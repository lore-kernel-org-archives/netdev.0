From: rwhron@earthlink.net
Subject: 82540EM very slow on 2.6.0-test[45]
Date: Wed, 10 Sep 2003 19:35:12 -0400
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030910233512.GB18056@rushmore>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: scott.feldman@intel.com
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Content-Disposition: inline
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


ftp'ing a multi-megabyte file gives about 16-20k/second
throughput.  I first noticed this on 2.6.0-test4, but
the slowness may have existed longer.   The destination
machine was running Solaris 8.

This is a dual boot Dell P4.  XP is about 1000x faster for
an ftp xfer, so the network seems okay.

I tried the 11 patches in
http://marc.theaimsgroup.com/?l=linux-netdev&m=106307597016664&w=2
but that didn't make a noticeable difference in ftp xfer throughput.

The e1000 driver is non-module with default settings.

ifconfig doesn't show any dropped packets.

eth0      Link encap:Ethernet  HWaddr 00:08:74:EA:C8:9E
          inet addr:146.126.194.254  Bcast:146.126.194.255  Mask:255.255.255.128
          UP BROADCAST RUNNING MULTICAST  MTU:1500  Metric:1
          RX packets:14198 errors:0 dropped:0 overruns:0 frame:0
          TX packets:6195 errors:0 dropped:0 overruns:0 carrier:0
          collisions:0 txqueuelen:100
          RX bytes:3531096 (3.3 Mb)  TX bytes:8602840 (8.2 Mb)
          Interrupt:10 Base address:0xecc0 Memory:ff8e0000-ff900000


netstat during the ftp xfer shows a large send-Q:

Active Internet connections (servers and established)
Proto Recv-Q Send-Q Local Address           Foreign Address         State       PID/Program name
tcp        0      0 0.0.0.0:6000            0.0.0.0:*               LISTEN      1036/X
tcp        0      0 0.0.0.0:22              0.0.0.0:*               LISTEN      921/sshd
tcp        0  66608 146.126.194.254:32804   146.126.60.140:50182    ESTABLISHED 1686/ftp
tcp        0      0 146.126.194.254:32805   146.126.88.210:443      ESTABLISHED 1594/mozilla-bin
tcp        0      0 146.126.194.254:32803   146.126.60.140:21       ESTABLISHED 1686/ftp


iptables is on the system.  I ran "/etc/init.d/iptables stop"
and re-tried ftp, but that didn't make a difference.

Here is grep ^C /usr/src/linux/.config

