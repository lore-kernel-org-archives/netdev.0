From: Fengguang Wu <wfg@linux.intel.com>
Subject: BUG: unable to handle kernel paging request at 00000000d8be176d
Date: Fri, 6 Jul 2012 13:58:59 +0800
Message-ID: <20120706055859.GA27693@localhost>
References: <20120705134857.GA14643@localhost>
 <20120705.142200.1828988382587831318.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="UlVJffcvxoiEqYs2"
Content-Transfer-Encoding: 8bit
Cc: netdev@vger.kernel.org,
	Steffen Klassert <steffen.klassert@secunet.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:9410 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932072Ab2GFF7H (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 6 Jul 2012 01:59:07 -0400
Content-Disposition: inline
In-Reply-To: <20120705.142200.1828988382587831318.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--UlVJffcvxoiEqYs2
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

On Thu, Jul 05, 2012 at 02:22:00PM -0700, David Miller wrote:
> 
> Steffen Klassert posted a patch which fixes this.

Steffen's patch converts one oops message into another.

tree:   git://git.kernel.org/pub/scm/linux/kernel/git/davem/net-next.git master
head:   700db99d0140e9da2a31e08ebd3e1b121691aa26
commit: a2de86f63cfc92f7aaf11e7b9d9f2150946a1622 [1/2] ipv6: Initialize the neighbour pointer of rt6_info on allocation

x86_64-allyesdebian         BBB

That 3 'B's indicate boot failures for all the 3 commits (detailed
below).  Where commit 0 still has the old error message. Commit 1 and
2 (both with Steffen's fix) trigger another oops. Note that commit 2
is boot tested 9 times, all of them produce about the same error message.

0:      B c90a9bb  [   77.308688] general protection fault: 0000 [#1] SMP DEBUG_PAGEALLOC [__nla_put nla_put inet6_rt_notify fib6_add __ip6_ins_rt ip6_route_add addrconf_add_mroute addrconf_add_dev addrconf_dev_config addrconf_notify notifier_call_chain __raw_notifier_call_chain raw_notifier_call_chain call_netdevice_notifiers __dev_notify_flags dev_change_flags ip_auto_config do_one_initcall kernel_init kernel_thread_helper]
1:      B a2de86f  [  127.378529] BUG: unable to handle kernel paging request at 00000000d8be176d [ip6_dst_lookup_tail ip6_dst_lookup_flow ip6_datagram_connect inet_dgram_connect sys_connect system_call_fastpath]
2:      B 700db99  [   86.189249] BUG: unable to handle kernel paging request at 00000000d0d4176d [ip6_dst_lookup_tail ip6_dst_lookup_flow ip6_datagram_connect inet_dgram_connect sys_connect system_call_fastpath]
2:      B 700db99  [   91.294019] BUG: unable to handle kernel paging request at 00000000eac8176d [ip6_dst_lookup_tail ip6_dst_lookup_flow ip6_datagram_connect inet_dgram_connect sys_connect system_call_fastpath]
2:      B 700db99  [  136.361566] BUG: unable to handle kernel paging request at 000000008eab176d [ip6_dst_lookup_tail ip6_dst_lookup_flow ip6_datagram_connect inet_dgram_connect sys_connect system_call_fastpath]
2:      B 700db99  [  133.408933] BUG: unable to handle kernel paging request at 000000009bc2176d [ip6_dst_lookup_tail ip6_dst_lookup_flow ip6_datagram_connect inet_dgram_connect sys_connect system_call_fastpath]
2:      B 700db99  [  136.259517] BUG: unable to handle kernel paging request at 00000000b79d176d [ip6_dst_lookup_tail ip6_dst_lookup_flow ip6_datagram_connect inet_dgram_connect sys_connect system_call_fastpath]
2:      B 700db99  [   82.898992] BUG: unable to handle kernel paging request at 000000003ae1176d [ip6_dst_lookup_tail ip6_dst_lookup_flow ip6_datagram_connect inet_dgram_connect sys_connect system_call_fastpath]
2:      B 700db99  [   85.065760] BUG: unable to handle kernel paging request at 00000000a2c1176d [ip6_dst_lookup_tail ip6_dst_lookup_flow ip6_datagram_connect inet_dgram_connect sys_connect system_call_fastpath]
2:      B 700db99  [   83.797562] BUG: unable to handle kernel paging request at 00000000fca1176d [ip6_dst_lookup_tail ip6_dst_lookup_flow ip6_datagram_connect inet_dgram_connect sys_connect system_call_fastpath]
2:      B 700db99  [  157.345636] BUG: unable to handle kernel paging request at 0000000067bc176d [ip6_dst_lookup_tail ip6_dst_lookup_flow ip6_datagram_connect inet_dgram_connect sys_connect system_call_fastpath]

[  124.000087] vhci_hcd: changed 0
[  126.016883] vhci_hcd: changed 0
[  127.378529] BUG: unable to handle kernel paging request at 00000000d8be176d
[  127.381203] IP: [<ffffffff82aecfc2>] ip6_dst_lookup_tail+0xd5/0x1d8
[  127.381203] PGD 0 
[  127.381203] Oops: 0000 [#1] SMP DEBUG_PAGEALLOC
[  127.381203] CPU 0 
[  127.381203] Modules linked in:
[  127.381203] 
[  127.381203] 
[  127.381203] Pid: 3073, comm: sshd Not tainted 3.5.0-rc5+ #2 Bochs Bochs
[  127.381203] RIP: 0010:[<ffffffff82aecfc2>]  [<ffffffff82aecfc2>] ip6_dst_lookup_tail+0xd5/0x1d8
[  127.381203] RSP: 0018:ffff8800122d1d08  EFLAGS: 00010206
[  127.381203] RAX: 00000000d8be1600 RBX: ffff8800122d1db0 RCX: 0000000000000015
[  127.381203] RDX: 0000000000000001 RSI: 0000000000000000 RDI: 0000000000000246
[  127.381203] RBP: ffff8800122d1d98 R08: ffff88001f3d5580 R09: ffffffff85124e70
[  127.381203] R10: ffffffff840401a0 R11: ffff88001214be70 R12: ffff8800122d1e10
[  127.381203] R13: 0000000000000000 R14: ffffffff855c5e00 R15: ffff88000cf6e938
[  127.381203] FS:  00007fc9742597c0(0000) GS:ffff88001f200000(0000) knlGS:0000000000000000
[  127.381203] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
[  127.381203] CR2: 00000000d8be176d CR3: 000000001219a000 CR4: 00000000000006f0
[  127.381203] DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
[  127.381203] DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
[  127.381203] Process sshd (pid: 3073, threadinfo ffff8800122d0000, task ffff880011c74d40)
[  127.381203] Stack:
[  127.381203]  ffff8800122d1d18 ffff8800122d1e34 ffff8800122d1d28 ffffffff8111ee10
[  127.381203]  ffff8800122d1d48 ffffffff8111f528 ffffffff810c0f1e ffffffff810da5f8
[  127.381203]  ffff8800122d1d68 00000000810da56c 0000000000000092 00000000b4cb58b8
[  127.381203] Call Trace:
[  127.381203]  [<ffffffff8111ee10>] ? irq_trace+0x14/0x21
[  127.381203]  [<ffffffff8111f528>] ? time_hardirqs_off+0x26/0x2a
[  127.381203]  [<ffffffff810c0f1e>] ? local_clock+0x3b/0x52
[  127.381203]  [<ffffffff810da5f8>] ? trace_hardirqs_off+0xd/0xf
[  127.381203]  [<ffffffff81097236>] ? _local_bh_enable_ip+0xbb/0xd8
[  127.381203]  [<ffffffff82aed0f9>] ip6_dst_lookup_flow+0x34/0x7e
[  127.381203]  [<ffffffff82b11a51>] ip6_datagram_connect+0x34b/0x4a4
[  127.381203]  [<ffffffff81097261>] ? local_bh_enable_ip+0xe/0x10
[  127.381203]  [<ffffffff82ab37c0>] inet_dgram_connect+0x3f/0x6e
[  127.381203]  [<ffffffff829d1aa3>] sys_connect+0x9b/0xd9
[  127.381203]  [<ffffffff810de26a>] ? trace_hardirqs_on_caller+0x123/0x17f
[  127.381203]  [<ffffffff816b050e>] ? trace_hardirqs_on_thunk+0x3a/0x3f
[  127.381203]  [<ffffffff82e53629>] system_call_fastpath+0x16/0x1b
[  127.381203] Code: 8a 48 6e c0 e9 05 0f b6 c9 eb 02 31 c9 4c 8b 85 78 ff ff ff 49 8d 54 24 14 4c 89 f7 e8 fa db 00 00 85 c0 0f 85 bb 00 00 00 eb a4 <f6> 80 6d 01 00 00 de 0f 85 a5 00 00 00 e8 53 fc ff ff 48 8b 03 
[  127.381203] RIP  [<ffffffff82aecfc2>] ip6_dst_lookup_tail+0xd5/0x1d8
[  127.381203]  RSP <ffff8800122d1d08>
[  127.381203] CR2: 00000000d8be176d
[  127.484620] ---[ end trace 86ddee5921c27d8c ]---

commit a2de86f63cfc92f7aaf11e7b9d9f2150946a1622
Author: Steffen Klassert <steffen.klassert@secunet.com>
Date:   Thu Jul 5 03:18:28 2012 +0000

    ipv6: Initialize the neighbour pointer of rt6_info on allocation
    
    git commit 97cac082 (ipv6: Store route neighbour in rt6_info struct)
    added a neighbour pointer to rt6_info. Currently we don't initialize
    this pointer at allocation time. We assume this pointer to be valid
    if it is not a null pointer, so initialize it on allocation.
    
    Signed-off-by: Steffen Klassert <steffen.klassert@secunet.com>
    Signed-off-by: David S. Miller <davem@davemloft.net>

diff --git a/net/ipv6/route.c b/net/ipv6/route.c
index ceff71d..6cc6c88 100644
--- a/net/ipv6/route.c
+++ b/net/ipv6/route.c
@@ -273,7 +273,7 @@ static inline struct rt6_info *ip6_dst_alloc(struct net *net,
 					0, 0, flags);
 
 	if (rt) {
-		memset(&rt->rt6i_table, 0,
+		memset(&rt->n, 0,
 		       sizeof(*rt) - sizeof(struct dst_entry));
 		rt6_init_peer(rt, table ? &table->tb6_peers : net->ipv6.peers);
 	}

--UlVJffcvxoiEqYs2
Content-Type: text/plain; charset=utf-8
Content-Disposition: attachment; filename=dmesg-kvm-fat-3730-2012-07-06-13-19-00
Content-Transfer-Encoding: 8bit

[    0.000000] Initializing cgroup subsys cpuset
[    0.000000] Initializing cgroup subsys cpu
[    0.000000] Linux version 3.5.0-rc5+ (wfg@bee) (gcc version 4.7.0 (Debian 4.7.1-1) ) #3 SMP Fri Jul 6 13:14:08 CST 2012
[    0.000000] Command line: rcutorture.rcutorture_runnable=0 tree=net-next:master auth_hashtable_size=10 sunrpc.auth_hashtable_size=10 log_buf_len=8M ignore_loglevel debug sched_debug apic=debug dynamic_printk sysrq_always_enabled panic=10 hung_task_panic=1 softlockup_panic=1 unknown_nmi_panic=1 nmi_watchdog=panic,lapic load_ramdisk=2 prompt_ramdisk=0 console=ttyS0,115200 console=tty0 vga=normal ip=::::kvm::dhcp nfsroot=10.239.97.14:/nfsroot/wfg,tcp,v3,nocto,actimeo=600,nolock,rsize=524288,wsize=524288 rw link=vmlinuz-2012-07-06-13-15-01-net-net-next.master-700db99-700db99-x86_64-allyesdebian-1 BOOT_IMAGE=kernel-tests/kernels/x86_64-allyesdebian/700db99d0140e9da2a31e08ebd3e1b121691aa26/vmlinuz-3.5.0-rc5+
[    0.000000] Disabled fast string operations
[    0.000000] e820: BIOS-provided physical RAM map:
[    0.000000] debug: ignoring loglevel setting.
[    0.000000] NX (Execute Disable) protection: active
[    0.000000] DMI 2.4 present.
[    0.000000] No AGP bridge found
[    0.000000] e820: last_pfn = 0x1fffd max_arch_pfn = 0x400000000
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
[    0.000000] x86 PAT enabled: cpu 0, old 0x70106, new 0x7010600070106
[    0.000000] Scan for SMP in [mem 0x00000000-0x000003ff]
[    0.000000] Scan for SMP in [mem 0x0009fc00-0x0009ffff]
[    0.000000] Scan for SMP in [mem 0x000f0000-0x000fffff]
[    0.000000] found SMP MP-table at [mem 0x000f8860-0x000f886f] mapped at [ffff8800000f8860]
[    0.000000]   mpc: f8870-f898c
[    0.000000] initial memory mapped: [mem 0x00000000-0x1fffffff]
[    0.000000] Base memory trampoline at [ffff880000099000] 99000 size 24576
[    0.000000] init_memory_mapping: [mem 0x00000000-0x1fffcfff]
[    0.000000]  [mem 0x00000000-0x1fffcfff] page 4k
[    0.000000] kernel direct mapping tables up to 0x1fffcfff @ [mem 0x1fefb000-0x1fffcfff]
[    0.000000] log_buf_len: 8388608
[    0.000000] early log buf free: 127844(97%)
[    0.000000] ACPI: Local APIC address 0xfee00000
[    0.000000] mapped APIC to ffffffffff5fb000 (        fee00000)
[    0.000000] No NUMA configuration found
[    0.000000] Faking a node at [mem 0x0000000000000000-0x000000001fffcfff]
[    0.000000] Initmem setup node 0 [mem 0x00000000-0x1fffcfff]
[    0.000000]   NODE_DATA [mem 0x1f6f6000-0x1f6fafff]
[    0.000000] kvm-clock: cpu 0, msr 0:45efa81, boot clock
[    0.000000]  [ffffea0000000000-ffffea00007fffff] PMD -> [ffff88001e600000-ffff88001edfffff] on node 0
[    0.000000] Zone ranges:
[    0.000000] Movable zone start for each node
[    0.000000] Early memory node ranges
[    0.000000]   node   0: [mem 0x00010000-0x0009efff]
[    0.000000]   node   0: [mem 0x00100000-0x1fffcfff]
[    0.000000] On node 0 totalpages: 130956
[    0.000000]   DMA zone: 64 pages used for memmap
[    0.000000]   DMA zone: 6 pages reserved
[    0.000000]   DMA zone: 3913 pages, LIFO batch:0
[    0.000000]   DMA32 zone: 1984 pages used for memmap
[    0.000000]   DMA32 zone: 124989 pages, LIFO batch:31
[    0.000000] ACPI: PM-Timer IO Port: 0xb008
[    0.000000] ACPI: Local APIC address 0xfee00000
[    0.000000] mapped APIC to ffffffffff5fb000 (        fee00000)
[    0.000000] ACPI: LAPIC (acpi_id[0x00] lapic_id[0x00] enabled)
[    0.000000] ACPI: LAPIC (acpi_id[0x01] lapic_id[0x01] enabled)
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
[    0.000000] SMP: Allowing 2 CPUs, 0 hotplug CPUs
[    0.000000] mapped IOAPIC to ffffffffff5fa000 (fec00000)
[    0.000000] nr_irqs_gsi: 40
[    0.000000] PM: Registered nosave memory: 000000000009f000 - 00000000000a0000
[    0.000000] PM: Registered nosave memory: 00000000000a0000 - 00000000000f0000
[    0.000000] PM: Registered nosave memory: 00000000000f0000 - 0000000000100000
[    0.000000] e820: [mem 0x20000000-0xfffbbfff] available for PCI devices
[    0.000000] Booting paravirtualized kernel on KVM
[    0.000000] setup_percpu: NR_CPUS:512 nr_cpumask_bits:512 nr_cpu_ids:2 nr_node_ids:1
[    0.000000] PERCPU: Embedded 477 pages/cpu @ffff88001f200000 s1924184 r8192 d21416 u2097152
[    0.000000] kvm-clock: cpu 0, msr 0:1f3d4a81, primary cpu clock
[    0.000000] Built 1 zonelists in Node order, mobility grouping on.  Total pages: 128902
[    0.000000] Policy zone: DMA32
[    0.000000] Kernel command line: rcutorture.rcutorture_runnable=0 tree=net-next:master auth_hashtable_size=10 sunrpc.auth_hashtable_size=10 log_buf_len=8M ignore_loglevel debug sched_debug apic=debug dynamic_printk sysrq_always_enabled panic=10 hung_task_panic=1 softlockup_panic=1 unknown_nmi_panic=1 nmi_watchdog=panic,lapic load_ramdisk=2 prompt_ramdisk=0 console=ttyS0,115200 console=tty0 vga=normal ip=::::kvm::dhcp nfsroot=10.239.97.14:/nfsroot/wfg,tcp,v3,nocto,actimeo=600,nolock,rsize=524288,wsize=524288 rw link=vmlinuz-2012-07-06-13-15-01-net-net-next.master-700db99-700db99-x86_64-allyesdebian-1 BOOT_IMAGE=kernel-tests/kernels/x86_64-allyesdebian/700db99d0140e9da2a31e08ebd3e1b121691aa26/vmlinuz-3.5.0-rc5+
[    0.000000] sysrq: sysrq always enabled.
[    0.000000] PID hash table entries: 2048 (order: 2, 16384 bytes)
[    0.000000] __ex_table already sorted, skipping sort
[    0.000000] Checking aperture...
[    0.000000] No AGP bridge found
[    0.000000] Calgary: detecting Calgary via BIOS EBDA area
[    0.000000] Calgary: Unable to locate Rio Grande table in EBDA - bailing!
[    0.000000] Memory: 430200k/524276k available (31077k kernel code, 452k absent, 93624k reserved, 22271k data, 3912k init)
[    0.000000] Hierarchical RCU implementation.
[    0.000000] 	RCU debugfs-based tracing is enabled.
[    0.000000] 	RCU dyntick-idle grace-period acceleration is enabled.
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
[    0.000000] allocated 2097152 bytes of page_cgroup
[    0.000000] please try 'cgroup_disable=memory' option if you don't want memory cgroups
[    0.000000] ODEBUG: 0 of 0 active objects replaced
[    0.000000] hpet clockevent registered
[    0.000000] Detected 3200.226 MHz processor.
[    0.004000] Calibrating delay loop (skipped) preset value.. 6400.45 BogoMIPS (lpj=12800904)
[    0.004000] pid_max: default: 32768 minimum: 301
[    0.004569] Security Framework initialized
[    0.005586] AppArmor: AppArmor disabled by boot time parameter
[    0.008322] Dentry cache hash table entries: 65536 (order: 7, 524288 bytes)
[    0.010687] Inode-cache hash table entries: 32768 (order: 6, 262144 bytes)
[    0.012435] Mount-cache hash table entries: 256
[    0.016652] Initializing cgroup subsys cpuacct
[    0.017729] Initializing cgroup subsys memory
[    0.019018] Initializing cgroup subsys devices
[    0.020013] Initializing cgroup subsys freezer
[    0.021080] Initializing cgroup subsys net_cls
[    0.022162] Initializing cgroup subsys blkio
[    0.023567] Disabled fast string operations
[    0.024026] mce: CPU supports 10 MCE banks
[    0.025151] numa_add_cpu cpu 0 node 0: mask now 0
[    0.028877] ACPI: Core revision 20120320
[    0.033501] ftrace: allocating 117566 entries in 460 pages
[    0.060399] Getting VERSION: 50014
[    0.064016] Getting VERSION: 50014
[    0.064903] Getting ID: 0
[    0.065663] Getting ID: ff000000
[    0.066498] Getting LVT0: 8700
[    0.067340] Getting LVT1: 8400
[    0.068058] enabled ExtINT on CPU#0
[    0.069888] ENABLING IO-APIC IRQs
[    0.070765] init IO_APIC IRQs
[    0.072012]  apic 2 pin 0 not connected
[    0.072987] IOAPIC[0]: Set routing entry (2-1 -> 0x31 -> IRQ 1 Mode:0 Active:0 Dest:1)
[    0.074883] IOAPIC[0]: Set routing entry (2-2 -> 0x30 -> IRQ 0 Mode:0 Active:0 Dest:1)
[    0.076032] IOAPIC[0]: Set routing entry (2-3 -> 0x33 -> IRQ 3 Mode:0 Active:0 Dest:1)
[    0.077901] IOAPIC[0]: Set routing entry (2-4 -> 0x34 -> IRQ 4 Mode:0 Active:0 Dest:1)
[    0.080030] IOAPIC[0]: Set routing entry (2-5 -> 0x35 -> IRQ 5 Mode:1 Active:0 Dest:1)
[    0.081913] IOAPIC[0]: Set routing entry (2-6 -> 0x36 -> IRQ 6 Mode:0 Active:0 Dest:1)
[    0.084042] IOAPIC[0]: Set routing entry (2-7 -> 0x37 -> IRQ 7 Mode:0 Active:0 Dest:1)
[    0.085907] IOAPIC[0]: Set routing entry (2-8 -> 0x38 -> IRQ 8 Mode:0 Active:0 Dest:1)
[    0.088031] IOAPIC[0]: Set routing entry (2-9 -> 0x39 -> IRQ 9 Mode:1 Active:0 Dest:1)
[    0.089915] IOAPIC[0]: Set routing entry (2-10 -> 0x3a -> IRQ 10 Mode:1 Active:0 Dest:1)
[    0.092043] IOAPIC[0]: Set routing entry (2-11 -> 0x3b -> IRQ 11 Mode:1 Active:0 Dest:1)
[    0.093941] IOAPIC[0]: Set routing entry (2-12 -> 0x3c -> IRQ 12 Mode:0 Active:0 Dest:1)
[    0.096031] IOAPIC[0]: Set routing entry (2-13 -> 0x3d -> IRQ 13 Mode:0 Active:0 Dest:1)
[    0.097943] IOAPIC[0]: Set routing entry (2-14 -> 0x3e -> IRQ 14 Mode:0 Active:0 Dest:1)
[    0.100031] IOAPIC[0]: Set routing entry (2-15 -> 0x3f -> IRQ 15 Mode:0 Active:0 Dest:1)
[    0.101935]  apic 2 pin 16 not connected
[    0.102894]  apic 2 pin 17 not connected
[    0.104012]  apic 2 pin 18 not connected
[    0.104958]  apic 2 pin 19 not connected
[    0.105910]  apic 2 pin 20 not connected
[    0.106877]  apic 2 pin 21 not connected
[    0.107858]  apic 2 pin 22 not connected
[    0.108011]  apic 2 pin 23 not connected
[    0.109130] ..TIMER: vector=0x30 apic1=0 pin1=2 apic2=-1 pin2=-1
[    0.110739] CPU0: Intel Common KVM processor stepping 01
[    0.113283] Using local APIC timer interrupts.
[    0.113283] calibrating APIC timer ...
[    0.116006] ... lapic delta = 6249853
[    0.116006] ... PM-Timer delta = 357944
[    0.116006] ... PM-Timer result ok
[    0.116006] ..... delta 6249853
[    0.116006] ..... mult: 268412366
[    0.116006] ..... calibration result: 3999905
[    0.116006] ..... CPU clock speed is 3200.0075 MHz.
[    0.116006] ..... host bus clock speed is 999.3905 MHz.
[    0.116057] Performance Events: unsupported Netburst CPU model 6 no PMU driver, software events only.
[    0.120044] Testing tracer nop: PASSED
[    0.121336] NMI watchdog: disabled (cpu0): hardware events not enabled
[    0.125481] lockdep: fixing up alternatives.
[    0.126787] Booting Node   0, Processors  #1 Ok.
[    0.004000] kvm-clock: cpu 1, msr 0:1f5d4a81, secondary cpu clock
[    0.004000] masked ExtINT on CPU#1
[    0.004000] Disabled fast string operations
[    0.004000] numa_add_cpu cpu 1 node 0: mask now 0-1
[    0.148255] Brought up 2 CPUs
[    0.149087] Total of 2 processors activated (12800.90 BogoMIPS).
[    0.152561] CPU0 attaching sched-domain:
[    0.153512]  domain 0: span 0-1 level CPU
[    0.154602]   groups: 0 (cpu_power = 1023) 1
[    0.156054] CPU1 attaching sched-domain:
[    0.157019]  domain 0: span 0-1 level CPU
[    0.158064]   groups: 1 0 (cpu_power = 1023)
[    0.160610] devtmpfs: initialized
[    0.174821] xor: automatically using best checksumming function:
[    0.216027]    generic_sse:   258.000 MB/sec
[    0.217062] atomic64 test passed for x86-64 platform with CX8 and with SSE
[    0.224900] dummy: 
[    0.226363] NET: Registered protocol family 16
[    0.235755] ACPI: bus type pci registered
[    0.236255] dca service started, version 1.12.1
[    0.237443] PCI: Using configuration type 1 for base access
[    0.242994] mtrr: your CPUs had inconsistent variable MTRR settings
[    0.244019] mtrr: your CPUs had inconsistent MTRRdefType settings
[    0.245353] mtrr: probably your BIOS does not setup all CPUs.
[    0.246663] mtrr: corrected configuration.
[    0.381462] bio: create slab <bio-0> at 0
[    0.452036] raid6: sse2x1    7803 MB/s
[    0.520044] raid6: sse2x2    9111 MB/s
[    0.588042] raid6: sse2x4   10208 MB/s
[    0.588977] raid6: using algorithm sse2x4 (10208 MB/s)
[    0.590131] raid6: using intx1 recovery algorithm
[    0.591487] ACPI: Added _OSI(Module Device)
[    0.592044] ACPI: Added _OSI(Processor Device)
[    0.593107] ACPI: Added _OSI(3.0 _SCP Extensions)
[    0.594224] ACPI: Added _OSI(Processor Aggregator Device)
[    0.598129] ACPI: EC: Look up EC in DSDT
[    0.606705] ACPI: Interpreter enabled
[    0.607625] ACPI: (supports S0 S3 S4 S5)
[    0.608888] ACPI: Using IOAPIC for interrupt routing
[    0.624976] ACPI: No dock devices found.
[    0.625927] PCI: Ignoring host bridge windows from ACPI; if necessary, use "pci=use_crs" and report a bug
[    0.628127] ACPI: PCI Root Bridge [PCI0] (domain 0000 [bus 00-ff])
[    0.629621] pci_root PNP0A03:00: host bridge window [io  0x0000-0x0cf7] (ignored)
[    0.631360] pci_root PNP0A03:00: host bridge window [io  0x0d00-0xffff] (ignored)
[    0.632045] pci_root PNP0A03:00: host bridge window [mem 0x000a0000-0x000bffff] (ignored)
[    0.633952] pci_root PNP0A03:00: host bridge window [mem 0xe0000000-0xfebfffff] (ignored)
[    0.636052] PCI: root bus 00: using default resources
[    0.637469] PCI host bridge to bus 0000:00
[    0.638480] pci_bus 0000:00: root bus resource [io  0x0000-0xffff]
[    0.640047] pci_bus 0000:00: root bus resource [mem 0x00000000-0xffffffffff]
[    0.641602] pci 0000:00:00.0: [8086:1237] type 00 class 0x060000
[    0.643363] pci 0000:00:01.0: [8086:7000] type 00 class 0x060100
[    0.644611] pci 0000:00:01.1: [8086:7010] type 00 class 0x010180
[    0.646306] pci 0000:00:01.1: reg 20: [io  0xc000-0xc00f]
[    0.648330] pci 0000:00:01.3: [8086:7113] type 00 class 0x068000
[    0.650182] pci 0000:00:01.3: quirk: [io  0xb000-0xb03f] claimed by PIIX4 ACPI
[    0.652058] pci 0000:00:01.3: quirk: [io  0xb100-0xb10f] claimed by PIIX4 SMB
[    0.653785] pci 0000:00:02.0: [1013:00b8] type 00 class 0x030000
[    0.657263] pci 0000:00:02.0: reg 10: [mem 0xf0000000-0xf1ffffff pref]
[    0.662201] pci 0000:00:02.0: reg 14: [mem 0xf2000000-0xf2000fff]
[    0.674594] pci 0000:00:02.0: reg 30: [mem 0xf2010000-0xf201ffff pref]
[    0.676388] pci 0000:00:03.0: [8086:100e] type 00 class 0x020000
[    0.678172] pci 0000:00:03.0: reg 10: [mem 0xf2020000-0xf203ffff]
[    0.680052] pci 0000:00:03.0: reg 14: [io  0xc040-0xc07f]
[    0.684048] pci 0000:00:03.0: reg 30: [mem 0xf2040000-0xf2047fff pref]
[    0.685602] pci 0000:00:04.0: [1af4:1001] type 00 class 0x010000
[    0.687024] pci 0000:00:04.0: reg 10: [io  0xc080-0xc0bf]
[    0.688124] pci 0000:00:04.0: reg 14: [mem 0xf2048000-0xf2048fff]
[    0.690067] pci 0000:00:05.0: [1af4:1001] type 00 class 0x010000
[    0.691454] pci 0000:00:05.0: reg 10: [io  0xc0c0-0xc0ff]
[    0.692123] pci 0000:00:05.0: reg 14: [mem 0xf2049000-0xf2049fff]
[    0.694094] pci 0000:00:06.0: [1af4:1001] type 00 class 0x010000
[    0.696175] pci 0000:00:06.0: reg 10: [io  0xc100-0xc13f]
[    0.697383] pci 0000:00:06.0: reg 14: [mem 0xf204a000-0xf204afff]
[    0.699372] pci 0000:00:07.0: [1af4:1001] type 00 class 0x010000
[    0.700175] pci 0000:00:07.0: reg 10: [io  0xc140-0xc17f]
[    0.701395] pci 0000:00:07.0: reg 14: [mem 0xf204b000-0xf204bfff]
[    0.703376] pci 0000:00:08.0: [1af4:1001] type 00 class 0x010000
[    0.704175] pci 0000:00:08.0: reg 10: [io  0xc180-0xc1bf]
[    0.705404] pci 0000:00:08.0: reg 14: [mem 0xf204c000-0xf204cfff]
[    0.708618] pci 0000:00:09.0: [1af4:1001] type 00 class 0x010000
[    0.710003] pci 0000:00:09.0: reg 10: [io  0xc1c0-0xc1ff]
[    0.711266] pci 0000:00:09.0: reg 14: [mem 0xf204d000-0xf204dfff]
[    0.712709] pci 0000:00:0a.0: [8086:25ab] type 00 class 0x088000
[    0.714054] pci 0000:00:0a.0: reg 10: [mem 0xf204e000-0xf204e00f]
[    0.716577] ACPI: PCI Interrupt Routing Table [\_SB_.PCI0._PRT]
[    0.720198]  pci0000:00: Unable to request _OSC control (_OSC support mask: 0x1e)
[    0.742856] ACPI: PCI Interrupt Link [LNKA] (IRQs 5 *10 11)
[    0.744635] ACPI: PCI Interrupt Link [LNKB] (IRQs 5 *10 11)
[    0.746462] ACPI: PCI Interrupt Link [LNKC] (IRQs 5 10 *11)
[    0.748974] ACPI: PCI Interrupt Link [LNKD] (IRQs 5 10 *11)
[    0.752234] vgaarb: device added: PCI:0000:00:02.0,decodes=io+mem,owns=io+mem,locks=none
[    0.754670] vgaarb: loaded
[    0.755622] vgaarb: bridge control possible 0000:00:02.0
[    0.756649] tps65010: version 2 May 2005
[    0.788121] tps65010: no chip?
[    0.790162] SCSI subsystem initialized
[    0.791426] libata version 3.00 loaded.
[    0.792357] ACPI: bus type usb registered
[    0.793711] usbcore: registered new interface driver usbfs
[    0.795060] usbcore: registered new interface driver hub
[    0.796202] usbcore: registered new device driver usb
[    0.797861] Linux media interface: v0.10
[    0.800060] Linux video capture interface: v2.00
[    0.801640] pps_core: LinuxPPS API ver. 1 registered
[    0.803298] pps_core: Software ver. 5.3.6 - Copyright 2005-2007 Rodolfo Giometti <giometti@linux.it>
[    0.804109] PTP clock support registered
[    0.808517] wmi: Mapper loaded
[    5.808903] Advanced Linux Sound Architecture Driver Version 1.0.25.
[    5.810523] PCI: Using ACPI for IRQ routing
[    5.811673] PCI: pci_cache_line_size set to 64 bytes
[    5.812731] e820: reserve RAM buffer [mem 0x0009f400-0x0009ffff]
[    5.814809] e820: reserve RAM buffer [mem 0x1fffd000-0x1fffffff]
[    5.817691] Sangoma WANPIPE Router v1.1 (c) 1995-2000 Sangoma Technologies Inc.
[    5.820679] NET: Registered protocol family 23
[    5.822264] Bluetooth: Core ver 2.16
[    5.823268] NET: Registered protocol family 31
[    5.824432] Bluetooth: HCI device and connection manager initialized
[    5.825953] Bluetooth: HCI socket layer initialized
[    5.827099] Bluetooth: L2CAP socket layer initialized
[    5.828482] Bluetooth: SCO socket layer initialized
[    5.829799] NET: Registered protocol family 8
[    5.830790] NET: Registered protocol family 20
[    5.832775] cfg80211: Calling CRDA to update world regulatory domain
[    5.834974] nfc: nfc_init: NFC Core ver 0.1
[    5.836472] NET: Registered protocol family 39
[    5.841559] HPET: 3 timers in total, 0 timers will be used for per-cpu timer
[    5.843311] hpet0: at MMIO 0xfed00000, IRQs 2, 8, 0
[    5.844649] hpet0: 3 comparators, 64-bit 100.000000 MHz counter
[    5.848529] Switching to clocksource kvm-clock
[    6.203982] FS-Cache: Loaded
[    6.205199] CacheFiles: Loaded
[    6.206097] pnp: PnP ACPI init
[    6.206944] ACPI: bus type pnp registered
[    6.207954] pnp 00:00: [bus 00-ff]
[    6.208835] pnp 00:00: [io  0x0cf8-0x0cff]
[    6.209775] pnp 00:00: [io  0x0000-0x0cf7 window]
[    6.210797] pnp 00:00: [io  0x0d00-0xffff window]
[    6.211822] pnp 00:00: [mem 0x000a0000-0x000bffff window]
[    6.213022] pnp 00:00: [mem 0xe0000000-0xfebfffff window]
[    6.214371] pnp 00:00: Plug and Play ACPI device, IDs PNP0a03 (active)
[    6.215986] pnp 00:01: [io  0x0070-0x0071]
[    6.217013] IOAPIC[0]: Set routing entry (2-8 -> 0x38 -> IRQ 8 Mode:0 Active:0 Dest:3)
[    6.218759] pnp 00:01: [irq 8]
[    6.219510] pnp 00:01: [io  0x0072-0x0077]
[    6.220684] pnp 00:01: Plug and Play ACPI device, IDs PNP0b00 (active)
[    6.222170] pnp 00:02: [io  0x0060]
[    6.223008] pnp 00:02: [io  0x0064]
[    6.223845] IOAPIC[0]: Set routing entry (2-1 -> 0x31 -> IRQ 1 Mode:0 Active:0 Dest:3)
[    6.225614] pnp 00:02: [irq 1]
[    6.226533] pnp 00:02: Plug and Play ACPI device, IDs PNP0303 (active)
[    6.227971] IOAPIC[0]: Set routing entry (2-12 -> 0x3c -> IRQ 12 Mode:0 Active:0 Dest:3)
[    6.229791] pnp 00:03: [irq 12]
[    6.230714] pnp 00:03: Plug and Play ACPI device, IDs PNP0f13 (active)
[    6.232200] pnp 00:04: [io  0x03f2-0x03f5]
[    6.233134] pnp 00:04: [io  0x03f7]
[    6.233962] IOAPIC[0]: Set routing entry (2-6 -> 0x36 -> IRQ 6 Mode:0 Active:0 Dest:3)
[    6.235707] pnp 00:04: [irq 6]
[    6.236557] pnp 00:04: [dma 2]
[    6.237482] pnp 00:04: Plug and Play ACPI device, IDs PNP0700 (active)
[    6.239046] pnp 00:05: [io  0x0378-0x037f]
[    6.239983] IOAPIC[0]: Set routing entry (2-7 -> 0x37 -> IRQ 7 Mode:0 Active:0 Dest:3)
[    6.241786] pnp 00:05: [irq 7]
[    6.242704] pnp 00:05: Plug and Play ACPI device, IDs PNP0400 (active)
[    6.244229] pnp 00:06: [io  0x03f8-0x03ff]
[    6.245168] IOAPIC[0]: Set routing entry (2-4 -> 0x34 -> IRQ 4 Mode:0 Active:0 Dest:3)
[    6.246924] pnp 00:06: [irq 4]
[    6.247860] pnp 00:06: Plug and Play ACPI device, IDs PNP0501 (active)
[    6.249403] pnp 00:07: [mem 0xfed00000-0xfed003ff]
[    6.250614] pnp 00:07: Plug and Play ACPI device, IDs PNP0103 (active)
[    6.252256] pnp: PnP ACPI: found 8 devices
[    6.253214] ACPI: ACPI bus type pnp unregistered
[    6.281929] pci_bus 0000:00: resource 4 [io  0x0000-0xffff]
[    6.283410] pci_bus 0000:00: resource 5 [mem 0x00000000-0xffffffffff]
[    6.285882] NET: Registered protocol family 2
[    6.287874] IP route cache hash table entries: 4096 (order: 3, 32768 bytes)
[    6.291068] TCP established hash table entries: 16384 (order: 6, 262144 bytes)
[    6.293690] TCP bind hash table entries: 16384 (order: 8, 1310720 bytes)
[    6.297711] TCP: Hash tables configured (established 16384 bind 16384)
[    6.309280] TCP: reno registered
[    6.310115] UDP hash table entries: 256 (order: 3, 49152 bytes)
[    6.311493] UDP-Lite hash table entries: 256 (order: 3, 49152 bytes)
[    6.313742] NET: Registered protocol family 1
[    6.316073] RPC: Registered named UNIX socket transport module.
[    6.317315] RPC: Registered udp transport module.
[    6.318350] RPC: Registered tcp transport module.
[    6.319383] RPC: Registered tcp NFSv4.1 backchannel transport module.
[    6.320830] pci 0000:00:00.0: Limiting direct PCI/PCI transfers
[    6.322091] pci 0000:00:01.0: PIIX3: Enabling Passive Release
[    6.323340] pci 0000:00:01.0: Activating ISA DMA hang workarounds
[    6.324768] pci 0000:00:02.0: Boot video device
[    6.325906] PCI: CLS 0 bytes, default 64
[    6.377652] DMA-API: preallocated 32768 debug entries
[    6.378779] DMA-API: debugging enabled by kernel config
[    6.383409] kvm: no hardware support
[    6.384326] has_svm: not amd
[    6.385064] kvm: no hardware support
[    6.387208] Machine check injector initialized
[    6.389976] microcode: CPU0 sig=0xf61, pf=0x1, revision=0x1
[    6.391218] microcode: CPU1 sig=0xf61, pf=0x1, revision=0x1
[    6.393061] microcode: Microcode Update Driver: v2.00 <tigran@aivazian.fsnet.co.uk>, Peter Oruba
[    6.395640] blowfish-x86_64: performance on this CPU would be suboptimal: disabling blowfish-x86_64.
[    6.395669] cryptomgr_test (29) used greatest stack depth: 6008 bytes left
[    6.399669] cryptomgr_test (30) used greatest stack depth: 5784 bytes left
[    6.399692] twofish-x86_64-3way: performance on this CPU would be suboptimal: disabling twofish-x86_64-3way.
[    6.403463] sha1_ssse3: Neither AVX nor SSSE3 is available/usable.
[    6.409372] Initializing RT-Tester: OK
[    6.410582] audit: initializing netlink socket (disabled)
[    6.411881] type=2000 audit(1341551851.404:1): initialized
[    6.488458] Kprobe smoke test started
[    6.547423] Kprobe smoke test passed successfully
[    6.572289] Testing tracer function: PASSED
[    6.982086] Testing dynamic ftrace: [    7.384164] Refined TSC clocksource calibration: 3200.115 MHz.
PASSED
[    7.504528] Testing dynamic ftrace ops #1: (1 0 1 1 0) (1 1 2 1 0) (2 1 3 1 51) (2 2 4 1 250) PASSED
[    8.257482] Testing dynamic ftrace ops #2: (1 0 1 50 0) (1 1 2 225 0) (2 1 3 2 31) (2 2 4 197 226) PASSED
[    8.996464] Testing tracer irqsoff: PASSED
[    9.588277] Testing tracer wakeup: PASSED
[   10.464287] Testing tracer wakeup_rt: PASSED
[   11.380194] Testing tracer function_graph: PASSED
[   12.157959] HugeTLB registered 2 MB page size, pre-allocated 0 pages
[   12.161392] VFS: Disk quotas dquot_6.5.2
[   12.162453] Dquot-cache hash table entries: 512 (order 0, 4096 bytes)
[   12.165518] DLM installed
[   12.168216] squashfs: version 4.0 (2009/01/31) Phillip Lougher
[   12.172883] NFS: Registering the id_resolver key type
[   12.174059] Key type id_resolver registered
[   12.175061] FS-Cache: Netfs 'nfs' registered for caching
[   12.177751] nfs4filelayout_init: NFSv4 File Layout Driver Registering...
[   12.179221] Installing knfsd (copyright (C) 1996 okir@monad.swb.de).
[   12.183312] FS-Cache: Netfs 'cifs' registered for caching
[   12.186720] Key type cifs.spnego registered
[   12.188260] Key type cifs.idmap registered
[   12.189881] NTFS driver 2.1.30 [Flags: R/W].
[   12.191929] EFS: 1.0a - http://aeschi.ch.eu.org/efs/
[   12.193711] jffs2: version 2.2. (NAND) (SUMMARY)  © 2001-2006 Red Hat, Inc.
[   12.197519] ROMFS MTD (C) 2007 Red Hat, Inc.
[   12.199002] QNX4 filesystem 0.2.3 registered.
[   12.200968] fuse init (API version 7.19)
[   12.203662] JFS: nTxBlock = 3360, nTxLock = 26887
[   12.213550] SGI XFS with ACLs, security attributes, realtime, large block/inode numbers, no debug enabled
[   12.220111] 9p: Installing v9fs 9p2000 file system support
[   12.221748] FS-Cache: Netfs '9p' registered for caching
[   12.223815] NILFS version 2 loaded
[   12.225145] BeFS version: 0.9.3
[   12.226477] OCFS2 1.5.0
[   12.228531] ocfs2: Registered cluster interface o2cb
[   12.230261] ocfs2: Registered cluster interface user
[   12.231703] OCFS2 DLMFS 1.5.0
[   12.233391] OCFS2 User DLM kernel interface loaded
[   12.234976] OCFS2 Node Manager 1.5.0
[   12.237504] OCFS2 DLM 1.5.0
[   12.240648] Btrfs loaded
[   12.243939] GFS2 installed
[   12.245709] ceph: loaded (mds proto 32)
[   12.247131] msgmni has been set to 840
[   12.250015] alg: No test for cipher_null (cipher_null-generic)
[   12.252248] alg: No test for ecb(cipher_null) (ecb-cipher_null)
[   12.254466] alg: No test for digest_null (digest_null-generic)
[   12.256793] alg: No test for compress_null (compress_null-generic)
[   12.259284] cryptomgr_test (66) used greatest stack depth: 5608 bytes left
[   12.262999] cryptomgr_test (70) used greatest stack depth: 5432 bytes left
[   12.269132] cryptomgr_test (80) used greatest stack depth: 5400 bytes left
[   12.273664] alg: No test for fcrypt (fcrypt-generic)
[   12.285833] alg: No test for stdrng (krng)
[   12.302100] alg: No test for fips(ansi_cprng) (fips_ansi_cprng)
[   12.304412] NET: Registered protocol family 38
[   12.305984] async_tx: api initialized (async)
[   12.307681] Block layer SCSI generic (bsg) driver version 0.4 loaded (major 249)
[   12.310272] io scheduler noop registered
[   12.311635] io scheduler deadline registered
[   12.313465] io scheduler cfq registered (default)
[   12.315053] start plist test
[   12.318455] end plist test
[   12.319546] list_sort_test: start testing list_sort()
[   12.324379] pci_hotplug: PCI Hot Plug PCI Core version: 0.5
[   12.325766] pciehp: PCI Express Hot Plug Controller Driver version: 0.4
[   12.327694] cpcihp_zt5550: ZT5550 CompactPCI Hot Plug Driver version: 0.2
[   12.329550] cpcihp_generic: Generic port I/O CompactPCI Hot Plug Driver version: 0.1
[   12.331429] cpcihp_generic: not configured, disabling.
[   12.332845] shpchp: Standard Hot Plug PCI Controller Driver version: 0.4
[   12.334929] acpiphp: ACPI Hot Plug PCI Controller Driver version: 0.5
[   12.337468] acpiphp: Slot [1] registered
[   12.338985] acpiphp: Slot [2] registered
[   12.340656] acpiphp: Slot [3] registered
[   12.342181] acpiphp: Slot [4] registered
[   12.343730] acpiphp: Slot [5] registered
[   12.345334] acpiphp: Slot [6] registered
[   12.346914] acpiphp: Slot [7] registered
[   12.348548] acpiphp: Slot [8] registered
[   12.350126] acpiphp: Slot [9] registered
[   12.351636] acpiphp: Slot [10] registered
[   12.353289] acpiphp: Slot [11] registered
[   12.354849] acpiphp: Slot [12] registered
[   12.356757] acpiphp: Slot [13] registered
[   12.358360] acpiphp: Slot [14] registered
[   12.359988] acpiphp: Slot [15] registered
[   12.361655] acpiphp: Slot [16] registered
[   12.363240] acpiphp: Slot [17] registered
[   12.364890] acpiphp: Slot [18] registered
[   12.366479] acpiphp: Slot [19] registered
[   12.368125] acpiphp: Slot [20] registered
[   12.369665] acpiphp: Slot [21] registered
[   12.371222] acpiphp: Slot [22] registered
[   12.372903] acpiphp: Slot [23] registered
[   12.374453] acpiphp: Slot [24] registered
[   12.376100] acpiphp: Slot [25] registered
[   12.377644] acpiphp: Slot [26] registered
[   12.379236] acpiphp: Slot [27] registered
[   12.380901] acpiphp: Slot [28] registered
[   12.382317] acpiphp: Slot [29] registered
[   12.383890] acpiphp: Slot [30] registered
[   12.385387] acpiphp: Slot [31] registered
[   12.391746] acpiphp_ibm: ibm_acpiphp_init: acpi_walk_namespace failed
[   12.394628] progear_bl: ALI M7101 PMU not found.
[   12.397526] VIA Graphics Integration Chipset framebuffer 2.4 initializing
[   12.400640] vmlfb: initializing
[   12.401951] Could not find Carillo Ranch MCH device.
[   12.403923] no IO addresses supplied
[   12.405583] hgafb: HGA card not detected.
[   12.406903] hgafb: probe of hgafb.0 failed with error -22
[   12.408928] usbcore: registered new interface driver udlfb
[   12.412260] kworker/u:0 (115) used greatest stack depth: 5272 bytes left
[   12.414541] uvesafb: failed to execute /sbin/v86d
[   12.415954] uvesafb: make sure that the v86d helper is installed and executable
[   12.418306] uvesafb: Getting VBE info block failed (eax=0x4f00, err=-2)
[   12.420399] uvesafb: vbe_init() failed with -22
[   12.421710] uvesafb: probe of uvesafb.0 failed with error -22
[   12.424277] input: Power Button as /devices/LNXSYSTM:00/LNXPWRBN:00/input/input0
[   12.426677] ACPI: Power Button [PWRF]
[   12.442606] GHES: HEST is not enabled!
[   12.443893] ioatdma: Intel(R) QuickData Technology Driver 4.00
[   12.446886] ACPI: PCI Interrupt Link [LNKD] enabled at IRQ 11
[   12.448850] IOAPIC[0]: Set routing entry (2-11 -> 0x3b -> IRQ 11 Mode:1 Active:0 Dest:3)
[   12.451618] virtio-pci 0000:00:04.0: setting latency timer to 64
[   12.454704] ACPI: PCI Interrupt Link [LNKA] enabled at IRQ 10
[   12.456506] IOAPIC[0]: Set routing entry (2-10 -> 0x3a -> IRQ 10 Mode:1 Active:0 Dest:3)
[   12.459262] virtio-pci 0000:00:05.0: setting latency timer to 64
[   12.462065] ACPI: PCI Interrupt Link [LNKB] enabled at IRQ 10
[   12.463933] virtio-pci 0000:00:06.0: setting latency timer to 64
[   12.466676] ACPI: PCI Interrupt Link [LNKC] enabled at IRQ 11
[   12.468701] virtio-pci 0000:00:07.0: setting latency timer to 64
[   12.470871] virtio-pci 0000:00:08.0: setting latency timer to 64
[   12.473290] virtio-pci 0000:00:09.0: setting latency timer to 64
[   12.475511] XENFS: not registering filesystem on non-xen platform
[   12.478105] HDLC line discipline maxframe=4096
[   12.494425] N_HDLC line discipline registered.
[   12.495997] r3964: Philips r3964 Driver $Revision: 1.10 $
[   12.497804] Serial: 8250/16550 driver, 4 ports, IRQ sharing enabled
[   12.523468] serial8250: ttyS0 at I/O 0x3f8 (irq = 4) is a 16550A
[   12.551627] 00:06: ttyS0 at I/O 0x3f8 (irq = 4) is a 16550A
[   12.555672] Cyclades driver 2.6
[   12.557610] MOXA Intellio family driver version 6.0k
[   12.592978] MOXA Smartio/Industio family driver version 2.0.5
[   12.595002] Initializing Nozomi driver 2.1d
[   12.596817] RocketPort device driver module, version 2.09, 12-June-2003
[   12.599063] No rocketport ports found; unloading driver
[   12.600987] SyncLink GT
[   12.602078] SyncLink GT, tty major#244
[   12.603575] SyncLink GT no devices found
[   12.605050] SyncLink MultiPort driver $Revision: 4.38 $
[   12.650680] SyncLink MultiPort driver $Revision: 4.38 $, tty major#243
[   12.652862] SyncLink serial driver $Revision: 4.38 $
[   12.694626] SyncLink serial driver $Revision: 4.38 $, tty major#242
[   12.697818] lp: driver loaded but no devices found
[   12.699098] Applicom driver: $Id: ac.c,v 1.30 2000/03/22 16:03:57 dwmw2 Exp $
[   12.700885] ac.o: No PCI boards found.
[   12.701867] ac.o: For an ISA board you must supply memory and irq parameters.
[   12.704337] Non-volatile memory driver v1.3
[   12.706302] ppdev: user-space parallel port driver
[   12.707613] telclk_interrupt = 0xf non-mcpbl0010 hw.
[   12.709086] smapi::smapi_init, ERROR invalid usSmapiID
[   12.710370] mwave: tp3780i::tp3780I_InitializeBoardData: Error: SMAPI is not available on this machine
[   12.712689] mwave: mwavedd::mwave_init: Error: Failed to initialize board data
[   12.714539] mwave: mwavedd::mwave_init: Error: Failed to initialize
[   12.716093] Linux agpgart interface v0.103
[   12.719549] SyncLink PC Card driver $Revision: 4.34 $, tty major#240
[   12.721460] ipmi message handler version 39.2
[   12.722616] ipmi device interface
[   12.723624] IPMI System Interface driver.
[   12.725016] ipmi_si: Adding default-specified kcs state machine
[   12.726539] ipmi_si: Trying default-specified kcs state machine at i/o address 0xca2, slave address 0x0, irq 0
[   12.729037] ipmi_si: Interface detection failed
[   12.730370] ipmi_si: Adding default-specified smic state machine
[   12.731951] ipmi_si: Trying default-specified smic state machine at i/o address 0xca9, slave address 0x0, irq 0
[   12.734375] ipmi_si: Interface detection failed
[   12.756114] ipmi_si: Adding default-specified bt state machine
[   12.757659] ipmi_si: Trying default-specified bt state machine at i/o address 0xe4, slave address 0x0, irq 0
[   12.759987] ipmi_si: Interface detection failed
[   12.761486] ipmi_si: Unable to find any System Interface(s)
[   12.762867] IPMI Watchdog: driver initialized
[   12.763964] Copyright (C) 2004 MontaVista Software - IPMI Powerdown via sys_reboot.
[   12.765983] Hangcheck: starting hangcheck timer 0.9.1 (tick is 180 seconds, margin is 60 seconds).
[   12.768212] Hangcheck: Using getrawmonotonic().
[   12.769663] [drm] Initialized drm 1.1.0 20060810
[   12.771305] [drm] radeon defaulting to kernel modesetting.
[   12.772784] [drm] radeon kernel modesetting enabled.
[   12.774211] [drm:i915_init] *ERROR* drm/i915 can't work without intel_agp module!
[   12.776800] i2c-core: driver [ch7006] using legacy suspend method
[   12.778257] i2c-core: driver [ch7006] using legacy resume method
[   12.780048] parport_pc 00:05: reported by Plug and Play ACPI
[   12.781596] parport0: PC-style at 0x378, irq 7 [PCSPP,TRISTATE]
[   12.881541] lp0: using parport0 (interrupt-driven).
[   12.905031] FDC 0 is a S82078B
[   12.921235] brd: module loaded
[   12.929467] loop: module loaded
[   12.930428] Compaq SMART2 Driver (v 2.6.0)
[   12.931763] HP CISS Driver (v 3.6.26)
[   12.934551] MM: desc_per_page = 128
[   12.939274] nbd: registered device at major 43
[   12.952957] virtio-pci 0000:00:04.0: irq 40 for MSI/MSI-X
[   12.954387] virtio-pci 0000:00:04.0: irq 41 for MSI/MSI-X
[   12.981199]  vda: unknown partition table
[   12.983350] virtio-pci 0000:00:05.0: irq 42 for MSI/MSI-X
[   12.985298] virtio-pci 0000:00:05.0: irq 43 for MSI/MSI-X
[   13.014105]  vdb: unknown partition table
[   13.016357] virtio-pci 0000:00:06.0: irq 44 for MSI/MSI-X
[   13.018163] virtio-pci 0000:00:06.0: irq 45 for MSI/MSI-X
[   13.035699]  vdc: unknown partition table
[   13.037907] virtio-pci 0000:00:07.0: irq 46 for MSI/MSI-X
[   13.039698] virtio-pci 0000:00:07.0: irq 47 for MSI/MSI-X
[   13.061558]  vdd: unknown partition table
[   13.063648] virtio-pci 0000:00:08.0: irq 48 for MSI/MSI-X
[   13.065572] virtio-pci 0000:00:08.0: irq 49 for MSI/MSI-X
[   13.083628]  vde: unknown partition table
[   13.085815] virtio-pci 0000:00:09.0: irq 50 for MSI/MSI-X
[   13.087631] virtio-pci 0000:00:09.0: irq 51 for MSI/MSI-X
[   13.111898]  vdf: unknown partition table
[   13.118737] drbd: initialized. Version: 8.3.13 (api:88/proto:86-96)
[   13.120603] drbd: built-in
[   13.121395] drbd: registered as block device major 147
[   13.122651] drbd: minor_table @ 0xffff880016422ef0
[   13.123946] rbd: loaded rbd (rados block device)
[   13.125345] ibmasm: IBM ASM Service Processor Driver version 1.0 loaded
[   13.127488] lkdtm: No crash points registered, enable through debugfs
[   13.129417] Phantom Linux Driver, version n0.9.8, init OK
[   13.131271] i2c-core: driver [apds9802als] using legacy suspend method
[   13.132835] i2c-core: driver [apds9802als] using legacy resume method
[   13.134419] i2c-core: driver [isl29003] using legacy suspend method
[   13.136026] i2c-core: driver [isl29003] using legacy resume method
[   13.137641] i2c-core: driver [tsl2550] using legacy suspend method
[   13.139078] i2c-core: driver [tsl2550] using legacy resume method
[   13.140710] Silicon Labs C2 port support v. 0.51.0 - (C) 2007 Rodolfo Giometti
[   13.143358] c2port c2port0: C2 port uc added
[   13.144473] c2port c2port0: uc flash has 30 blocks x 512 bytes (15360 bytes total)
[   13.147838] usbcore: registered new interface driver pn533
[   13.149332] Uniform Multi-Platform E-IDE driver
[   13.150842] piix 0000:00:01.1: IDE controller (0x8086:0x7010 rev 0x00)
[   13.152943] piix 0000:00:01.1: not 100% native mode: will probe irqs later
[   13.154542]     ide0: BM-DMA at 0xc000-0xc007
[   13.155811]     ide1: BM-DMA at 0xc008-0xc00f
[   13.157124] Probing IDE interface ide0...
[   13.724454] Probing IDE interface ide1...
[   14.460426] hdc: QEMU DVD-ROM, ATAPI CD/DVD-ROM drive
[   15.132427] hdc: host max PIO4 wanted PIO255(auto-tune) selected PIO0
[   15.134625] hdc: MWDMA2 mode selected
[   15.136368] ide0 at 0x1f0-0x1f7,0x3f6 on irq 14
[   15.137983] ide1 at 0x170-0x177,0x376 on irq 15
[   15.140793] ide_generic: please use "probe_mask=0x3f" module parameter for probing all legacy ISA IDE ports
[   15.143176] ide-gd driver 1.18
[   15.144184] ide-cd driver 5.00
[   15.145780] ide-cd: hdc: ATAPI 4X CD-ROM drive, 512kB Cache
[   15.147538] cdrom: Uniform CD-ROM driver Revision: 3.20
[   15.152203] Loading iSCSI transport class v2.0-870.
[   15.154325] rdac: device handler registered
[   15.155585] hp_sw: device handler registered
[   15.156735] emc: device handler registered
[   15.157757] alua: device handler registered
[   15.160075] fnic: Cisco FCoE HBA Driver, ver 1.5.0.2
[   15.161843] bnx2fc: Broadcom NetXtreme II FCoE Driver bnx2fc v1.0.11 (Apr 24, 2012)
[   15.164714] iscsi: registered transport (tcp)
[   15.166115] Loading Adaptec I2O RAID: Version 2.4 Build 5go
[   15.167424] Detecting Adaptec I2O RAID controllers...
[   15.169017] Adaptec aacraid driver 1.2-0[28900]-ms
[   15.170576] aic94xx: Adaptec aic94xx SAS/SATA driver version 1.0.3 loaded
[   15.172748] isci: Intel(R) C600 SAS Controller Driver - version 1.1.0
[   15.174478] scsi: <fdomain> Detection failed (no card)
[   15.175975] qla2xxx [0000:00:00.0]-0005: : QLogic Fibre Channel HBA Driver: 8.04.00.03-k.
[   15.178324] iscsi: registered transport (qla4xxx)
[   15.179571] QLogic iSCSI HBA Driver
[   15.180591] Brocade BFA FC/FCOE SCSI driver - version: 3.0.23.0
[   15.182485] DC390: clustering now enabled by default. If you get problems load
[   15.184392]        with "disable_clustering=1" and report to maintainers
[   15.186103] megaraid cmm: 2.20.2.7 (Release Date: Sun Jul 16 00:01:03 EST 2006)
[   15.188158] megaraid: 2.20.5.1 (Release Date: Thu Nov 16 15:32:35 EST 2006)
[   15.189734] megasas: 00.00.06.15-rc1 Mon. Mar. 19 17:00:00 PDT 2012
[   15.191225] mpt2sas version 13.100.00.00 loaded
[   15.192911] GDT-HA: Storage RAID Controller Driver. Version: 3.05
[   15.194545] 3ware Storage Controller device driver for Linux v1.26.02.003.
[   15.196268] 3ware 9000 Storage Controller device driver for Linux v2.26.02.014.
[   15.198059] LSI 3ware SAS/SATA-RAID Controller device driver for Linux v3.26.02.000.
[   15.199990] ppa: Version 2.07 (for Linux 2.4.x)
[   15.203580] imm: Version 2.05 (for Linux 2.4.0)
[   15.205324] ipr: IBM Power RAID SCSI Device Driver version: 2.5.3 (March 10, 2012)
[   15.207194] RocketRAID 3xxx/4xxx Controller driver v1.6 (090910)
[   15.208723] stex: Promise SuperTrak EX Driver version: 4.6.0000.4
[   15.210468] libcxgbi:libcxgbi_init_module: tag itt 0x1fff, 13 bits, age 0xf, 4 bits.
[   15.212333] libcxgbi:ddp_setup_host_page_size: system PAGE 4096, ddp idx 0.
[   15.214021] Chelsio T3 iSCSI Driver cxgb3i v2.0.0 (Jun. 2010)
[   15.215528] iscsi: registered transport (cxgb3i)
[   15.216844] Chelsio T4 iSCSI Driver cxgb4i v0.9.1 (Aug. 2010)
[   15.218353] iscsi: registered transport (cxgb4i)
[   15.219565] Broadcom NetXtreme II iSCSI Driver bnx2i v2.7.2.2 (Apr 25, 2012)
[   15.221391] iscsi: registered transport (bnx2i)
[   15.223221] iscsi: registered transport (be2iscsi)
[   15.224849] VMware PVSCSI driver - version 1.0.2.0-k
[   15.226146] hv_vmbus: registering driver hv_storvsc
[   15.238937] st: Version 20101219, fixed bufsize 32768, s/g segs 256
[   15.240589] osst :I: Tape driver with OnStream support version 0.99.4
[   15.240589] osst :I: $Id: osst.c,v 1.73 2005/01/01 21:13:34 wriede Exp $
[   15.244227] SCSI Media Changer driver v0.25 
[   15.245807] osd: LOADED open-osd 0.2.1
[   15.261543] scsi_debug: host protection
[   15.262615] scsi0 : scsi_debug, version 1.82 [20100324], dev_size_mb=8, opts=0x0
[   15.269067] scsi 0:0:0:0: Direct-Access     Linux    scsi_debug       0004 PQ: 0 ANSI: 5
[   15.273891] Rounding down aligned max_sectors from 4294967295 to 8388600
[   15.274954] sd 0:0:0:0: Attached scsi generic sg0 type 0
[   15.275957] scsi_scan_0 (134) used greatest stack depth: 4056 bytes left
[   15.276223] sd 0:0:0:0: [sda] 16384 512-byte logical blocks: (8.38 MB/8.00 MiB)
[   15.280105] sd 0:0:0:0: [sda] Write Protect is off
[   15.280108] sd 0:0:0:0: [sda] Mode Sense: 73 00 10 08
[   15.288137] sd 0:0:0:0: [sda] Write cache: enabled, read cache: enabled, supports DPO and FUA
[   15.293040] SSFDC read-only Flash Translation layer
[   15.294235] mtdoops: mtd device (mtddev=name/number) must be supplied
[   15.295756] SBC-GXx flash: IO:0x258-0x259 MEM:0xdc000-0xdffff
[   15.297503] Could not find PAR responsible for SC520CDP Flash Bank #0
[   15.298911] Trying default address 0x8400000
[   15.299898] Could not find PAR responsible for SC520CDP Flash Bank #1
[   15.301488] Trying default address 0x8c00000
[   15.302533] Could not find PAR responsible for SC520CDP DIL Flash
[   15.303840] Trying default address 0x9400000
[   15.305079] SC520 CDP flash device: 0x800000 at 0x8400000
[   15.306337] Failed to ioremap_nocache
[   15.307221] NetSc520 flash device: 0x100000 at 0x200000
[   15.308648] Failed to ioremap_nocache
[   15.309574] Failed to ioremap_nocache
[   15.310639] Generic platform RAM MTD, (c) 2004 Simtec Electronics
[   15.320115]  sda: unknown partition table
[   15.336107] sd 0:0:0:0: [sda] Attached SCSI disk
[   15.340155] No recognised DiskOnChip devices found
[   15.341344] slram: not enough parameters.
[   15.342338] Ramix PMC551 PCI Mezzanine Ram Driver. (C) 1999,2000 Nortel Networks.
[   15.344158] pmc551: not detected
[   15.348669] ftl_cs: FTL header not found.
[   15.384437] No valid DiskOnChip devices found
[   15.385629] [nandsim] warning: read_byte: unexpected data output cycle, state is STATE_READY return 0x0
[   15.387730] [nandsim] warning: read_byte: unexpected data output cycle, state is STATE_READY return 0x0
[   15.389921] [nandsim] warning: read_byte: unexpected data output cycle, state is STATE_READY return 0x0
[   15.392159] [nandsim] warning: read_byte: unexpected data output cycle, state is STATE_READY return 0x0
[   15.394331] [nandsim] warning: read_byte: unexpected data output cycle, state is STATE_READY return 0x0
[   15.396569] [nandsim] warning: read_byte: unexpected data output cycle, state is STATE_READY return 0x0
[   15.398644] NAND device: Manufacturer ID: 0x98, Chip ID: 0x39 (Toshiba NAND 128MiB 1,8V 8-bit), page size: 512, OOB size: 16
[   15.401309] flash size: 128 MiB
[   15.402113] page size: 512 bytes
[   15.402958] OOB area size: 16 bytes
[   15.403821] sector size: 16 KiB
[   15.404707] pages number: 262144
[   15.405566] pages per sector: 32
[   15.406396] bus width: 8
[   15.407087] bits in sector size: 14
[   15.407968] bits in page size: 9
[   15.408863] bits in OOB size: 4
[   15.409688] flash size with OOB: 135168 KiB
[   15.410695] page address bytes: 4
[   15.411542] sector address bytes: 3
[   15.412627] options: 0x42
[   15.417152] Scanning device for bad blocks
[   15.477998] Creating 1 MTD partitions on "NAND 128MiB 1,8V 8-bit":
[   15.479405] 0x000000000000-0x000008000000 : "NAND simulator partition 0"
[   15.482243] ftl_cs: FTL header not found.
[   15.484819] usbcore: registered new interface driver alauda
[   15.532065] onenand_wait: timeout! ctrl=0x0000 intr=0x0000
[   15.533400] OneNAND Manufacturer: Samsung (0xec)
[   15.534509] OneNAND 16MB 1.8V 16-bit (0x04)
[   15.535533] OneNAND version = 0x001e
[   15.536645] Lock scheme is Continuous Lock
[   15.537701] Scanning device for bad blocks
[   15.540718] Creating 1 MTD partitions on "OneNAND simulator":
[   15.542093] 0x000000000000-0x000001000000 : "OneNAND simulator partition"
[   15.544857] ftl_cs: FTL header not found.
[   15.660681] parport_pc 00:05: master is unqueued, this is deprecated
[   15.663785] parport0: AVR Butterfly
[   15.664864] parport0: cannot grant exclusive access for device spi-lm70llp
[   15.666421] spi-lm70llp: spi_lm70llp probe fail, status -12
[   15.667925] bonding: Ethernet Channel Bonding Driver: v3.7.1 (April 27, 2011)
[   15.672610] eql: Equalizer2002: Simon Janes (simon@ncm.com) and David S. Miller (davem@redhat.com)
[   15.676909] D-Link DE-620 pocket adapter io 0x378, which is busy.
[   15.680695] tun: Universal TUN/TAP device driver, 1.6
[   15.681878] tun: (C) 1999-2004 Max Krasnyansky <maxk@qualcomm.com>
[   15.683858] arcnet loaded.
[   15.684731] arcnet: RFC1201 "standard" (`a') encapsulation support loaded.
[   15.686240] arcnet: RFC1051 "simple standard" (`s') encapsulation support loaded.
[   15.688112] arcnet: raw mode (`r') encapsulation support loaded.
[   15.689559] arcnet: cap mode (`c') encapsulation support loaded.
[   15.690926] arcnet: COM90xx chipset support
[   15.992931] S3: No ARCnet cards found.
[   15.993928] arcnet: COM90xx IO-mapped mode support (by David Woodhouse et el.)
[   15.995673] E-mail me if you actually test this driver, please!
[   15.997079]  arc%d: No autoprobe for IO mapped cards; you must specify the base address!
[   15.998954] arcnet: RIM I (entirely mem-mapped) support
[   16.000203] E-mail me if you actually test the RIM I driver, please!
[   16.001575] Given: node 00h, shmem 0h, irq 0
[   16.002572] No autoprobe for RIM I; you must specify the shmem and irq!
[   16.003981] arcnet: COM20020 PCI support
[   16.005278] ipddp.c:v0.01 8/28/97 Bradford W. Johnson <johns393@maroon.tc.umn.edu>
[   16.007584] ipddp0: Appletalk-IP Encap. mode by Bradford W. Johnson <johns393@maroon.tc.umn.edu>
[   16.009646] vcan: Virtual CAN interface driver
[   16.010700] slcan: serial line CAN interface driver
[   16.011814] slcan: 10 dynamic interface channels.
[   16.012979] CAN device driver interface
[   16.014119] usbcore: registered new interface driver ems_usb
[   16.015469] usbcore: registered new interface driver esd_usb2
[   16.016981] sja1000 CAN netdevice driver
[   16.019355] pcnet32: pcnet32.c:v1.35 21.Apr.2008 tsbogend@alpha.franken.de
[   16.021147] Atheros(R) L2 Ethernet Driver - version 2.2.3
[   16.022329] Copyright (c) 2007 Atheros Corporation.
[   16.024006] cnic: Broadcom NetXtreme II CNIC Driver cnic v2.5.12 (June 29, 2012)
[   16.026132] bnx2x: Broadcom NetXtreme II 5771x/578xx 10/20-Gigabit Ethernet Driver bnx2x 1.72.51-0 (2012/06/18)
[   16.028922] Brocade 10G Ethernet driver - version: 3.0.23.0
[   16.031074] enic: Cisco VIC Ethernet NIC Driver, ver 2.1.1.39
[   16.032722] dmfe: Davicom DM9xxx net driver, version 1.36.4 (2002-01-17)
[   16.034274] v1.01-e (2.4 port) Sep-11-2006  Donald Becker <becker@scyld.com>
[   16.034274]   http://www.scyld.com/network/drivers.html
[   16.037403] uli526x: ULi M5261/M5263 net driver, version 0.9.3 (2005-7-29)
[   16.038997] DE600: port 0x378 busy
[   16.040333] vxge: Copyright(c) 2002-2010 Exar Corp.
[   16.041419] vxge: Driver version: 2.5.3.22640-k
[   16.042703] e100: Intel(R) PRO/100 Network Driver, 3.5.24-k2-NAPI
[   16.043982] e100: Copyright(c) 1999-2006 Intel Corporation
[   16.045359] e1000: Intel(R) PRO/1000 Network Driver - version 7.3.21-k8-NAPI
[   16.046816] e1000: Copyright (c) 1999-2006 Intel Corporation.
[   16.048357] e1000 0000:00:03.0: setting latency timer to 64
[   16.391057] e1000 0000:00:03.0: eth0: (PCI:33MHz:32-bit) 52:54:00:12:34:56
[   16.393364] e1000 0000:00:03.0: eth0: Intel(R) PRO/1000 Network Connection
[   16.395650] e1000e: Intel(R) PRO/1000 Network Driver - 2.0.0-k
[   16.397584] e1000e: Copyright(c) 1999 - 2012 Intel Corporation.
[   16.399658] igb: Intel(R) Gigabit Ethernet Network Driver - version 4.0.1-k
[   16.401875] igb: Copyright (c) 2007-2012 Intel Corporation.
[   16.403891] igbvf: Intel(R) Gigabit Virtual Function Network Driver - version 2.0.1-k
[   16.406599] igbvf: Copyright (c) 2009 - 2012 Intel Corporation.
[   16.408811] ixgbe: Intel(R) 10 Gigabit PCI Express Network Driver - version 3.9.15-k
[   16.411375] ixgbe: Copyright (c) 1999-2012 Intel Corporation.
[   16.413573] ixgbevf: Intel(R) 10 Gigabit PCI Express Virtual Function Network Driver - version 2.6.0-k
[   16.416682] ixgbevf: Copyright (c) 2009 - 2012 Intel Corporation.
[   16.418821] ixgb: Intel(R) PRO/10GbE Network Driver - version 1.0.135-k2-NAPI
[   16.421115] ixgb: Copyright (c) 1999-2008 Intel Corporation.
[   16.423307] jme: JMicron JMC2XX ethernet driver version 1.0.8
[   16.425677] sky2: driver version 1.30
[   16.428381] myri10ge: Version 1.5.3-1.534
[   16.430252] ns83820.c: National Semiconductor DP83820 10/100/1000 driver.
[   16.433365] QLogic 1/10 GbE Converged/Intelligent Ethernet Driver v5.0.29
[   16.436224] QLogic/NetXen Network Driver v4.0.80
[   16.438254] atp.c:v1.09=ac 2002/10/01 Donald Becker <becker@scyld.com>
[   16.441332] Solarflare NET driver v3.1
[   16.444905] tehuti: Tehuti Networks(R) Network Driver, 7.29.3
[   16.446770] tehuti: Options: hw_csum 
[   16.448250] tlan: ThunderLAN driver v1.17
[   16.449768] tlan: 0 devices installed, PCI: 0  EISA: 0
[   16.452147] mkiss: AX.25 Multikiss, Hans Albas PE1AYX
[   16.453808] AX.25: 6pack driver, Revision: 0.3.0
[   16.455341] YAM driver version 0.8 by F1OAT/F6FBB
[   16.460268] AX.25: bpqether driver version 004
[   16.461769] baycom_ser_fdx: (C) 1996-2000 Thomas Sailer, HB9JNX/AE4WA
[   16.461769] baycom_ser_fdx: version 0.10
[   16.483711] hdlcdrv: (C) 1996-2000 Thomas Sailer HB9JNX/AE4WA
[   16.485648] hdlcdrv: version 0.8
[   16.486844] baycom_ser_hdx: (C) 1996-2000 Thomas Sailer, HB9JNX/AE4WA
[   16.486844] baycom_ser_hdx: version 0.10
[   16.493358] baycom_par: (C) 1996-2000 Thomas Sailer, HB9JNX/AE4WA
[   16.493358] baycom_par: version 0.9
[   16.499862] usbcore: registered new interface driver irda-usb
[   16.501871] usbcore: registered new interface driver stir4200
[   16.505709] usbcore: registered new interface driver mcs7780
[   16.508100] usbcore: registered new interface driver kingsun-sir
[   16.510119] usbcore: registered new interface driver ksdazzle-sir
[   16.512229] usbcore: registered new interface driver ks959-sir
[   16.514988] NET3 PLIP version 2.4-parport gniibe@mri.co.jp
[   16.516910] plip0: Parallel port at 0x378, using IRQ 7.
[   16.518609] PPP generic driver version 2.4.2
[   16.520588] PPP BSD Compression module registered
[   16.522170] PPP Deflate Compression module registered
[   16.525726] PPP MPPE Compression module registered
[   16.527316] NET: Registered protocol family 24
[   16.529052] PPTP driver version 0.8.5
[   16.531816] SLIP: version 0.8.4-NET3.019-NEWTTY (dynamic channels, max=256) (6 bit encapsulation enabled).
[   16.534962] CSLIP: code copyright 1989 Regents of the University of California.
[   16.537598] SLIP linefill/keepalive option.
[   16.539187] hdlc: HDLC support module revision 1.22
[   16.541327] DLCI driver v0.35, 4 Jan 1997, mike.mclagan@linux.org.
[   16.543271] cycx_drv: Cyclom 2X Support Module v0.6 (c) 1998-2003 Arnaldo Carvalho de Melo <acme@conectiva.com.br>
[   16.546617] cyclomx: CYCLOM 2X(tm) Sync Card Driver v0.11 (c) 1998-2003 Arnaldo Carvalho de Melo <acme@conectiva.com.br>
[   16.550528] ipw2200: Intel(R) PRO/Wireless 2200/2915 Network Driver, 1.2.2kmprq
[   16.553075] ipw2200: Copyright(c) 2003-2006 Intel Corporation
[   16.555094] libipw: 802.11 data/management/control stack, git-1.1.13
[   16.557210] libipw: Copyright (C) 2004-2005 Intel Corporation <jketreno@linux.intel.com>
[   16.559901] orinoco 0.15 (David Gibson <hermes@gibson.dropbear.id.au>, Pavel Roskin <proski@gnu.org>, et al)
[   16.563254] orinoco_plx 0.15 (Pavel Roskin <proski@gnu.org>, David Gibson <hermes@gibson.dropbear.id.au>, Daniel Barlow <dan@telent.net>)
[   16.567381] orinoco_tmd 0.15 (Joerg Dorchain <joerg@dorchain.net>)
[   16.569584] orinoco_nortel 0.15 (Tobias Hoffmann & Christoph Jungegger <disdos@traum404.de>)
[   16.572782] usbcore: registered new interface driver orinoco_usb
[   16.574752] airo(): Probing for PCI adapters
[   16.576469] airo(): Finished probing for PCI adapters
[   16.578352] Atmel at76x USB Wireless LAN Driver 0.17 loading
[   16.580361] usbcore: registered new interface driver at76c50x-usb
[   16.582975] Broadcom 43xx driver loaded [ Features: PMNLS ]
[   16.584979] Broadcom 43xx-legacy driver loaded [ Features: PLID ]
[   16.587304] usbcore: registered new interface driver zd1211rw
[   16.589556] usbcore: registered new interface driver rtl8187
[   16.591648] usbcore: registered new interface driver rtl8192cu
[   16.594297] usbcore: registered new interface driver rndis_wlan
[   16.596364] usbcore: registered new interface driver zd1201
[   16.598306] usbcore: registered new interface driver usb8xxx
[   16.600281] libertas_sdio: Libertas SDIO driver
[   16.601819] libertas_sdio: Copyright Pierre Ossman
[   16.603485] libertas_spi: Libertas SPI driver
[   16.605646] usbcore: registered new interface driver lbtf_usb
[   16.607808] Intel(R) Wireless WiFi driver for Linux, in-tree:
[   16.609705] Copyright(c) 2003-2012 Intel Corporation
[   16.611533] iwldvm: Intel(R) Wireless WiFi Link AGN driver for Linux, in-tree:
[   16.614040] iwldvm: Copyright(c) 2003-2012 Intel Corporation
[   16.615934] iwl4965: Intel(R) Wireless WiFi 4965 driver for Linux, in-tree:
[   16.618129] iwl4965: Copyright(c) 2003-2011 Intel Corporation
[   16.620223] iwl3945: Intel(R) PRO/Wireless 3945ABG/BG Network Connection driver for Linux, in-tree:s
[   16.623239] iwl3945: Copyright(c) 2003-2011 Intel Corporation
[   16.626007] usbcore: registered new interface driver rt2500usb
[   16.627975] usbcore: registered new interface driver rt73usb
[   16.629930] usbcore: registered new interface driver rt2800usb
[   16.631962] usbcore: registered new interface driver p54usb
[   16.634449] usbcore: registered new interface driver ath9k_htc
[   16.636546] usbcore: registered new interface driver carl9170
[   16.638432] mac80211_hwsim: Initializing radio 0
[   16.641494] ieee80211 phy0: Selected rate control algorithm 'minstrel_ht'
[   16.645125] ieee80211 phy0: hwaddr 020000000000 registered
[   16.647104] mac80211_hwsim: Initializing radio 1
[   16.649980] ieee80211 phy1: Selected rate control algorithm 'minstrel_ht'
[   16.653183] ieee80211 phy1: hwaddr 020000000100 registered
[   16.655902] mac80211_hwsim: initializing netlink
[   16.658149] usbcore: registered new interface driver i2400m_usb
[   16.660166] VMware vmxnet3 virtual NIC driver - version 1.1.29.0-k-NAPI
[   16.662467] usbcore: registered new interface driver catc
[   16.664388] usbcore: registered new interface driver kaweth
[   16.666173] pegasus: v0.6.14 (2006/09/27), Pegasus/Pegasus II USB Ethernet driver
[   16.668893] usbcore: registered new interface driver pegasus
[   16.670821] usbcore: registered new interface driver rtl8150
[   16.672720] hso: /c/kernel-tests/net/drivers/net/usb/hso.c: Option Wireless
[   16.675027] usbcore: registered new interface driver hso
[   16.677133] usbcore: registered new interface driver asix
[   16.678986] usbcore: registered new interface driver cdc_ether
[   16.681069] usbcore: registered new interface driver cdc_eem
[   16.683065] usbcore: registered new interface driver dm9601
[   16.685047] usbcore: registered new interface driver smsc75xx
[   16.687018] usbcore: registered new interface driver smsc95xx
[   16.689045] usbcore: registered new interface driver gl620a
[   16.690910] usbcore: registered new interface driver net1080
[   16.692927] usbcore: registered new interface driver plusb
[   16.694803] usbcore: registered new interface driver rndis_host
[   16.696899] usbcore: registered new interface driver cdc_subset
[   16.698887] usbcore: registered new interface driver zaurus
[   16.700890] usbcore: registered new interface driver MOSCHIP usb-ethernet driver
[   16.703476] usbcore: registered new interface driver int51x1
[   16.705474] usbcore: registered new interface driver cdc_phonet
[   16.707511] usbcore: registered new interface driver kalmia
[   16.709464] usbcore: registered new interface driver ipheth
[   16.711338] usbcore: registered new interface driver sierra_net
[   16.713463] usbcore: registered new interface driver cx82310_eth
[   16.715455] usbcore: registered new interface driver cdc_ncm
[   16.717434] usbcore: registered new interface driver lg-vl600
[   16.719261] hv_vmbus: registering driver hv_netvsc
[   16.721288] Madge ATM Ambassador driver version 1.2.4
[   16.723087] Madge ATM Horizon [Ultra] driver version 1.2.1
[   16.725272] fore200e: FORE Systems 200E-series ATM driver - version 0.3e
[   16.727663] idt77252_init: at ffffffff846500ab
[   16.729368] Solos PCI Driver Version 0.07
[   16.730880] adummy: version 1.0
[   16.733042] I2O subsystem v1.325
[   16.734256] i2o: max drivers = 8
[   16.736128] I2O Configuration OSM v1.323
[   16.737868] I2O Bus Adapter OSM v1.317
[   16.739271] I2O Block Device OSM v1.325
[   16.742816] I2O SCSI Peripheral OSM v1.316
[   16.744430] I2O ProcFS OSM v1.316
[   16.745816] Fusion MPT base driver 3.04.20
[   16.747226] Copyright (c) 1999-2008 LSI Corporation
[   16.749055] Fusion MPT SPI Host driver 3.04.20
[   16.750790] Fusion MPT FC Host driver 3.04.20
[   16.752564] Fusion MPT SAS Host driver 3.04.20
[   16.754222] Fusion MPT misc device (ioctl) driver 3.04.20
[   16.756332] mptctl: Registered with Fusion MPT base driver
[   16.758106] mptctl: /dev/mptctl @ (major,minor=10,220)
[   16.759774] Fusion MPT LAN driver 3.04.20
[   16.762999] Generic UIO driver for PCI 2.3 devices version: 0.01.0
[   16.767434] aoe: AoE v47 initialised.
[   16.771019] usbcore: registered new interface driver hwa-rc
[   16.773035] usbcore: registered new interface driver i1480-dfu-usb
[   16.775715] ehci_hcd: USB 2.0 'Enhanced' Host Controller (EHCI) Driver
[   16.778051] ohci_hcd: USB 1.1 'Open' Host Controller (OHCI) Driver
[   16.780246] uhci_hcd: USB Universal Host Controller Interface driver
[   16.782836] driver u132_hcd
[   16.784676] usbcore: registered new interface driver hwa-hc
[   16.787001] usbcore: registered new interface driver wusb-cbaf
[   16.789094] usbcore: registered new interface driver cdc_acm
[   16.790912] cdc_acm: USB Abstract Control Model driver for USB modems and ISDN adapters
[   16.793781] usbcore: registered new interface driver usblp
[   16.795778] usbcore: registered new interface driver cdc_wdm
[   16.797811] usbcore: registered new interface driver usbtmc
[   16.799705] usbcore: registered new interface driver uas
[   16.801537] Initializing USB Mass Storage driver...
[   16.803339] usbcore: registered new interface driver usb-storage
[   16.805340] USB Mass Storage support registered.
[   16.807028] usbcore: registered new interface driver ums-alauda
[   16.809278] usbcore: registered new interface driver ums-cypress
[   16.811257] usbcore: registered new interface driver ums-datafab
[   16.813355] usbcore: registered new interface driver ums_eneub6250
[   16.815387] usbcore: registered new interface driver ums-freecom
[   16.817511] usbcore: registered new interface driver ums-isd200
[   16.819467] usbcore: registered new interface driver ums-jumpshot
[   16.821592] usbcore: registered new interface driver ums-karma
[   16.823557] usbcore: registered new interface driver ums-onetouch
[   16.825674] usbcore: registered new interface driver ums-realtek
[   16.827677] usbcore: registered new interface driver ums-sddr09
[   16.829734] usbcore: registered new interface driver ums-sddr55
[   16.831670] usbcore: registered new interface driver ums-usbat
[   16.833746] usbcore: registered new interface driver mdc800
[   16.835554] mdc800: v0.7.5 (30/10/2000):USB Driver for Mustek MDC800 Digital Camera
[   16.838292] usbcore: registered new interface driver microtekX6
[   16.840523] usbcore: registered new interface driver usbserial
[   16.842459] usbcore: registered new interface driver usbserial_generic
[   16.844776] USB Serial support registered for generic
[   16.846454] usbserial: USB Serial Driver core
[   16.863586] usbcore: registered new interface driver aircable
[   16.865594] USB Serial support registered for aircable
[   16.867366] usbcore: registered new interface driver ark3116
[   16.869371] USB Serial support registered for ark3116
[   16.871163] usbcore: registered new interface driver belkin_sa
[   16.873214] USB Serial support registered for Belkin / Peracom / GoHubs USB Serial Adapter
[   16.876102] usbcore: registered new interface driver ch341
[   16.877980] USB Serial support registered for ch341-uart
[   16.879798] usbcore: registered new interface driver cp210x
[   16.881684] USB Serial support registered for cp210x
[   16.883435] usbcore: registered new interface driver cyberjack
[   16.885533] USB Serial support registered for Reiner SCT Cyberjack USB card reader
[   16.888238] usbcore: registered new interface driver cypress_m8
[   16.890229] USB Serial support registered for DeLorme Earthmate USB
[   16.892333] USB Serial support registered for HID->COM RS232 Adapter
[   16.894371] USB Serial support registered for Nokia CA-42 V2 Adapter
[   16.896639] usbcore: registered new interface driver usb_debug
[   16.898578] USB Serial support registered for debug
[   16.900380] usbcore: registered new interface driver digi_acceleport
[   16.902445] USB Serial support registered for Digi 2 port USB adapter
[   16.904617] USB Serial support registered for Digi 4 port USB adapter
[   16.906744] usbcore: registered new interface driver io_edgeport
[   16.908834] USB Serial support registered for Edgeport 2 port adapter
[   16.910931] USB Serial support registered for Edgeport 4 port adapter
[   16.913107] USB Serial support registered for Edgeport 8 port adapter
[   16.915190] USB Serial support registered for EPiC device
[   16.917225] usbcore: registered new interface driver io_ti
[   16.919069] USB Serial support registered for Edgeport TI 1 port adapter
[   16.921305] USB Serial support registered for Edgeport TI 2 port adapter
[   16.923589] usbcore: registered new interface driver empeg
[   16.925554] USB Serial support registered for empeg
[   16.927286] usbcore: registered new interface driver ftdi_sio
[   16.929317] USB Serial support registered for FTDI USB Serial Device
[   16.931279] ftdi_sio: v1.6.0:USB FTDI Serial Converters Driver
[   16.933339] usbcore: registered new interface driver funsoft
[   16.935260] USB Serial support registered for funsoft
[   16.937145] usbcore: registered new interface driver garmin_gps
[   16.939106] USB Serial support registered for Garmin GPS usb/tty
[   16.941222] usbcore: registered new interface driver hp4x
[   16.943069] USB Serial support registered for hp4X
[   16.944863] usbcore: registered new interface driver ipaq
[   16.946728] USB Serial support registered for PocketPC PDA
[   16.948720] usbcore: registered new interface driver ipw
[   16.950545] USB Serial support registered for IPWireless converter
[   16.952711] usbcore: registered new interface driver ir_usb
[   16.954583] USB Serial support registered for IR Dongle
[   16.956377] ir_usb: v0.5:USB IR Dongle driver
[   16.957976] usbcore: registered new interface driver iuu_phoenix
[   16.959981] USB Serial support registered for iuu_phoenix
[   16.961938] usbcore: registered new interface driver keyspan
[   16.963837] USB Serial support registered for Keyspan - (without firmware)
[   16.966102] USB Serial support registered for Keyspan 1 port adapter
[   16.968231] USB Serial support registered for Keyspan 2 port adapter
[   16.970273] USB Serial support registered for Keyspan 4 port adapter
[   16.972486] usbcore: registered new interface driver keyspan_pda
[   16.974473] USB Serial support registered for Keyspan PDA
[   16.976464] USB Serial support registered for Keyspan PDA - (prerenumeration)
[   16.978738] USB Serial support registered for Xircom / Entregra PGS - (prerenumeration)
[   16.981677] usbcore: registered new interface driver kl5kusb105
[   16.983694] USB Serial support registered for KL5KUSB105D / PalmConnect
[   16.985989] usbcore: registered new interface driver kobil_sct
[   16.987918] USB Serial support registered for KOBIL USB smart card terminal
[   16.990256] usbcore: registered new interface driver mct_u232
[   16.992252] USB Serial support registered for MCT U232
[   16.994073] usbcore: registered new interface driver mos7720
[   16.995954] USB Serial support registered for Moschip 2 port adapter
[   16.998186] usbcore: registered new interface driver mos7840
[   17.000143] USB Serial support registered for Moschip 7840/7820 USB Serial Driver
[   17.002790] usbcore: registered new interface driver moto_modem
[   17.004860] USB Serial support registered for moto-modem
[   17.006719] usbcore: registered new interface driver navman
[   17.008684] USB Serial support registered for navman
[   17.010446] usbcore: registered new interface driver omninet
[   17.012452] USB Serial support registered for ZyXEL - omni.net lcd plus usb
[   17.014795] usbcore: registered new interface driver opticon
[   17.016839] USB Serial support registered for opticon
[   17.018617] usbcore: registered new interface driver option
[   17.020567] USB Serial support registered for GSM modem (1-port)
[   17.022591] usbcore: registered new interface driver oti6858
[   17.024629] USB Serial support registered for oti6858
[   17.026407] usbcore: registered new interface driver pl2303
[   17.028366] USB Serial support registered for pl2303
[   17.030141] usbcore: registered new interface driver qcaux
[   17.031972] USB Serial support registered for qcaux
[   17.033752] usbcore: registered new interface driver qcserial
[   17.035703] USB Serial support registered for Qualcomm USB modem
[   17.037673] safe_serial: v0.1:USB Safe Encapsulated Serial
[   17.039601] usbcore: registered new interface driver safe_serial
[   17.041659] USB Serial support registered for safe_serial
[   17.043627] usbcore: registered new interface driver siemens_mpi
[   17.045671] USB Serial support registered for siemens_mpi
[   17.047579] usbcore: registered new interface driver sierra
[   17.049554] USB Serial support registered for Sierra USB modem
[   17.051522] usbcore: registered new interface driver spcp8x5
[   17.053508] USB Serial support registered for SPCP8x5
[   17.055325] usbcore: registered new interface driver ssu100
[   17.057319] USB Serial support registered for Quatech SSU-100 USB to Serial Driver
[   17.059983] usbcore: registered new interface driver symbolserial
[   17.062048] USB Serial support registered for symbol
[   17.063828] usbcore: registered new interface driver ti_usb_3410_5052
[   17.065993] USB Serial support registered for TI USB 3410 1 port adapter
[   17.068204] USB Serial support registered for TI USB 5052 2 port adapter
[   17.070292] ti_usb_3410_5052: v0.10:TI USB 3410/5052 Serial Driver
[   17.072411] usbcore: registered new interface driver visor
[   17.074295] USB Serial support registered for Handspring Visor / Palm OS
[   17.076573] USB Serial support registered for Sony Clie 5.0
[   17.078440] USB Serial support registered for Sony Clie 3.5
[   17.080480] usbcore: registered new interface driver whiteheat
[   17.082430] USB Serial support registered for Connect Tech - WhiteHEAT - (prerenumeration)
[   17.085322] USB Serial support registered for Connect Tech - WhiteHEAT
[   17.087544] usbcore: registered new interface driver vivopay_serial
[   17.089673] USB Serial support registered for vivopay-serial
[   17.091645] usbcore: registered new interface driver zio
[   17.093575] USB Serial support registered for zio
[   17.095252] usbcore: registered new interface driver adutux
[   17.097660] usbcore: registered new interface driver appledisplay
[   17.099693] usbcore: registered new interface driver cypress_cy7c63
[   17.101843] usbcore: registered new interface driver cytherm
[   17.103826] usbcore: registered new interface driver emi26 - firmware loader
[   17.106154] usbcore: registered new interface driver emi62 - firmware loader
[   17.108398] driver ftdi-elan
[   17.110659] usbcore: registered new interface driver ftdi-elan
[   17.112745] usbcore: registered new interface driver idmouse
[   17.114684] usbcore: registered new interface driver iowarrior
[   17.116766] usbcore: registered new interface driver isight_firmware
[   17.118845] usbcore: registered new interface driver usblcd
[   17.120868] usbcore: registered new interface driver ldusb
[   17.122724] usbcore: registered new interface driver usbled
[   17.124742] usbcore: registered new interface driver legousbtower
[   17.126803] usbcore: registered new interface driver rio500
[   17.128819] usbcore: registered new interface driver usbtest
[   17.130760] usbcore: registered new interface driver trancevibrator
[   17.132933] usbcore: registered new interface driver uss720
[   17.134699] uss720: v0.6:USB Parport Cable driver for Cables using the Lucent Technologies USS720 Chip
[   17.137837] uss720: NOTE: this is a special purpose driver to allow nonstandard
[   17.140403] uss720: protocols (eg. bitbang) over USS720 usb to parallel cables
[   17.142863] uss720: If you just want to connect to a printer, use usblp instead
[   17.145652] usbcore: registered new interface driver usbsevseg
[   17.147587] usbcore: registered new interface driver yurex
[   17.149573] usbcore: registered new interface driver sisusb
[   17.151485] usbcore: registered new interface driver cxacru
[   17.153485] usbcore: registered new interface driver speedtch
[   17.155439] usbcore: registered new interface driver ueagle-atm
[   17.157439] xusbatm: malformed module parameters
[   17.159210] i8042: PNP: PS/2 Controller [PNP0303:KBD,PNP0f13:MOU] at 0x60,0x64 irq 1,12
[   17.163660] serio: i8042 KBD port at 0x60,0x64 irq 1
[   17.165510] serio: i8042 AUX port at 0x60,0x64 irq 12
[   17.167886] parport0: cannot grant exclusive access for device parkbd
[   17.260606] mousedev: PS/2 mouse device common for all mice
[   17.264515] input: AT Translated Set 2 keyboard as /devices/platform/i8042/serio0/input/input1
[   17.268931] usbcore: registered new interface driver appletouch
[   17.270286] usbcore: registered new interface driver bcm5974
[   17.272725] usbcore: registered new interface driver iforce
[   17.274819] usbcore: registered new interface driver xpad
[   17.276699] parport0: cannot grant exclusive access for device walkera0701
[   17.278833] usbcore: registered new interface driver usb_acecad
[   17.280599] usbcore: registered new interface driver aiptek
[   17.282161] usbcore: registered new interface driver gtco
[   17.283716] usbcore: registered new interface driver hanwang
[   17.285314] usbcore: registered new interface driver kbtab
[   17.287275] usbcore: registered new interface driver wacom
[   17.291193] mk712: device not present
[   17.292644] usbcore: registered new interface driver usbtouchscreen
[   17.294907] apanel: Fujitsu BIOS signature 'FJKEYINF' not found...
[   17.296432] usbcore: registered new interface driver ati_remote2
[   17.297841] cm109: Keymap for Komunikate KIP1000 phone loaded
[   17.299186] usbcore: registered new interface driver cm109
[   17.300482] cm109: CM109 phone driver: 20080805 (C) Alfred E. Heggestad
[   17.312075] usbcore: registered new interface driver keyspan_remote
[   17.313678] input: PC Speaker as /devices/platform/pcspkr/input/input2
[   17.315352] usbcore: registered new interface driver powermate
[   17.316936] usbcore: registered new interface driver yealink
[   17.319002] rtc_cmos 00:01: rtc core: registered rtc_cmos as rtc0
[   17.320501] rtc0: alarms up to one day, 114 bytes nvram, hpet irqs
[   17.323695] rtc-test rtc-test.0: rtc core: registered test as rtc1
[   17.325411] rtc-test rtc-test.1: rtc core: registered test as rtc2
[   17.326867] i2c /dev entries driver
[   17.328845] piix4_smbus 0000:00:01.3: SMBus Host Controller at 0xb100, revision 0
[   17.441541] usbcore: registered new interface driver i2c-diolan-u2c
[   17.443545] i2c-parport: adapter type unspecified
[   17.445233] i2c-parport-light: adapter type unspecified
[   17.447234] usbcore: registered new interface driver i2c-tiny-usb
[   17.449493] lirc_dev: IR Remote Control driver registered, major 222 
[   17.451556] IR NEC protocol handler initialized
[   17.453211] IR RC5(x) protocol handler initialized
[   17.454809] IR RC6 protocol handler initialized
[   17.456448] IR JVC protocol handler initialized
[   17.458001] IR Sony protocol handler initialized
[   17.459448] IR RC5 (streamzap) protocol handler initialized
[   17.461249] IR SANYO protocol handler initialized
[   17.462853] IR MCE Keyboard/mouse protocol handler initialized
[   17.464816] IR LIRC bridge handler initialized
[   17.466542] usbcore: registered new interface driver imon
[   17.468531] usbcore: registered new interface driver mceusb
[   17.470662] usbcore: registered new interface driver redrat3
[   17.472636] usbcore: registered new interface driver streamzap
[   17.474498] Registered IR keymap rc-empty
[   17.476613] input: rc-core loopback device as /devices/virtual/rc/rc0/input3
[   17.479182] rc0: rc-core loopback device as /devices/virtual/rc/rc0
[   17.482105] input: MCE IR Keyboard/Mouse (rc-loopback) as /devices/virtual/input/input4
[   17.486194] rc rc0: lirc_dev: driver ir-lirc-codec (rc-loopback) registered at minor = 0
[   17.491428] bttv: driver version 0.9.19 loaded
[   17.493063] bttv: using 8 buffers with 2080k (520 pages) each for capture
[   17.495177] bttv: Host bridge needs ETBF enabled
[   17.497171] Zoran MJPEG board driver version 0.10.1
[   17.498927] Linux video codec intermediate layer: v0.2
[   17.500789] meye: using 2 buffers with 600k (1200k total) for capture
[   17.503071] saa7130/34: v4l2 driver version 0, 2, 17 loaded
[   17.505205] cx88/0: cx2388x v4l2 driver version 0.0.9 loaded
[   17.507196] cx88/2: cx2388x MPEG-TS Driver Manager version 0.0.9 loaded
[   17.509510] cx2388x alsa driver version 0.0.9 loaded
[   17.511307] cx2388x blackbird driver version 0.0.9 loaded
[   17.513252] cx88/2: registering cx8802 driver, type: blackbird access: shared
[   17.515571] cx88/2: cx2388x dvb driver version 0.0.9 loaded
[   17.517453] cx88/2: registering cx8802 driver, type: dvb access: shared
[   17.519703] usbcore: registered new interface driver em28xx
[   17.521645] Em28xx: Initialized (Em28xx Audio Extension) extension
[   17.523663] Em28xx: Initialized (Em28xx dvb Extension) extension
[   17.525663] Em28xx: Initialized (Em28xx Input Extension) extension
[   17.527745] usbcore: registered new interface driver poseidon
[   17.529774] usbcore: registered new interface driver cx231xx
[   17.531672] cx231xx: Cx231xx Audio Extension initialized
[   17.533466] cx231xx: Cx231xx dvb Extension initialized
[   17.535310] usbcore: registered new interface driver usbvision
[   17.537350] USBVision USB Video Device Driver for Linux : 0.9.11
[   17.539787] usbcore: registered new interface driver pvrusb2
[   17.541776] pvrusb2: V4L in-tree version:Hauppauge WinTV-PVR-USB2 MPEG2 Encoder/Tuner
[   17.544544] pvrusb2: Debug mask is 31 (0x1f)
[   17.546047] cpia2: V4L-Driver for Vision CPiA2 based cameras v3.0.1
[   17.550749] usbcore: registered new interface driver cpia2
[   17.552842] usbcore: registered new interface driver tm6000
[   17.554709] saa7146: register extension 'Multimedia eXtension Board'
[   17.557034] saa7146: register extension 'hexium HV-PCI6 Orion'
[   17.559051] saa7146: register extension 'hexium gemini'
[   17.561186] usbcore: registered new interface driver zr364xx
[   17.563155] usbcore: registered new interface driver stkwebcam
[   17.565268] usbcore: registered new interface driver sn9c102
[   17.567252] usbcore: registered new interface driver Philips webcam
[   17.569336] gspca_main: v2.14.0 registered
[   17.570928] usbcore: registered new interface driver benq
[   17.572920] usbcore: registered new interface driver conex
[   17.574805] usbcore: registered new interface driver cpia1
[   17.576850] usbcore: registered new interface driver etoms
[   17.578733] usbcore: registered new interface driver finepix
[   17.580790] usbcore: registered new interface driver jeilinj
[   17.582814] usbcore: registered new interface driver kinect
[   17.584830] usbcore: registered new interface driver konica
[   17.586783] usbcore: registered new interface driver mars
[   17.588811] usbcore: registered new interface driver mr97310a
[   17.590796] usbcore: registered new interface driver nw80x
[   17.592800] usbcore: registered new interface driver ov519
[   17.594724] usbcore: registered new interface driver ov534
[   17.596757] usbcore: registered new interface driver ov534_9
[   17.598679] usbcore: registered new interface driver pac207
[   17.600705] usbcore: registered new interface driver gspca_pac7302
[   17.602762] usbcore: registered new interface driver pac7311
[   17.604787] usbcore: registered new interface driver se401
[   17.606715] usbcore: registered new interface driver sn9c2028
[   17.608816] usbcore: registered new interface driver gspca_sn9c20x
[   17.610875] usbcore: registered new interface driver sonixb
[   17.612881] usbcore: registered new interface driver sonixj
[   17.614811] usbcore: registered new interface driver spca500
[   17.616882] usbcore: registered new interface driver spca501
[   17.618944] usbcore: registered new interface driver spca505
[   17.621039] usbcore: registered new interface driver spca506
[   17.623011] usbcore: registered new interface driver spca508
[   17.625066] usbcore: registered new interface driver spca561
[   17.627031] usbcore: registered new interface driver spca1528
[   17.629092] usbcore: registered new interface driver sq905
[   17.630980] usbcore: registered new interface driver sq905c
[   17.632988] usbcore: registered new interface driver sq930x
[   17.634896] usbcore: registered new interface driver sunplus
[   17.636969] usbcore: registered new interface driver stk014
[   17.638876] usbcore: registered new interface driver stv0680
[   17.640907] usbcore: registered new interface driver t613
[   17.642864] usbcore: registered new interface driver tv8532
[   17.644900] usbcore: registered new interface driver vc032x
[   17.646828] usbcore: registered new interface driver vicam
[   17.648863] usbcore: registered new interface driver xirlink-cit
[   17.650891] usbcore: registered new interface driver gspca_zc3xx
[   17.653045] usbcore: registered new interface driver ALi m5602
[   17.655058] usbcore: registered new interface driver STV06xx
[   17.657122] usbcore: registered new interface driver gspca_gl860
[   17.659170] usbcore: registered new interface driver hdpvr
[   17.661181] usbcore: registered new interface driver s2255
[   17.662962] ivtv: Start initialization, version 1.4.3
[   17.664931] ivtv: End initialization
[   17.666288] ivtvfb:  no cards found
[   17.667594] cx18:  Start initialization, version 1.5.1
[   17.669528] cx18:  End initialization
[   17.670853] cx18-alsa: module loading...
[   17.672932] vivi-000: V4L2 device registered as video0
[   17.674627] Video Technology Magazine Virtual Video Capture Board ver 0.8.1 successfully loaded.
[   17.677647] cx23885 driver version 0.0.3 loaded
[   17.679465] au0828 driver loaded
[   17.681070] usbcore: registered new interface driver au0828
[   17.683169] usbcore: registered new interface driver uvcvideo
[   17.685163] USB Video Class driver (1.1.1)
[   17.686633] saa7164 driver loaded
[   17.688853] usbcore: registered new interface driver dsbr100
[   17.690911] usbcore: registered new interface driver radio-si470x
[   17.693232] usbcore: registered new interface driver radio-mr800
[   17.695702] saa7146: register extension 'budget dvb'
[   17.697791] saa7146: register extension 'budget_av'
[   17.699762] saa7146: register extension 'budget_ci dvb'
[   17.701921] saa7146: register extension 'budget_patch dvb'
[   17.704124] saa7146: register extension 'av7110'
[   17.706203] usbcore: registered new interface driver ttusb-dec
[   17.708459] usbcore: registered new interface driver ttusb
[   17.710260] b2c2-flexcop: B2C2 FlexcopII/II(b)/III digital TV receiver chip loaded successfully
[   17.713753] usbcore: registered new interface driver b2c2_flexcop_usb
[   17.715829] bt878: AUDIO driver version 0.0.0 loaded
[   17.718148] usbcore: registered new interface driver dvb_usb_vp7045
[   17.720527] usbcore: registered new interface driver dvb_usb_vp702x
[   17.722756] usbcore: registered new interface driver dvb_usb_gp8psk
[   17.725121] usbcore: registered new interface driver dvb_usb_dtt200u
[   17.727383] usbcore: registered new interface driver dvb_usb_a800
[   17.729744] usbcore: registered new interface driver dvb_usb_dibusb_mb
[   17.732082] usbcore: registered new interface driver dvb_usb_dibusb_mc
[   17.734359] usbcore: registered new interface driver dvb_usb_nova_t_usb2
[   17.736787] usbcore: registered new interface driver dvb_usb_umt_010
[   17.738998] usbcore: registered new interface driver dvb_usb_m920x
[   17.741289] usbcore: registered new interface driver dvb_usb_gl861
[   17.743372] usbcore: registered new interface driver dvb_usb_au6610
[   17.745639] usbcore: registered new interface driver dvb_usb_digitv
[   17.747727] usbcore: registered new interface driver dvb_usb_cxusb
[   17.750093] usbcore: registered new interface driver dvb_usb_ttusb2
[   17.752499] usbcore: registered new interface driver dvb_usb_dib0700
[   17.754693] usbcore: registered new interface driver opera1
[   17.756933] usbcore: registered new interface driver dvb_usb_af9005
[   17.759273] usbcore: registered new interface driver dvb_usb_anysee
[   17.761574] usbcore: registered new interface driver dw2102
[   17.763801] usbcore: registered new interface driver dvb_usb_dtv5100
[   17.766149] usbcore: registered new interface driver dvb_usb_af9015
[   17.768402] usbcore: registered new interface driver cinergyT2
[   17.770469] usbcore: registered new interface driver dvb_usb_ce6230
[   17.772754] usbcore: registered new interface driver dvb_usb_friio
[   17.773080] input: ImExPS/2 Generic Explorer Mouse as /devices/platform/i8042/serio1/input/input5
[   17.777949] usbcore: registered new interface driver dvb_usb_ec168
[   17.780112] usbcore: registered new interface driver dvb_usb_az6027
[   17.782207] usbcore: registered new interface driver LME2510C_DVB-S
[   17.800202] usbcore: registered new interface driver dvb_usb_technisat_usb2
[   17.802462] usbcore: registered new interface driver it913x
[   17.804759] usbcore: registered new interface driver smsusb
[   17.805942] smssdio: Siano SMS1xxx SDIO driver
[   17.806931] smssdio: Copyright Pierre Ossman
[   17.808398] nGene PCIE bridge driver, Copyright (C) 2005-2007 Micronas
[   17.809883] pps_ldisc: PPS line discipline registered
[   17.810968] pps_parport: parallel port PPS client
[   17.812039] parport0: cannot grant exclusive access for device pps_parport
[   17.813443] pps_parport: couldn't register with parport0
[   17.814571] Driver for 1-wire Dallas network protocol.
[   17.816033] usbcore: registered new interface driver DS9490R
[   17.817358] 1-Wire driver for the DS2760 battery monitor  chip  - (c) 2004-2005, Szabolcs Gyurko
[   17.819533] i2c-core: driver [max17040] using legacy suspend method
[   17.820927] i2c-core: driver [max17040] using legacy resume method
[   19.108119] i2c i2c-0: detect fail: address match, 0x2c
[   19.124134] i2c i2c-0: detect fail: address match, 0x2d
[   19.140139] i2c i2c-0: detect fail: address match, 0x2e
[   19.156116] i2c i2c-0: detect fail: address match, 0x2f
[   19.420138] applesmc: supported laptop not found!
[   19.421763] applesmc: driver init failed (ret=-19)!
[   27.764387] pc87360: PC8736x not detected, module not inserted
[   28.268668] usbcore: registered new interface driver pcwd_usb
[   28.270533] acquirewdt: WDT driver for Acquire single board computer initialising
[   28.273530] acquirewdt: I/O address 0x0043 already in use
[   28.275325] acquirewdt: probe of acquirewdt failed with error -5
[   28.277367] advantechwdt: WDT driver for Advantech single board computer initialising
[   28.280837] advantechwdt: initialized. timeout=60 sec (nowayout=0)
[   28.282835] alim7101_wdt: Steve Hill <steve@navaho.co.uk>
[   28.284743] alim7101_wdt: ALi M7101 PMU not present - WDT not set
[   28.286766] sp5100_tco: SP5100 TCO WatchDog Timer Driver v0.01
[   28.289183] sc520_wdt: cannot register miscdev on minor=130 (err=-16)
[   28.291370] eurotechwdt: can't misc_register on minor=130
[   28.293312] ib700wdt: WDT driver for IB700 single board computer initialising
[   28.295858] ib700wdt: START method I/O 443 is not available
[   28.297724] ib700wdt: probe of ib700wdt failed with error -5
[   28.299588] wafer5823wdt: WDT driver for Wafer 5823 single board computer initialising
[   28.302203] wafer5823wdt: I/O address 0x0443 already in use
[   28.304231] i6300esb: Intel 6300ESB WatchDog Timer Driver v0.05
[   28.306460] i6300esb: cannot register miscdev on minor=130 (err=-16)
[   28.308702] i6300ESB timer: probe of 0000:00:0a.0 failed with error -16
[   28.310881] iTCO_wdt: Intel TCO WatchDog Timer Driver v1.07
[   28.312733] iTCO_vendor_support: vendor-support=0
[   28.314046] it87_wdt: no device
[   28.315477] sc1200wdt: build 20020303
[   28.317032] sc1200wdt: io parameter must be specified
[   28.318775] pc87413_wdt: Version 1.1 at io 0x2E
[   28.320420] pc87413_wdt: cannot register miscdev on minor=130 (err=-16)
[   28.322546] nv_tco: NV TCO WatchDog Timer Driver v0.01
[   28.324776] sbc60xxwdt: I/O address 0x0443 already in use
[   28.326623] sbc8360: failed to register misc device
[   28.328418] cpu5wdt: misc_register failed
[   28.329936] smsc37b787_wdt: SMsC 37B787 watchdog component driver 1.1 initialising...
[   28.333920] smsc37b787_wdt: Unable to register miscdev on minor 130
[   28.335940] w83627hf_wdt: WDT driver for the Winbond(TM) W83627HF/THF/HG/DHG Super I/O chip initialising
[   28.339141] w83627hf_wdt: Watchdog already running. Resetting timeout to 60 sec
[   28.341835] w83627hf_wdt: cannot register miscdev on minor=130 (err=-16)
[   28.344045] w83697hf_wdt: WDT driver for W83697HF/HG initializing
[   28.346021] w83697hf_wdt: watchdog not found at address 0x2e
[   28.347872] w83697hf_wdt: No W83697HF/HG could be found
[   28.349707] w83697ug_wdt: WDT driver for the Winbond(TM) W83697UG/UF Super I/O chip initialising
[   28.352748] w83697ug_wdt: No W83697UG/UF could be found
[   28.354559] w83877f_wdt: I/O address 0x0443 already in use
[   28.356542] w83977f_wdt: driver v1.00
[   28.357907] w83977f_wdt: cannot register miscdev on minor=130 (err=-16)
[   28.360040] machzwd: MachZ ZF-Logic Watchdog driver initializing
[   28.361995] machzwd: no ZF-Logic found
[   28.363390] sbc_epx_c3: cannot register miscdev on minor=130 (err=-16)
[   28.365753] watchdog: Software Watchdog: cannot register miscdev on minor=130 (err=-16).
[   28.368606] watchdog: Software Watchdog: a legacy watchdog module is probably present.
[   28.371789] softdog: Software Watchdog Timer: 0.08 initialized. soft_noboot=0 soft_margin=60 sec soft_panic=0 (nowayout=0)
[   28.375397] md: linear personality registered for level -1
[   28.377337] md: raid0 personality registered for level 0
[   28.379144] md: raid1 personality registered for level 1
[   28.381039] md: raid10 personality registered for level 10
[   28.382828] md: raid6 personality registered for level 6
[   28.384781] md: raid5 personality registered for level 5
[   28.386550] md: raid4 personality registered for level 4
[   28.388416] md: multipath personality registered for level -4
[   28.390295] md: faulty personality registered for level -5
[   28.392882] device-mapper: uevent: version 1.0.3
[   28.395199] device-mapper: ioctl: 4.22.0-ioctl (2011-10-19) initialised: dm-devel@redhat.com
[   28.399729] device-mapper: multipath: version 1.4.0 loaded
[   28.401612] device-mapper: multipath round-robin: version 1.0.0 loaded
[   28.403708] device-mapper: multipath queue-length: version 0.1.0 loaded
[   28.405898] device-mapper: multipath service-time: version 0.2.0 loaded
[   28.408829] device-mapper: dm-log-userspace: version 1.1.0 loaded
[   28.411226] Bluetooth: Virtual HCI driver ver 1.3
[   28.413331] Bluetooth: HCI UART driver ver 2.2
[   28.414947] Bluetooth: HCI H4 protocol initialized
[   28.416722] Bluetooth: HCI BCSP protocol initialized
[   28.418398] Bluetooth: HCILL protocol initialized
[   28.420093] Bluetooth: HCIATH3K protocol initialized
[   28.421953] usbcore: registered new interface driver bcm203x
[   28.423952] usbcore: registered new interface driver bpa10x
[   28.425999] usbcore: registered new interface driver bfusb
[   28.428266] usbcore: registered new interface driver btusb
[   28.430090] Bluetooth: Generic Bluetooth SDIO driver ver 0.1
[   28.432185] usbcore: registered new interface driver ath3k
[   28.435116] CAPI 2.0 started up with major 68 (middleware)
[   28.437083] Modular ISDN core version 1.1.29
[   28.439088] NET: Registered protocol family 34
[   28.440697] DSP module 2.0
[   28.441693] mISDN_dsp: DSP clocks every 64 samples. This equals 2 jiffies.
[   28.446987] mISDN: Layer-1-over-IP driver Rev. 2.00
[   28.449189] 0 virtual devices registered
[   28.450889] b1pci: revision 1.1.2.2
[   28.452332] b1: revision 1.1.2.2
[   28.453504] b1dma: revision 1.1.2.3
[   28.454800] b1pci: revision 1.1.2.2
[   28.456449] t1pci: revision 1.1.2.2
[   28.457927] c4: revision 1.1.2.2
[   28.459334] mISDN: HFC-multi driver 2.03
[   28.461178] usbcore: registered new interface driver HFC-S_USB
[   28.463079] AVM Fritz PCI driver Rev. 2.3
[   28.464796] Sedlbauer Speedfax+ Driver Rev. 2.0
[   28.466559] Infineon ISDN Driver Rev. 1.0
[   28.468211] Winbond W6692 PCI driver Rev. 2.0
[   28.469888] mISDNipac module version 2.0
[   28.471275] mISDN: ISAR driver Rev. 2.1
[   28.472755] gigaset: Driver for Gigaset 307x
[   28.474262] gigaset: Kernel CAPI interface
[   28.476095] usbcore: registered new interface driver usb_gigaset
[   28.478017] usb_gigaset: USB Driver for Gigaset 307x using M105
[   28.480218] usbcore: registered new interface driver bas_gigaset
[   28.482165] bas_gigaset: USB Driver for Gigaset 307x
[   28.484086] EDAC MC: Ver: 2.1.0
[   28.488234] AMD64 EDAC driver v3.4.0
[   28.489921] cpuidle: using governor ladder
[   28.491357] cpuidle: using governor menu
[   28.493104] sdhci: Secure Digital Host Controller Interface driver
[   28.495101] sdhci: Copyright(c) Pierre Ossman
[   28.496898] wbsd: Winbond W83L51xD SD/MMC card interface driver
[   28.498813] wbsd: Copyright(c) Pierre Ossman
[   28.500797] via_sdmmc: VIA SD/MMC Card Reader driver (C) 2008 VIA Technologies, Inc.
[   28.503644] VUB300 Driver rom wait states = 1C irqpoll timeout = 0400
[   28.506644] usbcore: registered new interface driver vub300
[   28.509165] usbcore: registered new interface driver ushc
[   28.510961] sdhci-pltfm: SDHCI platform and OF driver helper
[   28.514419] leds_ss4200: no LED devices found
[   28.518890] user_mad: couldn't register device number
[   28.520694] user_verbs: couldn't register device number
[   28.522463] ucm: couldn't register device number
[   28.526639] ib_qib: Unable to register ipathfs
[   28.533743] iscsi: registered transport (iser)
[   28.535370] EFI Variables Facility v0.08 2004-May-17
[   28.537935] dcdbas dcdbas: Dell Systems Management Base Driver (version 5.6.0-3.2)
[   28.540679] No iBFT detected.
[   28.546819] usbcore: registered new interface driver usbhid
[   28.548775] usbhid: USB HID core driver
[   28.550554] Easycap version: 0.9.01
[   28.552036] usbcore: registered new interface driver easycap
[   28.554055] usbcore: registered new interface driver lirc_igorplugusb
[   28.556344] usbcore: registered new interface driver lirc_imon
[   28.558388] usbcore: registered new interface driver lirc_sasem
[   28.561005] lirc_serial: port 03f8 already in use
[   28.562619] lirc_serial: use 'setserial /dev/ttySX uart none'
[   28.564588] lirc_serial: or compile the serial port driver as module and
[   28.566722] lirc_serial: make sure this module is loaded first
[   28.568793] lirc_serial: probe of lirc_serial.0 failed with error -16
[   28.571381] platform lirc_serial.0: lirc_dev: driver lirc_serial registered at minor = 1
[   28.574234] lirc_register_driver: dev pointer not filled in!
[   28.576155] lirc_sir: init_chrdev() failed.
[   28.577861] usbcore: registered new interface driver TTUSBIR
[   28.579710] lirc_zilog: Zilog/Hauppauge IR driver initializing
[   28.598799] lirc_zilog: initialization complete
[   28.600727] usbip_core: USB/IP Core v1.0.0
[   28.602614] vhci_hcd vhci_hcd: USB/IP Virtual Host Controller
[   28.605621] vhci_hcd vhci_hcd: new USB bus registered, assigned bus number 1
[   28.610521] usb usb1: New USB device found, idVendor=1d6b, idProduct=0002
[   28.612771] usb usb1: New USB device strings: Mfr=3, Product=2, SerialNumber=1
[   28.615298] usb usb1: Product: USB/IP Virtual Host Controller
[   28.617323] usb usb1: Manufacturer: Linux 3.5.0-rc5+ vhci_hcd
[   28.619202] usb usb1: SerialNumber: vhci_hcd
[   28.622224] hub 1-0:1.0: USB hub found
[   28.623731] hub 1-0:1.0: 8 ports detected
[   28.625990] vhci_hcd: USB/IP 'Virtual' Host Controller (VHCI) Driver v1.0.0
[   28.628570] usbcore: registered new interface driver usbip-host
[   28.630506] usbip_host: USB/IP Host Driver v1.0.0
[   28.632355] usbcore: registered new interface driver prism2_usb
[   28.634420] usbcore: registered new interface driver r8712u
[   28.636383] Initializing Realtek PCIE storage driver...
[   28.638366] zram: num_devices not specified. Using default: 1
[   28.640315] zram: Creating 1 devices ...
[   28.643146] input: Speakup as /devices/virtual/input/input6
[   28.646059] initialized device: /dev/synth, node (MAJOR 10, MINOR 25)
[   28.648616] speakup 3.1.6: initialized
[   28.650018] synth name on entry is: (null)
[   28.651482] Linux telephony interface: v1.00
[   28.653115] ixj driver initialized.
[   28.654906] asus_wmi: Asus Management GUID not found
[   28.656739] asus_wmi: Management GUID not found
[   28.659419] asus_wmi: Management GUID not found
[   28.662047] msi_laptop: driver 0.5 successfully loaded
[   28.664257] compal_laptop: Motherboard not recognized (You could try the module's force-parameter)
[   28.667292] dell_wmi: No known WMI GUID found
[   28.668951] dell_wmi_aio: No known WMI GUID found
[   28.670571] acer_wmi: Acer Laptop ACPI-WMI Extras
[   28.672272] acer_wmi: No or unsupported WMI interface, unable to load
[   28.674387] acerhdf: Acer Aspire One Fan driver, v.0.5.26
[   28.676277] acerhdf: unknown (unsupported) BIOS version Bochs/Bochs/Bochs, please report, aborting!
[   28.679457] hp_accel: driver loaded
[   28.681091] hdaps: supported laptop not found!
[   28.682656] hdaps: driver init failed (ret=-19)!
[   28.685172] fujitsu_laptop: driver 0.6.0 successfully loaded
[   28.687227] msi_wmi: This machine doesn't have MSI-hotkeys through WMI
[   28.689578] topstar_laptop: ACPI extras driver loaded
[   28.691849] intel_oaktrail: Platform not recognized (You could try the module's force-parameter)
[   28.696187] ieee802154hardmac ieee802154hardmac: Added ieee802154 HardMAC hardware
[   28.699308] hv_utils: Registering HyperV Utility Driver
[   28.701167] hv_vmbus: registering driver hv_util
[   28.741411] no UART detected at 0x1
[   28.743484] MTVAP port 0x378 is busy
[   28.745103] snd_mtpav: probe of snd_mtpav failed with error -16
[   28.747549] snd_mts64: probe of snd_mts64.0 failed with error -5
[   28.750182] snd_portman2x4: probe of snd_portman2x4.0 failed with error -5
[   28.752926] Error: Driver 'pcspkr' is already registered, aborting...
[   28.758948] ASIHPI driver 4.10.01
[   28.767809] usbcore: registered new interface driver snd-usb-audio
[   28.770080] usbcore: registered new interface driver snd-ua101
[   28.772197] usbcore: registered new interface driver snd-usb-usx2y
[   28.774367] usbcore: registered new interface driver snd-usb-us122l
[   28.776664] usbcore: registered new interface driver snd-usb-caiaq
[   28.778862] usbcore: registered new interface driver snd-usb-6fire
[   28.781228] oprofile: using NMI interrupt.
[   28.782995] pktgen: Packet Generator for packet performance testing. Version: 2.74
[   28.786792] drop_monitor: Initializing network drop monitor service
[   28.789469] NET: Registered protocol family 26
[   28.791135] GACT probability on
[   28.792474] Mirror/redirect action on
[   28.793843] Simple TC action Loaded
[   28.796098] netem: version 1.3
[   28.797324] u32 classifier
[   28.798436]     Performance counters on
[   28.799820]     input device check on
[   28.801229]     Actions configured
[   28.802622] Netfilter messages via NETLINK v0.30.
[   28.804672] nf_conntrack version 0.5.0 (3360 buckets, 13440 max)
[   28.807703] ctnetlink v0.93: registering with nfnetlink.
[   28.810240] NF_TPROXY: Transparent proxy support initialized, version 4.1.0
[   28.812563] NF_TPROXY: Copyright (c) 2006-2007 BalaBit IT Ltd.
[   28.815294] xt_time: kernel timezone is -0000
[   28.817046] ip_set: protocol 6
[   28.818324] IPVS: Registered protocols (TCP, UDP, SCTP, AH, ESP)
[   28.820584] IPVS: Connection hash table configured (size=4096, memory=64Kbytes)
[   28.823654] IPVS: Creating netns size=3080 id=0
[   28.825471] IPVS: ipvs loaded.
[   28.826731] IPVS: [rr] scheduler registered.
[   28.828331] IPVS: [wrr] scheduler registered.
[   28.829861] IPVS: [lc] scheduler registered.
[   28.831355] IPVS: [wlc] scheduler registered.
[   28.833048] IPVS: [lblc] scheduler registered.
[   28.834721] IPVS: [lblcr] scheduler registered.
[   28.836424] IPVS: [dh] scheduler registered.
[   28.837935] IPVS: [sh] scheduler registered.
[   28.839436] IPVS: [sed] scheduler registered.
[   28.841124] IPVS: [nq] scheduler registered.
[   28.842716] IPVS: [sip] pe registered.
[   28.844227] IPv4 over IPv4 tunneling driver
[   28.846803] gre: GRE over IPv4 demultiplexor driver
[   28.848607] ip_gre: GRE over IPv4 tunneling driver
[   28.851612] ip_tables: (C) 2000-2006 Netfilter Core Team
[   28.853922] ipt_CLUSTERIP: ClusterIP Version 0.8 loaded successfully
[   28.856225] arp_tables: (C) 2002 David S. Miller
[   28.858032] TCP: bic registered
[   28.859393] TCP: cubic registered
[   28.860750] TCP: westwood registered
[   28.862068] TCP: highspeed registered
[   28.863410] TCP: hybla registered
[   28.864774] TCP: htcp registered
[   28.866036] TCP: vegas registered
[   28.867308] TCP: veno registered
[   28.868633] TCP: scalable registered
[   28.869963] TCP: lp registered
[   28.871165] TCP: yeah registered
[   28.872487] TCP: illinois registered
[   28.873803] Initializing XFRM netlink socket
[   28.876330] NET: Registered protocol family 10
[   28.884677] mip6: Mobile IPv6
[   28.886022] ip6_tables: (C) 2000-2006 Netfilter Core Team
[   28.888341] sit: IPv6 over IPv4 tunneling driver
[   28.892245] NET: Registered protocol family 17
[   28.893994] NET: Registered protocol family 15
[   28.895934] Bridge firewalling registered
[   28.897509] Ebtables v2.0 registered
[   28.899447] NET: Registered protocol family 4
[   28.901341] NET: Registered protocol family 5
[   28.906569] NET: Registered protocol family 6
[   28.916390] NET: Registered protocol family 11
[   28.918294] NET: Registered protocol family 3
[   28.919956] can: controller area network core (rev 20120528 abi 9)
[   28.922532] NET: Registered protocol family 29
[   28.924231] can: raw protocol (rev 20120528)
[   28.925840] can: broadcast manager protocol (rev 20120528 t)
[   28.927771] can: netlink gateway (rev 20101209)
[   28.931430] IrCOMM protocol (Dag Brattli)
[   28.944402] RPC: Registered rdma transport module.
[   28.946677] NET: Registered protocol family 33
[   28.948329] Key type rxrpc registered
[   28.949698] Key type rxrpc_s registered
[   28.953316] RxRPC: Registered security type 2 'rxkad'
[   28.955264] lec:lane_module_init: lec.c: initialized
[   28.957185] mpoa:atm_mpoa_init: mpc.c: initialized
[   28.958899] l2tp_core: L2TP core driver, V2.0
[   28.960578] l2tp_ppp: PPPoL2TP kernel driver, V2.0
[   28.962215] l2tp_ip: L2TP IP encapsulation support (L2TPv3)
[   28.964293] l2tp_netlink: L2TP netlink interface
[   28.966075] l2tp_eth: L2TP ethernet pseudowire support (L2TPv3)
[   28.968253] l2tp_debugfs: L2TP debugfs support
[   28.969852] l2tp_ip6: L2TP IP encapsulation support for IPv6 (L2TPv3)
[   28.972077] NET4: DECnet for Linux: V.2.5.68s (C) 1995-2003 Linux DECnet Project Team
[   28.975554] DECnet: Routing cache hash table of 256 buckets, 20Kbytes
[   28.977853] NET: Registered protocol family 12
[   28.979709] NET: Registered protocol family 35
[   28.981748] 8021q: 802.1Q VLAN Support v1.8
[   28.986052] DCCP: Activated CCID 2 (TCP-like)
[   28.987841] DCCP: Activated CCID 3 (TCP-Friendly Rate Control)
[   29.007844] DCCP watch registered (port=0)
[   29.010784] sctp: Hash tables configured (established 1638 bind 1638)
[   29.030810] sctp_probe: probe registered (port=0)
[   29.033354] NET: Registered protocol family 21
[   29.035457] Registered RDS/iwarp transport
[   29.037359] Registered RDS/infiniband transport
[   29.039039] Registered RDS/tcp transport
[   29.040979] lib80211: common routines for IEEE802.11 drivers
[   29.042777] lib80211_crypt: registered algorithm 'NULL'
[   29.044496] lib80211_crypt: registered algorithm 'WEP'
[   29.046197] lib80211_crypt: registered algorithm 'CCMP'
[   29.048274] lib80211_crypt: registered algorithm 'TKIP'
[   29.050357] TIPC: Activated (version 2.0.0)
[   29.053772] NET: Registered protocol family 30
[   29.054788] TIPC: Started in single node mode
[   29.055810] 9pnet: Installing 9P2000 support
[   29.057147] NET: Registered protocol family 36
[   29.058267] Key type dns_resolver registered
[   29.059297] Key type ceph registered
[   29.060248] libceph: loaded (mon/osd proto 15/24, osdmap 5/6 5/6)
[   29.072140] batman_adv: B.A.T.M.A.N. advanced 2012.3.0 (compatibility version 14) loaded
[   29.077271] 
[   29.077271] printing PIC contents
[   29.078528] ... PIC  IMR: ffff
[   29.079291] ... PIC  IRR: 9153
[   29.080143] ... PIC  ISR: 0000
[   29.080923] ... PIC ELCR: 0c00
[   29.081695] printing local APIC contents on CPU#0/0:
[   29.083134] ... APIC ID:      00000000 (0)
[   29.084633] ... APIC VERSION: 00050014
[   29.085695] ... APIC TASKPRI: 00000000 (00)
[   29.085695] ... APIC PROCPRI: 00000000
[   29.085695] ... APIC LDR: 01000000
[   29.085695] ... APIC DFR: ffffffff
[   29.085695] ... APIC SPIV: 000001ff
[   29.085695] ... APIC ISR field:
[   29.085695] 0000000000000000000000000000000000000000000000000000000000000000
[   29.085695] ... APIC TMR field:
[   29.085695] 0000000000000000000000000000000000000000000000000000000000000000
[   29.085695] ... APIC IRR field:
[   29.085695] 0000000000000000000000000000000000000000000000000000000020008000
[   29.085695] ... APIC ESR: 00000000
[   29.085695] ... APIC ICR: 000008fd
[   29.085695] ... APIC ICR2: 02000000
[   29.085695] ... APIC LVTT: 000000ef
[   29.085695] ... APIC LVTPC: 00010000
[   29.085695] ... APIC LVT0: 00010700
[   29.085695] ... APIC LVT1: 00000400
[   29.085695] ... APIC LVTERR: 000000fe
[   29.085695] ... APIC TMICT: 000b8f42
[   29.085695] ... APIC TMCCT: 00000000
[   29.085695] ... APIC TDCR: 00000003
[   29.085695] 
[   29.123857] number of MP IRQ sources: 15.
[   29.125362] number of IO-APIC #2 registers: 24.
[   29.126916] testing the IO APIC.......................
[   29.128785] 
[   29.129589] IO APIC #2......
[   29.130722] .... register #00: 00000000
[   29.132175] .......    : physical APIC id: 00
[   29.133752] .......    : Delivery Type: 0
[   29.135267] .......    : LTS          : 0
[   29.136844] .... register #01: 00170011
[   29.138245] .......     : max redirection entries: 17
[   29.139937] .......     : PRQ implemented: 0
[   29.141521] .......     : IO APIC version: 11
[   29.143047] .... register #02: 00000000
[   29.144567] .......     : arbitration: 00
[   29.146001] .... IRQ redirection table:
[   29.147388]  NR Dst Mask Trig IRR Pol Stat Dmod Deli Vect:
[   29.149333]  00 00  1    0    0   0   0    0    0    00
[   29.151264]  01 03  0    0    0   0   0    1    1    31
[   29.153368]  02 03  0    0    0   0   0    1    1    30
[   29.155309]  03 03  0    0    0   0   0    1    1    33
[   29.157293]  04 03  1    0    0   0   0    1    1    34
[   29.159201]  05 03  1    1    0   0   0    1    1    35
[   29.161176]  06 03  0    0    0   0   0    1    1    36
[   29.163067]  07 03  0    0    0   0   0    1    1    37
[   29.165112]  08 03  0    0    0   0   0    1    1    38
[   29.167010]  09 03  0    1    0   0   0    1    1    39
[   29.169015]  0a 03  1    1    0   0   0    1    1    3A
[   29.170908]  0b 03  1    1    0   0   0    1    1    3B
[   29.172912]  0c 03  0    0    0   0   0    1    1    3C
[   29.174821]  0d 03  0    0    0   0   0    1    1    3D
[   29.176856]  0e 03  0    0    0   0   0    1    1    3E
[   29.178758]  0f 03  0    0    0   0   0    1    1    3F
[   29.180763]  10 00  1    0    0   0   0    0    0    00
[   29.182698]  11 00  1    0    0   0   0    0    0    00
[   29.184749]  12 00  1    0    0   0   0    0    0    00
[   29.186686]  13 00  1    0    0   0   0    0    0    00
[   29.188680]  14 00  1    0    0   0   0    0    0    00
[   29.190585]  15 00  1    0    0   0   0    0    0    00
[   29.192560]  16 00  1    0    0   0   0    0    0    00
[   29.194496]  17 00  1    0    0   0   0    0    0    00
[   29.196535] IRQ to pin mappings:
[   29.197794] IRQ0 -> 0:2
[   29.199139] IRQ1 -> 0:1
[   29.200587] IRQ3 -> 0:3
[   29.201902] IRQ4 -> 0:4
[   29.203209] IRQ5 -> 0:5
[   29.204618] IRQ6 -> 0:6
[   29.205957] IRQ7 -> 0:7
[   29.207244] IRQ8 -> 0:8
[   29.208729] IRQ9 -> 0:9
[   29.210055] IRQ10 -> 0:10
[   29.211427] IRQ11 -> 0:11
[   29.212907] IRQ12 -> 0:12
[   29.214290] IRQ13 -> 0:13
[   29.215689] IRQ14 -> 0:14
[   29.217150] IRQ15 -> 0:15
[   29.218522] .................................... done.
[   29.221210] PM: Hibernation image not present or could not be loaded.
[   29.223435] registered taskstats version 1
[   29.224954] Running tests on trace events:
[   29.226425] Testing event 9p_client_req: OK
[   29.244970] Testing event 9p_client_res: OK
[   29.261029] Testing event 9p_protocol_dump: OK
[   29.277163] Testing event drv_return_void: OK
[   29.293180] Testing event drv_return_int: OK
[   29.309140] Testing event drv_return_bool: OK
[   29.325151] Testing event drv_return_u64: OK
[   29.341134] Testing event drv_start: OK
[   29.357157] Testing event drv_get_et_strings: OK
[   29.373183] Testing event drv_get_et_sset_count: OK
[   29.389115] Testing event drv_get_et_stats: OK
[   29.405113] Testing event drv_suspend: OK
[   29.421156] Testing event drv_resume: OK
[   29.437124] Testing event drv_set_wakeup: OK
[   29.453168] Testing event drv_stop: OK
[   29.469177] Testing event drv_add_interface: OK
[   29.485182] Testing event drv_change_interface: OK
[   29.500781] Testing event drv_remove_interface: OK
[   29.516726] Testing event drv_config: OK
[   29.532782] Testing event drv_bss_info_changed: OK
[   29.548790] Testing event drv_prepare_multicast: OK
[   29.564779] Testing event drv_configure_filter: OK
[   29.580730] Testing event drv_set_tim: OK
[   29.596726] Testing event drv_set_key: OK
[   29.612723] Testing event drv_update_tkip_key: OK
[   29.628727] Testing event drv_hw_scan: OK
[   29.644714] Testing event drv_cancel_hw_scan: OK
[   29.660722] Testing event drv_sched_scan_start: OK
[   29.676724] Testing event drv_sched_scan_stop: OK
[   29.692711] Testing event drv_sw_scan_start: OK
[   29.708727] Testing event drv_sw_scan_complete: OK
[   29.724725] Testing event drv_get_stats: OK
[   29.740782] Testing event drv_get_tkip_seq: OK
[   29.756912] Testing event drv_set_frag_threshold: OK
[   29.772905] Testing event drv_set_rts_threshold: OK
[   29.788830] Testing event drv_set_coverage_class: OK
[   29.804905] Testing event drv_sta_notify: OK
[   29.820934] Testing event drv_sta_state: OK
[   29.836933] Testing event drv_sta_rc_update: OK
[   29.852733] Testing event drv_sta_add: OK
[   29.869164] Testing event drv_sta_remove: OK
[   29.884788] Testing event drv_conf_tx: OK
[   29.901119] Testing event drv_get_tsf: OK
[   29.916710] Testing event drv_set_tsf: OK
[   29.932806] Testing event drv_reset_tsf: OK
[   29.948997] Testing event drv_tx_last_beacon: OK
[   29.964710] Testing event drv_ampdu_action: OK
[   29.981119] Testing event drv_get_survey: OK
[   29.996710] Testing event drv_flush: OK
[   30.012891] Testing event drv_channel_switch: OK
[   30.029187] Testing event drv_set_antenna: OK
[   30.044883] Testing event drv_get_antenna: OK
[   30.060895] Testing event drv_remain_on_channel: OK
[   30.076903] Testing event drv_cancel_remain_on_channel: OK
[   30.092885] Testing event drv_offchannel_tx: OK
[   30.108895] Testing event drv_set_ringparam: OK
[   30.124895] Testing event drv_get_ringparam: OK
[   30.140878] Testing event drv_tx_frames_pending: OK
[   30.156949] Testing event drv_offchannel_tx_cancel_wait: OK
[   30.172896] Testing event drv_set_bitrate_mask: OK
[   30.188879] Testing event drv_set_rekey_data: OK
[   30.204890] Testing event drv_rssi_callback: OK
[   30.220902] Testing event drv_release_buffered_frames: OK
[   30.236819] Testing event drv_allow_buffered_frames: OK
[   30.252892] Testing event drv_get_rssi: OK
[   30.268890] Testing event api_start_tx_ba_session: OK
[   30.284889] Testing event api_start_tx_ba_cb: OK
[   30.300890] Testing event api_stop_tx_ba_session: OK
[   30.316897] Testing event api_stop_tx_ba_cb: OK
[   30.332889] Testing event api_restart_hw: OK
[   30.348882] Testing event api_beacon_loss: OK
[   30.364889] Testing event api_connection_loss: OK
[   30.380888] Testing event api_cqm_rssi_notify: OK
[   30.396898] Testing event api_scan_completed: OK
[   30.412888] Testing event api_sched_scan_results: OK
[   30.428888] Testing event api_sched_scan_stopped: OK
[   30.444900] Testing event api_sta_block_awake: OK
[   30.460888] Testing event api_chswitch_done: OK
[   30.476881] Testing event api_ready_on_channel: OK
[   30.492867] Testing event api_remain_on_channel_expired: OK
[   30.508883] Testing event api_gtk_rekey_notify: OK
[   30.524880] Testing event api_enable_rssi_reports: OK
[   30.540869] Testing event api_eosp: OK
[   30.556878] Testing event wake_queue: OK
[   30.572831] Testing event stop_queue: OK
[   30.598944] Testing event rpc_call_status: OK
[   30.617111] Testing event rpc_bind_status: OK
[   30.632843] Testing event rpc_connect_status: OK
[   30.648898] Testing event rpc_task_begin: OK
[   30.664773] Testing event rpc_task_run_action: OK
[   30.680914] Testing event rpc_task_complete: OK
[   30.696910] Testing event rpc_task_sleep: OK
[   30.712783] Testing event rpc_task_wakeup: OK
[   30.728914] Testing event kfree_skb: OK
[   30.744848] Testing event consume_skb: OK
[   30.760780] Testing event skb_copy_datagram_iovec: OK
[   30.776916] Testing event net_dev_xmit: OK
[   30.792844] Testing event net_dev_queue: [   30.808317] vhci_hcd: changed 0
OK
[   30.809952] Testing event netif_receive_skb: OK
[   30.825030] Testing event netif_rx: OK
[   30.840895] Testing event napi_poll: OK
[   30.856926] Testing event sock_rcvqueue_full: OK
[   30.872861] Testing event sock_exceed_buf_limit: OK
[   30.888849] Testing event udp_fail_queue_rcv_skb: OK
[   30.904910] Testing event hda_send_cmd: OK
[   30.920797] Testing event hda_get_response: OK
[   30.936833] Testing event hda_bus_reset: OK
[   30.952834] Testing event hda_power_down: OK
[   30.968784] Testing event hda_power_up: OK
[   30.984835] Testing event hda_unsol_event: OK
[   31.000905] Testing event scsi_dispatch_cmd_start: OK
[   31.016800] Testing event scsi_dispatch_cmd_error: OK
[   31.032863] Testing event scsi_dispatch_cmd_done: OK
[   31.048775] Testing event scsi_dispatch_cmd_timeout: OK
[   31.064910] Testing event scsi_eh_wakeup: OK
[   31.080904] Testing event regmap_reg_write: OK
[   31.096902] Testing event regmap_reg_read: OK
[   31.112901] Testing event regmap_reg_read_cache: OK
[   31.128852] Testing event regmap_hw_read_start: OK
[   31.144884] Testing event regmap_hw_read_done: OK
[   31.160841] Testing event regmap_hw_write_start: OK
[   31.176833] Testing event regmap_hw_write_done: OK
[   31.192887] Testing event regcache_sync: OK
[   31.208836] Testing event regmap_cache_only: OK
[   31.224828] Testing event regmap_cache_bypass: OK
[   31.240829] Testing event i915_gem_object_create: OK
[   31.256898] Testing event i915_gem_object_bind: OK
[   31.272851] Testing event i915_gem_object_unbind: OK
[   31.288874] Testing event i915_gem_object_change_domain: OK
[   31.304835] Testing event i915_gem_object_pwrite: OK
[   31.320824] Testing event i915_gem_object_pread: OK
[   31.336769] Testing event i915_gem_object_fault: OK
[   31.352769] Testing event i915_gem_object_clflush: OK
[   31.368763] Testing event i915_gem_object_destroy: OK
[   31.384794] Testing event i915_gem_evict: OK
[   31.400899] Testing event i915_gem_evict_everything: OK
[   31.416846] Testing event i915_gem_ring_dispatch: OK
[   31.432769] Testing event i915_gem_ring_flush: OK
[   31.448833] Testing event i915_gem_request_add: OK
[   31.464829] Testing event i915_gem_request_complete: OK
[   31.480837] Testing event i915_gem_request_retire: OK
[   31.496883] Testing event i915_gem_request_wait_begin: OK
[   31.512815] Testing event i915_gem_request_wait_end: OK
[   31.528765] Testing event i915_ring_wait_begin: OK
[   31.544874] Testing event i915_ring_wait_end: OK
[   31.560880] Testing event i915_flip_request: OK
[   31.576838] Testing event i915_flip_complete: OK
[   31.592870] Testing event i915_reg_rw: OK
[   31.608842] Testing event radeon_bo_create: OK
[   31.624874] Testing event radeon_fence_emit: OK
[   31.640819] Testing event radeon_fence_retire: OK
[   31.656930] Testing event radeon_fence_wait_begin: OK
[   31.672766] Testing event radeon_fence_wait_end: OK
[   31.688817] Testing event drm_vblank_event: OK
[   31.704764] Testing event drm_vblank_event_queued: OK
[   31.720886] Testing event drm_vblank_event_delivered: OK
[   31.736829] Testing event regulator_enable: OK
[   31.752776] Testing event regulator_enable_delay: OK
[   31.768765] Testing event regulator_enable_complete: OK
[   31.784767] Testing event regulator_disable: OK
[   31.800880] Testing event regulator_disable_complete: OK
[   31.816857] Testing event regulator_set_voltage: OK
[   31.832870] Testing event regulator_set_voltage_complete: OK
[   31.848813] Testing event gpio_direction: OK
[   31.864798] Testing event gpio_value: OK
[   31.880802] Testing event block_rq_abort: OK
[   31.896863] Testing event block_rq_requeue: OK
[   31.912790] Testing event block_rq_complete: OK
[   31.928790] Testing event block_rq_insert: OK
[   31.944809] Testing event block_rq_issue: OK
[   31.960784] Testing event block_bio_bounce: OK
[   31.976789] Testing event block_bio_complete: OK
[   31.992774] Testing event block_bio_backmerge: OK
[   32.008788] Testing event block_bio_frontmerge: OK
[   32.024801] Testing event block_bio_queue: OK
[   32.040779] Testing event block_getrq: OK
[   32.056803] Testing event block_sleeprq: OK
[   32.072799] Testing event block_plug: OK
[   32.088777] Testing event block_unplug: OK
[   32.104796] Testing event block_split: OK
[   32.120834] Testing event block_bio_remap: OK
[   32.136781] Testing event block_rq_remap: OK
[   32.152868] Testing event gfs2_glock_state_change: OK
[   32.168874] Testing event gfs2_glock_put: OK
[   32.184795] Testing event gfs2_demote_rq: OK
[   32.200789] Testing event gfs2_promote: OK
[   32.216803] Testing event gfs2_glock_queue: OK
[   32.232866] Testing event gfs2_glock_lock_time: OK
[   32.248825] Testing event gfs2_pin: OK
[   32.264791] Testing event gfs2_log_flush: OK
[   32.280789] Testing event gfs2_log_blocks: OK
[   32.296794] Testing event gfs2_ail_flush: OK
[   32.312807] Testing event gfs2_bmap: OK
[   32.328795] Testing event gfs2_block_alloc: OK
[   32.344779] Testing event btrfs_transaction_commit: OK
[   32.360804] Testing event btrfs_inode_new: OK
[   32.376799] Testing event btrfs_inode_request: OK
[   32.392848] Testing event btrfs_inode_evict: OK
[   32.408813] Testing event btrfs_get_extent: OK
[   32.424855] Testing event btrfs_ordered_extent_add: OK
[   32.440778] Testing event btrfs_ordered_extent_remove: OK
[   32.456807] Testing event btrfs_ordered_extent_start: OK
[   32.472787] Testing event btrfs_ordered_extent_put: OK
[   32.488793] Testing event __extent_writepage: OK
[   32.504782] Testing event btrfs_writepage_end_io_hook: OK
[   32.520800] Testing event btrfs_sync_file: OK
[   32.536782] Testing event btrfs_sync_fs: OK
[   32.552799] Testing event btrfs_delayed_tree_ref: OK
[   32.568791] Testing event btrfs_delayed_data_ref: OK
[   32.584797] Testing event btrfs_delayed_ref_head: OK
[   32.600801] Testing event btrfs_chunk_alloc: OK
[   32.616790] Testing event btrfs_chunk_free: OK
[   32.632796] Testing event btrfs_cow_block: OK
[   32.648788] Testing event btrfs_space_reservation: OK
[   32.664797] Testing event btrfs_reserved_extent_alloc: OK
[   32.680789] Testing event btrfs_reserved_extent_free: OK
[   32.696801] Testing event find_free_extent: OK
[   32.712793] Testing event btrfs_reserve_extent: OK
[   32.728790] Testing event btrfs_reserve_extent_cluster: OK
[   32.744780] Testing event btrfs_find_cluster: OK
[   32.760789] Testing event btrfs_failed_cluster_setup: OK
[   32.776791] Testing event btrfs_setup_cluster: OK
[   32.792778] Testing event alloc_extent_state: OK
[   32.808916] Testing event free_extent_state: [   32.824089] vhci_hcd: changed 0
OK
[   32.825926] Testing event ocfs2_adjust_rightmost_branch: OK
[   32.840904] Testing event ocfs2_rotate_tree_right: OK
[   32.856797] Testing event ocfs2_append_rec_to_path: OK
[   32.872975] Testing event ocfs2_insert_extent_start: OK
[   32.888836] Testing event ocfs2_add_clusters_in_btree: OK
[   32.904793] Testing event ocfs2_num_free_extents: OK
[   32.920808] Testing event ocfs2_complete_edge_insert: OK
[   32.936789] Testing event ocfs2_grow_tree: OK
[   32.952792] Testing event ocfs2_rotate_subtree: OK
[   32.968799] Testing event ocfs2_insert_extent: OK
[   32.984795] Testing event ocfs2_split_extent: OK
[   33.000810] Testing event ocfs2_remove_extent: OK
[   33.016789] Testing event ocfs2_commit_truncate: OK
[   33.032835] Testing event ocfs2_validate_extent_block: OK
[   33.048794] Testing event ocfs2_rotate_leaf: OK
[   33.064788] Testing event ocfs2_add_clusters_in_btree_ret: OK
[   33.080792] Testing event ocfs2_mark_extent_written: OK
[   33.096795] Testing event ocfs2_truncate_log_append: OK
[   33.112787] Testing event ocfs2_replay_truncate_records: OK
[   33.128798] Testing event ocfs2_flush_truncate_log: OK
[   33.144775] Testing event ocfs2_begin_truncate_log_recovery: OK
[   33.160801] Testing event ocfs2_truncate_log_recovery_num: OK
[   33.176796] Testing event ocfs2_complete_truncate_log_recovery: OK
[   33.192821] Testing event ocfs2_free_cached_blocks: OK
[   33.208787] Testing event ocfs2_cache_cluster_dealloc: OK
[   33.224803] Testing event ocfs2_run_deallocs: OK
[   33.240784] Testing event ocfs2_cache_block_dealloc: OK
[   33.256800] Testing event ocfs2_trim_extent: OK
[   33.272803] Testing event ocfs2_trim_group: OK
[   33.288788] Testing event ocfs2_trim_fs: OK
[   33.304797] Testing event ocfs2_la_set_sizes: OK
[   33.320813] Testing event ocfs2_alloc_should_use_local: OK
[   33.336826] Testing event ocfs2_load_local_alloc: OK
[   33.352797] Testing event ocfs2_begin_local_alloc_recovery: OK
[   33.368796] Testing event ocfs2_reserve_local_alloc_bits: OK
[   33.384820] Testing event ocfs2_local_alloc_count_bits: OK
[   33.400804] Testing event ocfs2_local_alloc_find_clear_bits_search_bitmap: OK
[   33.416794] Testing event ocfs2_local_alloc_find_clear_bits: OK
[   33.443858] Testing event ocfs2_sync_local_to_main: OK
[   33.460859] Testing event ocfs2_sync_local_to_main_free: OK
[   33.476846] Testing event ocfs2_local_alloc_new_window: OK
[   33.492840] Testing event ocfs2_local_alloc_new_window_result: OK
[   33.508824] Testing event ocfs2_update_last_group_and_inode: OK
[   33.524840] Testing event ocfs2_group_extend: OK
[   33.540830] Testing event ocfs2_group_add: OK
[   33.556841] Testing event ocfs2_validate_group_descriptor: OK
[   33.572844] Testing event ocfs2_block_group_alloc_contig: OK
[   33.588812] Testing event ocfs2_block_group_alloc_discontig: OK
[   33.605328] Testing event ocfs2_block_group_alloc: OK
[   33.620813] Testing event ocfs2_reserve_suballoc_bits_nospc: OK
[   33.636828] Testing event ocfs2_reserve_suballoc_bits_no_new_group: OK
[   33.652836] Testing event ocfs2_reserve_new_inode_new_group: OK
[   33.668839] Testing event ocfs2_block_group_set_bits: OK
[   33.684838] Testing event ocfs2_relink_block_group: OK
[   33.700839] Testing event ocfs2_cluster_group_search_wrong_max_bits: OK
[   33.716830] Testing event ocfs2_cluster_group_search_max_block: OK
[   33.732835] Testing event ocfs2_block_group_search_max_block: OK
[   33.748829] Testing event ocfs2_search_chain_begin: OK
[   33.764841] Testing event ocfs2_search_chain_succ: OK
[   33.780870] Testing event ocfs2_search_chain_end: OK
[   33.796839] Testing event ocfs2_claim_suballoc_bits: OK
[   33.812817] Testing event ocfs2_claim_new_inode_at_loc: OK
[   33.828875] Testing event ocfs2_block_group_clear_bits: OK
[   33.844835] Testing event ocfs2_free_suballoc_bits: OK
[   33.860859] Testing event ocfs2_free_clusters: OK
[   33.877190] Testing event ocfs2_get_suballoc_slot_bit: OK
[   33.893139] Testing event ocfs2_test_suballoc_bit: OK
[   33.909148] Testing event ocfs2_test_inode_bit: OK
[   33.925121] Testing event ocfs2_validate_refcount_block: OK
[   33.941142] Testing event ocfs2_purge_refcount_trees: OK
[   33.957171] Testing event ocfs2_create_refcount_tree: OK
[   33.973172] Testing event ocfs2_create_refcount_tree_blkno: OK
[   33.989150] Testing event ocfs2_change_refcount_rec: OK
[   34.005145] Testing event ocfs2_expand_inline_ref_root: OK
[   34.020605] Testing event ocfs2_divide_leaf_refcount_block: OK
[   34.037170] Testing event ocfs2_new_leaf_refcount_block: OK
[   34.052588] Testing event ocfs2_insert_refcount_rec: OK
[   34.069654] Testing event ocfs2_split_refcount_rec: OK
[   34.085150] Testing event ocfs2_split_refcount_rec_insert: OK
[   34.101151] Testing event ocfs2_increase_refcount_begin: OK
[   34.117148] Testing event ocfs2_increase_refcount_change: OK
[   34.133168] Testing event ocfs2_increase_refcount_insert: OK
[   34.149162] Testing event ocfs2_increase_refcount_split: OK
[   34.165137] Testing event ocfs2_remove_refcount_extent: OK
[   34.181164] Testing event ocfs2_restore_refcount_block: OK
[   34.197160] Testing event ocfs2_decrease_refcount_rec: OK
[   34.213160] Testing event ocfs2_decrease_refcount: OK
[   34.229160] Testing event ocfs2_mark_extent_refcounted: OK
[   34.245160] Testing event ocfs2_calc_refcount_meta_credits: OK
[   34.261160] Testing event ocfs2_calc_refcount_meta_credits_iterate: OK
[   34.277160] Testing event ocfs2_add_refcount_flag: OK
[   34.293161] Testing event ocfs2_prepare_refcount_change_for_del: OK
[   34.309162] Testing event ocfs2_lock_refcount_allocators: OK
[   34.325154] Testing event ocfs2_duplicate_clusters_by_page: OK
[   34.341165] Testing event ocfs2_duplicate_clusters_by_jbd: OK
[   34.357161] Testing event ocfs2_clear_ext_refcount: OK
[   34.373155] Testing event ocfs2_replace_clusters: OK
[   34.389162] Testing event ocfs2_make_clusters_writable: OK
[   34.405150] Testing event ocfs2_refcount_cow_hunk: OK
[   34.421184] Testing event ocfs2_symlink_get_block: OK
[   34.437160] Testing event ocfs2_get_block: OK
[   34.453160] Testing event ocfs2_get_block_end: OK
[   34.469155] Testing event ocfs2_readpage: OK
[   34.485158] Testing event ocfs2_writepage: OK
[   34.501159] Testing event ocfs2_bmap: OK
[   34.517159] Testing event ocfs2_try_to_write_inline_data: OK
[   34.533154] Testing event ocfs2_write_begin_nolock: OK
[   34.549154] Testing event ocfs2_write_end_inline: OK
[   34.565153] Testing event ocfs2_fault: OK
[   34.581161] Testing event ocfs2_file_open: OK
[   34.597149] Testing event ocfs2_file_release: OK
[   34.613153] Testing event ocfs2_sync_file: OK
[   34.628920] Testing event ocfs2_file_aio_write: OK
[   34.644887] Testing event ocfs2_file_splice_write: OK
[   34.660861] Testing event ocfs2_file_splice_read: OK
[   34.676899] Testing event ocfs2_file_aio_read: OK
[   34.692864] Testing event ocfs2_truncate_file: OK
[   34.708849] Testing event ocfs2_truncate_file_error: OK
[   34.724854] Testing event ocfs2_extend_allocation: OK
[   34.740836] Testing event ocfs2_extend_allocation_end: OK
[   34.756911] Testing event ocfs2_write_zero_page: OK
[   34.772896] Testing event ocfs2_zero_extend_range: OK
[   34.788895] Testing event ocfs2_zero_extend: OK
[   34.804877] Testing event ocfs2_setattr: OK
[   34.820944] Testing event ocfs2_write_remove_suid: OK
[   34.836876] Testing event ocfs2_zero_partial_clusters: [   34.840109] vhci_hcd: changed 0
OK
[   34.852900] Testing event ocfs2_zero_partial_clusters_range1: OK
[   34.868869] Testing event ocfs2_zero_partial_clusters_range2: OK
[   34.884904] Testing event ocfs2_remove_inode_range: OK
[   34.900909] Testing event ocfs2_prepare_inode_for_write: OK
[   34.916879] Testing event generic_file_aio_read_ret: OK
[   34.932851] Testing event ocfs2_iget_begin: OK
[   34.948871] Testing event ocfs2_iget5_locked: OK
[   34.964894] Testing event ocfs2_iget_end: OK
[   34.980892] Testing event ocfs2_find_actor: OK
[   34.996863] Testing event ocfs2_populate_inode: OK
[   35.012890] Testing event ocfs2_read_locked_inode: OK
[   35.028877] Testing event ocfs2_check_orphan_recovery_state: OK
[   35.044837] Testing event ocfs2_validate_inode_block: OK
[   35.060874] Testing event ocfs2_inode_is_valid_to_delete: OK
[   35.076862] Testing event ocfs2_query_inode_wipe_begin: OK
[   35.092868] Testing event ocfs2_query_inode_wipe_succ: OK
[   35.108860] Testing event ocfs2_query_inode_wipe_end: OK
[   35.124869] Testing event ocfs2_cleanup_delete_inode: OK
[   35.140835] Testing event ocfs2_delete_inode: OK
[   35.156896] Testing event ocfs2_clear_inode: OK
[   35.172896] Testing event ocfs2_drop_inode: OK
[   35.188843] Testing event ocfs2_inode_revalidate: OK
[   35.204892] Testing event ocfs2_mark_inode_dirty: OK
[   35.220894] Testing event ocfs2_read_virt_blocks: OK
[   35.236868] Testing event ocfs2_refresh_slot_info: OK
[   35.252890] Testing event ocfs2_map_slot_buffers: OK
[   35.268897] Testing event ocfs2_map_slot_buffers_block: OK
[   35.284906] Testing event ocfs2_find_slot: OK
[   35.300870] Testing event ocfs2_do_node_down: OK
[   35.316881] Testing event ocfs2_remount: OK
[   35.332882] Testing event ocfs2_fill_super: OK
[   35.348890] Testing event ocfs2_parse_options: OK
[   35.364868] Testing event ocfs2_put_super: OK
[   35.380872] Testing event ocfs2_statfs: OK
[   35.396894] Testing event ocfs2_dismount_volume: OK
[   35.412863] Testing event ocfs2_initialize_super: OK
[   35.428863] Testing event ocfs2_validate_xattr_block: OK
[   35.444908] Testing event ocfs2_xattr_extend_allocation: OK
[   35.460890] Testing event ocfs2_init_xattr_set_ctxt: OK
[   35.476874] Testing event ocfs2_xattr_bucket_find: OK
[   35.493146] Testing event ocfs2_xattr_index_block_find: OK
[   35.508807] Testing event ocfs2_xattr_index_block_find_rec: OK
[   35.524880] Testing event ocfs2_iterate_xattr_buckets: OK
[   35.540816] Testing event ocfs2_iterate_xattr_bucket: OK
[   35.556823] Testing event ocfs2_cp_xattr_block_to_bucket_begin: OK
[   35.573146] Testing event ocfs2_cp_xattr_block_to_bucket_end: OK
[   35.589096] Testing event ocfs2_xattr_create_index_block_begin: OK
[   35.605109] Testing event ocfs2_xattr_create_index_block: OK
[   35.621150] Testing event ocfs2_defrag_xattr_bucket: OK
[   35.637103] Testing event ocfs2_mv_xattr_bucket_cross_cluster: OK
[   35.653108] Testing event ocfs2_divide_xattr_bucket_begin: OK
[   35.669108] Testing event ocfs2_divide_xattr_bucket_move: OK
[   35.685113] Testing event ocfs2_cp_xattr_bucket: OK
[   35.701110] Testing event ocfs2_mv_xattr_buckets: OK
[   35.717106] Testing event ocfs2_adjust_xattr_cross_cluster: OK
[   35.733101] Testing event ocfs2_add_new_xattr_cluster_begin: OK
[   35.749116] Testing event ocfs2_add_new_xattr_cluster: OK
[   35.765113] Testing event ocfs2_add_new_xattr_cluster_insert: OK
[   35.781113] Testing event ocfs2_extend_xattr_bucket: OK
[   35.797108] Testing event ocfs2_add_new_xattr_bucket: OK
[   35.812800] Testing event ocfs2_xattr_bucket_value_truncate: OK
[   35.828831] Testing event ocfs2_rm_xattr_cluster: OK
[   35.844787] Testing event ocfs2_reflink_xattr_header: OK
[   35.860819] Testing event ocfs2_create_empty_xattr_block: OK
[   35.876880] Testing event ocfs2_xattr_set_entry_bucket: OK
[   35.893070] Testing event ocfs2_xattr_set_entry_index_block: OK
[   35.909111] Testing event ocfs2_xattr_bucket_value_refcount: OK
[   35.924781] Testing event ocfs2_reflink_xattr_buckets: OK
[   35.940777] Testing event ocfs2_reflink_xattr_rec: OK
[   35.956796] Testing event ocfs2_resv_insert: OK
[   35.972841] Testing event ocfs2_resmap_find_free_bits_begin: OK
[   35.988902] Testing event ocfs2_resmap_find_free_bits_end: OK
[   36.004803] Testing event ocfs2_resv_find_window_begin: OK
[   36.020878] Testing event ocfs2_resv_find_window_prev: OK
[   36.036837] Testing event ocfs2_resv_find_window_next: OK
[   36.052878] Testing event ocfs2_cannibalize_resv_begin: OK
[   36.068853] Testing event ocfs2_cannibalize_resv_end: OK
[   36.084879] Testing event ocfs2_resmap_resv_bits: OK
[   36.100850] Testing event ocfs2_resmap_claimed_bits_begin: OK
[   36.116861] Testing event ocfs2_resmap_claimed_bits_end: OK
[   36.132830] Testing event ocfs2_recover_local_quota_file: OK
[   36.148842] Testing event ocfs2_finish_quota_recovery: OK
[   36.164843] Testing event olq_set_dquot: OK
[   36.180897] Testing event ocfs2_validate_quota_block: OK
[   36.196858] Testing event ocfs2_sync_dquot: OK
[   36.212896] Testing event ocfs2_sync_dquot_helper: OK
[   36.228808] Testing event ocfs2_write_dquot: OK
[   36.244838] Testing event ocfs2_release_dquot: OK
[   36.260893] Testing event ocfs2_acquire_dquot: OK
[   36.276884] Testing event ocfs2_mark_dquot_dirty: OK
[   36.303848] Testing event ocfs2_search_dirblock: OK
[   36.320916] Testing event ocfs2_validate_dir_block: OK
[   36.336880] Testing event ocfs2_find_entry_el: OK
[   36.352887] Testing event ocfs2_dx_dir_search: OK
[   36.368896] Testing event ocfs2_dx_dir_search_leaf_info: OK
[   36.384920] Testing event ocfs2_delete_entry_dx: OK
[   36.400910] Testing event ocfs2_readdir: OK
[   36.416892] Testing event ocfs2_find_files_on_disk: OK
[   36.432841] Testing event ocfs2_check_dir_for_entry: OK
[   36.448907] Testing event ocfs2_dx_dir_attach_index: OK
[   36.464909] Testing event ocfs2_dx_dir_format_cluster: OK
[   36.480882] Testing event ocfs2_dx_dir_index_root_block: OK
[   36.496873] Testing event ocfs2_extend_dir: OK
[   36.512881] Testing event ocfs2_dx_dir_rebalance: OK
[   36.528821] Testing event ocfs2_dx_dir_rebalance_split: OK
[   36.544857] Testing event ocfs2_prepare_dir_for_insert: OK
[   36.560845] Testing event ocfs2_lookup: OK
[   36.576871] Testing event ocfs2_mkdir: OK
[   36.592862] Testing event ocfs2_create: OK
[   36.608884] Testing event ocfs2_unlink: OK
[   36.624862] Testing event ocfs2_symlink_create: OK
[   36.640854] Testing event ocfs2_mv_orphaned_inode_to_new: OK
[   36.656899] Testing event ocfs2_lookup_ret: OK
[   36.672876] Testing event ocfs2_mknod: OK
[   36.688870] Testing event ocfs2_link: OK
[   36.704844] Testing event ocfs2_unlink_noent: OK
[   36.720897] Testing event ocfs2_double_lock: OK
[   36.736888] Testing event ocfs2_double_lock_end: OK
[   36.752893] Testing event ocfs2_rename: OK
[   36.768848] Testing event ocfs2_rename_target_exists: OK
[   36.784887] Testing event ocfs2_rename_disagree: OK
[   36.800859] Testing event ocfs2_rename_over_existing: OK
[   36.816879] Testing event ocfs2_create_symlink_data: OK
[   36.832800] Testing event ocfs2_symlink_begin: OK
[   36.848886] Testing event ocfs2_blkno_stringify: [   36.856144] vhci_hcd: changed 0
OK
[   36.864868] Testing event ocfs2_orphan_add_begin: OK
[   36.880869] Testing event ocfs2_orphan_add_end: OK
[   36.896882] Testing event ocfs2_orphan_del: OK
[   36.912879] Testing event ocfs2_dentry_revalidate: OK
[   36.928833] Testing event ocfs2_dentry_revalidate_negative: OK
[   36.944854] Testing event ocfs2_dentry_revalidate_delete: OK
[   36.960859] Testing event ocfs2_dentry_revalidate_orphaned: OK
[   36.976865] Testing event ocfs2_dentry_revalidate_nofsdata: OK
[   36.992852] Testing event ocfs2_dentry_revalidate_ret: OK
[   37.008883] Testing event ocfs2_find_local_alias: OK
[   37.024927] Testing event ocfs2_dentry_attach_lock: OK
[   37.040912] Testing event ocfs2_dentry_attach_lock_found: OK
[   37.056932] Testing event ocfs2_get_dentry_begin: OK
[   37.072911] Testing event ocfs2_get_dentry_test_bit: OK
[   37.088845] Testing event ocfs2_get_dentry_stale: OK
[   37.104912] Testing event ocfs2_get_dentry_generation: OK
[   37.120868] Testing event ocfs2_get_dentry_end: OK
[   37.136909] Testing event ocfs2_get_parent: OK
[   37.152913] Testing event ocfs2_get_parent_end: OK
[   37.168923] Testing event ocfs2_encode_fh_begin: OK
[   37.184867] Testing event ocfs2_encode_fh_self: OK
[   37.200911] Testing event ocfs2_encode_fh_parent: OK
[   37.216901] Testing event ocfs2_encode_fh_type: OK
[   37.232901] Testing event ocfs2_commit_cache_begin: OK
[   37.248906] Testing event ocfs2_commit_cache_end: OK
[   37.265047] Testing event ocfs2_extend_trans: OK
[   37.281116] Testing event ocfs2_extend_trans_restart: OK
[   37.297105] Testing event ocfs2_journal_access: OK
[   37.312892] Testing event ocfs2_journal_dirty: OK
[   37.328926] Testing event ocfs2_journal_init: OK
[   37.344870] Testing event ocfs2_journal_init_maxlen: OK
[   37.360887] Testing event ocfs2_journal_shutdown: OK
[   37.376869] Testing event ocfs2_journal_shutdown_wait: OK
[   37.392843] Testing event ocfs2_complete_recovery: OK
[   37.408900] Testing event ocfs2_complete_recovery_end: OK
[   37.424862] Testing event ocfs2_complete_recovery_slot: OK
[   37.440903] Testing event ocfs2_recovery_thread_node: OK
[   37.456901] Testing event ocfs2_recovery_thread_end: OK
[   37.472902] Testing event ocfs2_recovery_thread: OK
[   37.488864] Testing event ocfs2_replay_journal_recovered: OK
[   37.504892] Testing event ocfs2_replay_journal_lock_err: OK
[   37.520904] Testing event ocfs2_replay_journal_skip: OK
[   37.536839] Testing event ocfs2_recover_node: OK
[   37.552894] Testing event ocfs2_recover_node_skip: OK
[   37.568898] Testing event ocfs2_mark_dead_nodes: OK
[   37.584898] Testing event ocfs2_queue_orphan_scan_begin: OK
[   37.600891] Testing event ocfs2_queue_orphan_scan_end: OK
[   37.616896] Testing event ocfs2_orphan_filldir: OK
[   37.632889] Testing event ocfs2_recover_orphans: OK
[   37.648894] Testing event ocfs2_recover_orphans_iput: OK
[   37.664906] Testing event ocfs2_wait_on_mount: OK
[   37.680915] Testing event ocfs2_read_blocks_sync: OK
[   37.696912] Testing event ocfs2_read_blocks_sync_jbd: OK
[   37.712916] Testing event ocfs2_read_blocks_from_disk: OK
[   37.728849] Testing event ocfs2_read_blocks_bh: OK
[   37.744859] Testing event ocfs2_read_blocks_end: OK
[   37.760895] Testing event ocfs2_write_block: OK
[   37.776906] Testing event ocfs2_read_blocks_begin: OK
[   37.792893] Testing event ocfs2_purge_copied_metadata_tree: OK
[   37.808873] Testing event ocfs2_metadata_cache_purge: OK
[   37.825128] Testing event ocfs2_buffer_cached_begin: OK
[   37.841131] Testing event ocfs2_buffer_cached_end: OK
[   37.857146] Testing event ocfs2_append_cache_array: OK
[   37.872909] Testing event ocfs2_insert_cache_tree: OK
[   37.888859] Testing event ocfs2_expand_cache: OK
[   37.904874] Testing event ocfs2_set_buffer_uptodate: OK
[   37.920869] Testing event ocfs2_set_buffer_uptodate_begin: OK
[   37.936873] Testing event ocfs2_remove_metadata_array: OK
[   37.952915] Testing event ocfs2_remove_metadata_tree: OK
[   37.968864] Testing event ocfs2_remove_block_from_cache: OK
[   37.985020] Testing event xfs_attr_list_sf: OK
[   38.000899] Testing event xfs_attr_list_sf_all: OK
[   38.016876] Testing event xfs_attr_list_leaf: OK
[   38.032932] Testing event xfs_attr_list_leaf_end: OK
[   38.048857] Testing event xfs_attr_list_full: OK
[   38.064897] Testing event xfs_attr_list_add: OK
[   38.080902] Testing event xfs_attr_list_wrong_blk: OK
[   38.096868] Testing event xfs_attr_list_notfound: OK
[   38.112881] Testing event xfs_perag_get: OK
[   38.128880] Testing event xfs_perag_get_tag: OK
[   38.144857] Testing event xfs_perag_put: OK
[   38.160852] Testing event xfs_perag_set_reclaim: OK
[   38.176885] Testing event xfs_perag_clear_reclaim: OK
[   38.192876] Testing event xfs_attr_list_node_descend: OK
[   38.208847] Testing event xfs_iext_insert: OK
[   38.224839] Testing event xfs_iext_remove: OK
[   38.240870] Testing event xfs_bmap_pre_update: OK
[   38.256896] Testing event xfs_bmap_post_update: OK
[   38.272875] Testing event xfs_extlist: OK
[   38.288856] Testing event xfs_buf_init: OK
[   38.304851] Testing event xfs_buf_free: OK
[   38.320897] Testing event xfs_buf_hold: OK
[   38.336866] Testing event xfs_buf_rele: OK
[   38.352850] Testing event xfs_buf_iodone: OK
[   38.368877] Testing event xfs_buf_iorequest: OK
[   38.384921] Testing event xfs_buf_bawrite: OK
[   38.400909] Testing event xfs_buf_lock: OK
[   38.416878] Testing event xfs_buf_lock_done: OK
[   38.433096] Testing event xfs_buf_trylock: OK
[   38.448912] Testing event xfs_buf_unlock: OK
[   38.464888] Testing event xfs_buf_iowait: OK
[   38.480897] Testing event xfs_buf_iowait_done: OK
[   38.496921] Testing event xfs_buf_delwri_queue: OK
[   38.512887] Testing event xfs_buf_delwri_queued: OK
[   38.528900] Testing event xfs_buf_delwri_split: OK
[   38.544853] Testing event xfs_buf_get_uncached: OK
[   38.560929] Testing event xfs_bdstrat_shut: OK
[   38.576875] Testing event xfs_buf_item_relse: OK
[   38.592922] Testing event xfs_buf_item_iodone: OK
[   38.608875] Testing event xfs_buf_item_iodone_async: OK
[   38.624901] Testing event xfs_buf_error_relse: OK
[   38.640779] Testing event xfs_trans_read_buf_io: OK
[   38.656895] Testing event xfs_trans_read_buf_shut: OK
[   38.672894] Testing event xfs_btree_corrupt: OK
[   38.688883] Testing event xfs_da_btree_corrupt: OK
[   38.704911] Testing event xfs_reset_dqcounts: OK
[   38.720880] Testing event xfs_inode_item_push: OK
[   38.737072] Testing event xfs_buf_find: OK
[   38.753101] Testing event xfs_buf_get: OK
[   38.769119] Testing event xfs_buf_read: OK
[   38.784946] Testing event xfs_buf_ioerror: OK
[   38.800891] Testing event xfs_buf_item_size: OK
[   38.816902] Testing event xfs_buf_item_size_stale: OK
[   38.833066] Testing event xfs_buf_item_format: OK
[   38.849109] Testing event xfs_buf_item_format_stale: OK
[   38.865136] Testing event xfs_buf_item_pin: [   38.872151] vhci_hcd: changed 0
OK
[   38.881242] Testing event xfs_buf_item_unpin: OK
[   38.896911] Testing event xfs_buf_item_unpin_stale: OK
[   38.912898] Testing event xfs_buf_item_unlock: OK
[   38.928728] Testing event xfs_buf_item_unlock_stale: OK
[   38.944895] Testing event xfs_buf_item_committed: OK
[   38.960932] Testing event xfs_buf_item_push: OK
[   38.976895] Testing event xfs_trans_get_buf: OK
[   38.993044] Testing event xfs_trans_get_buf_recur: OK
[   39.008905] Testing event xfs_trans_getsb: OK
[   39.024892] Testing event xfs_trans_getsb_recur: OK
[   39.044833] Testing event xfs_trans_read_buf: OK
[   39.060841] Testing event xfs_trans_read_buf_recur: OK
[   39.076838] Testing event xfs_trans_log_buf: OK
[   39.092835] Testing event xfs_trans_brelse: OK
[   39.108841] Testing event xfs_trans_bjoin: OK
[   39.135285] Testing event xfs_trans_bhold: OK
[   39.152891] Testing event xfs_trans_bhold_release: OK
[   39.168883] Testing event xfs_trans_binval: OK
[   39.184877] Testing event xfs_ilock: OK
[   39.200887] Testing event xfs_ilock_nowait: OK
[   39.216814] Testing event xfs_ilock_demote: OK
[   39.232899] Testing event xfs_iunlock: OK
[   39.248891] Testing event xfs_iget_skip: OK
[   39.264816] Testing event xfs_iget_reclaim: OK
[   39.280891] Testing event xfs_iget_reclaim_fail: OK
[   39.296886] Testing event xfs_iget_hit: OK
[   39.313031] Testing event xfs_iget_miss: OK
[   39.329285] Testing event xfs_getattr: OK
[   39.345106] Testing event xfs_setattr: OK
[   39.360875] Testing event xfs_readlink: OK
[   39.377292] Testing event xfs_alloc_file_space: OK
[   39.396849] Testing event xfs_free_file_space: OK
[   39.413182] Testing event xfs_readdir: OK
[   39.429139] Testing event xfs_get_acl: OK
[   39.444989] Testing event xfs_vm_bmap: OK
[   39.461000] Testing event xfs_file_ioctl: OK
[   39.477190] Testing event xfs_file_compat_ioctl: OK
[   39.493187] Testing event xfs_ioctl_setattr: OK
[   39.509197] Testing event xfs_dir_fsync: OK
[   39.525160] Testing event xfs_file_fsync: OK
[   39.541095] Testing event xfs_destroy_inode: OK
[   39.557065] Testing event xfs_dirty_inode: OK
[   39.573144] Testing event xfs_evict_inode: OK
[   39.589154] Testing event xfs_dquot_dqalloc: OK
[   39.604964] Testing event xfs_dquot_dqdetach: OK
[   39.621185] Testing event xfs_ihold: OK
[   39.637219] Testing event xfs_irele: OK
[   39.653170] Testing event xfs_inode_pin: OK
[   39.669262] Testing event xfs_inode_unpin: OK
[   39.685284] Testing event xfs_inode_unpin_nowait: OK
[   39.701249] Testing event xfs_remove: OK
[   39.717158] Testing event xfs_link: OK
[   39.733183] Testing event xfs_lookup: OK
[   39.749173] Testing event xfs_create: OK
[   39.765167] Testing event xfs_symlink: OK
[   39.781168] Testing event xfs_rename: OK
[   39.797146] Testing event xfs_dqadjust: OK
[   39.812837] Testing event xfs_dqreclaim_want: OK
[   39.829092] Testing event xfs_dqreclaim_dirty: OK
[   39.845119] Testing event xfs_dqreclaim_busy: OK
[   39.861445] Testing event xfs_dqreclaim_done: OK
[   39.877435] Testing event xfs_dqattach_found: OK
[   39.897221] Testing event xfs_dqattach_get: OK
[   39.913192] Testing event xfs_dqalloc: OK
[   39.929082] Testing event xfs_dqtobp_read: OK
[   39.945099] Testing event xfs_dqread: OK
[   39.961188] Testing event xfs_dqread_fail: OK
[   39.977201] Testing event xfs_dqget_hit: OK
[   39.993182] Testing event xfs_dqget_miss: OK
[   40.009159] Testing event xfs_dqget_freeing: OK
[   40.025109] Testing event xfs_dqget_dup: OK
[   40.041134] Testing event xfs_dqput: OK
[   40.057161] Testing event xfs_dqput_wait: OK
[   40.073193] Testing event xfs_dqput_free: OK
[   40.089172] Testing event xfs_dqrele: OK
[   40.105153] Testing event xfs_dqflush: OK
[   40.121180] Testing event xfs_dqflush_force: OK
[   40.137148] Testing event xfs_dqflush_done: OK
[   40.153142] Testing event xfs_log_done_nonperm: OK
[   40.169160] Testing event xfs_log_done_perm: OK
[   40.185207] Testing event xfs_log_umount_write: OK
[   40.201199] Testing event xfs_log_grant_sleep: OK
[   40.217208] Testing event xfs_log_grant_wake: OK
[   40.233208] Testing event xfs_log_grant_wake_up: OK
[   40.249208] Testing event xfs_log_reserve: OK
[   40.265219] Testing event xfs_log_reserve_exit: OK
[   40.281203] Testing event xfs_log_regrant: OK
[   40.297199] Testing event xfs_log_regrant_exit: OK
[   40.313215] Testing event xfs_log_regrant_reserve_enter: OK
[   40.329197] Testing event xfs_log_regrant_reserve_exit: OK
[   40.345174] Testing event xfs_log_regrant_reserve_sub: OK
[   40.361198] Testing event xfs_log_ungrant_enter: OK
[   40.377201] Testing event xfs_log_ungrant_exit: OK
[   40.393171] Testing event xfs_log_ungrant_sub: OK
[   40.409195] Testing event xfs_log_force: OK
[   40.425157] Testing event xfs_ail_push: OK
[   40.441161] Testing event xfs_ail_pinned: OK
[   40.457180] Testing event xfs_ail_locked: OK
[   40.473179] Testing event xfs_ail_flushing: OK
[   40.489187] Testing event xfs_file_read: OK
[   40.505109] Testing event xfs_file_buffered_write: OK
[   40.521206] Testing event xfs_file_direct_write: OK
[   40.537118] Testing event xfs_file_splice_read: OK
[   40.553112] Testing event xfs_file_splice_write: OK
[   40.569191] Testing event xfs_writepage: OK
[   40.585280] Testing event xfs_releasepage: OK
[   40.601179] Testing event xfs_invalidatepage: OK
[   40.617210] Testing event xfs_map_blocks_found: OK
[   40.633169] Testing event xfs_map_blocks_alloc: OK
[   40.649180] Testing event xfs_get_blocks_found: OK
[   40.665166] Testing event xfs_get_blocks_alloc: OK
[   40.681168] Testing event xfs_delalloc_enospc: OK
[   40.697182] Testing event xfs_unwritten_convert: OK
[   40.713178] Testing event xfs_get_blocks_notfound: OK
[   40.729184] Testing event xfs_setfilesize: OK
[   40.745178] Testing event xfs_itruncate_extents_start: OK
[   40.761203] Testing event xfs_itruncate_extents_end: OK
[   40.777148] Testing event xfs_pagecache_inval: OK
[   40.793182] Testing event xfs_bunmap: OK
[   40.809178] Testing event xfs_extent_busy: OK
[   40.825172] Testing event xfs_extent_busy_enomem: OK
[   40.841154] Testing event xfs_extent_busy_force: OK
[   40.857180] Testing event xfs_extent_busy_reuse: OK
[   40.873180] Testing event xfs_extent_busy_clear: [   40.888160] vhci_hcd: changed 0
[   40.888634] Testing event xfs_extent_busy_trim: 
OK
[   40.904687] OK
[   40.906090] Testing event xfs_trans_commit_lsn: OK
[   40.925186] Testing event xfs_agf: OK
[   40.941180] Testing event xfs_free_extent: OK
[   40.957175] Testing event xfs_alloc_exact_done: OK
[   40.973150] Testing event xfs_alloc_exact_notfound: OK
[   40.989179] Testing event xfs_alloc_exact_error: OK
[   41.005150] Testing event xfs_alloc_near_nominleft: OK
[   41.021167] Testing event xfs_alloc_near_first: OK
[   41.037203] Testing event xfs_alloc_near_greater: OK
[   41.053215] Testing event xfs_alloc_near_lesser: OK
[   41.069213] Testing event xfs_alloc_near_error: OK
[   41.085174] Testing event xfs_alloc_near_noentry: OK
[   41.101145] Testing event xfs_alloc_near_busy: OK
[   41.117142] Testing event xfs_alloc_size_neither: OK
[   41.133154] Testing event xfs_alloc_size_noentry: OK
[   41.149137] Testing event xfs_alloc_size_nominleft: OK
[   41.165178] Testing event xfs_alloc_size_done: OK
[   41.181204] Testing event xfs_alloc_size_error: OK
[   41.197223] Testing event xfs_alloc_size_busy: OK
[   41.213220] Testing event xfs_alloc_small_freelist: OK
[   41.229171] Testing event xfs_alloc_small_notenough: OK
[   41.245199] Testing event xfs_alloc_small_done: OK
[   41.261219] Testing event xfs_alloc_small_error: OK
[   41.277199] Testing event xfs_alloc_vextent_badargs: OK
[   41.293220] Testing event xfs_alloc_vextent_nofix: OK
[   41.309210] Testing event xfs_alloc_vextent_noagbp: OK
[   41.325200] Testing event xfs_alloc_vextent_loopfailed: OK
[   41.341185] Testing event xfs_alloc_vextent_allfailed: OK
[   41.357223] Testing event xfs_dir2_sf_addname: OK
[   41.373198] Testing event xfs_dir2_sf_create: OK
[   41.389207] Testing event xfs_dir2_sf_lookup: OK
[   41.405216] Testing event xfs_dir2_sf_replace: OK
[   41.421192] Testing event xfs_dir2_sf_removename: OK
[   41.437249] Testing event xfs_dir2_sf_toino4: OK
[   41.453217] Testing event xfs_dir2_sf_toino8: OK
[   41.469194] Testing event xfs_dir2_sf_to_block: OK
[   41.485215] Testing event xfs_dir2_block_addname: OK
[   41.501222] Testing event xfs_dir2_block_lookup: OK
[   41.517196] Testing event xfs_dir2_block_replace: OK
[   41.533195] Testing event xfs_dir2_block_removename: OK
[   41.549192] Testing event xfs_dir2_block_to_sf: OK
[   41.565184] Testing event xfs_dir2_block_to_leaf: OK
[   41.581184] Testing event xfs_dir2_leaf_addname: OK
[   41.597117] Testing event xfs_dir2_leaf_lookup: OK
[   41.613160] Testing event xfs_dir2_leaf_replace: OK
[   41.629119] Testing event xfs_dir2_leaf_removename: OK
[   41.645182] Testing event xfs_dir2_leaf_to_block: OK
[   41.661126] Testing event xfs_dir2_leaf_to_node: OK
[   41.677175] Testing event xfs_dir2_node_addname: OK
[   41.693124] Testing event xfs_dir2_node_lookup: OK
[   41.709150] Testing event xfs_dir2_node_replace: OK
[   41.725122] Testing event xfs_dir2_node_removename: OK
[   41.741163] Testing event xfs_dir2_node_to_leaf: OK
[   41.757166] Testing event xfs_attr_sf_add: OK
[   41.773127] Testing event xfs_attr_sf_addname: OK
[   41.789182] Testing event xfs_attr_sf_create: OK
[   41.805174] Testing event xfs_attr_sf_lookup: OK
[   41.821211] Testing event xfs_attr_sf_remove: OK
[   41.837136] Testing event xfs_attr_sf_removename: OK
[   41.853167] Testing event xfs_attr_sf_to_leaf: OK
[   41.869182] Testing event xfs_attr_leaf_add: OK
[   41.885193] Testing event xfs_attr_leaf_add_old: OK
[   41.901171] Testing event xfs_attr_leaf_add_new: OK
[   41.917186] Testing event xfs_attr_leaf_addname: OK
[   41.933186] Testing event xfs_attr_leaf_create: OK
[   41.949182] Testing event xfs_attr_leaf_lookup: OK
[   41.965193] Testing event xfs_attr_leaf_replace: OK
[   41.997617] Testing event xfs_attr_leaf_removename: OK
[   42.013176] Testing event xfs_attr_leaf_split: OK
[   42.029150] Testing event xfs_attr_leaf_split_before: OK
[   42.045128] Testing event xfs_attr_leaf_split_after: OK
[   42.061166] Testing event xfs_attr_leaf_clearflag: OK
[   42.077198] Testing event xfs_attr_leaf_setflag: OK
[   42.093201] Testing event xfs_attr_leaf_flipflags: OK
[   42.109176] Testing event xfs_attr_leaf_to_sf: OK
[   42.125145] Testing event xfs_attr_leaf_to_node: OK
[   42.141160] Testing event xfs_attr_leaf_rebalance: OK
[   42.157192] Testing event xfs_attr_leaf_unbalance: OK
[   42.173149] Testing event xfs_attr_node_addname: OK
[   42.189132] Testing event xfs_attr_node_lookup: OK
[   42.205177] Testing event xfs_attr_node_replace: OK
[   42.221208] Testing event xfs_attr_node_removename: OK
[   42.237181] Testing event xfs_da_split: OK
[   42.253196] Testing event xfs_da_join: OK
[   42.269187] Testing event xfs_da_link_before: OK
[   42.285198] Testing event xfs_da_link_after: OK
[   42.301197] Testing event xfs_da_unlink_back: OK
[   42.317149] Testing event xfs_da_unlink_forward: OK
[   42.333172] Testing event xfs_da_root_split: OK
[   42.349166] Testing event xfs_da_root_join: OK
[   42.365189] Testing event xfs_da_node_add: OK
[   42.381161] Testing event xfs_da_node_create: OK
[   42.397171] Testing event xfs_da_node_split: OK
[   42.413200] Testing event xfs_da_node_remove: OK
[   42.429157] Testing event xfs_da_node_rebalance: OK
[   42.445119] Testing event xfs_da_node_unbalance: OK
[   42.461172] Testing event xfs_da_swap_lastblock: OK
[   42.477153] Testing event xfs_da_grow_inode: OK
[   42.493122] Testing event xfs_da_shrink_inode: OK
[   42.509170] Testing event xfs_dir2_leafn_add: OK
[   42.525201] Testing event xfs_dir2_leafn_remove: OK
[   42.541195] Testing event xfs_dir2_grow_inode: OK
[   42.557158] Testing event xfs_dir2_shrink_inode: OK
[   42.573167] Testing event xfs_dir2_leafn_moveents: OK
[   42.589146] Testing event xfs_swap_extent_before: OK
[   42.605173] Testing event xfs_swap_extent_after: OK
[   42.621167] Testing event xfs_log_recover_item_add: OK
[   42.637143] Testing event xfs_log_recover_item_add_cont: OK
[   42.653170] Testing event xfs_log_recover_item_reorder_head: OK
[   42.669154] Testing event xfs_log_recover_item_reorder_tail: OK
[   42.685167] Testing event xfs_log_recover_item_recover: OK
[   42.701155] Testing event xfs_log_recover_buf_not_cancel: OK
[   42.717124] Testing event xfs_log_recover_buf_cancel: OK
[   42.733178] Testing event xfs_log_recover_buf_cancel_add: OK
[   42.749164] Testing event xfs_log_recover_buf_cancel_ref_inc: OK
[   42.765197] Testing event xfs_log_recover_buf_recover: OK
[   42.781197] Testing event xfs_log_recover_buf_inode_buf: OK
[   42.797145] Testing event xfs_log_recover_buf_reg_buf: OK
[   42.813156] Testing event xfs_log_recover_buf_dquot_buf: OK
[   42.829192] Testing event xfs_log_recover_inode_recover: OK
[   42.845182] Testing event xfs_log_recover_inode_cancel: OK
[   42.861203] Testing event xfs_log_recover_inode_skip: OK
[   42.877199] Testing event xfs_discard_extent: OK
[   42.893194] Testing event xfs_discard_toosmall: [   42.904108] vhci_hcd: changed 0
OK
[   42.909178] Testing event xfs_discard_exclude: OK
[   42.925194] Testing event xfs_discard_busy: OK
[   42.941153] Testing event jbd2_checkpoint: OK
[   42.957199] Testing event jbd2_start_commit: OK
[   42.973167] Testing event jbd2_commit_locking: OK
[   42.989146] Testing event jbd2_commit_flushing: OK
[   43.005176] Testing event jbd2_commit_logging: OK
[   43.021164] Testing event jbd2_drop_transaction: OK
[   43.037193] Testing event jbd2_end_commit: OK
[   43.053147] Testing event jbd2_submit_inode_data: OK
[   43.069170] Testing event jbd2_run_stats: OK
[   43.085145] Testing event jbd2_checkpoint_stats: OK
[   43.101173] Testing event jbd2_update_log_tail: OK
[   43.117143] Testing event jbd2_write_superblock: OK
[   43.133154] Testing event jbd_checkpoint: OK
[   43.149146] Testing event jbd_start_commit: OK
[   43.165176] Testing event jbd_commit_locking: OK
[   43.181145] Testing event jbd_commit_flushing: OK
[   43.197168] Testing event jbd_commit_logging: OK
[   43.213150] Testing event jbd_drop_transaction: OK
[   43.229110] Testing event jbd_end_commit: OK
[   43.245173] Testing event jbd_do_submit_data: OK
[   43.261199] Testing event jbd_cleanup_journal_tail: OK
[   43.277206] Testing event journal_write_superblock: OK
[   43.293180] Testing event ext4_free_inode: OK
[   43.309139] Testing event ext4_request_inode: OK
[   43.325174] Testing event ext4_allocate_inode: OK
[   43.341144] Testing event ext4_evict_inode: OK
[   43.357147] Testing event ext4_drop_inode: OK
[   43.373171] Testing event ext4_mark_inode_dirty: OK
[   43.389149] Testing event ext4_begin_ordered_truncate: OK
[   43.405173] Testing event ext4_write_begin: OK
[   43.421156] Testing event ext4_da_write_begin: OK
[   43.437191] Testing event ext4_ordered_write_end: OK
[   43.453147] Testing event ext4_writeback_write_end: OK
[   43.469167] Testing event ext4_journalled_write_end: OK
[   43.485147] Testing event ext4_da_write_end: OK
[   43.501173] Testing event ext4_da_writepages: OK
[   43.517147] Testing event ext4_da_write_pages: OK
[   43.533157] Testing event ext4_da_writepages_result: OK
[   43.549139] Testing event ext4_writepage: OK
[   43.565175] Testing event ext4_readpage: OK
[   43.581147] Testing event ext4_releasepage: OK
[   43.597166] Testing event ext4_invalidatepage: OK
[   43.613148] Testing event ext4_discard_blocks: OK
[   43.629116] Testing event ext4_mb_new_inode_pa: OK
[   43.645171] Testing event ext4_mb_new_group_pa: OK
[   43.661198] Testing event ext4_mb_release_inode_pa: OK
[   43.677179] Testing event ext4_mb_release_group_pa: OK
[   43.693141] Testing event ext4_discard_preallocations: OK
[   43.709165] Testing event ext4_mb_discard_preallocations: OK
[   43.725144] Testing event ext4_request_blocks: OK
[   43.741136] Testing event ext4_allocate_blocks: OK
[   43.757423] Testing event ext4_free_blocks: OK
[   43.773190] Testing event ext4_sync_file_enter: OK
[   43.789146] Testing event ext4_sync_file_exit: OK
[   43.805173] Testing event ext4_sync_fs: OK
[   43.821193] Testing event ext4_alloc_da_blocks: OK
[   43.837189] Testing event ext4_mballoc_alloc: OK
[   43.853146] Testing event ext4_mballoc_prealloc: OK
[   43.869173] Testing event ext4_mballoc_discard: OK
[   43.885149] Testing event ext4_mballoc_free: OK
[   43.901218] Testing event ext4_forget: OK
[   43.917182] Testing event ext4_da_update_reserve_space: OK
[   43.933179] Testing event ext4_da_reserve_space: OK
[   43.949352] Testing event ext4_da_release_space: OK
[   43.965140] Testing event ext4_mb_bitmap_load: OK
[   43.983619] Testing event ext4_mb_buddy_bitmap_load: OK
[   44.001138] Testing event ext4_read_block_bitmap_load: OK
[   44.017172] Testing event ext4_load_inode_bitmap: OK
[   44.033139] Testing event ext4_direct_IO_enter: OK
[   44.049152] Testing event ext4_direct_IO_exit: OK
[   44.065122] Testing event ext4_fallocate_enter: OK
[   44.081122] Testing event ext4_fallocate_exit: OK
[   44.097121] Testing event ext4_unlink_enter: OK
[   44.113123] Testing event ext4_unlink_exit: OK
[   44.129120] Testing event ext4_truncate_enter: OK
[   44.145456] Testing event ext4_truncate_exit: OK
[   44.161142] Testing event ext4_ext_convert_to_initialized_enter: OK
[   44.177173] Testing event ext4_ext_convert_to_initialized_fastpath: OK
[   44.193189] Testing event ext4_ext_map_blocks_enter: OK
[   44.209182] Testing event ext4_ind_map_blocks_enter: OK
[   44.225172] Testing event ext4_ext_map_blocks_exit: OK
[   44.241142] Testing event ext4_ind_map_blocks_exit: OK
[   44.257166] Testing event ext4_ext_load_extent: OK
[   44.273132] Testing event ext4_load_inode: OK
[   44.289163] Testing event ext4_journal_start: OK
[   44.305126] Testing event ext4_trim_extent: OK
[   44.321171] Testing event ext4_trim_all_free: OK
[   44.337130] Testing event ext4_ext_handle_uninitialized_extents: OK
[   44.353146] Testing event ext4_get_implied_cluster_alloc_exit: OK
[   44.369171] Testing event ext4_ext_put_in_cache: OK
[   44.385147] Testing event ext4_ext_in_cache: OK
[   44.401164] Testing event ext4_find_delalloc_range: OK
[   44.417128] Testing event ext4_get_reserved_cluster_alloc: OK
[   44.433150] Testing event ext4_ext_show_extent: OK
[   44.449161] Testing event ext4_remove_blocks: OK
[   44.465172] Testing event ext4_ext_rm_leaf: OK
[   44.481133] Testing event ext4_ext_rm_idx: OK
[   44.497152] Testing event ext4_ext_remove_space: OK
[   44.513120] Testing event ext4_ext_remove_space_done: OK
[   44.529158] Testing event ext3_free_inode: OK
[   44.545177] Testing event ext3_request_inode: OK
[   44.561203] Testing event ext3_allocate_inode: OK
[   44.577179] Testing event ext3_evict_inode: OK
[   44.593116] Testing event ext3_drop_inode: OK
[   44.609153] Testing event ext3_mark_inode_dirty: OK
[   44.625132] Testing event ext3_write_begin: OK
[   44.641131] Testing event ext3_ordered_write_end: OK
[   44.657174] Testing event ext3_writeback_write_end: OK
[   44.673200] Testing event ext3_journalled_write_end: OK
[   44.689157] Testing event ext3_ordered_writepage: OK
[   44.705181] Testing event ext3_writeback_writepage: OK
[   44.721194] Testing event ext3_journalled_writepage: OK
[   44.737163] Testing event ext3_readpage: OK
[   44.753174] Testing event ext3_releasepage: OK
[   44.769189] Testing event ext3_invalidatepage: OK
[   44.785193] Testing event ext3_discard_blocks: OK
[   44.801192] Testing event ext3_request_blocks: OK
[   44.817199] Testing event ext3_allocate_blocks: OK
[   44.833188] Testing event ext3_free_blocks: OK
[   44.864753] Testing event ext3_sync_file_enter: OK
[   44.881176] Testing event ext3_sync_file_exit: OK
[   44.897139] Testing event ext3_sync_fs: OK
[   44.913181] Testing event ext3_rsv_window_add: [   44.920133] vhci_hcd: changed 0
OK
[   44.929182] Testing event ext3_discard_reservation: OK
[   44.945147] Testing event ext3_alloc_new_reservation: OK
[   44.961109] Testing event ext3_reserved: OK
[   44.977156] Testing event ext3_forget: OK
[   44.993110] Testing event ext3_read_block_bitmap: OK
[   45.009150] Testing event ext3_direct_IO_enter: OK
[   45.025163] Testing event ext3_direct_IO_exit: OK
[   45.041180] Testing event ext3_unlink_enter: OK
[   45.057174] Testing event ext3_unlink_exit: OK
[   45.073137] Testing event ext3_truncate_enter: OK
[   45.089136] Testing event ext3_truncate_exit: OK
[   45.105187] Testing event ext3_get_blocks_enter: OK
[   45.121207] Testing event ext3_get_blocks_exit: OK
[   45.137154] Testing event ext3_load_inode: OK
[   45.153202] Testing event writeback_nothread: OK
[   45.169183] Testing event writeback_queue: OK
[   45.185182] Testing event writeback_exec: OK
[   45.201184] Testing event writeback_start: OK
[   45.217178] Testing event writeback_written: OK
[   45.233188] Testing event writeback_wait: OK
[   45.249196] Testing event writeback_pages_written: OK
[   45.265161] Testing event writeback_nowork: OK
[   45.281183] Testing event writeback_wake_background: OK
[   45.297176] Testing event writeback_wake_thread: OK
[   45.313186] Testing event writeback_wake_forker_thread: OK
[   45.329180] Testing event writeback_bdi_register: OK
[   45.345175] Testing event writeback_bdi_unregister: OK
[   45.361183] Testing event writeback_thread_start: OK
[   45.377139] Testing event writeback_thread_stop: OK
[   45.393137] Testing event wbc_writepage: OK
[   45.409178] Testing event writeback_queue_io: OK
[   45.425175] Testing event global_dirty_state: OK
[   45.441174] Testing event bdi_dirty_ratelimit: OK
[   45.457179] Testing event balance_dirty_pages: OK
[   45.473122] Testing event writeback_sb_inodes_requeue: OK
[   45.489143] Testing event writeback_congestion_wait: OK
[   45.505170] Testing event writeback_wait_iff_congested: OK
[   45.521158] Testing event writeback_single_inode: OK
[   45.537161] Testing event mm_compaction_isolate_migratepages: OK
[   45.553183] Testing event mm_compaction_isolate_freepages: OK
[   45.569187] Testing event mm_compaction_migratepages: OK
[   45.585187] Testing event kmalloc: OK
[   45.601464] Testing event kmem_cache_alloc: OK
[   45.617450] Testing event kmalloc_node: OK
[   45.637143] Testing event kmem_cache_alloc_node: OK
[   45.653098] Testing event kfree: OK
[   45.669098] Testing event kmem_cache_free: OK
[   45.685124] Testing event mm_page_free: OK
[   45.701131] Testing event mm_page_free_batched: OK
[   45.717152] Testing event mm_page_alloc: OK
[   45.733123] Testing event mm_page_alloc_zone_locked: OK
[   45.749156] Testing event mm_page_pcpu_drain: OK
[   45.765139] Testing event mm_page_alloc_extfrag: OK
[   45.781143] Testing event mm_vmscan_kswapd_sleep: OK
[   45.797130] Testing event mm_vmscan_kswapd_wake: OK
[   45.813162] Testing event mm_vmscan_wakeup_kswapd: OK
[   45.829131] Testing event mm_vmscan_direct_reclaim_begin: OK
[   45.845155] Testing event mm_vmscan_memcg_reclaim_begin: OK
[   45.861155] Testing event mm_vmscan_memcg_softlimit_reclaim_begin: OK
[   45.877156] Testing event mm_vmscan_direct_reclaim_end: OK
[   45.893121] Testing event mm_vmscan_memcg_reclaim_end: OK
[   45.909156] Testing event mm_vmscan_memcg_softlimit_reclaim_end: OK
[   45.925119] Testing event mm_shrink_slab_start: OK
[   45.941138] Testing event mm_shrink_slab_end: OK
[   45.957150] Testing event mm_vmscan_lru_isolate: OK
[   45.973126] Testing event mm_vmscan_memcg_isolate: OK
[   45.989141] Testing event mm_vmscan_writepage: OK
[   46.005168] Testing event mm_vmscan_lru_shrink_inactive: OK
[   46.021127] Testing event oom_score_adj_update: OK
[   46.037135] Testing event rpm_suspend: OK
[   46.053155] Testing event rpm_resume: OK
[   46.069119] Testing event rpm_idle: OK
[   46.085139] Testing event rpm_return_int: OK
[   46.101119] Testing event cpu_idle: OK
[   46.117221] Testing event cpu_frequency: OK
[   46.133160] Testing event machine_suspend: OK
[   46.149117] Testing event wakeup_source_activate: OK
[   46.165122] Testing event wakeup_source_deactivate: OK
[   46.181123] Testing event power_start: OK
[   46.197149] Testing event power_frequency: OK
[   46.213126] Testing event power_end: OK
[   46.229141] Testing event clock_enable: OK
[   46.245149] Testing event clock_disable: OK
[   46.261147] Testing event clock_set_rate: OK
[   46.277108] Testing event power_domain_target: OK
[   46.293089] Testing event ftrace_test_filter: OK
[   46.309195] Testing event module_load: OK
[   46.325167] Testing event module_free: OK
[   46.341122] Testing event module_get: OK
[   46.357147] Testing event module_put: OK
[   46.373173] Testing event module_request: OK
[   46.389122] Testing event lock_acquire: OK
[   46.405137] Testing event lock_release: OK
[   46.421228] Testing event lock_contended: OK
[   46.437161] Testing event lock_acquired: OK
[   46.453172] Testing event sched_kthread_stop: OK
[   46.469131] Testing event sched_kthread_stop_ret: OK
[   46.485160] Testing event sched_wakeup: OK
[   46.501136] Testing event sched_wakeup_new: OK
[   46.517147] Testing event sched_switch: OK
[   46.533178] Testing event sched_migrate_task: OK
[   46.549125] Testing event sched_process_free: OK
[   46.565101] Testing event sched_process_exit: OK
[   46.581133] Testing event sched_wait_task: OK
[   46.597086] Testing event sched_process_wait: OK
[   46.613139] Testing event sched_process_fork: OK
[   46.629125] Testing event sched_process_exec: OK
[   46.645158] Testing event sched_stat_wait: OK
[   46.661164] Testing event sched_stat_sleep: OK
[   46.677156] Testing event sched_stat_iowait: OK
[   46.693113] Testing event sched_stat_blocked: OK
[   46.709153] Testing event sched_stat_runtime: OK
[   46.725141] Testing event sched_pi_setprio: OK
[   46.741138] Testing event rcu_utilization: OK
[   46.757157] Testing event rcu_grace_period: OK
[   46.773127] Testing event rcu_grace_period_init: OK
[   46.789121] Testing event rcu_preempt_task: OK
[   46.805158] Testing event rcu_unlock_preempted_task: OK
[   46.821178] Testing event rcu_quiescent_state_report: OK
[   46.837121] Testing event rcu_fqs: OK
[   46.853121] Testing event rcu_dyntick: OK
[   46.869170] Testing event rcu_prep_idle: OK
[   46.885155] Testing event rcu_callback: OK
[   46.901126] Testing event rcu_kfree_callback: OK
[   46.917151] Testing event rcu_batch_start: OK
[   46.933172] Testing event rcu_invoke_callback: [   46.936100] vhci_hcd: changed 0
OK
[   46.949152] Testing event rcu_invoke_kfree_callback: OK
[   46.965104] Testing event rcu_batch_end: OK
[   46.981170] Testing event rcu_torture_read: OK
[   46.997158] Testing event workqueue_queue_work: OK
[   47.013130] Testing event workqueue_activate_work: OK
[   47.029107] Testing event workqueue_execute_start: OK
[   47.045120] Testing event workqueue_execute_end: OK
[   47.061102] Testing event signal_generate: OK
[   47.077124] Testing event signal_deliver: OK
[   47.093092] Testing event timer_init: OK
[   47.109152] Testing event timer_start: OK
[   47.125072] Testing event timer_expire_entry: OK
[   47.141118] Testing event timer_expire_exit: OK
[   47.157159] Testing event timer_cancel: OK
[   47.173124] Testing event hrtimer_init: OK
[   47.189124] Testing event hrtimer_start: OK
[   47.205125] Testing event hrtimer_expire_entry: OK
[   47.221109] Testing event hrtimer_expire_exit: OK
[   47.237125] Testing event hrtimer_cancel: OK
[   47.253171] Testing event itimer_state: OK
[   47.269110] Testing event itimer_expire: OK
[   47.285119] Testing event irq_handler_entry: OK
[   47.301122] Testing event irq_handler_exit: OK
[   47.317141] Testing event softirq_entry: OK
[   47.333165] Testing event softirq_exit: OK
[   47.349154] Testing event softirq_raise: OK
[   47.365142] Testing event console: OK
[   47.381149] Testing event task_newtask: OK
[   47.397174] Testing event task_rename: OK
[   47.413142] Testing event mce_record: OK
[   47.429138] Testing event sys_enter: OK
[   47.445184] Testing event sys_exit: OK
[   47.461182] Testing event emulate_vsyscall: OK
[   47.477153] Testing event xen_mc_batch: OK
[   47.493097] Testing event xen_mc_issue: OK
[   47.509142] Testing event xen_mc_entry: OK
[   47.525156] Testing event xen_mc_entry_alloc: OK
[   47.541104] Testing event xen_mc_callback: OK
[   47.557152] Testing event xen_mc_flush_reason: OK
[   47.573136] Testing event xen_mc_flush: OK
[   47.589131] Testing event xen_mc_extend_args: OK
[   47.605122] Testing event xen_mmu_set_pte: OK
[   47.621179] Testing event xen_mmu_set_pte_atomic: OK
[   47.637115] Testing event xen_mmu_set_domain_pte: OK
[   47.653157] Testing event xen_mmu_set_pte_at: OK
[   47.669116] Testing event xen_mmu_pte_clear: OK
[   47.701106] Testing event xen_mmu_set_pmd: OK
[   47.717162] Testing event xen_mmu_pmd_clear: OK
[   47.733169] Testing event xen_mmu_set_pud: OK
[   47.749170] Testing event xen_mmu_set_pgd: OK
[   47.765139] Testing event xen_mmu_pud_clear: OK
[   47.781134] Testing event xen_mmu_pgd_clear: OK
[   47.797152] Testing event xen_mmu_ptep_modify_prot_start: OK
[   47.813159] Testing event xen_mmu_ptep_modify_prot_commit: OK
[   47.829118] Testing event xen_mmu_alloc_ptpage: OK
[   47.845165] Testing event xen_mmu_release_ptpage: OK
[   47.861110] Testing event xen_mmu_pgd_pin: OK
[   47.877161] Testing event xen_mmu_pgd_unpin: OK
[   47.893127] Testing event xen_mmu_flush_tlb: OK
[   47.909145] Testing event xen_mmu_flush_tlb_single: OK
[   47.925129] Testing event xen_mmu_flush_tlb_others: OK
[   47.941156] Testing event xen_mmu_write_cr3: OK
[   47.957121] Testing event xen_cpu_write_ldt_entry: OK
[   47.973108] Testing event xen_cpu_write_idt_entry: OK
[   47.989149] Testing event xen_cpu_load_idt: OK
[   48.005131] Testing event xen_cpu_write_gdt_entry: OK
[   48.021159] Testing event xen_cpu_set_ldt: OK
[   48.037125] Testing event kvm_mmu_pagetable_walk: OK
[   48.053151] Testing event kvm_mmu_paging_element: OK
[   48.069117] Testing event kvm_mmu_set_accessed_bit: OK
[   48.085154] Testing event kvm_mmu_set_dirty_bit: OK
[   48.101121] Testing event kvm_mmu_walker_error: OK
[   48.117140] Testing event kvm_mmu_get_page: OK
[   48.133148] Testing event kvm_mmu_sync_page: OK
[   48.149130] Testing event kvm_mmu_unsync_page: OK
[   48.165101] Testing event kvm_mmu_prepare_zap_page: OK
[   48.181129] Testing event kvm_mmu_delay_free_pages: OK
[   48.197149] Testing event mark_mmio_spte: OK
[   48.213122] Testing event handle_mmio_page_fault: OK
[   48.229154] Testing event kvm_entry: OK
[   48.245141] Testing event kvm_hypercall: OK
[   48.261141] Testing event kvm_hv_hypercall: OK
[   48.277134] Testing event kvm_pio: OK
[   48.293125] Testing event kvm_cpuid: OK
[   48.309158] Testing event kvm_apic: OK
[   48.325130] Testing event kvm_exit: OK
[   48.341143] Testing event kvm_inj_virq: OK
[   48.357133] Testing event kvm_inj_exception: OK
[   48.373112] Testing event kvm_page_fault: OK
[   48.389152] Testing event kvm_msr: OK
[   48.405119] Testing event kvm_cr: OK
[   48.421164] Testing event kvm_pic_set_irq: OK
[   48.437160] Testing event kvm_apic_ipi: OK
[   48.453116] Testing event kvm_apic_accept_irq: OK
[   48.469096] Testing event kvm_nested_vmrun: OK
[   48.485150] Testing event kvm_nested_intercepts: OK
[   48.501126] Testing event kvm_nested_vmexit: OK
[   48.517152] Testing event kvm_nested_vmexit_inject: OK
[   48.533157] Testing event kvm_nested_intr_vmexit: OK
[   48.549126] Testing event kvm_invlpga: OK
[   48.565112] Testing event kvm_skinit: OK
[   48.581130] Testing event kvm_emulate_insn: OK
[   48.597138] Testing event vcpu_match_mmio: OK
[   48.613135] Testing event kvm_userspace_exit: OK
[   48.629117] Testing event kvm_set_irq: OK
[   48.645143] Testing event kvm_ioapic_set_irq: OK
[   48.661139] Testing event kvm_msi_set_irq: OK
[   48.677164] Testing event kvm_ack_irq: OK
[   48.693135] Testing event kvm_mmio: OK
[   48.709149] Testing event kvm_fpu: OK
[   48.725109] Testing event kvm_age_page: OK
[   48.741154] Testing event kvm_try_async_get_page: OK
[   48.757152] Testing event kvm_async_pf_doublefault: OK
[   48.773134] Testing event kvm_async_pf_not_present: OK
[   48.789146] Testing event kvm_async_pf_ready: OK
[   48.805158] Testing event kvm_async_pf_completed: OK
[   48.821179] Running tests on trace event systems:
[   48.822782] Testing event system 9p: OK
[   48.841440] Testing event system mac80211: OK
[   48.878493] Testing event system sunrpc: OK
[   48.897988] Testing event system skb: OK
[   48.917258] Testing event system net: OK
[   48.933371] Testing event system napi: OK
[   48.950679] Testing event system sock: [   48.952111] vhci_hcd: changed 0
OK
[   48.969309] Testing event system udp: OK
[   48.985227] Testing event system hda: OK
[   49.001708] Testing event system scsi: OK
[   49.017600] Testing event system regmap: OK
[   49.038137] Testing event system i915: OK
[   49.059477] Testing event system radeon: OK
[   49.077629] Testing event system drm: OK
[   49.093443] Testing event system regulator: OK
[   49.113871] Testing event system gpio: OK
[   49.129342] Testing event system block: OK
[   49.150921] Testing event system gfs2: OK
[   49.170701] Testing event system btrfs: OK
[   49.196435] Testing event system ocfs2: OK
[   49.309237] Testing event system xfs: OK
[   49.413604] Testing event system jbd2: OK
[   49.434385] Testing event system jbd: OK
[   49.454209] Testing event system ext4: OK
[   49.490007] Testing event system ext3: OK
[   49.513283] Testing event system writeback: OK
[   49.535670] Testing event system compaction: OK
[   49.553433] Testing event system kmem: OK
[   49.574360] Testing event system vmscan: OK
[   49.594594] Testing event system oom: OK
[   49.613292] Testing event system rpm: OK
[   49.629528] Testing event system power: OK
[   49.650443] Testing event system test: OK
[   49.669284] Testing event system module: OK
[   49.685695] Testing event system lock: OK
[   49.701741] Testing event system sched: OK
[   49.723070] Testing event system rcu: OK
[   49.742881] Testing event system workqueue: OK
[   49.761533] Testing event system signal: OK
[   49.777315] Testing event system timer: OK
[   49.798310] Testing event system irq: OK
[   49.817692] Testing event system printk: OK
[   49.833235] Testing event system task: OK
[   49.849336] Testing event system mce: OK
[   49.865203] Testing event system raw_syscalls: OK
[   49.881379] Testing event system vsyscall: OK
[   49.897314] Testing event system syscalls: OK
[   49.918999] Testing event system xen: OK
[   49.944748] Testing event system kvmmmu: OK
[   49.962313] Testing event system kvm: OK
[   49.985024] Running tests on all trace events:
[   49.986601] Testing all events: OK
[   50.934199] Running tests again, along with the function tracer
[   50.936762] Running tests on trace events:
[   50.938476] Testing event 9p_client_req: OK
[   50.958762] Testing event 9p_client_res: [   50.968215] vhci_hcd: changed 0
OK
[   50.978843] Testing event 9p_protocol_dump: OK
[   50.998926] Testing event drv_return_void: OK
[   51.019098] Testing event drv_return_int: OK
[   51.038835] Testing event drv_return_bool: OK
[   51.058908] Testing event drv_return_u64: OK
[   51.078872] Testing event drv_start: OK
[   51.098839] Testing event drv_get_et_strings: OK
[   51.118814] Testing event drv_get_et_sset_count: OK
[   51.138815] Testing event drv_get_et_stats: OK
[   51.158814] Testing event drv_suspend: OK
[   51.178761] Testing event drv_resume: OK
[   51.197915] Testing event drv_set_wakeup: OK
[   51.217828] Testing event drv_stop: OK
[   51.237911] Testing event drv_add_interface: OK
[   51.258169] Testing event drv_change_interface: OK
[   51.277809] Testing event drv_remove_interface: OK
[   51.297800] Testing event drv_config: OK
[   51.317932] Testing event drv_bss_info_changed: OK
[   51.337903] Testing event drv_prepare_multicast: OK
[   51.357903] Testing event drv_configure_filter: OK
[   51.377954] Testing event drv_set_tim: OK
[   51.397834] Testing event drv_set_key: OK
[   51.417765] Testing event drv_update_tkip_key: OK
[   51.437774] Testing event drv_hw_scan: OK
[   51.457898] Testing event drv_cancel_hw_scan: OK
[   51.477779] Testing event drv_sched_scan_start: OK
[   51.497885] Testing event drv_sched_scan_stop: OK
[   51.517974] Testing event drv_sw_scan_start: OK
[   51.537883] Testing event drv_sw_scan_complete: OK
[   51.557917] Testing event drv_get_stats: OK
[   51.577777] Testing event drv_get_tkip_seq: OK
[   51.597774] Testing event drv_set_frag_threshold: OK
[   51.617779] Testing event drv_set_rts_threshold: OK
[   51.637753] Testing event drv_set_coverage_class: OK
[   51.657770] Testing event drv_sta_notify: OK
[   51.677775] Testing event drv_sta_state: OK
[   51.697771] Testing event drv_sta_rc_update: OK
[   51.717762] Testing event drv_sta_add: OK
[   51.737902] Testing event drv_sta_remove: OK
[   51.757787] Testing event drv_conf_tx: OK
[   51.777879] Testing event drv_get_tsf: OK
[   51.797912] Testing event drv_set_tsf: OK
[   51.817900] Testing event drv_reset_tsf: OK
[   51.837756] Testing event drv_tx_last_beacon: OK
[   51.857768] Testing event drv_ampdu_action: OK
[   51.877765] Testing event drv_get_survey: OK
[   51.897769] Testing event drv_flush: OK
[   51.917906] Testing event drv_channel_switch: OK
[   51.937754] Testing event drv_set_antenna: OK
[   51.957894] Testing event drv_get_antenna: OK
[   51.977794] Testing event drv_remain_on_channel: OK
[   52.008515] Testing event drv_cancel_remain_on_channel: OK
[   52.025940] Testing event drv_offchannel_tx: OK
[   52.045763] Testing event drv_set_ringparam: OK
[   52.065766] Testing event drv_get_ringparam: OK
[   52.085904] Testing event drv_tx_frames_pending: OK
[   52.105779] Testing event drv_offchannel_tx_cancel_wait: OK
[   52.125766] Testing event drv_set_bitrate_mask: OK
[   52.145768] Testing event drv_set_rekey_data: OK
[   52.165766] Testing event drv_rssi_callback: OK
[   52.185903] Testing event drv_release_buffered_frames: OK
[   52.205780] Testing event drv_allow_buffered_frames: OK
[   52.225759] Testing event drv_get_rssi: OK
[   52.245760] Testing event api_start_tx_ba_session: OK
[   52.265756] Testing event api_start_tx_ba_cb: OK
[   52.285902] Testing event api_stop_tx_ba_session: OK
[   52.305771] Testing event api_stop_tx_ba_cb: OK
[   52.325760] Testing event api_restart_hw: OK
[   52.345760] Testing event api_beacon_loss: OK
[   52.365732] Testing event api_connection_loss: OK
[   52.385842] Testing event api_cqm_rssi_notify: OK
[   52.405771] Testing event api_scan_completed: OK
[   52.425756] Testing event api_sched_scan_results: OK
[   52.445755] Testing event api_sched_scan_stopped: OK
[   52.465757] Testing event api_sta_block_awake: OK
[   52.485753] Testing event api_chswitch_done: OK
[   52.505764] Testing event api_ready_on_channel: OK
[   52.525782] Testing event api_remain_on_channel_expired: OK
[   52.545766] Testing event api_gtk_rekey_notify: OK
[   52.565779] Testing event api_enable_rssi_reports: OK
[   52.585913] Testing event api_eosp: OK
[   52.605906] Testing event wake_queue: OK
[   52.625897] Testing event stop_queue: OK
[   52.645893] Testing event rpc_call_status: OK
[   52.665893] Testing event rpc_bind_status: OK
[   52.685885] Testing event rpc_connect_status: OK
[   52.705774] Testing event rpc_task_begin: OK
[   52.725909] Testing event rpc_task_run_action: OK
[   52.745777] Testing event rpc_task_complete: OK
[   52.765792] Testing event rpc_task_sleep: OK
[   52.785911] Testing event rpc_task_wakeup: OK
[   52.805901] Testing event kfree_skb: OK
[   52.825929] Testing event consume_skb: OK
[   52.845779] Testing event skb_copy_datagram_iovec: OK
[   52.865943] Testing event net_dev_xmit: OK
[   52.885910] Testing event net_dev_queue: OK
[   52.905902] Testing event netif_receive_skb: OK
[   52.925837] Testing event netif_rx: OK
[   52.945835] Testing event napi_poll: OK
[   52.965909] Testing event sock_rcvqueue_full: [   52.984163] vhci_hcd: changed 0
OK
[   52.986664] Testing event sock_exceed_buf_limit: OK
[   53.005833] Testing event udp_fail_queue_rcv_skb: OK
[   53.025827] Testing event hda_send_cmd: OK
[   53.045777] Testing event hda_get_response: OK
[   53.065815] Testing event hda_bus_reset: OK
[   53.085828] Testing event hda_power_down: OK
[   53.105849] Testing event hda_power_up: OK
[   53.125849] Testing event hda_unsol_event: OK
[   53.145856] Testing event scsi_dispatch_cmd_start: OK
[   53.165848] Testing event scsi_dispatch_cmd_error: OK
[   53.185850] Testing event scsi_dispatch_cmd_done: OK
[   53.205840] Testing event scsi_dispatch_cmd_timeout: OK
[   53.225786] Testing event scsi_eh_wakeup: OK
[   53.245817] Testing event regmap_reg_write: OK
[   53.265830] Testing event regmap_reg_read: OK
[   53.285843] Testing event regmap_reg_read_cache: OK
[   53.305850] Testing event regmap_hw_read_start: OK
[   53.325825] Testing event regmap_hw_read_done: OK
[   53.345765] Testing event regmap_hw_write_start: OK
[   53.365779] Testing event regmap_hw_write_done: OK
[   53.385891] Testing event regcache_sync: OK
[   53.405785] Testing event regmap_cache_only: OK
[   53.425790] Testing event regmap_cache_bypass: OK
[   53.446725] Testing event i915_gem_object_create: OK
[   53.466774] Testing event i915_gem_object_bind: OK
[   53.485776] Testing event i915_gem_object_unbind: OK
[   53.505789] Testing event i915_gem_object_change_domain: OK
[   53.525761] Testing event i915_gem_object_pwrite: OK
[   53.545758] Testing event i915_gem_object_pread: OK
[   53.565754] Testing event i915_gem_object_fault: OK
[   53.585902] Testing event i915_gem_object_clflush: OK
[   53.605770] Testing event i915_gem_object_destroy: OK
[   53.625909] Testing event i915_gem_evict: OK
[   53.645772] Testing event i915_gem_evict_everything: OK
[   53.665748] Testing event i915_gem_ring_dispatch: OK
[   53.685753] Testing event i915_gem_ring_flush: OK
[   53.705758] Testing event i915_gem_request_add: OK
[   53.725890] Testing event i915_gem_request_complete: OK
[   53.745760] Testing event i915_gem_request_retire: OK
[   53.765750] Testing event i915_gem_request_wait_begin: OK
[   53.785899] Testing event i915_gem_request_wait_end: OK
[   53.805819] Testing event i915_ring_wait_begin: OK
[   53.825846] Testing event i915_ring_wait_end: OK
[   53.845747] Testing event i915_flip_request: OK
[   53.865740] Testing event i915_flip_complete: OK
[   53.885899] Testing event i915_reg_rw: OK
[   53.905772] Testing event radeon_bo_create: OK
[   53.925792] Testing event radeon_fence_emit: OK
[   53.945935] Testing event radeon_fence_retire: OK
[   53.965945] Testing event radeon_fence_wait_begin: OK
[   53.985846] Testing event radeon_fence_wait_end: OK
[   54.005852] Testing event drm_vblank_event: OK
[   54.025961] Testing event drm_vblank_event_queued: OK
[   54.045975] Testing event drm_vblank_event_delivered: OK
[   54.065852] Testing event regulator_enable: OK
[   54.085853] Testing event regulator_enable_delay: OK
[   54.105840] Testing event regulator_enable_complete: OK
[   54.125844] Testing event regulator_disable: OK
[   54.145837] Testing event regulator_disable_complete: OK
[   54.166076] Testing event regulator_set_voltage: OK
[   54.185790] Testing event regulator_set_voltage_complete: OK
[   54.205818] Testing event gpio_direction: OK
[   54.225811] Testing event gpio_value: OK
[   54.245936] Testing event block_rq_abort: OK
[   54.265979] Testing event block_rq_requeue: OK
[   54.285790] Testing event block_rq_complete: OK
[   54.305872] Testing event block_rq_insert: OK
[   54.325885] Testing event block_rq_issue: OK
[   54.345878] Testing event block_bio_bounce: OK
[   54.366077] Testing event block_bio_complete: OK
[   54.385772] Testing event block_bio_backmerge: OK
[   54.405825] Testing event block_bio_frontmerge: OK
[   54.425831] Testing event block_bio_queue: OK
[   54.445836] Testing event block_getrq: OK
[   54.465835] Testing event block_sleeprq: OK
[   54.486649] Testing event block_plug: OK
[   54.505859] Testing event block_unplug: OK
[   54.525614] Testing event block_split: OK
[   54.545873] Testing event block_bio_remap: OK
[   54.565639] Testing event block_rq_remap: OK
[   54.585605] Testing event gfs2_glock_state_change: OK
[   54.605868] Testing event gfs2_glock_put: OK
[   54.625610] Testing event gfs2_demote_rq: OK
[   54.645677] Testing event gfs2_promote: OK
[   54.665863] Testing event gfs2_glock_queue: OK
[   54.685626] Testing event gfs2_glock_lock_time: OK
[   54.705874] Testing event gfs2_pin: OK
[   54.725647] Testing event gfs2_log_flush: OK
[   54.745698] Testing event gfs2_log_blocks: OK
[   54.765767] Testing event gfs2_ail_flush: OK
[   54.785700] Testing event gfs2_bmap: OK
[   54.805627] Testing event gfs2_block_alloc: OK
[   54.825770] Testing event btrfs_transaction_commit: OK
[   54.845672] Testing event btrfs_inode_new: OK
[   54.865719] Testing event btrfs_inode_request: OK
[   54.885645] Testing event btrfs_inode_evict: OK
[   54.905649] Testing event btrfs_get_extent: OK
[   54.925692] Testing event btrfs_ordered_extent_add: OK
[   54.945677] Testing event btrfs_ordered_extent_remove: OK
[   54.965596] Testing event btrfs_ordered_extent_start: OK
[   54.985784] Testing event btrfs_ordered_extent_put: [   55.000198] vhci_hcd: changed 0
OK
[   55.005833] Testing event __extent_writepage: OK
[   55.025588] Testing event btrfs_writepage_end_io_hook: OK
[   55.045735] Testing event btrfs_sync_file: OK
[   55.065739] Testing event btrfs_sync_fs: OK
[   55.085723] Testing event btrfs_delayed_tree_ref: OK
[   55.105747] Testing event btrfs_delayed_data_ref: OK
[   55.125746] Testing event btrfs_delayed_ref_head: OK
[   55.145725] Testing event btrfs_chunk_alloc: OK
[   55.165659] Testing event btrfs_chunk_free: OK
[   55.185713] Testing event btrfs_cow_block: OK
[   55.205629] Testing event btrfs_space_reservation: OK
[   55.225746] Testing event btrfs_reserved_extent_alloc: OK
[   55.245741] Testing event btrfs_reserved_extent_free: OK
[   55.265733] Testing event find_free_extent: OK
[   55.285815] Testing event btrfs_reserve_extent: OK
[   55.305594] Testing event btrfs_reserve_extent_cluster: OK
[   55.325678] Testing event btrfs_find_cluster: OK
[   55.345736] Testing event btrfs_failed_cluster_setup: OK
[   55.365728] Testing event btrfs_setup_cluster: OK
[   55.385770] Testing event alloc_extent_state: OK
[   55.405590] Testing event free_extent_state: OK
[   55.425662] Testing event ocfs2_adjust_rightmost_branch: OK
[   55.445842] Testing event ocfs2_rotate_tree_right: OK
[   55.465626] Testing event ocfs2_append_rec_to_path: OK
[   55.485674] Testing event ocfs2_insert_extent_start: OK
[   55.505759] Testing event ocfs2_add_clusters_in_btree: OK
[   55.536178] Testing event ocfs2_num_free_extents: OK
[   55.553721] Testing event ocfs2_complete_edge_insert: OK
[   55.573752] Testing event ocfs2_grow_tree: OK
[   55.593738] Testing event ocfs2_rotate_subtree: OK
[   55.613746] Testing event ocfs2_insert_extent: OK
[   55.633744] Testing event ocfs2_split_extent: OK
[   55.653735] Testing event ocfs2_remove_extent: OK
[   55.673724] Testing event ocfs2_commit_truncate: OK
[   55.693752] Testing event ocfs2_validate_extent_block: OK
[   55.713674] Testing event ocfs2_rotate_leaf: OK
[   55.733794] Testing event ocfs2_add_clusters_in_btree_ret: OK
[   55.753719] Testing event ocfs2_mark_extent_written: OK
[   55.773642] Testing event ocfs2_truncate_log_append: OK
[   55.793708] Testing event ocfs2_replay_truncate_records: OK
[   55.813588] Testing event ocfs2_flush_truncate_log: OK
[   55.834640] Testing event ocfs2_begin_truncate_log_recovery: OK
[   55.853905] Testing event ocfs2_truncate_log_recovery_num: OK
[   55.873827] Testing event ocfs2_complete_truncate_log_recovery: OK
[   55.893948] Testing event ocfs2_free_cached_blocks: OK
[   55.913947] Testing event ocfs2_cache_cluster_dealloc: OK
[   55.934022] Testing event ocfs2_run_deallocs: OK
[   55.953945] Testing event ocfs2_cache_block_dealloc: OK
[   55.973959] Testing event ocfs2_trim_extent: OK
[   55.993995] Testing event ocfs2_trim_group: OK
[   56.013985] Testing event ocfs2_trim_fs: OK
[   56.033975] Testing event ocfs2_la_set_sizes: OK
[   56.053951] Testing event ocfs2_alloc_should_use_local: OK
[   56.074060] Testing event ocfs2_load_local_alloc: OK
[   56.094735] Testing event ocfs2_begin_local_alloc_recovery: OK
[   56.113781] Testing event ocfs2_reserve_local_alloc_bits: OK
[   56.133899] Testing event ocfs2_local_alloc_count_bits: OK
[   56.153812] Testing event ocfs2_local_alloc_find_clear_bits_search_bitmap: OK
[   56.173941] Testing event ocfs2_local_alloc_find_clear_bits: OK
[   56.193906] Testing event ocfs2_sync_local_to_main: OK
[   56.213812] Testing event ocfs2_sync_local_to_main_free: OK
[   56.233834] Testing event ocfs2_local_alloc_new_window: OK
[   56.253804] Testing event ocfs2_local_alloc_new_window_result: OK
[   56.273804] Testing event ocfs2_update_last_group_and_inode: OK
[   56.293812] Testing event ocfs2_group_extend: OK
[   56.313810] Testing event ocfs2_group_add: OK
[   56.333818] Testing event ocfs2_validate_group_descriptor: OK
[   56.353807] Testing event ocfs2_block_group_alloc_contig: OK
[   56.373798] Testing event ocfs2_block_group_alloc_discontig: OK
[   56.393911] Testing event ocfs2_block_group_alloc: OK
[   56.413809] Testing event ocfs2_reserve_suballoc_bits_nospc: OK
[   56.433832] Testing event ocfs2_reserve_suballoc_bits_no_new_group: OK
[   56.453802] Testing event ocfs2_reserve_new_inode_new_group: OK
[   56.473801] Testing event ocfs2_block_group_set_bits: OK
[   56.493796] Testing event ocfs2_relink_block_group: OK
[   56.513881] Testing event ocfs2_cluster_group_search_wrong_max_bits: OK
[   56.533823] Testing event ocfs2_cluster_group_search_max_block: OK
[   56.553797] Testing event ocfs2_block_group_search_max_block: OK
[   56.573797] Testing event ocfs2_search_chain_begin: OK
[   56.593907] Testing event ocfs2_search_chain_succ: OK
[   56.613799] Testing event ocfs2_search_chain_end: OK
[   56.633828] Testing event ocfs2_claim_suballoc_bits: OK
[   56.653808] Testing event ocfs2_claim_new_inode_at_loc: OK
[   56.673802] Testing event ocfs2_block_group_clear_bits: OK
[   56.693794] Testing event ocfs2_free_suballoc_bits: OK
[   56.713810] Testing event ocfs2_free_clusters: OK
[   56.733829] Testing event ocfs2_get_suballoc_slot_bit: OK
[   56.753795] Testing event ocfs2_test_suballoc_bit: OK
[   56.773937] Testing event ocfs2_test_inode_bit: OK
[   56.793910] Testing event ocfs2_validate_refcount_block: OK
[   56.813902] Testing event ocfs2_purge_refcount_trees: OK
[   56.833839] Testing event ocfs2_create_refcount_tree: OK
[   56.853904] Testing event ocfs2_create_refcount_tree_blkno: OK
[   56.873806] Testing event ocfs2_change_refcount_rec: OK
[   56.893808] Testing event ocfs2_expand_inline_ref_root: OK
[   56.913909] Testing event ocfs2_divide_leaf_refcount_block: OK
[   56.933896] Testing event ocfs2_new_leaf_refcount_block: OK
[   56.953806] Testing event ocfs2_insert_refcount_rec: OK
[   56.973889] Testing event ocfs2_split_refcount_rec: OK
[   56.993798] Testing event ocfs2_split_refcount_rec_insert: OK
[   57.013811] Testing event ocfs2_increase_refcount_begin: [   57.016139] vhci_hcd: changed 0
OK
[   57.034054] Testing event ocfs2_increase_refcount_change: OK
[   57.053817] Testing event ocfs2_increase_refcount_insert: OK
[   57.073951] Testing event ocfs2_increase_refcount_split: OK
[   57.093952] Testing event ocfs2_remove_refcount_extent: OK
[   57.113947] Testing event ocfs2_restore_refcount_block: OK
[   57.134008] Testing event ocfs2_decrease_refcount_rec: OK
[   57.153821] Testing event ocfs2_decrease_refcount: OK
[   57.173821] Testing event ocfs2_mark_extent_refcounted: OK
[   57.193810] Testing event ocfs2_calc_refcount_meta_credits: OK
[   57.213818] Testing event ocfs2_calc_refcount_meta_credits_iterate: OK
[   57.233826] Testing event ocfs2_add_refcount_flag: OK
[   57.253945] Testing event ocfs2_prepare_refcount_change_for_del: OK
[   57.274545] Testing event ocfs2_lock_refcount_allocators: OK
[   57.293915] Testing event ocfs2_duplicate_clusters_by_page: OK
[   57.313922] Testing event ocfs2_duplicate_clusters_by_jbd: OK
[   57.334146] Testing event ocfs2_clear_ext_refcount: OK
[   57.353816] Testing event ocfs2_replace_clusters: OK
[   57.373938] Testing event ocfs2_make_clusters_writable: OK
[   57.393802] Testing event ocfs2_refcount_cow_hunk: OK
[   57.414205] Testing event ocfs2_symlink_get_block: OK
[   57.434145] Testing event ocfs2_get_block: OK
[   57.454093] Testing event ocfs2_get_block_end: OK
[   57.473874] Testing event ocfs2_readpage: OK
[   57.494048] Testing event ocfs2_writepage: OK
[   57.514033] Testing event ocfs2_bmap: OK
[   57.534070] Testing event ocfs2_try_to_write_inline_data: OK
[   57.553735] Testing event ocfs2_write_begin_nolock: OK
[   57.574075] Testing event ocfs2_write_end_inline: OK
[   57.593975] Testing event ocfs2_fault: OK
[   57.613856] Testing event ocfs2_file_open: OK
[   57.633999] Testing event ocfs2_file_release: OK
[   57.654039] Testing event ocfs2_sync_file: OK
[   57.673851] Testing event ocfs2_file_aio_write: OK
[   57.694057] Testing event ocfs2_file_splice_write: OK
[   57.713772] Testing event ocfs2_file_splice_read: OK
[   57.734052] Testing event ocfs2_file_aio_read: OK
[   57.754039] Testing event ocfs2_truncate_file: OK
[   57.774056] Testing event ocfs2_truncate_file_error: OK
[   57.794039] Testing event ocfs2_extend_allocation: OK
[   57.813836] Testing event ocfs2_extend_allocation_end: OK
[   57.833894] Testing event ocfs2_write_zero_page: OK
[   57.854244] Testing event ocfs2_zero_extend_range: OK
[   57.874090] Testing event ocfs2_zero_extend: OK
[   57.894054] Testing event ocfs2_setattr: OK
[   57.914092] Testing event ocfs2_write_remove_suid: OK
[   57.933887] Testing event ocfs2_zero_partial_clusters: OK
[   57.954076] Testing event ocfs2_zero_partial_clusters_range1: OK
[   57.973871] Testing event ocfs2_zero_partial_clusters_range2: OK
[   57.994060] Testing event ocfs2_remove_inode_range: OK
[   58.013834] Testing event ocfs2_prepare_inode_for_write: OK
[   58.033872] Testing event generic_file_aio_read_ret: OK
[   58.054080] Testing event ocfs2_iget_begin: OK
[   58.073877] Testing event ocfs2_iget5_locked: OK
[   58.094078] Testing event ocfs2_iget_end: OK
[   58.113843] Testing event ocfs2_find_actor: OK
[   58.133899] Testing event ocfs2_populate_inode: OK
[   58.154053] Testing event ocfs2_read_locked_inode: OK
[   58.173850] Testing event ocfs2_check_orphan_recovery_state: OK
[   58.194038] Testing event ocfs2_validate_inode_block: OK
[   58.213844] Testing event ocfs2_inode_is_valid_to_delete: OK
[   58.233799] Testing event ocfs2_query_inode_wipe_begin: OK
[   58.253796] Testing event ocfs2_query_inode_wipe_succ: OK
[   58.274115] Testing event ocfs2_query_inode_wipe_end: OK
[   58.293821] Testing event ocfs2_cleanup_delete_inode: OK
[   58.314116] Testing event ocfs2_delete_inode: OK
[   58.333866] Testing event ocfs2_clear_inode: OK
[   58.354073] Testing event ocfs2_drop_inode: OK
[   58.373874] Testing event ocfs2_inode_revalidate: OK
[   58.394066] Testing event ocfs2_mark_inode_dirty: OK
[   58.413836] Testing event ocfs2_read_virt_blocks: OK
[   58.433952] Testing event ocfs2_refresh_slot_info: OK
[   58.454095] Testing event ocfs2_map_slot_buffers: OK
[   58.473889] Testing event ocfs2_map_slot_buffers_block: OK
[   58.494083] Testing event ocfs2_find_slot: OK
[   58.513835] Testing event ocfs2_do_node_down: OK
[   58.534133] Testing event ocfs2_remount: OK
[   58.553829] Testing event ocfs2_fill_super: OK
[   58.574095] Testing event ocfs2_parse_options: OK
[   58.593836] Testing event ocfs2_put_super: OK
[   58.614091] Testing event ocfs2_statfs: OK
[   58.633793] Testing event ocfs2_dismount_volume: OK
[   58.653804] Testing event ocfs2_initialize_super: OK
[   58.674083] Testing event ocfs2_validate_xattr_block: OK
[   58.693847] Testing event ocfs2_xattr_extend_allocation: OK
[   58.714069] Testing event ocfs2_init_xattr_set_ctxt: OK
[   58.734110] Testing event ocfs2_xattr_bucket_find: OK
[   58.754086] Testing event ocfs2_xattr_index_block_find: OK
[   58.773902] Testing event ocfs2_xattr_index_block_find_rec: OK
[   58.794048] Testing event ocfs2_iterate_xattr_buckets: OK
[   58.813850] Testing event ocfs2_iterate_xattr_bucket: OK
[   58.833910] Testing event ocfs2_cp_xattr_block_to_bucket_begin: OK
[   58.853919] Testing event ocfs2_cp_xattr_block_to_bucket_end: OK
[   58.873956] Testing event ocfs2_xattr_create_index_block_begin: OK
[   58.894155] Testing event ocfs2_xattr_create_index_block: OK
[   58.913814] Testing event ocfs2_defrag_xattr_bucket: OK
[   58.934849] Testing event ocfs2_mv_xattr_bucket_cross_cluster: OK
[   58.953884] Testing event ocfs2_divide_xattr_bucket_begin: OK
[   58.973930] Testing event ocfs2_divide_xattr_bucket_move: OK
[   58.993933] Testing event ocfs2_cp_xattr_bucket: OK
[   59.013839] Testing event ocfs2_mv_xattr_buckets: [   59.032633] vhci_hcd: changed 0
[   59.033808] Testing event ocfs2_adjust_xattr_cross_cluster: 
OK
[   59.053932] OK
[   59.066162] Testing event ocfs2_add_new_xattr_cluster_begin: OK
[   59.085939] Testing event ocfs2_add_new_xattr_cluster: OK
[   59.105922] Testing event ocfs2_add_new_xattr_cluster_insert: OK
[   59.125980] Testing event ocfs2_extend_xattr_bucket: OK
[   59.145933] Testing event ocfs2_add_new_xattr_bucket: OK
[   59.165947] Testing event ocfs2_xattr_bucket_value_truncate: OK
[   59.185966] Testing event ocfs2_rm_xattr_cluster: OK
[   59.205874] Testing event ocfs2_reflink_xattr_header: OK
[   59.225965] Testing event ocfs2_create_empty_xattr_block: OK
[   59.245901] Testing event ocfs2_xattr_set_entry_bucket: OK
[   59.265928] Testing event ocfs2_xattr_set_entry_index_block: OK
[   59.285932] Testing event ocfs2_xattr_bucket_value_refcount: OK
[   59.305933] Testing event ocfs2_reflink_xattr_buckets: OK
[   59.325933] Testing event ocfs2_reflink_xattr_rec: OK
[   59.345920] Testing event ocfs2_resv_insert: OK
[   59.365943] Testing event ocfs2_resmap_find_free_bits_begin: OK
[   59.386001] Testing event ocfs2_resmap_find_free_bits_end: OK
[   59.405928] Testing event ocfs2_resv_find_window_begin: OK
[   59.425933] Testing event ocfs2_resv_find_window_prev: OK
[   59.445936] Testing event ocfs2_resv_find_window_next: OK
[   59.465921] Testing event ocfs2_cannibalize_resv_begin: OK
[   59.485982] Testing event ocfs2_cannibalize_resv_end: OK
[   59.505922] Testing event ocfs2_resmap_resv_bits: OK
[   59.525981] Testing event ocfs2_resmap_claimed_bits_begin: OK
[   59.545928] Testing event ocfs2_resmap_claimed_bits_end: OK
[   59.565986] Testing event ocfs2_recover_local_quota_file: OK
[   59.585978] Testing event ocfs2_finish_quota_recovery: OK
[   59.605923] Testing event olq_set_dquot: OK
[   59.625980] Testing event ocfs2_validate_quota_block: OK
[   59.645916] Testing event ocfs2_sync_dquot: OK
[   59.665946] Testing event ocfs2_sync_dquot_helper: OK
[   59.685922] Testing event ocfs2_write_dquot: OK
[   59.705910] Testing event ocfs2_release_dquot: OK
[   59.725996] Testing event ocfs2_acquire_dquot: OK
[   59.745921] Testing event ocfs2_mark_dquot_dirty: OK
[   59.765928] Testing event ocfs2_search_dirblock: OK
[   59.785983] Testing event ocfs2_validate_dir_block: OK
[   59.805966] Testing event ocfs2_find_entry_el: OK
[   59.826810] Testing event ocfs2_dx_dir_search: OK
[   59.845782] Testing event ocfs2_dx_dir_search_leaf_info: OK
[   59.865729] Testing event ocfs2_delete_entry_dx: OK
[   59.885804] Testing event ocfs2_readdir: OK
[   59.905872] Testing event ocfs2_find_files_on_disk: OK
[   59.925775] Testing event ocfs2_check_dir_for_entry: OK
[   59.945998] Testing event ocfs2_dx_dir_attach_index: OK
[   59.965966] Testing event ocfs2_dx_dir_format_cluster: OK
[   59.985913] Testing event ocfs2_dx_dir_index_root_block: OK
[   60.005919] Testing event ocfs2_extend_dir: OK
[   60.025979] Testing event ocfs2_dx_dir_rebalance: OK
[   60.045962] Testing event ocfs2_dx_dir_rebalance_split: OK
[   60.065966] Testing event ocfs2_prepare_dir_for_insert: OK
[   60.085922] Testing event ocfs2_lookup: OK
[   60.105794] Testing event ocfs2_mkdir: OK
[   60.125817] Testing event ocfs2_create: OK
[   60.145819] Testing event ocfs2_unlink: OK
[   60.165836] Testing event ocfs2_symlink_create: OK
[   60.185869] Testing event ocfs2_mv_orphaned_inode_to_new: OK
[   60.205898] Testing event ocfs2_lookup_ret: OK
[   60.225949] Testing event ocfs2_mknod: OK
[   60.245879] Testing event ocfs2_link: OK
[   60.265942] Testing event ocfs2_unlink_noent: OK
[   60.285948] Testing event ocfs2_double_lock: OK
[   60.305940] Testing event ocfs2_double_lock_end: OK
[   60.325823] Testing event ocfs2_rename: OK
[   60.345936] Testing event ocfs2_rename_target_exists: OK
[   60.365804] Testing event ocfs2_rename_disagree: OK
[   60.385840] Testing event ocfs2_rename_over_existing: OK
[   60.405815] Testing event ocfs2_create_symlink_data: OK
[   60.425823] Testing event ocfs2_symlink_begin: OK
[   60.445825] Testing event ocfs2_blkno_stringify: OK
[   60.465821] Testing event ocfs2_orphan_add_begin: OK
[   60.485971] Testing event ocfs2_orphan_add_end: OK
[   60.505830] Testing event ocfs2_orphan_del: OK
[   60.525823] Testing event ocfs2_dentry_revalidate: OK
[   60.545808] Testing event ocfs2_dentry_revalidate_negative: OK
[   60.565952] Testing event ocfs2_dentry_revalidate_delete: OK
[   60.585959] Testing event ocfs2_dentry_revalidate_orphaned: OK
[   60.605814] Testing event ocfs2_dentry_revalidate_nofsdata: OK
[   60.625819] Testing event ocfs2_dentry_revalidate_ret: OK
[   60.645717] Testing event ocfs2_find_local_alias: OK
[   60.665701] Testing event ocfs2_dentry_attach_lock: OK
[   60.685730] Testing event ocfs2_dentry_attach_lock_found: OK
[   60.705729] Testing event ocfs2_get_dentry_begin: OK
[   60.725723] Testing event ocfs2_get_dentry_test_bit: OK
[   60.745904] Testing event ocfs2_get_dentry_stale: OK
[   60.765717] Testing event ocfs2_get_dentry_generation: OK
[   60.785747] Testing event ocfs2_get_dentry_end: OK
[   60.805786] Testing event ocfs2_get_parent: OK
[   60.825931] Testing event ocfs2_get_parent_end: OK
[   60.845743] Testing event ocfs2_encode_fh_begin: OK
[   60.865758] Testing event ocfs2_encode_fh_self: OK
[   60.885769] Testing event ocfs2_encode_fh_parent: OK
[   60.905745] Testing event ocfs2_encode_fh_type: OK
[   60.925753] Testing event ocfs2_commit_cache_begin: OK
[   60.945757] Testing event ocfs2_commit_cache_end: OK
[   60.965755] Testing event ocfs2_extend_trans: OK
[   60.985752] Testing event ocfs2_extend_trans_restart: OK
[   61.005919] Testing event ocfs2_journal_access: OK
[   61.025741] Testing event ocfs2_journal_dirty: OK
[   61.045889] Testing event ocfs2_journal_init: [   61.052107] vhci_hcd: changed 0
OK
[   61.065888] Testing event ocfs2_journal_init_maxlen: OK
[   61.085815] Testing event ocfs2_journal_shutdown: OK
[   61.105917] Testing event ocfs2_journal_shutdown_wait: OK
[   61.125773] Testing event ocfs2_complete_recovery: OK
[   61.145901] Testing event ocfs2_complete_recovery_end: OK
[   61.165782] Testing event ocfs2_complete_recovery_slot: OK
[   61.185775] Testing event ocfs2_recovery_thread_node: OK
[   61.205774] Testing event ocfs2_recovery_thread_end: OK
[   61.225750] Testing event ocfs2_recovery_thread: OK
[   61.245762] Testing event ocfs2_replay_journal_recovered: OK
[   61.265762] Testing event ocfs2_replay_journal_lock_err: OK
[   61.285797] Testing event ocfs2_replay_journal_skip: OK
[   61.305762] Testing event ocfs2_recover_node: OK
[   61.325886] Testing event ocfs2_recover_node_skip: OK
[   61.345772] Testing event ocfs2_mark_dead_nodes: OK
[   61.365762] Testing event ocfs2_queue_orphan_scan_begin: OK
[   61.385920] Testing event ocfs2_queue_orphan_scan_end: OK
[   61.405763] Testing event ocfs2_orphan_filldir: OK
[   61.425751] Testing event ocfs2_recover_orphans: OK
[   61.445748] Testing event ocfs2_recover_orphans_iput: OK
[   61.465758] Testing event ocfs2_wait_on_mount: OK
[   61.485915] Testing event ocfs2_read_blocks_sync: OK
[   61.505760] Testing event ocfs2_read_blocks_sync_jbd: OK
[   61.525756] Testing event ocfs2_read_blocks_from_disk: OK
[   61.545752] Testing event ocfs2_read_blocks_bh: OK
[   61.565892] Testing event ocfs2_read_blocks_end: OK
[   61.585876] Testing event ocfs2_write_block: OK
[   61.605753] Testing event ocfs2_read_blocks_begin: OK
[   61.625754] Testing event ocfs2_purge_copied_metadata_tree: OK
[   61.645737] Testing event ocfs2_metadata_cache_purge: OK
[   61.665743] Testing event ocfs2_buffer_cached_begin: OK
[   61.685761] Testing event ocfs2_buffer_cached_end: OK
[   61.705747] Testing event ocfs2_append_cache_array: OK
[   61.725750] Testing event ocfs2_insert_cache_tree: OK
[   61.745759] Testing event ocfs2_expand_cache: OK
[   61.765746] Testing event ocfs2_set_buffer_uptodate: OK
[   61.785824] Testing event ocfs2_set_buffer_uptodate_begin: OK
[   61.805853] Testing event ocfs2_remove_metadata_array: OK
[   61.825802] Testing event ocfs2_remove_metadata_tree: OK
[   61.845805] Testing event ocfs2_remove_block_from_cache: OK
[   61.865809] Testing event xfs_attr_list_sf: OK
[   61.885830] Testing event xfs_attr_list_sf_all: OK
[   61.905944] Testing event xfs_attr_list_leaf: OK
[   61.925819] Testing event xfs_attr_list_leaf_end: OK
[   61.945807] Testing event xfs_attr_list_full: OK
[   61.965808] Testing event xfs_attr_list_add: OK
[   61.985817] Testing event xfs_attr_list_wrong_blk: OK
[   62.005810] Testing event xfs_attr_list_notfound: OK
[   62.025830] Testing event xfs_perag_get: OK
[   62.045819] Testing event xfs_perag_get_tag: OK
[   62.065818] Testing event xfs_perag_put: OK
[   62.085972] Testing event xfs_perag_set_reclaim: OK
[   62.105821] Testing event xfs_perag_clear_reclaim: OK
[   62.125819] Testing event xfs_attr_list_node_descend: OK
[   62.145807] Testing event xfs_iext_insert: OK
[   62.165806] Testing event xfs_iext_remove: OK
[   62.185802] Testing event xfs_bmap_pre_update: OK
[   62.205806] Testing event xfs_bmap_post_update: OK
[   62.225835] Testing event xfs_extlist: OK
[   62.245832] Testing event xfs_buf_init: OK
[   62.265814] Testing event xfs_buf_free: OK
[   62.285815] Testing event xfs_buf_hold: OK
[   62.305811] Testing event xfs_buf_rele: OK
[   62.325810] Testing event xfs_buf_iodone: OK
[   62.345803] Testing event xfs_buf_iorequest: OK
[   62.365814] Testing event xfs_buf_bawrite: OK
[   62.385872] Testing event xfs_buf_lock: OK
[   62.405792] Testing event xfs_buf_lock_done: OK
[   62.425817] Testing event xfs_buf_trylock: OK
[   62.445827] Testing event xfs_buf_unlock: OK
[   62.465814] Testing event xfs_buf_iowait: OK
[   62.485968] Testing event xfs_buf_iowait_done: OK
[   62.505825] Testing event xfs_buf_delwri_queue: OK
[   62.525795] Testing event xfs_buf_delwri_queued: OK
[   62.545841] Testing event xfs_buf_delwri_split: OK
[   62.565793] Testing event xfs_buf_get_uncached: OK
[   62.585955] Testing event xfs_bdstrat_shut: OK
[   62.616865] Testing event xfs_buf_item_relse: OK
[   62.633811] Testing event xfs_buf_item_iodone: OK
[   62.653776] Testing event xfs_buf_item_iodone_async: OK
[   62.673779] Testing event xfs_buf_error_relse: OK
[   62.693931] Testing event xfs_trans_read_buf_io: OK
[   62.713794] Testing event xfs_trans_read_buf_shut: OK
[   62.733958] Testing event xfs_btree_corrupt: OK
[   62.753771] Testing event xfs_da_btree_corrupt: OK
[   62.773988] Testing event xfs_reset_dqcounts: OK
[   62.793776] Testing event xfs_inode_item_push: OK
[   62.813932] Testing event xfs_buf_find: OK
[   62.833827] Testing event xfs_buf_get: OK
[   62.853773] Testing event xfs_buf_read: OK
[   62.873817] Testing event xfs_buf_ioerror: OK
[   62.893817] Testing event xfs_buf_item_size: OK
[   62.913952] Testing event xfs_buf_item_size_stale: OK
[   62.933883] Testing event xfs_buf_item_format: OK
[   62.953822] Testing event xfs_buf_item_format_stale: OK
[   62.973825] Testing event xfs_buf_item_pin: OK
[   62.993956] Testing event xfs_buf_item_unpin: OK
[   63.013844] Testing event xfs_buf_item_unpin_stale: OK
[   63.033854] Testing event xfs_buf_item_unlock: OK
[   63.053841] Testing event xfs_buf_item_unlock_stale: OK
[   63.073851] Testing event xfs_buf_item_committed: OK
[   63.093939] Testing event xfs_buf_item_push: OK
[   63.113817] Testing event xfs_trans_get_buf: OK
[   63.133859] Testing event xfs_trans_get_buf_recur: OK
[   63.153831] Testing event xfs_trans_getsb: OK
[   63.173827] Testing event xfs_trans_getsb_recur: OK
[   63.193803] Testing event xfs_trans_read_buf: OK
[   63.213815] Testing event xfs_trans_read_buf_recur: OK
[   63.233841] Testing event xfs_trans_log_buf: OK
[   63.253826] Testing event xfs_trans_brelse: OK
[   63.273959] Testing event xfs_trans_bjoin: OK
[   63.293834] Testing event xfs_trans_bhold: OK
[   63.313843] Testing event xfs_trans_bhold_release: OK
[   63.333850] Testing event xfs_trans_binval: OK
[   63.353812] Testing event xfs_ilock: OK
[   63.373857] Testing event xfs_ilock_nowait: OK
[   63.393823] Testing event xfs_ilock_demote: OK
[   63.413820] Testing event xfs_iunlock: OK
[   63.433856] Testing event xfs_iget_skip: OK
[   63.453944] Testing event xfs_iget_reclaim: OK
[   63.474551] Testing event xfs_iget_reclaim_fail: OK
[   63.494028] Testing event xfs_iget_hit: OK
[   63.513965] Testing event xfs_iget_miss: OK
[   63.533994] Testing event xfs_getattr: OK
[   63.553828] Testing event xfs_setattr: OK
[   63.573980] Testing event xfs_readlink: OK
[   63.593858] Testing event xfs_alloc_file_space: OK
[   63.613879] Testing event xfs_free_file_space: OK
[   63.634030] Testing event xfs_readdir: OK
[   63.653929] Testing event xfs_get_acl: OK
[   63.673927] Testing event xfs_vm_bmap: OK
[   63.694024] Testing event xfs_file_ioctl: OK
[   63.713969] Testing event xfs_file_compat_ioctl: OK
[   63.734101] Testing event xfs_ioctl_setattr: OK
[   63.753967] Testing event xfs_dir_fsync: OK
[   63.773984] Testing event xfs_file_fsync: OK
[   63.793979] Testing event xfs_destroy_inode: OK
[   63.814035] Testing event xfs_dirty_inode: [   63.824984] vhci_hcd: changed 0
OK
[   63.834037] Testing event xfs_evict_inode: OK
[   63.854037] Testing event xfs_dquot_dqalloc: OK
[   63.873978] Testing event xfs_dquot_dqdetach: OK
[   63.893983] Testing event xfs_ihold: OK
[   63.913981] Testing event xfs_irele: OK
[   63.933955] Testing event xfs_inode_pin: OK
[   63.953852] Testing event xfs_inode_unpin: OK
[   63.974040] Testing event xfs_inode_unpin_nowait: OK
[   63.993839] Testing event xfs_remove: OK
[   64.013855] Testing event xfs_link: OK
[   64.034508] Testing event xfs_lookup: OK
[   64.053770] Testing event xfs_create: OK
[   64.073794] Testing event xfs_symlink: OK
[   64.093716] Testing event xfs_rename: OK
[   64.113880] Testing event xfs_dqadjust: OK
[   64.133837] Testing event xfs_dqreclaim_want: OK
[   64.153767] Testing event xfs_dqreclaim_dirty: OK
[   64.173803] Testing event xfs_dqreclaim_busy: OK
[   64.194255] Testing event xfs_dqreclaim_done: OK
[   64.213833] Testing event xfs_dqattach_found: OK
[   64.233967] Testing event xfs_dqattach_get: OK
[   64.253810] Testing event xfs_dqalloc: OK
[   64.273723] Testing event xfs_dqtobp_read: OK
[   64.293780] Testing event xfs_dqread: OK
[   64.313795] Testing event xfs_dqread_fail: OK
[   64.333772] Testing event xfs_dqget_hit: OK
[   64.353797] Testing event xfs_dqget_miss: OK
[   64.373810] Testing event xfs_dqget_freeing: OK
[   64.393891] Testing event xfs_dqget_dup: OK
[   64.413888] Testing event xfs_dqput: OK
[   64.433813] Testing event xfs_dqput_wait: OK
[   64.453771] Testing event xfs_dqput_free: OK
[   64.473805] Testing event xfs_dqrele: OK
[   64.493766] Testing event xfs_dqflush: OK
[   64.513775] Testing event xfs_dqflush_force: OK
[   64.533762] Testing event xfs_dqflush_done: OK
[   64.553704] Testing event xfs_log_done_nonperm: OK
[   64.573809] Testing event xfs_log_done_perm: OK
[   64.593885] Testing event xfs_log_umount_write: OK
[   64.613759] Testing event xfs_log_grant_sleep: OK
[   64.633961] Testing event xfs_log_grant_wake: OK
[   64.653755] Testing event xfs_log_grant_wake_up: OK
[   64.673729] Testing event xfs_log_reserve: OK
[   64.693698] Testing event xfs_log_reserve_exit: OK
[   64.713768] Testing event xfs_log_regrant: OK
[   64.733960] Testing event xfs_log_regrant_exit: OK
[   64.753799] Testing event xfs_log_regrant_reserve_enter: OK
[   64.773794] Testing event xfs_log_regrant_reserve_exit: OK
[   64.793768] Testing event xfs_log_regrant_reserve_sub: OK
[   64.813749] Testing event xfs_log_ungrant_enter: OK
[   64.833712] Testing event xfs_log_ungrant_exit: OK
[   64.853868] Testing event xfs_log_ungrant_sub: OK
[   64.873845] Testing event xfs_log_force: OK
[   64.893891] Testing event xfs_ail_push: OK
[   64.913788] Testing event xfs_ail_pinned: OK
[   64.933974] Testing event xfs_ail_locked: OK
[   64.953840] Testing event xfs_ail_flushing: OK
[   64.973840] Testing event xfs_file_read: OK
[   64.993858] Testing event xfs_file_buffered_write: OK
[   65.013739] Testing event xfs_file_direct_write: OK
[   65.033736] Testing event xfs_file_splice_read: OK
[   65.053748] Testing event xfs_file_splice_write: OK
[   65.073844] Testing event xfs_writepage: OK
[   65.093796] Testing event xfs_releasepage: OK
[   65.113926] Testing event xfs_invalidatepage: OK
[   65.133727] Testing event xfs_map_blocks_found: OK
[   65.153864] Testing event xfs_map_blocks_alloc: OK
[   65.173835] Testing event xfs_get_blocks_found: OK
[   65.193744] Testing event xfs_get_blocks_alloc: OK
[   65.213731] Testing event xfs_delalloc_enospc: OK
[   65.233733] Testing event xfs_unwritten_convert: OK
[   65.253725] Testing event xfs_get_blocks_notfound: OK
[   65.273829] Testing event xfs_setfilesize: OK
[   65.293728] Testing event xfs_itruncate_extents_start: OK
[   65.313741] Testing event xfs_itruncate_extents_end: OK
[   65.333898] Testing event xfs_pagecache_inval: OK
[   65.353769] Testing event xfs_bunmap: OK
[   65.373820] Testing event xfs_extent_busy: OK
[   65.393902] Testing event xfs_extent_busy_enomem: OK
[   65.413855] Testing event xfs_extent_busy_force: OK
[   65.433805] Testing event xfs_extent_busy_reuse: OK
[   65.453839] Testing event xfs_extent_busy_clear: OK
[   65.473795] Testing event xfs_extent_busy_trim: OK
[   65.493730] Testing event xfs_trans_commit_lsn: OK
[   65.513868] Testing event xfs_agf: OK
[   65.533719] Testing event xfs_free_extent: OK
[   65.553660] Testing event xfs_alloc_exact_done: OK
[   65.573761] Testing event xfs_alloc_exact_notfound: OK
[   65.593674] Testing event xfs_alloc_exact_error: OK
[   65.613739] Testing event xfs_alloc_near_nominleft: OK
[   65.633734] Testing event xfs_alloc_near_first: OK
[   65.653761] Testing event xfs_alloc_near_greater: OK
[   65.673908] Testing event xfs_alloc_near_lesser: OK
[   65.693871] Testing event xfs_alloc_near_error: OK
[   65.713969] Testing event xfs_alloc_near_noentry: OK
[   65.733991] Testing event xfs_alloc_near_busy: OK
[   65.753976] Testing event xfs_alloc_size_neither: OK
[   65.773882] Testing event xfs_alloc_size_noentry: OK
[   65.793942] Testing event xfs_alloc_size_nominleft: OK
[   65.813975] Testing event xfs_alloc_size_done: OK
[   65.833855] Testing event xfs_alloc_size_error: [   65.840186] vhci_hcd: changed 0
OK
[   65.853974] Testing event xfs_alloc_size_busy: OK
[   65.873896] Testing event xfs_alloc_small_freelist: OK
[   65.893898] Testing event xfs_alloc_small_notenough: OK
[   65.913895] Testing event xfs_alloc_small_done: OK
[   65.933886] Testing event xfs_alloc_small_error: OK
[   65.953964] Testing event xfs_alloc_vextent_badargs: OK
[   65.973969] Testing event xfs_alloc_vextent_nofix: OK
[   65.993961] Testing event xfs_alloc_vextent_noagbp: OK
[   66.013819] Testing event xfs_alloc_vextent_loopfailed: OK
[   66.033843] Testing event xfs_alloc_vextent_allfailed: OK
[   66.053956] Testing event xfs_dir2_sf_addname: OK
[   66.073871] Testing event xfs_dir2_sf_create: OK
[   66.093957] Testing event xfs_dir2_sf_lookup: OK
[   66.113958] Testing event xfs_dir2_sf_replace: OK
[   66.133865] Testing event xfs_dir2_sf_removename: OK
[   66.165053] Testing event xfs_dir2_sf_toino4: OK
[   66.181814] Testing event xfs_dir2_sf_toino8: OK
[   66.201960] Testing event xfs_dir2_sf_to_block: OK
[   66.221952] Testing event xfs_dir2_block_addname: OK
[   66.241942] Testing event xfs_dir2_block_lookup: OK
[   66.261820] Testing event xfs_dir2_block_replace: OK
[   66.281893] Testing event xfs_dir2_block_removename: OK
[   66.301941] Testing event xfs_dir2_block_to_sf: OK
[   66.321818] Testing event xfs_dir2_block_to_leaf: OK
[   66.341786] Testing event xfs_dir2_leaf_addname: OK
[   66.361949] Testing event xfs_dir2_leaf_lookup: OK
[   66.381801] Testing event xfs_dir2_leaf_replace: OK
[   66.401951] Testing event xfs_dir2_leaf_removename: OK
[   66.421819] Testing event xfs_dir2_leaf_to_block: OK
[   66.441940] Testing event xfs_dir2_leaf_to_node: OK
[   66.461813] Testing event xfs_dir2_node_addname: OK
[   66.481814] Testing event xfs_dir2_node_lookup: OK
[   66.501951] Testing event xfs_dir2_node_replace: OK
[   66.521950] Testing event xfs_dir2_node_removename: OK
[   66.541942] Testing event xfs_dir2_node_to_leaf: OK
[   66.561948] Testing event xfs_attr_sf_add: OK
[   66.581818] Testing event xfs_attr_sf_addname: OK
[   66.601950] Testing event xfs_attr_sf_create: OK
[   66.621950] Testing event xfs_attr_sf_lookup: OK
[   66.641932] Testing event xfs_attr_sf_remove: OK
[   66.661807] Testing event xfs_attr_sf_removename: OK
[   66.681825] Testing event xfs_attr_sf_to_leaf: OK
[   66.701941] Testing event xfs_attr_leaf_add: OK
[   66.721866] Testing event xfs_attr_leaf_add_old: OK
[   66.741923] Testing event xfs_attr_leaf_add_new: OK
[   66.761818] Testing event xfs_attr_leaf_addname: OK
[   66.781810] Testing event xfs_attr_leaf_create: OK
[   66.801945] Testing event xfs_attr_leaf_lookup: OK
[   66.821944] Testing event xfs_attr_leaf_replace: OK
[   66.841811] Testing event xfs_attr_leaf_removename: OK
[   66.861938] Testing event xfs_attr_leaf_split: OK
[   66.881819] Testing event xfs_attr_leaf_split_before: OK
[   66.901934] Testing event xfs_attr_leaf_split_after: OK
[   66.921827] Testing event xfs_attr_leaf_clearflag: OK
[   66.941921] Testing event xfs_attr_leaf_setflag: OK
[   66.961940] Testing event xfs_attr_leaf_flipflags: OK
[   66.981832] Testing event xfs_attr_leaf_to_sf: OK
[   67.001929] Testing event xfs_attr_leaf_to_node: OK
[   67.021942] Testing event xfs_attr_leaf_rebalance: OK
[   67.041931] Testing event xfs_attr_leaf_unbalance: OK
[   67.061936] Testing event xfs_attr_node_addname: OK
[   67.081825] Testing event xfs_attr_node_lookup: OK
[   67.101820] Testing event xfs_attr_node_replace: OK
[   67.121833] Testing event xfs_attr_node_removename: OK
[   67.141923] Testing event xfs_da_split: OK
[   67.161849] Testing event xfs_da_join: OK
[   67.181819] Testing event xfs_da_link_before: OK
[   67.201932] Testing event xfs_da_link_after: OK
[   67.221945] Testing event xfs_da_unlink_back: OK
[   67.241933] Testing event xfs_da_unlink_forward: OK
[   67.261933] Testing event xfs_da_root_split: OK
[   67.281821] Testing event xfs_da_root_join: OK
[   67.301939] Testing event xfs_da_node_add: OK
[   67.321951] Testing event xfs_da_node_create: OK
[   67.341923] Testing event xfs_da_node_split: OK
[   67.361935] Testing event xfs_da_node_remove: OK
[   67.381809] Testing event xfs_da_node_rebalance: OK
[   67.401819] Testing event xfs_da_node_unbalance: OK
[   67.421814] Testing event xfs_da_swap_lastblock: OK
[   67.441922] Testing event xfs_da_grow_inode: OK
[   67.461934] Testing event xfs_da_shrink_inode: OK
[   67.481820] Testing event xfs_dir2_leafn_add: OK
[   67.501819] Testing event xfs_dir2_leafn_remove: OK
[   67.521822] Testing event xfs_dir2_grow_inode: OK
[   67.541924] Testing event xfs_dir2_shrink_inode: OK
[   67.561926] Testing event xfs_dir2_leafn_moveents: OK
[   67.581818] Testing event xfs_swap_extent_before: OK
[   67.601923] Testing event xfs_swap_extent_after: OK
[   67.621925] Testing event xfs_log_recover_item_add: OK
[   67.641922] Testing event xfs_log_recover_item_add_cont: OK
[   67.661917] Testing event xfs_log_recover_item_reorder_head: OK
[   67.681813] Testing event xfs_log_recover_item_reorder_tail: OK
[   67.701816] Testing event xfs_log_recover_item_recover: OK
[   67.721926] Testing event xfs_log_recover_buf_not_cancel: OK
[   67.741906] Testing event xfs_log_recover_buf_cancel: OK
[   67.761946] Testing event xfs_log_recover_buf_cancel_add: OK
[   67.781820] Testing event xfs_log_recover_buf_cancel_ref_inc: OK
[   67.801920] Testing event xfs_log_recover_buf_recover: OK
[   67.821930] Testing event xfs_log_recover_buf_inode_buf: OK
[   67.841804] Testing event xfs_log_recover_buf_reg_buf: [   67.856142] vhci_hcd: changed 0
OK
[   67.861768] Testing event xfs_log_recover_buf_dquot_buf: OK
[   67.882717] Testing event xfs_log_recover_inode_recover: OK
[   67.901558] Testing event xfs_log_recover_inode_cancel: OK
[   67.922021] Testing event xfs_log_recover_inode_skip: OK
[   67.942027] Testing event xfs_discard_extent: OK
[   67.961762] Testing event xfs_discard_toosmall: OK
[   67.981692] Testing event xfs_discard_exclude: OK
[   68.002008] Testing event xfs_discard_busy: OK
[   68.021807] Testing event jbd2_checkpoint: OK
[   68.041991] Testing event jbd2_start_commit: OK
[   68.061820] Testing event jbd2_commit_locking: OK
[   68.081798] Testing event jbd2_commit_flushing: OK
[   68.101707] Testing event jbd2_commit_logging: OK
[   68.122031] Testing event jbd2_drop_transaction: OK
[   68.142016] Testing event jbd2_end_commit: OK
[   68.161827] Testing event jbd2_submit_inode_data: OK
[   68.181652] Testing event jbd2_run_stats: OK
[   68.202030] Testing event jbd2_checkpoint_stats: OK
[   68.222041] Testing event jbd2_update_log_tail: OK
[   68.241976] Testing event jbd2_write_superblock: OK
[   68.261726] Testing event jbd_checkpoint: OK
[   68.282032] Testing event jbd_start_commit: OK
[   68.301825] Testing event jbd_commit_locking: OK
[   68.321668] Testing event jbd_commit_flushing: OK
[   68.342032] Testing event jbd_commit_logging: OK
[   68.361743] Testing event jbd_drop_transaction: OK
[   68.381671] Testing event jbd_end_commit: OK
[   68.401972] Testing event jbd_do_submit_data: OK
[   68.421849] Testing event jbd_cleanup_journal_tail: OK
[   68.441783] Testing event journal_write_superblock: OK
[   68.461736] Testing event ext4_free_inode: OK
[   68.482076] Testing event ext4_request_inode: OK
[   68.502043] Testing event ext4_allocate_inode: OK
[   68.521746] Testing event ext4_evict_inode: OK
[   68.541736] Testing event ext4_drop_inode: OK
[   68.562060] Testing event ext4_mark_inode_dirty: OK
[   68.582098] Testing event ext4_begin_ordered_truncate: OK
[   68.602068] Testing event ext4_write_begin: OK
[   68.622069] Testing event ext4_da_write_begin: OK
[   68.641808] Testing event ext4_ordered_write_end: OK
[   68.662042] Testing event ext4_writeback_write_end: OK
[   68.681781] Testing event ext4_journalled_write_end: OK
[   68.702011] Testing event ext4_da_write_end: OK
[   68.722112] Testing event ext4_da_writepages: OK
[   68.741839] Testing event ext4_da_write_pages: OK
[   68.761795] Testing event ext4_da_writepages_result: OK
[   68.782084] Testing event ext4_writepage: OK
[   68.801808] Testing event ext4_readpage: OK
[   68.822104] Testing event ext4_releasepage: OK
[   68.841829] Testing event ext4_invalidatepage: OK
[   68.862000] Testing event ext4_discard_blocks: OK
[   68.881947] Testing event ext4_mb_new_inode_pa: OK
[   68.901905] Testing event ext4_mb_new_group_pa: OK
[   68.921904] Testing event ext4_mb_release_inode_pa: OK
[   68.943452] Testing event ext4_mb_release_group_pa: OK
[   68.962730] Testing event ext4_discard_preallocations: OK
[   68.982702] Testing event ext4_mb_discard_preallocations: OK
[   69.002700] Testing event ext4_request_blocks: OK
[   69.021970] Testing event ext4_allocate_blocks: OK
[   69.041836] Testing event ext4_free_blocks: OK
[   69.061917] Testing event ext4_sync_file_enter: OK
[   69.081826] Testing event ext4_sync_file_exit: OK
[   69.101820] Testing event ext4_sync_fs: OK
[   69.121821] Testing event ext4_alloc_da_blocks: OK
[   69.141898] Testing event ext4_mballoc_alloc: OK
[   69.161834] Testing event ext4_mballoc_prealloc: OK
[   69.181829] Testing event ext4_mballoc_discard: OK
[   69.202690] Testing event ext4_mballoc_free: OK
[   69.221940] Testing event ext4_forget: OK
[   69.241894] Testing event ext4_da_update_reserve_space: OK
[   69.261824] Testing event ext4_da_reserve_space: OK
[   69.281946] Testing event ext4_da_release_space: OK
[   69.301945] Testing event ext4_mb_bitmap_load: OK
[   69.321950] Testing event ext4_mb_buddy_bitmap_load: OK
[   69.341935] Testing event ext4_read_block_bitmap_load: OK
[   69.361945] Testing event ext4_load_inode_bitmap: OK
[   69.381825] Testing event ext4_direct_IO_enter: OK
[   69.401812] Testing event ext4_direct_IO_exit: OK
[   69.421804] Testing event ext4_fallocate_enter: OK
[   69.441803] Testing event ext4_fallocate_exit: OK
[   69.461810] Testing event ext4_unlink_enter: OK
[   69.481946] Testing event ext4_unlink_exit: OK
[   69.501945] Testing event ext4_truncate_enter: OK
[   69.521936] Testing event ext4_truncate_exit: OK
[   69.541930] Testing event ext4_ext_convert_to_initialized_enter: OK
[   69.561814] Testing event ext4_ext_convert_to_initialized_fastpath: OK
[   69.581944] Testing event ext4_ext_map_blocks_enter: OK
[   69.601946] Testing event ext4_ind_map_blocks_enter: OK
[   69.621814] Testing event ext4_ext_map_blocks_exit: OK
[   69.641929] Testing event ext4_ind_map_blocks_exit: OK
[   69.661944] Testing event ext4_ext_load_extent: OK
[   69.681805] Testing event ext4_load_inode: OK
[   69.701932] Testing event ext4_journal_start: OK
[   69.733084] Testing event ext4_trim_extent: OK
[   69.749828] Testing event ext4_trim_all_free: OK
[   69.769808] Testing event ext4_ext_handle_uninitialized_extents: OK
[   69.789830] Testing event ext4_get_implied_cluster_alloc_exit: OK
[   69.809900] Testing event ext4_ext_put_in_cache: OK
[   69.829774] Testing event ext4_ext_in_cache: OK
[   69.849943] Testing event ext4_find_delalloc_range: OK
[   69.869942] Testing event ext4_get_reserved_cluster_alloc: [   69.872229] vhci_hcd: changed 0
OK
[   69.890148] Testing event ext4_ext_show_extent: OK
[   69.909802] Testing event ext4_remove_blocks: OK
[   69.929806] Testing event ext4_ext_rm_leaf: OK
[   69.949801] Testing event ext4_ext_rm_idx: OK
[   69.969925] Testing event ext4_ext_remove_space: OK
[   69.989786] Testing event ext4_ext_remove_space_done: OK
[   70.009941] Testing event ext3_free_inode: OK
[   70.030006] Testing event ext3_request_inode: OK
[   70.049959] Testing event ext3_allocate_inode: OK
[   70.069947] Testing event ext3_evict_inode: OK
[   70.089944] Testing event ext3_drop_inode: OK
[   70.109950] Testing event ext3_mark_inode_dirty: OK
[   70.129942] Testing event ext3_write_begin: OK
[   70.149809] Testing event ext3_ordered_write_end: OK
[   70.169947] Testing event ext3_writeback_write_end: OK
[   70.189963] Testing event ext3_journalled_write_end: OK
[   70.209814] Testing event ext3_ordered_writepage: OK
[   70.229806] Testing event ext3_writeback_writepage: OK
[   70.249949] Testing event ext3_journalled_writepage: OK
[   70.269944] Testing event ext3_readpage: OK
[   70.289919] Testing event ext3_releasepage: OK
[   70.309929] Testing event ext3_invalidatepage: OK
[   70.329934] Testing event ext3_discard_blocks: OK
[   70.349791] Testing event ext3_request_blocks: OK
[   70.369794] Testing event ext3_allocate_blocks: OK
[   70.389790] Testing event ext3_free_blocks: OK
[   70.409787] Testing event ext3_sync_file_enter: OK
[   70.429795] Testing event ext3_sync_file_exit: OK
[   70.449938] Testing event ext3_sync_fs: OK
[   70.469790] Testing event ext3_rsv_window_add: OK
[   70.489782] Testing event ext3_discard_reservation: OK
[   70.509787] Testing event ext3_alloc_new_reservation: OK
[   70.529788] Testing event ext3_reserved: OK
[   70.549793] Testing event ext3_forget: OK
[   70.569923] Testing event ext3_read_block_bitmap: OK
[   70.589789] Testing event ext3_direct_IO_enter: OK
[   70.609943] Testing event ext3_direct_IO_exit: OK
[   70.629933] Testing event ext3_unlink_enter: OK
[   70.650785] Testing event ext3_unlink_exit: OK
[   70.670796] Testing event ext3_truncate_enter: OK
[   70.690822] Testing event ext3_truncate_exit: OK
[   70.709779] Testing event ext3_get_blocks_enter: OK
[   70.729683] Testing event ext3_get_blocks_exit: OK
[   70.749923] Testing event ext3_load_inode: OK
[   70.769948] Testing event writeback_nothread: OK
[   70.789747] Testing event writeback_queue: OK
[   70.810757] Testing event writeback_exec: OK
[   70.830818] Testing event writeback_start: OK
[   70.849943] Testing event writeback_written: OK
[   70.869997] Testing event writeback_wait: OK
[   70.889732] Testing event writeback_pages_written: OK
[   70.909694] Testing event writeback_nowork: OK
[   70.929685] Testing event writeback_wake_background: OK
[   70.949730] Testing event writeback_wake_thread: OK
[   70.969687] Testing event writeback_wake_forker_thread: OK
[   70.989733] Testing event writeback_bdi_register: OK
[   71.009744] Testing event writeback_bdi_unregister: OK
[   71.029684] Testing event writeback_thread_start: OK
[   71.049914] Testing event writeback_thread_stop: OK
[   71.069844] Testing event wbc_writepage: OK
[   71.089849] Testing event writeback_queue_io: OK
[   71.109882] Testing event global_dirty_state: OK
[   71.129833] Testing event bdi_dirty_ratelimit: OK
[   71.149837] Testing event balance_dirty_pages: OK
[   71.169825] Testing event writeback_sb_inodes_requeue: OK
[   71.189850] Testing event writeback_congestion_wait: OK
[   71.209733] Testing event writeback_wait_iff_congested: OK
[   71.229802] Testing event writeback_single_inode: OK
[   71.250519] Testing event mm_compaction_isolate_migratepages: OK
[   71.269775] Testing event mm_compaction_isolate_freepages: OK
[   71.289832] Testing event mm_compaction_migratepages: OK
[   71.309689] Testing event kmalloc: OK
[   71.329879] Testing event kmem_cache_alloc: OK
[   71.349780] Testing event kmalloc_node: OK
[   71.369795] Testing event kmem_cache_alloc_node: OK
[   71.389804] Testing event kfree: OK
[   71.409903] Testing event kmem_cache_free: OK
[   71.429873] Testing event mm_page_free: OK
[   71.449849] Testing event mm_page_free_batched: OK
[   71.469794] Testing event mm_page_alloc: OK
[   71.489768] Testing event mm_page_alloc_zone_locked: OK
[   71.509824] Testing event mm_page_pcpu_drain: OK
[   71.529832] Testing event mm_page_alloc_extfrag: OK
[   71.549724] Testing event mm_vmscan_kswapd_sleep: OK
[   71.569712] Testing event mm_vmscan_kswapd_wake: OK
[   71.589768] Testing event mm_vmscan_wakeup_kswapd: OK
[   71.609955] Testing event mm_vmscan_direct_reclaim_begin: OK
[   71.629882] Testing event mm_vmscan_memcg_reclaim_begin: OK
[   71.649922] Testing event mm_vmscan_memcg_softlimit_reclaim_begin: OK
[   71.669818] Testing event mm_vmscan_direct_reclaim_end: OK
[   71.689735] Testing event mm_vmscan_memcg_reclaim_end: OK
[   71.709780] Testing event mm_vmscan_memcg_softlimit_reclaim_end: OK
[   71.729747] Testing event mm_shrink_slab_start: OK
[   71.749756] Testing event mm_shrink_slab_end: OK
[   71.769797] Testing event mm_vmscan_lru_isolate: OK
[   71.789787] Testing event mm_vmscan_memcg_isolate: OK
[   71.809853] Testing event mm_vmscan_writepage: OK
[   71.829787] Testing event mm_vmscan_lru_shrink_inactive: OK
[   71.849887] Testing event oom_score_adj_update: OK
[   71.869894] Testing event rpm_suspend: [   71.888238] vhci_hcd: changed 0
OK
[   71.890772] Testing event rpm_resume: OK
[   71.909887] Testing event rpm_idle: OK
[   71.929741] Testing event rpm_return_int: OK
[   71.949927] Testing event cpu_idle: OK
[   71.969900] Testing event cpu_frequency: OK
[   71.989886] Testing event machine_suspend: OK
[   72.009939] Testing event wakeup_source_activate: OK
[   72.029805] Testing event wakeup_source_deactivate: OK
[   72.050687] Testing event power_start: OK
[   72.070686] Testing event power_frequency: OK
[   72.089906] Testing event power_end: OK
[   72.109844] Testing event clock_enable: OK
[   72.129879] Testing event clock_disable: OK
[   72.149892] Testing event clock_set_rate: OK
[   72.169862] Testing event power_domain_target: OK
[   72.189845] Testing event ftrace_test_filter: OK
[   72.209864] Testing event module_load: OK
[   72.229733] Testing event module_free: OK
[   72.249756] Testing event module_get: OK
[   72.265696] Testing event module_put: OK
[   72.281754] Testing event module_request: OK
[   72.301792] Testing event lock_acquire: OK
[   72.321828] Testing event lock_release: OK
[   72.341890] Testing event lock_contended: OK
[   72.361753] Testing event lock_acquired: OK
[   72.381779] Testing event sched_kthread_stop: OK
[   72.401888] Testing event sched_kthread_stop_ret: OK
[   72.421764] Testing event sched_wakeup: OK
[   72.441820] Testing event sched_wakeup_new: OK
[   72.461761] Testing event sched_switch: OK
[   72.477673] Testing event sched_migrate_task: OK
[   72.497678] Testing event sched_process_free: OK
[   72.517674] Testing event sched_process_exit: OK
[   72.534687] Testing event sched_wait_task: OK
[   72.554063] Testing event sched_process_wait: OK
[   72.573738] Testing event sched_process_fork: OK
[   72.593711] Testing event sched_process_exec: OK
[   72.613791] Testing event sched_stat_wait: OK
[   72.633766] Testing event sched_stat_sleep: OK
[   72.653984] Testing event sched_stat_iowait: OK
[   72.674096] Testing event sched_stat_blocked: OK
[   72.694054] Testing event sched_stat_runtime: OK
[   72.713988] Testing event sched_pi_setprio: OK
[   72.733743] Testing event rcu_utilization: OK
[   72.754036] Testing event rcu_grace_period: OK
[   72.774028] Testing event rcu_grace_period_init: OK
[   72.793744] Testing event rcu_preempt_task: OK
[   72.814021] Testing event rcu_unlock_preempted_task: OK
[   72.833703] Testing event rcu_quiescent_state_report: OK
[   72.853985] Testing event rcu_fqs: OK
[   72.873829] Testing event rcu_dyntick: OK
[   72.894019] Testing event rcu_prep_idle: OK
[   72.913983] Testing event rcu_callback: OK
[   72.934080] Testing event rcu_kfree_callback: OK
[   72.953988] Testing event rcu_batch_start: OK
[   72.974083] Testing event rcu_invoke_callback: OK
[   72.993953] Testing event rcu_invoke_kfree_callback: OK
[   73.014060] Testing event rcu_batch_end: OK
[   73.033753] Testing event rcu_torture_read: OK
[   73.053961] Testing event workqueue_queue_work: OK
[   73.074045] Testing event workqueue_activate_work: OK
[   73.093970] Testing event workqueue_execute_start: OK
[   73.114049] Testing event workqueue_execute_end: OK
[   73.134003] Testing event signal_generate: OK
[   73.153782] Testing event signal_deliver: OK
[   73.174010] Testing event timer_init: OK
[   73.194014] Testing event timer_start: OK
[   73.214053] Testing event timer_expire_entry: OK
[   73.234056] Testing event timer_expire_exit: OK
[   73.263849] Testing event timer_cancel: OK
[   73.281789] Testing event hrtimer_init: OK
[   73.301777] Testing event hrtimer_start: OK
[   73.321783] Testing event hrtimer_expire_entry: OK
[   73.342007] Testing event hrtimer_expire_exit: OK
[   73.361688] Testing event hrtimer_cancel: OK
[   73.381768] Testing event itimer_state: OK
[   73.401693] Testing event itimer_expire: OK
[   73.417762] Testing event irq_handler_entry: OK
[   73.437682] Testing event irq_handler_exit: OK
[   73.457766] Testing event softirq_entry: OK
[   73.477760] Testing event softirq_exit: OK
[   73.497767] Testing event softirq_raise: OK
[   73.517714] Testing event console: OK
[   73.538003] Testing event task_newtask: OK
[   73.557703] Testing event task_rename: OK
[   73.573731] Testing event mce_record: OK
[   73.589715] Testing event sys_enter: OK
[   73.605824] Testing event sys_exit: OK
[   73.625774] Testing event emulate_vsyscall: OK
[   73.645977] Testing event xen_mc_batch: OK
[   73.665781] Testing event xen_mc_issue: OK
[   73.685815] Testing event xen_mc_entry: OK
[   73.705646] Testing event xen_mc_entry_alloc: OK
[   73.726039] Testing event xen_mc_callback: OK
[   73.745845] Testing event xen_mc_flush_reason: OK
[   73.765727] Testing event xen_mc_flush: OK
[   73.785754] Testing event xen_mc_extend_args: OK
[   73.805759] Testing event xen_mmu_set_pte: OK
[   73.825674] Testing event xen_mmu_set_pte_atomic: OK
[   73.846093] Testing event xen_mmu_set_domain_pte: OK
[   73.865818] Testing event xen_mmu_set_pte_at: OK
[   73.885725] Testing event xen_mmu_pte_clear: [   73.904242] vhci_hcd: changed 0
OK
[   73.906895] Testing event xen_mmu_set_pmd: OK
[   73.925703] Testing event xen_mmu_pmd_clear: OK
[   73.945688] Testing event xen_mmu_set_pud: OK
[   73.961712] Testing event xen_mmu_set_pgd: OK
[   73.981777] Testing event xen_mmu_pud_clear: OK
[   74.001777] Testing event xen_mmu_pgd_clear: OK
[   74.021776] Testing event xen_mmu_ptep_modify_prot_start: OK
[   74.041677] Testing event xen_mmu_ptep_modify_prot_commit: OK
[   74.061770] Testing event xen_mmu_alloc_ptpage: OK
[   74.081771] Testing event xen_mmu_release_ptpage: OK
[   74.102053] Testing event xen_mmu_pgd_pin: OK
[   74.121754] Testing event xen_mmu_pgd_unpin: OK
[   74.141721] Testing event xen_mmu_flush_tlb: OK
[   74.161789] Testing event xen_mmu_flush_tlb_single: OK
[   74.181779] Testing event xen_mmu_flush_tlb_others: OK
[   74.201628] Testing event xen_mmu_write_cr3: OK
[   74.221880] Testing event xen_cpu_write_ldt_entry: OK
[   74.241833] Testing event xen_cpu_write_idt_entry: OK
[   74.261922] Testing event xen_cpu_load_idt: OK
[   74.281776] Testing event xen_cpu_write_gdt_entry: OK
[   74.301887] Testing event xen_cpu_set_ldt: OK
[   74.322130] Testing event kvm_mmu_pagetable_walk: OK
[   74.341863] Testing event kvm_mmu_paging_element: OK
[   74.362177] Testing event kvm_mmu_set_accessed_bit: OK
[   74.382081] Testing event kvm_mmu_set_dirty_bit: OK
[   74.401932] Testing event kvm_mmu_walker_error: OK
[   74.422112] Testing event kvm_mmu_get_page: OK
[   74.442227] Testing event kvm_mmu_sync_page: OK
[   74.462224] Testing event kvm_mmu_unsync_page: OK
[   74.481993] Testing event kvm_mmu_prepare_zap_page: OK
[   74.501875] Testing event kvm_mmu_delay_free_pages: OK
[   74.521896] Testing event mark_mmio_spte: OK
[   74.542324] Testing event handle_mmio_page_fault: OK
[   74.561859] Testing event kvm_entry: OK
[   74.581770] Testing event kvm_hypercall: OK
[   74.601901] Testing event kvm_hv_hypercall: OK
[   74.621895] Testing event kvm_pio: OK
[   74.642355] Testing event kvm_cpuid: OK
[   74.661941] Testing event kvm_apic: OK
[   74.682195] Testing event kvm_exit: OK
[   74.701952] Testing event kvm_inj_virq: OK
[   74.722211] Testing event kvm_inj_exception: OK
[   74.741940] Testing event kvm_page_fault: OK
[   74.761940] Testing event kvm_msr: OK
[   74.782184] Testing event kvm_cr: OK
[   74.801939] Testing event kvm_pic_set_irq: OK
[   74.822191] Testing event kvm_apic_ipi: OK
[   74.842148] Testing event kvm_apic_accept_irq: OK
[   74.861936] Testing event kvm_nested_vmrun: OK
[   74.882109] Testing event kvm_nested_intercepts: OK
[   74.902139] Testing event kvm_nested_vmexit: OK
[   74.922164] Testing event kvm_nested_vmexit_inject: OK
[   74.941929] Testing event kvm_nested_intr_vmexit: OK
[   74.962102] Testing event kvm_invlpga: OK
[   74.982240] Testing event kvm_skinit: OK
[   75.002276] Testing event kvm_emulate_insn: OK
[   75.022198] Testing event vcpu_match_mmio: OK
[   75.041921] Testing event kvm_userspace_exit: OK
[   75.062074] Testing event kvm_set_irq: OK
[   75.081933] Testing event kvm_ioapic_set_irq: OK
[   75.101770] Testing event kvm_msi_set_irq: OK
[   75.121807] Testing event kvm_ack_irq: OK
[   75.141798] Testing event kvm_mmio: OK
[   75.161772] Testing event kvm_fpu: OK
[   75.181818] Testing event kvm_age_page: OK
[   75.201880] Testing event kvm_try_async_get_page: OK
[   75.221875] Testing event kvm_async_pf_doublefault: OK
[   75.241859] Testing event kvm_async_pf_not_present: OK
[   75.261888] Testing event kvm_async_pf_ready: OK
[   75.281773] Testing event kvm_async_pf_completed: OK
[   75.301813] Running tests on trace event systems:
[   75.303155] Testing event system 9p: OK
[   75.322471] Testing event system mac80211: OK
[   75.389439] Testing event system sunrpc: OK
[   75.411790] Testing event system skb: OK
[   75.430392] Testing event system net: OK
[   75.450664] Testing event system napi: OK
[   75.469953] Testing event system sock: OK
[   75.490109] Testing event system udp: OK
[   75.509854] Testing event system hda: OK
[   75.531231] Testing event system scsi: OK
[   75.550955] Testing event system regmap: OK
[   75.576547] Testing event system i915: OK
[   75.608189] Testing event system radeon: OK
[   75.626975] Testing event system drm: OK
[   75.646420] Testing event system regulator: OK
[   75.667955] Testing event system gpio: OK
[   75.686129] Testing event system block: OK
[   75.714245] Testing event system gfs2: OK
[   75.741084] Testing event system btrfs: OK
[   75.778238] Testing event system ocfs2: [   75.920204] vhci_hcd: changed 0
OK
[   76.006372] Testing event system xfs: OK
[   76.218857] Testing event system jbd2: OK
[   76.245071] Testing event system jbd: OK
[   76.268561] Testing event system ext4: OK
[   76.332167] Testing event system ext3: OK
[   76.372555] Testing event system writeback: OK
[   76.404491] Testing event system compaction: OK
[   76.422400] Testing event system kmem: OK
[   76.445042] Testing event system vmscan: OK
[   76.469920] Testing event system oom: OK
[   76.489963] Testing event system rpm: OK
[   76.510664] Testing event system power: OK
[   76.538403] Testing event system test: OK
[   76.557961] Testing event system module: OK
[   76.578788] Testing event system lock: OK
[   76.598674] Testing event system sched: OK
[   76.626724] Testing event system rcu: OK
[   76.653821] Testing event system workqueue: OK
[   76.674916] Testing event system signal: OK
[   76.694027] Testing event system timer: OK
[   76.716976] Testing event system irq: OK
[   76.738937] Testing event system printk: OK
[   76.758122] Testing event system task: OK
[   76.778427] Testing event system mce: OK
[   76.797825] Testing event system raw_syscalls: OK
[   76.818246] Testing event system vsyscall: OK
[   76.837843] Testing event system syscalls: OK
[   76.860562] Testing event system xen: OK
[   76.901926] Testing event system kvmmmu: OK
[   76.937479] Testing event system kvm: OK
[   76.976889] Running tests on all trace events:
[   76.978126] Testing all events: [   77.936348] vhci_hcd: changed 0
OK
[   78.248549] Testing ftrace filter: OK
[   78.251219] Testing kprobe tracing: OK
[   78.257201] kAFS: Red Hat AFS client v0.1 registering.
[   78.258502] FS-Cache: Netfs 'afs' registered for caching
[   78.261951] console [netcon0] enabled
[   78.262888] netconsole: network logging started
[   78.264188] rtc_cmos 00:01: setting system clock to 2012-07-06 05:18:42 UTC (1341551922)
[   78.266128] saa7134 ALSA driver for DMA sound loaded
[   78.267269] saa7134 ALSA: no saa7134 cards found
[   78.268617] BIOS EDD facility v0.16 2004-Jun-25, 0 devices found
[   78.269952] EDD information not available.
[   78.272895] IPv6: ADDRCONF(NETDEV_UP): bond0: link is not ready
[   78.274278] 8021q: adding VLAN 0 to HW filter on device bond0
[   78.277726] IP-Config: Failed to open ipddp0
[   78.287284] IPv6: ADDRCONF(NETDEV_UP): eth0: link is not ready
[   78.289382] e1000: eth0 NIC Link is Up 1000 Mbps Full Duplex, Flow Control: RX
[   78.292330] 8021q: adding VLAN 0 to HW filter on device eth0
[   78.293700] IP-Config: Failed to open plip0
[   78.305405] ieee80211 phy0: mac80211_hwsim_start
[   78.306545] ieee80211 phy0: mac80211_hwsim_add_interface (type=2 mac_addr=02:00:00:00:00:00)
[   78.308619] ieee80211 phy0: mac80211_hwsim_bss_info_changed(changed=0xe)
[   78.310069] ieee80211 phy0:   ERP_CTS_PROT: 0
[   78.311102] ieee80211 phy0:   ERP_PREAMBLE: 0
[   78.312205] ieee80211 phy0:   ERP_SLOT: 0
[   78.313210] ieee80211 phy0: mac80211_hwsim_conf_tx (queue=0 txop=0 cw_min=31 cw_max=1023 aifs=2)
[   78.315190] ieee80211 phy0: mac80211_hwsim_conf_tx (queue=1 txop=0 cw_min=31 cw_max=1023 aifs=2)
[   78.317304] ieee80211 phy0: mac80211_hwsim_conf_tx (queue=2 txop=0 cw_min=31 cw_max=1023 aifs=2)
[   78.319304] ieee80211 phy0: mac80211_hwsim_conf_tx (queue=3 txop=0 cw_min=31 cw_max=1023 aifs=2)
[   78.321389] ieee80211 phy0: mac80211_hwsim_bss_info_changed(changed=0x2000)
[   78.322973] ieee80211 phy0: mac80211_hwsim_bss_info_changed(changed=0x4000)
[   78.324597] ieee80211 phy0: mac80211_hwsim_config (freq=2412/noht idle=1 ps=0 smps=static)
[   78.326714] ieee80211 phy0: mac80211_hwsim_configure_filter
[   78.327936] IPv6: ADDRCONF(NETDEV_UP): wlan0: link is not ready
[   78.328083] ieee80211 phy1: mac80211_hwsim_start
[   78.328089] ieee80211 phy1: mac80211_hwsim_add_interface (type=2 mac_addr=02:00:00:00:01:00)
[   78.328091] ieee80211 phy1: mac80211_hwsim_bss_info_changed(changed=0xe)
[   78.328093] ieee80211 phy1:   ERP_CTS_PROT: 0
[   78.328095] ieee80211 phy1:   ERP_PREAMBLE: 0
[   78.328097] ieee80211 phy1:   ERP_SLOT: 0
[   78.328102] ieee80211 phy1: mac80211_hwsim_conf_tx (queue=0 txop=0 cw_min=31 cw_max=1023 aifs=2)
[   78.328105] ieee80211 phy1: mac80211_hwsim_conf_tx (queue=1 txop=0 cw_min=31 cw_max=1023 aifs=2)
[   78.328108] ieee80211 phy1: mac80211_hwsim_conf_tx (queue=2 txop=0 cw_min=31 cw_max=1023 aifs=2)
[   78.328111] ieee80211 phy1: mac80211_hwsim_conf_tx (queue=3 txop=0 cw_min=31 cw_max=1023 aifs=2)
[   78.328124] ieee80211 phy1: mac80211_hwsim_bss_info_changed(changed=0x2000)
[   78.328130] ieee80211 phy1: mac80211_hwsim_bss_info_changed(changed=0x4000)
[   78.328134] ieee80211 phy1: mac80211_hwsim_config (freq=2412/noht idle=1 ps=0 smps=static)
[   78.329543] IPv6: ADDRCONF(NETDEV_UP): wlan1: link is not ready
[   78.329798] IP-Config: Failed to open irlan0
[   78.329863] IPv6: ADDRCONF(NETDEV_CHANGE): eth0: link becomes ready
[   78.344119] Sending DHCP requests .
[   78.329784] DHCP/BOOTP: Ignoring device hardwpan0, MTU 127 too small
[   78.356456] ieee80211 phy1: mac80211_hwsim_configure_filter
[   78.356521] ieee80211 phy0: mac80211_hwsim_configure_filter
[   79.844629] , OK
[   79.848756] IP-Config: Got DHCP answer from 10.0.2.2, my address is 10.0.2.15
[   79.853531] ieee80211 phy0: mac80211_hwsim_configure_filter
[   79.855481] ieee80211 phy0: mac80211_hwsim_configure_filter
[   79.857407] ieee80211 phy0: mac80211_hwsim_remove_interface (type=2 mac_addr=02:00:00:00:00:00)
[   79.859349] ieee80211 phy0: mac80211_hwsim_stop
[   79.860958] ieee80211 phy1: mac80211_hwsim_configure_filter
[   79.862205] ieee80211 phy1: mac80211_hwsim_configure_filter
[   79.868105] ieee80211 phy1: mac80211_hwsim_remove_interface (type=2 mac_addr=02:00:00:00:01:00)
[   79.870030] ieee80211 phy1: mac80211_hwsim_stop
[   79.872269] IP-Config: Complete:
[   79.873107]      device=eth0, addr=10.0.2.15, mask=255.255.255.0, gw=10.0.2.2
[   79.874546]      host=kvm, domain=, nis-domain=(none)
[   79.875673]      bootserver=10.0.2.2, rootserver=10.239.97.14, rootpath=
[   79.877252] ALSA device list:
[   79.878007]   #0: Dummy 1
[   79.878703]   #1: Loopback 1
[   79.879422]   #2: Virtual MIDI Card 1
[   79.881298] md: Waiting for all devices to be available before autodetect
[   79.882718] md: If you don't use raid, use raid=noautodetect
[   79.885265] md: Autodetecting RAID arrays.
[   79.886250] md: Scanned 0 and added 0 devices.
[   79.887242] md: autorun ...
[   79.887965] md: ... autorun DONE.
[   79.912481] VFS: Mounted root (nfs filesystem) on device 0:14.
[   79.913794] debug: unmapping init [mem 0xffffffff8441b000-0xffffffff847ecfff]
[   79.915517] Write protecting the kernel read-only data: 49152k
[   79.917764] debug: unmapping init [mem 0xffff880002e5d000-0xffff880002ffffff]
[   79.919341] debug: unmapping init [mem 0xffff880003e5f000-0xffff880003ffffff]
[   79.952755] vhci_hcd: changed 0
[   80.604956] modprobe (2778) used greatest stack depth: 3144 bytes left
[   81.968085] vhci_hcd: changed 0
[   82.895804] blkid (2961) used greatest stack depth: 2816 bytes left
[   83.984095] vhci_hcd: changed 0
[   86.000109] vhci_hcd: changed 0
[   86.189249] BUG: unable to handle kernel paging request at 00000000d0d4176d
[   86.191251] IP: [<ffffffff82aecf72>] ip6_dst_lookup_tail+0xd5/0x1d8
[   86.192677] PGD 0 
[   86.192677] Oops: 0000 [#1] SMP DEBUG_PAGEALLOC
[   86.192677] CPU 0 
[   86.192677] Modules linked in:
[   86.192677] 
[   86.192677] 
[   86.192677] Pid: 3083, comm: sshd Not tainted 3.5.0-rc5+ #3 Bochs Bochs
[   86.192677] RIP: 0010:[<ffffffff82aecf72>]  [<ffffffff82aecf72>] ip6_dst_lookup_tail+0xd5/0x1d8
[   86.192677] RSP: 0018:ffff88000e6c3d08  EFLAGS: 00010206
[   86.192677] RAX: 00000000d0d41600 RBX: ffff88000e6c3db0 RCX: 0000000000000015
[   86.192677] RDX: 0000000000000001 RSI: 0000000000000000 RDI: 0000000000000246
[   86.192677] RBP: ffff88000e6c3d98 R08: ffff88001f3d5580 R09: ffffffff85124e70
[   86.192677] R10: ffffffff840401a0 R11: ffff880012151e70 R12: ffff88000e6c3e10
[   86.192677] R13: 0000000000000000 R14: ffffffff855c5e00 R15: ffff88000c87e938
[   86.192677] FS:  00007f52440817c0(0000) GS:ffff88001f200000(0000) knlGS:0000000000000000
[   86.192677] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
[   86.192677] CR2: 00000000d0d4176d CR3: 00000000122c0000 CR4: 00000000000006f0
[   86.192677] DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
[   86.192677] DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
[   86.192677] Process sshd (pid: 3083, threadinfo ffff88000e6c2000, task ffff88000dea5900)
[   86.192677] Stack:
[   86.192677]  ffff88000e6c3d18 ffff88000e6c3e34 ffff88000e6c3d28 ffffffff8111ee10
[   86.192677]  ffff88000e6c3d48 ffffffff8111f528 ffffffff810c0f1e ffffffff810da5f8
[   86.192677]  ffff88000e6c3d68 00000000810da56c 0000000000000092 00000000992b7e67
[   86.192677] Call Trace:
[   86.192677]  [<ffffffff8111ee10>] ? irq_trace+0x14/0x21
[   86.192677]  [<ffffffff8111f528>] ? time_hardirqs_off+0x26/0x2a
[   86.192677]  [<ffffffff810c0f1e>] ? local_clock+0x3b/0x52
[   86.192677]  [<ffffffff810da5f8>] ? trace_hardirqs_off+0xd/0xf
[   86.192677]  [<ffffffff81097236>] ? _local_bh_enable_ip+0xbb/0xd8
[   86.192677]  [<ffffffff82aed0a9>] ip6_dst_lookup_flow+0x34/0x7e
[   86.192677]  [<ffffffff82b11a01>] ip6_datagram_connect+0x34b/0x4a4
[   86.192677]  [<ffffffff81097261>] ? local_bh_enable_ip+0xe/0x10
[   86.192677]  [<ffffffff82ab3770>] inet_dgram_connect+0x3f/0x6e
[   86.192677]  [<ffffffff829d1a53>] sys_connect+0x9b/0xd9
[   86.192677]  [<ffffffff810de26a>] ? trace_hardirqs_on_caller+0x123/0x17f
[   86.192677]  [<ffffffff816b050e>] ? trace_hardirqs_on_thunk+0x3a/0x3f
[   86.192677]  [<ffffffff82e535a9>] system_call_fastpath+0x16/0x1b
[   86.192677] Code: 8a 48 6e c0 e9 05 0f b6 c9 eb 02 31 c9 4c 8b 85 78 ff ff ff 49 8d 54 24 14 4c 89 f7 e8 fa db 00 00 85 c0 0f 85 bb 00 00 00 eb a4 <f6> 80 6d 01 00 00 de 0f 85 a5 00 00 00 e8 53 fc ff ff 48 8b 03 
[   86.192677] RIP  [<ffffffff82aecf72>] ip6_dst_lookup_tail+0xd5/0x1d8
[   86.192677]  RSP <ffff88000e6c3d08>
[   86.192677] CR2: 00000000d0d4176d
[   86.263779] ---[ end trace e1f3b1cea75a2d24 ]---
[   86.265012] BUG: sleeping function called from invalid context at /c/kernel-tests/net/kernel/rwsem.c:20
[   86.267222] in_atomic(): 1, irqs_disabled(): 0, pid: 3083, name: sshd
[   86.268824] INFO: lockdep is turned off.
[   86.269828] Pid: 3083, comm: sshd Tainted: G      D      3.5.0-rc5+ #3
[   86.271301] Call Trace:
[   86.272135]  [<ffffffff810bb354>] __might_sleep+0x10b/0x110
[   86.273474]  [<ffffffff82e4a758>] down_read+0x26/0x85
[   86.274674]  [<ffffffff810a2248>] exit_signals+0x26/0x12b
[   86.275991]  [<ffffffff81094f43>] do_exit+0x119/0x811
[   86.277309]  [<ffffffff81092f3d>] ? kmsg_dump+0xef/0x10a
[   86.278579]  [<ffffffff81092e73>] ? kmsg_dump+0x25/0x10a
[   86.279836]  [<ffffffff82e4d995>] oops_end+0xb0/0xb8
[   86.281125]  [<ffffffff82dfc17f>] no_context+0x250/0x27b
[   86.282379]  [<ffffffff82dfc372>] __bad_area_nosemaphore+0x1c8/0x1e8
[   86.283841]  [<ffffffff82e4fd9c>] ? do_page_fault+0x115/0x3d6
[   86.285285]  [<ffffffff82dfc3a5>] bad_area_nosemaphore+0x13/0x15
[   86.286688]  [<ffffffff82e4fe3a>] do_page_fault+0x1b3/0x3d6
[   86.288035]  [<ffffffff810dcfd1>] ? __lock_acquire+0x38c/0xd17
[   86.289422]  [<ffffffff8111ee10>] ? irq_trace+0x14/0x21
[   86.290659]  [<ffffffff8111f528>] ? time_hardirqs_off+0x26/0x2a
[   86.292105]  [<ffffffff82e4d126>] ? error_sti+0x5/0x6
[   86.293341]  [<ffffffff810da58c>] ? trace_hardirqs_off_caller+0x3f/0x9e
[   86.294842]  [<ffffffff816b054d>] ? trace_hardirqs_off_thunk+0x3a/0x3c
[   86.307717]  [<ffffffff82e4ced5>] page_fault+0x25/0x30
[   86.309065]  [<ffffffff82aecf72>] ? ip6_dst_lookup_tail+0xd5/0x1d8
[   86.310492]  [<ffffffff82aecf2a>] ? ip6_dst_lookup_tail+0x8d/0x1d8
[   86.311920]  [<ffffffff8111ee10>] ? irq_trace+0x14/0x21
[   86.313254]  [<ffffffff8111f528>] ? time_hardirqs_off+0x26/0x2a
[   86.314625]  [<ffffffff810c0f1e>] ? local_clock+0x3b/0x52
[   86.315960]  [<ffffffff810da5f8>] ? trace_hardirqs_off+0xd/0xf
[   86.317391]  [<ffffffff81097236>] ? _local_bh_enable_ip+0xbb/0xd8
[   86.318905]  [<ffffffff82aed0a9>] ip6_dst_lookup_flow+0x34/0x7e
[   86.320380]  [<ffffffff82b11a01>] ip6_datagram_connect+0x34b/0x4a4
[   86.321822]  [<ffffffff81097261>] ? local_bh_enable_ip+0xe/0x10
[   86.323203]  [<ffffffff82ab3770>] inet_dgram_connect+0x3f/0x6e
[   86.324666]  [<ffffffff829d1a53>] sys_connect+0x9b/0xd9
[   86.325952]  [<ffffffff810de26a>] ? trace_hardirqs_on_caller+0x123/0x17f
[   86.327447]  [<ffffffff816b050e>] ? trace_hardirqs_on_thunk+0x3a/0x3f
[   86.329053]  [<ffffffff82e535a9>] system_call_fastpath+0x16/0x1b
[   86.330428] BUG: scheduling while atomic: sshd/3083/0x10000002
[   86.331782] INFO: lockdep is turned off.
[   86.332940] Modules linked in:
[   86.333894] Pid: 3083, comm: sshd Tainted: G      D      3.5.0-rc5+ #3
[   86.335345] Call Trace:
[   86.336198]  [<ffffffff82dfcf15>] __schedule_bug+0x66/0x75
[   86.337504]  [<ffffffff82e4ab39>] __schedule+0x95/0x5ff
[   86.338754]  [<ffffffff810bd131>] __cond_resched+0x27/0x32
[   86.340103]  [<ffffffff82e4b0ff>] _cond_resched+0x19/0x22
[   86.341394]  [<ffffffff82e4a75d>] down_read+0x2b/0x85
[   86.342614]  [<ffffffff810a2248>] exit_signals+0x26/0x12b
[   86.343909]  [<ffffffff81094f43>] do_exit+0x119/0x811
[   86.345207]  [<ffffffff81092f3d>] ? kmsg_dump+0xef/0x10a
[   86.346487]  [<ffffffff81092e73>] ? kmsg_dump+0x25/0x10a
[   86.347743]  [<ffffffff82e4d995>] oops_end+0xb0/0xb8
[   86.349043]  [<ffffffff82dfc17f>] no_context+0x250/0x27b
[   86.350309]  [<ffffffff82dfc372>] __bad_area_nosemaphore+0x1c8/0x1e8
[   86.351759]  [<ffffffff82e4fd9c>] ? do_page_fault+0x115/0x3d6
[   86.353199]  [<ffffffff82dfc3a5>] bad_area_nosemaphore+0x13/0x15
[   86.354575]  [<ffffffff82e4fe3a>] do_page_fault+0x1b3/0x3d6
[   86.355914]  [<ffffffff810dcfd1>] ? __lock_acquire+0x38c/0xd17
[   86.357333]  [<ffffffff8111ee10>] ? irq_trace+0x14/0x21
[   86.358591]  [<ffffffff8111f528>] ? time_hardirqs_off+0x26/0x2a
[   86.359975]  [<ffffffff82e4d126>] ? error_sti+0x5/0x6
[   86.361272]  [<ffffffff810da58c>] ? trace_hardirqs_off_caller+0x3f/0x9e
[   86.362791]  [<ffffffff816b054d>] ? trace_hardirqs_off_thunk+0x3a/0x3c
[   86.364386]  [<ffffffff82e4ced5>] page_fault+0x25/0x30
[   86.365649]  [<ffffffff82aecf72>] ? ip6_dst_lookup_tail+0xd5/0x1d8
[   86.367067]  [<ffffffff82aecf2a>] ? ip6_dst_lookup_tail+0x8d/0x1d8
[   86.368605]  [<ffffffff8111ee10>] ? irq_trace+0x14/0x21
[   86.369857]  [<ffffffff8111f528>] ? time_hardirqs_off+0x26/0x2a
[   86.371220]  [<ffffffff810c0f1e>] ? local_clock+0x3b/0x52
[   86.372621]  [<ffffffff810da5f8>] ? trace_hardirqs_off+0xd/0xf
[   86.373993]  [<ffffffff81097236>] ? _local_bh_enable_ip+0xbb/0xd8
[   86.375373]  [<ffffffff82aed0a9>] ip6_dst_lookup_flow+0x34/0x7e
[   86.376905]  [<ffffffff82b11a01>] ip6_datagram_connect+0x34b/0x4a4
[   86.378325]  [<ffffffff81097261>] ? local_bh_enable_ip+0xe/0x10
[   86.379761]  [<ffffffff82ab3770>] inet_dgram_connect+0x3f/0x6e
[   86.381223]  [<ffffffff829d1a53>] sys_connect+0x9b/0xd9
[   86.382468]  [<ffffffff810de26a>] ? trace_hardirqs_on_caller+0x123/0x17f
[   86.383984]  [<ffffffff816b050e>] ? trace_hardirqs_on_thunk+0x3a/0x3f
[   86.385538]  [<ffffffff82e535a9>] system_call_fastpath+0x16/0x1b
[   86.386993] note: sshd[3083] exited with preempt_count 1
[   88.016068] vhci_hcd: changed 0
[   90.032056] vhci_hcd: changed 0
[   92.048696] vhci_hcd: changed 0

--UlVJffcvxoiEqYs2--
