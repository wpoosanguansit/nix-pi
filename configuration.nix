{ config, pkgs, ... }:

{
  #imports = [ <nixpkgs/nixos/modules/installer/cd-dvd/sd-image-aarch64.nix> ];
  services.xserver = {
  	enable = true;
  	desktopManager.xfce.enable = true;
  	displayManager.auto.enable = true;
  	videoDrivers = [ "modsetting" ];
  };
  networking.hostId = "8425e340";


  # if you have a Raspberry Pi 2 or 3, pick this:
  boot.kernelPackages = pkgs.linuxPackages_latest;

  # A bunch of boot parameters needed for optimal runtime on RPi 3b+
  boot.kernelParams = ["cma=256M"];
  boot.loader.raspberryPi.enable = true;
  boot.loader.raspberryPi.version = 3;
  boot.loader.raspberryPi.uboot.enable = true;
  boot.loader.raspberryPi.firmwareConfig = ''
    gpu_mem=256
  '';

  # File systems configuration for using the installer's partition layout
  fileSystems = {
    "/boot" = {
      device = "/dev/disk/by-label/NIXOS_BOOT";
      fsType = "vfat";
    };
    "/" = {
      device = "/dev/disk/by-label/NIXOS_SD";
      fsType = "zfs";
    };
  };

  # Preserve space by sacrificing documentation and history
  services.nixosManual.enable = false;
  nix.gc.automatic = true;
  nix.gc.options = "--delete-older-than 30d";
  boot.cleanTmpDir = true;

  # Configure basic SSH access
  services.openssh.enable = true;
  services.openssh.permitRootLogin = "yes";

  # Use 1GB of additional swap memory in order to not run out of memory
  # when installing lots of things while running other things at the same time.
  swapDevices = [ { device = "/swapfile"; size = 2048; } ];

  networking.wireless.enable = true;
  hardware.bluetooth.enable = true;
  # NixOS wants to enable GRUB by default
  boot.loader.grub.enable = false;

  users.extraUsers.admin = {
    name = "admin";
    group = "users";
    extraGroups = [ "wheel" "disk" "video" "autdio" "networkmanager" "systemd-journal" ];
    createHome = true;
    uid = 1000;
    home = "/home/admin";
  };

  environment.systemPackages = with pkgs; [
    raspberrypi-tools vim wpa_supplicant midori 
  ];

  nixpkgs.config = { 
    allowUnfree = true;
    oraclejdk.accept_license = true;
  }
}

