From: "Dale E. Martin" <dale@the-martins.org>
Subject: Re: where is the proper place for r8169 bug reports?
Date: Tue, 1 Feb 2005 16:56:07 -0500
Message-ID: <20050201215607.GA8530@gerbil.toadis.porkis>
References: <20050131181508.GA15908@gerbil.toadis.porkis> <20050131214951.GA13217@electric-eye.fr.zoreil.com> <20050131215948.GA23289@gerbil.toadis.porkis> <20050131222342.GB13217@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="tThc/1wpZn/ma/RB"
To: netdev@oss.sgi.com
Content-Disposition: inline
In-Reply-To: <20050131222342.GB13217@electric-eye.fr.zoreil.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


--tThc/1wpZn/ma/RB
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

> Typical symptoms: the card works fine until 64 (256) packets are sent
> (received) then "Good bye Charlie".

Yep, that was it.  Recompiled with gcc 3.3 and it seems to be working now,
although it looks like the card is only found on cold boots.

The irony of this, btw, is that linux/Documentation/Changes still
recommends gcc 2.95.3 - even in version 2.6.8, possibly in 2.6.10.  (I
think I saw it in there but I don't have it handy.)

Also, when I first started looking at this, I tried to #define
RTL8169_DEBUG but was getting compile errors.  Should I file a bug about
this?

> If it works, I'll gladly welcome an 'lspci -vx' + complete dmesg for my
> collection.

Attached.  The box says "Zonet Gigabit Ethernet 32 bit Adapter" and "Model
ZEN3300E".

The Linksys card in the lspci output is not connected to anything and I did
not load the tulip module that supports it.  (I was trying to ease
switching back to it since the gigE card kept locking up!)

It looks like the poor 1Ghz C3 in this machine is going to be the
bottleneck for getting good transfer rates over gigabit ethernet ;-)
 
> Btw, you can test the patch below (on top of 2.4.28, no bad report so far):
> http://www.fr.zoreil.com/~romieu/misc/20041209-2.4.28-r8169.c-test.patch

What is the intention of this patch?  Is it to handle the 2.95.x issue or
something else?

Thanks for the help!
	Dale
-- 
Dale E. Martin - dale@the-martins.org
http://the-martins.org/~dmartin

--tThc/1wpZn/ma/RB
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename="stuff.txt"

00:00.0 Host bridge: VIA Technologies, Inc.: Unknown device 3123
	Subsystem: VIA Technologies, Inc.: Unknown device cc01
	Flags: bus master, 66Mhz, medium devsel, latency 8
	Memory at e0000000 (32-bit, prefetchable) [size=64M]
	Capabilities: <available only to root>
00: 06 11 23 31 06 00 30 a2 00 00 00 06 00 08 00 00
10: 08 00 00 e0 00 00 00 00 00 00 00 00 00 00 00 00
20: 00 00 00 00 00 00 00 00 00 00 00 00 06 11 01 cc
30: 00 00 00 00 a0 00 00 00 00 00 00 00 00 00 00 00

00:01.0 PCI bridge: VIA Technologies, Inc. VT8633 [Apollo Pro266 AGP] (prog-if 00 [Normal decode])
	Flags: bus master, 66Mhz, medium devsel, latency 0
	Bus: primary=00, secondary=01, subordinate=01, sec-latency=0
	Memory behind bridge: e8000000-e9ffffff
	Prefetchable memory behind bridge: e4000000-e7ffffff
	Capabilities: <available only to root>
00: 06 11 91 b0 07 01 30 a2 00 00 04 06 00 00 01 00
10: 00 00 00 00 00 00 00 00 00 01 01 00 f0 00 00 00
20: 00 e8 f0 e9 00 e4 f0 e7 00 00 00 00 00 00 00 00
30: 00 00 00 00 80 00 00 00 00 00 00 00 00 00 0c 00

00:08.0 SCSI storage controller: BusLogic Flashpoint LT (rev 01)
	Flags: bus master, fast devsel, latency 32, IRQ 11
	I/O ports at d000 [size=256]
	Memory at eb000000 (32-bit, non-prefetchable) [size=4K]
	Expansion ROM at <unassigned> [disabled] [size=32K]
