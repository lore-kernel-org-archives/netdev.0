From: Luca Bortot <l.bortot@inet.it>
Subject: Re: jumbo on 8169
Date: Tue, 28 Dec 2004 11:13:24 +0100
Message-ID: <41D131C4.9010201@inet.it>
References: <41CFF27A.2070008@inet.it> <20041227123136.GA25187@electric-eye.fr.zoreil.com> <41D01562.4090606@inet.it> <20041227163802.GA27692@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Francois Romieu <romieu@fr.zoreil.com>
In-Reply-To: <20041227163802.GA27692@electric-eye.fr.zoreil.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Francois Romieu wrote:
> TSO may make a difference for a TCP test. See ethtool help to enable it.
> You can experiment with Tx csum/SG as well.

I tried and benchmarked them, but I could not see any difference in both 
throughput and cpu usage.

btw, I think I'll switch back to 1500...
I'm using the linux box as my own router/firewall/file server, and the 
latter  is why I went giga.
But... samba isn't (yet) i/o asynchronous, so that over 10-12 MB/s I 
basically wait for both disk and network latency, not the devices 
themselves.
With 7k frames I end up with 50% disk usage, 20% network usage, 20% cpu 
idle; with 1500 I get the same on disk and network, but 100%cpu usage.
Since I don't mind having spare cpu during file transfers, I prefer a 
1500 mtu setup for better compatibility (did you know that MS ip stack 
sets the "don't fragment" bit by default? Can you guess what happens 
when the 7k packets go to the internet?)


> I'll welcome a complete dmesg and lspci -vx as they pretty well describe
> the working combinations.

Linux version 2.6.10 (root@farm) (gcc version 3.4.2 20041017 (Red Hat 
3.4.2-6.fc3)) #7 Mon Dec 27 14:13:23 CET 2004
BIOS-provided physical RAM map:
  BIOS-e820: 0000000000000000 - 00000000000a0000 (usable)
  BIOS-e820: 00000000000f0000 - 0000000000100000 (reserved)
  BIOS-e820: 0000000000100000 - 0000000017ff0000 (usable)
  BIOS-e820: 0000000017ff0000 - 0000000017ff3000 (ACPI NVS)
  BIOS-e820: 0000000017ff3000 - 0000000018000000 (ACPI data)
  BIOS-e820: 00000000ffff0000 - 0000000100000000 (reserved)
383MB LOWMEM available.
On node 0 totalpages: 98288
   DMA zone: 4096 pages, LIFO batch:1
   Normal zone: 94192 pages, LIFO batch:16
   HighMem zone: 0 pages, LIFO batch:1
