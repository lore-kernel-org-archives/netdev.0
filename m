From: Meelis Roos <mroos@linux.ee>
Subject: tulip_stop_rxtx() failed
Date: Thu, 23 Nov 2006 13:59:17 +0200 (EET)
Message-ID: <Pine.SOC.4.61.0611231347090.24112@math.ut.ee>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Return-path: <netdev-owner@vger.kernel.org>
Received: from math.ut.ee ([193.40.36.2]:28590 "EHLO math.ut.ee")
	by vger.kernel.org with ESMTP id S1755698AbWKWL7V (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 23 Nov 2006 06:59:21 -0500
Received: from math.ut.ee (localhost [IPv6:::1])
	by math.ut.ee (8.12.8+Sun/8.12.8/math-1.2) with ESMTP id kANBxI28012518
	for <netdev@vger.kernel.org>; Thu, 23 Nov 2006 13:59:18 +0200 (EET)
Received: from localhost (mroos@localhost)
	by math.ut.ee (8.12.8+Sun/8.12.2/Submit) with ESMTP id kANBxHng012514
	for <netdev@vger.kernel.org>; Thu, 23 Nov 2006 13:59:18 +0200 (EET)
To: netdev@vger.kernel.org
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Background: Motorola Powerstack II (RS/6000 clone), PRep PowerPC 
machine, running Debian unstable userspace and latest git kernels. 1 
21140 onboard, another in PCI slot.

Occasionally there is the message
0000:00:06.0: tulip_stop_rxtx() failed
during bootup. It does not happen every time, just sometimes (about half 
boots with different git kernels). Everything seems to be working fine 
though. So this is nothing critical but just strange.

0000:00:06.0 seems to be eth1. There is a message about no MII on eth1 
that also differentiates it from eth0.
tulip1: ***WARNING***: No MII transceiver found!
eth1: Digital DS21140 Tulip rev 34 at MMIO 0xc2000000, 00:00:94:7A:31:8C, IRQ 10.


lspci and dmesg below, any additional information on request.

00:00.0 Host bridge: IBM 82660 CPU to PCI Bridge (rev 02)
	Control: I/O- Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- Stepping- SERR+ FastB2B-
	Status: Cap- 66MHz- UDF- FastB2B- ParErr- DEVSEL=medium >TAbort- <TAbort- <MAbort- >SERR- <PERR-
	Latency: 0

00:01.0 ISA bridge: Symphony Labs W83C553 (rev 10)
	Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- Stepping- SERR- FastB2B-
	Status: Cap- 66MHz- UDF- FastB2B- ParErr- DEVSEL=medium >TAbort- <TAbort- <MAbort- >SERR- <PERR-
	Latency: 0

00:01.1 IDE interface: Symphony Labs SL82c105 (rev 05) (prog-if 8f [Master SecP SecO PriP PriO])
	Control: I/O+ Mem- BusMaster- SpecCycle- MemWINV- VGASnoop- ParErr- Stepping- SERR- FastB2B-
	Status: Cap- 66MHz- UDF- FastB2B+ ParErr- DEVSEL=medium >TAbort- <TAbort- <MAbort- >SERR- <PERR-
	Interrupt: pin A routed to IRQ 0
	Region 0: I/O ports at 800001f0 [size=8]
	Region 1: I/O ports at 800003f4 [size=4]
	Region 2: I/O ports at 80000170 [size=8]
	Region 3: I/O ports at 80000374 [size=4]
	Region 4: I/O ports at 80000000 [size=16]
	Region 5: I/O ports at 800010b0 [size=16]

00:02.0 SCSI storage controller: LSI Logic / Symbios Logic 53c825 (rev 13)
	Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV+ VGASnoop- ParErr- Stepping- SERR- FastB2B-
	Status: Cap- 66MHz- UDF- FastB2B- ParErr- DEVSEL=medium >TAbort- <TAbort- <MAbort- >SERR- <PERR-
	Latency: 0 (4250ns min, 16000ns max), Cache Line Size: 32 bytes
	Interrupt: pin A routed to IRQ 15
	Region 0: I/O ports at 80001400 [size=256]
	Region 1: Memory at c4008000 (32-bit, non-prefetchable) [size=256]
	Region 2: Memory at c4009000 (32-bit, non-prefetchable) [size=4K]

00:04.0 Ethernet controller: Digital Equipment Corporation DECchip 21140 [FasterNet] (rev 22)
	Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV+ VGASnoop- ParErr- Stepping- SERR- FastB2B-
	Status: Cap- 66MHz- UDF- FastB2B+ ParErr- DEVSEL=medium >TAbort- <TAbort- <MAbort- >SERR- <PERR-
	Latency: 0 (5000ns min, 10000ns max), Cache Line Size: 32 bytes
	Interrupt: pin A routed to IRQ 11
	Region 0: I/O ports at 80001800 [size=128]
	Region 1: Memory at c400a000 (32-bit, non-prefetchable) [size=128]
	Expansion ROM at c1040000 [disabled] [size=256K]

00:06.0 Ethernet controller: Digital Equipment Corporation DECchip 21140 [FasterNet] (rev 22)
	Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV+ VGASnoop- ParErr- Stepping- SERR- FastB2B-
	Status: Cap- 66MHz- UDF- FastB2B+ ParErr- DEVSEL=medium >TAbort- <TAbort- <MAbort- >SERR- <PERR-
	Latency: 0 (5000ns min, 10000ns max), Cache Line Size: 32 bytes
	Interrupt: pin A routed to IRQ 10
	Region 0: I/O ports at 80001000 [size=128]
	Region 1: Memory at c2000000 (32-bit, non-prefetchable) [size=128]
	Expansion ROM at c1040000 [disabled] [size=256K]

00:07.0 Mass storage controller: Silicon Image, Inc. SiI 3112 [SATALink/SATARaid] Serial ATA Controller (rev 02)
	Subsystem: Silicon Image, Inc. SiI 3112 SATALink Controller
	Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- Stepping- SERR- FastB2B-
	Status: Cap+ 66MHz+ UDF- FastB2B+ ParErr- DEVSEL=medium >TAbort- <TAbort- <MAbort- >SERR- <PERR-
	Latency: 0
	Interrupt: pin A routed to IRQ 11
	Region 0: I/O ports at 80001080 [size=8]
	Region 1: I/O ports at 80001088 [size=4]
	Region 2: I/O ports at 80001090 [size=8]
	Region 3: I/O ports at 80001098 [size=4]
	Region 4: I/O ports at 800010a0 [size=16]
	Region 5: Memory at c2000200 (32-bit, non-prefetchable) [size=512]
	Expansion ROM at c1080000 [disabled] [size=512K]
	Capabilities: <access denied>

00:08.0 VGA compatible controller: Cirrus Logic GD 5446 (rev 45) (prog-if 00 [VGA])
	Control: I/O+ Mem+ BusMaster- SpecCycle- MemWINV- VGASnoop- ParErr- Stepping- SERR- FastB2B-
	Status: Cap- 66MHz- UDF- FastB2B- ParErr- DEVSEL=medium >TAbort- <TAbort- <MAbort- >SERR- <PERR-
	Interrupt: pin ? routed to IRQ 15
	Region 0: Memory at c0000000 (32-bit, prefetchable) [size=32M]
	Region 1: Memory at c2001000 (32-bit, non-prefetchable) [size=4K]
	Expansion ROM at c4000000 [disabled] [size=32K]


Total memory = 256MB; using 512kB for hash table (at c0380000)
Linux version 2.6.19-rc6 (mroos@muuseum) (gcc version 4.1.2 20061115 (prerelease) (Debian 4.1.1-20)) #62 Thu Nov 23 13:33:33 EET 2006
PReP architecture
Entering add_active_range(0, 0, 65536) 0 entries of 256 used
Zone PFN ranges:
  DMA             0 ->    65536
  Normal      65536 ->    65536
early_node_map[1] active PFN ranges
    0:        0 ->    65536
On node 0 totalpages: 65536
  DMA zone: 512 pages used for memmap
  DMA zone: 0 pages reserved
  DMA zone: 65024 pages, LIFO batch:15
  Normal zone: 0 pages used for memmap
Built 1 zonelists.  Total pages: 65024
Kernel command line: console=ttyS0,9600 console=tty0 root=/dev/sda3 tere tere tere
PID hash table entries: 1024 (order: 10, 4096 bytes)
time_init: decrementer frequency = 16.649364 MHz
Console: colour VGA+ 80x25
Dentry cache hash table entries: 32768 (order: 5, 131072 bytes)
Inode-cache hash table entries: 16384 (order: 4, 65536 bytes)
Memory: 256128k available (2212k kernel code, 804k data, 140k init, 0k highmem)
Calibrating delay loop... 299.00 BogoMIPS (lpj=1495040)
Mount-cache hash table entries: 512
NET: Registered protocol family 16
PCI: Probing PCI hardware
Setting PCI interrupts for a "Utah (Powerstack II Pro4000)"
PCI: Cannot allocate resource region 5 of device 0000:00:01.1
PCI: Cannot allocate resource region 1 of device 0000:00:06.0
PCI: Cannot allocate resource region 5 of device 0000:00:07.0
Linux Plug and Play Support v0.97 (c) Adam Belay
SCSI subsystem initialized
NET: Registered protocol family 2
IP route cache hash table entries: 2048 (order: 1, 8192 bytes)
TCP established hash table entries: 8192 (order: 5, 131072 bytes)
TCP bind hash table entries: 4096 (order: 4, 81920 bytes)
TCP: Hash tables configured (established 8192 bind 4096)
TCP reno registered
io scheduler noop registered
io scheduler anticipatory registered
io scheduler deadline registered
io scheduler cfq registered (default)
isapnp: Scanning for PnP cards...
isapnp: No Plug & Play device found
Generic RTC Driver v1.07
Serial: 8250/16550 driver $Revision: 1.90 $ 4 ports, IRQ sharing disabled
serial8250: ttyS0 at I/O 0x3f8 (irq = 4) is a 16550A
serial8250: ttyS1 at I/O 0x2f8 (irq = 3) is a 16550A
Linux Tulip driver version 1.1.14-NAPI (May 11, 2002)
PCI: Enabling device 0000:00:04.0 (0000 -> 0003)
tulip0:  EEPROM default media type Autosense.
tulip0:  Index #0 - Media AUI (#2) described by a 21140 non-MII (0) block.
tulip0:  Index #1 - Media MII (#11) described by a 21140 MII PHY (1) block.
tulip0:  MII transceiver #8 config 3100 status 786b advertising 01e1.
eth0: Digital DS21140 Tulip rev 34 at MMIO 0xc400a000, 08:00:3E:28:C4:A2, IRQ 11.
PCI: Enabling device 0000:00:06.0 (0000 -> 0003)
tulip1:  EEPROM default media type Autosense.
tulip1:  Index #0 - Media 10baseT (#0) described by a 21140 non-MII (0) block.
tulip1:  Index #1 - Media 100baseTx (#3) described by a 21140 non-MII (0) block.
tulip1:  Index #2 - Media 10baseT-FDX (#4) described by a 21140 non-MII (0) block.
tulip1:  Index #3 - Media 100baseTx-FDX (#5) described by a 21140 non-MII (0) block.
tulip1: ***WARNING***: No MII transceiver found!
eth1: Digital DS21140 Tulip rev 34 at MMIO 0xc2000000, 00:00:94:7A:31:8C, IRQ 10.
PCI: Enabling device 0000:00:02.0 (0000 -> 0003)
sym0: <825a> rev 0x13 at pci 0000:00:02.0 irq 15
sym0: No NVRAM, ID 7, Fast-10, SE, parity checking
sym0: SCSI BUS has been reset.
scsi0 : sym-2.2.3
scsi 0:0:0:0: Direct-Access     QUANTUM  ATLAS10K3_36_WLS 020W PQ: 0 ANSI: 3
 target0:0:0: tagged command queuing enabled, command queue depth 16.
 target0:0:0: Beginning Domain Validation
 target0:0:0: asynchronous
 target0:0:0: wide asynchronous
 target0:0:0: FAST-10 WIDE SCSI 20.0 MB/s ST (100 ns, offset 8)
 target0:0:0: Domain Validation skipping write tests
 target0:0:0: Ending Domain Validation
SCSI device sda: 71833096 512-byte hdwr sectors (36779 MB)
sda: Write Protect is off
sda: Mode Sense: e5 00 10 08
SCSI device sda: drive cache: write back w/ FUA
SCSI device sda: 71833096 512-byte hdwr sectors (36779 MB)
sda: Write Protect is off
sda: Mode Sense: e5 00 10 08
SCSI device sda: drive cache: write back w/ FUA
 sda: sda1 sda2 sda3
sd 0:0:0:0: Attached scsi disk sda
serio: i8042 KBD port at 0x60,0x64 irq 1
serio: i8042 AUX port at 0x60,0x64 irq 12
mice: PS/2 mouse device common for all mice
TCP cubic registered
NET: Registered protocol family 1
NET: Registered protocol family 17
kjournald starting.  Commit interval 5 seconds
EXT3-fs: mounted filesystem with ordered data mode.
VFS: Mounted root (ext3 filesystem) readonly.
Freeing unused kernel memory: 140k init
input: AT Translated Set 2 keyboard as /class/input/input0
atkbd.c: keyboard reset failed on isa0060/serio1
libata version 2.00 loaded.
PCI: Enabling device 0000:00:01.1 (0000 -> 0001)
pata_sl82c105 0000:00:01.1: is not available: No interrupt assigned.
sata_sil 0000:00:07.0: version 2.0
PCI: Enabling device 0000:00:07.0 (0000 -> 0003)
sata_sil 0000:00:07.0: cache line size not set.  Driver may not function
ata1: SATA max UDMA/100 cmd 0xF2000280 ctl 0xF200028A bmdma 0xF2000200 irq 11
ata2: SATA max UDMA/100 cmd 0xF20002C0 ctl 0xF20002CA bmdma 0xF2000208 irq 11
scsi1 : sata_sil
ata1: SATA link down (SStatus 0 SControl 310)
scsi2 : sata_sil
ata2: SATA link up 1.5 Gbps (SStatus 113 SControl 310)
ata2.00: ATA-7, max UDMA/133, 625134827 sectors: LBA48 NCQ (depth 0/32)
ata2.00: configured for UDMA/100
scsi 2:0:0:0: Direct-Access     ATA      ST3320620AS      3.AA PQ: 0 ANSI: 5
SCSI device sdb: 625134827 512-byte hdwr sectors (320069 MB)
sdb: Write Protect is off
sdb: Mode Sense: 00 3a 00 00
SCSI device sdb: drive cache: write back
SCSI device sdb: 625134827 512-byte hdwr sectors (320069 MB)
sdb: Write Protect is off
sdb: Mode Sense: 00 3a 00 00
SCSI device sdb: drive cache: write back
 sdb: sdb1
sd 2:0:0:0: Attached scsi disk sdb
Adding 498004k swap on /dev/sda2.  Priority:-1 extents:1 across:498004k
EXT3 FS on sda3, internal journal
NET: Registered protocol family 10
lo: Disabled Privacy Extensions
Mobile IPv6
device-mapper: ioctl: 4.10.0-ioctl (2006-09-14) initialised: dm-devel@redhat.com
kjournald starting.  Commit interval 5 seconds
EXT3 FS on sdb1, internal journal
EXT3-fs: mounted filesystem with ordered data mode.
ip_tables: (C) 2000-2006 Netfilter Core Team
Netfilter messages via NETLINK v0.30.
ip_conntrack version 2.4 (2048 buckets, 16384 max) - 232 bytes per conntrack
eth0: Setting full-duplex based on MII#8 link partner capability of c1e1.
0000:00:06.0: tulip_stop_rxtx() failed
NET: Registered protocol family 5

-- 
Meelis Roos (mroos@linux.ee)