00: 4b 10 30 81 07 00 00 00 01 00 00 01 08 20 00 00
10: 01 d0 00 00 00 00 00 eb 00 00 00 00 00 00 00 00
20: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
30: 00 00 00 00 00 00 00 00 00 00 00 00 0b 01 08 08

00:09.0 Ethernet controller: Linksys Network Everywhere Fast Ethernet 10/100 model NC100 (rev 11)
	Subsystem: Linksys: Unknown device 0574
	Flags: bus master, medium devsel, latency 32, IRQ 7
	I/O ports at d400 [size=256]
	Memory at eb001000 (32-bit, non-prefetchable) [size=1K]
	Expansion ROM at <unassigned> [disabled] [size=128K]
	Capabilities: <available only to root>
00: 17 13 85 09 07 00 90 02 11 00 00 02 08 20 00 00
10: 01 d4 00 00 00 10 00 eb 00 00 00 00 00 00 00 00
20: 00 00 00 00 00 00 00 00 02 02 00 00 17 13 74 05
30: 00 00 00 00 c0 00 00 00 00 00 00 00 07 01 ff ff

00:0a.0 Ethernet controller: Realtek Semiconductor Co., Ltd.: Unknown device 8169 (rev 10)
	Subsystem: Realtek Semiconductor Co., Ltd.: Unknown device 8169
	Flags: bus master, 66Mhz, medium devsel, latency 64, IRQ 5
	I/O ports at d800 [size=256]
	Memory at eb002000 (32-bit, non-prefetchable) [size=256]
	Expansion ROM at <unassigned> [disabled] [size=128K]
	Capabilities: <available only to root>
00: ec 10 69 81 07 00 b0 02 10 00 00 02 08 40 00 00
10: 01 d8 00 00 00 20 00 eb 00 00 00 00 00 00 00 00
20: 00 00 00 00 00 00 00 00 00 00 00 00 ec 10 69 81
30: 00 00 00 00 dc 00 00 00 00 00 00 00 05 01 20 40

00:10.0 USB Controller: VIA Technologies, Inc. UHCI USB (rev 80) (prog-if 00 [UHCI])
	Subsystem: VIA Technologies, Inc. UHCI USB
	Flags: bus master, medium devsel, latency 32, IRQ 11
	I/O ports at dc00 [size=32]
	Capabilities: <available only to root>
00: 06 11 38 30 07 00 10 02 80 00 03 0c 08 20 80 00
10: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
20: 01 dc 00 00 00 00 00 00 00 00 00 00 06 11 38 30
30: 00 00 00 00 80 00 00 00 00 00 00 00 0b 01 00 00

00:10.1 USB Controller: VIA Technologies, Inc. UHCI USB (rev 80) (prog-if 00 [UHCI])
	Subsystem: VIA Technologies, Inc. UHCI USB
	Flags: bus master, medium devsel, latency 32, IRQ 7
	I/O ports at e000 [size=32]
	Capabilities: <available only to root>
00: 06 11 38 30 07 00 10 02 80 00 03 0c 08 20 80 00
10: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
20: 01 e0 00 00 00 00 00 00 00 00 00 00 06 11 38 30
30: 00 00 00 00 80 00 00 00 00 00 00 00 07 02 00 00

00:10.2 USB Controller: VIA Technologies, Inc. UHCI USB (rev 80) (prog-if 00 [UHCI])
	Subsystem: VIA Technologies, Inc. UHCI USB
	Flags: bus master, medium devsel, latency 32, IRQ 5
	I/O ports at e400 [size=32]
	Capabilities: <available only to root>
00: 06 11 38 30 07 00 10 02 80 00 03 0c 08 20 80 00
10: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
20: 01 e4 00 00 00 00 00 00 00 00 00 00 06 11 38 30
30: 00 00 00 00 80 00 00 00 00 00 00 00 05 03 00 00

00:10.3 USB Controller: VIA Technologies, Inc.: Unknown device 3104 (rev 82) (prog-if 20)
	Subsystem: VIA Technologies, Inc.: Unknown device 3104
	Flags: bus master, medium devsel, latency 32, IRQ 3
	Memory at eb003000 (32-bit, non-prefetchable) [size=256]
	Capabilities: <available only to root>
