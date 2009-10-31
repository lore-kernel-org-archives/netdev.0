From: Frans Pop <elendil@planet.nl>
Subject: Re: large packet loss take2 2.6.31.x
Date: Sat, 31 Oct 2009 19:44:35 +0100
Message-ID: <200910311944.35922.elendil@planet.nl>
References: <81bfc67a0910310721p21046931o9b512cfd0a8a7acb@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Multipart/Mixed;
  boundary="Boundary-00=_TWI7KJq6CFmNaNG"
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Caleb Cushing <xenoterracide@gmail.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S933093AbZJaSof@vger.kernel.org>
In-reply-To: <81bfc67a0910310721p21046931o9b512cfd0a8a7acb@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--Boundary-00=_TWI7KJq6CFmNaNG
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

Adding netdev in CC. Original message + attachments follow.

=========
so ever since arch rolled out 2.6.31.x I've been having problems with
my network (again) where I've been losing a large amount of packets
(just testing with mtr somewhere between 30/50%). first I figured it
was the same problem as I had in 2.6.30.x (and maybe it is?) but that
appeared to get fixed. when I started bisecting the bug wasn't
apparent in 2.6.31.0 but I knew for sure it was in .5 (I couldn't
remember if I had noticed it again in .3)

I'm attaching the bisection log and a 'good' dmesg output.

c9fb3ded7a8a6769f3bcb3ef3d9aed61d3e376a9 is the first bad commit

I'm not going to pretend to understand why this patch is breaking my
networking but between bisection and testing it appears to be... I've
never bisected before and I'm definitely not a kernel hacker (I can
barely read C).

I should also note that the wireshark dump here
http://bugzilla.kernel.org/show_bug.cgi?id=13835 is related to this.
and if it's not the same bug then possibly a new one should be opened.

P.S. I'm not subscribed to the list please CC me

Caleb Cushing
http://xenoterracide.blogspot.com


--Boundary-00=_TWI7KJq6CFmNaNG
Content-Type: text/x-log;
  charset="us-ascii";
  name="bisect.log"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
	filename="bisect.log"

# bad: [e2984cbfddd5c8fac88b24d7e5f28e1cfb6f3838] Linux 2.6.31.5
# good: [74fca6a42863ffacaf7ba6f1936a9f228950f657] Linux 2.6.31
git bisect start 'v2.6.31.5' 'v2.6.31' '--'
# good: [08f30ff9811e59c08d1cee043ce55b2e862efe58] tty: USB hangup is racy
git bisect good 08f30ff9811e59c08d1cee043ce55b2e862efe58
# bad: [ddf2acb72f3df470ce15eb23ee97cd3be23016f8] KVM: fix LAPIC timer period overflow
git bisect bad ddf2acb72f3df470ce15eb23ee97cd3be23016f8
# bad: [03429ffaea91375d8ed80a60fa13c9ffe694539a] Fix idle time field in /proc/uptime
git bisect bad 03429ffaea91375d8ed80a60fa13c9ffe694539a
# bad: [2f670d465897b491da0b82fd8b047b9ec75bf8c8] USB: xhci: Support full speed devices.
git bisect bad 2f670d465897b491da0b82fd8b047b9ec75bf8c8
# bad: [b8580fde3ba44a0f00bf186dc5e4935bbd51be29] usb-serial: fix termios initialization logic
git bisect bad b8580fde3ba44a0f00bf186dc5e4935bbd51be29
# bad: [c9fb3ded7a8a6769f3bcb3ef3d9aed61d3e376a9] usb-serial: change referencing of port and serial structures
git bisect bad c9fb3ded7a8a6769f3bcb3ef3d9aed61d3e376a9
# good: [fa31221e38207cece07a6d96854a0fcf47c75ae5] hwmon: (asus_atk0110) Add maintainer information
git bisect good fa31221e38207cece07a6d96854a0fcf47c75ae5
# good: [17fd426331d1e4611654985dd545a52d200dd9d1] tty: USB serial termios bits
git bisect good 17fd426331d1e4611654985dd545a52d200dd9d1

--Boundary-00=_TWI7KJq6CFmNaNG
Content-Type: text/x-log;
  charset="us-ascii";
  name="dmesg.log"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
	filename="dmesg.log"

Linux version 2.6.31.1-test-00092-g17fd426 (xenoterracide@slave4) (gcc version 4.4.2 (GCC) ) #15 SMP PREEMPT Sat Oct 31 09:54:39 EDT 2009
Command line: root=/dev/disk/by-uuid/e9367b57-da02-48bf-9cd7-d41ce53520a3 ro
KERNEL supported cpus:
  Intel GenuineIntel
  AMD AuthenticAMD
  Centaur CentaurHauls
BIOS-provided physical RAM map:
 BIOS-e820: 0000000000000000 - 0000000000099c00 (usable)
 BIOS-e820: 0000000000099c00 - 00000000000a0000 (reserved)
 BIOS-e820: 00000000000f0000 - 0000000000100000 (reserved)
 BIOS-e820: 0000000000100000 - 00000000cf590000 (usable)
 BIOS-e820: 00000000cf590000 - 00000000cf5e3000 (ACPI NVS)
 BIOS-e820: 00000000cf5e3000 - 00000000cf5f0000 (ACPI data)
 BIOS-e820: 00000000cf5f0000 - 00000000cf600000 (reserved)
 BIOS-e820: 00000000e0000000 - 00000000f0000000 (reserved)
 BIOS-e820: 00000000fec00000 - 0000000100000000 (reserved)
 BIOS-e820: 0000000100000000 - 00000001b0000000 (usable)
DMI 2.5 present.
last_pfn = 0x1b0000 max_arch_pfn = 0x400000000
MTRR default type: uncachable
MTRR fixed ranges enabled:
  00000-9FFFF write-back
  A0000-BFFFF uncachable
  C0000-E7FFF write-protect
  E8000-EFFFF uncachable
  F0000-FFFFF write-through
MTRR variable ranges enabled:
  0 base 100000000 mask F80000000 write-back
  1 base 180000000 mask FE0000000 write-back
  2 base 1A0000000 mask FF0000000 write-back
  3 base 000000000 mask F80000000 write-back
  4 base 080000000 mask FC0000000 write-back
  5 base 0C0000000 mask FF0000000 write-back
  6 base 0CF700000 mask FFFF00000 uncachable
  7 base 0CF800000 mask FFF800000 uncachable