DMI 2.3 present.
ACPI: RSDP (v000 QDIGRP                                ) @ 0x000f7430
ACPI: RSDT (v001 AWARD  AWRDACPI 0x42302e31 AWRD 0x00000000) @ 0x17ff3000
ACPI: FADT (v001 AWARD  AWRDACPI 0x42302e31 AWRD 0x00000000) @ 0x17ff3040
ACPI: DSDT (v001 QDIGRP AWRDACPI 0x00001000 MSFT 0x0100000a) @ 0x00000000
Built 1 zonelists
Kernel command line: ro root=LABEL=/ rhgb quiet acpi=force console=tty0 
console=ttyS0,9600n8
Initializing CPU#0
PID hash table entries: 2048 (order: 11, 32768 bytes)
Detected 800.068 MHz processor.
Using tsc for high-res timesource
Console: colour VGA+ 80x25
Dentry cache hash table entries: 65536 (order: 6, 262144 bytes)
Inode-cache hash table entries: 32768 (order: 5, 131072 bytes)
Memory: 385368k/393152k available (2114k kernel code, 7144k reserved, 
614k data, 188k init, 0k highmem)
Checking if this processor honours the WP bit even in supervisor mode... Ok.
Calibrating delay loop... 1576.96 BogoMIPS (lpj=788480)
Security Framework v1.0.0 initialized
SELinux:  Initializing.
SELinux:  Starting in permissive mode
selinux_register_security:  Registering secondary module capability
Capability LSM initialized as secondary
Mount-cache hash table entries: 512 (order: 0, 4096 bytes)
CPU: After generic identify, caps: 0383f9ff 00000000 00000000 00000000
CPU: After vendor identify, caps:  0383f9ff 00000000 00000000 00000000
CPU: L1 I cache: 16K, L1 D cache: 16K
CPU: L2 cache: 256K
CPU: After all inits, caps:        0383f9ff 00000000 00000000 00000040
Intel machine check architecture supported.
Intel machine check reporting enabled on CPU#0.
CPU: Intel Pentium III (Coppermine) stepping 06
Enabling fast FPU save and restore... done.
Enabling unmasked SIMD FPU exception support... done.
Checking 'hlt' instruction... OK.
ACPI: setting ELCR to 0200 (from 1e20)
checking if image is initramfs... it is
Freeing initrd memory: 411k freed
NET: Registered protocol family 16
PCI: PCI BIOS revision 2.10 entry at 0xfb230, last bus=1
PCI: Using configuration type 1
mtrr: v2.0 (20020519)
ACPI: Subsystem revision 20041105
ACPI: Interpreter enabled
ACPI: Using PIC for interrupt routing
ACPI: PCI Root Bridge [PCI0] (00:00)
PCI: Probing PCI hardware (bus 00)
ACPI: PCI Interrupt Routing Table [\_SB_.PCI0._PRT]
ACPI: PCI Interrupt Link [LNKA] (IRQs 1 3 4 5 6 7 10 *11 12 14 15)
ACPI: PCI Interrupt Link [LNKB] (IRQs 1 3 4 5 6 7 10 11 *12 14 15)
ACPI: PCI Interrupt Link [LNKC] (IRQs 1 3 4 *5 6 7 10 11 12 14 15)
ACPI: PCI Interrupt Link [LNKD] (IRQs 1 3 4 5 6 7 *10 11 12 14 15)
Linux Plug and Play Support v0.97 (c) Adam Belay
pnp: PnP ACPI init
pnp: PnP ACPI: found 11 devices
usbcore: registered new driver usbfs
usbcore: registered new driver hub
PCI: Using ACPI for IRQ routing
** PCI interrupts are no longer routed automatically.  If this
** causes a device to stop working, it is probably because the
** driver failed to call pci_enable_device().  As a temporary
** workaround, the "pci=routeirq" argument restores the old
** behavior.  If this argument makes the device work again,
** please email the output of "lspci" to bjorn.helgaas@hp.com
** so I can fix the driver.
apm: BIOS version 1.2 Flags 0x07 (Driver version 1.16ac)
apm: overridden by ACPI.
audit: initializing netlink socket (disabled)
audit(1104229026.676:0): initialized
Total HugeTLB memory allocated, 0
VFS: Disk quotas dquot_6.5.1
Dquot-cache hash table entries: 1024 (order 0, 4096 bytes)
SELinux:  Registering netfilter hooks
Initializing Cryptographic API
Activating ISA DMA hang workarounds.
vesafb: probe of vesafb0 failed with error -6
ACPI: Processor [CPU0] (supports C1 C2)
ACPI: Processor [CPU0] (supports 2 throttling states)
isapnp: Scanning for PnP cards...
isapnp: No Plug & Play device found
Real Time Clock Driver v1.12
Linux agpgart interface v0.100 (c) Dave Jones
agpgart: Detected VIA Apollo Pro 133 chipset
agpgart: Maximum main memory to use for agp memory: 321M
agpgart: AGP aperture is 4M @ 0xe6000000
serio: i8042 AUX port at 0x60,0x64 irq 12
serio: i8042 KBD port at 0x60,0x64 irq 1
Serial: 8250/16550 driver $Revision: 1.90 $ 8 ports, IRQ sharing enabled
ttyS0 at I/O 0x3f8 (irq = 4) is a 16550A
ttyS1 at I/O 0x2f8 (irq = 3) is a 16550A
ttyS0 at I/O 0x3f8 (irq = 4) is a 16550A
ttyS1 at I/O 0x2f8 (irq = 3) is a 16550A
io scheduler noop registered
io scheduler anticipatory registered
io scheduler deadline registered
io scheduler cfq registered
RAMDISK driver initialized: 16 RAM disks of 16384K size 1024 blocksize
r8169 Gigabit Ethernet driver 1.6LK loaded
ACPI: PCI Interrupt Link [LNKC] enabled at IRQ 5
PCI: setting IRQ 5 as level-triggered
ACPI: PCI interrupt 0000:00:0b.0[A] -> GSI 5 (level, low) -> IRQ 5
r8169: NAPI enabled
eth0: Identified chip type is 'RTL8169s/8110s'.
eth0: RTL8169 at 0xd881c000, 00:40:f4:b4:8b:44, IRQ 5
Uniform Multi-Platform E-IDE driver Revision: 7.00alpha2
ide: Assuming 33MHz system bus speed for PIO modes; override with idebus=xx
VP_IDE: IDE controller at PCI slot 0000:00:07.1
VP_IDE: chipset revision 16
VP_IDE: not 100% native mode: will probe irqs later
VP_IDE: VIA vt82c596b (rev 23) IDE UDMA66 controller on pci0000:00:07.1
     ide0: BM-DMA at 0xd000-0xd007, BIOS settings: hda:DMA, hdb:DMA
     ide1: BM-DMA at 0xd008-0xd00f, BIOS settings: hdc:DMA, hdd:DMA
