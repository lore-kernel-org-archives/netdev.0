From: "M. Istehbab" <hariskhan@gmail.com>
Subject: linux-image-2.6.24-1-686: Linux kernel IPv4 : random TCP connection failure
Date: Mon, 21 Apr 2008 21:26:24 +0500
Message-ID: <c1410bfe0804210926t464df080radcfe6e5645032a7@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from yw-out-2324.google.com ([74.125.46.29]:1625 "EHLO
	yw-out-2324.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753731AbYDUQ0f (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 Apr 2008 12:26:35 -0400
Received: by yw-out-2324.google.com with SMTP id 5so1048810ywb.1
        for <netdev@vger.kernel.org>; Mon, 21 Apr 2008 09:26:24 -0700 (PDT)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Package: linux-image-2.6.24-1-686
Version: 2.6.24-6
Severity: important

I have tried it with kernels from debian between 2.6.18-5-686 - 2.6.24-1-686.

I have seen a severe issue of this problem in my transparent proxy
setup. This problem also occurs at times when it is not redirecting
traffic, rather accepting it
directly. Increasing the number of file descriptors didn't help. I
rebuilt the kernel with 65K file descriptors, still the problem
persists.

Even if it is one client behind squid or this box, this happens. It
will at random, not accept connections. squid doesn't report any in
the log. netstat doesn't show any
in its output as well.

I have changed NICs, I have changed between squid versions from 2.x to
3.x. Nothing has helped.

Following are some settings to mention;

ulimit -n is set to 8000
net.core.somaxconn = 1024
net.core.netdev_max_backlog = 3000
net.ipv4.tcp_max_syn_backlog = 3000

squid is built with 8000 file descriptors.

This is a 60 client LAN behind this box, using it as an internet
gateway/firewall for the following traffic;

1) vpn
2) email
3) cvs
4) browsing (http/https)
5) some ftp

/////////////////////////////////////////////////////////////////////////////////////////

This is a PIII (Coppermine)
cpu MHz         : 864.499
RAM             : 1 GB
Hard disk       : 2x 36 GB SCSI hard drives
RAID            : raid1
Non Raid part   : 3 non raid partitions

/////////////////////////////////////////////////////////////////////////////////////////

# cat /proc/mst
cat: /proc/mst: No such file or directory
sglhrcvs:~/work/traffic-shaping# cat /proc/mdstat
Personalities : [raid1]
md0 : active raid1 sda1[0] sdb1[1]
     32226240 blocks [2/2] [UU]


unused devices: <none>

/////////////////////////////////////////////////////////////////////////////////////////

This box worked fine when it had RHEL WS3 on it.


-- Package-specific info:
** Version:
Linux version 2.6.24-1-686 (Debian 2.6.24-6) (waldi@debian.org) (gcc
version 4.1.3 20080308 (prerelease) (Debian 4.1.2-21)) #1 SMP Sat Apr
19 00:37:55 UTC 2008

** Command line:
root=/dev/md0 ro

