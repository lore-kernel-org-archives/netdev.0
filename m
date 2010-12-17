From: Jon Mason <jon.mason@exar.com>
Subject: Re: "x86: allocate space within a region top-down" causes bar0
 access issue
Date: Fri, 17 Dec 2010 17:12:11 -0600
Message-ID: <20101217231210.GH4622@exar.com>
References: <20101217194457.GA4470@exar.com>
 <201012171316.12761.bjorn.helgaas@hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Ramkrishna Vepa <Ramkrishna.Vepa@exar.com>
To: Bjorn Helgaas <bjorn.helgaas@hp.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <201012171316.12761.bjorn.helgaas@hp.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Dec 17, 2010 at 12:16:12PM -0800, Bjorn Helgaas wrote:
> On Friday, December 17, 2010 12:44:58 pm Jon Mason wrote:
> > The following patch is causing problem with the vxge driver/adapter on
> > HP x86-64 systems. Reads to bar0 to return 0xffffffffffffffff instead
> > of their intended value.  This prevents the vxge module from loading
> > by failing sanity checks in the driver for certain values in bar0.  We
> > are not seeing any issues with this patch on non-HP systems in our
> > lab.
> >
> > Can this patch be removed from 2.6.37 until a better solution can be
> > found?
>
> There were several issues related to that patch, and it's about to
> be reverted.  I am curious about the failure you're seeing, though,
> and I'd like to understand the cause and make sure it's one of the
> issues I've already investigated.
>
> Can you send me the complete dmesg log of a failing boot?
>
> Thanks,
>   Bjorn

Below is the dmesg of a failing system.

Thanks,
Jon

Initializing cgroup subsys cpuset
Initializing cgroup subsys cpu
Linux version 2.6.37-rc1-5-default (root@SuSE-11) (gcc version 4.3.2 [gcc-4_3-branch revision 141291] (SUSE Linux) ) #2 SMP Wed Dec 15 14:33:28 PST 2010
Command line: root=/dev/disk/by-id/ata-GB0160CAABV_5RX52XN5-part2 resume=/dev/disk/by-id/ata-GB0160CAABV_5RX52XN5-part1 splash=silent crashkernel=256M-:128M@16M vga=0x317
BIOS-provided physical RAM map:
 BIOS-e820: 0000000000000000 - 000000000009fc00 (usable)
 BIOS-e820: 000000000009fc00 - 00000000000a0000 (reserved)
 BIOS-e820: 00000000000e0000 - 0000000000100000 (reserved)
 BIOS-e820: 0000000000100000 - 00000000dff90000 (usable)
 BIOS-e820: 00000000dff9e000 - 00000000dffa0000 type 9
 BIOS-e820: 00000000dffa0000 - 00000000dffae000 (ACPI data)
 BIOS-e820: 00000000dffae000 - 00000000dffe0000 (ACPI NVS)
 BIOS-e820: 00000000dffe0000 - 00000000dffee000 (reserved)
 BIOS-e820: 00000000dfff0000 - 00000000f0000000 (reserved)
 BIOS-e820: 00000000fee00000 - 00000000fee01000 (reserved)
 BIOS-e820: 00000000ffe00000 - 0000000100000000 (reserved)
 BIOS-e820: 0000000100000000 - 0000000220000000 (usable)
NX (Execute Disable) protection: active
DMI present.
DMI: ProLiant ML150 G5/ProLiant ML150 G5, BIOS O17     01/15/2009
e820 update range: 0000000000000000 - 0000000000010000 (usable) ==> (reserved)
e820 remove range: 00000000000a0000 - 0000000000100000 (usable)
No AGP bridge found
last_pfn = 0x220000 max_arch_pfn = 0x400000000
MTRR default type: uncachable
MTRR fixed ranges enabled:
  00000-9FFFF write-back
  A0000-DFFFF uncachable
  E0000-EFFFF write-through
  F0000-FFFFF write-protect
MTRR variable ranges enabled:
  0 base 0000000000 mask 3E00000000 write-back
  1 base 0200000000 mask 3FE0000000 write-back
  2 base 00E0000000 mask 3FE0000000 uncachable
  3 disabled
  4 disabled
  5 disabled
  6 disabled
  7 disabled
x86 PAT enabled: cpu 0, old 0x7040600070406, new 0x7010600070106
e820 update range: 00000000e0000000 - 0000000100000000 (usable) ==> (reserved)
last_pfn = 0xdff90 max_arch_pfn = 0x400000000
found SMP MP-table at [ffff8800000ff780] ff780
initial memory mapped : 0 - 20000000
init_memory_mapping: 0000000000000000-00000000dff90000
 0000000000 - 00dfe00000 page 2M
 00dfe00000 - 00dff90000 page 4k
kernel direct mapping tables up to dff90000 @ 1fffa000-20000000
init_memory_mapping: 0000000100000000-0000000220000000
 0100000000 - 0220000000 page 2M
kernel direct mapping tables up to 220000000 @ dff86000-dff90000
RAMDISK: 37406000 - 37ff0000
crashkernel reservation failed - memory is in use.
ACPI: RSDP 00000000000f9da0 00024 (v02 HP    )
ACPI: XSDT 00000000dffa0100 0007C (v01 HP     ProLiant 20090115 HP   00000097)
ACPI: FACP 00000000dffa0290 000F4 (v04 HP     ProLiant 20090115 HP   00000097)
ACPI: DSDT 00000000dffa0690 04EE4 (v02 HP     ProLiant 00000077 INTL 20051117)
ACPI: FACS 00000000dffae000 00040
ACPI: APIC 00000000dffa0390 00092 (v02 HP     ProLiant 20090115 HP   00000097)
ACPI: MCFG 00000000dffa0480 0003C (v01 HP     ProLiant 20090115 HP   00000097)
ACPI: SPMI 00000000dffa04c0 00041 (v05 HP     ProLiant 20090115 HP   00000097)
ACPI: SLIC 00000000dffa0510 00176 (v01 HP     ProLiant 20090115 HP   00000097)
ACPI: OEMB 00000000dffae040 00071 (v01 HP     ProLiant 20090115 HP   00000097)
ACPI: HPET 00000000dffa5580 00038 (v01 HP     ProLiant 20090115 HP   00000097)
ACPI: EINJ 00000000dffa55c0 00130 (v01   HP   ProLiant 20090115 HP   00000097)
ACPI: BERT 00000000dffa5750 00030 (v01 HP     ProLiant 20090115 HP   00000097)
ACPI: ERST 00000000dffa5780 001B0 (v01 HP     ProLiant 20090115 HP   00000097)
ACPI: HEST 00000000dffa5930 000A8 (v01 HP     ProLiant 20090115 HP   00000097)
ACPI: Local APIC address 0xfee00000
No NUMA configuration found
Faking a node at 0000000000000000-0000000220000000
Initmem setup node 0 0000000000000000-0000000220000000
  NODE_DATA [000000021ffd9000 - 000000021fffffff]
 [ffffea0000000000-ffffea00077fffff] PMD -> [ffff880217e00000-ffff88021effffff] on node 0
Zone PFN ranges:
  DMA      0x00000010 -> 0x00001000
  DMA32    0x00001000 -> 0x00100000
  Normal   0x00100000 -> 0x00220000
Movable zone start PFN for each node
early_node_map[3] active PFN ranges
    0: 0x00000010 -> 0x0000009f
    0: 0x00000100 -> 0x000dff90
    0: 0x00100000 -> 0x00220000
On node 0 totalpages: 2096927
  DMA zone: 56 pages used for memmap
  DMA zone: 6 pages reserved
  DMA zone: 3921 pages, LIFO batch:0
  DMA32 zone: 14280 pages used for memmap
  DMA32 zone: 899016 pages, LIFO batch:31
  Normal zone: 16128 pages used for memmap
  Normal zone: 1163520 pages, LIFO batch:31