Probing IDE interface ide0...
hda: HDS722525VLAT80, ATA DISK drive
hdb: ASUS CD-S340, ATAPI CD/DVD-ROM drive
elevator: using anticipatory as default io scheduler
ide0 at 0x1f0-0x1f7,0x3f6 on irq 14
Probing IDE interface ide1...
hdc: ST380021A, ATA DISK drive
hdc: IRQ probe failed (0xbcfa)
hdd: Maxtor 4G120J6, ATA DISK drive
ide1 at 0x170-0x177,0x376 on irq 15
Probing IDE interface ide2...
ide2: Wait for ready failed before probe !
Probing IDE interface ide3...
ide3: Wait for ready failed before probe !
Probing IDE interface ide4...
ide4: Wait for ready failed before probe !
Probing IDE interface ide5...
ide5: Wait for ready failed before probe !
hda: max request size: 1024KiB
hda: 488397168 sectors (250059 MB) w/7938KiB Cache, CHS=30401/255/63, 
UDMA(66)
hda: cache flushes supported
  hda: hda1 hda2 hda3
hdc: max request size: 128KiB
hdc: 156301488 sectors (80026 MB) w/2048KiB Cache, CHS=65535/16/63, UDMA(66)
hdc: cache flushes not supported
  hdc: hdc1
hdd: max request size: 1024KiB
hdd: 240121728 sectors (122942 MB) w/2048KiB Cache, CHS=16383/255/63, 
UDMA(66)
hdd: cache flushes not supported
  hdd: hdd1