CONFIG_X86=y
CONFIG_MMU=y
CONFIG_UID16=y
CONFIG_GENERIC_ISA_DMA=y
CONFIG_EXPERIMENTAL=y
CONFIG_CLEAN_COMPILE=y
CONFIG_STANDALONE=y
CONFIG_BROKEN_ON_SMP=y
CONFIG_SWAP=y
CONFIG_SYSVIPC=y
CONFIG_SYSCTL=y
CONFIG_LOG_BUF_SHIFT=14
CONFIG_EMBEDDED=y
CONFIG_KALLSYMS=y
CONFIG_FUTEX=y
CONFIG_EPOLL=y
CONFIG_IOSCHED_AS=y
CONFIG_IOSCHED_DEADLINE=y
CONFIG_X86_PC=y
CONFIG_MPENTIUM4=y
CONFIG_X86_CMPXCHG=y
CONFIG_X86_XADD=y
CONFIG_X86_L1_CACHE_SHIFT=7
CONFIG_RWSEM_XCHGADD_ALGORITHM=y
CONFIG_X86_WP_WORKS_OK=y
CONFIG_X86_INVLPG=y
CONFIG_X86_BSWAP=y
CONFIG_X86_POPAD_OK=y
CONFIG_X86_GOOD_APIC=y
CONFIG_X86_INTEL_USERCOPY=y
CONFIG_X86_USE_PPRO_CHECKSUM=y
CONFIG_X86_TSC=y
CONFIG_X86_MCE=y
CONFIG_NOHIGHMEM=y
CONFIG_MTRR=y
CONFIG_PM=y
CONFIG_PCI=y
CONFIG_PCI_GOANY=y
CONFIG_PCI_BIOS=y
CONFIG_PCI_DIRECT=y
CONFIG_PCI_NAMES=y
CONFIG_BINFMT_ELF=y
CONFIG_PNP=y
CONFIG_BLK_DEV_FD=y
CONFIG_BLK_DEV_RAM=y
CONFIG_BLK_DEV_RAM_SIZE=4096
CONFIG_IDE=y
CONFIG_BLK_DEV_IDE=y
CONFIG_BLK_DEV_IDEDISK=y
CONFIG_IDEDISK_MULTI_MODE=y
CONFIG_BLK_DEV_IDECD=y
CONFIG_BLK_DEV_IDEFLOPPY=y
CONFIG_BLK_DEV_IDEPCI=y
CONFIG_IDEPCI_SHARE_IRQ=y
CONFIG_BLK_DEV_GENERIC=y
CONFIG_BLK_DEV_IDEDMA_PCI=y
CONFIG_IDEDMA_PCI_AUTO=y
CONFIG_BLK_DEV_ADMA=y
CONFIG_BLK_DEV_PIIX=y
CONFIG_BLK_DEV_IDEDMA=y
CONFIG_IDEDMA_AUTO=y
CONFIG_NET=y
CONFIG_PACKET=y
CONFIG_PACKET_MMAP=y
CONFIG_UNIX=y
CONFIG_NET_KEY=y
CONFIG_INET=y
CONFIG_NETFILTER=y
CONFIG_IP_NF_CONNTRACK=y
CONFIG_IP_NF_FTP=y
CONFIG_IP_NF_IPTABLES=y
CONFIG_IP_NF_MATCH_LIMIT=y
CONFIG_IP_NF_MATCH_PKTTYPE=y
CONFIG_IP_NF_MATCH_MARK=y
CONFIG_IP_NF_MATCH_MULTIPORT=y
CONFIG_IP_NF_MATCH_TOS=y
CONFIG_IP_NF_MATCH_ECN=y
CONFIG_IP_NF_MATCH_DSCP=y
CONFIG_IP_NF_MATCH_STATE=y
CONFIG_IP_NF_MATCH_CONNTRACK=y
CONFIG_IP_NF_FILTER=y
CONFIG_IP_NF_TARGET_REJECT=y
CONFIG_IP_NF_MANGLE=y
CONFIG_IP_NF_TARGET_LOG=y
CONFIG_XFRM=y
CONFIG_IPV6_SCTP__=y
CONFIG_NETDEVICES=y
CONFIG_NET_ETHERNET=y
CONFIG_NET_PCI=y
CONFIG_EEPRO100=y
CONFIG_E1000=y
CONFIG_E1000_NAPI=y
CONFIG_INPUT=y
CONFIG_INPUT_MOUSEDEV=y
CONFIG_INPUT_MOUSEDEV_PSAUX=y
CONFIG_INPUT_MOUSEDEV_SCREEN_X=1024
CONFIG_INPUT_MOUSEDEV_SCREEN_Y=768
CONFIG_SOUND_GAMEPORT=y
CONFIG_SERIO=y
CONFIG_SERIO_I8042=y
CONFIG_SERIO_SERPORT=y
CONFIG_INPUT_KEYBOARD=y
CONFIG_KEYBOARD_ATKBD=y
CONFIG_INPUT_MOUSE=y
CONFIG_MOUSE_PS2=y
CONFIG_VT=y
CONFIG_VT_CONSOLE=y
CONFIG_HW_CONSOLE=y
CONFIG_UNIX98_PTYS=y
CONFIG_UNIX98_PTY_COUNT=128
CONFIG_RTC=y
CONFIG_AGP=y
CONFIG_AGP_INTEL=y
CONFIG_DRM=y
CONFIG_DRM_I810=y
CONFIG_EXT2_FS=y
CONFIG_EXT3_FS=y
CONFIG_JBD=y
CONFIG_ISO9660_FS=y
CONFIG_JOLIET=y
CONFIG_FAT_FS=y
CONFIG_MSDOS_FS=y
CONFIG_PROC_FS=y
CONFIG_DEVPTS_FS=y
CONFIG_TMPFS=y
CONFIG_RAMFS=y
CONFIG_SMB_FS=y
CONFIG_MSDOS_PARTITION=y
CONFIG_SMB_NLS=y
CONFIG_NLS=y
CONFIG_NLS_DEFAULT="iso8859-1"
CONFIG_NLS_CODEPAGE_437=y
CONFIG_FB=y
CONFIG_FB_VGA16=y
CONFIG_FB_VESA=y
CONFIG_VIDEO_SELECT=y
CONFIG_VGA_CONSOLE=y
CONFIG_DUMMY_CONSOLE=y
CONFIG_FRAMEBUFFER_CONSOLE=y
CONFIG_PCI_CONSOLE=y
CONFIG_FONT_8x8=y
CONFIG_FONT_8x16=y
CONFIG_SOUND=y
CONFIG_SOUND_PRIME=y
CONFIG_SOUND_ICH=y
CONFIG_DEBUG_KERNEL=y
CONFIG_MAGIC_SYSRQ=y
CONFIG_X86_BIOS_REBOOT=y

