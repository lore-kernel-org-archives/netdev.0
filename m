From: Michael Grollman <mgrollman@nscus.com>
Subject: 8169 Intermittent ifup Failure Issue With RTL8102E Chipset in Intel's
 New D945GCLF Atom Board (Not the Initial Modprobe Crash, Another Problem)
Date: Tue, 24 Jun 2008 16:27:06 -0700
Message-ID: <486182CA.8040307@nscus.com>
Reply-To: mgrollman@nscus.com
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp201.sat.emailsrvr.com ([66.216.121.201]:38473 "EHLO
	smtp201.sat.emailsrvr.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753384AbYFXX1O (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 Jun 2008 19:27:14 -0400
Received: from relay10.relay.sat.mlsrvr.com (localhost [127.0.0.1])
	by relay10.relay.sat.mlsrvr.com (SMTP Server) with ESMTP id 20C831B4A9A
	for <netdev@vger.kernel.org>; Tue, 24 Jun 2008 19:27:14 -0400 (EDT)
Received: by relay10.relay.sat.mlsrvr.com (Authenticated sender: mgrollman-AT-nscus.com) with ESMTP id 3B4C31B4954
	for <netdev@vger.kernel.org>; Tue, 24 Jun 2008 19:27:11 -0400 (EDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


(This is a newbie reporting the problem, so take it with a grain of 
salt, to be sure.)

Patch of http://lkml.org/lkml/2008/4/17/298 seems to fix the boot-up 
modprobe crash related to r8169 Intermittent Issue With RTL8102E Chipset 
in Intel's New D945GCLF Atom Board.  However, the r8169 still only seems 
to work with this motherboard / realtek combo a certain percentage of 
the time.  I have found the best luck when unplugging the power supply 
for 5 minutes, and then bring it up cold, thought his was also not 
perfect.  Warm boots, then r8169 driver will load, but not work 
correctly all the time.

I have done most of this testing in 2.6.25-5.  The port led's do come 
on, its just that the driver will (apparently) not pass packets 
correctly, including DHCP packets.

Bounced this off some Intel guys, who had no special ideas at this point 
(see thread 
http://softwarecommunity.intel.com/isn/Community/en-US/forums/thread/30257590.aspx).

Cheers,

- Michael

Below is a dmesg of it in failure mode:

pic_id[0x00] enabled)
Processor #0 7:12 APIC version 20
ACPI: LAPIC (acpi_id[0x02] lapic_id[0x01] enabled)
Processor #1 7:12 APIC version 20
WARNING: NR_CPUS limit of 1 reached.  Processor ignored.
ACPI: LAPIC (acpi_id[0x03] lapic_id[0x82] disabled)
ACPI: LAPIC (acpi_id[0x04] lapic_id[0x83] disabled)
ACPI: LAPIC_NMI (acpi_id[0x01] dfl dfl lint[0x1])
ACPI: LAPIC_NMI (acpi_id[0x02] dfl dfl lint[0x1])
ACPI: IOAPIC (id[0x02] address[0xfec00000] gsi_base[0])
IOAPIC[0]: apic_id 2, version 32, address 0xfec00000, GSI 0-23
ACPI: INT_SRC_OVR (bus 0 bus_irq 0 global_irq 2 dfl dfl)
ACPI: INT_SRC_OVR (bus 0 bus_irq 9 global_irq 9 high level)
ACPI: IRQ0 used by override.
ACPI: IRQ2 used by override.
ACPI: IRQ9 used by override.
Enabling APIC mode:  Flat.  Using 1 I/O APICs
Using ACPI (MADT) for SMP configuration information
Allocating PCI resources starting at 30000000 (gap: 20000000:d0000000)
PM: Registered nosave memory: 000000000008f000 - 00000000000a0000
PM: Registered nosave memory: 00000000000a0000 - 00000000000e0000
PM: Registered nosave memory: 00000000000e0000 - 0000000000100000
PM: Registered nosave memory: 000000001f525000 - 000000001f52d000
PM: Registered nosave memory: 000000001f5bd000 - 000000001f5c1000
PM: Registered nosave memory: 000000001f660000 - 000000001f6f0000
PM: Registered nosave memory: 000000001f6f3000 - 000000001f6ff000
Built 1 zonelists in Zone order, mobility grouping on.  Total pages: 127762
Kernel command line: root=/dev/sda1
mapped APIC to ffffb000 (fee00000)
mapped IOAPIC to ffffa000 (fec00000)
Enabling fast FPU save and restore... done.
Enabling unmasked SIMD FPU exception support... done.
Initializing CPU#0
PID hash table entries: 2048 (order: 11, 8192 bytes)
Detected 1596.154 MHz processor.
Console: colour VGA+ 80x25
console [tty0] enabled
Dentry cache hash table entries: 65536 (order: 6, 262144 bytes)
Inode-cache hash table entries: 32768 (order: 5, 131072 bytes)
Memory: 503288k/515072k available (2108k kernel code, 10184k reserved, 
823k data, 208k init, 0k highmem)
virtual kernel memory layout:
    fixmap  : 0xfffa7000 - 0xfffff000   ( 352 kB)
    pkmap   : 0xff800000 - 0xffc00000   (4096 kB)
    vmalloc : 0xe0000000 - 0xff7fe000   ( 503 MB)
    lowmem  : 0xc0000000 - 0xdf700000   ( 503 MB)
      .init : 0xc03e0000 - 0xc0414000   ( 208 kB)
      .data : 0xc030f3f9 - 0xc03dd3d8   ( 823 kB)
      .text : 0xc0100000 - 0xc030f3f9   (2108 kB)
Checking if this processor honours the WP bit even in supervisor mode...Ok.
CPA: page pool initialized 1 of 1 pages preallocated
Calibrating delay using timer specific routine.. 3194.13 BogoMIPS 
(lpj=1597066)
Mount-cache hash table entries: 512
CPU: L1 I cache: 32K, L1 D cache: 24K
CPU: L2 cache: 512K
using mwait in idle threads.
Compat vDSO mapped to ffffe000.
CPU: Intel(R) Atom(TM) CPU  230   @ 1.60GHz stepping 02
Checking 'hlt' instruction... OK.
Freeing SMP alternatives: 0k freed
ACPI: Core revision 20070126
ENABLING IO-APIC IRQs
..TIMER: vector=0x31 apic1=0 pin1=2 apic2=-1 pin2=-1
net_namespace: 540 bytes
NET: Registered protocol family 16
No dock devices found.
ACPI: bus type pci registered
PCI: Found Intel Corporation 945G/GZ/P/PL Express Memory Controller Hub 
without MMCONFIG support.
PCI: Using configuration type 1
Setting up standard PCI resources
ACPI: EC: Look up EC in DSDT
ACPI: Interpreter enabled
ACPI: (supports S0 S1 S3 S4 S5)
ACPI: Using IOAPIC for interrupt routing
ACPI: PCI Root Bridge [PCI0] (0000:00)
pci 0000:00:1f.0: Force enabled HPET at 0xfed00000
pci 0000:00:1f.0: quirk: region 0400-047f claimed by ICH6 ACPI/GPIO/TCO
pci 0000:00:1f.0: quirk: region 0500-053f claimed by ICH6 GPIO
PCI: Transparent bridge - 0000:00:1e.0
ACPI: PCI Interrupt Routing Table [\_SB_.PCI0._PRT]
ACPI: PCI Interrupt Routing Table [\_SB_.PCI0.P32_._PRT]
ACPI: PCI Interrupt Routing Table [\_SB_.PCI0.PEX0._PRT]
ACPI: PCI Interrupt Routing Table [\_SB_.PCI0.PEX2._PRT]
ACPI: PCI Interrupt Routing Table [\_SB_.PCI0.PEX3._PRT]
ACPI: PCI Interrupt Link [LNKA] (IRQs 3 4 5 7 9 10 *11 12)
ACPI: PCI Interrupt Link [LNKB] (IRQs 3 4 5 7 9 10 11 12) *0, disabled.
ACPI: PCI Interrupt Link [LNKC] (IRQs 3 4 5 7 *9 10 11 12)
ACPI: PCI Interrupt Link [LNKD] (IRQs 3 4 5 7 9 10 *11 12)
ACPI: PCI Interrupt Link [LNKE] (IRQs 3 4 5 7 9 10 11 12) *0, disabled.
ACPI: PCI Interrupt Link [LNKF] (IRQs 3 4 5 7 9 10 11 12) *0, disabled.
ACPI: PCI Interrupt Link [LNKG] (IRQs 3 4 5 7 *9 10 11 12)
ACPI: PCI Interrupt Link [LNKH] (IRQs 3 4 5 7 9 *10 11 12)
Linux Plug and Play Support v0.97 (c) Adam Belay
pnp: PnP ACPI init
ACPI: bus type pnp registered
pnp: PnP ACPI: found 11 devices
ACPI: ACPI bus type pnp unregistered
SCSI subsystem initialized
libata version 3.00 loaded.
usbcore: registered new interface driver usbfs
usbcore: registered new interface driver hub
usbcore: registered new device driver usb
PCI: Using ACPI for IRQ routing
PCI: If a device doesn't work, try "pci=routeirq".  If it helps, post a 
report
hpet clockevent registered
system 00:01: iomem range 0xf0000000-0xf3ffffff could not be reserved
system 00:01: iomem range 0xfed13000-0xfed13fff could not be reserved
system 00:01: iomem range 0xfed14000-0xfed17fff could not be reserved
system 00:01: iomem range 0xfed18000-0xfed18fff could not be reserved
system 00:01: iomem range 0xfed19000-0xfed19fff could not be reserved
system 00:01: iomem range 0xfed1c000-0xfed1ffff could not be reserved
system 00:01: iomem range 0xfed20000-0xfed3ffff could not be reserved
system 00:01: iomem range 0xfed45000-0xfed99fff could not be reserved
system 00:01: iomem range 0xc0000-0xdffff could not be reserved
system 00:01: iomem range 0xe0000-0xfffff could not be reserved
system 00:06: ioport range 0x500-0x53f has been reserved
system 00:06: ioport range 0x400-0x47f has been reserved
system 00:06: ioport range 0x680-0x6ff has been reserved
PCI: Bridge: 0000:00:1c.0
  IO window: 1000-1fff
  MEM window: 0x30100000-0x301fffff
  PREFETCH window: 0x0000000030000000-0x00000000300fffff
PCI: Bridge: 0000:00:1c.2
  IO window: disabled.
  MEM window: disabled.
  PREFETCH window: disabled.
PCI: Bridge: 0000:00:1c.3
  IO window: disabled.
  MEM window: disabled.
  PREFETCH window: disabled.
PCI: Bridge: 0000:00:1e.0
  IO window: disabled.
  MEM window: disabled.
  PREFETCH window: disabled.
ACPI: PCI Interrupt 0000:00:1c.0[A] -> GSI 17 (level, low) -> IRQ 17
PCI: Setting latency timer of device 0000:00:1c.0 to 64
ACPI: PCI Interrupt 0000:00:1c.2[C] -> GSI 18 (level, low) -> IRQ 18
PCI: Setting latency timer of device 0000:00:1c.2 to 64
ACPI: PCI Interrupt 0000:00:1c.3[D] -> GSI 19 (level, low) -> IRQ 19
PCI: Setting latency timer of device 0000:00:1c.3 to 64
PCI: Setting latency timer of device 0000:00:1e.0 to 64
NET: Registered protocol family 2
IP route cache hash table entries: 4096 (order: 2, 16384 bytes)
TCP established hash table entries: 16384 (order: 5, 131072 bytes)
TCP bind hash table entries: 16384 (order: 4, 65536 bytes)
TCP: Hash tables configured (established 16384 bind 16384)
TCP reno registered
checking if image is initramfs... it is
Freeing initrd memory: 2349k freed
io scheduler noop registered
io scheduler cfq registered (default)
pci 0000:00:02.0: Boot video device
PCI: Setting latency timer of device 0000:00:1c.0 to 64
assign_interrupt_mode Found MSI capability
Allocate Port Service[0000:00:1c.0:pcie00]
Allocate Port Service[0000:00:1c.0:pcie02]
PCI: Setting latency timer of device 0000:00:1c.2 to 64
assign_interrupt_mode Found MSI capability
Allocate Port Service[0000:00:1c.2:pcie00]
Allocate Port Service[0000:00:1c.2:pcie02]
PCI: Setting latency timer of device 0000:00:1c.3 to 64
assign_interrupt_mode Found MSI capability
Allocate Port Service[0000:00:1c.3:pcie00]
Allocate Port Service[0000:00:1c.3:pcie02]
input: Power Button (FF) as /class/input/input0
ACPI: Power Button (FF) [PWRF]
input: Sleep Button (CM) as /class/input/input1
ACPI: Sleep Button (CM) [SLPB]
ACPI: ACPI0007:00 is registered as cooling_device0
Serial: 8250/16550 driver $Revision: 1.90 $ 2 ports, IRQ sharing enabled
Switched to high resolution mode on CPU 0
serial8250: ttyS0 at I/O 0x3f8 (irq = 4) is a 16550A
00:09: ttyS0 at I/O 0x3f8 (irq = 4) is a 16550A
brd: module loaded
Uniform Multi-Platform E-IDE driver
ide: Assuming 33MHz system bus speed for PIO modes; override with idebus=xx
ICH7: IDE controller (0x8086:0x27df rev 0x01) at  PCI slot 0000:00:1f.1
ACPI: PCI Interrupt 0000:00:1f.1[A] -> GSI 18 (level, low) -> IRQ 18
ICH7: not 100% native mode: will probe irqs later
ICH7: IDE port disabled
    ide0: BM-DMA at 0x20b0-0x20b7, BIOS settings: hda:PIO, hdb:PIO
Probing IDE interface ide0...
Probing IDE interface ide0...
Probing IDE interface ide1...
usbmon: debugfs is not available
ACPI: PCI Interrupt 0000:00:1d.7[A] -> GSI 23 (level, low) -> IRQ 23
PCI: Setting latency timer of device 0000:00:1d.7 to 64
ehci_hcd 0000:00:1d.7: EHCI Host Controller
ehci_hcd 0000:00:1d.7: new USB bus registered, assigned bus number 1
ehci_hcd 0000:00:1d.7: debug port 1
PCI: cache line size of 32 is not supported by device 0000:00:1d.7
ehci_hcd 0000:00:1d.7: irq 23, io mem 0x302c4000
ehci_hcd 0000:00:1d.7: USB 2.0 started, EHCI 1.00, driver 10 Dec 2004
usb usb1: configuration #1 chosen from 1 choice
hub 1-0:1.0: USB hub found
hub 1-0:1.0: 8 ports detected
ohci_hcd: 2006 August 04 USB 1.1 'Open' Host Controller (OHCI) Driver
USB Universal Host Controller Interface driver v3.0
ACPI: PCI Interrupt 0000:00:1d.0[A] -> GSI 23 (level, low) -> IRQ 23
PCI: Setting latency timer of device 0000:00:1d.0 to 64
uhci_hcd 0000:00:1d.0: UHCI Host Controller
uhci_hcd 0000:00:1d.0: new USB bus registered, assigned bus number 2
uhci_hcd 0000:00:1d.0: irq 23, io base 0x00002080
usb usb2: configuration #1 chosen from 1 choice
hub 2-0:1.0: USB hub found
hub 2-0:1.0: 2 ports detected
ACPI: PCI Interrupt 0000:00:1d.1[B] -> GSI 19 (level, low) -> IRQ 19
PCI: Setting latency timer of device 0000:00:1d.1 to 64
uhci_hcd 0000:00:1d.1: UHCI Host Controller
uhci_hcd 0000:00:1d.1: new USB bus registered, assigned bus number 3
uhci_hcd 0000:00:1d.1: irq 19, io base 0x00002060
usb usb3: configuration #1 chosen from 1 choice
hub 3-0:1.0: USB hub found
hub 3-0:1.0: 2 ports detected
ACPI: PCI Interrupt 0000:00:1d.2[C] -> GSI 18 (level, low) -> IRQ 18
PCI: Setting latency timer of device 0000:00:1d.2 to 64
uhci_hcd 0000:00:1d.2: UHCI Host Controller
uhci_hcd 0000:00:1d.2: new USB bus registered, assigned bus number 4
uhci_hcd 0000:00:1d.2: irq 18, io base 0x00002040
usb usb4: configuration #1 chosen from 1 choice
hub 4-0:1.0: USB hub found
hub 4-0:1.0: 2 ports detected
usb 1-3: new high speed USB device using ehci_hcd and address 2
ACPI: PCI Interrupt 0000:00:1d.3[D] -> GSI 16 (level, low) -> IRQ 16
PCI: Setting latency timer of device 0000:00:1d.3 to 64
uhci_hcd 0000:00:1d.3: UHCI Host Controller
uhci_hcd 0000:00:1d.3: new USB bus registered, assigned bus number 5
uhci_hcd 0000:00:1d.3: irq 16, io base 0x00002020
usb usb5: configuration #1 chosen from 1 choice
hub 5-0:1.0: USB hub found
hub 5-0:1.0: 2 ports detected
usb 1-3: configuration #1 chosen from 1 choice
Initializing USB Mass Storage driver...
scsi0 : SCSI emulation for USB Mass Storage devices
usb-storage: device found at 2
usb-storage: waiting for device to settle before scanning
usbcore: registered new interface driver usb-storage
USB Mass Storage support registered.
PNP: PS/2 Controller [PNP0303:PS2K,PNP0f03:PS2M] at 0x60,0x64 irq 1,12
serio: i8042 KBD port at 0x60,0x64 irq 1
serio: i8042 AUX port at 0x60,0x64 irq 12
mice: PS/2 mouse device common for all mice
input: AT Translated Set 2 keyboard as /class/input/input2
padlock: VIA PadLock not detected.
padlock: VIA PadLock Hash Engine not detected.
TCP cubic registered
NET: Registered protocol family 1
NET: Registered protocol family 17
RPC: Registered udp transport module.
RPC: Registered tcp transport module.
Using IPI Shortcut mode
Freeing unused kernel memory: 208k freed
input: ImPS/2 Generic Wheel Mouse as /class/input/input3
*r8169 Gigabit Ethernet driver 2.2LK-NAPI loaded
ACPI: PCI Interrupt 0000:01:00.0[A] -> GSI 16 (level, low) -> IRQ 16
PCI: Setting latency timer of device 0000:01:00.0 to 64*
*r8169 0000:01:00.0: unknown MAC (27a00000)
r8169 0000:01:00.0: no MSI. Back to INTx.
eth0: RTL8169 at 0xe0020000, 00:1c:c0:45:de:94, XID 24a00000 IRQ 16*
ata_piix 0000:00:1f.2: version 2.12
ACPI: PCI Interrupt 0000:00:1f.2[B] -> GSI 19 (level, low) -> IRQ 19
ata_piix 0000:00:1f.2: MAP [ P0 P2 P1 P3 ]
PCI: Setting latency timer of device 0000:00:1f.2 to 64
scsi1 : ata_piix
scsi2 : ata_piix
ata1: SATA max UDMA/133 cmd 0x20c8 ctl 0x20ec bmdma 0x20a0 irq 19
ata2: SATA max UDMA/133 cmd 0x20c0 ctl 0x20e8 bmdma 0x20a8 irq 19
ata1.00: ATA-8: WDC WD600BEVS-22UST0, 01.01A01, max UDMA/133
ata1.00: 117210240 sectors, multi 16: LBA48 NCQ (depth 0/32)
ata1.00: configured for UDMA/133
scsi 1:0:0:0: Direct-Access     ATA      WDC WD600BEVS-22 01.0 PQ: 0 ANSI: 5
Driver 'sd' needs updating - please use bus_type methods
sd 1:0:0:0: [sda] 117210240 512-byte hardware sectors (60012 MB)
sd 1:0:0:0: [sda] Write Protect is off
sd 1:0:0:0: [sda] Mode Sense: 00 3a 00 00
sd 1:0:0:0: [sda] Write cache: enabled, read cache: enabled, doesn't 
support DPO or FUA
sd 1:0:0:0: [sda] 117210240 512-byte hardware sectors (60012 MB)
sd 1:0:0:0: [sda] Write Protect is off
sd 1:0:0:0: [sda] Mode Sense: 00 3a 00 00
sd 1:0:0:0: [sda] Write cache: enabled, read cache: enabled, doesn't 
support DPO or FUA
 sda: sda1 sda2
sd 1:0:0:0: [sda] Attached SCSI disk
kjournald starting.  Commit interval 5 seconds
EXT3-fs: mounted filesystem with ordered data mode.
ACPI: PCI Interrupt 0000:00:1b.0[A] -> GSI 22 (level, low) -> IRQ 22
PCI: Setting latency timer of device 0000:00:1b.0 to 64
hda_codec: Unknown model for ALC662, trying auto-probe from BIOS...
scsi 0:0:0:0: Direct-Access     OEI-USB2 Ultra Disk Drive 2.22 PQ: 0 ANSI: 0
sd 0:0:0:0: [sdb] 1981728 512-byte hardware sectors (1015 MB)
sd 0:0:0:0: [sdb] Write Protect is off
sd 0:0:0:0: [sdb] Mode Sense: 0b 00 00 08
sd 0:0:0:0: [sdb] Assuming drive cache: write through
sd 0:0:0:0: [sdb] 1981728 512-byte hardware sectors (1015 MB)
sd 0:0:0:0: [sdb] Write Protect is off
sd 0:0:0:0: [sdb] Mode Sense: 0b 00 00 08
sd 0:0:0:0: [sdb] Assuming drive cache: write through
 sdb: sdb1 sdb2 sdb3 sdb4
sd 0:0:0:0: [sdb] Attached SCSI removable disk
usb-storage: device scan complete
intel_rng: Firmware space is locked read-only. If you can't or
intel_rng: don't want to disable this in firmware setup, and if
intel_rng: you are certain that your system has a functional
intel_rng: RNG, try using the 'no_fwh_detect' option.
ACPI: PCI Interrupt 0000:00:1f.3[B] -> GSI 19 (level, low) -> IRQ 19
Real Time Clock Driver v1.12ac
iTCO_vendor_support: vendor-support=0
iTCO_wdt: Intel TCO WatchDog Timer Driver v1.02 (26-Jul-2007)
iTCO_wdt: Found a ICH7 or ICH7R TCO device (Version=2, TCOBASE=0x0460)
iTCO_wdt: initialized. heartbeat=30 sec (nowayout=0)
EXT3 FS on sda1, internal journal
natsemi dp8381x driver, version 2.1, Sept 11, 2006
  originally by Donald Becker <becker@scyld.com>
  2.4.x kernel port by Jeff Garzik, Tjeerd Mulder
ieee80211_crypt: registered algorithm 'NULL'
device-mapper: ioctl: 4.13.0-ioctl (2007-10-18) initialised: 
dm-devel@redhat.com
*r8169: eth0: link up*
NET: Registered protocol family 10
lo: Disabled Privacy Extensions
warning: `dnsmasq' uses 32-bit capabilities (legacy support in use)
eth0: no IPv6 routers present
EXT3 FS on sda1, internal journal