hdb: ATAPI 34X CD-ROM drive, 128kB Cache, UDMA(33)
Uniform CD-ROM driver Revision: 3.20
ide-floppy driver 0.99.newide
usbcore: registered new driver hiddev
usbcore: registered new driver usbhid
drivers/usb/input/hid-core.c: v2.0:USB HID core driver
mice: PS/2 mouse device common for all mice
md: md driver 0.90.1 MAX_MD_DEVS=256, MD_SB_DISKS=27
NET: Registered protocol family 2
IP: routing cache hash table of 4096 buckets, 32Kbytes
TCP: Hash tables configured (established 32768 bind 65536)
Initializing IPsec netlink socket
NET: Registered protocol family 1
NET: Registered protocol family 17
ACPI wakeup devices:
USB0 USB1
ACPI: (supports S0 S1 S4bios S5)
Freeing unused kernel memory: 188k freed
device-mapper: 4.3.0-ioctl (2004-09-30) initialised: dm-devel@redhat.com
EXT3-fs: INFO: recovery required on readonly filesystem.
EXT3-fs: write access will be enabled during recovery.
kjournald starting.  Commit interval 5 seconds
EXT3-fs: recovery complete.
EXT3-fs: mounted filesystem with ordered data mode.
SELinux:  Disabled at runtime.
SELinux:  Unregistering netfilter hooks
inserting floppy driver for 2.6.10
FDC 0 is a post-1991 82077
8139too Fast Ethernet driver 0.9.27
ACPI: PCI Interrupt Link [LNKB] enabled at IRQ 12
PCI: setting IRQ 12 as level-triggered
ACPI: PCI interrupt 0000:00:0a.0[A] -> GSI 12 (level, low) -> IRQ 12
eth1: RealTek RTL8139 at 0xd800, 00:40:f4:b1:26:b8, IRQ 12
eth1:  Identified 8139 chip type 'RTL-8100B/8139D'
e100: Intel(R) PRO/100 Network Driver, 3.2.3-k2-NAPI
e100: Copyright(c) 1999-2004 Intel Corporation
ACPI: PCI Interrupt Link [LNKD] enabled at IRQ 10
PCI: setting IRQ 10 as level-triggered
ACPI: PCI interrupt 0000:00:0c.0[A] -> GSI 10 (level, low) -> IRQ 10
e100: eth2: e100_probe: addr 0xe6602000, irq 10, MAC addr 00:A0:C9:1D:EC:2F
ACPI: PCI interrupt 0000:00:0e.0[A] -> GSI 12 (level, low) -> IRQ 12
e100: eth3: e100_probe: addr 0xe6601000, irq 12, MAC addr 00:A0:C9:CD:46:43
ip_tables: (C) 2000-2002 Netfilter core team
eth3: link up, 10Mbps, half-duplex, lpa 0x0000
e100: eth1: e100_watchdog: link up, 100Mbps, full-duplex
ip_tables: (C) 2000-2002 Netfilter core team
USB Universal Host Controller Interface driver v2.2
ACPI: PCI interrupt 0000:00:07.2[D] -> GSI 10 (level, low) -> IRQ 10
uhci_hcd 0000:00:07.2: UHCI Host Controller
uhci_hcd 0000:00:07.2: irq 10, io base 0xd400
uhci_hcd 0000:00:07.2: new USB bus registered, assigned bus number 1
hub 1-0:1.0: USB hub found
hub 1-0:1.0: 2 ports detected
md: Autodetecting RAID arrays.
md: autorun ...
md: ... autorun DONE.
ip_tables: (C) 2000-2002 Netfilter core team
ACPI: Power Button (FF) [PWRF]
ibm_acpi: ec object not found
EXT3 FS on hda1, internal journal
cdrom: open failed.
kjournald starting.  Commit interval 5 seconds
EXT3 FS on dm-0, internal journal
EXT3-fs: mounted filesystem with ordered data mode.
Adding 655192k swap on /dev/hda2.  Priority:-1 extents:1
IA-32 Microcode Update Driver: v1.14 <tigran@veritas.com>
microcode: CPU0 already at revision 0x8 (current=0x8)
microcode: No suitable data for CPU0
parport_pc: Ignoring new-style parameters in presence of obsolete ones
parport: PnPBIOS parport detected.
parport0: PC-style at 0x378, irq 7 [PCSPP,TRISTATE]
pnp: Device 00:09 disabled.
ip_tables: (C) 2000-2002 Netfilter core team
ip_conntrack version 2.1 (3071 buckets, 24568 max) - 304 bytes per conntrack
e100: eth0: e100_watchdog: link up, 10Mbps, half-duplex
r8169: eth2: link up
i2c /dev entries driver
parport_pc: Ignoring new-style parameters in presence of obsolete ones
pnp: Device 00:09 activated.
parport: PnPBIOS parport detected.
parport0: PC-style at 0x378, irq 7 [PCSPP,TRISTATE]
lp0: using parport0 (interrupt-driven).
lp0: console ready
Universal TUN/TAP device driver 1.5 (C)1999-2002 Maxim Krasnyansky