dmesg shows "e1000: eth0 NIC Link is Up 100 Mbps Full Duplex".
Here is the full dmesg log:

Linux version 2.6.0-test5 (root@hilltop) (gcc version 3.2.2 20030222 (Red Hat Linux 3.2.2-5)) #3 Wed Sep 10 10:07:45 EDT 2003
Video mode to be used for restore is f00
BIOS-provided physical RAM map:
 BIOS-e820: 0000000000000000 - 00000000000a0000 (usable)
 BIOS-e820: 00000000000f0000 - 0000000000100000 (reserved)
 BIOS-e820: 0000000000100000 - 000000001fe71000 (usable)
 BIOS-e820: 000000001fe71000 - 000000001fe73000 (ACPI NVS)
 BIOS-e820: 000000001fe73000 - 000000001fe94000 (ACPI data)
 BIOS-e820: 000000001fe94000 - 000000001ff00000 (reserved)
 BIOS-e820: 00000000fec00000 - 00000000fec10000 (reserved)
 BIOS-e820: 00000000fee00000 - 00000000fee10000 (reserved)
 BIOS-e820: 00000000ffb00000 - 0000000100000000 (reserved)
510MB LOWMEM available.
On node 0 totalpages: 130673
  DMA zone: 4096 pages, LIFO batch:1
  Normal zone: 126577 pages, LIFO batch:16
  HighMem zone: 0 pages, LIFO batch:1
