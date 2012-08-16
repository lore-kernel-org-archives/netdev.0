From: Fengguang Wu <fengguang.wu@intel.com>
Subject: suspicious RCU usage in xfrm_net_init()
Date: Thu, 16 Aug 2012 15:37:24 +0800
Message-ID: <20120816073724.GA10660@localhost>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="45Z9DzgjV8m4Oswq"
Cc: netdev@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>
To: wfg@linux.intel.com, Priyanka Jain <Priyanka.Jain@freescale.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--45Z9DzgjV8m4Oswq
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

Hi Priyanka,

The below warning shows up, probably related to this commit:

418a99ac6ad487dc9c42e6b0e85f941af56330f2 Replace rwlock on xfrm_policy_afinfo with rcu

[    0.921216] 
[    0.921645] ===============================
[    0.922766] [ INFO: suspicious RCU usage. ]
[    0.923887] 3.5.0-01540-g1669891 #64 Not tainted
[    0.925123] -------------------------------
[    0.932860] /c/kernel-tests/src/tip/net/xfrm/xfrm_policy.c:2504 suspicious rcu_dereference_check() usage!
[    0.935361] 
[    0.935361] other info that might help us debug this:
[    0.935361] 
[    0.937472] 
[    0.937472] rcu_scheduler_active = 1, debug_locks = 0
[    0.939182] 2 locks held by swapper/1:
[    0.940171]  #0:  (net_mutex){+.+.+.}, at: [<ffffffff814e1ad0>] register_pernet_subsys+0x21/0x57
[    0.942705]  #1:  (rcu_read_lock_bh){......}, at: [<ffffffff822c7329>] xfrm_net_init+0x1e4/0x437
[    0.951507] 
[    0.951507] stack backtrace:
[    0.952660] Pid: 1, comm: swapper Not tainted 3.5.0-01540-g1669891 #64
[    0.954364] Call Trace:
[    0.955074]  [<ffffffff8108b375>] lockdep_rcu_suspicious+0x174/0x187
[    0.956736]  [<ffffffff822c7453>] xfrm_net_init+0x30e/0x437
[    0.958205]  [<ffffffff822c7329>] ? xfrm_net_init+0x1e4/0x437
[    0.959712]  [<ffffffff814e134a>] ops_init+0x1bb/0x1ff
[    0.961067]  [<ffffffff810861f9>] ? trace_hardirqs_on+0x1b/0x24
[    0.962644]  [<ffffffff814e17cd>] register_pernet_operations.isra.5+0x9d/0xfe
[    0.971376]  [<ffffffff814e1adf>] register_pernet_subsys+0x30/0x57
[    0.972992]  [<ffffffff822c7130>] xfrm_init+0x17/0x2c
[    0.974316]  [<ffffffff822c2f8c>] ip_rt_init+0x82/0xe7
[    0.975668]  [<ffffffff822c31dc>] ip_init+0x10/0x25
[    0.976952]  [<ffffffff822c3f77>] inet_init+0x235/0x360
[    0.978352]  [<ffffffff822c3d42>] ? devinet_init+0xf2/0xf2
[    0.979808]  [<ffffffff82283252>] do_one_initcall+0xb4/0x203
[    0.981313]  [<ffffffff8228354a>] kernel_init+0x1a9/0x29a
[    0.982732]  [<ffffffff822826d9>] ? loglevel+0x46/0x46
[    0.990889]  [<ffffffff816d3d84>] kernel_thread_helper+0x4/0x10
[    0.992472]  [<ffffffff816d262c>] ? retint_restore_args+0x13/0x13
[    0.994076]  [<ffffffff822833a1>] ? do_one_initcall+0x203/0x203
[    0.995636]  [<ffffffff816d3d80>] ? gs_change+0x13/0x13
[    0.997197] TCP established hash table entries: 8192 (order: 5, 131072 bytes)
[    1.000074] TCP bind hash table entries: 8192 (order: 7, 655360 bytes)

Thanks,
Fengguang

--45Z9DzgjV8m4Oswq
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename="dmesg-kvm-bens-13066-2012-08-16-03-09-09-3.5.0-01540-g1669891-64"