00: 06 11 04 31 17 00 10 02 82 20 03 0c 08 20 00 00
10: 00 30 00 eb 00 00 00 00 00 00 00 00 00 00 00 00
20: 00 00 00 00 00 00 00 00 00 00 00 00 06 11 04 31
30: 00 00 00 00 80 00 00 00 00 00 00 00 03 04 00 00

00:11.0 ISA bridge: VIA Technologies, Inc.: Unknown device 3177
	Subsystem: VIA Technologies, Inc.: Unknown device cc01
	Flags: bus master, stepping, medium devsel, latency 0
	Capabilities: <available only to root>
00: 06 11 77 31 87 00 10 02 00 00 01 06 00 00 80 00
10: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
20: 00 00 00 00 00 00 00 00 00 00 00 00 06 11 01 cc
30: 00 00 00 00 c0 00 00 00 00 00 00 00 00 00 00 00

00:11.1 IDE interface: VIA Technologies, Inc. Bus Master IDE (rev 06) (prog-if 8a [Master SecP PriP])
	Subsystem: VIA Technologies, Inc.: Unknown device cc01
	Flags: bus master, medium devsel, latency 32, IRQ 11
	I/O ports at e800 [size=16]
	Capabilities: <available only to root>
00: 06 11 71 05 07 00 90 02 06 8a 01 01 00 20 00 00
10: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
20: 01 e8 00 00 00 00 00 00 00 00 00 00 06 11 01 cc
30: 00 00 00 00 c0 00 00 00 00 00 00 00 ff 01 00 00

00:12.0 Ethernet controller: VIA Technologies, Inc. Ethernet Controller (rev 74)
	Subsystem: VIA Technologies, Inc.: Unknown device 0102
	Flags: bus master, medium devsel, latency 32, IRQ 11
	I/O ports at ec00 [size=256]
	Memory at eb004000 (32-bit, non-prefetchable) [size=256]
	Capabilities: <available only to root>
00: 06 11 65 30 07 00 10 02 74 00 00 02 08 20 00 00
10: 01 ec 00 00 00 40 00 eb 00 00 00 00 00 00 00 00
20: 00 00 00 00 00 00 00 00 00 00 00 00 06 11 02 01
30: 00 00 00 00 40 00 00 00 00 00 00 00 0b 01 03 08

01:00.0 VGA compatible controller: VIA Technologies, Inc.: Unknown device 3122 (rev 03) (prog-if 00 [VGA])
	Subsystem: VIA Technologies, Inc.: Unknown device 3122
	Flags: bus master, medium devsel, latency 32, IRQ 11
	Memory at e4000000 (32-bit, prefetchable) [size=64M]
	Memory at e8000000 (32-bit, non-prefetchable) [size=16M]
	Expansion ROM at <unassigned> [disabled] [size=64K]
	Capabilities: <available only to root>
00: 06 11 22 31 07 00 10 02 03 00 00 03 00 20 00 00
10: 08 00 00 e4 00 00 00 e8 00 00 00 00 00 00 00 00
20: 00 00 00 00 00 00 00 00 00 00 00 00 06 11 22 31
30: 00 00 00 00 60 00 00 00 00 00 00 00 ff 01 02 00

Linux version 2.4.28 (root@chinchilla) (gcc version 3.3 (Debian)) #3 Tue Feb 1 16:24:24 EST 2005
BIOS-provided physical RAM map:
 BIOS-e820: 0000000000000000 - 000000000009fc00 (usable)
 BIOS-e820: 000000000009fc00 - 00000000000a0000 (reserved)
 BIOS-e820: 00000000000f0000 - 0000000000100000 (reserved)
 BIOS-e820: 0000000000100000 - 000000000eff0000 (usable)
 BIOS-e820: 000000000eff0000 - 000000000eff3000 (ACPI NVS)
 BIOS-e820: 000000000eff3000 - 000000000f000000 (ACPI data)
 BIOS-e820: 00000000ffff0000 - 0000000100000000 (reserved)