DMI 2.3 present.
Building zonelist for node : 0
Kernel command line: ro nousb profile=2
kernel profiling enabled
Initializing CPU#0
PID hash table entries: 2048 (order 11: 16384 bytes)
Detected 1793.494 MHz processor.
Console: colour VGA+ 80x25
Memory: 512536k/522692k available (1601k kernel code, 9376k reserved, 468k data, 300k init, 0k highmem)
Calibrating delay loop... 3538.94 BogoMIPS
Dentry cache hash table entries: 65536 (order: 6, 262144 bytes)
Inode-cache hash table entries: 32768 (order: 5, 131072 bytes)
Mount-cache hash table entries: 512 (order: 0, 4096 bytes)
-> /dev
-> /dev/console
-> /root
CPU:     After generic identify, caps: bfebfbff 00000000 00000000 00000000
CPU:     After vendor identify, caps: bfebfbff 00000000 00000000 00000000
CPU: Trace cache: 12K uops, L1 D cache: 8K
CPU: L2 cache: 512K
CPU:     After all inits, caps: bfebfbff 00000000 00000000 00000080
Intel machine check architecture supported.
Intel machine check reporting enabled on CPU#0.
CPU#0: Intel P4/Xeon Extended MCE MSRs (12) available
CPU: Intel(R) Pentium(R) 4 CPU 1.80GHz stepping 07
Enabling fast FPU save and restore... done.
Enabling unmasked SIMD FPU exception support... done.
Checking 'hlt' instruction... OK.
POSIX conformance testing by UNIFIX
NET: Registered protocol family 16
PCI: PCI BIOS revision 2.10 entry at 0xfbdf8, last bus=1
PCI: Using configuration type 1
mtrr: v2.0 (20020519)
Linux Plug and Play Support v0.97 (c) Adam Belay
PCI: Probing PCI hardware
PCI: Probing PCI hardware (bus 00)
PCI: Ignoring BAR0-3 of IDE controller 0000:00:1f.1
Transparent bridge - 0000:00:1e.0
PCI: Using IRQ router PIIX [8086/24c0] at 0000:00:1f.0
PCI: IRQ 0 for device 0000:00:1f.1 doesn't match PIRQ mask - try pci=usepirqmask
PCI: Found IRQ 10 for device 0000:00:1f.1
PCI: Sharing IRQ 10 with 0000:00:1d.2
PCI: Sharing IRQ 10 with 0000:01:0c.0
vga16fb: initializing
vga16fb: mapped to 0xc00a0000
fb0: VGA16 VGA frame buffer device
Console: switching to colour frame buffer device 80x30
pty: 256 Unix98 ptys configured
SBF: Simple Boot Flag extension found and enabled.
SBF: Simple boot flag value 0x87 read from CMOS RAM was invalid
SBF: Setting boot flags 0x1
Real Time Clock Driver v1.12
Linux agpgart interface v0.100 (c) Dave Jones
agpgart: Detected an Intel 845G Chipset.
agpgart: Maximum main memory to use for agp memory: 438M
agpgart: Detected 892K stolen memory.
agpgart: AGP aperture is 128M @ 0xe8000000
[drm] Initialized i810 1.4.0 20030605 on minor 0
Using anticipatory scheduling io scheduler
Floppy drive(s): fd0 is 1.44M
FDC 0 is a post-1991 82077
RAMDISK driver initialized: 16 RAM disks of 4096K size 1024 blocksize
Intel(R) PRO/1000 Network Driver - version 5.2.16-k1
Copyright (c) 1999-2003 Intel Corporation.
PCI: Found IRQ 10 for device 0000:01:0c.0
PCI: Sharing IRQ 10 with 0000:00:1d.2
PCI: Sharing IRQ 10 with 0000:00:1f.1
eth0: Intel(R) PRO/1000 Network Connection
Uniform Multi-Platform E-IDE driver Revision: 7.00alpha2
ide: Assuming 33MHz system bus speed for PIO modes; override with idebus=xx
ICH4: IDE controller at PCI slot 0000:00:1f.1
PCI: Enabling device 0000:00:1f.1 (0005 -> 0007)
PCI: Found IRQ 10 for device 0000:00:1f.1
PCI: Sharing IRQ 10 with 0000:00:1d.2
PCI: Sharing IRQ 10 with 0000:01:0c.0
ICH4: chipset revision 1
ICH4: not 100% native mode: will probe irqs later
    ide0: BM-DMA at 0xffa0-0xffa7, BIOS settings: hda:DMA, hdb:pio
    ide1: BM-DMA at 0xffa8-0xffaf, BIOS settings: hdc:DMA, hdd:pio
hda: ST340016A, ATA DISK drive
ide0 at 0x1f0-0x1f7,0x3f6 on irq 14
hdc: SAMSUNG DVD-ROM SD-616T, ATAPI CD/DVD-ROM drive
ide1 at 0x170-0x177,0x376 on irq 15
hda: max request size: 128KiB
hda: 78165360 sectors (40020 MB) w/2048KiB Cache, CHS=65535/16/63, UDMA(100)
 hda: hda1 hda2 hda3 hda4 < hda5 >