[    0.000000] Linux version 3.5.0-01540-g1669891 (kbuild@snb) (gcc version 4.7.1 (Debian 4.7.1-6) ) #64 Thu Aug 16 03:08:24 CST 2012
[    0.000000] Command line: trinity=2m hung_task_panic=1 branch=wireless-next/for-davem log_buf_len=8M ignore_loglevel debug sched_debug apic=debug dynamic_printk sysrq_always_enabled panic=10  prompt_ramdisk=0 console=ttyS0,115200 console=tty0 vga=normal  root=/dev/ram0 rw link=vmlinuz-2012-08-16-03-09-03-wireless-next:for-davem:1669891-1669891-x86_64-randconfig-s108-1-bens BOOT_IMAGE=kernel-tests/kernels/x86_64-randconfig-s108/1669891/vmlinuz-3.5.0-01540-g1669891
[    0.000000] KERNEL supported cpus:
[    0.000000]   AMD AuthenticAMD
[    0.000000] CPU: vendor_id 'GenuineIntel' unknown, using generic init.
[    0.000000] CPU: Your system may be unstable.
[    0.000000] e820: BIOS-provided physical RAM map:
[    0.000000] BIOS-e820: [mem 0x0000000000000000-0x0000000000093bff] usable
[    0.000000] BIOS-e820: [mem 0x0000000000093c00-0x000000000009ffff] reserved
[    0.000000] BIOS-e820: [mem 0x00000000000f0000-0x00000000000fffff] reserved
[    0.000000] BIOS-e820: [mem 0x0000000000100000-0x000000000fffdfff] usable
[    0.000000] BIOS-e820: [mem 0x000000000fffe000-0x000000000fffffff] reserved
[    0.000000] BIOS-e820: [mem 0x00000000feffc000-0x00000000feffffff] reserved
[    0.000000] BIOS-e820: [mem 0x00000000fffc0000-0x00000000ffffffff] reserved
[    0.000000] debug: ignoring loglevel setting.
[    0.000000] NX (Execute Disable) protection: active
[    0.000000] Hypervisor detected: KVM
[    0.000000] e820: update [mem 0x00000000-0x0000ffff] usable ==> reserved
[    0.000000] e820: remove [mem 0x000a0000-0x000fffff] usable
[    0.000000] No AGP bridge found
[    0.000000] e820: last_pfn = 0xfffe max_arch_pfn = 0x400000000
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
[    0.000000] found SMP MP-table at [mem 0x000fdac0-0x000fdacf] mapped at [ffff8800000fdac0]
[    0.000000]   mpc: fdad0-fdbec
[    0.000000] initial memory mapped: [mem 0x00000000-0x1fffffff]
[    0.000000] Base memory trampoline at [ffff88000008d000] 8d000 size 24576
[    0.000000] init_memory_mapping: [mem 0x00000000-0x0fffdfff]
[    0.000000]  [mem 0x00000000-0x0fffdfff] page 4k
[    0.000000] kernel direct mapping tables up to 0xfffdfff @ [mem 0x0e854000-0x0e8d5fff]
[    0.000000] log_buf_len: 8388608
[    0.000000] early log buf free: 128008(97%)
[    0.000000] RAMDISK: [mem 0x0e8d6000-0x0ffeffff]
[    0.000000] ACPI: RSDP 00000000000fd930 00014 (v00 BOCHS )
[    0.000000] ACPI: RSDT 000000000fffe550 00038 (v01 BOCHS  BXPCRSDT 00000001 BXPC 00000001)
[    0.000000] ACPI: FACP 000000000fffff80 00074 (v01 BOCHS  BXPCFACP 00000001 BXPC 00000001)
[    0.000000] ACPI: DSDT 000000000fffe590 01121 (v01   BXPC   BXDSDT 00000001 INTL 20100528)
[    0.000000] ACPI: FACS 000000000fffff40 00040
[    0.000000] ACPI: SSDT 000000000ffffe40 000FF (v01 BOCHS  BXPCSSDT 00000001 BXPC 00000001)
[    0.000000] ACPI: APIC 000000000ffffd50 00080 (v01 BOCHS  BXPCAPIC 00000001 BXPC 00000001)
[    0.000000] ACPI: HPET 000000000ffffd10 00038 (v01 BOCHS  BXPCHPET 00000001 BXPC 00000001)
[    0.000000] ACPI: SSDT 000000000ffff6c0 00644 (v01   BXPC BXSSDTPC 00000001 INTL 20100528)
[    0.000000] ACPI: Local APIC address 0xfee00000
[    0.000000] mapped APIC to ffffffffff5fb000 (        fee00000)
[    0.000000] kvm-clock: Using msrs 4b564d01 and 4b564d00
[    0.000000] kvm-clock: cpu 0, msr 0:1e37c41, boot clock
[    0.000000]  [ffffea0000000000-ffffea00003fffff] PMD -> [ffff88000d400000-ffff88000d7fffff] on node 0
[    0.000000] Zone ranges:
[    0.000000]   DMA32    [mem 0x00010000-0xffffffff]
[    0.000000]   Normal   empty
[    0.000000] Movable zone start for each node
[    0.000000] Early memory node ranges
[    0.000000]   node   0: [mem 0x00010000-0x00092fff]
[    0.000000]   node   0: [mem 0x00100000-0x0fffdfff]
[    0.000000] On node 0 totalpages: 65409
[    0.000000]   DMA32 zone: 1024 pages used for memmap
[    0.000000]   DMA32 zone: 6 pages reserved
[    0.000000]   DMA32 zone: 64379 pages, LIFO batch:15
[    0.000000] ACPI: PM-Timer IO Port: 0xb008
[    0.000000] ACPI: Local APIC address 0xfee00000
[    0.000000] mapped APIC to ffffffffff5fb000 (        fee00000)
[    0.000000] ACPI: LAPIC (acpi_id[0x00] lapic_id[0x00] enabled)
[    0.000000] ACPI: LAPIC (acpi_id[0x01] lapic_id[0x01] enabled)
[    0.000000] ACPI: NR_CPUS/possible_cpus limit of 1 reached.  Processor 1/0x1 ignored.
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
[    0.000000] mapped IOAPIC to ffffffffff5fa000 (fec00000)
[    0.000000] nr_irqs_gsi: 40
[    0.000000] KVM setup async PF for cpu 0
[    0.000000] kvm-stealtime: cpu 0, msr 1e37640
[    0.000000] e820: [mem 0x10000000-0xfeffbfff] available for PCI devices
[    0.000000] Booting paravirtualized kernel on KVM
[    0.000000] pcpu-alloc: s0 r0 d32768 u32768 alloc=1*32768
[    0.000000] pcpu-alloc: [0] 0 
[    0.000000] Built 1 zonelists in Zone order, mobility grouping on.  Total pages: 64379
[    0.000000] Kernel command line: trinity=2m hung_task_panic=1 branch=wireless-next/for-davem log_buf_len=8M ignore_loglevel debug sched_debug apic=debug dynamic_printk sysrq_always_enabled panic=10  prompt_ramdisk=0 console=ttyS0,115200 console=tty0 vga=normal  root=/dev/ram0 rw link=vmlinuz-2012-08-16-03-09-03-wireless-next:for-davem:1669891-1669891-x86_64-randconfig-s108-1-bens BOOT_IMAGE=kernel-tests/kernels/x86_64-randconfig-s108/1669891/vmlinuz-3.5.0-01540-g1669891
[    0.000000] sysrq: sysrq always enabled.
[    0.000000] PID hash table entries: 1024 (order: 1, 8192 bytes)
[    0.000000] Dentry cache hash table entries: 32768 (order: 6, 262144 bytes)
[    0.000000] Inode-cache hash table entries: 16384 (order: 5, 131072 bytes)
[    0.000000] __ex_table already sorted, skipping sort
[    0.000000] Checking aperture...
[    0.000000] No AGP bridge found
[    0.000000] Memory: 192584k/262136k available (6993k kernel code, 500k absent, 69052k reserved, 11939k data, 496k init)
[    0.000000] SLUB: Genslabs=15, HWalign=64, Order=0-3, MinObjects=0, CPUs=1, Nodes=1
[    0.000000] NR_IRQS:4352 nr_irqs:256 16
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
[    0.000000] hpet clockevent registered
[    0.000000] tsc: Detected 2666.696 MHz processor
[    0.010000] Calibrating delay loop (skipped) preset value.. 5333.39 BogoMIPS (lpj=26666960)
[    0.010000] pid_max: default: 4096 minimum: 301
[    0.010000] Mount-cache hash table entries: 256
[    0.010000] Last level iTLB entries: 4KB 0, 2MB 0, 4MB 0
[    0.010000] Last level dTLB entries: 4KB 0, 2MB 0, 4MB 0
[    0.010000] tlb_flushall_shift is 0xffffffff
[    0.010000] CPU: GenuineIntel Common KVM processor stepping 01
[    0.014049] ACPI: Core revision 20120711
[    0.019025] Performance Events: 
[    0.020521] NMI watchdog: disabled (cpu0): hardware events not enabled
[    0.021956] Getting VERSION: 50014
[    0.022611] Getting VERSION: 50014
[    0.023254] Getting ID: 0
[    0.023758] Getting ID: ff000000
[    0.024381] Getting LVT0: 8700
[    0.024962] Getting LVT1: 8400
[    0.025731] enabled ExtINT on CPU#0
[    0.027699] ENABLING IO-APIC IRQs
[    0.028326] init IO_APIC IRQs
[    0.028869]  apic 2 pin 0 not connected
[    0.029627] IOAPIC[0]: Set routing entry (2-1 -> 0x31 -> IRQ 1 Mode:0 Active:0 Dest:1)
[    0.030045] IOAPIC[0]: Set routing entry (2-2 -> 0x30 -> IRQ 0 Mode:0 Active:0 Dest:1)
[    0.031492] IOAPIC[0]: Set routing entry (2-3 -> 0x33 -> IRQ 3 Mode:0 Active:0 Dest:1)
[    0.032938] IOAPIC[0]: Set routing entry (2-4 -> 0x34 -> IRQ 4 Mode:0 Active:0 Dest:1)
[    0.034387] IOAPIC[0]: Set routing entry (2-5 -> 0x35 -> IRQ 5 Mode:1 Active:0 Dest:1)
[    0.035848] IOAPIC[0]: Set routing entry (2-6 -> 0x36 -> IRQ 6 Mode:0 Active:0 Dest:1)
[    0.037329] IOAPIC[0]: Set routing entry (2-7 -> 0x37 -> IRQ 7 Mode:0 Active:0 Dest:1)
[    0.038789] IOAPIC[0]: Set routing entry (2-8 -> 0x38 -> IRQ 8 Mode:0 Active:0 Dest:1)
[    0.040037] IOAPIC[0]: Set routing entry (2-9 -> 0x39 -> IRQ 9 Mode:1 Active:0 Dest:1)
[    0.041473] IOAPIC[0]: Set routing entry (2-10 -> 0x3a -> IRQ 10 Mode:1 Active:0 Dest:1)
[    0.042949] IOAPIC[0]: Set routing entry (2-11 -> 0x3b -> IRQ 11 Mode:1 Active:0 Dest:1)
[    0.044419] IOAPIC[0]: Set routing entry (2-12 -> 0x3c -> IRQ 12 Mode:0 Active:0 Dest:1)
[    0.045885] IOAPIC[0]: Set routing entry (2-13 -> 0x3d -> IRQ 13 Mode:0 Active:0 Dest:1)
[    0.047347] IOAPIC[0]: Set routing entry (2-14 -> 0x3e -> IRQ 14 Mode:0 Active:0 Dest:1)
[    0.050035] IOAPIC[0]: Set routing entry (2-15 -> 0x3f -> IRQ 15 Mode:0 Active:0 Dest:1)
[    0.051490]  apic 2 pin 16 not connected
[    0.052198]  apic 2 pin 17 not connected
[    0.052904]  apic 2 pin 18 not connected
[    0.053606]  apic 2 pin 19 not connected
[    0.054314]  apic 2 pin 20 not connected
[    0.055024]  apic 2 pin 21 not connected
[    0.055725]  apic 2 pin 22 not connected
[    0.056434]  apic 2 pin 23 not connected
[    0.057322] ..TIMER: vector=0x30 apic1=0 pin1=2 apic2=-1 pin2=-1
[    0.058862] Using local APIC timer interrupts.
[    0.058862] calibrating APIC timer ...
[    0.070000] ... lapic delta = 6248314
[    0.070000] ... PM-Timer delta = 357841
[    0.070000] ... PM-Timer result ok
[    0.070000] ..... delta 6248314
[    0.070000] ..... mult: 268363042
[    0.070000] ..... calibration result: 9997302
[    0.070000] ..... CPU clock speed is 2665.8143 MHz.
[    0.070000] ..... host bus clock speed is 999.7302 MHz.
[    0.070000] device: 'platform': device_add
[    0.070000] PM: Adding info for No Bus:platform
[    0.070000] bus: 'platform': registered
[    0.070000] bus: 'cpu': registered
[    0.070000] device: 'cpu': device_add
[    0.070000] PM: Adding info for No Bus:cpu
[    0.070000] bus: 'memory': registered
[    0.070000] device: 'memory': device_add
[    0.070000] PM: Adding info for No Bus:memory
[    0.070042] device: 'memory0': device_add
[    0.071157] bus: 'memory': add device memory0
[    0.072441] PM: Adding info for memory:memory0
[    0.073699] device: 'memory1': device_add
[    0.074761] bus: 'memory': add device memory1
[    0.075973] PM: Adding info for memory:memory1
[    0.079216] atomic64 test passed for x86-64 platform with CX8 and with SSE
[    0.080226] bus: 'virtio': registered
[    0.080926] device class 'regulator': registering
[    0.082180] Registering platform device 'reg-dummy'. Parent at platform
[    0.083616] device: 'reg-dummy': device_add
[    0.084558] bus: 'platform': add device reg-dummy
[    0.085625] PM: Adding info for platform:reg-dummy
[    0.090057] bus: 'platform': add driver reg-dummy
[    0.100039] bus: 'platform': driver_probe_device: matched device reg-dummy with driver reg-dummy
[    0.101955] bus: 'platform': really_probe: probing driver reg-dummy with device reg-dummy
[    0.103846] device: 'regulator.0': device_add
[    0.105032] PM: Adding info for No Bus:regulator.0
[    0.106183] dummy: 
[    0.106827] driver: 'reg-dummy': driver_bound: bound to device 'reg-dummy'
[    0.110036] bus: 'platform': really_probe: bound device reg-dummy to driver reg-dummy
[    0.111879] RTC time: 19:08:52, date: 08/15/12
[    0.120490] NET: Registered protocol family 16
[    0.121857] device class 'bdi': registering
[    0.122860] device class 'pci_bus': registering
[    0.123929] bus: 'pci': registered
[    0.124697] device class 'video_output': registering
[    0.125851] device class 'tty': registering
[    0.126863] bus: 'i2c': registered
[    0.127626] bus: 'i2c': add driver dummy
[    0.130388] ACPI: bus type pci registered
[    0.131378] PCI: Using configuration type 1 for base access
[    0.138925] device: 'cpu0': device_add
[    0.139841] bus: 'cpu': add device cpu0
[    0.140051] PM: Adding info for cpu:cpu0
[    0.149135] device: 'default': device_add
[    0.150127] PM: Adding info for No Bus:default
[    0.151567] device class 'graphics': registering
[    0.152667] ACPI: Added _OSI(Module Device)
[    0.153593] ACPI: Added _OSI(Processor Device)
[    0.154574] ACPI: Added _OSI(3.0 _SCP Extensions)
[    0.155612] ACPI: Added _OSI(Processor Aggregator Device)
[    0.161756] ACPI: EC: Look up EC in DSDT
[    0.172859] ACPI: Interpreter enabled
[    0.173839] ACPI: (supports S0 S3 S5)
[    0.174977] ACPI: Using IOAPIC for interrupt routing
[    0.176320] bus: 'acpi': registered
[    0.177260] bus: 'acpi': add driver power
[    0.178418] device: 'LNXSYSTM:00': device_add
[    0.179620] bus: 'acpi': add device LNXSYSTM:00
[    0.180089] PM: Adding info for acpi:LNXSYSTM:00
[    0.181557] device: 'device:00': device_add
[    0.182683] bus: 'acpi': add device device:00
[    0.183914] PM: Adding info for acpi:device:00
[    0.185213] device: 'PNP0A03:00': device_add
[    0.186366] bus: 'acpi': add device PNP0A03:00
[    0.187633] PM: Adding info for acpi:PNP0A03:00
[    0.191186] device: 'device:01': device_add
[    0.192307] bus: 'acpi': add device device:01
[    0.193542] PM: Adding info for acpi:device:01
[    0.194910] device: 'device:02': device_add
[    0.196041] bus: 'acpi': add device device:02
[    0.197249] PM: Adding info for acpi:device:02
[    0.198570] device: 'PNP0B00:00': device_add
[    0.199725] bus: 'acpi': add device PNP0B00:00
[    0.200090] PM: Adding info for acpi:PNP0B00:00
[    0.201491] device: 'PNP0303:00': device_add
[    0.202657] bus: 'acpi': add device PNP0303:00
[    0.203881] PM: Adding info for acpi:PNP0303:00
[    0.205301] device: 'PNP0F13:00': device_add
[    0.206441] bus: 'acpi': add device PNP0F13:00
[    0.207653] PM: Adding info for acpi:PNP0F13:00
[    0.209032] device: 'PNP0700:00': device_add
[    0.210017] bus: 'acpi': add device PNP0700:00
[    0.211273] PM: Adding info for acpi:PNP0700:00
[    0.212823] device: 'PNP0400:00': device_add
[    0.213988] bus: 'acpi': add device PNP0400:00
[    0.215253] PM: Adding info for acpi:PNP0400:00
[    0.216776] device: 'PNP0501:00': device_add
[    0.217947] bus: 'acpi': add device PNP0501:00
[    0.220048] PM: Adding info for acpi:PNP0501:00
[    0.221511] device: 'device:03': device_add
[    0.222659] bus: 'acpi': add device device:03
[    0.223905] PM: Adding info for acpi:device:03
[    0.225346] device: 'device:04': device_add
[    0.226478] bus: 'acpi': add device device:04
[    0.227667] PM: Adding info for acpi:device:04
[    0.229009] device: 'device:05': device_add
[    0.230020] bus: 'acpi': add device device:05
[    0.231223] PM: Adding info for acpi:device:05
[    0.232541] device: 'device:06': device_add
[    0.233679] bus: 'acpi': add device device:06
[    0.234932] PM: Adding info for acpi:device:06
[    0.236307] device: 'device:07': device_add
[    0.237440] bus: 'acpi': add device device:07
[    0.238649] PM: Adding info for acpi:device:07
[    0.240161] device: 'device:08': device_add
[    0.241281] bus: 'acpi': add device device:08
[    0.242528] PM: Adding info for acpi:device:08
[    0.243866] device: 'device:09': device_add
[    0.244984] bus: 'acpi': add device device:09
[    0.246213] PM: Adding info for acpi:device:09
[    0.247550] device: 'device:0a': device_add
[    0.248669] bus: 'acpi': add device device:0a
[    0.250081] PM: Adding info for acpi:device:0a
[    0.251406] device: 'device:0b': device_add
[    0.252563] bus: 'acpi': add device device:0b
[    0.253812] PM: Adding info for acpi:device:0b
[    0.255214] device: 'device:0c': device_add
[    0.256369] bus: 'acpi': add device device:0c
[    0.257621] PM: Adding info for acpi:device:0c
[    0.258985] device: 'device:0d': device_add
[    0.260018] bus: 'acpi': add device device:0d
[    0.261207] PM: Adding info for acpi:device:0d
[    0.262543] device: 'device:0e': device_add
[    0.263659] bus: 'acpi': add device device:0e
[    0.264898] PM: Adding info for acpi:device:0e
[    0.266227] device: 'device:0f': device_add
[    0.267342] bus: 'acpi': add device device:0f
[    0.268549] PM: Adding info for acpi:device:0f
[    0.270210] device: 'device:10': device_add
[    0.271353] bus: 'acpi': add device device:10
[    0.272557] PM: Adding info for acpi:device:10
[    0.273918] device: 'device:11': device_add
[    0.275027] bus: 'acpi': add device device:11
[    0.276281] PM: Adding info for acpi:device:11
[    0.277637] device: 'device:12': device_add
[    0.278775] bus: 'acpi': add device device:12
[    0.280053] PM: Adding info for acpi:device:12
[    0.281380] device: 'device:13': device_add
[    0.282546] bus: 'acpi': add device device:13
[    0.283732] PM: Adding info for acpi:device:13
[    0.285169] device: 'device:14': device_add
[    0.286289] bus: 'acpi': add device device:14
[    0.287519] PM: Adding info for acpi:device:14
[    0.288852] device: 'device:15': device_add
[    0.290021] bus: 'acpi': add device device:15
[    0.291220] PM: Adding info for acpi:device:15
[    0.292550] device: 'device:16': device_add
[    0.293685] bus: 'acpi': add device device:16
[    0.294942] PM: Adding info for acpi:device:16
[    0.296291] device: 'device:17': device_add
[    0.297417] bus: 'acpi': add device device:17
[    0.298649] PM: Adding info for acpi:device:17
[    0.300042] device: 'device:18': device_add
[    0.301156] bus: 'acpi': add device device:18
[    0.302341] PM: Adding info for acpi:device:18
[    0.303661] device: 'device:19': device_add
[    0.304779] bus: 'acpi': add device device:19
[    0.306014] PM: Adding info for acpi:device:19
[    0.307340] device: 'device:1a': device_add
[    0.308460] bus: 'acpi': add device device:1a
[    0.309649] PM: Adding info for acpi:device:1a
[    0.310218] device: 'device:1b': device_add
[    0.311359] bus: 'acpi': add device device:1b
[    0.312595] PM: Adding info for acpi:device:1b
[    0.314031] device: 'device:1c': device_add
[    0.315175] bus: 'acpi': add device device:1c
[    0.316434] PM: Adding info for acpi:device:1c
[    0.317780] device: 'device:1d': device_add
[    0.318932] bus: 'acpi': add device device:1d
[    0.320046] PM: Adding info for acpi:device:1d
[    0.321357] device: 'device:1e': device_add
[    0.322513] bus: 'acpi': add device device:1e
[    0.323699] PM: Adding info for acpi:device:1e
[    0.325020] device: 'device:1f': device_add
[    0.326128] bus: 'acpi': add device device:1f
[    0.327354] PM: Adding info for acpi:device:1f
[    0.328666] device: 'device:20': device_add
[    0.330018] bus: 'acpi': add device device:20
[    0.331222] PM: Adding info for acpi:device:20
[    0.332570] device: 'device:21': device_add
[    0.333711] bus: 'acpi': add device device:21
[    0.334994] PM: Adding info for acpi:device:21
[    0.336405] device: 'device:22': device_add
[    0.337516] bus: 'acpi': add device device:22
[    0.338740] PM: Adding info for acpi:device:22
[    0.340533] device: 'PNP0103:00': device_add
[    0.341666] bus: 'acpi': add device PNP0103:00
[    0.342895] PM: Adding info for acpi:PNP0103:00
[    0.344604] device: 'PNP0C0F:00': device_add
[    0.345758] bus: 'acpi': add device PNP0C0F:00
[    0.347014] PM: Adding info for acpi:PNP0C0F:00
[    0.348529] device: 'PNP0C0F:01': device_add
[    0.350019] bus: 'acpi': add device PNP0C0F:01
[    0.351293] PM: Adding info for acpi:PNP0C0F:01
[    0.352808] device: 'PNP0C0F:02': device_add
[    0.353956] bus: 'acpi': add device PNP0C0F:02
[    0.355188] PM: Adding info for acpi:PNP0C0F:02
[    0.356713] device: 'PNP0C0F:03': device_add
[    0.357885] bus: 'acpi': add device PNP0C0F:03
[    0.359157] PM: Adding info for acpi:PNP0C0F:03
[    0.360314] device: 'PNP0C0F:04': device_add
[    0.361477] bus: 'acpi': add device PNP0C0F:04
[    0.362771] PM: Adding info for acpi:PNP0C0F:04
[    0.364217] device: 'LNXCPU:00': device_add
[    0.365356] bus: 'acpi': add device LNXCPU:00
[    0.366551] PM: Adding info for acpi:LNXCPU:00
[    0.367932] device: 'LNXCPU:01': device_add
[    0.369136] bus: 'acpi': add device LNXCPU:01
[    0.370047] PM: Adding info for acpi:LNXCPU:01
[    0.371411] device: 'device:23': device_add
[    0.372553] bus: 'acpi': add device device:23
[    0.373825] PM: Adding info for acpi:device:23
[    0.375171] device: 'LNXPWRBN:00': device_add
[    0.376364] bus: 'acpi': add device LNXPWRBN:00
[    0.377637] PM: Adding info for acpi:LNXPWRBN:00
[    0.380595] bus: 'acpi': add driver ec
[    0.381711] PCI: Using host bridge windows from ACPI; if necessary, use "pci=nocrs" and report a bug
[    0.384116] bus: 'acpi': add driver pci_root
[    0.385285] bus: 'acpi': driver_probe_device: matched device PNP0A03:00 with driver pci_root
[    0.387525] bus: 'acpi': really_probe: probing driver pci_root with device PNP0A03:00
[    0.389656] ACPI: PCI Root Bridge [PCI0] (domain 0000 [bus 00-ff])
[    0.390105] device: 'pci0000:00': device_add
[    0.391386] PM: Adding info for No Bus:pci0000:00
[    0.392687] device: '0000:00': device_add
[    0.393865] PM: Adding info for No Bus:0000:00
[    0.395131] PCI host bridge to bus 0000:00
[    0.396247] pci_bus 0000:00: busn_res: [bus 00-ff] is inserted under domain [bus 00-ff]
[    0.398370] pci_bus 0000:00: root bus resource [bus 00-ff]
[    0.400010] pci_bus 0000:00: root bus resource [io  0x0000-0x0cf7]
[    0.401652] pci_bus 0000:00: root bus resource [io  0x0d00-0xffff]
[    0.403291] pci_bus 0000:00: root bus resource [mem 0x000a0000-0x000bffff]
[    0.405125] pci_bus 0000:00: root bus resource [mem 0xe0000000-0xfebfffff]
[    0.407071] pci 0000:00:00.0: [8086:1237] type 00 class 0x060000
[    0.410499] pci 0000:00:01.0: [8086:7000] type 00 class 0x060100
[    0.412961] pci 0000:00:01.1: [8086:7010] type 00 class 0x010180
[    0.416604] pci 0000:00:01.1: reg 20: [io  0xc1c0-0xc1cf]
[    0.419273] pci 0000:00:01.3: [8086:7113] type 00 class 0x068000
[    0.420808] pci 0000:00:01.3: quirk: [io  0xb000-0xb03f] claimed by PIIX4 ACPI
[    0.422754] pci 0000:00:01.3: quirk: [io  0xb100-0xb10f] claimed by PIIX4 SMB
[    0.424900] pci 0000:00:02.0: [1013:00b8] type 00 class 0x030000
[    0.430273] pci 0000:00:02.0: reg 10: [mem 0xfc000000-0xfdffffff pref]
[    0.433783] pci 0000:00:02.0: reg 14: [mem 0xfebf0000-0xfebf0fff]
[    0.441362] pci 0000:00:02.0: reg 30: [mem 0xfebe0000-0xfebeffff pref]
[    0.443896] pci 0000:00:03.0: [8086:100e] type 00 class 0x020000
[    0.445951] pci 0000:00:03.0: reg 10: [mem 0xfeba0000-0xfebbffff]
[    0.448287] pci 0000:00:03.0: reg 14: [io  0xc000-0xc03f]
[    0.453582] pci 0000:00:03.0: reg 30: [mem 0xfebc0000-0xfebdffff pref]
[    0.456169] pci 0000:00:04.0: [1af4:1001] type 00 class 0x010000
[    0.458279] pci 0000:00:04.0: reg 10: [io  0xc040-0xc07f]
[    0.460745] pci 0000:00:04.0: reg 14: [mem 0xfebf1000-0xfebf1fff]
[    0.466732] pci 0000:00:05.0: [1af4:1001] type 00 class 0x010000
[    0.468925] pci 0000:00:05.0: reg 10: [io  0xc080-0xc0bf]
[    0.470761] pci 0000:00:05.0: reg 14: [mem 0xfebf2000-0xfebf2fff]
[    0.476967] pci 0000:00:06.0: [1af4:1001] type 00 class 0x010000
[    0.479184] pci 0000:00:06.0: reg 10: [io  0xc0c0-0xc0ff]
[    0.480767] pci 0000:00:06.0: reg 14: [mem 0xfebf3000-0xfebf3fff]
[    0.486861] pci 0000:00:07.0: [1af4:1001] type 00 class 0x010000
[    0.490072] pci 0000:00:07.0: reg 10: [io  0xc100-0xc13f]
[    0.492309] pci 0000:00:07.0: reg 14: [mem 0xfebf4000-0xfebf4fff]
[    0.498507] pci 0000:00:08.0: [1af4:1001] type 00 class 0x010000
[    0.500524] pci 0000:00:08.0: reg 10: [io  0xc140-0xc17f]
[    0.502717] pci 0000:00:08.0: reg 14: [mem 0xfebf5000-0xfebf5fff]
[    0.508849] pci 0000:00:09.0: [1af4:1001] type 00 class 0x010000
[    0.510499] pci 0000:00:09.0: reg 10: [io  0xc180-0xc1bf]
[    0.512685] pci 0000:00:09.0: reg 14: [mem 0xfebf6000-0xfebf6fff]
[    0.518767] pci 0000:00:0a.0: [8086:25ab] type 00 class 0x088000
[    0.520290] pci 0000:00:0a.0: reg 10: [mem 0xfebf7000-0xfebf700f]
[    0.525145] pci_bus 0000:00: on NUMA node 0
[    0.526393] ACPI: PCI Interrupt Routing Table [\_SB_.PCI0._PRT]
[    0.533300]  pci0000:00: Unable to request _OSC control (_OSC support mask: 0x08)
[    0.535358] device: '0000:00:00.0': device_add
[    0.543234] bus: 'pci': add device 0000:00:00.0
[    0.544721] PM: Adding info for pci:0000:00:00.0
[    0.547106] device: '0000:00:01.0': device_add
[    0.552713] bus: 'pci': add device 0000:00:01.0
[    0.554144] PM: Adding info for pci:0000:00:01.0
[    0.555492] device: '0000:00:01.1': device_add
[    0.560241] bus: 'pci': add device 0000:00:01.1
[    0.561658] PM: Adding info for pci:0000:00:01.1
[    0.563983] device: '0000:00:01.3': device_add
[    0.568104] bus: 'pci': add device 0000:00:01.3
[    0.570107] PM: Adding info for pci:0000:00:01.3
[    0.571369] device: '0000:00:02.0': device_add
[    0.574560] bus: 'pci': add device 0000:00:02.0
[    0.575974] PM: Adding info for pci:0000:00:02.0
[    0.577277] device: '0000:00:03.0': device_add
[    0.580554] bus: 'pci': add device 0000:00:03.0
[    0.581960] PM: Adding info for pci:0000:00:03.0
[    0.583236] device: '0000:00:04.0': device_add
[    0.586463] bus: 'pci': add device 0000:00:04.0
[    0.587887] PM: Adding info for pci:0000:00:04.0
[    0.589184] device: '0000:00:05.0': device_add
[    0.591991] bus: 'pci': add device 0000:00:05.0
[    0.593429] PM: Adding info for pci:0000:00:05.0
[    0.594748] device: '0000:00:06.0': device_add
[    0.597983] bus: 'pci': add device 0000:00:06.0
[    0.599444] PM: Adding info for pci:0000:00:06.0
[    0.600036] device: '0000:00:07.0': device_add
[    0.603261] bus: 'pci': add device 0000:00:07.0
[    0.604685] PM: Adding info for pci:0000:00:07.0
[    0.605957] device: '0000:00:08.0': device_add
[    0.610321] bus: 'pci': add device 0000:00:08.0
[    0.611806] PM: Adding info for pci:0000:00:08.0
[    0.613102] device: '0000:00:09.0': device_add
[    0.616330] bus: 'pci': add device 0000:00:09.0
[    0.617825] PM: Adding info for pci:0000:00:09.0
[    0.619127] device: '0000:00:0a.0': device_add
[    0.621967] bus: 'pci': add device 0000:00:0a.0
[    0.623366] PM: Adding info for pci:0000:00:0a.0
[    0.624645] driver: 'PNP0A03:00': driver_bound: bound to device 'pci_root'
[    0.626512] bus: 'acpi': really_probe: bound device PNP0A03:00 to driver pci_root
[    0.628627] bus: 'acpi': add driver pci_link
[    0.630054] bus: 'acpi': driver_probe_device: matched device PNP0C0F:00 with driver pci_link
[    0.632333] bus: 'acpi': really_probe: probing driver pci_link with device PNP0C0F:00
[    0.634743] ACPI: PCI Interrupt Link [LNKA] (IRQs 5 *10 11)
[    0.636595] driver: 'PNP0C0F:00': driver_bound: bound to device 'pci_link'
[    0.638443] bus: 'acpi': really_probe: bound device PNP0C0F:00 to driver pci_link
[    0.640018] bus: 'acpi': driver_probe_device: matched device PNP0C0F:01 with driver pci_link
[    0.642283] bus: 'acpi': really_probe: probing driver pci_link with device PNP0C0F:01
[    0.644569] ACPI: PCI Interrupt Link [LNKB] (IRQs 5 *10 11)
[    0.646403] driver: 'PNP0C0F:01': driver_bound: bound to device 'pci_link'
[    0.648263] bus: 'acpi': really_probe: bound device PNP0C0F:01 to driver pci_link
[    0.650019] bus: 'acpi': driver_probe_device: matched device PNP0C0F:02 with driver pci_link
[    0.652344] bus: 'acpi': really_probe: probing driver pci_link with device PNP0C0F:02
[    0.654652] ACPI: PCI Interrupt Link [LNKC] (IRQs 5 10 *11)
[    0.656451] driver: 'PNP0C0F:02': driver_bound: bound to device 'pci_link'
[    0.658298] bus: 'acpi': really_probe: bound device PNP0C0F:02 to driver pci_link
[    0.660019] bus: 'acpi': driver_probe_device: matched device PNP0C0F:03 with driver pci_link
[    0.662303] bus: 'acpi': really_probe: probing driver pci_link with device PNP0C0F:03
[    0.664613] ACPI: PCI Interrupt Link [LNKD] (IRQs 5 10 *11)
[    0.666427] driver: 'PNP0C0F:03': driver_bound: bound to device 'pci_link'
[    0.668247] bus: 'acpi': really_probe: bound device PNP0C0F:03 to driver pci_link
[    0.670018] bus: 'acpi': driver_probe_device: matched device PNP0C0F:04 with driver pci_link
[    0.672357] bus: 'acpi': really_probe: probing driver pci_link with device PNP0C0F:04
[    0.674642] ACPI: PCI Interrupt Link [LNKS] (IRQs 9) *0
[    0.676406] driver: 'PNP0C0F:04': driver_bound: bound to device 'pci_link'
[    0.678242] bus: 'acpi': really_probe: bound device PNP0C0F:04 to driver pci_link
[    0.680161] bus: 'pnp': registered
[    0.681108] bus: 'platform': add driver reg-fixed-voltage
[    0.682575] bus: 'platform': add driver 88pm860x-regulator
[    0.684115] bus: 'platform': add driver da903x-regulator
[    0.685587] bus: 'i2c': add driver max1586
[    0.686774] bus: 'i2c': add driver max8660
[    0.688013] bus: 'i2c': add driver max8952
[    0.690035] bus: 'platform': add driver palmas-pmic
[    0.691409] bus: 'platform': add driver tps6507x-pmic
[    0.692885] bus: 'platform': add driver wm8350-regulator
[    0.694368] device class 'misc': registering
[    0.695666] device: 'vga_arbiter': device_add
[    0.697015] PM: Adding info for No Bus:vga_arbiter
[    0.698435] vgaarb: device added: PCI:0000:00:02.0,decodes=io+mem,owns=io+mem,locks=none
[    0.700039] vgaarb: loaded
[    0.700763] vgaarb: bridge control possible 0000:00:02.0
[    0.702325] bus: 'i2c': add driver 88PM860x
[    0.703498] bus: 'i2c': add driver wm831x
[    0.704649] bus: 'i2c': add driver wm8350
[    0.705812] bus: 'i2c': add driver tps65217
[    0.707113] bus: 'i2c': add driver mc13xxx
[    0.708312] bus: 'i2c': add driver da903x
[    0.710033] bus: 'i2c': add driver max77693
[    0.711226] bus: 'i2c': add driver max8925
[    0.712395] bus: 'i2c': add driver ab3100
[    0.713603] bus: 'i2c': add driver palmas
[    0.714782] bus: 'i2c': add driver lm3533
[    0.715983] bus: 'serio': registered
[    0.716998] bus: 'gameport': registered
[    0.718046] device class 'input': registering
[    0.720045] bus: 'i2c': add driver tca6416-keypad
[    0.721378] bus: 'i2c': add driver tca8418_keypad
[    0.722747] device class 'rtc': registering
[    0.723961] device class 'power_supply': registering
[    0.725395] device class 'hwmon': registering
[    0.726720] bus: 'mmc': registered
[    0.727687] device class 'mmc_host': registering
[    0.729025] bus: 'sdio': registered
[    0.730016] device class 'leds': registering
[    0.731268] device class 'devfreq': registering
[    0.732697] bus: 'iio': registered
[    0.733898] device class 'sound': registering
[    0.735109] Advanced Linux Sound Architecture Driver Version 1.0.25.
[    0.736831] PCI: Using ACPI for IRQ routing
[    0.737978] PCI: pci_cache_line_size set to 64 bytes
[    0.740346] e820: reserve RAM buffer [mem 0x00093c00-0x0009ffff]
[    0.741993] e820: reserve RAM buffer [mem 0x0fffe000-0x0fffffff]
[    0.743648] device class 'net': registering
[    0.744965] device: 'lo': device_add
[    0.746368] PM: Adding info for No Bus:lo
[    0.748096] Sangoma WANPIPE Router v1.1 (c) 1995-2000 Sangoma Technologies Inc.
[    0.750017] irda_init()
[    0.750913] NET: Registered protocol family 23
[    0.752217] Bluetooth: Core ver 2.16
[    0.753266] device class 'bluetooth': registering
[    0.754603] NET: Registered protocol family 31
[    0.755816] Bluetooth: HCI device and connection manager initialized
[    0.757556] Bluetooth: HCI socket layer initialized
[    0.758883] Bluetooth: L2CAP socket layer initialized
[    0.760057] Bluetooth: SCO socket layer initialized
[    0.761415] device class 'rfkill': registering
[    0.762712] device: 'rfkill': device_add
[    0.763888] PM: Adding info for No Bus:rfkill
[    0.765162] device class 'ieee802154': registering
[    0.767113] Switching to clocksource kvm-clock
[    0.768743] FS-Cache: Loaded
[    0.769568] bus: 'pnp': add driver system
[    0.769568] pnp: PnP ACPI init
[    0.769568] device: 'pnp0': device_add
[    0.769568] PM: Adding info for No Bus:pnp0
[    0.769568] ACPI: bus type pnp registered
[    0.769568] pnp 00:00: [bus 00-ff]
[    0.769568] pnp 00:00: [io  0x0cf8-0x0cff]
[    0.769568] pnp 00:00: [io  0x0000-0x0cf7 window]
[    0.769947] pnp 00:00: [io  0x0d00-0xffff window]
[    0.771236] pnp 00:00: [mem 0x000a0000-0x000bffff window]
[    0.772669] pnp 00:00: [mem 0xe0000000-0xfebfffff window]
[    0.774144] device: '00:00': device_add
[    0.775349] bus: 'pnp': add device 00:00
[    0.776466] PM: Adding info for pnp:00:00
[    0.777623] pnp 00:00: Plug and Play ACPI device, IDs PNP0a03 (active)
[    0.779505] pnp 00:01: [io  0x0070-0x0071]
[    0.780758] IOAPIC[0]: Set routing entry (2-8 -> 0x38 -> IRQ 8 Mode:0 Active:0 Dest:1)
[    0.783052] pnp 00:01: [irq 8]
[    0.783928] pnp 00:01: [io  0x0072-0x0077]
[    0.785105] device: '00:01': device_add
[    0.786292] bus: 'pnp': add device 00:01
[    0.787411] PM: Adding info for pnp:00:01
[    0.788518] pnp 00:01: Plug and Play ACPI device, IDs PNP0b00 (active)
[    0.790446] pnp 00:02: [io  0x0060]
[    0.791437] pnp 00:02: [io  0x0064]
[    0.792392] IOAPIC[0]: Set routing entry (2-1 -> 0x31 -> IRQ 1 Mode:0 Active:0 Dest:1)
[    0.794517] pnp 00:02: [irq 1]
[    0.795366] device: '00:02': device_add
[    0.796462] bus: 'pnp': add device 00:02
[    0.797645] PM: Adding info for pnp:00:02
[    0.798834] pnp 00:02: Plug and Play ACPI device, IDs PNP0303 (active)
[    0.800769] IOAPIC[0]: Set routing entry (2-12 -> 0x3c -> IRQ 12 Mode:0 Active:0 Dest:1)
[    0.803065] pnp 00:03: [irq 12]
[    0.803947] device: '00:03': device_add
[    0.805052] bus: 'pnp': add device 00:03
[    0.806230] PM: Adding info for pnp:00:03
[    0.807350] pnp 00:03: Plug and Play ACPI device, IDs PNP0f13 (active)
[    0.809205] pnp 00:04: [io  0x03f2-0x03f5]
[    0.810320] pnp 00:04: [io  0x03f7]
[    0.811311] IOAPIC[0]: Set routing entry (2-6 -> 0x36 -> IRQ 6 Mode:0 Active:0 Dest:1)
[    0.813446] pnp 00:04: [irq 6]
[    0.814290] pnp 00:04: [dma 2]
[    0.815139] device: '00:04': device_add
[    0.816238] bus: 'pnp': add device 00:04
[    0.817366] PM: Adding info for pnp:00:04
[    0.818517] pnp 00:04: Plug and Play ACPI device, IDs PNP0700 (active)
[    0.820572] pnp 00:05: [io  0x0378-0x037f]
[    0.821800] IOAPIC[0]: Set routing entry (2-7 -> 0x37 -> IRQ 7 Mode:0 Active:0 Dest:1)
[    0.823983] pnp 00:05: [irq 7]
[    0.824919] device: '00:05': device_add
[    0.826114] bus: 'pnp': add device 00:05
[    0.827230] PM: Adding info for pnp:00:05
[    0.828332] pnp 00:05: Plug and Play ACPI device, IDs PNP0400 (active)
[    0.830219] pnp 00:06: [io  0x03f8-0x03ff]
[    0.831351] IOAPIC[0]: Set routing entry (2-4 -> 0x34 -> IRQ 4 Mode:0 Active:0 Dest:1)
[    0.833476] pnp 00:06: [irq 4]
[    0.839479] device: '00:06': device_add
[    0.840557] bus: 'pnp': add device 00:06
[    0.841747] PM: Adding info for pnp:00:06
[    0.842852] pnp 00:06: Plug and Play ACPI device, IDs PNP0501 (active)
[    0.848394] pnp 00:07: [mem 0xfed00000-0xfed003ff]
[    0.849673] device: '00:07': device_add
[    0.850831] bus: 'pnp': add device 00:07
[    0.852026] PM: Adding info for pnp:00:07
[    0.853135] pnp 00:07: Plug and Play ACPI device, IDs PNP0103 (active)
[    0.855353] pnp: PnP ACPI: found 8 devices
[    0.856444] ACPI: ACPI bus type pnp unregistered
[    0.857677] device class 'mem': registering
[    0.858820] device: 'mem': device_add
[    0.866182] PM: Adding info for No Bus:mem
[    0.867359] device: 'null': device_add
[    0.868486] PM: Adding info for No Bus:null
[    0.869618] device: 'port': device_add
[    0.870773] PM: Adding info for No Bus:port
[    0.871925] device: 'zero': device_add
[    0.872978] PM: Adding info for No Bus:zero
[    0.874111] device: 'full': device_add
[    0.875215] PM: Adding info for No Bus:full
[    0.876397] device: 'random': device_add
[    0.883639] PM: Adding info for No Bus:random
[    0.884827] device: 'urandom': device_add
[    0.885943] PM: Adding info for No Bus:urandom
[    0.887137] device: 'kmsg': device_add
[    0.888238] PM: Adding info for No Bus:kmsg
[    0.889371] device: 'tty': device_add
[    0.890469] PM: Adding info for No Bus:tty
[    0.891641] device: 'console': device_add
[    0.892760] PM: Adding info for No Bus:console
[    0.900179] device class 'firmware': registering
[    0.901472] device class 'thermal': registering
[    0.912201] bus: 'bcma': registered
[    0.913263] pci_bus 0000:00: resource 4 [io  0x0000-0x0cf7]
[    0.914735] pci_bus 0000:00: resource 5 [io  0x0d00-0xffff]
[    0.916198] pci_bus 0000:00: resource 6 [mem 0x000a0000-0x000bffff]
[    0.917835] pci_bus 0000:00: resource 7 [mem 0xe0000000-0xfebfffff]
[    0.919664] NET: Registered protocol family 2
[    0.921216] 
[    0.921645] ===============================
[    0.922766] [ INFO: suspicious RCU usage. ]
[    0.923887] 3.5.0-01540-g1669891 #64 Not tainted
[    0.925123] -------------------------------
[    0.932860] /c/kernel-tests/src/tip/net/xfrm/xfrm_policy.c:2504 suspicious rcu_dereference_check() usage!
[    0.935361] 
[    0.935361] other info that might help us debug this:
[    0.935361] 
[    0.937472] 
[    0.937472] rcu_scheduler_active = 1, debug_locks = 0
[    0.939182] 2 locks held by swapper/1:
[    0.940171]  #0:  (net_mutex){+.+.+.}, at: [<ffffffff814e1ad0>] register_pernet_subsys+0x21/0x57
[    0.942705]  #1:  (rcu_read_lock_bh){......}, at: [<ffffffff822c7329>] xfrm_net_init+0x1e4/0x437
[    0.951507] 
[    0.951507] stack backtrace:
[    0.952660] Pid: 1, comm: swapper Not tainted 3.5.0-01540-g1669891 #64
[    0.954364] Call Trace:
[    0.955074]  [<ffffffff8108b375>] lockdep_rcu_suspicious+0x174/0x187
[    0.956736]  [<ffffffff822c7453>] xfrm_net_init+0x30e/0x437
[    0.958205]  [<ffffffff822c7329>] ? xfrm_net_init+0x1e4/0x437
[    0.959712]  [<ffffffff814e134a>] ops_init+0x1bb/0x1ff
[    0.961067]  [<ffffffff810861f9>] ? trace_hardirqs_on+0x1b/0x24
[    0.962644]  [<ffffffff814e17cd>] register_pernet_operations.isra.5+0x9d/0xfe
[    0.971376]  [<ffffffff814e1adf>] register_pernet_subsys+0x30/0x57
[    0.972992]  [<ffffffff822c7130>] xfrm_init+0x17/0x2c
[    0.974316]  [<ffffffff822c2f8c>] ip_rt_init+0x82/0xe7
[    0.975668]  [<ffffffff822c31dc>] ip_init+0x10/0x25
[    0.976952]  [<ffffffff822c3f77>] inet_init+0x235/0x360
[    0.978352]  [<ffffffff822c3d42>] ? devinet_init+0xf2/0xf2
[    0.979808]  [<ffffffff82283252>] do_one_initcall+0xb4/0x203
[    0.981313]  [<ffffffff8228354a>] kernel_init+0x1a9/0x29a
[    0.982732]  [<ffffffff822826d9>] ? loglevel+0x46/0x46
[    0.990889]  [<ffffffff816d3d84>] kernel_thread_helper+0x4/0x10
[    0.992472]  [<ffffffff816d262c>] ? retint_restore_args+0x13/0x13
[    0.994076]  [<ffffffff822833a1>] ? do_one_initcall+0x203/0x203
[    0.995636]  [<ffffffff816d3d80>] ? gs_change+0x13/0x13
[    0.997197] TCP established hash table entries: 8192 (order: 5, 131072 bytes)
[    1.000074] TCP bind hash table entries: 8192 (order: 7, 655360 bytes)
[    1.002942] TCP: Hash tables configured (established 8192 bind 8192)
[    1.011932] TCP: reno registered
[    1.012914] UDP hash table entries: 128 (order: 2, 24576 bytes)
[    1.014605] UDP-Lite hash table entries: 128 (order: 2, 24576 bytes)
[    1.019694] NET: Registered protocol family 1
[    1.021541] RPC: Registered named UNIX socket transport module.
[    1.030552] RPC: Registered udp transport module.
[    1.031816] RPC: Registered tcp transport module.
[    1.033076] RPC: Registered tcp NFSv4.1 backchannel transport module.
[    1.034779] pci 0000:00:00.0: Limiting direct PCI/PCI transfers
[    1.041653] pci 0000:00:01.0: PIIX3: Enabling Passive Release
[    1.042783] pci 0000:00:01.0: Activating ISA DMA hang workarounds
[    1.045029] pci 0000:00:02.0: Boot video device
[    1.049266] PCI: CLS 0 bytes, default 64
[    1.052495] Unpacking initramfs...
[    2.798435] debug: unmapping init [mem 0xffff88000e8d6000-0xffff88000ffeffff]
[    2.802021] device class 'msr': registering
[    2.803218] device: 'msr0': device_add
[    2.804270] PM: Adding info for No Bus:msr0
[    2.805430] device class 'cpuid': registering
[    2.806592] device: 'cpu0': device_add
[    2.807674] PM: Adding info for No Bus:cpu0
[    2.808800] Registering platform device 'pcspkr'. Parent at platform
[    2.810467] device: 'pcspkr': device_add
[    2.811549] bus: 'platform': add device pcspkr
[    2.812809] PM: Adding info for platform:pcspkr
[    2.814454] cryptomgr_test (15) used greatest stack depth: 7080 bytes left
[    2.817255] sha1_ssse3: Neither AVX nor SSSE3 is available/usable.
[    2.818946] bus: 'clocksource': registered
[    2.820038] device: 'clocksource': device_add
[    2.821343] PM: Adding info for No Bus:clocksource
[    2.822670] device: 'clocksource0': device_add
[    2.823904] bus: 'clocksource': add device clocksource0
[    2.825306] PM: Adding info for clocksource:clocksource0
[    2.826784] bus: 'platform': add driver alarmtimer
[    2.828091] Registering platform device 'alarmtimer'. Parent at platform
[    2.829847] device: 'alarmtimer': device_add
[    2.831008] bus: 'platform': add device alarmtimer
[    2.832355] PM: Adding info for platform:alarmtimer
[    2.833657] bus: 'platform': driver_probe_device: matched device alarmtimer with driver alarmtimer
[    2.836035] bus: 'platform': really_probe: probing driver alarmtimer with device alarmtimer
[    2.838218] driver: 'alarmtimer': driver_bound: bound to device 'alarmtimer'
[    2.840064] bus: 'platform': really_probe: bound device alarmtimer to driver alarmtimer
[    2.842233] bus: 'rttest': registered
[    2.843214] device: 'rttest': device_add
[    2.844361] PM: Adding info for No Bus:rttest
[    2.845614] device: 'rttest0': device_add
[    2.846695] bus: 'rttest': add device rttest0
[    2.847904] PM: Adding info for rttest:rttest0
[    2.849213] device: 'rttest1': device_add
[    2.850283] bus: 'rttest': add device rttest1
[    2.851531] PM: Adding info for rttest:rttest1
[    2.852817] device: 'rttest2': device_add
[    2.853918] bus: 'rttest': add device rttest2
[    2.855091] PM: Adding info for rttest:rttest2
[    2.856407] device: 'rttest3': device_add
[    2.857493] bus: 'rttest': add device rttest3
[    2.858666] PM: Adding info for rttest:rttest3
[    2.860000] device: 'rttest4': device_add
[    2.861091] bus: 'rttest': add device rttest4
[    2.862323] PM: Adding info for rttest:rttest4
[    2.863608] device: 'rttest5': device_add
[    2.864672] bus: 'rttest': add device rttest5
[    2.865839] PM: Adding info for rttest:rttest5
[    2.867093] device: 'rttest6': device_add
[    2.868215] bus: 'rttest': add device rttest6
[    2.869381] PM: Adding info for rttest:rttest6
[    2.870734] device: 'rttest7': device_add
[    2.871827] bus: 'rttest': add device rttest7
[    2.873062] PM: Adding info for rttest:rttest7
[    2.874236] Initializing RT-Tester: OK
[    2.875230] audit: initializing netlink socket (disabled)
[    2.876760] type=2000 audit(1345057735.870:1): initialized
[    2.878385] rcu-torture:--- Start of test: nreaders=2 nfakewriters=4 stat_interval=0 verbose=0 test_no_idle_hz=0 shuffle_interval=3 stutter=5 irqreader=1 fqs_duration=0 fqs_holdoff=0 fqs_stutter=3 test_boost=1/0 test_boost_interval=7 test_boost_duration=4 shutdown_secs=0 onoff_interval=0 onoff_holdoff=0
[    2.886217] bus: 'event_source': registered
[    2.887337] device: 'breakpoint': device_add
[    2.888466] bus: 'event_source': add device breakpoint
[    2.889912] PM: Adding info for event_source:breakpoint
[    2.891704] device: 'software': device_add
[    2.892867] bus: 'event_source': add device software
[    2.894197] PM: Adding info for event_source:software
[    2.895789] HugeTLB registered 2 MB page size, pre-allocated 0 pages
[    2.908583] device class 'coda': registering
[    2.909888] device: 'cfs0': device_add
[    2.910942] PM: Adding info for No Bus:cfs0
[    2.912055] device: 'cfs1': device_add
[    2.913156] PM: Adding info for No Bus:cfs1
[    2.914274] device: 'cfs2': device_add
[    2.915354] PM: Adding info for No Bus:cfs2
[    2.916463] device: 'cfs3': device_add
[    2.917478] PM: Adding info for No Bus:cfs3
[    2.918668] device: 'cfs4': device_add
[    2.919745] PM: Adding info for No Bus:cfs4
[    2.923001] NFS: Registering the id_resolver key type
[    2.924430] Key type id_resolver registered
[    2.925537] Key type id_legacy registered
[    2.926606] nfs4filelayout_init: NFSv4 File Layout Driver Registering...
[    2.928629] fuse init (API version 7.19)
[    2.930197] device: 'fuse': device_add
[    2.932192] PM: Adding info for No Bus:fuse
[    2.934090] ceph: loaded (mds proto 32)
[    2.937389] NET: Registered protocol family 38
[    2.938610] list_sort_test: start testing list_sort()
[    2.940415] bus: 'platform': add driver hecubafb
[    2.941755] no IO addresses supplied
[    2.942723] bus: 'platform': add driver tmio-fb
[    2.943967] bus: 'platform': add driver metronomefb
[    2.945287] bus: 'platform': add driver broadsheetfb
[    2.946620] Registering platform device 'vesafb.0'. Parent at platform
[    2.948333] device: 'vesafb.0': device_add
[    2.949427] bus: 'platform': add device vesafb.0
[    2.950744] PM: Adding info for platform:vesafb.0
[    2.952001] bus: 'platform': add driver vesafb
[    2.953200] bus: 'platform': driver_probe_device: matched device vesafb.0 with driver vesafb
[    2.955401] bus: 'platform': really_probe: probing driver vesafb with device vesafb.0
[    2.957459] vesafb: probe of vesafb.0 rejects match -19
[    2.958847] bus: 'platform': remove driver vesafb
[    2.960095] driver: 'vesafb': driver_release
[    2.961337] PM: Removing info for platform:vesafb.0
[    2.963388] bus: 'platform': remove device vesafb.0
[    2.964747] bus: 'acpi': add driver ac
[    2.965796] bus: 'acpi': add driver button
[    2.966915] bus: 'acpi': driver_probe_device: matched device LNXPWRBN:00 with driver button
[    2.969119] bus: 'acpi': really_probe: probing driver button with device LNXPWRBN:00
[    2.971242] device: 'input0': device_add
[    2.972368] PM: Adding info for No Bus:input0
[    2.973563] input: Power Button as /devices/LNXSYSTM:00/LNXPWRBN:00/input/input0
[    2.975502] ACPI: Power Button [PWRF]
[    2.976534] driver: 'LNXPWRBN:00': driver_bound: bound to device 'button'
[    2.978311] bus: 'acpi': really_probe: bound device LNXPWRBN:00 to driver button
[    2.980280] bus: 'acpi': add driver fan
[    2.981355] bus: 'acpi': add driver processor
[    2.982522] bus: 'acpi': driver_probe_device: matched device LNXCPU:00 with driver processor
[    2.984718] bus: 'acpi': really_probe: probing driver processor with device LNXCPU:00
[    2.987000] device: 'cooling_device0': device_add
[    2.988437] PM: Adding info for No Bus:cooling_device0
[    2.989815] driver: 'LNXCPU:00': driver_bound: bound to device 'processor'
[    2.991653] bus: 'acpi': really_probe: bound device LNXCPU:00 to driver processor
[    2.993616] bus: 'acpi': driver_probe_device: matched device LNXCPU:01 with driver processor
[    2.995816] bus: 'acpi': really_probe: probing driver processor with device LNXCPU:01
[    2.997969] driver: 'LNXCPU:01': driver_bound: bound to device 'processor'
[    2.999612] bus: 'acpi': really_probe: bound device LNXCPU:01 to driver processor
[    3.001500] bus: 'acpi': add driver thermal
[    3.002446] bus: 'virtio': add driver virtio_balloon
[    3.003544] bus: 'platform': add driver reg-virt-consumer
[    3.004704] bus: 'i2c': add driver LP3971
[    3.005626] device: 'ptmx': device_add
[    3.006422] PM: Adding info for No Bus:ptmx
[    3.007335] Serial: 8250/16550 driver, 4 ports, IRQ sharing disabled
[    3.008862] Registering platform device 'serial8250'. Parent at platform
[    3.010399] device: 'serial8250': device_add
[    3.011426] bus: 'acpi': add driver battery
[    3.012462] bus: 'platform': add device serial8250
[    3.013600] PM: Adding info for platform:serial8250
[    3.038649] serial8250: ttyS0 at I/O 0x3f8 (irq = 4) is a 16550A
[    3.040049] device: 'ttyS0': device_add
[    3.041009] PM: Adding info for No Bus:ttyS0
[    3.042075] device: 'ttyS1': device_add
[    3.043059] PM: Adding info for No Bus:ttyS1
[    3.044137] device: 'ttyS2': device_add
[    3.045102] PM: Adding info for No Bus:ttyS2
[    3.046157] device: 'ttyS3': device_add
[    3.047110] PM: Adding info for No Bus:ttyS3
[    3.048124] bus: 'platform': add driver serial8250
[    3.049240] bus: 'platform': driver_probe_device: matched device serial8250 with driver serial8250
[    3.051309] bus: 'platform': really_probe: probing driver serial8250 with device serial8250
[    3.053215] driver: 'serial8250': driver_bound: bound to device 'serial8250'
[    3.054821] bus: 'platform': really_probe: bound device serial8250 to driver serial8250
[    3.056695] bus: 'pnp': add driver serial
[    3.057711] bus: 'pnp': driver_probe_device: matched device 00:06 with driver serial
[    3.059479] bus: 'pnp': really_probe: probing driver serial with device 00:06
[    3.061147] device: 'ttyS0': device_unregister
[    3.062169] PM: Removing info for No Bus:ttyS0
[    3.063246] device: 'ttyS0': device_create_release
[    3.088335] 00:06: ttyS0 at I/O 0x3f8 (irq = 4) is a 16550A
[    3.089625] device: 'ttyS0': device_add
[    3.090558] PM: Adding info for No Bus:ttyS0
[    3.091570] driver: '00:06': driver_bound: bound to device 'serial'
[    3.093002] bus: 'pnp': really_probe: bound device 00:06 to driver serial
[    3.094568] bus: 'pci': add driver serial
[    3.095548] bus: 'platform': add driver altera_uart
[    3.096701] device: 'ttyprintk': device_add
[    3.097727] PM: Adding info for No Bus:ttyprintk
[    3.098824] telclk_interrupt = 0xf non-mcpbl0010 hw.
[    3.099977] bus: 'platform': add driver ipmi
[    3.100994] ipmi message handler version 39.2
[    3.102005] ipmi device interface
[    3.102771] device class 'ipmi': registering
[    3.103790] bus: 'platform': add driver ipmi_si
[    3.104864] IPMI System Interface driver.
[    3.105793] bus: 'pci': add driver ipmi_si
[    3.106782] bus: 'pnp': add driver ipmi_si
[    3.107757] ipmi_si: Adding default-specified kcs state machine
[    3.109160] ipmi_si: Trying default-specified kcs state machine at i/o address 0xca2, slave address 0x0, irq 0
[    3.111456] ipmi_si: Interface detection failed
[    3.112508] ipmi_si: Adding default-specified smic state machine
[    3.113908] ipmi_si: Trying default-specified smic state machine at i/o address 0xca9, slave address 0x0, irq 0
[    3.116210] ipmi_si: Interface detection failed
[    3.117256] ipmi_si: Adding default-specified bt state machine
[    3.118623] ipmi_si: Trying default-specified bt state machine at i/o address 0xe4, slave address 0x0, irq 0
[    3.120884] ipmi_si: Interface detection failed
[    3.121937] bus: 'pci': remove driver ipmi_si
[    3.122936] driver: 'ipmi_si': driver_release
[    3.123941] bus: 'pnp': remove driver ipmi_si
[    3.124952] driver: 'ipmi_si': driver_release
[    3.125963] bus: 'platform': remove driver ipmi_si
[    3.127075] driver: 'ipmi_si': driver_release
[    3.128084] ipmi_si: Unable to find any System Interface(s)
[    3.129381] IPMI Watchdog: driver initialized
[    3.130388] Copyright (C) 2004 MontaVista Software - IPMI Powerdown via sys_reboot.
[    3.132183] device class 'drm': registering
[    3.133170] [drm:drm_core_init] *ERROR* Cannot create /proc/dri
[    3.134508] device class 'drm': unregistering
[    3.135515] class 'drm': release.
[    3.136289] class_create_release called for drm
[    3.137372] bus: 'i2c': add driver bmp085
[    3.138316] device class 'enclosure': registering
[    3.139409] bus: 'i2c': add driver apds9802als
[    3.140457] i2c-core: driver [apds9802als] using legacy suspend method
[    3.141961] i2c-core: driver [apds9802als] using legacy resume method
[    3.143437] bus: 'i2c': add driver isl29003
[    3.144413] i2c-core: driver [isl29003] using legacy suspend method
[    3.145840] i2c-core: driver [isl29003] using legacy resume method
[    3.147251] bus: 'i2c': add driver hmc6352
[    3.148216] bus: 'i2c': add driver eeprom
[    3.149162] bus: 'i2c': add driver fsa9480
[    3.150145] i2c-core: driver [fsa9480] using legacy suspend method
[    3.151569] i2c-core: driver [fsa9480] using legacy resume method
[    3.152957] bus: 'i2c': add driver twl6040
[    3.153938] bus: 'platform': add driver ab3100-otp
[    3.155049] bus: 'platform': remove driver ab3100-otp
[    3.156220] driver: 'ab3100-otp': driver_release
[    3.157295] bus: 'platform': add driver nsc-ircc
[    3.158368] bus: 'pnp': add driver nsc-ircc
[    3.159464] bus: 'platform': remove driver nsc-ircc
[    3.160608] driver: 'nsc-ircc': driver_release
[    3.161638] bus: 'pnp': remove driver nsc-ircc
[    3.162672] driver: 'nsc-ircc': driver_release
[    3.163705] device class 'uio': registering
[    3.164684] bus: 'platform': add driver uio_pdrv
[    3.165772] bus: 'pnp': add driver i8042 kbd
[    3.166771] bus: 'pnp': driver_probe_device: matched device 00:02 with driver i8042 kbd
[    3.168586] bus: 'pnp': really_probe: probing driver i8042 kbd with device 00:02
[    3.170291] driver: '00:02': driver_bound: bound to device 'i8042 kbd'
[    3.171801] bus: 'pnp': really_probe: bound device 00:02 to driver i8042 kbd
[    3.173453] bus: 'pnp': add driver i8042 aux
[    3.174460] bus: 'pnp': driver_probe_device: matched device 00:03 with driver i8042 aux
[    3.176290] bus: 'pnp': really_probe: probing driver i8042 aux with device 00:03
[    3.178016] driver: '00:03': driver_bound: bound to device 'i8042 aux'
[    3.179511] bus: 'pnp': really_probe: bound device 00:03 to driver i8042 aux
[    3.181156] i8042: PNP: PS/2 Controller [PNP0303:KBD,PNP0f13:MOU] at 0x60,0x64 irq 1,12
[    3.182995] Registering platform device 'i8042'. Parent at platform
[    3.184430] device: 'i8042': device_add
[    3.185328] bus: 'platform': add device i8042
[    3.186386] PM: Adding info for platform:i8042
[    3.187432] bus: 'platform': add driver i8042
[    3.188473] bus: 'platform': driver_probe_device: matched device i8042 with driver i8042
[    3.190317] bus: 'platform': really_probe: probing driver i8042 with device i8042
[    3.193041] serio: i8042 KBD port at 0x60,0x64 irq 1
[    3.194189] serio: i8042 AUX port at 0x60,0x64 irq 12
[    3.195358] device: 'serio0': device_add
[    3.196280] bus: 'serio': add device serio0
[    3.197296] PM: Adding info for serio:serio0
[    3.198317] driver: 'i8042': driver_bound: bound to device 'i8042'
[    3.199546] bus: 'platform': really_probe: bound device i8042 to driver i8042
[    3.201278] bus: 'serio': add driver serio_raw
[    3.202330] bus: 'platform': add driver altera_ps2
[    3.203500] device: 'mice': device_add
[    3.204428] PM: Adding info for No Bus:mice
[    3.205415] device: 'psaux': device_add
[    3.206356] PM: Adding info for No Bus:psaux
[    3.207350] mousedev: PS/2 mouse device common for all mice
[    3.208522] device: 'event0': device_add
[    3.209345] PM: Adding info for No Bus:event0
[    3.210374] bus: 'serio': add driver atkbd
[    3.211354] device: 'serio1': device_add
[    3.212247] bus: 'serio': add device serio1
[    3.213031] PM: Adding info for serio:serio1
[    3.213828] bus: 'i2c': add driver lm8323
[    3.214563] bus: 'serio': driver_probe_device: matched device serio0 with driver atkbd
[    3.215967] bus: 'serio': really_probe: probing driver atkbd with device serio0
[    3.218074] device: 'input1': device_add
[    3.219059] PM: Adding info for No Bus:input1
[    3.220102] input: AT Translated Set 2 keyboard as /devices/platform/i8042/serio0/input/input1
[    3.222071] bus: 'i2c': add driver max7359
[    3.223065] bus: 'i2c': add driver mpr121
[    3.224023] bus: 'serio': add driver newtonkbd
[    3.225071] bus: 'i2c': add driver qt2160
[    3.226017] bus: 'platform': add driver stmpe-keypad
[    3.227178] bus: 'serio': add driver stowaway
[    3.228258] bus: 'serio': add driver sunkbd
[    3.229249] bus: 'serio': add driver xtkbd
[    3.230219] bus: 'platform': add driver 88pm860x-touch
[    3.231455] device: 'event1': device_add
[    3.232424] PM: Adding info for No Bus:event1
[    3.233447] driver: 'serio0': driver_bound: bound to device 'atkbd'
[    3.234887] bus: 'serio': really_probe: bound device serio0 to driver atkbd
[    3.236486] bus: 'serio': driver_probe_device: matched device serio1 with driver atkbd
[    3.238288] bus: 'serio': really_probe: probing driver atkbd with device serio1
[    3.240234] atkbd: probe of serio1 rejects match -19
[    3.241413] bus: 'i2c': add driver ad7879
[    3.242355] bus: 'i2c': add driver atmel_mxt_ts
[    3.243420] bus: 'i2c': add driver bu21013_tp
[    3.244447] bus: 'platform': add driver da9034-touch
[    3.245638] bus: 'serio': add driver hampshire
[    3.246677] bus: 'serio': add driver elo
[    3.247602] bus: 'i2c': add driver egalax_ts
[    3.248603] bus: 'serio': add driver fujitsu_ts
[    3.249666] bus: 'serio': add driver inexio
[    3.250710] bus: 'i2c': add driver max11801_ts
[    3.251758] bus: 'platform': add driver mc13783-ts
[    3.252874] bus: 'platform': remove driver mc13783-ts
[    3.254067] driver: 'mc13783-ts': driver_release
[    3.255148] mk712: device not present
[    3.255996] bus: 'serio': add driver touchwin
[    3.257032] bus: 'serio': add driver tsc40
[    3.258033] bus: 'i2c': add driver tsc2007
[    3.259007] bus: 'serio': add driver w8001
[    3.260028] bus: 'platform': add driver ab3100-rtc
[    3.261173] bus: 'platform': remove driver ab3100-rtc
[    3.262353] driver: 'ab3100-rtc': driver_release
[    3.263415] bus: 'platform': add driver rtc-bq4802
[    3.264537] bus: 'pnp': add driver rtc_cmos
[    3.265537] bus: 'pnp': driver_probe_device: matched device 00:01 with driver rtc_cmos
[    3.267335] bus: 'pnp': really_probe: probing driver rtc_cmos with device 00:01
[    3.269093] rtc_cmos 00:01: RTC can wake from S4
[    3.270468] rtc (null): alarm rollover: day
[    3.271540] device: 'rtc0': device_add
[    3.272487] PM: Adding info for No Bus:rtc0
[    3.273467] rtc_cmos 00:01: rtc core: registered rtc_cmos as rtc0
[    3.275010] rtc0: alarms up to one day, 114 bytes nvram, hpet irqs
[    3.276450] driver: '00:01': driver_bound: bound to device 'rtc_cmos'
[    3.277925] bus: 'pnp': really_probe: bound device 00:01 to driver rtc_cmos
[    3.279545] bus: 'platform': add driver rtc-ds1286
[    3.280667] bus: 'i2c': add driver rtc-ds1307
[    3.281691] bus: 'platform': add driver ds1511
[    3.282768] bus: 'i2c': add driver rtc-ds1672
[    3.283790] bus: 'platform': add driver rtc-ds1742
[    3.284907] bus: 'i2c': add driver rtc-fm3130
[    3.285927] bus: 'i2c': add driver rtc-isl12022
[    3.286993] bus: 'i2c': add driver rtc-m41t80
[    3.288014] bus: 'platform': add driver mc13xxx-rtc
[    3.289158] bus: 'platform': remove driver mc13xxx-rtc
[    3.290375] driver: 'mc13xxx-rtc': driver_release
[    3.291542] bus: 'platform': add driver rtc-msm6242
[    3.292686] bus: 'platform': remove driver rtc-msm6242
[    3.293880] driver: 'rtc-msm6242': driver_release
[    3.294973] bus: 'i2c': add driver rtc-pcf8563
[    3.296065] bus: 'i2c': add driver pcf8583
[    3.297022] bus: 'i2c': add driver rtc-rx8581
[    3.298080] bus: 'i2c': add driver rtc-s35390a
[    3.299119] bus: 'platform': add driver stk17ta8
[    3.300194] bus: 'platform': add driver wm831x-rtc
[    3.301347] bus: 'platform': add driver wm8350-rtc
[    3.302498] bus: 'i2c': add driver rtc-x1205
[    3.303512] bus: 'i2c': add driver smbus_alert
[    3.304549] i2c /dev entries driver
[    3.305371] device class 'i2c-dev': registering
[    3.306493] bus: 'platform': add driver ocores-i2c
[    3.307619] bus: 'platform': add driver simtec-i2c
[    3.308759] i2c-parport-light: adapter type unspecified
[    3.309982] bus: 'serio': add driver taos-evm
[    3.311034] Driver for 1-wire Dallas network protocol.
[    3.312264] bus: 'w1': registered
[    3.313043] bus: 'w1': add driver w1_master_driver
[    3.314153] bus: 'w1': add driver w1_slave_driver
[    3.315255] DS1WM w1 busmaster driver - (c) 2004 Szabolcs Gyurko
[    3.316639] bus: 'platform': add driver ds1wm
[    3.317686] bus: 'platform': add driver max8925-power
[    3.318860] bus: 'platform': add driver wm831x-power
[    3.320046] bus: 'platform': add driver wm8350-power
[    3.321283] device: 'test_ac': device_add
[    3.322275] PM: Adding info for No Bus:test_ac
[    3.323309] power_supply test_ac: uevent
[    3.324234] power_supply test_ac: POWER_SUPPLY_NAME=test_ac
[    3.325544] power_supply test_ac: prop ONLINE=1
[    3.326609] power_supply test_ac: power_supply_changed
[    3.327792] power_supply test_ac: power_supply_changed_work
[    3.329112] power_supply test_ac: uevent
[    3.330018] power_supply test_ac: POWER_SUPPLY_NAME=test_ac
[    3.331304] device: 'test_battery': device_add
[    3.332430] PM: Adding info for No Bus:test_battery
[    3.333561] power_supply test_battery: uevent
[    3.334576] power_supply test_battery: POWER_SUPPLY_NAME=test_battery
[    3.336076] power_supply test_battery: prop STATUS=Discharging
[    3.337418] power_supply test_battery: prop CHARGE_TYPE=Fast
[    3.338712] power_supply test_battery: prop HEALTH=Good
[    3.339900] power_supply test_battery: prop PRESENT=1
[    3.341106] power_supply test_ac: prop ONLINE=1
[    3.342174] power_supply test_battery: prop TECHNOLOGY=Li-ion
[    3.343499] power_supply test_battery: prop CHARGE_FULL_DESIGN=100
[    3.344917] power_supply test_battery: prop CHARGE_FULL=100
[    3.346188] power_supply test_battery: prop CHARGE_NOW=50
[    3.347421] power_supply test_battery: prop CAPACITY=50
[    3.348626] power_supply test_battery: prop CAPACITY_LEVEL=Normal
[    3.350022] power_supply test_battery: prop TIME_TO_EMPTY_AVG=3600
[    3.351438] power_supply test_battery: prop TIME_TO_FULL_NOW=3600
[    3.352819] power_supply test_battery: prop MODEL_NAME=Test battery
[    3.354246] power_supply test_battery: prop MANUFACTURER=Linux
[    3.355585] power_supply test_battery: prop SERIAL_NUMBER=3.5.0-01540-g1669891
[    3.357221] power_supply test_battery: prop TEMP=26
[    3.358334] power_supply test_battery: prop VOLTAGE_NOW=3300
[    3.359693] device: 'thermal_zone0': device_add
[    3.360778] PM: Adding info for No Bus:thermal_zone0
[    3.361996] device: 'hwmon0': device_add
[    3.362950] PM: Adding info for No Bus:hwmon0
[    3.363999] power_supply test_battery: power_supply_changed
[    3.365282] power_supply test_battery: power_supply_changed_work
[    3.366661] power_supply test_battery: uevent
[    3.367666] power_supply test_battery: POWER_SUPPLY_NAME=test_battery
[    3.369168] power_supply test_battery: prop STATUS=Discharging
[    3.370526] device: 'test_usb': device_add
[    3.371526] PM: Adding info for No Bus:test_usb
[    3.372573] power_supply test_usb: uevent
[    3.373501] power_supply test_usb: POWER_SUPPLY_NAME=test_usb
[    3.374844] power_supply test_usb: prop ONLINE=1
[    3.375929] power_supply test_usb: power_supply_changed
[    3.377132] bus: 'platform': add driver ds2780-battery
[    3.378331] bus: 'i2c': add driver sbs-battery
[    3.379364] i2c-core: driver [sbs-battery] using legacy suspend method
[    3.380867] power_supply test_battery: prop CHARGE_TYPE=Fast
[    3.382161] power_supply test_battery: prop HEALTH=Good
[    3.383357] power_supply test_battery: prop PRESENT=1
[    3.384521] power_supply test_battery: prop TECHNOLOGY=Li-ion
[    3.385842] power_supply test_battery: prop CHARGE_FULL_DESIGN=100
[    3.387261] power_supply test_battery: prop CHARGE_FULL=100
[    3.388539] power_supply test_battery: prop CHARGE_NOW=50
[    3.389776] power_supply test_battery: prop CAPACITY=50
[    3.391001] bus: 'i2c': add driver w83792d
[    3.391788] bus: 'i2c': add driver w83781d
[    3.392718] bus: 'i2c': add driver ad7418
[    3.393671] bus: 'i2c': add driver adm1021
[    3.394668] bus: 'i2c': add driver adm1029
[    3.395639] bus: 'i2c': add driver ads7828
[    3.396599] bus: 'i2c': add driver adt7470
[    3.397564] applesmc: supported laptop not found!
[    3.398654] applesmc: driver init failed (ret=-19)!
[    3.399789] bus: 'i2c': add driver atxp1
[    3.400721] power_supply test_battery: prop CAPACITY_LEVEL=Normal
[    3.402119] power_supply test_battery: prop TIME_TO_EMPTY_AVG=3600
[    3.403537] power_supply test_battery: prop TIME_TO_FULL_NOW=3600
[    3.404931] power_supply test_battery: prop MODEL_NAME=Test battery
[    3.406371] power_supply test_battery: prop MANUFACTURER=Linux
[    3.407707] power_supply test_battery: prop SERIAL_NUMBER=3.5.0-01540-g1669891
[    3.409370] power_supply test_battery: prop TEMP=26
[    3.410529] bus: 'i2c': add driver emc2103
[    3.411494] bus: 'i2c': add driver emc6w201
[    3.412509] bus: 'i2c': add driver g760a
[    3.413320] bus: 'i2c': add driver gl520sm
[    3.414283] bus: 'platform': add driver aem
[    3.415273] bus: 'i2c': add driver ina2xx
[    3.416280] bus: 'i2c': add driver lineage_pem
[    3.417334] bus: 'i2c': add driver lm77
[    3.418239] bus: 'i2c': add driver lm78
[    3.419177] bus: 'i2c': add driver lm83
[    3.420081] bus: 'i2c': add driver lm85
[    3.420990] power_supply test_battery: prop VOLTAGE_NOW=3300
[    3.422308] power_supply test_usb: power_supply_changed_work
[    3.423617] power_supply test_usb: uevent
[    3.424544] power_supply test_usb: POWER_SUPPLY_NAME=test_usb
[    3.425884] power_supply test_usb: prop ONLINE=1
[    3.427020] bus: 'i2c': add driver lm92
[    3.427925] bus: 'i2c': add driver ltc4151
[    3.428890] bus: 'i2c': add driver ltc4261
[    3.429853] bus: 'i2c': add driver max1668
[    3.430857] bus: 'i2c': add driver max6639
[    3.431823] bus: 'i2c': add driver max6642
[    3.432786] bus: 'platform': add driver mc13783-adc
[    3.433960] bus: 'platform': remove driver mc13783-adc
[    3.435150] driver: 'mc13783-adc': driver_release
[    3.436237] bus: 'platform': add driver ntc-thermistor
[    3.437477] pc87360: PC8736x not detected, module not inserted
[    3.438820] bus: 'i2c': add driver pcf8591
[    3.439830] bus: 'i2c': add driver smsc47m192
[    3.440864] bus: 'i2c': add driver thmc50
[    3.441844] bus: 'i2c': add driver tmp421
[    3.442841] bus: 'platform': add driver wm831x-hwmon
[    3.444011] Bluetooth: HCI UART driver ver 2.2
[    3.445046] Bluetooth: HCI H4 protocol initialized
[    3.446150] Bluetooth: HCILL protocol initialized
[    3.447232] Bluetooth: HCIATH3K protocol initialized
[    3.448380] Modular ISDN core version 1.1.29
[    3.449383] device class 'mISDN': registering
[    3.450430] device: 'mISDNtimer': device_add
[    3.451479] PM: Adding info for No Bus:mISDNtimer
[    3.452587] NET: Registered protocol family 34
[    3.453614] DSP module 2.0
[    3.454256] mISDN_dsp: DSP clocks every 80 samples. This equals 1 jiffies.
[    3.458662] device class 'dsp_pipeline': registering
[    3.459769] device: 'hwec': device_add
[    3.460491] PM: Adding info for No Bus:hwec
[    3.461337] mISDN: Layer-1-over-IP driver Rev. 2.00
[    3.462971] 0 virtual devices registered
[    3.463691] cpuidle: using governor ladder
[    3.464557] sdhci: Secure Digital Host Controller Interface driver
[    3.465952] sdhci: Copyright(c) Pierre Ossman
[    3.466954] wbsd: Winbond W83L51xD SD/MMC card interface driver
[    3.468301] wbsd: Copyright(c) Pierre Ossman
[    3.469230] bus: 'pnp': add driver wbsd
[    3.470270] bus: 'memstick': registered
[    3.471090] device class 'memstick_host': registering
[    3.472017] bus: 'platform': add driver 88pm860x-led
[    3.472924] bus: 'i2c': add driver BD2802
[    3.473670] bus: 'i2c': add driver lm3530-led
[    3.474603] bus: 'platform': add driver lm3533-leds
[    3.475518] bus: 'i2c': add driver lp3944
[    3.476260] bus: 'i2c': add driver lp5521
[    3.477061] bus: 'i2c': add driver lp5523
[    3.477799] bus: 'i2c': add driver leds-tca6507
[    3.478791] bus: 'platform': add driver leds-ot200
[    3.479840] bus: 'i2c': add driver leds-pca955x
[    3.480695] bus: 'i2c': add driver leds-pca9633
[    3.481670] bus: 'platform': add driver da903x-led
[    3.482810] bus: 'platform': add driver wm831x-status
[    3.483942] bus: 'platform': add driver wm8350-led
[    3.484822] bus: 'platform': add driver mc13783-led
[    3.485972] Registering platform device 'dell_rbu'. Parent at platform
[    3.487460] device: 'dell_rbu': device_add
[    3.488409] bus: 'platform': add device dell_rbu
[    3.489369] PM: Adding info for platform:dell_rbu
[    3.490277] bus: 'hid': registered
[    3.490922] device class 'hidraw': registering
[    3.492028] bus: 'hid': add driver tivo_slide
[    3.493051] bus: 'hid': add driver wiimote
[    3.494017] device class 'extcon': registering
[    3.495110] device: 'timer': device_add
[    3.496030] PM: Adding info for No Bus:timer
[    3.497073] bus: 'platform': add driver snd_mtpav
[    3.498169] Registering platform device 'snd_mtpav'. Parent at platform
[    3.499675] device: 'snd_mtpav': device_add
[    3.500657] bus: 'platform': add device snd_mtpav
[    3.501724] PM: Adding info for platform:snd_mtpav
[    3.502841] bus: 'platform': driver_probe_device: matched device snd_mtpav with driver snd_mtpav
[    3.504594] bus: 'platform': really_probe: probing driver snd_mtpav with device snd_mtpav
[    3.507072] device: 'card0': device_add
[    3.507822] PM: Adding info for No Bus:card0
[    3.508610] device: 'midiC0D0': device_add
[    3.509376] PM: Adding info for No Bus:midiC0D0
[    3.510267] device: 'midi': device_add
[    3.511186] PM: Adding info for No Bus:midi
[    3.512131] device: 'dmmidi': device_add
[    3.512896] PM: Adding info for No Bus:dmmidi
[    3.513747] device: 'controlC0': device_add
[    3.514677] PM: Adding info for No Bus:controlC0
[    3.515530] device: 'mixer': device_add
[    3.516355] PM: Adding info for No Bus:mixer
[    3.517435] Motu MidiTimePiece on parallel port irq: 7 ioport: 0x378
[    3.518729] driver: 'snd_mtpav': driver_bound: bound to device 'snd_mtpav'
[    3.519952] bus: 'platform': really_probe: bound device snd_mtpav to driver snd_mtpav
[    3.521778] bus: 'platform': add driver snd_mpu401
[    3.522891] bus: 'pnp': add driver mpu401
[    3.523841] bus: 'pnp': remove driver mpu401
[    3.524826] driver: 'mpu401': driver_release
[    3.525807] bus: 'platform': remove driver snd_mpu401
[    3.526924] driver: 'snd_mpu401': driver_release
[    3.527858] Registering platform device 'snd-soc-dummy'. Parent at platform
[    3.529143] device: 'snd-soc-dummy': device_add
[    3.530199] bus: 'platform': add device snd-soc-dummy
[    3.531435] PM: Adding info for platform:snd-soc-dummy
[    3.532645] bus: 'platform': add driver snd-soc-dummy
[    3.533580] bus: 'platform': driver_probe_device: matched device snd-soc-dummy with driver snd-soc-dummy
[    3.535616] bus: 'platform': really_probe: probing driver snd-soc-dummy with device snd-soc-dummy
[    3.537639] driver: 'snd-soc-dummy': driver_bound: bound to device 'snd-soc-dummy'
[    3.539028] bus: 'platform': really_probe: bound device snd-soc-dummy to driver snd-soc-dummy
[    3.541013] bus: 'platform': add driver soc-audio
[    3.542124] bus: 'platform': add driver 88pm860x-codec
[    3.543327] bus: 'platform': add driver ab8500-codec
[    3.544487] bus: 'i2c': add driver ad193x
[    3.545485] bus: 'platform': add driver ad73311
[    3.546552] bus: 'i2c': add driver adau1373
[    3.547534] bus: 'i2c': add driver adav803
[    3.548496] bus: 'platform': add driver ads117x-codec
[    3.549664] bus: 'i2c': add driver ak4535
[    3.550667] bus: 'i2c': add driver ak4641
[    3.551652] bus: 'i2c': add driver ak4642-codec
[    3.552715] bus: 'i2c': add driver ak4671-codec
[    3.553778] bus: 'i2c': add driver alc562x-codec
[    3.554857] bus: 'i2c': add driver alc5632
[    3.555841] bus: 'i2c': add driver cs42l51-codec
[    3.556914] bus: 'i2c': add driver cs42l52
[    3.557914] bus: 'i2c': add driver cs42l73
[    3.558878] bus: 'i2c': add driver cs4270
[    3.559833] bus: 'i2c': add driver cs4271
[    3.560796] bus: 'platform': add driver cx20442-codec
[    3.561968] bus: 'i2c': add driver da7210
[    3.562716] bus: 'i2c': add driver da7320
[    3.563501] bus: 'platform': add driver dfbmcs320
[    3.564366] bus: 'i2c': add driver isabelle
[    3.565180] bus: 'platform': add driver jz4740-codec
[    3.566250] bus: 'i2c': add driver lm4857
[    3.566999] bus: 'i2c': add driver lm49453
[    3.567762] bus: 'i2c': add driver max9768
[    3.568521] bus: 'i2c': add driver max98088
[    3.569434] bus: 'i2c': add driver max98095
[    3.570451] bus: 'i2c': add driver max9850
[    3.571427] bus: 'platform': add driver mc13783-codec
[    3.572622] bus: 'i2c': add driver ml26124
[    3.573600] bus: 'platform': add driver pcm3008-codec
[    3.574786] bus: 'i2c': add driver rt5631
[    3.575781] bus: 'i2c': add driver sgtl5000
[    3.576761] bus: 'platform': add driver spdif-dir
[    3.577896] bus: 'platform': add driver spdif-dit
[    3.578996] bus: 'i2c': add driver ssm2602
[    3.579972] bus: 'i2c': add driver sta32x
[    3.580950] bus: 'i2c': add driver sta529
[    3.581970] bus: 'i2c': add driver tlv320aic23-codec
[    3.583135] bus: 'i2c': add driver tlv320aic3x-codec
[    3.584314] bus: 'i2c': add driver tlv320aic32x4
[    3.585412] bus: 'i2c': add driver tlv320dac33-codec
[    3.586585] bus: 'platform': add driver twl6040-codec
[    3.587781] bus: 'platform': add driver uda134x-codec
[    3.589018] bus: 'i2c': add driver uda1380-codec
[    3.590119] bus: 'platform': add driver wl1273-codec
[    3.591306] bus: 'i2c': add driver wm1250-ev1
[    3.592325] bus: 'i2c': add driver wm2000
[    3.593273] bus: 'i2c': add driver wm2200
[    3.594231] bus: 'i2c': add driver wm5100
[    3.595196] bus: 'platform': add driver wm8350-codec
[    3.596416] bus: 'i2c': add driver wm8510
[    3.597371] bus: 'i2c': add driver wm8523
[    3.598326] bus: 'i2c': add driver wm8580
[    3.599305] bus: 'i2c': add driver wm8711
[    3.600247] bus: 'platform': add driver wm8727
[    3.601303] bus: 'i2c': add driver wm8728
[    3.602299] bus: 'i2c': add driver wm8731
[    3.603245] bus: 'i2c': add driver wm8737
[    3.604192] bus: 'i2c': add driver wm8741
[    3.605131] bus: 'i2c': add driver wm8750
[    3.606076] bus: 'i2c': add driver wm8753
[    3.607019] bus: 'i2c': add driver wm8776
[    3.607997] bus: 'platform': add driver wm8782
[    3.609036] bus: 'i2c': add driver wm8804
[    3.609975] bus: 'i2c': add driver wm8900
[    3.610950] bus: 'i2c': add driver wm8903
[    3.611906] bus: 'i2c': add driver wm8904
[    3.612862] bus: 'i2c': add driver wm8996
[    3.613844] bus: 'i2c': add driver wm8940
[    3.614820] bus: 'i2c': add driver wm8955
[    3.615762] bus: 'i2c': add driver wm8960
[    3.616709] bus: 'i2c': add driver wm8961
[    3.617663] bus: 'i2c': add driver wm8962
[    3.618643] bus: 'i2c': add driver wm8971
[    3.619596] bus: 'i2c': add driver wm8974
[    3.620600] bus: 'i2c': add driver wm8978
[    3.621555] bus: 'i2c': add driver wm8983
[    3.622492] bus: 'i2c': add driver wm8985
[    3.623444] bus: 'i2c': add driver wm8988
[    3.624386] bus: 'i2c': add driver wm8990
[    3.625327] bus: 'i2c': add driver wm8991
[    3.626308] bus: 'i2c': add driver wm8993
[    3.627267] bus: 'i2c': add driver wm8995
[    3.628207] bus: 'i2c': add driver wm9081
[    3.629145] bus: 'i2c': add driver wm9090
[    3.630133] bus: 'i2c': add driver max9877
[    3.631133] bus: 'i2c': add driver tpa6130a2
[    3.632174] bus: 'platform': add driver asoc-simple-card
[    3.633441] oprofile: using timer interrupt.
[    3.634666] NET: Registered protocol family 26
[    3.635722] gre: GRE over IPv4 demultiplexor driver
[    3.636915] TCP: bic registered
[    3.637654] TCP: highspeed registered
[    3.638500] TCP: hybla registered
[    3.639271] TCP: htcp registered
[    3.640037] TCP: vegas registered
[    3.640834] TCP: lp registered
[    3.641567] NET: Registered protocol family 17
[    3.642717] device: 'irlan0': device_add
[    3.643769] PM: Adding info for No Bus:irlan0
[    3.644989] IrCOMM protocol (Dag Brattli)
[    3.645924] device: 'ircomm0': device_add
[    3.646913] PM: Adding info for No Bus:ircomm0
[    3.647944] device: 'ircomm1': device_add
[    3.648946] PM: Adding info for No Bus:ircomm1
[    3.650049] device: 'ircomm2': device_add
[    3.651058] PM: Adding info for No Bus:ircomm2
[    3.652093] device: 'ircomm3': device_add
[    3.653046] PM: Adding info for No Bus:ircomm3
[    3.654092] device: 'ircomm4': device_add
[    3.655086] PM: Adding info for No Bus:ircomm4
[    3.656121] device: 'ircomm5': device_add
[    3.657083] PM: Adding info for No Bus:ircomm5
[    3.658129] device: 'ircomm6': device_add
[    3.659140] PM: Adding info for No Bus:ircomm6
[    3.660198] device: 'ircomm7': device_add
[    3.661214] PM: Adding info for No Bus:ircomm7
[    3.662263] device: 'ircomm8': device_add
[    3.663215] PM: Adding info for No Bus:ircomm8
[    3.664274] device: 'ircomm9': device_add
[    3.665288] PM: Adding info for No Bus:ircomm9
[    3.666377] device: 'ircomm10': device_add
[    3.667391] PM: Adding info for No Bus:ircomm10
[    3.668480] device: 'ircomm11': device_add
[    3.669467] PM: Adding info for No Bus:ircomm11
[    3.670547] device: 'ircomm12': device_add
[    3.671593] PM: Adding info for No Bus:ircomm12
[    3.672657] device: 'ircomm13': device_add
[    3.673698] PM: Adding info for No Bus:ircomm13
[    3.674751] device: 'ircomm14': device_add
[    3.675725] PM: Adding info for No Bus:ircomm14
[    3.676797] device: 'ircomm15': device_add
[    3.677852] PM: Adding info for No Bus:ircomm15
[    3.678932] device: 'ircomm16': device_add
[    3.679953] PM: Adding info for No Bus:ircomm16
[    3.681031] device: 'ircomm17': device_add
[    3.682035] PM: Adding info for No Bus:ircomm17
[    3.683141] device: 'ircomm18': device_add
[    3.684162] PM: Adding info for No Bus:ircomm18
[    3.685225] device: 'ircomm19': device_add
[    3.686197] PM: Adding info for No Bus:ircomm19
[    3.687261] device: 'ircomm20': device_add
[    3.688274] PM: Adding info for No Bus:ircomm20
[    3.689337] device: 'ircomm21': device_add
[    3.690378] PM: Adding info for No Bus:ircomm21
[    3.691433] device: 'ircomm22': device_add
[    3.692420] PM: Adding info for No Bus:ircomm22
[    3.693473] device: 'ircomm23': device_add
[    3.694496] PM: Adding info for No Bus:ircomm23
[    3.695546] device: 'ircomm24': device_add
[    3.696568] PM: Adding info for No Bus:ircomm24
[    3.697679] device: 'ircomm25': device_add
[    3.698682] PM: Adding info for No Bus:ircomm25
[    3.699815] device: 'ircomm26': device_add
[    3.700845] PM: Adding info for No Bus:ircomm26
[    3.701915] device: 'ircomm27': device_add
[    3.702926] PM: Adding info for No Bus:ircomm27
[    3.703998] device: 'ircomm28': device_add
[    3.704987] PM: Adding info for No Bus:ircomm28
[    3.706056] device: 'ircomm29': device_add
[    3.707066] PM: Adding info for No Bus:ircomm29
[    3.708131] device: 'ircomm30': device_add
[    3.709149] PM: Adding info for No Bus:ircomm30
[    3.710202] device: 'ircomm31': device_add
[    3.711231] PM: Adding info for No Bus:ircomm31
[    3.712396] Bluetooth: RFCOMM socket layer initialized
[    3.713580] Bluetooth: RFCOMM ver 1.11
[    3.714446] Bluetooth: BNEP (Ethernet Emulation) ver 1.3
[    3.715675] Bluetooth: BNEP filters: protocol 
[    3.716692] Bluetooth: BNEP socket layer initialized
[    3.717821] Bluetooth: HIDP (Human Interface Emulation) ver 1.2
[    3.719198] Bluetooth: HIDP socket layer initialized
[    3.720655] NET: Registered protocol family 33
[    3.721700] Key type rxrpc registered
[    3.722570] Key type rxrpc_s registered
[    3.723475] 8021q: 802.1Q VLAN Support v1.8
[    3.724546] 9pnet: Installing 9P2000 support
[    3.725644] NET: Registered protocol family 37
[    3.726751] NET: Registered protocol family 36
[    3.727802] Key type dns_resolver registered
[    3.728797] Key type ceph registered
[    3.729653] libceph: loaded (mon/osd proto 15/24, osdmap 5/6 5/6)
[    3.731414] 
[    3.731414] printing PIC contents
[    3.732542] ... PIC  IMR: ffff
[    3.733261] ... PIC  IRR: 1113
[    3.733998] ... PIC  ISR: 0000
[    3.734712] ... PIC ELCR: 0c00
[    3.735442] printing local APIC contents on CPU#0/0:
[    3.736587] ... APIC ID:      00000000 (0)
[    3.737550] ... APIC VERSION: 00050014
[    3.738512] ... APIC TASKPRI: 00000000 (00)
[    3.739498] ... APIC PROCPRI: 00000000
[    3.740372] ... APIC LDR: 01000000
[    3.741077] ... APIC DFR: ffffffff
[    3.741077] ... APIC SPIV: 000001ff
[    3.741077] ... APIC ISR field:
[    3.741077] 0000000000000000000000000000000000000000000000000000000000000000
[    3.741077] ... APIC TMR field:
[    3.741077] 0000000000000000000000000000000000000000000000000000000000000000
[    3.741077] ... APIC IRR field:
[    3.741077] 0000000000000000000000000000000000000000000000000000000000008000
[    3.741077] ... APIC ESR: 00000000
[    3.741077] ... APIC ICR: 00000831
[    3.741077] ... APIC ICR2: 01000000
[    3.741077] ... APIC LVTT: 000200ef
[    3.741077] ... APIC LVTPC: 00010000
[    3.741077] ... APIC LVT0: 00010700
[    3.741077] ... APIC LVT1: 00000400
[    3.741077] ... APIC LVTERR: 000000fe
[    3.741077] ... APIC TMICT: 000988bf
[    3.741077] ... APIC TMCCT: 0001f61c
[    3.741077] ... APIC TDCR: 00000003
[    3.741077] 
[    3.760311] number of MP IRQ sources: 15.
[    3.761273] number of IO-APIC #2 registers: 24.
[    3.762333] testing the IO APIC.......................
[    3.763555] IO APIC #2......
[    3.764232] .... register #00: 00000000
[    3.765119] .......    : physical APIC id: 00
[    3.766117] .......    : Delivery Type: 0
[    3.767038] .......    : LTS          : 0
[    3.767958] .... register #01: 00170011
[    3.768857] .......     : max redirection entries: 17
[    3.770018] .......     : PRQ implemented: 0
[    3.771014] .......     : IO APIC version: 11
[    3.772018] .... register #02: 00000000
[    3.772897] .......     : arbitration: 00
[    3.773840] .... IRQ redirection table:
[    3.774745]  NR Dst Mask Trig IRR Pol Stat Dmod Deli Vect:
[    3.776035]  00 00  1    0    0   0   0    0    0    00
[    3.777279]  01 01  0    0    0   0   0    1    1    31
[    3.778533]  02 01  0    0    0   0   0    1    1    30
[    3.779802]  03 01  0    0    0   0   0    1    1    33
[    3.781083]  04 01  1    0    0   0   0    1    1    34
[    3.782323]  05 01  1    1    0   0   0    1    1    35
[    3.783564]  06 01  0    0    0   0   0    1    1    36
[    3.784817]  07 01  0    0    0   0   0    1    1    37
[    3.786078]  08 01  0    0    0   0   0    1    1    38
[    3.787319]  09 01  0    1    0   0   0    1    1    39
[    3.788575]  0a 01  1    1    0   0   0    1    1    3A
[    3.789813]  0b 01  1    1    0   0   0    1    1    3B
[    3.791094]  0c 01  0    0    0   0   0    1    1    3C
[    3.792339]  0d 01  0    0    0   0   0    1    1    3D
[    3.793600]  0e 01  0    0    0   0   0    1    1    3E
[    3.794855]  0f 01  0    0    0   0   0    1    1    3F
[    3.796118]  10 00  1    0    0   0   0    0    0    00
[    3.797364]  11 00  1    0    0   0   0    0    0    00
[    3.798603]  12 00  1    0    0   0   0    0    0    00
[    3.799869]  13 00  1    0    0   0   0    0    0    00
[    3.801151]  14 00  1    0    0   0   0    0    0    00
[    3.802395]  15 00  1    0    0   0   0    0    0    00
[    3.803653]  16 00  1    0    0   0   0    0    0    00
[    3.804906]  17 00  1    0    0   0   0    0    0    00
[    3.806163] IRQ to pin mappings:
[    3.806927] IRQ0 -> 0:2
[    3.807577] IRQ1 -> 0:1
[    3.808221] IRQ3 -> 0:3
[    3.808880] IRQ4 -> 0:4
[    3.809531] IRQ5 -> 0:5
[    3.810189] IRQ6 -> 0:6
[    3.810860] IRQ7 -> 0:7
[    3.811508] IRQ8 -> 0:8
[    3.812165] IRQ9 -> 0:9
[    3.812816] IRQ10 -> 0:10
[    3.813505] IRQ11 -> 0:11
[    3.814200] IRQ12 -> 0:12
[    3.814892] IRQ13 -> 0:13
[    3.815581] IRQ14 -> 0:14
[    3.816264] IRQ15 -> 0:15
[    3.816954] .................................... done.
[    3.818163] tsc: Refined TSC clocksource calibration: 2666.666 MHz
[    3.819614] device: 'cpu_dma_latency': device_add
[    3.820746] PM: Adding info for No Bus:cpu_dma_latency
[    3.821949] device: 'network_latency': device_add
[    3.823110] PM: Adding info for No Bus:network_latency
[    3.824299] device: 'network_throughput': device_add
[    3.825477] PM: Adding info for No Bus:network_throughput
[    3.826735] registered taskstats version 1
[    3.827695] kAFS: Red Hat AFS client v0.1 registering.
[    3.828936] kAFS: failed to register: -12
[    3.830786]   Magic number: 8:220:142
[    3.831704] acpi device:13: hash matches
[    3.832652] bus: 'i2c': add driver wl1273-fm
[    3.833767] rtc_cmos 00:01: setting system clock to 2012-08-15 19:08:55 UTC (1345057735)
[    3.835807] bus: 'platform': add driver charger-manager
[    3.837051] BIOS EDD facility v0.16 2004-Jun-25, 6 devices found
[    3.838889] ALSA device list:
[    3.839591]   #0: MTPAV on parallel port at 0x378
[    3.841301] debug: unmapping init [mem 0xffffffff82282000-0xffffffff822fdfff]
[    3.843114] Write protecting the kernel read-only data: 14336k
[    3.845030] Testing CPA: undo ffffffff81000000-ffffffff81e00000
[    3.846704] Testing CPA: again
[    3.847703] debug: unmapping init [mem 0xffff8800016dd000-0xffff8800017fffff]
[    3.849524] debug: unmapping init [mem 0xffff880001ca8000-0xffff880001dfffff]
[    3.889685] hostname (79) used greatest stack depth: 5328 bytes left
/bin/sh: /proc/self/fd/9: No such file or directory
/bin/sh: /proc/self/fd/9: No such file or directory
/bin/sh: /proc/self/fd/9: No such file or directory

