From: Shawn Bohrer <sbohrer@rgmadvisors.com>
Subject: rtnl_lock deadlock on 3.10
Date: Mon, 1 Jul 2013 09:54:56 -0500
Message-ID: <20130701145456.GA7756@sbohrermbp13-local.rgmadvisors.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 8BIT
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from na3sys009aog133.obsmtp.com ([74.125.149.82]:59323 "EHLO
	na3sys009aog133.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753148Ab3GAOzF convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 1 Jul 2013 10:55:05 -0400
Received: by mail-vb0-f49.google.com with SMTP id 12so3617257vbf.22
        for <netdev@vger.kernel.org>; Mon, 01 Jul 2013 07:55:04 -0700 (PDT)
Received: from sbohrermbp13-local.rgmadvisors.com ([173.227.92.65])
        by mx.google.com with ESMTPSA id q2sm13335838vef.3.2013.07.01.07.55.03
        for <netdev@vger.kernel.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Mon, 01 Jul 2013 07:55:03 -0700 (PDT)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I've managed to hit a deadlock at boot a couple times while testing
the 3.10 rc kernels.  It seems to always happen when my network
devices are initializing.  This morning I updated to v3.10 and made a
few config tweaks and so far I've hit it 4 out of 5 reboots.  It looks
like most processes are getting stuck on rtnl_lock.  Below is a boot
log with the soft lockup prints.  Please let know if there is any
other information I can provide:


[    0.000000] Initializing cgroup subsys cpuset
[    0.000000] Linux version 3.10.0-00010-g1ae679b (sbohrer@berbox1) (gcc version 4.6.3 20120306 (Red Hat 4.6.3-2) (GCC) ) #38 SMP Mon Jul 1 09:02:58 CDT 2013
[    0.000000] Command line: BOOT_IMAGE=/vmlinuz-3.10.0-00010-g1ae679b root=UUID=0c3085f9-e876-4196-91f4-06cdad33a871 ro processor.max_cstate=0 skew_tick=1 crashkernel=128M audit=0 selinux=0 rd.md=0 rd.lvm=0 rd.luks=0 LANG=en_US.UTF-8 SYSFONT=latarcyrheb-sun16 KEYTABLE=us rd.dm=0 vga=775 consoleblank=0 uhash_entries=65536 console=ttyS1,115200 console=tty0
[    0.000000] e820: BIOS-provided physical RAM map:
[    0.000000] BIOS-e820: [mem 0x0000000000000000-0x000000000009dfff] usable
[    0.000000] BIOS-e820: [mem 0x0000000000100000-0x00000000cf378fff] usable
[    0.000000] BIOS-e820: [mem 0x00000000cf379000-0x00000000cf38efff] reserved
[    0.000000] BIOS-e820: [mem 0x00000000cf38f000-0x00000000cf3cdfff] ACPI data
[    0.000000] BIOS-e820: [mem 0x00000000cf3ce000-0x00000000cfffffff] reserved
[    0.000000] BIOS-e820: [mem 0x00000000e0000000-0x00000000efffffff] reserved
[    0.000000] BIOS-e820: [mem 0x00000000fe000000-0x00000000ffffffff] reserved
[    0.000000] BIOS-e820: [mem 0x0000000100000000-0x0000000c2fffffff] usable
[    0.000000] NX (Execute Disable) protection: active
[    0.000000] SMBIOS 2.6 present.
[    0.000000] No AGP bridge found
[    0.000000] e820: last_pfn = 0xc30000 max_arch_pfn = 0x400000000
[    0.000000] x86 PAT enabled: cpu 0, old 0x7040600070406, new 0x7010600070106
[    0.000000] e820: last_pfn = 0xcf379 max_arch_pfn = 0x400000000
[    0.000000] found SMP MP-table at [mem 0x000fe710-0x000fe71f] mapped at [ffff8800000fe710]
[    0.000000] Using GB pages for direct mapping
[    0.000000] init_memory_mapping: [mem 0x00000000-0x000fffff]
[    0.000000] init_memory_mapping: [mem 0xc2fe00000-0xc2fffffff]
[    0.000000] init_memory_mapping: [mem 0xc2c000000-0xc2fdfffff]
[    0.000000] init_memory_mapping: [mem 0xc00000000-0xc2bffffff]
[    0.000000] init_memory_mapping: [mem 0x00100000-0xcf378fff]
[    0.000000] init_memory_mapping: [mem 0x100000000-0xbffffffff]
[    0.000000] RAMDISK: [mem 0x364fe000-0x37276fff]
[    0.000000] Reserving 128MB of memory at 736MB for crashkernel (System RAM: 49139MB)
[    0.000000] ACPI: RSDP 00000000000f1150 00024 (v02 DELL  )
[    0.000000] ACPI: XSDT 00000000000f1254 0009C (v01 DELL   PE_SC3   00000001 DELL 00000001)
[    0.000000] ACPI: FACP 00000000cf3b3f9c 000F4 (v03 DELL   PE_SC3   00000001 DELL 00000001)
[    0.000000] ACPI: DSDT 00000000cf38f000 03DD0 (v01 DELL   PE_SC3   00000001 INTL 20050624)
[    0.000000] ACPI: FACS 00000000cf3b6000 00040
[    0.000000] ACPI: APIC 00000000cf3b3478 0015E (v01 DELL   PE_SC3   00000001 DELL 00000001)
[    0.000000] ACPI: SPCR 00000000cf3b35d8 00050 (v01 DELL   PE_SC3   00000001 DELL 00000001)
[    0.000000] ACPI: HPET 00000000cf3b362c 00038 (v01 DELL   PE_SC3   00000001 DELL 00000001)
[    0.000000] ACPI: DM__ 00000000cf3b3668 001A8 (v01 DELL   PE_SC3   00000001 DELL 00000001)
[    0.000000] ACPI: MCFG 00000000cf3b38c4 0003C (v01 DELL   PE_SC3   00000001 DELL 00000001)
[    0.000000] ACPI: WD__ 00000000cf3b3904 00134 (v01 DELL   PE_SC3   00000001 DELL 00000001)
[    0.000000] ACPI: SLIC 00000000cf3b3a3c 00024 (v01 DELL   PE_SC3   00000001 DELL 00000001)
[    0.000000] ACPI: ERST 00000000cf392f70 00270 (v01 DELL   PE_SC3   00000001 DELL 00000001)
[    0.000000] ACPI: HEST 00000000cf3931e0 003A8 (v01 DELL   PE_SC3   00000001 DELL 00000001)
[    0.000000] ACPI: BERT 00000000cf392dd0 00030 (v01 DELL   PE_SC3   00000001 DELL 00000001)
[    0.000000] ACPI: EINJ 00000000cf392e00 00170 (v01 DELL   PE_SC3   00000001 DELL 00000001)
[    0.000000] ACPI: SRAT 00000000cf3b3bc0 00370 (v01 DELL   PE_SC3   00000001 DELL 00000001)
[    0.000000] ACPI: TCPA 00000000cf3b3f34 00064 (v02 DELL   PE_SC3   00000001 DELL 00000001)
[    0.000000] ACPI: SSDT 00000000cf3b7000 07B84 (v01  INTEL PPM RCM  80000001 INTL 20061109)
[    0.000000] SRAT: PXM 1 -> APIC 0x20 -> Node 0
[    0.000000] SRAT: PXM 2 -> APIC 0x00 -> Node 1
[    0.000000] SRAT: PXM 1 -> APIC 0x22 -> Node 0
[    0.000000] SRAT: PXM 2 -> APIC 0x02 -> Node 1
[    0.000000] SRAT: PXM 1 -> APIC 0x24 -> Node 0
[    0.000000] SRAT: PXM 2 -> APIC 0x04 -> Node 1
[    0.000000] SRAT: PXM 1 -> APIC 0x30 -> Node 0
[    0.000000] SRAT: PXM 2 -> APIC 0x10 -> Node 1
[    0.000000] SRAT: PXM 1 -> APIC 0x32 -> Node 0
[    0.000000] SRAT: PXM 2 -> APIC 0x12 -> Node 1
[    0.000000] SRAT: PXM 1 -> APIC 0x34 -> Node 0
[    0.000000] SRAT: PXM 2 -> APIC 0x14 -> Node 1
[    0.000000] SRAT: PXM 1 -> APIC 0x21 -> Node 0
[    0.000000] SRAT: PXM 2 -> APIC 0x01 -> Node 1
[    0.000000] SRAT: PXM 1 -> APIC 0x23 -> Node 0
[    0.000000] SRAT: PXM 2 -> APIC 0x03 -> Node 1
[    0.000000] SRAT: PXM 1 -> APIC 0x25 -> Node 0
[    0.000000] SRAT: PXM 2 -> APIC 0x05 -> Node 1
[    0.000000] SRAT: PXM 1 -> APIC 0x31 -> Node 0
[    0.000000] SRAT: PXM 2 -> APIC 0x11 -> Node 1
[    0.000000] SRAT: PXM 1 -> APIC 0x33 -> Node 0
[    0.000000] SRAT: PXM 2 -> APIC 0x13 -> Node 1
[    0.000000] SRAT: PXM 1 -> APIC 0x35 -> Node 0
[    0.000000] SRAT: PXM 2 -> APIC 0x15 -> Node 1
[    0.000000] SRAT: Node 1 PXM 2 [mem 0x00000000-0xcfffffff]
[    0.000000] SRAT: Node 1 PXM 2 [mem 0x100000000-0x62fffffff]
[    0.000000] SRAT: Node 0 PXM 1 [mem 0x630000000-0xc2fffffff]
[    0.000000] NUMA: Node 1 [mem 0x00000000-0xcfffffff] + [mem 0x100000000-0x62fffffff] -> [mem 0x00000000-0x62fffffff]
[    0.000000] Initmem setup node 0 [mem 0x630000000-0xc2fffffff]
[    0.000000]   NODE_DATA [mem 0xc2ffea000-0xc2fffdfff]
[    0.000000] Initmem setup node 1 [mem 0x00000000-0x62fffffff]
[    0.000000]   NODE_DATA [mem 0x62ffec000-0x62fffffff]
[    0.000000] Zone ranges:
[    0.000000]   DMA      [mem 0x00001000-0x00ffffff]
[    0.000000]   DMA32    [mem 0x01000000-0xffffffff]
[    0.000000]   Normal   [mem 0x100000000-0xc2fffffff]
[    0.000000] Movable zone start for each node
[    0.000000] Early memory node ranges
[    0.000000]   node   1: [mem 0x00001000-0x0009dfff]
[    0.000000]   node   1: [mem 0x00100000-0xcf378fff]
[    0.000000]   node   1: [mem 0x100000000-0x62fffffff]
[    0.000000]   node   0: [mem 0x630000000-0xc2fffffff]
[    0.000000] ACPI: PM-Timer IO Port: 0x808
[    0.000000] ACPI: LAPIC (acpi_id[0x01] lapic_id[0x20] enabled)
[    0.000000] ACPI: LAPIC (acpi_id[0x02] lapic_id[0x00] enabled)
[    0.000000] ACPI: LAPIC (acpi_id[0x03] lapic_id[0x22] enabled)
[    0.000000] ACPI: LAPIC (acpi_id[0x04] lapic_id[0x02] enabled)
[    0.000000] ACPI: LAPIC (acpi_id[0x05] lapic_id[0x24] enabled)
[    0.000000] ACPI: LAPIC (acpi_id[0x06] lapic_id[0x04] enabled)
[    0.000000] ACPI: LAPIC (acpi_id[0x07] lapic_id[0x30] enabled)
[    0.000000] ACPI: LAPIC (acpi_id[0x08] lapic_id[0x10] enabled)
[    0.000000] ACPI: LAPIC (acpi_id[0x09] lapic_id[0x32] enabled)
[    0.000000] ACPI: LAPIC (acpi_id[0x0a] lapic_id[0x12] enabled)
[    0.000000] ACPI: LAPIC (acpi_id[0x0b] lapic_id[0x34] enabled)
[    0.000000] ACPI: LAPIC (acpi_id[0x0c] lapic_id[0x14] enabled)
[    0.000000] ACPI: LAPIC (acpi_id[0x0d] lapic_id[0x21] enabled)
[    0.000000] ACPI: LAPIC (acpi_id[0x0e] lapic_id[0x01] enabled)
[    0.000000] ACPI: LAPIC (acpi_id[0x0f] lapic_id[0x23] enabled)
[    0.000000] ACPI: LAPIC (acpi_id[0x10] lapic_id[0x03] enabled)
[    0.000000] ACPI: LAPIC (acpi_id[0x11] lapic_id[0x25] enabled)
[    0.000000] ACPI: LAPIC (acpi_id[0x12] lapic_id[0x05] enabled)
[    0.000000] ACPI: LAPIC (acpi_id[0x13] lapic_id[0x31] enabled)
[    0.000000] ACPI: LAPIC (acpi_id[0x14] lapic_id[0x11] enabled)
[    0.000000] ACPI: LAPIC (acpi_id[0x15] lapic_id[0x33] enabled)
[    0.000000] ACPI: LAPIC (acpi_id[0x16] lapic_id[0x13] enabled)
[    0.000000] ACPI: LAPIC (acpi_id[0x17] lapic_id[0x35] enabled)
[    0.000000] ACPI: LAPIC (acpi_id[0x18] lapic_id[0x15] enabled)
[    0.000000] ACPI: LAPIC (acpi_id[0x19] lapic_id[0xff] disabled)
[    0.000000] ACPI: LAPIC (acpi_id[0x1a] lapic_id[0xff] disabled)
[    0.000000] ACPI: LAPIC (acpi_id[0x1b] lapic_id[0xff] disabled)
[    0.000000] ACPI: LAPIC (acpi_id[0x1c] lapic_id[0xff] disabled)
[    0.000000] ACPI: LAPIC (acpi_id[0x1d] lapic_id[0xff] disabled)
[    0.000000] ACPI: LAPIC (acpi_id[0x1e] lapic_id[0xff] disabled)
[    0.000000] ACPI: LAPIC (acpi_id[0x1f] lapic_id[0xff] disabled)
[    0.000000] ACPI: LAPIC (acpi_id[0x20] lapic_id[0xff] disabled)
[    0.000000] ACPI: LAPIC_NMI (acpi_id[0xff] high edge lint[0x1])
[    0.000000] ACPI: IOAPIC (id[0x00] address[0xfec00000] gsi_base[0])
[    0.000000] IOAPIC[0]: apic_id 0, version 32, address 0xfec00000, GSI 0-23
[    0.000000] ACPI: IOAPIC (id[0x01] address[0xfec80000] gsi_base[32])
[    0.000000] IOAPIC[1]: apic_id 1, version 32, address 0xfec80000, GSI 32-55
[    0.000000] ACPI: INT_SRC_OVR (bus 0 bus_irq 0 global_irq 2 dfl dfl)
[    0.000000] ACPI: INT_SRC_OVR (bus 0 bus_irq 9 global_irq 9 high level)
[    0.000000] Using ACPI (MADT) for SMP configuration information
[    0.000000] ACPI: HPET id: 0x8086a301 base: 0xfed00000
[    0.000000] smpboot: Allowing 24 CPUs, 0 hotplug CPUs
[    0.000000] e820: [mem 0xd0000000-0xdfffffff] available for PCI devices
[    0.000000] setup_percpu: NR_CPUS:256 nr_cpumask_bits:256 nr_cpu_ids:24 nr_node_ids:2
[    0.000000] PERCPU: Embedded 27 pages/cpu @ffff880617c00000 s79936 r8192 d22464 u131072
[    0.000000] Built 2 zonelists in Zone order, mobility grouping on.  Total pages: 12383027
[    0.000000] Policy zone: Normal
[    0.000000] Kernel command line: BOOT_IMAGE=/vmlinuz-3.10.0-00010-g1ae679b root=UUID=0c3085f9-e876-4196-91f4-06cdad33a871 ro processor.max_cstate=0 skew_tick=1 crashkernel=128M audit=0 selinux=0 rd.md=0 rd.lvm=0 rd.luks=0 LANG=en_US.UTF-8 SYSFONT=latarcyrheb-sun16 KEYTABLE=us rd.dm=0 vga=775 consoleblank=0 uhash_entries=65536 console=ttyS1,115200 console=tty0
[    0.000000] PID hash table entries: 4096 (order: 3, 32768 bytes)
[    0.000000] Checking aperture...
[    0.000000] No AGP bridge found
[    0.000000] Memory: 49304580k/51118080k available (4935k kernel code, 799656k absent, 1013844k reserved, 6106k data, 1240k init)
[    0.000000] SLUB: HWalign=64, Order=0-3, MinObjects=0, CPUs=24, Nodes=2
[    0.000000] Hierarchical RCU implementation.
[    0.000000] 	RCU restricting CPUs from NR_CPUS=256 to nr_cpu_ids=24.
[    0.000000] NR_IRQS:16640 nr_irqs:1416 16
[    0.000000] Console: colour dummy device 80x25
[    0.000000] console [tty0] enabled
[    0.000000] console [ttyS1] enabled
[    0.000000] tsc: Fast TSC calibration using PIT
[    0.001000] tsc: Detected 3325.033 MHz processor
[    0.000006] Calibrating delay loop (skipped), value calculated using timer frequency.. 6650.06 BogoMIPS (lpj=3325033)
[    0.010614] pid_max: default: 32768 minimum: 301
[    0.018186] Dentry cache hash table entries: 8388608 (order: 14, 67108864 bytes)
[    0.037079] Inode-cache hash table entries: 4194304 (order: 13, 33554432 bytes)
[    0.049531] Mount-cache hash table entries: 256
[    0.054268] Initializing cgroup subsys net_cls
[    0.058729] CPU: Physical Processor ID: 1
[    0.062733] CPU: Processor Core ID: 0
[    0.066393] mce: CPU supports 9 MCE banks
[    0.070404] CPU0: Thermal monitoring enabled (TM1)
[    0.075194] Last level iTLB entries: 4KB 512, 2MB 7, 4MB 7
[    0.075194] Last level dTLB entries: 4KB 512, 2MB 32, 4MB 32
[    0.075194] tlb_flushall_shift: 6
[    0.089673] Freeing SMP alternatives: 20k freed
[    0.094202] ACPI: Core revision 20130328
[    0.099555] ACPI: All ACPI Tables successfully acquired
[    0.104896] ftrace: allocating 18845 entries in 74 pages
[    0.117351] Switched APIC routing to physical flat.
[    0.122738] ..TIMER: vector=0x30 apic1=0 pin1=2 apic2=-1 pin2=-1
[    0.138731] smpboot: CPU0: Intel(R) Xeon(R) CPU           X5680  @ 3.33GHz (fam: 06, model: 2c, stepping: 02)
[    0.250634] Performance Events: PEBS fmt1+, 16-deep LBR, Westmere events, Intel PMU driver.
[    0.259008] perf_event_intel: CPUID marked event: 'bus cycles' unavailable
[    0.265867] ... version:                3
[    0.269865] ... bit width:              48
[    0.273948] ... generic registers:      4
[    0.277945] ... value mask:             0000ffffffffffff
[    0.283243] ... max period:             000000007fffffff
[    0.288542] ... fixed-purpose events:   3
[    0.292540] ... event mask:             000000070000000f
[    0.298904] smpboot: Booting Node   1, Processors  #1 OK
[    0.395179] smpboot: Booting Node   0, Processors  #2 OK
[    0.413819] smpboot: Booting Node   1, Processors  #3 OK
[    0.432403] smpboot: Booting Node   0, Processors  #4 OK
[    0.451039] smpboot: Booting Node   1, Processors  #5 OK
[    0.469618] smpboot: Booting Node   0, Processors  #6 OK
[    0.488250] smpboot: Booting Node   1, Processors  #7 OK
[    0.506833] smpboot: Booting Node   0, Processors  #8 OK
[    0.525464] smpboot: Booting Node   1, Processors  #9 OK
[    0.544045] smpboot: Booting Node   0, Processors  #10 OK
[    0.562764] smpboot: Booting Node   1, Processors  #11 OK
[    0.581429] smpboot: Booting Node   0, Processors  #12 OK
[    0.600305] smpboot: Booting Node   1, Processors  #13 OK
[    0.618976] smpboot: Booting Node   0, Processors  #14 OK
[    0.637700] smpboot: Booting Node   1, Processors  #15 OK
[    0.656365] smpboot: Booting Node   0, Processors  #16 OK
[    0.675083] smpboot: Booting Node   1, Processors  #17 OK
[    0.693755] smpboot: Booting Node   0, Processors  #18 OK
[    0.712480] smpboot: Booting Node   1, Processors  #19 OK
[    0.731149] smpboot: Booting Node   0, Processors  #20 OK
[    0.749864] smpboot: Booting Node   1, Processors  #21 OK
[    0.768537] smpboot: Booting Node   0, Processors  #22 OK
[    0.787252] smpboot: Booting Node   1, Processors  #23 OK
[    0.805873] Brought up 24 CPUs
[    0.808919] smpboot: Total of 24 processors activated (159597.52 BogoMIPS)
[    0.841156] devtmpfs: initialized
[    0.845369] regulator-dummy: no parameters
[    0.849508] NET: Registered protocol family 16
[    0.854052] ACPI FADT declares the system doesn't support PCIe ASPM, so disable it
[    0.861605] ACPI: bus type PCI registered
[    0.865664] PCI: MMCONFIG for domain 0000 [bus 00-ff] at [mem 0xe0000000-0xefffffff] (base 0xe0000000)
[    0.874957] PCI: MMCONFIG at [mem 0xe0000000-0xefffffff] reserved in E820
[    0.888975] PCI: Using configuration type 1 for base access
[    0.895613] bio: create slab <bio-0> at 0
[    0.899824] ACPI: Added _OSI(Module Device)
[    0.903997] ACPI: Added _OSI(Processor Device)
[    0.908427] ACPI: Added _OSI(3.0 _SCP Extensions)
[    0.913118] ACPI: Added _OSI(Processor Aggregator Device)
[    0.919469] [Firmware Bug]: ACPI: BIOS _OSI(Linux) query ignored
[    0.927301] ACPI: Interpreter enabled
[    0.930958] ACPI: (supports S0 S5)
[    0.934349] ACPI: Using IOAPIC for interrupt routing
[    0.939316] PCI: Using host bridge windows from ACPI; if necessary, use "pci=nocrs" and report a bug
[    0.948461] ACPI: No dock devices found.
[    0.956309] ACPI: PCI Root Bridge [PCI0] (domain 0000 [bus 00-ff])
[    0.962662] PCI host bridge to bus 0000:00
[    0.966750] pci_bus 0000:00: root bus resource [bus 00-ff]
[    0.972221] pci_bus 0000:00: root bus resource [io  0x0000-0x0cf7]
[    0.978386] pci_bus 0000:00: root bus resource [io  0x0d00-0xffff]
[    0.984551] pci_bus 0000:00: root bus resource [mem 0x000a0000-0x000bffff]
[    0.991411] pci_bus 0000:00: root bus resource [mem 0xd0000000-0xfdffffff]
[    0.998271] pci_bus 0000:00: root bus resource [mem 0xfed40000-0xfed44fff]
[    1.006656] pci 0000:00:1f.0: quirk: [io  0x0800-0x087f] claimed by ICH6 ACPI/GPIO/TCO
[    1.014559] pci 0000:00:1f.0: quirk: [io  0x0880-0x08bf] claimed by ICH6 GPIO
[    1.021681] pci 0000:00:1f.0: ICH7 LPC Generic IO decode 1 PIO at 0c00 (mask 007f)
[    1.029235] pci 0000:00:1f.0: ICH7 LPC Generic IO decode 2 PIO at 0ca0 (mask 000f)
[    1.036789] pci 0000:00:1f.0: ICH7 LPC Generic IO decode 3 PIO at 00e0 (mask 000f)
[    1.046668] pci 0000:00:01.0: PCI bridge to [bus 01]
[    1.053667] pci 0000:00:03.0: PCI bridge to [bus 02]
[    1.060667] pci 0000:00:07.0: PCI bridge to [bus 04]
[    1.069737] pci 0000:00:09.0: PCI bridge to [bus 05]
[    1.076669] pci 0000:00:1c.0: PCI bridge to [bus 03]
[    1.081791] pci 0000:00:1e.0: PCI bridge to [bus 06] (subtractive decode)
[    1.088664] acpi PNP0A08:00: Requesting ACPI _OSC control (0x1d)
[    1.094785] acpi PNP0A08:00: ACPI _OSC control (0x1d) granted
[    1.101693] ACPI: PCI Interrupt Link [LK00] (IRQs 3 4 5 6 7 10 11 14 *15)
[    1.108608] ACPI: PCI Interrupt Link [LK01] (IRQs 3 4 5 6 7 10 11 *14 15)
[    1.115520] ACPI: PCI Interrupt Link [LK02] (IRQs 3 4 5 6 7 10 *11 14 15)
[    1.122428] ACPI: PCI Interrupt Link [LK03] (IRQs 3 4 5 6 7 *10 11 14 15)
[    1.129340] ACPI: PCI Interrupt Link [LK04] (IRQs 3 4 *5 6 7 10 11 14 15)
[    1.136253] ACPI: PCI Interrupt Link [LK05] (IRQs 3 4 5 *6 7 10 11 14 15)
[    1.143164] ACPI: PCI Interrupt Link [LK06] (IRQs 3 4 5 6 7 10 11 14 15) *0, disabled.
[    1.151221] ACPI: PCI Interrupt Link [LK07] (IRQs 3 4 5 6 7 10 11 *14 15)
[    1.158125] ACPI: Enabled 1 GPEs in block 00 to 3F
[    1.162984] vgaarb: device added: PCI:0000:06:03.0,decodes=io+mem,owns=io+mem,locks=none
[    1.171057] vgaarb: loaded
[    1.173756] vgaarb: bridge control possible 0000:06:03.0
[    1.179095] SCSI subsystem initialized
[    1.182849] ACPI: bus type USB registered
[    1.186857] usbcore: registered new interface driver usbfs
[    1.192334] usbcore: registered new interface driver hub
[    1.197654] usbcore: registered new device driver usb
[    1.202784] PCI: Using ACPI for IRQ routing
[    1.212093] PCI: Discovered peer bus fe
[    1.215928] PCI host bridge to bus 0000:fe
[    1.220014] pci_bus 0000:fe: root bus resource [io  0x0000-0xffff]
[    1.226179] pci_bus 0000:fe: root bus resource [mem 0x00000000-0xffffffffff]
[    1.233212] pci_bus 0000:fe: No busn resource found for root bus, will use [bus fe-ff]
[    1.241633] PCI: Discovered peer bus ff
[    1.245466] PCI host bridge to bus 0000:ff
[    1.249551] pci_bus 0000:ff: root bus resource [io  0x0000-0xffff]
[    1.255717] pci_bus 0000:ff: root bus resource [mem 0x00000000-0xffffffffff]
[    1.262750] pci_bus 0000:ff: No busn resource found for root bus, will use [bus ff-ff]
[    1.271441] hpet0: at MMIO 0xfed00000, IRQs 2, 8, 0, 0
[    1.276612] hpet0: 4 comparators, 64-bit 14.318180 MHz counter
[    1.284443] Switching to clocksource hpet
[    1.292382] pnp: PnP ACPI init
[    1.295437] ACPI: bus type PNP registered
[    1.300734] system 00:06: [io  0x0800-0x087f] has been reserved
[    1.306644] system 00:06: [io  0x0880-0x08ff] could not be reserved
[    1.312901] system 00:06: [io  0x0900-0x091f] has been reserved
[    1.318810] system 00:06: [io  0x0920-0x0923] has been reserved
[    1.324722] system 00:06: [io  0x0924] has been reserved
[    1.330023] system 00:06: [io  0x0c00-0x0c7f] has been reserved
[    1.335933] system 00:06: [io  0x0ca0-0x0ca7] has been reserved
[    1.341844] system 00:06: [io  0x0ca9-0x0cab] has been reserved
[    1.347753] system 00:06: [io  0x0cad-0x0caf] has been reserved
[    1.353720] system 00:07: [io  0x0ca8] has been reserved
[    1.359024] system 00:07: [io  0x0cac] has been reserved
[    1.364986] system 00:08: [mem 0xe0000000-0xefffffff] has been reserved
[    1.371663] system 00:0a: [mem 0xfed90000-0xfed91fff] has been reserved
[    1.378375] pnp: PnP ACPI: found 11 devices
[    1.382550] ACPI: bus type PNP unregistered
[    1.392191] pci 0000:00:1c.0: BAR 15: assigned [mem 0xd0000000-0xd01fffff 64bit pref]
[    1.400010] pci 0000:00:01.0: PCI bridge to [bus 01]
[    1.404970] pci 0000:00:01.0:   bridge window [mem 0xd4000000-0xd7ffffff]
[    1.411749] pci 0000:00:03.0: PCI bridge to [bus 02]
[    1.416706] pci 0000:00:03.0:   bridge window [mem 0xd8000000-0xdbffffff]
[    1.423484] pci 0000:00:07.0: PCI bridge to [bus 04]
[    1.428440] pci 0000:00:07.0:   bridge window [mem 0xdc000000-0xdcffffff]
[    1.435218] pci 0000:00:09.0: PCI bridge to [bus 05]
[    1.440177] pci 0000:00:09.0:   bridge window [mem 0xde100000-0xde1fffff]
[    1.446952] pci 0000:00:09.0:   bridge window [mem 0xd3000000-0xd37fffff 64bit pref]
[    1.454685] pci 0000:00:1c.0: PCI bridge to [bus 03]
[    1.459640] pci 0000:00:1c.0:   bridge window [io  0xf000-0xffff]
[    1.465725] pci 0000:00:1c.0:   bridge window [mem 0xde200000-0xde2fffff]
[    1.472504] pci 0000:00:1c.0:   bridge window [mem 0xd0000000-0xd01fffff 64bit pref]
[    1.480238] pci 0000:06:03.0: BAR 6: assigned [mem 0xdd000000-0xdd00ffff pref]
[    1.487447] pci 0000:00:1e.0: PCI bridge to [bus 06]
[    1.492405] pci 0000:00:1e.0:   bridge window [mem 0xdd000000-0xddffffff]
[    1.499183] pci 0000:00:1e.0:   bridge window [mem 0xd3800000-0xd3ffffff 64bit pref]
[    1.507725] NET: Registered protocol family 2
[    1.512541] TCP established hash table entries: 524288 (order: 11, 8388608 bytes)
[    1.521217] TCP bind hash table entries: 65536 (order: 8, 1048576 bytes)
[    1.528059] TCP: Hash tables configured (established 524288 bind 65536)
[    1.534699] TCP: reno registered
[    1.538011] UDP hash table entries: 65536 (order: 9, 2097152 bytes)
[    1.544667] UDP-Lite hash table entries: 65536 (order: 9, 2097152 bytes)
[    1.551778] NET: Registered protocol family 1
[    1.568663] Trying to unpack rootfs image as initramfs...
[    1.754246] Freeing initrd memory: 13796k freed
[    1.761430] PCI-DMA: Using software bounce buffering for IO (SWIOTLB)
[    1.767868] software IO TLB [mem 0xcb379000-0xcf379000] (64MB) mapped at [ffff8800cb379000-ffff8800cf378fff]
[    1.794223] bounce pool size: 64 pages
[    1.797968] HugeTLB registered 2 MB page size, pre-allocated 0 pages
[    1.806609] SGI XFS with ACLs, security attributes, large block/inode numbers, no debug enabled
[    1.815611] msgmni has been set to 32768
[    1.819753] Block layer SCSI generic (bsg) driver version 0.4 loaded (major 252)
[    1.827137] io scheduler noop registered
[    1.831052] io scheduler deadline registered
[    1.835317] io scheduler cfq registered (default)
[    1.840461] vesafb: mode is 1280x1024x8, linelength=1280, pages=0
[    1.846543] vesafb: scrolling: redraw
[    1.850198] vesafb: Pseudocolor: size=0:6:6:6, shift=0:0:0:0
[    1.855894] vesafb: framebuffer at 0xd3800000, mapped to 0xffffc90016e00000, using 1280k, total 1280k
[    1.925167] Console: switching to colour frame buffer device 160x64
[    1.982806] fb0: VESA VGA frame buffer device
[    1.987442] input: Power Button as /devices/LNXSYSTM:00/LNXPWRBN:00/input/input0
[    1.995236] ACPI: Power Button [PWRF]
[    1.999126] ACPI: processor limited to max C-state 0
[    2.008410] Serial: 8250/16550 driver, 4 ports, IRQ sharing enabled
[    2.035550] 00:04: ttyS0 at I/O 0x3f8 (irq = 4) is a 16550A
[    2.061965] 00:05: ttyS1 at I/O 0x2f8 (irq = 3) is a 16550A
[    2.068092] Non-volatile memory driver v1.3
[    2.072517] Linux agpgart interface v0.103
[    2.077717] brd: module loaded
[    2.081331] loop: module loaded
[    2.084679] libphy: Fixed MDIO Bus: probed
[    2.089033] i8042: PNP: No PS/2 controller found. Probing ports directly.
[    2.099081] serio: i8042 KBD port at 0x60,0x64 irq 1
[    2.104311] serio: i8042 AUX port at 0x60,0x64 irq 12
[    2.109674] mousedev: PS/2 mouse device common for all mice
[    2.115633] rtc_cmos 00:03: RTC can wake from S4
[    2.120594] rtc_cmos 00:03: rtc core: registered rtc_cmos as rtc0
[    2.127045] rtc_cmos 00:03: alarms up to one day, y3k, 242 bytes nvram, hpet irqs
[    2.134934] cpuidle: using governor ladder
[    2.139653] hidraw: raw HID events driver (C) Jiri Kosina
[    2.145430] usbcore: registered new interface driver usbhid
[    2.151305] usbhid: USB HID core driver
[    2.155451] drop_monitor: Initializing network drop monitor service
[    2.162119] TCP: cubic registered
[    2.165612] Initializing XFRM netlink socket
[    2.170504] NET: Registered protocol family 17
[    2.175200] Key type dns_resolver registered
[    2.179984] registered taskstats version 1
[    2.186273] rtc_cmos 00:03: setting system clock to 2013-07-01 14:20:57 UTC (1372688457)
[    2.195697] Freeing unused kernel memory: 1240k freed
[    2.201274] Write protecting the kernel read-only data: 10240k
[    2.209702] Freeing unused kernel memory: 1200k freed
[    2.218532] Freeing unused kernel memory: 1792k freed
[    2.267042] dracut: dracut-018-60.git20120927.fc16
[    2.304901] udevd[201]: starting version 173
[    2.340246] uhci_hcd: USB Universal Host Controller Interface driver
[    2.341908] megasas: 06.506.00.00-rc1 Sat. Feb. 9 17:00:00 PDT 2013
[    2.341928] megasas: 0x1000:0x0079:0x1028:0x1f17: bus 3:slot 0:func 0
[    2.342080] megasas: FW now in Ready state
[    2.405704] megasas_init_mfi: fw_support_ieee=67108864
[    2.405704] megasas: INIT adapter done
[    2.457875] uhci_hcd 0000:00:1a.0: UHCI Host Controller
[    2.468724] scsi0 : LSI SAS based MegaRAID driver
[    2.469081] scsi 0:0:0:0: Direct-Access     FUJITSU  MBD2300RC        D80A PQ: 0 ANSI: 5
[    2.469348] scsi 0:0:1:0: Direct-Access     FUJITSU  MBD2300RC        D80A PQ: 0 ANSI: 5
[    2.469715] scsi 0:0:2:0: Direct-Access     FUJITSU  MBD2300RC        D80A PQ: 0 ANSI: 5
[    2.469997] scsi 0:0:3:0: Direct-Access     FUJITSU  MBD2300RC        D80A PQ: 0 ANSI: 5
[    2.470239] scsi 0:0:4:0: Direct-Access     FUJITSU  MBD2300RC        D80A PQ: 0 ANSI: 5
[    2.470481] scsi 0:0:5:0: Direct-Access     FUJITSU  MBD2300RC        D80A PQ: 0 ANSI: 5
[    2.569888] scsi 0:0:32:0: Enclosure         DP       BACKPLANE        1.07 PQ: 0 ANSI: 5
[    2.579047] scsi 0:2:0:0: Direct-Access     DELL     PERC H700        2.10 PQ: 0 ANSI: 5
[    2.586678] scsi 0:0:32:0: Attached scsi generic sg0 type 13
[    2.586774] sd 0:2:0:0: Attached scsi generic sg1 type 0
[    2.586789] sd 0:2:0:0: [sda] 2339373056 512-byte logical blocks: (1.19 TB/1.08 TiB)
[    2.586857] sd 0:2:0:0: [sda] Write Protect is off
[    2.586902] sd 0:2:0:0: [sda] Write cache: enabled, read cache: enabled, doesn't support DPO or FUA
[    2.615696]  sda: sda1 sda2 sda3 sda4 sda5
[    2.616028] sd 0:2:0:0: [sda] Attached SCSI disk
[    2.779615] tsc: Refined TSC clocksource calibration: 3324.999 MHz
[    2.779618] Switching to clocksource tsc
[    2.835988] uhci_hcd 0000:00:1a.0: new USB bus registered, assigned bus number 1
[    2.836028] uhci_hcd 0000:00:1a.0: irq 17, io base 0x0000ec40
[    2.836063] usb usb1: New USB device found, idVendor=1d6b, idProduct=0001
[    2.836064] usb usb1: New USB device strings: Mfr=3, Product=2, SerialNumber=1
[    2.836065] usb usb1: Product: UHCI Host Controller
[    2.836066] usb usb1: Manufacturer: Linux 3.10.0-00010-g1ae679b uhci_hcd
[    2.836066] usb usb1: SerialNumber: 0000:00:1a.0
[    2.836120] hub 1-0:1.0: USB hub found
[    2.836122] hub 1-0:1.0: 2 ports detected
[    2.836331] uhci_hcd 0000:00:1a.1: UHCI Host Controller
[    2.836352] uhci_hcd 0000:00:1a.1: new USB bus registered, assigned bus number 2
[    2.836385] uhci_hcd 0000:00:1a.1: irq 18, io base 0x0000ec60
[    2.836408] usb usb2: New USB device found, idVendor=1d6b, idProduct=0001
[    2.836409] usb usb2: New USB device strings: Mfr=3, Product=2, SerialNumber=1
[    2.836410] usb usb2: Product: UHCI Host Controller
[    2.836411] usb usb2: Manufacturer: Linux 3.10.0-00010-g1ae679b uhci_hcd
[    2.836412] usb usb2: SerialNumber: 0000:00:1a.1
[    2.836456] hub 2-0:1.0: USB hub found
[    2.836458] hub 2-0:1.0: 2 ports detected
[    2.836649] uhci_hcd 0000:00:1d.0: UHCI Host Controller
[    2.836673] uhci_hcd 0000:00:1d.0: new USB bus registered, assigned bus number 3
[    2.836706] uhci_hcd 0000:00:1d.0: irq 21, io base 0x0000ec80
[    2.836731] usb usb3: New USB device found, idVendor=1d6b, idProduct=0001
[    2.836732] usb usb3: New USB device strings: Mfr=3, Product=2, SerialNumber=1
[    2.836733] usb usb3: Product: UHCI Host Controller
[    2.836734] usb usb3: Manufacturer: Linux 3.10.0-00010-g1ae679b uhci_hcd
[    2.836735] usb usb3: SerialNumber: 0000:00:1d.0
[    2.836780] hub 3-0:1.0: USB hub found
[    2.836782] hub 3-0:1.0: 2 ports detected
[    2.836977] uhci_hcd 0000:00:1d.1: UHCI Host Controller
[    2.836997] uhci_hcd 0000:00:1d.1: new USB bus registered, assigned bus number 4
[    2.837032] uhci_hcd 0000:00:1d.1: irq 20, io base 0x0000eca0
[    2.837055] u[    2.837056] usb usb4: New USB device strings: Mfr=3, Product=2, SerialNumber=1
[    2.837056] usb usb4: Product: UHCI Host Controller
[    2.837057] usb usb4: Manufacturer: Linux 3.10.0-00010-g1ae679b uhci_hcd
[    2.837058] usb usb4: SerialNumber: 0000:00:1d.1
[    2.837101] hub 4-0:1.0: USB hub found
[    2.837103] hub 4-0:1.0: 2 ports detected
[    3.137958] usb 2-1: new full-speed USB device number 2 using uhci_hcd
[    3.269456] usb 2-1: New USB device found, idVendor=0424, idProduct=2514
[    3.269457] usb 2-1: New USB device strings: Mfr=0, Product=0, SerialNumber=0
[    3.272468] hub 2-1:1.0: USB hub found
[    3.274457] hub 2-1:1.0: 3 ports detected
[    3.380670] usb 3-2: new full-speed USB device number 2 using uhci_hcd
[    3.531801] usb 3-2: New USB device found, idVendor=0624, idProduct=0248
[    3.531802] usb 3-2: New USB device strings: Mfr=1, Product=2, SerialNumber=3
[    3.531803] usb 3-2: Product: USB Composite Device-0
[    3.531804] usb 3-2: Manufacturer: Avocent
[    3.531805] usb 3-2: SerialNumber: 20120430
[    3.554942] input: Avocent USB Composite Device-0 as /devices/pci0000:00/0000:00:1d.0/usb3/3-2/3-2:1.0/input/input1
[    3.554992] hid-generic 0003:0624:0248.0001: input,hidraw0: USB HID v1.00 Keyboard [Avocent USB Composite Device-0] on usb-0000:00:1d.0-2/input0
[    3.560910] input: Avocent USB Composite Device-0 as /devices/pci0000:00/0000:00:1d.0/usb3/3-2/3-2:1.1/input/input2
[    3.560967] hid-generic 0003:0624:0248.0002: input,hidraw1: USB HID v1.00 Mouse [Avocent USB Composite Device-0] on usb-0000:00:1d.0-2/input1
[    3.988988] XFS (sda2): Mounting Filesystem
[    4.093921] XFS (sda2): Starting recovery (logdev: internal)
[    4.165921] XFS (sda2): Ending recovery (logdev: internal)
[    4.230129] dracut: Checking xfs: /dev/disk/by-uuid/0c3085f9-e876-4196-91f4-06cdad33a871
[    4.255237] dracut: trying to mount /dev/disk/by-uuid/0c3085f9-e876-4196-91f4-06cdad33a871
[    4.281363] XFS (sda2): Mounting Filesystem
[    4.363256] XFS (sda2): Starting recovery (logdev: internal)
[    4.417418] XFS (sda2): Ending recovery (logdev: internal)
[    4.439434] dracut: xfs: /dev/disk/by-uuid/0c3085f9-e876-4196-91f4-06cdad33a871 is clean
[    4.465612] dracut: Remounting /dev/disk/by-uuid/0c3085f9-e876-4196-91f4-06cdad33a871 with -o noatime,nodiratime,nobarrier,ro
[    4.495850] XFS (sda2): Mounting Filesystem
[    4.560765] XFS (sda2): Starting recovery (logdev: internal)
[    4.614787] XFS (sda2): Ending recovery (logdev: internal)
[    4.639008] dracut: Mounted root filesystem /dev/sda2
[    4.730139] dracut: Switching root
[    4.969002] systemd[1]: systemd 37 running in system mode. (+PAM +LIBWRAP +AUDIT +SELINUX +SYSVINIT +LIBCRYPTSETUP; fedora)
[    5.304009] NET: Registered protocol family 10
[    5.332075] systemd[1]: Set hostname to <berbox1>.
[    6.305396] systemd-readahead-collect[503]: Failed to create fanotify object: Function not implemented
[    6.616338] RPC: Registered named UNIX socket transport module.
[    6.616339] RPC: Registered udp transport module.
[    6.616339] RPC: Registered tcp transport module.
[    6.616340] RPC: Registered tcp NFSv4.1 backchannel transport module.
[    6.733311] systemd[1]: systemd-readahead-collect.service: main process exited, code=exited, status=1
[    6.741209] udevd[525]: starting version 173
[    7.076799] udevd[525]: specified group 'fuse' unknown
[    7.435222] ehci_hcd: USB 2.0 'Enhanced' Host Controller (EHCI) Driver
[    7.455234] Warning! ehci_hcd should always be loaded before uhci_hcd and ohci_hcd, not after
[    7.496572] input: PC Speaker as /devices/platform/pcspkr/input/input3
[    7.572715] dcdbas dcdbas: Dell Systems Management Base Driver (version 5.6.0-3.2)
[    7.600538] microcode: CPU0 sig=0x206c2, pf=0x1, revision=0x15
[    7.676062] fuse init (API version 7.22)
[    7.711307] wmi: Mapper loaded
[    7.733145] ehci-pci: EHCI PCI platform driver
[    7.733390] usb 2-1: USB disconnect, device number 2
[    7.735003] ehci-pci 0000:00:1a.7: EHCI Host Controller
[    7.735044] ehci-pci 0000:00:1a.7: new USB bus registered, assigned bus number 5
[    7.735060] ehci-pci 0000:00:1a.7: debug port 1
[    7.738994] ehci-pci 0000:00:1a.7: irq 19, io mem 0xde0fe000
[    7.744094] ehci-pci 0000:00:1a.7: USB 2.0 started, EHCI 1.00
[    7.744122] usb usb5: New USB device found, idVendor=1d6b, idProduct=0002
[    7.744123] usb usb5: New USB device strings: Mfr=3, Product=2, SerialNumber=1
[    7.744124] usb usb5: Product: EHCI Host Controller
[    7.744125] usb usb5: Manufacturer: Linux 3.10.0-00010-g1ae679b ehci_hcd
[    7.744126] usb usb5: SerialNumber: 0000:00:1a.7
[    7.744194] hub 5-0:1.0: USB hub found
[    7.744197] hub 5-0:1.0: 4 ports detected
[    7.744247] hub 1-0:1.0: USB hub found
[    7.744250] hub 1-0:1.0: 2 ports detected
[    7.744273] hub 2-0:1.0: USB hub found
[    7.744278] hub 2-0:1.0: 2 ports detected
[    7.744509] usb 3-2: USB disconnect, device number 2
[    7.818263] microcode: CPU1 sig=0x206c2, pf=0x1, revision=0x15
[    7.819793] microcode: CPU2 sig=0x206c2, pf=0x1, revision=0x15
[    7.831870] microcode: CPU3 sig=0x206c2, pf=0x1, revision=0x15
[    7.832622] microcode: CPU4 sig=0x206c2, pf=0x1, revision=0x15
[    7.833417] microcode: CPU5 sig=0x206c2, pf=0x1, revision=0x15
[    7.834208] microcode: CPU6 sig=0x206c2, pf=0x1, revision=0x15
[    7.835005] microcode: CPU7 sig=0x206c2, pf=0x1, revision=0x15
[    7.835794] microcode: CPU8 sig=0x206c2, pf=0x1, revision=0x15
[    7.836587] microcode: CPU9 sig=0x206c2, pf=0x1, revision=0x15
[    7.837374] microcode: CPU10 sig=0x206c2, pf=0x1, revision=0x15
[    7.838163] microcode: CPU11 sig=0x206c2, pf=0x1, revision=0x15
[    7.838947] microcode: CPU12 sig=0x206c2, pf=0x1, revision=0x15
[    7.839742] microcode: CPU13 sig=0x206c2, pf=0x1, revision=0x15
[    7.840530] microcode: CPU14 sig=0x206c2, pf=0x1, revision=0x15
[    7.841320] microcode: CPU15 sig=0x206c2, pf=0x1, revision=0x15
[    7.842095] microcode: CPU16 sig=0x206c2, pf=0x1, revision=0x15
[    7.842894] microcode: CPU17 sig=0x206c2, pf=0x1, revision=0x15
[    7.843675] microcode: CPU18 sig=0x206c2, pf=0x1, revision=0x15
[    7.844458] microcode: CPU19 sig=0x206c2, pf=0x1, revision=0x15
[    7.845250] microcode: CPU20 sig=0x206c2, pf=0x1, revision=0x15
[    7.846040] microcode: CPU21 sig=0x206c2, pf=0x1, revision=0x15
[    7.846824] microcode: CPU22 sig=0x206c2, pf=0x1, revision=0x15
[    7.847608] microcode: CPU23 sig=0x206c2, pf=0x1, revision=0x15
[    7.848406] microcode: Microcode Update Driver: v2.00 <tigran@aivazian.fsnet.co.uk>, Peter Oruba
[    8.046171] usb 5-3: new high-speed USB device number 2 using ehci-pci
[    8.160452] usb 5-3: New USB device found, idVendor=0424, idProduct=2514
[    8.160459] usb 5-3: New USB device strings: Mfr=0, Product=0, SerialNumber=0
[    8.160585] hub 5-3:1.0: USB hub found
[    8.160698] hub 5-3:1.0: 3 ports detected
[    8.578417] mount[1391]: mount: fusectl already mounted or /sys/fs/fuse/connections busy
[    8.578562] mount[1391]: mount: according to mtab, fusectl is already mounted on /sys/fs/fuse/connections
[    8.639522] systemd[1]: sys-fs-fuse-connections.mount mount process exited, code=exited status=32
[    8.666406] iTCO_vendor_support: vendor-support=0
[    8.682276] iTCO_wdt: Intel TCO WatchDog Timer Driver v1.10
[    8.682309] iTCO_wdt: Found a ICH9 TCO device (Version=2, TCOBASE=0x0860)
[    8.682402] iTCO_wdt: initialized. heartbeat=30 sec (nowayout=0)
[    8.752271] systemd[1]: Unit sys-fs-fuse-connections.mount entered failed state.
[    8.774384] ehci-pci 0000:00:1d.7: EHCI Host Controller
[    8.790981] ehci-pci 0000:00:1d.7: new USB bus registered, assigned bus number 6
[    8.816734] ehci-pci 0000:00:1d.7: debug port 1
[    8.836551] ehci-pci 0000:00:1d.7: irq 21, io mem 0xde0ff000
[    8.859245] ehci-pci 0000:00:1d.7: USB 2.0 started, EHCI 1.00
[    8.876358] usb usb6: New USB device found, idVendor=1d6b, idProduct=0002
[    8.894611] usb usb6: New USB device strings: Mfr=3, Product=2, SerialNumber=1
[    8.913347] usb usb6: Product: EHCI Host Controller
[    8.929698] usb usb6: Manufacturer: Linux 3.10.0-00010-g1ae679b ehci_hcd
[    8.929699] usb usb6: SerialNumber: 0000:00:1d.7
[    8.929755] hub 6-0:1.0: USB hub found
[    8.929759] hub 6-0:1.0: 4 ports detected
[    8.929808] hub 3-0:1.0: USB hub found
[    8.929811] hub 3-0:1.0: 2 ports detected
[    8.929834] hub 4-0:1.0: USB hub found
[    8.929836] hub 4-0:1.0: 2 ports detected
[    8.973429] bnx2: Broadcom NetXtreme II Gigabit Ethernet Driver bnx2 v2.2.3 (June 27, 2012)
[    8.973973] bnx2 0000:01:00.0 eth0: Broadcom NetXtreme II BCM5709 1000Base-T (C0) PCI Express found at mem d4000000, IRQ 36, node addr 00:21:9b:a0:c8:2e
[    8.974438] bnx2 0000:01:00.1 eth1: Broadcom NetXtreme II BCM5709 1000Base-T (C0) PCI Express found at mem d6000000, IRQ 48, node addr 00:21:9b:a0:c8:30
[    8.974911] bnx2 0000:02:00.0 eth2: Broadcom NetXtreme II BCM5709 1000Base-T (C0) PCI Express found at mem d8000000, IRQ 32, node addr 00:21:9b:a0:c8:32
[    8.975376] bnx2 0000:02:00.1 eth3: Broadcom NetXtreme II BCM5709 1000Base-T (C0) PCI Express found at mem da000000, IRQ 42, node addr 00:21:9b:a0:c8:34
[    8.996039] ses 0:0:32:0: Attached Enclosure device
[    9.003860] mlx4_core: log_num_vlan - obsolete module param, using 7
[    9.003927] mlx4_core: Mellanox ConnectX core driver v1.1 (Dec, 2011)
[    9.003927] mlx4_core: Initializing 0000:05:00.0
[    9.107344] cxgb3: Chelsio T3 Network Driver - version 1.1.5-ko
[    9.406968] Adding 33791996k swap on /dev/sda3.  Priority:0 extents:1 across:33791996k
[    9.414600] cxgb3 0000:04:00.0: Port 0 using 4 queue sets.
[    9.414601] cxgb3 0000:04:00.0: Port 1 using 4 queue sets.
[    9.414604] cxgb3 0000:04:00.0 eth4: Chelsio T320 10GBASE-R RNIC (rev 4) PCI Express x8 MSI-X
[    9.414605] cxgb3: eth4: 128MB CM, 256MB PMTX, 256MB PMRX, S/N: PT50090263
[    9.414610] cxgb3 0000:04:00.0 eth5: Chelsio T320 10GBASE-R RNIC (rev 4) PCI Express x8 MSI-X
[    9.691410] usb 3-2: new full-speed USB device number 3 using uhci_hcd
[    9.781158] systemd-fsck[1782]: /sbin/fsck.xfs: XFS file system.
[    9.852121] s[    9.865423] usb 3-2: New USB device found, idVendor=0624, idProduct=0248
[    9.865424] usb 3-2: New USB device strings: Mfr=1, Product=2, SerialNumber=3
[    9.865425] usb 3-2: Product: USB Composite Device-0
[    9.865426] usb 3-2: Manufacturer: Avocent
[    9.865427] usb 3-2: SerialNumber: 20120430
[    9.887575] input: Avocent USB Composite Device-0 as /devices/pci0000:00/0000:00:1d.0/usb3/3-2/3-2:1.0/input/input4
[    9.887639] hid-generic 0003:0624:0248.0003: input,hidraw0: USB HID v1.00 Keyboard [Avocent USB Composite Device-0] on usb-0000:00:1d.0-2/input0
[    9.893533] input: Avocent USB Composite Device-0 as /devices/pci0000:00/0000:00:1d.0/usb3/3-2/3-2:1.1/input/input5
[    9.893638] hid-generic 0003:0624:0248.0004: input,hidraw1: USB HID v1.00 Mouse [Avocent USB Composite Device-0] on usb-0000:00:1d.0-2/input1
[   10.176036] systemd-fsck[862]: /dev/sda4: clean, 242/76912 files, 179453/307200 blocks
[   10.194795] XFS (sda5): Mounting Filesystem
[   10.559764] XFS (sda5): Ending clean mount
[   10.574877] EXT4-fs (sda4): mounted filesystem with ordered data mode. Opts: (null)
[   11.269442] systemd[1887]: Failed at step EXEC spawning /sbin/plymouthd: No such file or directory
[   11.298086] systemd[1]: plymouth-start.service: control process exited, code=exited status=203
[   11.368340] systemd[1]: Unit plymouth-start.service entered failed state.
[   11.500719] device-mapper: uevent: version 1.0.3
[   11.526289] device-mapper: ioctl: 4.24.0-ioctl (2013-01-15) initialised: dm-devel@redhat.com
[   11.844988] systemd[1903]: Failed at step EXEC spawning /bin/plymouth: No such file or directory
[   12.267136] dkms_autoinstaller[1911]: dkms: running auto installation service for kernel 3.10.0-00010-g1ae679b
[   12.982403] cgconfig[1930]: Starting cgconfig service: [  OK  ]
[   13.127057] acpid[2050]: starting up with proc fs
[   13.153967] acpid[2050]: skipping incomplete file /etc/acpi/events/videoconf
[   13.181640] acpid[2050]: 1 rule loaded
[   13.205469] acpid[2050]: waiting for events: event logging is off
[   13.331234] /usr/sbin/crond[2039]: (CRON) INFO (running with inotify support)
[   14.536983] bnx2 0000:01:00.0 eth0: using MSIX
[   14.558440] IPv6: ADDRCONF(NETDEV_UP): eth0: link is not ready
[   16.236001] mlx4_core 0000:05:00.0: 64B EQEs/CQEs supported by the device but not enabled
[   17.268566] mlx4_en: Mellanox ConnectX HCA Ethernet driver v2.0 (Dec 2011)
[   17.292709] mlx4_en 0000:05:00.0: Activating port:2
[   17.318427] mlx4_en: eth4: Using 192 TX rings
[   17.318428] mlx4_en: eth4: Using 8 RX rings
[   17.318429] mlx4_en: eth4:   frag:0 - size:512 prefix:0 align:0 stride:512
[   17.318430] mlx4_en: eth4:   frag:1 - size:1014 prefix:512 align:0 stride:1024
[   17.318621] mlx4_en: eth4: Initializing port
[   17.318842] <mlx4_ib> mlx4_ib_add: mlx4_ib: Mellanox ConnectX InfiniBand driver v1.0 (April 4, 2008)
[   17.342445] mlx4_en: eth4:   frag:0 - size:512 prefix:0 align:0 stride:512
[   17.342446] mlx4_en: eth4:   frag:1 - size:1014 prefix:512 align:0 stride:1024
[   17.522270] IPv6: ADDRCONF(NETDEV_UP): eth4: link is not ready
[   17.616270] bnx2 0000:01:00.0 eth0: NIC Copper Link is Up, 1000 Mbps full duplex
[   17.640444] , receive & transmit flow control ON
[   17.666143] IPv6: ADDRCONF(NETDEV_CHANGE): eth0: link becomes ready
[   17.757321] cxgb3 0000:04:00.0: found old FW minor version(7.11), driver compiled for version 7.12
[   17.761375] netif_napi_add() called with weight 100 on device
[   17.815924] cxgb3 0000:04:00.0: could not upgrade firmware: unable to load cxgb3/t3fw-7.12.0.bin
[   17.842381] cxgb3 0000:04:00.0: FW upgrade to 7.12.0 failed
[   18.925683] iw_cxgb3: Chelsio T3 RDMA Driver - version 1.1
[   20.384962] mlx4_en: eth4: Link Up
[  241.816183] INFO: task kworker/10:1:137 blocked for more than 120 seconds.
[  241.845043] "echo 0 > /proc/sys/kernel/hung_task_timeout_secs" disables this message.
[  241.870043] kworker/10:1    D ffffffff81607960     0   137      2 0x00000000
[  241.898618] Workqueue: events linkwatch_event
[  241.919861]  ffff880c11f5dd18 0000000000000002 ffff880c13d6db80 0000000000012c40
[  241.944558]  ffff880c13ef1800 ffff880c11e8adc0 ffff880c11f5dfd8 ffff880c11f5dfd8
[  241.969283]  ffff880c11f5dfd8 ffff880c11e8adc0 ffff880c13ef1800 ffffffff81a9c9e0
[  241.994011] Call Trace:
[  242.013593]  [<ffffffff814c4969>] schedule+0x29/0x70
[  242.035861]  [<ffffffff814c4c6e>] schedule_preempt_disabled+0xe/0x10
[  242.059547]  [<ffffffff814c2f62>] __mutex_lock_slowpath+0x112/0x1b0
[  242.083144]  [<ffffffff810759eb>] ? idle_balance+0xdb/0x140
[  242.105928]  [<ffffffff814c2dda>] mutex_lock+0x2a/0x50
[  242.127980]  [<ffffffff814261e5>] rtnl_lock+0x15/0x20
[  242.149637]  [<ffffffff8142aa8e>] linkwatch_event+0xe/0x30
[  242.171732]  [<ffffffff81059e94>] process_one_work+0x174/0x490
[  242.194145]  [<ffffffff8105af4c>] worker_thread+0x11c/0x370
[  242.216212]  [<ffffffff8105ae30>] ? manage_workers+0x2c0/0x2c0
[  242.238470]  [<ffffffff81061380>] kthread+0xc0/0xd0
[  242.259692]  [<ffffffff810612c0>] ? flush_kthread_worker+0xb0/0xb0
[  242.282190]  [<ffffffff814ce09c>] ret_from_fork+0x7c/0xb0
[  242.303946]  [<ffffffff810612c0>] ? flush_kthread_worker+0xb0/0xb0
[  242.326535] INFO: task igmp-leave-thro:2290 blocked for more than 120 seconds.
[  242.350323] "echo 0 > /proc/sys/kernel/hung_task_timeout_secs" disables this message.
[  242.374712] igmp-leave-thro D ffffffff81607960     0  2290      1 0x00000000
[  242.398283]  ffff880c0b3fbcb8 0000000000000002 ffff880c13d916e0 0000000000000002
[  242.422419]  ffff880617d0d3c0 ffff880c1188c4a0 ffff880c0b3fbfd8 ffff880c0b3fbfd8
[  242.446637]  ffff880c0b3fbfd8 ffff880c1188c4a0 ffff880c0b3fbcc8 ffffffff81a9c9e0
[  242.470813] Call Trace:
[  242.489806]  [<ffffffff814c4969>] schedule+0x29/0x70
[  242.511439]  [<ffffffff814c4c6e>] schedule_preempt_disabled+0xe/0x10
[  242.534564]  [<ffffffff814c2f62>] __mutex_lock_slowpath+0x112/0x1b0
[  242.557600]  [<ffffffff814c2dda>] mutex_lock+0x2a/0x50
[  242.579449]  [<ffffffff814261e5>] rtnl_lock+0x15/0x20
[  242.601246]  [<ffffffff8142c6c5>] dev_ioctl+0x335/0x5c0
[  242.623274]  [<ffffffff8113454d>] ? kmem_cache_alloc+0x13d/0x170
[  242.646131]  [<ffffffff81405e21>] ? sk_prot_alloc+0x41/0x170
[  242.668495]  [<ffffffff81401809>] sock_do_ioctl.constprop.12+0x49/0x60
[  242.691642]  [<ffffffff81402134>] sock_ioctl+0x64/0x270
[  242.713360]  [<ffffffff81152436>] do_vfs_ioctl+0x96/0x550
[  242.735163]  [<ffffffff810ac809>] ? rcu_eqs_exit+0x59/0xb0
[  242.756859]  [<ffffffff810abc89>] ? rcu_eqs_enter+0x69/0xb0
[  242.778382]  [<ffffffff81142e3b>] ? alloc_file+0x2b/0xe0
[  242.799538]  [<ffffffff810ad3a3>] ? rcu_user_exit+0x13/0x20
[  242.820873]  [<ffffffff81152940>] SyS_ioctl+0x50/0x90
[  242.841624]  [<ffffffff814ce2b9>] tracesys+0xd0/0xd5
[  242.862362] INFO: task atop:2068 blocked for more than 120 seconds.
[  242.884539] "echo 0 > /proc/sys/kernel/hung_task_timeout_secs" disables this message.
[  242.908525] atop            D ffffffff81607960     0  2068      1 0x00000004
[  242.931834]  ffff880c1111bcb8 0000000000000002 ffff880c13d6adc0 ffff880c11b8ea00
[  242.955470]  ffff880613e72000 ffff880c11e6c4a0 ffff880c1111bfd8 ffff880c1111bfd8
[  242.978893]  ffff880c1111bfd8 ffff880c11e6c4a0 ffff880c1111bca8 ffffffff81a9c9e0
[  243.002266] Call Trace:
[  243.020355]  [<ffffffff814c4969>] schedule+0x29/0x70
[  243.040981]  [<ffffffff814c4c6e>] schedule_preempt_disabled+0xe/0x10
[  243.062911]  [<ffffffff814c2f62>] __mutex_lock_slowpath+0x112/0x1b0
[  243.084669]  [<ffffffff814c2dda>] mutex_lock+0x2a/0x50
[  243.105130]  [<ffffffff814261e5>] rtnl_lock+0x15/0x20
[  243.125194]  [<ffffffff8142c574>] dev_ioctl+0x1e4/0x5c0
[  243.145148]  [<ffffffff81401809>] sock_do_ioctl.constprop.12+0x49/0x60
[  243.166274]  [<ffffffff81402134>] sock_ioctl+0x64/0x270
[  243.185905]  [<ffffffff81152436>] do_vfs_ioctl+0x96/0x550
[  243.205613]  [<ffffffff810ac809>] ? rcu_eqs_exit+0x59/0xb0
[  243.225347]  [<ffffffff810abc89>] ? rcu_eqs_enter+0x69/0xb0
[  243.244960]  [<ffffffff810ad3a3>] ? rcu_user_exit+0x13/0x20
[  243.264322]  [<ffffffff81152940>] SyS_ioctl+0x50/0x90
[  243.282954]  [<ffffffff814ce2b9>] tracesys+0xd0/0xd5
[  243.301380] INFO: task modprobe:2635 blocked for more than 120 seconds.
[  243.321495] "echo 0 > /proc/sys/kernel/hung_task_timeout_secs" disables this message.
[  243.343008] modprobe        D ffffffff81607960     0  2635   1917 0x00000000
[  243.363956]  ffff880612c11b98 0000000000000002 ffffffff81a10440 ffff880612c11b90
[  243.385305]  00003ffffffff000 ffff880612a8adc0 ffff880612c11fd8 ffff880612c11fd8
[  243.406670]  ffff880612c11fd8 ffff880612a8adc0 ffff880612c11fd8 ffffffff81a9c9e0
[  243.428043] Call Trace:
[  243.444258]  [<ffffffff814c4969>] schedule+0x29/0x70
[  243.463136]  [<ffffffff814c4c6e>] schedule_preempt_disabled+0xe/0x10
[  243.483464]  [<ffffffff814c2f62>] __mutex_lock_slowpath+0x112/0x1b0
[  243.503753]  [<ffffffff814c2dda>] mutex_lock+0x2a/0x50
[  243.530031]  [<ffffffff814261e5>] rtnl_lock+0x15/0x20
[  243.549063]  [<ffffffff8141b6f6>] register_netdev+0x16/0x30
[  243.568635]  [<ffffffffa02a71db>] ipoib_add_one+0x32b/0x4c0 [ib_ipoib]
[  243.589253]  [<ffffffff8113361d>] ? kmem_cache_alloc_trace+0x12d/0x160
[  243.609940]  [<ffffffffa00f5be7>] ib_register_client+0x87/0xc0 [ib_core]
[  243.630862]  [<ffffffffa02b9000>] ? 0xffffffffa02b8fff
[  243.650169]  [<ffffffffa02b90e6>] ipoib_init_module+0xe6/0x137 [ib_ipoib]
[  243.671213]  [<ffffffff810002ca>] do_one_initcall+0xea/0x190
[  243.690975]  [<ffffffff81090377>] load_module+0x1407/0x1af0
[  243.710445]  [<ffffffff812868c0>] ? ddebug_add_module+0xf0/0xf0
[  243.730098]  [<ffffffff81090b32>] SyS_init_module+0xd2/0x120
[  243.749357]  [<ffffffff814ce2b9>] tracesys+0xd0/0xd5
[  243.767809] INFO: task ip:2662 blocked for more than 120 seconds.
[  243.787583] "echo 0 > /proc/sys/kernel/hung_task_timeout_secs" disables this message.
[  243.809193] ip              D ffffffff81607960     0  2662   2637 0x00000000
[  243.830165]  ffff880c04b5f558 0000000000000002 ffff880c13d844a0 ffffffff8127d463
[  243.851709]  000080d00030c0d0 ffff880c12e8db80 ffff880c04b5ffd8 ffff880c04b5ffd8
[  243.873311]  ffff880c04b5ffd8 ffff880c12e8db80 0000000000008000 ffffffffa00fd400
[  243.894929] Call Trace:
[  243.911445]  [<ffffffff8127d463>] ? gen_pool_add_virt+0x53/0xb0
[  243.931762]  [<ffffffff814c4969>] schedule+0x29/0x70
[  243.951054]  [<ffffffff814c4c6e>] schedule_preempt_disabled+0xe/0x10
[  243.971786]  [<ffffffff814c2f62>] __mutex_lock_slowpath+0x112/0x1b0
[  243.992424]  [<ffffffff8127d463>] ? gen_pool_add_virt+0x53/0xb0
[  244.012708]  [<ffffffff814c2dda>] mutex_lock+0x2a/0x50
[  244.032203]  [<ffffffffa00f5c5f>] ib_register_device+0x3f/0x4d0 [ib_core]
[  244.053500]  [<ffffffff8113361d>] ? kmem_cache_alloc_trace+0x12d/0x160
[  244.074665]  [<ffffffffa01fba3e>] ? iwch_register_device+0x2ae/0x3d0 [iw_cxgb3]
[  244.096749]  [<ffffffffa01fbac8>] iwch_register_device+0x338/0x3d0 [iw_cxgb3]
[  244.118752]  [<ffffffffa01fc1e7>] open_rnic_dev+0x247/0x340 [iw_cxgb3]
[  244.140170]  [<ffffffffa0a192be>] cxgb3_add_clients+0x3e/0x60 [cxgb3]
[  244.161569]  [<ffffffffa0a069c0>] cxgb_open+0x320/0x360 [cxgb3]
[  244.182341]  [<ffffffff8141aa3f>] __dev_open+0xcf/0x150
[  244.202210]  [<ffffffff8141ad11>] __dev_change_flags+0xa1/0x180
[  244.222602]  [<ffffffff8141aea8>] dev_change_flags+0x28/0x70
[  244.242568]  [<ffffffff81426652>] do_setlink+0x252/0x960
[  244.262128]  [<ffffffffa005500a>] ? inet6_fill_link_af+0x1a/0x30 [ipv6]
[  244.283144]  [<ffffffff81286fc0>] ? nla_parse+0x30/0xe0
[  244.302572]  [<ffffffff81429a19>] rtnl_newlink+0x359/0x560
[  244.322229]  [<ffffffff814295dd>] rtnetlink_rcv_msg+0x14d/0x230
[  244.342348]  [<ffffffff8140b22b>] ? __alloc_skb+0x8b/0x2b0
[  244.361988]  [<ffffffff81429490>] ? __rtnl_unlock+0x20/0x20
[  244.381664]  [<ffffffff81444079>] netlink_rcv_skb+0xa9/0xd0
[  244.401320]  [<ffffffff81426215>] rtnetlink_rcv+0x25/0x40
[  244.420848]  [<ffffffff81443a31>] netlink_unicast+0x161/0x1e0
[  244.440693]  [<ffffffff81443d4b>] netlink_sendmsg+0x29b/0x340
[  244.460443]  [<ffffffff81400776>] sock_sendmsg+0x76/0x90
[  244.479751]  [<ffffffff81403564>] ? move_addr_to_kernel+0x44/0x60
[  244.499905]  [<ffffffff8140f426>] ? verify_iovec+0x56/0xd0
[  244.519493]  [<ffffffff8140292c>] ___sys_sendmsg+0x38c/0x3a0
[  244.539314]  [<ffffffff8110fee0>] ? handle_mm_fault+0x210/0x310
[  244.559424]  [<ffffffff814c9714>] ? __do_page_fault+0x274/0x4c0
[  244.579490]  [<ffffffff811135d5>] ? __vma_link_rb+0x105/0x120
[  244.599250]  [<ffffffff811136bf>] ? vma_link+0xcf/0xe0
[  244.618153]  [<ffffffff810ac809>] ? rcu_eqs_exit+0x59/0xb0
[  244.637209]  [<ffffffff81403f19>] __sys_sendmsg+0x49/0x90
[  244.656010]  [<ffffffff81403f79>] SyS_sendmsg+0x19/0x20
[  244.674518]  [<ffffffff814ce2b9>] tracesys+0xd0/0xd5


-- 

---------------------------------------------------------------
This email, along with any attachments, is confidential. If you 
believe you received this message in error, please contact the 
sender immediately and delete all copies of the message.  
Thank you.