ACPI: PM-Timer IO Port: 0x808
ACPI: Local APIC address 0xfee00000
ACPI: LAPIC (acpi_id[0x01] lapic_id[0x00] enabled)
ACPI: LAPIC (acpi_id[0x02] lapic_id[0x01] enabled)
ACPI: LAPIC (acpi_id[0x03] lapic_id[0x02] enabled)
ACPI: LAPIC (acpi_id[0x04] lapic_id[0x03] enabled)
ACPI: LAPIC (acpi_id[0x05] lapic_id[0x84] disabled)
ACPI: LAPIC (acpi_id[0x06] lapic_id[0x85] disabled)
ACPI: LAPIC (acpi_id[0x07] lapic_id[0x86] disabled)
ACPI: LAPIC (acpi_id[0x08] lapic_id[0x87] disabled)
ACPI: LAPIC_NMI (acpi_id[0xff] high dfl lint[0x1])
ACPI: IOAPIC (id[0x04] address[0xfec00000] gsi_base[0])
IOAPIC[0]: apic_id 4, version 32, address 0xfec00000, GSI 0-23
ACPI: INT_SRC_OVR (bus 0 bus_irq 0 global_irq 2 dfl dfl)
ACPI: INT_SRC_OVR (bus 0 bus_irq 9 global_irq 9 high level)
ACPI: IRQ0 used by override.
ACPI: IRQ2 used by override.
ACPI: IRQ9 used by override.
Using ACPI (MADT) for SMP configuration information
ACPI: HPET id: 0x8086a301 base: 0xfed00000
SMP: Allowing 8 CPUs, 4 hotplug CPUs
nr_irqs_gsi: 40
PM: Registered nosave memory: 000000000009f000 - 00000000000a0000
PM: Registered nosave memory: 00000000000a0000 - 00000000000e0000
PM: Registered nosave memory: 00000000000e0000 - 0000000000100000
PM: Registered nosave memory: 00000000dff90000 - 00000000dff9e000
PM: Registered nosave memory: 00000000dff9e000 - 00000000dffa0000
PM: Registered nosave memory: 00000000dffa0000 - 00000000dffae000
PM: Registered nosave memory: 00000000dffae000 - 00000000dffe0000
PM: Registered nosave memory: 00000000dffe0000 - 00000000dffee000
PM: Registered nosave memory: 00000000dffee000 - 00000000dfff0000
PM: Registered nosave memory: 00000000dfff0000 - 00000000f0000000
PM: Registered nosave memory: 00000000f0000000 - 00000000fee00000
PM: Registered nosave memory: 00000000fee00000 - 00000000fee01000
PM: Registered nosave memory: 00000000fee01000 - 00000000ffe00000
PM: Registered nosave memory: 00000000ffe00000 - 0000000100000000
Allocating PCI resources starting at f0000000 (gap: f0000000:ee00000)
setup_percpu: NR_CPUS:4096 nr_cpumask_bits:8 nr_cpu_ids:8 nr_node_ids:1
PERCPU: Embedded 27 pages/cpu @ffff8800dfc00000 s79168 r8192 d23232 u262144
pcpu-alloc: s79168 r8192 d23232 u262144 alloc=1*2097152
pcpu-alloc: [0] 0 1 2 3 4 5 6 7
Built 1 zonelists in Zone order, mobility grouping on.  Total pages: 2066457
Policy zone: Normal
Kernel command line: root=/dev/disk/by-id/ata-GB0160CAABV_5RX52XN5-part2 resume=/dev/disk/by-id/ata-GB0160CAABV_5RX52XN5-part1 splash=silent crashkernel=256M-:128M@16M vga=0x317
PID hash table entries: 4096 (order: 3, 32768 bytes)
Checking aperture...
No AGP bridge found
Memory: 8110212k/8912896k available (2942k kernel code, 525188k absent, 277496k reserved, 5969k data, 1260k init)
Hierarchical RCU implementation.
NR_IRQS:4352
Extended CMOS year: 2000
Console: colour dummy device 80x25
console [tty0] enabled
allocated 83886080 bytes of page_cgroup
please try 'cgroup_disable=memory' option if you don't want memory cgroups
hpet clockevent registered
Fast TSC calibration using PIT
Detected 2493.477 MHz processor.
Calibrating delay loop (skipped), value calculated using timer frequency.. 4986.95 BogoMIPS (lpj=9973908)
pid_max: default: 32768 minimum: 301
Security Framework initialized
SELinux:  Disabled at boot.
AppArmor: AppArmor disabled by boot time parameter
Dentry cache hash table entries: 1048576 (order: 11, 8388608 bytes)
Inode-cache hash table entries: 524288 (order: 10, 4194304 bytes)
Mount-cache hash table entries: 256
Initializing cgroup subsys ns
ns_cgroup deprecated: consider using the 'clone_children' flag without the ns_cgroup.
Initializing cgroup subsys cpuacct
Initializing cgroup subsys memory
Initializing cgroup subsys devices
Initializing cgroup subsys freezer
CPU: Physical Processor ID: 0
CPU: Processor Core ID: 0
mce: CPU supports 6 MCE banks
CPU0: Thermal monitoring enabled (TM2)
using mwait in idle threads.
Performance Events: PEBS fmt0+, Core2 events, Intel PMU driver.
... version:                2
... bit width:              40
... generic registers:      2
... value mask:             000000ffffffffff
... max period:             000000007fffffff
... fixed-purpose events:   3
... event mask:             0000000700000003
ACPI: Core revision 20101013
Setting APIC routing to flat
..TIMER: vector=0x30 apic1=0 pin1=2 apic2=-1 pin2=-1
CPU0: Intel(R) Xeon(R) CPU           E5420  @ 2.50GHz stepping 06
Booting Node   0, Processors  #1 #2 #3
Brought up 4 CPUs
Total of 4 processors activated (19949.50 BogoMIPS).
NET: Registered protocol family 16
ACPI: bus type pci registered
PCI: MMCONFIG for domain 0000 [bus 00-ff] at [mem 0xe0000000-0xefffffff] (base 0xe0000000)
PCI: MMCONFIG at [mem 0xe0000000-0xefffffff] reserved in E820
PCI: Using configuration type 1 for base access
bio: create slab <bio-0> at 0
ACPI: EC: Look up EC in DSDT
ACPI: Executed 1 blocks of module-level executable AML code
ACPI: Interpreter enabled
ACPI: (supports S0 S4 S5)
ACPI: Using IOAPIC for interrupt routing
PCI: Using host bridge windows from ACPI; if necessary, use "pci=nocrs" and report a bug
ACPI: PCI Root Bridge [PCI0] (domain 0000 [bus 00-ff])
pci_root PNP0A08:00: host bridge window [io  0x0000-0x0bff]
pci_root PNP0A08:00: host bridge window [io  0x0d00-0xffff]
pci_root PNP0A08:00: host bridge window [mem 0x000a0000-0x000bffff]
pci_root PNP0A08:00: host bridge window [mem 0x000d0000-0x000dffff]
pci_root PNP0A08:00: host bridge window [mem 0xf0000000-0xffffffff]
pci 0000:00:00.0: [8086:65c0] type 0 class 0x000600
pci 0000:00:00.0: PME# supported from D0 D3hot D3cold
pci 0000:00:00.0: PME# disabled
pci 0000:00:02.0: [8086:65e2] type 1 class 0x000604
pci 0000:00:02.0: PME# supported from D0 D3hot D3cold
pci 0000:00:02.0: PME# disabled
pci 0000:00:03.0: [8086:65e3] type 1 class 0x000604
pci 0000:00:03.0: PME# supported from D0 D3hot D3cold
pci 0000:00:03.0: PME# disabled
pci 0000:00:04.0: [8086:65f8] type 1 class 0x000604
pci 0000:00:04.0: PME# supported from D0 D3hot D3cold
pci 0000:00:04.0: PME# disabled
pci 0000:00:05.0: [8086:65e5] type 1 class 0x000604
pci 0000:00:05.0: PME# supported from D0 D3hot D3cold
pci 0000:00:05.0: PME# disabled
pci 0000:00:06.0: [8086:65f9] type 1 class 0x000604
pci 0000:00:06.0: PME# supported from D0 D3hot D3cold
pci 0000:00:06.0: PME# disabled
pci 0000:00:07.0: [8086:65e7] type 1 class 0x000604
pci 0000:00:07.0: PME# supported from D0 D3hot D3cold
pci 0000:00:07.0: PME# disabled
pci 0000:00:10.0: [8086:65f0] type 0 class 0x000600
pci 0000:00:10.1: [8086:65f0] type 0 class 0x000600
pci 0000:00:10.2: [8086:65f0] type 0 class 0x000600
pci 0000:00:11.0: [8086:65f1] type 0 class 0x000600
pci 0000:00:13.0: [8086:65f3] type 0 class 0x000600
pci 0000:00:15.0: [8086:65f5] type 0 class 0x000600
pci 0000:00:16.0: [8086:65f6] type 0 class 0x000600
pci 0000:00:1a.0: [8086:2937] type 0 class 0x000c03
pci 0000:00:1a.0: reg 20: [io  0xe800-0xe81f]
pci 0000:00:1a.1: [8086:2938] type 0 class 0x000c03
pci 0000:00:1a.1: reg 20: [io  0xe880-0xe89f]
pci 0000:00:1a.2: [8086:2939] type 0 class 0x000c03
pci 0000:00:1a.2: reg 20: [io  0xec00-0xec1f]
pci 0000:00:1a.7: [8086:293c] type 0 class 0x000c03
pci 0000:00:1a.7: reg 10: [mem 0xfcdffc00-0xfcdfffff]
pci 0000:00:1a.7: PME# supported from D0 D3hot D3cold
pci 0000:00:1a.7: PME# disabled
pci 0000:00:1c.0: [8086:2940] type 1 class 0x000604
pci 0000:00:1c.0: PME# supported from D0 D3hot D3cold
pci 0000:00:1c.0: PME# disabled
pci 0000:00:1c.4: [8086:2948] type 1 class 0x000604
pci 0000:00:1c.4: PME# supported from D0 D3hot D3cold
pci 0000:00:1c.4: PME# disabled
pci 0000:00:1c.5: [8086:294a] type 1 class 0x000604
pci 0000:00:1c.5: PME# supported from D0 D3hot D3cold
pci 0000:00:1c.5: PME# disabled
pci 0000:00:1d.0: [8086:2934] type 0 class 0x000c03
pci 0000:00:1d.0: reg 20: [io  0xe080-0xe09f]
pci 0000:00:1d.1: [8086:2935] type 0 class 0x000c03
pci 0000:00:1d.1: reg 20: [io  0xe400-0xe41f]
pci 0000:00:1d.2: [8086:2936] type 0 class 0x000c03
pci 0000:00:1d.2: reg 20: [io  0xe480-0xe49f]
pci 0000:00:1d.7: [8086:293a] type 0 class 0x000c03
pci 0000:00:1d.7: reg 10: [mem 0xfcdff800-0xfcdffbff]
pci 0000:00:1d.7: PME# supported from D0 D3hot D3cold
pci 0000:00:1d.7: PME# disabled
pci 0000:00:1e.0: [8086:244e] type 1 class 0x000604
pci 0000:00:1f.0: [8086:2916] type 0 class 0x000601
pci 0000:00:1f.0: quirk: [io  0x0800-0x087f] claimed by ICH6 ACPI/GPIO/TCO
pci 0000:00:1f.0: quirk: [io  0x0480-0x04bf] claimed by ICH6 GPIO
pci 0000:00:1f.0: ICH7 LPC Generic IO decode 4 PIO at 0ca0 (mask 0007)
pci 0000:00:1f.2: [8086:2920] type 0 class 0x000101
pci 0000:00:1f.2: reg 10: [io  0x0000-0x0007]
pci 0000:00:1f.2: reg 14: [io  0x0000-0x0003]
pci 0000:00:1f.2: reg 18: [io  0x0000-0x0007]
pci 0000:00:1f.2: reg 1c: [io  0x0000-0x0003]
pci 0000:00:1f.2: reg 20: [io  0xff90-0xff9f]
pci 0000:00:1f.2: reg 24: [io  0xffa0-0xffaf]
pci 0000:00:1f.3: [8086:2930] type 0 class 0x000c05
pci 0000:00:1f.3: reg 10: [mem 0xffffffc00-0xffffffcff 64bit]
pci 0000:00:1f.3: reg 20: [io  0x0400-0x041f]
pci 0000:00:1f.5: [8086:2926] type 0 class 0x000101
pci 0000:00:1f.5: reg 10: [io  0xe000-0xe007]
pci 0000:00:1f.5: reg 14: [io  0xdc00-0xdc03]
pci 0000:00:1f.5: reg 18: [io  0xd880-0xd887]
pci 0000:00:1f.5: reg 1c: [io  0xd800-0xd803]
pci 0000:00:1f.5: reg 20: [io  0xd480-0xd48f]
pci 0000:00:1f.5: reg 24: [io  0xd400-0xd40f]
pci 0000:00:02.0: PCI bridge to [bus 01-01]
pci 0000:00:02.0:   bridge window [io  0xf000-0x0000] (disabled)
pci 0000:00:02.0:   bridge window [mem 0xfff00000-0x000fffff] (disabled)
pci 0000:00:02.0:   bridge window [mem 0xfff00000-0x000fffff pref] (disabled)
pci 0000:00:03.0: PCI bridge to [bus 02-02]
pci 0000:00:03.0:   bridge window [io  0xf000-0x0000] (disabled)
pci 0000:00:03.0:   bridge window [mem 0xfff00000-0x000fffff] (disabled)
pci 0000:00:03.0:   bridge window [mem 0xfff00000-0x000fffff pref] (disabled)
pci 0000:00:04.0: PCI bridge to [bus 03-03]
pci 0000:00:04.0:   bridge window [io  0xf000-0x0000] (disabled)
pci 0000:00:04.0:   bridge window [mem 0xfff00000-0x000fffff] (disabled)
pci 0000:00:04.0:   bridge window [mem 0xfff00000-0x000fffff pref] (disabled)
pci 0000:00:05.0: PCI bridge to [bus 04-04]
pci 0000:00:05.0:   bridge window [io  0xf000-0x0000] (disabled)
pci 0000:00:05.0:   bridge window [mem 0xfff00000-0x000fffff] (disabled)
pci 0000:00:05.0:   bridge window [mem 0xfff00000-0x000fffff pref] (disabled)
pci 0000:05:00.0: [17d5:5833] type 0 class 0x000200
pci 0000:05:00.0: reg 10: [mem 0xfff000000-0xfff7fffff 64bit pref]
pci 0000:05:00.0: reg 18: [mem 0xfffcfe000-0xfffcfffff 64bit pref]
pci 0000:05:00.0: reg 20: [mem 0xfffcfc000-0xfffcfdfff 64bit pref]
pci 0000:05:00.0: reg 30: [mem 0xfce80000-0xfcefffff pref]
pci 0000:05:00.0: supports D1 D2
pci 0000:05:00.0: PME# supported from D0 D1 D2
pci 0000:05:00.0: PME# disabled
pci 0000:00:06.0: PCI bridge to [bus 05-05]
pci 0000:00:06.0:   bridge window [io  0xf000-0x0000] (disabled)
pci 0000:00:06.0:   bridge window [mem 0xfce00000-0xfcefffff]
pci 0000:00:06.0:   bridge window [mem 0xfff000000-0xfffcfffff 64bit pref]
pci 0000:00:07.0: PCI bridge to [bus 06-06]
pci 0000:00:07.0:   bridge window [io  0xf000-0x0000] (disabled)
pci 0000:00:07.0:   bridge window [mem 0xfff00000-0x000fffff] (disabled)
pci 0000:00:07.0:   bridge window [mem 0xfff00000-0x000fffff pref] (disabled)
pci 0000:09:00.0: [1033:0125] type 1 class 0x000604
pci 0000:09:00.0: supports D1
pci 0000:09:00.0: PME# supported from D0 D1 D3hot D3cold
pci 0000:09:00.0: PME# disabled
pci 0000:09:00.1: [1033:0125] type 1 class 0x000604
pci 0000:09:00.1: reg 10: [mem 0xfdeffc00-0xfdeffc7f 64bit]
pci 0000:09:00.1: supports D1
pci 0000:09:00.1: PME# supported from D0 D1 D3hot D3cold
pci 0000:09:00.1: PME# disabled
pci 0000:09:00.0: disabling ASPM on pre-1.1 PCIe device.  You can enable it with 'pcie_aspm=force'
pci 0000:00:1c.0: PCI bridge to [bus 09-0b]
pci 0000:00:1c.0:   bridge window [io  0xf000-0x0000] (disabled)
pci 0000:00:1c.0:   bridge window [mem 0xfde00000-0xfdffffff]
pci 0000:00:1c.0:   bridge window [mem 0xfffd00000-0xfffefffff 64bit pref]
pci 0000:0b:04.0: [17d5:5832] type 0 class 0x000200
pci 0000:0b:04.0: reg 10: [mem 0xfffef8000-0xfffefffff 64bit pref]
pci 0000:0b:04.0: reg 18: [mem 0xfffd00000-0xfffdfffff 64bit pref]
pci 0000:0b:04.0: reg 20: [mem 0xfffef7800-0xfffef7fff 64bit pref]
pci 0000:0b:04.0: reg 30: [mem 0xfdf00000-0xfdffffff pref]
pci 0000:0b:04.0: supports D1 D2
pci 0000:0b:04.0: PME# supported from D0 D1 D2 D3hot
pci 0000:0b:04.0: PME# disabled
pci 0000:09:00.0: PCI bridge to [bus 0b-0b]
pci 0000:09:00.0:   bridge window [io  0xf000-0x0000] (disabled)
pci 0000:09:00.0:   bridge window [mem 0xfdf00000-0xfdffffff]
pci 0000:09:00.0:   bridge window [mem 0xfffd00000-0xfffefffff 64bit pref]
pci 0000:09:00.1: PCI bridge to [bus 0a-0a]
pci 0000:09:00.1:   bridge window [io  0xf000-0x0000] (disabled)
pci 0000:09:00.1:   bridge window [mem 0xfff00000-0x000fffff] (disabled)
pci 0000:09:00.1:   bridge window [mem 0xfff00000-0x000fffff pref] (disabled)
pci 0000:08:00.0: [102b:0522] type 0 class 0x000300
pci 0000:08:00.0: reg 10: [mem 0xfb000000-0xfbffffff pref]
pci 0000:08:00.0: reg 14: [mem 0xfddfc000-0xfddfffff]
pci 0000:08:00.0: reg 18: [mem 0xfd000000-0xfd7fffff]
pci 0000:08:00.0: reg 30: [mem 0xfdde0000-0xfddeffff pref]
pci 0000:08:00.0: disabling ASPM on pre-1.1 PCIe device.  You can enable it with 'pcie_aspm=force'
pci 0000:00:1c.4: PCI bridge to [bus 08-08]
pci 0000:00:1c.4:   bridge window [io  0xf000-0x0000] (disabled)
pci 0000:00:1c.4:   bridge window [mem 0xfd000000-0xfddfffff]
pci 0000:00:1c.4:   bridge window [mem 0xfb000000-0xfbffffff 64bit pref]
pci 0000:07:00.0: [14e4:165a] type 0 class 0x000200
pci 0000:07:00.0: reg 10: [mem 0xfcff0000-0xfcffffff 64bit]
pci 0000:07:00.0: PME# supported from D3hot D3cold
pci 0000:07:00.0: PME# disabled
pci 0000:00:1c.5: PCI bridge to [bus 07-07]
pci 0000:00:1c.5:   bridge window [io  0xf000-0x0000] (disabled)
pci 0000:00:1c.5:   bridge window [mem 0xfcf00000-0xfcffffff]
pci 0000:00:1c.5:   bridge window [mem 0xfff00000-0x000fffff pref] (disabled)
pci 0000:00:1e.0: PCI bridge to [bus 0c-0c] (subtractive decode)
pci 0000:00:1e.0:   bridge window [io  0xf000-0x0000] (disabled)
pci 0000:00:1e.0:   bridge window [mem 0xfff00000-0x000fffff] (disabled)
pci 0000:00:1e.0:   bridge window [mem 0xfff00000-0x000fffff pref] (disabled)
pci 0000:00:1e.0:   bridge window [io  0x0000-0x0bff] (subtractive decode)
pci 0000:00:1e.0:   bridge window [io  0x0d00-0xffff] (subtractive decode)
pci 0000:00:1e.0:   bridge window [mem 0x000a0000-0x000bffff] (subtractive decode)
pci 0000:00:1e.0:   bridge window [mem 0x000d0000-0x000dffff] (subtractive decode)
pci 0000:00:1e.0:   bridge window [mem 0xf0000000-0xffffffff] (subtractive decode)
ACPI: PCI Interrupt Routing Table [\_SB_.PCI0._PRT]
ACPI: PCI Interrupt Routing Table [\_SB_.PCI0.NPE2._PRT]
ACPI: PCI Interrupt Routing Table [\_SB_.PCI0.NPE3._PRT]
ACPI: PCI Interrupt Routing Table [\_SB_.PCI0.NPE4._PRT]
ACPI: PCI Interrupt Routing Table [\_SB_.PCI0.NPE6._PRT]
ACPI: PCI Interrupt Routing Table [\_SB_.PCI0.P0P1._PRT]
ACPI: PCI Interrupt Routing Table [\_SB_.PCI0.P0PE._PRT]
ACPI: PCI Interrupt Routing Table [\_SB_.PCI0.P0P3._PRT]
ACPI: PCI Interrupt Routing Table [\_SB_.PCI0.BCM_._PRT]
ACPI: PCI Interrupt Link [LNKA] (IRQs 5 6 7 10 *11 12 14 15)
ACPI: PCI Interrupt Link [LNKB] (IRQs 5 6 7 *10 11 12 14 15)
ACPI: PCI Interrupt Link [LNKC] (IRQs *5 6 7 10 11 12 14 15)
ACPI: PCI Interrupt Link [LNKD] (IRQs *3 4 6 10 11 12 14 15)
ACPI: PCI Interrupt Link [LNKE] (IRQs 5 6 7 10 11 12 14 15) *0, disabled.
ACPI: PCI Interrupt Link [LNKF] (IRQs 5 6 *7 10 11 12 14 15)
ACPI: PCI Interrupt Link [LNKG] (IRQs 5 6 7 10 11 12 14 15) *0, disabled.
ACPI: PCI Interrupt Link [LNKH] (IRQs 5 *6 7 10 11 12 14 15)
vgaarb: device added: PCI:0000:08:00.0,decodes=io+mem,owns=io+mem,locks=none
vgaarb: loaded
PCI: Using ACPI for IRQ routing
PCI: pci_cache_line_size set to 64 bytes
pci 0000:00:06.0: no compatible bridge window for [mem 0xfff000000-0xfffcfffff 64bit pref]
pci 0000:00:1c.0: no compatible bridge window for [mem 0xfffd00000-0xfffefffff 64bit pref]
pci 0000:09:00.0: no compatible bridge window for [mem 0xfffd00000-0xfffefffff 64bit pref]
pci 0000:00:1f.3: no compatible bridge window for [mem 0xffffffc00-0xffffffcff 64bit]
pci 0000:05:00.0: no compatible bridge window for [mem 0xfff000000-0xfff7fffff 64bit pref]
pci 0000:05:00.0: no compatible bridge window for [mem 0xfffcfe000-0xfffcfffff 64bit pref]
pci 0000:05:00.0: no compatible bridge window for [mem 0xfffcfc000-0xfffcfdfff 64bit pref]
pci 0000:0b:04.0: no compatible bridge window for [mem 0xfffef8000-0xfffefffff 64bit pref]
pci 0000:0b:04.0: no compatible bridge window for [mem 0xfffd00000-0xfffdfffff 64bit pref]
pci 0000:0b:04.0: no compatible bridge window for [mem 0xfffef7800-0xfffef7fff 64bit pref]
reserve RAM buffer: 000000000009fc00 - 000000000009ffff
reserve RAM buffer: 00000000dff90000 - 00000000dfffffff
HPET: 4 timers in total, 0 timers will be used for per-cpu timer
hpet0: at MMIO 0xfed00000, IRQs 2, 8, 0, 0
hpet0: 4 comparators, 64-bit 14.318180 MHz counter
Switching to clocksource tsc
pnp: PnP ACPI init
ACPI: bus type pnp registered
pnp 00:00: [bus 00-ff]
pnp 00:00: [io  0x0cf8-0x0cff]
pnp 00:00: [io  0x0000-0x0bff window]
pnp 00:00: [io  0x0d00-0xffff window]
pnp 00:00: [mem 0x000a0000-0x000bffff window]
pnp 00:00: [mem 0x000d0000-0x000dffff window]
pnp 00:00: [mem 0xe0000000-0xdfffffff window disabled]
pnp 00:00: [mem 0xf0000000-0xffffffff window]
pnp 00:00: Plug and Play ACPI device, IDs PNP0a08 PNP0a03 (active)
pnp 00:01: [mem 0xfe000000-0xfebfffff]
pnp 00:01: Plug and Play ACPI device, IDs PNP0c01 (active)
pnp 00:02: [dma 4]
pnp 00:02: [io  0x0000-0x000f]
pnp 00:02: [io  0x0081-0x0083]
pnp 00:02: [io  0x0087]
pnp 00:02: [io  0x0089-0x008b]
pnp 00:02: [io  0x008f]
pnp 00:02: [io  0x00c0-0x00df]
pnp 00:02: Plug and Play ACPI device, IDs PNP0200 (active)
pnp 00:03: [io  0x0070-0x0071]
pnp 00:03: [irq 8]
pnp 00:03: Plug and Play ACPI device, IDs PNP0b00 (active)
pnp 00:04: [io  0x0061]
pnp 00:04: Plug and Play ACPI device, IDs PNP0800 (active)
pnp 00:05: [io  0x00f0-0x00ff]
pnp 00:05: [irq 13]
pnp 00:05: Plug and Play ACPI device, IDs PNP0c04 (active)
pnp 00:06: [io  0x03f8-0x03ff]
pnp 00:06: [irq 4]
pnp 00:06: [dma 0 disabled]
pnp 00:06: Plug and Play ACPI device, IDs PNP0501 (active)
pnp 00:07: [io  0x0000-0xffffffffffffffff disabled]
pnp 00:07: [io  0x0a00-0x0a7f]
pnp 00:07: [io  0x0a80-0x0a83]
pnp 00:07: [io  0x0a84-0x0a85]
pnp 00:07: [io  0x0a88-0x0a8f]
pnp 00:07: [io  0x0a90-0x0a9f]
pnp 00:07: [io  0x0b00-0x0bfe]
pnp 00:07: Plug and Play ACPI device, IDs PNP0c02 (active)
pnp 00:08: [io  0x0010-0x001f]
pnp 00:08: [io  0x0022-0x003f]
pnp 00:08: [io  0x0044-0x005f]
pnp 00:08: [io  0x0062-0x0063]
pnp 00:08: [io  0x0065-0x006f]
pnp 00:08: [io  0x0072-0x007f]
pnp 00:08: [io  0x0080]
pnp 00:08: [io  0x0084-0x0086]
pnp 00:08: [io  0x0088]
pnp 00:08: [io  0x008c-0x008e]
pnp 00:08: [io  0x0090-0x009f]
pnp 00:08: [io  0x00a2-0x00bf]
pnp 00:08: [io  0x00e0-0x00ef]
pnp 00:08: [mem 0xffa00000-0xfffffffe]
pnp 00:08: [io  0x0ca4-0x0ca5]
pnp 00:08: [io  0x0ca7-0x0ca8]
pnp 00:08: [io  0x0ca0]
pnp 00:08: [io  0x0ca1]
pnp 00:08: [io  0x0ca2]
pnp 00:08: [io  0x0ca3]
pnp 00:08: [io  0x04d0-0x04d1]
pnp 00:08: [io  0x0800-0x087f]
pnp 00:08: [io  0x0000-0xffffffffffffffff disabled]
pnp 00:08: [io  0x0480-0x04bf]
pnp 00:08: [mem 0xfed1c000-0xfed1ffff]
pnp 00:08: [mem 0xfed20000-0xfed8ffff]
pnp 00:08: Plug and Play ACPI device, IDs PNP0c02 (active)
pnp 00:09: [mem 0xfed00000-0xfed003ff]
pnp 00:09: Plug and Play ACPI device, IDs PNP0103 (active)
pnp 00:0a: [io  0x0060]
pnp 00:0a: [io  0x0064]
pnp 00:0a: [mem 0xfec00000-0xfec00fff]
pnp 00:0a: [mem 0xfee00000-0xfee00fff]
pnp 00:0a: Plug and Play ACPI device, IDs PNP0c02 (active)
pnp 00:0b: [mem 0xe0000000-0xefffffff]
pnp 00:0b: Plug and Play ACPI device, IDs PNP0c02 (active)
pnp 00:0c: [io  0x0ca2]
pnp 00:0c: [io  0x0ca3]
pnp 00:0c: Plug and Play ACPI device, IDs IPI0001 (active)
pnp 00:0d: [io  0x0ca0]
pnp 00:0d: Plug and Play ACPI device, IDs HPI0002 (active)
pnp 00:0e: [mem 0x00000000-0x0009ffff]
pnp 00:0e: [mem 0x000c0000-0x000cffff]
pnp 00:0e: [mem 0x000e0000-0x000fffff]
pnp 00:0e: [mem 0x00100000-0xdfffffff]
pnp 00:0e: [mem 0x00000000-0xffffffffffffffff disabled]
pnp 00:0e: disabling [mem 0x00000000-0x0009ffff] because it overlaps 0000:05:00.0 BAR 0 [mem 0x00000000-0x007fffff 64bit pref]
pnp 00:0e: disabling [mem 0x000c0000-0x000cffff] because it overlaps 0000:05:00.0 BAR 0 [mem 0x00000000-0x007fffff 64bit pref]
pnp 00:0e: disabling [mem 0x000e0000-0x000fffff] because it overlaps 0000:05:00.0 BAR 0 [mem 0x00000000-0x007fffff 64bit pref]
pnp 00:0e: disabling [mem 0x00100000-0xdfffffff] because it overlaps 0000:05:00.0 BAR 0 [mem 0x00000000-0x007fffff 64bit pref]
pnp 00:0e: disabling [mem 0x00000000-0x0009ffff disabled] because it overlaps 0000:0b:04.0 BAR 2 [mem 0x00000000-0x000fffff 64bit pref]
pnp 00:0e: disabling [mem 0x000c0000-0x000cffff disabled] because it overlaps 0000:0b:04.0 BAR 2 [mem 0x00000000-0x000fffff 64bit pref]
pnp 00:0e: disabling [mem 0x000e0000-0x000fffff disabled] because it overlaps 0000:0b:04.0 BAR 2 [mem 0x00000000-0x000fffff 64bit pref]
pnp 00:0e: Plug and Play ACPI device, IDs PNP0c01 (active)
pnp: PnP ACPI: found 15 devices
ACPI: ACPI bus type pnp unregistered
system 00:01: [mem 0xfe000000-0xfebfffff] has been reserved
system 00:07: [io  0x0a00-0x0a7f] has been reserved
system 00:07: [io  0x0a80-0x0a83] has been reserved
system 00:07: [io  0x0a84-0x0a85] has been reserved
system 00:07: [io  0x0a88-0x0a8f] has been reserved
system 00:07: [io  0x0a90-0x0a9f] has been reserved
system 00:07: [io  0x0b00-0x0bfe] has been reserved
system 00:08: [io  0x0ca4-0x0ca5] has been reserved
system 00:08: [io  0x0ca7-0x0ca8] has been reserved
system 00:08: [io  0x0ca0] has been reserved
system 00:08: [io  0x0ca1] has been reserved
system 00:08: [io  0x0ca2] has been reserved
system 00:08: [io  0x0ca3] has been reserved
system 00:08: [io  0x04d0-0x04d1] has been reserved
system 00:08: [io  0x0800-0x087f] has been reserved
system 00:08: [io  0x0480-0x04bf] has been reserved
system 00:08: [mem 0xffa00000-0xfffffffe] could not be reserved
system 00:08: [mem 0xfed1c000-0xfed1ffff] has been reserved
system 00:08: [mem 0xfed20000-0xfed8ffff] has been reserved
system 00:0a: [mem 0xfec00000-0xfec00fff] could not be reserved
system 00:0a: [mem 0xfee00000-0xfee00fff] has been reserved
system 00:0b: [mem 0xe0000000-0xefffffff] has been reserved
pci 0000:00:06.0: BAR 9: assigned [mem 0xff000000-0xffbfffff 64bit pref]
pci 0000:00:04.0: BAR 8: assigned [mem 0xffc00000-0xffdfffff]
pci 0000:00:04.0: BAR 9: assigned [mem 0xfcb00000-0xfccfffff 64bit pref]
pci 0000:00:1c.0: BAR 9: assigned [mem 0xfc900000-0xfcafffff 64bit pref]
pci 0000:00:1c.5: BAR 9: assigned [mem 0xfc700000-0xfc8fffff 64bit pref]
pci 0000:00:04.0: BAR 7: assigned [io  0xc000-0xcfff]
pci 0000:00:06.0: BAR 7: assigned [io  0xb000-0xbfff]
pci 0000:00:1c.0: BAR 7: assigned [io  0xa000-0xafff]
pci 0000:00:1c.4: BAR 7: assigned [io  0x9000-0x9fff]
pci 0000:00:1c.5: BAR 7: assigned [io  0x8000-0x8fff]
pci 0000:00:1f.3: BAR 0: assigned [mem 0xfeffff00-0xfeffffff 64bit]
pci 0000:00:1f.3: BAR 0: set to [mem 0xfeffff00-0xfeffffff 64bit] (PCI address [0xfeffff00-0xfeffffff])
pci 0000:00:02.0: PCI bridge to [bus 01-01]
pci 0000:00:02.0:   bridge window [io  disabled]
pci 0000:00:02.0:   bridge window [mem disabled]
pci 0000:00:02.0:   bridge window [mem pref disabled]
pci 0000:00:03.0: PCI bridge to [bus 02-02]
pci 0000:00:03.0:   bridge window [io  disabled]
pci 0000:00:03.0:   bridge window [mem disabled]
pci 0000:00:03.0:   bridge window [mem pref disabled]
pci 0000:00:04.0: PCI bridge to [bus 03-03]
pci 0000:00:04.0:   bridge window [io  0xc000-0xcfff]
pci 0000:00:04.0:   bridge window [mem 0xffc00000-0xffdfffff]
pci 0000:00:04.0:   bridge window [mem 0xfcb00000-0xfccfffff 64bit pref]
pci 0000:00:05.0: PCI bridge to [bus 04-04]
pci 0000:00:05.0:   bridge window [io  disabled]
pci 0000:00:05.0:   bridge window [mem disabled]
pci 0000:00:05.0:   bridge window [mem pref disabled]
pci 0000:05:00.0: BAR 0: assigned [mem 0xff000000-0xff7fffff 64bit pref]
pci 0000:05:00.0: BAR 0: set to [mem 0xff000000-0xff7fffff 64bit pref] (PCI address [0xff000000-0xff7fffff])
pci 0000:05:00.0: BAR 2: assigned [mem 0xffbfe000-0xffbfffff 64bit pref]
pci 0000:05:00.0: BAR 2: set to [mem 0xffbfe000-0xffbfffff 64bit pref] (PCI address [0xffbfe000-0xffbfffff])
pci 0000:05:00.0: BAR 4: assigned [mem 0xffbfc000-0xffbfdfff 64bit pref]
pci 0000:05:00.0: BAR 4: set to [mem 0xffbfc000-0xffbfdfff 64bit pref] (PCI address [0xffbfc000-0xffbfdfff])
pci 0000:00:06.0: PCI bridge to [bus 05-05]
pci 0000:00:06.0:   bridge window [io  0xb000-0xbfff]
pci 0000:00:06.0:   bridge window [mem 0xfce00000-0xfcefffff]
pci 0000:00:06.0:   bridge window [mem 0xff000000-0xffbfffff 64bit pref]
pci 0000:00:07.0: PCI bridge to [bus 06-06]
pci 0000:00:07.0:   bridge window [io  disabled]
pci 0000:00:07.0:   bridge window [mem disabled]
pci 0000:00:07.0:   bridge window [mem pref disabled]
pci 0000:09:00.0: BAR 9: assigned [mem 0xfc900000-0xfcafffff 64bit pref]
pci 0000:0b:04.0: BAR 2: assigned [mem 0xfca00000-0xfcafffff 64bit pref]
pci 0000:0b:04.0: BAR 2: set to [mem 0xfca00000-0xfcafffff 64bit pref] (PCI address [0xfca00000-0xfcafffff])
pci 0000:0b:04.0: BAR 0: assigned [mem 0xfc9f8000-0xfc9fffff 64bit pref]
pci 0000:0b:04.0: BAR 0: set to [mem 0xfc9f8000-0xfc9fffff 64bit pref] (PCI address [0xfc9f8000-0xfc9fffff])
pci 0000:0b:04.0: BAR 4: assigned [mem 0xfc9f7800-0xfc9f7fff 64bit pref]
pci 0000:0b:04.0: BAR 4: set to [mem 0xfc9f7800-0xfc9f7fff 64bit pref] (PCI address [0xfc9f7800-0xfc9f7fff])
pci 0000:09:00.0: PCI bridge to [bus 0b-0b]
pci 0000:09:00.0:   bridge window [io  disabled]
pci 0000:09:00.0:   bridge window [mem 0xfdf00000-0xfdffffff]
pci 0000:09:00.0:   bridge window [mem 0xfc900000-0xfcafffff 64bit pref]
pci 0000:09:00.1: PCI bridge to [bus 0a-0a]
pci 0000:09:00.1:   bridge window [io  disabled]
pci 0000:09:00.1:   bridge window [mem disabled]
pci 0000:09:00.1:   bridge window [mem pref disabled]
pci 0000:00:1c.0: PCI bridge to [bus 09-0b]
pci 0000:00:1c.0:   bridge window [io  0xa000-0xafff]
pci 0000:00:1c.0:   bridge window [mem 0xfde00000-0xfdffffff]
pci 0000:00:1c.0:   bridge window [mem 0xfc900000-0xfcafffff 64bit pref]
pci 0000:00:1c.4: PCI bridge to [bus 08-08]
pci 0000:00:1c.4:   bridge window [io  0x9000-0x9fff]
pci 0000:00:1c.4:   bridge window [mem 0xfd000000-0xfddfffff]
pci 0000:00:1c.4:   bridge window [mem 0xfb000000-0xfbffffff 64bit pref]
pci 0000:00:1c.5: PCI bridge to [bus 07-07]
pci 0000:00:1c.5:   bridge window [io  0x8000-0x8fff]
pci 0000:00:1c.5:   bridge window [mem 0xfcf00000-0xfcffffff]
pci 0000:00:1c.5:   bridge window [mem 0xfc700000-0xfc8fffff 64bit pref]
pci 0000:00:1e.0: PCI bridge to [bus 0c-0c]
pci 0000:00:1e.0:   bridge window [io  disabled]
pci 0000:00:1e.0:   bridge window [mem disabled]
pci 0000:00:1e.0:   bridge window [mem pref disabled]
pci 0000:00:02.0: setting latency timer to 64
pci 0000:00:03.0: setting latency timer to 64
pci 0000:00:04.0: enabling device (0104 -> 0107)
pci 0000:00:04.0: setting latency timer to 64
pci 0000:00:05.0: setting latency timer to 64
pci 0000:00:06.0: enabling device (0106 -> 0107)
pci 0000:00:06.0: setting latency timer to 64
pci 0000:00:07.0: setting latency timer to 64
pci 0000:00:1c.0: enabling device (0106 -> 0107)
pci 0000:00:1c.0: PCI INT A -> GSI 16 (level, low) -> IRQ 16
pci 0000:00:1c.0: setting latency timer to 64
pci 0000:09:00.0: setting latency timer to 64
pci 0000:09:00.1: PCI INT A -> GSI 16 (level, low) -> IRQ 16
pci 0000:09:00.1: setting latency timer to 64
pci 0000:00:1c.4: PCI INT A -> GSI 16 (level, low) -> IRQ 16
pci 0000:00:1c.4: setting latency timer to 64
pci 0000:00:1c.5: enabling device (0106 -> 0107)
pci 0000:00:1c.5: PCI INT B -> GSI 17 (level, low) -> IRQ 17
pci 0000:00:1c.5: setting latency timer to 64
pci 0000:00:1e.0: setting latency timer to 64
pci_bus 0000:00: resource 4 [io  0x0000-0x0bff]
pci_bus 0000:00: resource 5 [io  0x0d00-0xffff]
pci_bus 0000:00: resource 6 [mem 0x000a0000-0x000bffff]
pci_bus 0000:00: resource 7 [mem 0x000d0000-0x000dffff]
pci_bus 0000:00: resource 8 [mem 0xf0000000-0xffffffff]
pci_bus 0000:03: resource 0 [io  0xc000-0xcfff]
pci_bus 0000:03: resource 1 [mem 0xffc00000-0xffdfffff]
pci_bus 0000:03: resource 2 [mem 0xfcb00000-0xfccfffff 64bit pref]
pci_bus 0000:05: resource 0 [io  0xb000-0xbfff]
pci_bus 0000:05: resource 1 [mem 0xfce00000-0xfcefffff]
pci_bus 0000:05: resource 2 [mem 0xff000000-0xffbfffff 64bit pref]
pci_bus 0000:09: resource 0 [io  0xa000-0xafff]
pci_bus 0000:09: resource 1 [mem 0xfde00000-0xfdffffff]
pci_bus 0000:09: resource 2 [mem 0xfc900000-0xfcafffff 64bit pref]
pci_bus 0000:0b: resource 1 [mem 0xfdf00000-0xfdffffff]
pci_bus 0000:0b: resource 2 [mem 0xfc900000-0xfcafffff 64bit pref]
pci_bus 0000:08: resource 0 [io  0x9000-0x9fff]
pci_bus 0000:08: resource 1 [mem 0xfd000000-0xfddfffff]
pci_bus 0000:08: resource 2 [mem 0xfb000000-0xfbffffff 64bit pref]
pci_bus 0000:07: resource 0 [io  0x8000-0x8fff]
pci_bus 0000:07: resource 1 [mem 0xfcf00000-0xfcffffff]
pci_bus 0000:07: resource 2 [mem 0xfc700000-0xfc8fffff 64bit pref]
pci_bus 0000:0c: resource 4 [io  0x0000-0x0bff]
pci_bus 0000:0c: resource 5 [io  0x0d00-0xffff]
pci_bus 0000:0c: resource 6 [mem 0x000a0000-0x000bffff]
pci_bus 0000:0c: resource 7 [mem 0x000d0000-0x000dffff]
pci_bus 0000:0c: resource 8 [mem 0xf0000000-0xffffffff]
NET: Registered protocol family 2
IP route cache hash table entries: 262144 (order: 9, 2097152 bytes)
TCP established hash table entries: 524288 (order: 11, 8388608 bytes)
TCP bind hash table entries: 65536 (order: 8, 1048576 bytes)
TCP: Hash tables configured (established 524288 bind 65536)
TCP reno registered
UDP hash table entries: 4096 (order: 5, 131072 bytes)
UDP-Lite hash table entries: 4096 (order: 5, 131072 bytes)
NET: Registered protocol family 1
pci 0000:08:00.0: Boot video device
PCI: CLS 64 bytes, default 64
Unpacking initramfs...
Freeing initrd memory: 12200k freed
PCI-DMA: Using software bounce buffering for IO (SWIOTLB)
Placing 64MB software IO TLB between ffff8800dbc00000 - ffff8800dfc00000
software IO TLB at phys 0xdbc00000 - 0xdfc00000
audit: initializing netlink socket (disabled)
type=2000 audit(1292626705.684:1): initialized
HugeTLB registered 2 MB page size, pre-allocated 0 pages
VFS: Disk quotas dquot_6.5.2
Dquot-cache hash table entries: 512 (order 0, 4096 bytes)
msgmni has been set to 15864
Block layer SCSI generic (bsg) driver version 0.4 loaded (major 254)
io scheduler noop registered
io scheduler deadline registered
io scheduler cfq registered (default)
pcieport 0000:00:02.0: ACPI _OSC control granted for 0x1d
pcieport 0000:00:02.0: setting latency timer to 64
pcieport 0000:00:02.0: irq 40 for MSI/MSI-X
pcieport 0000:00:03.0: ACPI _OSC control granted for 0x1d
pcieport 0000:00:03.0: setting latency timer to 64
pcieport 0000:00:03.0: irq 41 for MSI/MSI-X
pcieport 0000:00:04.0: ACPI _OSC control granted for 0x1d
pcieport 0000:00:04.0: setting latency timer to 64
pcieport 0000:00:04.0: irq 42 for MSI/MSI-X
pcieport 0000:00:05.0: ACPI _OSC control granted for 0x1d
pcieport 0000:00:05.0: setting latency timer to 64
pcieport 0000:00:05.0: irq 43 for MSI/MSI-X
pcieport 0000:00:06.0: ACPI _OSC control granted for 0x1d
pcieport 0000:00:06.0: setting latency timer to 64
pcieport 0000:00:06.0: irq 44 for MSI/MSI-X
pcieport 0000:00:07.0: ACPI _OSC control granted for 0x1d
pcieport 0000:00:07.0: setting latency timer to 64
pcieport 0000:00:07.0: irq 45 for MSI/MSI-X
pcieport 0000:00:1c.0: ACPI _OSC control granted for 0x1d
pcieport 0000:00:1c.0: setting latency timer to 64
pcieport 0000:00:1c.0: irq 46 for MSI/MSI-X
pcieport 0000:00:1c.4: ACPI _OSC control granted for 0x1d
pcieport 0000:00:1c.4: setting latency timer to 64
pcieport 0000:00:1c.4: irq 47 for MSI/MSI-X
pcieport 0000:00:1c.5: ACPI _OSC control granted for 0x1d
pcieport 0000:00:1c.5: setting latency timer to 64
pcieport 0000:00:1c.5: irq 48 for MSI/MSI-X
aer 0000:00:02.0:pcie02: service driver aer loaded
aer 0000:00:03.0:pcie02: service driver aer loaded
aer 0000:00:04.0:pcie02: service driver aer loaded
aer 0000:00:05.0:pcie02: service driver aer loaded
aer 0000:00:06.0:pcie02: service driver aer loaded
aer 0000:00:07.0:pcie02: service driver aer loaded
vesafb: framebuffer at 0xfb000000, mapped to 0xffffc90011800000, using 3072k, total 8128k
vesafb: mode is 1024x768x16, linelength=2048, pages=4
vesafb: scrolling: redraw
vesafb: Truecolor: size=0:5:6:5, shift=0:11:5:0
Console: switching to colour frame buffer device 128x48
fb0: VESA VGA frame buffer device
Non-volatile memory driver v1.3
Linux agpgart interface v0.103
Serial: 8250/16550 driver, 8 ports, IRQ sharing disabled
serial8250: ttyS0 at I/O 0x3f8 (irq = 4) is a 16550A
00:06: ttyS0 at I/O 0x3f8 (irq = 4) is a 16550A
PNP: No PS/2 controller found. Probing ports directly.
Clocksource tsc unstable (delta = -8588848793 ns)
Switching to clocksource hpet
serio: i8042 KBD port at 0x60,0x64 irq 1
mice: PS/2 mouse device common for all mice
cpuidle: using governor ladder
cpuidle: using governor menu
TCP cubic registered
Registering the dns_resolver key type
registered taskstats version 1
Freeing unused kernel memory: 1260k freed
Write protecting the kernel read-only data: 6144k
Freeing unused kernel memory: 1136k freed
Freeing unused kernel memory: 460k freed
ACPI: acpi_idle registered with cpuidle
SCSI subsystem initialized
libata version 3.00 loaded.
ata_piix 0000:00:1f.2: version 2.13
ata_piix 0000:00:1f.2: PCI INT B -> GSI 19 (level, low) -> IRQ 19
ata_piix 0000:00:1f.2: MAP [ P0 P2 P1 P3 ]
ata_piix 0000:00:1f.2: setting latency timer to 64
scsi0 : ata_piix
scsi1 : ata_piix
ata1: SATA max UDMA/133 cmd 0x1f0 ctl 0x3f6 bmdma 0xff90 irq 14
ata2: SATA max UDMA/133 cmd 0x170 ctl 0x376 bmdma 0xff98 irq 15
ata_piix 0000:00:1f.5: PCI INT B -> GSI 19 (level, low) -> IRQ 19
ata_piix 0000:00:1f.5: MAP [ P0 -- P1 -- ]
ata_piix 0000:00:1f.5: setting latency timer to 64
scsi2 : ata_piix
scsi3 : ata_piix
ata3: SATA max UDMA/133 cmd 0xe000 ctl 0xdc00 bmdma 0xd480 irq 19
ata4: SATA max UDMA/133 cmd 0xd880 ctl 0xd800 bmdma 0xd488 irq 19
ata4: SATA link down (SStatus 0 SControl 300)
ata3: SATA link up 1.5 Gbps (SStatus 113 SControl 300)
ata3.00: ATAPI: TSSTcorpDVD-ROM TS-H353B, IG01, max UDMA/100
ata3.00: configured for UDMA/100
ata1.00: SATA link down (SStatus 0 SControl 300)
ata1.01: SATA link down (SStatus 0 SControl 300)
ata2.00: SATA link up 1.5 Gbps (SStatus 113 SControl 300)
ata2.01: SATA link down (SStatus 0 SControl 300)
ata2.00: ATA-7: GB0160CAABV,     HPG1, max UDMA/100
ata2.00: 312581808 sectors, multi 16: LBA48 NCQ (depth 0/32)
ata2.00: configured for UDMA/100
scsi 1:0:0:0: Direct-Access     ATA      GB0160CAABV      n/a  PQ: 0 ANSI: 5
scsi 2:0:0:0: CD-ROM            TSSTcorp DVD-ROM TS-H353B IG01 PQ: 0 ANSI: 5
Uniform Multi-Platform E-IDE driver
BIOS EDD facility v0.16 2004-Jun-25, 1 devices found
udevd (89): /proc/89/oom_adj is deprecated, please use /proc/89/oom_score_adj instead.
udevd version 128 started
usbcore: registered new interface driver usbfs
usbcore: registered new interface driver hub
sd 1:0:0:0: [sda] 312581808 512-byte logical blocks: (160 GB/149 GiB)
sd 1:0:0:0: [sda] Write Protect is off
sd 1:0:0:0: [sda] Mode Sense: 00 3a 00 00
sd 1:0:0:0: [sda] Write cache: disabled, read cache: enabled, doesn't support DPO or FUA
 sda: sda1 sda2
