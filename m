From: Dan Carpenter <dan.carpenter@oracle.com>
Subject: Re: [patch] RxRPC: use copy_to_user() instead of memcpy()
Date: Wed, 20 Mar 2013 18:52:04 +0300
Message-ID: <20130320155204.GA9138@mwanda>
References: <20130319225101.GZ9189@mwanda>
 <20130319.094240.1315516663563952557.davem@davemloft.net>
 <20130318105503.GA17102@longonot.mountain>
 <30707.1363701570@warthog.procyon.org.uk>
 <27098.1363775018@warthog.procyon.org.uk>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="8t9RHnE3ZwKMSgU+"
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	kernel-janitors@vger.kernel.org
To: David Howells <dhowells@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from userp1040.oracle.com ([156.151.31.81]:29673 "EHLO
	userp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933181Ab3CTPwz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 20 Mar 2013 11:52:55 -0400
Content-Disposition: inline
In-Reply-To: <27098.1363775018@warthog.procyon.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--8t9RHnE3ZwKMSgU+
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

On Wed, Mar 20, 2013 at 10:23:38AM +0000, David Howells wrote:
> 
> Are you running with lockdep enabled?  That should catch such things.
> 

Yep.  I've attached the dmesg.  I'll take a look at this more
tomorrow.

regards,
dan carpenter


--8t9RHnE3ZwKMSgU+
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename=dmesg

[    0.000000] Initializing cgroup subsys cpuset
[    0.000000] Initializing cgroup subsys cpu
[    0.000000] Linux version 3.9.0-rc1-next-20130307+ (dcarpenter@meru) (gcc version 4.6.3 (Debian 4.6.3-1) ) #6 SMP Wed Mar 20 17:12:28 EAT 2013
[    0.000000] e820: BIOS-provided physical RAM map:
[    0.000000] BIOS-e820: [mem 0x0000000000000000-0x000000000009fbff] usable
[    0.000000] BIOS-e820: [mem 0x000000000009fc00-0x000000000009ffff] reserved
[    0.000000] BIOS-e820: [mem 0x00000000000e0000-0x00000000000fffff] reserved
[    0.000000] BIOS-e820: [mem 0x0000000000100000-0x000000007dd9ffff] usable
[    0.000000] BIOS-e820: [mem 0x000000007dda0000-0x000000007ddadfff] ACPI data
[    0.000000] BIOS-e820: [mem 0x000000007ddae000-0x000000007ddeffff] ACPI NVS
[    0.000000] BIOS-e820: [mem 0x000000007ddf0000-0x000000007fffffff] reserved
[    0.000000] BIOS-e820: [mem 0x00000000fee00000-0x00000000fee00fff] reserved
[    0.000000] BIOS-e820: [mem 0x00000000fff00000-0x00000000ffffffff] reserved
[    0.000000] Notice: NX (Execute Disable) protection cannot be enabled: non-PAE kernel!
[    0.000000] SMBIOS 2.6 present.
[    0.000000] DMI: Hewlett-Packard HP 500B Microtower/2A8C, BIOS 6.08 07/07/2011
[    0.000000] e820: update [mem 0x00000000-0x00000fff] usable ==> reserved
[    0.000000] e820: remove [mem 0x000a0000-0x000fffff] usable
[    0.000000] e820: last_pfn = 0x7dda0 max_arch_pfn = 0x100000
[    0.000000] MTRR default type: uncachable
[    0.000000] MTRR fixed ranges enabled:
[    0.000000]   00000-9FFFF write-back
[    0.000000]   A0000-BFFFF uncachable
[    0.000000]   C0000-CFFFF write-protect
[    0.000000]   D0000-DFFFF uncachable
[    0.000000]   E0000-EFFFF write-through
[    0.000000]   F0000-FFFFF write-protect
[    0.000000] MTRR variable ranges enabled:
[    0.000000]   0 base 000000000 mask F80000000 write-back
[    0.000000]   1 base 07DE00000 mask FFFE00000 uncachable
[    0.000000]   2 base 07E000000 mask FFE000000 uncachable
[    0.000000]   3 disabled
[    0.000000]   4 disabled
[    0.000000]   5 disabled
[    0.000000]   6 disabled
[    0.000000]   7 disabled
[    0.000000] x86 PAT enabled: cpu 0, old 0x7040600070406, new 0x7010600070106
[    0.000000] Scanning 1 areas for low memory corruption
[    0.000000] initial memory mapped: [mem 0x00000000-0x027fffff]
[    0.000000] Base memory trampoline at [c009b000] 9b000 size 16384
[    0.000000] init_memory_mapping: [mem 0x00000000-0x000fffff]
[    0.000000]  [mem 0x00000000-0x000fffff] page 4k
[    0.000000] init_memory_mapping: [mem 0x37400000-0x377fdfff]
[    0.000000]  [mem 0x37400000-0x377fdfff] page 4k
[    0.000000] BRK [0x02252000, 0x02252fff] PGTABLE
[    0.000000] init_memory_mapping: [mem 0x30000000-0x373fffff]
[    0.000000]  [mem 0x30000000-0x373fffff] page 2M
[    0.000000] init_memory_mapping: [mem 0x00100000-0x2fffffff]
[    0.000000]  [mem 0x00100000-0x003fffff] page 4k
[    0.000000]  [mem 0x00400000-0x2fffffff] page 2M
[    0.000000] RAMDISK: [mem 0x37bfe000-0x37df6fff]
[    0.000000] Allocated new RAMDISK: [mem 0x37605000-0x377fd0b0]
[    0.000000] Move RAMDISK from [mem 0x37bfe000-0x37df60b0] to [mem 0x37605000-0x377fd0b0]
[    0.000000] ACPI: RSDP 000f9c90 00024 (v02 HPQOEM)
[    0.000000] ACPI: XSDT 7dda0100 00064 (v01 HPQOEM SLIC-CPC 20110707 MSFT 00000097)
[    0.000000] ACPI: FACP 7dda0290 000F4 (v03 HPQOEM SLIC-CPC 20110707 MSFT 00000097)
[    0.000000] ACPI: DSDT 7dda05c0 05A6B (v01 HPQOEM SLIC-CPC 00000000 INTL 20051117)
[    0.000000] ACPI: FACS 7ddae000 00040
[    0.000000] ACPI: APIC 7dda0390 0006C (v01 HPQOEM SLIC-CPC 20110707 MSFT 00000097)
[    0.000000] ACPI: MCFG 7dda0400 0003C (v01 HPQOEM SLIC-CPC 20110707 MSFT 00000097)
[    0.000000] ACPI: OEMB 7ddae040 00072 (v01 HPQOEM SLIC-CPC 20110707 MSFT 00000097)
[    0.000000] ACPI: SSDT 7ddaa670 00843 (v01 HPQOEM SLIC-CPC 00000001 INTL 20051117)
[    0.000000] ACPI: HPET 7ddaaec0 00038 (v01 HPQOEM SLIC-CPC 20110707 MSFT 00000097)
[    0.000000] ACPI: GSCI 7ddae0c0 02024 (v01 HPQOEM SLIC-CPC 20110707 MSFT 00000097)
[    0.000000] ACPI: SSDT 7ddb0600 00363 (v01 HPQOEM SLIC-CPC 00000012 INTL 20051117)
[    0.000000] ACPI: Local APIC address 0xfee00000
[    0.000000] 1125MB HIGHMEM available.
[    0.000000] 887MB LOWMEM available.
[    0.000000]   mapped low ram: 0 - 377fe000
[    0.000000]   low ram: 0 - 377fe000
[    0.000000] BRK [0x02253000, 0x02253fff] PGTABLE
[    0.000000] Zone ranges:
[    0.000000]   DMA      [mem 0x00001000-0x00ffffff]
[    0.000000]   Normal   [mem 0x01000000-0x377fdfff]
[    0.000000]   HighMem  [mem 0x377fe000-0x7dd9ffff]
[    0.000000] Movable zone start for each node
[    0.000000] Early memory node ranges
[    0.000000]   node   0: [mem 0x00001000-0x0009efff]
[    0.000000]   node   0: [mem 0x00100000-0x7dd9ffff]
[    0.000000] On node 0 totalpages: 515390
[    0.000000] free_area_init_node: node 0, pgdat c1a96840, node_mem_map f6645020
[    0.000000]   DMA zone: 32 pages used for memmap
[    0.000000]   DMA zone: 0 pages reserved
[    0.000000]   DMA zone: 3998 pages, LIFO batch:0
[    0.000000]   Normal zone: 1744 pages used for memmap
[    0.000000]   Normal zone: 223230 pages, LIFO batch:31
[    0.000000]   HighMem zone: 2252 pages used for memmap
[    0.000000]   HighMem zone: 288162 pages, LIFO batch:31
[    0.000000] Using APIC driver default
[    0.000000] ACPI: PM-Timer IO Port: 0x808
[    0.000000] ACPI: Local APIC address 0xfee00000
[    0.000000] ACPI: LAPIC (acpi_id[0x01] lapic_id[0x00] enabled)
[    0.000000] ACPI: LAPIC (acpi_id[0x02] lapic_id[0x01] enabled)
[    0.000000] ACPI: LAPIC (acpi_id[0x03] lapic_id[0x82] disabled)
[    0.000000] ACPI: LAPIC (acpi_id[0x04] lapic_id[0x83] disabled)
[    0.000000] ACPI: IOAPIC (id[0x02] address[0xfec00000] gsi_base[0])
[    0.000000] IOAPIC[0]: apic_id 2, version 32, address 0xfec00000, GSI 0-23
[    0.000000] ACPI: INT_SRC_OVR (bus 0 bus_irq 0 global_irq 2 dfl dfl)
[    0.000000] ACPI: INT_SRC_OVR (bus 0 bus_irq 9 global_irq 9 high level)
[    0.000000] ACPI: IRQ0 used by override.
[    0.000000] ACPI: IRQ2 used by override.
[    0.000000] ACPI: IRQ9 used by override.
[    0.000000] Using ACPI (MADT) for SMP configuration information
[    0.000000] ACPI: HPET id: 0xffffffff base: 0xfed00000
[    0.000000] smpboot: Allowing 4 CPUs, 2 hotplug CPUs
[    0.000000] nr_irqs_gsi: 40
[    0.000000] PM: Registered nosave memory: 000000000009f000 - 00000000000a0000
[    0.000000] PM: Registered nosave memory: 00000000000a0000 - 00000000000e0000
[    0.000000] PM: Registered nosave memory: 00000000000e0000 - 0000000000100000
[    0.000000] e820: [mem 0x80000000-0xfedfffff] available for PCI devices
[    0.000000] setup_percpu: NR_CPUS:8 nr_cpumask_bits:8 nr_cpu_ids:4 nr_node_ids:1
[    0.000000] PERCPU: Embedded 334 pages/cpu @f60e6000 s1344192 r0 d23872 u1368064
[    0.000000] pcpu-alloc: s1344192 r0 d23872 u1368064 alloc=334*4096
[    0.000000] pcpu-alloc: [0] 0 [0] 1 [0] 2 [0] 3 
[    0.000000] Built 1 zonelists in Zone order, mobility grouping on.  Total pages: 513614
[    0.000000] Kernel command line: BOOT_IMAGE=/boot/vmlinuz-3.9.0-rc1-next-20130307+ root=UUID=91702034-16a0-4edf-a01a-a529c2d0e97e ro quiet
[    0.000000] PID hash table entries: 4096 (order: 2, 16384 bytes)
[    0.000000] Dentry cache hash table entries: 131072 (order: 7, 524288 bytes)
[    0.000000] Inode-cache hash table entries: 65536 (order: 6, 262144 bytes)
[    0.000000] __ex_table already sorted, skipping sort
[    0.000000] Initializing CPU#0
[    0.000000] xsave: enabled xstate_bv 0x3, cntxt size 0x240
[    0.000000] Initializing HighMem for node 0 (000377fe:0007dda0)
[    0.000000] Memory: 2018276k/2061952k available (7529k kernel code, 43284k reserved, 3384k data, 1880k init, 1152648k highmem)
[    0.000000] virtual kernel memory layout:
[    0.000000]     fixmap  : 0xfff16000 - 0xfffff000   ( 932 kB)
[    0.000000]     pkmap   : 0xff800000 - 0xffc00000   (4096 kB)
[    0.000000]     vmalloc : 0xf7ffe000 - 0xff7fe000   ( 120 MB)
[    0.000000]     lowmem  : 0xc0000000 - 0xf77fe000   ( 887 MB)
[    0.000000]       .init : 0xc1aa9000 - 0xc1c7f000   (1880 kB)
[    0.000000]       .data : 0xc175a7ea - 0xc1aa8840   (3384 kB)
[    0.000000]       .text : 0xc1000000 - 0xc175a7ea   (7529 kB)
[    0.000000] Checking if this processor honours the WP bit even in supervisor mode...Ok.
[    0.000000] SLUB: HWalign=64, Order=0-3, MinObjects=0, CPUs=4, Nodes=1
[    0.000000] Hierarchical RCU implementation.
[    0.000000] 	RCU lockdep checking is enabled.
[    0.000000] 	RCU restricting CPUs from NR_CPUS=8 to nr_cpu_ids=4.
[    0.000000] NR_IRQS:2304 nr_irqs:712 16
[    0.000000] CPU 0 irqstacks, hard=f5c08000 soft=f5c0a000
[    0.000000] Console: colour VGA+ 80x25
[    0.000000] console [tty0] enabled
[    0.000000] Lock dependency validator: Copyright (c) 2006 Red Hat, Inc., Ingo Molnar
[    0.000000] ... MAX_LOCKDEP_SUBCLASSES:  8
[    0.000000] ... MAX_LOCK_DEPTH:          48
[    0.000000] ... MAX_LOCKDEP_KEYS:        8191
[    0.000000] ... CLASSHASH_SIZE:          4096
[    0.000000] ... MAX_LOCKDEP_ENTRIES:     16384
[    0.000000] ... MAX_LOCKDEP_CHAINS:      32768
[    0.000000] ... CHAINHASH_SIZE:          16384
[    0.000000]  memory used by lock dependency info: 3823 kB
[    0.000000]  per task-struct memory footprint: 1920 bytes
[    0.000000] hpet clockevent registered
[    0.000000] tsc: Fast TSC calibration using PIT
[    0.000000] tsc: Detected 3200.032 MHz processor
[    0.001001] Calibrating delay loop (skipped), value calculated using timer frequency.. 6400.06 BogoMIPS (lpj=3200032)
[    0.001004] pid_max: default: 32768 minimum: 301
[    0.001080] Security Framework initialized
[    0.001083] SELinux:  Initializing.
[    0.001124] SELinux:  Starting in permissive mode
[    0.001141] Mount-cache hash table entries: 512
[    0.002465] Initializing cgroup subsys cpuacct
[    0.002472] Initializing cgroup subsys freezer
[    0.002526] CPU: Physical Processor ID: 0
[    0.002528] CPU: Processor Core ID: 0
[    0.002530] mce: CPU supports 6 MCE banks
[    0.002535] CPU0: Thermal monitoring enabled (TM2)
[    0.002543] Last level iTLB entries: 4KB 128, 2MB 4, 4MB 4
[    0.002543] Last level dTLB entries: 4KB 256, 2MB 0, 4MB 32
[    0.002543] tlb_flushall_shift: -1
[    0.002693] Freeing SMP alternatives: 24k freed
[    0.002701] ACPI: Core revision 20130117
[    0.009282] ACPI: All ACPI Tables successfully acquired
[    0.011171] Enabling APIC mode:  Flat.  Using 1 I/O APICs
[    0.011604] ..TIMER: vector=0x30 apic1=0 pin1=2 apic2=-1 pin2=-1
[    0.022789] smpboot: CPU0: Intel Pentium(R) Dual-Core  CPU      E5800  @ 3.20GHz (fam: 06, model: 17, stepping: 0a)
[    0.023000] Performance Events: PEBS fmt0+, 4-deep LBR, Core2 events, Intel PMU driver.
[    0.023000] ... version:                2
[    0.023000] ... bit width:              40
[    0.023000] ... generic registers:      2
[    0.023000] ... value mask:             000000ffffffffff
[    0.023000] ... max period:             000000007fffffff
[    0.023000] ... fixed-purpose events:   3
[    0.023000] ... event mask:             0000000700000003
[    0.023000] SMP alternatives: lockdep: fixing up alternatives
[    0.023000] CPU 1 irqstacks, hard=f5cd8000 soft=f5cda000
[    0.002000] Initializing CPU#1
[    0.023003] smpboot: Booting Node   0, Processors  #1
[    0.035148] Brought up 2 CPUs
[    0.035152] smpboot: Total of 2 processors activated (12800.12 BogoMIPS)
[    0.035335] NMI watchdog: enabled on all CPUs, permanently consumes one hw-PMU counter.
[    0.037320] PM: Registering ACPI NVS region [mem 0x7ddae000-0x7ddeffff] (270336 bytes)
[    0.037474] RTC time: 15:00:24, date: 03/20/13
[    0.037653] NET: Registered protocol family 16
[    0.038145] kworker/u:0 (20) used greatest stack depth: 6892 bytes left
[    0.038296] kworker/u:0 (21) used greatest stack depth: 6496 bytes left
[    0.039154] ACPI: bus type PCI registered
[    0.039185] PCI: MMCONFIG for domain 0000 [bus 00-ff] at [mem 0xe0000000-0xefffffff] (base 0xe0000000)
[    0.039185] PCI: not using MMCONFIG
[    0.039185] PCI: Using configuration type 1 for base access
[    0.061156] bio: create slab <bio-0> at 0
[    0.061204] ACPI: Added _OSI(Module Device)
[    0.061204] ACPI: Added _OSI(Processor Device)
[    0.061204] ACPI: Added _OSI(3.0 _SCP Extensions)
[    0.061204] ACPI: Added _OSI(Processor Aggregator Device)
[    0.067149] ACPI: EC: Look up EC in DSDT
[    0.073911] ACPI: Executed 1 blocks of module-level executable AML code
[    0.077536] ACPI BIOS Bug: Warning: Incorrect checksum in table [SSDT] - 0x12, should be 0x5C (20130117/tbutils-324)
[    0.077541] ACPI: SSDT 7ddb00f0 0050E (v01 HPQOEM SLIC-CPC 00000124 INTL 20051117)
[    0.079059] ACPI: Dynamic OEM Table Load:
[    0.079061] ACPI: SSDT   (null) 0050E (v01 HPQOEM SLIC-CPC 00000124 INTL 20051117)
[    0.080080] ACPI: Interpreter enabled
[    0.080094] ACPI Exception: AE_NOT_FOUND, While evaluating Sleep State [\_S2_] (20130117/hwxface-568)
[    0.080122] ACPI: (supports S0 S1 S3 S4 S5)
[    0.080124] ACPI: Using IOAPIC for interrupt routing
[    0.080155] PCI: MMCONFIG for domain 0000 [bus 00-ff] at [mem 0xe0000000-0xefffffff] (base 0xe0000000)
[    0.084466] PCI: MMCONFIG at [mem 0xe0000000-0xefffffff] reserved in ACPI motherboard resources
[    0.084468] PCI: Using MMCONFIG for extended config space
[    0.084483] PCI: Using host bridge windows from ACPI; if necessary, use "pci=nocrs" and report a bug
[    0.103753] ACPI: PCI Root Bridge [PCI0] (domain 0000 [bus 00-ff])
[    0.104038] acpi PNP0A08:00: Requesting ACPI _OSC control (0x1d)
[    0.104247] acpi PNP0A08:00: ACPI _OSC control (0x1d) granted
[    0.104542] PCI host bridge to bus 0000:00
[    0.104542] pci_bus 0000:00: root bus resource [bus 00-ff]
[    0.104542] pci_bus 0000:00: root bus resource [io  0x0000-0x0cf7]
[    0.104542] pci_bus 0000:00: root bus resource [io  0x0d00-0xffff]
[    0.104542] pci_bus 0000:00: root bus resource [mem 0x000a0000-0x000bffff]
[    0.104542] pci_bus 0000:00: root bus resource [mem 0x000d0000-0x000dffff]
[    0.104542] pci_bus 0000:00: root bus resource [mem 0x7de00000-0xdfffffff]
[    0.104542] pci_bus 0000:00: root bus resource [mem 0xf0000000-0xffffffff]
[    0.104542] pci 0000:00:00.0: [8086:2e30] type 00 class 0x060000
[    0.105071] pci 0000:00:02.0: [8086:2e32] type 00 class 0x030000
[    0.105071] pci 0000:00:02.0: reg 10: [mem 0xfe400000-0xfe7fffff 64bit]
[    0.105071] pci 0000:00:02.0: reg 18: [mem 0xd0000000-0xdfffffff 64bit pref]
[    0.105079] pci 0000:00:02.0: reg 20: [io  0xdc00-0xdc07]
[    0.105330] pci 0000:00:1b.0: [8086:27d8] type 00 class 0x040300
[    0.105330] pci 0000:00:1b.0: reg 10: [mem 0xfeaf8000-0xfeafbfff 64bit]
[    0.105330] pci 0000:00:1b.0: PME# supported from D0 D3hot D3cold
[    0.105463] pci 0000:00:1c.0: [8086:27d0] type 01 class 0x060400
[    0.105463] pci 0000:00:1c.0: PME# supported from D0 D3hot D3cold
[    0.106074] pci 0000:00:1c.0: System wakeup disabled by ACPI
[    0.106178] pci 0000:00:1c.1: [8086:27d2] type 01 class 0x060400
[    0.106178] pci 0000:00:1c.1: PME# supported from D0 D3hot D3cold
[    0.106263] pci 0000:00:1c.1: System wakeup disabled by ACPI
[    0.106333] pci 0000:00:1d.0: [8086:27c8] type 00 class 0x0c0300
[    0.106333] pci 0000:00:1d.0: reg 20: [io  0xd880-0xd89f]
[    0.106333] pci 0000:00:1d.0: System wakeup disabled by ACPI
[    0.107042] pci 0000:00:1d.1: [8086:27c9] type 00 class 0x0c0300
[    0.107107] pci 0000:00:1d.1: reg 20: [io  0xd800-0xd81f]
[    0.107187] pci 0000:00:1d.1: System wakeup disabled by ACPI
[    0.107261] pci 0000:00:1d.2: [8086:27ca] type 00 class 0x0c0300
[    0.107261] pci 0000:00:1d.2: reg 20: [io  0xd480-0xd49f]
[    0.107279] pci 0000:00:1d.2: System wakeup disabled by ACPI
[    0.107354] pci 0000:00:1d.3: [8086:27cb] type 00 class 0x0c0300
[    0.107354] pci 0000:00:1d.3: reg 20: [io  0xd400-0xd41f]
[    0.108003] pci 0000:00:1d.3: System wakeup disabled by ACPI
[    0.108050] pci 0000:00:1d.7: [8086:27cc] type 00 class 0x0c0320
[    0.108079] pci 0000:00:1d.7: reg 10: [mem 0xfeaf7c00-0xfeaf7fff]
[    0.108208] pci 0000:00:1d.7: PME# supported from D0 D3hot D3cold
[    0.108349] pci 0000:00:1d.7: System wakeup disabled by ACPI
[    0.108417] pci 0000:00:1e.0: [8086:244e] type 01 class 0x060401
[    0.108417] pci 0000:00:1e.0: System wakeup disabled by ACPI
[    0.108417] pci 0000:00:1f.0: [8086:27b8] type 00 class 0x060100
[    0.108417] pci 0000:00:1f.0: ICH7 LPC Generic IO decode 1 PIO at 0a00 (mask 00ff)
[    0.109048] pci 0000:00:1f.1: [8086:27df] type 00 class 0x01018a
[    0.109068] pci 0000:00:1f.1: reg 10: [io  0x0000-0x0007]
[    0.109081] pci 0000:00:1f.1: reg 14: [io  0x0000-0x0003]
[    0.109095] pci 0000:00:1f.1: reg 18: [io  0x08f0-0x08f7]
[    0.109108] pci 0000:00:1f.1: reg 1c: [io  0x08f8-0x08fb]
[    0.109122] pci 0000:00:1f.1: reg 20: [io  0xffa0-0xffaf]
[    0.109267] pci 0000:00:1f.2: [8086:27c0] type 00 class 0x01018f
[    0.109267] pci 0000:00:1f.2: reg 10: [io  0xd080-0xd087]
[    0.109267] pci 0000:00:1f.2: reg 14: [io  0xd000-0xd003]
[    0.109267] pci 0000:00:1f.2: reg 18: [io  0xcc00-0xcc07]
[    0.109267] pci 0000:00:1f.2: reg 1c: [io  0xc880-0xc883]
[    0.109267] pci 0000:00:1f.2: reg 20: [io  0xc800-0xc80f]
[    0.109267] pci 0000:00:1f.2: PME# supported from D3hot
[    0.109308] pci 0000:00:1f.3: [8086:27da] type 00 class 0x0c0500
[    0.109308] pci 0000:00:1f.3: reg 20: [io  0x0400-0x041f]
[    0.110081] pci 0000:00:1c.0: PCI bridge to [bus 01]
[    0.110155] pci 0000:02:00.0: [10ec:8136] type 00 class 0x020000
[    0.110155] pci 0000:02:00.0: reg 10: [io  0xe800-0xe8ff]
[    0.110155] pci 0000:02:00.0: reg 18: [mem 0xfebff000-0xfebfffff 64bit]
[    0.110155] pci 0000:02:00.0: reg 20: [mem 0xfdff0000-0xfdffffff 64bit pref]
[    0.110167] pci 0000:02:00.0: reg 30: [mem 0xfebc0000-0xfebdffff pref]
[    0.110261] pci 0000:02:00.0: supports D1 D2
[    0.110262] pci 0000:02:00.0: PME# supported from D0 D1 D2 D3hot D3cold
[    0.112079] pci 0000:00:1c.1: PCI bridge to [bus 02]
[    0.112084] pci 0000:00:1c.1:   bridge window [io  0xe000-0xefff]
[    0.112089] pci 0000:00:1c.1:   bridge window [mem 0xfeb00000-0xfebfffff]
[    0.112098] pci 0000:00:1c.1:   bridge window [mem 0xfdf00000-0xfdffffff 64bit pref]
[    0.112163] pci 0000:00:1e.0: PCI bridge to [bus 03] (subtractive decode)
[    0.112163] pci 0000:00:1e.0:   bridge window [io  0x0000-0x0cf7] (subtractive decode)
[    0.112163] pci 0000:00:1e.0:   bridge window [io  0x0d00-0xffff] (subtractive decode)
[    0.112163] pci 0000:00:1e.0:   bridge window [mem 0x000a0000-0x000bffff] (subtractive decode)
[    0.112163] pci 0000:00:1e.0:   bridge window [mem 0x000d0000-0x000dffff] (subtractive decode)
[    0.112163] pci 0000:00:1e.0:   bridge window [mem 0x7de00000-0xdfffffff] (subtractive decode)
[    0.112163] pci 0000:00:1e.0:   bridge window [mem 0xf0000000-0xffffffff] (subtractive decode)
[    0.112163] pci_bus 0000:00: on NUMA node 0
[    0.115288] ACPI: PCI Interrupt Link [LNKA] (IRQs 3 4 5 6 7 *10 11 12 14 15)
[    0.115400] ACPI: PCI Interrupt Link [LNKB] (IRQs 3 4 5 6 7 10 *11 12 14 15)
[    0.115510] ACPI: PCI Interrupt Link [LNKC] (IRQs 3 4 5 *6 7 10 11 12 14 15)
[    0.115621] ACPI: PCI Interrupt Link [LNKD] (IRQs 3 4 *5 6 7 10 11 12 14 15)
[    0.115730] ACPI: PCI Interrupt Link [LNKE] (IRQs 3 4 5 6 7 10 11 12 14 15) *0, disabled.
[    0.115841] ACPI: PCI Interrupt Link [LNKF] (IRQs 3 4 5 6 7 10 11 12 14 15) *0, disabled.
[    0.115952] ACPI: PCI Interrupt Link [LNKG] (IRQs 3 4 5 6 7 10 11 12 14 15) *0, disabled.
[    0.116068] ACPI: PCI Interrupt Link [LNKH] (IRQs 3 4 5 6 *7 10 11 12 14 15)
[    0.116550] ACPI: Enabled 2 GPEs in block 00 to 1F
[    0.116550] acpi root: \_SB_.PCI0 notify handler is installed
[    0.116550] Found 1 acpi root devices
[    0.117251] ACPI: No dock devices found.
[    0.117282] vgaarb: device added: PCI:0000:00:02.0,decodes=io+mem,owns=io+mem,locks=none
[    0.117282] vgaarb: loaded
[    0.117282] vgaarb: bridge control possible 0000:00:02.0
[    0.118009] SCSI subsystem initialized
[    0.118009] ACPI: bus type ATA registered
[    0.118057] libata version 3.00 loaded.
[    0.118073] ACPI: bus type USB registered
[    0.118077] usbcore: registered new interface driver usbfs
[    0.118077] usbcore: registered new interface driver hub
[    0.118077] usbcore: registered new device driver usb
[    0.119056] pps_core: LinuxPPS API ver. 1 registered
[    0.119056] pps_core: Software ver. 5.3.6 - Copyright 2005-2007 Rodolfo Giometti <giometti@linux.it>
[    0.119059] PTP clock support registered
[    0.119085] Advanced Linux Sound Architecture Driver Initialized.
[    0.119088] PCI: Using ACPI for IRQ routing
[    0.127976] PCI: pci_cache_line_size set to 64 bytes
[    0.128052] Expanded resource reserved due to conflict with PCI Bus 0000:00
[    0.128055] e820: reserve RAM buffer [mem 0x0009fc00-0x0009ffff]
[    0.128057] e820: reserve RAM buffer [mem 0x7dda0000-0x7fffffff]
[    0.129030] cfg80211: Calling CRDA to update world regulatory domain
[    0.129064] NetLabel: Initializing
[    0.129065] NetLabel:  domain hash size = 128
[    0.129067] NetLabel:  protocols = UNLABELED CIPSOv4
[    0.129113] NetLabel:  unlabeled traffic allowed by default
[    0.129175] HPET: 3 timers in total, 0 timers will be used for per-cpu timer
[    0.129175] hpet0: at MMIO 0xfed00000, IRQs 2, 8, 0
[    0.129175] hpet0: 3 comparators, 64-bit 14.318180 MHz counter
[    0.131038] Switching to clocksource hpet
[    0.159528] pnp: PnP ACPI init
[    0.159559] ACPI: bus type PNP registered
[    0.159763] system 00:00: [mem 0xfed14000-0xfed19fff] has been reserved
[    0.159767] system 00:00: [mem 0xfed90000-0xfed93fff] has been reserved
[    0.159819] system 00:00: Plug and Play ACPI device, IDs PNP0c01 (active)
[    0.159901] pnp 00:01: [dma 4]
[    0.160020] pnp 00:01: Plug and Play ACPI device, IDs PNP0200 (active)
[    0.160151] pnp 00:02: Plug and Play ACPI device, IDs PNP0b00 (active)
[    0.160260] pnp 00:03: Plug and Play ACPI device, IDs PNP0800 (active)
[    0.160378] pnp 00:04: Plug and Play ACPI device, IDs PNP0c04 (active)
[    0.161749] system 00:05: [io  0x0a00-0x0a0f] has been reserved
[    0.161752] system 00:05: [io  0x0a10-0x0a1f] has been reserved
[    0.161754] system 00:05: [io  0x0a20-0x0a2f] has been reserved
[    0.161757] system 00:05: [io  0x0a30-0x0a3f] has been reserved
[    0.161762] system 00:05: Plug and Play ACPI device, IDs PNP0c02 (active)
[    0.161976] system 00:06: [io  0x04d0-0x04d1] has been reserved
[    0.161979] system 00:06: [io  0x0800-0x087f] has been reserved
[    0.161981] system 00:06: [io  0x0480-0x04bf] has been reserved
[    0.161984] system 00:06: [mem 0xfed1c000-0xfed1ffff] has been reserved
[    0.161987] system 00:06: [mem 0xfed20000-0xfed8ffff] has been reserved
[    0.161992] system 00:06: Plug and Play ACPI device, IDs PNP0c02 (active)
[    0.162177] pnp 00:07: Plug and Play ACPI device, IDs PNP0103 (active)
[    0.162335] pnp 00:08: Plug and Play ACPI device, IDs INT0800 (active)
[    0.162503] system 00:09: [mem 0xffc00000-0xffefffff] has been reserved
[    0.162509] system 00:09: Plug and Play ACPI device, IDs PNP0c02 (active)
[    0.162723] system 00:0a: [mem 0xfec00000-0xfec00fff] could not be reserved
[    0.162727] system 00:0a: [mem 0xfee00000-0xfee00fff] has been reserved
[    0.162732] system 00:0a: Plug and Play ACPI device, IDs PNP0c02 (active)
[    0.162913] system 00:0b: [mem 0xe0000000-0xefffffff] has been reserved
[    0.162919] system 00:0b: Plug and Play ACPI device, IDs PNP0c02 (active)
[    0.163361] system 00:0c: [mem 0x00000000-0x0009ffff] could not be reserved
[    0.163365] system 00:0c: [mem 0x000c0000-0x000cffff] could not be reserved
[    0.163368] system 00:0c: [mem 0x000e0000-0x000fffff] could not be reserved
[    0.163370] system 00:0c: [mem 0x00100000-0x7ddfffff] could not be reserved
[    0.163376] system 00:0c: Plug and Play ACPI device, IDs PNP0c01 (active)
[    0.163590] pnp: PnP ACPI: found 13 devices
[    0.163592] ACPI: bus type PNP unregistered
[    0.205031] pci 0000:00:1c.0: bridge window [io  0x1000-0x0fff] to [bus 01] add_size 1000
[    0.205035] pci 0000:00:1c.0: bridge window [mem 0x00100000-0x000fffff 64bit pref] to [bus 01] add_size 200000
[    0.205038] pci 0000:00:1c.0: bridge window [mem 0x00100000-0x000fffff] to [bus 01] add_size 200000
[    0.205063] pci 0000:00:1c.0: res[8]=[mem 0x00100000-0x000fffff] get_res_add_size add_size 200000
[    0.205065] pci 0000:00:1c.0: res[9]=[mem 0x00100000-0x000fffff 64bit pref] get_res_add_size add_size 200000
[    0.205068] pci 0000:00:1c.0: res[7]=[io  0x1000-0x0fff] get_res_add_size add_size 1000
[    0.205073] pci 0000:00:1c.0: BAR 8: assigned [mem 0x80000000-0x801fffff]
[    0.205077] pci 0000:00:1c.0: BAR 9: assigned [mem 0x80200000-0x803fffff 64bit pref]
[    0.205081] pci 0000:00:1c.0: BAR 7: assigned [io  0x1000-0x1fff]
[    0.205083] pci 0000:00:1c.0: PCI bridge to [bus 01]
[    0.205088] pci 0000:00:1c.0:   bridge window [io  0x1000-0x1fff]
[    0.205094] pci 0000:00:1c.0:   bridge window [mem 0x80000000-0x801fffff]
[    0.205099] pci 0000:00:1c.0:   bridge window [mem 0x80200000-0x803fffff 64bit pref]
[    0.205108] pci 0000:00:1c.1: PCI bridge to [bus 02]
[    0.205111] pci 0000:00:1c.1:   bridge window [io  0xe000-0xefff]
[    0.205117] pci 0000:00:1c.1:   bridge window [mem 0xfeb00000-0xfebfffff]
[    0.205122] pci 0000:00:1c.1:   bridge window [mem 0xfdf00000-0xfdffffff 64bit pref]
[    0.205130] pci 0000:00:1e.0: PCI bridge to [bus 03]
[    0.205150] pci 0000:00:1c.0: enabling device (0104 -> 0107)
[    0.205297] pci 0000:00:1e.0: setting latency timer to 64
[    0.205301] pci_bus 0000:00: resource 4 [io  0x0000-0x0cf7]
[    0.205303] pci_bus 0000:00: resource 5 [io  0x0d00-0xffff]
[    0.205305] pci_bus 0000:00: resource 6 [mem 0x000a0000-0x000bffff]
[    0.205307] pci_bus 0000:00: resource 7 [mem 0x000d0000-0x000dffff]
[    0.205309] pci_bus 0000:00: resource 8 [mem 0x7de00000-0xdfffffff]
[    0.205310] pci_bus 0000:00: resource 9 [mem 0xf0000000-0xffffffff]
[    0.205313] pci_bus 0000:01: resource 0 [io  0x1000-0x1fff]
[    0.205314] pci_bus 0000:01: resource 1 [mem 0x80000000-0x801fffff]
[    0.205316] pci_bus 0000:01: resource 2 [mem 0x80200000-0x803fffff 64bit pref]
[    0.205318] pci_bus 0000:02: resource 0 [io  0xe000-0xefff]
[    0.205320] pci_bus 0000:02: resource 1 [mem 0xfeb00000-0xfebfffff]
[    0.205322] pci_bus 0000:02: resource 2 [mem 0xfdf00000-0xfdffffff 64bit pref]
[    0.205324] pci_bus 0000:03: resource 4 [io  0x0000-0x0cf7]
[    0.205326] pci_bus 0000:03: resource 5 [io  0x0d00-0xffff]
[    0.205328] pci_bus 0000:03: resource 6 [mem 0x000a0000-0x000bffff]
[    0.205330] pci_bus 0000:03: resource 7 [mem 0x000d0000-0x000dffff]
[    0.205331] pci_bus 0000:03: resource 8 [mem 0x7de00000-0xdfffffff]
[    0.205333] pci_bus 0000:03: resource 9 [mem 0xf0000000-0xffffffff]
[    0.205398] NET: Registered protocol family 2
[    0.205749] TCP established hash table entries: 8192 (order: 4, 65536 bytes)
[    0.205793] TCP bind hash table entries: 8192 (order: 6, 360448 bytes)
[    0.206300] TCP: Hash tables configured (established 8192 bind 8192)
[    0.206338] TCP: reno registered
[    0.206344] UDP hash table entries: 512 (order: 3, 49152 bytes)
[    0.206409] UDP-Lite hash table entries: 512 (order: 3, 49152 bytes)
[    0.206608] NET: Registered protocol family 1
[    0.206836] RPC: Registered named UNIX socket transport module.
[    0.206838] RPC: Registered udp transport module.
[    0.206840] RPC: Registered tcp transport module.
[    0.206841] RPC: Registered tcp NFSv4.1 backchannel transport module.
[    0.206852] pci 0000:00:02.0: Boot video device
[    0.206937] pci 0000:00:1d.0: uhci_check_and_reset_hc: legsup = 0x0f30
[    0.206939] pci 0000:00:1d.0: Performing full reset
[    0.207072] pci 0000:00:1d.1: uhci_check_and_reset_hc: legsup = 0x0030
[    0.207074] pci 0000:00:1d.1: Performing full reset
[    0.207190] pci 0000:00:1d.2: uhci_check_and_reset_hc: legsup = 0x0030
[    0.207191] pci 0000:00:1d.2: Performing full reset
[    0.207295] pci 0000:00:1d.3: uhci_check_and_reset_hc: legsup = 0x0030
[    0.207297] pci 0000:00:1d.3: Performing full reset
[    0.207491] PCI: CLS 32 bytes, default 64
[    0.207693] Unpacking initramfs...
[    0.248293] Freeing initrd memory: 2020k freed
[    0.250288] microcode: CPU0 sig=0x1067a, pf=0x1, revision=0xa07
[    0.250299] microcode: CPU1 sig=0x1067a, pf=0x1, revision=0xa07
[    0.250403] microcode: Microcode Update Driver: v2.00 <tigran@aivazian.fsnet.co.uk>, Peter Oruba
[    0.250405] Scanning for low memory corruption every 60 seconds
[    0.251098] audit: initializing netlink socket (disabled)
[    0.251138] type=2000 audit(1363791624.250:1): initialized
[    0.274475] bounce pool size: 64 pages
[    0.274482] HugeTLB registered 4 MB page size, pre-allocated 0 pages
[    0.282186] VFS: Disk quotas dquot_6.5.2
[    0.282333] Dquot-cache hash table entries: 1024 (order 0, 4096 bytes)
[    0.284690] NFS: Registering the id_resolver key type
[    0.284763] Key type id_resolver registered
[    0.284765] Key type id_legacy registered
[    0.284891] msgmni has been set to 1694
[    0.285198] SELinux:  Registering netfilter hooks
[    0.286272] Block layer SCSI generic (bsg) driver version 0.4 loaded (major 251)
[    0.286286] io scheduler noop registered
[    0.286288] io scheduler deadline registered
[    0.286509] io scheduler cfq registered (default)
[    0.286838] pcieport 0000:00:1c.0: irq 40 for MSI/MSI-X
[    0.287315] pcieport 0000:00:1c.1: irq 41 for MSI/MSI-X
[    0.287780] pci_hotplug: PCI Hot Plug PCI Core version: 0.5
[    0.288346] input: Power Button as /devices/LNXSYSTM:00/LNXSYBUS:00/PNP0C0C:00/input/input0
[    0.288380] ACPI: Power Button [PWRB]
[    0.288513] input: Power Button as /devices/LNXSYSTM:00/LNXPWRBN:00/input/input1
[    0.288518] ACPI: Power Button [PWRF]
[    0.288805] ACPI: Requesting acpi_cpufreq
[    0.297727] Serial: 8250/16550 driver, 4 ports, IRQ sharing enabled
[    0.298033] kworker/u:1 (719) used greatest stack depth: 6488 bytes left
[    0.299247] Non-volatile memory driver v1.3
[    0.299463] intel_rng: Firmware space is locked read-only. If you can't or
[    0.299463] intel_rng: don't want to disable this in firmware setup, and if
[    0.299463] intel_rng: you are certain that your system has a functional
[    0.299463] intel_rng: RNG, try using the 'no_fwh_detect' option.
[    0.299495] Linux agpgart interface v0.103
[    0.300028] agpgart-intel 0000:00:00.0: Intel G41 Chipset
[    0.300114] agpgart-intel 0000:00:00.0: detected gtt size: 2097152K total, 262144K mappable
[    0.300772] agpgart-intel 0000:00:00.0: detected 32768K stolen memory
[    0.301109] agpgart-intel 0000:00:00.0: AGP aperture is 256M @ 0xd0000000
[    0.301307] [drm] Initialized drm 1.1.0 20060810
[    0.302365] [drm] Memory usable by graphics device = 2048M
[    0.302376] pci 0000:00:02.0: setting latency timer to 64
[    0.303144] pci 0000:00:02.0: irq 42 for MSI/MSI-X
[    0.303159] [drm] Supports vblank timestamp caching Rev 1 (10.10.2010).
[    0.303160] [drm] No driver support for vblank timestamp query.
[    0.303280] [drm] Initialized i915 1.6.0 20080730 for 0000:00:02.0 on minor 0
[    0.306111] loop: module loaded
[    0.306698] ata_piix 0000:00:1f.1: version 2.13
[    0.306836] ata_piix 0000:00:1f.1: setting latency timer to 64
[    0.307972] scsi0 : ata_piix
[    0.308729] scsi1 : ata_piix
[    0.309257] ata1: PATA max UDMA/100 cmd 0x1f0 ctl 0x3f6 bmdma 0xffa0 irq 14
[    0.309259] ata2: PATA max UDMA/100 cmd 0x170 ctl 0x376 bmdma 0xffa8 irq 15
[    0.309345] ata_piix 0000:00:1f.2: MAP [
[    0.309346]  P0 P2 P1 P3 ]
[    0.309398] ata_piix 0000:00:1f.2: setting latency timer to 64
[    0.310607] scsi2 : ata_piix
[    0.311274] scsi3 : ata_piix
[    0.311785] ata3: SATA max UDMA/133 cmd 0xd080 ctl 0xd000 bmdma 0xc800 irq 19
[    0.311787] ata4: SATA max UDMA/133 cmd 0xcc00 ctl 0xc880 bmdma 0xc808 irq 19
[    0.312759] e100: Intel(R) PRO/100 Network Driver, 3.5.24-k2-NAPI
[    0.312761] e100: Copyright(c) 1999-2006 Intel Corporation
[    0.312850] e1000: Intel(R) PRO/1000 Network Driver - version 7.3.21-k8-NAPI
[    0.312852] e1000: Copyright (c) 1999-2006 Intel Corporation.
[    0.312947] e1000e: Intel(R) PRO/1000 Network Driver - 2.2.14-k
[    0.312949] e1000e: Copyright(c) 1999 - 2013 Intel Corporation.
[    0.313059] sky2: driver version 1.30
[    0.313353] r8169 Gigabit Ethernet driver 2.3LK-NAPI loaded
[    0.313607] r8169 0000:02:00.0: irq 43 for MSI/MSI-X
[    0.314102] r8169 0000:02:00.0 eth0: RTL8102e at 0xf8020000, 3c:d9:2b:6d:92:20, XID 04c00000 IRQ 43
[    0.314526] ehci_hcd: USB 2.0 'Enhanced' Host Controller (EHCI) Driver
[    0.314529] ehci_hcd: block sizes: qh 60 qtd 96 itd 160 sitd 96
[    0.314539] ehci-pci: EHCI PCI platform driver
[    0.314631] ehci-pci 0000:00:1d.7: setting latency timer to 64
[    0.314635] ehci-pci 0000:00:1d.7: EHCI Host Controller
[    0.314967] ehci-pci 0000:00:1d.7: new USB bus registered, assigned bus number 1
[    0.314985] ehci-pci 0000:00:1d.7: debug port 1
[    0.314989] ehci-pci 0000:00:1d.7: reset hcs_params 0x104208 dbg=1 cc=4 pcc=2 ordered !ppc ports=8
[    0.314992] ehci-pci 0000:00:1d.7: reset hcc_params 6871 thresh 7 uframes 1024 64 bit addr
[    0.315053] ehci-pci 0000:00:1d.7: reset command 0080002 (park)=0 ithresh=8 period=1024 Reset HALT
[    0.318949] ehci-pci 0000:00:1d.7: cache line size of 32 is not supported
[    0.318951] ehci-pci 0000:00:1d.7: supports USB remote wakeup
[    0.318986] ehci-pci 0000:00:1d.7: irq 23, io mem 0xfeaf7c00
[    0.318991] ehci-pci 0000:00:1d.7: init command 0010001 (park)=0 ithresh=1 period=1024 RUN
[    0.325049] ehci-pci 0000:00:1d.7: USB 2.0 started, EHCI 1.00
[    0.325310] usb usb1: default language 0x0409
[    0.325325] usb usb1: udev 1, busnum 1, minor = 0
[    0.325327] usb usb1: New USB device found, idVendor=1d6b, idProduct=0002
[    0.325329] usb usb1: New USB device strings: Mfr=3, Product=2, SerialNumber=1
[    0.325331] usb usb1: Product: EHCI Host Controller
[    0.325333] usb usb1: Manufacturer: Linux 3.9.0-rc1-next-20130307+ ehci_hcd
[    0.325335] usb usb1: SerialNumber: 0000:00:1d.7
[    0.325592] usb usb1: usb_probe_device
[    0.325595] usb usb1: configuration #1 chosen from 1 choice
[    0.325687] usb usb1: adding 1-0:1.0 (config #1, interface 0)
[    0.325833] hub 1-0:1.0: usb_probe_interface
[    0.325835] hub 1-0:1.0: usb_probe_interface - got id
[    0.325839] hub 1-0:1.0: USB hub found
[    0.325865] hub 1-0:1.0: 8 ports detected
[    0.325867] hub 1-0:1.0: standalone hub
[    0.325869] hub 1-0:1.0: no power switching (usb 1.0)
[    0.325870] hub 1-0:1.0: individual port over-current protection
[    0.325872] hub 1-0:1.0: power on to power good time: 20ms
[    0.325940] hub 1-0:1.0: local power source is good
[    0.326043] hub 1-0:1.0: trying to enable port power on non-switchable hub
[    0.326316] ohci_hcd: USB 1.1 'Open' Host Controller (OHCI) Driver
[    0.326318] ohci_hcd: block sizes: ed 64 td 64
[    0.326411] uhci_hcd: USB Universal Host Controller Interface driver
[    0.326513] uhci_hcd 0000:00:1d.0: setting latency timer to 64
[    0.326517] uhci_hcd 0000:00:1d.0: UHCI Host Controller
[    0.326643] uhci_hcd 0000:00:1d.0: new USB bus registered, assigned bus number 2
[    0.326650] uhci_hcd 0000:00:1d.0: detected 2 ports
[    0.326654] uhci_hcd 0000:00:1d.0: uhci_check_and_reset_hc: cmd = 0x0000
[    0.326656] uhci_hcd 0000:00:1d.0: Performing full reset
[    0.326669] uhci_hcd 0000:00:1d.0: supports USB remote wakeup
[    0.326677] uhci_hcd 0000:00:1d.0: irq 23, io base 0x0000d880
[    0.326753] usb usb2: default language 0x0409
[    0.326768] usb usb2: udev 1, busnum 2, minor = 128
[    0.326770] usb usb2: New USB device found, idVendor=1d6b, idProduct=0001
[    0.326772] usb usb2: New USB device strings: Mfr=3, Product=2, SerialNumber=1
[    0.326774] usb usb2: Product: UHCI Host Controller
[    0.326776] usb usb2: Manufacturer: Linux 3.9.0-rc1-next-20130307+ uhci_hcd
[    0.326778] usb usb2: SerialNumber: 0000:00:1d.0
[    0.326936] usb usb2: usb_probe_device
[    0.326938] usb usb2: configuration #1 chosen from 1 choice
[    0.326951] usb usb2: adding 2-0:1.0 (config #1, interface 0)
[    0.327063] hub 2-0:1.0: usb_probe_interface
[    0.327065] hub 2-0:1.0: usb_probe_interface - got id
[    0.327067] hub 2-0:1.0: USB hub found
[    0.327077] hub 2-0:1.0: 2 ports detected
[    0.327079] hub 2-0:1.0: standalone hub
[    0.327080] hub 2-0:1.0: no power switching (usb 1.0)
[    0.327082] hub 2-0:1.0: individual port over-current protection
[    0.327084] hub 2-0:1.0: power on to power good time: 2ms
[    0.327104] hub 2-0:1.0: local power source is good
[    0.327131] hub 2-0:1.0: trying to enable port power on non-switchable hub
[    0.327219] ehci-pci 0000:00:1d.7: HS companion for 0000:00:1d.0
[    0.327294] uhci_hcd 0000:00:1d.1: setting latency timer to 64
[    0.327298] uhci_hcd 0000:00:1d.1: UHCI Host Controller
[    0.327424] uhci_hcd 0000:00:1d.1: new USB bus registered, assigned bus number 3
[    0.327430] uhci_hcd 0000:00:1d.1: detected 2 ports
[    0.327434] uhci_hcd 0000:00:1d.1: uhci_check_and_reset_hc: cmd = 0x0000
[    0.327436] uhci_hcd 0000:00:1d.1: Performing full reset
[    0.327449] uhci_hcd 0000:00:1d.1: supports USB remote wakeup
[    0.327457] uhci_hcd 0000:00:1d.1: irq 19, io base 0x0000d800
[    0.327509] usb usb3: default language 0x0409
[    0.327524] usb usb3: udev 1, busnum 3, minor = 256
[    0.327526] usb usb3: New USB device found, idVendor=1d6b, idProduct=0001
[    0.327528] usb usb3: New USB device strings: Mfr=3, Product=2, SerialNumber=1
[    0.327530] usb usb3: Product: UHCI Host Controller
[    0.327532] usb usb3: Manufacturer: Linux 3.9.0-rc1-next-20130307+ uhci_hcd
[    0.327534] usb usb3: SerialNumber: 0000:00:1d.1
[    0.327692] usb usb3: usb_probe_device
[    0.327694] usb usb3: configuration #1 chosen from 1 choice
[    0.327706] usb usb3: adding 3-0:1.0 (config #1, interface 0)
[    0.327801] hub 3-0:1.0: usb_probe_interface
[    0.327803] hub 3-0:1.0: usb_probe_interface - got id
[    0.327806] hub 3-0:1.0: USB hub found
[    0.327817] hub 3-0:1.0: 2 ports detected
[    0.327818] hub 3-0:1.0: standalone hub
[    0.327820] hub 3-0:1.0: no power switching (usb 1.0)
[    0.327822] hub 3-0:1.0: individual port over-current protection
[    0.327823] hub 3-0:1.0: power on to power good time: 2ms
[    0.327835] hub 3-0:1.0: local power source is good
[    0.327861] hub 3-0:1.0: trying to enable port power on non-switchable hub
[    0.327946] ehci-pci 0000:00:1d.7: HS companion for 0000:00:1d.1
[    0.328034] uhci_hcd 0000:00:1d.2: setting latency timer to 64
[    0.328038] uhci_hcd 0000:00:1d.2: UHCI Host Controller
[    0.328162] uhci_hcd 0000:00:1d.2: new USB bus registered, assigned bus number 4
[    0.328169] uhci_hcd 0000:00:1d.2: detected 2 ports
[    0.328173] uhci_hcd 0000:00:1d.2: uhci_check_and_reset_hc: cmd = 0x0000
[    0.328175] uhci_hcd 0000:00:1d.2: Performing full reset
[    0.328188] uhci_hcd 0000:00:1d.2: supports USB remote wakeup
[    0.328217] uhci_hcd 0000:00:1d.2: irq 18, io base 0x0000d480
[    0.328270] usb usb4: default language 0x0409
[    0.328284] usb usb4: udev 1, busnum 4, minor = 384
[    0.328286] usb usb4: New USB device found, idVendor=1d6b, idProduct=0001
[    0.328288] usb usb4: New USB device strings: Mfr=3, Product=2, SerialNumber=1
[    0.328290] usb usb4: Product: UHCI Host Controller
[    0.328292] usb usb4: Manufacturer: Linux 3.9.0-rc1-next-20130307+ uhci_hcd
[    0.328294] usb usb4: SerialNumber: 0000:00:1d.2
[    0.328451] usb usb4: usb_probe_device
[    0.328454] usb usb4: configuration #1 chosen from 1 choice
[    0.328466] usb usb4: adding 4-0:1.0 (config #1, interface 0)
[    0.328563] hub 4-0:1.0: usb_probe_interface
[    0.328565] hub 4-0:1.0: usb_probe_interface - got id
[    0.328568] hub 4-0:1.0: USB hub found
[    0.328576] hub 4-0:1.0: 2 ports detected
[    0.328578] hub 4-0:1.0: standalone hub
[    0.328579] hub 4-0:1.0: no power switching (usb 1.0)
[    0.328581] hub 4-0:1.0: individual port over-current protection
[    0.328582] hub 4-0:1.0: power on to power good time: 2ms
[    0.328594] hub 4-0:1.0: local power source is good
[    0.328618] hub 4-0:1.0: trying to enable port power on non-switchable hub
[    0.328704] ehci-pci 0000:00:1d.7: HS companion for 0000:00:1d.2
[    0.328778] uhci_hcd 0000:00:1d.3: setting latency timer to 64
[    0.328782] uhci_hcd 0000:00:1d.3: UHCI Host Controller
[    0.328933] uhci_hcd 0000:00:1d.3: new USB bus registered, assigned bus number 5
[    0.328939] uhci_hcd 0000:00:1d.3: detected 2 ports
[    0.328944] uhci_hcd 0000:00:1d.3: uhci_check_and_reset_hc: cmd = 0x0000
[    0.328945] uhci_hcd 0000:00:1d.3: Performing full reset
[    0.328958] uhci_hcd 0000:00:1d.3: supports USB remote wakeup
[    0.328988] uhci_hcd 0000:00:1d.3: irq 16, io base 0x0000d400
[    0.329052] usb usb5: default language 0x0409
[    0.329067] usb usb5: udev 1, busnum 5, minor = 512
[    0.329069] usb usb5: New USB device found, idVendor=1d6b, idProduct=0001
[    0.329071] usb usb5: New USB device strings: Mfr=3, Product=2, SerialNumber=1
[    0.329073] usb usb5: Product: UHCI Host Controller
[    0.329075] usb usb5: Manufacturer: Linux 3.9.0-rc1-next-20130307+ uhci_hcd
[    0.329076] usb usb5: SerialNumber: 0000:00:1d.3
[    0.329235] usb usb5: usb_probe_device
[    0.329237] usb usb5: configuration #1 chosen from 1 choice
[    0.329249] usb usb5: adding 5-0:1.0 (config #1, interface 0)
[    0.329347] hub 5-0:1.0: usb_probe_interface
[    0.329349] hub 5-0:1.0: usb_probe_interface - got id
[    0.329351] hub 5-0:1.0: USB hub found
[    0.329359] hub 5-0:1.0: 2 ports detected
[    0.329361] hub 5-0:1.0: standalone hub
[    0.329362] hub 5-0:1.0: no power switching (usb 1.0)
[    0.329364] hub 5-0:1.0: individual port over-current protection
[    0.329366] hub 5-0:1.0: power on to power good time: 2ms
[    0.329377] hub 5-0:1.0: local power source is good
[    0.329402] hub 5-0:1.0: trying to enable port power on non-switchable hub
[    0.329487] ehci-pci 0000:00:1d.7: HS companion for 0000:00:1d.3
[    0.329664] usbcore: registered new interface driver usblp
[    0.329665] Initializing USB Mass Storage driver...
[    0.329759] usbcore: registered new interface driver usb-storage
[    0.329760] USB Mass Storage support registered.
[    0.330087] i8042: PNP: No PS/2 controller found. Probing ports directly.
[    0.335238] serio: i8042 KBD port at 0x60,0x64 irq 1
[    0.335274] serio: i8042 AUX port at 0x60,0x64 irq 12
[    0.335573] mousedev: PS/2 mouse device common for all mice
[    0.336095] rtc_cmos 00:02: RTC can wake from S4
[    0.336390] rtc_cmos 00:02: rtc core: registered rtc_cmos as rtc0
[    0.336425] rtc_cmos 00:02: alarms up to one month, y3k, 114 bytes nvram, hpet irqs
[    0.336612] i801_smbus 0000:00:1f.3: SMBus using PCI Interrupt
[    0.337144] device-mapper: ioctl: 4.24.0-ioctl (2013-01-15) initialised: dm-devel@redhat.com
[    0.337175] cpuidle: using governor ladder
[    0.337177] cpuidle: using governor menu
[    0.337179] EFI Variables Facility v0.08 2004-May-17
[    0.337316] hidraw: raw HID events driver (C) Jiri Kosina
[    0.338838] usbcore: registered new interface driver usbhid
[    0.338840] usbhid: USB HID core driver
[    0.342235] snd_hda_intel 0000:00:1b.0: irq 44 for MSI/MSI-X
[    0.359868] Netfilter messages via NETLINK v0.30.
[    0.359916] nf_conntrack version 0.5.0 (16384 buckets, 65536 max)
[    0.360281] ctnetlink v0.93: registering with nfnetlink.
[    0.360503] ip_tables: (C) 2000-2006 Netfilter Core Team
[    0.360557] TCP: cubic registered
[    0.360559] Initializing XFRM netlink socket
[    0.361193] NET: Registered protocol family 10
[    0.361670] ip6_tables: (C) 2000-2006 Netfilter Core Team
[    0.361724] sit: IPv6 over IPv4 tunneling driver
[    0.362169] NET: Registered protocol family 17
[    0.362238] Key type dns_resolver registered
[    0.362687] Using IPI No-Shortcut mode
[    0.362962] PM: Hibernation image not present or could not be loaded.
[    0.362997] registered taskstats version 1
[    0.363484]   Magic number: 5:37:33
[    0.363578] console [netcon0] enabled
[    0.363579] netconsole: network logging started
[    0.364369] ALSA device list:
[    0.364371]   #0: HDA Intel at 0xfeaf8000 irq 44
[    0.426216] ehci-pci 0000:00:1d.7: GetStatus port:3 status 001403 0  ACK POWER sig=k CSC CONNECT
[    0.426222] hub 1-0:1.0: port 3: status 0501 change 0001
[    0.426249] ehci-pci 0000:00:1d.7: GetStatus port:4 status 001403 0  ACK POWER sig=k CSC CONNECT
[    0.426254] hub 1-0:1.0: port 4: status 0501 change 0001
[    0.426277] ehci-pci 0000:00:1d.7: GetStatus port:7 status 001803 0  ACK POWER sig=j CSC CONNECT
[    0.426282] hub 1-0:1.0: port 7: status 0501 change 0001
[    0.427158] hub 2-0:1.0: state 7 ports 2 chg 0000 evt 0000
[    0.427163] uhci_hcd 0000:00:1d.1: port 1 portsc 008a,00
[    0.427225] uhci_hcd 0000:00:1d.1: port 2 portsc 008a,00
[    0.428095] hub 4-0:1.0: state 7 ports 2 chg 0000 evt 0000
[    0.429040] uhci_hcd 0000:00:1d.3: port 1 portsc 0082,00
[    0.465213] ata3.00: ATA-8: Hitachi HDS721050CLA662, JP2OA41A, max UDMA/133
[    0.465216] ata3.00: 976773168 sectors, multi 16: LBA48 NCQ (depth 0/32)
[    0.481602] ata3.00: configured for UDMA/133
[    0.481990] scsi 2:0:0:0: Direct-Access     ATA      Hitachi HDS72105 JP2O PQ: 0 ANSI: 5
[    0.482695] sd 2:0:0:0: [sda] 976773168 512-byte logical blocks: (500 GB/465 GiB)
[    0.482819] sd 2:0:0:0: [sda] Write Protect is off
[    0.482821] sd 2:0:0:0: [sda] Mode Sense: 00 3a 00 00
[    0.482871] sd 2:0:0:0: [sda] Write cache: enabled, read cache: enabled, doesn't support DPO or FUA
[    0.483059] sd 2:0:0:0: Attached scsi generic sg0 type 0
[    0.526089] hub 1-0:1.0: state 7 ports 8 chg 0098 evt 0000
[    0.526128] hub 1-0:1.0: port 3, status 0501, change 0000, 480 Mb/s
[    0.526240] ehci-pci 0000:00:1d.7: port 3 low speed --> companion
[    0.537977]  sda: sda1 sda2 sda3 < sda5 sda6 sda7 >
[    0.539446] sd 2:0:0:0: [sda] Attached SCSI disk
[    0.539625] Freeing unused kernel memory: 1880k freed
[    0.540637] Write protecting the kernel text: 7532k
[    0.540923] Write protecting the kernel read-only data: 2876k
[    0.550547] modprobe (945) used greatest stack depth: 6336 bytes left
[    0.577043] ehci-pci 0000:00:1d.7: GetStatus port:3 status 003002 0  ACK POWER OWNER sig=se0 CSC
[    0.577124] hub 1-0:1.0: port 4, status 0501, change 0000, 480 Mb/s
[    0.577134] ehci-pci 0000:00:1d.7: port 4 low speed --> companion
[    0.628048] ehci-pci 0000:00:1d.7: GetStatus port:4 status 003002 0  ACK POWER OWNER sig=se0 CSC
[    0.628100] hub 1-0:1.0: port 7, status 0501, change 0000, 480 Mb/s
[    0.631576] modprobe (988) used greatest stack depth: 6284 bytes left
[    0.645653] modprobe (1008) used greatest stack depth: 6160 bytes left
[    0.679520] ehci-pci 0000:00:1d.7: port 7 reset complete, port enabled
[    0.679526] ehci-pci 0000:00:1d.7: GetStatus port:7 status 001005 0  ACK POWER sig=se0 PE CONNECT
[    0.697562] ata_id (1039) used greatest stack depth: 6148 bytes left
[    0.730050] usb 1-7: new high-speed USB device number 4 using ehci-pci
[    0.781269] ehci-pci 0000:00:1d.7: port 7 reset complete, port enabled
[    0.781275] ehci-pci 0000:00:1d.7: GetStatus port:7 status 001005 0  ACK POWER sig=se0 PE CONNECT
[    0.844808] usb 1-7: default language 0x0409
[    0.845558] usb 1-7: udev 4, busnum 1, minor = 3
[    0.845565] usb 1-7: New USB device found, idVendor=058f, idProduct=6366
[    0.845570] usb 1-7: New USB device strings: Mfr=1, Product=2, SerialNumber=3
[    0.845575] usb 1-7: Product: Mass Storage Device
[    0.845580] usb 1-7: Manufacturer: Generic
[    0.845585] usb 1-7: SerialNumber: 058F63666433
[    0.845849] usb 1-7: usb_probe_device
[    0.845852] usb 1-7: configuration #1 chosen from 1 choice
[    0.846090] usb 1-7: adding 1-7:1.0 (config #1, interface 0)
[    0.846355] usb-storage 1-7:1.0: usb_probe_interface
[    0.846359] usb-storage 1-7:1.0: usb_probe_interface - got id
[    0.846558] scsi4 : usb-storage 1-7:1.0
[    0.846847] hub 1-0:1.0: state 7 ports 8 chg 0000 evt 0018
[    0.846856] ehci-pci 0000:00:1d.7: GetStatus port:3 status 003002 0  ACK POWER OWNER sig=se0 CSC
[    0.846868] hub 1-0:1.0: port 3, status 0100, change 0001, 12 Mb/s
[    0.891983] blkid (1058) used greatest stack depth: 6064 bytes left
[    0.950056] hub 1-0:1.0: debounce: port 3: total 100ms stable 100ms status 0x100
[    0.950076] ehci-pci 0000:00:1d.7: GetStatus port:4 status 003002 0  ACK POWER OWNER sig=se0 CSC
[    0.950104] hub 1-0:1.0: port 4, status 0100, change 0001, 12 Mb/s
[    1.054053] hub 1-0:1.0: debounce: port 4: total 100ms stable 100ms status 0x100
[    1.054074] hub 3-0:1.0: state 7 ports 2 chg 0000 evt 0006
[    1.054096] uhci_hcd 0000:00:1d.1: port 1 portsc 01a3,00
[    1.054129] hub 3-0:1.0: port 1, status 0301, change 0001, 1.5 Mb/s
[    1.158037] hub 3-0:1.0: debounce: port 1: total 100ms stable 100ms status 0x301
[    1.251449] PM: Starting manual resume from disk
[    1.251456] PM: Hibernation image partition 8:6 present
[    1.251457] PM: Looking for hibernation image.
[    1.252117] tsc: Refined TSC clocksource calibration: 3199.999 MHz
[    1.252138] Switching to clocksource tsc
[    1.252216] PM: Image not found (code -22)
[    1.252217] PM: Hibernation image not present or could not be loaded.
[    1.256371] EXT4-fs (sda5): INFO: recovery required on readonly filesystem
[    1.256374] EXT4-fs (sda5): write access will be enabled during recovery
[    1.260054] usb 3-1: new low-speed USB device number 2 using uhci_hcd
[    1.421556] usb 3-1: skipped 1 descriptor after interface
[    1.427541] usb 3-1: default language 0x0409
[    1.454026] usb usb2: suspend_rh (auto-stop)
[    1.454060] usb usb4: suspend_rh (auto-stop)
[    1.454142] usb usb5: suspend_rh (auto-stop)
[    1.454162] usb 3-1: udev 2, busnum 3, minor = 257
[    1.454164] usb 3-1: New USB device found, idVendor=413c, idProduct=2105
[    1.454166] usb 3-1: New USB device strings: Mfr=1, Product=2, SerialNumber=0
[    1.454168] usb 3-1: Product: Dell USB Keyboard
[    1.454170] usb 3-1: Manufacturer: Dell
[    1.454283] usb 3-1: usb_probe_device
[    1.454286] usb 3-1: configuration #1 chosen from 1 choice
[    1.474552] usb 3-1: adding 3-1:1.0 (config #1, interface 0)
[    1.489657] usbhid 3-1:1.0: usb_probe_interface
[    1.489663] usbhid 3-1:1.0: usb_probe_interface - got id
[    1.522381] input: Dell Dell USB Keyboard as /devices/pci0000:00/0000:00:1d.1/usb3/3-1/3-1:1.0/input/input2
[    1.522478] uhci_hcd 0000:00:1d.1: reserve dev 2 ep81-INT, period 16, phase 8, 118 us
[    1.522858] hid-generic 0003:413C:2105.0001: input,hidraw0: USB HID v1.10 Keyboard [Dell Dell USB Keyboard] on usb-0000:00:1d.1-1/input0
[    1.523042] uhci_hcd 0000:00:1d.1: port 2 portsc 01a3,00
[    1.523055] hub 3-0:1.0: port 2, status 0301, change 0001, 1.5 Mb/s
[    1.627053] hub 3-0:1.0: debounce: port 2: total 100ms stable 100ms status 0x301
[    1.713612] EXT4-fs (sda5): recovery complete
[    1.721583] EXT4-fs (sda5): mounted filesystem with ordered data mode. Opts: (null)
[    1.721745] exe (1086) used greatest stack depth: 5296 bytes left
[    1.730438] usb 3-2: new low-speed USB device number 3 using uhci_hcd
[    1.849566] scsi 4:0:0:0: Direct-Access     Multiple Card  Reader     1.00 PQ: 0 ANSI: 0
[    1.850037] sd 4:0:0:0: Attached scsi generic sg1 type 0
[    1.851466] sd 4:0:0:0: [sdb] Attached SCSI removable disk
[    1.871553] usb 3-2: skipped 1 descriptor after interface
[    1.876541] usb 3-2: default language 0x0409
[    1.893544] usb 3-2: udev 3, busnum 3, minor = 258
[    1.893551] usb 3-2: New USB device found, idVendor=046d, idProduct=c045
[    1.893556] usb 3-2: New USB device strings: Mfr=1, Product=2, SerialNumber=0
[    1.893561] usb 3-2: Product: USB-PS/2 Optical Mouse
[    1.893566] usb 3-2: Manufacturer: Logitech
[    1.893743] usb 3-2: usb_probe_device
[    1.893746] usb 3-2: configuration #1 chosen from 1 choice
[    1.896576] usb 3-2: adding 3-2:1.0 (config #1, interface 0)
[    1.896691] usbhid 3-2:1.0: usb_probe_interface
[    1.896697] usbhid 3-2:1.0: usb_probe_interface - got id
[    1.911112] input: Logitech USB-PS/2 Optical Mouse as /devices/pci0000:00/0000:00:1d.1/usb3/3-2/3-2:1.0/input/input3
[    1.911259] hid-generic 0003:046D:C045.0002: input,hidraw1: USB HID v1.10 Mouse [Logitech USB-PS/2 Optical Mouse] on usb-0000:00:1d.1-2/input0
[    1.911343] hub 5-0:1.0: state 7 ports 2 chg 0000 evt 0000
[    1.911347] hub 3-0:1.0: state 7 ports 2 chg 0000 evt 0000
[    2.708193] udevd[1177]: starting version 175
[    5.225094] Adding 4100092k swap on /dev/sda6.  Priority:-1 extents:1 across:4100092k 
[    5.245558] EXT4-fs (sda5): re-mounted. Opts: (null)
[    5.396944] EXT4-fs (sda5): re-mounted. Opts: errors=remount-ro
[    5.994049] EXT4-fs (sda7): recovery complete
[    6.033806] EXT4-fs (sda7): mounted filesystem with ordered data mode. Opts: errors=remount-ro
[    6.391258] r8169 0000:02:00.0 eth0: link down
[    6.391350] r8169 0000:02:00.0 eth0: link down
[    6.391425] IPv6: ADDRCONF(NETDEV_UP): eth0: link is not ready
[    7.886728] r8169 0000:02:00.0 eth0: link up
[    7.886757] IPv6: ADDRCONF(NETDEV_CHANGE): eth0: link becomes ready
[   17.016563] uhci_hcd 0000:00:1d.1: reserve dev 3 ep81-INT, period 8, phase 4, 99 us
[   21.711517] colord[3342]: segfault at 8 ip 08052674 sp bf970b00 error 4 in colord[8048000+20000]
[  342.126739] uhci_hcd 0000:00:1d.1: release dev 3 ep81-INT, period 8, phase 4, 99 us
[  906.336111] flush-8:0 (2038) used greatest stack depth: 5096 bytes left
[ 1328.068633] NET: Registered protocol family 33
[ 1328.068641] Key type rxrpc registered
[ 1328.068644] Key type rxrpc_s registered
[ 1338.907734] [a.out ] ==> rxrpc_create(f4fc6800,2)
[ 1338.907747] [a.out ] <== rxrpc_create() = 0 [f5f04e00]
[ 1338.907767] [a.out ] ==> rxrpc_setsockopt(,272,3,,0)
[ 1338.907937] [a.out ] ==> rxrpc_bind(f5f04e00,f5d65ecc,36)
[ 1338.907942] [a.out ]     INET: 1b59 @ 0.0.0.0
[ 1338.907950] [a.out ] ==> rxrpc_lookup_local({2,2,0.0.0.0+7001})
[ 1338.908123] [a.out ] <== rxrpc_alloc_local() = f5fb9000
[ 1338.908128] [a.out ] ==> rxrpc_create_local(f5fb9000{2})
[ 1338.908159] [a.out ]     bind
[ 1338.908257] [a.out ] <== rxrpc_create_local() = 0
[ 1338.908263] [a.out ] @@@ LOCAL new 1 {2,2,0.0.0.0+7001}
[ 1338.908267] [a.out ] <== rxrpc_lookup_local() = f5fb9000 [new]
[ 1338.908273] [a.out ] <== rxrpc_bind() = 0
[ 1338.908284] [a.out ] ==> rxrpc_connect(f5f04e00,f5d65ecc,36,2)
[ 1338.908288] [a.out ]     INET: 1b5c @ 127.0.0.1
[ 1338.908295] [a.out ] ==> rxrpc_name_to_transport(f5f04e00,f5d65ecc,36,2)
[ 1338.908300] [a.out ] ==> rxrpc_get_peer({2,16,127.0.0.1+7004})
[ 1338.908349] [a.out ] ==> rxrpc_alloc_peer()
[ 1338.908365] [a.out ] <== rxrpc_assess_MTU_size() [if_mtu 65520]
[ 1338.908368] [a.out ] <== rxrpc_alloc_peer() = f5fb8c00
[ 1338.908383] [a.out ] @@@ PEER new 2 {2,2,127.0.0.1+7004}
[ 1338.908387] [a.out ] <== rxrpc_get_peer() = f5fb8c00 {u=1}
[ 1338.908393] [a.out ] ==> rxrpc_get_transport({0.0.0.0+7001},{127.0.0.1+7004},)
[ 1338.908438] [a.out ] ==> rxrpc_alloc_transport()
[ 1338.908444] [a.out ] <== rxrpc_alloc_transport() = f5664400
[ 1338.908458] [a.out ] @@@ TRANSPORT new 3 local 1 -> peer 2
[ 1338.908462] [a.out ] <== rxrpc_get_transport() = f5664400 {u=1}
[ 1338.908465] [a.out ] ==> rxrpc_put_peer(f5fb8c00{u=2})
[ 1338.908469] [a.out ] <== rxrpc_put_peer() [in use]
[ 1338.908472] [a.out ] <== rxrpc_name_to_transport() = f5664400
[ 1338.908784] [a.out ] ==> rxrpc_sendmsg(,{2},,16384)
[ 1338.908791] [a.out ] ==> rxrpc_client_sendmsg()
[ 1338.908795] [a.out ]     CMSG 272, 1, 4
[ 1338.908798] [a.out ]     User Call ID 12345
[ 1338.908802] [a.out ] <== rxrpc_sendmsg_cmsg() = 0
[ 1338.908807] [a.out ] ==> rxrpc_get_bundle(f5f04e00{0},3,2db,)
[ 1338.908896] [a.out ] ==> rxrpc_alloc_bundle()
[ 1338.908901] [a.out ] <== rxrpc_alloc_bundle() = f3610f00
[ 1338.908905] [a.out ] @@@ BUNDLE new on trans 3
[ 1338.908909] [a.out ] <== rxrpc_get_bundle() = f3610f00 [new]
[ 1338.908914] [a.out ] ==> rxrpc_get_client_call(f5f04e00,3,0,12345,1)
[ 1338.908986] [a.out ] ==> rxrpc_alloc_client_call()
[ 1338.908996] [a.out ] ==> rxrpc_connect_call(f5f04e00,0,)
[ 1338.908999] [a.out ] ==> rxrpc_connect_exclusive()
[ 1338.909038] [a.out ] ==> rxrpc_alloc_connection()
[ 1338.909048] [a.out ] <== rxrpc_alloc_connection() = f5fb8e00{5}
[ 1338.909054] [a.out ] ==> rxrpc_init_client_conn_security({5},{0})
[ 1338.909126] [a.out ] @@@ CONNECT EXCL new 5 on TRANS 3
[ 1338.909132] [a.out ] ==> rxrpc_assign_connection_id()
[ 1338.909211] [a.out ] <== rxrpc_assign_connection_id() [CONNID 4 CID 4]
[ 1338.909215] [a.out ] @@@ CONNECT client on conn 5 chan 0 as call 1
[ 1338.909292] [a.out ] <== rxrpc_connect_exclusive() = 0
[ 1338.909393] [a.out ] <== rxrpc_alloc_client_call() = f5d57400
[ 1338.909480] [a.out ] @@@ CALL new 4 on CONN 5
[ 1338.909486] [a.out ] <== rxrpc_get_client_call() = f5d57400 [new]
[ 1338.909493] [a.out ] ==> rxrpc_put_bundle(f5664400,f3610f00{2})
[ 1338.909499] [a.out ] <== rxrpc_put_bundle()
[ 1338.909505] [a.out ]     CALL 4 USR 12345 ST 0 on CONN f5fb8e00
[ 1338.909511] [a.out ] ==> rxrpc_send_data(,,,{1},16384)
[ 1338.909517] [a.out ]     SEGMENT 16384 @bfbbef3c
[ 1338.909523] [a.out ]     alloc
[ 1338.909531] [a.out ]     SIZE: 16384/16388/16416
[ 1338.909561] [a.out ]     ALLOC SEND f5007f00
[ 1338.909565] [a.out ]     HS: 28
[ 1338.909569] [a.out ] @@@ skb: hr 28, tr 32548, hl 28, rm 16384
[ 1338.909572] [a.out ]     append
[ 1338.909575] [a.out ]     add
[ 1338.909642] [a.out ]     added
[ 1338.909651] [a.out ] @@@ queue skb f5007f00 [0]
[ 1338.909656] [a.out ]     ________awaiting reply/ACK__________
[ 1338.909734] [a.out ] ### Tx DATA %1 { #1 }
[ 1338.909737] [a.out ]     run timer
[ 1338.909744] [a.out ] ==> rxrpc_send_packet(,{16412})
[ 1338.910223] [a.out ] ==> rxrpc_data_ready(f430d500, 520)
[ 1338.910259] [a.out ] ==> rxrpc_put_local(f5fb9000{u=3})
[ 1338.910290] [a.out ] <== rxrpc_put_local()
[ 1338.910295] [a.out ] ==> rxrpc_UDP_error_report(f430d500{1})
[ 1338.910301] [a.out ] @@@ Rx UDP Error from 127.0.0.1:7004
[ 1338.910304] [a.out ]     Msg l:520 d:0
[ 1338.910308] [a.out ] ==> rxrpc_find_peer()
[ 1338.910338] [a.out ] @@@ Rx UDP DGRAM from peer 2
[ 1338.910343] [a.out ] <== rxrpc_find_peer() = f5fb8c00
[ 1338.910348] [a.out ] ==> rxrpc_find_transport({0.0.0.0+7001},{127.0.0.1+7004},)
[ 1338.910379] [a.out ] <== rxrpc_find_transport() = f5664400
[ 1338.910383] [a.out ] ==> rxrpc_put_peer(f5fb8c00{u=2})
[ 1338.910387] [a.out ] <== rxrpc_put_peer() [in use]
[ 1338.910612] [a.out ] <== rxrpc_UDP_error_report()
[ 1338.910630] [a.out ] <== rxrpc_send_packet() = 16412 [65464]
[ 1338.910634] [a.out ] @@@ sent skb f5007f00
[ 1338.910637] [a.out ] <== rxrpc_queue_packet()
[ 1338.910640] [a.out ] <== rxrpc_send_data() = 16384
[ 1338.910645] [a.out ] ==> __rxrpc_put_call(f5d57400{u=2})
[ 1338.910648] [a.out ] <== __rxrpc_put_call()
[ 1338.910651] [a.out ] <== rxrpc_client_sendmsg() = 16384
[ 1338.910657] [a.out ] ==> rxrpc_put_transport(f5664400{u=4})
[ 1338.910661] [a.out ] <== rxrpc_put_transport()
[ 1338.910664] [a.out ] <== rxrpc_sendmsg() = 16384
[ 1338.911122] [kworke] ==> rxrpc_UDP_error_handler()
[ 1338.911139] [kworke] @@@ Rx Error o=2 t=3 c=3 e=111
[ 1338.911142] [kworke] @@@ Rx Received ICMP Port Unreachable
[ 1338.911146] [kworke]     ISSUE ERROR 111
[ 1338.911183] [kworke] ==> rxrpc_put_transport(f5664400{u=3})
[ 1338.911187] [kworke] <== rxrpc_put_transport()
[ 1338.911190] [kworke] <== rxrpc_UDP_error_handler()
[ 1338.911253] [kworke] ==> rxrpc_process_call({4,NetError,8} [0])
[ 1338.911258] [kworke]     post net error 111
[ 1338.911263] [kworke] ==> rxrpc_post_message({4,a8},4,111,1)
[ 1338.911442] [kworke] ==> rxrpc_queue_rcv_skb(,,1,1)
[ 1338.911456] [kworke]     <<<< TERMINAL MESSAGE >>>>
[ 1338.911458] [kworke] @@@ post skb f5007900
[ 1338.911463] [kworke] <== rxrpc_queue_rcv_skb() = 0
[ 1338.911468] [kworke] <== rxrpc_process_call()
[ 1338.911623] [a.out ] ==> rxrpc_recvmsg(,,,16384,0)
[ 1338.911630] [a.out ]     next pkt ?00
[ 1338.911649] [a.out ]     non-data
[ 1338.911655] [a.out ]     RECV NET ERROR 111
[ 1338.911660] [a.out ]     terminal
[ 1338.911664] [a.out ] @@@ free terminal skb f5007900
[ 1338.911681] [a.out ] ==> rxrpc_packet_destructor(f5007900{f5d57400})
[ 1338.911685] [a.out ] ==> __rxrpc_put_call(f5d57400{u=3})
[ 1338.911689] [a.out ] <== __rxrpc_put_call()
[ 1338.911692] [a.out ] <== rxrpc_packet_destructor()
[ 1338.911697] [a.out ]     RELEASE CALL 4
[ 1338.911832] [a.out ] ==> __rxrpc_put_call(f5d57400{u=2})
[ 1338.911836] [a.out ] <== __rxrpc_put_call()
[ 1338.911839] [a.out ] <== rxrpc_recvmsg() = 0
[ 1338.911852] [kworke] ==> rxrpc_process_call({4,NetError,10000} [0])
[ 1338.911856] [kworke] ==> rxrpc_release_call({4,1,0,0})
[ 1338.911862] [kworke]     RELEASE CALL f5d57400 (4 CONN f5fb8e00)
[ 1338.911988] [kworke] <== rxrpc_release_call()
[ 1338.911993] [kworke] <== rxrpc_process_call()
[ 1338.913715] [a.out ] ==> rxrpc_sendmsg(,{2},,16384)
[ 1338.913723] [a.out ] ==> rxrpc_client_sendmsg()
[ 1338.913727] [a.out ]     CMSG 272, 1, 4
[ 1338.913730] [a.out ]     User Call ID 12345
[ 1338.913734] [a.out ] <== rxrpc_sendmsg_cmsg() = 0
[ 1338.913739] [a.out ] ==> rxrpc_get_bundle(f5f04e00{0},3,2db,)
[ 1338.913743] [a.out ] ==> rxrpc_get_client_call(f5f04e00,3,0,12345,1)
[ 1338.913748] [a.out ] ==> rxrpc_alloc_client_call()
[ 1338.913758] [a.out ] ==> rxrpc_connect_call(f5f04e00,0,)
[ 1338.913761] [a.out ] ==> rxrpc_connect_exclusive()
[ 1338.913765] [a.out ] @@@ CONNECT client on conn 5 chan 0 as call 2
[ 1338.913769] 
[ 1338.913838] =====================================
[ 1338.913918] [ BUG: bad unlock balance detected! ]
[ 1338.914000] 3.9.0-rc1-next-20130307+ #6 Not tainted
[ 1338.914012] -------------------------------------
[ 1338.914012] a.out/3864 is trying to release lock (&(&trans->client_lock)->rlock) at:
[ 1338.914012] [<f8137f27>] rxrpc_connect_call+0x317/0xbb0 [af_rxrpc]
[ 1338.914012] but there are no more locks to release!
[ 1338.914012] 
[ 1338.914012] other info that might help us debug this:
[ 1338.914012] 1 lock held by a.out/3864:
[ 1338.914012]  #0:  (sk_lock-AF_RXRPC){+.+.+.}, at: [<f812fca2>] rxrpc_sendmsg+0x52/0x220 [af_rxrpc]
[ 1338.914012] 
[ 1338.914012] stack backtrace:
[ 1338.914012] Pid: 3864, comm: a.out Not tainted 3.9.0-rc1-next-20130307+ #6
[ 1338.914012] Call Trace:
[ 1338.914012]  [<f8137f27>] ? rxrpc_connect_call+0x317/0xbb0 [af_rxrpc]
[ 1338.914012]  [<c1088fd5>] print_unlock_imbalance_bug+0xe5/0xf0
[ 1338.914012]  [<f8137f27>] ? rxrpc_connect_call+0x317/0xbb0 [af_rxrpc]
[ 1338.914012]  [<f8137f27>] ? rxrpc_connect_call+0x317/0xbb0 [af_rxrpc]
[ 1338.914012]  [<c108d65d>] lock_release_non_nested+0x1cd/0x310
[ 1338.914012]  [<c1036f55>] ? vprintk_emit+0x185/0x4f0
[ 1338.914012]  [<f8137f27>] ? rxrpc_connect_call+0x317/0xbb0 [af_rxrpc]
[ 1338.914012]  [<c108d83f>] lock_release+0x9f/0x240
[ 1338.914012]  [<c10968b7>] ? __module_address+0x117/0x120
[ 1338.914012]  [<f8137f27>] ? rxrpc_connect_call+0x317/0xbb0 [af_rxrpc]
[ 1338.914012]  [<c1752096>] _raw_spin_unlock+0x16/0x20
[ 1338.914012]  [<f8137f27>] rxrpc_connect_call+0x317/0xbb0 [af_rxrpc]
[ 1338.914012]  [<c1065c40>] ? try_to_wake_up+0x250/0x250
[ 1338.914012]  [<f8134aa9>] ? rxrpc_alloc_call+0x219/0x2d0 [af_rxrpc]
[ 1338.914012]  [<f8136221>] rxrpc_get_client_call+0xe1/0x4d0 [af_rxrpc]
[ 1338.914012]  [<f81407b5>] rxrpc_client_sendmsg+0xd5/0x270 [af_rxrpc]
[ 1338.914012]  [<c103ce9a>] ? local_bh_enable+0x5a/0xc0
[ 1338.914012]  [<f812fd20>] rxrpc_sendmsg+0xd0/0x220 [af_rxrpc]
[ 1338.914012]  [<c124727a>] ? selinux_socket_sendmsg+0x1a/0x20
[ 1338.914012]  [<c1572dee>] sock_sendmsg+0xbe/0xe0
[ 1338.914012]  [<c1102574>] ? might_fault+0x84/0x90
[ 1338.914012]  [<c1291d8d>] ? _copy_from_user+0x3d/0x60
[ 1338.914012]  [<c1574257>] __sys_sendmsg+0x217/0x220
[ 1338.914012]  [<c106820f>] ? sched_clock_cpu+0xcf/0x150
[ 1338.914012]  [<c1087d9b>] ? trace_hardirqs_off+0xb/0x10
[ 1338.914012]  [<c10682de>] ? local_clock+0x4e/0x60
[ 1338.914012]  [<c1088378>] ? lock_release_holdtime.part.23+0xb8/0x100
[ 1338.914012]  [<c1087d9b>] ? trace_hardirqs_off+0xb/0x10
[ 1338.914012]  [<c10682de>] ? local_clock+0x4e/0x60
[ 1338.914012]  [<c108d74b>] ? lock_release_non_nested+0x2bb/0x310
[ 1338.914012]  [<c113afd1>] ? fget_light+0x371/0x450
[ 1338.914012]  [<c157528e>] SyS_sendmsg+0x3e/0x70
[ 1338.914012]  [<c15757a7>] SyS_socketcall+0x117/0x2d0
[ 1338.914012]  [<c175953a>] sysenter_do_call+0x12/0x32
[ 1338.918247] [a.out ] <== rxrpc_connect_exclusive() = 0
[ 1338.918337] [a.out ] <== rxrpc_alloc_client_call() = f43e89c0
[ 1338.918425] [a.out ] @@@ CALL new 6 on CONN 5
[ 1338.918504] [a.out ] <== rxrpc_get_client_call() = f43e89c0 [new]
[ 1338.918589] [a.out ] ==> rxrpc_put_bundle(f5664400,f3610f00{2})
[ 1338.918674] [a.out ] <== rxrpc_put_bundle()
[ 1338.918755] [a.out ]     CALL 6 USR 12345 ST 0 on CONN f5fb8e00
[ 1338.918842] [a.out ] ==> rxrpc_send_data(,,,{1},16384)
[ 1338.918926] [a.out ]     SEGMENT 16384 @bfbbef3c
[ 1338.919019] [a.out ]     alloc
[ 1338.919096] [a.out ]     SIZE: 16384/16388/16416
[ 1338.919181] [a.out ]     ALLOC SEND f50aa300
[ 1338.919261] [a.out ]     HS: 28
[ 1338.919337] [a.out ] @@@ skb: hr 28, tr 32548, hl 28, rm 16384
[ 1338.919422] [a.out ]     append
[ 1338.919497] [a.out ]     add
[ 1338.919575] [a.out ]     added
[ 1338.919651] [a.out ] @@@ queue skb f50aa300 [0]
[ 1338.919730] [a.out ]     ________awaiting reply/ACK__________
[ 1338.919816] [a.out ] ### Tx DATA %2 { #1 }
[ 1338.919893] [a.out ]     run timer
[ 1338.919970] [a.out ] ==> rxrpc_send_packet(,{16412})
[ 1338.920158] [a.out ] ==> rxrpc_data_ready(f430d500, 520)
[ 1338.920245] [a.out ] ==> rxrpc_put_local(f5fb9000{u=3})
[ 1338.920328] [a.out ] <== rxrpc_put_local()
[ 1338.920394] [a.out ] ==> rxrpc_UDP_error_report(f430d500{1})
[ 1338.920465] [a.out ] @@@ Rx UDP Error from 127.0.0.1:7004
[ 1338.920535] [a.out ]     Msg l:520 d:0
[ 1338.920600] [a.out ] ==> rxrpc_find_peer()
[ 1338.920665] [a.out ] @@@ Rx UDP DGRAM from peer 2
[ 1338.920732] [a.out ] <== rxrpc_find_peer() = f5fb8c00
[ 1338.920801] [a.out ] ==> rxrpc_find_transport({0.0.0.0+7001},{127.0.0.1+7004},)
[ 1338.920911] [a.out ] <== rxrpc_find_transport() = f5664400
[ 1338.920980] [a.out ] ==> rxrpc_put_peer(f5fb8c00{u=2})
[ 1338.921055] [a.out ] <== rxrpc_put_peer() [in use]
[ 1338.921126] [a.out ] <== rxrpc_UDP_error_report()
[ 1338.921195] [a.out ] <== rxrpc_send_packet() = 16412 [65464]
[ 1338.921265] [a.out ] @@@ sent skb f50aa300
[ 1338.921331] [a.out ] <== rxrpc_queue_packet()
[ 1338.921398] [a.out ] <== rxrpc_send_data() = 16384
[ 1338.921465] [a.out ] ==> __rxrpc_put_call(f43e89c0{u=2})
[ 1338.921533] [a.out ] <== __rxrpc_put_call()
[ 1338.921599] [a.out ] <== rxrpc_client_sendmsg() = 16384
[ 1338.921668] [a.out ] ==> rxrpc_put_transport(f5664400{u=4})
[ 1338.921737] [a.out ] <== rxrpc_put_transport()
[ 1338.921803] [a.out ] <== rxrpc_sendmsg() = 16384
[ 1338.921872] [kworke] ==> rxrpc_UDP_error_handler()
[ 1338.921940] [kworke] @@@ Rx Error o=2 t=3 c=3 e=111
[ 1338.922013] [kworke] @@@ Rx Received ICMP Port Unreachable
[ 1338.922082] [kworke]     ISSUE ERROR 111
[ 1338.922149] [kworke] ==> rxrpc_put_transport(f5664400{u=3})
[ 1338.922219] [kworke] <== rxrpc_put_transport()
[ 1338.922978] [kworke] <== rxrpc_UDP_error_handler()
[ 1338.922979] [kworke] ==> rxrpc_process_call({6,NetError,8} [0])
[ 1338.922980] [kworke]     post net error 111
[ 1338.922981] [kworke] ==> rxrpc_post_message({6,a8},4,111,1)
[ 1338.922983] [kworke] ==> rxrpc_queue_rcv_skb(,,1,1)
[ 1338.922983] [kworke]     <<<< TERMINAL MESSAGE >>>>
[ 1338.922984] [kworke] @@@ post skb f50aa900
[ 1338.922984] [kworke] <== rxrpc_queue_rcv_skb() = 0
[ 1338.922985] [kworke] <== rxrpc_process_call()
[ 1338.923688] [a.out ] ==> rxrpc_release(f4fc6800{f5f04e00})
[ 1338.923758] [a.out ] ==> rxrpc_release_sock(f5f04e00{2,3})
[ 1338.923829] [a.out ] ==> rxrpc_release_calls_on_socket(f5f04e00)
[ 1338.923903] [a.out ] <== rxrpc_release_calls_on_socket()
[ 1338.923973] [kworke] ==> rxrpc_process_call({6,NetError,10000} [0])
[ 1338.924050] [kworke] ==> rxrpc_release_call({6,2,0,0})
[ 1338.924120] [kworke]     RELEASE CALL f43e89c0 (6 CONN f5fb8e00)
[ 1340.912007] [swappe] ==> rxrpc_dead_call_expired({4})
[ 1340.912079] [swappe] ==> __rxrpc_put_call(f5d57400{u=1})
[ 1340.912148] [swappe]     call 4 dead
[ 1340.912212] [swappe] <== __rxrpc_put_call()
[ 1340.912284] [kworke] ==> rxrpc_destroy_call(f5d57400{0,0,f5fb8e00})
[ 1340.912355] [kworke] @@@ DESTROY CALL 4
[ 1340.912421] [kworke] ==> rxrpc_put_connection(f5fb8e00{u=3,d=5})
[ 1340.912492] [kworke] <== rxrpc_put_connection()
[ 1340.912558] [kworke]     kill Tx window 1
[ 1340.912623] [kworke]     +++ clear Tx 1
[ 1340.912688] [kworke] ==> rxrpc_write_space(f5f04e00)
[ 1340.912757] [kworke] <== rxrpc_destroy_call()
[ 1364.035001] BUG: soft lockup - CPU#0 stuck for 22s! [kworker/0:2:1069]
[ 1364.035001] Modules linked in: af_rxrpc
[ 1364.035001] irq event stamp: 179286
[ 1364.035001] hardirqs last  enabled at (179285): [<c1752012>] _raw_spin_unlock_irq+0x22/0x30
[ 1364.035001] hardirqs last disabled at (179286): [<c1751910>] _raw_spin_lock_irq+0x10/0x70
[ 1364.035001] softirqs last  enabled at (179276): [<f81319cb>] rxrpc_post_message+0x11b/0x210 [af_rxrpc]
[ 1364.035001] softirqs last disabled at (179264): [<c1751adf>] _raw_spin_lock_bh+0xf/0x70
[ 1364.035001] Pid: 1069, comm: kworker/0:2 Not tainted 3.9.0-rc1-next-20130307+ #6 Hewlett-Packard HP 500B Microtower/2A8C
[ 1364.035001] EIP: 0060:[<c12904b7>] EFLAGS: 00000297 CPU: 0
[ 1364.035001] EIP is at delay_tsc+0x17/0x60
[ 1364.035001] EAX: 922e7bc0 EBX: f566447c ECX: 00000405 EDX: 00000404
[ 1364.035001] ESI: 00000000 EDI: 00000001 EBP: f50d5d00 ESP: f50d5cf4
[ 1364.035001]  DS: 007b ES: 007b FS: 00d8 GS: 0000 SS: 0068
[ 1364.035001] CR0: 8005003b CR2: bfbc1000 CR3: 33616000 CR4: 000407d0
[ 1364.035001] DR0: 00000000 DR1: 00000000 DR2: 00000000 DR3: 00000000
[ 1364.035001] DR6: ffff0ff0 DR7: 00000400
[ 1364.035001] Process kworker/0:2 (pid: 1069, ti=f50d4000 task=f5dc27f0 task.ti=f50d4000)
[ 1364.035001] Stack:
[ 1364.035001]  f566447c 3146c044 00000000 f50d5d08 c1290419 f50d5d20 c1297e69 bebc9d00
[ 1364.035001]  f566447c f566448c f5fb8e00 f50d5d40 c1751862 00000000 00000002 00000000
[ 1364.035001]  f8135bbe f43e89c0 f43e8c24 f50d5d80 f8135bbe f8149790 f5dc2ad0 f43e89c0
[ 1364.035001] Call Trace:
[ 1364.035001]  [<c1290419>] __delay+0x9/0x10
[ 1364.035001]  [<c1297e69>] do_raw_spin_lock+0x69/0x140
[ 1364.035001]  [<c1751862>] _raw_spin_lock+0x52/0x70
[ 1364.035001]  [<f8135bbe>] ? rxrpc_release_call+0xce/0x650 [af_rxrpc]
[ 1364.035001]  [<f8135bbe>] rxrpc_release_call+0xce/0x650 [af_rxrpc]
[ 1364.035001]  [<f8132583>] rxrpc_process_call+0x323/0x23a0 [af_rxrpc]
[ 1364.035001]  [<c106eb58>] ? dequeue_task_fair+0xa18/0xc70
[ 1364.035001]  [<c108a3ab>] ? trace_hardirqs_on+0xb/0x10
[ 1364.035001]  [<c1060f6a>] ? finish_task_switch+0x7a/0xe0
[ 1364.035001]  [<c104fee8>] ? process_one_work+0x108/0x420
[ 1364.035001]  [<c104ff62>] process_one_work+0x182/0x420
[ 1364.035001]  [<c104fee8>] ? process_one_work+0x108/0x420
[ 1364.035001]  [<c105258e>] ? worker_thread+0x18e/0x2d0
[ 1364.035001]  [<c105258e>] ? worker_thread+0x18e/0x2d0
[ 1364.035001]  [<c10524f2>] worker_thread+0xf2/0x2d0
[ 1364.035001]  [<c1052400>] ? manage_workers+0x2c0/0x2c0
[ 1364.035001]  [<c10573ef>] kthread+0x8f/0xa0
[ 1364.035001]  [<c108a3ab>] ? trace_hardirqs_on+0xb/0x10
[ 1364.035001]  [<c17594b7>] ret_from_kernel_thread+0x1b/0x28
[ 1364.035001]  [<c1057360>] ? flush_kthread_work+0x140/0x140
[ 1364.035001] Code: 15 3c be a5 c1 5d c3 8d b6 00 00 00 00 8d bc 27 00 00 00 00 55 89 e5 57 89 c7 56 53 64 8b 35 10 70 b3 c1 8d 76 00 0f ae e8 0f 31 <89> c3 eb 12 90 8d 74 26 00 f3 90 64 8b 0d 10 70 b3 c1 39 ce 75

--8t9RHnE3ZwKMSgU+--
