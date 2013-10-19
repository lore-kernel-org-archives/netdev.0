From: Thomas Glanzmann <thomas@glanzmann.de>
Subject: [BUG] v3.12-rc5-139-gbdeeab6 assertion failed at
 drivers/net/bonding/bond_main.c (3398)
Date: Sat, 19 Oct 2013 22:27:02 +0200
Message-ID: <20131019202702.GA8354@glanzmann.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jay Vosburgh <fubar@us.ibm.com>,
	Andy Gospodarek <andy@greyhouse.net>,
	Nikolay Aleksandrov <nikolay@redhat.com>,
	Veaceslav Falico <vfalico@redhat.com>,
	"David S. Miller" <davem@davemloft.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from infra.glanzmann.de ([78.47.70.69]:39483 "EHLO
	infra.glanzmann.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751318Ab3JSUdu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 19 Oct 2013 16:33:50 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello,
I'm referring to commit 7864a1adf7291993d74923fdd0a45459ce9da27e. I just
checked out the tip from Linus tree compiled it and run it on Debian Wheezy
with 4 1 GBIT NICs, two connected to one switch and two to another. I
configured bonding to use tlb. On the ports is one untagged and one
tagged VLAN. When I boot the kernel even if only one NIC is attached I
get multiple failed assertions:

[    0.000000] Initializing cgroup subsys cpuset
[    0.000000] Initializing cgroup subsys cpu
[    0.000000] Initializing cgroup subsys cpuacct
[    0.000000] Linux version 3.12.0-rc5+ (sithglan@infra) (gcc version 4.7.2 (Debian 4.7.2-5) ) #1 SMP Sat Oct 19 20:15:20 CEST 2013
[    0.000000] Command line: BOOT_IMAGE=/vmlinuz-3.12.0-rc5+ root=UUID=80f5fc61-60ba-4e3d-8d3a-2a51e4e4a5bc ro
[    0.000000] e820: BIOS-provided physical RAM map:
[    0.000000] BIOS-e820: [mem 0x0000000000000000-0x000000000009abff] usable
[    0.000000] BIOS-e820: [mem 0x000000000009ac00-0x000000000009ffff] reserved
[    0.000000] BIOS-e820: [mem 0x00000000000e0000-0x00000000000fffff] reserved
[    0.000000] BIOS-e820: [mem 0x0000000000100000-0x000000007dfe9fff] usable
[    0.000000] BIOS-e820: [mem 0x000000007dfea000-0x000000007e026fff] reserved
[    0.000000] BIOS-e820: [mem 0x000000007e027000-0x000000007e2c2fff] ACPI NVS
[    0.000000] BIOS-e820: [mem 0x000000007e2c3000-0x000000007f36bfff] reserved
[    0.000000] BIOS-e820: [mem 0x000000007f36c000-0x000000007f7fffff] ACPI NVS
[    0.000000] BIOS-e820: [mem 0x0000000080000000-0x000000008fffffff] reserved
[    0.000000] BIOS-e820: [mem 0x00000000fed1c000-0x00000000fed3ffff] reserved
[    0.000000] BIOS-e820: [mem 0x00000000ff000000-0x00000000ffffffff] reserved
[    0.000000] BIOS-e820: [mem 0x0000000100000000-0x000000107fffffff] usable
[    0.000000] NX (Execute Disable) protection: active
[    0.000000] SMBIOS 2.7 present.
[    0.000000] DMI: Supermicro X9SRD-F/X9SRD-F, BIOS 1.0a 10/15/2012
[    0.000000] e820: update [mem 0x00000000-0x00000fff] usable ==> reserved
[    0.000000] e820: remove [mem 0x000a0000-0x000fffff] usable
[    0.000000] No AGP bridge found
[    0.000000] e820: last_pfn = 0x1080000 max_arch_pfn = 0x400000000
[    0.000000] MTRR default type: uncachable
[    0.000000] MTRR fixed ranges enabled:
[    0.000000]   00000-9FFFF write-back
[    0.000000]   A0000-BFFFF uncachable
[    0.000000]   C0000-FFFFF write-protect
[    0.000000] MTRR variable ranges enabled:
[    0.000000]   0 base 000000000000 mask 3FF000000000 write-back
[    0.000000]   1 base 001000000000 mask 3FFF80000000 write-back
[    0.000000]   2 base 000080000000 mask 3FFF80000000 uncachable
[    0.000000]   3 disabled
[    0.000000]   4 disabled
[    0.000000]   5 disabled
[    0.000000]   6 disabled
[    0.000000]   7 disabled
[    0.000000]   8 disabled
[    0.000000]   9 disabled
[    0.000000] x86 PAT enabled: cpu 0, old 0x7040600070406, new 0x7010600070106
[    0.000000] e820: update [mem 0x80000000-0xffffffff] usable ==> reserved
[    0.000000] e820: last_pfn = 0x7dfea max_arch_pfn = 0x400000000
[    0.000000] found SMP MP-table at [mem 0x000fd840-0x000fd84f] mapped at [ffff8800000fd840]
[    0.000000] Base memory trampoline at [ffff880000094000] 94000 size 24576
[    0.000000] Using GB pages for direct mapping
[    0.000000] init_memory_mapping: [mem 0x00000000-0x000fffff]
[    0.000000]  [mem 0x00000000-0x000fffff] page 4k
[    0.000000] BRK [0x01853000, 0x01853fff] PGTABLE
[    0.000000] BRK [0x01854000, 0x01854fff] PGTABLE
[    0.000000] BRK [0x01855000, 0x01855fff] PGTABLE
[    0.000000] init_memory_mapping: [mem 0x107fe00000-0x107fffffff]
[    0.000000]  [mem 0x107fe00000-0x107fffffff] page 1G
[    0.000000] init_memory_mapping: [mem 0x107c000000-0x107fdfffff]
[    0.000000]  [mem 0x107c000000-0x107fdfffff] page 1G
[    0.000000] init_memory_mapping: [mem 0x1000000000-0x107bffffff]
[    0.000000]  [mem 0x1000000000-0x107bffffff] page 1G
[    0.000000] init_memory_mapping: [mem 0x00100000-0x7dfe9fff]
[    0.000000]  [mem 0x00100000-0x001fffff] page 4k
[    0.000000]  [mem 0x00200000-0x7ddfffff] page 2M
[    0.000000]  [mem 0x7de00000-0x7dfe9fff] page 4k
[    0.000000] init_memory_mapping: [mem 0x100000000-0xfffffffff]
[    0.000000]  [mem 0x100000000-0xfffffffff] page 1G
[    0.000000] RAMDISK: [mem 0x36938000-0x37493fff]
[    0.000000] ACPI: RSDP 00000000000f0490 00024 (v02 SUPERM)
[    0.000000] ACPI: XSDT 000000007e245088 0008C (v01 \xffffffff\xffffffff\xffffffff\xffffffff\xffffffff\xffffffff \xffffffff\xffffffff\xffffffff\xffffffff\xffffffff\xffffffff\xffffffff\xffffffff 00000001 AMI  00010013)
[    0.000000] ACPI: FACP 000000007e24e7d8 000F4 (v04 \xffffffff\xffffffff\xffffffff\xffffffff\xffffffff\xffffffff \xffffffff\xffffffff\xffffffff\xffffffff\xffffffff\xffffffff\xffffffff\xffffffff 00000001 AMI  00010013)
[    0.000000] ACPI: DSDT 000000007e2451a8 09629 (v02 \xffffffff\xffffffff\xffffffff\xffffffff\xffffffff\xffffffff \xffffffff\xffffffff\xffffffff\xffffffff\xffffffff\xffffffff\xffffffff\xffffffff 00000000 INTL 20091112)
[    0.000000] ACPI: FACS 000000007e2c0f80 00040
[    0.000000] ACPI: APIC 000000007e24e8d0 00100 (v03                 00000001 AMI  00010013)
[    0.000000] ACPI: FPDT 000000007e24e9d0 00044 (v01                 00000001 AMI  00010013)
[    0.000000] ACPI: HPET 000000007e24ea18 00038 (v01 SUPERM SMCI--MB 00000001 AMI. 00000005)
[    0.000000] ACPI: PRAD 000000007e24ea50 000BE (v02 PRADID  PRADTID 00000001 MSFT 04000000)
[    0.000000] ACPI: SPMI 000000007e24eb10 00040 (v05 A M I   OEMSPMI 00000000 AMI. 00000000)
[    0.000000] ACPI: SSDT 000000007e24eb50 6B344 (v02  INTEL    CpuPm 00004000 INTL 20091112)
[    0.000000] ACPI: EINJ 000000007e2b9e98 00130 (v01    AMI AMI EINJ 00000000      00000000)
[    0.000000] ACPI: ERST 000000007e2b9fc8 00230 (v01  AMIER AMI ERST 00000000      00000000)
[    0.000000] ACPI: HEST 000000007e2ba1f8 000A8 (v01    AMI AMI HEST 00000000      00000000)
[    0.000000] ACPI: BERT 000000007e2ba2a0 00030 (v01    AMI AMI BERT 00000000      00000000)
[    0.000000] ACPI: DMAR 000000007e2ba2d0 000CC (v01 A M I   OEMDMAR 00000001 INTL 00000001)
[    0.000000] ACPI: MCFG 000000007e2ba3a0 0003C (v01 SUPERM SMCI--MB 00000001 MSFT 00000097)
[    0.000000] ACPI: Local APIC address 0xfee00000
[    0.000000] No NUMA configuration found
[    0.000000] Faking a node at [mem 0x0000000000000000-0x000000107fffffff]
[    0.000000] Initmem setup node 0 [mem 0x00000000-0x107fffffff]
[    0.000000]   NODE_DATA [mem 0x107fffa000-0x107fffdfff]
[    0.000000]  [ffffea0000000000-ffffea0039bfffff] PMD -> [ffff88103f600000-ffff8810775fffff] on node 0
[    0.000000] Zone ranges:
[    0.000000]   DMA      [mem 0x00001000-0x00ffffff]
[    0.000000]   DMA32    [mem 0x01000000-0xffffffff]
[    0.000000]   Normal   [mem 0x100000000-0x107fffffff]
[    0.000000] Movable zone start for each node
[    0.000000] Early memory node ranges
[    0.000000]   node   0: [mem 0x00001000-0x00099fff]
[    0.000000]   node   0: [mem 0x00100000-0x7dfe9fff]
[    0.000000]   node   0: [mem 0x100000000-0x107fffffff]
[    0.000000] On node 0 totalpages: 16768899
[    0.000000]   DMA zone: 56 pages used for memmap
[    0.000000]   DMA zone: 21 pages reserved
[    0.000000]   DMA zone: 3993 pages, LIFO batch:0
[    0.000000]   DMA32 zone: 7000 pages used for memmap
[    0.000000]   DMA32 zone: 511978 pages, LIFO batch:31
[    0.000000]   Normal zone: 222208 pages used for memmap
[    0.000000]   Normal zone: 16252928 pages, LIFO batch:31
[    0.000000] ACPI: PM-Timer IO Port: 0x408
[    0.000000] ACPI: Local APIC address 0xfee00000
[    0.000000] ACPI: LAPIC (acpi_id[0x00] lapic_id[0x00] enabled)
[    0.000000] ACPI: LAPIC (acpi_id[0x02] lapic_id[0x02] enabled)
[    0.000000] ACPI: LAPIC (acpi_id[0x04] lapic_id[0x04] enabled)
[    0.000000] ACPI: LAPIC (acpi_id[0x06] lapic_id[0x06] enabled)
[    0.000000] ACPI: LAPIC (acpi_id[0x08] lapic_id[0x08] enabled)
[    0.000000] ACPI: LAPIC (acpi_id[0x0a] lapic_id[0x0a] enabled)
[    0.000000] ACPI: LAPIC (acpi_id[0x01] lapic_id[0x01] enabled)
[    0.000000] ACPI: LAPIC (acpi_id[0x03] lapic_id[0x03] enabled)
[    0.000000] ACPI: LAPIC (acpi_id[0x05] lapic_id[0x05] enabled)
[    0.000000] ACPI: LAPIC (acpi_id[0x07] lapic_id[0x07] enabled)
[    0.000000] ACPI: LAPIC (acpi_id[0x09] lapic_id[0x09] enabled)
[    0.000000] ACPI: LAPIC (acpi_id[0x0b] lapic_id[0x0b] enabled)
[    0.000000] ACPI: LAPIC_NMI (acpi_id[0x00] high edge lint[0x1])
[    0.000000] ACPI: LAPIC_NMI (acpi_id[0x02] high edge lint[0x1])
[    0.000000] ACPI: LAPIC_NMI (acpi_id[0x04] high edge lint[0x1])
[    0.000000] ACPI: LAPIC_NMI (acpi_id[0x06] high edge lint[0x1])
[    0.000000] ACPI: LAPIC_NMI (acpi_id[0x08] high edge lint[0x1])
[    0.000000] ACPI: LAPIC_NMI (acpi_id[0x0a] high edge lint[0x1])
[    0.000000] ACPI: LAPIC_NMI (acpi_id[0x01] high edge lint[0x1])
[    0.000000] ACPI: LAPIC_NMI (acpi_id[0x03] high edge lint[0x1])
[    0.000000] ACPI: LAPIC_NMI (acpi_id[0x05] high edge lint[0x1])
[    0.000000] ACPI: LAPIC_NMI (acpi_id[0x07] high edge lint[0x1])
[    0.000000] ACPI: LAPIC_NMI (acpi_id[0x09] high edge lint[0x1])
[    0.000000] ACPI: LAPIC_NMI (acpi_id[0x0b] high edge lint[0x1])
[    0.000000] ACPI: IOAPIC (id[0x00] address[0xfec00000] gsi_base[0])
[    0.000000] IOAPIC[0]: apic_id 0, version 32, address 0xfec00000, GSI 0-23
[    0.000000] ACPI: IOAPIC (id[0x02] address[0xfec01000] gsi_base[24])
[    0.000000] IOAPIC[1]: apic_id 2, version 32, address 0xfec01000, GSI 24-47
[    0.000000] ACPI: INT_SRC_OVR (bus 0 bus_irq 0 global_irq 2 dfl dfl)
[    0.000000] ACPI: INT_SRC_OVR (bus 0 bus_irq 9 global_irq 9 high level)
[    0.000000] ACPI: IRQ0 used by override.
[    0.000000] ACPI: IRQ2 used by override.
[    0.000000] ACPI: IRQ9 used by override.
[    0.000000] Using ACPI (MADT) for SMP configuration information
[    0.000000] ACPI: HPET id: 0x8086a701 base: 0xfed00000
[    0.000000] smpboot: Allowing 12 CPUs, 0 hotplug CPUs
[    0.000000] nr_irqs_gsi: 64
[    0.000000] PM: Registered nosave memory: [mem 0x0009a000-0x0009afff]
[    0.000000] PM: Registered nosave memory: [mem 0x0009b000-0x0009ffff]
[    0.000000] PM: Registered nosave memory: [mem 0x000a0000-0x000dffff]
[    0.000000] PM: Registered nosave memory: [mem 0x000e0000-0x000fffff]
[    0.000000] PM: Registered nosave memory: [mem 0x7dfea000-0x7e026fff]
[    0.000000] PM: Registered nosave memory: [mem 0x7e027000-0x7e2c2fff]
[    0.000000] PM: Registered nosave memory: [mem 0x7e2c3000-0x7f36bfff]
[    0.000000] PM: Registered nosave memory: [mem 0x7f36c000-0x7f7fffff]
[    0.000000] PM: Registered nosave memory: [mem 0x7f800000-0x7fffffff]
[    0.000000] PM: Registered nosave memory: [mem 0x80000000-0x8fffffff]
[    0.000000] PM: Registered nosave memory: [mem 0x90000000-0xfed1bfff]
[    0.000000] PM: Registered nosave memory: [mem 0xfed1c000-0xfed3ffff]
[    0.000000] PM: Registered nosave memory: [mem 0xfed40000-0xfeffffff]
[    0.000000] PM: Registered nosave memory: [mem 0xff000000-0xffffffff]
[    0.000000] e820: [mem 0x90000000-0xfed1bfff] available for PCI devices
[    0.000000] setup_percpu: NR_CPUS:512 nr_cpumask_bits:512 nr_cpu_ids:12 nr_node_ids:1
[    0.000000] PERCPU: Embedded 27 pages/cpu @ffff88107fc00000 s80704 r8192 d21696 u131072
[    0.000000] pcpu-alloc: s80704 r8192 d21696 u131072 alloc=1*2097152
[    0.000000] pcpu-alloc: [0] 00 01 02 03 04 05 06 07 08 09 10 11 -- -- -- -- 
[    0.000000] Built 1 zonelists in Zone order, mobility grouping on.  Total pages: 16539614
[    0.000000] Policy zone: Normal
[    0.000000] Kernel command line: BOOT_IMAGE=/vmlinuz-3.12.0-rc5+ root=UUID=80f5fc61-60ba-4e3d-8d3a-2a51e4e4a5bc ro
[    0.000000] PID hash table entries: 4096 (order: 3, 32768 bytes)
[    0.000000] xsave: enabled xstate_bv 0x7, cntxt size 0x340
[    0.000000] Checking aperture...
[    0.000000] No AGP bridge found
[    0.000000] Calgary: detecting Calgary via BIOS EBDA area
[    0.000000] Calgary: Unable to locate Rio Grande table in EBDA - bailing!
[    0.000000] Memory: 66070184K/67075596K available (3584K kernel code, 607K rwdata, 1512K rodata, 872K init, 876K bss, 1005412K reserved)
[    0.000000] Hierarchical RCU implementation.
[    0.000000] 	RCU dyntick-idle grace-period acceleration is enabled.
[    0.000000] 	RCU restricting CPUs from NR_CPUS=512 to nr_cpu_ids=12.
[    0.000000] NR_IRQS:33024 nr_irqs:1184 16
[    0.000000] Console: colour VGA+ 80x25
[    0.000000] console [tty0] enabled
[    0.000000] hpet clockevent registered
[    0.000000] tsc: Fast TSC calibration using PIT
[    0.004000] tsc: Detected 1999.978 MHz processor
[    0.000004] Calibrating delay loop (skipped), value calculated using timer frequency.. 3999.95 BogoMIPS (lpj=7999912)
[    0.000145] pid_max: default: 32768 minimum: 301
[    0.000250] Security Framework initialized
[    0.000321] AppArmor: AppArmor disabled by boot time parameter
[    0.005209] Dentry cache hash table entries: 8388608 (order: 14, 67108864 bytes)
[    0.020973] Inode-cache hash table entries: 4194304 (order: 13, 33554432 bytes)
[    0.027672] Mount-cache hash table entries: 256
[    0.027980] Initializing cgroup subsys devices
[    0.028052] Initializing cgroup subsys freezer
[    0.028122] Initializing cgroup subsys net_cls
[    0.028192] Initializing cgroup subsys blkio
[    0.028261] Initializing cgroup subsys perf_event
[    0.028357] CPU: Physical Processor ID: 0
[    0.028425] CPU: Processor Core ID: 0
[    0.028519] mce: CPU supports 18 MCE banks
[    0.028618] CPU0: Thermal monitoring enabled (TM1)
[    0.028708] Last level iTLB entries: 4KB 512, 2MB 0, 4MB 0
[    0.028708] Last level dTLB entries: 4KB 512, 2MB 32, 4MB 32
[    0.028708] tlb_flushall_shift: 5
[    0.028929] Freeing SMP alternatives memory: 12K (ffffffff81773000 - ffffffff81776000)
[    0.029019] ACPI: Core revision 20130725
[    0.053605] ACPI: All ACPI Tables successfully acquired
[    0.054045] dmar: Host address width 46
[    0.054114] dmar: DRHD base: 0x000000fbffc000 flags: 0x1
[    0.054191] dmar: IOMMU 0: reg_base_addr fbffc000 ver 1:0 cap d2078c106f0462 ecap f020fe
[    0.054280] dmar: RMRR base: 0x0000007dffd000 end: 0x0000007e009fff
[    0.054352] dmar: ATSR flags: 0x0
[    0.054419] dmar: RHSA base: 0x000000fbffc000 proximity domain: 0x0
[    0.054586] IOAPIC id 0 under DRHD base  0xfbffc000 IOMMU 0
[    0.054658] IOAPIC id 2 under DRHD base  0xfbffc000 IOMMU 0
[    0.054729] HPET id 0 under DRHD base 0xfbffc000
[    0.054927] Enabled IRQ remapping in x2apic mode
[    0.054996] Enabling x2apic
[    0.055061] Enabled x2apic
[    0.055131] Switched APIC routing to cluster x2apic.
[    0.055744] ..TIMER: vector=0x30 apic1=0 pin1=2 apic2=-1 pin2=-1
[    0.095498] smpboot: CPU0: Intel(R) Xeon(R) CPU E5-2630L 0 @ 2.00GHz (fam: 06, model: 2d, stepping: 07)
[    0.095735] TSC deadline timer enabled
[    0.095744] Performance Events: PEBS fmt1+, 16-deep LBR, SandyBridge events, full-width counters, Intel PMU driver.
[    0.096078] ... version:                3
[    0.096145] ... bit width:              48
[    0.101511] ... generic registers:      4
[    0.101579] ... value mask:             0000ffffffffffff
[    0.101649] ... max period:             0000ffffffffffff
[    0.101718] ... fixed-purpose events:   3
[    0.101786] ... event mask:             000000070000000f
[    0.116326] NMI watchdog: enabled on all CPUs, permanently consumes one hw-PMU counter.
[    0.102246] smpboot: Booting Node   0, Processors  #   1 #   2 #   3 #   4 #   5 #   6 #   7 #   8 #   9 #  10 #  11 OK
[    0.248878] Brought up 12 CPUs
[    0.248949] smpboot: Total of 12 processors activated (47999.47 BogoMIPS)
[    0.267646] devtmpfs: initialized
[    0.281269] PM: Registering ACPI NVS region [mem 0x7e027000-0x7e2c2fff] (2736128 bytes)
[    0.281497] PM: Registering ACPI NVS region [mem 0x7f36c000-0x7f7fffff] (4800512 bytes)
[    0.282080] regulator-dummy: no parameters
[    0.282240] NET: Registered protocol family 16
[    0.282421] cpuidle: using governor ladder
[    0.282489] cpuidle: using governor menu
[    0.282577] ACPI FADT declares the system doesn't support PCIe ASPM, so disable it
[    0.282666] ACPI: bus type PCI registered
[    0.282734] acpiphp: ACPI Hot Plug PCI Controller Driver version: 0.5
[    0.282882] PCI: MMCONFIG for domain 0000 [bus 00-ff] at [mem 0x80000000-0x8fffffff] (base 0x80000000)
[    0.282975] PCI: MMCONFIG at [mem 0x80000000-0x8fffffff] reserved in E820
[    0.292053] PCI: Using configuration type 1 for base access
[    0.294195] bio: create slab <bio-0> at 0
[    0.294500] ACPI: Added _OSI(Module Device)
[    0.294569] ACPI: Added _OSI(Processor Device)
[    0.294637] ACPI: Added _OSI(3.0 _SCP Extensions)
[    0.294707] ACPI: Added _OSI(Processor Aggregator Device)
[    0.299686] ACPI: EC: Look up EC in DSDT
[    0.304858] ACPI: Executed 1 blocks of module-level executable AML code
[    0.585219] ACPI: Interpreter enabled
[    0.585299] ACPI Exception: AE_NOT_FOUND, While evaluating Sleep State [\_S2_] (20130725/hwxface-571)
[    0.585485] ACPI Exception: AE_NOT_FOUND, While evaluating Sleep State [\_S3_] (20130725/hwxface-571)
[    0.585676] ACPI: (supports S0 S1 S4 S5)
[    0.585744] ACPI: Using IOAPIC for interrupt routing
[    0.585883] HEST: Table parsing has been initialized.
[    0.585955] PCI: Using host bridge windows from ACPI; if necessary, use "pci=nocrs" and report a bug
[    0.586280] ACPI: No dock devices found.
[    0.588734] [Firmware Bug]: ACPI: BIOS _OSI(Linux) query ignored
[    0.597833] ACPI: PCI Root Bridge [PCI0] (domain 0000 [bus 00-fe])
[    0.598131] acpi PNP0A08:00: Requesting ACPI _OSC control (0x1d)
[    0.598525] acpi PNP0A08:00: ACPI _OSC control (0x11) granted
[    0.598924] ACPI: \_SB_.PCI0.IOH_: can't evaluate _ADR (0x5)
[    0.598996] ACPI: \_SB_.PCI0.VTDR: can't evaluate _ADR (0x5)
[    0.599079] ACPI: \_SB_.PCI0.PCH_: can't evaluate _ADR (0x5)
[    0.599151] ACPI: \_SB_.PCI0.CWDT: can't evaluate _ADR (0x5)
[    0.599368] ACPI: \_SB_.PCI0.HPET: can't evaluate _ADR (0x5)
[    0.599440] ACPI: \_SB_.PCI0.ITPM: can't evaluate _ADR (0x5)
[    0.599511] PCI host bridge to bus 0000:00
[    0.599580] pci_bus 0000:00: root bus resource [bus 00-fe]
[    0.599652] pci_bus 0000:00: root bus resource [io  0x0000-0x03af]
[    0.599725] pci_bus 0000:00: root bus resource [io  0x03e0-0x0cf7]
[    0.599797] pci_bus 0000:00: root bus resource [io  0x03b0-0x03df]
[    0.599869] pci_bus 0000:00: root bus resource [io  0x0d00-0xffff]
[    0.599942] pci_bus 0000:00: root bus resource [mem 0x000a0000-0x000bffff]
[    0.600015] pci_bus 0000:00: root bus resource [mem 0x000c0000-0x000dffff]
[    0.600089] pci_bus 0000:00: root bus resource [mem 0xfed0e000-0xfed0ffff]
[    0.600162] pci_bus 0000:00: root bus resource [mem 0x80000000-0xfbffffff]
[    0.600247] pci 0000:00:00.0: [8086:3c00] type 00 class 0x060000
[    0.600307] pci 0000:00:00.0: PME# supported from D0 D3hot D3cold
[    0.600420] pci 0000:00:01.0: [8086:3c02] type 01 class 0x060400
[    0.600489] pci 0000:00:01.0: PME# supported from D0 D3hot D3cold
[    0.600562] pci 0000:00:01.0: System wakeup disabled by ACPI
[    0.600679] pci 0000:00:01.1: [8086:3c03] type 01 class 0x060400
[    0.600747] pci 0000:00:01.1: PME# supported from D0 D3hot D3cold
[    0.600818] pci 0000:00:01.1: System wakeup disabled by ACPI
[    0.600940] pci 0000:00:02.0: [8086:3c04] type 01 class 0x060400
[    0.601007] pci 0000:00:02.0: PME# supported from D0 D3hot D3cold
[    0.601080] pci 0000:00:02.0: System wakeup disabled by ACPI
[    0.601194] pci 0000:00:02.2: [8086:3c06] type 01 class 0x060400
[    0.601261] pci 0000:00:02.2: PME# supported from D0 D3hot D3cold
[    0.601332] pci 0000:00:02.2: System wakeup disabled by ACPI
[    0.601449] pci 0000:00:03.0: [8086:3c08] type 01 class 0x060400
[    0.601516] pci 0000:00:03.0: PME# supported from D0 D3hot D3cold
[    0.601589] pci 0000:00:03.0: System wakeup disabled by ACPI
[    0.601703] pci 0000:00:03.2: [8086:3c0a] type 01 class 0x060400
[    0.601770] pci 0000:00:03.2: PME# supported from D0 D3hot D3cold
[    0.601841] pci 0000:00:03.2: System wakeup disabled by ACPI
[    0.601960] pci 0000:00:04.0: [8086:3c20] type 00 class 0x088000
[    0.601976] pci 0000:00:04.0: reg 0x10: [mem 0xfb81c000-0xfb81ffff 64bit]
[    0.602134] pci 0000:00:04.1: [8086:3c21] type 00 class 0x088000
[    0.602148] pci 0000:00:04.1: reg 0x10: [mem 0xfb818000-0xfb81bfff 64bit]
[    0.602305] pci 0000:00:04.2: [8086:3c22] type 00 class 0x088000
[    0.602320] pci 0000:00:04.2: reg 0x10: [mem 0xfb814000-0xfb817fff 64bit]
[    0.602483] pci 0000:00:04.3: [8086:3c23] type 00 class 0x088000
[    0.602498] pci 0000:00:04.3: reg 0x10: [mem 0xfb810000-0xfb813fff 64bit]
[    0.602655] pci 0000:00:04.4: [8086:3c24] type 00 class 0x088000
[    0.602670] pci 0000:00:04.4: reg 0x10: [mem 0xfb80c000-0xfb80ffff 64bit]
[    0.602831] pci 0000:00:04.5: [8086:3c25] type 00 class 0x088000
[    0.602845] pci 0000:00:04.5: reg 0x10: [mem 0xfb808000-0xfb80bfff 64bit]
[    0.603000] pci 0000:00:04.6: [8086:3c26] type 00 class 0x088000
[    0.603015] pci 0000:00:04.6: reg 0x10: [mem 0xfb804000-0xfb807fff 64bit]
[    0.603169] pci 0000:00:04.7: [8086:3c27] type 00 class 0x088000
[    0.603184] pci 0000:00:04.7: reg 0x10: [mem 0xfb800000-0xfb803fff 64bit]
[    0.603337] pci 0000:00:05.0: [8086:3c28] type 00 class 0x088000
[    0.603479] pci 0000:00:05.2: [8086:3c2a] type 00 class 0x088000
[    0.603620] pci 0000:00:05.4: [8086:3c2c] type 00 class 0x080020
[    0.603633] pci 0000:00:05.4: reg 0x10: [mem 0xfb825000-0xfb825fff]
[    0.603789] pci 0000:00:11.0: [8086:1d3e] type 01 class 0x060400
[    0.603881] pci 0000:00:11.0: PME# supported from D0 D3hot D3cold
[    0.603997] pci 0000:00:16.0: [8086:1d3a] type 00 class 0x078000
[    0.604020] pci 0000:00:16.0: reg 0x10: [mem 0xfed0e000-0xfed0e00f 64bit]
[    0.604095] pci 0000:00:16.0: PME# supported from D0 D3hot D3cold
[    0.604199] pci 0000:00:16.1: [8086:1d3b] type 00 class 0x078000
[    0.604222] pci 0000:00:16.1: reg 0x10: [mem 0xfed0f000-0xfed0f00f 64bit]
[    0.604297] pci 0000:00:16.1: PME# supported from D0 D3hot D3cold
[    0.604415] pci 0000:00:1a.0: [8086:1d2d] type 00 class 0x0c0320
[    0.604437] pci 0000:00:1a.0: reg 0x10: [mem 0xfb823000-0xfb8233ff]
[    0.604531] pci 0000:00:1a.0: PME# supported from D0 D3hot D3cold
[    0.604600] pci 0000:00:1a.0: System wakeup disabled by ACPI
[    0.604719] pci 0000:00:1d.0: [8086:1d26] type 00 class 0x0c0320
[    0.604741] pci 0000:00:1d.0: reg 0x10: [mem 0xfb822000-0xfb8223ff]
[    0.604835] pci 0000:00:1d.0: PME# supported from D0 D3hot D3cold
[    0.604905] pci 0000:00:1d.0: System wakeup disabled by ACPI
[    0.605015] pci 0000:00:1e.0: [8086:244e] type 01 class 0x060401
[    0.605125] pci 0000:00:1e.0: System wakeup disabled by ACPI
[    0.605238] pci 0000:00:1f.0: [8086:1d41] type 00 class 0x060100
[    0.605442] pci 0000:00:1f.2: [8086:1d02] type 00 class 0x010601
[    0.605462] pci 0000:00:1f.2: reg 0x10: [io  0xf050-0xf057]
[    0.605470] pci 0000:00:1f.2: reg 0x14: [io  0xf040-0xf043]
[    0.605478] pci 0000:00:1f.2: reg 0x18: [io  0xf030-0xf037]
[    0.605487] pci 0000:00:1f.2: reg 0x1c: [io  0xf020-0xf023]
[    0.605495] pci 0000:00:1f.2: reg 0x20: [io  0xf000-0xf01f]
[    0.605503] pci 0000:00:1f.2: reg 0x24: [mem 0xfb821000-0xfb8217ff]
[    0.605551] pci 0000:00:1f.2: PME# supported from D3hot
[    0.605650] pci 0000:00:1f.3: [8086:1d22] type 00 class 0x0c0500
[    0.605666] pci 0000:00:1f.3: reg 0x10: [mem 0xfb820000-0xfb8200ff 64bit]
[    0.605688] pci 0000:00:1f.3: reg 0x20: [io  0x1180-0x119f]
[    0.605799] pci 0000:00:1f.6: [8086:1d24] type 00 class 0x118000
[    0.605820] pci 0000:00:1f.6: reg 0x10: [mem 0x90000000-0x90000fff 64bit]
[    0.606027] pci 0000:00:01.0: PCI bridge to [bus 01]
[    0.606161] pci 0000:00:01.1: PCI bridge to [bus 02]
[    0.606308] pci 0000:03:00.0: [8086:1521] type 00 class 0x020000
[    0.606319] pci 0000:03:00.0: reg 0x10: [mem 0xfb580000-0xfb5fffff]
[    0.606333] pci 0000:03:00.0: reg 0x18: [io  0xe020-0xe03f]
[    0.606341] pci 0000:03:00.0: reg 0x1c: [mem 0xfb704000-0xfb707fff]
[    0.606362] pci 0000:03:00.0: reg 0x30: [mem 0xfb640000-0xfb67ffff pref]
[    0.606401] pci 0000:03:00.0: PME# supported from D0 D3hot D3cold
[    0.606430] pci 0000:03:00.0: reg 0x184: [mem 0xfb6e0000-0xfb6e3fff]
[    0.606447] pci 0000:03:00.0: reg 0x190: [mem 0xfb6c0000-0xfb6c3fff]
[    0.606516] pci 0000:03:00.1: [8086:1521] type 00 class 0x020000
[    0.606527] pci 0000:03:00.1: reg 0x10: [mem 0xfb500000-0xfb57ffff]
[    0.606541] pci 0000:03:00.1: reg 0x18: [io  0xe000-0xe01f]
[    0.606549] pci 0000:03:00.1: reg 0x1c: [mem 0xfb700000-0xfb703fff]
[    0.606569] pci 0000:03:00.1: reg 0x30: [mem 0xfb600000-0xfb63ffff pref]
[    0.606608] pci 0000:03:00.1: PME# supported from D0 D3hot D3cold
[    0.606632] pci 0000:03:00.1: reg 0x184: [mem 0xfb6a0000-0xfb6a3fff]
[    0.606649] pci 0000:03:00.1: reg 0x190: [mem 0xfb680000-0xfb683fff]
[    0.614483] pci 0000:00:02.0: PCI bridge to [bus 03-04]
[    0.614569] pci 0000:00:02.0:   bridge window [io  0xe000-0xefff]
[    0.614573] pci 0000:00:02.0:   bridge window [mem 0xfb500000-0xfb7fffff]
[    0.614650] pci 0000:05:00.0: [8086:1521] type 00 class 0x020000
[    0.614660] pci 0000:05:00.0: reg 0x10: [mem 0xfb200000-0xfb2fffff]
[    0.614680] pci 0000:05:00.0: reg 0x1c: [mem 0xfb404000-0xfb407fff]
[    0.614701] pci 0000:05:00.0: reg 0x30: [mem 0xfb300000-0xfb37ffff pref]
[    0.614739] pci 0000:05:00.0: PME# supported from D0 D3hot D3cold
[    0.614768] pci 0000:05:00.0: reg 0x184: [mem 0xfb3e0000-0xfb3e3fff]
[    0.614784] pci 0000:05:00.0: reg 0x190: [mem 0xfb3c0000-0xfb3c3fff]
[    0.614846] pci 0000:05:00.1: [8086:1521] type 00 class 0x020000
[    0.614857] pci 0000:05:00.1: reg 0x10: [mem 0xfb100000-0xfb1fffff]
[    0.614877] pci 0000:05:00.1: reg 0x1c: [mem 0xfb400000-0xfb403fff]
[    0.614933] pci 0000:05:00.1: PME# supported from D0 D3hot D3cold
[    0.614957] pci 0000:05:00.1: reg 0x184: [mem 0xfb3a0000-0xfb3a3fff]
[    0.614974] pci 0000:05:00.1: reg 0x190: [mem 0xfb380000-0xfb383fff]
[    0.622495] pci 0000:00:02.2: PCI bridge to [bus 05-06]
[    0.622570] pci 0000:00:02.2:   bridge window [mem 0xfb100000-0xfb4fffff]
[    0.622636] pci 0000:00:03.0: PCI bridge to [bus 07]
[    0.622774] pci 0000:00:03.2: PCI bridge to [bus 08]
[    0.622919] pci 0000:00:11.0: PCI bridge to [bus 09]
[    0.623049] pci 0000:0a:01.0: [102b:0532] type 00 class 0x030000
[    0.623067] pci 0000:0a:01.0: reg 0x10: [mem 0xf9000000-0xf9ffffff pref]
[    0.623077] pci 0000:0a:01.0: reg 0x14: [mem 0xfb000000-0xfb003fff]
[    0.623087] pci 0000:0a:01.0: reg 0x18: [mem 0xfa800000-0xfaffffff]
[    0.623222] pci 0000:00:1e.0: PCI bridge to [bus 0a] (subtractive decode)
[    0.623299] pci 0000:00:1e.0:   bridge window [mem 0xfa800000-0xfb0fffff]
[    0.623305] pci 0000:00:1e.0:   bridge window [mem 0xf9000000-0xf9ffffff 64bit pref]
[    0.623307] pci 0000:00:1e.0:   bridge window [io  0x0000-0x03af] (subtractive decode)
[    0.623310] pci 0000:00:1e.0:   bridge window [io  0x03e0-0x0cf7] (subtractive decode)
[    0.623312] pci 0000:00:1e.0:   bridge window [io  0x03b0-0x03df] (subtractive decode)
[    0.623315] pci 0000:00:1e.0:   bridge window [io  0x0d00-0xffff] (subtractive decode)
[    0.623317] pci 0000:00:1e.0:   bridge window [mem 0x000a0000-0x000bffff] (subtractive decode)
[    0.623320] pci 0000:00:1e.0:   bridge window [mem 0x000c0000-0x000dffff] (subtractive decode)
[    0.623322] pci 0000:00:1e.0:   bridge window [mem 0xfed0e000-0xfed0ffff] (subtractive decode)
[    0.623325] pci 0000:00:1e.0:   bridge window [mem 0x80000000-0xfbffffff] (subtractive decode)
[    0.623366] pci_bus 0000:00: on NUMA node 0 (pxm 0)
[    0.623368] acpi PNP0A08:00: Disabling ASPM (FADT indicates it is unsupported)
[    0.624144] ACPI: PCI Root Bridge [UNC0] (domain 0000 [bus ff])
[    0.624219] acpi PNP0A03:00: ACPI _OSC support notification failed, disabling PCIe ASPM
[    0.624308] acpi PNP0A03:00: Unable to request _OSC control (_OSC support mask: 0x08)
[    0.624464] PCI host bridge to bus 0000:ff
[    0.624533] pci_bus 0000:ff: root bus resource [bus ff]
[    0.624612] pci 0000:ff:08.0: [8086:3c80] type 00 class 0x088000
[    0.624676] pci 0000:ff:08.3: [8086:3c83] type 00 class 0x088000
[    0.624747] pci 0000:ff:08.4: [8086:3c84] type 00 class 0x088000
[    0.624822] pci 0000:ff:09.0: [8086:3c90] type 00 class 0x088000
[    0.624882] pci 0000:ff:09.3: [8086:3c93] type 00 class 0x088000
[    0.624951] pci 0000:ff:09.4: [8086:3c94] type 00 class 0x088000
[    0.625023] pci 0000:ff:0a.0: [8086:3cc0] type 00 class 0x088000
[    0.625074] pci 0000:ff:0a.1: [8086:3cc1] type 00 class 0x088000
[    0.625124] pci 0000:ff:0a.2: [8086:3cc2] type 00 class 0x088000
[    0.625174] pci 0000:ff:0a.3: [8086:3cd0] type 00 class 0x088000
[    0.625227] pci 0000:ff:0b.0: [8086:3ce0] type 00 class 0x088000
[    0.625278] pci 0000:ff:0b.3: [8086:3ce3] type 00 class 0x088000
[    0.625329] pci 0000:ff:0c.0: [8086:3ce8] type 00 class 0x088000
[    0.625380] pci 0000:ff:0c.1: [8086:3ce8] type 00 class 0x088000
[    0.625430] pci 0000:ff:0c.2: [8086:3ce8] type 00 class 0x088000
[    0.625482] pci 0000:ff:0c.6: [8086:3cf4] type 00 class 0x088000
[    0.625532] pci 0000:ff:0c.7: [8086:3cf6] type 00 class 0x088000
[    0.625582] pci 0000:ff:0d.0: [8086:3ce8] type 00 class 0x088000
[    0.625632] pci 0000:ff:0d.1: [8086:3ce8] type 00 class 0x088000
[    0.625682] pci 0000:ff:0d.2: [8086:3ce8] type 00 class 0x088000
[    0.625733] pci 0000:ff:0d.6: [8086:3cf5] type 00 class 0x088000
[    0.625784] pci 0000:ff:0e.0: [8086:3ca0] type 00 class 0x088000
[    0.625838] pci 0000:ff:0e.1: [8086:3c46] type 00 class 0x110100
[    0.625898] pci 0000:ff:0f.0: [8086:3ca8] type 00 class 0x088000
[    0.625963] pci 0000:ff:0f.1: [8086:3c71] type 00 class 0x088000
[    0.626031] pci 0000:ff:0f.2: [8086:3caa] type 00 class 0x088000
[    0.626097] pci 0000:ff:0f.3: [8086:3cab] type 00 class 0x088000
[    0.626162] pci 0000:ff:0f.4: [8086:3cac] type 00 class 0x088000
[    0.626231] pci 0000:ff:0f.5: [8086:3cad] type 00 class 0x088000
[    0.626294] pci 0000:ff:0f.6: [8086:3cae] type 00 class 0x088000
[    0.626352] pci 0000:ff:10.0: [8086:3cb0] type 00 class 0x088000
[    0.626419] pci 0000:ff:10.1: [8086:3cb1] type 00 class 0x088000
[    0.626493] pci 0000:ff:10.2: [8086:3cb2] type 00 class 0x088000
[    0.626560] pci 0000:ff:10.3: [8086:3cb3] type 00 class 0x088000
[    0.626628] pci 0000:ff:10.4: [8086:3cb4] type 00 class 0x088000
[    0.626696] pci 0000:ff:10.5: [8086:3cb5] type 00 class 0x088000
[    0.626763] pci 0000:ff:10.6: [8086:3cb6] type 00 class 0x088000
[    0.626830] pci 0000:ff:10.7: [8086:3cb7] type 00 class 0x088000
[    0.626894] pci 0000:ff:11.0: [8086:3cb8] type 00 class 0x088000
[    0.626959] pci 0000:ff:13.0: [8086:3ce4] type 00 class 0x088000
[    0.627012] pci 0000:ff:13.1: [8086:3c43] type 00 class 0x110100
[    0.627066] pci 0000:ff:13.4: [8086:3ce6] type 00 class 0x110100
[    0.627118] pci 0000:ff:13.5: [8086:3c44] type 00 class 0x110100
[    0.627170] pci 0000:ff:13.6: [8086:3c45] type 00 class 0x088000
[    0.627326] ACPI: PCI Interrupt Link [LNKA] (IRQs 3 4 5 6 7 10 *11 12 14 15)
[    0.628013] ACPI: PCI Interrupt Link [LNKB] (IRQs 3 4 5 6 7 *10 11 12 14 15)
[    0.628699] ACPI: PCI Interrupt Link [LNKC] (IRQs 3 4 *5 6 10 11 12 14 15)
[    0.629337] ACPI: PCI Interrupt Link [LNKD] (IRQs 3 4 5 6 10 *11 12 14 15)
[    0.629977] ACPI: PCI Interrupt Link [LNKE] (IRQs 3 4 5 6 7 10 11 12 14 15) *0
[    0.630729] ACPI: PCI Interrupt Link [LNKF] (IRQs 3 4 5 6 7 10 11 12 14 15) *0
[    0.631473] ACPI: PCI Interrupt Link [LNKG] (IRQs 3 4 5 6 7 *10 11 12 14 15)
[    0.632158] ACPI: PCI Interrupt Link [LNKH] (IRQs 3 4 5 6 *7 10 11 12 14 15)
[    0.634271] ACPI: Enabled 2 GPEs in block 00 to 3F
[    0.634461] ACPI: \_SB_.PCI0: notify handler is installed
[    0.634636] ACPI: \_SB_.UNC0: notify handler is installed
[    0.634711] Found 2 acpi root devices
[    0.634819] vgaarb: device added: PCI:0000:0a:01.0,decodes=io+mem,owns=io+mem,locks=none
[    0.634919] vgaarb: loaded
[    0.634984] vgaarb: bridge control possible 0000:0a:01.0
[    0.635123] PCI: Using ACPI for IRQ routing
[    0.641814] PCI: pci_cache_line_size set to 64 bytes
[    0.641943] e820: reserve RAM buffer [mem 0x0009ac00-0x0009ffff]
[    0.641946] e820: reserve RAM buffer [mem 0x7dfea000-0x7fffffff]
[    0.642092] hpet0: at MMIO 0xfed00000, IRQs 2, 8, 0, 0, 0, 0, 0, 0
[    0.642586] hpet0: 8 comparators, 64-bit 14.318180 MHz counter
[    0.644700] Switched to clocksource hpet
[    0.646733] pnp: PnP ACPI init
[    0.646817] ACPI: bus type PNP registered
[    0.646980] system 00:00: [mem 0xfc000000-0xfcffffff] has been reserved
[    0.647057] system 00:00: [mem 0xfd000000-0xfdffffff] has been reserved
[    0.647130] system 00:00: [mem 0xfe000000-0xfeafffff] has been reserved
[    0.647204] system 00:00: [mem 0xfeb00000-0xfebfffff] has been reserved
[    0.647277] system 00:00: [mem 0xfed00400-0xfed3ffff] could not be reserved
[    0.647351] system 00:00: [mem 0xfed45000-0xfedfffff] has been reserved
[    0.647426] system 00:00: Plug and Play ACPI device, IDs PNP0c01 (active)
[    0.647530] system 00:01: [mem 0xfbffc000-0xfbffdfff] could not be reserved
[    0.647605] system 00:01: Plug and Play ACPI device, IDs PNP0c02 (active)
[    0.647621] pnp 00:02: [dma 4]
[    0.647644] pnp 00:02: Plug and Play ACPI device, IDs PNP0200 (active)
[    0.647684] pnp 00:03: Plug and Play ACPI device, IDs PNP0b00 (active)
[    0.647713] pnp 00:04: Plug and Play ACPI device, IDs PNP0800 (active)
[    0.647794] system 00:05: [io  0x04d0-0x04d1] has been reserved
[    0.647867] system 00:05: [mem 0x00000400-0x000004ff] could not be reserved
[    0.647941] system 00:05: Plug and Play ACPI device, IDs PNP0c02 (active)
[    0.647977] pnp 00:06: Plug and Play ACPI device, IDs PNP0c04 (active)
[    0.648132] system 00:07: [io  0x0a00-0x0a1f] has been reserved
[    0.648205] system 00:07: [io  0x0a30-0x0a3f] has been reserved
[    0.648277] system 00:07: Plug and Play ACPI device, IDs PNP0c02 (active)
[    0.648549] pnp 00:08: [dma 0 disabled]
[    0.648611] pnp 00:08: Plug and Play ACPI device, IDs PNP0501 (active)
[    0.648777] system 00:09: [io  0x0b00-0x0b7f] has been reserved
[    0.648851] system 00:09: Plug and Play ACPI device, IDs PNP0c02 (active)
[    0.649064] pnp 00:0a: [dma 0 disabled]
[    0.649123] pnp 00:0a: Plug and Play ACPI device, IDs PNP0501 (active)
[    0.649296] pnp 00:0b: Plug and Play ACPI device, IDs IPI0001 (active)
[    0.649544] system 00:0c: [io  0x0400-0x0453] could not be reserved
[    0.649618] system 00:0c: [io  0x0458-0x047f] has been reserved
[    0.649690] system 00:0c: [io  0x1180-0x119f] has been reserved
[    0.649762] system 00:0c: [io  0x0500-0x057f] has been reserved
[    0.649835] system 00:0c: [mem 0xfed1c000-0xfed1ffff] has been reserved
[    0.649909] system 00:0c: [mem 0xfec00000-0xfecfffff] could not be reserved
[    0.649983] system 00:0c: [mem 0xfed08000-0xfed08fff] has been reserved
[    0.650056] system 00:0c: [mem 0xff000000-0xffffffff] has been reserved
[    0.650129] system 00:0c: Plug and Play ACPI device, IDs PNP0c01 (active)
[    0.650217] system 00:0d: [io  0x0454-0x0457] has been reserved
[    0.650290] system 00:0d: Plug and Play ACPI device, IDs INT3f0d PNP0c02 (active)
[    0.650462] pnp 00:0e: Plug and Play ACPI device, IDs PNP0103 (active)
[    0.650693] system 00:0f: [mem 0x00000000-0x0009ffff] could not be reserved
[    0.650767] system 00:0f: Plug and Play ACPI device, IDs PNP0c01 (active)
[    0.650986] pnp: PnP ACPI: found 16 devices
[    0.651054] ACPI: bus type PNP unregistered
[    0.657936] pci 0000:00:01.0: PCI bridge to [bus 01]
[    0.658015] pci 0000:00:01.1: PCI bridge to [bus 02]
[    0.658094] pci 0000:00:02.0: PCI bridge to [bus 03-04]
[    0.658166] pci 0000:00:02.0:   bridge window [io  0xe000-0xefff]
[    0.658240] pci 0000:00:02.0:   bridge window [mem 0xfb500000-0xfb7fffff]
[    0.658319] pci 0000:00:02.2: PCI bridge to [bus 05-06]
[    0.658392] pci 0000:00:02.2:   bridge window [mem 0xfb100000-0xfb4fffff]
[    0.658470] pci 0000:00:03.0: PCI bridge to [bus 07]
[    0.658548] pci 0000:00:03.2: PCI bridge to [bus 08]
[    0.658626] pci 0000:00:11.0: PCI bridge to [bus 09]
[    0.658708] pci 0000:00:1e.0: PCI bridge to [bus 0a]
[    0.658781] pci 0000:00:1e.0:   bridge window [mem 0xfa800000-0xfb0fffff]
[    0.658856] pci 0000:00:1e.0:   bridge window [mem 0xf9000000-0xf9ffffff 64bit pref]
[    0.658949] pci_bus 0000:00: resource 4 [io  0x0000-0x03af]
[    0.658951] pci_bus 0000:00: resource 5 [io  0x03e0-0x0cf7]
[    0.658954] pci_bus 0000:00: resource 6 [io  0x03b0-0x03df]
[    0.658956] pci_bus 0000:00: resource 7 [io  0x0d00-0xffff]
[    0.658958] pci_bus 0000:00: resource 8 [mem 0x000a0000-0x000bffff]
[    0.658960] pci_bus 0000:00: resource 9 [mem 0x000c0000-0x000dffff]
[    0.658963] pci_bus 0000:00: resource 10 [mem 0xfed0e000-0xfed0ffff]
[    0.658965] pci_bus 0000:00: resource 11 [mem 0x80000000-0xfbffffff]
[    0.658967] pci_bus 0000:03: resource 0 [io  0xe000-0xefff]
[    0.658969] pci_bus 0000:03: resource 1 [mem 0xfb500000-0xfb7fffff]
[    0.658972] pci_bus 0000:05: resource 1 [mem 0xfb100000-0xfb4fffff]
[    0.658974] pci_bus 0000:0a: resource 1 [mem 0xfa800000-0xfb0fffff]
[    0.658976] pci_bus 0000:0a: resource 2 [mem 0xf9000000-0xf9ffffff 64bit pref]
[    0.658979] pci_bus 0000:0a: resource 4 [io  0x0000-0x03af]
[    0.658981] pci_bus 0000:0a: resource 5 [io  0x03e0-0x0cf7]
[    0.658983] pci_bus 0000:0a: resource 6 [io  0x03b0-0x03df]
[    0.658985] pci_bus 0000:0a: resource 7 [io  0x0d00-0xffff]
[    0.658987] pci_bus 0000:0a: resource 8 [mem 0x000a0000-0x000bffff]
[    0.658989] pci_bus 0000:0a: resource 9 [mem 0x000c0000-0x000dffff]
[    0.658991] pci_bus 0000:0a: resource 10 [mem 0xfed0e000-0xfed0ffff]
[    0.658993] pci_bus 0000:0a: resource 11 [mem 0x80000000-0xfbffffff]
[    0.659129] NET: Registered protocol family 2
[    0.660115] TCP established hash table entries: 524288 (order: 11, 8388608 bytes)
[    0.661610] TCP bind hash table entries: 65536 (order: 8, 1048576 bytes)
[    0.661822] TCP: Hash tables configured (established 524288 bind 65536)
[    0.661918] TCP: reno registered
[    0.662066] UDP hash table entries: 32768 (order: 8, 1048576 bytes)
[    0.662408] UDP-Lite hash table entries: 32768 (order: 8, 1048576 bytes)
[    0.662816] NET: Registered protocol family 1
[    0.700841] pci 0000:0a:01.0: Boot video device
[    0.700902] PCI: CLS 64 bytes, default 64
[    0.700950] Unpacking initramfs...
[    0.973164] Freeing initrd memory: 11632K (ffff880036938000 - ffff880037494000)
[    0.973267] PCI-DMA: Using software bounce buffering for IO (SWIOTLB)
[    0.973341] software IO TLB [mem 0x79fea000-0x7dfea000] (64MB) mapped at [ffff880079fea000-ffff88007dfe9fff]
[    0.974695] audit: initializing netlink socket (disabled)
[    0.974787] type=2000 audit(1382206912.796:1): initialized
[    0.999115] bounce pool size: 64 pages
[    0.999187] HugeTLB registered 2 MB page size, pre-allocated 0 pages
[    1.003098] VFS: Disk quotas dquot_6.5.2
[    1.003206] Dquot-cache hash table entries: 512 (order 0, 4096 bytes)
[    1.003398] msgmni has been set to 32768
[    1.003811] alg: No test for stdrng (krng)
[    1.003916] Block layer SCSI generic (bsg) driver version 0.4 loaded (major 252)
[    1.004006] io scheduler noop registered
[    1.004074] io scheduler deadline registered
[    1.004180] io scheduler cfq registered (default)
[    1.005428] ioapic: probe of 0000:00:05.4 failed with error -22
[    1.005512] pci_hotplug: PCI Hot Plug PCI Core version: 0.5
[    1.005598] pciehp: PCI Express Hot Plug Controller Driver version: 0.4
[    1.011015] intel_idle: MWAIT substates: 0x21120
[    1.011017] intel_idle: v0.4 model 0x2D
[    1.011018] intel_idle: lapic_timer_reliable_states 0xffffffff
[    1.011477] ERST: Error Record Serialization Table (ERST) support is initialized.
[    1.011571] pstore: Registered erst as persistent store backend
[    1.011788] GHES: APEI firmware first mode is enabled by APEI bit and WHEA _OSC.
[    1.011930] Serial: 8250/16550 driver, 4 ports, IRQ sharing enabled
[    1.032503] 00:08: ttyS0 at I/O 0x3f8 (irq = 4, base_baud = 115200) is a 16550A
[    1.053054] 00:0a: ttyS2 at I/O 0x3e8 (irq = 3, base_baud = 115200) is a 16550A
[    1.053637] Linux agpgart interface v0.103
[    1.053940] i8042: PNP: No PS/2 controller found. Probing ports directly.
[    1.056544] serio: i8042 KBD port at 0x60,0x64 irq 1
[    1.056620] serio: i8042 AUX port at 0x60,0x64 irq 12
[    1.056831] mousedev: PS/2 mouse device common for all mice
[    1.056943] rtc_cmos 00:03: RTC can wake from S4
[    1.057149] rtc_cmos 00:03: rtc core: registered rtc_cmos as rtc0
[    1.057251] rtc_cmos 00:03: alarms up to one month, y3k, 114 bytes nvram, hpet irqs
[    1.057400] drop_monitor: Initializing network drop monitor service
[    1.057563] TCP: cubic registered
[    1.057815] NET: Registered protocol family 10
[    1.058187] mip6: Mobile IPv6
[    1.058255] NET: Registered protocol family 17
[    1.058336] Key type dns_resolver registered
[    1.058903] PM: Hibernation image not present or could not be loaded.
[    1.058914] registered taskstats version 1
[    1.063057] rtc_cmos 00:03: setting system clock to 2013-10-19 18:21:53 UTC (1382206913)
[    1.064477] Freeing unused kernel memory: 872K (ffffffff81699000 - ffffffff81773000)
[    1.064565] Write protecting the kernel read-only data: 6144k
[    1.066220] Freeing unused kernel memory: 504K (ffff880001382000 - ffff880001400000)
[    1.067735] Freeing unused kernel memory: 536K (ffff88000157a000 - ffff880001600000)
[    1.079405] udevd[106]: starting version 175
[    1.113716] pps_core: LinuxPPS API ver. 1 registered
[    1.113794] pps_core: Software ver. 5.3.6 - Copyright 2005-2007 Rodolfo Giometti <giometti@linux.it>
[    1.114175] PTP clock support registered
[    1.114498] dca service started, version 1.12.1
[    1.115895] igb: Intel(R) Gigabit Ethernet Network Driver - version 5.0.5-k
[    1.115975] igb: Copyright (c) 2007-2013 Intel Corporation.
[    1.116084] pcieport 0000:00:02.0: driver skip pci_set_master, fix it!
[    1.116509] igb 0000:03:00.0: irq 65 for MSI/MSI-X
[    1.116524] igb 0000:03:00.0: irq 66 for MSI/MSI-X
[    1.116538] igb 0000:03:00.0: irq 67 for MSI/MSI-X
[    1.116551] igb 0000:03:00.0: irq 68 for MSI/MSI-X
[    1.116562] igb 0000:03:00.0: irq 69 for MSI/MSI-X
[    1.116573] igb 0000:03:00.0: irq 70 for MSI/MSI-X
[    1.116585] igb 0000:03:00.0: irq 71 for MSI/MSI-X
[    1.116596] igb 0000:03:00.0: irq 72 for MSI/MSI-X
[    1.116609] igb 0000:03:00.0: irq 73 for MSI/MSI-X
[    1.118537] SCSI subsystem initialized
[    1.120087] libata version 3.00 loaded.
[    1.122387] ahci 0000:00:1f.2: version 3.0
[    1.122533] ahci 0000:00:1f.2: irq 74 for MSI/MSI-X
[    1.128664] microcode: CPU0 sig=0x206d7, pf=0x1, revision=0x70d
[    1.128824] microcode: CPU0 sig=0x206d7, pf=0x1, revision=0x70d
[    1.129973] microcode: CPU0 updated to revision 0x710, date = 2013-06-17
[    1.130062] microcode: CPU1 sig=0x206d7, pf=0x1, revision=0x70d
[    1.130174] microcode: CPU1 sig=0x206d7, pf=0x1, revision=0x70d
[    1.130917] microcode: CPU1 updated to revision 0x710, date = 2013-06-17
[    1.131002] microcode: CPU2 sig=0x206d7, pf=0x1, revision=0x70d
[    1.131118] microcode: CPU2 sig=0x206d7, pf=0x1, revision=0x70d
[    1.131846] microcode: CPU2 updated to revision 0x710, date = 2013-06-17
[    1.131936] microcode: CPU3 sig=0x206d7, pf=0x1, revision=0x70d
[    1.132038] microcode: CPU3 sig=0x206d7, pf=0x1, revision=0x70d
[    1.132765] microcode: CPU3 updated to revision 0x710, date = 2013-06-17
[    1.132861] microcode: CPU4 sig=0x206d7, pf=0x1, revision=0x70d
[    1.132977] microcode: CPU4 sig=0x206d7, pf=0x1, revision=0x70d
[    1.133706] microcode: CPU4 updated to revision 0x710, date = 2013-06-17
[    1.133797] microcode: CPU5 sig=0x206d7, pf=0x1, revision=0x70d
[    1.133895] microcode: CPU5 sig=0x206d7, pf=0x1, revision=0x70d
[    1.134624] microcode: CPU5 updated to revision 0x710, date = 2013-06-17
[    1.134705] microcode: CPU6 sig=0x206d7, pf=0x1, revision=0x70d
[    1.134802] microcode: CPU6 sig=0x206d7, pf=0x1, revision=0x70d
[    1.135522] microcode: CPU6 updated to revision 0x710, date = 2013-06-17
[    1.135613] microcode: CPU7 sig=0x206d7, pf=0x1, revision=0x70d
[    1.135716] microcode: CPU7 sig=0x206d7, pf=0x1, revision=0x70d
[    1.136442] microcode: CPU7 updated to revision 0x710, date = 2013-06-17
[    1.136531] microcode: CPU8 sig=0x206d7, pf=0x1, revision=0x70d
[    1.136631] microcode: CPU8 sig=0x206d7, pf=0x1, revision=0x70d
[    1.136760] ahci 0000:00:1f.2: AHCI 0001.0300 32 slots 6 ports 6 Gbps 0x3f impl SATA mode
[    1.136856] ahci 0000:00:1f.2: flags: 64bit ncq sntf pm led clo pio slum part ems apst 
[    1.136951] ahci 0000:00:1f.2: setting latency timer to 64
[    1.137373] microcode: CPU8 updated to revision 0x710, date = 2013-06-17
[    1.137489] microcode: CPU9 sig=0x206d7, pf=0x1, revision=0x70d
[    1.137606] microcode: CPU9 sig=0x206d7, pf=0x1, revision=0x70d
[    1.138334] microcode: CPU9 updated to revision 0x710, date = 2013-06-17
[    1.138425] microcode: CPU10 sig=0x206d7, pf=0x1, revision=0x70d
[    1.138538] microcode: CPU10 sig=0x206d7, pf=0x1, revision=0x70d
[    1.139268] microcode: CPU10 updated to revision 0x710, date = 2013-06-17
[    1.139354] microcode: CPU11 sig=0x206d7, pf=0x1, revision=0x70d
[    1.139466] microcode: CPU11 sig=0x206d7, pf=0x1, revision=0x70d
[    1.140196] microcode: CPU11 updated to revision 0x710, date = 2013-06-17
[    1.140356] microcode: Microcode Update Driver: v2.00 <tigran@aivazian.fsnet.co.uk>, Peter Oruba
[    1.177366] scsi0 : ahci
[    1.177655] scsi1 : ahci
[    1.177869] scsi2 : ahci
[    1.178142] scsi3 : ahci
[    1.178360] scsi4 : ahci
[    1.178578] scsi5 : ahci
[    1.178726] ata1: SATA max UDMA/133 abar m2048@0xfb821000 port 0xfb821100 irq 74
[    1.178817] ata2: SATA max UDMA/133 abar m2048@0xfb821000 port 0xfb821180 irq 74
[    1.178905] ata3: SATA max UDMA/133 abar m2048@0xfb821000 port 0xfb821200 irq 74
[    1.178993] ata4: SATA max UDMA/133 abar m2048@0xfb821000 port 0xfb821280 irq 74
[    1.179081] ata5: SATA max UDMA/133 abar m2048@0xfb821000 port 0xfb821300 irq 74
[    1.179170] ata6: SATA max UDMA/133 abar m2048@0xfb821000 port 0xfb821380 irq 74
[    1.193441] igb 0000:03:00.0: added PHC on eth0
[    1.193514] igb 0000:03:00.0: Intel(R) Gigabit Ethernet Network Connection
[    1.193590] igb 0000:03:00.0: eth0: (PCIe:5.0Gb/s:Width x4) 00:25:90:97:dc:1e
[    1.193735] igb 0000:03:00.0: eth0: PBA No: 104900-000
[    1.193806] igb 0000:03:00.0: Using MSI-X interrupts. 8 rx queue(s), 8 tx queue(s)
[    1.194283] igb 0000:03:00.1: irq 75 for MSI/MSI-X
[    1.194293] igb 0000:03:00.1: irq 76 for MSI/MSI-X
[    1.194301] igb 0000:03:00.1: irq 77 for MSI/MSI-X
[    1.194309] igb 0000:03:00.1: irq 78 for MSI/MSI-X
[    1.194316] igb 0000:03:00.1: irq 79 for MSI/MSI-X
[    1.194324] igb 0000:03:00.1: irq 80 for MSI/MSI-X
[    1.194331] igb 0000:03:00.1: irq 81 for MSI/MSI-X
[    1.194339] igb 0000:03:00.1: irq 82 for MSI/MSI-X
[    1.194346] igb 0000:03:00.1: irq 83 for MSI/MSI-X
[    1.273269] igb 0000:03:00.1: added PHC on eth1
[    1.273342] igb 0000:03:00.1: Intel(R) Gigabit Ethernet Network Connection
[    1.273417] igb 0000:03:00.1: eth1: (PCIe:5.0Gb/s:Width x4) 00:25:90:97:dc:1f
[    1.273562] igb 0000:03:00.1: eth1: PBA No: 104900-000
[    1.273633] igb 0000:03:00.1: Using MSI-X interrupts. 8 rx queue(s), 8 tx queue(s)
[    1.273802] pcieport 0000:00:02.2: driver skip pci_set_master, fix it!
[    1.274177] igb 0000:05:00.0: irq 84 for MSI/MSI-X
[    1.274187] igb 0000:05:00.0: irq 85 for MSI/MSI-X
[    1.274195] igb 0000:05:00.0: irq 86 for MSI/MSI-X
[    1.274204] igb 0000:05:00.0: irq 87 for MSI/MSI-X
[    1.274211] igb 0000:05:00.0: irq 88 for MSI/MSI-X
[    1.274219] igb 0000:05:00.0: irq 89 for MSI/MSI-X
[    1.274226] igb 0000:05:00.0: irq 90 for MSI/MSI-X
[    1.274234] igb 0000:05:00.0: irq 91 for MSI/MSI-X
[    1.274241] igb 0000:05:00.0: irq 92 for MSI/MSI-X
[    1.353398] igb 0000:05:00.0: added PHC on eth2
[    1.353472] igb 0000:05:00.0: Intel(R) Gigabit Ethernet Network Connection
[    1.353547] igb 0000:05:00.0: eth2: (PCIe:5.0Gb/s:Width x4) a0:36:9f:18:17:c2
[    1.353904] igb 0000:05:00.0: eth2: PBA No: G15138-001
[    1.353982] igb 0000:05:00.0: Using MSI-X interrupts. 8 rx queue(s), 8 tx queue(s)
[    1.354453] igb 0000:05:00.1: irq 93 for MSI/MSI-X
[    1.354463] igb 0000:05:00.1: irq 94 for MSI/MSI-X
[    1.354471] igb 0000:05:00.1: irq 95 for MSI/MSI-X
[    1.354479] igb 0000:05:00.1: irq 96 for MSI/MSI-X
[    1.354486] igb 0000:05:00.1: irq 97 for MSI/MSI-X
[    1.354494] igb 0000:05:00.1: irq 98 for MSI/MSI-X
[    1.354501] igb 0000:05:00.1: irq 99 for MSI/MSI-X
[    1.354509] igb 0000:05:00.1: irq 100 for MSI/MSI-X
[    1.354517] igb 0000:05:00.1: irq 101 for MSI/MSI-X
[    1.433311] igb 0000:05:00.1: added PHC on eth3
[    1.433384] igb 0000:05:00.1: Intel(R) Gigabit Ethernet Network Connection
[    1.433458] igb 0000:05:00.1: eth3: (PCIe:5.0Gb/s:Width x4) a0:36:9f:18:17:c3
[    1.433815] igb 0000:05:00.1: eth3: PBA No: G15138-001
[    1.433886] igb 0000:05:00.1: Using MSI-X interrupts. 8 rx queue(s), 8 tx queue(s)
[    1.450598] e100: Intel(R) PRO/100 Network Driver, 3.5.24-k2-NAPI
[    1.450690] e100: Copyright(c) 1999-2006 Intel Corporation
[    1.455050] e1000: Intel(R) PRO/1000 Network Driver - version 7.3.21-k8-NAPI
[    1.455129] e1000: Copyright (c) 1999-2006 Intel Corporation.
[    1.467666] via_rhine: v1.10-LK1.5.1 2010-10-09 Written by Donald Becker
[    1.493763] md: raid1 personality registered for level 1
[    1.495476] 3ware Storage Controller device driver for Linux v1.26.02.003.
[    1.496738] ata1: SATA link up 3.0 Gbps (SStatus 123 SControl 300)
[    1.496836] ata3: SATA link down (SStatus 0 SControl 300)
[    1.496933] ata2: SATA link up 3.0 Gbps (SStatus 123 SControl 300)
[    1.497026] ata5: SATA link down (SStatus 0 SControl 300)
[    1.498941] ata1.00: ATA-8: WDC WD20EADS-00S2B0, 04.05G04, max UDMA/133
[    1.499030] ata1.00: 3907029168 sectors, multi 16: LBA48 NCQ (depth 31/32), AA
[    1.500742] ata6: SATA link down (SStatus 0 SControl 300)
[    1.500780] ata4: SATA link down (SStatus 0 SControl 300)
[    1.501594] ata1.00: configured for UDMA/133
[    1.501851] scsi 0:0:0:0: Direct-Access     ATA      WDC WD20EADS-00S 04.0 PQ: 0 ANSI: 5
[    1.502103] sd 0:0:0:0: [sda] 3907029168 512-byte logical blocks: (2.00 TB/1.81 TiB)
[    1.502397] sd 0:0:0:0: [sda] Write Protect is off
[    1.502469] sd 0:0:0:0: [sda] Mode Sense: 00 3a 00 00
[    1.502549] sd 0:0:0:0: [sda] Write cache: enabled, read cache: enabled, doesn't support DPO or FUA
[    1.503063] ata2.00: ATA-8: WDC WD20EADS-00R6B0, 01.00A01, max UDMA/133
[    1.503143] ata2.00: 3907029168 sectors, multi 16: LBA48 NCQ (depth 31/32), AA
[    1.505050] sd 0:0:0:0: Attached scsi generic sg0 type 0
[    1.509072] ata2.00: configured for UDMA/133
[    1.509306] scsi 1:0:0:0: Direct-Access     ATA      WDC WD20EADS-00R 01.0 PQ: 0 ANSI: 5
[    1.509584] sd 1:0:0:0: [sdb] 3907029168 512-byte logical blocks: (2.00 TB/1.81 TiB)
[    1.509597] sd 1:0:0:0: Attached scsi generic sg1 type 0
[    1.510000] sd 1:0:0:0: [sdb] Write Protect is off
[    1.510075] sd 1:0:0:0: [sdb] Mode Sense: 00 3a 00 00
[    1.510195] sd 1:0:0:0: [sdb] Write cache: enabled, read cache: enabled, doesn't support DPO or FUA
[    1.510731]  sda: sda1 sda2 sda3
[    1.516692] sd 0:0:0:0: [sda] Attached SCSI disk
[    1.527180]  sdb: sdb1 sdb2 sdb3
[    1.528266] sd 1:0:0:0: [sdb] Attached SCSI disk
[    1.617985] md: md1 stopped.
[    1.618646] md: bind<sda2>
[    1.620069] md/raid1:md1: active with 1 out of 2 mirrors
[    1.620176] md1: detected capacity change from 0 to 17178746880
[    1.620295] RAID1 conf printout:
[    1.620297]  --- wd:1 rd:2
[    1.620298]  disk 0, wo:0, o:1, dev:sda2
[    1.626874]  md1: unknown partition table
[    1.835982] md: md2 stopped.
[    1.836659] md: bind<sdb3>
[    1.836870] md: bind<sda3>
[    1.838743] md/raid1:md2: active with 2 out of 2 mirrors
[    1.838839] md2: detected capacity change from 0 to 1983007113216
[    1.838932] RAID1 conf printout:
[    1.838935]  --- wd:2 rd:2
[    1.838938]  disk 0, wo:0, o:1, dev:sda3
[    1.838939]  disk 1, wo:0, o:1, dev:sdb3
[    1.848710]  md2: unknown partition table
[    1.972804] tsc: Refined TSC clocksource calibration: 1999.999 MHz
[    2.042479] md: md0 stopped.
[    2.043221] md: bind<sdb1>
[    2.043430] md: bind<sda1>
[    2.044925] md/raid1:md0: active with 2 out of 2 mirrors
[    2.045020] md0: detected capacity change from 0 to 209702912
[    2.045139] RAID1 conf printout:
[    2.045140]  --- wd:2 rd:2
[    2.045143]  disk 0, wo:0, o:1, dev:sda1
[    2.045145]  disk 1, wo:0, o:1, dev:sdb1
[    2.046421]  md0: unknown partition table
[    2.294075] kjournald starting.  Commit interval 5 seconds
[    2.294597] EXT3-fs (md2): mounted filesystem with ordered data mode
[    2.972995] Switched to clocksource tsc
[    4.864390] udevd[572]: starting version 175
[    5.144965] input: Power Button as /devices/LNXSYSTM:00/device:00/PNP0C0C:00/input/input0
[    5.145066] ACPI: Power Button [PWRB]
[    5.145204] input: Power Button as /devices/LNXSYSTM:00/LNXPWRBN:00/input/input1
[    5.145296] ACPI: Power Button [PWRF]
[    5.190660] wmi: Mapper loaded
[    5.310723] ipmi message handler version 39.2
[    5.346745] EDAC MC: Ver: 3.0.0
[    5.349291] ACPI: Requesting acpi_cpufreq
[    5.354218] IPMI System Interface driver.
[    5.354322] ipmi_si: probing via ACPI
[    5.355634] ipmi_si 00:0b: [io  0x0ca2] regsize 1 spacing 1 irq 0
[    5.355705] ipmi_si: Adding ACPI-specified kcs state machine
[    5.355838] ipmi_si: probing via SMBIOS
[    5.355906] ipmi_si: SMBIOS: io 0xca2 regsize 1 spacing 1 irq 0
[    5.355977] ipmi_si: Adding SMBIOS-specified kcs state machine duplicate interface
[    5.356112] ipmi_si: probing via SPMI
[    5.356180] ipmi_si: SPMI: io 0xca2 regsize 1 spacing 1 irq 0
[    5.356250] ipmi_si: Adding SPMI-specified kcs state machine duplicate interface
[    5.356384] ipmi_si: Trying ACPI-specified kcs state machine at i/o address 0xca2, slave address 0x0, irq 0
[    5.489492] ipmi_si 00:0b: Found new BMC (man_id: 0x002a7c, prod_id: 0x0668, dev_id: 0x20)
[    5.489599] ipmi_si 00:0b: IPMI kcs interface initialized
[    5.521856] EDAC sbridge: Seeking for: dev 0e.0 PCI ID 8086:3ca0
[    5.521938] EDAC sbridge: Seeking for: dev 0e.0 PCI ID 8086:3ca0
[    5.522011] EDAC sbridge: Seeking for: dev 0f.0 PCI ID 8086:3ca8
[    5.522086] EDAC sbridge: Seeking for: dev 0f.0 PCI ID 8086:3ca8
[    5.522158] EDAC sbridge: Seeking for: dev 0f.1 PCI ID 8086:3c71
[    5.522233] EDAC sbridge: Seeking for: dev 0f.1 PCI ID 8086:3c71
[    5.522306] EDAC sbridge: Seeking for: dev 0f.2 PCI ID 8086:3caa
[    5.522381] EDAC sbridge: Seeking for: dev 0f.2 PCI ID 8086:3caa
[    5.522453] EDAC sbridge: Seeking for: dev 0f.3 PCI ID 8086:3cab
[    5.522528] EDAC sbridge: Seeking for: dev 0f.3 PCI ID 8086:3cab
[    5.522600] EDAC sbridge: Seeking for: dev 0f.4 PCI ID 8086:3cac
[    5.522675] EDAC sbridge: Seeking for: dev 0f.4 PCI ID 8086:3cac
[    5.522748] EDAC sbridge: Seeking for: dev 0f.5 PCI ID 8086:3cad
[    5.522823] EDAC sbridge: Seeking for: dev 0f.5 PCI ID 8086:3cad
[    5.522895] EDAC sbridge: Seeking for: dev 11.0 PCI ID 8086:3cb8
[    5.522971] EDAC sbridge: Seeking for: dev 11.0 PCI ID 8086:3cb8
[    5.523043] EDAC sbridge: Seeking for: dev 0c.6 PCI ID 8086:3cf4
[    5.523117] EDAC sbridge: Seeking for: dev 0c.6 PCI ID 8086:3cf4
[    5.523190] EDAC sbridge: Seeking for: dev 0c.7 PCI ID 8086:3cf6
[    5.523265] EDAC sbridge: Seeking for: dev 0c.7 PCI ID 8086:3cf6
[    5.523337] EDAC sbridge: Seeking for: dev 0d.6 PCI ID 8086:3cf5
[    5.523412] EDAC sbridge: Seeking for: dev 0d.6 PCI ID 8086:3cf5
[    5.523655] EDAC MC0: Giving out device to 'sbridge_edac.c' 'Sandy Bridge Socket#0': DEV 0000:ff:0e.0
[    5.523746] EDAC sbridge: Driver loaded.
[    5.656444] input: PC Speaker as /devices/platform/pcspkr/input/input2
[    5.700367] ACPI Warning: 0x0000000000000428-0x000000000000042f SystemIO conflicts with Region \PMIO 1 (20130725/utaddress-251)
[    5.700569] ACPI: If an ACPI driver is available for this device, you should use it instead of the native driver
[    5.700664] ACPI Warning: 0x0000000000000500-0x000000000000052f SystemIO conflicts with Region \GINV 1 (20130725/utaddress-251)
[    5.700859] ACPI Warning: 0x0000000000000500-0x000000000000052f SystemIO conflicts with Region \GPIO 2 (20130725/utaddress-251)
[    5.701048] ACPI Warning: 0x0000000000000500-0x000000000000052f SystemIO conflicts with Region \_SB_.PCI0.HEC2.GPO2 3 (20130725/utaddress-251)
[    5.701239] ACPI: If an ACPI driver is available for this device, you should use it instead of the native driver
[    5.701357] lpc_ich: Resource conflict(s) found affecting gpio_ich
[    5.851000] ACPI: bus type USB registered
[    5.851099] usbcore: registered new interface driver usbfs
[    5.851180] usbcore: registered new interface driver hub
[    5.851348] usbcore: registered new device driver usb
[    5.863037] ehci_hcd: USB 2.0 'Enhanced' Host Controller (EHCI) Driver
[    5.868291] iTCO_vendor_support: vendor-support=0
[    5.870399] ehci-pci: EHCI PCI platform driver
[    5.870619] ehci-pci 0000:00:1a.0: setting latency timer to 64
[    5.870641] ehci-pci 0000:00:1a.0: EHCI Host Controller
[    5.870717] ehci-pci 0000:00:1a.0: new USB bus registered, assigned bus number 1
[    5.870816] ehci-pci 0000:00:1a.0: debug port 2
[    5.874793] ehci-pci 0000:00:1a.0: cache line size of 64 is not supported
[    5.874827] ehci-pci 0000:00:1a.0: irq 16, io mem 0xfb823000
[    5.884721] ehci-pci 0000:00:1a.0: USB 2.0 started, EHCI 1.00
[    5.884839] usb usb1: New USB device found, idVendor=1d6b, idProduct=0002
[    5.884913] usb usb1: New USB device strings: Mfr=3, Product=2, SerialNumber=1
[    5.885001] usb usb1: Product: EHCI Host Controller
[    5.885071] usb usb1: Manufacturer: Linux 3.12.0-rc5+ ehci_hcd
[    5.885142] usb usb1: SerialNumber: 0000:00:1a.0
[    5.885345] hub 1-0:1.0: USB hub found
[    5.885420] hub 1-0:1.0: 2 ports detected
[    5.885744] ehci-pci 0000:00:1d.0: setting latency timer to 64
[    5.885761] ehci-pci 0000:00:1d.0: EHCI Host Controller
[    5.885836] ehci-pci 0000:00:1d.0: new USB bus registered, assigned bus number 2
[    5.885935] ehci-pci 0000:00:1d.0: debug port 2
[    5.889887] ehci-pci 0000:00:1d.0: cache line size of 64 is not supported
[    5.889923] ehci-pci 0000:00:1d.0: irq 23, io mem 0xfb822000
[    5.900708] ehci-pci 0000:00:1d.0: USB 2.0 started, EHCI 1.00
[    5.900817] usb usb2: New USB device found, idVendor=1d6b, idProduct=0002
[    5.900890] usb usb2: New USB device strings: Mfr=3, Product=2, SerialNumber=1
[    5.900978] usb usb2: Product: EHCI Host Controller
[    5.901048] usb usb2: Manufacturer: Linux 3.12.0-rc5+ ehci_hcd
[    5.901119] usb usb2: SerialNumber: 0000:00:1d.0
[    5.901300] hub 2-0:1.0: USB hub found
[    5.901374] hub 2-0:1.0: 2 ports detected
[    5.926812] iTCO_wdt: Intel TCO WatchDog Timer Driver v1.10
[    5.926906] iTCO_wdt: Found a Patsburg TCO device (Version=2, TCOBASE=0x0460)
[    5.927076] iTCO_wdt: initialized. heartbeat=30 sec (nowayout=0)
[    6.059469] alg: No test for __gcm-aes-aesni (__driver-gcm-aes-aesni)
[    6.097328] ioatdma: Intel(R) QuickData Technology Driver 4.00
[    6.097651] ioatdma 0000:00:04.0: irq 102 for MSI/MSI-X
[    6.097898] igb 0000:03:00.0: DCA enabled
[    6.097992] igb 0000:03:00.1: DCA enabled
[    6.098261] ioatdma 0000:00:04.1: irq 103 for MSI/MSI-X
[    6.098463] igb 0000:05:00.0: DCA enabled
[    6.098554] igb 0000:05:00.1: DCA enabled
[    6.098870] ioatdma 0000:00:04.2: irq 104 for MSI/MSI-X
[    6.099648] ioatdma 0000:00:04.3: irq 105 for MSI/MSI-X
[    6.100145] ioatdma 0000:00:04.4: irq 106 for MSI/MSI-X
[    6.100523] ioatdma 0000:00:04.5: irq 107 for MSI/MSI-X
[    6.100873] ioatdma 0000:00:04.6: irq 108 for MSI/MSI-X
[    6.101196] ioatdma 0000:00:04.7: irq 109 for MSI/MSI-X
[    6.117243] Error: Driver 'pcspkr' is already registered, aborting...
[    6.147760] i801_smbus 0000:00:1f.3: SMBus using PCI Interrupt
[    6.196732] usb 1-1: new high-speed USB device number 2 using ehci-pci
[    6.329119] usb 1-1: New USB device found, idVendor=8087, idProduct=0024
[    6.329205] usb 1-1: New USB device strings: Mfr=0, Product=0, SerialNumber=0
[    6.329680] hub 1-1:1.0: USB hub found
[    6.329865] hub 1-1:1.0: 6 ports detected
[    6.440832] usb 2-1: new high-speed USB device number 2 using ehci-pci
[    6.573115] usb 2-1: New USB device found, idVendor=8087, idProduct=0024
[    6.573195] usb 2-1: New USB device strings: Mfr=0, Product=0, SerialNumber=0
[    6.573708] hub 2-1:1.0: USB hub found
[    6.574023] hub 2-1:1.0: 8 ports detected
[    6.644898] usb 1-1.2: new full-speed USB device number 3 using ehci-pci
[    6.738838] usb 1-1.2: New USB device found, idVendor=0557, idProduct=2221
[    6.738915] usb 1-1.2: New USB device strings: Mfr=1, Product=2, SerialNumber=0
[    6.739003] usb 1-1.2: Product: Hermon USB hidmouse Device
[    6.739074] usb 1-1.2: Manufacturer: Winbond Electronics Corp
[    6.780045] hidraw: raw HID events driver (C) Jiri Kosina
[    6.783057] usbcore: registered new interface driver usbhid
[    6.783129] usbhid: USB HID core driver
[    6.797615] input: Winbond Electronics Corp Hermon USB hidmouse Device as /devices/pci0000:00/0000:00:1a.0/usb1/1-1/1-1.2/1-1.2:1.0/input/input3
[    6.797932] hid-generic 0003:0557:2221.0001: input,hidraw0: USB HID v1.00 Mouse [Winbond Electronics Corp Hermon USB hidmouse Device] on usb-0000:00:1a.0-1.2/input0
[    6.798302] input: Winbond Electronics Corp Hermon USB hidmouse Device as /devices/pci0000:00/0000:00:1a.0/usb1/1-1/1-1.2/1-1.2:1.1/input/input4
[    6.804236] hid-generic 0003:0557:2221.0002: input,hidraw1: USB HID v1.00 Keyboard [Winbond Electronics Corp Hermon USB hidmouse Device] on usb-0000:00:1a.0-1.2/input1
[    7.173766] Adding 16776116k swap on /dev/md1.  Priority:-1 extents:1 across:16776116k 
[    7.245067] EXT3-fs (md2): using internal journal
[    7.645797] loop: module loaded
[    7.866279] Fusion MPT base driver 3.04.20
[    7.866353] Copyright (c) 1999-2008 LSI Corporation
[    7.876599] Fusion MPT SPI Host driver 3.04.20
[    7.934363] nf_conntrack version 0.5.0 (16384 buckets, 65536 max)
[   11.286713] kjournald starting.  Commit interval 5 seconds
[   11.297889] EXT3-fs (md0): using internal journal
[   11.297979] EXT3-fs (md0): mounted filesystem with ordered data mode
[   11.741785] ISO 9660 Extensions: Microsoft Joliet Level 3
[   11.856191] ISO 9660 Extensions: RRIP_1991A
[   11.943248] ISO 9660 Extensions: Microsoft Joliet Level 3
[   11.960889] ISO 9660 Extensions: RRIP_1991A
[   12.230732] UDF-fs: warning (device loop5): udf_load_vrs: No anchor found
[   12.230809] UDF-fs: Rescanning with blocksize 2048
[   12.231938] UDF-fs: INFO Mounting volume 'UDF Volume', timestamp 2012/07/26 11:16 (1078)
[   12.232888] UDF-fs: warning (device loop6): udf_load_vrs: No anchor found
[   12.232963] UDF-fs: Rescanning with blocksize 2048
[   12.233264] UDF-fs: INFO Mounting volume 'UDF Volume', timestamp 2012/07/26 11:16 (1078)
[   12.312402] ISO 9660 Extensions: Microsoft Joliet Level 3
[   12.338617] ISO 9660 Extensions: RRIP_1991A
[   12.417054] ISO 9660 Extensions: Microsoft Joliet Level 3
[   12.435496] ISO 9660 Extensions: RRIP_1991A
[   12.479945] ISO 9660 Extensions: Microsoft Joliet Level 3
[   12.552621] ISO 9660 Extensions: RRIP_1991A
[   12.584928] ISO 9660 Extensions: Microsoft Joliet Level 3
[   12.600544] ISO 9660 Extensions: RRIP_1991A
[   12.646825] ISO 9660 Extensions: Microsoft Joliet Level 3
[   12.695972] ISO 9660 Extensions: RRIP_1991A
[   12.742522] ISO 9660 Extensions: Microsoft Joliet Level 3
[   12.817960] ISO 9660 Extensions: RRIP_1991A
[   12.897240] ISO 9660 Extensions: Microsoft Joliet Level 3
[   12.906041] ISO 9660 Extensions: RRIP_1991A
[   14.643674] bonding: Ethernet Channel Bonding Driver: v3.7.1 (April 27, 2011)
[   14.653771] bonding: bond0: Setting MII monitoring interval to 100.
[   14.657585] bonding: bond0: setting mode to balance-tlb (5).
[   14.660936] bonding: bond0: Adding slave eth0.
[   14.757431] bonding: bond0: enslaving eth0 as an active interface with a down link.
[   14.770985] bonding: bond0: Adding slave eth1.
[   14.865464] bonding: bond0: enslaving eth1 as an active interface with a down link.
[   14.869976] bonding: bond0: Adding slave eth2.
[   14.965313] bonding: bond0: enslaving eth2 as an active interface with a down link.
[   14.969795] bonding: bond0: Adding slave eth3.
[   15.065456] bonding: bond0: enslaving eth3 as an active interface with a down link.
[   15.073178] IPv6: ADDRCONF(NETDEV_UP): bond0: link is not ready
[   17.698053] igb: eth0 NIC Link is Up 1000 Mbps Full Duplex, Flow Control: RX
[   17.772814] bonding: bond0: link status definitely up for interface eth0, 1000 Mbps full duplex.
[   17.772915] bonding: bond0: making interface eth0 the new active one.
[   17.773076] bonding: bond0: first active interface up!
[   17.773159] IPv6: ADDRCONF(NETDEV_CHANGE): bond0: link becomes ready
[   17.814093] igb: eth1 NIC Link is Up 1000 Mbps Full Duplex, Flow Control: RX
[   17.872810] bonding: bond0: link status definitely up for interface eth1, 1000 Mbps full duplex.
[   17.902092] igb: eth2 NIC Link is Up 1000 Mbps Full Duplex, Flow Control: RX
[   17.972849] bonding: bond0: link status definitely up for interface eth2, 1000 Mbps full duplex.
[   18.082067] igb: eth3 NIC Link is Up 1000 Mbps Full Duplex, Flow Control: RX
[   18.172815] bonding: bond0: link status definitely up for interface eth3, 1000 Mbps full duplex.
[   19.080783] RTNL: assertion failed at drivers/net/bonding/bond_main.c (3398)
[   19.080868] CPU: 4 PID: 0 Comm: swapper/4 Not tainted 3.12.0-rc5+ #1
[   19.080944] Hardware name: Supermicro X9SRD-F/X9SRD-F, BIOS 1.0a 10/15/2012
[   19.081022]  0000000000000000 0000000000000000 ffffffff81373aba ffff88103e1a0000
[   19.081316]  ffffffffa040aea2 ffff88103e1a0000 0000000000000000 ffff88103e1a0000
[   19.081607]  ffffffff812c54f5 00000000ffffffff ffff88107fc83c90 ffff88107f000480
[   19.081912] Call Trace:
[   19.081982]  <IRQ>  [<ffffffff81373aba>] ? dump_stack+0x41/0x51
[   19.082176]  [<ffffffffa040aea2>] ? bond_set_rx_mode+0x2d/0xa7 [bonding]
[   19.082258]  [<ffffffff812c54f5>] ? __dev_mc_add+0x48/0x59
[   19.082337]  [<ffffffff8134d4ee>] ? igmp6_group_added+0x65/0x17d
[   19.082418]  [<ffffffff810fc836>] ? kmem_cache_alloc_trace+0xbb/0xcb
[   19.082497]  [<ffffffff8134e7dd>] ? ipv6_dev_mc_inc+0x20e/0x236
[   19.082578]  [<ffffffff81339f70>] ? addrconf_join_solict+0x2e/0x33
[   19.082656]  [<ffffffff81332e22>] ? ipv6_dev_ac_inc+0x131/0x16f
[   19.082735]  [<ffffffff81336f67>] ? addrconf_join_anycast+0x38/0x3e
[   19.082814]  [<ffffffff8133a0b1>] ? __ipv6_ifa_notify+0x106/0x234
[   19.082893]  [<ffffffff8133a20d>] ? ipv6_ifa_notify+0x2e/0x37
[   19.082971]  [<ffffffff8133a660>] ? addrconf_dad_completed+0x32/0x185
[   19.083050]  [<ffffffff8133a874>] ? addrconf_dad_timer+0xc1/0x13c
[   19.083129]  [<ffffffff8133a7b3>] ? addrconf_dad_completed+0x185/0x185
[   19.083210]  [<ffffffff81040613>] ? call_timer_fn+0x4b/0xf6
[   19.083288]  [<ffffffff8133a7b3>] ? addrconf_dad_completed+0x185/0x185
[   19.083367]  [<ffffffff81040c04>] ? run_timer_softirq+0x189/0x1ce
[   19.083448]  [<ffffffff8107c7dd>] ? tick_sched_do_timer+0x25/0x25
[   19.083527]  [<ffffffff8103ad68>] ? __do_softirq+0xe8/0x201
[   19.083606]  [<ffffffff81075d98>] ? ktime_get+0x5f/0x6b
[   19.083682]  [<ffffffff8107afca>] ? clockevents_program_event+0x9a/0xb6
[   19.083761]  [<ffffffff8137df5c>] ? call_softirq+0x1c/0x30
[   19.083839]  [<ffffffff81003b7c>] ? do_softirq+0x2c/0x60
[   19.083916]  [<ffffffff8103af46>] ? irq_exit+0x3b/0x7f
[   19.083994]  [<ffffffff81023b19>] ? smp_apic_timer_interrupt+0x2c/0x37
[   19.084074]  [<ffffffff8137d48a>] ? apic_timer_interrupt+0x6a/0x70
[   19.084149]  <EOI>  [<ffffffff8129a6b1>] ? cpuidle_enter_state+0x43/0xa6
[   19.084330]  [<ffffffff8129a6aa>] ? cpuidle_enter_state+0x3c/0xa6
[   19.084408]  [<ffffffff8129a7e6>] ? cpuidle_idle_call+0xd2/0x142
[   19.084486]  [<ffffffff81008ff9>] ? arch_cpu_idle+0x6/0x17
[   19.084563]  [<ffffffff8106f7e9>] ? cpu_startup_entry+0x10d/0x180
[   19.084641]  [<ffffffff8137780c>] ? _raw_spin_unlock_irqrestore+0x6/0x7
[   19.084726]  [<ffffffff810226dd>] ? start_secondary+0x1df/0x1e5
[  288.351173] 8021q: 802.1Q VLAN Support v1.8
[  288.351258] 8021q: adding VLAN 0 to HW filter on device eth0
[  288.351382] 8021q: adding VLAN 0 to HW filter on device eth1
[  288.351506] 8021q: adding VLAN 0 to HW filter on device eth2
[  288.351628] 8021q: adding VLAN 0 to HW filter on device eth3
[  288.351751] 8021q: adding VLAN 0 to HW filter on device bond0
[  290.160653] RTNL: assertion failed at drivers/net/bonding/bond_main.c (3398)
[  290.160740] CPU: 7 PID: 0 Comm: swapper/7 Not tainted 3.12.0-rc5+ #1
[  290.160816] Hardware name: Supermicro X9SRD-F/X9SRD-F, BIOS 1.0a 10/15/2012
[  290.160894]  0000000000000000 0000000000000000 ffffffff81373aba ffff88103e1a0000
[  290.161186]  ffffffffa040aea2 ffff88103e1a0000 0000000000000000 ffff88103e1a0204
[  290.161477]  ffffffff812c5c61 ffff88103e087000 ffff88103e087000 0000000000000000
[  290.161769] Call Trace:
[  290.161845]  <IRQ>  [<ffffffff81373aba>] ? dump_stack+0x41/0x51
[  290.162038]  [<ffffffffa040aea2>] ? bond_set_rx_mode+0x2d/0xa7 [bonding]
[  290.162122]  [<ffffffff812c5c61>] ? dev_mc_sync+0x58/0x6a
[  290.162200]  [<ffffffffa0429e67>] ? vlan_dev_set_rx_mode+0x13/0x23 [8021q]
[  290.162280]  [<ffffffff812c54f5>] ? __dev_mc_add+0x48/0x59
[  290.162360]  [<ffffffff8134d4ee>] ? igmp6_group_added+0x65/0x17d
[  290.162441]  [<ffffffff810fc836>] ? kmem_cache_alloc_trace+0xbb/0xcb
[  290.162519]  [<ffffffff8134e7dd>] ? ipv6_dev_mc_inc+0x20e/0x236
[  290.162599]  [<ffffffff81339f70>] ? addrconf_join_solict+0x2e/0x33
[  290.162678]  [<ffffffff81332e22>] ? ipv6_dev_ac_inc+0x131/0x16f
[  290.162756]  [<ffffffff81336f67>] ? addrconf_join_anycast+0x38/0x3e
[  290.162835]  [<ffffffff8133a0b1>] ? __ipv6_ifa_notify+0x106/0x234
[  290.162913]  [<ffffffff8133a20d>] ? ipv6_ifa_notify+0x2e/0x37
[  290.162991]  [<ffffffff8133a660>] ? addrconf_dad_completed+0x32/0x185
[  290.163070]  [<ffffffff8133a874>] ? addrconf_dad_timer+0xc1/0x13c
[  290.163148]  [<ffffffff8133a7b3>] ? addrconf_dad_completed+0x185/0x185
[  290.163228]  [<ffffffff81040613>] ? call_timer_fn+0x4b/0xf6
[  290.163305]  [<ffffffff8133a7b3>] ? addrconf_dad_completed+0x185/0x185
[  290.163384]  [<ffffffff81040c04>] ? run_timer_softirq+0x189/0x1ce
[  290.163464]  [<ffffffff8107c7dd>] ? tick_sched_do_timer+0x25/0x25
[  290.163543]  [<ffffffff8103ad68>] ? __do_softirq+0xe8/0x201
[  290.163621]  [<ffffffff81075d98>] ? ktime_get+0x5f/0x6b
[  290.163697]  [<ffffffff8107afca>] ? clockevents_program_event+0x9a/0xb6
[  290.163776]  [<ffffffff8137df5c>] ? call_softirq+0x1c/0x30
[  290.163854]  [<ffffffff81003b7c>] ? do_softirq+0x2c/0x60
[  290.163931]  [<ffffffff8103af46>] ? irq_exit+0x3b/0x7f
[  290.164009]  [<ffffffff81023b19>] ? smp_apic_timer_interrupt+0x2c/0x37
[  290.164089]  [<ffffffff8137d48a>] ? apic_timer_interrupt+0x6a/0x70
[  290.164164]  <EOI>  [<ffffffff8129a6b1>] ? cpuidle_enter_state+0x43/0xa6
[  290.164345]  [<ffffffff8129a6aa>] ? cpuidle_enter_state+0x3c/0xa6
[  290.164422]  [<ffffffff8129a7e6>] ? cpuidle_idle_call+0xd2/0x142
[  290.164500]  [<ffffffff81008ff9>] ? arch_cpu_idle+0x6/0x17
[  290.170083]  [<ffffffff8106f7e9>] ? cpu_startup_entry+0x10d/0x180
[  290.170161]  [<ffffffff8137780c>] ? _raw_spin_unlock_irqrestore+0x6/0x7
[  290.170240]  [<ffffffff810226dd>] ? start_secondary+0x1df/0x1e5
[  290.170377] RTNL: assertion failed at drivers/net/bonding/bond_main.c (3398)
[  290.170455] CPU: 7 PID: 0 Comm: swapper/7 Not tainted 3.12.0-rc5+ #1
[  290.170531] Hardware name: Supermicro X9SRD-F/X9SRD-F, BIOS 1.0a 10/15/2012
[  290.170607]  0000000000000000 0000000000000000 ffffffff81373aba ffff88103e1a0000
[  290.170897]  ffffffffa040aea2 ffff88103e1a0000 0000000000000000 ffff88103e1a0204
[  290.171186]  ffffffff812c5cca 0000000000000000 ffff88103e087000 0000000000000000
[  290.171484] Call Trace:
[  290.171554]  <IRQ>  [<ffffffff81373aba>] ? dump_stack+0x41/0x51
[  290.171734]  [<ffffffffa040aea2>] ? bond_set_rx_mode+0x2d/0xa7 [bonding]
[  290.171818]  [<ffffffff812c5cca>] ? dev_uc_sync+0x57/0x6a
[  290.171896]  [<ffffffff812c54f5>] ? __dev_mc_add+0x48/0x59
[  290.171974]  [<ffffffff8134d4ee>] ? igmp6_group_added+0x65/0x17d
[  290.172052]  [<ffffffff810fc836>] ? kmem_cache_alloc_trace+0xbb/0xcb
[  290.172132]  [<ffffffff8134e7dd>] ? ipv6_dev_mc_inc+0x20e/0x236
[  290.172210]  [<ffffffff81339f70>] ? addrconf_join_solict+0x2e/0x33
[  290.172288]  [<ffffffff81332e22>] ? ipv6_dev_ac_inc+0x131/0x16f
[  290.172366]  [<ffffffff81336f67>] ? addrconf_join_anycast+0x38/0x3e
[  290.172446]  [<ffffffff8133a0b1>] ? __ipv6_ifa_notify+0x106/0x234
[  290.172524]  [<ffffffff8133a20d>] ? ipv6_ifa_notify+0x2e/0x37
[  290.172604]  [<ffffffff8133a660>] ? addrconf_dad_completed+0x32/0x185
[  290.172683]  [<ffffffff8133a874>] ? addrconf_dad_timer+0xc1/0x13c
[  290.172762]  [<ffffffff8133a7b3>] ? addrconf_dad_completed+0x185/0x185
[  290.172840]  [<ffffffff81040613>] ? call_timer_fn+0x4b/0xf6
[  290.172918]  [<ffffffff8133a7b3>] ? addrconf_dad_completed+0x185/0x185
[  290.172997]  [<ffffffff81040c04>] ? run_timer_softirq+0x189/0x1ce
[  290.173074]  [<ffffffff8107c7dd>] ? tick_sched_do_timer+0x25/0x25
[  290.173153]  [<ffffffff8103ad68>] ? __do_softirq+0xe8/0x201
[  290.173229]  [<ffffffff81075d98>] ? ktime_get+0x5f/0x6b
[  290.173305]  [<ffffffff8107afca>] ? clockevents_program_event+0x9a/0xb6
[  290.173383]  [<ffffffff8137df5c>] ? call_softirq+0x1c/0x30
[  290.173459]  [<ffffffff81003b7c>] ? do_softirq+0x2c/0x60
[  290.173536]  [<ffffffff8103af46>] ? irq_exit+0x3b/0x7f
[  290.173612]  [<ffffffff81023b19>] ? smp_apic_timer_interrupt+0x2c/0x37
[  290.173690]  [<ffffffff8137d48a>] ? apic_timer_interrupt+0x6a/0x70
[  290.173765]  <EOI>  [<ffffffff8129a6b1>] ? cpuidle_enter_state+0x43/0xa6
[  290.173944]  [<ffffffff8129a6aa>] ? cpuidle_enter_state+0x3c/0xa6
[  290.174021]  [<ffffffff8129a7e6>] ? cpuidle_idle_call+0xd2/0x142
[  290.174098]  [<ffffffff81008ff9>] ? arch_cpu_idle+0x6/0x17
[  290.174175]  [<ffffffff8106f7e9>] ? cpu_startup_entry+0x10d/0x180
[  290.174252]  [<ffffffff8137780c>] ? _raw_spin_unlock_irqrestore+0x6/0x7
[  290.174331]  [<ffffffff810226dd>] ? start_secondary+0x1df/0x1e5
[  298.920399] RTNL: assertion failed at drivers/net/bonding/bond_main.c (3398)
[  298.920499] CPU: 7 PID: 4596 Comm: rpcbind Not tainted 3.12.0-rc5+ #1
[  298.920587] Hardware name: Supermicro X9SRD-F/X9SRD-F, BIOS 1.0a 10/15/2012
[  298.920676]  0000000000000000 0000000000000000 ffffffff81373aba ffff88103e1a0000
[  298.920949]  ffffffffa040aea2 ffff88103e1a0000 0000000000000000 ffff88103e1a0000
[  298.921220]  ffffffff812c54f5 00000000000000d0 ffff88103ca31c48 ffff88107f000480
[  298.921492] Call Trace:
[  298.921564]  [<ffffffff81373aba>] ? dump_stack+0x41/0x51
[  298.921639]  [<ffffffffa040aea2>] ? bond_set_rx_mode+0x2d/0xa7 [bonding]
[  298.921715]  [<ffffffff812c54f5>] ? __dev_mc_add+0x48/0x59
[  298.921789]  [<ffffffff8134d4ee>] ? igmp6_group_added+0x65/0x17d
[  298.921864]  [<ffffffff810fc836>] ? kmem_cache_alloc_trace+0xbb/0xcb
[  298.921937]  [<ffffffff8134e7dd>] ? ipv6_dev_mc_inc+0x20e/0x236
[  298.922010]  [<ffffffff8134e91b>] ? ipv6_sock_mc_join+0x116/0x171
[  298.922084]  [<ffffffff813442c4>] ? do_ipv6_setsockopt.isra.6+0x8e4/0xc57
[  298.922159]  [<ffffffff8110dd62>] ? full_name_hash+0x13/0x50
[  298.922232]  [<ffffffff812bd5f9>] ? dev_name_hash.isra.57+0x20/0x35
[  298.922305]  [<ffffffff812bd6fb>] ? dev_get_by_name_rcu+0x31/0x52
[  298.922378]  [<ffffffff810fac27>] ? __cache_free.isra.46+0x178/0x187
[  298.922453]  [<ffffffff81124f93>] ? __inode_wait_for_writeback+0x67/0xae
[  298.922527]  [<ffffffff810fac27>] ? __cache_free.isra.46+0x178/0x187
[  298.922602]  [<ffffffff81117164>] ? dentry_kill+0x13d/0x149
[  298.922674]  [<ffffffff813446ad>] ? compat_ipv6_setsockopt+0x76/0xc4
[  298.922752]  [<ffffffff812d7b61>] ? compat_sys_setsockopt+0x1df/0x203
[  298.922828]  [<ffffffff81059540>] ? should_resched+0x5/0x23
[  298.922900]  [<ffffffff812d7f3b>] ? compat_sys_socketcall+0x126/0x19f
[  298.922973]  [<ffffffff8137dff5>] ? sysenter_dispatch+0x7/0x1a
[  298.923117] RTNL: assertion failed at drivers/net/bonding/bond_main.c (3398)
[  298.923191] CPU: 7 PID: 4596 Comm: rpcbind Not tainted 3.12.0-rc5+ #1
[  298.923263] Hardware name: Supermicro X9SRD-F/X9SRD-F, BIOS 1.0a 10/15/2012
[  298.923336]  0000000000000000 0000000000000000 ffffffff81373aba ffff88103e1a0000
[  298.923623]  ffffffffa040aea2 ffff88103e1a0000 0000000000000000 ffff88103e1a0204
[  298.923924]  ffffffff812c5c61 ffff88103e087000 ffff88103e087000 0000000000000000
[  298.924225] Call Trace:
[  298.924300]  [<ffffffff81373aba>] ? dump_stack+0x41/0x51
[  298.924380]  [<ffffffffa040aea2>] ? bond_set_rx_mode+0x2d/0xa7 [bonding]
[  298.924460]  [<ffffffff812c5c61>] ? dev_mc_sync+0x58/0x6a
[  298.924539]  [<ffffffffa0429e67>] ? vlan_dev_set_rx_mode+0x13/0x23 [8021q]
[  298.924628]  [<ffffffff812c54f5>] ? __dev_mc_add+0x48/0x59
[  298.924716]  [<ffffffff8134d4ee>] ? igmp6_group_added+0x65/0x17d
[  298.924806]  [<ffffffff810fc836>] ? kmem_cache_alloc_trace+0xbb/0xcb
[  298.924885]  [<ffffffff8134e7dd>] ? ipv6_dev_mc_inc+0x20e/0x236
[  298.924962]  [<ffffffff8134e91b>] ? ipv6_sock_mc_join+0x116/0x171
[  298.925045]  [<ffffffff813442c4>] ? do_ipv6_setsockopt.isra.6+0x8e4/0xc57
[  298.925131]  [<ffffffff8110dd62>] ? full_name_hash+0x13/0x50
[  298.925214]  [<ffffffff812bd5f9>] ? dev_name_hash.isra.57+0x20/0x35
[  298.925296]  [<ffffffff812bd6fb>] ? dev_get_by_name_rcu+0x31/0x52
[  298.925375]  [<ffffffff810fac27>] ? __cache_free.isra.46+0x178/0x187
[  298.925455]  [<ffffffff81124f93>] ? __inode_wait_for_writeback+0x67/0xae
[  298.925534]  [<ffffffff810fac27>] ? __cache_free.isra.46+0x178/0x187
[  298.925613]  [<ffffffff81117164>] ? dentry_kill+0x13d/0x149
[  298.925691]  [<ffffffff813446ad>] ? compat_ipv6_setsockopt+0x76/0xc4
[  298.925771]  [<ffffffff812d7b61>] ? compat_sys_setsockopt+0x1df/0x203
[  298.925849]  [<ffffffff81059540>] ? should_resched+0x5/0x23
[  298.925927]  [<ffffffff812d7f3b>] ? compat_sys_socketcall+0x126/0x19f
[  298.926005]  [<ffffffff8137dff5>] ? sysenter_dispatch+0x7/0x1a
[  298.926143] RTNL: assertion failed at drivers/net/bonding/bond_main.c (3398)
[  298.926222] CPU: 7 PID: 4596 Comm: rpcbind Not tainted 3.12.0-rc5+ #1
[  298.926298] Hardware name: Supermicro X9SRD-F/X9SRD-F, BIOS 1.0a 10/15/2012
[  298.926374]  0000000000000000 0000000000000000 ffffffff81373aba ffff88103e1a0000
[  298.926678]  ffffffffa040aea2 ffff88103e1a0000 0000000000000000 ffff88103e1a0204
[  298.926967]  ffffffff812c5cca 0000000000000000 ffff88103e087000 0000000000000000
[  298.927256] Call Trace:
[  298.927330]  [<ffffffff81373aba>] ? dump_stack+0x41/0x51
[  298.927409]  [<ffffffffa040aea2>] ? bond_set_rx_mode+0x2d/0xa7 [bonding]
[  298.927489]  [<ffffffff812c5cca>] ? dev_uc_sync+0x57/0x6a
[  298.927566]  [<ffffffff812c54f5>] ? __dev_mc_add+0x48/0x59
[  298.927643]  [<ffffffff8134d4ee>] ? igmp6_group_added+0x65/0x17d
[  298.927726]  [<ffffffff810fc836>] ? kmem_cache_alloc_trace+0xbb/0xcb
[  298.927812]  [<ffffffff8134e7dd>] ? ipv6_dev_mc_inc+0x20e/0x236
[  298.927893]  [<ffffffff8134e91b>] ? ipv6_sock_mc_join+0x116/0x171
[  298.927972]  [<ffffffff813442c4>] ? do_ipv6_setsockopt.isra.6+0x8e4/0xc57
[  298.928050]  [<ffffffff8110dd62>] ? full_name_hash+0x13/0x50
[  298.928127]  [<ffffffff812bd5f9>] ? dev_name_hash.isra.57+0x20/0x35
[  298.928205]  [<ffffffff812bd6fb>] ? dev_get_by_name_rcu+0x31/0x52
[  298.928283]  [<ffffffff810fac27>] ? __cache_free.isra.46+0x178/0x187
[  298.928362]  [<ffffffff81124f93>] ? __inode_wait_for_writeback+0x67/0xae
[  298.928441]  [<ffffffff810fac27>] ? __cache_free.isra.46+0x178/0x187
[  298.928521]  [<ffffffff81117164>] ? dentry_kill+0x13d/0x149
[  298.928608]  [<ffffffff813446ad>] ? compat_ipv6_setsockopt+0x76/0xc4
[  298.928699]  [<ffffffff812d7b61>] ? compat_sys_setsockopt+0x1df/0x203
[  298.928790]  [<ffffffff81059540>] ? should_resched+0x5/0x23
[  298.928867]  [<ffffffff812d7f3b>] ? compat_sys_socketcall+0x126/0x19f
[  298.928945]  [<ffffffff8137dff5>] ? sysenter_dispatch+0x7/0x1a
[  299.185287] RPC: Registered named UNIX socket transport module.
[  299.185374] RPC: Registered udp transport module.
[  299.185443] RPC: Registered tcp transport module.
[  299.185511] RPC: Registered tcp NFSv4.1 backchannel transport module.
[  299.235908] FS-Cache: Loaded
[  299.264498] FS-Cache: Netfs 'nfs' registered for caching
[  299.298592] Installing knfsd (copyright (C) 1996 okir@monad.swb.de).
[  304.218323] Netfilter messages via NETLINK v0.30.
[  313.028841] tun: Universal TUN/TAP device driver, 1.6
[  313.028931] tun: (C) 1999-2004 Max Krasnyansky <maxk@qualcomm.com>
[  313.409097] ip_tables: (C) 2000-2006 Netfilter Core Team
[  314.231257] RTNL: assertion failed at drivers/net/bonding/bond_main.c (3398)
[  314.231336] CPU: 0 PID: 6146 Comm: avahi-daemon Not tainted 3.12.0-rc5+ #1
[  314.231410] Hardware name: Supermicro X9SRD-F/X9SRD-F, BIOS 1.0a 10/15/2012
[  314.231484]  0000000000000000 0000000000000000 ffffffff81373aba ffff88103e1a0000
[  314.231758]  ffffffffa040aea2 ffff88103e1a0000 0000000000000000 ffff88103e1a0204
[  314.232035]  ffffffff812c5c61 ffff88103e087000 ffff88103e087000 0000000000000000
[  314.232317] Call Trace:
[  314.232397]  [<ffffffff81373aba>] ? dump_stack+0x41/0x51
[  314.232475]  [<ffffffffa040aea2>] ? bond_set_rx_mode+0x2d/0xa7 [bonding]
[  314.232552]  [<ffffffff812c5c61>] ? dev_mc_sync+0x58/0x6a
[  314.232624]  [<ffffffffa0429e67>] ? vlan_dev_set_rx_mode+0x13/0x23 [8021q]
[  314.232699]  [<ffffffff812c54f5>] ? __dev_mc_add+0x48/0x59
[  314.232779]  [<ffffffff8134d4ee>] ? igmp6_group_added+0x65/0x17d
[  314.232856]  [<ffffffff810fc836>] ? kmem_cache_alloc_trace+0xbb/0xcb
[  314.232929]  [<ffffffff8134e7dd>] ? ipv6_dev_mc_inc+0x20e/0x236
[  314.233001]  [<ffffffff8134e91b>] ? ipv6_sock_mc_join+0x116/0x171
[  314.233076]  [<ffffffff813442c4>] ? do_ipv6_setsockopt.isra.6+0x8e4/0xc57
[  314.233151]  [<ffffffff812aeac3>] ? sock_sendmsg+0x49/0x64
[  314.233225]  [<ffffffff8111b33d>] ? fget_light+0x2e/0x7c
[  314.233297]  [<ffffffff812acbdc>] ? sockfd_lookup_light+0x17/0x4b
[  314.233369]  [<ffffffff812af517>] ? SYSC_sendto+0xec/0x101
[  314.233441]  [<ffffffff813446ad>] ? compat_ipv6_setsockopt+0x76/0xc4
[  314.233517]  [<ffffffff812d7b61>] ? compat_sys_setsockopt+0x1df/0x203
[  314.233591]  [<ffffffff812d7f3b>] ? compat_sys_socketcall+0x126/0x19f
[  314.233665]  [<ffffffff8137dff5>] ? sysenter_dispatch+0x7/0x1a
[  314.233794] RTNL: assertion failed at drivers/net/bonding/bond_main.c (3398)
[  314.233868] CPU: 0 PID: 6146 Comm: avahi-daemon Not tainted 3.12.0-rc5+ #1
[  314.233940] Hardware name: Supermicro X9SRD-F/X9SRD-F, BIOS 1.0a 10/15/2012
[  314.234013]  0000000000000000 0000000000000000 ffffffff81373aba ffff88103e1a0000
[  314.234285]  ffffffffa040aea2 ffff88103e1a0000 0000000000000000 ffff88103e1a0204
[  314.234558]  ffffffff812c5cca 0000000000000000 ffff88103e087000 0000000000000000
[  314.234831] Call Trace:
[  314.234897]  [<ffffffff81373aba>] ? dump_stack+0x41/0x51
[  314.234970]  [<ffffffffa040aea2>] ? bond_set_rx_mode+0x2d/0xa7 [bonding]
[  314.235044]  [<ffffffff812c5cca>] ? dev_uc_sync+0x57/0x6a
[  314.235123]  [<ffffffff812c54f5>] ? __dev_mc_add+0x48/0x59
[  314.235194]  [<ffffffff8134d4ee>] ? igmp6_group_added+0x65/0x17d
[  314.235274]  [<ffffffff810fc836>] ? kmem_cache_alloc_trace+0xbb/0xcb
[  314.235347]  [<ffffffff8134e7dd>] ? ipv6_dev_mc_inc+0x20e/0x236
[  314.235420]  [<ffffffff8134e91b>] ? ipv6_sock_mc_join+0x116/0x171
[  314.235493]  [<ffffffff813442c4>] ? do_ipv6_setsockopt.isra.6+0x8e4/0xc57
[  314.235566]  [<ffffffff812aeac3>] ? sock_sendmsg+0x49/0x64
[  314.235639]  [<ffffffff8111b33d>] ? fget_light+0x2e/0x7c
[  314.235710]  [<ffffffff812acbdc>] ? sockfd_lookup_light+0x17/0x4b
[  314.235782]  [<ffffffff812af517>] ? SYSC_sendto+0xec/0x101
[  314.235854]  [<ffffffff813446ad>] ? compat_ipv6_setsockopt+0x76/0xc4
[  314.235928]  [<ffffffff812d7b61>] ? compat_sys_setsockopt+0x1df/0x203
[  314.236002]  [<ffffffff812d7f3b>] ? compat_sys_socketcall+0x126/0x19f
[  314.236075]  [<ffffffff8137dff5>] ? sysenter_dispatch+0x7/0x1a
[  314.236393] RTNL: assertion failed at drivers/net/bonding/bond_main.c (3398)
[  314.236467] CPU: 0 PID: 6146 Comm: avahi-daemon Not tainted 3.12.0-rc5+ #1
[  314.236540] Hardware name: Supermicro X9SRD-F/X9SRD-F, BIOS 1.0a 10/15/2012
[  314.236613]  0000000000000000 0000000000000000 ffffffff81373aba ffff88103e1a0000
[  314.236889]  ffffffffa040aea2 ffff88103e1a0000 0000000000000000 ffff88103e1a0000
[  314.237162]  ffffffff812c54f5 00000000000000d0 ffff88102f5c5c48 ffff88107f000480
[  314.237434] Call Trace:
[  314.237501]  [<ffffffff81373aba>] ? dump_stack+0x41/0x51
[  314.237575]  [<ffffffffa040aea2>] ? bond_set_rx_mode+0x2d/0xa7 [bonding]
[  314.237649]  [<ffffffff812c54f5>] ? __dev_mc_add+0x48/0x59
[  314.237720]  [<ffffffff8134d4ee>] ? igmp6_group_added+0x65/0x17d
[  314.237794]  [<ffffffff810fc836>] ? kmem_cache_alloc_trace+0xbb/0xcb
[  314.237866]  [<ffffffff8134e7dd>] ? ipv6_dev_mc_inc+0x20e/0x236
[  314.237939]  [<ffffffff8134e91b>] ? ipv6_sock_mc_join+0x116/0x171
[  314.238018]  [<ffffffff813442c4>] ? do_ipv6_setsockopt.isra.6+0x8e4/0xc57
[  314.238093]  [<ffffffff812aeac3>] ? sock_sendmsg+0x49/0x64
[  314.238166]  [<ffffffff810dfc2a>] ? handle_mm_fault+0x22c/0x8aa
[  314.238239]  [<ffffffff8111b33d>] ? fget_light+0x2e/0x7c
[  314.238310]  [<ffffffff812acbdc>] ? sockfd_lookup_light+0x17/0x4b
[  314.238382]  [<ffffffff812af517>] ? SYSC_sendto+0xec/0x101
[  314.238454]  [<ffffffff813446ad>] ? compat_ipv6_setsockopt+0x76/0xc4
[  314.238528]  [<ffffffff81058942>] ? mmdrop+0xd/0x1c
[  314.238599]  [<ffffffff812d7b61>] ? compat_sys_setsockopt+0x1df/0x203
[  314.238674]  [<ffffffff81075fa6>] ? getnstimeofday+0x7/0x20
[  314.238746]  [<ffffffff812d7f3b>] ? compat_sys_socketcall+0x126/0x19f
[  314.238818]  [<ffffffff8137dff5>] ? sysenter_dispatch+0x7/0x1a
[  314.508396] NFSD: Using /var/lib/nfs/v4recovery as the NFSv4 state recovery directory
[  314.528759] NFSD: starting 90-second grace period (net ffffffff81678200)
[  320.219271] postgres (6634): /proc/6634/oom_adj is deprecated, please use /proc/6634/oom_score_adj instead.

Howto reproduce:

        - Build the kernel from Torvalds tip
        - Configure bonding with tlb with one NIC.

auto bond0
iface bond0 inet static
        address ...
        netmask ...
        network ...
        broadcast  ...
        gateway ...
        bond-mode balance-tlb
        bond-miimon 100
        slaves eth0
        # eth1 eth2 eth3

Cheers,
        Thomas
