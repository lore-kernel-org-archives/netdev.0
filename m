From: Meelis Roos <mroos@linux.ee>
Subject: 4.9-rc7: (forcedeth?) BUG: sleeping function called from invalid
 context at kernel/irq/manage.c:110
Date: Tue, 29 Nov 2016 22:26:56 +0200 (EET)
Message-ID: <alpine.LRH.2.20.1611292222200.31348@math.ut.ee>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
To: Linux Kernel list <linux-kernel@vger.kernel.org>,
        netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is 4.9-rc7 on Sun Ultra 20 (Opteron 175 on NVidia chipset PC with 
NVidia ethernet).

BUG: sleeping function called from invalid context at kernel/irq/manage.c:110

appears twice during bootup - once during usb init when nvidia ethernet 
irq(?) comes in, and orher time during amd64_edac init when nv irq comes 
in.

This is the only kernel so far after 4.8.0 that I have tested so I do 
not know when exactly this started.

Full dmesg:

[    0.000000] Linux version 4.9.0-rc7-00007-g88abd82 (mroos@u20) (gcc version 6.2.1 20161124 (Debian 6.2.1-5) ) #12 SMP Tue Nov 29 16:40:15 EET 2016
[    0.000000] Command line: BOOT_IMAGE=/boot/vmlinuz-4.9.0-rc7-00007-g88abd82 root=/dev/sda1 ro netconsole=1980@192.168.78.12/eth0,1975@192.168.78.2/00:16:3e:67:55:38
[    0.000000] x86/fpu: Legacy x87 FPU detected.
[    0.000000] x86/fpu: Using 'eager' FPU context switches.
[    0.000000] e820: BIOS-provided physical RAM map:
[    0.000000] BIOS-e820: [mem 0x0000000000000000-0x00000000000977ff] usable
[    0.000000] BIOS-e820: [mem 0x0000000000097800-0x000000000009ffff] reserved
[    0.000000] BIOS-e820: [mem 0x00000000000f0000-0x00000000000fffff] reserved
[    0.000000] BIOS-e820: [mem 0x0000000000100000-0x00000000bfedffff] usable
[    0.000000] BIOS-e820: [mem 0x00000000bfee0000-0x00000000bfee2fff] ACPI NVS
[    0.000000] BIOS-e820: [mem 0x00000000bfee3000-0x00000000bfeeffff] ACPI data
[    0.000000] BIOS-e820: [mem 0x00000000bfef0000-0x00000000bfefffff] reserved
[    0.000000] BIOS-e820: [mem 0x00000000e0000000-0x00000000efffffff] reserved
[    0.000000] BIOS-e820: [mem 0x00000000fec00000-0x00000000ffffffff] reserved
[    0.000000] BIOS-e820: [mem 0x0000000100000000-0x000000013fffffff] usable
[    0.000000] NX (Execute Disable) protection: active
[    0.000000] SMBIOS 2.3 present.
[    0.000000] DMI: Sun Microsystems Sun Ultra 20 Workstation/2864, BIOS 2.3.0  05/15/2008
[    0.000000] e820: update [mem 0x00000000-0x00000fff] usable ==> reserved
[    0.000000] e820: remove [mem 0x000a0000-0x000fffff] usable
[    0.000000] AGP: No AGP bridge found
[    0.000000] e820: last_pfn = 0x140000 max_arch_pfn = 0x400000000
[    0.000000] MTRR default type: uncachable
[    0.000000] MTRR fixed ranges enabled:
[    0.000000]   00000-9FFFF write-back
[    0.000000]   A0000-BFFFF uncachable
[    0.000000]   C0000-C7FFF write-protect
[    0.000000]   C8000-FFFFF uncachable
[    0.000000] MTRR variable ranges enabled:
[    0.000000]   0 base 0000000000 mask FF80000000 write-back
[    0.000000]   1 base 0080000000 mask FFC0000000 write-back
[    0.000000]   2 base 00BFF00000 mask FFFFF00000 uncachable
[    0.000000]   3 base 0100000000 mask FFC0000000 write-back
[    0.000000]   4 disabled
[    0.000000]   5 disabled
[    0.000000]   6 disabled
[    0.000000]   7 disabled
[    0.000000] x86/PAT: Configuration [0-7]: WB  WC  UC- UC  WB  WC  UC- WT  
[    0.000000] total RAM covered: 4095M
[    0.000000] Found optimal setting for mtrr clean up
[    0.000000]  gran_size: 64K 	chunk_size: 2M 	num_reg: 4  	lose cover RAM: 0G
[    0.000000] e820: update [mem 0xbff00000-0xffffffff] usable ==> reserved
[    0.000000] e820: last_pfn = 0xbfee0 max_arch_pfn = 0x400000000
[    0.000000] found SMP MP-table at [mem 0x000f3a10-0x000f3a1f] mapped at [ffff8800000f3a10]
[    0.000000] Base memory trampoline at [ffff880000091000] 91000 size 24576
[    0.000000] BRK [0x0245a000, 0x0245afff] PGTABLE
[    0.000000] BRK [0x0245b000, 0x0245bfff] PGTABLE
[    0.000000] BRK [0x0245c000, 0x0245cfff] PGTABLE
[    0.000000] BRK [0x0245d000, 0x0245dfff] PGTABLE
[    0.000000] ACPI: Early table checksum verification disabled
[    0.000000] ACPI: RSDP 0x00000000000F7BC0 000014 (v00 SUNW  )
[    0.000000] ACPI: RSDT 0x00000000BFEE3040 000034 (v01 SUNW   AWRDACPI 42302E31 AWRD 00000000)
[    0.000000] ACPI: FACP 0x00000000BFEE30C0 000074 (v01 SUNW   AWRDACPI 42302E31 AWRD 00000000)
[    0.000000] ACPI: DSDT 0x00000000BFEE3180 00611A (v01 SUNW   AWRDACPI 00001000 MSFT 0100000E)
[    0.000000] ACPI: FACS 0x00000000BFEE0000 000040
[    0.000000] ACPI: SSDT 0x00000000BFEE93C0 0001CA (v01 PTLTD  POWERNOW 00000001  LTP 00000001)
[    0.000000] ACPI: SRAT 0x00000000BFEE9600 0000C8 (v01 AMD    HAMMER   00000001 AMD  00000001)
[    0.000000] ACPI: APIC 0x00000000BFEE9300 000072 (v01 SUNW   AWRDACPI 42302E31 AWRD 00000000)
[    0.000000] ACPI: Local APIC address 0xfee00000
[    0.000000] Zone ranges:
[    0.000000]   DMA      [mem 0x0000000000001000-0x0000000000ffffff]
[    0.000000]   DMA32    [mem 0x0000000001000000-0x00000000ffffffff]
[    0.000000]   Normal   [mem 0x0000000100000000-0x000000013fffffff]
[    0.000000] Movable zone start for each node
[    0.000000] Early memory node ranges
[    0.000000]   node   0: [mem 0x0000000000001000-0x0000000000096fff]
[    0.000000]   node   0: [mem 0x0000000000100000-0x00000000bfedffff]
[    0.000000]   node   0: [mem 0x0000000100000000-0x000000013fffffff]
[    0.000000] Initmem setup node 0 [mem 0x0000000000001000-0x000000013fffffff]
[    0.000000] On node 0 totalpages: 1048182
[    0.000000]   DMA zone: 64 pages used for memmap
[    0.000000]   DMA zone: 21 pages reserved
[    0.000000]   DMA zone: 3990 pages, LIFO batch:0
[    0.000000]   DMA32 zone: 12220 pages used for memmap
[    0.000000]   DMA32 zone: 782048 pages, LIFO batch:31
[    0.000000]   Normal zone: 4096 pages used for memmap
[    0.000000]   Normal zone: 262144 pages, LIFO batch:31
[    0.000000] Nvidia board detected. Ignoring ACPI timer override.
[    0.000000] If you got timer trouble try acpi_use_timer_override
[    0.000000] ACPI: PM-Timer IO Port: 0x1008
[    0.000000] ACPI: Local APIC address 0xfee00000
[    0.000000] ACPI: LAPIC_NMI (acpi_id[0x00] high edge lint[0x1])
[    0.000000] ACPI: LAPIC_NMI (acpi_id[0x01] high edge lint[0x1])
[    0.000000] IOAPIC[0]: apic_id 2, version 17, address 0xfec00000, GSI 0-23
[    0.000000] ACPI: INT_SRC_OVR (bus 0 bus_irq 9 global_irq 9 high level)
[    0.000000] ACPI: INT_SRC_OVR (bus 0 bus_irq 14 global_irq 14 high edge)
[    0.000000] ACPI: INT_SRC_OVR (bus 0 bus_irq 15 global_irq 15 high edge)
[    0.000000] ACPI: IRQ9 used by override.
[    0.000000] ACPI: IRQ14 used by override.
[    0.000000] ACPI: IRQ15 used by override.
[    0.000000] Using ACPI (MADT) for SMP configuration information
[    0.000000] smpboot: Allowing 2 CPUs, 0 hotplug CPUs
[    0.000000] PM: Registered nosave memory: [mem 0x00000000-0x00000fff]
[    0.000000] PM: Registered nosave memory: [mem 0x00097000-0x00097fff]
[    0.000000] PM: Registered nosave memory: [mem 0x00098000-0x0009ffff]
[    0.000000] PM: Registered nosave memory: [mem 0x000a0000-0x000effff]
[    0.000000] PM: Registered nosave memory: [mem 0x000f0000-0x000fffff]
[    0.000000] PM: Registered nosave memory: [mem 0xbfee0000-0xbfee2fff]
[    0.000000] PM: Registered nosave memory: [mem 0xbfee3000-0xbfeeffff]
[    0.000000] PM: Registered nosave memory: [mem 0xbfef0000-0xbfefffff]
[    0.000000] PM: Registered nosave memory: [mem 0xbff00000-0xdfffffff]
[    0.000000] PM: Registered nosave memory: [mem 0xe0000000-0xefffffff]
[    0.000000] PM: Registered nosave memory: [mem 0xf0000000-0xfebfffff]
[    0.000000] PM: Registered nosave memory: [mem 0xfec00000-0xffffffff]
[    0.000000] e820: [mem 0xbff00000-0xdfffffff] available for PCI devices
[    0.000000] clocksource: refined-jiffies: mask: 0xffffffff max_cycles: 0xffffffff, max_idle_ns: 7645519600211568 ns
[    0.000000] setup_percpu: NR_CPUS:4 nr_cpumask_bits:4 nr_cpu_ids:2 nr_node_ids:1
[    0.000000] percpu: Embedded 33 pages/cpu @ffff88013fc00000 s95960 r8192 d31016 u1048576
[    0.000000] pcpu-alloc: s95960 r8192 d31016 u1048576 alloc=1*2097152
[    0.000000] pcpu-alloc: [0] 0 1 
[    0.000000] Built 1 zonelists in Zone order, mobility grouping on.  Total pages: 1031781
[    0.000000] Kernel command line: BOOT_IMAGE=/boot/vmlinuz-4.9.0-rc7-00007-g88abd82 root=/dev/sda1 ro netconsole=1980@192.168.78.12/eth0,1975@192.168.78.2/00:16:3e:67:55:38
[    0.000000] PID hash table entries: 4096 (order: 3, 32768 bytes)
[    0.000000] Dentry cache hash table entries: 524288 (order: 10, 4194304 bytes)
[    0.000000] Inode-cache hash table entries: 262144 (order: 9, 2097152 bytes)
[    0.000000] AGP: Checking aperture...
[    0.000000] AGP: No AGP bridge found
[    0.000000] AGP: Node 0: aperture [bus addr 0xc0000000-0xcfffffff] (256MB)
[    0.000000] Memory: 4033820K/4192728K available (8679K kernel code, 7159K rwdata, 1288K rodata, 936K init, 424K bss, 158908K reserved, 0K cma-reserved)
[    0.000000] SLUB: HWalign=64, Order=0-3, MinObjects=0, CPUs=2, Nodes=1
[    0.000000] Hierarchical RCU implementation.
[    0.000000] 	Build-time adjustment of leaf fanout to 64.
[    0.000000] 	RCU restricting CPUs from NR_CPUS=4 to nr_cpu_ids=2.
[    0.000000] RCU: Adjusting geometry for rcu_fanout_leaf=64, nr_cpu_ids=2
[    0.000000] NR_IRQS:4352 nr_irqs:440 16
[    0.000000] spurious 8259A interrupt: IRQ7.
[    0.000000] Console: colour dummy device 80x25
[    0.000000] console [tty0] enabled
[    0.000000] tsc: Fast TSC calibration using PIT
[    0.000000] tsc: Detected 1005.253 MHz processor
[    0.000000] tsc: Marking TSC unstable due to TSCs unsynchronized
[    0.004023] Calibrating delay loop (skipped), value calculated using timer frequency.. 2010.50 BogoMIPS (lpj=4021012)
[    0.004055] pid_max: default: 32768 minimum: 301
[    0.004080] ACPI: Core revision 20160831
[    0.016209] ACPI: 2 ACPI AML tables successfully acquired and loaded
[    0.016291] Mount-cache hash table entries: 8192 (order: 4, 65536 bytes)
[    0.016312] Mountpoint-cache hash table entries: 8192 (order: 4, 65536 bytes)
[    0.016849] CPU: Physical Processor ID: 0
[    0.016867] CPU: Processor Core ID: 0
[    0.016883] mce: CPU supports 5 MCE banks
[    0.016915] Last level iTLB entries: 4KB 512, 2MB 8, 4MB 4
[    0.016932] Last level dTLB entries: 4KB 512, 2MB 8, 4MB 4, 1GB 0
[    0.017458] Freeing SMP alternatives memory: 20K (ffffffff823e9000 - ffffffff823ee000)
[    0.020183] smpboot: APIC(0) Converting physical 0 to logical package 0
[    0.020211] smpboot: Max logical packages: 1
[    0.020662] ..TIMER: vector=0x30 apic1=0 pin1=0 apic2=-1 pin2=-1
[    0.064000] smpboot: CPU0: Dual Core AMD Opteron(tm) Processor 175 (family: 0xf, model: 0x23, stepping: 0x2)
[    0.064000] Performance Events: AMD PMU driver.
[    0.064000] ... version:                0
[    0.064000] ... bit width:              48
[    0.064000] ... generic registers:      4
[    0.064000] ... value mask:             0000ffffffffffff
[    0.064000] ... max period:             00007fffffffffff
[    0.064000] ... fixed-purpose events:   0
[    0.064000] ... event mask:             000000000000000f
[    0.064000] NMI watchdog: enabled on all CPUs, permanently consumes one hw-PMU counter.
[    0.064000] x86: Booting SMP configuration:
[    0.064000] .... node  #0, CPUs:      #1
[    0.140070] x86: Booted up 1 node, 2 CPUs
[    0.140070] smpboot: Total of 2 processors activated (4020.94 BogoMIPS)
[    0.141442] devtmpfs: initialized
[    0.141442] PM: Registering ACPI NVS region [mem 0xbfee0000-0xbfee2fff] (12288 bytes)
[    0.141442] clocksource: jiffies: mask: 0xffffffff max_cycles: 0xffffffff, max_idle_ns: 7645041785100000 ns
[    0.141442] NET: Registered protocol family 16
[    0.152011] cpuidle: using governor ladder
[    0.164009] cpuidle: using governor menu
[    0.164033] node 0 link 0: io port [5000, ffff]
[    0.164038] TOM: 00000000c0000000 aka 3072M
[    0.164056] node 0 link 0: mmio [a0000, bffff]
[    0.164061] node 0 link 0: mmio [feb00000, fec0ffff]
[    0.164065] node 0 link 0: mmio [c0000000, dfffffff]
[    0.164070] node 0 link 0: mmio [f0000000, fe02ffff]
[    0.164074] node 0 link 0: mmio [e0000000, e05fffff]
[    0.164077] TOM2: 0000000140000000 aka 5120M
[    0.164097] bus: [bus 00-05] on node 0 link 0
[    0.164099] bus: 00 [io  0x0000-0xffff]
[    0.164102] bus: 00 [mem 0x000a0000-0x000bffff]
[    0.164104] bus: 00 [mem 0xfe030000-0xffffffff]
[    0.164106] bus: 00 [mem 0xc0000000-0xefffffff]
[    0.164109] bus: 00 [mem 0xf0000000-0xfe02ffff]
[    0.164111] bus: 00 [mem 0x140000000-0xfcffffffff]
[    0.164170] ACPI: bus type PCI registered
[    0.164287] PCI: Using configuration type 1 for base access
[    0.180075] HugeTLB registered 2 MB page size, pre-allocated 0 pages
[    0.180123] ACPI: Added _OSI(Module Device)
[    0.180123] ACPI: Added _OSI(Processor Device)
[    0.180123] ACPI: Added _OSI(3.0 _SCP Extensions)
[    0.180135] ACPI: Added _OSI(Processor Aggregator Device)
[    0.187426] ================================================================================
[    0.187458] UBSAN: Undefined behaviour in drivers/acpi/acpica/dsutils.c:640:16
[    0.187487] index -1 is out of range for type 'acpi_operand_object *[9]'
[    0.187508] CPU: 1 PID: 1 Comm: swapper/0 Not tainted 4.9.0-rc7-00007-g88abd82 #12
[    0.187536] Hardware name: Sun Microsystems Sun Ultra 20 Workstation/2864, BIOS 2.3.0  05/15/2008
[    0.187566]  0000000000000000 ffffffff814517a2 000000000000003c ffffc9000000baf0
[    0.187600]  ffffffffffffffff ffffffff81499229 ffffffff8202db00 ffffffff8149989b
[    0.187632]  0000000000000202 000000000000312d ffffffff81a3c718 ffff88013b018200
[    0.187663] Call Trace:
[    0.187696]  [<ffffffff814517a2>] ? dump_stack+0x47/0x65
[    0.187716]  [<ffffffff81499229>] ? ubsan_epilogue+0x9/0x40
[    0.187735]  [<ffffffff8149989b>] ? __ubsan_handle_out_of_bounds+0x6b/0x80
[    0.187757]  [<ffffffff8150b34d>] ? acpi_ds_create_operand+0x20a/0x2a9
[    0.187778]  [<ffffffff8152c702>] ? acpi_ut_update_ref_count+0x4d/0x325
[    0.187798]  [<ffffffff8150b53b>] ? acpi_ds_create_operands+0x14f/0x1a2
[    0.187820]  [<ffffffff81230377>] ? kmem_cache_free+0x167/0x4c0
[    0.187840]  [<ffffffff8150bbda>] ? acpi_ds_exec_end_op+0x107/0x557
[    0.187862]  [<ffffffff81523fea>] ? acpi_ps_parse_loop+0x709/0x76d
[    0.187880]  [<ffffffff81524ffe>] ? acpi_ps_parse_aml+0x9f/0x2d9
[    0.187899]  [<ffffffff81525b5a>] ? acpi_ps_execute_method+0x1e7/0x21e
[    0.187919]  [<ffffffff8151ddbf>] ? acpi_ns_evaluate+0x223/0x2a7
[    0.187939]  [<ffffffff8151e1f3>] ? acpi_ns_init_one_device+0xe1/0x119
[    0.187959]  [<ffffffff81521a04>] ? acpi_ns_walk_namespace+0x109/0x1ec
[    0.187979]  [<ffffffff8151e112>] ? acpi_ns_init_one_object+0x12d/0x12d
[    0.187999]  [<ffffffff8151e4b7>] ? acpi_ns_initialize_devices+0x198/0x1f6
[    0.188000]  [<ffffffff82349705>] ? acpi_sleep_proc_init+0x22/0x22
[    0.188000]  [<ffffffff8234b4e4>] ? acpi_initialize_objects+0x38/0x4a
[    0.188000]  [<ffffffff823497b6>] ? acpi_init+0xb1/0x30e
[    0.188000]  [<ffffffff815b7c86>] ? __class_create+0x56/0x90
[    0.188000]  [<ffffffff82347e77>] ? video_setup+0x120/0x120
[    0.188000]  [<ffffffff82347eed>] ? fbmem_init+0x76/0xca
[    0.188000]  [<ffffffff81000443>] ? do_one_initcall+0x53/0x1d0
[    0.188000]  [<ffffffff823183ef>] ? kernel_init_freeable+0x240/0x2cd
[    0.188000]  [<ffffffff8186bcf0>] ? rest_init+0x80/0x80
[    0.188000]  [<ffffffff8186bcf6>] ? kernel_init+0x6/0x110
[    0.188000]  [<ffffffff8186bcf0>] ? rest_init+0x80/0x80
[    0.188000]  [<ffffffff818765f2>] ? ret_from_fork+0x22/0x30
[    0.188000] ================================================================================
[    0.191481] ACPI: Interpreter enabled
[    0.191555] ACPI: (supports S0 S1 S3 S4 S5)
[    0.191571] ACPI: Using IOAPIC for interrupt routing
[    0.191651] PCI: Using host bridge windows from ACPI; if necessary, use "pci=nocrs" and report a bug
[    0.209829] ACPI: PCI Root Bridge [PCI0] (domain 0000 [bus 00-05])
[    0.209860] acpi PNP0A08:00: _OSC: OS supports [ASPM ClockPM Segments MSI]
[    0.209889] acpi PNP0A08:00: _OSC failed (AE_NOT_FOUND); disabling ASPM
[    0.209911] acpi PNP0A08:00: fail to add MMCONFIG information, can't access extended PCI configuration space under this bridge.
[    0.211770] PCI host bridge to bus 0000:00
[    0.211793] pci_bus 0000:00: root bus resource [io  0x0000-0x03af window]
[    0.211812] pci_bus 0000:00: root bus resource [io  0x03e0-0x0cf7 window]
[    0.211831] pci_bus 0000:00: root bus resource [io  0x5000-0xffff window]
[    0.211850] pci_bus 0000:00: root bus resource [io  0x03b0-0x03df window]
[    0.211870] pci_bus 0000:00: root bus resource [mem 0x000a0000-0x000bffff window]
[    0.211899] pci_bus 0000:00: root bus resource [mem 0xc0000000-0xdfffffff window]
[    0.211929] pci_bus 0000:00: root bus resource [mem 0xf0000000-0xfe02ffff window]
[    0.211958] pci_bus 0000:00: root bus resource [mem 0xfeb00000-0xfebfffff window]
[    0.211988] pci_bus 0000:00: root bus resource [bus 00-05]
[    0.212026] pci 0000:00:00.0: [10de:005e] type 00 class 0x058000
[    0.212425] pci 0000:00:01.0: [10de:0050] type 00 class 0x060100
[    0.212469] HPET not enabled in BIOS. You might try hpet=force boot option
[    0.212810] pci 0000:00:01.1: [10de:0052] type 00 class 0x0c0500
[    0.212825] pci 0000:00:01.1: reg 0x10: [io  0xfc00-0xfc1f]
[    0.212846] pci 0000:00:01.1: reg 0x20: [io  0x1c00-0x1c3f]
[    0.212855] pci 0000:00:01.1: reg 0x24: [io  0x1c40-0x1c7f]
[    0.212889] pci 0000:00:01.1: PME# supported from D3hot D3cold
[    0.213232] pci 0000:00:02.0: [10de:005a] type 00 class 0x0c0310
[    0.213246] pci 0000:00:02.0: reg 0x10: [mem 0xfe02f000-0xfe02ffff]
[    0.213299] pci 0000:00:02.0: supports D1 D2
[    0.213303] pci 0000:00:02.0: PME# supported from D0 D1 D2 D3hot D3cold
[    0.213550] pci 0000:00:02.0: System wakeup disabled by ACPI
[    0.213676] pci 0000:00:02.1: [10de:005b] type 00 class 0x0c0320
[    0.213691] pci 0000:00:02.1: reg 0x10: [mem 0xfeb00000-0xfeb000ff]
[    0.213750] pci 0000:00:02.1: supports D1 D2
[    0.213753] pci 0000:00:02.1: PME# supported from D0 D1 D2 D3hot D3cold
[    0.214029] pci 0000:00:02.1: System wakeup disabled by ACPI
[    0.214160] pci 0000:00:04.0: [10de:0059] type 00 class 0x040100
[    0.214174] pci 0000:00:04.0: reg 0x10: [io  0xf000-0xf0ff]
[    0.214182] pci 0000:00:04.0: reg 0x14: [io  0xec00-0xecff]
[    0.214191] pci 0000:00:04.0: reg 0x18: [mem 0xfe02d000-0xfe02dfff]
[    0.214236] pci 0000:00:04.0: supports D1 D2
[    0.214555] pci 0000:00:06.0: [10de:0053] type 00 class 0x01018a
[    0.214585] pci 0000:00:06.0: reg 0x20: [io  0xe800-0xe80f]
[    0.214599] pci 0000:00:06.0: legacy IDE quirk: reg 0x10: [io  0x01f0-0x01f7]
[    0.214620] pci 0000:00:06.0: legacy IDE quirk: reg 0x14: [io  0x03f6]
[    0.214639] pci 0000:00:06.0: legacy IDE quirk: reg 0x18: [io  0x0170-0x0177]
[    0.214658] pci 0000:00:06.0: legacy IDE quirk: reg 0x1c: [io  0x0376]
[    0.215014] pci 0000:00:07.0: [10de:0054] type 00 class 0x010185
[    0.215028] pci 0000:00:07.0: reg 0x10: [io  0x09f0-0x09f7]
[    0.215036] pci 0000:00:07.0: reg 0x14: [io  0x0bf0-0x0bf3]
[    0.215044] pci 0000:00:07.0: reg 0x18: [io  0x0970-0x0977]
[    0.215052] pci 0000:00:07.0: reg 0x1c: [io  0x0b70-0x0b73]
[    0.215060] pci 0000:00:07.0: reg 0x20: [io  0xd400-0xd40f]
[    0.215069] pci 0000:00:07.0: reg 0x24: [mem 0xfe02c000-0xfe02cfff]
[    0.215415] pci 0000:00:08.0: [10de:0055] type 00 class 0x010185
[    0.215429] pci 0000:00:08.0: reg 0x10: [io  0x09e0-0x09e7]
[    0.215437] pci 0000:00:08.0: reg 0x14: [io  0x0be0-0x0be3]
[    0.215445] pci 0000:00:08.0: reg 0x18: [io  0x0960-0x0967]
[    0.215453] pci 0000:00:08.0: reg 0x1c: [io  0x0b60-0x0b63]
[    0.215461] pci 0000:00:08.0: reg 0x20: [io  0xc000-0xc00f]
[    0.215470] pci 0000:00:08.0: reg 0x24: [mem 0xfe02b000-0xfe02bfff]
[    0.215814] pci 0000:00:09.0: [10de:005c] type 01 class 0x060401
[    0.216099] pci 0000:00:09.0: System wakeup disabled by ACPI
[    0.216224] pci 0000:00:0a.0: [10de:0057] type 00 class 0x068000
[    0.216238] pci 0000:00:0a.0: reg 0x10: [mem 0xfe02a000-0xfe02afff]
[    0.216246] pci 0000:00:0a.0: reg 0x14: [io  0xbc00-0xbc07]
[    0.216296] pci 0000:00:0a.0: supports D1 D2
[    0.216300] pci 0000:00:0a.0: PME# supported from D0 D1 D2 D3hot D3cold
[    0.216543] pci 0000:00:0a.0: System wakeup disabled by ACPI
[    0.216670] pci 0000:00:0b.0: [10de:005d] type 01 class 0x060400
[    0.216725] pci 0000:00:0b.0: PME# supported from D0 D1 D2 D3hot D3cold
[    0.216969] pci 0000:00:0b.0: System wakeup disabled by ACPI
[    0.217099] pci 0000:00:0c.0: [10de:005d] type 01 class 0x060400
[    0.217152] pci 0000:00:0c.0: PME# supported from D0 D1 D2 D3hot D3cold
[    0.217396] pci 0000:00:0c.0: System wakeup disabled by ACPI
[    0.217523] pci 0000:00:0d.0: [10de:005d] type 01 class 0x060400
[    0.217576] pci 0000:00:0d.0: PME# supported from D0 D1 D2 D3hot D3cold
[    0.217825] pci 0000:00:0d.0: System wakeup disabled by ACPI
[    0.217951] pci 0000:00:0e.0: [10de:005d] type 01 class 0x060400
[    0.218003] pci 0000:00:0e.0: PME# supported from D0 D1 D2 D3hot D3cold
[    0.218247] pci 0000:00:0e.0: System wakeup disabled by ACPI
[    0.218381] pci 0000:00:18.0: [1022:1100] type 00 class 0x060000
[    0.218733] pci 0000:00:18.1: [1022:1101] type 00 class 0x060000
[    0.219079] pci 0000:00:18.2: [1022:1102] type 00 class 0x060000
[    0.219423] pci 0000:00:18.3: [1022:1103] type 00 class 0x060000
[    0.219829] pci 0000:01:06.0: [1106:3044] type 00 class 0x0c0010
[    0.219847] pci 0000:01:06.0: reg 0x10: [mem 0xfcffe000-0xfcffe7ff]
[    0.219858] pci 0000:01:06.0: reg 0x14: [io  0xa800-0xa87f]
[    0.219928] pci 0000:01:06.0: supports D2
[    0.219932] pci 0000:01:06.0: PME# supported from D2 D3hot D3cold
[    0.220055] pci 0000:01:07.0: [104b:8130] type 00 class 0x010000
[    0.220070] pci 0000:01:07.0: reg 0x10: [io  0xa400-0xa4ff]
[    0.220081] pci 0000:01:07.0: reg 0x14: [mem 0xfcffd000-0xfcffdfff]
[    0.220117] pci 0000:01:07.0: reg 0x30: [mem 0x00000000-0x00007fff pref]
[    0.220230] pci 0000:01:09.0: [1101:9400] type 00 class 0x010000
[    0.220245] pci 0000:01:09.0: reg 0x10: [io  0xa000-0xa0ff]
[    0.220256] pci 0000:01:09.0: reg 0x14: [mem 0xfcffc000-0xfcffcfff]
[    0.220291] pci 0000:01:09.0: reg 0x30: [mem 0x00000000-0x00007fff pref]
[    0.220402] pci 0000:01:0a.0: [1407:8000] type 00 class 0x070101
[    0.220417] pci 0000:01:0a.0: reg 0x10: [io  0x9c00-0x9c07]
[    0.220580] pci 0000:00:09.0: PCI bridge to [bus 01] (subtractive decode)
[    0.220602] pci 0000:00:09.0:   bridge window [io  0x9000-0xafff]
[    0.220608] pci 0000:00:09.0:   bridge window [mem 0xfb000000-0xfcffffff]
[    0.220613] pci 0000:00:09.0:   bridge window [mem 0xfdf00000-0xfdffffff pref]
[    0.220618] pci 0000:00:09.0:   bridge window [io  0x0000-0x03af window] (subtractive decode)
[    0.220622] pci 0000:00:09.0:   bridge window [io  0x03e0-0x0cf7 window] (subtractive decode)
[    0.220626] pci 0000:00:09.0:   bridge window [io  0x5000-0xffff window] (subtractive decode)
[    0.220631] pci 0000:00:09.0:   bridge window [io  0x03b0-0x03df window] (subtractive decode)
[    0.220635] pci 0000:00:09.0:   bridge window [mem 0x000a0000-0x000bffff window] (subtractive decode)
[    0.220640] pci 0000:00:09.0:   bridge window [mem 0xc0000000-0xdfffffff window] (subtractive decode)
[    0.220644] pci 0000:00:09.0:   bridge window [mem 0xf0000000-0xfe02ffff window] (subtractive decode)
[    0.220648] pci 0000:00:09.0:   bridge window [mem 0xfeb00000-0xfebfffff window] (subtractive decode)
[    0.220719] pci 0000:00:0b.0: PCI bridge to [bus 02]
[    0.220741] pci 0000:00:0b.0:   bridge window [io  0x8000-0x8fff]
[    0.220746] pci 0000:00:0b.0:   bridge window [mem 0xfde00000-0xfdefffff]
[    0.220753] pci 0000:00:0b.0:   bridge window [mem 0xfdd00000-0xfddfffff 64bit pref]
[    0.220818] pci 0000:00:0c.0: PCI bridge to [bus 03]
[    0.220839] pci 0000:00:0c.0:   bridge window [io  0x7000-0x7fff]
[    0.220844] pci 0000:00:0c.0:   bridge window [mem 0xfdc00000-0xfdcfffff]
[    0.220850] pci 0000:00:0c.0:   bridge window [mem 0xfdb00000-0xfdbfffff 64bit pref]
[    0.220918] pci 0000:00:0d.0: PCI bridge to [bus 04]
[    0.220939] pci 0000:00:0d.0:   bridge window [io  0x6000-0x6fff]
[    0.220944] pci 0000:00:0d.0:   bridge window [mem 0xfda00000-0xfdafffff]
[    0.220951] pci 0000:00:0d.0:   bridge window [mem 0xfd900000-0xfd9fffff 64bit pref]
[    0.221027] pci 0000:05:00.0: [10de:01d3] type 00 class 0x030000
[    0.221040] pci 0000:05:00.0: reg 0x10: [mem 0xf8000000-0xf8ffffff]
[    0.221053] pci 0000:05:00.0: reg 0x14: [mem 0xd0000000-0xdfffffff 64bit pref]
[    0.221067] pci 0000:05:00.0: reg 0x1c: [mem 0xf9000000-0xf9ffffff 64bit]
[    0.221082] pci 0000:05:00.0: reg 0x30: [mem 0x00000000-0x0001ffff pref]
[    0.221212] pci 0000:05:00.0: disabling ASPM on pre-1.1 PCIe device.  You can enable it with 'pcie_aspm=force'
[    0.221251] pci 0000:00:0e.0: PCI bridge to [bus 05]
[    0.221271] pci 0000:00:0e.0:   bridge window [io  0x5000-0x5fff]
[    0.221276] pci 0000:00:0e.0:   bridge window [mem 0xf8000000-0xfaffffff]
[    0.221282] pci 0000:00:0e.0:   bridge window [mem 0xd0000000-0xdfffffff 64bit pref]
[    0.221302] pci_bus 0000:00: on NUMA node 0
[    0.221641] ACPI: PCI Interrupt Link [LNK1] (IRQs 3 5 7 9 10 *11 12 14 15)
[    0.221818] ACPI: PCI Interrupt Link [LNK2] (IRQs 3 *5 7 9 10 11 12 14 15)
[    0.221992] ACPI: PCI Interrupt Link [LNK3] (IRQs 3 5 7 9 *10 11 12 14 15)
[    0.222165] ACPI: PCI Interrupt Link [LNK4] (IRQs *3 5 7 9 10 11 12 14 15)
[    0.222337] ACPI: PCI Interrupt Link [LNK5] (IRQs 3 5 7 9 10 11 12 14 15) *0, disabled.
[    0.222523] ACPI: PCI Interrupt Link [LUBA] (IRQs *3 5 7 9 10 11 12 14 15)
[    0.222703] ACPI: PCI Interrupt Link [LUBB] (IRQs 3 5 7 9 10 11 12 14 15) *0, disabled.
[    0.222889] ACPI: PCI Interrupt Link [LMAC] (IRQs 3 5 7 9 *10 11 12 14 15)
[    0.223068] ACPI: PCI Interrupt Link [LACI] (IRQs 3 5 7 9 10 *11 12 14 15)
[    0.223244] ACPI: PCI Interrupt Link [LMCI] (IRQs 3 5 7 9 10 11 12 14 15) *0, disabled.
[    0.223430] ACPI: PCI Interrupt Link [LSMB] (IRQs 3 5 7 9 10 *11 12 14 15)
[    0.223609] ACPI: PCI Interrupt Link [LUB2] (IRQs 3 5 *7 9 10 11 12 14 15)
[    0.223781] ACPI: PCI Interrupt Link [LIDE] (IRQs 3 5 7 9 10 11 12 14 15) *0, disabled.
[    0.223980] ACPI: PCI Interrupt Link [LSID] (IRQs 3 *5 7 9 10 11 12 14 15)
[    0.224172] ACPI: PCI Interrupt Link [LFID] (IRQs 3 5 *7 9 10 11 12 14 15)
[    0.224357] ACPI: PCI Interrupt Link [LPCA] (IRQs 3 5 7 9 10 11 12 14 15) *0, disabled.
[    0.224595] ACPI: PCI Interrupt Link [APC1] (IRQs 16) *0, disabled.
[    0.224813] ACPI: PCI Interrupt Link [APC2] (IRQs 17) *0, disabled.
[    0.225030] ACPI: PCI Interrupt Link [APC3] (IRQs 18) *0, disabled.
[    0.225247] ACPI: PCI Interrupt Link [APC4] (IRQs 19) *0, disabled.
[    0.225391] ACPI: PCI Interrupt Link [APC5] (IRQs *16), disabled.
[    0.225619] ACPI: PCI Interrupt Link [APCF] (IRQs 20 21 22 23) *0, disabled.
[    0.225852] ACPI: PCI Interrupt Link [APCG] (IRQs 20 21 22 23) *0, disabled.
[    0.226084] ACPI: PCI Interrupt Link [APCH] (IRQs 20 21 22 23) *0, disabled.
[    0.226316] ACPI: PCI Interrupt Link [APCJ] (IRQs 20 21 22 23) *0, disabled.
[    0.226548] ACPI: PCI Interrupt Link [APCK] (IRQs 20 21 22 23) *0, disabled.
[    0.226779] ACPI: PCI Interrupt Link [APCS] (IRQs 20 21 22 23) *0, disabled.
[    0.227011] ACPI: PCI Interrupt Link [APCL] (IRQs 20 21 22 23) *0, disabled.
[    0.227243] ACPI: PCI Interrupt Link [APCZ] (IRQs 20 21 22 23) *0, disabled.
[    0.227488] ACPI: PCI Interrupt Link [APSI] (IRQs 20 21 22 23) *0, disabled.
[    0.227733] ACPI: PCI Interrupt Link [APSJ] (IRQs 20 21 22 23) *0, disabled.
[    0.227977] ACPI: PCI Interrupt Link [APCP] (IRQs 20 21 22 23) *0, disabled.
[    0.229491] vgaarb: setting as boot device: PCI:0000:05:00.0
[    0.229491] vgaarb: device added: PCI:0000:05:00.0,decodes=io+mem,owns=io+mem,locks=none
[    0.229491] vgaarb: loaded
[    0.229491] vgaarb: bridge control possible 0000:05:00.0
[    0.229491] SCSI subsystem initialized
[    0.229491] libata version 3.00 loaded.
[    0.229491] PCI: Using ACPI for IRQ routing
[    0.229491] PCI: pci_cache_line_size set to 64 bytes
[    0.229491] pci 0000:00:01.1: can't claim BAR 4 [io  0x1c00-0x1c3f]: no compatible bridge window
[    0.229491] pci 0000:00:01.1: can't claim BAR 5 [io  0x1c40-0x1c7f]: no compatible bridge window
[    0.229491] e820: reserve RAM buffer [mem 0x00097800-0x0009ffff]
[    0.229491] e820: reserve RAM buffer [mem 0xbfee0000-0xbfffffff]
[    0.229491] clocksource: Switched to clocksource refined-jiffies
[    0.229491] pnp: PnP ACPI init
[    0.229491] system 00:00: [io  0x1000-0x107f] has been reserved
[    0.229491] system 00:00: [io  0x1080-0x10ff] has been reserved
[    0.229491] system 00:00: [io  0x1400-0x147f] has been reserved
[    0.229491] system 00:00: [io  0x1480-0x14ff] has been reserved
[    0.229491] system 00:00: [io  0x1800-0x187f] has been reserved
[    0.229491] system 00:00: [io  0x1880-0x18ff] has been reserved
[    0.229491] system 00:00: Plug and Play ACPI device, IDs PNP0c02 (active)
[    0.233073] system 00:01: [io  0x04d0-0x04d1] has been reserved
[    0.233095] system 00:01: [io  0x0800-0x087f] has been reserved
[    0.233114] system 00:01: [io  0x0ca0-0x0caf] has been reserved
[    0.233133] system 00:01: [io  0x0800-0x087f] has been reserved
[    0.233155] system 00:01: Plug and Play ACPI device, IDs PNP0c02 (active)
[    0.233241] pnp 00:02: Plug and Play ACPI device, IDs PNP0b00 (active)
[    0.234182] system 00:03: [mem 0xe0000000-0xefffffff] has been reserved
[    0.234206] system 00:03: Plug and Play ACPI device, IDs PNP0c02 (active)
[    0.234654] system 00:04: [mem 0x000da000-0x000dbfff] has been reserved
[    0.234677] system 00:04: [mem 0x000f0000-0x000f7fff] could not be reserved
[    0.234697] system 00:04: [mem 0x000f8000-0x000fbfff] could not be reserved
[    0.234717] system 00:04: [mem 0x000fc000-0x000fffff] could not be reserved
[    0.234736] system 00:04: [mem 0xbfee0000-0xbfefffff] could not be reserved
[    0.234756] system 00:04: [mem 0xffff0000-0xffffffff] has been reserved
[    0.234776] system 00:04: [mem 0x00000000-0x0009ffff] could not be reserved
[    0.234796] system 00:04: [mem 0x00100000-0xbfedffff] could not be reserved
[    0.234816] system 00:04: [mem 0xfec00000-0xfec00fff] could not be reserved
[    0.234836] system 00:04: [mem 0xfee00000-0xfeefffff] has been reserved
[    0.234855] system 00:04: [mem 0xfefff000-0xfeffffff] has been reserved
[    0.234875] system 00:04: [mem 0xfff80000-0xfff80fff] has been reserved
[    0.234894] system 00:04: [mem 0xfff90000-0xfffbffff] has been reserved
[    0.234914] system 00:04: [mem 0xfffed000-0xfffeffff] has been reserved
[    0.234936] system 00:04: Plug and Play ACPI device, IDs PNP0c01 (active)
[    0.234959] pnp: PnP ACPI: found 5 devices
[    0.244022] clocksource: acpi_pm: mask: 0xffffff max_cycles: 0xffffff, max_idle_ns: 2085701024 ns
[    0.244087] clocksource: Switched to clocksource acpi_pm
[    0.244151] pci 0000:00:01.1: BAR 4: assigned [io  0x0400-0x043f]
[    0.244175] pci 0000:00:01.1: BAR 5: assigned [io  0x0440-0x047f]
[    0.244203] pci 0000:01:07.0: BAR 6: assigned [mem 0xfdf00000-0xfdf07fff pref]
[    0.244234] pci 0000:01:09.0: BAR 6: assigned [mem 0xfdf08000-0xfdf0ffff pref]
[    0.244266] pci 0000:00:09.0: PCI bridge to [bus 01]
[    0.244285] pci 0000:00:09.0:   bridge window [io  0x9000-0xafff]
[    0.244305] pci 0000:00:09.0:   bridge window [mem 0xfb000000-0xfcffffff]
[    0.244326] pci 0000:00:09.0:   bridge window [mem 0xfdf00000-0xfdffffff pref]
[    0.244357] pci 0000:00:0b.0: PCI bridge to [bus 02]
[    0.244376] pci 0000:00:0b.0:   bridge window [io  0x8000-0x8fff]
[    0.244396] pci 0000:00:0b.0:   bridge window [mem 0xfde00000-0xfdefffff]
[    0.244416] pci 0000:00:0b.0:   bridge window [mem 0xfdd00000-0xfddfffff 64bit pref]
[    0.244447] pci 0000:00:0c.0: PCI bridge to [bus 03]
[    0.244465] pci 0000:00:0c.0:   bridge window [io  0x7000-0x7fff]
[    0.244486] pci 0000:00:0c.0:   bridge window [mem 0xfdc00000-0xfdcfffff]
[    0.244506] pci 0000:00:0c.0:   bridge window [mem 0xfdb00000-0xfdbfffff 64bit pref]
[    0.244537] pci 0000:00:0d.0: PCI bridge to [bus 04]
[    0.244555] pci 0000:00:0d.0:   bridge window [io  0x6000-0x6fff]
[    0.244575] pci 0000:00:0d.0:   bridge window [mem 0xfda00000-0xfdafffff]
[    0.244595] pci 0000:00:0d.0:   bridge window [mem 0xfd900000-0xfd9fffff 64bit pref]
[    0.244630] pci 0000:05:00.0: BAR 6: assigned [mem 0xfa000000-0xfa01ffff pref]
[    0.244660] pci 0000:00:0e.0: PCI bridge to [bus 05]
[    0.244678] pci 0000:00:0e.0:   bridge window [io  0x5000-0x5fff]
[    0.244698] pci 0000:00:0e.0:   bridge window [mem 0xf8000000-0xfaffffff]
[    0.244718] pci 0000:00:0e.0:   bridge window [mem 0xd0000000-0xdfffffff 64bit pref]
[    0.244752] pci_bus 0000:00: resource 4 [io  0x0000-0x03af window]
[    0.244756] pci_bus 0000:00: resource 5 [io  0x03e0-0x0cf7 window]
[    0.244760] pci_bus 0000:00: resource 6 [io  0x5000-0xffff window]
[    0.244764] pci_bus 0000:00: resource 7 [io  0x03b0-0x03df window]
[    0.244768] pci_bus 0000:00: resource 8 [mem 0x000a0000-0x000bffff window]
[    0.244773] pci_bus 0000:00: resource 9 [mem 0xc0000000-0xdfffffff window]
[    0.244777] pci_bus 0000:00: resource 10 [mem 0xf0000000-0xfe02ffff window]
[    0.244781] pci_bus 0000:00: resource 11 [mem 0xfeb00000-0xfebfffff window]
[    0.244786] pci_bus 0000:01: resource 0 [io  0x9000-0xafff]
[    0.244790] pci_bus 0000:01: resource 1 [mem 0xfb000000-0xfcffffff]
[    0.244794] pci_bus 0000:01: resource 2 [mem 0xfdf00000-0xfdffffff pref]
[    0.244798] pci_bus 0000:01: resource 4 [io  0x0000-0x03af window]
[    0.244802] pci_bus 0000:01: resource 5 [io  0x03e0-0x0cf7 window]
[    0.244806] pci_bus 0000:01: resource 6 [io  0x5000-0xffff window]
[    0.244810] pci_bus 0000:01: resource 7 [io  0x03b0-0x03df window]
[    0.244815] pci_bus 0000:01: resource 8 [mem 0x000a0000-0x000bffff window]
[    0.244819] pci_bus 0000:01: resource 9 [mem 0xc0000000-0xdfffffff window]
[    0.244823] pci_bus 0000:01: resource 10 [mem 0xf0000000-0xfe02ffff window]
[    0.244827] pci_bus 0000:01: resource 11 [mem 0xfeb00000-0xfebfffff window]
[    0.244832] pci_bus 0000:02: resource 0 [io  0x8000-0x8fff]
[    0.244836] pci_bus 0000:02: resource 1 [mem 0xfde00000-0xfdefffff]
[    0.244840] pci_bus 0000:02: resource 2 [mem 0xfdd00000-0xfddfffff 64bit pref]
[    0.244845] pci_bus 0000:03: resource 0 [io  0x7000-0x7fff]
[    0.244849] pci_bus 0000:03: resource 1 [mem 0xfdc00000-0xfdcfffff]
[    0.244853] pci_bus 0000:03: resource 2 [mem 0xfdb00000-0xfdbfffff 64bit pref]
[    0.244857] pci_bus 0000:04: resource 0 [io  0x6000-0x6fff]
[    0.244861] pci_bus 0000:04: resource 1 [mem 0xfda00000-0xfdafffff]
[    0.244866] pci_bus 0000:04: resource 2 [mem 0xfd900000-0xfd9fffff 64bit pref]
[    0.244870] pci_bus 0000:05: resource 0 [io  0x5000-0x5fff]
[    0.244874] pci_bus 0000:05: resource 1 [mem 0xf8000000-0xfaffffff]
[    0.244878] pci_bus 0000:05: resource 2 [mem 0xd0000000-0xdfffffff 64bit pref]
[    0.245097] NET: Registered protocol family 2
[    0.245476] TCP established hash table entries: 32768 (order: 6, 262144 bytes)
[    0.245771] TCP bind hash table entries: 32768 (order: 7, 524288 bytes)
[    0.246246] TCP: Hash tables configured (established 32768 bind 32768)
[    0.246378] UDP hash table entries: 2048 (order: 4, 65536 bytes)
[    0.246459] UDP-Lite hash table entries: 2048 (order: 4, 65536 bytes)
[    0.246651] NET: Registered protocol family 1
[    0.247377] ACPI: PCI Interrupt Link [APCF] enabled at IRQ 23
[    0.324819] ACPI: PCI Interrupt Link [APCL] enabled at IRQ 22
[    0.325181] pci 0000:00:00.0: Found enabled HT MSI Mapping
[    0.325206] pci 0000:00:0b.0: Found disabled HT MSI Mapping
[    0.325230] pci 0000:00:00.0: Found enabled HT MSI Mapping
[    0.325295] pci 0000:00:00.0: Found enabled HT MSI Mapping
[    0.325317] pci 0000:00:0c.0: Found disabled HT MSI Mapping
[    0.325342] pci 0000:00:00.0: Found enabled HT MSI Mapping
[    0.325410] pci 0000:00:00.0: Found enabled HT MSI Mapping
[    0.325432] pci 0000:00:0d.0: Found disabled HT MSI Mapping
[    0.325457] pci 0000:00:00.0: Found enabled HT MSI Mapping
[    0.325529] pci 0000:00:00.0: Found enabled HT MSI Mapping
[    0.325551] pci 0000:00:0e.0: Found disabled HT MSI Mapping
[    0.325576] pci 0000:00:00.0: Found enabled HT MSI Mapping
[    0.325641] pci 0000:05:00.0: Video device with shadowed ROM at [mem 0x000c0000-0x000dffff]
[    0.325670] PCI: CLS 32 bytes, default 64
[    0.326072] PCI-DMA: Disabling AGP.
[    0.326574] PCI-DMA: aperture base @ c0000000 size 262144 KB
[    0.326618] PCI-DMA: using GART IOMMU.
[    0.326639] PCI-DMA: Reserving 256MB of IOMMU area in the AGP aperture
[    0.336981] simple-framebuffer simple-framebuffer.0: framebuffer at 0xd0000000, 0x500000 bytes, mapped to 0xffffc90000800000
[    0.337043] clocksource: tsc: mask: 0xffffffffffffffff max_cycles: 0xe7d795ee82, max_idle_ns: 440795205334 ns
[    0.337090] simple-framebuffer simple-framebuffer.0: format=a8r8g8b8, mode=1280x1024x32, linelength=5120
[    0.355345] Console: switching to colour frame buffer device 160x64
[    0.373276] simple-framebuffer simple-framebuffer.0: fb0: simplefb registered!
[    0.373883] futex hash table entries: 512 (order: 3, 32768 bytes)
[    0.374517] workingset: timestamp_bits=62 max_order=20 bucket_order=0
[    0.380478] cryptomgr_test (33) used greatest stack depth: 15296 bytes left
[    0.380740] cryptomgr_test (35) used greatest stack depth: 14904 bytes left
[    0.382785] Block layer SCSI generic (bsg) driver version 0.4 loaded (major 252)
[    0.382961] io scheduler noop registered
[    0.383048] io scheduler deadline registered
[    0.383228] io scheduler cfq registered (default)
[    0.383812] Serial: 8250/16550 driver, 4 ports, IRQ sharing disabled
[    0.385007] Non-volatile memory driver v1.3
[    0.385102] Linux agpgart interface v0.103
[    0.385688] sata_nv 0000:00:07.0: version 3.5
[    0.386442] ACPI: PCI Interrupt Link [APSI] enabled at IRQ 21
[    0.387483] scsi host0: sata_nv
[    0.387855] scsi host1: sata_nv
[    0.388088] ata1: SATA max UDMA/133 cmd 0x9f0 ctl 0xbf0 bmdma 0xd400 irq 21
[    0.388240] ata2: SATA max UDMA/133 cmd 0x970 ctl 0xb70 bmdma 0xd408 irq 21
[    0.389047] ACPI: PCI Interrupt Link [APSJ] enabled at IRQ 20
[    0.390099] scsi host2: sata_nv
[    0.390442] scsi host3: sata_nv
[    0.390634] ata3: SATA max UDMA/133 cmd 0x9e0 ctl 0xbe0 bmdma 0xc000 irq 20
[    0.390785] ata4: SATA max UDMA/133 cmd 0x960 ctl 0xb60 bmdma 0xc008 irq 20
[    0.391017] forcedeth: Reverse Engineered nForce ethernet driver. Version 0.64.
[    0.391781] ACPI: PCI Interrupt Link [APCH] enabled at IRQ 23
[    0.702598] ata3: SATA link down (SStatus 0 SControl 300)
[    0.702606] ata1: SATA link down (SStatus 0 SControl 300)
[    0.939074] forcedeth 0000:00:0a.0: ifname eth0, PHY OUI 0x5043 @ 1, addr 00:e0:81:5b:71:c3
[    0.939259] forcedeth 0000:00:0a.0: highdma csum gbit lnktim desc-v3
[    0.939526] i8042: PNP: No PS/2 controller found. Probing ports directly.
[    0.942145] serio: i8042 KBD port at 0x60,0x64 irq 1
[    0.942265] serio: i8042 AUX port at 0x60,0x64 irq 12
[    0.942744] mousedev: PS/2 mouse device common for all mice
[    0.942948] rtc_cmos 00:02: RTC can wake from S4
[    0.943301] rtc_cmos 00:02: rtc core: registered rtc_cmos as rtc0
[    0.943470] rtc_cmos 00:02: alarms up to one year, y3k, 242 bytes nvram
[    0.944140] NET: Registered protocol family 10
[    0.944929] mip6: Mobile IPv6
[    0.945016] NET: Registered protocol family 17
[    0.945128] Key type dns_resolver registered
[    0.950879] microcode: AMD CPU family 0xf not supported
[    0.956696] registered taskstats version 1
[    0.962365] kworker/u4:0 (66) used greatest stack depth: 14608 bytes left
[    0.968366] cryptomgr_probe (68) used greatest stack depth: 14584 bytes left
[    0.974230] kworker/u4:0 (70) used greatest stack depth: 13968 bytes left
[    0.974474] Key type encrypted registered
[    0.974946] netpoll: netconsole: local port 1980
[    0.974949] netpoll: netconsole: local IPv4 address 192.168.78.12
[    0.974950] netpoll: netconsole: interface 'eth0'
[    0.974952] netpoll: netconsole: remote port 1975
[    0.974954] netpoll: netconsole: remote IPv4 address 192.168.78.2
[    0.974956] netpoll: netconsole: remote ethernet address 00:16:3e:67:55:38
[    0.974959] netpoll: netconsole: device eth0 not up yet, forcing it
[    0.975626] forcedeth 0000:00:0a.0 eth0: no link during initialization
[    0.975896] IPv6: ADDRCONF(NETDEV_UP): eth0: link is not ready
[    1.172049] ata2: SATA link up 1.5 Gbps (SStatus 113 SControl 300)
[    1.180358] ata2.00: LPM support broken, forcing max_power
[    1.186475] ata2.00: ATA-6: WDC WD800JD-00HKA0, 13.03G13, max UDMA/133
[    1.192449] ata2.00: 156301488 sectors, multi 16: LBA 
[    1.202832] ata2.00: LPM support broken, forcing max_power
[    1.208767] ata2.00: configured for UDMA/133
[    1.214743] scsi 1:0:0:0: Direct-Access     ATA      WDC WD800JD-00HK 3G13 PQ: 0 ANSI: 5
[    1.260369] sd 1:0:0:0: [sda] 156301488 512-byte logical blocks: (80.0 GB/74.5 GiB)
[    1.266237] sd 1:0:0:0: [sda] Write Protect is off
[    1.271932] sd 1:0:0:0: [sda] Mode Sense: 00 3a 00 00
[    1.271960] sd 1:0:0:0: [sda] Write cache: enabled, read cache: enabled, doesn't support DPO or FUA
[    1.318605]  sda: sda1 sda2 < sda5 >
[    1.324873] sd 1:0:0:0: [sda] Attached SCSI disk
[    1.578543] ata4: SATA link down (SStatus 0 SControl 300)
[    2.564013] forcedeth 0000:00:0a.0 eth0: link up
[    2.567399] IPv6: ADDRCONF(NETDEV_CHANGE): eth0: link becomes ready
[    2.580677] console [netcon0] enabled
[    2.586378] netconsole: network logging started
[    2.592130] rtc_cmos 00:02: setting system clock to 2016-11-29 15:37:19 UTC (1480433839)
[    2.604694] random: fast init done
[    2.615861] EXT4-fs (sda1): couldn't mount as ext3 due to feature incompatibilities
[    2.622035] EXT4-fs (sda1): couldn't mount as ext2 due to feature incompatibilities
[    2.664825] EXT4-fs (sda1): mounted filesystem with ordered data mode. Opts: (null)
[    2.670776] VFS: Mounted root (ext4 filesystem) readonly on device 8:1.
[    2.752314] devtmpfs: mounted
[    2.761596] Freeing unused kernel memory: 936K (ffffffff822ff000 - ffffffff823e9000)
[    2.767673] Write protecting the kernel read-only data: 12288k
[    2.775781] Freeing unused kernel memory: 1540K (ffff88000187f000 - ffff880001a00000)
[    2.787719] Freeing unused kernel memory: 760K (ffff880001b42000 - ffff880001c00000)
[    2.828056] x86/mm: Checked W+X mappings: passed, no W+X pages found.
[    3.633245] stty (79) used greatest stack depth: 13368 bytes left
[    3.715386] uname (81) used greatest stack depth: 13264 bytes left
[    4.559648] ps (154) used greatest stack depth: 13216 bytes left
[    5.555988] input: Power Button as /devices/LNXSYSTM:00/LNXSYBUS:00/PNP0C0C:00/input/input2
[    5.563371] ACPI: Power Button [PWRB]
[    5.570440] input: Power Button as /devices/LNXSYSTM:00/LNXPWRBN:00/input/input3
[    5.577383] ACPI: Power Button [PWRF]
[    5.699763] i2c i2c-0: nForce2 SMBus adapter at 0x400
[    5.706738] i2c i2c-1: nForce2 SMBus adapter at 0x440
[    5.844911] pata_amd 0000:00:06.0: version 0.4.1
[    5.847265] scsi host4: pata_amd
[    5.854345] scsi host5: pata_amd
[    5.861166] ata5: PATA max UDMA/133 cmd 0x1f0 ctl 0x3f6 bmdma 0xe800 irq 14
[    5.867953] ata6: PATA max UDMA/133 cmd 0x170 ctl 0x376 bmdma 0xe808 irq 15
[    6.034576] ata5.00: ATAPI: LITE-ON DVD SOHD-16P9S, F3S2, max UDMA/33
[    6.041409] ata5: nv_mode_filter: 0x739f&0x739f->0x739f, BIOS=0x7000 (0xc0000000) ACPI=0x701f (60:600:0x13)
[    6.043972] ata5.00: configured for UDMA/33
[    6.051689] scsi 4:0:0:0: CD-ROM            LITE-ON  DVD SOHD-16P9S   F3S2 PQ: 0 ANSI: 5
[    6.201923] ACPI: PCI Interrupt Link [APC3] enabled at IRQ 18
[    6.261402] i91u: PCI Base=0xA000, IRQ=18, BIOS=0xFF000, SCSI ID=7
[    6.268221] i91u: Reset SCSI Bus ... 
[    6.642771] ACPI: PCI Interrupt Link [APC1] enabled at IRQ 16
[    7.721797] scsi: ***** BusLogic SCSI Driver Version 2.1.17 of 12 September 2013 *****
[    7.728867] scsi: Copyright 1995-1998 by Leonard N. Zubkoff <lnz@dandelion.com>
[    7.736346] scsi7: Configuring BusLogic Model BT-950 PCI Wide Ultra SCSI Host Adapter
[    7.743401] scsi7:   Firmware Version: 5.02, I/O Address: 0xA400, IRQ Channel: 16/Level
[    7.756655] scsi7:   PCI Bus: 1, Device: 7, Address: 
[    7.756794] 0xFCFFD000, 
[    7.766570] Host Adapter SCSI ID: 7
[    7.773806] scsi7:   Parity Checking: Enabled, Extended Translation: Enabled
[    7.781109] scsi7:   Synchronous Negotiation: Fast, Wide Negotiation: Enabled
[    7.788417] scsi7:   Disconnect/Reconnect: Enabled, Tagged Queuing: Enabled
[    7.798344] scsi7:   Driver Queue Depth: 255, Scatter/Gather Limit: 128 segments
[    7.805678] scsi7:   Tagged Queue Depth: 
[    7.805773] Automatic
[    7.812989] , Untagged Queue Depth: 3
[    7.820661] scsi7:   SCSI Bus Termination: Both Enabled
[    7.820784] , SCAM: Disabled