usbcore: registered new device driver usb
sd 1:0:0:0: [sda] Attached SCSI disk
ehci_hcd: USB 2.0 'Enhanced' Host Controller (EHCI) Driver
ehci_hcd 0000:00:1a.7: PCI INT C -> GSI 18 (level, low) -> IRQ 18
ehci_hcd 0000:00:1a.7: setting latency timer to 64
ehci_hcd 0000:00:1a.7: EHCI Host Controller
ehci_hcd 0000:00:1a.7: new USB bus registered, assigned bus number 1
ehci_hcd 0000:00:1a.7: debug port 1
ehci_hcd 0000:00:1a.7: cache line size of 64 is not supported
ehci_hcd 0000:00:1a.7: irq 18, io mem 0xfcdffc00
ehci_hcd 0000:00:1a.7: USB 2.0 started, EHCI 1.00
usb usb1: New USB device found, idVendor=1d6b, idProduct=0002
usb usb1: New USB device strings: Mfr=3, Product=2, SerialNumber=1
usb usb1: Product: EHCI Host Controller
usb usb1: Manufacturer: Linux 2.6.37-rc1-5-default ehci_hcd
usb usb1: SerialNumber: 0000:00:1a.7
hub 1-0:1.0: USB hub found
hub 1-0:1.0: 6 ports detected
ehci_hcd 0000:00:1d.7: PCI INT A -> GSI 23 (level, low) -> IRQ 23
ehci_hcd 0000:00:1d.7: setting latency timer to 64
ehci_hcd 0000:00:1d.7: EHCI Host Controller
ehci_hcd 0000:00:1d.7: new USB bus registered, assigned bus number 2
ehci_hcd 0000:00:1d.7: debug port 1
ehci_hcd 0000:00:1d.7: cache line size of 64 is not supported
ehci_hcd 0000:00:1d.7: irq 23, io mem 0xfcdff800
ehci_hcd 0000:00:1d.7: USB 2.0 started, EHCI 1.00
usb usb2: New USB device found, idVendor=1d6b, idProduct=0002
usb usb2: New USB device strings: Mfr=3, Product=2, SerialNumber=1
usb usb2: Product: EHCI Host Controller
usb usb2: Manufacturer: Linux 2.6.37-rc1-5-default ehci_hcd
usb usb2: SerialNumber: 0000:00:1d.7
hub 2-0:1.0: USB hub found
hub 2-0:1.0: 6 ports detected
uhci_hcd: USB Universal Host Controller Interface driver
uhci_hcd 0000:00:1a.0: PCI INT A -> GSI 16 (level, low) -> IRQ 16
uhci_hcd 0000:00:1a.0: setting latency timer to 64
uhci_hcd 0000:00:1a.0: UHCI Host Controller
uhci_hcd 0000:00:1a.0: new USB bus registered, assigned bus number 3
uhci_hcd 0000:00:1a.0: irq 16, io base 0x0000e800
usb usb3: New USB device found, idVendor=1d6b, idProduct=0001
usb usb3: New USB device strings: Mfr=3, Product=2, SerialNumber=1
usb usb3: Product: UHCI Host Controller
usb usb3: Manufacturer: Linux 2.6.37-rc1-5-default uhci_hcd
usb usb3: SerialNumber: 0000:00:1a.0
hub 3-0:1.0: USB hub found
hub 3-0:1.0: 2 ports detected
uhci_hcd 0000:00:1a.1: PCI INT B -> GSI 21 (level, low) -> IRQ 21
uhci_hcd 0000:00:1a.1: setting latency timer to 64
uhci_hcd 0000:00:1a.1: UHCI Host Controller
uhci_hcd 0000:00:1a.1: new USB bus registered, assigned bus number 4
uhci_hcd 0000:00:1a.1: irq 21, io base 0x0000e880
usb usb4: New USB device found, idVendor=1d6b, idProduct=0001
usb usb4: New USB device strings: Mfr=3, Product=2, SerialNumber=1
usb usb4: Product: UHCI Host Controller
usb usb4: Manufacturer: Linux 2.6.37-rc1-5-default uhci_hcd
usb usb4: SerialNumber: 0000:00:1a.1
hub 4-0:1.0: USB hub found
hub 4-0:1.0: 2 ports detected
uhci_hcd 0000:00:1a.2: PCI INT D -> GSI 19 (level, low) -> IRQ 19
uhci_hcd 0000:00:1a.2: setting latency timer to 64
uhci_hcd 0000:00:1a.2: UHCI Host Controller
uhci_hcd 0000:00:1a.2: new USB bus registered, assigned bus number 5
uhci_hcd 0000:00:1a.2: irq 19, io base 0x0000ec00
usb usb5: New USB device found, idVendor=1d6b, idProduct=0001
usb usb5: New USB device strings: Mfr=3, Product=2, SerialNumber=1
usb usb5: Product: UHCI Host Controller
usb usb5: Manufacturer: Linux 2.6.37-rc1-5-default uhci_hcd
usb usb5: SerialNumber: 0000:00:1a.2
hub 5-0:1.0: USB hub found
hub 5-0:1.0: 2 ports detected
uhci_hcd 0000:00:1d.0: PCI INT A -> GSI 23 (level, low) -> IRQ 23
uhci_hcd 0000:00:1d.0: setting latency timer to 64
uhci_hcd 0000:00:1d.0: UHCI Host Controller
uhci_hcd 0000:00:1d.0: new USB bus registered, assigned bus number 6
uhci_hcd 0000:00:1d.0: irq 23, io base 0x0000e080
usb usb6: New USB device found, idVendor=1d6b, idProduct=0001
usb usb6: New USB device strings: Mfr=3, Product=2, SerialNumber=1
usb usb6: Product: UHCI Host Controller
usb usb6: Manufacturer: Linux 2.6.37-rc1-5-default uhci_hcd
usb usb6: SerialNumber: 0000:00:1d.0
hub 6-0:1.0: USB hub found
hub 6-0:1.0: 2 ports detected
uhci_hcd 0000:00:1d.1: PCI INT B -> GSI 19 (level, low) -> IRQ 19
uhci_hcd 0000:00:1d.1: setting latency timer to 64
uhci_hcd 0000:00:1d.1: UHCI Host Controller
uhci_hcd 0000:00:1d.1: new USB bus registered, assigned bus number 7
uhci_hcd 0000:00:1d.1: irq 19, io base 0x0000e400
usb 6-1: new full speed USB device using uhci_hcd and address 2
usb usb7: New USB device found, idVendor=1d6b, idProduct=0001
usb usb7: New USB device strings: Mfr=3, Product=2, SerialNumber=1
usb usb7: Product: UHCI Host Controller
usb usb7: Manufacturer: Linux 2.6.37-rc1-5-default uhci_hcd
usb usb7: SerialNumber: 0000:00:1d.1
hub 7-0:1.0: USB hub found
hub 7-0:1.0: 2 ports detected
uhci_hcd 0000:00:1d.2: PCI INT C -> GSI 18 (level, low) -> IRQ 18
usb 6-1: New USB device found, idVendor=0000, idProduct=0000
usb 6-1: New USB device strings: Mfr=1, Product=2, SerialNumber=3
usb 6-1: Product: SE USB Device
usb 6-1: Manufacturer: ServerEngines
usb 6-1: SerialNumber: 601615E48484F2
uhci_hcd 0000:00:1d.2: setting latency timer to 64
uhci_hcd 0000:00:1d.2: UHCI Host Controller
uhci_hcd 0000:00:1d.2: new USB bus registered, assigned bus number 8
uhci_hcd 0000:00:1d.2: irq 18, io base 0x0000e480
usb usb8: New USB device found, idVendor=1d6b, idProduct=0001
usb usb8: New USB device strings: Mfr=3, Product=2, SerialNumber=1
usb usb8: Product: UHCI Host Controller
usb usb8: Manufacturer: Linux 2.6.37-rc1-5-default uhci_hcd
usb usb8: SerialNumber: 0000:00:1d.2
hub 8-0:1.0: USB hub found
hub 8-0:1.0: 2 ports detected
input: ServerEngines SE USB Device as /devices/pci0000:00/0000:00:1d.0/usb6/6-1/6-1:1.0/input/input0
generic-usb 0003:0000:0000.0001: input,hidraw0: USB HID v1.11 Keyboard [ServerEngines SE USB Device] on usb-0000:00:1d.0-1/input0
input: ServerEngines SE USB Device as /devices/pci0000:00/0000:00:1d.0/usb6/6-1/6-1:1.1/input/input1
generic-usb 0003:0000:0000.0002: input,hidraw1: USB HID v1.11 Mouse [ServerEngines SE USB Device] on usb-0000:00:1d.0-1/input1
usbcore: registered new interface driver usbhid
usbhid: USB HID core driver
PM: Starting manual resume from disk
EXT3-fs: barriers not enabled
kjournald starting.  Commit interval 5 seconds
EXT3-fs (sda2): using internal journal
EXT3-fs (sda2): mounted filesystem with ordered data mode
udevd version 128 started
sd 1:0:0:0: Attached scsi generic sg0 type 0
scsi 2:0:0:0: Attached scsi generic sg1 type 5
input: PC Speaker as /devices/platform/pcspkr/input/input2
vxge: Copyright(c) 2002-2010 Exar Corp.
vxge: Driver version: 2.0.9.20840-k
vxge 0000:05:00.0: PCI INT A -> GSI 16 (level, low) -> IRQ 16
vxge 0000:05:00.0: setting latency timer to 64
vxge: Reading of hardware info failed.Please try upgrading the firmware.
vxge 0000:05:00.0: PCI INT A disabled
vxge: probe of 0000:05:00.0 failed with error -22
pci_hotplug: PCI Hot Plug PCI Core version: 0.5
iTCO_vendor_support: vendor-support=0
sr0: scsi3-mmc drive: 62x/62x cd/rw xa/form2 cdda tray
cdrom: Uniform CD-ROM driver Revision: 3.20
sr 2:0:0:0: Attached scsi CD-ROM sr0
input: Power Button as /devices/LNXSYSTM:00/device:00/PNP0C0C:00/input/input3
ACPI: Power Button [PWRB]
input: Power Button as /devices/LNXSYSTM:00/LNXPWRBN:00/input/input4
ACPI: Power Button [PWRF]
i801_smbus 0000:00:1f.3: PCI INT C -> GSI 18 (level, low) -> IRQ 18
iTCO_wdt: Intel TCO WatchDog Timer Driver v1.06
iTCO_wdt: Found a ICH9R TCO device (Version=2, TCOBASE=0x0860)
iTCO_wdt: initialized. heartbeat=30 sec (nowayout=0)
shpchp: Standard Hot Plug PCI Controller Driver version: 0.4
S2IO 0000:0b:04.0: PCI INT A -> GSI 16 (level, low) -> IRQ 16
S2IO 0000:0b:04.0: irq 49 for MSI/MSI-X
S2IO 0000:0b:04.0: irq 50 for MSI/MSI-X
tg3.c:v3.115 (October 14, 2010)
tg3 0000:07:00.0: PCI INT A -> GSI 17 (level, low) -> IRQ 17
tg3 0000:07:00.0: setting latency timer to 64
EDAC MC: Ver: 2.1.0 Dec 15 2010
rtc_cmos 00:03: RTC can wake from S4
S2IO 0000:0b:04.0: restoring config space at offset 0x1 (was 0x2300042, writing 0x2300046)
rtc_cmos 00:03: rtc core: registered rtc_cmos as rtc0
rtc0: alarms up to one month, y3k, 114 bytes nvram, hpet irqs
tg3 0000:07:00.0: eth1: Tigon3 [partno(N/A) rev a200] (PCI Express) MAC address 00:1e:0b:fc:9c:2b
tg3 0000:07:00.0: eth1: attached PHY is 5722/5756 (10/100/1000Base-T Ethernet) (WireSpeed[1])
tg3 0000:07:00.0: eth1: RXcsums[1] LinkChgREG[0] MIirq[0] ASF[0] TSOcap[1]
tg3 0000:07:00.0: eth1: dma_rwctrl[76180000] dma_mask[64-bit]
EDAC MC0: Giving out device to 'i5100_edac.c' 'i5100': DEV 0000:00:10.1
s2io: Copyright(c) 2002-2010 Exar Corp.
s2io: eth0: Neterion 10 Gigabit Ethernet-SR PCIe 1.0a Adapter (rev 2)
s2io: eth0: Driver version 2.0.26.27
s2io: eth0: MAC Address: 00:0c:fc:00:39:f3
s2io: Serial number: SXT0721133
s2io: eth0: Device is on PCI-E bus
s2io: eth0: 1-Buffer receive mode enabled
s2io: eth0: NAPI enabled
s2io: eth0: Using 5 Tx fifo(s)
s2io: eth0: Using 1 Rx ring(s)
s2io: eth0: Interrupt type MSI-X
s2io: eth0: Multiqueue support disabled
s2io: eth0: Default steering enabled for transmit
s2io: eth0: Large receive offload enabled
Adding 2104476k swap on /dev/sda1.  Priority:-1 extents:1 across:2104476k
device-mapper: uevent: version 1.0.3
device-mapper: ioctl: 4.18.0-ioctl (2010-06-29) initialised: dm-devel@redhat.com
loop: module loaded
fuse init (API version 7.15)
microcode: CPU0 sig=0x10676, pf=0x40, revision=0x60c
microcode: CPU1 sig=0x10676, pf=0x40, revision=0x60c
microcode: CPU2 sig=0x10676, pf=0x40, revision=0x60c
microcode: CPU3 sig=0x10676, pf=0x40, revision=0x60c
microcode: Microcode Update Driver: v2.00 <tigran@aivazian.fsnet.co.uk>, Peter Oruba
tg3 0000:07:00.0: irq 49 for MSI/MSI-X
tg3 0000:07:00.0: eth1: Link is up at 100 Mbps, full duplex
tg3 0000:07:00.0: eth1: Flow control is off for TX and off for RX
NET: Registered protocol family 10
lo: Disabled Privacy Extensions
eth1: no IPv6 routers present

The information and any attached documents contained in this message
may be confidential and/or legally privileged.  The message is
intended solely for the addressee(s).  If you are not the intended
recipient, you are hereby notified that any use, dissemination, or
reproduction is strictly prohibited and may be unlawful.  If you are
not the intended recipient, please contact the sender immediately by
return e-mail and destroy all copies of the original message.