239MB LOWMEM available.
On node 0 totalpages: 61424
zone(0): 4096 pages.
zone(1): 57328 pages.
zone(2): 0 pages.
ACPI: RSDP (v000 VT9174                                    ) @ 0x000f6500
ACPI: RSDT (v001 VT9174 AWRDACPI 0x42302e31 AWRD 0x00000000) @ 0x0eff3000
ACPI: FADT (v001 VT9174 AWRDACPI 0x42302e31 AWRD 0x00000000) @ 0x0eff3040
ACPI: DSDT (v001 VT9174 AWRDACPI 0x00001000 MSFT 0x0100000c) @ 0x00000000
Kernel command line: root=/dev/hdb3 ro vga=792 rootflags=data=journal
No local APIC present or hardware disabled
Initializing CPU#0
Detected 998.323 MHz processor.
Console: colour VGA+ 80x25
Calibrating delay loop... 1992.29 BogoMIPS
Memory: 239484k/245696k available (1840k kernel code, 5824k reserved, 682k data, 140k init, 0k highmem)
Checking if this processor honours the WP bit even in supervisor mode... Ok.
Dentry cache hash table entries: 32768 (order: 6, 262144 bytes)
Inode cache hash table entries: 16384 (order: 5, 131072 bytes)
Mount cache hash table entries: 512 (order: 0, 4096 bytes)
Buffer cache hash table entries: 16384 (order: 4, 65536 bytes)
Page-cache hash table entries: 65536 (order: 6, 262144 bytes)
CPU: L1 I Cache: 64K (32 bytes/line), D cache 64K (32 bytes/line)
CPU: L2 Cache: 64K (32 bytes/line)
CPU:     After generic, caps: 00803135 80803035 00000000 00000000
CPU:             Common caps: 00803135 80803035 00000000 00000000
CPU: Centaur VIA C3 Ezra stepping 09
Checking 'hlt' instruction... OK.
ACPI: IRQ9 SCI: Level Trigger.
POSIX conformance testing by UNIFIX
mtrr: v1.40 (20010327) Richard Gooch (rgooch@atnf.csiro.au)
mtrr: detected mtrr type: Intel
ACPI: Subsystem revision 20040326
PCI: PCI BIOS revision 2.10 entry at 0xfb0c0, last bus=1
PCI: Using configuration type 1
ACPI: Interpreter enabled
ACPI: Using PIC for interrupt routing
ACPI: System [ACPI] (supports S0 S1 S4 S5)
ACPI: PCI Root Bridge [PCI0] (00:00)
PCI: Probing PCI hardware (bus 00)
ACPI: PCI Interrupt Routing Table [\_SB_.PCI0._PRT]
ACPI: PCI Interrupt Link [LNKA] (IRQs 1 3 4 5 6 7 10 *11 12 14 15)
ACPI: PCI Interrupt Link [LNKB] (IRQs 1 3 4 5 6 *7 10 11 12 14 15)
ACPI: PCI Interrupt Link [LNKC] (IRQs 1 3 4 *5 6 7 10 11 12 14 15)
ACPI: PCI Interrupt Link [LNKD] (IRQs 1 *3 4 5 6 7 10 11 12 14 15)
PCI: Probing PCI hardware
ACPI: PCI Interrupt Link [LNKA] enabled at IRQ 11
ACPI: PCI Interrupt Link [LNKB] enabled at IRQ 7
ACPI: PCI Interrupt Link [LNKC] enabled at IRQ 5
ACPI: PCI Interrupt Link [LNKD] enabled at IRQ 3
PCI: Using ACPI for IRQ routing
Linux NET4.0 for Linux 2.4
Based upon Swansea University Computer Society NET3.039
Initializing RT netlink socket
Starting kswapd
Journalled Block Device driver loaded
Installing knfsd (copyright (C) 1996 okir@monad.swb.de).
ACPI: Power Button (FF) [PWRF]
pty: 256 Unix98 ptys configured
Serial driver version 5.05c (2001-07-08) with MANY_PORTS SHARE_IRQ SERIAL_PCI enabled
kmod: failed to exec /sbin/modprobe -s -k parport_lowlevel, errno = 2
lp: driver loaded but no devices found
Real Time Clock Driver v1.10f
Non-volatile memory driver v1.2
ipmi: message handler initialized
FDC 0 is a post-1991 82077
loop: loaded (max 8 devices)
Linux agpgart interface v0.99 (c) Jeff Hartmann
agpgart: Maximum main memory to use for agp memory: 189M
agpgart: Detected Via CLE266 chipset
agpgart: AGP aperture is 64M @ 0xe0000000
Uniform Multi-Platform E-IDE driver Revision: 7.00beta4-2.4
ide: Assuming 33MHz system bus speed for PIO modes; override with idebus=xx
VP_IDE: IDE controller at PCI slot 00:11.1
VP_IDE: chipset revision 6
VP_IDE: not 100% native mode: will probe irqs later
ide: Assuming 33MHz system bus speed for PIO modes; override with idebus=xx
VP_IDE: VIA vt8235 (rev 00) IDE UDMA133 controller on pci00:11.1
    ide0: BM-DMA at 0xe800-0xe807, BIOS settings: hda:DMA, hdb:DMA
    ide1: BM-DMA at 0xe808-0xe80f, BIOS settings: hdc:pio, hdd:pio