[    7.835663] scsi7: *** BusLogic BT-950 Initialized Successfully ***
[    9.827561] scsi host7: BusLogic BT-950
[    9.834953] floppy0: no floppy controllers found
[    9.834970] work still pending
[   10.040064] sd 1:0:0:0: Attached scsi generic sg0 type 0
[   10.050192] scsi 4:0:0:0: Attached scsi generic sg1 type 5
[   10.356596] ata_id (267) used greatest stack depth: 12600 bytes left
[   10.586702] ACPI: bus type USB registered
[   10.597053] usbcore: registered new interface driver usbfs
[   10.607918] usbcore: registered new interface driver hub
[   10.616986] usbcore: registered new device driver usb
[   10.784277] ehci_hcd: USB 2.0 'Enhanced' Host Controller (EHCI) Driver
[   10.987371] ehci-pci: EHCI PCI platform driver
[   10.997184] ehci-pci 0000:00:02.1: EHCI Host Controller
[   11.004136] ehci-pci 0000:00:02.1: new USB bus registered, assigned bus number 1
[   11.011031] BUG: sleeping function called from invalid context at kernel/irq/manage.c:110
[   11.011031] in_atomic(): 1, irqs_disabled(): 1, pid: 238, name: systemd-udevd
[   11.011031] CPU: 0 PID: 238 Comm: systemd-udevd Not tainted 4.9.0-rc7-00007-g88abd82 #12
[   11.011031] Hardware name: Sun Microsystems Sun Ultra 20 Workstation/2864, BIOS 2.3.0  05/15/2008
[   11.011031]  0000000000000000 ffffffff814517a2 0000000000000041 ffffc900002c4000
[   11.011031]  ffff88013a4705b8 ffffffff810cacf6 ffff88013a9a4a00 ffffc9000002d000
[   11.011031]  00000000000000df ffffffff81118dfe 0000000000000001 ffffffff811181fe
[   11.011031] Call Trace:
[   11.011031]  [<ffffffff814517a2>] ? dump_stack+0x47/0x65
[   11.011031]  [<ffffffff810cacf6>] ? ___might_sleep+0x106/0x1b0
[   11.011031]  [<ffffffff81118dfe>] ? synchronize_irq+0x2e/0xa0
[   11.011031]  [<ffffffff811181fe>] ? __irq_put_desc_unlock+0x1e/0x80
[   11.011031]  [<ffffffff811191fc>] ? __disable_irq_nosync+0x3c/0x60
[   11.011031]  [<ffffffff8165b33a>] ? nv_do_nic_poll+0x7a/0x5e0
[   11.011031]  [<ffffffff8171115c>] ? netpoll_poll_dev+0xbc/0x290
[   11.011031]  [<ffffffff817119d4>] ? netpoll_send_skb_on_dev+0x1e4/0x3f0
[   11.011031]  [<ffffffff817120b4>] ? netpoll_send_udp+0x404/0x950
[   11.011031]  [<ffffffff814e3910>] ? bit_update_start+0x90/0x90
[   11.011031]  [<ffffffff8164c174>] ? write_msg+0x104/0x1c0
[   11.011031]  [<ffffffff8111448a>] ? call_console_drivers.isra.13.constprop.26+0x9a/0xc0
[   11.011031]  [<ffffffff811153b0>] ? console_unlock+0x350/0x690
[   11.011031]  [<ffffffff81115949>] ? vprintk_emit+0x259/0x570
[   11.011031]  [<ffffffff815b2710>] ? dev_vprintk_emit+0xe0/0x2e0
[   11.011031]  [<ffffffff8122e22c>] ? kmem_cache_alloc+0x11c/0x1b0
[   11.011031]  [<ffffffff815b2949>] ? dev_printk_emit+0x39/0x40
[   11.011031]  [<ffffffff81455128>] ? idr_mark_full+0x78/0xc0
[   11.011031]  [<ffffffff815b2d47>] ? _dev_info+0x57/0x60
[   11.011031]  [<ffffffffa022a8df>] ? usb_add_hcd+0xdf/0xa40 [usbcore]
[   11.011031]  [<ffffffffa0246289>] ? for_each_companion+0x49/0xe0 [usbcore]
[   11.011031]  [<ffffffffa0246772>] ? usb_hcd_pci_probe+0x452/0x720 [usbcore]
[   11.011031]  [<ffffffff814aeb6f>] ? pci_device_probe+0xcf/0x160
[   11.011031]  [<ffffffff815b6622>] ? driver_probe_device+0xf2/0x370
[   11.011031]  [<ffffffff815b6960>] ? __driver_attach+0xc0/0x100
[   11.011031]  [<ffffffff815b68a0>] ? driver_probe_device+0x370/0x370
[   11.011031]  [<ffffffff815b35ec>] ? bus_for_each_dev+0x6c/0xb0
[   11.011031]  [<ffffffff815b4e87>] ? bus_add_driver+0x117/0x2c0
[   11.011031]  [<ffffffff815b7357>] ? driver_register+0x67/0x110
[   11.011031]  [<ffffffffa028f000>] ? 0xffffffffa028f000
[   11.011031]  [<ffffffff81000443>] ? do_one_initcall+0x53/0x1d0
[   11.011031]  [<ffffffff8122e1a2>] ? kmem_cache_alloc+0x92/0x1b0
[   11.011031]  [<ffffffff812052a8>] ? free_vmap_area_noflush+0x68/0x100
[   11.011031]  [<ffffffff8118f35f>] ? do_init_module+0x94/0x275
[   11.011031]  [<ffffffff8115bcaa>] ? load_module+0x23aa/0x31a0
[   11.011031]  [<ffffffff81157c40>] ? m_show+0x200/0x200
[   11.011031]  [<ffffffff8125f792>] ? kernel_read_file_from_fd+0x52/0x90
[   11.011031]  [<ffffffff8115ccb6>] ? SYSC_finit_module+0xd6/0xe0
[   11.011031]  [<ffffffff810029ad>] ? do_syscall_64+0x9d/0x300
[   11.011031]  [<ffffffff8187644a>] ? entry_SYSCALL64_slow_path+0x25/0x25
[   11.221006] ohci_hcd: USB 1.1 'Open' Host Controller (OHCI) Driver
[   11.328542] ehci-pci 0000:00:02.1: debug port 1
[   11.333691] ehci-pci 0000:00:02.1: cache line size of 32 is not supported
[   11.333737] ehci-pci 0000:00:02.1: irq 22, io mem 0xfeb00000
[   11.352042] ehci-pci 0000:00:02.1: USB 2.0 started, EHCI 1.00
[   11.361254] usb usb1: New USB device found, idVendor=1d6b, idProduct=0002
[   11.366444] usb usb1: New USB device strings: Mfr=3, Product=2, SerialNumber=1
[   11.371609] usb usb1: Product: EHCI Host Controller
[   11.376812] usb usb1: Manufacturer: Linux 4.9.0-rc7-00007-g88abd82 ehci_hcd
[   11.383879] usb usb1: SerialNumber: 0000:00:02.1
[   11.391477] hub 1-0:1.0: USB hub found
[   11.398600] hub 1-0:1.0: 8 ports detected
[   11.405339] ACPI: PCI Interrupt Link [APCJ] enabled at IRQ 22
[   11.461202] ohci-pci: OHCI PCI platform driver
[   11.744051] snd_intel8x0 0000:00:04.0: intel8x0_measure_ac97_clock: measured 58604 usecs (2872 samples)
[   11.756321] snd_intel8x0 0000:00:04.0: clocking to 47014
[   11.771603] ohci-pci 0000:00:02.0: OHCI PCI host controller
[   11.776915] ohci-pci 0000:00:02.0: new USB bus registered, assigned bus number 2
[   11.792090] ohci-pci 0000:00:02.0: irq 23, io mem 0xfe02f000
[   11.858143] usb usb2: New USB device found, idVendor=1d6b, idProduct=0001
[   11.863518] usb usb2: New USB device strings: Mfr=3, Product=2, SerialNumber=1
[   11.868669] usb usb2: Product: OHCI PCI host controller
[   11.873727] usb usb2: Manufacturer: Linux 4.9.0-rc7-00007-g88abd82 ohci_hcd
[   11.878847] usb usb2: SerialNumber: 0000:00:02.0
[   11.886470] hub 2-0:1.0: USB hub found
[   11.893377] hub 2-0:1.0: 8 ports detected
[   12.110753] input: PC Speaker as /devices/platform/pcspkr/input/input4
[   12.458415] random: crng init done
[   12.671477] EDAC MC: Ver: 3.0.0
[   12.714967] Error: Driver 'pcspkr' is already registered, aborting...
[   12.751862] MCE: In-kernel MCE decoding enabled.
[   12.859914] EDAC amd64: DRAM ECC enabled.
[   12.867539] EDAC amd64: K8 revE or earlier detected (node 0).
[   12.873458] EDAC MC0: Giving out device to module amd64_edac controller K8: DEV 0000:00:18.2 (INTERRUPT)
[   12.892620] EDAC PCI0: Giving out device to module amd64_edac controller EDAC PCI controller: DEV 0000:00:18.2 (POLLED)
[   12.904039] AMD64 EDAC driver v3.4.0
[   12.908011] BUG: sleeping function called from invalid context at kernel/irq/manage.c:110
[   12.908011] in_atomic(): 1, irqs_disabled(): 1, pid: 241, name: systemd-udevd
[   12.908011] CPU: 0 PID: 241 Comm: systemd-udevd Tainted: G        W       4.9.0-rc7-00007-g88abd82 #12
[   12.908011] Hardware name: Sun Microsystems Sun Ultra 20 Workstation/2864, BIOS 2.3.0  05/15/2008
[   12.908011]  0000000000000000 ffffffff814517a2 0000000000000041 ffffc900002dc000
[   12.908011]  ffff88013a8e1c38 ffffffff810cacf6 ffff88013a9a4a00 ffffc9000002d000
[   12.908011]  0000000000000060 ffffffff81118dfe 0000000000000001 ffffffff811181fe
[   12.908011] Call Trace:
[   12.908011]  [<ffffffff814517a2>] ? dump_stack+0x47/0x65
[   12.908011]  [<ffffffff810cacf6>] ? ___might_sleep+0x106/0x1b0
[   12.908011]  [<ffffffff81118dfe>] ? synchronize_irq+0x2e/0xa0
[   12.908011]  [<ffffffff811181fe>] ? __irq_put_desc_unlock+0x1e/0x80
[   12.908011]  [<ffffffff811191fc>] ? __disable_irq_nosync+0x3c/0x60
[   12.908011]  [<ffffffff8165b33a>] ? nv_do_nic_poll+0x7a/0x5e0
[   12.908011]  [<ffffffff8171115c>] ? netpoll_poll_dev+0xbc/0x290
[   12.908011]  [<ffffffff817119d4>] ? netpoll_send_skb_on_dev+0x1e4/0x3f0
[   12.908011]  [<ffffffff817120b4>] ? netpoll_send_udp+0x404/0x950
[   12.908011]  [<ffffffff814e3910>] ? bit_update_start+0x90/0x90
[   12.908011]  [<ffffffff8164c174>] ? write_msg+0x104/0x1c0
[   12.908011]  [<ffffffff8111448a>] ? call_console_drivers.isra.13.constprop.26+0x9a/0xc0
[   12.908011]  [<ffffffff811153b0>] ? console_unlock+0x350/0x690
[   12.908011]  [<ffffffff81115949>] ? vprintk_emit+0x259/0x570
[   12.908011]  [<ffffffff8118eee5>] ? printk+0x43/0x4b
[   12.908011]  [<ffffffffa03bd990>] ? amd64_edac_init+0x990/0x2000 [amd64_edac_mod]
[   12.908011]  [<ffffffffa03bd000>] ? 0xffffffffa03bd000
[   12.908011]  [<ffffffff81000443>] ? do_one_initcall+0x53/0x1d0
[   12.908011]  [<ffffffff8122e1a2>] ? kmem_cache_alloc+0x92/0x1b0
[   12.908011]  [<ffffffff812052a8>] ? free_vmap_area_noflush+0x68/0x100
[   12.908011]  [<ffffffff8118f35f>] ? do_init_module+0x94/0x275
[   12.908011]  [<ffffffff8115bcaa>] ? load_module+0x23aa/0x31a0
[   12.908011]  [<ffffffff81157c40>] ? m_show+0x200/0x200
[   12.908011]  [<ffffffff8125f792>] ? kernel_read_file_from_fd+0x52/0x90
[   12.908011]  [<ffffffff8115ccb6>] ? SYSC_finit_module+0xd6/0xe0
[   12.908011]  [<ffffffff810029ad>] ? do_syscall_64+0x9d/0x300
[   12.908011]  [<ffffffff8187644a>] ? entry_SYSCALL64_slow_path+0x25/0x25
[   13.195212] powernow_k8: fid 0xe (2200 MHz), vid 0x8
[   13.203737] powernow_k8: fid 0xc (2000 MHz), vid 0xa
[   13.209740] powernow_k8: fid 0xa (1800 MHz), vid 0xc
[   13.215860] powernow_k8: fid 0x2 (1000 MHz), vid 0x12
[   13.221776] powernow_k8: Found 1 Dual Core AMD Opteron(tm) Processor 175 (2 cpu cores) (version 2.20.00)
[   13.352889] [drm] Initialized
[   14.188444] wmi: Mapper loaded
[   16.276059] scsi host6: Initio INI-9X00U/UW SCSI device driver
[   16.284444] ACPI: PCI Interrupt Link [APC2] enabled at IRQ 17
[   16.285031] sr 4:0:0:0: [sr0] scsi3-mmc drive: 4x/48x cd/rw xa/form2 cdda tray
[   16.285034] cdrom: Uniform CD-ROM driver Revision: 3.20
[   16.285236] sr 4:0:0:0: Attached scsi CD-ROM sr0
[   16.298699] PCI parallel port detected: 1407:8000, I/O at 0x9c00(0x0), IRQ 17
[   16.298755] parport0: PC-style at 0x9c00, irq 17 [PCSPP,TRISTATE,EPP]
[   16.472085] firewire_ohci 0000:01:06.0: added OHCI v1.10 device as card 0, 4 IR + 8 IT contexts, quirks 0x11
[   16.903206] checking generic (d0000000 500000) vs hw (d0000000 10000000)
[   16.903211] fb: switching to nouveaufb from simple
[   16.909390] Console: switching to colour dummy device 80x25
[   16.909874] nouveau 0000:05:00.0: NVIDIA G72 (246300b1)
[   16.992267] firewire_core 0000:01:06.0: created device fw0: GUID 00e081000024cf31, S400
[   17.100617] nouveau 0000:05:00.0: bios: version 05.72.22.71.09
[   17.102363] nouveau 0000:05:00.0: fb: 128 MiB DDR2
[   18.404049] [TTM] Zone  kernel: Available graphics memory: 2051514 kiB
[   18.404069] [TTM] Initializing pool allocator
[   18.404084] [TTM] Initializing DMA pool allocator
[   18.404120] nouveau 0000:05:00.0: DRM: VRAM: 125 MiB
[   18.404131] nouveau 0000:05:00.0: DRM: GART: 512 MiB
[   18.404143] nouveau 0000:05:00.0: DRM: TMDS table version 1.1
[   18.404154] nouveau 0000:05:00.0: DRM: TMDS table script pointers not stubbed
[   18.404165] nouveau 0000:05:00.0: DRM: DCB version 3.0
[   18.404176] nouveau 0000:05:00.0: DRM: DCB outp 00: 01010300 00000028
[   18.404188] nouveau 0000:05:00.0: DRM: DCB outp 01: 01010302 00000000
[   18.404199] nouveau 0000:05:00.0: DRM: DCB outp 02: 02001310 00000028
[   18.404210] nouveau 0000:05:00.0: DRM: DCB outp 03: 020223f1 00a0c030
[   18.404221] nouveau 0000:05:00.0: DRM: DCB conn 00: 1030
[   18.404231] nouveau 0000:05:00.0: DRM: DCB conn 01: 0100
[   18.404241] nouveau 0000:05:00.0: DRM: DCB conn 02: 0210
[   18.404251] nouveau 0000:05:00.0: DRM: DCB conn 03: 0211
[   18.406573] [drm] Supports vblank timestamp caching Rev 2 (21.10.2013).
[   18.406586] [drm] Driver supports precise vblank timestamp query.
[   18.409721] nouveau 0000:05:00.0: DRM: MM: using M2MF for buffer copies
[   18.409744] nouveau 0000:05:00.0: DRM: Setting dpms mode 3 on TV encoder (output 3)
[   18.528034] nouveau 0000:05:00.0: No connectors reported connected with modes
[   18.528080] [drm] Cannot find any crtc or sizes - going 1024x768
[   18.528341] nouveau 0000:05:00.0: DRM: allocated 1024x768 fb: 0x9000, bo ffff88013abe6c00
[   18.528470] fbcon: nouveaufb (fb0) is primary device
[   18.648069] Console: switching to colour frame buffer device 128x48
[   18.649688] nouveau 0000:05:00.0: fb0: nouveaufb frame buffer device
[   18.664100] [drm] Initialized nouveau 1.3.1 20120801 for 0000:05:00.0 on minor 0
[   20.472053] systemd-udevd (237) used greatest stack depth: 12280 bytes left
[   21.105087] Adding 3212284k swap on /dev/sda5.  Priority:-1 extents:1 across:3212284k 
[   21.185803] EXT4-fs (sda1): re-mounted. Opts: (null)
[   21.365522] EXT4-fs (sda1): re-mounted. Opts: errors=remount-ro
[   21.762166] loop: module loaded
[   21.908067] i2c i2c-0: Found a DME1737 chip at 0x2e (rev 0x89).
[   21.932115] dme1737 0-002e: Optional features: pwm3=yes, pwm5=no, pwm6=no, fan3=yes, fan4=yes, fan5=no, fan6=no.
[   22.048040] i2c i2c-1: Found a DME1737 chip at 0x2e (rev 0x89).
[   22.072069] dme1737 1-002e: Optional features: pwm3=yes, pwm5=no, pwm6=no, fan3=yes, fan4=yes, fan5=no, fan6=no.
[ 6003.936088] kworker/dying (62) used greatest stack depth: 11952 bytes left


-- 
Meelis Roos (mroos@linux.ee)