00:00.0 Host bridge: VIA Technologies, Inc. VT82C693A/694x [Apollo 
PRO133x] (rev 44)
	Flags: bus master, medium devsel, latency 0
	Memory at e6000000 (32-bit, prefetchable) [size=4M]
	Capabilities: [a0] AGP version 1.0
00: 06 11 91 06 06 00 10 a2 44 00 00 06 00 00 00 00
10: 08 00 00 e6 00 00 00 00 00 00 00 00 00 00 00 00
20: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
30: 00 00 00 00 a0 00 00 00 00 00 00 00 00 00 00 00

00:01.0 PCI bridge: VIA Technologies, Inc. VT82C598/694x [Apollo 
MVP3/Pro133x AGP] (prog-if 00 [Normal decode])
	Flags: bus master, 66Mhz, medium devsel, latency 0
	Bus: primary=00, secondary=01, subordinate=01, sec-latency=0
	I/O behind bridge: 0000c000-0000cfff
	Memory behind bridge: e0000000-e1ffffff
	Prefetchable memory behind bridge: e2000000-e2ffffff
	Capabilities: [80] Power Management version 2
00: 06 11 98 85 07 00 30 22 00 00 04 06 00 00 01 00
10: 00 00 00 00 00 00 00 00 00 01 01 00 c0 c0 00 00
20: 00 e0 f0 e1 00 e2 f0 e2 00 00 00 00 00 00 00 00
30: 00 00 00 00 80 00 00 00 00 00 00 00 00 00 0c 00

00:07.0 ISA bridge: VIA Technologies, Inc. VT82C596 ISA [Mobile South] 
(rev 23)
	Subsystem: Quantum Designs (H.K.) Inc: Unknown device 0000
	Flags: bus master, stepping, medium devsel, latency 0
00: 06 11 96 05 87 00 00 02 23 00 01 06 00 00 80 00
10: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
20: 00 00 00 00 00 00 00 00 00 00 00 00 11 34 00 00
30: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00

00:07.1 IDE interface: VIA Technologies, Inc. 
VT82C586A/B/VT82C686/A/B/VT823x/A/C PIPC Bus Master IDE (rev 10) 
(prog-if 8a [Master SecP PriP])
	Flags: bus master, medium devsel, latency 64
	I/O ports at d000 [size=16]
	Capabilities: [c0] Power Management version 2
00: 06 11 71 05 07 00 90 02 10 8a 01 01 00 40 00 00
10: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
20: 01 d0 00 00 00 00 00 00 00 00 00 00 00 00 00 00
30: 00 00 00 00 c0 00 00 00 00 00 00 00 ff 00 00 00

00:07.2 USB Controller: VIA Technologies, Inc. VT82xxxxx UHCI USB 1.1 
Controller (rev 11) (prog-if 00 [UHCI])
	Subsystem: VIA Technologies, Inc. (Wrong ID) USB Controller
	Flags: bus master, medium devsel, latency 64, IRQ 10
	I/O ports at d400 [size=32]
	Capabilities: [80] Power Management version 2
00: 06 11 38 30 07 00 10 02 11 00 03 0c 08 40 00 00
10: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
20: 01 d4 00 00 00 00 00 00 00 00 00 00 25 09 34 12
30: 00 00 00 00 80 00 00 00 00 00 00 00 0a 04 00 00

00:07.3 Host bridge: VIA Technologies, Inc. VT82C596 Power Management 
(rev 30)
	Flags: medium devsel
00: 06 11 50 30 00 00 80 02 30 00 00 06 00 00 00 00
10: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
20: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
30: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00

00:0a.0 Ethernet controller: Realtek Semiconductor Co., Ltd. 
RTL-8139/8139C/8139C+ (rev 10)
	Subsystem: Realtek Semiconductor Co., Ltd. RT8139
	Flags: bus master, medium devsel, latency 64, IRQ 12
	I/O ports at d800 [size=256]
	Memory at e6600000 (32-bit, non-prefetchable) [size=256]
	Capabilities: [50] Power Management version 2