--45Z9DzgjV8m4Oswq
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename="config-3.5.0-01540-g1669891"

#
# Automatically generated file; DO NOT EDIT.
# Linux/x86_64 3.5.0 Kernel Configuration
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
CONFIG_ARCH_HWEIGHT_CFLAGS="-fcall-saved-rdi -fcall-saved-rsi -fcall-saved-rdx -fcall-saved-rcx -fcall-saved-r8 -fcall-saved-r9 -fcall-saved-r10 -fcall-saved-r11"
CONFIG_ARCH_SUPPORTS_UPROBES=y
CONFIG_DEFCONFIG_LIST="/lib/modules/$UNAME_RELEASE/.config"
CONFIG_CONSTRUCTORS=y
CONFIG_HAVE_IRQ_WORK=y
CONFIG_IRQ_WORK=y
CONFIG_BUILDTIME_EXTABLE_SORT=y

#
# General setup
#
CONFIG_EXPERIMENTAL=y
CONFIG_BROKEN_ON_SMP=y
CONFIG_INIT_ENV_ARG_LIMIT=32
CONFIG_CROSS_COMPILE=""
CONFIG_LOCALVERSION=""
CONFIG_LOCALVERSION_AUTO=y
CONFIG_HAVE_KERNEL_GZIP=y
CONFIG_HAVE_KERNEL_BZIP2=y
CONFIG_HAVE_KERNEL_LZMA=y
CONFIG_HAVE_KERNEL_XZ=y
CONFIG_HAVE_KERNEL_LZO=y
# CONFIG_KERNEL_GZIP is not set
# CONFIG_KERNEL_BZIP2 is not set
# CONFIG_KERNEL_LZMA is not set
# CONFIG_KERNEL_XZ is not set
CONFIG_KERNEL_LZO=y
CONFIG_DEFAULT_HOSTNAME="(none)"
# CONFIG_SYSVIPC is not set
# CONFIG_POSIX_MQUEUE is not set
CONFIG_BSD_PROCESS_ACCT=y
CONFIG_BSD_PROCESS_ACCT_V3=y
# CONFIG_FHANDLE is not set
CONFIG_TASKSTATS=y
# CONFIG_TASK_DELAY_ACCT is not set
# CONFIG_TASK_XACCT is not set
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
CONFIG_IRQ_DOMAIN=y
CONFIG_IRQ_DOMAIN_DEBUG=y
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
# CONFIG_NO_HZ is not set
# CONFIG_HIGH_RES_TIMERS is not set