x86 PAT enabled: cpu 0, old 0x7040600070406, new 0x7010600070106
e820 update range: 00000000cf700000 - 0000000100000000 (usable) ==> (reserved)
last_pfn = 0xcf590 max_arch_pfn = 0x400000000
e820 update range: 0000000000001000 - 0000000000006000 (usable) ==> (reserved)
Scanning 1 areas for low memory corruption
modified physical RAM map:
 modified: 0000000000000000 - 0000000000001000 (usable)
 modified: 0000000000001000 - 0000000000006000 (reserved)
 modified: 0000000000006000 - 0000000000099c00 (usable)
 modified: 0000000000099c00 - 00000000000a0000 (reserved)
 modified: 00000000000f0000 - 0000000000100000 (reserved)
 modified: 0000000000100000 - 00000000cf590000 (usable)
 modified: 00000000cf590000 - 00000000cf5e3000 (ACPI NVS)
 modified: 00000000cf5e3000 - 00000000cf5f0000 (ACPI data)
 modified: 00000000cf5f0000 - 00000000cf600000 (reserved)
 modified: 00000000e0000000 - 00000000f0000000 (reserved)
 modified: 00000000fec00000 - 0000000100000000 (reserved)
 modified: 0000000100000000 - 00000001b0000000 (usable)
initial memory mapped : 0 - 20000000
init_memory_mapping: 0000000000000000-00000000cf590000
 0000000000 - 00cf400000 page 2M
 00cf400000 - 00cf590000 page 4k
kernel direct mapping tables up to cf590000 @ 8000-e000
init_memory_mapping: 0000000100000000-00000001b0000000
 0100000000 - 01b0000000 page 2M
kernel direct mapping tables up to 1b0000000 @ c000-14000
RAMDISK: 37ef1000 - 37fef9a7
ACPI: RSDP 00000000000f97a0 00024 (v02 DELL  )
ACPI: XSDT 00000000cf5e3080 0005C (v01 DELL    FX09    42302E31 AWRD 00000000)
ACPI: FACP 00000000cf5e7200 000F4 (v03 DELL    FX09    42302E31 AWRD 00000000)
ACPI: DSDT 00000000cf5e3200 03FFC (v01 DELL   AWRDACPI 00001000 MSFT 03000000)
ACPI: FACS 00000000cf590000 00040
ACPI: HPET 00000000cf5e73c0 00038 (v01 DELL    FX09    42302E31 AWRD 00000098)
ACPI: MCFG 00000000cf5e7400 0003C (v01 DELL    FX09    42302E31 AWRD 00000000)
ACPI: DMY1 00000000cf5e7440 00176 (v01 DELL    FX09    42302E31 AWRD 00000000)
ACPI: DMY2 00000000cf5e75c0 00080 (v01 DELL    FX09    42302E31 AWRD 00000000)
ACPI: APIC 00000000cf5e7300 00084 (v01 DELL    FX09    42302E31 AWRD 00000000)
ACPI: SSDT 00000000cf5e7f60 00380 (v01  PmRef    CpuPm 00003000 INTL 20041203)
ACPI: Local APIC address 0xfee00000
(8 early reservations) ==> bootmem [0000000000 - 01b0000000]
  #0 [0000000000 - 0000001000]   BIOS data page ==> [0000000000 - 0000001000]
  #1 [0000006000 - 0000008000]       TRAMPOLINE ==> [0000006000 - 0000008000]
  #2 [0001000000 - 00016837d0]    TEXT DATA BSS ==> [0001000000 - 00016837d0]
  #3 [0037ef1000 - 0037fef9a7]          RAMDISK ==> [0037ef1000 - 0037fef9a7]
  #4 [0000099c00 - 0000100000]    BIOS reserved ==> [0000099c00 - 0000100000]
  #5 [0001684000 - 00016840f8]              BRK ==> [0001684000 - 00016840f8]
  #6 [0000008000 - 000000c000]          PGTABLE ==> [0000008000 - 000000c000]
  #7 [000000c000 - 000000f000]          PGTABLE ==> [000000c000 - 000000f000]
found SMP MP-table at [ffff8800000f3f00] f3f00
 [ffffea0000000000-ffffea0005ffffff] PMD -> [ffff880028600000-ffff88002dbfffff] on node 0
Zone PFN ranges:
  DMA      0x00000000 -> 0x00001000
  DMA32    0x00001000 -> 0x00100000
  Normal   0x00100000 -> 0x001b0000
Movable zone start PFN for each node
early_node_map[4] active PFN ranges
    0: 0x00000000 -> 0x00000001
    0: 0x00000006 -> 0x00000099
    0: 0x00000100 -> 0x000cf590
    0: 0x00100000 -> 0x001b0000
On node 0 totalpages: 1570084
  DMA zone: 56 pages used for memmap
  DMA zone: 112 pages reserved
  DMA zone: 3820 pages, LIFO batch:0
  DMA32 zone: 14280 pages used for memmap
  DMA32 zone: 830920 pages, LIFO batch:31
  Normal zone: 9856 pages used for memmap
  Normal zone: 711040 pages, LIFO batch:31
