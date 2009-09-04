From: Frederik Himpe <fhimpe@telenet.be>
Subject: virtio-net: networking not working when not in promiscuous mode
Date: Fri, 4 Sep 2009 10:21:34 +0000 (UTC)
Message-ID: <h7qpne$lec$1@ger.gmane.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Cc: netdev@vger.kernel.org
To: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S933583AbZIDKVv@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On kernel 2.6.38-rc8-git1, virtio-net networking in my qemu-kvm 0.10.6 
x86_64 virtual machine is not working: dhclient eth0 just times out.

As soon as I launch tcpdump however and put eth0 in promiscuous mode, 
dhclient gets an IP and networking works fine.

virtio-net also works fine if I switch to a 2.6.29.6 based kernel.

What could be the problem?

2.6.38-rc8-git1 dmesg:

Linux version 2.6.31-0.rc8.1.1mdv (mandrake@klodia.mandriva.com) (gcc 
version 4.4.1 (GCC) ) #1 SMP Sat Aug 29 11:14:57 EDT 2009
Command line: BOOT_IMAGE=2.6.31rc8-1.1 root=UUID=9f209c38-
b252-11dd-94f3-545200386498 speedboot resume=UUID=ced15188-4ce7-4862-
be03-427ad32cf927 splash=silent vga=788
KERNEL supported cpus:
  Intel GenuineIntel
  AMD AuthenticAMD
  Centaur CentaurHauls
BIOS-provided physical RAM map:
 BIOS-e820: 0000000000000000 - 000000000009f000 (usable)
 BIOS-e820: 000000000009f000 - 00000000000a0000 (reserved)
 BIOS-e820: 00000000000e8000 - 0000000000100000 (reserved)
 BIOS-e820: 0000000000100000 - 000000001fff0000 (usable)
 BIOS-e820: 000000001fff0000 - 0000000020000000 (ACPI data)
 BIOS-e820: 00000000fffbc000 - 0000000100000000 (reserved)
DMI 2.4 present.
last_pfn = 0x1fff0 max_arch_pfn = 0x400000000
MTRR default type: write-back
MTRR fixed ranges enabled:
  00000-9FFFF write-back
  A0000-FFFFF uncachable
MTRR variable ranges enabled:
  0 base 0E0000000 mask FFFFFFFFE0000000 uncachable
  1 disabled
  2 disabled
  3 disabled
  4 disabled
  5 disabled
  6 disabled
  7 disabled
PAT not supported by CPU.
initial memory mapped : 0 - 20000000
init_memory_mapping: 0000000000000000-000000001fff0000
 0000000000 - 001fe00000 page 2M
 001fe00000 - 001fff0000 page 4k
kernel direct mapping tables up to 1fff0000 @ 8000-b000
RAMDISK: 1fbfa000 - 1ffdf21b
ACPI: RSDP 00000000000fbe30 00014 (v00 QEMU  )
ACPI: RSDT 000000001fff0000 0002C (v01 QEMU   QEMURSDT 00000001 QEMU 
00000001)
ACPI: FACP 000000001fff002c 00074 (v01 QEMU   QEMUFACP 00000001 QEMU 
00000001)
ACPI: DSDT 000000001fff0100 02540 (v01   BXPC   BXDSDT 00000001 INTL 
20061109)
ACPI: FACS 000000001fff00c0 00040
ACPI: APIC 000000001fff2640 000E0 (v01 QEMU   QEMUAPIC 00000001 QEMU 
00000001)
ACPI: Local APIC address 0xfee00000
No NUMA configuration found
Faking a node at 0000000000000000-000000001fff0000
Bootmem setup node 0 0000000000000000-000000001fff0000
  NODE_DATA [0000000000001000 - 0000000000005fff]
  bootmap [0000000000009000 -  000000000000cfff] pages 4
(7 early reservations) ==> bootmem [0000000000 - 001fff0000]
  #0 [0000000000 - 0000001000]   BIOS data page ==> [0000000000 - 
0000001000]
  #1 [0000006000 - 0000008000]       TRAMPOLINE ==> [0000006000 - 
0000008000]
  #2 [0001000000 - 0001869270]    TEXT DATA BSS ==> [0001000000 - 
0001869270]
  #3 [001fbfa000 - 001ffdf21b]          RAMDISK ==> [001fbfa000 - 