hdc: ATAPI 48X DVD-ROM drive, 512kB Cache, UDMA(33)
Uniform CD-ROM driver Revision: 3.12
ide-floppy driver 0.99.newide
Console: switching to colour frame buffer device 80x30
mice: PS/2 mouse device common for all mice
input: ImPS/2 Generic Wheel Mouse on isa0060/serio1
serio: i8042 AUX port at 0x60,0x64 irq 12
input: AT Set 2 keyboard on isa0060/serio0
serio: i8042 KBD port at 0x60,0x64 irq 1
Intel 810 + AC97 Audio, version 0.24, 17:13:46 Sep  8 2003
PCI: Found IRQ 11 for device 0000:00:1f.5
PCI: Sharing IRQ 11 with 0000:00:1f.3
PCI: Setting latency timer of device 0000:00:1f.5 to 64
i810: Intel ICH4 found at IO 0xdc40 and 0xd800, MEM 0xffa00400 and 0xffa00000, IRQ 11
i810: Intel ICH4 mmio at 0xe08ca400 and 0xe08cc000
i810_audio: Primary codec has ID 0
i810_audio: Audio Controller supports 6 channels.
i810_audio: Defaulting to base 2 channel mode.
i810_audio: Resetting connection 0
i810_audio: Connection 0 with codec id 0
ac97_codec: AC97 Audio codec, id: ADS116 (Unknown)
i810_audio: AC'97 codec 0 supports AMAP, total channels = 2
i810_audio: setting clocking to 48648
NET: Registered protocol family 2
IP: routing cache hash table of 4096 buckets, 32Kbytes
TCP: Hash tables configured (established 32768 bind 65536)
ip_conntrack version 2.1 (4083 buckets, 32664 max) - 160 bytes per conntrack
ip_tables: (C) 2000-2002 Netfilter core team
NET: Registered protocol family 1
NET: Registered protocol family 17
NET: Registered protocol family 15
kjournald starting.  Commit interval 5 seconds
EXT3-fs: mounted filesystem with ordered data mode.
VFS: Mounted root (ext3 filesystem) readonly.
Freeing unused kernel memory: 300k freed
EXT3 FS on hda2, internal journal
Adding 514072k swap on /dev/hda3.  Priority:-1 extents:1
kjournald starting.  Commit interval 5 seconds
EXT3 FS on hda5, internal journal
EXT3-fs: mounted filesystem with ordered data mode.
blk: queue dfcdea00, I/O limit 4095Mb (mask 0xffffffff)
e1000: eth0 NIC Link is Up 100 Mbps Full Duplex
spurious 8259A interrupt: IRQ7.

Here is a short snippet of "tcpdump -s 1500 host $remotehost"