ACPI: PM-Timer IO Port: 0x408
ACPI: Local APIC address 0xfee00000
ACPI: LAPIC (acpi_id[0x00] lapic_id[0x00] enabled)
ACPI: LAPIC (acpi_id[0x01] lapic_id[0x01] enabled)
ACPI: LAPIC (acpi_id[0x02] lapic_id[0x03] enabled)
ACPI: LAPIC (acpi_id[0x03] lapic_id[0x02] enabled)
ACPI: LAPIC_NMI (acpi_id[0x00] high edge lint[0x1])
ACPI: LAPIC_NMI (acpi_id[0x01] high edge lint[0x1])
ACPI: LAPIC_NMI (acpi_id[0x02] high edge lint[0x1])
ACPI: LAPIC_NMI (acpi_id[0x03] high edge lint[0x1])
ACPI: IOAPIC (id[0x04] address[0xfec00000] gsi_base[0])
IOAPIC[0]: apic_id 4, version 32, address 0xfec00000, GSI 0-23
ACPI: INT_SRC_OVR (bus 0 bus_irq 0 global_irq 2 dfl dfl)
ACPI: INT_SRC_OVR (bus 0 bus_irq 9 global_irq 9 high level)
ACPI: IRQ0 used by override.
ACPI: IRQ2 used by override.
ACPI: IRQ9 used by override.
Using ACPI (MADT) for SMP configuration information
ACPI: HPET id: 0x8086a201 base: 0xfed00000
SMP: Allowing 4 CPUs, 0 hotplug CPUs
nr_irqs_gsi: 24
PM: Registered nosave memory: 0000000000001000 - 0000000000006000
PM: Registered nosave memory: 0000000000099000 - 000000000009a000
PM: Registered nosave memory: 000000000009a000 - 00000000000a0000
PM: Registered nosave memory: 00000000000a0000 - 00000000000f0000
PM: Registered nosave memory: 00000000000f0000 - 0000000000100000
PM: Registered nosave memory: 00000000cf590000 - 00000000cf5e3000
PM: Registered nosave memory: 00000000cf5e3000 - 00000000cf5f0000
PM: Registered nosave memory: 00000000cf5f0000 - 00000000cf600000
PM: Registered nosave memory: 00000000cf600000 - 00000000e0000000
PM: Registered nosave memory: 00000000e0000000 - 00000000f0000000
PM: Registered nosave memory: 00000000f0000000 - 00000000fec00000
PM: Registered nosave memory: 00000000fec00000 - 0000000100000000
Allocating PCI resources starting at cf600000 (gap: cf600000:10a00000)
NR_CPUS:16 nr_cpumask_bits:16 nr_cpu_ids:4 nr_node_ids:1
PERCPU: Embedded 28 pages at ffff880028034000, static data 82400 bytes
Built 1 zonelists in Zone order, mobility grouping on.  Total pages: 1545780
Kernel command line: root=/dev/disk/by-uuid/e9367b57-da02-48bf-9cd7-d41ce53520a3 ro
PID hash table entries: 4096 (order: 12, 32768 bytes)
Dentry cache hash table entries: 1048576 (order: 11, 8388608 bytes)
Inode-cache hash table entries: 524288 (order: 10, 4194304 bytes)
Initializing CPU#0
Checking aperture...
No AGP bridge found
Calgary: detecting Calgary via BIOS EBDA area
Calgary: Unable to locate Rio Grande table in EBDA - bailing!
PCI-DMA: Using software bounce buffering for IO (SWIOTLB)
Placing 64MB software IO TLB between ffff880020000000 - ffff880024000000
software IO TLB at phys 0x20000000 - 0x24000000
Memory: 6104592k/7077888k available (3629k kernel code, 797552k absent, 174760k reserved, 1500k data, 484k init)
SLUB: Genslabs=13, HWalign=64, Order=0-3, MinObjects=0, CPUs=4, Nodes=1
NR_IRQS:768
Fast TSC calibration using PIT
Detected 2393.837 MHz processor.
Console: colour VGA+ 80x25
console [tty0] enabled
hpet clockevent registered
HPET: 4 timers in total, 0 timers will be used for per-cpu timer
Calibrating delay loop (skipped), value calculated using timer frequency.. 4789.16 BogoMIPS (lpj=7979456)
Security Framework initialized
Mount-cache hash table entries: 256
CPU: L1 I cache: 32K, L1 D cache: 32K
CPU: L2 cache: 4096K
CPU: Physical Processor ID: 0
CPU: Processor Core ID: 0
mce: CPU supports 6 MCE banks
CPU0: Thermal monitoring enabled (TM2)
using mwait in idle threads.
Performance Counters: Core2 events, Intel PMU driver.
... version:                 2
... bit width:               40
... generic counters:        2
... value mask:              000000ffffffffff
... max period:              000000007fffffff
... fixed-purpose counters:  3
... counter mask:            0000000700000003
ACPI: Core revision 20090521
Setting APIC routing to flat
..TIMER: vector=0x30 apic1=0 pin1=2 apic2=-1 pin2=-1
CPU0: Intel(R) Core(TM)2 Quad CPU    Q6600  @ 2.40GHz stepping 0b
Booting processor 1 APIC 0x1 ip 0x6000
Initializing CPU#1
Calibrating delay using timer specific routine.. 4789.48 BogoMIPS (lpj=7979981)
CPU: L1 I cache: 32K, L1 D cache: 32K
CPU: L2 cache: 4096K
CPU: Physical Processor ID: 0
CPU: Processor Core ID: 1
mce: CPU supports 6 MCE banks
CPU1: Thermal monitoring enabled (TM2)
x86 PAT enabled: cpu 1, old 0x7040600070406, new 0x7010600070106
CPU1: Intel(R) Core(TM)2 Quad CPU    Q6600  @ 2.40GHz stepping 0b
checking TSC synchronization [CPU#0 -> CPU#1]: passed.
Booting processor 2 APIC 0x3 ip 0x6000
Initializing CPU#2
Calibrating delay using timer specific routine.. 4789.51 BogoMIPS (lpj=7980021)
CPU: L1 I cache: 32K, L1 D cache: 32K
CPU: L2 cache: 4096K
CPU: Physical Processor ID: 0
CPU: Processor Core ID: 3
mce: CPU supports 6 MCE banks
CPU2: Thermal monitoring enabled (TM2)
x86 PAT enabled: cpu 2, old 0x7040600070406, new 0x7010600070106
CPU2: Intel(R) Core(TM)2 Quad CPU    Q6600  @ 2.40GHz stepping 0b
checking TSC synchronization [CPU#0 -> CPU#2]: passed.
Booting processor 3 APIC 0x2 ip 0x6000
Initializing CPU#3
Calibrating delay using timer specific routine.. 4789.56 BogoMIPS (lpj=7980102)
CPU: L1 I cache: 32K, L1 D cache: 32K
CPU: L2 cache: 4096K
CPU: Physical Processor ID: 0
CPU: Processor Core ID: 2
mce: CPU supports 6 MCE banks
CPU3: Thermal monitoring enabled (TM2)
x86 PAT enabled: cpu 3, old 0x7040600070406, new 0x7010600070106
CPU3: Intel(R) Core(TM)2 Quad CPU    Q6600  @ 2.40GHz stepping 0b
checking TSC synchronization [CPU#0 -> CPU#3]: passed.
Brought up 4 CPUs
Total of 4 processors activated (19159.72 BogoMIPS).
CPU0 attaching sched-domain:
 domain 0: span 0-1 level MC
  groups: 0 1
  domain 1: span 0-3 level CPU
   groups: 0-1 2-3
CPU1 attaching sched-domain:
 domain 0: span 0-1 level MC
  groups: 1 0
  domain 1: span 0-3 level CPU
   groups: 0-1 2-3
CPU2 attaching sched-domain:
 domain 0: span 2-3 level MC
  groups: 2 3
  domain 1: span 0-3 level CPU
   groups: 2-3 0-1
CPU3 attaching sched-domain:
 domain 0: span 2-3 level MC
  groups: 3 2
  domain 1: span 0-3 level CPU
   groups: 2-3 0-1
Booting paravirtualized kernel on bare hardware
NET: Registered protocol family 16
ACPI: bus type pci registered
PCI: MCFG configuration 0: base e0000000 segment 0 buses 0 - 255
PCI: MCFG area at e0000000 reserved in E820
PCI: Using MMCONFIG at e0000000 - efffffff
PCI: Using configuration type 1 for base access
mtrr: your CPUs had inconsistent fixed MTRR settings
mtrr: probably your BIOS does not setup all CPUs.
mtrr: corrected configuration.
bio: create slab <bio-0> at 0
ACPI: EC: Look up EC in DSDT
ACPI: Interpreter enabled
ACPI: (supports S0 S3 S4 S5)
ACPI: Using IOAPIC for interrupt routing
ACPI: No dock devices found.
ACPI: PCI Root Bridge [PCI0] (0000:00)
pci 0000:00:01.0: PME# supported from D0 D3hot D3cold
pci 0000:00:01.0: PME# disabled
pci 0000:00:02.0: reg 10 32bit mmio: [0xfdf00000-0xfdf7ffff]
pci 0000:00:02.0: reg 14 io port: [0xff00-0xff07]
pci 0000:00:02.0: reg 18 32bit mmio: [0xd0000000-0xdfffffff]
pci 0000:00:02.0: reg 1c 32bit mmio: [0xfdc00000-0xfdcfffff]
pci 0000:00:19.0: reg 10 32bit mmio: [0xfdfc0000-0xfdfdffff]
pci 0000:00:19.0: reg 14 32bit mmio: [0xfdfff000-0xfdffffff]
pci 0000:00:19.0: reg 18 io port: [0xfe00-0xfe1f]
pci 0000:00:19.0: PME# supported from D0 D3hot D3cold
pci 0000:00:19.0: PME# disabled
pci 0000:00:1a.0: reg 20 io port: [0xfd00-0xfd1f]
pci 0000:00:1a.1: reg 20 io port: [0xfc00-0xfc1f]
pci 0000:00:1a.2: reg 20 io port: [0xfb00-0xfb1f]
pci 0000:00:1a.7: reg 10 32bit mmio: [0xfdffe000-0xfdffe3ff]
pci 0000:00:1a.7: PME# supported from D0 D3hot D3cold
pci 0000:00:1a.7: PME# disabled
pci 0000:00:1d.0: reg 20 io port: [0xfa00-0xfa1f]
pci 0000:00:1d.1: reg 20 io port: [0xf900-0xf91f]
pci 0000:00:1d.2: reg 20 io port: [0xf800-0xf81f]
pci 0000:00:1d.7: reg 10 32bit mmio: [0xfdffd000-0xfdffd3ff]
pci 0000:00:1d.7: PME# supported from D0 D3hot D3cold
pci 0000:00:1d.7: PME# disabled
pci 0000:00:1f.0: quirk: region 0400-047f claimed by ICH6 ACPI/GPIO/TCO
pci 0000:00:1f.0: quirk: region 0480-04bf claimed by ICH6 GPIO
pci 0000:00:1f.0: ICH7 LPC Generic IO decode 1 PIO at 0800 (mask 003f)
pci 0000:00:1f.0: ICH7 LPC Generic IO decode 2 PIO at 0290 (mask 003f)
pci 0000:00:1f.2: reg 10 io port: [0xf700-0xf707]
pci 0000:00:1f.2: reg 14 io port: [0xf600-0xf603]
pci 0000:00:1f.2: reg 18 io port: [0xf500-0xf507]
pci 0000:00:1f.2: reg 1c io port: [0xf400-0xf403]
pci 0000:00:1f.2: reg 20 io port: [0xf300-0xf31f]
pci 0000:00:1f.2: reg 24 32bit mmio: [0xfdffc000-0xfdffc7ff]
pci 0000:00:1f.2: PME# supported from D3hot
pci 0000:00:1f.2: PME# disabled
pci 0000:00:1f.3: reg 10 64bit mmio: [0xfdffb000-0xfdffb0ff]
pci 0000:00:1f.3: reg 20 io port: [0x500-0x51f]
pci 0000:00:01.0: bridge io port: [0xd000-0xdfff]
pci 0000:00:01.0: bridge 32bit mmio: [0xfda00000-0xfdafffff]
pci 0000:00:01.0: bridge 64bit mmio pref: [0xfdb00000-0xfdbfffff]
pci 0000:02:01.0: reg 10 io port: [0xcf00-0xcf3f]
pci 0000:02:01.0: supports D1 D2
pci 0000:02:01.1: reg 10 io port: [0xce00-0xce07]
pci 0000:02:01.1: supports D1 D2
pci 0000:02:01.2: reg 10 32bit mmio: [0xfdeff000-0xfdeff7ff]
pci 0000:02:01.2: reg 14 32bit mmio: [0xfdef8000-0xfdefbfff]
pci 0000:02:01.2: supports D1 D2
pci 0000:02:01.2: PME# supported from D0 D1 D2 D3hot
pci 0000:02:01.2: PME# disabled
pci 0000:00:1e.0: transparent bridge
pci 0000:00:1e.0: bridge io port: [0xc000-0xcfff]
pci 0000:00:1e.0: bridge 32bit mmio: [0xfde00000-0xfdefffff]
pci 0000:00:1e.0: bridge 64bit mmio pref: [0xfdd00000-0xfddfffff]
pci_bus 0000:00: on NUMA node 0
ACPI: PCI Interrupt Routing Table [\_SB_.PCI0._PRT]
ACPI: PCI Interrupt Routing Table [\_SB_.PCI0.HUB0._PRT]
ACPI: PCI Interrupt Link [LNKA] (IRQs 3 4 *5 7 9 10 11 12 14 15)
ACPI: PCI Interrupt Link [LNKB] (IRQs 3 *4 5 7 9 10 11 12 14 15)
ACPI: PCI Interrupt Link [LNKC] (IRQs 3 4 5 7 9 10 *11 12 14 15)
ACPI: PCI Interrupt Link [LNKD] (IRQs 3 4 5 7 9 10 *11 12 14 15)
ACPI: PCI Interrupt Link [LNKE] (IRQs 3 4 5 7 9 *10 11 12 14 15)
ACPI: PCI Interrupt Link [LNKF] (IRQs 3 4 5 7 9 *10 11 12 14 15)
ACPI: PCI Interrupt Link [LNK0] (IRQs *3 4 5 7 9 10 11 12 14 15)
ACPI: PCI Interrupt Link [LNK1] (IRQs 3 4 5 7 *9 10 11 12 14 15)
PCI: Using ACPI for IRQ routing
NetLabel: Initializing
NetLabel:  domain hash size = 128
NetLabel:  protocols = UNLABELED CIPSOv4
NetLabel:  unlabeled traffic allowed by default
pnp: PnP ACPI init
ACPI: bus type pnp registered
pnp: PnP ACPI: found 12 devices
ACPI: ACPI bus type pnp unregistered
system 00:01: ioport range 0x4d0-0x4d1 has been reserved
system 00:01: ioport range 0x800-0x87f has been reserved
system 00:01: ioport range 0x290-0x297 has been reserved
system 00:01: ioport range 0x880-0x88f has been reserved
system 00:08: ioport range 0x400-0x4bf could not be reserved
system 00:0a: iomem range 0xe0000000-0xefffffff has been reserved
system 00:0b: iomem range 0xf0000-0xfffff could not be reserved
system 00:0b: iomem range 0xcf600000-0xcf6fffff could not be reserved
system 00:0b: iomem range 0xfed00000-0xfed000ff has been reserved
system 00:0b: iomem range 0xcf590000-0xcf5fffff could not be reserved
system 00:0b: iomem range 0x0-0x9ffff could not be reserved
system 00:0b: iomem range 0x100000-0xcf58ffff could not be reserved
system 00:0b: iomem range 0xfec00000-0xfec00fff could not be reserved
system 00:0b: iomem range 0xfed14000-0xfed1dfff has been reserved
system 00:0b: iomem range 0xfed20000-0xfed9ffff has been reserved
system 00:0b: iomem range 0xfee00000-0xfee00fff has been reserved
system 00:0b: iomem range 0xffb00000-0xffb7ffff has been reserved
system 00:0b: iomem range 0xfff00000-0xffffffff has been reserved
system 00:0b: iomem range 0xe0000-0xeffff has been reserved
pci 0000:00:01.0: PCI bridge, secondary bus 0000:01
pci 0000:00:01.0:   IO window: 0xd000-0xdfff
pci 0000:00:01.0:   MEM window: 0xfda00000-0xfdafffff
pci 0000:00:01.0:   PREFETCH window: 0x000000fdb00000-0x000000fdbfffff
pci 0000:00:1e.0: PCI bridge, secondary bus 0000:02
pci 0000:00:1e.0:   IO window: 0xc000-0xcfff
pci 0000:00:1e.0:   MEM window: 0xfde00000-0xfdefffff
pci 0000:00:1e.0:   PREFETCH window: 0x000000fdd00000-0x000000fddfffff
pci 0000:00:01.0: PCI INT A -> GSI 16 (level, low) -> IRQ 16
pci 0000:00:01.0: setting latency timer to 64
pci 0000:00:1e.0: setting latency timer to 64
pci_bus 0000:00: resource 0 io:  [0x00-0xffff]
pci_bus 0000:00: resource 1 mem: [0x000000-0xffffffffffffffff]
pci_bus 0000:01: resource 0 io:  [0xd000-0xdfff]
pci_bus 0000:01: resource 1 mem: [0xfda00000-0xfdafffff]
pci_bus 0000:01: resource 2 pref mem [0xfdb00000-0xfdbfffff]
pci_bus 0000:02: resource 0 io:  [0xc000-0xcfff]
pci_bus 0000:02: resource 1 mem: [0xfde00000-0xfdefffff]
pci_bus 0000:02: resource 2 pref mem [0xfdd00000-0xfddfffff]
pci_bus 0000:02: resource 3 io:  [0x00-0xffff]
pci_bus 0000:02: resource 4 mem: [0x000000-0xffffffffffffffff]
NET: Registered protocol family 2
IP route cache hash table entries: 262144 (order: 9, 2097152 bytes)
TCP established hash table entries: 262144 (order: 10, 4194304 bytes)
TCP bind hash table entries: 65536 (order: 8, 1048576 bytes)
TCP: Hash tables configured (established 262144 bind 65536)
TCP reno registered
NET: Registered protocol family 1
Unpacking initramfs...
Freeing initrd memory: 1018k freed
Scanning for low memory corruption every 60 seconds
audit: initializing netlink socket (disabled)
type=2000 audit(1256998169.436:1): initialized
VFS: Disk quotas dquot_6.5.2
Dquot-cache hash table entries: 512 (order 0, 4096 bytes)
msgmni has been set to 11926
alg: No test for stdrng (krng)
Block layer SCSI generic (bsg) driver version 0.4 loaded (major 254)
io scheduler noop registered
io scheduler anticipatory registered
io scheduler deadline registered
io scheduler cfq registered (default)
pci 0000:00:02.0: Boot video device
pcieport-driver 0000:00:01.0: irq 24 for MSI/MSI-X
pcieport-driver 0000:00:01.0: setting latency timer to 64
Linux agpgart interface v0.103
Serial: 8250/16550 driver, 4 ports, IRQ sharing disabled
input: Macintosh mouse button emulation as /devices/virtual/input/input0
PNP: No PS/2 controller found. Probing ports directly.
serio: i8042 KBD port at 0x60,0x64 irq 1
serio: i8042 AUX port at 0x60,0x64 irq 12
mice: PS/2 mouse device common for all mice
cpuidle: using governor ladder
cpuidle: using governor menu
TCP cubic registered
NET: Registered protocol family 17
registered taskstats version 1
Initalizing network drop monitor service
Freeing unused kernel memory: 484k freed
agpgart-intel 0000:00:00.0: Intel G33 Chipset
agpgart-intel 0000:00:00.0: detected 7164K stolen memory
agpgart-intel 0000:00:00.0: AGP aperture is 256M @ 0xd0000000
[drm] Initialized drm 1.1.0 20060810
i915 0000:00:02.0: PCI INT A -> GSI 16 (level, low) -> IRQ 16
i915 0000:00:02.0: setting latency timer to 64
mtrr: no more MTRRs available
[drm] MTRR allocation failed.  Graphics performance may suffer.
i915 0000:00:02.0: irq 25 for MSI/MSI-X
Switched to high resolution mode on CPU 1
Switched to high resolution mode on CPU 3
Switched to high resolution mode on CPU 2
Switched to high resolution mode on CPU 0
[drm] DAC-6: set mode 1920x1080 11
Console: switching to colour frame buffer device 240x67
[drm] fb0: inteldrmfb frame buffer device
[drm] Initialized i915 1.6.0 20080730 for 0000:00:02.0 on minor 0
FDC 0 is a post-1991 82077
SCSI subsystem initialized
libata version 3.00 loaded.
ahci 0000:00:1f.2: version 3.0
ahci 0000:00:1f.2: PCI INT A -> GSI 19 (level, low) -> IRQ 19
ahci 0000:00:1f.2: irq 26 for MSI/MSI-X
ahci 0000:00:1f.2: AHCI 0001.0200 32 slots 6 ports 3 Gbps 0x3f impl RAID mode
ahci 0000:00:1f.2: flags: 64bit ncq sntf led clo pmp pio slum part ems 
ahci 0000:00:1f.2: setting latency timer to 64
scsi0 : ahci
scsi1 : ahci
scsi2 : ahci
scsi3 : ahci
scsi4 : ahci
scsi5 : ahci
ata1: SATA max UDMA/133 abar m2048@0xfdffc000 port 0xfdffc100 irq 26
ata2: SATA max UDMA/133 abar m2048@0xfdffc000 port 0xfdffc180 irq 26
ata3: SATA max UDMA/133 abar m2048@0xfdffc000 port 0xfdffc200 irq 26
ata4: SATA max UDMA/133 abar m2048@0xfdffc000 port 0xfdffc280 irq 26
ata5: SATA max UDMA/133 abar m2048@0xfdffc000 port 0xfdffc300 irq 26
ata6: SATA max UDMA/133 abar m2048@0xfdffc000 port 0xfdffc380 irq 26
ata3: SATA link down (SStatus 0 SControl 300)
ata2: SATA link down (SStatus 0 SControl 300)
ata4: SATA link down (SStatus 0 SControl 300)
ata6: SATA link down (SStatus 0 SControl 300)
ata5: SATA link up 1.5 Gbps (SStatus 113 SControl 300)
ata1: SATA link up 3.0 Gbps (SStatus 123 SControl 300)
ata5.00: ATAPI: PLDS DVD+/-RW DH-16A6S, YD11, max UDMA/100
ata5.00: configured for UDMA/100
ata1.00: ATA-7: SAMSUNG HD322HJ, 1AC01113, max UDMA7
ata1.00: 625142448 sectors, multi 0: LBA48 NCQ (depth 31/32)
ata1.00: configured for UDMA/133
scsi 0:0:0:0: Direct-Access     ATA      SAMSUNG HD322HJ  1AC0 PQ: 0 ANSI: 5
scsi 4:0:0:0: CD-ROM            PLDS     DVD+-RW DH-16A6S YD11 PQ: 0 ANSI: 5
sd 0:0:0:0: [sda] 625142448 512-byte logical blocks: (320 GB/298 GiB)
sd 0:0:0:0: [sda] Write Protect is off
sd 0:0:0:0: [sda] Mode Sense: 00 3a 00 00
sd 0:0:0:0: [sda] Write cache: enabled, read cache: enabled, doesn't support DPO or FUA
 sda: sda1 sda2 sda3 sda4 < sda5 sda6 >
sd 0:0:0:0: [sda] Attached SCSI disk
sr0: scsi3-mmc drive: 48x/12x writer dvd-ram cd/rw xa/form2 cdda tray
Uniform CD-ROM driver Revision: 3.20
sr 4:0:0:0: Attached scsi CD-ROM sr0
EXT4-fs (sda2): barriers enabled
kjournald2 starting: pid 557, dev sda2:8, commit interval 5 seconds
EXT4-fs (sda2): delayed allocation enabled
EXT4-fs: file extents enabled
EXT4-fs: mballoc enabled
EXT4-fs (sda2): mounted filesystem with ordered data mode
rtc_cmos 00:04: RTC can wake from S4
rtc_cmos 00:04: rtc core: registered rtc_cmos as rtc0
rtc0: alarms up to one month, 242 bytes nvram, hpet irqs
udev: starting version 146
i801_smbus 0000:00:1f.3: PCI INT B -> GSI 18 (level, low) -> IRQ 18
input: PC Speaker as /devices/platform/pcspkr/input/input1
input: Power Button as /devices/LNXSYSTM:00/LNXPWRBN:00/input/input2
ACPI: Power Button [PWRF]
input: Power Button as /devices/LNXSYSTM:00/device:00/PNP0C0C:00/input/input3
ACPI: Power Button [PWRB]
dcdbas dcdbas: Dell Systems Management Base Driver (version 5.6.0-3.2)
e1000e: Intel(R) PRO/1000 Network Driver - 1.0.2-k2
e1000e: Copyright (c) 1999-2008 Intel Corporation.
e1000e 0000:00:19.0: PCI INT A -> GSI 20 (level, low) -> IRQ 20
e1000e 0000:00:19.0: pci_enable_pcie_error_reporting failed 0xfffffffb
e1000e 0000:00:19.0: setting latency timer to 64
e1000e 0000:00:19.0: irq 27 for MSI/MSI-X
iTCO_vendor_support: vendor-support=0
sd 0:0:0:0: Attached scsi generic sg0 type 0
sr 4:0:0:0: Attached scsi generic sg1 type 5
ACPI: SSDT 00000000cf5e7680 0022A (v01  PmRef  Cpu0Ist 00003000 INTL 20041203)
processor LNXCPU:00: registered as cooling_device0
ACPI: SSDT 00000000cf5e7b40 00152 (v01  PmRef  Cpu1Ist 00003000 INTL 20041203)
processor LNXCPU:01: registered as cooling_device1
ACPI: SSDT 00000000cf5e7ca0 00152 (v01  PmRef  Cpu2Ist 00003000 INTL 20041203)
processor LNXCPU:02: registered as cooling_device2
ACPI: SSDT 00000000cf5e7e00 00152 (v01  PmRef  Cpu3Ist 00003000 INTL 20041203)
processor LNXCPU:03: registered as cooling_device3
iTCO_wdt: Intel TCO WatchDog Timer Driver v1.05
iTCO_wdt: Found a ICH9R TCO device (Version=2, TCOBASE=0x0460)
iTCO_wdt: initialized. heartbeat=30 sec (nowayout=0)
gameport: EMU10K1 is pci0000:02:01.1/gameport0, io 0xce00, speed 1007kHz
fan PNP0C0B:00: registered as cooling_device4
ACPI: Fan [FAN] (on)
thermal LNXTHERM:01: registered as thermal_zone0
ACPI: Thermal Zone [THRM] (40 C)
0000:00:19.0: eth0: (PCI Express:2.5GB/s:Width x1) 00:21:9b:06:4c:c9
0000:00:19.0: eth0: Intel(R) PRO/10/100 Network Connection
0000:00:19.0: eth0: MAC: 7, PHY: 7, PBA No: ffffff-0ff
usbcore: registered new interface driver usbfs
usbcore: registered new interface driver hub
usbcore: registered new device driver usb
ohci1394 0000:02:01.2: PCI INT B -> GSI 17 (level, low) -> IRQ 17
ohci1394 0000:02:01.2: setting latency timer to 64
ehci_hcd: USB 2.0 'Enhanced' Host Controller (EHCI) Driver
ehci_hcd 0000:00:1a.7: PCI INT C -> GSI 18 (level, low) -> IRQ 18
ehci_hcd 0000:00:1a.7: setting latency timer to 64
ehci_hcd 0000:00:1a.7: EHCI Host Controller
ehci_hcd 0000:00:1a.7: new USB bus registered, assigned bus number 1
ehci_hcd 0000:00:1a.7: debug port 1
ehci_hcd 0000:00:1a.7: cache line size of 32 is not supported
ehci_hcd 0000:00:1a.7: irq 18, io mem 0xfdffe000
ehci_hcd 0000:00:1a.7: USB 2.0 started, EHCI 1.00
usb usb1: configuration #1 chosen from 1 choice
hub 1-0:1.0: USB hub found
hub 1-0:1.0: 6 ports detected
ehci_hcd 0000:00:1d.7: PCI INT A -> GSI 23 (level, low) -> IRQ 23
ehci_hcd 0000:00:1d.7: setting latency timer to 64
ehci_hcd 0000:00:1d.7: EHCI Host Controller
ehci_hcd 0000:00:1d.7: new USB bus registered, assigned bus number 2
ohci1394: fw-host0: OHCI-1394 1.1 (PCI): IRQ=[17]  MMIO=[fdeff000-fdeff7ff]  Max Packet=[2048]  IR/IT contexts=[4/8]
ehci_hcd 0000:00:1d.7: debug port 1
ehci_hcd 0000:00:1d.7: cache line size of 32 is not supported
ehci_hcd 0000:00:1d.7: irq 23, io mem 0xfdffd000
ehci_hcd 0000:00:1d.7: USB 2.0 started, EHCI 1.00
usb usb2: configuration #1 chosen from 1 choice
hub 2-0:1.0: USB hub found
hub 2-0:1.0: 6 ports detected
uhci_hcd: USB Universal Host Controller Interface driver
uhci_hcd 0000:00:1a.0: PCI INT A -> GSI 16 (level, low) -> IRQ 16
uhci_hcd 0000:00:1a.0: setting latency timer to 64
uhci_hcd 0000:00:1a.0: UHCI Host Controller
uhci_hcd 0000:00:1a.0: new USB bus registered, assigned bus number 3
uhci_hcd 0000:00:1a.0: irq 16, io base 0x0000fd00
usb usb3: configuration #1 chosen from 1 choice
hub 3-0:1.0: USB hub found
hub 3-0:1.0: 2 ports detected
uhci_hcd 0000:00:1a.1: PCI INT B -> GSI 21 (level, low) -> IRQ 21
uhci_hcd 0000:00:1a.1: setting latency timer to 64
uhci_hcd 0000:00:1a.1: UHCI Host Controller
uhci_hcd 0000:00:1a.1: new USB bus registered, assigned bus number 4
uhci_hcd 0000:00:1a.1: irq 21, io base 0x0000fc00
usb usb4: configuration #1 chosen from 1 choice
hub 4-0:1.0: USB hub found
hub 4-0:1.0: 2 ports detected
uhci_hcd 0000:00:1a.2: PCI INT D -> GSI 19 (level, low) -> IRQ 19
uhci_hcd 0000:00:1a.2: setting latency timer to 64
uhci_hcd 0000:00:1a.2: UHCI Host Controller
uhci_hcd 0000:00:1a.2: new USB bus registered, assigned bus number 5
uhci_hcd 0000:00:1a.2: irq 19, io base 0x0000fb00
usb usb5: configuration #1 chosen from 1 choice
hub 5-0:1.0: USB hub found
hub 5-0:1.0: 2 ports detected
uhci_hcd 0000:00:1d.0: PCI INT A -> GSI 23 (level, low) -> IRQ 23
uhci_hcd 0000:00:1d.0: setting latency timer to 64
uhci_hcd 0000:00:1d.0: UHCI Host Controller
uhci_hcd 0000:00:1d.0: new USB bus registered, assigned bus number 6
uhci_hcd 0000:00:1d.0: irq 23, io base 0x0000fa00
usb usb6: configuration #1 chosen from 1 choice
hub 6-0:1.0: USB hub found
hub 6-0:1.0: 2 ports detected
uhci_hcd 0000:00:1d.1: PCI INT B -> GSI 19 (level, low) -> IRQ 19
uhci_hcd 0000:00:1d.1: setting latency timer to 64
uhci_hcd 0000:00:1d.1: UHCI Host Controller
uhci_hcd 0000:00:1d.1: new USB bus registered, assigned bus number 7
uhci_hcd 0000:00:1d.1: irq 19, io base 0x0000f900
usb usb7: configuration #1 chosen from 1 choice
hub 7-0:1.0: USB hub found
hub 7-0:1.0: 2 ports detected
uhci_hcd 0000:00:1d.2: PCI INT C -> GSI 18 (level, low) -> IRQ 18
uhci_hcd 0000:00:1d.2: setting latency timer to 64
uhci_hcd 0000:00:1d.2: UHCI Host Controller
uhci_hcd 0000:00:1d.2: new USB bus registered, assigned bus number 8
uhci_hcd 0000:00:1d.2: irq 18, io base 0x0000f800
usb usb8: configuration #1 chosen from 1 choice
hub 8-0:1.0: USB hub found
hub 8-0:1.0: 2 ports detected
EMU10K1_Audigy 0000:02:01.0: PCI INT A -> GSI 16 (level, low) -> IRQ 16
EMU10K1_Audigy 0000:02:01.0: setting latency timer to 64
Installing spdif_bug patch: SB Audigy 2 ZS [SB0350]
usb 5-1: new full speed USB device using uhci_hcd and address 2
usb 5-1: configuration #1 chosen from 1 choice
hub 5-1:1.0: USB hub found
hub 5-1:1.0: 4 ports detected
usb 5-1.1: new low speed USB device using uhci_hcd and address 3
usb 5-1.1: configuration #1 chosen from 1 choice
ieee1394: Host added: ID:BUS[0-00:1023]  GUID[00023c01510c1ac4]
usb 5-1.3: new low speed USB device using uhci_hcd and address 4
usbcore: registered new interface driver hiddev
input: Logitech Logitech Gaming Keyboard as /devices/pci0000:00/0000:00:1a.2/usb5/5-1/5-1.1/5-1.1:1.0/input/input4
generic-usb 0003:046D:C221.0001: input,hidraw0: USB HID v1.10 Keyboard [Logitech Logitech Gaming Keyboard] on usb-0000:00:1a.2-1.1/input0
input: Logitech Logitech Gaming Keyboard as /devices/pci0000:00/0000:00:1a.2/usb5/5-1/5-1.1/5-1.1:1.1/input/input5
generic-usb 0003:046D:C221.0002: input,hiddev0,hidraw1: USB HID v1.10 Device [Logitech Logitech Gaming Keyboard] on usb-0000:00:1a.2-1.1/input1
usbcore: registered new interface driver usbhid
usbhid: v2.6:USB HID core driver
usb 5-1.3: configuration #1 chosen from 1 choice
input: Logitech USB-PS/2 Optical Mouse as /devices/pci0000:00/0000:00:1a.2/usb5/5-1/5-1.3/5-1.3:1.0/input/input6
generic-usb 0003:046D:C01E.0003: input,hidraw2: USB HID v1.10 Mouse [Logitech USB-PS/2 Optical Mouse] on usb-0000:00:1a.2-1.3/input0
usb 5-1.4: new full speed USB device using uhci_hcd and address 5
usb 5-1.4: configuration #1 chosen from 1 choice
input: G15 Keyboard G15 Keyboard as /devices/pci0000:00/0000:00:1a.2/usb5/5-1/5-1.4/5-1.4:1.0/input/input7
generic-usb 0003:046D:C222.0004: input,hiddev1,hidraw3: USB HID v1.11 Keypad [G15 Keyboard G15 Keyboard] on usb-0000:00:1a.2-1.4/input0
EXT4-fs (sda2): internal journal on sda2:8
EXT4-fs (sda5): barriers enabled
kjournald2 starting: pid 1140, dev sda5:8, commit interval 5 seconds
EXT4-fs (sda5): internal journal on sda5:8
EXT4-fs (sda5): Ignoring delalloc option - requested data journaling mode
EXT4-fs: file extents enabled
EXT4-fs: mballoc enabled
EXT4-fs (sda5): mounted filesystem with journalled data mode
EXT4-fs (sda6): barriers enabled
kjournald2 starting: pid 1143, dev sda6:8, commit interval 5 seconds
EXT4-fs (sda6): internal journal on sda6:8
EXT4-fs (sda6): delayed allocation enabled
EXT4-fs: file extents enabled
EXT4-fs: mballoc enabled
EXT4-fs (sda6): mounted filesystem with ordered data mode
loop: module loaded
Adding 3212992k swap on /dev/sda3.  Priority:-1 extents:1 across:3212992k 
e1000e 0000:00:19.0: irq 27 for MSI/MSI-X
e1000e 0000:00:19.0: irq 27 for MSI/MSI-X
ip_tables: (C) 2000-2006 Netfilter Core Team
nf_conntrack version 0.5.0 (16384 buckets, 65536 max)
CONFIG_NF_CT_ACCT is deprecated and will be removed soon. Please use
nf_conntrack.acct=1 kernel parameter, acct=1 nf_conntrack module option or
sysctl net.netfilter.nf_conntrack_acct=1 to enable it.
e1000e: eth0 NIC Link is Up 100 Mbps Full Duplex, Flow Control: RX/TX
0000:00:19.0: eth0: 10/100 speed: disabling TSO
NET: Registered protocol family 10
lo: Disabled Privacy Extensions
eth0: no IPv6 routers present

--Boundary-00=_TWI7KJq6CFmNaNG--
