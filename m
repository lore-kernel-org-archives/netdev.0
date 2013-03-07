From: Michael Wang <wangyun@linux.vnet.ibm.com>
Subject: Re: upgrade to 3.8.1 : BUG Scheduling while atomic in bonding driver:
Date: Thu, 07 Mar 2013 15:48:21 +0800
Message-ID: <51384645.20009@linux.vnet.ibm.com>
References: <513063B4.8070604@tlinx.org> <1362155087.15793.54.camel@edumazet-glaptop> <51317FCF.1070400@tlinx.org> <51318C5B.60001@tlinx.org> <51382AFE.5080302@linux.vnet.ibm.com> <51383C47.7050009@tlinx.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	Linux-Kernel <linux-kernel@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>, Jay Vosburgh <fubar@us.ibm.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	Cong Wang <xiyou.wangcong@gmail.com>
To: Linda Walsh <lkml@tlinx.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <51383C47.7050009@tlinx.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 03/07/2013 03:05 PM, Linda Walsh wrote:
> 
> 
> 
> 
> Michael Wang wrote:
>> On 03/02/2013 01:21 PM, Linda Walsh wrote:
>> Update -- it *used* to stop the messages in 3.6.7.
>>
>> It no longer stops the messages in 3.8.1 -- (and isn't present by
>> default -- tried
>> adding the unlock/lock -- no difference.
>>
>> Weird. *sigh*
>>
>> Hi, Linda
>>
>> Do you have the BUG log after applied this patch?
>>
>> bond->lock seems to be the only one who will add the preempt_count, the
>> patch should works...
>>
>> And have you tried the 3.9.0-rc1, is the issue still exist?
>>
>> Regards,
>> Michael Wang
> -------------------
> 
> What do you mean by 'bug log', do you mean kernel log --- including
> the log from boot, in case anything weird pops out, but bug happens
> edited out stretch of repetitious looking stuff that was unlikely to
> be related...

But do you have the log after applied the change which unlock bond->lock
before enter bond_update_speed_duplex() ? you mentioned that the fix
doesn't address the problem, but I'd like to take a look at the log, may
be there will be more clue ;-)

And have you tried 3.9.0-rc1? may be the issue already solved.

Regards,
Michael Wang