#
# RCU Subsystem
#
CONFIG_TINY_RCU=y
# CONFIG_PREEMPT_RCU is not set
# CONFIG_TREE_RCU_TRACE is not set
CONFIG_IKCONFIG=y
CONFIG_LOG_BUF_SHIFT=17
CONFIG_HAVE_UNSTABLE_SCHED_CLOCK=y
CONFIG_CHECKPOINT_RESTORE=y
# CONFIG_NAMESPACES is not set
# CONFIG_SCHED_AUTOGROUP is not set
# CONFIG_SYSFS_DEPRECATED is not set
# CONFIG_RELAY is not set
CONFIG_BLK_DEV_INITRD=y
CONFIG_INITRAMFS_SOURCE=""
CONFIG_RD_GZIP=y
# CONFIG_RD_BZIP2 is not set
# CONFIG_RD_LZMA is not set
# CONFIG_RD_XZ is not set
# CONFIG_RD_LZO is not set
CONFIG_CC_OPTIMIZE_FOR_SIZE=y
CONFIG_ANON_INODES=y
CONFIG_EXPERT=y
CONFIG_KALLSYMS=y
CONFIG_KALLSYMS_ALL=y
CONFIG_HOTPLUG=y
CONFIG_PRINTK=y
CONFIG_BUG=y
CONFIG_ELF_CORE=y
CONFIG_PCSPKR_PLATFORM=y
CONFIG_HAVE_PCSPKR_PLATFORM=y
# CONFIG_BASE_FULL is not set
CONFIG_FUTEX=y
# CONFIG_EPOLL is not set
CONFIG_SIGNALFD=y
CONFIG_TIMERFD=y
# CONFIG_EVENTFD is not set
# CONFIG_SHMEM is not set
CONFIG_AIO=y
CONFIG_EMBEDDED=y
CONFIG_HAVE_PERF_EVENTS=y
CONFIG_PERF_USE_VMALLOC=y