process `sysctl' is using deprecated sysctl (syscall)
net.ipv6.neigh.default.retrans_time; Use
net.ipv6.neigh.default.retrans_time_ms instead.

** Loaded modules:
Module                  Size  Used by
cls_u32                 8100  1
sch_cbq                16352  1
tcp_diag                1792  0
inet_diag              12136  1 tcp_diag
xt_limit                2656  1
xt_state                2464  1
ipt_REDIRECT            2080  3
ipt_MASQUERADE          3776  3
xt_MARK                 2272  11
iptable_nat             6916  1
nf_nat                 18316  3 ipt_REDIRECT,ipt_MASQUERADE,iptable_nat
nf_conntrack_ipv4      17352  3 iptable_nat
nf_conntrack           62272  5
xt_state,ipt_MASQUERADE,iptable_nat,nf_nat,nf_conntrack_ipv4
iptable_filter          2976  1
ppdev                   8804  0
lp                     11076  0
ac                      6116  0
battery                13572  0
xt_TCPMSS               4384  1
xt_tcpmss               2240  1
xt_tcpudp               3136  29
iptable_mangle          2784  1
ip_tables              13188  3 iptable_nat,iptable_filter,iptable_mangle
x_tables               14244  10
xt_limit,xt_state,ipt_REDIRECT,ipt_MASQUERADE,xt_MARK,iptable_nat,xt_TCPMSS,xt_tcpmss,xt_tcpudp,ip_tables
pppoe                  12864  0
pppox                   3980  1 pppoe
ppp_generic            26196  2 pppoe,pppox
slhc                    5920  1 ppp_generic
ipv6                  240836  35
dm_snapshot            16964  0
dm_mirror              21600  0
dm_mod                 55812  2 dm_snapshot,dm_mirror
loop                   16804  0
parport_pc             33668  1
parport                34280  3 ppdev,lp,parport_pc
floppy                 54628  0
rtc                    13052  0
psmouse                36464  0
pcspkr                  3200  0
i2c_i801                9232  0
i2c_core               22432  1 i2c_i801
button                  8432  0
serio_raw               6660  0
shpchp                 31028  0
intel_agp              23412  1
agpgart                31688  1 intel_agp
pci_hotplug            27712  1 shpchp
intel_rng               5632  0
iTCO_wdt               11268  0
evdev                  11104  1
sg                     33264  0
sr_mod                 16708  0
cdrom                  32512  1 sr_mod
ext3                  122888  3
jbd                    43732  1 ext3
mbcache                 8288  1 ext3
raid1                  22240  1
md_mod                 73716  2 raid1
ide_generic             1280  0 [permanent]
sd_mod                 27200  7
aic7xxx               157560  5
scsi_transport_spi     22816  1 aic7xxx
ata_generic             7428  0
libata                144464  1 ata_generic
scsi_mod              141164  6
sg,sr_mod,sd_mod,aic7xxx,scsi_transport_spi,libata
generic                 4388  0 [permanent]
3c59x                  41064  0
e100                   33836  0
mii                     5312  2 3c59x,e100
piix                    7492  0 [permanent]
uhci_hcd               23376  0
ide_core              108292  3 ide_generic,generic,piix
usbcore               132940  2 uhci_hcd
thermal                16028  0
processor              36520  1 thermal
fan                     4772  0

** PCI devices:
00:00.0 Host bridge [0600]: Intel Corporation 82840 840 (Carmel)
Chipset Host Bridge (Hub A) [8086:1a21] (rev 01)
       Subsystem: Dell Unknown device [1028:0096]
       Control: I/O- Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop-
ParErr- Stepping- SERR+ FastB2B-
       Status: Cap+ 66MHz- UDF- FastB2B+ ParErr- DEVSEL=fast >TAbort-
<TAbort- <MAbort+ >SERR- <PERR+
       Latency: 0
       Region 0: Memory at ec000000 (32-bit, prefetchable) [size=32M]
       Capabilities: [a0] AGP version 2.0
               Status: RQ=32 Iso- ArqSz=0 Cal=0 SBA+ ITACoh- GART64-
HTrans- 64bit- FW+ AGP3- Rate=x1,x2,x4
               Command: RQ=1 ArqSz=0 Cal=0 SBA- AGP- GART64- 64bit-
FW- Rate=<none>

00:01.0 PCI bridge [0604]: Intel Corporation 82840 840 (Carmel)
Chipset AGP Bridge [8086:1a23] (rev 01) (prog-if 00 [Normal decode])
       Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop-
ParErr- Stepping- SERR+ FastB2B-
       Status: Cap- 66MHz+ UDF- FastB2B+ ParErr- DEVSEL=fast >TAbort-
<TAbort- <MAbort- >SERR- <PERR-
       Latency: 64
       Bus: primary=00, secondary=01, subordinate=01, sec-latency=64
       Memory behind bridge: f4000000-fbffffff
       Prefetchable memory behind bridge: 50000000-500fffff
       Secondary status: 66MHz+ FastB2B+ ParErr- DEVSEL=medium
>TAbort- <TAbort- <MAbort+ <SERR- <PERR-
       BridgeCtl: Parity- SERR+ NoISA+ VGA+ MAbort- >Reset- FastB2B-

00:1e.0 PCI bridge [0604]: Intel Corporation 82801AA PCI Bridge
[8086:2418] (rev 02) (prog-if 00 [Normal decode])
       Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop-
ParErr- Stepping- SERR+ FastB2B-
       Status: Cap- 66MHz- UDF- FastB2B+ ParErr- DEVSEL=fast >TAbort-
<TAbort- <MAbort- >SERR- <PERR-
       Latency: 0
       Bus: primary=00, secondary=02, subordinate=03, sec-latency=64
       I/O behind bridge: 0000e000-0000ffff
       Memory behind bridge: f0000000-f3ffffff
       Secondary status: 66MHz- FastB2B+ ParErr- DEVSEL=medium
>TAbort- <TAbort- <MAbort+ <SERR- <PERR-
       BridgeCtl: Parity- SERR+ NoISA+ VGA- MAbort- >Reset- FastB2B-

00:1f.0 ISA bridge [0601]: Intel Corporation 82801AA ISA Bridge (LPC)
[8086:2410] (rev 02)
       Control: I/O+ Mem+ BusMaster+ SpecCycle+ MemWINV- VGASnoop-
ParErr- Stepping- SERR- FastB2B-
       Status: Cap- 66MHz- UDF- FastB2B+ ParErr- DEVSEL=medium
>TAbort- <TAbort- <MAbort- >SERR- <PERR-
       Latency: 0

00:1f.1 IDE interface [0101]: Intel Corporation 82801AA IDE
[8086:2411] (rev 02) (prog-if 80 [Master])
       Subsystem: Intel Corporation 82801AA IDE [8086:2411]
       Control: I/O+ Mem- BusMaster- SpecCycle- MemWINV- VGASnoop-
ParErr- Stepping- SERR- FastB2B-
       Status: Cap- 66MHz- UDF- FastB2B+ ParErr- DEVSEL=medium
>TAbort- <TAbort- <MAbort- >SERR- <PERR-
       Region 0: [virtual] Memory at 000001f0 (32-bit,
non-prefetchable) [disabled] [size=8]
       Region 1: [virtual] Memory at 000003f0 (type 3,
non-prefetchable) [disabled] [size=1]
       Region 2: [virtual] Memory at 00000170 (32-bit,
non-prefetchable) [disabled] [size=8]
       Region 3: [virtual] Memory at 00000370 (type 3,
non-prefetchable) [disabled] [size=1]
       Region 4: I/O ports at 1020 [size=16]

00:1f.2 USB Controller [0c03]: Intel Corporation 82801AA USB
[8086:2412] (rev 02) (prog-if 00 [UHCI])
       Subsystem: Intel Corporation 82801AA USB [8086:2412]
       Control: I/O+ Mem- BusMaster+ SpecCycle- MemWINV- VGASnoop-
ParErr- Stepping- SERR- FastB2B-
       Status: Cap- 66MHz- UDF- FastB2B+ ParErr- DEVSEL=medium
>TAbort- <TAbort- <MAbort- >SERR- <PERR-
       Latency: 0
       Interrupt: pin D routed to IRQ 16
       Region 4: I/O ports at 1000 [size=32]

00:1f.3 SMBus [0c05]: Intel Corporation 82801AA SMBus [8086:2413] (rev 02)
       Subsystem: Intel Corporation 82801AA SMBus [8086:2413]
       Control: I/O+ Mem- BusMaster- SpecCycle- MemWINV- VGASnoop-
ParErr- Stepping- SERR- FastB2B-
       Status: Cap- 66MHz- UDF- FastB2B+ ParErr- DEVSEL=medium
>TAbort- <TAbort- <MAbort- >SERR- <PERR-
       Interrupt: pin B routed to IRQ 18
       Region 4: I/O ports at dcd0 [size=16]

01:00.0 VGA compatible controller [0300]: S3 Inc. 86c368 [Trio 3D/2X]
[5333:8a13] (rev 02) (prog-if 00 [VGA])
       Subsystem: S3 Inc. Trio3D/2X [5333:8a13]
       Control: I/O+ Mem+ BusMaster- SpecCycle- MemWINV- VGASnoop-
ParErr- Stepping- SERR- FastB2B-
       Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=medium
>TAbort- <TAbort- <MAbort- >SERR- <PERR-
       Region 0: Memory at f4000000 (32-bit, non-prefetchable) [size=64M]
       Expansion ROM at 50000000 [disabled] [size=64K]
       Capabilities: [dc] Power Management version 1
               Flags: PMEClk- DSI+ D1+ D2+ AuxCurrent=0mA
PME(D0-,D1-,D2-,D3hot-,D3cold-)
               Status: D0 PME-Enable- DSel=0 DScale=0 PME-
       Capabilities: [80] AGP version 1.0
               Status: RQ=32 Iso- ArqSz=0 Cal=0 SBA- ITACoh- GART64-
HTrans- 64bit- FW- AGP3- Rate=x1,x2
               Command: RQ=1 ArqSz=0 Cal=0 SBA- AGP- GART64- 64bit- FW- Rate=x2

02:04.0 Ethernet controller [0200]: 3Com Corporation 3c905C-TX/TX-M
[Tornado] [10b7:9200] (rev 78)
       Subsystem: Dell Unknown device [1028:0096]
       Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV+ VGASnoop-
ParErr- Stepping- SERR+ FastB2B-
       Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=medium
>TAbort- <TAbort- <MAbort- >SERR- <PERR-
       Latency: 64 (2500ns min, 2500ns max), Cache Line Size: 32 bytes
       Interrupt: pin A routed to IRQ 17
       Region 0: I/O ports at ec80 [size=128]
       Region 1: Memory at f0fffc00 (32-bit, non-prefetchable) [size=128]
       Expansion ROM at f0200000 [disabled] [size=128K]
       Capabilities: [dc] Power Management version 2
               Flags: PMEClk- DSI- D1+ D2+ AuxCurrent=0mA
PME(D0+,D1+,D2+,D3hot+,D3cold+)
               Status: D0 PME-Enable- DSel=0 DScale=2 PME-

02:06.0 Multimedia audio controller [0401]: Cirrus Logic CS 4614/22/24
[CrystalClear SoundFusion Audio Accelerator] [1013:6003] (rev 01)
       Subsystem: Dell Unknown device [1028:0096]
       Control: I/O- Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop-
ParErr- Stepping- SERR+ FastB2B-
       Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=medium
>TAbort- <TAbort- <MAbort- >SERR- <PERR-
       Latency: 64 (1000ns min, 6000ns max)
       Interrupt: pin A routed to IRQ 9
       Region 0: Memory at f0ffe000 (32-bit, non-prefetchable) [size=4K]
       Region 1: Memory at f0e00000 (32-bit, non-prefetchable) [size=1M]
       Capabilities: [40] Power Management version 2
               Flags: PMEClk+ DSI+ D1+ D2+ AuxCurrent=0mA
PME(D0+,D1+,D2+,D3hot+,D3cold-)
               Status: D0 PME-Enable- DSel=0 DScale=0 PME-

02:08.0 Ethernet controller [0200]: Intel Corporation 82557/8/9
[Ethernet Pro 100] [8086:1229] (rev 05)
       Subsystem: IBM 82558B Ethernet Pro 10/100 [1014:005c]
       Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV+ VGASnoop-
ParErr- Stepping- SERR+ FastB2B-
       Status: Cap+ 66MHz- UDF- FastB2B+ ParErr- DEVSEL=medium
>TAbort- <TAbort- <MAbort- >SERR- <PERR-
       Latency: 64 (2000ns min, 14000ns max), Cache Line Size: 32 bytes
       Interrupt: pin A routed to IRQ 17
       Region 0: Memory at ee000000 (32-bit, prefetchable) [size=4K]
       Region 1: I/O ports at ec60 [size=32]
       Region 2: Memory at f0d00000 (32-bit, non-prefetchable) [size=1M]
       Expansion ROM at f0000000 [disabled] [size=1M]
       Capabilities: [dc] Power Management version 1
               Flags: PMEClk- DSI+ D1+ D2+ AuxCurrent=0mA
PME(D0+,D1+,D2+,D3hot+,D3cold-)
               Status: D0 PME-Enable- DSel=0 DScale=0 PME-

02:09.0 Ethernet controller [0200]: Intel Corporation 82557/8/9
[Ethernet Pro 100] [8086:1229] (rev 0c)
       Subsystem: Intel Corporation EtherExpress PRO/100 S Desktop
Adapter [8086:0040]
       Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV+ VGASnoop-
ParErr- Stepping- SERR+ FastB2B-
       Status: Cap+ 66MHz- UDF- FastB2B+ ParErr- DEVSEL=medium
>TAbort- <TAbort- <MAbort- >SERR- <PERR-
       Latency: 64 (2000ns min, 14000ns max), Cache Line Size: 32 bytes
       Interrupt: pin A routed to IRQ 18
       Region 0: Memory at f0ffd000 (32-bit, non-prefetchable) [size=4K]
       Region 1: I/O ports at ec00 [size=64]
       Region 2: Memory at f0fc0000 (32-bit, non-prefetchable) [size=128K]
       Expansion ROM at f0240000 [disabled] [size=64K]
       Capabilities: [dc] Power Management version 2
               Flags: PMEClk- DSI+ D1+ D2+ AuxCurrent=0mA
PME(D0+,D1+,D2+,D3hot+,D3cold+)
               Status: D0 PME-Enable- DSel=0 DScale=2 PME-

02:0b.0 Ethernet controller [0200]: 3Com Corporation 3c905B 100BaseTX
[Cyclone] [10b7:9055] (rev 24)
       Subsystem: 3Com Corporation 3C905B Fast Etherlink XL 10/100 [10b7:9055]
       Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV+ VGASnoop-
ParErr- Stepping- SERR+ FastB2B-
       Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=medium
>TAbort- <TAbort- <MAbort- >SERR- <PERR-
       Latency: 64 (2500ns min, 2500ns max), Cache Line Size: 32 bytes
       Interrupt: pin A routed to IRQ 16
       Region 0: I/O ports at e880 [size=128]
       Region 1: Memory at f0fff800 (32-bit, non-prefetchable) [size=128]
       Expansion ROM at f0220000 [disabled] [size=128K]
       Capabilities: [dc] Power Management version 1
               Flags: PMEClk- DSI- D1+ D2+ AuxCurrent=0mA
PME(D0-,D1+,D2+,D3hot+,D3cold+)
               Status: D0 PME-Enable- DSel=0 DScale=0 PME-

02:0e.0 PCI bridge [0604]: Digital Equipment Corporation DECchip 21152
[1011:0024] (rev 03) (prog-if 00 [Normal decode])
       Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop-
ParErr- Stepping- SERR+ FastB2B-
       Status: Cap+ 66MHz- UDF- FastB2B+ ParErr- DEVSEL=medium
>TAbort- <TAbort- <MAbort- >SERR- <PERR-
       Latency: 64, Cache Line Size: 32 bytes
       Bus: primary=02, secondary=03, subordinate=03, sec-latency=64
       I/O behind bridge: 0000f000-0000ffff
       Memory behind bridge: f2000000-f3ffffff
       Prefetchable memory behind bridge: 00000000f0100000-00000000f01fffff
       Secondary status: 66MHz- FastB2B+ ParErr- DEVSEL=medium
>TAbort- <TAbort- <MAbort- <SERR- <PERR-
       BridgeCtl: Parity- SERR+ NoISA+ VGA- MAbort- >Reset- FastB2B-
       Capabilities: [dc] Power Management version 1
               Flags: PMEClk- DSI- D1- D2- AuxCurrent=220mA
PME(D0-,D1-,D2-,D3hot-,D3cold-)
               Status: D0 PME-Enable- DSel=0 DScale=0 PME-
               Bridge: PM- B3+

03:0a.0 SCSI storage controller [0100]: Adaptec AIC-7899P U160/m
[9005:00cf] (rev 01)
       Subsystem: Dell Unknown device [1028:0096]
       Control: I/O- Mem+ BusMaster+ SpecCycle- MemWINV+ VGASnoop-
ParErr- Stepping- SERR+ FastB2B-
       Status: Cap+ 66MHz+ UDF- FastB2B+ ParErr- DEVSEL=medium
>TAbort- <TAbort- <MAbort- >SERR- <PERR-
       Latency: 64 (10000ns min, 6250ns max), Cache Line Size: 32 bytes
       Interrupt: pin A routed to IRQ 19
       BIST result: 00
       Region 0: I/O ports at fc00 [disabled] [size=256]
       Region 1: Memory at f2fff000 (64-bit, non-prefetchable) [size=4K]
       Expansion ROM at f3000000 [disabled] [size=128K]
       Capabilities: [dc] Power Management version 2
               Flags: PMEClk- DSI- D1- D2- AuxCurrent=0mA
PME(D0-,D1-,D2-,D3hot-,D3cold-)
               Status: D0 PME-Enable- DSel=0 DScale=0 PME-

03:0a.1 SCSI storage controller [0100]: Adaptec AIC-7899P U160/m
[9005:00cf] (rev 01)
       Subsystem: Dell Unknown device [1028:0096]
       Control: I/O- Mem+ BusMaster+ SpecCycle- MemWINV+ VGASnoop-
ParErr- Stepping- SERR+ FastB2B-
       Status: Cap+ 66MHz+ UDF- FastB2B+ ParErr- DEVSEL=medium
>TAbort- <TAbort- <MAbort- >SERR- <PERR-
       Latency: 64 (10000ns min, 6250ns max), Cache Line Size: 32 bytes
       Interrupt: pin B routed to IRQ 16
       BIST result: 00
       Region 0: I/O ports at f800 [disabled] [size=256]
       Region 1: Memory at f2ffe000 (64-bit, non-prefetchable) [size=4K]
       Expansion ROM at f0100000 [disabled] [size=128K]
       Capabilities: [dc] Power Management version 2
               Flags: PMEClk- DSI- D1- D2- AuxCurrent=0mA
PME(D0-,D1-,D2-,D3hot-,D3cold-)
               Status: D0 PME-Enable- DSel=0 DScale=0 PME-



-- System Information:
Debian Release: 4.0
 APT prefers stable
 APT policy: (500, 'stable')
Architecture: i386 (i686)
Shell:  /bin/sh linked to /bin/bash
Kernel: Linux 2.6.24-1-686
Locale: LANG=en_US.UTF-8, LC_CTYPE=en_US.UTF-8 (charmap=UTF-8)

Versions of packages linux-image-2.6.24-1-686 depends on:
ii  debconf [debconf-2.0]        1.5.11etch1 Debian configuration management sy
ii  initramfs-tools [linux-initr 0.85h       tools for generating an initramfs
ii  module-init-tools            3.3-pre4-2  tools for managing Linux kernel mo

Versions of packages linux-image-2.6.24-1-686 recommends:
ii  libc6-i686             2.3.6.ds1-13etch4 GNU C Library: Shared libraries [i

-- debconf information:
 shared/kernel-image/really-run-bootloader: true
 linux-image-2.6.24-1-686/preinst/overwriting-modules-2.6.24-1-686: true
 linux-image-2.6.24-1-686/postinst/bootloader-error-2.6.24-1-686:
 linux-image-2.6.24-1-686/postinst/create-kimage-link-2.6.24-1-686: true
 linux-image-2.6.24-1-686/postinst/old-system-map-link-2.6.24-1-686: true
 linux-image-2.6.24-1-686/prerm/would-invalidate-boot-loader-2.6.24-1-686: true
 linux-image-2.6.24-1-686/preinst/initrd-2.6.24-1-686:
 linux-image-2.6.24-1-686/preinst/failed-to-move-modules-2.6.24-1-686:
 linux-image-2.6.24-1-686/postinst/depmod-error-initrd-2.6.24-1-686: false
 linux-image-2.6.24-1-686/preinst/bootloader-initrd-2.6.24-1-686: true
 linux-image-2.6.24-1-686/postinst/old-initrd-link-2.6.24-1-686: true
 linux-image-2.6.24-1-686/preinst/lilo-has-ramdisk:
 linux-image-2.6.24-1-686/postinst/old-dir-initrd-link-2.6.24-1-686: true
 linux-image-2.6.24-1-686/preinst/abort-install-2.6.24-1-686:
 linux-image-2.6.24-1-686/prerm/removing-running-kernel-2.6.24-1-686: true
 linux-image-2.6.24-1-686/postinst/depmod-error-2.6.24-1-686: false
 linux-image-2.6.24-1-686/preinst/abort-overwrite-2.6.24-1-686:
 linux-image-2.6.24-1-686/preinst/elilo-initrd-2.6.24-1-686: true
 linux-image-2.6.24-1-686/postinst/bootloader-test-error-2.6.24-1-686:
 linux-image-2.6.24-1-686/postinst/kimage-is-a-directory:
 linux-image-2.6.24-1-686/preinst/lilo-initrd-2.6.24-1-686: true
