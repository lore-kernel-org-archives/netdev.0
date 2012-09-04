From: Fengguang Wu <fengguang.wu@intel.com>
Subject: sctp_close/sk_free: kernel BUG at slab.c:3074!
Date: Tue, 4 Sep 2012 21:59:37 +0800
Message-ID: <20120904135937.GA15068@localhost>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="r5Pyd7+fXNt84Ff3"
Cc: Marc Kleine-Budde <mkl@pengutronix.de>, linux-can@vger.kernel.org
To: networking <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:15451 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753192Ab2IDN7q (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 4 Sep 2012 09:59:46 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--r5Pyd7+fXNt84Ff3
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

Greetings,

The below oops happens somewhere in tree 

        git://gitorious.org/linux-can/linux-can-next master

Bisect has been time consuming and still in half way..

[  233.046014] kfree_debugcheck: out of range ptr ea6000000bb8h.
[  233.047399] ------------[ cut here ]------------
[  233.048393] kernel BUG at /c/kernel-tests/src/stable/mm/slab.c:3074!
[  233.048393] invalid opcode: 0000 [#1] SMP DEBUG_PAGEALLOC
[  233.048393] Modules linked in:
[  233.048393] CPU 0 
[  233.048393] Pid: 3929, comm: trinity-watchdo Not tainted 3.6.0-rc3+ #4192 Bochs Bochs
[  233.048393] RIP: 0010:[<ffffffff81169653>]  [<ffffffff81169653>] kfree_debugcheck+0x27/0x2d
[  233.048393] RSP: 0018:ffff88000facbca8  EFLAGS: 00010092
[  233.048393] RAX: 0000000000000031 RBX: 0000ea6000000bb8 RCX: 00000000a189a188
[  233.048393] RDX: 000000000000a189 RSI: ffffffff8108ad32 RDI: ffffffff810d30f9
[  233.048393] RBP: ffff88000facbcb8 R08: 0000000000000002 R09: ffffffff843846f0
[  233.048393] R10: ffffffff810ae37c R11: 0000000000000908 R12: 0000000000000202
[  233.048393] R13: ffffffff823dbd5a R14: ffff88000ec5bea8 R15: ffffffff8363c780
[  233.048393] FS:  00007faa6899c700(0000) GS:ffff88001f200000(0000) knlGS:0000000000000000
[  233.048393] CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
[  233.048393] CR2: 00007faa6841019c CR3: 0000000012c82000 CR4: 00000000000006f0
[  233.048393] DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
[  233.048393] DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
[  233.048393] Process trinity-watchdo (pid: 3929, threadinfo ffff88000faca000, task ffff88000faec600)
[  233.048393] Stack:
[  233.048393]  0000000000000000 0000ea6000000bb8 ffff88000facbce8 ffffffff8116ad81
[  233.048393]  ffff88000ff588a0 ffff88000ff58850 ffff88000ff588a0 0000000000000000
[  233.048393]  ffff88000facbd08 ffffffff823dbd5a ffffffff823dbcb0 ffff88000ff58850
[  233.048393] Call Trace:
[  233.048393]  [<ffffffff8116ad81>] kfree+0x5f/0xca
[  233.048393]  [<ffffffff823dbd5a>] inet_sock_destruct+0xaa/0x13c
[  233.048393]  [<ffffffff823dbcb0>] ? inet_sk_rebuild_header+0x319/0x319
[  233.048393]  [<ffffffff8231c307>] __sk_free+0x21/0x14b
[  233.048393]  [<ffffffff8231c4bd>] sk_free+0x26/0x2a
[  233.048393]  [<ffffffff825372db>] sctp_close+0x215/0x224
[  233.048393]  [<ffffffff810d6835>] ? lock_release+0x16f/0x1b9
[  233.048393]  [<ffffffff823daf12>] inet_release+0x7e/0x85
[  233.048393]  [<ffffffff82317d15>] sock_release+0x1f/0x77
[  233.048393]  [<ffffffff82317d94>] sock_close+0x27/0x2b
[  233.048393]  [<ffffffff81173bbe>] __fput+0x101/0x20a
[  233.048393]  [<ffffffff81173cd5>] ____fput+0xe/0x10
[  233.048393]  [<ffffffff810a3794>] task_work_run+0x5d/0x75
[  233.048393]  [<ffffffff8108da70>] do_exit+0x290/0x7f5
[  233.048393]  [<ffffffff82707415>] ? retint_swapgs+0x13/0x1b
[  233.048393]  [<ffffffff8108e23f>] do_group_exit+0x7b/0xba
[  233.048393]  [<ffffffff8108e295>] sys_exit_group+0x17/0x17
[  233.048393]  [<ffffffff8270de10>] tracesys+0xdd/0xe2
[  233.048393] Code: 59 01 5d c3 55 48 89 e5 53 41 50 0f 1f 44 00 00 48 89 fb e8 d4 b0 f0 ff 84 c0 75 11 48 89 de 48 c7 c7 fc fa f7 82 e8 0d 0f 57 01 <0f> 0b 5f 5b 5d c3 55 48 89 e5 0f 1f 44 00 00 48 63 87 d8 00 00 
[  233.048393] RIP  [<ffffffff81169653>] kfree_debugcheck+0x27/0x2d
[  233.048393]  RSP <ffff88000facbca8>

Thanks,
Fengguang

--r5Pyd7+fXNt84Ff3
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename="dmesg-kvm-waimea-4919-2012-09-04-00-24-21-3.6.0-rc3+-4192"

[    0.000000] Initializing cgroup subsys cpuset
[    0.000000] Initializing cgroup subsys cpu
[    0.000000] Linux version 3.6.0-rc3+ (kbuild@bee) (gcc version 4.7.1 (Debian 4.7.1-6) ) #4192 SMP Tue Sep 4 00:17:51 CST 2012
[    0.000000] Command line: trinity=2m hung_task_panic=1 rcutree.rcu_cpu_stall_timeout=100 branch=can/master log_buf_len=8M ignore_loglevel debug sched_debug apic=debug dynamic_printk sysrq_always_enabled panic=10 load_ramdisk=2 prompt_ramdisk=0 console=ttyS0,115200 console=tty0 vga=normal ip=::::kvm::dhcp nfsroot=10.239.97.14:/nfsroot/wfg,tcp,v3,nocto,actimeo=600,nolock,rsize=524288,wsize=524288 rw link=vmlinuz-2012-09-04-00-18-37-can:master:d7ceb47-d7ceb47-x86_64-allyesdebian-2-waimea BOOT_IMAGE=kernel-tests/kernels/x86_64-allyesdebian/d7ceb47/vmlinuz-3.6.0-rc3+
[    0.000000] e820: BIOS-provided physical RAM map:
[    0.000000] BIOS-e820: [mem 0x0000000000000000-0x0000000000093bff] usable
[    0.000000] BIOS-e820: [mem 0x0000000000093c00-0x000000000009ffff] reserved
[    0.000000] BIOS-e820: [mem 0x00000000000f0000-0x00000000000fffff] reserved
[    0.000000] BIOS-e820: [mem 0x0000000000100000-0x000000001fffdfff] usable
[    0.000000] BIOS-e820: [mem 0x000000001fffe000-0x000000001fffffff] reserved
[    0.000000] BIOS-e820: [mem 0x00000000feffc000-0x00000000feffffff] reserved
[    0.000000] BIOS-e820: [mem 0x00000000fffc0000-0x00000000ffffffff] reserved
[    0.000000] debug: ignoring loglevel setting.
[    0.000000] NX (Execute Disable) protection: active
[    0.000000] DMI 2.4 present.
[    0.000000] DMI: Bochs Bochs, BIOS Bochs 01/01/2007
[    0.000000] Hypervisor detected: KVM
[    0.000000] e820: update [mem 0x00000000-0x0000ffff] usable ==> reserved
[    0.000000] e820: remove [mem 0x000a0000-0x000fffff] usable
[    0.000000] No AGP bridge found
[    0.000000] e820: last_pfn = 0x1fffe max_arch_pfn = 0x400000000
[    0.000000] MTRR default type: write-back
[    0.000000] MTRR fixed ranges enabled:
[    0.000000]   00000-9FFFF write-back
[    0.000000]   A0000-BFFFF uncachable
[    0.000000]   C0000-FFFFF write-protect
[    0.000000] MTRR variable ranges enabled:
[    0.000000]   0 base 00E0000000 mask FFE0000000 uncachable
[    0.000000]   1 disabled
[    0.000000]   2 disabled
[    0.000000]   3 disabled
[    0.000000]   4 disabled
[    0.000000]   5 disabled
[    0.000000]   6 disabled
[    0.000000]   7 disabled
[    0.000000] x86 PAT enabled: cpu 0, old 0x70406, new 0x7010600070106
[    0.000000] Scan for SMP in [mem 0x00000000-0x000003ff]
[    0.000000] Scan for SMP in [mem 0x0009fc00-0x0009ffff]
[    0.000000] Scan for SMP in [mem 0x000f0000-0x000fffff]
[    0.000000] found SMP MP-table at [mem 0x000fdab0-0x000fdabf] mapped at [ffff8800000fdab0]
[    0.000000]   mpc: fdac0-fdbe4
[    0.000000] initial memory mapped: [mem 0x00000000-0x1fffffff]
[    0.000000] Base memory trampoline at [ffff88000008d000] 8d000 size 24576
[    0.000000] init_memory_mapping: [mem 0x00000000-0x1fffdfff]
[    0.000000]  [mem 0x00000000-0x1fffdfff] page 4k
[    0.000000] kernel direct mapping tables up to 0x1fffdfff @ [mem 0x1fefc000-0x1fffdfff]
[    0.000000] log_buf_len: 8388608
[    0.000000] early log buf free: 127908(97%)
[    0.000000] ACPI: RSDP 00000000000fd920 00014 (v00 BOCHS )
[    0.000000] ACPI: RSDT 000000001fffe550 00038 (v01 BOCHS  BXPCRSDT 00000001 BXPC 00000001)
[    0.000000] ACPI: FACP 000000001fffff80 00074 (v01 BOCHS  BXPCFACP 00000001 BXPC 00000001)
[    0.000000] ACPI: DSDT 000000001fffe590 01121 (v01   BXPC   BXDSDT 00000001 INTL 20100528)
[    0.000000] ACPI: FACS 000000001fffff40 00040
[    0.000000] ACPI: SSDT 000000001ffffe40 000FF (v01 BOCHS  BXPCSSDT 00000001 BXPC 00000001)
[    0.000000] ACPI: APIC 000000001ffffd50 00080 (v01 BOCHS  BXPCAPIC 00000001 BXPC 00000001)
[    0.000000] ACPI: HPET 000000001ffffd10 00038 (v01 BOCHS  BXPCHPET 00000001 BXPC 00000001)
[    0.000000] ACPI: SSDT 000000001ffff6c0 00644 (v01   BXPC BXSSDTPC 00000001 INTL 20100528)
[    0.000000] ACPI: Local APIC address 0xfee00000
[    0.000000] mapped APIC to ffffffffff5fb000 (        fee00000)
[    0.000000] No NUMA configuration found
[    0.000000] Faking a node at [mem 0x0000000000000000-0x000000001fffdfff]
[    0.000000] Initmem setup node 0 [mem 0x00000000-0x1fffdfff]
[    0.000000]   NODE_DATA [mem 0x1f6f7000-0x1f6fbfff]
[    0.000000]  [ffffea0000000000-ffffea00007fffff] PMD -> [ffff88001e600000-ffff88001edfffff] on node 0
[    0.000000] Zone ranges:
[    0.000000]   DMA      [mem 0x00010000-0x00ffffff]
[    0.000000]   DMA32    [mem 0x01000000-0xffffffff]
[    0.000000]   Normal   empty
[    0.000000] Movable zone start for each node
[    0.000000] Early memory node ranges
[    0.000000]   node   0: [mem 0x00010000-0x00092fff]
[    0.000000]   node   0: [mem 0x00100000-0x1fffdfff]
[    0.000000] On node 0 totalpages: 130945
[    0.000000]   DMA zone: 64 pages used for memmap
[    0.000000]   DMA zone: 6 pages reserved
[    0.000000]   DMA zone: 3901 pages, LIFO batch:0
[    0.000000]   DMA32 zone: 1984 pages used for memmap
[    0.000000]   DMA32 zone: 124990 pages, LIFO batch:31
[    0.000000] ACPI: PM-Timer IO Port: 0xb008
[    0.000000] ACPI: Local APIC address 0xfee00000
[    0.000000] mapped APIC to ffffffffff5fb000 (        fee00000)
[    0.000000] ACPI: LAPIC (acpi_id[0x00] lapic_id[0x00] enabled)
[    0.000000] ACPI: LAPIC (acpi_id[0x01] lapic_id[0x01] enabled)
[    0.000000] ACPI: LAPIC_NMI (acpi_id[0xff] dfl dfl lint[0x1])
[    0.000000] ACPI: IOAPIC (id[0x02] address[0xfec00000] gsi_base[0])
[    0.000000] IOAPIC[0]: apic_id 2, version 17, address 0xfec00000, GSI 0-23
[    0.000000] ACPI: INT_SRC_OVR (bus 0 bus_irq 0 global_irq 2 dfl dfl)
[    0.000000] Int: type 0, pol 0, trig 0, bus 00, IRQ 00, APIC ID 2, APIC INT 02
[    0.000000] ACPI: INT_SRC_OVR (bus 0 bus_irq 5 global_irq 5 high level)
[    0.000000] Int: type 0, pol 1, trig 3, bus 00, IRQ 05, APIC ID 2, APIC INT 05
[    0.000000] ACPI: INT_SRC_OVR (bus 0 bus_irq 9 global_irq 9 high level)
[    0.000000] Int: type 0, pol 1, trig 3, bus 00, IRQ 09, APIC ID 2, APIC INT 09
[    0.000000] ACPI: INT_SRC_OVR (bus 0 bus_irq 10 global_irq 10 high level)
[    0.000000] Int: type 0, pol 1, trig 3, bus 00, IRQ 0a, APIC ID 2, APIC INT 0a
[    0.000000] ACPI: INT_SRC_OVR (bus 0 bus_irq 11 global_irq 11 high level)
[    0.000000] Int: type 0, pol 1, trig 3, bus 00, IRQ 0b, APIC ID 2, APIC INT 0b
[    0.000000] ACPI: IRQ0 used by override.
[    0.000000] Int: type 0, pol 0, trig 0, bus 00, IRQ 01, APIC ID 2, APIC INT 01
[    0.000000] ACPI: IRQ2 used by override.
[    0.000000] Int: type 0, pol 0, trig 0, bus 00, IRQ 03, APIC ID 2, APIC INT 03
[    0.000000] Int: type 0, pol 0, trig 0, bus 00, IRQ 04, APIC ID 2, APIC INT 04
[    0.000000] ACPI: IRQ5 used by override.
[    0.000000] Int: type 0, pol 0, trig 0, bus 00, IRQ 06, APIC ID 2, APIC INT 06
[    0.000000] Int: type 0, pol 0, trig 0, bus 00, IRQ 07, APIC ID 2, APIC INT 07
[    0.000000] Int: type 0, pol 0, trig 0, bus 00, IRQ 08, APIC ID 2, APIC INT 08
[    0.000000] ACPI: IRQ9 used by override.
[    0.000000] ACPI: IRQ10 used by override.
[    0.000000] ACPI: IRQ11 used by override.
[    0.000000] Int: type 0, pol 0, trig 0, bus 00, IRQ 0c, APIC ID 2, APIC INT 0c
[    0.000000] Int: type 0, pol 0, trig 0, bus 00, IRQ 0d, APIC ID 2, APIC INT 0d
[    0.000000] Int: type 0, pol 0, trig 0, bus 00, IRQ 0e, APIC ID 2, APIC INT 0e
[    0.000000] Int: type 0, pol 0, trig 0, bus 00, IRQ 0f, APIC ID 2, APIC INT 0f
[    0.000000] Using ACPI (MADT) for SMP configuration information
[    0.000000] ACPI: HPET id: 0x8086a201 base: 0xfed00000
[    0.000000] smpboot: Allowing 2 CPUs, 0 hotplug CPUs
[    0.000000] mapped IOAPIC to ffffffffff5fa000 (fec00000)
[    0.000000] nr_irqs_gsi: 40
[    0.000000] PM: Registered nosave memory: 0000000000093000 - 0000000000094000
[    0.000000] PM: Registered nosave memory: 0000000000094000 - 00000000000a0000
[    0.000000] PM: Registered nosave memory: 00000000000a0000 - 00000000000f0000
[    0.000000] PM: Registered nosave memory: 00000000000f0000 - 0000000000100000
[    0.000000] e820: [mem 0x20000000-0xfeffbfff] available for PCI devices
[    0.000000] Booting paravirtualized kernel on KVM
[    0.000000] setup_percpu: NR_CPUS:512 nr_cpumask_bits:512 nr_cpu_ids:2 nr_node_ids:1
[    0.000000] PERCPU: Embedded 478 pages/cpu @ffff88001f200000 s1925848 r8192 d23848 u2097152
[    0.000000] pcpu-alloc: s1925848 r8192 d23848 u2097152 alloc=1*2097152
[    0.000000] pcpu-alloc: [0] 0 [0] 1 
[    0.000000] KVM setup async PF for cpu 0
[    0.000000] kvm-stealtime: cpu 0, msr 1f20e200
[    0.000000] Built 1 zonelists in Node order, mobility grouping on.  Total pages: 128891
[    0.000000] Policy zone: DMA32
[    0.000000] Kernel command line: trinity=2m hung_task_panic=1 rcutree.rcu_cpu_stall_timeout=100 branch=can/master log_buf_len=8M ignore_loglevel debug sched_debug apic=debug dynamic_printk sysrq_always_enabled panic=10 load_ramdisk=2 prompt_ramdisk=0 console=ttyS0,115200 console=tty0 vga=normal ip=::::kvm::dhcp nfsroot=10.239.97.14:/nfsroot/wfg,tcp,v3,nocto,actimeo=600,nolock,rsize=524288,wsize=524288 rw link=vmlinuz-2012-09-04-00-18-37-can:master:d7ceb47-d7ceb47-x86_64-allyesdebian-2-waimea BOOT_IMAGE=kernel-tests/kernels/x86_64-allyesdebian/d7ceb47/vmlinuz-3.6.0-rc3+
[    0.000000] sysrq: sysrq always enabled.
[    0.000000] PID hash table entries: 2048 (order: 2, 16384 bytes)
[    0.000000] __ex_table already sorted, skipping sort
[    0.000000] Checking aperture...
[    0.000000] No AGP bridge found
[    0.000000] Calgary: detecting Calgary via BIOS EBDA area
[    0.000000] Calgary: Unable to locate Rio Grande table in EBDA - bailing!
[    0.000000] Memory: 445532k/524280k available (23630k kernel code, 500k absent, 78248k reserved, 16073k data, 3616k init)
[    0.000000] Hierarchical RCU implementation.
[    0.000000] 
[    0.000000] 
[    0.000000] 
[    0.000000] NR_IRQS:33024 nr_irqs:512 16
[    0.000000] Console: colour VGA+ 80x25
[    0.000000] console [tty0] enabled
[    0.000000] console [ttyS0] enabled
[    0.000000] Lock dependency validator: Copyright (c) 2006 Red Hat, Inc., Ingo Molnar
[    0.000000] ... MAX_LOCKDEP_SUBCLASSES:  8
[    0.000000] ... MAX_LOCK_DEPTH:          48
[    0.000000] ... MAX_LOCKDEP_KEYS:        8191
[    0.000000] ... CLASSHASH_SIZE:          4096
[    0.000000] ... MAX_LOCKDEP_ENTRIES:     16384
[    0.000000] ... MAX_LOCKDEP_CHAINS:      32768
[    0.000000] ... CHAINHASH_SIZE:          16384
[    0.000000]  memory used by lock dependency info: 6367 kB
[    0.000000]  per task-struct memory footprint: 2688 bytes
[    0.000000] ------------------------
[    0.000000] | Locking API testsuite:
[    0.000000] ----------------------------------------------------------------------------
[    0.000000]                                  | spin |wlock |rlock |mutex | wsem | rsem |
[    0.000000]   --------------------------------------------------------------------------
[    0.000000]                      A-A deadlock:  ok  |  ok  |  ok  |  ok  |  ok  |  ok  |
[    0.000000]                  A-B-B-A deadlock:  ok  |  ok  |  ok  |  ok  |  ok  |  ok  |
[    0.000000]              A-B-B-C-C-A deadlock:  ok  |  ok  |  ok  |  ok  |  ok  |  ok  |
[    0.000000]              A-B-C-A-B-C deadlock:  ok  |  ok  |  ok  |  ok  |  ok  |  ok  |
[    0.000000]          A-B-B-C-C-D-D-A deadlock:  ok  |  ok  |  ok  |  ok  |  ok  |  ok  |
[    0.000000]          A-B-C-D-B-D-D-A deadlock:  ok  |  ok  |  ok  |  ok  |  ok  |  ok  |
[    0.000000]          A-B-C-D-B-C-D-A deadlock:  ok  |  ok  |  ok  |  ok  |  ok  |  ok  |
[    0.000000]                     double unlock:  ok  |  ok  |  ok  |  ok  |  ok  |  ok  |
[    0.000000]                   initialize held:  ok  |  ok  |  ok  |  ok  |  ok  |  ok  |
[    0.000000]                  bad unlock order:  ok  |  ok  |  ok  |  ok  |  ok  |  ok  |
[    0.000000]   --------------------------------------------------------------------------
[    0.000000]               recursive read-lock:             |  ok  |             |  ok  |
[    0.000000]            recursive read-lock #2:             |  ok  |             |  ok  |
[    0.000000]             mixed read-write-lock:             |  ok  |             |  ok  |
[    0.000000]             mixed write-read-lock:             |  ok  |             |  ok  |
[    0.000000]   --------------------------------------------------------------------------
[    0.000000]      hard-irqs-on + irq-safe-A/12:  ok  |  ok  |  ok  |
[    0.000000]      soft-irqs-on + irq-safe-A/12:  ok  |  ok  |  ok  |
[    0.000000]      hard-irqs-on + irq-safe-A/21:  ok  |  ok  |  ok  |
[    0.000000]      soft-irqs-on + irq-safe-A/21:  ok  |  ok  |  ok  |
[    0.000000]        sirq-safe-A => hirqs-on/12:  ok  |  ok  |  ok  |
[    0.000000]        sirq-safe-A => hirqs-on/21:  ok  |  ok  |  ok  |
[    0.000000]          hard-safe-A + irqs-on/12:  ok  |  ok  |  ok  |
[    0.000000]          soft-safe-A + irqs-on/12:  ok  |  ok  |  ok  |
[    0.000000]          hard-safe-A + irqs-on/21:  ok  |  ok  |  ok  |
[    0.000000]          soft-safe-A + irqs-on/21:  ok  |  ok  |  ok  |
[    0.000000]     hard-safe-A + unsafe-B #1/123:  ok  |  ok  |  ok  |
[    0.000000]     soft-safe-A + unsafe-B #1/123:  ok  |  ok  |  ok  |
[    0.000000]     hard-safe-A + unsafe-B #1/132:  ok  |  ok  |  ok  |
[    0.000000]     soft-safe-A + unsafe-B #1/132:  ok  |  ok  |  ok  |
[    0.000000]     hard-safe-A + unsafe-B #1/213:  ok  |  ok  |  ok  |
[    0.000000]     soft-safe-A + unsafe-B #1/213:  ok  |  ok  |  ok  |
[    0.000000]     hard-safe-A + unsafe-B #1/231:  ok  |  ok  |  ok  |
[    0.000000]     soft-safe-A + unsafe-B #1/231:  ok  |  ok  |  ok  |
[    0.000000]     hard-safe-A + unsafe-B #1/312:  ok  |  ok  |  ok  |
[    0.000000]     soft-safe-A + unsafe-B #1/312:  ok  |  ok  |  ok  |
[    0.000000]     hard-safe-A + unsafe-B #1/321:  ok  |  ok  |  ok  |
[    0.000000]     soft-safe-A + unsafe-B #1/321:  ok  |  ok  |  ok  |
[    0.000000]     hard-safe-A + unsafe-B #2/123:  ok  |  ok  |  ok  |
[    0.000000]     soft-safe-A + unsafe-B #2/123:  ok  |  ok  |  ok  |
[    0.000000]     hard-safe-A + unsafe-B #2/132:  ok  |  ok  |  ok  |
[    0.000000]     soft-safe-A + unsafe-B #2/132:  ok  |  ok  |  ok  |
[    0.000000]     hard-safe-A + unsafe-B #2/213:  ok  |  ok  |  ok  |
[    0.000000]     soft-safe-A + unsafe-B #2/213:  ok  |  ok  |  ok  |
[    0.000000]     hard-safe-A + unsafe-B #2/231:  ok  |  ok  |  ok  |
[    0.000000]     soft-safe-A + unsafe-B #2/231:  ok  |  ok  |  ok  |
[    0.000000]     hard-safe-A + unsafe-B #2/312:  ok  |  ok  |  ok  |
[    0.000000]     soft-safe-A + unsafe-B #2/312:  ok  |  ok  |  ok  |
[    0.000000]     hard-safe-A + unsafe-B #2/321:  ok  |  ok  |  ok  |
[    0.000000]     soft-safe-A + unsafe-B #2/321:  ok  |  ok  |  ok  |
[    0.000000]       hard-irq lock-inversion/123:  ok  |  ok  |  ok  |
[    0.000000]       soft-irq lock-inversion/123:  ok  |  ok  |  ok  |
[    0.000000]       hard-irq lock-inversion/132:  ok  |  ok  |  ok  |
[    0.000000]       soft-irq lock-inversion/132:  ok  |  ok  |  ok  |
[    0.000000]       hard-irq lock-inversion/213:  ok  |  ok  |  ok  |
[    0.000000]       soft-irq lock-inversion/213:  ok  |  ok  |  ok  |
[    0.000000]       hard-irq lock-inversion/231:  ok  |  ok  |  ok  |
[    0.000000]       soft-irq lock-inversion/231:  ok  |  ok  |  ok  |
[    0.000000]       hard-irq lock-inversion/312:  ok  |  ok  |  ok  |
[    0.000000]       soft-irq lock-inversion/312:  ok  |  ok  |  ok  |
[    0.000000]       hard-irq lock-inversion/321:  ok  |  ok  |  ok  |
[    0.000000]       soft-irq lock-inversion/321:  ok  |  ok  |  ok  |
[    0.000000]       hard-irq read-recursion/123:  ok  |
[    0.000000]       soft-irq read-recursion/123:  ok  |
[    0.000000]       hard-irq read-recursion/132:  ok  |
[    0.000000]       soft-irq read-recursion/132:  ok  |
[    0.000000]       hard-irq read-recursion/213:  ok  |
[    0.000000]       soft-irq read-recursion/213:  ok  |
[    0.000000]       hard-irq read-recursion/231:  ok  |
[    0.000000]       soft-irq read-recursion/231:  ok  |
[    0.000000]       hard-irq read-recursion/312:  ok  |
[    0.000000]       soft-irq read-recursion/312:  ok  |
[    0.000000]       hard-irq read-recursion/321:  ok  |
[    0.000000]       soft-irq read-recursion/321:  ok  |
[    0.000000] -------------------------------------------------------
[    0.000000] Good, all 218 testcases passed! |
[    0.000000] ---------------------------------
[    0.000000] ODEBUG: 0 of 0 active objects replaced
[    0.000000] hpet clockevent registered
[    0.000000] tsc: Fast TSC calibration using PIT
[    0.000000] tsc: Detected 3300.153 MHz processor
[    0.004004] Calibrating delay loop (skipped), value calculated using timer frequency.. 6600.30 BogoMIPS (lpj=13200612)
[    0.008759] pid_max: default: 32768 minimum: 301
[    0.010662] Security Framework initialized
[    0.012069] Dentry cache hash table entries: 65536 (order: 7, 524288 bytes)
[    0.014404] Inode-cache hash table entries: 32768 (order: 6, 262144 bytes)
[    0.016331] Mount-cache hash table entries: 256
[    0.020791] Initializing cgroup subsys cpuacct
[    0.022094] Initializing cgroup subsys devices
[    0.023353] Initializing cgroup subsys freezer
[    0.024016] Initializing cgroup subsys net_cls
[    0.025028] Initializing cgroup subsys blkio
[    0.026374] mce: CPU supports 10 MCE banks
[    0.028054] numa_add_cpu cpu 0 node 0: mask now 0
[    0.029082] Last level iTLB entries: 4KB 0, 2MB 0, 4MB 0
[    0.029082] Last level dTLB entries: 4KB 0, 2MB 0, 4MB 0
[    0.029082] tlb_flushall_shift is 0x6
[    0.033903] ACPI: Core revision 20120711
[    0.041400] ftrace: allocating 90487 entries in 354 pages
[    0.068317] Getting VERSION: 50014
[    0.069210] Getting VERSION: 50014
[    0.070102] Getting ID: 0
[    0.072021] Getting ID: ff000000
[    0.073058] Getting LVT0: 8700
[    0.074016] Getting LVT1: 8400
[    0.075031] enabled ExtINT on CPU#0
[    0.077071] ENABLING IO-APIC IRQs
[    0.078111] init IO_APIC IRQs
[    0.079106]  apic 2 pin 0 not connected
[    0.080050] IOAPIC[0]: Set routing entry (2-1 -> 0x31 -> IRQ 1 Mode:0 Active:0 Dest:1)
[    0.082308] IOAPIC[0]: Set routing entry (2-2 -> 0x30 -> IRQ 0 Mode:0 Active:0 Dest:1)
[    0.084035] IOAPIC[0]: Set routing entry (2-3 -> 0x33 -> IRQ 3 Mode:0 Active:0 Dest:1)
[    0.085895] IOAPIC[0]: Set routing entry (2-4 -> 0x34 -> IRQ 4 Mode:0 Active:0 Dest:1)
[    0.088031] IOAPIC[0]: Set routing entry (2-5 -> 0x35 -> IRQ 5 Mode:1 Active:0 Dest:1)
[    0.089910] IOAPIC[0]: Set routing entry (2-6 -> 0x36 -> IRQ 6 Mode:0 Active:0 Dest:1)
[    0.092031] IOAPIC[0]: Set routing entry (2-7 -> 0x37 -> IRQ 7 Mode:0 Active:0 Dest:1)
[    0.093889] IOAPIC[0]: Set routing entry (2-8 -> 0x38 -> IRQ 8 Mode:0 Active:0 Dest:1)
[    0.096037] IOAPIC[0]: Set routing entry (2-9 -> 0x39 -> IRQ 9 Mode:1 Active:0 Dest:1)
[    0.098075] IOAPIC[0]: Set routing entry (2-10 -> 0x3a -> IRQ 10 Mode:1 Active:0 Dest:1)
[    0.100033] IOAPIC[0]: Set routing entry (2-11 -> 0x3b -> IRQ 11 Mode:1 Active:0 Dest:1)
[    0.101923] IOAPIC[0]: Set routing entry (2-12 -> 0x3c -> IRQ 12 Mode:0 Active:0 Dest:1)
[    0.104031] IOAPIC[0]: Set routing entry (2-13 -> 0x3d -> IRQ 13 Mode:0 Active:0 Dest:1)
[    0.105905] IOAPIC[0]: Set routing entry (2-14 -> 0x3e -> IRQ 14 Mode:0 Active:0 Dest:1)
[    0.108032] IOAPIC[0]: Set routing entry (2-15 -> 0x3f -> IRQ 15 Mode:0 Active:0 Dest:1)
[    0.109894]  apic 2 pin 16 not connected
[    0.111056]  apic 2 pin 17 not connected
[    0.112014]  apic 2 pin 18 not connected
[    0.116020]  apic 2 pin 19 not connected
[    0.120013]  apic 2 pin 20 not connected
[    0.120985]  apic 2 pin 21 not connected
[    0.121962]  apic 2 pin 22 not connected
[    0.122938]  apic 2 pin 23 not connected
[    0.124206] ..TIMER: vector=0x30 apic1=0 pin1=2 apic2=-1 pin2=-1
[    0.125904] smpboot: CPU0: Intel Common KVM processor stepping 01
[    0.128566] Using local APIC timer interrupts.
[    0.128566] calibrating APIC timer ...
[    0.132008] ... lapic delta = 6249289
[    0.132008] ... PM-Timer delta = 357910
[    0.132008] ... PM-Timer result ok
[    0.132008] ..... delta 6249289
[    0.132008] ..... mult: 268388144
[    0.132008] ..... calibration result: 3999544
[    0.132008] ..... CPU clock speed is 3299.2972 MHz.
[    0.132008] ..... host bus clock speed is 999.3544 MHz.
[    0.132078] Performance Events: unsupported Netburst CPU model 6 no PMU driver, software events only.
[    0.136917] Testing tracer nop: PASSED
[    0.140971] SMP alternatives: lockdep: fixing up alternatives
[    0.142780] smpboot: Booting Node   0, Processors  #1 OK
[    0.008000] masked ExtINT on CPU#1
[    0.008000] numa_add_cpu cpu 1 node 0: mask now 0-1
[    0.008000] calibrate_delay_direct() failed to get a good estimate for loops_per_jiffy.
[    0.008000] Probably due to long platform interrupts. Consider using "lpj=" boot option.
[    0.280017] TSC synchronization [CPU#0 -> CPU#1]:
[    0.280017] Measured 3024 cycles TSC warp between CPUs, turning off TSC clock.
[    0.280017] tsc: Marking TSC unstable due to check_tsc_sync_source failed
[    0.290904] Brought up 2 CPUs
[    0.290904] smpboot: Total of 2 processors activated (11372.14 BogoMIPS)
[    0.292310] KVM setup async PF for cpu 1
[    0.293227] kvm-stealtime: cpu 1, msr 1f40e200
[    0.296389] CPU0 attaching sched-domain:
[    0.297569]  domain 0: span 0-1 level CPU
[    0.298907]   groups: 0 1
[    0.300784] CPU1 attaching sched-domain:
[    0.301956]  domain 0: span 0-1 level CPU
[    0.303114]   groups: 1 0
[    0.328075] devtmpfs: initialized
[    0.354183] xor: automatically using best checksumming function:
[    0.392044]    generic_sse:   199.000 MB/sec
[    0.393153] atomic64 test passed for x86-64 platform with CX8 and with SSE
[    0.395495] dummy: 
[    0.396759] NET: Registered protocol family 16
[    0.402755] ACPI: bus type pci registered
[    0.403959] dca service started, version 1.12.1
[    0.404198] PCI: Using configuration type 1 for base access
[    0.488847] bio: create slab <bio-0> at 0
[    0.560048] raid6: sse2x1    5921 MB/s
[    0.628055] raid6: sse2x2    7738 MB/s
[    0.696056] raid6: sse2x4    8690 MB/s
[    0.697224] raid6: using algorithm sse2x4 (8690 MB/s)
[    0.698575] raid6: using intx1 recovery algorithm
[    0.699804] ACPI: Added _OSI(Module Device)
[    0.700053] ACPI: Added _OSI(Processor Device)
[    0.701284] ACPI: Added _OSI(3.0 _SCP Extensions)
[    0.702216] ACPI: Added _OSI(Processor Aggregator Device)
[    0.706161] ACPI: EC: Look up EC in DSDT
[    0.713870] ACPI: Interpreter enabled
[    0.714591] ACPI: (supports S0 S3 S4 S5)
[    0.715921] ACPI: Using IOAPIC for interrupt routing
[    0.731205] ACPI: No dock devices found.
[    0.732055] PCI: Ignoring host bridge windows from ACPI; if necessary, use "pci=use_crs" and report a bug
[    0.734677] ACPI: PCI Root Bridge [PCI0] (domain 0000 [bus 00-ff])
[    0.736123] pci_root PNP0A03:00: host bridge window [io  0x0000-0x0cf7] (ignored)
[    0.738231] pci_root PNP0A03:00: host bridge window [io  0x0d00-0xffff] (ignored)
[    0.740055] pci_root PNP0A03:00: host bridge window [mem 0x000a0000-0x000bffff] (ignored)
[    0.741998] pci_root PNP0A03:00: host bridge window [mem 0xe0000000-0xfebfffff] (ignored)
[    0.744066] PCI: root bus 00: using default resources
[    0.745443] pci_root PNP0A03:00: fail to add MMCONFIG information, can't access extended PCI configuration space under this bridge.
[    0.748310] PCI host bridge to bus 0000:00
[    0.749296] pci_bus 0000:00: busn_res: [bus 00-ff] is inserted under domain [bus 00-ff]
[    0.751119] pci_bus 0000:00: root bus resource [bus 00-ff]
[    0.752055] pci_bus 0000:00: root bus resource [io  0x0000-0xffff]
[    0.753387] pci_bus 0000:00: root bus resource [mem 0x00000000-0xffffffffff]
[    0.756176] pci 0000:00:00.0: [8086:1237] type 00 class 0x060000
[    0.758186] pci 0000:00:01.0: [8086:7000] type 00 class 0x060100
[    0.760563] pci 0000:00:01.1: [8086:7010] type 00 class 0x010180
[    0.763088] pci 0000:00:01.1: reg 20: [io  0xc1c0-0xc1cf]
[    0.764923] pci 0000:00:01.3: [8086:7113] type 00 class 0x068000
[    0.766440] pci 0000:00:01.3: quirk: [io  0xb000-0xb03f] claimed by PIIX4 ACPI
[    0.768054] pci 0000:00:01.3: quirk: [io  0xb100-0xb10f] claimed by PIIX4 SMB
[    0.769478] pci 0000:00:02.0: [1013:00b8] type 00 class 0x030000
[    0.772203] pci 0000:00:02.0: reg 10: [mem 0xfc000000-0xfdffffff pref]
[    0.776216] pci 0000:00:02.0: reg 14: [mem 0xfebf4000-0xfebf4fff]
[    0.782377] pci 0000:00:02.0: reg 30: [mem 0xfebe0000-0xfebeffff pref]
[    0.784334] pci 0000:00:03.0: [8086:100e] type 00 class 0x020000
[    0.785689] pci 0000:00:03.0: reg 10: [mem 0xfeba0000-0xfebbffff]
[    0.787323] pci 0000:00:03.0: reg 14: [io  0xc000-0xc03f]
[    0.790771] pci 0000:00:03.0: reg 30: [mem 0xfebc0000-0xfebdffff pref]
[    0.792564] pci 0000:00:04.0: [8086:2668] type 00 class 0x040300
[    0.794203] pci 0000:00:04.0: reg 10: [mem 0xfebf0000-0xfebf3fff]
[    0.799007] pci 0000:00:05.0: [1af4:1001] type 00 class 0x010000
[    0.800552] pci 0000:00:05.0: reg 10: [io  0xc040-0xc07f]
[    0.802556] pci 0000:00:05.0: reg 14: [mem 0xfebf5000-0xfebf5fff]
[    0.807473] pci 0000:00:06.0: [1af4:1001] type 00 class 0x010000
[    0.808402] pci 0000:00:06.0: reg 10: [io  0xc080-0xc0bf]
[    0.809920] pci 0000:00:06.0: reg 14: [mem 0xfebf6000-0xfebf6fff]
[    0.815190] pci 0000:00:07.0: [1af4:1001] type 00 class 0x010000
[    0.816540] pci 0000:00:07.0: reg 10: [io  0xc0c0-0xc0ff]
[    0.818625] pci 0000:00:07.0: reg 14: [mem 0xfebf7000-0xfebf7fff]
[    0.823534] pci 0000:00:08.0: [1af4:1001] type 00 class 0x010000
[    0.824440] pci 0000:00:08.0: reg 10: [io  0xc100-0xc13f]
[    0.826123] pci 0000:00:08.0: reg 14: [mem 0xfebf8000-0xfebf8fff]
[    0.832545] pci 0000:00:09.0: [1af4:1001] type 00 class 0x010000
[    0.834549] pci 0000:00:09.0: reg 10: [io  0xc140-0xc17f]
[    0.836388] pci 0000:00:09.0: reg 14: [mem 0xfebf9000-0xfebf9fff]
[    0.840974] pci 0000:00:0a.0: [1af4:1001] type 00 class 0x010000
[    0.842675] pci 0000:00:0a.0: reg 10: [io  0xc180-0xc1bf]
[    0.844704] pci 0000:00:0a.0: reg 14: [mem 0xfebfa000-0xfebfafff]
[    0.850217] pci 0000:00:0b.0: [8086:25ab] type 00 class 0x088000
[    0.851795] pci 0000:00:0b.0: reg 10: [mem 0xfebfb000-0xfebfb00f]
[    0.856442] ACPI: PCI Interrupt Routing Table [\_SB_.PCI0._PRT]
[    0.860569]  pci0000:00: ACPI _OSC support notification failed, disabling PCIe ASPM
[    0.861923]  pci0000:00: Unable to request _OSC control (_OSC support mask: 0x08)
[    0.885998] ACPI: PCI Interrupt Link [LNKA] (IRQs 5 *10 11)
[    0.887755] ACPI: PCI Interrupt Link [LNKB] (IRQs 5 *10 11)
[    0.888949] ACPI: PCI Interrupt Link [LNKC] (IRQs 5 10 *11)
[    0.890533] ACPI: PCI Interrupt Link [LNKD] (IRQs 5 10 *11)
[    0.893064] ACPI: PCI Interrupt Link [LNKS] (IRQs 9) *0
[    0.896210] vgaarb: device added: PCI:0000:00:02.0,decodes=io+mem,owns=io+mem,locks=none
[    0.897620] vgaarb: loaded
[    0.898197] vgaarb: bridge control possible 0000:00:02.0
[    0.900203] tps65010: version 2 May 2005
[    0.932159] tps65010: no chip?
[    0.934326] SCSI subsystem initialized
[    0.935427] ACPI: bus type scsi registered
[    0.938348] libata version 3.00 loaded.
[    0.940620] pps_core: LinuxPPS API ver. 1 registered
[    0.941933] pps_core: Software ver. 5.3.6 - Copyright 2005-2007 Rodolfo Giometti <giometti@linux.it>
[    0.944523] wmi: Mapper loaded
[    0.948070] Advanced Linux Sound Architecture Driver Version 1.0.25.
[    0.949727] PCI: Using ACPI for IRQ routing
[    0.950956] PCI: pci_cache_line_size set to 64 bytes
[    0.952557] e820: reserve RAM buffer [mem 0x00093c00-0x0009ffff]
[    0.954200] e820: reserve RAM buffer [mem 0x1fffe000-0x1fffffff]
[    0.957080] Sangoma WANPIPE Router v1.1 (c) 1995-2000 Sangoma Technologies Inc.
[    0.959230] NET: Registered protocol family 23
[    0.960300] Bluetooth: Core ver 2.16
[    0.961403] NET: Registered protocol family 31
[    0.962673] Bluetooth: HCI device and connection manager initialized
[    0.964116] Bluetooth: HCI socket layer initialized
[    0.965414] Bluetooth: L2CAP socket layer initialized
[    0.966916] Bluetooth: SCO socket layer initialized
[    0.968074] NET: Registered protocol family 8
[    0.969305] NET: Registered protocol family 20
[    0.972589] cfg80211: Calling CRDA to update world regulatory domain
[    0.977548] HPET: 3 timers in total, 0 timers will be used for per-cpu timer
[    0.979333] hpet0: at MMIO 0xfed00000, IRQs 2, 8, 0
[    0.980891] hpet0: 3 comparators, 64-bit 100.000000 MHz counter
[    0.992153] Switching to clocksource hpet
[    1.410888] FS-Cache: Loaded
[    1.412615] CacheFiles: Loaded
[    1.413716] pnp: PnP ACPI init
[    1.414810] ACPI: bus type pnp registered
[    1.416204] pnp 00:00: [bus 00-ff]
[    1.417265] pnp 00:00: [io  0x0cf8-0x0cff]
[    1.418477] pnp 00:00: [io  0x0000-0x0cf7 window]
[    1.420111] pnp 00:00: [io  0x0d00-0xffff window]
[    1.421599] pnp 00:00: [mem 0x000a0000-0x000bffff window]
[    1.423274] pnp 00:00: [mem 0xe0000000-0xfebfffff window]
[    1.425152] pnp 00:00: Plug and Play ACPI device, IDs PNP0a03 (active)
[    1.426972] pnp 00:01: [io  0x0070-0x0071]
[    1.428259] IOAPIC[0]: Set routing entry (2-8 -> 0x38 -> IRQ 8 Mode:0 Active:0 Dest:3)
[    1.430560] pnp 00:01: [irq 8]
[    1.431557] pnp 00:01: [io  0x0072-0x0077]
[    1.432994] pnp 00:01: Plug and Play ACPI device, IDs PNP0b00 (active)
[    1.434822] pnp 00:02: [io  0x0060]
[    1.447756] pnp 00:02: [io  0x0064]
[    1.448954] IOAPIC[0]: Set routing entry (2-1 -> 0x31 -> IRQ 1 Mode:0 Active:0 Dest:3)
[    1.451204] pnp 00:02: [irq 1]
[    1.452443] pnp 00:02: Plug and Play ACPI device, IDs PNP0303 (active)
[    1.454217] IOAPIC[0]: Set routing entry (2-12 -> 0x3c -> IRQ 12 Mode:0 Active:0 Dest:3)
[    1.456393] pnp 00:03: [irq 12]
[    1.457584] pnp 00:03: Plug and Play ACPI device, IDs PNP0f13 (active)
[    1.459823] pnp 00:04: [io  0x03f2-0x03f5]
[    1.461196] pnp 00:04: [io  0x03f7]
[    1.462279] IOAPIC[0]: Set routing entry (2-6 -> 0x36 -> IRQ 6 Mode:0 Active:0 Dest:3)
[    1.464250] pnp 00:04: [irq 6]
[    1.465086] pnp 00:04: [dma 2]
[    1.466086] pnp 00:04: Plug and Play ACPI device, IDs PNP0700 (active)
[    1.467749] pnp 00:05: [io  0x0378-0x037f]
[    1.468999] IOAPIC[0]: Set routing entry (2-7 -> 0x37 -> IRQ 7 Mode:0 Active:0 Dest:3)
[    1.471495] pnp 00:05: [irq 7]
[    1.472754] pnp 00:05: Plug and Play ACPI device, IDs PNP0400 (active)
[    1.474433] pnp 00:06: [io  0x03f8-0x03ff]
[    1.475452] IOAPIC[0]: Set routing entry (2-4 -> 0x34 -> IRQ 4 Mode:0 Active:0 Dest:3)
[    1.477837] pnp 00:06: [irq 4]
[    1.479049] pnp 00:06: Plug and Play ACPI device, IDs PNP0501 (active)
[    1.481519] pnp 00:07: [mem 0xfed00000-0xfed003ff]
[    1.483039] pnp 00:07: Plug and Play ACPI device, IDs PNP0103 (active)
[    1.484972] pnp: PnP ACPI: found 8 devices
[    1.485944] ACPI: ACPI bus type pnp unregistered
[    1.516743] pci_bus 0000:00: resource 4 [io  0x0000-0xffff]
[    1.518219] pci_bus 0000:00: resource 5 [mem 0x00000000-0xffffffffff]
[    1.520287] NET: Registered protocol family 2
[    1.523472] TCP established hash table entries: 16384 (order: 6, 262144 bytes)
[    1.526371] TCP bind hash table entries: 16384 (order: 8, 1310720 bytes)
[    1.530403] TCP: Hash tables configured (established 16384 bind 16384)
[    1.532289] TCP: reno registered
[    1.533174] UDP hash table entries: 256 (order: 3, 49152 bytes)
[    1.534580] UDP-Lite hash table entries: 256 (order: 3, 49152 bytes)
[    1.536941] NET: Registered protocol family 1
[    1.552324] RPC: Registered named UNIX socket transport module.
[    1.553496] RPC: Registered udp transport module.
[    1.554415] RPC: Registered tcp transport module.
[    1.555312] RPC: Registered tcp NFSv4.1 backchannel transport module.
[    1.556516] pci 0000:00:00.0: Limiting direct PCI/PCI transfers
[    1.557606] pci 0000:00:01.0: PIIX3: Enabling Passive Release
[    1.558682] pci 0000:00:01.0: Activating ISA DMA hang workarounds
[    1.560434] pci 0000:00:02.0: Boot video device
[    1.561884] PCI: CLS 0 bytes, default 64
[    1.610524] DMA-API: preallocated 32768 debug entries
[    1.611987] DMA-API: debugging enabled by kernel config
[    1.616002] kvm: no hardware support
[    1.617216] has_svm: not amd
[    1.618152] kvm: no hardware support
[    1.619842] Machine check injector initialized
[    1.623490] microcode: CPU0 sig=0xf61, pf=0x1, revision=0x1
[    1.625298] microcode: CPU1 sig=0xf61, pf=0x1, revision=0x1
[    1.627350] microcode: Microcode Update Driver: v2.00 <tigran@aivazian.fsnet.co.uk>, Peter Oruba
[    1.658116] cryptomgr_test (28) used greatest stack depth: 6536 bytes left
[    1.735504] Initializing RT-Tester: OK
[    1.736818] audit: initializing netlink socket (disabled)
[    1.738423] type=2000 audit(1346689225.736:1): initialized
[    1.803681] Kprobe smoke test started
[    1.859798] Kprobe smoke test passed successfully
[    1.888481] Testing tracer function: [    2.211651] kwatchdog (40) used greatest stack depth: 6296 bytes left
PASSED
[    2.302523] Testing dynamic ftrace: PASSED
[    2.788614] Testing dynamic ftrace ops #1: (1 0 1 1 0) (1 1 2 1 0) (2 1 3 1 4) (2 2 4 1 184) PASSED
[    3.538622] Testing dynamic ftrace ops #2: (1 0 1 4 0) (1 1 2 170 0) (2 1 3 1 5) (2 2 4 468 472) PASSED
[    4.324288] Testing tracer irqsoff: PASSED
[    4.960696] Testing tracer wakeup: PASSED
[    6.036526] Testing tracer wakeup_rt: PASSED
[    7.188510] Testing tracer function_graph: PASSED
[    8.022526] HugeTLB registered 2 MB page size, pre-allocated 0 pages
[    8.028461] VFS: Disk quotas dquot_6.5.2
[    8.031667] Dquot-cache hash table entries: 512 (order 0, 4096 bytes)
[    8.035640] DLM installed
[    8.039771] squashfs: version 4.0 (2009/01/31) Phillip Lougher
[    8.046438] FS-Cache: Netfs 'nfs' registered for caching
[    8.065818] NFS: Registering the id_resolver key type
[    8.067403] Key type id_resolver registered
[    8.068717] Key type id_legacy registered
[    8.069898] Installing knfsd (copyright (C) 1996 okir@monad.swb.de).
[    8.092082] Key type cifs.spnego registered
[    8.093241] NTFS driver 2.1.30 [Flags: R/W].
[    8.094889] EFS: 1.0a - http://aeschi.ch.eu.org/efs/
[    8.096312] jffs2: version 2.2. (NAND) (SUMMARY)  
[    8.100293] ROMFS MTD (C) 2007 Red Hat, Inc.
[    8.101786] QNX4 filesystem 0.2.3 registered.
[    8.103463] fuse init (API version 7.20)
[    8.105944] JFS: nTxBlock = 3480, nTxLock = 27845
[    8.113774] SGI XFS with ACLs, security attributes, realtime, large block/inode numbers, no debug enabled
[    8.132503] 9p: Installing v9fs 9p2000 file system support
[    8.133829] FS-Cache: Netfs '9p' registered for caching
[    8.135464] NILFS version 2 loaded
[    8.136409] BeFS version: 0.9.3
[    8.137542] OCFS2 1.5.0
[    8.152300] ocfs2: Registered cluster interface o2cb
[    8.153899] ocfs2: Registered cluster interface user
[    8.155284] OCFS2 DLMFS 1.5.0
[    8.157033] OCFS2 User DLM kernel interface loaded
[    8.158382] OCFS2 Node Manager 1.5.0
[    8.160392] OCFS2 DLM 1.5.0
[    8.163438] Btrfs loaded
[    8.166937] GFS2 installed
[    8.168670] ceph: loaded (mds proto 32)
[    8.169829] msgmni has been set to 870
[    8.237860] async_tx: api initialized (async)
[    8.239176] Block layer SCSI generic (bsg) driver version 0.4 loaded (major 251)
[    8.241423] io scheduler noop registered
[    8.242400] io scheduler deadline registered
[    8.243688] io scheduler cfq registered (default)
[    8.245481] start plist test
[    8.248215] end plist test
[    8.250494] pci_hotplug: PCI Hot Plug PCI Core version: 0.5
[    8.251885] pciehp: PCI Express Hot Plug Controller Driver version: 0.4
[    8.253444] cpcihp_zt5550: ZT5550 CompactPCI Hot Plug Driver version: 0.2
[    8.255023] cpcihp_generic: Generic port I/O CompactPCI Hot Plug Driver version: 0.1
[    8.256858] cpcihp_generic: not configured, disabling.
[    8.258232] shpchp: Standard Hot Plug PCI Controller Driver version: 0.4
[    8.259978] acpiphp: ACPI Hot Plug PCI Controller Driver version: 0.5
[    8.262316] acpiphp: Slot [3] registered
[    8.263533] acpiphp: Slot [4] registered
[    8.264705] acpiphp: Slot [5] registered
[    8.266364] acpiphp: Slot [6] registered
[    8.267617] acpiphp: Slot [7] registered
[    8.269202] acpiphp: Slot [8] registered
[    8.270531] acpiphp: Slot [9] registered
[    8.271836] acpiphp: Slot [10] registered
[    8.273727] acpiphp: Slot [11] registered
[    8.280796] acpiphp: Slot [12] registered
[    8.282148] acpiphp: Slot [13] registered
[    8.283436] acpiphp: Slot [14] registered
[    8.285371] acpiphp: Slot [15] registered
[    8.287460] acpiphp: Slot [16] registered
[    8.289387] acpiphp: Slot [17] registered
[    8.294813] acpiphp: Slot [18] registered
[    8.295948] acpiphp: Slot [19] registered
[    8.297343] acpiphp: Slot [20] registered
[    8.306830] acpiphp: Slot [21] registered
[    8.308219] acpiphp: Slot [22] registered
[    8.309386] acpiphp: Slot [23] registered
[    8.310609] acpiphp: Slot [24] registered
[    8.311860] acpiphp: Slot [25] registered
[    8.319354] acpiphp: Slot [26] registered
[    8.321731] acpiphp: Slot [27] registered
[    8.323216] acpiphp: Slot [28] registered
[    8.324884] acpiphp: Slot [29] registered
[    8.326367] acpiphp: Slot [30] registered
[    8.328191] acpiphp: Slot [31] registered
[    8.336768] acpiphp_ibm: ibm_acpiphp_init: acpi_walk_namespace failed
[    8.339496] progear_bl: ALI M7101 PMU not found.
[    8.342183] VIA Graphics Integration Chipset framebuffer 2.4 initializing
[    8.345130] vmlfb: initializing
[    8.346849] Could not find Carillo Ranch MCH device.
[    8.348860] no IO addresses supplied
[    8.351146] hgafb: HGA card not detected.
[    8.352930] hgafb: probe of hgafb.0 failed with error -22
[    8.372161] kworker/u:0 (115) used greatest stack depth: 5352 bytes left
[    8.374497] uvesafb: failed to execute /sbin/v86d
[    8.376005] uvesafb: make sure that the v86d helper is installed and executable
[    8.378032] uvesafb: Getting VBE info block failed (eax=0x4f00, err=-2)
[    8.379678] uvesafb: vbe_init() failed with -22
[    8.381616] uvesafb: probe of uvesafb.0 failed with error -22
[    8.384315] input: Power Button as /devices/LNXSYSTM:00/LNXPWRBN:00/input/input0
[    8.386461] ACPI: Power Button [PWRF]
[    8.418264] GHES: HEST is not enabled!
[    8.419289] ioatdma: Intel(R) QuickData Technology Driver 4.00
[    8.422412] ACPI: PCI Interrupt Link [LNKA] enabled at IRQ 10
[    8.424108] IOAPIC[0]: Set routing entry (2-10 -> 0x3a -> IRQ 10 Mode:1 Active:0 Dest:3)
[    8.435853] virtio-pci 0000:00:05.0: setting latency timer to 64
[    8.438760] ACPI: PCI Interrupt Link [LNKB] enabled at IRQ 11
[    8.440296] IOAPIC[0]: Set routing entry (2-11 -> 0x3b -> IRQ 11 Mode:1 Active:0 Dest:3)
[    8.442608] virtio-pci 0000:00:06.0: setting latency timer to 64
[    8.445282] ACPI: PCI Interrupt Link [LNKC] enabled at IRQ 11
[    8.446886] virtio-pci 0000:00:07.0: setting latency timer to 64
[    8.450046] ACPI: PCI Interrupt Link [LNKD] enabled at IRQ 10
[    8.451657] virtio-pci 0000:00:08.0: setting latency timer to 64
[    8.454016] virtio-pci 0000:00:09.0: setting latency timer to 64
[    8.456315] virtio-pci 0000:00:0a.0: setting latency timer to 64
[    8.458389] XENFS: not registering filesystem on non-xen platform
[    8.460693] HDLC line discipline maxframe=4096
[    8.462012] N_HDLC line discipline registered.
[    8.463326] r3964: Philips r3964 Driver $Revision: 1.10 $
[    8.465385] Serial: 8250/16550 driver, 4 ports, IRQ sharing enabled
[    8.485864] serial8250: ttyS0 at I/O 0x3f8 (irq = 4) is a 16550A
[    8.507882] 00:06: ttyS0 at I/O 0x3f8 (irq = 4) is a 16550A
[    8.510635] Cyclades driver 2.6
[    8.512160] MOXA Intellio family driver version 6.0k
[    8.562499] MOXA Smartio/Industio family driver version 2.0.5
[    8.564285] Initializing Nozomi driver 2.1d
[    8.565625] RocketPort device driver module, version 2.09, 12-June-2003
[    8.567416] No rocketport ports found; unloading driver
[    8.569009] SyncLink GT
[    8.569893] SyncLink GT, tty major#247
[    8.571159] SyncLink GT no devices found
[    8.572573] SyncLink MultiPort driver $Revision: 4.38 $
[    8.612136] SyncLink MultiPort driver $Revision: 4.38 $, tty major#246
[    8.613862] SyncLink serial driver $Revision: 4.38 $
[    8.651707] SyncLink serial driver $Revision: 4.38 $, tty major#245
[    8.667804] lp: driver loaded but no devices found
[    8.669237] Applicom driver: $Id: ac.c,v 1.30 2000/03/22 16:03:57 dwmw2 Exp $
[    8.671086] ac.o: No PCI boards found.
[    8.672232] ac.o: For an ISA board you must supply memory and irq parameters.
[    8.675448] Non-volatile memory driver v1.3
[    8.688173] ppdev: user-space parallel port driver
[    8.689348] telclk_interrupt = 0xf non-mcpbl0010 hw.
[    8.690542] smapi::smapi_init, ERROR invalid usSmapiID
[    8.691728] mwave: tp3780i::tp3780I_InitializeBoardData: Error: SMAPI is not available on this machine
[    8.693881] mwave: mwavedd::mwave_init: Error: Failed to initialize board data
[    8.695886] mwave: mwavedd::mwave_init: Error: Failed to initialize
[    8.697569] Linux agpgart interface v0.103
[    8.701731] SyncLink PC Card driver $Revision: 4.34 $, tty major#243
[    8.703579] ipmi message handler version 39.2
[    8.704854] ipmi device interface
[    8.705975] IPMI System Interface driver.
[    8.707268] ipmi_si: Adding default-specified kcs state machine
[    8.708974] ipmi_si: Trying default-specified kcs state machine at i/o address 0xca2, slave address 0x0, irq 0
[    8.711417] ipmi_si: Interface detection failed
[    8.713164] ipmi_si: Adding default-specified smic state machine
[    8.714747] ipmi_si: Trying default-specified smic state machine at i/o address 0xca9, slave address 0x0, irq 0
[    8.717335] ipmi_si: Interface detection failed
[    8.736251] ipmi_si: Adding default-specified bt state machine
[    8.737855] ipmi_si: Trying default-specified bt state machine at i/o address 0xe4, slave address 0x0, irq 0
[    8.740389] ipmi_si: Interface detection failed
[    8.741996] ipmi_si: Unable to find any System Interface(s)
[    8.743400] IPMI Watchdog: driver initialized
[    8.744761] Copyright (C) 2004 MontaVista Software - IPMI Powerdown via sys_reboot.
[    8.746794] Hangcheck: starting hangcheck timer 0.9.1 (tick is 180 seconds, margin is 60 seconds).
[    8.749167] Hangcheck: Using getrawmonotonic().
[    8.750713] [drm] Initialized drm 1.1.0 20060810
[    8.752618] [drm] radeon defaulting to kernel modesetting.
[    8.754018] [drm] radeon kernel modesetting enabled.
[    8.756900] parport_pc 00:05: reported by Plug and Play ACPI
[    8.758833] parport0: PC-style at 0x378, irq 7 [PCSPP,TRISTATE]
[    8.857234] lp0: using parport0 (interrupt-driven).
[    8.862469] Floppy drive(s): fd0 is 1.44M
[    8.876876] brd: module loaded
[    8.908250] loop: module loaded
[    8.909215] Compaq SMART2 Driver (v 2.6.0)
[    8.910510] HP CISS Driver (v 3.6.26)
[    8.916251] FDC 0 is a S82078B
[    8.918305] MM: desc_per_page = 128
[    8.922594] nbd: registered device at major 43
[    8.949269] virtio-pci 0000:00:05.0: irq 40 for MSI/MSI-X
[    8.950672] virtio-pci 0000:00:05.0: irq 41 for MSI/MSI-X
[    8.979049]  vda: unknown partition table
[    8.981117] virtio-pci 0000:00:06.0: irq 42 for MSI/MSI-X
[    8.982560] virtio-pci 0000:00:06.0: irq 43 for MSI/MSI-X
[    9.001273]  vdb: unknown partition table
[    9.003239] virtio-pci 0000:00:07.0: irq 44 for MSI/MSI-X
[    9.004775] virtio-pci 0000:00:07.0: irq 45 for MSI/MSI-X
[    9.023827]  vdc: unknown partition table
[    9.025993] virtio-pci 0000:00:08.0: irq 46 for MSI/MSI-X
[    9.027417] virtio-pci 0000:00:08.0: irq 47 for MSI/MSI-X
[    9.046320]  vdd: unknown partition table
[    9.048330] virtio-pci 0000:00:09.0: irq 48 for MSI/MSI-X
[    9.049762] virtio-pci 0000:00:09.0: irq 49 for MSI/MSI-X
[    9.065440]  vde: unknown partition table
[    9.067393] virtio-pci 0000:00:0a.0: irq 50 for MSI/MSI-X
[    9.068941] virtio-pci 0000:00:0a.0: irq 51 for MSI/MSI-X
[    9.086303]  vdf: unknown partition table
[    9.093035] drbd: initialized. Version: 8.3.13 (api:88/proto:86-96)
[    9.094619] drbd: built-in
[    9.095502] drbd: registered as block device major 147
[    9.096944] drbd: minor_table @ 0xffff88001686fef0
[    9.098378] ibmasm: IBM ASM Service Processor Driver version 1.0 loaded
[    9.100709] lkdtm: No crash points registered, enable through debugfs
[    9.102625] Phantom Linux Driver, version n0.9.8, init OK
[    9.104425] i2c-core: driver [isl29003] using legacy suspend method
[    9.105998] i2c-core: driver [isl29003] using legacy resume method
[    9.107554] i2c-core: driver [tsl2550] using legacy suspend method
[    9.109273] i2c-core: driver [tsl2550] using legacy resume method
[    9.110894] Silicon Labs C2 port support v. 0.51.0 - (C) 2007 Rodolfo Giometti
[    9.113326] c2port c2port0: C2 port uc added
[    9.114508] c2port c2port0: uc flash has 30 blocks x 512 bytes (15360 bytes total)
[    9.117353] Uniform Multi-Platform E-IDE driver
[    9.118870] piix 0000:00:01.1: IDE controller (0x8086:0x7010 rev 0x00)
[    9.120787] piix 0000:00:01.1: not 100% native mode: will probe irqs later
[    9.122527] pci 0000:00:01.1: setting latency timer to 64
[    9.123982]     ide0: BM-DMA at 0xc1c0-0xc1c7
[    9.125365]     ide1: BM-DMA at 0xc1c8-0xc1cf
[    9.126564] Probing IDE interface ide0...
[    9.692434] Probing IDE interface ide1...
[   10.428305] hdc: QEMU DVD-ROM, ATAPI CD/DVD-ROM drive
[   11.100392] hdc: host max PIO4 wanted PIO255(auto-tune) selected PIO0
[   11.102144] hdc: MWDMA2 mode selected
[   11.103502] ide0 at 0x1f0-0x1f7,0x3f6 on irq 14
[   11.105067] ide1 at 0x170-0x177,0x376 on irq 15
[   11.107717] ide_generic: please use "probe_mask=0x3f" module parameter for probing all legacy ISA IDE ports
[   11.110309] ide-gd driver 1.18
[   11.111292] ide-cd driver 5.00
[   11.112903] ide-cd: hdc: ATAPI 4X DVD-ROM drive, 512kB Cache
[   11.114890] cdrom: Uniform CD-ROM driver Revision: 3.20
[   11.120191] Loading iSCSI transport class v2.0-870.
[   11.135597] rdac: device handler registered
[   11.137195] hp_sw: device handler registered
[   11.138368] emc: device handler registered
[   11.139519] alua: device handler registered
[   11.142392] fnic: Cisco FCoE HBA Driver, ver 1.5.0.2
[   11.157411] iscsi: registered transport (tcp)
[   11.158984] Loading Adaptec I2O RAID: Version 2.4 Build 5go
[   11.160482] Detecting Adaptec I2O RAID controllers...
[   11.162145] Adaptec aacraid driver 1.2-0[29800]-ms
[   11.163895] aic94xx: Adaptec aic94xx SAS/SATA driver version 1.0.3 loaded
[   11.166461] scsi: <fdomain> Detection failed (no card)
[   11.168147] qla2xxx [0000:00:00.0]-0005: : QLogic Fibre Channel HBA Driver: 8.04.00.03-k.
[   11.170600] iscsi: registered transport (qla4xxx)
[   11.171941] QLogic iSCSI HBA Driver
[   11.173021] Brocade BFA FC/FCOE SCSI driver - version: 3.0.23.0
[   11.175044] DC390: clustering now enabled by default. If you get problems load
[   11.177032]        with "disable_clustering=1" and report to maintainers
[   11.178878] megaraid cmm: 2.20.2.7 (Release Date: Sun Jul 16 00:01:03 EST 2006)
[   11.181306] megaraid: 2.20.5.1 (Release Date: Thu Nov 16 15:32:35 EST 2006)
[   11.183096] megasas: 00.00.06.15-rc1 Mon. Mar. 19 17:00:00 PDT 2012
[   11.184861] mpt2sas version 13.100.00.00 loaded
[   11.186615] GDT-HA: Storage RAID Controller Driver. Version: 3.05
[   11.188492] 3ware Storage Controller device driver for Linux v1.26.02.003.
[   11.190265] 3ware 9000 Storage Controller device driver for Linux v2.26.02.014.
[   11.192411] LSI 3ware SAS/SATA-RAID Controller device driver for Linux v3.26.02.000.
[   11.194506] ppa: Version 2.07 (for Linux 2.4.x)
[   11.197789] imm: Version 2.05 (for Linux 2.4.0)
[   11.199570] ipr: IBM Power RAID SCSI Device Driver version: 2.5.3 (March 10, 2012)
[   11.201764] RocketRAID 3xxx/4xxx Controller driver v1.6 (091225)
[   11.203400] stex: Promise SuperTrak EX Driver version: 4.6.0000.4
[   11.205356] libcxgbi:libcxgbi_init_module: tag itt 0x1fff, 13 bits, age 0xf, 4 bits.
[   11.207366] libcxgbi:ddp_setup_host_page_size: system PAGE 4096, ddp idx 0.
[   11.209159] Chelsio T3 iSCSI Driver cxgb3i v2.0.0 (Jun. 2010)
[   11.210733] iscsi: registered transport (cxgb3i)
[   11.212111] Broadcom NetXtreme II iSCSI Driver bnx2i v2.7.2.2 (Apr 25, 2012)
[   11.213882] iscsi: registered transport (bnx2i)
[   11.238556] iscsi: registered transport (be2iscsi)
[   11.240244] VMware PVSCSI driver - version 1.0.2.0-k
[   11.241650] st: Version 20101219, fixed bufsize 32768, s/g segs 256
[   11.243299] osst :I: Tape driver with OnStream support version 0.99.4
[   11.243299] osst :I: $Id: osst.c,v 1.73 2005/01/01 21:13:34 wriede Exp $
[   11.247013] SCSI Media Changer driver v0.25 
[   11.248427] osd: LOADED open-osd 0.2.1
[   11.260735] scsi_debug: host protection
[   11.261824] scsi0 : scsi_debug, version 1.82 [20100324], dev_size_mb=8, opts=0x0
[   11.265791] scsi 0:0:0:0: Direct-Access     Linux    scsi_debug       0004 PQ: 0 ANSI: 5
[   11.273280] SSFDC read-only Flash Translation layer
[   11.274567] mtdoops: mtd device (mtddev=name/number) must be supplied
[   11.276352] SBC-GXx flash: IO:0x258-0x259 MEM:0xdc000-0xdffff
[   11.277938] NetSc520 flash device: 0x100000 at 0x200000
[   11.279296] Failed to ioremap_nocache
[   11.280418] Failed to ioremap_nocache
[   11.283520] Generic platform RAM MTD, (c) 2004 Simtec Electronics
[   11.285559] sd 0:0:0:0: Attached scsi generic sg0 type 0
[   11.287461] sd 0:0:0:0: [sda] 16384 512-byte logical blocks: (8.38 MB/8.00 MiB)
[   11.292183] sd 0:0:0:0: [sda] Write Protect is off
[   11.293449] sd 0:0:0:0: [sda] Mode Sense: 73 00 10 08
[   11.300187] sd 0:0:0:0: [sda] Write cache: enabled, read cache: enabled, supports DPO and FUA
[   11.320546] No recognised DiskOnChip devices found
[   11.321829] slram: not enough parameters.
[   11.322974] Ramix PMC551 PCI Mezzanine Ram Driver. (C) 1999,2000 Nortel Networks.
[   11.325503] pmc551: not detected
[   11.328162]  sda: unknown partition table
[   11.346414] ftl_cs: FTL header not found.
[   11.353341] sd 0:0:0:0: [sda] Attached SCSI disk
[   11.357809] DiskOnChip Millennium Plus 32MB is not supported, ignoring.
[   11.381397] No valid DiskOnChip devices found
[   11.382696] [nandsim] warning: read_byte: unexpected data output cycle, state is STATE_READY return 0x0
[   11.385193] [nandsim] warning: read_byte: unexpected data output cycle, state is STATE_READY return 0x0
[   11.387557] [nandsim] warning: read_byte: unexpected data output cycle, state is STATE_READY return 0x0
[   11.390403] [nandsim] warning: read_byte: unexpected data output cycle, state is STATE_READY return 0x0
[   11.392871] [nandsim] warning: read_byte: unexpected data output cycle, state is STATE_READY return 0x0
[   11.395280] [nandsim] warning: read_byte: unexpected data output cycle, state is STATE_READY return 0x0
[   11.397694] NAND device: Manufacturer ID: 0x98, Chip ID: 0x39 (Toshiba NAND 128MiB 1,8V 8-bit), page size: 512, OOB size: 16
[   11.400960] flash size: 128 MiB
[   11.401864] page size: 512 bytes
[   11.402813] OOB area size: 16 bytes
[   11.403827] sector size: 16 KiB
[   11.404863] pages number: 262144
[   11.405809] pages per sector: 32
[   11.406783] bus width: 8
[   11.407630] bits in sector size: 14
[   11.408693] bits in page size: 9
[   11.409649] bits in OOB size: 4
[   11.410587] flash size with OOB: 135168 KiB
[   11.411715] page address bytes: 4
[   11.413318] sector address bytes: 3
[   11.414348] options: 0x42
[   11.418387] Scanning device for bad blocks
[   11.526066] kworker/u:0 (139) used greatest stack depth: 5320 bytes left
[   11.528981] Creating 1 MTD partitions on "NAND 128MiB 1,8V 8-bit":
[   11.530546] 0x000000000000-0x000008000000 : "NAND simulator partition 0"
[   11.533814] ftl_cs: FTL header not found.
[   11.604074] onenand_wait: timeout! ctrl=0x0000 intr=0x0000
[   11.605493] OneNAND Manufacturer: Samsung (0xec)
[   11.606728] OneNAND 16MB 1.8V 16-bit (0x04)
[   11.607888] OneNAND version = 0x001e
[   11.609414] Lock scheme is Continuous Lock
[   11.610597] Scanning device for bad blocks
[   11.623414] Creating 1 MTD partitions on "OneNAND simulator":
[   11.625009] 0x000000000000-0x000001000000 : "OneNAND simulator partition"
[   11.628417] ftl_cs: FTL header not found.
[   11.765091] parport_pc 00:05: master is unqueued, this is deprecated
[   11.769233] parport0: AVR Butterfly
[   11.770431] parport0: cannot grant exclusive access for device spi-lm70llp
[   11.772582] spi-lm70llp: spi_lm70llp probe fail, status -12
[   11.774294] bonding: Ethernet Channel Bonding Driver: v3.7.1 (April 27, 2011)
[   11.792601] eql: Equalizer2002: Simon Janes (simon@ncm.com) and David S. Miller (davem@redhat.com)
[   11.800381] tun: Universal TUN/TAP device driver, 1.6
[   11.801895] tun: (C) 1999-2004 Max Krasnyansky <maxk@qualcomm.com>
[   11.804896] arcnet loaded.
[   11.805886] arcnet: RFC1201 "standard" (`a') encapsulation support loaded.
[   11.807797] arcnet: RFC1051 "simple standard" (`s') encapsulation support loaded.
[   11.810214] arcnet: raw mode (`r') encapsulation support loaded.
[   11.811959] arcnet: cap mode (`c') encapsulation support loaded.
[   11.813779] arcnet: COM90xx chipset support
[   12.138272] S3: No ARCnet cards found.
[   12.139555] arcnet: COM90xx IO-mapped mode support (by David Woodhouse et el.)
[   12.141836] E-mail me if you actually test this driver, please!
[   12.143566]  arc%d: No autoprobe for IO mapped cards; you must specify the base address!
[   12.146102] arcnet: RIM I (entirely mem-mapped) support
[   12.147634] E-mail me if you actually test the RIM I driver, please!
[   12.149554] Given: node 00h, shmem 0h, irq 0
[   12.150846] No autoprobe for RIM I; you must specify the shmem and irq!
[   12.152804] arcnet: COM20020 PCI support
[   12.154222] ipddp.c:v0.01 8/28/97 Bradford W. Johnson <johns393@maroon.tc.umn.edu>
[   12.157224] ipddp0: Appletalk-IP Encap. mode by Bradford W. Johnson <johns393@maroon.tc.umn.edu>
[   12.159773] vcan: Virtual CAN interface driver
[   12.161239] CAN device driver interface
[   12.162483] sja1000 CAN netdevice driver
[   12.164766] cnic: Broadcom NetXtreme II CNIC Driver cnic v2.5.12 (June 29, 2012)
[   12.180137] bnx2x: Broadcom NetXtreme II 5771x/578xx 10/20-Gigabit Ethernet Driver bnx2x 1.72.51-0 (2012/06/18)
[   12.184963] enic: Cisco VIC Ethernet NIC Driver, ver 2.1.1.39
[   12.187081] vxge: Copyright(c) 2002-2010 Exar Corp.
[   12.188632] vxge: Driver version: 2.5.3.22640-k
[   12.190250] e1000: Intel(R) PRO/1000 Network Driver - version 7.3.21-k8-NAPI
[   12.192271] e1000: Copyright (c) 1999-2006 Intel Corporation.
[   12.194077] e1000 0000:00:03.0: setting latency timer to 64
[   12.593837] e1000 0000:00:03.0: eth0: (PCI:33MHz:32-bit) 52:54:00:12:34:56
[   12.595658] e1000 0000:00:03.0: eth0: Intel(R) PRO/1000 Network Connection
[   12.598721] e1000e: Intel(R) PRO/1000 Network Driver - 2.1.4-k
[   12.600406] e1000e: Copyright(c) 1999 - 2012 Intel Corporation.
[   12.602310] igb: Intel(R) Gigabit Ethernet Network Driver - version 4.0.1-k
[   12.603971] igb: Copyright (c) 2007-2012 Intel Corporation.
[   12.605645] igbvf: Intel(R) Gigabit Virtual Function Network Driver - version 2.0.1-k
[   12.607876] igbvf: Copyright (c) 2009 - 2012 Intel Corporation.
[   12.609713] ixgbe: Intel(R) 10 Gigabit PCI Express Network Driver - version 3.9.15-k
[   12.611493] ixgbe: Copyright (c) 1999-2012 Intel Corporation.
[   12.613273] ixgbevf: Intel(R) 10 Gigabit PCI Express Virtual Function Network Driver - version 2.6.0-k
[   12.615643] ixgbevf: Copyright (c) 2009 - 2012 Intel Corporation.
[   12.617192] ixgb: Intel(R) PRO/10GbE Network Driver - version 1.0.135-k2-NAPI
[   12.618743] ixgb: Copyright (c) 1999-2008 Intel Corporation.
[   12.620398] jme: JMicron JMC2XX ethernet driver version 1.0.8
[   12.622258] sky2: driver version 1.30
[   12.636283] myri10ge: Version 1.5.3-1.534
[   12.637585] ns83820.c: National Semiconductor DP83820 10/100/1000 driver.
[   12.639652] QLogic 1/10 GbE Converged/Intelligent Ethernet Driver v5.0.29
[   12.641744] QLogic/NetXen Network Driver v4.0.80
[   12.643152] Solarflare NET driver v3.1
[   12.670476] tehuti: Tehuti Networks(R) Network Driver, 7.29.3
[   12.672277] tehuti: Options: hw_csum 
[   12.673868] mkiss: AX.25 Multikiss, Hans Albas PE1AYX
[   12.675276] AX.25: 6pack driver, Revision: 0.3.0
[   12.676446] YAM driver version 0.8 by F1OAT/F6FBB
[   12.679688] AX.25: bpqether driver version 004
[   12.681095] baycom_ser_fdx: (C) 1996-2000 Thomas Sailer, HB9JNX/AE4WA
[   12.681095] baycom_ser_fdx: version 0.10
[   12.686217] hdlcdrv: (C) 1996-2000 Thomas Sailer HB9JNX/AE4WA
[   12.687712] hdlcdrv: version 0.8
[   12.688644] baycom_ser_hdx: (C) 1996-2000 Thomas Sailer, HB9JNX/AE4WA
[   12.688644] baycom_ser_hdx: version 0.10
[   12.693338] baycom_par: (C) 1996-2000 Thomas Sailer, HB9JNX/AE4WA
[   12.693338] baycom_par: version 0.9
[   12.717832] NET3 PLIP version 2.4-parport gniibe@mri.co.jp
[   12.719387] plip0: Parallel port at 0x378, using IRQ 7.
[   12.720901] PPP generic driver version 2.4.2
[   12.722521] PPP BSD Compression module registered
[   12.723842] PPP Deflate Compression module registered
[   12.725373] PPP MPPE Compression module registered
[   12.726738] NET: Registered protocol family 24
[   12.728208] SLIP: version 0.8.4-NET3.019-NEWTTY (dynamic channels, max=256) (6 bit encapsulation enabled).
[   12.730991] CSLIP: code copyright 1989 Regents of the University of California.
[   12.733049] SLIP linefill/keepalive option.
[   12.734392] hdlc: HDLC support module revision 1.22
[   12.736193] DLCI driver v0.35, 4 Jan 1997, mike.mclagan@linux.org.
[   12.737849] cycx_drv: Cyclom 2X Support Module v0.6 (c) 1998-2003 Arnaldo Carvalho de Melo <acme@conectiva.com.br>
[   12.740683] cyclomx: CYCLOM 2X(tm) Sync Card Driver v0.11 (c) 1998-2003 Arnaldo Carvalho de Melo <acme@conectiva.com.br>
[   12.743383] ipw2200: Intel(R) PRO/Wireless 2200/2915 Network Driver, 1.2.2kmprq
[   12.754831] ipw2200: Copyright(c) 2003-2006 Intel Corporation
[   12.756424] libipw: 802.11 data/management/control stack, git-1.1.13
[   12.757990] libipw: Copyright (C) 2004-2005 Intel Corporation <jketreno@linux.intel.com>
[   12.760115] orinoco 0.15 (David Gibson <hermes@gibson.dropbear.id.au>, Pavel Roskin <proski@gnu.org>, et al)
[   12.762366] orinoco_plx 0.15 (Pavel Roskin <proski@gnu.org>, David Gibson <hermes@gibson.dropbear.id.au>, Daniel Barlow <dan@telent.net>)
[   12.765662] orinoco_tmd 0.15 (Joerg Dorchain <joerg@dorchain.net>)
[   12.767431] orinoco_nortel 0.15 (Tobias Hoffmann & Christoph Jungegger <disdos@traum404.de>)
[   12.770137] airo(): Probing for PCI adapters
[   12.771515] airo(): Finished probing for PCI adapters
[   12.774159] Broadcom 43xx driver loaded [ Features: PMLS ]
[   12.775576] Broadcom 43xx-legacy driver loaded [ Features: PLID ]
[   12.777506] libertas_sdio: Libertas SDIO driver
[   12.778660] libertas_sdio: Copyright Pierre Ossman
[   12.779860] libertas_spi: Libertas SPI driver
[   12.797053] Intel(R) Wireless WiFi driver for Linux, in-tree:
[   12.808775] Copyright(c) 2003-2012 Intel Corporation
[   12.810365] iwldvm: Intel(R) Wireless WiFi Link AGN driver for Linux, in-tree:
[   12.812522] iwldvm: Copyright(c) 2003-2012 Intel Corporation
[   12.814135] iwl3945: Intel(R) PRO/Wireless 3945ABG/BG Network Connection driver for Linux, in-tree:s
[   12.821805] iwl3945: Copyright(c) 2003-2011 Intel Corporation
[   12.824508] mac80211_hwsim: Initializing radio 0
[   12.827028] ieee80211 phy0: Selected rate control algorithm 'minstrel_ht'
[   12.829798] ieee80211 phy0: hwaddr 020000000000 registered
[   12.831441] mac80211_hwsim: Initializing radio 1
[   12.833724] ieee80211 phy1: Selected rate control algorithm 'minstrel_ht'
[   12.837116] ieee80211 phy1: hwaddr 020000000100 registered
[   12.839293] mac80211_hwsim: initializing netlink
[   12.841772] ieee802154hardmac ieee802154hardmac: Added ieee802154 HardMAC hardware
[   12.843603] VMware vmxnet3 virtual NIC driver - version 1.1.29.0-k-NAPI
[   12.845469] Madge ATM Ambassador driver version 1.2.4
[   12.846743] Madge ATM Horizon [Ultra] driver version 1.2.1
[   12.857246] fore200e: FORE Systems 200E-series ATM driver - version 0.3e
[   12.859126] idt77252_init: at ffffffff838f9d6d
[   12.860416] Solos PCI Driver Version 0.07
[   12.861534] adummy: version 1.0
[   12.863081] I2O subsystem v1.325
[   12.864002] i2o: max drivers = 8
[   12.878306] I2O Configuration OSM v1.323
[   12.879782] I2O Bus Adapter OSM v1.317
[   12.880974] I2O Block Device OSM v1.325
[   12.883276] I2O SCSI Peripheral OSM v1.316
[   12.884522] I2O ProcFS OSM v1.316
[   12.885630] Fusion MPT base driver 3.04.20
[   12.886819] Copyright (c) 1999-2008 LSI Corporation
[   12.888427] Fusion MPT SPI Host driver 3.04.20
[   12.889868] Fusion MPT FC Host driver 3.04.20
[   12.891197] Fusion MPT SAS Host driver 3.04.20
[   12.892504] Fusion MPT misc device (ioctl) driver 3.04.20
[   12.893979] mptctl: Registered with Fusion MPT base driver
[   12.895224] mptctl: /dev/mptctl @ (major,minor=10,220)
[   12.896447] Fusion MPT LAN driver 3.04.20
[   12.911084] Generic UIO driver for PCI 2.3 devices version: 0.01.0
[   12.914559] aoe: AoE v47 initialised.
[   12.917298] i8042: PNP: PS/2 Controller [PNP0303:KBD,PNP0f13:MOU] at 0x60,0x64 irq 1,12
[   12.933154] serio: i8042 KBD port at 0x60,0x64 irq 1
[   12.934480] serio: i8042 AUX port at 0x60,0x64 irq 12
[   12.936319] parport0: cannot grant exclusive access for device parkbd
[   13.016337] mousedev: PS/2 mouse device common for all mice
[   13.033955] parport0: cannot grant exclusive access for device walkera0701
[   13.036361] mk712: device not present
[   13.037828] apanel: Fujitsu BIOS signature 'FJKEYINF' not found...
[   13.039670] input: PC Speaker as /devices/platform/pcspkr/input/input1
[   13.042227] rtc_cmos 00:01: RTC can wake from S4
[   13.044279] rtc_cmos 00:01: rtc core: registered rtc_cmos as rtc0
[   13.046247] input: AT Translated Set 2 keyboard as /devices/platform/i8042/serio0/input/input2
[   13.061223] rtc0: alarms up to one day, 114 bytes nvram, hpet irqs
[   13.065534] rtc-test rtc-test.0: rtc core: registered test as rtc1
[   13.067841] rtc-test rtc-test.1: rtc core: registered test as rtc2
[   13.069635] i2c /dev entries driver
[   13.071822] piix4_smbus 0000:00:01.3: SMBus Host Controller at 0xb100, revision 0
[   13.205114] i2c-parport: adapter type unspecified
[   13.206454] i2c-parport-light: adapter type unspecified
[   13.207974] pps_ldisc: PPS line discipline registered
[   13.209432] Driver for 1-wire Dallas network protocol.
[   13.211350] 1-Wire driver for the DS2760 battery monitor  chip  - (c) 2004-2005, Szabolcs Gyurko
[   13.214211] i2c-core: driver [max17040] using legacy suspend method
[   13.215880] i2c-core: driver [max17040] using legacy resume method
[   13.548946] input: ImExPS/2 Generic Explorer Mouse as /devices/platform/i8042/serio1/input/input3
[   14.448142] i2c i2c-0: detect fail: address match, 0x2c
[   14.464169] i2c i2c-0: detect fail: address match, 0x2d
[   14.480174] i2c i2c-0: detect fail: address match, 0x2e
[   14.496146] i2c i2c-0: detect fail: address match, 0x2f
[   14.760178] applesmc: supported laptop not found!
[   14.761485] applesmc: driver init failed (ret=-19)!
[   22.620361] pc87360: PC8736x not detected, module not inserted
[   23.124255] acquirewdt: WDT driver for Acquire single board computer initialising
[   23.125704] acquirewdt: I/O address 0x0043 already in use
[   23.126611] acquirewdt: probe of acquirewdt failed with error -5
[   23.127606] advantechwdt: WDT driver for Advantech single board computer initialising
[   23.129353] advantechwdt: initialized. timeout=60 sec (nowayout=0)
[   23.130420] alim7101_wdt: Steve Hill <steve@navaho.co.uk>
[   23.131324] alim7101_wdt: ALi M7101 PMU not present - WDT not set
[   23.132397] sc520_wdt: cannot register miscdev on minor=130 (err=-16)
[   23.133512] ib700wdt: WDT driver for IB700 single board computer initialising
[   23.134750] ib700wdt: START method I/O 443 is not available
[   23.135694] ib700wdt: probe of ib700wdt failed with error -5
[   23.136685] wafer5823wdt: WDT driver for Wafer 5823 single board computer initialising
[   23.138059] wafer5823wdt: I/O address 0x0443 already in use
[   23.139037] i6300esb: Intel 6300ESB WatchDog Timer Driver v0.05
[   23.140229] i6300esb: cannot register miscdev on minor=130 (err=-16)
[   23.141318] i6300ESB timer: probe of 0000:00:0b.0 failed with error -16
[   23.142429] iTCO_wdt: Intel TCO WatchDog Timer Driver v1.10
[   23.143398] iTCO_vendor_support: vendor-support=0
[   23.144360] it87_wdt: no device
[   23.145043] sc1200wdt: build 20020303
[   23.145760] sc1200wdt: io parameter must be specified
[   23.146681] pc87413_wdt: Version 1.1 at io 0x2E
[   23.147479] pc87413_wdt: cannot register miscdev on minor=130 (err=-16)
[   23.148609] sbc60xxwdt: I/O address 0x0443 already in use
[   23.149528] sbc8360: failed to register misc device
[   23.150368] cpu5wdt: misc_register failed
[   23.151119] smsc37b787_wdt: SMsC 37B787 watchdog component driver 1.1 initialising...
[   23.153318] smsc37b787_wdt: Unable to register miscdev on minor 130
[   23.154348] w83627hf_wdt: WDT driver for the Winbond(TM) W83627HF/THF/HG/DHG Super I/O chip initialising
[   23.155958] w83627hf_wdt: Watchdog already running. Resetting timeout to 60 sec
[   23.157262] w83627hf_wdt: cannot register miscdev on minor=130 (err=-16)
[   23.158357] w83697hf_wdt: WDT driver for W83697HF/HG initializing
[   23.159346] w83697hf_wdt: watchdog not found at address 0x2e
[   23.160349] w83697hf_wdt: No W83697HF/HG could be found
[   23.161218] w83697ug_wdt: WDT driver for the Winbond(TM) W83697UG/UF Super I/O chip initialising
[   23.162721] w83697ug_wdt: No W83697UG/UF could be found
[   23.163592] w83877f_wdt: I/O address 0x0443 already in use
[   23.164561] w83977f_wdt: driver v1.00
[   23.165246] w83977f_wdt: cannot register miscdev on minor=130 (err=-16)
[   23.166325] machzwd: MachZ ZF-Logic Watchdog driver initializing
[   23.167300] machzwd: no ZF-Logic found
[   23.167997] sbc_epx_c3: cannot register miscdev on minor=130 (err=-16)
[   23.169320] watchdog: Software Watchdog: cannot register miscdev on minor=130 (err=-16).
[   23.171460] watchdog: Software Watchdog: a legacy watchdog module is probably present.
[   23.173600] softdog: Software Watchdog Timer: 0.08 initialized. soft_noboot=0 soft_margin=60 sec soft_panic=0 (nowayout=0)
[   23.175424] md: linear personality registered for level -1
[   23.177954] md: raid0 personality registered for level 0
[   23.179363] md: raid1 personality registered for level 1
[   23.180846] md: raid10 personality registered for level 10
[   23.181889] md: raid6 personality registered for level 6
[   23.182858] md: raid5 personality registered for level 5
[   23.183897] md: raid4 personality registered for level 4
[   23.185056] md: multipath personality registered for level -4
[   23.186513] md: faulty personality registered for level -5
[   23.188484] device-mapper: uevent: version 1.0.3
[   23.190276] device-mapper: ioctl: 4.23.0-ioctl (2012-07-25) initialised: dm-devel@redhat.com
[   23.193656] device-mapper: multipath: version 1.5.0 loaded
[   23.194673] device-mapper: multipath round-robin: version 1.0.0 loaded
[   23.195792] device-mapper: multipath queue-length: version 0.1.0 loaded
[   23.197566] device-mapper: multipath service-time: version 0.2.0 loaded
[   23.199876] device-mapper: dm-log-userspace: version 1.1.0 loaded
[   23.201555] Bluetooth: Virtual HCI driver ver 1.3
[   23.203093] Bluetooth: HCI UART driver ver 2.2
[   23.204399] Bluetooth: HCI H4 protocol initialized
[   23.205753] Bluetooth: HCI BCSP protocol initialized
[   23.207103] Bluetooth: HCILL protocol initialized
[   23.208704] Bluetooth: Generic Bluetooth SDIO driver ver 0.1
[   23.210854] CAPI 2.0 started up with major 68 (middleware)
[   23.212419] Modular ISDN core version 1.1.29
[   23.214220] NET: Registered protocol family 34
[   23.215450] DSP module 2.0
[   23.216376] mISDN_dsp: DSP clocks every 64 samples. This equals 2 jiffies.
[   23.231331] mISDN: Layer-1-over-IP driver Rev. 2.00
[   23.232624] 0 virtual devices registered
[   23.233869] b1pci: revision 1.1.2.2
[   23.234881] b1: revision 1.1.2.2
[   23.235853] b1dma: revision 1.1.2.3
[   23.237147] b1pci: revision 1.1.2.2
[   23.238374] t1pci: revision 1.1.2.2
[   23.239507] c4: revision 1.1.2.2
[   23.240702] mISDN: HFC-multi driver 2.03
[   23.241986] AVM Fritz PCI driver Rev. 2.3
[   23.243191] Sedlbauer Speedfax+ Driver Rev. 2.0
[   23.244649] Infineon ISDN Driver Rev. 1.0
[   23.245897] Winbond W6692 PCI driver Rev. 2.0
[   23.247238] mISDNipac module version 2.0
[   23.248385] mISDN: ISAR driver Rev. 2.1
[   23.249440] gigaset: Driver for Gigaset 307x
[   23.250612] gigaset: Kernel CAPI interface
[   23.252105] EDAC MC: Ver: 3.0.0
[   23.254414] AMD64 EDAC driver v3.4.0
[   23.255269] cpuidle: using governor ladder
[   23.256172] cpuidle: using governor menu
[   23.257050] sdhci: Secure Digital Host Controller Interface driver
[   23.258603] sdhci: Copyright(c) Pierre Ossman
[   23.260002] wbsd: Winbond W83L51xD SD/MMC card interface driver
[   23.261686] wbsd: Copyright(c) Pierre Ossman
[   23.263211] via_sdmmc: VIA SD/MMC Card Reader driver (C) 2008 VIA Technologies, Inc.
[   23.265733] sdhci-pltfm: SDHCI platform and OF driver helper
[   23.268412] leds_ss4200: no LED devices found
[   23.271744] user_mad: couldn't register device number
[   23.273240] user_verbs: couldn't register device number
[   23.274632] ucm: couldn't register device number
[   23.278061] ib_qib: Unable to register ipathfs
[   23.283607] iscsi: registered transport (iser)
[   23.284958] EFI Variables Facility v0.08 2004-May-17
[   23.286603] dcdbas dcdbas: Dell Systems Management Base Driver (version 5.6.0-3.2)
[   23.288465] No iBFT detected.
[   23.289788] Linux telephony interface: v1.00
[   23.290845] ixj driver initialized.
[   23.292765] msi_laptop: driver 0.5 successfully loaded
[   23.294521] compal_laptop: Motherboard not recognized (You could try the module's force-parameter)
[   23.296990] dell_wmi: No known WMI GUID found
[   23.298401] acer_wmi: Acer Laptop ACPI-WMI Extras
[   23.299629] acer_wmi: No or unsupported WMI interface, unable to load
[   23.301030] acerhdf: Acer Aspire One Fan driver, v.0.5.26
[   23.302499] acerhdf: unknown (unsupported) BIOS version Bochs/Bochs/Bochs, please report, aborting!
[   23.305158] hdaps: supported laptop not found!
[   23.306417] hdaps: driver init failed (ret=-19)!
[   23.307859] fujitsu_laptop: driver 0.6.0 successfully loaded
[   23.309048] msi_wmi: This machine doesn't have MSI-hotkeys through WMI
[   23.310575] topstar_laptop: ACPI extras driver loaded
[   23.324706] no UART detected at 0x1
[   23.325835] MTVAP port 0x378 is busy
[   23.326658] snd_mtpav: probe of snd_mtpav failed with error -16
[   23.328277] snd_mts64: probe of snd_mts64.0 failed with error -5
[   23.329827] snd_portman2x4: probe of snd_portman2x4.0 failed with error -5
[   23.331363] Error: Driver 'pcspkr' is already registered, aborting...
[   23.334542] ASIHPI driver 4.10.01
[   23.338055] snd_hda_intel 0000:00:04.0: irq 52 for MSI/MSI-X
[   23.345313] snd_hda_intel 0000:00:04.0: setting latency timer to 64
[   23.374706] oprofile: using NMI interrupt.
[   23.376158] pktgen: Packet Generator for packet performance testing. Version: 2.74
[   23.378879] drop_monitor: Initializing network drop monitor service
[   23.380847] NET: Registered protocol family 26
[   23.382101] GACT probability on
[   23.383033] Mirror/redirect action on
[   23.384131] Simple TC action Loaded
[   23.385687] netem: version 1.3
[   23.386609] u32 classifier
[   23.387446]     Performance counters on
[   23.388561]     input device check on
[   23.389583]     Actions configured
[   23.390598] Netfilter messages via NETLINK v0.30.
[   23.391992] nf_conntrack version 0.5.0 (3480 buckets, 13920 max)
[   23.394238] ctnetlink v0.93: registering with nfnetlink.
[   23.395876] NF_TPROXY: Transparent proxy support initialized, version 4.1.0
[   23.397627] NF_TPROXY: Copyright (c) 2006-2007 BalaBit IT Ltd.
[   23.399419] xt_time: kernel timezone is -0000
[   23.400633] IPVS: Registered protocols (TCP, UDP, SCTP, AH, ESP)
[   23.402238] IPVS: Connection hash table configured (size=4096, memory=64Kbytes)
[   23.404522] IPVS: Creating netns size=3080 id=0
[   23.405831] IPVS: ipvs loaded.
[   23.406763] IPVS: [rr] scheduler registered.
[   23.407900] IPVS: [wrr] scheduler registered.
[   23.409157] IPVS: [lc] scheduler registered.
[   23.410270] IPVS: [wlc] scheduler registered.
[   23.411404] IPVS: [lblc] scheduler registered.
[   23.412675] IPVS: [lblcr] scheduler registered.
[   23.413854] IPVS: [dh] scheduler registered.
[   23.415036] IPVS: [sh] scheduler registered.
[   23.416237] IPVS: [sed] scheduler registered.
[   23.417384] IPVS: [nq] scheduler registered.
[   23.418625] IPVS: ftp: loaded support on port[0] = 21
[   23.419973] IPv4 over IPv4 tunneling driver
[   23.422299] ip_tables: (C) 2000-2006 Netfilter Core Team
[   23.424126] ipt_CLUSTERIP: ClusterIP Version 0.8 loaded successfully
[   23.425768] arp_tables: (C) 2002 David S. Miller
[   23.427099] TCP: bic registered
[   23.428115] TCP: cubic registered
[   23.429054] TCP: westwood registered
[   23.430053] TCP: highspeed registered
[   23.431056] TCP: hybla registered
[   23.431990] TCP: htcp registered
[   23.433007] TCP: vegas registered
[   23.433959] TCP: veno registered
[   23.434858] TCP: scalable registered
[   23.435866] TCP: lp registered
[   23.436851] TCP: yeah registered
[   23.437781] TCP: illinois registered
[   23.438767] Initializing XFRM netlink socket
[   23.440814] NET: Registered protocol family 10
[   23.446498] mip6: Mobile IPv6
[   23.447505] ip6_tables: (C) 2000-2006 Netfilter Core Team
[   23.449269] sit: IPv6 over IPv4 tunneling driver
[   23.452186] NET: Registered protocol family 17
[   23.453426] NET: Registered protocol family 15
[   23.454845] Bridge firewalling registered
[   23.455990] Ebtables v2.0 registered
[   23.457506] NET: Registered protocol family 4
[   23.458793] NET: Registered protocol family 5
[   23.462352] NET: Registered protocol family 6
[   23.469012] NET: Registered protocol family 11
[   23.470399] NET: Registered protocol family 3
[   23.471618] can: controller area network core (rev 20120528 abi 9)
[   23.473591] NET: Registered protocol family 29
[   23.474775] can: raw protocol (rev 20120528)
[   23.475961] can: broadcast manager protocol (rev 20120528 t)
[   23.478859] IrCOMM protocol (Dag Brattli)
[   23.485858] RPC: Registered rdma transport module.
[   23.487608] NET: Registered protocol family 33
[   23.488906] Key type rxrpc registered
[   23.489961] Key type rxrpc_s registered
[   23.493197] RxRPC: Registered security type 2 'rxkad'
[   23.494576] lec:lane_module_init: lec.c: initialized
[   23.495899] mpoa:atm_mpoa_init: mpc.c: initialized
[   23.497336] l2tp_core: L2TP core driver, V2.0
[   23.498519] l2tp_ppp: PPPoL2TP kernel driver, V2.0
[   23.499739] l2tp_ip: L2TP IP encapsulation support (L2TPv3)
[   23.501333] l2tp_netlink: L2TP netlink interface
[   23.502656] l2tp_eth: L2TP ethernet pseudowire support (L2TPv3)
[   23.504246] l2tp_debugfs: L2TP debugfs support
[   23.505402] l2tp_ip6: L2TP IP encapsulation support for IPv6 (L2TPv3)
[   23.507042] NET4: DECnet for Linux: V.2.5.68s (C) 1995-2003 Linux DECnet Project Team
[   23.509701] DECnet: Routing cache hash table of 256 buckets, 20Kbytes
[   23.511351] NET: Registered protocol family 12
[   23.512783] NET: Registered protocol family 35
[   23.514324] 8021q: 802.1Q VLAN Support v1.8
[   23.517420] DCCP: Activated CCID 2 (TCP-like)
[   23.518755] DCCP: Activated CCID 3 (TCP-Friendly Rate Control)
[   23.533109] DCCP watch registered (port=0)
[   23.535069] sctp: Hash tables configured (established 1638 bind 1638)
[   23.549968] sctp_probe: probe registered (port=0)
[   23.553238] NET: Registered protocol family 21
[   23.555944] Registered RDS/iwarp transport
[   23.557470] Registered RDS/infiniband transport
[   23.558858] Registered RDS/tcp transport
[   23.560679] lib80211: common routines for IEEE802.11 drivers
[   23.562107] lib80211_crypt: registered algorithm 'NULL'
[   23.563407] lib80211_crypt: registered algorithm 'WEP'
[   23.564762] lib80211_crypt: registered algorithm 'CCMP'
[   23.566087] lib80211_crypt: registered algorithm 'TKIP'
[   23.567381] tipc: Activated (version 2.0.0)
[   23.570082] NET: Registered protocol family 30
[   23.571231] tipc: Started in single node mode
[   23.572563] 9pnet: Installing 9P2000 support
[   23.574047] NET: Registered protocol family 36
[   23.575297] Key type dns_resolver registered
[   23.576578] Key type ceph registered
[   23.577588] libceph: loaded (mon/osd proto 15/24, osdmap 5/6 5/6)
[   23.581948] 
[   23.581948] printing PIC contents
[   23.583358] ... PIC  IMR: ffff
[   23.584054] ... PIC  IRR: 9153
[   23.585231] ... PIC  ISR: 0000
[   23.596139] ... PIC ELCR: 0c00
[   23.597098] printing local APIC contents on CPU#0/0:
[   23.598415] ... APIC ID:      00000000 (0)
[   23.599622] ... APIC VERSION: 00050014
[   23.600814] ... APIC TASKPRI: 00000000 (00)
[   23.601090] ... APIC PROCPRI: 00000000
[   23.601090] ... APIC LDR: 01000000
[   23.601090] ... APIC DFR: ffffffff
[   23.601090] ... APIC SPIV: 000001ff
[   23.601090] ... APIC ISR field:
[   23.601090] 0000000000000000000000000000000000000000000000000000000000000000
[   23.601090] ... APIC TMR field:
[   23.601090] 0000000000000000000000000000000000000000000000000000000000000000
[   23.601090] ... APIC IRR field:
[   23.601090] 0000000000000000000000000000000000000000000000000000000020008000
[   23.601090] ... APIC ESR: 00000000
[   23.601090] ... APIC ICR: 000008fd
[   23.601090] ... APIC ICR2: 02000000
[   23.601090] ... APIC LVTT: 000000ef
[   23.601090] ... APIC LVTPC: 00010000
[   23.601090] ... APIC LVT0: 00010700
[   23.601090] ... APIC LVT1: 00000400
[   23.601090] ... APIC LVTERR: 000000fe
[   23.601090] ... APIC TMICT: 0012bc11
[   23.601090] ... APIC TMCCT: 00000000
[   23.601090] ... APIC TDCR: 00000003
[   23.601090] 
[   23.627130] number of MP IRQ sources: 15.
[   23.628268] number of IO-APIC #2 registers: 24.
[   23.629433] testing the IO APIC.......................
[   23.630736] IO APIC #2......
[   23.631591] .... register #00: 00000000
[   23.632734] .......    : physical APIC id: 00
[   23.633873] .......    : Delivery Type: 0
[   23.634987] .......    : LTS          : 0
[   23.636132] .... register #01: 00170011
[   23.637171] .......     : max redirection entries: 17
[   23.638433] .......     : PRQ implemented: 0
[   23.639533] .......     : IO APIC version: 11
[   23.640788] .... register #02: 00000000
[   23.641832] .......     : arbitration: 00
[   23.642901] .... IRQ redirection table:
[   23.643983]  NR Dst Mask Trig IRR Pol Stat Dmod Deli Vect:
[   23.645426]  00 00  1    0    0   0   0    0    0    00
[   23.646846]  01 03  0    0    0   0   0    1    1    31
[   23.648411]  02 03  0    0    0   0   0    1    1    30
[   23.649901]  03 03  0    0    0   0   0    1    1    33
[   23.651357]  04 03  1    0    0   0   0    1    1    34
[   23.652889]  05 03  1    1    0   0   0    1    1    35
[   23.654414]  06 03  0    0    0   0   0    1    1    36
[   23.655849]  07 03  0    0    0   0   0    1    1    37
[   23.657408]  08 03  0    0    0   0   0    1    1    38
[   23.658839]  09 03  0    1    0   0   0    1    1    39
[   23.660385]  0a 03  1    1    0   0   0    1    1    3A
[   23.661883]  0b 03  1    1    0   0   0    1    1    3B
[   23.663348]  0c 03  0    0    0   0   0    1    1    3C
[   23.664953]  0d 03  0    0    0   0   0    1    1    3D
[   23.666499]  0e 03  0    0    0   0   0    1    1    3E
[   23.667970]  0f 03  0    0    0   0   0    1    1    3F
[   23.669507]  10 00  1    0    0   0   0    0    0    00
[   23.670956]  11 00  1    0    0   0   0    0    0    00
[   23.672506]  12 00  1    0    0   0   0    0    0    00
[   23.674005]  13 00  1    0    0   0   0    0    0    00
[   23.675430]  14 00  1    0    0   0   0    0    0    00
[   23.676970]  15 00  1    0    0   0   0    0    0    00
[   23.678434]  16 00  1    0    0   0   0    0    0    00
[   23.679891]  17 00  1    0    0   0   0    0    0    00
[   23.681489] IRQ to pin mappings:
[   23.682414] IRQ0 -> 0:2
[   23.683432] IRQ1 -> 0:1
[   23.684540] IRQ3 -> 0:3
[   23.685564] IRQ4 -> 0:4
[   23.686591] IRQ5 -> 0:5
[   23.687690] IRQ6 -> 0:6
[   23.688875] IRQ7 -> 0:7
[   23.689897] IRQ8 -> 0:8
[   23.690945] IRQ9 -> 0:9
[   23.691959] IRQ10 -> 0:10
[   23.693150] IRQ11 -> 0:11
[   23.694198] IRQ12 -> 0:12
[   23.695264] IRQ13 -> 0:13
[   23.696412] IRQ14 -> 0:14
[   23.697503] IRQ15 -> 0:15
[   23.698563] .................................... done.
[   23.701624] PM: Hibernation image not present or could not be loaded.
[   23.703329] registered taskstats version 1
[   23.704519] Running tests on trace events:
[   23.705701] Testing event 9p_client_req: OK
[   23.721111] Testing event 9p_client_res: OK
[   23.737064] Testing event 9p_protocol_dump: OK
[   23.752991] Testing event drv_return_void: OK
[   23.769108] Testing event drv_return_int: OK
[   23.785089] Testing event drv_return_bool: OK
[   23.800824] Testing event drv_return_u64: OK
[   23.816889] Testing event drv_start: OK
[   23.832881] Testing event drv_get_et_strings: OK
[   23.849138] Testing event drv_get_et_sset_count: OK
[   23.865059] Testing event drv_get_et_stats: OK
[   23.882435] Testing event drv_suspend: OK
[   23.901073] Testing event drv_resume: OK
[   23.917148] Testing event drv_set_wakeup: OK
[   23.933119] Testing event drv_stop: OK
[   23.949623] Testing event drv_add_interface: OK
[   23.964873] Testing event drv_change_interface: OK
[   23.981171] Testing event drv_remove_interface: OK
[   23.997201] Testing event drv_config: OK
[   24.013101] Testing event drv_bss_info_changed: OK
[   24.029005] Testing event drv_prepare_multicast: OK
[   24.045075] Testing event drv_configure_filter: OK
[   24.061514] Testing event drv_set_tim: OK
[   24.077214] Testing event drv_set_key: OK
[   24.093005] Testing event drv_update_tkip_key: OK
[   24.109160] Testing event drv_hw_scan: OK
[   24.125424] Testing event drv_cancel_hw_scan: OK
[   24.141314] Testing event drv_sched_scan_start: OK
[   24.157206] Testing event drv_sched_scan_stop: OK
[   24.173138] Testing event drv_sw_scan_start: OK
[   24.189055] Testing event drv_sw_scan_complete: OK
[   24.205109] Testing event drv_get_stats: OK
[   24.221175] Testing event drv_get_tkip_seq: OK
[   24.237194] Testing event drv_set_frag_threshold: OK
[   24.270516] Testing event drv_set_rts_threshold: OK
[   24.289164] Testing event drv_set_coverage_class: OK
[   24.305033] Testing event drv_sta_notify: OK
[   24.324894] Testing event drv_sta_state: OK
[   24.340950] Testing event drv_sta_rc_update: OK
[   24.356982] Testing event drv_sta_add: OK
[   24.373527] Testing event drv_sta_remove: OK
[   24.388948] Testing event drv_conf_tx: OK
[   24.405735] Testing event drv_get_tsf: OK
[   24.420903] Testing event drv_set_tsf: OK
[   24.437136] Testing event drv_reset_tsf: OK
[   24.453049] Testing event drv_tx_last_beacon: OK
[   24.469261] Testing event drv_ampdu_action: OK
[   24.485070] Testing event drv_get_survey: OK
[   24.501282] Testing event drv_flush: OK
[   24.517080] Testing event drv_channel_switch: OK
[   24.533322] Testing event drv_set_antenna: OK
[   24.549101] Testing event drv_get_antenna: OK
[   24.565163] Testing event drv_remain_on_channel: OK
[   24.581386] Testing event drv_cancel_remain_on_channel: OK
[   24.597371] Testing event drv_offchannel_tx: OK
[   24.613066] Testing event drv_set_ringparam: OK
[   24.629060] Testing event drv_get_ringparam: OK
[   24.645043] Testing event drv_tx_frames_pending: OK
[   24.661013] Testing event drv_offchannel_tx_cancel_wait: OK
[   24.677853] Testing event drv_set_bitrate_mask: OK
[   24.692892] Testing event drv_set_rekey_data: OK
[   24.709079] Testing event drv_rssi_callback: OK
[   24.724800] Testing event drv_release_buffered_frames: OK
[   24.741140] Testing event drv_allow_buffered_frames: OK
[   24.756944] Testing event drv_get_rssi: OK
[   24.773308] Testing event drv_mgd_prepare_tx: OK
[   24.789113] Testing event api_start_tx_ba_session: OK
[   24.804955] Testing event api_start_tx_ba_cb: OK
[   24.821128] Testing event api_stop_tx_ba_session: OK
[   24.837162] Testing event api_stop_tx_ba_cb: OK
[   24.853070] Testing event api_restart_hw: OK
[   24.869342] Testing event api_beacon_loss: OK
[   24.884888] Testing event api_connection_loss: OK
[   24.901721] Testing event api_cqm_rssi_notify: OK
[   24.919275] Testing event api_scan_completed: OK
[   24.937047] Testing event api_sched_scan_results: OK
[   24.953500] Testing event api_sched_scan_stopped: OK
[   24.969560] Testing event api_sta_block_awake: OK
[   24.985266] Testing event api_chswitch_done: OK
[   25.001386] Testing event api_ready_on_channel: OK
[   25.017528] Testing event api_remain_on_channel_expired: OK
[   25.032819] Testing event api_gtk_rekey_notify: OK
[   25.049163] Testing event api_enable_rssi_reports: OK
[   25.065400] Testing event api_eosp: OK
[   25.081146] Testing event wake_queue: OK
[   25.098260] Testing event stop_queue: OK
[   25.117145] Testing event rpc_call_status: OK
[   25.133285] Testing event rpc_bind_status: OK
[   25.149195] Testing event rpc_connect_status: OK
[   25.164848] Testing event rpc_task_begin: OK
[   25.181114] Testing event rpc_task_run_action: OK
[   25.198333] Testing event rpc_task_complete: OK
[   25.217524] Testing event rpc_task_sleep: OK
[   25.243305] Testing event rpc_task_wakeup: OK
[   25.261026] Testing event kfree_skb: OK
[   25.277141] Testing event consume_skb: OK
[   25.297087] Testing event skb_copy_datagram_iovec: OK
[   25.315390] Testing event net_dev_xmit: OK
[   25.333195] Testing event net_dev_queue: OK
[   25.349816] Testing event netif_receive_skb: OK
[   25.369157] Testing event netif_rx: OK
[   25.385438] Testing event napi_poll: OK
[   25.405676] Testing event sock_rcvqueue_full: OK
[   25.421195] Testing event sock_exceed_buf_limit: OK
[   25.437280] Testing event udp_fail_queue_rcv_skb: OK
[   25.458071] Testing event hda_send_cmd: OK
[   25.477756] Testing event hda_get_response: OK
[   25.497598] Testing event hda_bus_reset: OK
[   25.517654] Testing event hda_power_down: OK
[   25.533142] Testing event hda_power_up: OK
[   25.549447] Testing event hda_unsol_event: OK
[   25.567428] Testing event mc_event: OK
[   25.586842] Testing event scsi_dispatch_cmd_start: OK
[   25.605564] Testing event scsi_dispatch_cmd_error: OK
[   25.625566] Testing event scsi_dispatch_cmd_done: OK
[   25.645229] Testing event scsi_dispatch_cmd_timeout: OK
[   25.661600] Testing event scsi_eh_wakeup: OK
[   25.689148] Testing event regmap_reg_write: OK
[   25.705803] Testing event regmap_reg_read: OK
[   25.721431] Testing event regmap_reg_read_cache: OK
[   25.737516] Testing event regmap_hw_read_start: OK
[   25.763943] Testing event regmap_hw_read_done: OK
[   25.781575] Testing event regmap_hw_write_start: OK
[   25.797569] Testing event regmap_hw_write_done: OK
[   25.813132] Testing event regcache_sync: OK
[   25.829189] Testing event regmap_cache_only: OK
[   25.845629] Testing event regmap_cache_bypass: OK
[   25.862878] Testing event i915_gem_object_create: OK
[   25.881829] Testing event i915_gem_object_bind: OK
[   25.912949] Testing event i915_gem_object_unbind: OK
[   25.933575] Testing event i915_gem_object_change_domain: OK
[   25.952622] Testing event i915_gem_object_pwrite: OK
[   25.969847] Testing event i915_gem_object_pread: OK
[   25.989127] Testing event i915_gem_object_fault: OK
[   26.021423] Testing event i915_gem_object_clflush: OK
[   26.041181] Testing event i915_gem_object_destroy: OK
[   26.057421] Testing event i915_gem_evict: OK
[   26.073457] Testing event i915_gem_evict_everything: OK
[   26.101657] Testing event i915_gem_ring_dispatch: OK
[   26.121578] Testing event i915_gem_ring_flush: OK
[   26.140975] Testing event i915_gem_request_add: OK
[   26.157380] Testing event i915_gem_request_complete: OK
[   26.173181] Testing event i915_gem_request_retire: OK
[   26.189520] Testing event i915_gem_request_wait_begin: OK
[   26.204905] Testing event i915_gem_request_wait_end: OK
[   26.221515] Testing event i915_ring_wait_begin: OK
[   26.241410] Testing event i915_ring_wait_end: OK
[   26.265661] Testing event i915_flip_request: OK
[   26.281438] Testing event i915_flip_complete: OK
[   26.306850] Testing event i915_reg_rw: OK
[   26.325087] Testing event radeon_bo_create: OK
[   26.341368] Testing event radeon_fence_emit: OK
[   26.361119] Testing event radeon_fence_retire: OK
[   26.377548] Testing event radeon_fence_wait_begin: OK
[   26.393455] Testing event radeon_fence_wait_end: OK
[   26.415174] Testing event drm_vblank_event: OK
[   26.433161] Testing event drm_vblank_event_queued: OK
[   26.448821] Testing event drm_vblank_event_delivered: OK
[   26.465123] Testing event mix_pool_bytes: OK
[   26.481528] Testing event mix_pool_bytes_nolock: OK
[   26.497116] Testing event credit_entropy_bits: OK
[   26.513157] Testing event get_random_bytes: OK
[   26.529117] Testing event extract_entropy: OK
[   26.545118] Testing event extract_entropy_user: OK
[   26.569097] Testing event regulator_enable: OK
[   26.585266] Testing event regulator_enable_delay: OK
[   26.601866] Testing event regulator_enable_complete: OK
[   26.617156] Testing event regulator_disable: OK
[   26.637091] Testing event regulator_disable_complete: OK
[   26.653028] Testing event regulator_set_voltage: OK
[   26.669194] Testing event regulator_set_voltage_complete: OK
[   26.685358] Testing event gpio_direction: OK
[   26.701122] Testing event gpio_value: OK
[   26.717118] Testing event block_rq_abort: OK
[   26.733120] Testing event block_rq_requeue: OK
[   26.748849] Testing event block_rq_complete: OK
[   26.765447] Testing event block_rq_insert: OK
[   26.781538] Testing event block_rq_issue: OK
[   26.801133] Testing event block_bio_bounce: OK
[   26.817190] Testing event block_bio_complete: OK
[   26.834463] Testing event block_bio_backmerge: OK
[   26.853606] Testing event block_bio_frontmerge: OK
[   26.899285] Testing event block_bio_queue: OK
[   26.933215] Testing event block_getrq: OK
[   26.949106] Testing event block_sleeprq: OK
[   26.969204] Testing event block_plug: OK
[   26.990275] Testing event block_unplug: OK
[   27.009612] Testing event block_split: OK
[   27.025527] Testing event block_bio_remap: OK
[   27.041177] Testing event block_rq_remap: OK
[   27.057734] Testing event gfs2_glock_state_change: OK
[   27.073130] Testing event gfs2_glock_put: OK
[   27.089201] Testing event gfs2_demote_rq: OK
[   27.105949] Testing event gfs2_promote: OK
[   27.129495] Testing event gfs2_glock_queue: OK
[   27.145576] Testing event gfs2_glock_lock_time: OK
[   27.169035] Testing event gfs2_pin: OK
[   27.192206] Testing event gfs2_log_flush: OK
[   27.221198] Testing event gfs2_log_blocks: OK
[   27.237275] Testing event gfs2_ail_flush: OK
[   27.253052] Testing event gfs2_bmap: OK
[   27.269084] Testing event gfs2_block_alloc: OK
[   27.285124] Testing event gfs2_rs: OK
[   27.301155] Testing event btrfs_transaction_commit: OK
[   27.324953] Testing event btrfs_inode_new: OK
[   27.341185] Testing event btrfs_inode_request: OK
[   27.357167] Testing event btrfs_inode_evict: OK
[   27.373193] Testing event btrfs_get_extent: OK
[   27.390154] Testing event btrfs_ordered_extent_add: OK
[   27.409138] Testing event btrfs_ordered_extent_remove: OK
[   27.426751] Testing event btrfs_ordered_extent_start: OK
[   27.445009] Testing event btrfs_ordered_extent_put: OK
[   27.461225] Testing event __extent_writepage: OK
[   27.477181] Testing event btrfs_writepage_end_io_hook: OK
[   27.493573] Testing event btrfs_sync_file: OK
[   27.508854] Testing event btrfs_sync_fs: OK
[   27.525502] Testing event btrfs_delayed_tree_ref: OK
[   27.542488] Testing event btrfs_delayed_data_ref: OK
[   27.566359] Testing event btrfs_delayed_ref_head: OK
[   27.585274] Testing event btrfs_chunk_alloc: OK
[   27.621849] Testing event btrfs_chunk_free: OK
[   27.664648] Testing event btrfs_cow_block: OK
[   27.681680] Testing event btrfs_space_reservation: OK
[   27.697187] Testing event btrfs_reserved_extent_alloc: OK
[   27.716550] Testing event btrfs_reserved_extent_free: OK
[   27.744208] Testing event find_free_extent: OK
[   27.761274] Testing event btrfs_reserve_extent: OK
[   27.777248] Testing event btrfs_reserve_extent_cluster: OK
[   27.794671] Testing event btrfs_find_cluster: OK
[   27.813379] Testing event btrfs_failed_cluster_setup: OK
[   27.830158] Testing event btrfs_setup_cluster: OK
[   27.863126] Testing event alloc_extent_state: OK
[   27.893963] Testing event free_extent_state: OK
[   27.913481] Testing event ocfs2_adjust_rightmost_branch: OK
[   27.929617] Testing event ocfs2_rotate_tree_right: OK
[   27.977598] Testing event ocfs2_append_rec_to_path: OK
[   27.993602] Testing event ocfs2_insert_extent_start: OK
[   28.025427] Testing event ocfs2_add_clusters_in_btree: OK
[   28.042090] Testing event ocfs2_num_free_extents: OK
[   28.057470] Testing event ocfs2_complete_edge_insert: OK
[   28.073943] Testing event ocfs2_grow_tree: OK
[   28.089272] Testing event ocfs2_rotate_subtree: OK
[   28.105227] Testing event ocfs2_insert_extent: OK
[   28.131055] Testing event ocfs2_split_extent: OK
[   28.157504] Testing event ocfs2_remove_extent: OK
[   28.175018] Testing event ocfs2_commit_truncate: OK
[   28.193281] Testing event ocfs2_validate_extent_block: OK
[   28.209828] Testing event ocfs2_rotate_leaf: OK
[   28.225828] Testing event ocfs2_add_clusters_in_btree_ret: OK
[   28.241111] Testing event ocfs2_mark_extent_written: OK
[   28.257098] Testing event ocfs2_truncate_log_append: OK
[   28.272895] Testing event ocfs2_replay_truncate_records: OK
[   28.290029] Testing event ocfs2_flush_truncate_log: OK
[   28.309147] Testing event ocfs2_begin_truncate_log_recovery: OK
[   28.324988] Testing event ocfs2_truncate_log_recovery_num: OK
[   28.355989] Testing event ocfs2_complete_truncate_log_recovery: OK
[   28.389463] Testing event ocfs2_free_cached_blocks: OK
[   28.409172] Testing event ocfs2_cache_cluster_dealloc: OK
[   28.433088] Testing event ocfs2_run_deallocs: OK
[   28.453577] Testing event ocfs2_cache_block_dealloc: OK
[   28.473232] Testing event ocfs2_trim_extent: OK
[   28.489458] Testing event ocfs2_trim_group: OK
[   28.505233] Testing event ocfs2_trim_fs: OK
[   28.525721] Testing event ocfs2_la_set_sizes: OK
[   28.541317] Testing event ocfs2_alloc_should_use_local: OK
[   28.557291] Testing event ocfs2_load_local_alloc: OK
[   28.574044] Testing event ocfs2_begin_local_alloc_recovery: OK
[   28.597292] Testing event ocfs2_reserve_local_alloc_bits: OK
[   28.617027] Testing event ocfs2_local_alloc_count_bits: OK
[   28.632980] Testing event ocfs2_local_alloc_find_clear_bits_search_bitmap: OK
[   28.650053] Testing event ocfs2_local_alloc_find_clear_bits: OK
[   28.669212] Testing event ocfs2_sync_local_to_main: OK
[   28.690619] Testing event ocfs2_sync_local_to_main_free: OK
[   28.727337] Testing event ocfs2_local_alloc_new_window: OK
[   28.757479] Testing event ocfs2_local_alloc_new_window_result: OK
[   28.777224] Testing event ocfs2_update_last_group_and_inode: OK
[   28.795324] Testing event ocfs2_group_extend: OK
[   28.813116] Testing event ocfs2_group_add: OK
[   28.829010] Testing event ocfs2_validate_group_descriptor: OK
[   28.845357] Testing event ocfs2_block_group_alloc_contig: OK
[   28.861115] Testing event ocfs2_block_group_alloc_discontig: OK
[   28.877250] Testing event ocfs2_block_group_alloc: OK
[   28.893122] Testing event ocfs2_reserve_suballoc_bits_nospc: OK
[   28.909769] Testing event ocfs2_reserve_suballoc_bits_no_new_group: OK
[   28.928812] Testing event ocfs2_reserve_new_inode_new_group: OK
[   28.945193] Testing event ocfs2_block_group_set_bits: OK
[   28.962768] Testing event ocfs2_relink_block_group: OK
[   28.981188] Testing event ocfs2_cluster_group_search_wrong_max_bits: OK
[   28.997114] Testing event ocfs2_cluster_group_search_max_block: OK
[   29.017156] Testing event ocfs2_block_group_search_max_block: OK
[   29.032994] Testing event ocfs2_search_chain_begin: OK
[   29.049755] Testing event ocfs2_search_chain_succ: OK
[   29.065226] Testing event ocfs2_search_chain_end: OK
[   29.081222] Testing event ocfs2_claim_suballoc_bits: OK
[   29.097178] Testing event ocfs2_claim_new_inode_at_loc: OK
[   29.120657] Testing event ocfs2_block_group_clear_bits: OK
[   29.141199] Testing event ocfs2_free_suballoc_bits: OK
[   29.166795] Testing event ocfs2_free_clusters: OK
[   29.189229] Testing event ocfs2_get_suballoc_slot_bit: OK
[   29.205156] Testing event ocfs2_test_suballoc_bit: OK
[   29.221184] Testing event ocfs2_test_inode_bit: OK
[   29.237129] Testing event ocfs2_validate_refcount_block: OK
[   29.260263] Testing event ocfs2_purge_refcount_trees: OK
[   29.277187] Testing event ocfs2_create_refcount_tree: OK
[   29.297139] Testing event ocfs2_create_refcount_tree_blkno: OK
[   29.318748] Testing event ocfs2_change_refcount_rec: OK
[   29.337234] Testing event ocfs2_expand_inline_ref_root: OK
[   29.353268] Testing event ocfs2_divide_leaf_refcount_block: OK
[   29.377867] Testing event ocfs2_new_leaf_refcount_block: OK
[   29.393113] Testing event ocfs2_insert_refcount_rec: OK
[   29.409201] Testing event ocfs2_split_refcount_rec: OK
[   29.428098] Testing event ocfs2_split_refcount_rec_insert: OK
[   29.445029] Testing event ocfs2_increase_refcount_begin: OK
[   29.471597] Testing event ocfs2_increase_refcount_change: OK
[   29.490061] Testing event ocfs2_increase_refcount_insert: OK
[   29.509198] Testing event ocfs2_increase_refcount_split: OK
[   29.525091] Testing event ocfs2_remove_refcount_extent: OK
[   29.545549] Testing event ocfs2_restore_refcount_block: OK
[   29.561184] Testing event ocfs2_decrease_refcount_rec: OK
[   29.601845] Testing event ocfs2_decrease_refcount: OK
[   29.621127] Testing event ocfs2_mark_extent_refcounted: OK
[   29.637055] Testing event ocfs2_calc_refcount_meta_credits: OK
[   29.660845] Testing event ocfs2_calc_refcount_meta_credits_iterate: OK
[   29.677856] Testing event ocfs2_add_refcount_flag: OK
[   29.693339] Testing event ocfs2_prepare_refcount_change_for_del: OK
[   29.709115] Testing event ocfs2_lock_refcount_allocators: OK
[   29.726019] Testing event ocfs2_duplicate_clusters_by_page: OK
[   29.745059] Testing event ocfs2_duplicate_clusters_by_jbd: OK
[   29.761008] Testing event ocfs2_clear_ext_refcount: OK
[   29.777539] Testing event ocfs2_replace_clusters: OK
[   29.794187] Testing event ocfs2_make_clusters_writable: OK
[   29.813323] Testing event ocfs2_refcount_cow_hunk: OK
[   29.831185] Testing event ocfs2_symlink_get_block: OK
[   29.849134] Testing event ocfs2_get_block: OK
[   29.865956] Testing event ocfs2_get_block_end: OK
[   29.885146] Testing event ocfs2_readpage: OK
[   29.901186] Testing event ocfs2_writepage: OK
[   29.917157] Testing event ocfs2_bmap: OK
[   29.933185] Testing event ocfs2_try_to_write_inline_data: OK
[   29.949223] Testing event ocfs2_write_begin_nolock: OK
[   29.965042] Testing event ocfs2_write_end_inline: OK
[   29.981367] Testing event ocfs2_fault: OK
[   29.997596] Testing event ocfs2_file_open: OK
[   30.013759] Testing event ocfs2_file_release: OK
[   30.033089] Testing event ocfs2_sync_file: OK
[   30.049237] Testing event ocfs2_file_aio_write: OK
[   30.065198] Testing event ocfs2_file_splice_write: OK
[   30.081118] Testing event ocfs2_file_splice_read: OK
[   30.097491] Testing event ocfs2_file_aio_read: OK
[   30.113413] Testing event ocfs2_truncate_file: OK
[   30.129702] Testing event ocfs2_truncate_file_error: OK
[   30.149653] Testing event ocfs2_extend_allocation: OK
[   30.168174] Testing event ocfs2_extend_allocation_end: OK
[   30.185048] Testing event ocfs2_write_zero_page: OK
[   30.205446] Testing event ocfs2_zero_extend_range: OK
[   30.229399] Testing event ocfs2_zero_extend: OK
[   30.248568] Testing event ocfs2_setattr: OK
[   30.265494] Testing event ocfs2_write_remove_suid: OK
[   30.281303] Testing event ocfs2_zero_partial_clusters: OK
[   30.309374] Testing event ocfs2_zero_partial_clusters_range1: OK
[   30.330186] Testing event ocfs2_zero_partial_clusters_range2: OK
[   30.351170] Testing event ocfs2_remove_inode_range: OK
[   30.369503] Testing event ocfs2_prepare_inode_for_write: OK
[   30.389538] Testing event generic_file_aio_read_ret: OK
[   30.411869] Testing event ocfs2_iget_begin: OK
[   30.429974] Testing event ocfs2_iget5_locked: OK
[   30.446151] Testing event ocfs2_iget_end: OK
[   30.465286] Testing event ocfs2_find_actor: OK
[   30.481144] Testing event ocfs2_populate_inode: OK
[   30.501170] Testing event ocfs2_read_locked_inode: OK
[   30.517184] Testing event ocfs2_check_orphan_recovery_state: OK
[   30.533173] Testing event ocfs2_validate_inode_block: OK
[   30.549473] Testing event ocfs2_inode_is_valid_to_delete: OK
[   30.565203] Testing event ocfs2_query_inode_wipe_begin: OK
[   30.581362] Testing event ocfs2_query_inode_wipe_succ: OK
[   30.597071] Testing event ocfs2_query_inode_wipe_end: OK
[   30.613189] Testing event ocfs2_cleanup_delete_inode: OK
[   30.629211] Testing event ocfs2_delete_inode: OK
[   30.645251] Testing event ocfs2_clear_inode: OK
[   30.661396] Testing event ocfs2_drop_inode: OK
[   30.677552] Testing event ocfs2_inode_revalidate: OK
[   30.693520] Testing event ocfs2_mark_inode_dirty: OK
[   30.763243] Testing event ocfs2_read_virt_blocks: OK
[   30.793504] Testing event ocfs2_refresh_slot_info: OK
[   30.809538] Testing event ocfs2_map_slot_buffers: OK
[   30.829117] Testing event ocfs2_map_slot_buffers_block: OK
[   30.845430] Testing event ocfs2_find_slot: OK
[   30.861707] Testing event ocfs2_do_node_down: OK
[   30.908137] Testing event ocfs2_remount: OK
[   30.925491] Testing event ocfs2_fill_super: OK
[   30.941047] Testing event ocfs2_parse_options: OK
[   30.959044] Testing event ocfs2_put_super: OK
[   30.977617] Testing event ocfs2_statfs: OK
[   30.997546] Testing event ocfs2_dismount_volume: OK
[   31.017115] Testing event ocfs2_initialize_super: OK
[   31.033109] Testing event ocfs2_validate_xattr_block: OK
[   31.048974] Testing event ocfs2_xattr_extend_allocation: OK
[   31.069271] Testing event ocfs2_init_xattr_set_ctxt: OK
[   31.085360] Testing event ocfs2_xattr_bucket_find: OK
[   31.101676] Testing event ocfs2_xattr_index_block_find: OK
[   31.117554] Testing event ocfs2_xattr_index_block_find_rec: OK
[   31.145450] Testing event ocfs2_iterate_xattr_buckets: OK
[   31.165539] Testing event ocfs2_iterate_xattr_bucket: OK
[   31.189103] Testing event ocfs2_cp_xattr_block_to_bucket_begin: OK
[   31.209153] Testing event ocfs2_cp_xattr_block_to_bucket_end: OK
[   31.228197] Testing event ocfs2_xattr_create_index_block_begin: OK
[   31.247207] Testing event ocfs2_xattr_create_index_block: OK
[   31.273330] Testing event ocfs2_defrag_xattr_bucket: OK
[   31.289382] Testing event ocfs2_mv_xattr_bucket_cross_cluster: OK
[   31.315181] Testing event ocfs2_divide_xattr_bucket_begin: OK
[   31.333414] Testing event ocfs2_divide_xattr_bucket_move: OK
[   31.351263] Testing event ocfs2_cp_xattr_bucket: OK
[   31.375403] Testing event ocfs2_mv_xattr_buckets: OK
[   31.422451] Testing event ocfs2_adjust_xattr_cross_cluster: OK
[   31.449520] Testing event ocfs2_add_new_xattr_cluster_begin: OK
[   31.465603] Testing event ocfs2_add_new_xattr_cluster: OK
[   31.482130] Testing event ocfs2_add_new_xattr_cluster_insert: OK
[   31.501591] Testing event ocfs2_extend_xattr_bucket: OK
[   31.529143] Testing event ocfs2_add_new_xattr_bucket: OK
[   31.549455] Testing event ocfs2_xattr_bucket_value_truncate: OK
[   31.569274] Testing event ocfs2_rm_xattr_cluster: OK
[   31.585187] Testing event ocfs2_reflink_xattr_header: OK
[   31.605065] Testing event ocfs2_create_empty_xattr_block: OK
[   31.621163] Testing event ocfs2_xattr_set_entry_bucket: OK
[   31.637153] Testing event ocfs2_xattr_set_entry_index_block: OK
[   31.653536] Testing event ocfs2_xattr_bucket_value_refcount: OK
[   31.669582] Testing event ocfs2_reflink_xattr_buckets: OK
[   31.689542] Testing event ocfs2_reflink_xattr_rec: OK
[   31.784546] Testing event ocfs2_resv_insert: OK
[   31.817405] Testing event ocfs2_resmap_find_free_bits_begin: OK
[   31.833535] Testing event ocfs2_resmap_find_free_bits_end: OK
[   31.849613] Testing event ocfs2_resv_find_window_begin: OK
[   31.889520] Testing event ocfs2_resv_find_window_prev: OK
[   31.906510] Testing event ocfs2_resv_find_window_next: OK
[   31.929468] Testing event ocfs2_cannibalize_resv_begin: OK
[   31.945499] Testing event ocfs2_cannibalize_resv_end: OK
[   31.985216] Testing event ocfs2_resmap_resv_bits: OK
[   32.001050] Testing event ocfs2_resmap_claimed_bits_begin: OK
[   32.017195] Testing event ocfs2_resmap_claimed_bits_end: OK
[   32.033023] Testing event ocfs2_recover_local_quota_file: OK
[   32.049532] Testing event ocfs2_finish_quota_recovery: OK
[   32.068964] Testing event olq_set_dquot: OK
[   32.084880] Testing event ocfs2_validate_quota_block: OK
[   32.100758] Testing event ocfs2_sync_dquot: OK
[   32.117103] Testing event ocfs2_sync_dquot_helper: OK
[   32.133053] Testing event ocfs2_write_dquot: OK
[   32.149106] Testing event ocfs2_release_dquot: OK
[   32.165198] Testing event ocfs2_acquire_dquot: OK
[   32.181127] Testing event ocfs2_mark_dquot_dirty: OK
[   32.201522] Testing event ocfs2_search_dirblock: OK
[   32.223129] Testing event ocfs2_validate_dir_block: OK
[   32.241904] Testing event ocfs2_find_entry_el: OK
[   32.269876] Testing event ocfs2_dx_dir_search: OK
[   32.301304] Testing event ocfs2_dx_dir_search_leaf_info: OK
[   32.329235] Testing event ocfs2_delete_entry_dx: OK
[   32.349420] Testing event ocfs2_readdir: OK
[   32.369219] Testing event ocfs2_find_files_on_disk: OK
[   32.385236] Testing event ocfs2_check_dir_for_entry: OK
[   32.409993] Testing event ocfs2_dx_dir_attach_index: OK
[   32.426996] Testing event ocfs2_dx_dir_format_cluster: OK
[   32.445543] Testing event ocfs2_dx_dir_index_root_block: OK
[   32.462860] Testing event ocfs2_extend_dir: OK
[   32.481241] Testing event ocfs2_dx_dir_rebalance: OK
[   32.497206] Testing event ocfs2_dx_dir_rebalance_split: OK
[   32.513598] Testing event ocfs2_prepare_dir_for_insert: OK
[   32.529228] Testing event ocfs2_lookup: OK
[   32.549269] Testing event ocfs2_mkdir: OK
[   32.565267] Testing event ocfs2_create: OK
[   32.581259] Testing event ocfs2_unlink: OK
[   32.604342] Testing event ocfs2_symlink_create: OK
[   32.621846] Testing event ocfs2_mv_orphaned_inode_to_new: OK
[   32.642123] Testing event ocfs2_lookup_ret: OK
[   32.657329] Testing event ocfs2_mknod: OK
[   32.673331] Testing event ocfs2_link: OK
[   32.693096] Testing event ocfs2_unlink_noent: OK
[   32.709850] Testing event ocfs2_double_lock: OK
[   32.729182] Testing event ocfs2_double_lock_end: OK
[   32.745657] Testing event ocfs2_rename: OK
[   32.761469] Testing event ocfs2_rename_target_exists: OK
[   32.777100] Testing event ocfs2_rename_disagree: OK
[   32.793322] Testing event ocfs2_rename_over_existing: OK
[   32.809191] Testing event ocfs2_create_symlink_data: OK
[   32.824881] Testing event ocfs2_symlink_begin: OK
[   32.845084] Testing event ocfs2_blkno_stringify: OK
[   32.861642] Testing event ocfs2_orphan_add_begin: OK
[   32.877139] Testing event ocfs2_orphan_add_end: OK
[   32.893124] Testing event ocfs2_orphan_del: OK
[   32.909558] Testing event ocfs2_dentry_revalidate: OK
[   32.925103] Testing event ocfs2_dentry_revalidate_negative: OK
[   32.941569] Testing event ocfs2_dentry_revalidate_delete: OK
[   32.957132] Testing event ocfs2_dentry_revalidate_orphaned: OK
[   32.973159] Testing event ocfs2_dentry_revalidate_nofsdata: OK
[   32.989167] Testing event ocfs2_dentry_revalidate_ret: OK
[   33.005041] Testing event ocfs2_find_local_alias: OK
[   33.020899] Testing event ocfs2_dentry_attach_lock: OK
[   33.036811] Testing event ocfs2_dentry_attach_lock_found: OK
[   33.053084] Testing event ocfs2_get_dentry_begin: OK
[   33.069175] Testing event ocfs2_get_dentry_test_bit: OK
[   33.085193] Testing event ocfs2_get_dentry_stale: OK
[   33.101118] Testing event ocfs2_get_dentry_generation: OK
[   33.117144] Testing event ocfs2_get_dentry_end: OK
[   33.132822] Testing event ocfs2_get_parent: OK
[   33.149094] Testing event ocfs2_get_parent_end: OK
[   33.166507] Testing event ocfs2_encode_fh_begin: OK
[   33.185469] Testing event ocfs2_encode_fh_self: OK
[   33.202320] Testing event ocfs2_encode_fh_parent: OK
[   33.217629] Testing event ocfs2_encode_fh_type: OK
[   33.237226] Testing event ocfs2_commit_cache_begin: OK
[   33.258843] Testing event ocfs2_commit_cache_end: OK
[   33.278480] Testing event ocfs2_extend_trans: OK
[   33.298145] Testing event ocfs2_extend_trans_restart: OK
[   33.313097] Testing event ocfs2_journal_access: OK
[   33.333232] Testing event ocfs2_journal_dirty: OK
[   33.354047] Testing event ocfs2_journal_init: OK
[   33.369131] Testing event ocfs2_journal_init_maxlen: OK
[   33.385155] Testing event ocfs2_journal_shutdown: OK
[   33.401110] Testing event ocfs2_journal_shutdown_wait: OK
[   33.416908] Testing event ocfs2_complete_recovery: OK
[   33.437143] Testing event ocfs2_complete_recovery_end: OK
[   33.458632] Testing event ocfs2_complete_recovery_slot: OK
[   33.480884] Testing event ocfs2_recovery_thread_node: OK
[   33.497090] Testing event ocfs2_recovery_thread_end: OK
[   33.513132] Testing event ocfs2_recovery_thread: OK
[   33.532906] Testing event ocfs2_replay_journal_recovered: OK
[   33.549143] Testing event ocfs2_replay_journal_lock_err: OK
[   33.578343] Testing event ocfs2_replay_journal_skip: OK
[   33.593339] Testing event ocfs2_recover_node: OK
[   33.611220] Testing event ocfs2_recover_node_skip: OK
[   33.629137] Testing event ocfs2_mark_dead_nodes: OK
[   33.645070] Testing event ocfs2_queue_orphan_scan_begin: OK
[   33.665109] Testing event ocfs2_queue_orphan_scan_end: OK
[   33.685042] Testing event ocfs2_orphan_filldir: OK
[   33.701184] Testing event ocfs2_recover_orphans: OK
[   33.717189] Testing event ocfs2_recover_orphans_iput: OK
[   33.733164] Testing event ocfs2_wait_on_mount: OK
[   33.753644] Testing event ocfs2_read_blocks_sync: OK
[   33.770943] Testing event ocfs2_read_blocks_sync_jbd: OK
[   33.789201] Testing event ocfs2_read_blocks_from_disk: OK
[   33.805155] Testing event ocfs2_read_blocks_bh: OK
[   33.826854] Testing event ocfs2_read_blocks_end: OK
[   33.846749] Testing event ocfs2_write_block: OK
[   33.865531] Testing event ocfs2_read_blocks_begin: OK
[   33.896123] Testing event ocfs2_purge_copied_metadata_tree: OK
[   33.913512] Testing event ocfs2_metadata_cache_purge: OK
[   33.930117] Testing event ocfs2_buffer_cached_begin: OK
[   33.953134] Testing event ocfs2_buffer_cached_end: OK
[   33.969535] Testing event ocfs2_append_cache_array: OK
[   33.986200] Testing event ocfs2_insert_cache_tree: OK
[   34.005414] Testing event ocfs2_expand_cache: OK
[   34.029605] Testing event ocfs2_set_buffer_uptodate: OK
[   34.045273] Testing event ocfs2_set_buffer_uptodate_begin: OK
[   34.062007] Testing event ocfs2_remove_metadata_array: OK
[   34.081467] Testing event ocfs2_remove_metadata_tree: OK
[   34.098755] Testing event ocfs2_remove_block_from_cache: OK
[   34.117354] Testing event xfs_attr_list_sf: OK
[   34.133204] Testing event xfs_attr_list_sf_all: OK
[   34.149473] Testing event xfs_attr_list_leaf: OK
[   34.165505] Testing event xfs_attr_list_leaf_end: OK
[   34.181892] Testing event xfs_attr_list_full: OK
[   34.203473] Testing event xfs_attr_list_add: OK
[   34.221416] Testing event xfs_attr_list_wrong_blk: OK
[   34.237477] Testing event xfs_attr_list_notfound: OK
[   34.257144] Testing event xfs_perag_get: OK
[   34.274689] Testing event xfs_perag_get_tag: OK
[   34.297360] Testing event xfs_perag_put: OK
[   34.313395] Testing event xfs_perag_set_reclaim: OK
[   34.329819] Testing event xfs_perag_clear_reclaim: OK
[   34.353250] Testing event xfs_attr_list_node_descend: OK
[   34.369114] Testing event xfs_iext_insert: OK
[   34.385432] Testing event xfs_iext_remove: OK
[   34.400858] Testing event xfs_bmap_pre_update: OK
[   34.416769] Testing event xfs_bmap_post_update: OK
[   34.437121] Testing event xfs_extlist: OK
[   34.453467] Testing event xfs_buf_init: OK
[   34.472739] Testing event xfs_buf_free: OK
[   34.489030] Testing event xfs_buf_hold: OK
[   34.534411] Testing event xfs_buf_rele: OK
[   34.553201] Testing event xfs_buf_iodone: OK
[   34.577864] Testing event xfs_buf_iorequest: OK
[   34.593591] Testing event xfs_buf_bawrite: OK
[   34.609219] Testing event xfs_buf_lock: OK
[   34.629133] Testing event xfs_buf_lock_done: OK
[   34.645387] Testing event xfs_buf_trylock: OK
[   34.661391] Testing event xfs_buf_unlock: OK
[   34.688684] Testing event xfs_buf_iowait: OK
[   34.712487] Testing event xfs_buf_iowait_done: OK
[   34.729571] Testing event xfs_buf_delwri_queue: OK
[   34.745692] Testing event xfs_buf_delwri_queued: OK
[   34.765189] Testing event xfs_buf_delwri_split: OK
[   34.782135] Testing event xfs_buf_get_uncached: OK
[   34.801553] Testing event xfs_bdstrat_shut: OK
[   34.831309] Testing event xfs_buf_item_relse: OK
[   34.848981] Testing event xfs_buf_item_iodone: OK
[   34.864975] Testing event xfs_buf_item_iodone_async: OK
[   34.884839] Testing event xfs_buf_error_relse: OK
[   34.901111] Testing event xfs_trans_read_buf_io: OK
[   34.919798] Testing event xfs_trans_read_buf_shut: OK
[   34.937162] Testing event xfs_btree_corrupt: OK
[   34.953585] Testing event xfs_da_btree_corrupt: OK
[   34.977209] Testing event xfs_reset_dqcounts: OK
[   34.993166] Testing event xfs_inode_item_push: OK
[   35.037796] Testing event xfs_buf_find: OK
[   35.059219] Testing event xfs_buf_get: OK
[   35.077112] Testing event xfs_buf_read: OK
[   35.094590] Testing event xfs_buf_ioerror: OK
[   35.112946] Testing event xfs_buf_item_size: OK
[   35.141856] Testing event xfs_buf_item_size_stale: OK
[   35.169183] Testing event xfs_buf_item_format: OK
[   35.185084] Testing event xfs_buf_item_format_stale: OK
[   35.205068] Testing event xfs_buf_item_pin: OK
[   35.222093] Testing event xfs_buf_item_unpin: OK
[   35.260390] Testing event xfs_buf_item_unpin_stale: OK
[   35.280543] Testing event xfs_buf_item_unlock: OK
[   35.297817] Testing event xfs_buf_item_unlock_stale: OK
[   35.320371] Testing event xfs_buf_item_committed: OK
[   35.337207] Testing event xfs_buf_item_push: OK
[   35.356505] Testing event xfs_trans_get_buf: OK
[   35.373466] Testing event xfs_trans_get_buf_recur: OK
[   35.405038] Testing event xfs_trans_getsb: OK
[   35.428327] Testing event xfs_trans_getsb_recur: OK
[   35.444836] Testing event xfs_trans_read_buf: OK
[   35.461155] Testing event xfs_trans_read_buf_recur: OK
[   35.480781] Testing event xfs_trans_log_buf: OK
[   35.497458] Testing event xfs_trans_brelse: OK
[   35.513102] Testing event xfs_trans_bjoin: OK
[   35.529015] Testing event xfs_trans_bhold: OK
[   35.545230] Testing event xfs_trans_bhold_release: OK
[   35.564855] Testing event xfs_trans_binval: OK
[   35.591783] Testing event xfs_ilock: OK
[   35.609083] Testing event xfs_ilock_nowait: OK
[   35.632189] Testing event xfs_ilock_demote: OK
[   35.650020] Testing event xfs_iunlock: OK
[   35.669752] Testing event xfs_iget_skip: OK
[   35.697216] Testing event xfs_iget_reclaim: OK
[   35.717959] Testing event xfs_iget_reclaim_fail: OK
[   35.742526] Testing event xfs_iget_hit: OK
[   35.761242] Testing event xfs_iget_miss: OK
[   35.781480] Testing event xfs_getattr: OK
[   35.797287] Testing event xfs_setattr: OK
[   35.820233] Testing event xfs_readlink: OK
[   35.840752] Testing event xfs_alloc_file_space: OK
[   35.857148] Testing event xfs_free_file_space: OK
[   35.874452] Testing event xfs_readdir: OK
[   35.893834] Testing event xfs_get_acl: OK
[   35.909036] Testing event xfs_vm_bmap: OK
[   35.925342] Testing event xfs_file_ioctl: OK
[   35.941060] Testing event xfs_file_compat_ioctl: OK
[   35.958855] Testing event xfs_ioctl_setattr: OK
[   35.977085] Testing event xfs_dir_fsync: OK
[   35.993165] Testing event xfs_file_fsync: OK
[   36.015202] Testing event xfs_destroy_inode: OK
[   36.038772] Testing event xfs_evict_inode: OK
[   36.057909] Testing event xfs_update_time: OK
[   36.073070] Testing event xfs_dquot_dqalloc: OK
[   36.089698] Testing event xfs_dquot_dqdetach: OK
[   36.105134] Testing event xfs_ihold: OK
[   36.129084] Testing event xfs_irele: OK
[   36.145139] Testing event xfs_inode_pin: OK
[   36.164355] Testing event xfs_inode_unpin: OK
[   36.181215] Testing event xfs_inode_unpin_nowait: OK
[   36.197051] Testing event xfs_remove: OK
[   36.213843] Testing event xfs_link: OK
[   36.229419] Testing event xfs_lookup: OK
[   36.251160] Testing event xfs_create: OK
[   36.270563] Testing event xfs_symlink: OK
[   36.289874] Testing event xfs_rename: OK
[   36.306289] Testing event xfs_dqadjust: OK
[   36.321172] Testing event xfs_dqreclaim_want: OK
[   36.337313] Testing event xfs_dqreclaim_dirty: OK
[   36.353168] Testing event xfs_dqreclaim_busy: OK
[   36.369156] Testing event xfs_dqreclaim_done: OK
[   36.385653] Testing event xfs_dqattach_found: OK
[   36.401538] Testing event xfs_dqattach_get: OK
[   36.416838] Testing event xfs_dqalloc: OK
[   36.433469] Testing event xfs_dqtobp_read: OK
[   36.453530] Testing event xfs_dqread: OK
[   36.473490] Testing event xfs_dqread_fail: OK
[   36.497114] Testing event xfs_dqget_hit: OK
[   36.517129] Testing event xfs_dqget_miss: OK
[   36.533231] Testing event xfs_dqget_freeing: OK
[   36.549435] Testing event xfs_dqget_dup: OK
[   36.565249] Testing event xfs_dqput: OK
[   36.580943] Testing event xfs_dqput_wait: OK
[   36.598006] Testing event xfs_dqput_free: OK
[   36.613191] Testing event xfs_dqrele: OK
[   36.629191] Testing event xfs_dqflush: OK
[   36.645510] Testing event xfs_dqflush_force: OK
[   36.661967] Testing event xfs_dqflush_done: OK
[   36.681562] Testing event xfs_log_done_nonperm: OK
[   36.697355] Testing event xfs_log_done_perm: OK
[   36.715323] Testing event xfs_log_umount_write: OK
[   36.733191] Testing event xfs_log_grant_sleep: OK
[   36.749050] Testing event xfs_log_grant_wake: OK
[   36.765080] Testing event xfs_log_grant_wake_up: OK
[   36.781123] Testing event xfs_log_reserve: OK
[   36.798147] Testing event xfs_log_reserve_exit: OK
[   36.817477] Testing event xfs_log_regrant: OK
[   36.841064] Testing event xfs_log_regrant_exit: OK
[   36.857136] Testing event xfs_log_regrant_reserve_enter: OK
[   36.873417] Testing event xfs_log_regrant_reserve_exit: OK
[   36.889564] Testing event xfs_log_regrant_reserve_sub: OK
[   36.907875] Testing event xfs_log_ungrant_enter: OK
[   36.925182] Testing event xfs_log_ungrant_exit: OK
[   36.941217] Testing event xfs_log_ungrant_sub: OK
[   36.956884] Testing event xfs_log_force: OK
[   36.973801] Testing event xfs_ail_push: OK
[   36.993071] Testing event xfs_ail_pinned: OK
[   37.009132] Testing event xfs_ail_locked: OK
[   37.025083] Testing event xfs_ail_flushing: OK
[   37.041064] Testing event xfs_file_read: OK
[   37.061007] Testing event xfs_file_buffered_write: OK
[   37.077489] Testing event xfs_file_direct_write: OK
[   37.101578] Testing event xfs_file_splice_read: OK
[   37.125471] Testing event xfs_file_splice_write: OK
[   37.146509] Testing event xfs_writepage: OK
[   37.169790] Testing event xfs_releasepage: OK
[   37.222821] Testing event xfs_invalidatepage: OK
[   37.246186] Testing event xfs_map_blocks_found: OK
[   37.265444] Testing event xfs_map_blocks_alloc: OK
[   37.290306] Testing event xfs_get_blocks_found: OK
[   37.309438] Testing event xfs_get_blocks_alloc: OK
[   37.351377] Testing event xfs_delalloc_enospc: OK
[   37.369523] Testing event xfs_unwritten_convert: OK
[   37.389133] Testing event xfs_get_blocks_notfound: OK
[   37.408122] Testing event xfs_setfilesize: OK
[   37.425157] Testing event xfs_itruncate_extents_start: OK
[   37.444366] Testing event xfs_itruncate_extents_end: OK
[   37.461375] Testing event xfs_pagecache_inval: OK
[   37.485398] Testing event xfs_bunmap: OK
[   37.501385] Testing event xfs_extent_busy: OK
[   37.518353] Testing event xfs_extent_busy_enomem: OK
[   37.540478] Testing event xfs_extent_busy_force: OK
[   37.560644] Testing event xfs_extent_busy_reuse: OK
[   37.578648] Testing event xfs_extent_busy_clear: OK
[   37.606084] Testing event xfs_extent_busy_trim: OK
[   37.625474] Testing event xfs_trans_commit_lsn: OK
[   37.641474] Testing event xfs_agf: OK
[   37.667826] Testing event xfs_free_extent: OK
[   37.685196] Testing event xfs_alloc_exact_done: OK
[   37.701549] Testing event xfs_alloc_exact_notfound: OK
[   37.717470] Testing event xfs_alloc_exact_error: OK
[   37.737495] Testing event xfs_alloc_near_nominleft: OK
[   37.765526] Testing event xfs_alloc_near_first: OK
[   37.781674] Testing event xfs_alloc_near_greater: OK
[   37.801468] Testing event xfs_alloc_near_lesser: OK
[   37.838244] Testing event xfs_alloc_near_error: OK
[   37.857508] Testing event xfs_alloc_near_noentry: OK
[   37.905522] Testing event xfs_alloc_near_busy: OK
[   37.933499] Testing event xfs_alloc_size_neither: OK
[   37.949381] Testing event xfs_alloc_size_noentry: OK
[   37.965479] Testing event xfs_alloc_size_nominleft: OK
[   37.981443] Testing event xfs_alloc_size_done: OK
[   38.011161] Testing event xfs_alloc_size_error: OK
[   38.030722] Testing event xfs_alloc_size_busy: OK
[   38.049246] Testing event xfs_alloc_small_freelist: OK
[   38.064817] Testing event xfs_alloc_small_notenough: OK
[   38.081167] Testing event xfs_alloc_small_done: OK
[   38.097723] Testing event xfs_alloc_small_error: OK
[   38.139305] Testing event xfs_alloc_vextent_badargs: OK
[   38.161499] Testing event xfs_alloc_vextent_nofix: OK
[   38.177902] Testing event xfs_alloc_vextent_noagbp: OK
[   38.193153] Testing event xfs_alloc_vextent_loopfailed: OK
[   38.209193] Testing event xfs_alloc_vextent_allfailed: OK
[   38.225547] Testing event xfs_dir2_sf_addname: OK
[   38.248761] Testing event xfs_dir2_sf_create: OK
[   38.265192] Testing event xfs_dir2_sf_lookup: OK
[   38.282554] Testing event xfs_dir2_sf_replace: OK
[   38.301277] Testing event xfs_dir2_sf_removename: OK
[   38.318626] Testing event xfs_dir2_sf_toino4: OK
[   38.344212] Testing event xfs_dir2_sf_toino8: OK
[   38.365650] Testing event xfs_dir2_sf_to_block: OK
[   38.389801] Testing event xfs_dir2_block_addname: OK
[   38.409192] Testing event xfs_dir2_block_lookup: OK
[   38.433567] Testing event xfs_dir2_block_replace: OK
[   38.465101] Testing event xfs_dir2_block_removename: OK
[   38.481057] Testing event xfs_dir2_block_to_sf: OK
[   38.497044] Testing event xfs_dir2_block_to_leaf: OK
[   38.513058] Testing event xfs_dir2_leaf_addname: OK
[   38.529095] Testing event xfs_dir2_leaf_lookup: OK
[   38.545247] Testing event xfs_dir2_leaf_replace: OK
[   38.565007] Testing event xfs_dir2_leaf_removename: OK
[   38.583218] Testing event xfs_dir2_leaf_to_block: OK
[   38.601233] Testing event xfs_dir2_leaf_to_node: OK
[   38.619490] Testing event xfs_dir2_node_addname: OK
[   38.638130] Testing event xfs_dir2_node_lookup: OK
[   38.657160] Testing event xfs_dir2_node_replace: OK
[   38.685305] Testing event xfs_dir2_node_removename: OK
[   38.701507] Testing event xfs_dir2_node_to_leaf: OK
[   38.717147] Testing event xfs_attr_sf_add: OK
[   38.733153] Testing event xfs_attr_sf_addname: OK
[   38.753104] Testing event xfs_attr_sf_create: OK
[   38.769013] Testing event xfs_attr_sf_lookup: OK
[   38.785060] Testing event xfs_attr_sf_remove: OK
[   38.801086] Testing event xfs_attr_sf_removename: OK
[   38.817004] Testing event xfs_attr_sf_to_leaf: OK
[   38.833742] Testing event xfs_attr_leaf_add: OK
[   38.848874] Testing event xfs_attr_leaf_add_old: OK
[   38.866026] Testing event xfs_attr_leaf_add_new: OK
[   38.881584] Testing event xfs_attr_leaf_addname: OK
[   38.901335] Testing event xfs_attr_leaf_create: OK
[   38.917064] Testing event xfs_attr_leaf_lookup: OK
[   38.933043] Testing event xfs_attr_leaf_replace: OK
[   38.949368] Testing event xfs_attr_leaf_removename: OK
[   38.965434] Testing event xfs_attr_leaf_split: OK
[   38.981149] Testing event xfs_attr_leaf_split_before: OK
[   39.003015] Testing event xfs_attr_leaf_split_after: OK
[   39.021005] Testing event xfs_attr_leaf_clearflag: OK
[   39.055038] Testing event xfs_attr_leaf_setflag: OK
[   39.073051] Testing event xfs_attr_leaf_flipflags: OK
[   39.089119] Testing event xfs_attr_leaf_to_sf: OK
[   39.107436] Testing event xfs_attr_leaf_to_node: OK
[   39.133173] Testing event xfs_attr_leaf_rebalance: OK
[   39.148873] Testing event xfs_attr_leaf_unbalance: OK
[   39.174087] Testing event xfs_attr_node_addname: OK
[   39.190638] Testing event xfs_attr_node_lookup: OK
[   39.209021] Testing event xfs_attr_node_replace: OK
[   39.249581] Testing event xfs_attr_node_removename: OK
[   39.265188] Testing event xfs_da_split: OK
[   39.291365] Testing event xfs_da_join: OK
[   39.308953] Testing event xfs_da_link_before: OK
[   39.327957] Testing event xfs_da_link_after: OK
[   39.349365] Testing event xfs_da_unlink_back: OK
[   39.365143] Testing event xfs_da_unlink_forward: OK
[   39.387176] Testing event xfs_da_root_split: OK
[   39.405138] Testing event xfs_da_root_join: OK
[   39.424493] Testing event xfs_da_node_add: OK
[   39.442423] Testing event xfs_da_node_create: OK
[   39.465697] Testing event xfs_da_node_split: OK
[   39.483279] Testing event xfs_da_node_remove: OK
[   39.521964] Testing event xfs_da_node_rebalance: OK
[   39.537455] Testing event xfs_da_node_unbalance: OK
[   39.553189] Testing event xfs_da_swap_lastblock: OK
[   39.581243] Testing event xfs_da_grow_inode: OK
[   39.597097] Testing event xfs_da_shrink_inode: OK
[   39.613012] Testing event xfs_dir2_leafn_add: OK
[   39.645670] Testing event xfs_dir2_leafn_remove: OK
[   39.661163] Testing event xfs_dir2_grow_inode: OK
[   39.678760] Testing event xfs_dir2_shrink_inode: OK
[   39.696984] Testing event xfs_dir2_leafn_moveents: OK
[   39.713441] Testing event xfs_swap_extent_before: OK
[   39.730882] Testing event xfs_swap_extent_after: OK
[   39.749332] Testing event xfs_log_recover_item_add: OK
[   39.769232] Testing event xfs_log_recover_item_add_cont: OK
[   39.784986] Testing event xfs_log_recover_item_reorder_head: OK
[   39.801028] Testing event xfs_log_recover_item_reorder_tail: OK
[   39.817046] Testing event xfs_log_recover_item_recover: OK
[   39.853796] Testing event xfs_log_recover_buf_not_cancel: OK
[   39.869198] Testing event xfs_log_recover_buf_cancel: OK
[   39.885167] Testing event xfs_log_recover_buf_cancel_add: OK
[   39.908589] Testing event xfs_log_recover_buf_cancel_ref_inc: OK
[   39.925324] Testing event xfs_log_recover_buf_recover: OK
[   39.946034] Testing event xfs_log_recover_buf_inode_buf: OK
[   39.968360] Testing event xfs_log_recover_buf_reg_buf: OK
[   39.992163] Testing event xfs_log_recover_buf_dquot_buf: OK
[   40.009859] Testing event xfs_log_recover_inode_recover: OK
[   40.029234] Testing event xfs_log_recover_inode_cancel: OK
[   40.063621] Testing event xfs_log_recover_inode_skip: OK
[   40.089205] Testing event xfs_discard_extent: OK
[   40.111252] Testing event xfs_discard_toosmall: OK
[   40.137199] Testing event xfs_discard_exclude: OK
[   40.177367] Testing event xfs_discard_busy: OK
[   40.193256] Testing event jbd2_checkpoint: OK
[   40.213118] Testing event jbd2_start_commit: OK
[   40.229087] Testing event jbd2_commit_locking: OK
[   40.245165] Testing event jbd2_commit_flushing: OK
[   40.263346] Testing event jbd2_commit_logging: OK
[   40.289380] Testing event jbd2_drop_transaction: OK
[   40.309352] Testing event jbd2_end_commit: OK
[   40.325627] Testing event jbd2_submit_inode_data: OK
[   40.341016] Testing event jbd2_run_stats: OK
[   40.357097] Testing event jbd2_checkpoint_stats: OK
[   40.373053] Testing event jbd2_update_log_tail: OK
[   40.389219] Testing event jbd2_write_superblock: OK
[   40.405074] Testing event jbd_checkpoint: OK
[   40.428592] Testing event jbd_start_commit: OK
[   40.445215] Testing event jbd_commit_locking: OK
[   40.470535] Testing event jbd_commit_flushing: OK
[   40.497256] Testing event jbd_commit_logging: OK
[   40.526701] Testing event jbd_drop_transaction: OK
[   40.545147] Testing event jbd_end_commit: OK
[   40.583306] Testing event jbd_do_submit_data: OK
[   40.601165] Testing event jbd_cleanup_journal_tail: OK
[   40.625325] Testing event journal_write_superblock: OK
[   40.648530] Testing event ext4_free_inode: OK
[   40.665670] Testing event ext4_request_inode: OK
[   40.681039] Testing event ext4_allocate_inode: OK
[   40.698866] Testing event ext4_evict_inode: OK
[   40.716967] Testing event ext4_drop_inode: OK
[   40.733550] Testing event ext4_mark_inode_dirty: OK
[   40.755125] Testing event ext4_begin_ordered_truncate: OK
[   40.773150] Testing event ext4_write_begin: OK
[   40.818124] Testing event ext4_da_write_begin: OK
[   40.837043] Testing event ext4_ordered_write_end: OK
[   40.857172] Testing event ext4_writeback_write_end: OK
[   40.878317] Testing event ext4_journalled_write_end: OK
[   40.896886] Testing event ext4_da_write_end: OK
[   40.913467] Testing event ext4_da_writepages: OK
[   40.928953] Testing event ext4_da_write_pages: OK
[   40.945070] Testing event ext4_da_writepages_result: OK
[   40.961492] Testing event ext4_writepage: OK
[   40.977173] Testing event ext4_readpage: OK
[   41.000451] Testing event ext4_releasepage: OK
[   41.017102] Testing event ext4_invalidatepage: OK
[   41.045180] Testing event ext4_discard_blocks: OK
[   41.072203] Testing event ext4_mb_new_inode_pa: OK
[   41.089018] Testing event ext4_mb_new_group_pa: OK
[   41.107854] Testing event ext4_mb_release_inode_pa: OK
[   41.125033] Testing event ext4_mb_release_group_pa: OK
[   41.153015] Testing event ext4_discard_preallocations: OK
[   41.177083] Testing event ext4_mb_discard_preallocations: OK
[   41.193059] Testing event ext4_request_blocks: OK
[   41.209488] Testing event ext4_allocate_blocks: OK
[   41.225102] Testing event ext4_free_blocks: OK
[   41.248160] Testing event ext4_sync_file_enter: OK
[   41.265386] Testing event ext4_sync_file_exit: OK
[   41.281143] Testing event ext4_sync_fs: OK
[   41.305888] Testing event ext4_alloc_da_blocks: OK
[   41.333060] Testing event ext4_mballoc_alloc: OK
[   41.367642] Testing event ext4_mballoc_prealloc: OK
[   41.389340] Testing event ext4_mballoc_discard: OK
[   41.406462] Testing event ext4_mballoc_free: OK
[   41.452422] Testing event ext4_forget: OK
[   41.469210] Testing event ext4_da_update_reserve_space: OK
[   41.489100] Testing event ext4_da_reserve_space: OK
[   41.517313] Testing event ext4_da_release_space: OK
[   41.535467] Testing event ext4_mb_bitmap_load: OK
[   41.553172] Testing event ext4_mb_buddy_bitmap_load: OK
[   41.576376] Testing event ext4_read_block_bitmap_load: OK
[   41.597129] Testing event ext4_load_inode_bitmap: OK
[   41.613094] Testing event ext4_direct_IO_enter: OK
[   41.629135] Testing event ext4_direct_IO_exit: OK
[   41.645158] Testing event ext4_fallocate_enter: OK
[   41.664233] Testing event ext4_fallocate_exit: OK
[   41.684716] Testing event ext4_unlink_enter: OK
[   41.702017] Testing event ext4_unlink_exit: OK
[   41.719238] Testing event ext4_truncate_enter: OK
[   41.737469] Testing event ext4_truncate_exit: OK
[   41.753427] Testing event ext4_ext_convert_to_initialized_enter: OK
[   41.774834] Testing event ext4_ext_convert_to_initialized_fastpath: OK
[   41.793146] Testing event ext4_ext_map_blocks_enter: OK
[   41.810429] Testing event ext4_ind_map_blocks_enter: OK
[   41.842734] Testing event ext4_ext_map_blocks_exit: OK
[   41.865657] Testing event ext4_ind_map_blocks_exit: OK
[   41.882465] Testing event ext4_ext_load_extent: OK
[   41.901030] Testing event ext4_load_inode: OK
[   41.917318] Testing event ext4_journal_start: OK
[   41.933215] Testing event ext4_trim_extent: OK
[   41.953299] Testing event ext4_trim_all_free: OK
[   41.973984] Testing event ext4_ext_handle_uninitialized_extents: OK
[   41.993466] Testing event ext4_get_implied_cluster_alloc_exit: OK
[   42.022292] Testing event ext4_ext_put_in_cache: OK
[   42.041041] Testing event ext4_ext_in_cache: OK
[   42.065056] Testing event ext4_find_delalloc_range: OK
[   42.083282] Testing event ext4_get_reserved_cluster_alloc: OK
[   42.101581] Testing event ext4_ext_show_extent: OK
[   42.117880] Testing event ext4_remove_blocks: OK
[   42.145114] Testing event ext4_ext_rm_leaf: OK
[   42.161129] Testing event ext4_ext_rm_idx: OK
[   42.177062] Testing event ext4_ext_remove_space: OK
[   42.193069] Testing event ext4_ext_remove_space_done: OK
[   42.209080] Testing event ext3_free_inode: OK
[   42.225319] Testing event ext3_request_inode: OK
[   42.241090] Testing event ext3_allocate_inode: OK
[   42.258283] Testing event ext3_evict_inode: OK
[   42.277199] Testing event ext3_drop_inode: OK
[   42.298544] Testing event ext3_mark_inode_dirty: OK
[   42.317191] Testing event ext3_write_begin: OK
[   42.338829] Testing event ext3_ordered_write_end: OK
[   42.357202] Testing event ext3_writeback_write_end: OK
[   42.373579] Testing event ext3_journalled_write_end: OK
[   42.389147] Testing event ext3_ordered_writepage: OK
[   42.410240] Testing event ext3_writeback_writepage: OK
[   42.429395] Testing event ext3_journalled_writepage: OK
[   42.445126] Testing event ext3_readpage: OK
[   42.462061] Testing event ext3_releasepage: OK
[   42.489060] Testing event ext3_invalidatepage: OK
[   42.505088] Testing event ext3_discard_blocks: OK
[   42.521982] Testing event ext3_request_blocks: OK
[   42.537132] Testing event ext3_allocate_blocks: OK
[   42.563468] Testing event ext3_free_blocks: OK
[   42.582549] Testing event ext3_sync_file_enter: OK
[   42.601446] Testing event ext3_sync_file_exit: OK
[   42.617108] Testing event ext3_sync_fs: OK
[   42.641019] Testing event ext3_rsv_window_add: OK
[   42.657190] Testing event ext3_discard_reservation: OK
[   42.678583] Testing event ext3_alloc_new_reservation: OK
[   42.697095] Testing event ext3_reserved: OK
[   42.713076] Testing event ext3_forget: OK
[   42.729453] Testing event ext3_read_block_bitmap: OK
[   42.749442] Testing event ext3_direct_IO_enter: OK
[   42.786154] Testing event ext3_direct_IO_exit: OK
[   42.805100] Testing event ext3_unlink_enter: OK
[   42.825018] Testing event ext3_unlink_exit: OK
[   42.851769] Testing event ext3_truncate_enter: OK
[   42.885456] Testing event ext3_truncate_exit: OK
[   42.902363] Testing event ext3_get_blocks_enter: OK
[   42.921405] Testing event ext3_get_blocks_exit: OK
[   42.941432] Testing event ext3_load_inode: OK
[   42.988960] Testing event writeback_nothread: OK
[   43.008954] Testing event writeback_queue: OK
[   43.033384] Testing event writeback_exec: OK
[   43.057082] Testing event writeback_start: OK
[   43.081334] Testing event writeback_written: OK
[   43.097414] Testing event writeback_wait: OK
[   43.141076] Testing event writeback_pages_written: OK
[   43.165395] Testing event writeback_nowork: OK
[   43.181339] Testing event writeback_wake_background: OK
[   43.197441] Testing event writeback_wake_thread: OK
[   43.221411] Testing event writeback_wake_forker_thread: OK
[   43.245483] Testing event writeback_bdi_register: OK
[   43.265205] Testing event writeback_bdi_unregister: OK
[   43.283616] Testing event writeback_thread_start: OK
[   43.301085] Testing event writeback_thread_stop: OK
[   43.317095] Testing event wbc_writepage: OK
[   43.333051] Testing event writeback_queue_io: OK
[   43.349298] Testing event global_dirty_state: OK
[   43.365427] Testing event bdi_dirty_ratelimit: OK
[   43.398206] Testing event balance_dirty_pages: OK
[   43.417288] Testing event writeback_sb_inodes_requeue: OK
[   43.433373] Testing event writeback_congestion_wait: OK
[   43.478378] Testing event writeback_wait_iff_congested: OK
[   43.513107] Testing event writeback_single_inode: OK
[   43.529437] Testing event mm_compaction_isolate_migratepages: OK
[   43.546777] Testing event mm_compaction_isolate_freepages: OK
[   43.581226] Testing event mm_compaction_migratepages: OK
[   43.602604] Testing event kmalloc: OK
[   43.625335] Testing event kmem_cache_alloc: OK
[   43.641058] Testing event kmalloc_node: OK
[   43.657424] Testing event kmem_cache_alloc_node: OK
[   43.674649] Testing event kfree: OK
[   43.693444] Testing event kmem_cache_free: OK
[   43.713506] Testing event mm_page_free: OK
[   43.737850] Testing event mm_page_free_batched: OK
[   43.757311] Testing event mm_page_alloc: OK
[   43.773080] Testing event mm_page_alloc_zone_locked: OK
[   43.789061] Testing event mm_page_pcpu_drain: OK
[   43.805519] Testing event mm_page_alloc_extfrag: OK
[   43.820970] Testing event mm_vmscan_kswapd_sleep: OK
[   43.837136] Testing event mm_vmscan_kswapd_wake: OK
[   43.868412] Testing event mm_vmscan_wakeup_kswapd: OK
[   43.885309] Testing event mm_vmscan_direct_reclaim_begin: OK
[   43.916877] Testing event mm_vmscan_memcg_reclaim_begin: OK
[   43.933118] Testing event mm_vmscan_memcg_softlimit_reclaim_begin: OK
[   43.949128] Testing event mm_vmscan_direct_reclaim_end: OK
[   43.965454] Testing event mm_vmscan_memcg_reclaim_end: OK
[   43.985111] Testing event mm_vmscan_memcg_softlimit_reclaim_end: OK
[   44.001572] Testing event mm_shrink_slab_start: OK
[   44.029834] Testing event mm_shrink_slab_end: OK
[   44.054061] Testing event mm_vmscan_lru_isolate: OK
[   44.085424] Testing event mm_vmscan_memcg_isolate: OK
[   44.101955] Testing event mm_vmscan_writepage: OK
[   44.121054] Testing event mm_vmscan_lru_shrink_inactive: OK
[   44.137028] Testing event oom_score_adj_update: OK
[   44.153011] Testing event rpm_suspend: OK
[   44.183584] Testing event rpm_resume: OK
[   44.203044] Testing event rpm_idle: OK
[   44.225947] Testing event rpm_return_int: OK
[   44.241072] Testing event cpu_idle: OK
[   44.257067] Testing event cpu_frequency: OK
[   44.280471] Testing event machine_suspend: OK
[   44.298848] Testing event wakeup_source_activate: OK
[   44.317099] Testing event wakeup_source_deactivate: OK
[   44.333065] Testing event power_start: OK
[   44.352722] Testing event power_frequency: OK
[   44.368947] Testing event power_end: OK
[   44.385306] Testing event clock_enable: OK
[   44.421968] Testing event clock_disable: OK
[   44.437014] Testing event clock_set_rate: OK
[   44.460748] Testing event power_domain_target: OK
[   44.492986] Testing event ftrace_test_filter: OK
[   44.508995] Testing event module_load: OK
[   44.525025] Testing event module_free: OK
[   44.540970] Testing event module_get: OK
[   44.557458] Testing event module_put: OK
[   44.573074] Testing event module_request: OK
[   44.597001] Testing event lock_acquire: OK
[   44.613585] Testing event lock_release: OK
[   44.633047] Testing event lock_contended: OK
[   44.649371] Testing event lock_acquired: OK
[   44.665032] Testing event sched_kthread_stop: OK
[   44.680974] Testing event sched_kthread_stop_ret: OK
[   44.697456] Testing event sched_wakeup: OK
[   44.713597] Testing event sched_wakeup_new: OK
[   44.737121] Testing event sched_switch: OK
[   44.756147] Testing event sched_migrate_task: OK
[   44.781104] Testing event sched_process_free: OK
[   44.799036] Testing event sched_process_exit: OK
[   44.817155] Testing event sched_wait_task: OK
[   44.833141] Testing event sched_process_wait: OK
[   44.849106] Testing event sched_process_fork: OK
[   44.865071] Testing event sched_process_exec: OK
[   44.884276] Testing event sched_stat_wait: OK
[   44.901385] Testing event sched_stat_sleep: OK
[   44.925628] Testing event sched_stat_iowait: OK
[   44.965588] Testing event sched_stat_blocked: OK
[   44.981048] Testing event sched_stat_runtime: OK
[   44.997053] Testing event sched_pi_setprio: OK
[   45.020228] Testing event rcu_utilization: OK
[   45.038791] Testing event rcu_grace_period: OK
[   45.060986] Testing event rcu_grace_period_init: OK
[   45.083397] Testing event rcu_preempt_task: OK
[   45.101049] Testing event rcu_unlock_preempted_task: OK
[   45.117020] Testing event rcu_quiescent_state_report: OK
[   45.136129] Testing event rcu_fqs: OK
[   45.153028] Testing event rcu_dyntick: OK
[   45.175094] Testing event rcu_prep_idle: OK
[   45.193954] Testing event rcu_callback: OK
[   45.209346] Testing event rcu_kfree_callback: OK
[   45.237653] Testing event rcu_batch_start: OK
[   45.265046] Testing event rcu_invoke_callback: OK
[   45.282843] Testing event rcu_invoke_kfree_callback: OK
[   45.302975] Testing event rcu_batch_end: OK
[   45.322961] Testing event rcu_torture_read: OK
[   45.341323] Testing event rcu_barrier: OK
[   45.357356] Testing event workqueue_queue_work: OK
[   45.373165] Testing event workqueue_activate_work: OK
[   45.395346] Testing event workqueue_execute_start: OK
[   45.413045] Testing event workqueue_execute_end: OK
[   45.429166] Testing event signal_generate: OK
[   45.453453] Testing event signal_deliver: OK
[   45.469004] Testing event timer_init: OK
[   45.485117] Testing event timer_start: OK
[   45.501077] Testing event timer_expire_entry: OK
[   45.517192] Testing event timer_expire_exit: OK
[   45.533067] Testing event timer_cancel: OK
[   45.549165] Testing event hrtimer_init: OK
[   45.565071] Testing event hrtimer_start: OK
[   45.581168] Testing event hrtimer_expire_entry: OK
[   45.597080] Testing event hrtimer_expire_exit: OK
[   45.613135] Testing event hrtimer_cancel: OK
[   45.637066] Testing event itimer_state: OK
[   45.653371] Testing event itimer_expire: OK
[   45.669009] Testing event irq_handler_entry: OK
[   45.685004] Testing event irq_handler_exit: OK
[   45.705026] Testing event softirq_entry: OK
[   45.721055] Testing event softirq_exit: OK
[   45.737779] Testing event softirq_raise: OK
[   45.757087] Testing event console: OK
[   45.772967] Testing event task_newtask: OK
[   45.795371] Testing event task_rename: OK
[   45.813351] Testing event mce_record: OK
[   45.833020] Testing event sys_enter: OK
[   45.849075] Testing event sys_exit: OK
[   45.865110] Testing event emulate_vsyscall: OK
[   45.911655] Testing event xen_mc_batch: OK
[   45.932987] Testing event xen_mc_issue: OK
[   45.949035] Testing event xen_mc_entry: OK
[   45.970831] Testing event xen_mc_entry_alloc: OK
[   45.989089] Testing event xen_mc_callback: OK
[   46.012316] Testing event xen_mc_flush_reason: OK
[   46.028969] Testing event xen_mc_flush: OK
[   46.045075] Testing event xen_mc_extend_args: OK
[   46.068201] Testing event xen_mmu_set_pte: OK
[   46.084994] Testing event xen_mmu_set_pte_atomic: OK
[   46.101070] Testing event xen_mmu_set_domain_pte: OK
[   46.118871] Testing event xen_mmu_set_pte_at: OK
[   46.137060] Testing event xen_mmu_pte_clear: OK
[   46.153068] Testing event xen_mmu_set_pmd: OK
[   46.185946] Testing event xen_mmu_pmd_clear: OK
[   46.205055] Testing event xen_mmu_set_pud: OK
[   46.221035] Testing event xen_mmu_set_pgd: OK
[   46.259818] Testing event xen_mmu_pud_clear: OK
[   46.289430] Testing event xen_mmu_pgd_clear: OK
[   46.321237] Testing event xen_mmu_ptep_modify_prot_start: OK
[   46.359906] Testing event xen_mmu_ptep_modify_prot_commit: OK
[   46.377068] Testing event xen_mmu_alloc_ptpage: OK
[   46.399699] Testing event xen_mmu_release_ptpage: OK
[   46.421118] Testing event xen_mmu_pgd_pin: OK
[   46.442378] Testing event xen_mmu_pgd_unpin: OK
[   46.469024] Testing event xen_mmu_flush_tlb: OK
[   46.490409] Testing event xen_mmu_flush_tlb_single: OK
[   46.509059] Testing event xen_mmu_flush_tlb_others: OK
[   46.528995] Testing event xen_mmu_write_cr3: OK
[   46.557828] Testing event xen_cpu_write_ldt_entry: OK
[   46.577128] Testing event xen_cpu_write_idt_entry: OK
[   46.593087] Testing event xen_cpu_load_idt: OK
[   46.615239] Testing event xen_cpu_write_gdt_entry: OK
[   46.637048] Testing event xen_cpu_set_ldt: OK
[   46.660312] Testing event kvm_mmu_pagetable_walk: OK
[   46.678462] Testing event kvm_mmu_paging_element: OK
[   46.697070] Testing event kvm_mmu_set_accessed_bit: OK
[   46.720340] Testing event kvm_mmu_set_dirty_bit: OK
[   46.737143] Testing event kvm_mmu_walker_error: OK
[   46.753064] Testing event kvm_mmu_get_page: OK
[   46.769108] Testing event kvm_mmu_sync_page: OK
[   46.786002] Testing event kvm_mmu_unsync_page: OK
[   46.829514] Testing event kvm_mmu_prepare_zap_page: OK
[   46.850603] Testing event kvm_mmu_delay_free_pages: OK
[   46.870064] Testing event mark_mmio_spte: OK
[   46.889006] Testing event handle_mmio_page_fault: OK
[   46.913395] Testing event fast_page_fault: OK
[   46.929034] Testing event kvm_entry: OK
[   46.944956] Testing event kvm_hypercall: OK
[   46.986245] Testing event kvm_hv_hypercall: OK
[   47.022019] Testing event kvm_pio: OK
[   47.049224] Testing event kvm_cpuid: OK
[   47.065154] Testing event kvm_apic: OK
[   47.085102] Testing event kvm_exit: OK
[   47.105364] Testing event kvm_inj_virq: OK
[   47.121188] Testing event kvm_inj_exception: OK
[   47.146418] Testing event kvm_page_fault: OK
[   47.165630] Testing event kvm_msr: OK
[   47.180980] Testing event kvm_cr: OK
[   47.202158] Testing event kvm_pic_set_irq: OK
[   47.217121] Testing event kvm_apic_ipi: OK
[   47.233620] Testing event kvm_apic_accept_irq: OK
[   47.249144] Testing event kvm_eoi: OK
[   47.278307] Testing event kvm_pv_eoi: OK
[   47.297082] Testing event kvm_nested_vmrun: OK
[   47.313055] Testing event kvm_nested_intercepts: OK
[   47.334984] Testing event kvm_nested_vmexit: OK
[   47.357356] Testing event kvm_nested_vmexit_inject: OK
[   47.372977] Testing event kvm_nested_intr_vmexit: OK
[   47.395129] Testing event kvm_invlpga: OK
[   47.413062] Testing event kvm_skinit: OK
[   47.433330] Testing event kvm_emulate_insn: OK
[   47.449781] Testing event vcpu_match_mmio: OK
[   47.465088] Testing event kvm_userspace_exit: OK
[   47.481862] Testing event kvm_set_irq: OK
[   47.502050] Testing event kvm_ioapic_set_irq: OK
[   47.517042] Testing event kvm_msi_set_irq: OK
[   47.533512] Testing event kvm_ack_irq: OK
[   47.567007] Testing event kvm_mmio: OK
[   47.594479] Testing event kvm_fpu: OK
[   47.613337] Testing event kvm_age_page: OK
[   47.633348] Testing event kvm_try_async_get_page: OK
[   47.650541] Testing event kvm_async_pf_doublefault: OK
[   47.670245] Testing event kvm_async_pf_not_present: OK
[   47.689221] Testing event kvm_async_pf_ready: OK
[   47.705647] Testing event kvm_async_pf_completed: OK
[   47.721147] Running tests on trace event systems:
[   47.722396] Testing event system 9p: OK
[   47.751445] Testing event system mac80211: OK
[   47.796759] Testing event system sunrpc: OK
[   47.826204] Testing event system skb: OK
[   47.861190] Testing event system net: OK
[   47.883432] Testing event system napi: OK
[   47.910415] Testing event system sock: OK
[   47.937273] Testing event system udp: OK
[   47.953274] Testing event system hda: OK
[   48.004878] Testing event system ras: OK
[   48.021194] Testing event system scsi: OK
[   48.044816] Testing event system regmap: OK
[   48.070151] Testing event system i915: OK
[   48.110478] Testing event system radeon: OK
[   48.134858] Testing event system drm: OK
[   48.162352] Testing event system random: OK
[   48.182433] Testing event system regulator: OK
[   48.201749] Testing event system gpio: OK
[   48.217365] Testing event system block: OK
[   48.238736] Testing event system gfs2: OK
[   48.258467] Testing event system btrfs: OK
[   48.280405] Testing event system ocfs2: OK
[   48.502505] Testing event system xfs: OK
[   48.664488] Testing event system jbd2: OK
[   48.683831] Testing event system jbd: OK
[   48.703855] Testing event system ext4: OK
[   48.747290] Testing event system ext3: OK
[   48.777355] Testing event system writeback: OK
[   48.799708] Testing event system compaction: OK
[   48.825460] Testing event system kmem: OK
[   48.846694] Testing event system vmscan: OK
[   48.866911] Testing event system oom: OK
[   48.916908] Testing event system rpm: OK
[   48.942708] Testing event system power: OK
[   48.970465] Testing event system test: OK
[   49.008666] Testing event system module: OK
[   49.030228] Testing event system lock: OK
[   49.051953] Testing event system sched: OK
[   49.087318] Testing event system rcu: OK
[   49.110896] Testing event system workqueue: OK
[   49.142524] Testing event system signal: OK
[   49.161647] Testing event system timer: OK
[   49.186403] Testing event system irq: OK
[   49.205654] Testing event system printk: OK
[   49.221616] Testing event system task: OK
[   49.238172] Testing event system mce: OK
[   49.253705] Testing event system raw_syscalls: OK
[   49.282426] Testing event system vsyscall: OK
[   49.305289] Testing event system syscalls: OK
[   49.326751] Testing event system xen: OK
[   49.372523] Testing event system kvmmmu: OK
[   49.391019] Testing event system kvm: OK
[   49.418759] Running tests on all trace events:
[   49.419950] Testing all events: OK
[   50.482582] Running tests again, along with the function tracer
[   50.484960] Running tests on trace events:
[   50.486395] Testing event 9p_client_req: OK
[   50.550409] Testing event 9p_client_res: OK
[   50.593066] Testing event 9p_protocol_dump: OK
[   50.616534] Testing event drv_return_void: OK
[   50.639057] Testing event drv_return_int: OK
[   50.671480] Testing event drv_return_bool: OK
[   50.710742] Testing event drv_return_u64: OK
[   50.730402] Testing event drv_start: OK
[   50.750503] Testing event drv_get_et_strings: OK
[   50.770260] Testing event drv_get_et_sset_count: OK
[   50.790289] Testing event drv_get_et_stats: OK
[   50.811033] Testing event drv_suspend: OK
[   50.834173] Testing event drv_resume: OK
[   50.857414] Testing event drv_set_wakeup: OK
[   50.894865] Testing event drv_stop: OK
[   50.926747] Testing event drv_add_interface: OK
[   50.941822] Testing event drv_change_interface: OK
[   50.957077] Testing event drv_remove_interface: OK
[   50.978342] Testing event drv_config: OK
[   50.998460] Testing event drv_bss_info_changed: OK
[   51.019096] Testing event drv_prepare_multicast: OK
[   51.042394] Testing event drv_configure_filter: OK
[   51.062420] Testing event drv_set_tim: OK
[   51.092126] Testing event drv_set_key: OK
[   51.115688] Testing event drv_update_tkip_key: OK
[   51.135051] Testing event drv_hw_scan: OK
[   51.161182] Testing event drv_cancel_hw_scan: OK
[   51.189210] Testing event drv_sched_scan_start: OK
[   51.210668] Testing event drv_sched_scan_stop: OK
[   51.230299] Testing event drv_sw_scan_start: OK
[   51.251171] Testing event drv_sw_scan_complete: OK
[   51.270258] Testing event drv_get_stats: OK
[   51.293865] Testing event drv_get_tkip_seq: OK
[   51.314418] Testing event drv_set_frag_threshold: OK
[   51.334868] Testing event drv_set_rts_threshold: OK
[   51.354491] Testing event drv_set_coverage_class: OK
[   51.374417] Testing event drv_sta_notify: OK
[   51.396215] Testing event drv_sta_state: OK
[   51.418118] Testing event drv_sta_rc_update: OK
[   51.446405] Testing event drv_sta_add: OK
[   51.466474] Testing event drv_sta_remove: OK
[   51.486857] Testing event drv_conf_tx: OK
[   51.511136] Testing event drv_get_tsf: OK
[   51.540863] Testing event drv_set_tsf: OK
[   51.562084] Testing event drv_reset_tsf: OK
[   51.582500] Testing event drv_tx_last_beacon: OK
[   51.603070] Testing event drv_ampdu_action: OK
[   51.623575] Testing event drv_get_survey: OK
[   51.655750] Testing event drv_flush: OK
[   51.674435] Testing event drv_channel_switch: OK
[   51.697192] Testing event drv_set_antenna: OK
[   51.718261] Testing event drv_get_antenna: OK
[   51.738465] Testing event drv_remain_on_channel: OK
[   51.758866] Testing event drv_cancel_remain_on_channel: OK
[   51.780735] Testing event drv_offchannel_tx: OK
[   51.802815] Testing event drv_set_ringparam: OK
[   51.821707] Testing event drv_get_ringparam: OK
[   51.845468] Testing event drv_tx_frames_pending: OK
[   51.874791] Testing event drv_offchannel_tx_cancel_wait: OK
[   51.923353] Testing event drv_set_bitrate_mask: OK
[   51.946283] Testing event drv_set_rekey_data: OK
[   51.972873] Testing event drv_rssi_callback: OK
[   51.991088] Testing event drv_release_buffered_frames: OK
[   52.010870] Testing event drv_allow_buffered_frames: OK
[   52.030557] Testing event drv_get_rssi: OK
[   52.050537] Testing event drv_mgd_prepare_tx: OK
[   52.080763] Testing event api_start_tx_ba_session: OK
[   52.102162] Testing event api_start_tx_ba_cb: OK
[   52.122231] Testing event api_stop_tx_ba_session: OK
[   52.146272] Testing event api_stop_tx_ba_cb: OK
[   52.167072] Testing event api_restart_hw: OK
[   52.187396] Testing event api_beacon_loss: OK
[   52.211085] Testing event api_connection_loss: OK
[   52.241049] Testing event api_cqm_rssi_notify: OK
[   52.264993] Testing event api_scan_completed: OK
[   52.287188] Testing event api_sched_scan_results: OK
[   52.309457] Testing event api_sched_scan_stopped: OK
[   52.331042] Testing event api_sta_block_awake: OK
[   52.350415] Testing event api_chswitch_done: OK
[   52.370258] Testing event api_ready_on_channel: OK
[   52.390198] Testing event api_remain_on_channel_expired: OK
[   52.412733] Testing event api_gtk_rekey_notify: OK
[   52.433747] Testing event api_enable_rssi_reports: OK
[   52.454159] Testing event api_eosp: OK
[   52.474154] Testing event wake_queue: OK
[   52.494067] Testing event stop_queue: OK
[   52.518053] Testing event rpc_call_status: OK
[   52.540548] Testing event rpc_bind_status: OK
[   52.563108] Testing event rpc_connect_status: OK
[   52.591124] Testing event rpc_task_begin: OK
[   52.623027] Testing event rpc_task_run_action: OK
[   52.651006] Testing event rpc_task_complete: OK
[   52.670786] Testing event rpc_task_sleep: OK
[   52.690164] Testing event rpc_task_wakeup: OK
[   52.729510] Testing event kfree_skb: OK
[   52.752184] Testing event consume_skb: OK
[   52.782285] Testing event skb_copy_datagram_iovec: OK
[   52.803035] Testing event net_dev_xmit: OK
[   52.827120] Testing event net_dev_queue: OK
[   52.846463] Testing event netif_receive_skb: OK
[   52.874869] Testing event netif_rx: OK
[   52.894387] Testing event napi_poll: OK
[   52.914887] Testing event sock_rcvqueue_full: OK
[   52.940762] Testing event sock_exceed_buf_limit: OK
[   52.962780] Testing event udp_fail_queue_rcv_skb: OK
[   52.986531] Testing event hda_send_cmd: OK
[   53.007535] Testing event hda_get_response: OK
[   53.027302] Testing event hda_bus_reset: OK
[   53.049146] Testing event hda_power_down: OK
[   53.070948] Testing event hda_power_up: OK
[   53.090384] Testing event hda_unsol_event: OK
[   53.110340] Testing event mc_event: OK
[   53.129312] Testing event scsi_dispatch_cmd_start: OK
[   53.145566] Testing event scsi_dispatch_cmd_error: OK
[   53.165763] Testing event scsi_dispatch_cmd_done: OK
[   53.181680] Testing event scsi_dispatch_cmd_timeout: OK
[   53.197905] Testing event scsi_eh_wakeup: OK
[   53.218193] Testing event regmap_reg_write: OK
[   53.238435] Testing event regmap_reg_read: OK
[   53.259059] Testing event regmap_reg_read_cache: OK
[   53.282222] Testing event regmap_hw_read_start: OK
[   53.306796] Testing event regmap_hw_read_done: OK
[   53.330436] Testing event regmap_hw_write_start: OK
[   53.352449] Testing event regmap_hw_write_done: OK
[   53.371160] Testing event regcache_sync: OK
[   53.401248] Testing event regmap_cache_only: OK
[   53.422402] Testing event regmap_cache_bypass: OK
[   53.442592] Testing event i915_gem_object_create: OK
[   53.462855] Testing event i915_gem_object_bind: OK
[   53.483074] Testing event i915_gem_object_unbind: OK
[   53.505774] Testing event i915_gem_object_change_domain: OK
[   53.526340] Testing event i915_gem_object_pwrite: OK
[   53.549013] Testing event i915_gem_object_pread: OK
[   53.567132] Testing event i915_gem_object_fault: OK
[   53.590215] Testing event i915_gem_object_clflush: OK
[   53.610291] Testing event i915_gem_object_destroy: OK
[   53.629617] Testing event i915_gem_evict: OK
[   53.651042] Testing event i915_gem_evict_everything: OK
[   53.678315] Testing event i915_gem_ring_dispatch: OK
[   53.710278] Testing event i915_gem_ring_flush: OK
[   53.734090] Testing event i915_gem_request_add: OK
[   53.754263] Testing event i915_gem_request_complete: OK
[   53.774800] Testing event i915_gem_request_retire: OK
[   53.793863] Testing event i915_gem_request_wait_begin: OK
[   53.814322] Testing event i915_gem_request_wait_end: OK
[   53.838085] Testing event i915_ring_wait_begin: OK
[   53.860373] Testing event i915_ring_wait_end: OK
[   53.878186] Testing event i915_flip_request: OK
[   53.899259] Testing event i915_flip_complete: OK
[   53.919057] Testing event i915_reg_rw: OK
[   53.938362] Testing event radeon_bo_create: OK
[   53.966667] Testing event radeon_fence_emit: OK
[   53.998401] Testing event radeon_fence_retire: OK
[   54.018432] Testing event radeon_fence_wait_begin: OK
[   54.037889] Testing event radeon_fence_wait_end: OK
[   54.059700] Testing event drm_vblank_event: OK
[   54.078412] Testing event drm_vblank_event_queued: OK
[   54.099051] Testing event drm_vblank_event_delivered: OK
[   54.119614] Testing event mix_pool_bytes: OK
[   54.138584] Testing event mix_pool_bytes_nolock: OK
[   54.160717] Testing event credit_entropy_bits: OK
[   54.182801] Testing event get_random_bytes: OK
[   54.202432] Testing event extract_entropy: OK
[   54.226447] Testing event extract_entropy_user: OK
[   54.247140] Testing event regulator_enable: OK
[   54.266405] Testing event regulator_enable_delay: OK
[   54.286817] Testing event regulator_enable_complete: OK
[   54.310468] Testing event regulator_disable: OK
[   54.331207] Testing event regulator_disable_complete: OK
[   54.358279] Testing event regulator_set_voltage: OK
[   54.381164] Testing event regulator_set_voltage_complete: OK
[   54.406628] Testing event gpio_direction: OK
[   54.430210] Testing event gpio_value: OK
[   54.464878] Testing event block_rq_abort: OK
[   54.498077] Testing event block_rq_requeue: OK
[   54.522701] Testing event block_rq_complete: OK
[   54.545944] Testing event block_rq_insert: OK
[   54.574908] Testing event block_rq_issue: OK
[   54.615310] Testing event block_bio_bounce: OK
[   54.642865] Testing event block_bio_complete: OK
[   54.670674] Testing event block_bio_backmerge: OK
[   54.694641] Testing event block_bio_frontmerge: OK
[   54.717982] Testing event block_bio_queue: OK
[   54.742251] Testing event block_getrq: OK
[   54.766548] Testing event block_sleeprq: OK
[   54.794423] Testing event block_plug: OK
[   54.821171] Testing event block_unplug: OK
[   54.854279] Testing event block_split: OK
[   54.876662] Testing event block_bio_remap: OK
[   54.896240] Testing event block_rq_remap: OK
[   54.916422] Testing event gfs2_glock_state_change: OK
[   54.938331] Testing event gfs2_glock_put: OK
[   54.958993] Testing event gfs2_demote_rq: OK
[   54.979759] Testing event gfs2_promote: OK
[   55.003056] Testing event gfs2_glock_queue: OK
[   55.024267] Testing event gfs2_glock_lock_time: OK
[   55.047146] Testing event gfs2_pin: OK
[   55.067575] Testing event gfs2_log_flush: OK
[   55.087808] Testing event gfs2_log_blocks: OK
[   55.112118] Testing event gfs2_ail_flush: OK
[   55.142488] Testing event gfs2_bmap: OK
[   55.166457] Testing event gfs2_block_alloc: OK
[   55.193743] Testing event gfs2_rs: OK
[   55.218500] Testing event btrfs_transaction_commit: OK
[   55.263249] Testing event btrfs_inode_new: OK
[   55.288182] Testing event btrfs_inode_request: OK
[   55.311277] Testing event btrfs_inode_evict: OK
[   55.334429] Testing event btrfs_get_extent: OK
[   55.357446] Testing event btrfs_ordered_extent_add: OK
[   55.378515] Testing event btrfs_ordered_extent_remove: OK
[   55.398702] Testing event btrfs_ordered_extent_start: OK
[   55.426428] Testing event btrfs_ordered_extent_put: OK
[   55.462418] Testing event __extent_writepage: OK
[   55.482601] Testing event btrfs_writepage_end_io_hook: OK
[   55.506569] Testing event btrfs_sync_file: OK
[   55.527124] Testing event btrfs_sync_fs: OK
[   55.559598] Testing event btrfs_delayed_tree_ref: OK
[   55.595083] Testing event btrfs_delayed_data_ref: OK
[   55.624162] Testing event btrfs_delayed_ref_head: OK
[   55.646439] Testing event btrfs_chunk_alloc: OK
[   55.674447] Testing event btrfs_chunk_free: OK
[   55.694276] Testing event btrfs_cow_block: OK
[   55.717231] Testing event btrfs_space_reservation: OK
[   55.738273] Testing event btrfs_reserved_extent_alloc: OK
[   55.758441] Testing event btrfs_reserved_extent_free: OK
[   55.787017] Testing event find_free_extent: OK
[   55.811114] Testing event btrfs_reserve_extent: OK
[   55.832421] Testing event btrfs_reserve_extent_cluster: OK
[   55.858029] Testing event btrfs_find_cluster: OK
[   55.890338] Testing event btrfs_failed_cluster_setup: OK
[   55.914415] Testing event btrfs_setup_cluster: OK
[   55.943670] Testing event alloc_extent_state: OK
[   55.969533] Testing event free_extent_state: OK
[   55.994581] Testing event ocfs2_adjust_rightmost_branch: OK
[   56.017204] Testing event ocfs2_rotate_tree_right: OK
[   56.050150] Testing event ocfs2_append_rec_to_path: OK
[   56.070675] Testing event ocfs2_insert_extent_start: OK
[   56.100011] Testing event ocfs2_add_clusters_in_btree: OK
[   56.122781] Testing event ocfs2_num_free_extents: OK
[   56.150749] Testing event ocfs2_complete_edge_insert: OK
[   56.171109] Testing event ocfs2_grow_tree: OK
[   56.194944] Testing event ocfs2_rotate_subtree: OK
[   56.220170] Testing event ocfs2_insert_extent: OK
[   56.251116] Testing event ocfs2_split_extent: OK
[   56.286426] Testing event ocfs2_remove_extent: OK
[   56.315746] Testing event ocfs2_commit_truncate: OK
[   56.369597] Testing event ocfs2_validate_extent_block: OK
[   56.414250] Testing event ocfs2_rotate_leaf: OK
[   56.438026] Testing event ocfs2_add_clusters_in_btree_ret: OK
[   56.459222] Testing event ocfs2_mark_extent_written: OK
[   56.482414] Testing event ocfs2_truncate_log_append: OK
[   56.505741] Testing event ocfs2_replay_truncate_records: OK
[   56.538256] Testing event ocfs2_flush_truncate_log: OK
[   56.558970] Testing event ocfs2_begin_truncate_log_recovery: OK
[   56.582404] Testing event ocfs2_truncate_log_recovery_num: OK
[   56.606452] Testing event ocfs2_complete_truncate_log_recovery: OK
[   56.626677] Testing event ocfs2_free_cached_blocks: OK
[   56.646343] Testing event ocfs2_cache_cluster_dealloc: OK
[   56.666175] Testing event ocfs2_run_deallocs: OK
[   56.686725] Testing event ocfs2_cache_block_dealloc: OK
[   56.706364] Testing event ocfs2_trim_extent: OK
[   56.754503] Testing event ocfs2_trim_group: OK
[   56.778370] Testing event ocfs2_trim_fs: OK
[   56.803659] Testing event ocfs2_la_set_sizes: OK
[   56.830546] Testing event ocfs2_alloc_should_use_local: OK
[   56.850544] Testing event ocfs2_load_local_alloc: OK
[   56.883332] Testing event ocfs2_begin_local_alloc_recovery: OK
[   56.914277] Testing event ocfs2_reserve_local_alloc_bits: OK
[   56.935032] Testing event ocfs2_local_alloc_count_bits: OK
[   56.984531] Testing event ocfs2_local_alloc_find_clear_bits_search_bitmap: OK
[   57.013367] Testing event ocfs2_local_alloc_find_clear_bits: OK
[   57.034184] Testing event ocfs2_sync_local_to_main: OK
[   57.056398] Testing event ocfs2_sync_local_to_main_free: OK
[   57.078818] Testing event ocfs2_local_alloc_new_window: OK
[   57.098438] Testing event ocfs2_local_alloc_new_window_result: OK
[   57.119072] Testing event ocfs2_update_last_group_and_inode: OK
[   57.155768] Testing event ocfs2_group_extend: OK
[   57.189160] Testing event ocfs2_group_add: OK
[   57.221444] Testing event ocfs2_validate_group_descriptor: OK
[   57.247815] Testing event ocfs2_block_group_alloc_contig: OK
[   57.298636] Testing event ocfs2_block_group_alloc_discontig: OK
[   57.322594] Testing event ocfs2_block_group_alloc: OK
[   57.350438] Testing event ocfs2_reserve_suballoc_bits_nospc: OK
[   57.382394] Testing event ocfs2_reserve_suballoc_bits_no_new_group: OK
[   57.410478] Testing event ocfs2_reserve_new_inode_new_group: OK
[   57.430700] Testing event ocfs2_block_group_set_bits: OK
[   57.454453] Testing event ocfs2_relink_block_group: OK
[   57.494468] Testing event ocfs2_cluster_group_search_wrong_max_bits: OK
[   57.521906] Testing event ocfs2_cluster_group_search_max_block: OK
[   57.546415] Testing event ocfs2_block_group_search_max_block: OK
[   57.567391] Testing event ocfs2_search_chain_begin: OK
[   57.587172] Testing event ocfs2_search_chain_succ: OK
[   57.606234] Testing event ocfs2_search_chain_end: OK
[   57.626292] Testing event ocfs2_claim_suballoc_bits: OK
[   57.650233] Testing event ocfs2_claim_new_inode_at_loc: OK
[   57.670867] Testing event ocfs2_block_group_clear_bits: OK
[   57.698369] Testing event ocfs2_free_suballoc_bits: OK
[   57.718603] Testing event ocfs2_free_clusters: OK
[   57.739244] Testing event ocfs2_get_suballoc_slot_bit: OK
[   57.762293] Testing event ocfs2_test_suballoc_bit: OK
[   57.784673] Testing event ocfs2_test_inode_bit: OK
[   57.837448] Testing event ocfs2_validate_refcount_block: OK
[   57.877342] Testing event ocfs2_purge_refcount_trees: OK
[   57.899214] Testing event ocfs2_create_refcount_tree: OK
[   57.921131] Testing event ocfs2_create_refcount_tree_blkno: OK
[   57.942970] Testing event ocfs2_change_refcount_rec: OK
[   57.962498] Testing event ocfs2_expand_inline_ref_root: OK
[   57.985868] Testing event ocfs2_divide_leaf_refcount_block: OK
[   58.006359] Testing event ocfs2_new_leaf_refcount_block: OK
[   58.026502] Testing event ocfs2_insert_refcount_rec: OK
[   58.051204] Testing event ocfs2_split_refcount_rec: OK
[   58.079990] Testing event ocfs2_split_refcount_rec_insert: OK
[   58.114839] Testing event ocfs2_increase_refcount_begin: OK
[   58.134667] Testing event ocfs2_increase_refcount_change: OK
[   58.163791] Testing event ocfs2_increase_refcount_insert: OK
[   58.186799] Testing event ocfs2_increase_refcount_split: OK
[   58.224661] Testing event ocfs2_remove_refcount_extent: OK
[   58.246668] Testing event ocfs2_restore_refcount_block: OK
[   58.267529] Testing event ocfs2_decrease_refcount_rec: OK
[   58.327654] Testing event ocfs2_decrease_refcount: OK
[   58.362431] Testing event ocfs2_mark_extent_refcounted: OK
[   58.389857] Testing event ocfs2_calc_refcount_meta_credits: OK
[   58.418254] Testing event ocfs2_calc_refcount_meta_credits_iterate: OK
[   58.443406] Testing event ocfs2_add_refcount_flag: OK
[   58.470679] Testing event ocfs2_prepare_refcount_change_for_del: OK
[   58.490565] Testing event ocfs2_lock_refcount_allocators: OK
[   58.518443] Testing event ocfs2_duplicate_clusters_by_page: OK
[   58.543688] Testing event ocfs2_duplicate_clusters_by_jbd: OK
[   58.562381] Testing event ocfs2_clear_ext_refcount: OK
[   58.583231] Testing event ocfs2_replace_clusters: OK
[   58.611006] Testing event ocfs2_make_clusters_writable: OK
[   58.646486] Testing event ocfs2_refcount_cow_hunk: OK
[   58.666980] Testing event ocfs2_symlink_get_block: OK
[   58.686269] Testing event ocfs2_get_block: OK
[   58.707039] Testing event ocfs2_get_block_end: OK
[   58.747954] Testing event ocfs2_readpage: OK
[   58.775471] Testing event ocfs2_writepage: OK
[   58.798224] Testing event ocfs2_bmap: OK
[   58.832883] Testing event ocfs2_try_to_write_inline_data: OK
[   58.859074] Testing event ocfs2_write_begin_nolock: OK
[   58.878384] Testing event ocfs2_write_end_inline: OK
[   58.899082] Testing event ocfs2_fault: OK
[   58.953903] Testing event ocfs2_file_open: OK
[   58.988675] Testing event ocfs2_file_release: OK
[   59.017451] Testing event ocfs2_sync_file: OK
[   59.058947] Testing event ocfs2_file_aio_write: OK
[   59.078402] Testing event ocfs2_file_splice_write: OK
[   59.103118] Testing event ocfs2_file_splice_read: OK
[   59.138337] Testing event ocfs2_file_aio_read: OK
[   59.158339] Testing event ocfs2_truncate_file: OK
[   59.179398] Testing event ocfs2_truncate_file_error: OK
[   59.203909] Testing event ocfs2_extend_allocation: OK
[   59.242316] Testing event ocfs2_extend_allocation_end: OK
[   59.276210] Testing event ocfs2_write_zero_page: OK
[   59.339640] Testing event ocfs2_zero_extend_range: OK
[   59.366469] Testing event ocfs2_zero_extend: OK
[   59.387246] Testing event ocfs2_setattr: OK
[   59.415154] Testing event ocfs2_write_remove_suid: OK
[   59.437074] Testing event ocfs2_zero_partial_clusters: OK
[   59.459147] Testing event ocfs2_zero_partial_clusters_range1: OK
[   59.495177] Testing event ocfs2_zero_partial_clusters_range2: OK
[   59.515123] Testing event ocfs2_remove_inode_range: OK
[   59.571176] Testing event ocfs2_prepare_inode_for_write: OK
[   59.603009] Testing event generic_file_aio_read_ret: OK
[   59.631981] Testing event ocfs2_iget_begin: OK
[   59.659040] Testing event ocfs2_iget5_locked: OK
[   59.706338] Testing event ocfs2_iget_end: OK
[   59.730544] Testing event ocfs2_find_actor: OK
[   59.759317] Testing event ocfs2_populate_inode: OK
[   59.777878] Testing event ocfs2_read_locked_inode: OK
[   59.798296] Testing event ocfs2_check_orphan_recovery_state: OK
[   59.826196] Testing event ocfs2_validate_inode_block: OK
[   59.847964] Testing event ocfs2_inode_is_valid_to_delete: OK
[   59.878996] Testing event ocfs2_query_inode_wipe_begin: OK
[   59.899562] Testing event ocfs2_query_inode_wipe_succ: OK
[   59.923899] Testing event ocfs2_query_inode_wipe_end: OK
[   59.963103] Testing event ocfs2_cleanup_delete_inode: OK
[   59.995169] Testing event ocfs2_delete_inode: OK
[   60.020302] Testing event ocfs2_clear_inode: OK
[   60.042846] Testing event ocfs2_drop_inode: OK
[   60.067160] Testing event ocfs2_inode_revalidate: OK
[   60.123160] Testing event ocfs2_mark_inode_dirty: OK
[   60.144764] Testing event ocfs2_read_virt_blocks: OK
[   60.178841] Testing event ocfs2_refresh_slot_info: OK
[   60.202386] Testing event ocfs2_map_slot_buffers: OK
[   60.226347] Testing event ocfs2_map_slot_buffers_block: OK
[   60.246346] Testing event ocfs2_find_slot: OK
[   60.278427] Testing event ocfs2_do_node_down: OK
[   60.313376] Testing event ocfs2_remount: OK
[   60.334725] Testing event ocfs2_fill_super: OK
[   60.362359] Testing event ocfs2_parse_options: OK
[   60.382318] Testing event ocfs2_put_super: OK
[   60.401706] Testing event ocfs2_statfs: OK
[   60.419396] Testing event ocfs2_dismount_volume: OK
[   60.442302] Testing event ocfs2_initialize_super: OK
[   60.462299] Testing event ocfs2_validate_xattr_block: OK
[   60.482614] Testing event ocfs2_xattr_extend_allocation: OK
[   60.514360] Testing event ocfs2_init_xattr_set_ctxt: OK
[   60.534311] Testing event ocfs2_xattr_bucket_find: OK
[   60.580887] Testing event ocfs2_xattr_index_block_find: OK
[   60.609639] Testing event ocfs2_xattr_index_block_find_rec: OK
[   60.631596] Testing event ocfs2_iterate_xattr_buckets: OK
[   60.662546] Testing event ocfs2_iterate_xattr_bucket: OK
[   60.691563] Testing event ocfs2_cp_xattr_block_to_bucket_begin: OK
[   60.717247] Testing event ocfs2_cp_xattr_block_to_bucket_end: OK
[   60.738641] Testing event ocfs2_xattr_create_index_block_begin: OK
[   60.758517] Testing event ocfs2_xattr_create_index_block: OK
[   60.780675] Testing event ocfs2_defrag_xattr_bucket: OK
[   60.802609] Testing event ocfs2_mv_xattr_bucket_cross_cluster: OK
[   60.822565] Testing event ocfs2_divide_xattr_bucket_begin: OK
[   60.846427] Testing event ocfs2_divide_xattr_bucket_move: OK
[   60.866484] Testing event ocfs2_cp_xattr_bucket: OK
[   60.891758] Testing event ocfs2_mv_xattr_buckets: OK
[   60.915145] Testing event ocfs2_adjust_xattr_cross_cluster: OK
[   60.947883] Testing event ocfs2_add_new_xattr_cluster_begin: OK
[   60.970945] Testing event ocfs2_add_new_xattr_cluster: OK
[   60.991090] Testing event ocfs2_add_new_xattr_cluster_insert: OK
[   61.014970] Testing event ocfs2_extend_xattr_bucket: OK
[   61.037615] Testing event ocfs2_add_new_xattr_bucket: OK
[   61.058307] Testing event ocfs2_xattr_bucket_value_truncate: OK
[   61.078280] Testing event ocfs2_rm_xattr_cluster: OK
[   61.098984] Testing event ocfs2_reflink_xattr_header: OK
[   61.131254] Testing event ocfs2_create_empty_xattr_block: OK
[   61.150497] Testing event ocfs2_xattr_set_entry_bucket: OK
[   61.171122] Testing event ocfs2_xattr_set_entry_index_block: OK
[   61.202658] Testing event ocfs2_xattr_bucket_value_refcount: OK
[   61.253641] Testing event ocfs2_reflink_xattr_buckets: OK
[   61.287222] Testing event ocfs2_reflink_xattr_rec: OK
[   61.316874] Testing event ocfs2_resv_insert: OK
[   61.350214] Testing event ocfs2_resmap_find_free_bits_begin: OK
[   61.372817] Testing event ocfs2_resmap_find_free_bits_end: OK
[   61.406353] Testing event ocfs2_resv_find_window_begin: OK
[   61.426459] Testing event ocfs2_resv_find_window_prev: OK
[   61.448810] Testing event ocfs2_resv_find_window_next: OK
[   61.469424] Testing event ocfs2_cannibalize_resv_begin: OK
[   61.489410] Testing event ocfs2_cannibalize_resv_end: OK
[   61.506097] Testing event ocfs2_resmap_resv_bits: OK
[   61.525483] Testing event ocfs2_resmap_claimed_bits_begin: OK
[   61.541400] Testing event ocfs2_resmap_claimed_bits_end: OK
[   61.558362] Testing event ocfs2_recover_local_quota_file: OK
[   61.579244] Testing event ocfs2_finish_quota_recovery: OK
[   61.598494] Testing event olq_set_dquot: OK
[   61.618363] Testing event ocfs2_validate_quota_block: OK
[   61.638362] Testing event ocfs2_sync_dquot: OK
[   61.659511] Testing event ocfs2_sync_dquot_helper: OK
[   61.678374] Testing event ocfs2_write_dquot: OK
[   61.698446] Testing event ocfs2_release_dquot: OK
[   61.718372] Testing event ocfs2_acquire_dquot: OK
[   61.738651] Testing event ocfs2_mark_dquot_dirty: OK
[   61.769381] Testing event ocfs2_search_dirblock: OK
[   61.818150] Testing event ocfs2_validate_dir_block: OK
[   61.839830] Testing event ocfs2_find_entry_el: OK
[   61.859193] Testing event ocfs2_dx_dir_search: OK
[   61.883360] Testing event ocfs2_dx_dir_search_leaf_info: OK
[   61.906097] Testing event ocfs2_delete_entry_dx: OK
[   61.930686] Testing event ocfs2_readdir: OK
[   61.950357] Testing event ocfs2_find_files_on_disk: OK
[   61.975025] Testing event ocfs2_check_dir_for_entry: OK
[   61.994501] Testing event ocfs2_dx_dir_attach_index: OK
[   62.019394] Testing event ocfs2_dx_dir_format_cluster: OK
[   62.038149] Testing event ocfs2_dx_dir_index_root_block: OK
[   62.062770] Testing event ocfs2_extend_dir: OK
[   62.082996] Testing event ocfs2_dx_dir_rebalance: OK
[   62.108172] Testing event ocfs2_dx_dir_rebalance_split: OK
[   62.133976] Testing event ocfs2_prepare_dir_for_insert: OK
[   62.154434] Testing event ocfs2_lookup: OK
[   62.174186] Testing event ocfs2_mkdir: OK
[   62.194471] Testing event ocfs2_create: OK
[   62.214446] Testing event ocfs2_unlink: OK
[   62.235475] Testing event ocfs2_symlink_create: OK
[   62.258391] Testing event ocfs2_mv_orphaned_inode_to_new: OK
[   62.305808] Testing event ocfs2_lookup_ret: OK
[   62.330177] Testing event ocfs2_mknod: OK
[   62.350911] Testing event ocfs2_link: OK
[   62.374280] Testing event ocfs2_unlink_noent: OK
[   62.398364] Testing event ocfs2_double_lock: OK
[   62.418415] Testing event ocfs2_double_lock_end: OK
[   62.440173] Testing event ocfs2_rename: OK
[   62.464359] Testing event ocfs2_rename_target_exists: OK
[   62.487014] Testing event ocfs2_rename_disagree: OK
[   62.506876] Testing event ocfs2_rename_over_existing: OK
[   62.527147] Testing event ocfs2_create_symlink_data: OK
[   62.554441] Testing event ocfs2_symlink_begin: OK
[   62.574487] Testing event ocfs2_blkno_stringify: OK
[   62.594293] Testing event ocfs2_orphan_add_begin: OK
[   62.614343] Testing event ocfs2_orphan_add_end: OK
[   62.635080] Testing event ocfs2_orphan_del: OK
[   62.663013] Testing event ocfs2_dentry_revalidate: OK
[   62.682421] Testing event ocfs2_dentry_revalidate_negative: OK
[   62.702579] Testing event ocfs2_dentry_revalidate_delete: OK
[   62.722538] Testing event ocfs2_dentry_revalidate_orphaned: OK
[   62.742040] Testing event ocfs2_dentry_revalidate_nofsdata: OK
[   62.762103] Testing event ocfs2_dentry_revalidate_ret: OK
[   62.782287] Testing event ocfs2_find_local_alias: OK
[   62.802279] Testing event ocfs2_dentry_attach_lock: OK
[   62.823156] Testing event ocfs2_dentry_attach_lock_found: OK
[   62.842477] Testing event ocfs2_get_dentry_begin: OK
[   62.862167] Testing event ocfs2_get_dentry_test_bit: OK
[   62.882133] Testing event ocfs2_get_dentry_stale: OK
[   62.901788] Testing event ocfs2_get_dentry_generation: OK
[   62.922238] Testing event ocfs2_get_dentry_end: OK
[   62.945736] Testing event ocfs2_get_parent: OK
[   62.966532] Testing event ocfs2_get_parent_end: OK
[   62.986505] Testing event ocfs2_encode_fh_begin: OK
[   63.005911] Testing event ocfs2_encode_fh_self: OK
[   63.026294] Testing event ocfs2_encode_fh_parent: OK
[   63.052197] Testing event ocfs2_encode_fh_type: OK
[   63.070338] Testing event ocfs2_commit_cache_begin: OK
[   63.091199] Testing event ocfs2_commit_cache_end: OK
[   63.115431] Testing event ocfs2_extend_trans: OK
[   63.133469] Testing event ocfs2_extend_trans_restart: OK
[   63.154367] Testing event ocfs2_journal_access: OK
[   63.194277] Testing event ocfs2_journal_dirty: OK
[   63.215167] Testing event ocfs2_journal_init: OK
[   63.234596] Testing event ocfs2_journal_init_maxlen: OK
[   63.254736] Testing event ocfs2_journal_shutdown: OK
[   63.275892] Testing event ocfs2_journal_shutdown_wait: OK
[   63.293986] Testing event ocfs2_complete_recovery: OK
[   63.314098] Testing event ocfs2_complete_recovery_end: OK
[   63.334096] Testing event ocfs2_complete_recovery_slot: OK
[   63.353680] Testing event ocfs2_recovery_thread_node: OK
[   63.375964] Testing event ocfs2_recovery_thread_end: OK
[   63.394529] Testing event ocfs2_recovery_thread: OK
[   63.414210] Testing event ocfs2_replay_journal_recovered: OK
[   63.435717] Testing event ocfs2_replay_journal_lock_err: OK
[   63.455023] Testing event ocfs2_replay_journal_skip: OK
[   63.483791] Testing event ocfs2_recover_node: OK
[   63.502754] Testing event ocfs2_recover_node_skip: OK
[   63.522055] Testing event ocfs2_mark_dead_nodes: OK
[   63.542565] Testing event ocfs2_queue_orphan_scan_begin: OK
[   63.562093] Testing event ocfs2_queue_orphan_scan_end: OK
[   63.582513] Testing event ocfs2_orphan_filldir: OK
[   63.602045] Testing event ocfs2_recover_orphans: OK
[   63.622402] Testing event ocfs2_recover_orphans_iput: OK
[   63.646436] Testing event ocfs2_wait_on_mount: OK
[   63.670817] Testing event ocfs2_read_blocks_sync: OK
[   63.694603] Testing event ocfs2_read_blocks_sync_jbd: OK
[   63.714476] Testing event ocfs2_read_blocks_from_disk: OK
[   63.735189] Testing event ocfs2_read_blocks_bh: OK
[   63.781036] Testing event ocfs2_read_blocks_end: OK
[   63.803221] Testing event ocfs2_write_block: OK
[   63.826295] Testing event ocfs2_read_blocks_begin: OK
[   63.846456] Testing event ocfs2_purge_copied_metadata_tree: OK
[   63.866367] Testing event ocfs2_metadata_cache_purge: OK
[   63.886516] Testing event ocfs2_buffer_cached_begin: OK
[   63.911164] Testing event ocfs2_buffer_cached_end: OK
[   63.930525] Testing event ocfs2_append_cache_array: OK
[   63.954822] Testing event ocfs2_insert_cache_tree: OK
[   63.974837] Testing event ocfs2_expand_cache: OK
[   64.003766] Testing event ocfs2_set_buffer_uptodate: OK
[   64.023131] Testing event ocfs2_set_buffer_uptodate_begin: OK
[   64.058465] Testing event ocfs2_remove_metadata_array: OK
[   64.078756] Testing event ocfs2_remove_metadata_tree: OK
[   64.102710] Testing event ocfs2_remove_block_from_cache: OK
[   64.123336] Testing event xfs_attr_list_sf: OK
[   64.142993] Testing event xfs_attr_list_sf_all: OK
[   64.163854] Testing event xfs_attr_list_leaf: OK
[   64.188891] Testing event xfs_attr_list_leaf_end: OK
[   64.230601] Testing event xfs_attr_list_full: OK
[   64.260304] Testing event xfs_attr_list_add: OK
[   64.286639] Testing event xfs_attr_list_wrong_blk: OK
[   64.306786] Testing event xfs_attr_list_notfound: OK
[   64.327067] Testing event xfs_perag_get: OK
[   64.346706] Testing event xfs_perag_get_tag: OK
[   64.366088] Testing event xfs_perag_put: OK
[   64.404262] Testing event xfs_perag_set_reclaim: OK
[   64.422220] Testing event xfs_perag_clear_reclaim: OK
[   64.442566] Testing event xfs_attr_list_node_descend: OK
[   64.462639] Testing event xfs_iext_insert: OK
[   64.490385] Testing event xfs_iext_remove: OK
[   64.509330] Testing event xfs_bmap_pre_update: OK
[   64.525961] Testing event xfs_bmap_post_update: OK
[   64.546145] Testing event xfs_extlist: OK
[   64.566207] Testing event xfs_buf_init: OK
[   64.585951] Testing event xfs_buf_free: OK
[   64.606609] Testing event xfs_buf_hold: OK
[   64.627639] Testing event xfs_buf_rele: OK
[   64.647259] Testing event xfs_buf_iodone: OK
[   64.675236] Testing event xfs_buf_iorequest: OK
[   64.694386] Testing event xfs_buf_bawrite: OK
[   64.715204] Testing event xfs_buf_lock: OK
[   64.736579] Testing event xfs_buf_lock_done: OK
[   64.760240] Testing event xfs_buf_trylock: OK
[   64.784381] Testing event xfs_buf_unlock: OK
[   64.812483] Testing event xfs_buf_iowait: OK
[   64.834512] Testing event xfs_buf_iowait_done: OK
[   64.854887] Testing event xfs_buf_delwri_queue: OK
[   64.874620] Testing event xfs_buf_delwri_queued: OK
[   64.894520] Testing event xfs_buf_delwri_split: OK
[   64.915641] Testing event xfs_buf_get_uncached: OK
[   64.935331] Testing event xfs_bdstrat_shut: OK
[   64.956632] Testing event xfs_buf_item_relse: OK
[   64.983327] Testing event xfs_buf_item_iodone: OK
[   65.002982] Testing event xfs_buf_item_iodone_async: OK
[   65.022396] Testing event xfs_buf_error_relse: OK
[   65.042779] Testing event xfs_trans_read_buf_io: OK
[   65.061782] Testing event xfs_trans_read_buf_shut: OK
[   65.082090] Testing event xfs_btree_corrupt: OK
[   65.102871] Testing event xfs_da_btree_corrupt: OK
[   65.123427] Testing event xfs_reset_dqcounts: OK
[   65.155106] Testing event xfs_inode_item_push: OK
[   65.174694] Testing event xfs_buf_find: OK
[   65.220524] Testing event xfs_buf_get: OK
[   65.245161] Testing event xfs_buf_read: OK
[   65.270685] Testing event xfs_buf_ioerror: OK
[   65.304686] Testing event xfs_buf_item_size: OK
[   65.348651] Testing event xfs_buf_item_size_stale: OK
[   65.396849] Testing event xfs_buf_item_format: OK
[   65.418347] Testing event xfs_buf_item_format_stale: OK
[   65.446181] Testing event xfs_buf_item_pin: OK
[   65.466287] Testing event xfs_buf_item_unpin: OK
[   65.489907] Testing event xfs_buf_item_unpin_stale: OK
[   65.510412] Testing event xfs_buf_item_unlock: OK
[   65.533543] Testing event xfs_buf_item_unlock_stale: OK
[   65.563511] Testing event xfs_buf_item_committed: OK
[   65.587398] Testing event xfs_buf_item_push: OK
[   65.630878] Testing event xfs_trans_get_buf: OK
[   65.662443] Testing event xfs_trans_get_buf_recur: OK
[   65.690382] Testing event xfs_trans_getsb: OK
[   65.715614] Testing event xfs_trans_getsb_recur: OK
[   65.751445] Testing event xfs_trans_read_buf: OK
[   65.778769] Testing event xfs_trans_read_buf_recur: OK
[   65.799838] Testing event xfs_trans_log_buf: OK
[   65.830435] Testing event xfs_trans_brelse: OK
[   65.854582] Testing event xfs_trans_bjoin: OK
[   65.873832] Testing event xfs_trans_bhold: OK
[   65.895498] Testing event xfs_trans_bhold_release: OK
[   65.913761] Testing event xfs_trans_binval: OK
[   65.936121] Testing event xfs_ilock: OK
[   65.958120] Testing event xfs_ilock_nowait: OK
[   65.978307] Testing event xfs_ilock_demote: OK
[   66.002384] Testing event xfs_iunlock: OK
[   66.030477] Testing event xfs_iget_skip: OK
[   66.062857] Testing event xfs_iget_reclaim: OK
[   66.082445] Testing event xfs_iget_reclaim_fail: OK
[   66.103005] Testing event xfs_iget_hit: OK
[   66.129230] Testing event xfs_iget_miss: OK
[   66.146726] Testing event xfs_getattr: OK
[   66.165828] Testing event xfs_setattr: OK
[   66.186321] Testing event xfs_readlink: OK
[   66.214320] Testing event xfs_alloc_file_space: OK
[   66.234484] Testing event xfs_free_file_space: OK
[   66.254350] Testing event xfs_readdir: OK
[   66.274522] Testing event xfs_get_acl: OK
[   66.298615] Testing event xfs_vm_bmap: OK
[   66.318251] Testing event xfs_file_ioctl: OK
[   66.342486] Testing event xfs_file_compat_ioctl: OK
[   66.362402] Testing event xfs_ioctl_setattr: OK
[   66.383083] Testing event xfs_dir_fsync: OK
[   66.415157] Testing event xfs_file_fsync: OK
[   66.444887] Testing event xfs_destroy_inode: OK
[   66.466996] Testing event xfs_evict_inode: OK
[   66.485829] Testing event xfs_update_time: OK
[   66.505872] Testing event xfs_dquot_dqalloc: OK
[   66.526117] Testing event xfs_dquot_dqdetach: OK
[   66.545837] Testing event xfs_ihold: OK
[   66.566037] Testing event xfs_irele: OK
[   66.586896] Testing event xfs_inode_pin: OK
[   66.610074] Testing event xfs_inode_unpin: OK
[   66.630086] Testing event xfs_inode_unpin_nowait: OK
[   66.651024] Testing event xfs_remove: OK
[   66.672547] Testing event xfs_link: OK
[   66.690044] Testing event xfs_lookup: OK
[   66.710396] Testing event xfs_create: OK
[   66.729855] Testing event xfs_symlink: OK
[   66.751424] Testing event xfs_rename: OK
[   66.771113] Testing event xfs_dqadjust: OK
[   66.790448] Testing event xfs_dqreclaim_want: OK
[   66.810710] Testing event xfs_dqreclaim_dirty: OK
[   66.831143] Testing event xfs_dqreclaim_busy: OK
[   66.851585] Testing event xfs_dqreclaim_done: OK
[   66.887943] Testing event xfs_dqattach_found: OK
[   66.911197] Testing event xfs_dqattach_get: OK
[   66.931883] Testing event xfs_dqalloc: OK
[   66.950691] Testing event xfs_dqtobp_read: OK
[   66.977741] Testing event xfs_dqread: OK
[   66.998464] Testing event xfs_dqread_fail: OK
[   67.019300] Testing event xfs_dqget_hit: OK
[   67.043908] Testing event xfs_dqget_miss: OK
[   67.074361] Testing event xfs_dqget_freeing: OK
[   67.094519] Testing event xfs_dqget_dup: OK
[   67.129072] Testing event xfs_dqput: OK
[   67.151220] Testing event xfs_dqput_wait: OK
[   67.170422] Testing event xfs_dqput_free: OK
[   67.190951] Testing event xfs_dqrele: OK
[   67.213184] Testing event xfs_dqflush: OK
[   67.234131] Testing event xfs_dqflush_force: OK
[   67.254784] Testing event xfs_dqflush_done: OK
[   67.279596] Testing event xfs_log_done_nonperm: OK
[   67.299587] Testing event xfs_log_done_perm: OK
[   67.318139] Testing event xfs_log_umount_write: OK
[   67.338171] Testing event xfs_log_grant_sleep: OK
[   67.358433] Testing event xfs_log_grant_wake: OK
[   67.378482] Testing event xfs_log_grant_wake_up: OK
[   67.399208] Testing event xfs_log_reserve: OK
[   67.426080] Testing event xfs_log_reserve_exit: OK
[   67.449441] Testing event xfs_log_regrant: OK
[   67.471032] Testing event xfs_log_regrant_exit: OK
[   67.499243] Testing event xfs_log_regrant_reserve_enter: OK
[   67.519739] Testing event xfs_log_regrant_reserve_exit: OK
[   67.548410] Testing event xfs_log_regrant_reserve_sub: OK
[   67.574432] Testing event xfs_log_ungrant_enter: OK
[   67.594355] Testing event xfs_log_ungrant_exit: OK
[   67.614634] Testing event xfs_log_ungrant_sub: OK
[   67.635207] Testing event xfs_log_force: OK
[   67.668199] Testing event xfs_ail_push: OK
[   67.691028] Testing event xfs_ail_pinned: OK
[   67.735317] Testing event xfs_ail_locked: OK
[   67.767021] Testing event xfs_ail_flushing: OK
[   67.786435] Testing event xfs_file_read: OK
[   67.806475] Testing event xfs_file_buffered_write: OK
[   67.838337] Testing event xfs_file_direct_write: OK
[   67.866554] Testing event xfs_file_splice_read: OK
[   67.886545] Testing event xfs_file_splice_write: OK
[   67.906422] Testing event xfs_writepage: OK
[   67.926642] Testing event xfs_releasepage: OK
[   67.946514] Testing event xfs_invalidatepage: OK
[   67.966525] Testing event xfs_map_blocks_found: OK
[   67.989890] Testing event xfs_map_blocks_alloc: OK
[   68.033791] Testing event xfs_get_blocks_found: OK
[   68.062578] Testing event xfs_get_blocks_alloc: OK
[   68.085912] Testing event xfs_delalloc_enospc: OK
[   68.115692] Testing event xfs_unwritten_convert: OK
[   68.142217] Testing event xfs_get_blocks_notfound: OK
[   68.206824] Testing event xfs_setfilesize: OK
[   68.238561] Testing event xfs_itruncate_extents_start: OK
[   68.258387] Testing event xfs_itruncate_extents_end: OK
[   68.302225] Testing event xfs_pagecache_inval: OK
[   68.322849] Testing event xfs_bunmap: OK
[   68.346559] Testing event xfs_extent_busy: OK
[   68.366480] Testing event xfs_extent_busy_enomem: OK
[   68.387157] Testing event xfs_extent_busy_force: OK
[   68.410794] Testing event xfs_extent_busy_reuse: OK
[   68.434616] Testing event xfs_extent_busy_clear: OK
[   68.458827] Testing event xfs_extent_busy_trim: OK
[   68.478524] Testing event xfs_trans_commit_lsn: OK
[   68.515710] Testing event xfs_agf: OK
[   68.543969] Testing event xfs_free_extent: OK
[   68.562342] Testing event xfs_alloc_exact_done: OK
[   68.595016] Testing event xfs_alloc_exact_notfound: OK
[   68.631004] Testing event xfs_alloc_exact_error: OK
[   68.652226] Testing event xfs_alloc_near_nominleft: OK
[   68.674448] Testing event xfs_alloc_near_first: OK
[   68.698349] Testing event xfs_alloc_near_greater: OK
[   68.718497] Testing event xfs_alloc_near_lesser: OK
[   68.748157] Testing event xfs_alloc_near_error: OK
[   68.774494] Testing event xfs_alloc_near_noentry: OK
[   68.808372] Testing event xfs_alloc_near_busy: OK
[   68.837765] Testing event xfs_alloc_size_neither: OK
[   68.867660] Testing event xfs_alloc_size_noentry: OK
[   68.890436] Testing event xfs_alloc_size_nominleft: OK
[   68.910419] Testing event xfs_alloc_size_done: OK
[   68.930466] Testing event xfs_alloc_size_error: OK
[   68.950384] Testing event xfs_alloc_size_busy: OK
[   68.974209] Testing event xfs_alloc_small_freelist: OK
[   68.994479] Testing event xfs_alloc_small_notenough: OK
[   69.015639] Testing event xfs_alloc_small_done: OK
[   69.034568] Testing event xfs_alloc_small_error: OK
[   69.058516] Testing event xfs_alloc_vextent_badargs: OK
[   69.088487] Testing event xfs_alloc_vextent_nofix: OK
[   69.110453] Testing event xfs_alloc_vextent_noagbp: OK
[   69.136762] Testing event xfs_alloc_vextent_loopfailed: OK
[   69.158837] Testing event xfs_alloc_vextent_allfailed: OK
[   69.196421] Testing event xfs_dir2_sf_addname: OK
[   69.226357] Testing event xfs_dir2_sf_create: OK
[   69.250543] Testing event xfs_dir2_sf_lookup: OK
[   69.286772] Testing event xfs_dir2_sf_replace: OK
[   69.306533] Testing event xfs_dir2_sf_removename: OK
[   69.339088] Testing event xfs_dir2_sf_toino4: OK
[   69.363462] Testing event xfs_dir2_sf_toino8: OK
[   69.386612] Testing event xfs_dir2_sf_to_block: OK
[   69.419657] Testing event xfs_dir2_block_addname: OK
[   69.453083] Testing event xfs_dir2_block_lookup: OK
[   69.474410] Testing event xfs_dir2_block_replace: OK
[   69.507469] Testing event xfs_dir2_block_removename: OK
[   69.534338] Testing event xfs_dir2_block_to_sf: OK
[   69.554373] Testing event xfs_dir2_block_to_leaf: OK
[   69.574395] Testing event xfs_dir2_leaf_addname: OK
[   69.594382] Testing event xfs_dir2_leaf_lookup: OK
[   69.614488] Testing event xfs_dir2_leaf_replace: OK
[   69.638292] Testing event xfs_dir2_leaf_removename: OK
[   69.658279] Testing event xfs_dir2_leaf_to_block: OK
[   69.678444] Testing event xfs_dir2_leaf_to_node: OK
[   69.698395] Testing event xfs_dir2_node_addname: OK
[   69.722398] Testing event xfs_dir2_node_lookup: OK
[   69.747028] Testing event xfs_dir2_node_replace: OK
[   69.776828] Testing event xfs_dir2_node_removename: OK
[   69.800179] Testing event xfs_dir2_node_to_leaf: OK
[   69.829457] Testing event xfs_attr_sf_add: OK
[   69.859577] Testing event xfs_attr_sf_addname: OK
[   69.903112] Testing event xfs_attr_sf_create: OK
[   69.943761] Testing event xfs_attr_sf_lookup: OK
[   69.969359] Testing event xfs_attr_sf_remove: OK
[   69.995311] Testing event xfs_attr_sf_removename: OK
[   70.021960] Testing event xfs_attr_sf_to_leaf: OK
[   70.043405] Testing event xfs_attr_leaf_add: OK
[   70.063126] Testing event xfs_attr_leaf_add_old: OK
[   70.083032] Testing event xfs_attr_leaf_add_new: OK
[   70.102411] Testing event xfs_attr_leaf_addname: OK
[   70.123801] Testing event xfs_attr_leaf_create: OK
[   70.169901] Testing event xfs_attr_leaf_lookup: OK
[   70.203651] Testing event xfs_attr_leaf_replace: OK
[   70.228233] Testing event xfs_attr_leaf_removename: OK
[   70.248902] Testing event xfs_attr_leaf_split: OK
[   70.271340] Testing event xfs_attr_leaf_split_before: OK
[   70.301730] Testing event xfs_attr_leaf_split_after: OK
[   70.322457] Testing event xfs_attr_leaf_clearflag: OK
[   70.347959] Testing event xfs_attr_leaf_setflag: OK
[   70.376285] Testing event xfs_attr_leaf_flipflags: OK
[   70.397456] Testing event xfs_attr_leaf_to_sf: OK
[   70.422295] Testing event xfs_attr_leaf_to_node: OK
[   70.467070] Testing event xfs_attr_leaf_rebalance: OK
[   70.486370] Testing event xfs_attr_leaf_unbalance: OK
[   70.515978] Testing event xfs_attr_node_addname: OK
[   70.555065] Testing event xfs_attr_node_lookup: OK
[   70.574525] Testing event xfs_attr_node_replace: OK
[   70.611043] Testing event xfs_attr_node_removename: OK
[   70.634375] Testing event xfs_da_split: OK
[   70.654839] Testing event xfs_da_join: OK
[   70.680744] Testing event xfs_da_link_before: OK
[   70.714281] Testing event xfs_da_link_after: OK
[   70.734398] Testing event xfs_da_unlink_back: OK
[   70.762015] Testing event xfs_da_unlink_forward: OK
[   70.782444] Testing event xfs_da_root_split: OK
[   70.806562] Testing event xfs_da_root_join: OK
[   70.851153] Testing event xfs_da_node_add: OK
[   70.887120] Testing event xfs_da_node_create: OK
[   70.911089] Testing event xfs_da_node_split: OK
[   70.958147] Testing event xfs_da_node_remove: OK
[   70.991045] Testing event xfs_da_node_rebalance: OK
[   71.014830] Testing event xfs_da_node_unbalance: OK
[   71.039091] Testing event xfs_da_swap_lastblock: OK
[   71.058986] Testing event xfs_da_grow_inode: OK
[   71.095480] Testing event xfs_da_shrink_inode: OK
[   71.131297] Testing event xfs_dir2_leafn_add: OK
[   71.152250] Testing event xfs_dir2_leafn_remove: OK
[   71.195366] Testing event xfs_dir2_grow_inode: OK
[   71.214803] Testing event xfs_dir2_shrink_inode: OK
[   71.247144] Testing event xfs_dir2_leafn_moveents: OK
[   71.271132] Testing event xfs_swap_extent_before: OK
[   71.306810] Testing event xfs_swap_extent_after: OK
[   71.331687] Testing event xfs_log_recover_item_add: OK
[   71.368178] Testing event xfs_log_recover_item_add_cont: OK
[   71.399114] Testing event xfs_log_recover_item_reorder_head: OK
[   71.435578] Testing event xfs_log_recover_item_reorder_tail: OK
[   71.465897] Testing event xfs_log_recover_item_recover: OK
[   71.498392] Testing event xfs_log_recover_buf_not_cancel: OK
[   71.518386] Testing event xfs_log_recover_buf_cancel: OK
[   71.538435] Testing event xfs_log_recover_buf_cancel_add: OK
[   71.558577] Testing event xfs_log_recover_buf_cancel_ref_inc: OK
[   71.595484] Testing event xfs_log_recover_buf_recover: OK
[   71.614958] Testing event xfs_log_recover_buf_inode_buf: OK
[   71.634564] Testing event xfs_log_recover_buf_reg_buf: OK
[   71.658437] Testing event xfs_log_recover_buf_dquot_buf: OK
[   71.682689] Testing event xfs_log_recover_inode_recover: OK
[   71.704997] Testing event xfs_log_recover_inode_cancel: OK
[   71.730429] Testing event xfs_log_recover_inode_skip: OK
[   71.762853] Testing event xfs_discard_extent: OK
[   71.782483] Testing event xfs_discard_toosmall: OK
[   71.805714] Testing event xfs_discard_exclude: OK
[   71.830414] Testing event xfs_discard_busy: OK
[   71.851274] Testing event jbd2_checkpoint: OK
[   71.871635] Testing event jbd2_start_commit: OK
[   71.912156] Testing event jbd2_commit_locking: OK
[   71.943414] Testing event jbd2_commit_flushing: OK
[   71.962383] Testing event jbd2_commit_logging: OK
[   71.984300] Testing event jbd2_drop_transaction: OK
[   72.031282] Testing event jbd2_end_commit: OK
[   72.051136] Testing event jbd2_submit_inode_data: OK
[   72.070420] Testing event jbd2_run_stats: OK
[   72.090989] Testing event jbd2_checkpoint_stats: OK
[   72.110483] Testing event jbd2_update_log_tail: OK
[   72.131077] Testing event jbd2_write_superblock: OK
[   72.150883] Testing event jbd_checkpoint: OK
[   72.170359] Testing event jbd_start_commit: OK
[   72.190425] Testing event jbd_commit_locking: OK
[   72.220894] Testing event jbd_commit_flushing: OK
[   72.242779] Testing event jbd_commit_logging: OK
[   72.263147] Testing event jbd_drop_transaction: OK
[   72.282439] Testing event jbd_end_commit: OK
[   72.303342] Testing event jbd_do_submit_data: OK
[   72.327175] Testing event jbd_cleanup_journal_tail: OK
[   72.379293] Testing event journal_write_superblock: OK
[   72.399513] Testing event ext4_free_inode: OK
[   72.418898] Testing event ext4_request_inode: OK
[   72.454971] Testing event ext4_allocate_inode: OK
[   72.493768] Testing event ext4_evict_inode: OK
[   72.519096] Testing event ext4_drop_inode: OK
[   72.555067] Testing event ext4_mark_inode_dirty: OK
[   72.578072] Testing event ext4_begin_ordered_truncate: OK
[   72.603695] Testing event ext4_write_begin: OK
[   72.625152] Testing event ext4_da_write_begin: OK
[   72.646709] Testing event ext4_ordered_write_end: OK
[   72.679051] Testing event ext4_writeback_write_end: OK
[   72.722896] Testing event ext4_journalled_write_end: OK
[   72.755069] Testing event ext4_da_write_end: OK
[   72.783318] Testing event ext4_da_writepages: OK
[   72.813709] Testing event ext4_da_write_pages: OK
[   72.836168] Testing event ext4_da_writepages_result: OK
[   72.854378] Testing event ext4_writepage: OK
[   72.874841] Testing event ext4_readpage: OK
[   72.895391] Testing event ext4_releasepage: OK
[   72.914493] Testing event ext4_invalidatepage: OK
[   72.945528] Testing event ext4_discard_blocks: OK
[   72.966560] Testing event ext4_mb_new_inode_pa: OK
[   72.986981] Testing event ext4_mb_new_group_pa: OK
[   73.009000] Testing event ext4_mb_release_inode_pa: OK
[   73.030355] Testing event ext4_mb_release_group_pa: OK
[   73.051146] Testing event ext4_discard_preallocations: OK
[   73.071450] Testing event ext4_mb_discard_preallocations: OK
[   73.094947] Testing event ext4_request_blocks: OK
[   73.118085] Testing event ext4_allocate_blocks: OK
[   73.153016] Testing event ext4_free_blocks: OK
[   73.175079] Testing event ext4_sync_file_enter: OK
[   73.204348] Testing event ext4_sync_file_exit: OK
[   73.223213] Testing event ext4_sync_fs: OK
[   73.246188] Testing event ext4_alloc_da_blocks: OK
[   73.266622] Testing event ext4_mballoc_alloc: OK
[   73.294910] Testing event ext4_mballoc_prealloc: OK
[   73.314465] Testing event ext4_mballoc_discard: OK
[   73.342970] Testing event ext4_mballoc_free: OK
[   73.370372] Testing event ext4_forget: OK
[   73.390861] Testing event ext4_da_update_reserve_space: OK
[   73.412639] Testing event ext4_da_reserve_space: OK
[   73.433872] Testing event ext4_da_release_space: OK
[   73.459229] Testing event ext4_mb_bitmap_load: OK
[   73.518584] Testing event ext4_mb_buddy_bitmap_load: OK
[   73.538485] Testing event ext4_read_block_bitmap_load: OK
[   73.558323] Testing event ext4_load_inode_bitmap: OK
[   73.582398] Testing event ext4_direct_IO_enter: OK
[   73.606380] Testing event ext4_direct_IO_exit: OK
[   73.626719] Testing event ext4_fallocate_enter: OK
[   73.654572] Testing event ext4_fallocate_exit: OK
[   73.677515] Testing event ext4_unlink_enter: OK
[   73.698456] Testing event ext4_unlink_exit: OK
[   73.718571] Testing event ext4_truncate_enter: OK
[   73.752004] Testing event ext4_truncate_exit: OK
[   73.776743] Testing event ext4_ext_convert_to_initialized_enter: OK
[   73.798466] Testing event ext4_ext_convert_to_initialized_fastpath: OK
[   73.819363] Testing event ext4_ext_map_blocks_enter: OK
[   73.838273] Testing event ext4_ind_map_blocks_enter: OK
[   73.858432] Testing event ext4_ext_map_blocks_exit: OK
[   73.879845] Testing event ext4_ind_map_blocks_exit: OK
[   73.899762] Testing event ext4_ext_load_extent: OK
[   73.919059] Testing event ext4_load_inode: OK
[   73.938326] Testing event ext4_journal_start: OK
[   73.959673] Testing event ext4_trim_extent: OK
[   73.982104] Testing event ext4_trim_all_free: OK
[   74.002818] Testing event ext4_ext_handle_uninitialized_extents: OK
[   74.041887] Testing event ext4_get_implied_cluster_alloc_exit: OK
[   74.062629] Testing event ext4_ext_put_in_cache: OK
[   74.082546] Testing event ext4_ext_in_cache: OK
[   74.105345] Testing event ext4_find_delalloc_range: OK
[   74.126546] Testing event ext4_get_reserved_cluster_alloc: OK
[   74.147566] Testing event ext4_ext_show_extent: OK
[   74.170989] Testing event ext4_remove_blocks: OK
[   74.192288] Testing event ext4_ext_rm_leaf: OK
[   74.215040] Testing event ext4_ext_rm_idx: OK
[   74.235664] Testing event ext4_ext_remove_space: OK
[   74.255068] Testing event ext4_ext_remove_space_done: OK
[   74.279063] Testing event ext3_free_inode: OK
[   74.299240] Testing event ext3_request_inode: OK
[   74.318527] Testing event ext3_allocate_inode: OK
[   74.339438] Testing event ext3_evict_inode: OK
[   74.362359] Testing event ext3_drop_inode: OK
[   74.382897] Testing event ext3_mark_inode_dirty: OK
[   74.414115] Testing event ext3_write_begin: OK
[   74.447212] Testing event ext3_ordered_write_end: OK
[   74.468588] Testing event ext3_writeback_write_end: OK
[   74.490536] Testing event ext3_journalled_write_end: OK
[   74.511242] Testing event ext3_ordered_writepage: OK
[   74.540596] Testing event ext3_writeback_writepage: OK
[   74.564769] Testing event ext3_journalled_writepage: OK
[   74.606686] Testing event ext3_readpage: OK
[   74.627518] Testing event ext3_releasepage: OK
[   74.651065] Testing event ext3_invalidatepage: OK
[   74.675219] Testing event ext3_discard_blocks: OK
[   74.695106] Testing event ext3_request_blocks: OK
[   74.719134] Testing event ext3_allocate_blocks: OK
[   74.750539] Testing event ext3_free_blocks: OK
[   74.771132] Testing event ext3_sync_file_enter: OK
[   74.791098] Testing event ext3_sync_file_exit: OK
[   74.814824] Testing event ext3_sync_fs: OK
[   74.834441] Testing event ext3_rsv_window_add: OK
[   74.854229] Testing event ext3_discard_reservation: OK
[   74.874579] Testing event ext3_alloc_new_reservation: OK
[   74.894393] Testing event ext3_reserved: OK
[   74.915025] Testing event ext3_forget: OK
[   74.935242] Testing event ext3_read_block_bitmap: OK
[   74.954139] Testing event ext3_direct_IO_enter: OK
[   74.974600] Testing event ext3_direct_IO_exit: OK
[   74.998229] Testing event ext3_unlink_enter: OK
[   75.021004] Testing event ext3_unlink_exit: OK
[   75.042344] Testing event ext3_truncate_enter: OK
[   75.062908] Testing event ext3_truncate_exit: OK
[   75.091111] Testing event ext3_get_blocks_enter: OK
[   75.110403] Testing event ext3_get_blocks_exit: OK
[   75.134677] Testing event ext3_load_inode: OK
[   75.154976] Testing event writeback_nothread: OK
[   75.174280] Testing event writeback_queue: OK
[   75.213468] Testing event writeback_exec: OK
[   75.234245] Testing event writeback_start: OK
[   75.254796] Testing event writeback_written: OK
[   75.274632] Testing event writeback_wait: OK
[   75.294135] Testing event writeback_pages_written: OK
[   75.316270] Testing event writeback_nowork: OK
[   75.363187] Testing event writeback_wake_background: OK
[   75.384785] Testing event writeback_wake_thread: OK
[   75.410251] Testing event writeback_wake_forker_thread: OK
[   75.435281] Testing event writeback_bdi_register: OK
[   75.455497] Testing event writeback_bdi_unregister: OK
[   75.480776] Testing event writeback_thread_start: OK
[   75.509613] Testing event writeback_thread_stop: OK
[   75.537112] Testing event wbc_writepage: OK
[   75.567200] Testing event writeback_queue_io: OK
[   75.590120] Testing event global_dirty_state: OK
[   75.611279] Testing event bdi_dirty_ratelimit: OK
[   75.632852] Testing event balance_dirty_pages: OK
[   75.657675] Testing event writeback_sb_inodes_requeue: OK
[   75.682297] Testing event writeback_congestion_wait: OK
[   75.710525] Testing event writeback_wait_iff_congested: OK
[   75.733521] Testing event writeback_single_inode: OK
[   75.750857] Testing event mm_compaction_isolate_migratepages: OK
[   75.778709] Testing event mm_compaction_isolate_freepages: OK
[   75.802163] Testing event mm_compaction_migratepages: OK
[   75.822307] Testing event kmalloc: OK
[   75.842254] Testing event kmem_cache_alloc: OK
[   75.862258] Testing event kmalloc_node: OK
[   75.882232] Testing event kmem_cache_alloc_node: OK
[   75.903839] Testing event kfree: OK
[   75.922359] Testing event kmem_cache_free: OK
[   75.949296] Testing event mm_page_free: OK
[   75.974275] Testing event mm_page_free_batched: OK
[   75.993694] Testing event mm_page_alloc: OK
[   76.015779] Testing event mm_page_alloc_zone_locked: OK
[   76.038426] Testing event mm_page_pcpu_drain: OK
[   76.059678] Testing event mm_page_alloc_extfrag: OK
[   76.078812] Testing event mm_vmscan_kswapd_sleep: OK
[   76.104592] Testing event mm_vmscan_kswapd_wake: OK
[   76.133974] Testing event mm_vmscan_wakeup_kswapd: OK
[   76.181077] Testing event mm_vmscan_direct_reclaim_begin: OK
[   76.201882] Testing event mm_vmscan_memcg_reclaim_begin: OK
[   76.222316] Testing event mm_vmscan_memcg_softlimit_reclaim_begin: OK
[   76.242330] Testing event mm_vmscan_direct_reclaim_end: OK
[   76.262427] Testing event mm_vmscan_memcg_reclaim_end: OK
[   76.282119] Testing event mm_vmscan_memcg_softlimit_reclaim_end: OK
[   76.302332] Testing event mm_shrink_slab_start: OK
[   76.330423] Testing event mm_shrink_slab_end: OK
[   76.350309] Testing event mm_vmscan_lru_isolate: OK
[   76.369667] Testing event mm_vmscan_memcg_isolate: OK
[   76.389793] Testing event mm_vmscan_writepage: OK
[   76.411306] Testing event mm_vmscan_lru_shrink_inactive: OK
[   76.434404] Testing event oom_score_adj_update: OK
[   76.475274] Testing event rpm_suspend: OK
[   76.494980] Testing event rpm_resume: OK
[   76.514772] Testing event rpm_idle: OK
[   76.538408] Testing event rpm_return_int: OK
[   76.558269] Testing event cpu_idle: OK
[   76.579802] Testing event cpu_frequency: OK
[   76.598437] Testing event machine_suspend: OK
[   76.618108] Testing event wakeup_source_activate: OK
[   76.637760] Testing event wakeup_source_deactivate: OK
[   76.654744] Testing event power_start: OK
[   76.673866] Testing event power_frequency: OK
[   76.694872] Testing event power_end: OK
[   76.714723] Testing event clock_enable: OK
[   76.735369] Testing event clock_disable: OK
[   76.754763] Testing event clock_set_rate: OK
[   76.774435] Testing event power_domain_target: OK
[   76.794815] Testing event ftrace_test_filter: OK
[   76.814475] Testing event module_load: OK
[   76.834087] Testing event module_free: OK
[   76.853895] Testing event module_get: OK
[   76.875024] Testing event module_put: OK
[   76.922383] Testing event module_request: OK
[   76.942218] Testing event lock_acquire: OK
[   76.962950] Testing event lock_release: OK
[   76.987320] Testing event lock_contended: OK
[   77.006244] Testing event lock_acquired: OK
[   77.026958] Testing event sched_kthread_stop: OK
[   77.064435] Testing event sched_kthread_stop_ret: OK
[   77.086234] Testing event sched_wakeup: OK
[   77.110224] Testing event sched_wakeup_new: OK
[   77.130822] Testing event sched_switch: OK
[   77.167618] Testing event sched_migrate_task: OK
[   77.210532] Testing event sched_process_free: OK
[   77.235273] Testing event sched_process_exit: OK
[   77.262965] Testing event sched_wait_task: OK
[   77.293193] Testing event sched_process_wait: OK
[   77.313887] Testing event sched_process_fork: OK
[   77.333852] Testing event sched_process_exec: OK
[   77.354333] Testing event sched_stat_wait: OK
[   77.374299] Testing event sched_stat_sleep: OK
[   77.395085] Testing event sched_stat_iowait: OK
[   77.426107] Testing event sched_stat_blocked: OK
[   77.447005] Testing event sched_stat_runtime: OK
[   77.466258] Testing event sched_pi_setprio: OK
[   77.491672] Testing event rcu_utilization: OK
[   77.515667] Testing event rcu_grace_period: OK
[   77.539122] Testing event rcu_grace_period_init: OK
[   77.571963] Testing event rcu_preempt_task: OK
[   77.594130] Testing event rcu_unlock_preempted_task: OK
[   77.614591] Testing event rcu_quiescent_state_report: OK
[   77.633848] Testing event rcu_fqs: OK
[   77.655058] Testing event rcu_dyntick: OK
[   77.682993] Testing event rcu_prep_idle: OK
[   77.704170] Testing event rcu_callback: OK
[   77.722450] Testing event rcu_kfree_callback: OK
[   77.744894] Testing event rcu_batch_start: OK
[   77.765962] Testing event rcu_invoke_callback: OK
[   77.786302] Testing event rcu_invoke_kfree_callback: OK
[   77.806207] Testing event rcu_batch_end: OK
[   77.826295] Testing event rcu_torture_read: OK
[   77.846293] Testing event rcu_barrier: OK
[   77.866157] Testing event workqueue_queue_work: OK
[   77.890128] Testing event workqueue_activate_work: OK
[   77.914953] Testing event workqueue_execute_start: OK
[   77.942859] Testing event workqueue_execute_end: OK
[   77.974038] Testing event signal_generate: OK
[   77.998747] Testing event signal_deliver: OK
[   78.019018] Testing event timer_init: OK
[   78.038325] Testing event timer_start: OK
[   78.058867] Testing event timer_expire_entry: OK
[   78.095182] Testing event timer_expire_exit: OK
[   78.114456] Testing event timer_cancel: OK
[   78.136650] Testing event hrtimer_init: OK
[   78.227651] Testing event hrtimer_start: OK
[   78.262874] Testing event hrtimer_expire_entry: OK
[   78.286886] Testing event hrtimer_expire_exit: OK
[   78.314735] Testing event hrtimer_cancel: OK
[   78.371725] Testing event itimer_state: OK
[   78.396651] Testing event itimer_expire: OK
[   78.422878] Testing event irq_handler_entry: OK
[   78.459491] Testing event irq_handler_exit: OK
[   78.479499] Testing event softirq_entry: OK
[   78.499658] Testing event softirq_exit: OK
[   78.518144] Testing event softirq_raise: OK
[   78.538289] Testing event console: OK
[   78.558203] Testing event task_newtask: OK
[   78.578979] Testing event task_rename: OK
[   78.598385] Testing event mce_record: OK
[   78.618650] Testing event sys_enter: OK
[   78.638275] Testing event sys_exit: OK
[   78.658402] Testing event emulate_vsyscall: OK
[   78.678437] Testing event xen_mc_batch: OK
[   78.698605] Testing event xen_mc_issue: OK
[   78.757018] Testing event xen_mc_entry: OK
[   78.779131] Testing event xen_mc_entry_alloc: OK
[   78.827901] Testing event xen_mc_callback: OK
[   78.851321] Testing event xen_mc_flush_reason: OK
[   78.903336] Testing event xen_mc_flush: OK
[   78.935749] Testing event xen_mc_extend_args: OK
[   78.954774] Testing event xen_mmu_set_pte: OK
[   78.978614] Testing event xen_mmu_set_pte_atomic: OK
[   78.998635] Testing event xen_mmu_set_domain_pte: OK
[   79.018314] Testing event xen_mmu_set_pte_at: OK
[   79.038363] Testing event xen_mmu_pte_clear: OK
[   79.062982] Testing event xen_mmu_set_pmd: OK
[   79.103049] Testing event xen_mmu_pmd_clear: OK
[   79.138330] Testing event xen_mmu_set_pud: OK
[   79.171481] Testing event xen_mmu_set_pgd: OK
[   79.195098] Testing event xen_mmu_pud_clear: OK
[   79.224248] Testing event xen_mmu_pgd_clear: OK
[   79.250818] Testing event xen_mmu_ptep_modify_prot_start: OK
[   79.277792] Testing event xen_mmu_ptep_modify_prot_commit: OK
[   79.307012] Testing event xen_mmu_alloc_ptpage: OK
[   79.341257] Testing event xen_mmu_release_ptpage: OK
[   79.374952] Testing event xen_mmu_pgd_pin: OK
[   79.401855] Testing event xen_mmu_pgd_unpin: OK
[   79.425232] Testing event xen_mmu_flush_tlb: OK
[   79.455153] Testing event xen_mmu_flush_tlb_single: OK
[   79.474268] Testing event xen_mmu_flush_tlb_others: OK
[   79.498173] Testing event xen_mmu_write_cr3: OK
[   79.518358] Testing event xen_cpu_write_ldt_entry: OK
[   79.558455] Testing event xen_cpu_write_idt_entry: OK
[   79.591435] Testing event xen_cpu_load_idt: OK
[   79.631044] Testing event xen_cpu_write_gdt_entry: OK
[   79.649895] Testing event xen_cpu_set_ldt: OK
[   79.675396] Testing event kvm_mmu_pagetable_walk: OK
[   79.695281] Testing event kvm_mmu_paging_element: OK
[   79.726663] Testing event kvm_mmu_set_accessed_bit: OK
[   79.747056] Testing event kvm_mmu_set_dirty_bit: OK
[   79.766448] Testing event kvm_mmu_walker_error: OK
[   79.786064] Testing event kvm_mmu_get_page: OK
[   79.809256] Testing event kvm_mmu_sync_page: OK
[   79.830498] Testing event kvm_mmu_unsync_page: OK
[   79.859166] Testing event kvm_mmu_prepare_zap_page: OK
[   79.881450] Testing event kvm_mmu_delay_free_pages: OK
[   79.910849] Testing event mark_mmio_spte: OK
[   79.930080] Testing event handle_mmio_page_fault: OK
[   79.950859] Testing event fast_page_fault: OK
[   79.971022] Testing event kvm_entry: OK
[   79.990160] Testing event kvm_hypercall: OK
[   80.010360] Testing event kvm_hv_hypercall: OK
[   80.030535] Testing event kvm_pio: OK
[   80.049606] Testing event kvm_cpuid: OK
[   80.066645] Testing event kvm_apic: OK
[   80.086639] Testing event kvm_exit: OK
[   80.106325] Testing event kvm_inj_virq: OK
[   80.126517] Testing event kvm_inj_exception: OK
[   80.146887] Testing event kvm_page_fault: OK
[   80.167015] Testing event kvm_msr: OK
[   80.186206] Testing event kvm_cr: OK
[   80.206215] Testing event kvm_pic_set_irq: OK
[   80.227056] Testing event kvm_apic_ipi: OK
[   80.246191] Testing event kvm_apic_accept_irq: OK
[   80.266356] Testing event kvm_eoi: OK
[   80.285661] Testing event kvm_pv_eoi: OK
[   80.302745] Testing event kvm_nested_vmrun: OK
[   80.323044] Testing event kvm_nested_intercepts: OK
[   80.341961] Testing event kvm_nested_vmexit: OK
[   80.365677] Testing event kvm_nested_vmexit_inject: OK
[   80.386210] Testing event kvm_nested_intr_vmexit: OK
[   80.409975] Testing event kvm_invlpga: OK
[   80.448265] Testing event kvm_skinit: OK
[   80.467037] Testing event kvm_emulate_insn: OK
[   80.507854] Testing event vcpu_match_mmio: OK
[   80.531297] Testing event kvm_userspace_exit: OK
[   80.575766] Testing event kvm_set_irq: OK
[   80.598764] Testing event kvm_ioapic_set_irq: OK
[   80.630437] Testing event kvm_msi_set_irq: OK
[   80.650300] Testing event kvm_ack_irq: OK
[   80.670319] Testing event kvm_mmio: OK
[   80.690828] Testing event kvm_fpu: OK
[   80.728286] Testing event kvm_age_page: OK
[   80.750463] Testing event kvm_try_async_get_page: OK
[   80.795612] Testing event kvm_async_pf_doublefault: OK
[   80.846176] Testing event kvm_async_pf_not_present: OK
[   80.871358] Testing event kvm_async_pf_ready: OK
[   80.891239] Testing event kvm_async_pf_completed: OK
[   80.922610] Running tests on trace event systems:
[   80.924196] Testing event system 9p: OK
[   80.950671] Testing event system mac80211: OK
[   81.063324] Testing event system sunrpc: OK
[   81.109540] Testing event system skb: OK
[   81.136719] Testing event system net: OK
[   81.170515] Testing event system napi: OK
[   81.238594] Testing event system sock: OK
[   81.277838] Testing event system udp: OK
[   81.300243] Testing event system hda: OK
[   81.349255] Testing event system ras: OK
[   81.370320] Testing event system scsi: OK
[   81.422128] Testing event system regmap: OK
[   81.450236] Testing event system i915: OK
[   81.485817] Testing event system radeon: OK
[   81.515552] Testing event system drm: OK
[   81.542789] Testing event system random: OK
[   81.563403] Testing event system regulator: OK
[   81.588086] Testing event system gpio: OK
[   81.605864] Testing event system block: OK
[   81.629238] Testing event system gfs2: OK
[   81.659036] Testing event system btrfs: OK
[   81.694757] Testing event system ocfs2: OK
[   81.977874] Testing event system xfs: OK
[   82.268474] Testing event system jbd2: OK
[   82.299512] Testing event system jbd: OK
[   82.331520] Testing event system ext4: OK
[   82.432797] Testing event system ext3: OK
[   82.501022] Testing event system writeback: OK
[   82.551482] Testing event system compaction: OK
[   82.576130] Testing event system kmem: OK
[   82.605802] Testing event system vmscan: OK
[   82.635904] Testing event system oom: OK
[   82.654165] Testing event system rpm: OK
[   82.675460] Testing event system power: OK
[   82.700395] Testing event system test: OK
[   82.717963] Testing event system module: OK
[   82.740578] Testing event system lock: OK
[   82.775417] Testing event system sched: OK
[   82.808570] Testing event system rcu: OK
[   82.841237] Testing event system workqueue: OK
[   82.877260] Testing event system signal: OK
[   82.911181] Testing event system timer: OK
[   82.946281] Testing event system irq: OK
[   82.967713] Testing event system printk: OK
[   82.985879] Testing event system task: OK
[   83.011115] Testing event system mce: OK
[   83.031187] Testing event system raw_syscalls: OK
[   83.051207] Testing event system vsyscall: OK
[   83.071283] Testing event system syscalls: OK
[   83.109765] Testing event system xen: OK
[   83.156699] Testing event system kvmmmu: OK
[   83.183336] Testing event system kvm: OK
[   83.233349] Running tests on all trace events:
[   83.234762] Testing all events: OK
[   84.608651] Testing ftrace filter: OK
[   84.611598] Testing kprobe tracing: OK
[   84.620474] kAFS: Red Hat AFS client v0.1 registering.
[   84.622210] FS-Cache: Netfs 'afs' registered for caching
[   84.626091] console [netcon0] enabled
[   84.627074] netconsole: network logging started
[   84.628456] rtc_cmos 00:01: setting system clock to 2012-09-03 16:21:50 UTC (1346689310)
[   84.630645] BIOS EDD facility v0.16 2004-Jun-25, 6 devices found
[   84.635032] IPv6: ADDRCONF(NETDEV_UP): bond0: link is not ready
[   84.636581] 8021q: adding VLAN 0 to HW filter on device bond0
[   84.640160] IP-Config: Failed to open ipddp0
[   84.652422] IPv6: ADDRCONF(NETDEV_UP): eth0: link is not ready
[   84.654915] 8021q: adding VLAN 0 to HW filter on device eth0
[   84.656657] IP-Config: Failed to open plip0
[   84.657766] ieee80211 phy0: mac80211_hwsim_start
[   84.658900] ieee80211 phy0: mac80211_hwsim_add_interface (type=2 mac_addr=02:00:00:00:00:00)
[   84.661220] ieee80211 phy0: mac80211_hwsim_bss_info_changed(changed=0xe)
[   84.662883] ieee80211 phy0:   ERP_CTS_PROT: 0
[   84.664210] ieee80211 phy0:   ERP_PREAMBLE: 0
[   84.665490] ieee80211 phy0:   ERP_SLOT: 0
[   84.666704] ieee80211 phy0: mac80211_hwsim_conf_tx (queue=0 txop=0 cw_min=31 cw_max=1023 aifs=2)
[   84.669070] ieee80211 phy0: mac80211_hwsim_conf_tx (queue=1 txop=0 cw_min=31 cw_max=1023 aifs=2)
[   84.671412] ieee80211 phy0: mac80211_hwsim_conf_tx (queue=2 txop=0 cw_min=31 cw_max=1023 aifs=2)
[   84.673875] ieee80211 phy0: mac80211_hwsim_conf_tx (queue=3 txop=0 cw_min=31 cw_max=1023 aifs=2)
[   84.676348] ieee80211 phy0: mac80211_hwsim_bss_info_changed(changed=0x2000)
[   84.678279] ieee80211 phy0: mac80211_hwsim_bss_info_changed(changed=0x4000)
[   84.679981] ieee80211 phy0: mac80211_hwsim_config (freq=2412/noht idle=1 ps=0 smps=static)
[   84.682360] ieee80211 phy0: mac80211_hwsim_configure_filter
[   84.683271] IPv6: ADDRCONF(NETDEV_UP): wlan0: link is not ready
[   84.683383] ieee80211 phy1: mac80211_hwsim_start
[   84.683391] ieee80211 phy1: mac80211_hwsim_add_interface (type=2 mac_addr=02:00:00:00:01:00)
[   84.683394] ieee80211 phy1: mac80211_hwsim_bss_info_changed(changed=0xe)
[   84.683395] ieee80211 phy1:   ERP_CTS_PROT: 0
[   84.683398] ieee80211 phy1:   ERP_PREAMBLE: 0
[   84.683399] ieee80211 phy1:   ERP_SLOT: 0
[   84.683421] ieee80211 phy1: mac80211_hwsim_conf_tx (queue=0 txop=0 cw_min=31 cw_max=1023 aifs=2)
[   84.683423] ieee80211 phy1: mac80211_hwsim_conf_tx (queue=1 txop=0 cw_min=31 cw_max=1023 aifs=2)
[   84.683431] ieee80211 phy1: mac80211_hwsim_conf_tx (queue=2 txop=0 cw_min=31 cw_max=1023 aifs=2)
[   84.683434] ieee80211 phy1: mac80211_hwsim_conf_tx (queue=3 txop=0 cw_min=31 cw_max=1023 aifs=2)
[   84.683436] ieee80211 phy1: mac80211_hwsim_bss_info_changed(changed=0x2000)
[   84.683440] ieee80211 phy1: mac80211_hwsim_bss_info_changed(changed=0x4000)
[   84.683443] ieee80211 phy1: mac80211_hwsim_config (freq=2412/noht idle=1 ps=0 smps=static)
[   84.683461] ieee80211 phy1: mac80211_hwsim_configure_filter
[   84.683594] ieee80211 phy1: mac80211_hwsim_configure_filter
[   84.683679] ieee80211 phy1: mac80211_hwsim_configure_filter
[   84.684401] IPv6: ADDRCONF(NETDEV_UP): wlan1: link is not ready
[   84.684442] ieee80211 phy1: mac80211_hwsim_configure_filter
[   84.684663] DHCP/BOOTP: Ignoring device hardwpan0, MTU 127 too small
[   84.684663] IP-Config: Failed to open irlan0
[   84.747116] ieee80211 phy0: mac80211_hwsim_configure_filter
[   86.652601] e1000: eth0 NIC Link is Up 1000 Mbps Full Duplex, Flow Control: RX
[   86.655466] IPv6: ADDRCONF(NETDEV_CHANGE): eth0: link becomes ready
[   87.700272] Sending DHCP requests .Unknown ARP type 0x0323 for device hwsim0
[   90.068253] ., OK
[   91.572883] IP-Config: Got DHCP answer from 10.0.2.2, my address is 10.0.2.15
[   91.579066] ieee80211 phy0: mac80211_hwsim_configure_filter
[   91.580907] ieee80211 phy0: mac80211_hwsim_configure_filter
[   91.600436] ieee80211 phy0: mac80211_hwsim_remove_interface (type=2 mac_addr=02:00:00:00:00:00)
[   91.603111] ieee80211 phy0: mac80211_hwsim_stop
[   91.605090] ieee80211 phy1: mac80211_hwsim_configure_filter
[   91.607583] ieee80211 phy1: mac80211_hwsim_configure_filter
[   91.609500] ieee80211 phy1: mac80211_hwsim_remove_interface (type=2 mac_addr=02:00:00:00:01:00)
[   91.611995] ieee80211 phy1: mac80211_hwsim_stop
[   91.615916] IP-Config: Complete:
[   91.617435]      device=eth0, addr=10.0.2.15, mask=255.255.255.0, gw=10.0.2.2
[   91.619357]      host=kvm, domain=, nis-domain=(none)
[   91.620906]      bootserver=10.0.2.2, rootserver=10.239.97.14, rootpath=
[   91.622865] ALSA device list:
[   91.624186]   #0: Dummy 1
[   91.625123]   #1: Virtual MIDI Card 1
[   91.626269]   #2: HDA Intel at 0xfebf0000 irq 52
[   91.628643] md: Waiting for all devices to be available before autodetect
[   91.630440] md: If you don't use raid, use raid=noautodetect
[   91.634951] md: Autodetecting RAID arrays.
[   91.636442] md: Scanned 0 and added 0 devices.
[   91.639085] md: autorun ...
[   91.639990] md: ... autorun DONE.
[   95.280337] VFS: Mounted root (nfs filesystem) on device 0:14.
[   95.281984] debug: unmapping init [mem 0xffffffff836c8000-0xffffffff83a4ffff]
[   95.285085] Write protecting the kernel read-only data: 36864k
[   95.287576] debug: unmapping init [mem 0xffff880002717000-0xffff8800027fffff]
[   95.289694] debug: unmapping init [mem 0xffff8800032c0000-0xffff8800033fffff]
[   95.660235] modprobe (2764) used greatest stack depth: 3112 bytes left
[   96.680791] S02mountkernfs. (2785) used greatest stack depth: 3024 bytes left
[   98.623776] ide-cd: hdc: DMA read error
[   98.625210] hdc: DMA disabled
[   99.440754] dsl-modem.agent (2970) used greatest stack depth: 2832 bytes left
[  107.871217] S36udev-mtab (3320) used greatest stack depth: 2672 bytes left
[  123.101531] NFSD: Using /var/lib/nfs/v4recovery as the NFSv4 state recovery directory
[  123.105607] NFSD: starting 90-second grace period
Kernel tests: Boot OK!
[  125.343216] Adding 307196k swap on /dev/vda.  Priority:-1 extents:1 across:307196k 
[  199.415520] warning: process `trinity-child1' used the deprecated sysctl system call with 
[  202.462672] trinity-child1 (3955): Using mlock ulimits for SHM_HUGETLB is deprecated
[  233.046014] kfree_debugcheck: out of range ptr ea6000000bb8h.
[  233.047399] ------------[ cut here ]------------
[  233.048393] kernel BUG at /c/kernel-tests/src/stable/mm/slab.c:3074!
[  233.048393] invalid opcode: 0000 [#1] SMP DEBUG_PAGEALLOC
[  233.048393] Modules linked in:
[  233.048393] CPU 0 
[  233.048393] Pid: 3929, comm: trinity-watchdo Not tainted 3.6.0-rc3+ #4192 Bochs Bochs
[  233.048393] RIP: 0010:[<ffffffff81169653>]  [<ffffffff81169653>] kfree_debugcheck+0x27/0x2d
[  233.048393] RSP: 0018:ffff88000facbca8  EFLAGS: 00010092
[  233.048393] RAX: 0000000000000031 RBX: 0000ea6000000bb8 RCX: 00000000a189a188
[  233.048393] RDX: 000000000000a189 RSI: ffffffff8108ad32 RDI: ffffffff810d30f9
[  233.048393] RBP: ffff88000facbcb8 R08: 0000000000000002 R09: ffffffff843846f0
[  233.048393] R10: ffffffff810ae37c R11: 0000000000000908 R12: 0000000000000202
[  233.048393] R13: ffffffff823dbd5a R14: ffff88000ec5bea8 R15: ffffffff8363c780
[  233.048393] FS:  00007faa6899c700(0000) GS:ffff88001f200000(0000) knlGS:0000000000000000
[  233.048393] CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
[  233.048393] CR2: 00007faa6841019c CR3: 0000000012c82000 CR4: 00000000000006f0
[  233.048393] DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
[  233.048393] DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
[  233.048393] Process trinity-watchdo (pid: 3929, threadinfo ffff88000faca000, task ffff88000faec600)
[  233.048393] Stack:
[  233.048393]  0000000000000000 0000ea6000000bb8 ffff88000facbce8 ffffffff8116ad81
[  233.048393]  ffff88000ff588a0 ffff88000ff58850 ffff88000ff588a0 0000000000000000
[  233.048393]  ffff88000facbd08 ffffffff823dbd5a ffffffff823dbcb0 ffff88000ff58850
[  233.048393] Call Trace:
[  233.048393]  [<ffffffff8116ad81>] kfree+0x5f/0xca
[  233.048393]  [<ffffffff823dbd5a>] inet_sock_destruct+0xaa/0x13c
[  233.048393]  [<ffffffff823dbcb0>] ? inet_sk_rebuild_header+0x319/0x319
[  233.048393]  [<ffffffff8231c307>] __sk_free+0x21/0x14b
[  233.048393]  [<ffffffff8231c4bd>] sk_free+0x26/0x2a
[  233.048393]  [<ffffffff825372db>] sctp_close+0x215/0x224
[  233.048393]  [<ffffffff810d6835>] ? lock_release+0x16f/0x1b9
[  233.048393]  [<ffffffff823daf12>] inet_release+0x7e/0x85
[  233.048393]  [<ffffffff82317d15>] sock_release+0x1f/0x77
[  233.048393]  [<ffffffff82317d94>] sock_close+0x27/0x2b
[  233.048393]  [<ffffffff81173bbe>] __fput+0x101/0x20a
[  233.048393]  [<ffffffff81173cd5>] ____fput+0xe/0x10
[  233.048393]  [<ffffffff810a3794>] task_work_run+0x5d/0x75
[  233.048393]  [<ffffffff8108da70>] do_exit+0x290/0x7f5
[  233.048393]  [<ffffffff82707415>] ? retint_swapgs+0x13/0x1b
[  233.048393]  [<ffffffff8108e23f>] do_group_exit+0x7b/0xba
[  233.048393]  [<ffffffff8108e295>] sys_exit_group+0x17/0x17
[  233.048393]  [<ffffffff8270de10>] tracesys+0xdd/0xe2
[  233.048393] Code: 59 01 5d c3 55 48 89 e5 53 41 50 0f 1f 44 00 00 48 89 fb e8 d4 b0 f0 ff 84 c0 75 11 48 89 de 48 c7 c7 fc fa f7 82 e8 0d 0f 57 01 <0f> 0b 5f 5b 5d c3 55 48 89 e5 0f 1f 44 00 00 48 63 87 d8 00 00 
[  233.048393] RIP  [<ffffffff81169653>] kfree_debugcheck+0x27/0x2d
[  233.048393]  RSP <ffff88000facbca8>
[  233.048393] ---[ end trace ebc9a98b6ec14357 ]---
[  233.048393] Fixing recursive fault but reboot is needed!

--r5Pyd7+fXNt84Ff3
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename="config-3.6.0-rc3+"

#
# Automatically generated file; DO NOT EDIT.
# Linux/x86_64 3.6.0-rc3 Kernel Configuration
#
CONFIG_64BIT=y
# CONFIG_X86_32 is not set
CONFIG_X86_64=y
CONFIG_X86=y
CONFIG_INSTRUCTION_DECODER=y
CONFIG_OUTPUT_FORMAT="elf64-x86-64"
CONFIG_ARCH_DEFCONFIG="arch/x86/configs/x86_64_defconfig"
CONFIG_LOCKDEP_SUPPORT=y
CONFIG_STACKTRACE_SUPPORT=y
CONFIG_HAVE_LATENCYTOP_SUPPORT=y
CONFIG_MMU=y
CONFIG_NEED_DMA_MAP_STATE=y
CONFIG_NEED_SG_DMA_LENGTH=y
CONFIG_GENERIC_ISA_DMA=y
CONFIG_GENERIC_BUG=y
CONFIG_GENERIC_BUG_RELATIVE_POINTERS=y
CONFIG_GENERIC_HWEIGHT=y
CONFIG_GENERIC_GPIO=y
CONFIG_ARCH_MAY_HAVE_PC_FDC=y
# CONFIG_RWSEM_GENERIC_SPINLOCK is not set
CONFIG_RWSEM_XCHGADD_ALGORITHM=y
CONFIG_GENERIC_CALIBRATE_DELAY=y
CONFIG_ARCH_HAS_CPU_RELAX=y
CONFIG_ARCH_HAS_DEFAULT_IDLE=y
CONFIG_ARCH_HAS_CACHE_LINE_SIZE=y
CONFIG_ARCH_HAS_CPU_AUTOPROBE=y
CONFIG_HAVE_SETUP_PER_CPU_AREA=y
CONFIG_NEED_PER_CPU_EMBED_FIRST_CHUNK=y
CONFIG_NEED_PER_CPU_PAGE_FIRST_CHUNK=y
CONFIG_ARCH_HIBERNATION_POSSIBLE=y
CONFIG_ARCH_SUSPEND_POSSIBLE=y
CONFIG_ZONE_DMA32=y
CONFIG_AUDIT_ARCH=y
CONFIG_ARCH_SUPPORTS_OPTIMIZED_INLINING=y
CONFIG_ARCH_SUPPORTS_DEBUG_PAGEALLOC=y
CONFIG_X86_64_SMP=y
CONFIG_X86_HT=y
CONFIG_ARCH_HWEIGHT_CFLAGS="-fcall-saved-rdi -fcall-saved-rsi -fcall-saved-rdx -fcall-saved-rcx -fcall-saved-r8 -fcall-saved-r9 -fcall-saved-r10 -fcall-saved-r11"
CONFIG_ARCH_CPU_PROBE_RELEASE=y
CONFIG_ARCH_SUPPORTS_UPROBES=y
CONFIG_DEFCONFIG_LIST="/lib/modules/$UNAME_RELEASE/.config"
CONFIG_HAVE_IRQ_WORK=y
CONFIG_IRQ_WORK=y
CONFIG_BUILDTIME_EXTABLE_SORT=y

#
# General setup
#
CONFIG_EXPERIMENTAL=y
CONFIG_INIT_ENV_ARG_LIMIT=32
CONFIG_CROSS_COMPILE=""
CONFIG_LOCALVERSION=""
# CONFIG_LOCALVERSION_AUTO is not set
CONFIG_HAVE_KERNEL_GZIP=y
CONFIG_HAVE_KERNEL_BZIP2=y
CONFIG_HAVE_KERNEL_LZMA=y
CONFIG_HAVE_KERNEL_XZ=y
CONFIG_HAVE_KERNEL_LZO=y
CONFIG_KERNEL_GZIP=y
# CONFIG_KERNEL_BZIP2 is not set
# CONFIG_KERNEL_LZMA is not set
# CONFIG_KERNEL_XZ is not set
# CONFIG_KERNEL_LZO is not set
CONFIG_DEFAULT_HOSTNAME="(none)"
CONFIG_SWAP=y
CONFIG_SYSVIPC=y
CONFIG_SYSVIPC_SYSCTL=y
CONFIG_POSIX_MQUEUE=y
CONFIG_POSIX_MQUEUE_SYSCTL=y
CONFIG_BSD_PROCESS_ACCT=y
CONFIG_BSD_PROCESS_ACCT_V3=y
# CONFIG_FHANDLE is not set
CONFIG_TASKSTATS=y
CONFIG_TASK_DELAY_ACCT=y
CONFIG_TASK_XACCT=y
CONFIG_TASK_IO_ACCOUNTING=y
CONFIG_AUDIT=y
CONFIG_AUDITSYSCALL=y
CONFIG_AUDIT_WATCH=y
CONFIG_AUDIT_TREE=y
# CONFIG_AUDIT_LOGINUID_IMMUTABLE is not set
CONFIG_HAVE_GENERIC_HARDIRQS=y

#
# IRQ subsystem
#
CONFIG_GENERIC_HARDIRQS=y
CONFIG_GENERIC_IRQ_PROBE=y
CONFIG_GENERIC_IRQ_SHOW=y
CONFIG_GENERIC_PENDING_IRQ=y
CONFIG_IRQ_DOMAIN=y
# CONFIG_IRQ_DOMAIN_DEBUG is not set
CONFIG_IRQ_FORCED_THREADING=y
CONFIG_SPARSE_IRQ=y
CONFIG_CLOCKSOURCE_WATCHDOG=y
CONFIG_ARCH_CLOCKSOURCE_DATA=y
CONFIG_GENERIC_TIME_VSYSCALL=y
CONFIG_GENERIC_CLOCKEVENTS=y
CONFIG_GENERIC_CLOCKEVENTS_BUILD=y
CONFIG_GENERIC_CLOCKEVENTS_BROADCAST=y
CONFIG_GENERIC_CLOCKEVENTS_MIN_ADJUST=y
CONFIG_GENERIC_CMOS_UPDATE=y

#
# Timers subsystem
#
CONFIG_TICK_ONESHOT=y
CONFIG_NO_HZ=y
CONFIG_HIGH_RES_TIMERS=y

#
# RCU Subsystem
#
CONFIG_TREE_RCU=y
# CONFIG_PREEMPT_RCU is not set
CONFIG_RCU_FANOUT=64
CONFIG_RCU_FANOUT_LEAF=16
# CONFIG_RCU_FANOUT_EXACT is not set
CONFIG_RCU_FAST_NO_HZ=y
CONFIG_TREE_RCU_TRACE=y
# CONFIG_IKCONFIG is not set
CONFIG_LOG_BUF_SHIFT=17
CONFIG_HAVE_UNSTABLE_SCHED_CLOCK=y
CONFIG_CGROUPS=y
# CONFIG_CGROUP_DEBUG is not set
CONFIG_CGROUP_FREEZER=y
CONFIG_CGROUP_DEVICE=y
CONFIG_CPUSETS=y
CONFIG_PROC_PID_CPUSET=y
CONFIG_CGROUP_CPUACCT=y
CONFIG_RESOURCE_COUNTERS=y
# CONFIG_MEMCG is not set
# CONFIG_CGROUP_HUGETLB is not set
# CONFIG_CGROUP_PERF is not set
CONFIG_CGROUP_SCHED=y
CONFIG_FAIR_GROUP_SCHED=y
# CONFIG_CFS_BANDWIDTH is not set
# CONFIG_RT_GROUP_SCHED is not set
CONFIG_BLK_CGROUP=y
# CONFIG_DEBUG_BLK_CGROUP is not set
# CONFIG_CHECKPOINT_RESTORE is not set
CONFIG_NAMESPACES=y
CONFIG_UTS_NS=y
CONFIG_IPC_NS=y
CONFIG_PID_NS=y
CONFIG_NET_NS=y
# CONFIG_SCHED_AUTOGROUP is not set
# CONFIG_SYSFS_DEPRECATED is not set
CONFIG_RELAY=y
CONFIG_BLK_DEV_INITRD=y
CONFIG_INITRAMFS_SOURCE=""
CONFIG_RD_GZIP=y
CONFIG_RD_BZIP2=y
CONFIG_RD_LZMA=y
CONFIG_RD_XZ=y
CONFIG_RD_LZO=y
CONFIG_CC_OPTIMIZE_FOR_SIZE=y
CONFIG_SYSCTL=y
CONFIG_ANON_INODES=y
# CONFIG_EXPERT is not set
CONFIG_UID16=y
# CONFIG_SYSCTL_SYSCALL is not set
CONFIG_KALLSYMS=y
CONFIG_KALLSYMS_ALL=y
CONFIG_HOTPLUG=y
CONFIG_PRINTK=y
CONFIG_BUG=y
CONFIG_ELF_CORE=y
CONFIG_PCSPKR_PLATFORM=y
CONFIG_HAVE_PCSPKR_PLATFORM=y
CONFIG_BASE_FULL=y
CONFIG_FUTEX=y
CONFIG_EPOLL=y
CONFIG_SIGNALFD=y
CONFIG_TIMERFD=y
CONFIG_EVENTFD=y
CONFIG_SHMEM=y
CONFIG_AIO=y
# CONFIG_EMBEDDED is not set
CONFIG_HAVE_PERF_EVENTS=y

#
# Kernel Performance Events And Counters
#
CONFIG_PERF_EVENTS=y
# CONFIG_DEBUG_PERF_USE_VMALLOC is not set
CONFIG_VM_EVENT_COUNTERS=y
CONFIG_PCI_QUIRKS=y
# CONFIG_COMPAT_BRK is not set
CONFIG_SLAB=y
# CONFIG_SLUB is not set
CONFIG_PROFILING=y
CONFIG_TRACEPOINTS=y
CONFIG_OPROFILE=y
# CONFIG_OPROFILE_EVENT_MULTIPLEX is not set
CONFIG_HAVE_OPROFILE=y
CONFIG_OPROFILE_NMI_TIMER=y
CONFIG_KPROBES=y
# CONFIG_JUMP_LABEL is not set
CONFIG_OPTPROBES=y
CONFIG_HAVE_EFFICIENT_UNALIGNED_ACCESS=y
CONFIG_KRETPROBES=y
CONFIG_USER_RETURN_NOTIFIER=y
CONFIG_HAVE_IOREMAP_PROT=y
CONFIG_HAVE_KPROBES=y
CONFIG_HAVE_KRETPROBES=y
CONFIG_HAVE_OPTPROBES=y
CONFIG_HAVE_ARCH_TRACEHOOK=y
CONFIG_HAVE_DMA_ATTRS=y
CONFIG_USE_GENERIC_SMP_HELPERS=y
CONFIG_GENERIC_SMP_IDLE_THREAD=y
CONFIG_HAVE_REGS_AND_STACK_ACCESS_API=y
CONFIG_HAVE_DMA_API_DEBUG=y
CONFIG_HAVE_HW_BREAKPOINT=y
CONFIG_HAVE_MIXED_BREAKPOINTS_REGS=y
CONFIG_HAVE_USER_RETURN_NOTIFIER=y
CONFIG_HAVE_PERF_EVENTS_NMI=y
CONFIG_HAVE_ARCH_JUMP_LABEL=y
CONFIG_ARCH_HAVE_NMI_SAFE_CMPXCHG=y
CONFIG_HAVE_CMPXCHG_LOCAL=y
CONFIG_HAVE_CMPXCHG_DOUBLE=y
CONFIG_ARCH_WANT_COMPAT_IPC_PARSE_VERSION=y
CONFIG_ARCH_WANT_OLD_COMPAT_IPC=y
CONFIG_HAVE_ARCH_SECCOMP_FILTER=y
CONFIG_SECCOMP_FILTER=y

#
# GCOV-based kernel profiling
#
# CONFIG_GCOV_KERNEL is not set
# CONFIG_HAVE_GENERIC_DMA_COHERENT is not set
CONFIG_SLABINFO=y
CONFIG_RT_MUTEXES=y
CONFIG_BASE_SMALL=0
CONFIG_MODULES=y
CONFIG_MODULE_FORCE_LOAD=y
CONFIG_MODULE_UNLOAD=y
CONFIG_MODULE_FORCE_UNLOAD=y
CONFIG_MODVERSIONS=y
# CONFIG_MODULE_SRCVERSION_ALL is not set
CONFIG_STOP_MACHINE=y
CONFIG_BLOCK=y
CONFIG_BLK_DEV_BSG=y
CONFIG_BLK_DEV_BSGLIB=y
CONFIG_BLK_DEV_INTEGRITY=y
# CONFIG_BLK_DEV_THROTTLING is not set

#
# Partition Types
#
CONFIG_PARTITION_ADVANCED=y
CONFIG_ACORN_PARTITION=y
# CONFIG_ACORN_PARTITION_CUMANA is not set
# CONFIG_ACORN_PARTITION_EESOX is not set
CONFIG_ACORN_PARTITION_ICS=y
# CONFIG_ACORN_PARTITION_ADFS is not set
# CONFIG_ACORN_PARTITION_POWERTEC is not set
CONFIG_ACORN_PARTITION_RISCIX=y
CONFIG_OSF_PARTITION=y
CONFIG_AMIGA_PARTITION=y
CONFIG_ATARI_PARTITION=y
CONFIG_MAC_PARTITION=y
CONFIG_MSDOS_PARTITION=y
CONFIG_BSD_DISKLABEL=y
CONFIG_MINIX_SUBPARTITION=y
CONFIG_SOLARIS_X86_PARTITION=y
CONFIG_UNIXWARE_DISKLABEL=y
CONFIG_LDM_PARTITION=y
# CONFIG_LDM_DEBUG is not set
CONFIG_SGI_PARTITION=y
CONFIG_ULTRIX_PARTITION=y
CONFIG_SUN_PARTITION=y
CONFIG_KARMA_PARTITION=y
CONFIG_EFI_PARTITION=y
# CONFIG_SYSV68_PARTITION is not set
CONFIG_BLOCK_COMPAT=y

#
# IO Schedulers
#
CONFIG_IOSCHED_NOOP=y
CONFIG_IOSCHED_DEADLINE=y
CONFIG_IOSCHED_CFQ=y
CONFIG_CFQ_GROUP_IOSCHED=y
# CONFIG_DEFAULT_DEADLINE is not set
CONFIG_DEFAULT_CFQ=y
# CONFIG_DEFAULT_NOOP is not set
CONFIG_DEFAULT_IOSCHED="cfq"
CONFIG_PREEMPT_NOTIFIERS=y
CONFIG_PADATA=y
# CONFIG_INLINE_SPIN_TRYLOCK is not set
# CONFIG_INLINE_SPIN_TRYLOCK_BH is not set
# CONFIG_INLINE_SPIN_LOCK is not set
# CONFIG_INLINE_SPIN_LOCK_BH is not set
# CONFIG_INLINE_SPIN_LOCK_IRQ is not set
# CONFIG_INLINE_SPIN_LOCK_IRQSAVE is not set
CONFIG_UNINLINE_SPIN_UNLOCK=y
# CONFIG_INLINE_SPIN_UNLOCK_BH is not set
# CONFIG_INLINE_SPIN_UNLOCK_IRQ is not set
# CONFIG_INLINE_SPIN_UNLOCK_IRQRESTORE is not set
# CONFIG_INLINE_READ_TRYLOCK is not set
# CONFIG_INLINE_READ_LOCK is not set
# CONFIG_INLINE_READ_LOCK_BH is not set
# CONFIG_INLINE_READ_LOCK_IRQ is not set
# CONFIG_INLINE_READ_LOCK_IRQSAVE is not set
# CONFIG_INLINE_READ_UNLOCK is not set
# CONFIG_INLINE_READ_UNLOCK_BH is not set
# CONFIG_INLINE_READ_UNLOCK_IRQ is not set
# CONFIG_INLINE_READ_UNLOCK_IRQRESTORE is not set
# CONFIG_INLINE_WRITE_TRYLOCK is not set
# CONFIG_INLINE_WRITE_LOCK is not set
# CONFIG_INLINE_WRITE_LOCK_BH is not set
# CONFIG_INLINE_WRITE_LOCK_IRQ is not set
# CONFIG_INLINE_WRITE_LOCK_IRQSAVE is not set
# CONFIG_INLINE_WRITE_UNLOCK is not set
# CONFIG_INLINE_WRITE_UNLOCK_BH is not set
# CONFIG_INLINE_WRITE_UNLOCK_IRQ is not set
# CONFIG_INLINE_WRITE_UNLOCK_IRQRESTORE is not set
# CONFIG_MUTEX_SPIN_ON_OWNER is not set
CONFIG_FREEZER=y

#
# Processor type and features
#
CONFIG_ZONE_DMA=y
CONFIG_SMP=y
CONFIG_X86_MPPARSE=y
# CONFIG_X86_EXTENDED_PLATFORM is not set
CONFIG_X86_SUPPORTS_MEMORY_FAILURE=y
CONFIG_SCHED_OMIT_FRAME_POINTER=y
CONFIG_PARAVIRT_GUEST=y
# CONFIG_PARAVIRT_TIME_ACCOUNTING is not set
CONFIG_XEN=y
CONFIG_XEN_DOM0=y
CONFIG_XEN_PRIVILEGED_GUEST=y
CONFIG_XEN_PVHVM=y
CONFIG_XEN_MAX_DOMAIN_MEMORY=500
CONFIG_XEN_SAVE_RESTORE=y
# CONFIG_XEN_DEBUG_FS is not set
# CONFIG_KVM_CLOCK is not set
CONFIG_KVM_GUEST=y
CONFIG_PARAVIRT=y
# CONFIG_PARAVIRT_SPINLOCKS is not set
CONFIG_PARAVIRT_CLOCK=y
# CONFIG_PARAVIRT_DEBUG is not set
CONFIG_NO_BOOTMEM=y
CONFIG_MEMTEST=y
# CONFIG_MK8 is not set
# CONFIG_MPSC is not set
# CONFIG_MCORE2 is not set
# CONFIG_MATOM is not set
CONFIG_GENERIC_CPU=y
CONFIG_X86_INTERNODE_CACHE_SHIFT=6
CONFIG_X86_CMPXCHG=y
CONFIG_X86_L1_CACHE_SHIFT=6
CONFIG_X86_XADD=y
CONFIG_X86_WP_WORKS_OK=y
CONFIG_X86_TSC=y
CONFIG_X86_CMPXCHG64=y
CONFIG_X86_CMOV=y
CONFIG_X86_MINIMUM_CPU_FAMILY=64
CONFIG_X86_DEBUGCTLMSR=y
CONFIG_CPU_SUP_INTEL=y
CONFIG_CPU_SUP_AMD=y
CONFIG_CPU_SUP_CENTAUR=y
CONFIG_HPET_TIMER=y
CONFIG_HPET_EMULATE_RTC=y
CONFIG_DMI=y
CONFIG_GART_IOMMU=y
CONFIG_CALGARY_IOMMU=y
CONFIG_CALGARY_IOMMU_ENABLED_BY_DEFAULT=y
CONFIG_SWIOTLB=y
CONFIG_IOMMU_HELPER=y
# CONFIG_MAXSMP is not set
CONFIG_NR_CPUS=512
CONFIG_SCHED_SMT=y
CONFIG_SCHED_MC=y
# CONFIG_IRQ_TIME_ACCOUNTING is not set
# CONFIG_PREEMPT_NONE is not set
CONFIG_PREEMPT_VOLUNTARY=y
# CONFIG_PREEMPT is not set
CONFIG_X86_LOCAL_APIC=y
CONFIG_X86_IO_APIC=y
CONFIG_X86_REROUTE_FOR_BROKEN_BOOT_IRQS=y
CONFIG_X86_MCE=y
CONFIG_X86_MCE_INTEL=y
CONFIG_X86_MCE_AMD=y
CONFIG_X86_MCE_THRESHOLD=y
CONFIG_X86_MCE_INJECT=y
CONFIG_X86_THERMAL_VECTOR=y
CONFIG_I8K=y
CONFIG_MICROCODE=y
CONFIG_MICROCODE_INTEL=y
CONFIG_MICROCODE_AMD=y
CONFIG_MICROCODE_OLD_INTERFACE=y
CONFIG_X86_MSR=y
CONFIG_X86_CPUID=y
CONFIG_ARCH_PHYS_ADDR_T_64BIT=y
CONFIG_ARCH_DMA_ADDR_T_64BIT=y
CONFIG_DIRECT_GBPAGES=y
CONFIG_NUMA=y
CONFIG_AMD_NUMA=y
CONFIG_X86_64_ACPI_NUMA=y
CONFIG_NODES_SPAN_OTHER_NODES=y
CONFIG_NUMA_EMU=y
CONFIG_NODES_SHIFT=6
CONFIG_ARCH_SPARSEMEM_ENABLE=y
CONFIG_ARCH_SPARSEMEM_DEFAULT=y
CONFIG_ARCH_SELECT_MEMORY_MODEL=y
CONFIG_ARCH_MEMORY_PROBE=y
CONFIG_ARCH_PROC_KCORE_TEXT=y
CONFIG_ILLEGAL_POINTER_VALUE=0xdead000000000000
CONFIG_SELECT_MEMORY_MODEL=y
CONFIG_SPARSEMEM_MANUAL=y
CONFIG_SPARSEMEM=y
CONFIG_NEED_MULTIPLE_NODES=y
CONFIG_HAVE_MEMORY_PRESENT=y
CONFIG_SPARSEMEM_EXTREME=y
CONFIG_SPARSEMEM_VMEMMAP_ENABLE=y
CONFIG_SPARSEMEM_ALLOC_MEM_MAP_TOGETHER=y
CONFIG_SPARSEMEM_VMEMMAP=y
CONFIG_HAVE_MEMBLOCK=y
CONFIG_HAVE_MEMBLOCK_NODE_MAP=y
CONFIG_ARCH_DISCARD_MEMBLOCK=y
CONFIG_MEMORY_ISOLATION=y
CONFIG_MEMORY_HOTPLUG=y
CONFIG_MEMORY_HOTPLUG_SPARSE=y
CONFIG_MEMORY_HOTREMOVE=y
CONFIG_PAGEFLAGS_EXTENDED=y
CONFIG_SPLIT_PTLOCK_CPUS=999999
CONFIG_COMPACTION=y
CONFIG_MIGRATION=y
CONFIG_PHYS_ADDR_T_64BIT=y
CONFIG_ZONE_DMA_FLAG=1
CONFIG_BOUNCE=y
CONFIG_VIRT_TO_BUS=y
CONFIG_MMU_NOTIFIER=y
CONFIG_KSM=y
CONFIG_DEFAULT_MMAP_MIN_ADDR=65536
CONFIG_ARCH_SUPPORTS_MEMORY_FAILURE=y
CONFIG_MEMORY_FAILURE=y
CONFIG_HWPOISON_INJECT=y
# CONFIG_TRANSPARENT_HUGEPAGE is not set
CONFIG_CROSS_MEMORY_ATTACH=y
# CONFIG_CLEANCACHE is not set
# CONFIG_FRONTSWAP is not set
# CONFIG_X86_CHECK_BIOS_CORRUPTION is not set
CONFIG_X86_RESERVE_LOW=64
CONFIG_MTRR=y
CONFIG_MTRR_SANITIZER=y
CONFIG_MTRR_SANITIZER_ENABLE_DEFAULT=0
CONFIG_MTRR_SANITIZER_SPARE_REG_NR_DEFAULT=1
CONFIG_X86_PAT=y
CONFIG_ARCH_USES_PG_UNCACHED=y
CONFIG_ARCH_RANDOM=y
CONFIG_EFI=y
# CONFIG_EFI_STUB is not set
CONFIG_SECCOMP=y
CONFIG_CC_STACKPROTECTOR=y
# CONFIG_HZ_100 is not set
CONFIG_HZ_250=y
# CONFIG_HZ_300 is not set
# CONFIG_HZ_1000 is not set
CONFIG_HZ=250
CONFIG_SCHED_HRTICK=y
CONFIG_KEXEC=y
# CONFIG_CRASH_DUMP is not set
# CONFIG_KEXEC_JUMP is not set
CONFIG_PHYSICAL_START=0x1000000
CONFIG_RELOCATABLE=y
CONFIG_PHYSICAL_ALIGN=0x1000000
CONFIG_HOTPLUG_CPU=y
# CONFIG_COMPAT_VDSO is not set
# CONFIG_CMDLINE_BOOL is not set
CONFIG_ARCH_ENABLE_MEMORY_HOTPLUG=y
CONFIG_ARCH_ENABLE_MEMORY_HOTREMOVE=y
CONFIG_USE_PERCPU_NUMA_NODE_ID=y

#
# Power management and ACPI options
#
CONFIG_ARCH_HIBERNATION_HEADER=y
CONFIG_SUSPEND=y
CONFIG_SUSPEND_FREEZER=y
CONFIG_HIBERNATE_CALLBACKS=y
CONFIG_HIBERNATION=y
CONFIG_PM_STD_PARTITION=""
CONFIG_PM_SLEEP=y
CONFIG_PM_SLEEP_SMP=y
# CONFIG_PM_AUTOSLEEP is not set
# CONFIG_PM_WAKELOCKS is not set
CONFIG_PM_RUNTIME=y
CONFIG_PM=y
CONFIG_PM_DEBUG=y
CONFIG_PM_ADVANCED_DEBUG=y
CONFIG_PM_TEST_SUSPEND=y
CONFIG_PM_SLEEP_DEBUG=y
# CONFIG_PM_TRACE_RTC is not set
CONFIG_ACPI=y
CONFIG_ACPI_SLEEP=y
# CONFIG_ACPI_PROCFS is not set
# CONFIG_ACPI_PROCFS_POWER is not set
# CONFIG_ACPI_EC_DEBUGFS is not set
# CONFIG_ACPI_PROC_EVENT is not set
CONFIG_ACPI_AC=y
CONFIG_ACPI_BATTERY=y
CONFIG_ACPI_BUTTON=y
CONFIG_ACPI_VIDEO=y
CONFIG_ACPI_FAN=y
CONFIG_ACPI_DOCK=y
CONFIG_ACPI_PROCESSOR=y
# CONFIG_ACPI_IPMI is not set
CONFIG_ACPI_HOTPLUG_CPU=y
CONFIG_ACPI_PROCESSOR_AGGREGATOR=y
CONFIG_ACPI_THERMAL=y
CONFIG_ACPI_NUMA=y
# CONFIG_ACPI_CUSTOM_DSDT is not set
CONFIG_ACPI_BLACKLIST_YEAR=0
# CONFIG_ACPI_DEBUG is not set
CONFIG_ACPI_PCI_SLOT=y
CONFIG_X86_PM_TIMER=y
CONFIG_ACPI_CONTAINER=y
CONFIG_ACPI_HOTPLUG_MEMORY=y
CONFIG_ACPI_SBS=y
CONFIG_ACPI_HED=y
# CONFIG_ACPI_CUSTOM_METHOD is not set
# CONFIG_ACPI_BGRT is not set
CONFIG_ACPI_APEI=y
CONFIG_ACPI_APEI_GHES=y
# CONFIG_ACPI_APEI_PCIEAER is not set
# CONFIG_ACPI_APEI_MEMORY_FAILURE is not set
# CONFIG_ACPI_APEI_EINJ is not set
# CONFIG_ACPI_APEI_ERST_DEBUG is not set
CONFIG_SFI=y

#
# CPU Frequency scaling
#
CONFIG_CPU_FREQ=y
CONFIG_CPU_FREQ_TABLE=y
CONFIG_CPU_FREQ_STAT=y
# CONFIG_CPU_FREQ_STAT_DETAILS is not set
# CONFIG_CPU_FREQ_DEFAULT_GOV_PERFORMANCE is not set
# CONFIG_CPU_FREQ_DEFAULT_GOV_USERSPACE is not set
CONFIG_CPU_FREQ_DEFAULT_GOV_ONDEMAND=y
# CONFIG_CPU_FREQ_DEFAULT_GOV_CONSERVATIVE is not set
CONFIG_CPU_FREQ_GOV_PERFORMANCE=y
CONFIG_CPU_FREQ_GOV_POWERSAVE=y
CONFIG_CPU_FREQ_GOV_USERSPACE=y
CONFIG_CPU_FREQ_GOV_ONDEMAND=y
CONFIG_CPU_FREQ_GOV_CONSERVATIVE=y

#
# x86 CPU frequency scaling drivers
#
CONFIG_X86_PCC_CPUFREQ=y
CONFIG_X86_ACPI_CPUFREQ=y
CONFIG_X86_POWERNOW_K8=y
CONFIG_X86_SPEEDSTEP_CENTRINO=y
CONFIG_X86_P4_CLOCKMOD=y

#
# shared options
#
CONFIG_X86_SPEEDSTEP_LIB=y
CONFIG_CPU_IDLE=y
CONFIG_CPU_IDLE_GOV_LADDER=y
CONFIG_CPU_IDLE_GOV_MENU=y
# CONFIG_ARCH_NEEDS_CPU_IDLE_COUPLED is not set
CONFIG_INTEL_IDLE=y

#
# Memory power savings
#
CONFIG_I7300_IDLE_IOAT_CHANNEL=y
CONFIG_I7300_IDLE=y

#
# Bus options (PCI etc.)
#
CONFIG_PCI=y
CONFIG_PCI_DIRECT=y
CONFIG_PCI_MMCONFIG=y
CONFIG_PCI_XEN=y
CONFIG_PCI_DOMAINS=y
# CONFIG_PCI_CNB20LE_QUIRK is not set
CONFIG_PCIEPORTBUS=y
CONFIG_HOTPLUG_PCI_PCIE=y
CONFIG_PCIEAER=y
# CONFIG_PCIE_ECRC is not set
CONFIG_PCIEAER_INJECT=y
CONFIG_PCIEASPM=y
CONFIG_PCIEASPM_DEBUG=y
CONFIG_PCIEASPM_DEFAULT=y
# CONFIG_PCIEASPM_POWERSAVE is not set
# CONFIG_PCIEASPM_PERFORMANCE is not set
CONFIG_PCIE_PME=y
CONFIG_ARCH_SUPPORTS_MSI=y
CONFIG_PCI_MSI=y
# CONFIG_PCI_DEBUG is not set
# CONFIG_PCI_REALLOC_ENABLE_AUTO is not set
CONFIG_PCI_STUB=y
CONFIG_XEN_PCIDEV_FRONTEND=y
CONFIG_HT_IRQ=y
CONFIG_PCI_ATS=y
CONFIG_PCI_IOV=y
CONFIG_PCI_PRI=y
CONFIG_PCI_PASID=y
CONFIG_PCI_IOAPIC=y
CONFIG_PCI_LABEL=y
CONFIG_ISA_DMA_API=y
CONFIG_AMD_NB=y
CONFIG_PCCARD=y
CONFIG_PCMCIA=y
CONFIG_PCMCIA_LOAD_CIS=y
CONFIG_CARDBUS=y

#
# PC-card bridges
#
CONFIG_YENTA=y
CONFIG_YENTA_O2=y
CONFIG_YENTA_RICOH=y
CONFIG_YENTA_TI=y
CONFIG_YENTA_ENE_TUNE=y
CONFIG_YENTA_TOSHIBA=y
CONFIG_PD6729=y
CONFIG_I82092=y
CONFIG_PCCARD_NONSTATIC=y
CONFIG_HOTPLUG_PCI=y
CONFIG_HOTPLUG_PCI_FAKE=y
CONFIG_HOTPLUG_PCI_ACPI=y
CONFIG_HOTPLUG_PCI_ACPI_IBM=y
CONFIG_HOTPLUG_PCI_CPCI=y
CONFIG_HOTPLUG_PCI_CPCI_ZT5550=y
CONFIG_HOTPLUG_PCI_CPCI_GENERIC=y
CONFIG_HOTPLUG_PCI_SHPC=y
# CONFIG_RAPIDIO is not set

#
# Executable file formats / Emulations
#
CONFIG_BINFMT_ELF=y
CONFIG_COMPAT_BINFMT_ELF=y
CONFIG_ARCH_BINFMT_ELF_RANDOMIZE_PIE=y
CONFIG_CORE_DUMP_DEFAULT_ELF_HEADERS=y
# CONFIG_HAVE_AOUT is not set
CONFIG_BINFMT_MISC=y
CONFIG_IA32_EMULATION=y
CONFIG_IA32_AOUT=y
# CONFIG_X86_X32 is not set
CONFIG_COMPAT=y
CONFIG_COMPAT_FOR_U64_ALIGNMENT=y
CONFIG_SYSVIPC_COMPAT=y
CONFIG_KEYS_COMPAT=y
CONFIG_HAVE_TEXT_POKE_SMP=y
CONFIG_X86_DEV_DMA_OPS=y
CONFIG_NET=y
CONFIG_COMPAT_NETLINK_MESSAGES=y

#
# Networking options
#
CONFIG_PACKET=y
# CONFIG_PACKET_DIAG is not set
CONFIG_UNIX=y
# CONFIG_UNIX_DIAG is not set
CONFIG_XFRM=y
CONFIG_XFRM_ALGO=y
CONFIG_XFRM_USER=y
CONFIG_XFRM_SUB_POLICY=y
CONFIG_XFRM_MIGRATE=y
# CONFIG_XFRM_STATISTICS is not set
CONFIG_XFRM_IPCOMP=y
CONFIG_NET_KEY=y
CONFIG_NET_KEY_MIGRATE=y
CONFIG_INET=y
CONFIG_IP_MULTICAST=y
CONFIG_IP_ADVANCED_ROUTER=y
# CONFIG_IP_FIB_TRIE_STATS is not set
CONFIG_IP_MULTIPLE_TABLES=y
CONFIG_IP_ROUTE_MULTIPATH=y
CONFIG_IP_ROUTE_VERBOSE=y
CONFIG_IP_ROUTE_CLASSID=y
CONFIG_IP_PNP=y
CONFIG_IP_PNP_DHCP=y
CONFIG_IP_PNP_BOOTP=y
CONFIG_IP_PNP_RARP=y
CONFIG_NET_IPIP=y
# CONFIG_NET_IPGRE_DEMUX is not set
CONFIG_IP_MROUTE=y
CONFIG_IP_MROUTE_MULTIPLE_TABLES=y
CONFIG_IP_PIMSM_V1=y
CONFIG_IP_PIMSM_V2=y
# CONFIG_ARPD is not set
CONFIG_SYN_COOKIES=y
# CONFIG_NET_IPVTI is not set
CONFIG_INET_AH=y
CONFIG_INET_ESP=y
CONFIG_INET_IPCOMP=y
CONFIG_INET_XFRM_TUNNEL=y
CONFIG_INET_TUNNEL=y
CONFIG_INET_XFRM_MODE_TRANSPORT=y
CONFIG_INET_XFRM_MODE_TUNNEL=y
CONFIG_INET_XFRM_MODE_BEET=y
CONFIG_INET_LRO=y
CONFIG_INET_DIAG=y
CONFIG_INET_TCP_DIAG=y
# CONFIG_INET_UDP_DIAG is not set
CONFIG_TCP_CONG_ADVANCED=y
CONFIG_TCP_CONG_BIC=y
CONFIG_TCP_CONG_CUBIC=y
CONFIG_TCP_CONG_WESTWOOD=y
CONFIG_TCP_CONG_HTCP=y
CONFIG_TCP_CONG_HSTCP=y
CONFIG_TCP_CONG_HYBLA=y
CONFIG_TCP_CONG_VEGAS=y
CONFIG_TCP_CONG_SCALABLE=y
CONFIG_TCP_CONG_LP=y
CONFIG_TCP_CONG_VENO=y
CONFIG_TCP_CONG_YEAH=y
CONFIG_TCP_CONG_ILLINOIS=y
# CONFIG_DEFAULT_BIC is not set
CONFIG_DEFAULT_CUBIC=y
# CONFIG_DEFAULT_HTCP is not set
# CONFIG_DEFAULT_HYBLA is not set
# CONFIG_DEFAULT_VEGAS is not set
# CONFIG_DEFAULT_VENO is not set
# CONFIG_DEFAULT_WESTWOOD is not set
# CONFIG_DEFAULT_RENO is not set
CONFIG_DEFAULT_TCP_CONG="cubic"
CONFIG_TCP_MD5SIG=y
CONFIG_IPV6=y
CONFIG_IPV6_PRIVACY=y
CONFIG_IPV6_ROUTER_PREF=y
CONFIG_IPV6_ROUTE_INFO=y
CONFIG_IPV6_OPTIMISTIC_DAD=y
CONFIG_INET6_AH=y
CONFIG_INET6_ESP=y
CONFIG_INET6_IPCOMP=y
CONFIG_IPV6_MIP6=y
CONFIG_INET6_XFRM_TUNNEL=y
CONFIG_INET6_TUNNEL=y
CONFIG_INET6_XFRM_MODE_TRANSPORT=y
CONFIG_INET6_XFRM_MODE_TUNNEL=y
CONFIG_INET6_XFRM_MODE_BEET=y
CONFIG_INET6_XFRM_MODE_ROUTEOPTIMIZATION=y
CONFIG_IPV6_SIT=y
CONFIG_IPV6_SIT_6RD=y
CONFIG_IPV6_NDISC_NODETYPE=y
CONFIG_IPV6_TUNNEL=y
# CONFIG_IPV6_GRE is not set
CONFIG_IPV6_MULTIPLE_TABLES=y
CONFIG_IPV6_SUBTREES=y
CONFIG_IPV6_MROUTE=y
CONFIG_IPV6_MROUTE_MULTIPLE_TABLES=y
CONFIG_IPV6_PIMSM_V2=y
# CONFIG_NETLABEL is not set
CONFIG_NETWORK_SECMARK=y
# CONFIG_NETWORK_PHY_TIMESTAMPING is not set
CONFIG_NETFILTER=y
# CONFIG_NETFILTER_DEBUG is not set
CONFIG_NETFILTER_ADVANCED=y
CONFIG_BRIDGE_NETFILTER=y

#
# Core Netfilter Configuration
#
CONFIG_NETFILTER_NETLINK=y
# CONFIG_NETFILTER_NETLINK_ACCT is not set
CONFIG_NETFILTER_NETLINK_QUEUE=y
CONFIG_NETFILTER_NETLINK_LOG=y
CONFIG_NF_CONNTRACK=y
CONFIG_NF_CONNTRACK_MARK=y
CONFIG_NF_CONNTRACK_SECMARK=y
CONFIG_NF_CONNTRACK_ZONES=y
CONFIG_NF_CONNTRACK_PROCFS=y
CONFIG_NF_CONNTRACK_EVENTS=y
# CONFIG_NF_CONNTRACK_TIMEOUT is not set
# CONFIG_NF_CONNTRACK_TIMESTAMP is not set
CONFIG_NF_CT_PROTO_DCCP=y
CONFIG_NF_CT_PROTO_GRE=y
CONFIG_NF_CT_PROTO_SCTP=y
CONFIG_NF_CT_PROTO_UDPLITE=y
CONFIG_NF_CONNTRACK_AMANDA=y
CONFIG_NF_CONNTRACK_FTP=y
CONFIG_NF_CONNTRACK_H323=y
CONFIG_NF_CONNTRACK_IRC=y
CONFIG_NF_CONNTRACK_BROADCAST=y
CONFIG_NF_CONNTRACK_NETBIOS_NS=y
# CONFIG_NF_CONNTRACK_SNMP is not set
CONFIG_NF_CONNTRACK_PPTP=y
CONFIG_NF_CONNTRACK_SANE=y
CONFIG_NF_CONNTRACK_SIP=y
CONFIG_NF_CONNTRACK_TFTP=y
CONFIG_NF_CT_NETLINK=y
# CONFIG_NF_CT_NETLINK_TIMEOUT is not set
# CONFIG_NETFILTER_NETLINK_QUEUE_CT is not set
CONFIG_NETFILTER_TPROXY=y
CONFIG_NETFILTER_XTABLES=y

#
# Xtables combined modules
#
CONFIG_NETFILTER_XT_MARK=y
CONFIG_NETFILTER_XT_CONNMARK=y

#
# Xtables targets
#
# CONFIG_NETFILTER_XT_TARGET_AUDIT is not set
# CONFIG_NETFILTER_XT_TARGET_CHECKSUM is not set
CONFIG_NETFILTER_XT_TARGET_CLASSIFY=y
CONFIG_NETFILTER_XT_TARGET_CONNMARK=y
CONFIG_NETFILTER_XT_TARGET_CONNSECMARK=y
CONFIG_NETFILTER_XT_TARGET_CT=y
CONFIG_NETFILTER_XT_TARGET_DSCP=y
CONFIG_NETFILTER_XT_TARGET_HL=y
# CONFIG_NETFILTER_XT_TARGET_HMARK is not set
# CONFIG_NETFILTER_XT_TARGET_IDLETIMER is not set
CONFIG_NETFILTER_XT_TARGET_LED=y
# CONFIG_NETFILTER_XT_TARGET_LOG is not set
CONFIG_NETFILTER_XT_TARGET_MARK=y
CONFIG_NETFILTER_XT_TARGET_NFLOG=y
CONFIG_NETFILTER_XT_TARGET_NFQUEUE=y
CONFIG_NETFILTER_XT_TARGET_NOTRACK=y
CONFIG_NETFILTER_XT_TARGET_RATEEST=y
CONFIG_NETFILTER_XT_TARGET_TEE=y
CONFIG_NETFILTER_XT_TARGET_TPROXY=y
CONFIG_NETFILTER_XT_TARGET_TRACE=y
CONFIG_NETFILTER_XT_TARGET_SECMARK=y
CONFIG_NETFILTER_XT_TARGET_TCPMSS=y
CONFIG_NETFILTER_XT_TARGET_TCPOPTSTRIP=y

#
# Xtables matches
#
# CONFIG_NETFILTER_XT_MATCH_ADDRTYPE is not set
CONFIG_NETFILTER_XT_MATCH_CLUSTER=y
CONFIG_NETFILTER_XT_MATCH_COMMENT=y
CONFIG_NETFILTER_XT_MATCH_CONNBYTES=y
CONFIG_NETFILTER_XT_MATCH_CONNLIMIT=y
CONFIG_NETFILTER_XT_MATCH_CONNMARK=y
CONFIG_NETFILTER_XT_MATCH_CONNTRACK=y
# CONFIG_NETFILTER_XT_MATCH_CPU is not set
CONFIG_NETFILTER_XT_MATCH_DCCP=y
# CONFIG_NETFILTER_XT_MATCH_DEVGROUP is not set
CONFIG_NETFILTER_XT_MATCH_DSCP=y
CONFIG_NETFILTER_XT_MATCH_ECN=y
CONFIG_NETFILTER_XT_MATCH_ESP=y
CONFIG_NETFILTER_XT_MATCH_HASHLIMIT=y
CONFIG_NETFILTER_XT_MATCH_HELPER=y
CONFIG_NETFILTER_XT_MATCH_HL=y
CONFIG_NETFILTER_XT_MATCH_IPRANGE=y
# CONFIG_NETFILTER_XT_MATCH_IPVS is not set
CONFIG_NETFILTER_XT_MATCH_LENGTH=y
CONFIG_NETFILTER_XT_MATCH_LIMIT=y
CONFIG_NETFILTER_XT_MATCH_MAC=y
CONFIG_NETFILTER_XT_MATCH_MARK=y
CONFIG_NETFILTER_XT_MATCH_MULTIPORT=y
# CONFIG_NETFILTER_XT_MATCH_NFACCT is not set
CONFIG_NETFILTER_XT_MATCH_OSF=y
CONFIG_NETFILTER_XT_MATCH_OWNER=y
CONFIG_NETFILTER_XT_MATCH_POLICY=y
CONFIG_NETFILTER_XT_MATCH_PHYSDEV=y
CONFIG_NETFILTER_XT_MATCH_PKTTYPE=y
CONFIG_NETFILTER_XT_MATCH_QUOTA=y
CONFIG_NETFILTER_XT_MATCH_RATEEST=y
CONFIG_NETFILTER_XT_MATCH_REALM=y
CONFIG_NETFILTER_XT_MATCH_RECENT=y
CONFIG_NETFILTER_XT_MATCH_SCTP=y
CONFIG_NETFILTER_XT_MATCH_SOCKET=y
CONFIG_NETFILTER_XT_MATCH_STATE=y
CONFIG_NETFILTER_XT_MATCH_STATISTIC=y
CONFIG_NETFILTER_XT_MATCH_STRING=y
CONFIG_NETFILTER_XT_MATCH_TCPMSS=y
CONFIG_NETFILTER_XT_MATCH_TIME=y
CONFIG_NETFILTER_XT_MATCH_U32=y
# CONFIG_IP_SET is not set
CONFIG_IP_VS=y
CONFIG_IP_VS_IPV6=y
# CONFIG_IP_VS_DEBUG is not set
CONFIG_IP_VS_TAB_BITS=12

#
# IPVS transport protocol load balancing support
#
CONFIG_IP_VS_PROTO_TCP=y
CONFIG_IP_VS_PROTO_UDP=y
CONFIG_IP_VS_PROTO_AH_ESP=y
CONFIG_IP_VS_PROTO_ESP=y
CONFIG_IP_VS_PROTO_AH=y
CONFIG_IP_VS_PROTO_SCTP=y

#
# IPVS scheduler
#
CONFIG_IP_VS_RR=y
CONFIG_IP_VS_WRR=y
CONFIG_IP_VS_LC=y
CONFIG_IP_VS_WLC=y
CONFIG_IP_VS_LBLC=y
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
CONFIG_IP_VS_FTP=y
CONFIG_IP_VS_NFCT=y
# CONFIG_IP_VS_PE_SIP is not set

#
# IP: Netfilter Configuration
#
CONFIG_NF_DEFRAG_IPV4=y
CONFIG_NF_CONNTRACK_IPV4=y
CONFIG_NF_CONNTRACK_PROC_COMPAT=y
CONFIG_IP_NF_QUEUE=y
CONFIG_IP_NF_IPTABLES=y
CONFIG_IP_NF_MATCH_AH=y
CONFIG_IP_NF_MATCH_ECN=y
# CONFIG_IP_NF_MATCH_RPFILTER is not set
CONFIG_IP_NF_MATCH_TTL=y
CONFIG_IP_NF_FILTER=y
CONFIG_IP_NF_TARGET_REJECT=y
CONFIG_IP_NF_TARGET_ULOG=y
CONFIG_NF_NAT=y
CONFIG_NF_NAT_NEEDED=y
CONFIG_IP_NF_TARGET_MASQUERADE=y
CONFIG_IP_NF_TARGET_NETMAP=y
CONFIG_IP_NF_TARGET_REDIRECT=y
CONFIG_NF_NAT_PROTO_DCCP=y
CONFIG_NF_NAT_PROTO_GRE=y
CONFIG_NF_NAT_PROTO_UDPLITE=y
CONFIG_NF_NAT_PROTO_SCTP=y
CONFIG_NF_NAT_FTP=y
CONFIG_NF_NAT_IRC=y
CONFIG_NF_NAT_TFTP=y
CONFIG_NF_NAT_AMANDA=y
CONFIG_NF_NAT_PPTP=y
CONFIG_NF_NAT_H323=y
CONFIG_NF_NAT_SIP=y
CONFIG_IP_NF_MANGLE=y
CONFIG_IP_NF_TARGET_CLUSTERIP=y
CONFIG_IP_NF_TARGET_ECN=y
CONFIG_IP_NF_TARGET_TTL=y
CONFIG_IP_NF_RAW=y
CONFIG_IP_NF_SECURITY=y
CONFIG_IP_NF_ARPTABLES=y
CONFIG_IP_NF_ARPFILTER=y
CONFIG_IP_NF_ARP_MANGLE=y

#
# IPv6: Netfilter Configuration
#
CONFIG_NF_DEFRAG_IPV6=y
CONFIG_NF_CONNTRACK_IPV6=y
CONFIG_IP6_NF_IPTABLES=y
CONFIG_IP6_NF_MATCH_AH=y
CONFIG_IP6_NF_MATCH_EUI64=y
CONFIG_IP6_NF_MATCH_FRAG=y
CONFIG_IP6_NF_MATCH_OPTS=y
CONFIG_IP6_NF_MATCH_HL=y
CONFIG_IP6_NF_MATCH_IPV6HEADER=y
CONFIG_IP6_NF_MATCH_MH=y
# CONFIG_IP6_NF_MATCH_RPFILTER is not set
CONFIG_IP6_NF_MATCH_RT=y
CONFIG_IP6_NF_TARGET_HL=y
CONFIG_IP6_NF_FILTER=y
CONFIG_IP6_NF_TARGET_REJECT=y
CONFIG_IP6_NF_MANGLE=y
CONFIG_IP6_NF_RAW=y
CONFIG_IP6_NF_SECURITY=y

#
# DECnet: Netfilter Configuration
#
CONFIG_DECNET_NF_GRABULATOR=y
CONFIG_BRIDGE_NF_EBTABLES=y
CONFIG_BRIDGE_EBT_BROUTE=y
CONFIG_BRIDGE_EBT_T_FILTER=y
CONFIG_BRIDGE_EBT_T_NAT=y
CONFIG_BRIDGE_EBT_802_3=y
CONFIG_BRIDGE_EBT_AMONG=y
CONFIG_BRIDGE_EBT_ARP=y
CONFIG_BRIDGE_EBT_IP=y
CONFIG_BRIDGE_EBT_IP6=y
CONFIG_BRIDGE_EBT_LIMIT=y
CONFIG_BRIDGE_EBT_MARK=y
CONFIG_BRIDGE_EBT_PKTTYPE=y
CONFIG_BRIDGE_EBT_STP=y
CONFIG_BRIDGE_EBT_VLAN=y
CONFIG_BRIDGE_EBT_ARPREPLY=y
CONFIG_BRIDGE_EBT_DNAT=y
CONFIG_BRIDGE_EBT_MARK_T=y
CONFIG_BRIDGE_EBT_REDIRECT=y
CONFIG_BRIDGE_EBT_SNAT=y
CONFIG_BRIDGE_EBT_LOG=y
CONFIG_BRIDGE_EBT_ULOG=y
CONFIG_BRIDGE_EBT_NFLOG=y
CONFIG_IP_DCCP=y
CONFIG_INET_DCCP_DIAG=y

#
# DCCP CCIDs Configuration (EXPERIMENTAL)
#
# CONFIG_IP_DCCP_CCID2_DEBUG is not set
CONFIG_IP_DCCP_CCID3=y
# CONFIG_IP_DCCP_CCID3_DEBUG is not set
CONFIG_IP_DCCP_TFRC_LIB=y

#
# DCCP Kernel Hacking
#
# CONFIG_IP_DCCP_DEBUG is not set
CONFIG_NET_DCCPPROBE=y
CONFIG_IP_SCTP=y
CONFIG_NET_SCTPPROBE=y
# CONFIG_SCTP_DBG_MSG is not set
# CONFIG_SCTP_DBG_OBJCNT is not set
# CONFIG_SCTP_HMAC_NONE is not set
# CONFIG_SCTP_HMAC_SHA1 is not set
CONFIG_SCTP_HMAC_MD5=y
CONFIG_RDS=y
CONFIG_RDS_RDMA=y
CONFIG_RDS_TCP=y
# CONFIG_RDS_DEBUG is not set
CONFIG_TIPC=y
CONFIG_TIPC_ADVANCED=y
CONFIG_TIPC_PORTS=8191
CONFIG_ATM=y
CONFIG_ATM_CLIP=y
# CONFIG_ATM_CLIP_NO_ICMP is not set
CONFIG_ATM_LANE=y
CONFIG_ATM_MPOA=y
CONFIG_ATM_BR2684=y
# CONFIG_ATM_BR2684_IPFILTER is not set
CONFIG_L2TP=y
CONFIG_L2TP_DEBUGFS=y
CONFIG_L2TP_V3=y
CONFIG_L2TP_IP=y
CONFIG_L2TP_ETH=y
CONFIG_STP=y
CONFIG_GARP=y
CONFIG_BRIDGE=y
CONFIG_BRIDGE_IGMP_SNOOPING=y
# CONFIG_NET_DSA is not set
CONFIG_VLAN_8021Q=y
CONFIG_VLAN_8021Q_GVRP=y
CONFIG_DECNET=y
# CONFIG_DECNET_ROUTER is not set
CONFIG_LLC=y
CONFIG_LLC2=y
CONFIG_IPX=y
# CONFIG_IPX_INTERN is not set
CONFIG_ATALK=y
CONFIG_DEV_APPLETALK=y
CONFIG_IPDDP=y
CONFIG_IPDDP_ENCAP=y
CONFIG_IPDDP_DECAP=y
# CONFIG_X25 is not set
CONFIG_LAPB=y
CONFIG_WAN_ROUTER=y
CONFIG_PHONET=y
CONFIG_IEEE802154=y
# CONFIG_IEEE802154_6LOWPAN is not set
# CONFIG_MAC802154 is not set
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
# CONFIG_NET_SCH_SFB is not set
CONFIG_NET_SCH_SFQ=y
CONFIG_NET_SCH_TEQL=y
CONFIG_NET_SCH_TBF=y
CONFIG_NET_SCH_GRED=y
CONFIG_NET_SCH_DSMARK=y
CONFIG_NET_SCH_NETEM=y
CONFIG_NET_SCH_DRR=y
# CONFIG_NET_SCH_MQPRIO is not set
# CONFIG_NET_SCH_CHOKE is not set
# CONFIG_NET_SCH_QFQ is not set
# CONFIG_NET_SCH_CODEL is not set
# CONFIG_NET_SCH_FQ_CODEL is not set
CONFIG_NET_SCH_INGRESS=y
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
CONFIG_CLS_U32_PERF=y
CONFIG_CLS_U32_MARK=y
CONFIG_NET_CLS_RSVP=y
CONFIG_NET_CLS_RSVP6=y
CONFIG_NET_CLS_FLOW=y
CONFIG_NET_CLS_CGROUP=y
CONFIG_NET_EMATCH=y
CONFIG_NET_EMATCH_STACK=32
CONFIG_NET_EMATCH_CMP=y
CONFIG_NET_EMATCH_NBYTE=y
CONFIG_NET_EMATCH_U32=y
CONFIG_NET_EMATCH_META=y
CONFIG_NET_EMATCH_TEXT=y
# CONFIG_NET_EMATCH_CANID is not set
CONFIG_NET_CLS_ACT=y
CONFIG_NET_ACT_POLICE=y
CONFIG_NET_ACT_GACT=y
CONFIG_GACT_PROB=y
CONFIG_NET_ACT_MIRRED=y
CONFIG_NET_ACT_IPT=y
CONFIG_NET_ACT_NAT=y
CONFIG_NET_ACT_PEDIT=y
CONFIG_NET_ACT_SIMP=y
CONFIG_NET_ACT_SKBEDIT=y
# CONFIG_NET_ACT_CSUM is not set
CONFIG_NET_CLS_IND=y
CONFIG_NET_SCH_FIFO=y
CONFIG_DCB=y
CONFIG_DNS_RESOLVER=y
# CONFIG_BATMAN_ADV is not set
# CONFIG_OPENVSWITCH is not set
CONFIG_RPS=y
CONFIG_RFS_ACCEL=y
CONFIG_XPS=y
# CONFIG_NETPRIO_CGROUP is not set
CONFIG_BQL=y
# CONFIG_BPF_JIT is not set

#
# Network testing
#
CONFIG_NET_PKTGEN=y
# CONFIG_NET_TCPPROBE is not set
CONFIG_NET_DROP_MONITOR=y
CONFIG_HAMRADIO=y

#
# Packet Radio protocols
#
CONFIG_AX25=y
# CONFIG_AX25_DAMA_SLAVE is not set
CONFIG_NETROM=y
CONFIG_ROSE=y

#
# AX.25 network device drivers
#
CONFIG_MKISS=y
CONFIG_6PACK=y
CONFIG_BPQETHER=y
CONFIG_BAYCOM_SER_FDX=y
CONFIG_BAYCOM_SER_HDX=y
CONFIG_BAYCOM_PAR=y
CONFIG_YAM=y
CONFIG_CAN=y
CONFIG_CAN_RAW=y
CONFIG_CAN_BCM=y
# CONFIG_CAN_GW is not set

#
# CAN Device Drivers
#
CONFIG_CAN_VCAN=y
# CONFIG_CAN_SLCAN is not set
CONFIG_CAN_DEV=y
CONFIG_CAN_CALC_BITTIMING=y
CONFIG_CAN_MCP251X=y
# CONFIG_PCH_CAN is not set
CONFIG_CAN_SJA1000=y
# CONFIG_CAN_SJA1000_ISA is not set
# CONFIG_CAN_SJA1000_PLATFORM is not set
# CONFIG_CAN_EMS_PCMCIA is not set
CONFIG_CAN_EMS_PCI=y
# CONFIG_CAN_PEAK_PCMCIA is not set
# CONFIG_CAN_PEAK_PCI is not set
CONFIG_CAN_KVASER_PCI=y
CONFIG_CAN_PLX_PCI=y
# CONFIG_CAN_C_CAN is not set
# CONFIG_CAN_CC770 is not set
# CONFIG_CAN_SOFTING is not set
# CONFIG_CAN_DEBUG_DEVICES is not set
CONFIG_IRDA=y

#
# IrDA protocols
#
CONFIG_IRLAN=y
CONFIG_IRNET=y
CONFIG_IRCOMM=y
# CONFIG_IRDA_ULTRA is not set

#
# IrDA options
#
CONFIG_IRDA_CACHE_LAST_LSAP=y
CONFIG_IRDA_FAST_RR=y
# CONFIG_IRDA_DEBUG is not set

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
CONFIG_ACTISYS_DONGLE=y
CONFIG_TEKRAM_DONGLE=y
CONFIG_TOIM3232_DONGLE=y
CONFIG_LITELINK_DONGLE=y
CONFIG_MA600_DONGLE=y
CONFIG_GIRBIL_DONGLE=y
CONFIG_MCP2120_DONGLE=y
CONFIG_OLD_BELKIN_DONGLE=y
CONFIG_ACT200L_DONGLE=y

#
# FIR device drivers
#
CONFIG_NSC_FIR=y
CONFIG_WINBOND_FIR=y
CONFIG_SMC_IRCC_FIR=y
CONFIG_ALI_FIR=y
CONFIG_VLSI_FIR=y
CONFIG_VIA_FIR=y
CONFIG_BT=y
# CONFIG_BT_RFCOMM is not set
# CONFIG_BT_BNEP is not set
# CONFIG_BT_CMTP is not set
# CONFIG_BT_HIDP is not set

#
# Bluetooth device drivers
#
CONFIG_BT_HCIBTSDIO=y
CONFIG_BT_HCIUART=y
CONFIG_BT_HCIUART_H4=y
CONFIG_BT_HCIUART_BCSP=y
# CONFIG_BT_HCIUART_ATH3K is not set
CONFIG_BT_HCIUART_LL=y
# CONFIG_BT_HCIUART_3WIRE is not set
CONFIG_BT_HCIDTL1=y
CONFIG_BT_HCIBT3C=y
CONFIG_BT_HCIBLUECARD=y
CONFIG_BT_HCIBTUART=y
CONFIG_BT_HCIVHCI=y
CONFIG_BT_MRVL=y
CONFIG_BT_MRVL_SDIO=y
CONFIG_AF_RXRPC=y
# CONFIG_AF_RXRPC_DEBUG is not set
CONFIG_RXKAD=y
CONFIG_FIB_RULES=y
CONFIG_WIRELESS=y
CONFIG_WIRELESS_EXT=y
CONFIG_WEXT_CORE=y
CONFIG_WEXT_PROC=y
CONFIG_WEXT_SPY=y
CONFIG_WEXT_PRIV=y
CONFIG_CFG80211=y
# CONFIG_NL80211_TESTMODE is not set
# CONFIG_CFG80211_DEVELOPER_WARNINGS is not set
# CONFIG_CFG80211_REG_DEBUG is not set
CONFIG_CFG80211_DEFAULT_PS=y
# CONFIG_CFG80211_DEBUGFS is not set
# CONFIG_CFG80211_INTERNAL_REGDB is not set
CONFIG_CFG80211_WEXT=y
CONFIG_LIB80211=y
CONFIG_LIB80211_CRYPT_WEP=y
CONFIG_LIB80211_CRYPT_CCMP=y
CONFIG_LIB80211_CRYPT_TKIP=y
# CONFIG_LIB80211_DEBUG is not set
CONFIG_MAC80211=y
CONFIG_MAC80211_HAS_RC=y
CONFIG_MAC80211_RC_MINSTREL=y
CONFIG_MAC80211_RC_MINSTREL_HT=y
CONFIG_MAC80211_RC_DEFAULT_MINSTREL=y
CONFIG_MAC80211_RC_DEFAULT="minstrel_ht"
CONFIG_MAC80211_MESH=y
CONFIG_MAC80211_LEDS=y
# CONFIG_MAC80211_DEBUGFS is not set
# CONFIG_MAC80211_MESSAGE_TRACING is not set
# CONFIG_MAC80211_DEBUG_MENU is not set
CONFIG_WIMAX=y
CONFIG_WIMAX_DEBUG_LEVEL=8
CONFIG_RFKILL=y
CONFIG_RFKILL_LEDS=y
CONFIG_RFKILL_INPUT=y
# CONFIG_RFKILL_REGULATOR is not set
CONFIG_NET_9P=y
CONFIG_NET_9P_VIRTIO=y
CONFIG_NET_9P_RDMA=y
# CONFIG_NET_9P_DEBUG is not set
# CONFIG_CAIF is not set
CONFIG_CEPH_LIB=y
# CONFIG_CEPH_LIB_PRETTYDEBUG is not set
# CONFIG_CEPH_LIB_USE_DNS_RESOLVER is not set
# CONFIG_NFC is not set
CONFIG_HAVE_BPF_JIT=y

#
# Device Drivers
#

#
# Generic Driver Options
#
CONFIG_UEVENT_HELPER_PATH=""
CONFIG_DEVTMPFS=y
# CONFIG_DEVTMPFS_MOUNT is not set
CONFIG_STANDALONE=y
CONFIG_PREVENT_FIRMWARE_BUILD=y
CONFIG_FW_LOADER=y
# CONFIG_FIRMWARE_IN_KERNEL is not set
CONFIG_EXTRA_FIRMWARE=""
# CONFIG_DEBUG_DRIVER is not set
# CONFIG_DEBUG_DEVRES is not set
CONFIG_SYS_HYPERVISOR=y
# CONFIG_GENERIC_CPU_DEVICES is not set
CONFIG_REGMAP=y
CONFIG_REGMAP_I2C=y
CONFIG_DMA_SHARED_BUFFER=y
CONFIG_CONNECTOR=y
CONFIG_PROC_EVENTS=y
CONFIG_MTD=y
# CONFIG_MTD_TESTS is not set
CONFIG_MTD_REDBOOT_PARTS=y
CONFIG_MTD_REDBOOT_DIRECTORY_BLOCK=-1
# CONFIG_MTD_REDBOOT_PARTS_UNALLOCATED is not set
# CONFIG_MTD_REDBOOT_PARTS_READONLY is not set
# CONFIG_MTD_CMDLINE_PARTS is not set
CONFIG_MTD_AR7_PARTS=y

#
# User Modules And Translation Layers
#
CONFIG_MTD_CHAR=y
CONFIG_MTD_BLKDEVS=y
CONFIG_MTD_BLOCK=y
CONFIG_FTL=y
CONFIG_NFTL=y
CONFIG_NFTL_RW=y
CONFIG_INFTL=y
CONFIG_RFD_FTL=y
CONFIG_SSFDC=y
# CONFIG_SM_FTL is not set
CONFIG_MTD_OOPS=y
# CONFIG_MTD_SWAP is not set

#
# RAM/ROM/Flash chip drivers
#
CONFIG_MTD_CFI=y
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
CONFIG_MTD_ABSENT=y

#
# Mapping drivers for chip access
#
CONFIG_MTD_COMPLEX_MAPPINGS=y
CONFIG_MTD_PHYSMAP=y
# CONFIG_MTD_PHYSMAP_COMPAT is not set
# CONFIG_MTD_SC520CDP is not set
CONFIG_MTD_NETSC520=y
CONFIG_MTD_TS5500=y
CONFIG_MTD_SBC_GXX=y
# CONFIG_MTD_AMD76XROM is not set
# CONFIG_MTD_ICHXROM is not set
# CONFIG_MTD_ESB2ROM is not set
# CONFIG_MTD_CK804XROM is not set
# CONFIG_MTD_SCB2_FLASH is not set
# CONFIG_MTD_NETtel is not set
# CONFIG_MTD_L440GX is not set
CONFIG_MTD_PCI=y
CONFIG_MTD_PCMCIA=y
# CONFIG_MTD_PCMCIA_ANONYMOUS is not set
# CONFIG_MTD_GPIO_ADDR is not set
CONFIG_MTD_INTEL_VR_NOR=y
CONFIG_MTD_PLATRAM=y
# CONFIG_MTD_LATCH_ADDR is not set

#
# Self-contained MTD device drivers
#
CONFIG_MTD_PMC551=y
# CONFIG_MTD_PMC551_BUGFIX is not set
# CONFIG_MTD_PMC551_DEBUG is not set
CONFIG_MTD_DATAFLASH=y
# CONFIG_MTD_DATAFLASH_WRITE_VERIFY is not set
# CONFIG_MTD_DATAFLASH_OTP is not set
CONFIG_MTD_M25P80=y
CONFIG_M25PXX_USE_FAST_READ=y
CONFIG_MTD_SST25L=y
CONFIG_MTD_SLRAM=y
CONFIG_MTD_PHRAM=y
CONFIG_MTD_MTDRAM=y
CONFIG_MTDRAM_TOTAL_SIZE=4096
CONFIG_MTDRAM_ERASE_SIZE=128
CONFIG_MTDRAM_ABS_POS=0
CONFIG_MTD_BLOCK2MTD=y

#
# Disk-On-Chip Device Drivers
#
CONFIG_MTD_DOC2000=y
CONFIG_MTD_DOC2001=y
CONFIG_MTD_DOC2001PLUS=y
# CONFIG_MTD_DOCG3 is not set
CONFIG_MTD_DOCPROBE=y
CONFIG_MTD_DOCECC=y
# CONFIG_MTD_DOCPROBE_ADVANCED is not set
CONFIG_MTD_DOCPROBE_ADDRESS=0x0
CONFIG_MTD_NAND_ECC=y
# CONFIG_MTD_NAND_ECC_SMC is not set
CONFIG_MTD_NAND=y
# CONFIG_MTD_NAND_VERIFY_WRITE is not set
# CONFIG_MTD_NAND_ECC_BCH is not set
CONFIG_MTD_SM_COMMON=y
# CONFIG_MTD_NAND_MUSEUM_IDS is not set
# CONFIG_MTD_NAND_DENALI is not set
CONFIG_MTD_NAND_IDS=y
CONFIG_MTD_NAND_RICOH=y
CONFIG_MTD_NAND_DISKONCHIP=y
# CONFIG_MTD_NAND_DISKONCHIP_PROBE_ADVANCED is not set
CONFIG_MTD_NAND_DISKONCHIP_PROBE_ADDRESS=0
# CONFIG_MTD_NAND_DISKONCHIP_BBTWRITE is not set
# CONFIG_MTD_NAND_DOCG4 is not set
CONFIG_MTD_NAND_CAFE=y
CONFIG_MTD_NAND_NANDSIM=y
CONFIG_MTD_NAND_PLATFORM=y
CONFIG_MTD_ONENAND=y
CONFIG_MTD_ONENAND_VERIFY_WRITE=y
CONFIG_MTD_ONENAND_GENERIC=y
# CONFIG_MTD_ONENAND_OTP is not set
CONFIG_MTD_ONENAND_2X_PROGRAM=y
CONFIG_MTD_ONENAND_SIM=y

#
# LPDDR flash memory drivers
#
CONFIG_MTD_LPDDR=y
CONFIG_MTD_QINFO_PROBE=y
CONFIG_MTD_UBI=y
CONFIG_MTD_UBI_WL_THRESHOLD=4096
CONFIG_MTD_UBI_BEB_RESERVE=2
# CONFIG_MTD_UBI_GLUEBI is not set
CONFIG_PARPORT=y
CONFIG_PARPORT_PC=y
CONFIG_PARPORT_SERIAL=y
# CONFIG_PARPORT_PC_FIFO is not set
# CONFIG_PARPORT_PC_SUPERIO is not set
CONFIG_PARPORT_PC_PCMCIA=y
# CONFIG_PARPORT_GSC is not set
CONFIG_PARPORT_AX88796=y
CONFIG_PARPORT_1284=y
CONFIG_PARPORT_NOT_PC=y
CONFIG_PNP=y
# CONFIG_PNP_DEBUG_MESSAGES is not set

#
# Protocols
#
CONFIG_PNPACPI=y
CONFIG_BLK_DEV=y
CONFIG_BLK_DEV_FD=y
CONFIG_PARIDE=m

#
# Parallel IDE high-level drivers
#
CONFIG_PARIDE_PD=m
CONFIG_PARIDE_PCD=m
CONFIG_PARIDE_PF=m
CONFIG_PARIDE_PT=m
CONFIG_PARIDE_PG=m

#
# Parallel IDE protocol modules
#
CONFIG_PARIDE_ATEN=m
CONFIG_PARIDE_BPCK=m
CONFIG_PARIDE_COMM=m
CONFIG_PARIDE_DSTR=m
CONFIG_PARIDE_FIT2=m
CONFIG_PARIDE_FIT3=m
CONFIG_PARIDE_EPAT=m
# CONFIG_PARIDE_EPATC8 is not set
CONFIG_PARIDE_EPIA=m
CONFIG_PARIDE_FRIQ=m
CONFIG_PARIDE_FRPW=m
CONFIG_PARIDE_KBIC=m
CONFIG_PARIDE_KTTI=m
CONFIG_PARIDE_ON20=m
CONFIG_PARIDE_ON26=m
# CONFIG_BLK_DEV_PCIESSD_MTIP32XX is not set
CONFIG_BLK_CPQ_DA=y
CONFIG_BLK_CPQ_CISS_DA=y
CONFIG_CISS_SCSI_TAPE=y
CONFIG_BLK_DEV_DAC960=y
CONFIG_BLK_DEV_UMEM=y
# CONFIG_BLK_DEV_COW_COMMON is not set
CONFIG_BLK_DEV_LOOP=y
CONFIG_BLK_DEV_LOOP_MIN_COUNT=8
# CONFIG_BLK_DEV_CRYPTOLOOP is not set
CONFIG_BLK_DEV_DRBD=y
# CONFIG_DRBD_FAULT_INJECTION is not set
CONFIG_BLK_DEV_NBD=y
# CONFIG_BLK_DEV_NVME is not set
CONFIG_BLK_DEV_OSD=y
CONFIG_BLK_DEV_SX8=y
CONFIG_BLK_DEV_RAM=y
CONFIG_BLK_DEV_RAM_COUNT=16
CONFIG_BLK_DEV_RAM_SIZE=65536
# CONFIG_BLK_DEV_XIP is not set
CONFIG_CDROM_PKTCDVD=y
CONFIG_CDROM_PKTCDVD_BUFFERS=8
# CONFIG_CDROM_PKTCDVD_WCACHE is not set
CONFIG_ATA_OVER_ETH=y
CONFIG_XEN_BLKDEV_FRONTEND=y
# CONFIG_XEN_BLKDEV_BACKEND is not set
CONFIG_VIRTIO_BLK=y
# CONFIG_BLK_DEV_HD is not set
# CONFIG_BLK_DEV_RBD is not set

#
# Misc devices
#
CONFIG_SENSORS_LIS3LV02D=y
CONFIG_AD525X_DPOT=y
CONFIG_AD525X_DPOT_I2C=y
CONFIG_AD525X_DPOT_SPI=y
CONFIG_IBM_ASM=y
CONFIG_PHANTOM=y
# CONFIG_INTEL_MID_PTI is not set
CONFIG_SGI_IOC4=y
CONFIG_TIFM_CORE=y
CONFIG_TIFM_7XX1=y
CONFIG_ICS932S401=y
CONFIG_ENCLOSURE_SERVICES=y
CONFIG_HP_ILO=y
# CONFIG_APDS9802ALS is not set
CONFIG_ISL29003=y
# CONFIG_ISL29020 is not set
CONFIG_SENSORS_TSL2550=y
# CONFIG_SENSORS_BH1780 is not set
# CONFIG_SENSORS_BH1770 is not set
# CONFIG_SENSORS_APDS990X is not set
# CONFIG_HMC6352 is not set
CONFIG_DS1682=y
CONFIG_TI_DAC7512=y
CONFIG_VMWARE_BALLOON=y
# CONFIG_BMP085_I2C is not set
# CONFIG_BMP085_SPI is not set
# CONFIG_PCH_PHUB is not set
# CONFIG_USB_SWITCH_FSA9480 is not set
CONFIG_C2PORT=y
CONFIG_C2PORT_DURAMAR_2150=y

#
# EEPROM support
#
CONFIG_EEPROM_AT24=y
CONFIG_EEPROM_AT25=y
CONFIG_EEPROM_LEGACY=y
CONFIG_EEPROM_MAX6875=y
CONFIG_EEPROM_93CX6=y
# CONFIG_EEPROM_93XX46 is not set
CONFIG_CB710_CORE=y
# CONFIG_CB710_DEBUG is not set
CONFIG_CB710_DEBUG_ASSUMPTIONS=y

#
# Texas Instruments shared transport line discipline
#
# CONFIG_TI_ST is not set
CONFIG_SENSORS_LIS3_I2C=y

#
# Altera FPGA firmware download module
#
# CONFIG_ALTERA_STAPL is not set
# CONFIG_INTEL_MEI is not set
CONFIG_HAVE_IDE=y
CONFIG_IDE=y

#
# Please see Documentation/ide/ide.txt for help/info on IDE drives
#
CONFIG_IDE_XFER_MODE=y
CONFIG_IDE_ATAPI=y
# CONFIG_BLK_DEV_IDE_SATA is not set
CONFIG_IDE_GD=y
CONFIG_IDE_GD_ATA=y
CONFIG_IDE_GD_ATAPI=y
# CONFIG_BLK_DEV_IDECS is not set
CONFIG_BLK_DEV_DELKIN=y
CONFIG_BLK_DEV_IDECD=y
CONFIG_BLK_DEV_IDECD_VERBOSE_ERRORS=y
CONFIG_BLK_DEV_IDETAPE=y
# CONFIG_BLK_DEV_IDEACPI is not set
# CONFIG_IDE_TASK_IOCTL is not set
CONFIG_IDE_PROC_FS=y

#
# IDE chipset support/bugfixes
#
CONFIG_IDE_GENERIC=y
# CONFIG_BLK_DEV_PLATFORM is not set
# CONFIG_BLK_DEV_CMD640 is not set
CONFIG_BLK_DEV_IDEPNP=y
CONFIG_BLK_DEV_IDEDMA_SFF=y

#
# PCI IDE chipsets support
#
CONFIG_BLK_DEV_IDEPCI=y
CONFIG_IDEPCI_PCIBUS_ORDER=y
# CONFIG_BLK_DEV_OFFBOARD is not set
# CONFIG_BLK_DEV_GENERIC is not set
CONFIG_BLK_DEV_OPTI621=y
# CONFIG_BLK_DEV_RZ1000 is not set
CONFIG_BLK_DEV_IDEDMA_PCI=y
# CONFIG_BLK_DEV_AEC62XX is not set
# CONFIG_BLK_DEV_ALI15X3 is not set
# CONFIG_BLK_DEV_AMD74XX is not set
# CONFIG_BLK_DEV_ATIIXP is not set
# CONFIG_BLK_DEV_CMD64X is not set
# CONFIG_BLK_DEV_TRIFLEX is not set
# CONFIG_BLK_DEV_CS5520 is not set
# CONFIG_BLK_DEV_CS5530 is not set
CONFIG_BLK_DEV_HPT366=y
# CONFIG_BLK_DEV_JMICRON is not set
# CONFIG_BLK_DEV_SC1200 is not set
CONFIG_BLK_DEV_PIIX=y
CONFIG_BLK_DEV_IT8172=y
CONFIG_BLK_DEV_IT8213=y
# CONFIG_BLK_DEV_IT821X is not set
# CONFIG_BLK_DEV_NS87415 is not set
# CONFIG_BLK_DEV_PDC202XX_OLD is not set
# CONFIG_BLK_DEV_PDC202XX_NEW is not set
# CONFIG_BLK_DEV_SVWKS is not set
# CONFIG_BLK_DEV_SIIMAGE is not set
# CONFIG_BLK_DEV_SIS5513 is not set
# CONFIG_BLK_DEV_SLC90E66 is not set
CONFIG_BLK_DEV_TRM290=y
# CONFIG_BLK_DEV_VIA82CXXX is not set
CONFIG_BLK_DEV_TC86C001=y
CONFIG_BLK_DEV_IDEDMA=y

#
# SCSI device support
#
CONFIG_SCSI_MOD=y
CONFIG_RAID_ATTRS=y
CONFIG_SCSI=y
CONFIG_SCSI_DMA=y
CONFIG_SCSI_TGT=y
CONFIG_SCSI_NETLINK=y
# CONFIG_SCSI_PROC_FS is not set

#
# SCSI support type (disk, tape, CD-ROM)
#
CONFIG_BLK_DEV_SD=y
CONFIG_CHR_DEV_ST=y
CONFIG_CHR_DEV_OSST=y
CONFIG_BLK_DEV_SR=y
CONFIG_BLK_DEV_SR_VENDOR=y
CONFIG_CHR_DEV_SG=y
CONFIG_CHR_DEV_SCH=y
CONFIG_SCSI_ENCLOSURE=y
CONFIG_SCSI_MULTI_LUN=y
CONFIG_SCSI_CONSTANTS=y
CONFIG_SCSI_LOGGING=y
CONFIG_SCSI_SCAN_ASYNC=y

#
# SCSI Transports
#
CONFIG_SCSI_SPI_ATTRS=y
CONFIG_SCSI_FC_ATTRS=y
CONFIG_SCSI_FC_TGT_ATTRS=y
CONFIG_SCSI_ISCSI_ATTRS=y
CONFIG_SCSI_SAS_ATTRS=y
CONFIG_SCSI_SAS_LIBSAS=y
CONFIG_SCSI_SAS_ATA=y
CONFIG_SCSI_SAS_HOST_SMP=y
CONFIG_SCSI_SRP_ATTRS=y
CONFIG_SCSI_SRP_TGT_ATTRS=y
CONFIG_SCSI_LOWLEVEL=y
CONFIG_ISCSI_TCP=y
CONFIG_ISCSI_BOOT_SYSFS=y
CONFIG_SCSI_CXGB3_ISCSI=y
# CONFIG_SCSI_CXGB4_ISCSI is not set
CONFIG_SCSI_BNX2_ISCSI=y
# CONFIG_SCSI_BNX2X_FCOE is not set
CONFIG_BE2ISCSI=y
CONFIG_BLK_DEV_3W_XXXX_RAID=y
CONFIG_SCSI_HPSA=y
CONFIG_SCSI_3W_9XXX=y
CONFIG_SCSI_3W_SAS=y
CONFIG_SCSI_ACARD=y
CONFIG_SCSI_AACRAID=y
CONFIG_SCSI_AIC7XXX=y
CONFIG_AIC7XXX_CMDS_PER_DEVICE=8
CONFIG_AIC7XXX_RESET_DELAY_MS=15000
CONFIG_AIC7XXX_DEBUG_ENABLE=y
CONFIG_AIC7XXX_DEBUG_MASK=0
CONFIG_AIC7XXX_REG_PRETTY_PRINT=y
CONFIG_SCSI_AIC7XXX_OLD=y
CONFIG_SCSI_AIC79XX=y
CONFIG_AIC79XX_CMDS_PER_DEVICE=32
CONFIG_AIC79XX_RESET_DELAY_MS=15000
CONFIG_AIC79XX_DEBUG_ENABLE=y
CONFIG_AIC79XX_DEBUG_MASK=0
CONFIG_AIC79XX_REG_PRETTY_PRINT=y
CONFIG_SCSI_AIC94XX=y
# CONFIG_AIC94XX_DEBUG is not set
CONFIG_SCSI_MVSAS=y
# CONFIG_SCSI_MVSAS_DEBUG is not set
# CONFIG_SCSI_MVSAS_TASKLET is not set
# CONFIG_SCSI_MVUMI is not set
CONFIG_SCSI_DPT_I2O=y
CONFIG_SCSI_ADVANSYS=y
CONFIG_SCSI_ARCMSR=y
CONFIG_MEGARAID_NEWGEN=y
CONFIG_MEGARAID_MM=y
CONFIG_MEGARAID_MAILBOX=y
CONFIG_MEGARAID_LEGACY=y
CONFIG_MEGARAID_SAS=y
CONFIG_SCSI_MPT2SAS=y
CONFIG_SCSI_MPT2SAS_MAX_SGE=128
# CONFIG_SCSI_MPT2SAS_LOGGING is not set
# CONFIG_SCSI_UFSHCD is not set
CONFIG_SCSI_HPTIOP=y
CONFIG_SCSI_BUSLOGIC=y
CONFIG_VMWARE_PVSCSI=y
CONFIG_LIBFC=y
CONFIG_LIBFCOE=y
CONFIG_FCOE=y
CONFIG_FCOE_FNIC=y
CONFIG_SCSI_DMX3191D=y
CONFIG_SCSI_EATA=y
CONFIG_SCSI_EATA_TAGGED_QUEUE=y
CONFIG_SCSI_EATA_LINKED_COMMANDS=y
CONFIG_SCSI_EATA_MAX_TAGS=16
CONFIG_SCSI_FUTURE_DOMAIN=y
CONFIG_SCSI_GDTH=y
# CONFIG_SCSI_ISCI is not set
CONFIG_SCSI_IPS=y
CONFIG_SCSI_INITIO=y
CONFIG_SCSI_INIA100=y
CONFIG_SCSI_PPA=y
CONFIG_SCSI_IMM=y
# CONFIG_SCSI_IZIP_EPP16 is not set
# CONFIG_SCSI_IZIP_SLOW_CTR is not set
CONFIG_SCSI_STEX=y
CONFIG_SCSI_SYM53C8XX_2=y
CONFIG_SCSI_SYM53C8XX_DMA_ADDRESSING_MODE=1
CONFIG_SCSI_SYM53C8XX_DEFAULT_TAGS=16
CONFIG_SCSI_SYM53C8XX_MAX_TAGS=64
CONFIG_SCSI_SYM53C8XX_MMIO=y
CONFIG_SCSI_IPR=y
# CONFIG_SCSI_IPR_TRACE is not set
# CONFIG_SCSI_IPR_DUMP is not set
CONFIG_SCSI_QLOGIC_1280=y
CONFIG_SCSI_QLA_FC=y
CONFIG_SCSI_QLA_ISCSI=y
# CONFIG_SCSI_LPFC is not set
CONFIG_SCSI_DC395x=y
CONFIG_SCSI_DC390T=y
CONFIG_SCSI_DEBUG=y
CONFIG_SCSI_PMCRAID=y
CONFIG_SCSI_PM8001=y
CONFIG_SCSI_SRP=y
CONFIG_SCSI_BFA_FC=y
# CONFIG_SCSI_VIRTIO is not set
CONFIG_SCSI_LOWLEVEL_PCMCIA=y
# CONFIG_PCMCIA_AHA152X is not set
CONFIG_PCMCIA_FDOMAIN=m
CONFIG_PCMCIA_QLOGIC=m
CONFIG_PCMCIA_SYM53C500=m
CONFIG_SCSI_DH=y
CONFIG_SCSI_DH_RDAC=y
CONFIG_SCSI_DH_HP_SW=y
CONFIG_SCSI_DH_EMC=y
CONFIG_SCSI_DH_ALUA=y
CONFIG_SCSI_OSD_INITIATOR=y
CONFIG_SCSI_OSD_ULD=y
CONFIG_SCSI_OSD_DPRINT_SENSE=1
# CONFIG_SCSI_OSD_DEBUG is not set
CONFIG_ATA=y
# CONFIG_ATA_NONSTANDARD is not set
CONFIG_ATA_VERBOSE_ERROR=y
CONFIG_ATA_ACPI=y
CONFIG_SATA_PMP=y

#
# Controllers with non-SFF native interface
#
CONFIG_SATA_AHCI=y
# CONFIG_SATA_AHCI_PLATFORM is not set
CONFIG_SATA_INIC162X=y
# CONFIG_SATA_ACARD_AHCI is not set
CONFIG_SATA_SIL24=y
CONFIG_ATA_SFF=y

#
# SFF controllers with custom DMA interface
#
CONFIG_PDC_ADMA=y
CONFIG_SATA_QSTOR=y
CONFIG_SATA_SX4=y
CONFIG_ATA_BMDMA=y

#
# SATA SFF controllers with BMDMA
#
CONFIG_ATA_PIIX=y
CONFIG_SATA_MV=y
CONFIG_SATA_NV=y
CONFIG_SATA_PROMISE=y
CONFIG_SATA_SIL=y
CONFIG_SATA_SIS=y
CONFIG_SATA_SVW=y
CONFIG_SATA_ULI=y
CONFIG_SATA_VIA=y
CONFIG_SATA_VITESSE=y

#
# PATA SFF controllers with BMDMA
#
CONFIG_PATA_ALI=y
CONFIG_PATA_AMD=y
# CONFIG_PATA_ARASAN_CF is not set
CONFIG_PATA_ARTOP=y
CONFIG_PATA_ATIIXP=y
CONFIG_PATA_ATP867X=y
CONFIG_PATA_CMD64X=y
CONFIG_PATA_CS5520=y
CONFIG_PATA_CS5530=y
# CONFIG_PATA_CS5536 is not set
# CONFIG_PATA_CYPRESS is not set
CONFIG_PATA_EFAR=y
# CONFIG_PATA_HPT366 is not set
# CONFIG_PATA_HPT37X is not set
# CONFIG_PATA_HPT3X2N is not set
# CONFIG_PATA_HPT3X3 is not set
# CONFIG_PATA_IT8213 is not set
CONFIG_PATA_IT821X=y
CONFIG_PATA_JMICRON=y
CONFIG_PATA_MARVELL=y
CONFIG_PATA_NETCELL=y
# CONFIG_PATA_NINJA32 is not set
CONFIG_PATA_NS87415=y
CONFIG_PATA_OLDPIIX=y
# CONFIG_PATA_OPTIDMA is not set
CONFIG_PATA_PDC2027X=y
CONFIG_PATA_PDC_OLD=y
# CONFIG_PATA_RADISYS is not set
CONFIG_PATA_RDC=y
CONFIG_PATA_SC1200=y
CONFIG_PATA_SCH=y
CONFIG_PATA_SERVERWORKS=y
CONFIG_PATA_SIL680=y
CONFIG_PATA_SIS=y
CONFIG_PATA_TOSHIBA=y
CONFIG_PATA_TRIFLEX=y
CONFIG_PATA_VIA=y
# CONFIG_PATA_WINBOND is not set

#
# PIO-only SFF controllers
#
# CONFIG_PATA_CMD640_PCI is not set
CONFIG_PATA_MPIIX=y
CONFIG_PATA_NS87410=y
# CONFIG_PATA_OPTI is not set
CONFIG_PATA_PCMCIA=y
CONFIG_PATA_RZ1000=y

#
# Generic fallback / legacy drivers
#
# CONFIG_PATA_ACPI is not set
CONFIG_ATA_GENERIC=y
# CONFIG_PATA_LEGACY is not set
CONFIG_MD=y
CONFIG_BLK_DEV_MD=y
CONFIG_MD_AUTODETECT=y
CONFIG_MD_LINEAR=y
CONFIG_MD_RAID0=y
CONFIG_MD_RAID1=y
CONFIG_MD_RAID10=y
CONFIG_MD_RAID456=y
# CONFIG_MULTICORE_RAID456 is not set
CONFIG_MD_MULTIPATH=y
CONFIG_MD_FAULTY=y
CONFIG_BLK_DEV_DM=y
# CONFIG_DM_DEBUG is not set
CONFIG_DM_CRYPT=y
CONFIG_DM_SNAPSHOT=y
# CONFIG_DM_THIN_PROVISIONING is not set
CONFIG_DM_MIRROR=y
# CONFIG_DM_RAID is not set
CONFIG_DM_LOG_USERSPACE=y
CONFIG_DM_ZERO=y
CONFIG_DM_MULTIPATH=y
CONFIG_DM_MULTIPATH_QL=y
CONFIG_DM_MULTIPATH_ST=y
CONFIG_DM_DELAY=y
CONFIG_DM_UEVENT=y
# CONFIG_DM_FLAKEY is not set
# CONFIG_DM_VERITY is not set
# CONFIG_TARGET_CORE is not set
CONFIG_FUSION=y
CONFIG_FUSION_SPI=y
CONFIG_FUSION_FC=y
CONFIG_FUSION_SAS=y
CONFIG_FUSION_MAX_SGE=128
CONFIG_FUSION_CTL=y
CONFIG_FUSION_LAN=y
# CONFIG_FUSION_LOGGING is not set

#
# IEEE 1394 (FireWire) support
#
CONFIG_FIREWIRE=y
CONFIG_FIREWIRE_OHCI=y
CONFIG_FIREWIRE_SBP2=y
CONFIG_FIREWIRE_NET=y
# CONFIG_FIREWIRE_NOSY is not set
CONFIG_I2O=y
CONFIG_I2O_LCT_NOTIFY_ON_CHANGES=y
CONFIG_I2O_EXT_ADAPTEC=y
CONFIG_I2O_EXT_ADAPTEC_DMA64=y
CONFIG_I2O_CONFIG=y
CONFIG_I2O_CONFIG_OLD_IOCTL=y
CONFIG_I2O_BUS=y
CONFIG_I2O_BLOCK=y
CONFIG_I2O_SCSI=y
CONFIG_I2O_PROC=y
CONFIG_MACINTOSH_DRIVERS=y
CONFIG_MAC_EMUMOUSEBTN=y
CONFIG_NETDEVICES=y
CONFIG_NET_CORE=y
CONFIG_BONDING=y
CONFIG_DUMMY=y
CONFIG_EQUALIZER=y
CONFIG_NET_FC=y
CONFIG_MII=y
CONFIG_IFB=y
# CONFIG_NET_TEAM is not set
CONFIG_MACVLAN=y
CONFIG_MACVTAP=y
CONFIG_NETCONSOLE=y
CONFIG_NETCONSOLE_DYNAMIC=y
CONFIG_NETPOLL=y
# CONFIG_NETPOLL_TRAP is not set
CONFIG_NET_POLL_CONTROLLER=y
CONFIG_TUN=y
CONFIG_VETH=y
CONFIG_VIRTIO_NET=y
CONFIG_ARCNET=y
CONFIG_ARCNET_1201=y
CONFIG_ARCNET_1051=y
CONFIG_ARCNET_RAW=y
CONFIG_ARCNET_CAP=y
CONFIG_ARCNET_COM90xx=y
CONFIG_ARCNET_COM90xxIO=y
CONFIG_ARCNET_RIM_I=y
CONFIG_ARCNET_COM20020=y
CONFIG_ARCNET_COM20020_PCI=y
# CONFIG_ARCNET_COM20020_CS is not set
CONFIG_ATM_DRIVERS=y
CONFIG_ATM_DUMMY=y
CONFIG_ATM_TCP=y
CONFIG_ATM_LANAI=y
CONFIG_ATM_ENI=y
# CONFIG_ATM_ENI_DEBUG is not set
# CONFIG_ATM_ENI_TUNE_BURST is not set
CONFIG_ATM_FIRESTREAM=y
CONFIG_ATM_ZATM=y
# CONFIG_ATM_ZATM_DEBUG is not set
# CONFIG_ATM_NICSTAR is not set
CONFIG_ATM_IDT77252=y
# CONFIG_ATM_IDT77252_DEBUG is not set
# CONFIG_ATM_IDT77252_RCV_ALL is not set
CONFIG_ATM_IDT77252_USE_SUNI=y
CONFIG_ATM_AMBASSADOR=y
# CONFIG_ATM_AMBASSADOR_DEBUG is not set
CONFIG_ATM_HORIZON=y
# CONFIG_ATM_HORIZON_DEBUG is not set
CONFIG_ATM_IA=y
# CONFIG_ATM_IA_DEBUG is not set
CONFIG_ATM_FORE200E=y
# CONFIG_ATM_FORE200E_USE_TASKLET is not set
CONFIG_ATM_FORE200E_TX_RETRY=16
CONFIG_ATM_FORE200E_DEBUG=0
CONFIG_ATM_HE=y
CONFIG_ATM_HE_USE_SUNI=y
CONFIG_ATM_SOLOS=y

#
# CAIF transport drivers
#
CONFIG_ETHERNET=y
CONFIG_MDIO=y
CONFIG_NET_VENDOR_3COM=y
# CONFIG_PCMCIA_3C574 is not set
# CONFIG_PCMCIA_3C589 is not set
# CONFIG_VORTEX is not set
# CONFIG_TYPHOON is not set
CONFIG_NET_VENDOR_ADAPTEC=y
# CONFIG_ADAPTEC_STARFIRE is not set
CONFIG_NET_VENDOR_ALTEON=y
CONFIG_ACENIC=y
# CONFIG_ACENIC_OMIT_TIGON_I is not set
CONFIG_NET_VENDOR_AMD=y
# CONFIG_AMD8111_ETH is not set
# CONFIG_PCNET32 is not set
# CONFIG_PCMCIA_NMCLAN is not set
CONFIG_NET_VENDOR_ATHEROS=y
# CONFIG_ATL2 is not set
CONFIG_ATL1=y
CONFIG_ATL1E=y
CONFIG_ATL1C=y
CONFIG_NET_VENDOR_BROADCOM=y
# CONFIG_B44 is not set
CONFIG_BNX2=y
CONFIG_CNIC=y
CONFIG_TIGON3=y
CONFIG_BNX2X=y
CONFIG_NET_VENDOR_BROCADE=y
# CONFIG_BNA is not set
# CONFIG_NET_CALXEDA_XGMAC is not set
CONFIG_NET_VENDOR_CHELSIO=y
CONFIG_CHELSIO_T1=y
CONFIG_CHELSIO_T1_1G=y
CONFIG_CHELSIO_T3=y
CONFIG_CHELSIO_T4=y
# CONFIG_CHELSIO_T4VF is not set
CONFIG_NET_VENDOR_CISCO=y
CONFIG_ENIC=y
# CONFIG_DNET is not set
CONFIG_NET_VENDOR_DEC=y
# CONFIG_NET_TULIP is not set
CONFIG_NET_VENDOR_DLINK=y
# CONFIG_DE600 is not set
# CONFIG_DE620 is not set
CONFIG_DL2K=y
# CONFIG_SUNDANCE is not set
CONFIG_NET_VENDOR_EMULEX=y
CONFIG_BE2NET=y
CONFIG_NET_VENDOR_EXAR=y
CONFIG_S2IO=y
CONFIG_VXGE=y
# CONFIG_VXGE_DEBUG_TRACE_ALL is not set
CONFIG_NET_VENDOR_FUJITSU=y
# CONFIG_PCMCIA_FMVJ18X is not set
CONFIG_NET_VENDOR_HP=y
# CONFIG_HP100 is not set
CONFIG_NET_VENDOR_INTEL=y
# CONFIG_E100 is not set
CONFIG_E1000=y
CONFIG_E1000E=y
CONFIG_IGB=y
CONFIG_IGB_DCA=y
# CONFIG_IGB_PTP is not set
CONFIG_IGBVF=y
CONFIG_IXGB=y
CONFIG_IXGBE=y
CONFIG_IXGBE_HWMON=y
CONFIG_IXGBE_DCA=y
CONFIG_IXGBE_DCB=y
# CONFIG_IXGBE_PTP is not set
CONFIG_IXGBEVF=y
CONFIG_NET_VENDOR_I825XX=y
# CONFIG_ZNET is not set
CONFIG_IP1000=y
CONFIG_JME=y
CONFIG_NET_VENDOR_MARVELL=y
CONFIG_SKGE=y
CONFIG_SKGE_DEBUG=y
# CONFIG_SKGE_GENESIS is not set
CONFIG_SKY2=y
CONFIG_SKY2_DEBUG=y
CONFIG_NET_VENDOR_MELLANOX=y
CONFIG_MLX4_EN=y
CONFIG_MLX4_EN_DCB=y
CONFIG_MLX4_CORE=y
CONFIG_MLX4_DEBUG=y
CONFIG_NET_VENDOR_MICREL=y
# CONFIG_KS8842 is not set
# CONFIG_KS8851 is not set
# CONFIG_KS8851_MLL is not set
# CONFIG_KSZ884X_PCI is not set
CONFIG_NET_VENDOR_MICROCHIP=y
# CONFIG_ENC28J60 is not set
CONFIG_NET_VENDOR_MYRI=y
CONFIG_MYRI10GE=y
CONFIG_MYRI10GE_DCA=y
# CONFIG_FEALNX is not set
CONFIG_NET_VENDOR_NATSEMI=y
# CONFIG_NATSEMI is not set
CONFIG_NS83820=y
CONFIG_NET_VENDOR_8390=y
# CONFIG_PCMCIA_AXNET is not set
# CONFIG_NE2K_PCI is not set
# CONFIG_PCMCIA_PCNET is not set
CONFIG_NET_VENDOR_NVIDIA=y
# CONFIG_FORCEDETH is not set
CONFIG_NET_VENDOR_OKI=y
# CONFIG_PCH_GBE is not set
# CONFIG_ETHOC is not set
CONFIG_NET_PACKET_ENGINE=y
CONFIG_HAMACHI=y
CONFIG_YELLOWFIN=y
CONFIG_NET_VENDOR_QLOGIC=y
CONFIG_QLA3XXX=y
CONFIG_QLCNIC=y
CONFIG_QLGE=y
CONFIG_NETXEN_NIC=y
CONFIG_NET_VENDOR_REALTEK=y
# CONFIG_ATP is not set
# CONFIG_8139CP is not set
# CONFIG_8139TOO is not set
CONFIG_R8169=y
CONFIG_NET_VENDOR_RDC=y
# CONFIG_R6040 is not set
CONFIG_NET_VENDOR_SEEQ=y
# CONFIG_SEEQ8005 is not set
CONFIG_NET_VENDOR_SILAN=y
# CONFIG_SC92031 is not set
CONFIG_NET_VENDOR_SIS=y
# CONFIG_SIS900 is not set
CONFIG_SIS190=y
CONFIG_SFC=y
CONFIG_SFC_MTD=y
CONFIG_SFC_MCDI_MON=y
CONFIG_SFC_SRIOV=y
CONFIG_NET_VENDOR_SMSC=y
# CONFIG_PCMCIA_SMC91C92 is not set
# CONFIG_EPIC100 is not set
# CONFIG_SMSC9420 is not set
CONFIG_NET_VENDOR_STMICRO=y
# CONFIG_STMMAC_ETH is not set
CONFIG_NET_VENDOR_SUN=y
# CONFIG_HAPPYMEAL is not set
# CONFIG_SUNGEM is not set
# CONFIG_CASSINI is not set
CONFIG_NIU=y
CONFIG_NET_VENDOR_TEHUTI=y
CONFIG_TEHUTI=y
CONFIG_NET_VENDOR_TI=y
# CONFIG_TLAN is not set
CONFIG_NET_VENDOR_VIA=y
# CONFIG_VIA_RHINE is not set
CONFIG_VIA_VELOCITY=y
CONFIG_NET_VENDOR_WIZNET=y
# CONFIG_WIZNET_W5100 is not set
# CONFIG_WIZNET_W5300 is not set
CONFIG_NET_VENDOR_XIRCOM=y
# CONFIG_PCMCIA_XIRC2PS is not set
CONFIG_FDDI=y
CONFIG_DEFXX=y
# CONFIG_DEFXX_MMIO is not set
CONFIG_SKFP=y
CONFIG_HIPPI=y
CONFIG_ROADRUNNER=y
# CONFIG_ROADRUNNER_LARGE_RINGS is not set
CONFIG_NET_SB1000=y
CONFIG_PHYLIB=y

#
# MII PHY device drivers
#
# CONFIG_AMD_PHY is not set
CONFIG_MARVELL_PHY=y
CONFIG_DAVICOM_PHY=y
CONFIG_QSEMI_PHY=y
CONFIG_LXT_PHY=y
CONFIG_CICADA_PHY=y
CONFIG_VITESSE_PHY=y
CONFIG_SMSC_PHY=y
CONFIG_BROADCOM_PHY=y
# CONFIG_BCM87XX_PHY is not set
CONFIG_ICPLUS_PHY=y
CONFIG_REALTEK_PHY=y
CONFIG_NATIONAL_PHY=y
CONFIG_STE10XP=y
CONFIG_LSI_ET1011C_PHY=y
CONFIG_MICREL_PHY=y
# CONFIG_FIXED_PHY is not set
CONFIG_MDIO_BITBANG=y
# CONFIG_MDIO_GPIO is not set
# CONFIG_MICREL_KS8995MA is not set
CONFIG_PLIP=y
CONFIG_PPP=y
CONFIG_PPP_BSDCOMP=y
CONFIG_PPP_DEFLATE=y
CONFIG_PPP_FILTER=y
CONFIG_PPP_MPPE=y
CONFIG_PPP_MULTILINK=y
CONFIG_PPPOATM=y
CONFIG_PPPOE=y
CONFIG_PPPOL2TP=y
CONFIG_PPP_ASYNC=y
CONFIG_PPP_SYNC_TTY=y
CONFIG_SLIP=y
CONFIG_SLHC=y
CONFIG_SLIP_COMPRESSED=y
CONFIG_SLIP_SMART=y
CONFIG_SLIP_MODE_SLIP6=y
CONFIG_WLAN=y
CONFIG_PCMCIA_RAYCS=y
CONFIG_LIBERTAS_THINFIRM=y
# CONFIG_LIBERTAS_THINFIRM_DEBUG is not set
CONFIG_AIRO=y
CONFIG_ATMEL=y
CONFIG_PCI_ATMEL=y
CONFIG_PCMCIA_ATMEL=y
CONFIG_AIRO_CS=y
CONFIG_PCMCIA_WL3501=y
# CONFIG_PRISM54 is not set
CONFIG_RTL8180=y
CONFIG_ADM8211=y
CONFIG_MAC80211_HWSIM=y
CONFIG_MWL8K=y
CONFIG_ATH_COMMON=y
# CONFIG_ATH_DEBUG is not set
CONFIG_ATH5K=y
# CONFIG_ATH5K_DEBUG is not set
# CONFIG_ATH5K_TRACER is not set
CONFIG_ATH5K_PCI=y
CONFIG_ATH9K_HW=y
CONFIG_ATH9K_COMMON=y
CONFIG_ATH9K_BTCOEX_SUPPORT=y
CONFIG_ATH9K=y
CONFIG_ATH9K_PCI=y
# CONFIG_ATH9K_AHB is not set
# CONFIG_ATH9K_DEBUGFS is not set
CONFIG_ATH9K_RATE_CONTROL=y
# CONFIG_ATH6KL is not set
CONFIG_B43=y
CONFIG_B43_SSB=y
CONFIG_B43_PCI_AUTOSELECT=y
CONFIG_B43_PCICORE_AUTOSELECT=y
CONFIG_B43_PCMCIA=y
CONFIG_B43_SDIO=y
CONFIG_B43_PIO=y
# CONFIG_B43_PHY_N is not set
CONFIG_B43_PHY_LP=y
# CONFIG_B43_PHY_HT is not set
CONFIG_B43_LEDS=y
CONFIG_B43_HWRNG=y
# CONFIG_B43_DEBUG is not set
CONFIG_B43LEGACY=y
CONFIG_B43LEGACY_PCI_AUTOSELECT=y
CONFIG_B43LEGACY_PCICORE_AUTOSELECT=y
CONFIG_B43LEGACY_LEDS=y
CONFIG_B43LEGACY_HWRNG=y
CONFIG_B43LEGACY_DEBUG=y
CONFIG_B43LEGACY_DMA=y
CONFIG_B43LEGACY_PIO=y
CONFIG_B43LEGACY_DMA_AND_PIO_MODE=y
# CONFIG_B43LEGACY_DMA_MODE is not set
# CONFIG_B43LEGACY_PIO_MODE is not set
# CONFIG_BRCMFMAC is not set
CONFIG_HOSTAP=y
CONFIG_HOSTAP_FIRMWARE=y
# CONFIG_HOSTAP_FIRMWARE_NVRAM is not set
CONFIG_HOSTAP_PLX=y
CONFIG_HOSTAP_PCI=y
CONFIG_HOSTAP_CS=y
# CONFIG_IPW2100 is not set
CONFIG_IPW2200=y
CONFIG_IPW2200_MONITOR=y
CONFIG_IPW2200_RADIOTAP=y
CONFIG_IPW2200_PROMISCUOUS=y
CONFIG_IPW2200_QOS=y
# CONFIG_IPW2200_DEBUG is not set
CONFIG_LIBIPW=y
# CONFIG_LIBIPW_DEBUG is not set
CONFIG_IWLWIFI=y
CONFIG_IWLDVM=y

#
# Debugging Options
#
# CONFIG_IWLWIFI_DEBUG is not set
# CONFIG_IWLWIFI_DEVICE_TRACING is not set
CONFIG_IWLWIFI_P2P=y
# CONFIG_IWLWIFI_EXPERIMENTAL_MFP is not set
CONFIG_IWLEGACY=y
# CONFIG_IWL4965 is not set
CONFIG_IWL3945=y

#
# iwl3945 / iwl4965 Debugging Options
#
# CONFIG_IWLEGACY_DEBUG is not set
CONFIG_LIBERTAS=y
CONFIG_LIBERTAS_CS=y
CONFIG_LIBERTAS_SDIO=y
CONFIG_LIBERTAS_SPI=y
# CONFIG_LIBERTAS_DEBUG is not set
CONFIG_LIBERTAS_MESH=y
CONFIG_HERMES=y
# CONFIG_HERMES_PRISM is not set
CONFIG_HERMES_CACHE_FW_ON_INIT=y
CONFIG_PLX_HERMES=y
CONFIG_TMD_HERMES=y
CONFIG_NORTEL_HERMES=y
CONFIG_PCMCIA_HERMES=y
CONFIG_PCMCIA_SPECTRUM=y
CONFIG_P54_COMMON=y
CONFIG_P54_PCI=y
CONFIG_P54_SPI=y
# CONFIG_P54_SPI_DEFAULT_EEPROM is not set
CONFIG_P54_LEDS=y
CONFIG_RT2X00=y
CONFIG_RT2400PCI=y
CONFIG_RT2500PCI=y
CONFIG_RT61PCI=y
CONFIG_RT2800PCI=y
CONFIG_RT2800PCI_RT33XX=y
CONFIG_RT2800PCI_RT35XX=y
CONFIG_RT2800PCI_RT53XX=y
CONFIG_RT2800PCI_RT3290=y
CONFIG_RT2800_LIB=y
CONFIG_RT2X00_LIB_PCI=y
CONFIG_RT2X00_LIB=y
CONFIG_RT2X00_LIB_FIRMWARE=y
CONFIG_RT2X00_LIB_CRYPTO=y
CONFIG_RT2X00_LIB_LEDS=y
# CONFIG_RT2X00_DEBUG is not set
# CONFIG_RTL8192CE is not set
# CONFIG_RTL8192SE is not set
# CONFIG_RTL8192DE is not set
# CONFIG_WL_TI is not set
# CONFIG_MWIFIEX is not set

#
# WiMAX Wireless Broadband devices
#

#
# Enable USB support to see WiMAX USB drivers
#
CONFIG_WAN=y
CONFIG_LANMEDIA=y
CONFIG_HDLC=y
CONFIG_HDLC_RAW=y
CONFIG_HDLC_RAW_ETH=y
CONFIG_HDLC_CISCO=y
CONFIG_HDLC_FR=y
CONFIG_HDLC_PPP=y
# CONFIG_HDLC_X25 is not set
CONFIG_PCI200SYN=y
CONFIG_WANXL=y
# CONFIG_PC300TOO is not set
CONFIG_FARSYNC=y
CONFIG_DSCC4=m
CONFIG_DSCC4_PCISYNC=y
CONFIG_DSCC4_PCI_RST=y
CONFIG_DLCI=y
CONFIG_DLCI_MAX=8
CONFIG_WAN_ROUTER_DRIVERS=y
CONFIG_CYCLADES_SYNC=y
# CONFIG_CYCLOMX_X25 is not set
CONFIG_SBNI=y
# CONFIG_SBNI_MULTILINE is not set
CONFIG_IEEE802154_DRIVERS=y
CONFIG_IEEE802154_FAKEHARD=y
CONFIG_XEN_NETDEV_FRONTEND=y
# CONFIG_XEN_NETDEV_BACKEND is not set
CONFIG_VMXNET3=y
CONFIG_ISDN=y
# CONFIG_ISDN_I4L is not set
CONFIG_ISDN_CAPI=y
CONFIG_ISDN_DRV_AVMB1_VERBOSE_REASON=y
CONFIG_CAPI_TRACE=y
CONFIG_ISDN_CAPI_MIDDLEWARE=y
CONFIG_ISDN_CAPI_CAPI20=y

#
# CAPI hardware drivers
#
CONFIG_CAPI_AVM=y
CONFIG_ISDN_DRV_AVMB1_B1PCI=y
CONFIG_ISDN_DRV_AVMB1_B1PCIV4=y
CONFIG_ISDN_DRV_AVMB1_B1PCMCIA=y
CONFIG_ISDN_DRV_AVMB1_AVM_CS=y
CONFIG_ISDN_DRV_AVMB1_T1PCI=y
CONFIG_ISDN_DRV_AVMB1_C4=y
# CONFIG_CAPI_EICON is not set
CONFIG_ISDN_DRV_GIGASET=y
CONFIG_GIGASET_CAPI=y
# CONFIG_GIGASET_DUMMYLL is not set
CONFIG_GIGASET_M101=y
# CONFIG_GIGASET_DEBUG is not set
CONFIG_HYSDN=m
CONFIG_HYSDN_CAPI=y
CONFIG_MISDN=y
CONFIG_MISDN_DSP=y
CONFIG_MISDN_L1OIP=y

#
# mISDN hardware drivers
#
CONFIG_MISDN_HFCPCI=y
CONFIG_MISDN_HFCMULTI=y
CONFIG_MISDN_AVMFRITZ=y
CONFIG_MISDN_SPEEDFAX=y
CONFIG_MISDN_INFINEON=y
CONFIG_MISDN_W6692=y
# CONFIG_MISDN_NETJET is not set
CONFIG_MISDN_IPAC=y
CONFIG_MISDN_ISAR=y

#
# Input device support
#
CONFIG_INPUT=y
CONFIG_INPUT_FF_MEMLESS=y
CONFIG_INPUT_POLLDEV=y
CONFIG_INPUT_SPARSEKMAP=y
# CONFIG_INPUT_MATRIXKMAP is not set

#
# Userland interfaces
#
CONFIG_INPUT_MOUSEDEV=y
CONFIG_INPUT_MOUSEDEV_PSAUX=y
CONFIG_INPUT_MOUSEDEV_SCREEN_X=1024
CONFIG_INPUT_MOUSEDEV_SCREEN_Y=768
CONFIG_INPUT_JOYDEV=y
CONFIG_INPUT_EVDEV=y
# CONFIG_INPUT_EVBUG is not set

#
# Input Device Drivers
#
CONFIG_INPUT_KEYBOARD=y
CONFIG_KEYBOARD_ADP5588=y
# CONFIG_KEYBOARD_ADP5589 is not set
CONFIG_KEYBOARD_ATKBD=y
# CONFIG_KEYBOARD_QT1070 is not set
CONFIG_KEYBOARD_QT2160=y
CONFIG_KEYBOARD_LKKBD=y
# CONFIG_KEYBOARD_GPIO is not set
# CONFIG_KEYBOARD_GPIO_POLLED is not set
# CONFIG_KEYBOARD_TCA6416 is not set
# CONFIG_KEYBOARD_TCA8418 is not set
# CONFIG_KEYBOARD_MATRIX is not set
CONFIG_KEYBOARD_LM8323=y
# CONFIG_KEYBOARD_LM8333 is not set
CONFIG_KEYBOARD_MAX7359=y
# CONFIG_KEYBOARD_MCS is not set
# CONFIG_KEYBOARD_MPR121 is not set
CONFIG_KEYBOARD_NEWTON=y
CONFIG_KEYBOARD_OPENCORES=y
CONFIG_KEYBOARD_STOWAWAY=y
CONFIG_KEYBOARD_SUNKBD=y
# CONFIG_KEYBOARD_OMAP4 is not set
CONFIG_KEYBOARD_XTKBD=y
CONFIG_INPUT_MOUSE=y
CONFIG_MOUSE_PS2=y
CONFIG_MOUSE_PS2_ALPS=y
CONFIG_MOUSE_PS2_LOGIPS2PP=y
CONFIG_MOUSE_PS2_SYNAPTICS=y
CONFIG_MOUSE_PS2_LIFEBOOK=y
CONFIG_MOUSE_PS2_TRACKPOINT=y
CONFIG_MOUSE_PS2_ELANTECH=y
CONFIG_MOUSE_PS2_SENTELIC=y
# CONFIG_MOUSE_PS2_TOUCHKIT is not set
CONFIG_MOUSE_SERIAL=y
# CONFIG_MOUSE_APPLETOUCH is not set
# CONFIG_MOUSE_BCM5974 is not set
CONFIG_MOUSE_VSXXXAA=y
# CONFIG_MOUSE_GPIO is not set
CONFIG_MOUSE_SYNAPTICS_I2C=y
# CONFIG_MOUSE_SYNAPTICS_USB is not set
CONFIG_INPUT_JOYSTICK=y
CONFIG_JOYSTICK_ANALOG=y
CONFIG_JOYSTICK_A3D=y
CONFIG_JOYSTICK_ADI=y
CONFIG_JOYSTICK_COBRA=y
CONFIG_JOYSTICK_GF2K=y
CONFIG_JOYSTICK_GRIP=y
CONFIG_JOYSTICK_GRIP_MP=y
CONFIG_JOYSTICK_GUILLEMOT=y
CONFIG_JOYSTICK_INTERACT=y
CONFIG_JOYSTICK_SIDEWINDER=y
CONFIG_JOYSTICK_TMDC=y
CONFIG_JOYSTICK_IFORCE=y
CONFIG_JOYSTICK_IFORCE_232=y
CONFIG_JOYSTICK_WARRIOR=y
CONFIG_JOYSTICK_MAGELLAN=y
CONFIG_JOYSTICK_SPACEORB=y
CONFIG_JOYSTICK_SPACEBALL=y
CONFIG_JOYSTICK_STINGER=y
CONFIG_JOYSTICK_TWIDJOY=y
CONFIG_JOYSTICK_ZHENHUA=y
CONFIG_JOYSTICK_DB9=y
CONFIG_JOYSTICK_GAMECON=y
CONFIG_JOYSTICK_TURBOGRAFX=y
# CONFIG_JOYSTICK_AS5011 is not set
CONFIG_JOYSTICK_JOYDUMP=y
# CONFIG_JOYSTICK_XPAD is not set
CONFIG_JOYSTICK_WALKERA0701=y
CONFIG_INPUT_TABLET=y
# CONFIG_TABLET_USB_ACECAD is not set
# CONFIG_TABLET_USB_AIPTEK is not set
# CONFIG_TABLET_USB_HANWANG is not set
# CONFIG_TABLET_USB_KBTAB is not set
# CONFIG_TABLET_USB_WACOM is not set
CONFIG_INPUT_TOUCHSCREEN=y
CONFIG_TOUCHSCREEN_ADS7846=y
CONFIG_TOUCHSCREEN_AD7877=y
CONFIG_TOUCHSCREEN_AD7879=y
CONFIG_TOUCHSCREEN_AD7879_I2C=y
# CONFIG_TOUCHSCREEN_AD7879_SPI is not set
# CONFIG_TOUCHSCREEN_ATMEL_MXT is not set
# CONFIG_TOUCHSCREEN_AUO_PIXCIR is not set
# CONFIG_TOUCHSCREEN_BU21013 is not set
# CONFIG_TOUCHSCREEN_CY8CTMG110 is not set
# CONFIG_TOUCHSCREEN_CYTTSP_CORE is not set
CONFIG_TOUCHSCREEN_DYNAPRO=y
CONFIG_TOUCHSCREEN_HAMPSHIRE=y
CONFIG_TOUCHSCREEN_EETI=y
# CONFIG_TOUCHSCREEN_EGALAX is not set
CONFIG_TOUCHSCREEN_FUJITSU=y
# CONFIG_TOUCHSCREEN_ILI210X is not set
CONFIG_TOUCHSCREEN_GUNZE=y
CONFIG_TOUCHSCREEN_ELO=y
CONFIG_TOUCHSCREEN_WACOM_W8001=y
# CONFIG_TOUCHSCREEN_WACOM_I2C is not set
# CONFIG_TOUCHSCREEN_MAX11801 is not set
CONFIG_TOUCHSCREEN_MCS5000=y
# CONFIG_TOUCHSCREEN_MMS114 is not set
CONFIG_TOUCHSCREEN_MTOUCH=y
CONFIG_TOUCHSCREEN_INEXIO=y
CONFIG_TOUCHSCREEN_MK712=y
CONFIG_TOUCHSCREEN_PENMOUNT=y
# CONFIG_TOUCHSCREEN_EDT_FT5X06 is not set
CONFIG_TOUCHSCREEN_TOUCHRIGHT=y
CONFIG_TOUCHSCREEN_TOUCHWIN=y
# CONFIG_TOUCHSCREEN_PIXCIR is not set
CONFIG_TOUCHSCREEN_WM97XX=y
CONFIG_TOUCHSCREEN_WM9705=y
CONFIG_TOUCHSCREEN_WM9712=y
CONFIG_TOUCHSCREEN_WM9713=y
# CONFIG_TOUCHSCREEN_USB_COMPOSITE is not set
CONFIG_TOUCHSCREEN_TOUCHIT213=y
# CONFIG_TOUCHSCREEN_TSC_SERIO is not set
# CONFIG_TOUCHSCREEN_TSC2005 is not set
CONFIG_TOUCHSCREEN_TSC2007=y
# CONFIG_TOUCHSCREEN_ST1232 is not set
CONFIG_TOUCHSCREEN_TPS6507X=y
CONFIG_INPUT_MISC=y
# CONFIG_INPUT_AD714X is not set
# CONFIG_INPUT_BMA150 is not set
CONFIG_INPUT_PCSPKR=y
# CONFIG_INPUT_MMA8450 is not set
# CONFIG_INPUT_MPU3050 is not set
CONFIG_INPUT_APANEL=y
# CONFIG_INPUT_GP2A is not set
# CONFIG_INPUT_GPIO_TILT_POLLED is not set
CONFIG_INPUT_ATLAS_BTNS=y
# CONFIG_INPUT_ATI_REMOTE2 is not set
# CONFIG_INPUT_KEYSPAN_REMOTE is not set
# CONFIG_INPUT_KXTJ9 is not set
# CONFIG_INPUT_POWERMATE is not set
# CONFIG_INPUT_YEALINK is not set
# CONFIG_INPUT_CM109 is not set
CONFIG_INPUT_UINPUT=y
CONFIG_INPUT_PCF50633_PMU=y
# CONFIG_INPUT_PCF8574 is not set
# CONFIG_INPUT_GPIO_ROTARY_ENCODER is not set
# CONFIG_INPUT_ADXL34X is not set
# CONFIG_INPUT_CMA3000 is not set
CONFIG_INPUT_XEN_KBDDEV_FRONTEND=y

#
# Hardware I/O ports
#
CONFIG_SERIO=y
CONFIG_SERIO_I8042=y
CONFIG_SERIO_SERPORT=y
CONFIG_SERIO_CT82C710=y
CONFIG_SERIO_PARKBD=y
CONFIG_SERIO_PCIPS2=y
CONFIG_SERIO_LIBPS2=y
CONFIG_SERIO_RAW=y
CONFIG_SERIO_ALTERA_PS2=y
# CONFIG_SERIO_PS2MULT is not set
CONFIG_GAMEPORT=y
CONFIG_GAMEPORT_NS558=y
CONFIG_GAMEPORT_L4=y
CONFIG_GAMEPORT_EMU10K1=y
CONFIG_GAMEPORT_FM801=y

#
# Character devices
#
CONFIG_VT=y
CONFIG_CONSOLE_TRANSLATIONS=y
CONFIG_VT_CONSOLE=y
CONFIG_VT_CONSOLE_SLEEP=y
CONFIG_HW_CONSOLE=y
CONFIG_VT_HW_CONSOLE_BINDING=y
CONFIG_UNIX98_PTYS=y
# CONFIG_DEVPTS_MULTIPLE_INSTANCES is not set
# CONFIG_LEGACY_PTYS is not set
CONFIG_SERIAL_NONSTANDARD=y
CONFIG_ROCKETPORT=y
CONFIG_CYCLADES=y
# CONFIG_CYZ_INTR is not set
CONFIG_MOXA_INTELLIO=y
CONFIG_MOXA_SMARTIO=y
CONFIG_SYNCLINK=y
CONFIG_SYNCLINKMP=y
CONFIG_SYNCLINK_GT=y
CONFIG_NOZOMI=y
CONFIG_ISI=y
CONFIG_N_HDLC=y
CONFIG_N_GSM=y
# CONFIG_TRACE_SINK is not set
# CONFIG_DEVKMEM is not set
CONFIG_STALDRV=y

#
# Serial drivers
#
CONFIG_SERIAL_8250=y
CONFIG_SERIAL_8250_CONSOLE=y
CONFIG_FIX_EARLYCON_MEM=y
CONFIG_SERIAL_8250_PCI=y
CONFIG_SERIAL_8250_PNP=y
CONFIG_SERIAL_8250_CS=y
CONFIG_SERIAL_8250_NR_UARTS=32
CONFIG_SERIAL_8250_RUNTIME_UARTS=4
CONFIG_SERIAL_8250_EXTENDED=y
CONFIG_SERIAL_8250_MANY_PORTS=y
CONFIG_SERIAL_8250_SHARE_IRQ=y
# CONFIG_SERIAL_8250_DETECT_IRQ is not set
CONFIG_SERIAL_8250_RSA=y

#
# Non-8250 serial port support
#
CONFIG_SERIAL_MAX3100=y
# CONFIG_SERIAL_MAX3107 is not set
# CONFIG_SERIAL_MFD_HSU is not set
CONFIG_SERIAL_CORE=y
CONFIG_SERIAL_CORE_CONSOLE=y
CONFIG_SERIAL_JSM=y
# CONFIG_SERIAL_TIMBERDALE is not set
# CONFIG_SERIAL_ALTERA_JTAGUART is not set
# CONFIG_SERIAL_ALTERA_UART is not set
# CONFIG_SERIAL_IFX6X60 is not set
# CONFIG_SERIAL_PCH_UART is not set
# CONFIG_SERIAL_XILINX_PS_UART is not set
CONFIG_PRINTER=y
# CONFIG_LP_CONSOLE is not set
CONFIG_PPDEV=y
CONFIG_HVC_DRIVER=y
CONFIG_HVC_IRQ=y
CONFIG_HVC_XEN=y
CONFIG_HVC_XEN_FRONTEND=y
CONFIG_VIRTIO_CONSOLE=y
CONFIG_IPMI_HANDLER=y
# CONFIG_IPMI_PANIC_EVENT is not set
CONFIG_IPMI_DEVICE_INTERFACE=y
CONFIG_IPMI_SI=y
CONFIG_IPMI_WATCHDOG=y
CONFIG_IPMI_POWEROFF=y
CONFIG_HW_RANDOM=y
CONFIG_HW_RANDOM_TIMERIOMEM=y
CONFIG_HW_RANDOM_INTEL=y
CONFIG_HW_RANDOM_AMD=y
CONFIG_HW_RANDOM_VIA=y
CONFIG_HW_RANDOM_VIRTIO=y
CONFIG_NVRAM=y
CONFIG_R3964=y
CONFIG_APPLICOM=y

#
# PCMCIA character devices
#
CONFIG_SYNCLINK_CS=y
CONFIG_CARDMAN_4000=y
CONFIG_CARDMAN_4040=y
CONFIG_IPWIRELESS=y
CONFIG_MWAVE=y
CONFIG_RAW_DRIVER=y
CONFIG_MAX_RAW_DEVS=256
CONFIG_HPET=y
CONFIG_HPET_MMAP=y
CONFIG_HANGCHECK_TIMER=y
CONFIG_TCG_TPM=y
CONFIG_TCG_TIS=y
CONFIG_TCG_NSC=y
CONFIG_TCG_ATMEL=y
CONFIG_TCG_INFINEON=y
CONFIG_TELCLOCK=y
CONFIG_DEVPORT=y
CONFIG_I2C=y
CONFIG_I2C_BOARDINFO=y
CONFIG_I2C_COMPAT=y
CONFIG_I2C_CHARDEV=y
# CONFIG_I2C_MUX is not set
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
CONFIG_I2C_ALI1535=y
CONFIG_I2C_ALI1563=y
CONFIG_I2C_ALI15X3=y
CONFIG_I2C_AMD756=y
CONFIG_I2C_AMD756_S4882=y
CONFIG_I2C_AMD8111=y
CONFIG_I2C_I801=y
CONFIG_I2C_ISCH=y
CONFIG_I2C_PIIX4=y
CONFIG_I2C_NFORCE2=y
CONFIG_I2C_NFORCE2_S4985=y
CONFIG_I2C_SIS5595=y
CONFIG_I2C_SIS630=y
CONFIG_I2C_SIS96X=y
CONFIG_I2C_VIA=y
CONFIG_I2C_VIAPRO=y

#
# ACPI drivers
#
CONFIG_I2C_SCMI=y

#
# I2C system bus drivers (mostly embedded / system-on-chip)
#
# CONFIG_I2C_DESIGNWARE_PCI is not set
# CONFIG_I2C_EG20T is not set
# CONFIG_I2C_GPIO is not set
# CONFIG_I2C_INTEL_MID is not set
CONFIG_I2C_OCORES=y
CONFIG_I2C_PCA_PLATFORM=y
# CONFIG_I2C_PXA_PCI is not set
CONFIG_I2C_SIMTEC=y
# CONFIG_I2C_XILINX is not set

#
# External I2C/SMBus adapter drivers
#
CONFIG_I2C_PARPORT=y
CONFIG_I2C_PARPORT_LIGHT=y
CONFIG_I2C_TAOS_EVM=y

#
# Other I2C/SMBus bus drivers
#
CONFIG_I2C_STUB=m
# CONFIG_I2C_DEBUG_CORE is not set
# CONFIG_I2C_DEBUG_ALGO is not set
# CONFIG_I2C_DEBUG_BUS is not set
CONFIG_SPI=y
# CONFIG_SPI_DEBUG is not set
CONFIG_SPI_MASTER=y

#
# SPI Master Controller Drivers
#
# CONFIG_SPI_ALTERA is not set
CONFIG_SPI_BITBANG=y
CONFIG_SPI_BUTTERFLY=y
# CONFIG_SPI_GPIO is not set
CONFIG_SPI_LM70_LLP=y
# CONFIG_SPI_OC_TINY is not set
# CONFIG_SPI_PXA2XX_PCI is not set
# CONFIG_SPI_TOPCLIFF_PCH is not set
# CONFIG_SPI_XCOMM is not set
# CONFIG_SPI_XILINX is not set
# CONFIG_SPI_DESIGNWARE is not set

#
# SPI Protocol Masters
#
# CONFIG_SPI_SPIDEV is not set
CONFIG_SPI_TLE62X0=y
# CONFIG_HSI is not set

#
# PPS support
#
CONFIG_PPS=y
# CONFIG_PPS_DEBUG is not set

#
# PPS clients support
#
# CONFIG_PPS_CLIENT_KTIMER is not set
CONFIG_PPS_CLIENT_LDISC=y
# CONFIG_PPS_CLIENT_PARPORT is not set
# CONFIG_PPS_CLIENT_GPIO is not set

#
# PPS generators support
#

#
# PTP clock support
#
# CONFIG_PTP_1588_CLOCK is not set
CONFIG_ARCH_WANT_OPTIONAL_GPIOLIB=y
CONFIG_GPIOLIB=y
# CONFIG_DEBUG_GPIO is not set
# CONFIG_GPIO_SYSFS is not set

#
# Memory mapped GPIO drivers:
#
# CONFIG_GPIO_GENERIC_PLATFORM is not set
# CONFIG_GPIO_IT8761E is not set
# CONFIG_GPIO_SCH is not set
# CONFIG_GPIO_ICH is not set
# CONFIG_GPIO_VX855 is not set

#
# I2C GPIO expanders:
#
# CONFIG_GPIO_MAX7300 is not set
# CONFIG_GPIO_MAX732X is not set
# CONFIG_GPIO_PCA953X is not set
# CONFIG_GPIO_PCF857X is not set
# CONFIG_GPIO_SX150X is not set
# CONFIG_GPIO_ADP5588 is not set

#
# PCI GPIO expanders:
#
# CONFIG_GPIO_BT8XX is not set
# CONFIG_GPIO_AMD8111 is not set
# CONFIG_GPIO_LANGWELL is not set
# CONFIG_GPIO_PCH is not set
# CONFIG_GPIO_ML_IOH is not set
# CONFIG_GPIO_RDC321X is not set

#
# SPI GPIO expanders:
#
# CONFIG_GPIO_MAX7301 is not set
# CONFIG_GPIO_MCP23S08 is not set
# CONFIG_GPIO_MC33880 is not set
# CONFIG_GPIO_74X164 is not set

#
# AC97 GPIO expanders:
#

#
# MODULbus GPIO expanders:
#
CONFIG_W1=y
CONFIG_W1_CON=y

#
# 1-wire Bus Masters
#
CONFIG_W1_MASTER_MATROX=y
CONFIG_W1_MASTER_DS2482=y
# CONFIG_W1_MASTER_DS1WM is not set
# CONFIG_W1_MASTER_GPIO is not set

#
# 1-wire Slaves
#
CONFIG_W1_SLAVE_THERM=y
CONFIG_W1_SLAVE_SMEM=y
# CONFIG_W1_SLAVE_DS2408 is not set
# CONFIG_W1_SLAVE_DS2423 is not set
CONFIG_W1_SLAVE_DS2431=y
CONFIG_W1_SLAVE_DS2433=y
# CONFIG_W1_SLAVE_DS2433_CRC is not set
CONFIG_W1_SLAVE_DS2760=y
# CONFIG_W1_SLAVE_DS2780 is not set
# CONFIG_W1_SLAVE_DS2781 is not set
# CONFIG_W1_SLAVE_DS28E04 is not set
CONFIG_W1_SLAVE_BQ27000=y
CONFIG_POWER_SUPPLY=y
# CONFIG_POWER_SUPPLY_DEBUG is not set
CONFIG_PDA_POWER=y
# CONFIG_TEST_POWER is not set
CONFIG_BATTERY_DS2760=y
# CONFIG_BATTERY_DS2780 is not set
# CONFIG_BATTERY_DS2781 is not set
CONFIG_BATTERY_DS2782=y
# CONFIG_BATTERY_WM97XX is not set
# CONFIG_BATTERY_SBS is not set
CONFIG_BATTERY_BQ27x00=y
CONFIG_BATTERY_BQ27X00_I2C=y
CONFIG_BATTERY_BQ27X00_PLATFORM=y
CONFIG_BATTERY_MAX17040=y
# CONFIG_BATTERY_MAX17042 is not set
CONFIG_CHARGER_PCF50633=y
# CONFIG_CHARGER_ISP1704 is not set
# CONFIG_CHARGER_MAX8903 is not set
# CONFIG_CHARGER_LP8727 is not set
# CONFIG_CHARGER_GPIO is not set
# CONFIG_CHARGER_MANAGER is not set
# CONFIG_CHARGER_SMB347 is not set
# CONFIG_POWER_AVS is not set
CONFIG_HWMON=y
CONFIG_HWMON_VID=y
# CONFIG_HWMON_DEBUG_CHIP is not set

#
# Native drivers
#
CONFIG_SENSORS_ABITUGURU=y
CONFIG_SENSORS_ABITUGURU3=y
# CONFIG_SENSORS_AD7314 is not set
CONFIG_SENSORS_AD7414=y
CONFIG_SENSORS_AD7418=y
CONFIG_SENSORS_ADCXX=y
CONFIG_SENSORS_ADM1021=y
CONFIG_SENSORS_ADM1025=y
CONFIG_SENSORS_ADM1026=y
CONFIG_SENSORS_ADM1029=y
CONFIG_SENSORS_ADM1031=y
CONFIG_SENSORS_ADM9240=y
CONFIG_SENSORS_ADT7411=y
CONFIG_SENSORS_ADT7462=y
CONFIG_SENSORS_ADT7470=y
CONFIG_SENSORS_ADT7475=y
CONFIG_SENSORS_ASC7621=y
CONFIG_SENSORS_K8TEMP=y
CONFIG_SENSORS_K10TEMP=y
# CONFIG_SENSORS_FAM15H_POWER is not set
CONFIG_SENSORS_ASB100=y
CONFIG_SENSORS_ATXP1=y
# CONFIG_SENSORS_DS620 is not set
CONFIG_SENSORS_DS1621=y
CONFIG_SENSORS_I5K_AMB=y
CONFIG_SENSORS_F71805F=y
CONFIG_SENSORS_F71882FG=y
CONFIG_SENSORS_F75375S=y
CONFIG_SENSORS_FSCHMD=y
CONFIG_SENSORS_G760A=y
CONFIG_SENSORS_GL518SM=y
CONFIG_SENSORS_GL520SM=y
# CONFIG_SENSORS_GPIO_FAN is not set
# CONFIG_SENSORS_HIH6130 is not set
CONFIG_SENSORS_CORETEMP=y
CONFIG_SENSORS_IBMAEM=y
CONFIG_SENSORS_IBMPEX=y
CONFIG_SENSORS_IT87=y
# CONFIG_SENSORS_JC42 is not set
# CONFIG_SENSORS_LINEAGE is not set
CONFIG_SENSORS_LM63=y
CONFIG_SENSORS_LM70=y
CONFIG_SENSORS_LM73=y
CONFIG_SENSORS_LM75=y
CONFIG_SENSORS_LM77=y
CONFIG_SENSORS_LM78=y
CONFIG_SENSORS_LM80=y
CONFIG_SENSORS_LM83=y
CONFIG_SENSORS_LM85=y
CONFIG_SENSORS_LM87=y
CONFIG_SENSORS_LM90=y
CONFIG_SENSORS_LM92=y
CONFIG_SENSORS_LM93=y
# CONFIG_SENSORS_LTC4151 is not set
CONFIG_SENSORS_LTC4215=y
CONFIG_SENSORS_LTC4245=y
# CONFIG_SENSORS_LTC4261 is not set
CONFIG_SENSORS_LM95241=y
# CONFIG_SENSORS_LM95245 is not set
CONFIG_SENSORS_MAX1111=y
# CONFIG_SENSORS_MAX16065 is not set
CONFIG_SENSORS_MAX1619=y
# CONFIG_SENSORS_MAX1668 is not set
# CONFIG_SENSORS_MAX6639 is not set
# CONFIG_SENSORS_MAX6642 is not set
CONFIG_SENSORS_MAX6650=y
# CONFIG_SENSORS_MCP3021 is not set
# CONFIG_SENSORS_NTC_THERMISTOR is not set
CONFIG_SENSORS_PC87360=y
CONFIG_SENSORS_PC87427=y
CONFIG_SENSORS_PCF8591=y
# CONFIG_PMBUS is not set
# CONFIG_SENSORS_SHT15 is not set
# CONFIG_SENSORS_SHT21 is not set
CONFIG_SENSORS_SIS5595=y
# CONFIG_SENSORS_SMM665 is not set
CONFIG_SENSORS_DME1737=y
CONFIG_SENSORS_EMC1403=y
# CONFIG_SENSORS_EMC2103 is not set
# CONFIG_SENSORS_EMC6W201 is not set
CONFIG_SENSORS_SMSC47M1=y
CONFIG_SENSORS_SMSC47M192=y
CONFIG_SENSORS_SMSC47B397=y
# CONFIG_SENSORS_SCH56XX_COMMON is not set
# CONFIG_SENSORS_SCH5627 is not set
# CONFIG_SENSORS_SCH5636 is not set
# CONFIG_SENSORS_ADS1015 is not set
CONFIG_SENSORS_ADS7828=y
CONFIG_SENSORS_ADS7871=y
CONFIG_SENSORS_AMC6821=y
# CONFIG_SENSORS_INA2XX is not set
CONFIG_SENSORS_THMC50=y
CONFIG_SENSORS_TMP102=y
CONFIG_SENSORS_TMP401=y
CONFIG_SENSORS_TMP421=y
CONFIG_SENSORS_VIA_CPUTEMP=y
CONFIG_SENSORS_VIA686A=y
CONFIG_SENSORS_VT1211=y
CONFIG_SENSORS_VT8231=y
CONFIG_SENSORS_W83781D=y
CONFIG_SENSORS_W83791D=y
CONFIG_SENSORS_W83792D=y
CONFIG_SENSORS_W83793=y
# CONFIG_SENSORS_W83795 is not set
CONFIG_SENSORS_W83L785TS=y
CONFIG_SENSORS_W83L786NG=y
CONFIG_SENSORS_W83627HF=y
CONFIG_SENSORS_W83627EHF=y
CONFIG_SENSORS_APPLESMC=y

#
# ACPI drivers
#
# CONFIG_SENSORS_ACPI_POWER is not set
CONFIG_SENSORS_ATK0110=y
CONFIG_THERMAL=y
CONFIG_THERMAL_HWMON=y
CONFIG_WATCHDOG=y
CONFIG_WATCHDOG_CORE=y
# CONFIG_WATCHDOG_NOWAYOUT is not set

#
# Watchdog Device Drivers
#
CONFIG_SOFT_WATCHDOG=y
CONFIG_ACQUIRE_WDT=y
CONFIG_ADVANTECH_WDT=y
CONFIG_ALIM1535_WDT=y
CONFIG_ALIM7101_WDT=y
# CONFIG_F71808E_WDT is not set
# CONFIG_SP5100_TCO is not set
CONFIG_SC520_WDT=y
CONFIG_SBC_FITPC2_WATCHDOG=y
# CONFIG_EUROTECH_WDT is not set
CONFIG_IB700_WDT=y
CONFIG_IBMASR=y
CONFIG_WAFER_WDT=y
CONFIG_I6300ESB_WDT=y
# CONFIG_IE6XX_WDT is not set
CONFIG_ITCO_WDT=y
CONFIG_ITCO_VENDOR_SUPPORT=y
CONFIG_IT8712F_WDT=y
CONFIG_IT87_WDT=y
CONFIG_HP_WATCHDOG=y
CONFIG_HPWDT_NMI_DECODING=y
CONFIG_SC1200_WDT=y
CONFIG_PC87413_WDT=y
# CONFIG_NV_TCO is not set
CONFIG_60XX_WDT=y
CONFIG_SBC8360_WDT=y
CONFIG_CPU5_WDT=y
CONFIG_SMSC_SCH311X_WDT=y
CONFIG_SMSC37B787_WDT=y
# CONFIG_VIA_WDT is not set
CONFIG_W83627HF_WDT=y
CONFIG_W83697HF_WDT=y
CONFIG_W83697UG_WDT=y
CONFIG_W83877F_WDT=y
CONFIG_W83977F_WDT=y
CONFIG_MACHZ_WDT=y
CONFIG_SBC_EPX_C3_WATCHDOG=y
# CONFIG_XEN_WDT is not set

#
# PCI-based Watchdog Cards
#
CONFIG_PCIPCWATCHDOG=y
CONFIG_WDTPCI=y
CONFIG_SSB_POSSIBLE=y

#
# Sonics Silicon Backplane
#
CONFIG_SSB=y
CONFIG_SSB_SPROM=y
CONFIG_SSB_BLOCKIO=y
CONFIG_SSB_PCIHOST_POSSIBLE=y
CONFIG_SSB_PCIHOST=y
CONFIG_SSB_B43_PCI_BRIDGE=y
CONFIG_SSB_PCMCIAHOST_POSSIBLE=y
CONFIG_SSB_PCMCIAHOST=y
CONFIG_SSB_SDIOHOST_POSSIBLE=y
CONFIG_SSB_SDIOHOST=y
# CONFIG_SSB_DEBUG is not set
CONFIG_SSB_DRIVER_PCICORE_POSSIBLE=y
CONFIG_SSB_DRIVER_PCICORE=y
CONFIG_BCMA_POSSIBLE=y

#
# Broadcom specific AMBA
#
# CONFIG_BCMA is not set

#
# Multifunction device drivers
#
CONFIG_MFD_CORE=y
# CONFIG_MFD_88PM860X is not set
# CONFIG_MFD_88PM800 is not set
# CONFIG_MFD_88PM805 is not set
CONFIG_MFD_SM501=y
# CONFIG_MFD_SM501_GPIO is not set
CONFIG_HTC_PASIC3=y
# CONFIG_HTC_I2CPLD is not set
# CONFIG_UCB1400_CORE is not set
# CONFIG_MFD_LM3533 is not set
# CONFIG_TPS6105X is not set
CONFIG_TPS65010=y
# CONFIG_TPS6507X is not set
# CONFIG_MFD_TPS65217 is not set
# CONFIG_MFD_TPS6586X is not set
# CONFIG_MFD_TPS65910 is not set
# CONFIG_MFD_TPS65912_I2C is not set
# CONFIG_MFD_TPS65912_SPI is not set
# CONFIG_TWL4030_CORE is not set
# CONFIG_TWL6040_CORE is not set
# CONFIG_MFD_STMPE is not set
# CONFIG_MFD_TC3589X is not set
# CONFIG_MFD_TMIO is not set
# CONFIG_PMIC_DA903X is not set
# CONFIG_MFD_DA9052_SPI is not set
# CONFIG_MFD_DA9052_I2C is not set
# CONFIG_PMIC_ADP5520 is not set
# CONFIG_MFD_MAX77686 is not set
# CONFIG_MFD_MAX77693 is not set
# CONFIG_MFD_MAX8925 is not set
# CONFIG_MFD_MAX8997 is not set
# CONFIG_MFD_MAX8998 is not set
# CONFIG_MFD_SEC_CORE is not set
# CONFIG_MFD_ARIZONA_I2C is not set
# CONFIG_MFD_ARIZONA_SPI is not set
CONFIG_MFD_WM8400=y
# CONFIG_MFD_WM831X_I2C is not set
# CONFIG_MFD_WM831X_SPI is not set
# CONFIG_MFD_WM8350_I2C is not set
# CONFIG_MFD_WM8994 is not set
CONFIG_MFD_PCF50633=y
CONFIG_PCF50633_ADC=y
CONFIG_PCF50633_GPIO=y
# CONFIG_MFD_MC13XXX_SPI is not set
# CONFIG_MFD_MC13XXX_I2C is not set
# CONFIG_ABX500_CORE is not set
# CONFIG_EZX_PCAP is not set
# CONFIG_MFD_CS5535 is not set
# CONFIG_MFD_TIMBERDALE is not set
CONFIG_LPC_SCH=y
CONFIG_LPC_ICH=y
# CONFIG_MFD_RDC321X is not set
# CONFIG_MFD_JANZ_CMODIO is not set
# CONFIG_MFD_VX855 is not set
# CONFIG_MFD_WL1273_CORE is not set
# CONFIG_MFD_TPS65090 is not set
# CONFIG_MFD_AAT2870_CORE is not set
# CONFIG_MFD_RC5T583 is not set
# CONFIG_MFD_PALMAS is not set
CONFIG_REGULATOR=y
# CONFIG_REGULATOR_DEBUG is not set
# CONFIG_REGULATOR_DUMMY is not set
CONFIG_REGULATOR_FIXED_VOLTAGE=y
# CONFIG_REGULATOR_VIRTUAL_CONSUMER is not set
CONFIG_REGULATOR_USERSPACE_CONSUMER=y
# CONFIG_REGULATOR_GPIO is not set
# CONFIG_REGULATOR_AD5398 is not set
# CONFIG_REGULATOR_ISL6271A is not set
CONFIG_REGULATOR_MAX1586=y
CONFIG_REGULATOR_MAX8649=y
CONFIG_REGULATOR_MAX8660=y
# CONFIG_REGULATOR_MAX8952 is not set
CONFIG_REGULATOR_LP3971=y
# CONFIG_REGULATOR_LP3972 is not set
# CONFIG_REGULATOR_LP872X is not set
CONFIG_REGULATOR_PCF50633=y
# CONFIG_REGULATOR_TPS62360 is not set
CONFIG_REGULATOR_TPS65023=y
CONFIG_REGULATOR_TPS6507X=y
# CONFIG_REGULATOR_TPS6524X is not set
CONFIG_REGULATOR_WM8400=y
CONFIG_MEDIA_SUPPORT=y

#
# Multimedia core support
#
# CONFIG_MEDIA_CAMERA_SUPPORT is not set
# CONFIG_MEDIA_ANALOG_TV_SUPPORT is not set
# CONFIG_MEDIA_DIGITAL_TV_SUPPORT is not set
# CONFIG_MEDIA_RADIO_SUPPORT is not set
# CONFIG_MEDIA_RC_SUPPORT is not set

#
# Media drivers
#

#
# Graphics support
#
CONFIG_AGP=y
CONFIG_AGP_AMD64=y
CONFIG_AGP_INTEL=y
CONFIG_AGP_SIS=y
CONFIG_AGP_VIA=y
CONFIG_VGA_ARB=y
CONFIG_VGA_ARB_MAX_GPUS=16
CONFIG_VGA_SWITCHEROO=y
CONFIG_DRM=y
CONFIG_DRM_KMS_HELPER=y
# CONFIG_DRM_LOAD_EDID_FIRMWARE is not set
CONFIG_DRM_TTM=y
CONFIG_DRM_TDFX=y
CONFIG_DRM_R128=y
CONFIG_DRM_RADEON=y
CONFIG_DRM_RADEON_KMS=y
# CONFIG_DRM_NOUVEAU is not set

#
# I2C encoder or helper chips
#
# CONFIG_DRM_I2C_CH7006 is not set
# CONFIG_DRM_I2C_SIL164 is not set
# CONFIG_DRM_I810 is not set
CONFIG_DRM_I915=y
CONFIG_DRM_I915_KMS=y
CONFIG_DRM_MGA=y
CONFIG_DRM_SIS=y
CONFIG_DRM_VIA=y
CONFIG_DRM_SAVAGE=y
# CONFIG_DRM_VMWGFX is not set
# CONFIG_DRM_GMA500 is not set
# CONFIG_DRM_UDL is not set
# CONFIG_DRM_AST is not set
# CONFIG_DRM_MGAG200 is not set
# CONFIG_DRM_CIRRUS_QEMU is not set
# CONFIG_STUB_POULSBO is not set
CONFIG_VGASTATE=y
CONFIG_VIDEO_OUTPUT_CONTROL=y
CONFIG_FB=y
CONFIG_FIRMWARE_EDID=y
CONFIG_FB_DDC=y
CONFIG_FB_BOOT_VESA_SUPPORT=y
CONFIG_FB_CFB_FILLRECT=y
CONFIG_FB_CFB_COPYAREA=y
CONFIG_FB_CFB_IMAGEBLIT=y
# CONFIG_FB_CFB_REV_PIXELS_IN_BYTE is not set
CONFIG_FB_SYS_FILLRECT=y
CONFIG_FB_SYS_COPYAREA=y
CONFIG_FB_SYS_IMAGEBLIT=y
# CONFIG_FB_FOREIGN_ENDIAN is not set
CONFIG_FB_SYS_FOPS=y
# CONFIG_FB_WMT_GE_ROPS is not set
CONFIG_FB_DEFERRED_IO=y
CONFIG_FB_HECUBA=y
CONFIG_FB_SVGALIB=y
# CONFIG_FB_MACMODES is not set
CONFIG_FB_BACKLIGHT=y
CONFIG_FB_MODE_HELPERS=y
CONFIG_FB_TILEBLITTING=y

#
# Frame buffer hardware drivers
#
# CONFIG_FB_CIRRUS is not set
CONFIG_FB_PM2=y
CONFIG_FB_PM2_FIFO_DISCONNECT=y
CONFIG_FB_CYBER2000=y
CONFIG_FB_CYBER2000_DDC=y
CONFIG_FB_ARC=y
# CONFIG_FB_ASILIANT is not set
# CONFIG_FB_IMSTT is not set
# CONFIG_FB_VGA16 is not set
CONFIG_FB_UVESA=y
CONFIG_FB_VESA=y
CONFIG_FB_EFI=y
CONFIG_FB_N411=y
CONFIG_FB_HGA=y
CONFIG_FB_S1D13XXX=y
CONFIG_FB_NVIDIA=y
# CONFIG_FB_NVIDIA_I2C is not set
# CONFIG_FB_NVIDIA_DEBUG is not set
CONFIG_FB_NVIDIA_BACKLIGHT=y
# CONFIG_FB_RIVA is not set
# CONFIG_FB_I740 is not set
CONFIG_FB_LE80578=y
CONFIG_FB_CARILLO_RANCH=y
CONFIG_FB_MATROX=y
CONFIG_FB_MATROX_MILLENIUM=y
CONFIG_FB_MATROX_MYSTIQUE=y
CONFIG_FB_MATROX_G=y
CONFIG_FB_MATROX_I2C=y
CONFIG_FB_MATROX_MAVEN=y
CONFIG_FB_RADEON=y
CONFIG_FB_RADEON_I2C=y
CONFIG_FB_RADEON_BACKLIGHT=y
# CONFIG_FB_RADEON_DEBUG is not set
CONFIG_FB_ATY128=y
CONFIG_FB_ATY128_BACKLIGHT=y
CONFIG_FB_ATY=y
CONFIG_FB_ATY_CT=y
# CONFIG_FB_ATY_GENERIC_LCD is not set
CONFIG_FB_ATY_GX=y
CONFIG_FB_ATY_BACKLIGHT=y
CONFIG_FB_S3=y
CONFIG_FB_S3_DDC=y
CONFIG_FB_SAVAGE=y
# CONFIG_FB_SAVAGE_I2C is not set
# CONFIG_FB_SAVAGE_ACCEL is not set
CONFIG_FB_SIS=y
CONFIG_FB_SIS_300=y
CONFIG_FB_SIS_315=y
CONFIG_FB_VIA=y
# CONFIG_FB_VIA_DIRECT_PROCFS is not set
# CONFIG_FB_VIA_X_COMPATIBILITY is not set
CONFIG_FB_NEOMAGIC=y
CONFIG_FB_KYRO=y
CONFIG_FB_3DFX=y
# CONFIG_FB_3DFX_ACCEL is not set
CONFIG_FB_3DFX_I2C=y
CONFIG_FB_VOODOO1=y
CONFIG_FB_VT8623=y
CONFIG_FB_TRIDENT=y
CONFIG_FB_ARK=y
CONFIG_FB_PM3=y
# CONFIG_FB_CARMINE is not set
# CONFIG_FB_GEODE is not set
# CONFIG_FB_TMIO is not set
CONFIG_FB_SM501=y
CONFIG_FB_VIRTUAL=y
CONFIG_XEN_FBDEV_FRONTEND=y
CONFIG_FB_METRONOME=y
CONFIG_FB_MB862XX=y
CONFIG_FB_MB862XX_PCI_GDC=y
CONFIG_FB_MB862XX_I2C=y
# CONFIG_FB_BROADSHEET is not set
# CONFIG_FB_AUO_K190X is not set
# CONFIG_EXYNOS_VIDEO is not set
CONFIG_BACKLIGHT_LCD_SUPPORT=y
# CONFIG_LCD_CLASS_DEVICE is not set
CONFIG_BACKLIGHT_CLASS_DEVICE=y
# CONFIG_BACKLIGHT_GENERIC is not set
CONFIG_BACKLIGHT_PROGEAR=y
# CONFIG_BACKLIGHT_APPLE is not set
# CONFIG_BACKLIGHT_SAHARA is not set
# CONFIG_BACKLIGHT_ADP8860 is not set
# CONFIG_BACKLIGHT_ADP8870 is not set
# CONFIG_BACKLIGHT_PCF50633 is not set
# CONFIG_BACKLIGHT_LP855X is not set

#
# Console display driver support
#
CONFIG_VGA_CONSOLE=y
# CONFIG_VGACON_SOFT_SCROLLBACK is not set
CONFIG_DUMMY_CONSOLE=y
CONFIG_FRAMEBUFFER_CONSOLE=y
CONFIG_FRAMEBUFFER_CONSOLE_DETECT_PRIMARY=y
CONFIG_FRAMEBUFFER_CONSOLE_ROTATION=y
# CONFIG_FONTS is not set
CONFIG_FONT_8x8=y
CONFIG_FONT_8x16=y
# CONFIG_LOGO is not set
CONFIG_SOUND=y
CONFIG_SOUND_OSS_CORE=y
# CONFIG_SOUND_OSS_CORE_PRECLAIM is not set
CONFIG_SND=y
CONFIG_SND_TIMER=y
CONFIG_SND_PCM=y
CONFIG_SND_HWDEP=y
CONFIG_SND_RAWMIDI=y
CONFIG_SND_JACK=y
CONFIG_SND_SEQUENCER=y
CONFIG_SND_SEQ_DUMMY=y
CONFIG_SND_OSSEMUL=y
CONFIG_SND_MIXER_OSS=y
CONFIG_SND_PCM_OSS=y
CONFIG_SND_PCM_OSS_PLUGINS=y
# CONFIG_SND_SEQUENCER_OSS is not set
CONFIG_SND_HRTIMER=y
CONFIG_SND_SEQ_HRTIMER_DEFAULT=y
CONFIG_SND_DYNAMIC_MINORS=y
CONFIG_SND_SUPPORT_OLD_API=y
CONFIG_SND_VERBOSE_PROCFS=y
# CONFIG_SND_VERBOSE_PRINTK is not set
# CONFIG_SND_DEBUG is not set
CONFIG_SND_VMASTER=y
CONFIG_SND_KCTL_JACK=y
CONFIG_SND_DMA_SGBUF=y
CONFIG_SND_RAWMIDI_SEQ=y
CONFIG_SND_OPL3_LIB_SEQ=y
# CONFIG_SND_OPL4_LIB_SEQ is not set
# CONFIG_SND_SBAWE_SEQ is not set
CONFIG_SND_EMU10K1_SEQ=y
CONFIG_SND_MPU401_UART=y
CONFIG_SND_OPL3_LIB=y
CONFIG_SND_VX_LIB=y
CONFIG_SND_AC97_CODEC=y
CONFIG_SND_DRIVERS=y
CONFIG_SND_PCSP=y
CONFIG_SND_DUMMY=y
# CONFIG_SND_ALOOP is not set
CONFIG_SND_VIRMIDI=y
CONFIG_SND_MTPAV=y
CONFIG_SND_MTS64=y
CONFIG_SND_SERIAL_U16550=y
CONFIG_SND_MPU401=y
CONFIG_SND_PORTMAN2X4=y
CONFIG_SND_AC97_POWER_SAVE=y
CONFIG_SND_AC97_POWER_SAVE_DEFAULT=0
CONFIG_SND_SB_COMMON=y
CONFIG_SND_SB16_DSP=y
CONFIG_SND_PCI=y
CONFIG_SND_AD1889=y
CONFIG_SND_ALS300=y
CONFIG_SND_ALS4000=y
CONFIG_SND_ALI5451=y
CONFIG_SND_ASIHPI=y
CONFIG_SND_ATIIXP=y
CONFIG_SND_ATIIXP_MODEM=y
CONFIG_SND_AU8810=y
CONFIG_SND_AU8820=y
CONFIG_SND_AU8830=y
# CONFIG_SND_AW2 is not set
CONFIG_SND_AZT3328=y
CONFIG_SND_BT87X=y
# CONFIG_SND_BT87X_OVERCLOCK is not set
CONFIG_SND_CA0106=y
CONFIG_SND_CMIPCI=y
CONFIG_SND_OXYGEN_LIB=y
CONFIG_SND_OXYGEN=y
CONFIG_SND_CS4281=y
CONFIG_SND_CS46XX=y
CONFIG_SND_CS46XX_NEW_DSP=y
CONFIG_SND_CS5530=y
CONFIG_SND_CS5535AUDIO=y
CONFIG_SND_CTXFI=y
CONFIG_SND_DARLA20=y
CONFIG_SND_GINA20=y
CONFIG_SND_LAYLA20=y
CONFIG_SND_DARLA24=y
CONFIG_SND_GINA24=y
CONFIG_SND_LAYLA24=y
CONFIG_SND_MONA=y
CONFIG_SND_MIA=y
CONFIG_SND_ECHO3G=y
CONFIG_SND_INDIGO=y
CONFIG_SND_INDIGOIO=y
CONFIG_SND_INDIGODJ=y
CONFIG_SND_INDIGOIOX=y
CONFIG_SND_INDIGODJX=y
CONFIG_SND_EMU10K1=y
CONFIG_SND_EMU10K1X=y
CONFIG_SND_ENS1370=y
CONFIG_SND_ENS1371=y
CONFIG_SND_ES1938=y
CONFIG_SND_ES1968=y
CONFIG_SND_ES1968_INPUT=y
CONFIG_SND_FM801=y
CONFIG_SND_HDA_INTEL=y
CONFIG_SND_HDA_PREALLOC_SIZE=64
CONFIG_SND_HDA_HWDEP=y
CONFIG_SND_HDA_RECONFIG=y
CONFIG_SND_HDA_INPUT_BEEP=y
CONFIG_SND_HDA_INPUT_BEEP_MODE=1
CONFIG_SND_HDA_INPUT_JACK=y
CONFIG_SND_HDA_PATCH_LOADER=y
CONFIG_SND_HDA_CODEC_REALTEK=y
CONFIG_SND_HDA_CODEC_ANALOG=y
CONFIG_SND_HDA_CODEC_SIGMATEL=y
CONFIG_SND_HDA_CODEC_VIA=y
CONFIG_SND_HDA_CODEC_HDMI=y
CONFIG_SND_HDA_CODEC_CIRRUS=y
CONFIG_SND_HDA_CODEC_CONEXANT=y
CONFIG_SND_HDA_CODEC_CA0110=y
CONFIG_SND_HDA_CODEC_CA0132=y
CONFIG_SND_HDA_CODEC_CMEDIA=y
CONFIG_SND_HDA_CODEC_SI3054=y
CONFIG_SND_HDA_GENERIC=y
# CONFIG_SND_HDA_POWER_SAVE is not set
CONFIG_SND_HDSP=y

#
# Don't forget to add built-in firmwares for HDSP driver
#
CONFIG_SND_HDSPM=y
CONFIG_SND_ICE1712=y
CONFIG_SND_ICE1724=y
CONFIG_SND_INTEL8X0=y
CONFIG_SND_INTEL8X0M=y
CONFIG_SND_KORG1212=y
# CONFIG_SND_LOLA is not set
CONFIG_SND_LX6464ES=y
CONFIG_SND_MAESTRO3=y
CONFIG_SND_MAESTRO3_INPUT=y
CONFIG_SND_MIXART=y
CONFIG_SND_NM256=y
CONFIG_SND_PCXHR=y
CONFIG_SND_RIPTIDE=y
CONFIG_SND_RME32=y
CONFIG_SND_RME96=y
CONFIG_SND_RME9652=y
CONFIG_SND_SONICVIBES=y
CONFIG_SND_TRIDENT=y
CONFIG_SND_VIA82XX=y
CONFIG_SND_VIA82XX_MODEM=y
CONFIG_SND_VIRTUOSO=y
CONFIG_SND_VX222=y
CONFIG_SND_YMFPCI=y
CONFIG_SND_SPI=y
CONFIG_SND_FIREWIRE=y
# CONFIG_SND_FIREWIRE_SPEAKERS is not set
# CONFIG_SND_ISIGHT is not set
CONFIG_SND_PCMCIA=y
CONFIG_SND_VXPOCKET=y
CONFIG_SND_PDAUDIOCF=y
# CONFIG_SND_SOC is not set
# CONFIG_SOUND_PRIME is not set
CONFIG_AC97_BUS=y

#
# HID support
#
CONFIG_HID=y
# CONFIG_HID_BATTERY_STRENGTH is not set
CONFIG_HIDRAW=y
# CONFIG_UHID is not set
CONFIG_HID_GENERIC=y

#
# Special HID drivers
#
CONFIG_USB_ARCH_HAS_OHCI=y
CONFIG_USB_ARCH_HAS_EHCI=y
CONFIG_USB_ARCH_HAS_XHCI=y
CONFIG_USB_SUPPORT=y
CONFIG_USB_COMMON=y
CONFIG_USB_ARCH_HAS_HCD=y
# CONFIG_USB is not set
# CONFIG_USB_HCD_SSB is not set
# CONFIG_USB_CHIPIDEA is not set

#
# NOTE: USB_STORAGE depends on SCSI but BLK_DEV_SD may
#

#
# USB Physical Layer drivers
#
# CONFIG_USB_ISP1301 is not set
CONFIG_USB_GADGET=y
# CONFIG_USB_GADGET_DEBUG is not set
# CONFIG_USB_GADGET_DEBUG_FILES is not set
# CONFIG_USB_GADGET_DEBUG_FS is not set
CONFIG_USB_GADGET_VBUS_DRAW=2
CONFIG_USB_GADGET_STORAGE_NUM_BUFFERS=2

#
# USB Peripheral Controller
#
CONFIG_USB_R8A66597=y
# CONFIG_USB_MV_UDC is not set
# CONFIG_USB_M66592 is not set
# CONFIG_USB_AMD5536UDC is not set
# CONFIG_USB_NET2272 is not set
# CONFIG_USB_NET2280 is not set
# CONFIG_USB_GOKU is not set
# CONFIG_USB_EG20T is not set
CONFIG_USB_GADGET_DUALSPEED=y
# CONFIG_USB_ZERO is not set
# CONFIG_USB_AUDIO is not set
# CONFIG_USB_ETH is not set
# CONFIG_USB_G_NCM is not set
# CONFIG_USB_GADGETFS is not set
# CONFIG_USB_FUNCTIONFS is not set
# CONFIG_USB_FILE_STORAGE is not set
# CONFIG_USB_MASS_STORAGE is not set
# CONFIG_USB_G_SERIAL is not set
# CONFIG_USB_MIDI_GADGET is not set
# CONFIG_USB_G_PRINTER is not set
# CONFIG_USB_CDC_COMPOSITE is not set
# CONFIG_USB_G_NOKIA is not set
# CONFIG_USB_G_ACM_MS is not set
# CONFIG_USB_G_MULTI is not set
# CONFIG_USB_G_HID is not set
# CONFIG_USB_G_DBGP is not set

#
# OTG and related infrastructure
#
CONFIG_USB_OTG_UTILS=y
# CONFIG_USB_GPIO_VBUS is not set
CONFIG_NOP_USB_XCEIV=y
CONFIG_UWB=y
CONFIG_UWB_WHCI=y
CONFIG_MMC=y
# CONFIG_MMC_DEBUG is not set
# CONFIG_MMC_UNSAFE_RESUME is not set
# CONFIG_MMC_CLKGATE is not set

#
# MMC/SD/SDIO Card Drivers
#
CONFIG_MMC_BLOCK=y
CONFIG_MMC_BLOCK_MINORS=8
CONFIG_MMC_BLOCK_BOUNCE=y
CONFIG_SDIO_UART=y
# CONFIG_MMC_TEST is not set

#
# MMC/SD/SDIO Host Controller Drivers
#
CONFIG_MMC_SDHCI=y
CONFIG_MMC_SDHCI_PCI=y
CONFIG_MMC_RICOH_MMC=y
CONFIG_MMC_SDHCI_PLTFM=y
CONFIG_MMC_WBSD=y
CONFIG_MMC_TIFM_SD=y
CONFIG_MMC_SPI=y
CONFIG_MMC_SDRICOH_CS=y
CONFIG_MMC_CB710=y
CONFIG_MMC_VIA_SDMMC=y
CONFIG_MEMSTICK=y
# CONFIG_MEMSTICK_DEBUG is not set

#
# MemoryStick drivers
#
# CONFIG_MEMSTICK_UNSAFE_RESUME is not set
CONFIG_MSPRO_BLOCK=y

#
# MemoryStick Host Controller Drivers
#
CONFIG_MEMSTICK_TIFM_MS=y
CONFIG_MEMSTICK_JMICRON_38X=y
# CONFIG_MEMSTICK_R592 is not set
CONFIG_NEW_LEDS=y
CONFIG_LEDS_CLASS=y

#
# LED drivers
#
# CONFIG_LEDS_LM3530 is not set
CONFIG_LEDS_PCA9532=y
# CONFIG_LEDS_PCA9532_GPIO is not set
# CONFIG_LEDS_GPIO is not set
CONFIG_LEDS_LP3944=y
# CONFIG_LEDS_LP5521 is not set
# CONFIG_LEDS_LP5523 is not set
CONFIG_LEDS_CLEVO_MAIL=y
CONFIG_LEDS_PCA955X=y
# CONFIG_LEDS_PCA9633 is not set
CONFIG_LEDS_DAC124S085=y
CONFIG_LEDS_REGULATOR=y
CONFIG_LEDS_BD2802=y
CONFIG_LEDS_INTEL_SS4200=y
CONFIG_LEDS_LT3593=y
CONFIG_LEDS_DELL_NETBOOKS=y
# CONFIG_LEDS_TCA6507 is not set
# CONFIG_LEDS_LM3556 is not set
# CONFIG_LEDS_OT200 is not set
# CONFIG_LEDS_BLINKM is not set
CONFIG_LEDS_TRIGGERS=y

#
# LED Triggers
#
CONFIG_LEDS_TRIGGER_TIMER=y
# CONFIG_LEDS_TRIGGER_ONESHOT is not set
CONFIG_LEDS_TRIGGER_IDE_DISK=y
CONFIG_LEDS_TRIGGER_HEARTBEAT=y
CONFIG_LEDS_TRIGGER_BACKLIGHT=y
# CONFIG_LEDS_TRIGGER_GPIO is not set
CONFIG_LEDS_TRIGGER_DEFAULT_ON=y

#
# iptables trigger is under Netfilter config (LED target)
#
# CONFIG_LEDS_TRIGGER_TRANSIENT is not set
CONFIG_ACCESSIBILITY=y
CONFIG_A11Y_BRAILLE_CONSOLE=y
CONFIG_INFINIBAND=y
CONFIG_INFINIBAND_USER_MAD=y
CONFIG_INFINIBAND_USER_ACCESS=y
CONFIG_INFINIBAND_USER_MEM=y
CONFIG_INFINIBAND_ADDR_TRANS=y
CONFIG_INFINIBAND_MTHCA=y
CONFIG_INFINIBAND_MTHCA_DEBUG=y
CONFIG_INFINIBAND_IPATH=y
CONFIG_INFINIBAND_QIB=y
CONFIG_INFINIBAND_AMSO1100=y
# CONFIG_INFINIBAND_AMSO1100_DEBUG is not set
CONFIG_INFINIBAND_CXGB3=y
# CONFIG_INFINIBAND_CXGB3_DEBUG is not set
CONFIG_INFINIBAND_CXGB4=y
CONFIG_MLX4_INFINIBAND=y
CONFIG_INFINIBAND_NES=y
# CONFIG_INFINIBAND_NES_DEBUG is not set
# CONFIG_INFINIBAND_OCRDMA is not set
CONFIG_INFINIBAND_IPOIB=y
CONFIG_INFINIBAND_IPOIB_CM=y
CONFIG_INFINIBAND_IPOIB_DEBUG=y
# CONFIG_INFINIBAND_IPOIB_DEBUG_DATA is not set
CONFIG_INFINIBAND_SRP=y
CONFIG_INFINIBAND_ISER=y
CONFIG_EDAC=y

#
# Reporting subsystems
#
CONFIG_EDAC_LEGACY_SYSFS=y
# CONFIG_EDAC_DEBUG is not set
CONFIG_EDAC_DECODE_MCE=y
# CONFIG_EDAC_MCE_INJ is not set
CONFIG_EDAC_MM_EDAC=y
CONFIG_EDAC_AMD64=y
# CONFIG_EDAC_AMD64_ERROR_INJECTION is not set
CONFIG_EDAC_E752X=y
CONFIG_EDAC_I82975X=y
CONFIG_EDAC_I3000=y
CONFIG_EDAC_I3200=y
CONFIG_EDAC_X38=y
CONFIG_EDAC_I5400=y
CONFIG_EDAC_I7CORE=y
CONFIG_EDAC_I5000=y
CONFIG_EDAC_I5100=y
# CONFIG_EDAC_I7300 is not set
# CONFIG_EDAC_SBRIDGE is not set
CONFIG_RTC_LIB=y
CONFIG_RTC_CLASS=y
CONFIG_RTC_HCTOSYS=y
CONFIG_RTC_HCTOSYS_DEVICE="rtc0"
# CONFIG_RTC_DEBUG is not set

#
# RTC interfaces
#
CONFIG_RTC_INTF_SYSFS=y
CONFIG_RTC_INTF_PROC=y
CONFIG_RTC_INTF_DEV=y
# CONFIG_RTC_INTF_DEV_UIE_EMUL is not set
CONFIG_RTC_DRV_TEST=y

#
# I2C RTC drivers
#
CONFIG_RTC_DRV_DS1307=y
CONFIG_RTC_DRV_DS1374=y
CONFIG_RTC_DRV_DS1672=y
# CONFIG_RTC_DRV_DS3232 is not set
CONFIG_RTC_DRV_MAX6900=y
CONFIG_RTC_DRV_RS5C372=y
CONFIG_RTC_DRV_ISL1208=y
# CONFIG_RTC_DRV_ISL12022 is not set
CONFIG_RTC_DRV_X1205=y
CONFIG_RTC_DRV_PCF8563=y
CONFIG_RTC_DRV_PCF8583=y
CONFIG_RTC_DRV_M41T80=y
# CONFIG_RTC_DRV_M41T80_WDT is not set
CONFIG_RTC_DRV_BQ32K=y
CONFIG_RTC_DRV_S35390A=y
CONFIG_RTC_DRV_FM3130=y
CONFIG_RTC_DRV_RX8581=y
CONFIG_RTC_DRV_RX8025=y
# CONFIG_RTC_DRV_EM3027 is not set
# CONFIG_RTC_DRV_RV3029C2 is not set

#
# SPI RTC drivers
#
# CONFIG_RTC_DRV_M41T93 is not set
CONFIG_RTC_DRV_M41T94=y
CONFIG_RTC_DRV_DS1305=y
CONFIG_RTC_DRV_DS1390=y
CONFIG_RTC_DRV_MAX6902=y
CONFIG_RTC_DRV_R9701=y
CONFIG_RTC_DRV_RS5C348=y
CONFIG_RTC_DRV_DS3234=y
CONFIG_RTC_DRV_PCF2123=y

#
# Platform RTC drivers
#
CONFIG_RTC_DRV_CMOS=y
CONFIG_RTC_DRV_DS1286=y
CONFIG_RTC_DRV_DS1511=y
CONFIG_RTC_DRV_DS1553=y
CONFIG_RTC_DRV_DS1742=y
CONFIG_RTC_DRV_STK17TA8=y
CONFIG_RTC_DRV_M48T86=y
CONFIG_RTC_DRV_M48T35=y
CONFIG_RTC_DRV_M48T59=y
CONFIG_RTC_DRV_MSM6242=y
CONFIG_RTC_DRV_BQ4802=y
CONFIG_RTC_DRV_RP5C01=y
CONFIG_RTC_DRV_V3020=y
CONFIG_RTC_DRV_PCF50633=y

#
# on-CPU RTC drivers
#
CONFIG_DMADEVICES=y
# CONFIG_DMADEVICES_DEBUG is not set

#
# DMA Devices
#
# CONFIG_INTEL_MID_DMAC is not set
CONFIG_INTEL_IOATDMA=y
# CONFIG_TIMB_DMA is not set
# CONFIG_PCH_DMA is not set
CONFIG_DMA_ENGINE=y

#
# DMA Clients
#
CONFIG_NET_DMA=y
CONFIG_ASYNC_TX_DMA=y
# CONFIG_DMATEST is not set
CONFIG_DCA=y
# CONFIG_AUXDISPLAY is not set
CONFIG_UIO=y
CONFIG_UIO_CIF=y
CONFIG_UIO_PDRV=y
CONFIG_UIO_PDRV_GENIRQ=y
CONFIG_UIO_AEC=y
CONFIG_UIO_SERCOS3=y
CONFIG_UIO_PCI_GENERIC=y
CONFIG_UIO_NETX=y
# CONFIG_VFIO is not set
CONFIG_VIRTIO=y
CONFIG_VIRTIO_RING=y

#
# Virtio drivers
#
CONFIG_VIRTIO_PCI=y
CONFIG_VIRTIO_BALLOON=y
# CONFIG_VIRTIO_MMIO is not set

#
# Microsoft Hyper-V guest support
#
# CONFIG_HYPERV is not set

#
# Xen driver support
#
CONFIG_XEN_BALLOON=y
# CONFIG_XEN_BALLOON_MEMORY_HOTPLUG is not set
CONFIG_XEN_SCRUB_PAGES=y
CONFIG_XEN_DEV_EVTCHN=y
CONFIG_XEN_BACKEND=y
CONFIG_XENFS=y
CONFIG_XEN_COMPAT_XENFS=y
CONFIG_XEN_SYS_HYPERVISOR=y
CONFIG_XEN_XENBUS_FRONTEND=y
CONFIG_XEN_GNTDEV=m
CONFIG_XEN_GRANT_DEV_ALLOC=m
CONFIG_SWIOTLB_XEN=y
CONFIG_XEN_PCIDEV_BACKEND=m
CONFIG_XEN_PRIVCMD=y
CONFIG_XEN_ACPI_PROCESSOR=m
# CONFIG_XEN_MCE_LOG is not set
CONFIG_STAGING=y
# CONFIG_ET131X is not set
# CONFIG_SLICOSS is not set
# CONFIG_ECHO is not set
# CONFIG_COMEDI is not set
# CONFIG_PANEL is not set
# CONFIG_R8187SE is not set
# CONFIG_RTLLIB is not set
# CONFIG_RTS_PSTOR is not set
# CONFIG_IDE_PHISON is not set
# CONFIG_VT6655 is not set
# CONFIG_DX_SEP is not set
# CONFIG_ZSMALLOC is not set
# CONFIG_WLAGS49_H2 is not set
# CONFIG_WLAGS49_H25 is not set
# CONFIG_FB_SM7XX is not set
# CONFIG_CRYSTALHD is not set
# CONFIG_CXT1E1 is not set
# CONFIG_FB_XGI is not set
# CONFIG_ACPI_QUICKSTART is not set
# CONFIG_SBE_2T3E3 is not set
# CONFIG_FT1000 is not set

#
# Speakup console speech
#
# CONFIG_SPEAKUP is not set
# CONFIG_TOUCHSCREEN_CLEARPAD_TM1217 is not set
# CONFIG_TOUCHSCREEN_SYNAPTICS_I2C_RMI4 is not set
# CONFIG_STAGING_MEDIA is not set

#
# Android
#
# CONFIG_ANDROID is not set
CONFIG_PHONE=y
CONFIG_PHONE_IXJ=y
CONFIG_PHONE_IXJ_PCMCIA=y
# CONFIG_USB_G_CCG is not set
# CONFIG_IPACK_BUS is not set
# CONFIG_WIMAX_GDM72XX is not set
# CONFIG_CSR_WIFI is not set
CONFIG_X86_PLATFORM_DEVICES=y
CONFIG_ACER_WMI=y
CONFIG_ACERHDF=y
CONFIG_ASUS_LAPTOP=y
CONFIG_DELL_LAPTOP=y
CONFIG_DELL_WMI=y
# CONFIG_DELL_WMI_AIO is not set
CONFIG_FUJITSU_LAPTOP=y
# CONFIG_FUJITSU_LAPTOP_DEBUG is not set
# CONFIG_FUJITSU_TABLET is not set
# CONFIG_AMILO_RFKILL is not set
# CONFIG_HP_ACCEL is not set
CONFIG_HP_WMI=y
CONFIG_MSI_LAPTOP=y
CONFIG_PANASONIC_LAPTOP=y
CONFIG_COMPAL_LAPTOP=y
CONFIG_SONY_LAPTOP=y
CONFIG_SONYPI_COMPAT=y
# CONFIG_IDEAPAD_LAPTOP is not set
CONFIG_THINKPAD_ACPI=y
CONFIG_THINKPAD_ACPI_ALSA_SUPPORT=y
# CONFIG_THINKPAD_ACPI_DEBUGFACILITIES is not set
# CONFIG_THINKPAD_ACPI_DEBUG is not set
# CONFIG_THINKPAD_ACPI_UNSAFE_LEDS is not set
CONFIG_THINKPAD_ACPI_VIDEO=y
CONFIG_THINKPAD_ACPI_HOTKEY_POLL=y
CONFIG_SENSORS_HDAPS=y
# CONFIG_INTEL_MENLOW is not set
CONFIG_EEEPC_LAPTOP=y
# CONFIG_ASUS_WMI is not set
CONFIG_ACPI_WMI=y
CONFIG_MSI_WMI=y
CONFIG_TOPSTAR_LAPTOP=y
CONFIG_ACPI_TOSHIBA=y
CONFIG_TOSHIBA_BT_RFKILL=y
CONFIG_ACPI_CMPC=y
# CONFIG_INTEL_IPS is not set
# CONFIG_IBM_RTL is not set
# CONFIG_XO15_EBOOK is not set
# CONFIG_SAMSUNG_LAPTOP is not set
# CONFIG_MXM_WMI is not set
# CONFIG_INTEL_OAKTRAIL is not set
# CONFIG_SAMSUNG_Q10 is not set
# CONFIG_APPLE_GMUX is not set

#
# Hardware Spinlock drivers
#
CONFIG_CLKEVT_I8253=y
CONFIG_I8253_LOCK=y
CONFIG_CLKBLD_I8253=y
CONFIG_IOMMU_API=y
CONFIG_IOMMU_SUPPORT=y
CONFIG_AMD_IOMMU=y
# CONFIG_AMD_IOMMU_STATS is not set
# CONFIG_AMD_IOMMU_V2 is not set
# CONFIG_INTEL_IOMMU is not set
# CONFIG_IRQ_REMAP is not set

#
# Remoteproc drivers (EXPERIMENTAL)
#

#
# Rpmsg drivers (EXPERIMENTAL)
#
# CONFIG_VIRT_DRIVERS is not set
# CONFIG_PM_DEVFREQ is not set
# CONFIG_EXTCON is not set
# CONFIG_MEMORY is not set
# CONFIG_IIO is not set
# CONFIG_VME_BUS is not set
# CONFIG_PWM is not set

#
# Firmware Drivers
#
CONFIG_EDD=y
# CONFIG_EDD_OFF is not set
CONFIG_FIRMWARE_MEMMAP=y
CONFIG_EFI_VARS=y
CONFIG_DELL_RBU=y
CONFIG_DCDBAS=y
CONFIG_DMIID=y
# CONFIG_DMI_SYSFS is not set
CONFIG_ISCSI_IBFT_FIND=y
CONFIG_ISCSI_IBFT=y
# CONFIG_GOOGLE_FIRMWARE is not set

#
# File systems
#
CONFIG_DCACHE_WORD_ACCESS=y
CONFIG_EXT2_FS=y
CONFIG_EXT2_FS_XATTR=y
CONFIG_EXT2_FS_POSIX_ACL=y
CONFIG_EXT2_FS_SECURITY=y
# CONFIG_EXT2_FS_XIP is not set
CONFIG_EXT3_FS=y
CONFIG_EXT3_DEFAULTS_TO_ORDERED=y
CONFIG_EXT3_FS_XATTR=y
CONFIG_EXT3_FS_POSIX_ACL=y
CONFIG_EXT3_FS_SECURITY=y
CONFIG_EXT4_FS=y
CONFIG_EXT4_FS_XATTR=y
CONFIG_EXT4_FS_POSIX_ACL=y
CONFIG_EXT4_FS_SECURITY=y
# CONFIG_EXT4_DEBUG is not set
CONFIG_JBD=y
# CONFIG_JBD_DEBUG is not set
CONFIG_JBD2=y
# CONFIG_JBD2_DEBUG is not set
CONFIG_FS_MBCACHE=y
CONFIG_REISERFS_FS=y
# CONFIG_REISERFS_CHECK is not set
# CONFIG_REISERFS_PROC_INFO is not set
CONFIG_REISERFS_FS_XATTR=y
CONFIG_REISERFS_FS_POSIX_ACL=y
CONFIG_REISERFS_FS_SECURITY=y
CONFIG_JFS_FS=y
CONFIG_JFS_POSIX_ACL=y
CONFIG_JFS_SECURITY=y
# CONFIG_JFS_DEBUG is not set
# CONFIG_JFS_STATISTICS is not set
CONFIG_XFS_FS=y
CONFIG_XFS_QUOTA=y
CONFIG_XFS_POSIX_ACL=y
CONFIG_XFS_RT=y
# CONFIG_XFS_DEBUG is not set
CONFIG_GFS2_FS=y
CONFIG_GFS2_FS_LOCKING_DLM=y
CONFIG_OCFS2_FS=y
CONFIG_OCFS2_FS_O2CB=y
CONFIG_OCFS2_FS_USERSPACE_CLUSTER=y
CONFIG_OCFS2_FS_STATS=y
CONFIG_OCFS2_DEBUG_MASKLOG=y
# CONFIG_OCFS2_DEBUG_FS is not set
CONFIG_BTRFS_FS=y
CONFIG_BTRFS_FS_POSIX_ACL=y
# CONFIG_BTRFS_FS_CHECK_INTEGRITY is not set
CONFIG_NILFS2_FS=y
CONFIG_FS_POSIX_ACL=y
CONFIG_EXPORTFS=y
CONFIG_FILE_LOCKING=y
CONFIG_FSNOTIFY=y
CONFIG_DNOTIFY=y
CONFIG_INOTIFY_USER=y
# CONFIG_FANOTIFY is not set
CONFIG_QUOTA=y
CONFIG_QUOTA_NETLINK_INTERFACE=y
CONFIG_PRINT_QUOTA_WARNING=y
# CONFIG_QUOTA_DEBUG is not set
CONFIG_QUOTA_TREE=y
CONFIG_QFMT_V1=y
CONFIG_QFMT_V2=y
CONFIG_QUOTACTL=y
CONFIG_QUOTACTL_COMPAT=y
CONFIG_AUTOFS4_FS=y
CONFIG_FUSE_FS=y
CONFIG_CUSE=y
CONFIG_GENERIC_ACL=y

#
# Caches
#
CONFIG_FSCACHE=y
CONFIG_FSCACHE_STATS=y
# CONFIG_FSCACHE_HISTOGRAM is not set
# CONFIG_FSCACHE_DEBUG is not set
# CONFIG_FSCACHE_OBJECT_LIST is not set
CONFIG_CACHEFILES=y
# CONFIG_CACHEFILES_DEBUG is not set
# CONFIG_CACHEFILES_HISTOGRAM is not set

#
# CD-ROM/DVD Filesystems
#
CONFIG_ISO9660_FS=y
CONFIG_JOLIET=y
CONFIG_ZISOFS=y
CONFIG_UDF_FS=y
CONFIG_UDF_NLS=y

#
# DOS/FAT/NT Filesystems
#
CONFIG_FAT_FS=y
CONFIG_MSDOS_FS=y
CONFIG_VFAT_FS=y
CONFIG_FAT_DEFAULT_CODEPAGE=437
CONFIG_FAT_DEFAULT_IOCHARSET="utf8"
CONFIG_NTFS_FS=y
# CONFIG_NTFS_DEBUG is not set
CONFIG_NTFS_RW=y

#
# Pseudo filesystems
#
CONFIG_PROC_FS=y
CONFIG_PROC_KCORE=y
CONFIG_PROC_SYSCTL=y
CONFIG_PROC_PAGE_MONITOR=y
CONFIG_SYSFS=y
CONFIG_TMPFS=y
CONFIG_TMPFS_POSIX_ACL=y
CONFIG_TMPFS_XATTR=y
CONFIG_HUGETLBFS=y
CONFIG_HUGETLB_PAGE=y
CONFIG_CONFIGFS_FS=y
CONFIG_MISC_FILESYSTEMS=y
CONFIG_ADFS_FS=y
# CONFIG_ADFS_FS_RW is not set
CONFIG_AFFS_FS=y
CONFIG_ECRYPT_FS=y
CONFIG_HFS_FS=y
CONFIG_HFSPLUS_FS=y
CONFIG_BEFS_FS=y
# CONFIG_BEFS_DEBUG is not set
CONFIG_BFS_FS=y
CONFIG_EFS_FS=y
CONFIG_JFFS2_FS=y
CONFIG_JFFS2_FS_DEBUG=0
CONFIG_JFFS2_FS_WRITEBUFFER=y
# CONFIG_JFFS2_FS_WBUF_VERIFY is not set
CONFIG_JFFS2_SUMMARY=y
CONFIG_JFFS2_FS_XATTR=y
CONFIG_JFFS2_FS_POSIX_ACL=y
CONFIG_JFFS2_FS_SECURITY=y
CONFIG_JFFS2_COMPRESSION_OPTIONS=y
CONFIG_JFFS2_ZLIB=y
CONFIG_JFFS2_LZO=y
CONFIG_JFFS2_RTIME=y
# CONFIG_JFFS2_RUBIN is not set
# CONFIG_JFFS2_CMODE_NONE is not set
CONFIG_JFFS2_CMODE_PRIORITY=y
# CONFIG_JFFS2_CMODE_SIZE is not set
# CONFIG_JFFS2_CMODE_FAVOURLZO is not set
CONFIG_UBIFS_FS=y
CONFIG_UBIFS_FS_ADVANCED_COMPR=y
CONFIG_UBIFS_FS_LZO=y
CONFIG_UBIFS_FS_ZLIB=y
CONFIG_LOGFS=y
CONFIG_CRAMFS=y
CONFIG_SQUASHFS=y
# CONFIG_SQUASHFS_XATTR is not set
CONFIG_SQUASHFS_ZLIB=y
# CONFIG_SQUASHFS_LZO is not set
# CONFIG_SQUASHFS_XZ is not set
# CONFIG_SQUASHFS_4K_DEVBLK_SIZE is not set
# CONFIG_SQUASHFS_EMBEDDED is not set
CONFIG_SQUASHFS_FRAGMENT_CACHE_SIZE=3
CONFIG_VXFS_FS=y
CONFIG_MINIX_FS=y
CONFIG_OMFS_FS=y
# CONFIG_HPFS_FS is not set
CONFIG_QNX4FS_FS=y
# CONFIG_QNX6FS_FS is not set
CONFIG_ROMFS_FS=y
# CONFIG_ROMFS_BACKED_BY_BLOCK is not set
# CONFIG_ROMFS_BACKED_BY_MTD is not set
CONFIG_ROMFS_BACKED_BY_BOTH=y
CONFIG_ROMFS_ON_BLOCK=y
CONFIG_ROMFS_ON_MTD=y
CONFIG_PSTORE=y
# CONFIG_PSTORE_CONSOLE is not set
# CONFIG_PSTORE_FTRACE is not set
# CONFIG_PSTORE_RAM is not set
CONFIG_SYSV_FS=y
CONFIG_UFS_FS=y
# CONFIG_UFS_FS_WRITE is not set
# CONFIG_UFS_DEBUG is not set
CONFIG_EXOFS_FS=y
# CONFIG_EXOFS_DEBUG is not set
CONFIG_ORE=y
CONFIG_NETWORK_FILESYSTEMS=y
CONFIG_NFS_FS=y
CONFIG_NFS_V2=y
CONFIG_NFS_V3=y
CONFIG_NFS_V3_ACL=y
CONFIG_NFS_V4=y
# CONFIG_NFS_SWAP is not set
CONFIG_NFS_V4_1=y
CONFIG_PNFS_FILE_LAYOUT=m
CONFIG_PNFS_BLOCK=m
CONFIG_PNFS_OBJLAYOUT=m
CONFIG_NFS_V4_1_IMPLEMENTATION_ID_DOMAIN="kernel.org"
CONFIG_ROOT_NFS=y
CONFIG_NFS_FSCACHE=y
# CONFIG_NFS_USE_LEGACY_DNS is not set
CONFIG_NFS_USE_KERNEL_DNS=y
CONFIG_NFSD=y
CONFIG_NFSD_V2_ACL=y
CONFIG_NFSD_V3=y
CONFIG_NFSD_V3_ACL=y
CONFIG_NFSD_V4=y
# CONFIG_NFSD_FAULT_INJECTION is not set
CONFIG_LOCKD=y
CONFIG_LOCKD_V4=y
CONFIG_NFS_ACL_SUPPORT=y
CONFIG_NFS_COMMON=y
CONFIG_SUNRPC=y
CONFIG_SUNRPC_GSS=y
CONFIG_SUNRPC_BACKCHANNEL=y
CONFIG_SUNRPC_XPRT_RDMA=y
CONFIG_RPCSEC_GSS_KRB5=y
# CONFIG_SUNRPC_DEBUG is not set
CONFIG_CEPH_FS=y
CONFIG_CIFS=y
# CONFIG_CIFS_STATS is not set
CONFIG_CIFS_WEAK_PW_HASH=y
CONFIG_CIFS_UPCALL=y
CONFIG_CIFS_XATTR=y
CONFIG_CIFS_POSIX=y
# CONFIG_CIFS_DEBUG2 is not set
CONFIG_CIFS_DFS_UPCALL=y
# CONFIG_CIFS_FSCACHE is not set
# CONFIG_CIFS_ACL is not set
CONFIG_NCP_FS=y
CONFIG_NCPFS_PACKET_SIGNING=y
CONFIG_NCPFS_IOCTL_LOCKING=y
CONFIG_NCPFS_STRONG=y
CONFIG_NCPFS_NFS_NS=y
CONFIG_NCPFS_OS2_NS=y
# CONFIG_NCPFS_SMALLDOS is not set
CONFIG_NCPFS_NLS=y
CONFIG_NCPFS_EXTRAS=y
CONFIG_CODA_FS=y
CONFIG_AFS_FS=y
# CONFIG_AFS_DEBUG is not set
CONFIG_AFS_FSCACHE=y
CONFIG_9P_FS=y
CONFIG_9P_FSCACHE=y
# CONFIG_9P_FS_POSIX_ACL is not set
CONFIG_NLS=y
CONFIG_NLS_DEFAULT="utf8"
CONFIG_NLS_CODEPAGE_437=y
CONFIG_NLS_CODEPAGE_737=y
CONFIG_NLS_CODEPAGE_775=y
CONFIG_NLS_CODEPAGE_850=y
CONFIG_NLS_CODEPAGE_852=y
CONFIG_NLS_CODEPAGE_855=y
CONFIG_NLS_CODEPAGE_857=y
CONFIG_NLS_CODEPAGE_860=y
CONFIG_NLS_CODEPAGE_861=y
CONFIG_NLS_CODEPAGE_862=y
CONFIG_NLS_CODEPAGE_863=y
CONFIG_NLS_CODEPAGE_864=y
CONFIG_NLS_CODEPAGE_865=y
CONFIG_NLS_CODEPAGE_866=y
CONFIG_NLS_CODEPAGE_869=y
CONFIG_NLS_CODEPAGE_936=y
CONFIG_NLS_CODEPAGE_950=y
CONFIG_NLS_CODEPAGE_932=y
CONFIG_NLS_CODEPAGE_949=y
CONFIG_NLS_CODEPAGE_874=y
CONFIG_NLS_ISO8859_8=y
CONFIG_NLS_CODEPAGE_1250=y
CONFIG_NLS_CODEPAGE_1251=y
CONFIG_NLS_ASCII=y
CONFIG_NLS_ISO8859_1=y
CONFIG_NLS_ISO8859_2=y
CONFIG_NLS_ISO8859_3=y
CONFIG_NLS_ISO8859_4=y
CONFIG_NLS_ISO8859_5=y
CONFIG_NLS_ISO8859_6=y
CONFIG_NLS_ISO8859_7=y
CONFIG_NLS_ISO8859_9=y
CONFIG_NLS_ISO8859_13=y
CONFIG_NLS_ISO8859_14=y
CONFIG_NLS_ISO8859_15=y
CONFIG_NLS_KOI8_R=y
CONFIG_NLS_KOI8_U=y
# CONFIG_NLS_MAC_ROMAN is not set
# CONFIG_NLS_MAC_CELTIC is not set
# CONFIG_NLS_MAC_CENTEURO is not set
# CONFIG_NLS_MAC_CROATIAN is not set
# CONFIG_NLS_MAC_CYRILLIC is not set
# CONFIG_NLS_MAC_GAELIC is not set
# CONFIG_NLS_MAC_GREEK is not set
# CONFIG_NLS_MAC_ICELAND is not set
# CONFIG_NLS_MAC_INUIT is not set
# CONFIG_NLS_MAC_ROMANIAN is not set
# CONFIG_NLS_MAC_TURKISH is not set
CONFIG_NLS_UTF8=y
CONFIG_DLM=y
CONFIG_DLM_DEBUG=y

#
# Kernel hacking
#
CONFIG_TRACE_IRQFLAGS_SUPPORT=y
CONFIG_PRINTK_TIME=y
CONFIG_DEFAULT_MESSAGE_LOGLEVEL=4
CONFIG_ENABLE_WARN_DEPRECATED=y
CONFIG_ENABLE_MUST_CHECK=y
CONFIG_FRAME_WARN=2048
CONFIG_MAGIC_SYSRQ=y
CONFIG_STRIP_ASM_SYMS=y
# CONFIG_READABLE_ASM is not set
CONFIG_UNUSED_SYMBOLS=y
CONFIG_DEBUG_FS=y
# CONFIG_HEADERS_CHECK is not set
# CONFIG_DEBUG_SECTION_MISMATCH is not set
CONFIG_DEBUG_KERNEL=y
CONFIG_DEBUG_SHIRQ=y
# CONFIG_LOCKUP_DETECTOR is not set
# CONFIG_HARDLOCKUP_DETECTOR is not set
# CONFIG_PANIC_ON_OOPS is not set
CONFIG_PANIC_ON_OOPS_VALUE=0
CONFIG_DETECT_HUNG_TASK=y
CONFIG_DEFAULT_HUNG_TASK_TIMEOUT=120
CONFIG_BOOTPARAM_HUNG_TASK_PANIC=y
CONFIG_BOOTPARAM_HUNG_TASK_PANIC_VALUE=1
CONFIG_SCHED_DEBUG=y
CONFIG_SCHEDSTATS=y
CONFIG_TIMER_STATS=y
CONFIG_DEBUG_OBJECTS=y
# CONFIG_DEBUG_OBJECTS_SELFTEST is not set
# CONFIG_DEBUG_OBJECTS_FREE is not set
# CONFIG_DEBUG_OBJECTS_TIMERS is not set
# CONFIG_DEBUG_OBJECTS_WORK is not set
# CONFIG_DEBUG_OBJECTS_RCU_HEAD is not set
# CONFIG_DEBUG_OBJECTS_PERCPU_COUNTER is not set
CONFIG_DEBUG_OBJECTS_ENABLE_DEFAULT=1
CONFIG_DEBUG_SLAB=y
# CONFIG_DEBUG_SLAB_LEAK is not set
# CONFIG_DEBUG_KMEMLEAK is not set
CONFIG_DEBUG_RT_MUTEXES=y
CONFIG_DEBUG_PI_LIST=y
CONFIG_RT_MUTEX_TESTER=y
CONFIG_DEBUG_SPINLOCK=y
CONFIG_DEBUG_MUTEXES=y
CONFIG_DEBUG_LOCK_ALLOC=y
CONFIG_PROVE_LOCKING=y
# CONFIG_PROVE_RCU is not set
# CONFIG_SPARSE_RCU_POINTER is not set
CONFIG_LOCKDEP=y
CONFIG_LOCK_STAT=y
# CONFIG_DEBUG_LOCKDEP is not set
CONFIG_TRACE_IRQFLAGS=y
# CONFIG_DEBUG_ATOMIC_SLEEP is not set
CONFIG_DEBUG_LOCKING_API_SELFTESTS=y
CONFIG_STACKTRACE=y
CONFIG_DEBUG_STACK_USAGE=y
# CONFIG_DEBUG_KOBJECT is not set
CONFIG_DEBUG_BUGVERBOSE=y
# CONFIG_DEBUG_INFO is not set
CONFIG_DEBUG_VM=y
CONFIG_DEBUG_VIRTUAL=y
CONFIG_DEBUG_WRITECOUNT=y
CONFIG_DEBUG_MEMORY_INIT=y
CONFIG_DEBUG_LIST=y
# CONFIG_TEST_LIST_SORT is not set
CONFIG_DEBUG_SG=y
CONFIG_DEBUG_NOTIFIERS=y
CONFIG_DEBUG_CREDENTIALS=y
CONFIG_ARCH_WANT_FRAME_POINTERS=y
CONFIG_FRAME_POINTER=y
CONFIG_BOOT_PRINTK_DELAY=y
# CONFIG_RCU_TORTURE_TEST is not set
CONFIG_RCU_CPU_STALL_TIMEOUT=60
# CONFIG_RCU_CPU_STALL_INFO is not set
CONFIG_RCU_TRACE=y
CONFIG_KPROBES_SANITY_TEST=y
# CONFIG_BACKTRACE_SELF_TEST is not set
CONFIG_DEBUG_BLOCK_EXT_DEVT=y
CONFIG_DEBUG_FORCE_WEAK_PER_CPU=y
CONFIG_DEBUG_PER_CPU_MAPS=y
CONFIG_LKDTM=y
# CONFIG_NOTIFIER_ERROR_INJECTION is not set
CONFIG_FAULT_INJECTION=y
# CONFIG_FAILSLAB is not set
# CONFIG_FAIL_PAGE_ALLOC is not set
# CONFIG_FAIL_MAKE_REQUEST is not set
# CONFIG_FAIL_IO_TIMEOUT is not set
# CONFIG_FAIL_MMC_REQUEST is not set
# CONFIG_FAULT_INJECTION_DEBUG_FS is not set
CONFIG_LATENCYTOP=y
CONFIG_DEBUG_PAGEALLOC=y
CONFIG_WANT_PAGE_DEBUG_FLAGS=y
CONFIG_PAGE_GUARD=y
CONFIG_USER_STACKTRACE_SUPPORT=y
CONFIG_NOP_TRACER=y
CONFIG_HAVE_FUNCTION_TRACER=y
CONFIG_HAVE_FUNCTION_GRAPH_TRACER=y
CONFIG_HAVE_FUNCTION_GRAPH_FP_TEST=y
CONFIG_HAVE_FUNCTION_TRACE_MCOUNT_TEST=y
CONFIG_HAVE_DYNAMIC_FTRACE=y
CONFIG_HAVE_FTRACE_MCOUNT_RECORD=y
CONFIG_HAVE_SYSCALL_TRACEPOINTS=y
CONFIG_HAVE_C_RECORDMCOUNT=y
CONFIG_TRACER_MAX_TRACE=y
CONFIG_RING_BUFFER=y
CONFIG_EVENT_TRACING=y
CONFIG_EVENT_POWER_TRACING_DEPRECATED=y
CONFIG_CONTEXT_SWITCH_TRACER=y
CONFIG_RING_BUFFER_ALLOW_SWAP=y
CONFIG_TRACING=y
CONFIG_GENERIC_TRACER=y
CONFIG_TRACING_SUPPORT=y
CONFIG_FTRACE=y
CONFIG_FUNCTION_TRACER=y
CONFIG_FUNCTION_GRAPH_TRACER=y
CONFIG_IRQSOFF_TRACER=y
CONFIG_SCHED_TRACER=y
CONFIG_FTRACE_SYSCALLS=y
CONFIG_BRANCH_PROFILE_NONE=y
# CONFIG_PROFILE_ANNOTATED_BRANCHES is not set
# CONFIG_PROFILE_ALL_BRANCHES is not set
# CONFIG_STACK_TRACER is not set
CONFIG_BLK_DEV_IO_TRACE=y
CONFIG_KPROBE_EVENT=y
# CONFIG_UPROBE_EVENT is not set
CONFIG_PROBE_EVENTS=y
CONFIG_DYNAMIC_FTRACE=y
# CONFIG_FUNCTION_PROFILER is not set
CONFIG_FTRACE_MCOUNT_RECORD=y
CONFIG_FTRACE_SELFTEST=y
CONFIG_FTRACE_STARTUP_TEST=y
# CONFIG_EVENT_TRACE_TEST_SYSCALLS is not set
CONFIG_MMIOTRACE=y
# CONFIG_MMIOTRACE_TEST is not set
# CONFIG_RING_BUFFER_BENCHMARK is not set
# CONFIG_PROVIDE_OHCI1394_DMA_INIT is not set
# CONFIG_FIREWIRE_OHCI_REMOTE_DMA is not set
# CONFIG_DYNAMIC_DEBUG is not set
CONFIG_DMA_API_DEBUG=y
CONFIG_ATOMIC64_SELFTEST=y
# CONFIG_ASYNC_RAID6_TEST is not set
# CONFIG_SAMPLES is not set
CONFIG_HAVE_ARCH_KGDB=y
# CONFIG_KGDB is not set
CONFIG_HAVE_ARCH_KMEMCHECK=y
# CONFIG_TEST_KSTRTOX is not set
CONFIG_STRICT_DEVMEM=y
CONFIG_X86_VERBOSE_BOOTUP=y
CONFIG_EARLY_PRINTK=y
# CONFIG_EARLY_PRINTK_DBGP is not set
CONFIG_DEBUG_STACKOVERFLOW=y
CONFIG_X86_PTDUMP=y
CONFIG_DEBUG_RODATA=y
CONFIG_DEBUG_RODATA_TEST=y
# CONFIG_DEBUG_SET_MODULE_RONX is not set
CONFIG_DEBUG_NX_TEST=m
# CONFIG_DEBUG_TLBFLUSH is not set
# CONFIG_IOMMU_DEBUG is not set
# CONFIG_IOMMU_STRESS is not set
CONFIG_HAVE_MMIOTRACE_SUPPORT=y
# CONFIG_X86_DECODER_SELFTEST is not set
CONFIG_IO_DELAY_TYPE_0X80=0
CONFIG_IO_DELAY_TYPE_0XED=1
CONFIG_IO_DELAY_TYPE_UDELAY=2
CONFIG_IO_DELAY_TYPE_NONE=3
CONFIG_IO_DELAY_0X80=y
# CONFIG_IO_DELAY_0XED is not set
# CONFIG_IO_DELAY_UDELAY is not set
# CONFIG_IO_DELAY_NONE is not set
CONFIG_DEFAULT_IO_DELAY_TYPE=0
# CONFIG_DEBUG_BOOT_PARAMS is not set
# CONFIG_CPA_DEBUG is not set
CONFIG_OPTIMIZE_INLINING=y
# CONFIG_DEBUG_STRICT_USER_COPY_CHECKS is not set
# CONFIG_DEBUG_NMI_SELFTEST is not set

#
# Security options
#
CONFIG_KEYS=y
# CONFIG_TRUSTED_KEYS is not set
# CONFIG_ENCRYPTED_KEYS is not set
CONFIG_KEYS_DEBUG_PROC_KEYS=y
# CONFIG_SECURITY_DMESG_RESTRICT is not set
CONFIG_SECURITY=y
CONFIG_SECURITYFS=y
CONFIG_SECURITY_NETWORK=y
CONFIG_SECURITY_NETWORK_XFRM=y
CONFIG_SECURITY_PATH=y
CONFIG_LSM_MMAP_MIN_ADDR=65536
CONFIG_SECURITY_SELINUX=y
# CONFIG_SECURITY_SELINUX_BOOTPARAM is not set
# CONFIG_SECURITY_SELINUX_DISABLE is not set
CONFIG_SECURITY_SELINUX_DEVELOP=y
CONFIG_SECURITY_SELINUX_AVC_STATS=y
CONFIG_SECURITY_SELINUX_CHECKREQPROT_VALUE=1
# CONFIG_SECURITY_SELINUX_POLICYDB_VERSION_MAX is not set
CONFIG_SECURITY_TOMOYO=y
CONFIG_SECURITY_TOMOYO_MAX_ACCEPT_ENTRY=2048
CONFIG_SECURITY_TOMOYO_MAX_AUDIT_LOG=1024
# CONFIG_SECURITY_TOMOYO_OMIT_USERSPACE_LOADER is not set
CONFIG_SECURITY_TOMOYO_POLICY_LOADER="/sbin/tomoyo-init"
CONFIG_SECURITY_TOMOYO_ACTIVATION_TRIGGER="/sbin/init"
# CONFIG_SECURITY_APPARMOR is not set
# CONFIG_SECURITY_YAMA is not set
# CONFIG_IMA is not set
# CONFIG_EVM is not set
# CONFIG_DEFAULT_SECURITY_SELINUX is not set
# CONFIG_DEFAULT_SECURITY_TOMOYO is not set
CONFIG_DEFAULT_SECURITY_DAC=y
CONFIG_DEFAULT_SECURITY=""
CONFIG_XOR_BLOCKS=y
CONFIG_ASYNC_CORE=y
CONFIG_ASYNC_MEMCPY=y
CONFIG_ASYNC_XOR=y
CONFIG_ASYNC_PQ=y
CONFIG_ASYNC_RAID6_RECOV=y
CONFIG_ASYNC_TX_DISABLE_PQ_VAL_DMA=y
CONFIG_ASYNC_TX_DISABLE_XOR_VAL_DMA=y
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
CONFIG_CRYPTO_MANAGER_DISABLE_TESTS=y
CONFIG_CRYPTO_GF128MUL=y
CONFIG_CRYPTO_NULL=y
CONFIG_CRYPTO_PCRYPT=y
CONFIG_CRYPTO_WORKQUEUE=y
CONFIG_CRYPTO_CRYPTD=y
CONFIG_CRYPTO_AUTHENC=y
CONFIG_CRYPTO_TEST=m
CONFIG_CRYPTO_ABLK_HELPER_X86=y

#
# Authenticated Encryption with Associated Data
#
CONFIG_CRYPTO_CCM=y
CONFIG_CRYPTO_GCM=y
CONFIG_CRYPTO_SEQIV=y

#
# Block modes
#
CONFIG_CRYPTO_CBC=y
CONFIG_CRYPTO_CTR=y
CONFIG_CRYPTO_CTS=y
CONFIG_CRYPTO_ECB=y
CONFIG_CRYPTO_LRW=y
CONFIG_CRYPTO_PCBC=y
CONFIG_CRYPTO_XTS=y

#
# Hash modes
#
CONFIG_CRYPTO_HMAC=y
CONFIG_CRYPTO_XCBC=y
CONFIG_CRYPTO_VMAC=y

#
# Digest
#
CONFIG_CRYPTO_CRC32C=y
CONFIG_CRYPTO_CRC32C_INTEL=y
CONFIG_CRYPTO_GHASH=y
CONFIG_CRYPTO_MD4=y
CONFIG_CRYPTO_MD5=y
CONFIG_CRYPTO_MICHAEL_MIC=y
CONFIG_CRYPTO_RMD128=y
CONFIG_CRYPTO_RMD160=y
CONFIG_CRYPTO_RMD256=y
CONFIG_CRYPTO_RMD320=y
CONFIG_CRYPTO_SHA1=y
# CONFIG_CRYPTO_SHA1_SSSE3 is not set
CONFIG_CRYPTO_SHA256=y
CONFIG_CRYPTO_SHA512=y
CONFIG_CRYPTO_TGR192=y
CONFIG_CRYPTO_WP512=y
CONFIG_CRYPTO_GHASH_CLMUL_NI_INTEL=y

#
# Ciphers
#
CONFIG_CRYPTO_AES=y
CONFIG_CRYPTO_AES_X86_64=y
CONFIG_CRYPTO_AES_NI_INTEL=y
CONFIG_CRYPTO_ANUBIS=y
CONFIG_CRYPTO_ARC4=y
CONFIG_CRYPTO_BLOWFISH=y
CONFIG_CRYPTO_BLOWFISH_COMMON=y
# CONFIG_CRYPTO_BLOWFISH_X86_64 is not set
CONFIG_CRYPTO_CAMELLIA=y
# CONFIG_CRYPTO_CAMELLIA_X86_64 is not set
CONFIG_CRYPTO_CAST5=y
CONFIG_CRYPTO_CAST6=y
CONFIG_CRYPTO_DES=y
CONFIG_CRYPTO_FCRYPT=y
CONFIG_CRYPTO_KHAZAD=y
CONFIG_CRYPTO_SALSA20=y
CONFIG_CRYPTO_SALSA20_X86_64=y
CONFIG_CRYPTO_SEED=y
CONFIG_CRYPTO_SERPENT=y
# CONFIG_CRYPTO_SERPENT_SSE2_X86_64 is not set
# CONFIG_CRYPTO_SERPENT_AVX_X86_64 is not set
CONFIG_CRYPTO_TEA=y
CONFIG_CRYPTO_TWOFISH=y
CONFIG_CRYPTO_TWOFISH_COMMON=y
CONFIG_CRYPTO_TWOFISH_X86_64=y
# CONFIG_CRYPTO_TWOFISH_X86_64_3WAY is not set
# CONFIG_CRYPTO_TWOFISH_AVX_X86_64 is not set

#
# Compression
#
CONFIG_CRYPTO_DEFLATE=y
CONFIG_CRYPTO_ZLIB=y
CONFIG_CRYPTO_LZO=y

#
# Random Number Generation
#
CONFIG_CRYPTO_ANSI_CPRNG=y
# CONFIG_CRYPTO_USER_API_HASH is not set
# CONFIG_CRYPTO_USER_API_SKCIPHER is not set
CONFIG_CRYPTO_HW=y
CONFIG_CRYPTO_DEV_PADLOCK=y
CONFIG_CRYPTO_DEV_PADLOCK_AES=y
CONFIG_CRYPTO_DEV_PADLOCK_SHA=y
CONFIG_HAVE_KVM=y
CONFIG_HAVE_KVM_IRQCHIP=y
CONFIG_HAVE_KVM_EVENTFD=y
CONFIG_KVM_APIC_ARCHITECTURE=y
CONFIG_KVM_MMIO=y
CONFIG_KVM_ASYNC_PF=y
CONFIG_HAVE_KVM_MSI=y
CONFIG_VIRTUALIZATION=y
CONFIG_KVM=y
CONFIG_KVM_INTEL=y
CONFIG_KVM_AMD=y
# CONFIG_KVM_MMU_AUDIT is not set
CONFIG_VHOST_NET=y
CONFIG_BINARY_PRINTF=y

#
# Library routines
#
CONFIG_RAID6_PQ=y
CONFIG_BITREVERSE=y
CONFIG_GENERIC_STRNCPY_FROM_USER=y
CONFIG_GENERIC_STRNLEN_USER=y
CONFIG_GENERIC_FIND_FIRST_BIT=y
CONFIG_GENERIC_PCI_IOMAP=y
CONFIG_GENERIC_IOMAP=y
CONFIG_GENERIC_IO=y
CONFIG_CRC_CCITT=y
CONFIG_CRC16=y
CONFIG_CRC_T10DIF=y
CONFIG_CRC_ITU_T=y
CONFIG_CRC32=y
# CONFIG_CRC32_SELFTEST is not set
CONFIG_CRC32_SLICEBY8=y
# CONFIG_CRC32_SLICEBY4 is not set
# CONFIG_CRC32_SARWATE is not set
# CONFIG_CRC32_BIT is not set
CONFIG_CRC7=y
CONFIG_LIBCRC32C=y
# CONFIG_CRC8 is not set
CONFIG_ZLIB_INFLATE=y
CONFIG_ZLIB_DEFLATE=y
CONFIG_LZO_COMPRESS=y
CONFIG_LZO_DECOMPRESS=y
CONFIG_XZ_DEC=y
CONFIG_XZ_DEC_X86=y
CONFIG_XZ_DEC_POWERPC=y
CONFIG_XZ_DEC_IA64=y
CONFIG_XZ_DEC_ARM=y
CONFIG_XZ_DEC_ARMTHUMB=y
CONFIG_XZ_DEC_SPARC=y
CONFIG_XZ_DEC_BCJ=y
# CONFIG_XZ_DEC_TEST is not set
CONFIG_DECOMPRESS_GZIP=y
CONFIG_DECOMPRESS_BZIP2=y
CONFIG_DECOMPRESS_LZMA=y
CONFIG_DECOMPRESS_XZ=y
CONFIG_DECOMPRESS_LZO=y
CONFIG_GENERIC_ALLOCATOR=y
CONFIG_REED_SOLOMON=y
CONFIG_REED_SOLOMON_DEC16=y
CONFIG_TEXTSEARCH=y
CONFIG_TEXTSEARCH_KMP=y
CONFIG_TEXTSEARCH_BM=y
CONFIG_TEXTSEARCH_FSM=y
CONFIG_BTREE=y
CONFIG_HAS_IOMEM=y
CONFIG_HAS_IOPORT=y
CONFIG_HAS_DMA=y
CONFIG_CHECK_SIGNATURE=y
# CONFIG_CPUMASK_OFFSTACK is not set
CONFIG_CPU_RMAP=y
CONFIG_DQL=y
CONFIG_NLATTR=y
CONFIG_ARCH_HAS_ATOMIC64_DEC_IF_POSITIVE=y
CONFIG_LRU_CACHE=y
CONFIG_AVERAGE=y
# CONFIG_CORDIC is not set
# CONFIG_DDR is not set

--r5Pyd7+fXNt84Ff3--