#
# Kernel Performance Events And Counters
#
CONFIG_PERF_EVENTS=y
CONFIG_DEBUG_PERF_USE_VMALLOC=y
# CONFIG_VM_EVENT_COUNTERS is not set
CONFIG_PCI_QUIRKS=y
CONFIG_SLUB_DEBUG=y
# CONFIG_COMPAT_BRK is not set
# CONFIG_SLAB is not set
CONFIG_SLUB=y
# CONFIG_SLOB is not set
CONFIG_PROFILING=y
CONFIG_OPROFILE=y
CONFIG_OPROFILE_EVENT_MULTIPLEX=y
CONFIG_HAVE_OPROFILE=y
CONFIG_OPROFILE_NMI_TIMER=y
# CONFIG_JUMP_LABEL is not set
CONFIG_HAVE_EFFICIENT_UNALIGNED_ACCESS=y
CONFIG_HAVE_IOREMAP_PROT=y
CONFIG_HAVE_KPROBES=y
CONFIG_HAVE_KRETPROBES=y
CONFIG_HAVE_OPTPROBES=y
CONFIG_HAVE_ARCH_TRACEHOOK=y
CONFIG_HAVE_DMA_ATTRS=y
CONFIG_GENERIC_SMP_IDLE_THREAD=y
CONFIG_HAVE_REGS_AND_STACK_ACCESS_API=y
CONFIG_HAVE_DMA_API_DEBUG=y
CONFIG_HAVE_HW_BREAKPOINT=y
CONFIG_HAVE_MIXED_BREAKPOINTS_REGS=y
CONFIG_HAVE_USER_RETURN_NOTIFIER=y
CONFIG_HAVE_PERF_EVENTS_NMI=y
CONFIG_HAVE_ARCH_JUMP_LABEL=y
CONFIG_ARCH_HAVE_NMI_SAFE_CMPXCHG=y
CONFIG_HAVE_ALIGNED_STRUCT_PAGE=y
CONFIG_HAVE_CMPXCHG_LOCAL=y
CONFIG_HAVE_CMPXCHG_DOUBLE=y
CONFIG_HAVE_ARCH_SECCOMP_FILTER=y

#
# GCOV-based kernel profiling
#
CONFIG_GCOV_KERNEL=y
CONFIG_GCOV_PROFILE_ALL=y
# CONFIG_HAVE_GENERIC_DMA_COHERENT is not set
CONFIG_RT_MUTEXES=y
CONFIG_BASE_SMALL=1
# CONFIG_MODULES is not set
# CONFIG_BLOCK is not set
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
# CONFIG_ZONE_DMA is not set
# CONFIG_SMP is not set
CONFIG_X86_MPPARSE=y
CONFIG_X86_EXTENDED_PLATFORM=y
CONFIG_SCHED_OMIT_FRAME_POINTER=y
CONFIG_PARAVIRT_GUEST=y
CONFIG_PARAVIRT_TIME_ACCOUNTING=y
# CONFIG_XEN is not set
# CONFIG_XEN_PRIVILEGED_GUEST is not set
CONFIG_KVM_CLOCK=y
CONFIG_KVM_GUEST=y
CONFIG_PARAVIRT=y
CONFIG_PARAVIRT_CLOCK=y
CONFIG_PARAVIRT_DEBUG=y
CONFIG_NO_BOOTMEM=y
# CONFIG_MEMTEST is not set
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
CONFIG_PROCESSOR_SELECT=y
# CONFIG_CPU_SUP_INTEL is not set
CONFIG_CPU_SUP_AMD=y
# CONFIG_CPU_SUP_CENTAUR is not set
CONFIG_HPET_TIMER=y
CONFIG_HPET_EMULATE_RTC=y
# CONFIG_DMI is not set
CONFIG_GART_IOMMU=y
# CONFIG_CALGARY_IOMMU is not set
CONFIG_SWIOTLB=y
CONFIG_IOMMU_HELPER=y
CONFIG_NR_CPUS=1
# CONFIG_IRQ_TIME_ACCOUNTING is not set
# CONFIG_PREEMPT_NONE is not set
CONFIG_PREEMPT_VOLUNTARY=y
# CONFIG_PREEMPT is not set
CONFIG_PREEMPT_COUNT=y
CONFIG_X86_LOCAL_APIC=y
CONFIG_X86_IO_APIC=y
# CONFIG_X86_REROUTE_FOR_BROKEN_BOOT_IRQS is not set
# CONFIG_X86_MCE is not set
CONFIG_I8K=y
# CONFIG_MICROCODE is not set
CONFIG_X86_MSR=y
CONFIG_X86_CPUID=y
CONFIG_ARCH_PHYS_ADDR_T_64BIT=y
CONFIG_ARCH_DMA_ADDR_T_64BIT=y
CONFIG_DIRECT_GBPAGES=y
CONFIG_ARCH_SPARSEMEM_ENABLE=y
CONFIG_ARCH_SPARSEMEM_DEFAULT=y
CONFIG_ARCH_SELECT_MEMORY_MODEL=y
CONFIG_ARCH_MEMORY_PROBE=y
CONFIG_ILLEGAL_POINTER_VALUE=0xdead000000000000
CONFIG_SELECT_MEMORY_MODEL=y
CONFIG_SPARSEMEM_MANUAL=y
CONFIG_SPARSEMEM=y
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
CONFIG_ZONE_DMA_FLAG=0
CONFIG_VIRT_TO_BUS=y
# CONFIG_KSM is not set
CONFIG_DEFAULT_MMAP_MIN_ADDR=4096
# CONFIG_TRANSPARENT_HUGEPAGE is not set
CONFIG_CROSS_MEMORY_ATTACH=y
CONFIG_NEED_PER_CPU_KM=y
# CONFIG_CLEANCACHE is not set
CONFIG_X86_CHECK_BIOS_CORRUPTION=y
CONFIG_X86_BOOTPARAM_MEMORY_CORRUPTION_CHECK=y
CONFIG_X86_RESERVE_LOW=64
CONFIG_MTRR=y
CONFIG_MTRR_SANITIZER=y
CONFIG_MTRR_SANITIZER_ENABLE_DEFAULT=0
CONFIG_MTRR_SANITIZER_SPARE_REG_NR_DEFAULT=1
CONFIG_X86_PAT=y
CONFIG_ARCH_USES_PG_UNCACHED=y
CONFIG_ARCH_RANDOM=y
# CONFIG_EFI is not set
# CONFIG_SECCOMP is not set
CONFIG_CC_STACKPROTECTOR=y
CONFIG_HZ_100=y
# CONFIG_HZ_250 is not set
# CONFIG_HZ_300 is not set
# CONFIG_HZ_1000 is not set
CONFIG_HZ=100
# CONFIG_SCHED_HRTICK is not set
# CONFIG_KEXEC is not set
# CONFIG_CRASH_DUMP is not set
CONFIG_PHYSICAL_START=0x1000000
CONFIG_RELOCATABLE=y
CONFIG_PHYSICAL_ALIGN=0x1000000
# CONFIG_CMDLINE_BOOL is not set
CONFIG_ARCH_ENABLE_MEMORY_HOTPLUG=y
CONFIG_ARCH_ENABLE_MEMORY_HOTREMOVE=y