001ffdf21b]
  #4 [000009fc00 - 0000100000]    BIOS reserved ==> [000009fc00 - 
0000100000]
  #5 [000186a000 - 000186a065]              BRK ==> [000186a000 - 
000186a065]
  #6 [0000008000 - 0000009000]          PGTABLE ==> [0000008000 - 
0000009000]
found SMP MP-table at [ffff8800000fbd10] fbd10
kvm-clock: cpu 0, msr 0:16d6641, boot clock
 [ffffea0000000000-ffffea00007fffff] PMD -> [ffff880001e00000-
ffff8800025fffff] on node 0
Zone PFN ranges:
  DMA      0x00000000 -> 0x00001000
  DMA32    0x00001000 -> 0x00100000
  Normal   0x00100000 -> 0x00100000
Movable zone start PFN for each node
early_node_map[2] active PFN ranges
    0: 0x00000000 -> 0x0000009f
    0: 0x00000100 -> 0x0001fff0
On node 0 totalpages: 130959
  DMA zone: 56 pages used for memmap
  DMA zone: 100 pages reserved
  DMA zone: 3843 pages, LIFO batch:0
  DMA32 zone: 1736 pages used for memmap
  DMA32 zone: 125224 pages, LIFO batch:31
ACPI: PM-Timer IO Port: 0xb008
ACPI: Local APIC address 0xfee00000
ACPI: LAPIC (acpi_id[0x00] lapic_id[0x00] enabled)
ACPI: LAPIC (acpi_id[0x01] lapic_id[0x01] disabled)
ACPI: LAPIC (acpi_id[0x02] lapic_id[0x02] disabled)
ACPI: LAPIC (acpi_id[0x03] lapic_id[0x03] disabled)
ACPI: LAPIC (acpi_id[0x04] lapic_id[0x04] disabled)
ACPI: LAPIC (acpi_id[0x05] lapic_id[0x05] disabled)
ACPI: LAPIC (acpi_id[0x06] lapic_id[0x06] disabled)
ACPI: LAPIC (acpi_id[0x07] lapic_id[0x07] disabled)
ACPI: LAPIC (acpi_id[0x08] lapic_id[0x08] disabled)
ACPI: LAPIC (acpi_id[0x09] lapic_id[0x09] disabled)
ACPI: LAPIC (acpi_id[0x0a] lapic_id[0x0a] disabled)
ACPI: LAPIC (acpi_id[0x0b] lapic_id[0x0b] disabled)
ACPI: LAPIC (acpi_id[0x0c] lapic_id[0x0c] disabled)
ACPI: LAPIC (acpi_id[0x0d] lapic_id[0x0d] disabled)
ACPI: LAPIC (acpi_id[0x0e] lapic_id[0x0e] disabled)
ACPI: LAPIC (acpi_id[0x0f] lapic_id[0x0f] disabled)
ACPI: IOAPIC (id[0x01] address[0xfec00000] gsi_base[0])
IOAPIC[0]: apic_id 1, version 17, address 0xfec00000, GSI 0-23
ACPI: INT_SRC_OVR (bus 0 bus_irq 5 global_irq 5 high level)
ACPI: INT_SRC_OVR (bus 0 bus_irq 9 global_irq 9 high level)
ACPI: INT_SRC_OVR (bus 0 bus_irq 10 global_irq 10 high level)
ACPI: INT_SRC_OVR (bus 0 bus_irq 11 global_irq 11 high level)
ACPI: IRQ5 used by override.
ACPI: IRQ9 used by override.
ACPI: IRQ10 used by override.
ACPI: IRQ11 used by override.
Using ACPI (MADT) for SMP configuration information
SMP: Allowing 16 CPUs, 15 hotplug CPUs
nr_irqs_gsi: 24
PM: Registered nosave memory: 000000000009f000 - 00000000000a0000
PM: Registered nosave memory: 00000000000a0000 - 00000000000e8000
PM: Registered nosave memory: 00000000000e8000 - 0000000000100000
Allocating PCI resources starting at 20000000 (gap: 20000000:dffbc000)
NR_CPUS:32 nr_cpumask_bits:32 nr_cpu_ids:16 nr_node_ids:1
PERCPU: Embedded 30 pages at ffff880001872000, static data 90144 bytes
kvm-clock: cpu 0, msr 0:1887641, primary cpu clock
Built 1 zonelists in Node order, mobility grouping on.  Total pages: 
129067
Policy zone: DMA32
Kernel command line: BOOT_IMAGE=2.6.31rc8-1.1 root=UUID=9f209c38-
b252-11dd-94f3-545200386498 speedboot resume=UUID=ced15188-4ce7-4862-
be03-427ad32cf927 splash=silent vga=788
PID hash table entries: 2048 (order: 11, 16384 bytes)
Initializing CPU#0
Checking aperture...
No AGP bridge found
Calgary: detecting Calgary via BIOS EBDA area
Calgary: Unable to locate Rio Grande table in EBDA - bailing!
Memory: 500996k/524224k available (4210k kernel code, 388k absent, 22840k 
reserved, 2700k data, 648k init)
SLUB: Genslabs=14, HWalign=64, Order=0-3, MinObjects=0, CPUs=16, Nodes=1
NR_IRQS:1280
Detected 2261.412 MHz processor.
Console: colour dummy device 80x25
console [tty0] enabled
Calibrating delay loop (skipped) preset value.. 4522.82 BogoMIPS 
(lpj=2261412)
Security Framework initialized
TOMOYO Linux initialized
Dentry cache hash table entries: 65536 (order: 7, 524288 bytes)
Inode-cache hash table entries: 32768 (order: 6, 262144 bytes)
Mount-cache hash table entries: 256
CPU: L1 I cache: 32K, L1 D cache: 32K
CPU: L2 cache: 2048K
CPU 0/0x0 -> Node 0
mce: CPU supports 0 MCE banks
Performance Counters: unsupported p6 CPU model 2 no PMU driver, software 
counters only.
SMP alternatives: switching to UP code
ACPI: Core revision 20090521
ftrace: converting mcount calls to 0f 1f 44 00 00
ftrace: allocating 14592 entries in 58 pages
Setting APIC routing to flat
..TIMER: vector=0x30 apic1=0 pin1=0 apic2=-1 pin2=-1
CPU0: Intel QEMU Virtual CPU version 0.10.6 stepping 03
Brought up 1 CPUs
Total of 1 processors activated (4522.82 BogoMIPS).
CPU0 attaching NULL sched-domain.
Booting paravirtualized kernel on KVM
Time: 10:09:33  Date: 09/04/09
NET: Registered protocol family 16
ACPI: bus type pci registered
PCI: Using configuration type 1 for base access
bio: create slab <bio-0> at 0
ACPI: EC: Look up EC in DSDT
ACPI: Interpreter enabled
ACPI: (supports S0 S3 S4 S5)
ACPI: Using IOAPIC for interrupt routing
ACPI: No dock devices found.
ACPI: PCI Root Bridge [PCI0] (0000:00)
pci 0000:00:01.1: reg 20 io port: [0xc000-0xc00f]
pci 0000:00:01.2: reg 20 io port: [0xc020-0xc03f]
pci 0000:00:01.3: quirk: region b000-b03f claimed by PIIX4 ACPI
pci 0000:00:01.3: quirk: region b100-b10f claimed by PIIX4 SMB
pci 0000:00:02.0: reg 10 32bit mmio: [0xf0000000-0xf1ffffff]
pci 0000:00:02.0: reg 14 32bit mmio: [0xf2000000-0xf2000fff]
pci 0000:00:03.0: reg 10 io port: [0xc040-0xc05f]
pci 0000:00:04.0: reg 10 io port: [0xc080-0xc0bf]
pci 0000:00:05.0: reg 10 io port: [0xc0c0-0xc0df]
ACPI: PCI Interrupt Routing Table [\_SB_.PCI0._PRT]
ACPI: PCI Interrupt Link [LNKA] (IRQs 5 *10 11)
ACPI: PCI Interrupt Link [LNKB] (IRQs 5 *10 11)
ACPI: PCI Interrupt Link [LNKC] (IRQs 5 10 *11)
ACPI: PCI Interrupt Link [LNKD] (IRQs 5 10 *11)
PCI: Using ACPI for IRQ routing
NetLabel: Initializing
NetLabel:  domain hash size = 128
NetLabel:  protocols = UNLABELED CIPSOv4
NetLabel:  unlabeled traffic allowed by default
Switched to high resolution mode on CPU 0
pnp: PnP ACPI init
ACPI: bus type pnp registered
pnp: PnP ACPI: found 6 devices
ACPI: ACPI bus type pnp unregistered
pci_bus 0000:00: resource 0 io:  [0x00-0xffff]
pci_bus 0000:00: resource 1 mem: [0x000000-0xffffffffffffffff]
NET: Registered protocol family 2
IP route cache hash table entries: 4096 (order: 3, 32768 bytes)
TCP established hash table entries: 16384 (order: 6, 262144 bytes)
TCP bind hash table entries: 16384 (order: 6, 262144 bytes)
TCP: Hash tables configured (established 16384 bind 16384)
TCP reno registered
NET: Registered protocol family 1
Trying to unpack rootfs image as initramfs...
Freeing initrd memory: 3988k freed
audit: initializing netlink socket (disabled)
type=2000 audit(1252058974.255:1): initialized
HugeTLB registered 2 MB page size, pre-allocated 0 pages
VFS: Disk quotas dquot_6.5.2
Dquot-cache hash table entries: 512 (order 0, 4096 bytes)
msgmni has been set to 986
alg: No test for stdrng (krng)
Block layer SCSI generic (bsg) driver version 0.4 loaded (major 253)
io scheduler noop registered
io scheduler anticipatory registered
io scheduler deadline registered
io scheduler cfq registered (default)
pci 0000:00:00.0: Limiting direct PCI/PCI transfers
pci 0000:00:01.0: PIIX3: Enabling Passive Release
pci 0000:00:01.0: Activating ISA DMA hang workarounds
pci 0000:00:02.0: Boot video device
vesafb: framebuffer at 0xf0000000, mapped to 0xffffc90000180000, using 
1875k, total 4096k
vesafb: mode is 800x600x16, linelength=1600, pages=3
vesafb: scrolling: redraw
vesafb: Truecolor: size=0:5:6:5, shift=0:11:5:0
Console: switching to colour frame buffer device 100x37
fb0: VESA VGA frame buffer device
Linux agpgart interface v0.103
Serial: 8250/16550 driver, 4 ports, IRQ sharing enabled
serial8250: ttyS0 at I/O 0x3f8 (irq = 4) is a 16550A
00:05: ttyS0 at I/O 0x3f8 (irq = 4) is a 16550A
brd: module loaded
input: Macintosh mouse button emulation as /devices/virtual/input/input0
PNP: PS/2 Controller [PNP0303:KBD,PNP0f13:MOU] at 0x60,0x64 irq 1,12
serio: i8042 KBD port at 0x60,0x64 irq 1
serio: i8042 AUX port at 0x60,0x64 irq 12
mice: PS/2 mouse device common for all mice
input: AT Translated Set 2 keyboard as /devices/platform/i8042/serio0/
input/input1
cpuidle: using governor ladder
cpuidle: using governor menu
TCP cubic registered
PM: Checking image partition UUID=ced15188-4ce7-4862-be03-427ad32cf927
input: ImExPS/2 Generic Explorer Mouse as /devices/platform/i8042/serio1/
input/input2
PM: Resume from disk failed.
registered taskstats version 1
  Magic number: 9:991:172
