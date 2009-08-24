From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: [PATCH 2.6.30-rc4] r8169: avoid losing MSI interrupts
Date: Sun, 23 Aug 2009 19:37:02 -0700
Message-ID: <m1eir2djjl.fsf@fess.ebiederm.org>
References: <200903041828.49972.m.bueker@berlin.de>
	<1242001754.4093.12.camel@obelisk.thedillows.org>
	<200905112248.44868.mb@bu3sch.de> <200905112310.08534.mb@bu3sch.de>
	<1242077392.3716.15.camel@lap75545.ornl.gov>
	<4A09DC3E.2080807@googlemail.com>
	<1242268709.4979.7.camel@obelisk.thedillows.org>
	<4A0C6504.8000704@googlemail.com>
	<1242328457.32579.12.camel@lap75545.ornl.gov>
	<4A0C7443.1010000@googlemail.com>
	<1243042174.3580.23.camel@obelisk.thedillows.org>
	<m1skfkrik2.fsf@fess.ebiederm.org>
	<1250895567.23419.1.camel@obelisk.thedillows.org>
	<1250897657.23419.5.camel@obelisk.thedillows.org>
	<m1iqggf4rf.fsf@fess.ebiederm.org> <m18whcf3w2.fsf@fess.ebiederm.org>
	<1250973787.3582.14.camel@obelisk.thedillows.org>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="=-=-="
Cc: Michael Riepe <michael.riepe@googlemail.com>,
	Michael Buesch <mb@bu3sch.de>,
	Francois Romieu <romieu@fr.zoreil.com>,
	Rui Santos <rsantos@grupopie.com>,
	Michael =?utf-8?Q?B=C3=BCker?= <m.bueker@berlin.de>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: David Dillow <dave@thedillows.org>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1751318AbZHXChP@vger.kernel.org>