#
# Power management and ACPI options
#
CONFIG_SUSPEND=y
CONFIG_SUSPEND_FREEZER=y
CONFIG_PM_SLEEP=y
# CONFIG_PM_AUTOSLEEP is not set
# CONFIG_PM_WAKELOCKS is not set
CONFIG_PM_RUNTIME=y
CONFIG_PM=y
CONFIG_PM_DEBUG=y
CONFIG_PM_ADVANCED_DEBUG=y
# CONFIG_PM_TEST_SUSPEND is not set
CONFIG_PM_SLEEP_DEBUG=y
CONFIG_PM_TRACE=y
CONFIG_PM_TRACE_RTC=y
CONFIG_ACPI=y
CONFIG_ACPI_SLEEP=y
# CONFIG_ACPI_EC_DEBUGFS is not set
CONFIG_ACPI_AC=y
CONFIG_ACPI_BATTERY=y
CONFIG_ACPI_BUTTON=y
CONFIG_ACPI_FAN=y
# CONFIG_ACPI_DOCK is not set
CONFIG_ACPI_PROCESSOR=y
# CONFIG_ACPI_IPMI is not set
# CONFIG_ACPI_PROCESSOR_AGGREGATOR is not set
CONFIG_ACPI_THERMAL=y
CONFIG_ACPI_CUSTOM_DSDT_FILE=""
# CONFIG_ACPI_CUSTOM_DSDT is not set
CONFIG_ACPI_BLACKLIST_YEAR=0
# CONFIG_ACPI_DEBUG is not set
# CONFIG_ACPI_PCI_SLOT is not set
CONFIG_X86_PM_TIMER=y
# CONFIG_ACPI_CONTAINER is not set
# CONFIG_ACPI_HOTPLUG_MEMORY is not set
# CONFIG_ACPI_SBS is not set
# CONFIG_ACPI_HED is not set
# CONFIG_ACPI_CUSTOM_METHOD is not set
# CONFIG_ACPI_BGRT is not set
# CONFIG_ACPI_APEI is not set
CONFIG_SFI=y

#
# CPU Frequency scaling
#
# CONFIG_CPU_FREQ is not set
CONFIG_CPU_IDLE=y
CONFIG_CPU_IDLE_GOV_LADDER=y
# CONFIG_ARCH_NEEDS_CPU_IDLE_COUPLED is not set

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
# CONFIG_PCI_MMCONFIG is not set
CONFIG_PCI_DOMAINS=y
# CONFIG_PCI_CNB20LE_QUIRK is not set
# CONFIG_PCIEPORTBUS is not set
CONFIG_ARCH_SUPPORTS_MSI=y
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
CONFIG_ISA_DMA_API=y
CONFIG_AMD_NB=y
# CONFIG_PCCARD is not set
# CONFIG_HOTPLUG_PCI is not set
# CONFIG_RAPIDIO is not set

#
# Executable file formats / Emulations
#
CONFIG_BINFMT_ELF=y
CONFIG_ARCH_BINFMT_ELF_RANDOMIZE_PIE=y
# CONFIG_CORE_DUMP_DEFAULT_ELF_HEADERS is not set
# CONFIG_HAVE_AOUT is not set
CONFIG_BINFMT_MISC=y
# CONFIG_IA32_EMULATION is not set
# CONFIG_COMPAT_FOR_U64_ALIGNMENT is not set
CONFIG_HAVE_TEXT_POKE_SMP=y
CONFIG_X86_DEV_DMA_OPS=y
CONFIG_NET=y

#
# Networking options
#
CONFIG_PACKET=y
# CONFIG_PACKET_DIAG is not set
CONFIG_UNIX=y
# CONFIG_UNIX_DIAG is not set
CONFIG_XFRM=y
CONFIG_XFRM_ALGO=y
# CONFIG_XFRM_USER is not set
# CONFIG_XFRM_SUB_POLICY is not set
# CONFIG_XFRM_MIGRATE is not set
CONFIG_XFRM_IPCOMP=y
# CONFIG_NET_KEY is not set
CONFIG_INET=y
# CONFIG_IP_MULTICAST is not set
CONFIG_IP_ADVANCED_ROUTER=y
# CONFIG_IP_FIB_TRIE_STATS is not set
# CONFIG_IP_MULTIPLE_TABLES is not set
CONFIG_IP_ROUTE_MULTIPATH=y
# CONFIG_IP_ROUTE_VERBOSE is not set
CONFIG_IP_PNP=y
CONFIG_IP_PNP_DHCP=y
CONFIG_IP_PNP_BOOTP=y
CONFIG_IP_PNP_RARP=y
# CONFIG_NET_IPIP is not set
CONFIG_NET_IPGRE_DEMUX=y
# CONFIG_NET_IPGRE is not set
CONFIG_ARPD=y
CONFIG_SYN_COOKIES=y
# CONFIG_INET_AH is not set
# CONFIG_INET_ESP is not set
CONFIG_INET_IPCOMP=y
CONFIG_INET_XFRM_TUNNEL=y
CONFIG_INET_TUNNEL=y
CONFIG_INET_XFRM_MODE_TRANSPORT=y
# CONFIG_INET_XFRM_MODE_TUNNEL is not set
CONFIG_INET_XFRM_MODE_BEET=y
# CONFIG_INET_LRO is not set
CONFIG_INET_DIAG=y
CONFIG_INET_TCP_DIAG=y
CONFIG_INET_UDP_DIAG=y
CONFIG_TCP_CONG_ADVANCED=y
CONFIG_TCP_CONG_BIC=y
# CONFIG_TCP_CONG_CUBIC is not set
# CONFIG_TCP_CONG_WESTWOOD is not set
CONFIG_TCP_CONG_HTCP=y
CONFIG_TCP_CONG_HSTCP=y
CONFIG_TCP_CONG_HYBLA=y
CONFIG_TCP_CONG_VEGAS=y
# CONFIG_TCP_CONG_SCALABLE is not set
CONFIG_TCP_CONG_LP=y
# CONFIG_TCP_CONG_VENO is not set
# CONFIG_TCP_CONG_YEAH is not set
# CONFIG_TCP_CONG_ILLINOIS is not set
CONFIG_DEFAULT_BIC=y
# CONFIG_DEFAULT_HTCP is not set
# CONFIG_DEFAULT_HYBLA is not set
# CONFIG_DEFAULT_VEGAS is not set
# CONFIG_DEFAULT_RENO is not set
CONFIG_DEFAULT_TCP_CONG="bic"
CONFIG_TCP_MD5SIG=y
# CONFIG_IPV6 is not set
CONFIG_NETWORK_SECMARK=y
# CONFIG_NETWORK_PHY_TIMESTAMPING is not set
# CONFIG_NETFILTER is not set
# CONFIG_IP_DCCP is not set
# CONFIG_IP_SCTP is not set
# CONFIG_RDS is not set
# CONFIG_TIPC is not set
# CONFIG_ATM is not set
# CONFIG_L2TP is not set
CONFIG_STP=y
CONFIG_GARP=y
# CONFIG_BRIDGE is not set
CONFIG_VLAN_8021Q=y
CONFIG_VLAN_8021Q_GVRP=y
# CONFIG_DECNET is not set
CONFIG_LLC=y
CONFIG_LLC2=y
# CONFIG_IPX is not set
# CONFIG_ATALK is not set
# CONFIG_X25 is not set
CONFIG_LAPB=y
CONFIG_WAN_ROUTER=y
# CONFIG_PHONET is not set
CONFIG_IEEE802154=y
CONFIG_MAC802154=y
# CONFIG_NET_SCHED is not set
CONFIG_DCB=y
CONFIG_DNS_RESOLVER=y
# CONFIG_BATMAN_ADV is not set
# CONFIG_OPENVSWITCH is not set
CONFIG_BQL=y

#
# Network testing
#
CONFIG_HAMRADIO=y

#
# Packet Radio protocols
#
# CONFIG_AX25 is not set
# CONFIG_CAN is not set
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
CONFIG_IRDA_CACHE_LAST_LSAP=y
CONFIG_IRDA_FAST_RR=y
CONFIG_IRDA_DEBUG=y

#
# Infrared-port device drivers
#

#
# SIR device drivers
#
# CONFIG_IRTTY_SIR is not set

#
# Dongle support
#

#
# FIR device drivers
#
CONFIG_NSC_FIR=y
# CONFIG_WINBOND_FIR is not set
# CONFIG_SMC_IRCC_FIR is not set
# CONFIG_ALI_FIR is not set
# CONFIG_VLSI_FIR is not set
# CONFIG_VIA_FIR is not set
CONFIG_BT=y
CONFIG_BT_RFCOMM=y
# CONFIG_BT_RFCOMM_TTY is not set
CONFIG_BT_BNEP=y
# CONFIG_BT_BNEP_MC_FILTER is not set
CONFIG_BT_BNEP_PROTO_FILTER=y
CONFIG_BT_HIDP=y

#
# Bluetooth device drivers
#
# CONFIG_BT_HCIBTSDIO is not set
CONFIG_BT_HCIUART=y
CONFIG_BT_HCIUART_H4=y
# CONFIG_BT_HCIUART_BCSP is not set
CONFIG_BT_HCIUART_ATH3K=y
CONFIG_BT_HCIUART_LL=y
# CONFIG_BT_HCIUART_3WIRE is not set
# CONFIG_BT_HCIVHCI is not set
# CONFIG_BT_MRVL is not set
CONFIG_AF_RXRPC=y
CONFIG_AF_RXRPC_DEBUG=y
# CONFIG_RXKAD is not set
# CONFIG_WIRELESS is not set
# CONFIG_WIMAX is not set
CONFIG_RFKILL=y
CONFIG_RFKILL_INPUT=y
# CONFIG_RFKILL_REGULATOR is not set
CONFIG_NET_9P=y
# CONFIG_NET_9P_VIRTIO is not set
CONFIG_NET_9P_DEBUG=y
CONFIG_CAIF=y
# CONFIG_CAIF_DEBUG is not set
CONFIG_CAIF_NETDEV=y
# CONFIG_CAIF_USB is not set
CONFIG_CEPH_LIB=y
# CONFIG_CEPH_LIB_PRETTYDEBUG is not set
CONFIG_CEPH_LIB_USE_DNS_RESOLVER=y
# CONFIG_NFC is not set
CONFIG_HAVE_BPF_JIT=y

#
# Device Drivers
#

#
# Generic Driver Options
#
CONFIG_UEVENT_HELPER_PATH=""
# CONFIG_DEVTMPFS is not set
# CONFIG_STANDALONE is not set
CONFIG_PREVENT_FIRMWARE_BUILD=y
CONFIG_FW_LOADER=y
CONFIG_FIRMWARE_IN_KERNEL=y
CONFIG_EXTRA_FIRMWARE=""
CONFIG_DEBUG_DRIVER=y
CONFIG_DEBUG_DEVRES=y
# CONFIG_SYS_HYPERVISOR is not set
# CONFIG_GENERIC_CPU_DEVICES is not set
CONFIG_REGMAP=y
CONFIG_REGMAP_I2C=y
CONFIG_REGMAP_IRQ=y
CONFIG_DMA_SHARED_BUFFER=y
CONFIG_CONNECTOR=y
CONFIG_PROC_EVENTS=y
# CONFIG_MTD is not set
# CONFIG_PARPORT is not set
CONFIG_PNP=y
CONFIG_PNP_DEBUG_MESSAGES=y

#
# Protocols
#
CONFIG_PNPACPI=y

#
# Misc devices
#
# CONFIG_SENSORS_LIS3LV02D is not set
CONFIG_AD525X_DPOT=y
# CONFIG_AD525X_DPOT_I2C is not set
# CONFIG_IBM_ASM is not set
# CONFIG_PHANTOM is not set
# CONFIG_INTEL_MID_PTI is not set
# CONFIG_SGI_IOC4 is not set
# CONFIG_TIFM_CORE is not set
# CONFIG_ICS932S401 is not set
CONFIG_ENCLOSURE_SERVICES=y
# CONFIG_HP_ILO is not set
CONFIG_APDS9802ALS=y
CONFIG_ISL29003=y
# CONFIG_ISL29020 is not set
# CONFIG_SENSORS_TSL2550 is not set
# CONFIG_SENSORS_BH1780 is not set
# CONFIG_SENSORS_BH1770 is not set
# CONFIG_SENSORS_APDS990X is not set
CONFIG_HMC6352=y
# CONFIG_DS1682 is not set
# CONFIG_VMWARE_BALLOON is not set
CONFIG_BMP085=y
CONFIG_BMP085_I2C=y
# CONFIG_PCH_PHUB is not set
CONFIG_USB_SWITCH_FSA9480=y
# CONFIG_C2PORT is not set

#
# EEPROM support
#
# CONFIG_EEPROM_AT24 is not set
CONFIG_EEPROM_LEGACY=y
# CONFIG_EEPROM_MAX6875 is not set
CONFIG_EEPROM_93CX6=y
# CONFIG_CB710_CORE is not set

#
# Texas Instruments shared transport line discipline
#
# CONFIG_SENSORS_LIS3_I2C is not set

#
# Altera FPGA firmware download module
#
CONFIG_ALTERA_STAPL=y
CONFIG_HAVE_IDE=y

#
# SCSI device support
#
CONFIG_SCSI_MOD=y
# CONFIG_SCSI_DMA is not set
# CONFIG_SCSI_NETLINK is not set
# CONFIG_FUSION is not set

#
# IEEE 1394 (FireWire) support
#
# CONFIG_FIREWIRE is not set
# CONFIG_FIREWIRE_NOSY is not set
# CONFIG_I2O is not set
CONFIG_MACINTOSH_DRIVERS=y
# CONFIG_NETDEVICES is not set
CONFIG_ISDN=y
# CONFIG_ISDN_I4L is not set
# CONFIG_ISDN_CAPI is not set
# CONFIG_ISDN_DRV_GIGASET is not set
CONFIG_MISDN=y
CONFIG_MISDN_DSP=y
CONFIG_MISDN_L1OIP=y

#
# mISDN hardware drivers
#
# CONFIG_MISDN_HFCPCI is not set
# CONFIG_MISDN_HFCMULTI is not set
# CONFIG_MISDN_AVMFRITZ is not set
# CONFIG_MISDN_SPEEDFAX is not set
# CONFIG_MISDN_INFINEON is not set
# CONFIG_MISDN_W6692 is not set
# CONFIG_MISDN_NETJET is not set

#
# Input device support
#
CONFIG_INPUT=y
CONFIG_INPUT_FF_MEMLESS=y
CONFIG_INPUT_POLLDEV=y
CONFIG_INPUT_SPARSEKMAP=y
CONFIG_INPUT_MATRIXKMAP=y

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
# CONFIG_KEYBOARD_ADP5588 is not set
# CONFIG_KEYBOARD_ADP5589 is not set
CONFIG_KEYBOARD_ATKBD=y
# CONFIG_KEYBOARD_QT1070 is not set
CONFIG_KEYBOARD_QT2160=y
# CONFIG_KEYBOARD_LKKBD is not set
CONFIG_KEYBOARD_TCA6416=y
CONFIG_KEYBOARD_TCA8418=y
CONFIG_KEYBOARD_LM8323=y
# CONFIG_KEYBOARD_LM8333 is not set
CONFIG_KEYBOARD_MAX7359=y
# CONFIG_KEYBOARD_MCS is not set
CONFIG_KEYBOARD_MPR121=y
CONFIG_KEYBOARD_NEWTON=y
# CONFIG_KEYBOARD_OPENCORES is not set
CONFIG_KEYBOARD_STOWAWAY=y
CONFIG_KEYBOARD_SUNKBD=y
CONFIG_KEYBOARD_STMPE=y
# CONFIG_KEYBOARD_OMAP4 is not set
CONFIG_KEYBOARD_XTKBD=y
# CONFIG_INPUT_MOUSE is not set
# CONFIG_INPUT_JOYSTICK is not set
# CONFIG_INPUT_TABLET is not set
CONFIG_INPUT_TOUCHSCREEN=y
CONFIG_TOUCHSCREEN_88PM860X=y
CONFIG_TOUCHSCREEN_AD7879=y
CONFIG_TOUCHSCREEN_AD7879_I2C=y
CONFIG_TOUCHSCREEN_ATMEL_MXT=y
CONFIG_TOUCHSCREEN_BU21013=y
CONFIG_TOUCHSCREEN_CYTTSP_CORE=y
# CONFIG_TOUCHSCREEN_CYTTSP_I2C is not set
CONFIG_TOUCHSCREEN_DA9034=y
# CONFIG_TOUCHSCREEN_DYNAPRO is not set
CONFIG_TOUCHSCREEN_HAMPSHIRE=y
# CONFIG_TOUCHSCREEN_EETI is not set
CONFIG_TOUCHSCREEN_EGALAX=y
CONFIG_TOUCHSCREEN_FUJITSU=y
# CONFIG_TOUCHSCREEN_ILI210X is not set
# CONFIG_TOUCHSCREEN_GUNZE is not set
CONFIG_TOUCHSCREEN_ELO=y
CONFIG_TOUCHSCREEN_WACOM_W8001=y
# CONFIG_TOUCHSCREEN_WACOM_I2C is not set
CONFIG_TOUCHSCREEN_MAX11801=y
# CONFIG_TOUCHSCREEN_MCS5000 is not set
# CONFIG_TOUCHSCREEN_MMS114 is not set
# CONFIG_TOUCHSCREEN_MTOUCH is not set
CONFIG_TOUCHSCREEN_INEXIO=y
CONFIG_TOUCHSCREEN_MK712=y
# CONFIG_TOUCHSCREEN_PENMOUNT is not set
# CONFIG_TOUCHSCREEN_EDT_FT5X06 is not set
# CONFIG_TOUCHSCREEN_TOUCHRIGHT is not set
CONFIG_TOUCHSCREEN_TOUCHWIN=y
# CONFIG_TOUCHSCREEN_PIXCIR is not set
# CONFIG_TOUCHSCREEN_WM831X is not set
# CONFIG_TOUCHSCREEN_USB_COMPOSITE is not set
CONFIG_TOUCHSCREEN_MC13783=y
# CONFIG_TOUCHSCREEN_TOUCHIT213 is not set
CONFIG_TOUCHSCREEN_TSC_SERIO=y
CONFIG_TOUCHSCREEN_TSC2007=y
# CONFIG_TOUCHSCREEN_ST1232 is not set
# CONFIG_TOUCHSCREEN_STMPE is not set
# CONFIG_TOUCHSCREEN_TPS6507X is not set
# CONFIG_INPUT_MISC is not set

#
# Hardware I/O ports
#
CONFIG_SERIO=y
CONFIG_SERIO_I8042=y
CONFIG_SERIO_SERPORT=y
CONFIG_SERIO_CT82C710=y
# CONFIG_SERIO_PCIPS2 is not set
CONFIG_SERIO_LIBPS2=y
CONFIG_SERIO_RAW=y
CONFIG_SERIO_ALTERA_PS2=y
# CONFIG_SERIO_PS2MULT is not set
CONFIG_GAMEPORT=y
# CONFIG_GAMEPORT_NS558 is not set
CONFIG_GAMEPORT_L4=y
# CONFIG_GAMEPORT_EMU10K1 is not set
# CONFIG_GAMEPORT_FM801 is not set

#
# Character devices
#
# CONFIG_VT is not set
CONFIG_UNIX98_PTYS=y
CONFIG_DEVPTS_MULTIPLE_INSTANCES=y
# CONFIG_LEGACY_PTYS is not set
# CONFIG_SERIAL_NONSTANDARD is not set
# CONFIG_NOZOMI is not set
CONFIG_N_GSM=y
CONFIG_TRACE_ROUTER=y
CONFIG_TRACE_SINK=y
# CONFIG_DEVKMEM is not set

#
# Serial drivers
#
CONFIG_SERIAL_8250=y
CONFIG_SERIAL_8250_CONSOLE=y
CONFIG_FIX_EARLYCON_MEM=y
CONFIG_SERIAL_8250_PCI=y
CONFIG_SERIAL_8250_PNP=y
CONFIG_SERIAL_8250_NR_UARTS=4
CONFIG_SERIAL_8250_RUNTIME_UARTS=4
# CONFIG_SERIAL_8250_EXTENDED is not set

#
# Non-8250 serial port support
#
# CONFIG_SERIAL_MFD_HSU is not set
CONFIG_SERIAL_CORE=y
CONFIG_SERIAL_CORE_CONSOLE=y
# CONFIG_SERIAL_JSM is not set
# CONFIG_SERIAL_TIMBERDALE is not set
# CONFIG_SERIAL_ALTERA_JTAGUART is not set
CONFIG_SERIAL_ALTERA_UART=y
CONFIG_SERIAL_ALTERA_UART_MAXPORTS=4
CONFIG_SERIAL_ALTERA_UART_BAUDRATE=115200
# CONFIG_SERIAL_ALTERA_UART_CONSOLE is not set
# CONFIG_SERIAL_PCH_UART is not set
# CONFIG_SERIAL_XILINX_PS_UART is not set
CONFIG_TTY_PRINTK=y
# CONFIG_VIRTIO_CONSOLE is not set
CONFIG_IPMI_HANDLER=y
# CONFIG_IPMI_PANIC_EVENT is not set
CONFIG_IPMI_DEVICE_INTERFACE=y
CONFIG_IPMI_SI=y
CONFIG_IPMI_WATCHDOG=y
CONFIG_IPMI_POWEROFF=y
# CONFIG_HW_RANDOM is not set
# CONFIG_NVRAM is not set
# CONFIG_R3964 is not set
# CONFIG_APPLICOM is not set
# CONFIG_MWAVE is not set
# CONFIG_HPET is not set
# CONFIG_HANGCHECK_TIMER is not set
# CONFIG_TCG_TPM is not set
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
# CONFIG_I2C_MUX_PCA9541 is not set
# CONFIG_I2C_MUX_PCA954x is not set
# CONFIG_I2C_HELPER_AUTO is not set
CONFIG_I2C_SMBUS=y

#
# I2C Algorithms
#
CONFIG_I2C_ALGOBIT=y
# CONFIG_I2C_ALGOPCF is not set
# CONFIG_I2C_ALGOPCA is not set

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
# CONFIG_I2C_DESIGNWARE_PCI is not set
# CONFIG_I2C_EG20T is not set
# CONFIG_I2C_INTEL_MID is not set
CONFIG_I2C_OCORES=y
# CONFIG_I2C_PCA_PLATFORM is not set
# CONFIG_I2C_PXA_PCI is not set
CONFIG_I2C_SIMTEC=y
# CONFIG_I2C_XILINX is not set

#
# External I2C/SMBus adapter drivers
#
CONFIG_I2C_PARPORT_LIGHT=y
CONFIG_I2C_TAOS_EVM=y

#
# Other I2C/SMBus bus drivers
#
# CONFIG_I2C_DEBUG_CORE is not set
CONFIG_I2C_DEBUG_ALGO=y
CONFIG_I2C_DEBUG_BUS=y
# CONFIG_SPI is not set
# CONFIG_HSI is not set

#
# PPS support
#
# CONFIG_PPS is not set

#
# PPS generators support
#

#
# PTP clock support
#

#
# Enable Device Drivers -> PPS to see the PTP clock options.
#
CONFIG_ARCH_WANT_OPTIONAL_GPIOLIB=y
# CONFIG_GPIOLIB is not set
CONFIG_W1=y
# CONFIG_W1_CON is not set

#
# 1-wire Bus Masters
#
# CONFIG_W1_MASTER_MATROX is not set
# CONFIG_W1_MASTER_DS2482 is not set
CONFIG_W1_MASTER_DS1WM=y

#
# 1-wire Slaves
#
CONFIG_W1_SLAVE_THERM=y
# CONFIG_W1_SLAVE_SMEM is not set
CONFIG_W1_SLAVE_DS2408=y
CONFIG_W1_SLAVE_DS2423=y
CONFIG_W1_SLAVE_DS2431=y
# CONFIG_W1_SLAVE_DS2433 is not set
# CONFIG_W1_SLAVE_DS2760 is not set
CONFIG_W1_SLAVE_DS2780=y
# CONFIG_W1_SLAVE_DS2781 is not set
# CONFIG_W1_SLAVE_DS28E04 is not set
CONFIG_W1_SLAVE_BQ27000=y
CONFIG_POWER_SUPPLY=y
CONFIG_POWER_SUPPLY_DEBUG=y
# CONFIG_PDA_POWER is not set
CONFIG_MAX8925_POWER=y
# CONFIG_WM831X_BACKUP is not set
CONFIG_WM831X_POWER=y
CONFIG_WM8350_POWER=y
CONFIG_TEST_POWER=y
CONFIG_BATTERY_DS2780=y
# CONFIG_BATTERY_DS2781 is not set
# CONFIG_BATTERY_DS2782 is not set
CONFIG_BATTERY_SBS=y
# CONFIG_BATTERY_BQ27x00 is not set
# CONFIG_BATTERY_DA9030 is not set
# CONFIG_BATTERY_MAX17040 is not set
# CONFIG_BATTERY_MAX17042 is not set
# CONFIG_CHARGER_MAX8903 is not set
# CONFIG_CHARGER_LP8727 is not set
CONFIG_CHARGER_MANAGER=y
# CONFIG_CHARGER_SMB347 is not set
# CONFIG_POWER_AVS is not set
CONFIG_HWMON=y
CONFIG_HWMON_VID=y
CONFIG_HWMON_DEBUG_CHIP=y