BIOS EDD facility v0.16 2004-Jun-25, 1 devices found
Freeing unused kernel memory: 648k freed
Clocksource tsc unstable (delta = -152616453 ns)
ACPI: PCI Interrupt Link [LNKC] enabled at IRQ 11
virtio-pci 0000:00:03.0: PCI INT A -> Link[LNKC] -> GSI 11 (level, high) -
> IRQ 11
ACPI: PCI Interrupt Link [LNKD] enabled at IRQ 10
virtio-pci 0000:00:04.0: PCI INT A -> Link[LNKD] -> GSI 10 (level, high) -
> IRQ 10
ACPI: PCI Interrupt Link [LNKA] enabled at IRQ 10
virtio-pci 0000:00:05.0: PCI INT A -> Link[LNKA] -> GSI 10 (level, high) -
> IRQ 10
 vda: vda1 vda2 < vda5 >
SCSI subsystem initialized
libata version 3.00 loaded.
ata_piix 0000:00:01.1: version 2.13
ata_piix 0000:00:01.1: setting latency timer to 64
scsi0 : ata_piix
scsi1 : ata_piix
ata1: PATA max MWDMA2 cmd 0x1f0 ctl 0x3f6 bmdma 0xc000 irq 14
ata2: PATA max MWDMA2 cmd 0x170 ctl 0x376 bmdma 0xc008 irq 15
ata2.01: NODEV after polling detection
ata2.00: ATAPI: QEMU DVD-ROM, 0.10.6, max UDMA/100
ata2.00: configured for MWDMA2
scsi 1:0:0:0: CD-ROM            QEMU     QEMU DVD-ROM     0.10 PQ: 0 
ANSI: 5
Uniform Multi-Platform E-IDE driver
ide_generic: please use "probe_mask=0x3f" module parameter for probing 
all legacy ISA IDE ports
PM: Marking nosave pages: 000000000009f000 - 0000000000100000
PM: Basic memory bitmaps created
PM: Basic memory bitmaps freed
kjournald starting.  Commit interval 5 seconds
EXT3-fs: mounted filesystem with writeback data mode.
Not activating Mandatory Access Control now since /sbin/tomoyo-init 
doesn't exist.
usbcore: registered new interface driver usbfs
usbcore: registered new interface driver hub
usbcore: registered new device driver usb
udev: starting version 146
processor LNXCPU:00: registered as cooling_device0
input: Power Button as /devices/LNXSYSTM:00/LNXPWRBN:00/input/input3
ACPI: Power Button [PWRF]
rtc_cmos 00:01: rtc core: registered rtc_cmos as rtc0
rtc0: alarms up to one day, 114 bytes nvram
uhci_hcd: USB Universal Host Controller Interface driver
uhci_hcd 0000:00:01.2: PCI INT D -> Link[LNKD] -> GSI 10 (level, high) -> 
IRQ 10
uhci_hcd 0000:00:01.2: setting latency timer to 64
uhci_hcd 0000:00:01.2: UHCI Host Controller
uhci_hcd 0000:00:01.2: new USB bus registered, assigned bus number 1
uhci_hcd 0000:00:01.2: irq 10, io base 0x0000c020
usb usb1: New USB device found, idVendor=1d6b, idProduct=0001
usb usb1: New USB device strings: Mfr=3, Product=2, SerialNumber=1
usb usb1: Product: UHCI Host Controller
usb usb1: Manufacturer: Linux 2.6.31-0.rc8.1.1mdv uhci_hcd
usb usb1: SerialNumber: 0000:00:01.2
usb usb1: configuration #1 chosen from 1 choice
hub 1-0:1.0: USB hub found
hub 1-0:1.0: 2 ports detected
input: PC Speaker as /devices/platform/pcspkr/input/input4
piix4_smbus 0000:00:01.3: SMBus Host Controller at 0xb100, revision 0
FDC 0 is a S82078B
sr0: scsi3-mmc drive: 4x/4x xa/form2 tray
Uniform CD-ROM driver Revision: 3.20
sr 1:0:0:0: Attached scsi CD-ROM sr0
sr 1:0:0:0: Attached scsi generic sg0 type 5
usb 1-2: new full speed USB device using uhci_hcd and address 2
usb 1-2: New USB device found, idVendor=0627, idProduct=0001
usb 1-2: New USB device strings: Mfr=3, Product=2, SerialNumber=1
usb 1-2: Product: QEMU USB Tablet
usb 1-2: Manufacturer: QEMU 0.10.6
usb 1-2: SerialNumber: 1
usb 1-2: configuration #1 chosen from 1 choice
usbcore: registered new interface driver hiddev
input: QEMU 0.10.6 QEMU USB Tablet as /devices/pci0000:00/0000:00:01.2/
usb1/1-2/1-2:1.0/input/input5
generic-usb 0003:0627:0001.0001: input,hidraw0: USB HID v0.01 Pointer 
[QEMU 0.10.6 QEMU USB Tablet] on usb-0000:00:01.2-2/input0
usbcore: registered new interface driver usbhid
usbhid: v2.6:USB HID core driver
device-mapper: uevent: version 1.0.3
device-mapper: ioctl: 4.15.0-ioctl (2009-04-01) initialised: dm-
devel@redhat.com
EXT3 FS on vda5, internal journal
loop: module loaded
Adding 763048k swap on /dev/vda1.  Priority:-1 extents:1 across:763048k SS
NET: Registered protocol family 10
lo: Disabled Privacy Extensions
mtrr: no MTRR for f0000000,100000 found
NET: Registered protocol family 17
eth0: no IPv6 routers present
fuse init (API version 7.12)
ISO 9660 Extensions: Microsoft Joliet Level 3
ISOFS: changing to secondary root
device eth0 entered promiscuous mode