hda: WDC WD100BA, ATA DISK drive
hdb: ST3200822A, ATA DISK drive
ide0 at 0x1f0-0x1f7,0x3f6 on irq 14
hda: attached ide-disk driver.
hda: host protected area => 1
hda: 19541088 sectors (10005 MB) w/2048KiB Cache, CHS=1216/255/63
hdb: attached ide-disk driver.
hdb: host protected area => 1
hdb: 390721968 sectors (200050 MB) w/8192KiB Cache, CHS=24321/255/63
Partition check:
 hda: hda1 hda2
 hdb: hdb1 hdb2 hdb3
SCSI subsystem driver Revision: 1.00
scsi: ***** BusLogic SCSI Driver Version 2.1.15 of 17 August 1998 *****
scsi: Copyright 1995-1998 by Leonard N. Zubkoff <lnz@dandelion.com>
scsi0: Configuring BusLogic Model BT-950 PCI Wide Ultra SCSI Host Adapter
scsi0:   Firmware Version: 5.02, I/O Address: 0xD000, IRQ Channel: 11/Level
scsi0:   PCI Bus: 0, Device: 8, Address: 0xEB000000, Host Adapter SCSI ID: 7
scsi0:   Parity Checking: Enabled, Extended Translation: Enabled
scsi0:   Synchronous Negotiation: Fast, Wide Negotiation: Enabled
scsi0:   Disconnect/Reconnect: Enabled, Tagged Queuing: Enabled
scsi0:   Driver Queue Depth: 255, Scatter/Gather Limit: 128 segments
scsi0:   Tagged Queue Depth: Automatic, Untagged Queue Depth: 3
scsi0:   Error Recovery Strategy: Default, SCSI Bus Reset: Enabled
scsi0:   SCSI Bus Termination: Both Enabled, SCAM: Disabled
scsi0: *** BusLogic BT-950 Initialized Successfully ***
scsi0 : BusLogic BT-950
  Vendor: SONY      Model: SDX-300C          Rev: 0404
  Type:   Sequential-Access                  ANSI SCSI revision: 02
