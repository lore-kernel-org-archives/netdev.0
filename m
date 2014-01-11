From: Fengguang Wu <fengguang.wu@intel.com>
Subject: [ipv6_vti.c] INFO: trying to register non-static key.
Date: Sun, 12 Jan 2014 07:10:23 +0800
Message-ID: <20140111231023.GA9864@localhost>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="BXVAT5kNtrzKuDFl"
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Li RongQing <roy.qing.li@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--BXVAT5kNtrzKuDFl
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

Greetings,

Here is a warning introduced by commit 469bdcefd ("ipv6: fix the use
of pcpu_tstats in ip6_vti.c"):
    
[    5.138330] NET: Registered protocol family 10
[    5.142996] mip6: Mobile IPv6
[    5.143479] ip6_tables: (C) 2000-2006 Netfilter Core Team
[    5.146779] INFO: trying to register non-static key.
[    5.147439] the code is fine but needs lockdep annotation.
[    5.147711] turning off the locking correctness validator.
[    5.147711] CPU: 1 PID: 1 Comm: swapper/0 Not tainted 3.13.0-rc7-00264-gc11a763 #1
[    5.147711] Hardware name: Bochs Bochs, BIOS Bochs 01/01/2011
[    5.147711]  be55ec1c b001fc34 b12f4e53 00000000 b001fc78 b02b9604 b175fb0c 00000000
[    5.147711]  b0010838 b0010440 00000001 b001fc94 b1d96828 00000000 00000003 00000000
[    5.147711]  be55ec1c b0010440 be55ebf8 00000046 00000000 b001fcac b02badaf 00000002
[    5.147711] Call Trace:
[    5.147711]  [<b12f4e53>] dump_stack+0xb8/0x108
[    5.147711]  [<b02b9604>] __lock_acquire.isra.19+0x3a4/0x1a00
[    5.147711]  [<b02badaf>] lock_acquire+0x14f/0x1d0
[    5.147711]  [<b0e758f1>] ? dev_get_stats+0x81/0x150
[    5.147711]  [<b1017d62>] ip_tunnel_get_stats64+0xc2/0x350
[    5.147711]  [<b0e758f1>] ? dev_get_stats+0x81/0x150
[    5.147711]  [<b08b9966>] ? __nla_reserve+0x56/0x60
[    5.147711]  [<b0e758f1>] dev_get_stats+0x81/0x150
[    5.147711]  [<b0e89539>] rtnl_fill_ifinfo+0x819/0x1130
[    5.147711]  [<b0e8e27f>] rtmsg_ifinfo+0x9f/0x190
[    5.147711]  [<b0e77d27>] register_netdevice+0x927/0xa80
[    5.147711]  [<b10dd6cd>] ? ip6_tnl_get_cap+0x3d/0x140
[    5.147711]  [<b0e77eae>] register_netdev+0x2e/0x60
[    5.147711]  [<b1ba3fe5>] vti6_init_net+0x32d/0x3a8
[    5.147711]  [<b1ba3e15>] ? vti6_init_net+0x15d/0x3a8
[    5.147711]  [<b0e65402>] ops_init+0x1d2/0x250
[    5.147711]  [<b0e65540>] register_pernet_operations.isra.5+0xc0/0x130
[    5.147711]  [<b0e657d6>] register_pernet_device+0x36/0xa0
[    5.147711]  [<b1ba4060>] ? vti6_init_net+0x3a8/0x3a8
[    5.147711]  [<b1ba407f>] vti6_tunnel_init+0x1f/0xfa
[    5.147711]  [<b1ba3c72>] ? synproxy_tg6_init+0x4d/0x93
[    5.147711]  [<b1afb634>] do_one_initcall+0xf6/0x222
[    5.147711]  [<b0284cf1>] ? parameq+0x21/0xf0
[    5.147711]  [<b1afa738>] ? repair_env_string+0x32/0xd3
[    5.147711]  [<b02851b2>] ? parse_args+0x3f2/0x5d0
[    5.147711]  [<b1afbb64>] kernel_init_freeable+0x404/0x59a
[    5.147711]  [<b1afa706>] ? do_early_param+0x12b/0x12b
[    5.147711]  [<b12e4cf9>] kernel_init+0x19/0x230
[    5.147711]  [<b13078bb>] ret_from_kernel_thread+0x1b/0x30
[    5.147711]  [<b12e4ce0>] ? rest_init+0x170/0x170
[    5.174185] sit: IPv6 over IPv4 tunneling driver
[    5.178596] ip6_gre: GRE over IPv6 tunneling driver
[    5.181035] NET: Registered protocol family 17

It's fairly reproducible and the warning disappears when reverting the
commit.

Thanks,
Fengguang

--BXVAT5kNtrzKuDFl
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename="dmesg-quantal-xian-26:20140110002935:i386-randconfig-x4-01100001:3.13.0-rc7-00264-gc11a763:1"
Content-Transfer-Encoding: quoted-printable

early console in setup code
[    0.000000] Initializing cgroup subsys cpuset
[    0.000000] Initializing cgroup subsys cpu
[    0.000000] Linux version 3.13.0-rc7-00264-gc11a763 (kbuild@xian) (gcc v=
ersion 4.8.1 (Debian 4.8.1-8) ) #1 SMP Fri Jan 10 00:27:06 CST 2014
[    0.000000] KERNEL supported cpus:
[    0.000000]   UMC UMC UMC UMC
[    0.000000] CPU: vendor_id 'GenuineIntel' unknown, using generic init.
[    0.000000] CPU: Your system may be unstable.
[    0.000000] e820: BIOS-provided physical RAM map:
[    0.000000] BIOS-e820: [mem 0x0000000000000000-0x000000000009fbff] usable
[    0.000000] BIOS-e820: [mem 0x000000000009fc00-0x000000000009ffff] reser=
ved
[    0.000000] BIOS-e820: [mem 0x00000000000f0000-0x00000000000fffff] reser=
ved
[    0.000000] BIOS-e820: [mem 0x0000000000100000-0x000000000fffdfff] usable
[    0.000000] BIOS-e820: [mem 0x000000000fffe000-0x000000000fffffff] reser=
ved
[    0.000000] BIOS-e820: [mem 0x00000000feffc000-0x00000000feffffff] reser=
ved
[    0.000000] BIOS-e820: [mem 0x00000000fffc0000-0x00000000ffffffff] reser=
ved
[    0.000000] Notice: NX (Execute Disable) protection cannot be enabled: n=
on-PAE kernel!
[    0.000000] SMBIOS 2.4 present.
[    0.000000] DMI: Bochs Bochs, BIOS Bochs 01/01/2011
[    0.000000] Hypervisor detected: KVM
[    0.000000] e820: update [mem 0x00000000-0x00000fff] usable =3D=3D> rese=
rved
[    0.000000] e820: remove [mem 0x000a0000-0x000fffff] usable
[    0.000000] e820: last_pfn =3D 0xfffe max_arch_pfn =3D 0x100000
[    0.000000] Scan for SMP in [mem 0x00000000-0x000003ff]
[    0.000000] Scan for SMP in [mem 0x0009fc00-0x0009ffff]
[    0.000000] Scan for SMP in [mem 0x000f0000-0x000fffff]
[    0.000000] found SMP MP-table at [mem 0x000fdac0-0x000fdacf] mapped at =
[b00fdac0]
[    0.000000]   mpc: fdad0-fdbec
[    0.000000] Scanning 1 areas for low memory corruption
[    0.000000] initial memory mapped: [mem 0x00000000-0x02bfffff]
[    0.000000] Base memory trampoline at [b009b000] 9b000 size 16384
[    0.000000] init_memory_mapping: [mem 0x00000000-0x000fffff]
[    0.000000]  [mem 0x00000000-0x000fffff] page 4k
[    0.000000] init_memory_mapping: [mem 0x0e000000-0x0e3fffff]
[    0.000000]  [mem 0x0e000000-0x0e3fffff] page 4k
[    0.000000] BRK [0x0268e000, 0x0268efff] PGTABLE
[    0.000000] init_memory_mapping: [mem 0x08000000-0x0dffffff]
[    0.000000]  [mem 0x08000000-0x0dffffff] page 4k
[    0.000000] BRK [0x0268f000, 0x0268ffff] PGTABLE
[    0.000000] BRK [0x02690000, 0x02690fff] PGTABLE
[    0.000000] BRK [0x02691000, 0x02691fff] PGTABLE
[    0.000000] BRK [0x02692000, 0x02692fff] PGTABLE
[    0.000000] BRK [0x02693000, 0x02693fff] PGTABLE
[    0.000000] init_memory_mapping: [mem 0x00100000-0x07ffffff]
[    0.000000]  [mem 0x00100000-0x07ffffff] page 4k
[    0.000000] init_memory_mapping: [mem 0x0e400000-0x0fffdfff]
[    0.000000]  [mem 0x0e400000-0x0fffdfff] page 4k
[    0.000000] RAMDISK: [mem 0x0e7ab000-0x0ffeffff]
[    0.000000] ACPI: RSDP 000fd930 000014 (v00 BOCHS )
[    0.000000] ACPI: RSDT 0fffe450 000034 (v01 BOCHS  BXPCRSDT 00000001 BXP=
C 00000001)
[    0.000000] ACPI: FACP 0fffff80 000074 (v01 BOCHS  BXPCFACP 00000001 BXP=
C 00000001)
[    0.000000] ACPI: DSDT 0fffe490 0011A9 (v01   BXPC   BXDSDT 00000001 INT=
L 20100528)
[    0.000000] ACPI: FACS 0fffff40 000040
[    0.000000] ACPI: SSDT 0ffff7a0 000796 (v01 BOCHS  BXPCSSDT 00000001 BXP=
C 00000001)
[    0.000000] ACPI: APIC 0ffff680 000080 (v01 BOCHS  BXPCAPIC 00000001 BXP=
C 00000001)
[    0.000000] ACPI: HPET 0ffff640 000038 (v01 BOCHS  BXPCHPET 00000001 BXP=
C 00000001)
[    0.000000] ACPI: Local APIC address 0xfee00000
[    0.000000] mapped APIC to         ffffb000 (        fee00000)
[    0.000000] 0MB HIGHMEM available.
[    0.000000] 255MB LOWMEM available.
[    0.000000]   mapped low ram: 0 - 0fffe000
[    0.000000]   low ram: 0 - 0fffe000
[    0.000000] kvm-clock: Using msrs 4b564d01 and 4b564d00
[    0.000000] kvm-clock: cpu 0, msr 0:fffd001, boot clock
[    0.000000] Zone ranges:
[    0.000000]   Normal   [mem 0x00001000-0x0fffdfff]
[    0.000000]   HighMem  empty
[    0.000000] Movable zone start for each node
[    0.000000] Early memory node ranges
[    0.000000]   node   0: [mem 0x00001000-0x0009efff]
[    0.000000]   node   0: [mem 0x00100000-0x0fffdfff]
[    0.000000] On node 0 totalpages: 65436
[    0.000000] free_area_init_node: node 0, pgdat b1ae5840, node_mem_map be=
56b024
[    0.000000]   Normal zone: 576 pages used for memmap
[    0.000000]   Normal zone: 0 pages reserved
[    0.000000]   Normal zone: 65436 pages, LIFO batch:15
[    0.000000] Using APIC driver default
[    0.000000] ACPI: PM-Timer IO Port: 0xb008
[    0.000000] ACPI: Local APIC address 0xfee00000
[    0.000000] mapped APIC to         ffffb000 (        fee00000)
[    0.000000] ACPI: LAPIC (acpi_id[0x00] lapic_id[0x00] enabled)
[    0.000000] ACPI: LAPIC (acpi_id[0x01] lapic_id[0x01] enabled)
[    0.000000] ACPI: LAPIC_NMI (acpi_id[0xff] dfl dfl lint[0x1])
[    0.000000] ACPI: IOAPIC (id[0x00] address[0xfec00000] gsi_base[0])
[    0.000000] IOAPIC[0]: apic_id 0, version 17, address 0xfec00000, GSI 0-=
23
[    0.000000] ACPI: INT_SRC_OVR (bus 0 bus_irq 0 global_irq 2 dfl dfl)
[    0.000000] Int: type 0, pol 0, trig 0, bus 00, IRQ 00, APIC ID 0, APIC =
INT 02
[    0.000000] ACPI: INT_SRC_OVR (bus 0 bus_irq 5 global_irq 5 high level)
[    0.000000] Int: type 0, pol 1, trig 3, bus 00, IRQ 05, APIC ID 0, APIC =
INT 05
[    0.000000] ACPI: INT_SRC_OVR (bus 0 bus_irq 9 global_irq 9 high level)
[    0.000000] Int: type 0, pol 1, trig 3, bus 00, IRQ 09, APIC ID 0, APIC =
INT 09
[    0.000000] ACPI: INT_SRC_OVR (bus 0 bus_irq 10 global_irq 10 high level)
[    0.000000] Int: type 0, pol 1, trig 3, bus 00, IRQ 0a, APIC ID 0, APIC =
INT 0a
[    0.000000] ACPI: INT_SRC_OVR (bus 0 bus_irq 11 global_irq 11 high level)
[    0.000000] Int: type 0, pol 1, trig 3, bus 00, IRQ 0b, APIC ID 0, APIC =
INT 0b
[    0.000000] ACPI: IRQ0 used by override.
[    0.000000] Int: type 0, pol 0, trig 0, bus 00, IRQ 01, APIC ID 0, APIC =
INT 01
[    0.000000] ACPI: IRQ2 used by override.
[    0.000000] Int: type 0, pol 0, trig 0, bus 00, IRQ 03, APIC ID 0, APIC =
INT 03
[    0.000000] Int: type 0, pol 0, trig 0, bus 00, IRQ 04, APIC ID 0, APIC =
INT 04
[    0.000000] ACPI: IRQ5 used by override.
[    0.000000] Int: type 0, pol 0, trig 0, bus 00, IRQ 06, APIC ID 0, APIC =
INT 06
[    0.000000] Int: type 0, pol 0, trig 0, bus 00, IRQ 07, APIC ID 0, APIC =
INT 07
[    0.000000] Int: type 0, pol 0, trig 0, bus 00, IRQ 08, APIC ID 0, APIC =
INT 08
[    0.000000] ACPI: IRQ9 used by override.
[    0.000000] ACPI: IRQ10 used by override.
[    0.000000] ACPI: IRQ11 used by override.
[    0.000000] Int: type 0, pol 0, trig 0, bus 00, IRQ 0c, APIC ID 0, APIC =
INT 0c
[    0.000000] Int: type 0, pol 0, trig 0, bus 00, IRQ 0d, APIC ID 0, APIC =
INT 0d
[    0.000000] Int: type 0, pol 0, trig 0, bus 00, IRQ 0e, APIC ID 0, APIC =
INT 0e
[    0.000000] Int: type 0, pol 0, trig 0, bus 00, IRQ 0f, APIC ID 0, APIC =
INT 0f
[    0.000000] Using ACPI (MADT) for SMP configuration information
[    0.000000] ACPI: HPET id: 0x8086a201 base: 0xfed00000
[    0.000000] smpboot: Allowing 2 CPUs, 0 hotplug CPUs
[    0.000000] mapped IOAPIC to ffffa000 (fec00000)
[    0.000000] nr_irqs_gsi: 40
[    0.000000] e820: [mem 0x10000000-0xfeffbfff] available for PCI devices
[    0.000000] Booting paravirtualized kernel on KVM
[    0.000000] setup_percpu: NR_CPUS:32 nr_cpumask_bits:32 nr_cpu_ids:2 nr_=
node_ids:1
[    0.000000] PERCPU: Embedded 12 pages/cpu @be553000 s33736 r0 d15416 u49=
152
[    0.000000] pcpu-alloc: s33736 r0 d15416 u49152 alloc=3D12*4096
[    0.000000] pcpu-alloc: [0] 0 [0] 1=20
[    0.000000] kvm-clock: cpu 0, msr 0:fffd001, primary cpu clock
[    0.000000] KVM setup async PF for cpu 0
[    0.000000] kvm-stealtime: cpu 0, msr e555580
[    0.000000] Built 1 zonelists in Zone order, mobility grouping on.  Tota=
l pages: 64860
[    0.000000] Kernel command line: hung_task_panic=3D1 earlyprintk=3DttyS0=
,115200 debug apic=3Ddebug sysrq_always_enabled panic=3D10  prompt_ramdisk=
=3D0 console=3DttyS0,115200 console=3Dtty0 vga=3Dnormal  root=3D/dev/ram0 r=
w link=3D/kernel-tests/run-queue/kvm/i386-randconfig-x4-01100001/linux-deve=
l:devel-hourly-2014010921/.vmlinuz-c11a763d03cd080104cfb045b2edfebcb2c6f8ef=
-20140110002917-8-xian branch=3Dlinux-devel/devel-hourly-2014010921 BOOT_IM=
AGE=3D/kernel/i386-randconfig-x4-01100001/c11a763d03cd080104cfb045b2edfebcb=
2c6f8ef/vmlinuz-3.13.0-rc7-00264-gc11a763
[    0.000000] sysrq: sysrq always enabled.
[    0.000000] PID hash table entries: 1024 (order: 0, 4096 bytes)
[    0.000000] Dentry cache hash table entries: 32768 (order: 5, 131072 byt=
es)
[    0.000000] Inode-cache hash table entries: 16384 (order: 4, 65536 bytes)
[    0.000000] Initializing CPU#0
[    0.000000] Initializing HighMem for node 0 (00000000:00000000)
[    0.000000] Memory: 196548K/261744K available (17441K kernel code, 2449K=
 rwdata, 5632K rodata, 1112K init, 10664K bss, 65196K reserved, 0K highmem)
[    0.000000] virtual kernel memory layout:
[    0.000000]     fixmap  : 0xffd35000 - 0xfffff000   (2856 kB)
[    0.000000]     pkmap   : 0xff800000 - 0xffc00000   (4096 kB)
[    0.000000]     vmalloc : 0xc07fe000 - 0xff7fe000   (1008 MB)
[    0.000000]     lowmem  : 0xb0000000 - 0xbfffe000   ( 255 MB)
[    0.000000]       .init : 0xb1afa000 - 0xb1c10000   (1112 kB)
[    0.000000]       .data : 0xb13088a6 - 0xb1af9600   (8131 kB)
[    0.000000]       .text : 0xb0200000 - 0xb13088a6   (17442 kB)
[    0.000000] Checking if this processor honours the WP bit even in superv=
isor mode...Ok.
[    0.000000] Hierarchical RCU implementation.
[    0.000000]=20
[    0.000000]=20
[    0.000000]=20
[    0.000000]=20
[    0.000000] NR_IRQS:2304 nr_irqs:512 16
[    0.000000] CPU 0 irqstacks, hard=3Db0090000 soft=3Db0092000
[    0.000000] console [ttyS0] enabled
[    0.000000] Lock dependency validator: Copyright (c) 2006 Red Hat, Inc.,=
 Ingo Molnar
[    0.000000] ... MAX_LOCKDEP_SUBCLASSES:  8
[    0.000000] ... MAX_LOCK_DEPTH:          48
[    0.000000] ... MAX_LOCKDEP_KEYS:        8191
[    0.000000] ... CLASSHASH_SIZE:          4096
[    0.000000] ... MAX_LOCKDEP_ENTRIES:     16384
[    0.000000] ... MAX_LOCKDEP_CHAINS:      32768
[    0.000000] ... CHAINHASH_SIZE:          16384
[    0.000000]  memory used by lock dependency info: 3551 kB
[    0.000000]  per task-struct memory footprint: 1152 bytes
[    0.000000] ODEBUG: 0 of 0 active objects replaced
[    0.000000] hpet clockevent registered
[    0.000000] tsc: Detected 2893.002 MHz processor
[    0.000000] tsc: Marking TSC unstable due to TSCs unsynchronized
[    0.004000] Calibrating delay loop (skipped) preset value.. 5786.00 Bogo=
MIPS (lpj=3D2893002)
[    0.005013] pid_max: default: 32768 minimum: 301
[    0.006127] Security Framework initialized
[    0.006765] SELinux:  Initializing.
[    0.007093] SELinux:  Starting in permissive mode
[    0.008063] Mount-cache hash table entries: 512
[    0.010170] Initializing cgroup subsys debug
[    0.010919] Initializing cgroup subsys net_cls
[    0.011018] Initializing cgroup subsys blkio
[    0.012148] Last level iTLB entries: 4KB 0, 2MB 0, 4MB 0
[    0.012148] Last level dTLB entries: 4KB 0, 2MB 0, 4MB 0
[    0.012148] tlb_flushall_shift: -1
[    0.015927] debug: unmapping init [mem 0xb1c10000-0xb1c17fff]
[    0.022691] ACPI: Core revision 20131218
[    0.030197] ACPI: All ACPI Tables successfully acquired
[    0.032070] Getting VERSION: 50014
[    0.032620] Getting VERSION: 50014
[    0.033021] Getting ID: 0
[    0.033468] Getting ID: f000000
[    0.034026] Getting LVT0: 8700
[    0.034560] Getting LVT1: 8400
[    0.035016] Enabling APIC mode:  Flat.  Using 1 I/O APICs
[    0.036119] enabled ExtINT on CPU#0
[    0.038711] ENABLING IO-APIC IRQs
[    0.039035] init IO_APIC IRQs
[    0.039542]  apic 0 pin 0 not connected
[    0.040048] IOAPIC[0]: Set routing entry (0-1 -> 0x31 -> IRQ 1 Mode:0 Ac=
tive:0 Dest:1)
[    0.042048] IOAPIC[0]: Set routing entry (0-2 -> 0x30 -> IRQ 0 Mode:0 Ac=
tive:0 Dest:1)
[    0.043048] IOAPIC[0]: Set routing entry (0-3 -> 0x33 -> IRQ 3 Mode:0 Ac=
tive:0 Dest:1)
[    0.044044] IOAPIC[0]: Set routing entry (0-4 -> 0x34 -> IRQ 4 Mode:0 Ac=
tive:0 Dest:1)
[    0.045041] IOAPIC[0]: Set routing entry (0-5 -> 0x35 -> IRQ 5 Mode:1 Ac=
tive:0 Dest:1)
[    0.046044] IOAPIC[0]: Set routing entry (0-6 -> 0x36 -> IRQ 6 Mode:0 Ac=
tive:0 Dest:1)
[    0.047044] IOAPIC[0]: Set routing entry (0-7 -> 0x37 -> IRQ 7 Mode:0 Ac=
tive:0 Dest:1)
[    0.048043] IOAPIC[0]: Set routing entry (0-8 -> 0x38 -> IRQ 8 Mode:0 Ac=
tive:0 Dest:1)
[    0.049045] IOAPIC[0]: Set routing entry (0-9 -> 0x39 -> IRQ 9 Mode:1 Ac=
tive:0 Dest:1)
[    0.050052] IOAPIC[0]: Set routing entry (0-10 -> 0x3a -> IRQ 10 Mode:1 =
Active:0 Dest:1)
[    0.051044] IOAPIC[0]: Set routing entry (0-11 -> 0x3b -> IRQ 11 Mode:1 =
Active:0 Dest:1)
[    0.052043] IOAPIC[0]: Set routing entry (0-12 -> 0x3c -> IRQ 12 Mode:0 =
Active:0 Dest:1)
[    0.053045] IOAPIC[0]: Set routing entry (0-13 -> 0x3d -> IRQ 13 Mode:0 =
Active:0 Dest:1)
[    0.054045] IOAPIC[0]: Set routing entry (0-14 -> 0x3e -> IRQ 14 Mode:0 =
Active:0 Dest:1)
[    0.055046] IOAPIC[0]: Set routing entry (0-15 -> 0x3f -> IRQ 15 Mode:0 =
Active:0 Dest:1)
[    0.056036]  apic 0 pin 16 not connected
[    0.056716]  apic 0 pin 17 not connected
[    0.057009]  apic 0 pin 18 not connected
[    0.058008]  apic 0 pin 19 not connected
[    0.058617]  apic 0 pin 20 not connected
[    0.059008]  apic 0 pin 21 not connected
[    0.060009]  apic 0 pin 22 not connected
[    0.060610]  apic 0 pin 23 not connected
[    0.061181] ..TIMER: vector=3D0x30 apic1=3D0 pin1=3D2 apic2=3D-1 pin2=3D=
-1
[    0.062009] smpboot: CPU0: GenuineIntel Common KVM processor (fam: 0f, m=
odel: 06, stepping: 01)
[    0.064373] Using local APIC timer interrupts.
[    0.064373] calibrating APIC timer ...
[    0.066000] ... lapic delta =3D 6249918
[    0.066000] ... PM-Timer delta =3D 357949
[    0.066000] ... PM-Timer result ok
[    0.066000] ..... delta 6249918
[    0.066000] ..... mult: 268431934
[    0.066000] ..... calibration result: 999986
[    0.066000] ..... CPU clock speed is 2892.0952 MHz.
[    0.066000] ..... host bus clock speed is 999.0986 MHz.
[    0.066122] Performance Events: no PMU driver, software events only.
[    0.070562] NMI watchdog: disabled (cpu0): hardware events not enabled
[    0.071493] CPU 1 irqstacks, hard=3Db0074000 soft=3Db0076000
[    0.072009] x86: Booting SMP configuration:
[    0.073009] .... node  #0, CPUs:      #1
[    0.003000] Initializing CPU#1
[    0.004000] kvm-clock: cpu 1, msr 0:fffd041, secondary cpu clock
[    0.004000] masked ExtINT on CPU#1

[    0.087111] x86: Booted up 1 node, 2 CPUs
[    0.087009] KVM setup async PF for cpu 1
[    0.087009] kvm-stealtime: cpu 1, msr e561580
[    0.088010] smpboot: Total of 2 processors activated (11572.00 BogoMIPS)
[    0.091300] devtmpfs: initialized
[    0.092677] gcov: version magic: 0x3430382a
[    0.095460] EVM: security.selinux
[    0.096007] EVM: security.SMACK64
[    0.096522] EVM: security.ima
[    0.097007] EVM: security.capability
[    0.103241] prandom: seed boundary self test passed
[    0.105223] prandom: 100 self tests passed
[    0.105892] atomic64 test passed for i386+ platform with CX8 and with SSE
[    0.107564] regulator-dummy: no parameters
[    0.108399] NET: Registered protocol family 16
[    0.110499] cpuidle: using governor menu
[    0.111603] ACPI: bus type PCI registered
[    0.112433] PCI: PCI BIOS revision 2.10 entry at 0xfc6d5, last bus=3D0
[    0.113008] PCI: Using configuration type 1 for base access
[    0.131157] bio: create slab <bio-0> at 0
[    0.132776] ACPI: Added _OSI(Module Device)
[    0.133009] ACPI: Added _OSI(Processor Device)
[    0.134009] ACPI: Added _OSI(3.0 _SCP Extensions)
[    0.134694] ACPI: Added _OSI(Processor Aggregator Device)
[    0.151750] ACPI: Interpreter enabled
[    0.152020] ACPI Exception: AE_NOT_FOUND, While evaluating Sleep State [=
\_S1_] (20131218/hwxface-580)
[    0.153861] ACPI Exception: AE_NOT_FOUND, While evaluating Sleep State [=
\_S2_] (20131218/hwxface-580)
[    0.155441] ACPI: (supports S0 S3 S5)
[    0.156008] ACPI: Using IOAPIC for interrupt routing
[    0.156859] PCI: Using host bridge windows from ACPI; if necessary, use =
"pci=3Dnocrs" and report a bug
[    0.180514] ACPI: PCI Root Bridge [PCI0] (domain 0000 [bus 00-ff])
[    0.181020] acpi PNP0A03:00: _OSC: OS supports [Segments]
[    0.182066] acpi PNP0A03:00: _OSC failed (AE_NOT_FOUND); disabling ASPM
[    0.184365] acpi PNP0A03:00: fail to add MMCONFIG information, can't acc=
ess extended PCI configuration space under this bridge.
[    0.185156] PCI host bridge to bus 0000:00
[    0.185814] pci_bus 0000:00: root bus resource [bus 00-ff]
[    0.186012] pci_bus 0000:00: root bus resource [io  0x0000-0x0cf7]
[    0.187012] pci_bus 0000:00: root bus resource [io  0x0d00-0xffff]
[    0.188013] pci_bus 0000:00: root bus resource [mem 0x000a0000-0x000bfff=
f]
[    0.189012] pci_bus 0000:00: root bus resource [mem 0x80000000-0xfebffff=
f]
[    0.190132] pci 0000:00:00.0: [8086:1237] type 00 class 0x060000
[    0.192235] pci 0000:00:01.0: [8086:7000] type 00 class 0x060100
[    0.194404] pci 0000:00:01.1: [8086:7010] type 00 class 0x010180
[    0.199475] pci 0000:00:01.1: reg 0x20: [io  0xc1c0-0xc1cf]
[    0.203247] pci 0000:00:01.3: [8086:7113] type 00 class 0x068000
[    0.204594] pci 0000:00:01.3: quirk: [io  0xb000-0xb03f] claimed by PIIX=
4 ACPI
[    0.205028] pci 0000:00:01.3: quirk: [io  0xb100-0xb10f] claimed by PIIX=
4 SMB
[    0.207033] pci 0000:00:02.0: [1013:00b8] type 00 class 0x030000
[    0.210081] pci 0000:00:02.0: reg 0x10: [mem 0xfc000000-0xfdffffff pref]
[    0.213078] pci 0000:00:02.0: reg 0x14: [mem 0xfebf0000-0xfebf0fff]
[    0.224088] pci 0000:00:02.0: reg 0x30: [mem 0xfebe0000-0xfebeffff pref]
[    0.227264] pci 0000:00:03.0: [8086:100e] type 00 class 0x020000
[    0.230013] pci 0000:00:03.0: reg 0x10: [mem 0xfeba0000-0xfebbffff]
[    0.233019] pci 0000:00:03.0: reg 0x14: [io  0xc000-0xc03f]
[    0.242019] pci 0000:00:03.0: reg 0x30: [mem 0xfebc0000-0xfebdffff pref]
[    0.244092] pci 0000:00:04.0: [1af4:1001] type 00 class 0x010000
[    0.246862] pci 0000:00:04.0: reg 0x10: [io  0xc040-0xc07f]
[    0.249015] pci 0000:00:04.0: reg 0x14: [mem 0xfebf1000-0xfebf1fff]
[    0.260096] pci 0000:00:05.0: [1af4:1001] type 00 class 0x010000
[    0.262846] pci 0000:00:05.0: reg 0x10: [io  0xc080-0xc0bf]
[    0.265012] pci 0000:00:05.0: reg 0x14: [mem 0xfebf2000-0xfebf2fff]
[    0.275822] pci 0000:00:06.0: [1af4:1001] type 00 class 0x010000
[    0.278015] pci 0000:00:06.0: reg 0x10: [io  0xc0c0-0xc0ff]
[    0.281011] pci 0000:00:06.0: reg 0x14: [mem 0xfebf3000-0xfebf3fff]
[    0.291872] pci 0000:00:07.0: [1af4:1001] type 00 class 0x010000
[    0.294012] pci 0000:00:07.0: reg 0x10: [io  0xc100-0xc13f]
[    0.297013] pci 0000:00:07.0: reg 0x14: [mem 0xfebf4000-0xfebf4fff]
[    0.307651] pci 0000:00:08.0: [1af4:1001] type 00 class 0x010000
[    0.310016] pci 0000:00:08.0: reg 0x10: [io  0xc140-0xc17f]
[    0.313014] pci 0000:00:08.0: reg 0x14: [mem 0xfebf5000-0xfebf5fff]
[    0.323695] pci 0000:00:09.0: [1af4:1001] type 00 class 0x010000
[    0.326013] pci 0000:00:09.0: reg 0x10: [io  0xc180-0xc1bf]
[    0.329012] pci 0000:00:09.0: reg 0x14: [mem 0xfebf6000-0xfebf6fff]
[    0.339518] pci 0000:00:0a.0: [8086:25ab] type 00 class 0x088000
[    0.341459] pci 0000:00:0a.0: reg 0x10: [mem 0xfebf7000-0xfebf700f]
[    0.348673] pci_bus 0000:00: on NUMA node 0
[    0.351173] ACPI: PCI Interrupt Link [LNKA] (IRQs 5 *10 11)
[    0.352644] ACPI: PCI Interrupt Link [LNKB] (IRQs 5 *10 11)
[    0.354283] ACPI: PCI Interrupt Link [LNKC] (IRQs 5 10 *11)
[    0.355772] ACPI: PCI Interrupt Link [LNKD] (IRQs 5 10 *11)
[    0.357119] ACPI: PCI Interrupt Link [LNKS] (IRQs *9)
[    0.359860] ACPI: Enabled 16 GPEs in block 00 to 0F
[    0.362911] vgaarb: device added: PCI:0000:00:02.0,decodes=3Dio+mem,owns=
=3Dio+mem,locks=3Dnone
[    0.363016] vgaarb: loaded
[    0.363481] vgaarb: bridge control possible 0000:00:02.0
[    0.366296] SCSI subsystem initialized
[    0.367265] pps_core: LinuxPPS API ver. 1 registered
[    0.368008] pps_core: Software ver. 5.3.6 - Copyright 2005-2007 Rodolfo =
Giometti <giometti@linux.it>
[    0.369175] PTP clock support registered
[    0.371917] Advanced Linux Sound Architecture Driver Initialized.
[    0.372018] PCI: Using ACPI for IRQ routing
[    0.373018] PCI: pci_cache_line_size set to 64 bytes
[    0.374388] e820: reserve RAM buffer [mem 0x0009fc00-0x0009ffff]
[    0.375022] e820: reserve RAM buffer [mem 0x0fffe000-0x0fffffff]
[    0.378029] irda_init()
[    0.378633] NET: Registered protocol family 23
[    0.379156] Bluetooth: Core ver 2.17
[    0.380136] NET: Registered protocol family 31
[    0.380791] Bluetooth: HCI device and connection manager initialized
[    0.381063] Bluetooth: HCI socket layer initialized
[    0.382033] Bluetooth: L2CAP socket layer initialized
[    0.383058] Bluetooth: SCO socket layer initialized
[    0.384055] NET: Registered protocol family 8
[    0.385014] NET: Registered protocol family 20
[    0.386101] NetLabel: Initializing
[    0.386687] NetLabel:  domain hash size =3D 128
[    0.387007] NetLabel:  protocols =3D UNLABELED CIPSOv4
[    0.388211] NetLabel:  unlabeled traffic allowed by default
[    0.390512] Switched to clocksource kvm-clock
[    0.547547] FS-Cache: Loaded
[    0.548184] pnp: PnP ACPI init
[    0.548944] ACPI: bus type PNP registered
[    0.549800] IOAPIC[0]: Set routing entry (0-8 -> 0x38 -> IRQ 8 Mode:0 Ac=
tive:0 Dest:3)
[    0.551194] pnp 00:00: Plug and Play ACPI device, IDs PNP0b00 (active)
[    0.552320] IOAPIC[0]: Set routing entry (0-1 -> 0x31 -> IRQ 1 Mode:0 Ac=
tive:0 Dest:3)
[    0.553698] pnp 00:01: Plug and Play ACPI device, IDs PNP0303 (active)
[    0.554760] IOAPIC[0]: Set routing entry (0-12 -> 0x3c -> IRQ 12 Mode:0 =
Active:0 Dest:3)
[    0.556135] pnp 00:02: Plug and Play ACPI device, IDs PNP0f13 (active)
[    0.557579] IOAPIC[0]: Set routing entry (0-6 -> 0x36 -> IRQ 6 Mode:0 Ac=
tive:0 Dest:3)
[    0.558876] pnp 00:03: [dma 2]
[    0.559681] pnp 00:03: Plug and Play ACPI device, IDs PNP0700 (active)
[    0.560884] IOAPIC[0]: Set routing entry (0-7 -> 0x37 -> IRQ 7 Mode:0 Ac=
tive:0 Dest:3)
[    0.562237] pnp 00:04: Plug and Play ACPI device, IDs PNP0400 (active)
[    0.563431] IOAPIC[0]: Set routing entry (0-4 -> 0x34 -> IRQ 4 Mode:0 Ac=
tive:0 Dest:3)
[    0.564779] pnp 00:05: Plug and Play ACPI device, IDs PNP0501 (active)
[    0.567166] pnp 00:06: Plug and Play ACPI device, IDs PNP0103 (active)
[    0.569289] pnp: PnP ACPI: found 7 devices
[    0.569955] ACPI: bus type PNP unregistered
[    0.607959] pci_bus 0000:00: resource 4 [io  0x0000-0x0cf7]
[    0.608870] pci_bus 0000:00: resource 5 [io  0x0d00-0xffff]
[    0.609759] pci_bus 0000:00: resource 6 [mem 0x000a0000-0x000bffff]
[    0.610801] pci_bus 0000:00: resource 7 [mem 0x80000000-0xfebfffff]
[    0.611874] NET: Registered protocol family 2
[    0.613454] TCP established hash table entries: 2048 (order: 1, 8192 byt=
es)
[    0.614654] TCP bind hash table entries: 2048 (order: 4, 73728 bytes)
[    0.615895] TCP: Hash tables configured (established 2048 bind 2048)
[    0.617071] TCP: reno registered
[    0.617637] UDP hash table entries: 256 (order: 2, 20480 bytes)
[    0.618622] UDP-Lite hash table entries: 256 (order: 2, 20480 bytes)
[    0.620763] NET: Registered protocol family 1
[    0.621525] pci 0000:00:00.0: Limiting direct PCI/PCI transfers
[    0.622480] pci 0000:00:01.0: PIIX3: Enabling Passive Release
[    0.623404] pci 0000:00:01.0: Activating ISA DMA hang workarounds
[    0.624457] pci 0000:00:02.0: Boot video device
[    0.625306] PCI: CLS 0 bytes, default 64
[    0.626599] Unpacking initramfs...
[    2.636821] debug: unmapping init [mem 0xbe7ab000-0xbffeffff]
[    2.639837] apm: BIOS not found.
[    2.640375] Scanning for low memory corruption every 60 seconds
[    2.642260] PCLMULQDQ-NI instructions are not detected.
[    2.643148] The force parameter has not been set to 1. The Iris poweroff=
 handler will not be installed.
[    2.645845] audit: initializing netlink socket (disabled)
[    2.646859] type=3D2000 audit(1389284971.268:1): initialized
[    3.852517] VFS: Disk quotas dquot_6.5.2
[    3.853287] Dquot-cache hash table entries: 1024 (order 0, 4096 bytes)
[    3.855687] NTFS driver 2.1.30 [Flags: R/O].
[    3.857513] fuse init (API version 7.22)
[    3.859582] JFS: nTxBlock =3D 1535, nTxLock =3D 12284
[    3.863780] SGI XFS with ACLs, security attributes, large block/inode nu=
mbers, debug enabled
[    3.869686] GFS2 installed
[    3.870226] msgmni has been set to 383
[    3.870903] SELinux:  Registering netfilter hooks
[    3.900674] alg: No test for lz4hc (lz4hc-generic)
[    3.901769] alg: No test for stdrng (krng)
[    3.902488] NET: Registered protocol family 38
[    3.903278] Key type asymmetric registered
[    3.903988] Asymmetric key parser 'x509' registered
[    3.904943] Block layer SCSI generic (bsg) driver version 0.4 loaded (ma=
jor 252)
[    3.906135] io scheduler noop registered
[    3.906777] io scheduler deadline registered
[    3.907508] io scheduler cfq registered (default)
[    3.912525] test_string_helpers: Running tests...
[    3.914113] crc32: CRC_LE_BITS =3D 64, CRC_BE BITS =3D 64
[    3.914940] crc32: self tests passed, processed 225944 bytes in 263574 n=
sec
[    3.916306] crc32c: CRC_LE_BITS =3D 64
[    3.916910] crc32c: self tests passed, processed 225944 bytes in 122765 =
nsec
[    4.258476] crc32_combine: 8373 self tests passed
[    4.599252] crc32c_combine: 8373 self tests passed
[    4.602769] ipmi message handler version 39.2
[    4.604789] IPMI System Interface driver.
[    4.605651] ipmi_si: Adding default-specified kcs state machine
[    4.606570] ipmi_si: Trying default-specified kcs state machine at i/o a=
ddress 0xca2, slave address 0x0, irq 0
[    4.608065] ipmi_si: Interface detection failed
[    4.610560] ipmi_si: Adding default-specified smic state machine
[    4.611588] ipmi_si: Trying default-specified smic state machine at i/o =
address 0xca9, slave address 0x0, irq 0
[    4.613187] ipmi_si: Interface detection failed
[    4.615530] ipmi_si: Adding default-specified bt state machine
[    4.616468] ipmi_si: Trying default-specified bt state machine at i/o ad=
dress 0xe4, slave address 0x0, irq 0
[    4.617968] ipmi_si: Interface detection failed
[    4.620783] ipmi_si: Unable to find any System Interface(s)
[    4.621702] IPMI Watchdog: driver initialized
[    4.622747] input: Power Button as /devices/LNXSYSTM:00/LNXPWRBN:00/inpu=
t/input0
[    4.623916] ACPI: Power Button [PWRF]
[    4.771661] r3964: Philips r3964 Driver $Revision: 1.10 $
[    4.772363] Serial: 8250/16550 driver, 4 ports, IRQ sharing disabled
[    4.797480] 00:05: ttyS0 at I/O 0x3f8 (irq =3D 4, base_baud =3D 115200) =
is a 16550A
[    4.804120] serial: Freescale lpuart driver
[    4.806883] lp: driver loaded but no devices found
[    4.809267] Non-volatile memory driver v1.3
[    4.809858] toshiba: not a supported Toshiba laptop
[    4.810748] ppdev: user-space parallel port driver
[    4.811670] platform pc8736x_gpio.0: NatSemi pc8736x GPIO Driver Initial=
izing
[    4.812860] platform pc8736x_gpio.0: no device found
[    4.813858] nsc_gpio initializing
[    4.814468] telclk_interrupt =3D 0xf non-mcpbl0010 hw.
[    4.815362] smapi::smapi_init, ERROR invalid usSmapiID
[    4.816187] mwave: tp3780i::tp3780I_InitializeBoardData: Error: SMAPI is=
 not available on this machine
[    4.817652] mwave: mwavedd::mwave_init: Error: Failed to initialize boar=
d data
[    4.818787] mwave: mwavedd::mwave_init: Error: Failed to initialize
[    4.819936] SyncLink PC Card driver $Revision: 4.34 $, tty major#248
[    4.820970] Hangcheck: starting hangcheck timer 0.9.1 (tick is 180 secon=
ds, margin is 60 seconds).
[    4.822425] Hangcheck: Using getrawmonotonic().
[    4.824736] [drm] Initialized drm 1.1.0 20060810
[    4.826637] parport_pc 00:04: reported by Plug and Play ACPI
[    4.827812] parport0: PC-style at 0x378, irq 7 [PCSPP,TRISTATE]
[    4.920917] lp0: using parport0 (interrupt-driven).
[    4.921701] lp0: console ready
[    4.927691] dummy-irq: no IRQ given.  Use irq=3DN
[    4.930059] Silicon Labs C2 port support v. 0.51.0 - (C) 2007 Rodolfo Gi=
ometti
[    4.931523] c2port c2port0: C2 port uc added
[    4.932195] c2port c2port0: uc flash has 30 blocks x 512 bytes (15360 by=
tes total)
[    4.937692] rdac: device handler registered
[    4.940145] hp_sw: device handler registered
[    4.940863] emc: device handler registered
[    4.941519] alua: device handler registered
[    4.942183] osst :I: Tape driver with OnStream support version 0.99.4
[    4.942183] osst :I: $Id: osst.c,v 1.73 2005/01/01 21:13:34 wriede Exp $
[    4.948166] Rounding down aligned max_sectors from 4294967295 to 4294967=
288
[    4.951711] SSFDC read-only Flash Translation layer
[    4.952522] mtdoops: mtd device (mtddev=3Dname/number) must be supplied
[    4.953587] L440GX flash mapping: failed to find PIIX4 ISA bridge, canno=
t continue
[    4.956314] SBC-GXx flash: IO:0x258-0x259 MEM:0xdc000-0xdffff
[    4.957217] Failed to ioremap_nocache
[    4.957828] slram: not enough parameters.
[    4.958615] HSI/SSI char device loaded
[    4.959217] slcan: serial line CAN interface driver
[    4.959979] slcan: 10 dynamic interface channels.
[    4.960738] CAN device driver interface
[    4.961336] sja1000 CAN netdevice driver
[    4.961947] sja1000_isa: insufficient parameters supplied
[    4.962896] cc770: CAN netdevice driver
[    4.965193] w83977af_init()
[    4.965671] w83977af_open()
[    4.966135] w83977af_probe()
[    4.966702] w83977af_probe(), Wrong chip version
[    4.967410] w83977af_probe()
[    4.967998] w83977af_probe(), Wrong chip version
[    4.970722] irda_register_dongle : registering dongle "JetEye PC ESI-968=
0 PC" (1).
[    4.972030] irda_register_dongle : registering dongle "Old Belkin SmartB=
eam" (7).
[    4.973182] irda_register_dongle : registering dongle "Microchip MCP2120=
" (9).
[    4.974325] irda_register_dongle : registering dongle "MA600" (11).
[    4.975472] i8042: PNP: PS/2 Controller [PNP0303:KBD,PNP0f13:MOU] at 0x6=
0,0x64 irq 1,12
[    4.978011] serio: i8042 KBD port at 0x60,0x64 irq 1
[    4.978861] serio: i8042 AUX port at 0x60,0x64 irq 12
[    4.983846] mousedev: PS/2 mouse device common for all mice
[    4.985760] input: AT Translated Set 2 keyboard as /devices/platform/i80=
42/serio0/input/input1
[    4.990634] i2c /dev entries driver
[    4.993030] i2c-parport-light: adapter type unspecified
[    4.997365] pps pps0: new PPS source ktimer
[    4.998013] pps pps0: ktimer PPS source registered
[    4.998903] Driver for 1-wire Dallas network protocol.
[    5.001671] 1-Wire driver for the DS2760 battery monitor  chip  - (c) 20=
04-2005, Szabolcs Gyurko
[    5.003311] power_supply test_ac: uevent
[    5.003950] power_supply test_ac: POWER_SUPPLY_NAME=3Dtest_ac
[    5.004866] power_supply test_ac: prop ONLINE=3D1
[    5.005725] power_supply test_ac: power_supply_changed
[    5.008575] power_supply test_ac: power_supply_changed_work
[    5.009471] power_supply test_ac: power_supply_update_gen_leds 1
[    5.010448] power_supply test_ac: uevent
[    5.011044] power_supply test_ac: POWER_SUPPLY_NAME=3Dtest_ac
[    5.011912] power_supply test_ac: prop ONLINE=3D1
[    5.012684] power_supply test_battery: uevent
[    5.013307] power_supply test_battery: POWER_SUPPLY_NAME=3Dtest_battery
[    5.014235] power_supply test_battery: prop STATUS=3DDischarging
[    5.015078] power_supply test_battery: prop CHARGE_TYPE=3DFast
[    5.015889] power_supply test_battery: prop HEALTH=3DGood
[    5.016644] power_supply test_battery: prop PRESENT=3D1
[    5.017367] power_supply test_battery: prop TECHNOLOGY=3DLi-ion
[    5.018149] power_supply test_battery: prop CHARGE_FULL_DESIGN=3D100
[    5.019016] power_supply test_battery: prop CHARGE_FULL=3D100
[    5.019831] power_supply test_battery: prop CHARGE_NOW=3D50
[    5.020604] power_supply test_battery: prop CAPACITY=3D50
[    5.021360] power_supply test_battery: prop CAPACITY_LEVEL=3DNormal
[    5.022208] power_supply test_battery: prop TIME_TO_EMPTY_AVG=3D3600
[    5.023084] power_supply test_battery: prop TIME_TO_FULL_NOW=3D3600
[    5.023943] power_supply test_battery: prop MODEL_NAME=3DTest battery
[    5.024832] power_supply test_battery: prop MANUFACTURER=3DLinux
[    5.025658] power_supply test_battery: prop SERIAL_NUMBER=3D3.13.0-rc7-0=
0264-gc11a763
[    5.026734] power_supply test_battery: prop TEMP=3D26
[    5.027436] power_supply test_battery: prop VOLTAGE_NOW=3D3300
[    5.029928] power_supply test_battery: power_supply_changed
[    5.030791] power_supply test_battery: power_supply_changed_work
[    5.031644] power_supply test_battery: power_supply_update_bat_leds 2
[    5.032553] power_supply test_battery: uevent
[    5.033158] power_supply test_battery: POWER_SUPPLY_NAME=3Dtest_battery
[    5.034077] power_supply test_battery: prop STATUS=3DDischarging
[    5.034896] power_supply test_battery: prop CHARGE_TYPE=3DFast
[    5.035693] power_supply test_battery: prop HEALTH=3DGood
[    5.036439] power_supply test_battery: prop PRESENT=3D1
[    5.037138] power_supply test_battery: prop TECHNOLOGY=3DLi-ion
[    5.037942] power_supply test_battery: prop CHARGE_FULL_DESIGN=3D100
[    5.038819] power_supply test_battery: prop CHARGE_FULL=3D100
[    5.039624] power_supply test_battery: prop CHARGE_NOW=3D50
[    5.040391] power_supply test_battery: prop CAPACITY=3D50
[    5.041119] power_supply test_battery: prop CAPACITY_LEVEL=3DNormal
[    5.041971] power_supply test_battery: prop TIME_TO_EMPTY_AVG=3D3600
[    5.042848] power_supply test_battery: prop TIME_TO_FULL_NOW=3D3600
[    5.043712] power_supply test_battery: prop MODEL_NAME=3DTest battery
[    5.044605] power_supply test_battery: prop MANUFACTURER=3DLinux
[    5.045443] power_supply test_battery: prop SERIAL_NUMBER=3D3.13.0-rc7-0=
0264-gc11a763
[    5.046510] power_supply test_battery: prop TEMP=3D26
[    5.047198] power_supply test_battery: prop VOLTAGE_NOW=3D3300
[    5.048119] power_supply test_usb: uevent
[    5.048692] power_supply test_usb: POWER_SUPPLY_NAME=3Dtest_usb
[    5.049529] power_supply test_usb: prop ONLINE=3D1
[    5.050197] power_supply test_usb: power_supply_changed
[    5.061100] power_supply test_usb: power_supply_changed_work
[    5.061924] power_supply test_usb: power_supply_update_gen_leds 1
[    5.062785] power_supply test_usb: uevent
[    5.063353] power_supply test_usb: POWER_SUPPLY_NAME=3Dtest_usb
[    5.064158] power_supply test_usb: prop ONLINE=3D1
[    5.065178] pc87360: PC8736x not detected, module not inserted
[    5.068019] md: raid0 personality registered for level 0
[    5.068811] md: raid1 personality registered for level 1
[    5.069592] md: raid10 personality registered for level 10
[    5.070376] Bluetooth: Virtual HCI driver ver 1.4
[    5.072729] Bluetooth: HCI UART driver ver 2.2
[    5.075005] sdhci: Secure Digital Host Controller Interface driver
[    5.075907] sdhci: Copyright(c) Pierre Ossman
[    5.076532] wbsd: Winbond W83L51xD SD/MMC card interface driver
[    5.077361] wbsd: Copyright(c) Pierre Ossman
[    5.078001] sdhci-pltfm: SDHCI platform and OF driver helper
[    5.082491] ledtrig-cpu: registered to indicate activity on CPUs
[    5.083616] dcdbas dcdbas: Dell Systems Management Base Driver (version =
5.6.0-3.2)
[    5.086296] logger: created 256K log 'log_main'
[    5.087268] logger: created 256K log 'log_events'
[    5.089199] logger: created 256K log 'log_radio'
[    5.090174] logger: created 256K log 'log_system'
[    5.092704] dgap: dgap-1.3-16, Digi International Part Number 40002347_C
[    5.093701] dgap: For the tools package or updated drivers please visit =
http://www.digi.com
[    5.096997] goldfish_pdev_bus goldfish_pdev_bus: unable to reserve Goldf=
ish MMIO.
[    5.098092] goldfish_pdev_bus: probe of goldfish_pdev_bus failed with er=
ror -16
[    5.105341] pktgen: Packet Generator for packet performance testing. Ver=
sion: 2.74
[    5.107061] drop_monitor: Initializing network drop monitor service
[    5.109562] u32 classifier
[    5.109975]     input device check on
[    5.110604] Netfilter messages via NETLINK v0.30.
[    5.111296] nfnl_acct: registering with nfnetlink.
[    5.113343] nf_conntrack version 0.5.0 (3071 buckets, 12284 max)
[    5.114473] ctnetlink v0.93: registering with nfnetlink.
[    5.115459] nf_tables: (c) 2007-2009 Patrick McHardy <kaber@trash.net>
[    5.116396] nf_tables_compat: (c) 2012 Pablo Neira Ayuso <pablo@netfilte=
r.org>
[    5.117828] xt_time: kernel timezone is -0000
[    5.118513] ip_set: protocol 6
[    5.119020] IPVS: Registered protocols (UDP, SCTP)
[    5.119781] IPVS: Connection hash table configured (size=3D4096, memory=
=3D32Kbytes)
[    5.122201] IPVS: Creating netns size=3D1204 id=3D0
[    5.123043] IPVS: ipvs loaded.
[    5.123576] IPVS: [rr] scheduler registered.
[    5.124175] IPVS: [wrr] scheduler registered.
[    5.124791] IPVS: [lc] scheduler registered.
[    5.125403] IPVS: [wlc] scheduler registered.
[    5.126001] IPVS: [lblcr] scheduler registered.
[    5.126656] IPVS: [dh] scheduler registered.
[    5.127256] IPVS: [sh] scheduler registered.
[    5.127872] IPVS: [sed] scheduler registered.
[    5.128499] IPVS: [nq] scheduler registered.
[    5.129110] IPVS: [sip] pe registered.
[    5.129588] ipip: IPv4 over IPv4 tunneling driver
[    5.132918] ip_tables: (C) 2000-2006 Netfilter Core Team
[    5.133922] arp_tables: (C) 2002 David S. Miller
[    5.134673] TCP: bic registered
[    5.135066] TCP: cubic registered
[    5.135503] TCP: highspeed registered
[    5.135951] TCP: htcp registered
[    5.136364] TCP: vegas registered
[    5.136769] TCP: lp registered
[    5.137150] TCP: yeah registered
[    5.137574] Initializing XFRM netlink socket
[    5.138330] NET: Registered protocol family 10
[    5.142996] mip6: Mobile IPv6
[    5.143479] ip6_tables: (C) 2000-2006 Netfilter Core Team
[    5.146779] INFO: trying to register non-static key.
[    5.147439] the code is fine but needs lockdep annotation.
[    5.147711] turning off the locking correctness validator.
[    5.147711] CPU: 1 PID: 1 Comm: swapper/0 Not tainted 3.13.0-rc7-00264-g=
c11a763 #1
[    5.147711] Hardware name: Bochs Bochs, BIOS Bochs 01/01/2011
[    5.147711]  be55ec1c b001fc34 b12f4e53 00000000 b001fc78 b02b9604 b175f=
b0c 00000000
[    5.147711]  b0010838 b0010440 00000001 b001fc94 b1d96828 00000000 00000=
003 00000000
[    5.147711]  be55ec1c b0010440 be55ebf8 00000046 00000000 b001fcac b02ba=
daf 00000002
[    5.147711] Call Trace:
[    5.147711]  [<b12f4e53>] dump_stack+0xb8/0x108
[    5.147711]  [<b02b9604>] __lock_acquire.isra.19+0x3a4/0x1a00
[    5.147711]  [<b02badaf>] lock_acquire+0x14f/0x1d0
[    5.147711]  [<b0e758f1>] ? dev_get_stats+0x81/0x150
[    5.147711]  [<b1017d62>] ip_tunnel_get_stats64+0xc2/0x350
[    5.147711]  [<b0e758f1>] ? dev_get_stats+0x81/0x150
[    5.147711]  [<b08b9966>] ? __nla_reserve+0x56/0x60
[    5.147711]  [<b0e758f1>] dev_get_stats+0x81/0x150
[    5.147711]  [<b0e89539>] rtnl_fill_ifinfo+0x819/0x1130
[    5.147711]  [<b0e8e27f>] rtmsg_ifinfo+0x9f/0x190
[    5.147711]  [<b0e77d27>] register_netdevice+0x927/0xa80
[    5.147711]  [<b10dd6cd>] ? ip6_tnl_get_cap+0x3d/0x140
[    5.147711]  [<b0e77eae>] register_netdev+0x2e/0x60
[    5.147711]  [<b1ba3fe5>] vti6_init_net+0x32d/0x3a8
[    5.147711]  [<b1ba3e15>] ? vti6_init_net+0x15d/0x3a8
[    5.147711]  [<b0e65402>] ops_init+0x1d2/0x250
[    5.147711]  [<b0e65540>] register_pernet_operations.isra.5+0xc0/0x130
[    5.147711]  [<b0e657d6>] register_pernet_device+0x36/0xa0
[    5.147711]  [<b1ba4060>] ? vti6_init_net+0x3a8/0x3a8
[    5.147711]  [<b1ba407f>] vti6_tunnel_init+0x1f/0xfa
[    5.147711]  [<b1ba3c72>] ? synproxy_tg6_init+0x4d/0x93
[    5.147711]  [<b1afb634>] do_one_initcall+0xf6/0x222
[    5.147711]  [<b0284cf1>] ? parameq+0x21/0xf0
[    5.147711]  [<b1afa738>] ? repair_env_string+0x32/0xd3
[    5.147711]  [<b02851b2>] ? parse_args+0x3f2/0x5d0
[    5.147711]  [<b1afbb64>] kernel_init_freeable+0x404/0x59a
[    5.147711]  [<b1afa706>] ? do_early_param+0x12b/0x12b
[    5.147711]  [<b12e4cf9>] kernel_init+0x19/0x230
[    5.147711]  [<b13078bb>] ret_from_kernel_thread+0x1b/0x30
[    5.147711]  [<b12e4ce0>] ? rest_init+0x170/0x170
[    5.174185] sit: IPv6 over IPv4 tunneling driver
[    5.178596] ip6_gre: GRE over IPv6 tunneling driver
[    5.181035] NET: Registered protocol family 17
[    5.181816] NET: Registered protocol family 15
[    5.182586] Ebtables v2.0 registered
[    5.183247] NET: Registered protocol family 4
[    5.184030] NET: Registered protocol family 9
[    5.184684] X.25 for Linux Version 0.2
[    5.185264] can: controller area network core (rev 20120528 abi 9)
[    5.187593] NET: Registered protocol family 29
[    5.188283] can: broadcast manager protocol (rev 20120528 t)
[    5.189133] can: netlink gateway (rev 20130117) max_hops=3D1
[    5.192147] IrCOMM protocol (Dag Brattli)
[    5.208181] Bluetooth: RFCOMM socket layer initialized
[    5.210472] Bluetooth: RFCOMM ver 1.11
[    5.211186] NET: Registered protocol family 33
[    5.211906] Key type rxrpc registered
[    5.212483] Key type rxrpc_s registered
[    5.213839] DCCP: Activated CCID 2 (TCP-like)
[    5.215142] sctp: Hash tables configured (established 1638 bind 1820)
[    5.216614] tipc: Activated (version 2.0.0)
[    5.217967] NET: Registered protocol family 30
[    5.219019] tipc: Started in single node mode
[    5.219724] NET: Registered protocol family 36
[    5.220440] Key type dns_resolver registered
[    5.221105] Key type ceph registered
[    5.221779] libceph: loaded (mon/osd proto 15/24)
[    5.224424] batman_adv: B.A.T.M.A.N. advanced 2013.5.0 (compatibility ve=
rsion 15) loaded
[    5.225645] openvswitch: Open vSwitch switching datapath
[    5.227194]=20
[    5.227194] printing PIC contents
[    5.227918] ... PIC  IMR: ffff
[    5.228376] ... PIC  IRR: 1013
[    5.228852] ... PIC  ISR: 0000
[    5.229868] ... PIC ELCR: 0c00
[    5.230419] printing local APIC contents on CPU#0/0:
[    5.230419] ... APIC ID:      00000000 (0)
[    5.230419] ... APIC VERSION: 00050014
[    5.230419] ... APIC TASKPRI: 00000000 (00)
[    5.230419] ... APIC PROCPRI: 00000000
[    5.230419] ... APIC LDR: 01000000
[    5.230419] ... APIC DFR: ffffffff
[    5.230419] ... APIC SPIV: 000001ff
[    5.230419] ... APIC ISR field:
[    5.230419] 000000000000000000000000000000000000000000000000000000000000=
0000
[    5.230419] ... APIC TMR field:
[    5.230419] 000000000200000000000000000000000000000000000000000000000000=
0000
[    5.230419] ... APIC IRR field:
[    5.230419] 000000000000000000000000000000000000000000000000000000000000=
8000
[    5.230419] ... APIC ESR: 00000000
[    5.230419] ... APIC ICR: 000008fd
[    5.230419] ... APIC ICR2: 02000000
[    5.230419] ... APIC LVTT: 000200ef
[    5.230419] ... APIC LVTPC: 00010000
[    5.230419] ... APIC LVT0: 00010700
[    5.230419] ... APIC LVT1: 00000400
[    5.230419] ... APIC LVTERR: 000000fe
[    5.230419] ... APIC TMICT: 0000f423
[    5.230419] ... APIC TMCCT: 00004e32
[    5.230419] ... APIC TDCR: 00000003
[    5.230419]=20
[    5.247500] number of MP IRQ sources: 15.
[    5.248129] number of IO-APIC #0 registers: 24.
[    5.248868] testing the IO APIC.......................
[    5.249684] IO APIC #0......
[    5.250114] .... register #00: 00000000
[    5.250675] .......    : physical APIC id: 00
[    5.251301] .......    : Delivery Type: 0
[    5.251936] .......    : LTS          : 0
[    5.252553] .... register #01: 00170011
[    5.253135] .......     : max redirection entries: 17
[    5.253865] .......     : PRQ implemented: 0
[    5.254562] .......     : IO APIC version: 11
[    5.255212] .... register #02: 00000000
[    5.255823] .......     : arbitration: 00
[    5.256435] .... IRQ redirection table:
[    5.257000] 1    0    0   0   0    0    0    00
[    5.257684] 0    0    0   0   0    1    1    31
[    5.258382] 0    0    0   0   0    1    1    30
[    5.259062] 0    0    0   0   0    1    1    33
[    5.259805] 1    0    0   0   0    1    1    34
[    5.260530] 1    1    0   0   0    1    1    35
[    5.261216] 0    0    0   0   0    1    1    36
[    5.261890] 0    0    0   0   0    1    1    37
[    5.262574] 0    0    0   0   0    1    1    38
[    5.263231] 0    1    0   0   0    1    1    39
[    5.263924] 1    1    0   0   0    1    1    3A
[    5.264645] 1    1    0   0   0    1    1    3B
[    5.265358] 0    0    0   0   0    1    1    3C
[    5.266048] 0    0    0   0   0    1    1    3D
[    5.266766] 0    0    0   0   0    1    1    3E
[    5.267483] 0    0    0   0   0    1    1    3F
[    5.268144] 1    0    0   0   0    0    0    00
[    5.268814] 1    0    0   0   0    0    0    00
[    5.269512] 1    0    0   0   0    0    0    00
[    5.270173] 1    0    0   0   0    0    0    00
[    5.270834] 1    0    0   0   0    0    0    00
[    5.271547] 1    0    0   0   0    0    0    00
[    5.272262] 1    0    0   0   0    0    0    00
[    5.272967] 1    0    0   0   0    0    0    00
[    5.273670] IRQ to pin mappings:
[    5.274150] IRQ0 -> 0:2
[    5.274570] IRQ1 -> 0:1
[    5.274964] IRQ3 -> 0:3
[    5.275388] IRQ4 -> 0:4
[    5.275789] IRQ5 -> 0:5
[    5.276177] IRQ6 -> 0:6
[    5.276593] IRQ7 -> 0:7
[    5.276992] IRQ8 -> 0:8
[    5.277434] IRQ9 -> 0:9
[    5.277868] IRQ10 -> 0:10
[    5.278330] IRQ11 -> 0:11
[    5.278796] IRQ12 -> 0:12
[    5.279261] IRQ13 -> 0:13
[    5.279692] IRQ14 -> 0:14
[    5.280114] IRQ15 -> 0:15
[    5.280541] .................................... done.
[    5.281335] Using IPI No-Shortcut mode
[    5.283620] registered taskstats version 1
[    5.285514] Key type trusted registered
[    5.286926] Key type encrypted registered
[    5.288098] IMA: No TPM chip found, activating TPM-bypass!
[    5.294077] BIOS EDD facility v0.16 2004-Jun-25, 0 devices found
[    5.295047] EDD information not available.
[    5.295761] ALSA device list:
[    5.296235]   No soundcards found.
[    5.297812] debug: unmapping init [mem 0xb1afa000-0xb1c0ffff]
[    5.325694] random: init urandom read with 4 bits of entropy available
mountall: ply-event-loop.c:497: ply_event_loop_new: Assertion `loop->epoll_=
fd >=3D 0' failed.
General error mounting filesystems.
A maintenance shell will now be started.
CONTROL-D will terminate this shell and reboot the system.
wfg: rebooting
[    5.490744] Unregister pv shared memory for cpu 1
[    5.491429] Unregister pv shared memory for cpu 0
[    5.625813] input: ImExPS/2 Generic Explorer Mouse as /devices/platform/=
i8042/serio1/input/input3
[    5.628283] reboot: Restarting system
[    5.628888] reboot: machine restart
Elapsed time: 10
qemu-system-x86_64 -cpu kvm64 -enable-kvm -kernel /kernel/i386-randconfig-x=
4-01100001/c11a763d03cd080104cfb045b2edfebcb2c6f8ef/vmlinuz-3.13.0-rc7-0026=
4-gc11a763 -append 'hung_task_panic=3D1 earlyprintk=3DttyS0,115200 debug ap=
ic=3Ddebug sysrq_always_enabled panic=3D10  prompt_ramdisk=3D0 console=3Dtt=
yS0,115200 console=3Dtty0 vga=3Dnormal  root=3D/dev/ram0 rw link=3D/kernel-=
tests/run-queue/kvm/i386-randconfig-x4-01100001/linux-devel:devel-hourly-20=
14010921/.vmlinuz-c11a763d03cd080104cfb045b2edfebcb2c6f8ef-20140110002917-8=
-xian branch=3Dlinux-devel/devel-hourly-2014010921 BOOT_IMAGE=3D/kernel/i38=
6-randconfig-x4-01100001/c11a763d03cd080104cfb045b2edfebcb2c6f8ef/vmlinuz-3=
=2E13.0-rc7-00264-gc11a763'  -initrd /kernel-tests/initrd/quantal-core-i386=
=2Ecgz -m 256M -smp 2 -net nic,vlan=3D1,model=3De1000 -net user,vlan=3D1,ho=
stfwd=3Dtcp::13482-:22 -boot order=3Dnc -no-reboot -watchdog i6300esb -rtc =
base=3Dlocaltime -drive file=3D/fs/LABEL=3DKVM/disk0-quantal-xian-26,media=
=3Ddisk,if=3Dvirtio -drive file=3D/fs/LABEL=3DKVM/disk1-quantal-xian-26,med=
ia=3Ddisk,if=3Dvirtio -drive file=3D/fs/LABEL=3DKVM/disk2-quantal-xian-26,m=
edia=3Ddisk,if=3Dvirtio -drive file=3D/fs/LABEL=3DKVM/disk3-quantal-xian-26=
,media=3Ddisk,if=3Dvirtio -drive file=3D/fs/LABEL=3DKVM/disk4-quantal-xian-=
26,media=3Ddisk,if=3Dvirtio -drive file=3D/fs/LABEL=3DKVM/disk5-quantal-xia=
n-26,media=3Ddisk,if=3Dvirtio -pidfile /dev/shm/kboot/pid-quantal-xian-26 -=
serial file:/dev/shm/kboot/serial-quantal-xian-26 -daemonize -display none =
-monitor null=20

--BXVAT5kNtrzKuDFl
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename="config-3.13.0-rc7-00264-gc11a763"

#
# Automatically generated file; DO NOT EDIT.
# Linux/i386 3.13.0-rc7 Kernel Configuration
#
# CONFIG_64BIT is not set
CONFIG_X86_32=y
CONFIG_X86=y
CONFIG_INSTRUCTION_DECODER=y
CONFIG_OUTPUT_FORMAT="elf32-i386"
CONFIG_ARCH_DEFCONFIG="arch/x86/configs/i386_defconfig"
CONFIG_LOCKDEP_SUPPORT=y
CONFIG_STACKTRACE_SUPPORT=y
CONFIG_HAVE_LATENCYTOP_SUPPORT=y
CONFIG_MMU=y
CONFIG_NEED_SG_DMA_LENGTH=y
CONFIG_GENERIC_ISA_DMA=y
CONFIG_GENERIC_BUG=y
CONFIG_GENERIC_HWEIGHT=y
CONFIG_ARCH_MAY_HAVE_PC_FDC=y
CONFIG_RWSEM_XCHGADD_ALGORITHM=y
CONFIG_GENERIC_CALIBRATE_DELAY=y
CONFIG_ARCH_HAS_CPU_RELAX=y
CONFIG_ARCH_HAS_CACHE_LINE_SIZE=y
CONFIG_ARCH_HAS_CPU_AUTOPROBE=y
CONFIG_HAVE_SETUP_PER_CPU_AREA=y
CONFIG_NEED_PER_CPU_EMBED_FIRST_CHUNK=y
CONFIG_NEED_PER_CPU_PAGE_FIRST_CHUNK=y
CONFIG_ARCH_HIBERNATION_POSSIBLE=y
CONFIG_ARCH_SUSPEND_POSSIBLE=y
CONFIG_ARCH_WANT_HUGE_PMD_SHARE=y
CONFIG_ARCH_WANT_GENERAL_HUGETLB=y
# CONFIG_ZONE_DMA32 is not set
# CONFIG_AUDIT_ARCH is not set
CONFIG_ARCH_SUPPORTS_OPTIMIZED_INLINING=y
CONFIG_ARCH_SUPPORTS_DEBUG_PAGEALLOC=y
CONFIG_X86_32_SMP=y
CONFIG_X86_HT=y
CONFIG_X86_32_LAZY_GS=y
CONFIG_ARCH_HWEIGHT_CFLAGS="-fcall-saved-ecx -fcall-saved-edx"
CONFIG_ARCH_SUPPORTS_UPROBES=y
CONFIG_DEFCONFIG_LIST="/lib/modules/$UNAME_RELEASE/.config"
CONFIG_CONSTRUCTORS=y
CONFIG_IRQ_WORK=y
CONFIG_BUILDTIME_EXTABLE_SORT=y

#
# General setup
#
CONFIG_INIT_ENV_ARG_LIMIT=32
CONFIG_CROSS_COMPILE=""
# CONFIG_COMPILE_TEST is not set
CONFIG_LOCALVERSION=""
CONFIG_LOCALVERSION_AUTO=y
CONFIG_HAVE_KERNEL_GZIP=y
CONFIG_HAVE_KERNEL_BZIP2=y
CONFIG_HAVE_KERNEL_LZMA=y
CONFIG_HAVE_KERNEL_XZ=y
CONFIG_HAVE_KERNEL_LZO=y
CONFIG_HAVE_KERNEL_LZ4=y
# CONFIG_KERNEL_GZIP is not set
# CONFIG_KERNEL_BZIP2 is not set
# CONFIG_KERNEL_LZMA is not set
# CONFIG_KERNEL_XZ is not set
CONFIG_KERNEL_LZO=y
# CONFIG_KERNEL_LZ4 is not set
CONFIG_DEFAULT_HOSTNAME="(none)"
CONFIG_SWAP=y
CONFIG_SYSVIPC=y
# CONFIG_POSIX_MQUEUE is not set
CONFIG_FHANDLE=y
CONFIG_AUDIT=y
# CONFIG_AUDITSYSCALL is not set

#
# IRQ subsystem
#
CONFIG_GENERIC_IRQ_PROBE=y
CONFIG_GENERIC_IRQ_SHOW=y
CONFIG_GENERIC_PENDING_IRQ=y
CONFIG_IRQ_DOMAIN=y
# CONFIG_IRQ_DOMAIN_DEBUG is not set
CONFIG_IRQ_FORCED_THREADING=y
CONFIG_SPARSE_IRQ=y
CONFIG_CLOCKSOURCE_WATCHDOG=y
CONFIG_KTIME_SCALAR=y
CONFIG_GENERIC_CLOCKEVENTS=y
CONFIG_GENERIC_CLOCKEVENTS_BUILD=y
CONFIG_GENERIC_CLOCKEVENTS_BROADCAST=y
CONFIG_GENERIC_CLOCKEVENTS_MIN_ADJUST=y
CONFIG_GENERIC_CMOS_UPDATE=y

#
# Timers subsystem
#
CONFIG_HZ_PERIODIC=y
# CONFIG_NO_HZ_IDLE is not set
CONFIG_NO_HZ=y
# CONFIG_HIGH_RES_TIMERS is not set

#
# CPU/Task time and stats accounting
#
CONFIG_TICK_CPU_ACCOUNTING=y
# CONFIG_IRQ_TIME_ACCOUNTING is not set
# CONFIG_BSD_PROCESS_ACCT is not set
CONFIG_TASKSTATS=y
CONFIG_TASK_DELAY_ACCT=y
CONFIG_TASK_XACCT=y
CONFIG_TASK_IO_ACCOUNTING=y

#
# RCU Subsystem
#
CONFIG_TREE_RCU=y
# CONFIG_PREEMPT_RCU is not set
CONFIG_RCU_STALL_COMMON=y
CONFIG_RCU_FANOUT=32
CONFIG_RCU_FANOUT_LEAF=16
# CONFIG_RCU_FANOUT_EXACT is not set
CONFIG_TREE_RCU_TRACE=y
CONFIG_RCU_NOCB_CPU=y
# CONFIG_RCU_NOCB_CPU_NONE is not set
# CONFIG_RCU_NOCB_CPU_ZERO is not set
CONFIG_RCU_NOCB_CPU_ALL=y
CONFIG_IKCONFIG=y
# CONFIG_IKCONFIG_PROC is not set
CONFIG_LOG_BUF_SHIFT=17
CONFIG_HAVE_UNSTABLE_SCHED_CLOCK=y
CONFIG_ARCH_SUPPORTS_NUMA_BALANCING=y
CONFIG_ARCH_WANTS_PROT_NUMA_PROT_NONE=y
CONFIG_CGROUPS=y
CONFIG_CGROUP_DEBUG=y
# CONFIG_CGROUP_FREEZER is not set
# CONFIG_CGROUP_DEVICE is not set
CONFIG_CPUSETS=y
CONFIG_PROC_PID_CPUSET=y
# CONFIG_CGROUP_CPUACCT is not set
CONFIG_RESOURCE_COUNTERS=y
# CONFIG_MEMCG is not set
# CONFIG_CGROUP_PERF is not set
CONFIG_CGROUP_SCHED=y
CONFIG_FAIR_GROUP_SCHED=y
# CONFIG_CFS_BANDWIDTH is not set
# CONFIG_RT_GROUP_SCHED is not set
CONFIG_BLK_CGROUP=y
CONFIG_DEBUG_BLK_CGROUP=y
# CONFIG_CHECKPOINT_RESTORE is not set
# CONFIG_NAMESPACES is not set
CONFIG_UIDGID_STRICT_TYPE_CHECKS=y
CONFIG_SCHED_AUTOGROUP=y
# CONFIG_SYSFS_DEPRECATED is not set
CONFIG_RELAY=y
CONFIG_BLK_DEV_INITRD=y
CONFIG_INITRAMFS_SOURCE=""
CONFIG_RD_GZIP=y
# CONFIG_RD_BZIP2 is not set
# CONFIG_RD_LZMA is not set
# CONFIG_RD_XZ is not set
# CONFIG_RD_LZO is not set
# CONFIG_RD_LZ4 is not set
# CONFIG_CC_OPTIMIZE_FOR_SIZE is not set
CONFIG_ANON_INODES=y
CONFIG_HAVE_UID16=y
CONFIG_SYSCTL_EXCEPTION_TRACE=y
CONFIG_HAVE_PCSPKR_PLATFORM=y
CONFIG_EXPERT=y
CONFIG_UID16=y
CONFIG_KALLSYMS=y
CONFIG_KALLSYMS_ALL=y
CONFIG_PRINTK=y
CONFIG_BUG=y
CONFIG_ELF_CORE=y
# CONFIG_PCSPKR_PLATFORM is not set
CONFIG_BASE_FULL=y
CONFIG_FUTEX=y
# CONFIG_EPOLL is not set
# CONFIG_SIGNALFD is not set
CONFIG_TIMERFD=y
CONFIG_EVENTFD=y
# CONFIG_SHMEM is not set
# CONFIG_AIO is not set
CONFIG_PCI_QUIRKS=y
CONFIG_EMBEDDED=y
CONFIG_HAVE_PERF_EVENTS=y
CONFIG_PERF_USE_VMALLOC=y

#
# Kernel Performance Events And Counters
#
CONFIG_PERF_EVENTS=y
CONFIG_DEBUG_PERF_USE_VMALLOC=y
# CONFIG_VM_EVENT_COUNTERS is not set
# CONFIG_COMPAT_BRK is not set
# CONFIG_SLAB is not set
# CONFIG_SLUB is not set
CONFIG_SLOB=y
CONFIG_PROFILING=y
CONFIG_TRACEPOINTS=y
# CONFIG_OPROFILE is not set
CONFIG_HAVE_OPROFILE=y
CONFIG_OPROFILE_NMI_TIMER=y
# CONFIG_JUMP_LABEL is not set
CONFIG_UPROBES=y
# CONFIG_HAVE_64BIT_ALIGNED_ACCESS is not set
CONFIG_HAVE_EFFICIENT_UNALIGNED_ACCESS=y
CONFIG_ARCH_USE_BUILTIN_BSWAP=y
CONFIG_HAVE_IOREMAP_PROT=y
CONFIG_HAVE_KPROBES=y
CONFIG_HAVE_KRETPROBES=y
CONFIG_HAVE_OPTPROBES=y
CONFIG_HAVE_KPROBES_ON_FTRACE=y
CONFIG_HAVE_ARCH_TRACEHOOK=y
CONFIG_HAVE_DMA_ATTRS=y
CONFIG_HAVE_DMA_CONTIGUOUS=y
CONFIG_GENERIC_SMP_IDLE_THREAD=y
CONFIG_HAVE_REGS_AND_STACK_ACCESS_API=y
CONFIG_HAVE_DMA_API_DEBUG=y
CONFIG_HAVE_HW_BREAKPOINT=y
CONFIG_HAVE_MIXED_BREAKPOINTS_REGS=y
CONFIG_HAVE_USER_RETURN_NOTIFIER=y
CONFIG_HAVE_PERF_EVENTS_NMI=y
CONFIG_HAVE_PERF_REGS=y
CONFIG_HAVE_PERF_USER_STACK_DUMP=y
CONFIG_HAVE_ARCH_JUMP_LABEL=y
CONFIG_ARCH_HAVE_NMI_SAFE_CMPXCHG=y
CONFIG_HAVE_CMPXCHG_LOCAL=y
CONFIG_HAVE_CMPXCHG_DOUBLE=y
CONFIG_ARCH_WANT_IPC_PARSE_VERSION=y
CONFIG_HAVE_ARCH_SECCOMP_FILTER=y
CONFIG_SECCOMP_FILTER=y
CONFIG_HAVE_IRQ_TIME_ACCOUNTING=y
CONFIG_HAVE_ARCH_TRANSPARENT_HUGEPAGE=y
CONFIG_HAVE_ARCH_SOFT_DIRTY=y
CONFIG_MODULES_USE_ELF_REL=y
CONFIG_CLONE_BACKWARDS=y
CONFIG_OLD_SIGSUSPEND3=y
CONFIG_OLD_SIGACTION=y

#
# GCOV-based kernel profiling
#
CONFIG_GCOV_KERNEL=y
CONFIG_GCOV_PROFILE_ALL=y
CONFIG_GCOV_FORMAT_AUTODETECT=y
# CONFIG_GCOV_FORMAT_3_4 is not set
# CONFIG_GCOV_FORMAT_4_7 is not set
CONFIG_HAVE_GENERIC_DMA_COHERENT=y
CONFIG_RT_MUTEXES=y
CONFIG_BASE_SMALL=0
# CONFIG_SYSTEM_TRUSTED_KEYRING is not set
# CONFIG_MODULES is not set
CONFIG_STOP_MACHINE=y
CONFIG_BLOCK=y
CONFIG_LBDAF=y
CONFIG_BLK_DEV_BSG=y
CONFIG_BLK_DEV_BSGLIB=y
CONFIG_BLK_DEV_INTEGRITY=y
# CONFIG_BLK_DEV_THROTTLING is not set
# CONFIG_BLK_CMDLINE_PARSER is not set

#
# Partition Types
#
CONFIG_PARTITION_ADVANCED=y
# CONFIG_ACORN_PARTITION is not set
CONFIG_AIX_PARTITION=y
CONFIG_OSF_PARTITION=y
# CONFIG_AMIGA_PARTITION is not set
CONFIG_ATARI_PARTITION=y
CONFIG_MAC_PARTITION=y
CONFIG_MSDOS_PARTITION=y
CONFIG_BSD_DISKLABEL=y
# CONFIG_MINIX_SUBPARTITION is not set
CONFIG_SOLARIS_X86_PARTITION=y
# CONFIG_UNIXWARE_DISKLABEL is not set
# CONFIG_LDM_PARTITION is not set
# CONFIG_SGI_PARTITION is not set
# CONFIG_ULTRIX_PARTITION is not set
# CONFIG_SUN_PARTITION is not set
# CONFIG_KARMA_PARTITION is not set
# CONFIG_EFI_PARTITION is not set
# CONFIG_SYSV68_PARTITION is not set
# CONFIG_CMDLINE_PARTITION is not set

#
# IO Schedulers
#
CONFIG_IOSCHED_NOOP=y
CONFIG_IOSCHED_DEADLINE=y
CONFIG_IOSCHED_CFQ=y
# CONFIG_CFQ_GROUP_IOSCHED is not set
# CONFIG_DEFAULT_DEADLINE is not set
CONFIG_DEFAULT_CFQ=y
# CONFIG_DEFAULT_NOOP is not set
CONFIG_DEFAULT_IOSCHED="cfq"
CONFIG_ASN1=y
CONFIG_UNINLINE_SPIN_UNLOCK=y
CONFIG_FREEZER=y

#
# Processor type and features
#
# CONFIG_ZONE_DMA is not set
CONFIG_SMP=y
CONFIG_X86_MPPARSE=y
CONFIG_X86_BIGSMP=y
CONFIG_GOLDFISH=y
CONFIG_X86_EXTENDED_PLATFORM=y
CONFIG_X86_GOLDFISH=y
CONFIG_X86_WANT_INTEL_MID=y
# CONFIG_X86_MDFLD is not set
# CONFIG_X86_INTEL_LPSS is not set
# CONFIG_X86_RDC321X is not set
CONFIG_X86_32_NON_STANDARD=y
# CONFIG_X86_NUMAQ is not set
# CONFIG_STA2X11 is not set
# CONFIG_X86_SUMMIT is not set
# CONFIG_X86_ES7000 is not set
CONFIG_X86_32_IRIS=y
# CONFIG_SCHED_OMIT_FRAME_POINTER is not set
CONFIG_HYPERVISOR_GUEST=y
CONFIG_PARAVIRT=y
# CONFIG_PARAVIRT_DEBUG is not set
# CONFIG_PARAVIRT_SPINLOCKS is not set
# CONFIG_XEN_PRIVILEGED_GUEST is not set
CONFIG_KVM_GUEST=y
# CONFIG_KVM_DEBUG_FS is not set
CONFIG_LGUEST_GUEST=y
# CONFIG_PARAVIRT_TIME_ACCOUNTING is not set
CONFIG_PARAVIRT_CLOCK=y
CONFIG_NO_BOOTMEM=y
CONFIG_MEMTEST=y
# CONFIG_M486 is not set
# CONFIG_M586 is not set
# CONFIG_M586TSC is not set
# CONFIG_M586MMX is not set
# CONFIG_M686 is not set
# CONFIG_MPENTIUMII is not set
# CONFIG_MPENTIUMIII is not set
# CONFIG_MPENTIUMM is not set
# CONFIG_MPENTIUM4 is not set
# CONFIG_MK6 is not set
# CONFIG_MK7 is not set
# CONFIG_MK8 is not set
# CONFIG_MCRUSOE is not set
# CONFIG_MEFFICEON is not set
# CONFIG_MWINCHIPC6 is not set
# CONFIG_MWINCHIP3D is not set
# CONFIG_MELAN is not set
CONFIG_MGEODEGX1=y
# CONFIG_MGEODE_LX is not set
# CONFIG_MCYRIXIII is not set
# CONFIG_MVIAC3_2 is not set
# CONFIG_MVIAC7 is not set
# CONFIG_MCORE2 is not set
# CONFIG_MATOM is not set
CONFIG_X86_GENERIC=y
CONFIG_X86_INTERNODE_CACHE_SHIFT=6
CONFIG_X86_L1_CACHE_SHIFT=6
CONFIG_X86_PPRO_FENCE=y
CONFIG_X86_ALIGNMENT_16=y
CONFIG_X86_INTEL_USERCOPY=y
CONFIG_X86_TSC=y
CONFIG_X86_MINIMUM_CPU_FAMILY=4
CONFIG_X86_DEBUGCTLMSR=y
CONFIG_PROCESSOR_SELECT=y
# CONFIG_CPU_SUP_INTEL is not set
# CONFIG_CPU_SUP_CYRIX_32 is not set
# CONFIG_CPU_SUP_AMD is not set
# CONFIG_CPU_SUP_CENTAUR is not set
# CONFIG_CPU_SUP_TRANSMETA_32 is not set
CONFIG_CPU_SUP_UMC_32=y
CONFIG_HPET_TIMER=y
CONFIG_DMI=y
CONFIG_NR_CPUS=32
# CONFIG_SCHED_SMT is not set
CONFIG_SCHED_MC=y
# CONFIG_PREEMPT_NONE is not set
CONFIG_PREEMPT_VOLUNTARY=y
# CONFIG_PREEMPT is not set
CONFIG_PREEMPT_COUNT=y
CONFIG_X86_LOCAL_APIC=y
CONFIG_X86_IO_APIC=y
CONFIG_X86_REROUTE_FOR_BROKEN_BOOT_IRQS=y
# CONFIG_X86_MCE is not set
# CONFIG_VM86 is not set
CONFIG_TOSHIBA=y
CONFIG_I8K=y
# CONFIG_X86_REBOOTFIXUPS is not set
# CONFIG_MICROCODE_INTEL_EARLY is not set
# CONFIG_MICROCODE_AMD_EARLY is not set
# CONFIG_X86_MSR is not set
CONFIG_X86_CPUID=y
# CONFIG_NOHIGHMEM is not set
CONFIG_HIGHMEM4G=y
# CONFIG_HIGHMEM64G is not set
# CONFIG_VMSPLIT_3G is not set
CONFIG_VMSPLIT_3G_OPT=y
# CONFIG_VMSPLIT_2G is not set
# CONFIG_VMSPLIT_2G_OPT is not set
# CONFIG_VMSPLIT_1G is not set
CONFIG_PAGE_OFFSET=0xB0000000
CONFIG_HIGHMEM=y
CONFIG_ARCH_FLATMEM_ENABLE=y
CONFIG_ARCH_SPARSEMEM_ENABLE=y
CONFIG_ARCH_SELECT_MEMORY_MODEL=y
CONFIG_ILLEGAL_POINTER_VALUE=0
CONFIG_SELECT_MEMORY_MODEL=y
CONFIG_FLATMEM_MANUAL=y
# CONFIG_SPARSEMEM_MANUAL is not set
CONFIG_FLATMEM=y
CONFIG_FLAT_NODE_MEM_MAP=y
CONFIG_SPARSEMEM_STATIC=y
CONFIG_HAVE_MEMBLOCK=y
CONFIG_HAVE_MEMBLOCK_NODE_MAP=y
CONFIG_ARCH_DISCARD_MEMBLOCK=y
# CONFIG_HAVE_BOOTMEM_INFO_NODE is not set
CONFIG_PAGEFLAGS_EXTENDED=y
CONFIG_SPLIT_PTLOCK_CPUS=4
# CONFIG_COMPACTION is not set
# CONFIG_PHYS_ADDR_T_64BIT is not set
CONFIG_ZONE_DMA_FLAG=0
CONFIG_BOUNCE=y
CONFIG_NEED_BOUNCE_POOL=y
CONFIG_VIRT_TO_BUS=y
# CONFIG_KSM is not set
CONFIG_DEFAULT_MMAP_MIN_ADDR=4096
# CONFIG_TRANSPARENT_HUGEPAGE is not set
# CONFIG_CROSS_MEMORY_ATTACH is not set
# CONFIG_CLEANCACHE is not set
# CONFIG_FRONTSWAP is not set
# CONFIG_CMA is not set
# CONFIG_ZBUD is not set
# CONFIG_HIGHPTE is not set
CONFIG_X86_CHECK_BIOS_CORRUPTION=y
CONFIG_X86_BOOTPARAM_MEMORY_CORRUPTION_CHECK=y
CONFIG_X86_RESERVE_LOW=64
CONFIG_MATH_EMULATION=y
# CONFIG_MTRR is not set
CONFIG_ARCH_RANDOM=y
# CONFIG_X86_SMAP is not set
# CONFIG_EFI is not set
CONFIG_SECCOMP=y
# CONFIG_CC_STACKPROTECTOR is not set
# CONFIG_HZ_100 is not set
# CONFIG_HZ_250 is not set
# CONFIG_HZ_300 is not set
CONFIG_HZ_1000=y
CONFIG_HZ=1000
# CONFIG_SCHED_HRTICK is not set
CONFIG_KEXEC=y
CONFIG_CRASH_DUMP=y
CONFIG_PHYSICAL_START=0x1000000
CONFIG_RELOCATABLE=y
CONFIG_X86_NEED_RELOCS=y
CONFIG_PHYSICAL_ALIGN=0x200000
CONFIG_HOTPLUG_CPU=y
# CONFIG_BOOTPARAM_HOTPLUG_CPU0 is not set
# CONFIG_DEBUG_HOTPLUG_CPU0 is not set
# CONFIG_COMPAT_VDSO is not set
# CONFIG_CMDLINE_BOOL is not set
CONFIG_ARCH_ENABLE_MEMORY_HOTPLUG=y

#
# Power management and ACPI options
#
CONFIG_SUSPEND=y
CONFIG_SUSPEND_FREEZER=y
# CONFIG_HIBERNATION is not set
CONFIG_PM_SLEEP=y
CONFIG_PM_SLEEP_SMP=y
# CONFIG_PM_AUTOSLEEP is not set
# CONFIG_PM_WAKELOCKS is not set
# CONFIG_PM_RUNTIME is not set
CONFIG_PM=y
# CONFIG_PM_DEBUG is not set
# CONFIG_WQ_POWER_EFFICIENT_DEFAULT is not set
CONFIG_ACPI=y
CONFIG_ACPI_SLEEP=y
# CONFIG_ACPI_PROCFS is not set
# CONFIG_ACPI_EC_DEBUGFS is not set
CONFIG_ACPI_AC=y
CONFIG_ACPI_BATTERY=y
CONFIG_ACPI_BUTTON=y
# CONFIG_ACPI_VIDEO is not set
CONFIG_ACPI_FAN=y
# CONFIG_ACPI_DOCK is not set
CONFIG_ACPI_PROCESSOR=y
# CONFIG_ACPI_IPMI is not set
CONFIG_ACPI_HOTPLUG_CPU=y
# CONFIG_ACPI_PROCESSOR_AGGREGATOR is not set
CONFIG_ACPI_THERMAL=y
CONFIG_ACPI_CUSTOM_DSDT_FILE=""
# CONFIG_ACPI_CUSTOM_DSDT is not set
# CONFIG_ACPI_INITRD_TABLE_OVERRIDE is not set
# CONFIG_ACPI_DEBUG is not set
# CONFIG_ACPI_PCI_SLOT is not set
CONFIG_X86_PM_TIMER=y
CONFIG_ACPI_CONTAINER=y
# CONFIG_ACPI_SBS is not set
# CONFIG_ACPI_HED is not set
# CONFIG_ACPI_CUSTOM_METHOD is not set
# CONFIG_ACPI_APEI is not set
CONFIG_SFI=y
CONFIG_X86_APM_BOOT=y
CONFIG_APM=y
# CONFIG_APM_IGNORE_USER_SUSPEND is not set
CONFIG_APM_DO_ENABLE=y
# CONFIG_APM_CPU_IDLE is not set
# CONFIG_APM_DISPLAY_BLANK is not set
CONFIG_APM_ALLOW_INTS=y

#
# CPU Frequency scaling
#
CONFIG_CPU_FREQ=y
CONFIG_CPU_FREQ_GOV_COMMON=y
CONFIG_CPU_FREQ_STAT=y
CONFIG_CPU_FREQ_STAT_DETAILS=y
# CONFIG_CPU_FREQ_DEFAULT_GOV_PERFORMANCE is not set
# CONFIG_CPU_FREQ_DEFAULT_GOV_POWERSAVE is not set
CONFIG_CPU_FREQ_DEFAULT_GOV_USERSPACE=y
# CONFIG_CPU_FREQ_DEFAULT_GOV_ONDEMAND is not set
# CONFIG_CPU_FREQ_DEFAULT_GOV_CONSERVATIVE is not set
# CONFIG_CPU_FREQ_GOV_PERFORMANCE is not set
CONFIG_CPU_FREQ_GOV_POWERSAVE=y
CONFIG_CPU_FREQ_GOV_USERSPACE=y
CONFIG_CPU_FREQ_GOV_ONDEMAND=y
# CONFIG_CPU_FREQ_GOV_CONSERVATIVE is not set

#
# x86 CPU frequency scaling drivers
#
# CONFIG_X86_INTEL_PSTATE is not set
# CONFIG_X86_PCC_CPUFREQ is not set
# CONFIG_X86_ACPI_CPUFREQ is not set
CONFIG_X86_POWERNOW_K6=y
# CONFIG_X86_POWERNOW_K7 is not set
# CONFIG_X86_GX_SUSPMOD is not set
CONFIG_X86_SPEEDSTEP_CENTRINO=y
CONFIG_X86_SPEEDSTEP_CENTRINO_TABLE=y
# CONFIG_X86_SPEEDSTEP_ICH is not set
CONFIG_X86_SPEEDSTEP_SMI=y
CONFIG_X86_P4_CLOCKMOD=y
# CONFIG_X86_CPUFREQ_NFORCE2 is not set
CONFIG_X86_LONGRUN=y
# CONFIG_X86_LONGHAUL is not set
# CONFIG_X86_E_POWERSAVER is not set

#
# shared options
#
CONFIG_X86_SPEEDSTEP_LIB=y
CONFIG_X86_SPEEDSTEP_RELAXED_CAP_CHECK=y

#
# CPU Idle
#
CONFIG_CPU_IDLE=y
CONFIG_CPU_IDLE_MULTIPLE_DRIVERS=y
# CONFIG_CPU_IDLE_GOV_LADDER is not set
CONFIG_CPU_IDLE_GOV_MENU=y
# CONFIG_ARCH_NEEDS_CPU_IDLE_COUPLED is not set

#
# Bus options (PCI etc.)
#
CONFIG_PCI=y
# CONFIG_PCI_GOBIOS is not set
# CONFIG_PCI_GOMMCONFIG is not set
# CONFIG_PCI_GODIRECT is not set
CONFIG_PCI_GOANY=y
CONFIG_PCI_BIOS=y
CONFIG_PCI_DIRECT=y
CONFIG_PCI_MMCONFIG=y
CONFIG_PCI_DOMAINS=y
# CONFIG_PCI_CNB20LE_QUIRK is not set
# CONFIG_PCIEPORTBUS is not set
# CONFIG_PCI_MSI is not set
# CONFIG_PCI_DEBUG is not set
# CONFIG_PCI_REALLOC_ENABLE_AUTO is not set
# CONFIG_PCI_STUB is not set
CONFIG_HT_IRQ=y
# CONFIG_PCI_IOV is not set
# CONFIG_PCI_PRI is not set
# CONFIG_PCI_PASID is not set
# CONFIG_PCI_IOAPIC is not set
CONFIG_PCI_LABEL=y

#
# PCI host controller drivers
#
CONFIG_ISA_DMA_API=y
# CONFIG_ISA is not set
# CONFIG_SCx200 is not set
# CONFIG_OLPC is not set
CONFIG_ALIX=y
CONFIG_NET5501=y
CONFIG_GEOS=y
CONFIG_PCCARD=y
CONFIG_PCMCIA=y
# CONFIG_PCMCIA_LOAD_CIS is not set
CONFIG_CARDBUS=y

#
# PC-card bridges
#
# CONFIG_YENTA is not set
# CONFIG_PD6729 is not set
# CONFIG_I82092 is not set
# CONFIG_HOTPLUG_PCI is not set
# CONFIG_RAPIDIO is not set
CONFIG_X86_SYSFB=y

#
# Executable file formats / Emulations
#
CONFIG_BINFMT_ELF=y
CONFIG_ARCH_BINFMT_ELF_RANDOMIZE_PIE=y
CONFIG_CORE_DUMP_DEFAULT_ELF_HEADERS=y
CONFIG_BINFMT_SCRIPT=y
CONFIG_HAVE_AOUT=y
CONFIG_BINFMT_AOUT=y
CONFIG_BINFMT_MISC=y
CONFIG_COREDUMP=y
CONFIG_HAVE_ATOMIC_IOMAP=y
CONFIG_NET=y

#
# Networking options
#
CONFIG_PACKET=y
# CONFIG_PACKET_DIAG is not set
CONFIG_UNIX=y
CONFIG_UNIX_DIAG=y
CONFIG_XFRM=y
CONFIG_XFRM_ALGO=y
CONFIG_XFRM_USER=y
# CONFIG_XFRM_SUB_POLICY is not set
# CONFIG_XFRM_MIGRATE is not set
# CONFIG_XFRM_STATISTICS is not set
CONFIG_XFRM_IPCOMP=y
CONFIG_NET_KEY=y
# CONFIG_NET_KEY_MIGRATE is not set
CONFIG_INET=y
# CONFIG_IP_MULTICAST is not set
# CONFIG_IP_ADVANCED_ROUTER is not set
CONFIG_IP_ROUTE_CLASSID=y
CONFIG_IP_PNP=y
CONFIG_IP_PNP_DHCP=y
# CONFIG_IP_PNP_BOOTP is not set
# CONFIG_IP_PNP_RARP is not set
CONFIG_NET_IPIP=y
# CONFIG_NET_IPGRE_DEMUX is not set
CONFIG_NET_IP_TUNNEL=y
CONFIG_SYN_COOKIES=y
# CONFIG_NET_IPVTI is not set
CONFIG_INET_AH=y
# CONFIG_INET_ESP is not set
# CONFIG_INET_IPCOMP is not set
# CONFIG_INET_XFRM_TUNNEL is not set
CONFIG_INET_TUNNEL=y
# CONFIG_INET_XFRM_MODE_TRANSPORT is not set
CONFIG_INET_XFRM_MODE_TUNNEL=y
CONFIG_INET_XFRM_MODE_BEET=y
CONFIG_INET_LRO=y
CONFIG_INET_DIAG=y
CONFIG_INET_TCP_DIAG=y
# CONFIG_INET_UDP_DIAG is not set
CONFIG_TCP_CONG_ADVANCED=y
CONFIG_TCP_CONG_BIC=y
CONFIG_TCP_CONG_CUBIC=y
# CONFIG_TCP_CONG_WESTWOOD is not set
CONFIG_TCP_CONG_HTCP=y
CONFIG_TCP_CONG_HSTCP=y
# CONFIG_TCP_CONG_HYBLA is not set
CONFIG_TCP_CONG_VEGAS=y
# CONFIG_TCP_CONG_SCALABLE is not set
CONFIG_TCP_CONG_LP=y
# CONFIG_TCP_CONG_VENO is not set
CONFIG_TCP_CONG_YEAH=y
# CONFIG_TCP_CONG_ILLINOIS is not set
CONFIG_DEFAULT_BIC=y
# CONFIG_DEFAULT_CUBIC is not set
# CONFIG_DEFAULT_HTCP is not set
# CONFIG_DEFAULT_VEGAS is not set
# CONFIG_DEFAULT_RENO is not set
CONFIG_DEFAULT_TCP_CONG="bic"
# CONFIG_TCP_MD5SIG is not set
CONFIG_IPV6=y
CONFIG_IPV6_ROUTER_PREF=y
CONFIG_IPV6_ROUTE_INFO=y
CONFIG_IPV6_OPTIMISTIC_DAD=y
# CONFIG_INET6_AH is not set
# CONFIG_INET6_ESP is not set
CONFIG_INET6_IPCOMP=y
CONFIG_IPV6_MIP6=y
CONFIG_INET6_XFRM_TUNNEL=y
CONFIG_INET6_TUNNEL=y
CONFIG_INET6_XFRM_MODE_TRANSPORT=y
CONFIG_INET6_XFRM_MODE_TUNNEL=y
# CONFIG_INET6_XFRM_MODE_BEET is not set
CONFIG_INET6_XFRM_MODE_ROUTEOPTIMIZATION=y
CONFIG_IPV6_VTI=y
CONFIG_IPV6_SIT=y
# CONFIG_IPV6_SIT_6RD is not set
CONFIG_IPV6_NDISC_NODETYPE=y
CONFIG_IPV6_TUNNEL=y
CONFIG_IPV6_GRE=y
# CONFIG_IPV6_MULTIPLE_TABLES is not set
CONFIG_IPV6_MROUTE=y
CONFIG_IPV6_MROUTE_MULTIPLE_TABLES=y
# CONFIG_IPV6_PIMSM_V2 is not set
CONFIG_NETLABEL=y
CONFIG_NETWORK_SECMARK=y
# CONFIG_NETWORK_PHY_TIMESTAMPING is not set
CONFIG_NETFILTER=y
CONFIG_NETFILTER_DEBUG=y
CONFIG_NETFILTER_ADVANCED=y
# CONFIG_BRIDGE_NETFILTER is not set

#
# Core Netfilter Configuration
#
CONFIG_NETFILTER_NETLINK=y
CONFIG_NETFILTER_NETLINK_ACCT=y
CONFIG_NETFILTER_NETLINK_QUEUE=y
CONFIG_NETFILTER_NETLINK_LOG=y
CONFIG_NF_CONNTRACK=y
CONFIG_NF_CONNTRACK_MARK=y
CONFIG_NF_CONNTRACK_SECMARK=y
# CONFIG_NF_CONNTRACK_ZONES is not set
CONFIG_NF_CONNTRACK_PROCFS=y
CONFIG_NF_CONNTRACK_EVENTS=y
CONFIG_NF_CONNTRACK_TIMEOUT=y
CONFIG_NF_CONNTRACK_TIMESTAMP=y
# CONFIG_NF_CT_PROTO_DCCP is not set
# CONFIG_NF_CT_PROTO_SCTP is not set
CONFIG_NF_CT_PROTO_UDPLITE=y
CONFIG_NF_CONNTRACK_AMANDA=y
CONFIG_NF_CONNTRACK_FTP=y
CONFIG_NF_CONNTRACK_H323=y
CONFIG_NF_CONNTRACK_IRC=y
CONFIG_NF_CONNTRACK_BROADCAST=y
# CONFIG_NF_CONNTRACK_NETBIOS_NS is not set
CONFIG_NF_CONNTRACK_SNMP=y
# CONFIG_NF_CONNTRACK_PPTP is not set
# CONFIG_NF_CONNTRACK_SANE is not set
CONFIG_NF_CONNTRACK_SIP=y
CONFIG_NF_CONNTRACK_TFTP=y
CONFIG_NF_CT_NETLINK=y
# CONFIG_NF_CT_NETLINK_TIMEOUT is not set
# CONFIG_NETFILTER_NETLINK_QUEUE_CT is not set
CONFIG_NETFILTER_SYNPROXY=y
CONFIG_NF_TABLES=y
CONFIG_NFT_EXTHDR=y
# CONFIG_NFT_META is not set
CONFIG_NFT_CT=y
# CONFIG_NFT_RBTREE is not set
CONFIG_NFT_HASH=y
CONFIG_NFT_COUNTER=y
# CONFIG_NFT_LOG is not set
# CONFIG_NFT_LIMIT is not set
CONFIG_NFT_COMPAT=y
CONFIG_NETFILTER_XTABLES=y

#
# Xtables combined modules
#
CONFIG_NETFILTER_XT_MARK=y
CONFIG_NETFILTER_XT_CONNMARK=y
# CONFIG_NETFILTER_XT_SET is not set

#
# Xtables targets
#
# CONFIG_NETFILTER_XT_TARGET_AUDIT is not set
CONFIG_NETFILTER_XT_TARGET_CHECKSUM=y
# CONFIG_NETFILTER_XT_TARGET_CLASSIFY is not set
# CONFIG_NETFILTER_XT_TARGET_CONNMARK is not set
CONFIG_NETFILTER_XT_TARGET_CONNSECMARK=y
CONFIG_NETFILTER_XT_TARGET_CT=y
CONFIG_NETFILTER_XT_TARGET_DSCP=y
CONFIG_NETFILTER_XT_TARGET_HL=y
CONFIG_NETFILTER_XT_TARGET_HMARK=y
CONFIG_NETFILTER_XT_TARGET_IDLETIMER=y
CONFIG_NETFILTER_XT_TARGET_LED=y
CONFIG_NETFILTER_XT_TARGET_LOG=y
CONFIG_NETFILTER_XT_TARGET_MARK=y
CONFIG_NETFILTER_XT_TARGET_NFLOG=y
CONFIG_NETFILTER_XT_TARGET_NFQUEUE=y
CONFIG_NETFILTER_XT_TARGET_NOTRACK=y
CONFIG_NETFILTER_XT_TARGET_RATEEST=y
CONFIG_NETFILTER_XT_TARGET_TEE=y
CONFIG_NETFILTER_XT_TARGET_TPROXY=y
CONFIG_NETFILTER_XT_TARGET_TRACE=y
# CONFIG_NETFILTER_XT_TARGET_SECMARK is not set
CONFIG_NETFILTER_XT_TARGET_TCPMSS=y
CONFIG_NETFILTER_XT_TARGET_TCPOPTSTRIP=y

#
# Xtables matches
#
CONFIG_NETFILTER_XT_MATCH_ADDRTYPE=y
CONFIG_NETFILTER_XT_MATCH_BPF=y
# CONFIG_NETFILTER_XT_MATCH_CLUSTER is not set
CONFIG_NETFILTER_XT_MATCH_COMMENT=y
CONFIG_NETFILTER_XT_MATCH_CONNBYTES=y
# CONFIG_NETFILTER_XT_MATCH_CONNLABEL is not set
# CONFIG_NETFILTER_XT_MATCH_CONNLIMIT is not set
CONFIG_NETFILTER_XT_MATCH_CONNMARK=y
CONFIG_NETFILTER_XT_MATCH_CONNTRACK=y
CONFIG_NETFILTER_XT_MATCH_CPU=y
CONFIG_NETFILTER_XT_MATCH_DCCP=y
CONFIG_NETFILTER_XT_MATCH_DEVGROUP=y
CONFIG_NETFILTER_XT_MATCH_DSCP=y
# CONFIG_NETFILTER_XT_MATCH_ECN is not set
CONFIG_NETFILTER_XT_MATCH_ESP=y
CONFIG_NETFILTER_XT_MATCH_HASHLIMIT=y
CONFIG_NETFILTER_XT_MATCH_HELPER=y
CONFIG_NETFILTER_XT_MATCH_HL=y
# CONFIG_NETFILTER_XT_MATCH_IPRANGE is not set
# CONFIG_NETFILTER_XT_MATCH_IPVS is not set
CONFIG_NETFILTER_XT_MATCH_LENGTH=y
CONFIG_NETFILTER_XT_MATCH_LIMIT=y
# CONFIG_NETFILTER_XT_MATCH_MAC is not set
CONFIG_NETFILTER_XT_MATCH_MARK=y
CONFIG_NETFILTER_XT_MATCH_MULTIPORT=y
CONFIG_NETFILTER_XT_MATCH_NFACCT=y
CONFIG_NETFILTER_XT_MATCH_OSF=y
# CONFIG_NETFILTER_XT_MATCH_OWNER is not set
CONFIG_NETFILTER_XT_MATCH_POLICY=y
# CONFIG_NETFILTER_XT_MATCH_PKTTYPE is not set
CONFIG_NETFILTER_XT_MATCH_QUOTA=y
# CONFIG_NETFILTER_XT_MATCH_RATEEST is not set
# CONFIG_NETFILTER_XT_MATCH_REALM is not set
CONFIG_NETFILTER_XT_MATCH_RECENT=y
CONFIG_NETFILTER_XT_MATCH_SCTP=y
CONFIG_NETFILTER_XT_MATCH_SOCKET=y
CONFIG_NETFILTER_XT_MATCH_STATE=y
CONFIG_NETFILTER_XT_MATCH_STATISTIC=y
# CONFIG_NETFILTER_XT_MATCH_STRING is not set
CONFIG_NETFILTER_XT_MATCH_TCPMSS=y
CONFIG_NETFILTER_XT_MATCH_TIME=y
CONFIG_NETFILTER_XT_MATCH_U32=y
CONFIG_IP_SET=y
CONFIG_IP_SET_MAX=256
# CONFIG_IP_SET_BITMAP_IP is not set
# CONFIG_IP_SET_BITMAP_IPMAC is not set
CONFIG_IP_SET_BITMAP_PORT=y
CONFIG_IP_SET_HASH_IP=y
CONFIG_IP_SET_HASH_IPPORT=y
# CONFIG_IP_SET_HASH_IPPORTIP is not set
CONFIG_IP_SET_HASH_IPPORTNET=y
CONFIG_IP_SET_HASH_NETPORTNET=y
CONFIG_IP_SET_HASH_NET=y
# CONFIG_IP_SET_HASH_NETNET is not set
CONFIG_IP_SET_HASH_NETPORT=y
# CONFIG_IP_SET_HASH_NETIFACE is not set
# CONFIG_IP_SET_LIST_SET is not set
CONFIG_IP_VS=y
CONFIG_IP_VS_IPV6=y
# CONFIG_IP_VS_DEBUG is not set
CONFIG_IP_VS_TAB_BITS=12

#
# IPVS transport protocol load balancing support
#
# CONFIG_IP_VS_PROTO_TCP is not set
CONFIG_IP_VS_PROTO_UDP=y
# CONFIG_IP_VS_PROTO_AH_ESP is not set
# CONFIG_IP_VS_PROTO_ESP is not set
# CONFIG_IP_VS_PROTO_AH is not set
CONFIG_IP_VS_PROTO_SCTP=y

#
# IPVS scheduler
#
CONFIG_IP_VS_RR=y
CONFIG_IP_VS_WRR=y
CONFIG_IP_VS_LC=y
CONFIG_IP_VS_WLC=y
# CONFIG_IP_VS_LBLC is not set
CONFIG_IP_VS_LBLCR=y
CONFIG_IP_VS_DH=y
CONFIG_IP_VS_SH=y
CONFIG_IP_VS_SED=y
CONFIG_IP_VS_NQ=y

#
# IPVS SH scheduler
#
CONFIG_IP_VS_SH_TAB_BITS=8

#
# IPVS application helper
#
# CONFIG_IP_VS_NFCT is not set
CONFIG_IP_VS_PE_SIP=y

#
# IP: Netfilter Configuration
#
CONFIG_NF_DEFRAG_IPV4=y
CONFIG_NF_CONNTRACK_IPV4=y
CONFIG_NF_CONNTRACK_PROC_COMPAT=y
CONFIG_NF_TABLES_IPV4=y
# CONFIG_NFT_REJECT_IPV4 is not set
CONFIG_NFT_CHAIN_ROUTE_IPV4=y
CONFIG_NF_TABLES_ARP=y
CONFIG_IP_NF_IPTABLES=y
# CONFIG_IP_NF_MATCH_AH is not set
# CONFIG_IP_NF_MATCH_ECN is not set
CONFIG_IP_NF_MATCH_RPFILTER=y
CONFIG_IP_NF_MATCH_TTL=y
CONFIG_IP_NF_FILTER=y
CONFIG_IP_NF_TARGET_REJECT=y
CONFIG_IP_NF_TARGET_SYNPROXY=y
# CONFIG_IP_NF_TARGET_ULOG is not set
# CONFIG_NF_NAT_IPV4 is not set
CONFIG_IP_NF_MANGLE=y
# CONFIG_IP_NF_TARGET_CLUSTERIP is not set
# CONFIG_IP_NF_TARGET_ECN is not set
CONFIG_IP_NF_TARGET_TTL=y
CONFIG_IP_NF_RAW=y
# CONFIG_IP_NF_SECURITY is not set
CONFIG_IP_NF_ARPTABLES=y
CONFIG_IP_NF_ARPFILTER=y
CONFIG_IP_NF_ARP_MANGLE=y

#
# IPv6: Netfilter Configuration
#
CONFIG_NF_DEFRAG_IPV6=y
# CONFIG_NF_CONNTRACK_IPV6 is not set
# CONFIG_NF_TABLES_IPV6 is not set
CONFIG_IP6_NF_IPTABLES=y
CONFIG_IP6_NF_MATCH_AH=y
CONFIG_IP6_NF_MATCH_EUI64=y
CONFIG_IP6_NF_MATCH_FRAG=y
CONFIG_IP6_NF_MATCH_OPTS=y
# CONFIG_IP6_NF_MATCH_HL is not set
# CONFIG_IP6_NF_MATCH_IPV6HEADER is not set
# CONFIG_IP6_NF_MATCH_MH is not set
# CONFIG_IP6_NF_MATCH_RPFILTER is not set
CONFIG_IP6_NF_MATCH_RT=y
CONFIG_IP6_NF_TARGET_HL=y
CONFIG_IP6_NF_FILTER=y
CONFIG_IP6_NF_TARGET_REJECT=y
CONFIG_IP6_NF_TARGET_SYNPROXY=y
CONFIG_IP6_NF_MANGLE=y
# CONFIG_IP6_NF_RAW is not set
# CONFIG_IP6_NF_SECURITY is not set
# CONFIG_NF_TABLES_BRIDGE is not set
CONFIG_BRIDGE_NF_EBTABLES=y
# CONFIG_BRIDGE_EBT_BROUTE is not set
# CONFIG_BRIDGE_EBT_T_FILTER is not set
# CONFIG_BRIDGE_EBT_T_NAT is not set
CONFIG_BRIDGE_EBT_802_3=y
# CONFIG_BRIDGE_EBT_AMONG is not set
# CONFIG_BRIDGE_EBT_ARP is not set
CONFIG_BRIDGE_EBT_IP=y
CONFIG_BRIDGE_EBT_IP6=y
CONFIG_BRIDGE_EBT_LIMIT=y
# CONFIG_BRIDGE_EBT_MARK is not set
# CONFIG_BRIDGE_EBT_PKTTYPE is not set
# CONFIG_BRIDGE_EBT_STP is not set
# CONFIG_BRIDGE_EBT_VLAN is not set
CONFIG_BRIDGE_EBT_ARPREPLY=y
# CONFIG_BRIDGE_EBT_DNAT is not set
# CONFIG_BRIDGE_EBT_MARK_T is not set
CONFIG_BRIDGE_EBT_REDIRECT=y
CONFIG_BRIDGE_EBT_SNAT=y
CONFIG_BRIDGE_EBT_LOG=y
CONFIG_BRIDGE_EBT_ULOG=y
# CONFIG_BRIDGE_EBT_NFLOG is not set
CONFIG_IP_DCCP=y
CONFIG_INET_DCCP_DIAG=y

#
# DCCP CCIDs Configuration
#
# CONFIG_IP_DCCP_CCID2_DEBUG is not set
# CONFIG_IP_DCCP_CCID3 is not set

#
# DCCP Kernel Hacking
#
# CONFIG_IP_DCCP_DEBUG is not set
CONFIG_IP_SCTP=y
CONFIG_SCTP_DBG_OBJCNT=y
# CONFIG_SCTP_DEFAULT_COOKIE_HMAC_MD5 is not set
# CONFIG_SCTP_DEFAULT_COOKIE_HMAC_SHA1 is not set
CONFIG_SCTP_DEFAULT_COOKIE_HMAC_NONE=y
# CONFIG_SCTP_COOKIE_HMAC_MD5 is not set
# CONFIG_SCTP_COOKIE_HMAC_SHA1 is not set
CONFIG_RDS=y
# CONFIG_RDS_TCP is not set
# CONFIG_RDS_DEBUG is not set
CONFIG_TIPC=y
CONFIG_TIPC_PORTS=8191
CONFIG_ATM=y
# CONFIG_ATM_CLIP is not set
# CONFIG_ATM_LANE is not set
CONFIG_ATM_BR2684=y
# CONFIG_ATM_BR2684_IPFILTER is not set
# CONFIG_L2TP is not set
CONFIG_STP=y
CONFIG_BRIDGE=y
# CONFIG_BRIDGE_IGMP_SNOOPING is not set
# CONFIG_VLAN_8021Q is not set
# CONFIG_DECNET is not set
CONFIG_LLC=y
# CONFIG_LLC2 is not set
CONFIG_IPX=y
CONFIG_IPX_INTERN=y
# CONFIG_ATALK is not set
CONFIG_X25=y
CONFIG_LAPB=y
# CONFIG_PHONET is not set
CONFIG_IEEE802154=y
# CONFIG_IEEE802154_6LOWPAN is not set
CONFIG_MAC802154=y
CONFIG_NET_SCHED=y

#
# Queueing/Scheduling
#
CONFIG_NET_SCH_CBQ=y
CONFIG_NET_SCH_HTB=y
CONFIG_NET_SCH_HFSC=y
CONFIG_NET_SCH_ATM=y
CONFIG_NET_SCH_PRIO=y
CONFIG_NET_SCH_MULTIQ=y
CONFIG_NET_SCH_RED=y
CONFIG_NET_SCH_SFB=y
CONFIG_NET_SCH_SFQ=y
CONFIG_NET_SCH_TEQL=y
CONFIG_NET_SCH_TBF=y
CONFIG_NET_SCH_GRED=y
CONFIG_NET_SCH_DSMARK=y
# CONFIG_NET_SCH_NETEM is not set
CONFIG_NET_SCH_DRR=y
CONFIG_NET_SCH_MQPRIO=y
CONFIG_NET_SCH_CHOKE=y
CONFIG_NET_SCH_QFQ=y
# CONFIG_NET_SCH_CODEL is not set
# CONFIG_NET_SCH_FQ_CODEL is not set
# CONFIG_NET_SCH_FQ is not set
# CONFIG_NET_SCH_PLUG is not set

#
# Classification
#
CONFIG_NET_CLS=y
CONFIG_NET_CLS_BASIC=y
CONFIG_NET_CLS_TCINDEX=y
CONFIG_NET_CLS_ROUTE4=y
CONFIG_NET_CLS_FW=y
CONFIG_NET_CLS_U32=y
# CONFIG_CLS_U32_PERF is not set
# CONFIG_CLS_U32_MARK is not set
# CONFIG_NET_CLS_RSVP is not set
CONFIG_NET_CLS_RSVP6=y
# CONFIG_NET_CLS_FLOW is not set
CONFIG_NET_CLS_CGROUP=y
CONFIG_NET_CLS_BPF=y
# CONFIG_NET_EMATCH is not set
# CONFIG_NET_CLS_ACT is not set
CONFIG_NET_CLS_IND=y
CONFIG_NET_SCH_FIFO=y
CONFIG_DCB=y
CONFIG_DNS_RESOLVER=y
CONFIG_BATMAN_ADV=y
# CONFIG_BATMAN_ADV_BLA is not set
CONFIG_BATMAN_ADV_DAT=y
# CONFIG_BATMAN_ADV_NC is not set
CONFIG_BATMAN_ADV_DEBUG=y
CONFIG_OPENVSWITCH=y
# CONFIG_VSOCKETS is not set
CONFIG_NETLINK_MMAP=y
CONFIG_NETLINK_DIAG=y
# CONFIG_NET_MPLS_GSO is not set
CONFIG_HSR=y
CONFIG_RPS=y
CONFIG_RFS_ACCEL=y
CONFIG_XPS=y
# CONFIG_NETPRIO_CGROUP is not set
CONFIG_NET_RX_BUSY_POLL=y
CONFIG_BQL=y
CONFIG_NET_FLOW_LIMIT=y

#
# Network testing
#
CONFIG_NET_PKTGEN=y
CONFIG_NET_DROP_MONITOR=y
# CONFIG_HAMRADIO is not set
CONFIG_CAN=y
# CONFIG_CAN_RAW is not set
CONFIG_CAN_BCM=y
CONFIG_CAN_GW=y

#
# CAN Device Drivers
#
# CONFIG_CAN_VCAN is not set
CONFIG_CAN_SLCAN=y
CONFIG_CAN_DEV=y
CONFIG_CAN_CALC_BITTIMING=y
CONFIG_CAN_LEDS=y
# CONFIG_PCH_CAN is not set
CONFIG_CAN_SJA1000=y
CONFIG_CAN_SJA1000_ISA=y
CONFIG_CAN_SJA1000_PLATFORM=y
CONFIG_CAN_EMS_PCMCIA=y
# CONFIG_CAN_EMS_PCI is not set
CONFIG_CAN_PEAK_PCMCIA=y
# CONFIG_CAN_PEAK_PCI is not set
# CONFIG_CAN_KVASER_PCI is not set
# CONFIG_CAN_PLX_PCI is not set
# CONFIG_CAN_C_CAN is not set
CONFIG_CAN_CC770=y
# CONFIG_CAN_CC770_ISA is not set
CONFIG_CAN_CC770_PLATFORM=y
# CONFIG_CAN_SOFTING is not set
# CONFIG_CAN_DEBUG_DEVICES is not set
CONFIG_IRDA=y

#
# IrDA protocols
#
CONFIG_IRLAN=y
CONFIG_IRCOMM=y
CONFIG_IRDA_ULTRA=y

#
# IrDA options
#
# CONFIG_IRDA_CACHE_LAST_LSAP is not set
# CONFIG_IRDA_FAST_RR is not set
CONFIG_IRDA_DEBUG=y

#
# Infrared-port device drivers
#

#
# SIR device drivers
#
CONFIG_IRTTY_SIR=y

#
# Dongle support
#
CONFIG_DONGLE=y
CONFIG_ESI_DONGLE=y
# CONFIG_ACTISYS_DONGLE is not set
# CONFIG_TEKRAM_DONGLE is not set
# CONFIG_TOIM3232_DONGLE is not set
# CONFIG_LITELINK_DONGLE is not set
CONFIG_MA600_DONGLE=y
# CONFIG_GIRBIL_DONGLE is not set
CONFIG_MCP2120_DONGLE=y
CONFIG_OLD_BELKIN_DONGLE=y
# CONFIG_ACT200L_DONGLE is not set

#
# FIR device drivers
#
CONFIG_NSC_FIR=y
CONFIG_WINBOND_FIR=y
# CONFIG_TOSHIBA_FIR is not set
CONFIG_SMC_IRCC_FIR=y
# CONFIG_ALI_FIR is not set
# CONFIG_VLSI_FIR is not set
# CONFIG_VIA_FIR is not set
CONFIG_BT=y
CONFIG_BT_RFCOMM=y
# CONFIG_BT_RFCOMM_TTY is not set
# CONFIG_BT_BNEP is not set
# CONFIG_BT_HIDP is not set

#
# Bluetooth device drivers
#
# CONFIG_BT_HCIBTSDIO is not set
CONFIG_BT_HCIUART=y
# CONFIG_BT_HCIUART_H4 is not set
# CONFIG_BT_HCIUART_BCSP is not set
# CONFIG_BT_HCIUART_ATH3K is not set
# CONFIG_BT_HCIUART_LL is not set
# CONFIG_BT_HCIUART_3WIRE is not set
CONFIG_BT_HCIDTL1=y
CONFIG_BT_HCIBT3C=y
# CONFIG_BT_HCIBLUECARD is not set
CONFIG_BT_HCIBTUART=y
CONFIG_BT_HCIVHCI=y
CONFIG_BT_MRVL=y
CONFIG_BT_MRVL_SDIO=y
CONFIG_BT_WILINK=y
CONFIG_AF_RXRPC=y
# CONFIG_AF_RXRPC_DEBUG is not set
# CONFIG_RXKAD is not set
CONFIG_FIB_RULES=y
CONFIG_WIRELESS=y
# CONFIG_CFG80211 is not set
# CONFIG_LIB80211 is not set

#
# CFG80211 needs to be enabled for MAC80211
#
# CONFIG_WIMAX is not set
# CONFIG_RFKILL is not set
CONFIG_RFKILL_REGULATOR=y
# CONFIG_NET_9P is not set
# CONFIG_CAIF is not set
CONFIG_CEPH_LIB=y
# CONFIG_CEPH_LIB_PRETTYDEBUG is not set
# CONFIG_CEPH_LIB_USE_DNS_RESOLVER is not set
# CONFIG_NFC is not set

#
# Device Drivers
#

#
# Generic Driver Options
#
CONFIG_UEVENT_HELPER_PATH=""
CONFIG_DEVTMPFS=y
# CONFIG_DEVTMPFS_MOUNT is not set
# CONFIG_STANDALONE is not set
# CONFIG_PREVENT_FIRMWARE_BUILD is not set
CONFIG_FW_LOADER=y
CONFIG_FIRMWARE_IN_KERNEL=y
CONFIG_EXTRA_FIRMWARE=""
CONFIG_FW_LOADER_USER_HELPER=y
# CONFIG_DEBUG_DRIVER is not set
# CONFIG_DEBUG_DEVRES is not set
# CONFIG_SYS_HYPERVISOR is not set
# CONFIG_GENERIC_CPU_DEVICES is not set
CONFIG_REGMAP=y
CONFIG_REGMAP_I2C=y
CONFIG_REGMAP_MMIO=y
CONFIG_REGMAP_IRQ=y
CONFIG_DMA_SHARED_BUFFER=y
# CONFIG_FENCE_TRACE is not set

#
# Bus devices
#
# CONFIG_CONNECTOR is not set
CONFIG_MTD=y
# CONFIG_MTD_REDBOOT_PARTS is not set
CONFIG_MTD_CMDLINE_PARTS=y
# CONFIG_MTD_AR7_PARTS is not set

#
# User Modules And Translation Layers
#
CONFIG_MTD_BLKDEVS=y
CONFIG_MTD_BLOCK=y
CONFIG_FTL=y
CONFIG_NFTL=y
CONFIG_NFTL_RW=y
CONFIG_INFTL=y
# CONFIG_RFD_FTL is not set
CONFIG_SSFDC=y
# CONFIG_SM_FTL is not set
CONFIG_MTD_OOPS=y
CONFIG_MTD_SWAP=y

#
# RAM/ROM/Flash chip drivers
#
# CONFIG_MTD_CFI is not set
CONFIG_MTD_JEDECPROBE=y
CONFIG_MTD_GEN_PROBE=y
# CONFIG_MTD_CFI_ADV_OPTIONS is not set
CONFIG_MTD_MAP_BANK_WIDTH_1=y
CONFIG_MTD_MAP_BANK_WIDTH_2=y
CONFIG_MTD_MAP_BANK_WIDTH_4=y
# CONFIG_MTD_MAP_BANK_WIDTH_8 is not set
# CONFIG_MTD_MAP_BANK_WIDTH_16 is not set
# CONFIG_MTD_MAP_BANK_WIDTH_32 is not set
CONFIG_MTD_CFI_I1=y
CONFIG_MTD_CFI_I2=y
# CONFIG_MTD_CFI_I4 is not set
# CONFIG_MTD_CFI_I8 is not set
CONFIG_MTD_CFI_INTELEXT=y
CONFIG_MTD_CFI_AMDSTD=y
CONFIG_MTD_CFI_STAA=y
CONFIG_MTD_CFI_UTIL=y
CONFIG_MTD_RAM=y
CONFIG_MTD_ROM=y
# CONFIG_MTD_ABSENT is not set

#
# Mapping drivers for chip access
#
CONFIG_MTD_COMPLEX_MAPPINGS=y
CONFIG_MTD_PHYSMAP=y
# CONFIG_MTD_PHYSMAP_COMPAT is not set
CONFIG_MTD_TS5500=y
CONFIG_MTD_SBC_GXX=y
CONFIG_MTD_AMD76XROM=y
CONFIG_MTD_ICHXROM=y
# CONFIG_MTD_ESB2ROM is not set
# CONFIG_MTD_CK804XROM is not set
# CONFIG_MTD_SCB2_FLASH is not set
# CONFIG_MTD_NETtel is not set
CONFIG_MTD_L440GX=y
# CONFIG_MTD_PCI is not set
CONFIG_MTD_PCMCIA=y
CONFIG_MTD_PCMCIA_ANONYMOUS=y
# CONFIG_MTD_GPIO_ADDR is not set
# CONFIG_MTD_INTEL_VR_NOR is not set
# CONFIG_MTD_PLATRAM is not set
CONFIG_MTD_LATCH_ADDR=y

#
# Self-contained MTD device drivers
#
# CONFIG_MTD_PMC551 is not set
CONFIG_MTD_SLRAM=y
CONFIG_MTD_PHRAM=y
# CONFIG_MTD_MTDRAM is not set
CONFIG_MTD_BLOCK2MTD=y

#
# Disk-On-Chip Device Drivers
#
# CONFIG_MTD_DOCG3 is not set
# CONFIG_MTD_NAND is not set
CONFIG_MTD_ONENAND=y
CONFIG_MTD_ONENAND_VERIFY_WRITE=y
CONFIG_MTD_ONENAND_GENERIC=y
CONFIG_MTD_ONENAND_OTP=y
# CONFIG_MTD_ONENAND_2X_PROGRAM is not set

#
# LPDDR flash memory drivers
#
# CONFIG_MTD_LPDDR is not set
CONFIG_MTD_UBI=y
CONFIG_MTD_UBI_WL_THRESHOLD=4096
CONFIG_MTD_UBI_BEB_LIMIT=20
# CONFIG_MTD_UBI_FASTMAP is not set
CONFIG_MTD_UBI_GLUEBI=y
CONFIG_PARPORT=y
CONFIG_ARCH_MIGHT_HAVE_PC_PARPORT=y
CONFIG_PARPORT_PC=y
# CONFIG_PARPORT_SERIAL is not set
CONFIG_PARPORT_PC_FIFO=y
CONFIG_PARPORT_PC_SUPERIO=y
CONFIG_PARPORT_PC_PCMCIA=y
# CONFIG_PARPORT_GSC is not set
CONFIG_PARPORT_AX88796=y
CONFIG_PARPORT_1284=y
CONFIG_PARPORT_NOT_PC=y
CONFIG_PNP=y
CONFIG_PNP_DEBUG_MESSAGES=y

#
# Protocols
#
CONFIG_PNPACPI=y
CONFIG_BLK_DEV=y
# CONFIG_BLK_DEV_NULL_BLK is not set
# CONFIG_BLK_DEV_FD is not set
# CONFIG_PARIDE is not set
# CONFIG_BLK_DEV_PCIESSD_MTIP32XX is not set
# CONFIG_BLK_CPQ_CISS_DA is not set
# CONFIG_BLK_DEV_DAC960 is not set
# CONFIG_BLK_DEV_UMEM is not set
# CONFIG_BLK_DEV_COW_COMMON is not set
# CONFIG_BLK_DEV_LOOP is not set
# CONFIG_BLK_DEV_DRBD is not set
# CONFIG_BLK_DEV_NBD is not set
# CONFIG_BLK_DEV_NVME is not set
# CONFIG_BLK_DEV_SX8 is not set
# CONFIG_BLK_DEV_RAM is not set
# CONFIG_CDROM_PKTCDVD is not set
# CONFIG_ATA_OVER_ETH is not set
# CONFIG_VIRTIO_BLK is not set
# CONFIG_BLK_DEV_HD is not set
# CONFIG_BLK_DEV_RBD is not set
# CONFIG_BLK_DEV_RSXX is not set

#
# Misc devices
#
# CONFIG_SENSORS_LIS3LV02D is not set
# CONFIG_AD525X_DPOT is not set
CONFIG_DUMMY_IRQ=y
# CONFIG_IBM_ASM is not set
# CONFIG_PHANTOM is not set
# CONFIG_SGI_IOC4 is not set
# CONFIG_TIFM_CORE is not set
CONFIG_ICS932S401=y
# CONFIG_ATMEL_SSC is not set
# CONFIG_ENCLOSURE_SERVICES is not set
# CONFIG_HP_ILO is not set
# CONFIG_APDS9802ALS is not set
CONFIG_ISL29003=y
CONFIG_ISL29020=y
CONFIG_SENSORS_TSL2550=y
# CONFIG_SENSORS_BH1780 is not set
CONFIG_SENSORS_BH1770=y
# CONFIG_SENSORS_APDS990X is not set
CONFIG_HMC6352=y
# CONFIG_DS1682 is not set
CONFIG_VMWARE_BALLOON=y
CONFIG_BMP085=y
CONFIG_BMP085_I2C=y
# CONFIG_PCH_PHUB is not set
# CONFIG_USB_SWITCH_FSA9480 is not set
CONFIG_SRAM=y
CONFIG_C2PORT=y
CONFIG_C2PORT_DURAMAR_2150=y

#
# EEPROM support
#
CONFIG_EEPROM_AT24=y
CONFIG_EEPROM_LEGACY=y
CONFIG_EEPROM_MAX6875=y
CONFIG_EEPROM_93CX6=y
# CONFIG_CB710_CORE is not set

#
# Texas Instruments shared transport line discipline
#
CONFIG_TI_ST=y
# CONFIG_SENSORS_LIS3_I2C is not set

#
# Altera FPGA firmware download module
#
CONFIG_ALTERA_STAPL=y
# CONFIG_VMWARE_VMCI is not set

#
# Intel MIC Host Driver
#

#
# Intel MIC Card Driver
#
CONFIG_HAVE_IDE=y
# CONFIG_IDE is not set

#
# SCSI device support
#
CONFIG_SCSI_MOD=y
CONFIG_RAID_ATTRS=y
CONFIG_SCSI=y
CONFIG_SCSI_DMA=y
CONFIG_SCSI_TGT=y
CONFIG_SCSI_NETLINK=y
CONFIG_SCSI_PROC_FS=y

#
# SCSI support type (disk, tape, CD-ROM)
#
CONFIG_BLK_DEV_SD=y
# CONFIG_CHR_DEV_ST is not set
CONFIG_CHR_DEV_OSST=y
CONFIG_BLK_DEV_SR=y
# CONFIG_BLK_DEV_SR_VENDOR is not set
CONFIG_CHR_DEV_SG=y
# CONFIG_CHR_DEV_SCH is not set
CONFIG_SCSI_MULTI_LUN=y
# CONFIG_SCSI_CONSTANTS is not set
CONFIG_SCSI_LOGGING=y
# CONFIG_SCSI_SCAN_ASYNC is not set

#
# SCSI Transports
#
CONFIG_SCSI_SPI_ATTRS=y
CONFIG_SCSI_FC_ATTRS=y
CONFIG_SCSI_FC_TGT_ATTRS=y
# CONFIG_SCSI_ISCSI_ATTRS is not set
CONFIG_SCSI_SAS_ATTRS=y
# CONFIG_SCSI_SAS_LIBSAS is not set
CONFIG_SCSI_SRP_ATTRS=y
CONFIG_SCSI_SRP_TGT_ATTRS=y
# CONFIG_SCSI_LOWLEVEL is not set
# CONFIG_SCSI_LOWLEVEL_PCMCIA is not set
CONFIG_SCSI_DH=y
CONFIG_SCSI_DH_RDAC=y
CONFIG_SCSI_DH_HP_SW=y
CONFIG_SCSI_DH_EMC=y
CONFIG_SCSI_DH_ALUA=y
CONFIG_SCSI_OSD_INITIATOR=y
# CONFIG_SCSI_OSD_ULD is not set
CONFIG_SCSI_OSD_DPRINT_SENSE=1
# CONFIG_SCSI_OSD_DEBUG is not set
# CONFIG_ATA is not set
CONFIG_MD=y
CONFIG_BLK_DEV_MD=y
# CONFIG_MD_AUTODETECT is not set
# CONFIG_MD_LINEAR is not set
CONFIG_MD_RAID0=y
CONFIG_MD_RAID1=y
CONFIG_MD_RAID10=y
# CONFIG_MD_RAID456 is not set
# CONFIG_MD_MULTIPATH is not set
# CONFIG_MD_FAULTY is not set
# CONFIG_BCACHE is not set
# CONFIG_BLK_DEV_DM is not set
CONFIG_TARGET_CORE=y
CONFIG_TCM_IBLOCK=y
# CONFIG_TCM_FILEIO is not set
CONFIG_TCM_PSCSI=y
CONFIG_LOOPBACK_TARGET=y
# CONFIG_ISCSI_TARGET is not set
# CONFIG_FUSION is not set

#
# IEEE 1394 (FireWire) support
#
# CONFIG_FIREWIRE is not set
# CONFIG_FIREWIRE_NOSY is not set
# CONFIG_I2O is not set
CONFIG_MACINTOSH_DRIVERS=y
# CONFIG_NETDEVICES is not set
# CONFIG_VHOST_NET is not set

#
# Input device support
#
CONFIG_INPUT=y
# CONFIG_INPUT_FF_MEMLESS is not set
# CONFIG_INPUT_POLLDEV is not set
# CONFIG_INPUT_SPARSEKMAP is not set
# CONFIG_INPUT_MATRIXKMAP is not set

#
# Userland interfaces
#
CONFIG_INPUT_MOUSEDEV=y
CONFIG_INPUT_MOUSEDEV_PSAUX=y
CONFIG_INPUT_MOUSEDEV_SCREEN_X=1024
CONFIG_INPUT_MOUSEDEV_SCREEN_Y=768
# CONFIG_INPUT_JOYDEV is not set
# CONFIG_INPUT_EVDEV is not set
# CONFIG_INPUT_EVBUG is not set

#
# Input Device Drivers
#
CONFIG_INPUT_KEYBOARD=y
# CONFIG_KEYBOARD_ADP5588 is not set
# CONFIG_KEYBOARD_ADP5589 is not set
CONFIG_KEYBOARD_ATKBD=y
# CONFIG_KEYBOARD_QT1070 is not set
# CONFIG_KEYBOARD_QT2160 is not set
# CONFIG_KEYBOARD_LKKBD is not set
# CONFIG_KEYBOARD_GPIO is not set
# CONFIG_KEYBOARD_GPIO_POLLED is not set
# CONFIG_KEYBOARD_TCA6416 is not set
# CONFIG_KEYBOARD_TCA8418 is not set
# CONFIG_KEYBOARD_MATRIX is not set
# CONFIG_KEYBOARD_LM8323 is not set
# CONFIG_KEYBOARD_LM8333 is not set
# CONFIG_KEYBOARD_MAX7359 is not set
# CONFIG_KEYBOARD_MCS is not set
# CONFIG_KEYBOARD_MPR121 is not set
# CONFIG_KEYBOARD_NEWTON is not set
# CONFIG_KEYBOARD_OPENCORES is not set
# CONFIG_KEYBOARD_GOLDFISH_EVENTS is not set
# CONFIG_KEYBOARD_STOWAWAY is not set
# CONFIG_KEYBOARD_SUNKBD is not set
# CONFIG_KEYBOARD_STMPE is not set
# CONFIG_KEYBOARD_TWL4030 is not set
# CONFIG_KEYBOARD_XTKBD is not set
# CONFIG_KEYBOARD_CROS_EC is not set
CONFIG_INPUT_MOUSE=y
CONFIG_MOUSE_PS2=y
CONFIG_MOUSE_PS2_ALPS=y
CONFIG_MOUSE_PS2_LOGIPS2PP=y
CONFIG_MOUSE_PS2_SYNAPTICS=y
CONFIG_MOUSE_PS2_CYPRESS=y
CONFIG_MOUSE_PS2_LIFEBOOK=y
CONFIG_MOUSE_PS2_TRACKPOINT=y
# CONFIG_MOUSE_PS2_ELANTECH is not set
# CONFIG_MOUSE_PS2_SENTELIC is not set
# CONFIG_MOUSE_PS2_TOUCHKIT is not set
# CONFIG_MOUSE_SERIAL is not set
# CONFIG_MOUSE_APPLETOUCH is not set
# CONFIG_MOUSE_BCM5974 is not set
# CONFIG_MOUSE_CYAPA is not set
# CONFIG_MOUSE_VSXXXAA is not set
# CONFIG_MOUSE_GPIO is not set
# CONFIG_MOUSE_SYNAPTICS_I2C is not set
# CONFIG_MOUSE_SYNAPTICS_USB is not set
# CONFIG_INPUT_JOYSTICK is not set
# CONFIG_INPUT_TABLET is not set
# CONFIG_INPUT_TOUCHSCREEN is not set
# CONFIG_INPUT_MISC is not set

#
# Hardware I/O ports
#
CONFIG_SERIO=y
CONFIG_SERIO_I8042=y
# CONFIG_SERIO_SERPORT is not set
# CONFIG_SERIO_CT82C710 is not set
# CONFIG_SERIO_PARKBD is not set
# CONFIG_SERIO_PCIPS2 is not set
CONFIG_SERIO_LIBPS2=y
CONFIG_SERIO_RAW=y
CONFIG_SERIO_ALTERA_PS2=y
# CONFIG_SERIO_PS2MULT is not set
# CONFIG_SERIO_ARC_PS2 is not set
# CONFIG_GAMEPORT is not set

#
# Character devices
#
CONFIG_TTY=y
# CONFIG_VT is not set
# CONFIG_UNIX98_PTYS is not set
CONFIG_LEGACY_PTYS=y
CONFIG_LEGACY_PTY_COUNT=256
# CONFIG_SERIAL_NONSTANDARD is not set
# CONFIG_NOZOMI is not set
CONFIG_N_GSM=y
# CONFIG_TRACE_ROUTER is not set
CONFIG_TRACE_SINK=y
CONFIG_GOLDFISH_TTY=y
# CONFIG_DEVKMEM is not set

#
# Serial drivers
#
CONFIG_SERIAL_8250=y
CONFIG_SERIAL_8250_DEPRECATED_OPTIONS=y
CONFIG_SERIAL_8250_PNP=y
CONFIG_SERIAL_8250_CONSOLE=y
CONFIG_FIX_EARLYCON_MEM=y
# CONFIG_SERIAL_8250_DMA is not set
CONFIG_SERIAL_8250_PCI=y
CONFIG_SERIAL_8250_CS=y
CONFIG_SERIAL_8250_NR_UARTS=4
CONFIG_SERIAL_8250_RUNTIME_UARTS=4
CONFIG_SERIAL_8250_EXTENDED=y
CONFIG_SERIAL_8250_MANY_PORTS=y
# CONFIG_SERIAL_8250_SHARE_IRQ is not set
CONFIG_SERIAL_8250_DETECT_IRQ=y
# CONFIG_SERIAL_8250_RSA is not set
CONFIG_SERIAL_8250_DW=y

#
# Non-8250 serial port support
#
# CONFIG_SERIAL_MFD_HSU is not set
CONFIG_SERIAL_CORE=y
CONFIG_SERIAL_CORE_CONSOLE=y
# CONFIG_SERIAL_JSM is not set
CONFIG_SERIAL_SCCNXP=y
# CONFIG_SERIAL_SCCNXP_CONSOLE is not set
# CONFIG_SERIAL_TIMBERDALE is not set
CONFIG_SERIAL_ALTERA_JTAGUART=y
CONFIG_SERIAL_ALTERA_JTAGUART_CONSOLE=y
CONFIG_SERIAL_ALTERA_JTAGUART_CONSOLE_BYPASS=y
CONFIG_SERIAL_ALTERA_UART=y
CONFIG_SERIAL_ALTERA_UART_MAXPORTS=4
CONFIG_SERIAL_ALTERA_UART_BAUDRATE=115200
# CONFIG_SERIAL_ALTERA_UART_CONSOLE is not set
# CONFIG_SERIAL_PCH_UART is not set
CONFIG_SERIAL_ARC=y
CONFIG_SERIAL_ARC_CONSOLE=y
CONFIG_SERIAL_ARC_NR_PORTS=1
# CONFIG_SERIAL_RP2 is not set
CONFIG_SERIAL_FSL_LPUART=y
# CONFIG_SERIAL_FSL_LPUART_CONSOLE is not set
CONFIG_TTY_PRINTK=y
CONFIG_PRINTER=y
CONFIG_LP_CONSOLE=y
CONFIG_PPDEV=y
CONFIG_HVC_DRIVER=y
CONFIG_VIRTIO_CONSOLE=y
CONFIG_IPMI_HANDLER=y
# CONFIG_IPMI_PANIC_EVENT is not set
# CONFIG_IPMI_DEVICE_INTERFACE is not set
CONFIG_IPMI_SI=y
CONFIG_IPMI_WATCHDOG=y
# CONFIG_IPMI_POWEROFF is not set
# CONFIG_HW_RANDOM is not set
CONFIG_NVRAM=y
CONFIG_R3964=y
# CONFIG_APPLICOM is not set
# CONFIG_SONYPI is not set

#
# PCMCIA character devices
#
CONFIG_SYNCLINK_CS=y
# CONFIG_CARDMAN_4000 is not set
# CONFIG_CARDMAN_4040 is not set
CONFIG_MWAVE=y
CONFIG_PC8736x_GPIO=y
CONFIG_NSC_GPIO=y
# CONFIG_RAW_DRIVER is not set
# CONFIG_HPET is not set
CONFIG_HANGCHECK_TIMER=y
CONFIG_TCG_TPM=y
CONFIG_TCG_TIS=y
# CONFIG_TCG_TIS_I2C_ATMEL is not set
# CONFIG_TCG_TIS_I2C_INFINEON is not set
# CONFIG_TCG_TIS_I2C_NUVOTON is not set
# CONFIG_TCG_NSC is not set
# CONFIG_TCG_ATMEL is not set
# CONFIG_TCG_INFINEON is not set
CONFIG_TCG_ST33_I2C=y
CONFIG_TELCLOCK=y
CONFIG_DEVPORT=y
CONFIG_I2C=y
CONFIG_I2C_BOARDINFO=y
# CONFIG_I2C_COMPAT is not set
CONFIG_I2C_CHARDEV=y
CONFIG_I2C_MUX=y

#
# Multiplexer I2C Chip support
#
CONFIG_I2C_MUX_GPIO=y
CONFIG_I2C_MUX_PCA9541=y
# CONFIG_I2C_MUX_PCA954x is not set
CONFIG_I2C_HELPER_AUTO=y
CONFIG_I2C_SMBUS=y
CONFIG_I2C_ALGOBIT=y
CONFIG_I2C_ALGOPCA=y

#
# I2C Hardware Bus support
#

#
# PC SMBus host controller drivers
#
# CONFIG_I2C_ALI1535 is not set
# CONFIG_I2C_ALI1563 is not set
# CONFIG_I2C_ALI15X3 is not set
# CONFIG_I2C_AMD756 is not set
# CONFIG_I2C_AMD8111 is not set
# CONFIG_I2C_I801 is not set
# CONFIG_I2C_ISCH is not set
# CONFIG_I2C_ISMT is not set
# CONFIG_I2C_PIIX4 is not set
# CONFIG_I2C_NFORCE2 is not set
# CONFIG_I2C_SIS5595 is not set
# CONFIG_I2C_SIS630 is not set
# CONFIG_I2C_SIS96X is not set
# CONFIG_I2C_VIA is not set
# CONFIG_I2C_VIAPRO is not set

#
# ACPI drivers
#
# CONFIG_I2C_SCMI is not set

#
# I2C system bus drivers (mostly embedded / system-on-chip)
#
CONFIG_I2C_CBUS_GPIO=y
# CONFIG_I2C_DESIGNWARE_PCI is not set
# CONFIG_I2C_EG20T is not set
CONFIG_I2C_GPIO=y
CONFIG_I2C_KEMPLD=y
CONFIG_I2C_OCORES=y
CONFIG_I2C_PCA_PLATFORM=y
# CONFIG_I2C_PXA_PCI is not set
CONFIG_I2C_SIMTEC=y
CONFIG_I2C_XILINX=y

#
# External I2C/SMBus adapter drivers
#
# CONFIG_I2C_PARPORT is not set
CONFIG_I2C_PARPORT_LIGHT=y
# CONFIG_I2C_TAOS_EVM is not set

#
# Other I2C/SMBus bus drivers
#
# CONFIG_SCx200_ACB is not set
# CONFIG_I2C_DEBUG_CORE is not set
# CONFIG_I2C_DEBUG_ALGO is not set
# CONFIG_I2C_DEBUG_BUS is not set
# CONFIG_SPI is not set
CONFIG_HSI=y
CONFIG_HSI_BOARDINFO=y

#
# HSI clients
#
CONFIG_HSI_CHAR=y

#
# PPS support
#
CONFIG_PPS=y
# CONFIG_PPS_DEBUG is not set

#
# PPS clients support
#
CONFIG_PPS_CLIENT_KTIMER=y
# CONFIG_PPS_CLIENT_LDISC is not set
# CONFIG_PPS_CLIENT_PARPORT is not set
CONFIG_PPS_CLIENT_GPIO=y

#
# PPS generators support
#

#
# PTP clock support
#
CONFIG_PTP_1588_CLOCK=y

#
# Enable PHYLIB and NETWORK_PHY_TIMESTAMPING to see the additional clocks.
#
CONFIG_PTP_1588_CLOCK_PCH=y
CONFIG_ARCH_WANT_OPTIONAL_GPIOLIB=y
CONFIG_GPIOLIB=y
CONFIG_GPIO_DEVRES=y
CONFIG_GPIO_ACPI=y
# CONFIG_DEBUG_GPIO is not set
# CONFIG_GPIO_SYSFS is not set
CONFIG_GPIO_GENERIC=y
# CONFIG_GPIO_DA9052 is not set
CONFIG_GPIO_DA9055=y
CONFIG_GPIO_MAX730X=y

#
# Memory mapped GPIO drivers:
#
CONFIG_GPIO_GENERIC_PLATFORM=y
CONFIG_GPIO_IT8761E=y
# CONFIG_GPIO_F7188X is not set
# CONFIG_GPIO_TS5500 is not set
# CONFIG_GPIO_SCH is not set
# CONFIG_GPIO_ICH is not set
# CONFIG_GPIO_VX855 is not set
# CONFIG_GPIO_LYNXPOINT is not set

#
# I2C GPIO expanders:
#
CONFIG_GPIO_MAX7300=y
# CONFIG_GPIO_MAX732X is not set
CONFIG_GPIO_PCA953X=y
CONFIG_GPIO_PCA953X_IRQ=y
# CONFIG_GPIO_PCF857X is not set
# CONFIG_GPIO_RC5T583 is not set
# CONFIG_GPIO_SX150X is not set
CONFIG_GPIO_STMPE=y
CONFIG_GPIO_TPS65912=y
# CONFIG_GPIO_TWL4030 is not set
CONFIG_GPIO_WM831X=y
# CONFIG_GPIO_WM8350 is not set
# CONFIG_GPIO_ADP5588 is not set

#
# PCI GPIO expanders:
#
# CONFIG_GPIO_BT8XX is not set
# CONFIG_GPIO_AMD8111 is not set
# CONFIG_GPIO_INTEL_MID is not set
# CONFIG_GPIO_PCH is not set
# CONFIG_GPIO_ML_IOH is not set
# CONFIG_GPIO_RDC321X is not set

#
# SPI GPIO expanders:
#
CONFIG_GPIO_MCP23S08=y

#
# AC97 GPIO expanders:
#

#
# LPC GPIO expanders:
#
CONFIG_GPIO_KEMPLD=y

#
# MODULbus GPIO expanders:
#
# CONFIG_GPIO_TPS65910 is not set

#
# USB GPIO expanders:
#
CONFIG_W1=y

#
# 1-wire Bus Masters
#
# CONFIG_W1_MASTER_MATROX is not set
# CONFIG_W1_MASTER_DS2482 is not set
# CONFIG_W1_MASTER_DS1WM is not set
CONFIG_W1_MASTER_GPIO=y

#
# 1-wire Slaves
#
# CONFIG_W1_SLAVE_THERM is not set
# CONFIG_W1_SLAVE_SMEM is not set
# CONFIG_W1_SLAVE_DS2408 is not set
# CONFIG_W1_SLAVE_DS2413 is not set
CONFIG_W1_SLAVE_DS2423=y
# CONFIG_W1_SLAVE_DS2431 is not set
# CONFIG_W1_SLAVE_DS2433 is not set
CONFIG_W1_SLAVE_DS2760=y
CONFIG_W1_SLAVE_DS2780=y
CONFIG_W1_SLAVE_DS2781=y
CONFIG_W1_SLAVE_DS28E04=y
# CONFIG_W1_SLAVE_BQ27000 is not set
CONFIG_POWER_SUPPLY=y
CONFIG_POWER_SUPPLY_DEBUG=y
# CONFIG_PDA_POWER is not set
CONFIG_WM831X_BACKUP=y
# CONFIG_WM831X_POWER is not set
CONFIG_WM8350_POWER=y
CONFIG_TEST_POWER=y
CONFIG_BATTERY_DS2760=y
# CONFIG_BATTERY_DS2780 is not set
CONFIG_BATTERY_DS2781=y
CONFIG_BATTERY_DS2782=y
CONFIG_BATTERY_SBS=y
CONFIG_BATTERY_BQ27x00=y
# CONFIG_BATTERY_BQ27X00_I2C is not set
# CONFIG_BATTERY_BQ27X00_PLATFORM is not set
CONFIG_BATTERY_DA9030=y
CONFIG_BATTERY_DA9052=y
CONFIG_BATTERY_MAX17040=y
CONFIG_BATTERY_MAX17042=y
CONFIG_BATTERY_TWL4030_MADC=y
CONFIG_CHARGER_PCF50633=y
CONFIG_BATTERY_RX51=y
CONFIG_CHARGER_MAX8903=y
CONFIG_CHARGER_TWL4030=y
CONFIG_CHARGER_LP8727=y
CONFIG_CHARGER_GPIO=y
CONFIG_CHARGER_MAX8997=y
CONFIG_CHARGER_BQ2415X=y
# CONFIG_CHARGER_BQ24190 is not set
CONFIG_CHARGER_BQ24735=y
CONFIG_CHARGER_SMB347=y
# CONFIG_CHARGER_TPS65090 is not set
# CONFIG_BATTERY_GOLDFISH is not set
# CONFIG_POWER_RESET is not set
CONFIG_POWER_AVS=y
CONFIG_HWMON=y
CONFIG_HWMON_VID=y
# CONFIG_HWMON_DEBUG_CHIP is not set

#
# Native drivers
#
CONFIG_SENSORS_ABITUGURU=y
# CONFIG_SENSORS_ABITUGURU3 is not set
CONFIG_SENSORS_AD7414=y
CONFIG_SENSORS_AD7418=y
CONFIG_SENSORS_ADM1021=y
CONFIG_SENSORS_ADM1025=y
# CONFIG_SENSORS_ADM1026 is not set
# CONFIG_SENSORS_ADM1029 is not set
# CONFIG_SENSORS_ADM1031 is not set
CONFIG_SENSORS_ADM9240=y
# CONFIG_SENSORS_ADT7410 is not set
CONFIG_SENSORS_ADT7411=y
CONFIG_SENSORS_ADT7462=y
# CONFIG_SENSORS_ADT7470 is not set
# CONFIG_SENSORS_ADT7475 is not set
CONFIG_SENSORS_ASC7621=y
# CONFIG_SENSORS_K8TEMP is not set
# CONFIG_SENSORS_K10TEMP is not set
# CONFIG_SENSORS_FAM15H_POWER is not set
# CONFIG_SENSORS_ASB100 is not set
CONFIG_SENSORS_ATXP1=y
# CONFIG_SENSORS_DS620 is not set
# CONFIG_SENSORS_DS1621 is not set
CONFIG_SENSORS_DA9052_ADC=y
CONFIG_SENSORS_DA9055=y
# CONFIG_SENSORS_I5K_AMB is not set
CONFIG_SENSORS_F71805F=y
# CONFIG_SENSORS_F71882FG is not set
# CONFIG_SENSORS_F75375S is not set
CONFIG_SENSORS_FSCHMD=y
CONFIG_SENSORS_G760A=y
CONFIG_SENSORS_G762=y
CONFIG_SENSORS_GL518SM=y
CONFIG_SENSORS_GL520SM=y
CONFIG_SENSORS_GPIO_FAN=y
CONFIG_SENSORS_HIH6130=y
# CONFIG_SENSORS_HTU21 is not set
# CONFIG_SENSORS_CORETEMP is not set
CONFIG_SENSORS_IBMAEM=y
CONFIG_SENSORS_IBMPEX=y
CONFIG_SENSORS_IT87=y
CONFIG_SENSORS_JC42=y
CONFIG_SENSORS_LINEAGE=y
CONFIG_SENSORS_LM63=y
CONFIG_SENSORS_LM73=y
CONFIG_SENSORS_LM75=y
CONFIG_SENSORS_LM77=y
CONFIG_SENSORS_LM78=y
# CONFIG_SENSORS_LM80 is not set
# CONFIG_SENSORS_LM83 is not set
CONFIG_SENSORS_LM85=y
CONFIG_SENSORS_LM87=y
# CONFIG_SENSORS_LM90 is not set
# CONFIG_SENSORS_LM92 is not set
# CONFIG_SENSORS_LM93 is not set
CONFIG_SENSORS_LTC4151=y
CONFIG_SENSORS_LTC4215=y
CONFIG_SENSORS_LTC4245=y
CONFIG_SENSORS_LTC4261=y
# CONFIG_SENSORS_LM95234 is not set
# CONFIG_SENSORS_LM95241 is not set
CONFIG_SENSORS_LM95245=y
# CONFIG_SENSORS_MAX16065 is not set
CONFIG_SENSORS_MAX1619=y
CONFIG_SENSORS_MAX1668=y
# CONFIG_SENSORS_MAX197 is not set
# CONFIG_SENSORS_MAX6639 is not set
CONFIG_SENSORS_MAX6642=y
CONFIG_SENSORS_MAX6650=y
CONFIG_SENSORS_MAX6697=y
CONFIG_SENSORS_MCP3021=y
CONFIG_SENSORS_NCT6775=y
CONFIG_SENSORS_NTC_THERMISTOR=y
CONFIG_SENSORS_PC87360=y
# CONFIG_SENSORS_PC87427 is not set
CONFIG_SENSORS_PCF8591=y
CONFIG_PMBUS=y
# CONFIG_SENSORS_PMBUS is not set
CONFIG_SENSORS_ADM1275=y
# CONFIG_SENSORS_LM25066 is not set
CONFIG_SENSORS_LTC2978=y
# CONFIG_SENSORS_MAX16064 is not set
CONFIG_SENSORS_MAX34440=y
CONFIG_SENSORS_MAX8688=y
# CONFIG_SENSORS_UCD9000 is not set
CONFIG_SENSORS_UCD9200=y
CONFIG_SENSORS_ZL6100=y
# CONFIG_SENSORS_SHT15 is not set
# CONFIG_SENSORS_SHT21 is not set
# CONFIG_SENSORS_SIS5595 is not set
CONFIG_SENSORS_SMM665=y
CONFIG_SENSORS_DME1737=y
# CONFIG_SENSORS_EMC1403 is not set
CONFIG_SENSORS_EMC2103=y
# CONFIG_SENSORS_EMC6W201 is not set
CONFIG_SENSORS_SMSC47M1=y
# CONFIG_SENSORS_SMSC47M192 is not set
CONFIG_SENSORS_SMSC47B397=y
# CONFIG_SENSORS_SCH56XX_COMMON is not set
CONFIG_SENSORS_ADS1015=y
CONFIG_SENSORS_ADS7828=y
CONFIG_SENSORS_AMC6821=y
CONFIG_SENSORS_INA209=y
# CONFIG_SENSORS_INA2XX is not set
CONFIG_SENSORS_THMC50=y
CONFIG_SENSORS_TMP102=y
CONFIG_SENSORS_TMP401=y
# CONFIG_SENSORS_TMP421 is not set
CONFIG_SENSORS_TWL4030_MADC=y
# CONFIG_SENSORS_VIA_CPUTEMP is not set
# CONFIG_SENSORS_VIA686A is not set
# CONFIG_SENSORS_VT1211 is not set
# CONFIG_SENSORS_VT8231 is not set
CONFIG_SENSORS_W83781D=y
# CONFIG_SENSORS_W83791D is not set
CONFIG_SENSORS_W83792D=y
CONFIG_SENSORS_W83793=y
CONFIG_SENSORS_W83795=y
# CONFIG_SENSORS_W83795_FANCTRL is not set
# CONFIG_SENSORS_W83L785TS is not set
CONFIG_SENSORS_W83L786NG=y
CONFIG_SENSORS_W83627HF=y
CONFIG_SENSORS_W83627EHF=y
CONFIG_SENSORS_WM831X=y
# CONFIG_SENSORS_WM8350 is not set
# CONFIG_SENSORS_APPLESMC is not set
CONFIG_SENSORS_MC13783_ADC=y

#
# ACPI drivers
#
# CONFIG_SENSORS_ACPI_POWER is not set
# CONFIG_SENSORS_ATK0110 is not set
CONFIG_THERMAL=y
CONFIG_THERMAL_HWMON=y
CONFIG_THERMAL_DEFAULT_GOV_STEP_WISE=y
# CONFIG_THERMAL_DEFAULT_GOV_FAIR_SHARE is not set
# CONFIG_THERMAL_DEFAULT_GOV_USER_SPACE is not set
# CONFIG_THERMAL_GOV_FAIR_SHARE is not set
CONFIG_THERMAL_GOV_STEP_WISE=y
# CONFIG_THERMAL_GOV_USER_SPACE is not set
# CONFIG_CPU_THERMAL is not set
# CONFIG_THERMAL_EMULATION is not set

#
# Texas Instruments thermal drivers
#
# CONFIG_WATCHDOG is not set
CONFIG_SSB_POSSIBLE=y

#
# Sonics Silicon Backplane
#
CONFIG_SSB=y
CONFIG_SSB_SPROM=y
CONFIG_SSB_PCIHOST_POSSIBLE=y
CONFIG_SSB_PCIHOST=y
# CONFIG_SSB_B43_PCI_BRIDGE is not set
CONFIG_SSB_PCMCIAHOST_POSSIBLE=y
CONFIG_SSB_PCMCIAHOST=y
CONFIG_SSB_SDIOHOST_POSSIBLE=y
# CONFIG_SSB_SDIOHOST is not set
CONFIG_SSB_SILENT=y
CONFIG_SSB_DRIVER_PCICORE_POSSIBLE=y
# CONFIG_SSB_DRIVER_PCICORE is not set
# CONFIG_SSB_DRIVER_GPIO is not set
CONFIG_BCMA_POSSIBLE=y

#
# Broadcom specific AMBA
#
# CONFIG_BCMA is not set

#
# Multifunction device drivers
#
CONFIG_MFD_CORE=y
# CONFIG_MFD_CS5535 is not set
# CONFIG_MFD_AS3711 is not set
# CONFIG_PMIC_ADP5520 is not set
# CONFIG_MFD_AAT2870_CORE is not set
CONFIG_MFD_CROS_EC=y
CONFIG_MFD_CROS_EC_I2C=y
CONFIG_PMIC_DA903X=y
CONFIG_PMIC_DA9052=y
CONFIG_MFD_DA9052_I2C=y
CONFIG_MFD_DA9055=y
# CONFIG_MFD_DA9063 is not set
CONFIG_MFD_MC13783=y
CONFIG_MFD_MC13XXX=y
CONFIG_MFD_MC13XXX_I2C=y
CONFIG_HTC_PASIC3=y
# CONFIG_HTC_I2CPLD is not set
# CONFIG_LPC_ICH is not set
# CONFIG_LPC_SCH is not set
# CONFIG_MFD_JANZ_CMODIO is not set
CONFIG_MFD_KEMPLD=y
CONFIG_MFD_88PM800=y
CONFIG_MFD_88PM805=y
# CONFIG_MFD_88PM860X is not set
# CONFIG_MFD_MAX77686 is not set
CONFIG_MFD_MAX77693=y
CONFIG_MFD_MAX8907=y
# CONFIG_MFD_MAX8925 is not set
CONFIG_MFD_MAX8997=y
# CONFIG_MFD_MAX8998 is not set
CONFIG_MFD_RETU=y
CONFIG_MFD_PCF50633=y
# CONFIG_PCF50633_ADC is not set
CONFIG_PCF50633_GPIO=y
# CONFIG_MFD_RDC321X is not set
# CONFIG_MFD_RTSX_PCI is not set
CONFIG_MFD_RC5T583=y
CONFIG_MFD_SEC_CORE=y
# CONFIG_MFD_SI476X_CORE is not set
CONFIG_MFD_SM501=y
CONFIG_MFD_SM501_GPIO=y
CONFIG_MFD_SMSC=y
# CONFIG_ABX500_CORE is not set
CONFIG_MFD_STMPE=y

#
# STMicroelectronics STMPE Interface Drivers
#
# CONFIG_STMPE_I2C is not set
CONFIG_MFD_SYSCON=y
# CONFIG_MFD_TI_AM335X_TSCADC is not set
# CONFIG_MFD_LP8788 is not set
# CONFIG_MFD_PALMAS is not set
CONFIG_TPS6105X=y
# CONFIG_TPS65010 is not set
CONFIG_TPS6507X=y
CONFIG_MFD_TPS65090=y
CONFIG_MFD_TPS65217=y
# CONFIG_MFD_TPS6586X is not set
CONFIG_MFD_TPS65910=y
CONFIG_MFD_TPS65912=y
CONFIG_MFD_TPS65912_I2C=y
# CONFIG_MFD_TPS80031 is not set
CONFIG_TWL4030_CORE=y
CONFIG_TWL4030_MADC=y
CONFIG_MFD_TWL4030_AUDIO=y
# CONFIG_TWL6040_CORE is not set
# CONFIG_MFD_WL1273_CORE is not set
CONFIG_MFD_LM3533=y
# CONFIG_MFD_TIMBERDALE is not set
# CONFIG_MFD_TC3589X is not set
# CONFIG_MFD_TMIO is not set
# CONFIG_MFD_VX855 is not set
# CONFIG_MFD_ARIZONA_I2C is not set
CONFIG_MFD_WM8400=y
CONFIG_MFD_WM831X=y
CONFIG_MFD_WM831X_I2C=y
CONFIG_MFD_WM8350=y
CONFIG_MFD_WM8350_I2C=y
# CONFIG_MFD_WM8994 is not set
CONFIG_REGULATOR=y
# CONFIG_REGULATOR_DEBUG is not set
CONFIG_REGULATOR_FIXED_VOLTAGE=y
CONFIG_REGULATOR_VIRTUAL_CONSUMER=y
# CONFIG_REGULATOR_USERSPACE_CONSUMER is not set
CONFIG_REGULATOR_88PM800=y
CONFIG_REGULATOR_AD5398=y
CONFIG_REGULATOR_ANATOP=y
CONFIG_REGULATOR_DA903X=y
CONFIG_REGULATOR_DA9052=y
# CONFIG_REGULATOR_DA9055 is not set
CONFIG_REGULATOR_DA9210=y
# CONFIG_REGULATOR_FAN53555 is not set
# CONFIG_REGULATOR_GPIO is not set
CONFIG_REGULATOR_ISL6271A=y
# CONFIG_REGULATOR_LP3971 is not set
CONFIG_REGULATOR_LP3972=y
# CONFIG_REGULATOR_LP872X is not set
# CONFIG_REGULATOR_LP8755 is not set
# CONFIG_REGULATOR_MAX1586 is not set
# CONFIG_REGULATOR_MAX8649 is not set
CONFIG_REGULATOR_MAX8660=y
# CONFIG_REGULATOR_MAX8907 is not set
CONFIG_REGULATOR_MAX8952=y
CONFIG_REGULATOR_MAX8973=y
CONFIG_REGULATOR_MAX8997=y
CONFIG_REGULATOR_MAX77693=y
CONFIG_REGULATOR_MC13XXX_CORE=y
CONFIG_REGULATOR_MC13783=y
# CONFIG_REGULATOR_MC13892 is not set
CONFIG_REGULATOR_PCF50633=y
CONFIG_REGULATOR_PFUZE100=y
CONFIG_REGULATOR_RC5T583=y
# CONFIG_REGULATOR_S2MPS11 is not set
CONFIG_REGULATOR_S5M8767=y
CONFIG_REGULATOR_TPS51632=y
CONFIG_REGULATOR_TPS6105X=y
CONFIG_REGULATOR_TPS62360=y
CONFIG_REGULATOR_TPS65023=y
CONFIG_REGULATOR_TPS6507X=y
# CONFIG_REGULATOR_TPS65090 is not set
CONFIG_REGULATOR_TPS65217=y
CONFIG_REGULATOR_TPS65910=y
CONFIG_REGULATOR_TPS65912=y
CONFIG_REGULATOR_TWL4030=y
CONFIG_REGULATOR_WM831X=y
# CONFIG_REGULATOR_WM8350 is not set
# CONFIG_REGULATOR_WM8400 is not set
CONFIG_MEDIA_SUPPORT=y

#
# Multimedia core support
#
# CONFIG_MEDIA_CAMERA_SUPPORT is not set
# CONFIG_MEDIA_ANALOG_TV_SUPPORT is not set
CONFIG_MEDIA_DIGITAL_TV_SUPPORT=y
# CONFIG_MEDIA_RADIO_SUPPORT is not set
# CONFIG_MEDIA_RC_SUPPORT is not set
CONFIG_VIDEO_ADV_DEBUG=y
CONFIG_VIDEO_FIXED_MINOR_RANGES=y
CONFIG_DVB_CORE=y
# CONFIG_DVB_NET is not set
# CONFIG_TTPCI_EEPROM is not set
CONFIG_DVB_MAX_ADAPTERS=8
# CONFIG_DVB_DYNAMIC_MINORS is not set

#
# Media drivers
#
# CONFIG_MEDIA_PCI_SUPPORT is not set

#
# Supported MMC/SDIO adapters
#
# CONFIG_SMS_SDIO_DRV is not set

#
# Media ancillary drivers (tuners, sensors, i2c, frontends)
#
CONFIG_MEDIA_SUBDRV_AUTOSELECT=y

#
# Multistandard (satellite) frontends
#

#
# Multistandard (cable + terrestrial) frontends
#

#
# DVB-S (satellite) frontends
#

#
# DVB-T (terrestrial) frontends
#

#
# DVB-C (cable) frontends
#

#
# ATSC (North American/Korean Terrestrial/Cable DTV) frontends
#

#
# ISDB-T (terrestrial) frontends
#

#
# Digital terrestrial only tuners/PLL
#

#
# SEC control devices for DVB-S
#

#
# Tools to develop new frontends
#
# CONFIG_DVB_DUMMY_FE is not set

#
# Graphics support
#
# CONFIG_AGP is not set
CONFIG_VGA_ARB=y
CONFIG_VGA_ARB_MAX_GPUS=16
# CONFIG_VGA_SWITCHEROO is not set
CONFIG_DRM=y
# CONFIG_DRM_TDFX is not set
# CONFIG_DRM_R128 is not set
# CONFIG_DRM_RADEON is not set
# CONFIG_DRM_NOUVEAU is not set
# CONFIG_DRM_MGA is not set
# CONFIG_DRM_VIA is not set
# CONFIG_DRM_SAVAGE is not set
# CONFIG_DRM_GMA500 is not set
# CONFIG_DRM_UDL is not set
# CONFIG_DRM_AST is not set
# CONFIG_DRM_MGAG200 is not set
# CONFIG_DRM_CIRRUS_QEMU is not set
# CONFIG_DRM_QXL is not set
# CONFIG_VGASTATE is not set
CONFIG_VIDEO_OUTPUT_CONTROL=y
CONFIG_HDMI=y
# CONFIG_FB is not set
CONFIG_EXYNOS_VIDEO=y
CONFIG_BACKLIGHT_LCD_SUPPORT=y
CONFIG_LCD_CLASS_DEVICE=y
CONFIG_LCD_PLATFORM=y
CONFIG_BACKLIGHT_CLASS_DEVICE=y
CONFIG_BACKLIGHT_GENERIC=y
CONFIG_BACKLIGHT_LM3533=y
CONFIG_BACKLIGHT_DA903X=y
# CONFIG_BACKLIGHT_DA9052 is not set
# CONFIG_BACKLIGHT_APPLE is not set
# CONFIG_BACKLIGHT_SAHARA is not set
# CONFIG_BACKLIGHT_WM831X is not set
CONFIG_BACKLIGHT_ADP8860=y
CONFIG_BACKLIGHT_ADP8870=y
# CONFIG_BACKLIGHT_PCF50633 is not set
CONFIG_BACKLIGHT_LM3630A=y
CONFIG_BACKLIGHT_LM3639=y
# CONFIG_BACKLIGHT_LP855X is not set
CONFIG_BACKLIGHT_PANDORA=y
CONFIG_BACKLIGHT_TPS65217=y
# CONFIG_BACKLIGHT_GPIO is not set
CONFIG_BACKLIGHT_LV5207LP=y
CONFIG_BACKLIGHT_BD6107=y
CONFIG_SOUND=y
CONFIG_SOUND_OSS_CORE=y
# CONFIG_SOUND_OSS_CORE_PRECLAIM is not set
CONFIG_SND=y
CONFIG_SND_TIMER=y
CONFIG_SND_PCM=y
CONFIG_SND_SEQUENCER=y
CONFIG_SND_SEQ_DUMMY=y
CONFIG_SND_OSSEMUL=y
CONFIG_SND_MIXER_OSS=y
CONFIG_SND_PCM_OSS=y
CONFIG_SND_PCM_OSS_PLUGINS=y
CONFIG_SND_SEQUENCER_OSS=y
CONFIG_SND_DYNAMIC_MINORS=y
CONFIG_SND_MAX_CARDS=32
# CONFIG_SND_SUPPORT_OLD_API is not set
# CONFIG_SND_VERBOSE_PROCFS is not set
CONFIG_SND_VERBOSE_PRINTK=y
CONFIG_SND_DEBUG=y
CONFIG_SND_DEBUG_VERBOSE=y
CONFIG_SND_DMA_SGBUF=y
# CONFIG_SND_RAWMIDI_SEQ is not set
# CONFIG_SND_OPL3_LIB_SEQ is not set
# CONFIG_SND_OPL4_LIB_SEQ is not set
# CONFIG_SND_SBAWE_SEQ is not set
# CONFIG_SND_EMU10K1_SEQ is not set
# CONFIG_SND_DRIVERS is not set
CONFIG_SND_PCI=y
# CONFIG_SND_AD1889 is not set
# CONFIG_SND_ALS300 is not set
# CONFIG_SND_ALS4000 is not set
# CONFIG_SND_ALI5451 is not set
# CONFIG_SND_ASIHPI is not set
# CONFIG_SND_ATIIXP is not set
# CONFIG_SND_ATIIXP_MODEM is not set
# CONFIG_SND_AU8810 is not set
# CONFIG_SND_AU8820 is not set
# CONFIG_SND_AU8830 is not set
# CONFIG_SND_AW2 is not set
# CONFIG_SND_AZT3328 is not set
# CONFIG_SND_BT87X is not set
# CONFIG_SND_CA0106 is not set
# CONFIG_SND_CMIPCI is not set
# CONFIG_SND_OXYGEN is not set
# CONFIG_SND_CS4281 is not set
# CONFIG_SND_CS46XX is not set
# CONFIG_SND_CS5530 is not set
# CONFIG_SND_CS5535AUDIO is not set
# CONFIG_SND_CTXFI is not set
# CONFIG_SND_DARLA20 is not set
# CONFIG_SND_GINA20 is not set
# CONFIG_SND_LAYLA20 is not set
# CONFIG_SND_DARLA24 is not set
# CONFIG_SND_GINA24 is not set
# CONFIG_SND_LAYLA24 is not set
# CONFIG_SND_MONA is not set
# CONFIG_SND_MIA is not set
# CONFIG_SND_ECHO3G is not set
# CONFIG_SND_INDIGO is not set
# CONFIG_SND_INDIGOIO is not set
# CONFIG_SND_INDIGODJ is not set
# CONFIG_SND_INDIGOIOX is not set
# CONFIG_SND_INDIGODJX is not set
# CONFIG_SND_EMU10K1 is not set
# CONFIG_SND_EMU10K1X is not set
# CONFIG_SND_ENS1370 is not set
# CONFIG_SND_ENS1371 is not set
# CONFIG_SND_ES1938 is not set
# CONFIG_SND_ES1968 is not set
# CONFIG_SND_FM801 is not set
# CONFIG_SND_HDA_INTEL is not set
# CONFIG_SND_HDSP is not set
# CONFIG_SND_HDSPM is not set
# CONFIG_SND_ICE1712 is not set
# CONFIG_SND_ICE1724 is not set
# CONFIG_SND_INTEL8X0 is not set
# CONFIG_SND_INTEL8X0M is not set
# CONFIG_SND_KORG1212 is not set
# CONFIG_SND_LOLA is not set
# CONFIG_SND_LX6464ES is not set
# CONFIG_SND_MAESTRO3 is not set
# CONFIG_SND_MIXART is not set
# CONFIG_SND_NM256 is not set
# CONFIG_SND_PCXHR is not set
# CONFIG_SND_RIPTIDE is not set
# CONFIG_SND_RME32 is not set
# CONFIG_SND_RME96 is not set
# CONFIG_SND_RME9652 is not set
# CONFIG_SND_SIS7019 is not set
# CONFIG_SND_SONICVIBES is not set
# CONFIG_SND_TRIDENT is not set
# CONFIG_SND_VIA82XX is not set
# CONFIG_SND_VIA82XX_MODEM is not set
# CONFIG_SND_VIRTUOSO is not set
# CONFIG_SND_VX222 is not set
# CONFIG_SND_YMFPCI is not set
CONFIG_SND_PCMCIA=y
# CONFIG_SND_VXPOCKET is not set
CONFIG_SND_PDAUDIOCF=y
# CONFIG_SND_SOC is not set
# CONFIG_SOUND_PRIME is not set

#
# HID support
#
CONFIG_HID=y
# CONFIG_HID_BATTERY_STRENGTH is not set
# CONFIG_HIDRAW is not set
# CONFIG_UHID is not set
CONFIG_HID_GENERIC=y

#
# Special HID drivers
#
# CONFIG_HID_A4TECH is not set
# CONFIG_HID_ACRUX is not set
# CONFIG_HID_APPLE is not set
# CONFIG_HID_AUREAL is not set
# CONFIG_HID_BELKIN is not set
# CONFIG_HID_CHERRY is not set
# CONFIG_HID_CHICONY is not set
# CONFIG_HID_PRODIKEYS is not set
# CONFIG_HID_CYPRESS is not set
# CONFIG_HID_DRAGONRISE is not set
# CONFIG_HID_EMS_FF is not set
# CONFIG_HID_ELECOM is not set
# CONFIG_HID_EZKEY is not set
# CONFIG_HID_KEYTOUCH is not set
# CONFIG_HID_KYE is not set
# CONFIG_HID_UCLOGIC is not set
# CONFIG_HID_WALTOP is not set
# CONFIG_HID_GYRATION is not set
# CONFIG_HID_ICADE is not set
# CONFIG_HID_TWINHAN is not set
# CONFIG_HID_KENSINGTON is not set
# CONFIG_HID_LCPOWER is not set
# CONFIG_HID_LENOVO_TPKBD is not set
# CONFIG_HID_LOGITECH is not set
# CONFIG_HID_MAGICMOUSE is not set
# CONFIG_HID_MICROSOFT is not set
# CONFIG_HID_MONTEREY is not set
# CONFIG_HID_MULTITOUCH is not set
# CONFIG_HID_ORTEK is not set
# CONFIG_HID_PANTHERLORD is not set
# CONFIG_HID_PETALYNX is not set
# CONFIG_HID_PICOLCD is not set
# CONFIG_HID_PRIMAX is not set
# CONFIG_HID_SAITEK is not set
# CONFIG_HID_SAMSUNG is not set
# CONFIG_HID_SPEEDLINK is not set
# CONFIG_HID_STEELSERIES is not set
# CONFIG_HID_SUNPLUS is not set
# CONFIG_HID_GREENASIA is not set
# CONFIG_HID_SMARTJOYPLUS is not set
# CONFIG_HID_TIVO is not set
# CONFIG_HID_TOPSEED is not set
# CONFIG_HID_THINGM is not set
# CONFIG_HID_THRUSTMASTER is not set
# CONFIG_HID_WACOM is not set
# CONFIG_HID_WIIMOTE is not set
# CONFIG_HID_XINMO is not set
# CONFIG_HID_ZEROPLUS is not set
# CONFIG_HID_ZYDACRON is not set
# CONFIG_HID_SENSOR_HUB is not set

#
# I2C HID support
#
# CONFIG_I2C_HID is not set
CONFIG_USB_OHCI_LITTLE_ENDIAN=y
CONFIG_USB_SUPPORT=y
CONFIG_USB_ARCH_HAS_HCD=y
# CONFIG_USB is not set

#
# USB port drivers
#

#
# USB Physical Layer drivers
#
# CONFIG_USB_PHY is not set
# CONFIG_NOP_USB_XCEIV is not set
# CONFIG_SAMSUNG_USB2PHY is not set
# CONFIG_SAMSUNG_USB3PHY is not set
# CONFIG_USB_GPIO_VBUS is not set
# CONFIG_USB_GADGET is not set
# CONFIG_UWB is not set
CONFIG_MMC=y
CONFIG_MMC_DEBUG=y
# CONFIG_MMC_UNSAFE_RESUME is not set
CONFIG_MMC_CLKGATE=y

#
# MMC/SD/SDIO Card Drivers
#
CONFIG_MMC_BLOCK=y
CONFIG_MMC_BLOCK_MINORS=8
# CONFIG_MMC_BLOCK_BOUNCE is not set
CONFIG_SDIO_UART=y
# CONFIG_MMC_TEST is not set

#
# MMC/SD/SDIO Host Controller Drivers
#
CONFIG_MMC_SDHCI=y
# CONFIG_MMC_SDHCI_PCI is not set
# CONFIG_MMC_SDHCI_ACPI is not set
CONFIG_MMC_SDHCI_PLTFM=y
CONFIG_MMC_WBSD=y
# CONFIG_MMC_TIFM_SD is not set
# CONFIG_MMC_GOLDFISH is not set
# CONFIG_MMC_SDRICOH_CS is not set
# CONFIG_MMC_CB710 is not set
# CONFIG_MMC_VIA_SDMMC is not set
CONFIG_MEMSTICK=y
CONFIG_MEMSTICK_DEBUG=y

#
# MemoryStick drivers
#
# CONFIG_MEMSTICK_UNSAFE_RESUME is not set
CONFIG_MSPRO_BLOCK=y
CONFIG_MS_BLOCK=y

#
# MemoryStick Host Controller Drivers
#
# CONFIG_MEMSTICK_TIFM_MS is not set
# CONFIG_MEMSTICK_JMICRON_38X is not set
# CONFIG_MEMSTICK_R592 is not set
CONFIG_NEW_LEDS=y
CONFIG_LEDS_CLASS=y

#
# LED drivers
#
# CONFIG_LEDS_LM3530 is not set
CONFIG_LEDS_LM3533=y
CONFIG_LEDS_LM3642=y
# CONFIG_LEDS_PCA9532 is not set
# CONFIG_LEDS_GPIO is not set
CONFIG_LEDS_LP3944=y
CONFIG_LEDS_LP55XX_COMMON=y
# CONFIG_LEDS_LP5521 is not set
# CONFIG_LEDS_LP5523 is not set
CONFIG_LEDS_LP5562=y
CONFIG_LEDS_LP8501=y
CONFIG_LEDS_CLEVO_MAIL=y
CONFIG_LEDS_PCA955X=y
# CONFIG_LEDS_PCA963X is not set
CONFIG_LEDS_PCA9685=y
CONFIG_LEDS_WM831X_STATUS=y
CONFIG_LEDS_WM8350=y
CONFIG_LEDS_DA903X=y
CONFIG_LEDS_DA9052=y
CONFIG_LEDS_REGULATOR=y
CONFIG_LEDS_BD2802=y
# CONFIG_LEDS_INTEL_SS4200 is not set
# CONFIG_LEDS_LT3593 is not set
CONFIG_LEDS_MC13783=y
CONFIG_LEDS_TCA6507=y
# CONFIG_LEDS_MAX8997 is not set
# CONFIG_LEDS_LM355x is not set
# CONFIG_LEDS_OT200 is not set
CONFIG_LEDS_BLINKM=y

#
# LED Triggers
#
CONFIG_LEDS_TRIGGERS=y
CONFIG_LEDS_TRIGGER_TIMER=y
CONFIG_LEDS_TRIGGER_ONESHOT=y
# CONFIG_LEDS_TRIGGER_HEARTBEAT is not set
CONFIG_LEDS_TRIGGER_BACKLIGHT=y
CONFIG_LEDS_TRIGGER_CPU=y
# CONFIG_LEDS_TRIGGER_GPIO is not set
CONFIG_LEDS_TRIGGER_DEFAULT_ON=y

#
# iptables trigger is under Netfilter config (LED target)
#
CONFIG_LEDS_TRIGGER_TRANSIENT=y
CONFIG_LEDS_TRIGGER_CAMERA=y
CONFIG_ACCESSIBILITY=y
# CONFIG_INFINIBAND is not set
CONFIG_EDAC=y
# CONFIG_EDAC_LEGACY_SYSFS is not set
CONFIG_EDAC_DEBUG=y
# CONFIG_EDAC_MM_EDAC is not set
CONFIG_RTC_LIB=y
# CONFIG_RTC_CLASS is not set
CONFIG_DMADEVICES=y
# CONFIG_DMADEVICES_DEBUG is not set

#
# DMA Devices
#
# CONFIG_INTEL_MID_DMAC is not set
# CONFIG_INTEL_IOATDMA is not set
CONFIG_DW_DMAC_CORE=y
CONFIG_DW_DMAC=y
# CONFIG_DW_DMAC_PCI is not set
# CONFIG_TIMB_DMA is not set
# CONFIG_PCH_DMA is not set
CONFIG_DMA_ENGINE=y
CONFIG_DMA_ACPI=y

#
# DMA Clients
#
CONFIG_ASYNC_TX_DMA=y
# CONFIG_DMATEST is not set
# CONFIG_AUXDISPLAY is not set
# CONFIG_UIO is not set
CONFIG_VIRT_DRIVERS=y
CONFIG_VIRTIO=y

#
# Virtio drivers
#
# CONFIG_VIRTIO_PCI is not set
CONFIG_VIRTIO_BALLOON=y
CONFIG_VIRTIO_MMIO=y
CONFIG_VIRTIO_MMIO_CMDLINE_DEVICES=y

#
# Microsoft Hyper-V guest support
#
# CONFIG_HYPERV is not set
CONFIG_STAGING=y
# CONFIG_SLICOSS is not set
# CONFIG_ECHO is not set
# CONFIG_PANEL is not set
# CONFIG_DX_SEP is not set
# CONFIG_ZSMALLOC is not set
# CONFIG_CRYSTALHD is not set
# CONFIG_ACPI_QUICKSTART is not set
CONFIG_FT1000=y
CONFIG_FT1000_PCMCIA=y

#
# Speakup console speech
#
# CONFIG_TOUCHSCREEN_CLEARPAD_TM1217 is not set
# CONFIG_TOUCHSCREEN_SYNAPTICS_I2C_RMI4 is not set
# CONFIG_STAGING_MEDIA is not set

#
# Android
#
CONFIG_ANDROID=y
# CONFIG_ANDROID_BINDER_IPC is not set
CONFIG_ANDROID_LOGGER=y
CONFIG_ANDROID_TIMED_OUTPUT=y
# CONFIG_ANDROID_TIMED_GPIO is not set
# CONFIG_ANDROID_LOW_MEMORY_KILLER is not set
# CONFIG_SYNC is not set
CONFIG_WIMAX_GDM72XX=y
# CONFIG_WIMAX_GDM72XX_QOS is not set
# CONFIG_WIMAX_GDM72XX_K_MODE is not set
CONFIG_WIMAX_GDM72XX_WIMAX2=y
CONFIG_WIMAX_GDM72XX_SDIO=y
CONFIG_DGRP=y
CONFIG_GOLDFISH_AUDIO=y
CONFIG_MTD_GOLDFISH_NAND=y
# CONFIG_XILLYBUS is not set
# CONFIG_DGNC is not set
CONFIG_DGAP=y
CONFIG_X86_PLATFORM_DEVICES=y
# CONFIG_ACERHDF is not set
# CONFIG_ASUS_LAPTOP is not set
CONFIG_DELL_LAPTOP=y
# CONFIG_FUJITSU_LAPTOP is not set
# CONFIG_FUJITSU_TABLET is not set
# CONFIG_HP_ACCEL is not set
# CONFIG_PANASONIC_LAPTOP is not set
# CONFIG_THINKPAD_ACPI is not set
# CONFIG_SENSORS_HDAPS is not set
# CONFIG_INTEL_MENLOW is not set
# CONFIG_ACPI_WMI is not set
# CONFIG_TOPSTAR_LAPTOP is not set
# CONFIG_TOSHIBA_BT_RFKILL is not set
# CONFIG_ACPI_CMPC is not set
# CONFIG_INTEL_IPS is not set
# CONFIG_IBM_RTL is not set
# CONFIG_XO15_EBOOK is not set
CONFIG_SAMSUNG_LAPTOP=y
# CONFIG_SAMSUNG_Q10 is not set
# CONFIG_APPLE_GMUX is not set
# CONFIG_INTEL_RST is not set
# CONFIG_INTEL_SMARTCONNECT is not set
# CONFIG_PVPANIC is not set
# CONFIG_GOLDFISH_PIPE is not set
# CONFIG_CHROME_PLATFORMS is not set

#
# Hardware Spinlock drivers
#
CONFIG_CLKSRC_I8253=y
CONFIG_CLKEVT_I8253=y
CONFIG_CLKBLD_I8253=y
# CONFIG_MAILBOX is not set
# CONFIG_IOMMU_SUPPORT is not set

#
# Remoteproc drivers
#
CONFIG_REMOTEPROC=y
CONFIG_STE_MODEM_RPROC=y

#
# Rpmsg drivers
#
CONFIG_PM_DEVFREQ=y

#
# DEVFREQ Governors
#
CONFIG_DEVFREQ_GOV_SIMPLE_ONDEMAND=y
CONFIG_DEVFREQ_GOV_PERFORMANCE=y
CONFIG_DEVFREQ_GOV_POWERSAVE=y
CONFIG_DEVFREQ_GOV_USERSPACE=y

#
# DEVFREQ Drivers
#
# CONFIG_EXTCON is not set
CONFIG_MEMORY=y
# CONFIG_IIO is not set
# CONFIG_NTB is not set
# CONFIG_VME_BUS is not set
# CONFIG_PWM is not set
CONFIG_IPACK_BUS=y
# CONFIG_BOARD_TPCI200 is not set
CONFIG_SERIAL_IPOCTAL=y
# CONFIG_RESET_CONTROLLER is not set
# CONFIG_FMC is not set

#
# PHY Subsystem
#
CONFIG_GENERIC_PHY=y
CONFIG_PHY_EXYNOS_MIPI_VIDEO=y
# CONFIG_POWERCAP is not set

#
# Firmware Drivers
#
CONFIG_EDD=y
CONFIG_EDD_OFF=y
# CONFIG_FIRMWARE_MEMMAP is not set
# CONFIG_DELL_RBU is not set
CONFIG_DCDBAS=y
CONFIG_DMIID=y
# CONFIG_DMI_SYSFS is not set
# CONFIG_ISCSI_IBFT_FIND is not set
CONFIG_GOOGLE_FIRMWARE=y

#
# Google Firmware Drivers
#
# CONFIG_GOOGLE_SMI is not set
CONFIG_GOOGLE_MEMCONSOLE=y

#
# File systems
#
CONFIG_DCACHE_WORD_ACCESS=y
# CONFIG_EXT2_FS is not set
CONFIG_EXT3_FS=y
# CONFIG_EXT3_DEFAULTS_TO_ORDERED is not set
CONFIG_EXT3_FS_XATTR=y
CONFIG_EXT3_FS_POSIX_ACL=y
# CONFIG_EXT3_FS_SECURITY is not set
CONFIG_EXT4_FS=y
# CONFIG_EXT4_USE_FOR_EXT23 is not set
# CONFIG_EXT4_FS_POSIX_ACL is not set
CONFIG_EXT4_FS_SECURITY=y
# CONFIG_EXT4_DEBUG is not set
CONFIG_JBD=y
# CONFIG_JBD_DEBUG is not set
CONFIG_JBD2=y
CONFIG_JBD2_DEBUG=y
CONFIG_FS_MBCACHE=y
CONFIG_REISERFS_FS=y
CONFIG_REISERFS_CHECK=y
# CONFIG_REISERFS_PROC_INFO is not set
# CONFIG_REISERFS_FS_XATTR is not set
CONFIG_JFS_FS=y
# CONFIG_JFS_POSIX_ACL is not set
CONFIG_JFS_SECURITY=y
# CONFIG_JFS_DEBUG is not set
CONFIG_JFS_STATISTICS=y
CONFIG_XFS_FS=y
# CONFIG_XFS_QUOTA is not set
CONFIG_XFS_POSIX_ACL=y
# CONFIG_XFS_RT is not set
CONFIG_XFS_DEBUG=y
CONFIG_GFS2_FS=y
# CONFIG_OCFS2_FS is not set
# CONFIG_BTRFS_FS is not set
# CONFIG_NILFS2_FS is not set
CONFIG_FS_POSIX_ACL=y
CONFIG_EXPORTFS=y
# CONFIG_FILE_LOCKING is not set
CONFIG_FSNOTIFY=y
CONFIG_DNOTIFY=y
CONFIG_INOTIFY_USER=y
# CONFIG_FANOTIFY is not set
CONFIG_QUOTA=y
# CONFIG_QUOTA_NETLINK_INTERFACE is not set
CONFIG_PRINT_QUOTA_WARNING=y
# CONFIG_QUOTA_DEBUG is not set
# CONFIG_QFMT_V1 is not set
# CONFIG_QFMT_V2 is not set
CONFIG_QUOTACTL=y
CONFIG_AUTOFS4_FS=y
CONFIG_FUSE_FS=y
# CONFIG_CUSE is not set

#
# Caches
#
CONFIG_FSCACHE=y
CONFIG_FSCACHE_STATS=y
CONFIG_FSCACHE_HISTOGRAM=y
CONFIG_FSCACHE_DEBUG=y
CONFIG_FSCACHE_OBJECT_LIST=y
# CONFIG_CACHEFILES is not set

#
# CD-ROM/DVD Filesystems
#
CONFIG_ISO9660_FS=y
# CONFIG_JOLIET is not set
CONFIG_ZISOFS=y
CONFIG_UDF_FS=y
CONFIG_UDF_NLS=y

#
# DOS/FAT/NT Filesystems
#
CONFIG_FAT_FS=y
# CONFIG_MSDOS_FS is not set
CONFIG_VFAT_FS=y
CONFIG_FAT_DEFAULT_CODEPAGE=437
CONFIG_FAT_DEFAULT_IOCHARSET="iso8859-1"
CONFIG_NTFS_FS=y
# CONFIG_NTFS_DEBUG is not set
# CONFIG_NTFS_RW is not set

#
# Pseudo filesystems
#
CONFIG_PROC_FS=y
CONFIG_PROC_KCORE=y
CONFIG_PROC_VMCORE=y
# CONFIG_PROC_SYSCTL is not set
CONFIG_PROC_PAGE_MONITOR=y
CONFIG_SYSFS=y
# CONFIG_HUGETLBFS is not set
# CONFIG_HUGETLB_PAGE is not set
CONFIG_CONFIGFS_FS=y
# CONFIG_MISC_FILESYSTEMS is not set
# CONFIG_NETWORK_FILESYSTEMS is not set
CONFIG_NLS=y
CONFIG_NLS_DEFAULT="iso8859-1"
CONFIG_NLS_CODEPAGE_437=y
CONFIG_NLS_CODEPAGE_737=y
CONFIG_NLS_CODEPAGE_775=y
# CONFIG_NLS_CODEPAGE_850 is not set
CONFIG_NLS_CODEPAGE_852=y
CONFIG_NLS_CODEPAGE_855=y
CONFIG_NLS_CODEPAGE_857=y
CONFIG_NLS_CODEPAGE_860=y
# CONFIG_NLS_CODEPAGE_861 is not set
CONFIG_NLS_CODEPAGE_862=y
# CONFIG_NLS_CODEPAGE_863 is not set
CONFIG_NLS_CODEPAGE_864=y
# CONFIG_NLS_CODEPAGE_865 is not set
CONFIG_NLS_CODEPAGE_866=y
# CONFIG_NLS_CODEPAGE_869 is not set
CONFIG_NLS_CODEPAGE_936=y
CONFIG_NLS_CODEPAGE_950=y
CONFIG_NLS_CODEPAGE_932=y
CONFIG_NLS_CODEPAGE_949=y
CONFIG_NLS_CODEPAGE_874=y
CONFIG_NLS_ISO8859_8=y
# CONFIG_NLS_CODEPAGE_1250 is not set
CONFIG_NLS_CODEPAGE_1251=y
# CONFIG_NLS_ASCII is not set
CONFIG_NLS_ISO8859_1=y
CONFIG_NLS_ISO8859_2=y
# CONFIG_NLS_ISO8859_3 is not set
CONFIG_NLS_ISO8859_4=y
CONFIG_NLS_ISO8859_5=y
CONFIG_NLS_ISO8859_6=y
CONFIG_NLS_ISO8859_7=y
# CONFIG_NLS_ISO8859_9 is not set
# CONFIG_NLS_ISO8859_13 is not set
# CONFIG_NLS_ISO8859_14 is not set
CONFIG_NLS_ISO8859_15=y
CONFIG_NLS_KOI8_R=y
CONFIG_NLS_KOI8_U=y
CONFIG_NLS_MAC_ROMAN=y
CONFIG_NLS_MAC_CELTIC=y
CONFIG_NLS_MAC_CENTEURO=y
# CONFIG_NLS_MAC_CROATIAN is not set
CONFIG_NLS_MAC_CYRILLIC=y
CONFIG_NLS_MAC_GAELIC=y
# CONFIG_NLS_MAC_GREEK is not set
CONFIG_NLS_MAC_ICELAND=y
# CONFIG_NLS_MAC_INUIT is not set
CONFIG_NLS_MAC_ROMANIAN=y
# CONFIG_NLS_MAC_TURKISH is not set
CONFIG_NLS_UTF8=y
# CONFIG_DLM is not set

#
# Kernel hacking
#
CONFIG_TRACE_IRQFLAGS_SUPPORT=y

#
# printk and dmesg options
#
CONFIG_PRINTK_TIME=y
CONFIG_DEFAULT_MESSAGE_LOGLEVEL=4
# CONFIG_BOOT_PRINTK_DELAY is not set
# CONFIG_DYNAMIC_DEBUG is not set

#
# Compile-time checks and compiler options
#
# CONFIG_DEBUG_INFO is not set
# CONFIG_ENABLE_WARN_DEPRECATED is not set
# CONFIG_ENABLE_MUST_CHECK is not set
CONFIG_FRAME_WARN=1024
CONFIG_STRIP_ASM_SYMS=y
CONFIG_READABLE_ASM=y
CONFIG_UNUSED_SYMBOLS=y
CONFIG_DEBUG_FS=y
# CONFIG_HEADERS_CHECK is not set
# CONFIG_DEBUG_SECTION_MISMATCH is not set
CONFIG_ARCH_WANT_FRAME_POINTERS=y
CONFIG_FRAME_POINTER=y
# CONFIG_DEBUG_FORCE_WEAK_PER_CPU is not set
CONFIG_MAGIC_SYSRQ=y
CONFIG_MAGIC_SYSRQ_DEFAULT_ENABLE=0x1
CONFIG_DEBUG_KERNEL=y

#
# Memory Debugging
#
CONFIG_DEBUG_PAGEALLOC=y
CONFIG_WANT_PAGE_DEBUG_FLAGS=y
CONFIG_PAGE_GUARD=y
CONFIG_DEBUG_OBJECTS=y
# CONFIG_DEBUG_OBJECTS_SELFTEST is not set
# CONFIG_DEBUG_OBJECTS_FREE is not set
# CONFIG_DEBUG_OBJECTS_TIMERS is not set
# CONFIG_DEBUG_OBJECTS_WORK is not set
CONFIG_DEBUG_OBJECTS_RCU_HEAD=y
CONFIG_DEBUG_OBJECTS_PERCPU_COUNTER=y
CONFIG_DEBUG_OBJECTS_ENABLE_DEFAULT=1
CONFIG_HAVE_DEBUG_KMEMLEAK=y
# CONFIG_DEBUG_KMEMLEAK is not set
# CONFIG_DEBUG_STACK_USAGE is not set
CONFIG_DEBUG_VM=y
CONFIG_DEBUG_VM_RB=y
# CONFIG_DEBUG_VIRTUAL is not set
# CONFIG_DEBUG_MEMORY_INIT is not set
# CONFIG_DEBUG_PER_CPU_MAPS is not set
# CONFIG_DEBUG_HIGHMEM is not set
CONFIG_HAVE_DEBUG_STACKOVERFLOW=y
# CONFIG_DEBUG_STACKOVERFLOW is not set
CONFIG_HAVE_ARCH_KMEMCHECK=y
CONFIG_DEBUG_SHIRQ=y

#
# Debug Lockups and Hangs
#
CONFIG_LOCKUP_DETECTOR=y
CONFIG_HARDLOCKUP_DETECTOR=y
# CONFIG_BOOTPARAM_HARDLOCKUP_PANIC is not set
CONFIG_BOOTPARAM_HARDLOCKUP_PANIC_VALUE=0
# CONFIG_BOOTPARAM_SOFTLOCKUP_PANIC is not set
CONFIG_BOOTPARAM_SOFTLOCKUP_PANIC_VALUE=0
CONFIG_DETECT_HUNG_TASK=y
CONFIG_DEFAULT_HUNG_TASK_TIMEOUT=120
CONFIG_BOOTPARAM_HUNG_TASK_PANIC=y
CONFIG_BOOTPARAM_HUNG_TASK_PANIC_VALUE=1
CONFIG_PANIC_ON_OOPS=y
CONFIG_PANIC_ON_OOPS_VALUE=1
# CONFIG_SCHED_DEBUG is not set
# CONFIG_SCHEDSTATS is not set
CONFIG_TIMER_STATS=y

#
# Lock Debugging (spinlocks, mutexes, etc...)
#
CONFIG_DEBUG_RT_MUTEXES=y
CONFIG_DEBUG_PI_LIST=y
# CONFIG_RT_MUTEX_TESTER is not set
CONFIG_DEBUG_SPINLOCK=y
CONFIG_DEBUG_MUTEXES=y
CONFIG_DEBUG_WW_MUTEX_SLOWPATH=y
CONFIG_DEBUG_LOCK_ALLOC=y
# CONFIG_PROVE_LOCKING is not set
CONFIG_LOCKDEP=y
# CONFIG_LOCK_STAT is not set
CONFIG_DEBUG_LOCKDEP=y
CONFIG_DEBUG_ATOMIC_SLEEP=y
# CONFIG_DEBUG_LOCKING_API_SELFTESTS is not set
CONFIG_TRACE_IRQFLAGS=y
CONFIG_STACKTRACE=y
# CONFIG_DEBUG_KOBJECT is not set
CONFIG_DEBUG_BUGVERBOSE=y
# CONFIG_DEBUG_WRITECOUNT is not set
# CONFIG_DEBUG_LIST is not set
CONFIG_DEBUG_SG=y
CONFIG_DEBUG_NOTIFIERS=y
# CONFIG_DEBUG_CREDENTIALS is not set

#
# RCU Debugging
#
CONFIG_SPARSE_RCU_POINTER=y
# CONFIG_RCU_TORTURE_TEST is not set
CONFIG_RCU_CPU_STALL_TIMEOUT=21
# CONFIG_RCU_CPU_STALL_INFO is not set
CONFIG_RCU_TRACE=y
# CONFIG_DEBUG_BLOCK_EXT_DEVT is not set
# CONFIG_NOTIFIER_ERROR_INJECTION is not set
CONFIG_FAULT_INJECTION=y
CONFIG_FAIL_PAGE_ALLOC=y
# CONFIG_FAIL_MAKE_REQUEST is not set
# CONFIG_FAIL_IO_TIMEOUT is not set
CONFIG_FAIL_MMC_REQUEST=y
# CONFIG_FAULT_INJECTION_DEBUG_FS is not set
# CONFIG_LATENCYTOP is not set
CONFIG_ARCH_HAS_DEBUG_STRICT_USER_COPY_CHECKS=y
# CONFIG_DEBUG_STRICT_USER_COPY_CHECKS is not set
CONFIG_USER_STACKTRACE_SUPPORT=y
CONFIG_NOP_TRACER=y
CONFIG_HAVE_FUNCTION_TRACER=y
CONFIG_HAVE_FUNCTION_GRAPH_TRACER=y
CONFIG_HAVE_FUNCTION_GRAPH_FP_TEST=y
CONFIG_HAVE_FUNCTION_TRACE_MCOUNT_TEST=y
CONFIG_HAVE_DYNAMIC_FTRACE=y
CONFIG_HAVE_DYNAMIC_FTRACE_WITH_REGS=y
CONFIG_HAVE_FTRACE_MCOUNT_RECORD=y
CONFIG_HAVE_SYSCALL_TRACEPOINTS=y
CONFIG_HAVE_C_RECORDMCOUNT=y
CONFIG_TRACER_MAX_TRACE=y
CONFIG_TRACE_CLOCK=y
CONFIG_RING_BUFFER=y
CONFIG_EVENT_TRACING=y
CONFIG_CONTEXT_SWITCH_TRACER=y
CONFIG_RING_BUFFER_ALLOW_SWAP=y
CONFIG_TRACING=y
CONFIG_GENERIC_TRACER=y
CONFIG_TRACING_SUPPORT=y
CONFIG_FTRACE=y
# CONFIG_FUNCTION_TRACER is not set
CONFIG_IRQSOFF_TRACER=y
CONFIG_SCHED_TRACER=y
CONFIG_FTRACE_SYSCALLS=y
CONFIG_TRACER_SNAPSHOT=y
CONFIG_TRACER_SNAPSHOT_PER_CPU_SWAP=y
CONFIG_BRANCH_PROFILE_NONE=y
# CONFIG_PROFILE_ANNOTATED_BRANCHES is not set
# CONFIG_PROFILE_ALL_BRANCHES is not set
# CONFIG_STACK_TRACER is not set
CONFIG_BLK_DEV_IO_TRACE=y
CONFIG_UPROBE_EVENT=y
CONFIG_PROBE_EVENTS=y
# CONFIG_FTRACE_STARTUP_TEST is not set
# CONFIG_MMIOTRACE is not set
# CONFIG_RING_BUFFER_BENCHMARK is not set
# CONFIG_RING_BUFFER_STARTUP_TEST is not set

#
# Runtime Testing
#
# CONFIG_LKDTM is not set
# CONFIG_TEST_LIST_SORT is not set
# CONFIG_BACKTRACE_SELF_TEST is not set
# CONFIG_RBTREE_TEST is not set
CONFIG_ATOMIC64_SELFTEST=y
CONFIG_TEST_STRING_HELPERS=y
CONFIG_TEST_KSTRTOX=y
# CONFIG_PROVIDE_OHCI1394_DMA_INIT is not set
# CONFIG_DMA_API_DEBUG is not set
# CONFIG_SAMPLES is not set
CONFIG_HAVE_ARCH_KGDB=y
# CONFIG_KGDB is not set
# CONFIG_STRICT_DEVMEM is not set
# CONFIG_X86_VERBOSE_BOOTUP is not set
# CONFIG_EARLY_PRINTK is not set
CONFIG_X86_PTDUMP=y
# CONFIG_DEBUG_RODATA is not set
# CONFIG_DOUBLEFAULT is not set
# CONFIG_DEBUG_TLBFLUSH is not set
# CONFIG_IOMMU_STRESS is not set
CONFIG_HAVE_MMIOTRACE_SUPPORT=y
CONFIG_IO_DELAY_TYPE_0X80=0
CONFIG_IO_DELAY_TYPE_0XED=1
CONFIG_IO_DELAY_TYPE_UDELAY=2
CONFIG_IO_DELAY_TYPE_NONE=3
CONFIG_IO_DELAY_0X80=y
# CONFIG_IO_DELAY_0XED is not set
# CONFIG_IO_DELAY_UDELAY is not set
# CONFIG_IO_DELAY_NONE is not set
CONFIG_DEFAULT_IO_DELAY_TYPE=0
CONFIG_DEBUG_BOOT_PARAMS=y
# CONFIG_CPA_DEBUG is not set
# CONFIG_OPTIMIZE_INLINING is not set
# CONFIG_DEBUG_NMI_SELFTEST is not set
CONFIG_X86_DEBUG_STATIC_CPU_HAS=y

#
# Security options
#
CONFIG_KEYS=y
# CONFIG_PERSISTENT_KEYRINGS is not set
CONFIG_TRUSTED_KEYS=y
CONFIG_ENCRYPTED_KEYS=y
CONFIG_KEYS_DEBUG_PROC_KEYS=y
# CONFIG_SECURITY_DMESG_RESTRICT is not set
CONFIG_SECURITY=y
CONFIG_SECURITYFS=y
CONFIG_SECURITY_NETWORK=y
# CONFIG_SECURITY_NETWORK_XFRM is not set
CONFIG_SECURITY_PATH=y
CONFIG_LSM_MMAP_MIN_ADDR=65536
CONFIG_SECURITY_SELINUX=y
# CONFIG_SECURITY_SELINUX_BOOTPARAM is not set
# CONFIG_SECURITY_SELINUX_DISABLE is not set
CONFIG_SECURITY_SELINUX_DEVELOP=y
CONFIG_SECURITY_SELINUX_AVC_STATS=y
CONFIG_SECURITY_SELINUX_CHECKREQPROT_VALUE=1
CONFIG_SECURITY_SELINUX_POLICYDB_VERSION_MAX=y
CONFIG_SECURITY_SELINUX_POLICYDB_VERSION_MAX_VALUE=19
CONFIG_SECURITY_SMACK=y
# CONFIG_SECURITY_TOMOYO is not set
# CONFIG_SECURITY_APPARMOR is not set
# CONFIG_SECURITY_YAMA is not set
CONFIG_INTEGRITY=y
CONFIG_INTEGRITY_SIGNATURE=y
# CONFIG_INTEGRITY_AUDIT is not set
CONFIG_INTEGRITY_ASYMMETRIC_KEYS=y
CONFIG_IMA=y
CONFIG_IMA_MEASURE_PCR_IDX=10
CONFIG_IMA_LSM_RULES=y
# CONFIG_IMA_TEMPLATE is not set
CONFIG_IMA_NG_TEMPLATE=y
# CONFIG_IMA_SIG_TEMPLATE is not set
CONFIG_IMA_DEFAULT_TEMPLATE="ima-ng"
# CONFIG_IMA_DEFAULT_HASH_SHA1 is not set
# CONFIG_IMA_DEFAULT_HASH_SHA256 is not set
# CONFIG_IMA_DEFAULT_HASH_SHA512 is not set
CONFIG_IMA_DEFAULT_HASH_WP512=y
CONFIG_IMA_DEFAULT_HASH="wp512"
CONFIG_IMA_APPRAISE=y
CONFIG_EVM=y
CONFIG_EVM_HMAC_VERSION=2
CONFIG_DEFAULT_SECURITY_SELINUX=y
# CONFIG_DEFAULT_SECURITY_SMACK is not set
# CONFIG_DEFAULT_SECURITY_DAC is not set
CONFIG_DEFAULT_SECURITY="selinux"
CONFIG_CRYPTO=y

#
# Crypto core or helper
#
CONFIG_CRYPTO_ALGAPI=y
CONFIG_CRYPTO_ALGAPI2=y
CONFIG_CRYPTO_AEAD=y
CONFIG_CRYPTO_AEAD2=y
CONFIG_CRYPTO_BLKCIPHER=y
CONFIG_CRYPTO_BLKCIPHER2=y
CONFIG_CRYPTO_HASH=y
CONFIG_CRYPTO_HASH2=y
CONFIG_CRYPTO_RNG=y
CONFIG_CRYPTO_RNG2=y
CONFIG_CRYPTO_PCOMP=y
CONFIG_CRYPTO_PCOMP2=y
CONFIG_CRYPTO_MANAGER=y
CONFIG_CRYPTO_MANAGER2=y
# CONFIG_CRYPTO_USER is not set
# CONFIG_CRYPTO_MANAGER_DISABLE_TESTS is not set
CONFIG_CRYPTO_GF128MUL=y
CONFIG_CRYPTO_NULL=y
# CONFIG_CRYPTO_PCRYPT is not set
CONFIG_CRYPTO_WORKQUEUE=y
CONFIG_CRYPTO_CRYPTD=y
# CONFIG_CRYPTO_AUTHENC is not set
CONFIG_CRYPTO_ABLK_HELPER=y

#
# Authenticated Encryption with Associated Data
#
CONFIG_CRYPTO_CCM=y
# CONFIG_CRYPTO_GCM is not set
CONFIG_CRYPTO_SEQIV=y

#
# Block modes
#
CONFIG_CRYPTO_CBC=y
CONFIG_CRYPTO_CTR=y
# CONFIG_CRYPTO_CTS is not set
CONFIG_CRYPTO_ECB=y
CONFIG_CRYPTO_LRW=y
# CONFIG_CRYPTO_PCBC is not set
CONFIG_CRYPTO_XTS=y

#
# Hash modes
#
# CONFIG_CRYPTO_CMAC is not set
CONFIG_CRYPTO_HMAC=y
CONFIG_CRYPTO_XCBC=y
# CONFIG_CRYPTO_VMAC is not set

#
# Digest
#
CONFIG_CRYPTO_CRC32C=y
CONFIG_CRYPTO_CRC32C_INTEL=y
# CONFIG_CRYPTO_CRC32 is not set
CONFIG_CRYPTO_CRC32_PCLMUL=y
CONFIG_CRYPTO_CRCT10DIF=y
# CONFIG_CRYPTO_GHASH is not set
CONFIG_CRYPTO_MD4=y
CONFIG_CRYPTO_MD5=y
CONFIG_CRYPTO_MICHAEL_MIC=y
CONFIG_CRYPTO_RMD128=y
# CONFIG_CRYPTO_RMD160 is not set
# CONFIG_CRYPTO_RMD256 is not set
CONFIG_CRYPTO_RMD320=y
CONFIG_CRYPTO_SHA1=y
CONFIG_CRYPTO_SHA256=y
CONFIG_CRYPTO_SHA512=y
CONFIG_CRYPTO_TGR192=y
CONFIG_CRYPTO_WP512=y

#
# Ciphers
#
CONFIG_CRYPTO_AES=y
CONFIG_CRYPTO_AES_586=y
CONFIG_CRYPTO_AES_NI_INTEL=y
CONFIG_CRYPTO_ANUBIS=y
CONFIG_CRYPTO_ARC4=y
# CONFIG_CRYPTO_BLOWFISH is not set
CONFIG_CRYPTO_CAMELLIA=y
CONFIG_CRYPTO_CAST_COMMON=y
CONFIG_CRYPTO_CAST5=y
CONFIG_CRYPTO_CAST6=y
# CONFIG_CRYPTO_DES is not set
CONFIG_CRYPTO_FCRYPT=y
CONFIG_CRYPTO_KHAZAD=y
CONFIG_CRYPTO_SALSA20=y
CONFIG_CRYPTO_SALSA20_586=y
CONFIG_CRYPTO_SEED=y
CONFIG_CRYPTO_SERPENT=y
# CONFIG_CRYPTO_SERPENT_SSE2_586 is not set
CONFIG_CRYPTO_TEA=y
# CONFIG_CRYPTO_TWOFISH is not set
# CONFIG_CRYPTO_TWOFISH_586 is not set

#
# Compression
#
CONFIG_CRYPTO_DEFLATE=y
CONFIG_CRYPTO_ZLIB=y
CONFIG_CRYPTO_LZO=y
# CONFIG_CRYPTO_LZ4 is not set
CONFIG_CRYPTO_LZ4HC=y

#
# Random Number Generation
#
# CONFIG_CRYPTO_ANSI_CPRNG is not set
CONFIG_CRYPTO_USER_API=y
# CONFIG_CRYPTO_USER_API_HASH is not set
CONFIG_CRYPTO_USER_API_SKCIPHER=y
CONFIG_CRYPTO_HASH_INFO=y
# CONFIG_CRYPTO_HW is not set
CONFIG_ASYMMETRIC_KEY_TYPE=y
CONFIG_ASYMMETRIC_PUBLIC_KEY_SUBTYPE=y
CONFIG_PUBLIC_KEY_ALGO_RSA=y
CONFIG_X509_CERTIFICATE_PARSER=y
CONFIG_HAVE_KVM=y
CONFIG_VIRTUALIZATION=y
# CONFIG_LGUEST is not set
CONFIG_BINARY_PRINTF=y

#
# Library routines
#
CONFIG_BITREVERSE=y
CONFIG_GENERIC_STRNCPY_FROM_USER=y
CONFIG_GENERIC_STRNLEN_USER=y
CONFIG_GENERIC_NET_UTILS=y
CONFIG_GENERIC_FIND_FIRST_BIT=y
CONFIG_GENERIC_PCI_IOMAP=y
CONFIG_GENERIC_IOMAP=y
CONFIG_GENERIC_IO=y
CONFIG_PERCPU_RWSEM=y
CONFIG_CRC_CCITT=y
CONFIG_CRC16=y
CONFIG_CRC_T10DIF=y
CONFIG_CRC_ITU_T=y
CONFIG_CRC32=y
CONFIG_CRC32_SELFTEST=y
CONFIG_CRC32_SLICEBY8=y
# CONFIG_CRC32_SLICEBY4 is not set
# CONFIG_CRC32_SARWATE is not set
# CONFIG_CRC32_BIT is not set
CONFIG_CRC7=y
CONFIG_LIBCRC32C=y
CONFIG_CRC8=y
CONFIG_AUDIT_GENERIC=y
CONFIG_RANDOM32_SELFTEST=y
CONFIG_ZLIB_INFLATE=y
CONFIG_ZLIB_DEFLATE=y
CONFIG_LZO_COMPRESS=y
CONFIG_LZO_DECOMPRESS=y
CONFIG_LZ4HC_COMPRESS=y
CONFIG_LZ4_DECOMPRESS=y
# CONFIG_XZ_DEC is not set
# CONFIG_XZ_DEC_BCJ is not set
CONFIG_DECOMPRESS_GZIP=y
CONFIG_GENERIC_ALLOCATOR=y
CONFIG_TEXTSEARCH=y
CONFIG_TEXTSEARCH_KMP=y
CONFIG_ASSOCIATIVE_ARRAY=y
CONFIG_HAS_IOMEM=y
CONFIG_HAS_IOPORT=y
CONFIG_HAS_DMA=y
CONFIG_CPU_RMAP=y
CONFIG_DQL=y
CONFIG_NLATTR=y
CONFIG_ARCH_HAS_ATOMIC64_DEC_IF_POSITIVE=y
CONFIG_AVERAGE=y
CONFIG_CLZ_TAB=y
# CONFIG_CORDIC is not set
CONFIG_DDR=y
CONFIG_MPILIB=y
CONFIG_SIGNATURE=y
CONFIG_OID_REGISTRY=y

--BXVAT5kNtrzKuDFl--
