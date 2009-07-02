From: Ingo Molnar <mingo@elte.hu>
Subject: Re: [GIT]: Networking
Date: Thu, 2 Jul 2009 10:02:04 +0200
Message-ID: <20090702080204.GA11505@elte.hu>
References: <20090630.213927.180401151.davem@davemloft.net> <20090702075724.GA10608@elte.hu>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: torvalds@linux-foundation.org, akpm@linux-foundation.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1754676AbZGBIEP@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20090702075724.GA10608@elte.hu>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


* Ingo Molnar <mingo@elte.hu> wrote:

> Config attached. Unfortunately i've got no time to do bisection=20
> today.

=46ull bootlog attached. (The lockep warning triggered by kmemleak is=20
unrelated.)

	Ingo

[    0.000000] Linux version 2.6.31-rc1-tip-01159-g24b7800-dirty (mingo=
@sirius) (gcc version 4.3.2 20081105 (Red Hat 4.3.2-7) (GCC) ) #59554 S=
MP Thu Jul 2 09:18:32 CEST 2009
[    0.000000] KERNEL supported cpus:
[    0.000000]   Intel GenuineIntel
[    0.000000]   AMD AuthenticAMD
[    0.000000]   NSC Geode by NSC
[    0.000000]   Cyrix CyrixInstead
[    0.000000]   Centaur CentaurHauls
[    0.000000]   Transmeta GenuineTMx86
[    0.000000]   Transmeta TransmetaCPU
[    0.000000]   UMC UMC UMC UMC
[    0.000000] BIOS-provided physical RAM map:
[    0.000000]  BIOS-e820: 0000000000000000 - 000000000009f800 (usable)
[    0.000000]  BIOS-e820: 000000000009f800 - 00000000000a0000 (reserve=
d)
[    0.000000]  BIOS-e820: 00000000000f0000 - 0000000000100000 (reserve=
d)
[    0.000000]  BIOS-e820: 0000000000100000 - 000000003fff0000 (usable)
[    0.000000]  BIOS-e820: 000000003fff0000 - 000000003fff3000 (ACPI NV=
S)
[    0.000000]  BIOS-e820: 000000003fff3000 - 0000000040000000 (ACPI da=
ta)
[    0.000000]  BIOS-e820: 00000000e0000000 - 00000000f0000000 (reserve=
d)
[    0.000000]  BIOS-e820: 00000000fec00000 - 0000000100000000 (reserve=
d)
[    0.000000] console [earlyser0] enabled
[    0.000000] debug: ignoring loglevel setting.
[    0.000000] DMI 2.3 present.
[    0.000000] Phoenix BIOS detected: BIOS may corrupt low RAM, working=
 around it.
[    0.000000] e820 update range: 0000000000000000 - 0000000000010000 (=
usable) =3D=3D> (reserved)
[    0.000000] last_pfn =3D 0x3fff0 max_arch_pfn =3D 0x1000000
[    0.000000] MTRR default type: uncachable
[    0.000000] MTRR fixed ranges enabled:
[    0.000000]   00000-9FFFF write-back
[    0.000000]   A0000-BFFFF uncachable
[    0.000000]   C0000-C7FFF write-protect
[    0.000000]   C8000-FFFFF uncachable
[    0.000000] MTRR variable ranges enabled:
[    0.000000]   0 base 0000000000 mask FFC0000000 write-back
[    0.000000]   1 disabled
[    0.000000]   2 disabled
[    0.000000]   3 disabled
[    0.000000]   4 disabled
[    0.000000]   5 disabled
[    0.000000]   6 disabled
[    0.000000]   7 disabled
[    0.000000] x86 PAT enabled: cpu 0, old 0x7040600070406, new 0x70106=
00070106
[    0.000000] Warning only 893MB will be used.
[    0.000000] Use a HIGHMEM enabled kernel.
[    0.000000] Scanning 0 areas for low memory corruption
[    0.000000] modified physical RAM map:
[    0.000000]  modified: 0000000000000000 - 0000000000010000 (reserved=
)
[    0.000000]  modified: 0000000000010000 - 000000000009f800 (usable)
[    0.000000]  modified: 000000000009f800 - 00000000000a0000 (reserved=
)
[    0.000000]  modified: 00000000000f0000 - 0000000000100000 (reserved=
)
[    0.000000]  modified: 0000000000100000 - 000000003fff0000 (usable)
[    0.000000]  modified: 000000003fff0000 - 000000003fff3000 (ACPI NVS=
)
[    0.000000]  modified: 000000003fff3000 - 0000000040000000 (ACPI dat=
a)
[    0.000000]  modified: 00000000e0000000 - 00000000f0000000 (reserved=
)
[    0.000000]  modified: 00000000fec00000 - 0000000100000000 (reserved=
)
[    0.000000] initial memory mapped : 0 - 02e00000
[    0.000000] init_memory_mapping: 0000000000000000-0000000037d55000
[    0.000000] NX (Execute Disable) protection: active
[    0.000000]  0000000000 - 0000200000 page 4k
[    0.000000]  0000200000 - 0037c00000 page 2M
[    0.000000]  0037c00000 - 0037d55000 page 4k
[    0.000000] kernel direct mapping tables up to 37d55000 @ 10000-1700=
0
[    0.000000] ACPI: RSDP 000f76f0 00014 (v00 Nvidia)
[    0.000000] ACPI: RSDT 3fff3040 00034 (v01 Nvidia AWRDACPI 42302E31 =
AWRD 00000000)
[    0.000000] ACPI: FACP 3fff30c0 00074 (v01 Nvidia AWRDACPI 42302E31 =
AWRD 00000000)
[    0.000000] ACPI: DSDT 3fff3180 06264 (v01 NVIDIA AWRDACPI 00001000 =
MSFT 0100000E)
[    0.000000] ACPI: FACS 3fff0000 00040
[    0.000000] ACPI: SRAT 3fff9500 000A0 (v01 AMD    HAMMER   00000001 =
AMD  00000001)
[    0.000000] ACPI: MCFG 3fff9600 0003C (v01 Nvidia AWRDACPI 42302E31 =
AWRD 00000000)
[    0.000000] ACPI: APIC 3fff9440 0007C (v01 Nvidia AWRDACPI 42302E31 =
AWRD 00000000)
[    0.000000] ACPI: Local APIC address 0xfee00000
[    0.000000] 893MB LOWMEM available.
[    0.000000]   mapped low ram: 0 - 37d55000
[    0.000000]   low ram: 0 - 37d55000
[    0.000000]   node 0 low ram: 00000000 - 37d55000
[    0.000000]   node 0 bootmap 00012000 - 00018fac
[    0.000000] (8 early reservations) =3D=3D> bootmem [0000000000 - 003=
7d55000]
[    0.000000]   #0 [0000000000 - 0000001000]   BIOS data page =3D=3D> =
[0000000000 - 0000001000]
[    0.000000]   #1 [0000001000 - 0000002000]    EX TRAMPOLINE =3D=3D> =
[0000001000 - 0000002000]
[    0.000000]   #2 [0000006000 - 0000007000]       TRAMPOLINE =3D=3D> =
[0000006000 - 0000007000]
[    0.000000]   #3 [0001000000 - 0002a1a740]    TEXT DATA BSS =3D=3D> =
[0001000000 - 0002a1a740]
[    0.000000]   #4 [000009f800 - 0000100000]    BIOS reserved =3D=3D> =
[000009f800 - 0000100000]
[    0.000000]   #5 [0002a1b000 - 0002a32149]              BRK =3D=3D> =
[0002a1b000 - 0002a32149]
[    0.000000]   #6 [0000010000 - 0000012000]          PGTABLE =3D=3D> =
[0000010000 - 0000012000]
[    0.000000]   #7 [0000012000 - 0000019000]          BOOTMAP =3D=3D> =
[0000012000 - 0000019000]
[    0.000000] Zone PFN ranges:
[    0.000000]   DMA      0x00000010 -> 0x00001000
[    0.000000]   Normal   0x00001000 -> 0x00037d55
[    0.000000] Movable zone start PFN for each node
[    0.000000] early_node_map[2] active PFN ranges
[    0.000000]     0: 0x00000010 -> 0x0000009f
[    0.000000]     0: 0x00000100 -> 0x00037d55
[    0.000000] On node 0 totalpages: 228580
[    0.000000] free_area_init_node: node 0, pgdat c200a780, node_mem_ma=
p c2a333c0
[    0.000000]   DMA zone: 60 pages used for memmap
[    0.000000]   DMA zone: 0 pages reserved
[    0.000000]   DMA zone: 3923 pages, LIFO batch:0
[    0.000000]   Normal zone: 3290 pages used for memmap
[    0.000000]   Normal zone: 221307 pages, LIFO batch:31
[    0.000000] Using APIC driver default
[    0.000000] Nvidia board detected. Ignoring ACPI timer override.
[    0.000000] If you got timer trouble try acpi_use_timer_override
[    0.000000] ACPI: PM-Timer IO Port: 0x4008
[    0.000000] ACPI: Local APIC address 0xfee00000
[    0.000000] ACPI: LAPIC (acpi_id[0x00] lapic_id[0x00] enabled)
[    0.000000] ACPI: LAPIC (acpi_id[0x01] lapic_id[0x01] enabled)
[    0.000000] ACPI: LAPIC_NMI (acpi_id[0x00] high edge lint[0x1])
[    0.000000] ACPI: LAPIC_NMI (acpi_id[0x01] high edge lint[0x1])
[    0.000000] ACPI: IOAPIC (id[0x02] address[0xfec00000] gsi_base[0])
[    0.000000] IOAPIC[0]: apic_id 2, version 17, address 0xfec00000, GS=
I 0-23
[    0.000000] ACPI: INT_SRC_OVR (bus 0 bus_irq 0 global_irq 2 dfl dfl)
[    0.000000] ACPI: BIOS IRQ0 pin2 override ignored.
[    0.000000] ACPI: INT_SRC_OVR (bus 0 bus_irq 9 global_irq 9 high lev=
el)
[    0.000000] ACPI: INT_SRC_OVR (bus 0 bus_irq 14 global_irq 14 high e=
dge)
[    0.000000] ACPI: INT_SRC_OVR (bus 0 bus_irq 15 global_irq 15 high e=
dge)
[    0.000000] ACPI: IRQ9 used by override.
[    0.000000] ACPI: IRQ14 used by override.
[    0.000000] ACPI: IRQ15 used by override.
[    0.000000] Enabling APIC mode:  Flat.  Using 1 I/O APICs
[    0.000000] Using ACPI (MADT) for SMP configuration information
[    0.000000] SMP: Allowing 2 CPUs, 0 hotplug CPUs
[    0.000000] mapped APIC to ffffb000 (fee00000)
[    0.000000] mapped IOAPIC to ffffa000 (fec00000)
[    0.000000] nr_irqs_gsi: 24
[    0.000000] Allocating PCI resources starting at 40000000 (gap: 4000=
0000:a0000000)
[    0.000000] NR_CPUS:32 nr_cpumask_bits:32 nr_cpu_ids:2 nr_node_ids:1
[    0.000000] PERCPU: Embedded 337 pages at c375f000, static data 1366=
748 bytes
[    0.000000] Built 1 zonelists in Zone order, mobility grouping on.  =
Total pages: 225230
[    0.000000] Kernel command line: root=3D/dev/sda1 earlyprintk=3Dseri=
al,ttyS0,115200,keep console=3Dtty debug initcall_debug enforcing=3D0 a=
pic=3Dverbose ignore_loglevel sysrq_always_enabled selinux=3D0 nmi_watc=
hdog=3D0 3 panic=3D1
[    0.000000] debug: sysrq always enabled.
[    0.000000] PID hash table entries: 4096 (order: 12, 16384 bytes)
[    0.000000] Dentry cache hash table entries: 131072 (order: 7, 52428=
8 bytes)
[    0.000000] Inode-cache hash table entries: 65536 (order: 6, 262144 =
bytes)
[    0.000000] Enabling fast FPU save and restore... done.
[    0.000000] Enabling unmasked SIMD FPU exception support... done.
[    0.000000] Initializing CPU#0
[    0.000000] Memory: 870324k/914772k available (10785k kernel code, 4=
3808k reserved, 6038k data, 1928k init, 0k highmem)
[    0.000000] virtual kernel memory layout:
[    0.000000]     fixmap  : 0xffd57000 - 0xfffff000   (2720 kB)
[    0.000000]     vmalloc : 0xf8555000 - 0xffd55000   ( 120 MB)
[    0.000000]     lowmem  : 0xc0000000 - 0xf7d55000   ( 893 MB)
[    0.000000]       .init : 0xc2079000 - 0xc225b000   (1928 kB)
[    0.000000]       .data : 0xc1a885c3 - 0xc206dea4   (6038 kB)
[    0.000000]       .text : 0xc1000000 - 0xc1a885c3   (10785 kB)
[    0.000000] Checking if this processor honours the WP bit even in su=
pervisor mode...Ok.
[    0.000000] SLUB: Genslabs=3D13, HWalign=3D64, Order=3D0-3, MinObjec=
ts=3D0, CPUs=3D2, Nodes=3D1
[    0.000000] Hierarchical RCU implementation.
[    0.000000] RCU-based detection of stalled CPUs is enabled.
[    0.000000] NR_IRQS:1280
[    0.000000] CPU 0 irqstacks, hard=3Dc375f000 soft=3Dc3760000
[    0.000000] Fast TSC calibration using PIT
[    0.000000] Detected 2010.357 MHz processor.
[    0.000038] spurious 8259A interrupt: IRQ7.
[    0.005209] Console: colour VGA+ 80x25
[    0.008784] console [tty0] enabled
[    0.010000] Lock dependency validator: Copyright (c) 2006 Red Hat, I=
nc., Ingo Molnar
[    0.010000] ... MAX_LOCKDEP_SUBCLASSES:  8
[    0.010000] ... MAX_LOCK_DEPTH:          48
[    0.010000] ... MAX_LOCKDEP_KEYS:        8191
[    0.010000] ... CLASSHASH_SIZE:          4096
[    0.010000] ... MAX_LOCKDEP_ENTRIES:     16384
[    0.010000] ... MAX_LOCKDEP_CHAINS:      32768
[    0.010000] ... CHAINHASH_SIZE:          16384
[    0.010000]  memory used by lock dependency info: 3743 kB
[    0.010000]  per task-struct memory footprint: 1920 bytes
[    0.010000] ODEBUG: 0 of 0 active objects replaced
[    0.010033] Calibrating delay loop (skipped), value calculated using=
 timer frequency.. 4020.71 BogoMIPS (lpj=3D20103570)
[    0.020180] Security Framework initialized
[    0.024213] Mount-cache hash table entries: 512
[    0.031569] CPU: L1 I Cache: 64K (64 bytes/line), D cache 64K (64 by=
tes/line)
[    0.038587] CPU: L2 Cache: 512K (64 bytes/line)
[    0.040008] CPU: Physical Processor ID: 0
[    0.043976] CPU: Processor Core ID: 0
[    0.050009] Intel machine check architecture supported.
[    0.055753] Intel machine check reporting enabled on CPU#0.
[    0.060037] mce: CPU supports 5 MCE banks
[    0.063984] Performance Counters: AMD PMU driver.
[    0.070014] ... version:                 0
[    0.074063] ... bit width:               48
[    0.078220] ... generic counters:        4
[    0.080006] ... value mask:              0000ffffffffffff
[    0.085363] ... max period:              00007fffffffffff
[    0.090006] ... fixed-purpose counters:  0
[    0.094064] ... counter mask:            000000000000000f
[    0.100016] Checking 'hlt' instruction... OK.
[    0.142940] ACPI: Core revision 20090521
[    0.242530] ftrace: converting mcount calls to 0f 1f 44 00 00
[    0.248161] ftrace: allocating 45875 entries in 90 pages
[    0.260242] enabled ExtINT on CPU#0
[    0.270177] ENABLING IO-APIC IRQs
[    0.273370] init IO_APIC IRQs
[    0.276330] IOAPIC[0]: Set routing entry (2-0 -> 0x30 -> IRQ 0 Mode:=
0 Active:0)
[    0.280016] IOAPIC[0]: Set routing entry (2-1 -> 0x31 -> IRQ 1 Mode:=
0 Active:0)
[    0.290017] IOAPIC[0]: Set routing entry (2-3 -> 0x33 -> IRQ 3 Mode:=
0 Active:0)
[    0.297283] IOAPIC[0]: Set routing entry (2-4 -> 0x34 -> IRQ 4 Mode:=
0 Active:0)
[    0.300012] IOAPIC[0]: Set routing entry (2-5 -> 0x35 -> IRQ 5 Mode:=
0 Active:0)
[    0.310014] IOAPIC[0]: Set routing entry (2-6 -> 0x36 -> IRQ 6 Mode:=
0 Active:0)
[    0.320013] IOAPIC[0]: Set routing entry (2-7 -> 0x37 -> IRQ 7 Mode:=
0 Active:0)
[    0.327282] IOAPIC[0]: Set routing entry (2-8 -> 0x38 -> IRQ 8 Mode:=
0 Active:0)
[    0.330012] IOAPIC[0]: Set routing entry (2-9 -> 0x39 -> IRQ 9 Mode:=
1 Active:0)
[    0.340013] IOAPIC[0]: Set routing entry (2-10 -> 0x3a -> IRQ 10 Mod=
e:0 Active:0)
[    0.350014] IOAPIC[0]: Set routing entry (2-11 -> 0x3b -> IRQ 11 Mod=
e:0 Active:0)
[    0.357455] IOAPIC[0]: Set routing entry (2-12 -> 0x3c -> IRQ 12 Mod=
e:0 Active:0)
[    0.360012] IOAPIC[0]: Set routing entry (2-13 -> 0x3d -> IRQ 13 Mod=
e:0 Active:0)
[    0.370012] IOAPIC[0]: Set routing entry (2-14 -> 0x3e -> IRQ 14 Mod=
e:0 Active:0)
[    0.380012] IOAPIC[0]: Set routing entry (2-15 -> 0x3f -> IRQ 15 Mod=
e:0 Active:0)
[    0.387450]  2-16 2-17 2-18 2-19 2-20 2-21 2-22 2-23 (apicid-pin) no=
t connected
[    0.394915] ..TIMER: vector=3D0x30 apic1=3D0 pin1=3D0 apic2=3D-1 pin=
2=3D-1
[    0.501245] CPU0: AMD Athlon(tm) 64 X2 Dual Core Processor 3800+ ste=
pping 02
[    0.508140] Using local APIC timer interrupts.
[    0.508141] calibrating APIC timer ...
[    0.520000] ... lapic delta =3D 1256460
[    0.520000] ... PM-Timer delta =3D 357961
[    0.520000] ... PM-Timer result ok
[    0.520000] ..... delta 1256460
[    0.520000] ..... mult: 53964546
[    0.520000] ..... calibration result: 2010336
[    0.520000] ..... CPU clock speed is 2010.3360 MHz.
[    0.520000] ..... host bus clock speed is 201.0336 MHz.
[    0.520026] calling  migration_init+0x0/0x4b @ 1
[    0.524734] initcall migration_init+0x0/0x4b returned 1 after 0 usec=
s
[    0.530090] initcall migration_init+0x0/0x4b returned with error cod=
e 1=20
[    0.536672] calling  spawn_ksoftirqd+0x0/0x47 @ 1
[    0.540165] initcall spawn_ksoftirqd+0x0/0x47 returned 0 after 0 use=
cs
[    0.546574] calling  init_call_single_data+0x0/0x86 @ 1
[    0.550090] initcall init_call_single_data+0x0/0x86 returned 0 after=
 0 usecs
[    0.560085] calling  spawn_softlockup_task+0x0/0x5f @ 1
[    0.572351] initcall spawn_softlockup_task+0x0/0x5f returned 0 after=
 9765 usecs
[    0.579569] calling  relay_init+0x0/0x11 @ 1
[    0.580006] initcall relay_init+0x0/0x11 returned 0 after 0 usecs
[    0.586062] calling  tracer_alloc_buffers+0x0/0x18d @ 1
[    0.590171] Testing tracer nop: PASSED
[    0.593778] initcall tracer_alloc_buffers+0x0/0x18d returned 0 after=
 0 usecs
[    0.600005] calling  init_trace_printk+0x0/0x7 @ 1
[    0.610004] initcall init_trace_printk+0x0/0x7 returned 0 after 0 us=
ecs
[    0.616959] lockdep: fixing up alternatives.
[    0.620119] CPU 1 irqstacks, hard=3Dc38b0000 soft=3Dc38b1000
[    0.625311] Booting processor 1 APIC 0x1 ip 0x6000
[    0.010000] Initializing CPU#1
[    0.010000] masked ExtINT on CPU#1
[    0.010000] Calibrating delay using timer specific routine.. 4020.72=
 BogoMIPS (lpj=3D20103622)
[    0.010000] CPU: L1 I Cache: 64K (64 bytes/line), D cache 64K (64 by=
tes/line)
[    0.010000] CPU: L2 Cache: 512K (64 bytes/line)
[    0.010000] CPU: Physical Processor ID: 0
[    0.010000] CPU: Processor Core ID: 1
[    0.010000] Intel machine check architecture supported.
[    0.010000] Intel machine check reporting enabled on CPU#1.
[    0.010000] mce: CPU supports 5 MCE banks
[    0.010000] x86 PAT enabled: cpu 1, old 0x7040600070406, new 0x70106=
00070106
[    0.790547] CPU1: AMD Athlon(tm) 64 X2 Dual Core Processor 3800+ ste=
pping 02
[    0.811351] Brought up 2 CPUs
[    0.814200] Total of 2 processors activated (8041.43 BogoMIPS).
[    0.820122] CPU0 attaching sched-domain:
[    0.823922]  domain 0: span 0-1 level CPU
[    0.830003]   groups: 0 1
[    0.832612] CPU1 attaching sched-domain:
[    0.836493]  domain 0: span 0-1 level CPU
[    0.840003]   groups: 1 0
[    0.843126] device: 'platform': device_add
[    0.847167] PM: Adding info for No Bus:platform
[    0.850708] bus: 'platform': registered
[    0.854439] Registering sysdev class 'cpu'
[    0.860873] calling  net_ns_init+0x0/0xc8 @ 1
[    0.865281] initcall net_ns_init+0x0/0xc8 returned 0 after 0 usecs
[    0.870020] calling  reboot_init+0x0/0x11 @ 1
[    0.874335] initcall reboot_init+0x0/0x11 returned 0 after 0 usecs
[    0.880004] calling  init_lapic_sysfs+0x0/0x28 @ 1
[    0.884761] Registering sysdev class 'lapic'
[    0.890191] Registering sys device of class 'lapic'
[    0.894968] Registering sys device 'lapic0'
[    0.900236] initcall init_lapic_sysfs+0x0/0x28 returned 0 after 1953=
1 usecs
[    0.907075] calling  print_banner+0x0/0xd @ 1
[    0.910007] Booting paravirtualized kernel on bare hardware
[    0.915542] initcall print_banner+0x0/0xd returned 0 after 0 usecs
[    0.920005] calling  init_smp_flush+0x0/0x2f @ 1
[    0.924590] initcall init_smp_flush+0x0/0x2f returned 0 after 0 usec=
s
[    0.930006] calling  alloc_frozen_cpus+0x0/0xc @ 1
[    0.934763] initcall alloc_frozen_cpus+0x0/0xc returned 0 after 0 us=
ecs
[    0.940004] calling  sysctl_init+0x0/0x13 @ 1
[    0.950009] initcall sysctl_init+0x0/0x13 returned 0 after 0 usecs
[    0.956148] calling  ksysfs_init+0x0/0x96 @ 1
[    0.960065] initcall ksysfs_init+0x0/0x96 returned 0 after 0 usecs
[    0.966148] calling  async_init+0x0/0x3c @ 1
[    0.970005] initcall async_init+0x0/0x3c returned 0 after 0 usecs
[    0.976062] calling  init_jiffies_clocksource+0x0/0xf @ 1
[    0.980015] initcall init_jiffies_clocksource+0x0/0xf returned 0 aft=
er 0 usecs
[    0.987188] calling  pm_init+0x0/0x2d @ 1
[    0.990042] initcall pm_init+0x0/0x2d returned 0 after 0 usecs
[    0.995803] calling  init_hw_breakpoint+0x0/0xf @ 1
[    1.000006] initcall init_hw_breakpoint+0x0/0xf returned 0 after 0 u=
secs
[    1.010005] calling  filelock_init+0x0/0x27 @ 1
[    1.014510] initcall filelock_init+0x0/0x27 returned 0 after 0 usecs
[    1.020005] calling  init_misc_binfmt+0x0/0x35 @ 1
[    1.024780] initcall init_misc_binfmt+0x0/0x35 returned 0 after 0 us=
ecs
[    1.030006] calling  init_script_binfmt+0x0/0x11 @ 1
[    1.034937] initcall init_script_binfmt+0x0/0x11 returned 0 after 0 =
usecs
[    1.040005] calling  init_elf_binfmt+0x0/0x11 @ 1
[    1.044678] initcall init_elf_binfmt+0x0/0x11 returned 0 after 0 use=
cs
[    1.050005] calling  debugfs_init+0x0/0x4a @ 1
[    1.060024] initcall debugfs_init+0x0/0x4a returned 0 after 0 usecs
[    1.066236] calling  securityfs_init+0x0/0x41 @ 1
[    1.070025] initcall securityfs_init+0x0/0x41 returned 0 after 0 use=
cs
[    1.076495] calling  random32_init+0x0/0xa8 @ 1
[    1.080005] initcall random32_init+0x0/0xa8 returned 0 after 0 usecs
[    1.086323] calling  gnttab_init+0x0/0x171 @ 1
[    1.090005] initcall gnttab_init+0x0/0x171 returned -19 after 0 usec=
s
[    1.096409] calling  regulator_init+0x0/0x23 @ 1
[    1.100003] regulator: core version 0.5
[    1.103808] device class 'regulator': registering
[    1.110203] initcall regulator_init+0x0/0x23 returned 0 after 9765 u=
secs
[    1.116781] calling  early_resume_init+0x0/0x16 @ 1
[    1.120025] Time: 13:17:57  Date: 07/02/09
[    1.124070] initcall early_resume_init+0x0/0x16 returned 0 after 0 u=
secs
[    1.130005] calling  cpuidle_init+0x0/0x32 @ 1
[    1.134440] initcall cpuidle_init+0x0/0x32 returned 0 after 0 usecs
[    1.140006] calling  virtio_init+0x0/0x24 @ 1
[    1.150249] bus: 'virtio': registered
[    1.153793] initcall virtio_init+0x0/0x24 returned 0 after 0 usecs
[    1.160010] calling  sock_init+0x0/0x51 @ 1
[    1.164363] initcall sock_init+0x0/0x51 returned 0 after 0 usecs
[    1.170004] calling  net_inuse_init+0x0/0x1f @ 1
[    1.174602] initcall net_inuse_init+0x0/0x1f returned 0 after 0 usec=
s
[    1.180004] calling  netpoll_init+0x0/0x39 @ 1
[    1.184417] initcall netpoll_init+0x0/0x39 returned 0 after 0 usecs
[    1.190004] calling  netlink_proto_init+0x0/0x15d @ 1
[    1.195158] NET: Registered protocol family 16
[    1.200088] initcall netlink_proto_init+0x0/0x15d returned 0 after 9=
765 usecs
[    1.207102] calling  olpc_init+0x0/0x102 @ 1
[    1.210005] initcall olpc_init+0x0/0x102 returned 0 after 0 usecs
[    1.216063] calling  bdi_class_init+0x0/0x35 @ 1
[    1.220007] device class 'bdi': registering
[    1.224540] initcall bdi_class_init+0x0/0x35 returned 0 after 0 usec=
s
[    1.230009] calling  kobject_uevent_init+0x0/0x4e @ 1
[    1.235040] initcall kobject_uevent_init+0x0/0x4e returned 0 after 0=
 usecs
[    1.240005] calling  pcibus_class_init+0x0/0x14 @ 1
[    1.250003] device class 'pci_bus': registering
[    1.254716] initcall pcibus_class_init+0x0/0x14 returned 0 after 0 u=
secs
[    1.260016] calling  pci_driver_init+0x0/0xf @ 1
[    1.264852] bus: 'pci': registered
[    1.270006] initcall pci_driver_init+0x0/0xf returned 0 after 9765 u=
secs
[    1.276668] calling  backlight_class_init+0x0/0x4d @ 1
[    1.280012] device class 'backlight': registering
[    1.284881] initcall backlight_class_init+0x0/0x4d returned 0 after =
0 usecs
[    1.290010] calling  video_output_class_init+0x0/0x14 @ 1
[    1.300003] device class 'video_output': registering
[    1.305139] initcall video_output_class_init+0x0/0x14 returned 0 aft=
er 0 usecs
[    1.310005] calling  xenbus_probe_init+0x0/0xde @ 1
[    1.314850] initcall xenbus_probe_init+0x0/0xde returned -19 after 0=
 usecs
[    1.320009] calling  tty_class_init+0x0/0x28 @ 1
[    1.324592] device class 'tty': registering
[    1.330209] initcall tty_class_init+0x0/0x28 returned 0 after 9765 u=
secs
[    1.336789] calling  vtconsole_class_init+0x0/0xa1 @ 1
[    1.340012] device class 'vtconsole': registering
[    1.344894] device: 'vtcon0': device_add
[    1.350073] PM: Adding info for No Bus:vtcon0
[    1.354566] initcall vtconsole_class_init+0x0/0xa1 returned 0 after =
9765 usecs
[    1.360011] calling  spi_init+0x0/0xae @ 1
[    1.364331] bus: 'spi': registered
[    1.370004] device class 'spi_master': registering
[    1.374968] initcall spi_init+0x0/0xae returned 0 after 9765 usecs
[    1.380014] calling  i2c_init+0x0/0x54 @ 1
[    1.384327] bus: 'i2c': registered
[    1.390004] device class 'i2c-adapter': registering
[    1.395057] bus: 'i2c': add driver dummy
[    1.400232] i2c-core: driver [dummy] registered
[    1.404664] initcall i2c_init+0x0/0x54 returned 0 after 19531 usecs
[    1.410009] calling  amd_postcore_init+0x0/0x66 @ 1
[    1.414850] initcall amd_postcore_init+0x0/0x66 returned 0 after 0 u=
secs
[    1.420006] calling  arch_kdebugfs_init+0x0/0x28 @ 1
[    1.425022] initcall arch_kdebugfs_init+0x0/0x28 returned 0 after 0 =
usecs
[    1.430004] calling  init_pit_clocksource+0x0/0x95 @ 1
[    1.435109] initcall init_pit_clocksource+0x0/0x95 returned 0 after =
0 usecs
[    1.440006] calling  mtrr_if_init+0x0/0x44 @ 1
[    1.450018] initcall mtrr_if_init+0x0/0x44 returned 0 after 0 usecs
[    1.456236] calling  ffh_cstate_init+0x0/0x27 @ 1
[    1.460005] initcall ffh_cstate_init+0x0/0x27 returned -1 after 0 us=
ecs
[    1.466581] initcall ffh_cstate_init+0x0/0x27 returned with error co=
de -1=20
[    1.470005] calling  acpi_pci_init+0x0/0x4c @ 1
[    1.474514] ACPI: bus type pci registered
[    1.480044] initcall acpi_pci_init+0x0/0x4c returned 0 after 9765 us=
ecs
[    1.490004] calling  setup_vcpu_hotplug_event+0x0/0x1f @ 1
[    1.495456] initcall setup_vcpu_hotplug_event+0x0/0x1f returned -19 =
after 0 usecs
[    1.500005] calling  dmi_id_init+0x0/0xd2 @ 1
[    1.504329] device class 'dmi': registering
[    1.510226] device: 'id': device_add
[    1.513843] PM: Adding info for No Bus:id
[    1.518028] initcall dmi_id_init+0x0/0xd2 returned 0 after 9765 usec=
s
[    1.520013] calling  pci_arch_init+0x0/0x33 @ 1
[    1.534590] PCI: PCI BIOS revision 3.00 entry at 0xf21d0, last bus=3D=
5
[    1.540015] initcall pci_arch_init+0x0/0x33 returned 0 after 9765 us=
ecs
[    1.546583] calling  topology_init+0x0/0x36 @ 1
[    1.550003] Registering sys device of class 'cpu'
[    1.554693] Registering sys device 'cpu0'
[    1.560201] Registering sys device of class 'cpu'
[    1.564803] Registering sys device 'cpu1'
[    1.570230] initcall topology_init+0x0/0x36 returned 0 after 19531 u=
secs
[    1.576805] calling  mtrr_init_finialize+0x0/0x35 @ 1
[    1.580009] initcall mtrr_init_finialize+0x0/0x35 returned 0 after 0=
 usecs
[    1.586840] calling  param_sysfs_init+0x0/0xb3 @ 1
[    1.714335] initcall param_sysfs_init+0x0/0xb3 returned 0 after 1171=
87 usecs
[    1.720141] calling  pm_sysrq_init+0x0/0x1b @ 1
[    1.724571] initcall pm_sysrq_init+0x0/0x1b returned 0 after 0 usecs
[    1.730085] calling  init_slow_work+0x0/0x2f @ 1
[    1.734590] initcall init_slow_work+0x0/0x2f returned 0 after 0 usec=
s
[    1.740083] calling  default_bdi_init+0x0/0x2f @ 1
[    1.744788] device: 'default': device_add
[    1.750145] PM: Adding info for No Bus:default
[    1.754739] initcall default_bdi_init+0x0/0x2f returned 0 after 9765=
 usecs
[    1.760155] calling  init_bio+0x0/0xed @ 1
[    1.764926] bio: create slab <bio-0> at 0
[    1.770072] initcall init_bio+0x0/0xed returned 0 after 9765 usecs
[    1.776149] calling  cryptomgr_init+0x0/0xf @ 1
[    1.780005] initcall cryptomgr_init+0x0/0xf returned 0 after 0 usecs
[    1.786321] calling  blk_settings_init+0x0/0x1d @ 1
[    1.790034] initcall blk_settings_init+0x0/0x1d returned 0 after 0 u=
secs
[    1.800006] calling  blk_ioc_init+0x0/0x24 @ 1
[    1.804423] initcall blk_ioc_init+0x0/0x24 returned 0 after 0 usecs
[    1.810004] calling  blk_softirq_init+0x0/0x56 @ 1
[    1.814766] initcall blk_softirq_init+0x0/0x56 returned 0 after 0 us=
ecs
[    1.820006] calling  genhd_device_init+0x0/0x50 @ 1
[    1.824849] device class 'block': registering
[    1.830219] initcall genhd_device_init+0x0/0x50 returned 0 after 976=
5 usecs
[    1.837058] calling  blk_dev_integrity_init+0x0/0x24 @ 1
[    1.840033] initcall blk_dev_integrity_init+0x0/0x24 returned 0 afte=
r 0 usecs
[    1.850006] calling  pci_slot_init+0x0/0x40 @ 1
[    1.854527] initcall pci_slot_init+0x0/0x40 returned 0 after 0 usecs
[    1.860005] calling  fbmem_init+0x0/0x78 @ 1
[    1.864297] device class 'graphics': registering
[    1.870224] initcall fbmem_init+0x0/0x78 returned 0 after 9765 usecs
[    1.876452] calling  acpi_init+0x0/0x113 @ 1
[    1.885994] ACPI: EC: Look up EC in DSDT
[    2.005169] ACPI: Interpreter enabled
[    2.008717] ACPI: (supports S0 S5)
[    2.010540] ACPI: Using IOAPIC for interrupt routing
[    2.015988] bus: 'acpi': registered
[    2.020209] device: 'LNXSYSTM:00': device_add
[    2.024481] bus: 'acpi': add device LNXSYSTM:00
[    2.029011] PM: Adding info for acpi:LNXSYSTM:00
[    2.030287] device: 'LNXPWRBN:00': device_add
[    2.034549] bus: 'acpi': add device LNXPWRBN:00
[    2.052782] PM: Adding info for acpi:LNXPWRBN:00
[    2.057645] device: 'LNXCPU:00': device_add
[    2.060028] bus: 'acpi': add device LNXCPU:00
[    2.064385] PM: Adding info for acpi:LNXCPU:00
[    2.070376] device: 'LNXCPU:01': device_add
[    2.074461] bus: 'acpi': add device LNXCPU:01
[    2.078823] PM: Adding info for acpi:LNXCPU:01
[    2.080563] device: 'device:00': device_add
[    2.084644] bus: 'acpi': add device device:00
[    2.090057] PM: Adding info for acpi:device:00
[    2.094429] device: 'device:00': dev_uevent: bus uevent() returned -=
12
[    2.100634] device: 'PNP0C0C:00': device_add
[    2.104807] bus: 'acpi': add device PNP0C0C:00
[    2.110152] PM: Adding info for acpi:PNP0C0C:00
[    2.115711] device: 'PNP0A08:00': device_add
[    2.120063] bus: 'acpi': add device PNP0A08:00
[    2.124487] PM: Adding info for acpi:PNP0A08:00
[    2.130580] device: 'PNP0C02:00': device_add
[    2.134748] bus: 'acpi': add device PNP0C02:00
[    2.140137] PM: Adding info for acpi:PNP0C02:00
[    2.145532] device: 'device:01': device_add
[    2.150024] bus: 'acpi': add device device:01
[    2.154383] PM: Adding info for acpi:device:01
[    2.158758] device: 'device:01': dev_uevent: bus uevent() returned -=
12
[    2.160401] device: 'device:02': device_add
[    2.170024] bus: 'acpi': add device device:02
[    2.174383] PM: Adding info for acpi:device:02
[    2.178758] device: 'device:02': dev_uevent: bus uevent() returned -=
12
[    2.180351] device: 'device:03': device_add
[    2.184435] bus: 'acpi': add device device:03
[    2.190060] PM: Adding info for acpi:device:03
[    2.194428] device: 'device:03': dev_uevent: bus uevent() returned -=
12
[    2.200359] device: 'device:04': device_add
[    2.204443] bus: 'acpi': add device device:04
[    2.210058] PM: Adding info for acpi:device:04
[    2.214428] device: 'device:04': dev_uevent: bus uevent() returned -=
12
[    2.220361] device: 'device:05': device_add
[    2.224444] bus: 'acpi': add device device:05
[    2.230059] PM: Adding info for acpi:device:05
[    2.234427] device: 'device:05': dev_uevent: bus uevent() returned -=
12
[    2.240362] device: 'device:06': device_add
[    2.244443] bus: 'acpi': add device device:06
[    2.250058] PM: Adding info for acpi:device:06
[    2.254428] device: 'device:06': dev_uevent: bus uevent() returned -=
12
[    2.260365] device: 'device:07': device_add
[    2.264452] bus: 'acpi': add device device:07
[    2.270061] PM: Adding info for acpi:device:07
[    2.274427] device: 'device:07': dev_uevent: bus uevent() returned -=
12
[    2.280355] device: 'device:08': device_add
[    2.284436] bus: 'acpi': add device device:08
[    2.290058] PM: Adding info for acpi:device:08
[    2.294427] device: 'device:08': dev_uevent: bus uevent() returned -=
12
[    2.300362] device: 'device:09': device_add
[    2.304444] bus: 'acpi': add device device:09
[    2.310060] PM: Adding info for acpi:device:09
[    2.314428] device: 'device:09': dev_uevent: bus uevent() returned -=
12
[    2.320369] device: 'device:0a': device_add
[    2.324453] bus: 'acpi': add device device:0a
[    2.330057] PM: Adding info for acpi:device:0a
[    2.334428] device: 'device:0a': dev_uevent: bus uevent() returned -=
12
[    2.340362] device: 'device:0b': device_add
[    2.344444] bus: 'acpi': add device device:0b
[    2.350062] PM: Adding info for acpi:device:0b
[    2.354428] device: 'device:0b': dev_uevent: bus uevent() returned -=
12
[    2.360367] device: 'device:0c': device_add
[    2.364456] bus: 'acpi': add device device:0c
[    2.370058] PM: Adding info for acpi:device:0c
[    2.374427] device: 'device:0c': dev_uevent: bus uevent() returned -=
12
[    2.380388] device: 'device:0d': device_add
[    2.384469] bus: 'acpi': add device device:0d
[    2.390060] PM: Adding info for acpi:device:0d
[    2.394428] device: 'device:0d': dev_uevent: bus uevent() returned -=
12
[    2.400357] device: 'device:0e': device_add
[    2.404445] bus: 'acpi': add device device:0e
[    2.410058] PM: Adding info for acpi:device:0e
[    2.414428] device: 'device:0e': dev_uevent: bus uevent() returned -=
12
[    2.420357] device: 'device:0f': device_add
[    2.424443] bus: 'acpi': add device device:0f
[    2.430061] PM: Adding info for acpi:device:0f
[    2.434427] device: 'device:0f': dev_uevent: bus uevent() returned -=
12
[    2.440362] device: 'device:10': device_add
[    2.444444] bus: 'acpi': add device device:10
[    2.450057] PM: Adding info for acpi:device:10
[    2.454429] device: 'device:10': dev_uevent: bus uevent() returned -=
12
[    2.460355] device: 'device:11': device_add
[    2.464435] bus: 'acpi': add device device:11
[    2.470060] PM: Adding info for acpi:device:11
[    2.474427] device: 'device:11': dev_uevent: bus uevent() returned -=
12
[    2.480358] device: 'device:12': device_add
[    2.484444] bus: 'acpi': add device device:12
[    2.488808] PM: Adding info for acpi:device:12
[    2.490016] device: 'device:12': dev_uevent: bus uevent() returned -=
12
[    2.500520] device: 'device:13': device_add
[    2.504600] bus: 'acpi': add device device:13
[    2.508964] PM: Adding info for acpi:device:13
[    2.510018] device: 'device:13': dev_uevent: bus uevent() returned -=
12
[    2.520515] device: 'device:14': device_add
[    2.524600] bus: 'acpi': add device device:14
[    2.528965] PM: Adding info for acpi:device:14
[    2.530016] device: 'device:14': dev_uevent: bus uevent() returned -=
12
[    2.540514] device: 'device:15': device_add
[    2.544600] bus: 'acpi': add device device:15
[    2.548965] PM: Adding info for acpi:device:15
[    2.550018] device: 'device:15': dev_uevent: bus uevent() returned -=
12
[    2.560516] device: 'device:16': device_add
[    2.564600] bus: 'acpi': add device device:16
[    2.568969] PM: Adding info for acpi:device:16
[    2.570016] device: 'device:16': dev_uevent: bus uevent() returned -=
12
[    2.580358] device: 'device:17': device_add
[    2.584444] bus: 'acpi': add device device:17
[    2.588810] PM: Adding info for acpi:device:17
[    2.590018] device: 'device:17': dev_uevent: bus uevent() returned -=
12
[    2.600189] device: 'device:18': device_add
[    2.604270] bus: 'acpi': add device device:18
[    2.608636] PM: Adding info for acpi:device:18
[    2.610016] device: 'device:18': dev_uevent: bus uevent() returned -=
12
[    2.620420] device: 'device:19': device_add
[    2.624506] bus: 'acpi': add device device:19
[    2.628870] PM: Adding info for acpi:device:19
[    2.630019] device: 'device:19': dev_uevent: bus uevent() returned -=
12
[    2.640884] device: 'device:1a': device_add
[    2.644968] bus: 'acpi': add device device:1a
[    2.649333] PM: Adding info for acpi:device:1a
[    2.650017] device: 'device:1a': dev_uevent: bus uevent() returned -=
12
[    2.660521] device: 'device:1b': device_add
[    2.664609] bus: 'acpi': add device device:1b
[    2.668974] PM: Adding info for acpi:device:1b
[    2.670018] device: 'device:1b': dev_uevent: bus uevent() returned -=
12
[    2.680697] device: 'device:1c': device_add
[    2.684781] bus: 'acpi': add device device:1c
[    2.689147] PM: Adding info for acpi:device:1c
[    2.690016] device: 'device:1c': dev_uevent: bus uevent() returned -=
12
[    2.700704] device: 'device:1d': device_add
[    2.704793] bus: 'acpi': add device device:1d
[    2.709156] PM: Adding info for acpi:device:1d
[    2.710018] device: 'device:1d': dev_uevent: bus uevent() returned -=
12
[    2.720727] device: 'ATK0110:00': device_add
[    2.724894] bus: 'acpi': add device ATK0110:00
[    2.729345] PM: Adding info for acpi:ATK0110:00
[    2.731254] device: 'PNP0C0F:00': device_add
[    2.735422] bus: 'acpi': add device PNP0C0F:00
[    2.740062] PM: Adding info for acpi:PNP0C0F:00
[    2.745491] device: 'PNP0C0F:01': device_add
[    2.750025] bus: 'acpi': add device PNP0C0F:01
[    2.754469] PM: Adding info for acpi:PNP0C0F:01
[    2.762328] device: 'PNP0C0F:02': device_add
[    2.766506] bus: 'acpi': add device PNP0C0F:02
[    2.770060] PM: Adding info for acpi:PNP0C0F:02
[    2.775508] device: 'PNP0C0F:03': device_add
[    2.780027] bus: 'acpi': add device PNP0C0F:03
[    2.784469] PM: Adding info for acpi:PNP0C0F:03
[    2.791013] device: 'PNP0C0F:04': device_add
[    2.795180] bus: 'acpi': add device PNP0C0F:04
[    2.800136] PM: Adding info for acpi:PNP0C0F:04
[    2.805549] device: 'PNP0C0F:05': device_add
[    2.810024] bus: 'acpi': add device PNP0C0F:05
[    2.814470] PM: Adding info for acpi:PNP0C0F:05
[    2.821083] device: 'PNP0C0F:06': device_add
[    2.825258] bus: 'acpi': add device PNP0C0F:06
[    2.829709] PM: Adding info for acpi:PNP0C0F:06
[    2.830985] device: 'PNP0C0F:07': device_add
[    2.835154] bus: 'acpi': add device PNP0C0F:07
[    2.840143] PM: Adding info for acpi:PNP0C0F:07
[    2.845537] device: 'PNP0C0F:08': device_add
[    2.850086] bus: 'acpi': add device PNP0C0F:08
[    2.854469] PM: Adding info for acpi:PNP0C0F:08
[    2.861002] device: 'PNP0C0F:09': device_add
[    2.865173] bus: 'acpi': add device PNP0C0F:09
[    2.870063] PM: Adding info for acpi:PNP0C0F:09
[    2.875509] device: 'PNP0C0F:0a': device_add
[    2.880026] bus: 'acpi': add device PNP0C0F:0a
[    2.884470] PM: Adding info for acpi:PNP0C0F:0a
[    2.891084] device: 'PNP0C0F:0b': device_add
[    2.895260] bus: 'acpi': add device PNP0C0F:0b
[    2.900127] PM: Adding info for acpi:PNP0C0F:0b
[    2.905534] device: 'PNP0C0F:0c': device_add
[    2.909709] bus: 'acpi': add device PNP0C0F:0c
[    2.910062] PM: Adding info for acpi:PNP0C0F:0c
[    2.915508] device: 'PNP0C0F:0d': device_add
[    2.920106] bus: 'acpi': add device PNP0C0F:0d
[    2.924488] PM: Adding info for acpi:PNP0C0F:0d
[    2.931052] device: 'PNP0C0F:0e': device_add
[    2.935226] bus: 'acpi': add device PNP0C0F:0e
[    2.940131] PM: Adding info for acpi:PNP0C0F:0e
[    2.945546] device: 'PNP0C0F:0f': device_add
[    2.950025] bus: 'acpi': add device PNP0C0F:0f
[    2.954470] PM: Adding info for acpi:PNP0C0F:0f
[    2.961235] device: 'PNP0C0F:10': device_add
[    2.965407] bus: 'acpi': add device PNP0C0F:10
[    2.970133] PM: Adding info for acpi:PNP0C0F:10
[    2.975673] device: 'PNP0C0F:11': device_add
[    2.980026] bus: 'acpi': add device PNP0C0F:11
[    2.984471] PM: Adding info for acpi:PNP0C0F:11
[    2.990994] device: 'PNP0C0F:12': device_add
[    2.995165] bus: 'acpi': add device PNP0C0F:12
[    2.999616] PM: Adding info for acpi:PNP0C0F:12
[    3.001221] device: 'PNP0C0F:13': device_add
[    3.005397] bus: 'acpi': add device PNP0C0F:13
[    3.010065] PM: Adding info for acpi:PNP0C0F:13
[    3.015641] device: 'PNP0C0F:14': device_add
[    3.020105] bus: 'acpi': add device PNP0C0F:14
[    3.024486] PM: Adding info for acpi:PNP0C0F:14
[    3.031214] device: 'PNP0C0F:15': device_add
[    3.035389] bus: 'acpi': add device PNP0C0F:15
[    3.040140] PM: Adding info for acpi:PNP0C0F:15
[    3.045695] device: 'PNP0C0F:16': device_add
[    3.050026] bus: 'acpi': add device PNP0C0F:16
[    3.054470] PM: Adding info for acpi:PNP0C0F:16
[    3.061200] device: 'PNP0C0F:17': device_add
[    3.065372] bus: 'acpi': add device PNP0C0F:17
[    3.070064] PM: Adding info for acpi:PNP0C0F:17
[    3.075625] device: 'PNP0C0F:18': device_add
[    3.080104] bus: 'acpi': add device PNP0C0F:18
[    3.084480] PM: Adding info for acpi:PNP0C0F:18
[    3.090839] device: 'PNP0C0F:19': device_add
[    3.095013] bus: 'acpi': add device PNP0C0F:19
[    3.099463] PM: Adding info for acpi:PNP0C0F:19
[    3.101251] device: 'PNP0C0F:1a': device_add
[    3.105424] bus: 'acpi': add device PNP0C0F:1a
[    3.110150] PM: Adding info for acpi:PNP0C0F:1a
[    3.115711] device: 'PNP0C0F:1b': device_add
[    3.120111] bus: 'acpi': add device PNP0C0F:1b
[    3.124488] PM: Adding info for acpi:PNP0C0F:1b
[    3.131148] device: 'PNP0C0F:1c': device_add
[    3.135321] bus: 'acpi': add device PNP0C0F:1c
[    3.140063] PM: Adding info for acpi:PNP0C0F:1c
[    3.145641] device: 'PNP0C0F:1d': device_add
[    3.150026] bus: 'acpi': add device PNP0C0F:1d
[    3.154472] PM: Adding info for acpi:PNP0C0F:1d
[    3.161241] device: 'PNP0C0F:1e': device_add
[    3.165417] bus: 'acpi': add device PNP0C0F:1e
[    3.170149] PM: Adding info for acpi:PNP0C0F:1e
[    3.175710] device: 'PNP0C0F:1f': device_add
[    3.180026] bus: 'acpi': add device PNP0C0F:1f
[    3.184470] PM: Adding info for acpi:PNP0C0F:1f
[    3.190306] device: 'PNP0C02:01': device_add
[    3.194479] bus: 'acpi': add device PNP0C02:01
[    3.198930] PM: Adding info for acpi:PNP0C02:01
[    3.200641] device: 'PNP0000:00': device_add
[    3.204817] bus: 'acpi': add device PNP0000:00
[    3.210075] PM: Adding info for acpi:PNP0000:00
[    3.215058] device: 'PNP0200:00': device_add
[    3.220026] bus: 'acpi': add device PNP0200:00
[    3.224471] PM: Adding info for acpi:PNP0200:00
[    3.230619] device: 'PNP0100:00': device_add
[    3.234792] bus: 'acpi': add device PNP0100:00
[    3.240056] PM: Adding info for acpi:PNP0100:00
[    3.245031] device: 'PNP0B00:00': device_add
[    3.249204] bus: 'acpi': add device PNP0B00:00
[    3.250095] PM: Adding info for acpi:PNP0B00:00
[    3.255052] device: 'PNP0800:00': device_add
[    3.260025] bus: 'acpi': add device PNP0800:00
[    3.265042] PM: Adding info for acpi:PNP0800:00
[    3.270602] device: 'PNP0C04:00': device_add
[    3.274776] bus: 'acpi': add device PNP0C04:00
[    3.280096] PM: Adding info for acpi:PNP0C04:00
[    3.286795] device: 'PNP0700:00': device_add
[    3.290027] bus: 'acpi': add device PNP0700:00
[    3.294472] PM: Adding info for acpi:PNP0700:00
[    3.302676] device: 'PNP0501:00': device_add
[    3.306855] bus: 'acpi': add device PNP0501:00
[    3.310142] PM: Adding info for acpi:PNP0501:00
[    3.322449] device: 'PNP0401:00': device_add
[    3.326625] bus: 'acpi': add device PNP0401:00
[    3.330142] PM: Adding info for acpi:PNP0401:00
[    3.335630] device: 'PNP0F13:00': device_add
[    3.340026] bus: 'acpi': add device PNP0F13:00
[    3.344470] PM: Adding info for acpi:PNP0F13:00
[    3.350926] device: 'PNP0303:00': device_add
[    3.355095] bus: 'acpi': add device PNP0303:00
[    3.359546] PM: Adding info for acpi:PNP0303:00
[    3.362915] device: 'PNPB006:00': device_add
[    3.370027] bus: 'acpi': add device PNPB006:00
[    3.374470] PM: Adding info for acpi:PNPB006:00
[    3.382349] device: 'PNPB02F:00': device_add
[    3.386526] bus: 'acpi': add device PNPB02F:00
[    3.390059] PM: Adding info for acpi:PNPB02F:00
[    3.395079] device: 'PNP0C02:02': device_add
[    3.400026] bus: 'acpi': add device PNP0C02:02
[    3.404471] PM: Adding info for acpi:PNP0C02:02
[    3.409529] device: 'PNP0C01:00': device_add
[    3.410107] bus: 'acpi': add device PNP0C01:00
[    3.414489] PM: Adding info for acpi:PNP0C01:00
[    3.420540] device: 'LNXTHERM:00': device_add
[    3.424801] bus: 'acpi': add device LNXTHERM:00
[    3.430089] PM: Adding info for acpi:LNXTHERM:00
[    3.435135] device: 'PNP0C0B:00': device_add
[    3.440028] bus: 'acpi': add device PNP0C0B:00
[    3.444472] PM: Adding info for acpi:PNP0C0B:00
[    3.450347] device: 'LNXTHERM:01': device_add
[    3.454600] bus: 'acpi': add device LNXTHERM:01
[    3.459138] PM: Adding info for acpi:LNXTHERM:01
[    3.460945] bus: 'acpi': add driver ec
[    3.464869] bus: 'acpi': add driver power
[    3.470561] initcall acpi_init+0x0/0x113 returned 0 after 1552734 us=
ecs
[    3.477059] calling  acpi_pci_root_init+0x0/0x25 @ 1
[    3.480023] bus: 'acpi': add driver pci_root
[    3.484272] bus: 'acpi': driver_probe_device: matched device PNP0A08=
:00 with driver pci_root
[    3.490004] bus: 'acpi': really_probe: probing driver pci_root with =
device PNP0A08:00
[    3.500836] ACPI: PCI Root Bridge [PCI0] (0000:00)
[    3.510076] device: 'pci0000:00': device_add
[    3.514330] PM: Adding info for No Bus:pci0000:00
[    3.518931] device: '0000:00': device_add
[    3.520100] PM: Adding info for No Bus:0000:00
[    3.524668] PCI: Scanning bus 0000:00
[    3.530103] pci 0000:00:00.0: found [10de:005e] class 000580 header =
type 00
[    3.537161] pci 0000:00:00.0: calling quirk_resource_alignment+0x0/0=
x1b2
[    3.540178] pci 0000:00:01.0: found [10de:0050] class 000601 header =
type 00
[    3.550162] pci 0000:00:01.0: calling nvidia_force_enable_hpet+0x0/0=
xa0
[    3.556650] HPET not enabled in BIOS. You might try hpet=3Dforce boo=
t option
[    3.560005] pci 0000:00:01.0: calling quirk_resource_alignment+0x0/0=
x1b2
[    3.570073] pci 0000:00:01.1: found [10de:0052] class 000c05 header =
type 00
[    3.576997] pci 0000:00:01.1: reg 10 io port: [0xdc00-0xdc1f]
[    3.580078] pci 0000:00:01.1: reg 20 io port: [0x4c00-0x4c3f]
[    3.590022] pci 0000:00:01.1: reg 24 io port: [0x4c40-0x4c7f]
[    3.595745] pci 0000:00:01.1: calling quirk_resource_alignment+0x0/0=
x1b2
[    3.600063] pci 0000:00:01.1: PME# supported from D3hot D3cold
[    3.605812] pci 0000:00:01.1: PME# disabled
[    3.610106] pci 0000:00:02.0: found [10de:005a] class 000c03 header =
type 00
[    3.620073] pci 0000:00:02.0: reg 10 32bit mmio: [0xda102000-0xda102=
fff]
[    3.626793] pci 0000:00:02.0: calling quirk_resource_alignment+0x0/0=
x1b2
[    3.630062] pci 0000:00:02.0: supports D1 D2
[    3.634242] pci 0000:00:02.0: PME# supported from D0 D1 D2 D3hot D3c=
old
[    3.640014] pci 0000:00:02.0: PME# disabled
[    3.644232] pci 0000:00:02.1: found [10de:005b] class 000c03 header =
type 00
[    3.650092] pci 0000:00:02.1: reg 10 32bit mmio: [0xfeb00000-0xfeb00=
0ff]
[    3.660129] pci 0000:00:02.1: calling quirk_resource_alignment+0x0/0=
x1b2
[    3.666797] pci 0000:00:02.1: supports D1 D2
[    3.670003] pci 0000:00:02.1: PME# supported from D0 D1 D2 D3hot D3c=
old
[    3.680014] pci 0000:00:02.1: PME# disabled
[    3.684272] pci 0000:00:04.0: found [10de:0059] class 000401 header =
type 00
[    3.690071] pci 0000:00:04.0: reg 10 io port: [0xd400-0xd4ff]
[    3.695734] pci 0000:00:04.0: reg 14 io port: [0xd800-0xd8ff]
[    3.700023] pci 0000:00:04.0: reg 18 32bit mmio: [0xda101000-0xda101=
fff]
[    3.706752] pci 0000:00:04.0: calling quirk_resource_alignment+0x0/0=
x1b2
[    3.710061] pci 0000:00:04.0: supports D1 D2
[    3.720077] pci 0000:00:06.0: found [10de:0053] class 000101 header =
type 00
[    3.727064] pci 0000:00:06.0: reg 20 io port: [0xf000-0xf00f]
[    3.730058] pci 0000:00:06.0: calling quirk_resource_alignment+0x0/0=
x1b2
[    3.736791] pci 0000:00:09.0: found [10de:005c] class 000604 header =
type 01
[    3.740075] pci 0000:00:09.0: calling quirk_resource_alignment+0x0/0=
x1b2
[    3.750071] pci 0000:00:0a.0: found [10de:0057] class 000680 header =
type 00
[    3.760072] pci 0000:00:0a.0: reg 10 32bit mmio: [0xda100000-0xda100=
fff]
[    3.766688] pci 0000:00:0a.0: reg 14 io port: [0xd000-0xd007]
[    3.770110] pci 0000:00:0a.0: calling quirk_resource_alignment+0x0/0=
x1b2
[    3.776742] pci 0000:00:0a.0: supports D1 D2
[    3.780004] pci 0000:00:0a.0: PME# supported from D0 D1 D2 D3hot D3c=
old
[    3.790014] pci 0000:00:0a.0: PME# disabled
[    3.794251] pci 0000:00:0b.0: found [10de:005d] class 000604 header =
type 01
[    3.800109] pci 0000:00:0b.0: calling quirk_resource_alignment+0x0/0=
x1b2
[    3.806797] pci 0000:00:0b.0: PME# supported from D0 D1 D2 D3hot D3c=
old
[    3.810016] pci 0000:00:0b.0: PME# disabled
[    3.814278] pci 0000:00:0c.0: found [10de:005d] class 000604 header =
type 01
[    3.820110] pci 0000:00:0c.0: calling quirk_resource_alignment+0x0/0=
x1b2
[    3.830116] pci 0000:00:0c.0: PME# supported from D0 D1 D2 D3hot D3c=
old
[    3.836618] pci 0000:00:0c.0: PME# disabled
[    3.840125] pci 0000:00:0d.0: found [10de:005d] class 000604 header =
type 01
[    3.850105] pci 0000:00:0d.0: calling quirk_resource_alignment+0x0/0=
x1b2
[    3.856792] pci 0000:00:0d.0: PME# supported from D0 D1 D2 D3hot D3c=
old
[    3.860014] pci 0000:00:0d.0: PME# disabled
[    3.864278] pci 0000:00:0e.0: found [10de:005d] class 000604 header =
type 01
[    3.870111] pci 0000:00:0e.0: calling quirk_resource_alignment+0x0/0=
x1b2
[    3.880119] pci 0000:00:0e.0: PME# supported from D0 D1 D2 D3hot D3c=
old
[    3.886618] pci 0000:00:0e.0: PME# disabled
[    3.890148] pci 0000:00:18.0: found [1022:1100] class 000600 header =
type 00
[    3.897132] pci 0000:00:18.0: calling quirk_resource_alignment+0x0/0=
x1b2
[    3.900112] pci 0000:00:18.1: found [1022:1101] class 000600 header =
type 00
[    3.910150] pci 0000:00:18.1: calling quirk_resource_alignment+0x0/0=
x1b2
[    3.916787] pci 0000:00:18.2: found [1022:1102] class 000600 header =
type 00
[    3.920146] pci 0000:00:18.2: calling quirk_resource_alignment+0x0/0=
x1b2
[    3.930058] pci 0000:00:18.3: found [1022:1103] class 000600 header =
type 00
[    3.940042] pci 0000:00:18.3: calling quirk_resource_alignment+0x0/0=
x1b2
[    3.946704] PCI: Fixups for bus 0000:00
[    3.950009] pci 0000:00:09.0: scanning behind bridge, config 050500,=
 pass 0
[    3.956951] PCI: Scanning bus 0000:05
[    3.960091] pci 0000:05:07.0: found [10ec:8139] class 000200 header =
type 00
[    3.966997] pci 0000:05:07.0: reg 10 io port: [0xc000-0xc0ff]
[    3.970025] pci 0000:05:07.0: reg 14 32bit mmio: [0xda000000-0xda000=
0ff]
[    3.980112] pci 0000:05:07.0: calling quirk_resource_alignment+0x0/0=
x1b2
[    3.986755] pci 0000:05:07.0: supports D1 D2
[    3.990004] pci 0000:05:07.0: PME# supported from D1 D2 D3hot
[    3.995725] pci 0000:05:07.0: PME# disabled
[    4.000159] PCI: Fixups for bus 0000:05
[    4.003878] pci 0000:00:09.0: transparent bridge
[    4.008478] pci 0000:00:09.0: bridge io port: [0xc000-0xcfff]
[    4.010015] pci 0000:00:09.0: bridge 32bit mmio: [0xda000000-0xda0ff=
fff]
[    4.020013] PCI: Bus scan for 0000:05 returning with max=3D05
[    4.025554] pci 0000:00:0b.0: scanning behind bridge, config 040400,=
 pass 0
[    4.030027] PCI: Scanning bus 0000:04
[    4.033809] PCI: Fixups for bus 0000:04
[    4.040051] PCI: Bus scan for 0000:04 returning with max=3D04
[    4.045553] pci 0000:00:0c.0: scanning behind bridge, config 030300,=
 pass 0
[    4.050029] PCI: Scanning bus 0000:03
[    4.053808] PCI: Fixups for bus 0000:03
[    4.060052] PCI: Bus scan for 0000:03 returning with max=3D03
[    4.065553] pci 0000:00:0d.0: scanning behind bridge, config 020200,=
 pass 0
[    4.070027] PCI: Scanning bus 0000:02
[    4.073806] PCI: Fixups for bus 0000:02
[    4.080051] PCI: Bus scan for 0000:02 returning with max=3D02
[    4.085553] pci 0000:00:0e.0: scanning behind bridge, config 010100,=
 pass 0
[    4.090028] PCI: Scanning bus 0000:01
[    4.093696] pci 0000:01:00.0: found [1002:5b60] class 000300 header =
type 00
[    4.100030] pci 0000:01:00.0: calling quirk_no_ata_d3+0x0/0x21
[    4.110033] pci 0000:01:00.0: reg 10 32bit mmio: [0xd0000000-0xd7fff=
fff]
[    4.116686] pci 0000:01:00.0: reg 14 io port: [0xb000-0xb0ff]
[    4.120024] pci 0000:01:00.0: reg 18 32bit mmio: [0xd9000000-0xd900f=
fff]
[    4.130074] pci 0000:01:00.0: reg 30 32bit mmio: [0x000000-0x01ffff]
[    4.136324] pci 0000:01:00.0: calling quirk_resource_alignment+0x0/0=
x1b2
[    4.140093] pci 0000:01:00.0: supports D1 D2
[    4.144341] pci 0000:01:00.1: found [1002:5b70] class 000380 header =
type 00
[    4.150029] pci 0000:01:00.1: calling quirk_no_ata_d3+0x0/0x21
[    4.160013] pci 0000:01:00.1: reg 10 32bit mmio: [0xd9010000-0xd901f=
fff]
[    4.166782] pci 0000:01:00.1: calling quirk_resource_alignment+0x0/0=
x1b2
[    4.170085] pci 0000:01:00.1: supports D1 D2
[    4.174468] PCI: Fixups for bus 0000:01
[    4.180022] pci 0000:00:0e.0: bridge io port: [0xb000-0xbfff]
[    4.185725] pci 0000:00:0e.0: bridge 32bit mmio: [0xd8000000-0xd9fff=
fff]
[    4.190023] pci 0000:00:0e.0: bridge 64bit mmio pref: [0xd0000000-0x=
d7ffffff]
[    4.200003] PCI: Bus scan for 0000:01 returning with max=3D01
[    4.205553] pci 0000:00:09.0: scanning behind bridge, config 050500,=
 pass 1
[    4.210027] pci 0000:00:0b.0: scanning behind bridge, config 040400,=
 pass 1
[    4.220025] pci 0000:00:0c.0: scanning behind bridge, config 030300,=
 pass 1
[    4.226949] pci 0000:00:0d.0: scanning behind bridge, config 020200,=
 pass 1
[    4.230025] pci 0000:00:0e.0: scanning behind bridge, config 010100,=
 pass 1
[    4.240020] PCI: Bus scan for 0000:00 returning with max=3D05
[    4.245542] pci_bus 0000:00: on NUMA node 0
[    4.250024] ACPI: PCI Interrupt Routing Table [\_SB_.PCI0._PRT]
[    4.262108] ACPI: PCI Interrupt Routing Table [\_SB_.PCI0.HUB0._PRT]
[    4.272710] device: '0000:00:00.0': device_add
[    4.311692] bus: 'pci': add device 0000:00:00.0
[    4.316918] PM: Adding info for pci:0000:00:00.0
[    4.320241] device: '0000:00:01.0': device_add
[    4.360416] bus: 'pci': add device 0000:00:01.0
[    4.365008] PM: Adding info for pci:0000:00:01.0
[    4.369735] device: '0000:00:01.1': device_add
[    4.409233] bus: 'pci': add device 0000:00:01.1
[    4.413512] PM: Adding info for pci:0000:00:01.1
[    4.420244] device: '0000:00:02.0': device_add
[    4.463255] bus: 'pci': add device 0000:00:02.0
[    4.467844] PM: Adding info for pci:0000:00:02.0
[    4.470240] device: '0000:00:02.1': device_add
[    4.514239] bus: 'pci': add device 0000:00:02.1
[    4.518826] PM: Adding info for pci:0000:00:02.1
[    4.520242] device: '0000:00:04.0': device_add
[    4.564781] bus: 'pci': add device 0000:00:04.0
[    4.569372] PM: Adding info for pci:0000:00:04.0
[    4.570243] device: '0000:00:06.0': device_add
[    4.615392] bus: 'pci': add device 0000:00:06.0
[    4.619981] PM: Adding info for pci:0000:00:06.0
[    4.620240] device: '0000:00:09.0': device_add
[    4.666209] bus: 'pci': add device 0000:00:09.0
[    4.670314] PM: Adding info for pci:0000:00:09.0
[    4.675055] device: '0000:00:0a.0': device_add
[    4.717026] bus: 'pci': add device 0000:00:0a.0
[    4.720176] PM: Adding info for pci:0000:00:0a.0
[    4.724907] device: '0000:00:0b.0': device_add
[    4.767851] bus: 'pci': add device 0000:00:0b.0
[    4.770183] PM: Adding info for pci:0000:00:0b.0
[    4.774913] device: '0000:00:0c.0': device_add
[    4.818362] bus: 'pci': add device 0000:00:0c.0
[    4.820178] PM: Adding info for pci:0000:00:0c.0
[    4.824907] device: '0000:00:0d.0': device_add
[    4.869025] bus: 'pci': add device 0000:00:0d.0
[    4.870176] PM: Adding info for pci:0000:00:0d.0
[    4.874913] device: '0000:00:0e.0': device_add
[    4.919591] bus: 'pci': add device 0000:00:0e.0
[    4.920182] PM: Adding info for pci:0000:00:0e.0
[    4.924917] device: '0000:00:18.0': device_add
[    4.970269] bus: 'pci': add device 0000:00:18.0
[    4.974864] PM: Adding info for pci:0000:00:18.0
[    4.979602] device: '0000:00:18.1': device_add
[    5.020829] bus: 'pci': add device 0000:00:18.1
[    5.025425] PM: Adding info for pci:0000:00:18.1
[    5.030264] device: '0000:00:18.2': device_add
[    5.071657] bus: 'pci': add device 0000:00:18.2
[    5.076255] PM: Adding info for pci:0000:00:18.2
[    5.080242] device: '0000:00:18.3': device_add
[    5.122756] bus: 'pci': add device 0000:00:18.3
[    5.127350] PM: Adding info for pci:0000:00:18.3
[    5.130244] device: '0000:05:07.0': device_add
[    5.134600] bus: 'pci': add device 0000:05:07.0
[    5.142700] PM: Adding info for pci:0000:05:07.0
[    5.147419] device: '0000:05': device_add
[    5.150098] PM: Adding info for No Bus:0000:05
[    5.154654] device: '0000:04': device_add
[    5.162264] PM: Adding info for No Bus:0000:04
[    5.166827] device: '0000:03': device_add
[    5.170099] PM: Adding info for No Bus:0000:03
[    5.174647] device: '0000:02': device_add
[    5.180103] PM: Adding info for No Bus:0000:02
[    5.184651] device: '0000:01:00.0': device_add
[    5.189011] bus: 'pci': add device 0000:01:00.0
[    5.190191] PM: Adding info for pci:0000:01:00.0
[    5.194907] device: '0000:01:00.1': device_add
[    5.200032] bus: 'pci': add device 0000:01:00.1
[    5.204680] PM: Adding info for pci:0000:01:00.1
[    5.210223] device: '0000:01': device_add
[    5.214201] PM: Adding info for No Bus:0000:01
[    5.220238] driver: 'PNP0A08:00': driver_bound: bound to device 'pci=
_root'
[    5.226987] bus: 'acpi': really_probe: bound device PNP0A08:00 to dr=
iver pci_root
[    5.230302] initcall acpi_pci_root_init+0x0/0x25 returned 0 after 17=
08984 usecs
[    5.240006] calling  acpi_pci_link_init+0x0/0x3f @ 1
[    5.244936] bus: 'acpi': add driver pci_link
[    5.250051] bus: 'acpi': driver_probe_device: matched device PNP0C0F=
:00 with driver pci_link
[    5.260004] bus: 'acpi': really_probe: probing driver pci_link with =
device PNP0C0F:00
[    5.268578] ACPI: PCI Interrupt Link [LNK1] (IRQs 3 4 5 7 9 10 11 12=
 14 15) *0, disabled.
[    5.273827] driver: 'PNP0C0F:00': driver_bound: bound to device 'pci=
_link'
[    5.280006] bus: 'acpi': really_probe: bound device PNP0C0F:00 to dr=
iver pci_link
[    5.290007] bus: 'acpi': driver_probe_device: matched device PNP0C0F=
:01 with driver pci_link
[    5.298399] bus: 'acpi': really_probe: probing driver pci_link with =
device PNP0C0F:01
[    5.300695] ACPI: PCI Interrupt Link [LNK2] (IRQs 3 4 5 7 9 10 *11 1=
2 14 15)
[    5.312697] driver: 'PNP0C0F:01': driver_bound: bound to device 'pci=
_link'
[    5.320006] bus: 'acpi': really_probe: bound device PNP0C0F:01 to dr=
iver pci_link
[    5.327451] bus: 'acpi': driver_probe_device: matched device PNP0C0F=
:02 with driver pci_link
[    5.330003] bus: 'acpi': really_probe: probing driver pci_link with =
device PNP0C0F:02
[    5.340693] ACPI: PCI Interrupt Link [LNK3] (IRQs 3 4 *5 7 9 10 11 1=
2 14 15)
[    5.352697] driver: 'PNP0C0F:02': driver_bound: bound to device 'pci=
_link'
[    5.360006] bus: 'acpi': really_probe: bound device PNP0C0F:02 to dr=
iver pci_link
[    5.367449] bus: 'acpi': driver_probe_device: matched device PNP0C0F=
:03 with driver pci_link
[    5.370003] bus: 'acpi': really_probe: probing driver pci_link with =
device PNP0C0F:03
[    5.380652] ACPI: PCI Interrupt Link [LNK4] (IRQs 3 4 5 7 9 10 11 12=
 14 15) *0, disabled.
[    5.392436] driver: 'PNP0C0F:03': driver_bound: bound to device 'pci=
_link'
[    5.399188] bus: 'acpi': really_probe: bound device PNP0C0F:03 to dr=
iver pci_link
[    5.400009] bus: 'acpi': driver_probe_device: matched device PNP0C0F=
:04 with driver pci_link
[    5.410003] bus: 'acpi': really_probe: probing driver pci_link with =
device PNP0C0F:04
[    5.420654] ACPI: PCI Interrupt Link [LNK5] (IRQs 3 4 5 7 9 10 11 12=
 14 15) *0, disabled.
[    5.431658] driver: 'PNP0C0F:04': driver_bound: bound to device 'pci=
_link'
[    5.438408] bus: 'acpi': really_probe: bound device PNP0C0F:04 to dr=
iver pci_link
[    5.440010] bus: 'acpi': driver_probe_device: matched device PNP0C0F=
:05 with driver pci_link
[    5.450004] bus: 'acpi': really_probe: probing driver pci_link with =
device PNP0C0F:05
[    5.460655] ACPI: PCI Interrupt Link [LUBA] (IRQs 3 4 5 7 9 10 11 12=
 14 15) *0, disabled.
[    5.470361] driver: 'PNP0C0F:05': driver_bound: bound to device 'pci=
_link'
[    5.477109] bus: 'acpi': really_probe: bound device PNP0C0F:05 to dr=
iver pci_link
[    5.480013] bus: 'acpi': driver_probe_device: matched device PNP0C0F=
:06 with driver pci_link
[    5.490003] bus: 'acpi': really_probe: probing driver pci_link with =
device PNP0C0F:06
[    5.500655] ACPI: PCI Interrupt Link [LUBB] (IRQs 3 4 5 7 9 10 11 12=
 14 15) *0, disabled.
[    5.510360] driver: 'PNP0C0F:06': driver_bound: bound to device 'pci=
_link'
[    5.517110] bus: 'acpi': really_probe: bound device PNP0C0F:06 to dr=
iver pci_link
[    5.520009] bus: 'acpi': driver_probe_device: matched device PNP0C0F=
:07 with driver pci_link
[    5.530003] bus: 'acpi': really_probe: probing driver pci_link with =
device PNP0C0F:07
[    5.540693] ACPI: PCI Interrupt Link [LMAC] (IRQs 3 4 5 7 9 10 *11 1=
2 14 15)
[    5.547780] driver: 'PNP0C0F:07': driver_bound: bound to device 'pci=
_link'
[    5.550005] bus: 'acpi': really_probe: bound device PNP0C0F:07 to dr=
iver pci_link
[    5.560009] bus: 'acpi': driver_probe_device: matched device PNP0C0F=
:08 with driver pci_link
[    5.570003] bus: 'acpi': really_probe: probing driver pci_link with =
device PNP0C0F:08
[    5.578484] ACPI: PCI Interrupt Link [LACI] (IRQs *3 4 5 7 9 10 11 1=
2 14 15)
[    5.582699] driver: 'PNP0C0F:08': driver_bound: bound to device 'pci=
_link'
[    5.590004] bus: 'acpi': really_probe: bound device PNP0C0F:08 to dr=
iver pci_link
[    5.600009] bus: 'acpi': driver_probe_device: matched device PNP0C0F=
:09 with driver pci_link
[    5.608401] bus: 'acpi': really_probe: probing driver pci_link with =
device PNP0C0F:09
[    5.610654] ACPI: PCI Interrupt Link [LMCI] (IRQs 3 4 5 7 9 10 11 12=
 14 15) *0, disabled.
[    5.623823] driver: 'PNP0C0F:09': driver_bound: bound to device 'pci=
_link'
[    5.630004] bus: 'acpi': really_probe: bound device PNP0C0F:09 to dr=
iver pci_link
[    5.640009] bus: 'acpi': driver_probe_device: matched device PNP0C0F=
:0a with driver pci_link
[    5.648399] bus: 'acpi': really_probe: probing driver pci_link with =
device PNP0C0F:0a
[    5.650661] ACPI: PCI Interrupt Link [LSMB] (IRQs 3 4 5 7 9 10 11 12=
 14 15) *0, disabled.
[    5.663825] driver: 'PNP0C0F:0a': driver_bound: bound to device 'pci=
_link'
[    5.670004] bus: 'acpi': really_probe: bound device PNP0C0F:0a to dr=
iver pci_link
[    5.677451] bus: 'acpi': driver_probe_device: matched device PNP0C0F=
:0b with driver pci_link
[    5.680005] bus: 'acpi': really_probe: probing driver pci_link with =
device PNP0C0F:0b
[    5.690660] ACPI: PCI Interrupt Link [LUB2] (IRQs 3 4 5 7 9 10 11 12=
 14 15) *0, disabled.
[    5.703823] driver: 'PNP0C0F:0b': driver_bound: bound to device 'pci=
_link'
[    5.710004] bus: 'acpi': really_probe: bound device PNP0C0F:0b to dr=
iver pci_link
[    5.717449] bus: 'acpi': driver_probe_device: matched device PNP0C0F=
:0c with driver pci_link
[    5.720005] bus: 'acpi': really_probe: probing driver pci_link with =
device PNP0C0F:0c
[    5.730659] ACPI: PCI Interrupt Link [LIDE] (IRQs 3 4 5 7 9 10 11 12=
 14 15) *0, disabled.
[    5.743903] driver: 'PNP0C0F:0c': driver_bound: bound to device 'pci=
_link'
[    5.750004] bus: 'acpi': really_probe: bound device PNP0C0F:0c to dr=
iver pci_link
[    5.757450] bus: 'acpi': driver_probe_device: matched device PNP0C0F=
:0d with driver pci_link
[    5.760005] bus: 'acpi': really_probe: probing driver pci_link with =
device PNP0C0F:0d
[    5.770657] ACPI: PCI Interrupt Link [LSID] (IRQs 3 4 5 7 9 10 11 12=
 14 15) *0, disabled.
[    5.783903] driver: 'PNP0C0F:0d': driver_bound: bound to device 'pci=
_link'
[    5.790004] bus: 'acpi': really_probe: bound device PNP0C0F:0d to dr=
iver pci_link
[    5.797451] bus: 'acpi': driver_probe_device: matched device PNP0C0F=
:0e with driver pci_link
[    5.800005] bus: 'acpi': really_probe: probing driver pci_link with =
device PNP0C0F:0e
[    5.810659] ACPI: PCI Interrupt Link [LFID] (IRQs 3 4 5 7 9 10 11 12=
 14 15) *0, disabled.
[    5.823381] driver: 'PNP0C0F:0e': driver_bound: bound to device 'pci=
_link'
[    5.830004] bus: 'acpi': really_probe: bound device PNP0C0F:0e to dr=
iver pci_link
[    5.837450] bus: 'acpi': driver_probe_device: matched device PNP0C0F=
:0f with driver pci_link
[    5.840005] bus: 'acpi': really_probe: probing driver pci_link with =
device PNP0C0F:0f
[    5.850653] ACPI: PCI Interrupt Link [LPCA] (IRQs 3 4 5 7 9 10 11 12=
 14 15) *0, disabled.
[    5.862698] driver: 'PNP0C0F:0f': driver_bound: bound to device 'pci=
_link'
[    5.869448] bus: 'acpi': really_probe: bound device PNP0C0F:0f to dr=
iver pci_link
[    5.870007] bus: 'acpi': driver_probe_device: matched device PNP0C0F=
:10 with driver pci_link
[    5.880005] bus: 'acpi': really_probe: probing driver pci_link with =
device PNP0C0F:10
[    5.891156] ACPI: PCI Interrupt Link [APC1] (IRQs 16) *0, disabled.
[    5.900356] driver: 'PNP0C0F:10': driver_bound: bound to device 'pci=
_link'
[    5.907109] bus: 'acpi': really_probe: bound device PNP0C0F:10 to dr=
iver pci_link
[    5.910008] bus: 'acpi': driver_probe_device: matched device PNP0C0F=
:11 with driver pci_link
[    5.920005] bus: 'acpi': really_probe: probing driver pci_link with =
device PNP0C0F:11
[    5.931144] ACPI: PCI Interrupt Link [APC2] (IRQs 17) *0
[    5.936497] driver: 'PNP0C0F:11': driver_bound: bound to device 'pci=
_link'
[    5.940004] bus: 'acpi': really_probe: bound device PNP0C0F:11 to dr=
iver pci_link
[    5.950007] bus: 'acpi': driver_probe_device: matched device PNP0C0F=
:12 with driver pci_link
[    5.960006] bus: 'acpi': really_probe: probing driver pci_link with =
device PNP0C0F:12
[    5.968932] ACPI: PCI Interrupt Link [APC3] (IRQs 18) *0
[    5.970964] driver: 'PNP0C0F:12': driver_bound: bound to device 'pci=
_link'
[    5.980004] bus: 'acpi': really_probe: bound device PNP0C0F:12 to dr=
iver pci_link
[    5.987450] bus: 'acpi': driver_probe_device: matched device PNP0C0F=
:13 with driver pci_link
[    5.990004] bus: 'acpi': really_probe: probing driver pci_link with =
device PNP0C0F:13
[    6.001148] ACPI: PCI Interrupt Link [APC4] (IRQs 19) *0, disabled.
[    6.011917] driver: 'PNP0C0F:13': driver_bound: bound to device 'pci=
_link'
[    6.018668] bus: 'acpi': really_probe: bound device PNP0C0F:13 to dr=
iver pci_link
[    6.020008] bus: 'acpi': driver_probe_device: matched device PNP0C0F=
:14 with driver pci_link
[    6.030008] bus: 'acpi': really_probe: probing driver pci_link with =
device PNP0C0F:14
[    6.040363] ACPI: PCI Interrupt Link [APC5] (IRQs *16), disabled.
[    6.046498] driver: 'PNP0C0F:14': driver_bound: bound to device 'pci=
_link'
[    6.050004] bus: 'acpi': really_probe: bound device PNP0C0F:14 to dr=
iver pci_link
[    6.060007] bus: 'acpi': driver_probe_device: matched device PNP0C0F=
:15 with driver pci_link
[    6.070003] bus: 'acpi': really_probe: probing driver pci_link with =
device PNP0C0F:15
[    6.080950] ACPI: PCI Interrupt Link [APCF] (IRQs 20 21 22 23) *0, d=
isabled.
[    6.088036] driver: 'PNP0C0F:15': driver_bound: bound to device 'pci=
_link'
[    6.090005] bus: 'acpi': really_probe: bound device PNP0C0F:15 to dr=
iver pci_link
[    6.100007] bus: 'acpi': driver_probe_device: matched device PNP0C0F=
:16 with driver pci_link
[    6.110003] bus: 'acpi': really_probe: probing driver pci_link with =
device PNP0C0F:16
[    6.119086] ACPI: PCI Interrupt Link [APCG] (IRQs 20 21 22 23) *0, d=
isabled.
[    6.122697] driver: 'PNP0C0F:16': driver_bound: bound to device 'pci=
_link'
[    6.130005] bus: 'acpi': really_probe: bound device PNP0C0F:16 to dr=
iver pci_link
[    6.140007] bus: 'acpi': driver_probe_device: matched device PNP0C0F=
:17 with driver pci_link
[    6.148399] bus: 'acpi': really_probe: probing driver pci_link with =
device PNP0C0F:17
[    6.151302] ACPI: PCI Interrupt Link [APCH] (IRQs 20 21 22 23) *0
[    6.161743] driver: 'PNP0C0F:17': driver_bound: bound to device 'pci=
_link'
[    6.170004] bus: 'acpi': really_probe: bound device PNP0C0F:17 to dr=
iver pci_link
[    6.177450] bus: 'acpi': driver_probe_device: matched device PNP0C0F=
:18 with driver pci_link
[    6.180004] bus: 'acpi': really_probe: probing driver pci_link with =
device PNP0C0F:18
[    6.191307] ACPI: PCI Interrupt Link [APCJ] (IRQs 20 21 22 23) *0
[    6.201743] driver: 'PNP0C0F:18': driver_bound: bound to device 'pci=
_link'
[    6.208495] bus: 'acpi': really_probe: bound device PNP0C0F:18 to dr=
iver pci_link
[    6.210008] bus: 'acpi': driver_probe_device: matched device PNP0C0F=
:19 with driver pci_link
[    6.220004] bus: 'acpi': really_probe: probing driver pci_link with =
device PNP0C0F:19
[    6.231308] ACPI: PCI Interrupt Link [APCK] (IRQs 20 21 22 23) *0, d=
isabled.
[    6.241312] driver: 'PNP0C0F:19': driver_bound: bound to device 'pci=
_link'
[    6.248061] bus: 'acpi': really_probe: bound device PNP0C0F:19 to dr=
iver pci_link
[    6.250008] bus: 'acpi': driver_probe_device: matched device PNP0C0F=
:1a with driver pci_link
[    6.260004] bus: 'acpi': really_probe: probing driver pci_link with =
device PNP0C0F:1a
[    6.271308] ACPI: PCI Interrupt Link [APCS] (IRQs 20 21 22 23) *0, d=
isabled.
[    6.280191] driver: 'PNP0C0F:1a': driver_bound: bound to device 'pci=
_link'
[    6.286944] bus: 'acpi': really_probe: bound device PNP0C0F:1a to dr=
iver pci_link
[    6.290008] bus: 'acpi': driver_probe_device: matched device PNP0C0F=
:1b with driver pci_link
[    6.300003] bus: 'acpi': really_probe: probing driver pci_link with =
device PNP0C0F:1b
[    6.311299] ACPI: PCI Interrupt Link [APCL] (IRQs 20 21 22 23) *0, d=
isabled.
[    6.318385] driver: 'PNP0C0F:1b': driver_bound: bound to device 'pci=
_link'
[    6.320006] bus: 'acpi': really_probe: bound device PNP0C0F:1b to dr=
iver pci_link
[    6.330007] bus: 'acpi': driver_probe_device: matched device PNP0C0F=
:1c with driver pci_link
[    6.340003] bus: 'acpi': really_probe: probing driver pci_link with =
device PNP0C0F:1c
[    6.350727] ACPI: PCI Interrupt Link [APCZ] (IRQs 20 21 22 23) *0, d=
isabled.
[    6.357892] driver: 'PNP0C0F:1c': driver_bound: bound to device 'pci=
_link'
[    6.360006] bus: 'acpi': really_probe: bound device PNP0C0F:1c to dr=
iver pci_link
[    6.370007] bus: 'acpi': driver_probe_device: matched device PNP0C0F=
:1d with driver pci_link
[    6.380003] bus: 'acpi': really_probe: probing driver pci_link with =
device PNP0C0F:1d
[    6.389088] ACPI: PCI Interrupt Link [APSI] (IRQs 20 21 22 23) *0, d=
isabled.
[    6.392774] driver: 'PNP0C0F:1d': driver_bound: bound to device 'pci=
_link'
[    6.400006] bus: 'acpi': really_probe: bound device PNP0C0F:1d to dr=
iver pci_link
[    6.410007] bus: 'acpi': driver_probe_device: matched device PNP0C0F=
:1e with driver pci_link
[    6.418400] bus: 'acpi': really_probe: probing driver pci_link with =
device PNP0C0F:1e
[    6.421310] ACPI: PCI Interrupt Link [APSJ] (IRQs 20 21 22 23) *0, d=
isabled.
[    6.432776] driver: 'PNP0C0F:1e': driver_bound: bound to device 'pci=
_link'
[    6.440006] bus: 'acpi': really_probe: bound device PNP0C0F:1e to dr=
iver pci_link
[    6.447449] bus: 'acpi': driver_probe_device: matched device PNP0C0F=
:1f with driver pci_link
[    6.450004] bus: 'acpi': really_probe: probing driver pci_link with =
device PNP0C0F:1f
[    6.461310] ACPI: PCI Interrupt Link [APCP] (IRQs 20 21 22 23) *0, d=
isabled.
[    6.472695] driver: 'PNP0C0F:1f': driver_bound: bound to device 'pci=
_link'
[    6.480011] bus: 'acpi': really_probe: bound device PNP0C0F:1f to dr=
iver pci_link
[    6.487701] initcall acpi_pci_link_init+0x0/0x3f returned 0 after 12=
10937 usecs
[    6.490012] calling  pnp_init+0x0/0xf @ 1
[    6.500271] bus: 'pnp': registered
[    6.503560] initcall pnp_init+0x0/0xf returned 0 after 0 usecs
[    6.509363] calling  setup_shutdown_event+0x0/0x11 @ 1
[    6.510105] initcall setup_shutdown_event+0x0/0x11 returned 0 after =
0 usecs
[    6.520094] calling  balloon_init+0x0/0x119 @ 1
[    6.524505] initcall balloon_init+0x0/0x119 returned -19 after 0 use=
cs
[    6.530094] calling  max1586_pmic_init+0x0/0x11 @ 1
[    6.534851] bus: 'i2c': add driver max1586
[    6.540180] i2c-core: driver [max1586] registered
[    6.544724] initcall max1586_pmic_init+0x0/0x11 returned 0 after 976=
5 usecs
[    6.550037] calling  twl4030reg_init+0x0/0xf @ 1
[    6.554591] bus: 'platform': add driver twl4030_reg
[    6.564752] initcall twl4030reg_init+0x0/0xf returned 0 after 9765 u=
secs
[    6.566852] calling  wm8400_regulator_init+0x0/0xf @ 1
[    6.570051] bus: 'platform': add driver wm8400-regulator
[    6.582514] initcall wm8400_regulator_init+0x0/0xf returned 0 after =
9765 usecs
[    6.582514] calling  da903x_regulator_init+0x0/0xf @ 1
[    6.590026] bus: 'platform': add driver da903x-regulator
[    6.600268] initcall da903x_regulator_init+0x0/0xf returned 0 after =
9765 usecs
[    6.600268] calling  pcf50633_regulator_init+0x0/0xf @ 1
[    6.605284] bus: 'platform': add driver pcf50633-regltr
[    6.618105] initcall pcf50633_regulator_init+0x0/0xf returned 0 afte=
r 0 usecs
[    6.620017] calling  misc_init+0x0/0x92 @ 1
[    6.624178] device class 'misc': registering
[    6.633749] initcall misc_init+0x0/0x92 returned 0 after 9765 usecs
[    6.636376] calling  cn_init+0x0/0xd0 @ 1
[    6.640100] initcall cn_init+0x0/0xd0 returned 0 after 0 usecs
[    6.645811] calling  tifm_init+0x0/0x75 @ 1
[    6.654176] bus: 'tifm': registered
[    6.654176] device class 'tifm_adapter': registering
[    6.662746] initcall tifm_init+0x0/0x75 returned 0 after 9765 usecs
[    6.662746] calling  wm8400_module_init+0x0/0x2a @ 1
[    6.670004] bus: 'i2c': add driver WM8400
[    6.678041] i2c-core: driver [WM8400] registered
[    6.678707] initcall wm8400_module_init+0x0/0x2a returned 0 after 97=
65 usecs
[    6.680016] calling  twl4030_init+0x0/0x11 @ 1
[    6.690004] bus: 'i2c': add driver twl4030
[    6.698277] i2c-core: driver [twl4030] registered
[    6.698880] initcall twl4030_init+0x0/0x11 returned 0 after 9765 use=
cs
[    6.700010] calling  da903x_init+0x0/0x11 @ 1
[    6.710004] bus: 'i2c': add driver da903x
[    6.717911] i2c-core: driver [da903x] registered
[    6.718715] initcall da903x_init+0x0/0x11 returned 0 after 9765 usec=
s
[    6.720010] calling  pcf50633_init+0x0/0x11 @ 1
[    6.724504] bus: 'i2c': add driver pcf50633
[    6.737722] i2c-core: driver [pcf50633] registered
[    6.737722] initcall pcf50633_init+0x0/0x11 returned 0 after 9765 us=
ecs
[    6.740011] calling  ab3100_i2c_init+0x0/0x11 @ 1
[    6.750004] bus: 'i2c': add driver ab3100
[    6.757872] i2c-core: driver [ab3100] registered
[    6.758715] initcall ab3100_i2c_init+0x0/0x11 returned 0 after 9765 =
usecs
[    6.760011] calling  init_scsi+0x0/0x89 @ 1
[    6.770679] device class 'scsi_host': registering
[    6.779056] bus: 'scsi': registered
[    6.779098] device class 'scsi_device': registering
[    6.787554] SCSI subsystem initialized
[    6.787554] initcall init_scsi+0x0/0x89 returned 0 after 19531 usecs
[    6.790019] calling  ata_init+0x0/0x81 @ 1
[    6.801853] libata version 3.00 loaded.
[    6.801853] initcall ata_init+0x0/0x81 returned 0 after 0 usecs
[    6.805890] calling  phy_init+0x0/0x29 @ 1
[    6.810009] device class 'mdio_bus': registering
[    6.820525] bus: 'mdio_bus': registered
[    6.820525] bus: 'mdio_bus': add driver Generic PHY
[    6.829365] initcall phy_init+0x0/0x29 returned 0 after 9765 usecs
[    6.830015] calling  init_pcmcia_cs+0x0/0x28 @ 1
[    6.834590] device class 'pcmcia_socket': registering
[    6.845259] initcall init_pcmcia_cs+0x0/0x28 returned 0 after 0 usec=
s
[    6.846531] calling  twl4030_usb_init+0x0/0xf @ 1
[    6.850010] bus: 'platform': add driver twl4030_usb
[    6.861347] initcall twl4030_usb_init+0x0/0xf returned 0 after 9765 =
usecs
[    6.861347] calling  nop_usb_xceiv_init+0x0/0xf @ 1
[    6.864851] bus: 'platform': add driver nop_usb_xceiv
[    6.878125] initcall nop_usb_xceiv_init+0x0/0xf returned 0 after 0 u=
secs
[    6.880010] calling  usb_init+0x0/0x171 @ 1
[    6.889214] bus: 'usb': registered
[    6.889214] bus: 'usb': add driver usbfs
[    6.896694] usbcore: registered new interface driver usbfs
[    6.896694] bus: 'usb': add driver hub
[    6.906029] usbcore: registered new interface driver hub
[    6.911312] bus: 'usb': add driver usb
[    6.915193] usbcore: registered new device driver usb
[    6.915193] initcall usb_init+0x0/0x171 returned 0 after 39062 usecs
[    6.920011] calling  serio_init+0x0/0x73 @ 1
[    6.930909] bus: 'serio': registered
[    6.934498] initcall serio_init+0x0/0x73 returned 0 after 0 usecs
[    6.936063] calling  gameport_init+0x0/0x73 @ 1
[    6.945206] bus: 'gameport': registered
[    6.949053] initcall gameport_init+0x0/0x73 returned 0 after 0 usecs
[    6.950010] calling  input_init+0x0/0x106 @ 1
[    6.954329] device class 'input': registering
[    6.964183] initcall input_init+0x0/0x106 returned 0 after 9765 usec=
s
[    6.966590] calling  rtc_init+0x0/0x5e @ 1
[    6.970013] device class 'rtc': registering
[    6.979005] initcall rtc_init+0x0/0x5e returned 0 after 0 usecs
[    6.980017] calling  pps_init+0x0/0x92 @ 1
[    6.984073] device class 'pps': registering
[    6.993254] LinuxPPS API ver. 1 registered
[    6.993254] Software ver. 5.3.6 - Copyright 2005-2007 Rodolfo Giomet=
ti <giometti@linux.it>
[    7.000010] initcall pps_init+0x0/0x92 returned 0 after 19531 usecs
[    7.006236] calling  power_supply_class_init+0x0/0x2f @ 1
[    7.010007] device class 'power_supply': registering
[    7.022234] initcall power_supply_class_init+0x0/0x2f returned 0 aft=
er 9765 usecs
[    7.022234] calling  hwmon_init+0x0/0x3c @ 1
[    7.030028] device class 'hwmon': registering
[    7.038405] initcall hwmon_init+0x0/0x3c returned 0 after 0 usecs
[    7.040011] calling  thermal_init+0x0/0x46 @ 1
[    7.044417] device class 'thermal': registering
[    7.053524] initcall thermal_init+0x0/0x46 returned 0 after 9765 use=
cs
[    7.056550] calling  md_init+0x0/0xb7 @ 1
[    7.060053] initcall md_init+0x0/0xb7 returned 0 after 0 usecs
[    7.065804] calling  mmc_init+0x0/0x6e @ 1
[    7.074087] bus: 'mmc': registered
[    7.074087] device class 'mmc_host': registering
[    7.082422] bus: 'sdio': registered
[    7.082422] initcall mmc_init+0x0/0x6e returned 0 after 9765 usecs
[    7.086149] calling  leds_init+0x0/0x36 @ 1
[    7.090007] device class 'leds': registering
[    7.100619] initcall leds_init+0x0/0x36 returned 0 after 9765 usecs
[    7.100619] calling  acpi_wmi_init+0x0/0x4f @ 1
[    7.104505] bus: 'acpi': add driver wmi
[    7.115377] ACPI: WMI: Mapper loaded
[    7.115377] initcall acpi_wmi_init+0x0/0x4f returned 0 after 0 usecs
[    7.120010] calling  pci_subsys_init+0x0/0xe3 @ 1
[    7.124675] PCI: Using ACPI for IRQ routing
[    7.130595] initcall pci_subsys_init+0x0/0xe3 returned 0 after 9765 =
usecs
[    7.137259] calling  proto_init+0x0/0xf @ 1
[    7.140022] initcall proto_init+0x0/0xf returned 0 after 0 usecs
[    7.145976] calling  net_dev_init+0x0/0x150 @ 1
[    7.150060] device class 'net': registering
[    7.160291] device: 'lo': device_add
[    7.160391] PM: Adding info for No Bus:lo
[    7.168402] initcall net_dev_init+0x0/0x150 returned 0 after 9765 us=
ecs
[    7.170055] calling  neigh_init+0x0/0x66 @ 1
[    7.174243] initcall neigh_init+0x0/0x66 returned 0 after 0 usecs
[    7.180004] calling  fib_rules_init+0x0/0x99 @ 1
[    7.184594] initcall fib_rules_init+0x0/0x99 returned 0 after 0 usec=
s
[    7.190004] calling  genl_init+0x0/0xb0 @ 1
[    7.220052] initcall genl_init+0x0/0xb0 returned 0 after 19531 usecs
[    7.226284] calling  cipso_v4_init+0x0/0x6d @ 1
[    7.230028] initcall cipso_v4_init+0x0/0x6d returned 0 after 0 usecs
[    7.236323] calling  wanrouter_init+0x0/0x42 @ 1
[    7.240004] Sangoma WANPIPE Router v1.1 (c) 1995-2000 Sangoma Techno=
logies Inc.
[    7.247317] initcall wanrouter_init+0x0/0x42 returned 0 after 9765 u=
secs
[    7.250004] calling  bt_init+0x0/0x50 @ 1
[    7.253983] Bluetooth: Core ver 2.15
[    7.266676] device class 'bluetooth': registering
[    7.271487] NET: Registered protocol family 31
[    7.271487] Bluetooth: HCI device and connection manager initialized
[    7.276345] Bluetooth: HCI socket layer initialized
[    7.280005] initcall bt_init+0x0/0x50 returned 0 after 19531 usecs
[    7.286150] calling  atm_init+0x0/0xa0 @ 1
[    7.290004] NET: Registered protocol family 8
[    7.294329] NET: Registered protocol family 20
[    7.300066] device class 'atm': registering
[    7.310348] initcall atm_init+0x0/0xa0 returned 0 after 19531 usecs
[    7.310348] calling  wireless_nlevent_init+0x0/0x39 @ 1
[    7.315198] initcall wireless_nlevent_init+0x0/0x39 returned 0 after=
 0 usecs
[    7.320005] calling  cfg80211_init+0x0/0x69 @ 1
[    7.324503] device class 'ieee80211': registering
[    7.450057] Registering platform device 'regulatory.0'. Parent at pl=
atform
[    7.456817] device: 'regulatory.0': device_add
[    7.460025] bus: 'platform': add device regulatory.0
[    7.464995] PM: Adding info for platform:regulatory.0
[    7.474785] cfg80211: Using static regulatory domain info
[    7.475489] cfg80211: Regulatory domain: US
[    7.480007] 	(start_freq - end_freq @ bandwidth), (max_antenna_gain,=
 max_eirp)
[    7.487188] 	(2402000 KHz - 2472000 KHz @ 40000 KHz), (600 mBi, 2700=
 mBm)
[    7.490004] 	(5170000 KHz - 5190000 KHz @ 40000 KHz), (600 mBi, 2300=
 mBm)
[    7.500004] 	(5190000 KHz - 5210000 KHz @ 40000 KHz), (600 mBi, 2300=
 mBm)
[    7.506755] 	(5210000 KHz - 5230000 KHz @ 40000 KHz), (600 mBi, 2300=
 mBm)
[    7.510003] 	(5230000 KHz - 5330000 KHz @ 40000 KHz), (600 mBi, 2300=
 mBm)
[    7.520004] 	(5735000 KHz - 5835000 KHz @ 40000 KHz), (600 mBi, 3000=
 mBm)
[    7.526839] cfg80211: Calling CRDA for country: US
[    7.537063] initcall cfg80211_init+0x0/0x69 returned 0 after 195312 =
usecs
[    7.540008] calling  ieee80211_init+0x0/0x19 @ 1
[    7.544618] initcall ieee80211_init+0x0/0x19 returned 0 after 0 usec=
s
[    7.550005] calling  netlbl_init+0x0/0x6d @ 1
[    7.554328] NetLabel: Initializing
[    7.557707] NetLabel:  domain hash size =3D 128
[    7.560002] NetLabel:  protocols =3D UNLABELED CIPSOv4
[    7.565074] NetLabel:  unlabeled traffic allowed by default
[    7.570005] initcall netlbl_init+0x0/0x6d returned 0 after 19531 use=
cs
[    7.580004] calling  rfkill_init+0x0/0x75 @ 1
[    7.584329] device class 'rfkill': registering
[    7.592842] device: 'rfkill': device_add
[    7.592842] PM: Adding info for No Bus:rfkill
[    7.601334] initcall rfkill_init+0x0/0x75 returned 0 after 19531 use=
cs
[    7.601334] calling  sysctl_init+0x0/0x3b @ 1
[    7.604334] initcall sysctl_init+0x0/0x3b returned 0 after 0 usecs
[    7.610019] calling  pci_iommu_init+0x0/0x20 @ 1
[    7.725574] DMA-API: preallocated 32768 debug entries
[    7.730004] DMA-API: debugging enabled by kernel config
[    7.735205] initcall pci_iommu_init+0x0/0x20 returned 0 after 107421=
 usecs
[    7.740006] calling  print_all_ICs+0x0/0x5f @ 1
[    7.744502]=20
[    7.744503] printing PIC contents
[    7.750005] ... PIC  IMR: ffff
[    7.753033] ... PIC  IRR: 0829
[    7.756067] ... PIC  ISR: 0000
[    7.760004] ... PIC ELCR: 0828
[    7.767373]=20
[    7.768841] printing local APIC contents on CPU#0/0:
[    7.770000] ... APIC ID:      00000000 (0)
[    7.770000] ... APIC VERSION: 00040010
[    7.770000] ... APIC TASKPRI: 00000000 (00)
[    7.770000] ... APIC ARBPRI: 000000e0 (e0)
[    7.770000] ... APIC PROCPRI: 00000000
[    7.770000] ... APIC LDR: 01000000
[    7.770000] ... APIC DFR: ffffffff
[    7.770000] ... APIC SPIV: 000001ff
[    7.770000] ... APIC ISR field:
[    7.770000] 00000000000000000000000000000000000000000000000000000000=
00000000
[    7.770000] ... APIC TMR field:
[    7.770000] 00000000000000000000000000000000000000000000000000000000=
00000000
[    7.770000] ... APIC IRR field:
[    7.770000] 00000000000000000000000000000000000000000000000000000000=
00008000
[    7.770000] ... APIC ESR: 00000000
[    7.770000] ... APIC ICR: 000008fd
[    7.770000] ... APIC ICR2: 02000000
[    7.770000] ... APIC LVTT: 000200ef
[    7.770000] ... APIC LVTPC: 00000400
[    7.770000] ... APIC LVT0: 00010700
[    7.770000] ... APIC LVT1: 00000400
[    7.770000] ... APIC LVTERR: 000000fe
[    7.770000] ... APIC TMICT: 0001eace
[    7.770000] ... APIC TMCCT: 0000d996
[    7.770000] ... APIC TDCR: 00000003
[    7.770000]=20
[    7.769992]=20
[    7.769992] printing local APIC contents on CPU#1/1:
[    7.769992] ... APIC ID:      01000000 (1)
[    7.770000] ... APIC VERSION: 00040010
[    7.770000] ... APIC TASKPRI: 00000000 (00)
[    7.770000] ... APIC ARBPRI: 000000f0 (f0)
[    7.770000] ... APIC PROCPRI: 00000000
[    7.770000] ... APIC LDR: 02000000
[    7.770000] ... APIC DFR: ffffffff
[    7.770000] ... APIC SPIV: 000001ff
[    7.770000] ... APIC ISR field:
[    7.770000] 00000000000000000000000000000000000000000000000000000000=
00000000
[    7.770000] ... APIC TMR field:
[    7.770000] 00000000000000000000000000000000000000000000000000000000=
00000000
[    7.770000] ... APIC IRR field:
[    7.770000] 00000000000000000000000000000000000000000000000000000000=
20008000
[    7.770000] ... APIC ESR: 00000000
[    7.770000] ... APIC ICR: 000008fb
[    7.770000] ... APIC ICR2: 01000000
[    7.770000] ... APIC LVTT: 000200ef
[    7.770000] ... APIC LVTPC: 00010400
[    7.770000] ... APIC LVT0: 00010700
[    7.770000] ... APIC LVT1: 00010400
[    7.770000] ... APIC LVTERR: 000000fe
[    7.770000] ... APIC TMICT: 0001eace
[    7.770000] ... APIC TMCCT: 000038c0
[    7.770000] ... APIC TDCR: 00000003
[    7.770000]=20
[    7.880006] number of MP IRQ sources: 16.
[    7.883982] number of IO-APIC #2 registers: 24.
[    7.884503] testing the IO APIC.......................
[    7.890006]=20
[    7.891471] IO APIC #2......
[    7.894328] .... register #00: 00000000
[    7.898138] .......    : physical APIC id: 00
[    7.900003] .......    : Delivery Type: 0
[    7.903982] .......    : LTS          : 0
[    7.910003] .... register #01: 00170011
[    7.913809] .......     : max redirection entries: 0017
[    7.920003] .......     : PRQ implemented: 0
[    7.924243] .......     : IO APIC version: 0011
[    7.928747] .... register #02: 00000000
[    7.930002] .......     : arbitration: 00
[    7.933982] .... IRQ redirection table:
[    7.940002]  NR Dst Mask Trig IRR Pol Stat Dmod Deli Vect:  =20
[    7.945718]  00 003 0    0    0   0   0    1    1    30
[    7.950005]  01 003 0    0    0   0   0    1    1    31
[    7.955198]  02 003 1    0    0   0   0    0    0    32
[    7.960005]  03 003 1    0    0   0   0    1    1    33
[    7.965198]  04 003 0    0    0   0   0    1    1    34
[    7.970005]  05 003 1    0    0   0   0    1    1    35
[    7.975197]  06 003 0    0    0   0   0    1    1    36
[    7.980004] Clocksource tsc unstable (delta =3D 106007164 ns)
[    7.985561]  07 003 1    0    0   0   0    1    1    37
[    7.993205]  08 003 0    0    0   0   0    1    1    38
[    7.998402]  09 003 0    1    0   0   0    1    1    39
[    8.003206]  0a 003 0    0    0   0   0    1    1    3A
[    8.008403]  0b 003 1    0    0   0   0    1    1    3B
[    8.013206]  0c 003 0    0    0   0   0    1    1    3C
[    8.018402]  0d 003 0    0    0   0   0    1    1    3D
[    8.023206]  0e 003 0    0    0   0   0    1    1    3E
[    8.030005]  0f 003 0    0    0   0   0    1    1    3F
[    8.035198]  10 000 1    0    0   0   0    0    0    00
[    8.040005]  11 000 1    0    0   0   0    0    0    00
[    8.045198]  12 000 1    0    0   0   0    0    0    00
[    8.050005]  13 000 1    0    0   0   0    0    0    00
[    8.055197]  14 000 1    0    0   0   0    0    0    00
[    8.060005]  15 000 1    0    0   0   0    0    0    00
[    8.065198]  16 000 1    0    0   0   0    0    0    00
[    8.070005]  17 000 1    0    0   0   0    0    0    00
[    8.075195] IRQ to pin mappings:
[    8.080003] IRQ0 -> 0:0
[    8.082424] IRQ1 -> 0:1
[    8.084849] IRQ2 -> 0:2
[    8.087274] IRQ3 -> 0:3
[    8.089699] IRQ4 -> 0:4
[    8.090691] IRQ5 -> 0:5
[    8.093117] IRQ6 -> 0:6
[    8.095541] IRQ7 -> 0:7
[    8.097966] IRQ8 -> 0:8
[    8.100691] IRQ9 -> 0:9
[    8.103117] IRQ10 -> 0:10
[    8.105715] IRQ11 -> 0:11
[    8.108313] IRQ12 -> 0:12
[    8.110779] IRQ13 -> 0:13
[    8.113377] IRQ14 -> 0:14
[    8.115975] IRQ15 -> 0:15
[    8.120028] .................................... done.
[    8.125049] initcall print_all_ICs+0x0/0x5f returned 0 after 361328 =
usecs
[    8.130005] calling  hpet_late_init+0x0/0x96 @ 1
[    8.134591] initcall hpet_late_init+0x0/0x96 returned -19 after 0 us=
ecs
[    8.140005] calling  clocksource_done_booting+0x0/0x11 @ 1
[    8.145457] initcall clocksource_done_booting+0x0/0x11 returned 0 af=
ter 0 usecs
[    8.150004] calling  ftrace_init_debugfs+0x0/0x9e @ 1
[    8.160222] initcall ftrace_init_debugfs+0x0/0x9e returned 0 after 0=
 usecs
[    8.166972] calling  rb_init_debugfs+0x0/0x27 @ 1
[    8.170019] initcall rb_init_debugfs+0x0/0x27 returned 0 after 0 use=
cs
[    8.176496] calling  tracer_init_debugfs+0x0/0x1ed @ 1
[    8.180729] initcall tracer_init_debugfs+0x0/0x1ed returned 0 after =
0 usecs
[    8.190005] calling  init_trace_printk_function_export+0x0/0x2a @ 1
[    8.196250] initcall init_trace_printk_function_export+0x0/0x2a retu=
rned 0 after 0 usecs
[    8.200004] calling  event_trace_init+0x0/0x1a0 @ 1
[    8.234203] initcall event_trace_init+0x0/0x1a0 returned 0 after 195=
31 usecs
[    8.240006] calling  ksym_tracer_stat_init+0x0/0x27 @ 1
[    8.245217] initcall ksym_tracer_stat_init+0x0/0x27 returned 0 after=
 0 usecs
[    8.250006] calling  init_pipe_fs+0x0/0x3d @ 1
[    8.254565] initcall init_pipe_fs+0x0/0x3d returned 0 after 0 usecs
[    8.260005] calling  eventpoll_init+0x0/0xb9 @ 1
[    8.264625] initcall eventpoll_init+0x0/0xb9 returned 0 after 0 usec=
s
[    8.270004] calling  anon_inode_init+0x0/0xf0 @ 1
[    8.274790] initcall anon_inode_init+0x0/0xf0 returned 0 after 0 use=
cs
[    8.280005] calling  acpi_event_init+0x0/0x6f @ 1
[    8.320056] initcall acpi_event_init+0x0/0x6f returned 0 after 29296=
 usecs
[    8.326804] calling  pnpacpi_init+0x0/0x7b @ 1
[    8.330004] pnp: PnP ACPI init
[    8.333058] device: 'pnp0': device_add
[    8.336800] PM: Adding info for No Bus:pnp0
[    8.340006] ACPI: bus type pnp registered
[    8.345155] device: '00:00': device_add
[    8.350151] bus: 'pnp': add device 00:00
[    8.354047] PM: Adding info for pnp:00:00
[    8.362596] device: '00:01': device_add
[    8.362596] bus: 'pnp': add device 00:01
[    8.363980] PM: Adding info for pnp:00:01
[    8.381618] device: '00:02': device_add
[    8.385482] bus: 'pnp': add device 00:02
[    8.389370] PM: Adding info for pnp:00:02
[    8.396952] device: '00:03': device_add
[    8.396952] bus: 'pnp': add device 00:03
[    8.400183] PM: Adding info for pnp:00:03
[    8.409062] IOAPIC[0]: Set routing entry (2-8 -> 0x38 -> IRQ 8 Mode:=
0 Active:0)
[    8.410122] device: '00:04': device_add
[    8.413981] bus: 'pnp': add device 00:04
[    8.420153] PM: Adding info for pnp:00:04
[    8.429131] device: '00:05': device_add
[    8.429131] bus: 'pnp': add device 00:05
[    8.430093] PM: Adding info for pnp:00:05
[    8.441757] IOAPIC[0]: Set routing entry (2-13 -> 0x3d -> IRQ 13 Mod=
e:0 Active:0)
[    8.441757] device: '00:06': device_add
[    8.443956] bus: 'pnp': add device 00:06
[    8.450112] PM: Adding info for pnp:00:06
[    8.461226] IOAPIC[0]: Set routing entry (2-6 -> 0x36 -> IRQ 6 Mode:=
0 Active:0)
[    8.467383] device: '00:07': device_add
[    8.470158] bus: 'pnp': add device 00:07
[    8.474046] PM: Adding info for pnp:00:07
[    8.482640] IOAPIC[0]: Set routing entry (2-4 -> 0x34 -> IRQ 4 Mode:=
0 Active:0)
[    8.489585] device: '00:08': device_add
[    8.490250] bus: 'pnp': add device 00:08
[    8.500003] PM: Adding info for pnp:00:08
[    8.507287] IOAPIC[0]: Set routing entry (2-7 -> 0x37 -> IRQ 7 Mode:=
0 Active:0)
[    8.510246] device: '00:09': device_add
[    8.514129] bus: 'pnp': add device 00:09
[    8.520088] PM: Adding info for pnp:00:09
[    8.531386] IOAPIC[0]: Set routing entry (2-12 -> 0x3c -> IRQ 12 Mod=
e:0 Active:0)
[    8.531386] device: '00:0a': device_add
[    8.540254] bus: 'pnp': add device 00:0a
[    8.544144] PM: Adding info for pnp:00:0a
[    8.551682] IOAPIC[0]: Set routing entry (2-1 -> 0x31 -> IRQ 1 Mode:=
0 Active:0)
[    8.560033] device: '00:0b': device_add
[    8.563808] bus: 'pnp': add device 00:0b
[    8.564059] PM: Adding info for pnp:00:0b
[    8.572037] IOAPIC[0]: Set routing entry (2-10 -> 0x3a -> IRQ 10 Mod=
e:0 Active:0)
[    8.579257] device: '00:0c': device_add
[    8.580165] bus: 'pnp': add device 00:0c
[    8.584052] PM: Adding info for pnp:00:0c
[    8.594543] device: '00:0d': device_add
[    8.596681] bus: 'pnp': add device 00:0d
[    8.600184] PM: Adding info for pnp:00:0d
[    8.609112] device: '00:0e': device_add
[    8.610223] bus: 'pnp': add device 00:0e
[    8.614113] PM: Adding info for pnp:00:0e
[    8.621620] device: '00:0f': device_add
[    8.624727] bus: 'pnp': add device 00:0f
[    8.628621] PM: Adding info for pnp:00:0f
[    8.636191] pnp: PnP ACPI: found 16 devices
[    8.636191] ACPI: ACPI bus type pnp unregistered
[    8.640009] initcall pnpacpi_init+0x0/0x7b returned 0 after 302734 u=
secs
[    8.646669] calling  pnpbios_init+0x0/0xba @ 1
[    8.650005] PnPBIOS: Disabled by ACPI PNP
[    8.653985] initcall pnpbios_init+0x0/0xba returned -19 after 0 usec=
s
[    8.660007] calling  pnp_system_init+0x0/0xf @ 1
[    8.664591] bus: 'pnp': add driver system
[    8.670029] bus: 'pnp': driver_probe_device: matched device 00:01 wi=
th driver system
[    8.677708] bus: 'pnp': really_probe: probing driver system with dev=
ice 00:01
[    8.680043] system 00:01: ioport range 0x4000-0x407f has been reserv=
ed
[    8.690016] system 00:01: ioport range 0x4080-0x40ff has been reserv=
ed
[    8.696506] system 00:01: ioport range 0x4400-0x447f has been reserv=
ed
[    8.700014] system 00:01: ioport range 0x4480-0x44ff has been reserv=
ed
[    8.710014] system 00:01: ioport range 0x4800-0x487f has been reserv=
ed
[    8.716506] system 00:01: ioport range 0x4880-0x48ff has been reserv=
ed
[    8.720003] driver: '00:01': driver_bound: bound to device 'system'
[    8.730004] bus: 'pnp': really_probe: bound device 00:01 to driver s=
ystem
[    8.736758] bus: 'pnp': driver_probe_device: matched device 00:02 wi=
th driver system
[    8.740003] bus: 'pnp': really_probe: probing driver system with dev=
ice 00:02
[    8.750038] system 00:02: ioport range 0x4d0-0x4d1 has been reserved
[    8.756334] system 00:02: ioport range 0x800-0x805 has been reserved
[    8.760014] system 00:02: ioport range 0x290-0x297 has been reserved
[    8.770003] driver: '00:02': driver_bound: bound to device 'system'
[    8.776236] bus: 'pnp': really_probe: bound device 00:02 to driver s=
ystem
[    8.780016] bus: 'pnp': driver_probe_device: matched device 00:0e wi=
th driver system
[    8.790003] bus: 'pnp': really_probe: probing driver system with dev=
ice 00:0e
[    8.800038] system 00:0e: iomem range 0xe0000000-0xefffffff has been=
 reserved
[    8.807100] driver: '00:0e': driver_bound: bound to device 'system'
[    8.810004] bus: 'pnp': really_probe: bound device 00:0e to driver s=
ystem
[    8.820006] bus: 'pnp': driver_probe_device: matched device 00:0f wi=
th driver system
[    8.827707] bus: 'pnp': really_probe: probing driver system with dev=
ice 00:0f
[    8.830044] system 00:0f: iomem range 0xf0000-0xf3fff could not be r=
eserved
[    8.840019] system 00:0f: iomem range 0xf4000-0xf7fff could not be r=
eserved
[    8.846943] system 00:0f: iomem range 0xf8000-0xfbfff could not be r=
eserved
[    8.850019] system 00:0f: iomem range 0xfc000-0xfffff could not be r=
eserved
[    8.860019] system 00:0f: iomem range 0x3fff0000-0x3fffffff could no=
t be reserved
[    8.870013] system 00:0f: iomem range 0xffff0000-0xffffffff has been=
 reserved
[    8.877118] system 00:0f: iomem range 0x0-0x9ffff could not be reser=
ved
[    8.880019] system 00:0f: iomem range 0x100000-0x3ffeffff could not =
be reserved
[    8.890014] system 00:0f: iomem range 0xfec00000-0xfec00fff has been=
 reserved
[    8.897113] system 00:0f: iomem range 0xfee00000-0xfeefffff has been=
 reserved
[    8.900014] system 00:0f: iomem range 0xfefff000-0xfeffffff has been=
 reserved
[    8.910016] system 00:0f: iomem range 0xfff80000-0xfff80fff has been=
 reserved
[    8.917111] system 00:0f: iomem range 0xfff90000-0xfffbffff has been=
 reserved
[    8.930014] system 00:0f: iomem range 0xfffed000-0xfffeffff has been=
 reserved
[    8.937100] driver: '00:0f': driver_bound: bound to device 'system'
[    8.937100] bus: 'pnp': really_probe: bound device 00:0f to driver s=
ystem
[    8.950354] initcall pnp_system_init+0x0/0xf returned 0 after 273437=
 usecs
[    8.956971] calling  chr_dev_init+0x0/0x89 @ 1
[    8.956971] device class 'mem': registering
[    8.966014] device: 'mem': device_add
[    8.966014] PM: Adding info for No Bus:mem
[    8.973879] device: 'kmem': device_add
[    8.973979] PM: Adding info for No Bus:kmem
[    8.981932] device: 'null': device_add
[    8.981932] PM: Adding info for No Bus:null
[    8.989934] device: 'port': device_add
[    8.990085] PM: Adding info for No Bus:port
[    8.997939] device: 'zero': device_add
[    8.998067] PM: Adding info for No Bus:zero
[    9.005961] device: 'full': device_add
[    9.005961] PM: Adding info for No Bus:full
[    9.013981] device: 'random': device_add
[    9.014090] PM: Adding info for No Bus:random
[    9.022334] device: 'urandom': device_add
[    9.022334] PM: Adding info for No Bus:urandom
[    9.030862] device: 'kmsg': device_add
[    9.030862] PM: Adding info for No Bus:kmsg
[    9.038863] initcall chr_dev_init+0x0/0x89 returned 0 after 68359 us=
ecs
[    9.040014] calling  firmware_class_init+0x0/0x61 @ 1
[    9.045022] device class 'firmware': registering
[    9.055208] initcall firmware_class_init+0x0/0x61 returned 0 after 0=
 usecs
[    9.056982] calling  init_acpi_pm_clocksource+0x0/0x12f @ 1
[    9.098681] initcall init_acpi_pm_clocksource+0x0/0x12f returned 0 a=
fter 39062 usecs
[    9.100005] calling  ssb_modinit+0x0/0x7a @ 1
[    9.110040] Switched to high resolution mode on CPU 0
[    9.119115] Switched to high resolution mode on CPU 1
[    9.124423] bus: 'ssb': registered
[    9.127724] bus: 'pci': add driver b43-pci-bridge
[    9.132700] initcall ssb_modinit+0x0/0x7a returned 0 after 8357 usec=
s
[    9.139021] calling  pcibios_assign_resources+0x0/0x81 @ 1
[    9.144798] pci 0000:00:09.0: PCI bridge, secondary bus 0000:05
[    9.150604] pci 0000:00:09.0:   IO window: 0xc000-0xcfff
[    9.155915] pci 0000:00:09.0:   MEM window: 0xda000000-0xda0fffff
[    9.161961] pci 0000:00:09.0:   PREFETCH window: disabled
[    9.167352] pci 0000:00:0b.0: PCI bridge, secondary bus 0000:04
[    9.173235] pci 0000:00:0b.0:   IO window: disabled
[    9.178086] pci 0000:00:0b.0:   MEM window: disabled
[    9.183037] pci 0000:00:0b.0:   PREFETCH window: disabled
[    9.188397] pci 0000:00:0c.0: PCI bridge, secondary bus 0000:03
[    9.194295] pci 0000:00:0c.0:   IO window: disabled
[    9.199146] pci 0000:00:0c.0:   MEM window: disabled
[    9.204097] pci 0000:00:0c.0:   PREFETCH window: disabled
[    9.209457] pci 0000:00:0d.0: PCI bridge, secondary bus 0000:02
[    9.215355] pci 0000:00:0d.0:   IO window: disabled
[    9.220207] pci 0000:00:0d.0:   MEM window: disabled
[    9.225157] pci 0000:00:0d.0:   PREFETCH window: disabled
[    9.230527] pci 0000:01:00.0: BAR 6: got res [0xd8000000-0xd801ffff]=
 bus [0xd8000000-0xd801ffff] flags 0x27200
[    9.240492] pci 0000:00:0e.0: PCI bridge, secondary bus 0000:01
[    9.246385] pci 0000:00:0e.0:   IO window: 0xb000-0xbfff
[    9.251667] pci 0000:00:0e.0:   MEM window: 0xd8000000-0xd9ffffff
[    9.257745] pci 0000:00:0e.0:   PREFETCH window: 0x000000d0000000-0x=
000000d7ffffff
[    9.265314] pci 0000:00:09.0: setting latency timer to 64
[    9.270666] pci 0000:00:0b.0: setting latency timer to 64
[    9.276055] pci 0000:00:0c.0: setting latency timer to 64
[    9.281413] pci 0000:00:0d.0: setting latency timer to 64
[    9.286801] pci 0000:00:0e.0: setting latency timer to 64
[    9.292135] pci_bus 0000:00: resource 0 io:  [0x00-0xffff]
[    9.297603] pci_bus 0000:00: resource 1 mem: [0x000000-0xfffffffffff=
fffff]
[    9.304451] pci_bus 0000:05: resource 0 io:  [0xc000-0xcfff]
[    9.310068] pci_bus 0000:05: resource 1 mem: [0xda000000-0xda0fffff]
[    9.316410] pci_bus 0000:05: resource 3 io:  [0x00-0xffff]
[    9.321856] pci_bus 0000:05: resource 4 mem: [0x000000-0xfffffffffff=
fffff]
[    9.328718] pci_bus 0000:01: resource 0 io:  [0xb000-0xbfff]
[    9.334350] pci_bus 0000:01: resource 1 mem: [0xd8000000-0xd9ffffff]
[    9.340662] pci_bus 0000:01: resource 2 pref mem [0xd0000000-0xd7fff=
fff]
[    9.347354] initcall pcibios_assign_resources+0x0/0x81 returned 0 af=
ter 198092 usecs
[    9.355064] calling  sysctl_core_init+0x0/0x2d @ 1
[    9.359850] initcall sysctl_core_init+0x0/0x2d returned 0 after 31 u=
secs
[    9.366505] calling  inet_init+0x0/0x199 @ 1
[    9.370780] NET: Registered protocol family 2
[    9.375275] IP route cache hash table entries: 32768 (order: 5, 1310=
72 bytes)
[    9.382986] TCP established hash table entries: 131072 (order: 8, 10=
48576 bytes)
[    9.391994] TCP bind hash table entries: 65536 (order: 9, 2621440 by=
tes)
[    9.405163] TCP: Hash tables configured (established 131072 bind 655=
36)
[    9.411692] TCP reno registered
[    9.415146] initcall inet_init+0x0/0x199 returned 0 after 43359 usec=
s
[    9.421463] calling  af_unix_init+0x0/0x47 @ 1
[    9.425910] NET: Registered protocol family 1
[    9.430247] initcall af_unix_init+0x0/0x47 returned 0 after 4245 use=
cs
[    9.436734] calling  default_rootfs+0x0/0x65 @ 1
[    9.441449] initcall default_rootfs+0x0/0x65 returned 0 after 133 us=
ecs
[    9.447964] calling  vmx_init+0x0/0x20a @ 1
[    9.452657] kvm: no hardware support
[    9.456120] initcall vmx_init+0x0/0x20a returned -95 after 3914 usec=
s
[    9.462543] initcall vmx_init+0x0/0x20a returned with error code -95=
=20
[    9.468940] calling  i8259A_init_sysfs+0x0/0x1d @ 1
[    9.473808] Registering sysdev class 'i8259'
[    9.478287] Registering sys device of class 'i8259'
[    9.483087] Registering sys device 'i82590'
[    9.487411] initcall i8259A_init_sysfs+0x0/0x1d returned 0 after 132=
85 usecs
[    9.494413] calling  sbf_init+0x0/0xda @ 1
[    9.498420] initcall sbf_init+0x0/0xda returned 0 after 1 usecs
[    9.504325] calling  i8237A_init_sysfs+0x0/0x1d @ 1
[    9.509162] Registering sysdev class 'i8237'
[    9.513637] Registering sys device of class 'i8237'
[    9.518407] Registering sys device 'i82370'
[    9.522776] initcall i8237A_init_sysfs+0x0/0x1d returned 0 after 132=
89 usecs
[    9.529701] calling  add_rtc_cmos+0x0/0x94 @ 1
[    9.534150] initcall add_rtc_cmos+0x0/0x94 returned 0 after 4 usecs
[    9.540364] calling  cache_sysfs_init+0x0/0x5a @ 1
[    9.547352] initcall cache_sysfs_init+0x0/0x5a returned 0 after 2155=
 usecs
[    9.554129] calling  cpu_debug_init+0x0/0xe3 @ 1
[    9.564706] cpu0(2) debug files 137
[    9.573270] cpu1(2) debug files 137
[    9.576647] initcall cpu_debug_init+0x0/0xe3 returned 0 after 17519 =
usecs
[    9.583418] calling  cpuid_init+0x0/0x115 @ 1
[    9.587764] device class 'cpuid': registering
[    9.592336] device: 'cpu0': device_add
[    9.596111] PM: Adding info for No Bus:cpu0
[    9.600571] device: 'cpu1': device_add
[    9.604291] PM: Adding info for No Bus:cpu1
[    9.608598] initcall cpuid_init+0x0/0x115 returned 0 after 20370 use=
cs
[    9.615033] calling  ioapic_init_sysfs+0x0/0x84 @ 1
[    9.619864] Registering sysdev class 'ioapic'
[    9.624432] Registering sys device of class 'ioapic'
[    9.629290] Registering sys device 'ioapic0'
[    9.633751] initcall ioapic_init_sysfs+0x0/0x84 returned 0 after 135=
55 usecs
[    9.640679] calling  add_pcspkr+0x0/0x24 @ 1
[    9.644959] Registering platform device 'pcspkr'. Parent at platform
[    9.651257] device: 'pcspkr': device_add
[    9.655191] bus: 'platform': add device pcspkr
[    9.659630] PM: Adding info for platform:pcspkr
[    9.664313] initcall add_pcspkr+0x0/0x24 returned 0 after 18907 usec=
s
[    9.670632] calling  scx200_init+0x0/0x20 @ 1
[    9.674989] scx200: NatSemi SCx200 Driver
[    9.678955] bus: 'pci': add driver scx200
[    9.683334] initcall scx200_init+0x0/0x20 returned 0 after 8147 usec=
s
[    9.689657] calling  start_periodic_check_for_corruption+0x0/0x37 @ =
1
[    9.696092] Scanning for low memory corruption every 60 seconds
[    9.701968] initcall start_periodic_check_for_corruption+0x0/0x37 re=
turned 0 after 5741 usecs
[    9.710475] calling  pt_dump_init+0x0/0x56 @ 1
[    9.714911] initcall pt_dump_init+0x0/0x56 returned 0 after 18 usecs
[    9.721202] calling  init_sched_debug_procfs+0x0/0x27 @ 1
[    9.726615] initcall init_sched_debug_procfs+0x0/0x27 returned 0 aft=
er 20 usecs
[    9.733873] calling  proc_schedstat_init+0x0/0x1c @ 1
[    9.738900] initcall proc_schedstat_init+0x0/0x1c returned 0 after 1=
4 usecs
[    9.745832] calling  proc_execdomains_init+0x0/0x1c @ 1
[    9.751034] initcall proc_execdomains_init+0x0/0x1c returned 0 after=
 13 usecs
[    9.758139] calling  ioresources_init+0x0/0x31 @ 1
[    9.762935] initcall ioresources_init+0x0/0x31 returned 0 after 26 u=
secs
[    9.769563] calling  uid_cache_init+0x0/0x78 @ 1
[    9.774203] initcall uid_cache_init+0x0/0x78 returned 0 after 27 use=
cs
[    9.780656] calling  init_posix_timers+0x0/0xa9 @ 1
[    9.785541] initcall init_posix_timers+0x0/0xa9 returned 0 after 12 =
usecs
[    9.792270] calling  init_posix_cpu_timers+0x0/0x8d @ 1
[    9.797490] initcall init_posix_cpu_timers+0x0/0x8d returned 0 after=
 1 usecs
[    9.804507] calling  nsproxy_cache_init+0x0/0x27 @ 1
[    9.809440] initcall nsproxy_cache_init+0x0/0x27 returned 0 after 7 =
usecs
[    9.816210] calling  create_proc_profile+0x0/0x65 @ 1
[    9.821221] initcall create_proc_profile+0x0/0x65 returned 0 after 1=
 usecs
[    9.828080] calling  timekeeping_init_device+0x0/0x1d @ 1
[    9.833455] Registering sysdev class 'timekeeping'
[    9.838433] Registering sys device of class 'timekeeping'
[    9.843764] Registering sys device 'timekeeping0'
[    9.848603] initcall timekeeping_init_device+0x0/0x1d returned 0 aft=
er 14795 usecs
[    9.856105] calling  init_clocksource_sysfs+0x0/0x43 @ 1
[    9.861363] Registering sysdev class 'clocksource'
[    9.866370] Registering sys device of class 'clocksource'
[    9.871670] Registering sys device 'clocksource0'
[    9.876578] initcall init_clocksource_sysfs+0x0/0x43 returned 0 afte=
r 14852 usecs
[    9.883990] calling  init_timer_list_procfs+0x0/0x27 @ 1
[    9.889271] initcall init_timer_list_procfs+0x0/0x27 returned 0 afte=
r 16 usecs
[    9.896461] calling  init_tstats_procfs+0x0/0x27 @ 1
[    9.901406] initcall init_tstats_procfs+0x0/0x27 returned 0 after 16=
 usecs
[    9.908247] calling  lockdep_proc_init+0x0/0x67 @ 1
[    9.913158] initcall lockdep_proc_init+0x0/0x67 returned 0 after 54 =
usecs
[    9.919845] calling  futex_init+0x0/0x91 @ 1
[    9.924137] initcall futex_init+0x0/0x91 returned 0 after 26 usecs
[    9.930245] calling  proc_dma_init+0x0/0x1c @ 1
[    9.934784] initcall proc_dma_init+0x0/0x1c returned 0 after 14 usec=
s
[    9.941165] calling  kallsyms_init+0x0/0x1f @ 1
[    9.945705] initcall kallsyms_init+0x0/0x1f returned 0 after 14 usec=
s
[    9.952086] calling  crash_save_vmcoreinfo_init+0x0/0x348 @ 1
[    9.957850] initcall crash_save_vmcoreinfo_init+0x0/0x348 returned 0=
 after 26 usecs
[    9.965449] calling  crash_notes_memory_init+0x0/0x31 @ 1
[    9.970815] initcall crash_notes_memory_init+0x0/0x31 returned 0 aft=
er 6 usecs
[    9.978016] calling  rcu_torture_init+0x0/0x591 @ 1
[    9.982892] rcu-torture:--- Start of test: nreaders=3D4 nfakewriters=
=3D4 stat_interval=3D0 verbose=3D0 test_no_idle_hz=3D0 shuffle_interval=
=3D3 stutter=3D5 irqreader=3D1
[    9.997267] initcall rcu_torture_init+0x0/0x591 returned 0 after 140=
60 usecs
[   10.004216] calling  rcuclassic_trace_init+0x0/0x123 @ 1
[   10.009581] initcall rcuclassic_trace_init+0x0/0x123 returned 0 afte=
r 98 usecs
[   10.016722] calling  utsname_sysctl_init+0x0/0x11 @ 1
[   10.021744] initcall utsname_sysctl_init+0x0/0x11 returned 0 after 9=
 usecs
[   10.028595] calling  ftrace_mod_cmd_init+0x0/0xf @ 1
[   10.033559] initcall ftrace_mod_cmd_init+0x0/0xf returned 0 after 21=
 usecs
[   10.040365] calling  init_events+0x0/0x5a @ 1
[   10.044723] initcall init_events+0x0/0x5a returned 0 after 6 usecs
[   10.050852] calling  init_sched_switch_trace+0x0/0xf @ 1
[   10.056160] Testing tracer sched_switch: PASSED
[   10.173225] initcall init_sched_switch_trace+0x0/0xf returned 0 afte=
r 114325 usecs
[   10.180757] calling  init_stack_trace+0x0/0xf @ 1
[   10.185457] Testing tracer sysprof: .. no entries found ..FAILED!
[   10.295131] initcall init_stack_trace+0x0/0xf returned -1 after 1071=
05 usecs
[   10.302143] initcall init_stack_trace+0x0/0xf returned with error co=
de -1=20
[   10.309009] calling  init_function_trace+0x0/0x35 @ 1
[   10.314039] Testing tracer function: PASSED
[   10.453522] Testing dynamic ftrace: PASSED
[   10.730920] initcall init_function_trace+0x0/0x35 returned 0 after 4=
07108 usecs
[   10.738188] calling  init_wakeup_tracer+0x0/0x1d @ 1
[   10.743153] Testing tracer wakeup: PASSED
[   11.103151] Testing tracer wakeup_rt: PASSED
[   11.463140] initcall init_wakeup_tracer+0x0/0x1d returned 0 after 70=
3112 usecs
[   11.470345] calling  stack_trace_init+0x0/0x5b @ 1
[   11.475137] initcall stack_trace_init+0x0/0x5b returned 0 after 43 u=
secs
[   11.481782] calling  init_kmem_tracer+0x0/0xf @ 1
[   11.486450] initcall init_kmem_tracer+0x0/0xf returned 0 after 3 use=
cs
[   11.492962] calling  init_blk_tracer+0x0/0x4b @ 1
[   11.497630] initcall init_blk_tracer+0x0/0x4b returned 0 after 4 use=
cs
[   11.504141] calling  register_ftrace_syscalls+0x0/0x93 @ 1
[   11.509589] initcall register_ftrace_syscalls+0x0/0x93 returned 0 af=
ter 4 usecs
[   11.516884] calling  init_ksym_trace+0x0/0x47 @ 1
[   11.521580] Testing tracer ksym_tracer: PASSED
[   11.560658] initcall init_ksym_trace+0x0/0x47 returned 0 after 38176=
 usecs
[   11.567494] calling  perf_counter_sysfs_init+0x0/0x14 @ 1
[   11.572942] initcall perf_counter_sysfs_init+0x0/0x14 returned 0 aft=
er 49 usecs
[   11.580168] calling  init_per_zone_wmark_min+0x0/0x59 @ 1
[   11.585556] initcall init_per_zone_wmark_min+0x0/0x59 returned 0 aft=
er 30 usecs
[   11.592820] calling  pdflush_init+0x0/0x1b @ 1
[   11.597385] initcall pdflush_init+0x0/0x1b returned 0 after 155 usec=
s
[   11.603729] calling  kswapd_init+0x0/0x1d @ 1
[   11.608113] initcall kswapd_init+0x0/0x1d returned 0 after 69 usecs
[   11.614299] calling  init_tmpfs+0x0/0xb9 @ 1
[   11.618730] initcall init_tmpfs+0x0/0xb9 returned 0 after 196 usecs
[   11.624901] calling  setup_vmstat+0x0/0xa8 @ 1
[   11.629367] initcall setup_vmstat+0x0/0xa8 returned 0 after 64 usecs
[   11.635643] calling  mm_sysfs_init+0x0/0x22 @ 1
[   11.640180] initcall mm_sysfs_init+0x0/0x22 returned 0 after 28 usec=
s
[   11.646544] calling  proc_vmalloc_init+0x0/0x1f @ 1
[   11.651438] initcall proc_vmalloc_init+0x0/0x1f returned 0 after 16 =
usecs
[   11.658158] calling  slab_proc_init+0x0/0x1f @ 1
[   11.662788] initcall slab_proc_init+0x0/0x1f returned 0 after 15 use=
cs
[   11.669251] calling  slab_sysfs_init+0x0/0xb6 @ 1
[   11.702622] initcall slab_sysfs_init+0x0/0xb6 returned 0 after 27994=
 usecs
[   11.709386] calling  fasync_init+0x0/0x24 @ 1
[   11.713879] initcall fasync_init+0x0/0x24 returned 0 after 24 usecs
[   11.720068] calling  proc_filesystems_init+0x0/0x1c @ 1
[   11.725248] initcall proc_filesystems_init+0x0/0x1c returned 0 after=
 22 usecs
[   11.732920] calling  aio_setup+0x0/0x94 @ 1
[   11.737269] initcall aio_setup+0x0/0x94 returned 0 after 199 usecs
[   11.743361] calling  proc_locks_init+0x0/0x1c @ 1
[   11.748035] initcall proc_locks_init+0x0/0x1c returned 0 after 16 us=
ecs
[   11.754621] calling  init_mbcache+0x0/0x11 @ 1
[   11.759028] initcall init_mbcache+0x0/0x11 returned 0 after 2 usecs
[   11.765282] calling  dquot_init+0x0/0xc8 @ 1
[   11.769511] VFS: Disk quotas dquot_6.5.2
[   11.773999] Dquot-cache hash table entries: 1024 (order 0, 4096 byte=
s)
[   11.780497] initcall dquot_init+0x0/0xc8 returned 0 after 10723 usec=
s
[   11.786817] calling  init_v1_quota_format+0x0/0xf @ 1
[   11.791868] initcall init_v1_quota_format+0x0/0xf returned 0 after 3=
 usecs
[   11.798689] calling  init_v2_quota_format+0x0/0xf @ 1
[   11.803739] initcall init_v2_quota_format+0x0/0xf returned 0 after 1=
 usecs
[   11.810581] calling  proc_cmdline_init+0x0/0x1c @ 1
[   11.815436] initcall proc_cmdline_init+0x0/0x1c returned 0 after 16 =
usecs
[   11.822198] calling  proc_cpuinfo_init+0x0/0x1c @ 1
[   11.827049] initcall proc_cpuinfo_init+0x0/0x1c returned 0 after 16 =
usecs
[   11.833809] calling  proc_devices_init+0x0/0x1c @ 1
[   11.838662] initcall proc_devices_init+0x0/0x1c returned 0 after 14 =
usecs
[   11.845424] calling  proc_interrupts_init+0x0/0x1c @ 1
[   11.850551] initcall proc_interrupts_init+0x0/0x1c returned 0 after =
14 usecs
[   11.857536] calling  proc_loadavg_init+0x0/0x1c @ 1
[   11.862431] initcall proc_loadavg_init+0x0/0x1c returned 0 after 15 =
usecs
[   11.869150] calling  proc_meminfo_init+0x0/0x1c @ 1
[   11.874041] initcall proc_meminfo_init+0x0/0x1c returned 0 after 15 =
usecs
[   11.880782] calling  proc_stat_init+0x0/0x1c @ 1
[   11.885376] initcall proc_stat_init+0x0/0x1c returned 0 after 15 use=
cs
[   11.891877] calling  proc_uptime_init+0x0/0x1c @ 1
[   11.896643] initcall proc_uptime_init+0x0/0x1c returned 0 after 15 u=
secs
[   11.903319] calling  proc_version_init+0x0/0x1c @ 1
[   11.908169] initcall proc_version_init+0x0/0x1c returned 0 after 15 =
usecs
[   11.914930] calling  proc_softirqs_init+0x0/0x1c @ 1
[   11.919869] initcall proc_softirqs_init+0x0/0x1c returned 0 after 15=
 usecs
[   11.926717] calling  proc_kcore_init+0x0/0x40 @ 1
[   11.931413] initcall proc_kcore_init+0x0/0x40 returned 0 after 15 us=
ecs
[   11.937964] calling  proc_kmsg_init+0x0/0x1f @ 1
[   11.942596] initcall proc_kmsg_init+0x0/0x1f returned 0 after 15 use=
cs
[   11.949058] calling  proc_page_init+0x0/0x37 @ 1
[   11.953701] initcall proc_page_init+0x0/0x37 returned 0 after 27 use=
cs
[   11.960170] calling  configfs_init+0x0/0xd6 @ 1
[   11.965259] initcall configfs_init+0x0/0xd6 returned 0 after 584 use=
cs
[   11.971698] calling  init_devpts_fs+0x0/0x3d @ 1
[   11.976455] initcall init_devpts_fs+0x0/0x3d returned 0 after 183 us=
ecs
[   11.982973] calling  init_dlm+0x0/0x7f @ 1
[   11.987346] device: 'dlm-control': device_add
[   11.991688] PM: Adding info for No Bus:dlm-control
[   11.996594] device: 'dlm-monitor': device_add
[   12.000948] PM: Adding info for No Bus:dlm-monitor
[   12.005864] device: 'dlm_plock': device_add
[   12.010038] PM: Adding info for No Bus:dlm_plock
[   12.014739] DLM (built Jul  2 2009 09:18:03) installed
[   12.019761] initcall init_dlm+0x0/0x7f returned 0 after 31967 usecs
[   12.026032] calling  init_ext3_fs+0x0/0x64 @ 1
[   12.031558] initcall init_ext3_fs+0x0/0x64 returned 0 after 1074 use=
cs
[   12.037961] calling  journal_init+0x0/0xb6 @ 1
[   12.044207] initcall journal_init+0x0/0xb6 returned 0 after 1732 use=
cs
[   12.050636] calling  journal_init+0x0/0xcf @ 1
[   12.055699] initcall journal_init+0x0/0xcf returned 0 after 644 usec=
s
[   12.062054] calling  init_squashfs_fs+0x0/0x5d @ 1
[   12.067300] squashfs: version 4.0 (2009/01/31) Phillip Lougher
[   12.073081] initcall init_squashfs_fs+0x0/0x5d returned 0 after 6140=
 usecs
[   12.079865] calling  init_ramfs_fs+0x0/0xf @ 1
[   12.084309] initcall init_ramfs_fs+0x0/0xf returned 0 after 2 usecs
[   12.090543] calling  init_minix_fs+0x0/0x54 @ 1
[   12.095548] initcall init_minix_fs+0x0/0x54 returned 0 after 500 use=
cs
[   12.101983] calling  init_bfs_fs+0x0/0x54 @ 1
[   12.106814] initcall init_bfs_fs+0x0/0x54 returned 0 after 507 usecs
[   12.113077] calling  init_iso9660_fs+0x0/0x54 @ 1
[   12.118250] initcall init_iso9660_fs+0x0/0x54 returned 0 after 503 u=
secs
[   12.124857] calling  init_hfs_fs+0x0/0x50 @ 1
[   12.129687] initcall init_hfs_fs+0x0/0x50 returned 0 after 509 usecs
[   12.135950] calling  ecryptfs_init+0x0/0x1ab @ 1
[   12.141517] device: 'ecryptfs': device_add
[   12.145572] PM: Adding info for No Bus:ecryptfs
[   12.150241] initcall ecryptfs_init+0x0/0x1ab returned 0 after 9478 u=
secs
[   12.156817] calling  vxfs_init+0x0/0x4d @ 1
[   12.161548] initcall vxfs_init+0x0/0x4d returned 0 after 529 usecs
[   12.167608] calling  init_nls_cp437+0x0/0xf @ 1
[   12.172168] initcall init_nls_cp437+0x0/0xf returned 0 after 22 usec=
s
[   12.178528] calling  init_nls_cp737+0x0/0xf @ 1
[   12.183058] initcall init_nls_cp737+0x0/0xf returned 0 after 2 usecs
[   12.189361] calling  init_nls_cp775+0x0/0xf @ 1
[   12.193891] initcall init_nls_cp775+0x0/0xf returned 0 after 1 usecs
[   12.200213] calling  init_nls_cp850+0x0/0xf @ 1
[   12.204707] initcall init_nls_cp850+0x0/0xf returned 0 after 2 usecs
[   12.211050] calling  init_nls_cp852+0x0/0xf @ 1
[   12.215541] initcall init_nls_cp852+0x0/0xf returned 0 after 1 usecs
[   12.221880] calling  init_nls_cp855+0x0/0xf @ 1
[   12.226374] initcall init_nls_cp855+0x0/0xf returned 0 after 2 usecs
[   12.232715] calling  init_nls_cp863+0x0/0xf @ 1
[   12.237208] initcall init_nls_cp863+0x0/0xf returned 0 after 2 usecs
[   12.243548] calling  init_nls_cp864+0x0/0xf @ 1
[   12.248040] initcall init_nls_cp864+0x0/0xf returned 0 after 1 usecs
[   12.254384] calling  init_nls_cp866+0x0/0xf @ 1
[   12.258874] initcall init_nls_cp866+0x0/0xf returned 0 after 1 usecs
[   12.265215] calling  init_nls_cp869+0x0/0xf @ 1
[   12.269708] initcall init_nls_cp869+0x0/0xf returned 0 after 2 usecs
[   12.276048] calling  init_nls_cp874+0x0/0xf @ 1
[   12.280558] initcall init_nls_cp874+0x0/0xf returned 0 after 1 usecs
[   12.286863] calling  init_nls_cp932+0x0/0xf @ 1
[   12.291395] initcall init_nls_cp932+0x0/0xf returned 0 after 2 usecs
[   12.297697] calling  init_nls_euc_jp+0x0/0x39 @ 1
[   12.302400] initcall init_nls_euc_jp+0x0/0x39 returned 0 after 3 use=
cs
[   12.308876] calling  init_nls_cp936+0x0/0xf @ 1
[   12.313406] initcall init_nls_cp936+0x0/0xf returned 0 after 2 usecs
[   12.319710] calling  init_nls_cp949+0x0/0xf @ 1
[   12.324239] initcall init_nls_cp949+0x0/0xf returned 0 after 1 usecs
[   12.330562] calling  init_nls_cp950+0x0/0xf @ 1
[   12.335055] initcall init_nls_cp950+0x0/0xf returned 0 after 1 usecs
[   12.341396] calling  init_nls_cp1250+0x0/0xf @ 1
[   12.345976] initcall init_nls_cp1250+0x0/0xf returned 0 after 1 usec=
s
[   12.352403] calling  init_nls_cp1251+0x0/0xf @ 1
[   12.356982] initcall init_nls_cp1251+0x0/0xf returned 0 after 2 usec=
s
[   12.363409] calling  init_nls_ascii+0x0/0xf @ 1
[   12.367902] initcall init_nls_ascii+0x0/0xf returned 0 after 1 usecs
[   12.374245] calling  init_nls_iso8859_1+0x0/0xf @ 1
[   12.379082] initcall init_nls_iso8859_1+0x0/0xf returned 0 after 2 u=
secs
[   12.385770] calling  init_nls_iso8859_3+0x0/0xf @ 1
[   12.390626] initcall init_nls_iso8859_3+0x0/0xf returned 0 after 1 u=
secs
[   12.397277] calling  init_nls_iso8859_4+0x0/0xf @ 1
[   12.402153] initcall init_nls_iso8859_4+0x0/0xf returned 0 after 1 u=
secs
[   12.408804] calling  init_nls_iso8859_5+0x0/0xf @ 1
[   12.413682] initcall init_nls_iso8859_5+0x0/0xf returned 0 after 2 u=
secs
[   12.420349] calling  init_nls_iso8859_6+0x0/0xf @ 1
[   12.425190] initcall init_nls_iso8859_6+0x0/0xf returned 0 after 1 u=
secs
[   12.431877] calling  init_nls_iso8859_7+0x0/0xf @ 1
[   12.436717] initcall init_nls_iso8859_7+0x0/0xf returned 0 after 1 u=
secs
[   12.443404] calling  init_nls_iso8859_9+0x0/0xf @ 1
[   12.448244] initcall init_nls_iso8859_9+0x0/0xf returned 0 after 1 u=
secs
[   12.454932] calling  init_nls_iso8859_13+0x0/0xf @ 1
[   12.459857] initcall init_nls_iso8859_13+0x0/0xf returned 0 after 1 =
usecs
[   12.466631] calling  init_nls_iso8859_14+0x0/0xf @ 1
[   12.471574] initcall init_nls_iso8859_14+0x0/0xf returned 0 after 1 =
usecs
[   12.478312] calling  init_nls_iso8859_15+0x0/0xf @ 1
[   12.483275] initcall init_nls_iso8859_15+0x0/0xf returned 0 after 1 =
usecs
[   12.490032] calling  init_nls_koi8_r+0x0/0xf @ 1
[   12.494610] initcall init_nls_koi8_r+0x0/0xf returned 0 after 2 usec=
s
[   12.501038] calling  init_nls_koi8_u+0x0/0xf @ 1
[   12.505618] initcall init_nls_koi8_u+0x0/0xf returned 0 after 2 usec=
s
[   12.512045] calling  init_nls_koi8_ru+0x0/0x39 @ 1
[   12.516798] initcall init_nls_koi8_ru+0x0/0x39 returned 0 after 2 us=
ecs
[   12.523398] calling  init_sysv_fs+0x0/0x43 @ 1
[   12.528340] initcall init_sysv_fs+0x0/0x43 returned 0 after 524 usec=
s
[   12.534693] calling  init_ntfs_fs+0x0/0x199 @ 1
[   12.539172] NTFS driver 2.1.29 [Flags: R/O].
[   12.544561] initcall init_ntfs_fs+0x0/0x199 returned 0 after 5258 us=
ecs
[   12.551073] calling  init_ufs_fs+0x0/0x54 @ 1
[   12.555913] initcall init_ufs_fs+0x0/0x54 returned 0 after 512 usecs
[   12.562171] calling  init_affs_fs+0x0/0x54 @ 1
[   12.567088] initcall init_affs_fs+0x0/0x54 returned 0 after 506 usec=
s
[   12.573450] calling  init_adfs_fs+0x0/0x54 @ 1
[   12.578344] initcall init_adfs_fs+0x0/0x54 returned 0 after 496 usec=
s
[   12.584688] calling  fuse_init+0x0/0x10a @ 1
[   12.588911] fuse init (API version 7.12)
[   12.593898] device: 'fuse': device_add
[   12.597608] PM: Adding info for No Bus:fuse
[   12.601959] initcall fuse_init+0x0/0x10a returned 0 after 12738 usec=
s
[   12.608279] calling  init_udf_fs+0x0/0x54 @ 1
[   12.613150] initcall init_udf_fs+0x0/0x54 returned 0 after 498 usecs
[   12.619381] calling  init_omfs_fs+0x0/0xf @ 1
[   12.623752] initcall init_omfs_fs+0x0/0xf returned 0 after 3 usecs
[   12.629868] calling  init_jfs_fs+0x0/0x17f @ 1
[   12.635471] JFS: nTxBlock =3D 6800, nTxLock =3D 54407
[   12.644254] initcall init_jfs_fs+0x0/0x17f returned 0 after 9708 use=
cs
[   12.650705] calling  init_xfs_fs+0x0/0xa0 @ 1
[   12.655004] SGI XFS with ACLs, security attributes, large block/inod=
e numbers, no debug enabled
[   12.667457] SGI XFS Quota Management subsystem
[   12.671849] initcall init_xfs_fs+0x0/0xa0 returned 0 after 16443 use=
cs
[   12.678281] calling  init_nilfs_fs+0x0/0x84 @ 1
[   12.684935] initcall init_nilfs_fs+0x0/0x84 returned 0 after 2077 us=
ecs
[   12.691496] calling  init_befs_fs+0x0/0x6d @ 1
[   12.695851] BeFS version: 0.9.3
[   12.699485] initcall init_befs_fs+0x0/0x6d returned 0 after 3549 use=
cs
[   12.705941] calling  ocfs2_init+0x0/0x316 @ 1
[   12.710246] OCFS2 1.5.0
[   12.714070] initcall ocfs2_init+0x0/0x316 returned 0 after 3736 usec=
s
[   12.720420] calling  ocfs2_stack_glue_init+0x0/0x7c @ 1
[   12.725651] initcall ocfs2_stack_glue_init+0x0/0x7c returned 0 after=
 53 usecs
[   12.733316] calling  o2cb_stack_init+0x0/0xf @ 1
[   12.737894] ocfs2: Registered cluster interface o2cb
[   12.742852] initcall o2cb_stack_init+0x0/0xf returned 0 after 4838 u=
secs
[   12.749505] calling  ocfs2_user_plugin_init+0x0/0x4b @ 1
[   12.754829] device: 'ocfs2_control': device_add
[   12.759381] PM: Adding info for No Bus:ocfs2_control
[   12.764473] ocfs2: Registered cluster interface user
[   12.769320] initcall ocfs2_user_plugin_init+0x0/0x4b returned 0 afte=
r 14171 usecs
[   12.776805] calling  init_o2nm+0x0/0x92 @ 1
[   12.780949] OCFS2 Node Manager 1.5.0
[   12.785250] initcall init_o2nm+0x0/0x92 returned 0 after 4201 usecs
[   12.791420] calling  dlm_init+0x0/0x247 @ 1
[   12.795562] OCFS2 DLM 1.5.0
[   12.798495] initcall dlm_init+0x0/0x247 returned 0 after 2864 usecs
[   12.804668] calling  init_dlmfs_fs+0x0/0xc8 @ 1
[   12.809151] OCFS2 DLMFS 1.5.0
[   12.812738] OCFS2 User DLM kernel interface loaded
[   12.817412] initcall init_dlmfs_fs+0x0/0xc8 returned 0 after 8066 us=
ecs
[   12.824023] calling  init_btrfs_fs+0x0/0x83 @ 1
[   12.831808] device: 'btrfs-control': device_add
[   12.836301] PM: Adding info for No Bus:btrfs-control
[   12.841400] Btrfs loaded
[   12.843822] initcall init_btrfs_fs+0x0/0x83 returned 0 after 14955 u=
secs
[   12.850525] calling  init_gfs2_fs+0x0/0x1aa @ 1
[   12.857098] Slow work thread pool: Starting up
[   12.861619] Slow work thread pool: Ready
[   12.865448] GFS2 (built Jul  2 2009 09:18:14) installed
[   12.870675] initcall init_gfs2_fs+0x0/0x1aa returned 0 after 15303 u=
secs
[   12.877297] calling  ipc_init+0x0/0x20 @ 1
[   12.881416] msgmni has been set to 1700
[   12.885224] initcall ipc_init+0x0/0x20 returned 0 after 3746 usecs
[   12.891355] calling  ipc_sysctl_init+0x0/0x11 @ 1
[   12.896029] initcall ipc_sysctl_init+0x0/0x11 returned 0 after 10 us=
ecs
[   12.902627] calling  init_mqueue_fs+0x0/0xa3 @ 1
[   12.907925] initcall init_mqueue_fs+0x0/0xa3 returned 0 after 709 us=
ecs
[   12.914473] calling  key_proc_init+0x0/0x2c @ 1
[   12.918953] initcall key_proc_init+0x0/0x2c returned 0 after 17 usec=
s
[   12.925364] calling  crypto_wq_init+0x0/0x2f @ 1
[   12.930163] initcall crypto_wq_init+0x0/0x2f returned 0 after 213 us=
ecs
[   12.936655] calling  crypto_algapi_init+0x0/0xc @ 1
[   12.941566] initcall crypto_algapi_init+0x0/0xc returned 0 after 23 =
usecs
[   12.948268] calling  chainiv_module_init+0x0/0xf @ 1
[   12.953272] initcall chainiv_module_init+0x0/0xf returned 0 after 42=
 usecs
[   12.960074] calling  eseqiv_module_init+0x0/0xf @ 1
[   12.964914] initcall eseqiv_module_init+0x0/0xf returned 0 after 2 u=
secs
[   12.971601] calling  seqiv_module_init+0x0/0xf @ 1
[   12.976354] initcall seqiv_module_init+0x0/0xf returned 0 after 2 us=
ecs
[   12.982956] calling  hmac_module_init+0x0/0xf @ 1
[   12.987621] initcall hmac_module_init+0x0/0xf returned 0 after 2 use=
cs
[   12.994134] calling  crypto_xcbc_module_init+0x0/0xf @ 1
[   12.999407] initcall crypto_xcbc_module_init+0x0/0xf returned 0 afte=
r 2 usecs
[   13.006528] calling  crypto_null_mod_init+0x0/0x69 @ 1
[   13.011783] alg: No test for cipher_null (cipher_null-generic)
[   13.017701] alg: No test for ecb(cipher_null) (ecb-cipher_null)
[   13.023651] alg: No test for digest_null (digest_null-generic)
[   13.029455] alg: No test for compress_null (compress_null-generic)
[   13.035698] initcall crypto_null_mod_init+0x0/0x69 returned 0 after =
23494 usecs
[   13.042950] calling  md4_mod_init+0x0/0xf @ 1
[   13.047414] initcall md4_mod_init+0x0/0xf returned 0 after 154 usecs
[   13.053689] calling  md5_mod_init+0x0/0xf @ 1
[   13.058116] initcall md5_mod_init+0x0/0xf returned 0 after 129 usecs
[   13.064376] calling  rmd128_mod_init+0x0/0xf @ 1
[   13.069089] initcall rmd128_mod_init+0x0/0xf returned 0 after 138 us=
ecs
[   13.075614] calling  sha1_generic_mod_init+0x0/0xf @ 1
[   13.080847] initcall sha1_generic_mod_init+0x0/0xf returned 0 after =
128 usecs
[   13.087864] calling  sha256_generic_mod_init+0x0/0x33 @ 1
[   13.093542] initcall sha256_generic_mod_init+0x0/0x33 returned 0 aft=
er 273 usecs
[   13.100859] calling  sha512_generic_mod_init+0x0/0x33 @ 1
[   13.106523] initcall sha512_generic_mod_init+0x0/0x33 returned 0 aft=
er 300 usecs
[   13.113851] calling  wp512_mod_init+0x0/0x52 @ 1
[   13.118979] initcall wp512_mod_init+0x0/0x52 returned 0 after 548 us=
ecs
[   13.125502] calling  tgr192_mod_init+0x0/0x52 @ 1
[   13.130612] initcall tgr192_mod_init+0x0/0x52 returned 0 after 424 u=
secs
[   13.137195] calling  crypto_ecb_module_init+0x0/0xf @ 1
[   13.142427] initcall crypto_ecb_module_init+0x0/0xf returned 0 after=
 2 usecs
[   13.149415] calling  crypto_cbc_module_init+0x0/0xf @ 1
[   13.154639] initcall crypto_cbc_module_init+0x0/0xf returned 0 after=
 2 usecs
[   13.161655] calling  crypto_pcbc_module_init+0x0/0xf @ 1
[   13.166927] initcall crypto_pcbc_module_init+0x0/0xf returned 0 afte=
r 2 usecs
[   13.174047] calling  crypto_module_init+0x0/0xf @ 1
[   13.178888] initcall crypto_module_init+0x0/0xf returned 0 after 2 u=
secs
[   13.185576] calling  crypto_module_init+0x0/0xf @ 1
[   13.190431] initcall crypto_module_init+0x0/0xf returned 0 after 2 u=
secs
[   13.197083] calling  crypto_ctr_module_init+0x0/0x35 @ 1
[   13.202394] initcall crypto_ctr_module_init+0x0/0x35 returned 0 afte=
r 3 usecs
[   13.209476] calling  crypto_ccm_module_init+0x0/0x4f @ 1
[   13.214787] initcall crypto_ccm_module_init+0x0/0x4f returned 0 afte=
r 4 usecs
[   13.221889] calling  cryptd_init+0x0/0xb6 @ 1
[   13.226212] initcall cryptd_init+0x0/0xb6 returned 0 after 6 usecs
[   13.232375] calling  des_generic_mod_init+0x0/0x33 @ 1
[   13.237827] initcall des_generic_mod_init+0x0/0x33 returned 0 after =
345 usecs
[   13.244871] calling  fcrypt_mod_init+0x0/0xf @ 1
[   13.249526] alg: No test for fcrypt (fcrypt-generic)
[   13.254499] initcall fcrypt_mod_init+0x0/0xf returned 0 after 4936 u=
secs
[   13.261098] calling  blowfish_mod_init+0x0/0xf @ 1
[   13.266623] initcall blowfish_mod_init+0x0/0xf returned 0 after 756 =
usecs
[   13.273313] calling  aes_init+0x0/0xf @ 1
[   13.277450] initcall aes_init+0x0/0xf returned 0 after 165 usecs
[   13.283364] calling  camellia_init+0x0/0xf @ 1
[   13.287931] initcall camellia_init+0x0/0xf returned 0 after 160 usec=
s
[   13.294278] calling  cast5_mod_init+0x0/0xf @ 1
[   13.298929] initcall cast5_mod_init+0x0/0xf returned 0 after 160 use=
cs
[   13.305362] calling  cast6_mod_init+0x0/0xf @ 1
[   13.310035] initcall cast6_mod_init+0x0/0xf returned 0 after 177 use=
cs
[   13.316442] calling  arc4_init+0x0/0xf @ 1
[   13.320702] initcall arc4_init+0x0/0xf returned 0 after 159 usecs
[   13.326677] calling  anubis_mod_init+0x0/0xf @ 1
[   13.331529] initcall anubis_mod_init+0x0/0xf returned 0 after 229 us=
ecs
[   13.338022] calling  salsa20_generic_mod_init+0x0/0xf @ 1
[   13.343522] initcall salsa20_generic_mod_init+0x0/0xf returned 0 aft=
er 98 usecs
[   13.350756] calling  deflate_mod_init+0x0/0xf @ 1
[   13.355947] initcall deflate_mod_init+0x0/0xf returned 0 after 514 u=
secs
[   13.362553] calling  zlib_mod_init+0x0/0xf @ 1
[   13.367609] initcall zlib_mod_init+0x0/0xf returned 0 after 638 usec=
s
[   13.373950] calling  michael_mic_init+0x0/0xf @ 1
[   13.378777] initcall michael_mic_init+0x0/0xf returned 0 after 161 u=
secs
[   13.385384] calling  crc32c_mod_init+0x0/0xf @ 1
[   13.390206] initcall crc32c_mod_init+0x0/0xf returned 0 after 240 us=
ecs
[   13.396695] calling  crypto_authenc_module_init+0x0/0xf @ 1
[   13.402268] initcall crypto_authenc_module_init+0x0/0xf returned 0 a=
fter 3 usecs
[   13.409608] calling  lzo_mod_init+0x0/0xf @ 1
[   13.414137] initcall lzo_mod_init+0x0/0xf returned 0 after 169 usecs
[   13.420386] calling  krng_mod_init+0x0/0xf @ 1
[   13.424877] alg: No test for stdrng (krng)
[   13.428873] initcall krng_mod_init+0x0/0xf returned 0 after 3991 use=
cs
[   13.435381] calling  prng_mod_init+0x0/0x24 @ 1
[   13.439950] alg: No test for stdrng (ansi_cprng)
[   13.444525] initcall prng_mod_init+0x0/0x24 returned 0 after 4547 us=
ecs
[   13.451064] calling  proc_genhd_init+0x0/0x31 @ 1
[   13.455763] initcall proc_genhd_init+0x0/0x31 returned 0 after 33 us=
ecs
[   13.462332] calling  bsg_init+0x0/0x10d @ 1
[   13.467080] device class 'bsg': registering
[   13.471396] Block layer SCSI generic (bsg) driver version 0.4 loaded=
 (major 252)
[   13.478694] initcall bsg_init+0x0/0x10d returned 0 after 11933 usecs
[   13.485050] calling  noop_init+0x0/0x11 @ 1
[   13.489208] io scheduler noop registered
[   13.493100] initcall noop_init+0x0/0x11 returned 0 after 3821 usecs
[   13.499319] calling  as_init+0x0/0x11 @ 1
[   13.503325] io scheduler anticipatory registered
[   13.507902] initcall as_init+0x0/0x11 returned 0 after 4472 usecs
[   13.513984] calling  deadline_init+0x0/0x11 @ 1
[   13.518476] io scheduler deadline registered
[   13.522742] initcall deadline_init+0x0/0x11 returned 0 after 4162 us=
ecs
[   13.529305] calling  cfq_init+0x0/0x89 @ 1
[   13.533450] io scheduler cfq registered (default)
[   13.538063] initcall cfq_init+0x0/0x89 returned 0 after 4556 usecs
[   13.544233] calling  debug_objects_init_debugfs+0x0/0x57 @ 1
[   13.549889] initcall debug_objects_init_debugfs+0x0/0x57 returned 0 =
after 37 usecs
[   13.557407] calling  libcrc32c_mod_init+0x0/0x25 @ 1
[   13.562359] initcall libcrc32c_mod_init+0x0/0x25 returned 0 after 10=
 usecs
[   13.569173] calling  init_kmp+0x0/0xf @ 1
[   13.573204] initcall init_kmp+0x0/0xf returned 0 after 22 usecs
[   13.579054] calling  init_bm+0x0/0xf @ 1
[   13.582977] initcall init_bm+0x0/0xf returned 0 after 2 usecs
[   13.588674] calling  init_fsm+0x0/0xf @ 1
[   13.592683] initcall init_fsm+0x0/0xf returned 0 after 2 usecs
[   13.598468] calling  percpu_counter_startup+0x0/0x30 @ 1
[   13.603780] initcall percpu_counter_startup+0x0/0x30 returned 0 afte=
r 3 usecs
[   13.610879] calling  dynamic_debug_init+0x0/0xfd @ 1
[   13.617395] initcall dynamic_debug_init+0x0/0xfd returned 0 after 15=
54 usecs
[   13.624349] calling  pci_init+0x0/0x31 @ 1
[   13.628419] pci 0000:00:00.0: calling nv_msi_ht_cap_quirk_leaf+0x0/0=
x11
[   13.635084] pci 0000:00:00.0: calling quirk_cardbus_legacy+0x0/0x26
[   13.641250] pci 0000:00:00.0: calling quirk_usb_early_handoff+0x0/0x=
99
[   13.647730] pci 0000:00:00.0: calling pci_fixup_video+0x0/0x97
[   13.653565] pci 0000:00:01.0: calling nv_msi_ht_cap_quirk_leaf+0x0/0=
x11
[   13.660147] pci 0000:00:01.0: calling quirk_cardbus_legacy+0x0/0x26
[   13.666363] pci 0000:00:01.0: calling quirk_usb_early_handoff+0x0/0x=
99
[   13.672881] pci 0000:00:01.0: calling pci_fixup_video+0x0/0x97
[   13.678680] pci 0000:00:01.1: calling nv_msi_ht_cap_quirk_leaf+0x0/0=
x11
[   13.685298] pci 0000:00:01.1: calling quirk_cardbus_legacy+0x0/0x26
[   13.691514] pci 0000:00:01.1: calling quirk_usb_early_handoff+0x0/0x=
99
[   13.698550] pci 0000:00:01.1: calling pci_fixup_video+0x0/0x97
[   13.704387] pci 0000:00:02.0: calling nv_msi_ht_cap_quirk_leaf+0x0/0=
x11
[   13.710982] pci 0000:00:02.0: calling quirk_cardbus_legacy+0x0/0x26
[   13.717185] pci 0000:00:02.0: calling quirk_usb_early_handoff+0x0/0x=
99
[   13.740070] pci 0000:00:02.0: calling pci_fixup_video+0x0/0x97
[   13.745795] pci 0000:00:02.1: calling nv_msi_ht_cap_quirk_leaf+0x0/0=
x11
[   13.752422] pci 0000:00:02.1: calling quirk_cardbus_legacy+0x0/0x26
[   13.758612] pci 0000:00:02.1: calling quirk_usb_early_handoff+0x0/0x=
99
[   13.765180] pci 0000:00:02.1: calling pci_fixup_video+0x0/0x97
[   13.770947] pci 0000:00:04.0: calling nv_msi_ht_cap_quirk_leaf+0x0/0=
x11
[   13.777524] pci 0000:00:04.0: calling quirk_cardbus_legacy+0x0/0x26
[   13.783765] pci 0000:00:04.0: calling quirk_usb_early_handoff+0x0/0x=
99
[   13.790265] pci 0000:00:04.0: calling pci_fixup_video+0x0/0x97
[   13.796063] pci 0000:00:06.0: calling nv_msi_ht_cap_quirk_leaf+0x0/0=
x11
[   13.802678] pci 0000:00:06.0: calling quirk_cardbus_legacy+0x0/0x26
[   13.808879] pci 0000:00:06.0: calling quirk_usb_early_handoff+0x0/0x=
99
[   13.815398] pci 0000:00:06.0: calling pci_fixup_video+0x0/0x97
[   13.821214] pci 0000:00:09.0: calling nv_msi_ht_cap_quirk_leaf+0x0/0=
x11
[   13.827777] pci 0000:00:09.0: calling quirk_cardbus_legacy+0x0/0x26
[   13.834034] pci 0000:00:09.0: calling quirk_usb_early_handoff+0x0/0x=
99
[   13.840531] pci 0000:00:09.0: calling pci_fixup_video+0x0/0x97
[   13.846329] pci 0000:00:0a.0: calling nv_msi_ht_cap_quirk_leaf+0x0/0=
x11
[   13.852945] pci 0000:00:0a.0: calling quirk_cardbus_legacy+0x0/0x26
[   13.859147] pci 0000:00:0a.0: calling quirk_usb_early_handoff+0x0/0x=
99
[   13.865666] pci 0000:00:0a.0: calling pci_fixup_video+0x0/0x97
[   13.871483] pci 0000:00:0b.0: calling nv_msi_ht_cap_quirk_leaf+0x0/0=
x11
[   13.878328] pci 0000:00:00.0: Found enabled HT MSI Mapping
[   13.883719] pci 0000:00:0b.0: calling quirk_nvidia_ck804_msi_ht_cap+=
0x0/0x6d
[   13.890780] pci 0000:00:0b.0: Found disabled HT MSI Mapping
[   13.896305] pci 0000:00:00.0: Found enabled HT MSI Mapping
[   13.901746] pci 0000:00:0b.0: calling quirk_nvidia_ck804_pcie_aer_ex=
t_cap+0x0/0x68
[   13.909266] pci 0000:00:0b.0: calling quirk_cardbus_legacy+0x0/0x26
[   13.915528] pci 0000:00:0b.0: calling quirk_usb_early_handoff+0x0/0x=
99
[   13.922024] pci 0000:00:0b.0: calling pci_fixup_video+0x0/0x97
[   13.927823] pci 0000:00:0c.0: calling nv_msi_ht_cap_quirk_leaf+0x0/0=
x11
[   13.934756] pci 0000:00:00.0: Found enabled HT MSI Mapping
[   13.940140] pci 0000:00:0c.0: calling quirk_nvidia_ck804_msi_ht_cap+=
0x0/0x6d
[   13.947181] pci 0000:00:0c.0: Found disabled HT MSI Mapping
[   13.952746] pci 0000:00:00.0: Found enabled HT MSI Mapping
[   13.958148] pci 0000:00:0c.0: calling quirk_nvidia_ck804_pcie_aer_ex=
t_cap+0x0/0x68
[   13.965707] pci 0000:00:0c.0: calling quirk_cardbus_legacy+0x0/0x26
[   13.971945] pci 0000:00:0c.0: calling quirk_usb_early_handoff+0x0/0x=
99
[   13.978428] pci 0000:00:0c.0: calling pci_fixup_video+0x0/0x97
[   13.984263] pci 0000:00:0d.0: calling nv_msi_ht_cap_quirk_leaf+0x0/0=
x11
[   13.991231] pci 0000:00:00.0: Found enabled HT MSI Mapping
[   13.996594] pci 0000:00:0d.0: calling quirk_nvidia_ck804_msi_ht_cap+=
0x0/0x6d
[   14.003673] pci 0000:00:0d.0: Found disabled HT MSI Mapping
[   14.009198] pci 0000:00:00.0: Found enabled HT MSI Mapping
[   14.014639] pci 0000:00:0d.0: calling quirk_nvidia_ck804_pcie_aer_ex=
t_cap+0x0/0x68
[   14.022179] pci 0000:00:0d.0: calling quirk_cardbus_legacy+0x0/0x26
[   14.028401] pci 0000:00:0d.0: calling quirk_usb_early_handoff+0x0/0x=
99
[   14.034921] pci 0000:00:0d.0: calling pci_fixup_video+0x0/0x97
[   14.040742] pci 0000:00:0e.0: calling nv_msi_ht_cap_quirk_leaf+0x0/0=
x11
[   14.047741] pci 0000:00:00.0: Found enabled HT MSI Mapping
[   14.053129] pci 0000:00:0e.0: calling quirk_nvidia_ck804_msi_ht_cap+=
0x0/0x6d
[   14.060189] pci 0000:00:0e.0: Found disabled HT MSI Mapping
[   14.065715] pci 0000:00:00.0: Found enabled HT MSI Mapping
[   14.071157] pci 0000:00:0e.0: calling quirk_nvidia_ck804_pcie_aer_ex=
t_cap+0x0/0x68
[   14.078676] pci 0000:00:0e.0: calling quirk_cardbus_legacy+0x0/0x26
[   14.084936] pci 0000:00:0e.0: calling quirk_usb_early_handoff+0x0/0x=
99
[   14.091433] pci 0000:00:0e.0: calling pci_fixup_video+0x0/0x97
[   14.097235] pci 0000:00:18.0: calling quirk_cardbus_legacy+0x0/0x26
[   14.103483] pci 0000:00:18.0: calling quirk_usb_early_handoff+0x0/0x=
99
[   14.109962] pci 0000:00:18.0: calling pci_fixup_video+0x0/0x97
[   14.115800] pci 0000:00:18.1: calling quirk_cardbus_legacy+0x0/0x26
[   14.122028] pci 0000:00:18.1: calling quirk_usb_early_handoff+0x0/0x=
99
[   14.128509] pci 0000:00:18.1: calling pci_fixup_video+0x0/0x97
[   14.134346] pci 0000:00:18.2: calling quirk_cardbus_legacy+0x0/0x26
[   14.140576] pci 0000:00:18.2: calling quirk_usb_early_handoff+0x0/0x=
99
[   14.147057] pci 0000:00:18.2: calling pci_fixup_video+0x0/0x97
[   14.152894] pci 0000:00:18.3: calling quirk_cardbus_legacy+0x0/0x26
[   14.159104] pci 0000:00:18.3: calling quirk_usb_early_handoff+0x0/0x=
99
[   14.165623] pci 0000:00:18.3: calling pci_fixup_video+0x0/0x97
[   14.171438] pci 0000:05:07.0: calling quirk_cardbus_legacy+0x0/0x26
[   14.177651] pci 0000:05:07.0: calling quirk_usb_early_handoff+0x0/0x=
99
[   14.184170] pci 0000:05:07.0: calling pci_fixup_video+0x0/0x97
[   14.189967] pci 0000:01:00.0: calling quirk_cardbus_legacy+0x0/0x26
[   14.196219] pci 0000:01:00.0: calling quirk_usb_early_handoff+0x0/0x=
99
[   14.202717] pci 0000:01:00.0: calling pci_fixup_video+0x0/0x97
[   14.208514] pci 0000:01:00.0: Boot video device
[   14.213041] pci 0000:01:00.1: calling quirk_cardbus_legacy+0x0/0x26
[   14.219252] pci 0000:01:00.1: calling quirk_usb_early_handoff+0x0/0x=
99
[   14.225770] pci 0000:01:00.1: calling pci_fixup_video+0x0/0x97
[   14.231587] initcall pci_init+0x0/0x31 returned 0 after 589041 usecs
[   14.237885] calling  pci_proc_init+0x0/0x5b @ 1
[   14.242964] initcall pci_proc_init+0x0/0x5b returned 0 after 538 use=
cs
[   14.249367] calling  pci_hotplug_init+0x0/0x41 @ 1
[   14.254155] pci_hotplug: PCI Hot Plug PCI Core version: 0.5
[   14.259684] initcall pci_hotplug_init+0x0/0x41 returned 0 after 5402=
 usecs
[   14.266548] calling  ibmphp_init+0x0/0x197 @ 1
[   14.270968] ibmphpd: IBM Hot Plug PCI Controller Driver version: 0.6
[   14.277444] initcall ibmphp_init+0x0/0x197 returned -19 after 6326 u=
secs
[   14.284048] calling  zt5550_init+0x0/0x70 @ 1
[   14.288362] cpcihp_zt5550: ZT5550 CompactPCI Hot Plug Driver version=
: 0.2
[   14.295144] bus: 'pci': add driver zt5550_hc
[   14.299699] initcall zt5550_init+0x0/0x70 returned 0 after 11068 use=
cs
[   14.306134] calling  cpcihp_generic_init+0x0/0x1e6 @ 1
[   14.311242] cpcihp_generic: Generic port I/O CompactPCI Hot Plug Dri=
ver version: 0.1
[   14.318934] cpcihp_generic: not configured, disabling.
[   14.324071] initcall cpcihp_generic_init+0x0/0x1e6 returned -22 afte=
r 12526 usecs
[   14.331522] initcall cpcihp_generic_init+0x0/0x1e6 returned with err=
or code -22=20
[   14.338869] calling  init_legacy+0x0/0x36 @ 1
[   14.343943] initcall init_legacy+0x0/0x36 returned 0 after 699 usecs
[   14.350190] calling  pci_stub_init+0x0/0x16 @ 1
[   14.354680] bus: 'pci': add driver pci-stub
[   14.359116] initcall pci_stub_init+0x0/0x16 returned 0 after 4333 us=
ecs
[   14.365739] calling  genericbl_init+0x0/0xf @ 1
[   14.370169] bus: 'platform': add driver generic-bl
[   14.375172] initcall genericbl_init+0x0/0xf returned 0 after 4888 us=
ecs
[   14.381687] calling  progearbl_init+0x0/0x49 @ 1
[   14.386262] bus: 'platform': add driver progear-bl
[   14.391333] Registering platform device 'progear-bl'. Parent at plat=
form
[   14.397914] device: 'progear-bl': device_add
[   14.402210] bus: 'platform': add device progear-bl
[   14.406984] PM: Adding info for platform:progear-bl
[   14.412007] bus: 'platform': driver_probe_device: matched device pro=
gear-bl with driver progear-bl
[   14.420891] bus: 'platform': really_probe: probing driver progear-bl=
 with device progear-bl
[   14.429231] ALI M7101 PMU not found.
[   14.432808] initcall progearbl_init+0x0/0x49 returned 0 after 45450 =
usecs
[   14.439500] calling  da903x_backlight_init+0x0/0xf @ 1
[   14.444633] Platform driver 'da903x-backlight' needs updating - plea=
se use dev_pm_ops
[   14.452430] bus: 'platform': add driver da903x-backlight
[   14.457960] initcall da903x_backlight_init+0x0/0xf returned 0 after =
13016 usecs
[   14.465200] calling  cyber2000fb_init+0x0/0xb2 @ 1
[   14.469941] bus: 'pci': add driver CyberPro
[   14.474404] initcall cyber2000fb_init+0x0/0xb2 returned 0 after 4353=
 usecs
[   14.481172] calling  pm2fb_init+0x0/0x42 @ 1
[   14.485403] bus: 'pci': add driver pm2fb
[   14.489579] initcall pm2fb_init+0x0/0x42 returned 0 after 4081 usecs
[   14.495853] calling  pm3fb_init+0x0/0xed @ 1
[   14.500084] bus: 'pci': add driver pm3fb
[   14.504243] initcall pm3fb_init+0x0/0xed returned 0 after 4064 usecs
[   14.510501] calling  matroxfb_init+0x0/0x63 @ 1
[   14.514991] bus: 'pci': add driver matroxfb
[   14.519428] initcall matroxfb_init+0x0/0x63 returned 0 after 4336 us=
ecs
[   14.525958] calling  matroxfb_crtc2_init+0x0/0x2d @ 1
[   14.530975] initcall matroxfb_crtc2_init+0x0/0x2d returned 0 after 2=
 usecs
[   14.537798] calling  i2c_matroxfb_init+0x0/0x27 @ 1
[   14.542674] initcall i2c_matroxfb_init+0x0/0x27 returned 0 after 1 u=
secs
[   14.549325] calling  matroxfb_maven_init+0x0/0x11 @ 1
[   14.554373] bus: 'i2c': add driver maven
[   14.558502] i2c-core: driver [maven] registered
[   14.562948] initcall matroxfb_maven_init+0x0/0x11 returned 0 after 8=
375 usecs
[   14.570040] calling  nvidiafb_init+0x0/0x47 @ 1
[   14.574531] nvidiafb_setup START
[   14.577734] bus: 'pci': add driver nvidiafb
[   14.582200] initcall nvidiafb_init+0x0/0x47 returned 0 after 7484 us=
ecs
[   14.588689] calling  atyfb_init+0x0/0x62 @ 1
[   14.592966] bus: 'pci': add driver atyfb
[   14.597126] initcall atyfb_init+0x0/0x62 returned 0 after 4065 usecs
[   14.603390] calling  sisfb_init+0x0/0x42 @ 1
[   14.607613] bus: 'pci': add driver sisfb
[   14.611807] initcall sisfb_init+0x0/0x42 returned 0 after 4092 usecs
[   14.618035] calling  viafb_init+0x0/0x47 @ 1
[   14.622310] VIA Graphics Intergration Chipset framebuffer 2.4 initia=
lizing
[   14.629266] device: 'i2c-0': device_add
[   14.633085] PM: Adding info for No Bus:i2c-0
[   14.637473] i2c-adapter i2c-0: adapter [via_i2c] registered
[   14.643161] i2c-adapter i2c-0: master_xfer[0] W, addr=3D0x08, len=3D=
1
[   14.649132] i2c-adapter i2c-0: master_xfer[1] R, addr=3D0x08, len=3D=
1
[   16.330060] i2c-adapter i2c-0: master_xfer[0] W, addr=3D0x08, len=3D=
1
[   16.336033] i2c-adapter i2c-0: master_xfer[1] R, addr=3D0x08, len=3D=
1
[   18.020071] i2c-adapter i2c-0: master_xfer[0] W, addr=3D0x08, len=3D=
1
[   18.026046] i2c-adapter i2c-0: master_xfer[1] R, addr=3D0x08, len=3D=
1
[   19.710060] i2c-adapter i2c-0: master_xfer[0] W, addr=3D0x50, len=3D=
1
[   19.716033] i2c-adapter i2c-0: master_xfer[1] R, addr=3D0x50, len=3D=
1
[   21.400047] i2c-adapter i2c-0: master_xfer[0] W, addr=3D0x50, len=3D=
1
[   21.406044] i2c-adapter i2c-0: master_xfer[1] R, addr=3D0x50, len=3D=
1
[   23.090044] i2c-adapter i2c-0: master_xfer[0] W, addr=3D0x50, len=3D=
1
[   23.096673] i2c-adapter i2c-0: master_xfer[1] R, addr=3D0x50, len=3D=
1
[   24.780049] i2c-adapter i2c-0: master_xfer[0] W, addr=3D0x50, len=3D=
1
[   24.786043] i2c-adapter i2c-0: master_xfer[1] R, addr=3D0x50, len=3D=
1
[   26.470059] i2c-adapter i2c-0: master_xfer[0] W, addr=3D0x50, len=3D=
1
[   26.476032] i2c-adapter i2c-0: master_xfer[1] R, addr=3D0x50, len=3D=
1
[   28.160044] i2c-adapter i2c-0: master_xfer[0] W, addr=3D0x50, len=3D=
1
[   28.166035] i2c-adapter i2c-0: master_xfer[1] R, addr=3D0x50, len=3D=
1
[   29.850045] i2c-adapter i2c-0: master_xfer[0] W, addr=3D0x40, len=3D=
1
[   29.856038] i2c-adapter i2c-0: master_xfer[1] R, addr=3D0x40, len=3D=
1
[   31.540045] i2c-adapter i2c-0: master_xfer[0] W, addr=3D0x40, len=3D=
1
[   31.546033] i2c-adapter i2c-0: master_xfer[1] R, addr=3D0x40, len=3D=
1
[   33.230060] i2c-adapter i2c-0: master_xfer[0] W, addr=3D0x40, len=3D=
1
[   33.236031] i2c-adapter i2c-0: master_xfer[1] R, addr=3D0x40, len=3D=
1
[   34.920044] i2c-adapter i2c-0: master_xfer[0] W, addr=3D0x40, len=3D=
1
[   34.926034] i2c-adapter i2c-0: master_xfer[1] R, addr=3D0x40, len=3D=
1
[   36.610044] i2c-adapter i2c-0: master_xfer[0] W, addr=3D0x38, len=3D=
1
[   36.616038] i2c-adapter i2c-0: master_xfer[1] R, addr=3D0x38, len=3D=
1
[   38.300046] ioremap failed
[   38.302659] initcall viafb_init+0x0/0x47 returned -1 after 23125338 =
usecs
[   38.309398] initcall viafb_init+0x0/0x47 returned with error code -1=
=20
[   38.315827] calling  kyrofb_init+0x0/0xcb @ 1
[   38.320150] bus: 'pci': add driver kyrofb
[   38.324513] initcall kyrofb_init+0x0/0xcb returned 0 after 4259 usec=
s
[   38.330830] calling  savagefb_init+0x0/0x62 @ 1
[   38.335358] bus: 'pci': add driver savagefb
[   38.339791] initcall savagefb_init+0x0/0x62 returned 0 after 4332 us=
ecs
[   38.346305] calling  gx1fb_init+0x0/0x42 @ 1
[   38.350535] bus: 'pci': add driver gx1fb
[   38.354736] initcall gx1fb_init+0x0/0x42 returned 0 after 4100 usecs
[   38.360964] calling  lxfb_init+0x0/0xcb @ 1
[   38.365150] bus: 'pci': add driver lxfb
[   38.369233] initcall lxfb_init+0x0/0xcb returned 0 after 3990 usecs
[   38.375400] calling  neofb_init+0x0/0x42 @ 1
[   38.379628] bus: 'pci': add driver neofb
[   38.383832] initcall neofb_init+0x0/0x42 returned 0 after 4101 usecs
[   38.390059] calling  tdfxfb_init+0x0/0x42 @ 1
[   38.394418] bus: 'pci': add driver tdfxfb
[   38.398665] initcall tdfxfb_init+0x0/0x42 returned 0 after 4150 usec=
s
[   38.405006] calling  imsttfb_init+0x0/0x42 @ 1
[   38.409407] bus: 'pci': add driver imsttfb
[   38.413777] initcall imsttfb_init+0x0/0x42 returned 0 after 4264 use=
cs
[   38.420185] calling  vt8623fb_init+0x0/0x74 @ 1
[   38.424718] bus: 'pci': add driver vt8623fb
[   38.429142] initcall vt8623fb_init+0x0/0x74 returned 0 after 4324 us=
ecs
[   38.435660] calling  tridentfb_init+0x0/0x42 @ 1
[   38.440235] bus: 'pci': add driver tridentfb
[   38.444775] initcall tridentfb_init+0x0/0x42 returned 0 after 4430 u=
secs
[   38.451351] calling  s3fb_init+0x0/0xf0 @ 1
[   38.455535] bus: 'pci': add driver s3fb
[   38.459617] initcall s3fb_init+0x0/0xf0 returned 0 after 3988 usecs
[   38.465786] calling  arkfb_init+0x0/0x73 @ 1
[   38.470015] bus: 'pci': add driver arkfb
[   38.474214] initcall arkfb_init+0x0/0x73 returned 0 after 4097 usecs
[   38.480444] calling  hecubafb_init+0x0/0xf @ 1
[   38.484890] bus: 'platform': add driver hecubafb
[   38.489724] initcall hecubafb_init+0x0/0xf returned 0 after 4724 use=
cs
[   38.496156] calling  n411_init+0x0/0x7c @ 1
[   38.500294] no IO addresses supplied
[   38.503863] initcall n411_init+0x0/0x7c returned -22 after 3480 usec=
s
[   38.510259] initcall n411_init+0x0/0x7c returned with error code -22=
=20
[   38.516690] calling  sstfb_init+0x0/0x47 @ 1
[   38.520923] bus: 'pci': add driver sstfb
[   38.525120] initcall sstfb_init+0x0/0x47 returned 0 after 4096 usecs
[   38.531353] calling  metronomefb_init+0x0/0xf @ 1
[   38.536059] bus: 'platform': add driver metronomefb
[   38.541148] initcall metronomefb_init+0x0/0xf returned 0 after 4972 =
usecs
[   38.547838] calling  broadsheetfb_init+0x0/0xf @ 1
[   38.552610] bus: 'platform': add driver broadsheetfb
[   38.557790] initcall broadsheetfb_init+0x0/0xf returned 0 after 5062=
 usecs
[   38.564570] calling  xenfb_init+0x0/0x3c @ 1
[   38.568798] initcall xenfb_init+0x0/0x3c returned -19 after 1 usecs
[   38.575050] calling  carminefb_init+0x0/0x31 @ 1
[   38.579631] bus: 'pci': add driver carminefb
[   38.584179] initcall carminefb_init+0x0/0x31 returned 0 after 4437 u=
secs
[   38.590756] calling  uvesafb_init+0x0/0xc9 @ 1
[   38.595207] bus: 'platform': add driver uvesafb
[   38.599934] Registering platform device 'uvesafb.0'. Parent at platf=
orm
[   38.606460] device: 'uvesafb.0': device_add
[   38.610617] bus: 'platform': add device uvesafb.0
[   38.615353] PM: Adding info for platform:uvesafb.0
[   38.620275] bus: 'platform': driver_probe_device: matched device uve=
safb.0 with driver uvesafb
[   38.628816] bus: 'platform': really_probe: probing driver uvesafb wi=
th device uvesafb.0
[   38.637151] uvesafb: failed to execute /sbin/v86d
[   38.641734] uvesafb: make sure that the v86d helper is installed and=
 executable
[   38.649040] uvesafb: Getting VBE info block failed (eax=3D0x4f00, er=
r=3D-2)
[   38.655622] uvesafb: vbe_init() failed with -22
[   38.660132] uvesafb: probe of uvesafb.0 failed with error -22
[   38.665857] initcall uvesafb_init+0x0/0xc9 returned 0 after 69000 us=
ecs
[   38.672415] calling  acpi_reserve_resources+0x0/0xc8 @ 1
[   38.677747] initcall acpi_reserve_resources+0x0/0xc8 returned 0 afte=
r 28 usecs
[   38.684911] calling  irqrouter_init_sysfs+0x0/0x33 @ 1
[   38.690009] Registering sysdev class 'irqrouter'
[   38.694843] Registering sys device of class 'irqrouter'
[   38.699966] Registering sys device 'irqrouter0'
[   38.704684] initcall irqrouter_init_sysfs+0x0/0x33 returned 0 after =
14325 usecs
[   38.711890] calling  acpi_ac_init+0x0/0x3d @ 1
[   38.716418] bus: 'acpi': add driver ac
[   38.720344] initcall acpi_ac_init+0x0/0x3d returned 0 after 3910 use=
cs
[   38.726773] calling  acpi_button_init+0x0/0x4a @ 1
[   38.731539] bus: 'acpi': add driver button
[   38.735642] bus: 'acpi': driver_probe_device: matched device LNXPWRB=
N:00 with driver button
[   38.743931] bus: 'acpi': really_probe: probing driver button with de=
vice LNXPWRBN:00
[   38.751722] device: 'input0': device_add
[   38.755798] PM: Adding info for No Bus:input0
[   38.760328] input: Power Button as /class/input/input0
[   38.765376] ACPI: Power Button [PWRF]
[   38.769003] driver: 'LNXPWRBN:00': driver_bound: bound to device 'bu=
tton'
[   38.775764] bus: 'acpi': really_probe: bound device LNXPWRBN:00 to d=
river button
[   38.783135] bus: 'acpi': driver_probe_device: matched device PNP0C0C=
:00 with driver button
[   38.791346] bus: 'acpi': really_probe: probing driver button with de=
vice PNP0C0C:00
[   38.799070] device: 'input1': device_add
[   38.803142] PM: Adding info for No Bus:input1
[   38.807645] input: Power Button as /class/input/input1
[   38.812703] ACPI: Power Button [PWRB]
[   38.816325] driver: 'PNP0C0C:00': driver_bound: bound to device 'but=
ton'
[   38.822999] bus: 'acpi': really_probe: bound device PNP0C0C:00 to dr=
iver button
[   38.830549] initcall acpi_button_init+0x0/0x4a returned 0 after 9670=
5 usecs
[   38.837422] calling  acpi_fan_init+0x0/0x4a @ 1
[   38.841921] bus: 'acpi': add driver fan
[   38.845793] bus: 'acpi': driver_probe_device: matched device PNP0C0B=
:00 with driver fan
[   38.853713] bus: 'acpi': really_probe: probing driver fan with devic=
e PNP0C0B:00
[   38.861233] device: 'cooling_device0': device_add
[   38.865896] PM: Adding info for No Bus:cooling_device0
[   38.871238] fan PNP0C0B:00: registered as cooling_device0
[   38.876599] ACPI: Fan [FAN] (on)
[   38.879725] driver: 'PNP0C0B:00': driver_bound: bound to device 'fan=
'
[   38.886153] bus: 'acpi': really_probe: bound device PNP0C0B:00 to dr=
iver fan
[   38.893399] initcall acpi_fan_init+0x0/0x4a returned 0 after 50283 u=
secs
[   38.899978] calling  acpi_video_init+0x0/0x14 @ 1
[   38.904700] bus: 'acpi': add driver video
[   38.908934] initcall acpi_video_init+0x0/0x14 returned 0 after 4153 =
usecs
[   38.915628] calling  acpi_processor_init+0x0/0xd5 @ 1
[   38.920684] bus: 'acpi': add driver processor
[   38.925006] bus: 'acpi': driver_probe_device: matched device LNXCPU:=
00 with driver processor
[   38.933386] bus: 'acpi': really_probe: probing driver processor with=
 device LNXCPU:00
[   38.941446] device: 'cooling_device1': device_add
[   38.946113] PM: Adding info for No Bus:cooling_device1
[   38.951385] processor LNXCPU:00: registered as cooling_device1
[   38.957158] driver: 'LNXCPU:00': driver_bound: bound to device 'proc=
essor'
[   38.963963] bus: 'acpi': really_probe: bound device LNXCPU:00 to dri=
ver processor
[   38.971403] bus: 'acpi': driver_probe_device: matched device LNXCPU:=
01 with driver processor
[   38.979822] bus: 'acpi': really_probe: probing driver processor with=
 device LNXCPU:01
[   38.987879] device: 'cooling_device2': device_add
[   38.992536] PM: Adding info for No Bus:cooling_device2
[   38.997812] processor LNXCPU:01: registered as cooling_device2
[   39.003600] driver: 'LNXCPU:01': driver_bound: bound to device 'proc=
essor'
[   39.010374] bus: 'acpi': really_probe: bound device LNXCPU:01 to dri=
ver processor
[   39.018160] initcall acpi_processor_init+0x0/0xd5 returned 0 after 9=
5236 usecs
[   39.025321] calling  acpi_container_init+0x0/0x3d @ 1
[   39.030312] bus: 'acpi': add driver container
[   39.068198] initcall acpi_container_init+0x0/0x3d returned 0 after 3=
6990 usecs
[   39.075351] calling  acpi_thermal_init+0x0/0x6f @ 1
[   39.080215] bus: 'acpi': add driver thermal
[   39.084443] bus: 'acpi': driver_probe_device: matched device LNXTHER=
M:00 with driver thermal
[   39.092795] bus: 'acpi': really_probe: probing driver thermal with d=
evice LNXTHERM:00
[   39.100659] bus: 'acpi': driver_probe_device: matched device LNXTHER=
M:01 with driver thermal
[   39.109651] bus: 'acpi': really_probe: probing driver thermal with d=
evice LNXTHERM:01
[   39.121086] device: 'thermal_zone0': device_add
[   39.125575] PM: Adding info for No Bus:thermal_zone0
[   39.130901] device: 'hwmon0': device_add
[   39.134890] PM: Adding info for No Bus:hwmon0
[   39.142048] thermal LNXTHERM:01: registered as thermal_zone0
[   39.147812] ACPI: Thermal Zone [THRM] (40 C)
[   39.151979] driver: 'LNXTHERM:01': driver_bound: bound to device 'th=
ermal'
[   39.158923] bus: 'acpi': really_probe: bound device LNXTHERM:01 to d=
river thermal
[   39.169341] initcall acpi_thermal_init+0x0/0x6f returned 0 after 870=
56 usecs
[   39.176394] calling  acpi_battery_init+0x0/0x13 @ 1
[   39.181218] bus: 'acpi': add driver battery
[   39.185707] initcall acpi_battery_init+0x0/0x13 returned 0 after 443=
8 usecs
[   39.192560] calling  acpi_smb_hc_init+0x0/0x15 @ 1
[   39.197313] bus: 'acpi': add driver smbus_hc
[   39.201835] initcall acpi_smb_hc_init+0x0/0x15 returned 0 after 4419=
 usecs
[   39.208610] calling  acpi_sbs_init+0x0/0x46 @ 1
[   39.213129] bus: 'acpi': add driver sbs
[   39.217196] initcall acpi_sbs_init+0x0/0x46 returned 0 after 3975 us=
ecs
[   39.223713] calling  pnpbios_thread_init+0x0/0x46 @ 1
[   39.228721] initcall pnpbios_thread_init+0x0/0x46 returned 0 after 1=
 usecs
[   39.235581] calling  isapnp_init+0x0/0x2bb @ 1
[   39.240006] device: 'pnp1': device_add
[   39.243772] PM: Adding info for No Bus:pnp1
[   39.247872] isapnp: Scanning for PnP cards...
[   39.607590] isapnp: No Plug & Play device found
[   39.612005] initcall isapnp_init+0x0/0x2bb returned 0 after 363302 u=
secs
[   39.618695] calling  evtchn_init+0x0/0x5d @ 1
[   39.623032] initcall evtchn_init+0x0/0x5d returned -19 after 1 usecs
[   39.629340] calling  xenfs_init+0x0/0x27 @ 1
[   39.633602] XENFS: not registering filesystem on non-xen platform
[   39.639654] initcall xenfs_init+0x0/0x27 returned 0 after 5913 usecs
[   39.645996] calling  hypervisor_subsys_init+0x0/0x21 @ 1
[   39.651271] initcall hypervisor_subsys_init+0x0/0x21 returned -19 af=
ter 1 usecs
[   39.658561] calling  hyper_sysfs_init+0x0/0xc4 @ 1
[   39.663332] initcall hyper_sysfs_init+0x0/0xc4 returned -19 after 1 =
usecs
[   39.670073] calling  regulator_userspace_consumer_init+0x0/0xf @ 1
[   39.676246] bus: 'platform': add driver reg-userspace-consumer
[   39.682284] initcall regulator_userspace_consumer_init+0x0/0xf retur=
ned 0 after 5901 usecs
[   39.690471] calling  bq24022_init+0x0/0x14 @ 1
[   39.694885] bus: 'platform': add driver bq24022
[   39.699687] bus: 'platform': remove driver bq24022
[   39.704613] driver: 'bq24022': driver_release
[   39.708859] initcall bq24022_init+0x0/0x14 returned -19 after 13649 =
usecs
[   39.715634] calling  rand_initialize+0x0/0x2a @ 1
[   39.720352] initcall rand_initialize+0x0/0x2a returned 0 after 58 us=
ecs
[   39.726891] calling  tty_init+0x0/0xd5 @ 1
[   39.730977] device: 'tty': device_add
[   39.734676] PM: Adding info for No Bus:tty
[   39.738933] device: 'console': device_add
[   39.742918] PM: Adding info for No Bus:console
[   39.747477] device: 'tty0': device_add
[   39.751178] PM: Adding info for No Bus:tty0
[   39.755522] device class 'vc': registering
[   39.759735] device: 'vcs': device_add
[   39.763379] PM: Adding info for No Bus:vcs
[   39.767628] device: 'vcsa': device_add
[   39.771330] PM: Adding info for No Bus:vcsa
[   39.775714] device: 'tty1': device_add
[   39.779417] PM: Adding info for No Bus:tty1
[   39.783757] device: 'tty2': device_add
[   39.787463] PM: Adding info for No Bus:tty2
[   39.791777] device: 'tty3': device_add
[   39.795513] PM: Adding info for No Bus:tty3
[   39.799795] device: 'tty4': device_add
[   39.803530] PM: Adding info for No Bus:tty4
[   39.807821] device: 'tty5': device_add
[   39.811531] PM: Adding info for No Bus:tty5
[   39.815868] device: 'tty6': device_add
[   39.819576] PM: Adding info for No Bus:tty6
[   39.823902] device: 'tty7': device_add
[   39.827608] PM: Adding info for No Bus:tty7
[   39.831918] device: 'tty8': device_add
[   39.835656] PM: Adding info for No Bus:tty8
[   39.839945] device: 'tty9': device_add
[   39.843682] PM: Adding info for No Bus:tty9
[   39.847973] device: 'tty10': device_add
[   39.851768] PM: Adding info for No Bus:tty10
[   39.856194] device: 'tty11': device_add
[   39.859987] PM: Adding info for No Bus:tty11
[   39.864407] device: 'tty12': device_add
[   39.868211] PM: Adding info for No Bus:tty12
[   39.872609] device: 'tty13': device_add
[   39.876400] PM: Adding info for No Bus:tty13
[   39.880831] device: 'tty14': device_add
[   39.884658] PM: Adding info for No Bus:tty14
[   39.889035] device: 'tty15': device_add
[   39.892899] PM: Adding info for No Bus:tty15
[   39.897279] device: 'tty16': device_add
[   39.901076] PM: Adding info for No Bus:tty16
[   39.905494] device: 'tty17': device_add
[   39.909284] PM: Adding info for No Bus:tty17
[   39.913726] device: 'tty18': device_add
[   39.917517] PM: Adding info for No Bus:tty18
[   39.921918] device: 'tty19': device_add
[   39.925742] PM: Adding info for No Bus:tty19
[   39.930211] device: 'tty20': device_add
[   39.934022] PM: Adding info for No Bus:tty20
[   39.938419] device: 'tty21': device_add
[   39.942211] PM: Adding info for No Bus:tty21
[   39.946653] device: 'tty22': device_add
[   39.950440] PM: Adding info for No Bus:tty22
[   39.954864] device: 'tty23': device_add
[   39.958656] PM: Adding info for No Bus:tty23
[   39.963130] device: 'tty24': device_add
[   39.966924] PM: Adding info for No Bus:tty24
[   39.971325] device: 'tty25': device_add
[   39.975148] PM: Adding info for No Bus:tty25
[   39.979531] device: 'tty26': device_add
[   39.983377] PM: Adding info for No Bus:tty26
[   39.987779] device: 'tty27': device_add
[   39.991569] PM: Adding info for No Bus:tty27
[   39.995991] device: 'tty28': device_add
[   39.999784] PM: Adding info for No Bus:tty28
[   40.004212] device: 'tty29': device_add
[   40.008009] PM: Adding info for No Bus:tty29
[   40.012407] device: 'tty30': device_add
[   40.016231] PM: Adding info for No Bus:tty30
[   40.020613] device: 'tty31': device_add
[   40.024432] PM: Adding info for No Bus:tty31
[   40.028807] device: 'tty32': device_add
[   40.032628] PM: Adding info for No Bus:tty32
[   40.037011] device: 'tty33': device_add
[   40.040810] PM: Adding info for No Bus:tty33
[   40.045233] device: 'tty34': device_add
[   40.049023] PM: Adding info for No Bus:tty34
[   40.053450] device: 'tty35': device_add
[   40.057243] PM: Adding info for No Bus:tty35
[   40.061642] device: 'tty36': device_add
[   40.065463] PM: Adding info for No Bus:tty36
[   40.069844] device: 'tty37': device_add
[   40.073664] PM: Adding info for No Bus:tty37
[   40.078035] device: 'tty38': device_add
[   40.081831] PM: Adding info for No Bus:tty38
[   40.086254] device: 'tty39': device_add
[   40.090049] PM: Adding info for No Bus:tty39
[   40.094465] device: 'tty40': device_add
[   40.098256] PM: Adding info for No Bus:tty40
[   40.102661] device: 'tty41': device_add
[   40.106455] PM: Adding info for No Bus:tty41
[   40.110849] device: 'tty42': device_add
[   40.114673] PM: Adding info for No Bus:tty42
[   40.119054] device: 'tty43': device_add
[   40.122875] PM: Adding info for No Bus:tty43
[   40.127256] device: 'tty44': device_add
[   40.131048] PM: Adding info for No Bus:tty44
[   40.135557] device: 'tty45': device_add
[   40.139349] PM: Adding info for No Bus:tty45
[   40.143777] device: 'tty46': device_add
[   40.147574] PM: Adding info for No Bus:tty46
[   40.151961] device: 'tty47': device_add
[   40.155821] PM: Adding info for No Bus:tty47
[   40.160225] device: 'tty48': device_add
[   40.164042] PM: Adding info for No Bus:tty48
[   40.168425] device: 'tty49': device_add
[   40.172220] PM: Adding info for No Bus:tty49
[   40.176652] device: 'tty50': device_add
[   40.180442] PM: Adding info for No Bus:tty50
[   40.184880] device: 'tty51': device_add
[   40.188673] PM: Adding info for No Bus:tty51
[   40.193101] device: 'tty52': device_add
[   40.196892] PM: Adding info for No Bus:tty52
[   40.201289] device: 'tty53': device_add
[   40.205113] PM: Adding info for No Bus:tty53
[   40.209498] device: 'tty54': device_add
[   40.213322] PM: Adding info for No Bus:tty54
[   40.217704] device: 'tty55': device_add
[   40.221506] PM: Adding info for No Bus:tty55
[   40.225930] device: 'tty56': device_add
[   40.229722] PM: Adding info for No Bus:tty56
[   40.234149] device: 'tty57': device_add
[   40.237949] PM: Adding info for No Bus:tty57
[   40.242342] device: 'tty58': device_add
[   40.246165] PM: Adding info for No Bus:tty58
[   40.250544] device: 'tty59': device_add
[   40.254364] PM: Adding info for No Bus:tty59
[   40.259387] device: 'tty60': device_add
[   40.263310] PM: Adding info for No Bus:tty60
[   40.267693] device: 'tty61': device_add
[   40.271507] PM: Adding info for No Bus:tty61
[   40.275915] device: 'tty62': device_add
[   40.279724] PM: Adding info for No Bus:tty62
[   40.284159] device: 'tty63': device_add
[   40.287954] PM: Adding info for No Bus:tty63
[   40.292659] initcall tty_init+0x0/0xd5 returned 0 after 548536 usecs
[   40.298891] calling  pty_init+0x0/0x11 @ 1
[   40.303024] device: 'ptyp0': device_add
[   40.306858] PM: Adding info for No Bus:ptyp0
[   40.311257] device: 'ptyp1': device_add
[   40.315075] PM: Adding info for No Bus:ptyp1
[   40.319454] device: 'ptyp2': device_add
[   40.323276] PM: Adding info for No Bus:ptyp2
[   40.327659] device: 'ptyp3': device_add
[   40.331461] PM: Adding info for No Bus:ptyp3
[   40.335881] device: 'ptyp4': device_add
[   40.339676] PM: Adding info for No Bus:ptyp4
[   40.344102] device: 'ptyp5': device_add
[   40.347889] PM: Adding info for No Bus:ptyp5
[   40.352296] device: 'ptyp6': device_add
[   40.356125] PM: Adding info for No Bus:ptyp6
[   40.360509] device: 'ptyp7': device_add
[   40.364324] PM: Adding info for No Bus:ptyp7
[   40.368704] device: 'ptyp8': device_add
[   40.372492] PM: Adding info for No Bus:ptyp8
[   40.376921] device: 'ptyp9': device_add
[   40.380713] PM: Adding info for No Bus:ptyp9
[   40.385130] device: 'ptypa': device_add
[   40.388918] PM: Adding info for No Bus:ptypa
[   40.393347] device: 'ptypb': device_add
[   40.397136] PM: Adding info for No Bus:ptypb
[   40.401541] device: 'ptypc': device_add
[   40.405364] PM: Adding info for No Bus:ptypc
[   40.409747] device: 'ptypd': device_add
[   40.413568] PM: Adding info for No Bus:ptypd
[   40.417948] device: 'ptype': device_add
[   40.421739] PM: Adding info for No Bus:ptype
[   40.426160] device: 'ptypf': device_add
[   40.429953] PM: Adding info for No Bus:ptypf
[   40.434373] device: 'ptyq0': device_add
[   40.438165] PM: Adding info for No Bus:ptyq0
[   40.442566] device: 'ptyq1': device_add
[   40.446354] PM: Adding info for No Bus:ptyq1
[   40.450768] device: 'ptyq2': device_add
[   40.454597] PM: Adding info for No Bus:ptyq2
[   40.458980] device: 'ptyq3': device_add
[   40.462845] PM: Adding info for No Bus:ptyq3
[   40.467226] device: 'ptyq4': device_add
[   40.471023] PM: Adding info for No Bus:ptyq4
[   40.475442] device: 'ptyq5': device_add
[   40.479239] PM: Adding info for No Bus:ptyq5
[   40.483679] device: 'ptyq6': device_add
[   40.487474] PM: Adding info for No Bus:ptyq6
[   40.491878] device: 'ptyq7': device_add
[   40.495696] PM: Adding info for No Bus:ptyq7
[   40.500153] device: 'ptyq8': device_add
[   40.503962] PM: Adding info for No Bus:ptyq8
[   40.508345] device: 'ptyq9': device_add
[   40.512140] PM: Adding info for No Bus:ptyq9
[   40.516579] device: 'ptyqa': device_add
[   40.520371] PM: Adding info for No Bus:ptyqa
[   40.524791] device: 'ptyqb': device_add
[   40.528587] PM: Adding info for No Bus:ptyqb
[   40.533016] device: 'ptyqc': device_add
[   40.536814] PM: Adding info for No Bus:ptyqc
[   40.541206] device: 'ptyqd': device_add
[   40.545034] PM: Adding info for No Bus:ptyqd
[   40.549423] device: 'ptyqe': device_add
[   40.553242] PM: Adding info for No Bus:ptyqe
[   40.557618] device: 'ptyqf': device_add
[   40.561414] PM: Adding info for No Bus:ptyqf
[   40.565838] device: 'ptyr0': device_add
[   40.569636] PM: Adding info for No Bus:ptyr0
[   40.574055] device: 'ptyr1': device_add
[   40.577852] PM: Adding info for No Bus:ptyr1
[   40.582242] device: 'ptyr2': device_add
[   40.586060] PM: Adding info for No Bus:ptyr2
[   40.590435] device: 'ptyr3': device_add
[   40.594248] PM: Adding info for No Bus:ptyr3
[   40.598624] device: 'ptyr4': device_add
[   40.602416] PM: Adding info for No Bus:ptyr4
[   40.606843] device: 'ptyr5': device_add
[   40.610640] PM: Adding info for No Bus:ptyr5
[   40.615053] device: 'ptyr6': device_add
[   40.618850] PM: Adding info for No Bus:ptyr6
[   40.623274] device: 'ptyr7': device_add
[   40.627069] PM: Adding info for No Bus:ptyr7
[   40.631462] device: 'ptyr8': device_add
[   40.635290] PM: Adding info for No Bus:ptyr8
[   40.639674] device: 'ptyr9': device_add
[   40.643500] PM: Adding info for No Bus:ptyr9
[   40.647888] device: 'ptyra': device_add
[   40.651686] PM: Adding info for No Bus:ptyra
[   40.656107] device: 'ptyrb': device_add
[   40.659908] PM: Adding info for No Bus:ptyrb
[   40.664322] device: 'ptyrc': device_add
[   40.668116] PM: Adding info for No Bus:ptyrc
[   40.672531] device: 'ptyrd': device_add
[   40.676332] PM: Adding info for No Bus:ptyrd
[   40.680728] device: 'ptyre': device_add
[   40.684544] PM: Adding info for No Bus:ptyre
[   40.688922] device: 'ptyrf': device_add
[   40.692748] PM: Adding info for No Bus:ptyrf
[   40.697122] device: 'ptys0': device_add
[   40.700919] PM: Adding info for No Bus:ptys0
[   40.705339] device: 'ptys1': device_add
[   40.709135] PM: Adding info for No Bus:ptys1
[   40.713554] device: 'ptys2': device_add
[   40.717352] PM: Adding info for No Bus:ptys2
[   40.721743] device: 'ptys3': device_add
[   40.725572] PM: Adding info for No Bus:ptys3
[   40.729956] device: 'ptys4': device_add
[   40.733785] PM: Adding info for No Bus:ptys4
[   40.738159] device: 'ptys5': device_add
[   40.741951] PM: Adding info for No Bus:ptys5
[   40.746374] device: 'ptys6': device_add
[   40.750177] PM: Adding info for No Bus:ptys6
[   40.754591] device: 'ptys7': device_add
[   40.758388] PM: Adding info for No Bus:ptys7
[   40.762806] device: 'ptys8': device_add
[   40.766606] PM: Adding info for No Bus:ptys8
[   40.770998] device: 'ptys9': device_add
[   40.774826] PM: Adding info for No Bus:ptys9
[   40.779206] device: 'ptysa': device_add
[   40.783026] PM: Adding info for No Bus:ptysa
[   40.787410] device: 'ptysb': device_add
[   40.791208] PM: Adding info for No Bus:ptysb
[   40.795634] device: 'ptysc': device_add
[   40.799435] PM: Adding info for No Bus:ptysc
[   40.803853] device: 'ptysd': device_add
[   40.807652] PM: Adding info for No Bus:ptysd
[   40.812046] device: 'ptyse': device_add
[   40.815869] PM: Adding info for No Bus:ptyse
[   40.820251] device: 'ptysf': device_add
[   40.824066] PM: Adding info for No Bus:ptysf
[   40.828440] device: 'ptyt0': device_add
[   40.832239] PM: Adding info for No Bus:ptyt0
[   40.836659] device: 'ptyt1': device_add
[   40.840455] PM: Adding info for No Bus:ptyt1
[   40.844873] device: 'ptyt2': device_add
[   40.848669] PM: Adding info for No Bus:ptyt2
[   40.853094] device: 'ptyt3': device_add
[   40.856891] PM: Adding info for No Bus:ptyt3
[   40.861279] device: 'ptyt4': device_add
[   40.865108] PM: Adding info for No Bus:ptyt4
[   40.869487] device: 'ptyt5': device_add
[   40.873312] PM: Adding info for No Bus:ptyt5
[   40.877685] device: 'ptyt6': device_add
[   40.881478] PM: Adding info for No Bus:ptyt6
[   40.885901] device: 'ptyt7': device_add
[   40.889704] PM: Adding info for No Bus:ptyt7
[   40.894112] device: 'ptyt8': device_add
[   40.897913] PM: Adding info for No Bus:ptyt8
[   40.902300] device: 'ptyt9': device_add
[   40.906125] PM: Adding info for No Bus:ptyt9
[   40.910502] device: 'ptyta': device_add
[   40.914325] PM: Adding info for No Bus:ptyta
[   40.918710] device: 'ptytb': device_add
[   40.922535] PM: Adding info for No Bus:ptytb
[   40.926917] device: 'ptytc': device_add
[   40.930728] PM: Adding info for No Bus:ptytc
[   40.935132] device: 'ptytd': device_add
[   40.938925] PM: Adding info for No Bus:ptytd
[   40.943345] device: 'ptyte': device_add
[   40.947144] PM: Adding info for No Bus:ptyte
[   40.951537] device: 'ptytf': device_add
[   40.955364] PM: Adding info for No Bus:ptytf
[   40.959749] device: 'ptyu0': device_add
[   40.963574] PM: Adding info for No Bus:ptyu0
[   40.967947] device: 'ptyu1': device_add
[   40.971750] PM: Adding info for No Bus:ptyu1
[   40.976162] device: 'ptyu2': device_add
[   40.979959] PM: Adding info for No Bus:ptyu2
[   40.984372] device: 'ptyu3': device_add
[   40.988177] PM: Adding info for No Bus:ptyu3
[   40.992567] device: 'ptyu4': device_add
[   40.996361] PM: Adding info for No Bus:ptyu4
[   41.001385] device: 'ptyu5': device_add
[   41.005210] PM: Adding info for No Bus:ptyu5
[   41.009591] device: 'ptyu6': device_add
[   41.013468] PM: Adding info for No Bus:ptyu6
[   41.017847] device: 'ptyu7': device_add
[   41.021652] PM: Adding info for No Bus:ptyu7
[   41.026074] device: 'ptyu8': device_add
[   41.029873] PM: Adding info for No Bus:ptyu8
[   41.034306] device: 'ptyu9': device_add
[   41.038102] PM: Adding info for No Bus:ptyu9
[   41.042525] device: 'ptyua': device_add
[   41.046324] PM: Adding info for No Bus:ptyua
[   41.050718] device: 'ptyub': device_add
[   41.054542] PM: Adding info for No Bus:ptyub
[   41.058917] device: 'ptyuc': device_add
[   41.062751] PM: Adding info for No Bus:ptyuc
[   41.067132] device: 'ptyud': device_add
[   41.070930] PM: Adding info for No Bus:ptyud
[   41.075344] device: 'ptyue': device_add
[   41.079140] PM: Adding info for No Bus:ptyue
[   41.083558] device: 'ptyuf': device_add
[   41.087359] PM: Adding info for No Bus:ptyuf
[   41.091750] device: 'ptyv0': device_add
[   41.095577] PM: Adding info for No Bus:ptyv0
[   41.099963] device: 'ptyv1': device_add
[   41.103787] PM: Adding info for No Bus:ptyv1
[   41.108157] device: 'ptyv2': device_add
[   41.111959] PM: Adding info for No Bus:ptyv2
[   41.116378] device: 'ptyv3': device_add
[   41.120181] PM: Adding info for No Bus:ptyv3
[   41.124590] device: 'ptyv4': device_add
[   41.128399] PM: Adding info for No Bus:ptyv4
[   41.132815] device: 'ptyv5': device_add
[   41.136614] PM: Adding info for No Bus:ptyv5
[   41.141002] device: 'ptyv6': device_add
[   41.144830] PM: Adding info for No Bus:ptyv6
[   41.149210] device: 'ptyv7': device_add
[   41.153037] PM: Adding info for No Bus:ptyv7
[   41.157414] device: 'ptyv8': device_add
[   41.161214] PM: Adding info for No Bus:ptyv8
[   41.165629] device: 'ptyv9': device_add
[   41.169433] PM: Adding info for No Bus:ptyv9
[   41.173849] device: 'ptyva': device_add
[   41.177645] PM: Adding info for No Bus:ptyva
[   41.182035] device: 'ptyvb': device_add
[   41.185858] PM: Adding info for No Bus:ptyvb
[   41.190258] device: 'ptyvc': device_add
[   41.194076] PM: Adding info for No Bus:ptyvc
[   41.198445] device: 'ptyvd': device_add
[   41.202243] PM: Adding info for No Bus:ptyvd
[   41.206667] device: 'ptyve': device_add
[   41.210465] PM: Adding info for No Bus:ptyve
[   41.214882] device: 'ptyvf': device_add
[   41.218681] PM: Adding info for No Bus:ptyvf
[   41.223099] device: 'ptyw0': device_add
[   41.226905] PM: Adding info for No Bus:ptyw0
[   41.231290] device: 'ptyw1': device_add
[   41.235120] PM: Adding info for No Bus:ptyw1
[   41.239504] device: 'ptyw2': device_add
[   41.243330] PM: Adding info for No Bus:ptyw2
[   41.247703] device: 'ptyw3': device_add
[   41.251504] PM: Adding info for No Bus:ptyw3
[   41.255921] device: 'ptyw4': device_add
[   41.259724] PM: Adding info for No Bus:ptyw4
[   41.264138] device: 'ptyw5': device_add
[   41.267939] PM: Adding info for No Bus:ptyw5
[   41.272330] device: 'ptyw6': device_add
[   41.276154] PM: Adding info for No Bus:ptyw6
[   41.280525] device: 'ptyw7': device_add
[   41.284348] PM: Adding info for No Bus:ptyw7
[   41.288730] device: 'ptyw8': device_add
[   41.292558] PM: Adding info for No Bus:ptyw8
[   41.296938] device: 'ptyw9': device_add
[   41.300739] PM: Adding info for No Bus:ptyw9
[   41.305162] device: 'ptywa': device_add
[   41.308963] PM: Adding info for No Bus:ptywa
[   41.313382] device: 'ptywb': device_add
[   41.317184] PM: Adding info for No Bus:ptywb
[   41.321573] device: 'ptywc': device_add
[   41.325407] PM: Adding info for No Bus:ptywc
[   41.329797] device: 'ptywd': device_add
[   41.333627] PM: Adding info for No Bus:ptywd
[   41.338006] device: 'ptywe': device_add
[   41.341809] PM: Adding info for No Bus:ptywe
[   41.346226] device: 'ptywf': device_add
[   41.350036] PM: Adding info for No Bus:ptywf
[   41.354446] device: 'ptyx0': device_add
[   41.358248] PM: Adding info for No Bus:ptyx0
[   41.362663] device: 'ptyx1': device_add
[   41.366460] PM: Adding info for No Bus:ptyx1
[   41.370860] device: 'ptyx2': device_add
[   41.374688] PM: Adding info for No Bus:ptyx2
[   41.379072] device: 'ptyx3': device_add
[   41.382902] PM: Adding info for No Bus:ptyx3
[   41.387283] device: 'ptyx4': device_add
[   41.391084] PM: Adding info for No Bus:ptyx4
[   41.395585] device: 'ptyx5': device_add
[   41.399388] PM: Adding info for No Bus:ptyx5
[   41.403804] device: 'ptyx6': device_add
[   41.407604] PM: Adding info for No Bus:ptyx6
[   41.411997] device: 'ptyx7': device_add
[   41.415865] PM: Adding info for No Bus:ptyx7
[   41.420252] device: 'ptyx8': device_add
[   41.424070] PM: Adding info for No Bus:ptyx8
[   41.428453] device: 'ptyx9': device_add
[   41.432261] PM: Adding info for No Bus:ptyx9
[   41.436682] device: 'ptyxa': device_add
[   41.440586] PM: Adding info for No Bus:ptyxa
[   41.445007] device: 'ptyxb': device_add
[   41.448828] PM: Adding info for No Bus:ptyxb
[   41.453248] device: 'ptyxc': device_add
[   41.457061] PM: Adding info for No Bus:ptyxc
[   41.461440] device: 'ptyxd': device_add
[   41.465278] PM: Adding info for No Bus:ptyxd
[   41.469654] device: 'ptyxe': device_add
[   41.473488] PM: Adding info for No Bus:ptyxe
[   41.477860] device: 'ptyxf': device_add
[   41.481659] PM: Adding info for No Bus:ptyxf
[   41.486074] device: 'ptyy0': device_add
[   41.489885] PM: Adding info for No Bus:ptyy0
[   41.494293] device: 'ptyy1': device_add
[   41.498097] PM: Adding info for No Bus:ptyy1
[   41.502487] device: 'ptyy2': device_add
[   41.506312] PM: Adding info for No Bus:ptyy2
[   41.510696] device: 'ptyy3': device_add
[   41.514520] PM: Adding info for No Bus:ptyy3
[   41.518901] device: 'ptyy4': device_add
[   41.522737] PM: Adding info for No Bus:ptyy4
[   41.527116] device: 'ptyy5': device_add
[   41.530928] PM: Adding info for No Bus:ptyy5
[   41.535335] device: 'ptyy6': device_add
[   41.539138] PM: Adding info for No Bus:ptyy6
[   41.543556] device: 'ptyy7': device_add
[   41.547361] PM: Adding info for No Bus:ptyy7
[   41.551743] device: 'ptyy8': device_add
[   41.555579] PM: Adding info for No Bus:ptyy8
[   41.559966] device: 'ptyy9': device_add
[   41.563795] PM: Adding info for No Bus:ptyy9
[   41.568167] device: 'ptyya': device_add
[   41.571970] PM: Adding info for No Bus:ptyya
[   41.576385] device: 'ptyyb': device_add
[   41.580194] PM: Adding info for No Bus:ptyyb
[   41.584601] device: 'ptyyc': device_add
[   41.588404] PM: Adding info for No Bus:ptyyc
[   41.592813] device: 'ptyyd': device_add
[   41.596620] PM: Adding info for No Bus:ptyyd
[   41.601006] device: 'ptyye': device_add
[   41.604837] PM: Adding info for No Bus:ptyye
[   41.609221] device: 'ptyyf': device_add
[   41.613049] PM: Adding info for No Bus:ptyyf
[   41.617432] device: 'ptyz0': device_add
[   41.621242] PM: Adding info for No Bus:ptyz0
[   41.625661] device: 'ptyz1': device_add
[   41.629468] PM: Adding info for No Bus:ptyz1
[   41.633876] device: 'ptyz2': device_add
[   41.637686] PM: Adding info for No Bus:ptyz2
[   41.642070] device: 'ptyz3': device_add
[   41.645906] PM: Adding info for No Bus:ptyz3
[   41.650287] device: 'ptyz4': device_add
[   41.654103] PM: Adding info for No Bus:ptyz4
[   41.658485] device: 'ptyz5': device_add
[   41.662282] PM: Adding info for No Bus:ptyz5
[   41.666705] device: 'ptyz6': device_add
[   41.670516] PM: Adding info for No Bus:ptyz6
[   41.674920] device: 'ptyz7': device_add
[   41.678720] PM: Adding info for No Bus:ptyz7
[   41.683133] device: 'ptyz8': device_add
[   41.686935] PM: Adding info for No Bus:ptyz8
[   41.691324] device: 'ptyz9': device_add
[   41.695157] PM: Adding info for No Bus:ptyz9
[   41.699533] device: 'ptyza': device_add
[   41.703378] PM: Adding info for No Bus:ptyza
[   41.707759] device: 'ptyzb': device_add
[   41.711568] PM: Adding info for No Bus:ptyzb
[   41.715980] device: 'ptyzc': device_add
[   41.719784] PM: Adding info for No Bus:ptyzc
[   41.724195] device: 'ptyzd': device_add
[   41.728003] PM: Adding info for No Bus:ptyzd
[   41.732380] device: 'ptyze': device_add
[   41.736212] PM: Adding info for No Bus:ptyze
[   41.741220] device: 'ptyzf': device_add
[   41.745045] PM: Adding info for No Bus:ptyzf
[   41.749425] device: 'ptya0': device_add
[   41.753253] PM: Adding info for No Bus:ptya0
[   41.757633] device: 'ptya1': device_add
[   41.761437] PM: Adding info for No Bus:ptya1
[   41.765846] device: 'ptya2': device_add
[   41.769654] PM: Adding info for No Bus:ptya2
[   41.774064] device: 'ptya3': device_add
[   41.777873] PM: Adding info for No Bus:ptya3
[   41.782258] device: 'ptya4': device_add
[   41.786096] PM: Adding info for No Bus:ptya4
[   41.790477] device: 'ptya5': device_add
[   41.794300] PM: Adding info for No Bus:ptya5
[   41.798674] device: 'ptya6': device_add
[   41.802483] PM: Adding info for No Bus:ptya6
[   41.806896] device: 'ptya7': device_add
[   41.810701] PM: Adding info for No Bus:ptya7
[   41.815107] device: 'ptya8': device_add
[   41.818913] PM: Adding info for No Bus:ptya8
[   41.823330] device: 'ptya9': device_add
[   41.827138] PM: Adding info for No Bus:ptya9
[   41.831516] device: 'ptyaa': device_add
[   41.835352] PM: Adding info for No Bus:ptyaa
[   41.839745] device: 'ptyab': device_add
[   41.843582] PM: Adding info for No Bus:ptyab
[   41.847954] device: 'ptyac': device_add
[   41.851761] PM: Adding info for No Bus:ptyac
[   41.856176] device: 'ptyad': device_add
[   41.859984] PM: Adding info for No Bus:ptyad
[   41.864390] device: 'ptyae': device_add
[   41.868198] PM: Adding info for No Bus:ptyae
[   41.872586] device: 'ptyaf': device_add
[   41.876393] PM: Adding info for No Bus:ptyaf
[   41.880793] device: 'ptyb0': device_add
[   41.884629] PM: Adding info for No Bus:ptyb0
[   41.889012] device: 'ptyb1': device_add
[   41.892884] PM: Adding info for No Bus:ptyb1
[   41.897267] device: 'ptyb2': device_add
[   41.901077] PM: Adding info for No Bus:ptyb2
[   41.905490] device: 'ptyb3': device_add
[   41.909293] PM: Adding info for No Bus:ptyb3
[   41.913723] device: 'ptyb4': device_add
[   41.917533] PM: Adding info for No Bus:ptyb4
[   41.921916] device: 'ptyb5': device_add
[   41.925748] PM: Adding info for No Bus:ptyb5
[   41.930217] device: 'ptyb6': device_add
[   41.934044] PM: Adding info for No Bus:ptyb6
[   41.938424] device: 'ptyb7': device_add
[   41.942232] PM: Adding info for No Bus:ptyb7
[   41.946658] device: 'ptyb8': device_add
[   41.950465] PM: Adding info for No Bus:ptyb8
[   41.954870] device: 'ptyb9': device_add
[   41.958675] PM: Adding info for No Bus:ptyb9
[   41.963136] device: 'ptyba': device_add
[   41.966947] PM: Adding info for No Bus:ptyba
[   41.971333] device: 'ptybb': device_add
[   41.975164] PM: Adding info for No Bus:ptybb
[   41.979543] device: 'ptybc': device_add
[   41.983403] PM: Adding info for No Bus:ptybc
[   41.987777] device: 'ptybd': device_add
[   41.991582] PM: Adding info for No Bus:ptybd
[   41.995995] device: 'ptybe': device_add
[   41.999807] PM: Adding info for No Bus:ptybe
[   42.004217] device: 'ptybf': device_add
[   42.008030] PM: Adding info for No Bus:ptybf
[   42.012408] device: 'ptyc0': device_add
[   42.016248] PM: Adding info for No Bus:ptyc0
[   42.020625] device: 'ptyc1': device_add
[   42.024450] PM: Adding info for No Bus:ptyc1
[   42.028829] device: 'ptyc2': device_add
[   42.032669] PM: Adding info for No Bus:ptyc2
[   42.037049] device: 'ptyc3': device_add
[   42.040854] PM: Adding info for No Bus:ptyc3
[   42.045270] device: 'ptyc4': device_add
[   42.049080] PM: Adding info for No Bus:ptyc4
[   42.053490] device: 'ptyc5': device_add
[   42.057297] PM: Adding info for No Bus:ptyc5
[   42.061678] device: 'ptyc6': device_add
[   42.065509] PM: Adding info for No Bus:ptyc6
[   42.069894] device: 'ptyc7': device_add
[   42.073725] PM: Adding info for No Bus:ptyc7
[   42.078106] device: 'ptyc8': device_add
[   42.081913] PM: Adding info for No Bus:ptyc8
[   42.086327] device: 'ptyc9': device_add
[   42.090139] PM: Adding info for No Bus:ptyc9
[   42.094546] device: 'ptyca': device_add
[   42.098358] PM: Adding info for No Bus:ptyca
[   42.102764] device: 'ptycb': device_add
[   42.106565] PM: Adding info for No Bus:ptycb
[   42.110953] device: 'ptycc': device_add
[   42.114784] PM: Adding info for No Bus:ptycc
[   42.119158] device: 'ptycd': device_add
[   42.122988] PM: Adding info for No Bus:ptycd
[   42.127370] device: 'ptyce': device_add
[   42.131186] PM: Adding info for No Bus:ptyce
[   42.135592] device: 'ptycf': device_add
[   42.139397] PM: Adding info for No Bus:ptycf
[   42.143808] device: 'ptyd0': device_add
[   42.147619] PM: Adding info for No Bus:ptyd0
[   42.151993] device: 'ptyd1': device_add
[   42.155827] PM: Adding info for No Bus:ptyd1
[   42.160254] device: 'ptyd2': device_add
[   42.164082] PM: Adding info for No Bus:ptyd2
[   42.168451] device: 'ptyd3': device_add
[   42.172262] PM: Adding info for No Bus:ptyd3
[   42.176675] device: 'ptyd4': device_add
[   42.180478] PM: Adding info for No Bus:ptyd4
[   42.184887] device: 'ptyd5': device_add
[   42.188696] PM: Adding info for No Bus:ptyd5
[   42.193103] device: 'ptyd6': device_add
[   42.196914] PM: Adding info for No Bus:ptyd6
[   42.201295] device: 'ptyd7': device_add
[   42.205132] PM: Adding info for No Bus:ptyd7
[   42.209514] device: 'ptyd8': device_add
[   42.213354] PM: Adding info for No Bus:ptyd8
[   42.217735] device: 'ptyd9': device_add
[   42.221538] PM: Adding info for No Bus:ptyd9
[   42.225949] device: 'ptyda': device_add
[   42.229766] PM: Adding info for No Bus:ptyda
[   42.234178] device: 'ptydb': device_add
[   42.237982] PM: Adding info for No Bus:ptydb
[   42.242366] device: 'ptydc': device_add
[   42.246200] PM: Adding info for No Bus:ptydc
[   42.250577] device: 'ptydd': device_add
[   42.254405] PM: Adding info for No Bus:ptydd
[   42.258778] device: 'ptyde': device_add
[   42.262611] PM: Adding info for No Bus:ptyde
[   42.266990] device: 'ptydf': device_add
[   42.270807] PM: Adding info for No Bus:ptydf
[   42.275205] device: 'ptye0': device_add
[   42.279011] PM: Adding info for No Bus:ptye0
[   42.283419] device: 'ptye1': device_add
[   42.287228] PM: Adding info for No Bus:ptye1
[   42.291609] device: 'ptye2': device_add
[   42.295450] PM: Adding info for No Bus:ptye2
[   42.299831] device: 'ptye3': device_add
[   42.303670] PM: Adding info for No Bus:ptye3
[   42.308043] device: 'ptye4': device_add
[   42.311854] PM: Adding info for No Bus:ptye4
[   42.316259] device: 'ptye5': device_add
[   42.320074] PM: Adding info for No Bus:ptye5
[   42.324482] device: 'ptye6': device_add
[   42.328299] PM: Adding info for No Bus:ptye6
[   42.332707] device: 'ptye7': device_add
[   42.336516] PM: Adding info for No Bus:ptye7
[   42.340897] device: 'ptye8': device_add
[   42.344740] PM: Adding info for No Bus:ptye8
[   42.349120] device: 'ptye9': device_add
[   42.352953] PM: Adding info for No Bus:ptye9
[   42.357332] device: 'ptyea': device_add
[   42.361146] PM: Adding info for No Bus:ptyea
[   42.365557] device: 'ptyeb': device_add
[   42.369370] PM: Adding info for No Bus:ptyeb
[   42.373779] device: 'ptyec': device_add
[   42.377590] PM: Adding info for No Bus:ptyec
[   42.381974] device: 'ptyed': device_add
[   42.385813] PM: Adding info for No Bus:ptyed
[   42.390247] device: 'ptyee': device_add
[   42.394072] PM: Adding info for No Bus:ptyee
[   42.398446] device: 'ptyef': device_add
[   42.402249] PM: Adding info for No Bus:ptyef
[   42.406682] device: 'ttyp0': device_add
[   42.410485] PM: Adding info for No Bus:ttyp0
[   42.414902] device: 'ttyp1': device_add
[   42.418706] PM: Adding info for No Bus:ttyp1
[   42.423123] device: 'ttyp2': device_add
[   42.426931] PM: Adding info for No Bus:ttyp2
[   42.431309] device: 'ttyp3': device_add
[   42.435145] PM: Adding info for No Bus:ttyp3
[   42.439532] device: 'ttyp4': device_add
[   42.443366] PM: Adding info for No Bus:ttyp4
[   42.447741] device: 'ttyp5': device_add
[   42.451550] PM: Adding info for No Bus:ttyp5
[   42.455960] device: 'ttyp6': device_add
[   42.459765] PM: Adding info for No Bus:ttyp6
[   42.464176] device: 'ttyp7': device_add
[   42.467980] PM: Adding info for No Bus:ttyp7
[   42.472358] device: 'ttyp8': device_add
[   42.476193] PM: Adding info for No Bus:ttyp8
[   42.481206] device: 'ttyp9': device_add
[   42.485037] PM: Adding info for No Bus:ttyp9
[   42.489414] device: 'ttypa': device_add
[   42.493250] PM: Adding info for No Bus:ttypa
[   42.497634] device: 'ttypb': device_add
[   42.501444] PM: Adding info for No Bus:ttypb
[   42.505849] device: 'ttypc': device_add
[   42.509659] PM: Adding info for No Bus:ttypc
[   42.514066] device: 'ttypd': device_add
[   42.517877] PM: Adding info for No Bus:ttypd
[   42.522259] device: 'ttype': device_add
[   42.526103] PM: Adding info for No Bus:ttype
[   42.530490] device: 'ttypf': device_add
[   42.534313] PM: Adding info for No Bus:ttypf
[   42.538690] device: 'ttyq0': device_add
[   42.542493] PM: Adding info for No Bus:ttyq0
[   42.546907] device: 'ttyq1': device_add
[   42.550719] PM: Adding info for No Bus:ttyq1
[   42.555119] device: 'ttyq2': device_add
[   42.558931] PM: Adding info for No Bus:ttyq2
[   42.563340] device: 'ttyq3': device_add
[   42.567152] PM: Adding info for No Bus:ttyq3
[   42.571528] device: 'ttyq4': device_add
[   42.575359] PM: Adding info for No Bus:ttyq4
[   42.579739] device: 'ttyq5': device_add
[   42.583580] PM: Adding info for No Bus:ttyq5
[   42.587954] device: 'ttyq6': device_add
[   42.591765] PM: Adding info for No Bus:ttyq6
[   42.596176] device: 'ttyq7': device_add
[   42.599989] PM: Adding info for No Bus:ttyq7
[   42.604399] device: 'ttyq8': device_add
[   42.608325] PM: Adding info for No Bus:ttyq8
[   42.612726] device: 'ttyq9': device_add
[   42.616555] PM: Adding info for No Bus:ttyq9
[   42.620946] device: 'ttyqa': device_add
[   42.624798] PM: Adding info for No Bus:ttyqa
[   42.629178] device: 'ttyqb': device_add
[   42.633023] PM: Adding info for No Bus:ttyqb
[   42.637400] device: 'ttyqc': device_add
[   42.641210] PM: Adding info for No Bus:ttyqc
[   42.645627] device: 'ttyqd': device_add
[   42.649443] PM: Adding info for No Bus:ttyqd
[   42.653844] device: 'ttyqe': device_add
[   42.657654] PM: Adding info for No Bus:ttyqe
[   42.662038] device: 'ttyqf': device_add
[   42.665878] PM: Adding info for No Bus:ttyqf
[   42.670267] device: 'ttyr0': device_add
[   42.674091] PM: Adding info for No Bus:ttyr0
[   42.678470] device: 'ttyr1': device_add
[   42.682279] PM: Adding info for No Bus:ttyr1
[   42.686690] device: 'ttyr2': device_add
[   42.690505] PM: Adding info for No Bus:ttyr2
[   42.694911] device: 'ttyr3': device_add
[   42.698718] PM: Adding info for No Bus:ttyr3
[   42.703128] device: 'ttyr4': device_add
[   42.706935] PM: Adding info for No Bus:ttyr4
[   42.711318] device: 'ttyr5': device_add
[   42.715159] PM: Adding info for No Bus:ttyr5
[   42.719542] device: 'ttyr6': device_add
[   42.723381] PM: Adding info for No Bus:ttyr6
[   42.727757] device: 'ttyr7': device_add
[   42.731569] PM: Adding info for No Bus:ttyr7
[   42.735982] device: 'ttyr8': device_add
[   42.739791] PM: Adding info for No Bus:ttyr8
[   42.744201] device: 'ttyr9': device_add
[   42.748007] PM: Adding info for No Bus:ttyr9
[   42.752383] device: 'ttyra': device_add
[   42.756218] PM: Adding info for No Bus:ttyra
[   42.760607] device: 'ttyrb': device_add
[   42.764434] PM: Adding info for No Bus:ttyrb
[   42.768815] device: 'ttyrc': device_add
[   42.772652] PM: Adding info for No Bus:ttyrc
[   42.777030] device: 'ttyrd': device_add
[   42.780844] PM: Adding info for No Bus:ttyrd
[   42.785254] device: 'ttyre': device_add
[   42.789058] PM: Adding info for No Bus:ttyre
[   42.793471] device: 'ttyrf': device_add
[   42.797277] PM: Adding info for No Bus:ttyrf
[   42.801660] device: 'ttys0': device_add
[   42.805500] PM: Adding info for No Bus:ttys0
[   42.809883] device: 'ttys1': device_add
[   42.813715] PM: Adding info for No Bus:ttys1
[   42.818088] device: 'ttys2': device_add
[   42.821897] PM: Adding info for No Bus:ttys2
[   42.826305] device: 'ttys3': device_add
[   42.830125] PM: Adding info for No Bus:ttys3
[   42.834531] device: 'ttys4': device_add
[   42.838342] PM: Adding info for No Bus:ttys4
[   42.842751] device: 'ttys5': device_add
[   42.846554] PM: Adding info for No Bus:ttys5
[   42.850935] device: 'ttys6': device_add
[   42.854773] PM: Adding info for No Bus:ttys6
[   42.859158] device: 'ttys7': device_add
[   42.863002] PM: Adding info for No Bus:ttys7
[   42.867387] device: 'ttys8': device_add
[   42.871197] PM: Adding info for No Bus:ttys8
[   42.875604] device: 'ttys9': device_add
[   42.879411] PM: Adding info for No Bus:ttys9
[   42.883828] device: 'ttysa': device_add
[   42.887641] PM: Adding info for No Bus:ttysa
[   42.892029] device: 'ttysb': device_add
[   42.895863] PM: Adding info for No Bus:ttysb
[   42.900251] device: 'ttysc': device_add
[   42.904079] PM: Adding info for No Bus:ttysc
[   42.908465] device: 'ttysd': device_add
[   42.912273] PM: Adding info for No Bus:ttysd
[   42.916687] device: 'ttyse': device_add
[   42.920495] PM: Adding info for No Bus:ttyse
[   42.924901] device: 'ttysf': device_add
[   42.928711] PM: Adding info for No Bus:ttysf
[   42.933116] device: 'ttyt0': device_add
[   42.936926] PM: Adding info for No Bus:ttyt0
[   42.941311] device: 'ttyt1': device_add
[   42.945147] PM: Adding info for No Bus:ttyt1
[   42.949528] device: 'ttyt2': device_add
[   42.953366] PM: Adding info for No Bus:ttyt2
[   42.957753] device: 'ttyt3': device_add
[   42.961562] PM: Adding info for No Bus:ttyt3
[   42.965966] device: 'ttyt4': device_add
[   42.969776] PM: Adding info for No Bus:ttyt4
[   42.974178] device: 'ttyt5': device_add
[   42.977991] PM: Adding info for No Bus:ttyt5
[   42.982371] device: 'ttyt6': device_add
[   42.986212] PM: Adding info for No Bus:ttyt6
[   42.990592] device: 'ttyt7': device_add
[   42.994420] PM: Adding info for No Bus:ttyt7
[   42.998791] device: 'ttyt8': device_add
[   43.002637] PM: Adding info for No Bus:ttyt8
[   43.007023] device: 'ttyt9': device_add
[   43.010838] PM: Adding info for No Bus:ttyt9
[   43.015252] device: 'ttyta': device_add
[   43.019063] PM: Adding info for No Bus:ttyta
[   43.023467] device: 'ttytb': device_add
[   43.027282] PM: Adding info for No Bus:ttytb
[   43.031665] device: 'ttytc': device_add
[   43.035517] PM: Adding info for No Bus:ttytc
[   43.039897] device: 'ttytd': device_add
[   43.043735] PM: Adding info for No Bus:ttytd
[   43.048116] device: 'ttyte': device_add
[   43.051921] PM: Adding info for No Bus:ttyte
[   43.056328] device: 'ttytf': device_add
[   43.060148] PM: Adding info for No Bus:ttytf
[   43.064554] device: 'ttyu0': device_add
[   43.068373] PM: Adding info for No Bus:ttyu0
[   43.072781] device: 'ttyu1': device_add
[   43.076592] PM: Adding info for No Bus:ttyu1
[   43.080969] device: 'ttyu2': device_add
[   43.084803] PM: Adding info for No Bus:ttyu2
[   43.089184] device: 'ttyu3': device_add
[   43.093024] PM: Adding info for No Bus:ttyu3
[   43.097408] device: 'ttyu4': device_add
[   43.101224] PM: Adding info for No Bus:ttyu4
[   43.105637] device: 'ttyu5': device_add
[   43.109448] PM: Adding info for No Bus:ttyu5
[   43.113850] device: 'ttyu6': device_add
[   43.117668] PM: Adding info for No Bus:ttyu6
[   43.122041] device: 'ttyu7': device_add
[   43.125881] PM: Adding info for No Bus:ttyu7
[   43.130262] device: 'ttyu8': device_add
[   43.134096] PM: Adding info for No Bus:ttyu8
[   43.138473] device: 'ttyu9': device_add
[   43.142285] PM: Adding info for No Bus:ttyu9
[   43.146699] device: 'ttyua': device_add
[   43.150514] PM: Adding info for No Bus:ttyua
[   43.154917] device: 'ttyub': device_add
[   43.158728] PM: Adding info for No Bus:ttyub
[   43.163133] device: 'ttyuc': device_add
[   43.166944] PM: Adding info for No Bus:ttyuc
[   43.171320] device: 'ttyud': device_add
[   43.175155] PM: Adding info for No Bus:ttyud
[   43.179537] device: 'ttyue': device_add
[   43.183378] PM: Adding info for No Bus:ttyue
[   43.187756] device: 'ttyuf': device_add
[   43.191567] PM: Adding info for No Bus:ttyuf
[   43.195985] device: 'ttyv0': device_add
[   43.199799] PM: Adding info for No Bus:ttyv0
[   43.204207] device: 'ttyv1': device_add
[   43.208020] PM: Adding info for No Bus:ttyv1
[   43.212400] device: 'ttyv2': device_add
[   43.216240] PM: Adding info for No Bus:ttyv2
[   43.221258] device: 'ttyv3': device_add
[   43.225089] PM: Adding info for No Bus:ttyv3
[   43.229471] device: 'ttyv4': device_add
[   43.233313] PM: Adding info for No Bus:ttyv4
[   43.237693] device: 'ttyv5': device_add
[   43.241504] PM: Adding info for No Bus:ttyv5
[   43.245914] device: 'ttyv6': device_add
[   43.249729] PM: Adding info for No Bus:ttyv6
[   43.254135] device: 'ttyv7': device_add
[   43.257946] PM: Adding info for No Bus:ttyv7
[   43.262327] device: 'ttyv8': device_add
[   43.266169] PM: Adding info for No Bus:ttyv8
[   43.270552] device: 'ttyv9': device_add
[   43.274385] PM: Adding info for No Bus:ttyv9
[   43.278763] device: 'ttyva': device_add
[   43.282603] PM: Adding info for No Bus:ttyva
[   43.286985] device: 'ttyvb': device_add
[   43.290801] PM: Adding info for No Bus:ttyvb
[   43.295226] device: 'ttyvc': device_add
[   43.299036] PM: Adding info for No Bus:ttyvc
[   43.303436] device: 'ttyvd': device_add
[   43.307256] PM: Adding info for No Bus:ttyvd
[   43.311640] device: 'ttyve': device_add
[   43.315482] PM: Adding info for No Bus:ttyve
[   43.319867] device: 'ttyvf': device_add
[   43.323716] PM: Adding info for No Bus:ttyvf
[   43.328099] device: 'ttyw0': device_add
[   43.331914] PM: Adding info for No Bus:ttyw0
[   43.336317] device: 'ttyw1': device_add
[   43.340138] PM: Adding info for No Bus:ttyw1
[   43.344546] device: 'ttyw2': device_add
[   43.348362] PM: Adding info for No Bus:ttyw2
[   43.352770] device: 'ttyw3': device_add
[   43.356585] PM: Adding info for No Bus:ttyw3
[   43.360965] device: 'ttyw4': device_add
[   43.364803] PM: Adding info for No Bus:ttyw4
[   43.369181] device: 'ttyw5': device_add
[   43.373023] PM: Adding info for No Bus:ttyw5
[   43.377402] device: 'ttyw6': device_add
[   43.381215] PM: Adding info for No Bus:ttyw6
[   43.385631] device: 'ttyw7': device_add
[   43.389451] PM: Adding info for No Bus:ttyw7
[   43.393854] device: 'ttyw8': device_add
[   43.397667] PM: Adding info for No Bus:ttyw8
[   43.402053] device: 'ttyw9': device_add
[   43.405899] PM: Adding info for No Bus:ttyw9
[   43.410277] device: 'ttywa': device_add
[   43.414115] PM: Adding info for No Bus:ttywa
[   43.418493] device: 'ttywb': device_add
[   43.422308] PM: Adding info for No Bus:ttywb
[   43.426723] device: 'ttywc': device_add
[   43.430544] PM: Adding info for No Bus:ttywc
[   43.434944] device: 'ttywd': device_add
[   43.438753] PM: Adding info for No Bus:ttywd
[   43.443158] device: 'ttywe': device_add
[   43.446974] PM: Adding info for No Bus:ttywe
[   43.451356] device: 'ttywf': device_add
[   43.455201] PM: Adding info for No Bus:ttywf
[   43.459589] device: 'ttyx0': device_add
[   43.463427] PM: Adding info for No Bus:ttyx0
[   43.467802] device: 'ttyx1': device_add
[   43.471617] PM: Adding info for No Bus:ttyx1
[   43.476031] device: 'ttyx2': device_add
[   43.479847] PM: Adding info for No Bus:ttyx2
[   43.484246] device: 'ttyx3': device_add
[   43.488059] PM: Adding info for No Bus:ttyx3
[   43.492441] device: 'ttyx4': device_add
[   43.496277] PM: Adding info for No Bus:ttyx4
[   43.500652] device: 'ttyx5': device_add
[   43.504485] PM: Adding info for No Bus:ttyx5
[   43.508866] device: 'ttyx6': device_add
[   43.512706] PM: Adding info for No Bus:ttyx6
[   43.517084] device: 'ttyx7': device_add
[   43.520899] PM: Adding info for No Bus:ttyx7
[   43.525310] device: 'ttyx8': device_add
[   43.529125] PM: Adding info for No Bus:ttyx8
[   43.533535] device: 'ttyx9': device_add
[   43.537349] PM: Adding info for No Bus:ttyx9
[   43.541732] device: 'ttyxa': device_add
[   43.545580] PM: Adding info for No Bus:ttyxa
[   43.549964] device: 'ttyxb': device_add
[   43.553808] PM: Adding info for No Bus:ttyxb
[   43.558180] device: 'ttyxc': device_add
[   43.561993] PM: Adding info for No Bus:ttyxc
[   43.566407] device: 'ttyxd': device_add
[   43.570224] PM: Adding info for No Bus:ttyxd
[   43.574632] device: 'ttyxe': device_add
[   43.578450] PM: Adding info for No Bus:ttyxe
[   43.582850] device: 'ttyxf': device_add
[   43.586661] PM: Adding info for No Bus:ttyxf
[   43.591039] device: 'ttyy0': device_add
[   43.594884] PM: Adding info for No Bus:ttyy0
[   43.599263] device: 'ttyy1': device_add
[   43.603107] PM: Adding info for No Bus:ttyy1
[   43.607492] device: 'ttyy2': device_add
[   43.611310] PM: Adding info for No Bus:ttyy2
[   43.615721] device: 'ttyy3': device_add
[   43.619533] PM: Adding info for No Bus:ttyy3
[   43.623932] device: 'ttyy4': device_add
[   43.627763] PM: Adding info for No Bus:ttyy4
[   43.632148] device: 'ttyy5': device_add
[   43.635993] PM: Adding info for No Bus:ttyy5
[   43.640373] device: 'ttyy6': device_add
[   43.644208] PM: Adding info for No Bus:ttyy6
[   43.648585] device: 'ttyy7': device_add
[   43.652404] PM: Adding info for No Bus:ttyy7
[   43.656816] device: 'ttyy8': device_add
[   43.660637] PM: Adding info for No Bus:ttyy8
[   43.665041] device: 'ttyy9': device_add
[   43.668859] PM: Adding info for No Bus:ttyy9
[   43.673273] device: 'ttyya': device_add
[   43.677094] PM: Adding info for No Bus:ttyya
[   43.681479] device: 'ttyyb': device_add
[   43.685321] PM: Adding info for No Bus:ttyyb
[   43.689708] device: 'ttyyc': device_add
[   43.693551] PM: Adding info for No Bus:ttyyc
[   43.697928] device: 'ttyyd': device_add
[   43.701746] PM: Adding info for No Bus:ttyyd
[   43.706157] device: 'ttyye': device_add
[   43.709977] PM: Adding info for No Bus:ttyye
[   43.714381] device: 'ttyyf': device_add
[   43.718205] PM: Adding info for No Bus:ttyyf
[   43.722591] device: 'ttyz0': device_add
[   43.726410] PM: Adding info for No Bus:ttyz0
[   43.730817] device: 'ttyz1': device_add
[   43.734670] PM: Adding info for No Bus:ttyz1
[   43.739056] device: 'ttyz2': device_add
[   43.742944] PM: Adding info for No Bus:ttyz2
[   43.747332] device: 'ttyz3': device_add
[   43.751151] PM: Adding info for No Bus:ttyz3
[   43.755559] device: 'ttyz4': device_add
[   43.759376] PM: Adding info for No Bus:ttyz4
[   43.763798] device: 'ttyz5': device_add
[   43.767715] PM: Adding info for No Bus:ttyz5
[   43.772092] device: 'ttyz6': device_add
[   43.775960] PM: Adding info for No Bus:ttyz6
[   43.780345] device: 'ttyz7': device_add
[   43.784193] PM: Adding info for No Bus:ttyz7
[   43.788570] device: 'ttyz8': device_add
[   43.792384] PM: Adding info for No Bus:ttyz8
[   43.796806] device: 'ttyz9': device_add
[   43.800620] PM: Adding info for No Bus:ttyz9
[   43.805035] device: 'ttyza': device_add
[   43.808857] PM: Adding info for No Bus:ttyza
[   43.813270] device: 'ttyzb': device_add
[   43.817091] PM: Adding info for No Bus:ttyzb
[   43.821473] device: 'ttyzc': device_add
[   43.825319] PM: Adding info for No Bus:ttyzc
[   43.829699] device: 'ttyzd': device_add
[   43.833549] PM: Adding info for No Bus:ttyzd
[   43.837927] device: 'ttyze': device_add
[   43.841741] PM: Adding info for No Bus:ttyze
[   43.846153] device: 'ttyzf': device_add
[   43.849974] PM: Adding info for No Bus:ttyzf
[   43.854376] device: 'ttya0': device_add
[   43.858198] PM: Adding info for No Bus:ttya0
[   43.862585] device: 'ttya1': device_add
[   43.866404] PM: Adding info for No Bus:ttya1
[   43.870789] device: 'ttya2': device_add
[   43.874649] PM: Adding info for No Bus:ttya2
[   43.879035] device: 'ttya3': device_add
[   43.882925] PM: Adding info for No Bus:ttya3
[   43.887307] device: 'ttya4': device_add
[   43.891132] PM: Adding info for No Bus:ttya4
[   43.895542] device: 'ttya5': device_add
[   43.899363] PM: Adding info for No Bus:ttya5
[   43.903788] device: 'ttya6': device_add
[   43.907605] PM: Adding info for No Bus:ttya6
[   43.911990] device: 'ttya7': device_add
[   43.915835] PM: Adding info for No Bus:ttya7
[   43.920252] device: 'ttya8': device_add
[   43.924091] PM: Adding info for No Bus:ttya8
[   43.928474] device: 'ttya9': device_add
[   43.932291] PM: Adding info for No Bus:ttya9
[   43.936718] device: 'ttyaa': device_add
[   43.940540] PM: Adding info for No Bus:ttyaa
[   43.944945] device: 'ttyab': device_add
[   43.948764] PM: Adding info for No Bus:ttyab
[   43.953176] device: 'ttyac': device_add
[   43.956999] PM: Adding info for No Bus:ttyac
[   43.962015] device: 'ttyad': device_add
[   43.965857] PM: Adding info for No Bus:ttyad
[   43.970244] device: 'ttyae': device_add
[   43.974078] PM: Adding info for No Bus:ttyae
[   43.978448] device: 'ttyaf': device_add
[   43.982267] PM: Adding info for No Bus:ttyaf
[   43.986680] device: 'ttyb0': device_add
[   43.990505] PM: Adding info for No Bus:ttyb0
[   43.994909] device: 'ttyb1': device_add
[   43.998726] PM: Adding info for No Bus:ttyb1
[   44.003132] device: 'ttyb2': device_add
[   44.006953] PM: Adding info for No Bus:ttyb2
[   44.011332] device: 'ttyb3': device_add
[   44.015189] PM: Adding info for No Bus:ttyb3
[   44.019570] device: 'ttyb4': device_add
[   44.023420] PM: Adding info for No Bus:ttyb4
[   44.027802] device: 'ttyb5': device_add
[   44.031628] PM: Adding info for No Bus:ttyb5
[   44.036028] device: 'ttyb6': device_add
[   44.039850] PM: Adding info for No Bus:ttyb6
[   44.044255] device: 'ttyb7': device_add
[   44.048083] PM: Adding info for No Bus:ttyb7
[   44.052466] device: 'ttyb8': device_add
[   44.056320] PM: Adding info for No Bus:ttyb8
[   44.060699] device: 'ttyb9': device_add
[   44.064537] PM: Adding info for No Bus:ttyb9
[   44.068916] device: 'ttyba': device_add
[   44.072768] PM: Adding info for No Bus:ttyba
[   44.077154] device: 'ttybb': device_add
[   44.080972] PM: Adding info for No Bus:ttybb
[   44.085378] device: 'ttybc': device_add
[   44.089206] PM: Adding info for No Bus:ttybc
[   44.093615] device: 'ttybd': device_add
[   44.097435] PM: Adding info for No Bus:ttybd
[   44.101810] device: 'ttybe': device_add
[   44.105654] PM: Adding info for No Bus:ttybe
[   44.110087] device: 'ttybf': device_add
[   44.113934] PM: Adding info for No Bus:ttybf
[   44.118319] device: 'ttyc0': device_add
[   44.122140] PM: Adding info for No Bus:ttyc0
[   44.126547] device: 'ttyc1': device_add
[   44.130374] PM: Adding info for No Bus:ttyc1
[   44.134779] device: 'ttyc2': device_add
[   44.138601] PM: Adding info for No Bus:ttyc2
[   44.143060] device: 'ttyc3': device_add
[   44.146877] PM: Adding info for No Bus:ttyc3
[   44.151254] device: 'ttyc4': device_add
[   44.155107] PM: Adding info for No Bus:ttyc4
[   44.159492] device: 'ttyc5': device_add
[   44.163366] PM: Adding info for No Bus:ttyc5
[   44.167746] device: 'ttyc6': device_add
[   44.171571] PM: Adding info for No Bus:ttyc6
[   44.175986] device: 'ttyc7': device_add
[   44.179802] PM: Adding info for No Bus:ttyc7
[   44.184216] device: 'ttyc8': device_add
[   44.188041] PM: Adding info for No Bus:ttyc8
[   44.192427] device: 'ttyc9': device_add
[   44.196278] PM: Adding info for No Bus:ttyc9
[   44.200660] device: 'ttyca': device_add
[   44.204503] PM: Adding info for No Bus:ttyca
[   44.208889] device: 'ttycb': device_add
[   44.212740] PM: Adding info for No Bus:ttycb
[   44.217124] device: 'ttycc': device_add
[   44.220942] PM: Adding info for No Bus:ttycc
[   44.225347] device: 'ttycd': device_add
[   44.229172] PM: Adding info for No Bus:ttycd
[   44.233579] device: 'ttyce': device_add
[   44.237406] PM: Adding info for No Bus:ttyce
[   44.241786] device: 'ttycf': device_add
[   44.245634] PM: Adding info for No Bus:ttycf
[   44.250021] device: 'ttyd0': device_add
[   44.253869] PM: Adding info for No Bus:ttyd0
[   44.258247] device: 'ttyd1': device_add
[   44.262068] PM: Adding info for No Bus:ttyd1
[   44.266473] device: 'ttyd2': device_add
[   44.270300] PM: Adding info for No Bus:ttyd2
[   44.274704] device: 'ttyd3': device_add
[   44.278528] PM: Adding info for No Bus:ttyd3
[   44.282926] device: 'ttyd4': device_add
[   44.286744] PM: Adding info for No Bus:ttyd4
[   44.291122] device: 'ttyd5': device_add
[   44.294976] PM: Adding info for No Bus:ttyd5
[   44.299361] device: 'ttyd6': device_add
[   44.303209] PM: Adding info for No Bus:ttyd6
[   44.307591] device: 'ttyd7': device_add
[   44.311416] PM: Adding info for No Bus:ttyd7
[   44.315821] device: 'ttyd8': device_add
[   44.319646] PM: Adding info for No Bus:ttyd8
[   44.324054] device: 'ttyd9': device_add
[   44.327882] PM: Adding info for No Bus:ttyd9
[   44.332263] device: 'ttyda': device_add
[   44.336113] PM: Adding info for No Bus:ttyda
[   44.340491] device: 'ttydb': device_add
[   44.344333] PM: Adding info for No Bus:ttydb
[   44.348709] device: 'ttydc': device_add
[   44.352561] PM: Adding info for No Bus:ttydc
[   44.356942] device: 'ttydd': device_add
[   44.360765] PM: Adding info for No Bus:ttydd
[   44.365167] device: 'ttyde': device_add
[   44.368992] PM: Adding info for No Bus:ttyde
[   44.373397] device: 'ttydf': device_add
[   44.377217] PM: Adding info for No Bus:ttydf
[   44.381595] device: 'ttye0': device_add
[   44.385447] PM: Adding info for No Bus:ttye0
[   44.389833] device: 'ttye1': device_add
[   44.393688] PM: Adding info for No Bus:ttye1
[   44.398064] device: 'ttye2': device_add
[   44.401887] PM: Adding info for No Bus:ttye2
[   44.406292] device: 'ttye3': device_add
[   44.410121] PM: Adding info for No Bus:ttye3
[   44.414526] device: 'ttye4': device_add
[   44.418353] PM: Adding info for No Bus:ttye4
[   44.422762] device: 'ttye5': device_add
[   44.426587] PM: Adding info for No Bus:ttye5
[   44.430968] device: 'ttye6': device_add
[   44.434822] PM: Adding info for No Bus:ttye6
[   44.439210] device: 'ttye7': device_add
[   44.443059] PM: Adding info for No Bus:ttye7
[   44.447439] device: 'ttye8': device_add
[   44.451268] PM: Adding info for No Bus:ttye8
[   44.455681] device: 'ttye9': device_add
[   44.459505] PM: Adding info for No Bus:ttye9
[   44.463910] device: 'ttyea': device_add
[   44.467737] PM: Adding info for No Bus:ttyea
[   44.472128] device: 'ttyeb': device_add
[   44.475984] PM: Adding info for No Bus:ttyeb
[   44.480362] device: 'ttyec': device_add
[   44.484201] PM: Adding info for No Bus:ttyec
[   44.488576] device: 'ttyed': device_add
[   44.492397] PM: Adding info for No Bus:ttyed
[   44.496804] device: 'ttyee': device_add
[   44.500625] PM: Adding info for No Bus:ttyee
[   44.505025] device: 'ttyef': device_add
[   44.508848] PM: Adding info for No Bus:ttyef
[   44.513297] device: 'ptmx': device_add
[   44.517024] PM: Adding info for No Bus:ptmx
[   44.521310] initcall pty_init+0x0/0x11 returned 0 after 4119462 usec=
s
[   44.527660] calling  sysrq_init+0x0/0x1f @ 1
[   44.531913] initcall sysrq_init+0x0/0x1f returned 0 after 25 usecs
[   44.538053] calling  rp_init+0x0/0x29b @ 1
[   44.542112] RocketPort device driver module, version 2.09, 12-June-2=
003
[   44.548754] No rocketport ports found; unloading driver
[   44.553975] initcall rp_init+0x0/0x29b returned -6 after 11580 usecs
[   44.560224] initcall rp_init+0x0/0x29b returned with error code -6=20
[   44.566481] calling  cy_init+0x0/0xf6 @ 1
[   44.570458] Cyclades driver 2.5 (built Jul  2 2009 09:17:53)
[   44.589150] bus: 'pci': add driver cyclades
[   44.593523] initcall cy_init+0x0/0xf6 returned 0 after 22524 usecs
[   44.599580] calling  stallion_module_init+0x0/0x28b @ 1
[   44.604808] Stallion Multiport Serial Driver: version 5.6.0
[   44.610365] bus: 'pci': add driver stallion
[   44.614804] device class 'staliomem': registering
[   44.619632] device: 'staliomem0': device_add
[   44.623903] PM: Adding info for No Bus:staliomem0
[   44.628754] device: 'staliomem1': device_add
[   44.633023] PM: Adding info for No Bus:staliomem1
[   44.637833] device: 'staliomem2': device_add
[   44.642069] PM: Adding info for No Bus:staliomem2
[   44.646911] device: 'staliomem3': device_add
[   44.651147] PM: Adding info for No Bus:staliomem3
[   44.655980] initcall stallion_module_init+0x0/0x28b returned 0 after=
 49970 usecs
[   44.663303] calling  istallion_module_init+0x0/0x1f1 @ 1
[   44.668569] Stallion Intelligent Multiport Serial Driver: version 5.=
6.0
[   44.675193] istallion: failed to register serial driver
[   44.680362] initcall istallion_module_init+0x0/0x1f1 returned -16 af=
ter 11515 usecs
[   44.687997] initcall istallion_module_init+0x0/0x1f1 returned with e=
rror code -16=20
[   44.695537] calling  epca_module_init+0x0/0xa @ 1
[   44.700210] DIGI epca driver version 1.3.0.1-LK2.6 loaded.
[   44.705680] bus: 'pci': add driver epca
[   44.709779] device: 'ttyD0': device_add
[   44.713632] PM: Adding info for No Bus:ttyD0
[   44.718021] device: 'ttyD1': device_add
[   44.721847] PM: Adding info for No Bus:ttyD1
[   44.726265] device: 'ttyD2': device_add
[   44.730086] PM: Adding info for No Bus:ttyD2
[   44.734484] device: 'ttyD3': device_add
[   44.738305] PM: Adding info for No Bus:ttyD3
[   44.743347] device: 'ttyD4': device_add
[   44.747171] PM: Adding info for No Bus:ttyD4
[   44.751551] device: 'ttyD5': device_add
[   44.755398] PM: Adding info for No Bus:ttyD5
[   44.759779] device: 'ttyD6': device_add
[   44.763631] PM: Adding info for No Bus:ttyD6
[   44.768019] device: 'ttyD7': device_add
[   44.771841] PM: Adding info for No Bus:ttyD7
[   44.776256] device: 'ttyD8': device_add
[   44.780079] PM: Adding info for No Bus:ttyD8
[   44.784482] device: 'ttyD9': device_add
[   44.788304] PM: Adding info for No Bus:ttyD9
[   44.792714] device: 'ttyD10': device_add
[   44.796625] PM: Adding info for No Bus:ttyD10
[   44.801092] device: 'ttyD11': device_add
[   44.805036] PM: Adding info for No Bus:ttyD11
[   44.809498] device: 'ttyD12': device_add
[   44.813431] PM: Adding info for No Bus:ttyD12
[   44.817900] device: 'ttyD13': device_add
[   44.821815] PM: Adding info for No Bus:ttyD13
[   44.826316] device: 'ttyD14': device_add
[   44.830227] PM: Adding info for No Bus:ttyD14
[   44.834721] device: 'ttyD15': device_add
[   44.838629] PM: Adding info for No Bus:ttyD15
[   44.843118] device: 'ttyD16': device_add
[   44.847029] PM: Adding info for No Bus:ttyD16
[   44.851495] device: 'ttyD17': device_add
[   44.855437] PM: Adding info for No Bus:ttyD17
[   44.859896] device: 'ttyD18': device_add
[   44.863837] PM: Adding info for No Bus:ttyD18
[   44.868306] device: 'ttyD19': device_add
[   44.872220] PM: Adding info for No Bus:ttyD19
[   44.876718] device: 'ttyD20': device_add
[   44.880634] PM: Adding info for No Bus:ttyD20
[   44.885128] device: 'ttyD21': device_add
[   44.889034] PM: Adding info for No Bus:ttyD21
[   44.893520] device: 'ttyD22': device_add
[   44.897438] PM: Adding info for No Bus:ttyD22
[   44.901909] device: 'ttyD23': device_add
[   44.905849] PM: Adding info for No Bus:ttyD23
[   44.910312] device: 'ttyD24': device_add
[   44.914237] PM: Adding info for No Bus:ttyD24
[   44.918701] device: 'ttyD25': device_add
[   44.922634] PM: Adding info for No Bus:ttyD25
[   44.927103] device: 'ttyD26': device_add
[   44.931015] PM: Adding info for No Bus:ttyD26
[   44.935509] device: 'ttyD27': device_add
[   44.939414] PM: Adding info for No Bus:ttyD27
[   44.943909] device: 'ttyD28': device_add
[   44.947824] PM: Adding info for No Bus:ttyD28
[   44.952293] device: 'ttyD29': device_add
[   44.956233] PM: Adding info for No Bus:ttyD29
[   44.960706] device: 'ttyD30': device_add
[   44.964638] PM: Adding info for No Bus:ttyD30
[   44.969094] device: 'ttyD31': device_add
[   44.973040] PM: Adding info for No Bus:ttyD31
[   44.977505] device: 'ttyD32': device_add
[   44.981415] PM: Adding info for No Bus:ttyD32
[   44.985915] device: 'ttyD33': device_add
[   44.989821] PM: Adding info for No Bus:ttyD33
[   44.994308] device: 'ttyD34': device_add
[   44.998222] PM: Adding info for No Bus:ttyD34
[   45.002711] device: 'ttyD35': device_add
[   45.006621] PM: Adding info for No Bus:ttyD35
[   45.011093] device: 'ttyD36': device_add
[   45.015042] PM: Adding info for No Bus:ttyD36
[   45.019509] device: 'ttyD37': device_add
[   45.023449] PM: Adding info for No Bus:ttyD37
[   45.027917] device: 'ttyD38': device_add
[   45.031829] PM: Adding info for No Bus:ttyD38
[   45.036322] device: 'ttyD39': device_add
[   45.040234] PM: Adding info for No Bus:ttyD39
[   45.044724] device: 'ttyD40': device_add
[   45.048637] PM: Adding info for No Bus:ttyD40
[   45.053128] device: 'ttyD41': device_add
[   45.057046] PM: Adding info for No Bus:ttyD41
[   45.061513] device: 'ttyD42': device_add
[   45.065457] PM: Adding info for No Bus:ttyD42
[   45.069914] device: 'ttyD43': device_add
[   45.073955] PM: Adding info for No Bus:ttyD43
[   45.078427] device: 'ttyD44': device_add
[   45.082366] PM: Adding info for No Bus:ttyD44
[   45.086863] device: 'ttyD45': device_add
[   45.090790] PM: Adding info for No Bus:ttyD45
[   45.095296] device: 'ttyD46': device_add
[   45.099207] PM: Adding info for No Bus:ttyD46
[   45.103711] device: 'ttyD47': device_add
[   45.107624] PM: Adding info for No Bus:ttyD47
[   45.112097] device: 'ttyD48': device_add
[   45.116032] PM: Adding info for No Bus:ttyD48
[   45.120495] device: 'ttyD49': device_add
[   45.124429] PM: Adding info for No Bus:ttyD49
[   45.128898] device: 'ttyD50': device_add
[   45.132844] PM: Adding info for No Bus:ttyD50
[   45.137314] device: 'ttyD51': device_add
[   45.141230] PM: Adding info for No Bus:ttyD51
[   45.145729] device: 'ttyD52': device_add
[   45.149639] PM: Adding info for No Bus:ttyD52
[   45.154136] device: 'ttyD53': device_add
[   45.158050] PM: Adding info for No Bus:ttyD53
[   45.162544] device: 'ttyD54': device_add
[   45.166458] PM: Adding info for No Bus:ttyD54
[   45.170926] device: 'ttyD55': device_add
[   45.174858] PM: Adding info for No Bus:ttyD55
[   45.179315] device: 'ttyD56': device_add
[   45.183254] PM: Adding info for No Bus:ttyD56
[   45.187717] device: 'ttyD57': device_add
[   45.191627] PM: Adding info for No Bus:ttyD57
[   45.196124] device: 'ttyD58': device_add
[   45.200041] PM: Adding info for No Bus:ttyD58
[   45.204529] device: 'ttyD59': device_add
[   45.208447] PM: Adding info for No Bus:ttyD59
[   45.212939] device: 'ttyD60': device_add
[   45.216853] PM: Adding info for No Bus:ttyD60
[   45.221321] device: 'ttyD61': device_add
[   45.225264] PM: Adding info for No Bus:ttyD61
[   45.229727] device: 'ttyD62': device_add
[   45.233678] PM: Adding info for No Bus:ttyD62
[   45.238140] device: 'ttyD63': device_add
[   45.242054] PM: Adding info for No Bus:ttyD63
[   45.246543] device: 'ttyD64': device_add
[   45.250469] PM: Adding info for No Bus:ttyD64
[   45.254962] device: 'ttyD65': device_add
[   45.258880] PM: Adding info for No Bus:ttyD65
[   45.263373] device: 'ttyD66': device_add
[   45.267290] PM: Adding info for No Bus:ttyD66
[   45.271755] device: 'ttyD67': device_add
[   45.275698] PM: Adding info for No Bus:ttyD67
[   45.280303] device: 'ttyD68': device_add
[   45.284237] PM: Adding info for No Bus:ttyD68
[   45.288716] device: 'ttyD69': device_add
[   45.292662] PM: Adding info for No Bus:ttyD69
[   45.297135] device: 'ttyD70': device_add
[   45.301051] PM: Adding info for No Bus:ttyD70
[   45.305600] device: 'ttyD71': device_add
[   45.309518] PM: Adding info for No Bus:ttyD71
[   45.314061] device: 'ttyD72': device_add
[   45.317986] PM: Adding info for No Bus:ttyD72
[   45.322453] device: 'ttyD73': device_add
[   45.326417] PM: Adding info for No Bus:ttyD73
[   45.330893] device: 'ttyD74': device_add
[   45.334823] PM: Adding info for No Bus:ttyD74
[   45.339292] device: 'ttyD75': device_add
[   45.343266] PM: Adding info for No Bus:ttyD75
[   45.347735] device: 'ttyD76': device_add
[   45.351652] PM: Adding info for No Bus:ttyD76
[   45.356160] device: 'ttyD77': device_add
[   45.360074] PM: Adding info for No Bus:ttyD77
[   45.364579] device: 'ttyD78': device_add
[   45.368501] PM: Adding info for No Bus:ttyD78
[   45.372996] device: 'ttyD79': device_add
[   45.376914] PM: Adding info for No Bus:ttyD79
[   45.381383] device: 'ttyD80': device_add
[   45.385321] PM: Adding info for No Bus:ttyD80
[   45.389786] device: 'ttyD81': device_add
[   45.393732] PM: Adding info for No Bus:ttyD81
[   45.398204] device: 'ttyD82': device_add
[   45.402123] PM: Adding info for No Bus:ttyD82
[   45.406614] device: 'ttyD83': device_add
[   45.410535] PM: Adding info for No Bus:ttyD83
[   45.415027] device: 'ttyD84': device_add
[   45.418947] PM: Adding info for No Bus:ttyD84
[   45.423438] device: 'ttyD85': device_add
[   45.427357] PM: Adding info for No Bus:ttyD85
[   45.431832] device: 'ttyD86': device_add
[   45.435771] PM: Adding info for No Bus:ttyD86
[   45.440266] device: 'ttyD87': device_add
[   45.444199] PM: Adding info for No Bus:ttyD87
[   45.448671] device: 'ttyD88': device_add
[   45.452619] PM: Adding info for No Bus:ttyD88
[   45.457084] device: 'ttyD89': device_add
[   45.461007] PM: Adding info for No Bus:ttyD89
[   45.465502] device: 'ttyD90': device_add
[   45.469420] PM: Adding info for No Bus:ttyD90
[   45.473917] device: 'ttyD91': device_add
[   45.477839] PM: Adding info for No Bus:ttyD91
[   45.482314] device: 'ttyD92': device_add
[   45.486258] PM: Adding info for No Bus:ttyD92
[   45.490732] device: 'ttyD93': device_add
[   45.494668] PM: Adding info for No Bus:ttyD93
[   45.499760] device: 'ttyD94': device_add
[   45.503707] PM: Adding info for No Bus:ttyD94
[   45.508177] device: 'ttyD95': device_add
[   45.512099] PM: Adding info for No Bus:ttyD95
[   45.516597] device: 'ttyD96': device_add
[   45.520512] PM: Adding info for No Bus:ttyD96
[   45.525001] device: 'ttyD97': device_add
[   45.528923] PM: Adding info for No Bus:ttyD97
[   45.533420] device: 'ttyD98': device_add
[   45.537337] PM: Adding info for No Bus:ttyD98
[   45.541814] device: 'ttyD99': device_add
[   45.545756] PM: Adding info for No Bus:ttyD99
[   45.550296] device: 'ttyD100': device_add
[   45.554321] PM: Adding info for No Bus:ttyD100
[   45.558881] device: 'ttyD101': device_add
[   45.562911] PM: Adding info for No Bus:ttyD101
[   45.567462] device: 'ttyD102': device_add
[   45.571466] PM: Adding info for No Bus:ttyD102
[   45.576051] device: 'ttyD103': device_add
[   45.580060] PM: Adding info for No Bus:ttyD103
[   45.584640] device: 'ttyD104': device_add
[   45.588644] PM: Adding info for No Bus:ttyD104
[   45.593228] device: 'ttyD105': device_add
[   45.597236] PM: Adding info for No Bus:ttyD105
[   45.601794] device: 'ttyD106': device_add
[   45.605826] PM: Adding info for No Bus:ttyD106
[   45.610392] device: 'ttyD107': device_add
[   45.614420] PM: Adding info for No Bus:ttyD107
[   45.618967] device: 'ttyD108': device_add
[   45.622998] PM: Adding info for No Bus:ttyD108
[   45.627556] device: 'ttyD109': device_add
[   45.631562] PM: Adding info for No Bus:ttyD109
[   45.636147] device: 'ttyD110': device_add
[   45.640155] PM: Adding info for No Bus:ttyD110
[   45.644738] device: 'ttyD111': device_add
[   45.648743] PM: Adding info for No Bus:ttyD111
[   45.653328] device: 'ttyD112': device_add
[   45.657344] PM: Adding info for No Bus:ttyD112
[   45.661894] device: 'ttyD113': device_add
[   45.665931] PM: Adding info for No Bus:ttyD113
[   45.670487] device: 'ttyD114': device_add
[   45.674516] PM: Adding info for No Bus:ttyD114
[   45.679071] device: 'ttyD115': device_add
[   45.683110] PM: Adding info for No Bus:ttyD115
[   45.687669] device: 'ttyD116': device_add
[   45.691673] PM: Adding info for No Bus:ttyD116
[   45.696255] device: 'ttyD117': device_add
[   45.700269] PM: Adding info for No Bus:ttyD117
[   45.704857] device: 'ttyD118': device_add
[   45.708867] PM: Adding info for No Bus:ttyD118
[   45.713450] device: 'ttyD119': device_add
[   45.717459] PM: Adding info for No Bus:ttyD119
[   45.722012] device: 'ttyD120': device_add
[   45.726046] PM: Adding info for No Bus:ttyD120
[   45.730597] device: 'ttyD121': device_add
[   45.734624] PM: Adding info for No Bus:ttyD121
[   45.739182] device: 'ttyD122': device_add
[   45.743223] PM: Adding info for No Bus:ttyD122
[   45.747786] device: 'ttyD123': device_add
[   45.751791] PM: Adding info for No Bus:ttyD123
[   45.756366] device: 'ttyD124': device_add
[   45.760371] PM: Adding info for No Bus:ttyD124
[   45.764960] device: 'ttyD125': device_add
[   45.768973] PM: Adding info for No Bus:ttyD125
[   45.773550] device: 'ttyD126': device_add
[   45.777557] PM: Adding info for No Bus:ttyD126
[   45.782107] device: 'ttyD127': device_add
[   45.786144] PM: Adding info for No Bus:ttyD127
[   45.790690] device: 'ttyD128': device_add
[   45.794715] PM: Adding info for No Bus:ttyD128
[   45.799266] device: 'ttyD129': device_add
[   45.803310] PM: Adding info for No Bus:ttyD129
[   45.807870] device: 'ttyD130': device_add
[   45.811881] PM: Adding info for No Bus:ttyD130
[   45.816462] device: 'ttyD131': device_add
[   45.820467] PM: Adding info for No Bus:ttyD131
[   45.825054] device: 'ttyD132': device_add
[   45.829066] PM: Adding info for No Bus:ttyD132
[   45.833645] device: 'ttyD133': device_add
[   45.837655] PM: Adding info for No Bus:ttyD133
[   45.842206] device: 'ttyD134': device_add
[   45.846244] PM: Adding info for No Bus:ttyD134
[   45.850800] device: 'ttyD135': device_add
[   45.854829] PM: Adding info for No Bus:ttyD135
[   45.859382] device: 'ttyD136': device_add
[   45.863416] PM: Adding info for No Bus:ttyD136
[   45.867969] device: 'ttyD137': device_add
[   45.871983] PM: Adding info for No Bus:ttyD137
[   45.876557] device: 'ttyD138': device_add
[   45.880563] PM: Adding info for No Bus:ttyD138
[   45.885150] device: 'ttyD139': device_add
[   45.889169] PM: Adding info for No Bus:ttyD139
[   45.893753] device: 'ttyD140': device_add
[   45.897772] PM: Adding info for No Bus:ttyD140
[   45.902327] device: 'ttyD141': device_add
[   45.906367] PM: Adding info for No Bus:ttyD141
[   45.910917] device: 'ttyD142': device_add
[   45.914948] PM: Adding info for No Bus:ttyD142
[   45.919501] device: 'ttyD143': device_add
[   45.923538] PM: Adding info for No Bus:ttyD143
[   45.928093] device: 'ttyD144': device_add
[   45.932101] PM: Adding info for No Bus:ttyD144
[   45.936687] device: 'ttyD145': device_add
[   45.940692] PM: Adding info for No Bus:ttyD145
[   45.945272] device: 'ttyD146': device_add
[   45.949284] PM: Adding info for No Bus:ttyD146
[   45.953865] device: 'ttyD147': device_add
[   45.957875] PM: Adding info for No Bus:ttyD147
[   45.962442] device: 'ttyD148': device_add
[   45.966479] PM: Adding info for No Bus:ttyD148
[   45.971034] device: 'ttyD149': device_add
[   45.975065] PM: Adding info for No Bus:ttyD149
[   45.979631] device: 'ttyD150': device_add
[   45.983675] PM: Adding info for No Bus:ttyD150
[   45.988226] device: 'ttyD151': device_add
[   45.992245] PM: Adding info for No Bus:ttyD151
[   45.996832] device: 'ttyD152': device_add
[   46.000839] PM: Adding info for No Bus:ttyD152
[   46.005425] device: 'ttyD153': device_add
[   46.009439] PM: Adding info for No Bus:ttyD153
[   46.014029] device: 'ttyD154': device_add
[   46.018038] PM: Adding info for No Bus:ttyD154
[   46.022600] device: 'ttyD155': device_add
[   46.026608] PM: Adding info for No Bus:ttyD155
[   46.031186] device: 'ttyD156': device_add
[   46.035234] PM: Adding info for No Bus:ttyD156
[   46.039795] device: 'ttyD157': device_add
[   46.043888] PM: Adding info for No Bus:ttyD157
[   46.048457] device: 'ttyD158': device_add
[   46.052468] PM: Adding info for No Bus:ttyD158
[   46.057047] device: 'ttyD159': device_add
[   46.061060] PM: Adding info for No Bus:ttyD159
[   46.065664] device: 'ttyD160': device_add
[   46.069677] PM: Adding info for No Bus:ttyD160
[   46.074263] device: 'ttyD161': device_add
[   46.078272] PM: Adding info for No Bus:ttyD161
[   46.082855] device: 'ttyD162': device_add
[   46.086872] PM: Adding info for No Bus:ttyD162
[   46.091443] device: 'ttyD163': device_add
[   46.095479] PM: Adding info for No Bus:ttyD163
[   46.100025] device: 'ttyD164': device_add
[   46.104072] PM: Adding info for No Bus:ttyD164
[   46.108635] device: 'ttyD165': device_add
[   46.112672] PM: Adding info for No Bus:ttyD165
[   46.117223] device: 'ttyD166': device_add
[   46.121241] PM: Adding info for No Bus:ttyD166
[   46.125829] device: 'ttyD167': device_add
[   46.129845] PM: Adding info for No Bus:ttyD167
[   46.134427] device: 'ttyD168': device_add
[   46.138435] PM: Adding info for No Bus:ttyD168
[   46.143013] device: 'ttyD169': device_add
[   46.147026] PM: Adding info for No Bus:ttyD169
[   46.151573] device: 'ttyD170': device_add
[   46.155613] PM: Adding info for No Bus:ttyD170
[   46.160267] device: 'ttyD171': device_add
[   46.164300] PM: Adding info for No Bus:ttyD171
[   46.168864] device: 'ttyD172': device_add
[   46.172904] PM: Adding info for No Bus:ttyD172
[   46.177466] device: 'ttyD173': device_add
[   46.181483] PM: Adding info for No Bus:ttyD173
[   46.186120] device: 'ttyD174': device_add
[   46.190137] PM: Adding info for No Bus:ttyD174
[   46.194771] device: 'ttyD175': device_add
[   46.198790] PM: Adding info for No Bus:ttyD175
[   46.203395] device: 'ttyD176': device_add
[   46.207415] PM: Adding info for No Bus:ttyD176
[   46.211972] device: 'ttyD177': device_add
[   46.216044] PM: Adding info for No Bus:ttyD177
[   46.220609] device: 'ttyD178': device_add
[   46.224643] PM: Adding info for No Bus:ttyD178
[   46.229196] device: 'ttyD179': device_add
[   46.233250] PM: Adding info for No Bus:ttyD179
[   46.237812] device: 'ttyD180': device_add
[   46.241828] PM: Adding info for No Bus:ttyD180
[   46.246421] device: 'ttyD181': device_add
[   46.250439] PM: Adding info for No Bus:ttyD181
[   46.255030] device: 'ttyD182': device_add
[   46.259049] PM: Adding info for No Bus:ttyD182
[   46.263632] device: 'ttyD183': device_add
[   46.267642] PM: Adding info for No Bus:ttyD183
[   46.272854] device: 'ttyD184': device_add
[   46.276873] PM: Adding info for No Bus:ttyD184
[   46.281429] device: 'ttyD185': device_add
[   46.285579] PM: Adding info for No Bus:ttyD185
[   46.290237] device: 'ttyD186': device_add
[   46.294304] PM: Adding info for No Bus:ttyD186
[   46.298870] device: 'ttyD187': device_add
[   46.302929] PM: Adding info for No Bus:ttyD187
[   46.307495] device: 'ttyD188': device_add
[   46.311514] PM: Adding info for No Bus:ttyD188
[   46.316148] device: 'ttyD189': device_add
[   46.320167] PM: Adding info for No Bus:ttyD189
[   46.324806] device: 'ttyD190': device_add
[   46.328821] PM: Adding info for No Bus:ttyD190
[   46.333425] device: 'ttyD191': device_add
[   46.337437] PM: Adding info for No Bus:ttyD191
[   46.341998] device: 'ttyD192': device_add
[   46.346060] PM: Adding info for No Bus:ttyD192
[   46.350617] device: 'ttyD193': device_add
[   46.354652] PM: Adding info for No Bus:ttyD193
[   46.359206] device: 'ttyD194': device_add
[   46.363254] PM: Adding info for No Bus:ttyD194
[   46.367811] device: 'ttyD195': device_add
[   46.371827] PM: Adding info for No Bus:ttyD195
[   46.376417] device: 'ttyD196': device_add
[   46.380434] PM: Adding info for No Bus:ttyD196
[   46.385022] device: 'ttyD197': device_add
[   46.389047] PM: Adding info for No Bus:ttyD197
[   46.393640] device: 'ttyD198': device_add
[   46.397657] PM: Adding info for No Bus:ttyD198
[   46.402213] device: 'ttyD199': device_add
[   46.406253] PM: Adding info for No Bus:ttyD199
[   46.410811] device: 'ttyD200': device_add
[   46.414862] PM: Adding info for No Bus:ttyD200
[   46.419420] device: 'ttyD201': device_add
[   46.423462] PM: Adding info for No Bus:ttyD201
[   46.428016] device: 'ttyD202': device_add
[   46.432038] PM: Adding info for No Bus:ttyD202
[   46.436616] device: 'ttyD203': device_add
[   46.440633] PM: Adding info for No Bus:ttyD203
[   46.445219] device: 'ttyD204': device_add
[   46.449241] PM: Adding info for No Bus:ttyD204
[   46.453821] device: 'ttyD205': device_add
[   46.457842] PM: Adding info for No Bus:ttyD205
[   46.462392] device: 'ttyD206': device_add
[   46.466437] PM: Adding info for No Bus:ttyD206
[   46.470995] device: 'ttyD207': device_add
[   46.475032] PM: Adding info for No Bus:ttyD207
[   46.479586] device: 'ttyD208': device_add
[   46.483631] PM: Adding info for No Bus:ttyD208
[   46.488188] device: 'ttyD209': device_add
[   46.492206] PM: Adding info for No Bus:ttyD209
[   46.496788] device: 'ttyD210': device_add
[   46.500808] PM: Adding info for No Bus:ttyD210
[   46.505392] device: 'ttyD211': device_add
[   46.509408] PM: Adding info for No Bus:ttyD211
[   46.513987] device: 'ttyD212': device_add
[   46.518009] PM: Adding info for No Bus:ttyD212
[   46.522577] device: 'ttyD213': device_add
[   46.526590] PM: Adding info for No Bus:ttyD213
[   46.531164] device: 'ttyD214': device_add
[   46.535216] PM: Adding info for No Bus:ttyD214
[   46.539780] device: 'ttyD215': device_add
[   46.543875] PM: Adding info for No Bus:ttyD215
[   46.548439] device: 'ttyD216': device_add
[   46.552460] PM: Adding info for No Bus:ttyD216
[   46.557041] device: 'ttyD217': device_add
[   46.561064] PM: Adding info for No Bus:ttyD217
[   46.565665] device: 'ttyD218': device_add
[   46.569683] PM: Adding info for No Bus:ttyD218
[   46.574265] device: 'ttyD219': device_add
[   46.578279] PM: Adding info for No Bus:ttyD219
[   46.582874] device: 'ttyD220': device_add
[   46.586894] PM: Adding info for No Bus:ttyD220
[   46.591447] device: 'ttyD221': device_add
[   46.595493] PM: Adding info for No Bus:ttyD221
[   46.600131] device: 'ttyD222': device_add
[   46.604181] PM: Adding info for No Bus:ttyD222
[   46.608742] device: 'ttyD223': device_add
[   46.612784] PM: Adding info for No Bus:ttyD223
[   46.617345] device: 'ttyD224': device_add
[   46.621367] PM: Adding info for No Bus:ttyD224
[   46.625957] device: 'ttyD225': device_add
[   46.629975] PM: Adding info for No Bus:ttyD225
[   46.634604] device: 'ttyD226': device_add
[   46.638620] PM: Adding info for No Bus:ttyD226
[   46.643204] device: 'ttyD227': device_add
[   46.647227] PM: Adding info for No Bus:ttyD227
[   46.651780] device: 'ttyD228': device_add
[   46.655850] PM: Adding info for No Bus:ttyD228
[   46.660407] device: 'ttyD229': device_add
[   46.664444] PM: Adding info for No Bus:ttyD229
[   46.668994] device: 'ttyD230': device_add
[   46.673047] PM: Adding info for No Bus:ttyD230
[   46.677601] device: 'ttyD231': device_add
[   46.681623] PM: Adding info for No Bus:ttyD231
[   46.686219] device: 'ttyD232': device_add
[   46.690238] PM: Adding info for No Bus:ttyD232
[   46.694821] device: 'ttyD233': device_add
[   46.698840] PM: Adding info for No Bus:ttyD233
[   46.703415] device: 'ttyD234': device_add
[   46.707434] PM: Adding info for No Bus:ttyD234
[   46.711996] device: 'ttyD235': device_add
[   46.716041] PM: Adding info for No Bus:ttyD235
[   46.720599] device: 'ttyD236': device_add
[   46.724638] PM: Adding info for No Bus:ttyD236
[   46.729195] device: 'ttyD237': device_add
[   46.733244] PM: Adding info for No Bus:ttyD237
[   46.737801] device: 'ttyD238': device_add
[   46.741820] PM: Adding info for No Bus:ttyD238
[   46.746408] device: 'ttyD239': device_add
[   46.750430] PM: Adding info for No Bus:ttyD239
[   46.755009] device: 'ttyD240': device_add
[   46.759031] PM: Adding info for No Bus:ttyD240
[   46.763616] device: 'ttyD241': device_add
[   46.767637] PM: Adding info for No Bus:ttyD241
[   46.772190] device: 'ttyD242': device_add
[   46.776235] PM: Adding info for No Bus:ttyD242
[   46.780786] device: 'ttyD243': device_add
[   46.784833] PM: Adding info for No Bus:ttyD243
[   46.789389] device: 'ttyD244': device_add
[   46.793433] PM: Adding info for No Bus:ttyD244
[   46.797990] device: 'ttyD245': device_add
[   46.802014] PM: Adding info for No Bus:ttyD245
[   46.806600] device: 'ttyD246': device_add
[   46.810625] PM: Adding info for No Bus:ttyD246
[   46.815210] device: 'ttyD247': device_add
[   46.819232] PM: Adding info for No Bus:ttyD247
[   46.823820] device: 'ttyD248': device_add
[   46.827849] PM: Adding info for No Bus:ttyD248
[   46.832404] device: 'ttyD249': device_add
[   46.836451] PM: Adding info for No Bus:ttyD249
[   46.841004] device: 'ttyD250': device_add
[   46.845048] PM: Adding info for No Bus:ttyD250
[   46.849606] device: 'ttyD251': device_add
[   46.853653] PM: Adding info for No Bus:ttyD251
[   46.858206] device: 'ttyD252': device_add
[   46.862232] PM: Adding info for No Bus:ttyD252
[   46.866813] device: 'ttyD253': device_add
[   46.870831] PM: Adding info for No Bus:ttyD253
[   46.875407] device: 'ttyD254': device_add
[   46.879430] PM: Adding info for No Bus:ttyD254
[   46.884007] device: 'ttyD255': device_add
[   46.888032] PM: Adding info for No Bus:ttyD255
[   46.892619] device: 'digi_ctl0': device_add
[   46.896804] PM: Adding info for No Bus:digi_ctl0
[   46.901548] device: 'digi_ctl1': device_add
[   46.905769] PM: Adding info for No Bus:digi_ctl1
[   46.910502] device: 'digi_ctl2': device_add
[   46.914712] PM: Adding info for No Bus:digi_ctl2
[   46.919439] device: 'digi_ctl3': device_add
[   46.923696] PM: Adding info for No Bus:digi_ctl3
[   46.928432] device: 'digi_ctl4': device_add
[   46.932646] PM: Adding info for No Bus:digi_ctl4
[   46.937372] device: 'digi_ctl5': device_add
[   46.941557] PM: Adding info for No Bus:digi_ctl5
[   46.946339] device: 'digi_ctl6': device_add
[   46.950522] PM: Adding info for No Bus:digi_ctl6
[   46.955275] device: 'digi_ctl7': device_add
[   46.959460] PM: Adding info for No Bus:digi_ctl7
[   46.964226] device: 'digi_ctl8': device_add
[   46.968410] PM: Adding info for No Bus:digi_ctl8
[   46.973159] device: 'digi_ctl9': device_add
[   46.977346] PM: Adding info for No Bus:digi_ctl9
[   46.982075] device: 'digi_ctl10': device_add
[   46.986374] PM: Adding info for No Bus:digi_ctl10
[   46.991192] device: 'digi_ctl11': device_add
[   46.995486] PM: Adding info for No Bus:digi_ctl11
[   47.000302] device: 'digi_ctl12': device_add
[   47.004606] PM: Adding info for No Bus:digi_ctl12
[   47.009419] device: 'digi_ctl13': device_add
[   47.013724] PM: Adding info for No Bus:digi_ctl13
[   47.018536] device: 'digi_ctl14': device_add
[   47.022835] PM: Adding info for No Bus:digi_ctl14
[   47.027652] device: 'digi_ctl15': device_add
[   47.031924] PM: Adding info for No Bus:digi_ctl15
[   47.036777] device: 'digi_ctl16': device_add
[   47.041049] PM: Adding info for No Bus:digi_ctl16
[   47.045900] device: 'digi_ctl17': device_add
[   47.050181] PM: Adding info for No Bus:digi_ctl17
[   47.055652] device: 'digi_ctl18': device_add
[   47.059923] PM: Adding info for No Bus:digi_ctl18
[   47.064759] device: 'digi_ctl19': device_add
[   47.069035] PM: Adding info for No Bus:digi_ctl19
[   47.073876] device: 'digi_ctl20': device_add
[   47.078152] PM: Adding info for No Bus:digi_ctl20
[   47.082995] device: 'digi_ctl21': device_add
[   47.087267] PM: Adding info for No Bus:digi_ctl21
[   47.092079] device: 'digi_ctl22': device_add
[   47.096380] PM: Adding info for No Bus:digi_ctl22
[   47.101201] device: 'digi_ctl23': device_add
[   47.105495] PM: Adding info for No Bus:digi_ctl23
[   47.110304] device: 'digi_ctl24': device_add
[   47.114601] PM: Adding info for No Bus:digi_ctl24
[   47.119414] device: 'digi_ctl25': device_add
[   47.123711] PM: Adding info for No Bus:digi_ctl25
[   47.128527] device: 'digi_ctl26': device_add
[   47.132825] PM: Adding info for No Bus:digi_ctl26
[   47.137645] device: 'digi_ctl27': device_add
[   47.141919] PM: Adding info for No Bus:digi_ctl27
[   47.146771] device: 'digi_ctl28': device_add
[   47.151049] PM: Adding info for No Bus:digi_ctl28
[   47.155893] device: 'digi_ctl29': device_add
[   47.160174] PM: Adding info for No Bus:digi_ctl29
[   47.165019] device: 'digi_ctl30': device_add
[   47.169288] PM: Adding info for No Bus:digi_ctl30
[   47.174124] device: 'digi_ctl31': device_add
[   47.178402] PM: Adding info for No Bus:digi_ctl31
[   47.183242] device: 'digi_ctl32': device_add
[   47.187515] PM: Adding info for No Bus:digi_ctl32
[   47.192329] device: 'digi_ctl33': device_add
[   47.196629] PM: Adding info for No Bus:digi_ctl33
[   47.201446] device: 'digi_ctl34': device_add
[   47.205740] PM: Adding info for No Bus:digi_ctl34
[   47.210563] device: 'digi_ctl35': device_add
[   47.214869] PM: Adding info for No Bus:digi_ctl35
[   47.219683] device: 'digi_ctl36': device_add
[   47.223979] PM: Adding info for No Bus:digi_ctl36
[   47.228791] device: 'digi_ctl37': device_add
[   47.233091] PM: Adding info for No Bus:digi_ctl37
[   47.237917] device: 'digi_ctl38': device_add
[   47.242191] PM: Adding info for No Bus:digi_ctl38
[   47.247046] device: 'digi_ctl39': device_add
[   47.251323] PM: Adding info for No Bus:digi_ctl39
[   47.256165] device: 'digi_ctl40': device_add
[   47.260442] PM: Adding info for No Bus:digi_ctl40
[   47.265285] device: 'digi_ctl41': device_add
[   47.269560] PM: Adding info for No Bus:digi_ctl41
[   47.274398] device: 'digi_ctl42': device_add
[   47.278678] PM: Adding info for No Bus:digi_ctl42
[   47.283518] device: 'digi_ctl43': device_add
[   47.287797] PM: Adding info for No Bus:digi_ctl43
[   47.292622] device: 'digi_ctl44': device_add
[   47.296902] PM: Adding info for No Bus:digi_ctl44
[   47.301740] device: 'digi_ctl45': device_add
[   47.306056] PM: Adding info for No Bus:digi_ctl45
[   47.310885] device: 'digi_ctl46': device_add
[   47.315182] PM: Adding info for No Bus:digi_ctl46
[   47.319998] device: 'digi_ctl47': device_add
[   47.324355] PM: Adding info for No Bus:digi_ctl47
[   47.329178] device: 'digi_ctl48': device_add
[   47.333479] PM: Adding info for No Bus:digi_ctl48
[   47.338301] device: 'digi_ctl49': device_add
[   47.342627] PM: Adding info for No Bus:digi_ctl49
[   47.347441] device: 'digi_ctl50': device_add
[   47.351719] PM: Adding info for No Bus:digi_ctl50
[   47.356560] device: 'digi_ctl51': device_add
[   47.360838] PM: Adding info for No Bus:digi_ctl51
[   47.365686] device: 'digi_ctl52': device_add
[   47.369963] PM: Adding info for No Bus:digi_ctl52
[   47.374807] device: 'digi_ctl53': device_add
[   47.379085] PM: Adding info for No Bus:digi_ctl53
[   47.383935] device: 'digi_ctl54': device_add
[   47.388216] PM: Adding info for No Bus:digi_ctl54
[   47.393061] device: 'digi_ctl55': device_add
[   47.397342] PM: Adding info for No Bus:digi_ctl55
[   47.402160] device: 'digi_ctl56': device_add
[   47.406469] PM: Adding info for No Bus:digi_ctl56
[   47.411285] device: 'digi_ctl57': device_add
[   47.415588] PM: Adding info for No Bus:digi_ctl57
[   47.420400] device: 'digi_ctl58': device_add
[   47.424703] PM: Adding info for No Bus:digi_ctl58
[   47.429513] device: 'digi_ctl59': device_add
[   47.433820] PM: Adding info for No Bus:digi_ctl59
[   47.438631] device: 'digi_ctl60': device_add
[   47.442936] PM: Adding info for No Bus:digi_ctl60
[   47.447747] device: 'digi_ctl61': device_add
[   47.452025] PM: Adding info for No Bus:digi_ctl61
[   47.456877] device: 'digi_ctl62': device_add
[   47.461157] PM: Adding info for No Bus:digi_ctl62
[   47.465998] device: 'digi_ctl63': device_add
[   47.470277] PM: Adding info for No Bus:digi_ctl63
[   47.475113] device: 'digi_ctl64': device_add
[   47.479392] PM: Adding info for No Bus:digi_ctl64
[   47.484235] device: 'digi_ctl65': device_add
[   47.488519] PM: Adding info for No Bus:digi_ctl65
[   47.493364] device: 'digi_ctl66': device_add
[   47.497645] PM: Adding info for No Bus:digi_ctl66
[   47.502455] device: 'digi_ctl67': device_add
[   47.506765] PM: Adding info for No Bus:digi_ctl67
[   47.511587] device: 'digi_ctl68': device_add
[   47.515885] PM: Adding info for No Bus:digi_ctl68
[   47.520692] device: 'digi_ctl69': device_add
[   47.525000] PM: Adding info for No Bus:digi_ctl69
[   47.529821] device: 'digi_ctl70': device_add
[   47.534126] PM: Adding info for No Bus:digi_ctl70
[   47.538937] device: 'digi_ctl71': device_add
[   47.543353] PM: Adding info for No Bus:digi_ctl71
[   47.548175] device: 'digi_ctl72': device_add
[   47.552473] PM: Adding info for No Bus:digi_ctl72
[   47.557323] device: 'digi_ctl73': device_add
[   47.561616] PM: Adding info for No Bus:digi_ctl73
[   47.566469] device: 'digi_ctl74': device_add
[   47.570749] PM: Adding info for No Bus:digi_ctl74
[   47.575593] device: 'digi_ctl75': device_add
[   47.579876] PM: Adding info for No Bus:digi_ctl75
[   47.584715] device: 'digi_ctl76': device_add
[   47.588991] PM: Adding info for No Bus:digi_ctl76
[   47.593829] device: 'digi_ctl77': device_add
[   47.598114] PM: Adding info for No Bus:digi_ctl77
[   47.602967] device: 'digi_ctl78': device_add
[   47.607247] PM: Adding info for No Bus:digi_ctl78
[   47.612055] device: 'digi_ctl79': device_add
[   47.616359] PM: Adding info for No Bus:digi_ctl79
[   47.621172] device: 'digi_ctl80': device_add
[   47.625476] PM: Adding info for No Bus:digi_ctl80
[   47.630290] device: 'digi_ctl81': device_add
[   47.634600] PM: Adding info for No Bus:digi_ctl81
[   47.639422] device: 'digi_ctl82': device_add
[   47.643729] PM: Adding info for No Bus:digi_ctl82
[   47.648540] device: 'digi_ctl83': device_add
[   47.652848] PM: Adding info for No Bus:digi_ctl83
[   47.657676] device: 'digi_ctl84': device_add
[   47.661954] PM: Adding info for No Bus:digi_ctl84
[   47.666799] device: 'digi_ctl85': device_add
[   47.671080] PM: Adding info for No Bus:digi_ctl85
[   47.675928] device: 'digi_ctl86': device_add
[   47.680212] PM: Adding info for No Bus:digi_ctl86
[   47.685056] device: 'digi_ctl87': device_add
[   47.689336] PM: Adding info for No Bus:digi_ctl87
[   47.694177] device: 'digi_ctl88': device_add
[   47.698455] PM: Adding info for No Bus:digi_ctl88
[   47.703295] device: 'digi_ctl89': device_add
[   47.707576] PM: Adding info for No Bus:digi_ctl89
[   47.712394] device: 'digi_ctl90': device_add
[   47.716705] PM: Adding info for No Bus:digi_ctl90
[   47.721525] device: 'digi_ctl91': device_add
[   47.725825] PM: Adding info for No Bus:digi_ctl91
[   47.730645] device: 'digi_ctl92': device_add
[   47.734955] PM: Adding info for No Bus:digi_ctl92
[   47.739764] device: 'digi_ctl93': device_add
[   47.744073] PM: Adding info for No Bus:digi_ctl93
[   47.748881] device: 'digi_ctl94': device_add
[   47.753193] PM: Adding info for No Bus:digi_ctl94
[   47.758015] device: 'digi_ctl95': device_add
[   47.762300] PM: Adding info for No Bus:digi_ctl95
[   47.767147] device: 'digi_ctl96': device_add
[   47.771434] PM: Adding info for No Bus:digi_ctl96
[   47.776281] device: 'digi_ctl97': device_add
[   47.780572] PM: Adding info for No Bus:digi_ctl97
[   47.785415] device: 'digi_ctl98': device_add
[   47.789699] PM: Adding info for No Bus:digi_ctl98
[   47.794536] device: 'digi_ctl99': device_add
[   47.798820] PM: Adding info for No Bus:digi_ctl99
[   47.803668] device: 'digi_ctl100': device_add
[   47.808043] PM: Adding info for No Bus:digi_ctl100
[   47.812979] device: 'digi_ctl101': device_add
[   47.817347] PM: Adding info for No Bus:digi_ctl101
[   47.822246] device: 'digi_ctl102': device_add
[   47.826652] PM: Adding info for No Bus:digi_ctl102
[   47.831559] device: 'digi_ctl103': device_add
[   47.835948] PM: Adding info for No Bus:digi_ctl103
[   47.840846] device: 'digi_ctl104': device_add
[   47.845248] PM: Adding info for No Bus:digi_ctl104
[   47.850323] device: 'digi_ctl105': device_add
[   47.854721] PM: Adding info for No Bus:digi_ctl105
[   47.859630] device: 'digi_ctl106': device_add
[   47.864033] PM: Adding info for No Bus:digi_ctl106
[   47.868943] device: 'digi_ctl107': device_add
[   47.873390] PM: Adding info for No Bus:digi_ctl107
[   47.878926] device: 'digi_ctl108': device_add
[   47.883375] PM: Adding info for No Bus:digi_ctl108
[   47.888288] device: 'digi_ctl109': device_add
[   47.892707] PM: Adding info for No Bus:digi_ctl109
[   47.897609] device: 'digi_ctl110': device_add
[   47.901983] PM: Adding info for No Bus:digi_ctl110
[   47.906935] device: 'digi_ctl111': device_add
[   47.911311] PM: Adding info for No Bus:digi_ctl111
[   47.916253] device: 'digi_ctl112': device_add
[   47.920623] PM: Adding info for No Bus:digi_ctl112
[   47.925557] device: 'digi_ctl113': device_add
[   47.929931] PM: Adding info for No Bus:digi_ctl113
[   47.934865] device: 'digi_ctl114': device_add
[   47.939244] PM: Adding info for No Bus:digi_ctl114
[   47.944164] device: 'digi_ctl115': device_add
[   47.948543] PM: Adding info for No Bus:digi_ctl115
[   47.953473] device: 'digi_ctl116': device_add
[   47.957852] PM: Adding info for No Bus:digi_ctl116
[   47.962786] device: 'digi_ctl117': device_add
[   47.967154] PM: Adding info for No Bus:digi_ctl117
[   47.972060] device: 'digi_ctl118': device_add
[   47.976463] PM: Adding info for No Bus:digi_ctl118
[   47.981366] device: 'digi_ctl119': device_add
[   47.985749] PM: Adding info for No Bus:digi_ctl119
[   47.990656] device: 'digi_ctl120': device_add
[   47.995060] PM: Adding info for No Bus:digi_ctl120
[   47.999961] device: 'digi_ctl121': device_add
[   48.004360] PM: Adding info for No Bus:digi_ctl121
[   48.009260] device: 'digi_ctl122': device_add
[   48.013668] PM: Adding info for No Bus:digi_ctl122
[   48.018569] device: 'digi_ctl123': device_add
[   48.022970] PM: Adding info for No Bus:digi_ctl123
[   48.027875] device: 'digi_ctl124': device_add
[   48.032249] PM: Adding info for No Bus:digi_ctl124
[   48.037185] device: 'digi_ctl125': device_add
[   48.041562] PM: Adding info for No Bus:digi_ctl125
[   48.046494] device: 'digi_ctl126': device_add
[   48.050874] PM: Adding info for No Bus:digi_ctl126
[   48.055799] device: 'digi_ctl127': device_add
[   48.060170] PM: Adding info for No Bus:digi_ctl127
[   48.065102] device: 'digi_ctl128': device_add
[   48.069477] PM: Adding info for No Bus:digi_ctl128
[   48.074401] device: 'digi_ctl129': device_add
[   48.078778] PM: Adding info for No Bus:digi_ctl129
[   48.083704] device: 'digi_ctl130': device_add
[   48.088081] PM: Adding info for No Bus:digi_ctl130
[   48.093014] device: 'digi_ctl131': device_add
[   48.097384] PM: Adding info for No Bus:digi_ctl131
[   48.102279] device: 'digi_ctl132': device_add
[   48.106682] PM: Adding info for No Bus:digi_ctl132
[   48.111582] device: 'digi_ctl133': device_add
[   48.115978] PM: Adding info for No Bus:digi_ctl133
[   48.120881] device: 'digi_ctl134': device_add
[   48.125286] PM: Adding info for No Bus:digi_ctl134
[   48.130310] device: 'digi_ctl135': device_add
[   48.134714] PM: Adding info for No Bus:digi_ctl135
[   48.139617] device: 'digi_ctl136': device_add
[   48.144013] PM: Adding info for No Bus:digi_ctl136
[   48.148916] device: 'digi_ctl137': device_add
[   48.153326] PM: Adding info for No Bus:digi_ctl137
[   48.158229] device: 'digi_ctl138': device_add
[   48.162630] PM: Adding info for No Bus:digi_ctl138
[   48.167534] device: 'digi_ctl139': device_add
[   48.171908] PM: Adding info for No Bus:digi_ctl139
[   48.176836] device: 'digi_ctl140': device_add
[   48.181209] PM: Adding info for No Bus:digi_ctl140
[   48.186139] device: 'digi_ctl141': device_add
[   48.190512] PM: Adding info for No Bus:digi_ctl141
[   48.195441] device: 'digi_ctl142': device_add
[   48.199821] PM: Adding info for No Bus:digi_ctl142
[   48.204752] device: 'digi_ctl143': device_add
[   48.209127] PM: Adding info for No Bus:digi_ctl143
[   48.214050] device: 'digi_ctl144': device_add
[   48.218429] PM: Adding info for No Bus:digi_ctl144
[   48.223364] device: 'digi_ctl145': device_add
[   48.227741] PM: Adding info for No Bus:digi_ctl145
[   48.232674] device: 'digi_ctl146': device_add
[   48.237058] PM: Adding info for No Bus:digi_ctl146
[   48.241972] device: 'digi_ctl147': device_add
[   48.246380] PM: Adding info for No Bus:digi_ctl147
[   48.251286] device: 'digi_ctl148': device_add
[   48.255692] PM: Adding info for No Bus:digi_ctl148
[   48.260600] device: 'digi_ctl149': device_add
[   48.265089] PM: Adding info for No Bus:digi_ctl149
[   48.269995] device: 'digi_ctl150': device_add
[   48.274408] PM: Adding info for No Bus:digi_ctl150
[   48.279308] device: 'digi_ctl151': device_add
[   48.283711] PM: Adding info for No Bus:digi_ctl151
[   48.288615] device: 'digi_ctl152': device_add
[   48.293064] PM: Adding info for No Bus:digi_ctl152
[   48.297964] device: 'digi_ctl153': device_add
[   48.302338] PM: Adding info for No Bus:digi_ctl153
[   48.307277] device: 'digi_ctl154': device_add
[   48.311661] PM: Adding info for No Bus:digi_ctl154
[   48.316607] device: 'digi_ctl155': device_add
[   48.320986] PM: Adding info for No Bus:digi_ctl155
[   48.325910] device: 'digi_ctl156': device_add
[   48.330290] PM: Adding info for No Bus:digi_ctl156
[   48.335224] device: 'digi_ctl157': device_add
[   48.339595] PM: Adding info for No Bus:digi_ctl157
[   48.344521] device: 'digi_ctl158': device_add
[   48.348900] PM: Adding info for No Bus:digi_ctl158
[   48.353834] device: 'digi_ctl159': device_add
[   48.358215] PM: Adding info for No Bus:digi_ctl159
[   48.363145] device: 'digi_ctl160': device_add
[   48.367522] PM: Adding info for No Bus:digi_ctl160
[   48.372427] device: 'digi_ctl161': device_add
[   48.376833] PM: Adding info for No Bus:digi_ctl161
[   48.381729] device: 'digi_ctl162': device_add
[   48.386135] PM: Adding info for No Bus:digi_ctl162
[   48.391042] device: 'digi_ctl163': device_add
[   48.395448] PM: Adding info for No Bus:digi_ctl163
[   48.400349] device: 'digi_ctl164': device_add
[   48.404751] PM: Adding info for No Bus:digi_ctl164
[   48.409660] device: 'digi_ctl165': device_add
[   48.414062] PM: Adding info for No Bus:digi_ctl165
[   48.418963] device: 'digi_ctl166': device_add
[   48.423367] PM: Adding info for No Bus:digi_ctl166
[   48.428269] device: 'digi_ctl167': device_add
[   48.432679] PM: Adding info for No Bus:digi_ctl167
[   48.437583] device: 'digi_ctl168': device_add
[   48.441960] PM: Adding info for No Bus:digi_ctl168
[   48.446899] device: 'digi_ctl169': device_add
[   48.451279] PM: Adding info for No Bus:digi_ctl169
[   48.456209] device: 'digi_ctl170': device_add
[   48.460585] PM: Adding info for No Bus:digi_ctl170
[   48.465512] device: 'digi_ctl171': device_add
[   48.469889] PM: Adding info for No Bus:digi_ctl171
[   48.474826] device: 'digi_ctl172': device_add
[   48.479205] PM: Adding info for No Bus:digi_ctl172
[   48.484134] device: 'digi_ctl173': device_add
[   48.488513] PM: Adding info for No Bus:digi_ctl173
[   48.493441] device: 'digi_ctl174': device_add
[   48.497821] PM: Adding info for No Bus:digi_ctl174
[   48.502755] device: 'digi_ctl175': device_add
[   48.507145] PM: Adding info for No Bus:digi_ctl175
[   48.512043] device: 'digi_ctl176': device_add
[   48.516451] PM: Adding info for No Bus:digi_ctl176
[   48.521355] device: 'digi_ctl177': device_add
[   48.525755] PM: Adding info for No Bus:digi_ctl177
[   48.530654] device: 'digi_ctl178': device_add
[   48.535061] PM: Adding info for No Bus:digi_ctl178
[   48.539971] device: 'digi_ctl179': device_add
[   48.544376] PM: Adding info for No Bus:digi_ctl179
[   48.549283] device: 'digi_ctl180': device_add
[   48.553685] PM: Adding info for No Bus:digi_ctl180
[   48.558590] device: 'digi_ctl181': device_add
[   48.562996] PM: Adding info for No Bus:digi_ctl181
[   48.567903] device: 'digi_ctl182': device_add
[   48.572284] PM: Adding info for No Bus:digi_ctl182
[   48.577218] device: 'digi_ctl183': device_add
[   48.581599] PM: Adding info for No Bus:digi_ctl183
[   48.586523] device: 'digi_ctl184': device_add
[   48.590906] PM: Adding info for No Bus:digi_ctl184
[   48.595833] device: 'digi_ctl185': device_add
[   48.600211] PM: Adding info for No Bus:digi_ctl185
[   48.605143] device: 'digi_ctl186': device_add
[   48.609523] PM: Adding info for No Bus:digi_ctl186
[   48.614448] device: 'digi_ctl187': device_add
[   48.618834] PM: Adding info for No Bus:digi_ctl187
[   48.623756] device: 'digi_ctl188': device_add
[   48.628135] PM: Adding info for No Bus:digi_ctl188
[   48.633067] device: 'digi_ctl189': device_add
[   48.637446] PM: Adding info for No Bus:digi_ctl189
[   48.642344] device: 'digi_ctl190': device_add
[   48.646757] PM: Adding info for No Bus:digi_ctl190
[   48.651658] device: 'digi_ctl191': device_add
[   48.656061] PM: Adding info for No Bus:digi_ctl191
[   48.660965] device: 'digi_ctl192': device_add
[   48.665379] PM: Adding info for No Bus:digi_ctl192
[   48.670316] device: 'digi_ctl193': device_add
[   48.674727] PM: Adding info for No Bus:digi_ctl193
[   48.679627] device: 'digi_ctl194': device_add
[   48.684036] PM: Adding info for No Bus:digi_ctl194
[   48.688938] device: 'digi_ctl195': device_add
[   48.693342] PM: Adding info for No Bus:digi_ctl195
[   48.698246] device: 'digi_ctl196': device_add
[   48.702659] PM: Adding info for No Bus:digi_ctl196
[   48.707560] device: 'digi_ctl197': device_add
[   48.711944] PM: Adding info for No Bus:digi_ctl197
[   48.717509] device: 'digi_ctl198': device_add
[   48.721887] PM: Adding info for No Bus:digi_ctl198
[   48.726816] device: 'digi_ctl199': device_add
[   48.731201] PM: Adding info for No Bus:digi_ctl199
[   48.736130] device: 'digi_ctl200': device_add
[   48.740512] PM: Adding info for No Bus:digi_ctl200
[   48.745445] device: 'digi_ctl201': device_add
[   48.749828] PM: Adding info for No Bus:digi_ctl201
[   48.754757] device: 'digi_ctl202': device_add
[   48.759135] PM: Adding info for No Bus:digi_ctl202
[   48.764065] device: 'digi_ctl203': device_add
[   48.768447] PM: Adding info for No Bus:digi_ctl203
[   48.773370] device: 'digi_ctl204': device_add
[   48.777752] PM: Adding info for No Bus:digi_ctl204
[   48.782690] device: 'digi_ctl205': device_add
[   48.787081] PM: Adding info for No Bus:digi_ctl205
[   48.791994] device: 'digi_ctl206': device_add
[   48.796416] PM: Adding info for No Bus:digi_ctl206
[   48.801326] device: 'digi_ctl207': device_add
[   48.805738] PM: Adding info for No Bus:digi_ctl207
[   48.810649] device: 'digi_ctl208': device_add
[   48.815157] PM: Adding info for No Bus:digi_ctl208
[   48.820146] device: 'digi_ctl209': device_add
[   48.824562] PM: Adding info for No Bus:digi_ctl209
[   48.829470] device: 'digi_ctl210': device_add
[   48.833878] PM: Adding info for No Bus:digi_ctl210
[   48.838785] device: 'digi_ctl211': device_add
[   48.843246] PM: Adding info for No Bus:digi_ctl211
[   48.848153] device: 'digi_ctl212': device_add
[   48.852658] PM: Adding info for No Bus:digi_ctl212
[   48.857562] device: 'digi_ctl213': device_add
[   48.861969] PM: Adding info for No Bus:digi_ctl213
[   48.866932] device: 'digi_ctl214': device_add
[   48.871332] PM: Adding info for No Bus:digi_ctl214
[   48.876274] device: 'digi_ctl215': device_add
[   48.880660] PM: Adding info for No Bus:digi_ctl215
[   48.885600] device: 'digi_ctl216': device_add
[   48.889981] PM: Adding info for No Bus:digi_ctl216
[   48.894910] device: 'digi_ctl217': device_add
[   48.899295] PM: Adding info for No Bus:digi_ctl217
[   48.904225] device: 'digi_ctl218': device_add
[   48.908605] PM: Adding info for No Bus:digi_ctl218
[   48.913528] device: 'digi_ctl219': device_add
[   48.917915] PM: Adding info for No Bus:digi_ctl219
[   48.922841] device: 'digi_ctl220': device_add
[   48.927230] PM: Adding info for No Bus:digi_ctl220
[   48.932133] device: 'digi_ctl221': device_add
[   48.936542] PM: Adding info for No Bus:digi_ctl221
[   48.941443] device: 'digi_ctl222': device_add
[   48.945846] PM: Adding info for No Bus:digi_ctl222
[   48.950754] device: 'digi_ctl223': device_add
[   48.955185] PM: Adding info for No Bus:digi_ctl223
[   48.960227] device: 'digi_ctl224': device_add
[   48.964637] PM: Adding info for No Bus:digi_ctl224
[   48.969540] device: 'digi_ctl225': device_add
[   48.973950] PM: Adding info for No Bus:digi_ctl225
[   48.978860] device: 'digi_ctl226': device_add
[   48.983269] PM: Adding info for No Bus:digi_ctl226
[   48.988173] device: 'digi_ctl227': device_add
[   48.992585] PM: Adding info for No Bus:digi_ctl227
[   48.997491] device: 'digi_ctl228': device_add
[   49.001875] PM: Adding info for No Bus:digi_ctl228
[   49.006807] device: 'digi_ctl229': device_add
[   49.011193] PM: Adding info for No Bus:digi_ctl229
[   49.016128] device: 'digi_ctl230': device_add
[   49.020515] PM: Adding info for No Bus:digi_ctl230
[   49.025453] device: 'digi_ctl231': device_add
[   49.029836] PM: Adding info for No Bus:digi_ctl231
[   49.034765] device: 'digi_ctl232': device_add
[   49.039142] PM: Adding info for No Bus:digi_ctl232
[   49.044073] device: 'digi_ctl233': device_add
[   49.048464] PM: Adding info for No Bus:digi_ctl233
[   49.053398] device: 'digi_ctl234': device_add
[   49.057779] PM: Adding info for No Bus:digi_ctl234
[   49.062710] device: 'digi_ctl235': device_add
[   49.067098] PM: Adding info for No Bus:digi_ctl235
[   49.072003] device: 'digi_ctl236': device_add
[   49.076422] PM: Adding info for No Bus:digi_ctl236
[   49.081323] device: 'digi_ctl237': device_add
[   49.085729] PM: Adding info for No Bus:digi_ctl237
[   49.090637] device: 'digi_ctl238': device_add
[   49.095055] PM: Adding info for No Bus:digi_ctl238
[   49.099957] device: 'digi_ctl239': device_add
[   49.104369] PM: Adding info for No Bus:digi_ctl239
[   49.109275] device: 'digi_ctl240': device_add
[   49.113688] PM: Adding info for No Bus:digi_ctl240
[   49.118593] device: 'digi_ctl241': device_add
[   49.123008] PM: Adding info for No Bus:digi_ctl241
[   49.127912] device: 'digi_ctl242': device_add
[   49.132296] PM: Adding info for No Bus:digi_ctl242
[   49.137233] device: 'digi_ctl243': device_add
[   49.141627] PM: Adding info for No Bus:digi_ctl243
[   49.146559] device: 'digi_ctl244': device_add
[   49.150949] PM: Adding info for No Bus:digi_ctl244
[   49.155881] device: 'digi_ctl245': device_add
[   49.160266] PM: Adding info for No Bus:digi_ctl245
[   49.165201] device: 'digi_ctl246': device_add
[   49.169594] PM: Adding info for No Bus:digi_ctl246
[   49.174521] device: 'digi_ctl247': device_add
[   49.178912] PM: Adding info for No Bus:digi_ctl247
[   49.183839] device: 'digi_ctl248': device_add
[   49.188229] PM: Adding info for No Bus:digi_ctl248
[   49.193158] device: 'digi_ctl249': device_add
[   49.197544] PM: Adding info for No Bus:digi_ctl249
[   49.202445] device: 'digi_ctl250': device_add
[   49.206862] PM: Adding info for No Bus:digi_ctl250
[   49.211773] device: 'digi_ctl251': device_add
[   49.216182] PM: Adding info for No Bus:digi_ctl251
[   49.221082] device: 'digi_ctl252': device_add
[   49.225502] PM: Adding info for No Bus:digi_ctl252
[   49.230405] device: 'digi_ctl253': device_add
[   49.234814] PM: Adding info for No Bus:digi_ctl253
[   49.239721] device: 'digi_ctl254': device_add
[   49.244135] PM: Adding info for No Bus:digi_ctl254
[   49.249037] device: 'digi_ctl255': device_add
[   49.253447] PM: Adding info for No Bus:digi_ctl255
[   49.258347] initcall epca_module_init+0x0/0xa returned 0 after 44513=
07 usecs
[   49.265308] calling  moxa_init+0x0/0xf1 @ 1
[   49.269440] MOXA Intellio family driver version 6.0k
[   49.274432] device: 'ttyMX0': device_add
[   49.278427] PM: Adding info for No Bus:ttyMX0
[   49.282918] device: 'ttyMX1': device_add
[   49.286868] PM: Adding info for No Bus:ttyMX1
[   49.291339] device: 'ttyMX2': device_add
[   49.295391] PM: Adding info for No Bus:ttyMX2
[   49.299854] device: 'ttyMX3': device_add
[   49.303843] PM: Adding info for No Bus:ttyMX3
[   49.308318] device: 'ttyMX4': device_add
[   49.312267] PM: Adding info for No Bus:ttyMX4
[   49.316769] device: 'ttyMX5': device_add
[   49.320718] PM: Adding info for No Bus:ttyMX5
[   49.325220] device: 'ttyMX6': device_add
[   49.329171] PM: Adding info for No Bus:ttyMX6
[   49.333662] device: 'ttyMX7': device_add
[   49.337613] PM: Adding info for No Bus:ttyMX7
[   49.342082] device: 'ttyMX8': device_add
[   49.346056] PM: Adding info for No Bus:ttyMX8
[   49.350524] device: 'ttyMX9': device_add
[   49.354491] PM: Adding info for No Bus:ttyMX9
[   49.358961] device: 'ttyMX10': device_add
[   49.363031] PM: Adding info for No Bus:ttyMX10
[   49.367589] device: 'ttyMX11': device_add
[   49.371624] PM: Adding info for No Bus:ttyMX11
[   49.376215] device: 'ttyMX12': device_add
[   49.380253] PM: Adding info for No Bus:ttyMX12
[   49.384837] device: 'ttyMX13': device_add
[   49.388876] PM: Adding info for No Bus:ttyMX13
[   49.393457] device: 'ttyMX14': device_add
[   49.397495] PM: Adding info for No Bus:ttyMX14
[   49.402057] device: 'ttyMX15': device_add
[   49.406121] PM: Adding info for No Bus:ttyMX15
[   49.410682] device: 'ttyMX16': device_add
[   49.414744] PM: Adding info for No Bus:ttyMX16
[   49.419304] device: 'ttyMX17': device_add
[   49.423373] PM: Adding info for No Bus:ttyMX17
[   49.427923] device: 'ttyMX18': device_add
[   49.431972] PM: Adding info for No Bus:ttyMX18
[   49.436555] device: 'ttyMX19': device_add
[   49.440594] PM: Adding info for No Bus:ttyMX19
[   49.445184] device: 'ttyMX20': device_add
[   49.449228] PM: Adding info for No Bus:ttyMX20
[   49.453817] device: 'ttyMX21': device_add
[   49.457859] PM: Adding info for No Bus:ttyMX21
[   49.462421] device: 'ttyMX22': device_add
[   49.466490] PM: Adding info for No Bus:ttyMX22
[   49.471041] device: 'ttyMX23': device_add
[   49.475102] PM: Adding info for No Bus:ttyMX23
[   49.479661] device: 'ttyMX24': device_add
[   49.483725] PM: Adding info for No Bus:ttyMX24
[   49.488284] device: 'ttyMX25': device_add
[   49.492324] PM: Adding info for No Bus:ttyMX25
[   49.496918] device: 'ttyMX26': device_add
[   49.500956] PM: Adding info for No Bus:ttyMX26
[   49.505536] device: 'ttyMX27': device_add
[   49.509583] PM: Adding info for No Bus:ttyMX27
[   49.514173] device: 'ttyMX28': device_add
[   49.518218] PM: Adding info for No Bus:ttyMX28
[   49.522798] device: 'ttyMX29': device_add
[   49.526834] PM: Adding info for No Bus:ttyMX29
[   49.531385] device: 'ttyMX30': device_add
[   49.536089] PM: Adding info for No Bus:ttyMX30
[   49.540650] device: 'ttyMX31': device_add
[   49.544710] PM: Adding info for No Bus:ttyMX31
[   49.549274] device: 'ttyMX32': device_add
[   49.553347] PM: Adding info for No Bus:ttyMX32
[   49.557900] device: 'ttyMX33': device_add
[   49.561944] PM: Adding info for No Bus:ttyMX33
[   49.566532] device: 'ttyMX34': device_add
[   49.570569] PM: Adding info for No Bus:ttyMX34
[   49.575164] device: 'ttyMX35': device_add
[   49.579204] PM: Adding info for No Bus:ttyMX35
[   49.583791] device: 'ttyMX36': device_add
[   49.587834] PM: Adding info for No Bus:ttyMX36
[   49.592396] device: 'ttyMX37': device_add
[   49.596458] PM: Adding info for No Bus:ttyMX37
[   49.601015] device: 'ttyMX38': device_add
[   49.605078] PM: Adding info for No Bus:ttyMX38
[   49.609639] device: 'ttyMX39': device_add
[   49.613715] PM: Adding info for No Bus:ttyMX39
[   49.618281] device: 'ttyMX40': device_add
[   49.622328] PM: Adding info for No Bus:ttyMX40
[   49.626908] device: 'ttyMX41': device_add
[   49.630951] PM: Adding info for No Bus:ttyMX41
[   49.635545] device: 'ttyMX42': device_add
[   49.639585] PM: Adding info for No Bus:ttyMX42
[   49.644175] device: 'ttyMX43': device_add
[   49.648219] PM: Adding info for No Bus:ttyMX43
[   49.652800] device: 'ttyMX44': device_add
[   49.656839] PM: Adding info for No Bus:ttyMX44
[   49.661394] device: 'ttyMX45': device_add
[   49.665467] PM: Adding info for No Bus:ttyMX45
[   49.670028] device: 'ttyMX46': device_add
[   49.674104] PM: Adding info for No Bus:ttyMX46
[   49.678695] device: 'ttyMX47': device_add
[   49.682778] PM: Adding info for No Bus:ttyMX47
[   49.687342] device: 'ttyMX48': device_add
[   49.691384] PM: Adding info for No Bus:ttyMX48
[   49.695972] device: 'ttyMX49': device_add
[   49.700024] PM: Adding info for No Bus:ttyMX49
[   49.704677] device: 'ttyMX50': device_add
[   49.708721] PM: Adding info for No Bus:ttyMX50
[   49.713308] device: 'ttyMX51': device_add
[   49.717355] PM: Adding info for No Bus:ttyMX51
[   49.721910] device: 'ttyMX52': device_add
[   49.726010] PM: Adding info for No Bus:ttyMX52
[   49.730576] device: 'ttyMX53': device_add
[   49.734650] PM: Adding info for No Bus:ttyMX53
[   49.739202] device: 'ttyMX54': device_add
[   49.743273] PM: Adding info for No Bus:ttyMX54
[   49.747830] device: 'ttyMX55': device_add
[   49.751878] PM: Adding info for No Bus:ttyMX55
[   49.756476] device: 'ttyMX56': device_add
[   49.760522] PM: Adding info for No Bus:ttyMX56
[   49.765111] device: 'ttyMX57': device_add
[   49.769156] PM: Adding info for No Bus:ttyMX57
[   49.773746] device: 'ttyMX58': device_add
[   49.777789] PM: Adding info for No Bus:ttyMX58
[   49.782345] device: 'ttyMX59': device_add
[   49.786412] PM: Adding info for No Bus:ttyMX59
[   49.790970] device: 'ttyMX60': device_add
[   49.795033] PM: Adding info for No Bus:ttyMX60
[   49.799598] device: 'ttyMX61': device_add
[   49.803673] PM: Adding info for No Bus:ttyMX61
[   49.808239] device: 'ttyMX62': device_add
[   49.812285] PM: Adding info for No Bus:ttyMX62
[   49.816873] device: 'ttyMX63': device_add
[   49.820922] PM: Adding info for No Bus:ttyMX63
[   49.825507] device: 'ttyMX64': device_add
[   49.829560] PM: Adding info for No Bus:ttyMX64
[   49.834145] device: 'ttyMX65': device_add
[   49.838185] PM: Adding info for No Bus:ttyMX65
[   49.842769] device: 'ttyMX66': device_add
[   49.846814] PM: Adding info for No Bus:ttyMX66
[   49.851369] device: 'ttyMX67': device_add
[   49.855448] PM: Adding info for No Bus:ttyMX67
[   49.860011] device: 'ttyMX68': device_add
[   49.864086] PM: Adding info for No Bus:ttyMX68
[   49.868649] device: 'ttyMX69': device_add
[   49.872714] PM: Adding info for No Bus:ttyMX69
[   49.877276] device: 'ttyMX70': device_add
[   49.881313] PM: Adding info for No Bus:ttyMX70
[   49.885905] device: 'ttyMX71': device_add
[   49.889954] PM: Adding info for No Bus:ttyMX71
[   49.894552] device: 'ttyMX72': device_add
[   49.898607] PM: Adding info for No Bus:ttyMX72
[   49.903195] device: 'ttyMX73': device_add
[   49.907248] PM: Adding info for No Bus:ttyMX73
[   49.911808] device: 'ttyMX74': device_add
[   49.915878] PM: Adding info for No Bus:ttyMX74
[   49.920436] device: 'ttyMX75': device_add
[   49.924500] PM: Adding info for No Bus:ttyMX75
[   49.929054] device: 'ttyMX76': device_add
[   49.933137] PM: Adding info for No Bus:ttyMX76
[   49.937695] device: 'ttyMX77': device_add
[   49.941742] PM: Adding info for No Bus:ttyMX77
[   49.946331] device: 'ttyMX78': device_add
[   49.950376] PM: Adding info for No Bus:ttyMX78
[   49.954966] device: 'ttyMX79': device_add
[   49.959012] PM: Adding info for No Bus:ttyMX79
[   49.963597] device: 'ttyMX80': device_add
[   49.967643] PM: Adding info for No Bus:ttyMX80
[   49.972200] device: 'ttyMX81': device_add
[   49.976270] PM: Adding info for No Bus:ttyMX81
[   49.980825] device: 'ttyMX82': device_add
[   49.984896] PM: Adding info for No Bus:ttyMX82
[   49.989463] device: 'ttyMX83': device_add
[   49.993543] PM: Adding info for No Bus:ttyMX83
[   49.998097] device: 'ttyMX84': device_add
[   50.002144] PM: Adding info for No Bus:ttyMX84
[   50.006731] device: 'ttyMX85': device_add
[   50.010777] PM: Adding info for No Bus:ttyMX85
[   50.015370] device: 'ttyMX86': device_add
[   50.019425] PM: Adding info for No Bus:ttyMX86
[   50.024010] device: 'ttyMX87': device_add
[   50.028061] PM: Adding info for No Bus:ttyMX87
[   50.032633] device: 'ttyMX88': device_add
[   50.036682] PM: Adding info for No Bus:ttyMX88
[   50.041259] device: 'ttyMX89': device_add
[   50.045360] PM: Adding info for No Bus:ttyMX89
[   50.049923] device: 'ttyMX90': device_add
[   50.054053] PM: Adding info for No Bus:ttyMX90
[   50.058614] device: 'ttyMX91': device_add
[   50.062693] PM: Adding info for No Bus:ttyMX91
[   50.067255] device: 'ttyMX92': device_add
[   50.071303] PM: Adding info for No Bus:ttyMX92
[   50.075902] device: 'ttyMX93': device_add
[   50.079951] PM: Adding info for No Bus:ttyMX93
[   50.084536] device: 'ttyMX94': device_add
[   50.088579] PM: Adding info for No Bus:ttyMX94
[   50.093172] device: 'ttyMX95': device_add
[   50.097225] PM: Adding info for No Bus:ttyMX95
[   50.101791] device: 'ttyMX96': device_add
[   50.105865] PM: Adding info for No Bus:ttyMX96
[   50.110413] device: 'ttyMX97': device_add
[   50.114487] PM: Adding info for No Bus:ttyMX97
[   50.119042] device: 'ttyMX98': device_add
[   50.123218] PM: Adding info for No Bus:ttyMX98
[   50.127784] device: 'ttyMX99': device_add
[   50.131860] PM: Adding info for No Bus:ttyMX99
[   50.136451] device: 'ttyMX100': device_add
[   50.140609] PM: Adding info for No Bus:ttyMX100
[   50.145296] device: 'ttyMX101': device_add
[   50.149435] PM: Adding info for No Bus:ttyMX101
[   50.154112] device: 'ttyMX102': device_add
[   50.158245] PM: Adding info for No Bus:ttyMX102
[   50.162927] device: 'ttyMX103': device_add
[   50.167058] PM: Adding info for No Bus:ttyMX103
[   50.171696] device: 'ttyMX104': device_add
[   50.175863] PM: Adding info for No Bus:ttyMX104
[   50.180509] device: 'ttyMX105': device_add
[   50.184657] PM: Adding info for No Bus:ttyMX105
[   50.189310] device: 'ttyMX106': device_add
[   50.193476] PM: Adding info for No Bus:ttyMX106
[   50.198115] device: 'ttyMX107': device_add
[   50.202253] PM: Adding info for No Bus:ttyMX107
[   50.206925] device: 'ttyMX108': device_add
[   50.211061] PM: Adding info for No Bus:ttyMX108
[   50.215742] device: 'ttyMX109': device_add
[   50.219875] PM: Adding info for No Bus:ttyMX109
[   50.224552] device: 'ttyMX110': device_add
[   50.228691] PM: Adding info for No Bus:ttyMX110
[   50.233368] device: 'ttyMX111': device_add
[   50.237506] PM: Adding info for No Bus:ttyMX111
[   50.242151] device: 'ttyMX112': device_add
[   50.246321] PM: Adding info for No Bus:ttyMX112
[   50.250969] device: 'ttyMX113': device_add
[   50.255133] PM: Adding info for No Bus:ttyMX113
[   50.259776] device: 'ttyMX114': device_add
[   50.263945] PM: Adding info for No Bus:ttyMX114
[   50.268590] device: 'ttyMX115': device_add
[   50.272757] PM: Adding info for No Bus:ttyMX115
[   50.277401] device: 'ttyMX116': device_add
[   50.281542] PM: Adding info for No Bus:ttyMX116
[   50.286222] device: 'ttyMX117': device_add
[   50.290368] PM: Adding info for No Bus:ttyMX117
[   50.295038] device: 'ttyMX118': device_add
[   50.299181] PM: Adding info for No Bus:ttyMX118
[   50.303848] device: 'ttyMX119': device_add
[   50.307984] PM: Adding info for No Bus:ttyMX119
[   50.312635] device: 'ttyMX120': device_add
[   50.317404] PM: Adding info for No Bus:ttyMX120
[   50.322077] device: 'ttyMX121': device_add
[   50.326257] PM: Adding info for No Bus:ttyMX121
[   50.330913] device: 'ttyMX122': device_add
[   50.335078] PM: Adding info for No Bus:ttyMX122
[   50.339721] device: 'ttyMX123': device_add
[   50.343943] PM: Adding info for No Bus:ttyMX123
[   50.348600] device: 'ttyMX124': device_add
[   50.352765] PM: Adding info for No Bus:ttyMX124
[   50.357422] device: 'ttyMX125': device_add
[   50.361566] PM: Adding info for No Bus:ttyMX125
[   50.366274] device: 'ttyMX126': device_add
[   50.370416] PM: Adding info for No Bus:ttyMX126
[   50.375085] device: 'ttyMX127': device_add
[   50.379230] PM: Adding info for No Bus:ttyMX127
[   50.383913] device: 'ttyMX128': device_add
[   50.388047] PM: Adding info for No Bus:ttyMX128
[   50.392707] bus: 'pci': add driver moxa
[   50.396718] initcall moxa_init+0x0/0xf1 returned 0 after 1100852 use=
cs
[   50.403160] calling  mxser_module_init+0x0/0x1a5 @ 1
[   50.408076] MOXA Smartio/Industio family driver version 2.0.4
[   50.413826] bus: 'pci': add driver mxser
[   50.417977] initcall mxser_module_init+0x0/0x1a5 returned 0 after 96=
69 usecs
[   50.424929] calling  ip2_loadmain+0x0/0x8c2 @ 1
[   50.429411] Computone IntelliPort Plus multiport driver version 1.2.=
14
[   50.435990] device class 'ip2': registering
[   50.440333] initcall ip2_loadmain+0x0/0x8c2 returned 0 after 10665 u=
secs
[   50.446938] calling  isicom_init+0x0/0x1ad @ 1
[   50.451396] bus: 'pci': add driver isicom
[   50.455619] initcall isicom_init+0x0/0x1ad returned 0 after 4175 use=
cs
[   50.462021] calling  synclink_init+0x0/0x134 @ 1
[   50.466698] SyncLink serial driver $Revision: 4.38 $
[   50.471558] bus: 'pci': add driver synclink
[   50.476047] device: 'ttySL0': device_add
[   50.480081] PM: Adding info for No Bus:ttySL0
[   50.484591] device: 'ttySL1': device_add
[   50.488564] PM: Adding info for No Bus:ttySL1
[   50.493069] device: 'ttySL2': device_add
[   50.497038] PM: Adding info for No Bus:ttySL2
[   50.501514] device: 'ttySL3': device_add
[   50.505504] PM: Adding info for No Bus:ttySL3
[   50.509974] device: 'ttySL4': device_add
[   50.513970] PM: Adding info for No Bus:ttySL4
[   50.518447] device: 'ttySL5': device_add
[   50.522416] PM: Adding info for No Bus:ttySL5
[   50.526920] device: 'ttySL6': device_add
[   50.530887] PM: Adding info for No Bus:ttySL6
[   50.535388] device: 'ttySL7': device_add
[   50.539355] PM: Adding info for No Bus:ttySL7
[   50.543855] device: 'ttySL8': device_add
[   50.547824] PM: Adding info for No Bus:ttySL8
[   50.552297] device: 'ttySL9': device_add
[   50.556299] PM: Adding info for No Bus:ttySL9
[   50.560773] device: 'ttySL10': device_add
[   50.564844] PM: Adding info for No Bus:ttySL10
[   50.569403] device: 'ttySL11': device_add
[   50.573490] PM: Adding info for No Bus:ttySL11
[   50.578050] device: 'ttySL12': device_add
[   50.582103] PM: Adding info for No Bus:ttySL12
[   50.586688] device: 'ttySL13': device_add
[   50.590740] PM: Adding info for No Bus:ttySL13
[   50.595331] device: 'ttySL14': device_add
[   50.599382] PM: Adding info for No Bus:ttySL14
[   50.603973] device: 'ttySL15': device_add
[   50.608033] PM: Adding info for No Bus:ttySL15
[   50.612591] device: 'ttySL16': device_add
[   50.616643] PM: Adding info for No Bus:ttySL16
[   50.621233] device: 'ttySL17': device_add
[   50.625351] PM: Adding info for No Bus:ttySL17
[   50.629922] device: 'ttySL18': device_add
[   50.634066] PM: Adding info for No Bus:ttySL18
[   50.638627] device: 'ttySL19': device_add
[   50.642716] PM: Adding info for No Bus:ttySL19
[   50.647279] device: 'ttySL20': device_add
[   50.651336] PM: Adding info for No Bus:ttySL20
[   50.655950] device: 'ttySL21': device_add
[   50.660011] PM: Adding info for No Bus:ttySL21
[   50.664601] device: 'ttySL22': device_add
[   50.668658] PM: Adding info for No Bus:ttySL22
[   50.673259] device: 'ttySL23': device_add
[   50.677320] PM: Adding info for No Bus:ttySL23
[   50.681883] device: 'ttySL24': device_add
[   50.685975] PM: Adding info for No Bus:ttySL24
[   50.690542] device: 'ttySL25': device_add
[   50.694622] PM: Adding info for No Bus:ttySL25
[   50.699181] device: 'ttySL26': device_add
[   50.703266] PM: Adding info for No Bus:ttySL26
[   50.707825] device: 'ttySL27': device_add
[   50.711882] PM: Adding info for No Bus:ttySL27
[   50.716470] device: 'ttySL28': device_add
[   50.720529] PM: Adding info for No Bus:ttySL28
[   50.725125] device: 'ttySL29': device_add
[   50.729190] PM: Adding info for No Bus:ttySL29
[   50.733783] device: 'ttySL30': device_add
[   50.737849] PM: Adding info for No Bus:ttySL30
[   50.742410] device: 'ttySL31': device_add
[   50.746496] PM: Adding info for No Bus:ttySL31
[   50.751061] device: 'ttySL32': device_add
[   50.755141] PM: Adding info for No Bus:ttySL32
[   50.759706] device: 'ttySL33': device_add
[   50.763797] PM: Adding info for No Bus:ttySL33
[   50.768368] device: 'ttySL34': device_add
[   50.772417] PM: Adding info for No Bus:ttySL34
[   50.777019] device: 'ttySL35': device_add
[   50.781073] PM: Adding info for No Bus:ttySL35
[   50.785662] device: 'ttySL36': device_add
[   50.789715] PM: Adding info for No Bus:ttySL36
[   50.794303] device: 'ttySL37': device_add
[   50.798361] PM: Adding info for No Bus:ttySL37
[   50.802961] device: 'ttySL38': device_add
[   50.807017] PM: Adding info for No Bus:ttySL38
[   50.811577] device: 'ttySL39': device_add
[   50.815667] PM: Adding info for No Bus:ttySL39
[   50.820259] device: 'ttySL40': device_add
[   50.824340] PM: Adding info for No Bus:ttySL40
[   50.828905] device: 'ttySL41': device_add
[   50.832995] PM: Adding info for No Bus:ttySL41
[   50.837567] device: 'ttySL42': device_add
[   50.841628] PM: Adding info for No Bus:ttySL42
[   50.846233] device: 'ttySL43': device_add
[   50.850298] PM: Adding info for No Bus:ttySL43
[   50.854895] device: 'ttySL44': device_add
[   50.858958] PM: Adding info for No Bus:ttySL44
[   50.863562] device: 'ttySL45': device_add
[   50.867625] PM: Adding info for No Bus:ttySL45
[   50.872192] device: 'ttySL46': device_add
[   50.876276] PM: Adding info for No Bus:ttySL46
[   50.880838] device: 'ttySL47': device_add
[   50.884924] PM: Adding info for No Bus:ttySL47
[   50.889488] device: 'ttySL48': device_add
[   50.893581] PM: Adding info for No Bus:ttySL48
[   50.898153] device: 'ttySL49': device_add
[   50.902207] PM: Adding info for No Bus:ttySL49
[   50.906821] device: 'ttySL50': device_add
[   50.910876] PM: Adding info for No Bus:ttySL50
[   50.915463] device: 'ttySL51': device_add
[   50.919519] PM: Adding info for No Bus:ttySL51
[   50.924122] device: 'ttySL52': device_add
[   50.928178] PM: Adding info for No Bus:ttySL52
[   50.932785] device: 'ttySL53': device_add
[   50.936844] PM: Adding info for No Bus:ttySL53
[   50.941405] device: 'ttySL54': device_add
[   50.945495] PM: Adding info for No Bus:ttySL54
[   50.950146] device: 'ttySL55': device_add
[   50.954234] PM: Adding info for No Bus:ttySL55
[   50.958806] device: 'ttySL56': device_add
[   50.962899] PM: Adding info for No Bus:ttySL56
[   50.967477] device: 'ttySL57': device_add
[   50.971532] PM: Adding info for No Bus:ttySL57
[   50.976139] device: 'ttySL58': device_add
[   50.980199] PM: Adding info for No Bus:ttySL58
[   50.984801] device: 'ttySL59': device_add
[   50.988865] PM: Adding info for No Bus:ttySL59
[   50.993462] device: 'ttySL60': device_add
[   50.997527] PM: Adding info for No Bus:ttySL60
[   51.002105] device: 'ttySL61': device_add
[   51.006194] PM: Adding info for No Bus:ttySL61
[   51.010761] device: 'ttySL62': device_add
[   51.014859] PM: Adding info for No Bus:ttySL62
[   51.019424] device: 'ttySL63': device_add
[   51.023525] PM: Adding info for No Bus:ttySL63
[   51.028095] device: 'ttySL64': device_add
[   51.032158] PM: Adding info for No Bus:ttySL64
[   51.036760] device: 'ttySL65': device_add
[   51.040828] PM: Adding info for No Bus:ttySL65
[   51.045427] device: 'ttySL66': device_add
[   51.049494] PM: Adding info for No Bus:ttySL66
[   51.054101] device: 'ttySL67': device_add
[   51.058171] PM: Adding info for No Bus:ttySL67
[   51.062776] device: 'ttySL68': device_add
[   51.066843] PM: Adding info for No Bus:ttySL68
[   51.071401] device: 'ttySL69': device_add
[   51.075499] PM: Adding info for No Bus:ttySL69
[   51.080161] device: 'ttySL70': device_add
[   51.084242] PM: Adding info for No Bus:ttySL70
[   51.088824] device: 'ttySL71': device_add
[   51.092924] PM: Adding info for No Bus:ttySL71
[   51.097490] device: 'ttySL72': device_add
[   51.101557] PM: Adding info for No Bus:ttySL72
[   51.106161] device: 'ttySL73': device_add
[   51.110862] PM: Adding info for No Bus:ttySL73
[   51.115470] device: 'ttySL74': device_add
[   51.119538] PM: Adding info for No Bus:ttySL74
[   51.124148] device: 'ttySL75': device_add
[   51.128213] PM: Adding info for No Bus:ttySL75
[   51.132807] device: 'ttySL76': device_add
[   51.136870] PM: Adding info for No Bus:ttySL76
[   51.141434] device: 'ttySL77': device_add
[   51.145528] PM: Adding info for No Bus:ttySL77
[   51.150173] device: 'ttySL78': device_add
[   51.154260] PM: Adding info for No Bus:ttySL78
[   51.158838] device: 'ttySL79': device_add
[   51.162929] PM: Adding info for No Bus:ttySL79
[   51.167498] device: 'ttySL80': device_add
[   51.171560] PM: Adding info for No Bus:ttySL80
[   51.176159] device: 'ttySL81': device_add
[   51.180226] PM: Adding info for No Bus:ttySL81
[   51.184830] device: 'ttySL82': device_add
[   51.188900] PM: Adding info for No Bus:ttySL82
[   51.193503] device: 'ttySL83': device_add
[   51.197569] PM: Adding info for No Bus:ttySL83
[   51.202150] device: 'ttySL84': device_add
[   51.206253] PM: Adding info for No Bus:ttySL84
[   51.210831] device: 'ttySL85': device_add
[   51.214926] PM: Adding info for No Bus:ttySL85
[   51.219505] device: 'ttySL86': device_add
[   51.223600] PM: Adding info for No Bus:ttySL86
[   51.228170] device: 'ttySL87': device_add
[   51.232239] PM: Adding info for No Bus:ttySL87
[   51.236841] device: 'ttySL88': device_add
[   51.240906] PM: Adding info for No Bus:ttySL88
[   51.245504] device: 'ttySL89': device_add
[   51.249567] PM: Adding info for No Bus:ttySL89
[   51.254170] device: 'ttySL90': device_add
[   51.258239] PM: Adding info for No Bus:ttySL90
[   51.262839] device: 'ttySL91': device_add
[   51.266911] PM: Adding info for No Bus:ttySL91
[   51.271480] device: 'ttySL92': device_add
[   51.275586] PM: Adding info for No Bus:ttySL92
[   51.280273] device: 'ttySL93': device_add
[   51.284387] PM: Adding info for No Bus:ttySL93
[   51.288970] device: 'ttySL94': device_add
[   51.293092] PM: Adding info for No Bus:ttySL94
[   51.297677] device: 'ttySL95': device_add
[   51.301750] PM: Adding info for No Bus:ttySL95
[   51.306404] device: 'ttySL96': device_add
[   51.310483] PM: Adding info for No Bus:ttySL96
[   51.315132] device: 'ttySL97': device_add
[   51.319209] PM: Adding info for No Bus:ttySL97
[   51.323831] device: 'ttySL98': device_add
[   51.327903] PM: Adding info for No Bus:ttySL98
[   51.332471] device: 'ttySL99': device_add
[   51.336599] PM: Adding info for No Bus:ttySL99
[   51.341170] device: 'ttySL100': device_add
[   51.345350] PM: Adding info for No Bus:ttySL100
[   51.350011] device: 'ttySL101': device_add
[   51.354211] PM: Adding info for No Bus:ttySL101
[   51.358880] device: 'ttySL102': device_add
[   51.363085] PM: Adding info for No Bus:ttySL102
[   51.367740] device: 'ttySL103': device_add
[   51.371897] PM: Adding info for No Bus:ttySL103
[   51.376598] device: 'ttySL104': device_add
[   51.380751] PM: Adding info for No Bus:ttySL104
[   51.385438] device: 'ttySL105': device_add
[   51.389602] PM: Adding info for No Bus:ttySL105
[   51.394290] device: 'ttySL106': device_add
[   51.398447] PM: Adding info for No Bus:ttySL106
[   51.403133] device: 'ttySL107': device_add
[   51.407388] PM: Adding info for No Bus:ttySL107
[   51.412048] device: 'ttySL108': device_add
[   51.416266] PM: Adding info for No Bus:ttySL108
[   51.420932] device: 'ttySL109': device_add
[   51.425122] PM: Adding info for No Bus:ttySL109
[   51.429778] device: 'ttySL110': device_add
[   51.433965] PM: Adding info for No Bus:ttySL110
[   51.438627] device: 'ttySL111': device_add
[   51.442820] PM: Adding info for No Bus:ttySL111
[   51.447488] device: 'ttySL112': device_add
[   51.451640] PM: Adding info for No Bus:ttySL112
[   51.456340] device: 'ttySL113': device_add
[   51.460497] PM: Adding info for No Bus:ttySL113
[   51.465188] device: 'ttySL114': device_add
[   51.469352] PM: Adding info for No Bus:ttySL114
[   51.474040] device: 'ttySL115': device_add
[   51.478202] PM: Adding info for No Bus:ttySL115
[   51.482885] device: 'ttySL116': device_add
[   51.487040] PM: Adding info for No Bus:ttySL116
[   51.491701] device: 'ttySL117': device_add
[   51.495892] PM: Adding info for No Bus:ttySL117
[   51.500548] device: 'ttySL118': device_add
[   51.504734] PM: Adding info for No Bus:ttySL118
[   51.509387] device: 'ttySL119': device_add
[   51.513581] PM: Adding info for No Bus:ttySL119
[   51.518241] device: 'ttySL120': device_add
[   51.522398] PM: Adding info for No Bus:ttySL120
[   51.527083] device: 'ttySL121': device_add
[   51.531239] PM: Adding info for No Bus:ttySL121
[   51.535928] device: 'ttySL122': device_add
[   51.540094] PM: Adding info for No Bus:ttySL122
[   51.544782] device: 'ttySL123': device_add
[   51.548943] PM: Adding info for No Bus:ttySL123
[   51.553634] device: 'ttySL124': device_add
[   51.557789] PM: Adding info for No Bus:ttySL124
[   51.562442] device: 'ttySL125': device_add
[   51.566635] PM: Adding info for No Bus:ttySL125
[   51.571300] device: 'ttySL126': device_add
[   51.575491] PM: Adding info for No Bus:ttySL126
[   51.580247] device: 'ttySL127': device_add
[   51.584471] PM: Adding info for No Bus:ttySL127
[   51.589148] SyncLink serial driver $Revision: 4.38 $, tty major#251
[   51.595329] initcall synclink_init+0x0/0x134 returned 0 after 110217=
4 usecs
[   51.602232] calling  synclinkmp_init+0x0/0x157 @ 1
[   51.607016] SyncLink MultiPort driver $Revision: 4.38 $
[   51.612202] bus: 'pci': add driver synclinkmp
[   51.616886] device: 'ttySLM0': device_add
[   51.621004] PM: Adding info for No Bus:ttySLM0
[   51.625656] device: 'ttySLM1': device_add
[   51.629748] PM: Adding info for No Bus:ttySLM1
[   51.634402] device: 'ttySLM2': device_add
[   51.638489] PM: Adding info for No Bus:ttySLM2
[   51.643116] device: 'ttySLM3': device_add
[   51.647196] PM: Adding info for No Bus:ttySLM3
[   51.651765] device: 'ttySLM4': device_add
[   51.655897] PM: Adding info for No Bus:ttySLM4
[   51.660476] device: 'ttySLM5': device_add
[   51.664575] PM: Adding info for No Bus:ttySLM5
[   51.669145] device: 'ttySLM6': device_add
[   51.673261] PM: Adding info for No Bus:ttySLM6
[   51.677833] device: 'ttySLM7': device_add
[   51.681906] PM: Adding info for No Bus:ttySLM7
[   51.686528] device: 'ttySLM8': device_add
[   51.690602] PM: Adding info for No Bus:ttySLM8
[   51.695210] device: 'ttySLM9': device_add
[   51.699285] PM: Adding info for No Bus:ttySLM9
[   51.703891] device: 'ttySLM10': device_add
[   51.708054] PM: Adding info for No Bus:ttySLM10
[   51.712737] device: 'ttySLM11': device_add
[   51.716896] PM: Adding info for No Bus:ttySLM11
[   51.721555] device: 'ttySLM12': device_add
[   51.725763] PM: Adding info for No Bus:ttySLM12
[   51.730414] device: 'ttySLM13': device_add
[   51.734597] PM: Adding info for No Bus:ttySLM13
[   51.739258] device: 'ttySLM14': device_add
[   51.743452] PM: Adding info for No Bus:ttySLM14
[   51.748109] device: 'ttySLM15': device_add
[   51.752272] PM: Adding info for No Bus:ttySLM15
[   51.756962] device: 'ttySLM16': device_add
[   51.761126] PM: Adding info for No Bus:ttySLM16
[   51.765822] device: 'ttySLM17': device_add
[   51.769983] PM: Adding info for No Bus:ttySLM17
[   51.774670] device: 'ttySLM18': device_add
[   51.778836] PM: Adding info for No Bus:ttySLM18
[   51.783522] device: 'ttySLM19': device_add
[   51.787686] PM: Adding info for No Bus:ttySLM19
[   51.792345] device: 'ttySLM20': device_add
[   51.796547] PM: Adding info for No Bus:ttySLM20
[   51.801209] device: 'ttySLM21': device_add
[   51.805396] PM: Adding info for No Bus:ttySLM21
[   51.810137] device: 'ttySLM22': device_add
[   51.814333] PM: Adding info for No Bus:ttySLM22
[   51.818990] device: 'ttySLM23': device_add
[   51.823182] PM: Adding info for No Bus:ttySLM23
[   51.827838] device: 'ttySLM24': device_add
[   51.831998] PM: Adding info for No Bus:ttySLM24
[   51.836690] device: 'ttySLM25': device_add
[   51.840848] PM: Adding info for No Bus:ttySLM25
[   51.845538] device: 'ttySLM26': device_add
[   51.849697] PM: Adding info for No Bus:ttySLM26
[   51.854391] device: 'ttySLM27': device_add
[   51.858555] PM: Adding info for No Bus:ttySLM27
[   51.863242] device: 'ttySLM28': device_add
[   51.867407] PM: Adding info for No Bus:ttySLM28
[   51.872064] device: 'ttySLM29': device_add
[   51.876265] PM: Adding info for No Bus:ttySLM29
[   51.880927] device: 'ttySLM30': device_add
[   51.885115] PM: Adding info for No Bus:ttySLM30
[   51.889777] device: 'ttySLM31': device_add
[   51.893977] PM: Adding info for No Bus:ttySLM31
[   51.898634] device: 'ttySLM32': device_add
[   51.902825] PM: Adding info for No Bus:ttySLM32
[   51.908113] device: 'ttySLM33': device_add
[   51.912276] PM: Adding info for No Bus:ttySLM33
[   51.916977] device: 'ttySLM34': device_add
[   51.921146] PM: Adding info for No Bus:ttySLM34
[   51.925838] device: 'ttySLM35': device_add
[   51.930005] PM: Adding info for No Bus:ttySLM35
[   51.934703] device: 'ttySLM36': device_add
[   51.938863] PM: Adding info for No Bus:ttySLM36
[   51.943556] device: 'ttySLM37': device_add
[   51.947724] PM: Adding info for No Bus:ttySLM37
[   51.952381] device: 'ttySLM38': device_add
[   51.956585] PM: Adding info for No Bus:ttySLM38
[   51.961234] device: 'ttySLM39': device_add
[   51.965418] PM: Adding info for No Bus:ttySLM39
[   51.970179] device: 'ttySLM40': device_add
[   51.974372] PM: Adding info for No Bus:ttySLM40
[   51.979035] device: 'ttySLM41': device_add
[   51.983229] PM: Adding info for No Bus:ttySLM41
[   51.987890] device: 'ttySLM42': device_add
[   51.992053] PM: Adding info for No Bus:ttySLM42
[   51.996754] device: 'ttySLM43': device_add
[   52.000920] PM: Adding info for No Bus:ttySLM43
[   52.005604] device: 'ttySLM44': device_add
[   52.009773] PM: Adding info for No Bus:ttySLM44
[   52.014470] device: 'ttySLM45': device_add
[   52.018637] PM: Adding info for No Bus:ttySLM45
[   52.023316] device: 'ttySLM46': device_add
[   52.027493] PM: Adding info for No Bus:ttySLM46
[   52.032149] device: 'ttySLM47': device_add
[   52.036354] PM: Adding info for No Bus:ttySLM47
[   52.041010] device: 'ttySLM48': device_add
[   52.045205] PM: Adding info for No Bus:ttySLM48
[   52.049861] device: 'ttySLM49': device_add
[   52.054066] PM: Adding info for No Bus:ttySLM49
[   52.058726] device: 'ttySLM50': device_add
[   52.062924] PM: Adding info for No Bus:ttySLM50
[   52.067577] device: 'ttySLM51': device_add
[   52.071742] PM: Adding info for No Bus:ttySLM51
[   52.076436] device: 'ttySLM52': device_add
[   52.080606] PM: Adding info for No Bus:ttySLM52
[   52.085300] device: 'ttySLM53': device_add
[   52.089473] PM: Adding info for No Bus:ttySLM53
[   52.094165] device: 'ttySLM54': device_add
[   52.098335] PM: Adding info for No Bus:ttySLM54
[   52.103017] device: 'ttySLM55': device_add
[   52.107186] PM: Adding info for No Bus:ttySLM55
[   52.111849] device: 'ttySLM56': device_add
[   52.116053] PM: Adding info for No Bus:ttySLM56
[   52.120709] device: 'ttySLM57': device_add
[   52.124905] PM: Adding info for No Bus:ttySLM57
[   52.129562] device: 'ttySLM58': device_add
[   52.133773] PM: Adding info for No Bus:ttySLM58
[   52.138434] device: 'ttySLM59': device_add
[   52.142639] PM: Adding info for No Bus:ttySLM59
[   52.147299] device: 'ttySLM60': device_add
[   52.151469] PM: Adding info for No Bus:ttySLM60
[   52.156162] device: 'ttySLM61': device_add
[   52.160328] PM: Adding info for No Bus:ttySLM61
[   52.165016] device: 'ttySLM62': device_add
[   52.169188] PM: Adding info for No Bus:ttySLM62
[   52.173883] device: 'ttySLM63': device_add
[   52.178055] PM: Adding info for No Bus:ttySLM63
[   52.182743] device: 'ttySLM64': device_add
[   52.186917] PM: Adding info for No Bus:ttySLM64
[   52.191574] device: 'ttySLM65': device_add
[   52.195775] PM: Adding info for No Bus:ttySLM65
[   52.200441] device: 'ttySLM66': device_add
[   52.204645] PM: Adding info for No Bus:ttySLM66
[   52.209299] device: 'ttySLM67': device_add
[   52.213507] PM: Adding info for No Bus:ttySLM67
[   52.218173] device: 'ttySLM68': device_add
[   52.222349] PM: Adding info for No Bus:ttySLM68
[   52.227046] device: 'ttySLM69': device_add
[   52.231221] PM: Adding info for No Bus:ttySLM69
[   52.235914] device: 'ttySLM70': device_add
[   52.240096] PM: Adding info for No Bus:ttySLM70
[   52.244786] device: 'ttySLM71': device_add
[   52.248967] PM: Adding info for No Bus:ttySLM71
[   52.253665] device: 'ttySLM72': device_add
[   52.257836] PM: Adding info for No Bus:ttySLM72
[   52.262493] device: 'ttySLM73': device_add
[   52.266702] PM: Adding info for No Bus:ttySLM73
[   52.271365] device: 'ttySLM74': device_add
[   52.275561] PM: Adding info for No Bus:ttySLM74
[   52.280254] device: 'ttySLM75': device_add
[   52.284465] PM: Adding info for No Bus:ttySLM75
[   52.289124] device: 'ttySLM76': device_add
[   52.293329] PM: Adding info for No Bus:ttySLM76
[   52.297986] device: 'ttySLM77': device_add
[   52.302166] PM: Adding info for No Bus:ttySLM77
[   52.306860] device: 'ttySLM78': device_add
[   52.311038] PM: Adding info for No Bus:ttySLM78
[   52.315728] device: 'ttySLM79': device_add
[   52.319905] PM: Adding info for No Bus:ttySLM79
[   52.324596] device: 'ttySLM80': device_add
[   52.328776] PM: Adding info for No Bus:ttySLM80
[   52.333455] device: 'ttySLM81': device_add
[   52.337641] PM: Adding info for No Bus:ttySLM81
[   52.342301] device: 'ttySLM82': device_add
[   52.346516] PM: Adding info for No Bus:ttySLM82
[   52.351177] device: 'ttySLM83': device_add
[   52.355382] PM: Adding info for No Bus:ttySLM83
[   52.360134] device: 'ttySLM84': device_add
[   52.364338] PM: Adding info for No Bus:ttySLM84
[   52.369023] device: 'ttySLM85': device_add
[   52.373257] PM: Adding info for No Bus:ttySLM85
[   52.377920] device: 'ttySLM86': device_add
[   52.382102] PM: Adding info for No Bus:ttySLM86
[   52.386859] device: 'ttySLM87': device_add
[   52.391049] PM: Adding info for No Bus:ttySLM87
[   52.395745] device: 'ttySLM88': device_add
[   52.399925] PM: Adding info for No Bus:ttySLM88
[   52.404639] device: 'ttySLM89': device_add
[   52.408819] PM: Adding info for No Bus:ttySLM89
[   52.413511] device: 'ttySLM90': device_add
[   52.417691] PM: Adding info for No Bus:ttySLM90
[   52.422358] device: 'ttySLM91': device_add
[   52.426573] PM: Adding info for No Bus:ttySLM91
[   52.431229] device: 'ttySLM92': device_add
[   52.435433] PM: Adding info for No Bus:ttySLM92
[   52.440187] device: 'ttySLM93': device_add
[   52.444399] PM: Adding info for No Bus:ttySLM93
[   52.449059] device: 'ttySLM94': device_add
[   52.453273] PM: Adding info for No Bus:ttySLM94
[   52.457933] device: 'ttySLM95': device_add
[   52.462110] PM: Adding info for No Bus:ttySLM95
[   52.466806] device: 'ttySLM96': device_add
[   52.470983] PM: Adding info for No Bus:ttySLM96
[   52.475680] device: 'ttySLM97': device_add
[   52.479860] PM: Adding info for No Bus:ttySLM97
[   52.484554] device: 'ttySLM98': device_add
[   52.488734] PM: Adding info for No Bus:ttySLM98
[   52.493425] device: 'ttySLM99': device_add
[   52.497615] PM: Adding info for No Bus:ttySLM99
[   52.502285] device: 'ttySLM100': device_add
[   52.506594] PM: Adding info for No Bus:ttySLM100
[   52.511346] device: 'ttySLM101': device_add
[   52.515641] PM: Adding info for No Bus:ttySLM101
[   52.520387] device: 'ttySLM102': device_add
[   52.524692] PM: Adding info for No Bus:ttySLM102
[   52.529436] device: 'ttySLM103': device_add
[   52.533728] PM: Adding info for No Bus:ttySLM103
[   52.538474] device: 'ttySLM104': device_add
[   52.542770] PM: Adding info for No Bus:ttySLM104
[   52.547523] device: 'ttySLM105': device_add
[   52.551787] PM: Adding info for No Bus:ttySLM105
[   52.556565] device: 'ttySLM106': device_add
[   52.560840] PM: Adding info for No Bus:ttySLM106
[   52.565617] device: 'ttySLM107': device_add
[   52.569888] PM: Adding info for No Bus:ttySLM107
[   52.574670] device: 'ttySLM108': device_add
[   52.578945] PM: Adding info for No Bus:ttySLM108
[   52.583724] device: 'ttySLM109': device_add
[   52.588000] PM: Adding info for No Bus:ttySLM109
[   52.592774] device: 'ttySLM110': device_add
[   52.597048] PM: Adding info for No Bus:ttySLM110
[   52.601791] device: 'ttySLM111': device_add
[   52.606092] PM: Adding info for No Bus:ttySLM111
[   52.610843] device: 'ttySLM112': device_add
[   52.615139] PM: Adding info for No Bus:ttySLM112
[   52.619881] device: 'ttySLM113': device_add
[   52.624184] PM: Adding info for No Bus:ttySLM113
[   52.628931] device: 'ttySLM114': device_add
[   52.633226] PM: Adding info for No Bus:ttySLM114
[   52.637970] device: 'ttySLM115': device_add
[   52.642233] PM: Adding info for No Bus:ttySLM115
[   52.647011] device: 'ttySLM116': device_add
[   52.651281] PM: Adding info for No Bus:ttySLM116
[   52.656062] device: 'ttySLM117': device_add
[   52.660335] PM: Adding info for No Bus:ttySLM117
[   52.665117] device: 'ttySLM118': device_add
[   52.669386] PM: Adding info for No Bus:ttySLM118
[   52.674160] device: 'ttySLM119': device_add
[   52.678435] PM: Adding info for No Bus:ttySLM119
[   52.683214] device: 'ttySLM120': device_add
[   52.687585] PM: Adding info for No Bus:ttySLM120
[   52.692328] device: 'ttySLM121': device_add
[   52.696661] PM: Adding info for No Bus:ttySLM121
[   52.701419] device: 'ttySLM122': device_add
[   52.705731] PM: Adding info for No Bus:ttySLM122
[   52.711114] device: 'ttySLM123': device_add
[   52.715427] PM: Adding info for No Bus:ttySLM123
[   52.720351] device: 'ttySLM124': device_add
[   52.724681] PM: Adding info for No Bus:ttySLM124
[   52.729442] device: 'ttySLM125': device_add
[   52.733775] PM: Adding info for No Bus:ttySLM125
[   52.738536] device: 'ttySLM126': device_add
[   52.742904] PM: Adding info for No Bus:ttySLM126
[   52.747653] device: 'ttySLM127': device_add
[   52.751924] PM: Adding info for No Bus:ttySLM127
[   52.756768] SyncLink MultiPort driver $Revision: 4.38 $, tty major#2=
50
[   52.763225] initcall synclinkmp_init+0x0/0x157 returned 0 after 1129=
105 usecs
[   52.770279] calling  slgt_init+0x0/0x183 @ 1
[   52.774544] SyncLink GT
[   52.776989] SyncLink GT, tty major#249
[   52.780682] bus: 'pci': add driver synclink_gt
[   52.785412] SyncLink GT no devices found
[   52.789219] initcall slgt_init+0x0/0x183 returned 0 after 14332 usec=
s
[   52.795672] calling  n_hdlc_init+0x0/0x81 @ 1
[   52.799965] HDLC line discipline maxframe=3D4096
[   52.804399] N_HDLC line discipline registered.
[   52.808806] initcall n_hdlc_init+0x0/0x81 returned 0 after 8632 usec=
s
[   52.815234] calling  sx_init+0x0/0x2fb @ 1
[   52.819307] device: 'sxctl': device_add
[   52.823246] PM: Adding info for No Bus:sxctl
[   52.827731] bus: 'pci': add driver sx
[   52.831570] initcall sx_init+0x0/0x2fb returned 0 after 11991 usecs
[   52.837758] calling  xen_init+0x0/0x7f @ 1
[   52.841802] initcall xen_init+0x0/0x7f returned -19 after 1 usecs
[   52.847881] calling  raw_init+0x0/0xc7 @ 1
[   52.851953] device class 'raw': registering
[   52.856374] device: 'rawctl': device_add
[   52.860305] PM: Adding info for No Bus:rawctl
[   52.864898] initcall raw_init+0x0/0xc7 returned 0 after 12649 usecs
[   52.871048] calling  lp_init_module+0x0/0xb1 @ 1
[   52.875694] device class 'printer': registering
[   52.880416] lp: driver loaded but no devices found
[   52.885108] initcall lp_init_module+0x0/0xb1 returned 0 after 9218 u=
secs
[   52.891761] calling  dtlk_init+0x0/0x8e @ 1
[   52.896029] DoubleTalk PC - not found
[   52.899588] initcall dtlk_init+0x0/0x8e returned -19 after 3555 usec=
s
[   52.906000] calling  r3964_init+0x0/0x38 @ 1
[   52.910231] r3964: Philips r3964 Driver $Revision: 1.10 $
[   52.915623] initcall r3964_init+0x0/0x38 returned 0 after 5260 usecs
[   52.921930] calling  nvram_init+0x0/0x70 @ 1
[   52.926211] device: 'nvram': device_add
[   52.930120] PM: Adding info for No Bus:nvram
[   52.934547] Non-volatile memory driver v1.3
[   52.938617] initcall nvram_init+0x0/0x70 returned 0 after 12132 usec=
s
[   52.945051] calling  scx200_gpio_init+0x0/0x10e @ 1
[   52.949882] scx200_gpio: no SCx200 gpio present
[   52.954407] initcall scx200_gpio_init+0x0/0x10e returned -19 after 4=
413 usecs
[   52.961493] calling  pc8736x_gpio_init+0x0/0x37f @ 1
[   52.966462] Registering platform device 'pc8736x_gpio.0'. Parent at =
platform
[   52.973476] device: 'pc8736x_gpio.0': device_add
[   52.978068] bus: 'platform': add device pc8736x_gpio.0
[   52.983235] PM: Adding info for platform:pc8736x_gpio.0
[   52.988595] platform pc8736x_gpio.0: NatSemi pc8736x GPIO Driver Ini=
tializing
[   52.995662] platform pc8736x_gpio.0: no device found
[   53.000555] PM: Removing info for platform:pc8736x_gpio.0
[   53.006001] bus: 'platform': remove device pc8736x_gpio.0
[   53.011550] initcall pc8736x_gpio_init+0x0/0x37f returned -19 after =
44042 usecs
[   53.018793] calling  nsc_gpio_init+0x0/0x11 @ 1
[   53.023289] nsc_gpio initializing
[   53.026568] initcall nsc_gpio_init+0x0/0x11 returned 0 after 3201 us=
ecs
[   53.033169] calling  cs5535_gpio_init+0x0/0x147 @ 1
[   53.038023] cs5535_gpio: DIVIL not found
[   53.041905] initcall cs5535_gpio_init+0x0/0x147 returned -19 after 3=
809 usecs
[   53.049028] calling  tlclk_init+0x0/0x1cb @ 1
[   53.053393] telclk_interrup =3D 0xf non-mcpbl0010 hw.
[   53.058221] initcall tlclk_init+0x0/0x1cb returned -6 after 4745 use=
cs
[   53.064717] initcall tlclk_init+0x0/0x1cb returned with error code -=
6=20
[   53.071198] calling  mwave_init+0x0/0x265 @ 1
[   53.075556] smapi::smapi_init, ERROR invalid usSmapiID
[   53.080644] mwave: tp3780i::tp3780I_InitializeBoardData: Error: SMAP=
I is not available on this machine
[   53.089934] mwave: mwavedd::mwave_init: Error: Failed to initialize =
board data
[   53.097128] mwave: mwavedd::mwave_init: Error: Failed to initialize
[   53.103371] initcall mwave_init+0x0/0x265 returned -5 after 27168 us=
ecs
[   53.109939] initcall mwave_init+0x0/0x265 returned with error code -=
5=20
[   53.116456] calling  agp_init+0x0/0x21 @ 1
[   53.120514] Linux agpgart interface v0.103
[   53.124604] initcall agp_init+0x0/0x21 returned 0 after 3989 usecs
[   53.130739] calling  agp_ati_init+0x0/0x24 @ 1
[   53.135182] bus: 'pci': add driver agpgart-ati
[   53.139874] initcall agp_ati_init+0x0/0x24 returned 0 after 4587 use=
cs
[   53.146324] calling  agp_efficeon_init+0x0/0x39 @ 1
[   53.151144] bus: 'pci': add driver agpgart-efficeon
[   53.156300] initcall agp_efficeon_init+0x0/0x39 returned 0 after 503=
1 usecs
[   53.163165] calling  agp_intel_init+0x0/0x24 @ 1
[   53.167732] bus: 'pci': add driver agpgart-intel
[   53.172623] initcall agp_intel_init+0x0/0x24 returned 0 after 4773 u=
secs
[   53.179203] calling  agp_sis_init+0x0/0x24 @ 1
[   53.183649] bus: 'pci': add driver agpgart-sis
[   53.188337] initcall agp_sis_init+0x0/0x24 returned 0 after 4581 use=
cs
[   53.194765] calling  agp_serverworks_init+0x0/0x24 @ 1
[   53.199861] bus: 'pci': add driver agpgart-serverworks
[   53.205285] initcall agp_serverworks_init+0x0/0x24 returned 0 after =
5294 usecs
[   53.212405] calling  ipmi_init_msghandler_mod+0x0/0xc @ 1
[   53.217812] bus: 'platform': add driver ipmi
[   53.222291] ipmi message handler version 39.2
[   53.226574] initcall ipmi_init_msghandler_mod+0x0/0xc returned 0 aft=
er 8557 usecs
[   53.234010] calling  init_ipmi_si+0x0/0x332 @ 1
[   53.238496] bus: 'platform': add driver ipmi_si
[   53.243277] IPMI System Interface driver.
[   53.247173] bus: 'pci': add driver ipmi_si
[   53.332572] bus: 'pci': remove driver ipmi_si
[   53.337059] driver: 'ipmi_si': driver_release
[   53.341320] bus: 'platform': remove driver ipmi_si
[   53.346316] driver: 'ipmi_si': driver_release
[   53.350559] ipmi_si: Unable to find any System Interface(s)
[   53.356189] initcall init_ipmi_si+0x0/0x332 returned -19 after 11493=
0 usecs
[   53.363053] calling  ipmi_poweroff_init+0x0/0x7e @ 1
[   53.367975] Copyright (C) 2004 MontaVista Software - IPMI Powerdown =
via sys_reboot.
[   53.375679] initcall ipmi_poweroff_init+0x0/0x7e returned 0 after 75=
17 usecs
[   53.382639] calling  init_tis+0x0/0x87 @ 1
[   53.386698] bus: 'pnp': add driver tpm_tis
[   53.391049] initcall init_tis+0x0/0x87 returned 0 after 4250 usecs
[   53.397140] calling  init_nsc+0x0/0x59c @ 1
[   53.401288] initcall init_nsc+0x0/0x59c returned -19 after 12 usecs
[   53.407530] calling  init_atmel+0x0/0x164 @ 1
[   53.411848] Platform driver 'tpm_atmel' needs updating - please use =
dev_pm_ops
[   53.419057] bus: 'platform': add driver tpm_atmel
[   53.424019] bus: 'platform': remove driver tpm_atmel
[   53.429097] driver: 'tpm_atmel': driver_release
[   53.433566] initcall init_atmel+0x0/0x164 returned -19 after 21204 u=
secs
[   53.440186] calling  drm_core_init+0x0/0xec @ 1
[   53.444734] device class 'drm': registering
[   53.449140] [drm] Initialized drm 1.1.0 20060810
[   53.453672] initcall drm_core_init+0x0/0xec returned 0 after 8749 us=
ecs
[   53.460223] calling  tdfx_init+0x0/0xf @ 1
[   53.464419] initcall tdfx_init+0x0/0xf returned 0 after 100 usecs
[   53.470390] calling  r128_init+0x0/0x19 @ 1
[   53.475160] initcall r128_init+0x0/0x19 returned 0 after 576 usecs
[   53.481214] calling  mga_init+0x0/0x19 @ 1
[   53.485373] initcall mga_init+0x0/0x19 returned 0 after 63 usecs
[   53.491268] calling  i810_init+0x0/0x19 @ 1
[   53.495515] initcall i810_init+0x0/0x19 returned 0 after 65 usecs
[   53.501494] calling  savage_init+0x0/0x19 @ 1
[   53.506212] initcall savage_init+0x0/0x19 returned 0 after 356 usecs
[   53.512441] calling  i810fb_init+0x0/0x47 @ 1
[   53.516796] bus: 'pci': add driver i810fb
[   53.521049] initcall i810fb_init+0x0/0x47 returned 0 after 4158 usec=
s
[   53.527410] calling  intelfb_init+0x0/0x5f @ 1
[   53.531796] intelfb: Framebuffer driver for Intel(R) 830M/845G/852GM=
/855GM/865G/915G/915GM/945G/945GM/945GME/965G/965GM chipsets
[   53.543338] intelfb: Version 0.9.6
[   53.546704] bus: 'pci': add driver intelfb
[   53.551064] initcall intelfb_init+0x0/0x5f returned 0 after 18817 us=
ecs
[   53.557652] calling  serial8250_init+0x0/0x115 @ 1
[   53.562329] Serial: 8250/16550 driver, 4 ports, IRQ sharing disabled
[   53.568724] Registering platform device 'serial8250'. Parent at plat=
form
[   53.575348] device: 'serial8250': device_add
[   53.579594] bus: 'platform': add device serial8250
[   53.584412] PM: Adding info for platform:serial8250
[   53.589593] serial8250: ttyS0 at I/O 0x3f8 (irq =3D 4) is a 16550A
[   53.595532] device: 'ttyS0': device_add
[   53.599780] PM: Adding info for No Bus:ttyS0
[   53.604338] device: 'ttyS1': device_add
[   53.608329] PM: Adding info for No Bus:ttyS1
[   53.612807] device: 'ttyS2': device_add
[   53.616775] PM: Adding info for No Bus:ttyS2
[   53.621225] device: 'ttyS3': device_add
[   53.625234] PM: Adding info for No Bus:ttyS3
[   53.629628] Platform driver 'serial8250' needs updating - please use=
 dev_pm_ops
[   53.636884] bus: 'platform': add driver serial8250
[   53.641641] bus: 'platform': driver_probe_device: matched device ser=
ial8250 with driver serial8250
[   53.650554] bus: 'platform': really_probe: probing driver serial8250=
 with device serial8250
[   53.658896] driver: 'serial8250': driver_bound: bound to device 'ser=
ial8250'
[   53.665896] bus: 'platform': really_probe: bound device serial8250 t=
o driver serial8250
[   53.674696] initcall serial8250_init+0x0/0x115 returned 0 after 1097=
25 usecs
[   53.681624] calling  serial8250_pnp_init+0x0/0xf @ 1
[   53.686591] bus: 'pnp': add driver serial
[   53.690648] bus: 'pnp': driver_probe_device: matched device 00:08 wi=
th driver serial
[   53.698308] bus: 'pnp': really_probe: probing driver serial with dev=
ice 00:08
[   53.706266] device: 'ttyS0': device_unregister
[   53.710589] PM: Removing info for No Bus:ttyS0
[   53.715798] device: 'ttyS0': device_create_release=EF=BF=BD[   53.72=
0584] 00:08: ttyS0 at I/O 0x3f8 (irq =3D 4) is a 16550A
[   53.726100] device: 'ttyS0': device_add
[   53.730169] PM: Adding info for No Bus:ttyS0
[   53.734638] driver: '00:08': driver_bound: bound to device 'serial'
[   53.740784] bus: 'pnp': really_probe: bound device 00:08 to driver s=
erial
[   53.747928] initcall serial8250_pnp_init+0x0/0xf returned 0 after 59=
895 usecs
[   53.754965] calling  serial8250_pci_init+0x0/0x16 @ 1
[   53.759970] bus: 'pci': add driver serial
[   53.764290] initcall serial8250_pci_init+0x0/0x16 returned 0 after 4=
217 usecs
[   53.771300] calling  max3100_init+0x0/0xf @ 1
[   53.775658] bus: 'spi': add driver max3100
[   53.779966] initcall max3100_init+0x0/0xf returned 0 after 4208 usec=
s
[   53.786312] calling  jsm_init_module+0x0/0x3a @ 1
[   53.791046] bus: 'pci': add driver jsm
[   53.795000] initcall jsm_init_module+0x0/0x3a returned 0 after 3933 =
usecs
[   53.801669] calling  parport_default_proc_register+0x0/0x16 @ 1
[   53.807600] initcall parport_default_proc_register+0x0/0x16 returned=
 0 after 12 usecs
[   53.815380] calling  parport_ax88796_init+0x0/0xf @ 1
[   53.820391] Platform driver 'ax88796-pp' needs updating - please use=
 dev_pm_ops
[   53.827690] bus: 'platform': add driver ax88796-pp
[   53.832719] initcall parport_ax88796_init+0x0/0xf returned 0 after 1=
2033 usecs
[   53.839845] calling  isa_bus_init+0x0/0x33 @ 1
[   53.844586] bus: 'isa': registered
[   53.847880] device: 'isa': device_add
[   53.851545] PM: Adding info for No Bus:isa
[   53.855612] initcall isa_bus_init+0x0/0x33 returned 0 after 11052 us=
ecs
[   53.862172] calling  topology_sysfs_init+0x0/0x56 @ 1
[   53.867315] initcall topology_sysfs_init+0x0/0x56 returned 0 after 9=
4 usecs
[   53.874175] calling  floppy_init+0x0/0x552 @ 1
[   53.878710] Platform driver 'floppy' needs updating - please use dev=
_pm_ops
[   53.885573] bus: 'platform': add driver floppy
[   53.890350] Floppy drive(s): fd0 is 1.44M
[   53.916429] FDC 0 is a post-1991 82077
[   53.921049] Registering platform device 'floppy.0'. Parent at platfo=
rm
[   53.927483] device: 'floppy.0': device_add
[   53.931558] bus: 'platform': add device floppy.0
[   53.936201] PM: Adding info for platform:floppy.0
[   53.941039] bus: 'platform': driver_probe_device: matched device flo=
ppy.0 with driver floppy
[   53.949396] bus: 'platform': really_probe: probing driver floppy wit=
h device floppy.0
[   53.957220] driver: 'floppy.0': driver_bound: bound to device 'flopp=
y'
[   53.963694] bus: 'platform': really_probe: bound device floppy.0 to =
driver floppy
[   53.971152] device: 'fd0': device_add
[   53.974947] PM: Adding info for No Bus:fd0
[   53.979461] device: '2:0': device_add
[   53.983098] PM: Adding info for No Bus:2:0
[   53.987358] initcall floppy_init+0x0/0x552 returned 0 after 106227 u=
secs
[   53.993966] calling  brd_init+0x0/0x14f @ 1
[   53.998627] device: 'ram0': device_add
[   54.002379] PM: Adding info for No Bus:ram0
[   54.006881] device: '1:0': device_add
[   54.010493] PM: Adding info for No Bus:1:0
[   54.014807] device: 'ram1': device_add
[   54.018553] PM: Adding info for No Bus:ram1
[   54.023071] device: '1:1': device_add
[   54.026684] PM: Adding info for No Bus:1:1
[   54.030968] device: 'ram2': device_add
[   54.034751] PM: Adding info for No Bus:ram2
[   54.039229] device: '1:2': device_add
[   54.042877] PM: Adding info for No Bus:1:2
[   54.047129] device: 'ram3': device_add
[   54.050877] PM: Adding info for No Bus:ram3
[   54.055388] device: '1:3': device_add
[   54.059004] PM: Adding info for No Bus:1:3
[   54.063325] device: 'ram4': device_add
[   54.067081] PM: Adding info for No Bus:ram4
[   54.071556] device: '1:4': device_add
[   54.075197] PM: Adding info for No Bus:1:4
[   54.079460] device: 'ram5': device_add
[   54.083243] PM: Adding info for No Bus:ram5
[   54.087733] device: '1:5': device_add
[   54.091343] PM: Adding info for No Bus:1:5
[   54.095653] device: 'ram6': device_add
[   54.099408] PM: Adding info for No Bus:ram6
[   54.103918] device: '1:6': device_add
[   54.107529] PM: Adding info for No Bus:1:6
[   54.111804] device: 'ram7': device_add
[   54.115590] PM: Adding info for No Bus:ram7
[   54.120080] device: '1:7': device_add
[   54.123731] PM: Adding info for No Bus:1:7
[   54.127979] device: 'ram8': device_add
[   54.131733] PM: Adding info for No Bus:ram8
[   54.136249] device: '1:8': device_add
[   54.139863] PM: Adding info for No Bus:1:8
[   54.144169] device: 'ram9': device_add
[   54.147929] PM: Adding info for No Bus:ram9
[   54.152427] device: '1:9': device_add
[   54.156069] PM: Adding info for No Bus:1:9
[   54.160337] device: 'ram10': device_add
[   54.164203] PM: Adding info for No Bus:ram10
[   54.168768] device: '1:10': device_add
[   54.172470] PM: Adding info for No Bus:1:10
[   54.176875] device: 'ram11': device_add
[   54.180713] PM: Adding info for No Bus:ram11
[   54.185314] device: '1:11': device_add
[   54.189015] PM: Adding info for No Bus:1:11
[   54.193411] device: 'ram12': device_add
[   54.197248] PM: Adding info for No Bus:ram12
[   54.201824] device: '1:12': device_add
[   54.205555] PM: Adding info for No Bus:1:12
[   54.209902] device: 'ram13': device_add
[   54.213773] PM: Adding info for No Bus:ram13
[   54.218353] device: '1:13': device_add
[   54.222057] PM: Adding info for No Bus:1:13
[   54.226453] device: 'ram14': device_add
[   54.230298] PM: Adding info for No Bus:ram14
[   54.235016] device: '1:14': device_add
[   54.238721] PM: Adding info for No Bus:1:14
[   54.243108] device: 'ram15': device_add
[   54.246949] PM: Adding info for No Bus:ram15
[   54.251523] device: '1:15': device_add
[   54.255263] PM: Adding info for No Bus:1:15
[   54.259595] brd: module loaded
[   54.262568] initcall brd_init+0x0/0x14f returned 0 after 258261 usec=
s
[   54.268946] calling  loop_init+0x0/0x16c @ 1
[   54.273491] device: 'loop0': device_add
[   54.277328] PM: Adding info for No Bus:loop0
[   54.281894] device: '7:0': device_add
[   54.285531] PM: Adding info for No Bus:7:0
[   54.289785] device: 'loop1': device_add
[   54.293656] PM: Adding info for No Bus:loop1
[   54.298219] device: '7:1': device_add
[   54.301834] PM: Adding info for No Bus:7:1
[   54.306162] device: 'loop2': device_add
[   54.309998] PM: Adding info for No Bus:loop2
[   54.314594] device: '7:2': device_add
[   54.318208] PM: Adding info for No Bus:7:2
[   54.322493] device: 'loop3': device_add
[   54.326363] PM: Adding info for No Bus:loop3
[   54.330939] device: '7:3': device_add
[   54.334570] PM: Adding info for No Bus:7:3
[   54.338832] device: 'loop4': device_add
[   54.342702] PM: Adding info for No Bus:loop4
[   54.347264] device: '7:4': device_add
[   54.350881] PM: Adding info for No Bus:7:4
[   54.355192] device: 'loop5': device_add
[   54.359027] PM: Adding info for No Bus:loop5
[   54.363632] device: '7:5': device_add
[   54.367248] PM: Adding info for No Bus:7:5
[   54.371525] device: 'loop6': device_add
[   54.375388] PM: Adding info for No Bus:loop6
[   54.379953] device: '7:6': device_add
[   54.383602] PM: Adding info for No Bus:7:6
[   54.387855] device: 'loop7': device_add
[   54.391691] PM: Adding info for No Bus:loop7
[   54.396287] device: '7:7': device_add
[   54.399906] PM: Adding info for No Bus:7:7
[   54.404194] loop: module loaded
[   54.407221] initcall loop_init+0x0/0x16c returned 0 after 130870 use=
cs
[   54.413740] calling  xd_init+0x0/0x47b @ 1
[   54.417793] ------------[ cut here ]------------
[   54.422383] WARNING: at mm/page_alloc.c:1743 __alloc_pages_nodemask+=
0x185/0x479()
[   54.429855] Hardware name: System Product Name
[   54.434275] Pid: 1, comm: swapper Not tainted 2.6.31-rc1-tip-01159-g=
24b7800-dirty #59554
[   54.442314] Call Trace:
[   54.444764]  [<c105108d>] warn_slowpath_common+0x60/0x90
[   54.450032]  [<c10510cf>] warn_slowpath_null+0x12/0x15
[   54.455162]  [<c10a841e>] __alloc_pages_nodemask+0x185/0x479
[   54.460779]  [<c10a876a>] __get_free_pages+0x14/0x37
[   54.465736]  [<c20a8d3d>] xd_init+0x50/0x47b
[   54.469967]  [<c1066f43>] ? ktime_get+0x18/0x34
[   54.474489]  [<c1002059>] do_one_initcall+0x4f/0x11f
[   54.479411]  [<c20a8ced>] ? xd_init+0x0/0x47b
[   54.483763]  [<c20792e9>] do_basic_setup+0x3d/0x4d
[   54.489067]  [<c207935b>] kernel_init+0x62/0xa3
[   54.493591]  [<c20792f9>] ? kernel_init+0x0/0xa3
[   54.498169]  [<c1023997>] kernel_thread_helper+0x7/0x10
[   54.503391] ---[ end trace 47b331f1c1cf47e1 ]---
[   54.507959] xd: Out of memory.
[   54.510993] initcall xd_init+0x0/0x47b returned -12 after 91018 usec=
s
[   54.517423] initcall xd_init+0x0/0x47b returned with error code -12=20
[   54.523750] calling  cpqarray_init+0x0/0x5a @ 1
[   54.528240] Compaq SMART2 Driver (v 2.6.0)
[   54.532316] bus: 'pci': add driver cpqarray
[   54.536819] bus: 'pci': remove driver cpqarray
[   54.541377] driver: 'cpqarray': driver_release
[   54.545736] initcall cpqarray_init+0x0/0x5a returned -19 after 17080=
 usecs
[   54.552568] calling  DAC960_init_module+0x0/0x46 @ 1
[   54.557494] bus: 'pci': add driver DAC960
[   54.561769] device: 'dac960_gam': device_add
[   54.566242] PM: Adding info for No Bus:dac960_gam
[   54.571069] initcall DAC960_init_module+0x0/0x46 returned 0 after 13=
258 usecs
[   54.578100] calling  mm_init+0x0/0x155 @ 1
[   54.582161] bus: 'pci': add driver umem
[   54.586289] MM: desc_per_page =3D 128
[   54.589665] initcall mm_init+0x0/0x155 returned 0 after 7330 usecs
[   54.595838] calling  init_cryptoloop+0x0/0x26 @ 1
[   54.600499] initcall init_cryptoloop+0x0/0x26 returned 0 after 1 use=
cs
[   54.607011] calling  ub_init+0x0/0x71 @ 1
[   54.610990] bus: 'usb': add driver ub
[   54.614899] usbcore: registered new interface driver ub
[   54.620051] initcall ub_init+0x0/0x71 returned 0 after 8855 usecs
[   54.626095] calling  xlblk_init+0x0/0x6d @ 1
[   54.630322] initcall xlblk_init+0x0/0x6d returned -19 after 1 usecs
[   54.636575] calling  ibmasm_init+0x0/0x56 @ 1
[   54.640906] bus: 'pci': add driver ibmasm
[   54.645181] ibmasm: IBM ASM Service Processor Driver version 1.0 loa=
ded
[   54.651673] initcall ibmasm_init+0x0/0x56 returned 0 after 10528 use=
cs
[   54.658195] calling  ics932s401_init+0x0/0x11 @ 1
[   54.662872] bus: 'i2c': add driver ics932s401
[   54.667446] i2c-core: driver [ics932s401] registered
[   54.672326] initcall ics932s401_init+0x0/0x11 returned 0 after 9240 =
usecs
[   54.679073] calling  tifm_7xx1_init+0x0/0x16 @ 1
[   54.683664] bus: 'pci': add driver tifm_7xx1
[   54.688182] initcall tifm_7xx1_init+0x0/0x16 returned 0 after 4416 u=
secs
[   54.694787] calling  phantom_init+0x0/0xe1 @ 1
[   54.699189] device class 'phantom': registering
[   54.703968] bus: 'pci': add driver phantom
[   54.708225] Phantom Linux Driver, version n0.9.8, init OK
[   54.713535] initcall phantom_init+0x0/0xe1 returned 0 after 14009 us=
ecs
[   54.720095] calling  enclosure_init+0x0/0x14 @ 1
[   54.724709] device class 'enclosure': registering
[   54.729608] initcall enclosure_init+0x0/0x14 returned 0 after 4786 u=
secs
[   54.736219] calling  init_kgdbts+0x0/0x15 @ 1
[   54.740528] initcall init_kgdbts+0x0/0x15 returned 0 after 1 usecs
[   54.746694] calling  isl29003_init+0x0/0x11 @ 1
[   54.751186] bus: 'i2c': add driver isl29003
[   54.755623] i2c-core: driver [isl29003] registered
[   54.760297] initcall isl29003_init+0x0/0x11 returned 0 after 8897 us=
ecs
[   54.766902] calling  c2port_init+0x0/0x45 @ 1
[   54.771214] Silicon Labs C2 port support v. 0.51.0 - (C) 2007 Rodolf=
o Giometti
[   54.778426] device class 'c2port': registering
[   54.783090] initcall c2port_init+0x0/0x45 returned 0 after 11592 use=
cs
[   54.789498] calling  duramar2150_c2port_init+0x0/0x67 @ 1
[   54.795027] device: 'c2port0': device_add
[   54.799039] PM: Adding info for No Bus:c2port0
[   54.803666] c2port c2port0: C2 port uc added
[   54.807813] c2port c2port0: uc flash has 30 blocks x 512 bytes (1536=
0 bytes total)
[   54.815379] initcall duramar2150_c2port_init+0x0/0x67 returned 0 aft=
er 19999 usecs
[   54.822912] calling  at25_init+0x0/0xf @ 1
[   54.826969] bus: 'spi': add driver at25
[   54.831040] initcall at25_init+0x0/0xf returned 0 after 3978 usecs
[   54.837129] calling  eeprom_init+0x0/0x11 @ 1
[   54.841442] bus: 'i2c': add driver eeprom
[   54.845706] i2c-core: driver [eeprom] registered
[   54.850223] initcall eeprom_init+0x0/0x11 returned 0 after 8575 usec=
s
[   54.856638] calling  max6875_init+0x0/0x11 @ 1
[   54.861038] bus: 'i2c': add driver max6875
[   54.865393] i2c-core: driver [max6875] registered
[   54.869992] initcall max6875_init+0x0/0x11 returned 0 after 8743 use=
cs
[   54.876506] calling  cb710_init_module+0x0/0x16 @ 1
[   54.881338] bus: 'pci': add driver cb710
[   54.885541] initcall cb710_init_module+0x0/0x16 returned 0 after 410=
3 usecs
[   54.892381] calling  sm501_base_init+0x0/0x20 @ 1
[   54.897090] Platform driver 'sm501' needs updating - please use dev_=
pm_ops
[   54.903929] bus: 'platform': add driver sm501
[   54.908514] bus: 'pci': add driver sm501
[   54.912616] initcall sm501_base_init+0x0/0x20 returned 0 after 15160=
 usecs
[   54.919370] calling  pasic3_base_init+0x0/0x14 @ 1
[   54.924167] bus: 'platform': add driver pasic3
[   54.928841] bus: 'platform': remove driver pasic3
[   54.933679] driver: 'pasic3': driver_release
[   54.937840] initcall pasic3_base_init+0x0/0x14 returned -19 after 13=
357 usecs
[   54.944965] calling  scsi_tgt_init+0x0/0x7d @ 1
[   54.950397] device: 'tgt': device_add
[   54.954208] PM: Adding info for No Bus:tgt
[   54.958435] initcall scsi_tgt_init+0x0/0x7d returned 0 after 8775 us=
ecs
[   54.964959] calling  raid_init+0x0/0xf @ 1
[   54.969008] device class 'raid_devices': registering
[   54.974211] initcall raid_init+0x0/0xf returned 0 after 5078 usecs
[   54.980272] calling  spi_transport_init+0x0/0x65 @ 1
[   54.985250] device class 'spi_transport': registering
[   54.990522] device class 'spi_host': registering
[   54.995279] initcall spi_transport_init+0x0/0x65 returned 0 after 98=
05 usecs
[   55.002207] calling  fc_transport_init+0x0/0x43 @ 1
[   55.007084] device class 'fc_host': registering
[   55.011811] device class 'fc_vports': registering
[   55.016657] device class 'fc_remote_ports': registering
[   55.021995] device class 'fc_transport': registering
[   55.027108] initcall fc_transport_init+0x0/0x43 returned 0 after 195=
53 usecs
[   55.034061] calling  iscsi_transport_init+0x0/0x125 @ 1
[   55.039233] Loading iSCSI transport class v2.0-870.
[   55.044102] device class 'iscsi_transport': registering
[   55.049526] device class 'iscsi_endpoint': registering
[   55.054804] device class 'iscsi_host': registering
[   55.059711] device class 'iscsi_connection': registering
[   55.065167] device class 'iscsi_session': registering
[   55.070447] initcall iscsi_transport_init+0x0/0x125 returned 0 after=
 30480 usecs
[   55.077777] calling  sas_transport_init+0x0/0x9f @ 1
[   55.082705] device class 'sas_host': registering
[   55.087518] device class 'sas_phy': registering
[   55.092166] device class 'sas_port': registering
[   55.096924] device class 'sas_device': registering
[   55.101833] device class 'sas_end_device': registering
[   55.107128] device class 'sas_expander': registering
[   55.112215] initcall sas_transport_init+0x0/0x9f returned 0 after 28=
820 usecs
[   55.119265] calling  sas_class_init+0x0/0x2c @ 1
[   55.124442] initcall sas_class_init+0x0/0x2c returned 0 after 579 us=
ecs
[   55.130934] calling  srp_transport_init+0x0/0x33 @ 1
[   55.135903] device class 'srp_host': registering
[   55.140705] device class 'srp_remote_ports': registering
[   55.146166] initcall srp_transport_init+0x0/0x33 returned 0 after 10=
020 usecs
[   55.153200] calling  scsi_dh_init+0x0/0x34 @ 1
[   55.157600] initcall scsi_dh_init+0x0/0x34 returned 0 after 3 usecs
[   55.163851] calling  ahc_linux_init+0x0/0x5c @ 1
[   55.168443] bus: 'pci': add driver aic7xxx
[   55.172834] initcall ahc_linux_init+0x0/0x5c returned 0 after 4296 u=
secs
[   55.179417] calling  init_st+0x0/0xe2 @ 1
[   55.183431] st: Version 20081215, fixed bufsize 32768, s/g segs 256
[   55.189648] device class 'scsi_tape': registering
[   55.194589] bus: 'scsi': add driver st
[   55.198502] initcall init_st+0x0/0xe2 returned 0 after 14720 usecs
[   55.204589] calling  init_sd+0x0/0xbd @ 1
[   55.208625] device class 'scsi_disk': registering
[   55.213489] bus: 'scsi': add driver sd
[   55.217379] initcall init_sd+0x0/0xbd returned 0 after 8621 usecs
[   55.223391] calling  init_ch_module+0x0/0x8c @ 1
[   55.227952] SCSI Media Changer driver v0.25=20
[   55.232199] device class 'scsi_changer': registering
[   55.237413] bus: 'scsi': add driver ch
[   55.241310] initcall init_ch_module+0x0/0x8c returned 0 after 13041 =
usecs
[   55.248010] calling  ahci_init+0x0/0x16 @ 1
[   55.252146] bus: 'pci': add driver ahci
[   55.256283] initcall ahci_init+0x0/0x16 returned 0 after 4038 usecs
[   55.262427] calling  piix_init+0x0/0x24 @ 1
[   55.266621] bus: 'pci': add driver ata_piix
[   55.271045] initcall piix_init+0x0/0x24 returned 0 after 4325 usecs
[   55.277214] calling  pdc_ata_init+0x0/0x16 @ 1
[   55.281621] bus: 'pci': add driver sata_promise
[   55.286441] initcall pdc_ata_init+0x0/0x16 returned 0 after 4704 use=
cs
[   55.292872] calling  qs_ata_init+0x0/0x16 @ 1
[   55.297186] bus: 'pci': add driver sata_qstor
[   55.301805] initcall qs_ata_init+0x0/0x16 returned 0 after 4515 usec=
s
[   55.308147] calling  sil_init+0x0/0x16 @ 1
[   55.312206] bus: 'pci': add driver sata_sil
[   55.316677] initcall sil_init+0x0/0x16 returned 0 after 4363 usecs
[   55.322757] calling  sil24_init+0x0/0x16 @ 1
[   55.326983] bus: 'pci': add driver sata_sil24
[   55.331604] initcall sil24_init+0x0/0x16 returned 0 after 4517 usecs
[   55.337864] calling  svia_init+0x0/0x16 @ 1
[   55.342011] bus: 'pci': add driver sata_via
[   55.346481] initcall svia_init+0x0/0x16 returned 0 after 4362 usecs
[   55.352646] calling  vsc_sata_init+0x0/0x16 @ 1
[   55.357135] bus: 'pci': add driver sata_vsc
[   55.361584] initcall vsc_sata_init+0x0/0x16 returned 0 after 4350 us=
ecs
[   55.368103] calling  sis_init+0x0/0x16 @ 1
[   55.372163] bus: 'pci': add driver sata_sis
[   55.376639] initcall sis_init+0x0/0x16 returned 0 after 4370 usecs
[   55.382722] calling  nv_init+0x0/0x16 @ 1
[   55.386689] bus: 'pci': add driver sata_nv
[   55.391594] initcall nv_init+0x0/0x16 returned 0 after 4795 usecs
[   55.397587] calling  ali_init+0x0/0x40 @ 1
[   55.401667] bus: 'pci': add driver pata_ali
[   55.406118] initcall ali_init+0x0/0x40 returned 0 after 4364 usecs
[   55.412181] calling  amd_init+0x0/0x16 @ 1
[   55.416285] bus: 'pci': add driver pata_amd
[   55.420448] bus: 'pci': driver_probe_device: matched device 0000:00:=
06.0 with driver pata_amd
[   55.428928] bus: 'pci': really_probe: probing driver pata_amd with d=
evice 0000:00:06.0
[   55.436839] pata_amd 0000:00:06.0: version 0.4.1
[   55.441580] pata_amd 0000:00:06.0: setting latency timer to 64
[   55.447618] scsi0 : pata_amd
[   55.450589] device: 'host0': device_add
[   55.454385] PM: Adding info for No Bus:host0
[   55.458565] device: 'host0': device_add
[   55.462603] PM: Adding info for No Bus:host0
[   55.467138] scsi1 : pata_amd
[   55.469918] device: 'host1': device_add
[   55.473786] PM: Adding info for No Bus:host1
[   55.477969] device: 'host1': device_add
[   55.481981] PM: Adding info for No Bus:host1
[   55.486398] ata1: PATA max UDMA/133 cmd 0x1f0 ctl 0x3f6 bmdma 0xf000=
 irq 14
[   55.493268] ata2: PATA max UDMA/133 cmd 0x170 ctl 0x376 bmdma 0xf008=
 irq 15
[   55.703045] ata1.00: ATA-6: HDS722525VLAT80, V36OA60A, max UDMA/100
[   55.709191] ata1.00: 488397168 sectors, multi 1: LBA48=20
[   55.714429] ata1: nv_mode_filter: 0x3f39f&0x3f07f->0x3f01f, BIOS=3D0=
x3f000 (0xc60000c0) ACPI=3D0x0
[   55.782980] ata1.00: configured for UDMA/100
[   55.787144] async_waiting @ 1
[   55.790080] async_continuing @ 1 after 2 usec
[   55.795384] scsi 0:0:0:0: Direct-Access     ATA      HDS722525VLAT80=
  V36O PQ: 0 ANSI: 5
[   55.803401] device: 'target0:0:0': device_add
[   55.807819] PM: Adding info for No Bus:target0:0:0
[   55.812547] device: '0:0:0:0': device_add
[   55.816656] bus: 'scsi': add device 0:0:0:0
[   55.820810] PM: Adding info for scsi:0:0:0:0
[   55.825412] bus: 'scsi': driver_probe_device: matched device 0:0:0:0=
 with driver st
[   55.833002] bus: 'scsi': really_probe: probing driver st with device=
 0:0:0:0
[   55.840093] bus: 'scsi': driver_probe_device: matched device 0:0:0:0=
 with driver sd
[   55.847669] bus: 'scsi': really_probe: probing driver sd with device=
 0:0:0:0
[   55.855048] device: '0:0:0:0': device_add
[   55.859125] PM: Adding info for No Bus:0:0:0:0
[   55.864051] sd 0:0:0:0: [sda] 488397168 512-byte logical blocks: (25=
0 GB/232 GiB)
[   55.871978] sd 0:0:0:0: [sda] Write Protect is off
[   55.876684] sd 0:0:0:0: [sda] Mode Sense: 00 3a 00 00
[   55.881963] sd 0:0:0:0: [sda] Write cache: enabled, read cache: enab=
led, doesn't support DPO or FUA
[   55.891043] device: 'sda': device_add
[   55.894862] PM: Adding info for No Bus:sda
[   55.900420]  sda: sda1 sda2 sda3 < sda5 sda6 sda7 sda8 sda9 sda10 >
[   55.982397] device: 'sda1': device_add
[   55.986450] PM: Adding info for No Bus:sda1
[   55.991009] device: 'sda2': device_add
[   55.994925] PM: Adding info for No Bus:sda2
[   55.999344] device: 'sda3': device_add
[   56.003273] PM: Adding info for No Bus:sda3
[   56.007682] device: 'sda5': device_add
[   56.011576] PM: Adding info for No Bus:sda5
[   56.016025] device: 'sda6': device_add
[   56.019947] PM: Adding info for No Bus:sda6
[   56.024404] device: 'sda7': device_add
[   56.028302] PM: Adding info for No Bus:sda7
[   56.032745] device: 'sda8': device_add
[   56.036876] PM: Adding info for No Bus:sda8
[   56.041305] device: 'sda9': device_add
[   56.045233] PM: Adding info for No Bus:sda9
[   56.049644] device: 'sda10': device_add
[   56.053680] PM: Adding info for No Bus:sda10
[   56.061402] device: '8:0': device_add
[   56.065102] PM: Adding info for No Bus:8:0
[   56.070553] sd 0:0:0:0: [sda] Attached SCSI disk
[   56.075069] driver: '0:0:0:0': driver_bound: bound to device 'sd'
[   56.081119] bus: 'scsi': really_probe: bound device 0:0:0:0 to drive=
r sd
[   56.088011] device: '0:0:0:0': device_add
[   56.092020] PM: Adding info for No Bus:0:0:0:0
[   56.097012] device: '0:0:0:0': device_add
[   56.101359] PM: Adding info for No Bus:0:0:0:0
[   56.106323] async_waiting @ 1
[   56.109177] async_continuing @ 1 after 2 usec
[   56.281264] ata2.01: ATAPI: DVDRW IDE 16X, VER A079, max UDMA/66
[   56.287180] ata2: nv_mode_filter: 0x1f39f&0x707f->0x701f, BIOS=3D0x7=
000 (0xc60000c0) ACPI=3D0x0
[   56.330209] ata2.01: configured for UDMA/33
[   56.334993] async_waiting @ 1
[   56.337848] async_continuing @ 1 after 2 usec
[   56.342764] scsi 1:0:1:0: CD-ROM            DVDRW    IDE 16X        =
  A079 PQ: 0 ANSI: 5
[   56.350769] device: 'target1:0:1': device_add
[   56.355176] PM: Adding info for No Bus:target1:0:1
[   56.359869] device: '1:0:1:0': device_add
[   56.364045] bus: 'scsi': add device 1:0:1:0
[   56.368185] PM: Adding info for scsi:1:0:1:0
[   56.372593] bus: 'scsi': driver_probe_device: matched device 1:0:1:0=
 with driver st
[   56.380146] bus: 'scsi': really_probe: probing driver st with device=
 1:0:1:0
[   56.387253] bus: 'scsi': driver_probe_device: matched device 1:0:1:0=
 with driver sd
[   56.394829] bus: 'scsi': really_probe: probing driver sd with device=
 1:0:1:0
[   56.401885] bus: 'scsi': driver_probe_device: matched device 1:0:1:0=
 with driver ch
[   56.409476] bus: 'scsi': really_probe: probing driver ch with device=
 1:0:1:0
[   56.416558] device: '1:0:1:0': device_add
[   56.420579] PM: Adding info for No Bus:1:0:1:0
[   56.425216] device: '1:0:1:0': device_add
[   56.429373] PM: Adding info for No Bus:1:0:1:0
[   56.434012] driver: '0000:00:06.0': driver_bound: bound to device 'p=
ata_amd'
[   56.440938] bus: 'pci': really_probe: bound device 0000:00:06.0 to d=
river pata_amd
[   56.448779] initcall amd_init+0x0/0x16 returned 0 after 1008294 usec=
s
[   56.455127] calling  atiixp_init+0x0/0x16 @ 1
[   56.459439] bus: 'pci': add driver pata_atiixp
[   56.464151] initcall atiixp_init+0x0/0x16 returned 0 after 4602 usec=
s
[   56.470472] calling  cmd640_init+0x0/0x16 @ 1
[   56.474835] bus: 'pci': add driver pata_cmd640
[   56.479501] initcall cmd640_init+0x0/0x16 returned 0 after 4562 usec=
s
[   56.485844] calling  cmd64x_init+0x0/0x16 @ 1
[   56.490160] bus: 'pci': add driver pata_cmd64x
[   56.494871] initcall cmd64x_init+0x0/0x16 returned 0 after 4599 usec=
s
[   56.501187] calling  cs5530_init+0x0/0x16 @ 1
[   56.505551] bus: 'pci': add driver pata_cs5530
[   56.510220] initcall cs5530_init+0x0/0x16 returned 0 after 4565 usec=
s
[   56.516563] calling  hpt37x_init+0x0/0x16 @ 1
[   56.520884] bus: 'pci': add driver pata_hpt37x
[   56.525597] initcall hpt37x_init+0x0/0x16 returned 0 after 4601 usec=
s
[   56.531911] calling  hpt3x3_init+0x0/0x16 @ 1
[   56.536272] bus: 'pci': add driver pata_hpt3x3
[   56.540942] initcall hpt3x3_init+0x0/0x16 returned 0 after 4566 usec=
s
[   56.547279] calling  isapnp_init+0x0/0xf @ 1
[   56.551510] bus: 'pnp': add driver pata_isapnp
[   56.556208] initcall isapnp_init+0x0/0xf returned 0 after 4584 usecs
[   56.562444] calling  it8213_init+0x0/0x16 @ 1
[   56.566806] bus: 'pci': add driver pata_it8213
[   56.571478] initcall it8213_init+0x0/0x16 returned 0 after 4567 usec=
s
[   56.577820] calling  jmicron_init+0x0/0x16 @ 1
[   56.582227] bus: 'pci': add driver pata_jmicron
[   56.587030] initcall jmicron_init+0x0/0x16 returned 0 after 4689 use=
cs
[   56.593463] calling  netcell_init+0x0/0x16 @ 1
[   56.597863] bus: 'pci': add driver pata_netcell
[   56.602687] initcall netcell_init+0x0/0x16 returned 0 after 4709 use=
cs
[   56.609089] calling  ninja32_init+0x0/0x16 @ 1
[   56.613539] bus: 'pci': add driver pata_ninja32
[   56.618292] initcall ninja32_init+0x0/0x16 returned 0 after 4647 use=
cs
[   56.624722] calling  ns87415_init+0x0/0x16 @ 1
[   56.629123] bus: 'pci': add driver pata_ns87415
[   56.633926] initcall ns87415_init+0x0/0x16 returned 0 after 4689 use=
cs
[   56.640332] calling  opti_init+0x0/0x16 @ 1
[   56.644572] bus: 'pci': add driver pata_opti
[   56.649013] initcall opti_init+0x0/0x16 returned 0 after 4343 usecs
[   56.655186] calling  optidma_init+0x0/0x16 @ 1
[   56.659588] bus: 'pci': add driver pata_optidma
[   56.664385] initcall optidma_init+0x0/0x16 returned 0 after 4684 use=
cs
[   56.670788] calling  marvell_init+0x0/0x16 @ 1
[   56.675257] bus: 'pci': add driver pata_marvell
[   56.679998] initcall marvell_init+0x0/0x16 returned 0 after 4635 use=
cs
[   56.686430] calling  oldpiix_init+0x0/0x16 @ 1
[   56.690831] bus: 'pci': add driver pata_oldpiix
[   56.695617] initcall oldpiix_init+0x0/0x16 returned 0 after 4672 use=
cs
[   56.702022] calling  pdc2027x_init+0x0/0x16 @ 1
[   56.706568] bus: 'pci': add driver pata_pdc2027x
[   56.711400] initcall pdc2027x_init+0x0/0x16 returned 0 after 4724 us=
ecs
[   56.717910] calling  pdc202xx_init+0x0/0x16 @ 1
[   56.722404] bus: 'pci': add driver pata_pdc202xx_old
[   56.727644] initcall pdc202xx_init+0x0/0x16 returned 0 after 5115 us=
ecs
[   56.734159] calling  qdi_init+0x0/0x1d4 @ 1
[   56.738299] initcall qdi_init+0x0/0x1d4 returned -19 after 1 usecs
[   56.744466] calling  radisys_init+0x0/0x16 @ 1
[   56.748873] bus: 'pci': add driver pata_radisys
[   56.753667] initcall radisys_init+0x0/0x16 returned 0 after 4680 use=
cs
[   56.760072] calling  sc1200_init+0x0/0x16 @ 1
[   56.764435] bus: 'pci': add driver sc1200
[   56.768672] initcall sc1200_init+0x0/0x16 returned 0 after 4143 usec=
s
[   56.775021] calling  sil680_init+0x0/0x16 @ 1
[   56.779336] bus: 'pci': add driver pata_sil680
[   56.784040] initcall sil680_init+0x0/0x16 returned 0 after 4593 usec=
s
[   56.790363] calling  sl82c105_init+0x0/0x16 @ 1
[   56.795438] bus: 'pci': add driver pata_sl82c105
[   56.800288] initcall sl82c105_init+0x0/0x16 returned 0 after 4743 us=
ecs
[   56.806805] calling  winbond_init+0x0/0xca @ 1
[   56.811211] initcall winbond_init+0x0/0xca returned -19 after 1 usec=
s
[   56.817642] calling  sis_init+0x0/0x16 @ 1
[   56.821701] bus: 'pci': add driver pata_sis
[   56.826151] initcall sis_init+0x0/0x16 returned 0 after 4346 usecs
[   56.832207] calling  triflex_init+0x0/0x16 @ 1
[   56.836656] bus: 'pci': add driver pata_triflex
[   56.841417] initcall triflex_init+0x0/0x16 returned 0 after 4655 use=
cs
[   56.847842] calling  ata_generic_init+0x0/0x16 @ 1
[   56.852618] bus: 'pci': add driver ata_generic
[   56.857296] initcall ata_generic_init+0x0/0x16 returned 0 after 4574=
 usecs
[   56.864074] calling  legacy_init+0x0/0x1f5 @ 1
[   56.868654] initcall legacy_init+0x0/0x1f5 returned -19 after 178 us=
ecs
[   56.875168] calling  e1000_init_module+0x0/0x6e @ 1
[   56.880009] Intel(R) PRO/1000 Network Driver - version 7.3.21-k3-NAP=
I
[   56.886433] Copyright (c) 1999-2006 Intel Corporation.
[   56.891534] bus: 'pci': add driver e1000
[   56.895732] initcall e1000_init_module+0x0/0x6e returned 0 after 153=
49 usecs
[   56.902685] calling  e1000_init_module+0x0/0x53 @ 1
[   56.907514] e1000e: Intel(R) PRO/1000 Network Driver - 1.0.2-k2
[   56.913422] e1000e: Copyright (c) 1999-2008 Intel Corporation.
[   56.919216] bus: 'pci': add driver e1000e
[   56.923549] initcall e1000_init_module+0x0/0x53 returned 0 after 156=
55 usecs
[   56.930479] calling  igbvf_init_module+0x0/0x53 @ 1
[   56.935378] Intel(R) Virtual Function Network Driver - version 1.0.0=
-k0
[   56.941918] Copyright (c) 2009 Intel Corporation.
[   56.946621] bus: 'pci': add driver igbvf
[   56.950782] initcall igbvf_init_module+0x0/0x53 returned 0 after 150=
44 usecs
[   56.957734] calling  ipg_init_module+0x0/0x16 @ 1
[   56.962397] bus: 'pci': add driver Sundance Technology IPG Triple-Sp=
eed Ethernet
[   56.970064] initcall ipg_init_module+0x0/0x16 returned 0 after 7487 =
usecs
[   56.976757] calling  can_dev_init+0x0/0x26 @ 1
[   56.981157] CAN device driver interface
[   56.984987] initcall can_dev_init+0x0/0x26 returned 0 after 3736 use=
cs
[   56.991466] calling  bonding_init+0x0/0xb5 @ 1
[   56.995905] Ethernet Channel Bonding Driver: v3.5.0 (November 4, 200=
8)
[   57.002387] bonding: Warning: either miimon or arp_interval and arp_=
ip_target module parameters must be specified, otherwise bonding will n=
ot detect link failures! see bonding.txt for details.
[   57.019714] device: 'bond0': device_add
[   57.023797] PM: Adding info for No Bus:bond0
[   57.028486] initcall bonding_init+0x0/0xb5 returned 0 after 31819 us=
ecs
[   57.035006] calling  atl1_init_module+0x0/0x16 @ 1
[   57.039757] bus: 'pci': add driver atl1
[   57.043860] initcall atl1_init_module+0x0/0x16 returned 0 after 4006=
 usecs
[   57.050608] calling  atl2_init_module+0x0/0x39 @ 1
[   57.055402] Atheros(R) L2 Ethernet Driver - version 2.2.3
[   57.060749] Copyright (c) 2007 Atheros Corporation.
[   57.065624] bus: 'pci': add driver atl2
[   57.069696] initcall atl2_init_module+0x0/0x39 returned 0 after 1396=
0 usecs
[   57.076564] calling  jme_init_module+0x0/0x25 @ 1
[   57.081222] jme: JMicron JMC2XX ethernet driver version 1.0.4
[   57.086961] bus: 'pci': add driver jme
[   57.090934] initcall jme_init_module+0x0/0x25 returned 0 after 9481 =
usecs
[   57.097624] calling  plip_init+0x0/0x52 @ 1
[   57.101767] initcall plip_init+0x0/0x52 returned 0 after 3 usecs
[   57.107759] calling  happy_meal_probe+0x0/0x16 @ 1
[   57.112530] bus: 'pci': add driver hme
[   57.116509] initcall happy_meal_probe+0x0/0x16 returned 0 after 3890=
 usecs
[   57.123288] calling  gem_init+0x0/0x16 @ 1
[   57.127343] bus: 'pci': add driver gem
[   57.131343] initcall gem_init+0x0/0x16 returned 0 after 3911 usecs
[   57.137425] calling  cas_init+0x0/0x33 @ 1
[   57.141487] bus: 'pci': add driver cassini
[   57.145854] initcall cas_init+0x0/0x33 returned 0 after 4264 usecs
[   57.151914] calling  vortex_init+0x0/0x9c @ 1
[   57.156278] bus: 'pci': add driver 3c59x
[   57.160436] initcall vortex_init+0x0/0x9c returned 0 after 4065 usec=
s
[   57.166780] calling  ne2k_pci_init+0x0/0x16 @ 1
[   57.171275] bus: 'pci': add driver ne2k-pci
[   57.175721] initcall ne2k_pci_init+0x0/0x16 returned 0 after 4341 us=
ecs
[   57.182214] calling  e100_init_module+0x0/0x4d @ 1
[   57.187006] e100: Intel(R) PRO/100 Network Driver, 3.5.24-k2-NAPI
[   57.193063] e100: Copyright(c) 1999-2006 Intel Corporation
[   57.198512] bus: 'pci': add driver e100
[   57.202607] initcall e100_init_module+0x0/0x4d returned 0 after 1523=
2 usecs
[   57.209445] calling  tlan_probe+0x0/0xc5 @ 1
[   57.213713] ThunderLAN driver v1.15a
[   57.217251] bus: 'pci': add driver tlan
[   57.221334] TLAN: 0 devices installed, PCI: 0  EISA: 0
[   57.226405] bus: 'pci': remove driver tlan
[   57.230649] driver: 'tlan': driver_release
[   57.234662] initcall tlan_probe+0x0/0xc5 returned -19 after 20456 us=
ecs
[   57.241217] calling  epic_init+0x0/0x16 @ 1
[   57.245405] bus: 'pci': add driver epic100
[   57.249729] initcall epic_init+0x0/0x16 returned 0 after 4229 usecs
[   57.255913] calling  sis190_init_module+0x0/0x16 @ 1
[   57.260829] bus: 'pci': add driver sis190
[   57.265110] initcall sis190_init_module+0x0/0x16 returned 0 after 41=
80 usecs
[   57.272036] calling  tg3_init+0x0/0x16 @ 1
[   57.276142] bus: 'pci': add driver tg3
[   57.280201] initcall tg3_init+0x0/0x16 returned 0 after 3970 usecs
[   57.286276] calling  bnx2_init+0x0/0x16 @ 1
[   57.290426] bus: 'pci': add driver bnx2
[   57.294528] initcall bnx2_init+0x0/0x16 returned 0 after 4006 usecs
[   57.300671] calling  marvell_init+0x0/0x46 @ 1
[   57.305119] bus: 'mdio_bus': add driver Marvell 88E1101
[   57.310543] bus: 'mdio_bus': add driver Marvell 88E1112
[   57.315909] bus: 'mdio_bus': add driver Marvell 88E1111
[   57.321261] bus: 'mdio_bus': add driver Marvell 88E1118
[   57.326631] bus: 'mdio_bus': add driver Marvell 88E1121R
[   57.332063] bus: 'mdio_bus': add driver Marvell 88E1145
[   57.337436] bus: 'mdio_bus': add driver Marvell 88E1240
[   57.342813] initcall marvell_init+0x0/0x46 returned 0 after 36810 us=
ecs
[   57.349310] calling  davicom_init+0x0/0x4d @ 1
[   57.353759] bus: 'mdio_bus': add driver Davicom DM9161E
[   57.359177] bus: 'mdio_bus': add driver Davicom DM9161A
[   57.364564] bus: 'mdio_bus': add driver Davicom DM9131
[   57.369821] initcall davicom_init+0x0/0x4d returned 0 after 15688 us=
ecs
[   57.376340] calling  lxt_init+0x0/0x33 @ 1
[   57.380392] bus: 'mdio_bus': add driver LXT970
[   57.385071] bus: 'mdio_bus': add driver LXT971
[   57.389639] initcall lxt_init+0x0/0x33 returned 0 after 9030 usecs
[   57.395731] calling  qs6612_init+0x0/0xf @ 1
[   57.399952] bus: 'mdio_bus': add driver QS6612
[   57.404630] initcall qs6612_init+0x0/0xf returned 0 after 4563 usecs
[   57.410861] calling  vsc82xx_init+0x0/0x33 @ 1
[   57.415313] bus: 'mdio_bus': add driver Vitesse VSC8244
[   57.420727] bus: 'mdio_bus': add driver Vitesse VSC8221
[   57.426105] initcall vsc82xx_init+0x0/0x33 returned 0 after 10538 us=
ecs
[   57.432621] calling  broadcom_init+0x0/0xdb @ 1
[   57.437106] bus: 'mdio_bus': add driver Broadcom BCM5411
[   57.442667] bus: 'mdio_bus': add driver Broadcom BCM5421
[   57.448115] bus: 'mdio_bus': add driver Broadcom BCM5461
[   57.453583] bus: 'mdio_bus': add driver Broadcom BCM5464
[   57.459015] bus: 'mdio_bus': add driver Broadcom BCM5481
[   57.464483] bus: 'mdio_bus': add driver Broadcom BCM5482
[   57.469914] bus: 'mdio_bus': add driver Broadcom BCM50610
[   57.475553] bus: 'mdio_bus': add driver Broadcom BCM57780
[   57.481072] initcall broadcom_init+0x0/0xdb returned 0 after 42934 u=
secs
[   57.487697] calling  ip175c_init+0x0/0xf @ 1
[   57.491908] bus: 'mdio_bus': add driver ICPlus IP175C
[   57.497199] initcall ip175c_init+0x0/0xf returned 0 after 5162 usecs
[   57.503500] calling  realtek_init+0x0/0xf @ 1
[   57.507767] bus: 'mdio_bus': add driver RTL821x Gigabit Ethernet
[   57.514007] initcall realtek_init+0x0/0xf returned 0 after 6089 usec=
s
[   57.520322] calling  et1011c_init+0x0/0xf @ 1
[   57.524683] bus: 'mdio_bus': add driver ET1011C
[   57.529411] initcall et1011c_init+0x0/0xf returned 0 after 4619 usec=
s
[   57.535771] calling  fixed_mdio_bus_init+0x0/0xae @ 1
[   57.540771] Registering platform device 'Fixed MDIO bus.0'. Parent a=
t platform
[   57.547974] device: 'Fixed MDIO bus.0': device_add
[   57.552758] bus: 'platform': add device Fixed MDIO bus.0
[   57.558064] PM: Adding info for platform:Fixed MDIO bus.0
[   57.563633] device: '0': device_add
[   57.567082] PM: Adding info for No Bus:0
[   57.571155] Fixed MDIO Bus: probed
[   57.574473] initcall fixed_mdio_bus_init+0x0/0xae returned 0 after 3=
2916 usecs
[   57.581640] calling  ns_init+0x0/0xf @ 1
[   57.585560] bus: 'mdio_bus': add driver NatSemi DP83865
[   57.590987] initcall ns_init+0x0/0xf returned 0 after 5303 usecs
[   57.596910] calling  sundance_init+0x0/0x16 @ 1
[   57.601392] bus: 'pci': add driver sundance
[   57.605844] initcall sundance_init+0x0/0x16 returned 0 after 4349 us=
ecs
[   57.612337] calling  hamachi_init+0x0/0x16 @ 1
[   57.616789] bus: 'pci': add driver hamachi
[   57.621110] initcall hamachi_init+0x0/0x16 returned 0 after 4226 use=
cs
[   57.627543] calling  net_olddevs_init+0x0/0x27 @ 1
[   57.633030] initcall net_olddevs_init+0x0/0x27 returned 0 after 717 =
usecs
[   57.639698] calling  sb1000_init+0x0/0xf @ 1
[   57.643965] bus: 'pnp': add driver sb1000
[   57.648195] initcall sb1000_init+0x0/0xf returned 0 after 4133 usecs
[   57.654457] calling  hp100_module_init+0x0/0x16 @ 1
[   57.659295] bus: 'pci': add driver hp100
[   57.663480] initcall hp100_module_init+0x0/0x16 returned 0 after 408=
8 usecs
[   57.670318] calling  b44_init+0x0/0x55 @ 1
[   57.674540] bus: 'pci': add driver b44
[   57.678445] bus: 'ssb': add driver b44
[   57.682328] initcall b44_init+0x0/0x55 returned 0 after 7615 usecs
[   57.688412] calling  init_nic+0x0/0x16 @ 1
[   57.692470] bus: 'pci': add driver forcedeth
[   57.696773] bus: 'pci': driver_probe_device: matched device 0000:00:=
0a.0 with driver forcedeth
[   57.705307] bus: 'pci': really_probe: probing driver forcedeth with =
device 0000:00:0a.0
[   57.713889] forcedeth: Reverse Engineered nForce ethernet driver. Ve=
rsion 0.64.
[   57.724366] ACPI: PCI Interrupt Link [APCH] enabled at IRQ 23
[   57.729999] IOAPIC[0]: Set routing entry (2-23 -> 0x49 -> IRQ 23 Mod=
e:1 Active:1)
[   57.737467] forcedeth 0000:00:0a.0: PCI INT A -> Link[APCH] -> GSI 2=
3 (level, low) -> IRQ 23
[   57.745878] forcedeth 0000:00:0a.0: setting latency timer to 64
[   57.751861] nv_probe: set workaround bit for reversed mac addr
[   58.282710] device: 'eth0': device_add
[   58.286819] PM: Adding info for No Bus:eth0
[   58.291281] forcedeth 0000:00:0a.0: ifname eth0, PHY OUI 0x5043 @ 1,=
 addr 00:13:d4:dc:41:12
[   58.299564] forcedeth 0000:00:0a.0: highdma csum gbit lnktim desc-v3
[   58.305891] driver: '0000:00:0a.0': driver_bound: bound to device 'f=
orcedeth'
[   58.312995] bus: 'pci': really_probe: bound device 0000:00:0a.0 to d=
river forcedeth
[   58.320865] initcall init_nic+0x0/0x16 returned 0 after 613671 usecs
[   58.327178] calling  ql3xxx_init_module+0x0/0x16 @ 1
[   58.332054] bus: 'pci': add driver qla3xxx
[   58.336417] initcall ql3xxx_init_module+0x0/0x16 returned 0 after 42=
64 usecs
[   58.343371] calling  slip_init+0x0/0x99 @ 1
[   58.347508] SLIP: version 0.8.4-NET3.019-NEWTTY (dynamic channels, m=
ax=3D256) (6 bit encapsulation enabled).
[   58.357141] CSLIP: code copyright 1989 Regents of the University of =
California.
[   58.364430] initcall slip_init+0x0/0x99 returned 0 after 16520 usecs
[   58.370733] calling  netif_init+0x0/0x47 @ 1
[   58.375000] initcall netif_init+0x0/0x47 returned -19 after 1 usecs
[   58.381220] calling  dummy_init_module+0x0/0x95 @ 1
[   58.386151] device: 'dummy0': device_add
[   58.390291] PM: Adding info for No Bus:dummy0
[   58.394828] initcall dummy_init_module+0x0/0x95 returned 0 after 852=
9 usecs
[   58.401664] calling  macvlan_init_module+0x0/0x45 @ 1
[   58.406742] initcall macvlan_init_module+0x0/0x45 returned 0 after 4=
 usecs
[   58.413556] calling  de600_init+0x0/0x1c @ 1
[   58.417805] eth%d: D-Link DE-600 pocket adapter: not at I/O 0x378.
[   58.423970] initcall de600_init+0x0/0x1c returned -19 after 6033 use=
cs
[   58.430438] calling  cp_init+0x0/0x16 @ 1
[   58.434451] bus: 'pci': add driver 8139cp
[   58.438450] bus: 'pci': driver_probe_device: matched device 0000:05:=
07.0 with driver 8139cp
[   58.446749] bus: 'pci': really_probe: probing driver 8139cp with dev=
ice 0000:05:07.0
[   58.454488] <6>8139cp: 10/100 PCI Ethernet driver v1.3 (Mar 22, 2004=
)
[   58.460858] 8139cp 0000:05:07.0: This (id 10ec:8139 rev 10) is not a=
n 8139C+ compatible chip, use 8139too
[   58.470668] initcall cp_init+0x0/0x16 returned 0 after 35374 usecs
[   58.476751] calling  rtl8139_init_module+0x0/0x16 @ 1
[   58.481762] bus: 'pci': add driver 8139too
[   58.485882] bus: 'pci': driver_probe_device: matched device 0000:05:=
07.0 with driver 8139too
[   58.494251] bus: 'pci': really_probe: probing driver 8139too with de=
vice 0000:05:07.0
[   58.502058] 8139too Fast Ethernet driver 0.9.28
[   58.507998] ACPI: PCI Interrupt Link [APC2] enabled at IRQ 17
[   58.513653] IOAPIC[0]: Set routing entry (2-17 -> 0x51 -> IRQ 17 Mod=
e:1 Active:1)
[   58.521079] 8139too 0000:05:07.0: PCI INT A -> Link[APC2] -> GSI 17 =
(level, low) -> IRQ 17
[   58.529611] device: 'eth1': device_add
[   58.533687] PM: Adding info for No Bus:eth1
[   58.538085] eth1: RealTek RTL8139 at 0xf8c78000, 00:c0:df:03:68:5d, =
IRQ 17
[   58.544880] driver: '0000:05:07.0': driver_bound: bound to device '8=
139too'
[   58.551772] bus: 'pci': really_probe: bound device 0000:05:07.0 to d=
river 8139too
[   58.559487] initcall rtl8139_init_module+0x0/0x16 returned 0 after 7=
5904 usecs
[   58.566722] calling  depca_module_init+0x0/0xb4 @ 1
[   58.571486] bus: 'platform': add driver depca
[   58.576116] Registering platform device 'depca.0'. Parent at platfor=
m
[   58.582441] device: 'depca.0': device_add
[   58.586470] bus: 'platform': add device depca.0
[   58.590985] PM: Adding info for platform:depca.0
[   58.595760] bus: 'platform': driver_probe_device: matched device dep=
ca.0 with driver depca
[   58.603944] bus: 'platform': really_probe: probing driver depca with=
 device depca.0
[   58.611625] PM: Removing info for platform:depca.0
[   58.616383] bus: 'platform': remove device depca.0
[   58.621317] Registering platform device 'depca.1'. Parent at platfor=
m
[   58.627671] device: 'depca.1': device_add
[   58.631649] bus: 'platform': add device depca.1
[   58.636207] PM: Adding info for platform:depca.1
[   58.640947] bus: 'platform': driver_probe_device: matched device dep=
ca.1 with driver depca
[   58.649161] bus: 'platform': really_probe: probing driver depca with=
 device depca.1
[   58.656838] PM: Removing info for platform:depca.1
[   58.661561] bus: 'platform': remove device depca.1
[   58.666524] initcall depca_module_init+0x0/0xb4 returned 0 after 928=
07 usecs
[   58.673479] calling  atp_init_module+0x0/0x86 @ 1
[   58.678136] atp.c:v1.09=3Dac 2002/10/01 Donald Becker <becker@scyld.=
com>
[   58.684685] initcall atp_init_module+0x0/0x86 returned -19 after 639=
0 usecs
[   58.691567] calling  sc92031_init+0x0/0x16 @ 1
[   58.696014] bus: 'pci': add driver sc92031
[   58.700343] initcall sc92031_init+0x0/0x16 returned 0 after 4236 use=
cs
[   58.706795] calling  eql_init_module+0x0/0x50 @ 1
[   58.711434] Equalizer2002: Simon Janes (simon@ncm.com) and David S. =
Miller (davem@redhat.com)
[   58.719971] device: 'eql': device_add
[   58.723913] PM: Adding info for No Bus:eql
[   58.728174] initcall eql_init_module+0x0/0x50 returned 0 after 16345=
 usecs
[   58.734954] calling  tun_init+0x0/0x79 @ 1
[   58.739003] tun: Universal TUN/TAP device driver, 1.6
[   58.744044] tun: (C) 1999-2004 Max Krasnyansky <maxk@qualcomm.com>
[   58.750198] device: 'tun': device_add
[   58.754090] PM: Adding info for No Bus:tun
[   58.758296] initcall tun_init+0x0/0x79 returned 0 after 18838 usecs
[   58.764474] calling  veth_init+0x0/0xf @ 1
[   58.768527] initcall veth_init+0x0/0xf returned 0 after 3 usecs
[   58.774432] calling  rio_init+0x0/0x16 @ 1
[   58.778498] bus: 'pci': add driver dl2k
[   58.782594] initcall rio_init+0x0/0x16 returned 0 after 4003 usecs
[   58.788654] calling  amd8111e_init+0x0/0x16 @ 1
[   58.793189] bus: 'pci': add driver amd8111e
[   58.797596] initcall amd8111e_init+0x0/0x16 returned 0 after 4311 us=
ecs
[   58.804112] calling  mlx4_init+0x0/0x9a @ 1
[   58.808351] bus: 'pci': add driver mlx4_core
[   58.812800] initcall mlx4_init+0x0/0x9a returned 0 after 4437 usecs
[   58.818944] calling  dnet_init+0x0/0xf @ 1
[   58.823046] bus: 'platform': add driver dnet
[   58.827518] initcall dnet_init+0x0/0xf returned 0 after 4372 usecs
[   58.833602] calling  streamer_init_module+0x0/0x16 @ 1
[   58.838704] bus: 'pci': add driver lanstreamer
[   58.843407] initcall streamer_init_module+0x0/0x16 returned 0 after =
4593 usecs
[   58.850533] calling  abyss_init+0x0/0x3f @ 1
[   58.854819] bus: 'pci': add driver abyss
[   58.858962] initcall abyss_init+0x0/0x3f returned 0 after 4054 usecs
[   58.865222] calling  proteon_init+0x0/0x101 @ 1
[   58.869709] bus: 'platform': add driver proteon
[   58.874510] Registering platform device 'proteon.0'. Parent at platf=
orm
[   58.881009] device: 'proteon.0': device_add
[   58.885213] bus: 'platform': add device proteon.0
[   58.889906] PM: Adding info for platform:proteon.0
[   58.894855] bus: 'platform': driver_probe_device: matched device pro=
teon.0 with driver proteon
[   58.903390] bus: 'platform': really_probe: probing driver proteon wi=
th device proteon.0
[   58.911366] driver: 'proteon.0': driver_bound: bound to device 'prot=
eon'
[   58.918032] bus: 'platform': really_probe: bound device proteon.0 to=
 driver proteon
[   58.925934] PM: Removing info for platform:proteon.0
[   58.930834] bus: 'platform': remove device proteon.0
[   58.936009] Registering platform device 'proteon.1'. Parent at platf=
orm
[   58.942525] device: 'proteon.1': device_add
[   58.946678] bus: 'platform': add device proteon.1
[   58.951393] PM: Adding info for platform:proteon.1
[   58.956336] bus: 'platform': driver_probe_device: matched device pro=
teon.1 with driver proteon
[   58.964926] bus: 'platform': really_probe: probing driver proteon wi=
th device proteon.1
[   58.972873] driver: 'proteon.1': driver_bound: bound to device 'prot=
eon'
[   58.979504] bus: 'platform': really_probe: bound device proteon.1 to=
 driver proteon
[   58.987409] PM: Removing info for platform:proteon.1
[   58.992305] bus: 'platform': remove device proteon.1
[   58.997490] Registering platform device 'proteon.2'. Parent at platf=
orm
[   59.004008] device: 'proteon.2': device_add
[   59.008159] bus: 'platform': add device proteon.2
[   59.012897] PM: Adding info for platform:proteon.2
[   59.017801] bus: 'platform': driver_probe_device: matched device pro=
teon.2 with driver proteon
[   59.026391] bus: 'platform': really_probe: probing driver proteon wi=
th device proteon.2
[   59.034338] driver: 'proteon.2': driver_bound: bound to device 'prot=
eon'
[   59.040968] bus: 'platform': really_probe: bound device proteon.2 to=
 driver proteon
[   59.048874] PM: Removing info for platform:proteon.2
[   59.053785] bus: 'platform': remove device proteon.2
[   59.058906] proteon.c: 0 cards found.
[   59.062450] proteon.c: No cards found.
[   59.066223] bus: 'platform': remove driver proteon
[   59.071161] driver: 'proteon': driver_release
[   59.075430] initcall proteon_init+0x0/0x101 returned -19 after 20089=
6 usecs
[   59.082335] calling  sk_isa_init+0x0/0x101 @ 1
[   59.086833] bus: 'platform': add driver skisa
[   59.091354] Registering platform device 'skisa.0'. Parent at platfor=
m
[   59.097705] device: 'skisa.0': device_add
[   59.102247] bus: 'platform': add device skisa.0
[   59.106806] PM: Adding info for platform:skisa.0
[   59.111543] bus: 'platform': driver_probe_device: matched device ski=
sa.0 with driver skisa
[   59.119734] bus: 'platform': really_probe: probing driver skisa with=
 device skisa.0
[   59.127376] driver: 'skisa.0': driver_bound: bound to device 'skisa'
[   59.133677] bus: 'platform': really_probe: bound device skisa.0 to d=
river skisa
[   59.141027] PM: Removing info for platform:skisa.0
[   59.145772] bus: 'platform': remove device skisa.0
[   59.150745] Registering platform device 'skisa.1'. Parent at platfor=
m
[   59.157098] device: 'skisa.1': device_add
[   59.161078] bus: 'platform': add device skisa.1
[   59.165637] PM: Adding info for platform:skisa.1
[   59.170373] bus: 'platform': driver_probe_device: matched device ski=
sa.1 with driver skisa
[   59.178590] bus: 'platform': really_probe: probing driver skisa with=
 device skisa.1
[   59.186206] driver: 'skisa.1': driver_bound: bound to device 'skisa'
[   59.192490] bus: 'platform': really_probe: bound device skisa.1 to d=
river skisa
[   59.199874] PM: Removing info for platform:skisa.1
[   59.204613] bus: 'platform': remove device skisa.1
[   59.209584] Registering platform device 'skisa.2'. Parent at platfor=
m
[   59.215935] device: 'skisa.2': device_add
[   59.219914] bus: 'platform': add device skisa.2
[   59.224477] PM: Adding info for platform:skisa.2
[   59.229210] bus: 'platform': driver_probe_device: matched device ski=
sa.2 with driver skisa
[   59.237431] bus: 'platform': really_probe: probing driver skisa with=
 device skisa.2
[   59.245044] driver: 'skisa.2': driver_bound: bound to device 'skisa'
[   59.251329] bus: 'platform': really_probe: bound device skisa.2 to d=
river skisa
[   59.258710] PM: Removing info for platform:skisa.2
[   59.263451] bus: 'platform': remove device skisa.2
[   59.268395] skisa.c: 0 cards found.
[   59.271762] skisa.c: No cards found.
[   59.275360] bus: 'platform': remove driver skisa
[   59.280239] driver: 'skisa': driver_release
[   59.284334] initcall sk_isa_init+0x0/0x101 returned -19 after 192871=
 usecs
[   59.291153] calling  hdlc_module_init+0x0/0x37 @ 1
[   59.295972] HDLC support module revision 1.22
[   59.300262] initcall hdlc_module_init+0x0/0x37 returned 0 after 4191=
 usecs
[   59.307118] calling  mod_init+0x0/0x11 @ 1
[   59.311179] initcall mod_init+0x0/0x11 returned 0 after 2 usecs
[   59.317085] calling  mod_init+0x0/0x11 @ 1
[   59.321146] initcall mod_init+0x0/0x11 returned 0 after 2 usecs
[   59.327053] calling  mod_init+0x0/0x11 @ 1
[   59.331114] initcall mod_init+0x0/0x11 returned 0 after 2 usecs
[   59.337018] calling  mod_init+0x0/0x43 @ 1
[   59.341079] initcall mod_init+0x0/0x43 returned 0 after 2 usecs
[   59.346984] calling  mod_init+0x0/0x11 @ 1
[   59.351047] initcall mod_init+0x0/0x11 returned 0 after 2 usecs
[   59.356952] calling  init_lmc+0x0/0x16 @ 1
[   59.361018] bus: 'pci': add driver lmc
[   59.365024] initcall init_lmc+0x0/0x16 returned 0 after 3915 usecs
[   59.371088] calling  lapbeth_init_driver+0x0/0x25 @ 1
[   59.376144] LAPB Ethernet driver version 0.02
[   59.380451] initcall lapbeth_init_driver+0x0/0x25 returned 0 after 4=
209 usecs
[   59.387571] calling  n2_init+0x0/0x124 @ 1
[   59.391632] initcall n2_init+0x0/0x124 returned -22 after 1 usecs
[   59.397712] initcall n2_init+0x0/0x124 returned with error code -22=20
[   59.404037] calling  c101_init+0x0/0xa4 @ 1
[   59.408186] initcall c101_init+0x0/0xa4 returned -22 after 1 usecs
[   59.414352] initcall c101_init+0x0/0xa4 returned with error code -22=
=20
[   59.420747] calling  arcnet_init+0x0/0x50 @ 1
[   59.425100] arcnet loaded.
[   59.427772] initcall arcnet_init+0x0/0x50 returned 0 after 2610 usec=
s
[   59.434199] calling  arcnet_rfc1201_init+0x0/0x65 @ 1
[   59.439209] arcnet: RFC1201 "standard" (`a') encapsulation support l=
oaded.
[   59.446074] initcall arcnet_rfc1201_init+0x0/0x65 returned 0 after 6=
698 usecs
[   59.453178] calling  arcnet_raw_init+0x0/0x52 @ 1
[   59.457842] arcnet: raw mode (`r') encapsulation support loaded.
[   59.463841] initcall arcnet_raw_init+0x0/0x52 returned 0 after 5853 =
usecs
[   59.470580] calling  arc_rimi_init+0x0/0x73 @ 1
[   59.475120] arcnet: RIM I (entirely mem-mapped) support
[   59.480287] E-mail me if you actually test the RIM I driver, please!
[   59.486631]  arc%d: Given: node 00h, shmem 0h, irq 0
[   59.491554]  arc%d: No autoprobe for RIM I; you must specify the shm=
em and irq!
[   59.498860] initcall arc_rimi_init+0x0/0x73 returned -5 after 23196 =
usecs
[   59.505612] initcall arc_rimi_init+0x0/0x73 returned with error code=
 -5=20
[   59.512268] calling  kaweth_init+0x0/0x16 @ 1
[   59.516622] bus: 'usb': add driver kaweth
[   59.520831] usbcore: registered new interface driver kaweth
[   59.526319] initcall kaweth_init+0x0/0x16 returned 0 after 9470 usec=
s
[   59.532713] calling  pegasus_init+0x0/0x3b @ 1
[   59.537118] pegasus: v0.6.14 (2006/09/27), Pegasus/Pegasus II USB Et=
hernet driver
[   59.544586] bus: 'usb': add driver pegasus
[   59.548878] usbcore: registered new interface driver pegasus
[   59.554462] initcall pegasus_init+0x0/0x3b returned 0 after 16933 us=
ecs
[   59.561010] calling  usb_rtl8150_init+0x0/0x20 @ 1
[   59.565795] rtl8150: v0.6.2 (2004/08/27):rtl8150 based usb-ethernet =
driver
[   59.572641] bus: 'usb': add driver rtl8150
[   59.576934] usbcore: registered new interface driver rtl8150
[   59.582484] initcall usb_rtl8150_init+0x0/0x20 returned 0 after 1630=
4 usecs
[   59.589435] calling  asix_init+0x0/0x16 @ 1
[   59.593591] bus: 'usb': add driver asix
[   59.597630] usbcore: registered new interface driver asix
[   59.602947] initcall asix_init+0x0/0x16 returned 0 after 9136 usecs
[   59.609153] calling  cdc_init+0x0/0x16 @ 1
[   59.613247] bus: 'usb': add driver cdc_ether
[   59.617716] usbcore: registered new interface driver cdc_ether
[   59.623462] initcall cdc_init+0x0/0x16 returned 0 after 9976 usecs
[   59.629581] calling  eem_init+0x0/0x16 @ 1
[   59.633675] bus: 'usb': add driver cdc_eem
[   59.637967] usbcore: registered new interface driver cdc_eem
[   59.643541] initcall eem_init+0x0/0x16 returned 0 after 9634 usecs
[   59.649662] calling  dm9601_init+0x0/0x16 @ 1
[   59.654015] bus: 'usb': add driver dm9601
[   59.658228] usbcore: registered new interface driver dm9601
[   59.663718] initcall dm9601_init+0x0/0x16 returned 0 after 9476 usec=
s
[   59.670098] calling  smsc95xx_init+0x0/0x16 @ 1
[   59.674626] bus: 'usb': add driver smsc95xx
[   59.679008] usbcore: registered new interface driver smsc95xx
[   59.684666] initcall smsc95xx_init+0x0/0x16 returned 0 after 9804 us=
ecs
[   59.691219] calling  usbnet_init+0x0/0x16 @ 1
[   59.695572] bus: 'usb': add driver gl620a
[   59.699783] usbcore: registered new interface driver gl620a
[   59.705267] initcall usbnet_init+0x0/0x16 returned 0 after 9467 usec=
s
[   59.711647] calling  net1080_init+0x0/0x16 @ 1
[   59.716088] bus: 'usb': add driver net1080
[   59.720385] usbcore: registered new interface driver net1080
[   59.725965] initcall net1080_init+0x0/0x16 returned 0 after 9646 use=
cs
[   59.732429] calling  rndis_init+0x0/0x16 @ 1
[   59.736697] bus: 'usb': add driver rndis_host
[   59.741251] usbcore: registered new interface driver rndis_host
[   59.747084] initcall rndis_init+0x0/0x16 returned 0 after 10144 usec=
s
[   59.753483] calling  cdc_subset_init+0x0/0x16 @ 1
[   59.758147] bus: 'usb': add driver cdc_subset
[   59.762741] usbcore: registered new interface driver cdc_subset
[   59.768545] initcall cdc_subset_init+0x0/0x16 returned 0 after 10154=
 usecs
[   59.775408] calling  mcs7830_init+0x0/0x16 @ 1
[   59.779806] bus: 'usb': add driver MOSCHIP usb-ethernet driver
[   59.785874] usbcore: registered new interface driver MOSCHIP usb-eth=
ernet driver
[   59.793201] initcall mcs7830_init+0x0/0x16 returned 0 after 13077 us=
ecs
[   59.799753] calling  usbnet_init+0x0/0x26 @ 1
[   59.804116] initcall usbnet_init+0x0/0x26 returned 0 after 9 usecs
[   59.810241] calling  ipw2100_init+0x0/0x68 @ 1
[   59.814679] ipw2100: Intel(R) PRO/Wireless 2100 Network Driver, git-=
1.2.2
[   59.821420] ipw2100: Copyright(c) 2003-2006 Intel Corporation
[   59.827167] bus: 'pci': add driver ipw2100
[   59.831513] initcall ipw2100_init+0x0/0x68 returned 0 after 16441 us=
ecs
[   59.838035] calling  ieee80211_init+0x0/0x1b @ 1
[   59.842622] ieee80211: 802.11 data/management/control stack, git-1.1=
=2E13
[   59.849188] ieee80211: Copyright (C) 2004-2005 Intel Corporation <jk=
etreno@linux.intel.com>
[   59.857528] initcall ieee80211_init+0x0/0x1b returned 0 after 14556 =
usecs
[   59.864286] calling  init_orinoco+0x0/0x16 @ 1
[   59.868692] orinoco 0.15 (David Gibson <hermes@gibson.dropbear.id.au=
>, Pavel Roskin <proski@gnu.org>, et al)
[   59.878503] initcall init_orinoco+0x0/0x16 returned 0 after 9576 use=
cs
[   59.885000] calling  orinoco_plx_init+0x0/0x25 @ 1
[   59.889752] orinoco_plx 0.15 (Pavel Roskin <proski@gnu.org>, David G=
ibson <hermes@gibson.dropbear.id.au>, Daniel Barlow <dan@telent.net>)
[   59.902080] bus: 'pci': add driver orinoco_plx
[   59.906762] initcall orinoco_plx_init+0x0/0x25 returned 0 after 1660=
6 usecs
[   59.913625] calling  orinoco_pci_init+0x0/0x25 @ 1
[   59.918369] orinoco_pci 0.15 (Pavel Roskin <proski@gnu.org>, David G=
ibson <hermes@gibson.dropbear.id.au> & Jean Tourrilhes <jt@hpl.hp.com>)
[   59.930873] bus: 'pci': add driver orinoco_pci
[   59.935560] initcall orinoco_pci_init+0x0/0x25 returned 0 after 1678=
3 usecs
[   59.942400] calling  orinoco_tmd_init+0x0/0x25 @ 1
[   59.947191] orinoco_tmd 0.15 (Joerg Dorchain <joerg@dorchain.net>)
[   59.953345] bus: 'pci': add driver orinoco_tmd
[   59.958116] initcall orinoco_tmd_init+0x0/0x25 returned 0 after 1067=
0 usecs
[   59.964985] calling  orinoco_nortel_init+0x0/0x25 @ 1
[   59.969988] orinoco_nortel 0.15 (Tobias Hoffmann & Christoph Jungegg=
er <disdos@traum404.de>)
[   59.978417] bus: 'pci': add driver orinoco_nortel
[   59.983378] initcall orinoco_nortel_init+0x0/0x25 returned 0 after 1=
3071 usecs
[   59.990499] calling  airo_init_module+0x0/0xce @ 1
[   59.995319] airo(): Probing for PCI adapters
[   59.999522] bus: 'pci': add driver airo
[   60.003629] airo(): Finished probing for PCI adapters
[   60.009189] initcall airo_init_module+0x0/0xce returned 0 after 1356=
8 usecs
[   60.016154] calling  prism54_module_init+0x0/0x2a @ 1
[   60.021148] Loaded prism54 driver, version 1.2
[   60.025591] bus: 'pci': add driver prism54
[   60.029919] initcall prism54_module_init+0x0/0x2a returned 0 after 8=
562 usecs
[   60.036969] calling  hostap_init+0x0/0x3b @ 1
[   60.041296] initcall hostap_init+0x0/0x3b returned 0 after 21 usecs
[   60.047528] calling  b43_init+0x0/0x4a @ 1
[   60.051614] bus: 'ssb': add driver b43
[   60.055571] Broadcom 43xx driver loaded [ Features: PL, Firmware-ID:=
 FW13 ]
[   60.062410] initcall b43_init+0x0/0x4a returned 0 after 10571 usecs
[   60.068673] calling  b43legacy_init+0x0/0x4f @ 1
[   60.073280] bus: 'ssb': add driver b43legacy
[   60.077734] Broadcom 43xx-legacy driver loaded [ Features: PLI, Firm=
ware-ID: FW10 ]
[   60.085325] initcall b43legacy_init+0x0/0x4f returned 0 after 11779 =
usecs
[   60.092058] calling  rtl8180_init+0x0/0x16 @ 1
[   60.096505] bus: 'pci': add driver rtl8180
[   60.100827] initcall rtl8180_init+0x0/0x16 returned 0 after 4230 use=
cs
[   60.107257] calling  rndis_wlan_init+0x0/0x16 @ 1
[   60.111917] bus: 'usb': add driver rndis_wlan
[   60.116505] usbcore: registered new interface driver rndis_wlan
[   60.122316] initcall rndis_wlan_init+0x0/0x16 returned 0 after 10155=
 usecs
[   60.129176] calling  zd1201_init+0x0/0x16 @ 1
[   60.133507] bus: 'usb': add driver zd1201
[   60.137717] usbcore: registered new interface driver zd1201
[   60.143208] initcall zd1201_init+0x0/0x16 returned 0 after 9473 usec=
s
[   60.149588] calling  lbs_init_module+0x0/0x39 @ 1
[   60.154308] initcall lbs_init_module+0x0/0x39 returned 0 after 18 us=
ecs
[   60.160855] calling  if_usb_init_module+0x0/0x16 @ 1
[   60.165815] bus: 'usb': add driver usb8xxx
[   60.170122] usbcore: registered new interface driver usb8xxx
[   60.175698] initcall if_usb_init_module+0x0/0x16 returned 0 after 96=
51 usecs
[   60.182703] calling  if_sdio_init_module+0x0/0x2a @ 1
[   60.187714] libertas_sdio: Libertas SDIO driver
[   60.192216] libertas_sdio: Copyright Pierre Ossman
[   60.197005] bus: 'sdio': add driver libertas_sdio
[   60.201912] initcall if_sdio_init_module+0x0/0x2a returned 0 after 1=
3862 usecs
[   60.209066] calling  if_spi_init_module+0x0/0x19 @ 1
[   60.214000] libertas_spi: Libertas SPI driver
[   60.218317] bus: 'spi': add driver libertas_spi
[   60.223081] initcall if_spi_init_module+0x0/0x19 returned 0 after 88=
66 usecs
[   60.230008] calling  lbtf_init_module+0x0/0x3f @ 1
[   60.234962] initcall lbtf_init_module+0x0/0x3f returned 0 after 154 =
usecs
[   60.241629] calling  adm8211_init+0x0/0x16 @ 1
[   60.246077] bus: 'pci': add driver adm8211
[   60.250395] initcall adm8211_init+0x0/0x16 returned 0 after 4227 use=
cs
[   60.256827] calling  ath9k_init+0x0/0x62 @ 1
[   60.261085] bus: 'pci': add driver ath9k
[   60.265245] initcall ath9k_init+0x0/0x62 returned 0 after 4089 usecs
[   60.271478] calling  ar9170_init+0x0/0x16 @ 1
[   60.275839] bus: 'usb': add driver ar9170usb
[   60.280308] usbcore: registered new interface driver ar9170usb
[   60.286049] initcall ar9170_init+0x0/0x16 returned 0 after 9971 usec=
s
[   60.292433] calling  wl12xx_init+0x0/0x28 @ 1
[   60.296792] bus: 'spi': add driver wl12xx
[   60.300990] initcall wl12xx_init+0x0/0x28 returned 0 after 4102 usec=
s
[   60.307340] calling  iwm_sdio_init_module+0x0/0xf @ 1
[   60.312344] bus: 'sdio': add driver iwm_sdio
[   60.316845] initcall iwm_sdio_init_module+0x0/0xf returned 0 after 4=
390 usecs
[   60.323883] calling  scc_init_driver+0x0/0x75 @ 1
[   60.328542] AX.25: Z8530 SCC driver version 3.0.dl1bke
[   60.333704] device: 'scc0': device_add
[   60.337723] PM: Adding info for No Bus:scc0
[   60.342113] initcall scc_init_driver+0x0/0x75 returned 0 after 13254=
 usecs
[   60.348897] calling  mkiss_init_driver+0x0/0x38 @ 1
[   60.353743] mkiss: AX.25 Multikiss, Hans Albas PE1AYX
[   60.358756] initcall mkiss_init_driver+0x0/0x38 returned 0 after 489=
7 usecs
[   60.365703] calling  yam_init_driver+0x0/0xdc @ 1
[   60.370367] YAM driver version 0.8 by F1OAT/F6FBB
[   60.375087] device: 'yam0': device_add
[   60.379105] PM: Adding info for No Bus:yam0
[   60.383483] device: 'yam1': device_add
[   60.387431] PM: Adding info for No Bus:yam1
[   60.391793] device: 'yam2': device_add
[   60.395780] PM: Adding info for No Bus:yam2
[   60.400169] device: 'yam3': device_add
[   60.404138] PM: Adding info for No Bus:yam3
[   60.408505] initcall yam_init_driver+0x0/0xdc returned 0 after 37241=
 usecs
[   60.415355] calling  init_baycomserfdx+0x0/0xe4 @ 1
[   60.420115] baycom_ser_fdx: (C) 1996-2000 Thomas Sailer, HB9JNX/AE4W=
A
[   60.420116] <6>baycom_ser_fdx: version 0.10 compiled 09:18:08 Jul  2=
 2009
[   60.433333] device: 'bcsf0': device_add
[   60.437441] PM: Adding info for No Bus:bcsf0
[   60.441897] device: 'bcsf1': device_add
[   60.445975] PM: Adding info for No Bus:bcsf1
[   60.450441] device: 'bcsf2': device_add
[   60.454520] PM: Adding info for No Bus:bcsf2
[   60.458976] device: 'bcsf3': device_add
[   60.463064] PM: Adding info for No Bus:bcsf3
[   60.467506] initcall init_baycomserfdx+0x0/0xe4 returned 0 after 462=
78 usecs
[   60.474464] calling  hdlcdrv_init_driver+0x0/0x1b @ 1
[   60.479465] hdlcdrv: (C) 1996-2000 Thomas Sailer HB9JNX/AE4WA
[   60.485201] hdlcdrv: version 0.8 compiled 09:18:09 Jul  2 2009
[   60.490993] initcall hdlcdrv_init_driver+0x0/0x1b returned 0 after 1=
1257 usecs
[   60.498202] calling  init_baycomserhdx+0x0/0xd1 @ 1
[   60.503056] baycom_ser_hdx: (C) 1996-2000 Thomas Sailer, HB9JNX/AE4W=
A
[   60.503057] <6>baycom_ser_hdx: version 0.10 compiled 09:18:10 Jul  2=
 2009
[   60.516254] device: 'bcsh0': device_add
[   60.520362] PM: Adding info for No Bus:bcsh0
[   60.524842] device: 'bcsh1': device_add
[   60.528900] PM: Adding info for No Bus:bcsh1
[   60.533394] device: 'bcsh2': device_add
[   60.537450] PM: Adding info for No Bus:bcsh2
[   60.541917] device: 'bcsh3': device_add
[   60.546000] PM: Adding info for No Bus:bcsh3
[   60.550439] initcall init_baycomserhdx+0x0/0xd1 returned 0 after 462=
74 usecs
[   60.557390] calling  init_baycompar+0x0/0xc1 @ 1
[   60.561964] baycom_par: (C) 1996-2000 Thomas Sailer, HB9JNX/AE4WA
[   60.561966] <6>baycom_par: version 0.9 compiled 09:18:10 Jul  2 2009
[   60.574413] device: 'bcp0': device_add
[   60.578423] PM: Adding info for No Bus:bcp0
[   60.582811] device: 'bcp1': device_add
[   60.586768] PM: Adding info for No Bus:bcp1
[   60.591140] device: 'bcp2': device_add
[   60.595130] PM: Adding info for No Bus:bcp2
[   60.599504] device: 'bcp3': device_add
[   60.603520] PM: Adding info for No Bus:bcp3
[   60.607874] initcall init_baycompar+0x0/0xc1 returned 0 after 44832 =
usecs
[   60.614571] calling  init_baycomepp+0x0/0xf2 @ 1
[   60.619139] baycom_epp: (C) 1998-2000 Thomas Sailer, HB9JNX/AE4WA
[   60.619140] <6>baycom_epp: version 0.7 compiled 09:18:10 Jul  2 2009
[   60.631579] device: 'bce0': device_add
[   60.635595] PM: Adding info for No Bus:bce0
[   60.639969] device: 'bce1': device_add
[   60.643951] PM: Adding info for No Bus:bce1
[   60.648324] device: 'bce2': device_add
[   60.652289] PM: Adding info for No Bus:bce2
[   60.656697] device: 'bce3': device_add
[   60.660815] PM: Adding info for No Bus:bce3
[   60.665198] initcall init_baycomepp+0x0/0xf2 returned 0 after 44974 =
usecs
[   60.671866] calling  init_netconsole+0x0/0x133 @ 1
[   60.676737] console [netcon0] enabled
[   60.680284] netconsole: network logging started
[   60.684809] initcall init_netconsole+0x0/0x133 returned 0 after 7937=
 usecs
[   60.691634] calling  nicstar_init+0x0/0x5f @ 1
[   60.696088] bus: 'pci': add driver nicstar
[   60.700432] initcall nicstar_init+0x0/0x5f returned 0 after 4256 use=
cs
[   60.706862] calling  ia_module_init+0x0/0x48 @ 1
[   60.711440] bus: 'pci': add driver ia
[   60.715365] initcall ia_module_init+0x0/0x48 returned 0 after 3836 u=
secs
[   60.721942] calling  fore200e_module_init+0x0/0x20 @ 1
[   60.727082] fore200e: FORE Systems 200E-series ATM driver - version =
0.3e
[   60.733756] bus: 'pci': add driver fore_200e
[   60.738252] initcall fore200e_module_init+0x0/0x20 returned 0 after =
10909 usecs
[   60.745489] calling  idt77252_init+0x0/0x2a @ 1
[   60.749973] idt77252_init: at c20b26e1
[   60.753724] bus: 'pci': add driver idt77252
[   60.758132] initcall idt77252_init+0x0/0x2a returned 0 after 7966 us=
ecs
[   60.764651] calling  adummy_init+0x0/0xd9 @ 1
[   60.768962] adummy: version 1.0
[   60.772210] device: 'adummy0': device_add
[   60.776225] PM: Adding info for No Bus:adummy0
[   60.780919] initcall adummy_init+0x0/0xd9 returned 0 after 11675 use=
cs
[   60.787351] calling  atmtcp_init+0x0/0x11 @ 1
[   60.791685] initcall atmtcp_init+0x0/0x11 returned 0 after 23 usecs
[   60.797918] calling  lanai_module_init+0x0/0x2d @ 1
[   60.802780] bus: 'pci': add driver lanai
[   60.806931] initcall lanai_module_init+0x0/0x2d returned 0 after 406=
4 usecs
[   60.813802] calling  uio_init+0x0/0x7 @ 1
[   60.817767] initcall uio_init+0x0/0x7 returned 0 after 1 usecs
[   60.823588] calling  hilscher_init_module+0x0/0x16 @ 1
[   60.828692] bus: 'pci': add driver hilscher
[   60.833139] initcall hilscher_init_module+0x0/0x16 returned 0 after =
4345 usecs
[   60.840260] calling  uio_pdrv_init+0x0/0xf @ 1
[   60.844710] bus: 'platform': add driver uio_pdrv
[   60.849525] initcall uio_pdrv_init+0x0/0xf returned 0 after 4707 use=
cs
[   60.855956] calling  uio_pdrv_genirq_init+0x0/0xf @ 1
[   60.860961] bus: 'platform': add driver uio_pdrv_genirq
[   60.866417] initcall uio_pdrv_genirq_init+0x0/0xf returned 0 after 5=
324 usecs
[   60.873454] calling  smx_ce_init_module+0x0/0xf @ 1
[   60.878286] bus: 'platform': add driver smx-ce
[   60.882966] initcall smx_ce_init_module+0x0/0xf returned 0 after 456=
7 usecs
[   60.889809] calling  aectc_init+0x0/0x16 @ 1
[   60.894092] bus: 'pci': add driver aectc
[   60.898237] initcall aectc_init+0x0/0x16 returned 0 after 4058 usecs
[   60.905131] calling  sercos3_init_module+0x0/0x16 @ 1
[   60.910143] bus: 'pci': add driver sercos3
[   60.914490] initcall sercos3_init_module+0x0/0x16 returned 0 after 4=
248 usecs
[   60.921503] calling  butterfly_init+0x0/0xf @ 1
[   60.926039] initcall butterfly_init+0x0/0xf returned 0 after 2 usecs
[   60.932337] calling  init_spi_lm70llp+0x0/0xf @ 1
[   60.937041] initcall init_spi_lm70llp+0x0/0xf returned 0 after 1 use=
cs
[   60.943536] calling  spidev_init+0x0/0x82 @ 1
[   60.947877] device class 'spidev': registering
[   60.952526] bus: 'spi': add driver spidev
[   60.956665] initcall spidev_init+0x0/0x82 returned 0 after 8604 usec=
s
[   60.963007] calling  tle62x0_init+0x0/0xf @ 1
[   60.967319] bus: 'spi': add driver tle62x0
[   60.971626] initcall tle62x0_init+0x0/0xf returned 0 after 4209 usec=
s
[   60.977969] calling  nonstatic_sysfs_init+0x0/0xf @ 1
[   60.983045] initcall nonstatic_sysfs_init+0x0/0xf returned 0 after 4=
0 usecs
[   60.989909] calling  yenta_socket_init+0x0/0x16 @ 1
[   60.994795] bus: 'pci': add driver yenta_cardbus
[   60.999637] initcall yenta_socket_init+0x0/0x16 returned 0 after 473=
9 usecs
[   61.006506] calling  aoe_init+0x0/0x9d @ 1
[   61.010581] device class 'aoe': registering
[   61.014973] device: 'err': device_add
[   61.018796] PM: Adding info for No Bus:err
[   61.023080] device: 'discover': device_add
[   61.027174] PM: Adding info for No Bus:discover
[   61.031813] device: 'interfaces': device_add
[   61.036106] PM: Adding info for No Bus:interfaces
[   61.040919] device: 'revalidate': device_add
[   61.045210] PM: Adding info for No Bus:revalidate
[   61.050015] device: 'flush': device_add
[   61.053880] PM: Adding info for No Bus:flush
[   61.058299] aoe: AoE v47 initialised.
[   61.062364] initcall aoe_init+0x0/0x9d returned 0 after 50592 usecs
[   61.068547] calling  uwb_subsys_init+0x0/0x46 @ 1
[   61.073243] device class 'uwb_rc': registering
[   61.077878] initcall uwb_subsys_init+0x0/0x46 returned 0 after 4552 =
usecs
[   61.084626] calling  umc_bus_init+0x0/0xf @ 1
[   61.089162] bus: 'umc': registered
[   61.092448] initcall umc_bus_init+0x0/0xf returned 0 after 3488 usec=
s
[   61.098885] calling  whci_init+0x0/0x16 @ 1
[   61.103051] bus: 'pci': add driver whci
[   61.107116] initcall whci_init+0x0/0x16 returned 0 after 3982 usecs
[   61.113291] calling  whcrc_driver_init+0x0/0x16 @ 1
[   61.118121] bus: 'umc': add driver whc-rc
[   61.122345] initcall whcrc_driver_init+0x0/0x16 returned 0 after 412=
7 usecs
[   61.129214] calling  hwarc_driver_init+0x0/0x16 @ 1
[   61.134076] bus: 'usb': add driver hwa-rc
[   61.138279] usbcore: registered new interface driver hwa-rc
[   61.143770] initcall hwarc_driver_init+0x0/0x16 returned 0 after 946=
8 usecs
[   61.150670] calling  i1480_dfu_driver_init+0x0/0x16 @ 1
[   61.155895] bus: 'usb': add driver i1480-dfu-usb
[   61.160705] usbcore: registered new interface driver i1480-dfu-usb
[   61.166798] initcall i1480_dfu_driver_init+0x0/0x16 returned 0 after=
 10647 usecs
[   61.174153] calling  i1480_est_init+0x0/0x78 @ 1
[   61.178760] initcall i1480_est_init+0x0/0x78 returned 0 after 31 use=
cs
[   61.185243] calling  mon_init+0x0/0xef @ 1
[   61.189322] device class 'usbmon': registering
[   61.194023] device: 'usbmon0': device_add
[   61.198079] PM: Adding info for No Bus:usbmon0
[   61.202690] initcall mon_init+0x0/0xef returned 0 after 13070 usecs
[   61.208833] calling  ehci_hcd_init+0x0/0xa5 @ 1
[   61.213372] ehci_hcd: USB 2.0 'Enhanced' Host Controller (EHCI) Driv=
er
[   61.219850] bus: 'pci': add driver ehci_hcd
[   61.224052] bus: 'pci': driver_probe_device: matched device 0000:00:=
02.1 with driver ehci_hcd
[   61.232491] bus: 'pci': really_probe: probing driver ehci_hcd with d=
evice 0000:00:02.1
[   61.243473] ACPI: PCI Interrupt Link [APCL] enabled at IRQ 22
[   61.249109] IOAPIC[0]: Set routing entry (2-22 -> 0x59 -> IRQ 22 Mod=
e:1 Active:1)
[   61.256579] ehci_hcd 0000:00:02.1: PCI INT B -> Link[APCL] -> GSI 22=
 (level, low) -> IRQ 22
[   61.264944] ehci_hcd 0000:00:02.1: setting latency timer to 64
[   61.270685] ehci_hcd 0000:00:02.1: EHCI Host Controller
[   61.276175] device: 'usbmon1': device_add
[   61.280424] PM: Adding info for No Bus:usbmon1
[   61.285183] ehci_hcd 0000:00:02.1: new USB bus registered, assigned =
bus number 1
[   61.292724] ehci_hcd 0000:00:02.1: debug port 1
[   61.297147] ehci_hcd 0000:00:02.1: cache line size of 64 is not supp=
orted
[   61.304005] ehci_hcd 0000:00:02.1: irq 22, io mem 0xfeb00000
[   61.322535] ehci_hcd 0000:00:02.1: USB 2.0 started, EHCI 1.00
[   61.328582] usb usb1: New USB device found, idVendor=3D1d6b, idProdu=
ct=3D0002
[   61.335280] usb usb1: New USB device strings: Mfr=3D3, Product=3D2, =
SerialNumber=3D1
[   61.342447] usb usb1: Product: EHCI Host Controller
[   61.347323] usb usb1: Manufacturer: Linux 2.6.31-rc1-tip-01159-g24b7=
800-dirty ehci_hcd
[   61.355206] usb usb1: SerialNumber: 0000:00:02.1
[   61.359789] device: 'usb1': device_add
[   61.363917] bus: 'usb': add device usb1
[   61.367702] PM: Adding info for usb:usb1
[   61.372008] bus: 'usb': driver_probe_device: matched device usb1 wit=
h driver usb
[   61.379331] bus: 'usb': really_probe: probing driver usb with device=
 usb1
[   61.386120] usb usb1: configuration #1 chosen from 1 choice
[   61.391818] device: '1-0:1.0': device_add
[   61.395839] bus: 'usb': add device 1-0:1.0
[   61.399893] PM: Adding info for usb:1-0:1.0
[   61.404280] bus: 'usb': driver_probe_device: matched device 1-0:1.0 =
with driver hub
[   61.411834] bus: 'usb': really_probe: probing driver hub with device=
 1-0:1.0
[   61.418949] hub 1-0:1.0: USB hub found
[   61.422737] hub 1-0:1.0: 10 ports detected
[   61.427241] driver: '1-0:1.0': driver_bound: bound to device 'hub'
[   61.433323] bus: 'usb': really_probe: bound device 1-0:1.0 to driver=
 hub
[   61.440016] device: 'ep_81': device_add
[   61.443952] PM: Adding info for No Bus:ep_81
[   61.448116] driver: 'usb1': driver_bound: bound to device 'usb'
[   61.454010] bus: 'usb': really_probe: bound device usb1 to driver us=
b
[   61.460424] device: 'ep_00': device_add
[   61.464349] PM: Adding info for No Bus:ep_00
[   61.468511] driver: '0000:00:02.1': driver_bound: bound to device 'e=
hci_hcd'
[   61.475539] bus: 'pci': really_probe: bound device 0000:00:02.1 to d=
river ehci_hcd
[   61.483333] initcall ehci_hcd_init+0x0/0xa5 returned 0 after 263629 =
usecs
[   61.490003] calling  oxu_module_init+0x0/0xf @ 1
[   61.494628] bus: 'platform': add driver oxu210hp-hcd
[   61.499782] initcall oxu_module_init+0x0/0xf returned 0 after 5039 u=
secs
[   61.506418] calling  ohci_hcd_mod_init+0x0/0xbe @ 1
[   61.511219] ohci_hcd: USB 1.1 'Open' Host Controller (OHCI) Driver
[   61.517398] bus: 'pci': add driver ohci_hcd
[   61.521571] bus: 'pci': driver_probe_device: matched device 0000:00:=
02.0 with driver ohci_hcd
[   61.530108] bus: 'pci': really_probe: probing driver ohci_hcd with d=
evice 0000:00:02.0
[   61.541043] ACPI: PCI Interrupt Link [APCF] enabled at IRQ 21
[   61.546706] IOAPIC[0]: Set routing entry (2-21 -> 0x61 -> IRQ 21 Mod=
e:1 Active:1)
[   61.554150] ohci_hcd 0000:00:02.0: PCI INT A -> Link[APCF] -> GSI 21=
 (level, low) -> IRQ 21
[   61.562519] ohci_hcd 0000:00:02.0: setting latency timer to 64
[   61.568259] ohci_hcd 0000:00:02.0: OHCI Host Controller
[   61.573636] device: 'usbmon2': device_add
[   61.577833] PM: Adding info for No Bus:usbmon2
[   61.582673] ohci_hcd 0000:00:02.0: new USB bus registered, assigned =
bus number 2
[   61.590137] ohci_hcd 0000:00:02.0: irq 21, io mem 0xda102000
[   61.654825] usb usb2: New USB device found, idVendor=3D1d6b, idProdu=
ct=3D0001
[   61.661488] usb usb2: New USB device strings: Mfr=3D3, Product=3D2, =
SerialNumber=3D1
[   61.668704] usb usb2: Product: OHCI Host Controller
[   61.673558] usb usb2: Manufacturer: Linux 2.6.31-rc1-tip-01159-g24b7=
800-dirty ohci_hcd
[   61.681422] usb usb2: SerialNumber: 0000:00:02.0
[   61.686040] device: 'usb2': device_add
[   61.690082] bus: 'usb': add device usb2
[   61.693889] PM: Adding info for usb:usb2
[   61.697994] bus: 'usb': driver_probe_device: matched device usb2 wit=
h driver usb
[   61.705400] bus: 'usb': really_probe: probing driver usb with device=
 usb2
[   61.712104] usb usb2: configuration #1 chosen from 1 choice
[   61.717697] device: '2-0:1.0': device_add
[   61.721716] bus: 'usb': add device 2-0:1.0
[   61.725791] PM: Adding info for usb:2-0:1.0
[   61.730104] bus: 'usb': driver_probe_device: matched device 2-0:1.0 =
with driver hub
[   61.737690] bus: 'usb': really_probe: probing driver hub with device=
 2-0:1.0
[   61.744742] hub 2-0:1.0: USB hub found
[   61.748533] hub 2-0:1.0: 10 ports detected
[   61.752858] driver: '2-0:1.0': driver_bound: bound to device 'hub'
[   61.758914] bus: 'usb': really_probe: bound device 2-0:1.0 to driver=
 hub
[   61.765631] device: 'ep_81': device_add
[   61.769540] PM: Adding info for No Bus:ep_81
[   61.773715] driver: 'usb2': driver_bound: bound to device 'usb'
[   61.779584] bus: 'usb': really_probe: bound device usb2 to driver us=
b
[   61.786038] device: 'ep_00': device_add
[   61.789928] PM: Adding info for No Bus:ep_00
[   61.794121] driver: '0000:00:02.0': driver_bound: bound to device 'o=
hci_hcd'
[   61.801105] bus: 'pci': really_probe: bound device 0000:00:02.0 to d=
river ohci_hcd
[   61.808911] bus: 'ssb': add driver ohci_hcd
[   61.813243] Platform driver 'sm501-usb' needs updating - please use =
dev_pm_ops
[   61.820370] bus: 'platform': add driver sm501-usb
[   61.825348] initcall ohci_hcd_mod_init+0x0/0xbe returned 0 after 306=
758 usecs
[   61.832364] calling  uhci_hcd_init+0x0/0xa7 @ 1
[   61.836898] uhci_hcd: USB Universal Host Controller Interface driver
[   61.843273] bus: 'pci': add driver uhci_hcd
[   61.848252] initcall uhci_hcd_init+0x0/0xa7 returned 0 after 11090 u=
secs
[   61.854869] calling  xhci_hcd_init+0x0/0x25 @ 1
[   61.859355] bus: 'pci': add driver xhci_hcd
[   61.863910] initcall xhci_hcd_init+0x0/0x25 returned 0 after 4452 us=
ecs
[   61.870403] calling  isp1760_init+0x0/0x44 @ 1
[   61.874895] bus: 'platform': add driver isp1760
[   61.879582] bus: 'pci': add driver isp1760
[   61.883874] initcall isp1760_init+0x0/0x44 returned 0 after 8812 use=
cs
[   61.890276] calling  hwahc_driver_init+0x0/0x16 @ 1
[   61.895158] bus: 'usb': add driver hwa-hc
[   61.899360] usbcore: registered new interface driver hwa-hc
[   61.904844] initcall hwahc_driver_init+0x0/0x16 returned 0 after 946=
0 usecs
[   61.911743] calling  wusbcore_init+0x0/0x6c @ 1
[   61.916366] initcall wusbcore_init+0x0/0x6c returned 0 after 93 usec=
s
[   61.922705] calling  usblp_init+0x0/0x16 @ 1
[   61.926932] bus: 'usb': add driver usblp
[   61.931072] usbcore: registered new interface driver usblp
[   61.936476] initcall usblp_init+0x0/0x16 returned 0 after 9317 usecs
[   61.942790] calling  usbtmc_init+0x0/0x2d @ 1
[   61.947107] bus: 'usb': add driver usbtmc
[   61.951329] usbcore: registered new interface driver usbtmc
[   61.956819] initcall usbtmc_init+0x0/0x2d returned 0 after 9480 usec=
s
[   61.963217] calling  usb_usual_init+0x0/0x32 @ 1
[   61.967834] bus: 'usb': add driver libusual
[   61.972324] usbcore: registered new interface driver libusual
[   61.977996] initcall usb_usual_init+0x0/0x32 returned 0 after 9958 u=
secs
[   61.984650] calling  usb_mdc800_init+0x0/0x30b @ 1
[   61.989425] bus: 'usb': add driver mdc800
[   61.993651] usbcore: registered new interface driver mdc800
[   61.999109] mdc800: v0.7.5 (30/10/2000):USB Driver for Mustek MDC800=
 Digital Camera
[   62.006758] initcall usb_mdc800_init+0x0/0x30b returned 0 after 1694=
7 usecs
[   62.013688] calling  microtek_drv_init+0x0/0x16 @ 1
[   62.018522] bus: 'usb': add driver microtekX6
[   62.023116] usbcore: registered new interface driver microtekX6
[   62.028919] initcall microtek_drv_init+0x0/0x16 returned 0 after 101=
54 usecs
[   62.035955] calling  usb_serial_init+0x0/0x1cc @ 1
[   62.040984] bus: 'usb-serial': registered
[   62.044997] bus: 'usb': add driver usbserial
[   62.049388] usbcore: registered new interface driver usbserial
[   62.055125] usbserial: USB Serial Driver core
[   62.059438] initcall usb_serial_init+0x0/0x1cc returned 0 after 1829=
7 usecs
[   62.066386] calling  aircable_init+0x0/0x3a @ 1
[   62.070877] bus: 'usb-serial': add driver aircable
[   62.075901] USB Serial support registered for aircable
[   62.080920] bus: 'usb': add driver aircable
[   62.085349] usbcore: registered new interface driver aircable
[   62.090975] initcall aircable_init+0x0/0x3a returned 0 after 19628 u=
secs
[   62.097679] calling  ark3116_init+0x0/0x3a @ 1
[   62.102069] bus: 'usb-serial': add driver ark3116
[   62.107012] USB Serial support registered for ark3116
[   62.111948] bus: 'usb': add driver ark3116
[   62.116289] usbcore: registered new interface driver ark3116
[   62.121829] initcall ark3116_init+0x0/0x3a returned 0 after 19296 us=
ecs
[   62.128439] calling  belkin_sa_init+0x0/0x49 @ 1
[   62.133028] bus: 'usb-serial': add driver belkin
[   62.137848] USB Serial support registered for Belkin / Peracom / GoH=
ubs USB Serial Adapter
[   62.146044] bus: 'usb': add driver belkin
[   62.150249] usbcore: registered new interface driver belkin
[   62.155722] belkin_sa: v1.2:USB Belkin Serial converter driver
[   62.161514] initcall belkin_sa_init+0x0/0x49 returned 0 after 27822 =
usecs
[   62.168294] calling  cyberjack_init+0x0/0x54 @ 1
[   62.172886] bus: 'usb-serial': add driver cyberjack
[   62.177966] USB Serial support registered for Reiner SCT Cyberjack U=
SB card reader
[   62.185467] bus: 'usb': add driver cyberjack
[   62.189933] usbcore: registered new interface driver cyberjack
[   62.195675] cyberjack: v1.01 Matthias Bruestle
[   62.200069] cyberjack: REINER SCT cyberJack pinpad/e-com USB Chipcar=
d Reader Driver
[   62.207717] initcall cyberjack_init+0x0/0x54 returned 0 after 34014 =
usecs
[   62.214476] calling  cypress_init+0x0/0x9d @ 1
[   62.218879] bus: 'usb-serial': add driver earthmate
[   62.223994] USB Serial support registered for DeLorme Earthmate USB
[   62.230135] bus: 'usb-serial': add driver cyphidcom
[   62.235263] USB Serial support registered for HID->COM RS232 Adapter
[   62.241497] bus: 'usb-serial': add driver nokiaca42v2
[   62.246802] USB Serial support registered for Nokia CA-42 V2 Adapter
[   62.253060] bus: 'usb': add driver cypress
[   62.257356] usbcore: registered new interface driver cypress
[   62.262920] cypress_m8: v1.09:Cypress USB to Serial Driver
[   62.268358] initcall cypress_init+0x0/0x9d returned 0 after 48319 us=
ecs
[   62.274961] calling  digi_init+0x0/0x63 @ 1
[   62.279105] bus: 'usb-serial': add driver digi_2
[   62.283963] USB Serial support registered for Digi 2 port USB adapte=
r
[   62.290281] bus: 'usb-serial': add driver digi_4
[   62.295154] USB Serial support registered for Digi 4 port USB adapte=
r
[   62.301473] bus: 'usb': add driver digi_acceleport
[   62.306506] usbcore: registered new interface driver digi_acceleport
[   62.312762] digi_acceleport: v1.80.1.2:Digi AccelePort USB-2/USB-4 S=
erial Converter driver
[   62.320972] initcall digi_init+0x0/0x63 returned 0 after 40887 usecs
[   62.327316] calling  edgeport_init+0x0/0xa5 @ 1
[   62.331807] bus: 'usb-serial': add driver edgeport_2
[   62.337012] USB Serial support registered for Edgeport 2 port adapte=
r
[   62.343358] bus: 'usb-serial': add driver edgeport_4
[   62.348522] USB Serial support registered for Edgeport 4 port adapte=
r
[   62.354866] bus: 'usb-serial': add driver edgeport_8
[   62.360100] USB Serial support registered for Edgeport 8 port adapte=
r
[   62.366444] bus: 'usb-serial': add driver epic
[   62.371092] USB Serial support registered for EPiC device
[   62.376391] bus: 'usb': add driver io_edgeport
[   62.381036] usbcore: registered new interface driver io_edgeport
[   62.386949] io_edgeport: v2.7:Edgeport USB Serial Driver
[   62.392216] initcall edgeport_init+0x0/0xa5 returned 0 after 58992 u=
secs
[   62.398909] calling  edgeport_init+0x0/0x63 @ 1
[   62.403412] bus: 'usb-serial': add driver edgeport_ti_1
[   62.408843] USB Serial support registered for Edgeport TI 1 port ada=
pter
[   62.415448] bus: 'usb-serial': add driver edgeport_ti_2
[   62.420874] USB Serial support registered for Edgeport TI 2 port ada=
pter
[   62.427480] bus: 'usb': add driver io_ti
[   62.431611] usbcore: registered new interface driver io_ti
[   62.437000] io_ti: v0.7mode043006:Edgeport USB Serial Driver
[   62.442636] initcall edgeport_init+0x0/0x63 returned 0 after 38305 u=
secs
[   62.449283] calling  empeg_init+0x0/0x12d @ 1
[   62.453760] bus: 'usb-serial': add driver empeg
[   62.458411] USB Serial support registered for empeg
[   62.463203] bus: 'usb': add driver empeg
[   62.467319] usbcore: registered new interface driver empeg
[   62.472707] empeg: v1.2:USB Empeg Mark I/II Driver
[   62.477453] initcall empeg_init+0x0/0x12d returned 0 after 23260 use=
cs
[   62.483968] calling  ftdi_init+0x0/0xb3 @ 1
[   62.488114] bus: 'usb-serial': add driver ftdi_sio
[   62.493146] USB Serial support registered for FTDI USB Serial Device
[   62.499378] bus: 'usb': add driver ftdi_sio
[   62.503819] usbcore: registered new interface driver ftdi_sio
[   62.509446] ftdi_sio: v1.5.0:USB FTDI Serial Converters Driver
[   62.515282] initcall ftdi_init+0x0/0xb3 returned 0 after 26527 usecs
[   62.521581] calling  funsoft_init+0x0/0x3a @ 1
[   62.526022] bus: 'usb-serial': add driver funsoft
[   62.530929] USB Serial support registered for funsoft
[   62.535892] bus: 'usb': add driver funsoft
[   62.540229] usbcore: registered new interface driver funsoft
[   62.545801] initcall funsoft_init+0x0/0x3a returned 0 after 19315 us=
ecs
[   62.552357] calling  garmin_init+0x0/0x49 @ 1
[   62.556715] bus: 'usb-serial': add driver garmin_gps
[   62.561886] USB Serial support registered for Garmin GPS usb/tty
[   62.567802] bus: 'usb': add driver garmin_gps
[   62.572347] usbcore: registered new interface driver garmin_gps
[   62.578169] garmin_gps: v0.33:garmin gps driver
[   62.582682] initcall garmin_init+0x0/0x49 returned 0 after 25357 use=
cs
[   62.589156] calling  hp49gp_init+0x0/0x49 @ 1
[   62.593510] bus: 'usb-serial': add driver hp4X
[   62.598158] USB Serial support registered for hp4X
[   62.602859] bus: 'usb': add driver hp4X
[   62.606891] usbcore: registered new interface driver hp4X
[   62.612171] hp4x: v1.00:HP4x (48/49) Generic Serial driver
[   62.617664] initcall hp49gp_init+0x0/0x49 returned 0 after 23588 use=
cs
[   62.624153] calling  ipaq_init+0x0/0x7a @ 1
[   62.628299] bus: 'usb-serial': add driver ipaq
[   62.632975] USB Serial support registered for PocketPC PDA
[   62.638341] bus: 'usb': add driver ipaq
[   62.642407] usbcore: registered new interface driver ipaq
[   62.647717] ipaq: v0.5:USB PocketPC PDA driver
[   62.652115] initcall ipaq_init+0x0/0x7a returned 0 after 23258 usecs
[   62.658458] calling  ir_init+0x0/0x49 @ 1
[   62.662428] bus: 'usb-serial': add driver ir-usb
[   62.667287] USB Serial support registered for IR Dongle
[   62.672394] bus: 'usb': add driver ir-usb
[   62.676648] usbcore: registered new interface driver ir-usb
[   62.682098] ir_usb: v0.4:USB IR Dongle driver
[   62.686461] initcall ir_init+0x0/0x49 returned 0 after 23466 usecs
[   62.692605] calling  iuu_init+0x0/0x49 @ 1
[   62.696662] bus: 'usb-serial': add driver iuu_phoenix
[   62.701925] USB Serial support registered for iuu_phoenix
[   62.707234] bus: 'usb': add driver iuu_phoenix
[   62.711869] usbcore: registered new interface driver iuu_phoenix
[   62.717773] iuu_phoenix: v0.10:Infinity USB Unlimited Phoenix driver
[   62.724106] initcall iuu_init+0x0/0x49 returned 0 after 26798 usecs
[   62.730321] calling  keyspan_pda_init+0x0/0x7d @ 1
[   62.735109] bus: 'usb-serial': add driver keyspan_pda
[   62.740359] USB Serial support registered for Keyspan PDA
[   62.745669] bus: 'usb-serial': add driver keyspan_pda_pre
[   62.751262] USB Serial support registered for Keyspan PDA - (prerenu=
meration)
[   62.758299] bus: 'usb-serial': add driver xircom_no_firm
[   62.763834] USB Serial support registered for Xircom / Entregra PGS =
- (prerenumeration)
[   62.771739] bus: 'usb': add driver keyspan_pda
[   62.776431] usbcore: registered new interface driver keyspan_pda
[   62.782969] keyspan_pda: v1.1:USB Keyspan PDA Converter driver
[   62.788754] initcall keyspan_pda_init+0x0/0x7d returned 0 after 5239=
1 usecs
[   62.795714] calling  klsi_105_init+0x0/0x49 @ 1
[   62.800195] bus: 'usb-serial': add driver kl5kusb105d
[   62.805485] USB Serial support registered for KL5KUSB105D / PalmConn=
ect
[   62.811980] bus: 'usb': add driver kl5kusb105d
[   62.816670] usbcore: registered new interface driver kl5kusb105d
[   62.822576] kl5kusb105: v0.3a:KLSI KL5KUSB105 chipset USB->Serial Co=
nverter driver
[   62.830094] initcall klsi_105_init+0x0/0x49 returned 0 after 29200 u=
secs
[   62.836785] calling  kobil_init+0x0/0x49 @ 1
[   62.841016] bus: 'usb-serial': add driver kobil
[   62.845781] USB Serial support registered for KOBIL USB smart card t=
erminal
[   62.852646] bus: 'usb': add driver kobil
[   62.856762] usbcore: registered new interface driver kobil
[   62.862129] kobil_sct: 21/05/2004:KOBIL USB Smart Card Terminal Driv=
er (experimental)
[   62.869962] initcall kobil_init+0x0/0x49 returned 0 after 28263 usec=
s
[   62.876365] calling  mct_u232_init+0x0/0x49 @ 1
[   62.880857] bus: 'usb-serial': add driver mct_u232
[   62.885889] USB Serial support registered for MCT U232
[   62.890910] bus: 'usb': add driver mct_u232
[   62.895341] usbcore: registered new interface driver mct_u232
[   62.900968] mct_u232: z2.1:Magic Control Technology USB-RS232 conver=
ter driver
[   62.908191] initcall mct_u232_init+0x0/0x49 returned 0 after 26690 u=
secs
[   62.914854] calling  moschip7720_init+0x0/0x67 @ 1
[   62.919606] bus: 'usb-serial': add driver moschip7720
[   62.924891] USB Serial support registered for Moschip 2 port adapter
[   62.931120] mos7720: 1.0.0.4F:Moschip USB Serial Driver
[   62.936351] bus: 'usb': add driver moschip7720
[   62.940984] usbcore: registered new interface driver moschip7720
[   62.946892] initcall moschip7720_init+0x0/0x67 returned 0 after 2664=
3 usecs
[   62.953826] calling  moschip7840_init+0x0/0xa9 @ 1
[   62.958572] bus: 'usb-serial': add driver mos7840
[   62.963517] USB Serial support registered for Moschip 7840/7820 USB =
Serial Driver
[   62.970899] mos7840: 1.3.2:Moschip 7840/7820 USB Serial Driver
[   62.976737] bus: 'usb': add driver mos7840
[   62.981029] usbcore: registered new interface driver mos7840
[   62.986592] initcall moschip7840_init+0x0/0xa9 returned 0 after 2736=
0 usecs
[   62.993529] calling  moto_init+0x0/0x3a @ 1
[   62.997668] bus: 'usb-serial': add driver moto-modem
[   63.002873] USB Serial support registered for moto-modem
[   63.008067] bus: 'usb': add driver moto-modem
[   63.012645] usbcore: registered new interface driver moto-modem
[   63.018441] initcall moto_init+0x0/0x3a returned 0 after 20288 usecs
[   63.024791] calling  navman_init+0x0/0x3a @ 1
[   63.029102] bus: 'usb-serial': add driver navman
[   63.033956] USB Serial support registered for navman
[   63.038800] bus: 'usb': add driver navman
[   63.043056] usbcore: registered new interface driver navman
[   63.048506] initcall navman_init+0x0/0x3a returned 0 after 18950 use=
cs
[   63.055030] calling  option_init+0x0/0x49 @ 1
[   63.059341] bus: 'usb-serial': add driver option1
[   63.064284] USB Serial support registered for GSM modem (1-port)
[   63.070173] bus: 'usb': add driver option
[   63.074435] usbcore: registered new interface driver option
[   63.079885] option: v0.7.2:USB Driver for GSM modems
[   63.084854] initcall option_init+0x0/0x49 returned 0 after 24912 use=
cs
[   63.091327] calling  sierra_init+0x0/0x49 @ 1
[   63.095681] bus: 'usb-serial': add driver sierra
[   63.100498] USB Serial support registered for Sierra USB modem
[   63.106242] bus: 'usb': add driver sierra
[   63.110448] usbcore: registered new interface driver sierra
[   63.115923] sierra: v.1.3.7:USB Driver for Sierra Wireless USB modem=
s
[   63.122320] initcall sierra_init+0x0/0x49 returned 0 after 26019 use=
cs
[   63.128842] calling  spcp8x5_init+0x0/0x49 @ 1
[   63.133261] bus: 'usb-serial': add driver SPCP8x5
[   63.138164] USB Serial support registered for SPCP8x5
[   63.143131] bus: 'usb': add driver spcp8x5
[   63.147432] usbcore: registered new interface driver spcp8x5
[   63.152997] spcp8x5: v0.04:SPCP8x5 USB to serial adaptor driver
[   63.158869] initcall spcp8x5_init+0x0/0x49 returned 0 after 25013 us=
ecs
[   63.165472] calling  symbol_init+0x0/0x3a @ 1
[   63.169791] bus: 'usb-serial': add driver symbol
[   63.174648] USB Serial support registered for symbol
[   63.179496] bus: 'usb': add driver symbol
[   63.183752] usbcore: registered new interface driver symbol
[   63.189203] initcall symbol_init+0x0/0x3a returned 0 after 18958 use=
cs
[   63.195727] calling  ti_init+0x0/0x133 @ 1
[   63.199778] bus: 'usb-serial': add driver ti_usb_3410_5052_1
[   63.205669] USB Serial support registered for TI USB 3410 1 port ada=
pter
[   63.212246] bus: 'usb-serial': add driver ti_usb_3410_5052_2
[   63.218154] USB Serial support registered for TI USB 5052 2 port ada=
pter
[   63.224761] bus: 'usb': add driver ti_usb_3410_5052
[   63.229837] usbcore: registered new interface driver ti_usb_3410_505=
2
[   63.236181] ti_usb_3410_5052: v0.9:TI USB 3410/5052 Serial Driver
[   63.242226] initcall ti_init+0x0/0x133 returned 0 after 41455 usecs
[   63.248484] calling  whiteheat_init+0x0/0x63 @ 1
[   63.253078] bus: 'usb-serial': add driver whiteheatnofirm
[   63.258677] USB Serial support registered for Connect Tech - WhiteHE=
AT - (prerenumeration)
[   63.266872] bus: 'usb-serial': add driver whiteheat
[   63.271945] USB Serial support registered for Connect Tech - WhiteHE=
AT
[   63.278377] bus: 'usb': add driver whiteheat
[   63.282869] usbcore: registered new interface driver whiteheat
[   63.288580] whiteheat: v2.0:USB ConnectTech WhiteHEAT driver
[   63.294244] initcall whiteheat_init+0x0/0x63 returned 0 after 40200 =
usecs
[   63.300975] calling  cypress_init+0x0/0x2f @ 1
[   63.305418] bus: 'usb': add driver cypress_cy7c63
[   63.310323] usbcore: registered new interface driver cypress_cy7c63
[   63.316506] initcall cypress_init+0x0/0x2f returned 0 after 10829 us=
ecs
[   63.323077] calling  usb_cytherm_init+0x0/0x3c @ 1
[   63.327830] bus: 'usb': add driver cytherm
[   63.332140] usbcore: registered new interface driver cytherm
[   63.337719] cytherm: v1.0:Cypress USB Thermometer driver
[   63.342998] initcall usb_cytherm_init+0x0/0x3c returned 0 after 1480=
9 usecs
[   63.349907] calling  emi62_init+0x0/0x2d @ 1
[   63.354177] bus: 'usb': add driver emi62 - firmware loader
[   63.359864] usbcore: registered new interface driver emi62 - firmwar=
e loader
[   63.366825] initcall emi62_init+0x0/0x2d returned 0 after 12352 usec=
s
[   63.373224] calling  ftdi_elan_init+0x0/0x139 @ 1
[   63.377887] driver ftdi-elan built at 09:18:19 on Jul  2 2009
[   63.383864] bus: 'usb': add driver ftdi-elan
[   63.388259] usbcore: registered new interface driver ftdi-elan
[   63.394005] initcall ftdi_elan_init+0x0/0x139 returned 0 after 15736=
 usecs
[   63.400817] calling  usb_idmouse_init+0x0/0x3a @ 1
[   63.405603] idmouse: 0.6:Siemens ID Mouse FingerTIP Sensor Driver
[   63.411653] bus: 'usb': add driver idmouse
[   63.415990] usbcore: registered new interface driver idmouse
[   63.421542] initcall usb_idmouse_init+0x0/0x3a returned 0 after 1556=
7 usecs
[   63.428488] calling  iowarrior_init+0x0/0x16 @ 1
[   63.433079] bus: 'usb': add driver iowarrior
[   63.437542] usbcore: registered new interface driver iowarrior
[   63.443294] initcall iowarrior_init+0x0/0x16 returned 0 after 9977 u=
secs
[   63.449931] calling  usb_lcd_init+0x0/0x2f @ 1
[   63.454375] bus: 'usb': add driver usblcd
[   63.458585] usbcore: registered new interface driver usblcd
[   63.464075] initcall usb_lcd_init+0x0/0x2f returned 0 after 9474 use=
cs
[   63.470541] calling  usb_led_init+0x0/0x2f @ 1
[   63.474984] bus: 'usb': add driver usbled
[   63.479195] usbcore: registered new interface driver usbled
[   63.484684] initcall usb_led_init+0x0/0x2f returned 0 after 9474 use=
cs
[   63.491151] calling  usb_rio_init+0x0/0x2d @ 1
[   63.495595] bus: 'usb': add driver rio500
[   63.499806] usbcore: registered new interface driver rio500
[   63.505291] rio500: v1.1:USB Rio 500 driver
[   63.509424] initcall usb_rio_init+0x0/0x2d returned 0 after 13509 us=
ecs
[   63.516026] calling  tv_init+0x0/0x3c @ 1
[   63.519999] bus: 'usb': add driver trancevibrator
[   63.524940] usbcore: registered new interface driver trancevibrator
[   63.531092] trancevibrator: v1.1:PlayStation 2 Trance Vibrator drive=
r
[   63.537531] initcall tv_init+0x0/0x3c returned 0 after 17119 usecs
[   63.543674] calling  uss720_init+0x0/0x4d @ 1
[   63.547993] bus: 'usb': add driver uss720
[   63.552216] usbcore: registered new interface driver uss720
[   63.557708] uss720: v0.6:USB Parport Cable driver for Cables using t=
he Lucent Technologies USS720 Chip
[   63.566968] uss720: NOTE: this is a special purpose driver to allow =
nonstandard
[   63.574248] uss720: protocols (eg. bitbang) over USS720 usb to paral=
lel cables
[   63.581421] uss720: If you just want to connect to a printer, use us=
blp instead
[   63.588724] initcall uss720_init+0x0/0x4d returned 0 after 39775 use=
cs
[   63.595223] calling  usb_sevseg_init+0x0/0x2f @ 1
[   63.599889] bus: 'usb': add driver usbsevseg
[   63.604395] usbcore: registered new interface driver usbsevseg
[   63.610113] initcall usb_sevseg_init+0x0/0x2f returned 0 after 9986 =
usecs
[   63.616890] calling  usb_sisusb_init+0x0/0x1b @ 1
[   63.621548] bus: 'usb': add driver sisusb
[   63.625800] usbcore: registered new interface driver sisusb
[   63.631267] initcall usb_sisusb_init+0x0/0x1b returned 0 after 9493 =
usecs
[   63.638035] calling  i8042_init+0x0/0xfc @ 1
[   63.642261] bus: 'pnp': add driver i8042 kbd
[   63.646556] bus: 'pnp': driver_probe_device: matched device 00:0b wi=
th driver i8042 kbd
[   63.654496] bus: 'pnp': really_probe: probing driver i8042 kbd with =
device 00:0b
[   63.661873] driver: '00:0b': driver_bound: bound to device 'i8042 kb=
d'
[   63.668361] bus: 'pnp': really_probe: bound device 00:0b to driver i=
8042 kbd
[   63.675600] bus: 'pnp': add driver i8042 aux
[   63.679787] bus: 'pnp': driver_probe_device: matched device 00:0a wi=
th driver i8042 aux
[   63.687748] bus: 'pnp': really_probe: probing driver i8042 aux with =
device 00:0a
[   63.695135] driver: '00:0a': driver_bound: bound to device 'i8042 au=
x'
[   63.701588] bus: 'pnp': really_probe: bound device 00:0a to driver i=
8042 aux
[   63.708862] PNP: PS/2 Controller [PNP0303:PS2K,PNP0f13:PS2M] at 0x60=
,0x64 irq 1,12
[   63.717085] Platform driver 'i8042' needs updating - please use dev_=
pm_ops
[   63.723858] bus: 'platform': add driver i8042
[   63.728434] Registering platform device 'i8042'. Parent at platform
[   63.734613] device: 'i8042': device_add
[   63.738419] bus: 'platform': add device i8042
[   63.742806] PM: Adding info for platform:i8042
[   63.747370] bus: 'platform': driver_probe_device: matched device i80=
42 with driver i8042
[   63.755393] bus: 'platform': really_probe: probing driver i8042 with=
 device i8042
[   63.766076] serio: i8042 KBD port at 0x60,0x64 irq 1
[   63.770966] serio: i8042 AUX port at 0x60,0x64 irq 12
[   63.771007] device: 'serio0': device_add
[   63.771076] bus: 'serio': add device serio0
[   63.771175] PM: Adding info for serio:serio0
[   63.788300] driver: 'i8042': driver_bound: bound to device 'i8042'
[   63.788304] device: 'serio1': device_add
[   63.788328] bus: 'serio': add device serio1
[   63.788413] PM: Adding info for serio:serio1
[   63.806736] bus: 'platform': really_probe: bound device i8042 to dri=
ver i8042
[   63.813848] initcall i8042_init+0x0/0xfc returned 0 after 167563 use=
cs
[   63.820324] calling  serport_init+0x0/0x2b @ 1
[   63.824768] initcall serport_init+0x0/0x2b returned 0 after 3 usecs
[   63.830984] calling  ct82c710_init+0x0/0xa7 @ 1
[   63.835529] initcall ct82c710_init+0x0/0xa7 returned -19 after 17 us=
ecs
[   63.842077] calling  serio_raw_init+0x0/0x16 @ 1
[   63.846692] bus: 'serio': add driver serio_raw
[   63.851356] initcall serio_raw_init+0x0/0x16 returned 0 after 4556 u=
secs
[   63.857963] calling  emu_init+0x0/0x16 @ 1
[   63.862026] bus: 'pci': add driver Emu10k1_gameport
[   63.867176] initcall emu_init+0x0/0x16 returned 0 after 5037 usecs
[   63.873261] calling  fm801_gp_init+0x0/0x16 @ 1
[   63.877753] bus: 'pci': add driver FM801_gameport
[   63.882718] initcall fm801_gp_init+0x0/0x16 returned 0 after 4853 us=
ecs
[   63.889207] calling  l4_init+0x0/0x7e @ 1
[   63.893241] initcall l4_init+0x0/0x7e returned -19 after 18 usecs
[   63.899261] calling  ns558_init+0x0/0x4f @ 1
[   63.903529] bus: 'pnp': add driver ns558
[   63.907458] bus: 'pnp': driver_probe_device: matched device 00:0d wi=
th driver ns558
[   63.915052] bus: 'pnp': really_probe: probing driver ns558 with devi=
ce 00:0d
[   63.922141] driver: '00:0d': driver_bound: bound to device 'ns558'
[   63.928226] bus: 'pnp': really_probe: bound device 00:0d to driver n=
s558
[   63.941183] gameport: NS558 PnP Gameport is pnp00:0d/gameport0, io 0=
x201, speed 59659kHz
[   63.948408] initcall ns558_init+0x0/0x4f returned 0 after 43830 usec=
s
[   63.948412] calling  mousedev_init+0x0/0x78 @ 1
[   63.948456] device: 'mice': device_add
[   63.948718] PM: Adding info for No Bus:mice
[   63.948975] device: 'psaux': device_add
[   63.949102] PM: Adding info for No Bus:psaux
[   63.949322] mice: PS/2 mouse device common for all mice
[   63.949329] initcall mousedev_init+0x0/0x78 returned 0 after 888 use=
cs
[   63.949333] calling  joydev_init+0x0/0xf @ 1
[   63.949342] initcall joydev_init+0x0/0xf returned 0 after 4 usecs
[   63.949346] calling  evdev_init+0x0/0xf @ 1
[   63.949367] device: 'event0': device_add
[   63.949601] PM: Adding info for No Bus:event0
[   63.949955] device: 'event1': device_add
[   63.950124] PM: Adding info for No Bus:event1
[   63.950377] initcall evdev_init+0x0/0xf returned 0 after 1000 usecs
[   63.950381] calling  evbug_init+0x0/0xf @ 1
[   63.950393] evbug.c: Connected device: input0 (Power Button at LNXPW=
RBN/button/input0)
[   63.950402] evbug.c: Connected device: input1 (Power Button at PNP0C=
0C/button/input0)
[   63.950409] initcall evbug_init+0x0/0xf returned 0 after 21 usecs
[   63.950412] calling  atkbd_init+0x0/0x20 @ 1
[   63.950422] bus: 'serio': add driver atkbd
[   63.950691] initcall atkbd_init+0x0/0x20 returned 0 after 266 usecs
[   63.950694] calling  sunkbd_init+0x0/0x16 @ 1
[   63.950699] bus: 'serio': add driver sunkbd
[   63.950805] bus: 'serio': driver_probe_device: matched device serio0=
 with driver atkbd
[   63.950808] bus: 'serio': really_probe: probing driver atkbd with de=
vice serio0
[   63.951318] initcall sunkbd_init+0x0/0x16 returned 0 after 603 usecs
[   63.951322] calling  xtkbd_init+0x0/0x16 @ 1
[   63.951327] bus: 'serio': add driver xtkbd
[   63.951619] initcall xtkbd_init+0x0/0x16 returned 0 after 283 usecs
[   63.951622] calling  nkbd_init+0x0/0x16 @ 1
[   63.951627] bus: 'serio': add driver newtonkbd
[   63.951906] initcall nkbd_init+0x0/0x16 returned 0 after 271 usecs
[   63.951910] calling  atp_init+0x0/0x16 @ 1
[   63.951921] bus: 'usb': add driver appletouch
[   63.952173] usbcore: registered new interface driver appletouch
[   63.952185] initcall atp_init+0x0/0x16 returned 0 after 262 usecs
[   63.952189] calling  bcm5974_init+0x0/0x16 @ 1
[   63.952199] bus: 'usb': add driver bcm5974
[   63.952431] usbcore: registered new interface driver bcm5974
[   63.952443] initcall bcm5974_init+0x0/0x16 returned 0 after 242 usec=
s
[   63.952447] calling  inport_init+0x0/0x124 @ 1
[   63.952463] inport.c: Didn't find InPort mouse at 0x23c
[   63.952473] initcall inport_init+0x0/0x124 returned -19 after 19 use=
cs
[   63.952477] calling  logibm_init+0x0/0x12c @ 1
[   63.952596] logibm.c: Didn't find Logitech busmouse at 0x23c
[   63.952606] initcall logibm_init+0x0/0x12c returned -19 after 113 us=
ecs
[   63.952609] calling  psmouse_init+0x0/0x67 @ 1
[   63.952685] bus: 'serio': add driver psmouse
[   63.952941] initcall psmouse_init+0x0/0x67 returned 0 after 318 usec=
s
[   63.952945] calling  synaptics_i2c_init+0x0/0x11 @ 1
[   63.952952] bus: 'i2c': add driver synaptics_i2c
[   63.953183] i2c-core: driver [synaptics_i2c] registered
[   63.953193] initcall synaptics_i2c_init+0x0/0x11 returned 0 after 23=
6 usecs
[   63.953197] calling  a3d_init+0x0/0x16 @ 1
[   63.953203] bus: 'gameport': add driver adc
[   63.953445] initcall a3d_init+0x0/0x16 returned 0 after 235 usecs
[   63.953448] calling  adi_init+0x0/0x16 @ 1
[   63.953454] bus: 'gameport': add driver adi
[   63.953693] initcall adi_init+0x0/0x16 returned 0 after 233 usecs
[   63.953697] calling  cobra_init+0x0/0x16 @ 1
[   63.953702] bus: 'gameport': add driver cobra
[   63.954008] initcall cobra_init+0x0/0x16 returned 0 after 297 usecs
[   63.954012] calling  db9_init+0x0/0x9a @ 1
[   63.954020] initcall db9_init+0x0/0x9a returned -19 after 2 usecs
[   63.954024] calling  gf2k_init+0x0/0x16 @ 1
[   63.954029] bus: 'gameport': add driver gf2k
[   63.954271] initcall gf2k_init+0x0/0x16 returned 0 after 235 usecs
[   63.954275] calling  grip_init+0x0/0x16 @ 1
[   63.954280] bus: 'gameport': add driver grip
[   63.954519] initcall grip_init+0x0/0x16 returned 0 after 232 usecs
[   63.954522] calling  grip_init+0x0/0x16 @ 1
[   63.954528] bus: 'gameport': add driver grip_mp
[   63.954782] initcall grip_init+0x0/0x16 returned 0 after 247 usecs
[   63.954786] calling  guillemot_init+0x0/0x16 @ 1
[   63.954791] bus: 'gameport': add driver guillemot
[   63.955032] initcall guillemot_init+0x0/0x16 returned 0 after 234 us=
ecs
[   63.955036] calling  iforce_init+0x0/0x41 @ 1
[   63.955046] bus: 'usb': add driver iforce
[   63.955301] usbcore: registered new interface driver iforce
[   63.955311] bus: 'serio': add driver iforce
[   63.955566] initcall iforce_init+0x0/0x41 returned 0 after 511 usecs
[   63.955570] calling  interact_init+0x0/0x16 @ 1
[   63.955575] bus: 'gameport': add driver interact
[   63.955819] initcall interact_init+0x0/0x16 returned 0 after 237 use=
cs
[   63.955823] calling  joydump_init+0x0/0x16 @ 1
[   63.955827] bus: 'gameport': add driver joydump
[   63.956071] initcall joydump_init+0x0/0x16 returned 0 after 236 usec=
s
[   63.956075] calling  sw_init+0x0/0x16 @ 1
[   63.956080] bus: 'gameport': add driver sidewinder
[   63.956318] initcall sw_init+0x0/0x16 returned 0 after 231 usecs
[   63.956321] calling  spaceball_init+0x0/0x16 @ 1
[   63.956327] bus: 'serio': add driver spaceball
[   63.956599] initcall spaceball_init+0x0/0x16 returned 0 after 264 us=
ecs
[   63.956603] calling  spaceorb_init+0x0/0x16 @ 1
[   63.956608] bus: 'serio': add driver spaceorb
[   63.956860] initcall spaceorb_init+0x0/0x16 returned 0 after 245 use=
cs
[   63.956864] calling  stinger_init+0x0/0x16 @ 1
[   63.956869] bus: 'serio': add driver stinger
[   63.957118] initcall stinger_init+0x0/0x16 returned 0 after 241 usec=
s
[   63.957122] calling  tgfx_init+0x0/0xa4 @ 1
[   63.957130] initcall tgfx_init+0x0/0xa4 returned -19 after 2 usecs
[   63.957133] calling  warrior_init+0x0/0x16 @ 1
[   63.957138] bus: 'serio': add driver warrior
[   63.957395] initcall warrior_init+0x0/0x16 returned 0 after 249 usec=
s
[   63.957399] calling  walkera0701_init+0x0/0x15 @ 1
[   63.957455] initcall walkera0701_init+0x0/0x15 returned -19 after 48=
 usecs
[   63.957458] calling  ad7877_init+0x0/0xf @ 1
[   63.957465] bus: 'spi': add driver ad7877
[   63.957697] initcall ad7877_init+0x0/0xf returned 0 after 226 usecs
[   63.957701] calling  ad7879_init+0x0/0x11 @ 1
[   63.957707] bus: 'i2c': add driver ad7879
[   63.957938] i2c-core: driver [ad7879] registered
[   63.957948] initcall ad7879_init+0x0/0x11 returned 0 after 235 usecs
[   63.957951] calling  ads7846_init+0x0/0xf @ 1
[   63.957956] bus: 'spi': add driver ads7846
[   63.958184] initcall ads7846_init+0x0/0xf returned 0 after 222 usecs
[   63.958188] calling  elo_init+0x0/0x16 @ 1
[   63.958193] bus: 'serio': add driver elo
[   63.958445] initcall elo_init+0x0/0x16 returned 0 after 244 usecs
[   63.958448] calling  inexio_init+0x0/0x16 @ 1
[   63.958454] bus: 'serio': add driver inexio
[   63.958701] initcall inexio_init+0x0/0x16 returned 0 after 240 usecs
[   63.958705] calling  mtouch_init+0x0/0x16 @ 1
[   63.958710] bus: 'serio': add driver mtouch
[   63.958963] initcall mtouch_init+0x0/0x16 returned 0 after 245 usecs
[   63.958966] calling  usbtouch_init+0x0/0x16 @ 1
[   63.958977] bus: 'usb': add driver usbtouchscreen
[   63.959214] usbcore: registered new interface driver usbtouchscreen
[   63.959226] initcall usbtouch_init+0x0/0x16 returned 0 after 247 use=
cs
[   63.959230] calling  pm_init+0x0/0x16 @ 1
[   63.959235] bus: 'serio': add driver penmountlpc
[   63.959488] initcall pm_init+0x0/0x16 returned 0 after 245 usecs
[   63.959492] calling  tr_init+0x0/0x16 @ 1
[   63.959497] bus: 'serio': add driver touchright
[   63.959748] initcall tr_init+0x0/0x16 returned 0 after 244 usecs
[   63.959752] calling  tw_init+0x0/0x16 @ 1
[   63.959757] bus: 'serio': add driver touchwin
[   63.960038] initcall tw_init+0x0/0x16 returned 0 after 273 usecs
[   63.960042] calling  tsc2007_init+0x0/0x11 @ 1
[   63.960048] bus: 'i2c': add driver tsc2007
[   63.960273] i2c-core: driver [tsc2007] registered
[   63.960281] initcall tsc2007_init+0x0/0x11 returned 0 after 227 usec=
s
[   63.960285] calling  w8001_init+0x0/0x16 @ 1
[   63.960289] bus: 'serio': add driver w8001
[   63.960537] initcall w8001_init+0x0/0x16 returned 0 after 240 usecs
[   63.960541] calling  da9034_touch_init+0x0/0xf @ 1
[   63.960549] bus: 'platform': add driver da9034-touch
[   63.960789] initcall da9034_touch_init+0x0/0xf returned 0 after 236 =
usecs
[   63.960794] calling  w90x900ts_init+0x0/0xf @ 1
[   63.960800] bus: 'platform': add driver w90x900-ts
[   63.961036] initcall w90x900ts_init+0x0/0xf returned 0 after 230 use=
cs
[   63.961040] calling  ati_remote_init+0x0/0x3c @ 1
[   63.961050] bus: 'usb': add driver ati_remote
[   63.961282] usbcore: registered new interface driver ati_remote
[   63.961291] ati_remote: 2.2.1:ATI/X10 RF USB Remote Control
[   63.961297] initcall ati_remote_init+0x0/0x3c returned 0 after 245 u=
secs
[   63.961301] calling  atlas_acpi_init+0x0/0x35 @ 1
[   63.961308] bus: 'acpi': add driver Atlas ACPI
[   63.961594] initcall atlas_acpi_init+0x0/0x35 returned 0 after 280 u=
secs
[   63.961598] calling  cm109_init+0x0/0x38 @ 1
[   63.961602] cm109: Keymap for Komunikate KIP1000 phone loaded
[   63.961611] bus: 'usb': add driver cm109
[   63.961845] usbcore: registered new interface driver cm109
[   63.961854] cm109: CM109 phone driver: 20080805 (C) Alfred E. Hegges=
tad
[   63.961861] initcall cm109_init+0x0/0x38 returned 0 after 250 usecs
[   63.961865] calling  usb_keyspan_init+0x0/0x2f @ 1
[   63.961874] bus: 'usb': add driver keyspan_remote
[   63.962107] usbcore: registered new interface driver keyspan_remote
[   63.962120] initcall usb_keyspan_init+0x0/0x2f returned 0 after 242 =
usecs
[   63.962124] calling  pcf50633_input_init+0x0/0xf @ 1
[   63.962131] bus: 'platform': add driver pcf50633-input
[   63.962366] initcall pcf50633_input_init+0x0/0xf returned 0 after 23=
0 usecs
[   63.962370] calling  powermate_init+0x0/0x16 @ 1
[   63.962380] bus: 'usb': add driver powermate
[   63.962639] usbcore: registered new interface driver powermate
[   63.962651] initcall powermate_init+0x0/0x16 returned 0 after 261 us=
ecs
[   63.962655] calling  twl4030_pwrbutton_init+0x0/0xf @ 1
[   63.962662] bus: 'platform': add driver twl4030_pwrbutton
[   63.962930] initcall twl4030_pwrbutton_init+0x0/0xf returned 0 after=
 262 usecs
[   63.962934] calling  uinput_init+0x0/0xf @ 1
[   63.962954] device: 'uinput': device_add
[   63.963245] PM: Adding info for No Bus:uinput
[   63.963474] initcall uinput_init+0x0/0xf returned 0 after 521 usecs
[   63.963478] calling  wb_module_init+0x0/0x10a @ 1
[   63.963495] wistron_btns: System unknown
[   63.963502] initcall wb_module_init+0x0/0x10a returned -19 after 17 =
usecs
[   63.963505] calling  yealink_dev_init+0x0/0x2d @ 1
[   63.963517] bus: 'usb': add driver yealink
[   63.963757] usbcore: registered new interface driver yealink
[   63.963765] yealink: yld-20051230:Yealink phone driver
[   63.963772] initcall yealink_dev_init+0x0/0x2d returned 0 after 253 =
usecs
[   63.963776] calling  i2o_iop_init+0x0/0x41 @ 1
[   63.963780] I2O subsystem v1.325
[   63.963782] i2o: max drivers =3D 8
[   63.964051] bus: 'i2o': registered
[   63.964238] bus: 'i2o': add driver exec-osm
[   63.964482] bus: 'pci': add driver PCI_I2O
[   63.964768] initcall i2o_iop_init+0x0/0x41 returned 0 after 962 usec=
s
[   63.964772] calling  i2o_config_init+0x0/0x38 @ 1
[   63.964776] I2O Configuration OSM v1.323
[   63.964780] bus: 'i2o': add driver config-osm
[   63.965011] initcall i2o_config_init+0x0/0x38 returned 0 after 226 u=
secs
[   63.965015] calling  i2o_bus_init+0x0/0x37 @ 1
[   63.965019] I2O Bus Adapter OSM v1.317
[   63.965022] bus: 'i2o': add driver bus-osm
[   63.965253] initcall i2o_bus_init+0x0/0x37 returned 0 after 226 usec=
s
[   63.965257] calling  i2o_block_init+0x0/0xf7 @ 1
[   63.965261] I2O Block Device OSM v1.325
[   63.966063] bus: 'i2o': add driver block-osm
[   63.966297] initcall i2o_block_init+0x0/0xf7 returned 0 after 1010 u=
secs
[   63.966302] calling  i2o_scsi_init+0x0/0x37 @ 1
[   63.966306] I2O SCSI Peripheral OSM v1.316
[   63.966309] bus: 'i2o': add driver scsi-osm
[   63.966574] initcall i2o_scsi_init+0x0/0x37 returned 0 after 259 use=
cs
[   63.966578] calling  i2o_proc_init+0x0/0x75 @ 1
[   63.966581] I2O ProcFS OSM v1.316
[   63.966585] bus: 'i2o': add driver proc-osm
[   63.966842] initcall i2o_proc_init+0x0/0x75 returned 0 after 251 use=
cs
[   63.966846] calling  cmos_init+0x0/0x3d @ 1
[   63.966852] bus: 'pnp': add driver rtc_cmos
[   63.966884] bus: 'pnp': driver_probe_device: matched device 00:04 wi=
th driver rtc_cmos
[   63.966887] bus: 'pnp': really_probe: probing driver rtc_cmos with d=
evice 00:04
[   63.966943] rtc_cmos 00:04: RTC can wake from S4
[   63.967117] device: 'rtc0': device_add
[   63.967458] PM: Adding info for No Bus:rtc0
[   63.967767] rtc_cmos: dev (254:0)
[   63.967798] rtc_cmos 00:04: rtc core: registered rtc_cmos as rtc0
[   63.967866] rtc0: alarms up to one year, y3k, 242 bytes nvram
[   63.967869] driver: '00:04': driver_bound: bound to device 'rtc_cmos=
'
[   63.967872] bus: 'pnp': really_probe: bound device 00:04 to driver r=
tc_cmos
[   63.968098] initcall cmos_init+0x0/0x3d returned 0 after 1216 usecs
[   63.968103] calling  ds1286_init+0x0/0xf @ 1
[   63.968111] bus: 'platform': add driver rtc-ds1286
[   63.968356] initcall ds1286_init+0x0/0xf returned 0 after 241 usecs
[   63.968360] calling  ds1307_init+0x0/0x11 @ 1
[   63.968367] bus: 'i2c': add driver rtc-ds1307
[   63.968593] i2c-core: driver [rtc-ds1307] registered
[   63.968603] initcall ds1307_init+0x0/0x11 returned 0 after 230 usecs
[   63.968606] calling  ds1374_init+0x0/0x11 @ 1
[   63.968612] bus: 'i2c': add driver rtc-ds1374
[   63.968844] i2c-core: driver [rtc-ds1374] registered
[   63.968853] initcall ds1374_init+0x0/0x11 returned 0 after 234 usecs
[   63.968857] calling  ds1511_rtc_init+0x0/0xf @ 1
[   63.968864] bus: 'platform': add driver ds1511
[   63.969097] initcall ds1511_rtc_init+0x0/0xf returned 0 after 228 us=
ecs
[   63.969101] calling  ds1553_init+0x0/0xf @ 1
[   63.969107] bus: 'platform': add driver rtc-ds1553
[   63.969343] initcall ds1553_init+0x0/0xf returned 0 after 229 usecs
[   63.969347] calling  ds1742_init+0x0/0xf @ 1
[   63.969354] bus: 'platform': add driver rtc-ds1742
[   63.969593] initcall ds1742_init+0x0/0xf returned 0 after 234 usecs
[   63.969596] calling  m41t80_rtc_init+0x0/0x11 @ 1
[   63.969602] bus: 'i2c': add driver rtc-m41t80
[   63.969833] i2c-core: driver [rtc-m41t80] registered
[   63.969841] initcall m41t80_rtc_init+0x0/0x11 returned 0 after 233 u=
secs
[   63.969844] calling  m41t94_init+0x0/0xf @ 1
[   63.969850] bus: 'spi': add driver rtc-m41t94
[   63.970107] initcall m41t94_init+0x0/0xf returned 0 after 251 usecs
[   63.970110] calling  m48t35_init+0x0/0xf @ 1
[   63.970118] bus: 'platform': add driver rtc-m48t35
[   63.970352] initcall m48t35_init+0x0/0xf returned 0 after 230 usecs
[   63.970356] calling  m48t59_rtc_init+0x0/0xf @ 1
[   63.970363] bus: 'platform': add driver rtc-m48t59
[   63.970595] initcall m48t59_rtc_init+0x0/0xf returned 0 after 228 us=
ecs
[   63.970599] calling  m48t86_rtc_init+0x0/0xf @ 1
[   63.970606] bus: 'platform': add driver rtc-m48t86
[   63.970839] initcall m48t86_rtc_init+0x0/0xf returned 0 after 229 us=
ecs
[   63.970843] calling  bq4802_init+0x0/0xf @ 1
[   63.970850] bus: 'platform': add driver rtc-bq4802
[   63.971080] initcall bq4802_init+0x0/0xf returned 0 after 226 usecs
[   63.971084] calling  max6900_init+0x0/0x11 @ 1
[   63.971090] bus: 'i2c': add driver rtc-max6900
[   63.971316] i2c-core: driver [rtc-max6900] registered
[   63.971324] initcall max6900_init+0x0/0x11 returned 0 after 229 usec=
s
[   63.971328] calling  max6902_init+0x0/0xf @ 1
[   63.971333] bus: 'spi': add driver rtc-max6902
[   63.971569] initcall max6902_init+0x0/0xf returned 0 after 230 usecs
[   63.971572] calling  rs5c348_init+0x0/0xf @ 1
[   63.971578] bus: 'spi': add driver rtc-rs5c348
[   63.971810] initcall rs5c348_init+0x0/0xf returned 0 after 226 usecs
[   63.971813] calling  rs5c372_init+0x0/0x11 @ 1
[   63.971820] bus: 'i2c': add driver rtc-rs5c372
[   63.972044] i2c-core: driver [rtc-rs5c372] registered
[   63.972052] initcall rs5c372_init+0x0/0x11 returned 0 after 227 usec=
s
[   63.972055] calling  rx8581_init+0x0/0x11 @ 1
[   63.972060] bus: 'i2c': add driver rtc-rx8581
[   63.972293] i2c-core: driver [rtc-rx8581] registered
[   63.972301] initcall rx8581_init+0x0/0x11 returned 0 after 235 usecs
[   63.972304] calling  s35390a_rtc_init+0x0/0x11 @ 1
[   63.972311] bus: 'i2c': add driver rtc-s35390a
[   63.972566] i2c-core: driver [rtc-s35390a] registered
[   63.972573] initcall s35390a_rtc_init+0x0/0x11 returned 0 after 249 =
usecs
[   63.972576] calling  stk17ta8_init+0x0/0xf @ 1
[   63.972585] bus: 'platform': add driver stk17ta8
[   63.972820] initcall stk17ta8_init+0x0/0xf returned 0 after 232 usec=
s
[   63.972823] calling  twl4030_rtc_init+0x0/0xf @ 1
[   63.972828] Platform driver 'twl4030_rtc' needs updating - please us=
e dev_pm_ops
[   63.972833] bus: 'platform': add driver twl4030_rtc
[   63.973069] initcall twl4030_rtc_init+0x0/0xf returned 0 after 234 u=
secs
[   63.973072] calling  v3020_init+0x0/0xf @ 1
[   63.973079] bus: 'platform': add driver v3020
[   63.973314] initcall v3020_init+0x0/0xf returned 0 after 231 usecs
[   63.973318] calling  x1205_init+0x0/0x11 @ 1
[   63.973324] bus: 'i2c': add driver rtc-x1205
[   63.973518] device: 'input2': device_add
[   63.973821] PM: Adding info for No Bus:input2
[   63.974216] i2c-core: driver [rtc-x1205] registered
[   63.974223] initcall x1205_init+0x0/0x11 returned 0 after 879 usecs
[   63.974227] calling  pcf50633_rtc_init+0x0/0xf @ 1
[   63.974235] bus: 'platform': add driver pcf50633-rtc
[   63.974501] input: AT Translated Set 2 keyboard as /class/input/inpu=
t2
[   63.974566] device: 'event2': device_add
[   63.974925] PM: Adding info for No Bus:event2
[   63.975191] initcall pcf50633_rtc_init+0x0/0xf returned 0 after 935 =
usecs
[   63.975195] calling  i2c_ali15x3_init+0x0/0x16 @ 1
[   63.975213] bus: 'pci': add driver ali15x3_smbus
[   63.975498] evbug.c: Connected device: input2 (AT Translated Set 2 k=
eyboard at isa0060/serio0/input0)
[   63.975505] driver: 'serio0': driver_bound: bound to device 'atkbd'
[   63.975509] bus: 'serio': really_probe: bound device serio0 to drive=
r atkbd
[   63.975525] bus: 'serio': driver_probe_device: matched device serio1=
 with driver atkbd
[   63.975528] bus: 'serio': really_probe: probing driver atkbd with de=
vice serio1
[   63.975736] initcall i2c_ali15x3_init+0x0/0x16 returned 0 after 523 =
usecs
[   63.975740] calling  amd756_init+0x0/0x16 @ 1
[   63.975754] bus: 'pci': add driver amd756_smbus
[   63.976014] initcall amd756_init+0x0/0x16 returned 0 after 262 usecs
[   63.976018] calling  i2c_amd8111_init+0x0/0x16 @ 1
[   63.976032] bus: 'pci': add driver amd8111_smbus2
[   63.976293] initcall i2c_amd8111_init+0x0/0x16 returned 0 after 263 =
usecs
[   63.976296] calling  i2c_i801_init+0x0/0x16 @ 1
[   63.976310] bus: 'pci': add driver i801_smbus
[   63.976569] initcall i2c_i801_init+0x0/0x16 returned 0 after 260 use=
cs
[   63.976572] calling  i2c_sch_init+0x0/0x16 @ 1
[   63.976587] bus: 'pci': add driver isch_smbus
[   63.976853] initcall i2c_sch_init+0x0/0x16 returned 0 after 269 usec=
s
[   63.976857] calling  i2c_sis5595_init+0x0/0x16 @ 1
[   63.976871] bus: 'pci': add driver sis5595_smbus
[   63.977130] initcall i2c_sis5595_init+0x0/0x16 returned 0 after 261 =
usecs
[   63.977134] calling  i2c_sis630_init+0x0/0x16 @ 1
[   63.977148] bus: 'pci': add driver sis630_smbus
[   63.977405] initcall i2c_sis630_init+0x0/0x16 returned 0 after 259 u=
secs
[   63.977409] calling  i2c_sis96x_init+0x0/0x16 @ 1
[   63.977422] bus: 'pci': add driver sis96x_smbus
[   63.977694] initcall i2c_sis96x_init+0x0/0x16 returned 0 after 273 u=
secs
[   63.977698] calling  i2c_vt586b_init+0x0/0x16 @ 1
[   63.977712] bus: 'pci': add driver vt586b_smbus
[   63.977970] initcall i2c_vt586b_init+0x0/0x16 returned 0 after 260 u=
secs
[   63.977974] calling  i2c_vt596_init+0x0/0x16 @ 1
[   63.977987] bus: 'pci': add driver vt596_smbus
[   63.978247] initcall i2c_vt596_init+0x0/0x16 returned 0 after 261 us=
ecs
[   63.978251] calling  i2c_parport_init+0x0/0x43 @ 1
[   63.978254] i2c-parport: adapter type unspecified
[   63.978259] initcall i2c_parport_init+0x0/0x43 returned -19 after 3 =
usecs
[   63.978263] calling  i2c_parport_init+0x0/0x12e @ 1
[   63.978267] i2c-parport-light: adapter type unspecified
[   63.978272] initcall i2c_parport_init+0x0/0x12e returned -19 after 3=
 usecs
[   63.978275] calling  scx200_acb_init+0x0/0x41 @ 1
[   63.978352] initcall scx200_acb_init+0x0/0x41 returned -19 after 69 =
usecs
[   63.978358] calling  scx200_i2c_init+0x0/0x106 @ 1
[   63.978362] scx200_i2c: no SCx200 gpio pins available
[   63.978367] initcall scx200_i2c_init+0x0/0x106 returned -19 after 3 =
usecs
[   63.978370] calling  pca9539_init+0x0/0x11 @ 1
[   63.978377] bus: 'i2c': add driver pca9539
[   63.978607] i2c-core: driver [pca9539] registered
[   63.978624] initcall pca9539_init+0x0/0x11 returned 0 after 242 usec=
s
[   63.978628] calling  pcf8574_init+0x0/0x11 @ 1
[   63.978634] bus: 'i2c': add driver pcf8574
[   63.978858] i2c-core: driver [pcf8574] registered
[   63.978886] initcall pcf8574_init+0x0/0x11 returned 0 after 247 usec=
s
[   63.978890] calling  olpc_bat_init+0x0/0xe1 @ 1
[   63.978898] initcall olpc_bat_init+0x0/0xe1 returned -6 after 2 usec=
s
[   63.978902] initcall olpc_bat_init+0x0/0xe1 returned with error code=
 -6=20
[   63.978906] calling  da903x_battery_init+0x0/0x14 @ 1
[   63.978915] bus: 'platform': add driver da903x-battery
[   63.979158] initcall da903x_battery_init+0x0/0x14 returned 0 after 2=
39 usecs
[   63.979161] calling  max17040_init+0x0/0x11 @ 1
[   63.979168] bus: 'i2c': add driver max17040
[   63.979392] i2c-core: driver [max17040] registered
[   63.979400] initcall max17040_init+0x0/0x11 returned 0 after 227 use=
cs
[   63.979404] calling  asb100_init+0x0/0x11 @ 1
[   63.979411] bus: 'i2c': add driver asb100
[   63.979637] i2c-core: driver [asb100] registered
[   63.979652] initcall asb100_init+0x0/0x11 returned 0 after 236 usecs
[   63.979655] calling  sensors_w83793_init+0x0/0x11 @ 1
[   63.979662] bus: 'i2c': add driver w83793
[   63.979907] i2c-core: driver [w83793] registered
[   63.979923] initcall sensors_w83793_init+0x0/0x11 returned 0 after 2=
55 usecs
[   63.979926] calling  sensors_w83781d_init+0x0/0x5c @ 1
[   63.979974] w83781d: Detection failed at step 3
[   63.979985] bus: 'i2c': add driver w83781d
[   63.980217] i2c-core: driver [w83781d] registered
[   63.980232] initcall sensors_w83781d_init+0x0/0x5c returned 0 after =
293 usecs
[   63.980236] calling  sensors_w83791d_init+0x0/0x11 @ 1
[   63.980242] bus: 'i2c': add driver w83791d
[   63.980470] i2c-core: driver [w83791d] registered
[   63.980487] initcall sensors_w83791d_init+0x0/0x11 returned 0 after =
240 usecs
[   63.980490] calling  abituguru_init+0x0/0x163 @ 1
[   63.980498] initcall abituguru_init+0x0/0x163 returned -19 after 2 u=
secs
[   63.980502] calling  sensors_adm1021_init+0x0/0x11 @ 1
[   63.980508] bus: 'i2c': add driver adm1021
[   63.980739] i2c-core: driver [adm1021] registered
[   63.980755] initcall sensors_adm1021_init+0x0/0x11 returned 0 after =
241 usecs
[   63.980759] calling  sensors_adm1029_init+0x0/0x11 @ 1
[   63.980765] bus: 'i2c': add driver adm1029
[   63.981058] bus: 'serio': driver_probe_device: matched device serio1=
 with driver psmouse
[   63.981062] bus: 'serio': really_probe: probing driver psmouse with =
device serio1
[   63.981310] i2c-core: driver [adm1029] registered
[   63.981325] initcall sensors_adm1029_init+0x0/0x11 returned 0 after =
547 usecs
[   63.981328] calling  sensors_adm1031_init+0x0/0x11 @ 1
[   63.981335] bus: 'i2c': add driver adm1031
[   63.981565] i2c-core: driver [adm1031] registered
[   63.981580] initcall sensors_adm1031_init+0x0/0x11 returned 0 after =
240 usecs
[   63.981583] calling  adt7462_init+0x0/0x11 @ 1
[   63.981590] bus: 'i2c': add driver adt7462
[   63.981816] i2c-core: driver [adt7462] registered
[   63.981831] initcall adt7462_init+0x0/0x11 returned 0 after 236 usec=
s
[   63.981834] calling  adt7473_init+0x0/0x11 @ 1
[   63.981841] bus: 'i2c': add driver adt7473
[   63.982072] i2c-core: driver [adt7473] registered
[   63.982087] initcall adt7473_init+0x0/0x11 returned 0 after 241 usec=
s
[   63.982091] calling  atk0110_init+0x0/0x28 @ 1
[   63.982098] bus: 'acpi': add driver ATK0110
[   63.982145] bus: 'acpi': driver_probe_device: matched device ATK0110=
:00 with driver ATK0110
[   63.982148] bus: 'acpi': really_probe: probing driver ATK0110 with d=
evice ATK0110:00
[   63.982176] ATK0110 ATK0110:00: adding...
[   63.982374] ATK0110 ATK0110:00: board ID =3D A8N-E
[   63.982407] ATK0110 ATK0110:00: Using old hwmon interface
[   63.983505] ATK0110 ATK0110:00: voltage: 0x6020000 Vcore Voltage [14=
50-1750] enabled
[   63.983521] ATK0110 ATK0110:00: voltage: 0x6020001  +3.3 Voltage [30=
00-3600] enabled
[   63.983537] ATK0110 ATK0110:00: voltage: 0x6020002  +5.0 Voltage [45=
00-5500] enabled
[   63.983552] ATK0110 ATK0110:00: voltage: 0x6020003 +12.0 Voltage [11=
200-13200] enabled
[   63.984196] ATK0110 ATK0110:00: temperature: 0x6030000 CPU Temperatu=
re [900-1250] enabled
[   63.984212] ATK0110 ATK0110:00: temperature: 0x6030001 MB Temperatur=
e [700-1250] enabled
[   63.985488] ATK0110 ATK0110:00: fan: 0x6040000 CPU FAN Speed [0-1800=
] enabled
[   63.985514] ATK0110 ATK0110:00: fan: 0x6040001 CHASSIS FAN Speed [0-=
1800] enabled
[   63.985532] ATK0110 ATK0110:00: fan: 0x6040002 POWER FAN Speed [0-18=
00] disabled
[   63.985536] ATK0110 ATK0110:00: fan: 0x6040005 CHIPSET FAN Speed [0-=
1800] enabled
[   63.985551] ATK0110 ATK0110:00: fan: 0x6040006 CHASSIS2 FAN Speed [0=
-1800] disabled
[   63.985557] ATK0110 ATK0110:00: registering hwmon device
[   63.985584] device: 'hwmon1': device_add
[   63.985684] PM: Adding info for No Bus:hwmon1
[   63.985925] ATK0110 ATK0110:00: populating sysfs directory
[   63.986193] driver: 'ATK0110:00': driver_bound: bound to device 'ATK=
0110'
[   63.986196] bus: 'acpi': really_probe: bound device ATK0110:00 to dr=
iver ATK0110
[   63.986443] initcall atk0110_init+0x0/0x28 returned 0 after 4239 use=
cs
[   63.986447] calling  atxp1_init+0x0/0x11 @ 1
[   63.986454] bus: 'i2c': add driver atxp1
[   63.986685] i2c-core: driver [atxp1] registered
[   63.986700] initcall atxp1_init+0x0/0x11 returned 0 after 241 usecs
[   63.986704] calling  coretemp_init+0x0/0x13a @ 1
[   63.986711] initcall coretemp_init+0x0/0x13a returned -19 after 2 us=
ecs
[   63.986715] calling  dme1737_init+0x0/0xa0 @ 1
[   63.986722] bus: 'i2c': add driver dme1737
[   63.987079] i2c-core: driver [dme1737] registered
[   63.987114] initcall dme1737_init+0x0/0xa0 returned 0 after 384 usec=
s
[   63.987118] calling  ds1621_init+0x0/0x11 @ 1
[   63.987125] bus: 'i2c': add driver ds1621
[   63.987350] i2c-core: driver [ds1621] registered
[   63.987365] initcall ds1621_init+0x0/0x11 returned 0 after 236 usecs
[   63.987368] calling  f71882fg_init+0x0/0x72 @ 1
[   63.987385] f71882fg: Not a Fintek device
[   63.987402] f71882fg: Not a Fintek device
[   63.987409] initcall f71882fg_init+0x0/0x72 returned -19 after 34 us=
ecs
[   63.987413] calling  sensors_f75375_init+0x0/0x11 @ 1
[   63.987420] bus: 'i2c': add driver f75375
[   63.987648] i2c-core: driver [f75375] registered
[   63.987663] initcall sensors_f75375_init+0x0/0x11 returned 0 after 2=
38 usecs
[   63.987667] calling  sensors_fscher_init+0x0/0x11 @ 1
[   63.987673] bus: 'i2c': add driver fscher
[   63.987899] i2c-core: driver [fscher] registered
[   63.987915] initcall sensors_fscher_init+0x0/0x11 returned 0 after 2=
37 usecs
[   63.987918] calling  fschmd_init+0x0/0x11 @ 1
[   63.987925] bus: 'i2c': add driver fschmd
[   63.988149] i2c-core: driver [fschmd] registered
[   63.988165] initcall fschmd_init+0x0/0x11 returned 0 after 235 usecs
[   63.988168] calling  sm_fscpos_init+0x0/0x11 @ 1
[   63.988175] bus: 'i2c': add driver fscpos
[   63.988407] i2c-core: driver [fscpos] registered
[   63.988423] initcall sm_fscpos_init+0x0/0x11 returned 0 after 243 us=
ecs
[   63.988426] calling  g760a_init+0x0/0x11 @ 1
[   63.988433] bus: 'i2c': add driver g760a
[   63.988658] i2c-core: driver [g760a] registered
[   63.988665] initcall g760a_init+0x0/0x11 returned 0 after 227 usecs
[   63.988668] calling  sensors_gl518sm_init+0x0/0x11 @ 1
[   63.988675] bus: 'i2c': add driver gl518sm
[   63.988904] i2c-core: driver [gl518sm] registered
[   63.988919] initcall sensors_gl518sm_init+0x0/0x11 returned 0 after =
239 usecs
[   63.988922] calling  sensors_gl520sm_init+0x0/0x11 @ 1
[   63.988929] bus: 'i2c': add driver gl520sm
[   63.989157] i2c-core: driver [gl520sm] registered
[   63.989172] initcall sensors_gl520sm_init+0x0/0x11 returned 0 after =
238 usecs
[   63.989176] calling  hdaps_init+0x0/0x1e7 @ 1
[   63.989189] hdaps: supported laptop not found!
[   63.989191] hdaps: driver init failed (ret=3D-19)!
[   63.989195] initcall hdaps_init+0x0/0x1e7 returned -19 after 14 usec=
s
[   63.989199] calling  i5k_amb_init+0x0/0x52 @ 1
[   63.989208] bus: 'platform': add driver i5k_amb
[   63.989456] Registering platform device 'i5k_amb.0'. Parent at platf=
orm
[   63.989462] device: 'i5k_amb.0': device_add
[   63.989484] bus: 'platform': add device i5k_amb.0
[   63.989544] PM: Adding info for platform:i5k_amb.0
[   63.989771] bus: 'platform': driver_probe_device: matched device i5k=
_amb.0 with driver i5k_amb
[   63.989775] bus: 'platform': really_probe: probing driver i5k_amb wi=
th device i5k_amb.0
[   63.989876] initcall i5k_amb_init+0x0/0x52 returned 0 after 656 usec=
s
[   63.989879] calling  aem_init+0x0/0x42 @ 1
[   63.989887] bus: 'platform': add driver aem
[   63.990124] initcall aem_init+0x0/0x42 returned 0 after 234 usecs
[   63.990128] calling  ibmpex_init+0x0/0xf @ 1
[   63.990137] initcall ibmpex_init+0x0/0xf returned 0 after 3 usecs
[   63.990140] calling  k8temp_init+0x0/0x16 @ 1
[   63.990159] bus: 'pci': add driver k8temp
[   63.990213] bus: 'pci': driver_probe_device: matched device 0000:00:=
18.3 with driver k8temp
[   63.990216] bus: 'pci': really_probe: probing driver k8temp with dev=
ice 0000:00:18.3
[   63.990324] device: 'hwmon2': device_add
[   63.990422] PM: Adding info for No Bus:hwmon2
[   63.990640] driver: '0000:00:18.3': driver_bound: bound to device 'k=
8temp'
[   63.990645] bus: 'pci': really_probe: bound device 0000:00:18.3 to d=
river k8temp
[   63.990876] initcall k8temp_init+0x0/0x16 returned 0 after 713 usecs
[   63.990880] calling  lis3lv02d_init_module+0x0/0x2e @ 1
[   63.990887] bus: 'acpi': add driver lis3lv02d
[   63.991161] lis3lv02d driver loaded.
[   63.991167] initcall lis3lv02d_init_module+0x0/0x2e returned 0 after=
 274 usecs
[   63.991171] calling  sensors_lm63_init+0x0/0x11 @ 1
[   63.991177] bus: 'i2c': add driver lm63
[   63.991603] i2c-core: driver [lm63] registered
[   63.991620] initcall sensors_lm63_init+0x0/0x11 returned 0 after 434=
 usecs
[   63.991624] calling  init_lm70+0x0/0x33 @ 1
[   63.991630] bus: 'spi': add driver lm70
[   63.991856] bus: 'spi': add driver tmp121
[   63.992091] initcall init_lm70+0x0/0x33 returned 0 after 451 usecs
[   63.992095] calling  sensors_lm77_init+0x0/0x11 @ 1
[   63.992103] bus: 'i2c': add driver lm77
[   63.992334] i2c-core: driver [lm77] registered
[   63.992348] initcall sensors_lm77_init+0x0/0x11 returned 0 after 241=
 usecs
[   63.992352] calling  sensors_lm80_init+0x0/0x11 @ 1
[   63.992359] bus: 'i2c': add driver lm80
[   63.992618] i2c-core: driver [lm80] registered
[   63.992632] initcall sensors_lm80_init+0x0/0x11 returned 0 after 261=
 usecs
[   63.992636] calling  ltc4215_init+0x0/0x11 @ 1
[   63.992643] bus: 'i2c': add driver ltc4215
[   63.992874] i2c-core: driver [ltc4215] registered
[   63.992889] initcall ltc4215_init+0x0/0x11 returned 0 after 242 usec=
s
[   63.992893] calling  max1111_init+0x0/0xf @ 1
[   63.992898] bus: 'spi': add driver max1111
[   63.993131] initcall max1111_init+0x0/0xf returned 0 after 227 usecs
[   63.993135] calling  sensors_max1619_init+0x0/0x11 @ 1
[   63.993143] bus: 'i2c': add driver max1619
[   63.993372] i2c-core: driver [max1619] registered
[   63.993388] initcall sensors_max1619_init+0x0/0x11 returned 0 after =
240 usecs
[   63.993392] calling  sensors_max6650_init+0x0/0x11 @ 1
[   63.993399] bus: 'i2c': add driver max6650
[   63.993632] i2c-core: driver [max6650] registered
[   63.993647] initcall sensors_max6650_init+0x0/0x11 returned 0 after =
243 usecs
[   63.993650] calling  pc87360_init+0x0/0xa5 @ 1
[   63.993672] pc87360: PC8736x not detected, module not inserted.
[   63.993677] initcall pc87360_init+0x0/0xa5 returned -19 after 20 use=
cs
[   63.993680] calling  pc87427_init+0x0/0x67 @ 1
[   63.993706] initcall pc87427_init+0x0/0x67 returned -19 after 19 use=
cs
[   63.993709] calling  pcf8591_init+0x0/0x32 @ 1
[   63.993717] bus: 'i2c': add driver pcf8591
[   63.993946] i2c-core: driver [pcf8591] registered
[   63.993962] initcall pcf8591_init+0x0/0x32 returned 0 after 240 usec=
s
[   63.993965] calling  sm_sis5595_init+0x0/0x16 @ 1
[   63.993982] bus: 'pci': add driver sis5595
[   63.994257] initcall sm_sis5595_init+0x0/0x16 returned 0 after 279 u=
secs
[   63.994260] calling  smsc47b397_init+0x0/0xc6 @ 1
[   63.994277] initcall smsc47b397_init+0x0/0xc6 returned -19 after 10 =
usecs
[   63.994281] calling  sm_smsc47m1_init+0x0/0x51 @ 1
[   63.994297] initcall sm_smsc47m1_init+0x0/0x51 returned -19 after 10=
 usecs
[   63.994301] calling  smsc47m192_init+0x0/0x11 @ 1
[   63.994308] bus: 'i2c': add driver smsc47m192
[   63.994549] i2c-core: driver [smsc47m192] registered
[   63.994564] initcall smsc47m192_init+0x0/0x11 returned 0 after 251 u=
secs
[   63.994568] calling  sm_thmc50_init+0x0/0x11 @ 1
[   63.994575] bus: 'i2c': add driver thmc50
[   63.994805] i2c-core: driver [thmc50] registered
[   63.994820] initcall sm_thmc50_init+0x0/0x11 returned 0 after 240 us=
ecs
[   63.994824] calling  tmp401_init+0x0/0x11 @ 1
[   63.994830] bus: 'i2c': add driver tmp401
[   63.995065] i2c-core: driver [tmp401] registered
[   63.995080] initcall tmp401_init+0x0/0x11 returned 0 after 245 usecs
[   63.995084] calling  sm_via686a_init+0x0/0x16 @ 1
[   63.995100] bus: 'pci': add driver via686a
[   63.995366] initcall sm_via686a_init+0x0/0x16 returned 0 after 270 u=
secs
[   63.995370] calling  vt1211_init+0x0/0x9a @ 1
[   63.995400] initcall vt1211_init+0x0/0x9a returned -19 after 23 usec=
s
[   63.995404] calling  sensors_w83l785ts_init+0x0/0x11 @ 1
[   63.995411] bus: 'i2c': add driver w83l785ts
[   63.995646] i2c-core: driver [w83l785ts] registered
[   63.995661] initcall sensors_w83l785ts_init+0x0/0x11 returned 0 afte=
r 245 usecs
[   63.995664] calling  sensors_w83l786ng_init+0x0/0x11 @ 1
[   63.995672] bus: 'i2c': add driver w83l786ng
[   63.995910] i2c-core: driver [w83l786ng] registered
[   63.995928] initcall sensors_w83l786ng_init+0x0/0x11 returned 0 afte=
r 251 usecs
[   63.995932] calling  raid0_init+0x0/0xf @ 1
[   63.995993] md: raid0 personality registered for level 0
[   63.995999] initcall raid0_init+0x0/0xf returned 0 after 60 usecs
[   63.996002] calling  raid_init+0x0/0xf @ 1
[   63.996007] md: raid1 personality registered for level 1
[   63.996012] initcall raid_init+0x0/0xf returned 0 after 4 usecs
[   63.996016] calling  raid_init+0x0/0xf @ 1
[   63.996020] md: raid10 personality registered for level 10
[   63.996025] initcall raid_init+0x0/0xf returned 0 after 4 usecs
[   63.996028] calling  dm_init+0x0/0x38 @ 1
[   63.997266] device-mapper: uevent: version 1.0.3
[   63.997460] device: 'device-mapper': device_add
[   63.997752] PM: Adding info for No Bus:device-mapper
[   63.997998] device-mapper: ioctl: 4.15.0-ioctl (2009-04-01) initiali=
sed: dm-devel@redhat.com
[   63.998006] initcall dm_init+0x0/0x38 returned 0 after 1926 usecs
[   63.998010] calling  dm_crypt_init+0x0/0x5a @ 1
[   63.998053] initcall dm_crypt_init+0x0/0x5a returned 0 after 36 usec=
s
[   63.998057] calling  dm_snapshot_init+0x0/0x215 @ 1
[   63.998255] initcall dm_snapshot_init+0x0/0x215 returned 0 after 188=
 usecs
[   63.998259] calling  dm_mirror_init+0x0/0x69 @ 1
[   63.998811] initcall dm_mirror_init+0x0/0x69 returned 0 after 532 us=
ecs
[   63.998814] calling  dm_dirty_log_init+0x0/0x49 @ 1
[   63.998856] initcall dm_dirty_log_init+0x0/0x49 returned 0 after 35 =
usecs
[   63.998860] calling  userspace_dirty_log_init+0x0/0x89 @ 1
[   63.999213] device-mapper: dm-log-userspace: version 1.0.0 loaded
[   63.999219] initcall userspace_dirty_log_init+0x0/0x89 returned 0 af=
ter 344 usecs
[   63.999223] calling  dm_zero_init+0x0/0x28 @ 1
[   63.999231] initcall dm_zero_init+0x0/0x28 returned 0 after 2 usecs
[   63.999234] calling  vhci_init+0x0/0x44 @ 1
[   63.999238] Bluetooth: Virtual HCI driver ver 1.3
[   63.999257] device: 'vhci': device_add
[   63.999442] PM: Adding info for No Bus:vhci
[   63.999678] initcall vhci_init+0x0/0x44 returned 0 after 427 usecs
[   63.999682] calling  hci_uart_init+0x0/0xc9 @ 1
[   63.999686] Bluetooth: HCI UART driver ver 2.2
[   63.999690] Bluetooth: HCI H4 protocol initialized
[   63.999692] Bluetooth: HCILL protocol initialized
[   63.999697] initcall hci_uart_init+0x0/0xc9 returned 0 after 8 usecs
[   63.999700] calling  bcm203x_init+0x0/0x44 @ 1
[   63.999704] Bluetooth: Broadcom Blutonium firmware driver ver 1.2
[   63.999715] bus: 'usb': add driver bcm203x
[   63.999963] usbcore: registered new interface driver bcm203x
[   63.999975] initcall bcm203x_init+0x0/0x44 returned 0 after 262 usec=
s
[   63.999979] calling  bpa10x_init+0x0/0x25 @ 1
[   63.999982] Bluetooth: Digianswer Bluetooth USB driver ver 0.10
[   63.999990] bus: 'usb': add driver bpa10x
[   64.000228] usbcore: registered new interface driver bpa10x
[   64.000241] initcall bpa10x_init+0x0/0x25 returned 0 after 250 usecs
[   64.000244] calling  bfusb_init+0x0/0x44 @ 1
[   64.000248] Bluetooth: BlueFRITZ! USB driver ver 1.2
[   64.000256] bus: 'usb': add driver bfusb
[   64.000681] usbcore: registered new interface driver bfusb
[   64.000693] initcall bfusb_init+0x0/0x44 returned 0 after 433 usecs
[   64.000697] calling  btsdio_init+0x0/0x1e @ 1
[   64.000701] Bluetooth: Generic Bluetooth SDIO driver ver 0.1
[   64.000704] bus: 'sdio': add driver btsdio
[   64.000946] initcall btsdio_init+0x0/0x1e returned 0 after 237 usecs
[   64.000950] calling  init+0x0/0x7f @ 1
[   64.000968] lguest: mapping switcher would thwack fixmap
[   64.000981] initcall init+0x0/0x7f returned -12 after 25 usecs
[   64.000984] initcall init+0x0/0x7f returned with error code -12=20
[   64.000988] calling  init_ladder+0x0/0xf @ 1
[   64.001036] cpuidle: using governor ladder
[   64.001042] initcall init_ladder+0x0/0xf returned 0 after 47 usecs
[   64.001045] calling  mmc_blk_init+0x0/0x3d @ 1
[   64.001056] bus: 'mmc': add driver mmcblk
[   64.001287] initcall mmc_blk_init+0x0/0x3d returned 0 after 230 usec=
s
[   64.001291] calling  mmc_test_init+0x0/0xf @ 1
[   64.001296] bus: 'mmc': add driver mmc_test
[   64.001527] initcall mmc_test_init+0x0/0xf returned 0 after 224 usec=
s
[   64.001531] calling  sdio_uart_init+0x0/0xc3 @ 1
[   64.001573] bus: 'sdio': add driver sdio_uart
[   64.001812] initcall sdio_uart_init+0x0/0xc3 returned 0 after 268 us=
ecs
[   64.001816] calling  wbsd_drv_init+0x0/0x9b @ 1
[   64.001820] wbsd: Winbond W83L51xD SD/MMC card interface driver
[   64.001822] wbsd: Copyright(c) Pierre Ossman
[   64.001826] bus: 'pnp': add driver wbsd
[   64.002075] initcall wbsd_drv_init+0x0/0x9b returned 0 after 247 use=
cs
[   64.002079] calling  tifm_sd_init+0x0/0xf @ 1
[   64.002085] bus: 'tifm': add driver tifm_sd
[   64.002318] initcall tifm_sd_init+0x0/0xf returned 0 after 226 usecs
[   64.002322] calling  mmc_spi_init+0x0/0xf @ 1
[   64.002328] bus: 'spi': add driver mmc_spi
[   64.002662] initcall mmc_spi_init+0x0/0xf returned 0 after 318 usecs
[   64.002665] calling  cb710_mmc_init_module+0x0/0xf @ 1
[   64.002670] Platform driver 'cb710-mmc' needs updating - please use =
dev_pm_ops
[   64.002677] bus: 'platform': add driver cb710-mmc
[   64.002935] initcall cb710_mmc_init_module+0x0/0xf returned 0 after =
256 usecs
[   64.002939] calling  via_sd_drv_init+0x0/0x20 @ 1
[   64.002942] via_sdmmc: VIA SD/MMC Card Reader driver (C) 2008 VIA Te=
chnologies, Inc.
[   64.002959] bus: 'pci': add driver via_sdmmc
[   64.003257] initcall via_sd_drv_init+0x0/0x20 returned 0 after 305 u=
secs
[   64.003261] calling  memstick_init+0x0/0x75 @ 1
[   64.003618] bus: 'memstick': registered
[   64.003621] device class 'memstick_host': registering
[   64.003842] initcall memstick_init+0x0/0x75 returned 0 after 561 use=
cs
[   64.003846] calling  mspro_block_init+0x0/0x63 @ 1
[   64.003856] bus: 'memstick': add driver mspro_block
[   64.004093] initcall mspro_block_init+0x0/0x63 returned 0 after 235 =
usecs
[   64.004097] calling  tifm_ms_init+0x0/0xf @ 1
[   64.004102] bus: 'tifm': add driver tifm_ms
[   64.004335] initcall tifm_ms_init+0x0/0xf returned 0 after 226 usecs
[   64.004338] calling  jmb38x_ms_init+0x0/0x16 @ 1
[   64.004355] bus: 'pci': add driver jmb38x_ms
[   64.004616] initcall jmb38x_ms_init+0x0/0x16 returned 0 after 265 us=
ecs
[   64.004620] calling  bd2802_init+0x0/0x11 @ 1
[   64.004630] bus: 'i2c': add driver BD2802
[   64.004863] i2c-core: driver [BD2802] registered
[   64.004873] initcall bd2802_init+0x0/0x11 returned 0 after 240 usecs
[   64.004876] calling  wrap_led_init+0x0/0x53 @ 1
[   64.004885] initcall wrap_led_init+0x0/0x53 returned -19 after 2 use=
cs
[   64.004889] calling  alix_led_init+0x0/0xe1 @ 1
[   64.009878] initcall alix_led_init+0x0/0xe1 returned -19 after 4870 =
usecs
[   64.009882] calling  lp3944_module_init+0x0/0x11 @ 1
[   64.009891] bus: 'i2c': add driver lp3944
[   64.010191] i2c-core: driver [lp3944] registered
[   64.010198] initcall lp3944_module_init+0x0/0x11 returned 0 after 30=
2 usecs
[   64.010202] calling  clevo_mail_led_init+0x0/0x7e @ 1
[   64.010213] initcall clevo_mail_led_init+0x0/0x7e returned -19 after=
 4 usecs
[   64.010216] calling  da903x_led_init+0x0/0xf @ 1
[   64.010225] bus: 'platform': add driver da903x-led
[   64.010469] initcall da903x_led_init+0x0/0xf returned 0 after 240 us=
ecs
[   64.010473] calling  dac124s085_leds_init+0x0/0xf @ 1
[   64.010479] bus: 'spi': add driver dac124s085
[   64.010710] initcall dac124s085_leds_init+0x0/0xf returned 0 after 2=
25 usecs
[   64.010714] calling  timer_trig_init+0x0/0xf @ 1
[   64.010790] initcall timer_trig_init+0x0/0xf returned 0 after 67 use=
cs
[   64.010793] calling  defon_trig_init+0x0/0xf @ 1
[   64.010802] initcall defon_trig_init+0x0/0xf returned 0 after 3 usec=
s
[   64.010805] calling  ib_core_init+0x0/0x3a @ 1
[   64.010810] device class 'infiniband': registering
[   64.011068] initcall ib_core_init+0x0/0x3a returned 0 after 250 usec=
s
[   64.011072] calling  ib_mad_init_module+0x0/0x8e @ 1
[   64.011126] initcall ib_mad_init_module+0x0/0x8e returned 0 after 45=
 usecs
[   64.011129] calling  ib_sa_init+0x0/0x7f @ 1
[   64.011217] initcall ib_sa_init+0x0/0x7f returned 0 after 81 usecs
[   64.011221] calling  ib_cm_init+0x0/0x134 @ 1
[   64.011286] device class 'infiniband_cm': registering
[   64.011636] initcall ib_cm_init+0x0/0x134 returned 0 after 399 usecs
[   64.011639] calling  iw_cm_init+0x0/0x32 @ 1
[   64.011721] initcall iw_cm_init+0x0/0x32 returned 0 after 73 usecs
[   64.011724] calling  addr_init+0x0/0x41 @ 1
[   64.011827] initcall addr_init+0x0/0x41 returned 0 after 94 usecs
[   64.011830] calling  cma_init+0x0/0xcb @ 1
[   64.011915] initcall cma_init+0x0/0xcb returned 0 after 78 usecs
[   64.011919] calling  ib_uverbs_init+0x0/0x126 @ 1
[   64.011932] device class 'infiniband_verbs': registering
[   64.012311] initcall ib_uverbs_init+0x0/0x126 returned 0 after 377 u=
secs
[   64.012315] calling  ib_ucm_init+0x0/0x8d @ 1
[   64.012336] initcall ib_ucm_init+0x0/0x8d returned 0 after 14 usecs
[   64.012339] calling  ucma_init+0x0/0x45 @ 1
[   64.012359] device: 'rdma_cm': device_add
[   64.012661] PM: Adding info for No Bus:rdma_cm
[   64.012907] initcall ucma_init+0x0/0x45 returned 0 after 541 usecs
[   64.012912] calling  mthca_init+0x0/0x39 @ 1
[   64.013002] bus: 'pci': add driver ib_mthca
[   64.013292] initcall mthca_init+0x0/0x39 returned 0 after 364 usecs
[   64.013296] calling  c2_init_module+0x0/0x16 @ 1
[   64.013311] bus: 'pci': add driver c2
[   64.013574] initcall c2_init_module+0x0/0x16 returned 0 after 265 us=
ecs
[   64.013578] calling  mlx4_ib_init+0x0/0xf @ 1
[   64.013630] initcall mlx4_ib_init+0x0/0xf returned 0 after 45 usecs
[   64.013633] calling  nes_init_module+0x0/0x4d @ 1
[   64.013782] bus: 'pci': add driver iw_nes
[   64.014114] initcall nes_init_module+0x0/0x4d returned 0 after 463 u=
secs
[   64.014118] calling  srp_init_module+0x0/0xcc @ 1
[   64.014128] device class 'infiniband_srp': registering
[   64.014351] initcall srp_init_module+0x0/0xcc returned 0 after 222 u=
secs
[   64.014355] calling  iser_init+0x0/0x105 @ 1
[   64.014450] device: 'iser': device_add
[   64.014498] PM: Adding info for No Bus:iser
[   64.014755] iscsi: registered transport (iser)
[   64.014761] initcall iser_init+0x0/0x105 returned 0 after 390 usecs
[   64.014765] calling  padlock_init+0x0/0x6e @ 1
[   64.014769] padlock: VIA PadLock Hash Engine not detected.
[   64.014776] initcall padlock_init+0x0/0x6e returned -19 after 4 usec=
s
[   64.014779] calling  geode_aes_init+0x0/0x16 @ 1
[   64.014795] bus: 'pci': add driver Geode LX AES
[   64.015212] initcall geode_aes_init+0x0/0x16 returned 0 after 416 us=
ecs
[   64.015216] calling  init_hrt_clocksource+0x0/0x12e @ 1
[   64.015225] initcall init_hrt_clocksource+0x0/0x12e returned -19 aft=
er 2 usecs
[   64.015229] calling  virtio_pci_init+0x0/0x44 @ 1
[   64.015244] device: 'virtio-pci': device_add
[   64.015282] PM: Adding info for No Bus:virtio-pci
[   64.015298] bus: 'pci': add driver virtio-pci
[   64.015561] initcall virtio_pci_init+0x0/0x44 returned 0 after 317 u=
secs
[   64.015565] calling  asus_laptop_init+0x0/0x2cb @ 1
[   64.015573] bus: 'acpi': add driver Asus Laptop Support
[   64.015874] bus: 'acpi': remove driver Asus Laptop Support
[   64.016076] driver: 'Asus Laptop Support': driver_release
[   64.016088] initcall asus_laptop_init+0x0/0x2cb returned -19 after 5=
04 usecs
[   64.016092] calling  eeepc_laptop_init+0x0/0x218 @ 1
[   64.016098] bus: 'acpi': add driver Eee PC Hotkey Driver
[   64.016383] bus: 'acpi': remove driver Eee PC Hotkey Driver
[   64.016584] driver: 'Eee PC Hotkey Driver': driver_release
[   64.016597] initcall eeepc_laptop_init+0x0/0x218 returned -19 after =
486 usecs
[   64.016601] calling  compal_init+0x0/0xf3 @ 1
[   64.016610] initcall compal_init+0x0/0xf3 returned -19 after 3 usecs
[   64.016614] calling  dell_wmi_init+0x0/0x118 @ 1
[   64.016618] dell-wmi: No known WMI GUID found
[   64.016624] initcall dell_wmi_init+0x0/0x118 returned 0 after 4 usec=
s
[   64.016627] calling  acer_wmi_init+0x0/0x45c @ 1
[   64.016631] acer-wmi: Acer Laptop ACPI-WMI Extras
[   64.016641] acer-wmi: No or unsupported WMI interface, unable to loa=
d
[   64.016647] initcall acer_wmi_init+0x0/0x45c returned -19 after 14 u=
secs
[   64.016651] calling  tc1100_init+0x0/0x50 @ 1
[   64.016659] initcall tc1100_init+0x0/0x50 returned -19 after 2 usecs
[   64.016663] calling  sony_laptop_init+0x0/0x6d @ 1
[   64.016669] bus: 'acpi': add driver Sony Notebook Control Driver
[   64.016939] initcall sony_laptop_init+0x0/0x6d returned 0 after 264 =
usecs
[   64.016943] calling  thinkpad_acpi_module_init+0x0/0x3b3 @ 1
[   64.017030] initcall thinkpad_acpi_module_init+0x0/0x3b3 returned -1=
9 after 77 usecs
[   64.017033] calling  flow_cache_init+0x0/0x14e @ 1
[   64.017083] initcall flow_cache_init+0x0/0x14e returned 0 after 42 u=
secs
[   64.017086] calling  pg_init+0x0/0x116 @ 1
[   64.017091] pktgen v2.70: Packet Generator for packet performance te=
sting.
[   68.194096] device: 'gameport0': device_add
[   68.198226] bus: 'gameport': add device gameport0
[   68.202943] PM: Adding info for gameport:gameport0
[   68.208600] bus: 'gameport': driver_probe_device: matched device gam=
eport0 with driver adc
[   68.216873] bus: 'gameport': really_probe: probing driver adc with d=
evice gameport0
[   68.264847] bus: 'gameport': driver_probe_device: matched device gam=
eport0 with driver adi
[   68.273030] bus: 'gameport': really_probe: probing driver adi with d=
evice gameport0
[   68.280774] initcall pg_init+0x0/0x116 returned 0 after 4163753 usec=
s
[   68.287347] calling  llc_init+0x0/0x1b @ 1
[   68.291549] initcall llc_init+0x0/0x1b returned 0 after 217 usecs
[   68.297539] calling  llc2_init+0x0/0xb5 @ 1
[   68.301749] NET: Registered protocol family 26
[   68.306124] initcall llc2_init+0x0/0xb5 returned 0 after 4333 usecs
[   68.312339] calling  snap_init+0x0/0x31 @ 1
[   68.316580] initcall snap_init+0x0/0x31 returned 0 after 58 usecs
[   68.322586] calling  rif_init+0x0/0x71 @ 1
[   68.326665] initcall rif_init+0x0/0x71 returned 0 after 21 usecs
[   68.332639] calling  nfnetlink_init+0x0/0x51 @ 1
[   68.337215] Netfilter messages via NETLINK v0.30.
[   68.341917] initcall nfnetlink_init+0x0/0x51 returned 0 after 4593 u=
secs
[   68.348586] calling  nfnetlink_queue_init+0x0/0x87 @ 1
[   68.353752] initcall nfnetlink_queue_init+0x0/0x87 returned 0 after =
50 usecs
[   68.360700] calling  nfnetlink_log_init+0x0/0xb3 @ 1
[   68.365714] initcall nfnetlink_log_init+0x0/0xb3 returned 0 after 51=
 usecs
[   68.372487] calling  xt_init+0x0/0x103 @ 1
[   68.376592] initcall xt_init+0x0/0x103 returned 0 after 10 usecs
[   68.382564] calling  tcpudp_mt_init+0x0/0x14 @ 1
[   68.387172] initcall tcpudp_mt_init+0x0/0x14 returned 0 after 33 use=
cs
[   68.393656] calling  led_tg_init+0x0/0xf @ 1
[   68.397887] initcall led_tg_init+0x0/0xf returned 0 after 2 usecs
[   68.403966] calling  mark_tg_init+0x0/0x14 @ 1
[   68.408375] initcall mark_tg_init+0x0/0x14 returned 0 after 4 usecs
[   68.414625] calling  nflog_tg_init+0x0/0xf @ 1
[   68.419033] initcall nflog_tg_init+0x0/0xf returned 0 after 2 usecs
[   68.425286] calling  secmark_tg_init+0x0/0xf @ 1
[   68.429866] initcall secmark_tg_init+0x0/0xf returned 0 after 2 usec=
s
[   68.436293] calling  tcpmss_tg_init+0x0/0x14 @ 1
[   68.440875] initcall tcpmss_tg_init+0x0/0x14 returned 0 after 3 usec=
s
[   68.447301] calling  comment_mt_init+0x0/0xf @ 1
[   68.451881] initcall comment_mt_init+0x0/0xf returned 0 after 2 usec=
s
[   68.458308] calling  hashlimit_mt_init+0x0/0xc6 @ 1
[   68.463243] initcall hashlimit_mt_init+0x0/0xc6 returned 0 after 77 =
usecs
[   68.469910] calling  hl_mt_init+0x0/0x14 @ 1
[   68.474181] initcall hl_mt_init+0x0/0x14 returned 0 after 3 usecs
[   68.480224] calling  mark_mt_init+0x0/0x14 @ 1
[   68.484667] initcall mark_mt_init+0x0/0x14 returned 0 after 3 usecs
[   68.490884] calling  xt_osf_init+0x0/0x79 @ 1
[   68.495241] initcall xt_osf_init+0x0/0x79 returned 0 after 3 usecs
[   68.501371] calling  owner_mt_init+0x0/0x14 @ 1
[   68.505903] initcall owner_mt_init+0x0/0x14 returned 0 after 3 usecs
[   68.512204] calling  physdev_mt_init+0x0/0xf @ 1
[   68.516820] initcall physdev_mt_init+0x0/0xf returned 0 after 2 usec=
s
[   68.523230] calling  pkttype_mt_init+0x0/0xf @ 1
[   68.527810] initcall pkttype_mt_init+0x0/0xf returned 0 after 2 usec=
s
[   68.534239] calling  policy_mt_init+0x0/0x14 @ 1
[   68.538821] initcall policy_mt_init+0x0/0x14 returned 0 after 3 usec=
s
[   68.545242] calling  quota_mt_init+0x0/0xf @ 1
[   68.549652] initcall quota_mt_init+0x0/0xf returned 0 after 2 usecs
[   68.555209] bus: 'gameport': driver_probe_device: matched device gam=
eport0 with driver cobra
[   68.555213] bus: 'gameport': really_probe: probing driver cobra with=
 device gameport0
[   68.555377] bus: 'gameport': driver_probe_device: matched device gam=
eport0 with driver gf2k
[   68.555380] bus: 'gameport': really_probe: probing driver gf2k with =
device gameport0
[   68.588356] calling  realm_mt_init+0x0/0xf @ 1
[   68.592785] initcall realm_mt_init+0x0/0xf returned 0 after 2 usecs
[   68.599012] calling  recent_mt_init+0x0/0x82 @ 1
[   68.603642] initcall recent_mt_init+0x0/0x82 returned 0 after 17 use=
cs
[   68.610130] calling  sctp_mt_init+0x0/0x14 @ 1
[   68.614575] initcall sctp_mt_init+0x0/0x14 returned 0 after 3 usecs
[   68.620801] calling  statistic_mt_init+0x0/0xf @ 1
[   68.625590] initcall statistic_mt_init+0x0/0xf returned 0 after 2 us=
ecs
[   68.632163] calling  string_mt_init+0x0/0x14 @ 1
[   68.636779] initcall string_mt_init+0x0/0x14 returned 0 after 3 usec=
s
[   68.643194] calling  ip_vs_init+0x0/0xa5 @ 1
[   68.647587] IPVS: Registered protocols (UDP, AH, ESP)
[   68.652687] IPVS: Connection hash table configured (size=3D4096, mem=
ory=3D32Kbytes)
[   68.660015] IPVS: Each connection entry needs 240 bytes at least
[   68.666102] IPVS: ipvs loaded.
[   68.669124] initcall ip_vs_init+0x0/0xa5 returned 0 after 21184 usec=
s
[   68.675547] calling  ip_vs_lblc_init+0x0/0x37 @ 1
[   68.680242] IPVS: [lblc] scheduler registered.
[   68.684668] initcall ip_vs_lblc_init+0x0/0x37 returned 0 after 4346 =
usecs
[   68.691418] calling  ip_vs_sh_init+0x0/0xf @ 1
[   68.695857] IPVS: [sh] scheduler registered.
[   68.700088] initcall ip_vs_sh_init+0x0/0xf returned 0 after 4134 use=
cs
[   68.706602] calling  ip_vs_sed_init+0x0/0xf @ 1
[   68.711093] IPVS: [sed] scheduler registered.
[   68.715443] initcall ip_vs_sed_init+0x0/0xf returned 0 after 4244 us=
ecs
[   68.722020] calling  ip_vs_nq_init+0x0/0xf @ 1
[   68.726459] IPVS: [nq] scheduler registered.
[   68.730691] initcall ip_vs_nq_init+0x0/0xf returned 0 after 4135 use=
cs
[   68.737204] calling  sysctl_ipv4_init+0x0/0x3f @ 1
[   68.741991] initcall sysctl_ipv4_init+0x0/0x3f returned 0 after 33 u=
secs
[   68.748670] calling  ipgre_init+0x0/0x98 @ 1
[   68.752917] GRE over IPv4 tunneling driver
[   68.757132] device: 'gre0': device_add
[   68.761195] PM: Adding info for No Bus:gre0
[   69.188853] initcall ipgre_init+0x0/0x98 returned 0 after 425714 use=
cs
[   69.195497] calling  init_syncookies+0x0/0x16 @ 1
[   69.200196] initcall init_syncookies+0x0/0x16 returned 0 after 46 us=
ecs
[   69.206814] calling  esp4_init+0x0/0x5a @ 1
[   69.210972] initcall esp4_init+0x0/0x5a returned 0 after 4 usecs
[   69.216952] calling  ipcomp4_init+0x0/0x5a @ 1
[   69.221363] initcall ipcomp4_init+0x0/0x5a returned 0 after 3 usecs
[   69.227613] calling  ipip_init+0x0/0x88 @ 1
[   69.231840] initcall ipip_init+0x0/0x88 returned 0 after 76 usecs
[   69.237908] calling  xfrm4_beet_init+0x0/0x14 @ 1
[   69.242593] initcall xfrm4_beet_init+0x0/0x14 returned 0 after 2 use=
cs
[   69.249080] calling  tunnel4_init+0x0/0x5a @ 1
[   69.253525] initcall tunnel4_init+0x0/0x5a returned 0 after 3 usecs
[   69.259750] calling  xfrm4_mode_tunnel_init+0x0/0x14 @ 1
[   69.265058] initcall xfrm4_mode_tunnel_init+0x0/0x14 returned 0 afte=
r 2 usecs
[   69.272153] calling  ipv4_netfilter_init+0x0/0x14 @ 1
[   69.277231] initcall ipv4_netfilter_init+0x0/0x14 returned 0 after 3=
2 usecs
[   69.284164] calling  ip_queue_init+0x0/0x10c @ 1
[   69.288838] initcall ip_queue_init+0x0/0x10c returned 0 after 92 use=
cs
[   69.295344] calling  inet_diag_init+0x0/0x9e @ 1
[   69.299947] initcall inet_diag_init+0x0/0x9e returned 0 after 22 use=
cs
[   69.306454] calling  tcp_diag_init+0x0/0xf @ 1
[   69.310894] initcall tcp_diag_init+0x0/0xf returned 0 after 31 usecs
[   69.317227] calling  cubictcp_register+0x0/0x7f @ 1
[   69.322068] TCP cubic registered
[   69.325290] initcall cubictcp_register+0x0/0x7f returned 0 after 314=
1 usecs
[   69.332213] calling  xfrm_user_init+0x0/0x40 @ 1
[   69.336825] Initializing XFRM netlink socket
[   69.341106] initcall xfrm_user_init+0x0/0x40 returned 0 after 4181 u=
secs
[   69.347787] calling  inet6_init+0x0/0x2a2 @ 1
[   70.077459] NET: Registered protocol family 10
[   70.083210] lo: Disabled Privacy Extensions
[   70.091305] initcall inet6_init+0x0/0x2a2 returned 0 after 721869 us=
ecs
[   70.097937] calling  ah6_init+0x0/0x5a @ 1
[   70.102005] initcall ah6_init+0x0/0x5a returned 0 after 4 usecs
[   70.107907] calling  esp6_init+0x0/0x5a @ 1
[   70.112056] initcall esp6_init+0x0/0x5a returned 0 after 3 usecs
[   70.118047] calling  ipcomp6_init+0x0/0x5a @ 1
[   70.122457] initcall ipcomp6_init+0x0/0x5a returned 0 after 3 usecs
[   70.128706] calling  xfrm6_tunnel_init+0x0/0xdb @ 1
[   70.133662] initcall xfrm6_tunnel_init+0x0/0xdb returned 0 after 97 =
usecs
[   70.139031] bus: 'gameport': driver_probe_device: matched device gam=
eport0 with driver grip
[   70.139034] bus: 'gameport': really_probe: probing driver grip with =
device gameport0
[   70.156568] calling  tunnel6_init+0x0/0x5a @ 1
[   70.160980] initcall tunnel6_init+0x0/0x5a returned 0 after 3 usecs
[   70.167233] calling  xfrm6_transport_init+0x0/0x14 @ 1
[   70.172341] initcall xfrm6_transport_init+0x0/0x14 returned 0 after =
2 usecs
[   70.179290] calling  xfrm6_mode_tunnel_init+0x0/0x14 @ 1
[   70.184586] initcall xfrm6_mode_tunnel_init+0x0/0x14 returned 0 afte=
r 2 usecs
[   70.191680] calling  xfrm6_ro_init+0x0/0x14 @ 1
[   70.196209] initcall xfrm6_ro_init+0x0/0x14 returned 0 after 2 usecs
[   70.202545] calling  mip6_init+0x0/0xa7 @ 1
[   70.205422] bus: 'gameport': driver_probe_device: matched device gam=
eport0 with driver grip_mp
[   70.205425] bus: 'gameport': really_probe: probing driver grip_mp wi=
th device gameport0
[   70.223262] Mobile IPv6
[   70.225676] initcall mip6_init+0x0/0xa7 returned 0 after 2357 usecs
[   70.231908] calling  ip6_tables_init+0x0/0x92 @ 1
[   70.236669] ip6_tables: (C) 2000-2006 Netfilter Core Team
[   70.241967] initcall ip6_tables_init+0x0/0x92 returned 0 after 5235 =
usecs
[   70.248742] calling  ip6_queue_init+0x0/0x10c @ 1
[   70.253474] initcall ip6_queue_init+0x0/0x10c returned 0 after 48 us=
ecs
[   70.259990] calling  ah_mt6_init+0x0/0xf @ 1
[   70.264260] initcall ah_mt6_init+0x0/0xf returned 0 after 2 usecs
[   70.270304] calling  frag_mt6_init+0x0/0xf @ 1
[   70.274745] initcall frag_mt6_init+0x0/0xf returned 0 after 2 usecs
[   70.280964] calling  ipv6header_mt6_init+0x0/0xf @ 1
[   70.285926] initcall ipv6header_mt6_init+0x0/0xf returned 0 after 2 =
usecs
[   70.292684] calling  mh_mt6_init+0x0/0xf @ 1
[   70.296916] initcall mh_mt6_init+0x0/0xf returned 0 after 2 usecs
[   70.302996] calling  hbh_mt6_init+0x0/0x14 @ 1
[   70.307404] initcall hbh_mt6_init+0x0/0x14 returned 0 after 3 usecs
[   70.313656] calling  rt_mt6_init+0x0/0xf @ 1
[   70.317890] initcall rt_mt6_init+0x0/0xf returned 0 after 2 usecs
[   70.323968] calling  log_tg6_init+0x0/0x24 @ 1
[   70.328933] initcall log_tg6_init+0x0/0x24 returned 0 after 3 usecs
[   70.335186] calling  sit_init+0x0/0x5f @ 1
[   70.339241] IPv6 over IPv4 tunneling driver
[   70.343463] device: 'sit0': device_add
[   70.347485] PM: Adding info for No Bus:sit0
[   70.352227] sit0: Disabled Privacy Extensions
[   70.356615] initcall sit_init+0x0/0x5f returned 0 after 16960 usecs
[   70.362780] calling  ip6_tunnel_init+0x0/0x8c @ 1
[   70.367482] device: 'ip6tnl0': device_add
[   70.371762] PM: Adding info for No Bus:ip6tnl0
[   70.376470] ip6tnl0: Disabled Privacy Extensions
[   70.381039] initcall ip6_tunnel_init+0x0/0x8c returned 0 after 13276=
 usecs
[   70.387838] calling  packet_init+0x0/0x39 @ 1
[   70.392154] NET: Registered protocol family 17
[   70.396673] initcall packet_init+0x0/0x39 returned 0 after 4410 usec=
s
[   70.403010] calling  br_init+0x0/0xb4 @ 1
[   70.407086] Bridge firewalling registered
[   70.411026] initcall br_init+0x0/0xb4 returned 0 after 3951 usecs
[   70.417068] calling  dsa_init_module+0x0/0x11 @ 1
[   70.421736] initcall dsa_init_module+0x0/0x11 returned 0 after 2 use=
cs
[   70.428248] calling  edsa_init_module+0x0/0x11 @ 1
[   70.433018] initcall edsa_init_module+0x0/0x11 returned 0 after 2 us=
ecs
[   70.439583] calling  mv88e6123_61_65_init+0x0/0x11 @ 1
[   70.444744] initcall mv88e6123_61_65_init+0x0/0x11 returned 0 after =
27 usecs
[   70.451715] calling  mv88e6131_init+0x0/0x11 @ 1
[   70.456336] initcall mv88e6131_init+0x0/0x11 returned 0 after 2 usec=
s
[   70.462743] calling  dsa_init_module+0x0/0xf @ 1
[   70.467325] bus: 'platform': add driver dsa
[   70.471761] initcall dsa_init_module+0x0/0xf returned 0 after 4338 u=
secs
[   70.478368] calling  atalk_init+0x0/0x77 @ 1
[   70.482615] NET: Registered protocol family 5
[   70.710954] device: 'input3': device_add
[   70.715133] PM: Adding info for No Bus:input3
[   70.719783] input: ImPS/2 Generic Wheel Mouse as /class/input/input3
[   70.726081] device: 'mouse0': device_add
[   70.730267] PM: Adding info for No Bus:mouse0
[   70.734883] device: 'event3': device_add
[   70.738896] PM: Adding info for No Bus:event3
[   70.743432] evbug.c: Connected device: input3 (ImPS/2 Generic Wheel =
Mouse at isa0060/serio1/input0)
[   70.757788] driver: 'serio1': driver_bound: bound to device 'psmouse=
'
[   70.764131] bus: 'serio': really_probe: bound device serio1 to drive=
r psmouse
[   71.276378] bus: 'gameport': driver_probe_device: matched device gam=
eport0 with driver guillemot
[   71.285090] bus: 'gameport': really_probe: probing driver guillemot =
with device gameport0
[   71.333590] bus: 'gameport': driver_probe_device: matched device gam=
eport0 with driver interact
[   71.342202] bus: 'gameport': really_probe: probing driver interact w=
ith device gameport0
[   71.390617] bus: 'gameport': driver_probe_device: matched device gam=
eport0 with driver joydump
[   71.399123] bus: 'gameport': really_probe: probing driver joydump wi=
th device gameport0
[   71.407145] joydump: ,------------------ START ----------------.
[   71.413097] joydump: | Dumping:             pnp00:0d/gameport0 |
[   71.419057] joydump: | Speed:                        59659 kHz |
[   72.096150] joydump: >------------------ DATA -----------------<
[   72.102053] joydump: | index:   0 delta:   0 us data: 11111111 |
[   72.108019] joydump: `------------------- END -----------------'
[   72.114014] driver: 'gameport0': driver_bound: bound to device 'joyd=
ump'
[   72.120687] bus: 'gameport': really_probe: bound device gameport0 to=
 driver joydump
[   72.202662] initcall atalk_init+0x0/0x77 returned 0 after 1679727 us=
ecs
[   72.209158] calling  x25_init+0x0/0x50 @ 1
[   72.213254] NET: Registered protocol family 9
[   72.217567] X.25 for Linux Version 0.2
[   72.221352] initcall x25_init+0x0/0x50 returned 0 after 7914 usecs
[   72.227486] calling  lapb_init+0x0/0x7 @ 1
[   72.231523] initcall lapb_init+0x0/0x7 returned 0 after 1 usecs
[   72.237429] calling  nr_proto_init+0x0/0x1f5 @ 1
[   72.242041] device: 'nr0': device_add
[   72.246001] PM: Adding info for No Bus:nr0
[   72.250345] device: 'nr1': device_add
[   72.254263] PM: Adding info for No Bus:nr1
[   72.258551] device: 'nr2': device_add
[   72.262427] PM: Adding info for No Bus:nr2
[   72.266766] device: 'nr3': device_add
[   72.270645] PM: Adding info for No Bus:nr3
[   72.274951] NET: Registered protocol family 6
[   72.279328] initcall nr_proto_init+0x0/0x1f5 returned 0 after 36443 =
usecs
[   72.286026] calling  ax25_init+0x0/0x8e @ 1
[   72.290160] NET: Registered protocol family 3
[   72.294607] initcall ax25_init+0x0/0x8e returned 0 after 4339 usecs
[   72.300756] calling  can_init+0x0/0xf3 @ 1
[   72.304855] can: controller area network core (rev 20090105 abi 8)
[   72.311201] NET: Registered protocol family 29
[   72.315558] initcall can_init+0x0/0xf3 returned 0 after 10450 usecs
[   72.321774] calling  sco_init+0x0/0xc0 @ 1
[   72.325905] Bluetooth: SCO (Voice Link) ver 0.6
[   72.330353] Bluetooth: SCO socket layer initialized
[   72.335227] initcall sco_init+0x0/0xc0 returned 0 after 9140 usecs
[   72.341360] calling  af_rxrpc_init+0x0/0x16d @ 1
[   72.346182] NET: Registered protocol family 33
[   72.350576] initcall af_rxrpc_init+0x0/0x16d returned 0 after 4495 u=
secs
[   72.357215] calling  rxkad_init+0x0/0x56 @ 1
[   72.361739] RxRPC: Registered security type 2 'rxkad'
[   72.366682] initcall rxkad_init+0x0/0x56 returned 0 after 5130 usecs
[   72.373084] calling  br2684_init+0x0/0x37 @ 1
[   72.377361] initcall br2684_init+0x0/0x37 returned 0 after 21 usecs
[   72.383595] calling  lane_module_init+0x0/0x4f @ 1
[   72.388359] lec.c: Jul  2 2009 09:17:52 initialized
[   72.393216] initcall lane_module_init+0x0/0x4f returned 0 after 4752=
 usecs
[   72.400061] calling  phonet_init+0x0/0x6b @ 1
[   72.404404] NET: Registered protocol family 35
[   72.408909] initcall phonet_init+0x0/0x6b returned 0 after 4425 usec=
s
[   72.415257] calling  pep_register+0x0/0x14 @ 1
[   72.419690] initcall pep_register+0x0/0x14 returned 0 after 30 usecs
[   72.426005] calling  vlan_proto_init+0x0/0xa7 @ 1
[   72.430682] 802.1Q VLAN Support v1.8 Ben Greear <greearb@candelatech=
=2Ecom>
[   72.437420] All bugs added by David S. Miller <davem@redhat.com>
[   72.443521] initcall vlan_proto_init+0x0/0xa7 returned 0 after 12536=
 usecs
[   72.450296] calling  dccp_init+0x0/0x318 @ 1
[   72.463387] CCID: Activated CCID 2 (TCP-like)
[   72.467691] CCID: Activated CCID 3 (TCP-Friendly Rate Control)
[   72.473537] initcall dccp_init+0x0/0x318 returned 0 after 18558 usec=
s
[   72.479856] calling  dccp_v4_init+0x0/0x72 @ 1
[   72.485527] initcall dccp_v4_init+0x0/0x72 returned 0 after 1203 use=
cs
[   72.491958] calling  dccp_v6_init+0x0/0x72 @ 1
[   72.497529] initcall dccp_v6_init+0x0/0x72 returned 0 after 1142 use=
cs
[   72.504031] calling  dccp_diag_init+0x0/0xf @ 1
[   72.508453] initcall dccp_diag_init+0x0/0xf returned 0 after 3 usecs
[   72.514793] calling  sctp_init+0x0/0x6a8 @ 1
[   72.526088] SCTP: Hash tables configured (established 26214 bind 262=
14)
[   72.533534] sctp_init_sock(sk: f57f4000)
[   72.537387] initcall sctp_init+0x0/0x6a8 returned 0 after 17928 usec=
s
[   72.543791] calling  lib80211_init+0x0/0x19 @ 1
[   72.548263] lib80211: common routines for IEEE802.11 drivers
[   72.553983] lib80211_crypt: registered algorithm 'NULL'
[   72.559098] initcall lib80211_init+0x0/0x19 returned 0 after 10579 u=
secs
[   72.565796] calling  lib80211_crypto_wep_init+0x0/0xf @ 1
[   72.571165] lib80211_crypt: registered algorithm 'WEP'
[   72.576259] initcall lib80211_crypto_wep_init+0x0/0xf returned 0 aft=
er 4980 usecs
[   72.583730] calling  lib80211_crypto_ccmp_init+0x0/0xf @ 1
[   72.589174] lib80211_crypt: registered algorithm 'CCMP'
[   72.594390] initcall lib80211_crypto_ccmp_init+0x0/0xf returned 0 af=
ter 5091 usecs
[   72.601927] calling  lib80211_crypto_tkip_init+0x0/0xf @ 1
[   72.607374] lib80211_crypt: registered algorithm 'TKIP'
[   72.612590] initcall lib80211_crypto_tkip_init+0x0/0xf returned 0 af=
ter 5092 usecs
[   72.620131] calling  hpet_insert_resource+0x0/0x1e @ 1
[   72.625228] initcall hpet_insert_resource+0x0/0x1e returned 1 after =
1 usecs
[   72.632176] initcall hpet_insert_resource+0x0/0x1e returned with err=
or code 1=20
[   72.639349] calling  lapic_insert_resource+0x0/0x45 @ 1
[   72.644574] initcall lapic_insert_resource+0x0/0x45 returned 0 after=
 4 usecs
[   72.651588] calling  print_ipi_mode+0x0/0x26 @ 1
[   72.656165] Using IPI No-Shortcut mode
[   72.659891] initcall print_ipi_mode+0x0/0x26 returned 0 after 3639 u=
secs
[   72.666584] calling  init_lapic_nmi_sysfs+0x0/0x33 @ 1
[   72.671698] initcall init_lapic_nmi_sysfs+0x0/0x33 returned 0 after =
1 usecs
[   72.678610] calling  ioapic_insert_resources+0x0/0x4b @ 1
[   72.684007] initcall ioapic_insert_resources+0x0/0x4b returned 0 aft=
er 2 usecs
[   72.691195] calling  io_apic_bug_finalize+0x0/0x1a @ 1
[   72.696294] initcall io_apic_bug_finalize+0x0/0x1a returned 0 after =
1 usecs
[   72.703245] calling  check_early_ioremap_leak+0x0/0x5e @ 1
[   72.708688] initcall check_early_ioremap_leak+0x0/0x5e returned 0 af=
ter 1 usecs
[   72.715984] calling  pat_memtype_list_init+0x0/0x23 @ 1
[   72.721210] initcall pat_memtype_list_init+0x0/0x23 returned 0 after=
 25 usecs
[   72.728271] calling  sched_init_debug+0x0/0x1f @ 1
[   72.733077] initcall sched_init_debug+0x0/0x1f returned 0 after 18 u=
secs
[   72.739712] calling  init_oops_id+0x0/0x3f @ 1
[   72.744156] initcall init_oops_id+0x0/0x3f returned 0 after 1 usecs
[   72.750389] calling  disable_boot_consoles+0x0/0x3d @ 1
[   72.755576] initcall disable_boot_consoles+0x0/0x3d returned 0 after=
 1 usecs
[   72.762610] calling  pm_qos_power_init+0x0/0xae @ 1
[   72.767468] device: 'cpu_dma_latency': device_add
[   72.772440] PM: Adding info for No Bus:cpu_dma_latency
[   72.777711] device: 'network_latency': device_add
[   72.782490] PM: Adding info for No Bus:network_latency
[   72.787746] device: 'network_throughput': device_add
[   72.792742] PM: Adding info for No Bus:network_throughput
[   72.798246] initcall pm_qos_power_init+0x0/0xae returned 0 after 300=
76 usecs
[   72.805209] calling  taskstats_init+0x0/0x7d @ 1
[   72.809810] registered taskstats version 1
[   72.813868] initcall taskstats_init+0x0/0x7d returned 0 after 3992 u=
secs
[   72.821094] calling  clear_boot_tracer+0x0/0x27 @ 1
[   72.825932] initcall clear_boot_tracer+0x0/0x27 returned 0 after 1 u=
secs
[   72.832621] calling  event_trace_self_tests_init+0x0/0x39 @ 1
[   72.838323] Running tests on trace events:
[   72.842413] Testing event kfree_skb: OK
[   72.882870] Testing event block_rq_abort: OK
[   72.920373] Testing event block_rq_insert: OK
[   72.960396] Testing event block_rq_issue: OK
[   73.000368] Testing event block_rq_requeue: OK
[   73.040399] Testing event block_rq_complete: OK
[   73.080405] Testing event block_bio_bounce: OK
[   73.120411] Testing event block_bio_complete: OK
[   73.160408] Testing event block_bio_backmerge: OK
[   73.200422] Testing event block_bio_frontmerge: OK
[   73.240411] Testing event block_bio_queue: OK
[   73.280409] Testing event block_getrq: OK
[   73.320405] Testing event block_sleeprq: OK
[   73.360412] Testing event block_plug: OK
[   73.400408] Testing event block_unplug_timer: OK
[   73.440406] Testing event block_unplug_io: OK
[   73.480412] Testing event block_split: OK
[   73.520409] Testing event block_remap: OK
[   73.560406] Testing event gfs2_glock_state_change: OK
[   73.600412] Testing event gfs2_glock_put: OK
[   73.640409] Testing event gfs2_demote_rq: OK
[   73.680406] Testing event gfs2_promote: OK
[   73.720412] Testing event gfs2_glock_queue: OK
[   73.760409] Testing event gfs2_pin: OK
[   73.800406] Testing event gfs2_log_flush: OK
[   73.840412] Testing event gfs2_log_blocks: OK
[   73.880409] Testing event gfs2_bmap: OK
[   73.920406] Testing event gfs2_block_alloc: OK
[   73.960412] Testing event jbd2_checkpoint: OK
[   74.000410] Testing event jbd2_start_commit: OK
[   74.040416] Testing event jbd2_commit_locking: OK
[   74.080413] Testing event jbd2_commit_flushing: OK
[   74.120401] Testing event jbd2_commit_logging: OK
[   74.160407] Testing event jbd2_end_commit: OK
[   74.200404] Testing event jbd2_submit_inode_data: OK
[   74.240410] Testing event kmalloc: OK
[   74.280407] Testing event kmem_cache_alloc: OK
[   74.320404] Testing event kmalloc_node: OK
[   74.360410] Testing event kmem_cache_alloc_node: OK
[   74.400408] Testing event kfree: OK
[   74.440412] Testing event kmem_cache_free: OK
[   74.480420] Testing event lock_acquire: OK
[   74.520476] Testing event lock_release: OK
[   74.560474] Testing event lock_contended: OK
[   74.600410] Testing event lock_acquired: OK
[   74.640469] Testing event workqueue_insertion: OK
[   74.680414] Testing event workqueue_execution: OK
[   74.720411] Testing event workqueue_creation: OK
[   74.760407] Testing event workqueue_destruction: OK
[   74.800405] Testing event irq_handler_entry: OK
[   74.840410] Testing event irq_handler_exit: OK
[   74.880407] Testing event softirq_entry: OK
[   74.920414] Testing event softirq_exit: OK
[   74.960411] Testing event sched_kthread_stop: OK
[   75.000408] Testing event sched_kthread_stop_ret: OK
[   75.040414] Testing event sched_wait_task: OK
[   75.080411] Testing event sched_wakeup: OK
[   75.120408] Testing event sched_wakeup_new: OK
[   75.160415] Testing event sched_switch: OK
[   75.200411] Testing event sched_migrate_task: OK
[   75.240409] Testing event sched_process_free: OK
[   75.280406] Testing event sched_process_exit: OK
[   75.320411] Testing event sched_process_wait: OK
[   75.360409] Testing event sched_process_fork: OK
[   75.400406] Testing event sched_signal_send: OK
[   75.440411] Running tests on trace event systems:
[   75.445088] Testing event system skb: OK
[   75.480418] Testing event system block: OK
[   75.520675] Testing event system gfs2: OK
[   75.560611] Testing event system jbd2: OK
[   75.600547] Testing event system kmem: OK
[   75.640536] Testing event system lockdep: OK
[   75.680680] Testing event system workqueue: OK
[   75.720470] Testing event system irq: OK
[   75.760476] Testing event system sched: OK
[   75.800612] Running tests on all trace events:
[   75.805028] Testing all events: OK
[   75.869124] Running tests again, along with the function tracer
[   75.875493] Running tests on trace events:
[   75.879487] Testing event kfree_skb: OK
[   75.923091] Testing event block_rq_abort: OK
[   75.960637] Testing event block_rq_insert: OK
[   76.000730] Testing event block_rq_issue: OK
[   76.040658] Testing event block_rq_requeue: OK
[   76.080742] Testing event block_rq_complete: OK
[   76.120738] Testing event block_bio_bounce: OK
[   76.160762] Testing event block_bio_complete: OK
[   76.200751] Testing event block_bio_backmerge: OK
[   76.240748] Testing event block_bio_frontmerge: OK
[   76.280779] Testing event block_bio_queue: OK
[   76.320759] Testing event block_getrq: OK
[   76.360757] Testing event block_sleeprq: OK
[   76.400754] Testing event block_plug: OK
[   76.440751] Testing event block_unplug_timer: OK
[   76.480774] Testing event block_unplug_io: OK
[   76.520754] Testing event block_split: OK
[   76.560751] Testing event block_remap: OK
[   76.600757] Testing event gfs2_glock_state_change: OK
[   76.640754] Testing event gfs2_glock_put: OK
[   76.680777] Testing event gfs2_demote_rq: OK
[   76.720748] Testing event gfs2_promote: OK
[   76.760754] Testing event gfs2_glock_queue: OK
[   76.800752] Testing event gfs2_pin: OK
[   76.840757] Testing event gfs2_log_flush: OK
[   76.880771] Testing event gfs2_log_blocks: OK
[   76.920761] Testing event gfs2_bmap: OK
[   76.960757] Testing event gfs2_block_alloc: OK
[   77.000754] Testing event jbd2_checkpoint: OK
[   77.040769] Testing event jbd2_start_commit: OK
[   77.080774] Testing event jbd2_commit_locking: OK
[   77.120754] Testing event jbd2_commit_flushing: OK
[   77.160752] Testing event jbd2_commit_logging: OK
[   77.200749] Testing event jbd2_end_commit: OK
[   77.240755] Testing event jbd2_submit_inode_data: OK
[   77.280779] Testing event kmalloc: OK
[   77.320749] Testing event kmem_cache_alloc: OK
[   77.360755] Testing event kmalloc_node: OK
[   77.400752] Testing event kmem_cache_alloc_node: OK
[   77.440750] Testing event kfree: OK
[   77.480781] Testing event kmem_cache_free: OK
[   77.520762] Testing event lock_acquire: OK
[   77.560880] Testing event lock_release: OK
[   77.600877] Testing event lock_contended: OK
[   77.640753] Testing event lock_acquired: OK
[   77.680905] Testing event workqueue_insertion: OK
[   77.720756] Testing event workqueue_execution: OK
[   77.760752] Testing event workqueue_creation: OK
[   77.800758] Testing event workqueue_destruction: OK
[   77.840747] Testing event irq_handler_entry: OK
[   77.880779] Testing event irq_handler_exit: OK
[   77.920759] Testing event softirq_entry: OK
[   77.960755] Testing event softirq_exit: OK
[   78.000762] Testing event sched_kthread_stop: OK
[   78.040768] Testing event sched_kthread_stop_ret: OK
[   78.080783] Testing event sched_wait_task: OK
[   78.120754] Testing event sched_wakeup: OK
[   78.160794] Testing event sched_wakeup_new: OK
[   78.200835] Testing event sched_switch: OK
[   78.240798] Testing event sched_migrate_task: OK
[   78.280777] Testing event sched_process_free: OK
[   78.320756] Testing event sched_process_exit: OK
[   78.360754] Testing event sched_process_wait: OK
[   78.400760] Testing event sched_process_fork: OK
[   78.440756] Testing event sched_signal_send: OK
[   78.480779] Running tests on trace event systems:
[   78.485456] Testing event system skb: OK
[   78.520777] Testing event system block: OK
[   78.561736] Testing event system gfs2: OK
[   78.601456] Testing event system jbd2: OK
[   78.641237] Testing event system kmem: OK
[   78.681183] Testing event system lockdep: OK
[   78.721439] Testing event system workqueue: OK
[   78.760986] Testing event system irq: OK
[   78.800984] Testing event system sched: OK
[   78.841560] Running tests on all trace events:
[   78.845976] Testing all events: OK
[   78.930557] initcall event_trace_self_tests_init+0x0/0x39 returned 0=
 after 5949435 usecs
[   78.938554] calling  fail_page_alloc_debugfs+0x0/0xc1 @ 1
[   78.944413] initcall fail_page_alloc_debugfs+0x0/0xc1 returned 0 aft=
er 246 usecs
[   78.951807] calling  failslab_debugfs_init+0x0/0x58 @ 1
[   78.957117] initcall failslab_debugfs_init+0x0/0x58 returned 0 after=
 198 usecs
[   78.964261] calling  kmemleak_late_init+0x0/0x75 @ 1
[   78.969370] kmemleak: Kernel memory leak detector initialized
[   78.969373] kmemleak: Automatic memory scanning thread started
[   78.980864] initcall kmemleak_late_init+0x0/0x75 returned 0 after 11=
400 usecs
[   78.987911] calling  init_ima+0x0/0x19 @ 1
[   78.992638] No TPM chip found, activating TPM-bypass!
[   78.998012] initcall init_ima+0x0/0x19 returned 0 after 5869 usecs
[   79.004162] calling  random32_reseed+0x0/0x83 @ 1
[   79.008780] initcall random32_reseed+0x0/0x83 returned 0 after 21 us=
ecs
[   79.015361] calling  pci_resource_alignment_sysfs_init+0x0/0x14 @ 1
[   79.021612] initcall pci_resource_alignment_sysfs_init+0x0/0x14 retu=
rned 0 after 10 usecs
[   79.030337] calling  pci_sysfs_init+0x0/0x44 @ 1
[   79.035511] initcall pci_sysfs_init+0x0/0x44 returned 0 after 583 us=
ecs
[   79.042036] calling  boot_wait_for_devices+0x0/0x18 @ 1
[   79.047214] initcall boot_wait_for_devices+0x0/0x18 returned 0 after=
 1 usecs
[   79.054248] calling  regulator_init_complete+0x0/0xef @ 1
[   79.059651] initcall regulator_init_complete+0x0/0xef returned 0 aft=
er 45 usecs
[   79.066901] calling  seqgen_init+0x0/0xe @ 1
[   79.071170] initcall seqgen_init+0x0/0xe returned 0 after 21 usecs
[   79.077283] calling  late_resume_init+0x0/0x10c @ 1
[   79.082157]   Magic number: 1:253:280
[   79.086011] tty ttyy8: hash matches
[   79.089387] tty ttyvb: hash matches
[   79.092944] tty tty17: hash matches
[   79.096358] initcall late_resume_init+0x0/0x10c returned 0 after 138=
69 usecs
[   79.103357] calling  hd_init+0x0/0x2a8 @ 1
[   79.107491] hd: no drives specified - use hd=3Dcyl,head,sectors on k=
ernel command line
[   79.115433] initcall hd_init+0x0/0x2a8 returned -1 after 7829 usecs
[   79.121599] initcall hd_init+0x0/0x2a8 returned with error code -1=20
[   79.127821] calling  scsi_complete_async_scans+0x0/0x122 @ 1
[   79.133475] initcall scsi_complete_async_scans+0x0/0x122 returned 0 =
after 2 usecs
[   79.140925] calling  edd_init+0x0/0x181 @ 1
[   79.145068] BIOS EDD facility v0.16 2004-Jun-25, 0 devices found
[   79.151062] EDD information not available.
[   79.155123] initcall edd_init+0x0/0x181 returned -19 after 9818 usec=
s
[   79.161553] calling  memmap_init+0x0/0x89 @ 1
[   79.166173] initcall memmap_init+0x0/0x89 returned 0 after 296 usecs
[   79.172429] calling  tcp_congestion_default+0x0/0xf @ 1
[   79.177615] initcall tcp_congestion_default+0x0/0xf returned 0 after=
 3 usecs
[   79.184649] calling  initialize_hashrnd+0x0/0x16 @ 1
[   79.189580] initcall initialize_hashrnd+0x0/0x16 returned 0 after 7 =
usecs
[   79.196422] async_waiting @ 1
[   79.199283] async_continuing @ 1 after 3 usec
[   79.203804] md: Skipping autodetection of RAID arrays. (raid=3Dautod=
etect will force)
[   79.213264] EXT3-fs: INFO: recovery required on readonly filesystem.
[   79.219503] EXT3-fs: write access will be enabled during recovery.
[   79.268485] kjournald starting.  Commit interval 5 seconds
[   79.268537] EXT3-fs: recovery complete.
[   79.269459] EXT3-fs: mounted filesystem with ordered data mode.
[   79.269555] VFS: Mounted root (ext3 filesystem) readonly on device 8=
:1.
[   79.269598] async_waiting @ 1
[   79.269605] async_continuing @ 1 after 3 usec
[   79.297455] Freeing unused kernel memory: 1928k freed
[   81.840522] device: 'md0': device_add
[   81.844414] PM: Adding info for No Bus:md0
[   81.849081] device: '9:0': device_add
[   81.852834] PM: Adding info for No Bus:9:0
[   81.857443] md: Autodetecting RAID arrays.
[   81.861421] md: Scanned 0 and added 0 devices.
[   81.865891] md: autorun ...
[   81.868619] md: ... autorun DONE.
[   82.769639] device: 'md1': device_add
[   82.773393] PM: Adding info for No Bus:md1
[   82.777888] device: '9:1': device_add
[   82.781530] PM: Adding info for No Bus:9:1
[   83.258075] EXT3 FS on sda1, internal journal
[   83.382368] kjournald starting.  Commit interval 5 seconds
[   83.382766] EXT3 FS on sda5, internal journal
[   83.382779] EXT3-fs: mounted filesystem with ordered data mode.
[   86.169648] device: 'lapb0': device_add
[   86.173826] PM: Adding info for No Bus:lapb0
[   92.733329] CPU 1 is now offline
[   92.736451] lockdep: fixing up alternatives.
[   92.740723] SMP alternatives: switching to UP code
[   92.756749] CPU0 attaching NULL sched-domain.
[   92.761354] CPU1 attaching NULL sched-domain.
[   92.765642] CPU0 attaching NULL sched-domain.
[   92.772088] device: 'cpu1': device_unregister
[   92.776328] PM: Removing info for No Bus:cpu1
[   92.781122] device: 'cpu1': device_create_release
[   93.794355] device: 'cpu1': device_add
[   93.798271] PM: Adding info for No Bus:cpu1
[   93.802742] lockdep: fixing up alternatives.
[   93.806895] SMP alternatives: switching to SMP code
[   93.821660] CPU 1 irqstacks, hard=3Dc38b0000 soft=3Dc38b1000
[   93.826858] Booting processor 1 APIC 0x1 ip 0x6000
[   92.755912] Initializing CPU#1
[   92.755912] masked ExtINT on CPU#1
[   92.755912] Calibrating delay using timer specific routine.. 4020.59=
 BogoMIPS (lpj=3D20102973)
[   92.755912] CPU: L1 I Cache: 64K (64 bytes/line), D cache 64K (64 by=
tes/line)
[   92.755912] CPU: L2 Cache: 512K (64 bytes/line)
[   92.755912] CPU: Physical Processor ID: 0
[   92.755912] CPU: Processor Core ID: 1
[   92.755912] Intel machine check architecture supported.
[   92.755912] Intel machine check reporting enabled on CPU#1.
[   92.755912] mce: CPU supports 5 MCE banks
[   92.755912] x86 PAT enabled: cpu 1, old 0x7040600070406, new 0x70106=
00070106
[   93.990537] CPU1: AMD Athlon(tm) 64 X2 Dual Core Processor 3800+ ste=
pping 02
[   94.053604] CPU0 attaching NULL sched-domain.
[   94.060033] Switched to high resolution mode on CPU 1
[   94.080081] CPU0 attaching sched-domain:
[   94.083887]  domain 0: span 0-1 level CPU
[   94.087869]   groups: 0 1
[   94.090479] CPU1 attaching sched-domain:
[   94.094372]  domain 0: span 0-1 level CPU
[   94.098356]   groups: 1 0
[   94.102408] Warning: Processor Platform Limit event detected, but no=
t handled.
[   94.109527] Consider compiling CPUfreq support into your kernel.
[   95.154932] CPU 1 is now offline
[   95.158051] lockdep: fixing up alternatives.
[   95.162325] SMP alternatives: switching to UP code
[   95.177468] CPU0 attaching NULL sched-domain.
[   95.181745] CPU1 attaching NULL sched-domain.
[   95.186093] CPU0 attaching NULL sched-domain.
[   95.191617] device: 'cpu1': device_unregister
[   95.195857] PM: Removing info for No Bus:cpu1
[   95.200654] device: 'cpu1': device_create_release
[   96.210195] device: 'cpu1': device_add
[   96.214098] PM: Adding info for No Bus:cpu1
[   96.218525] lockdep: fixing up alternatives.
[   96.222707] SMP alternatives: switching to SMP code
[   96.237451] CPU 1 irqstacks, hard=3Dc38b0000 soft=3Dc38b1000
[   96.242682] Booting processor 1 APIC 0x1 ip 0x6000
[   95.177129] Initializing CPU#1
[   95.177129] masked ExtINT on CPU#1
[   95.177129] Calibrating delay using timer specific routine.. 4020.61=
 BogoMIPS (lpj=3D20103074)
[   95.177129] CPU: L1 I Cache: 64K (64 bytes/line), D cache 64K (64 by=
tes/line)
[   95.177129] CPU: L2 Cache: 512K (64 bytes/line)
[   95.177129] CPU: Physical Processor ID: 0
[   95.177129] CPU: Processor Core ID: 1
[   95.177129] Intel machine check architecture supported.
[   95.177129] Intel machine check reporting enabled on CPU#1.
[   95.177129] mce: CPU supports 5 MCE banks
[   95.177129] x86 PAT enabled: cpu 1, old 0x7040600070406, new 0x70106=
00070106
[   96.400600] CPU1: AMD Athlon(tm) 64 X2 Dual Core Processor 3800+ ste=
pping 02
[   96.470034] Switched to high resolution mode on CPU 1
[   96.541948] CPU0 attaching NULL sched-domain.
[   96.590274] CPU0 attaching sched-domain:
[   96.594080]  domain 0: span 0-1 level CPU
[   96.598061]   groups: 0 1
[   96.600672] CPU1 attaching sched-domain:
[   96.604565]  domain 0: span 0-1 level CPU
[   96.608548]   groups: 1 0
[   96.660023] eth0: no IPv6 routers present
[   96.686107] device: 'vcs6': device_add
[   96.686415] PM: Adding info for No Bus:vcs6
[   96.690990] device: 'vcsa6': device_add
[   96.691290] PM: Adding info for No Bus:vcsa6
[   96.709512] device: 'vcs8': device_add
[   96.709817] PM: Adding info for No Bus:vcs8
[   96.710719] device: 'vcsa8': device_add
[   96.710917] PM: Adding info for No Bus:vcsa8
[   96.727178] device: 'vcs10': device_add
[   96.727343] PM: Adding info for No Bus:vcs10
[   96.727796] device: 'vcsa10': device_add
[   96.727965] PM: Adding info for No Bus:vcsa10
[   96.744584] device: 'vcs9': device_add
[   96.744742] PM: Adding info for No Bus:vcs9
[   96.745174] device: 'vcsa9': device_add
[   96.745341] PM: Adding info for No Bus:vcsa9
[   96.761661] device: 'vcs5': device_add
[   96.761809] PM: Adding info for No Bus:vcs5
[   96.762258] device: 'vcsa5': device_add
[   96.762419] PM: Adding info for No Bus:vcsa5
[   96.778985] device: 'vcs4': device_add
[   96.779284] PM: Adding info for No Bus:vcs4
[   96.779691] device: 'vcsa4': device_add
[   96.779830] PM: Adding info for No Bus:vcsa4
[   96.796433] device: 'vcs3': device_add
[   96.796601] PM: Adding info for No Bus:vcs3
[   96.796998] device: 'vcsa3': device_add
[   96.797148] PM: Adding info for No Bus:vcsa3
[   96.813650] device: 'vcs2': device_add
[   96.813804] PM: Adding info for No Bus:vcs2
[   96.814071] device: 'vcsa2': device_add
[   96.814217] PM: Adding info for No Bus:vcsa2
[   96.831312] device: 'vcs7': device_add
[   96.831512] PM: Adding info for No Bus:vcs7
[   96.831786] device: 'vcsa7': device_add
[   96.831919] PM: Adding info for No Bus:vcsa7

=46edora Core release 6 (Zod)
Kernel 2.6.31-rc1-tip-01159-g24b7800-dirty on an i686

mercury login: [  107.540046] BUG: MAX_STACK_TRACE_ENTRIES too low!
[  107.544708] turning off the locking correctness validator.
[  107.550009] Pid: 9, comm: events/0 Tainted: G        W  2.6.31-rc1-t=
ip-01159-g24b7800-dirty #59554
[  107.550009] Call Trace:
[  107.550009]  [<c1a847d7>] ? printk+0x14/0x1d
[  107.550009]  [<c107183b>] save_trace+0x89/0x94
[  107.550009]  [<c10718b4>] add_lock_to_list+0x6e/0xa0
[  107.550009]  [<c1073942>] check_prev_add+0x3e2/0x472
[  107.550009]  [<c10c453c>] ? delete_object+0x16/0xaa
[  107.550009]  [<c10c453c>] ? delete_object+0x16/0xaa
[  107.550009]  [<c10c453c>] ? delete_object+0x16/0xaa
[  107.550009]  [<c1073d97>] validate_chain+0x3c5/0x4c3
[  107.550009]  [<c10718b4>] ? add_lock_to_list+0x6e/0xa0
[  107.550009]  [<c10744cc>] __lock_acquire+0x637/0x69a
[  107.550009]  [<c10745c3>] lock_acquire+0x94/0xb7
[  107.550009]  [<c10c453c>] ? delete_object+0x16/0xaa
[  107.550009]  [<c1a871ba>] _write_lock_irqsave+0x37/0x6a
[  107.550009]  [<c10c453c>] ? delete_object+0x16/0xaa
[  107.550009]  [<c10c453c>] delete_object+0x16/0xaa
[  107.550009]  [<c10c50f4>] kmemleak_free+0x42/0x80
[  107.550009]  [<c10c33a2>] kmem_cache_free+0x4b/0x110
[  107.550009]  [<c18d2eca>] ? dst_destroy+0x8d/0xc0
[  107.550009]  [<c18d2eca>] dst_destroy+0x8d/0xc0
[  107.550009]  [<c18d2f66>] dst_gc_task+0x69/0x17f
[  107.550009]  [<c10744cc>] ? __lock_acquire+0x637/0x69a
[  107.550009]  [<c10287c6>] ? sched_clock+0x8/0xb
[  107.550009]  [<c10601f3>] ? run_workqueue+0x9e/0x1ac
[  107.550009]  [<c1060238>] run_workqueue+0xe3/0x1ac
[  107.550009]  [<c10601f3>] ? run_workqueue+0x9e/0x1ac
[  107.550009]  [<c18d2efd>] ? dst_gc_task+0x0/0x17f
[  107.550009]  [<c10603bc>] worker_thread+0xbb/0xc7
[  107.550009]  [<c1063e4c>] ? autoremove_wake_function+0x0/0x38
[  107.550009]  [<c1060301>] ? worker_thread+0x0/0xc7
[  107.550009]  [<c1063bd8>] kthread+0x6e/0x73
[  107.550009]  [<c1063b6a>] ? kthread+0x0/0x73
[  107.550009]  [<c1023997>] kernel_thread_helper+0x7/0x10
[  142.172347] kmemleak: 571 new suspected memory leaks (see /sys/kerne=
l/debug/kmemleak)
[  351.000014] ------------[ cut here ]------------
[  351.004596] WARNING: at net/sched/sch_generic.c:246 dev_watchdog+0x1=
0b/0x19c()
[  351.011815] Hardware name: System Product Name
[  351.016220] NETDEV WATCHDOG: eth0 (forcedeth): transmit queue 0 time=
d out
[  351.022996] Pid: 0, comm: swapper Tainted: G        W  2.6.31-rc1-ti=
p-01159-g24b7800-dirty #59554
[  351.031850] Call Trace:
[  351.034270]  [<c105108d>] warn_slowpath_common+0x60/0x90
[  351.039550]  [<c10510fb>] warn_slowpath_fmt+0x29/0x2c
[  351.044593]  [<c18eadf6>] dev_watchdog+0x10b/0x19c
[  351.049348]  [<c1074779>] ? __lock_acquired+0xbc/0x2c3
[  351.054474]  [<c1059fb7>] ? run_timer_softirq+0x125/0x1f0
[  351.059832]  [<c105a00d>] run_timer_softirq+0x17b/0x1f0
[  351.065046]  [<c1059fb7>] ? run_timer_softirq+0x125/0x1f0
[  351.070420]  [<c18eaceb>] ? dev_watchdog+0x0/0x19c
[  351.075173]  [<c105625d>] __do_softirq+0xbc/0x16f
[  351.079849]  [<c10561a1>] ? __do_softirq+0x0/0x16f
[  351.084632]  <IRQ>  [<c1055b7e>] ? irq_exit+0x3a/0x3c
[  351.089646]  [<c10340b4>] ? smp_apic_timer_interrupt+0x74/0x82
[  351.095468]  [<c102383b>] ? apic_timer_interrupt+0x2f/0x34
[  351.100927]  [<c10220a5>] ? cpu_idle+0x43/0x5e
[  351.105334]  [<c10297fc>] ? default_idle+0x6e/0xc4
[  351.110114]  [<c103adc8>] ? native_safe_halt+0xa/0xc
[  351.115040]  [<c1029801>] ? default_idle+0x73/0xc4
[  351.119803]  [<c10220ab>] ? cpu_idle+0x49/0x5e
[  351.124241]  [<c1a3170c>] ? rest_init+0x58/0x5a
[  351.128735]  [<c20797e6>] ? start_kernel+0x268/0x26d
[  351.133688]  [<c207904a>] ? i386_start_kernel+0x39/0x41
[  351.138872] ---[ end trace 47b331f1c1cf47e3 ]---
[  351.143480] eth0: Got tx_timeout. irq: 00000076
[  351.148595] eth0: Ring at 35478000
[  351.151989] eth0: Dumping tx registers
[  351.155706]   0: 00002076 00000000 00000003 0007000d 00000000 000000=
00 00000000 00000000
[  351.163788]  20: 06255300 ff701365 00000000 00000000 00000000 000000=
00 00000000 00000000
[  351.171865]  40: 0420e20e 0000a855 00002e20 00000000 00000000 000000=
00 00000000 00000000
[  351.179927]  60: 00000000 00000000 00000000 00000000 00000000 000000=
00 00000000 00000000
[  351.188012]  80: 003b0f3c 00000001 00040000 007f0028 0000061c 000000=
01 00200000 8003ff43
[  351.196090]  a0: 0014050f 00000016 dcd41300 00001241 00000001 000000=
00 2300cccd 0000ecbe
[  351.204175]  c0: 10000002 00000001 00000001 00000001 00000001 000000=
01 00000001 00000001
[  351.212252]  e0: 00000001 00000001 00000001 00000001 00000001 000000=
01 00000001 00000001
[  351.220331] 100: 3547a000 35478000 01ff00ff 00008000 00010032 000000=
00 0000000a 3547aff0
[  351.228391] 120: 35479ff0 337cd040 a000ffeb 00000000 00000000 3547af=
fc 35479ffc 0fe08000
[  351.236477] 140: 00304120 80002600 00000000 00000000 00000000 000000=
00 00000000 00000000
[  351.244553] 160: 00000000 00000000 00000000 00000000 00000000 000000=
00 00000000 00000000
[  351.252631] 180: 00000016 00000008 0194796d 00008103 00000026 000000=
0f 0194000f 0000000f
[  351.260709] 1a0: 00000016 00000008 0194796d 00008103 00000026 000000=
0f 0194000f 0000000f
[  351.268770] 1c0: 00000016 00000008 0194796d 00008103 00000026 000000=
0f 0194000f 0000000f
[  351.276863] 1e0: 00000016 00000008 0194796d 00008103 00000026 000000=
0f 0194000f 0000000f
[  351.284941] 200: 00000000 00000000 00000000 00000000 00000000 000000=
00 00000000 00000000
[  351.293018] 220: 00000000 00000000 00000000 00000000 00000000 000000=
00 00000000 00000000
[  351.301095] 240: 00000000 00000000 00000000 00000000 00000000 000000=
00 00000000 00000000
[  351.309157] 260: 00000000 00000000 fe020001 00000100 00000000 000000=
00 7e020001 00000100
[  351.317242] 280: 00000000 00000000 00000000 00000000 00000000 000000=
00 00000000 00000000
[  351.325320] 2a0: 00000000 00000000 00000000 00000000 00000000 000000=
00 00000000 00000000
[  351.333397] 2c0: 00000000 00000000 00000000 00000000 00000000 000000=
01 00000001 00000001
[  351.341473] 2e0: 00000001 00000001 00000001 00000001 00000001 000000=
01 00000001 00000001
[  351.349536] 300: 80210000 00000000 00000000 00000000 00000000 000020=
00 00000000 00000000
[  351.357620] 320: 00000000 00000000 00000000 00000000 00000000 000000=
00 00000000 00000000
[  351.365697] 340: 00000000 00000000 00000000 00000000 00000000 000000=
00 000b328e 00000000
[  351.373775] 360: 00000000 00000000 00000000 00000000 00000000 000000=
00 00000000 00000000
[  351.381852] 380: 00000000 00000000 00000000 00000000 00000000 000000=
00 00000000 00000000
[  351.389914] 3a0: 00000000 00000000 00000000 00000000 00000000 000000=
00 00000000 00000000
[  351.397999] 3c0: 00000000 00000000 00000000 00000000 00000000 000000=
00 00000000 00000000
[  351.406076] 3e0: 00000000 00000000 00000000 00000000 00000000 000000=
00 00000000 00000000
[  351.414154] 400: 00000000 00000000 00000000 00000000 00000000 000000=
00 00000000 00000000
[  351.422231] 420: 00000000 00000000 00000000 00000000 00000000 000000=
00 00000000 00000000
[  351.430309] 440: 00000000 00000000 00000000 00000000 00000000 000000=
00 00000000 00000000
[  351.438370] 460: 00000000 00000000 00000000 00000000 00000000 000000=
00 00000000 00000000
[  351.446454] 480: 00000000 00000000 00000000 00000000 00000000 000000=
00 00000000 00000000
[  351.454532] 4a0: 00000000 00000000 00000000 00000000 00000000 000000=
00 00000000 00000000
[  351.462610] 4c0: 00000000 00000000 00000000 00000000 00000000 000000=
00 00000000 00000000
[  351.470686] 4e0: 00000000 00000000 00000000 00000000 00000000 000000=
00 00000000 00000000
[  351.478748] 500: 000110ff 80000000 00000000 00000000 00000000 000000=
00 00000000 00000000
[  351.486833] 520: 00000000 00000000 00000000 00000000 00000000 000000=
00 00000000 00000000
[  351.494911] 540: 00000000 00000000 00000000 00000000 00000000 000000=
00 00000000 00000000
[  351.502989] 560: 00000000 00000000 00000000 00000000 00000000 000000=
00 00000000 00000000
[  351.511065] 580: 00000000 00000000 00000000 00000000 00000000 000000=
00 00000000 00000000
[  351.519127] 5a0: 00000000 00000000 00000000 00000000 00000000 000000=
00 00000000 00000000
[  351.527212] 5c0: 00000000 00000000 00000000 00000000 00000000 000000=
00 00000000 00000000
[  351.535290] 5e0: 00000000 00000000 00000000 00000000 00000000 000000=
00 00000000 00000000
[  351.543367] 600: 00000000 00000000 00000000 00000000 00000000 000000=
00 00000000 00000000
[  351.551441] eth0: Dumping tx ring
[  351.554725] 000: 00000000 35be0002 20000040 // 00000000 33fe3802 220=
0005e // 00000000 3575d402 20000052 // 00000000 35be1c02 20000040
[  351.566715] 004: 00000000 3575f402 2200004a // 00000000 35be0402 200=
00040 // 00000000 33fe4002 2200005e // 00000000 35be1e02 20000040
[  351.578700] 008: 00000000 35049c02 22000040 // 00000000 3501a802 220=
0004a // 00000000 357c6c02 20000040 // 00000000 35048002 22000040
[  351.590687] 00c: 00000000 357c6002 22000040 // 00000000 357c6202 220=
00040 // 00000000 357c6602 22000040 // 00000000 357c6402 22000040
[  351.602673] 010: 00000000 357c6e02 22000040 // 00000000 357c7602 220=
00040 // 00000000 357c7402 22000040 // 00000000 350eb602 22000040
[  351.614659] 014: 00000000 350eb402 22000040 // 00000000 350eb202 220=
00040 // 00000000 350eb002 22000040 // 00000000 3575f802 2200004a
[  351.626645] 018: 00000000 3577f202 20000040 // 00000000 35be1402 220=
00040 // 00000000 35be1202 22000040 // 00000000 35048202 22000040
[  351.638631] 01c: 00000000 350eac02 22000040 // 00000000 350eae02 220=
00040 // 00000000 350ebe02 22000040 // 00000000 350eba02 22000040
[  351.650617] 020: 00000000 350eb802 22000040 // 00000000 350ea402 220=
00040 // 00000000 350eaa02 22000040 // 00000000 3552f802 22000040
[  351.662603] 024: 00000000 3568f602 22000040 // 00000000 35098402 220=
00040 // 00000000 35098602 22000040 // 00000000 3568e202 22000040
[  351.674590] 028: 00000000 35049602 22000040 // 00000000 35098c02 220=
00040 // 00000000 35099002 22000040 // 00000000 35049802 22000040
[  351.686576] 02c: 00000000 35049e02 22000040 // 00000000 35099202 220=
00040 // 00000000 35099402 22000040 // 00000000 35049a02 22000040
[  351.698562] 030: 00000000 35099a02 22000040 // 00000000 357c6802 220=
00040 // 00000000 35099802 22000040 // 00000000 35099e02 22000040
[  351.710549] 034: 00000000 35098202 22000040 // 00000000 350c1e02 220=
00040 // 00000000 3552f602 22000040 // 00000000 3552ea02 22000040
[  351.722534] 038: 00000000 355e3e02 22000040 // 00000000 350c0c02 220=
00040 // 00000000 355e3c02 22000040 // 00000000 35662402 22000040
[  351.734520] 03c: 00000000 350c1802 22000040 // 00000000 36be2a02 220=
00040 // 00000000 3568e802 22000040 // 00000000 37b62202 22000040
[  351.746506] 040: 00000000 35663a02 22000040 // 00000000 3577e202 220=
00040 // 00000000 35be1a02 22000040 // 00000000 35be0e02 22000040
[  351.758493] 044: 00000000 35048602 22000040 // 00000000 3577ec02 220=
00040 // 00000000 35099c02 22000040 // 00000000 35099602 22000040
[  351.770478] 048: 00000000 33760600 22000040 // 00000000 33779602 220=
00040 // 00000000 3375e602 22000040 // 00000000 33779002 22000040
[  351.782465] 04c: 00000000 33778e02 22000040 // 00000000 33778c02 220=
00040 // 00000000 3375e002 22000040 // 00000000 33778a02 22000040
[  351.794451] 050: 00000000 33778802 22000040 // 00000000 33778602 220=
00040 // 00000000 3375e802 22000040 // 00000000 33778402 22000040
[  351.806438] 054: 00000000 33778202 22000040 // 00000000 33779c02 220=
00040 // 00000000 3375f002 22000040 // 00000000 3375f202 22000040
[  351.818423] 058: 00000000 33778002 22000040 // 00000000 33779a02 220=
00040 // 00000000 3375ec02 22000040 // 00000000 3375ee02 22000040
[  351.830410] 05c: 00000000 33779802 22000040 // 00000000 33779402 220=
00040 // 00000000 3375f402 22000040 // 00000000 3375f602 22000040
[  351.842396] 060: 00000000 33760002 22000040 // 00000000 3375ea02 220=
00040 // 00000000 33761c02 22000040 // 00000000 3375fa02 22000040
[  351.854382] 064: 00000000 3375e202 22000040 // 00000000 3375fe02 220=
00040 // 00000000 33761a02 22000040 // 00000000 350c1602 22000040
[  351.866369] 068: 00000000 350c0802 22000040 // 00000000 350c0202 220=
00040 // 00000000 33760202 22000040 // 00000000 357c7e02 22000040
[  351.878354] 06c: 00000000 3544bc02 22000040 // 00000000 33761802 220=
00040 // 00000000 33761002 22000040 // 00000000 33760e02 22000040
[  351.890340] 070: 00000000 3568e002 22000040 // 00000000 33761602 220=
00040 // 00000000 33760c02 22000040 // 00000000 33760a02 22000040
[  351.902327] 074: 00000000 3375f802 22000040 // 00000000 33760802 220=
00040 // 00000000 33760402 22000040 // 00000000 35098002 22000040
[  351.914314] 078: 00000000 3375fc02 22000040 // 00000000 33761202 220=
00040 // 00000000 33761e02 22000040 // 00000000 37b31802 22000040
[  351.926300] 07c: 00000000 337f2002 22000040 // 00000000 33779202 220=
00040 // 00000000 337f4002 22000040 // 00000000 337f4202 22000040
[  351.938286] 080: 00000000 337f2402 22000040 // 00000000 337f4402 220=
00040 // 00000000 337f4602 22000040 // 00000000 337f4802 22000040
[  351.950271] 084: 00000000 337f2202 22000040 // 00000000 337f2c02 220=
00040 // 00000000 337f3202 22000040 // 00000000 337f4c02 22000040
[  351.962257] 088: 00000000 337f3402 22000040 // 00000000 337f2e02 220=
00040 // 00000000 337f3602 22000040 // 00000000 337f5002 22000040
[  351.974244] 08c: 00000000 337f3802 22000040 // 00000000 337f3a02 220=
00040 // 00000000 337f3c02 22000040 // 00000000 337f4a02 22000040
[  351.986230] 090: 00000000 337f3e02 22000040 // 00000000 337f3000 220=
00040 // 00000000 337f5402 22000040 // 00000000 337b7802 22000040
[  351.998216] 094: 00000000 337b7402 22000040 // 00000000 337f5202 220=
00040 // 00000000 337f5802 22000040 // 00000000 337b7202 22000040
[  352.010202] 098: 00000000 337b7002 22000040 // 00000000 337f5a02 220=
00040 // 00000000 337f5c02 22000040 // 00000000 337b6e02 22000040
[  352.022188] 09c: 00000000 337b6c02 22000040 // 00000000 337f5e02 220=
00040 // 00000000 337b7a02 22000040 // 00000000 3375e402 22000040
[  352.034807] 0a0: 00000000 337f4e02 22000040 // 00000000 337b6802 220=
00040 // 00000000 337b6a02 22000040 // 00000000 337f2a02 22000040
[  352.046793] 0a4: 00000000 337f2802 22000040 // 00000000 337b6402 220=
00040 // 00000000 337b6202 22000040 // 00000000 337f2602 22000040
[  352.058780] 0a8: 00000000 33779e02 22000040 // 00000000 337b6002 220=
00040 // 00000000 33788402 22000040 // 00000000 337f0602 22000040
[  352.070766] 0ac: 00000000 33788802 22000040 // 00000000 337f0402 220=
00040 // 00000000 33788002 22000040 // 00000000 337f0802 22000040
[  352.082752] 0b0: 00000000 33788a02 22000040 // 00000000 337f0a02 220=
00040 // 00000000 33788c02 22000040 // 00000000 337f0c02 22000040
[  352.094738] 0b4: 00000000 33788e02 22000040 // 00000000 337f0e02 220=
00040 // 00000000 337f1002 22000040 // 00000000 33789402 22000040
[  352.106724] 0b8: 00000000 33789602 22000040 // 00000000 33789802 220=
00040 // 00000000 337f1402 22000040 // 00000000 33789a02 22000040
[  352.118710] 0bc: 00000000 33789c02 22000040 // 00000000 33789e02 220=
00040 // 00000000 337f1800 22000040 // 00000000 32424a02 22000040
[  352.130696] 0c0: 00000000 33788602 22000040 // 00000000 337f1202 220=
00040 // 00000000 337f0002 22000040 // 00000000 337f1c02 22000040
[  352.142683] 0c4: 00000000 32424202 22000040 // 00000000 337f0202 220=
00040 // 00000000 337b7602 22000040 // 00000000 337b7c02 22000040
[  352.154668] 0c8: 00000000 32424402 22000040 // 00000000 337b6602 220=
00040 // 00000000 337b7e02 22000040 // 00000000 33761402 22000040
[  352.166654] 0cc: 00000000 32424802 22000040 // 00000000 337f5602 220=
00040 // 00000000 33789002 22000040 // 00000000 32424e02 22000040
[  352.178641] 0d0: 00000000 32425202 22000040 // 00000000 337dc402 220=
00040 // 00000000 32424c02 22000040 // 00000000 32425402 22000040
[  352.190628] 0d4: 00000000 32425602 22000040 // 00000000 337dc202 220=
00040 // 00000000 32425802 22000040 // 00000000 32425a02 22000040
[  352.202613] 0d8: 00000000 32425c02 22000040 // 00000000 337dc602 220=
00040 // 00000000 32425e02 22000040 // 00000000 337dc802 22000040
[  352.214599] 0dc: 00000000 337dce02 22000040 // 00000000 337f1602 220=
00040 // 00000000 33788202 22000040 // 00000000 337dca02 22000040
[  352.226585] 0e0: 00000000 337dd002 22000040 // 00000000 33789202 220=
00040 // 00000000 32424002 22000040 // 00000000 337dd202 22000040
[  352.238572] 0e4: 00000000 337dd402 22000040 // 00000000 32425002 220=
00040 // 00000000 32424602 22000040 // 00000000 337cca00 22000040
[  352.250558] 0e8: 00000000 337dda02 22000040 // 00000000 32400402 220=
00040 // 00000000 337dde02 22000040 // 00000000 32400002 22000040
[  352.262543] 0ec: 00000000 337dd602 22000040 // 00000000 32400802 220=
00040 // 00000000 337dcc02 22000040 // 00000000 32400a02 22000040
[  352.274530] 0f0: 00000000 337dc002 22000040 // 00000000 32400c02 220=
00040 // 00000000 337cc602 22000040 // 00000000 32400e02 22000040
[  352.286516] 0f4: 00000000 337cc802 22000040 // 00000000 32400202 220=
00040 // 00000000 337cdc02 22000040 // 00000000 337cda02 22000040
[  352.298502] 0f8: 00000000 337cd802 22000040 // 00000000 32401602 220=
00040 // 00000000 337cd602 22000040 // 00000000 337cd402 22000040
[  352.310489] 0fc: 00000000 337cd202 22000040 // 00000000 32401402 220=
00040 // 00000000 337cd002 22000040 // 00000000 00000000 00000000
;Press any key to enter the menu