14:22:44.181589 tcmsgpc.southernco.com.50182 > sixgp06w.southernco.com.32804: . ack 3236331158 win 24616 <nop,nop,timestamp 497026209 13941233> (DF)
14:22:44.488916 sixgp06w.southernco.com.32804 > tcmsgpc.southernco.com.50182: . 1:1449(1448) ack 0 win 5840 <nop,nop,timestamp 13941661 497026209> (DF) [tos 0x8]
14:22:44.601516 tcmsgpc.southernco.com.50182 > sixgp06w.southernco.com.32804: . ack 1449 win 24616 <nop,nop,timestamp 497026251 13941661> (DF)
14:22:44.601551 sixgp06w.southernco.com.32804 > tcmsgpc.southernco.com.50182: . 1449:2897(1448) ack 0 win 5840 <nop,nop,timestamp 13941773 497026251> (DF) [tos 0x8]
14:22:44.601560 sixgp06w.southernco.com.32804 > tcmsgpc.southernco.com.50182: . 2897:4345(1448) ack 0 win 5840 <nop,nop,timestamp 13941773 497026251> (DF) [tos 0x8]
14:22:44.602592 tcmsgpc.southernco.com.50182 > sixgp06w.southernco.com.32804: . ack 4345 win 24616 <nop,nop,timestamp 497026251 13941773> (DF)
14:22:44.602607 sixgp06w.southernco.com.32804 > tcmsgpc.southernco.com.50182: . 4345:5793(1448) ack 0 win 5840 <nop,nop,timestamp 13941774 497026251> (DF) [tos 0x8]
14:22:44.602614 sixgp06w.southernco.com.32804 > tcmsgpc.southernco.com.50182: . 5793:7241(1448) ack 0 win 5840 <nop,nop,timestamp 13941774 497026251> (DF) [tos 0x8]
14:22:44.603513 tcmsgpc.southernco.com.50182 > sixgp06w.southernco.com.32804: . ack 7241 win 24616 <nop,nop,timestamp 497026251 13941774> (DF)
14:22:44.603526 sixgp06w.southernco.com.32804 > tcmsgpc.southernco.com.50182: . 7241:8689(1448) ack 0 win 5840 <nop,nop,timestamp 13941775 497026251> (DF) [tos 0x8]
14:22:44.603533 sixgp06w.southernco.com.32804 > tcmsgpc.southernco.com.50182: P 8689:10137(1448) ack 0 win 5840 <nop,nop,timestamp 13941775 497026251> (DF) [tos 0x8]
14:22:44.604437 tcmsgpc.southernco.com.50182 > sixgp06w.southernco.com.32804: . ack 10137 win 24616 <nop,nop,timestamp 497026251 13941775> (DF)
14:22:44.604451 sixgp06w.southernco.com.32804 > tcmsgpc.southernco.com.50182: . 10137:10085(4294967244) ack 0 win 5840 <nop,nop,timestamp 13941776 497026251> (DF) [tos 0x8]
14:22:44.721478 tcmsgpc.southernco.com.50182 > sixgp06w.southernco.com.32804: . ack 11585 win 24616 <nop,nop,timestamp 497026263 13941776> (DF)
14:22:44.721497 sixgp06w.southernco.com.32804 > tcmsgpc.southernco.com.50182: . 11585:13033(1448) ack 0 win 5840 <nop,nop,timestamp 13941893 497026263> (DF) [tos 0x8]
14:22:44.841444 tcmsgpc.southernco.com.50182 > sixgp06w.southernco.com.32804: . ack 13033 win 24616 <nop,nop,timestamp 497026275 13941893> (DF)
14:22:44.841505 sixgp06w.southernco.com.32804 > tcmsgpc.southernco.com.50182: . 13033:14481(1448) ack 0 win 5840 <nop,nop,timestamp 13942013 497026275> (DF) [tos 0x8]
14:22:44.961555 tcmsgpc.southernco.com.50182 > sixgp06w.southernco.com.32804: . ack 14481 win 24616 <nop,nop,timestamp 497026287 13942013> (DF)
14:22:44.961575 sixgp06w.southernco.com.32804 > tcmsgpc.southernco.com.50182: . 14481:15929(1448) ack 0 win 5840 <nop,nop,timestamp 13942133 497026287> (DF) [tos 0x8]
14:22:45.081516 tcmsgpc.southernco.com.50182 > sixgp06w.southernco.com.32804: . ack 15929 win 24616 <nop,nop,timestamp 497026299 13942133> (DF)
14:22:45.081535 sixgp06w.southernco.com.32804 > tcmsgpc.southernco.com.50182: . 15929:17377(1448) ack 0 win 5840 <nop,nop,timestamp 13942253 497026299> (DF) [tos 0x8]
14:22:45.201477 tcmsgpc.southernco.com.50182 > sixgp06w.southernco.com.32804: . ack 17377 win 24616 <nop,nop,timestamp 497026311 13942253> (DF)
14:22:45.201494 sixgp06w.southernco.com.32804 > tcmsgpc.southernco.com.50182: . 17377:18825(1448) ack 0 win 5840 <nop,nop,timestamp 13942373 497026311> (DF) [tos 0x8]
14:22:45.321599 tcmsgpc.southernco.com.50182 > sixgp06w.southernco.com.32804: . ack 18825 win 24616 <nop,nop,timestamp 497026323 13942373> (DF)
14:22:45.321670 sixgp06w.southernco.com.32804 > tcmsgpc.southernco.com.50182: . 18825:20273(1448) ack 0 win 5840 <nop,nop,timestamp 13942493 497026323> (DF) [tos 0x8]
14:22:45.441416 tcmsgpc.southernco.com.50182 > sixgp06w.southernco.com.32804: . ack 20273 win 24616 <nop,nop,timestamp 497026335 13942493> (DF)
14:22:45.441511 sixgp06w.southernco.com.32804 > tcmsgpc.southernco.com.50182: . 20273:21721(1448) ack 0 win 5840 <nop,nop,timestamp 13942613 497026335> (DF) [tos 0x8]
14:22:45.561525 tcmsgpc.southernco.com.50182 > sixgp06w.southernco.com.32804: . ack 21721 win 24616 <nop,nop,timestamp 497026347 13942613> (DF)
14:22:45.561610 sixgp06w.southernco.com.32804 > tcmsgpc.southernco.com.50182: . 21721:21669(4294967244) ack 0 win 5840 <nop,nop,timestamp 13942733 497026347> (DF) [tos 0x8]
14:22:45.681540 tcmsgpc.southernco.com.50182 > sixgp06w.southernco.com.32804: . ack 23169 win 24616 <nop,nop,timestamp 497026359 13942733> (DF)
14:22:45.988697 sixgp06w.southernco.com.32804 > tcmsgpc.southernco.com.50182: . 23169:24617(1448) ack 0 win 5840 <nop,nop,timestamp 13943161 497026359> (DF) [tos 0x8]
14:22:46.101407 tcmsgpc.southernco.com.50182 > sixgp06w.southernco.com.32804: . ack 24617 win 24616 <nop,nop,timestamp 497026401 13943161> (DF)
14:22:46.101478 sixgp06w.southernco.com.32804 > tcmsgpc.southernco.com.50182: . 24617:26065(1448) ack 0 win 5840 <nop,nop,timestamp 13943273 497026401> (DF) [tos 0x8]
14:22:46.101492 sixgp06w.southernco.com.32804 > tcmsgpc.southernco.com.50182: . 26065:27513(1448) ack 0 win 5840 <nop,nop,timestamp 13943273 497026401> (DF) [tos 0x8]
14:22:46.102601 tcmsgpc.southernco.com.50182 > sixgp06w.southernco.com.32804: . ack 27513 win 24616 <nop,nop,timestamp 497026401 13943273> (DF)
14:22:46.102616 sixgp06w.southernco.com.32804 > tcmsgpc.southernco.com.50182: . 27513:28961(1448) ack 0 win 5840 <nop,nop,timestamp 13943274 497026401> (DF) [tos 0x8]
14:22:46.102622 sixgp06w.southernco.com.32804 > tcmsgpc.southernco.com.50182: . 28961:30409(1448) ack 0 win 5840 <nop,nop,timestamp 13943274 497026401> (DF) [tos 0x8]
14:22:46.103601 tcmsgpc.southernco.com.50182 > sixgp06w.southernco.com.32804: . ack 30409 win 24616 <nop,nop,timestamp 497026401 13943274> (DF)
14:22:46.103614 sixgp06w.southernco.com.32804 > tcmsgpc.southernco.com.50182: . 30409:31857(1448) ack 0 win 5840 <nop,nop,timestamp 13943275 497026401> (DF) [tos 0x8]
14:22:46.103621 sixgp06w.southernco.com.32804 > tcmsgpc.southernco.com.50182: . 31857:33305(1448) ack 0 win 5840 <nop,nop,timestamp 13943275 497026401> (DF) [tos 0x8]
14:22:46.104600 tcmsgpc.southernco.com.50182 > sixgp06w.southernco.com.32804: . ack 33305 win 24616 <nop,nop,timestamp 497026401 13943275> (DF)
14:22:46.104613 sixgp06w.southernco.com.32804 > tcmsgpc.southernco.com.50182: . 33305:33253(4294967244) ack 0 win 5840 <nop,nop,timestamp 13943276 497026401> (DF) [tos 0x8]