#
# Native drivers
#
# CONFIG_SENSORS_AD7414 is not set
CONFIG_SENSORS_AD7418=y
CONFIG_SENSORS_ADM1021=y
# CONFIG_SENSORS_ADM1025 is not set
# CONFIG_SENSORS_ADM1026 is not set
CONFIG_SENSORS_ADM1029=y
# CONFIG_SENSORS_ADM1031 is not set
# CONFIG_SENSORS_ADM9240 is not set
# CONFIG_SENSORS_ADT7411 is not set
# CONFIG_SENSORS_ADT7462 is not set
CONFIG_SENSORS_ADT7470=y
# CONFIG_SENSORS_ADT7475 is not set
# CONFIG_SENSORS_ASC7621 is not set
# CONFIG_SENSORS_K8TEMP is not set
# CONFIG_SENSORS_K10TEMP is not set
# CONFIG_SENSORS_FAM15H_POWER is not set
# CONFIG_SENSORS_ASB100 is not set
CONFIG_SENSORS_ATXP1=y
# CONFIG_SENSORS_DS620 is not set
# CONFIG_SENSORS_DS1621 is not set
# CONFIG_SENSORS_I5K_AMB is not set
CONFIG_SENSORS_F71805F=y
# CONFIG_SENSORS_F71882FG is not set
# CONFIG_SENSORS_F75375S is not set
# CONFIG_SENSORS_FSCHMD is not set
CONFIG_SENSORS_G760A=y
# CONFIG_SENSORS_GL518SM is not set
CONFIG_SENSORS_GL520SM=y
# CONFIG_SENSORS_HIH6130 is not set
# CONFIG_SENSORS_CORETEMP is not set
CONFIG_SENSORS_IBMAEM=y
# CONFIG_SENSORS_IBMPEX is not set
CONFIG_SENSORS_IT87=y
# CONFIG_SENSORS_JC42 is not set
CONFIG_SENSORS_LINEAGE=y
# CONFIG_SENSORS_LM63 is not set
# CONFIG_SENSORS_LM73 is not set
# CONFIG_SENSORS_LM75 is not set
CONFIG_SENSORS_LM77=y
CONFIG_SENSORS_LM78=y
# CONFIG_SENSORS_LM80 is not set
CONFIG_SENSORS_LM83=y
CONFIG_SENSORS_LM85=y
# CONFIG_SENSORS_LM87 is not set
# CONFIG_SENSORS_LM90 is not set
CONFIG_SENSORS_LM92=y
# CONFIG_SENSORS_LM93 is not set
CONFIG_SENSORS_LTC4151=y
# CONFIG_SENSORS_LTC4215 is not set
# CONFIG_SENSORS_LTC4245 is not set
CONFIG_SENSORS_LTC4261=y
# CONFIG_SENSORS_LM95241 is not set
# CONFIG_SENSORS_LM95245 is not set
# CONFIG_SENSORS_MAX16065 is not set
# CONFIG_SENSORS_MAX1619 is not set
CONFIG_SENSORS_MAX1668=y
CONFIG_SENSORS_MAX6639=y
CONFIG_SENSORS_MAX6642=y
# CONFIG_SENSORS_MAX6650 is not set
# CONFIG_SENSORS_MCP3021 is not set
CONFIG_SENSORS_NTC_THERMISTOR=y
CONFIG_SENSORS_PC87360=y
# CONFIG_SENSORS_PC87427 is not set
CONFIG_SENSORS_PCF8591=y
# CONFIG_PMBUS is not set
# CONFIG_SENSORS_SHT21 is not set
# CONFIG_SENSORS_SIS5595 is not set
# CONFIG_SENSORS_SMM665 is not set
# CONFIG_SENSORS_DME1737 is not set
# CONFIG_SENSORS_EMC1403 is not set
CONFIG_SENSORS_EMC2103=y
CONFIG_SENSORS_EMC6W201=y
CONFIG_SENSORS_SMSC47M1=y
CONFIG_SENSORS_SMSC47M192=y
CONFIG_SENSORS_SMSC47B397=y
# CONFIG_SENSORS_SCH56XX_COMMON is not set
# CONFIG_SENSORS_ADS1015 is not set
CONFIG_SENSORS_ADS7828=y
# CONFIG_SENSORS_AMC6821 is not set
CONFIG_SENSORS_INA2XX=y
CONFIG_SENSORS_THMC50=y
# CONFIG_SENSORS_TMP102 is not set
# CONFIG_SENSORS_TMP401 is not set
CONFIG_SENSORS_TMP421=y
# CONFIG_SENSORS_VIA_CPUTEMP is not set
# CONFIG_SENSORS_VIA686A is not set
CONFIG_SENSORS_VT1211=y
# CONFIG_SENSORS_VT8231 is not set
CONFIG_SENSORS_W83781D=y
# CONFIG_SENSORS_W83791D is not set
CONFIG_SENSORS_W83792D=y
# CONFIG_SENSORS_W83793 is not set
# CONFIG_SENSORS_W83795 is not set
# CONFIG_SENSORS_W83L785TS is not set
# CONFIG_SENSORS_W83L786NG is not set
# CONFIG_SENSORS_W83627HF is not set
# CONFIG_SENSORS_W83627EHF is not set
CONFIG_SENSORS_WM831X=y
# CONFIG_SENSORS_WM8350 is not set
CONFIG_SENSORS_APPLESMC=y
CONFIG_SENSORS_MC13783_ADC=y

#
# ACPI drivers
#
# CONFIG_SENSORS_ACPI_POWER is not set
# CONFIG_SENSORS_ATK0110 is not set
CONFIG_THERMAL=y
CONFIG_THERMAL_HWMON=y
# CONFIG_WATCHDOG is not set
CONFIG_SSB_POSSIBLE=y

#
# Sonics Silicon Backplane
#
# CONFIG_SSB is not set
CONFIG_BCMA_POSSIBLE=y

#
# Broadcom specific AMBA
#
CONFIG_BCMA=y
CONFIG_BCMA_HOST_PCI_POSSIBLE=y
# CONFIG_BCMA_HOST_PCI is not set
# CONFIG_BCMA_DRIVER_GMAC_CMN is not set
# CONFIG_BCMA_DEBUG is not set

#
# Multifunction device drivers
#
CONFIG_MFD_CORE=y
CONFIG_MFD_88PM860X=y
# CONFIG_MFD_88PM800 is not set
# CONFIG_MFD_88PM805 is not set
# CONFIG_MFD_SM501 is not set
# CONFIG_HTC_PASIC3 is not set
CONFIG_MFD_LM3533=y
# CONFIG_TPS6105X is not set
# CONFIG_TPS6507X is not set
CONFIG_MFD_TPS65217=y
# CONFIG_MFD_TPS6586X is not set
# CONFIG_TWL4030_CORE is not set
CONFIG_TWL6040_CORE=y
CONFIG_MFD_STMPE=y

#
# STMPE Interface Drivers
#
# CONFIG_STMPE_I2C is not set
# CONFIG_MFD_TC3589X is not set
# CONFIG_MFD_TMIO is not set
CONFIG_PMIC_DA903X=y
# CONFIG_MFD_DA9052_I2C is not set
# CONFIG_PMIC_ADP5520 is not set
# CONFIG_MFD_MAX77686 is not set
CONFIG_MFD_MAX77693=y
CONFIG_MFD_MAX8925=y
# CONFIG_MFD_MAX8997 is not set
# CONFIG_MFD_MAX8998 is not set
# CONFIG_MFD_SEC_CORE is not set
# CONFIG_MFD_ARIZONA_I2C is not set
# CONFIG_MFD_WM8400 is not set
CONFIG_MFD_WM831X=y
CONFIG_MFD_WM831X_I2C=y
CONFIG_MFD_WM8350=y
CONFIG_MFD_WM8350_I2C=y
# CONFIG_MFD_WM8994 is not set
# CONFIG_MFD_PCF50633 is not set
CONFIG_MFD_MC13783=y
CONFIG_MFD_MC13XXX=y
CONFIG_MFD_MC13XXX_I2C=y
CONFIG_ABX500_CORE=y
CONFIG_AB3100_CORE=y
CONFIG_AB3100_OTP=y
# CONFIG_MFD_CS5535 is not set
# CONFIG_LPC_SCH is not set
# CONFIG_LPC_ICH is not set
# CONFIG_MFD_RDC321X is not set
# CONFIG_MFD_JANZ_CMODIO is not set
# CONFIG_MFD_VX855 is not set
CONFIG_MFD_WL1273_CORE=y
# CONFIG_MFD_TPS65090 is not set
# CONFIG_MFD_RC5T583 is not set
CONFIG_MFD_PALMAS=y
CONFIG_REGULATOR=y
# CONFIG_REGULATOR_DEBUG is not set
# CONFIG_REGULATOR_DUMMY is not set
CONFIG_REGULATOR_FIXED_VOLTAGE=y
CONFIG_REGULATOR_VIRTUAL_CONSUMER=y
# CONFIG_REGULATOR_USERSPACE_CONSUMER is not set
# CONFIG_REGULATOR_AD5398 is not set
CONFIG_REGULATOR_DA903X=y
# CONFIG_REGULATOR_MC13783 is not set
# CONFIG_REGULATOR_MC13892 is not set
# CONFIG_REGULATOR_ISL6271A is not set
CONFIG_REGULATOR_88PM8607=y
CONFIG_REGULATOR_MAX1586=y
# CONFIG_REGULATOR_MAX8649 is not set
CONFIG_REGULATOR_MAX8660=y
# CONFIG_REGULATOR_MAX8925 is not set
CONFIG_REGULATOR_MAX8952=y
CONFIG_REGULATOR_LP3971=y
# CONFIG_REGULATOR_LP3972 is not set
# CONFIG_REGULATOR_LP872X is not set
# CONFIG_REGULATOR_AB3100 is not set
CONFIG_REGULATOR_PALMAS=y
# CONFIG_REGULATOR_TPS62360 is not set
# CONFIG_REGULATOR_TPS65023 is not set
CONFIG_REGULATOR_TPS6507X=y
# CONFIG_REGULATOR_TPS65217 is not set
# CONFIG_REGULATOR_WM831X is not set
CONFIG_REGULATOR_WM8350=y
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
# CONFIG_DRM_VMWGFX is not set
# CONFIG_DRM_GMA500 is not set
# CONFIG_DRM_UDL is not set
# CONFIG_DRM_AST is not set
# CONFIG_DRM_MGAG200 is not set
# CONFIG_DRM_CIRRUS_QEMU is not set
# CONFIG_STUB_POULSBO is not set
# CONFIG_VGASTATE is not set
CONFIG_VIDEO_OUTPUT_CONTROL=y
CONFIG_FB=y
# CONFIG_FIRMWARE_EDID is not set
# CONFIG_FB_DDC is not set
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
# CONFIG_FB_SVGALIB is not set
# CONFIG_FB_MACMODES is not set
# CONFIG_FB_BACKLIGHT is not set
CONFIG_FB_MODE_HELPERS=y
# CONFIG_FB_TILEBLITTING is not set

#
# Frame buffer hardware drivers
#
# CONFIG_FB_CIRRUS is not set
# CONFIG_FB_PM2 is not set
# CONFIG_FB_CYBER2000 is not set
# CONFIG_FB_ARC is not set
# CONFIG_FB_ASILIANT is not set
# CONFIG_FB_IMSTT is not set
# CONFIG_FB_VGA16 is not set
# CONFIG_FB_UVESA is not set
CONFIG_FB_VESA=y
CONFIG_FB_N411=y
# CONFIG_FB_HGA is not set
# CONFIG_FB_S1D13XXX is not set
# CONFIG_FB_NVIDIA is not set
# CONFIG_FB_RIVA is not set
# CONFIG_FB_I740 is not set
# CONFIG_FB_LE80578 is not set
# CONFIG_FB_MATROX is not set
# CONFIG_FB_RADEON is not set
# CONFIG_FB_ATY128 is not set
# CONFIG_FB_ATY is not set
# CONFIG_FB_S3 is not set
# CONFIG_FB_SAVAGE is not set
# CONFIG_FB_SIS is not set
# CONFIG_FB_VIA is not set
# CONFIG_FB_NEOMAGIC is not set
# CONFIG_FB_KYRO is not set
# CONFIG_FB_3DFX is not set
# CONFIG_FB_VOODOO1 is not set
# CONFIG_FB_VT8623 is not set
# CONFIG_FB_TRIDENT is not set
# CONFIG_FB_ARK is not set
# CONFIG_FB_PM3 is not set
# CONFIG_FB_CARMINE is not set
# CONFIG_FB_GEODE is not set
CONFIG_FB_TMIO=y
CONFIG_FB_TMIO_ACCELL=y
CONFIG_FB_VIRTUAL=y
CONFIG_FB_METRONOME=y
# CONFIG_FB_MB862XX is not set
CONFIG_FB_BROADSHEET=y
# CONFIG_FB_AUO_K190X is not set
# CONFIG_EXYNOS_VIDEO is not set
# CONFIG_BACKLIGHT_LCD_SUPPORT is not set
CONFIG_LOGO=y
# CONFIG_LOGO_LINUX_MONO is not set
CONFIG_LOGO_LINUX_VGA16=y
CONFIG_LOGO_LINUX_CLUT224=y
CONFIG_SOUND=y
CONFIG_SOUND_OSS_CORE=y
CONFIG_SOUND_OSS_CORE_PRECLAIM=y
CONFIG_SND=y
CONFIG_SND_TIMER=y
CONFIG_SND_PCM=y
CONFIG_SND_RAWMIDI=y
CONFIG_SND_JACK=y
# CONFIG_SND_SEQUENCER is not set
CONFIG_SND_OSSEMUL=y
CONFIG_SND_MIXER_OSS=y
CONFIG_SND_PCM_OSS=y
# CONFIG_SND_PCM_OSS_PLUGINS is not set
# CONFIG_SND_DYNAMIC_MINORS is not set
# CONFIG_SND_SUPPORT_OLD_API is not set
# CONFIG_SND_VERBOSE_PRINTK is not set
CONFIG_SND_DEBUG=y
# CONFIG_SND_DEBUG_VERBOSE is not set
CONFIG_SND_DMA_SGBUF=y
# CONFIG_SND_RAWMIDI_SEQ is not set
# CONFIG_SND_OPL3_LIB_SEQ is not set
# CONFIG_SND_OPL4_LIB_SEQ is not set
# CONFIG_SND_SBAWE_SEQ is not set
# CONFIG_SND_EMU10K1_SEQ is not set
CONFIG_SND_MPU401_UART=y
CONFIG_SND_DRIVERS=y
# CONFIG_SND_DUMMY is not set
# CONFIG_SND_ALOOP is not set
CONFIG_SND_MTPAV=y
# CONFIG_SND_SERIAL_U16550 is not set
CONFIG_SND_MPU401=y
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
# CONFIG_SND_SONICVIBES is not set
# CONFIG_SND_TRIDENT is not set
# CONFIG_SND_VIA82XX is not set
# CONFIG_SND_VIA82XX_MODEM is not set
# CONFIG_SND_VIRTUOSO is not set
# CONFIG_SND_VX222 is not set
# CONFIG_SND_YMFPCI is not set
CONFIG_SND_SOC=y
CONFIG_SND_SOC_I2C_AND_SPI=y
CONFIG_SND_SOC_ALL_CODECS=y
CONFIG_SND_SOC_88PM860X=y
CONFIG_SND_SOC_WM_HUBS=y
CONFIG_SND_SOC_AB8500_CODEC=y
CONFIG_SND_SOC_AD193X=y
CONFIG_SND_SOC_AD73311=y
CONFIG_SND_SOC_ADAU1373=y
CONFIG_SND_SOC_ADAV80X=y
CONFIG_SND_SOC_ADS117X=y
CONFIG_SND_SOC_AK4535=y
CONFIG_SND_SOC_AK4641=y
CONFIG_SND_SOC_AK4642=y
CONFIG_SND_SOC_AK4671=y
CONFIG_SND_SOC_ALC5623=y
CONFIG_SND_SOC_ALC5632=y
CONFIG_SND_SOC_CS42L51=y
CONFIG_SND_SOC_CS42L52=y
CONFIG_SND_SOC_CS42L73=y
CONFIG_SND_SOC_CS4270=y
CONFIG_SND_SOC_CS4271=y
CONFIG_SND_SOC_CX20442=y
CONFIG_SND_SOC_JZ4740_CODEC=y
CONFIG_SND_SOC_L3=y
CONFIG_SND_SOC_DA7210=y
CONFIG_SND_SOC_DA732X=y
CONFIG_SND_SOC_DFBMCS320=y
CONFIG_SND_SOC_ISABELLE=y
CONFIG_SND_SOC_LM49453=y
CONFIG_SND_SOC_MAX98088=y
CONFIG_SND_SOC_MAX98095=y
CONFIG_SND_SOC_MAX9850=y
CONFIG_SND_SOC_PCM3008=y
CONFIG_SND_SOC_RT5631=y
CONFIG_SND_SOC_SGTL5000=y
CONFIG_SND_SOC_SPDIF=y
CONFIG_SND_SOC_SSM2602=y
CONFIG_SND_SOC_STA32X=y
CONFIG_SND_SOC_STA529=y
CONFIG_SND_SOC_TLV320AIC23=y
CONFIG_SND_SOC_TLV320AIC32X4=y
CONFIG_SND_SOC_TLV320AIC3X=y
CONFIG_SND_SOC_TLV320DAC33=y
CONFIG_SND_SOC_TWL6040=y
CONFIG_SND_SOC_UDA134X=y
CONFIG_SND_SOC_UDA1380=y
CONFIG_SND_SOC_WL1273=y
CONFIG_SND_SOC_WM1250_EV1=y
CONFIG_SND_SOC_WM2000=y
CONFIG_SND_SOC_WM2200=y
CONFIG_SND_SOC_WM5100=y
CONFIG_SND_SOC_WM8350=y
CONFIG_SND_SOC_WM8510=y
CONFIG_SND_SOC_WM8523=y
CONFIG_SND_SOC_WM8580=y
CONFIG_SND_SOC_WM8711=y
CONFIG_SND_SOC_WM8727=y
CONFIG_SND_SOC_WM8728=y
CONFIG_SND_SOC_WM8731=y
CONFIG_SND_SOC_WM8737=y
CONFIG_SND_SOC_WM8741=y
CONFIG_SND_SOC_WM8750=y
CONFIG_SND_SOC_WM8753=y
CONFIG_SND_SOC_WM8776=y
CONFIG_SND_SOC_WM8782=y
CONFIG_SND_SOC_WM8804=y
CONFIG_SND_SOC_WM8900=y
CONFIG_SND_SOC_WM8903=y
CONFIG_SND_SOC_WM8904=y
CONFIG_SND_SOC_WM8940=y
CONFIG_SND_SOC_WM8955=y
CONFIG_SND_SOC_WM8960=y
CONFIG_SND_SOC_WM8961=y
CONFIG_SND_SOC_WM8962=y
CONFIG_SND_SOC_WM8971=y
CONFIG_SND_SOC_WM8974=y
CONFIG_SND_SOC_WM8978=y
CONFIG_SND_SOC_WM8983=y
CONFIG_SND_SOC_WM8985=y
CONFIG_SND_SOC_WM8988=y
CONFIG_SND_SOC_WM8990=y
CONFIG_SND_SOC_WM8991=y
CONFIG_SND_SOC_WM8993=y
CONFIG_SND_SOC_WM8995=y
CONFIG_SND_SOC_WM8996=y
CONFIG_SND_SOC_WM9081=y
CONFIG_SND_SOC_WM9090=y
CONFIG_SND_SOC_LM4857=y
CONFIG_SND_SOC_MAX9768=y
CONFIG_SND_SOC_MAX9877=y
CONFIG_SND_SOC_MC13783=y
CONFIG_SND_SOC_ML26124=y
CONFIG_SND_SOC_TPA6130A2=y
CONFIG_SND_SIMPLE_CARD=y
# CONFIG_SOUND_PRIME is not set

#
# HID support
#
CONFIG_HID=y
CONFIG_HID_BATTERY_STRENGTH=y
CONFIG_HIDRAW=y
# CONFIG_UHID is not set
# CONFIG_HID_GENERIC is not set

#
# Special HID drivers
#
# CONFIG_HID_APPLE is not set
# CONFIG_HID_ELECOM is not set
# CONFIG_HID_MAGICMOUSE is not set
CONFIG_HID_TIVO=y
# CONFIG_HID_WACOM is not set
CONFIG_HID_WIIMOTE=y
CONFIG_HID_WIIMOTE_EXT=y
CONFIG_USB_ARCH_HAS_OHCI=y
CONFIG_USB_ARCH_HAS_EHCI=y
CONFIG_USB_ARCH_HAS_XHCI=y
CONFIG_USB_SUPPORT=y
CONFIG_USB_ARCH_HAS_HCD=y
# CONFIG_USB is not set
# CONFIG_USB_OTG_WHITELIST is not set
# CONFIG_USB_OTG_BLACKLIST_HUB is not set
# CONFIG_USB_HCD_BCMA is not set

#
# NOTE: USB_STORAGE depends on SCSI but BLK_DEV_SD may
#
# CONFIG_USB_GADGET is not set

#
# OTG and related infrastructure
#
# CONFIG_UWB is not set
CONFIG_MMC=y
# CONFIG_MMC_DEBUG is not set
CONFIG_MMC_UNSAFE_RESUME=y
# CONFIG_MMC_CLKGATE is not set

#
# MMC/SD/SDIO Card Drivers
#
# CONFIG_SDIO_UART is not set
# CONFIG_MMC_TEST is not set

#
# MMC/SD/SDIO Host Controller Drivers
#
CONFIG_MMC_SDHCI=y
# CONFIG_MMC_SDHCI_PCI is not set
# CONFIG_MMC_SDHCI_PLTFM is not set
CONFIG_MMC_WBSD=y
# CONFIG_MMC_TIFM_SD is not set
# CONFIG_MMC_CB710 is not set
# CONFIG_MMC_VIA_SDMMC is not set
CONFIG_MEMSTICK=y
CONFIG_MEMSTICK_DEBUG=y

#
# MemoryStick drivers
#
CONFIG_MEMSTICK_UNSAFE_RESUME=y

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
CONFIG_LEDS_88PM860X=y
CONFIG_LEDS_LM3530=y
CONFIG_LEDS_LM3533=y
# CONFIG_LEDS_PCA9532 is not set
CONFIG_LEDS_LP3944=y
CONFIG_LEDS_LP5521=y
CONFIG_LEDS_LP5523=y
CONFIG_LEDS_PCA955X=y
CONFIG_LEDS_PCA9633=y
CONFIG_LEDS_WM831X_STATUS=y
CONFIG_LEDS_WM8350=y
CONFIG_LEDS_DA903X=y
# CONFIG_LEDS_REGULATOR is not set
CONFIG_LEDS_BD2802=y
CONFIG_LEDS_MC13783=y
CONFIG_LEDS_TCA6507=y
# CONFIG_LEDS_LM3556 is not set
CONFIG_LEDS_OT200=y
# CONFIG_LEDS_BLINKM is not set
# CONFIG_LEDS_TRIGGERS is not set

#
# LED Triggers
#
CONFIG_ACCESSIBILITY=y
# CONFIG_INFINIBAND is not set
CONFIG_EDAC=y