scsi0: Target 0: Queue Depth 3, Wide Synchronous at 20.0 MB/sec, offset 15
scsi1 : SCSI host adapter emulation for IDE ATAPI devices
st: Version 20040102, bufsize 32768, max init. bufs 4, s/g segs 16
Attached scsi tape st0 at scsi0, channel 0, id 0, lun 0
usb.c: registered new driver usbdevfs
usb.c: registered new driver hub
ehci_hcd 00:10.3: VIA Technologies, Inc. USB 2.0
ehci_hcd 00:10.3: irq 3, pci mem cf81d000
usb.c: new USB bus registered, assigned bus number 1
ehci_hcd 00:10.3: USB 2.0 enabled, EHCI 1.00, driver 2003-Dec-29/2.4
hub.c: USB hub found
hub.c: 6 ports detected
host/uhci.c: USB Universal Host Controller Interface driver v1.1
host/uhci.c: USB UHCI at I/O 0xdc00, IRQ 11
usb.c: new USB bus registered, assigned bus number 2
hub.c: USB hub found
hub.c: 2 ports detected
host/uhci.c: USB UHCI at I/O 0xe000, IRQ 7
usb.c: new USB bus registered, assigned bus number 3
hub.c: USB hub found
hub.c: 2 ports detected
host/uhci.c: USB UHCI at I/O 0xe400, IRQ 5
usb.c: new USB bus registered, assigned bus number 4
hub.c: USB hub found
hub.c: 2 ports detected
Initializing USB Mass Storage driver...
usb.c: registered new driver usb-storage
USB Mass Storage support registered.
NET4: Linux TCP/IP 1.0 for NET4.0
IP Protocols: ICMP, UDP, TCP
IP: routing cache hash table of 2048 buckets, 16Kbytes
TCP: Hash tables configured (established 16384 bind 32768)
IPv4 over IPv4 tunneling driver
ip_conntrack version 2.1 (1919 buckets, 15352 max) - 288 bytes per conntrack
ip_tables: (C) 2000-2002 Netfilter core team
ipt_recent v0.3.1: Stephen Frost <sfrost@snowman.net>.  http://snowman.net/projects/ipt_recent/
NET4: Unix domain sockets 1.0/SMP for Linux NET4.0.
kjournald starting.  Commit interval 5 seconds
EXT3-fs: mounted filesystem with journal data mode.
VFS: Mounted root (ext3 filesystem) readonly.
Freeing unused kernel memory: 140k freed
hub.c: new USB device 00:10.3-3, assigned address 2
hub.c: USB hub found
hub.c: 4 ports detected
hub.c: new USB device 00:10.3-3.3, assigned address 3
usb.c: USB device 3 (vend/prod 0x4a9/0x1056) is not claimed by any active driver.
hub.c: new USB device 00:10.3-3.4, assigned address 4
usb.c: USB device 4 (vend/prod 0x4f9/0x16) is not claimed by any active driver.
Adding Swap: 506036k swap-space (priority -1)
EXT3 FS 2.4-0.9.19, 19 August 2002 on ide0(3,67), internal journal
usb.c: registered new driver usblp
printer.c: usblp0: USB Bidirectional printer dev 3 if 0 alt 0 proto 2 vid 0x04A9 pid 0x1056
printer.c: usblp1: USB Bidirectional printer dev 4 if 0 alt 0 proto 2 vid 0x04F9 pid 0x0016
printer.c: v0.13: USB Printer Device Class driver
via-rhine.c:v1.10-LK1.1.19  July-12-2003  Written by Donald Becker
  http://www.scyld.com/network/via-rhine.html
eth0: VIA VT6102 Rhine-II at 0xec00, 00:40:63:c4:b6:ca, IRQ 11.
eth0: MII PHY found at address 1, status 0x786d advertising 05e1 Link 45e1.
r8169 Gigabit Ethernet driver 1.2 loaded
eth1: Identified chip type is 'RTL8169s/8110s'.
eth1: RTL8169 at 0xcf882000, 00:08:54:23:fd:2b, IRQ 5
eth1: Auto-negotiation Enabled.
eth1: 1000Mbps Full-duplex operation.
ttyS0: LSR safety check engaged!
ttyS0: LSR safety check engaged!
ttyS1: LSR safety check engaged!
ttyS1: LSR safety check engaged!
kjournald starting.  Commit interval 5 seconds
EXT3 FS 2.4-0.9.19, 19 August 2002 on ide0(3,2), internal journal
EXT3-fs: mounted filesystem with journal data mode.
kjournald starting.  Commit interval 5 seconds
EXT3 FS 2.4-0.9.19, 19 August 2002 on ide0(3,1), internal journal
EXT3-fs: mounted filesystem with journal data mode.
eth0: Setting full-duplex based on MII #1 link partner capability of 45e1.
ttyS0: LSR safety check engaged!
ttyS1: LSR safety check engaged!
blk: queue c03c7f20, I/O limit 4095Mb (mask 0xffffffff)
blk: queue c03c805c, I/O limit 4095Mb (mask 0xffffffff)
Shorewall:net2all:DROP:IN=eth0 OUT= MAC=00:40:63:c4:b6:ca:00:e0:d0:00:b7:f2:08:00 SRC=222.88.173.5 DST=10.192.151.130 LEN=666 TOS=0x00 PREC=0x00 TTL=105 ID=34014 PROTO=UDP SPT=14668 DPT=1026 LEN=646 

--tThc/1wpZn/ma/RB--