Here is lspci:

00:00.0 Host bridge: Intel Corp. 82845G/GL [Brookdale-G] Chipset Host Bridge (rev 01)
00:02.0 VGA compatible controller: Intel Corp. 82845G/GL [Brookdale-G] Chipset Integrated Graphics Device (rev 01)
00:1d.0 USB Controller: Intel Corp. 82801DB USB (Hub #1) (rev 01)
00:1d.1 USB Controller: Intel Corp. 82801DB USB (Hub #2) (rev 01)
00:1d.2 USB Controller: Intel Corp. 82801DB USB (Hub #3) (rev 01)
00:1d.7 USB Controller: Intel Corp. 82801DB USB EHCI Controller (rev 01)
00:1e.0 PCI bridge: Intel Corp. 82801BA/CA/DB PCI Bridge (rev 81)
00:1f.0 ISA bridge: Intel Corp. 82801DB ISA Bridge (LPC) (rev 01)
00:1f.1 IDE interface: Intel Corp. 82801DB ICH4 IDE (rev 01)
00:1f.3 SMBus: Intel Corp. 82801DB SMBus (rev 01)
00:1f.5 Multimedia audio controller: Intel Corp. 82801DB AC'97 Audio (rev 01)
01:0c.0 Ethernet controller: Intel Corp. 82540EM Gigabit Ethernet Controller (rev 02)

Is anyone getting decent throughput from an Intel 82540EM
Gigabit Ethernet Controller with 2.6.0-test?  Suggestions
are welcome.

-- 
Randy Hron
http://home.earthlink.net/~rwhron/kernel/bigbox.html