#
# Reporting subsystems
#
CONFIG_EDAC_LEGACY_SYSFS=y
CONFIG_EDAC_DEBUG=y
# CONFIG_EDAC_MM_EDAC is not set
CONFIG_RTC_LIB=y
CONFIG_RTC_CLASS=y
CONFIG_RTC_HCTOSYS=y
CONFIG_RTC_HCTOSYS_DEVICE="rtc0"
CONFIG_RTC_DEBUG=y

#
# RTC interfaces
#
# CONFIG_RTC_INTF_SYSFS is not set
# CONFIG_RTC_INTF_DEV is not set
# CONFIG_RTC_DRV_TEST is not set

#
# I2C RTC drivers
#
# CONFIG_RTC_DRV_88PM860X is not set
CONFIG_RTC_DRV_DS1307=y
# CONFIG_RTC_DRV_DS1374 is not set
CONFIG_RTC_DRV_DS1672=y
# CONFIG_RTC_DRV_DS3232 is not set
# CONFIG_RTC_DRV_MAX6900 is not set
# CONFIG_RTC_DRV_MAX8925 is not set
# CONFIG_RTC_DRV_RS5C372 is not set
# CONFIG_RTC_DRV_ISL1208 is not set
CONFIG_RTC_DRV_ISL12022=y
CONFIG_RTC_DRV_X1205=y
CONFIG_RTC_DRV_PCF8563=y
CONFIG_RTC_DRV_PCF8583=y
CONFIG_RTC_DRV_M41T80=y
CONFIG_RTC_DRV_M41T80_WDT=y
# CONFIG_RTC_DRV_BQ32K is not set
CONFIG_RTC_DRV_S35390A=y
CONFIG_RTC_DRV_FM3130=y
CONFIG_RTC_DRV_RX8581=y
# CONFIG_RTC_DRV_RX8025 is not set
# CONFIG_RTC_DRV_EM3027 is not set
# CONFIG_RTC_DRV_RV3029C2 is not set

#
# SPI RTC drivers
#

#
# Platform RTC drivers
#
CONFIG_RTC_DRV_CMOS=y
CONFIG_RTC_DRV_DS1286=y
CONFIG_RTC_DRV_DS1511=y
# CONFIG_RTC_DRV_DS1553 is not set
CONFIG_RTC_DRV_DS1742=y
CONFIG_RTC_DRV_STK17TA8=y
# CONFIG_RTC_DRV_M48T86 is not set
# CONFIG_RTC_DRV_M48T35 is not set
# CONFIG_RTC_DRV_M48T59 is not set
CONFIG_RTC_DRV_MSM6242=y
CONFIG_RTC_DRV_BQ4802=y
# CONFIG_RTC_DRV_RP5C01 is not set
# CONFIG_RTC_DRV_V3020 is not set
CONFIG_RTC_DRV_WM831X=y
CONFIG_RTC_DRV_WM8350=y
CONFIG_RTC_DRV_AB3100=y

#
# on-CPU RTC drivers
#
CONFIG_RTC_DRV_MC13XXX=y
CONFIG_DMADEVICES=y
# CONFIG_DMADEVICES_DEBUG is not set

#
# DMA Devices
#
# CONFIG_INTEL_MID_DMAC is not set
# CONFIG_INTEL_IOATDMA is not set
# CONFIG_TIMB_DMA is not set
# CONFIG_PCH_DMA is not set
CONFIG_AUXDISPLAY=y
CONFIG_UIO=y
# CONFIG_UIO_CIF is not set
CONFIG_UIO_PDRV=y
# CONFIG_UIO_PDRV_GENIRQ is not set
# CONFIG_UIO_AEC is not set
# CONFIG_UIO_SERCOS3 is not set
# CONFIG_UIO_PCI_GENERIC is not set
# CONFIG_UIO_NETX is not set
CONFIG_VIRTIO=y
CONFIG_VIRTIO_RING=y

#
# Virtio drivers
#
# CONFIG_VIRTIO_PCI is not set
CONFIG_VIRTIO_BALLOON=y
# CONFIG_VIRTIO_MMIO is not set

#
# Microsoft Hyper-V guest support
#
# CONFIG_HYPERV is not set
# CONFIG_STAGING is not set
# CONFIG_X86_PLATFORM_DEVICES is not set

#
# Hardware Spinlock drivers
#
CONFIG_CLKEVT_I8253=y
CONFIG_I8253_LOCK=y
CONFIG_CLKBLD_I8253=y
# CONFIG_IOMMU_SUPPORT is not set

#
# Remoteproc drivers (EXPERIMENTAL)
#

#
# Rpmsg drivers (EXPERIMENTAL)
#
# CONFIG_VIRT_DRIVERS is not set
CONFIG_PM_DEVFREQ=y

#
# DEVFREQ Governors
#
# CONFIG_DEVFREQ_GOV_SIMPLE_ONDEMAND is not set
CONFIG_DEVFREQ_GOV_PERFORMANCE=y
# CONFIG_DEVFREQ_GOV_POWERSAVE is not set
# CONFIG_DEVFREQ_GOV_USERSPACE is not set

#
# DEVFREQ Drivers
#
CONFIG_EXTCON=y

#
# Extcon Device Drivers
#
# CONFIG_EXTCON_MAX77693 is not set
# CONFIG_MEMORY is not set
CONFIG_IIO=y
# CONFIG_IIO_BUFFER is not set
# CONFIG_IIO_TRIGGER is not set

#
# Analog to digital converters
#

#
# Amplifiers
#

#
# Light sensors
#
# CONFIG_ADJD_S311 is not set
# CONFIG_SENSORS_LM3533 is not set
# CONFIG_VCNL4000 is not set

#
# Frequency Synthesizers DDS/PLL
#

#
# Clock Generator/Distribution
#

#
# Phase-Locked Loop (PLL) frequency synthesizers
#

#
# Digital to analog converters
#
# CONFIG_AD5064 is not set
# CONFIG_AD5380 is not set
# CONFIG_MAX517 is not set
# CONFIG_MCP4725 is not set
# CONFIG_VME_BUS is not set
# CONFIG_PWM is not set

#
# Firmware Drivers
#
CONFIG_EDD=y
# CONFIG_EDD_OFF is not set
# CONFIG_FIRMWARE_MEMMAP is not set
CONFIG_DELL_RBU=y
# CONFIG_DCDBAS is not set
# CONFIG_ISCSI_IBFT_FIND is not set
CONFIG_GOOGLE_FIRMWARE=y

#
# Google Firmware Drivers
#

#
# File systems
#
CONFIG_DCACHE_WORD_ACCESS=y
# CONFIG_FS_POSIX_ACL is not set
CONFIG_FILE_LOCKING=y
CONFIG_FSNOTIFY=y
# CONFIG_DNOTIFY is not set
# CONFIG_INOTIFY_USER is not set
CONFIG_FANOTIFY=y
# CONFIG_QUOTA is not set
# CONFIG_QUOTACTL is not set
# CONFIG_AUTOFS4_FS is not set
CONFIG_FUSE_FS=y
# CONFIG_CUSE is not set

#
# Caches
#
CONFIG_FSCACHE=y
# CONFIG_FSCACHE_DEBUG is not set

#
# Pseudo filesystems
#
# CONFIG_PROC_FS is not set
CONFIG_SYSFS=y
CONFIG_HUGETLBFS=y
CONFIG_HUGETLB_PAGE=y
# CONFIG_CONFIGFS_FS is not set
CONFIG_MISC_FILESYSTEMS=y
# CONFIG_ECRYPT_FS is not set
# CONFIG_PSTORE is not set
CONFIG_NETWORK_FILESYSTEMS=y
CONFIG_NFS_FS=y
# CONFIG_NFS_V2 is not set
# CONFIG_NFS_V3 is not set
CONFIG_NFS_V4=y
# CONFIG_NFS_SWAP is not set
CONFIG_NFS_V4_1=y
CONFIG_PNFS_FILE_LAYOUT=y
CONFIG_NFS_V4_1_IMPLEMENTATION_ID_DOMAIN="kernel.org"
# CONFIG_ROOT_NFS is not set
# CONFIG_NFS_FSCACHE is not set
CONFIG_NFS_USE_LEGACY_DNS=y
# CONFIG_NFSD is not set
CONFIG_LOCKD=y
CONFIG_NFS_COMMON=y
CONFIG_SUNRPC=y
CONFIG_SUNRPC_GSS=y
CONFIG_SUNRPC_BACKCHANNEL=y
CONFIG_CEPH_FS=y
# CONFIG_CIFS is not set
CONFIG_NCP_FS=y
# CONFIG_NCPFS_PACKET_SIGNING is not set
CONFIG_NCPFS_IOCTL_LOCKING=y
# CONFIG_NCPFS_STRONG is not set
CONFIG_NCPFS_NFS_NS=y
CONFIG_NCPFS_OS2_NS=y
# CONFIG_NCPFS_SMALLDOS is not set
# CONFIG_NCPFS_NLS is not set
# CONFIG_NCPFS_EXTRAS is not set
CONFIG_CODA_FS=y
CONFIG_AFS_FS=y
CONFIG_AFS_DEBUG=y
CONFIG_AFS_FSCACHE=y
# CONFIG_9P_FS is not set
CONFIG_NLS=y
CONFIG_NLS_DEFAULT="iso8859-1"
# CONFIG_NLS_CODEPAGE_437 is not set
# CONFIG_NLS_CODEPAGE_737 is not set
# CONFIG_NLS_CODEPAGE_775 is not set
# CONFIG_NLS_CODEPAGE_850 is not set
# CONFIG_NLS_CODEPAGE_852 is not set
# CONFIG_NLS_CODEPAGE_855 is not set
# CONFIG_NLS_CODEPAGE_857 is not set
# CONFIG_NLS_CODEPAGE_860 is not set
# CONFIG_NLS_CODEPAGE_861 is not set
# CONFIG_NLS_CODEPAGE_862 is not set
# CONFIG_NLS_CODEPAGE_863 is not set
# CONFIG_NLS_CODEPAGE_864 is not set
# CONFIG_NLS_CODEPAGE_865 is not set
# CONFIG_NLS_CODEPAGE_866 is not set
# CONFIG_NLS_CODEPAGE_869 is not set
# CONFIG_NLS_CODEPAGE_936 is not set
# CONFIG_NLS_CODEPAGE_950 is not set
# CONFIG_NLS_CODEPAGE_932 is not set
# CONFIG_NLS_CODEPAGE_949 is not set
# CONFIG_NLS_CODEPAGE_874 is not set
# CONFIG_NLS_ISO8859_8 is not set
# CONFIG_NLS_CODEPAGE_1250 is not set
# CONFIG_NLS_CODEPAGE_1251 is not set
# CONFIG_NLS_ASCII is not set
# CONFIG_NLS_ISO8859_1 is not set
# CONFIG_NLS_ISO8859_2 is not set
# CONFIG_NLS_ISO8859_3 is not set
# CONFIG_NLS_ISO8859_4 is not set
# CONFIG_NLS_ISO8859_5 is not set
# CONFIG_NLS_ISO8859_6 is not set
# CONFIG_NLS_ISO8859_7 is not set
# CONFIG_NLS_ISO8859_9 is not set
# CONFIG_NLS_ISO8859_13 is not set
# CONFIG_NLS_ISO8859_14 is not set
# CONFIG_NLS_ISO8859_15 is not set
# CONFIG_NLS_KOI8_R is not set
# CONFIG_NLS_KOI8_U is not set
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
# CONFIG_NLS_UTF8 is not set

#
# Kernel hacking
#
CONFIG_TRACE_IRQFLAGS_SUPPORT=y
CONFIG_PRINTK_TIME=y
CONFIG_DEFAULT_MESSAGE_LOGLEVEL=4
CONFIG_ENABLE_WARN_DEPRECATED=y
# CONFIG_ENABLE_MUST_CHECK is not set
CONFIG_FRAME_WARN=2048
CONFIG_MAGIC_SYSRQ=y
# CONFIG_STRIP_ASM_SYMS is not set
# CONFIG_READABLE_ASM is not set
CONFIG_UNUSED_SYMBOLS=y
CONFIG_DEBUG_FS=y
CONFIG_HEADERS_CHECK=y
CONFIG_DEBUG_SECTION_MISMATCH=y
CONFIG_DEBUG_KERNEL=y
# CONFIG_DEBUG_SHIRQ is not set
CONFIG_LOCKUP_DETECTOR=y
CONFIG_HARDLOCKUP_DETECTOR=y
CONFIG_BOOTPARAM_HARDLOCKUP_PANIC=y
CONFIG_BOOTPARAM_HARDLOCKUP_PANIC_VALUE=1
# CONFIG_BOOTPARAM_SOFTLOCKUP_PANIC is not set
CONFIG_BOOTPARAM_SOFTLOCKUP_PANIC_VALUE=0
# CONFIG_PANIC_ON_OOPS is not set
CONFIG_PANIC_ON_OOPS_VALUE=0
CONFIG_DETECT_HUNG_TASK=y
CONFIG_DEFAULT_HUNG_TASK_TIMEOUT=120
# CONFIG_BOOTPARAM_HUNG_TASK_PANIC is not set
CONFIG_BOOTPARAM_HUNG_TASK_PANIC_VALUE=0
# CONFIG_DEBUG_OBJECTS is not set
# CONFIG_SLUB_DEBUG_ON is not set
CONFIG_SLUB_STATS=y
# CONFIG_DEBUG_KMEMLEAK is not set
# CONFIG_DEBUG_RT_MUTEXES is not set
CONFIG_RT_MUTEX_TESTER=y
CONFIG_DEBUG_SPINLOCK=y
CONFIG_DEBUG_MUTEXES=y
CONFIG_DEBUG_LOCK_ALLOC=y
CONFIG_PROVE_LOCKING=y
CONFIG_PROVE_RCU=y
# CONFIG_PROVE_RCU_REPEATEDLY is not set
# CONFIG_SPARSE_RCU_POINTER is not set
CONFIG_LOCKDEP=y
CONFIG_LOCK_STAT=y
CONFIG_DEBUG_LOCKDEP=y
CONFIG_TRACE_IRQFLAGS=y
CONFIG_DEBUG_ATOMIC_SLEEP=y
CONFIG_DEBUG_LOCKING_API_SELFTESTS=y
CONFIG_STACKTRACE=y
CONFIG_DEBUG_STACK_USAGE=y
# CONFIG_DEBUG_KOBJECT is not set
# CONFIG_DEBUG_BUGVERBOSE is not set
# CONFIG_DEBUG_INFO is not set
# CONFIG_DEBUG_VM is not set
# CONFIG_DEBUG_VIRTUAL is not set
CONFIG_DEBUG_WRITECOUNT=y
CONFIG_DEBUG_MEMORY_INIT=y
# CONFIG_DEBUG_LIST is not set
CONFIG_TEST_LIST_SORT=y
# CONFIG_DEBUG_SG is not set
# CONFIG_DEBUG_NOTIFIERS is not set
CONFIG_DEBUG_CREDENTIALS=y
CONFIG_ARCH_WANT_FRAME_POINTERS=y
CONFIG_FRAME_POINTER=y
CONFIG_BOOT_PRINTK_DELAY=y
CONFIG_RCU_TORTURE_TEST=y
# CONFIG_RCU_TORTURE_TEST_RUNNABLE is not set
CONFIG_RCU_TRACE=y
# CONFIG_BACKTRACE_SELF_TEST is not set
# CONFIG_DEBUG_FORCE_WEAK_PER_CPU is not set
# CONFIG_NOTIFIER_ERROR_INJECTION is not set
# CONFIG_FAULT_INJECTION is not set
CONFIG_DEBUG_PAGEALLOC=y
CONFIG_WANT_PAGE_DEBUG_FLAGS=y
CONFIG_PAGE_GUARD=y
CONFIG_USER_STACKTRACE_SUPPORT=y
CONFIG_HAVE_FUNCTION_TRACER=y
CONFIG_HAVE_FUNCTION_GRAPH_TRACER=y
CONFIG_HAVE_FUNCTION_GRAPH_FP_TEST=y
CONFIG_HAVE_FUNCTION_TRACE_MCOUNT_TEST=y
CONFIG_HAVE_DYNAMIC_FTRACE=y
CONFIG_HAVE_FTRACE_MCOUNT_RECORD=y
CONFIG_HAVE_SYSCALL_TRACEPOINTS=y
CONFIG_HAVE_C_RECORDMCOUNT=y
CONFIG_RING_BUFFER=y
CONFIG_RING_BUFFER_ALLOW_SWAP=y
CONFIG_TRACING_SUPPORT=y
# CONFIG_FTRACE is not set
# CONFIG_PROVIDE_OHCI1394_DMA_INIT is not set
# CONFIG_BUILD_DOCSRC is not set
# CONFIG_DYNAMIC_DEBUG is not set
# CONFIG_DMA_API_DEBUG is not set
CONFIG_ATOMIC64_SELFTEST=y
# CONFIG_SAMPLES is not set
CONFIG_HAVE_ARCH_KGDB=y
# CONFIG_KGDB is not set
CONFIG_HAVE_ARCH_KMEMCHECK=y
CONFIG_TEST_KSTRTOX=y
CONFIG_STRICT_DEVMEM=y
# CONFIG_X86_VERBOSE_BOOTUP is not set
CONFIG_EARLY_PRINTK=y
# CONFIG_EARLY_PRINTK_DBGP is not set
# CONFIG_DEBUG_STACKOVERFLOW is not set
# CONFIG_X86_PTDUMP is not set
CONFIG_DEBUG_RODATA=y
CONFIG_DEBUG_RODATA_TEST=y
# CONFIG_DEBUG_TLBFLUSH is not set
# CONFIG_IOMMU_DEBUG is not set
CONFIG_IOMMU_STRESS=y
CONFIG_HAVE_MMIOTRACE_SUPPORT=y
CONFIG_IO_DELAY_TYPE_0X80=0
CONFIG_IO_DELAY_TYPE_0XED=1
CONFIG_IO_DELAY_TYPE_UDELAY=2
CONFIG_IO_DELAY_TYPE_NONE=3
# CONFIG_IO_DELAY_0X80 is not set
# CONFIG_IO_DELAY_0XED is not set
CONFIG_IO_DELAY_UDELAY=y
# CONFIG_IO_DELAY_NONE is not set
CONFIG_DEFAULT_IO_DELAY_TYPE=2
# CONFIG_DEBUG_BOOT_PARAMS is not set
CONFIG_CPA_DEBUG=y
# CONFIG_OPTIMIZE_INLINING is not set
# CONFIG_DEBUG_STRICT_USER_COPY_CHECKS is not set
# CONFIG_DEBUG_NMI_SELFTEST is not set

#
# Security options
#
CONFIG_KEYS=y
# CONFIG_ENCRYPTED_KEYS is not set
# CONFIG_KEYS_DEBUG_PROC_KEYS is not set
# CONFIG_SECURITY_DMESG_RESTRICT is not set
# CONFIG_SECURITY is not set
CONFIG_SECURITYFS=y
CONFIG_DEFAULT_SECURITY_DAC=y
CONFIG_DEFAULT_SECURITY=""
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
CONFIG_CRYPTO_USER=y
CONFIG_CRYPTO_MANAGER_DISABLE_TESTS=y
CONFIG_CRYPTO_GF128MUL=y
CONFIG_CRYPTO_NULL=y
CONFIG_CRYPTO_WORKQUEUE=y
CONFIG_CRYPTO_CRYPTD=y
# CONFIG_CRYPTO_AUTHENC is not set
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
# CONFIG_CRYPTO_CBC is not set
CONFIG_CRYPTO_CTR=y
CONFIG_CRYPTO_CTS=y
CONFIG_CRYPTO_ECB=y
CONFIG_CRYPTO_LRW=y
# CONFIG_CRYPTO_PCBC is not set
CONFIG_CRYPTO_XTS=y

#
# Hash modes
#
CONFIG_CRYPTO_HMAC=y
CONFIG_CRYPTO_XCBC=y
# CONFIG_CRYPTO_VMAC is not set

#
# Digest
#
CONFIG_CRYPTO_CRC32C=y
# CONFIG_CRYPTO_CRC32C_INTEL is not set
CONFIG_CRYPTO_GHASH=y
# CONFIG_CRYPTO_MD4 is not set
CONFIG_CRYPTO_MD5=y
# CONFIG_CRYPTO_MICHAEL_MIC is not set
# CONFIG_CRYPTO_RMD128 is not set
CONFIG_CRYPTO_RMD160=y
CONFIG_CRYPTO_RMD256=y
# CONFIG_CRYPTO_RMD320 is not set
CONFIG_CRYPTO_SHA1=y
CONFIG_CRYPTO_SHA1_SSSE3=y
# CONFIG_CRYPTO_SHA256 is not set
# CONFIG_CRYPTO_SHA512 is not set
# CONFIG_CRYPTO_TGR192 is not set
CONFIG_CRYPTO_WP512=y
CONFIG_CRYPTO_GHASH_CLMUL_NI_INTEL=y

#
# Ciphers
#
CONFIG_CRYPTO_AES=y
CONFIG_CRYPTO_AES_X86_64=y
CONFIG_CRYPTO_AES_NI_INTEL=y
# CONFIG_CRYPTO_ANUBIS is not set
CONFIG_CRYPTO_ARC4=y
# CONFIG_CRYPTO_BLOWFISH is not set
CONFIG_CRYPTO_BLOWFISH_COMMON=y
CONFIG_CRYPTO_BLOWFISH_X86_64=y
# CONFIG_CRYPTO_CAMELLIA is not set
# CONFIG_CRYPTO_CAMELLIA_X86_64 is not set
# CONFIG_CRYPTO_CAST5 is not set
# CONFIG_CRYPTO_CAST6 is not set
CONFIG_CRYPTO_DES=y
CONFIG_CRYPTO_FCRYPT=y
# CONFIG_CRYPTO_KHAZAD is not set
# CONFIG_CRYPTO_SALSA20 is not set
# CONFIG_CRYPTO_SALSA20_X86_64 is not set
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
# CONFIG_CRYPTO_LZO is not set

#
# Random Number Generation
#
CONFIG_CRYPTO_ANSI_CPRNG=y
CONFIG_CRYPTO_USER_API=y
CONFIG_CRYPTO_USER_API_HASH=y
CONFIG_CRYPTO_USER_API_SKCIPHER=y
# CONFIG_CRYPTO_HW is not set
CONFIG_HAVE_KVM=y
# CONFIG_VIRTUALIZATION is not set
# CONFIG_BINARY_PRINTF is not set

#
# Library routines
#
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
# CONFIG_CRC32_SLICEBY8 is not set
# CONFIG_CRC32_SLICEBY4 is not set
CONFIG_CRC32_SARWATE=y
# CONFIG_CRC32_BIT is not set
CONFIG_CRC7=y
CONFIG_LIBCRC32C=y
CONFIG_CRC8=y
CONFIG_ZLIB_INFLATE=y
CONFIG_ZLIB_DEFLATE=y
CONFIG_LZO_COMPRESS=y
CONFIG_LZO_DECOMPRESS=y
CONFIG_XZ_DEC=y
# CONFIG_XZ_DEC_X86 is not set
# CONFIG_XZ_DEC_POWERPC is not set
CONFIG_XZ_DEC_IA64=y
# CONFIG_XZ_DEC_ARM is not set
CONFIG_XZ_DEC_ARMTHUMB=y
# CONFIG_XZ_DEC_SPARC is not set
CONFIG_XZ_DEC_BCJ=y
# CONFIG_XZ_DEC_TEST is not set
CONFIG_DECOMPRESS_GZIP=y
CONFIG_HAS_IOMEM=y
CONFIG_HAS_IOPORT=y
CONFIG_HAS_DMA=y
CONFIG_DQL=y
CONFIG_NLATTR=y
CONFIG_ARCH_HAS_ATOMIC64_DEC_IF_POSITIVE=y
CONFIG_AVERAGE=y
# CONFIG_CORDIC is not set
CONFIG_DDR=y

--45Z9DzgjV8m4Oswq--