In-Reply-To: <1250973787.3582.14.camel@obelisk.thedillows.org> (David Dillow's message of "Sat\, 22 Aug 2009 16\:43\:07 -0400")
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--=-=-=

David Dillow <dave@thedillows.org> writes:

> On Sat, 2009-08-22 at 05:07 -0700, Eric W. Biederman wrote:
>> ebiederm@xmission.com (Eric W. Biederman) writes:
>> 
>> > David Dillow <dave@thedillows.org> writes:
>> >
>> >>
>> >> Re-looking at the code, I'd guess that some IRQ status line is getting
>> >> stuck high, but I don't see why -- we should acknowledge all outstanding
>> >> interrupts each time through the loop, whether we care about them or
>> >> not.
>> >>
>> >> Could reproduce a problem with the following patch applied, and send the
>> >> full dmesg, please?
>> >
>> > Here is what I get.
>> >
>> > r8169 screaming irq status 00000085 mask 0000ffff event 0000803f napi 0000001d
>> 
>> And now that the machine has come out of it, that was followed by:
>> Looks like the soft lockup did not manage to trigger in this case.
>
> I need some more context, please. What is the network load through this
> NIC when you have the issues? Light, heavy? Can you give me more details
> about the machine? A full dmesg from boot until this happens would help
> quite a bit. At a minimum it would help answer which version of the chip
> we're dealing with and what the machine it is in looks like.

dmesg attached.

What seems to reproduce the problem is a download of about a gigabyte.
Which this machine does every hour or two.  The switch and the upstream
server are all 10Gig. So at least in bursts I expect I am saturating
the network adapter with traffic coming in as fast as it can come.

Last night I reverted your patch and the machine seems to be happy
and not having problems since then.

> Can you reproduce this with pci=nomsi? I'm assuming it the chip running
> in MSI mode.

It is.

> Also, can you reproduce it when booting UP (or maxcpus=1)? I'm thinking
> about a race between rtl8169_interrupt() and rtl8169_poll(), but it
> isn't jumping out at me.
>
> Also, I'm having connectivity troubles this weekend, so my response may
> be spotty. :(

No problem.

I haven't wrapped my head around the device specific bits but I suspect
we are simply receiving more packets while the interrupt handler is
running.

Eric


--=-=-=
Content-Disposition: attachment; filename=bs5-dmesg1.txt

Initializing cgroup subsys cpuset
Linux version 2.6.30eric-rtl8169-debug (ebiederm@maxwell.aristanetworks.com.) (gcc version 4.4.1 20090725 (Red Hat 4.4.1-2) (GCC) ) #36 SMP Fri Aug 21 18:30:36 PDT 2009
Command line: ro root=LABEL=/ rhgb quiet 8250.nr_uarts=16 crashkernel=128M
KERNEL supported cpus:
  Intel GenuineIntel
  AMD AuthenticAMD
  Centaur CentaurHauls
BIOS-provided physical RAM map:
 BIOS-e820: 0000000000000000 - 000000000009e800 (usable)
 BIOS-e820: 000000000009f800 - 00000000000a0000 (reserved)
 BIOS-e820: 00000000000f0000 - 0000000000100000 (reserved)
 BIOS-e820: 0000000000100000 - 00000000cf5e0000 (usable)
 BIOS-e820: 00000000cf5e0000 - 00000000cf5e3000 (ACPI NVS)
 BIOS-e820: 00000000cf5e3000 - 00000000cf5f0000 (ACPI data)
 BIOS-e820: 00000000cf5f0000 - 00000000cf600000 (reserved)
 BIOS-e820: 00000000d0000000 - 00000000e0000000 (reserved)
 BIOS-e820: 00000000fec00000 - 0000000100000000 (reserved)
 BIOS-e820: 0000000100000000 - 0000000130000000 (usable)
DMI 2.4 present.
last_pfn = 0x130000 max_arch_pfn = 0x100000000
MTRR default type: uncachable
MTRR fixed ranges enabled:
  00000-9FFFF write-back
  A0000-BFFFF uncachable
  C0000-CAFFF write-protect
  CB000-EFFFF uncachable
  F0000-FFFFF write-through
MTRR variable ranges enabled:
  0 base 100000000 mask FC0000000 write-back
  1 base 130000000 mask FF0000000 uncachable
  2 base 0C0000000 mask FF0000000 write-back
  3 base 0CF800000 mask FFF800000 uncachable
  4 base 0CF700000 mask FFFF00000 uncachable
  5 base 080000000 mask FC0000000 write-back
  6 base 000000000 mask F80000000 write-back
  7 base 0CF600000 mask FFFF00000 write-through
x86 PAT enabled: cpu 0, old 0x7040600070406, new 0x7010600070106
last_pfn = 0xcf5e0 max_arch_pfn = 0x100000000
init_memory_mapping: 0000000000000000-00000000cf5e0000
 0000000000 - 00cf400000 page 2M
 00cf400000 - 00cf5e0000 page 4k
kernel direct mapping tables up to cf5e0000 @ 8000-e000
init_memory_mapping: 0000000100000000-0000000130000000
 0100000000 - 0130000000 page 2M
kernel direct mapping tables up to 130000000 @ c000-12000
RAMDISK: 37cd1000 - 37fef789
ACPI: RSDP 00000000000f6f40 00014 (v00 GBT   )
ACPI: RSDT 00000000cf5e3040 0003C (v01 GBT    GBTUACPI 42302E31 GBTU 01010101)
ACPI: FACP 00000000cf5e30c0 00074 (v01 GBT    GBTUACPI 42302E31 GBTU 01010101)
ACPI: DSDT 00000000cf5e3180 054DD (v01 GBT    GBTUACPI 00001000 MSFT 0100000C)
ACPI: FACS 00000000cf5e0000 00040
ACPI: HPET 00000000cf5e87c0 00038 (v01 GBT    GBTUACPI 42302E31 GBTU 00000098)
ACPI: MCFG 00000000cf5e8840 0003C (v01 GBT    GBTUACPI 42302E31 GBTU 01010101)
ACPI: APIC 00000000cf5e86c0 00084 (v01 GBT    GBTUACPI 42302E31 GBTU 01010101)
ACPI: SSDT 00000000cf5e88c0 0015C (v01  PmRef  Cpu0Ist 00003000 INTL 20040311)
ACPI: SSDT 00000000cf5e8e70 00275 (v01  PmRef    CpuPm 00003000 INTL 20040311)
ACPI: Local APIC address 0xfee00000
No NUMA configuration found
Faking a node at 0000000000000000-0000000130000000
Bootmem setup node 0 0000000000000000-0000000130000000
  NODE_DATA [000000000000d000 - 0000000000021fff]
  bootmap [0000000000022000 -  0000000000047fff] pages 26
(8 early reservations) ==> bootmem [0000000000 - 0130000000]
  #0 [0000000000 - 0000001000]   BIOS data page ==> [0000000000 - 0000001000]
  #1 [0000006000 - 0000008000]       TRAMPOLINE ==> [0000006000 - 0000008000]
  #2 [0000200000 - 0000961968]    TEXT DATA BSS ==> [0000200000 - 0000961968]
  #3 [0037cd1000 - 0037fef789]          RAMDISK ==> [0037cd1000 - 0037fef789]
  #4 [000009e800 - 0000100000]    BIOS reserved ==> [000009e800 - 0000100000]
  #5 [0000962000 - 00009620ee]              BRK ==> [0000962000 - 00009620ee]
  #6 [0000008000 - 000000c000]          PGTABLE ==> [0000008000 - 000000c000]
  #7 [000000c000 - 000000d000]          PGTABLE ==> [000000c000 - 000000d000]
found SMP MP-table at [ffff8800000f55a0] f55a0
Reserving 128MB of memory at 16MB for crashkernel (System RAM: 4864MB)
 [ffffe20000000000-ffffe200043fffff] PMD -> [ffff880028200000-ffff88002bbfffff] on node 0
Zone PFN ranges:
  DMA      0x00000000 -> 0x00001000
  DMA32    0x00001000 -> 0x00100000
  Normal   0x00100000 -> 0x00130000
Movable zone start PFN for each node
early_node_map[3] active PFN ranges
    0: 0x00000000 -> 0x0000009e
    0: 0x00000100 -> 0x000cf5e0
    0: 0x00100000 -> 0x00130000
On node 0 totalpages: 1045886
  DMA zone: 56 pages used for memmap
  DMA zone: 1994 pages reserved
  DMA zone: 1948 pages, LIFO batch:0
  DMA32 zone: 14280 pages used for memmap
  DMA32 zone: 831000 pages, LIFO batch:31
  Normal zone: 2688 pages used for memmap
  Normal zone: 193920 pages, LIFO batch:31
ACPI: PM-Timer IO Port: 0x408
ACPI: Local APIC address 0xfee00000
ACPI: LAPIC (acpi_id[0x00] lapic_id[0x00] enabled)
ACPI: LAPIC (acpi_id[0x01] lapic_id[0x03] enabled)
ACPI: LAPIC (acpi_id[0x02] lapic_id[0x02] enabled)
ACPI: LAPIC (acpi_id[0x03] lapic_id[0x01] enabled)
ACPI: LAPIC_NMI (acpi_id[0x00] dfl dfl lint[0x1])
ACPI: LAPIC_NMI (acpi_id[0x01] dfl dfl lint[0x1])
ACPI: LAPIC_NMI (acpi_id[0x02] dfl dfl lint[0x1])
ACPI: LAPIC_NMI (acpi_id[0x03] dfl dfl lint[0x1])
ACPI: IOAPIC (id[0x02] address[0xfec00000] gsi_base[0])
IOAPIC[0]: apic_id 2, version 0, address 0xfec00000, GSI 0-23
ACPI: INT_SRC_OVR (bus 0 bus_irq 0 global_irq 2 dfl dfl)
ACPI: INT_SRC_OVR (bus 0 bus_irq 9 global_irq 9 high level)
ACPI: IRQ0 used by override.
ACPI: IRQ2 used by override.
ACPI: IRQ9 used by override.
Using ACPI (MADT) for SMP configuration information
ACPI: HPET id: 0x8086a201 base: 0xfed00000
SMP: Allowing 4 CPUs, 0 hotplug CPUs
nr_irqs_gsi: 24
PM: Registered nosave memory: 000000000009e000 - 00000000000a0000
PM: Registered nosave memory: 00000000000a0000 - 00000000000f0000
PM: Registered nosave memory: 00000000000f0000 - 0000000000100000
PM: Registered nosave memory: 00000000cf5e0000 - 00000000cf5e3000
PM: Registered nosave memory: 00000000cf5e3000 - 00000000cf5f0000
PM: Registered nosave memory: 00000000cf5f0000 - 00000000cf600000
PM: Registered nosave memory: 00000000cf600000 - 00000000d0000000
PM: Registered nosave memory: 00000000d0000000 - 00000000e0000000
PM: Registered nosave memory: 00000000e0000000 - 00000000fec00000
PM: Registered nosave memory: 00000000fec00000 - 0000000100000000
Allocating PCI resources starting at e2000000 (gap: e0000000:1ec00000)
NR_CPUS:64 nr_cpumask_bits:64 nr_cpu_ids:4 nr_node_ids:1
PERCPU: Embedded 25 pages at ffff880028022000, static data 72160 bytes
Built 1 zonelists in Node order, mobility grouping on.  Total pages: 1026868
Policy zone: Normal
Kernel command line: ro root=LABEL=/ rhgb quiet 8250.nr_uarts=16 crashkernel=128M
Initializing CPU#0
NR_IRQS:4352 nr_irqs:440
PID hash table entries: 4096 (order: 12, 32768 bytes)
Fast TSC calibration using PIT
Detected 2399.928 MHz processor.
Console: colour VGA+ 80x25
console [tty0] enabled
Checking aperture...
No AGP bridge found
Calgary: detecting Calgary via BIOS EBDA area
Calgary: Unable to locate Rio Grande table in EBDA - bailing!
PCI-DMA: Using software bounce buffering for IO (SWIOTLB)
Placing 64MB software IO TLB between ffff880020000000 - ffff880024000000
software IO TLB at phys 0x20000000 - 0x24000000
Memory: 3915580k/4980736k available (3571k kernel code, 797192k absent, 267964k reserved, 1887k data, 1280k init)
SLUB: Genslabs=14, HWalign=64, Order=0-3, MinObjects=0, CPUs=4, Nodes=1
hpet clockevent registered
HPET: 4 timers in total, 0 timers will be used for per-cpu timer
Calibrating delay loop (skipped), value calculated using timer frequency.. 4799.85 BogoMIPS (lpj=9599712)
Security Framework initialized
SELinux:  Initializing.
SELinux:  Starting in permissive mode
Dentry cache hash table entries: 524288 (order: 10, 4194304 bytes)
Inode-cache hash table entries: 262144 (order: 9, 2097152 bytes)
Mount-cache hash table entries: 256
Initializing cgroup subsys cpuacct
Initializing cgroup subsys devices
Initializing cgroup subsys freezer
CPU: L1 I cache: 32K, L1 D cache: 32K
CPU: L2 cache: 4096K
CPU 0/0x0 -> Node 0
CPU: Physical Processor ID: 0
CPU: Processor Core ID: 0
CPU0: Thermal monitoring enabled (TM2)
using mwait in idle threads.
ACPI: Core revision 20090320
Setting APIC routing to flat
..TIMER: vector=0x30 apic1=0 pin1=2 apic2=-1 pin2=-1
CPU0: Intel(R) Core(TM)2 Quad CPU    Q6600  @ 2.40GHz stepping 0b
Booting processor 1 APIC 0x3 ip 0x6000
Initializing CPU#1
Calibrating delay using timer specific routine.. 4800.02 BogoMIPS (lpj=9600054)
CPU: L1 I cache: 32K, L1 D cache: 32K
CPU: L2 cache: 4096K
CPU 1/0x3 -> Node 0
CPU: Physical Processor ID: 0
CPU: Processor Core ID: 3
CPU1: Thermal monitoring enabled (TM2)
x86 PAT enabled: cpu 1, old 0x7040600070406, new 0x7010600070106
CPU1: Intel(R) Core(TM)2 Quad CPU    Q6600  @ 2.40GHz stepping 0b
checking TSC synchronization [CPU#0 -> CPU#1]: passed.
Booting processor 2 APIC 0x2 ip 0x6000
Initializing CPU#2
Calibrating delay using timer specific routine.. 4799.98 BogoMIPS (lpj=9599971)
CPU: L1 I cache: 32K, L1 D cache: 32K
CPU: L2 cache: 4096K
CPU 2/0x2 -> Node 0
CPU: Physical Processor ID: 0
CPU: Processor Core ID: 2
CPU2: Thermal monitoring enabled (TM2)
x86 PAT enabled: cpu 2, old 0x7040600070406, new 0x7010600070106
CPU2: Intel(R) Core(TM)2 Quad CPU    Q6600  @ 2.40GHz stepping 0b
checking TSC synchronization [CPU#0 -> CPU#2]: passed.
Booting processor 3 APIC 0x1 ip 0x6000
Initializing CPU#3
Calibrating delay using timer specific routine.. 4799.85 BogoMIPS (lpj=9599715)
CPU: L1 I cache: 32K, L1 D cache: 32K
CPU: L2 cache: 4096K
CPU 3/0x1 -> Node 0
CPU: Physical Processor ID: 0
CPU: Processor Core ID: 1
CPU3: Thermal monitoring enabled (TM2)
x86 PAT enabled: cpu 3, old 0x7040600070406, new 0x7010600070106
CPU3: Intel(R) Core(TM)2 Quad CPU    Q6600  @ 2.40GHz stepping 0b
checking TSC synchronization [CPU#0 -> CPU#3]: passed.
Brought up 4 CPUs
Total of 4 processors activated (19199.72 BogoMIPS).
net_namespace: 1888 bytes
Booting paravirtualized kernel on bare hardware
NET: Registered protocol family 16
ACPI: bus type pci registered
PCI: MCFG configuration 0: base d0000000 segment 0 buses 0 - 255
PCI: MCFG area at d0000000 reserved in E820
PCI: Using MMCONFIG at d0000000 - dfffffff
PCI: Using configuration type 1 for base access
mtrr: your CPUs had inconsistent variable MTRR settings
mtrr: probably your BIOS does not setup all CPUs.
mtrr: corrected configuration.
bio: create slab <bio-0> at 0
ACPI: EC: Look up EC in DSDT
ACPI: Interpreter enabled
ACPI: (supports S0 S3 S4 S5)
ACPI: Using IOAPIC for interrupt routing
ACPI: No dock devices found.
ACPI: PCI Root Bridge [PCI0] (0000:00)
pci 0000:00:02.0: reg 10 32bit mmio: [0xf3200000-0xf327ffff]
pci 0000:00:02.0: reg 14 io port: [0xe200-0xe207]
pci 0000:00:02.0: reg 18 32bit mmio: [0xe0000000-0xefffffff]
pci 0000:00:02.0: reg 1c 32bit mmio: [0xf3000000-0xf30fffff]
pci 0000:00:1a.0: reg 20 io port: [0xe300-0xe31f]
pci 0000:00:1a.1: reg 20 io port: [0xe000-0xe01f]
pci 0000:00:1a.2: reg 20 io port: [0xe100-0xe11f]
pci 0000:00:1a.7: reg 10 32bit mmio: [0xf3285000-0xf32853ff]
pci 0000:00:1b.0: reg 10 64bit mmio: [0xf3280000-0xf3283fff]
pci 0000:00:1b.0: PME# supported from D0 D3hot D3cold
pci 0000:00:1b.0: PME# disabled
pci 0000:00:1c.0: PME# supported from D0 D3hot D3cold
pci 0000:00:1c.0: PME# disabled
pci 0000:00:1c.4: PME# supported from D0 D3hot D3cold
pci 0000:00:1c.4: PME# disabled
pci 0000:00:1c.5: PME# supported from D0 D3hot D3cold
pci 0000:00:1c.5: PME# disabled
pci 0000:00:1d.0: reg 20 io port: [0xe400-0xe41f]
pci 0000:00:1d.1: reg 20 io port: [0xe500-0xe51f]
pci 0000:00:1d.2: reg 20 io port: [0xe600-0xe61f]
pci 0000:00:1d.7: reg 10 32bit mmio: [0xf3284000-0xf32843ff]
pci 0000:00:1f.0: quirk: region 0400-047f claimed by ICH6 ACPI/GPIO/TCO
pci 0000:00:1f.0: quirk: region 0480-04bf claimed by ICH6 GPIO
pci 0000:00:1f.0: ICH7 LPC Generic IO decode 1 PIO at 0800 (mask 000f)
pci 0000:00:1f.0: ICH7 LPC Generic IO decode 2 PIO at 0290 (mask 000f)
pci 0000:00:1f.2: reg 10 io port: [0xe700-0xe707]
pci 0000:00:1f.2: reg 14 io port: [0xe800-0xe803]
pci 0000:00:1f.2: reg 18 io port: [0xe900-0xe907]
pci 0000:00:1f.2: reg 1c io port: [0xea00-0xea03]
pci 0000:00:1f.2: reg 20 io port: [0xeb00-0xeb1f]
pci 0000:00:1f.2: reg 24 32bit mmio: [0xf3286000-0xf32867ff]
pci 0000:00:1f.2: PME# supported from D3hot
pci 0000:00:1f.2: PME# disabled
pci 0000:00:1f.3: reg 10 64bit mmio: [0xf3287000-0xf32870ff]
pci 0000:00:1f.3: reg 20 io port: [0x500-0x51f]
pci 0000:00:1c.0: bridge io port: [0xb000-0xbfff]
pci 0000:02:00.0: reg 10 io port: [0xc000-0xc007]
pci 0000:02:00.0: reg 14 io port: [0xc100-0xc103]
pci 0000:02:00.0: reg 18 io port: [0xc200-0xc207]
pci 0000:02:00.0: reg 1c io port: [0xc300-0xc303]
pci 0000:02:00.0: reg 20 io port: [0xc400-0xc40f]
pci 0000:02:00.0: disabling ASPM on pre-1.1 PCIe device.  You can enable it with 'pcie_aspm=force'
pci 0000:00:1c.4: bridge io port: [0xc000-0xcfff]
pci 0000:00:1c.4: bridge 32bit mmio: [0xf0000000-0xf0ffffff]
pci 0000:03:00.0: reg 10 io port: [0xd000-0xd0ff]
pci 0000:03:00.0: reg 18 64bit mmio: [0xf2000000-0xf2000fff]
pci 0000:03:00.0: reg 30 32bit mmio: [0x000000-0x00ffff]
pci 0000:03:00.0: supports D1 D2
pci 0000:03:00.0: PME# supported from D1 D2 D3hot D3cold
pci 0000:03:00.0: PME# disabled
pci 0000:03:00.0: disabling ASPM on pre-1.1 PCIe device.  You can enable it with 'pcie_aspm=force'
pci 0000:00:1c.5: bridge io port: [0xd000-0xdfff]
pci 0000:00:1c.5: bridge 32bit mmio: [0xf1000000-0xf2ffffff]
pci 0000:04:07.0: reg 10 32bit mmio: [0xf3104000-0xf31047ff]
pci 0000:04:07.0: reg 14 32bit mmio: [0xf3100000-0xf3103fff]
pci 0000:04:07.0: supports D1 D2
pci 0000:04:07.0: PME# supported from D0 D1 D2 D3hot
pci 0000:04:07.0: PME# disabled
pci 0000:00:1e.0: transparent bridge
pci 0000:00:1e.0: bridge 32bit mmio: [0xf3100000-0xf31fffff]
ACPI: PCI Interrupt Routing Table [\_SB_.PCI0._PRT]
ACPI: PCI Interrupt Routing Table [\_SB_.PCI0.PEX0._PRT]
ACPI: PCI Interrupt Routing Table [\_SB_.PCI0.PEX4._PRT]
ACPI: PCI Interrupt Routing Table [\_SB_.PCI0.PEX5._PRT]
ACPI: PCI Interrupt Routing Table [\_SB_.PCI0.HUB0._PRT]
ACPI: PCI Interrupt Link [LNKA] (IRQs 3 4 5 6 7 9 10 11 12 14 *15)
ACPI: PCI Interrupt Link [LNKB] (IRQs 3 4 5 6 7 9 *10 11 12 14 15)
ACPI: PCI Interrupt Link [LNKC] (IRQs 3 4 5 6 7 *9 10 11 12 14 15)
ACPI: PCI Interrupt Link [LNKD] (IRQs 3 4 5 6 7 9 10 *11 12 14 15)
ACPI: PCI Interrupt Link [LNKE] (IRQs 3 4 5 6 7 9 10 11 12 14 15) *0, disabled.
ACPI: PCI Interrupt Link [LNKF] (IRQs 3 4 5 6 7 9 10 11 12 14 *15)
ACPI: PCI Interrupt Link [LNK0] (IRQs 3 4 5 6 7 9 10 11 12 *14 15)
ACPI: PCI Interrupt Link [LNK1] (IRQs 3 4 *5 6 7 9 10 11 12 14 15)
usbcore: registered new interface driver usbfs
usbcore: registered new interface driver hub
usbcore: registered new device driver usb
PCI: Using ACPI for IRQ routing
NetLabel: Initializing
NetLabel:  domain hash size = 128
NetLabel:  protocols = UNLABELED CIPSOv4
NetLabel:  unlabeled traffic allowed by default
hpet0: at MMIO 0xfed00000, IRQs 2, 8, 0, 0
hpet0: 4 comparators, 64-bit 14.318180 MHz counter
pnp: PnP ACPI init
ACPI: bus type pnp registered
pnp: PnP ACPI: found 15 devices
ACPI: ACPI bus type pnp unregistered
system 00:01: ioport range 0x4d0-0x4d1 has been reserved
system 00:01: ioport range 0x290-0x29f has been reserved
system 00:01: ioport range 0x800-0x87f has been reserved
system 00:01: ioport range 0x290-0x294 has been reserved
system 00:01: ioport range 0x880-0x88f has been reserved
system 00:0b: ioport range 0x400-0x4bf could not be reserved
system 00:0c: iomem range 0xd0000000-0xdfffffff has been reserved
system 00:0d: iomem range 0xcee00-0xcffff has been reserved
system 00:0d: iomem range 0xf0000-0xf7fff could not be reserved
system 00:0d: iomem range 0xf8000-0xfbfff could not be reserved
system 00:0d: iomem range 0xfc000-0xfffff could not be reserved
system 00:0d: iomem range 0xcf5e0000-0xcf5fffff could not be reserved
system 00:0d: iomem range 0x0-0x9ffff could not be reserved
system 00:0d: iomem range 0x100000-0xcf5dffff could not be reserved
system 00:0d: iomem range 0xfec00000-0xfec00fff has been reserved
system 00:0d: iomem range 0xfed10000-0xfed1dfff has been reserved
system 00:0d: iomem range 0xfed20000-0xfed8ffff has been reserved
system 00:0d: iomem range 0xfee00000-0xfee00fff has been reserved
system 00:0d: iomem range 0xffb00000-0xffb7ffff has been reserved
system 00:0d: iomem range 0xfff00000-0xffffffff has been reserved
system 00:0d: iomem range 0xe0000-0xeffff has been reserved
pci 0000:00:1c.0: PCI bridge, secondary bus 0000:01
pci 0000:00:1c.0:   IO window: 0xb000-0xbfff
pci 0000:00:1c.0:   MEM window: disabled
pci 0000:00:1c.0:   PREFETCH window: disabled
pci 0000:00:1c.4: PCI bridge, secondary bus 0000:02
pci 0000:00:1c.4:   IO window: 0xc000-0xcfff
pci 0000:00:1c.4:   MEM window: 0xf0000000-0xf0ffffff
pci 0000:00:1c.4:   PREFETCH window: disabled
pci 0000:00:1c.5: PCI bridge, secondary bus 0000:03
pci 0000:00:1c.5:   IO window: 0xd000-0xdfff
pci 0000:00:1c.5:   MEM window: 0xf1000000-0xf2ffffff
pci 0000:00:1c.5:   PREFETCH window: 0x000000f3300000-0x000000f33fffff
pci 0000:00:1e.0: PCI bridge, secondary bus 0000:04
pci 0000:00:1e.0:   IO window: disabled
pci 0000:00:1e.0:   MEM window: 0xf3100000-0xf31fffff
pci 0000:00:1e.0:   PREFETCH window: disabled
  alloc irq_desc for 16 on cpu 0 node 0
  alloc kstat_irqs on cpu 0 node 0
pci 0000:00:1c.0: PCI INT A -> GSI 16 (level, low) -> IRQ 16
pci 0000:00:1c.0: setting latency timer to 64
pci 0000:00:1c.4: PCI INT A -> GSI 16 (level, low) -> IRQ 16
pci 0000:00:1c.4: setting latency timer to 64
  alloc irq_desc for 17 on cpu 0 node 0
  alloc kstat_irqs on cpu 0 node 0
pci 0000:00:1c.5: PCI INT B -> GSI 17 (level, low) -> IRQ 17
pci 0000:00:1c.5: setting latency timer to 64
pci 0000:00:1e.0: setting latency timer to 64
pci_bus 0000:00: resource 0 io:  [0x00-0xffff]
pci_bus 0000:00: resource 1 mem: [0x000000-0xffffffffffffffff]
pci_bus 0000:01: resource 0 io:  [0xb000-0xbfff]
pci_bus 0000:02: resource 0 io:  [0xc000-0xcfff]
pci_bus 0000:02: resource 1 mem: [0xf0000000-0xf0ffffff]
pci_bus 0000:03: resource 0 io:  [0xd000-0xdfff]
pci_bus 0000:03: resource 1 mem: [0xf1000000-0xf2ffffff]
pci_bus 0000:03: resource 2 pref mem [0xf3300000-0xf33fffff]
pci_bus 0000:04: resource 1 mem: [0xf3100000-0xf31fffff]
pci_bus 0000:04: resource 3 io:  [0x00-0xffff]
pci_bus 0000:04: resource 4 mem: [0x000000-0xffffffffffffffff]
NET: Registered protocol family 2
IP route cache hash table entries: 131072 (order: 8, 1048576 bytes)
TCP established hash table entries: 524288 (order: 11, 8388608 bytes)
TCP bind hash table entries: 65536 (order: 8, 1048576 bytes)
TCP: Hash tables configured (established 524288 bind 65536)
TCP reno registered
NET: Registered protocol family 1
Trying to unpack rootfs image as initramfs...
Switched to high resolution mode on CPU 3
Switched to high resolution mode on CPU 1
Switched to high resolution mode on CPU 2
Switched to high resolution mode on CPU 0
Freeing initrd memory: 3193k freed
audit: initializing netlink socket (disabled)
type=2000 audit(1251019087.537:1): initialized
HugeTLB registered 2 MB page size, pre-allocated 0 pages
VFS: Disk quotas dquot_6.5.2
Dquot-cache hash table entries: 512 (order 0, 4096 bytes)
msgmni has been set to 7653
SELinux:  Registering netfilter hooks
cryptomgr_test used greatest stack depth: 6152 bytes left
alg: No test for stdrng (krng)
Block layer SCSI generic (bsg) driver version 0.4 loaded (major 252)
io scheduler noop registered
io scheduler anticipatory registered
io scheduler deadline registered
io scheduler cfq registered (default)
pci 0000:00:02.0: Boot video device
pci 0000:00:1a.0: uhci_check_and_reset_hc: legsup = 0x0f10
pci 0000:00:1a.0: Performing full reset
pci 0000:00:1a.1: uhci_check_and_reset_hc: legsup = 0x0010
pci 0000:00:1a.1: Performing full reset
pci 0000:00:1a.2: uhci_check_and_reset_hc: legsup = 0x0010
pci 0000:00:1a.2: Performing full reset
pci 0000:00:1d.0: uhci_check_and_reset_hc: legsup = 0x003a
pci 0000:00:1d.0: Performing full reset
pci 0000:00:1d.1: uhci_check_and_reset_hc: legsup = 0x0010
pci 0000:00:1d.1: Performing full reset
pci 0000:00:1d.2: uhci_check_and_reset_hc: legsup = 0x0010
pci 0000:00:1d.2: Performing full reset
  alloc irq_desc for 24 on cpu 0 node 0
  alloc kstat_irqs on cpu 0 node 0
pcieport-driver 0000:00:1c.0: irq 24 for MSI/MSI-X
pcieport-driver 0000:00:1c.0: setting latency timer to 64
  alloc irq_desc for 25 on cpu 0 node 0
  alloc kstat_irqs on cpu 0 node 0
pcieport-driver 0000:00:1c.4: irq 25 for MSI/MSI-X
pcieport-driver 0000:00:1c.4: setting latency timer to 64
  alloc irq_desc for 26 on cpu 0 node 0
  alloc kstat_irqs on cpu 0 node 0
pcieport-driver 0000:00:1c.5: irq 26 for MSI/MSI-X
pcieport-driver 0000:00:1c.5: setting latency timer to 64
pci_hotplug: PCI Hot Plug PCI Core version: 0.5
input: Power Button as /devices/LNXSYSTM:00/LNXPWRBN:00/input/input0
ACPI: Power Button [PWRF]
input: Power Button as /devices/LNXSYSTM:00/device:00/PNP0C0C:00/input/input1
ACPI: Power Button [PWRB]
processor ACPI_CPU:00: registered as cooling_device0
ACPI: Processor [CPU0] (supports 8 throttling states)
ACPI: SSDT 00000000cf5e8cc0 00087 (v01  PmRef  Cpu1Ist 00003000 INTL 20040311)
processor ACPI_CPU:01: registered as cooling_device1
ACPI: Processor [CPU1] (supports 8 throttling states)
ACPI: SSDT 00000000cf5e8d50 00087 (v01  PmRef  Cpu2Ist 00003000 INTL 20040311)
processor ACPI_CPU:02: registered as cooling_device2
ACPI: Processor [CPU2] (supports 8 throttling states)
ACPI: SSDT 00000000cf5e8de0 00087 (v01  PmRef  Cpu3Ist 00003000 INTL 20040311)
processor ACPI_CPU:03: registered as cooling_device3
ACPI: Processor [CPU3] (supports 8 throttling states)
Non-volatile memory driver v1.3
Linux agpgart interface v0.103
agpgart-intel 0000:00:00.0: Intel G33 Chipset
agpgart-intel 0000:00:00.0: detected 7164K stolen memory
agpgart-intel 0000:00:00.0: AGP aperture is 256M @ 0xe0000000
work_for_cpu used greatest stack depth: 5928 bytes left
Serial: 8250/16550 driver, 16 ports, IRQ sharing enabled
serial8250: ttyS0 at I/O 0x3f8 (irq = 4) is a 16550A
serial8250: ttyS1 at I/O 0x2f8 (irq = 3) is a 16550A
00:07: ttyS0 at I/O 0x3f8 (irq = 4) is a 16550A
00:08: ttyS1 at I/O 0x2f8 (irq = 3) is a 16550A
brd: module loaded
input: Macintosh mouse button emulation as /devices/virtual/input/input2
PNP: PS/2 Controller [PNP0303:PS2K] at 0x60,0x64 irq 1
PNP: PS/2 appears to have AUX port disabled, if this is incorrect please boot with i8042.nopnp
serio: i8042 KBD port at 0x60,0x64 irq 1
mice: PS/2 mouse device common for all mice
rtc_cmos 00:03: RTC can wake from S4
rtc_cmos 00:03: rtc core: registered rtc_cmos as rtc0
rtc0: alarms up to one month, 242 bytes nvram, hpet irqs
cpuidle: using governor ladder
cpuidle: using governor menu
usbcore: registered new interface driver hiddev
usbcore: registered new interface driver usbhid
usbhid: v2.6:USB HID core driver
TCP cubic registered
Initializing XFRM netlink socket
NET: Registered protocol family 17
PM: Resume from disk failed.
registered taskstats version 1
Freeing unused kernel memory: 1280k freed
Write protecting the kernel read-only data: 5080k
modprobe used greatest stack depth: 5776 bytes left
input: AT Translated Set 2 keyboard as /devices/platform/i8042/serio0/input/input3
[drm] Initialized drm 1.1.0 20060810
i915 0000:00:02.0: PCI INT A -> GSI 16 (level, low) -> IRQ 16
i915 0000:00:02.0: setting latency timer to 64
mtrr: no more MTRRs available
[drm] MTRR allocation failed.  Graphics performance may suffer.
  alloc irq_desc for 27 on cpu 0 node 0
  alloc kstat_irqs on cpu 0 node 0
i915 0000:00:02.0: irq 27 for MSI/MSI-X
allocated 1280x1024 fb: 0x007e0000, bo ffff88012dc77180
Console: switching to colour frame buffer device 160x64
[drm] DAC-6: set mode 1280x1024 1a
fb0: inteldrmfb frame buffer device
registered panic notifier
[drm] Initialized i915 1.6.0 20080730 for 0000:00:02.0 on minor 0
work_for_cpu used greatest stack depth: 4680 bytes left
ehci_hcd: USB 2.0 'Enhanced' Host Controller (EHCI) Driver
ehci_hcd: block sizes: qh 160 qtd 96 itd 192 sitd 96
  alloc irq_desc for 18 on cpu 0 node 0
  alloc kstat_irqs on cpu 0 node 0
ehci_hcd 0000:00:1a.7: PCI INT C -> GSI 18 (level, low) -> IRQ 18
ehci_hcd 0000:00:1a.7: setting latency timer to 64
ehci_hcd 0000:00:1a.7: EHCI Host Controller
/home/ebiederm/projects/linux/linux-2.6.30-Arora/drivers/usb/core/inode.c: creating file 'devices'
/home/ebiederm/projects/linux/linux-2.6.30-Arora/drivers/usb/core/inode.c: creating file '001'
ehci_hcd 0000:00:1a.7: new USB bus registered, assigned bus number 1
ehci_hcd 0000:00:1a.7: reset hcs_params 0x103206 dbg=1 cc=3 pcc=2 ordered !ppc ports=6
ehci_hcd 0000:00:1a.7: reset hcc_params 16871 thresh 7 uframes 1024 64 bit addr
ehci_hcd 0000:00:1a.7: reset command 080002 (park)=0 ithresh=8 period=1024 Reset HALT
ehci_hcd 0000:00:1a.7: cache line size of 32 is not supported
ehci_hcd 0000:00:1a.7: supports USB remote wakeup
ehci_hcd 0000:00:1a.7: irq 18, io mem 0xf3285000
ehci_hcd 0000:00:1a.7: reset command 080002 (park)=0 ithresh=8 period=1024 Reset HALT
ehci_hcd 0000:00:1a.7: init command 010001 (park)=0 ithresh=1 period=1024 RUN
ehci_hcd 0000:00:1a.7: USB 2.0 started, EHCI 1.00
usb usb1: default language 0x0409
usb usb1: New USB device found, idVendor=1d6b, idProduct=0002
usb usb1: New USB device strings: Mfr=3, Product=2, SerialNumber=1
usb usb1: Product: EHCI Host Controller
usb usb1: Manufacturer: Linux 2.6.30eric-rtl8169-debug ehci_hcd
usb usb1: SerialNumber: 0000:00:1a.7
usb usb1: uevent
usb usb1: usb_probe_device
usb usb1: configuration #1 chosen from 1 choice
usb usb1: adding 1-0:1.0 (config #1, interface 0)
usb 1-0:1.0: uevent
hub 1-0:1.0: usb_probe_interface
hub 1-0:1.0: usb_probe_interface - got id
hub 1-0:1.0: USB hub found
hub 1-0:1.0: 6 ports detected
hub 1-0:1.0: standalone hub
hub 1-0:1.0: no power switching (usb 1.0)
hub 1-0:1.0: individual port over-current protection
hub 1-0:1.0: power on to power good time: 20ms
hub 1-0:1.0: local power source is good
hub 1-0:1.0: trying to enable port power on non-switchable hub
/home/ebiederm/projects/linux/linux-2.6.30-Arora/drivers/usb/core/inode.c: creating file '001'
  alloc irq_desc for 23 on cpu 0 node 0
  alloc kstat_irqs on cpu 0 node 0
ehci_hcd 0000:00:1d.7: PCI INT A -> GSI 23 (level, low) -> IRQ 23
ehci_hcd 0000:00:1d.7: setting latency timer to 64
ehci_hcd 0000:00:1d.7: EHCI Host Controller
/home/ebiederm/projects/linux/linux-2.6.30-Arora/drivers/usb/core/inode.c: creating file '002'
ehci_hcd 0000:00:1d.7: new USB bus registered, assigned bus number 2
ehci_hcd 0000:00:1d.7: reset hcs_params 0x103206 dbg=1 cc=3 pcc=2 ordered !ppc ports=6
ehci_hcd 0000:00:1d.7: reset hcc_params 16871 thresh 7 uframes 1024 64 bit addr
ehci_hcd 0000:00:1d.7: reset command 080002 (park)=0 ithresh=8 period=1024 Reset HALT
ehci_hcd 0000:00:1d.7: cache line size of 32 is not supported
ehci_hcd 0000:00:1d.7: supports USB remote wakeup
ehci_hcd 0000:00:1d.7: irq 23, io mem 0xf3284000
ehci_hcd 0000:00:1d.7: reset command 080002 (park)=0 ithresh=8 period=1024 Reset HALT
ehci_hcd 0000:00:1d.7: init command 010001 (park)=0 ithresh=1 period=1024 RUN
ehci_hcd 0000:00:1d.7: USB 2.0 started, EHCI 1.00
usb usb2: default language 0x0409
usb usb2: New USB device found, idVendor=1d6b, idProduct=0002
usb usb2: New USB device strings: Mfr=3, Product=2, SerialNumber=1
usb usb2: Product: EHCI Host Controller
usb usb2: Manufacturer: Linux 2.6.30eric-rtl8169-debug ehci_hcd
usb usb2: SerialNumber: 0000:00:1d.7
usb usb2: uevent
usb usb2: usb_probe_device
usb usb2: configuration #1 chosen from 1 choice
usb usb2: adding 2-0:1.0 (config #1, interface 0)
usb 2-0:1.0: uevent
hub 2-0:1.0: usb_probe_interface
hub 2-0:1.0: usb_probe_interface - got id
hub 2-0:1.0: USB hub found
hub 2-0:1.0: 6 ports detected
hub 2-0:1.0: standalone hub
hub 2-0:1.0: no power switching (usb 1.0)
hub 2-0:1.0: individual port over-current protection
hub 2-0:1.0: power on to power good time: 20ms
hub 2-0:1.0: local power source is good
hub 2-0:1.0: trying to enable port power on non-switchable hub
/home/ebiederm/projects/linux/linux-2.6.30-Arora/drivers/usb/core/inode.c: creating file '001'
ohci_hcd: USB 1.1 'Open' Host Controller (OHCI) Driver
ohci_hcd: block sizes: ed 80 td 96
uhci_hcd: USB Universal Host Controller Interface driver
uhci_hcd 0000:00:1a.0: PCI INT A -> GSI 16 (level, low) -> IRQ 16
uhci_hcd 0000:00:1a.0: setting latency timer to 64
uhci_hcd 0000:00:1a.0: UHCI Host Controller
/home/ebiederm/projects/linux/linux-2.6.30-Arora/drivers/usb/core/inode.c: creating file '003'
uhci_hcd 0000:00:1a.0: new USB bus registered, assigned bus number 3
uhci_hcd 0000:00:1a.0: detected 2 ports
uhci_hcd 0000:00:1a.0: uhci_check_and_reset_hc: cmd = 0x0000
uhci_hcd 0000:00:1a.0: Performing full reset
uhci_hcd 0000:00:1a.0: supports USB remote wakeup
uhci_hcd 0000:00:1a.0: irq 16, io base 0x0000e300
usb usb3: default language 0x0409
usb usb3: New USB device found, idVendor=1d6b, idProduct=0001
usb usb3: New USB device strings: Mfr=3, Product=2, SerialNumber=1
usb usb3: Product: UHCI Host Controller
usb usb3: Manufacturer: Linux 2.6.30eric-rtl8169-debug uhci_hcd
usb usb3: SerialNumber: 0000:00:1a.0
usb usb3: uevent
usb usb3: usb_probe_device
usb usb3: configuration #1 chosen from 1 choice
usb usb3: adding 3-0:1.0 (config #1, interface 0)
usb 3-0:1.0: uevent
hub 3-0:1.0: usb_probe_interface
hub 3-0:1.0: usb_probe_interface - got id
hub 3-0:1.0: USB hub found
hub 3-0:1.0: 2 ports detected
hub 3-0:1.0: standalone hub
hub 3-0:1.0: no power switching (usb 1.0)
hub 3-0:1.0: individual port over-current protection
hub 3-0:1.0: power on to power good time: 2ms
hub 3-0:1.0: local power source is good
hub 3-0:1.0: trying to enable port power on non-switchable hub
/home/ebiederm/projects/linux/linux-2.6.30-Arora/drivers/usb/core/inode.c: creating file '001'
  alloc irq_desc for 21 on cpu 0 node 0
  alloc kstat_irqs on cpu 0 node 0
uhci_hcd 0000:00:1a.1: PCI INT B -> GSI 21 (level, low) -> IRQ 21
uhci_hcd 0000:00:1a.1: setting latency timer to 64
uhci_hcd 0000:00:1a.1: UHCI Host Controller
/home/ebiederm/projects/linux/linux-2.6.30-Arora/drivers/usb/core/inode.c: creating file '004'
uhci_hcd 0000:00:1a.1: new USB bus registered, assigned bus number 4
uhci_hcd 0000:00:1a.1: detected 2 ports
uhci_hcd 0000:00:1a.1: uhci_check_and_reset_hc: cmd = 0x0000
uhci_hcd 0000:00:1a.1: Performing full reset
uhci_hcd 0000:00:1a.1: supports USB remote wakeup
uhci_hcd 0000:00:1a.1: irq 21, io base 0x0000e000
usb usb4: default language 0x0409
usb usb4: New USB device found, idVendor=1d6b, idProduct=0001
usb usb4: New USB device strings: Mfr=3, Product=2, SerialNumber=1
usb usb4: Product: UHCI Host Controller
usb usb4: Manufacturer: Linux 2.6.30eric-rtl8169-debug uhci_hcd
usb usb4: SerialNumber: 0000:00:1a.1
usb usb4: uevent
usb usb4: usb_probe_device
usb usb4: configuration #1 chosen from 1 choice
usb usb4: adding 4-0:1.0 (config #1, interface 0)
usb 4-0:1.0: uevent
hub 4-0:1.0: usb_probe_interface
hub 4-0:1.0: usb_probe_interface - got id
hub 4-0:1.0: USB hub found
hub 4-0:1.0: 2 ports detected
hub 4-0:1.0: standalone hub
hub 4-0:1.0: no power switching (usb 1.0)
hub 4-0:1.0: individual port over-current protection
hub 4-0:1.0: power on to power good time: 2ms
hub 4-0:1.0: local power source is good
hub 4-0:1.0: trying to enable port power on non-switchable hub
/home/ebiederm/projects/linux/linux-2.6.30-Arora/drivers/usb/core/inode.c: creating file '001'
uhci_hcd 0000:00:1a.2: PCI INT C -> GSI 18 (level, low) -> IRQ 18
uhci_hcd 0000:00:1a.2: setting latency timer to 64
uhci_hcd 0000:00:1a.2: UHCI Host Controller
/home/ebiederm/projects/linux/linux-2.6.30-Arora/drivers/usb/core/inode.c: creating file '005'
uhci_hcd 0000:00:1a.2: new USB bus registered, assigned bus number 5
uhci_hcd 0000:00:1a.2: detected 2 ports
uhci_hcd 0000:00:1a.2: uhci_check_and_reset_hc: cmd = 0x0000
uhci_hcd 0000:00:1a.2: Performing full reset
uhci_hcd 0000:00:1a.2: supports USB remote wakeup
uhci_hcd 0000:00:1a.2: irq 18, io base 0x0000e100
usb usb5: default language 0x0409
usb usb5: New USB device found, idVendor=1d6b, idProduct=0001
usb usb5: New USB device strings: Mfr=3, Product=2, SerialNumber=1
usb usb5: Product: UHCI Host Controller
usb usb5: Manufacturer: Linux 2.6.30eric-rtl8169-debug uhci_hcd
usb usb5: SerialNumber: 0000:00:1a.2
usb usb5: uevent
usb usb5: usb_probe_device
usb usb5: configuration #1 chosen from 1 choice
usb usb5: adding 5-0:1.0 (config #1, interface 0)
usb 5-0:1.0: uevent
hub 5-0:1.0: usb_probe_interface
hub 5-0:1.0: usb_probe_interface - got id
hub 5-0:1.0: USB hub found
hub 5-0:1.0: 2 ports detected
hub 5-0:1.0: standalone hub
hub 5-0:1.0: no power switching (usb 1.0)
hub 5-0:1.0: individual port over-current protection
hub 5-0:1.0: power on to power good time: 2ms
hub 5-0:1.0: local power source is good
hub 5-0:1.0: trying to enable port power on non-switchable hub
/home/ebiederm/projects/linux/linux-2.6.30-Arora/drivers/usb/core/inode.c: creating file '001'
uhci_hcd 0000:00:1d.0: PCI INT A -> GSI 23 (level, low) -> IRQ 23
uhci_hcd 0000:00:1d.0: setting latency timer to 64
uhci_hcd 0000:00:1d.0: UHCI Host Controller
/home/ebiederm/projects/linux/linux-2.6.30-Arora/drivers/usb/core/inode.c: creating file '006'
uhci_hcd 0000:00:1d.0: new USB bus registered, assigned bus number 6
uhci_hcd 0000:00:1d.0: detected 2 ports
uhci_hcd 0000:00:1d.0: uhci_check_and_reset_hc: cmd = 0x0000
uhci_hcd 0000:00:1d.0: Performing full reset
uhci_hcd 0000:00:1d.0: supports USB remote wakeup
uhci_hcd 0000:00:1d.0: irq 23, io base 0x0000e400
usb usb6: default language 0x0409
usb usb6: New USB device found, idVendor=1d6b, idProduct=0001
usb usb6: New USB device strings: Mfr=3, Product=2, SerialNumber=1
usb usb6: Product: UHCI Host Controller
usb usb6: Manufacturer: Linux 2.6.30eric-rtl8169-debug uhci_hcd
usb usb6: SerialNumber: 0000:00:1d.0
usb usb6: uevent
usb usb6: usb_probe_device
usb usb6: configuration #1 chosen from 1 choice
usb usb6: adding 6-0:1.0 (config #1, interface 0)
usb 6-0:1.0: uevent
hub 6-0:1.0: usb_probe_interface
hub 6-0:1.0: usb_probe_interface - got id
hub 6-0:1.0: USB hub found
hub 6-0:1.0: 2 ports detected
hub 6-0:1.0: standalone hub
hub 6-0:1.0: no power switching (usb 1.0)
hub 6-0:1.0: individual port over-current protection
hub 6-0:1.0: power on to power good time: 2ms
hub 6-0:1.0: local power source is good
hub 6-0:1.0: trying to enable port power on non-switchable hub
/home/ebiederm/projects/linux/linux-2.6.30-Arora/drivers/usb/core/inode.c: creating file '001'
  alloc irq_desc for 19 on cpu 0 node 0
  alloc kstat_irqs on cpu 0 node 0
uhci_hcd 0000:00:1d.1: PCI INT B -> GSI 19 (level, low) -> IRQ 19
uhci_hcd 0000:00:1d.1: setting latency timer to 64
uhci_hcd 0000:00:1d.1: UHCI Host Controller
/home/ebiederm/projects/linux/linux-2.6.30-Arora/drivers/usb/core/inode.c: creating file '007'
uhci_hcd 0000:00:1d.1: new USB bus registered, assigned bus number 7
uhci_hcd 0000:00:1d.1: detected 2 ports
uhci_hcd 0000:00:1d.1: uhci_check_and_reset_hc: cmd = 0x0000
uhci_hcd 0000:00:1d.1: Performing full reset
uhci_hcd 0000:00:1d.1: supports USB remote wakeup
uhci_hcd 0000:00:1d.1: irq 19, io base 0x0000e500
usb usb7: default language 0x0409
usb usb7: New USB device found, idVendor=1d6b, idProduct=0001
usb usb7: New USB device strings: Mfr=3, Product=2, SerialNumber=1
usb usb7: Product: UHCI Host Controller
usb usb7: Manufacturer: Linux 2.6.30eric-rtl8169-debug uhci_hcd
usb usb7: SerialNumber: 0000:00:1d.1
usb usb7: uevent
usb usb7: usb_probe_device
usb usb7: configuration #1 chosen from 1 choice
usb usb7: adding 7-0:1.0 (config #1, interface 0)
usb 7-0:1.0: uevent
hub 7-0:1.0: usb_probe_interface
hub 7-0:1.0: usb_probe_interface - got id
hub 7-0:1.0: USB hub found
hub 7-0:1.0: 2 ports detected
hub 7-0:1.0: standalone hub
hub 7-0:1.0: no power switching (usb 1.0)
hub 7-0:1.0: individual port over-current protection
hub 7-0:1.0: power on to power good time: 2ms
hub 7-0:1.0: local power source is good
hub 7-0:1.0: trying to enable port power on non-switchable hub
/home/ebiederm/projects/linux/linux-2.6.30-Arora/drivers/usb/core/inode.c: creating file '001'
uhci_hcd 0000:00:1d.2: PCI INT C -> GSI 18 (level, low) -> IRQ 18
uhci_hcd 0000:00:1d.2: setting latency timer to 64
uhci_hcd 0000:00:1d.2: UHCI Host Controller
/home/ebiederm/projects/linux/linux-2.6.30-Arora/drivers/usb/core/inode.c: creating file '008'
uhci_hcd 0000:00:1d.2: new USB bus registered, assigned bus number 8
uhci_hcd 0000:00:1d.2: detected 2 ports
uhci_hcd 0000:00:1d.2: uhci_check_and_reset_hc: cmd = 0x0000
uhci_hcd 0000:00:1d.2: Performing full reset
uhci_hcd 0000:00:1d.2: supports USB remote wakeup
uhci_hcd 0000:00:1d.2: irq 18, io base 0x0000e600
usb usb8: default language 0x0409
usb usb8: New USB device found, idVendor=1d6b, idProduct=0001
usb usb8: New USB device strings: Mfr=3, Product=2, SerialNumber=1
usb usb8: Product: UHCI Host Controller
usb usb8: Manufacturer: Linux 2.6.30eric-rtl8169-debug uhci_hcd
usb usb8: SerialNumber: 0000:00:1d.2
usb usb8: uevent
usb usb8: usb_probe_device
usb usb8: configuration #1 chosen from 1 choice
usb usb8: adding 8-0:1.0 (config #1, interface 0)
usb 8-0:1.0: uevent
hub 8-0:1.0: usb_probe_interface
hub 8-0:1.0: usb_probe_interface - got id
hub 8-0:1.0: USB hub found
hub 8-0:1.0: 2 ports detected
hub 8-0:1.0: standalone hub
hub 8-0:1.0: no power switching (usb 1.0)
hub 8-0:1.0: individual port over-current protection
hub 8-0:1.0: power on to power good time: 2ms
hub 8-0:1.0: local power source is good
hub 8-0:1.0: trying to enable port power on non-switchable hub
/home/ebiederm/projects/linux/linux-2.6.30-Arora/drivers/usb/core/inode.c: creating file '001'
SCSI subsystem initialized
Driver 'sd' needs updating - please use bus_type methods
libata version 3.00 loaded.
ahci 0000:00:1f.2: version 3.0
ahci 0000:00:1f.2: PCI INT B -> GSI 19 (level, low) -> IRQ 19
  alloc irq_desc for 28 on cpu 0 node 0
  alloc kstat_irqs on cpu 0 node 0
ahci 0000:00:1f.2: irq 28 for MSI/MSI-X
ahci: SSS flag set, parallel bus scan disabled
ahci 0000:00:1f.2: AHCI 0001.0200 32 slots 4 ports 3 Gbps 0x33 impl SATA mode
ahci 0000:00:1f.2: flags: 64bit ncq sntf stag pm led clo pmp pio slum part ems 
ahci 0000:00:1f.2: setting latency timer to 64
scsi0 : ahci
scsi1 : ahci
scsi2 : ahci
scsi3 : ahci
scsi4 : ahci
scsi5 : ahci
ata1: SATA max UDMA/133 abar m2048@0xf3286000 port 0xf3286100 irq 28
ata2: SATA max UDMA/133 abar m2048@0xf3286000 port 0xf3286180 irq 28
ata3: DUMMY
ata4: DUMMY
ata5: SATA max UDMA/133 abar m2048@0xf3286000 port 0xf3286300 irq 28
ata6: SATA max UDMA/133 abar m2048@0xf3286000 port 0xf3286380 irq 28
hub 1-0:1.0: state 7 ports 6 chg 0000 evt 0000
hub 2-0:1.0: state 7 ports 6 chg 0000 evt 0000
hub 3-0:1.0: state 7 ports 2 chg 0000 evt 0000
hub 4-0:1.0: state 7 ports 2 chg 0000 evt 0000
hub 5-0:1.0: state 7 ports 2 chg 0000 evt 0000
hub 6-0:1.0: state 7 ports 2 chg 0000 evt 0000
hub 7-0:1.0: state 7 ports 2 chg 0000 evt 0000
hub 8-0:1.0: state 7 ports 2 chg 0000 evt 0000
ata1: SATA link up 1.5 Gbps (SStatus 113 SControl 300)
ata1.00: HPA detected: current 488395055, native 488397168
ata1.00: ATA-7: ST3250410AS, 3.AAA, max UDMA/133
ata1.00: 488395055 sectors, multi 0: LBA48 NCQ (depth 31/32)
ata1.00: configured for UDMA/133
scsi 0:0:0:0: Direct-Access     ATA      ST3250410AS      3.AA PQ: 0 ANSI: 5
sd 0:0:0:0: [sda] 488395055 512-byte hardware sectors: (250 GB/232 GiB)
sd 0:0:0:0: [sda] Write Protect is off
sd 0:0:0:0: [sda] Mode Sense: 00 3a 00 00
sd 0:0:0:0: [sda] Write cache: enabled, read cache: enabled, doesn't support DPO or FUA
 sda: sda1 sda2 sda3
sd 0:0:0:0: [sda] Attached SCSI disk
ata2: SATA link down (SStatus 0 SControl 300)
ata5: SATA link down (SStatus 0 SControl 300)
usb usb3: suspend_rh (auto-stop)
usb usb4: suspend_rh (auto-stop)
usb usb5: suspend_rh (auto-stop)
usb usb6: suspend_rh (auto-stop)
usb usb7: suspend_rh (auto-stop)
usb usb8: suspend_rh (auto-stop)
ata6: SATA link down (SStatus 0 SControl 300)
kjournald starting.  Commit interval 5 seconds
EXT3-fs: mounted filesystem with ordered data mode.
SELinux:  Disabled at runtime.
SELinux:  Unregistering netfilter hooks
type=1404 audit(1251019090.797:2): selinux=0 auid=4294967295 ses=4294967295
sh used greatest stack depth: 4256 bytes left
awk used greatest stack depth: 3632 bytes left
mount used greatest stack depth: 3600 bytes left
hub 1-0:1.0: hub_suspend
usb usb1: bus auto-suspend
ehci_hcd 0000:00:1a.7: suspend root hub
hub 2-0:1.0: hub_suspend
usb usb2: bus auto-suspend
ehci_hcd 0000:00:1d.7: suspend root hub
hub 3-0:1.0: hub_suspend
usb usb3: bus auto-suspend
usb usb3: suspend_rh
hub 4-0:1.0: hub_suspend
usb usb4: bus auto-suspend
usb usb4: suspend_rh
hub 5-0:1.0: hub_suspend
usb usb5: bus auto-suspend
usb usb5: suspend_rh
hub 6-0:1.0: hub_suspend
usb usb6: bus auto-suspend
usb usb6: suspend_rh
hub 7-0:1.0: hub_suspend
usb usb7: bus auto-suspend
usb usb7: suspend_rh
hub 8-0:1.0: hub_suspend
usb usb8: bus auto-suspend
usb usb8: suspend_rh
udev: starting version 141
usb usb3: uevent
usb 3-0:1.0: uevent
usb usb4: uevent
usb 4-0:1.0: uevent
usb usb5: uevent
usb 5-0:1.0: uevent
usb usb1: uevent
usb 1-0:1.0: uevent
usb usb6: uevent
usb 6-0:1.0: uevent
usb usb7: uevent
usb 7-0:1.0: uevent
usb usb8: uevent
usb 8-0:1.0: uevent
usb usb2: uevent
usb 2-0:1.0: uevent
usb usb3: uevent
usb usb5: uevent
usb usb1: uevent
usb usb7: uevent
usb usb4: uevent
usb usb2: uevent
usb usb8: uevent
usb usb6: uevent
sd 0:0:0:0: Attached scsi generic sg0 type 0
pata_jmicron 0000:02:00.0: PCI INT A -> GSI 16 (level, low) -> IRQ 16
pata_jmicron 0000:02:00.0: setting latency timer to 64
scsi6 : pata_jmicron
scsi7 : pata_jmicron
ata7: PATA max UDMA/100 cmd 0xc000 ctl 0xc100 bmdma 0xc400 irq 16
ata8: PATA max UDMA/100 cmd 0xc200 ctl 0xc300 bmdma 0xc408 irq 16
iTCO_vendor_support: vendor-support=0
input: PC Speaker as /devices/platform/pcspkr/input/input4
Floppy drive(s): fd0 is 1.44M
FDC 0 is a post-1991 82077
r8169 Gigabit Ethernet driver 2.3LK-NAPI loaded
r8169 0000:03:00.0: PCI INT A -> GSI 17 (level, low) -> IRQ 17
r8169 0000:03:00.0: setting latency timer to 64
  alloc irq_desc for 29 on cpu 0 node 0
  alloc kstat_irqs on cpu 0 node 0
r8169 0000:03:00.0: irq 29 for MSI/MSI-X
eth0: RTL8168b/8111b at 0xffffc2000065a000, 00:1a:4d:4e:2c:8c, XID 38000000 IRQ 29
i801_smbus 0000:00:1f.3: PCI INT C -> GSI 18 (level, low) -> IRQ 18
firewire_ohci 0000:04:07.0: PCI INT A -> GSI 23 (level, low) -> IRQ 23
iTCO_wdt: Intel TCO WatchDog Timer Driver v1.05
iTCO_wdt: Found a ICH9 TCO device (Version=2, TCOBASE=0x0460)
iTCO_wdt: initialized. heartbeat=30 sec (nowayout=0)
firewire_ohci: Added fw-ohci device 0000:04:07.0, OHCI version 1.10
parport_pc 00:09: reported by Plug and Play ACPI
parport0: PC-style at 0x378, irq 7 [PCSPP,TRISTATE]
ppdev: user-space parallel port driver
firewire_core: created device fw0: GUID 00c650fd00001a4d, S400
  alloc irq_desc for 22 on cpu 0 node 0
  alloc kstat_irqs on cpu 0 node 0
HDA Intel 0000:00:1b.0: PCI INT A -> GSI 22 (level, low) -> IRQ 22
HDA Intel 0000:00:1b.0: setting latency timer to 64
readahead used greatest stack depth: 3440 bytes left
end_request: I/O error, dev fd0, sector 0
end_request: I/O error, dev fd0, sector 0
Buffer I/O error on device fd0, logical block 0
end_request: I/O error, dev fd0, sector 0
Buffer I/O error on device fd0, logical block 0
end_request: I/O error, dev fd0, sector 0
Buffer I/O error on device fd0, logical block 0
802.1Q VLAN Support v1.8 Ben Greear <greearb@candelatech.com>
All bugs added by David S. Miller <davem@redhat.com>
tun: Universal TUN/TAP device driver, 1.6
tun: (C) 1999-2004 Max Krasnyansky <maxk@qualcomm.com>
nf_conntrack version 0.5.0 (16384 buckets, 65536 max)
CONFIG_NF_CT_ACCT is deprecated and will be removed soon. Please use
nf_conntrack.acct=1 kernel paramater, acct=1 nf_conntrack module option or
sysctl net.netfilter.nf_conntrack_acct=1 to enable it.
ip_tables: (C) 2000-2006 Netfilter Core Team
fuse init (API version 7.11)
has_svm: not amd
kvm: no hardware support
device-mapper: uevent: version 1.0.3
device-mapper: ioctl: 4.14.0-ioctl (2008-04-23) initialised: dm-devel@redhat.com
device-mapper: multipath: version 1.0.5 loaded
EXT3 FS on sda1, internal journal
EXT4-fs: barriers enabled
kjournald2 starting: pid 1011, dev sda3:8, commit interval 5 seconds
EXT4 FS on sda3, internal journal on sda3:8
EXT4-fs: delayed allocation enabled
EXT4-fs: file extents enabled
EXT4-fs: mballoc enabled
EXT4-fs: mounted filesystem sda3 with ordered data mode
Adding 1951888k swap on /dev/sda2.  Priority:-1 extents:1 across:1951888k 
platform microcode: firmware: requesting intel-ucode/06-0f-0b
platform microcode: firmware: requesting intel-ucode/06-0f-0b
platform microcode: firmware: requesting intel-ucode/06-0f-0b
platform microcode: firmware: requesting intel-ucode/06-0f-0b
Microcode Update Driver: v2.00 <tigran@aivazian.fsnet.co.uk>, Peter Oruba
microcode: CPU0 updated from revision 0xb3 to 0xb6, date = 2007-07-13 
microcode: CPU1 updated from revision 0xb3 to 0xb6, date = 2007-07-13 
microcode: CPU2 updated from revision 0xb3 to 0xb6, date = 2007-07-13 
microcode: CPU3 updated from revision 0xb3 to 0xb6, date = 2007-07-13 
Microcode Update Driver: v2.00 removed.
NET: Registered protocol family 10
lo: Disabled Privacy Extensions
r8169: eth0: link up
r8169: eth0: link up
RPC: Registered udp transport module.
RPC: Registered tcp transport module.
r8169 screaming irq status 00000084 mask 0000ffff event 0000803f napi 0000001d
usb usb3: uevent
usb 3-0:1.0: uevent
usb usb4: uevent
usb 4-0:1.0: uevent
usb usb5: uevent
usb 5-0:1.0: uevent
usb usb1: uevent
usb 1-0:1.0: uevent
usb usb6: uevent
usb 6-0:1.0: uevent
usb usb7: uevent
usb 7-0:1.0: uevent
usb usb8: uevent
usb 8-0:1.0: uevent
usb usb2: uevent
usb 2-0:1.0: uevent
Bluetooth: Core ver 2.15
NET: Registered protocol family 31
Bluetooth: HCI device and connection manager initialized
Bluetooth: HCI socket layer initialized
Bluetooth: L2CAP ver 2.13
Bluetooth: L2CAP socket layer initialized
Bluetooth: SCO (Voice Link) ver 0.6
Bluetooth: SCO socket layer initialized
Bluetooth: BNEP (Ethernet Emulation) ver 1.3
Bluetooth: BNEP filters: protocol multicast
Installing knfsd (copyright (C) 1996 okir@monad.swb.de).
NFSD: Using /var/lib/nfs/v4recovery as the NFSv4 state recovery directory
NFSD: starting 90-second grace period
Bridge firewalling registered
------------[ cut here ]------------
WARNING: at /home/ebiederm/projects/linux/linux-2.6.30-Arora/net/sched/sch_generic.c:226 dev_watchdog+0xd9/0x14a()
Hardware name: G33M-S2
NETDEV WATCHDOG: eth0 (r8169): transmit timed out
Modules linked in: bridge nfsd lockd stp bnep nfs_acl sco l2cap auth_rpcgss bluetooth exportfs sunrpc ipv6 cpufreq_ondemand acpi_cpufreq freq_table ext4 jbd2 crc16 dm_mirror dm_region_hash dm_log dm_multipath dm_mod uinput kvm_intel kvm fuse xt_multiport iptable_nat ip_tables nf_nat x_tables nf_conntrack_ipv4 nf_conntrack nf_defrag_ipv4 tun 8021q snd_hda_codec_realtek snd_hda_intel snd_hda_codec snd_hwdep snd_pcm ata_generic ppdev snd_timer parport_pc pata_acpi snd iTCO_wdt firewire_ohci r8169 i2c_i801 parport firewire_core floppy soundcore pcspkr iTCO_vendor_support pata_jmicron crc_itu_t mii snd_page_alloc sg ahci libata sd_mod scsi_mod ext3 jbd mbcache uhci_hcd ohci_hcd ehci_hcd i915 drm i2c_algo_bit video output i2c_core [last unloaded: microcode]
Pid: 0, comm: swapper Not tainted 2.6.30eric-rtl8169-debug #36
Call Trace:
 <IRQ>  [<ffffffff8104583b>] warn_slowpath_common+0x88/0xb6
 [<ffffffff812ee53c>] ? dev_watchdog+0x0/0x14a
 [<ffffffff810458ec>] warn_slowpath_fmt+0x4b/0x61
 [<ffffffff812d607e>] ? netdev_drivername+0x52/0x70
 [<ffffffff812ee615>] dev_watchdog+0xd9/0x14a
 [<ffffffff810596de>] ? __queue_work+0x44/0x61
 [<ffffffff810128ad>] ? read_tsc+0x9/0x1b
 [<ffffffff810665cd>] ? clocksource_read+0x1d/0x33
 [<ffffffff81050922>] run_timer_softirq+0x169/0x1f5
 [<ffffffff81020306>] ? apic_write+0x24/0x3a
 [<ffffffff81069ce2>] ? clockevents_program_event+0x88/0xa5
 [<ffffffff8104ba7b>] __do_softirq+0xc3/0x1b0
 [<ffffffff8100cfcc>] call_softirq+0x1c/0x28
 [<ffffffff8100e721>] do_softirq+0x51/0xae
 [<ffffffff8104b6d2>] irq_exit+0x52/0xa3
 [<ffffffff81020f11>] smp_apic_timer_interrupt+0x94/0xb8
 [<ffffffff8100c9d3>] apic_timer_interrupt+0x13/0x20
 <EOI>  [<ffffffff81014096>] ? mwait_idle+0x9b/0xcc
 [<ffffffff81014038>] ? mwait_idle+0x3d/0xcc
 [<ffffffff8100ae08>] ? enter_idle+0x33/0x49
 [<ffffffff8100aece>] ? cpu_idle+0xb0/0xf3
 [<ffffffff813613c5>] ? rest_init+0x79/0x8f
 [<ffffffff81577f45>] ? start_kernel+0x3d7/0x3f8
 [<ffffffff815772b4>] ? x86_64_start_reservations+0xbb/0xd6
 [<ffffffff815773d4>] ? x86_64_start_kernel+0x105/0x128
---[ end trace 2ef0a88e80889562 ]---
r8169: eth0: link up
r8169: eth0: link up
r8169: eth0: link up
r8169: eth0: link up
r8169: eth0: link up
r8169: eth0: link up
r8169: eth0: link up
r8169: eth0: link up
r8169: eth0: link up
r8169: eth0: link up
r8169: eth0: link up
r8169: eth0: link up
r8169: eth0: link up
r8169: eth0: link up
r8169: eth0: link up
r8169: eth0: link up
r8169: eth0: link up
r8169: eth0: link up
r8169: eth0: link up
r8169: eth0: link up
r8169: eth0: link up
lo: Disabled Privacy Extensions
r8169: eth0: link up
r8169: eth0: link up
r8169: eth0: link up
end_request: I/O error, dev fd0, sector 0
end_request: I/O error, dev fd0, sector 0
Buffer I/O error on device fd0, logical block 0
end_request: I/O error, dev fd0, sector 0
Buffer I/O error on device fd0, logical block 0
r8169: eth0: link up
r8169: eth0: link up
r8169: eth0: link up
r8169: eth0: link up
r8169: eth0: link up
r8169: eth0: link up

--=-=-=--
