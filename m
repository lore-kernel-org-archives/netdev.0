From: Jan Gukelberger <g.u.g.i@gmx.de>
Subject: BUG: skge ethernet breakage (PCI: Unable to reserve mem region)
Date: Fri, 07 Sep 2007 18:42:35 +0200
Message-ID: <1189183355.3784.11.camel@localhost>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="=-1kfB3eVTCK8LrFJ0Ta0u"
Cc: netdev@vger.kernel.org
To: shemminger@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.gmx.net ([213.165.64.20]:48261 "HELO mail.gmx.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with SMTP
	id S1757437AbXIGQmk (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 7 Sep 2007 12:42:40 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--=-1kfB3eVTCK8LrFJ0Ta0u
Content-Type: text/plain
Content-Transfer-Encoding: 7bit

Hi,

I originally reported this bug to the Debian BTS:
http://bugs.debian.org/cgi-bin/bugreport.cgi?bug=441232
There I was told to talk directly to upstream.

I am pasting the original bug report below. The referenced text files
can be found at the mentioned BTS URL. 
Additionally, I have just tried Linux 2.6.23-rc5 and am attaching the
corresponding dmesg output.

Thanks in advance for any help,
Jan


With recent kernels my on-board network adapter does not work any more.
This is a Marvell Gigabit Ethernet Controller on an Asus P5B-V
mainboard.

This is the same bug as #428452 reported earlier against
linux-image-2.6.21-1-amd64. (Sorry for the duplicate, I didn't know how
to extend the old report to newer kernel versions.)
In fact, the network adapter hasn't been working since then, i.e. the
last working kernel image was 2.6.20-1-amd64 (which I am using now). The
following images 2.6.2[12]-[12]-amd64 have all exposed the same problem.

The key problem seem to be the following lines in dmesg:
------------------------------------------------------------------------
ACPI: PCI Interrupt 0000:04:04.0[A] -> GSI 19 (level, low) -> IRQ 19
PCI: Unable to reserve mem region #1:4000@ff9f8000 for device 0000:04:04.0
skge 0000:04:04.0: cannot obtain PCI resources
ACPI: PCI interrupt for device 0000:04:04.0 disabled
skge: probe of 0000:04:04.0 failed with error -16
------------------------------------------------------------------------

I'm attaching full 'dmesg' output from working (2.6.20-1) and broken
(2.6.22-2) kernel versions as well as the output of 'lspci -vvv' on the
most recent kernel.

If you need any other information or I can try something please let me
know.

--=-1kfB3eVTCK8LrFJ0Ta0u
Content-Disposition: attachment; filename=dmesg-2.6.23-rc5
Content-Type: text/plain; name=dmesg-2.6.23-rc5; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit

Linux version 2.6.23-rc5-amd64 (Debian 2.6.23~rc5-1~experimental.1~snapshot.9462) (waldi@debian.org) (gcc version 4.1.3 20070718 (prerelease) (Debian 4.1.2-14+1)) #1 SMP Thu Sep 6 06:18:52 UTC 2007
Command line: root=/dev/sda6 ro quiet vga=791 
BIOS-provided physical RAM map:
 BIOS-e820: 0000000000000000 - 000000000009ec00 (usable)
 BIOS-e820: 000000000009ec00 - 00000000000a0000 (reserved)
 BIOS-e820: 00000000000e4000 - 0000000000100000 (reserved)
 BIOS-e820: 0000000000100000 - 000000007ef90000 (usable)
 BIOS-e820: 000000007ef90000 - 000000007ef9e000 (ACPI data)
 BIOS-e820: 000000007ef9e000 - 000000007efe0000 (ACPI NVS)
 BIOS-e820: 000000007efe0000 - 000000007f000000 (reserved)
 BIOS-e820: 00000000fee00000 - 00000000fee01000 (reserved)
 BIOS-e820: 00000000ffb00000 - 0000000100000000 (reserved)
Entering add_active_range(0, 0, 158) 0 entries of 3200 used
Entering add_active_range(0, 256, 520080) 1 entries of 3200 used
end_pfn_map = 1048576
DMI 2.4 present.
ACPI: RSDP 000FAD70, 0024 (r2 ACPIAM)
ACPI: XSDT 7EF90100, 006C (r1 NEC              5000730 MSFT       97)
ACPI: FACP 7EF90290, 00F4 (r3 MSTEST OEMFACP   5000730 MSFT       97)
ACPI: DSDT 7EF905C0, 9C85 (r1  A0579 A0579000        0 INTL 20060113)
ACPI: FACS 7EF9E000, 0040
ACPI: APIC 7EF90390, 006C (r1 MSTEST OEMAPIC   5000730 MSFT       97)
ACPI: MCFG 7EF90400, 003C (r1 MSTEST OEMMCFG   5000730 MSFT       97)
ACPI: SLIC 7EF90440, 0176 (r1 NEC              5000730 MSFT       97)
ACPI: OEMB 7EF9E040, 007B (r1 MSTEST AMI_OEM   5000730 MSFT       97)
ACPI: HPET 7EF9A250, 0038 (r1 MSTEST OEMHPET   5000730 MSFT       97)
ACPI: GSCI 7EF9E0C0, 2024 (r1 MSTEST GMCHSCI   5000730 MSFT       97)
ACPI: SSDT 7EFA00F0, 01BF (r1    AMI   CPU1PM        1 INTL 20060113)
ACPI: SSDT 7EFA02B0, 0133 (r1    AMI   CPU2PM        1 INTL 20060113)
No NUMA configuration found
Faking a node at 0000000000000000-000000007ef90000
Entering add_active_range(0, 0, 158) 0 entries of 3200 used
Entering add_active_range(0, 256, 520080) 1 entries of 3200 used
Bootmem setup node 0 0000000000000000-000000007ef90000
Zone PFN ranges:
  DMA             0 ->     4096
  DMA32        4096 ->  1048576
  Normal    1048576 ->  1048576
Movable zone start PFN for each node
early_node_map[2] active PFN ranges
    0:        0 ->      158
    0:      256 ->   520080
On node 0 totalpages: 519982
  DMA zone: 56 pages used for memmap
  DMA zone: 1044 pages reserved
  DMA zone: 2898 pages, LIFO batch:0
  DMA32 zone: 7054 pages used for memmap
  DMA32 zone: 508930 pages, LIFO batch:31
  Normal zone: 0 pages used for memmap
  Movable zone: 0 pages used for memmap
ACPI: PM-Timer IO Port: 0x808
ACPI: Local APIC address 0xfee00000
ACPI: LAPIC (acpi_id[0x01] lapic_id[0x00] enabled)
Processor #0 (Bootup-CPU)
ACPI: LAPIC (acpi_id[0x02] lapic_id[0x01] enabled)
Processor #1
ACPI: LAPIC (acpi_id[0x03] lapic_id[0x82] disabled)
ACPI: LAPIC (acpi_id[0x04] lapic_id[0x83] disabled)
ACPI: IOAPIC (id[0x02] address[0xfec00000] gsi_base[0])
IOAPIC[0]: apic_id 2, address 0xfec00000, GSI 0-23
ACPI: INT_SRC_OVR (bus 0 bus_irq 0 global_irq 2 dfl dfl)
ACPI: INT_SRC_OVR (bus 0 bus_irq 9 global_irq 9 high level)
ACPI: IRQ0 used by override.
ACPI: IRQ2 used by override.
ACPI: IRQ9 used by override.
Setting APIC routing to flat
ACPI: HPET id: 0x8086a202 base: 0xfed00000
Using ACPI (MADT) for SMP configuration information
swsusp: Registered nosave memory region: 000000000009e000 - 000000000009f000
swsusp: Registered nosave memory region: 000000000009f000 - 00000000000a0000
swsusp: Registered nosave memory region: 00000000000a0000 - 00000000000e4000
swsusp: Registered nosave memory region: 00000000000e4000 - 0000000000100000
Allocating PCI resources starting at 80000000 (gap: 7f000000:7fe00000)
SMP: Allowing 4 CPUs, 2 hotplug CPUs
PERCPU: Allocating 35176 bytes of per cpu data
Built 1 zonelists in Node order.  Total pages: 511828
Policy zone: DMA32
Kernel command line: root=/dev/sda6 ro quiet vga=791 
Initializing CPU#0
PID hash table entries: 4096 (order: 12, 32768 bytes)
Extended CMOS year: 2000
time.c: Detected 2399.997 MHz processor.
Console: colour dummy device 80x25
console [tty0] enabled
Checking aperture...
Calgary: detecting Calgary via BIOS EBDA area
Calgary: Unable to locate Rio Grande table in EBDA - bailing!
Memory: 2041096k/2080320k available (2066k kernel code, 38832k reserved, 977k data, 304k init)
Calibrating delay using timer specific routine.. 4803.34 BogoMIPS (lpj=9606690)
Security Framework v1.0.0 initialized
SELinux:  Disabled at boot.
Capability LSM initialized
Dentry cache hash table entries: 262144 (order: 9, 2097152 bytes)
Inode-cache hash table entries: 131072 (order: 8, 1048576 bytes)
Mount-cache hash table entries: 256
CPU: L1 I cache: 32K, L1 D cache: 32K
CPU: L2 cache: 4096K
CPU 0/0 -> Node 0
using mwait in idle threads.
CPU: Physical Processor ID: 0
CPU: Processor Core ID: 0
CPU0: Thermal monitoring enabled (TM2)
SMP alternatives: switching to UP code
ACPI: Core revision 20070126
Using local APIC timer interrupts.
result 16666629
Detected 16.666 MHz APIC timer.
SMP alternatives: switching to SMP code
Booting processor 1/2 APIC 0x1
Initializing CPU#1
Calibrating delay using timer specific routine.. 4800.03 BogoMIPS (lpj=9600060)
CPU: L1 I cache: 32K, L1 D cache: 32K
CPU: L2 cache: 4096K
CPU 1/1 -> Node 0
CPU: Physical Processor ID: 0
CPU: Processor Core ID: 1
CPU1: Thermal monitoring enabled (TM2)
Intel(R) Core(TM)2 CPU          6600  @ 2.40GHz stepping 06
checking TSC synchronization [CPU#0 -> CPU#1]: passed.
Brought up 2 CPUs
NET: Registered protocol family 16
ACPI: bus type pci registered
PCI: BIOS Bug: MCFG area at e0000000 is not E820-reserved
PCI: Not using MMCONFIG.
PCI: Using configuration type 1
ACPI: EC: Look up EC in DSDT
ACPI: Interpreter enabled
ACPI: (supports S0 S1 S3)
ACPI: Using IOAPIC for interrupt routing
ACPI: PCI Root Bridge [PCI0] (0000:00)
PCI quirk: region 0800-087f claimed by ICH6 ACPI/GPIO/TCO
PCI quirk: region 0480-04bf claimed by ICH6 GPIO
PCI: Transparent bridge - 0000:00:1e.0
ACPI: PCI Interrupt Routing Table [\_SB_.PCI0._PRT]
ACPI: PCI Interrupt Routing Table [\_SB_.PCI0.P0P2._PRT]
ACPI: PCI Interrupt Routing Table [\_SB_.PCI0.P0P1._PRT]
ACPI: PCI Interrupt Routing Table [\_SB_.PCI0.P0P8._PRT]
ACPI: PCI Interrupt Routing Table [\_SB_.PCI0.P0P4._PRT]
ACPI: PCI Interrupt Link [LNKA] (IRQs 3 4 5 6 7 10 *11 12 14 15)
ACPI: PCI Interrupt Link [LNKB] (IRQs 3 4 5 6 7 *10 11 12 14 15)
ACPI: PCI Interrupt Link [LNKC] (IRQs 3 4 *5 6 7 10 11 12 14 15)
ACPI: PCI Interrupt Link [LNKD] (IRQs 3 4 5 6 7 10 11 12 14 *15)
ACPI: PCI Interrupt Link [LNKE] (IRQs 3 4 5 6 7 10 11 12 14 15) *0, disabled.
ACPI: PCI Interrupt Link [LNKF] (IRQs 3 4 5 6 7 10 11 12 *14 15)
ACPI: PCI Interrupt Link [LNKG] (IRQs *3 4 5 6 7 10 11 12 14 15)
ACPI: PCI Interrupt Link [LNKH] (IRQs 3 4 5 6 *7 10 11 12 14 15)
ACPI Warning (tbutils-0217): Incorrect checksum in table [OEMB] -  CD, should be C4 [20070126]
Linux Plug and Play Support v0.97 (c) Adam Belay
pnp: PnP ACPI init
ACPI: bus type pnp registered
pnp: ACPI device : hid PNP0A08
pnp: ACPI device : hid PNP0C01
pnp: ACPI device : hid PNP0200
pnp: ACPI device : hid PNP0B00
pnp: ACPI device : hid PNP0800
pnp: ACPI device : hid PNP0C04
pnp: ACPI device : hid PNP0501
pnp: ACPI device : hid PNP0700
pnp: ACPI device : hid PNP0C02
pnp: ACPI device : hid PNP0C02
pnp: ACPI device : hid PNP0103
pnp: ACPI device : hid PNP0C02
pnp: ACPI device : hid PNP0303
pnp: ACPI device : hid PNP0F03
pnp: ACPI device : hid PNP0C02
pnp: ACPI device : hid PNP0C01
pnp: PnP ACPI: found 16 devices
ACPI: ACPI bus type pnp unregistered
usbcore: registered new interface driver usbfs
usbcore: registered new interface driver hub
usbcore: registered new device driver usb
PCI: Using ACPI for IRQ routing
PCI: If a device doesn't work, try "pci=routeirq".  If it helps, post a report
NET: Registered protocol family 8
NET: Registered protocol family 20
PCI-GART: No AMD northbridge found.
hpet0: at MMIO 0xfed00000, IRQs 2, 8, 0
hpet0: 3 64-bit timers, 14318180 Hz
ACPI: RTC can wake from S4
Time: tsc clocksource has been installed.
pnp: the driver 'system' has been registered
pnp: match found with the PnP device '00:01' and the driver 'system'
pnp: 00:01: iomem range 0xfed14000-0xfed19fff has been reserved
pnp: match found with the PnP device '00:08' and the driver 'system'
pnp: 00:08: ioport range 0x290-0x297 has been reserved
pnp: match found with the PnP device '00:09' and the driver 'system'
pnp: 00:09: iomem range 0xfed1c000-0xfed1ffff has been reserved
pnp: 00:09: iomem range 0xfed20000-0xfed8ffff has been reserved
pnp: 00:09: iomem range 0xff9fa000-0xff9fafff has been reserved
pnp: 00:09: iomem range 0xfff00000-0xfffffffe could not be reserved
pnp: match found with the PnP device '00:0b' and the driver 'system'
pnp: 00:0b: iomem range 0xfec00000-0xfec00fff has been reserved
pnp: 00:0b: iomem range 0xfee00000-0xfee00fff could not be reserved
pnp: match found with the PnP device '00:0e' and the driver 'system'
pnp: 00:0e: iomem range 0xe0000000-0xefffffff has been reserved
pnp: match found with the PnP device '00:0f' and the driver 'system'
pnp: 00:0f: iomem range 0x0-0x9ffff could not be reserved
pnp: 00:0f: iomem range 0xc0000-0xcffff has been reserved
pnp: 00:0f: iomem range 0xe0000-0xfffff could not be reserved
pnp: 00:0f: iomem range 0x100000-0x7effffff could not be reserved
PCI: Bridge: 0000:00:01.0
  IO window: 8000-afff
  MEM window: ff700000-ff7fffff
  PREFETCH window: bfe00000-dfdfffff
PCI: Bridge: 0000:00:1c.0
  IO window: disabled.
  MEM window: disabled.
  PREFETCH window: dfe00000-dfefffff
PCI: Bridge: 0000:00:1c.4
  IO window: b000-bfff
  MEM window: ff800000-ff8fffff
  PREFETCH window: disabled.
PCI: Bridge: 0000:00:1e.0
  IO window: c000-cfff
  MEM window: ff900000-ff9fffff
  PREFETCH window: 80000000-800fffff
ACPI: PCI Interrupt 0000:00:01.0[A] -> GSI 16 (level, low) -> IRQ 16
PCI: Setting latency timer of device 0000:00:01.0 to 64
ACPI: PCI Interrupt 0000:00:1c.0[A] -> GSI 17 (level, low) -> IRQ 17
PCI: Setting latency timer of device 0000:00:1c.0 to 64
ACPI: PCI Interrupt 0000:00:1c.4[A] -> GSI 17 (level, low) -> IRQ 17
PCI: Setting latency timer of device 0000:00:1c.4 to 64
PCI: Setting latency timer of device 0000:00:1e.0 to 64
NET: Registered protocol family 2
IP route cache hash table entries: 65536 (order: 7, 524288 bytes)
TCP established hash table entries: 262144 (order: 10, 6291456 bytes)
TCP bind hash table entries: 65536 (order: 8, 1048576 bytes)
TCP: Hash tables configured (established 262144 bind 65536)
TCP reno registered
checking if image is initramfs... it is
Freeing initrd memory: 5950k freed
audit: initializing netlink socket (disabled)
audit(1189181505.780:1): initialized
VFS: Disk quotas dquot_6.5.1
Dquot-cache hash table entries: 512 (order 0, 4096 bytes)
io scheduler noop registered
io scheduler anticipatory registered
io scheduler deadline registered
io scheduler cfq registered (default)
Boot video device is 0000:01:00.0
PCI: Setting latency timer of device 0000:00:01.0 to 64
assign_interrupt_mode Found MSI capability
Allocate Port Service[0000:00:01.0:pcie00]
PCI: Setting latency timer of device 0000:00:1c.0 to 64
assign_interrupt_mode Found MSI capability
Allocate Port Service[0000:00:1c.0:pcie00]
Allocate Port Service[0000:00:1c.0:pcie02]
PCI: Setting latency timer of device 0000:00:1c.4 to 64
assign_interrupt_mode Found MSI capability
Allocate Port Service[0000:00:1c.4:pcie00]
Allocate Port Service[0000:00:1c.4:pcie02]
vesafb: framebuffer at 0xc0000000, mapped to 0xffffc20000b00000, using 3072k, total 16384k
vesafb: mode is 1024x768x16, linelength=2048, pages=9
vesafb: scrolling: redraw
vesafb: Truecolor: size=0:5:6:5, shift=0:11:5:0
Console: switching to colour frame buffer device 128x48
fb0: VESA VGA frame buffer device
Real Time Clock Driver v1.12ac
hpet_resources: 0xfed00000 is busy
Linux agpgart interface v0.102
Serial: 8250/16550 driver $Revision: 1.90 $ 4 ports, IRQ sharing enabled
serial8250: ttyS0 at I/O 0x3f8 (irq = 4) is a 16550A
pnp: the driver 'serial' has been registered
pnp: match found with the PnP device '00:06' and the driver 'serial'
00:06: ttyS0 at I/O 0x3f8 (irq = 4) is a 16550A
RAMDISK driver initialized: 16 RAM disks of 65536K size 1024 blocksize
pnp: the driver 'i8042 kbd' has been registered
pnp: match found with the PnP device '00:0c' and the driver 'i8042 kbd'
pnp: the driver 'i8042 aux' has been registered
pnp: match found with the PnP device '00:0d' and the driver 'i8042 aux'
PNP: PS/2 Controller [PNP0303:PS2K,PNP0f03:PS2M] at 0x60,0x64 irq 1,12
serio: i8042 KBD port at 0x60,0x64 irq 1
serio: i8042 AUX port at 0x60,0x64 irq 12
mice: PS/2 mouse device common for all mice
TCP bic registered
NET: Registered protocol family 1
NET: Registered protocol family 17
Freeing unused kernel memory: 304k freed
input: AT Translated Set 2 keyboard as /class/input/input0
ACPI Exception (processor_core-0797): AE_NOT_FOUND, Processor Device is not present [20070126]
ACPI Exception (processor_core-0797): AE_NOT_FOUND, Processor Device is not present [20070126]
USB Universal Host Controller Interface driver v3.0
ACPI: PCI Interrupt 0000:00:1a.0[A] -> GSI 16 (level, low) -> IRQ 16
PCI: Setting latency timer of device 0000:00:1a.0 to 64
uhci_hcd 0000:00:1a.0: UHCI Host Controller
uhci_hcd 0000:00:1a.0: new USB bus registered, assigned bus number 1
uhci_hcd 0000:00:1a.0: irq 16, io base 0x0000e000
usb usb1: configuration #1 chosen from 1 choice
hub 1-0:1.0: USB hub found
hub 1-0:1.0: 2 ports detected
Uniform Multi-Platform E-IDE driver Revision: 7.00alpha2
ide: Assuming 33MHz system bus speed for PIO modes; override with idebus=xx
pnp: the driver 'ide' has been registered
Floppy drive(s): fd0 is 1.44M
SCSI subsystem initialized
libata version 2.21 loaded.
FDC 0 is a post-1991 82077
ACPI: PCI Interrupt 0000:00:1a.1[B] -> GSI 17 (level, low) -> IRQ 17
PCI: Setting latency timer of device 0000:00:1a.1 to 64
uhci_hcd 0000:00:1a.1: UHCI Host Controller
uhci_hcd 0000:00:1a.1: new USB bus registered, assigned bus number 2
uhci_hcd 0000:00:1a.1: irq 17, io base 0x0000e080
usb usb2: configuration #1 chosen from 1 choice
hub 2-0:1.0: USB hub found
hub 2-0:1.0: 2 ports detected
ACPI: PCI Interrupt 0000:00:1d.0[A] -> GSI 23 (level, low) -> IRQ 23
PCI: Setting latency timer of device 0000:00:1d.0 to 64
uhci_hcd 0000:00:1d.0: UHCI Host Controller
uhci_hcd 0000:00:1d.0: new USB bus registered, assigned bus number 3
uhci_hcd 0000:00:1d.0: irq 23, io base 0x0000d800
usb usb3: configuration #1 chosen from 1 choice
hub 3-0:1.0: USB hub found
hub 3-0:1.0: 2 ports detected
ACPI: PCI Interrupt 0000:00:1d.1[B] -> GSI 19 (level, low) -> IRQ 19
PCI: Setting latency timer of device 0000:00:1d.1 to 64
uhci_hcd 0000:00:1d.1: UHCI Host Controller
uhci_hcd 0000:00:1d.1: new USB bus registered, assigned bus number 4
uhci_hcd 0000:00:1d.1: irq 19, io base 0x0000d880
usb usb4: configuration #1 chosen from 1 choice
hub 4-0:1.0: USB hub found
hub 4-0:1.0: 2 ports detected
ACPI: PCI Interrupt 0000:00:1d.2[C] -> GSI 18 (level, low) -> IRQ 18
PCI: Setting latency timer of device 0000:00:1d.2 to 64
uhci_hcd 0000:00:1d.2: UHCI Host Controller
uhci_hcd 0000:00:1d.2: new USB bus registered, assigned bus number 5
uhci_hcd 0000:00:1d.2: irq 18, io base 0x0000dc00
usb usb5: configuration #1 chosen from 1 choice
hub 5-0:1.0: USB hub found
hub 5-0:1.0: 2 ports detected
ACPI: PCI Interrupt 0000:04:04.0[A] -> GSI 19 (level, low) -> IRQ 19
PCI: Unable to reserve mem region #1:4000@ff9f8000 for device 0000:04:04.0
skge 0000:04:04.0: cannot obtain PCI resources
ACPI: PCI interrupt for device 0000:04:04.0 disabled
skge: probe of 0000:04:04.0 failed with error -16
ACPI: PCI Interrupt 0000:04:03.0[A] -> GSI 21 (level, low) -> IRQ 21
firewire_ohci: Added fw-ohci device 0000:04:03.0, OHCI version 1.10
ahci 0000:00:1f.2: version 2.3
ACPI: PCI Interrupt 0000:00:1f.2[B] -> GSI 19 (level, low) -> IRQ 19
firewire_core: created new fw device fw0 (0 config rom retries, S400)
ahci 0000:00:1f.2: AHCI 0001.0100 32 slots 4 ports 3 Gbps 0x33 impl SATA mode
ahci 0000:00:1f.2: flags: 64bit ncq sntf ilck stag pm led clo pmp pio slum part 
PCI: Setting latency timer of device 0000:00:1f.2 to 64
scsi0 : ahci
scsi1 : ahci
scsi2 : ahci
scsi3 : ahci
scsi4 : ahci
scsi5 : ahci
ata1: SATA max UDMA/133 cmd 0xffffc20000ac2900 ctl 0x0000000000000000 bmdma 0x0000000000000000 irq 1276
ata2: SATA max UDMA/133 cmd 0xffffc20000ac2980 ctl 0x0000000000000000 bmdma 0x0000000000000000 irq 1276
ata3: DUMMY
ata4: DUMMY
ata5: SATA max UDMA/133 cmd 0xffffc20000ac2b00 ctl 0x0000000000000000 bmdma 0x0000000000000000 irq 1276
ata6: SATA max UDMA/133 cmd 0xffffc20000ac2b80 ctl 0x0000000000000000 bmdma 0x0000000000000000 irq 1276
ata1: SATA link up 3.0 Gbps (SStatus 123 SControl 300)
ata1.00: ATA-7: SAMSUNG HD401LJ, ZZ100-15, max UDMA7
ata1.00: 781422768 sectors, multi 0: LBA48 NCQ (not used)
ata1.00: configured for UDMA/133
ata2: SATA link up 1.5 Gbps (SStatus 113 SControl 300)
ata2.00: ATAPI: HL-DT-STDVD-RAM GSA-H30N, 1.01, max UDMA/100
ata2.00: configured for UDMA/100
ata5: SATA link down (SStatus 0 SControl 300)
ata6: SATA link down (SStatus 0 SControl 300)
scsi 0:0:0:0: Direct-Access     ATA      SAMSUNG HD401LJ  ZZ10 PQ: 0 ANSI: 5
scsi 1:0:0:0: CD-ROM            HL-DT-ST DVD-RAM GSA-H30N 1.01 PQ: 0 ANSI: 5
ACPI: PCI Interrupt 0000:02:00.0[A] -> GSI 16 (level, low) -> IRQ 16
ACPI: PCI Interrupt 0000:00:1a.7[C] -> GSI 18 (level, low) -> IRQ 18
PCI: Setting latency timer of device 0000:00:1a.7 to 64
ehci_hcd 0000:00:1a.7: EHCI Host Controller
ehci_hcd 0000:00:1a.7: new USB bus registered, assigned bus number 6
ehci_hcd 0000:00:1a.7: debug port 1
PCI: cache line size of 32 is not supported by device 0000:00:1a.7
ehci_hcd 0000:00:1a.7: irq 18, io mem 0xffaff000
ehci_hcd 0000:00:1a.7: USB 2.0 started, EHCI 1.00, driver 10 Dec 2004
usb usb6: configuration #1 chosen from 1 choice
hub 6-0:1.0: USB hub found
hub 6-0:1.0: 4 ports detected
ahci 0000:02:00.0: AHCI 0001.0000 32 slots 2 ports 3 Gbps 0x3 impl SATA mode
ahci 0000:02:00.0: flags: 64bit ncq pm led clo pmp pio slum part 
PCI: Setting latency timer of device 0000:02:00.0 to 64
scsi6 : ahci
scsi7 : ahci
ata7: SATA max UDMA/133 cmd 0xffffc20000ac4100 ctl 0x0000000000000000 bmdma 0x0000000000000000 irq 16
ata8: SATA max UDMA/133 cmd 0xffffc20000ac4180 ctl 0x0000000000000000 bmdma 0x0000000000000000 irq 16
ata7: SATA link down (SStatus 0 SControl 300)
ata8: SATA link down (SStatus 0 SControl 300)
ACPI: PCI Interrupt 0000:00:1d.7[A] -> GSI 23 (level, low) -> IRQ 23
PCI: Setting latency timer of device 0000:00:1d.7 to 64
ehci_hcd 0000:00:1d.7: EHCI Host Controller
ehci_hcd 0000:00:1d.7: new USB bus registered, assigned bus number 7
ehci_hcd 0000:00:1d.7: debug port 1
PCI: cache line size of 32 is not supported by device 0000:00:1d.7
ehci_hcd 0000:00:1d.7: irq 23, io mem 0xffafec00
ehci_hcd 0000:00:1d.7: USB 2.0 started, EHCI 1.00, driver 10 Dec 2004
usb usb7: configuration #1 chosen from 1 choice
hub 7-0:1.0: USB hub found
hub 7-0:1.0: 6 ports detected
sd 0:0:0:0: [sda] 781422768 512-byte hardware sectors (400088 MB)
sd 0:0:0:0: [sda] Write Protect is off
sd 0:0:0:0: [sda] Mode Sense: 00 3a 00 00
sd 0:0:0:0: [sda] Write cache: enabled, read cache: enabled, doesn't support DPO or FUA
sd 0:0:0:0: [sda] 781422768 512-byte hardware sectors (400088 MB)
sd 0:0:0:0: [sda] Write Protect is off
sd 0:0:0:0: [sda] Mode Sense: 00 3a 00 00
sd 0:0:0:0: [sda] Write cache: enabled, read cache: enabled, doesn't support DPO or FUA
 sda: sda1 sda2 sda3 < sda5 sda6 sda7 >
sd 0:0:0:0: [sda] Attached SCSI disk
JMB363: IDE controller at PCI slot 0000:02:00.1
PCI: Enabling device 0000:02:00.1 (0000 -> 0001)
ACPI: PCI Interrupt 0000:02:00.1[B] -> GSI 17 (level, low) -> IRQ 17
JMB363: chipset revision 2
JMB363: 100% native mode on irq 17
PCI: Setting latency timer of device 0000:02:00.1 to 64
    ide0: BM-DMA at 0xb400-0xb407, BIOS settings: hda:DMA, hdb:DMA
    ide1: BM-DMA at 0xb408-0xb40f, BIOS settings: hdc:pio, hdd:pio
Probing IDE interface ide0...
sr0: scsi3-mmc drive: 48x/48x writer dvd-ram cd/rw xa/form2 cdda tray
Uniform CD-ROM driver Revision: 3.20
sr 1:0:0:0: Attached scsi CD-ROM sr0
sd 0:0:0:0: Attached scsi generic sg0 type 0
sr 1:0:0:0: Attached scsi generic sg1 type 5
hdb: WDC WD400BB-00AUA1, ATA DISK drive
hdb: selected mode 0x45
ide0 at 0xbc00-0xbc07,0xb882 on irq 17
Probing IDE interface ide1...
hdb: max request size: 128KiB
hdb: 78165360 sectors (40020 MB) w/2048KiB Cache, CHS=65535/16/63, UDMA(100)
hdb: cache flushes not supported
 hdb: hdb1 hdb2 < hdb5 hdb6 hdb7 hdb8 hdb9 hdb10 hdb11 >
kjournald starting.  Commit interval 5 seconds
EXT3-fs: mounted filesystem with ordered data mode.
input: PC Speaker as /class/input/input1
iTCO_wdt: Intel TCO WatchDog Timer Driver v1.02 (26-Jul-2007)
iTCO_wdt: Found a ICH8 or ICH8R TCO device (Version=2, TCOBASE=0x0860)
iTCO_wdt: initialized. heartbeat=30 sec (nowayout=0)
input: Power Button (FF) as /class/input/input2
ACPI: Power Button (FF) [PWRF]
input: Power Button (CM) as /class/input/input3
ACPI: Power Button (CM) [PWRB]
ACPI: PCI Interrupt 0000:00:1b.0[A] -> GSI 22 (level, low) -> IRQ 22
PCI: Setting latency timer of device 0000:00:1b.0 to 64
hda_codec: Unknown model for AD1988, trying auto-probe from BIOS...
Linux video capture interface: v2.00
PCI: Enabling device 0000:00:1f.3 (0001 -> 0003)
ACPI: PCI Interrupt 0000:00:1f.3[C] -> GSI 18 (level, low) -> IRQ 18
logips2pp: Detected unknown logitech mouse model 95
saa7146: register extension 'dvb'.
ACPI: PCI Interrupt 0000:04:01.0[A] -> GSI 22 (level, low) -> IRQ 22
saa7146: found saa7146 @ mem ffffc20000ace800 (revision 1, irq 22) (0x13c2,0x0003).
DVB: registering new adapter (Technotrend/Hauppauge WinTV Nexus-S rev2.X)
adapter has MAC addr = 00:d0:5c:22:68:cc
dvb-ttpci: gpioirq unknown type=0 len=0
dvb-ttpci: info @ card 0: firm f0240009, rtsl b0250018, vid 71010068, app 80002622
dvb-ttpci: firmware @ card 0 supports CI link layer interface
input: ImExPS/2 Logitech Explorer Mouse as /class/input/input4
dvb-ttpci: adac type set to 0 @ card 0
saa7146_vv: saa7146 (0): registered device video0 [v4l2]
saa7146_vv: saa7146 (0): registered device vbi0 [v4l2]
DVB: registering frontend 0 (ST STV0299 DVB-S)...
input: DVB on-card IR receiver as /class/input/input5
dvb-ttpci: found av7110-0.
EXT3 FS on sda6, internal journal
device-mapper: ioctl: 4.11.0-ioctl (2006-10-12) initialised: dm-devel@redhat.com
kjournald starting.  Commit interval 5 seconds
EXT3 FS on sda1, internal journal
EXT3-fs: mounted filesystem with ordered data mode.
kjournald starting.  Commit interval 5 seconds
EXT3-fs warning: maximal mount count reached, running e2fsck is recommended
EXT3 FS on sda7, internal journal
EXT3-fs: mounted filesystem with ordered data mode.
NET: Registered protocol family 10
lo: Disabled Privacy Extensions
pnp: the driver 'parport_pc' has been registered
lp: driver loaded but no devices found
ppdev: user-space parallel port driver
[drm] Initialized drm 1.1.0 20060810
ACPI: PCI Interrupt 0000:01:00.0[A] -> GSI 16 (level, low) -> IRQ 16
[drm] Initialized radeon 1.28.0 20060524 on minor 0
[drm] Setting GART location based on new memory map
[drm] Loading R300 Microcode
[drm] writeback test succeeded in 1 usecs

--=-1kfB3eVTCK8LrFJ0Ta0u--

