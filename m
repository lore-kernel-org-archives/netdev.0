From: assirati@nonada.if.usp.br
Subject: Wake on lan with RTL8111/8168B
Date: Wed, 6 Feb 2013 02:49:00 -0200
Message-ID: <e9c426461bfd4b2dad85d2feaf830a22.squirrel@nonada.if.usp.br>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
Cc: assirati@nonada.if.usp.br
To: nic_swsd@realtek.com, romieu@fr.zoreil.com, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from nonada.if.usp.br ([143.107.132.119]:38755 "EHLO
	nonada.if.usp.br" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755163Ab3BFE6r (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Feb 2013 23:58:47 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello,

I have an Asus P8Z77-M motherboard which has the following onboard NIC, as
reported by lspci:

03:00.0 Ethernet controller: Realtek Semiconductor Co., Ltd. RTL8111/8168B
PCI Express Gigabit Ethernet controller (rev 09). This is a 10ec:8168.

I am trying to enable wake on lan but I am having a curious behavior:

1. At the first boot, the system receives the magic packet and boots as
expected.

2. When the system boots, I issue  'ethtool -s eth0 wol g' and then
'shutdown -h now'.

3. Instead of halting, the machine reboots. When the boot is complete, I
issue 'ethtool -s eth0 wol g' and then 'shutdown -h now' again, and this
time the system halts.

4. After that, I can again wake the system with a magic packet, and
everything repeats again.

That is, the system is alternately halting and rebooting under 'shutdown
-h now'. When it halts, I can wake it normaly through a magic packet.

I am using a stock Debian kernel 3.7.3. The output of dmesg is given below.

I would like very much that wol work in this machine. I can apply paches
and compile kernels to help debugging.

I am not subscribed to the mailing list, so please send e-mails directly
to me. If this is not acceptable, I can subscribe to the mailing list.

Thank you very much,
Joao Luis.


[    0.000000] Initializing cgroup subsys cpuset
[    0.000000] Initializing cgroup subsys cpu
[    0.000000] Linux version 3.7-trunk-amd64
(debian-kernel@lists.debian.org) (gcc version 4.7.2 (Debian 4.7.2-5) ) #1
SMP Debian 3.7.3-1~experimental.1
[    0.000000] Command line: BOOT_IMAGE=/vmlinuz-3.7-trunk-amd64
root=/dev/mapper/glaukopis-root ro quiet
[    0.000000] e820: BIOS-provided physical RAM map:
[    0.000000] BIOS-e820: [mem 0x0000000000000000-0x000000000009d7ff] usable
[    0.000000] BIOS-e820: [mem 0x000000000009d800-0x000000000009ffff]
reserved
[    0.000000] BIOS-e820: [mem 0x00000000000e0000-0x00000000000fffff]
reserved
[    0.000000] BIOS-e820: [mem 0x0000000000100000-0x000000001fffffff] usable
[    0.000000] BIOS-e820: [mem 0x0000000020000000-0x00000000201fffff]
reserved
[    0.000000] BIOS-e820: [mem 0x0000000020200000-0x0000000040003fff] usable
[    0.000000] BIOS-e820: [mem 0x0000000040004000-0x0000000040004fff]
reserved
[    0.000000] BIOS-e820: [mem 0x0000000040005000-0x00000000cc652fff] usable
[    0.000000] BIOS-e820: [mem 0x00000000cc653000-0x00000000ccad5fff]
reserved
[    0.000000] BIOS-e820: [mem 0x00000000ccad6000-0x00000000ccae5fff] ACPI
data
[    0.000000] BIOS-e820: [mem 0x00000000ccae6000-0x00000000ccc0dfff] ACPI
NVS
[    0.000000] BIOS-e820: [mem 0x00000000ccc0e000-0x00000000cd80dfff]
reserved
[    0.000000] BIOS-e820: [mem 0x00000000cd80e000-0x00000000cd80efff] usable
[    0.000000] BIOS-e820: [mem 0x00000000cd80f000-0x00000000cd851fff] ACPI
NVS
[    0.000000] BIOS-e820: [mem 0x00000000cd852000-0x00000000cdc77fff] usable
[    0.000000] BIOS-e820: [mem 0x00000000cdc78000-0x00000000cdff3fff]
reserved
[    0.000000] BIOS-e820: [mem 0x00000000cdff4000-0x00000000cdffffff] usable
[    0.000000] BIOS-e820: [mem 0x00000000cf000000-0x00000000df1fffff]
reserved
[    0.000000] BIOS-e820: [mem 0x00000000f8000000-0x00000000fbffffff]
reserved
[    0.000000] BIOS-e820: [mem 0x00000000fec00000-0x00000000fec00fff]
reserved
[    0.000000] BIOS-e820: [mem 0x00000000fed00000-0x00000000fed03fff]
reserved
[    0.000000] BIOS-e820: [mem 0x00000000fed1c000-0x00000000fed1ffff]
reserved
[    0.000000] BIOS-e820: [mem 0x00000000fee00000-0x00000000fee00fff]
reserved
[    0.000000] BIOS-e820: [mem 0x00000000ff000000-0x00000000ffffffff]
reserved
[    0.000000] BIOS-e820: [mem 0x0000000100000000-0x00000003feffffff] usable
[    0.000000] NX (Execute Disable) protection: active
[    0.000000] DMI 2.7 present.
[    0.000000] DMI: System manufacturer System Product Name/P8Z77-M, BIOS
1806 01/03/2013
[    0.000000] e820: update [mem 0x00000000-0x0000ffff] usable ==> reserved
[    0.000000] e820: remove [mem 0x000a0000-0x000fffff] usable
[    0.000000] No AGP bridge found
[    0.000000] e820: last_pfn = 0x3ff000 max_arch_pfn = 0x400000000
[    0.000000] MTRR default type: uncachable
[    0.000000] MTRR fixed ranges enabled:
[    0.000000]   00000-9FFFF write-back
[    0.000000]   A0000-BFFFF uncachable
[    0.000000]   C0000-CFFFF write-protect
[    0.000000]   D0000-E7FFF uncachable
[    0.000000]   E8000-FFFFF write-protect
[    0.000000] MTRR variable ranges enabled:
[    0.000000]   0 base 000000000 mask C00000000 write-back
[    0.000000]   1 base 0E0000000 mask FE0000000 uncachable
[    0.000000]   2 base 0D0000000 mask FF0000000 uncachable
[    0.000000]   3 base 0CF000000 mask FFF000000 uncachable
[    0.000000]   4 base 3FF000000 mask FFF000000 uncachable
[    0.000000]   5 disabled
[    0.000000]   6 disabled
[    0.000000]   7 disabled
[    0.000000]   8 disabled
[    0.000000]   9 disabled
[    0.000000] x86 PAT enabled: cpu 0, old 0x7040600070406, new
0x7010600070106
[    0.000000] e820: update [mem 0xcf000000-0xffffffff] usable ==> reserved
[    0.000000] e820: last_pfn = 0xce000 max_arch_pfn = 0x400000000
[    0.000000] found SMP MP-table at [mem 0x000fd810-0x000fd81f] mapped at
[ffff8800000fd810]
[    0.000000] initial memory mapped: [mem 0x00000000-0x1fffffff]
[    0.000000] Base memory trampoline at [ffff880000097000] 97000 size 24576
[    0.000000] init_memory_mapping: [mem 0x00000000-0xcdffffff]
[    0.000000]  [mem 0x00000000-0xcdffffff] page 2M
[    0.000000] kernel direct mapping tables up to 0xcdffffff @ [mem
0x1fffb000-0x1fffffff]
[    0.000000] init_memory_mapping: [mem 0x100000000-0x3feffffff]
[    0.000000]  [mem 0x100000000-0x3feffffff] page 2M
[    0.000000] kernel direct mapping tables up to 0x3feffffff @ [mem
0xcdc6b000-0xcdc77fff]
[    0.000000] RAMDISK: [mem 0x36904000-0x37479fff]
[    0.000000] ACPI: RSDP 00000000000f0490 00024 (v02 ALASKA)
[    0.000000] ACPI: XSDT 00000000ccad9078 0006C (v01 ALASKA    A M I
01072009 AMI  00010013)
[    0.000000] ACPI: FACP 00000000ccae4320 0010C (v05 ALASKA    A M I
01072009 AMI  00010013)
[    0.000000] ACPI: DSDT 00000000ccad9180 0B19E (v02 ALASKA    A M I
00000022 INTL 20051117)
[    0.000000] ACPI: FACS 00000000ccc0c080 00040
[    0.000000] ACPI: APIC 00000000ccae4430 00092 (v03 ALASKA    A M I
01072009 AMI  00010013)
[    0.000000] ACPI: FPDT 00000000ccae44c8 00044 (v01 ALASKA    A M I
01072009 AMI  00010013)
[    0.000000] ACPI: MCFG 00000000ccae4510 0003C (v01 ALASKA    A M I
01072009 MSFT 00000097)
[    0.000000] ACPI: HPET 00000000ccae4550 00038 (v01 ALASKA    A M I
01072009 AMI. 00000005)
[    0.000000] ACPI: SSDT 00000000ccae4588 0036D (v01 SataRe SataTabl
00001000 INTL 20091112)
[    0.000000] ACPI: DMAR 00000000ccae5d98 000B8 (v01 INTEL      SNB 
00000001 INTL 00000001)
[    0.000000] ACPI: SSDT 00000000ccae4950 009AA (v01  PmRef  Cpu0Ist
00003000 INTL 20051117)
[    0.000000] ACPI: SSDT 00000000ccae5300 00A92 (v01  PmRef    CpuPm
00003000 INTL 20051117)
[    0.000000] ACPI: Local APIC address 0xfee00000
[    0.000000] No NUMA configuration found
[    0.000000] Faking a node at [mem 0x0000000000000000-0x00000003feffffff]
[    0.000000] Initmem setup node 0 [mem 0x00000000-0x3feffffff]
[    0.000000]   NODE_DATA [mem 0x3feffc000-0x3feffffff]
[    0.000000]  [ffffea0000000000-ffffea000dffffff] PMD ->
[ffff8803ef200000-ffff8803fc7fffff] on node 0
[    0.000000] Zone ranges:
[    0.000000]   DMA      [mem 0x00010000-0x00ffffff]
[    0.000000]   DMA32    [mem 0x01000000-0xffffffff]
[    0.000000]   Normal   [mem 0x100000000-0x3feffffff]
[    0.000000] Movable zone start for each node
[    0.000000] Early memory node ranges
[    0.000000]   node   0: [mem 0x00010000-0x0009cfff]
[    0.000000]   node   0: [mem 0x00100000-0x1fffffff]
[    0.000000]   node   0: [mem 0x20200000-0x40003fff]
[    0.000000]   node   0: [mem 0x40005000-0xcc652fff]
[    0.000000]   node   0: [mem 0xcd80e000-0xcd80efff]
[    0.000000]   node   0: [mem 0xcd852000-0xcdc77fff]
[    0.000000]   node   0: [mem 0xcdff4000-0xcdffffff]
[    0.000000]   node   0: [mem 0x100000000-0x3feffffff]
[    0.000000] On node 0 totalpages: 3979282
[    0.000000]   DMA zone: 56 pages used for memmap
[    0.000000]   DMA zone: 6 pages reserved
[    0.000000]   DMA zone: 3919 pages, LIFO batch:0
[    0.000000]   DMA32 zone: 14280 pages used for memmap
[    0.000000]   DMA32 zone: 819389 pages, LIFO batch:31
[    0.000000]   Normal zone: 42952 pages used for memmap
[    0.000000]   Normal zone: 3098680 pages, LIFO batch:31
[    0.000000] ACPI: PM-Timer IO Port: 0x408
[    0.000000] ACPI: Local APIC address 0xfee00000
[    0.000000] ACPI: LAPIC (acpi_id[0x01] lapic_id[0x00] enabled)
[    0.000000] ACPI: LAPIC (acpi_id[0x02] lapic_id[0x02] enabled)
[    0.000000] ACPI: LAPIC (acpi_id[0x03] lapic_id[0x04] enabled)
[    0.000000] ACPI: LAPIC (acpi_id[0x04] lapic_id[0x06] enabled)
[    0.000000] ACPI: LAPIC (acpi_id[0x05] lapic_id[0x01] enabled)
[    0.000000] ACPI: LAPIC (acpi_id[0x06] lapic_id[0x03] enabled)
[    0.000000] ACPI: LAPIC (acpi_id[0x07] lapic_id[0x05] enabled)
[    0.000000] ACPI: LAPIC (acpi_id[0x08] lapic_id[0x07] enabled)
[    0.000000] ACPI: LAPIC_NMI (acpi_id[0xff] high edge lint[0x1])
[    0.000000] ACPI: IOAPIC (id[0x02] address[0xfec00000] gsi_base[0])
[    0.000000] IOAPIC[0]: apic_id 2, version 32, address 0xfec00000, GSI 0-23
[    0.000000] ACPI: INT_SRC_OVR (bus 0 bus_irq 0 global_irq 2 dfl dfl)
[    0.000000] ACPI: INT_SRC_OVR (bus 0 bus_irq 9 global_irq 9 high level)
[    0.000000] ACPI: IRQ0 used by override.
[    0.000000] ACPI: IRQ2 used by override.
[    0.000000] ACPI: IRQ9 used by override.
[    0.000000] Using ACPI (MADT) for SMP configuration information
[    0.000000] ACPI: HPET id: 0x8086a701 base: 0xfed00000
[    0.000000] smpboot: Allowing 8 CPUs, 0 hotplug CPUs
[    0.000000] nr_irqs_gsi: 40
[    0.000000] PM: Registered nosave memory: 000000000009d000 -
000000000009e000
[    0.000000] PM: Registered nosave memory: 000000000009e000 -
00000000000a0000
[    0.000000] PM: Registered nosave memory: 00000000000a0000 -
00000000000e0000
[    0.000000] PM: Registered nosave memory: 00000000000e0000 -
0000000000100000
[    0.000000] PM: Registered nosave memory: 0000000020000000 -
0000000020200000
[    0.000000] PM: Registered nosave memory: 0000000040004000 -
0000000040005000
[    0.000000] PM: Registered nosave memory: 00000000cc653000 -
00000000ccad6000
[    0.000000] PM: Registered nosave memory: 00000000ccad6000 -
00000000ccae6000
[    0.000000] PM: Registered nosave memory: 00000000ccae6000 -
00000000ccc0e000
[    0.000000] PM: Registered nosave memory: 00000000ccc0e000 -
00000000cd80e000
[    0.000000] PM: Registered nosave memory: 00000000cd80f000 -
00000000cd852000
[    0.000000] PM: Registered nosave memory: 00000000cdc78000 -
00000000cdff4000
[    0.000000] PM: Registered nosave memory: 00000000ce000000 -
00000000cf000000
[    0.000000] PM: Registered nosave memory: 00000000cf000000 -
00000000df200000
[    0.000000] PM: Registered nosave memory: 00000000df200000 -
00000000f8000000
[    0.000000] PM: Registered nosave memory: 00000000f8000000 -
00000000fc000000
[    0.000000] PM: Registered nosave memory: 00000000fc000000 -
00000000fec00000
[    0.000000] PM: Registered nosave memory: 00000000fec00000 -
00000000fec01000
[    0.000000] PM: Registered nosave memory: 00000000fec01000 -
00000000fed00000
[    0.000000] PM: Registered nosave memory: 00000000fed00000 -
00000000fed04000
[    0.000000] PM: Registered nosave memory: 00000000fed04000 -
00000000fed1c000
[    0.000000] PM: Registered nosave memory: 00000000fed1c000 -
00000000fed20000
[    0.000000] PM: Registered nosave memory: 00000000fed20000 -
00000000fee00000
[    0.000000] PM: Registered nosave memory: 00000000fee00000 -
00000000fee01000
[    0.000000] PM: Registered nosave memory: 00000000fee01000 -
00000000ff000000
[    0.000000] PM: Registered nosave memory: 00000000ff000000 -
0000000100000000
[    0.000000] e820: [mem 0xdf200000-0xf7ffffff] available for PCI devices
[    0.000000] Booting paravirtualized kernel on bare hardware
[    0.000000] setup_percpu: NR_CPUS:512 nr_cpumask_bits:512 nr_cpu_ids:8
nr_node_ids:1
[    0.000000] PERCPU: Embedded 28 pages/cpu @ffff8803fec00000 s83840
r8192 d22656 u262144
[    0.000000] pcpu-alloc: s83840 r8192 d22656 u262144 alloc=1*2097152
[    0.000000] pcpu-alloc: [0] 0 1 2 3 4 5 6 7
[    0.000000] Built 1 zonelists in Zone order, mobility grouping on. 
Total pages: 3921988
[    0.000000] Policy zone: Normal
[    0.000000] Kernel command line: BOOT_IMAGE=/vmlinuz-3.7-trunk-amd64
root=/dev/mapper/glaukopis-root ro quiet
[    0.000000] PID hash table entries: 4096 (order: 3, 32768 bytes)
[    0.000000] __ex_table already sorted, skipping sort
[    0.000000] xsave: enabled xstate_bv 0x7, cntxt size 0x340
[    0.000000] Checking aperture...
[    0.000000] No AGP bridge found
[    0.000000] Calgary: detecting Calgary via BIOS EBDA area
[    0.000000] Calgary: Unable to locate Rio Grande table in EBDA - bailing!
[    0.000000] Memory: 15610672k/16760832k available (3587k kernel code,
843704k absent, 306456k reserved, 3137k data, 616k init)
[    0.000000] Hierarchical RCU implementation.
[    0.000000]  RCU dyntick-idle grace-period acceleration is enabled.
[    0.000000]  RCU restricting CPUs from NR_CPUS=512 to nr_cpu_ids=8.
[    0.000000] NR_IRQS:33024 nr_irqs:744 16
[    0.000000] Extended CMOS year: 2000
[    0.000000] Console: colour VGA+ 80x25
[    0.000000] console [tty0] enabled
[    0.000000] hpet clockevent registered
[    0.000000] tsc: Fast TSC calibration using PIT
[    0.004000] tsc: Detected 3410.364 MHz processor
[    0.000002] Calibrating delay loop (skipped), value calculated using
timer frequency.. 6820.72 BogoMIPS (lpj=13641456)
[    0.000003] pid_max: default: 32768 minimum: 301
[    0.000024] Security Framework initialized
[    0.000027] AppArmor: AppArmor disabled by boot time parameter
[    0.000661] Dentry cache hash table entries: 2097152 (order: 12,
16777216 bytes)
[    0.003500] Inode-cache hash table entries: 1048576 (order: 11, 8388608
bytes)
[    0.004753] Mount-cache hash table entries: 256
[    0.004887] Initializing cgroup subsys cpuacct
[    0.004889] Initializing cgroup subsys memory
[    0.004895] Initializing cgroup subsys devices
[    0.004896] Initializing cgroup subsys freezer
[    0.004897] Initializing cgroup subsys net_cls
[    0.004898] Initializing cgroup subsys blkio
[    0.004899] Initializing cgroup subsys perf_event
[    0.004918] CPU: Physical Processor ID: 0
[    0.004919] CPU: Processor Core ID: 0
[    0.004922] ENERGY_PERF_BIAS: Set to 'normal', was 'performance'
[    0.004922] ENERGY_PERF_BIAS: View and update with
x86_energy_perf_policy(8)
[    0.005182] mce: CPU supports 9 MCE banks
[    0.005191] CPU0: Thermal monitoring enabled (TM1)
[    0.005197] process: using mwait in idle threads
[    0.005200] Last level iTLB entries: 4KB 512, 2MB 0, 4MB 0
[    0.005200] Last level dTLB entries: 4KB 512, 2MB 32, 4MB 32
[    0.005200] tlb_flushall_shift: 1
[    0.005275] Freeing SMP alternatives: 8k freed
[    0.005543] ACPI: Core revision 20120913
[    0.011378] dmar: Host address width 36
[    0.011379] dmar: DRHD base: 0x000000fed90000 flags: 0x0
[    0.011384] dmar: IOMMU 0: reg_base_addr fed90000 ver 1:0 cap
c0000020e60262 ecap f0101a
[    0.011385] dmar: DRHD base: 0x000000fed91000 flags: 0x1
[    0.011390] dmar: IOMMU 1: reg_base_addr fed91000 ver 1:0 cap
c9008020660262 ecap f0105a
[    0.011391] dmar: RMRR base: 0x000000cca58000 end: 0x000000cca69fff
[    0.011392] dmar: RMRR base: 0x000000cf000000 end: 0x000000df1fffff
[    0.011461] IOAPIC id 2 under DRHD base  0xfed91000 IOMMU 1
[    0.011461] HPET id 0 under DRHD base 0xfed91000
[    0.011569] Enabled IRQ remapping in x2apic mode
[    0.011570] Enabling x2apic
[    0.011571] Enabled x2apic
[    0.011575] Switched APIC routing to cluster x2apic.
[    0.011969] ..TIMER: vector=0x30 apic1=0 pin1=2 apic2=-1 pin2=-1
[    0.051618] smpboot: CPU0: Intel(R) Core(TM) i7-3770 CPU @ 3.40GHz
(fam: 06, model: 3a, stepping: 09)
[    0.156647] Performance Events: PEBS fmt1+, 16-deep LBR, IvyBridge
events, Intel PMU driver.
[    0.156652] ... version:                3
[    0.156652] ... bit width:              48
[    0.156653] ... generic registers:      4
[    0.156654] ... value mask:             0000ffffffffffff
[    0.156655] ... max period:             000000007fffffff
[    0.156655] ... fixed-purpose events:   3
[    0.156656] ... event mask:             000000070000000f
[    0.170113] NMI watchdog: enabled on all CPUs, permanently consumes one
hw-PMU counter.
[    0.156840] smpboot: Booting Node   0, Processors  #1 #2 #3 #4 #5 #6 #7 OK
[    0.250362] Brought up 8 CPUs
[    0.250365] smpboot: Total of 8 processors activated (54565.82 BogoMIPS)
[    0.256550] devtmpfs: initialized
[    0.259364] PM: Registering ACPI NVS region [mem 0xccae6000-0xccc0dfff]
(1212416 bytes)
[    0.259386] PM: Registering ACPI NVS region [mem 0xcd80f000-0xcd851fff]
(274432 bytes)
[    0.259466] regulator-dummy: no parameters
[    0.259509] NET: Registered protocol family 16
[    0.259593] ACPI FADT declares the system doesn't support PCIe ASPM, so
disable it
[    0.259594] ACPI: bus type pci registered
[    0.259634] PCI: MMCONFIG for domain 0000 [bus 00-3f] at [mem
0xf8000000-0xfbffffff] (base 0xf8000000)
[    0.259636] PCI: MMCONFIG at [mem 0xf8000000-0xfbffffff] reserved in E820
[    0.262479] PCI: Using configuration type 1 for base access
[    0.263043] bio: create slab <bio-0> at 0
[    0.263097] ACPI: Added _OSI(Module Device)
[    0.263098] ACPI: Added _OSI(Processor Device)
[    0.263099] ACPI: Added _OSI(3.0 _SCP Extensions)
[    0.263100] ACPI: Added _OSI(Processor Aggregator Device)
[    0.264017] ACPI: EC: Look up EC in DSDT
[    0.265092] ACPI: Executed 1 blocks of module-level executable AML code
[    0.267514] ACPI: SSDT 00000000cca83018 0083B (v01  PmRef  Cpu0Cst
00003001 INTL 20051117)
[    0.267750] ACPI: Dynamic OEM Table Load:
[    0.267751] ACPI: SSDT           (null) 0083B (v01  PmRef  Cpu0Cst
00003001 INTL 20051117)
[    0.278157] ACPI: SSDT 00000000cca84a98 00303 (v01  PmRef    ApIst
00003000 INTL 20051117)
[    0.278413] ACPI: Dynamic OEM Table Load:
[    0.278414] ACPI: SSDT           (null) 00303 (v01  PmRef    ApIst
00003000 INTL 20051117)
[    0.298039] ACPI: SSDT 00000000cca85c18 00119 (v01  PmRef    ApCst
00003000 INTL 20051117)
[    0.298265] ACPI: Dynamic OEM Table Load:
[    0.298266] ACPI: SSDT           (null) 00119 (v01  PmRef    ApCst
00003000 INTL 20051117)
[    0.318860] ACPI: Interpreter enabled
[    0.318864] ACPI: (supports S0 S3 S4 S5)
[    0.318877] ACPI: Using IOAPIC for interrupt routing
[    0.322652] ACPI: Power Resource [FN00] (off)
[    0.322703] ACPI: Power Resource [FN01] (off)
[    0.322753] ACPI: Power Resource [FN02] (off)
[    0.322800] ACPI: Power Resource [FN03] (off)
[    0.322849] ACPI: Power Resource [FN04] (off)
[    0.323160] ACPI: No dock devices found.
[    0.323162] PCI: Using host bridge windows from ACPI; if necessary, use
"pci=nocrs" and report a bug
[    0.323449] ACPI: PCI Root Bridge [PCI0] (domain 0000 [bus 00-3e])
[    0.323788] PCI host bridge to bus 0000:00
[    0.323790] pci_bus 0000:00: root bus resource [bus 00-3e]
[    0.323792] pci_bus 0000:00: root bus resource [io  0x0000-0x0cf7]
[    0.323793] pci_bus 0000:00: root bus resource [io  0x0d00-0xffff]
[    0.323795] pci_bus 0000:00: root bus resource [mem 0x000a0000-0x000bffff]
[    0.323796] pci_bus 0000:00: root bus resource [mem 0x000d0000-0x000d3fff]
[    0.323797] pci_bus 0000:00: root bus resource [mem 0x000d4000-0x000d7fff]
[    0.323798] pci_bus 0000:00: root bus resource [mem 0x000d8000-0x000dbfff]
[    0.323800] pci_bus 0000:00: root bus resource [mem 0x000dc000-0x000dffff]
[    0.323801] pci_bus 0000:00: root bus resource [mem 0x000e0000-0x000e3fff]
[    0.323802] pci_bus 0000:00: root bus resource [mem 0x000e4000-0x000e7fff]
[    0.323803] pci_bus 0000:00: root bus resource [mem 0xdf200000-0xfeafffff]
[    0.323809] pci 0000:00:00.0: [8086:0150] type 00 class 0x060000
[    0.323835] pci 0000:00:01.0: [8086:0151] type 01 class 0x060400
[    0.323856] pci 0000:00:01.0: PME# supported from D0 D3hot D3cold
[    0.323871] pci 0000:00:02.0: [8086:0162] type 00 class 0x030000
[    0.323878] pci 0000:00:02.0: reg 10: [mem 0xf7800000-0xf7bfffff 64bit]
[    0.323882] pci 0000:00:02.0: reg 18: [mem 0xe0000000-0xefffffff 64bit
pref]
[    0.323886] pci 0000:00:02.0: reg 20: [io  0xf000-0xf03f]
[    0.323926] pci 0000:00:14.0: [8086:1e31] type 00 class 0x0c0330
[    0.323945] pci 0000:00:14.0: reg 10: [mem 0xf7c00000-0xf7c0ffff 64bit]
[    0.324010] pci 0000:00:14.0: PME# supported from D3hot D3cold
[    0.324030] pci 0000:00:16.0: [8086:1e3a] type 00 class 0x078000
[    0.324050] pci 0000:00:16.0: reg 10: [mem 0xf7c1a000-0xf7c1a00f 64bit]
[    0.324119] pci 0000:00:16.0: PME# supported from D0 D3hot D3cold
[    0.324148] pci 0000:00:1a.0: [8086:1e2d] type 00 class 0x0c0320
[    0.324167] pci 0000:00:1a.0: reg 10: [mem 0xf7c18000-0xf7c183ff]
[    0.324250] pci 0000:00:1a.0: PME# supported from D0 D3hot D3cold
[    0.324273] pci 0000:00:1b.0: [8086:1e20] type 00 class 0x040300
[    0.324286] pci 0000:00:1b.0: reg 10: [mem 0xf7c10000-0xf7c13fff 64bit]
[    0.324347] pci 0000:00:1b.0: PME# supported from D0 D3hot D3cold
[    0.324372] pci 0000:00:1c.0: [8086:1e10] type 01 class 0x060400
[    0.324498] pci 0000:00:1c.0: PME# supported from D0 D3hot D3cold
[    0.324533] pci 0000:00:1c.5: [8086:1e1a] type 01 class 0x060400
[    0.324604] pci 0000:00:1c.5: PME# supported from D0 D3hot D3cold
[    0.324626] pci 0000:00:1c.6: [8086:244e] type 01 class 0x060401
[    0.324696] pci 0000:00:1c.6: PME# supported from D0 D3hot D3cold
[    0.324723] pci 0000:00:1d.0: [8086:1e26] type 00 class 0x0c0320
[    0.324741] pci 0000:00:1d.0: reg 10: [mem 0xf7c17000-0xf7c173ff]
[    0.324824] pci 0000:00:1d.0: PME# supported from D0 D3hot D3cold
[    0.324847] pci 0000:00:1f.0: [8086:1e44] type 00 class 0x060100
[    0.324961] pci 0000:00:1f.2: [8086:1e02] type 00 class 0x010601
[    0.324977] pci 0000:00:1f.2: reg 10: [io  0xf0b0-0xf0b7]
[    0.324984] pci 0000:00:1f.2: reg 14: [io  0xf0a0-0xf0a3]
[    0.324990] pci 0000:00:1f.2: reg 18: [io  0xf090-0xf097]
[    0.324996] pci 0000:00:1f.2: reg 1c: [io  0xf080-0xf083]
[    0.325003] pci 0000:00:1f.2: reg 20: [io  0xf060-0xf07f]
[    0.325009] pci 0000:00:1f.2: reg 24: [mem 0xf7c16000-0xf7c167ff]
[    0.325049] pci 0000:00:1f.2: PME# supported from D3hot
[    0.325064] pci 0000:00:1f.3: [8086:1e22] type 00 class 0x0c0500
[    0.325077] pci 0000:00:1f.3: reg 10: [mem 0xf7c15000-0xf7c150ff 64bit]
[    0.325095] pci 0000:00:1f.3: reg 20: [io  0xf040-0xf05f]
[    0.325133] pci 0000:00:01.0: PCI bridge to [bus 01]
[    0.325202] pci 0000:00:1c.0: PCI bridge to [bus 02]
[    0.325275] pci 0000:03:00.0: [10ec:8168] type 00 class 0x020000
[    0.325293] pci 0000:03:00.0: reg 10: [io  0xe000-0xe0ff]
[    0.325325] pci 0000:03:00.0: reg 18: [mem 0xf0004000-0xf0004fff 64bit
pref]
[    0.325346] pci 0000:03:00.0: reg 20: [mem 0xf0000000-0xf0003fff 64bit
pref]
[    0.325433] pci 0000:03:00.0: supports D1 D2
[    0.325435] pci 0000:03:00.0: PME# supported from D0 D1 D2 D3hot D3cold
[    0.333916] pci 0000:00:1c.5: PCI bridge to [bus 03]
[    0.333921] pci 0000:00:1c.5:   bridge window [io  0xe000-0xefff]
[    0.333931] pci 0000:00:1c.5:   bridge window [mem
0xf0000000-0xf00fffff 64bit pref]
[    0.333998] pci 0000:04:00.0: [1b21:1080] type 01 class 0x060401
[    0.334111] pci 0000:00:1c.6: PCI bridge to [bus 04-05] (subtractive
decode)
[    0.334120] pci 0000:00:1c.6:   bridge window [io  0x0000-0x0cf7]
(subtractive decode)
[    0.334121] pci 0000:00:1c.6:   bridge window [io  0x0d00-0xffff]
(subtractive decode)
[    0.334122] pci 0000:00:1c.6:   bridge window [mem
0x000a0000-0x000bffff] (subtractive decode)
[    0.334124] pci 0000:00:1c.6:   bridge window [mem
0x000d0000-0x000d3fff] (subtractive decode)
[    0.334125] pci 0000:00:1c.6:   bridge window [mem
0x000d4000-0x000d7fff] (subtractive decode)
[    0.334126] pci 0000:00:1c.6:   bridge window [mem
0x000d8000-0x000dbfff] (subtractive decode)
[    0.334127] pci 0000:00:1c.6:   bridge window [mem
0x000dc000-0x000dffff] (subtractive decode)
[    0.334129] pci 0000:00:1c.6:   bridge window [mem
0x000e0000-0x000e3fff] (subtractive decode)
[    0.334130] pci 0000:00:1c.6:   bridge window [mem
0x000e4000-0x000e7fff] (subtractive decode)
[    0.334131] pci 0000:00:1c.6:   bridge window [mem
0xdf200000-0xfeafffff] (subtractive decode)
[    0.334241] pci 0000:04:00.0: PCI bridge to [bus 05] (subtractive decode)
[    0.334262] pci 0000:04:00.0:   bridge window [??? 0x00000000 flags
0x0] (subtractive decode)
[    0.334263] pci 0000:04:00.0:   bridge window [??? 0x00000000 flags
0x0] (subtractive decode)
[    0.334264] pci 0000:04:00.0:   bridge window [??? 0x00000000 flags
0x0] (subtractive decode)
[    0.334266] pci 0000:04:00.0:   bridge window [??? 0x00000000 flags
0x0] (subtractive decode)
[    0.334267] pci 0000:04:00.0:   bridge window [io  0x0000-0x0cf7]
(subtractive decode)
[    0.334268] pci 0000:04:00.0:   bridge window [io  0x0d00-0xffff]
(subtractive decode)
[    0.334269] pci 0000:04:00.0:   bridge window [mem
0x000a0000-0x000bffff] (subtractive decode)
[    0.334271] pci 0000:04:00.0:   bridge window [mem
0x000d0000-0x000d3fff] (subtractive decode)
[    0.334272] pci 0000:04:00.0:   bridge window [mem
0x000d4000-0x000d7fff] (subtractive decode)
[    0.334273] pci 0000:04:00.0:   bridge window [mem
0x000d8000-0x000dbfff] (subtractive decode)
[    0.334275] pci 0000:04:00.0:   bridge window [mem
0x000dc000-0x000dffff] (subtractive decode)
[    0.334276] pci 0000:04:00.0:   bridge window [mem
0x000e0000-0x000e3fff] (subtractive decode)
[    0.334277] pci 0000:04:00.0:   bridge window [mem
0x000e4000-0x000e7fff] (subtractive decode)
[    0.334279] pci 0000:04:00.0:   bridge window [mem
0xdf200000-0xfeafffff] (subtractive decode)
[    0.334306] ACPI: PCI Interrupt Routing Table [\_SB_.PCI0._PRT]
[    0.334424] ACPI: PCI Interrupt Routing Table [\_SB_.PCI0.RP01._PRT]
[    0.334453] ACPI: PCI Interrupt Routing Table [\_SB_.PCI0.RP06._PRT]
[    0.334478] ACPI: PCI Interrupt Routing Table [\_SB_.PCI0.PEG0._PRT]
[    0.334506] ACPI: PCI Interrupt Routing Table [\_SB_.PCI0.RP07._PRT]
[    0.334528] ACPI: PCI Interrupt Routing Table [\_SB_.PCI0.RP07.PXSX._PRT]
[    0.334622]  pci0000:00: Requesting ACPI _OSC control (0x1d)
[    0.334775]  pci0000:00: ACPI _OSC control (0x18) granted
[    0.337958] ACPI: PCI Interrupt Link [LNKA] (IRQs 3 4 5 6 10 *11 12 14 15)
[    0.337990] ACPI: PCI Interrupt Link [LNKB] (IRQs *3 4 5 6 10 11 12 14 15)
[    0.338020] ACPI: PCI Interrupt Link [LNKC] (IRQs 3 4 5 6 10 *11 12 14 15)
[    0.338051] ACPI: PCI Interrupt Link [LNKD] (IRQs 3 4 5 6 *10 11 12 14 15)
[    0.338081] ACPI: PCI Interrupt Link [LNKE] (IRQs 3 4 5 6 10 11 12 14
15) *0, disabled.
[    0.338110] ACPI: PCI Interrupt Link [LNKF] (IRQs 3 4 5 6 10 11 12 14
15) *0, disabled.
[    0.338141] ACPI: PCI Interrupt Link [LNKG] (IRQs 3 4 *5 6 10 11 12 14 15)
[    0.338170] ACPI: PCI Interrupt Link [LNKH] (IRQs 3 4 5 6 *10 11 12 14 15)
[    0.338219] vgaarb: device added:
PCI:0000:00:02.0,decodes=io+mem,owns=io+mem,locks=none
[    0.338221] vgaarb: loaded
[    0.338222] vgaarb: bridge control possible 0000:00:02.0
[    0.338245] PCI: Using ACPI for IRQ routing
[    0.339619] PCI: pci_cache_line_size set to 64 bytes
[    0.339660] e820: reserve RAM buffer [mem 0x0009d800-0x0009ffff]
[    0.339662] e820: reserve RAM buffer [mem 0x40004000-0x43ffffff]
[    0.339663] e820: reserve RAM buffer [mem 0xcc653000-0xcfffffff]
[    0.339664] e820: reserve RAM buffer [mem 0xcd80f000-0xcfffffff]
[    0.339665] e820: reserve RAM buffer [mem 0xcdc78000-0xcfffffff]
[    0.339666] e820: reserve RAM buffer [mem 0xce000000-0xcfffffff]
[    0.339668] e820: reserve RAM buffer [mem 0x3ff000000-0x3ffffffff]
[    0.339742] hpet0: at MMIO 0xfed00000, IRQs 2, 8, 0, 0, 0, 0, 0, 0
[    0.339746] hpet0: 8 comparators, 64-bit 14.318180 MHz counter
[    0.341751] Switching to clocksource hpet
[    0.342864] pnp: PnP ACPI init
[    0.342871] ACPI: bus type pnp registered
[    0.343046] pnp 00:00: [bus 00-3e]
[    0.343048] pnp 00:00: [io  0x0000-0x0cf7 window]
[    0.343049] pnp 00:00: [io  0x0cf8-0x0cff]
[    0.343050] pnp 00:00: [io  0x0d00-0xffff window]
[    0.343051] pnp 00:00: [mem 0x000a0000-0x000bffff window]
[    0.343053] pnp 00:00: [mem 0x000c0000-0x000c3fff window]
[    0.343054] pnp 00:00: [mem 0x000c4000-0x000c7fff window]
[    0.343055] pnp 00:00: [mem 0x000c8000-0x000cbfff window]
[    0.343056] pnp 00:00: [mem 0x000cc000-0x000cffff window]
[    0.343057] pnp 00:00: [mem 0x000d0000-0x000d3fff window]
[    0.343059] pnp 00:00: [mem 0x000d4000-0x000d7fff window]
[    0.343060] pnp 00:00: [mem 0x000d8000-0x000dbfff window]
[    0.343061] pnp 00:00: [mem 0x000dc000-0x000dffff window]
[    0.343063] pnp 00:00: [mem 0x000e0000-0x000e3fff window]
[    0.343064] pnp 00:00: [mem 0x000e4000-0x000e7fff window]
[    0.343065] pnp 00:00: [mem 0x000e8000-0x000ebfff window]
[    0.343066] pnp 00:00: [mem 0x000ec000-0x000effff window]
[    0.343067] pnp 00:00: [mem 0x000f0000-0x000fffff window]
[    0.343068] pnp 00:00: [mem 0xdf200000-0xfeafffff window]
[    0.343070] pnp 00:00: [mem 0x00010000-0x0001ffff window]
[    0.343088] pnp 00:00: Plug and Play ACPI device, IDs PNP0a08 PNP0a03
(active)
[    0.343103] pnp 00:01: [mem 0xfed40000-0xfed44fff]
[    0.343119] system 00:01: [mem 0xfed40000-0xfed44fff] has been reserved
[    0.343121] system 00:01: Plug and Play ACPI device, IDs PNP0c01 (active)
[    0.343128] pnp 00:02: [io  0x0000-0x001f]
[    0.343129] pnp 00:02: [io  0x0081-0x0091]
[    0.343130] pnp 00:02: [io  0x0093-0x009f]
[    0.343131] pnp 00:02: [io  0x00c0-0x00df]
[    0.343132] pnp 00:02: [dma 4]
[    0.343142] pnp 00:02: Plug and Play ACPI device, IDs PNP0200 (active)
[    0.343147] pnp 00:03: [mem 0xff000000-0xffffffff]
[    0.343158] pnp 00:03: Plug and Play ACPI device, IDs INT0800 (active)
[    0.343209] pnp 00:04: [mem 0xfed00000-0xfed003ff]
[    0.343220] pnp 00:04: Plug and Play ACPI device, IDs PNP0103 (active)
[    0.343227] pnp 00:05: [io  0x002e-0x002f]
[    0.343228] pnp 00:05: [io  0x004e-0x004f]
[    0.343229] pnp 00:05: [io  0x0061]
[    0.343230] pnp 00:05: [io  0x0063]
[    0.343231] pnp 00:05: [io  0x0065]
[    0.343232] pnp 00:05: [io  0x0067]
[    0.343233] pnp 00:05: [io  0x0070]
[    0.343234] pnp 00:05: [io  0x0080]
[    0.343235] pnp 00:05: [io  0x0092]
[    0.343236] pnp 00:05: [io  0x00b2-0x00b3]
[    0.343237] pnp 00:05: [io  0x0680-0x069f]
[    0.343238] pnp 00:05: [io  0x1000-0x100f]
[    0.343240] pnp 00:05: [io  0xffff]
[    0.343241] pnp 00:05: [io  0xffff]
[    0.343242] pnp 00:05: [io  0x0400-0x0453]
[    0.343243] pnp 00:05: [io  0x0458-0x047f]
[    0.343244] pnp 00:05: [io  0x0500-0x057f]
[    0.343246] pnp 00:05: [io  0x164e-0x164f]
[    0.343264] system 00:05: [io  0x0680-0x069f] has been reserved
[    0.343266] system 00:05: [io  0x1000-0x100f] has been reserved
[    0.343267] system 00:05: [io  0xffff] has been reserved
[    0.343269] system 00:05: [io  0xffff] has been reserved
[    0.343270] system 00:05: [io  0x0400-0x0453] has been reserved
[    0.343272] system 00:05: [io  0x0458-0x047f] has been reserved
[    0.343273] system 00:05: [io  0x0500-0x057f] has been reserved
[    0.343274] system 00:05: [io  0x164e-0x164f] has been reserved
[    0.343276] system 00:05: Plug and Play ACPI device, IDs PNP0c02 (active)
[    0.343281] pnp 00:06: [io  0x0070-0x0077]
[    0.343288] pnp 00:06: [irq 8]
[    0.343299] pnp 00:06: Plug and Play ACPI device, IDs PNP0b00 (active)
[    0.343316] pnp 00:07: [io  0x0454-0x0457]
[    0.343330] system 00:07: [io  0x0454-0x0457] has been reserved
[    0.343332] system 00:07: Plug and Play ACPI device, IDs INT3f0d
PNP0c02 (active)
[    0.343372] pnp 00:08: [io  0x0000-0xffffffffffffffff disabled]
[    0.343373] pnp 00:08: [io  0x0000-0xffffffffffffffff disabled]
[    0.343374] pnp 00:08: [io  0x0000-0xffffffffffffffff disabled]
[    0.343375] pnp 00:08: [io  0x0290-0x029f]
[    0.343377] pnp 00:08: [io  0x0000-0xffffffffffffffff disabled]
[    0.343393] system 00:08: [io  0x0290-0x029f] has been reserved
[    0.343395] system 00:08: Plug and Play ACPI device, IDs PNP0c02 (active)
[    0.343409] pnp 00:09: [io  0x0010-0x001f]
[    0.343410] pnp 00:09: [io  0x0022-0x003f]
[    0.343411] pnp 00:09: [io  0x0044-0x005f]
[    0.343412] pnp 00:09: [io  0x0063]
[    0.343413] pnp 00:09: [io  0x0065]
[    0.343414] pnp 00:09: [io  0x0067-0x006f]
[    0.343415] pnp 00:09: [io  0x0072-0x007f]
[    0.343416] pnp 00:09: [io  0x0080]
[    0.343417] pnp 00:09: [io  0x0084-0x0086]
[    0.343418] pnp 00:09: [io  0x0088]
[    0.343419] pnp 00:09: [io  0x008c-0x008e]
[    0.343420] pnp 00:09: [io  0x0090-0x009f]
[    0.343422] pnp 00:09: [io  0x00a2-0x00bf]
[    0.343423] pnp 00:09: [io  0x00e0-0x00ef]
[    0.343424] pnp 00:09: [io  0x04d0-0x04d1]
[    0.343442] system 00:09: [io  0x04d0-0x04d1] has been reserved
[    0.343443] system 00:09: Plug and Play ACPI device, IDs PNP0c02 (active)
[    0.343448] pnp 00:0a: [io  0x00f0-0x00ff]
[    0.343454] pnp 00:0a: [irq 13]
[    0.343467] pnp 00:0a: Plug and Play ACPI device, IDs PNP0c04 (active)
[    0.343635] pnp 00:0b: [io  0x03f8-0x03ff]
[    0.343640] pnp 00:0b: [irq 4]
[    0.343641] pnp 00:0b: [dma 0 disabled]
[    0.343674] pnp 00:0b: Plug and Play ACPI device, IDs PNP0501 (active)
[    0.343828] pnp 00:0c: [mem 0xfed1c000-0xfed1ffff]
[    0.343829] pnp 00:0c: [mem 0xfed10000-0xfed17fff]
[    0.343830] pnp 00:0c: [mem 0xfed18000-0xfed18fff]
[    0.343831] pnp 00:0c: [mem 0xfed19000-0xfed19fff]
[    0.343832] pnp 00:0c: [mem 0xf8000000-0xfbffffff]
[    0.343833] pnp 00:0c: [mem 0xfed20000-0xfed3ffff]
[    0.343834] pnp 00:0c: [mem 0xfed90000-0xfed93fff]
[    0.343835] pnp 00:0c: [mem 0xfed45000-0xfed8ffff]
[    0.343837] pnp 00:0c: [mem 0xff000000-0xffffffff]
[    0.343838] pnp 00:0c: [mem 0xfee00000-0xfeefffff]
[    0.343839] pnp 00:0c: [mem 0xdf200000-0xdf200fff]
[    0.343861] system 00:0c: [mem 0xfed1c000-0xfed1ffff] has been reserved
[    0.343863] system 00:0c: [mem 0xfed10000-0xfed17fff] has been reserved
[    0.343864] system 00:0c: [mem 0xfed18000-0xfed18fff] has been reserved
[    0.343866] system 00:0c: [mem 0xfed19000-0xfed19fff] has been reserved
[    0.343867] system 00:0c: [mem 0xf8000000-0xfbffffff] has been reserved
[    0.343869] system 00:0c: [mem 0xfed20000-0xfed3ffff] has been reserved
[    0.343870] system 00:0c: [mem 0xfed90000-0xfed93fff] could not be
reserved
[    0.343872] system 00:0c: [mem 0xfed45000-0xfed8ffff] has been reserved
[    0.343873] system 00:0c: [mem 0xff000000-0xffffffff] has been reserved
[    0.343875] system 00:0c: [mem 0xfee00000-0xfeefffff] could not be
reserved
[    0.343876] system 00:0c: [mem 0xdf200000-0xdf200fff] has been reserved
[    0.343878] system 00:0c: Plug and Play ACPI device, IDs PNP0c02 (active)
[    0.343976] pnp 00:0d: [mem 0x20000000-0x201fffff]
[    0.343977] pnp 00:0d: [mem 0x40004000-0x40004fff]
[    0.343997] system 00:0d: [mem 0x20000000-0x201fffff] has been reserved
[    0.343998] system 00:0d: [mem 0x40004000-0x40004fff] has been reserved
[    0.344000] system 00:0d: Plug and Play ACPI device, IDs PNP0c01 (active)
[    0.344015] pnp: PnP ACPI: found 14 devices
[    0.344016] ACPI: ACPI bus type pnp unregistered
[    0.349604] pci 0000:00:01.0: PCI bridge to [bus 01]
[    0.349608] pci 0000:00:1c.0: PCI bridge to [bus 02]
[    0.349625] pci 0000:00:1c.5: PCI bridge to [bus 03]
[    0.349627] pci 0000:00:1c.5:   bridge window [io  0xe000-0xefff]
[    0.349633] pci 0000:00:1c.5:   bridge window [mem
0xf0000000-0xf00fffff 64bit pref]
[    0.349638] pci 0000:04:00.0: PCI bridge to [bus 05]
[    0.349657] pci 0000:00:1c.6: PCI bridge to [bus 04-05]
[    0.349696] pci 0000:04:00.0: setting latency timer to 64
[    0.349699] pci_bus 0000:00: resource 4 [io  0x0000-0x0cf7]
[    0.349700] pci_bus 0000:00: resource 5 [io  0x0d00-0xffff]
[    0.349702] pci_bus 0000:00: resource 6 [mem 0x000a0000-0x000bffff]
[    0.349703] pci_bus 0000:00: resource 7 [mem 0x000d0000-0x000d3fff]
[    0.349704] pci_bus 0000:00: resource 8 [mem 0x000d4000-0x000d7fff]
[    0.349705] pci_bus 0000:00: resource 9 [mem 0x000d8000-0x000dbfff]
[    0.349707] pci_bus 0000:00: resource 10 [mem 0x000dc000-0x000dffff]
[    0.349708] pci_bus 0000:00: resource 11 [mem 0x000e0000-0x000e3fff]
[    0.349709] pci_bus 0000:00: resource 12 [mem 0x000e4000-0x000e7fff]
[    0.349710] pci_bus 0000:00: resource 13 [mem 0xdf200000-0xfeafffff]
[    0.349712] pci_bus 0000:03: resource 0 [io  0xe000-0xefff]
[    0.349713] pci_bus 0000:03: resource 2 [mem 0xf0000000-0xf00fffff
64bit pref]
[    0.349714] pci_bus 0000:04: resource 4 [io  0x0000-0x0cf7]
[    0.349715] pci_bus 0000:04: resource 5 [io  0x0d00-0xffff]
[    0.349716] pci_bus 0000:04: resource 6 [mem 0x000a0000-0x000bffff]
[    0.349718] pci_bus 0000:04: resource 7 [mem 0x000d0000-0x000d3fff]
[    0.349719] pci_bus 0000:04: resource 8 [mem 0x000d4000-0x000d7fff]
[    0.349720] pci_bus 0000:04: resource 9 [mem 0x000d8000-0x000dbfff]
[    0.349721] pci_bus 0000:04: resource 10 [mem 0x000dc000-0x000dffff]
[    0.349722] pci_bus 0000:04: resource 11 [mem 0x000e0000-0x000e3fff]
[    0.349724] pci_bus 0000:04: resource 12 [mem 0x000e4000-0x000e7fff]
[    0.349725] pci_bus 0000:04: resource 13 [mem 0xdf200000-0xfeafffff]
[    0.349726] pci_bus 0000:05: resource 8 [io  0x0000-0x0cf7]
[    0.349727] pci_bus 0000:05: resource 9 [io  0x0d00-0xffff]
[    0.349728] pci_bus 0000:05: resource 10 [mem 0x000a0000-0x000bffff]
[    0.349730] pci_bus 0000:05: resource 11 [mem 0x000d0000-0x000d3fff]
[    0.349731] pci_bus 0000:05: resource 12 [mem 0x000d4000-0x000d7fff]
[    0.349732] pci_bus 0000:05: resource 13 [mem 0x000d8000-0x000dbfff]
[    0.349733] pci_bus 0000:05: resource 14 [mem 0x000dc000-0x000dffff]
[    0.349734] pci_bus 0000:05: resource 15 [mem 0x000e0000-0x000e3fff]
[    0.349736] pci_bus 0000:05: resource 16 [mem 0x000e4000-0x000e7fff]
[    0.349737] pci_bus 0000:05: resource 17 [mem 0xdf200000-0xfeafffff]
[    0.349811] NET: Registered protocol family 2
[    0.350264] TCP established hash table entries: 524288 (order: 11,
8388608 bytes)
[    0.351043] TCP bind hash table entries: 65536 (order: 8, 1048576 bytes)
[    0.351143] TCP: Hash tables configured (established 524288 bind 65536)
[    0.351158] TCP: reno registered
[    0.351171] UDP hash table entries: 8192 (order: 6, 262144 bytes)
[    0.351209] UDP-Lite hash table entries: 8192 (order: 6, 262144 bytes)
[    0.351306] NET: Registered protocol family 1
[    0.351315] pci 0000:00:02.0: Boot video device
[    0.389744] PCI: CLS 64 bytes, default 64
[    0.389786] Unpacking initramfs...
[    0.543331] Freeing initrd memory: 11736k freed
[    0.544169] PCI-DMA: Using software bounce buffering for IO (SWIOTLB)
[    0.544172] software IO TLB [mem 0xc8653000-0xcc652fff] (64MB) mapped
at [ffff8800c8653000-ffff8800cc652fff]
[    0.544508] audit: initializing netlink socket (disabled)
[    0.544519] type=2000 audit(1360123937.440:1): initialized
[    0.554862] HugeTLB registered 2 MB page size, pre-allocated 0 pages
[    0.555437] VFS: Disk quotas dquot_6.5.2
[    0.555458] Dquot-cache hash table entries: 512 (order 0, 4096 bytes)
[    0.555513] msgmni has been set to 30512
[    0.555658] alg: No test for stdrng (krng)
[    0.555684] Block layer SCSI generic (bsg) driver version 0.4 loaded
(major 252)
[    0.555704] io scheduler noop registered
[    0.555706] io scheduler deadline registered
[    0.555726] io scheduler cfq registered (default)
[    0.555788] pcieport 0000:00:01.0: irq 42 for MSI/MSI-X
[    0.555923] pci_hotplug: PCI Hot Plug PCI Core version: 0.5
[    0.555933] pciehp: PCI Express Hot Plug Controller Driver version: 0.4
[    0.555934] acpiphp: ACPI Hot Plug PCI Controller Driver version: 0.5
[    0.556173] intel_idle: MWAIT substates: 0x1120
[    0.556174] intel_idle: v0.4 model 0x3A
[    0.556175] intel_idle: lapic_timer_reliable_states 0xffffffff
[    0.556198] GHES: HEST is not enabled!
[    0.556229] Serial: 8250/16550 driver, 4 ports, IRQ sharing enabled
[    0.576658] 00:0b: ttyS0 at I/O 0x3f8 (irq = 4) is a 16550A
[    0.576940] Linux agpgart interface v0.103
[    0.577020] i8042: PNP: No PS/2 controller found. Probing ports directly.
[    0.579161] serio: i8042 KBD port at 0x60,0x64 irq 1
[    0.579165] serio: i8042 AUX port at 0x60,0x64 irq 12
[    0.579224] mousedev: PS/2 mouse device common for all mice
[    0.579253] rtc_cmos 00:06: RTC can wake from S4
[    0.579355] rtc_cmos 00:06: rtc core: registered rtc_cmos as rtc0
[    0.579379] rtc0: alarms up to one month, y3k, 242 bytes nvram, hpet irqs
[    0.579463] cpuidle: using governor ladder
[    0.579568] cpuidle: using governor menu
[    0.579593] drop_monitor: Initializing network drop monitor service
[    0.579643] TCP: cubic registered
[    0.579768] NET: Registered protocol family 10
[    0.579975] mip6: Mobile IPv6
[    0.579976] NET: Registered protocol family 17
[    0.580347] PM: Hibernation image not present or could not be loaded.
[    0.580354] registered taskstats version 1
[    0.580981] rtc_cmos 00:06: setting system clock to 2013-02-06 04:12:18
UTC (1360123938)
[    0.581867] Freeing unused kernel memory: 616k freed
[    0.581919] Write protecting the kernel read-only data: 6144k
[    0.583186] Freeing unused kernel memory: 500k freed
[    0.584487] Freeing unused kernel memory: 556k freed
[    0.591637] udevd[90]: starting version 175
[    0.599963] ACPI: bus type usb registered
[    0.599990] usbcore: registered new interface driver usbfs
[    0.599999] usbcore: registered new interface driver hub
[    0.602529] SCSI subsystem initialized
[    0.603381] ACPI: Fan [FAN0] (off)
[    0.603446] ACPI: bus type scsi registered
[    0.603482] usbcore: registered new device driver usb
[    0.603512] ACPI: Fan [FAN1] (off)
[    0.603617] ACPI: Fan [FAN2] (off)
[    0.603650] ACPI: Fan [FAN3] (off)
[    0.603691] ACPI: Fan [FAN4] (off)
[    0.603780] ehci_hcd: USB 2.0 'Enhanced' Host Controller (EHCI) Driver
[    0.603812] ehci_hcd 0000:00:1a.0: setting latency timer to 64
[    0.603815] ehci_hcd 0000:00:1a.0: EHCI Host Controller
[    0.603820] ehci_hcd 0000:00:1a.0: new USB bus registered, assigned bus
number 1
[    0.603833] ehci_hcd 0000:00:1a.0: debug port 2
[    0.605424] libata version 3.00 loaded.
[    0.605600] r8169 0000:03:00.0: irq 43 for MSI/MSI-X
[    0.605810] r8169 0000:03:00.0 eth0: RTL8168f/8111f at
0xffffc9000187c000, 10:bf:48:71:6b:97, XID 08000800 IRQ 43
[    0.605813] r8169 0000:03:00.0 eth0: jumbo features [frames: 9200
bytes, tx checksumming: ko]
[    0.607727] ehci_hcd 0000:00:1a.0: cache line size of 64 is not supported
[    0.607743] ehci_hcd 0000:00:1a.0: irq 16, io mem 0xf7c18000
[    0.617543] ehci_hcd 0000:00:1a.0: USB 2.0 started, EHCI 1.00
[    0.617569] usb usb1: New USB device found, idVendor=1d6b, idProduct=0002
[    0.617572] usb usb1: New USB device strings: Mfr=3, Product=2,
SerialNumber=1
[    0.617574] usb usb1: Product: EHCI Host Controller
[    0.617576] usb usb1: Manufacturer: Linux 3.7-trunk-amd64 ehci_hcd
[    0.617577] usb usb1: SerialNumber: 0000:00:1a.0
[    0.617751] hub 1-0:1.0: USB hub found
[    0.617756] hub 1-0:1.0: 2 ports detected
[    0.618019] ehci_hcd 0000:00:1d.0: setting latency timer to 64
[    0.618020] thermal LNXTHERM:00: registered as thermal_zone0
[    0.618022] ACPI: Thermal Zone [TZ00] (28 C)
[    0.618025] ehci_hcd 0000:00:1d.0: EHCI Host Controller
[    0.618029] ehci_hcd 0000:00:1d.0: new USB bus registered, assigned bus
number 2
[    0.618040] ehci_hcd 0000:00:1d.0: debug port 2
[    0.618132] thermal LNXTHERM:01: registered as thermal_zone1
[    0.618134] ACPI: Thermal Zone [TZ01] (30 C)
[    0.621933] ehci_hcd 0000:00:1d.0: cache line size of 64 is not supported
[    0.621947] ehci_hcd 0000:00:1d.0: irq 23, io mem 0xf7c17000
[    0.633524] ehci_hcd 0000:00:1d.0: USB 2.0 started, EHCI 1.00
[    0.633552] usb usb2: New USB device found, idVendor=1d6b, idProduct=0002
[    0.633555] usb usb2: New USB device strings: Mfr=3, Product=2,
SerialNumber=1
[    0.633557] usb usb2: Product: EHCI Host Controller
[    0.633559] usb usb2: Manufacturer: Linux 3.7-trunk-amd64 ehci_hcd
[    0.633561] usb usb2: SerialNumber: 0000:00:1d.0
[    0.633693] hub 2-0:1.0: USB hub found
[    0.633696] hub 2-0:1.0: 2 ports detected
[    0.633845] ahci 0000:00:1f.2: version 3.0
[    0.633911] ahci 0000:00:1f.2: irq 44 for MSI/MSI-X
[    0.633956] ahci 0000:00:1f.2: AHCI 0001.0300 32 slots 6 ports 6 Gbps
0x3 impl SATA mode
[    0.633959] ahci 0000:00:1f.2: flags: 64bit ncq led clo pio slum part
ems apst
[    0.633962] ahci 0000:00:1f.2: setting latency timer to 64
[    0.641890] scsi0 : ahci
[    0.642038] scsi1 : ahci
[    0.642115] scsi2 : ahci
[    0.642209] scsi3 : ahci
[    0.642302] scsi4 : ahci
[    0.642400] scsi5 : ahci
[    0.642427] ata1: SATA max UDMA/133 abar m2048@0xf7c16000 port
0xf7c16100 irq 44
[    0.642429] ata2: SATA max UDMA/133 abar m2048@0xf7c16000 port
0xf7c16180 irq 44
[    0.642430] ata3: DUMMY
[    0.642431] ata4: DUMMY
[    0.642431] ata5: DUMMY
[    0.642432] ata6: DUMMY
[    0.642509] xhci_hcd 0000:00:14.0: setting latency timer to 64
[    0.642512] xhci_hcd 0000:00:14.0: xHCI Host Controller
[    0.642518] xhci_hcd 0000:00:14.0: new USB bus registered, assigned bus
number 3
[    0.642634] xhci_hcd 0000:00:14.0: cache line size of 64 is not supported
[    0.642639] xhci_hcd 0000:00:14.0: irq 16, io mem 0xf7c00000
[    0.642682] xhci_hcd 0000:00:14.0: irq 45 for MSI/MSI-X
[    0.642719] usb usb3: New USB device found, idVendor=1d6b, idProduct=0002
[    0.642720] usb usb3: New USB device strings: Mfr=3, Product=2,
SerialNumber=1
[    0.642721] usb usb3: Product: xHCI Host Controller
[    0.642723] usb usb3: Manufacturer: Linux 3.7-trunk-amd64 xhci_hcd
[    0.642724] usb usb3: SerialNumber: 0000:00:14.0
[    0.642810] xHCI xhci_add_endpoint called for root hub
[    0.642812] xHCI xhci_check_bandwidth called for root hub
[    0.642832] hub 3-0:1.0: USB hub found
[    0.642839] hub 3-0:1.0: 4 ports detected
[    0.643151] xhci_hcd 0000:00:14.0: xHCI Host Controller
[    0.643154] xhci_hcd 0000:00:14.0: new USB bus registered, assigned bus
number 4
[    0.643170] usb usb4: New USB device found, idVendor=1d6b, idProduct=0003
[    0.643172] usb usb4: New USB device strings: Mfr=3, Product=2,
SerialNumber=1
[    0.643173] usb usb4: Product: xHCI Host Controller
[    0.643174] usb usb4: Manufacturer: Linux 3.7-trunk-amd64 xhci_hcd
[    0.643175] usb usb4: SerialNumber: 0000:00:14.0
[    0.643225] xHCI xhci_add_endpoint called for root hub
[    0.643226] xHCI xhci_check_bandwidth called for root hub
[    0.643242] hub 4-0:1.0: USB hub found
[    0.643248] hub 4-0:1.0: 4 ports detected
[    0.929251] usb 1-1: new high-speed USB device number 2 using ehci_hcd
[    0.961216] ata1: SATA link up 6.0 Gbps (SStatus 133 SControl 300)
[    0.961244] ata2: SATA link up 6.0 Gbps (SStatus 133 SControl 300)
[    0.961783] ACPI Error: [DSSP] Namespace lookup failure, AE_NOT_FOUND
(20120913/psargs-359)
[    0.961787] ACPI Error: Method parse/execution failed
[\_SB_.PCI0.SAT0.SPT0._GTF] (Node ffff8803eecb3998), AE_NOT_FOUND
(20120913/psparse-536)
[    0.961885] ACPI Error: [DSSP] Namespace lookup failure, AE_NOT_FOUND
(20120913/psargs-359)
[    0.961888] ACPI Error: Method parse/execution failed
[\_SB_.PCI0.SAT0.SPT1._GTF] (Node ffff8803eecb3920), AE_NOT_FOUND
(20120913/psparse-536)
[    0.962094] ata1.00: ATA-8: ST2000DM001-9YN164, CC4B, max UDMA/133
[    0.962099] ata1.00: 3907029168 sectors, multi 16: LBA48 NCQ (depth
31/32), AA
[    0.962235] ata1.00: failed to get Identify Device Data, Emask 0x1
[    0.962262] ata2.00: ATA-8: ST2000DM001-9YN164, CC4B, max UDMA/133
[    0.962265] ata2.00: 3907029168 sectors, multi 16: LBA48 NCQ (depth
31/32), AA
[    0.962428] ata2.00: failed to get Identify Device Data, Emask 0x1
[    0.962771] ACPI Error: [DSSP] Namespace lookup failure, AE_NOT_FOUND
(20120913/psargs-359)
[    0.962776] ACPI Error: Method parse/execution failed
[\_SB_.PCI0.SAT0.SPT0._GTF] (Node ffff8803eecb3998), AE_NOT_FOUND
(20120913/psparse-536)
[    0.962873] ACPI Error: [DSSP] Namespace lookup failure, AE_NOT_FOUND
(20120913/psargs-359)
[    0.962875] ACPI Error: Method parse/execution failed
[\_SB_.PCI0.SAT0.SPT1._GTF] (Node ffff8803eecb3920), AE_NOT_FOUND
(20120913/psparse-536)
[    0.963150] ata1.00: failed to get Identify Device Data, Emask 0x1
[    0.963154] ata1.00: configured for UDMA/133
[    0.963292] ata2.00: failed to get Identify Device Data, Emask 0x1
[    0.963296] ata2.00: configured for UDMA/133
[    0.963344] scsi 0:0:0:0: Direct-Access     ATA      ST2000DM001-9YN1
CC4B PQ: 0 ANSI: 5
[    0.963696] scsi 1:0:0:0: Direct-Access     ATA      ST2000DM001-9YN1
CC4B PQ: 0 ANSI: 5
[    0.963560] ACPI: Invalid Power Resource to register!
[    0.963914] ACPI: Invalid Power Resource to register!<5>[    0.966509]
sd 0:0:0:0: [sda] 3907029168 512-byte logical blocks: (2.00 TB/1.81 TiB)
[    0.966512] sd 0:0:0:0: [sda] 4096-byte physical blocks
[    0.966528] sd 1:0:0:0: [sdb] 3907029168 512-byte logical blocks: (2.00
TB/1.81 TiB)
[    0.966530] sd 1:0:0:0: [sdb] 4096-byte physical blocks
[    0.966543] sd 0:0:0:0: [sda] Write Protect is off
[    0.966545] sd 0:0:0:0: [sda] Mode Sense: 00 3a 00 00
[    0.966554] sd 0:0:0:0: [sda] Write cache: enabled, read cache:
enabled, doesn't support DPO or FUA
[    0.966580] sd 1:0:0:0: [sdb] Write Protect is off
[    0.966583] sd 1:0:0:0: [sdb] Mode Sense: 00 3a 00 00
[    0.966601] sd 1:0:0:0: [sdb] Write cache: enabled, read cache:
enabled, doesn't support DPO or FUA
[    0.974241] sd 0:0:0:0: Attached scsi generic sg0 type 0
[    0.974290] sd 1:0:0:0: Attached scsi generic sg1 type 0
[    0.984650]  sda: sda1
[    0.984650]  sdb: sdb1
[    0.984906] sd 0:0:0:0: [sda] Attached SCSI disk
[    0.984928] sd 1:0:0:0: [sdb] Attached SCSI disk
[    1.061508] usb 1-1: New USB device found, idVendor=8087, idProduct=0024
[    1.061513] usb 1-1: New USB device strings: Mfr=0, Product=0,
SerialNumber=0
[    1.061726] hub 1-1:1.0: USB hub found
[    1.061835] hub 1-1:1.0: 6 ports detected
[    1.075672] md: md0 stopped.
[    1.081618] md: bind<sdb1>
[    1.081762] md: bind<sda1>
[    1.082579] md: raid1 personality registered for level 1
[    1.082936] md/raid1:md0: active with 2 out of 2 mirrors
[    1.082947] md0: detected capacity change from 0 to 2000263380992
[    1.100596]  md0: unknown partition table
[    1.173004] usb 2-1: new high-speed USB device number 2 using ehci_hcd
[    1.284966] device-mapper: uevent: version 1.0.3
[    1.285028] device-mapper: ioctl: 4.23.0-ioctl (2012-07-25)
initialised: dm-devel@redhat.com
[    1.295834] bio: create slab <bio-1> at 1
[    1.305281] usb 2-1: New USB device found, idVendor=8087, idProduct=0024
[    1.305287] usb 2-1: New USB device strings: Mfr=0, Product=0,
SerialNumber=0
[    1.305512] hub 2-1:1.0: USB hub found
[    1.305613] hub 2-1:1.0: 8 ports detected
[    1.376911] usb 1-1.3: new high-speed USB device number 3 using ehci_hcd
[    1.443518] PM: Starting manual resume from disk
[    1.443521] PM: Hibernation image partition 253:1 present
[    1.443521] PM: Looking for hibernation image.
[    1.443711] PM: Image not found (code -22)
[    1.443714] PM: Hibernation image not present or could not be loaded.
[    1.471743] EXT4-fs (dm-0): mounted filesystem with ordered data mode.
Opts: (null)
[    1.540622] tsc: Refined TSC clocksource calibration: 3410.013 MHz
[    1.540628] Switching to clocksource tsc
[    2.107567] usb 1-1.3: New USB device found, idVendor=0bda, idProduct=0151
[    2.107572] usb 1-1.3: New USB device strings: Mfr=1, Product=2,
SerialNumber=3
[    2.107575] usb 1-1.3: Product: USB2.0-CRW
[    2.107577] usb 1-1.3: Manufacturer: Generic
[    2.107580] usb 1-1.3: SerialNumber: 20060413092100000
[    2.180120] usb 1-1.5: new high-speed USB device number 4 using ehci_hcd
[    2.276310] usb 1-1.5: New USB device found, idVendor=1c6b, idProduct=a223
[    2.276315] usb 1-1.5: New USB device strings: Mfr=1, Product=2,
SerialNumber=3
[    2.276318] usb 1-1.5: Product: Mass Storag Device
[    2.276320] usb 1-1.5: Manufacturer: USB2.0 External
[    2.276323] usb 1-1.5: SerialNumber: 010200027965
[    2.347989] usb 2-1.5: new low-speed USB device number 3 using ehci_hcd
[    2.356020] udevd[425]: starting version 175
[    2.445395] usb 2-1.5: New USB device found, idVendor=046d, idProduct=c063
[    2.445400] usb 2-1.5: New USB device strings: Mfr=1, Product=2,
SerialNumber=0
[    2.445403] usb 2-1.5: Product: DELL USB Laser Mouse
[    2.445405] usb 2-1.5: Manufacturer: DELL
[    2.515790] usb 2-1.6: new low-speed USB device number 4 using ehci_hcd
[    2.615192] usb 2-1.6: New USB device found, idVendor=045e, idProduct=0750
[    2.615196] usb 2-1.6: New USB device strings: Mfr=1, Product=2,
SerialNumber=0
[    2.615198] usb 2-1.6: Product: Wired Keyboard 600
[    2.615200] usb 2-1.6: Manufacturer: Microsoft
[    2.668857] input: Power Button as
/devices/LNXSYSTM:00/LNXSYBUS:00/PNP0C0C:00/input/input0
[    2.668863] ACPI: Power Button [PWRB]
[    2.668913] input: Power Button as
/devices/LNXSYSTM:00/LNXPWRBN:00/input/input1
[    2.668915] ACPI: Power Button [PWRF]
[    2.676260] input: PC Speaker as /devices/platform/pcspkr/input/input2
[    2.687626] usb 2-1.8: new high-speed USB device number 5 using ehci_hcd
[    2.694307] wmi: Mapper loaded
[    2.735336] mei 0000:00:16.0: setting latency timer to 64
[    2.735407] mei 0000:00:16.0: irq 46 for MSI/MSI-X
[    2.740481] mei 0000:00:16.0: wd: failed to find the client
[    2.743820] microcode: CPU0 sig=0x306a9, pf=0x2, revision=0x16
[    2.746948] ACPI: Requesting acpi_cpufreq
[    2.766948] asus_wmi: ASUS WMI generic driver loaded
[    2.767647] asus_wmi: Initialization: 0x0asus_wmi: BIOS WMI version: 0.9
[    2.767685] asus_wmi: SFUN value: 0x0<6>[    2.767884] input: Eee PC
WMI hotkeys as /devices/platform/eeepc-wmi/input/input3
[    2.768377] asus_wmi: Backlight controlled by ACPI video driver
[    2.783530] usb 2-1.8: New USB device found, idVendor=13fe, idProduct=1a00
[    2.783535] usb 2-1.8: New USB device strings: Mfr=1, Product=2,
SerialNumber=3
[    2.783538] usb 2-1.8: Product: DataTraveler 2.0
[    2.783540] usb 2-1.8: Manufacturer: Kingston
[    2.783543] usb 2-1.8: SerialNumber: 5B6A1B836AD3
[    2.788366] ACPI Warning: 0x000000000000f040-0x000000000000f05f
SystemIO conflicts with Region \_SB_.PCI0.SBUS.SMBI 1
(20120913/utaddress-251)
[    2.788370] ACPI: If an ACPI driver is available for this device, you
should use it instead of the native driver
[    2.829641] ACPI Warning: 0x0000000000000428-0x000000000000042f
SystemIO conflicts with Region \PMIO 1 (20120913/utaddress-251)
[    2.829645] ACPI: If an ACPI driver is available for this device, you
should use it instead of the native driver
[    2.829648] ACPI Warning: 0x0000000000000530-0x000000000000053f
SystemIO conflicts with Region \GPIO 1 (20120913/utaddress-251)
[    2.829650] ACPI Warning: 0x0000000000000530-0x000000000000053f
SystemIO conflicts with Region \_SB_.PCI0.LPCB.GPBX 2
(20120913/utaddress-251)
[    2.829652] ACPI: If an ACPI driver is available for this device, you
should use it instead of the native driver
[    2.829653] ACPI Warning: 0x0000000000000500-0x000000000000052f
SystemIO conflicts with Region \GPIO 1 (20120913/utaddress-251)
[    2.829655] ACPI Warning: 0x0000000000000500-0x000000000000052f
SystemIO conflicts with Region \_SB_.PCI0.LPCB.GPBX 2
(20120913/utaddress-251)
[    2.829657] ACPI: If an ACPI driver is available for this device, you
should use it instead of the native driver
[    2.829658] lpc_ich: Resource conflict(s) found affecting gpio_ich
[    2.857902] iTCO_vendor_support: vendor-support=0
[    2.859702] iTCO_wdt: Intel TCO WatchDog Timer Driver v1.10
[    2.859722] iTCO_wdt: Found a Panther Point TCO device (Version=2,
TCOBASE=0x0460)
[    2.859804] iTCO_wdt: initialized. heartbeat=30 sec (nowayout=0)
[    2.885161] platform microcode: firmware: agent aborted loading
intel-ucode/06-3a-09 (not found?)
[    2.885237] microcode: CPU1 sig=0x306a9, pf=0x2, revision=0x16
[    2.886273] platform microcode: firmware: agent aborted loading
intel-ucode/06-3a-09 (not found?)
[    2.886348] microcode: CPU2 sig=0x306a9, pf=0x2, revision=0x16
[    2.887402] platform microcode: firmware: agent aborted loading
intel-ucode/06-3a-09 (not found?)
[    2.887476] microcode: CPU3 sig=0x306a9, pf=0x2, revision=0x16
[    2.888438] platform microcode: firmware: agent aborted loading
intel-ucode/06-3a-09 (not found?)
[    2.888513] microcode: CPU4 sig=0x306a9, pf=0x2, revision=0x16
[    2.889486] platform microcode: firmware: agent aborted loading
intel-ucode/06-3a-09 (not found?)
[    2.889555] microcode: CPU5 sig=0x306a9, pf=0x2, revision=0x16
[    2.890570] platform microcode: firmware: agent aborted loading
intel-ucode/06-3a-09 (not found?)
[    2.890645] microcode: CPU6 sig=0x306a9, pf=0x2, revision=0x16
[    2.891685] platform microcode: firmware: agent aborted loading
intel-ucode/06-3a-09 (not found?)
[    2.891761] microcode: CPU7 sig=0x306a9, pf=0x2, revision=0x16
[    2.892828] platform microcode: firmware: agent aborted loading
intel-ucode/06-3a-09 (not found?)
[    2.892941] microcode: Microcode Update Driver: v2.00
<tigran@aivazian.fsnet.co.uk>, Peter Oruba
[    3.016663] [drm] Initialized drm 1.1.0 20060810
[    3.054538] pci 0000:00:00.0: Intel Ivybridge Chipset
[    3.054574] pci 0000:00:00.0: detected gtt size: 2097152K total,
262144K mappable
[    3.055511] pci 0000:00:00.0: detected 262144K stolen memory
[    3.055554] i915 0000:00:02.0: setting latency timer to 64
[    3.069239] i915 0000:00:02.0: irq 47 for MSI/MSI-X
[    3.069244] [drm] Supports vblank timestamp caching Rev 1 (10.10.2010).
[    3.069244] [drm] Driver supports precise vblank timestamp query.
[    3.069301] vgaarb: device changed decodes:
PCI:0000:00:02.0,olddecodes=io+mem,decodes=io+mem:owns=io+mem
[    3.075947] alg: No test for __gcm-aes-aesni (__driver-gcm-aes-aesni)
[    3.101646] [drm] Enabling RC6 states: RC6 on, RC6p on, RC6pp off
[    3.211354] Initializing USB Mass Storage driver...
[    3.211418] scsi6 : usb-storage 1-1.3:1.0
[    3.211562] scsi7 : usb-storage 1-1.5:1.0
[    3.211771] scsi8 : usb-storage 2-1.8:1.0
[    3.211860] usbcore: registered new interface driver usb-storage
[    3.211862] USB Mass Storage support registered.
[    3.246381] usbcore: registered new interface driver usbhid
[    3.246384] usbhid: USB HID core driver
[    3.276297] input: DELL DELL USB Laser Mouse as
/devices/pci0000:00/0000:00:1d.0/usb2/2-1/2-1.5/2-1.5:1.0/input/input4
[    3.276523] hid-generic 0003:046D:C063.0001: input,hidraw0: USB HID
v1.10 Mouse [DELL DELL USB Laser Mouse] on usb-0000:00:1d.0-1.5/input0
[    3.276639] input: Microsoft Wired Keyboard 600 as
/devices/pci0000:00/0000:00:1d.0/usb2/2-1/2-1.6/2-1.6:1.0/input/input5
[    3.276758] hid-generic 0003:045E:0750.0002: input,hidraw1: USB HID
v1.11 Keyboard [Microsoft Wired Keyboard 600] on
usb-0000:00:1d.0-1.6/input0
[    3.278637] input: Microsoft Wired Keyboard 600 as
/devices/pci0000:00/0000:00:1d.0/usb2/2-1/2-1.6/2-1.6:1.1/input/input6
[    3.278702] hid-generic 0003:045E:0750.0003: input,hidraw2: USB HID
v1.11 Device [Microsoft Wired Keyboard 600] on usb-0000:00:1d.0-1.6/input1
[    3.404034] fbcon: inteldrmfb (fb0) is primary device
[    3.636087] Console: switching to colour frame buffer device 240x67
[    3.645476] fb0: inteldrmfb frame buffer device
[    3.645477] drm: registered panic notifier
[    3.667120] acpi device:47: registered as cooling_device13
[    3.667325] ACPI: Video Device [GFX0] (multi-head: yes  rom: no  post: no)
[    3.667387] input: Video Bus as
/devices/LNXSYSTM:00/LNXSYBUS:00/PNP0A08:00/LNXVIDEO:00/input/input7
[    3.667516] [drm] Initialized i915 1.6.0 20080730 for 0000:00:02.0 on
minor 0
[    3.667692] snd_hda_intel 0000:00:1b.0: irq 48 for MSI/MSI-X
[    3.708556] input: HDA Digital PCBeep as
/devices/pci0000:00/0000:00:1b.0/input/input8
[    3.726782] input: HDA Intel PCH HDMI/DP,pcm=3 as
/devices/pci0000:00/0000:00:1b.0/sound/card0/input9
[    3.726879] input: HDA Intel PCH Line as
/devices/pci0000:00/0000:00:1b.0/sound/card0/input10
[    3.726960] input: HDA Intel PCH Front Mic as
/devices/pci0000:00/0000:00:1b.0/sound/card0/input11
[    3.727040] input: HDA Intel PCH Rear Mic as
/devices/pci0000:00/0000:00:1b.0/sound/card0/input12
[    3.727117] input: HDA Intel PCH Front Headphone as
/devices/pci0000:00/0000:00:1b.0/sound/card0/input13
[    3.727198] input: HDA Intel PCH Line Out as
/devices/pci0000:00/0000:00:1b.0/sound/card0/input14
[    4.210724] scsi 8:0:0:0: Direct-Access     Kingston DataTraveler 2.0
PMAP PQ: 0 ANSI: 0 CCS
[    4.215189] scsi 7:0:0:0: CD-ROM            Slimtype eNAU108   5     
8L71 PQ: 0 ANSI: 0
[    4.216537] scsi 6:0:0:0: Direct-Access     Generic- Compact Flash   
1.00 PQ: 0 ANSI: 0 CCS
[    4.222783] scsi 6:0:0:1: Direct-Access     Generic- SM/xD-Picture   
1.00 PQ: 0 ANSI: 0 CCS
[    4.229170] scsi 6:0:0:2: Direct-Access     Generic- SD/MMC          
1.00 PQ: 0 ANSI: 0 CCS
[    4.235692] scsi 6:0:0:3: Direct-Access     Generic- MS/MS-Pro       
1.00 PQ: 0 ANSI: 0 CCS
[    4.236742] sd 6:0:0:0: Attached scsi generic sg2 type 0
[    4.237045] sd 6:0:0:1: Attached scsi generic sg3 type 0
[    4.237391] sd 6:0:0:2: Attached scsi generic sg4 type 0
[    4.237922] sd 6:0:0:3: Attached scsi generic sg5 type 0
[    4.238607] sd 8:0:0:0: Attached scsi generic sg6 type 0
[    4.238864] scsi 7:0:0:0: Attached scsi generic sg7 type 5
[    4.239372] sd 8:0:0:0: [sdg] 4030464 512-byte logical blocks: (2.06
GB/1.92 GiB)
[    4.239904] sd 8:0:0:0: [sdg] Write Protect is off
[    4.239910] sd 8:0:0:0: [sdg] Mode Sense: 23 00 00 00
[    4.240751] sd 8:0:0:0: [sdg] No Caching mode page present
[    4.240813] sd 8:0:0:0: [sdg] Assuming drive cache: write through
[    4.242863] sd 6:0:0:0: [sdc] Attached SCSI removable disk
[    4.243747] sd 6:0:0:1: [sdd] Attached SCSI removable disk
[    4.244229] sd 8:0:0:0: [sdg] No Caching mode page present
[    4.244277] sd 8:0:0:0: [sdg] Assuming drive cache: write through
[    4.245109] sd 6:0:0:2: [sde] Attached SCSI removable disk
[    4.245635]  sdg: sdg1
[    4.245863] sd 6:0:0:3: [sdf] Attached SCSI removable disk
[    4.247739] sd 8:0:0:0: [sdg] No Caching mode page present
[    4.247804] sd 8:0:0:0: [sdg] Assuming drive cache: write through
[    4.247872] sd 8:0:0:0: [sdg] Attached SCSI removable disk
[    4.285066] sr0: scsi3-mmc drive: 24x/24x writer dvd-ram cd/rw xa/form2
cdda tray
[    4.285072] cdrom: Uniform CD-ROM driver Revision: 3.20
[    4.285227] sr 7:0:0:0: Attached scsi CD-ROM sr0
[    5.025539] EXT4-fs (dm-0): re-mounted. Opts: (null)
[    5.409035] EXT4-fs (dm-0): re-mounted. Opts: errors=remount-ro
[    5.482200] loop: module loaded
[    5.866732] Adding 15622140k swap on /dev/mapper/glaukopis-swap. 
Priority:-1 extents:1 across:15622140k
[    6.963139] EXT4-fs (sdg1): mounted filesystem with ordered data mode.
Opts: (null)
[    7.063964] EXT4-fs (dm-4): mounted filesystem with ordered data mode.
Opts: (null)
[    7.101677] EXT4-fs (dm-2): mounted filesystem with ordered data mode.
Opts: (null)
[    7.151829] EXT4-fs (dm-3): mounted filesystem with ordered data mode.
Opts: (null)
[    8.275576] RPC: Registered named UNIX socket transport module.
[    8.275578] RPC: Registered udp transport module.
[    8.275579] RPC: Registered tcp transport module.
[    8.275579] RPC: Registered tcp NFSv4.1 backchannel transport module.
[    8.284971] FS-Cache: Loaded
[    8.292319] Key type dns_resolver registered
[    8.312115] FS-Cache: Netfs 'nfs' registered for caching
[    8.330323] Installing knfsd (copyright (C) 1996 okir@monad.swb.de).
[   11.254321] r8169 0000:03:00.0: firmware: agent loaded
rtl_nic/rtl8168f-1.fw into memory
[   11.365904] r8169 0000:03:00.0 eth0: link down
[   11.365956] r8169 0000:03:00.0 eth0: link down
[   11.365973] IPv6: ADDRCONF(NETDEV_UP): eth0: link is not ready
[   13.596159] r8169 0000:03:00.0 eth0: link up
[   13.596170] IPv6: ADDRCONF(NETDEV_CHANGE): eth0: link becomes ready
