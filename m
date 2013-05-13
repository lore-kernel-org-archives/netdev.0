From: Denys Fedoryshchenko <denys@visp.net.lb>
Subject: r8169 not working under latest kernels
Date: Mon, 13 May 2013 14:59:00 +0300
Message-ID: <6901a7785249816fe13a98e3c0b35127@visp.net.lb>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
 format=flowed
Content-Transfer-Encoding: 7bit
To: hayeswang <hayeswang@realtek.com>,
	Francois Romieu <romieu@fr.zoreil.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from hosting.visp.net.lb ([194.146.153.11]:51620 "EHLO
	hosting.visp.net.lb" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751038Ab3EML7F (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 13 May 2013 07:59:05 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi

Noticed on 32-builds of my systems that r8169 is not working anymore at 
all.
Problem started to occur somewhere after 3.6 kernels, but it is 
difficult to try other kernels on this semi-embedded system, and i am 
not completely sure about that.
Once i used another OS build, but 64-bit build with same latest kernel, 
and it worked.
It spits netdev watchdog timeouts, and constantly shows interface coming 
up.

Here is max debug output(dmesg) i got, with some inline comments:
[    0.000000] Linux version 3.9.2-build-0063 (root@centaur) (gcc 
version 4.5.3 (Gentoo 4.5.3-r2 p1.2, pie-0.4.7) ) #4 SMP Mon May 13 
12:29:39 EEST 2013
[    0.000000] e820: BIOS-provided physical RAM map:
[    0.000000] BIOS-e820: [mem 0x0000000000000000-0x000000000009ebff] 
usable
[    0.000000] BIOS-e820: [mem 0x000000000009ec00-0x000000000009ffff] 
reserved
[    0.000000] BIOS-e820: [mem 0x00000000000e0000-0x00000000000fffff] 
reserved
[    0.000000] BIOS-e820: [mem 0x0000000000100000-0x00000000bd87efff] 
usable
[    0.000000] BIOS-e820: [mem 0x00000000bd87f000-0x00000000bd901fff] 
ACPI NVS
[    0.000000] BIOS-e820: [mem 0x00000000bd902000-0x00000000bda42fff] 
reserved
[    0.000000] BIOS-e820: [mem 0x00000000bda43000-0x00000000bda56fff] 
ACPI NVS
[    0.000000] BIOS-e820: [mem 0x00000000bda57000-0x00000000bdb54fff] 
reserved
[    0.000000] BIOS-e820: [mem 0x00000000bdb55000-0x00000000bdb5dfff] 
ACPI data
[    0.000000] BIOS-e820: [mem 0x00000000bdb5e000-0x00000000bdb67fff] 
ACPI NVS
[    0.000000] BIOS-e820: [mem 0x00000000bdb68000-0x00000000bdb88fff] 
reserved
[    0.000000] BIOS-e820: [mem 0x00000000bdb89000-0x00000000bdb8efff] 
ACPI NVS
[    0.000000] BIOS-e820: [mem 0x00000000bdb8f000-0x00000000bdcfffff] 
usable
[    0.000000] BIOS-e820: [mem 0x00000000fec00000-0x00000000fec00fff] 
reserved
[    0.000000] BIOS-e820: [mem 0x00000000fed00000-0x00000000fed00fff] 
reserved
[    0.000000] BIOS-e820: [mem 0x00000000fed1c000-0x00000000fed8ffff] 
reserved
[    0.000000] BIOS-e820: [mem 0x00000000fff00000-0x00000000ffffffff] 
reserved
[    0.000000] BIOS-e820: [mem 0x0000000100000000-0x000000013fffffff] 
usable
[    0.000000] NX (Execute Disable) protection: active
[    0.000000] SMBIOS 2.4 present.
[    0.000000] DMI:                  /DG41RQ, BIOS 
RQG4110H.86A.0013.2009.1223.1136 12/23/2009
[    0.000000] e820: update [mem 0x00000000-0x00000fff] usable ==> 
reserved
[    0.000000] e820: remove [mem 0x000a0000-0x000fffff] usable
[    0.000000] e820: last_pfn = 0x140000 max_arch_pfn = 0x1000000
[    0.000000] MTRR default type: uncachable
[    0.000000] MTRR fixed ranges enabled:
[    0.000000]   00000-9FFFF write-back
[    0.000000]   A0000-E7FFF uncachable
[    0.000000]   E8000-FFFFF write-protect
[    0.000000] MTRR variable ranges enabled:
[    0.000000]   0 base 000000000 mask F00000000 write-back
[    0.000000]   1 base 100000000 mask FC0000000 write-back
[    0.000000]   2 base 0BDD00000 mask FFFF00000 write-through
[    0.000000]   3 base 0BDE00000 mask FFFE00000 uncachable
[    0.000000]   4 base 0BE000000 mask FFE000000 uncachable
[    0.000000]   5 base 0C0000000 mask FC0000000 uncachable
[    0.000000]   6 disabled
[    0.000000] x86 PAT enabled: cpu 0, old 0x7040600070406, new 
0x7010600070106
[    0.000000] found SMP MP-table at [mem 0x000fd640-0x000fd64f] mapped 
at [c00fd640]
[    0.000000] initial memory mapped: [mem 0x00000000-0x031fffff]
[    0.000000] Base memory trampoline at [c009a000] 9a000 size 16384
[    0.000000] init_memory_mapping: [mem 0x00000000-0x000fffff]
[    0.000000]  [mem 0x00000000-0x000fffff] page 4k
[    0.000000] init_memory_mapping: [mem 0x37800000-0x379fffff]
[    0.000000]  [mem 0x37800000-0x379fffff] page 2M
[    0.000000] init_memory_mapping: [mem 0x34000000-0x377fffff]
[    0.000000]  [mem 0x34000000-0x377fffff] page 2M
[    0.000000] init_memory_mapping: [mem 0x00100000-0x33ffffff]
[    0.000000]  [mem 0x00100000-0x001fffff] page 4k
[    0.000000]  [mem 0x00200000-0x33ffffff] page 2M
[    0.000000] init_memory_mapping: [mem 0x37a00000-0x37bfdfff]
[    0.000000]  [mem 0x37a00000-0x37bfdfff] page 4k
[    0.000000] BRK [0x02cdb000, 0x02cdbfff] PGTABLE
[    0.000000] cma: CMA: reserved 16 MiB at 36800000
[    0.000000] ACPI: RSDP 000f03c0 00024 (v02  INTEL)
[    0.000000] ACPI: XSDT bdb5ce18 00044 (v01 INTEL  DG41RQ   0000000D 
MSFT 00010013)
[    0.000000] ACPI: FACP bdb5bd98 000F4 (v04  INTEL   DG41RQ 0000000D 
MSFT 00010013)
[    0.000000] ACPI Warning: 32/64 FACS address mismatch in FADT - two 
FACS tables! (20130117/tbfadt-395)
[    0.000000] ACPI BIOS Bug: Warning: 32/64X FACS address mismatch in 
FADT - 0xBDB5FF40/0x00000000BDB64F40, using 32 (20130117/tbfadt-522)
[    0.000000] ACPI: DSDT bdb55018 05983 (v01 INTEL  DG41RQ   0000000D 
INTL 20051117)
[    0.000000] ACPI: FACS bdb5ff40 00040
[    0.000000] ACPI: APIC bdb5bf18 0006C (v02 INTEL  DG41RQ   0000000D 
MSFT 00010013)
[    0.000000] ACPI: MCFG bdb66e18 0003C (v01 INTEL  DG41RQ   0000000D 
MSFT 00000097)
[    0.000000] ACPI: HPET bdb66d98 00038 (v01 INTEL  DG41RQ   0000000D 
AMI. 00000003)
[    0.000000] ACPI: Local APIC address 0xfee00000
[    0.000000] 4228MB HIGHMEM available.
[    0.000000] 891MB LOWMEM available.
[    0.000000]   mapped low ram: 0 - 37bfe000
[    0.000000]   low ram: 0 - 37bfe000
[    0.000000] BRK [0x02cdc000, 0x02cdcfff] PGTABLE
[    0.000000] Zone ranges:
[    0.000000]   DMA      [mem 0x00001000-0x00ffffff]
[    0.000000]   Normal   [mem 0x01000000-0x37bfdfff]
[    0.000000]   HighMem  [mem 0x37bfe000-0x3fffffff]
[    0.000000] Movable zone start for each node
[    0.000000] Early memory node ranges
[    0.000000]   node   0: [mem 0x00001000-0x0009dfff]
[    0.000000]   node   0: [mem 0x00100000-0xbd87efff]
[    0.000000]   node   0: [mem 0xbdb8f000-0xbdcfffff]
[    0.000000]   node   0: [mem 0x00000000-0x3fffffff]
[    0.000000] On node 0 totalpages: 1038733
[    0.000000]   DMA zone: 32 pages used for memmap
[    0.000000]   DMA zone: 0 pages reserved
[    0.000000]   DMA zone: 3997 pages, LIFO batch:0
[    0.000000]   Normal zone: 1752 pages used for memmap
[    0.000000]   Normal zone: 224254 pages, LIFO batch:31
[    0.000000]   HighMem zone: 6332 pages used for memmap
[    0.000000]   HighMem zone: 810482 pages, LIFO batch:31
[    0.000000] Using APIC driver default
[    0.000000] ACPI: PM-Timer IO Port: 0x808
[    0.000000] ACPI: Local APIC address 0xfee00000
[    0.000000] ACPI: LAPIC (acpi_id[0x01] lapic_id[0x00] enabled)
[    0.000000] ACPI: LAPIC (acpi_id[0x02] lapic_id[0x01] enabled)
[    0.000000] ACPI: LAPIC (acpi_id[0x03] lapic_id[0x02] disabled)
[    0.000000] ACPI: LAPIC (acpi_id[0x04] lapic_id[0x03] disabled)
[    0.000000] ACPI: IOAPIC (id[0x04] address[0xfec00000] gsi_base[0])
[    0.000000] IOAPIC[0]: apic_id 4, version 32, address 0xfec00000, GSI 
0-23
[    0.000000] ACPI: INT_SRC_OVR (bus 0 bus_irq 0 global_irq 2 dfl dfl)
[    0.000000] ACPI: INT_SRC_OVR (bus 0 bus_irq 9 global_irq 9 high 
level)
[    0.000000] ACPI: IRQ0 used by override.
[    0.000000] ACPI: IRQ2 used by override.
[    0.000000] ACPI: IRQ9 used by override.
[    0.000000] Using ACPI (MADT) for SMP configuration information
[    0.000000] ACPI: HPET id: 0x8086a201 base: 0xfed00000
[    0.000000] smpboot: Allowing 4 CPUs, 2 hotplug CPUs
[    0.000000] nr_irqs_gsi: 40
[    0.000000] e820: [mem 0xbdd00000-0xfebfffff] available for PCI 
devices
[    0.000000] setup_percpu: NR_CPUS:8 nr_cpumask_bits:8 nr_cpu_ids:4 
nr_node_ids:1
[    0.000000] PERCPU: Embedded 12 pages/cpu @f7b99000 s27328 r0 d21824 
u49152
[    0.000000] pcpu-alloc: s27328 r0 d21824 u49152 alloc=12*4096
[    0.000000] pcpu-alloc: [0] 0 [0] 1 [0] 2 [0] 3
[    0.000000] Built 1 zonelists in Zone order, mobility grouping on.  
Total pages: 1036949
[    0.000000] Kernel command line: panic=1 BOOT_IMAGE=kernel
[    0.000000] PID hash table entries: 4096 (order: 2, 16384 bytes)
[    0.000000] Dentry cache hash table entries: 131072 (order: 7, 524288 
bytes)
[    0.000000] Inode-cache hash table entries: 65536 (order: 6, 262144 
bytes)
[    0.000000] __ex_table already sorted, skipping sort
[    0.000000] Initializing CPU#0
[    0.000000] xsave: enabled xstate_bv 0x3, cntxt size 0x240
[    0.000000] Initializing HighMem for node 0 (00037bfe:00140000)
[    0.000000] Memory: 4059584k/5242880k available (2970k kernel code, 
95348k reserved, 1600k data, 34948k init, 3241928k highmem)
[    0.000000] virtual kernel memory layout:
[    0.000000]     fixmap  : 0xfff17000 - 0xfffff000   ( 928 kB)
[    0.000000]     pkmap   : 0xffc00000 - 0xffe00000   (2048 kB)
[    0.000000]     vmalloc : 0xf83fe000 - 0xffbfe000   ( 120 MB)
[    0.000000]     lowmem  : 0xc0000000 - 0xf7bfe000   ( 891 MB)
[    0.000000]       .init : 0xc0577000 - 0xc2798000   (34948 kB)
[    0.000000]       .data : 0xc03e6adb - 0xc0576b00   (1600 kB)
[    0.000000]       .text : 0xc0100000 - 0xc03e6adb   (2970 kB)
[    0.000000] Checking if this processor honours the WP bit even in 
supervisor mode...Ok.
[    0.000000] SLUB: Genslabs=15, HWalign=64, Order=0-3, MinObjects=0, 
CPUs=4, Nodes=1
[    0.000000] Hierarchical RCU implementation.
[    0.000000]  RCU restricting CPUs from NR_CPUS=8 to nr_cpu_ids=4.
[    0.000000] NR_IRQS:2304 nr_irqs:712 16
[    0.000000] CPU 0 irqstacks, hard=f4408000 soft=f440a000
[    0.000000] Console: colour VGA+ 80x25
[    0.000000] console [tty0] enabled
[    0.000000] Lock dependency validator: Copyright (c) 2006 Red Hat, 
Inc., Ingo Molnar
[    0.000000] ... MAX_LOCKDEP_SUBCLASSES:  8
[    0.000000] ... MAX_LOCK_DEPTH:          48
[    0.000000] ... MAX_LOCKDEP_KEYS:        8191
[    0.000000] ... CLASSHASH_SIZE:          4096
[    0.000000] ... MAX_LOCKDEP_ENTRIES:     16384
[    0.000000] ... MAX_LOCKDEP_CHAINS:      32768
[    0.000000] ... CHAINHASH_SIZE:          16384
[    0.000000]  memory used by lock dependency info: 3567 kB
[    0.000000]  per task-struct memory footprint: 1152 bytes
[    0.000000] hpet clockevent registered
[    0.000000] tsc: Fast TSC calibration using PIT
[    0.000000] tsc: Detected 2933.469 MHz processor
[    0.001001] Calibrating delay loop (skipped), value calculated using 
timer frequency.. 5866.93 BogoMIPS (lpj=2933469)
[    0.001178] pid_max: default: 32768 minimum: 301
[    0.001343] Mount-cache hash table entries: 512
[    0.002437] CPU: Physical Processor ID: 0
[    0.002523] CPU: Processor Core ID: 0
[    0.002608] mce: CPU supports 6 MCE banks
[    0.002697] CPU0: Thermal monitoring enabled (TM2)
[    0.002792] Last level iTLB entries: 4KB 128, 2MB 4, 4MB 4
[    0.002792] Last level dTLB entries: 4KB 256, 2MB 0, 4MB 32
[    0.002792] tlb_flushall_shift: -1
[    0.003133] Freeing SMP alternatives: 8k freed
[    0.003222] ACPI: Core revision 20130117
[    0.005562] ACPI: All ACPI Tables successfully acquired
[    0.005886] Enabling APIC mode:  Flat.  Using 1 I/O APICs
[    0.006318] ..TIMER: vector=0x30 apic1=0 pin1=2 apic2=0 pin2=0
[    0.016416] smpboot: CPU0: Intel(R) Core(TM)2 Duo CPU     E7500  @ 
2.93GHz (fam: 06, model: 17, stepping: 0a)
[    0.017000] Performance Events: PEBS fmt0+, 4-deep LBR, Core2 events, 
Intel PMU driver.
[    0.017000] ... version:                2
[    0.017000] ... bit width:              40
[    0.017000] ... generic registers:      2
[    0.017000] ... value mask:             000000ffffffffff
[    0.017000] ... max period:             000000007fffffff
[    0.017000] ... fixed-purpose events:   3
[    0.017000] ... event mask:             0000000700000003
[    0.017483] SMP alternatives: lockdep: fixing up alternatives
[    0.017592] CPU 1 irqstacks, hard=f44b8000 soft=f44ba000
[    0.002000] Initializing CPU#1
[    0.017594] smpboot: Booting Node   0, Processors  #1
[    0.029094] Brought up 2 CPUs
[    0.030003] smpboot: Total of 2 processors activated (11733.87 
BogoMIPS)
[    0.031181] NMI watchdog: enabled on all CPUs, permanently consumes 
one hw-PMU counter.
[    0.032468] PM: Registering ACPI NVS region [mem 
0xbd87f000-0xbd901fff] (536576 bytes)
[    0.032468] PM: Registering ACPI NVS region [mem 
0xbda43000-0xbda56fff] (81920 bytes)
[    0.032468] PM: Registering ACPI NVS region [mem 
0xbdb5e000-0xbdb67fff] (40960 bytes)
[    0.033034] PM: Registering ACPI NVS region [mem 
0xbdb89000-0xbdb8efff] (24576 bytes)
[    0.033477] NET: Registered protocol family 16
[    0.034169] ACPI: bus type PCI registered
[    0.034182] PCI: MMCONFIG for domain 0000 [bus 00-ff] at [mem 
0xe0000000-0xefffffff] (base 0xe0000000)
[    0.034235] PCI: not using MMCONFIG
[    0.054003] PCI: Using configuration type 1 for base access
[    0.060066] bio: create slab <bio-0> at 0
[    0.060170] ACPI: Added _OSI(Module Device)
[    0.060170] ACPI: Added _OSI(Processor Device)
[    0.060225] ACPI: Added _OSI(3.0 _SCP Extensions)
[    0.060312] ACPI: Added _OSI(Processor Aggregator Device)
[    0.062902] ACPI: EC: Look up EC in DSDT
[    0.065902] ACPI: Executed 1 blocks of module-level executable AML 
code
[    0.068875] ACPI: SSDT bdb5fc18 002CC (v01    AMI      IST 00000001 
MSFT 03000001)
[    0.069638] ACPI: Dynamic OEM Table Load:
[    0.069641] ACPI: SSDT   (null) 002CC (v01    AMI      IST 00000001 
MSFT 03000001)
[    0.069943] ACPI: Interpreter enabled
[    0.070010] ACPI Exception: AE_NOT_FOUND, While evaluating Sleep 
State [\_S1_] (20130117/hwxface-568)
[    0.070014] ACPI Exception: AE_NOT_FOUND, While evaluating Sleep 
State [\_S2_] (20130117/hwxface-568)
[    0.070038] ACPI: (supports S0 S3 S5)
[    0.070124] ACPI: Using IOAPIC for interrupt routing
[    0.070235] PCI: MMCONFIG for domain 0000 [bus 00-ff] at [mem 
0xe0000000-0xefffffff] (base 0xe0000000)
[    0.070427] PCI: MMCONFIG at [mem 0xe0000000-0xefffffff] reserved in 
ACPI motherboard resources
[    0.070581] PCI: Using MMCONFIG for extended config space
[    0.071037] PCI: Using host bridge windows from ACPI; if necessary, 
use "pci=nocrs" and report a bug
[    0.071249] [Firmware Bug]: ACPI: BIOS _OSI(Linux) query ignored
[    0.082266] ACPI: PCI Root Bridge [PCI0] (domain 0000 [bus 00-ff])
[    0.082653] PCI host bridge to bus 0000:00
[    0.082653] pci_bus 0000:00: root bus resource [bus 00-ff]
[    0.082653] pci_bus 0000:00: root bus resource [io  0x0000-0x0cf7]
[    0.082653] pci_bus 0000:00: root bus resource [io  0x0d00-0xffff]
[    0.082653] pci_bus 0000:00: root bus resource [mem 
0x000a0000-0x000bffff]
[    0.082653] pci_bus 0000:00: root bus resource [mem 
0xc0000000-0xffffffff]
[    0.082653] pci 0000:00:00.0: [8086:2e30] type 00 class 0x060000
[    0.083066] pci 0000:00:01.0: [8086:2e31] type 01 class 0x060400
[    0.083127] pci 0000:00:01.0: PME# supported from D0 D3hot D3cold
[    0.083194] pci 0000:00:01.0: System wakeup disabled by ACPI
[    0.083194] pci 0000:00:02.0: [8086:2e32] type 00 class 0x030000
[    0.083194] pci 0000:00:02.0: reg 10: [mem 0xd0000000-0xd03fffff 
64bit]
[    0.083194] pci 0000:00:02.0: reg 18: [mem 0xc0000000-0xcfffffff 
64bit pref]
[    0.083194] pci 0000:00:02.0: reg 20: [io  0xf140-0xf147]
[    0.084067] pci 0000:00:1c.0: [8086:27d0] type 01 class 0x060400
[    0.084156] pci 0000:00:1c.0: PME# supported from D0 D3hot D3cold
[    0.084220] pci 0000:00:1c.0: System wakeup disabled by ACPI
[    0.084358] pci 0000:00:1c.1: [8086:27d2] type 01 class 0x060400
[    0.084358] pci 0000:00:1c.1: PME# supported from D0 D3hot D3cold
[    0.084358] pci 0000:00:1c.1: System wakeup disabled by ACPI
[    0.084358] pci 0000:00:1d.0: [8086:27c8] type 00 class 0x0c0300
[    0.084358] pci 0000:00:1d.0: reg 20: [io  0xf080-0xf09f]
[    0.084358] pci 0000:00:1d.0: System wakeup disabled by ACPI
[    0.085032] pci 0000:00:1d.1: [8086:27c9] type 00 class 0x0c0300
[    0.085081] pci 0000:00:1d.1: reg 20: [io  0xf060-0xf07f]
[    0.085164] pci 0000:00:1d.1: System wakeup disabled by ACPI
[    0.085303] pci 0000:00:1d.2: [8086:27ca] type 00 class 0x0c0300
[    0.085303] pci 0000:00:1d.2: reg 20: [io  0xf040-0xf05f]
[    0.085303] pci 0000:00:1d.2: System wakeup disabled by ACPI
[    0.085303] pci 0000:00:1d.3: [8086:27cb] type 00 class 0x0c0300
[    0.085303] pci 0000:00:1d.3: reg 20: [io  0xf020-0xf03f]
[    0.085303] pci 0000:00:1d.3: System wakeup disabled by ACPI
[    0.086043] pci 0000:00:1d.7: [8086:27cc] type 00 class 0x0c0320
[    0.086066] pci 0000:00:1d.7: reg 10: [mem 0xd0500000-0xd05003ff]
[    0.086165] pci 0000:00:1d.7: PME# supported from D0 D3hot D3cold
[    0.086224] pci 0000:00:1d.7: System wakeup disabled by ACPI
[    0.086361] pci 0000:00:1e.0: [8086:244e] type 01 class 0x060401
[    0.086361] pci 0000:00:1e.0: System wakeup disabled by ACPI
[    0.086361] pci 0000:00:1f.0: [8086:27b8] type 00 class 0x060100
[    0.086361] pci 0000:00:1f.0: ICH7 LPC Generic IO decode 1 PIO at 
0a00 (mask 00ff)
[    0.087032] pci 0000:00:1f.1: [8086:27df] type 00 class 0x01018a
[    0.087048] pci 0000:00:1f.1: reg 10: [io  0x0000-0x0007]
[    0.087058] pci 0000:00:1f.1: reg 14: [io  0x0000-0x0003]
[    0.087069] pci 0000:00:1f.1: reg 18: [io  0x08f0-0x08f7]
[    0.087080] pci 0000:00:1f.1: reg 1c: [io  0x08f8-0x08fb]
[    0.087091] pci 0000:00:1f.1: reg 20: [io  0xf0f0-0xf0ff]
[    0.087184] pci 0000:00:1f.2: [8086:27c0] type 00 class 0x01018f
[    0.087184] pci 0000:00:1f.2: reg 10: [io  0xf0e0-0xf0e7]
[    0.087184] pci 0000:00:1f.2: reg 14: [io  0xf0d0-0xf0d3]
[    0.087184] pci 0000:00:1f.2: reg 18: [io  0xf0c0-0xf0c7]
[    0.087184] pci 0000:00:1f.2: reg 1c: [io  0xf0b0-0xf0b3]
[    0.087184] pci 0000:00:1f.2: reg 20: [io  0xf0a0-0xf0af]
[    0.087184] pci 0000:00:1f.2: PME# supported from D3hot
[    0.087218] pci 0000:00:1f.3: [8086:27da] type 00 class 0x0c0500
[    0.087218] pci 0000:00:1f.3: reg 20: [io  0x0400-0x041f]
[    0.088026] pci 0000:00:01.0: PCI bridge to [bus 01]
[    0.088191] pci 0000:00:1c.0: PCI bridge to [bus 02]
[    0.088194] pci 0000:03:00.0: [10ec:8168] type 00 class 0x020000
[    0.088194] pci 0000:03:00.0: reg 10: [io  0xe000-0xe0ff]
[    0.088194] pci 0000:03:00.0: reg 18: [mem 0xd0414000-0xd0414fff 
64bit pref]
[    0.088194] pci 0000:03:00.0: reg 20: [mem 0xd0410000-0xd0413fff 
64bit pref]
[    0.088194] pci 0000:03:00.0: reg 30: [mem 0xd0400000-0xd040ffff 
pref]
[    0.088211] pci 0000:03:00.0: supports D1 D2
[    0.088214] pci 0000:03:00.0: PME# supported from D0 D1 D2 D3hot 
D3cold
[    0.090045] pci 0000:00:1c.1: PCI bridge to [bus 03]
[    0.090145] pci 0000:00:1c.1:   bridge window [io  0xe000-0xefff]
[    0.090153] pci 0000:00:1c.1:   bridge window [mem 
0xd0400000-0xd04fffff]
[    0.091075] pci 0000:00:1e.0: PCI bridge to [bus 04] (subtractive 
decode)
[    0.091178] pci 0000:00:1e.0:   bridge window [io  0x0000-0x0cf7] 
(subtractive decode)
[    0.091180] pci 0000:00:1e.0:   bridge window [io  0x0d00-0xffff] 
(subtractive decode)
[    0.091183] pci 0000:00:1e.0:   bridge window [mem 
0x000a0000-0x000bffff] (subtractive decode)
[    0.091185] pci 0000:00:1e.0:   bridge window [mem 
0xc0000000-0xffffffff] (subtractive decode)
[    0.091206] pci_bus 0000:00: on NUMA node 0
[    0.091278] acpi PNP0A08:00: Requesting ACPI _OSC control (0x1d)
[    0.091490] acpi PNP0A08:00: ACPI _OSC control (0x1d) granted
[    0.092207] ACPI: PCI Interrupt Link [LNKA] (IRQs 3 4 5 6 7 *10 12 14 
15)
[    0.092562] ACPI: PCI Interrupt Link [LNKB] (IRQs 3 4 *5 6 7 10 11 12 
14 15)
[    0.092933] ACPI: PCI Interrupt Link [LNKC] (IRQs 3 4 5 6 7 10 *11 12 
14 15)
[    0.093308] ACPI: PCI Interrupt Link [LNKD] (IRQs 3 *4 5 6 10 11 12 
14 15)
[    0.093661] ACPI: PCI Interrupt Link [LNKE] (IRQs 3 4 5 6 7 10 11 12 
14 15) *0, disabled.
[    0.094066] ACPI: PCI Interrupt Link [LNKF] (IRQs 3 4 5 6 7 10 11 12 
14 15) *0, disabled.
[    0.094532] ACPI: PCI Interrupt Link [LNKG] (IRQs 3 4 5 6 7 10 11 12 
14 15) *0, disabled.
[    0.095066] ACPI: PCI Interrupt Link [LNKH] (IRQs *3 4 5 6 7 10 11 12 
14 15)
[    0.096053] ACPI: Enabled 2 GPEs in block 00 to 1F
[    0.096062] acpi root: \_SB_.PCI0 notify handler is installed
[    0.096153] Found 1 acpi root devices
[    0.096182] ACPI: No dock devices found.
[    0.097037] SCSI subsystem initialized
[    0.097124] ACPI: bus type ATA registered
[    0.097217] libata version 3.00 loaded.
[    0.097217] ACPI: bus type USB registered
[    0.097217] usbcore: registered new interface driver usbfs
[    0.097217] usbcore: registered new interface driver hub
[    0.097217] usbcore: registered new device driver usb
[    0.098036] PCI: Using ACPI for IRQ routing
[    0.104122] PCI: pci_cache_line_size set to 64 bytes
[    0.104173] e820: reserve RAM buffer [mem 0x0009ec00-0x0009ffff]
[    0.104175] e820: reserve RAM buffer [mem 0xbd87f000-0xbfffffff]
[    0.104178] e820: reserve RAM buffer [mem 0xbdd00000-0xbfffffff]
[    0.105154] HPET: 3 timers in total, 0 timers will be used for 
per-cpu timer
[    0.105249] hpet0: at MMIO 0xfed00000, IRQs 2, 8, 0
[    0.105408] hpet0: 3 comparators, 64-bit 14.318180 MHz counter
[    0.107047] Switching to clocksource hpet
[    0.108238] pnp: PnP ACPI init
[    0.108345] ACPI: bus type PNP registered
[    0.108584] system 00:00: [mem 0xfed14000-0xfed19fff] has been 
reserved
[    0.110389] system 00:00: [mem 0xe0000000-0xefffffff] has been 
reserved
[    0.110545] system 00:00: Plug and Play ACPI device, IDs PNP0c01 
(active)
[    0.110752] system 00:01: [io  0x0800-0x087f] has been reserved
[    0.110844] system 00:01: [io  0x0480-0x04bf] has been reserved
[    0.110935] system 00:01: [mem 0xfec00000-0xfec00fff] could not be 
reserved
[    0.111047] system 00:01: [mem 0xfee00000-0xfee00fff] has been 
reserved
[    0.111140] system 00:01: [mem 0xfed1c000-0xfed1ffff] has been 
reserved
[    0.111232] system 00:01: [mem 0xfed20000-0xfed8ffff] has been 
reserved
[    0.111325] system 00:01: [mem 0xff000000-0xffffffff] could not be 
reserved
[    0.111421] system 00:01: Plug and Play ACPI device, IDs PNP0c02 
(active)
[    0.111575] system 00:02: Plug and Play ACPI device, IDs PNP0c02 
(active)
[    0.111767] pnp 00:03: [dma 4]
[    0.111842] pnp 00:03: Plug and Play ACPI device, IDs PNP0200 
(active)
[    0.111951] pnp 00:04: Plug and Play ACPI device, IDs PNP0b00 
(active)
[    0.112035] pnp 00:05: Plug and Play ACPI device, IDs PNP0800 
(active)
[    0.112146] system 00:06: [io  0x04d0-0x04d1] has been reserved
[    0.112240] system 00:06: Plug and Play ACPI device, IDs PNP0c02 
(active)
[    0.112331] pnp 00:07: Plug and Play ACPI device, IDs PNP0c04 
(active)
[    0.112552] pnp 00:08: Plug and Play ACPI device, IDs PNP0103 
(active)
[    0.112696] pnp: PnP ACPI: found 9 devices
[    0.112782] ACPI: bus type PNP unregistered
[    0.152414] pci 0000:00:1c.0: bridge window [io  0x1000-0x0fff] to 
[bus 02] add_size 1000
[    0.152418] pci 0000:00:1c.0: bridge window [mem 
0x00100000-0x000fffff 64bit pref] to [bus 02] add_size 200000
[    0.152421] pci 0000:00:1c.0: bridge window [mem 
0x00100000-0x000fffff] to [bus 02] add_size 200000
[    0.152431] pci 0000:00:1c.1: bridge window [mem 
0x00100000-0x000fffff 64bit pref] to [bus 03] add_size 200000
[    0.152444] pci 0000:00:1c.0: res[8]=[mem 0x00100000-0x000fffff] 
get_res_add_size add_size 200000
[    0.152447] pci 0000:00:1c.0: res[9]=[mem 0x00100000-0x000fffff 64bit 
pref] get_res_add_size add_size 200000
[    0.152449] pci 0000:00:1c.1: res[9]=[mem 0x00100000-0x000fffff 64bit 
pref] get_res_add_size add_size 200000
[    0.152452] pci 0000:00:1c.0: res[7]=[io  0x1000-0x0fff] 
get_res_add_size add_size 1000
[    0.152457] pci 0000:00:1c.0: BAR 8: assigned [mem 
0xd0600000-0xd07fffff]
[    0.152553] pci 0000:00:1c.0: BAR 9: assigned [mem 
0xd0800000-0xd09fffff 64bit pref]
[    0.152708] pci 0000:00:1c.1: BAR 9: assigned [mem 
0xd0a00000-0xd0bfffff 64bit pref]
[    0.152864] pci 0000:00:1c.0: BAR 7: assigned [io  0x1000-0x1fff]
[    0.152956] pci 0000:00:01.0: PCI bridge to [bus 01]
[    0.153061] pci 0000:00:1c.0: PCI bridge to [bus 02]
[    0.153152] pci 0000:00:1c.0:   bridge window [io  0x1000-0x1fff]
[    0.153246] pci 0000:00:1c.0:   bridge window [mem 
0xd0600000-0xd07fffff]
[    0.153342] pci 0000:00:1c.0:   bridge window [mem 
0xd0800000-0xd09fffff 64bit pref]
[    0.153501] pci 0000:00:1c.1: PCI bridge to [bus 03]
[    0.153591] pci 0000:00:1c.1:   bridge window [io  0xe000-0xefff]
[    0.153685] pci 0000:00:1c.1:   bridge window [mem 
0xd0400000-0xd04fffff]
[    0.153780] pci 0000:00:1c.1:   bridge window [mem 
0xd0a00000-0xd0bfffff 64bit pref]
[    0.153936] pci 0000:00:1e.0: PCI bridge to [bus 04]
[    0.154146] pci 0000:00:1e.0: setting latency timer to 64
[    0.154151] pci_bus 0000:00: resource 4 [io  0x0000-0x0cf7]
[    0.154153] pci_bus 0000:00: resource 5 [io  0x0d00-0xffff]
[    0.154155] pci_bus 0000:00: resource 6 [mem 0x000a0000-0x000bffff]
[    0.154158] pci_bus 0000:00: resource 7 [mem 0xc0000000-0xffffffff]
[    0.154160] pci_bus 0000:02: resource 0 [io  0x1000-0x1fff]
[    0.154162] pci_bus 0000:02: resource 1 [mem 0xd0600000-0xd07fffff]
[    0.154165] pci_bus 0000:02: resource 2 [mem 0xd0800000-0xd09fffff 
64bit pref]
[    0.154167] pci_bus 0000:03: resource 0 [io  0xe000-0xefff]
[    0.154169] pci_bus 0000:03: resource 1 [mem 0xd0400000-0xd04fffff]
[    0.154172] pci_bus 0000:03: resource 2 [mem 0xd0a00000-0xd0bfffff 
64bit pref]
[    0.154174] pci_bus 0000:04: resource 4 [io  0x0000-0x0cf7]
[    0.154177] pci_bus 0000:04: resource 5 [io  0x0d00-0xffff]
[    0.154179] pci_bus 0000:04: resource 6 [mem 0x000a0000-0x000bffff]
[    0.154181] pci_bus 0000:04: resource 7 [mem 0xc0000000-0xffffffff]
[    0.154230] NET: Registered protocol family 2
[    0.154570] TCP established hash table entries: 8192 (order: 4, 65536 
bytes)
[    0.154706] TCP bind hash table entries: 8192 (order: 6, 294912 
bytes)
[    0.155317] TCP: Hash tables configured (established 8192 bind 8192)
[    0.155445] TCP: reno registered
[    0.155532] UDP hash table entries: 512 (order: 3, 40960 bytes)
[    0.155690] UDP-Lite hash table entries: 512 (order: 3, 40960 bytes)
[    0.155956] NET: Registered protocol family 1
[    0.156066] pci 0000:00:02.0: Boot video device
[    0.179114] PCI: CLS 64 bytes, default 64
[    0.324437] bounce pool size: 64 pages
[    0.324442] HugeTLB registered 2 MB page size, pre-allocated 0 pages
[    0.330553] squashfs: version 4.0 (2009/01/31) Phillip Lougher
[    0.330838] msgmni has been set to 1629
[    0.331481] Block layer SCSI generic (bsg) driver version 0.4 loaded 
(major 252)
[    0.331645] io scheduler noop registered
[    0.331803] io scheduler cfq registered (default)
[    0.333113] pcieport 0000:00:01.0: irq 40 for MSI/MSI-X
[    0.333405] pcieport 0000:00:1c.0: irq 41 for MSI/MSI-X
[    0.333687] pcieport 0000:00:1c.1: irq 42 for MSI/MSI-X
[    0.334077] pcieport 0000:00:01.0: Signaling PME through PCIe PME 
interrupt
[    0.334177] pcie_pme 0000:00:01.0:pcie01: service driver pcie_pme 
loaded
[    0.334209] pcieport 0000:00:1c.0: Signaling PME through PCIe PME 
interrupt
[    0.334304] pcie_pme 0000:00:1c.0:pcie01: service driver pcie_pme 
loaded
[    0.334334] pcieport 0000:00:1c.1: Signaling PME through PCIe PME 
interrupt
[    0.334427] pci 0000:03:00.0: Signaling PME through PCIe PME 
interrupt
[    0.334522] pcie_pme 0000:00:1c.1:pcie01: service driver pcie_pme 
loaded
[    0.334571] intel_idle: does not run on family 6 model 23
[    0.365880] SCSI Media Changer driver v0.25
[    0.366212] ata_piix 0000:00:1f.1: version 2.13
[    0.366330] ata_piix 0000:00:1f.1: setting latency timer to 64
[    0.368118] scsi0 : ata_piix
[    0.368760] scsi1 : ata_piix
[    0.369274] ata1: PATA max UDMA/100 cmd 0x1f0 ctl 0x3f6 bmdma 0xf0f0 
irq 14
[    0.369367] ata2: PATA max UDMA/100 cmd 0x170 ctl 0x376 bmdma 0xf0f8 
irq 15
[    0.369520] ata_piix 0000:00:1f.2: MAP [
[    0.369610]  P0 P2 P1 P3 ]
[    0.369646] ata_piix 0000:00:1f.2: setting latency timer to 64
[    0.369691] ata2: port disabled--ignoring
[    0.370640] scsi2 : ata_piix
[    0.371125] scsi3 : ata_piix
[    0.371567] ata3: SATA max UDMA/133 cmd 0xf0e0 ctl 0xf0d0 bmdma 
0xf0a0 irq 19
[    0.371661] ata4: SATA max UDMA/133 cmd 0xf0c0 ctl 0xf0b0 bmdma 
0xf0a8 irq 19
[    0.371920] PPP generic driver version 2.4.2
[    0.372166] NET: Registered protocol family 24
[    0.372269] ehci_hcd: USB 2.0 'Enhanced' Host Controller (EHCI) 
Driver
[    0.372360] ehci-pci: EHCI PCI platform driver
[    0.372500] ehci-pci 0000:00:1d.7: setting latency timer to 64
[    0.372504] ehci-pci 0000:00:1d.7: EHCI Host Controller
[    0.372689] ehci-pci 0000:00:1d.7: new USB bus registered, assigned 
bus number 1
[    0.372853] ehci-pci 0000:00:1d.7: debug port 1
[    0.377014] ehci-pci 0000:00:1d.7: cache line size of 64 is not 
supported
[    0.377038] ehci-pci 0000:00:1d.7: irq 23, io mem 0xd0500000
[    0.383034] ehci-pci 0000:00:1d.7: USB 2.0 started, EHCI 1.00
[    0.383292] usb usb1: New USB device found, idVendor=1d6b, 
idProduct=0002
[    0.383385] usb usb1: New USB device strings: Mfr=3, Product=2, 
SerialNumber=1
[    0.383536] usb usb1: Product: EHCI Host Controller
[    0.383623] usb usb1: Manufacturer: Linux 3.9.2-build-0063 ehci_hcd
[    0.383714] usb usb1: SerialNumber: 0000:00:1d.7
[    0.384328] hub 1-0:1.0: USB hub found
[    0.384440] hub 1-0:1.0: 8 ports detected
[    0.385222] ohci_hcd: USB 1.1 'Open' Host Controller (OHCI) Driver
[    0.385370] uhci_hcd: USB Universal Host Controller Interface driver
[    0.385514] uhci_hcd 0000:00:1d.0: setting latency timer to 64
[    0.385517] uhci_hcd 0000:00:1d.0: UHCI Host Controller
[    0.385612] uhci_hcd 0000:00:1d.0: new USB bus registered, assigned 
bus number 2
[    0.385786] uhci_hcd 0000:00:1d.0: irq 23, io base 0x0000f080
[    0.385974] usb usb2: New USB device found, idVendor=1d6b, 
idProduct=0001
[    0.386082] usb usb2: New USB device strings: Mfr=3, Product=2, 
SerialNumber=1
[    0.386233] usb usb2: Product: UHCI Host Controller
[    0.386321] usb usb2: Manufacturer: Linux 3.9.2-build-0063 uhci_hcd
[    0.386412] usb usb2: SerialNumber: 0000:00:1d.0
[    0.386696] hub 2-0:1.0: USB hub found
[    0.386788] hub 2-0:1.0: 2 ports detected
[    0.387071] uhci_hcd 0000:00:1d.1: setting latency timer to 64
[    0.387074] uhci_hcd 0000:00:1d.1: UHCI Host Controller
[    0.387169] uhci_hcd 0000:00:1d.1: new USB bus registered, assigned 
bus number 3
[    0.387342] uhci_hcd 0000:00:1d.1: irq 19, io base 0x0000f060
[    0.387519] usb usb3: New USB device found, idVendor=1d6b, 
idProduct=0001
[    0.387612] usb usb3: New USB device strings: Mfr=3, Product=2, 
SerialNumber=1
[    0.387763] usb usb3: Product: UHCI Host Controller
[    0.387851] usb usb3: Manufacturer: Linux 3.9.2-build-0063 uhci_hcd
[    0.387941] usb usb3: SerialNumber: 0000:00:1d.1
[    0.388237] hub 3-0:1.0: USB hub found
[    0.388327] hub 3-0:1.0: 2 ports detected
[    0.388586] uhci_hcd 0000:00:1d.2: setting latency timer to 64
[    0.388590] uhci_hcd 0000:00:1d.2: UHCI Host Controller
[    0.388685] uhci_hcd 0000:00:1d.2: new USB bus registered, assigned 
bus number 4
[    0.388872] uhci_hcd 0000:00:1d.2: irq 18, io base 0x0000f040
[    0.389047] usb usb4: New USB device found, idVendor=1d6b, 
idProduct=0001
[    0.389140] usb usb4: New USB device strings: Mfr=3, Product=2, 
SerialNumber=1
[    0.389290] usb usb4: Product: UHCI Host Controller
[    0.389378] usb usb4: Manufacturer: Linux 3.9.2-build-0063 uhci_hcd
[    0.389469] usb usb4: SerialNumber: 0000:00:1d.2
[    0.389757] hub 4-0:1.0: USB hub found
[    0.389846] hub 4-0:1.0: 2 ports detected
[    0.390126] uhci_hcd 0000:00:1d.3: setting latency timer to 64
[    0.390130] uhci_hcd 0000:00:1d.3: UHCI Host Controller
[    0.390225] uhci_hcd 0000:00:1d.3: new USB bus registered, assigned 
bus number 5
[    0.390411] uhci_hcd 0000:00:1d.3: irq 16, io base 0x0000f020
[    0.390577] usb usb5: New USB device found, idVendor=1d6b, 
idProduct=0001
[    0.390670] usb usb5: New USB device strings: Mfr=3, Product=2, 
SerialNumber=1
[    0.390821] usb usb5: Product: UHCI Host Controller
[    0.390909] usb usb5: Manufacturer: Linux 3.9.2-build-0063 uhci_hcd
[    0.390999] usb usb5: SerialNumber: 0000:00:1d.3
[    0.391308] hub 5-0:1.0: USB hub found
[    0.391398] hub 5-0:1.0: 2 ports detected
[    0.391734] Initializing USB Mass Storage driver...
[    0.391889] usbcore: registered new interface driver usb-storage
[    0.391980] USB Mass Storage support registered.
[    0.392137] usbcore: registered new interface driver ums-alauda
[    0.392279] usbcore: registered new interface driver ums-cypress
[    0.392421] usbcore: registered new interface driver ums-datafab
[    0.392561] usbcore: registered new interface driver ums_eneub6250
[    0.392703] usbcore: registered new interface driver ums-freecom
[    0.392844] usbcore: registered new interface driver ums-isd200
[    0.392987] usbcore: registered new interface driver ums-jumpshot
[    0.393138] usbcore: registered new interface driver ums-karma
[    0.393279] usbcore: registered new interface driver ums-onetouch
[    0.393424] usbcore: registered new interface driver ums-realtek
[    0.393565] usbcore: registered new interface driver ums-sddr09
[    0.393707] usbcore: registered new interface driver ums-sddr55
[    0.393848] usbcore: registered new interface driver ums-usbat
[    0.394235] i8042: PNP: No PS/2 controller found. Probing ports 
directly.
[    0.397393] serio: i8042 KBD port at 0x60,0x64 irq 1
[    0.397515] serio: i8042 AUX port at 0x60,0x64 irq 12
[    0.397916] mousedev: PS/2 mouse device common for all mice
[    0.398313] input: PC Speaker as 
/devices/platform/pcspkr/input/input0
[    0.398515] rtc_cmos 00:04: RTC can wake from S4
[    0.398854] rtc_cmos 00:04: rtc core: registered rtc_cmos as rtc0
[    0.398974] rtc_cmos 00:04: alarms up to one month, y3k, 114 bytes 
nvram, hpet irqs
[    0.399331] device-mapper: uevent: version 1.0.3
[    0.399582] device-mapper: ioctl: 4.24.0-ioctl (2013-01-15) 
initialised: dm-devel@redhat.com
[    0.399756] cpuidle: using governor ladder
[    0.399842] cpuidle: using governor menu
[    0.400176] ip_tables: (C) 2000-2006 Netfilter Core Team
[    0.400266] TCP: cubic registered
[    0.400350] NET: Registered protocol family 17
[    0.400726] Using IPI No-Shortcut mode
[    0.401028] registered taskstats version 1
[    0.543749] Freeing unused kernel memory: 34948k freed
[    0.737036] usb 1-7: new high-speed USB device number 3 using 
ehci-pci
[    0.851922] usb 1-7: New USB device found, idVendor=1e3d, 
idProduct=2092
[    0.852038] usb 1-7: New USB device strings: Mfr=1, Product=2, 
SerialNumber=3
[    0.852139] usb 1-7: Product: Flash Disk
[    0.852232] usb 1-7: Manufacturer: CBM
[    0.852322] usb 1-7: SerialNumber: 130211007AC1A803
[    0.861259] scsi4 : usb-storage 1-7:1.0
[    1.185038] usb 4-1: new low-speed USB device number 2 using uhci_hcd
[    1.324097] tsc: Refined TSC clocksource calibration: 2933.286 MHz
[    1.324211] Switching to clocksource tsc
[    1.331046] usb 4-1: New USB device found, idVendor=04f3, 
idProduct=0103
[    1.331141] usb 4-1: New USB device strings: Mfr=0, Product=0, 
SerialNumber=0
[    1.733802] input: HID 04f3:0103 as 
/devices/pci0000:00/0000:00:1d.2/usb4/4-1/4-1:1.0/input/input1
[    1.734131] hid-generic 0003:04F3:0103.0001: input: USB HID v1.10 
Keyboard [HID 04f3:0103] on usb-0000:00:1d.2-1/input0
[    1.759324] input: HID 04f3:0103 as 
/devices/pci0000:00/0000:00:1d.2/usb4/4-1/4-1:1.1/input/input2
[    1.759493] hid-generic 0003:04F3:0103.0002: input: USB HID v1.10 
Device [HID 04f3:0103] on usb-0000:00:1d.2-1/input1
[    1.759766] usbcore: registered new interface driver usbhid
[    1.759857] usbhid: USB HID core driver
[    1.761449] e100: Intel(R) PRO/100 Network Driver, 3.5.24-k2-NAPI
[    1.761542] e100: Copyright(c) 1999-2006 Intel Corporation
[    1.763737] e1000: Intel(R) PRO/1000 Network Driver - version 
7.3.21-k8-NAPI
[    1.763893] e1000: Copyright (c) 1999-2006 Intel Corporation.
[    1.765712] pps_core: LinuxPPS API ver. 1 registered
[    1.765802] pps_core: Software ver. 5.3.6 - Copyright 2005-2007 
Rodolfo Giometti <giometti@linux.it>
[    1.766917] PTP clock support registered
[    1.767662] e1000e: Intel(R) PRO/1000 Network Driver - 2.2.14-k
[    1.767755] e1000e: Copyright(c) 1999 - 2013 Intel Corporation.
[    1.769954] 8139too: 8139too Fast Ethernet driver 0.9.28
[    1.771796] 8139cp: 8139cp: 10/100 PCI Ethernet driver v1.3 (Mar 22, 
2004)
[    1.779979] ne2k-pci.c:v1.03 9/22/2003 D. Becker/P. Gortmaker
[    1.782127] sis900.c: v1.08.10 Apr. 2 2006
[    1.783983] via_rhine: v1.10-LK1.5.0 2010-10-09 Written by Donald 
Becker
[    1.788215] sky2: driver version 1.30
[    1.790208] r8169 Gigabit Ethernet driver 2.3LK-NAPI loaded
[    1.790540] r8169 0000:03:00.0: irq 43 for MSI/MSI-X
[    1.791638] r8169 0000:03:00.0 eth0: RTL8168d/8111d at 0xf85d8000, 
00:27:0e:27:32:41, XID 081000c0 IRQ 43
[    1.791800] r8169 0000:03:00.0 eth0: jumbo features [frames: 9200 
bytes, tx checksumming: ko]
[    1.793757] tulip: Linux Tulip driver version 1.1.15-NAPI (Feb 27, 
2007)
[    1.877344] scsi 4:0:0:0: Direct-Access     CBM      Flash Disk       
5.00 PQ: 0 ANSI: 2
[    1.879181] sd 4:0:0:0: [sda] 8008704 512-byte logical blocks: (4.10 
GB/3.81 GiB)
[    1.879465] sd 4:0:0:0: Attached scsi generic sg0 type 0
[    1.879931] sd 4:0:0:0: [sda] Write Protect is off
[    1.880033] sd 4:0:0:0: [sda] Mode Sense: 0b 00 00 08
[    1.880678] sd 4:0:0:0: [sda] No Caching mode page present
[    1.880773] sd 4:0:0:0: [sda] Assuming drive cache: write through
[    1.884191] sd 4:0:0:0: [sda] No Caching mode page present
[    1.884291] sd 4:0:0:0: [sda] Assuming drive cache: write through
[    1.885122]  sda: sda1 sda2
[    1.888816] sd 4:0:0:0: [sda] No Caching mode page present
[    1.888916] sd 4:0:0:0: [sda] Assuming drive cache: write through
[    1.889038] sd 4:0:0:0: [sda] Attached SCSI removable disk
[   17.967469] bio: create slab <bio-1> at 1
[   17.970814] EXT4-fs (dm-0): mounting ext3 file system using the ext4 
subsystem
[   18.024498] EXT4-fs (dm-0): recovery complete
[   18.026861] EXT4-fs (dm-0): mounted filesystem with ordered data 
mode. Opts: (null)
[   18.408451] loop: module loaded
[   18.448675] 8021q: 802.1Q VLAN Support v1.8
[   18.675357] r8169 0000:03:00.0 eth0: link down
[   18.675492] r8169 0000:03:00.0 eth0: link down
[   18.849611] nf_conntrack version 0.5.0 (16384 buckets, 65536 max)
[   19.173272] Mirror/redirect action on
[   19.215985] u32 classifier
[   19.216091]     Performance counters on
[   19.216179]     input device check on
[   19.216264]     Actions configured
[   19.735062]

Here i am trying to remove module

[   19.735147] =================================
[   19.735235] [ INFO: inconsistent lock state ]
[   19.735324] 3.9.2-build-0063 #4 Not tainted
[   19.735412] ---------------------------------
[   19.735500] inconsistent {IN-SOFTIRQ-W} -> {SOFTIRQ-ON-W} usage.
[   19.735592] rmmod/1840 [HC0[0]:SC0[0]:HE1:SE1] takes:
[   19.735682]  (&(&app->lock)->rlock#2){+.?...}, at: [<f862bb5b>] 
mrp_uninit_applicant+0x69/0xba [mrp]
[   19.735932] {IN-SOFTIRQ-W} state was registered at:
[   19.736002]   [<c01611d8>] __lock_acquire+0x284/0xd52
[   19.736002]   [<c0162068>] lock_acquire+0x71/0x85
[   19.736002]   [<c03e4ad5>] _raw_spin_lock+0x33/0x40
[   19.736002]   [<f862b5dc>] mrp_join_timer+0x11/0x3d [mrp]
[   19.736002]   [<c0136102>] call_timer_fn+0x69/0xdc
[   19.736002]   [<c01362e6>] run_timer_softirq+0x171/0x1ab
[   19.736002]   [<c0131963>] __do_softirq+0x98/0x153
[   19.736002]   [<c0131afa>] irq_exit+0x47/0x82
[   19.736002]   [<c011c274>] smp_apic_timer_interrupt+0x64/0x71
[   19.736002]   [<c03e5616>] apic_timer_interrupt+0x32/0x38
[   19.736002]   [<c010902c>] cpu_idle+0x55/0x6f
[   19.736002]   [<c03d7d19>] rest_init+0xa1/0xa7
[   19.736002]   [<c057792f>] start_kernel+0x300/0x307
[   19.736002]   [<c05772a3>] i386_start_kernel+0x79/0x7d
[   19.736002] irq event stamp: 4379
[   19.736002] hardirqs last  enabled at (4379): [<c03e50bb>] 
_raw_spin_unlock_irqrestore+0x36/0x3c
[   19.736002] hardirqs last disabled at (4378): [<c03e4b92>] 
_raw_spin_lock_irqsave+0x16/0x50
[   19.736002] softirqs last  enabled at (4342): [<c0379c22>] 
neigh_ifdown+0x95/0xb5
[   19.736002] softirqs last disabled at (4340): [<c03e4cc9>] 
_raw_write_lock_bh+0xe/0x45
[   19.736002]
[   19.736002] other info that might help us debug this:
[   19.736002]  Possible unsafe locking scenario:
[   19.736002]
[   19.736002]        CPU0
[   19.736002]        ----
[   19.736002]   lock(&(&app->lock)->rlock#2);
[   19.736002]   <Interrupt>
[   19.736002]     lock(&(&app->lock)->rlock#2);
[   19.736002]
[   19.736002]  *** DEADLOCK ***
[   19.736002]
[   19.736002] 3 locks held by rmmod/1840:
[   19.736002]  #0:  (&__lockdep_no_validate__){......}, at: 
[<c02c195c>] device_lock+0xd/0xf
[   19.736002]  #1:  (&__lockdep_no_validate__){......}, at: 
[<c02c195c>] device_lock+0xd/0xf
[   19.736002]  #2:  (rtnl_mutex){+.+.+.}, at: [<c037d71b>] 
rtnl_lock+0xf/0x11
[   19.736002]
[   19.736002] stack backtrace:
[   19.736002] Pid: 1840, comm: rmmod Not tainted 3.9.2-build-0063 #4
[   19.736002] Call Trace:
[   19.736002]  [<c0160d8e>] valid_state+0x1f6/0x201
[   19.736002]  [<c0160e6a>] mark_lock+0xd1/0x1bb
[   19.736002]  [<c01606b1>] ? check_usage_forwards+0x77/0x77
[   19.736002]  [<c016124c>] __lock_acquire+0x2f8/0xd52
[   19.736002]  [<c0160d00>] ? valid_state+0x168/0x201
[   19.736002]  [<c0160dbf>] ? mark_lock+0x26/0x1bb
[   19.736002]  [<c016230e>] ? mark_held_locks+0x5d/0x7b
[   19.736002]  [<c03e50bb>] ? _raw_spin_unlock_irqrestore+0x36/0x3c
[   19.736002]  [<c0162068>] lock_acquire+0x71/0x85
[   19.736002]  [<f862bb5b>] ? mrp_uninit_applicant+0x69/0xba [mrp]
[   19.736002]  [<c03e4ad5>] _raw_spin_lock+0x33/0x40
[   19.736002]  [<f862bb5b>] ? mrp_uninit_applicant+0x69/0xba [mrp]
[   19.736002]  [<f862bb5b>] mrp_uninit_applicant+0x69/0xba [mrp]
[   19.736002]  [<c0172e67>] ? kfree_call_rcu+0x17/0x19
[   19.736002]  [<f8647bf6>] vlan_mvrp_uninit_applicant+0xd/0xf [8021q]
[   19.736002]  [<f8646198>] unregister_vlan_dev+0xb8/0xe2 [8021q]
[   19.736002]  [<c03d1ae8>] ? packet_mm_close+0x1f/0x1f
[   19.736002]  [<f86464c9>] vlan_device_event+0x307/0x35a [8021q]
[   19.736002]  [<c03d1ce7>] ? rcu_read_unlock+0x17/0x19
[   19.736002]  [<c0146215>] notifier_call_chain+0x26/0x48
[   19.736002]  [<c0146283>] raw_notifier_call_chain+0x1a/0x1c
[   19.736002]  [<c0370310>] call_netdevice_notifiers+0x44/0x4b
[   19.736002]  [<c0370604>] rollback_registered_many+0xe2/0x185
[   19.736002]  [<c037070d>] rollback_registered+0x1f/0x2c
[   19.736002]  [<c0370777>] unregister_netdevice_queue+0x5d/0x87
[   19.736002]  [<c03e3464>] ? mutex_lock_nested+0x20/0x22
[   19.736002]  [<c037d71b>] ? rtnl_lock+0xf/0x11
[   19.736002]  [<c0370851>] unregister_netdev+0x18/0x1f
[   19.736002]  [<f85cb017>] rtl_remove_one+0x7f/0xf9 [r8169]
[   19.736002]  [<c02c9117>] ? __pm_runtime_resume+0x48/0x50
[   19.736002]  [<c026cea9>] pci_device_remove+0x27/0x76
[   19.736002]  [<c02c1b70>] __device_release_driver+0x66/0xaa
[   19.736002]  [<c02c20a3>] driver_detach+0x62/0x83
[   19.736002]  [<c02c1919>] bus_remove_driver+0x69/0x88
[   19.736002]  [<c02c23be>] driver_unregister+0x53/0x5a
[   19.736002]  [<c016243a>] ? trace_hardirqs_on_caller+0x10e/0x13f
[   19.736002]  [<c026cf87>] pci_unregister_driver+0x10/0x5a
[   19.736002]  [<f85cd8fb>] rtl8169_pci_driver_exit+0xd/0xf [r8169]
[   19.736002]  [<c01688cf>] sys_delete_module+0x175/0x1c1
[   19.736002]  [<c03e5367>] ? restore_all+0xf/0xf
[   19.736002]  [<c03e5334>] syscall_call+0x7/0xb

here i load it with debug=16 parameter

[   19.769100] r8169 0000:03:00.0: irq 43 for MSI/MSI-X
[   19.769998] r8169 0000:03:00.0 eth0: RTL8168d/8111d at 0xf8afe000, 
00:27:0e:27:32:41, XID 081000c0 IRQ 43
[   19.770168] r8169 0000:03:00.0 eth0: jumbo features [frames: 9200 
bytes, tx checksumming: ko]
[   19.845299] r8169 0000:03:00.0 eth0: link down
[   21.404853] r8169 0000:03:00.0 eth0: link up
Here i am trying to run udhcpc for DHCP.

[   75.712006] ------------[ cut here ]------------
[   75.712112] WARNING: at net/sched/sch_generic.c:255 
dev_watchdog+0xcd/0x121()
[   75.712204] Hardware name:
[   75.712289] NETDEV WATCHDOG: eth0 (r8169): transmit queue 0 timed out
[   75.712379] Modules linked in: r8169 nf_nat_pptp nf_nat_proto_gre 
nf_conntrack_pptp nf_conntrack_proto_gre cls_flow cls_u32 em_meta 
cls_basic xt_dscp xt_hl ifb cls_fw sch_tbf sch_htb act_ipt act_mirred 
xt_nat xt_REDIRECT ipt_REJECT xt_TCPMSS ts_bm xt_string xt_connmark 
xt_DSCP xt_mark iptable_mangle iptable_nat nf_conntrack_ipv4 
nf_defrag_ipv4 nf_nat_ipv4 nf_nat nf_conntrack iptable_filter 8021q garp 
stp mrp llc loop tulip sky2 via_velocity via_rhine sis900 ne2k_pci 8390 
skge libphy 8139cp 8139too e1000e ptp pps_core e1000 e100 usbhid [last 
unloaded: r8169]
[   75.714043] Pid: 0, comm: swapper/0 Not tainted 3.9.2-build-0063 #4
[   75.714133] Call Trace:
[   75.714218]  [<c012bee5>] warn_slowpath_common+0x77/0x8e
[   75.714308]  [<c0385261>] ? dev_watchdog+0xcd/0x121
[   75.714396]  [<c0385261>] ? dev_watchdog+0xcd/0x121
[   75.714484]  [<c012bf78>] warn_slowpath_fmt+0x2e/0x30
[   75.714573]  [<c0385261>] dev_watchdog+0xcd/0x121
[   75.714662]  [<c0136102>] call_timer_fn+0x69/0xdc
[   75.714749]  [<c0136099>] ? cascade+0x5c/0x5c
[   75.714837]  [<c015ee03>] ? arch_local_irq_save+0x8/0xb
[   75.714926]  [<c0385194>] ? netif_tx_unlock+0x41/0x41
[   75.715018]  [<c01362e6>] run_timer_softirq+0x171/0x1ab
[   75.715108]  [<c011bcb5>] ? lapic_next_event+0xf/0x13
[   75.715196]  [<c0385194>] ? netif_tx_unlock+0x41/0x41
[   75.715286]  [<c0131963>] __do_softirq+0x98/0x153
[   75.715373]  [<c0131afa>] irq_exit+0x47/0x82
[   75.715460]  [<c011c274>] smp_apic_timer_interrupt+0x64/0x71
[   75.715552]  [<c025a464>] ? trace_hardirqs_off_thunk+0xc/0x10
[   75.715643]  [<c03e5616>] apic_timer_interrupt+0x32/0x38
[   75.715733]  [<c0108a67>] ? default_idle+0x21/0x38
[   75.715821]  [<c0108a69>] ? default_idle+0x23/0x38
[   75.715909]  [<c010902c>] cpu_idle+0x55/0x6f
[   75.715997]  [<c03d7d19>] rest_init+0xa1/0xa7
[   75.716086]  [<c03d7c78>] ? __read_lock_failed+0x14/0x14
[   75.716177]  [<c057792f>] start_kernel+0x300/0x307
[   75.716265]  [<c05773f6>] ? repair_env_string+0x51/0x51
[   75.716355]  [<c05772a3>] i386_start_kernel+0x79/0x7d
[   75.716442] ---[ end trace 7b25d1f43686b021 ]---
It obtains ip, but next DHCP packet will not go, and no network 
communication possible.
[   75.721265] r8169 0000:03:00.0 eth0: link up
[   81.717262] r8169 0000:03:00.0 eth0: link up
[   87.717258] r8169 0000:03:00.0 eth0: link up
[   93.717261] r8169 0000:03:00.0 eth0: link up

---
Denys Fedoryshchenko, Network Engineer, Virtual ISP S.A.L.