> 
> 
> [    0.000000] Initializing cgroup subsys cpuset
> [    0.000000] Initializing cgroup subsys cpu
> [    0.000000] Linux version 3.8.1-Isht-Van (law@Ishtar) (gcc version
> 4.6.2 (SUSE Linux) ) #6 SMP PREEMPT Fri Mar 1 20:29:32 PST 2013
> [    0.000000] Command line: BOOT_IMAGE=381-Isht-Van rw root=/dev/sdc1
> root=/dev/sdc1 showopts console=ttyS0,115200n8 console=tty0 elevator=cfq
> pcie_aspm=force pcie_ports=native reboot=bios
> [    0.000000] KERNEL supported cpus:
> [    0.000000]   Intel GenuineIntel
> [    0.000000] e820: BIOS-provided physical RAM map:
> [    0.000000] BIOS-e820: [mem 0x0000000000000000-0x000000000009ffff] usable
> ...
> [    0.000000] BIOS-e820: [mem 0x0000000100000000-0x0000000c2fffffff] usable
> [    0.000000] NX (Execute Disable) protection: active
> [    0.000000] SMBIOS 2.6 present.
> [    0.000000] DMI: Dell Inc. PowerEdge T610/0CX0R0, BIOS 6.1.0 10/18/2011
> [    0.000000] e820: update [mem 0x00000000-0x00000fff] usable ==> reserved
> [    0.000000] e820: remove [mem 0x000a0000-0x000fffff] usable
> [    0.000000] e820: last_pfn = 0xc30000 max_arch_pfn = 0x400000000
> [    0.000000] MTRR default type: uncachable
> [    0.000000] MTRR fixed ranges enabled:
> ...
> [    0.000000]   EC000-FFFFF write-protect
> [    0.000000] MTRR variable ranges enabled:
> [    0.000000]   0 base 0000000000 mask FF80000000 write-back
> ...
> [    0.000000]   7 base 0C00000000 mask FFC0000000 write-back
> [    0.000000]   8 disabled
> [    0.000000]   9 disabled
> [    0.000000] x86 PAT enabled: cpu 0, old 0x7040600070406, new
> 0x7010600070106
> [    0.000000] e820: update [mem 0xd0000000-0xffffffff] usable ==> reserved
> [    0.000000] e820: last_pfn = 0xcf379 max_arch_pfn = 0x400000000
> [    0.000000] initial memory mapped: [mem 0x00000000-0x1fffffff]
> [    0.000000] Base memory trampoline at [ffff880000098000] 98000 size 24576
> [    0.000000] Using GB pages for direct mapping
> [    0.000000] init_memory_mapping: [mem 0x00000000-0xcf378fff]
> [    0.000000]  [mem 0x00000000-0xbfffffff] page 1G
> [    0.000000]  [mem 0xc0000000-0xcf1fffff] page 2M
> [    0.000000]  [mem 0xcf200000-0xcf378fff] page 4k
> [    0.000000] kernel direct mapping tables up to 0xcf378fff @ [mem
> 0x1fffd000-0x1fffffff]
> [    0.000000] init_memory_mapping: [mem 0x100000000-0xc2fffffff]
> [    0.000000]  [mem 0x100000000-0xbffffffff] page 1G
> [    0.000000]  [mem 0xc00000000-0xc2fffffff] page 2M
> [    0.000000] kernel direct mapping tables up to 0xc2fffffff @ [mem
> 0xcf377000-0xcf378fff]
> [    0.000000] ACPI: RSDP 00000000000f1170 00024 (v02 DELL  )
> ...
> [    0.000000] ACPI: TCPA 00000000cf3b3f34 00064 (v02 DELL   PE_SC3  
> 00000001 DELL 00000001)
> [    0.000000] ACPI: SSDT 00000000cf3b7000 037A4 (v01  INTEL PPM RCM 
> 80000001 INTL 20061109)
> [    0.000000] ACPI: Local APIC address 0xfee00000
> ...
> [    0.000000] SRAT: PXM 2 -> APIC 0x14 -> Node 1
> [    0.000000] SRAT: Node 1 PXM 2 [mem 0x00000000-0xcfffffff]
> [    0.000000] SRAT: Node 1 PXM 2 [mem 0x100000000-0x62fffffff]
> [    0.000000] SRAT: Node 0 PXM 1 [mem 0x630000000-0xc2fffffff]
> [    0.000000] NUMA: Node 1 [mem 0x00000000-0xcfffffff] + [mem
> 0x100000000-0x62fffffff] -> [mem 0x00000000-0x62fffffff]
> [    0.000000] Initmem setup node 0 [mem 0x630000000-0xc2fffffff]
> [    0.000000]   NODE_DATA [mem 0xc2fffd000-0xc2fffffff]
> [    0.000000] Initmem setup node 1 [mem 0x00000000-0x62fffffff]
> [    0.000000]   NODE_DATA [mem 0x62fffd000-0x62fffffff]
> [    0.000000]  [ffffea0000000000-ffffea0018bfffff] PMD ->
> [ffff880617e00000-ffff88062fdfffff] on node 1
> [    0.000000]  [ffffea0018c00000-ffffea0030bfffff] PMD ->
> [ffff880c17600000-ffff880c2f5fffff] on node 0
> [    0.000000] Zone ranges:
> [    0.000000]   DMA      [mem 0x00001000-0x00ffffff]
> [    0.000000]   DMA32    [mem 0x01000000-0xffffffff]
> [    0.000000]   Normal   [mem 0x100000000-0xc2fffffff]
> [    0.000000] Movable zone start for each node
> [    0.000000] Early memory node ranges
> [    0.000000]   node   1: [mem 0x00001000-0x0009ffff]
> [    0.000000]   node   1: [mem 0x00100000-0xcf378fff]
> [    0.000000]   node   1: [mem 0x100000000-0x62fffffff]
> [    0.000000]   node   0: [mem 0x630000000-0xc2fffffff]
> [    0.000000] On node 0 totalpages: 6291456
> [    0.000000]   Normal zone: 98304 pages used for memmap
> [    0.000000]   Normal zone: 6193152 pages, LIFO batch:31
> [    0.000000] On node 1 totalpages: 6288152
> [    0.000000]   DMA zone: 64 pages used for memmap
> [    0.000000]   DMA zone: 8 pages reserved
> [    0.000000]   DMA zone: 3927 pages, LIFO batch:0
> [    0.000000]   DMA32 zone: 13198 pages used for memmap
> [    0.000000]   DMA32 zone: 831467 pages, LIFO batch:31
> [    0.000000]   Normal zone: 84992 pages used for memmap
> [    0.000000]   Normal zone: 5354496 pages, LIFO batch:31
> [    0.000000] ACPI: PM-Timer IO Port: 0x808
> [    0.000000] ACPI: Local APIC address 0xfee00000
> ...
> [    0.000000] ACPI: LAPIC (acpi_id[0x20] lapic_id[0xff] disabled)
> [    0.000000] ACPI: LAPIC_NMI (acpi_id[0xff] high edge lint[0x1])
> [    0.000000] ACPI: IOAPIC (id[0x00] address[0xfec00000] gsi_base[0])
> [    0.000000] IOAPIC[0]: apic_id 0, version 32, address 0xfec00000, GSI
> 0-23
> [    0.000000] ACPI: IOAPIC (id[0x01] address[0xfec80000] gsi_base[32])
> [    0.000000] IOAPIC[1]: apic_id 1, version 32, address 0xfec80000, GSI
> 32-55
> [    0.000000] ACPI: INT_SRC_OVR (bus 0 bus_irq 0 global_irq 2 dfl dfl)
> [    0.000000] ACPI: INT_SRC_OVR (bus 0 bus_irq 9 global_irq 9 high level)
> [    0.000000] ACPI: IRQ0 used by override.
> [    0.000000] ACPI: IRQ2 used by override.
> [    0.000000] ACPI: IRQ9 used by override.
> [    0.000000] Using ACPI (MADT) for SMP configuration information
> [    0.000000] ACPI: HPET id: 0x8086a301 base: 0xfed00000
> [    0.000000] smpboot: 32 Processors exceeds NR_CPUS limit of 12
> [    0.000000] smpboot: Allowing 12 CPUs, 0 hotplug CPUs
> [    0.000000] nr_irqs_gsi: 72
> [    0.000000] e820: [mem 0xd0000000-0xdfffffff] available for PCI devices
> [    0.000000] setup_percpu: NR_CPUS:12 nr_cpumask_bits:12 nr_cpu_ids:12
> nr_node_ids:2
> [    0.000000] PERCPU: Embedded 476 pages/cpu @ffff880617200000 s1918016
> r8192 d23488 u2097152
> [    0.000000] pcpu-alloc: s1918016 r8192 d23488 u2097152 alloc=1*2097152
> [    0.000000] pcpu-alloc: [0] 00 [0] 02 [0] 04 [0] 06 [0] 08 [0] 10 [1]
> 01 [1] 03
> [    0.000000] pcpu-alloc: [1] 05 [1] 07 [1] 09 [1] 11
> [    0.000000] Built 2 zonelists in Zone order, mobility grouping on. 
> Total pages: 12383042
> [    0.000000] Policy zone: Normal
> [    0.000000] Kernel command line: reboot=bios BOOT_IMAGE=381-Isht-Van
> rw root=/dev/sdc1 root=/dev/sdc1 showopts console=ttyS0,115200n8
> console=tty0 elevator=cfq pcie_aspm=force pcie_ports=native reboot=bios
> [    0.000000] PCIe ASPM is forcibly enabled
> [    0.000000] PID hash table entries: 4096 (order: 3, 32768 bytes)
> [    0.000000] __ex_table already sorted, skipping sort
> [    0.000000] Memory: 49417684k/51118080k available (6379k kernel code,
> 799648k absent, 900748k reserved, 6697k data, 2356k init)
> [    0.000000] SLUB: Genslabs=15, HWalign=64, Order=0-3, MinObjects=0,
> CPUs=12, Nodes=2
> [    0.000000] Preemptible hierarchical RCU implementation.
> [    0.000000] NR_IRQS:4352 nr_irqs:1320 16
> [    0.000000] Extended CMOS year: 2000
> [    0.000000] Console: colour VGA+ 132x43
> [    0.000000] console [tty0] enabled
> [    0.000000] console [ttyS0] enabled
> ...
> [    0.000000] Enabling automatic NUMA balancing. Configure with
> numa_balancing= or sysctl
> [    0.000000] hpet clockevent registered
> [    0.000000] tsc: Fast TSC calibration using PIT
> [    0.001000] tsc: Detected 2793.076 MHz processor
> [    0.000004] Calibrating delay loop (skipped), value calculated using
> timer frequency.. 5586.15 BogoMIPS (lpj=2793076)
> [    0.010813] pid_max: default: 32768 minimum: 301
> [    0.015614] Security Framework initialized
> [    0.023350] Dentry cache hash table entries: 8388608 (order: 14,
> 67108864 bytes)
> [    0.044185] Inode-cache hash table entries: 4194304 (order: 13,
> 33554432 bytes)
> [    0.057474] Mount-cache hash table entries: 256
> ...
> [    0.089812] CPU: Physical Processor ID: 1
> [    0.093952] CPU: Processor Core ID: 0
> [    0.097757] ENERGY_PERF_BIAS: Set to 'normal', was 'performance'
> [    0.097757] ENERGY_PERF_BIAS: View and update with
> x86_energy_perf_policy(8)
> [    0.110967] mce: CPU supports 9 MCE banks
> [    0.115114] CPU0: Thermal monitoring enabled (TM1)
> [    0.120048] process: using mwait in idle threads
> [    0.124793] Last level iTLB entries: 4KB 512, 2MB 7, 4MB 7
> [    0.124793] Last level dTLB entries: 4KB 512, 2MB 32, 4MB 32
> [    0.124793] tlb_flushall_shift: 6
> [    0.139667] Freeing SMP alternatives: 20k freed
> [    0.144332] ACPI: Core revision 20121018
> [    0.152164] dmar: Host address width 40
> [    0.156136] dmar: DRHD base: 0x000000fed90000 flags: 0x1
> [    0.161569] dmar: IOMMU 0: reg_base_addr fed90000 ver 1:0 cap
> c90780106f0462 ecap f020f6
> ...
> [    0.224974] dmar: RMRR base: 0x000000cf4c2000 end: 0x000000cf4c2fff
> [    0.231442] dmar: ATSR flags: 0x0
> [    0.235046] Switched APIC routing to physical flat.
> [    0.240639] ..TIMER: vector=0x30 apic1=0 pin1=2 apic2=-1 pin2=-1
> [    0.256738] smpboot: CPU0: Intel(R) Xeon(R) CPU           X5660  @
> 2.80GHz (fam: 06, model: 2c, stepping: 02)
> [    0.368291] Performance Events: PEBS fmt1+, 16-deep LBR, Westmere
> events, Intel PMU driver.
> [    0.376959] perf_event_intel: CPUID marked event: 'bus cycles'
> unavailable
> [    0.383937] ... version:                3
> [    0.388059] ... bit width:              48
> [    0.392282] ... generic registers:      4
> [    0.396395] ... value mask:             0000ffffffffffff
> [    0.401818] ... max period:             000000007fffffff
> [    0.407240] ... fixed-purpose events:   3
> [    0.411353] ... event mask:             000000070000000f
> [    0.424313] SMP alternatives: lockdep: fixing up alternatives
> [    0.526339] NMI watchdog: enabled on all CPUs, permanently consumes
> one hw-PMU counter.
> [    0.430197] smpboot: Booting Node   1, Processors  #1
> ...
> [    0.767737] smpboot: Booting Node   0, Processors  #10
> [    0.787660] SMP alternatives: lockdep: fixing up alternatives
> [    0.793815]  OK
> [    0.795696] smpboot: Booting Node   1, Processors  #11 OK
> [    0.814480] Brought up 12 CPUs
> [    0.817643] smpboot: Total of 12 processors activated (67031.54 BogoMIPS)
> [    0.837389] devtmpfs: initialized
> [    0.841517] NET: Registered protocol family 16
> [    0.846297] i2c-core: driver [dummy] registered
> [    0.846445] ACPI FADT declares the system doesn't support PCIe ASPM,
> so disable it
> [    0.854119] ACPI: bus type pci registered
> [    0.858333] dca service started, version 1.12.1
> [    0.863002] PCI: MMCONFIG for domain 0000 [bus 00-ff] at [mem
> 0xe0000000-0xefffffff] (base 0xe0000000)
> [    0.872412] PCI: MMCONFIG at [mem 0xe0000000-0xefffffff] reserved in E820
> [    0.915444] PCI: Using configuration type 1 for base access
> [    0.923541] bio: create slab <bio-0> at 0
> [    0.927876] ACPI: Added _OSI(Module Device)
> [    0.932207] ACPI: Added _OSI(Processor Device)
> [    0.936769] ACPI: Added _OSI(3.0 _SCP Extensions)
> [    0.941613] ACPI: Added _OSI(Processor Aggregator Device)
> [    0.949347] ACPI: EC: Look up EC in DSDT
> [    0.952568] [Firmware Bug]: ACPI: BIOS _OSI(Linux) query ignored
> [    0.962779] ACPI: Interpreter enabled
> [    0.966551] ACPI: (supports S0 S5)
> [    0.970176] ACPI: Using IOAPIC for interrupt routing
> [    0.982895] HEST: Table parsing has been initialized.
> [    0.988063] PCI: Using host bridge windows from ACPI; if necessary,
> use "pci=nocrs" and report a bug
> [    0.997500] ACPI: PCI Root Bridge [PCI0] (domain 0000 [bus 00-ff])
> [    1.003792] ACPI: PCI Interrupt Routing Table [\_SB_.PCI0._PRT]
> [    1.004949] pci_root PNP0A08:00: Requesting ACPI _OSC control (0x15)
> [    1.011897] pci_root PNP0A08:00: ACPI _OSC control (0x15) granted
> [    1.018511] PCI host bridge to bus 0000:00
> [    1.022727] pci_bus 0000:00: root bus resource [bus 00-ff]
> ...
> [    1.054860] pci_bus 0000:00: root bus resource [mem
> 0xfed40000-0xfed44fff]
> [    1.065200] pci 0000:00:00.0: [8086:3406] type 00 class 0x060000
> ...
> [    1.066442] pci 0000:00:16.0: [8086:3430] type 00 class 0x088000
> [    1.066459] pci 0000:00:16.0: reg 10: [mem 0xdf0e0000-0xdf0e3fff 64bit]
> ...
> [    1.067245] pci 0000:00:16.7: [8086:342c] type 00 class 0x088000
> [    1.067261] pci 0000:00:16.7: reg 10: [mem 0xdf0fc000-0xdf0fffff 64bit]
> [    1.067362] pci 0000:00:1a.0: [8086:2937] type 00 class 0x0c0300
> ...
> [    1.144174] pci 0000:00:1e.0:   bridge window [mem
> 0xd0000000-0xfdffffff] (subtractive decode)
> [    1.144176] pci 0000:00:1e.0:   bridge window [mem
> 0xfed40000-0xfed44fff] (subtractive decode)
> [    1.144234] ACPI: PCI Interrupt Routing Table [\_SB_.PCI0.PEX1._PRT]
> ...
> [    1.201823] ACPI: PCI Interrupt Link [LK06] (IRQs 3 4 5 6 7 10 11 14
> 15) *0, disabled.
> [    1.210634] ACPI: PCI Interrupt Link [LK07] (IRQs 3 4 *5 6 7 10 11 14 15)
> [    1.218252] SCSI subsystem initialized
> [    1.222118] ACPI: bus type scsi registered
> [    1.226390] libata version 3.00 loaded.
> [    1.226405] ACPI: bus type usb registered
> [    1.230546] usbcore: registered new interface driver usbfs
> [    1.236210] usbcore: registered new interface driver hub
> [    1.241673] usbcore: registered new device driver usb
> [    1.246856] pps_core: LinuxPPS API ver. 1 registered
> [    1.251935] pps_core: Software ver. 5.3.6 - Copyright 2005-2007
> Rodolfo Giometti <giometti@linux.it>
> [    1.261180] PTP clock support registered
> [    1.265251] PCI: Using ACPI for IRQ routing
> [    1.276548] PCI: Discovered peer bus fe
> [    1.280502] PCI: root bus fe: using default resources
> [    1.280503] PCI: Probing PCI hardware (bus fe)
> [    1.280544] PCI host bridge to bus 0000:fe
> [    1.284756] pci_bus 0000:fe: root bus resource [io  0x0000-0xffff]
> [    1.291039] pci_bus 0000:fe: root bus resource [mem
> 0x00000000-0xffffffffff]
> [    1.298198] pci_bus 0000:fe: No busn resource found for root bus,
> will use [bus fe-ff]
> [    1.306219] pci 0000:fe:00.0: [8086:2c70] type 00 class 0x060000
> ...
> [    1.307032] pci 0000:fe:06.3: [8086:2db3] type 00 class 0x060000
> [    1.307092] pci_bus 0000:fe: busn_res: [bus fe-ff] end is updated to fe
> [    1.307859] PCI: Discovered peer bus ff
> [    1.311814] PCI: root bus ff: using default resources
> [    1.311815] PCI: Probing PCI hardware (bus ff)
> [    1.311850] PCI host bridge to bus 0000:ff
> [    1.316053] pci_bus 0000:ff: root bus resource [io  0x0000-0xffff]
> [    1.322346] pci_bus 0000:ff: root bus resource [mem
> 0x00000000-0xffffffffff]
> [    1.329504] pci_bus 0000:ff: No busn resource found for root bus,
> will use [bus ff-ff]
> [    1.337525] pci 0000:ff:00.0: [8086:2c70] type 00 class 0x060000
> ...
> [    1.338386] pci 0000:ff:06.3: [8086:2db3] type 00 class 0x060000
> [    1.338450] pci_bus 0000:ff: busn_res: [bus ff] end is updated to ff
> [    1.339197] PCI: pci_cache_line_size set to 64 bytes
> [    1.339469] e820: reserve RAM buffer [mem 0xcf379000-0xcfffffff]
> [    1.339687] hpet0: at MMIO 0xfed00000, IRQs 2, 8, 0, 0
> [    1.345199] hpet0: 4 comparators, 64-bit 14.318180 MHz counter
> [    1.353153] Switching to clocksource hpet
> [    1.369117] FS-Cache: Loaded
> [    1.372138] pnp: PnP ACPI init
> [    1.375319] ACPI: bus type pnp registered
> [    1.379569] pnp 00:00: [dma 4]
> ...
> [    1.455138] pnp 00:0a: Plug and Play ACPI device, IDs PNP0103 (active)
> [    1.455269] system 00:0b: [mem 0xfed90000-0xfed91fff] could not be
> reserved
> [    1.462353] system 00:0b: Plug and Play ACPI device, IDs PNP0c02 (active)
> [    1.462732] pnp: PnP ACPI: found 12 devices
> [    1.467044] ACPI: ACPI bus type pnp unregistered
> [    1.481774] pci 0000:06:00.1: address space collision: [mem
> 0xdf300000-0xdf37ffff pref] conflicts with 0000:06:00.0 [mem
> 0xdf300000-0xdf37ffff pref]
> [    1.495395] pci 0000:00:01.0: PCI bridge to [bus 01]
> [    1.500484] pci 0000:00:01.0:   bridge window [mem 0xda000000-0xddffffff]
> ...
> [    1.611994] pci 0000:00:1e.0:   bridge window [mem 0xde000000-0xdeffffff]
> [    1.623952] pci 0000:00:1e.0:   bridge window [mem
> 0xd9000000-0xd97fffff 64bit pref]
> [    1.631898] pci 0000:00:1e.0: setting latency timer to 64
> ...
> [    1.631951] pci_bus 0000:ff: resource 5 [mem 0x00000000-0xffffffffff]
> [    1.632012] NET: Registered protocol family 2
> [    1.637148] TCP established hash table entries: 524288 (order: 11,
> 8388608 bytes)
> [    1.646389] TCP bind hash table entries: 65536 (order: 10, 5242880 bytes)
> ...
> [    1.815851] IOMMU: Setting identity map for device 0000:00:1a.7
> [0xcf4c8000 - 0xcf4dffff]
> [    1.824137] IOMMU: Setting identity map for device 0000:00:1d.7
> [0xcf4c8000 - 0xcf4dffff]
> [    1.832424] IOMMU: Prepare 0-16MiB unity mapping for LPC
> [    1.837883] IOMMU: Setting identity map for device 0000:00:1f.0 [0x0
> - 0xffffff]
> [    1.845592] PCI-DMA: Intel(R) Virtualization Technology for Directed I/O
> ...
> [    1.923963] microcode: CPU11 sig=0x206c2, pf=0x1, revision=0x15
> [    1.930096] microcode: Microcode Update Driver: v2.00
> <tigran@aivazian.fsnet.co.uk>, Peter Oruba
> [    1.939117] sha1_ssse3: Using SSSE3 optimized SHA-1 implementation
> [    1.939131] cryptomgr_test (77) used greatest stack depth: 5832 bytes
> left
> [    1.954626] HugeTLB registered 2 MB page size, pre-allocated 0 pages
> [    1.965735] Key type cifs.idmap registered
> [    1.970070] SGI XFS with ACLs, security attributes, realtime, large
> block/inode numbers, no debug enabled
> [    1.980271] msgmni has been set to 32768
> [    1.985133] cryptomgr_test (97) used greatest stack depth: 5776 bytes
> left
> [    1.985471] alg: No test for stdrng (krng)
> [    1.985539] Block layer SCSI generic (bsg) driver version 0.4 loaded
> (major 250)
> [    1.985596] io scheduler noop registered
> [    1.985643] io scheduler cfq registered (default)
> ...
> [    1.987902] pcieport 0000:00:0a.0: irq 79 for MSI/MSI-X
> [    1.988057] pcieport 0000:00:01.0: Signaling PME through PCIe PME
> interrupt
> ...
> [    1.988274] pcie_pme 0000:00:0a.0:pcie01: service driver pcie_pme loaded
> [    1.988375] intel_idle: MWAIT substates: 0x1120
> [    1.988375] intel_idle: v0.4 model 0x2C
> [    1.988376] intel_idle: lapic_timer_reliable_states 0xffffffff
> [    2.115394] cryptomgr_test (99) used greatest stack depth: 5208 bytes
> left
> [    2.122414] ipmi message handler version 39.2
> [    2.126909] ipmi device interface
> [    2.130384] IPMI System Interface driver.
> [    2.134590] ipmi_si: probing via SMBIOS
> [    2.138537] ipmi_si: SMBIOS: io 0xca8 regsize 1 spacing 4 irq 0
> [    2.144571] ipmi_si: Adding SMBIOS-specified kcs state machine
> [    2.150581] ipmi_si: Trying SMBIOS-specified kcs state machine at i/o
> address 0xca8, slave address 0x20, irq 0
> [    2.376680] ipmi_si ipmi_si.0: Found new BMC (man_id: 0x0002a2,
> prod_id: 0x0100, dev_id: 0x20)
> [    2.385509] ipmi_si ipmi_si.0: IPMI kcs interface initialized
> [    2.391506] ERST: Error Record Serialization Table (ERST) support is
> initialized.
> [    2.399478] GHES: APEI firmware first mode is enabled by APEI bit and
> WHEA _OSC.
> [    2.406995] ioatdma: Intel(R) QuickData Technology Driver 4.00
> ...
> [    2.416327] ioatdma 0000:00:16.7: irq 87 for MSI/MSI-X
> [    2.450434] Serial: 8250/16550 driver, 4 ports, IRQ sharing enabled
> [    2.480844] 00:04: ttyS0 at I/O 0x3f8 (irq = 4) is a 16550A
> [    2.507130] 00:05: ttyS1 at I/O 0x2f8 (irq = 3) is a 16550A
> [    2.513742] Non-volatile memory driver v1.3
> [    2.521604] brd: module loaded
> [    2.526285] loop: module loaded
> [    2.530376] nbd: registered device at major 43
> [    2.537559] gpio_ich: GPIO from 195 to 255 on gpio_ich
> [    2.543005] Loading iSCSI transport class v2.0-870.
> [    2.548103] megasas: 06.504.01.00-rc1 Mon. Oct. 1 17:00:00 PDT 2012
> [    2.554547] megasas: 0x1000:0x0079:0x1000:0x9275: bus 5:slot 0:func 0
> [    2.561326] megasas: FW now in Ready state
> ...
> [    2.844408] scsi 0:0:29:0: Direct-Access     ATA      Hitachi
> HUA72202 A3EA PQ: 0 ANSI: 5
> ...
> [    2.958508] bonding: Ethernet Channel Bonding Driver: v3.7.1 (April
> 27, 2011)
> [    2.959107] bnx2: Broadcom NetXtreme II Gigabit Ethernet Driver bnx2
> v2.2.3 (June 27, 2012)
> [    2.959422] scsi 1:0:4:0: Direct-Access     ATA      Hitachi HUA72202
> A3EA PQ: 0 ANSI: 5
> [    2.959720] bnx2 0000:01:00.0 eth0: Broadcom NetXtreme II BCM5709
> 1000Base-T (C0) PCI Express found at mem da000000, IRQ 36, node addr
> 00:26:b9:2c:a4:ef
> [    2.960305] bnx2 0000:01:00.1 eth1: Broadcom NetXtreme II BCM5709
> 1000Base-T (C0) PCI Express found at mem dc000000, IRQ 48, node addr
> 00:26:b9:2c:a4:f1
> [    2.960347] e1000e: Intel(R) PRO/1000 Network Driver - 2.1.4-k
> [    2.960348] e1000e: Copyright(c) 1999 - 2012 Intel Corporation.
> [    2.960377] e1000e 0000:03:00.0: Disabling ASPM  L1
> [    2.960470] e1000e 0000:03:00.0: Interrupt Throttling Rate (ints/sec)
> set to dynamic conservative mode
> [    2.960511] e1000e 0000:03:00.0: irq 89 for MSI/MSI-X
> [    3.007831] scsi 1:0:5:0: Direct-Access     ATA      Hitachi HUA72202
> A3EA PQ: 0 ANSI: 5
> ...
> [    3.127317] scsi 0:0:39:0: Direct-Access     ATA      Hitachi
> HUA72202 A3EA PQ: 0 ANSI: 5
> [    3.132612] e1000e 0000:03:00.0 eth2: (PCI Express:2.5GT/s:Width x4)
> 00:15:17:bf:be:b2
> [    3.132614] e1000e 0000:03:00.0 eth2: Intel(R) PRO/1000 Network
> Connection
> [    3.132689] e1000e 0000:03:00.0 eth2: MAC: 0, PHY: 4, PBA No: C57721-005
> [    3.132702] e1000e 0000:03:00.1: Disabling ASPM  L1
> [    3.132795] e1000e 0000:03:00.1: Interrupt Throttling Rate (ints/sec)
> set to dynamic conservative mode
> [    3.132836] e1000e 0000:03:00.1: irq 90 for MSI/MSI-X
> [    3.159261] Uhhuh. NMI received for unknown reason 31 on CPU 0.
> [    3.159261] Do you have a strange power saving mode enabled?
> [    3.159262] Dazed and confused, but trying to continue
> [    3.188918] dmar: DRHD: handling fault status reg 2
> [    3.193907] dmar: DMAR:[DMA Read] Request device [02:00.0] fault addr
> ffe76000
> [    3.193907] DMAR:[fault reason 06] PTE Read access is not set
> [    3.240182] scsi 0:2:0:0: Direct-Access     LSI      MR9280DE-8e     
> 2.0. PQ: 0 ANSI: 5
> [    3.248746] scsi 0:2:1:0: Direct-Access     LSI      MR9280DE-8e     
> 2.0. PQ: 0 ANSI: 5
> [    3.282652] dmar: DRHD: handling fault status reg 102
> [    3.284312] ses 0:0:14:0: Attached Enclosure device
> [    3.284426] ses 0:0:14:0: Attached scsi generic sg0 type 13
> [    3.301981] dmar: DMAR:[DMA Read] Request device [02:00.0] fault addr
> ffe8a000
> [    3.301981] DMAR:[fault reason 06] PTE Read access is not set
> [    3.305305] e1000e 0000:03:00.1 eth3: (PCI Express:2.5GT/s:Width x4)
> 00:15:17:bf:be:b3
> [    3.305307] e1000e 0000:03:00.1 eth3: Intel(R) PRO/1000 Network
> Connection
> [    3.305382] e1000e 0000:03:00.1 eth3: MAC: 0, PHY: 4, PBA No: C57721-005
> [    3.305431] ixgbe: Intel(R) 10 Gigabit PCI Express Network Driver -
> version 3.11.33-k
> [    3.305431] ixgbe: Copyright (c) 1999-2012 Intel Corporation.
> [    3.350903] scsi 1:0:32:0: Enclosure         DP      
> BACKPLANE        1.07 PQ: 0 ANSI: 5
> [    3.359344] dmar: DRHD: handling fault status reg 202
> [    3.364534] dmar: DMAR:[DMA Read] Request device [02:00.0] fault addr
> ffe89000
> [    3.364534] DMAR:[fault reason 06] PTE Read access is not set
> [    3.386416] ses 0:0:27:0: Attached Enclosure device
> ...
> [    3.508700] sd 0:2:1:0: [sdb] Attached SCSI disk
> [    3.622261] ses 1:0:32:0: Attached Enclosure device
> [    3.627372] ses 1:0:32:0: Attached scsi generic sg4 type 13
> [    3.733753] ixgbe 0000:06:00.0: irq 91 for MSI/MSI-X
> [    3.733763] ixgbe 0000:06:00.0: irq 92 for MSI/MSI-X
> [    3.733772] ixgbe 0000:06:00.0: irq 93 for MSI/MSI-X
> [    3.733780] ixgbe 0000:06:00.0: irq 94 for MSI/MSI-X
> [    3.733789] ixgbe 0000:06:00.0: irq 95 for MSI/MSI-X
> [    3.733797] ixgbe 0000:06:00.0: irq 96 for MSI/MSI-X
> [    3.733805] ixgbe 0000:06:00.0: irq 97 for MSI/MSI-X
> [    3.733814] ixgbe 0000:06:00.0: irq 98 for MSI/MSI-X
> [    3.733822] ixgbe 0000:06:00.0: irq 99 for MSI/MSI-X
> [    3.733831] ixgbe 0000:06:00.0: irq 100 for MSI/MSI-X
> [    3.733839] ixgbe 0000:06:00.0: irq 101 for MSI/MSI-X
> [    3.733847] ixgbe 0000:06:00.0: irq 102 for MSI/MSI-X
> [    3.733856] ixgbe 0000:06:00.0: irq 103 for MSI/MSI-X
> [    3.733933] ixgbe 0000:06:00.0: Multiqueue Enabled: Rx Queue count =
> 12, Tx Queue count = 12
> [    3.742464] dmar: DRHD: handling fault status reg 302
> [    3.742467] dmar: DMAR:[DMA Read] Request device [02:00.0] fault addr
> ffe86000
> [    3.742467] DMAR:[fault reason 06] PTE Read access is not set
> [    3.805353] dmar: DRHD: handling fault status reg 402
> [    3.810529] dmar: DMAR:[DMA Read] Request device [02:00.0] fault addr
> ffe87000
> [    3.810529] DMAR:[fault reason 06] PTE Read access is not set
> [    3.820908] ixgbe 0000:06:00.0: (PCI Express:5.0GT/s:Width x8)
> a0:36:9f:15:c9:c0
> [    3.889229] dmar: DRHD: handling fault status reg 502
> [    3.894389] dmar: DMAR:[DMA Read] Request device [02:00.0] fault addr
> ffe84000
> [    3.894389] DMAR:[fault reason 06] PTE Read access is not set
> ...
> [    4.037793] sd 1:2:0:0: [sdc] Attached SCSI disk
> [    4.062063] dmar: DRHD: handling fault status reg 702
> [    4.067233] dmar: DMAR:[DMA Read] Request device [02:00.0] fault addr
> ffe7f000
> [    4.067233] DMAR:[fault reason 06] PTE Read access is not set
> [    4.100647]  sdd: sdd1
> [    4.103655] sd 1:2:1:0: [sdd] Attached SCSI disk
> [    4.123872] ixgbe 0000:06:00.0: Intel(R) 10 Gigabit Network Connection
> [    4.558317] ixgbe 0000:06:00.1: irq 104 for MSI/MSI-X
> [    4.558326] ixgbe 0000:06:00.1: irq 105 for MSI/MSI-X
> [    4.558335] ixgbe 0000:06:00.1: irq 106 for MSI/MSI-X
> [    4.558343] ixgbe 0000:06:00.1: irq 107 for MSI/MSI-X
> [    4.558351] ixgbe 0000:06:00.1: irq 108 for MSI/MSI-X
> [    4.558360] ixgbe 0000:06:00.1: irq 109 for MSI/MSI-X
> [    4.558368] ixgbe 0000:06:00.1: irq 110 for MSI/MSI-X
> [    4.558376] ixgbe 0000:06:00.1: irq 111 for MSI/MSI-X
> [    4.558385] ixgbe 0000:06:00.1: irq 112 for MSI/MSI-X
> [    4.558393] ixgbe 0000:06:00.1: irq 113 for MSI/MSI-X
> [    4.558401] ixgbe 0000:06:00.1: irq 114 for MSI/MSI-X
> [    4.558410] ixgbe 0000:06:00.1: irq 115 for MSI/MSI-X
> [    4.558418] ixgbe 0000:06:00.1: irq 116 for MSI/MSI-X
> [    4.558490] ixgbe 0000:06:00.1: Multiqueue Enabled: Rx Queue count =
> 12, Tx Queue count = 12
> [    4.627063] ixgbe 0000:06:00.1: (PCI Express:5.0GT/s:Width x8)
> a0:36:9f:15:c9:c2
> [    4.794640] ixgbe 0000:06:00.1: MAC: 3, PHY: 3, PBA No: G45270-002
> [    4.943908] ixgbe 0000:06:00.1: Intel(R) 10 Gigabit Network Connection
> [    4.950603] I2O subsystem v1.325
> [    4.953953] i2o: max drivers = 8
> ...
> [    5.519890] usbserial: USB Serial support registered for generic
> [    5.526107] i8042: PNP: No PS/2 controller found. Probing ports directly.
> [    5.535870] serio: i8042 KBD port at 0x60,0x64 irq 1
> [    5.541055] serio: i8042 AUX port at 0x60,0x64 irq 12
> [    5.549583] usbcore: registered new interface driver wacom
> [    5.555277] input: PC Speaker as /devices/platform/pcspkr/input/input0
> [    5.562198] rtc_cmos 00:03: RTC can wake from S4
> [    5.567265] rtc_cmos 00:03: rtc core: registered rtc_cmos as rtc0
> [    5.574040] rtc0: alarms up to one day, y3k, 242 bytes nvram, hpet irqs
> [    5.580796] i2c /dev entries driver
> [    5.585128] ACPI Error: No handler for Region [IPMI]
> (ffff880613c39240) [IPMI] (20121018/evregion-376)
> [    5.594665] ACPI Error: Region IPMI (ID=7) has no handler
> (20121018/exfldio-305)
> [    5.602573] ACPI Error: Method parse/execution failed
> [\_SB_.PMI0._GHL] (Node ffff880613c38b18), AE_NOT_EXIST
> (20121018/psparse-537)
> [    5.614909] ACPI Error: Method parse/execution failed
> [\_SB_.PMI0._PMC] (Node ffff880613c38a78), AE_NOT_EXIST
> (20121018/psparse-537)
> [    5.627254] ACPI Exception: AE_NOT_EXIST, Evaluating _PMC
> (20121018/power_meter-753)
> [    5.635332] coretemp coretemp.1: TjMax is 96 degrees C
> ...
> [    5.635573] coretemp coretemp.0: TjMax is 96 degrees C
> [    5.635834] device-mapper: uevent: version 1.0.3
> [    5.640724] device-mapper: ioctl: 4.23.1-ioctl (2012-12-18)
> initialised: dm-devel@redhat.com
> [    5.649319] EDAC MC: Ver: 3.0.0
> [    5.653653] EDAC MC1: Giving out device to 'i7core_edac.c' 'i7 core
> #1': DEV 0000:fe:03.0
> [    5.662012] EDAC PCI0: Giving out device to module 'i7core_edac'
> controller 'EDAC PCI controller': DEV '0000:fe:03.0' (POLLED)
> [    5.674123] EDAC MC0: Giving out device to 'i7core_edac.c' 'i7 core
> #0': DEV 0000:ff:03.0
> [    5.682450] EDAC PCI1: Giving out device to module 'i7core_edac'
> controller 'EDAC PCI controller': DEV '0000:ff:03.0' (POLLED)
> [    5.694321] EDAC i7core: Driver loaded, 2 memory controller(s) found.
> [    5.701319] cpuidle: using governor ladder
> [    5.706287] cpuidle: using governor menu
> [    5.711285] EFI Variables Facility v0.08 2004-May-17
> [    5.716452] dcdbas dcdbas: Dell Systems Management Base Driver
> (version 5.6.0-3.2)
> [    5.724250] usbcore: registered new interface driver usbhid
> [    5.729946] usbhid: USB HID core driver
> [    5.733841] usb 7-1: new low-speed USB device number 2 using uhci_hcd
> [    5.740464] GACT probability on
> [    5.743781] Netfilter messages via NETLINK v0.30.
> [    5.748733] ip_tables: (C) 2000-2006 Netfilter Core Team
> [    5.754795] TCP: highspeed registered
> [    5.758606] TCP: htcp registered
> [    5.761957] TCP: scalable registered
> [    5.765638] TCP: lp registered
> [    5.768828] NET: Registered protocol family 17
> [    5.773416] Key type dns_resolver registered
> [    5.778771] registered taskstats version 1
> [    5.785472] console [netcon0] enabled
> [    5.789268] netconsole: network logging started
> [    5.794417] rtc_cmos 00:03: setting system clock to 2013-03-03
> 13:36:33 UTC (1362317793)
> ...
> [    6.034685] Freeing unused kernel memory: 2356k freed
> [    6.040393] Write protecting the kernel read-only data: 12288k
> [    6.055099] Freeing unused kernel memory: 1804k freed
> [    6.066535] Freeing unused kernel memory: 1296k freed
> ...
> [    7.272433] XFS (sdc6): Ending clean mount
> [    8.729858] ACPI: Requesting acpi_cpufreq
> [    8.736906] mousedev: PS/2 mouse device common for all mice
> [    8.740862] Uhhuh. NMI received for unknown reason 31 on CPU 0.
> [    8.740862] Do you have a strange power saving mode enabled?
> [    8.740863] Dazed and confused, but trying to continue
> [    8.763852] input: Power Button as
> /devices/LNXSYSTM:00/LNXPWRBN:00/input/input5
> [    8.771464] ACPI: Power Button [PWRF]
> [    8.816722] iTCO_wdt: Intel TCO WatchDog Timer Driver v1.10
> [    8.822886] iTCO_wdt: Found a ICH9 TCO device (Version=2, TCOBASE=0x0860)
> [    8.830275] iTCO_wdt: initialized. heartbeat=30 sec (nowayout=0)
> [    8.871909] kvm: VM_EXIT_LOAD_IA32_PERF_GLOBAL_CTRL does not work
> properly. Using workaround
> [    9.311531] Adding 8393924k swap on /dev/sdc5.  Priority:-1 extents:1
> across:8393924k
> [    9.898467] bio: create slab <bio-1> at 1
> [   10.320156] bio: create slab <bio-2> at 2
> [   12.848010] XFS (sdc2): Mounting Filesystem
> ...
> [   14.534075] XFS (dm-6): Ending clean mount
> [   18.538494] bonding: bond0: Setting MII monitoring interval to 250.
> [   18.552402] bonding: bond0: Adding slave eth_s2_0.
> [   18.620810] pps pps0: new PPS source ptp0
> [   18.624829] ixgbe 0000:06:00.0: registered PHC device on eth_s2_0
> [   19.055454] bonding: bond0: enslaving eth_s2_0 as an active interface
> with a down link.
> [   19.073574] bonding: bond0: Adding slave eth_s2_1.
> [   19.140326] pps pps1: new PPS source ptp1
> [   19.144340] ixgbe 0000:06:00.1: registered PHC device on eth_s2_1
> [   19.574896] bonding: bond0: enslaving eth_s2_1 as an active interface
> with a down link.
> [   19.597337] ixgbe 0000:06:00.0 eth_s2_0: changing MTU from 1500 to 9000
> [   20.466899] ixgbe 0000:06:00.1 eth_s2_1: changing MTU from 1500 to 9000
> [   22.177843] e1000e 0000:03:00.0 eth0: changing MTU from 1500 to 9000
> [   22.472021] e1000e 0000:03:00.0: irq 89 for MSI/MSI-X
> [   22.572957] e1000e 0000:03:00.0: irq 89 for MSI/MSI-X
> [   22.917065] e1000e 0000:03:00.1 eth1: changing MTU from 1500 to 9000
> [   23.211319] e1000e 0000:03:00.1: irq 90 for MSI/MSI-X
> [   23.311726] e1000e 0000:03:00.1: irq 90 for MSI/MSI-X
> [   23.677061] bnx2 0000:01:00.0: irq 117 for MSI/MSI-X
> ...
> [   23.677168] bnx2 0000:01:00.0: irq 125 for MSI/MSI-X
> [   23.729930] bnx2 0000:01:00.0 eth2: using MSIX
> [   23.730055] ip (2400) used greatest stack depth: 2096 bytes left
> [   24.075847] bnx2 0000:01:00.1: irq 126 for MSI/MSI-X
> ...
> [   24.075913] bnx2 0000:01:00.1: irq 134 for MSI/MSI-X
> [   24.129293] bnx2 0000:01:00.1 eth3: using MSIX
> [   24.776033] ixgbe 0000:06:00.0 eth_s2_0: NIC Link is Up 10 Gbps, Flow
> Control: RX/TX
> [   24.820010] BUG: scheduling while atomic: kworker/u:2/109/0x00000002
> [   24.826415] 4 locks held by kworker/u:2/109:
> [   24.826425]  #0:  ((bond_dev->name)){......}, at:
> [<ffffffff8105da4d>] process_one_work+0x13d/0x5d0
> [   24.826428]  #1:  ((&(&bond->mii_work)->work)){......}, at:
> [<ffffffff8105da4d>] process_one_work+0x13d/0x5d0
> [   24.826435]  #2:  (rtnl_mutex){......}, at: [<ffffffff81590c00>]
> rtnl_trylock+0x10/0x20
> [   24.826441]  #3:  (&bond->lock){......}, at: [<ffffffff8145af55>]
> bond_mii_monitor+0x2d5/0x630
> [   24.826448] Modules linked in: iptable_filter kvm_intel kvm iTCO_wdt
> acpi_cpufreq mperf button mousedev processor
> [   24.826451] Pid: 109, comm: kworker/u:2 Not tainted 3.8.1-Isht-Van #6
> [   24.826452] Call Trace:
> [   24.826459]  [<ffffffff8162b039>] __schedule_bug+0x5e/0x6c
> [   24.826475]  [<ffffffff816345a2>] __schedule+0x762/0x7f0
> [   24.826479]  [<ffffffff81634744>] schedule+0x24/0x70
> [   24.826488]  [<ffffffff81633704>]
> schedule_hrtimeout_range_clock+0xa4/0x130
> [   24.826495]  [<ffffffff81068250>] ? update_rmtp+0x60/0x60
> [   24.826499]  [<ffffffff81068f9f>] ? hrtimer_start_range_ns+0xf/0x20
> [   24.826507]  [<ffffffff8163379e>] schedule_hrtimeout_range+0xe/0x10
> [   24.826512]  [<ffffffff8104ec1b>] usleep_range+0x3b/0x40
> [   24.826518]  [<ffffffff814b2d8c>] ixgbe_acquire_swfw_sync_X540+0xbc/0x100
> [   24.826527]  [<ffffffff814aeb1d>] ixgbe_read_phy_reg_generic+0x3d/0x140
> [   24.826532]  [<ffffffff814aedbc>]
> ixgbe_get_copper_link_capabilities_generic+0x2c/0x60
> [   24.826537]  [<ffffffff8145af55>] ? bond_mii_monitor+0x2d5/0x630
> [   24.826543]  [<ffffffff814a64f4>] ixgbe_get_settings+0x34/0x340
> [   24.826546]  [<ffffffff81586ac8>] __ethtool_get_settings+0x88/0x130
> [   24.826552]  [<ffffffff814568a3>] bond_update_speed_duplex+0x23/0x60
> [   24.826554]  [<ffffffff8145afc4>] bond_mii_monitor+0x344/0x630
> [   24.826556]  [<ffffffff8105dab1>] process_one_work+0x1a1/0x5d0
> [   24.826558]  [<ffffffff8105da4d>] ? process_one_work+0x13d/0x5d0
> [   24.826560]  [<ffffffff8145ac80>] ? bond_loadbalance_arp_mon+0x300/0x300
> [   24.826563]  [<ffffffff8105ed60>] worker_thread+0x160/0x3f0
> [   24.826565]  [<ffffffff8105ec00>] ? manage_workers+0x290/0x290
> [   24.826569]  [<ffffffff81064446>] kthread+0xd6/0xe0
> [   24.826573]  [<ffffffff8107004a>] ? finish_task_switch+0x3a/0x100
> [   24.826576]  [<ffffffff81064370>] ? flush_kthread_worker+0x160/0x160
> [   24.826578]  [<ffffffff81636fec>] ret_from_fork+0x7c/0xb0
> [   24.826580]  [<ffffffff81064370>] ? flush_kthread_worker+0x160/0x160
> [   24.829930] BUG: scheduling while atomic: kworker/u:2/109/0x00000002
> [   24.836284] 4 locks held by kworker/u:2/109:
> [   24.836287]  #0:  ((bond_dev->name)){......}, at:
> [<ffffffff8105da4d>] process_one_work+0x13d/0x5d0
> [   24.836297]  #1:  ((&(&bond->mii_work)->work)){......}, at:
> [<ffffffff8105da4d>] process_one_work+0x13d/0x5d0
> [   24.836304]  #2:  (rtnl_mutex){......}, at: [<ffffffff81590c00>]
> rtnl_trylock+0x10/0x20
> [   24.836312]  #3:  (&bond->lock){......}, at: [<ffffffff8145af55>]
> bond_mii_monitor+0x2d5/0x630
> [   24.836320] Modules linked in: iptable_filter kvm_intel kvm iTCO_wdt
> acpi_cpufreq mperf button mousedev processor
> [   24.836334] Pid: 109, comm: kworker/u:2 Tainted: G        W   
> 3.8.1-Isht-Van #6
> [   24.836336] Call Trace:
> [   24.836342]  [<ffffffff8162b039>] __schedule_bug+0x5e/0x6c
> [   24.836348]  [<ffffffff816345a2>] __schedule+0x762/0x7f0
> [   24.836352]  [<ffffffff81634744>] schedule+0x24/0x70
> [   24.836357]  [<ffffffff81633704>]
> schedule_hrtimeout_range_clock+0xa4/0x130
> [   24.836362]  [<ffffffff81068250>] ? update_rmtp+0x60/0x60
> [   24.836366]  [<ffffffff81068250>] ? update_rmtp+0x60/0x60
> [   24.836371]  [<ffffffff81068f9f>] ? hrtimer_start_range_ns+0xf/0x20
> [   24.836375]  [<ffffffff8163379e>] schedule_hrtimeout_range+0xe/0x10
> [   24.836380]  [<ffffffff8104ec1b>] usleep_range+0x3b/0x40
> [   24.836385]  [<ffffffff814b2cbe>] ixgbe_release_swfw_sync_X540+0x4e/0x60
> [   24.836390]  [<ffffffff814aebed>] ixgbe_read_phy_reg_generic+0x10d/0x140
> [   24.836395]  [<ffffffff814aedbc>]
> ixgbe_get_copper_link_capabilities_generic+0x2c/0x60
> [   24.836400]  [<ffffffff8145af55>] ? bond_mii_monitor+0x2d5/0x630
> [   24.836404]  [<ffffffff814a64f4>] ixgbe_get_settings+0x34/0x340
> [   24.836409]  [<ffffffff81586ac8>] __ethtool_get_settings+0x88/0x130
> [   24.836413]  [<ffffffff814568a3>] bond_update_speed_duplex+0x23/0x60
> [   24.836418]  [<ffffffff8145afc4>] bond_mii_monitor+0x344/0x630
> [   24.836422]  [<ffffffff8105dab1>] process_one_work+0x1a1/0x5d0
> [   24.836426]  [<ffffffff8105da4d>] ? process_one_work+0x13d/0x5d0
> [   24.836431]  [<ffffffff8145ac80>] ? bond_loadbalance_arp_mon+0x300/0x300
> [   24.836436]  [<ffffffff8105ed60>] worker_thread+0x160/0x3f0
> [   24.836440]  [<ffffffff8105ec00>] ? manage_workers+0x290/0x290
> [   24.836445]  [<ffffffff81064446>] kthread+0xd6/0xe0
> [   24.836449]  [<ffffffff8107004a>] ? finish_task_switch+0x3a/0x100
> [   24.836455]  [<ffffffff81064370>] ? flush_kthread_worker+0x160/0x160
> [   24.836459]  [<ffffffff81636fec>] ret_from_fork+0x7c/0xb0
> [   24.836464]  [<ffffffff81064370>] ? flush_kthread_worker+0x160/0x160
> [   24.839952] bonding: bond0: link status definitely up for interface
> eth_s2_0, 10000 Mbps full duplex.
> [   24.839968] bonding: bond0: first active interface up!
> [   24.955598] e1000e: eth0 NIC Link is Up 1000 Mbps Full Duplex, Flow
> Control: Rx/Tx
> [   25.621770] ixgbe 0000:06:00.1 eth_s2_1: NIC Link is Up 10 Gbps, Flow
> Control: RX/TX
> [   25.838277] BUG: scheduling while atomic: kworker/u:2/109/0x00000002
> [   25.844673] 4 locks held by kworker/u:2/109:
> [   25.844676]  #0:  ((bond_dev->name)){......}, at:
> [<ffffffff8105da4d>] process_one_work+0x13d/0x5d0
> [   25.844689]  #1:  ((&(&bond->mii_work)->work)){......}, at:
> [<ffffffff8105da4d>] process_one_work+0x13d/0x5d0
> [   25.844705]  #2:  (rtnl_mutex){......}, at: [<ffffffff81590c00>]
> rtnl_trylock+0x10/0x20
> [   25.844715]  #3:  (&bond->lock){......}, at: [<ffffffff8145af55>]
> bond_mii_monitor+0x2d5/0x630
> [   25.844724] Modules linked in: iptable_filter kvm_intel kvm iTCO_wdt
> acpi_cpufreq mperf button mousedev processor
> [   25.844740] Pid: 109, comm: kworker/u:2 Tainted: G        W   
> 3.8.1-Isht-Van #6
> [   25.844743] Call Trace:
> [   25.844752]  [<ffffffff8162b039>] __schedule_bug+0x5e/0x6c
> [   25.844759]  [<ffffffff816345a2>] __schedule+0x762/0x7f0
> [   25.844764]  [<ffffffff81634744>] schedule+0x24/0x70
> [   25.844770]  [<ffffffff81633704>]
> schedule_hrtimeout_range_clock+0xa4/0x130
> [   25.844776]  [<ffffffff81068250>] ? update_rmtp+0x60/0x60
> [   25.844781]  [<ffffffff81068f9f>] ? hrtimer_start_range_ns+0xf/0x20
> [   25.844786]  [<ffffffff8163379e>] schedule_hrtimeout_range+0xe/0x10
> [   25.844791]  [<ffffffff8104ec1b>] usleep_range+0x3b/0x40
> [   25.844798]  [<ffffffff814b2d8c>] ixgbe_acquire_swfw_sync_X540+0xbc/0x100
> [   25.844805]  [<ffffffff814aeb1d>] ixgbe_read_phy_reg_generic+0x3d/0x140
> [   25.844811]  [<ffffffff814aedbc>]
> ixgbe_get_copper_link_capabilities_generic+0x2c/0x60
> [   25.844818]  [<ffffffff8145af55>] ? bond_mii_monitor+0x2d5/0x630
> [   25.844832]  [<ffffffff814a64f4>] ixgbe_get_settings+0x34/0x340
> [   25.844845]  [<ffffffff81586ac8>] __ethtool_get_settings+0x88/0x130
> [   25.844858]  [<ffffffff814568a3>] bond_update_speed_duplex+0x23/0x60
> [   25.844866]  [<ffffffff8145afc4>] bond_mii_monitor+0x344/0x630
> [   25.844871]  [<ffffffff8105dab1>] process_one_work+0x1a1/0x5d0
> [   25.844875]  [<ffffffff8105da4d>] ? process_one_work+0x13d/0x5d0
> [   25.844880]  [<ffffffff8145ac80>] ? bond_loadbalance_arp_mon+0x300/0x300
> [   25.844885]  [<ffffffff8105ed60>] worker_thread+0x160/0x3f0
> [   25.844890]  [<ffffffff8105ec00>] ? manage_workers+0x290/0x290
> [   25.844896]  [<ffffffff81064446>] kthread+0xd6/0xe0
> [   25.844901]  [<ffffffff8107004a>] ? finish_task_switch+0x3a/0x100
> [   25.844907]  [<ffffffff81064370>] ? flush_kthread_worker+0x160/0x160
> [   25.844911]  [<ffffffff81636fec>] ret_from_fork+0x7c/0xb0
> [   25.844916]  [<ffffffff81064370>] ? flush_kthread_worker+0x160/0x160
> [   25.848369] BUG: scheduling while atomic: kworker/u:2/109/0x00000002
> [   25.854761] 4 locks held by kworker/u:2/109:
> [   25.854764]  #0:  ((bond_dev->name)){......}, at:
> [<ffffffff8105da4d>] process_one_work+0x13d/0x5d0
> [   25.854774]  #1:  ((&(&bond->mii_work)->work)){......}, at:
> [<ffffffff8105da4d>] process_one_work+0x13d/0x5d0
> [   25.854781]  #2:  (rtnl_mutex){......}, at: [<ffffffff81590c00>]
> rtnl_trylock+0x10/0x20
> [   25.854790]  #3:  (&bond->lock){......}, at: [<ffffffff8145af55>]
> bond_mii_monitor+0x2d5/0x630
> [   25.854798] Modules linked in: iptable_filter kvm_intel kvm iTCO_wdt
> acpi_cpufreq mperf button mousedev processor
> [   25.854812] Pid: 109, comm: kworker/u:2 Tainted: G        W   
> 3.8.1-Isht-Van #6
> [   25.854814] Call Trace:
> [   25.854820]  [<ffffffff8162b039>] __schedule_bug+0x5e/0x6c
> [   25.854826]  [<ffffffff816345a2>] __schedule+0x762/0x7f0
> [   25.854831]  [<ffffffff81634744>] schedule+0x24/0x70
> [   25.854835]  [<ffffffff81633704>]
> schedule_hrtimeout_range_clock+0xa4/0x130
> [   25.854840]  [<ffffffff81068250>] ? update_rmtp+0x60/0x60
> [   25.854844]  [<ffffffff81068250>] ? update_rmtp+0x60/0x60
> [   25.854849]  [<ffffffff81068f9f>] ? hrtimer_start_range_ns+0xf/0x20
> [   25.854854]  [<ffffffff8163379e>] schedule_hrtimeout_range+0xe/0x10
> [   25.854858]  [<ffffffff8104ec1b>] usleep_range+0x3b/0x40
> [   25.854863]  [<ffffffff814b2cbe>] ixgbe_release_swfw_sync_X540+0x4e/0x60
> [   25.854869]  [<ffffffff814aebed>] ixgbe_read_phy_reg_generic+0x10d/0x140
> [   25.854874]  [<ffffffff814aedbc>]
> ixgbe_get_copper_link_capabilities_generic+0x2c/0x60
> [   25.854879]  [<ffffffff8145af55>] ? bond_mii_monitor+0x2d5/0x630
> [   25.854883]  [<ffffffff814a64f4>] ixgbe_get_settings+0x34/0x340
> [   25.854888]  [<ffffffff81586ac8>] __ethtool_get_settings+0x88/0x130
> [   25.854892]  [<ffffffff814568a3>] bond_update_speed_duplex+0x23/0x60
> [   25.854897]  [<ffffffff8145afc4>] bond_mii_monitor+0x344/0x630
> [   25.854901]  [<ffffffff8105dab1>] process_one_work+0x1a1/0x5d0
> [   25.854905]  [<ffffffff8105da4d>] ? process_one_work+0x13d/0x5d0
> [   25.854910]  [<ffffffff8145ac80>] ? bond_loadbalance_arp_mon+0x300/0x300
> [   25.854915]  [<ffffffff8105ed60>] worker_thread+0x160/0x3f0
> [   25.854920]  [<ffffffff8105ec00>] ? manage_workers+0x290/0x290
> [   25.854925]  [<ffffffff81064446>] kthread+0xd6/0xe0
> [   25.854929]  [<ffffffff8107004a>] ? finish_task_switch+0x3a/0x100
> [   25.854935]  [<ffffffff81064370>] ? flush_kthread_worker+0x160/0x160
> [   25.854939]  [<ffffffff81636fec>] ret_from_fork+0x7c/0xb0
> [   25.854944]  [<ffffffff81064370>] ? flush_kthread_worker+0x160/0x160
> [   25.858392] bonding: bond0: link status definitely up for interface
> eth_s2_1, 10000 Mbps full duplex.
> [   27.292402] bnx2 0000:01:00.1 eth3: NIC Copper Link is Up, 1000 Mbps
> full duplex
> [   27.292406] , receive & transmit flow control ON
> [   28.682172] e1000e: eth1 NIC Link is Up 1000 Mbps Full Duplex, Flow
> Control: Rx/Tx
> [   29.037441] Status code returned 0xc000005e NT_STATUS_NO_LOGON_SERVERS
> [   29.037451] CIFS VFS: Send error in SessSetup = -5
> [   29.043058] CIFS VFS: cifs_mount failed w/return code = -5
> [   30.005962] Status code returned 0xc000005e NT_STATUS_NO_LOGON_SERVERS
> [   30.005971] CIFS VFS: Send error in SessSetup = -5
> [   30.011333] CIFS VFS: cifs_mount failed w/return code = -5
> [   31.093294] Status code returned 0xc000000d NT_STATUS_INVALID_PARAMETER
> [   31.093303] CIFS VFS: Send error in SessSetup = -22
> [   31.098672] CIFS VFS: cifs_mount failed w/return code = -22
> [   32.339022] device eth0 entered promiscuous mode
> [   32.523684] device eth1 entered promiscuous mode
> [   32.739312] device eth2 entered promiscuous mode
> [   32.922051] device eth3 entered promiscuous mode
> [   33.075705] device bond0 entered promiscuous mode
> [   33.075711] device eth_s2_0 entered promiscuous mode
> [   33.076022] device eth_s2_1 entered promiscuous mode
> [   34.783087] u32 classifier
> [   34.783089]     Performance counters on
> [   34.783090]     input device check on
> [   34.783091]     Actions configured
> [   40.834154] bnx2 0000:01:00.0 eth2: NIC Copper Link is Up, 100 Mbps
> full duplex
> [   40.834158] , receive & transmit flow control ON
> 
> 
> 