00: ec 10 39 81 07 00 90 02 10 00 00 02 00 40 00 00
10: 01 d8 00 00 00 00 60 e6 00 00 00 00 00 00 00 00
20: 00 00 00 00 00 00 00 00 00 00 00 00 ec 10 39 81
30: 00 00 00 00 50 00 00 00 00 00 00 00 0c 01 20 40

00:0b.0 Ethernet controller: Realtek Semiconductor Co., Ltd. RTL-8169 
Gigabit Ethernet (rev 10)
	Subsystem: Realtek Semiconductor Co., Ltd. RTL-8169 Gigabit Ethernet
	Flags: bus master, 66Mhz, medium devsel, latency 64, IRQ 5
	I/O ports at dc00 [size=256]
	Memory at e6603000 (32-bit, non-prefetchable) [size=256]
	Expansion ROM at e3000000 [disabled] [size=128K]
	Capabilities: [dc] Power Management version 2
00: ec 10 69 81 17 00 b0 02 10 00 00 02 08 40 00 00
10: 01 dc 00 00 00 30 60 e6 00 00 00 00 00 00 00 00
20: 00 00 00 00 00 00 00 00 00 00 00 00 ec 10 69 81
30: 00 00 00 e3 dc 00 00 00 00 00 00 00 05 01 20 40

00:0c.0 Ethernet controller: Intel Corp. 82557/8/9 [Ethernet Pro 100] 
(rev 01)
	Flags: bus master, medium devsel, latency 64, IRQ 10
	Memory at e6602000 (32-bit, prefetchable) [size=4K]
	I/O ports at e000 [size=32]
	Memory at e6500000 (32-bit, non-prefetchable) [size=1M]
	Expansion ROM at e4000000 [disabled] [size=1M]
00: 86 80 29 12 07 00 80 02 01 00 00 02 00 40 00 00
10: 08 20 60 e6 01 e0 00 00 00 00 50 e6 00 00 00 00
20: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
30: 00 00 00 e4 00 00 00 00 00 00 00 00 0a 01 08 38

00:0e.0 Ethernet controller: Intel Corp. 82557/8/9 [Ethernet Pro 100] 
(rev 05)
	Subsystem: Intel Corp. EtherExpress PRO/100+
	Flags: bus master, medium devsel, latency 64, IRQ 12
	Memory at e6601000 (32-bit, prefetchable) [size=4K]
	I/O ports at e400 [size=32]
	Memory at e6400000 (32-bit, non-prefetchable) [size=1M]
	Expansion ROM at e5000000 [disabled] [size=1M]
	Capabilities: [dc] Power Management version 1
00: 86 80 29 12 07 00 90 02 05 00 00 02 08 40 00 00
10: 08 10 60 e6 01 e4 00 00 00 00 40 e6 00 00 00 00
20: 00 00 00 00 00 00 00 00 00 00 00 00 86 80 09 00
30: 00 00 00 e5 dc 00 00 00 00 00 00 00 0c 01 08 38

01:00.0 VGA compatible controller: ATI Technologies Inc 3D Rage IIC AGP 
(rev 7a) (prog-if 00 [VGA])
	Subsystem: ATI Technologies Inc Rage 3D Pro AGP 2x XPERT 98
	Flags: bus master, stepping, medium devsel, latency 64, IRQ 11
	Memory at e2000000 (32-bit, prefetchable) [size=16M]
	I/O ports at c000 [size=256]
	Memory at e1000000 (32-bit, non-prefetchable) [size=4K]
	Capabilities: [5c] Power Management version 1
00: 02 10 5a 47 87 00 90 02 7a 00 00 03 08 40 00 00
10: 08 00 00 e2 01 c0 00 00 00 00 00 e1 00 00 00 00
20: 00 00 00 00 00 00 00 00 00 00 00 00 02 10 84 00
30: 00 00 00 00 5c 00 00 00 00 00 00 00 0b 01 08 00
