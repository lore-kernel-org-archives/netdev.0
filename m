From: wfg@linux.intel.com
Subject: [net-next:master] general protection fault in __nla_put()
Date: Thu, 5 Jul 2012 21:48:57 +0800
Message-ID: <20120705134857.GA14643@localhost>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="M9NhX3UHpAaciwkO"
Content-Transfer-Encoding: 8bit
Cc: netdev <netdev@vger.kernel.org>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:47462 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756225Ab2GENwu (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 5 Jul 2012 09:52:50 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--M9NhX3UHpAaciwkO
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

Hi David,

This is a very reproducible bug, introduced by the following commit

tree:   git://git.kernel.org/pub/scm/linux/kernel/git/davem/net-next.git master
head:   36bdbcae2fa2a6dfa99344d4190fcea0aa7b7c25
commit: 97cac0821af4474ec4ba3a9e7a36b98ed9b6db88 [96/99] ipv6: Store route neighbour in rt6_info struct.

[   80.878774] IPv6: ADDRCONF(NETDEV_UP): bond0: link is not ready
[   80.880350] 8021q: adding VLAN 0 to HW filter on device bond0
[   80.882116] general protection fault: 0000 [#1] SMP DEBUG_PAGEALLOC
[   80.883606] CPU 0 
[   80.884216] Modules linked in:
[   80.884296] 
[   80.884296] Pid: 1, comm: swapper/0 Not tainted 3.5.0-rc4+ #16 Bochs Bochs
[   80.884296] RIP: 0010:[<ffffffff816ce77e>]  [<ffffffff816ce77e>] __nla_put+0x1f/0x26
[   80.884296] RSP: 0018:ffff88001d819910  EFLAGS: 00010282
[   80.884296] RAX: ffff880012167c2c RBX: 5a5a5a5a5a5a5d3a RCX: 0000000000000010
[   80.884296] RDX: ffff880012167c3c RSI: 5a5a5a5a5a5a5d3a RDI: ffff880012167c2c
[   80.884296] RBP: ffff88001d819920 R08: ffff880012167c28 R09: ffff880012167bf0
[   80.884296] R10: ffffffff840401a0 R11: ffffffff840401a0 R12: 0000000000000010
[   80.884296] R13: ffff8800120c3f00 R14: 0000000000000000 R15: 0000000000000000
[   80.884296] FS:  0000000000000000(0000) GS:ffff88001f200000(0000) knlGS:0000000000000000
[   80.884296] CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
[   80.884296] CR2: 0000000000000000 CR3: 0000000004014000 CR4: 00000000000006f0
[   80.884296] DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
[   80.884296] DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
[   80.884296] Process swapper/0 (pid: 1, threadinfo ffff88001d818000, task ffff88001d814040)
[   80.884296] Stack:
[   80.884296]  ffff8800120c3f00 ffff880012168e70 ffff88001d819960 ffffffff816ce7bf
[   80.884296]  ffff88001d819950 5a5a5a5a5a5a5d3a ffffffff00000010 ffff880000000005
[   80.884296]  ffff88001d819960 ffff880012167bf0 ffff88001d819a00 ffffffff82afa9b0
[   80.884296] Call Trace:
[   80.884296]  [<ffffffff816ce7bf>] nla_put+0x3a/0x4a
[   80.884296]  [<ffffffff82afa9b0>] rt6_fill_node.constprop.35+0x325/0x486
[   80.884296]  [<ffffffff8117598d>] ? __kmalloc_node_track_caller+0x35/0x3e
[   80.884296]  [<ffffffff829d69cb>] ? __alloc_skb+0xaf/0x15a
[   80.884296]  [<ffffffff82afaf82>] inet6_rt_notify+0xb2/0x130
[   80.884296]  [<ffffffff82afc56f>] fib6_add+0x359/0x55a
[   80.884296]  [<ffffffff810dbeb0>] ? lock_acquired+0x1e4/0x219
[   80.884296]  [<ffffffff82af7ae5>] __ip6_ins_rt+0x3c/0x57
[   80.884296]  [<ffffffff82af9c10>] ip6_route_add+0x49e/0x58d
[   80.884296]  [<ffffffff82af0bcc>] addrconf_add_mroute+0x82/0x98
[   80.884296]  [<ffffffff82af24a8>] addrconf_add_dev+0x61/0x83
[   80.884296]  [<ffffffff82af429a>] addrconf_dev_config+0x78/0xd4
[   80.884296]  [<ffffffff82af5fb1>] addrconf_notify+0x164/0x283
[   80.884296]  [<ffffffff82e4fcc2>] notifier_call_chain+0x65/0x95
[   80.884296]  [<ffffffff810b54ab>] __raw_notifier_call_chain+0xe/0x10
[   80.884296]  [<ffffffff810b54c1>] raw_notifier_call_chain+0x14/0x16
[   80.884296]  [<ffffffff829df1c8>] call_netdevice_notifiers+0x4a/0x4f
[   80.884296]  [<ffffffff829e4934>] __dev_notify_flags+0x37/0x5b
[   80.884296]  [<ffffffff829e49a0>] dev_change_flags+0x48/0x54
[   80.884296]  [<ffffffff8467e322>] ip_auto_config.part.10+0x14a/0xd52
[   80.884296]  [<ffffffff82e4c452>] ? _raw_spin_unlock+0x28/0x3b
[   80.884296]  [<ffffffff811da21f>] ? proc_register+0x192/0x1a6
[   80.884296]  [<ffffffff8467c8c6>] ? tcp_v4_init+0x30/0x30
[   80.884296]  [<ffffffff8467ef2a>] ? ip_auto_config.part.10+0xd52/0xd52
[   80.884296]  [<ffffffff8467ef5d>] ip_auto_config+0x33/0x35
[   80.884296]  [<ffffffff81002099>] do_one_initcall+0x7f/0x13a
[   80.884296]  [<ffffffff845f1d0a>] kernel_init+0x141/0x1c5
[   80.884296]  [<ffffffff845f1590>] ? do_early_param+0x8c/0x8c
[   80.884296]  [<ffffffff82e545f4>] kernel_thread_helper+0x4/0x10
[   80.884296]  [<ffffffff82e4c830>] ? retint_restore_args+0x13/0x13
[   80.884296]  [<ffffffff845f1bc9>] ? start_kernel+0x3e7/0x3e7
[   80.884296]  [<ffffffff82e545f0>] ? gs_change+0x13/0x13
[   80.884296] Code: 4c 89 c0 41 5b 5b 41 5c 41 5d 5d c3 55 48 89 e5 41 54 41 89 d4 53 48 89 cb e8 a2 ff ff ff 48 83 c0 04 49 63 cc 48 89 de 48 89 c7 <f3> a4 5b 41 5c 5d c3 55 48 89 e5 53 48 89 fb 48 83 ec 28 89 55 
[   80.884296] RIP  [<ffffffff816ce77e>] __nla_put+0x1f/0x26
[   80.884296]  RSP <ffff88001d819910>
[   80.964726] ---[ end trace 7265c51d764fcc58 ]---
[   80.965811] Kernel panic - not syncing: Fatal exception in interrupt

commit 97cac0821af4474ec4ba3a9e7a36b98ed9b6db88
Author: David S. Miller <davem@davemloft.net>
Date:   Mon Jul 2 22:43:47 2012 -0700

    ipv6: Store route neighbour in rt6_info struct.
    
    This makes for a simplified conversion away from dst_get_neighbour*().
    
    All code outside of ipv6 will use neigh lookups via dst_neigh_lookup*().
    
    Signed-off-by: David S. Miller <davem@davemloft.net>

diff --git a/include/net/ip6_fib.h b/include/net/ip6_fib.h
index a192f78..0fedbd8 100644
--- a/include/net/ip6_fib.h
+++ b/include/net/ip6_fib.h
@@ -86,6 +86,8 @@ struct fib6_table;
 struct rt6_info {
 	struct dst_entry		dst;
 
+	struct neighbour		*n;
+
 	/*
 	 * Tail elements of dst_entry (__refcnt etc.)
 	 * and these elements (rarely used in hot path) are in
diff --git a/net/ipv6/ip6_output.c b/net/ipv6/ip6_output.c
index c94e4aa..6d9c0ab 100644
--- a/net/ipv6/ip6_output.c
+++ b/net/ipv6/ip6_output.c
@@ -88,6 +88,7 @@ static int ip6_finish_output2(struct sk_buff *skb)
 	struct dst_entry *dst = skb_dst(skb);
 	struct net_device *dev = dst->dev;
 	struct neighbour *neigh;
+	struct rt6_info *rt;
 
 	skb->protocol = htons(ETH_P_IPV6);
 	skb->dev = dev;
@@ -123,7 +124,8 @@ static int ip6_finish_output2(struct sk_buff *skb)
 	}
 
 	rcu_read_lock();
-	neigh = dst_get_neighbour_noref(dst);
+	rt = (struct rt6_info *) dst;
+	neigh = rt->n;
 	if (neigh) {
 		int res = dst_neigh_output(dst, neigh, skb);
 
@@ -944,6 +946,7 @@ static int ip6_dst_lookup_tail(struct sock *sk,
 	struct net *net = sock_net(sk);
 #ifdef CONFIG_IPV6_OPTIMISTIC_DAD
 	struct neighbour *n;
+	struct rt6_info *rt;
 #endif
 	int err;
 
@@ -972,7 +975,8 @@ static int ip6_dst_lookup_tail(struct sock *sk,
 	 * dst entry of the nexthop router
 	 */
 	rcu_read_lock();
-	n = dst_get_neighbour_noref(*dst);
+	rt = (struct rt6_info *) dst;
+	n = rt->n;
 	if (n && !(n->nud_state & NUD_VALID)) {
 		struct inet6_ifaddr *ifp;
 		struct flowi6 fl_gw6;
diff --git a/net/ipv6/route.c b/net/ipv6/route.c
index 34b2988..ceff71d 100644
--- a/net/ipv6/route.c
+++ b/net/ipv6/route.c
@@ -155,7 +155,7 @@ static int rt6_bind_neighbour(struct rt6_info *rt, struct net_device *dev)
 		if (IS_ERR(n))
 			return PTR_ERR(n);
 	}
-	dst_set_neighbour(&rt->dst, n);
+	rt->n = n;
 
 	return 0;
 }
@@ -285,6 +285,9 @@ static void ip6_dst_destroy(struct dst_entry *dst)
 	struct rt6_info *rt = (struct rt6_info *)dst;
 	struct inet6_dev *idev = rt->rt6i_idev;
 
+	if (rt->n)
+		neigh_release(rt->n);
+
 	if (!(rt->dst.flags & DST_HOST))
 		dst_destroy_metrics_generic(dst);
 
@@ -335,12 +338,19 @@ static void ip6_dst_ifdown(struct dst_entry *dst, struct net_device *dev,
 	struct net_device *loopback_dev =
 		dev_net(dev)->loopback_dev;
 
-	if (dev != loopback_dev && idev && idev->dev == dev) {
-		struct inet6_dev *loopback_idev =
-			in6_dev_get(loopback_dev);
-		if (loopback_idev) {
-			rt->rt6i_idev = loopback_idev;
-			in6_dev_put(idev);
+	if (dev != loopback_dev) {
+		if (idev && idev->dev == dev) {
+			struct inet6_dev *loopback_idev =
+				in6_dev_get(loopback_dev);
+			if (loopback_idev) {
+				rt->rt6i_idev = loopback_idev;
+				in6_dev_put(idev);
+			}
+		}
+		if (rt->n && rt->n->dev == dev) {
+			rt->n->dev = loopback_dev;
+			dev_hold(loopback_dev);
+			dev_put(dev);
 		}
 	}
 }
@@ -430,7 +440,7 @@ static void rt6_probe(struct rt6_info *rt)
 	 * to no more than one per minute.
 	 */
 	rcu_read_lock();
-	neigh = rt ? dst_get_neighbour_noref(&rt->dst) : NULL;
+	neigh = rt ? rt->n : NULL;
 	if (!neigh || (neigh->nud_state & NUD_VALID))
 		goto out;
 	read_lock_bh(&neigh->lock);
@@ -477,7 +487,7 @@ static inline int rt6_check_neigh(struct rt6_info *rt)
 	int m;
 
 	rcu_read_lock();
-	neigh = dst_get_neighbour_noref(&rt->dst);
+	neigh = rt->n;
 	if (rt->rt6i_flags & RTF_NONEXTHOP ||
 	    !(rt->rt6i_flags & RTF_GATEWAY))
 		m = 1;
@@ -824,7 +834,7 @@ static struct rt6_info *rt6_alloc_clone(struct rt6_info *ort,
 
 	if (rt) {
 		rt->rt6i_flags |= RTF_CACHE;
-		dst_set_neighbour(&rt->dst, neigh_clone(dst_get_neighbour_noref_raw(&ort->dst)));
+		rt->n = neigh_clone(ort->n);
 	}
 	return rt;
 }
@@ -858,7 +868,7 @@ restart:
 	dst_hold(&rt->dst);
 	read_unlock_bh(&table->tb6_lock);
 
-	if (!dst_get_neighbour_noref_raw(&rt->dst) && !(rt->rt6i_flags & RTF_NONEXTHOP))
+	if (!rt->n && !(rt->rt6i_flags & RTF_NONEXTHOP))
 		nrt = rt6_alloc_cow(rt, &fl6->daddr, &fl6->saddr);
 	else if (!(rt->dst.flags & DST_HOST))
 		nrt = rt6_alloc_clone(rt, &fl6->daddr);
@@ -1178,7 +1188,7 @@ struct dst_entry *icmp6_dst_alloc(struct net_device *dev,
 
 	rt->dst.flags |= DST_HOST;
 	rt->dst.output  = ip6_output;
-	dst_set_neighbour(&rt->dst, neigh);
+	rt->n = neigh;
 	atomic_set(&rt->dst.__refcnt, 1);
 	rt->rt6i_dst.addr = fl6->daddr;
 	rt->rt6i_dst.plen = 128;
@@ -1715,7 +1725,7 @@ void rt6_redirect(const struct in6_addr *dest, const struct in6_addr *src,
 	dst_confirm(&rt->dst);
 
 	/* Duplicate redirect: silently ignore. */
-	old_neigh = dst_get_neighbour_noref_raw(&rt->dst);
+	old_neigh = rt->n;
 	if (neigh == old_neigh)
 		goto out;
 
@@ -1728,7 +1738,7 @@ void rt6_redirect(const struct in6_addr *dest, const struct in6_addr *src,
 		nrt->rt6i_flags &= ~RTF_GATEWAY;
 
 	nrt->rt6i_gateway = *(struct in6_addr *)neigh->primary_key;
-	dst_set_neighbour(&nrt->dst, neigh_clone(neigh));
+	nrt->n = neigh_clone(neigh);
 
 	if (ip6_ins_rt(nrt))
 		goto out;
@@ -2442,7 +2452,7 @@ static int rt6_fill_node(struct net *net,
 		goto nla_put_failure;
 
 	rcu_read_lock();
-	n = dst_get_neighbour_noref(&rt->dst);
+	n = rt->n;
 	if (n) {
 		if (nla_put(skb, RTA_GATEWAY, 16, &n->primary_key) < 0) {
 			rcu_read_unlock();
@@ -2666,7 +2676,7 @@ static int rt6_info_route(struct rt6_info *rt, void *p_arg)
 	seq_puts(m, "00000000000000000000000000000000 00 ");
 #endif
 	rcu_read_lock();
-	n = dst_get_neighbour_noref(&rt->dst);
+	n = rt->n;
 	if (n) {
 		seq_printf(m, "%pi6", n->primary_key);
 	} else {
diff --git a/net/ipv6/xfrm6_policy.c b/net/ipv6/xfrm6_policy.c
index d749484..bb02038 100644
--- a/net/ipv6/xfrm6_policy.c
+++ b/net/ipv6/xfrm6_policy.c
@@ -103,6 +103,7 @@ static int xfrm6_fill_dst(struct xfrm_dst *xdst, struct net_device *dev,
 
 	/* Sheit... I remember I did this right. Apparently,
 	 * it was magically lost, so this code needs audit */
+	xdst->u.rt6.n = neigh_clone(rt->n);
 	xdst->u.rt6.rt6i_flags = rt->rt6i_flags & (RTF_ANYCAST |
 						   RTF_LOCAL);
 	xdst->u.rt6.rt6i_metric = rt->rt6i_metric;

--M9NhX3UHpAaciwkO
Content-Type: application/octet-stream
Content-Disposition: attachment; filename=dmesg-kvm-waimea-20382-2012-07-05-21-02-50
Content-Transfer-Encoding: 8bit

[    0.000000] Initializing cgroup subsys cpuset
[    0.000000] Initializing cgroup subsys cpu
[    0.000000] Linux version 3.5.0-rc4+ (wfg@bee) (gcc version 4.7.0 (Debian 4.7.1-1) ) #16 SMP Thu Jul 5 20:59:53 CST 2012
[    0.000000] Command line: rcutorture.rcutorture_runnable=0 tree=net-next:master auth_hashtable_size=10 sunrpc.auth_hashtable_size=10 log_buf_len=8M ignore_loglevel debug sched_debug apic=debug dynamic_printk sysrq_always_enabled panic=10 hung_task_panic=1 softlockup_panic=1 unknown_nmi_panic=1 nmi_watchdog=panic,lapic load_ramdisk=2 prompt_ramdisk=0 console=ttyS0,115200 console=tty0 vga=normal ip=::::kvm::dhcp nfsroot=10.239.97.14:/nfsroot/wfg,tcp,v3,nocto,actimeo=600,nolock,rsize=524288,wsize=524288 rw link=vmlinuz-2012-07-05-21-00-48-net-net-next.master-36bdbca-97cac08-x86_64-allyesdebian-1 BOOT_IMAGE=kernel-tests/kernels/x86_64-allyesdebian/97cac0821af4474ec4ba3a9e7a36b98ed9b6db88/vmlinuz-3.5.0-rc4+
[    0.000000] Disabled fast string operations
[    0.000000] e820: BIOS-provided physical RAM map:
[    0.000000] BIOS-e820: [mem 0x0000000000000000-0x000000000009f3ff] usable
[    0.000000] BIOS-e820: [mem 0x000000000009f400-0x000000000009ffff] reserved
[    0.000000] BIOS-e820: [mem 0x00000000000f0000-0x00000000000fffff] reserved
[    0.000000] BIOS-e820: [mem 0x0000000000100000-0x000000001fffcfff] usable
[    0.000000] BIOS-e820: [mem 0x000000001fffd000-0x000000001fffffff] reserved
[    0.000000] BIOS-e820: [mem 0x00000000fffbc000-0x00000000ffffffff] reserved
[    0.000000] debug: ignoring loglevel setting.
[    0.000000] NX (Execute Disable) protection: active
[    0.000000] DMI 2.4 present.
[    0.000000] DMI: Bochs Bochs, BIOS Bochs 01/01/2007
[    0.000000] e820: update [mem 0x00000000-0x0000ffff] usable ==> reserved
[    0.000000] e820: remove [mem 0x000a0000-0x000fffff] usable
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
[    0.000000] ACPI: RSDP 00000000000f8810 00014 (v00 BOCHS )
[    0.000000] ACPI: RSDT 000000001fffde10 00034 (v01 BOCHS  BXPCRSDT 00000001 BXPC 00000001)
[    0.000000] ACPI: FACP 000000001ffffe40 00074 (v01 BOCHS  BXPCFACP 00000001 BXPC 00000001)
[    0.000000] ACPI: DSDT 000000001fffdfd0 01E22 (v01   BXPC   BXDSDT 00000001 INTL 20090123)
[    0.000000] ACPI: FACS 000000001ffffe00 00040
[    0.000000] ACPI: SSDT 000000001fffdf80 00044 (v01 BOCHS  BXPCSSDT 00000001 BXPC 00000001)
[    0.000000] ACPI: APIC 000000001fffde90 0007A (v01 BOCHS  BXPCAPIC 00000001 BXPC 00000001)
[    0.000000] ACPI: HPET 000000001fffde50 00038 (v01 BOCHS  BXPCHPET 00000001 BXPC 00000001)
[    0.000000] ACPI: Local APIC address 0xfee00000
[    0.000000] mapped APIC to ffffffffff5fb000 (        fee00000)
[    0.000000] No NUMA configuration found
[    0.000000] Faking a node at [mem 0x0000000000000000-0x000000001fffcfff]
[    0.000000] Initmem setup node 0 [mem 0x00000000-0x1fffcfff]
[    0.000000]   NODE_DATA [mem 0x1f6f6000-0x1f6fafff]
[    0.000000] kvm-clock: Using msrs 12 and 11
[    0.000000] kvm-clock: cpu 0, msr 0:45efa81, boot clock
[    0.000000]  [ffffea0000000000-ffffea00007fffff] PMD -> [ffff88001e600000-ffff88001edfffff] on node 0
[    0.000000] Zone ranges:
[    0.000000]   DMA      [mem 0x00010000-0x00ffffff]
[    0.000000]   DMA32    [mem 0x01000000-0xffffffff]
[    0.000000]   Normal   empty
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
[    0.000000] pcpu-alloc: s1924184 r8192 d21416 u2097152 alloc=1*2097152
[    0.000000] pcpu-alloc: [0] 0 [0] 1 
[    0.000000] kvm-clock: cpu 0, msr 0:1f3d4a81, primary cpu clock
[    0.000000] Built 1 zonelists in Node order, mobility grouping on.  Total pages: 128902
[    0.000000] Policy zone: DMA32
[    0.000000] Kernel command line: rcutorture.rcutorture_runnable=0 tree=net-next:master auth_hashtable_size=10 sunrpc.auth_hashtable_size=10 log_buf_len=8M ignore_loglevel debug sched_debug apic=debug dynamic_printk sysrq_always_enabled panic=10 hung_task_panic=1 softlockup_panic=1 unknown_nmi_panic=1 nmi_watchdog=panic,lapic load_ramdisk=2 prompt_ramdisk=0 console=ttyS0,115200 console=tty0 vga=normal ip=::::kvm::dhcp nfsroot=10.239.97.14:/nfsroot/wfg,tcp,v3,nocto,actimeo=600,nolock,rsize=524288,wsize=524288 rw link=vmlinuz-2012-07-05-21-00-48-net-net-next.master-36bdbca-97cac08-x86_64-allyesdebian-1 BOOT_IMAGE=kernel-tests/kernels/x86_64-allyesdebian/97cac0821af4474ec4ba3a9e7a36b98ed9b6db88/vmlinuz-3.5.0-rc4+
[    0.000000] sysrq: sysrq always enabled.
[    0.000000] PID hash table entries: 2048 (order: 2, 16384 bytes)
[    0.000000] __ex_table already sorted, skipping sort
[    0.000000] Checking aperture...
[    0.000000] No AGP bridge found
[    0.000000] Calgary: detecting Calgary via BIOS EBDA area
[    0.000000] Calgary: Unable to locate Rio Grande table in EBDA - bailing!
[    0.000000] Memory: 430204k/524276k available (31076k kernel code, 452k absent, 93620k reserved, 22272k data, 3908k init)
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
[    0.000000] Detected 3299.986 MHz processor.
[    0.004000] Calibrating delay loop (skipped) preset value.. 6599.97 BogoMIPS (lpj=13199944)
[    0.004000] pid_max: default: 32768 minimum: 301
[    0.004457] Security Framework initialized
[    0.005464] AppArmor: AppArmor disabled by boot time parameter
[    0.008093] Dentry cache hash table entries: 65536 (order: 7, 524288 bytes)
[    0.010345] Inode-cache hash table entries: 32768 (order: 6, 262144 bytes)
[    0.012239] Mount-cache hash table entries: 256
[    0.015457] Initializing cgroup subsys cpuacct
[    0.016008] Initializing cgroup subsys memory
[    0.017246] Initializing cgroup subsys devices
[    0.018299] Initializing cgroup subsys freezer
[    0.020008] Initializing cgroup subsys net_cls
[    0.021079] Initializing cgroup subsys blkio
[    0.022400] Disabled fast string operations
[    0.023430] mce: CPU supports 10 MCE banks
[    0.024056] numa_add_cpu cpu 0 node 0: mask now 0
[    0.026650] ACPI: Core revision 20120320
[    0.030463] ftrace: allocating 117555 entries in 460 pages
[    0.056303] Getting VERSION: 50014
[    0.060013] Getting VERSION: 50014
[    0.060877] Getting ID: 0
[    0.061602] Getting ID: ff000000
[    0.062423] Getting LVT0: 8700
[    0.063225] Getting LVT1: 8400
[    0.064048] enabled ExtINT on CPU#0
[    0.065643] ENABLING IO-APIC IRQs
[    0.066505] init IO_APIC IRQs
[    0.067286]  apic 2 pin 0 not connected
[    0.068023] IOAPIC[0]: Set routing entry (2-1 -> 0x31 -> IRQ 1 Mode:0 Active:0 Dest:1)
[    0.069867] IOAPIC[0]: Set routing entry (2-2 -> 0x30 -> IRQ 0 Mode:0 Active:0 Dest:1)
[    0.072025] IOAPIC[0]: Set routing entry (2-3 -> 0x33 -> IRQ 3 Mode:0 Active:0 Dest:1)
[    0.073862] IOAPIC[0]: Set routing entry (2-4 -> 0x34 -> IRQ 4 Mode:0 Active:0 Dest:1)
[    0.076024] IOAPIC[0]: Set routing entry (2-5 -> 0x35 -> IRQ 5 Mode:1 Active:0 Dest:1)
[    0.077870] IOAPIC[0]: Set routing entry (2-6 -> 0x36 -> IRQ 6 Mode:0 Active:0 Dest:1)
[    0.080024] IOAPIC[0]: Set routing entry (2-7 -> 0x37 -> IRQ 7 Mode:0 Active:0 Dest:1)
[    0.081854] IOAPIC[0]: Set routing entry (2-8 -> 0x38 -> IRQ 8 Mode:0 Active:0 Dest:1)
[    0.084024] IOAPIC[0]: Set routing entry (2-9 -> 0x39 -> IRQ 9 Mode:1 Active:0 Dest:1)
[    0.085847] IOAPIC[0]: Set routing entry (2-10 -> 0x3a -> IRQ 10 Mode:1 Active:0 Dest:1)
[    0.087724] IOAPIC[0]: Set routing entry (2-11 -> 0x3b -> IRQ 11 Mode:1 Active:0 Dest:1)
[    0.088024] IOAPIC[0]: Set routing entry (2-12 -> 0x3c -> IRQ 12 Mode:0 Active:0 Dest:1)
[    0.089969] IOAPIC[0]: Set routing entry (2-13 -> 0x3d -> IRQ 13 Mode:0 Active:0 Dest:1)
[    0.092038] IOAPIC[0]: Set routing entry (2-14 -> 0x3e -> IRQ 14 Mode:0 Active:0 Dest:1)
[    0.093887] IOAPIC[0]: Set routing entry (2-15 -> 0x3f -> IRQ 15 Mode:0 Active:0 Dest:1)
[    0.096022]  apic 2 pin 16 not connected
[    0.096979]  apic 2 pin 17 not connected
[    0.097917]  apic 2 pin 18 not connected
[    0.100009]  apic 2 pin 19 not connected
[    0.100958]  apic 2 pin 20 not connected
[    0.101915]  apic 2 pin 21 not connected
[    0.102855]  apic 2 pin 22 not connected
[    0.104009]  apic 2 pin 23 not connected
[    0.105111] ..TIMER: vector=0x30 apic1=0 pin1=2 apic2=-1 pin2=-1
[    0.108012] CPU0: Intel Common KVM processor stepping 01
[    0.112010] Using local APIC timer interrupts.
[    0.112010] calibrating APIC timer ...
[    0.116006] ... lapic delta = 6250433
[    0.116006] ... PM-Timer delta = 357988
[    0.116006] ... PM-Timer result ok
[    0.116006] ..... delta 6250433
[    0.116006] ..... mult: 268437275
[    0.116006] ..... calibration result: 4000277
[    0.116006] ..... CPU clock speed is 3299.3759 MHz.
[    0.116006] ..... host bus clock speed is 1000.0277 MHz.
[    0.116056] Performance Events: unsupported Netburst CPU model 6 no PMU driver, software events only.
[    0.119687] Testing tracer nop: PASSED
[    0.120045] NMI watchdog: disabled (cpu0): hardware events not enabled
[    0.124642] lockdep: fixing up alternatives.
[    0.125886] Booting Node   0, Processors  #1 Ok.
[    0.004000] kvm-clock: cpu 1, msr 0:1f5d4a81, secondary cpu clock
[    0.004000] masked ExtINT on CPU#1
[    0.004000] Disabled fast string operations
[    0.004000] numa_add_cpu cpu 1 node 0: mask now 0-1
[    0.144008] TSC synchronization [CPU#0 -> CPU#1]:
[    0.144008] Measured 14 cycles TSC warp between CPUs, turning off TSC clock.
[    0.144008] Marking TSC unstable due to check_tsc_sync_source failed
[    0.148192] Brought up 2 CPUs
[    0.149083] Total of 2 processors activated (13199.94 BogoMIPS).
[    0.152104] CPU0 attaching sched-domain:
[    0.153073]  domain 0: span 0-1 level CPU
[    0.154129]   groups: 0 (cpu_power = 1023) 1
[    0.155150] CPU1 attaching sched-domain:
[    0.156039]  domain 0: span 0-1 level CPU
[    0.157003]   groups: 1 0 (cpu_power = 1023)
[    0.158428] devtmpfs: initialized
[    0.171252] xor: automatically using best checksumming function:
[    0.212019]    generic_sse:   226.000 MB/sec
[    0.213049] atomic64 test passed for x86-64 platform with CX8 and with SSE
[    0.215235] dummy: 
[    0.216618] NET: Registered protocol family 16
[    0.223991] ACPI: bus type pci registered
[    0.224200] dca service started, version 1.12.1
[    0.225490] PCI: Using configuration type 1 for base access
[    0.230638] mtrr: your CPUs had inconsistent variable MTRR settings
[    0.232017] mtrr: your CPUs had inconsistent MTRRdefType settings
[    0.233361] mtrr: probably your BIOS does not setup all CPUs.
[    0.234722] mtrr: corrected configuration.
[    0.336456] bio: create slab <bio-0> at 0
[    0.404029] raid6: sse2x1   10027 MB/s
[    0.472034] raid6: sse2x2   12493 MB/s
[    0.540037] raid6: sse2x4   14754 MB/s
[    0.540959] raid6: using algorithm sse2x4 (14754 MB/s)
[    0.542213] raid6: using intx1 recovery algorithm
[    0.543475] ACPI: Added _OSI(Module Device)
[    0.544039] ACPI: Added _OSI(Processor Device)
[    0.545090] ACPI: Added _OSI(3.0 _SCP Extensions)
[    0.546276] ACPI: Added _OSI(Processor Aggregator Device)
[    0.549788] ACPI: EC: Look up EC in DSDT
[    0.556297] ACPI: Interpreter enabled
[    0.557375] ACPI: (supports S0 S3 S4 S5)
[    0.558475] ACPI: Using IOAPIC for interrupt routing
[    0.570460] ACPI: No dock devices found.
[    0.571432] PCI: Ignoring host bridge windows from ACPI; if necessary, use "pci=use_crs" and report a bug
[    0.572105] ACPI: PCI Root Bridge [PCI0] (domain 0000 [bus 00-ff])
[    0.573627] pci_root PNP0A03:00: host bridge window [io  0x0000-0x0cf7] (ignored)
[    0.576040] pci_root PNP0A03:00: host bridge window [io  0x0d00-0xffff] (ignored)
[    0.577901] pci_root PNP0A03:00: host bridge window [mem 0x000a0000-0x000bffff] (ignored)
[    0.580040] pci_root PNP0A03:00: host bridge window [mem 0xe0000000-0xfebfffff] (ignored)
[    0.582040] PCI: root bus 00: using default resources
[    0.583394] PCI host bridge to bus 0000:00
[    0.584042] pci_bus 0000:00: root bus resource [io  0x0000-0xffff]
[    0.585526] pci_bus 0000:00: root bus resource [mem 0x00000000-0xffffffffff]
[    0.588075] pci 0000:00:00.0: [8086:1237] type 00 class 0x060000
[    0.589824] pci 0000:00:01.0: [8086:7000] type 00 class 0x060100
[    0.591773] pci 0000:00:01.1: [8086:7010] type 00 class 0x010180
[    0.592367] pci 0000:00:01.1: reg 20: [io  0xc000-0xc00f]
[    0.593978] pci 0000:00:01.3: [8086:7113] type 00 class 0x068000
[    0.596544] pci 0000:00:01.3: quirk: [io  0xb000-0xb03f] claimed by PIIX4 ACPI
[    0.598307] pci 0000:00:01.3: quirk: [io  0xb100-0xb10f] claimed by PIIX4 SMB
[    0.600242] pci 0000:00:02.0: [1013:00b8] type 00 class 0x030000
[    0.610313] pci 0000:00:02.0: reg 10: [mem 0xf0000000-0xf1ffffff pref]
[    0.616140] pci 0000:00:02.0: reg 14: [mem 0xf2000000-0xf2000fff]
[    0.647027] pci 0000:00:02.0: reg 30: [mem 0xf2010000-0xf201ffff pref]
[    0.648721] pci 0000:00:03.0: [8086:100e] type 00 class 0x020000
[    0.656051] pci 0000:00:03.0: reg 10: [mem 0xf2020000-0xf203ffff]
[    0.660058] pci 0000:00:03.0: reg 14: [io  0xc040-0xc07f]
[    0.674466] pci 0000:00:03.0: reg 30: [mem 0xf2040000-0xf2047fff pref]
[    0.676562] pci 0000:00:04.0: [1af4:1001] type 00 class 0x010000
[    0.680387] pci 0000:00:04.0: reg 10: [io  0xc080-0xc0bf]
[    0.684224] pci 0000:00:04.0: reg 14: [mem 0xf2048000-0xf2048fff]
[    0.689752] pci 0000:00:05.0: [1af4:1001] type 00 class 0x010000
[    0.692189] pci 0000:00:05.0: reg 10: [io  0xc0c0-0xc0ff]
[    0.693649] pci 0000:00:05.0: reg 14: [mem 0xf2049000-0xf2049fff]
[    0.696760] pci 0000:00:06.0: [1af4:1001] type 00 class 0x010000
[    0.698403] pci 0000:00:06.0: reg 10: [io  0xc100-0xc13f]
[    0.699808] pci 0000:00:06.0: reg 14: [mem 0xf204a000-0xf204afff]
[    0.700856] pci 0000:00:07.0: [1af4:1001] type 00 class 0x010000
[    0.702416] pci 0000:00:07.0: reg 10: [io  0xc140-0xc17f]
[    0.704130] pci 0000:00:07.0: reg 14: [mem 0xf204b000-0xf204bfff]
[    0.706406] pci 0000:00:08.0: [1af4:1001] type 00 class 0x010000
[    0.708191] pci 0000:00:08.0: reg 10: [io  0xc180-0xc1bf]
[    0.709654] pci 0000:00:08.0: reg 14: [mem 0xf204c000-0xf204cfff]
[    0.712609] pci 0000:00:09.0: [1af4:1001] type 00 class 0x010000
[    0.714227] pci 0000:00:09.0: reg 10: [io  0xc1c0-0xc1ff]
[    0.715608] pci 0000:00:09.0: reg 14: [mem 0xf204d000-0xf204dfff]
[    0.716790] pci 0000:00:0a.0: [8086:25ab] type 00 class 0x088000
[    0.718336] pci 0000:00:0a.0: reg 10: [mem 0xf204e000-0xf204e00f]
[    0.720856] ACPI: PCI Interrupt Routing Table [\_SB_.PCI0._PRT]
[    0.725018]  pci0000:00: Unable to request _OSC control (_OSC support mask: 0x1e)
[    0.743786] ACPI: PCI Interrupt Link [LNKA] (IRQs 5 *10 11)
[    0.744216] ACPI: PCI Interrupt Link [LNKB] (IRQs 5 *10 11)
[    0.745791] ACPI: PCI Interrupt Link [LNKC] (IRQs 5 10 *11)
[    0.748209] ACPI: PCI Interrupt Link [LNKD] (IRQs 5 10 *11)
[    0.750401] vgaarb: device added: PCI:0000:00:02.0,decodes=io+mem,owns=io+mem,locks=none
[    0.752071] vgaarb: loaded
[    0.752904] vgaarb: bridge control possible 0000:00:02.0
[    0.756109] tps65010: version 2 May 2005
[    0.788105] tps65010: no chip?
[    0.792421] SCSI subsystem initialized
[    0.793830] libata version 3.00 loaded.
[    0.793830] ACPI: bus type usb registered
[    0.796257] usbcore: registered new interface driver usbfs
[    0.797729] usbcore: registered new interface driver hub
[    0.799125] usbcore: registered new device driver usb
[    0.800313] Linux media interface: v0.10
[    0.801478] Linux video capture interface: v2.00
[    0.802745] pps_core: LinuxPPS API ver. 1 registered
[    0.804054] pps_core: Software ver. 5.3.6 - Copyright 2005-2007 Rodolfo Giometti <giometti@linux.it>
[    0.806438] PTP clock support registered
[    0.808427] wmi: Mapper loaded
[    5.809529] Advanced Linux Sound Architecture Driver Version 1.0.25.
[    5.812412] PCI: Using ACPI for IRQ routing
[    5.813498] PCI: pci_cache_line_size set to 64 bytes
[    5.815029] e820: reserve RAM buffer [mem 0x0009f400-0x0009ffff]
[    5.816371] e820: reserve RAM buffer [mem 0x1fffd000-0x1fffffff]
[    5.818624] Sangoma WANPIPE Router v1.1 (c) 1995-2000 Sangoma Technologies Inc.
[    5.820524] NET: Registered protocol family 23
[    5.821968] Bluetooth: Core ver 2.16
[    5.822919] NET: Registered protocol family 31
[    5.824412] Bluetooth: HCI device and connection manager initialized
[    5.825865] Bluetooth: HCI socket layer initialized
[    5.827025] Bluetooth: L2CAP socket layer initialized
[    5.828460] Bluetooth: SCO socket layer initialized
[    5.829594] NET: Registered protocol family 8
[    5.830661] NET: Registered protocol family 20
[    5.832616] cfg80211: Calling CRDA to update world regulatory domain
[    5.834460] nfc: nfc_init: NFC Core ver 0.1
[    5.834460] NET: Registered protocol family 39
[    5.840587] HPET: 3 timers in total, 0 timers will be used for per-cpu timer
[    5.842209] hpet0: at MMIO 0xfed00000, IRQs 2, 8, 0
[    5.843337] hpet0: 3 comparators, 64-bit 100.000000 MHz counter
[    5.852433] Switching to clocksource kvm-clock
[    6.132997] FS-Cache: Loaded
[    6.134364] CacheFiles: Loaded
[    6.135341] pnp: PnP ACPI init
[    6.136212] ACPI: bus type pnp registered
[    6.137268] pnp 00:00: [bus 00-ff]
[    6.138121] pnp 00:00: [io  0x0cf8-0x0cff]
[    6.139108] pnp 00:00: [io  0x0000-0x0cf7 window]
[    6.140310] pnp 00:00: [io  0x0d00-0xffff window]
[    6.141408] pnp 00:00: [mem 0x000a0000-0x000bffff window]
[    6.142613] pnp 00:00: [mem 0xe0000000-0xfebfffff window]
[    6.144160] pnp 00:00: Plug and Play ACPI device, IDs PNP0a03 (active)
[    6.145801] pnp 00:01: [io  0x0070-0x0071]
[    6.146808] IOAPIC[0]: Set routing entry (2-8 -> 0x38 -> IRQ 8 Mode:0 Active:0 Dest:3)
[    6.148747] pnp 00:01: [irq 8]
[    6.149543] pnp 00:01: [io  0x0072-0x0077]
[    6.150654] pnp 00:01: Plug and Play ACPI device, IDs PNP0b00 (active)
[    6.152297] pnp 00:02: [io  0x0060]
[    6.153174] pnp 00:02: [io  0x0064]
[    6.154047] IOAPIC[0]: Set routing entry (2-1 -> 0x31 -> IRQ 1 Mode:0 Active:0 Dest:3)
[    6.155950] pnp 00:02: [irq 1]
[    6.156898] pnp 00:02: Plug and Play ACPI device, IDs PNP0303 (active)
[    6.158399] IOAPIC[0]: Set routing entry (2-12 -> 0x3c -> IRQ 12 Mode:0 Active:0 Dest:3)
[    6.168484] pnp 00:03: [irq 12]
[    6.169414] pnp 00:03: Plug and Play ACPI device, IDs PNP0f13 (active)
[    6.170938] pnp 00:04: [io  0x03f2-0x03f5]
[    6.171962] pnp 00:04: [io  0x03f7]
[    6.172865] IOAPIC[0]: Set routing entry (2-6 -> 0x36 -> IRQ 6 Mode:0 Active:0 Dest:3)
[    6.174686] pnp 00:04: [irq 6]
[    6.175572] pnp 00:04: [dma 2]
[    6.176509] pnp 00:04: Plug and Play ACPI device, IDs PNP0700 (active)
[    6.178054] pnp 00:05: [io  0x0378-0x037f]
[    6.179054] IOAPIC[0]: Set routing entry (2-7 -> 0x37 -> IRQ 7 Mode:0 Active:0 Dest:3)
[    6.180916] pnp 00:05: [irq 7]
[    6.181829] pnp 00:05: Plug and Play ACPI device, IDs PNP0400 (active)
[    6.183402] pnp 00:06: [io  0x03f8-0x03ff]
[    6.184446] IOAPIC[0]: Set routing entry (2-4 -> 0x34 -> IRQ 4 Mode:0 Active:0 Dest:3)
[    6.186276] pnp 00:06: [irq 4]
[    6.187208] pnp 00:06: Plug and Play ACPI device, IDs PNP0501 (active)
[    6.188753] pnp 00:07: [mem 0xfed00000-0xfed003ff]
[    6.190005] pnp 00:07: Plug and Play ACPI device, IDs PNP0103 (active)
[    6.191718] pnp: PnP ACPI: found 8 devices
[    6.192714] ACPI: ACPI bus type pnp unregistered
[    6.238375] pci_bus 0000:00: resource 4 [io  0x0000-0xffff]
[    6.240755] pci_bus 0000:00: resource 5 [mem 0x00000000-0xffffffffff]
[    6.242686] NET: Registered protocol family 2
[    6.244221] IP route cache hash table entries: 4096 (order: 3, 32768 bytes)
[    6.246916] TCP established hash table entries: 16384 (order: 6, 262144 bytes)
[    6.249446] TCP bind hash table entries: 16384 (order: 8, 1310720 bytes)
[    6.253240] TCP: Hash tables configured (established 16384 bind 16384)
[    6.254754] TCP: reno registered
[    6.255759] UDP hash table entries: 256 (order: 3, 49152 bytes)
[    6.257203] UDP-Lite hash table entries: 256 (order: 3, 49152 bytes)
[    6.259262] NET: Registered protocol family 1
[    6.261509] RPC: Registered named UNIX socket transport module.
[    6.262836] RPC: Registered udp transport module.
[    6.264106] RPC: Registered tcp transport module.
[    6.265314] RPC: Registered tcp NFSv4.1 backchannel transport module.
[    6.266720] pci 0000:00:00.0: Limiting direct PCI/PCI transfers
[    6.268202] pci 0000:00:01.0: PIIX3: Enabling Passive Release
[    6.269493] pci 0000:00:01.0: Activating ISA DMA hang workarounds
[    6.270901] pci 0000:00:02.0: Boot video device
[    6.272198] PCI: CLS 0 bytes, default 64
[    6.304389] DMA-API: preallocated 32768 debug entries
[    6.305545] DMA-API: debugging enabled by kernel config
[    6.309958] kvm: no hardware support
[    6.310867] has_svm: not amd
[    6.311745] kvm: no hardware support
[    6.313926] Machine check injector initialized
[    6.317556] microcode: CPU0 sig=0xf61, pf=0x1, revision=0x1
[    6.318893] microcode: CPU1 sig=0xf61, pf=0x1, revision=0x1
[    6.320664] microcode: Microcode Update Driver: v2.00 <tigran@aivazian.fsnet.co.uk>, Peter Oruba
[    6.323577] blowfish-x86_64: performance on this CPU would be suboptimal: disabling blowfish-x86_64.
[    6.323597] cryptomgr_test (29) used greatest stack depth: 6008 bytes left
[    6.327999] cryptomgr_test (30) used greatest stack depth: 5784 bytes left
[    6.328051] twofish-x86_64-3way: performance on this CPU would be suboptimal: disabling twofish-x86_64-3way.
[    6.338822] sha1_ssse3: Neither AVX nor SSSE3 is available/usable.
[    6.344386] Initializing RT-Tester: OK
[    6.345537] audit: initializing netlink socket (disabled)
[    6.346870] type=2000 audit(1341493285.340:1): initialized
[    6.408121] Kprobe smoke test started
[    6.470390] Kprobe smoke test passed successfully
[    6.850738] Testing tracer function: PASSED
[    7.320153] Testing dynamic ftrace: PASSED
[    7.975888] Testing dynamic ftrace ops #1: (1 0 1 1 0) (1 1 2 1 0) (2 1 3 1 906) (2 2 4 1 923) PASSED
[    8.632256] Testing dynamic ftrace ops #2: (1 0 1 56 0) (1 1 2 73 0) (2 1 3 1 23) (2 2 4 29 50) PASSED
[    9.132185] Testing tracer irqsoff: PASSED
[    9.932301] Testing tracer wakeup: PASSED
[   10.744315] Testing tracer wakeup_rt: PASSED
[   11.320171] Testing tracer function_graph: PASSED
[   11.322632] HugeTLB registered 2 MB page size, pre-allocated 0 pages
[   11.326201] VFS: Disk quotas dquot_6.5.2
[   11.327404] Dquot-cache hash table entries: 512 (order 0, 4096 bytes)
[   11.331080] DLM installed
[   11.333526] squashfs: version 4.0 (2009/01/31) Phillip Lougher
[   11.338910] NFS: Registering the id_resolver key type
[   11.340259] Key type id_resolver registered
[   11.341310] FS-Cache: Netfs 'nfs' registered for caching
[   11.343631] nfs4filelayout_init: NFSv4 File Layout Driver Registering...
[   11.345130] Installing knfsd (copyright (C) 1996 okir@monad.swb.de).
[   11.348490] FS-Cache: Netfs 'cifs' registered for caching
[   11.350479] Key type cifs.spnego registered
[   11.351634] Key type cifs.idmap registered
[   11.352730] NTFS driver 2.1.30 [Flags: R/W].
[   11.354155] EFS: 1.0a - http://aeschi.ch.eu.org/efs/
[   11.355573] jffs2: version 2.2. (NAND) (SUMMARY)  © 2001-2006 Red Hat, Inc.
[   11.358159] ROMFS MTD (C) 2007 Red Hat, Inc.
[   11.359430] QNX4 filesystem 0.2.3 registered.
[   11.360972] fuse init (API version 7.19)
[   11.363135] JFS: nTxBlock = 3360, nTxLock = 26887
[   11.369320] SGI XFS with ACLs, security attributes, realtime, large block/inode numbers, no debug enabled
[   11.373538] 9p: Installing v9fs 9p2000 file system support
[   11.374862] FS-Cache: Netfs '9p' registered for caching
[   11.376484] NILFS version 2 loaded
[   11.377334] BeFS version: 0.9.3
[   11.378209] OCFS2 1.5.0
[   11.379457] ocfs2: Registered cluster interface o2cb
[   11.381056] ocfs2: Registered cluster interface user
[   11.382196] OCFS2 DLMFS 1.5.0
[   11.383264] OCFS2 User DLM kernel interface loaded
[   11.384428] OCFS2 Node Manager 1.5.0
[   11.386051] OCFS2 DLM 1.5.0
[   11.388153] Btrfs loaded
[   11.390175] GFS2 installed
[   11.391260] ceph: loaded (mds proto 32)
[   11.392280] msgmni has been set to 840
[   11.394017] alg: No test for cipher_null (cipher_null-generic)
[   11.398187] alg: No test for ecb(cipher_null) (ecb-cipher_null)
[   11.402318] alg: No test for digest_null (digest_null-generic)
[   11.406413] alg: No test for compress_null (compress_null-generic)
[   11.410424] cryptomgr_test (67) used greatest stack depth: 5608 bytes left
[   11.412104] cryptomgr_test (68) used greatest stack depth: 5400 bytes left
[   11.427516] alg: No test for fcrypt (fcrypt-generic)
[   11.449225] cryptomgr_test (108) used greatest stack depth: 5336 bytes left
[   11.454537] alg: No test for stdrng (krng)
[   11.472263] alg: No test for fips(ansi_cprng) (fips_ansi_cprng)
[   11.476248] cryptomgr_test (113) used greatest stack depth: 5160 bytes left
[   11.476276] NET: Registered protocol family 38
[   11.476308] async_tx: api initialized (async)
[   11.480210] Block layer SCSI generic (bsg) driver version 0.4 loaded (major 249)
[   11.482618] io scheduler noop registered
[   11.484117] io scheduler deadline registered
[   11.485756] io scheduler cfq registered (default)
[   11.487373] start plist test
[   11.490032] end plist test
[   11.490759] list_sort_test: start testing list_sort()
[   11.493871] pci_hotplug: PCI Hot Plug PCI Core version: 0.5
[   11.495233] pciehp: PCI Express Hot Plug Controller Driver version: 0.4
[   11.496780] cpcihp_zt5550: ZT5550 CompactPCI Hot Plug Driver version: 0.2
[   11.498321] cpcihp_generic: Generic port I/O CompactPCI Hot Plug Driver version: 0.1
[   11.500315] cpcihp_generic: not configured, disabling.
[   11.501610] shpchp: Standard Hot Plug PCI Controller Driver version: 0.4
[   11.503071] acpiphp: ACPI Hot Plug PCI Controller Driver version: 0.5
[   11.504958] acpiphp: Slot [1] registered
[   11.506025] acpiphp: Slot [2] registered
[   11.507042] acpiphp: Slot [3] registered
[   11.508178] acpiphp: Slot [4] registered
[   11.509219] acpiphp: Slot [5] registered
[   11.510264] acpiphp: Slot [6] registered
[   11.511361] acpiphp: Slot [7] registered
[   11.512453] acpiphp: Slot [8] registered
[   11.513502] acpiphp: Slot [9] registered
[   11.514519] acpiphp: Slot [10] registered
[   11.515731] acpiphp: Slot [11] registered
[   11.516818] acpiphp: Slot [12] registered
[   11.517906] acpiphp: Slot [13] registered
[   11.518999] acpiphp: Slot [14] registered
[   11.520196] acpiphp: Slot [15] registered
[   11.521267] acpiphp: Slot [16] registered
[   11.522309] acpiphp: Slot [17] registered
[   11.523512] acpiphp: Slot [18] registered
[   11.524582] acpiphp: Slot [19] registered
[   11.525626] acpiphp: Slot [20] registered
[   11.526693] acpiphp: Slot [21] registered
[   11.527871] acpiphp: Slot [22] registered
[   11.528952] acpiphp: Slot [23] registered
[   11.530006] acpiphp: Slot [24] registered
[   11.531046] acpiphp: Slot [25] registered
[   11.532261] acpiphp: Slot [26] registered
[   11.533303] acpiphp: Slot [27] registered
[   11.534363] acpiphp: Slot [28] registered
[   11.535595] acpiphp: Slot [29] registered
[   11.536694] acpiphp: Slot [30] registered
[   11.537739] acpiphp: Slot [31] registered
[   11.540996] acpiphp_ibm: ibm_acpiphp_init: acpi_walk_namespace failed
[   11.542824] progear_bl: ALI M7101 PMU not found.
[   11.544752] VIA Graphics Integration Chipset framebuffer 2.4 initializing
[   11.546730] vmlfb: initializing
[   11.547780] Could not find Carillo Ranch MCH device.
[   11.549109] no IO addresses supplied
[   11.558249] hgafb: HGA card not detected.
[   11.559348] hgafb: probe of hgafb.0 failed with error -22
[   11.560847] usbcore: registered new interface driver udlfb
[   11.563216] uvesafb: failed to execute /sbin/v86d
[   11.564389] uvesafb: make sure that the v86d helper is installed and executable
[   11.566112] uvesafb: Getting VBE info block failed (eax=0x4f00, err=-2)
[   11.567712] uvesafb: vbe_init() failed with -22
[   11.568828] uvesafb: probe of uvesafb.0 failed with error -22
[   11.570731] input: Power Button as /devices/LNXSYSTM:00/LNXPWRBN:00/input/input0
[   11.572618] ACPI: Power Button [PWRF]
[   11.581946] GHES: HEST is not enabled!
[   11.582869] ioatdma: Intel(R) QuickData Technology Driver 4.00
[   11.585006] ACPI: PCI Interrupt Link [LNKD] enabled at IRQ 11
[   11.586305] IOAPIC[0]: Set routing entry (2-11 -> 0x3b -> IRQ 11 Mode:1 Active:0 Dest:3)
[   11.588375] virtio-pci 0000:00:04.0: setting latency timer to 64
[   11.590300] ACPI: PCI Interrupt Link [LNKA] enabled at IRQ 10
[   11.591691] IOAPIC[0]: Set routing entry (2-10 -> 0x3a -> IRQ 10 Mode:1 Active:0 Dest:3)
[   11.593658] virtio-pci 0000:00:05.0: setting latency timer to 64
[   11.595725] ACPI: PCI Interrupt Link [LNKB] enabled at IRQ 10
[   11.597142] virtio-pci 0000:00:06.0: setting latency timer to 64
[   11.598945] ACPI: PCI Interrupt Link [LNKC] enabled at IRQ 11
[   11.600395] virtio-pci 0000:00:07.0: setting latency timer to 64
[   11.601995] virtio-pci 0000:00:08.0: setting latency timer to 64
[   11.603764] virtio-pci 0000:00:09.0: setting latency timer to 64
[   11.605325] XENFS: not registering filesystem on non-xen platform
[   11.607103] HDLC line discipline maxframe=4096
[   11.608261] N_HDLC line discipline registered.
[   11.609317] r3964: Philips r3964 Driver $Revision: 1.10 $
[   11.610545] Serial: 8250/16550 driver, 4 ports, IRQ sharing enabled
[   11.636088] serial8250: ttyS0 at I/O 0x3f8 (irq = 4) is a 16550A
[   11.663762] 00:06: ttyS0 at I/O 0x3f8 (irq = 4) is a 16550A
[   11.666438] Cyclades driver 2.6
[   11.667748] MOXA Intellio family driver version 6.0k
[   11.733589] MOXA Smartio/Industio family driver version 2.0.5
[   11.737726] Initializing Nozomi driver 2.1d
[   11.741194] RocketPort device driver module, version 2.09, 12-June-2003
[   11.745882] No rocketport ports found; unloading driver
[   11.749595] SyncLink GT
[   11.750571] SyncLink GT, tty major#244
[   11.751741] SyncLink GT no devices found
[   11.752758] SyncLink MultiPort driver $Revision: 4.38 $
[   11.816124] SyncLink MultiPort driver $Revision: 4.38 $, tty major#243
[   11.820413] SyncLink serial driver $Revision: 4.38 $
[   11.900206] SyncLink serial driver $Revision: 4.38 $, tty major#242
[   11.907108] lp: driver loaded but no devices found
[   11.910533] Applicom driver: $Id: ac.c,v 1.30 2000/03/22 16:03:57 dwmw2 Exp $
[   11.915059] ac.o: No PCI boards found.
[   11.917712] ac.o: For an ISA board you must supply memory and irq parameters.
[   11.921734] Non-volatile memory driver v1.3
[   11.923657] ppdev: user-space parallel port driver
[   11.925030] telclk_interrupt = 0xf non-mcpbl0010 hw.
[   11.926212] smapi::smapi_init, ERROR invalid usSmapiID
[   11.927520] mwave: tp3780i::tp3780I_InitializeBoardData: Error: SMAPI is not available on this machine
[   11.929653] mwave: mwavedd::mwave_init: Error: Failed to initialize board data
[   11.931527] mwave: mwavedd::mwave_init: Error: Failed to initialize
[   11.932947] Linux agpgart interface v0.103
[   11.935866] SyncLink PC Card driver $Revision: 4.34 $, tty major#240
[   11.937463] ipmi message handler version 39.2
[   11.938517] ipmi device interface
[   11.939629] IPMI System Interface driver.
[   11.940817] ipmi_si: Adding default-specified kcs state machine
[   11.942144] ipmi_si: Trying default-specified kcs state machine at i/o address 0xca2, slave address 0x0, irq 0
[   11.944548] ipmi_si: Interface detection failed
[   11.945760] ipmi_si: Adding default-specified smic state machine
[   11.947123] ipmi_si: Trying default-specified smic state machine at i/o address 0xca9, slave address 0x0, irq 0
[   11.949507] ipmi_si: Interface detection failed
[   11.956153] ipmi_si: Adding default-specified bt state machine
[   11.957468] ipmi_si: Trying default-specified bt state machine at i/o address 0xe4, slave address 0x0, irq 0
[   11.959775] ipmi_si: Interface detection failed
[   11.962071] ipmi_si: Unable to find any System Interface(s)
[   11.964490] IPMI Watchdog: driver initialized
[   11.966314] Copyright (C) 2004 MontaVista Software - IPMI Powerdown via sys_reboot.
[   11.969691] Hangcheck: starting hangcheck timer 0.9.1 (tick is 180 seconds, margin is 60 seconds).
[   11.971966] Hangcheck: Using getrawmonotonic().
[   11.973265] [drm] Initialized drm 1.1.0 20060810
[   11.974666] [drm] radeon defaulting to kernel modesetting.
[   11.976093] [drm] radeon kernel modesetting enabled.
[   11.977378] [drm:i915_init] *ERROR* drm/i915 can't work without intel_agp module!
[   11.979597] i2c-core: driver [ch7006] using legacy suspend method
[   11.981011] i2c-core: driver [ch7006] using legacy resume method
[   11.982540] parport_pc 00:05: reported by Plug and Play ACPI
[   11.984176] parport0: PC-style at 0x378, irq 7 [PCSPP,TRISTATE]
[   12.082489] lp0: using parport0 (interrupt-driven).
[   12.105354] FDC 0 is a S82078B
[   12.134578] brd: module loaded
[   12.151990] loop: module loaded
[   12.154381] Compaq SMART2 Driver (v 2.6.0)
[   12.157690] HP CISS Driver (v 3.6.26)
[   12.164145] MM: desc_per_page = 128
[   12.174591] nbd: registered device at major 43
[   12.190706] virtio-pci 0000:00:04.0: irq 40 for MSI/MSI-X
[   12.192689] virtio-pci 0000:00:04.0: irq 41 for MSI/MSI-X
[   12.215087]  vda: unknown partition table
[   12.219398] virtio-pci 0000:00:05.0: irq 42 for MSI/MSI-X
[   12.221110] virtio-pci 0000:00:05.0: irq 43 for MSI/MSI-X
[   12.238190]  vdb: unknown partition table
[   12.242278] virtio-pci 0000:00:06.0: irq 44 for MSI/MSI-X
[   12.246155] virtio-pci 0000:00:06.0: irq 45 for MSI/MSI-X
[   12.266862]  vdc: unknown partition table
[   12.270928] virtio-pci 0000:00:07.0: irq 46 for MSI/MSI-X
[   12.274565] virtio-pci 0000:00:07.0: irq 47 for MSI/MSI-X
[   12.295636]  vdd: unknown partition table
[   12.299850] virtio-pci 0000:00:08.0: irq 48 for MSI/MSI-X
[   12.303707] virtio-pci 0000:00:08.0: irq 49 for MSI/MSI-X
[   12.324652]  vde: unknown partition table
[   12.328932] virtio-pci 0000:00:09.0: irq 50 for MSI/MSI-X
[   12.332811] virtio-pci 0000:00:09.0: irq 51 for MSI/MSI-X
[   12.353962]  vdf: unknown partition table
[   12.362753] drbd: initialized. Version: 8.3.13 (api:88/proto:86-96)
[   12.364245] drbd: built-in
[   12.364977] drbd: registered as block device major 147
[   12.366143] drbd: minor_table @ 0xffff880016410ef0
[   12.367433] rbd: loaded rbd (rados block device)
[   12.368657] ibmasm: IBM ASM Service Processor Driver version 1.0 loaded
[   12.370548] lkdtm: No crash points registered, enable through debugfs
[   12.372197] Phantom Linux Driver, version n0.9.8, init OK
[   12.373729] i2c-core: driver [apds9802als] using legacy suspend method
[   12.375146] i2c-core: driver [apds9802als] using legacy resume method
[   12.376653] i2c-core: driver [isl29003] using legacy suspend method
[   12.378021] i2c-core: driver [isl29003] using legacy resume method
[   12.379469] i2c-core: driver [tsl2550] using legacy suspend method
[   12.380867] i2c-core: driver [tsl2550] using legacy resume method
[   12.382287] Silicon Labs C2 port support v. 0.51.0 - (C) 2007 Rodolfo Giometti
[   12.384598] c2port c2port0: C2 port uc added
[   12.385610] c2port c2port0: uc flash has 30 blocks x 512 bytes (15360 bytes total)
[   12.388163] usbcore: registered new interface driver pn533
[   12.389421] Uniform Multi-Platform E-IDE driver
[   12.390691] piix 0000:00:01.1: IDE controller (0x8086:0x7010 rev 0x00)
[   12.392417] piix 0000:00:01.1: not 100% native mode: will probe irqs later
[   12.393914]     ide0: BM-DMA at 0xc000-0xc007
[   12.394986]     ide1: BM-DMA at 0xc008-0xc00f
[   12.396128] Probing IDE interface ide0...
[   12.964321] Probing IDE interface ide1...
[   13.700231] hdc: QEMU DVD-ROM, ATAPI CD/DVD-ROM drive
[   14.372713] hdc: host max PIO4 wanted PIO255(auto-tune) selected PIO0
[   14.377246] hdc: MWDMA2 mode selected
[   14.380209] ide0 at 0x1f0-0x1f7,0x3f6 on irq 14
[   14.381352] ide1 at 0x170-0x177,0x376 on irq 15
[   14.383354] ide_generic: please use "probe_mask=0x3f" module parameter for probing all legacy ISA IDE ports
[   14.385540] ide-gd driver 1.18
[   14.386374] ide-cd driver 5.00
[   14.387691] ide-cd: hdc: ATAPI 4X CD-ROM drive, 512kB Cache
[   14.388966] cdrom: Uniform CD-ROM driver Revision: 3.20
[   14.392887] Loading iSCSI transport class v2.0-870.
[   14.395023] rdac: device handler registered
[   14.396500] hp_sw: device handler registered
[   14.397524] emc: device handler registered
[   14.398497] alua: device handler registered
[   14.401496] fnic: Cisco FCoE HBA Driver, ver 1.5.0.2
[   14.403252] bnx2fc: Broadcom NetXtreme II FCoE Driver bnx2fc v1.0.11 (Apr 24, 2012)
[   14.406305] iscsi: registered transport (tcp)
[   14.407674] Loading Adaptec I2O RAID: Version 2.4 Build 5go
[   14.408956] Detecting Adaptec I2O RAID controllers...
[   14.410346] Adaptec aacraid driver 1.2-0[28900]-ms
[   14.411890] aic94xx: Adaptec aic94xx SAS/SATA driver version 1.0.3 loaded
[   14.413720] isci: Intel(R) C600 SAS Controller Driver - version 1.1.0
[   14.415393] scsi: <fdomain> Detection failed (no card)
[   14.416784] qla2xxx [0000:00:00.0]-0005: : QLogic Fibre Channel HBA Driver: 8.04.00.03-k.
[   14.418859] iscsi: registered transport (qla4xxx)
[   14.420178] QLogic iSCSI HBA Driver
[   14.421048] Brocade BFA FC/FCOE SCSI driver - version: 3.0.23.0
[   14.422726] DC390: clustering now enabled by default. If you get problems load
[   14.432547]        with "disable_clustering=1" and report to maintainers
[   14.434138] megaraid cmm: 2.20.2.7 (Release Date: Sun Jul 16 00:01:03 EST 2006)
[   14.436121] megaraid: 2.20.5.1 (Release Date: Thu Nov 16 15:32:35 EST 2006)
[   14.437702] megasas: 00.00.06.15-rc1 Mon. Mar. 19 17:00:00 PDT 2012
[   14.439164] mpt2sas version 13.100.00.00 loaded
[   14.440608] GDT-HA: Storage RAID Controller Driver. Version: 3.05
[   14.442158] 3ware Storage Controller device driver for Linux v1.26.02.003.
[   14.443818] 3ware 9000 Storage Controller device driver for Linux v2.26.02.014.
[   14.445584] LSI 3ware SAS/SATA-RAID Controller device driver for Linux v3.26.02.000.
[   14.447588] ppa: Version 2.07 (for Linux 2.4.x)
[   14.451111] imm: Version 2.05 (for Linux 2.4.0)
[   14.452887] ipr: IBM Power RAID SCSI Device Driver version: 2.5.3 (March 10, 2012)
[   14.454814] RocketRAID 3xxx/4xxx Controller driver v1.6 (090910)
[   14.456391] stex: Promise SuperTrak EX Driver version: 4.6.0000.4
[   14.458015] libcxgbi:libcxgbi_init_module: tag itt 0x1fff, 13 bits, age 0xf, 4 bits.
[   14.459923] libcxgbi:ddp_setup_host_page_size: system PAGE 4096, ddp idx 0.
[   14.461443] Chelsio T3 iSCSI Driver cxgb3i v2.0.0 (Jun. 2010)
[   14.462799] iscsi: registered transport (cxgb3i)
[   14.464077] Chelsio T4 iSCSI Driver cxgb4i v0.9.1 (Aug. 2010)
[   14.465440] iscsi: registered transport (cxgb4i)
[   14.466532] Broadcom NetXtreme II iSCSI Driver bnx2i v2.7.2.2 (Apr 25, 2012)
[   14.468266] iscsi: registered transport (bnx2i)
[   14.470274] iscsi: registered transport (be2iscsi)
[   14.471722] VMware PVSCSI driver - version 1.0.2.0-k
[   14.472970] hv_vmbus: registering driver hv_storvsc
[   14.474094] st: Version 20101219, fixed bufsize 32768, s/g segs 256
[   14.475661] osst :I: Tape driver with OnStream support version 0.99.4
[   14.475661] osst :I: $Id: osst.c,v 1.73 2005/01/01 21:13:34 wriede Exp $
[   14.478733] SCSI Media Changer driver v0.25 
[   14.480119] osd: LOADED open-osd 0.2.1
[   14.493204] scsi_debug: host protection
[   14.494147] scsi0 : scsi_debug, version 1.82 [20100324], dev_size_mb=8, opts=0x0
[   14.500632] scsi 0:0:0:0: Direct-Access     Linux    scsi_debug       0004 PQ: 0 ANSI: 5
[   14.503686] Rounding down aligned max_sectors from 4294967295 to 8388600
[   14.504086] sd 0:0:0:0: [sda] 16384 512-byte logical blocks: (8.38 MB/8.00 MiB)
[   14.504732] sd 0:0:0:0: Attached scsi generic sg0 type 0
[   14.505226] scsi_scan_0 (135) used greatest stack depth: 4280 bytes left
[   14.508073] sd 0:0:0:0: [sda] Write Protect is off
[   14.508075] sd 0:0:0:0: [sda] Mode Sense: 73 00 10 08
[   14.516103] sd 0:0:0:0: [sda] Write cache: enabled, read cache: enabled, supports DPO and FUA
[   14.519032] SSFDC read-only Flash Translation layer
[   14.520278] mtdoops: mtd device (mtddev=name/number) must be supplied
[   14.521783] SBC-GXx flash: IO:0x258-0x259 MEM:0xdc000-0xdffff
[   14.523221] Could not find PAR responsible for SC520CDP Flash Bank #0
[   14.524654] Trying default address 0x8400000
[   14.525659] Could not find PAR responsible for SC520CDP Flash Bank #1
[   14.527059] Trying default address 0x8c00000
[   14.528113] Could not find PAR responsible for SC520CDP DIL Flash
[   14.529447] Trying default address 0x9400000
[   14.530524] SC520 CDP flash device: 0x800000 at 0x8400000
[   14.531812] Failed to ioremap_nocache
[   14.532727] NetSc520 flash device: 0x100000 at 0x200000
[   14.533915] Failed to ioremap_nocache
[   14.534811] Failed to ioremap_nocache
[   14.535871] Generic platform RAM MTD, (c) 2004 Simtec Electronics
[   14.544082]  sda: unknown partition table
[   14.560076] sd 0:0:0:0: [sda] Attached SCSI disk
[   14.565161] No recognised DiskOnChip devices found
[   14.566281] slram: not enough parameters.
[   14.567344] Ramix PMC551 PCI Mezzanine Ram Driver. (C) 1999,2000 Nortel Networks.
[   14.569089] pmc551: not detected
[   14.573208] ftl_cs: FTL header not found.
[   14.608215] No valid DiskOnChip devices found
[   14.609294] [nandsim] warning: read_byte: unexpected data output cycle, state is STATE_READY return 0x0
[   14.611450] [nandsim] warning: read_byte: unexpected data output cycle, state is STATE_READY return 0x0
[   14.613558] [nandsim] warning: read_byte: unexpected data output cycle, state is STATE_READY return 0x0
[   14.615701] [nandsim] warning: read_byte: unexpected data output cycle, state is STATE_READY return 0x0
[   14.617808] [nandsim] warning: read_byte: unexpected data output cycle, state is STATE_READY return 0x0
[   14.619945] [nandsim] warning: read_byte: unexpected data output cycle, state is STATE_READY return 0x0
[   14.622043] NAND device: Manufacturer ID: 0x98, Chip ID: 0x39 (Toshiba NAND 128MiB 1,8V 8-bit), page size: 512, OOB size: 16
[   14.624530] flash size: 128 MiB
[   14.625334] page size: 512 bytes
[   14.626155] OOB area size: 16 bytes
[   14.627011] sector size: 16 KiB
[   14.627837] pages number: 262144
[   14.628705] pages per sector: 32
[   14.629526] bus width: 8
[   14.630228] bits in sector size: 14
[   14.631099] bits in page size: 9
[   14.631955] bits in OOB size: 4
[   14.632771] flash size with OOB: 135168 KiB
[   14.633837] page address bytes: 4
[   14.634663] sector address bytes: 3
[   14.635652] options: 0x42
[   14.639557] Scanning device for bad blocks
[   14.686177] Creating 1 MTD partitions on "NAND 128MiB 1,8V 8-bit":
[   14.687605] 0x000000000000-0x000008000000 : "NAND simulator partition 0"
[   14.690582] ftl_cs: FTL header not found.
[   14.693060] usbcore: registered new interface driver alauda
[   14.736030] onenand_wait: timeout! ctrl=0x0000 intr=0x0000
[   14.737290] OneNAND Manufacturer: Samsung (0xec)
[   14.738359] OneNAND 16MB 1.8V 16-bit (0x04)
[   14.739403] OneNAND version = 0x001e
[   14.740345] Lock scheme is Continuous Lock
[   14.741361] Scanning device for bad blocks
[   14.744442] Creating 1 MTD partitions on "OneNAND simulator":
[   14.745742] 0x000000000000-0x000001000000 : "OneNAND simulator partition"
[   14.748268] ftl_cs: FTL header not found.
[   14.864728] parport_pc 00:05: master is unqueued, this is deprecated
[   14.873417] parport0: AVR Butterfly
[   14.874373] parport0: cannot grant exclusive access for device spi-lm70llp
[   14.875948] spi-lm70llp: spi_lm70llp probe fail, status -12
[   14.877398] bonding: Ethernet Channel Bonding Driver: v3.7.1 (April 27, 2011)
[   14.881712] eql: Equalizer2002: Simon Janes (simon@ncm.com) and David S. Miller (davem@redhat.com)
[   14.886541] D-Link DE-620 pocket adapter io 0x378, which is busy.
[   14.890465] tun: Universal TUN/TAP device driver, 1.6
[   14.891697] tun: (C) 1999-2004 Max Krasnyansky <maxk@qualcomm.com>
[   14.893528] arcnet loaded.
[   14.894264] arcnet: RFC1201 "standard" (`a') encapsulation support loaded.
[   14.895811] arcnet: RFC1051 "simple standard" (`s') encapsulation support loaded.
[   14.897562] arcnet: raw mode (`r') encapsulation support loaded.
[   14.898898] arcnet: cap mode (`c') encapsulation support loaded.
[   14.900324] arcnet: COM90xx chipset support
[   15.199816] S3: No ARCnet cards found.
[   15.200802] arcnet: COM90xx IO-mapped mode support (by David Woodhouse et el.)
[   15.202468] E-mail me if you actually test this driver, please!
[   15.203928]  arc%d: No autoprobe for IO mapped cards; you must specify the base address!
[   15.205802] arcnet: RIM I (entirely mem-mapped) support
[   15.206982] E-mail me if you actually test the RIM I driver, please!
[   15.208451] Given: node 00h, shmem 0h, irq 0
[   15.209461] No autoprobe for RIM I; you must specify the shmem and irq!
[   15.210914] arcnet: COM20020 PCI support
[   15.212115] ipddp.c:v0.01 8/28/97 Bradford W. Johnson <johns393@maroon.tc.umn.edu>
[   15.214218] ipddp0: Appletalk-IP Encap. mode by Bradford W. Johnson <johns393@maroon.tc.umn.edu>
[   15.216282] vcan: Virtual CAN interface driver
[   15.217327] slcan: serial line CAN interface driver
[   15.218453] slcan: 10 dynamic interface channels.
[   15.219671] CAN device driver interface
[   15.220694] usbcore: registered new interface driver ems_usb
[   15.222033] usbcore: registered new interface driver esd_usb2
[   15.223437] sja1000 CAN netdevice driver
[   15.225458] pcnet32: pcnet32.c:v1.35 21.Apr.2008 tsbogend@alpha.franken.de
[   15.227070] Atheros(R) L2 Ethernet Driver - version 2.2.3
[   15.228336] Copyright (c) 2007 Atheros Corporation.
[   15.229850] cnic: Broadcom NetXtreme II CNIC Driver cnic v2.5.12 (June 29, 2012)
[   15.232003] bnx2x: Broadcom NetXtreme II 5771x/578xx 10/20-Gigabit Ethernet Driver bnx2x 1.72.51-0 (2012/06/18)
[   15.234952] Brocade 10G Ethernet driver - version: 3.0.23.0
[   15.237163] enic: Cisco VIC Ethernet NIC Driver, ver 2.1.1.39
[   15.238609] dmfe: Davicom DM9xxx net driver, version 1.36.4 (2002-01-17)
[   15.240256] v1.01-e (2.4 port) Sep-11-2006  Donald Becker <becker@scyld.com>
[   15.240256]   http://www.scyld.com/network/drivers.html
[   15.243093] uli526x: ULi M5261/M5263 net driver, version 0.9.3 (2005-7-29)
[   15.244727] DE600: port 0x378 busy
[   15.245879] vxge: Copyright(c) 2002-2010 Exar Corp.
[   15.246997] vxge: Driver version: 2.5.3.22640-k
[   15.248280] e100: Intel(R) PRO/100 Network Driver, 3.5.24-k2-NAPI
[   15.249614] e100: Copyright(c) 1999-2006 Intel Corporation
[   15.250942] e1000: Intel(R) PRO/1000 Network Driver - version 7.3.21-k8-NAPI
[   15.252515] e1000: Copyright (c) 1999-2006 Intel Corporation.
[   15.253917] e1000 0000:00:03.0: setting latency timer to 64
[   15.580420] e1000 0000:00:03.0: eth0: (PCI:33MHz:32-bit) 52:54:00:12:34:56
[   15.581911] e1000 0000:00:03.0: eth0: Intel(R) PRO/1000 Network Connection
[   15.583492] e1000e: Intel(R) PRO/1000 Network Driver - 2.0.0-k
[   15.584806] e1000e: Copyright(c) 1999 - 2012 Intel Corporation.
[   15.586175] igb: Intel(R) Gigabit Ethernet Network Driver - version 4.0.1-k
[   15.595931] igb: Copyright (c) 2007-2012 Intel Corporation.
[   15.597300] igbvf: Intel(R) Gigabit Virtual Function Network Driver - version 2.0.1-k
[   15.599119] igbvf: Copyright (c) 2009 - 2012 Intel Corporation.
[   15.600627] ixgbe: Intel(R) 10 Gigabit PCI Express Network Driver - version 3.9.15-k
[   15.602404] ixgbe: Copyright (c) 1999-2012 Intel Corporation.
[   15.603896] ixgbevf: Intel(R) 10 Gigabit PCI Express Virtual Function Network Driver - version 2.6.0-k
[   15.605976] ixgbevf: Copyright (c) 2009 - 2012 Intel Corporation.
[   15.607425] ixgb: Intel(R) PRO/10GbE Network Driver - version 1.0.135-k2-NAPI
[   15.609023] ixgb: Copyright (c) 1999-2008 Intel Corporation.
[   15.610436] jme: JMicron JMC2XX ethernet driver version 1.0.8
[   15.611991] sky2: driver version 1.30
[   15.613753] myri10ge: Version 1.5.3-1.534
[   15.614943] ns83820.c: National Semiconductor DP83820 10/100/1000 driver.
[   15.616926] QLogic 1/10 GbE Converged/Intelligent Ethernet Driver v5.0.29
[   15.618995] QLogic/NetXen Network Driver v4.0.80
[   15.620355] atp.c:v1.09=ac 2002/10/01 Donald Becker <becker@scyld.com>
[   15.622262] Solarflare NET driver v3.1
[   15.624860] tehuti: Tehuti Networks(R) Network Driver, 7.29.3
[   15.626137] tehuti: Options: hw_csum 
[   15.627098] tlan: ThunderLAN driver v1.17
[   15.628205] tlan: 0 devices installed, PCI: 0  EISA: 0
[   15.629698] mkiss: AX.25 Multikiss, Hans Albas PE1AYX
[   15.630878] AX.25: 6pack driver, Revision: 0.3.0
[   15.632090] YAM driver version 0.8 by F1OAT/F6FBB
[   15.634661] AX.25: bpqether driver version 004
[   15.635849] baycom_ser_fdx: (C) 1996-2000 Thomas Sailer, HB9JNX/AE4WA
[   15.635849] baycom_ser_fdx: version 0.10
[   15.639562] hdlcdrv: (C) 1996-2000 Thomas Sailer HB9JNX/AE4WA
[   15.640906] hdlcdrv: version 0.8
[   15.641721] baycom_ser_hdx: (C) 1996-2000 Thomas Sailer, HB9JNX/AE4WA
[   15.641721] baycom_ser_hdx: version 0.10
[   15.645542] baycom_par: (C) 1996-2000 Thomas Sailer, HB9JNX/AE4WA
[   15.645542] baycom_par: version 0.9
[   15.649324] usbcore: registered new interface driver irda-usb
[   15.650672] usbcore: registered new interface driver stir4200
[   15.653195] usbcore: registered new interface driver mcs7780
[   15.655241] usbcore: registered new interface driver kingsun-sir
[   15.656643] usbcore: registered new interface driver ksdazzle-sir
[   15.658032] usbcore: registered new interface driver ks959-sir
[   15.659775] NET3 PLIP version 2.4-parport gniibe@mri.co.jp
[   15.661065] plip0: Parallel port at 0x378, using IRQ 7.
[   15.662250] PPP generic driver version 2.4.2
[   15.663762] PPP BSD Compression module registered
[   15.664887] PPP Deflate Compression module registered
[   15.668777] PPP MPPE Compression module registered
[   15.669906] NET: Registered protocol family 24
[   15.671004] PPTP driver version 0.8.5
[   15.672775] SLIP: version 0.8.4-NET3.019-NEWTTY (dynamic channels, max=256) (6 bit encapsulation enabled).
[   15.674898] CSLIP: code copyright 1989 Regents of the University of California.
[   15.676644] SLIP linefill/keepalive option.
[   15.677720] hdlc: HDLC support module revision 1.22
[   15.679000] DLCI driver v0.35, 4 Jan 1997, mike.mclagan@linux.org.
[   15.680433] cycx_drv: Cyclom 2X Support Module v0.6 (c) 1998-2003 Arnaldo Carvalho de Melo <acme@conectiva.com.br>
[   15.682672] cyclomx: CYCLOM 2X(tm) Sync Card Driver v0.11 (c) 1998-2003 Arnaldo Carvalho de Melo <acme@conectiva.com.br>
[   15.685260] ipw2200: Intel(R) PRO/Wireless 2200/2915 Network Driver, 1.2.2kmprq
[   15.686954] ipw2200: Copyright(c) 2003-2006 Intel Corporation
[   15.688369] libipw: 802.11 data/management/control stack, git-1.1.13
[   15.689752] libipw: Copyright (C) 2004-2005 Intel Corporation <jketreno@linux.intel.com>
[   15.691741] orinoco 0.15 (David Gibson <hermes@gibson.dropbear.id.au>, Pavel Roskin <proski@gnu.org>, et al)
[   15.693978] orinoco_plx 0.15 (Pavel Roskin <proski@gnu.org>, David Gibson <hermes@gibson.dropbear.id.au>, Daniel Barlow <dan@telent.net>)
[   15.696754] orinoco_tmd 0.15 (Joerg Dorchain <joerg@dorchain.net>)
[   15.698182] orinoco_nortel 0.15 (Tobias Hoffmann & Christoph Jungegger <disdos@traum404.de>)
[   15.700408] usbcore: registered new interface driver orinoco_usb
[   15.701758] airo(): Probing for PCI adapters
[   15.702844] airo(): Finished probing for PCI adapters
[   15.704330] Atmel at76x USB Wireless LAN Driver 0.17 loading
[   15.705646] usbcore: registered new interface driver at76c50x-usb
[   15.707333] Broadcom 43xx driver loaded [ Features: PMNLS ]
[   15.708690] Broadcom 43xx-legacy driver loaded [ Features: PLID ]
[   15.710248] usbcore: registered new interface driver zd1211rw
[   15.711830] usbcore: registered new interface driver rtl8187
[   15.713272] usbcore: registered new interface driver rtl8192cu
[   15.715008] usbcore: registered new interface driver rndis_wlan
[   15.716495] usbcore: registered new interface driver zd1201
[   15.717838] usbcore: registered new interface driver usb8xxx
[   15.719148] libertas_sdio: Libertas SDIO driver
[   15.720316] libertas_sdio: Copyright Pierre Ossman
[   15.721467] libertas_spi: Libertas SPI driver
[   15.722736] usbcore: registered new interface driver lbtf_usb
[   15.724327] Intel(R) Wireless WiFi driver for Linux, in-tree:
[   15.725601] Copyright(c) 2003-2012 Intel Corporation
[   15.726825] iwldvm: Intel(R) Wireless WiFi Link AGN driver for Linux, in-tree:
[   15.728606] iwldvm: Copyright(c) 2003-2012 Intel Corporation
[   15.729908] iwl4965: Intel(R) Wireless WiFi 4965 driver for Linux, in-tree:
[   15.731529] iwl4965: Copyright(c) 2003-2011 Intel Corporation
[   15.732911] iwl3945: Intel(R) PRO/Wireless 3945ABG/BG Network Connection driver for Linux, in-tree:s
[   15.734939] iwl3945: Copyright(c) 2003-2011 Intel Corporation
[   15.736681] usbcore: registered new interface driver rt2500usb
[   15.738033] usbcore: registered new interface driver rt73usb
[   15.739421] usbcore: registered new interface driver rt2800usb
[   15.740845] usbcore: registered new interface driver p54usb
[   15.742402] usbcore: registered new interface driver ath9k_htc
[   15.743925] usbcore: registered new interface driver carl9170
[   15.745254] mac80211_hwsim: Initializing radio 0
[   15.747042] ieee80211 phy0: Selected rate control algorithm 'minstrel_ht'
[   15.749345] ieee80211 phy0: hwaddr 020000000000 registered
[   15.750692] mac80211_hwsim: Initializing radio 1
[   15.752509] ieee80211 phy1: Selected rate control algorithm 'minstrel_ht'
[   15.754470] ieee80211 phy1: hwaddr 020000000100 registered
[   15.756295] mac80211_hwsim: initializing netlink
[   15.757641] usbcore: registered new interface driver i2400m_usb
[   15.758995] VMware vmxnet3 virtual NIC driver - version 1.1.29.0-k-NAPI
[   15.760694] usbcore: registered new interface driver catc
[   15.761969] usbcore: registered new interface driver kaweth
[   15.763340] pegasus: v0.6.14 (2006/09/27), Pegasus/Pegasus II USB Ethernet driver
[   15.765152] usbcore: registered new interface driver pegasus
[   15.766469] usbcore: registered new interface driver rtl8150
[   15.767868] hso: /c/kernel-tests/net/drivers/net/usb/hso.c: Option Wireless
[   15.769460] usbcore: registered new interface driver hso
[   15.770740] usbcore: registered new interface driver asix
[   15.772139] usbcore: registered new interface driver cdc_ether
[   15.773490] usbcore: registered new interface driver cdc_eem
[   15.774873] usbcore: registered new interface driver dm9601
[   15.776295] usbcore: registered new interface driver smsc75xx
[   15.777633] usbcore: registered new interface driver smsc95xx
[   15.778968] usbcore: registered new interface driver gl620a
[   15.780378] usbcore: registered new interface driver net1080
[   15.781690] usbcore: registered new interface driver plusb
[   15.782991] usbcore: registered new interface driver rndis_host
[   15.784484] usbcore: registered new interface driver cdc_subset
[   15.785840] usbcore: registered new interface driver zaurus
[   15.787157] usbcore: registered new interface driver MOSCHIP usb-ethernet driver
[   15.788992] usbcore: registered new interface driver int51x1
[   15.790314] usbcore: registered new interface driver cdc_phonet
[   15.791784] usbcore: registered new interface driver kalmia
[   15.793125] usbcore: registered new interface driver ipheth
[   15.794405] usbcore: registered new interface driver sierra_net
[   15.795949] usbcore: registered new interface driver cx82310_eth
[   15.797354] usbcore: registered new interface driver cdc_ncm
[   15.798662] usbcore: registered new interface driver lg-vl600
[   15.800101] hv_vmbus: registering driver hv_netvsc
[   15.801341] Madge ATM Ambassador driver version 1.2.4
[   15.802570] Madge ATM Horizon [Ultra] driver version 1.2.1
[   15.804179] fore200e: FORE Systems 200E-series ATM driver - version 0.3e
[   15.805753] idt77252_init: at ffffffff846500c0
[   15.806885] Solos PCI Driver Version 0.07
[   15.808060] adummy: version 1.0
[   15.809311] I2O subsystem v1.325
[   15.810165] i2o: max drivers = 8
[   15.811320] I2O Configuration OSM v1.323
[   15.812644] I2O Bus Adapter OSM v1.317
[   15.813595] I2O Block Device OSM v1.325
[   15.815362] I2O SCSI Peripheral OSM v1.316
[   15.816447] I2O ProcFS OSM v1.316
[   15.817353] Fusion MPT base driver 3.04.20
[   15.818331] Copyright (c) 1999-2008 LSI Corporation
[   15.819606] Fusion MPT SPI Host driver 3.04.20
[   15.820768] Fusion MPT FC Host driver 3.04.20
[   15.821885] Fusion MPT SAS Host driver 3.04.20
[   15.823018] Fusion MPT misc device (ioctl) driver 3.04.20
[   15.824641] mptctl: Registered with Fusion MPT base driver
[   15.825879] mptctl: /dev/mptctl @ (major,minor=10,220)
[   15.827043] Fusion MPT LAN driver 3.04.20
[   15.828918] Generic UIO driver for PCI 2.3 devices version: 0.01.0
[   15.832740] aoe: AoE v47 initialised.
[   15.834838] usbcore: registered new interface driver hwa-rc
[   15.836323] usbcore: registered new interface driver i1480-dfu-usb
[   15.838257] ehci_hcd: USB 2.0 'Enhanced' Host Controller (EHCI) Driver
[   15.839932] ohci_hcd: USB 1.1 'Open' Host Controller (OHCI) Driver
[   15.841433] uhci_hcd: USB Universal Host Controller Interface driver
[   15.843120] driver u132_hcd
[   15.844284] usbcore: registered new interface driver hwa-hc
[   15.845740] usbcore: registered new interface driver wusb-cbaf
[   15.847110] usbcore: registered new interface driver cdc_acm
[   15.856640] cdc_acm: USB Abstract Control Model driver for USB modems and ISDN adapters
[   15.858514] usbcore: registered new interface driver usblp
[   15.859992] usbcore: registered new interface driver cdc_wdm
[   15.861345] usbcore: registered new interface driver usbtmc
[   15.862654] usbcore: registered new interface driver uas
[   15.863987] Initializing USB Mass Storage driver...
[   15.865172] usbcore: registered new interface driver usb-storage
[   15.866497] USB Mass Storage support registered.
[   15.867784] usbcore: registered new interface driver ums-alauda
[   15.869169] usbcore: registered new interface driver ums-cypress
[   15.870571] usbcore: registered new interface driver ums-datafab
[   15.872148] usbcore: registered new interface driver ums_eneub6250
[   15.873548] usbcore: registered new interface driver ums-freecom
[   15.874924] usbcore: registered new interface driver ums-isd200
[   15.876397] usbcore: registered new interface driver ums-jumpshot
[   15.877807] usbcore: registered new interface driver ums-karma
[   15.879157] usbcore: registered new interface driver ums-onetouch
[   15.880646] usbcore: registered new interface driver ums-realtek
[   15.882018] usbcore: registered new interface driver ums-sddr09
[   15.883546] usbcore: registered new interface driver ums-sddr55
[   15.884948] usbcore: registered new interface driver ums-usbat
[   15.886313] usbcore: registered new interface driver mdc800
[   15.887682] mdc800: v0.7.5 (30/10/2000):USB Driver for Mustek MDC800 Digital Camera
[   15.889563] usbcore: registered new interface driver microtekX6
[   15.891040] usbcore: registered new interface driver usbserial
[   15.892487] usbcore: registered new interface driver usbserial_generic
[   15.894114] USB Serial support registered for generic
[   15.895339] usbserial: USB Serial Driver core
[   15.896456] usbcore: registered new interface driver aircable
[   15.897759] USB Serial support registered for aircable
[   15.898978] usbcore: registered new interface driver ark3116
[   15.900384] USB Serial support registered for ark3116
[   15.901592] usbcore: registered new interface driver belkin_sa
[   15.902926] USB Serial support registered for Belkin / Peracom / GoHubs USB Serial Adapter
[   15.904929] usbcore: registered new interface driver ch341
[   15.906202] USB Serial support registered for ch341-uart
[   15.907572] usbcore: registered new interface driver cp210x
[   15.908883] USB Serial support registered for cp210x
[   15.910077] usbcore: registered new interface driver cyberjack
[   15.911526] USB Serial support registered for Reiner SCT Cyberjack USB card reader
[   15.913341] usbcore: registered new interface driver cypress_m8
[   15.914684] USB Serial support registered for DeLorme Earthmate USB
[   15.916246] USB Serial support registered for HID->COM RS232 Adapter
[   15.917684] USB Serial support registered for Nokia CA-42 V2 Adapter
[   15.919138] usbcore: registered new interface driver usb_debug
[   15.920641] USB Serial support registered for debug
[   15.921823] usbcore: registered new interface driver digi_acceleport
[   15.923382] USB Serial support registered for Digi 2 port USB adapter
[   15.924885] USB Serial support registered for Digi 4 port USB adapter
[   15.926326] usbcore: registered new interface driver io_edgeport
[   15.927817] USB Serial support registered for Edgeport 2 port adapter
[   15.929287] USB Serial support registered for Edgeport 4 port adapter
[   15.930744] USB Serial support registered for Edgeport 8 port adapter
[   15.932336] USB Serial support registered for EPiC device
[   15.933607] usbcore: registered new interface driver io_ti
[   15.934891] USB Serial support registered for Edgeport TI 1 port adapter
[   15.936465] USB Serial support registered for Edgeport TI 2 port adapter
[   15.937965] usbcore: registered new interface driver empeg
[   15.939347] USB Serial support registered for empeg
[   15.940589] usbcore: registered new interface driver ftdi_sio
[   15.941916] USB Serial support registered for FTDI USB Serial Device
[   15.943370] ftdi_sio: v1.6.0:USB FTDI Serial Converters Driver
[   15.944738] usbcore: registered new interface driver funsoft
[   15.946043] USB Serial support registered for funsoft
[   15.947317] usbcore: registered new interface driver garmin_gps
[   15.948704] USB Serial support registered for Garmin GPS usb/tty
[   15.950099] usbcore: registered new interface driver hp4x
[   15.951542] USB Serial support registered for hp4X
[   15.952734] usbcore: registered new interface driver ipaq
[   15.954103] USB Serial support registered for PocketPC PDA
[   15.955553] usbcore: registered new interface driver ipw
[   15.956826] USB Serial support registered for IPWireless converter
[   15.958253] usbcore: registered new interface driver ir_usb
[   15.959722] USB Serial support registered for IR Dongle
[   15.960953] ir_usb: v0.5:USB IR Dongle driver
[   15.962039] usbcore: registered new interface driver iuu_phoenix
[   15.963577] USB Serial support registered for iuu_phoenix
[   15.964883] usbcore: registered new interface driver keyspan
[   15.966182] USB Serial support registered for Keyspan - (without firmware)
[   15.967831] USB Serial support registered for Keyspan 1 port adapter
[   15.969281] USB Serial support registered for Keyspan 2 port adapter
[   15.970714] USB Serial support registered for Keyspan 4 port adapter
[   15.972290] usbcore: registered new interface driver keyspan_pda
[   15.973648] USB Serial support registered for Keyspan PDA
[   15.974924] USB Serial support registered for Keyspan PDA - (prerenumeration)
[   15.976579] USB Serial support registered for Xircom / Entregra PGS - (prerenumeration)
[   15.978460] usbcore: registered new interface driver kl5kusb105
[   15.979953] USB Serial support registered for KL5KUSB105D / PalmConnect
[   15.981479] usbcore: registered new interface driver kobil_sct
[   15.982820] USB Serial support registered for KOBIL USB smart card terminal
[   15.984540] usbcore: registered new interface driver mct_u232
[   15.985870] USB Serial support registered for MCT U232
[   15.987132] usbcore: registered new interface driver mos7720
[   15.988516] USB Serial support registered for Moschip 2 port adapter
[   15.989968] usbcore: registered new interface driver mos7840
[   15.991393] USB Serial support registered for Moschip 7840/7820 USB Serial Driver
[   15.993254] usbcore: registered new interface driver moto_modem
[   15.994599] USB Serial support registered for moto-modem
[   15.995987] usbcore: registered new interface driver navman
[   15.997300] USB Serial support registered for navman
[   15.998505] usbcore: registered new interface driver omninet
[   16.000025] USB Serial support registered for ZyXEL - omni.net lcd plus usb
[   16.001577] usbcore: registered new interface driver opticon
[   16.002894] USB Serial support registered for opticon
[   16.004228] usbcore: registered new interface driver option
[   16.005510] USB Serial support registered for GSM modem (1-port)
[   16.006897] usbcore: registered new interface driver oti6858
[   16.008303] USB Serial support registered for oti6858
[   16.009512] usbcore: registered new interface driver pl2303
[   16.010819] USB Serial support registered for pl2303
[   16.012186] usbcore: registered new interface driver qcaux
[   16.013470] USB Serial support registered for qcaux
[   16.014705] usbcore: registered new interface driver qcserial
[   16.016223] USB Serial support registered for Qualcomm USB modem
[   16.017544] safe_serial: v0.1:USB Safe Encapsulated Serial
[   16.018853] usbcore: registered new interface driver safe_serial
[   16.020429] USB Serial support registered for safe_serial
[   16.021699] usbcore: registered new interface driver siemens_mpi
[   16.023075] USB Serial support registered for siemens_mpi
[   16.024445] usbcore: registered new interface driver sierra
[   16.025745] USB Serial support registered for Sierra USB modem
[   16.027110] usbcore: registered new interface driver spcp8x5
[   16.028514] USB Serial support registered for SPCP8x5
[   16.029726] usbcore: registered new interface driver ssu100
[   16.031052] USB Serial support registered for Quatech SSU-100 USB to Serial Driver
[   16.032918] usbcore: registered new interface driver symbolserial
[   16.034293] USB Serial support registered for symbol
[   16.035618] usbcore: registered new interface driver ti_usb_3410_5052
[   16.037088] USB Serial support registered for TI USB 3410 1 port adapter
[   16.038595] USB Serial support registered for TI USB 5052 2 port adapter
[   16.040249] ti_usb_3410_5052: v0.10:TI USB 3410/5052 Serial Driver
[   16.041658] usbcore: registered new interface driver visor
[   16.042949] USB Serial support registered for Handspring Visor / Palm OS
[   16.044532] USB Serial support registered for Sony Clie 5.0
[   16.045827] USB Serial support registered for Sony Clie 3.5
[   16.047144] usbcore: registered new interface driver whiteheat
[   16.048567] USB Serial support registered for Connect Tech - WhiteHEAT - (prerenumeration)
[   16.050493] USB Serial support registered for Connect Tech - WhiteHEAT
[   16.052107] usbcore: registered new interface driver vivopay_serial
[   16.053519] USB Serial support registered for vivopay-serial
[   16.054874] usbcore: registered new interface driver zio
[   16.056218] USB Serial support registered for zio
[   16.057367] usbcore: registered new interface driver adutux
[   16.058852] usbcore: registered new interface driver appledisplay
[   16.060387] usbcore: registered new interface driver cypress_cy7c63
[   16.061829] usbcore: registered new interface driver cytherm
[   16.063154] usbcore: registered new interface driver emi26 - firmware loader
[   16.064810] usbcore: registered new interface driver emi62 - firmware loader
[   16.066314] driver ftdi-elan
[   16.067668] usbcore: registered new interface driver ftdi-elan
[   16.069037] usbcore: registered new interface driver idmouse
[   16.070372] usbcore: registered new interface driver iowarrior
[   16.071841] usbcore: registered new interface driver isight_firmware
[   16.073306] usbcore: registered new interface driver usblcd
[   16.074703] usbcore: registered new interface driver ldusb
[   16.076131] usbcore: registered new interface driver usbled
[   16.077444] usbcore: registered new interface driver legousbtower
[   16.078852] usbcore: registered new interface driver rio500
[   16.080329] usbcore: registered new interface driver usbtest
[   16.081639] usbcore: registered new interface driver trancevibrator
[   16.083076] usbcore: registered new interface driver uss720
[   16.084417] uss720: v0.6:USB Parport Cable driver for Cables using the Lucent Technologies USS720 Chip
[   16.086456] uss720: NOTE: this is a special purpose driver to allow nonstandard
[   16.088290] uss720: protocols (eg. bitbang) over USS720 usb to parallel cables
[   16.089978] uss720: If you just want to connect to a printer, use usblp instead
[   16.091890] usbcore: registered new interface driver usbsevseg
[   16.093253] usbcore: registered new interface driver yurex
[   16.094574] usbcore: registered new interface driver sisusb
[   16.104314] usbcore: registered new interface driver cxacru
[   16.105613] usbcore: registered new interface driver speedtch
[   16.106965] usbcore: registered new interface driver ueagle-atm
[   16.108373] xusbatm: malformed module parameters
[   16.109542] i8042: PNP: PS/2 Controller [PNP0303:KBD,PNP0f13:MOU] at 0x60,0x64 irq 1,12
[   16.112554] serio: i8042 KBD port at 0x60,0x64 irq 1
[   16.113732] serio: i8042 AUX port at 0x60,0x64 irq 12
[   16.115232] parport0: cannot grant exclusive access for device parkbd
[   16.185601] mousedev: PS/2 mouse device common for all mice
[   16.188225] input: AT Translated Set 2 keyboard as /devices/platform/i8042/serio0/input/input1
[   16.191082] usbcore: registered new interface driver appletouch
[   16.192566] usbcore: registered new interface driver bcm5974
[   16.197133] usbcore: registered new interface driver iforce
[   16.200541] usbcore: registered new interface driver xpad
[   16.201830] parport0: cannot grant exclusive access for device walkera0701
[   16.203431] usbcore: registered new interface driver usb_acecad
[   16.204875] usbcore: registered new interface driver aiptek
[   16.206174] usbcore: registered new interface driver gtco
[   16.207586] usbcore: registered new interface driver hanwang
[   16.208939] usbcore: registered new interface driver kbtab
[   16.210247] usbcore: registered new interface driver wacom
[   16.212185] mk712: device not present
[   16.213140] usbcore: registered new interface driver usbtouchscreen
[   16.214936] apanel: Fujitsu BIOS signature 'FJKEYINF' not found...
[   16.216469] usbcore: registered new interface driver ati_remote2
[   16.217876] cm109: Keymap for Komunikate KIP1000 phone loaded
[   16.219324] usbcore: registered new interface driver cm109
[   16.220602] cm109: CM109 phone driver: 20080805 (C) Alfred E. Heggestad
[   16.222131] usbcore: registered new interface driver keyspan_remote
[   16.223873] input: PC Speaker as /devices/platform/pcspkr/input/input2
[   16.225804] usbcore: registered new interface driver powermate
[   16.227485] usbcore: registered new interface driver yealink
[   16.229729] rtc_cmos 00:01: rtc core: registered rtc_cmos as rtc0
[   16.231359] rtc0: alarms up to one day, 114 bytes nvram, hpet irqs
[   16.234489] rtc-test rtc-test.0: rtc core: registered test as rtc1
[   16.236478] rtc-test rtc-test.1: rtc core: registered test as rtc2
[   16.237952] i2c /dev entries driver
[   16.239723] piix4_smbus 0000:00:01.3: SMBus Host Controller at 0xb100, revision 0
[   16.352961] usbcore: registered new interface driver i2c-diolan-u2c
[   16.357124] i2c-parport: adapter type unspecified
[   16.360124] i2c-parport-light: adapter type unspecified
[   16.361402] usbcore: registered new interface driver i2c-tiny-usb
[   16.362876] lirc_dev: IR Remote Control driver registered, major 222 
[   16.364394] IR NEC protocol handler initialized
[   16.365453] IR RC5(x) protocol handler initialized
[   16.366602] IR RC6 protocol handler initialized
[   16.367826] IR JVC protocol handler initialized
[   16.368934] IR Sony protocol handler initialized
[   16.370018] IR RC5 (streamzap) protocol handler initialized
[   16.371383] IR SANYO protocol handler initialized
[   16.372514] IR MCE Keyboard/mouse protocol handler initialized
[   16.373942] IR LIRC bridge handler initialized
[   16.375072] usbcore: registered new interface driver imon
[   16.376432] usbcore: registered new interface driver mceusb
[   16.377850] usbcore: registered new interface driver redrat3
[   16.379180] usbcore: registered new interface driver streamzap
[   16.380576] Registered IR keymap rc-empty
[   16.381824] input: rc-core loopback device as /devices/virtual/rc/rc0/input3
[   16.383880] rc0: rc-core loopback device as /devices/virtual/rc/rc0
[   16.385882] input: MCE IR Keyboard/Mouse (rc-loopback) as /devices/virtual/input/input4
[   16.389531] rc rc0: lirc_dev: driver ir-lirc-codec (rc-loopback) registered at minor = 0
[   16.392740] bttv: driver version 0.9.19 loaded
[   16.393783] bttv: using 8 buffers with 2080k (520 pages) each for capture
[   16.395293] bttv: Host bridge needs ETBF enabled
[   16.396533] Zoran MJPEG board driver version 0.10.1
[   16.397720] Linux video codec intermediate layer: v0.2
[   16.398933] meye: using 2 buffers with 600k (1200k total) for capture
[   16.400706] saa7130/34: v4l2 driver version 0, 2, 17 loaded
[   16.402054] cx88/0: cx2388x v4l2 driver version 0.0.9 loaded
[   16.403507] cx88/2: cx2388x MPEG-TS Driver Manager version 0.0.9 loaded
[   16.405034] cx2388x alsa driver version 0.0.9 loaded
[   16.406251] cx2388x blackbird driver version 0.0.9 loaded
[   16.407531] cx88/2: registering cx8802 driver, type: blackbird access: shared
[   16.409099] cx88/2: cx2388x dvb driver version 0.0.9 loaded
[   16.410358] cx88/2: registering cx8802 driver, type: dvb access: shared
[   16.411933] usbcore: registered new interface driver em28xx
[   16.413222] Em28xx: Initialized (Em28xx Audio Extension) extension
[   16.414569] Em28xx: Initialized (Em28xx dvb Extension) extension
[   16.416040] Em28xx: Initialized (Em28xx Input Extension) extension
[   16.417457] usbcore: registered new interface driver poseidon
[   16.418806] usbcore: registered new interface driver cx231xx
[   16.420191] cx231xx: Cx231xx Audio Extension initialized
[   16.421389] cx231xx: Cx231xx dvb Extension initialized
[   16.422623] usbcore: registered new interface driver usbvision
[   16.424075] USBVision USB Video Device Driver for Linux : 0.9.11
[   16.425801] usbcore: registered new interface driver pvrusb2
[   16.427060] pvrusb2: V4L in-tree version:Hauppauge WinTV-PVR-USB2 MPEG2 Encoder/Tuner
[   16.428878] pvrusb2: Debug mask is 31 (0x1f)
[   16.429894] cpia2: V4L-Driver for Vision CPiA2 based cameras v3.0.1
[   16.431406] usbcore: registered new interface driver cpia2
[   16.432901] usbcore: registered new interface driver tm6000
[   16.434281] saa7146: register extension 'Multimedia eXtension Board'
[   16.435898] saa7146: register extension 'hexium HV-PCI6 Orion'
[   16.437280] saa7146: register extension 'hexium gemini'
[   16.438603] usbcore: registered new interface driver zr364xx
[   16.440118] usbcore: registered new interface driver stkwebcam
[   16.441465] usbcore: registered new interface driver sn9c102
[   16.442784] usbcore: registered new interface driver Philips webcam
[   16.444259] gspca_main: v2.14.0 registered
[   16.445298] usbcore: registered new interface driver benq
[   16.446567] usbcore: registered new interface driver conex
[   16.447921] usbcore: registered new interface driver cpia1
[   16.449235] usbcore: registered new interface driver etoms
[   16.450534] usbcore: registered new interface driver finepix
[   16.451921] usbcore: registered new interface driver jeilinj
[   16.453272] usbcore: registered new interface driver kinect
[   16.454575] usbcore: registered new interface driver konica
[   16.455957] usbcore: registered new interface driver mars
[   16.457269] usbcore: registered new interface driver mr97310a
[   16.458617] usbcore: registered new interface driver nw80x
[   16.459988] usbcore: registered new interface driver ov519
[   16.461309] usbcore: registered new interface driver ov534
[   16.462594] usbcore: registered new interface driver ov534_9
[   16.464071] usbcore: registered new interface driver pac207
[   16.465375] usbcore: registered new interface driver gspca_pac7302
[   16.466780] usbcore: registered new interface driver pac7311
[   16.468251] usbcore: registered new interface driver se401
[   16.469530] usbcore: registered new interface driver sn9c2028
[   16.470905] usbcore: registered new interface driver gspca_sn9c20x
[   16.472378] usbcore: registered new interface driver sonixb
[   16.473672] usbcore: registered new interface driver sonixj
[   16.474991] usbcore: registered new interface driver spca500
[   16.476367] usbcore: registered new interface driver spca501
[   16.477752] usbcore: registered new interface driver spca505
[   16.479092] usbcore: registered new interface driver spca506
[   16.480501] usbcore: registered new interface driver spca508
[   16.481818] usbcore: registered new interface driver spca561
[   16.483125] usbcore: registered new interface driver spca1528
[   16.484549] usbcore: registered new interface driver sq905
[   16.485843] usbcore: registered new interface driver sq905c
[   16.487135] usbcore: registered new interface driver sq930x
[   16.488498] usbcore: registered new interface driver sunplus
[   16.489841] usbcore: registered new interface driver stk014
[   16.491135] usbcore: registered new interface driver stv0680
[   16.492552] usbcore: registered new interface driver t613
[   16.493972] usbcore: registered new interface driver tv8532
[   16.495363] usbcore: registered new interface driver vc032x
[   16.496681] usbcore: registered new interface driver vicam
[   16.497995] usbcore: registered new interface driver xirlink-cit
[   16.499424] usbcore: registered new interface driver gspca_zc3xx
[   16.500859] usbcore: registered new interface driver ALi m5602
[   16.502233] usbcore: registered new interface driver STV06xx
[   16.503694] usbcore: registered new interface driver gspca_gl860
[   16.505116] usbcore: registered new interface driver hdpvr
[   16.506402] usbcore: registered new interface driver s2255
[   16.507689] ivtv: Start initialization, version 1.4.3
[   16.508947] ivtv: End initialization
[   16.509861] ivtvfb:  no cards found
[   16.510721] cx18:  Start initialization, version 1.5.1
[   16.512059] cx18:  End initialization
[   16.512959] cx18-alsa: module loading...
[   16.514492] vivi-000: V4L2 device registered as video0
[   16.515728] Video Technology Magazine Virtual Video Capture Board ver 0.8.1 successfully loaded.
[   16.517719] cx23885 driver version 0.0.3 loaded
[   16.518865] au0828 driver loaded
[   16.519859] usbcore: registered new interface driver au0828
[   16.521215] usbcore: registered new interface driver uvcvideo
[   16.522489] USB Video Class driver (1.1.1)
[   16.523609] saa7164 driver loaded
[   16.524840] usbcore: registered new interface driver dsbr100
[   16.526151] usbcore: registered new interface driver radio-si470x
[   16.527631] usbcore: registered new interface driver radio-mr800
[   16.529180] saa7146: register extension 'budget dvb'
[   16.530402] saa7146: register extension 'budget_av'
[   16.531675] saa7146: register extension 'budget_ci dvb'
[   16.532974] saa7146: register extension 'budget_patch dvb'
[   16.534281] saa7146: register extension 'av7110'
[   16.535598] usbcore: registered new interface driver ttusb-dec
[   16.536989] usbcore: registered new interface driver ttusb
[   16.538220] b2c2-flexcop: B2C2 FlexcopII/II(b)/III digital TV receiver chip loaded successfully
[   16.540464] usbcore: registered new interface driver b2c2_flexcop_usb
[   16.541861] bt878: AUDIO driver version 0.0.0 loaded
[   16.551170] usbcore: registered new interface driver dvb_usb_vp7045
[   16.552621] usbcore: registered new interface driver dvb_usb_vp702x
[   16.554125] usbcore: registered new interface driver dvb_usb_gp8psk
[   16.555636] usbcore: registered new interface driver dvb_usb_dtt200u
[   16.557118] usbcore: registered new interface driver dvb_usb_a800
[   16.558521] usbcore: registered new interface driver dvb_usb_dibusb_mb
[   16.560190] usbcore: registered new interface driver dvb_usb_dibusb_mc
[   16.561664] usbcore: registered new interface driver dvb_usb_nova_t_usb2
[   16.563179] usbcore: registered new interface driver dvb_usb_umt_010
[   16.564642] usbcore: registered new interface driver dvb_usb_m920x
[   16.566063] usbcore: registered new interface driver dvb_usb_gl861
[   16.567534] usbcore: registered new interface driver dvb_usb_au6610
[   16.568998] usbcore: registered new interface driver dvb_usb_digitv
[   16.570431] usbcore: registered new interface driver dvb_usb_cxusb
[   16.571940] usbcore: registered new interface driver dvb_usb_ttusb2
[   16.573413] usbcore: registered new interface driver dvb_usb_dib0700
[   16.574860] usbcore: registered new interface driver opera1
[   16.576302] usbcore: registered new interface driver dvb_usb_af9005
[   16.577771] usbcore: registered new interface driver dvb_usb_anysee
[   16.579214] usbcore: registered new interface driver dw2102
[   16.580557] usbcore: registered new interface driver dvb_usb_dtv5100
[   16.582009] usbcore: registered new interface driver dvb_usb_af9015
[   16.583587] usbcore: registered new interface driver cinergyT2
[   16.584971] usbcore: registered new interface driver dvb_usb_ce6230
[   16.586404] usbcore: registered new interface driver dvb_usb_friio
[   16.587882] usbcore: registered new interface driver dvb_usb_ec168
[   16.589334] usbcore: registered new interface driver dvb_usb_az6027
[   16.590771] usbcore: registered new interface driver LME2510C_DVB-S
[   16.592312] usbcore: registered new interface driver dvb_usb_technisat_usb2
[   16.593874] usbcore: registered new interface driver it913x
[   16.595281] usbcore: registered new interface driver smsusb
[   16.596576] smssdio: Siano SMS1xxx SDIO driver
[   16.597613] smssdio: Copyright Pierre Ossman
[   16.599000] nGene PCIE bridge driver, Copyright (C) 2005-2007 Micronas
[   16.600591] pps_ldisc: PPS line discipline registered
[   16.601738] pps_parport: parallel port PPS client
[   16.602858] parport0: cannot grant exclusive access for device pps_parport
[   16.604449] pps_parport: couldn't register with parport0
[   16.605638] Driver for 1-wire Dallas network protocol.
[   16.607021] usbcore: registered new interface driver DS9490R
[   16.608421] 1-Wire driver for the DS2760 battery monitor  chip  - (c) 2004-2005, Szabolcs Gyurko
[   16.610632] i2c-core: driver [max17040] using legacy suspend method
[   16.612162] i2c-core: driver [max17040] using legacy resume method
[   16.638304] input: ImExPS/2 Generic Explorer Mouse as /devices/platform/i8042/serio1/input/input5
[   17.900266] i2c i2c-0: detect fail: address match, 0x2c
[   17.920262] i2c i2c-0: detect fail: address match, 0x2d
[   17.940247] i2c i2c-0: detect fail: address match, 0x2e
[   17.956273] i2c i2c-0: detect fail: address match, 0x2f
[   18.224155] applesmc: supported laptop not found!
[   18.226082] applesmc: driver init failed (ret=-19)!
[   26.572688] pc87360: PC8736x not detected, module not inserted
[   27.081047] usbcore: registered new interface driver pcwd_usb
[   27.084975] acquirewdt: WDT driver for Acquire single board computer initialising
[   27.090172] acquirewdt: I/O address 0x0043 already in use
[   27.091524] acquirewdt: probe of acquirewdt failed with error -5
[   27.092876] advantechwdt: WDT driver for Advantech single board computer initialising
[   27.095018] advantechwdt: initialized. timeout=60 sec (nowayout=0)
[   27.096460] alim7101_wdt: Steve Hill <steve@navaho.co.uk>
[   27.097691] alim7101_wdt: ALi M7101 PMU not present - WDT not set
[   27.099127] sp5100_tco: SP5100 TCO WatchDog Timer Driver v0.01
[   27.100730] sc520_wdt: cannot register miscdev on minor=130 (err=-16)
[   27.102294] eurotechwdt: can't misc_register on minor=130
[   27.103631] ib700wdt: WDT driver for IB700 single board computer initialising
[   27.105327] ib700wdt: START method I/O 443 is not available
[   27.106580] ib700wdt: probe of ib700wdt failed with error -5
[   27.107996] wafer5823wdt: WDT driver for Wafer 5823 single board computer initialising
[   27.109834] wafer5823wdt: I/O address 0x0443 already in use
[   27.111133] i6300esb: Intel 6300ESB WatchDog Timer Driver v0.05
[   27.112716] i6300esb: cannot register miscdev on minor=130 (err=-16)
[   27.114264] i6300ESB timer: probe of 0000:00:0a.0 failed with error -16
[   27.115863] iTCO_wdt: Intel TCO WatchDog Timer Driver v1.07
[   27.117167] iTCO_vendor_support: vendor-support=0
[   27.118336] it87_wdt: no device
[   27.119211] sc1200wdt: build 20020303
[   27.120191] sc1200wdt: io parameter must be specified
[   27.121371] pc87413_wdt: Version 1.1 at io 0x2E
[   27.122425] pc87413_wdt: cannot register miscdev on minor=130 (err=-16)
[   27.123947] nv_tco: NV TCO WatchDog Timer Driver v0.01
[   27.125303] sbc60xxwdt: I/O address 0x0443 already in use
[   27.126520] sbc8360: failed to register misc device
[   27.127738] cpu5wdt: misc_register failed
[   27.128797] smsc37b787_wdt: SMsC 37B787 watchdog component driver 1.1 initialising...
[   27.131684] smsc37b787_wdt: Unable to register miscdev on minor 130
[   27.133084] w83627hf_wdt: WDT driver for the Winbond(TM) W83627HF/THF/HG/DHG Super I/O chip initialising
[   27.135258] w83627hf_wdt: Watchdog already running. Resetting timeout to 60 sec
[   27.137021] w83627hf_wdt: cannot register miscdev on minor=130 (err=-16)
[   27.138469] w83697hf_wdt: WDT driver for W83697HF/HG initializing
[   27.139978] w83697hf_wdt: watchdog not found at address 0x2e
[   27.141258] w83697hf_wdt: No W83697HF/HG could be found
[   27.142446] w83697ug_wdt: WDT driver for the Winbond(TM) W83697UG/UF Super I/O chip initialising
[   27.144600] w83697ug_wdt: No W83697UG/UF could be found
[   27.145787] w83877f_wdt: I/O address 0x0443 already in use
[   27.147020] w83977f_wdt: driver v1.00
[   27.147970] w83977f_wdt: cannot register miscdev on minor=130 (err=-16)
[   27.149421] machzwd: MachZ ZF-Logic Watchdog driver initializing
[   27.150767] machzwd: no ZF-Logic found
[   27.151831] sbc_epx_c3: cannot register miscdev on minor=130 (err=-16)
[   27.153318] watchdog: Software Watchdog: cannot register miscdev on minor=130 (err=-16).
[   27.155259] watchdog: Software Watchdog: a legacy watchdog module is probably present.
[   27.157239] softdog: Software Watchdog Timer: 0.08 initialized. soft_noboot=0 soft_margin=60 sec soft_panic=0 (nowayout=0)
[   27.159755] md: linear personality registered for level -1
[   27.161048] md: raid0 personality registered for level 0
[   27.162243] md: raid1 personality registered for level 1
[   27.163515] md: raid10 personality registered for level 10
[   27.164759] md: raid6 personality registered for level 6
[   27.165973] md: raid5 personality registered for level 5
[   27.167222] md: raid4 personality registered for level 4
[   27.168442] md: multipath personality registered for level -4
[   27.169721] md: faulty personality registered for level -5
[   27.171453] device-mapper: uevent: version 1.0.3
[   27.172935] device-mapper: ioctl: 4.22.0-ioctl (2011-10-19) initialised: dm-devel@redhat.com
[   27.176538] device-mapper: multipath: version 1.4.0 loaded
[   27.177827] device-mapper: multipath round-robin: version 1.0.0 loaded
[   27.179333] device-mapper: multipath queue-length: version 0.1.0 loaded
[   27.180852] device-mapper: multipath service-time: version 0.2.0 loaded
[   27.182669] device-mapper: dm-log-userspace: version 1.1.0 loaded
[   27.184447] Bluetooth: Virtual HCI driver ver 1.3
[   27.185715] Bluetooth: HCI UART driver ver 2.2
[   27.186756] Bluetooth: HCI H4 protocol initialized
[   27.187998] Bluetooth: HCI BCSP protocol initialized
[   27.189169] Bluetooth: HCILL protocol initialized
[   27.190268] Bluetooth: HCIATH3K protocol initialized
[   27.191651] usbcore: registered new interface driver bcm203x
[   27.193023] usbcore: registered new interface driver bpa10x
[   27.194334] usbcore: registered new interface driver bfusb
[   27.195911] usbcore: registered new interface driver btusb
[   27.197162] Bluetooth: Generic Bluetooth SDIO driver ver 0.1
[   27.198511] usbcore: registered new interface driver ath3k
[   27.200317] CAPI 2.0 started up with major 68 (middleware)
[   27.201543] Modular ISDN core version 1.1.29
[   27.202771] NET: Registered protocol family 34
[   27.203976] DSP module 2.0
[   27.204717] mISDN_dsp: DSP clocks every 64 samples. This equals 2 jiffies.
[   27.207610] mISDN: Layer-1-over-IP driver Rev. 2.00
[   27.208994] 0 virtual devices registered
[   27.210042] b1pci: revision 1.1.2.2
[   27.210911] b1: revision 1.1.2.2
[   27.211808] b1dma: revision 1.1.2.3
[   27.212748] b1pci: revision 1.1.2.2
[   27.213720] t1pci: revision 1.1.2.2
[   27.214667] c4: revision 1.1.2.2
[   27.215706] mISDN: HFC-multi driver 2.03
[   27.216831] usbcore: registered new interface driver HFC-S_USB
[   27.218123] AVM Fritz PCI driver Rev. 2.3
[   27.219155] Sedlbauer Speedfax+ Driver Rev. 2.0
[   27.220383] Infineon ISDN Driver Rev. 1.0
[   27.221422] Winbond W6692 PCI driver Rev. 2.0
[   27.222527] mISDNipac module version 2.0
[   27.223571] mISDN: ISAR driver Rev. 2.1
[   27.224521] gigaset: Driver for Gigaset 307x
[   27.225538] gigaset: Kernel CAPI interface
[   27.226637] usbcore: registered new interface driver usb_gigaset
[   27.228118] usb_gigaset: USB Driver for Gigaset 307x using M105
[   27.229545] usbcore: registered new interface driver bas_gigaset
[   27.230900] bas_gigaset: USB Driver for Gigaset 307x
[   27.232199] EDAC MC: Ver: 2.1.0
[   27.234721] AMD64 EDAC driver v3.4.0
[   27.235923] cpuidle: using governor ladder
[   27.236939] cpuidle: using governor menu
[   27.237973] sdhci: Secure Digital Host Controller Interface driver
[   27.239362] sdhci: Copyright(c) Pierre Ossman
[   27.240502] wbsd: Winbond W83L51xD SD/MMC card interface driver
[   27.241813] wbsd: Copyright(c) Pierre Ossman
[   27.242987] via_sdmmc: VIA SD/MMC Card Reader driver (C) 2008 VIA Technologies, Inc.
[   27.246427] VUB300 Driver rom wait states = 1C irqpoll timeout = 0400
[   27.246427] usbcore: registered new interface driver vub300
[   27.257314] usbcore: registered new interface driver ushc
[   27.258527] sdhci-pltfm: SDHCI platform and OF driver helper
[   27.260907] leds_ss4200: no LED devices found
[   27.264848] user_mad: couldn't register device number
[   27.266039] user_verbs: couldn't register device number
[   27.267322] ucm: couldn't register device number
[   27.270166] ib_qib: Unable to register ipathfs
[   27.276371] iscsi: registered transport (iser)
[   27.277607] EFI Variables Facility v0.08 2004-May-17
[   27.279302] dcdbas dcdbas: Dell Systems Management Base Driver (version 5.6.0-3.2)
[   27.281613] No iBFT detected.
[   27.286135] usbcore: registered new interface driver usbhid
[   27.287910] usbhid: USB HID core driver
[   27.289362] Easycap version: 0.9.01
[   27.290473] usbcore: registered new interface driver easycap
[   27.291956] usbcore: registered new interface driver lirc_igorplugusb
[   27.293435] usbcore: registered new interface driver lirc_imon
[   27.294860] usbcore: registered new interface driver lirc_sasem
[   27.296531] lirc_serial: port 03f8 already in use
[   27.297611] lirc_serial: use 'setserial /dev/ttySX uart none'
[   27.298886] lirc_serial: or compile the serial port driver as module and
[   27.300406] lirc_serial: make sure this module is loaded first
[   27.301734] lirc_serial: probe of lirc_serial.0 failed with error -16
[   27.303347] platform lirc_serial.0: lirc_dev: driver lirc_serial registered at minor = 1
[   27.305214] lirc_register_driver: dev pointer not filled in!
[   27.306470] lirc_sir: init_chrdev() failed.
[   27.307609] usbcore: registered new interface driver TTUSBIR
[   27.308896] lirc_zilog: Zilog/Hauppauge IR driver initializing
[   27.310941] lirc_zilog: initialization complete
[   27.312158] usbip_core: USB/IP Core v1.0.0
[   27.313306] vhci_hcd vhci_hcd: USB/IP Virtual Host Controller
[   27.315024] vhci_hcd vhci_hcd: new USB bus registered, assigned bus number 1
[   27.319627] usb usb1: New USB device found, idVendor=1d6b, idProduct=0002
[   27.321396] usb usb1: New USB device strings: Mfr=3, Product=2, SerialNumber=1
[   27.323514] usb usb1: Product: USB/IP Virtual Host Controller
[   27.325054] usb usb1: Manufacturer: Linux 3.5.0-rc4+ vhci_hcd
[   27.326561] usb usb1: SerialNumber: vhci_hcd
[   27.328718] hub 1-0:1.0: USB hub found
[   27.329914] hub 1-0:1.0: 8 ports detected
[   27.331193] vhci_hcd: USB/IP 'Virtual' Host Controller (VHCI) Driver v1.0.0
[   27.332929] usbcore: registered new interface driver usbip-host
[   27.334246] usbip_host: USB/IP Host Driver v1.0.0
[   27.335529] usbcore: registered new interface driver prism2_usb
[   27.336931] usbcore: registered new interface driver r8712u
[   27.338179] Initializing Realtek PCIE storage driver...
[   27.339587] zram: num_devices not specified. Using default: 1
[   27.340913] zram: Creating 1 devices ...
[   27.342466] input: Speakup as /devices/virtual/input/input6
[   27.344305] initialized device: /dev/synth, node (MAJOR 10, MINOR 25)
[   27.346275] speakup 3.1.6: initialized
[   27.347288] synth name on entry is: (null)
[   27.348312] Linux telephony interface: v1.00
[   27.349346] ixj driver initialized.
[   27.350555] asus_wmi: Asus Management GUID not found
[   27.350555] asus_wmi: Management GUID not found
[   27.353238] asus_wmi: Management GUID not found
[   27.354805] msi_laptop: driver 0.5 successfully loaded
[   27.356301] compal_laptop: Motherboard not recognized (You could try the module's force-parameter)
[   27.358303] dell_wmi: No known WMI GUID found
[   27.359392] dell_wmi_aio: No known WMI GUID found
[   27.360519] acer_wmi: Acer Laptop ACPI-WMI Extras
[   27.361634] acer_wmi: No or unsupported WMI interface, unable to load
[   27.363056] acerhdf: Acer Aspire One Fan driver, v.0.5.26
[   27.364348] acerhdf: unknown (unsupported) BIOS version Bochs/Bochs/Bochs, please report, aborting!
[   27.366441] hp_accel: driver loaded
[   27.367526] hdaps: supported laptop not found!
[   27.368597] hdaps: driver init failed (ret=-19)!
[   27.370092] fujitsu_laptop: driver 0.6.0 successfully loaded
[   27.371567] msi_wmi: This machine doesn't have MSI-hotkeys through WMI
[   27.373090] topstar_laptop: ACPI extras driver loaded
[   27.375183] intel_oaktrail: Platform not recognized (You could try the module's force-parameter)
[   27.375183] ieee802154hardmac ieee802154hardmac: Added ieee802154 HardMAC hardware
[   27.378937] hv_utils: Registering HyperV Utility Driver
[   27.380206] hv_vmbus: registering driver hv_util
[   27.399022] no UART detected at 0x1
[   27.400324] MTVAP port 0x378 is busy
[   27.401276] snd_mtpav: probe of snd_mtpav failed with error -16
[   27.402833] snd_mts64: probe of snd_mts64.0 failed with error -5
[   27.404613] snd_portman2x4: probe of snd_portman2x4.0 failed with error -5
[   27.406298] Error: Driver 'pcspkr' is already registered, aborting...
[   27.409823] ASIHPI driver 4.10.01
[   27.414528] usbcore: registered new interface driver snd-usb-audio
[   27.416168] usbcore: registered new interface driver snd-ua101
[   27.417538] usbcore: registered new interface driver snd-usb-usx2y
[   27.418972] usbcore: registered new interface driver snd-usb-us122l
[   27.420536] usbcore: registered new interface driver snd-usb-caiaq
[   27.421979] usbcore: registered new interface driver snd-usb-6fire
[   27.423609] oprofile: using NMI interrupt.
[   27.424777] pktgen: Packet Generator for packet performance testing. Version: 2.74
[   27.427979] drop_monitor: Initializing network drop monitor service
[   27.429742] NET: Registered protocol family 26
[   27.430869] GACT probability on
[   27.431820] Mirror/redirect action on
[   27.432755] Simple TC action Loaded
[   27.434057] netem: version 1.3
[   27.434860] u32 classifier
[   27.435713]     Performance counters on
[   27.436682]     input device check on
[   27.437591]     Actions configured
[   27.438484] Netfilter messages via NETLINK v0.30.
[   27.439991] nf_conntrack version 0.5.0 (3360 buckets, 13440 max)
[   27.441932] ctnetlink v0.93: registering with nfnetlink.
[   27.443463] NF_TPROXY: Transparent proxy support initialized, version 4.1.0
[   27.445000] NF_TPROXY: Copyright (c) 2006-2007 BalaBit IT Ltd.
[   27.446707] xt_time: kernel timezone is -0000
[   27.447924] ip_set: protocol 6
[   27.448771] IPVS: Registered protocols (TCP, UDP, SCTP, AH, ESP)
[   27.450253] IPVS: Connection hash table configured (size=4096, memory=64Kbytes)
[   27.452384] IPVS: Creating netns size=3080 id=0
[   27.453529] IPVS: ipvs loaded.
[   27.454340] IPVS: [rr] scheduler registered.
[   27.455487] IPVS: [wrr] scheduler registered.
[   27.456557] IPVS: [lc] scheduler registered.
[   27.457573] IPVS: [wlc] scheduler registered.
[   27.458610] IPVS: [lblc] scheduler registered.
[   27.459816] IPVS: [lblcr] scheduler registered.
[   27.460912] IPVS: [dh] scheduler registered.
[   27.461931] IPVS: [sh] scheduler registered.
[   27.462949] IPVS: [sed] scheduler registered.
[   27.464043] IPVS: [nq] scheduler registered.
[   27.465082] IPVS: [sip] pe registered.
[   27.466042] IPv4 over IPv4 tunneling driver
[   27.467492] gre: GRE over IPv4 demultiplexor driver
[   27.468648] ip_gre: GRE over IPv4 tunneling driver
[   27.470426] ip_tables: (C) 2000-2006 Netfilter Core Team
[   27.471999] ipt_CLUSTERIP: ClusterIP Version 0.8 loaded successfully
[   27.473515] arp_tables: (C) 2002 David S. Miller
[   27.474681] TCP: bic registered
[   27.475634] TCP: cubic registered
[   27.476502] TCP: westwood registered
[   27.477392] TCP: highspeed registered
[   27.478295] TCP: hybla registered
[   27.479137] TCP: htcp registered
[   27.480059] TCP: vegas registered
[   27.480910] TCP: veno registered
[   27.481734] TCP: scalable registered
[   27.482617] TCP: lp registered
[   27.483486] TCP: yeah registered
[   27.484342] TCP: illinois registered
[   27.485238] Initializing XFRM netlink socket
[   27.486910] NET: Registered protocol family 10
[   27.491648] mip6: Mobile IPv6
[   27.492533] ip6_tables: (C) 2000-2006 Netfilter Core Team
[   27.494006] sit: IPv6 over IPv4 tunneling driver
[   27.496190] NET: Registered protocol family 17
[   27.497312] NET: Registered protocol family 15
[   27.498536] Bridge firewalling registered
[   27.499680] Ebtables v2.0 registered
[   27.500937] NET: Registered protocol family 4
[   27.502108] NET: Registered protocol family 5
[   27.504966] NET: Registered protocol family 6
[   27.509732] NET: Registered protocol family 11
[   27.510969] NET: Registered protocol family 3
[   27.512158] can: controller area network core (rev 20120528 abi 9)
[   27.513786] NET: Registered protocol family 29
[   27.514853] can: raw protocol (rev 20120528)
[   27.515970] can: broadcast manager protocol (rev 20120528 t)
[   27.517300] can: netlink gateway (rev 20101209)
[   27.519292] IrCOMM protocol (Dag Brattli)
[   27.524513] RPC: Registered rdma transport module.
[   27.526019] NET: Registered protocol family 33
[   27.527076] Key type rxrpc registered
[   27.528048] Key type rxrpc_s registered
[   27.531329] RxRPC: Registered security type 2 'rxkad'
[   27.532608] lec:lane_module_init: lec.c: initialized
[   27.533879] mpoa:atm_mpoa_init: mpc.c: initialized
[   27.535017] l2tp_core: L2TP core driver, V2.0
[   27.536157] l2tp_ppp: PPPoL2TP kernel driver, V2.0
[   27.537266] l2tp_ip: L2TP IP encapsulation support (L2TPv3)
[   27.538599] l2tp_netlink: L2TP netlink interface
[   27.539844] l2tp_eth: L2TP ethernet pseudowire support (L2TPv3)
[   27.549290] l2tp_debugfs: L2TP debugfs support
[   27.550354] l2tp_ip6: L2TP IP encapsulation support for IPv6 (L2TPv3)
[   27.551987] NET4: DECnet for Linux: V.2.5.68s (C) 1995-2003 Linux DECnet Project Team
[   27.554296] DECnet: Routing cache hash table of 256 buckets, 20Kbytes
[   27.555916] NET: Registered protocol family 12
[   27.557130] NET: Registered protocol family 35
[   27.558417] 8021q: 802.1Q VLAN Support v1.8
[   27.561321] DCCP: Activated CCID 2 (TCP-like)
[   27.562527] DCCP: Activated CCID 3 (TCP-Friendly Rate Control)
[   27.576254] DCCP watch registered (port=0)
[   27.578040] sctp: Hash tables configured (established 1638 bind 1638)
[   27.591514] sctp_probe: probe registered (port=0)
[   27.593262] NET: Registered protocol family 21
[   27.594675] Registered RDS/iwarp transport
[   27.595938] Registered RDS/infiniband transport
[   27.597185] Registered RDS/tcp transport
[   27.598360] lib80211: common routines for IEEE802.11 drivers
[   27.599829] lib80211_crypt: registered algorithm 'NULL'
[   27.601100] lib80211_crypt: registered algorithm 'WEP'
[   27.602276] lib80211_crypt: registered algorithm 'CCMP'
[   27.603567] lib80211_crypt: registered algorithm 'TKIP'
[   27.604801] TIPC: Activated (version 2.0.0)
[   27.607190] NET: Registered protocol family 30
[   27.608283] TIPC: Started in single node mode
[   27.609334] 9pnet: Installing 9P2000 support
[   27.610574] NET: Registered protocol family 36
[   27.611781] Key type dns_resolver registered
[   27.612857] Key type ceph registered
[   27.613755] libceph: loaded (mon/osd proto 15/24, osdmap 5/6 5/6)
[   27.615627] batman_adv: B.A.T.M.A.N. advanced 2012.3.0 (compatibility version 14) loaded
[   27.620433] 
[   27.620433] printing PIC contents
[   27.621678] ... PIC  IMR: ffff
[   27.622471] ... PIC  IRR: 9153
[   27.623387] ... PIC  ISR: 0000
[   27.624209] ... PIC ELCR: 0c00
[   27.625012] printing local APIC contents on CPU#0/0:
[   27.626154] ... APIC ID:      00000000 (0)
[   27.627141] ... APIC VERSION: 00050014
[   27.628154] ... APIC TASKPRI: 00000000 (00)
[   27.628192] ... APIC PROCPRI: 00000000
[   27.628192] ... APIC LDR: 01000000
[   27.628192] ... APIC DFR: ffffffff
[   27.628192] ... APIC SPIV: 000001ff
[   27.628192] ... APIC ISR field:
[   27.628192] 0000000000000000000000000000000000000000000000000000000000000000
[   27.628192] ... APIC TMR field:
[   27.628192] 0000000000000000000000000000000000000000000000000000000000000000
[   27.628192] ... APIC IRR field:
[   27.628192] 0000000000000000000000000000000000000000000000000000000000008000
[   27.628192] ... APIC ESR: 00000000
[   27.628192] ... APIC ICR: 000008fd
[   27.628192] ... APIC ICR2: 02000000
[   27.628192] ... APIC LVTT: 000000ef
[   27.628192] ... APIC LVTPC: 00010000
[   27.628192] ... APIC LVT0: 00010700
[   27.628192] ... APIC LVT1: 00000400
[   27.628192] ... APIC LVTERR: 000000fe
[   27.628192] ... APIC TMICT: 0003a11a
[   27.628192] ... APIC TMCCT: 00000000
[   27.628192] ... APIC TDCR: 00000003
[   27.628192] 
[   27.650449] number of MP IRQ sources: 15.
[   27.651544] number of IO-APIC #2 registers: 24.
[   27.652635] testing the IO APIC.......................
[   27.653918] 
[   27.654425] IO APIC #2......
[   27.655289] .... register #00: 00000000
[   27.656256] .......    : physical APIC id: 00
[   27.657293] .......    : Delivery Type: 0
[   27.658259] .......    : LTS          : 0
[   27.659327] .... register #01: 00170011
[   27.660308] .......     : max redirection entries: 17
[   27.661476] .......     : PRQ implemented: 0
[   27.662489] .......     : IO APIC version: 11
[   27.663579] .... register #02: 00000000
[   27.664543] .......     : arbitration: 00
[   27.665516] .... IRQ redirection table:
[   27.666450]  NR Dst Mask Trig IRR Pol Stat Dmod Deli Vect:
[   27.667829]  00 00  1    0    0   0   0    0    0    00
[   27.669055]  01 03  0    0    0   0   0    1    1    31
[   27.670273]  02 03  0    0    0   0   0    1    1    30
[   27.671533]  03 03  0    0    0   0   0    1    1    33
[   27.672760]  04 03  1    0    0   0   0    1    1    34
[   27.673986]  05 03  1    1    0   0   0    1    1    35
[   27.675276]  06 03  0    0    0   0   0    1    1    36
[   27.676496]  07 03  0    0    0   0   0    1    1    37
[   27.677692]  08 03  0    0    0   0   0    1    1    38
[   27.678890]  09 03  0    1    0   0   0    1    1    39
[   27.680205]  0a 03  1    1    0   0   0    1    1    3A
[   27.681409]  0b 03  1    1    0   0   0    1    1    3B
[   27.682612]  0c 03  0    0    0   0   0    1    1    3C
[   27.683955]  0d 03  0    0    0   0   0    1    1    3D
[   27.685180]  0e 03  0    0    0   0   0    1    1    3E
[   27.686377]  0f 03  0    0    0   0   0    1    1    3F
[   27.687701]  10 00  1    0    0   0   0    0    0    00
[   27.688933]  11 00  1    0    0   0   0    0    0    00
[   27.690140]  12 00  1    0    0   0   0    0    0    00
[   27.691458]  13 00  1    0    0   0   0    0    0    00
[   27.692678]  14 00  1    0    0   0   0    0    0    00
[   27.693903]  15 00  1    0    0   0   0    0    0    00
[   27.695093]  16 00  1    0    0   0   0    0    0    00
[   27.696357]  17 00  1    0    0   0   0    0    0    00
[   27.697550] IRQ to pin mappings:
[   27.698385] IRQ0 -> 0:2
[   27.699075] IRQ1 -> 0:1
[   27.699818] IRQ3 -> 0:3
[   27.700528] IRQ4 -> 0:4
[   27.701225] IRQ5 -> 0:5
[   27.701916] IRQ6 -> 0:6
[   27.702592] IRQ7 -> 0:7
[   27.703372] IRQ8 -> 0:8
[   27.704083] IRQ9 -> 0:9
[   27.704762] IRQ10 -> 0:10
[   27.705477] IRQ11 -> 0:11
[   27.706189] IRQ12 -> 0:12
[   27.706906] IRQ13 -> 0:13
[   27.707690] IRQ14 -> 0:14
[   27.708437] IRQ15 -> 0:15
[   27.709162] .................................... done.
[   27.712130] PM: Hibernation image not present or could not be loaded.
[   27.717160] registered taskstats version 1
[   27.720045] Running tests on trace events:
[   27.736490] Testing event 9p_client_req: OK
[   27.752500] Testing event 9p_client_res: OK
[   27.773265] Testing event 9p_protocol_dump: OK
[   27.793360] Testing event drv_return_void: OK
[   27.813143] Testing event drv_return_int: OK
[   27.833352] Testing event drv_return_bool: OK
[   27.853227] Testing event drv_return_u64: OK
[   27.873388] Testing event drv_start: OK
[   27.893247] Testing event drv_get_et_strings: OK
[   27.913358] Testing event drv_get_et_sset_count: OK
[   27.933241] Testing event drv_get_et_stats: OK
[   27.953377] Testing event drv_suspend: OK
[   27.973213] Testing event drv_resume: OK
[   27.993379] Testing event drv_set_wakeup: OK
[   28.013246] Testing event drv_stop: OK
[   28.033356] Testing event drv_add_interface: OK
[   28.053245] Testing event drv_change_interface: OK
[   28.073386] Testing event drv_remove_interface: OK
[   28.093212] Testing event drv_config: OK
[   28.113390] Testing event drv_bss_info_changed: OK
[   28.133237] Testing event drv_prepare_multicast: OK
[   28.153178] Testing event drv_configure_filter: OK
[   28.173150] Testing event drv_set_tim: OK
[   28.193209] Testing event drv_set_key: OK
[   28.213367] Testing event drv_update_tkip_key: OK
[   28.233221] Testing event drv_hw_scan: OK
[   28.253256] Testing event drv_cancel_hw_scan: OK
[   28.273234] Testing event drv_sched_scan_start: OK
[   28.293193] Testing event drv_sched_scan_stop: OK
[   28.313178] Testing event drv_sw_scan_start: OK
[   28.333230] Testing event drv_sw_scan_complete: OK
[   28.353216] Testing event drv_get_stats: OK
[   28.373110] Testing event drv_get_tkip_seq: OK
[   28.393187] Testing event drv_set_frag_threshold: OK
[   28.413278] Testing event drv_set_rts_threshold: OK
[   28.433361] Testing event drv_set_coverage_class: OK
[   28.453591] Testing event drv_sta_notify: OK
[   28.473383] Testing event drv_sta_state: OK
[   28.493257] Testing event drv_sta_rc_update: OK
[   28.513375] Testing event drv_sta_add: OK
[   28.533244] Testing event drv_sta_remove: OK
[   28.553382] Testing event drv_conf_tx: OK
[   28.573220] Testing event drv_get_tsf: OK
[   28.593377] Testing event drv_set_tsf: OK
[   28.613262] Testing event drv_reset_tsf: OK
[   28.633379] Testing event drv_tx_last_beacon: OK
[   28.653329] Testing event drv_ampdu_action: OK
[   28.673389] Testing event drv_get_survey: OK
[   28.693212] Testing event drv_flush: OK
[   28.713386] Testing event drv_channel_switch: OK
[   28.733250] Testing event drv_set_antenna: OK
[   28.753369] Testing event drv_get_antenna: OK
[   28.773266] Testing event drv_remain_on_channel: OK
[   28.793383] Testing event drv_cancel_remain_on_channel: OK
[   28.813213] Testing event drv_offchannel_tx: OK
[   28.840652] Testing event drv_set_ringparam: OK
[   28.857158] Testing event drv_get_ringparam: OK
[   28.876557] Testing event drv_tx_frames_pending: OK
[   28.896595] Testing event drv_offchannel_tx_cancel_wait: OK
[   28.916390] Testing event drv_set_bitrate_mask: OK
[   28.932532] Testing event drv_set_rekey_data: OK
[   28.953389] Testing event drv_rssi_callback: OK
[   28.973241] Testing event drv_release_buffered_frames: OK
[   28.993374] Testing event drv_allow_buffered_frames: OK
[   29.013246] Testing event drv_get_rssi: OK
[   29.033393] Testing event api_start_tx_ba_session: OK
[   29.053250] Testing event api_start_tx_ba_cb: OK
[   29.073385] Testing event api_stop_tx_ba_session: OK
[   29.093251] Testing event api_stop_tx_ba_cb: OK
[   29.113382] Testing event api_restart_hw: OK
[   29.133270] Testing event api_beacon_loss: OK
[   29.153385] Testing event api_connection_loss: OK
[   29.173219] Testing event api_cqm_rssi_notify: OK
[   29.193388] Testing event api_scan_completed: OK
[   29.213224] Testing event api_sched_scan_results: OK
[   29.233262] Testing event api_sched_scan_stopped: OK
[   29.253197] Testing event api_sta_block_awake: OK
[   29.273216] Testing event api_chswitch_done: OK
[   29.293120] Testing event api_ready_on_channel: OK
[   29.313225] Testing event api_remain_on_channel_expired: OK
[   29.333365] Testing event api_gtk_rekey_notify: OK
[   29.353161] Testing event api_enable_rssi_reports: OK
[   29.373151] Testing event api_eosp: OK
[   29.393221] Testing event wake_queue: OK
[   29.413106] Testing event stop_queue: OK
[   29.433218] Testing event rpc_call_status: OK
[   29.453132] Testing event rpc_bind_status: OK
[   29.473199] Testing event rpc_connect_status: OK
[   29.493108] Testing event rpc_task_begin: OK
[   29.513250] Testing event rpc_task_run_action: OK
[   29.533234] Testing event rpc_task_complete: OK
[   29.553389] Testing event rpc_task_sleep: OK
[   29.573261] Testing event rpc_task_wakeup: OK
[   29.593365] Testing event kfree_skb: OK
[   29.613253] Testing event consume_skb: OK
[   29.633389] Testing event skb_copy_datagram_iovec: OK
[   29.653216] Testing event net_dev_xmit: OK
[   29.673384] Testing event net_dev_queue: OK
[   29.693257] Testing event netif_receive_skb: OK
[   29.713359] Testing event netif_rx: OK
[   29.733261] Testing event napi_poll: OK
[   29.753385] Testing event sock_rcvqueue_full: OK
[   29.773198] Testing event sock_exceed_buf_limit: OK
[   29.793213] Testing event udp_fail_queue_rcv_skb: OK
[   29.808617] vhci_hcd: changed 0
[   29.817080] Testing event hda_send_cmd: OK
[   29.836409] Testing event hda_get_response: OK
[   29.852650] Testing event hda_bus_reset: OK
[   29.873216] Testing event hda_power_down: OK
[   29.893138] Testing event hda_power_up: OK
[   29.913215] Testing event hda_unsol_event: OK
[   29.933116] Testing event scsi_dispatch_cmd_start: OK
[   29.953358] Testing event scsi_dispatch_cmd_error: OK
[   29.973243] Testing event scsi_dispatch_cmd_done: OK
[   29.993386] Testing event scsi_dispatch_cmd_timeout: OK
[   30.013236] Testing event scsi_eh_wakeup: OK
[   30.033385] Testing event regmap_reg_write: OK
[   30.053253] Testing event regmap_reg_read: OK
[   30.073374] Testing event regmap_reg_read_cache: OK
[   30.093097] Testing event regmap_hw_read_start: OK
[   30.113368] Testing event regmap_hw_read_done: OK
[   30.133209] Testing event regmap_hw_write_start: OK
[   30.153386] Testing event regmap_hw_write_done: OK
[   30.173267] Testing event regcache_sync: OK
[   30.193382] Testing event regmap_cache_only: OK
[   30.213242] Testing event regmap_cache_bypass: OK
[   30.233394] Testing event i915_gem_object_create: OK
[   30.253218] Testing event i915_gem_object_bind: OK
[   30.273394] Testing event i915_gem_object_unbind: OK
[   30.293235] Testing event i915_gem_object_change_domain: OK
[   30.313375] Testing event i915_gem_object_pwrite: OK
[   30.333246] Testing event i915_gem_object_pread: OK
[   30.353398] Testing event i915_gem_object_fault: OK
[   30.373231] Testing event i915_gem_object_clflush: OK
[   30.393394] Testing event i915_gem_object_destroy: OK
[   30.413142] Testing event i915_gem_evict: OK
[   30.433206] Testing event i915_gem_evict_everything: OK
[   30.453069] Testing event i915_gem_ring_dispatch: OK
[   30.473251] Testing event i915_gem_ring_flush: OK
[   30.493297] Testing event i915_gem_request_add: OK
[   30.513437] Testing event i915_gem_request_complete: OK
[   30.533300] Testing event i915_gem_request_retire: OK
[   30.553407] Testing event i915_gem_request_wait_begin: OK
[   30.573289] Testing event i915_gem_request_wait_end: OK
[   30.593440] Testing event i915_ring_wait_begin: OK
[   30.613281] Testing event i915_ring_wait_end: OK
[   30.633436] Testing event i915_flip_request: OK
[   30.653306] Testing event i915_flip_complete: OK
[   30.673412] Testing event i915_reg_rw: OK
[   30.693312] Testing event radeon_bo_create: OK
[   30.713438] Testing event radeon_fence_emit: OK
[   30.733252] Testing event radeon_fence_retire: OK
[   30.753439] Testing event radeon_fence_wait_begin: OK
[   30.773302] Testing event radeon_fence_wait_end: OK
[   30.793414] Testing event drm_vblank_event: OK
[   30.813268] Testing event drm_vblank_event_queued: OK
[   30.833108] Testing event drm_vblank_event_delivered: OK
[   30.853269] Testing event regulator_enable: OK
[   30.873428] Testing event regulator_enable_delay: OK
[   30.893290] Testing event regulator_enable_complete: OK
[   30.913411] Testing event regulator_disable: OK
[   30.933283] Testing event regulator_disable_complete: OK
[   30.953436] Testing event regulator_set_voltage: OK
[   30.973253] Testing event regulator_set_voltage_complete: OK
[   30.993435] Testing event gpio_direction: OK
[   31.013305] Testing event gpio_value: OK
[   31.033276] Testing event block_rq_abort: OK
[   31.053336] Testing event block_rq_requeue: OK
[   31.073221] Testing event block_rq_complete: OK
[   31.093138] Testing event block_rq_insert: OK
[   31.113226] Testing event block_rq_issue: OK
[   31.133366] Testing event block_bio_bounce: OK
[   31.153149] Testing event block_bio_complete: OK
[   31.173372] Testing event block_bio_backmerge: OK
[   31.193218] Testing event block_bio_frontmerge: OK
[   31.213108] Testing event block_bio_queue: OK
[   31.233136] Testing event block_getrq: OK
[   31.253365] Testing event block_sleeprq: OK
[   31.273343] Testing event block_plug: OK
[   31.293368] Testing event block_unplug: OK
[   31.313223] Testing event block_split: OK
[   31.333115] Testing event block_bio_remap: OK
[   31.353217] Testing event block_rq_remap: OK
[   31.373130] Testing event gfs2_glock_state_change: OK
[   31.393176] Testing event gfs2_glock_put: OK
[   31.413353] Testing event gfs2_demote_rq: OK
[   31.433447] Testing event gfs2_promote: OK
[   31.453266] Testing event gfs2_glock_queue: OK
[   31.473420] Testing event gfs2_glock_lock_time: OK
[   31.493293] Testing event gfs2_pin: OK
[   31.513406] Testing event gfs2_log_flush: OK
[   31.533285] Testing event gfs2_log_blocks: OK
[   31.553431] Testing event gfs2_ail_flush: OK
[   31.573258] Testing event gfs2_bmap: OK
[   31.593429] Testing event gfs2_block_alloc: OK
[   31.613406] Testing event btrfs_transaction_commit: OK
[   31.633420] Testing event btrfs_inode_new: OK
[   31.653285] Testing event btrfs_inode_request: OK
[   31.673422] Testing event btrfs_inode_evict: OK
[   31.693263] Testing event btrfs_get_extent: OK
[   31.713443] Testing event btrfs_ordered_extent_add: OK
[   31.733264] Testing event btrfs_ordered_extent_remove: OK
[   31.753413] Testing event btrfs_ordered_extent_start: OK
[   31.773282] Testing event btrfs_ordered_extent_put: OK
[   31.793422] Testing event __extent_writepage: OK
[   31.813258] Testing event btrfs_writepage_end_io_hook: OK
[   31.824407] vhci_hcd: changed 0
[   31.833440] Testing event btrfs_sync_file: OK
[   31.853402] Testing event btrfs_sync_fs: OK
[   31.873409] Testing event btrfs_delayed_tree_ref: OK
[   31.893281] Testing event btrfs_delayed_data_ref: OK
[   31.913423] Testing event btrfs_delayed_ref_head: OK
[   31.933270] Testing event btrfs_chunk_alloc: OK
[   31.953442] Testing event btrfs_chunk_free: OK
[   31.973292] Testing event btrfs_cow_block: OK
[   31.993405] Testing event btrfs_space_reservation: OK
[   32.013262] Testing event btrfs_reserved_extent_alloc: OK
[   32.033441] Testing event btrfs_reserved_extent_free: OK
[   32.053259] Testing event find_free_extent: OK
[   32.073422] Testing event btrfs_reserve_extent: OK
[   32.093301] Testing event btrfs_reserve_extent_cluster: OK
[   32.113410] Testing event btrfs_find_cluster: OK
[   32.133304] Testing event btrfs_failed_cluster_setup: OK
[   32.153398] Testing event btrfs_setup_cluster: OK
[   32.173255] Testing event alloc_extent_state: OK
[   32.193430] Testing event free_extent_state: OK
[   32.213298] Testing event ocfs2_adjust_rightmost_branch: OK
[   32.233430] Testing event ocfs2_rotate_tree_right: OK
[   32.253285] Testing event ocfs2_append_rec_to_path: OK
[   32.273439] Testing event ocfs2_insert_extent_start: OK
[   32.293187] Testing event ocfs2_add_clusters_in_btree: OK
[   32.313348] Testing event ocfs2_num_free_extents: OK
[   32.333360] Testing event ocfs2_complete_edge_insert: OK
[   32.353352] Testing event ocfs2_grow_tree: OK
[   32.373424] Testing event ocfs2_rotate_subtree: OK
[   32.400641] Testing event ocfs2_insert_extent: OK
[   32.417168] Testing event ocfs2_split_extent: OK
[   32.436552] Testing event ocfs2_remove_extent: OK
[   32.456661] Testing event ocfs2_commit_truncate: OK
[   32.476556] Testing event ocfs2_validate_extent_block: OK
[   32.496617] Testing event ocfs2_rotate_leaf: OK
[   32.516386] Testing event ocfs2_add_clusters_in_btree_ret: OK
[   32.536656] Testing event ocfs2_mark_extent_written: OK
[   32.556506] Testing event ocfs2_truncate_log_append: OK
[   32.576655] Testing event ocfs2_replay_truncate_records: OK
[   32.596550] Testing event ocfs2_flush_truncate_log: OK
[   32.616611] Testing event ocfs2_begin_truncate_log_recovery: OK
[   32.636654] Testing event ocfs2_truncate_log_recovery_num: OK
[   32.656642] Testing event ocfs2_complete_truncate_log_recovery: OK
[   32.676553] Testing event ocfs2_free_cached_blocks: OK
[   32.696671] Testing event ocfs2_cache_cluster_dealloc: OK
[   32.716384] Testing event ocfs2_run_deallocs: OK
[   32.732550] Testing event ocfs2_cache_block_dealloc: OK
[   32.753437] Testing event ocfs2_trim_extent: OK
[   32.773261] Testing event ocfs2_trim_group: OK
[   32.793428] Testing event ocfs2_trim_fs: OK
[   32.813265] Testing event ocfs2_la_set_sizes: OK
[   32.833270] Testing event ocfs2_alloc_should_use_local: OK
[   32.853099] Testing event ocfs2_load_local_alloc: OK
[   32.873255] Testing event ocfs2_begin_local_alloc_recovery: OK
[   32.893125] Testing event ocfs2_reserve_local_alloc_bits: OK
[   32.913227] Testing event ocfs2_local_alloc_count_bits: OK
[   32.933368] Testing event ocfs2_local_alloc_find_clear_bits_search_bitmap: OK
[   32.953203] Testing event ocfs2_local_alloc_find_clear_bits: OK
[   32.973115] Testing event ocfs2_sync_local_to_main: OK
[   32.993228] Testing event ocfs2_sync_local_to_main_free: OK
[   33.013166] Testing event ocfs2_local_alloc_new_window: OK
[   33.033268] Testing event ocfs2_local_alloc_new_window_result: OK
[   33.053354] Testing event ocfs2_update_last_group_and_inode: OK
[   33.073360] Testing event ocfs2_group_extend: OK
[   33.093374] Testing event ocfs2_group_add: OK
[   33.113240] Testing event ocfs2_validate_group_descriptor: OK
[   33.133208] Testing event ocfs2_block_group_alloc_contig: OK
[   33.153248] Testing event ocfs2_block_group_alloc_discontig: OK
[   33.173296] Testing event ocfs2_block_group_alloc: OK
[   33.193244] Testing event ocfs2_reserve_suballoc_bits_nospc: OK
[   33.213336] Testing event ocfs2_reserve_suballoc_bits_no_new_group: OK
[   33.233216] Testing event ocfs2_reserve_new_inode_new_group: OK
[   33.253149] Testing event ocfs2_block_group_set_bits: OK
[   33.273103] Testing event ocfs2_relink_block_group: OK
[   33.293164] Testing event ocfs2_cluster_group_search_wrong_max_bits: OK
[   33.313256] Testing event ocfs2_cluster_group_search_max_block: OK
[   33.333330] Testing event ocfs2_block_group_search_max_block: OK
[   33.353269] Testing event ocfs2_search_chain_begin: OK
[   33.373248] Testing event ocfs2_search_chain_succ: OK
[   33.393220] Testing event ocfs2_search_chain_end: OK
[   33.413156] Testing event ocfs2_claim_suballoc_bits: OK
[   33.433203] Testing event ocfs2_claim_new_inode_at_loc: OK
[   33.453392] Testing event ocfs2_block_group_clear_bits: OK
[   33.473229] Testing event ocfs2_free_suballoc_bits: OK
[   33.493114] Testing event ocfs2_free_clusters: OK
[   33.513219] Testing event ocfs2_get_suballoc_slot_bit: OK
[   33.533349] Testing event ocfs2_test_suballoc_bit: OK
[   33.553162] Testing event ocfs2_test_inode_bit: OK
[   33.573378] Testing event ocfs2_validate_refcount_block: OK
[   33.593223] Testing event ocfs2_purge_refcount_trees: OK
[   33.613163] Testing event ocfs2_create_refcount_tree: OK
[   33.633233] Testing event ocfs2_create_refcount_tree_blkno: OK
[   33.653359] Testing event ocfs2_change_refcount_rec: OK
[   33.673147] Testing event ocfs2_expand_inline_ref_root: OK
[   33.693341] Testing event ocfs2_divide_leaf_refcount_block: OK
[   33.713226] Testing event ocfs2_new_leaf_refcount_block: OK
[   33.733256] Testing event ocfs2_insert_refcount_rec: OK
[   33.753424] Testing event ocfs2_split_refcount_rec: OK
[   33.773288] Testing event ocfs2_split_refcount_rec_insert: OK
[   33.793420] Testing event ocfs2_increase_refcount_begin: OK
[   33.813292] Testing event ocfs2_increase_refcount_change: OK
[   33.833303] Testing event ocfs2_increase_refcount_insert: OK
[   33.840234] vhci_hcd: changed 0
[   33.853392] Testing event ocfs2_increase_refcount_split: OK
[   33.873141] Testing event ocfs2_remove_refcount_extent: OK
[   33.893145] Testing event ocfs2_restore_refcount_block: OK
[   33.913201] Testing event ocfs2_decrease_refcount_rec: OK
[   33.933312] Testing event ocfs2_decrease_refcount: OK
[   33.953424] Testing event ocfs2_mark_extent_refcounted: OK
[   33.973430] Testing event ocfs2_calc_refcount_meta_credits: OK
[   33.993331] Testing event ocfs2_calc_refcount_meta_credits_iterate: OK
[   34.013408] Testing event ocfs2_add_refcount_flag: OK
[   34.033358] Testing event ocfs2_prepare_refcount_change_for_del: OK
[   34.053435] Testing event ocfs2_lock_refcount_allocators: OK
[   34.073343] Testing event ocfs2_duplicate_clusters_by_page: OK
[   34.093423] Testing event ocfs2_duplicate_clusters_by_jbd: OK
[   34.113375] Testing event ocfs2_clear_ext_refcount: OK
[   34.133460] Testing event ocfs2_replace_clusters: OK
[   34.153355] Testing event ocfs2_make_clusters_writable: OK
[   34.173396] Testing event ocfs2_refcount_cow_hunk: OK
[   34.193345] Testing event ocfs2_symlink_get_block: OK
[   34.213438] Testing event ocfs2_get_block: OK
[   34.233338] Testing event ocfs2_get_block_end: OK
[   34.253367] Testing event ocfs2_readpage: OK
[   34.273352] Testing event ocfs2_writepage: OK
[   34.293402] Testing event ocfs2_bmap: OK
[   34.313348] Testing event ocfs2_try_to_write_inline_data: OK
[   34.333437] Testing event ocfs2_write_begin_nolock: OK
[   34.353345] Testing event ocfs2_write_end_inline: OK
[   34.373363] Testing event ocfs2_fault: OK
[   34.393351] Testing event ocfs2_file_open: OK
[   34.413345] Testing event ocfs2_file_release: OK
[   34.433358] Testing event ocfs2_sync_file: OK
[   34.453337] Testing event ocfs2_file_aio_write: OK
[   34.473379] Testing event ocfs2_file_splice_write: OK
[   34.493358] Testing event ocfs2_file_splice_read: OK
[   34.513355] Testing event ocfs2_file_aio_read: OK
[   34.533395] Testing event ocfs2_truncate_file: OK
[   34.553352] Testing event ocfs2_truncate_file_error: OK
[   34.573429] Testing event ocfs2_extend_allocation: OK
[   34.593363] Testing event ocfs2_extend_allocation_end: OK
[   34.613374] Testing event ocfs2_write_zero_page: OK
[   34.633355] Testing event ocfs2_zero_extend_range: OK
[   34.653394] Testing event ocfs2_zero_extend: OK
[   34.673328] Testing event ocfs2_setattr: OK
[   34.693426] Testing event ocfs2_write_remove_suid: OK
[   34.713380] Testing event ocfs2_zero_partial_clusters: OK
[   34.733429] Testing event ocfs2_zero_partial_clusters_range1: OK
[   34.753360] Testing event ocfs2_zero_partial_clusters_range2: OK
[   34.773397] Testing event ocfs2_remove_inode_range: OK
[   34.793344] Testing event ocfs2_prepare_inode_for_write: OK
[   34.813402] Testing event generic_file_aio_read_ret: OK
[   34.833365] Testing event ocfs2_iget_begin: OK
[   34.853422] Testing event ocfs2_iget5_locked: OK
[   34.873352] Testing event ocfs2_iget_end: OK
[   34.893426] Testing event ocfs2_find_actor: OK
[   34.913325] Testing event ocfs2_populate_inode: OK
[   34.933351] Testing event ocfs2_read_locked_inode: OK
[   34.953358] Testing event ocfs2_check_orphan_recovery_state: OK
[   34.973366] Testing event ocfs2_validate_inode_block: OK
[   34.993334] Testing event ocfs2_inode_is_valid_to_delete: OK
[   35.013385] Testing event ocfs2_query_inode_wipe_begin: OK
[   35.033382] Testing event ocfs2_query_inode_wipe_succ: OK
[   35.053431] Testing event ocfs2_query_inode_wipe_end: OK
[   35.073364] Testing event ocfs2_cleanup_delete_inode: OK
[   35.093368] Testing event ocfs2_delete_inode: OK
[   35.113360] Testing event ocfs2_clear_inode: OK
[   35.133395] Testing event ocfs2_drop_inode: OK
[   35.153353] Testing event ocfs2_inode_revalidate: OK
[   35.173402] Testing event ocfs2_mark_inode_dirty: OK
[   35.193327] Testing event ocfs2_read_virt_blocks: OK
[   35.213366] Testing event ocfs2_refresh_slot_info: OK
[   35.233341] Testing event ocfs2_map_slot_buffers: OK
[   35.253393] Testing event ocfs2_map_slot_buffers_block: OK
[   35.273390] Testing event ocfs2_find_slot: OK
[   35.293244] Testing event ocfs2_do_node_down: OK
[   35.313424] Testing event ocfs2_remount: OK
[   35.333303] Testing event ocfs2_fill_super: OK
[   35.353421] Testing event ocfs2_parse_options: OK
[   35.373309] Testing event ocfs2_put_super: OK
[   35.393433] Testing event ocfs2_statfs: OK
[   35.413133] Testing event ocfs2_dismount_volume: OK
[   35.433269] Testing event ocfs2_initialize_super: OK
[   35.453098] Testing event ocfs2_validate_xattr_block: OK
[   35.473057] Testing event ocfs2_xattr_extend_allocation: OK
[   35.493105] Testing event ocfs2_init_xattr_set_ctxt: OK
[   35.513224] Testing event ocfs2_xattr_bucket_find: OK
[   35.533118] Testing event ocfs2_xattr_index_block_find: OK
[   35.553326] Testing event ocfs2_xattr_index_block_find_rec: OK
[   35.573327] Testing event ocfs2_iterate_xattr_buckets: OK
[   35.593323] Testing event ocfs2_iterate_xattr_bucket: OK
[   35.613391] Testing event ocfs2_cp_xattr_block_to_bucket_begin: OK
[   35.633431] Testing event ocfs2_cp_xattr_block_to_bucket_end: OK
[   35.653434] Testing event ocfs2_xattr_create_index_block_begin: OK
[   35.673337] Testing event ocfs2_xattr_create_index_block: OK
[   35.693356] Testing event ocfs2_defrag_xattr_bucket: OK
[   35.713351] Testing event ocfs2_mv_xattr_bucket_cross_cluster: OK
[   35.733404] Testing event ocfs2_divide_xattr_bucket_begin: OK
[   35.753429] Testing event ocfs2_divide_xattr_bucket_move: OK
[   35.773294] Testing event ocfs2_cp_xattr_bucket: OK
[   35.793430] Testing event ocfs2_mv_xattr_buckets: OK
[   35.813281] Testing event ocfs2_adjust_xattr_cross_cluster: OK
[   35.833413] Testing event ocfs2_add_new_xattr_cluster_begin: OK
[   35.853279] Testing event ocfs2_add_new_xattr_cluster: OK
[   35.857177] vhci_hcd: changed 0
[   35.876557] Testing event ocfs2_add_new_xattr_cluster_insert: OK
[   35.896998] Testing event ocfs2_extend_xattr_bucket: OK
[   35.916398] Testing event ocfs2_add_new_xattr_bucket: OK
[   35.932383] Testing event ocfs2_xattr_bucket_value_truncate: OK
[   35.960603] Testing event ocfs2_rm_xattr_cluster: OK
[   35.976973] Testing event ocfs2_reflink_xattr_header: OK
[   35.996638] Testing event ocfs2_create_empty_xattr_block: OK
[   36.016563] Testing event ocfs2_xattr_set_entry_bucket: OK
[   36.036394] Testing event ocfs2_xattr_set_entry_index_block: OK
[   36.056595] Testing event ocfs2_xattr_bucket_value_refcount: OK
[   36.076405] Testing event ocfs2_reflink_xattr_buckets: OK
[   36.096601] Testing event ocfs2_reflink_xattr_rec: OK
[   36.116632] Testing event ocfs2_resv_insert: OK
[   36.136494] Testing event ocfs2_resmap_find_free_bits_begin: OK
[   36.157172] Testing event ocfs2_resmap_find_free_bits_end: OK
[   36.176653] Testing event ocfs2_resv_find_window_begin: OK
[   36.196505] Testing event ocfs2_resv_find_window_prev: OK
[   36.217308] Testing event ocfs2_resv_find_window_next: OK
[   36.236668] Testing event ocfs2_cannibalize_resv_begin: OK
[   36.256609] Testing event ocfs2_cannibalize_resv_end: OK
[   36.276564] Testing event ocfs2_resmap_resv_bits: OK
[   36.296643] Testing event ocfs2_resmap_claimed_bits_begin: OK
[   36.316387] Testing event ocfs2_resmap_claimed_bits_end: OK
[   36.336644] Testing event ocfs2_recover_local_quota_file: OK
[   36.356547] Testing event ocfs2_finish_quota_recovery: OK
[   36.376602] Testing event olq_set_dquot: OK
[   36.396655] Testing event ocfs2_validate_quota_block: OK
[   36.416658] Testing event ocfs2_sync_dquot: OK
[   36.436610] Testing event ocfs2_sync_dquot_helper: OK
[   36.456635] Testing event ocfs2_write_dquot: OK
[   36.476550] Testing event ocfs2_release_dquot: OK
[   36.496641] Testing event ocfs2_acquire_dquot: OK
[   36.516391] Testing event ocfs2_mark_dquot_dirty: OK
[   36.532948] Testing event ocfs2_search_dirblock: OK
[   36.552641] Testing event ocfs2_validate_dir_block: OK
[   36.572938] Testing event ocfs2_find_entry_el: OK
[   36.592679] Testing event ocfs2_dx_dir_search: OK
[   36.612941] Testing event ocfs2_dx_dir_search_leaf_info: OK
[   36.633124] Testing event ocfs2_delete_entry_dx: OK
[   36.653378] Testing event ocfs2_readdir: OK
[   36.673224] Testing event ocfs2_find_files_on_disk: OK
[   36.693150] Testing event ocfs2_check_dir_for_entry: OK
[   36.713197] Testing event ocfs2_dx_dir_attach_index: OK
[   36.733115] Testing event ocfs2_dx_dir_format_cluster: OK
[   36.753222] Testing event ocfs2_dx_dir_index_root_block: OK
[   36.773398] Testing event ocfs2_extend_dir: OK
[   36.793261] Testing event ocfs2_dx_dir_rebalance: OK
[   36.813335] Testing event ocfs2_dx_dir_rebalance_split: OK
[   36.833125] Testing event ocfs2_prepare_dir_for_insert: OK
[   36.853379] Testing event ocfs2_lookup: OK
[   36.873224] Testing event ocfs2_mkdir: OK
[   36.893148] Testing event ocfs2_create: OK
[   36.913097] Testing event ocfs2_unlink: OK
[   36.933099] Testing event ocfs2_symlink_create: OK
[   36.953161] Testing event ocfs2_mv_orphaned_inode_to_new: OK
[   36.973371] Testing event ocfs2_lookup_ret: OK
[   36.993218] Testing event ocfs2_mknod: OK
[   37.013097] Testing event ocfs2_link: OK
[   37.033129] Testing event ocfs2_unlink_noent: OK
[   37.053345] Testing event ocfs2_double_lock: OK
[   37.073259] Testing event ocfs2_double_lock_end: OK
[   37.093359] Testing event ocfs2_rename: OK
[   37.113225] Testing event ocfs2_rename_target_exists: OK
[   37.133115] Testing event ocfs2_rename_disagree: OK
[   37.153225] Testing event ocfs2_rename_over_existing: OK
[   37.173078] Testing event ocfs2_create_symlink_data: OK
[   37.193258] Testing event ocfs2_symlink_begin: OK
[   37.213254] Testing event ocfs2_blkno_stringify: OK
[   37.233290] Testing event ocfs2_orphan_add_begin: OK
[   37.253242] Testing event ocfs2_orphan_add_end: OK
[   37.273135] Testing event ocfs2_orphan_del: OK
[   37.293148] Testing event ocfs2_dentry_revalidate: OK
[   37.313200] Testing event ocfs2_dentry_revalidate_negative: OK
[   37.333374] Testing event ocfs2_dentry_revalidate_delete: OK
[   37.353227] Testing event ocfs2_dentry_revalidate_orphaned: OK
[   37.373127] Testing event ocfs2_dentry_revalidate_nofsdata: OK
[   37.393184] Testing event ocfs2_dentry_revalidate_ret: OK
[   37.413299] Testing event ocfs2_find_local_alias: OK
[   37.433081] Testing event ocfs2_dentry_attach_lock: OK
[   37.453298] Testing event ocfs2_dentry_attach_lock_found: OK
[   37.473184] Testing event ocfs2_get_dentry_begin: OK
[   37.493129] Testing event ocfs2_get_dentry_test_bit: OK
[   37.513161] Testing event ocfs2_get_dentry_stale: OK
[   37.533187] Testing event ocfs2_get_dentry_generation: OK
[   37.553138] Testing event ocfs2_get_dentry_end: OK
[   37.573548] Testing event ocfs2_get_parent: OK
[   37.593162] Testing event ocfs2_get_parent_end: OK
[   37.613072] Testing event ocfs2_encode_fh_begin: OK
[   37.633163] Testing event ocfs2_encode_fh_self: OK
[   37.653263] Testing event ocfs2_encode_fh_parent: OK
[   37.673334] Testing event ocfs2_encode_fh_type: OK
[   37.693260] Testing event ocfs2_commit_cache_begin: OK
[   37.713384] Testing event ocfs2_commit_cache_end: OK
[   37.733215] Testing event ocfs2_extend_trans: OK
[   37.753390] Testing event ocfs2_extend_trans_restart: OK
[   37.773229] Testing event ocfs2_journal_access: OK
[   37.793380] Testing event ocfs2_journal_dirty: OK
[   37.813203] Testing event ocfs2_journal_init: OK
[   37.833233] Testing event ocfs2_journal_init_maxlen: OK
[   37.853181] Testing event ocfs2_journal_shutdown: OK
[   37.872281] vhci_hcd: changed 0
[   37.873090] Testing event ocfs2_journal_shutdown_wait: OK
[   37.893188] Testing event ocfs2_complete_recovery: OK
[   37.913302] Testing event ocfs2_complete_recovery_end: OK
[   37.933256] Testing event ocfs2_complete_recovery_slot: OK
[   37.953386] Testing event ocfs2_recovery_thread_node: OK
[   37.973241] Testing event ocfs2_recovery_thread_end: OK
[   37.993393] Testing event ocfs2_recovery_thread: OK
[   38.013235] Testing event ocfs2_replay_journal_recovered: OK
[   38.033207] Testing event ocfs2_replay_journal_lock_err: OK
[   38.053233] Testing event ocfs2_replay_journal_skip: OK
[   38.073249] Testing event ocfs2_recover_node: OK
[   38.093149] Testing event ocfs2_recover_node_skip: OK
[   38.113263] Testing event ocfs2_mark_dead_nodes: OK
[   38.133169] Testing event ocfs2_queue_orphan_scan_begin: OK
[   38.153286] Testing event ocfs2_queue_orphan_scan_end: OK
[   38.173399] Testing event ocfs2_orphan_filldir: OK
[   38.193245] Testing event ocfs2_recover_orphans: OK
[   38.213134] Testing event ocfs2_recover_orphans_iput: OK
[   38.233170] Testing event ocfs2_wait_on_mount: OK
[   38.253382] Testing event ocfs2_read_blocks_sync: OK
[   38.273383] Testing event ocfs2_read_blocks_sync_jbd: OK
[   38.293451] Testing event ocfs2_read_blocks_from_disk: OK
[   38.313244] Testing event ocfs2_read_blocks_bh: OK
[   38.333142] Testing event ocfs2_read_blocks_end: OK
[   38.353134] Testing event ocfs2_write_block: OK
[   38.373146] Testing event ocfs2_read_blocks_begin: OK
[   38.393217] Testing event ocfs2_purge_copied_metadata_tree: OK
[   38.413317] Testing event ocfs2_metadata_cache_purge: OK
[   38.433256] Testing event ocfs2_buffer_cached_begin: OK
[   38.453176] Testing event ocfs2_buffer_cached_end: OK
[   38.473135] Testing event ocfs2_append_cache_array: OK
[   38.493193] Testing event ocfs2_insert_cache_tree: OK
[   38.513233] Testing event ocfs2_expand_cache: OK
[   38.533393] Testing event ocfs2_set_buffer_uptodate: OK
[   38.553253] Testing event ocfs2_set_buffer_uptodate_begin: OK
[   38.573145] Testing event ocfs2_remove_metadata_array: OK
[   38.593246] Testing event ocfs2_remove_metadata_tree: OK
[   38.613377] Testing event ocfs2_remove_block_from_cache: OK
[   38.633136] Testing event xfs_attr_list_sf: OK
[   38.653365] Testing event xfs_attr_list_sf_all: OK
[   38.673255] Testing event xfs_attr_list_leaf: OK
[   38.693168] Testing event xfs_attr_list_leaf_end: OK
[   38.713252] Testing event xfs_attr_list_full: OK
[   38.733396] Testing event xfs_attr_list_add: OK
[   38.753196] Testing event xfs_attr_list_wrong_blk: OK
[   38.773172] Testing event xfs_attr_list_notfound: OK
[   38.793253] Testing event xfs_perag_get: OK
[   38.813348] Testing event xfs_perag_get_tag: OK
[   38.833364] Testing event xfs_perag_put: OK
[   38.853246] Testing event xfs_perag_set_reclaim: OK
[   38.873371] Testing event xfs_perag_clear_reclaim: OK
[   38.893256] Testing event xfs_attr_list_node_descend: OK
[   38.913393] Testing event xfs_iext_insert: OK
[   38.933214] Testing event xfs_iext_remove: OK
[   38.953388] Testing event xfs_bmap_pre_update: OK
[   38.973201] Testing event xfs_bmap_post_update: OK
[   38.993367] Testing event xfs_extlist: OK
[   39.013230] Testing event xfs_buf_init: OK
[   39.033399] Testing event xfs_buf_free: OK
[   39.053100] Testing event xfs_buf_hold: OK
[   39.073361] Testing event xfs_buf_rele: OK
[   39.093259] Testing event xfs_buf_iodone: OK
[   39.113386] Testing event xfs_buf_iorequest: OK
[   39.133271] Testing event xfs_buf_bawrite: OK
[   39.153392] Testing event xfs_buf_lock: OK
[   39.173214] Testing event xfs_buf_lock_done: OK
[   39.193395] Testing event xfs_buf_trylock: OK
[   39.213223] Testing event xfs_buf_unlock: OK
[   39.233373] Testing event xfs_buf_iowait: OK
[   39.253261] Testing event xfs_buf_iowait_done: OK
[   39.273391] Testing event xfs_buf_delwri_queue: OK
[   39.293090] Testing event xfs_buf_delwri_queued: OK
[   39.313353] Testing event xfs_buf_delwri_split: OK
[   39.333234] Testing event xfs_buf_get_uncached: OK
[   39.353368] Testing event xfs_bdstrat_shut: OK
[   39.373239] Testing event xfs_buf_item_relse: OK
[   39.393413] Testing event xfs_buf_item_iodone: OK
[   39.413211] Testing event xfs_buf_item_iodone_async: OK
[   39.433250] Testing event xfs_buf_error_relse: OK
[   39.453143] Testing event xfs_trans_read_buf_io: OK
[   39.473389] Testing event xfs_trans_read_buf_shut: OK
[   39.493407] Testing event xfs_btree_corrupt: OK
[   39.513390] Testing event xfs_da_btree_corrupt: OK
[   39.540592] Testing event xfs_reset_dqcounts: OK
[   39.557116] Testing event xfs_inode_item_push: OK
[   39.576732] Testing event xfs_buf_find: OK
[   39.596638] Testing event xfs_buf_get: OK
[   39.616573] Testing event xfs_buf_read: OK
[   39.636633] Testing event xfs_buf_ioerror: OK
[   39.656407] Testing event xfs_buf_item_size: OK
[   39.676596] Testing event xfs_buf_item_size_stale: OK
[   39.696509] Testing event xfs_buf_item_format: OK
[   39.716638] Testing event xfs_buf_item_format_stale: OK
[   39.736643] Testing event xfs_buf_item_pin: OK
[   39.757012] Testing event xfs_buf_item_unpin: OK
[   39.776450] Testing event xfs_buf_item_unpin_stale: OK
[   39.792522] Testing event xfs_buf_item_unlock: OK
[   39.813198] Testing event xfs_buf_item_unlock_stale: OK
[   39.833267] Testing event xfs_buf_item_committed: OK
[   39.853204] Testing event xfs_buf_item_push: OK
[   39.873231] Testing event xfs_trans_get_buf: OK
[   39.892241] vhci_hcd: changed 0
[   39.895730] Testing event xfs_trans_get_buf_recur: OK
[   39.917160] Testing event xfs_trans_getsb: OK
[   39.936448] Testing event xfs_trans_getsb_recur: OK
[   39.952450] Testing event xfs_trans_read_buf: OK
[   39.968740] Testing event xfs_trans_read_buf_recur: OK
[   39.984520] Testing event xfs_trans_log_buf: OK
[   40.005234] Testing event xfs_trans_brelse: OK
[   40.024667] Testing event xfs_trans_bjoin: OK
[   40.045202] Testing event xfs_trans_bhold: OK
[   40.064666] Testing event xfs_trans_bhold_release: OK
[   40.085329] Testing event xfs_trans_binval: OK
[   40.104617] Testing event xfs_ilock: OK
[   40.125342] Testing event xfs_ilock_nowait: OK
[   40.144652] Testing event xfs_ilock_demote: OK
[   40.165314] Testing event xfs_iunlock: OK
[   40.185388] Testing event xfs_iget_skip: OK
[   40.204626] Testing event xfs_iget_reclaim: OK
[   40.225127] Testing event xfs_iget_reclaim_fail: OK
[   40.244557] Testing event xfs_iget_hit: OK
[   40.265164] Testing event xfs_iget_miss: OK
[   40.284632] Testing event xfs_getattr: OK
[   40.305388] Testing event xfs_setattr: OK
[   40.325332] Testing event xfs_readlink: OK
[   40.344585] Testing event xfs_alloc_file_space: OK
[   40.365307] Testing event xfs_free_file_space: OK
[   40.384643] Testing event xfs_readdir: OK
[   40.405332] Testing event xfs_get_acl: OK
[   40.425401] Testing event xfs_vm_bmap: OK
[   40.444626] Testing event xfs_file_ioctl: OK
[   40.465342] Testing event xfs_file_compat_ioctl: OK
[   40.485225] Testing event xfs_ioctl_setattr: OK
[   40.505245] Testing event xfs_dir_fsync: OK
[   40.525231] Testing event xfs_file_fsync: OK
[   40.544646] Testing event xfs_destroy_inode: OK
[   40.565310] Testing event xfs_dirty_inode: OK
[   40.584583] Testing event xfs_evict_inode: OK
[   40.605271] Testing event xfs_dquot_dqalloc: OK
[   40.624639] Testing event xfs_dquot_dqdetach: OK
[   40.645309] Testing event xfs_ihold: OK
[   40.665382] Testing event xfs_irele: OK
[   40.685276] Testing event xfs_inode_pin: OK
[   40.704613] Testing event xfs_inode_unpin: OK
[   40.725312] Testing event xfs_inode_unpin_nowait: OK
[   40.744659] Testing event xfs_remove: OK
[   40.765308] Testing event xfs_link: OK
[   40.785384] Testing event xfs_lookup: OK
[   40.805318] Testing event xfs_create: OK
[   40.824411] Testing event xfs_symlink: OK
[   40.841368] Testing event xfs_rename: OK
[   40.861268] Testing event xfs_dqadjust: OK
[   40.881169] Testing event xfs_dqreclaim_want: OK
[   40.901343] Testing event xfs_dqreclaim_dirty: OK
[   40.921264] Testing event xfs_dqreclaim_busy: OK
[   40.941217] Testing event xfs_dqreclaim_done: OK
[   40.961154] Testing event xfs_dqattach_found: OK
[   40.981346] Testing event xfs_dqattach_get: OK
[   41.001213] Testing event xfs_dqalloc: OK
[   41.021229] Testing event xfs_dqtobp_read: OK
[   41.041331] Testing event xfs_dqread: OK
[   41.061125] Testing event xfs_dqread_fail: OK
[   41.081144] Testing event xfs_dqget_hit: OK
[   41.101263] Testing event xfs_dqget_miss: OK
[   41.121286] Testing event xfs_dqget_freeing: OK
[   41.141245] Testing event xfs_dqget_dup: OK
[   41.161107] Testing event xfs_dqput: OK
[   41.181324] Testing event xfs_dqput_wait: OK
[   41.201440] Testing event xfs_dqput_free: OK
[   41.221349] Testing event xfs_dqrele: OK
[   41.241394] Testing event xfs_dqflush: OK
[   41.261307] Testing event xfs_dqflush_force: OK
[   41.281367] Testing event xfs_dqflush_done: OK
[   41.301293] Testing event xfs_log_done_nonperm: OK
[   41.321332] Testing event xfs_log_done_perm: OK
[   41.341318] Testing event xfs_log_umount_write: OK
[   41.361374] Testing event xfs_log_grant_sleep: OK
[   41.381370] Testing event xfs_log_grant_wake: OK
[   41.401346] Testing event xfs_log_grant_wake_up: OK
[   41.421307] Testing event xfs_log_reserve: OK
[   41.441337] Testing event xfs_log_reserve_exit: OK
[   41.461110] Testing event xfs_log_regrant: OK
[   41.481295] Testing event xfs_log_regrant_exit: OK
[   41.501338] Testing event xfs_log_regrant_reserve_enter: OK
[   41.521352] Testing event xfs_log_regrant_reserve_exit: OK
[   41.541292] Testing event xfs_log_regrant_reserve_sub: OK
[   41.561369] Testing event xfs_log_ungrant_enter: OK
[   41.581400] Testing event xfs_log_ungrant_exit: OK
[   41.601361] Testing event xfs_log_ungrant_sub: OK
[   41.621214] Testing event xfs_log_force: OK
[   41.641141] Testing event xfs_ail_push: OK
[   41.661214] Testing event xfs_ail_pinned: OK
[   41.681219] Testing event xfs_ail_locked: OK
[   41.701202] Testing event xfs_ail_flushing: OK
[   41.721222] Testing event xfs_file_read: OK
[   41.741307] Testing event xfs_file_buffered_write: OK
[   41.761397] Testing event xfs_file_direct_write: OK
[   41.781333] Testing event xfs_file_splice_read: OK
[   41.801390] Testing event xfs_file_splice_write: OK
[   41.821300] Testing event xfs_writepage: OK
[   41.841401] Testing event xfs_releasepage: OK
[   41.861305] Testing event xfs_invalidatepage: OK
[   41.881322] Testing event xfs_map_blocks_found: OK
[   41.901310] Testing event xfs_map_blocks_alloc: OK
[   41.908223] vhci_hcd: changed 0
[   41.921345] Testing event xfs_get_blocks_found: OK
[   41.941306] Testing event xfs_get_blocks_alloc: OK
[   41.961394] Testing event xfs_delalloc_enospc: OK
[   41.981302] Testing event xfs_unwritten_convert: OK
[   42.001382] Testing event xfs_get_blocks_notfound: OK
[   42.021309] Testing event xfs_setfilesize: OK
[   42.041373] Testing event xfs_itruncate_extents_start: OK
[   42.061324] Testing event xfs_itruncate_extents_end: OK
[   42.081405] Testing event xfs_pagecache_inval: OK
[   42.101348] Testing event xfs_bunmap: OK
[   42.121382] Testing event xfs_extent_busy: OK
[   42.141255] Testing event xfs_extent_busy_enomem: OK
[   42.161362] Testing event xfs_extent_busy_force: OK
[   42.181337] Testing event xfs_extent_busy_reuse: OK
[   42.201421] Testing event xfs_extent_busy_clear: OK
[   42.221309] Testing event xfs_extent_busy_trim: OK
[   42.241333] Testing event xfs_trans_commit_lsn: OK
[   42.261326] Testing event xfs_agf: OK
[   42.281364] Testing event xfs_free_extent: OK
[   42.301341] Testing event xfs_alloc_exact_done: OK
[   42.321362] Testing event xfs_alloc_exact_notfound: OK
[   42.341345] Testing event xfs_alloc_exact_error: OK
[   42.361322] Testing event xfs_alloc_near_nominleft: OK
[   42.381306] Testing event xfs_alloc_near_first: OK
[   42.401370] Testing event xfs_alloc_near_greater: OK
[   42.421325] Testing event xfs_alloc_near_lesser: OK
[   42.441388] Testing event xfs_alloc_near_error: OK
[   42.461128] Testing event xfs_alloc_near_noentry: OK
[   42.481290] Testing event xfs_alloc_near_busy: OK
[   42.501311] Testing event xfs_alloc_size_neither: OK
[   42.521366] Testing event xfs_alloc_size_noentry: OK
[   42.541347] Testing event xfs_alloc_size_nominleft: OK
[   42.561391] Testing event xfs_alloc_size_done: OK
[   42.581349] Testing event xfs_alloc_size_error: OK
[   42.601385] Testing event xfs_alloc_size_busy: OK
[   42.621319] Testing event xfs_alloc_small_freelist: OK
[   42.641363] Testing event xfs_alloc_small_notenough: OK
[   42.661341] Testing event xfs_alloc_small_done: OK
[   42.681403] Testing event xfs_alloc_small_error: OK
[   42.701303] Testing event xfs_alloc_vextent_badargs: OK
[   42.721369] Testing event xfs_alloc_vextent_nofix: OK
[   42.741317] Testing event xfs_alloc_vextent_noagbp: OK
[   42.761368] Testing event xfs_alloc_vextent_loopfailed: OK
[   42.781353] Testing event xfs_alloc_vextent_allfailed: OK
[   42.801412] Testing event xfs_dir2_sf_addname: OK
[   42.821339] Testing event xfs_dir2_sf_create: OK
[   42.841359] Testing event xfs_dir2_sf_lookup: OK
[   42.861308] Testing event xfs_dir2_sf_replace: OK
[   42.881373] Testing event xfs_dir2_sf_removename: OK
[   42.901323] Testing event xfs_dir2_sf_toino4: OK
[   42.921361] Testing event xfs_dir2_sf_toino8: OK
[   42.941353] Testing event xfs_dir2_sf_to_block: OK
[   42.961331] Testing event xfs_dir2_block_addname: OK
[   42.981315] Testing event xfs_dir2_block_lookup: OK
[   43.001376] Testing event xfs_dir2_block_replace: OK
[   43.021305] Testing event xfs_dir2_block_removename: OK
[   43.041402] Testing event xfs_dir2_block_to_sf: OK
[   43.061302] Testing event xfs_dir2_block_to_leaf: OK
[   43.092668] Testing event xfs_dir2_leaf_addname: OK
[   43.113346] Testing event xfs_dir2_leaf_lookup: OK
[   43.133399] Testing event xfs_dir2_leaf_replace: OK
[   43.153270] Testing event xfs_dir2_leaf_removename: OK
[   43.173372] Testing event xfs_dir2_leaf_to_block: OK
[   43.193247] Testing event xfs_dir2_leaf_to_node: OK
[   43.213401] Testing event xfs_dir2_node_addname: OK
[   43.233215] Testing event xfs_dir2_node_lookup: OK
[   43.253404] Testing event xfs_dir2_node_replace: OK
[   43.273241] Testing event xfs_dir2_node_removename: OK
[   43.293380] Testing event xfs_dir2_node_to_leaf: OK
[   43.313237] Testing event xfs_attr_sf_add: OK
[   43.333398] Testing event xfs_attr_sf_addname: OK
[   43.353213] Testing event xfs_attr_sf_create: OK
[   43.373368] Testing event xfs_attr_sf_lookup: OK
[   43.393258] Testing event xfs_attr_sf_remove: OK
[   43.413398] Testing event xfs_attr_sf_removename: OK
[   43.433254] Testing event xfs_attr_sf_to_leaf: OK
[   43.453388] Testing event xfs_attr_leaf_add: OK
[   43.473223] Testing event xfs_attr_leaf_add_old: OK
[   43.493401] Testing event xfs_attr_leaf_add_new: OK
[   43.513247] Testing event xfs_attr_leaf_addname: OK
[   43.533274] Testing event xfs_attr_leaf_create: OK
[   43.553204] Testing event xfs_attr_leaf_lookup: OK
[   43.573248] Testing event xfs_attr_leaf_replace: OK
[   43.593122] Testing event xfs_attr_leaf_removename: OK
[   43.613242] Testing event xfs_attr_leaf_split: OK
[   43.633370] Testing event xfs_attr_leaf_split_before: OK
[   43.653277] Testing event xfs_attr_leaf_split_after: OK
[   43.673151] Testing event xfs_attr_leaf_clearflag: OK
[   43.693228] Testing event xfs_attr_leaf_setflag: OK
[   43.713134] Testing event xfs_attr_leaf_flipflags: OK
[   43.733235] Testing event xfs_attr_leaf_to_sf: OK
[   43.753355] Testing event xfs_attr_leaf_to_node: OK
[   43.773172] Testing event xfs_attr_leaf_rebalance: OK
[   43.793148] Testing event xfs_attr_leaf_unbalance: OK
[   43.813117] Testing event xfs_attr_node_addname: OK
[   43.833113] Testing event xfs_attr_node_lookup: OK
[   43.853279] Testing event xfs_attr_node_replace: OK
[   43.873132] Testing event xfs_attr_node_removename: OK
[   43.893201] Testing event xfs_da_split: OK
[   43.913343] Testing event xfs_da_join: OK
[   43.924372] vhci_hcd: changed 0
[   43.933231] Testing event xfs_da_link_before: OK
[   43.953125] Testing event xfs_da_link_after: OK
[   43.973229] Testing event xfs_da_unlink_back: OK
[   43.993266] Testing event xfs_da_unlink_forward: OK
[   44.013246] Testing event xfs_da_root_split: OK
[   44.033342] Testing event xfs_da_root_join: OK
[   44.053214] Testing event xfs_da_node_add: OK
[   44.073139] Testing event xfs_da_node_create: OK
[   44.093230] Testing event xfs_da_node_split: OK
[   44.113358] Testing event xfs_da_node_remove: OK
[   44.133146] Testing event xfs_da_node_rebalance: OK
[   44.153143] Testing event xfs_da_node_unbalance: OK
[   44.173227] Testing event xfs_da_swap_lastblock: OK
[   44.193119] Testing event xfs_da_grow_inode: OK
[   44.213227] Testing event xfs_da_shrink_inode: OK
[   44.233354] Testing event xfs_dir2_leafn_add: OK
[   44.253163] Testing event xfs_dir2_leafn_remove: OK
[   44.273370] Testing event xfs_dir2_grow_inode: OK
[   44.293224] Testing event xfs_dir2_shrink_inode: OK
[   44.313164] Testing event xfs_dir2_leafn_moveents: OK
[   44.333234] Testing event xfs_swap_extent_before: OK
[   44.353137] Testing event xfs_swap_extent_after: OK
[   44.373194] Testing event xfs_log_recover_item_add: OK
[   44.393371] Testing event xfs_log_recover_item_add_cont: OK
[   44.413168] Testing event xfs_log_recover_item_reorder_head: OK
[   44.433127] Testing event xfs_log_recover_item_reorder_tail: OK
[   44.453150] Testing event xfs_log_recover_item_recover: OK
[   44.473133] Testing event xfs_log_recover_buf_not_cancel: OK
[   44.493202] Testing event xfs_log_recover_buf_cancel: OK
[   44.513326] Testing event xfs_log_recover_buf_cancel_add: OK
[   44.533229] Testing event xfs_log_recover_buf_cancel_ref_inc: OK
[   44.553124] Testing event xfs_log_recover_buf_recover: OK
[   44.573229] Testing event xfs_log_recover_buf_inode_buf: OK
[   44.593256] Testing event xfs_log_recover_buf_reg_buf: OK
[   44.613348] Testing event xfs_log_recover_buf_dquot_buf: OK
[   44.633252] Testing event xfs_log_recover_inode_recover: OK
[   44.653404] Testing event xfs_log_recover_inode_cancel: OK
[   44.673223] Testing event xfs_log_recover_inode_skip: OK
[   44.693401] Testing event xfs_discard_extent: OK
[   44.713350] Testing event xfs_discard_toosmall: OK
[   44.733383] Testing event xfs_discard_exclude: OK
[   44.753263] Testing event xfs_discard_busy: OK
[   44.773391] Testing event jbd2_checkpoint: OK
[   44.793254] Testing event jbd2_start_commit: OK
[   44.813400] Testing event jbd2_commit_locking: OK
[   44.833256] Testing event jbd2_commit_flushing: OK
[   44.853285] Testing event jbd2_commit_logging: OK
[   44.873255] Testing event jbd2_drop_transaction: OK
[   44.893394] Testing event jbd2_end_commit: OK
[   44.913215] Testing event jbd2_submit_inode_data: OK
[   44.933403] Testing event jbd2_run_stats: OK
[   44.953232] Testing event jbd2_checkpoint_stats: OK
[   44.973381] Testing event jbd2_update_log_tail: OK
[   44.993276] Testing event jbd2_write_superblock: OK
[   45.013403] Testing event jbd_checkpoint: OK
[   45.033216] Testing event jbd_start_commit: OK
[   45.053391] Testing event jbd_commit_locking: OK
[   45.073231] Testing event jbd_commit_flushing: OK
[   45.093339] Testing event jbd_commit_logging: OK
[   45.113311] Testing event jbd_drop_transaction: OK
[   45.133296] Testing event jbd_end_commit: OK
[   45.153247] Testing event jbd_do_submit_data: OK
[   45.173213] Testing event jbd_cleanup_journal_tail: OK
[   45.193135] Testing event journal_write_superblock: OK
[   45.213203] Testing event ext4_free_inode: OK
[   45.233367] Testing event ext4_request_inode: OK
[   45.253224] Testing event ext4_allocate_inode: OK
[   45.273137] Testing event ext4_evict_inode: OK
[   45.293219] Testing event ext4_drop_inode: OK
[   45.313247] Testing event ext4_mark_inode_dirty: OK
[   45.333247] Testing event ext4_begin_ordered_truncate: OK
[   45.353338] Testing event ext4_write_begin: OK
[   45.373222] Testing event ext4_da_write_begin: OK
[   45.393145] Testing event ext4_ordered_write_end: OK
[   45.413232] Testing event ext4_writeback_write_end: OK
[   45.433226] Testing event ext4_journalled_write_end: OK
[   45.453385] Testing event ext4_da_write_end: OK
[   45.473273] Testing event ext4_da_writepages: OK
[   45.493385] Testing event ext4_da_write_pages: OK
[   45.513202] Testing event ext4_da_writepages_result: OK
[   45.533217] Testing event ext4_writepage: OK
[   45.553331] Testing event ext4_readpage: OK
[   45.573261] Testing event ext4_releasepage: OK
[   45.593250] Testing event ext4_invalidatepage: OK
[   45.613359] Testing event ext4_discard_blocks: OK
[   45.633123] Testing event ext4_mb_new_inode_pa: OK
[   45.653230] Testing event ext4_mb_new_group_pa: OK
[   45.673221] Testing event ext4_mb_release_inode_pa: OK
[   45.693160] Testing event ext4_mb_release_group_pa: OK
[   45.713132] Testing event ext4_discard_preallocations: OK
[   45.733130] Testing event ext4_mb_discard_preallocations: OK
[   45.753299] Testing event ext4_request_blocks: OK
[   45.773227] Testing event ext4_allocate_blocks: OK
[   45.793248] Testing event ext4_free_blocks: OK
[   45.813319] Testing event ext4_sync_file_enter: OK
[   45.833273] Testing event ext4_sync_file_exit: OK
[   45.853402] Testing event ext4_sync_fs: OK
[   45.873256] Testing event ext4_alloc_da_blocks: OK
[   45.893403] Testing event ext4_mballoc_alloc: OK
[   45.913241] Testing event ext4_mballoc_prealloc: OK
[   45.933280] Testing event ext4_mballoc_discard: OK
[   45.940207] vhci_hcd: changed 0
[   45.953207] Testing event ext4_mballoc_free: OK
[   45.973219] Testing event ext4_forget: OK
[   45.993124] Testing event ext4_da_update_reserve_space: OK
[   46.013227] Testing event ext4_da_reserve_space: OK
[   46.033402] Testing event ext4_da_release_space: OK
[   46.053195] Testing event ext4_mb_bitmap_load: OK
[   46.073110] Testing event ext4_mb_buddy_bitmap_load: OK
[   46.093242] Testing event ext4_read_block_bitmap_load: OK
[   46.113159] Testing event ext4_load_inode_bitmap: OK
[   46.133232] Testing event ext4_direct_IO_enter: OK
[   46.153374] Testing event ext4_direct_IO_exit: OK
[   46.173163] Testing event ext4_fallocate_enter: OK
[   46.193383] Testing event ext4_fallocate_exit: OK
[   46.213226] Testing event ext4_unlink_enter: OK
[   46.233203] Testing event ext4_unlink_exit: OK
[   46.253222] Testing event ext4_truncate_enter: OK
[   46.273369] Testing event ext4_truncate_exit: OK
[   46.293194] Testing event ext4_ext_convert_to_initialized_enter: OK
[   46.313142] Testing event ext4_ext_convert_to_initialized_fastpath: OK
[   46.333098] Testing event ext4_ext_map_blocks_enter: OK
[   46.353240] Testing event ext4_ind_map_blocks_enter: OK
[   46.373227] Testing event ext4_ext_map_blocks_exit: OK
[   46.393093] Testing event ext4_ind_map_blocks_exit: OK
[   46.413162] Testing event ext4_ext_load_extent: OK
[   46.433371] Testing event ext4_load_inode: OK
[   46.453144] Testing event ext4_journal_start: OK
[   46.473147] Testing event ext4_trim_extent: OK
[   46.493228] Testing event ext4_trim_all_free: OK
[   46.513249] Testing event ext4_ext_handle_uninitialized_extents: OK
[   46.533345] Testing event ext4_get_implied_cluster_alloc_exit: OK
[   46.553276] Testing event ext4_ext_put_in_cache: OK
[   46.573389] Testing event ext4_ext_in_cache: OK
[   46.593300] Testing event ext4_find_delalloc_range: OK
[   46.613394] Testing event ext4_get_reserved_cluster_alloc: OK
[   46.633234] Testing event ext4_ext_show_extent: OK
[   46.660658] Testing event ext4_remove_blocks: OK
[   46.677127] Testing event ext4_ext_rm_leaf: OK
[   46.696652] Testing event ext4_ext_rm_idx: OK
[   46.716695] Testing event ext4_ext_remove_space: OK
[   46.736502] Testing event ext4_ext_remove_space_done: OK
[   46.756651] Testing event ext3_free_inode: OK
[   46.776560] Testing event ext3_request_inode: OK
[   46.796642] Testing event ext3_allocate_inode: OK
[   46.816621] Testing event ext3_evict_inode: OK
[   46.836417] Testing event ext3_drop_inode: OK
[   46.852651] Testing event ext3_mark_inode_dirty: OK
[   46.873239] Testing event ext3_write_begin: OK
[   46.893380] Testing event ext3_ordered_write_end: OK
[   46.913238] Testing event ext3_writeback_write_end: OK
[   46.933392] Testing event ext3_journalled_write_end: OK
[   46.953218] Testing event ext3_ordered_writepage: OK
[   46.973402] Testing event ext3_writeback_writepage: OK
[   46.993232] Testing event ext3_journalled_writepage: OK
[   47.013374] Testing event ext3_readpage: OK
[   47.033273] Testing event ext3_releasepage: OK
[   47.053411] Testing event ext3_invalidatepage: OK
[   47.073214] Testing event ext3_discard_blocks: OK
[   47.093371] Testing event ext3_request_blocks: OK
[   47.113248] Testing event ext3_allocate_blocks: OK
[   47.133374] Testing event ext3_free_blocks: OK
[   47.153270] Testing event ext3_sync_file_enter: OK
[   47.173391] Testing event ext3_sync_file_exit: OK
[   47.193282] Testing event ext3_sync_fs: OK
[   47.213401] Testing event ext3_rsv_window_add: OK
[   47.233238] Testing event ext3_discard_reservation: OK
[   47.253375] Testing event ext3_alloc_new_reservation: OK
[   47.273271] Testing event ext3_reserved: OK
[   47.293396] Testing event ext3_forget: OK
[   47.313216] Testing event ext3_read_block_bitmap: OK
[   47.333343] Testing event ext3_direct_IO_enter: OK
[   47.353242] Testing event ext3_direct_IO_exit: OK
[   47.373389] Testing event ext3_unlink_enter: OK
[   47.393342] Testing event ext3_unlink_exit: OK
[   47.413395] Testing event ext3_truncate_enter: OK
[   47.433214] Testing event ext3_truncate_exit: OK
[   47.453386] Testing event ext3_get_blocks_enter: OK
[   47.473235] Testing event ext3_get_blocks_exit: OK
[   47.493381] Testing event ext3_load_inode: OK
[   47.513261] Testing event writeback_nothread: OK
[   47.533396] Testing event writeback_queue: OK
[   47.553222] Testing event writeback_exec: OK
[   47.573368] Testing event writeback_start: OK
[   47.593497] Testing event writeback_written: OK
[   47.613383] Testing event writeback_wait: OK
[   47.633252] Testing event writeback_pages_written: OK
[   47.653412] Testing event writeback_nowork: OK
[   47.673220] Testing event writeback_wake_background: OK
[   47.693391] Testing event writeback_wake_thread: OK
[   47.713232] Testing event writeback_wake_forker_thread: OK
[   47.733376] Testing event writeback_bdi_register: OK
[   47.753248] Testing event writeback_bdi_unregister: OK
[   47.773400] Testing event writeback_thread_start: OK
[   47.793217] Testing event writeback_thread_stop: OK
[   47.813344] Testing event wbc_writepage: OK
[   47.833236] Testing event writeback_queue_io: OK
[   47.853349] Testing event global_dirty_state: OK
[   47.873246] Testing event bdi_dirty_ratelimit: OK
[   47.893389] Testing event balance_dirty_pages: OK
[   47.913213] Testing event writeback_sb_inodes_requeue: OK
[   47.933394] Testing event writeback_congestion_wait: OK
[   47.953232] Testing event writeback_wait_iff_congested: OK
[   47.957151] vhci_hcd: changed 0
[   47.976563] Testing event writeback_single_inode: OK
[   47.996648] Testing event mm_compaction_isolate_migratepages: OK
[   48.016399] Testing event mm_compaction_isolate_freepages: OK
[   48.036652] Testing event mm_compaction_migratepages: OK
[   48.056493] Testing event kmalloc: OK
[   48.073354] Testing event kmem_cache_alloc: OK
[   48.093373] Testing event kmalloc_node: OK
[   48.113243] Testing event kmem_cache_alloc_node: OK
[   48.133308] Testing event kfree: OK
[   48.153381] Testing event kmem_cache_free: OK
[   48.173198] Testing event mm_page_free: OK
[   48.193145] Testing event mm_page_free_batched: OK
[   48.213204] Testing event mm_page_alloc: OK
[   48.233368] Testing event mm_page_alloc_zone_locked: OK
[   48.253233] Testing event mm_page_pcpu_drain: OK
[   48.273130] Testing event mm_page_alloc_extfrag: OK
[   48.293221] Testing event mm_vmscan_kswapd_sleep: OK
[   48.313094] Testing event mm_vmscan_kswapd_wake: OK
[   48.333162] Testing event mm_vmscan_wakeup_kswapd: OK
[   48.353147] Testing event mm_vmscan_direct_reclaim_begin: OK
[   48.373222] Testing event mm_vmscan_memcg_reclaim_begin: OK
[   48.393413] Testing event mm_vmscan_memcg_softlimit_reclaim_begin: OK
[   48.413176] Testing event mm_vmscan_direct_reclaim_end: OK
[   48.433150] Testing event mm_vmscan_memcg_reclaim_end: OK
[   48.453123] Testing event mm_vmscan_memcg_softlimit_reclaim_end: OK
[   48.473377] Testing event mm_shrink_slab_start: OK
[   48.493230] Testing event mm_shrink_slab_end: OK
[   48.513095] Testing event mm_vmscan_lru_isolate: OK
[   48.533222] Testing event mm_vmscan_memcg_isolate: OK
[   48.553126] Testing event mm_vmscan_writepage: OK
[   48.573195] Testing event mm_vmscan_lru_shrink_inactive: OK
[   48.593306] Testing event oom_score_adj_update: OK
[   48.613263] Testing event rpm_suspend: OK
[   48.633117] Testing event rpm_resume: OK
[   48.653244] Testing event rpm_idle: OK
[   48.673354] Testing event rpm_return_int: OK
[   48.693184] Testing event cpu_idle: OK
[   48.713219] Testing event cpu_frequency: OK
[   48.733396] Testing event machine_suspend: OK
[   48.753221] Testing event wakeup_source_activate: OK
[   48.773404] Testing event wakeup_source_deactivate: OK
[   48.793253] Testing event power_start: OK
[   48.813293] Testing event power_frequency: OK
[   48.833279] Testing event power_end: OK
[   48.853264] Testing event clock_enable: OK
[   48.873381] Testing event clock_disable: OK
[   48.893365] Testing event clock_set_rate: OK
[   48.913368] Testing event power_domain_target: OK
[   48.933196] Testing event ftrace_test_filter: OK
[   48.953370] Testing event module_load: OK
[   48.973228] Testing event module_free: OK
[   48.993155] Testing event module_get: OK
[   49.013226] Testing event module_put: OK
[   49.033352] Testing event module_request: OK
[   49.053247] Testing event lock_acquire: OK
[   49.073175] Testing event lock_release: OK
[   49.093246] Testing event lock_contended: OK
[   49.113179] Testing event lock_acquired: OK
[   49.133230] Testing event sched_kthread_stop: OK
[   49.153363] Testing event sched_kthread_stop_ret: OK
[   49.173168] Testing event sched_wakeup: OK
[   49.193191] Testing event sched_wakeup_new: OK
[   49.213239] Testing event sched_switch: OK
[   49.233123] Testing event sched_migrate_task: OK
[   49.253228] Testing event sched_process_free: OK
[   49.273262] Testing event sched_process_exit: OK
[   49.293238] Testing event sched_wait_task: OK
[   49.313131] Testing event sched_process_wait: OK
[   49.333377] Testing event sched_process_fork: OK
[   49.353246] Testing event sched_process_exec: OK
[   49.373404] Testing event sched_stat_wait: OK
[   49.393236] Testing event sched_stat_sleep: OK
[   49.413391] Testing event sched_stat_iowait: OK
[   49.433355] Testing event sched_stat_blocked: OK
[   49.453396] Testing event sched_stat_runtime: OK
[   49.473255] Testing event sched_pi_setprio: OK
[   49.493415] Testing event rcu_utilization: OK
[   49.513347] Testing event rcu_grace_period: OK
[   49.533374] Testing event rcu_grace_period_init: OK
[   49.553248] Testing event rcu_preempt_task: OK
[   49.573395] Testing event rcu_unlock_preempted_task: OK
[   49.593255] Testing event rcu_quiescent_state_report: OK
[   49.613394] Testing event rcu_fqs: OK
[   49.633255] Testing event rcu_dyntick: OK
[   49.653400] Testing event rcu_prep_idle: OK
[   49.673251] Testing event rcu_callback: OK
[   49.693396] Testing event rcu_kfree_callback: OK
[   49.713220] Testing event rcu_batch_start: OK
[   49.733411] Testing event rcu_invoke_callback: OK
[   49.753241] Testing event rcu_invoke_kfree_callback: OK
[   49.773374] Testing event rcu_batch_end: OK
[   49.793255] Testing event rcu_torture_read: OK
[   49.813247] Testing event workqueue_queue_work: OK
[   49.833238] Testing event workqueue_activate_work: OK
[   49.853237] Testing event workqueue_execute_start: OK
[   49.873128] Testing event workqueue_execute_end: OK
[   49.893226] Testing event signal_generate: OK
[   49.913319] Testing event signal_deliver: OK
[   49.933224] Testing event timer_init: OK
[   49.953245] Testing event timer_start: OK
[   49.972330] vhci_hcd: changed 0
[   49.975771] Testing event timer_expire_entry: OK
[   49.993025] Testing event timer_expire_exit: OK
[   50.012887] Testing event timer_cancel: OK
[   50.033091] Testing event hrtimer_init: OK
[   50.053090] Testing event hrtimer_start: OK
[   50.073079] Testing event hrtimer_expire_entry: OK
[   50.092683] Testing event hrtimer_expire_exit: OK
[   50.113001] Testing event hrtimer_cancel: OK
[   50.133086] Testing event itimer_state: OK
[   50.153152] Testing event itimer_expire: OK
[   50.173222] Testing event irq_handler_entry: OK
[   50.193114] Testing event irq_handler_exit: OK
[   50.220595] Testing event softirq_entry: OK
[   50.237020] Testing event softirq_exit: OK
[   50.256646] Testing event softirq_raise: OK
[   50.276558] Testing event console: OK
[   50.292592] Testing event task_newtask: OK
[   50.313129] Testing event task_rename: OK
[   50.333134] Testing event mce_record: OK
[   50.353447] Testing event sys_enter: OK
[   50.373378] Testing event sys_exit: OK
[   50.393367] Testing event emulate_vsyscall: OK
[   50.413156] Testing event xen_mc_batch: OK
[   50.433194] Testing event xen_mc_issue: OK
[   50.453285] Testing event xen_mc_entry: OK
[   50.473249] Testing event xen_mc_entry_alloc: OK
[   50.493241] Testing event xen_mc_callback: OK
[   50.513325] Testing event xen_mc_flush_reason: OK
[   50.533146] Testing event xen_mc_flush: OK
[   50.553131] Testing event xen_mc_extend_args: OK
[   50.573209] Testing event xen_mmu_set_pte: OK
[   50.593339] Testing event xen_mmu_set_pte_atomic: OK
[   50.613221] Testing event xen_mmu_set_domain_pte: OK
[   50.633248] Testing event xen_mmu_set_pte_at: OK
[   50.653380] Testing event xen_mmu_pte_clear: OK
[   50.673228] Testing event xen_mmu_set_pmd: OK
[   50.693380] Testing event xen_mmu_pmd_clear: OK
[   50.713230] Testing event xen_mmu_set_pud: OK
[   50.733263] Testing event xen_mmu_set_pgd: OK
[   50.753152] Testing event xen_mmu_pud_clear: OK
[   50.773219] Testing event xen_mmu_pgd_clear: OK
[   50.793137] Testing event xen_mmu_ptep_modify_prot_start: OK
[   50.813094] Testing event xen_mmu_ptep_modify_prot_commit: OK
[   50.833225] Testing event xen_mmu_alloc_ptpage: OK
[   50.853169] Testing event xen_mmu_release_ptpage: OK
[   50.873298] Testing event xen_mmu_pgd_pin: OK
[   50.893365] Testing event xen_mmu_pgd_unpin: OK
[   50.913218] Testing event xen_mmu_flush_tlb: OK
[   50.933402] Testing event xen_mmu_flush_tlb_single: OK
[   50.953233] Testing event xen_mmu_flush_tlb_others: OK
[   50.973393] Testing event xen_mmu_write_cr3: OK
[   50.993355] Testing event xen_cpu_write_ldt_entry: OK
[   51.013402] Testing event xen_cpu_write_idt_entry: OK
[   51.033246] Testing event xen_cpu_load_idt: OK
[   51.053340] Testing event xen_cpu_write_gdt_entry: OK
[   51.073236] Testing event xen_cpu_set_ldt: OK
[   51.093379] Testing event kvm_mmu_pagetable_walk: OK
[   51.113237] Testing event kvm_mmu_paging_element: OK
[   51.133300] Testing event kvm_mmu_set_accessed_bit: OK
[   51.153228] Testing event kvm_mmu_set_dirty_bit: OK
[   51.173210] Testing event kvm_mmu_walker_error: OK
[   51.193379] Testing event kvm_mmu_get_page: OK
[   51.213156] Testing event kvm_mmu_sync_page: OK
[   51.233326] Testing event kvm_mmu_unsync_page: OK
[   51.253232] Testing event kvm_mmu_prepare_zap_page: OK
[   51.273131] Testing event kvm_mmu_delay_free_pages: OK
[   51.293222] Testing event mark_mmio_spte: OK
[   51.313125] Testing event handle_mmio_page_fault: OK
[   51.333198] Testing event kvm_entry: OK
[   51.353307] Testing event kvm_hypercall: OK
[   51.373358] Testing event kvm_hv_hypercall: OK
[   51.393239] Testing event kvm_pio: OK
[   51.413405] Testing event kvm_cpuid: OK
[   51.433231] Testing event kvm_apic: OK
[   51.453383] Testing event kvm_exit: OK
[   51.473272] Testing event kvm_inj_virq: OK
[   51.493398] Testing event kvm_inj_exception: OK
[   51.513252] Testing event kvm_page_fault: OK
[   51.533397] Testing event kvm_msr: OK
[   51.553243] Testing event kvm_cr: OK
[   51.573371] Testing event kvm_pic_set_irq: OK
[   51.593099] Testing event kvm_apic_ipi: OK
[   51.613263] Testing event kvm_apic_accept_irq: OK
[   51.633360] Testing event kvm_nested_vmrun: OK
[   51.653349] Testing event kvm_nested_intercepts: OK
[   51.673253] Testing event kvm_nested_vmexit: OK
[   51.693238] Testing event kvm_nested_vmexit_inject: OK
[   51.713123] Testing event kvm_nested_intr_vmexit: OK
[   51.733367] Testing event kvm_invlpga: OK
[   51.753243] Testing event kvm_skinit: OK
[   51.773397] Testing event kvm_emulate_insn: OK
[   51.793243] Testing event vcpu_match_mmio: OK
[   51.813294] Testing event kvm_userspace_exit: OK
[   51.833264] Testing event kvm_set_irq: OK
[   51.853405] Testing event kvm_ioapic_set_irq: OK
[   51.873220] Testing event kvm_msi_set_irq: OK
[   51.893400] Testing event kvm_ack_irq: OK
[   51.913241] Testing event kvm_mmio: OK
[   51.933274] Testing event kvm_fpu: OK
[   51.953146] Testing event kvm_age_page: OK
[   51.973219] Testing event kvm_try_async_get_page: OK
[   51.988213] vhci_hcd: changed 0
[   51.993116] Testing event kvm_async_pf_doublefault: OK
[   52.013217] Testing event kvm_async_pf_not_present: OK
[   52.033090] Testing event kvm_async_pf_ready: OK
[   52.053244] Testing event kvm_async_pf_completed: OK
[   52.056829] Running tests on trace event systems:
[   52.076620] Testing event system 9p: OK
[   52.111519] Testing event system mac80211: OK
[   52.128828] Testing event system sunrpc: OK
[   52.145344] Testing event system skb: OK
[   52.164680] Testing event system net: OK
[   52.184740] Testing event system napi: OK
[   52.205378] Testing event system sock: OK
[   52.224751] Testing event system udp: OK
[   52.245272] Testing event system hda: OK
[   52.265317] Testing event system scsi: OK
[   52.286885] Testing event system regmap: OK
[   52.307894] Testing event system i915: OK
[   52.324682] Testing event system radeon: OK
[   52.345508] Testing event system drm: OK
[   52.364785] Testing event system regulator: OK
[   52.385307] Testing event system gpio: OK
[   52.407231] Testing event system block: OK
[   52.425762] Testing event system gfs2: OK
[   52.449919] Testing event system btrfs: OK
[   52.523637] Testing event system ocfs2: OK
[   52.593569] Testing event system xfs: OK
[   52.609493] Testing event system jbd2: OK
[   52.630224] Testing event system jbd: OK
[   52.661896] Testing event system ext4: OK
[   52.686051] Testing event system ext3: OK
[   52.707885] Testing event system writeback: OK
[   52.724681] Testing event system compaction: OK
[   52.746475] Testing event system kmem: OK
[   52.766878] Testing event system vmscan: OK
[   52.784533] Testing event system oom: OK
[   52.805894] Testing event system rpm: OK
[   52.825610] Testing event system power: OK
[   52.844572] Testing event system test: OK
[   52.866170] Testing event system module: OK
[   52.884962] Testing event system lock: OK
[   52.906737] Testing event system sched: OK
[   52.926904] Testing event system rcu: OK
[   52.944585] Testing event system workqueue: OK
[   52.965447] Testing event system signal: OK
[   52.985582] Testing event system timer: OK
[   53.005103] Testing event system irq: OK
[   53.025232] Testing event system printk: OK
[   53.044562] Testing event system task: OK
[   53.065178] Testing event system mce: OK
[   53.085468] Testing event system raw_syscalls: OK
[   53.104673] Testing event system vsyscall: OK
[   53.126448] Testing event system syscalls: OK
[   53.151308] Testing event system xen: OK
[   53.170098] Testing event system kvmmmu: OK
[   53.191450] Testing event system kvm: OK
[   53.192445] Running tests on all trace events:
[   53.562843] Testing all events: OK
[   53.770458] Running tests again, along with the function tracer
[   53.772411] Running tests on trace events:
[   53.795782] Testing event 9p_client_req: OK
[   53.818914] Testing event 9p_client_res: OK
[   53.839156] Testing event 9p_protocol_dump: OK
[   53.858756] Testing event drv_return_void: OK
[   53.879175] Testing event drv_return_int: OK
[   53.898757] Testing event drv_return_bool: OK
[   53.919045] Testing event drv_return_u64: OK
[   53.939493] Testing event drv_start: OK
[   53.959055] Testing event drv_get_et_strings: OK
[   53.977878] Testing event drv_get_et_sset_count: OK
[   53.999059] Testing event drv_get_et_stats: OK
[   54.004202] vhci_hcd: changed 0
[   54.017956] Testing event drv_suspend: OK
[   54.039148] Testing event drv_resume: OK
[   54.057891] Testing event drv_set_wakeup: OK
[   54.077877] Testing event drv_stop: OK
[   54.097911] Testing event drv_add_interface: OK
[   54.119069] Testing event drv_change_interface: OK
[   54.137908] Testing event drv_remove_interface: OK
[   54.159082] Testing event drv_config: OK
[   54.177897] Testing event drv_bss_info_changed: OK
[   54.199420] Testing event drv_prepare_multicast: OK
[   54.218238] Testing event drv_configure_filter: OK
[   54.238232] Testing event drv_set_tim: OK
[   54.259266] Testing event drv_set_key: OK
[   54.278628] Testing event drv_update_tkip_key: OK
[   54.298671] Testing event drv_hw_scan: OK
[   54.318748] Testing event drv_cancel_hw_scan: OK
[   54.339436] Testing event drv_sched_scan_start: OK
[   54.358074] Testing event drv_sched_scan_stop: OK
[   54.378163] Testing event drv_sw_scan_start: OK
[   54.407390] Testing event drv_sw_scan_complete: OK
[   54.426381] Testing event drv_get_stats: OK
[   54.446020] Testing event drv_get_tkip_seq: OK
[   54.465871] Testing event drv_set_frag_threshold: OK
[   54.486761] Testing event drv_set_rts_threshold: OK
[   54.507453] Testing event drv_set_coverage_class: OK
[   54.526375] Testing event drv_sta_notify: OK
[   54.547053] Testing event drv_sta_state: OK
[   54.567212] Testing event drv_sta_rc_update: OK
[   54.587283] Testing event drv_sta_add: OK
[   54.607003] Testing event drv_sta_remove: OK
[   54.627375] Testing event drv_conf_tx: OK
[   54.647033] Testing event drv_get_tsf: OK
[   54.667148] Testing event drv_set_tsf: OK
[   54.687147] Testing event drv_reset_tsf: OK
[   54.705898] Testing event drv_tx_last_beacon: OK
[   54.727149] Testing event drv_ampdu_action: OK
[   54.746768] Testing event drv_get_survey: OK
[   54.767062] Testing event drv_flush: OK
[   54.786768] Testing event drv_channel_switch: OK
[   54.807098] Testing event drv_set_antenna: OK
[   54.826400] Testing event drv_get_antenna: OK
[   54.847438] Testing event drv_remain_on_channel: OK
[   54.866210] Testing event drv_cancel_remain_on_channel: OK
[   54.885969] Testing event drv_offchannel_tx: OK
[   54.905867] Testing event drv_set_ringparam: OK
[   54.927058] Testing event drv_get_ringparam: OK
[   54.945900] Testing event drv_tx_frames_pending: OK
[   54.966751] Testing event drv_offchannel_tx_cancel_wait: OK
[   54.987454] Testing event drv_set_bitrate_mask: OK
[   55.006315] Testing event drv_set_rekey_data: OK
[   55.027350] Testing event drv_rssi_callback: OK
[   55.046756] Testing event drv_release_buffered_frames: OK
[   55.065868] Testing event drv_allow_buffered_frames: OK
[   55.086780] Testing event drv_get_rssi: OK
[   55.107131] Testing event api_start_tx_ba_session: OK
[   55.126507] Testing event api_start_tx_ba_cb: OK
[   55.145919] Testing event api_stop_tx_ba_session: OK
[   55.166872] Testing event api_stop_tx_ba_cb: OK
[   55.185852] Testing event api_restart_hw: OK
[   55.206761] Testing event api_beacon_loss: OK
[   55.227142] Testing event api_connection_loss: OK
[   55.246329] Testing event api_cqm_rssi_notify: OK
[   55.266973] Testing event api_scan_completed: OK
[   55.287143] Testing event api_sched_scan_results: OK
[   55.306697] Testing event api_sched_scan_stopped: OK
[   55.327134] Testing event api_sta_block_awake: OK
[   55.347234] Testing event api_chswitch_done: OK
[   55.367120] Testing event api_ready_on_channel: OK
[   55.387152] Testing event api_remain_on_channel_expired: OK
[   55.405917] Testing event api_gtk_rekey_notify: OK
[   55.426841] Testing event api_enable_rssi_reports: OK
[   55.446988] Testing event api_eosp: OK
[   55.467080] Testing event wake_queue: OK
[   55.487083] Testing event stop_queue: OK
[   55.506768] Testing event rpc_call_status: OK
[   55.526947] Testing event rpc_bind_status: OK
[   55.549005] Testing event rpc_connect_status: OK
[   55.570996] Testing event rpc_task_begin: OK
[   55.594828] Testing event rpc_task_run_action: OK
[   55.618852] Testing event rpc_task_complete: OK
[   55.639085] Testing event rpc_task_sleep: OK
[   55.659223] Testing event rpc_task_wakeup: OK
[   55.678967] Testing event kfree_skb: OK
[   55.699201] Testing event consume_skb: OK
[   55.719133] Testing event skb_copy_datagram_iovec: OK
[   55.739290] Testing event net_dev_xmit: OK
[   55.759147] Testing event net_dev_queue: OK
[   55.777955] Testing event netif_receive_skb: OK
[   55.799066] Testing event netif_rx: OK
[   55.818855] Testing event napi_poll: OK
[   55.839099] Testing event sock_rcvqueue_full: OK
[   55.859277] Testing event sock_exceed_buf_limit: OK
[   55.879252] Testing event udp_fail_queue_rcv_skb: OK
[   55.898686] Testing event hda_send_cmd: OK
[   55.919417] Testing event hda_get_response: OK
[   55.938106] Testing event hda_bus_reset: OK
[   55.958395] Testing event hda_power_down: OK
[   55.977874] Testing event hda_power_up: OK
[   55.999119] Testing event hda_unsol_event: OK
[   56.018697] Testing event scsi_dispatch_cmd_start: OK
[   56.020945] vhci_hcd: changed 0
[   56.039222] Testing event scsi_dispatch_cmd_error: OK
[   56.058274] Testing event scsi_dispatch_cmd_done: OK
[   56.078991] Testing event scsi_dispatch_cmd_timeout: OK
[   56.099116] Testing event scsi_eh_wakeup: OK
[   56.119311] Testing event regmap_reg_write: OK
[   56.139451] Testing event regmap_reg_read: OK
[   56.158080] Testing event regmap_reg_read_cache: OK
[   56.178124] Testing event regmap_hw_read_start: OK
[   56.198090] Testing event regmap_hw_read_done: OK
[   56.218310] Testing event regmap_hw_write_start: OK
[   56.238046] Testing event regmap_hw_write_done: OK
[   56.258665] Testing event regcache_sync: OK
[   56.278188] Testing event regmap_cache_only: OK
[   56.299219] Testing event regmap_cache_bypass: OK
[   56.318764] Testing event i915_gem_object_create: OK
[   56.338568] Testing event i915_gem_object_bind: OK
[   56.358730] Testing event i915_gem_object_unbind: OK
[   56.379450] Testing event i915_gem_object_change_domain: OK
[   56.398093] Testing event i915_gem_object_pwrite: OK
[   56.419209] Testing event i915_gem_object_pread: OK
[   56.438727] Testing event i915_gem_object_fault: OK
[   56.458520] Testing event i915_gem_object_clflush: OK
[   56.479497] Testing event i915_gem_object_destroy: OK
[   56.497879] Testing event i915_gem_evict: OK
[   56.519043] Testing event i915_gem_evict_everything: OK
[   56.538906] Testing event i915_gem_ring_dispatch: OK
[   56.559192] Testing event i915_gem_ring_flush: OK
[   56.577877] Testing event i915_gem_request_add: OK
[   56.599125] Testing event i915_gem_request_complete: OK
[   56.618754] Testing event i915_gem_request_retire: OK
[   56.638978] Testing event i915_gem_request_wait_begin: OK
[   56.658700] Testing event i915_gem_request_wait_end: OK
[   56.679158] Testing event i915_ring_wait_begin: OK
[   56.697896] Testing event i915_ring_wait_end: OK
[   56.719028] Testing event i915_flip_request: OK
[   56.738763] Testing event i915_flip_complete: OK
[   56.758657] Testing event i915_reg_rw: OK
[   56.777859] Testing event radeon_bo_create: OK
[   56.799469] Testing event radeon_fence_emit: OK
[   56.817968] Testing event radeon_fence_retire: OK
[   56.838168] Testing event radeon_fence_wait_begin: OK
[   56.859058] Testing event radeon_fence_wait_end: OK
[   56.878007] Testing event drm_vblank_event: OK
[   56.899237] Testing event drm_vblank_event_queued: OK
[   56.918759] Testing event drm_vblank_event_delivered: OK
[   56.938713] Testing event regulator_enable: OK
[   56.958775] Testing event regulator_enable_delay: OK
[   56.978672] Testing event regulator_enable_complete: OK
[   56.998173] Testing event regulator_disable: OK
[   57.018708] Testing event regulator_disable_complete: OK
[   57.039108] Testing event regulator_set_voltage: OK
[   57.059330] Testing event regulator_set_voltage_complete: OK
[   57.079115] Testing event gpio_direction: OK
[   57.098759] Testing event gpio_value: OK
[   57.119019] Testing event block_rq_abort: OK
[   57.138699] Testing event block_rq_requeue: OK
[   57.159172] Testing event block_rq_complete: OK
[   57.177880] Testing event block_rq_insert: OK
[   57.199124] Testing event block_rq_issue: OK
[   57.218575] Testing event block_bio_bounce: OK
[   57.238949] Testing event block_bio_complete: OK
[   57.259282] Testing event block_bio_backmerge: OK
[   57.279197] Testing event block_bio_frontmerge: OK
[   57.297901] Testing event block_bio_queue: OK
[   57.319101] Testing event block_getrq: OK
[   57.338784] Testing event block_sleeprq: OK
[   57.359047] Testing event block_plug: OK
[   57.377861] Testing event block_unplug: OK
[   57.399270] Testing event block_split: OK
[   57.417923] Testing event block_bio_remap: OK
[   57.439099] Testing event block_rq_remap: OK
[   57.458739] Testing event gfs2_glock_state_change: OK
[   57.478897] Testing event gfs2_glock_put: OK
[   57.498694] Testing event gfs2_demote_rq: OK
[   57.519153] Testing event gfs2_promote: OK
[   57.537899] Testing event gfs2_glock_queue: OK
[   57.557912] Testing event gfs2_glock_lock_time: OK
[   57.577880] Testing event gfs2_pin: OK
[   57.599379] Testing event gfs2_log_flush: OK
[   57.618113] Testing event gfs2_log_blocks: OK
[   57.638745] Testing event gfs2_ail_flush: OK
[   57.658708] Testing event gfs2_bmap: OK
[   57.678773] Testing event gfs2_block_alloc: OK
[   57.697927] Testing event btrfs_transaction_commit: OK
[   57.718751] Testing event btrfs_inode_new: OK
[   57.737855] Testing event btrfs_inode_request: OK
[   57.758749] Testing event btrfs_inode_evict: OK
[   57.779455] Testing event btrfs_get_extent: OK
[   57.798198] Testing event btrfs_ordered_extent_add: OK
[   57.818868] Testing event btrfs_ordered_extent_remove: OK
[   57.838917] Testing event btrfs_ordered_extent_start: OK
[   57.859219] Testing event btrfs_ordered_extent_put: OK
[   57.879153] Testing event __extent_writepage: OK
[   57.897862] Testing event btrfs_writepage_end_io_hook: OK
[   57.919429] Testing event btrfs_sync_file: OK
[   57.938274] Testing event btrfs_sync_fs: OK
[   57.957981] Testing event btrfs_delayed_tree_ref: OK
[   57.979504] Testing event btrfs_delayed_data_ref: OK
[   58.006320] Testing event btrfs_delayed_ref_head: OK
[   58.026334] Testing event btrfs_chunk_alloc: OK
[   58.036266] vhci_hcd: changed 0
[   58.046175] Testing event btrfs_chunk_free: OK
[   58.066091] Testing event btrfs_cow_block: OK
[   58.085977] Testing event btrfs_space_reservation: OK
[   58.105975] Testing event btrfs_reserved_extent_alloc: OK
[   58.125960] Testing event btrfs_reserved_extent_free: OK
[   58.145900] Testing event find_free_extent: OK
[   58.167435] Testing event btrfs_reserve_extent: OK
[   58.186353] Testing event btrfs_reserve_extent_cluster: OK
[   58.206001] Testing event btrfs_find_cluster: OK
[   58.226025] Testing event btrfs_failed_cluster_setup: OK
[   58.246182] Testing event btrfs_setup_cluster: OK
[   58.265769] Testing event alloc_extent_state: OK
[   58.286748] Testing event free_extent_state: OK
[   58.307108] Testing event ocfs2_adjust_rightmost_branch: OK
[   58.326930] Testing event ocfs2_rotate_tree_right: OK
[   58.345892] Testing event ocfs2_append_rec_to_path: OK
[   58.366380] Testing event ocfs2_insert_extent_start: OK
[   58.387099] Testing event ocfs2_add_clusters_in_btree: OK
[   58.406777] Testing event ocfs2_num_free_extents: OK
[   58.426890] Testing event ocfs2_complete_edge_insert: OK
[   58.446726] Testing event ocfs2_grow_tree: OK
[   58.466114] Testing event ocfs2_rotate_subtree: OK
[   58.486165] Testing event ocfs2_insert_extent: OK
[   58.507376] Testing event ocfs2_split_extent: OK
[   58.526463] Testing event ocfs2_remove_extent: OK
[   58.545885] Testing event ocfs2_commit_truncate: OK
[   58.566376] Testing event ocfs2_validate_extent_block: OK
[   58.586202] Testing event ocfs2_rotate_leaf: OK
[   58.606084] Testing event ocfs2_add_clusters_in_btree_ret: OK
[   58.626373] Testing event ocfs2_mark_extent_written: OK
[   58.646332] Testing event ocfs2_truncate_log_append: OK
[   58.665885] Testing event ocfs2_replay_truncate_records: OK
[   58.686014] Testing event ocfs2_flush_truncate_log: OK
[   58.706072] Testing event ocfs2_begin_truncate_log_recovery: OK
[   58.726408] Testing event ocfs2_truncate_log_recovery_num: OK
[   58.746361] Testing event ocfs2_complete_truncate_log_recovery: OK
[   58.766354] Testing event ocfs2_free_cached_blocks: OK
[   58.786394] Testing event ocfs2_cache_cluster_dealloc: OK
[   58.806344] Testing event ocfs2_run_deallocs: OK
[   58.825972] Testing event ocfs2_cache_block_dealloc: OK
[   58.846401] Testing event ocfs2_trim_extent: OK
[   58.865948] Testing event ocfs2_trim_group: OK
[   58.887411] Testing event ocfs2_trim_fs: OK
[   58.905912] Testing event ocfs2_la_set_sizes: OK
[   58.926925] Testing event ocfs2_alloc_should_use_local: OK
[   58.947448] Testing event ocfs2_load_local_alloc: OK
[   58.966320] Testing event ocfs2_begin_local_alloc_recovery: OK
[   58.986362] Testing event ocfs2_reserve_local_alloc_bits: OK
[   59.006451] Testing event ocfs2_local_alloc_count_bits: OK
[   59.026450] Testing event ocfs2_local_alloc_find_clear_bits_search_bitmap: OK
[   59.047076] Testing event ocfs2_local_alloc_find_clear_bits: OK
[   59.066983] Testing event ocfs2_sync_local_to_main: OK
[   59.087054] Testing event ocfs2_sync_local_to_main_free: OK
[   59.107122] Testing event ocfs2_local_alloc_new_window: OK
[   59.125959] Testing event ocfs2_local_alloc_new_window_result: OK
[   59.146750] Testing event ocfs2_update_last_group_and_inode: OK
[   59.167173] Testing event ocfs2_group_extend: OK
[   59.187194] Testing event ocfs2_group_add: OK
[   59.207035] Testing event ocfs2_validate_group_descriptor: OK
[   59.227257] Testing event ocfs2_block_group_alloc_contig: OK
[   59.247213] Testing event ocfs2_block_group_alloc_discontig: OK
[   59.267173] Testing event ocfs2_block_group_alloc: OK
[   59.286988] Testing event ocfs2_reserve_suballoc_bits_nospc: OK
[   59.307131] Testing event ocfs2_reserve_suballoc_bits_no_new_group: OK
[   59.327413] Testing event ocfs2_reserve_new_inode_new_group: OK
[   59.346301] Testing event ocfs2_block_group_set_bits: OK
[   59.366820] Testing event ocfs2_relink_block_group: OK
[   59.386189] Testing event ocfs2_cluster_group_search_wrong_max_bits: OK
[   59.406774] Testing event ocfs2_cluster_group_search_max_block: OK
[   59.426164] Testing event ocfs2_block_group_search_max_block: OK
[   59.446225] Testing event ocfs2_search_chain_begin: OK
[   59.466732] Testing event ocfs2_search_chain_succ: OK
[   59.486577] Testing event ocfs2_search_chain_end: OK
[   59.505852] Testing event ocfs2_claim_suballoc_bits: OK
[   59.526829] Testing event ocfs2_claim_new_inode_at_loc: OK
[   59.545824] Testing event ocfs2_block_group_clear_bits: OK
[   59.566005] Testing event ocfs2_free_suballoc_bits: OK
[   59.587516] Testing event ocfs2_free_clusters: OK
[   59.606392] Testing event ocfs2_get_suballoc_slot_bit: OK
[   59.626264] Testing event ocfs2_test_suballoc_bit: OK
[   59.646356] Testing event ocfs2_test_inode_bit: OK
[   59.666142] Testing event ocfs2_validate_refcount_block: OK
[   59.686357] Testing event ocfs2_purge_refcount_trees: OK
[   59.706171] Testing event ocfs2_create_refcount_tree: OK
[   59.726435] Testing event ocfs2_create_refcount_tree_blkno: OK
[   59.746078] Testing event ocfs2_change_refcount_rec: OK
[   59.766233] Testing event ocfs2_expand_inline_ref_root: OK
[   59.786282] Testing event ocfs2_divide_leaf_refcount_block: OK
[   59.805935] Testing event ocfs2_new_leaf_refcount_block: OK
[   59.826227] Testing event ocfs2_insert_refcount_rec: OK
[   59.846353] Testing event ocfs2_split_refcount_rec: OK
[   59.866168] Testing event ocfs2_split_refcount_rec_insert: OK
[   59.886439] Testing event ocfs2_increase_refcount_begin: OK
[   59.906181] Testing event ocfs2_increase_refcount_change: OK
[   59.926119] Testing event ocfs2_increase_refcount_insert: OK
[   59.946302] Testing event ocfs2_increase_refcount_split: OK
[   59.966814] Testing event ocfs2_remove_refcount_extent: OK
[   59.987113] Testing event ocfs2_restore_refcount_block: OK
[   60.006723] Testing event ocfs2_decrease_refcount_rec: OK
[   60.026185] Testing event ocfs2_decrease_refcount: OK
[   60.045845] Testing event ocfs2_mark_extent_refcounted: OK
[   60.067089] Testing event ocfs2_calc_refcount_meta_credits: OK
[   60.086761] Testing event ocfs2_calc_refcount_meta_credits_iterate: OK
[   60.105926] Testing event ocfs2_add_refcount_flag: OK
[   60.126999] Testing event ocfs2_prepare_refcount_change_for_del: OK
[   60.145891] Testing event ocfs2_lock_refcount_allocators: OK
[   60.166819] Testing event ocfs2_duplicate_clusters_by_page: OK
[   60.187335] Testing event ocfs2_duplicate_clusters_by_jbd: OK
[   60.206810] Testing event ocfs2_clear_ext_refcount: OK
[   60.226860] Testing event ocfs2_replace_clusters: OK
[   60.246747] Testing event ocfs2_make_clusters_writable: OK
[   60.267241] Testing event ocfs2_refcount_cow_hunk: OK
[   60.286504] Testing event ocfs2_symlink_get_block: OK
[   60.307392] Testing event ocfs2_get_block: OK
[   60.326415] Testing event ocfs2_get_block_end: OK
[   60.345895] Testing event ocfs2_readpage: OK
[   60.367127] Testing event ocfs2_writepage: OK
[   60.386737] Testing event ocfs2_bmap: OK
[   60.407067] Testing event ocfs2_try_to_write_inline_data: OK
[   60.426019] Testing event ocfs2_write_begin_nolock: OK
[   60.447110] Testing event ocfs2_write_end_inline: OK
[   60.465931] Testing event ocfs2_fault: OK
[   60.487064] Testing event ocfs2_file_open: OK
[   60.506730] Testing event ocfs2_file_release: OK
[   60.526996] Testing event ocfs2_sync_file: OK
[   60.547151] Testing event ocfs2_file_aio_write: OK
[   60.570179] Testing event ocfs2_file_splice_write: OK
[   60.590225] Testing event ocfs2_file_splice_read: OK
[   60.610200] Testing event ocfs2_file_aio_read: OK
[   60.630277] Testing event ocfs2_truncate_file: OK
[   60.650156] Testing event ocfs2_truncate_file_error: OK
[   60.670352] Testing event ocfs2_extend_allocation: OK
[   60.690282] Testing event ocfs2_extend_allocation_end: OK
[   60.710212] Testing event ocfs2_write_zero_page: OK
[   60.730273] Testing event ocfs2_zero_extend_range: OK
[   60.750183] Testing event ocfs2_zero_extend: OK
[   60.771385] Testing event ocfs2_setattr: OK
[   60.794739] Testing event ocfs2_write_remove_suid: OK
[   60.808242] vhci_hcd: changed 0
[   60.818814] Testing event ocfs2_zero_partial_clusters: OK
[   60.837989] Testing event ocfs2_zero_partial_clusters_range1: OK
[   60.857870] Testing event ocfs2_zero_partial_clusters_range2: OK
[   60.878835] Testing event ocfs2_remove_inode_range: OK
[   60.897871] Testing event ocfs2_prepare_inode_for_write: OK
[   60.918769] Testing event generic_file_aio_read_ret: OK
[   60.939114] Testing event ocfs2_iget_begin: OK
[   60.958242] Testing event ocfs2_iget5_locked: OK
[   60.979089] Testing event ocfs2_iget_end: OK
[   60.998706] Testing event ocfs2_find_actor: OK
[   61.017905] Testing event ocfs2_populate_inode: OK
[   61.038755] Testing event ocfs2_read_locked_inode: OK
[   61.057780] Testing event ocfs2_check_orphan_recovery_state: OK
[   61.078018] Testing event ocfs2_validate_inode_block: OK
[   61.099233] Testing event ocfs2_inode_is_valid_to_delete: OK
[   61.118764] Testing event ocfs2_query_inode_wipe_begin: OK
[   61.138687] Testing event ocfs2_query_inode_wipe_succ: OK
[   61.158742] Testing event ocfs2_query_inode_wipe_end: OK
[   61.179452] Testing event ocfs2_cleanup_delete_inode: OK
[   61.198086] Testing event ocfs2_delete_inode: OK
[   61.218351] Testing event ocfs2_clear_inode: OK
[   61.238348] Testing event ocfs2_drop_inode: OK
[   61.257872] Testing event ocfs2_inode_revalidate: OK
[   61.278746] Testing event ocfs2_mark_inode_dirty: OK
[   61.299092] Testing event ocfs2_read_virt_blocks: OK
[   61.318210] Testing event ocfs2_refresh_slot_info: OK
[   61.337890] Testing event ocfs2_map_slot_buffers: OK
[   61.359113] Testing event ocfs2_map_slot_buffers_block: OK
[   61.378960] Testing event ocfs2_find_slot: OK
[   61.399255] Testing event ocfs2_do_node_down: OK
[   61.419124] Testing event ocfs2_remount: OK
[   61.437982] Testing event ocfs2_fill_super: OK
[   61.458717] Testing event ocfs2_parse_options: OK
[   61.479028] Testing event ocfs2_put_super: OK
[   61.497879] Testing event ocfs2_statfs: OK
[   61.518782] Testing event ocfs2_dismount_volume: OK
[   61.539060] Testing event ocfs2_initialize_super: OK
[   61.558230] Testing event ocfs2_validate_xattr_block: OK
[   61.587185] Testing event ocfs2_xattr_extend_allocation: OK
[   61.606245] Testing event ocfs2_init_xattr_set_ctxt: OK
[   61.626825] Testing event ocfs2_xattr_bucket_find: OK
[   61.646337] Testing event ocfs2_xattr_index_block_find: OK
[   61.665774] Testing event ocfs2_xattr_index_block_find_rec: OK
[   61.685934] Testing event ocfs2_iterate_xattr_buckets: OK
[   61.707155] Testing event ocfs2_iterate_xattr_bucket: OK
[   61.726478] Testing event ocfs2_cp_xattr_block_to_bucket_begin: OK
[   61.747175] Testing event ocfs2_cp_xattr_block_to_bucket_end: OK
[   61.766166] Testing event ocfs2_xattr_create_index_block_begin: OK
[   61.786104] Testing event ocfs2_xattr_create_index_block: OK
[   61.805962] Testing event ocfs2_defrag_xattr_bucket: OK
[   61.827282] Testing event ocfs2_mv_xattr_bucket_cross_cluster: OK
[   61.847146] Testing event ocfs2_divide_xattr_bucket_begin: OK
[   61.870132] Testing event ocfs2_divide_xattr_bucket_move: OK
[   61.890259] Testing event ocfs2_cp_xattr_bucket: OK
[   61.910286] Testing event ocfs2_mv_xattr_buckets: OK
[   61.930230] Testing event ocfs2_adjust_xattr_cross_cluster: OK
[   61.950265] Testing event ocfs2_add_new_xattr_cluster_begin: OK
[   61.970135] Testing event ocfs2_add_new_xattr_cluster: OK
[   61.990325] Testing event ocfs2_add_new_xattr_cluster_insert: OK
[   62.010289] Testing event ocfs2_extend_xattr_bucket: OK
[   62.030182] Testing event ocfs2_add_new_xattr_bucket: OK
[   62.050236] Testing event ocfs2_xattr_bucket_value_truncate: OK
[   62.070267] Testing event ocfs2_rm_xattr_cluster: OK
[   62.090228] Testing event ocfs2_reflink_xattr_header: OK
[   62.110322] Testing event ocfs2_create_empty_xattr_block: OK
[   62.130287] Testing event ocfs2_xattr_set_entry_bucket: OK
[   62.150319] Testing event ocfs2_xattr_set_entry_index_block: OK
[   62.170116] Testing event ocfs2_xattr_bucket_value_refcount: OK
[   62.190302] Testing event ocfs2_reflink_xattr_buckets: OK
[   62.210296] Testing event ocfs2_reflink_xattr_rec: OK
[   62.230195] Testing event ocfs2_resv_insert: OK
[   62.250299] Testing event ocfs2_resmap_find_free_bits_begin: OK
[   62.270332] Testing event ocfs2_resmap_find_free_bits_end: OK
[   62.290265] Testing event ocfs2_resv_find_window_begin: OK
[   62.310294] Testing event ocfs2_resv_find_window_prev: OK
[   62.330280] Testing event ocfs2_resv_find_window_next: OK
[   62.350314] Testing event ocfs2_cannibalize_resv_begin: OK
[   62.370350] Testing event ocfs2_cannibalize_resv_end: OK
[   62.390019] Testing event ocfs2_resmap_resv_bits: OK
[   62.409985] Testing event ocfs2_resmap_claimed_bits_begin: OK
[   62.429920] Testing event ocfs2_resmap_claimed_bits_end: OK
[   62.450137] Testing event ocfs2_recover_local_quota_file: OK
[   62.470328] Testing event ocfs2_finish_quota_recovery: OK
[   62.490286] Testing event olq_set_dquot: OK
[   62.510050] Testing event ocfs2_validate_quota_block: OK
[   62.530290] Testing event ocfs2_sync_dquot: OK
[   62.550307] Testing event ocfs2_sync_dquot_helper: OK
[   62.570113] Testing event ocfs2_write_dquot: OK
[   62.589930] Testing event ocfs2_release_dquot: OK
[   62.610275] Testing event ocfs2_acquire_dquot: OK
[   62.630198] Testing event ocfs2_mark_dquot_dirty: OK
[   62.650311] Testing event ocfs2_search_dirblock: OK
[   62.670407] Testing event ocfs2_validate_dir_block: OK
[   62.690290] Testing event ocfs2_find_entry_el: OK
[   62.710072] Testing event ocfs2_dx_dir_search: OK
[   62.730317] Testing event ocfs2_dx_dir_search_leaf_info: OK
[   62.750306] Testing event ocfs2_delete_entry_dx: OK
[   62.770191] Testing event ocfs2_readdir: OK
[   62.790280] Testing event ocfs2_find_files_on_disk: OK
[   62.810121] Testing event ocfs2_check_dir_for_entry: OK
[   62.824398] vhci_hcd: changed 0
[   62.831256] Testing event ocfs2_dx_dir_attach_index: OK
[   62.854425] Testing event ocfs2_dx_dir_format_cluster: OK
[   62.879311] Testing event ocfs2_dx_dir_index_root_block: OK
[   62.897889] Testing event ocfs2_extend_dir: OK
[   62.918105] Testing event ocfs2_dx_dir_rebalance: OK
[   62.939100] Testing event ocfs2_dx_dir_rebalance_split: OK
[   62.958784] Testing event ocfs2_prepare_dir_for_insert: OK
[   62.979496] Testing event ocfs2_lookup: OK
[   62.998044] Testing event ocfs2_mkdir: OK
[   63.019027] Testing event ocfs2_create: OK
[   63.039327] Testing event ocfs2_unlink: OK
[   63.058128] Testing event ocfs2_symlink_create: OK
[   63.078619] Testing event ocfs2_mv_orphaned_inode_to_new: OK
[   63.098301] Testing event ocfs2_lookup_ret: OK
[   63.119190] Testing event ocfs2_mknod: OK
[   63.139178] Testing event ocfs2_link: OK
[   63.159113] Testing event ocfs2_unlink_noent: OK
[   63.179488] Testing event ocfs2_double_lock: OK
[   63.198372] Testing event ocfs2_double_lock_end: OK
[   63.219206] Testing event ocfs2_rename: OK
[   63.238340] Testing event ocfs2_rename_target_exists: OK
[   63.259249] Testing event ocfs2_rename_disagree: OK
[   63.277949] Testing event ocfs2_rename_over_existing: OK
[   63.299031] Testing event ocfs2_create_symlink_data: OK
[   63.317977] Testing event ocfs2_symlink_begin: OK
[   63.338851] Testing event ocfs2_blkno_stringify: OK
[   63.357939] Testing event ocfs2_orphan_add_begin: OK
[   63.379463] Testing event ocfs2_orphan_add_end: OK
[   63.397933] Testing event ocfs2_orphan_del: OK
[   63.419036] Testing event ocfs2_dentry_revalidate: OK
[   63.438515] Testing event ocfs2_dentry_revalidate_negative: OK
[   63.458591] Testing event ocfs2_dentry_revalidate_delete: OK
[   63.477952] Testing event ocfs2_dentry_revalidate_orphaned: OK
[   63.498834] Testing event ocfs2_dentry_revalidate_nofsdata: OK
[   63.518707] Testing event ocfs2_dentry_revalidate_ret: OK
[   63.538619] Testing event ocfs2_find_local_alias: OK
[   63.557983] Testing event ocfs2_dentry_attach_lock: OK
[   63.579289] Testing event ocfs2_dentry_attach_lock_found: OK
[   63.598000] Testing event ocfs2_get_dentry_begin: OK
[   63.618626] Testing event ocfs2_get_dentry_test_bit: OK
[   63.638445] Testing event ocfs2_get_dentry_stale: OK
[   63.658641] Testing event ocfs2_get_dentry_generation: OK
[   63.678273] Testing event ocfs2_get_dentry_end: OK
[   63.697861] Testing event ocfs2_get_parent: OK
[   63.717926] Testing event ocfs2_get_parent_end: OK
[   63.739052] Testing event ocfs2_encode_fh_begin: OK
[   63.757870] Testing event ocfs2_encode_fh_self: OK
[   63.778654] Testing event ocfs2_encode_fh_parent: OK
[   63.798307] Testing event ocfs2_encode_fh_type: OK
[   63.818507] Testing event ocfs2_commit_cache_begin: OK
[   63.838015] Testing event ocfs2_commit_cache_end: OK
[   63.858620] Testing event ocfs2_extend_trans: OK
[   63.879032] Testing event ocfs2_extend_trans_restart: OK
[   63.898248] Testing event ocfs2_journal_access: OK
[   63.918811] Testing event ocfs2_journal_dirty: OK
[   63.938590] Testing event ocfs2_journal_init: OK
[   63.958301] Testing event ocfs2_journal_init_maxlen: OK
[   63.977893] Testing event ocfs2_journal_shutdown: OK
[   63.998776] Testing event ocfs2_journal_shutdown_wait: OK
[   64.018642] Testing event ocfs2_complete_recovery: OK
[   64.038317] Testing event ocfs2_complete_recovery_end: OK
[   64.057858] Testing event ocfs2_complete_recovery_slot: OK
[   64.077941] Testing event ocfs2_recovery_thread_node: OK
[   64.099040] Testing event ocfs2_recovery_thread_end: OK
[   64.117990] Testing event ocfs2_recovery_thread: OK
[   64.138694] Testing event ocfs2_replay_journal_recovered: OK
[   64.157956] Testing event ocfs2_replay_journal_lock_err: OK
[   64.179402] Testing event ocfs2_replay_journal_skip: OK
[   64.198390] Testing event ocfs2_recover_node: OK
[   64.219111] Testing event ocfs2_recover_node_skip: OK
[   64.239095] Testing event ocfs2_mark_dead_nodes: OK
[   64.259217] Testing event ocfs2_queue_orphan_scan_begin: OK
[   64.279471] Testing event ocfs2_queue_orphan_scan_end: OK
[   64.298253] Testing event ocfs2_orphan_filldir: OK
[   64.317976] Testing event ocfs2_recover_orphans: OK
[   64.338629] Testing event ocfs2_recover_orphans_iput: OK
[   64.359078] Testing event ocfs2_wait_on_mount: OK
[   64.378087] Testing event ocfs2_read_blocks_sync: OK
[   64.398381] Testing event ocfs2_read_blocks_sync_jbd: OK
[   64.418557] Testing event ocfs2_read_blocks_from_disk: OK
[   64.438443] Testing event ocfs2_read_blocks_bh: OK
[   64.459195] Testing event ocfs2_read_blocks_end: OK
[   64.478744] Testing event ocfs2_write_block: OK
[   64.498628] Testing event ocfs2_read_blocks_begin: OK
[   64.517942] Testing event ocfs2_purge_copied_metadata_tree: OK
[   64.539104] Testing event ocfs2_metadata_cache_purge: OK
[   64.557996] Testing event ocfs2_buffer_cached_begin: OK
[   64.578616] Testing event ocfs2_buffer_cached_end: OK
[   64.598251] Testing event ocfs2_append_cache_array: OK
[   64.619166] Testing event ocfs2_insert_cache_tree: OK
[   64.637973] Testing event ocfs2_expand_cache: OK
[   64.658605] Testing event ocfs2_set_buffer_uptodate: OK
[   64.677933] Testing event ocfs2_set_buffer_uptodate_begin: OK
[   64.699090] Testing event ocfs2_remove_metadata_array: OK
[   64.717959] Testing event ocfs2_remove_metadata_tree: OK
[   64.738651] Testing event ocfs2_remove_block_from_cache: OK
[   64.757942] Testing event xfs_attr_list_sf: OK
[   64.779274] Testing event xfs_attr_list_sf_all: OK
[   64.798294] Testing event xfs_attr_list_leaf: OK
[   64.819471] Testing event xfs_attr_list_leaf_end: OK
[   64.837943] Testing event xfs_attr_list_full: OK
[   64.840672] vhci_hcd: changed 0
[   64.858893] Testing event xfs_attr_list_add: OK
[   64.878112] Testing event xfs_attr_list_wrong_blk: OK
[   64.899125] Testing event xfs_attr_list_notfound: OK
[   64.919168] Testing event xfs_perag_get: OK
[   64.939000] Testing event xfs_perag_get_tag: OK
[   64.958568] Testing event xfs_perag_put: OK
[   64.979062] Testing event xfs_perag_set_reclaim: OK
[   64.998892] Testing event xfs_perag_clear_reclaim: OK
[   65.019257] Testing event xfs_attr_list_node_descend: OK
[   65.039177] Testing event xfs_iext_insert: OK
[   65.059164] Testing event xfs_iext_remove: OK
[   65.078599] Testing event xfs_bmap_pre_update: OK
[   65.099066] Testing event xfs_bmap_post_update: OK
[   65.119199] Testing event xfs_extlist: OK
[   65.139210] Testing event xfs_buf_init: OK
[   65.166872] Testing event xfs_buf_free: OK
[   65.186695] Testing event xfs_buf_hold: OK
[   65.206714] Testing event xfs_buf_rele: OK
[   65.226512] Testing event xfs_buf_iodone: OK
[   65.246720] Testing event xfs_buf_iorequest: OK
[   65.267508] Testing event xfs_buf_bawrite: OK
[   65.286058] Testing event xfs_buf_lock: OK
[   65.306845] Testing event xfs_buf_lock_done: OK
[   65.327236] Testing event xfs_buf_trylock: OK
[   65.346674] Testing event xfs_buf_unlock: OK
[   65.365965] Testing event xfs_buf_iowait: OK
[   65.385898] Testing event xfs_buf_iowait_done: OK
[   65.406607] Testing event xfs_buf_delwri_queue: OK
[   65.426008] Testing event xfs_buf_delwri_queued: OK
[   65.447035] Testing event xfs_buf_delwri_split: OK
[   65.466677] Testing event xfs_buf_get_uncached: OK
[   65.486986] Testing event xfs_bdstrat_shut: OK
[   65.506811] Testing event xfs_buf_item_relse: OK
[   65.527129] Testing event xfs_buf_item_iodone: OK
[   65.546880] Testing event xfs_buf_item_iodone_async: OK
[   65.566077] Testing event xfs_buf_error_relse: OK
[   65.587457] Testing event xfs_trans_read_buf_io: OK
[   65.611644] Testing event xfs_trans_read_buf_shut: OK
[   65.639087] Testing event xfs_btree_corrupt: OK
[   65.658592] Testing event xfs_da_btree_corrupt: OK
[   65.677921] Testing event xfs_reset_dqcounts: OK
[   65.697887] Testing event xfs_inode_item_push: OK
[   65.719228] Testing event xfs_buf_find: OK
[   65.738829] Testing event xfs_buf_get: OK
[   65.759290] Testing event xfs_buf_read: OK
[   65.779402] Testing event xfs_buf_ioerror: OK
[   65.798196] Testing event xfs_buf_item_size: OK
[   65.817905] Testing event xfs_buf_item_size_stale: OK
[   65.839169] Testing event xfs_buf_item_format: OK
[   65.857959] Testing event xfs_buf_item_format_stale: OK
[   65.877877] Testing event xfs_buf_item_pin: OK
[   65.897852] Testing event xfs_buf_item_unpin: OK
[   65.919010] Testing event xfs_buf_item_unpin_stale: OK
[   65.938843] Testing event xfs_buf_item_unlock: OK
[   65.957943] Testing event xfs_buf_item_unlock_stale: OK
[   65.979606] Testing event xfs_buf_item_committed: OK
[   65.997914] Testing event xfs_buf_item_push: OK
[   66.018724] Testing event xfs_trans_get_buf: OK
[   66.039032] Testing event xfs_trans_get_buf_recur: OK
[   66.058812] Testing event xfs_trans_getsb: OK
[   66.077891] Testing event xfs_trans_getsb_recur: OK
[   66.097909] Testing event xfs_trans_read_buf: OK
[   66.117900] Testing event xfs_trans_read_buf_recur: OK
[   66.137880] Testing event xfs_trans_log_buf: OK
[   66.159005] Testing event xfs_trans_brelse: OK
[   66.178899] Testing event xfs_trans_bjoin: OK
[   66.197925] Testing event xfs_trans_bhold: OK
[   66.218851] Testing event xfs_trans_bhold_release: OK
[   66.237934] Testing event xfs_trans_binval: OK
[   66.257871] Testing event xfs_ilock: OK
[   66.277919] Testing event xfs_ilock_nowait: OK
[   66.297890] Testing event xfs_ilock_demote: OK
[   66.319201] Testing event xfs_iunlock: OK
[   66.338853] Testing event xfs_iget_skip: OK
[   66.359177] Testing event xfs_iget_reclaim: OK
[   66.379376] Testing event xfs_iget_reclaim_fail: OK
[   66.398296] Testing event xfs_iget_hit: OK
[   66.417873] Testing event xfs_iget_miss: OK
[   66.439175] Testing event xfs_getattr: OK
[   66.458688] Testing event xfs_setattr: OK
[   66.477879] Testing event xfs_readlink: OK
[   66.497858] Testing event xfs_alloc_file_space: OK
[   66.519048] Testing event xfs_free_file_space: OK
[   66.538841] Testing event xfs_readdir: OK
[   66.559197] Testing event xfs_get_acl: OK
[   66.579538] Testing event xfs_vm_bmap: OK
[   66.597951] Testing event xfs_file_ioctl: OK
[   66.617891] Testing event xfs_file_compat_ioctl: OK
[   66.638657] Testing event xfs_ioctl_setattr: OK
[   66.658812] Testing event xfs_dir_fsync: OK
[   66.677824] Testing event xfs_file_fsync: OK
[   66.697924] Testing event xfs_destroy_inode: OK
[   66.717879] Testing event xfs_dirty_inode: OK
[   66.738690] Testing event xfs_evict_inode: OK
[   66.759040] Testing event xfs_dquot_dqalloc: OK
[   66.779468] Testing event xfs_dquot_dqdetach: OK
[   66.797906] Testing event xfs_ihold: OK
[   66.818826] Testing event xfs_irele: OK
[   66.838146] Testing event xfs_inode_pin: OK
[   66.856211] vhci_hcd: changed 0
[   66.858104] Testing event xfs_inode_unpin: OK
[   66.877942] Testing event xfs_inode_unpin_nowait: OK
[   66.899253] Testing event xfs_remove: OK
[   66.918893] Testing event xfs_link: OK
[   66.939320] Testing event xfs_lookup: OK
[   66.958927] Testing event xfs_create: OK
[   66.979433] Testing event xfs_symlink: OK
[   66.998398] Testing event xfs_rename: OK
[   67.018059] Testing event xfs_dqadjust: OK
[   67.039146] Testing event xfs_dqreclaim_want: OK
[   67.058835] Testing event xfs_dqreclaim_dirty: OK
[   67.079159] Testing event xfs_dqreclaim_busy: OK
[   67.098642] Testing event xfs_dqreclaim_done: OK
[   67.117881] Testing event xfs_dqattach_found: OK
[   67.137869] Testing event xfs_dqattach_get: OK
[   67.159037] Testing event xfs_dqalloc: OK
[   67.177980] Testing event xfs_dqtobp_read: OK
[   67.199012] Testing event xfs_dqread: OK
[   67.218651] Testing event xfs_dqread_fail: OK
[   67.237864] Testing event xfs_dqget_hit: OK
[   67.257890] Testing event xfs_dqget_miss: OK
[   67.277869] Testing event xfs_dqget_freeing: OK
[   67.297860] Testing event xfs_dqget_dup: OK
[   67.319042] Testing event xfs_dqput: OK
[   67.337941] Testing event xfs_dqput_wait: OK
[   67.359045] Testing event xfs_dqput_free: OK
[   67.377929] Testing event xfs_dqrele: OK
[   67.399508] Testing event xfs_dqflush: OK
[   67.418103] Testing event xfs_dqflush_force: OK
[   67.438827] Testing event xfs_dqflush_done: OK
[   67.459123] Testing event xfs_log_done_nonperm: OK
[   67.479355] Testing event xfs_log_done_perm: OK
[   67.497851] Testing event xfs_log_umount_write: OK
[   67.519145] Testing event xfs_log_grant_sleep: OK
[   67.537897] Testing event xfs_log_grant_wake: OK
[   67.559162] Testing event xfs_log_grant_wake_up: OK
[   67.579349] Testing event xfs_log_reserve: OK
[   67.597937] Testing event xfs_log_reserve_exit: OK
[   67.618761] Testing event xfs_log_regrant: OK
[   67.639139] Testing event xfs_log_regrant_exit: OK
[   67.657947] Testing event xfs_log_regrant_reserve_enter: OK
[   67.677886] Testing event xfs_log_regrant_reserve_exit: OK
[   67.697877] Testing event xfs_log_regrant_reserve_sub: OK
[   67.719134] Testing event xfs_log_ungrant_enter: OK
[   67.738785] Testing event xfs_log_ungrant_exit: OK
[   67.758676] Testing event xfs_log_ungrant_sub: OK
[   67.779562] Testing event xfs_log_force: OK
[   67.798752] Testing event xfs_ail_push: OK
[   67.818842] Testing event xfs_ail_pinned: OK
[   67.837918] Testing event xfs_ail_locked: OK
[   67.857885] Testing event xfs_ail_flushing: OK
[   67.877907] Testing event xfs_file_read: OK
[   67.898948] Testing event xfs_file_buffered_write: OK
[   67.919058] Testing event xfs_file_direct_write: OK
[   67.938637] Testing event xfs_file_splice_read: OK
[   67.958719] Testing event xfs_file_splice_write: OK
[   67.978824] Testing event xfs_writepage: OK
[   67.999222] Testing event xfs_releasepage: OK
[   68.018700] Testing event xfs_invalidatepage: OK
[   68.037887] Testing event xfs_map_blocks_found: OK
[   68.058912] Testing event xfs_map_blocks_alloc: OK
[   68.078966] Testing event xfs_get_blocks_found: OK
[   68.098831] Testing event xfs_get_blocks_alloc: OK
[   68.119171] Testing event xfs_delalloc_enospc: OK
[   68.138015] Testing event xfs_unwritten_convert: OK
[   68.159532] Testing event xfs_get_blocks_notfound: OK
[   68.178100] Testing event xfs_setfilesize: OK
[   68.199448] Testing event xfs_itruncate_extents_start: OK
[   68.218138] Testing event xfs_itruncate_extents_end: OK
[   68.239176] Testing event xfs_pagecache_inval: OK
[   68.257914] Testing event xfs_bunmap: OK
[   68.277883] Testing event xfs_extent_busy: OK
[   68.297904] Testing event xfs_extent_busy_enomem: OK
[   68.319136] Testing event xfs_extent_busy_force: OK
[   68.338731] Testing event xfs_extent_busy_reuse: OK
[   68.357908] Testing event xfs_extent_busy_clear: OK
[   68.377874] Testing event xfs_extent_busy_trim: OK
[   68.397893] Testing event xfs_trans_commit_lsn: OK
[   68.418833] Testing event xfs_agf: OK
[   68.437885] Testing event xfs_free_extent: OK
[   68.458913] Testing event xfs_alloc_exact_done: OK
[   68.477884] Testing event xfs_alloc_exact_notfound: OK
[   68.497876] Testing event xfs_alloc_exact_error: OK
[   68.517892] Testing event xfs_alloc_near_nominleft: OK
[   68.537853] Testing event xfs_alloc_near_first: OK
[   68.559042] Testing event xfs_alloc_near_greater: OK
[   68.579491] Testing event xfs_alloc_near_lesser: OK
[   68.597911] Testing event xfs_alloc_near_error: OK
[   68.617861] Testing event xfs_alloc_near_noentry: OK
[   68.639116] Testing event xfs_alloc_near_busy: OK
[   68.657862] Testing event xfs_alloc_size_neither: OK
[   68.679024] Testing event xfs_alloc_size_noentry: OK
[   68.698832] Testing event xfs_alloc_size_nominleft: OK
[   68.719214] Testing event xfs_alloc_size_done: OK
[   68.737954] Testing event xfs_alloc_size_error: OK
[   68.767185] Testing event xfs_alloc_size_busy: OK
[   68.786816] Testing event xfs_alloc_small_freelist: OK
[   68.807131] Testing event xfs_alloc_small_notenough: OK
[   68.829918] Testing event xfs_alloc_small_done: OK
[   68.850186] Testing event xfs_alloc_small_error: OK
[   68.870157] Testing event xfs_alloc_vextent_badargs: OK
[   68.872664] vhci_hcd: changed 0
[   68.890243] Testing event xfs_alloc_vextent_nofix: OK
[   68.910085] Testing event xfs_alloc_vextent_noagbp: OK
[   68.929937] Testing event xfs_alloc_vextent_loopfailed: OK
[   68.950205] Testing event xfs_alloc_vextent_allfailed: OK
[   68.969938] Testing event xfs_dir2_sf_addname: OK
[   68.990200] Testing event xfs_dir2_sf_create: OK
[   69.010272] Testing event xfs_dir2_sf_lookup: OK
[   69.029941] Testing event xfs_dir2_sf_replace: OK
[   69.050305] Testing event xfs_dir2_sf_removename: OK
[   69.070016] Testing event xfs_dir2_sf_toino4: OK
[   69.089867] Testing event xfs_dir2_sf_toino8: OK
[   69.110178] Testing event xfs_dir2_sf_to_block: OK
[   69.129777] Testing event xfs_dir2_block_addname: OK
[   69.150200] Testing event xfs_dir2_block_lookup: OK
[   69.169929] Testing event xfs_dir2_block_replace: OK
[   69.189919] Testing event xfs_dir2_block_removename: OK
[   69.210234] Testing event xfs_dir2_block_to_sf: OK
[   69.230152] Testing event xfs_dir2_block_to_leaf: OK
[   69.249927] Testing event xfs_dir2_leaf_addname: OK
[   69.269955] Testing event xfs_dir2_leaf_lookup: OK
[   69.290323] Testing event xfs_dir2_leaf_replace: OK
[   69.310186] Testing event xfs_dir2_leaf_removename: OK
[   69.330167] Testing event xfs_dir2_leaf_to_block: OK
[   69.350230] Testing event xfs_dir2_leaf_to_node: OK
[   69.370105] Testing event xfs_dir2_node_addname: OK
[   69.390033] Testing event xfs_dir2_node_lookup: OK
[   69.410336] Testing event xfs_dir2_node_replace: OK
[   69.430147] Testing event xfs_dir2_node_removename: OK
[   69.450188] Testing event xfs_dir2_node_to_leaf: OK
[   69.470371] Testing event xfs_attr_sf_add: OK
[   69.489942] Testing event xfs_attr_sf_addname: OK
[   69.510175] Testing event xfs_attr_sf_create: OK
[   69.529938] Testing event xfs_attr_sf_lookup: OK
[   69.550195] Testing event xfs_attr_sf_remove: OK
[   69.570341] Testing event xfs_attr_sf_removename: OK
[   69.590193] Testing event xfs_attr_sf_to_leaf: OK
[   69.610308] Testing event xfs_attr_leaf_add: OK
[   69.630203] Testing event xfs_attr_leaf_add_old: OK
[   69.650272] Testing event xfs_attr_leaf_add_new: OK
[   69.669931] Testing event xfs_attr_leaf_addname: OK
[   69.690314] Testing event xfs_attr_leaf_create: OK
[   69.710331] Testing event xfs_attr_leaf_lookup: OK
[   69.730311] Testing event xfs_attr_leaf_replace: OK
[   69.750202] Testing event xfs_attr_leaf_removename: OK
[   69.770321] Testing event xfs_attr_leaf_split: OK
[   69.790209] Testing event xfs_attr_leaf_split_before: OK
[   69.810346] Testing event xfs_attr_leaf_split_after: OK
[   69.830336] Testing event xfs_attr_leaf_clearflag: OK
[   69.850312] Testing event xfs_attr_leaf_setflag: OK
[   69.870340] Testing event xfs_attr_leaf_flipflags: OK
[   69.890332] Testing event xfs_attr_leaf_to_sf: OK
[   69.910208] Testing event xfs_attr_leaf_to_node: OK
[   69.930329] Testing event xfs_attr_leaf_rebalance: OK
[   69.950209] Testing event xfs_attr_leaf_unbalance: OK
[   69.970351] Testing event xfs_attr_node_addname: OK
[   69.990184] Testing event xfs_attr_node_lookup: OK
[   70.010309] Testing event xfs_attr_node_replace: OK
[   70.030192] Testing event xfs_attr_node_removename: OK
[   70.050322] Testing event xfs_da_split: OK
[   70.070374] Testing event xfs_da_join: OK
[   70.090306] Testing event xfs_da_link_before: OK
[   70.110204] Testing event xfs_da_link_after: OK
[   70.130348] Testing event xfs_da_unlink_back: OK
[   70.150193] Testing event xfs_da_unlink_forward: OK
[   70.170348] Testing event xfs_da_root_split: OK
[   70.190189] Testing event xfs_da_root_join: OK
[   70.210278] Testing event xfs_da_node_add: OK
[   70.230187] Testing event xfs_da_node_create: OK
[   70.250312] Testing event xfs_da_node_split: OK
[   70.270363] Testing event xfs_da_node_remove: OK
[   70.290325] Testing event xfs_da_node_rebalance: OK
[   70.310207] Testing event xfs_da_node_unbalance: OK
[   70.330321] Testing event xfs_da_swap_lastblock: OK
[   70.350217] Testing event xfs_da_grow_inode: OK
[   70.370379] Testing event xfs_da_shrink_inode: OK
[   70.390198] Testing event xfs_dir2_leafn_add: OK
[   70.410308] Testing event xfs_dir2_leafn_remove: OK
[   70.431807] Testing event xfs_dir2_grow_inode: OK
[   70.455333] Testing event xfs_dir2_shrink_inode: OK
[   70.479188] Testing event xfs_dir2_leafn_moveents: OK
[   70.497831] Testing event xfs_swap_extent_before: OK
[   70.517900] Testing event xfs_swap_extent_after: OK
[   70.537882] Testing event xfs_log_recover_item_add: OK
[   70.559006] Testing event xfs_log_recover_item_add_cont: OK
[   70.579506] Testing event xfs_log_recover_item_reorder_head: OK
[   70.597885] Testing event xfs_log_recover_item_reorder_tail: OK
[   70.618681] Testing event xfs_log_recover_item_recover: OK
[   70.637992] Testing event xfs_log_recover_buf_not_cancel: OK
[   70.658758] Testing event xfs_log_recover_buf_cancel: OK
[   70.678690] Testing event xfs_log_recover_buf_cancel_add: OK
[   70.698069] Testing event xfs_log_recover_buf_cancel_ref_inc: OK
[   70.719166] Testing event xfs_log_recover_buf_recover: OK
[   70.737930] Testing event xfs_log_recover_buf_inode_buf: OK
[   70.759158] Testing event xfs_log_recover_buf_reg_buf: OK
[   70.779387] Testing event xfs_log_recover_buf_dquot_buf: OK
[   70.798168] Testing event xfs_log_recover_inode_recover: OK
[   70.819868] Testing event xfs_log_recover_inode_cancel: OK
[   70.839152] Testing event xfs_log_recover_inode_skip: OK
[   70.858830] Testing event xfs_discard_extent: OK
[   70.879186] Testing event xfs_discard_toosmall: OK
[   70.888253] vhci_hcd: changed 0
[   70.899409] Testing event xfs_discard_exclude: OK
[   70.917922] Testing event xfs_discard_busy: OK
[   70.937887] Testing event jbd2_checkpoint: OK
[   70.959233] Testing event jbd2_start_commit: OK
[   70.977940] Testing event jbd2_commit_locking: OK
[   70.997916] Testing event jbd2_commit_flushing: OK
[   71.017901] Testing event jbd2_commit_logging: OK
[   71.038932] Testing event jbd2_drop_transaction: OK
[   71.059159] Testing event jbd2_end_commit: OK
[   71.078637] Testing event jbd2_submit_inode_data: OK
[   71.098422] Testing event jbd2_run_stats: OK
[   71.117973] Testing event jbd2_checkpoint_stats: OK
[   71.138310] Testing event jbd2_update_log_tail: OK
[   71.158416] Testing event jbd2_write_superblock: OK
[   71.179325] Testing event jbd_checkpoint: OK
[   71.198284] Testing event jbd_start_commit: OK
[   71.218935] Testing event jbd_commit_locking: OK
[   71.237866] Testing event jbd_commit_flushing: OK
[   71.258638] Testing event jbd_commit_logging: OK
[   71.279030] Testing event jbd_drop_transaction: OK
[   71.298823] Testing event jbd_end_commit: OK
[   71.319194] Testing event jbd_do_submit_data: OK
[   71.337955] Testing event jbd_cleanup_journal_tail: OK
[   71.357899] Testing event journal_write_superblock: OK
[   71.377872] Testing event ext4_free_inode: OK
[   71.398958] Testing event ext4_request_inode: OK
[   71.418809] Testing event ext4_allocate_inode: OK
[   71.439241] Testing event ext4_evict_inode: OK
[   71.457918] Testing event ext4_drop_inode: OK
[   71.477884] Testing event ext4_mark_inode_dirty: OK
[   71.497881] Testing event ext4_begin_ordered_truncate: OK
[   71.519005] Testing event ext4_write_begin: OK
[   71.538821] Testing event ext4_da_write_begin: OK
[   71.558593] Testing event ext4_ordered_write_end: OK
[   71.579537] Testing event ext4_writeback_write_end: OK
[   71.598715] Testing event ext4_journalled_write_end: OK
[   71.618578] Testing event ext4_da_write_end: OK
[   71.637964] Testing event ext4_da_writepages: OK
[   71.658786] Testing event ext4_da_write_pages: OK
[   71.678972] Testing event ext4_da_writepages_result: OK
[   71.697952] Testing event ext4_writepage: OK
[   71.717905] Testing event ext4_readpage: OK
[   71.737871] Testing event ext4_releasepage: OK
[   71.758949] Testing event ext4_invalidatepage: OK
[   71.779452] Testing event ext4_discard_blocks: OK
[   71.797897] Testing event ext4_mb_new_inode_pa: OK
[   71.817995] Testing event ext4_mb_new_group_pa: OK
[   71.839105] Testing event ext4_mb_release_inode_pa: OK
[   71.858645] Testing event ext4_mb_release_group_pa: OK
[   71.879190] Testing event ext4_discard_preallocations: OK
[   71.898860] Testing event ext4_mb_discard_preallocations: OK
[   71.919146] Testing event ext4_request_blocks: OK
[   71.937977] Testing event ext4_allocate_blocks: OK
[   71.957894] Testing event ext4_free_blocks: OK
[   71.977904] Testing event ext4_sync_file_enter: OK
[   71.999145] Testing event ext4_sync_file_exit: OK
[   72.018781] Testing event ext4_sync_fs: OK
[   72.038431] Testing event ext4_alloc_da_blocks: OK
[   72.057856] Testing event ext4_mballoc_alloc: OK
[   72.077872] Testing event ext4_mballoc_prealloc: OK
[   72.097863] Testing event ext4_mballoc_discard: OK
[   72.119038] Testing event ext4_mballoc_free: OK
[   72.138836] Testing event ext4_forget: OK
[   72.159169] Testing event ext4_da_update_reserve_space: OK
[   72.177936] Testing event ext4_da_reserve_space: OK
[   72.197901] Testing event ext4_da_release_space: OK
[   72.217874] Testing event ext4_mb_bitmap_load: OK
[   72.239059] Testing event ext4_mb_buddy_bitmap_load: OK
[   72.258809] Testing event ext4_read_block_bitmap_load: OK
[   72.277895] Testing event ext4_load_inode_bitmap: OK
[   72.298905] Testing event ext4_direct_IO_enter: OK
[   72.317860] Testing event ext4_direct_IO_exit: OK
[   72.346427] Testing event ext4_fallocate_enter: OK
[   72.366594] Testing event ext4_fallocate_exit: OK
[   72.386100] Testing event ext4_unlink_enter: OK
[   72.406669] Testing event ext4_unlink_exit: OK
[   72.426327] Testing event ext4_truncate_enter: OK
[   72.447212] Testing event ext4_truncate_exit: OK
[   72.466020] Testing event ext4_ext_convert_to_initialized_enter: OK
[   72.486832] Testing event ext4_ext_convert_to_initialized_fastpath: OK
[   72.505954] Testing event ext4_ext_map_blocks_enter: OK
[   72.526653] Testing event ext4_ind_map_blocks_enter: OK
[   72.545941] Testing event ext4_ext_map_blocks_exit: OK
[   72.565830] Testing event ext4_ind_map_blocks_exit: OK
[   72.586415] Testing event ext4_ext_load_extent: OK
[   72.606570] Testing event ext4_load_inode: OK
[   72.626058] Testing event ext4_journal_start: OK
[   72.646655] Testing event ext4_trim_extent: OK
[   72.666253] Testing event ext4_trim_all_free: OK
[   72.686831] Testing event ext4_ext_handle_uninitialized_extents: OK
[   72.705932] Testing event ext4_get_implied_cluster_alloc_exit: OK
[   72.727044] Testing event ext4_ext_put_in_cache: OK
[   72.745913] Testing event ext4_ext_in_cache: OK
[   72.766652] Testing event ext4_find_delalloc_range: OK
[   72.785976] Testing event ext4_get_reserved_cluster_alloc: OK
[   72.806826] Testing event ext4_ext_show_extent: OK
[   72.826771] Testing event ext4_remove_blocks: OK
[   72.846606] Testing event ext4_ext_rm_leaf: OK
[   72.866113] Testing event ext4_ext_rm_idx: OK
[   72.886625] Testing event ext4_ext_remove_space: OK
[   72.904228] vhci_hcd: changed 0
[   72.908972] Testing event ext4_ext_remove_space_done: OK
[   72.930416] Testing event ext3_free_inode: OK
[   72.950383] Testing event ext3_request_inode: OK
[   72.970362] Testing event ext3_allocate_inode: OK
[   72.990353] Testing event ext3_evict_inode: OK
[   73.010193] Testing event ext3_drop_inode: OK
[   73.030298] Testing event ext3_mark_inode_dirty: OK
[   73.050392] Testing event ext3_write_begin: OK
[   73.070330] Testing event ext3_ordered_write_end: OK
[   73.090357] Testing event ext3_writeback_write_end: OK
[   73.110351] Testing event ext3_journalled_write_end: OK
[   73.129968] Testing event ext3_ordered_writepage: OK
[   73.150253] Testing event ext3_writeback_writepage: OK
[   73.170377] Testing event ext3_journalled_writepage: OK
[   73.190341] Testing event ext3_readpage: OK
[   73.210341] Testing event ext3_releasepage: OK
[   73.230352] Testing event ext3_invalidatepage: OK
[   73.250339] Testing event ext3_discard_blocks: OK
[   73.270368] Testing event ext3_request_blocks: OK
[   73.290359] Testing event ext3_allocate_blocks: OK
[   73.310389] Testing event ext3_free_blocks: OK
[   73.329999] Testing event ext3_sync_file_enter: OK
[   73.350408] Testing event ext3_sync_file_exit: OK
[   73.370398] Testing event ext3_sync_fs: OK
[   73.389992] Testing event ext3_rsv_window_add: OK
[   73.409923] Testing event ext3_discard_reservation: OK
[   73.430037] Testing event ext3_alloc_new_reservation: OK
[   73.449941] Testing event ext3_reserved: OK
[   73.469974] Testing event ext3_forget: OK
[   73.490000] Testing event ext3_read_block_bitmap: OK
[   73.509942] Testing event ext3_direct_IO_enter: OK
[   73.530079] Testing event ext3_direct_IO_exit: OK
[   73.549988] Testing event ext3_unlink_enter: OK
[   73.570035] Testing event ext3_unlink_exit: OK
[   73.590295] Testing event ext3_truncate_enter: OK
[   73.610340] Testing event ext3_truncate_exit: OK
[   73.630290] Testing event ext3_get_blocks_enter: OK
[   73.650265] Testing event ext3_get_blocks_exit: OK
[   73.670131] Testing event ext3_load_inode: OK
[   73.690303] Testing event writeback_nothread: OK
[   73.710269] Testing event writeback_queue: OK
[   73.730341] Testing event writeback_exec: OK
[   73.750146] Testing event writeback_start: OK
[   73.770204] Testing event writeback_written: OK
[   73.790267] Testing event writeback_wait: OK
[   73.810339] Testing event writeback_pages_written: OK
[   73.830330] Testing event writeback_nowork: OK
[   73.850330] Testing event writeback_wake_background: OK
[   73.870112] Testing event writeback_wake_thread: OK
[   73.890316] Testing event writeback_wake_forker_thread: OK
[   73.910288] Testing event writeback_bdi_register: OK
[   73.930357] Testing event writeback_bdi_unregister: OK
[   73.950280] Testing event writeback_thread_start: OK
[   73.970376] Testing event writeback_thread_stop: OK
[   73.990371] Testing event wbc_writepage: OK
[   74.009953] Testing event writeback_queue_io: OK
[   74.030066] Testing event global_dirty_state: OK
[   74.050122] Testing event bdi_dirty_ratelimit: OK
[   74.070378] Testing event balance_dirty_pages: OK
[   74.090352] Testing event writeback_sb_inodes_requeue: OK
[   74.110122] Testing event writeback_congestion_wait: OK
[   74.130142] Testing event writeback_wait_iff_congested: OK
[   74.150325] Testing event writeback_single_inode: OK
[   74.170046] Testing event mm_compaction_isolate_migratepages: OK
[   74.190132] Testing event mm_compaction_isolate_freepages: OK
[   74.210303] Testing event mm_compaction_migratepages: OK
[   74.230272] Testing event kmalloc: OK
[   74.249939] Testing event kmem_cache_alloc: OK
[   74.269934] Testing event kmalloc_node: OK
[   74.290187] Testing event kmem_cache_alloc_node: OK
[   74.310135] Testing event kfree: OK
[   74.329934] Testing event kmem_cache_free: OK
[   74.350112] Testing event mm_page_free: OK
[   74.369993] Testing event mm_page_free_batched: OK
[   74.390144] Testing event mm_page_alloc: OK
[   74.410351] Testing event mm_page_alloc_zone_locked: OK
[   74.430102] Testing event mm_page_pcpu_drain: OK
[   74.450238] Testing event mm_page_alloc_extfrag: OK
[   74.470198] Testing event mm_vmscan_kswapd_sleep: OK
[   74.490296] Testing event mm_vmscan_kswapd_wake: OK
[   74.510338] Testing event mm_vmscan_wakeup_kswapd: OK
[   74.529928] Testing event mm_vmscan_direct_reclaim_begin: OK
[   74.550151] Testing event mm_vmscan_memcg_reclaim_begin: OK
[   74.570369] Testing event mm_vmscan_memcg_softlimit_reclaim_begin: OK
[   74.590145] Testing event mm_vmscan_direct_reclaim_end: OK
[   74.610306] Testing event mm_vmscan_memcg_reclaim_end: OK
[   74.629879] Testing event mm_vmscan_memcg_softlimit_reclaim_end: OK
[   74.650313] Testing event mm_shrink_slab_start: OK
[   74.670190] Testing event mm_shrink_slab_end: OK
[   74.690312] Testing event mm_vmscan_lru_isolate: OK
[   74.710143] Testing event mm_vmscan_memcg_isolate: OK
[   74.730339] Testing event mm_vmscan_writepage: OK
[   74.750298] Testing event mm_vmscan_lru_shrink_inactive: OK
[   74.770046] Testing event oom_score_adj_update: OK
[   74.789728] Testing event rpm_suspend: OK
[   74.810230] Testing event rpm_resume: OK
[   74.829918] Testing event rpm_idle: OK
[   74.850045] Testing event rpm_return_int: OK
[   74.869932] Testing event cpu_idle: OK
[   74.889907] Testing event cpu_frequency: OK
[   74.910013] Testing event machine_suspend: OK
[   74.920255] vhci_hcd: changed 0
[   74.929917] Testing event wakeup_source_activate: OK
[   74.949936] Testing event wakeup_source_deactivate: OK
[   74.969964] Testing event power_start: OK
[   74.990272] Testing event power_frequency: OK
[   75.010312] Testing event power_end: OK
[   75.030190] Testing event clock_enable: OK
[   75.050333] Testing event clock_disable: OK
[   75.069996] Testing event clock_set_rate: OK
[   75.089909] Testing event power_domain_target: OK
[   75.110002] Testing event ftrace_test_filter: OK
[   75.130108] Testing event module_load: OK
[   75.150306] Testing event module_free: OK
[   75.170375] Testing event module_get: OK
[   75.190267] Testing event module_put: OK
[   75.210306] Testing event module_request: OK
[   75.230295] Testing event lock_acquire: OK
[   75.250340] Testing event lock_release: OK
[   75.270112] Testing event lock_contended: OK
[   75.290340] Testing event lock_acquired: OK
[   75.310265] Testing event sched_kthread_stop: OK
[   75.330327] Testing event sched_kthread_stop_ret: OK
[   75.350304] Testing event sched_wakeup: OK
[   75.370211] Testing event sched_wakeup_new: OK
[   75.390298] Testing event sched_switch: OK
[   75.410297] Testing event sched_migrate_task: OK
[   75.430218] Testing event sched_process_free: OK
[   75.450312] Testing event sched_process_exit: OK
[   75.470296] Testing event sched_wait_task: OK
[   75.490321] Testing event sched_process_wait: OK
[   75.510265] Testing event sched_process_fork: OK
[   75.530331] Testing event sched_process_exec: OK
[   75.550137] Testing event sched_stat_wait: OK
[   75.570187] Testing event sched_stat_sleep: OK
[   75.590248] Testing event sched_stat_iowait: OK
[   75.611275] Testing event sched_stat_blocked: OK
[   75.630051] Testing event sched_stat_runtime: OK
[   75.650426] Testing event sched_pi_setprio: OK
[   75.669922] Testing event rcu_utilization: OK
[   75.689924] Testing event rcu_grace_period: OK
[   75.709903] Testing event rcu_grace_period_init: OK
[   75.729948] Testing event rcu_preempt_task: OK
[   75.750274] Testing event rcu_unlock_preempted_task: OK
[   75.770187] Testing event rcu_quiescent_state_report: OK
[   75.790235] Testing event rcu_fqs: OK
[   75.810304] Testing event rcu_dyntick: OK
[   75.830309] Testing event rcu_prep_idle: OK
[   75.850313] Testing event rcu_callback: OK
[   75.870138] Testing event rcu_kfree_callback: OK
[   75.890322] Testing event rcu_batch_start: OK
[   75.919059] Testing event rcu_invoke_callback: OK
[   75.939196] Testing event rcu_invoke_kfree_callback: OK
[   75.959108] Testing event rcu_batch_end: OK
[   75.978579] Testing event rcu_torture_read: OK
[   75.998573] Testing event workqueue_queue_work: OK
[   76.034049] Testing event workqueue_activate_work: OK
[   76.057899] Testing event workqueue_execute_start: OK
[   76.078171] Testing event workqueue_execute_end: OK
[   76.099330] Testing event signal_generate: OK
[   76.118428] Testing event signal_deliver: OK
[   76.139337] Testing event timer_init: OK
[   76.159263] Testing event timer_start: OK
[   76.179370] Testing event timer_expire_entry: OK
[   76.197964] Testing event timer_expire_exit: OK
[   76.217852] Testing event timer_cancel: OK
[   76.239204] Testing event hrtimer_init: OK
[   76.257915] Testing event hrtimer_start: OK
[   76.277891] Testing event hrtimer_expire_entry: OK
[   76.297899] Testing event hrtimer_expire_exit: OK
[   76.318967] Testing event hrtimer_cancel: OK
[   76.338775] Testing event itimer_state: OK
[   76.358384] Testing event itimer_expire: OK
[   76.379589] Testing event irq_handler_entry: OK
[   76.399187] Testing event irq_handler_exit: OK
[   76.418639] Testing event softirq_entry: OK
[   76.437900] Testing event softirq_exit: OK
[   76.457881] Testing event softirq_raise: OK
[   76.477892] Testing event console: OK
[   76.497900] Testing event task_newtask: OK
[   76.517897] Testing event task_rename: OK
[   76.538780] Testing event mce_record: OK
[   76.557971] Testing event sys_enter: OK
[   76.577882] Testing event sys_exit: OK
[   76.599053] Testing event emulate_vsyscall: OK
[   76.617895] Testing event xen_mc_batch: OK
[   76.639138] Testing event xen_mc_issue: OK
[   76.658636] Testing event xen_mc_entry: OK
[   76.679030] Testing event xen_mc_entry_alloc: OK
[   76.698764] Testing event xen_mc_callback: OK
[   76.719152] Testing event xen_mc_flush_reason: OK
[   76.738928] Testing event xen_mc_flush: OK
[   76.757906] Testing event xen_mc_extend_args: OK
[   76.778885] Testing event xen_mmu_set_pte: OK
[   76.799114] Testing event xen_mmu_set_pte_atomic: OK
[   76.819756] Testing event xen_mmu_set_domain_pte: OK
[   76.837843] Testing event xen_mmu_set_pte_at: OK
[   76.858823] Testing event xen_mmu_pte_clear: OK
[   76.879208] Testing event xen_mmu_set_pmd: OK
[   76.898637] Testing event xen_mmu_pmd_clear: OK
[   76.919027] Testing event xen_mmu_set_pud: OK
[   76.936220] vhci_hcd: changed 0
[   76.940199] Testing event xen_mmu_set_pgd: OK
[   76.957922] Testing event xen_mmu_pud_clear: OK
[   76.979578] Testing event xen_mmu_pgd_clear: OK
[   76.999169] Testing event xen_mmu_ptep_modify_prot_start: OK
[   77.018632] Testing event xen_mmu_ptep_modify_prot_commit: OK
[   77.039498] Testing event xen_mmu_alloc_ptpage: OK
[   77.058256] Testing event xen_mmu_release_ptpage: OK
[   77.079344] Testing event xen_mmu_pgd_pin: OK
[   77.097860] Testing event xen_mmu_pgd_unpin: OK
[   77.119221] Testing event xen_mmu_flush_tlb: OK
[   77.139381] Testing event xen_mmu_flush_tlb_single: OK
[   77.157967] Testing event xen_mmu_flush_tlb_others: OK
[   77.177839] Testing event xen_mmu_write_cr3: OK
[   77.199030] Testing event xen_cpu_write_ldt_entry: OK
[   77.217958] Testing event xen_cpu_write_idt_entry: OK
[   77.239110] Testing event xen_cpu_load_idt: OK
[   77.259359] Testing event xen_cpu_write_gdt_entry: OK
[   77.278671] Testing event xen_cpu_set_ldt: OK
[   77.299346] Testing event kvm_mmu_pagetable_walk: OK
[   77.318277] Testing event kvm_mmu_paging_element: OK
[   77.338358] Testing event kvm_mmu_set_accessed_bit: OK
[   77.359127] Testing event kvm_mmu_set_dirty_bit: OK
[   77.379393] Testing event kvm_mmu_walker_error: OK
[   77.397915] Testing event kvm_mmu_get_page: OK
[   77.417891] Testing event kvm_mmu_sync_page: OK
[   77.439115] Testing event kvm_mmu_unsync_page: OK
[   77.457918] Testing event kvm_mmu_prepare_zap_page: OK
[   77.477897] Testing event kvm_mmu_delay_free_pages: OK
[   77.497874] Testing event mark_mmio_spte: OK
[   77.519084] Testing event handle_mmio_page_fault: OK
[   77.538746] Testing event kvm_entry: OK
[   77.559172] Testing event kvm_hypercall: OK
[   77.579555] Testing event kvm_hv_hypercall: OK
[   77.598747] Testing event kvm_pio: OK
[   77.618620] Testing event kvm_cpuid: OK
[   77.638674] Testing event kvm_apic: OK
[   77.659304] Testing event kvm_exit: OK
[   77.677885] Testing event kvm_inj_virq: OK
[   77.697877] Testing event kvm_inj_exception: OK
[   77.719265] Testing event kvm_page_fault: OK
[   77.739224] Testing event kvm_msr: OK
[   77.758987] Testing event kvm_cr: OK
[   77.779527] Testing event kvm_pic_set_irq: OK
[   77.797853] Testing event kvm_apic_ipi: OK
[   77.819063] Testing event kvm_apic_accept_irq: OK
[   77.838664] Testing event kvm_nested_vmrun: OK
[   77.859182] Testing event kvm_nested_intercepts: OK
[   77.879187] Testing event kvm_nested_vmexit: OK
[   77.897775] Testing event kvm_nested_vmexit_inject: OK
[   77.918296] Testing event kvm_nested_intr_vmexit: OK
[   77.938282] Testing event kvm_invlpga: OK
[   77.957780] Testing event kvm_skinit: OK
[   77.978613] Testing event kvm_emulate_insn: OK
[   77.999067] Testing event vcpu_match_mmio: OK
[   78.018767] Testing event kvm_userspace_exit: OK
[   78.038283] Testing event kvm_set_irq: OK
[   78.057964] Testing event kvm_ioapic_set_irq: OK
[   78.077900] Testing event kvm_msi_set_irq: OK
[   78.097871] Testing event kvm_ack_irq: OK
[   78.119173] Testing event kvm_mmio: OK
[   78.139263] Testing event kvm_fpu: OK
[   78.157887] Testing event kvm_age_page: OK
[   78.178892] Testing event kvm_try_async_get_page: OK
[   78.199092] Testing event kvm_async_pf_doublefault: OK
[   78.218637] Testing event kvm_async_pf_not_present: OK
[   78.239502] Testing event kvm_async_pf_ready: OK
[   78.258230] Testing event kvm_async_pf_completed: OK
[   78.260751] Running tests on trace event systems:
[   78.280236] Testing event system 9p: OK
[   78.337599] Testing event system mac80211: OK
[   78.361218] Testing event system sunrpc: OK
[   78.380289] Testing event system skb: OK
[   78.400417] Testing event system net: OK
[   78.418020] Testing event system napi: OK
[   78.439921] Testing event system sock: OK
[   78.458708] Testing event system udp: OK
[   78.480803] Testing event system hda: OK
[   78.500539] Testing event system scsi: OK
[   78.529747] Testing event system regmap: OK
[   78.562613] Testing event system i915: OK
[   78.585023] Testing event system radeon: OK
[   78.607328] Testing event system drm: OK
[   78.631524] Testing event system regulator: OK
[   78.650180] Testing event system gpio: OK
[   78.681504] Testing event system block: OK
[   78.707675] Testing event system gfs2: OK
[   78.744208] Testing event system btrfs: OK
[   78.928113] Testing event system ocfs2: OK
[   78.952121] vhci_hcd: changed 0
[   79.104376] Testing event system xfs: OK
[   79.131511] Testing event system jbd2: OK
[   79.151987] Testing event system jbd: OK
[   79.206133] Testing event system ext4: OK
[   79.245898] Testing event system ext3: OK
[   79.282277] Testing event system writeback: OK
[   79.303150] Testing event system compaction: OK
[   79.331090] Testing event system kmem: OK
[   79.360749] Testing event system vmscan: OK
[   79.378195] Testing event system oom: OK
[   79.400091] Testing event system rpm: OK
[   79.430160] Testing event system power: OK
[   79.450183] Testing event system test: OK
[   79.470787] Testing event system module: OK
[   79.490967] Testing event system lock: OK
[   79.521461] Testing event system sched: OK
[   79.548583] Testing event system rcu: OK
[   79.570635] Testing event system workqueue: OK
[   79.590119] Testing event system signal: OK
[   79.612513] Testing event system timer: OK
[   79.630662] Testing event system irq: OK
[   79.649927] Testing event system printk: OK
[   79.670470] Testing event system task: OK
[   79.689931] Testing event system mce: OK
[   79.710132] Testing event system raw_syscalls: OK
[   79.730214] Testing event system vsyscall: OK
[   79.751442] Testing event system syscalls: OK
[   79.786832] Testing event system xen: OK
[   79.811389] Testing event system kvmmmu: OK
[   79.847363] Testing event system kvm: OK
[   79.848469] Running tests on all trace events:
[   80.634205] Testing all events: OK
[   80.849246] Testing ftrace filter: OK
[   80.853922] Testing kprobe tracing: OK
[   80.855466] kAFS: Red Hat AFS client v0.1 registering.
[   80.856807] FS-Cache: Netfs 'afs' registered for caching
[   80.860143] console [netcon0] enabled
[   80.861060] netconsole: network logging started
[   80.862265] rtc_cmos 00:01: setting system clock to 2012-07-05 13:02:39 UTC (1341493359)
[   80.872586] saa7134 ALSA driver for DMA sound loaded
[   80.873862] saa7134 ALSA: no saa7134 cards found
[   80.875115] BIOS EDD facility v0.16 2004-Jun-25, 0 devices found
[   80.876551] EDD information not available.
[   80.878774] IPv6: ADDRCONF(NETDEV_UP): bond0: link is not ready
[   80.880350] 8021q: adding VLAN 0 to HW filter on device bond0
[   80.882116] general protection fault: 0000 [#1] SMP DEBUG_PAGEALLOC
[   80.883606] CPU 0 
[   80.884216] Modules linked in:
[   80.884296] 
[   80.884296] Pid: 1, comm: swapper/0 Not tainted 3.5.0-rc4+ #16 Bochs Bochs
[   80.884296] RIP: 0010:[<ffffffff816ce77e>]  [<ffffffff816ce77e>] __nla_put+0x1f/0x26
[   80.884296] RSP: 0018:ffff88001d819910  EFLAGS: 00010282
[   80.884296] RAX: ffff880012167c2c RBX: 5a5a5a5a5a5a5d3a RCX: 0000000000000010
[   80.884296] RDX: ffff880012167c3c RSI: 5a5a5a5a5a5a5d3a RDI: ffff880012167c2c
[   80.884296] RBP: ffff88001d819920 R08: ffff880012167c28 R09: ffff880012167bf0
[   80.884296] R10: ffffffff840401a0 R11: ffffffff840401a0 R12: 0000000000000010
[   80.884296] R13: ffff8800120c3f00 R14: 0000000000000000 R15: 0000000000000000
[   80.884296] FS:  0000000000000000(0000) GS:ffff88001f200000(0000) knlGS:0000000000000000
[   80.884296] CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
[   80.884296] CR2: 0000000000000000 CR3: 0000000004014000 CR4: 00000000000006f0
[   80.884296] DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
[   80.884296] DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
[   80.884296] Process swapper/0 (pid: 1, threadinfo ffff88001d818000, task ffff88001d814040)
[   80.884296] Stack:
[   80.884296]  ffff8800120c3f00 ffff880012168e70 ffff88001d819960 ffffffff816ce7bf
[   80.884296]  ffff88001d819950 5a5a5a5a5a5a5d3a ffffffff00000010 ffff880000000005
[   80.884296]  ffff88001d819960 ffff880012167bf0 ffff88001d819a00 ffffffff82afa9b0
[   80.884296] Call Trace:
[   80.884296]  [<ffffffff816ce7bf>] nla_put+0x3a/0x4a
[   80.884296]  [<ffffffff82afa9b0>] rt6_fill_node.constprop.35+0x325/0x486
[   80.884296]  [<ffffffff8117598d>] ? __kmalloc_node_track_caller+0x35/0x3e
[   80.884296]  [<ffffffff829d69cb>] ? __alloc_skb+0xaf/0x15a
[   80.884296]  [<ffffffff82afaf82>] inet6_rt_notify+0xb2/0x130
[   80.884296]  [<ffffffff82afc56f>] fib6_add+0x359/0x55a
[   80.884296]  [<ffffffff810dbeb0>] ? lock_acquired+0x1e4/0x219
[   80.884296]  [<ffffffff82af7ae5>] __ip6_ins_rt+0x3c/0x57
[   80.884296]  [<ffffffff82af9c10>] ip6_route_add+0x49e/0x58d
[   80.884296]  [<ffffffff82af0bcc>] addrconf_add_mroute+0x82/0x98
[   80.884296]  [<ffffffff82af24a8>] addrconf_add_dev+0x61/0x83
[   80.884296]  [<ffffffff82af429a>] addrconf_dev_config+0x78/0xd4
[   80.884296]  [<ffffffff82af5fb1>] addrconf_notify+0x164/0x283
[   80.884296]  [<ffffffff82e4fcc2>] notifier_call_chain+0x65/0x95
[   80.884296]  [<ffffffff810b54ab>] __raw_notifier_call_chain+0xe/0x10
[   80.884296]  [<ffffffff810b54c1>] raw_notifier_call_chain+0x14/0x16
[   80.884296]  [<ffffffff829df1c8>] call_netdevice_notifiers+0x4a/0x4f
[   80.884296]  [<ffffffff829e4934>] __dev_notify_flags+0x37/0x5b
[   80.884296]  [<ffffffff829e49a0>] dev_change_flags+0x48/0x54
[   80.884296]  [<ffffffff8467e322>] ip_auto_config.part.10+0x14a/0xd52
[   80.884296]  [<ffffffff82e4c452>] ? _raw_spin_unlock+0x28/0x3b
[   80.884296]  [<ffffffff811da21f>] ? proc_register+0x192/0x1a6
[   80.884296]  [<ffffffff8467c8c6>] ? tcp_v4_init+0x30/0x30
[   80.884296]  [<ffffffff8467ef2a>] ? ip_auto_config.part.10+0xd52/0xd52
[   80.884296]  [<ffffffff8467ef5d>] ip_auto_config+0x33/0x35
[   80.884296]  [<ffffffff81002099>] do_one_initcall+0x7f/0x13a
[   80.884296]  [<ffffffff845f1d0a>] kernel_init+0x141/0x1c5
[   80.884296]  [<ffffffff845f1590>] ? do_early_param+0x8c/0x8c
[   80.884296]  [<ffffffff82e545f4>] kernel_thread_helper+0x4/0x10
[   80.884296]  [<ffffffff82e4c830>] ? retint_restore_args+0x13/0x13
[   80.884296]  [<ffffffff845f1bc9>] ? start_kernel+0x3e7/0x3e7
[   80.884296]  [<ffffffff82e545f0>] ? gs_change+0x13/0x13
[   80.884296] Code: 4c 89 c0 41 5b 5b 41 5c 41 5d 5d c3 55 48 89 e5 41 54 41 89 d4 53 48 89 cb e8 a2 ff ff ff 48 83 c0 04 49 63 cc 48 89 de 48 89 c7 <f3> a4 5b 41 5c 5d c3 55 48 89 e5 53 48 89 fb 48 83 ec 28 89 55 
[   80.884296] RIP  [<ffffffff816ce77e>] __nla_put+0x1f/0x26
[   80.884296]  RSP <ffff88001d819910>
[   80.964726] ---[ end trace 7265c51d764fcc58 ]---
[   80.965811] Kernel panic - not syncing: Fatal exception in interrupt

--M9NhX3UHpAaciwkO
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename="config-3.5.0-rc4+"

#
# Automatically generated file; DO NOT EDIT.
# Linux/x86_64 3.5.0-rc4 Kernel Configuration
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
CONFIG_HAVE_INTEL_TXT=y
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
CONFIG_FHANDLE=y
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
CONFIG_GENERIC_IRQ_CHIP=y
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
CONFIG_CGROUP_MEM_RES_CTLR=y
CONFIG_CGROUP_MEM_RES_CTLR_SWAP=y
# CONFIG_CGROUP_MEM_RES_CTLR_SWAP_ENABLED is not set
# CONFIG_CGROUP_MEM_RES_CTLR_KMEM is not set
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
CONFIG_SCHED_AUTOGROUP=y
CONFIG_MM_OWNER=y
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
CONFIG_X86_X2APIC=y
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
CONFIG_KVM_CLOCK=y
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
CONFIG_PREEMPT_COUNT=y
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
CONFIG_TRANSPARENT_HUGEPAGE=y
# CONFIG_TRANSPARENT_HUGEPAGE_ALWAYS is not set
CONFIG_TRANSPARENT_HUGEPAGE_MADVISE=y
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
CONFIG_CAN_PM_TRACE=y
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
CONFIG_ACPI_IPMI=y
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
CONFIG_ACPI_APEI_PCIEAER=y
CONFIG_ACPI_APEI_MEMORY_FAILURE=y
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
CONFIG_IP_FIB_TRIE_STATS=y
CONFIG_IP_MULTIPLE_TABLES=y
CONFIG_IP_ROUTE_MULTIPATH=y
CONFIG_IP_ROUTE_VERBOSE=y
CONFIG_IP_ROUTE_CLASSID=y
CONFIG_IP_PNP=y
CONFIG_IP_PNP_DHCP=y
CONFIG_IP_PNP_BOOTP=y
CONFIG_IP_PNP_RARP=y
CONFIG_NET_IPIP=y
CONFIG_NET_IPGRE_DEMUX=y
CONFIG_NET_IPGRE=y
CONFIG_NET_IPGRE_BROADCAST=y
CONFIG_IP_MROUTE=y
CONFIG_IP_MROUTE_MULTIPLE_TABLES=y
CONFIG_IP_PIMSM_V1=y
CONFIG_IP_PIMSM_V2=y
# CONFIG_ARPD is not set
CONFIG_SYN_COOKIES=y
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
CONFIG_NF_CONNTRACK_TIMESTAMP=y
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
CONFIG_NF_CONNTRACK_SNMP=y
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
CONFIG_NETFILTER_XT_SET=y

#
# Xtables targets
#
CONFIG_NETFILTER_XT_TARGET_AUDIT=y
CONFIG_NETFILTER_XT_TARGET_CHECKSUM=y
CONFIG_NETFILTER_XT_TARGET_CLASSIFY=y
CONFIG_NETFILTER_XT_TARGET_CONNMARK=y
CONFIG_NETFILTER_XT_TARGET_CONNSECMARK=y
CONFIG_NETFILTER_XT_TARGET_CT=y
CONFIG_NETFILTER_XT_TARGET_DSCP=y
CONFIG_NETFILTER_XT_TARGET_HL=y
# CONFIG_NETFILTER_XT_TARGET_HMARK is not set
CONFIG_NETFILTER_XT_TARGET_IDLETIMER=y
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
CONFIG_NETFILTER_XT_MATCH_ADDRTYPE=y
CONFIG_NETFILTER_XT_MATCH_CLUSTER=y
CONFIG_NETFILTER_XT_MATCH_COMMENT=y
CONFIG_NETFILTER_XT_MATCH_CONNBYTES=y
CONFIG_NETFILTER_XT_MATCH_CONNLIMIT=y
CONFIG_NETFILTER_XT_MATCH_CONNMARK=y
CONFIG_NETFILTER_XT_MATCH_CONNTRACK=y
CONFIG_NETFILTER_XT_MATCH_CPU=y
CONFIG_NETFILTER_XT_MATCH_DCCP=y
CONFIG_NETFILTER_XT_MATCH_DEVGROUP=y
CONFIG_NETFILTER_XT_MATCH_DSCP=y
CONFIG_NETFILTER_XT_MATCH_ECN=y
CONFIG_NETFILTER_XT_MATCH_ESP=y
CONFIG_NETFILTER_XT_MATCH_HASHLIMIT=y
CONFIG_NETFILTER_XT_MATCH_HELPER=y
CONFIG_NETFILTER_XT_MATCH_HL=y
CONFIG_NETFILTER_XT_MATCH_IPRANGE=y
CONFIG_NETFILTER_XT_MATCH_IPVS=y
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
CONFIG_IP_SET=y
CONFIG_IP_SET_MAX=256
CONFIG_IP_SET_BITMAP_IP=y
CONFIG_IP_SET_BITMAP_IPMAC=y
CONFIG_IP_SET_BITMAP_PORT=y
CONFIG_IP_SET_HASH_IP=y
CONFIG_IP_SET_HASH_IPPORT=y
CONFIG_IP_SET_HASH_IPPORTIP=y
CONFIG_IP_SET_HASH_IPPORTNET=y
CONFIG_IP_SET_HASH_NET=y
CONFIG_IP_SET_HASH_NETPORT=y
CONFIG_IP_SET_HASH_NETIFACE=y
CONFIG_IP_SET_LIST_SET=y
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
CONFIG_IP_VS_NFCT=y
CONFIG_IP_VS_PE_SIP=y

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
# CONFIG_NF_NAT is not set
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
CONFIG_TIPC_LOG=0
# CONFIG_TIPC_DEBUG is not set
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
CONFIG_IEEE802154_6LOWPAN=y
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
CONFIG_NET_SCH_SFB=y
CONFIG_NET_SCH_SFQ=y
CONFIG_NET_SCH_TEQL=y
CONFIG_NET_SCH_TBF=y
CONFIG_NET_SCH_GRED=y
CONFIG_NET_SCH_DSMARK=y
CONFIG_NET_SCH_NETEM=y
CONFIG_NET_SCH_DRR=y
CONFIG_NET_SCH_MQPRIO=y
CONFIG_NET_SCH_CHOKE=y
CONFIG_NET_SCH_QFQ=y
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
CONFIG_NET_ACT_CSUM=y
CONFIG_NET_CLS_IND=y
CONFIG_NET_SCH_FIFO=y
CONFIG_DCB=y
CONFIG_DNS_RESOLVER=y
CONFIG_BATMAN_ADV=y
CONFIG_BATMAN_ADV_BLA=y
# CONFIG_BATMAN_ADV_DEBUG is not set
# CONFIG_OPENVSWITCH is not set
CONFIG_RPS=y
CONFIG_RFS_ACCEL=y
CONFIG_XPS=y
# CONFIG_NETPRIO_CGROUP is not set
CONFIG_BQL=y
CONFIG_BPF_JIT=y

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
CONFIG_CAN_GW=y

#
# CAN Device Drivers
#
CONFIG_CAN_VCAN=y
CONFIG_CAN_SLCAN=y
CONFIG_CAN_DEV=y
CONFIG_CAN_CALC_BITTIMING=y
CONFIG_CAN_MCP251X=y
CONFIG_PCH_CAN=y
CONFIG_CAN_SJA1000=y
# CONFIG_CAN_SJA1000_ISA is not set
# CONFIG_CAN_SJA1000_PLATFORM is not set
CONFIG_CAN_EMS_PCMCIA=y
CONFIG_CAN_EMS_PCI=y
# CONFIG_CAN_PEAK_PCMCIA is not set
CONFIG_CAN_PEAK_PCI=y
CONFIG_CAN_PEAK_PCIEC=y
CONFIG_CAN_KVASER_PCI=y
CONFIG_CAN_PLX_PCI=y
# CONFIG_CAN_C_CAN is not set
# CONFIG_CAN_CC770 is not set

#
# CAN USB interfaces
#
CONFIG_CAN_EMS_USB=y
CONFIG_CAN_ESD_USB2=y
# CONFIG_CAN_PEAK_USB is not set
CONFIG_CAN_SOFTING=y
CONFIG_CAN_SOFTING_CS=y
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
CONFIG_KINGSUN_DONGLE=y
CONFIG_KSDAZZLE_DONGLE=y
CONFIG_KS959_DONGLE=y

#
# FIR device drivers
#
CONFIG_USB_IRDA=y
CONFIG_SIGMATEL_FIR=y
CONFIG_NSC_FIR=y
CONFIG_WINBOND_FIR=y
CONFIG_SMC_IRCC_FIR=y
CONFIG_ALI_FIR=y
CONFIG_VLSI_FIR=y
CONFIG_VIA_FIR=y
CONFIG_MCS_FIR=y
CONFIG_BT=y
# CONFIG_BT_RFCOMM is not set
# CONFIG_BT_BNEP is not set
# CONFIG_BT_CMTP is not set
# CONFIG_BT_HIDP is not set

#
# Bluetooth device drivers
#
CONFIG_BT_HCIBTUSB=y
CONFIG_BT_HCIBTSDIO=y
CONFIG_BT_HCIUART=y
CONFIG_BT_HCIUART_H4=y
CONFIG_BT_HCIUART_BCSP=y
CONFIG_BT_HCIUART_ATH3K=y
CONFIG_BT_HCIUART_LL=y
CONFIG_BT_HCIBCM203X=y
CONFIG_BT_HCIBPA10X=y
CONFIG_BT_HCIBFUSB=y
CONFIG_BT_HCIDTL1=y
CONFIG_BT_HCIBT3C=y
CONFIG_BT_HCIBLUECARD=y
CONFIG_BT_HCIBTUART=y
CONFIG_BT_HCIVHCI=y
CONFIG_BT_MRVL=y
CONFIG_BT_MRVL_SDIO=y
CONFIG_BT_ATH3K=y
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
CONFIG_NFC=y
CONFIG_NFC_NCI=y
# CONFIG_NFC_HCI is not set
# CONFIG_NFC_LLCP is not set

#
# Near Field Communication (NFC) devices
#
# CONFIG_PN544_NFC is not set
CONFIG_NFC_PN533=y
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
CONFIG_MTD_SWAP=y

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
CONFIG_MTD_SC520CDP=y
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
CONFIG_MTD_ALAUDA=y
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
CONFIG_MTD_UBI_BEB_RESERVE=1
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
# CONFIG_BLK_DEV_UB is not set
CONFIG_BLK_DEV_RAM=y
CONFIG_BLK_DEV_RAM_COUNT=16
CONFIG_BLK_DEV_RAM_SIZE=65536
# CONFIG_BLK_DEV_XIP is not set
CONFIG_CDROM_PKTCDVD=y
CONFIG_CDROM_PKTCDVD_BUFFERS=8
# CONFIG_CDROM_PKTCDVD_WCACHE is not set
CONFIG_ATA_OVER_ETH=y
CONFIG_XEN_BLKDEV_FRONTEND=y
CONFIG_XEN_BLKDEV_BACKEND=y
CONFIG_VIRTIO_BLK=y
# CONFIG_BLK_DEV_HD is not set
CONFIG_BLK_DEV_RBD=y

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
CONFIG_APDS9802ALS=y
CONFIG_ISL29003=y
CONFIG_ISL29020=y
CONFIG_SENSORS_TSL2550=y
CONFIG_SENSORS_BH1780=y
CONFIG_SENSORS_BH1770=y
CONFIG_SENSORS_APDS990X=y
CONFIG_HMC6352=y
CONFIG_DS1682=y
CONFIG_TI_DAC7512=y
CONFIG_VMWARE_BALLOON=y
# CONFIG_BMP085_I2C is not set
# CONFIG_BMP085_SPI is not set
CONFIG_PCH_PHUB=y
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
CONFIG_IWMC3200TOP=y
# CONFIG_IWMC3200TOP_DEBUG is not set
# CONFIG_IWMC3200TOP_DEBUGFS is not set

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
CONFIG_SCSI_WAIT_SCAN=m

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
CONFIG_SCSI_CXGB4_ISCSI=y
CONFIG_SCSI_BNX2_ISCSI=y
CONFIG_SCSI_BNX2X_FCOE=y
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
CONFIG_SCSI_MVUMI=y
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
CONFIG_HYPERV_STORAGE=y
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
CONFIG_SCSI_ISCI=y
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
# CONFIG_TCM_QLA2XXX is not set
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
CONFIG_PCMCIA_AHA152X=m
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
CONFIG_SATA_ACARD_AHCI=y
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
CONFIG_PATA_ARASAN_CF=y
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
CONFIG_DM_BUFIO=y
CONFIG_DM_PERSISTENT_DATA=y
CONFIG_DM_CRYPT=y
CONFIG_DM_SNAPSHOT=y
CONFIG_DM_THIN_PROVISIONING=y
# CONFIG_DM_DEBUG_BLOCK_STACK_TRACING is not set
# CONFIG_DM_DEBUG_SPACE_MAPS is not set
CONFIG_DM_MIRROR=y
CONFIG_DM_RAID=y
CONFIG_DM_LOG_USERSPACE=y
CONFIG_DM_ZERO=y
CONFIG_DM_MULTIPATH=y
CONFIG_DM_MULTIPATH_QL=y
CONFIG_DM_MULTIPATH_ST=y
CONFIG_DM_DELAY=y
CONFIG_DM_UEVENT=y
CONFIG_DM_FLAKEY=y
# CONFIG_DM_VERITY is not set
CONFIG_TARGET_CORE=y
CONFIG_TCM_IBLOCK=y
CONFIG_TCM_FILEIO=y
CONFIG_TCM_PSCSI=y
CONFIG_LOOPBACK_TARGET=y
CONFIG_TCM_FC=y
CONFIG_ISCSI_TARGET=y
# CONFIG_SBP_TARGET is not set
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
CONFIG_FIREWIRE_NOSY=y
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
CONFIG_IEEE802154_DRIVERS=y
CONFIG_IEEE802154_FAKEHARD=y
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
CONFIG_SUNGEM_PHY=y
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
CONFIG_ARCNET_COM20020_CS=y
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
CONFIG_ATM_NICSTAR=y
CONFIG_ATM_NICSTAR_USE_SUNI=y
CONFIG_ATM_NICSTAR_USE_IDT77105=y
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
CONFIG_PCMCIA_3C574=y
CONFIG_PCMCIA_3C589=y
CONFIG_VORTEX=y
CONFIG_TYPHOON=y
CONFIG_NET_VENDOR_ADAPTEC=y
CONFIG_ADAPTEC_STARFIRE=y
CONFIG_NET_VENDOR_ALTEON=y
CONFIG_ACENIC=y
# CONFIG_ACENIC_OMIT_TIGON_I is not set
CONFIG_NET_VENDOR_AMD=y
CONFIG_AMD8111_ETH=y
CONFIG_PCNET32=y
CONFIG_PCMCIA_NMCLAN=y
CONFIG_NET_VENDOR_ATHEROS=y
CONFIG_ATL2=y
CONFIG_ATL1=y
CONFIG_ATL1E=y
CONFIG_ATL1C=y
CONFIG_NET_VENDOR_BROADCOM=y
CONFIG_B44=y
CONFIG_B44_PCI_AUTOSELECT=y
CONFIG_B44_PCICORE_AUTOSELECT=y
CONFIG_B44_PCI=y
CONFIG_BNX2=y
CONFIG_CNIC=y
CONFIG_TIGON3=y
CONFIG_BNX2X=y
CONFIG_NET_VENDOR_BROCADE=y
CONFIG_BNA=y
# CONFIG_NET_CALXEDA_XGMAC is not set
CONFIG_NET_VENDOR_CHELSIO=y
CONFIG_CHELSIO_T1=y
CONFIG_CHELSIO_T1_1G=y
CONFIG_CHELSIO_T3=y
CONFIG_CHELSIO_T4=y
CONFIG_CHELSIO_T4VF=y
CONFIG_NET_VENDOR_CISCO=y
CONFIG_ENIC=y
CONFIG_DNET=y
CONFIG_NET_VENDOR_DEC=y
CONFIG_NET_TULIP=y
CONFIG_DE2104X=y
CONFIG_DE2104X_DSL=0
CONFIG_TULIP=y
# CONFIG_TULIP_MWI is not set
# CONFIG_TULIP_MMIO is not set
CONFIG_TULIP_NAPI=y
CONFIG_TULIP_NAPI_HW_MITIGATION=y
CONFIG_DE4X5=y
CONFIG_WINBOND_840=y
CONFIG_DM9102=y
CONFIG_ULI526X=y
CONFIG_PCMCIA_XIRCOM=y
CONFIG_NET_VENDOR_DLINK=y
CONFIG_DE600=y
CONFIG_DE620=y
CONFIG_DL2K=y
CONFIG_SUNDANCE=y
# CONFIG_SUNDANCE_MMIO is not set
CONFIG_NET_VENDOR_EMULEX=y
CONFIG_BE2NET=y
CONFIG_NET_VENDOR_EXAR=y
CONFIG_S2IO=y
CONFIG_VXGE=y
# CONFIG_VXGE_DEBUG_TRACE_ALL is not set
CONFIG_NET_VENDOR_FUJITSU=y
CONFIG_PCMCIA_FMVJ18X=y
CONFIG_NET_VENDOR_HP=y
CONFIG_HP100=y
CONFIG_NET_VENDOR_INTEL=y
CONFIG_E100=y
CONFIG_E1000=y
CONFIG_E1000E=y
CONFIG_IGB=y
CONFIG_IGB_DCA=y
CONFIG_IGB_PTP=y
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
CONFIG_SKGE_GENESIS=y
CONFIG_SKY2=y
CONFIG_SKY2_DEBUG=y
CONFIG_NET_VENDOR_MELLANOX=y
CONFIG_MLX4_EN=y
CONFIG_MLX4_EN_DCB=y
CONFIG_MLX4_CORE=y
CONFIG_MLX4_DEBUG=y
CONFIG_NET_VENDOR_MICREL=y
CONFIG_KS8842=y
CONFIG_KS8851=y
CONFIG_KS8851_MLL=y
CONFIG_KSZ884X_PCI=y
CONFIG_NET_VENDOR_MICROCHIP=y
CONFIG_ENC28J60=y
# CONFIG_ENC28J60_WRITEVERIFY is not set
CONFIG_NET_VENDOR_MYRI=y
CONFIG_MYRI10GE=y
CONFIG_MYRI10GE_DCA=y
CONFIG_FEALNX=y
CONFIG_NET_VENDOR_NATSEMI=y
CONFIG_NATSEMI=y
CONFIG_NS83820=y
CONFIG_NET_VENDOR_8390=y
CONFIG_PCMCIA_AXNET=y
CONFIG_NE2K_PCI=y
CONFIG_PCMCIA_PCNET=y
CONFIG_NET_VENDOR_NVIDIA=y
CONFIG_FORCEDETH=y
CONFIG_NET_VENDOR_OKI=y
CONFIG_PCH_GBE=y
CONFIG_ETHOC=y
CONFIG_NET_PACKET_ENGINE=y
CONFIG_HAMACHI=y
CONFIG_YELLOWFIN=y
CONFIG_NET_VENDOR_QLOGIC=y
CONFIG_QLA3XXX=y
CONFIG_QLCNIC=y
CONFIG_QLGE=y
CONFIG_NETXEN_NIC=y
CONFIG_NET_VENDOR_REALTEK=y
CONFIG_ATP=y
CONFIG_8139CP=y
CONFIG_8139TOO=y
CONFIG_8139TOO_PIO=y
CONFIG_8139TOO_TUNE_TWISTER=y
CONFIG_8139TOO_8129=y
# CONFIG_8139_OLD_RX_RESET is not set
CONFIG_R8169=y
CONFIG_NET_VENDOR_RDC=y
CONFIG_R6040=y
CONFIG_NET_VENDOR_SEEQ=y
# CONFIG_SEEQ8005 is not set
CONFIG_NET_VENDOR_SILAN=y
CONFIG_SC92031=y
CONFIG_NET_VENDOR_SIS=y
CONFIG_SIS900=y
CONFIG_SIS190=y
CONFIG_SFC=y
CONFIG_SFC_MTD=y
CONFIG_SFC_MCDI_MON=y
CONFIG_SFC_SRIOV=y
CONFIG_NET_VENDOR_SMSC=y
CONFIG_PCMCIA_SMC91C92=y
CONFIG_EPIC100=y
CONFIG_SMSC9420=y
CONFIG_NET_VENDOR_STMICRO=y
# CONFIG_STMMAC_ETH is not set
CONFIG_NET_VENDOR_SUN=y
CONFIG_HAPPYMEAL=y
CONFIG_SUNGEM=y
CONFIG_CASSINI=y
CONFIG_NIU=y
CONFIG_NET_VENDOR_TEHUTI=y
CONFIG_TEHUTI=y
CONFIG_NET_VENDOR_TI=y
CONFIG_TLAN=y
CONFIG_NET_VENDOR_VIA=y
CONFIG_VIA_RHINE=y
# CONFIG_VIA_RHINE_MMIO is not set
CONFIG_VIA_VELOCITY=y
CONFIG_NET_VENDOR_WIZNET=y
# CONFIG_WIZNET_W5100 is not set
# CONFIG_WIZNET_W5300 is not set
CONFIG_NET_VENDOR_XIRCOM=y
CONFIG_PCMCIA_XIRC2PS=y
CONFIG_FDDI=y
CONFIG_DEFXX=y
# CONFIG_DEFXX_MMIO is not set
CONFIG_SKFP=y
# CONFIG_HIPPI is not set
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
CONFIG_PPTP=y
CONFIG_PPPOL2TP=y
CONFIG_PPP_ASYNC=y
CONFIG_PPP_SYNC_TTY=y
CONFIG_SLIP=y
CONFIG_SLHC=y
CONFIG_SLIP_COMPRESSED=y
CONFIG_SLIP_SMART=y
CONFIG_SLIP_MODE_SLIP6=y

#
# USB Network Adapters
#
CONFIG_USB_CATC=y
CONFIG_USB_KAWETH=y
CONFIG_USB_PEGASUS=y
CONFIG_USB_RTL8150=y
CONFIG_USB_USBNET=y
CONFIG_USB_NET_AX8817X=y
CONFIG_USB_NET_CDCETHER=y
CONFIG_USB_NET_CDC_EEM=y
CONFIG_USB_NET_CDC_NCM=y
CONFIG_USB_NET_DM9601=y
CONFIG_USB_NET_SMSC75XX=y
CONFIG_USB_NET_SMSC95XX=y
CONFIG_USB_NET_GL620A=y
CONFIG_USB_NET_NET1080=y
CONFIG_USB_NET_PLUSB=y
CONFIG_USB_NET_MCS7830=y
CONFIG_USB_NET_RNDIS_HOST=y
CONFIG_USB_NET_CDC_SUBSET=y
CONFIG_USB_ALI_M5632=y
CONFIG_USB_AN2720=y
CONFIG_USB_BELKIN=y
CONFIG_USB_ARMLINUX=y
CONFIG_USB_EPSON2888=y
CONFIG_USB_KC2190=y
CONFIG_USB_NET_ZAURUS=y
CONFIG_USB_NET_CX82310_ETH=y
CONFIG_USB_NET_KALMIA=y
# CONFIG_USB_NET_QMI_WWAN is not set
CONFIG_USB_HSO=y
CONFIG_USB_NET_INT51X1=y
CONFIG_USB_CDC_PHONET=y
CONFIG_USB_IPHETH=y
CONFIG_USB_SIERRA_NET=y
CONFIG_USB_VL600=y
CONFIG_WLAN=y
CONFIG_PCMCIA_RAYCS=y
CONFIG_LIBERTAS_THINFIRM=y
# CONFIG_LIBERTAS_THINFIRM_DEBUG is not set
CONFIG_LIBERTAS_THINFIRM_USB=y
CONFIG_AIRO=y
CONFIG_ATMEL=y
CONFIG_PCI_ATMEL=y
CONFIG_PCMCIA_ATMEL=y
CONFIG_AT76C50X_USB=y
CONFIG_AIRO_CS=y
CONFIG_PCMCIA_WL3501=y
# CONFIG_PRISM54 is not set
CONFIG_USB_ZD1201=y
CONFIG_USB_NET_RNDIS_WLAN=y
CONFIG_RTL8180=y
CONFIG_RTL8187=y
CONFIG_RTL8187_LEDS=y
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
CONFIG_ATH9K_HTC=y
# CONFIG_ATH9K_HTC_DEBUGFS is not set
CONFIG_CARL9170=y
CONFIG_CARL9170_LEDS=y
CONFIG_CARL9170_WPC=y
# CONFIG_CARL9170_HWRNG is not set
# CONFIG_ATH6KL is not set
CONFIG_B43=y
CONFIG_B43_BCMA=y
CONFIG_B43_BCMA_EXTRA=y
CONFIG_B43_SSB=y
CONFIG_B43_PCI_AUTOSELECT=y
CONFIG_B43_PCICORE_AUTOSELECT=y
CONFIG_B43_PCMCIA=y
CONFIG_B43_SDIO=y
CONFIG_B43_BCMA_PIO=y
CONFIG_B43_PIO=y
CONFIG_B43_PHY_N=y
CONFIG_B43_PHY_LP=y
CONFIG_B43_PHY_HT=y
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
# CONFIG_BRCMSMAC is not set
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
CONFIG_IWL4965=y
CONFIG_IWL3945=y

#
# iwl3945 / iwl4965 Debugging Options
#
# CONFIG_IWLEGACY_DEBUG is not set
CONFIG_IWM=y
# CONFIG_IWM_DEBUG is not set
# CONFIG_IWM_TRACING is not set
CONFIG_LIBERTAS=y
CONFIG_LIBERTAS_USB=y
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
CONFIG_ORINOCO_USB=y
CONFIG_P54_COMMON=y
CONFIG_P54_USB=y
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
CONFIG_RT2500USB=y
CONFIG_RT73USB=y
CONFIG_RT2800USB=y
CONFIG_RT2800USB_RT33XX=y
CONFIG_RT2800USB_RT35XX=y
CONFIG_RT2800USB_RT53XX=y
# CONFIG_RT2800USB_UNKNOWN is not set
CONFIG_RT2800_LIB=y
CONFIG_RT2X00_LIB_PCI=y
CONFIG_RT2X00_LIB_USB=y
CONFIG_RT2X00_LIB=y
CONFIG_RT2X00_LIB_FIRMWARE=y
CONFIG_RT2X00_LIB_CRYPTO=y
CONFIG_RT2X00_LIB_LEDS=y
# CONFIG_RT2X00_DEBUG is not set
CONFIG_RTL8192CE=y
CONFIG_RTL8192SE=y
CONFIG_RTL8192DE=y
CONFIG_RTL8192CU=y
CONFIG_RTLWIFI=y
CONFIG_RTLWIFI_DEBUG=y
CONFIG_RTL8192C_COMMON=y
# CONFIG_WL_TI is not set
CONFIG_ZD1211RW=y
# CONFIG_ZD1211RW_DEBUG is not set
CONFIG_MWIFIEX=y
CONFIG_MWIFIEX_SDIO=y
CONFIG_MWIFIEX_PCIE=y
# CONFIG_MWIFIEX_USB is not set

#
# WiMAX Wireless Broadband devices
#
CONFIG_WIMAX_I2400M=y
CONFIG_WIMAX_I2400M_USB=y
CONFIG_WIMAX_I2400M_SDIO=y
CONFIG_WIMAX_IWMC3200_SDIO=y
CONFIG_WIMAX_I2400M_DEBUG_LEVEL=8
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
CONFIG_XEN_NETDEV_FRONTEND=y
CONFIG_XEN_NETDEV_BACKEND=y
CONFIG_VMXNET3=y
CONFIG_HYPERV_NET=y
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
CONFIG_GIGASET_BASE=y
CONFIG_GIGASET_M105=y
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
CONFIG_MISDN_HFCUSB=y
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
CONFIG_MOUSE_APPLETOUCH=y
CONFIG_MOUSE_BCM5974=y
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
CONFIG_JOYSTICK_IFORCE_USB=y
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
CONFIG_JOYSTICK_XPAD=y
CONFIG_JOYSTICK_XPAD_FF=y
CONFIG_JOYSTICK_XPAD_LEDS=y
CONFIG_JOYSTICK_WALKERA0701=y
CONFIG_INPUT_TABLET=y
CONFIG_TABLET_USB_ACECAD=y
CONFIG_TABLET_USB_AIPTEK=y
CONFIG_TABLET_USB_GTCO=y
CONFIG_TABLET_USB_HANWANG=y
CONFIG_TABLET_USB_KBTAB=y
CONFIG_TABLET_USB_WACOM=y
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
CONFIG_TOUCHSCREEN_MTOUCH=y
CONFIG_TOUCHSCREEN_INEXIO=y
CONFIG_TOUCHSCREEN_MK712=y
CONFIG_TOUCHSCREEN_PENMOUNT=y
CONFIG_TOUCHSCREEN_TOUCHRIGHT=y
CONFIG_TOUCHSCREEN_TOUCHWIN=y
# CONFIG_TOUCHSCREEN_PIXCIR is not set
CONFIG_TOUCHSCREEN_WM97XX=y
CONFIG_TOUCHSCREEN_WM9705=y
CONFIG_TOUCHSCREEN_WM9712=y
CONFIG_TOUCHSCREEN_WM9713=y
CONFIG_TOUCHSCREEN_USB_COMPOSITE=y
CONFIG_TOUCHSCREEN_USB_EGALAX=y
CONFIG_TOUCHSCREEN_USB_PANJIT=y
CONFIG_TOUCHSCREEN_USB_3M=y
CONFIG_TOUCHSCREEN_USB_ITM=y
CONFIG_TOUCHSCREEN_USB_ETURBO=y
CONFIG_TOUCHSCREEN_USB_GUNZE=y
CONFIG_TOUCHSCREEN_USB_DMC_TSC10=y
CONFIG_TOUCHSCREEN_USB_IRTOUCH=y
CONFIG_TOUCHSCREEN_USB_IDEALTEK=y
CONFIG_TOUCHSCREEN_USB_GENERAL_TOUCH=y
CONFIG_TOUCHSCREEN_USB_GOTOP=y
CONFIG_TOUCHSCREEN_USB_JASTEC=y
CONFIG_TOUCHSCREEN_USB_ELO=y
CONFIG_TOUCHSCREEN_USB_E2I=y
CONFIG_TOUCHSCREEN_USB_ZYTRONIC=y
CONFIG_TOUCHSCREEN_USB_ETT_TC45USB=y
CONFIG_TOUCHSCREEN_USB_NEXIO=y
CONFIG_TOUCHSCREEN_USB_EASYTOUCH=y
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
CONFIG_INPUT_ATI_REMOTE2=y
CONFIG_INPUT_KEYSPAN_REMOTE=y
# CONFIG_INPUT_KXTJ9 is not set
CONFIG_INPUT_POWERMATE=y
CONFIG_INPUT_YEALINK=y
CONFIG_INPUT_CM109=y
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
CONFIG_DEVPTS_MULTIPLE_INSTANCES=y
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
CONFIG_SERIAL_MFD_HSU=y
# CONFIG_SERIAL_MFD_HSU_CONSOLE is not set
CONFIG_SERIAL_CORE=y
CONFIG_SERIAL_CORE_CONSOLE=y
CONFIG_SERIAL_JSM=y
# CONFIG_SERIAL_TIMBERDALE is not set
# CONFIG_SERIAL_ALTERA_JTAGUART is not set
# CONFIG_SERIAL_ALTERA_UART is not set
# CONFIG_SERIAL_IFX6X60 is not set
CONFIG_SERIAL_PCH_UART=y
# CONFIG_SERIAL_PCH_UART_CONSOLE is not set
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
CONFIG_I2C_EG20T=y
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
CONFIG_I2C_DIOLAN_U2C=y
CONFIG_I2C_PARPORT=y
CONFIG_I2C_PARPORT_LIGHT=y
CONFIG_I2C_TAOS_EVM=y
CONFIG_I2C_TINY_USB=y

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
CONFIG_SPI_TOPCLIFF_PCH=y
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
CONFIG_PPS_CLIENT_PARPORT=y
# CONFIG_PPS_CLIENT_GPIO is not set

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
# CONFIG_PTP_1588_CLOCK_PCH is not set
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
# CONFIG_GPIO_LANGWELL is not set
CONFIG_GPIO_PCH=y
CONFIG_GPIO_ML_IOH=y
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
CONFIG_W1_MASTER_DS2490=y
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
CONFIG_SENSORS_FAM15H_POWER=y
CONFIG_SENSORS_ASB100=y
CONFIG_SENSORS_ATXP1=y
CONFIG_SENSORS_DS620=y
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
CONFIG_SENSORS_CORETEMP=y
CONFIG_SENSORS_IBMAEM=y
CONFIG_SENSORS_IBMPEX=y
CONFIG_SENSORS_IT87=y
# CONFIG_SENSORS_JC42 is not set
CONFIG_SENSORS_LINEAGE=y
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
CONFIG_SENSORS_LTC4151=y
CONFIG_SENSORS_LTC4215=y
CONFIG_SENSORS_LTC4245=y
CONFIG_SENSORS_LTC4261=y
CONFIG_SENSORS_LM95241=y
CONFIG_SENSORS_LM95245=y
CONFIG_SENSORS_MAX1111=y
CONFIG_SENSORS_MAX16065=y
CONFIG_SENSORS_MAX1619=y
CONFIG_SENSORS_MAX1668=y
CONFIG_SENSORS_MAX6639=y
CONFIG_SENSORS_MAX6642=y
CONFIG_SENSORS_MAX6650=y
# CONFIG_SENSORS_MCP3021 is not set
CONFIG_SENSORS_NTC_THERMISTOR=y
CONFIG_SENSORS_PC87360=y
CONFIG_SENSORS_PC87427=y
CONFIG_SENSORS_PCF8591=y
# CONFIG_PMBUS is not set
# CONFIG_SENSORS_SHT15 is not set
CONFIG_SENSORS_SHT21=y
CONFIG_SENSORS_SIS5595=y
CONFIG_SENSORS_SMM665=y
CONFIG_SENSORS_DME1737=y
CONFIG_SENSORS_EMC1403=y
CONFIG_SENSORS_EMC2103=y
CONFIG_SENSORS_EMC6W201=y
CONFIG_SENSORS_SMSC47M1=y
CONFIG_SENSORS_SMSC47M192=y
CONFIG_SENSORS_SMSC47B397=y
CONFIG_SENSORS_SCH56XX_COMMON=y
CONFIG_SENSORS_SCH5627=y
# CONFIG_SENSORS_SCH5636 is not set
CONFIG_SENSORS_ADS1015=y
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
CONFIG_SENSORS_W83795=y
# CONFIG_SENSORS_W83795_FANCTRL is not set
CONFIG_SENSORS_W83L785TS=y
CONFIG_SENSORS_W83L786NG=y
CONFIG_SENSORS_W83627HF=y
CONFIG_SENSORS_W83627EHF=y
CONFIG_SENSORS_APPLESMC=y

#
# ACPI drivers
#
CONFIG_SENSORS_ACPI_POWER=y
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
CONFIG_F71808E_WDT=y
CONFIG_SP5100_TCO=y
CONFIG_SC520_WDT=y
CONFIG_SBC_FITPC2_WATCHDOG=y
CONFIG_EUROTECH_WDT=y
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
CONFIG_NV_TCO=y
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
CONFIG_XEN_WDT=y

#
# PCI-based Watchdog Cards
#
CONFIG_PCIPCWATCHDOG=y
CONFIG_WDTPCI=y

#
# USB-based Watchdog Cards
#
CONFIG_USBPCWATCHDOG=y
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
CONFIG_BCMA=y
CONFIG_BCMA_BLOCKIO=y
CONFIG_BCMA_HOST_PCI_POSSIBLE=y
CONFIG_BCMA_HOST_PCI=y
# CONFIG_BCMA_DEBUG is not set

#
# Multifunction device drivers
#
CONFIG_MFD_CORE=y
# CONFIG_MFD_88PM860X is not set
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
# CONFIG_MFD_MAX77693 is not set
# CONFIG_MFD_MAX8925 is not set
# CONFIG_MFD_MAX8997 is not set
# CONFIG_MFD_MAX8998 is not set
# CONFIG_MFD_S5M_CORE is not set
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
CONFIG_MFD_WL1273_CORE=y
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
CONFIG_MEDIA_CONTROLLER=y
CONFIG_VIDEO_DEV=y
CONFIG_VIDEO_V4L2_COMMON=y
# CONFIG_VIDEO_V4L2_SUBDEV_API is not set
CONFIG_DVB_CORE=y
CONFIG_DVB_NET=y
CONFIG_VIDEO_MEDIA=y

#
# Multimedia drivers
#
CONFIG_VIDEO_SAA7146=y
CONFIG_VIDEO_SAA7146_VV=y
CONFIG_RC_CORE=y
CONFIG_LIRC=y
CONFIG_RC_MAP=y
CONFIG_IR_NEC_DECODER=y
CONFIG_IR_RC5_DECODER=y
CONFIG_IR_RC6_DECODER=y
CONFIG_IR_JVC_DECODER=y
CONFIG_IR_SONY_DECODER=y
CONFIG_IR_RC5_SZ_DECODER=y
CONFIG_IR_SANYO_DECODER=y
CONFIG_IR_MCE_KBD_DECODER=y
CONFIG_IR_LIRC_CODEC=y
# CONFIG_RC_ATI_REMOTE is not set
CONFIG_IR_ENE=y
CONFIG_IR_IMON=y
CONFIG_IR_MCEUSB=y
CONFIG_IR_ITE_CIR=y
CONFIG_IR_FINTEK=y
CONFIG_IR_NUVOTON=y
CONFIG_IR_REDRAT3=y
CONFIG_IR_STREAMZAP=y
CONFIG_IR_WINBOND_CIR=y
CONFIG_RC_LOOPBACK=y
# CONFIG_IR_GPIO_CIR is not set
CONFIG_MEDIA_ATTACH=y
CONFIG_MEDIA_TUNER=y
# CONFIG_MEDIA_TUNER_CUSTOMISE is not set
CONFIG_MEDIA_TUNER_SIMPLE=y
CONFIG_MEDIA_TUNER_TDA8290=y
CONFIG_MEDIA_TUNER_TDA827X=y
CONFIG_MEDIA_TUNER_TDA18271=y
CONFIG_MEDIA_TUNER_TDA9887=y
CONFIG_MEDIA_TUNER_TEA5761=y
CONFIG_MEDIA_TUNER_TEA5767=y
CONFIG_MEDIA_TUNER_MT20XX=y
CONFIG_MEDIA_TUNER_MT2060=y
CONFIG_MEDIA_TUNER_MT2266=y
CONFIG_MEDIA_TUNER_MT2131=y
CONFIG_MEDIA_TUNER_QT1010=y
CONFIG_MEDIA_TUNER_XC2028=y
CONFIG_MEDIA_TUNER_XC5000=y
CONFIG_MEDIA_TUNER_XC4000=y
CONFIG_MEDIA_TUNER_MXL5005S=y
CONFIG_MEDIA_TUNER_MXL5007T=y
CONFIG_MEDIA_TUNER_MC44S803=y
CONFIG_MEDIA_TUNER_MAX2165=y
CONFIG_MEDIA_TUNER_TDA18218=y
CONFIG_MEDIA_TUNER_TDA18212=y
CONFIG_VIDEO_V4L2=y
CONFIG_VIDEOBUF_GEN=y
CONFIG_VIDEOBUF_DMA_SG=y
CONFIG_VIDEOBUF_VMALLOC=y
CONFIG_VIDEOBUF_DVB=y
CONFIG_VIDEO_BTCX=y
CONFIG_VIDEO_TVEEPROM=y
CONFIG_VIDEO_TUNER=y
CONFIG_VIDEOBUF2_CORE=y
CONFIG_VIDEOBUF2_MEMOPS=y
CONFIG_VIDEOBUF2_VMALLOC=y
CONFIG_VIDEO_CAPTURE_DRIVERS=y
# CONFIG_VIDEO_ADV_DEBUG is not set
# CONFIG_VIDEO_FIXED_MINOR_RANGES is not set
CONFIG_VIDEO_HELPER_CHIPS_AUTO=y
CONFIG_VIDEO_IR_I2C=y

#
# Audio decoders, processors and mixers
#
CONFIG_VIDEO_TVAUDIO=y
CONFIG_VIDEO_TDA7432=y
CONFIG_VIDEO_TDA9840=y
CONFIG_VIDEO_TEA6415C=y
CONFIG_VIDEO_TEA6420=y
CONFIG_VIDEO_MSP3400=y
CONFIG_VIDEO_CS5345=y
CONFIG_VIDEO_CS53L32A=y
CONFIG_VIDEO_WM8775=y
CONFIG_VIDEO_WM8739=y
CONFIG_VIDEO_VP27SMPX=y

#
# RDS decoders
#
CONFIG_VIDEO_SAA6588=y

#
# Video decoders
#
CONFIG_VIDEO_BT819=y
CONFIG_VIDEO_BT856=y
CONFIG_VIDEO_BT866=y
CONFIG_VIDEO_KS0127=y
CONFIG_VIDEO_SAA7110=y
CONFIG_VIDEO_SAA711X=y
CONFIG_VIDEO_TVP5150=y
CONFIG_VIDEO_VPX3220=y

#
# Video and audio decoders
#
CONFIG_VIDEO_SAA717X=y
CONFIG_VIDEO_CX25840=y

#
# MPEG video encoders
#
CONFIG_VIDEO_CX2341X=y

#
# Video encoders
#
CONFIG_VIDEO_SAA7127=y
CONFIG_VIDEO_SAA7185=y
CONFIG_VIDEO_ADV7170=y
CONFIG_VIDEO_ADV7175=y

#
# Camera sensor devices
#
CONFIG_VIDEO_MT9V011=y

#
# Flash devices
#

#
# Video improvement chips
#
CONFIG_VIDEO_UPD64031A=y
CONFIG_VIDEO_UPD64083=y

#
# Miscelaneous helper chips
#
CONFIG_VIDEO_M52790=y
CONFIG_VIDEO_VIVI=y
CONFIG_V4L_USB_DRIVERS=y
CONFIG_VIDEO_AU0828=y
CONFIG_USB_VIDEO_CLASS=y
CONFIG_USB_VIDEO_CLASS_INPUT_EVDEV=y
CONFIG_USB_GSPCA=y
CONFIG_USB_M5602=y
CONFIG_USB_STV06XX=y
CONFIG_USB_GL860=y
CONFIG_USB_GSPCA_BENQ=y
CONFIG_USB_GSPCA_CONEX=y
CONFIG_USB_GSPCA_CPIA1=y
CONFIG_USB_GSPCA_ETOMS=y
CONFIG_USB_GSPCA_FINEPIX=y
CONFIG_USB_GSPCA_JEILINJ=y
# CONFIG_USB_GSPCA_JL2005BCD is not set
CONFIG_USB_GSPCA_KINECT=y
CONFIG_USB_GSPCA_KONICA=y
CONFIG_USB_GSPCA_MARS=y
CONFIG_USB_GSPCA_MR97310A=y
CONFIG_USB_GSPCA_NW80X=y
CONFIG_USB_GSPCA_OV519=y
CONFIG_USB_GSPCA_OV534=y
CONFIG_USB_GSPCA_OV534_9=y
CONFIG_USB_GSPCA_PAC207=y
CONFIG_USB_GSPCA_PAC7302=y
CONFIG_USB_GSPCA_PAC7311=y
CONFIG_USB_GSPCA_SE401=y
CONFIG_USB_GSPCA_SN9C2028=y
CONFIG_USB_GSPCA_SN9C20X=y
CONFIG_USB_GSPCA_SONIXB=y
CONFIG_USB_GSPCA_SONIXJ=y
CONFIG_USB_GSPCA_SPCA500=y
CONFIG_USB_GSPCA_SPCA501=y
CONFIG_USB_GSPCA_SPCA505=y
CONFIG_USB_GSPCA_SPCA506=y
CONFIG_USB_GSPCA_SPCA508=y
CONFIG_USB_GSPCA_SPCA561=y
CONFIG_USB_GSPCA_SPCA1528=y
CONFIG_USB_GSPCA_SQ905=y
CONFIG_USB_GSPCA_SQ905C=y
CONFIG_USB_GSPCA_SQ930X=y
CONFIG_USB_GSPCA_STK014=y
CONFIG_USB_GSPCA_STV0680=y
CONFIG_USB_GSPCA_SUNPLUS=y
CONFIG_USB_GSPCA_T613=y
# CONFIG_USB_GSPCA_TOPRO is not set
CONFIG_USB_GSPCA_TV8532=y
CONFIG_USB_GSPCA_VC032X=y
CONFIG_USB_GSPCA_VICAM=y
CONFIG_USB_GSPCA_XIRLINK_CIT=y
CONFIG_USB_GSPCA_ZC3XX=y
CONFIG_VIDEO_PVRUSB2=y
CONFIG_VIDEO_PVRUSB2_SYSFS=y
CONFIG_VIDEO_PVRUSB2_DVB=y
# CONFIG_VIDEO_PVRUSB2_DEBUGIFC is not set
CONFIG_VIDEO_HDPVR=y
CONFIG_VIDEO_EM28XX=y
CONFIG_VIDEO_EM28XX_ALSA=y
CONFIG_VIDEO_EM28XX_DVB=y
CONFIG_VIDEO_EM28XX_RC=y
CONFIG_VIDEO_TLG2300=y
CONFIG_VIDEO_CX231XX=y
CONFIG_VIDEO_CX231XX_RC=y
CONFIG_VIDEO_CX231XX_ALSA=y
CONFIG_VIDEO_CX231XX_DVB=y
CONFIG_VIDEO_TM6000=y
CONFIG_VIDEO_TM6000_ALSA=y
CONFIG_VIDEO_TM6000_DVB=y
CONFIG_VIDEO_USBVISION=y
CONFIG_USB_SN9C102=y
CONFIG_USB_PWC=y
# CONFIG_USB_PWC_DEBUG is not set
CONFIG_USB_PWC_INPUT_EVDEV=y
CONFIG_VIDEO_CPIA2=y
CONFIG_USB_ZR364XX=y
CONFIG_USB_STKWEBCAM=y
CONFIG_USB_S2255=y
CONFIG_V4L_PCI_DRIVERS=y
CONFIG_VIDEO_BT848=y
CONFIG_VIDEO_BT848_DVB=y
CONFIG_VIDEO_CX18=y
CONFIG_VIDEO_CX18_ALSA=y
CONFIG_VIDEO_CX23885=y
# CONFIG_MEDIA_ALTERA_CI is not set
# CONFIG_VIDEO_CX25821 is not set
CONFIG_VIDEO_CX88=y
CONFIG_VIDEO_CX88_ALSA=y
CONFIG_VIDEO_CX88_BLACKBIRD=y
CONFIG_VIDEO_CX88_DVB=y
CONFIG_VIDEO_CX88_VP3054=y
CONFIG_VIDEO_CX88_MPEG=y
CONFIG_VIDEO_HEXIUM_GEMINI=y
CONFIG_VIDEO_HEXIUM_ORION=y
CONFIG_VIDEO_IVTV=y
CONFIG_VIDEO_FB_IVTV=y
CONFIG_VIDEO_MEYE=y
CONFIG_VIDEO_MXB=y
CONFIG_VIDEO_SAA7134=y
CONFIG_VIDEO_SAA7134_ALSA=y
CONFIG_VIDEO_SAA7134_RC=y
CONFIG_VIDEO_SAA7134_DVB=y
CONFIG_VIDEO_SAA7164=y
CONFIG_VIDEO_ZORAN=y
CONFIG_VIDEO_ZORAN_DC30=y
CONFIG_VIDEO_ZORAN_ZR36060=y
CONFIG_VIDEO_ZORAN_BUZ=y
CONFIG_VIDEO_ZORAN_DC10=y
CONFIG_VIDEO_ZORAN_LML33=y
CONFIG_VIDEO_ZORAN_LML33R10=y
CONFIG_VIDEO_ZORAN_AVS6EYES=y
# CONFIG_V4L_ISA_PARPORT_DRIVERS is not set
# CONFIG_V4L_PLATFORM_DRIVERS is not set
CONFIG_V4L_MEM2MEM_DRIVERS=y
# CONFIG_VIDEO_MEM2MEM_TESTDEV is not set
CONFIG_RADIO_ADAPTERS=y
CONFIG_RADIO_SI470X=y
CONFIG_USB_SI470X=y
CONFIG_USB_MR800=y
CONFIG_USB_DSBR=y
CONFIG_RADIO_MAXIRADIO=y
CONFIG_I2C_SI4713=y
CONFIG_RADIO_SI4713=y
# CONFIG_USB_KEENE is not set
CONFIG_RADIO_TEA5764=y
CONFIG_RADIO_TEA5764_XTAL=y
CONFIG_RADIO_SAA7706H=y
CONFIG_RADIO_TEF6862=y
CONFIG_RADIO_WL1273=y

#
# Texas Instruments WL128x FM driver (ST based)
#
# CONFIG_RADIO_WL128X is not set
CONFIG_DVB_MAX_ADAPTERS=8
CONFIG_DVB_DYNAMIC_MINORS=y
CONFIG_DVB_CAPTURE_DRIVERS=y

#
# Supported SAA7146 based PCI Adapters
#
CONFIG_TTPCI_EEPROM=y
CONFIG_DVB_AV7110=y
CONFIG_DVB_AV7110_OSD=y
CONFIG_DVB_BUDGET_CORE=y
CONFIG_DVB_BUDGET=y
CONFIG_DVB_BUDGET_CI=y
CONFIG_DVB_BUDGET_AV=y
CONFIG_DVB_BUDGET_PATCH=y

#
# Supported USB Adapters
#
CONFIG_DVB_USB=y
# CONFIG_DVB_USB_DEBUG is not set
CONFIG_DVB_USB_A800=y
CONFIG_DVB_USB_DIBUSB_MB=y
CONFIG_DVB_USB_DIBUSB_MB_FAULTY=y
CONFIG_DVB_USB_DIBUSB_MC=y
CONFIG_DVB_USB_DIB0700=y
CONFIG_DVB_USB_UMT_010=y
CONFIG_DVB_USB_CXUSB=y
CONFIG_DVB_USB_M920X=y
CONFIG_DVB_USB_GL861=y
CONFIG_DVB_USB_AU6610=y
CONFIG_DVB_USB_DIGITV=y
CONFIG_DVB_USB_VP7045=y
CONFIG_DVB_USB_VP702X=y
CONFIG_DVB_USB_GP8PSK=y
CONFIG_DVB_USB_NOVA_T_USB2=y
CONFIG_DVB_USB_TTUSB2=y
CONFIG_DVB_USB_DTT200U=y
CONFIG_DVB_USB_OPERA1=y
CONFIG_DVB_USB_AF9005=y
CONFIG_DVB_USB_AF9005_REMOTE=y
# CONFIG_DVB_USB_PCTV452E is not set
CONFIG_DVB_USB_DW2102=y
CONFIG_DVB_USB_CINERGY_T2=y
CONFIG_DVB_USB_ANYSEE=y
CONFIG_DVB_USB_DTV5100=y
CONFIG_DVB_USB_AF9015=y
CONFIG_DVB_USB_CE6230=y
CONFIG_DVB_USB_FRIIO=y
CONFIG_DVB_USB_EC168=y
# CONFIG_DVB_USB_AZ6007 is not set
CONFIG_DVB_USB_AZ6027=y
CONFIG_DVB_USB_LME2510=y
CONFIG_DVB_USB_TECHNISAT_USB2=y
CONFIG_DVB_USB_IT913X=y
# CONFIG_DVB_USB_MXL111SF is not set
# CONFIG_DVB_USB_RTL28XXU is not set
# CONFIG_DVB_USB_AF9035 is not set
CONFIG_DVB_TTUSB_BUDGET=y
CONFIG_DVB_TTUSB_DEC=y
CONFIG_SMS_SIANO_MDTV=y

#
# Siano module components
#
CONFIG_SMS_USB_DRV=y
CONFIG_SMS_SDIO_DRV=y

#
# Supported FlexCopII (B2C2) Adapters
#
CONFIG_DVB_B2C2_FLEXCOP=y
CONFIG_DVB_B2C2_FLEXCOP_PCI=y
CONFIG_DVB_B2C2_FLEXCOP_USB=y
# CONFIG_DVB_B2C2_FLEXCOP_DEBUG is not set

#
# Supported BT878 Adapters
#
CONFIG_DVB_BT8XX=y

#
# Supported Pluto2 Adapters
#
CONFIG_DVB_PLUTO2=y

#
# Supported SDMC DM1105 Adapters
#
CONFIG_DVB_DM1105=y

#
# Supported FireWire (IEEE 1394) Adapters
#
CONFIG_DVB_FIREDTV=y
CONFIG_DVB_FIREDTV_INPUT=y

#
# Supported Earthsoft PT1 Adapters
#
CONFIG_DVB_PT1=y

#
# Supported Mantis Adapters
#
CONFIG_MANTIS_CORE=y
CONFIG_DVB_MANTIS=y
CONFIG_DVB_HOPPER=y

#
# Supported nGene Adapters
#
CONFIG_DVB_NGENE=y

#
# Supported ddbridge ('Octopus') Adapters
#
# CONFIG_DVB_DDBRIDGE is not set

#
# Supported DVB Frontends
#
# CONFIG_DVB_FE_CUSTOMISE is not set

#
# Multistandard (satellite) frontends
#
CONFIG_DVB_STB0899=y
CONFIG_DVB_STB6100=y
CONFIG_DVB_STV090x=y
CONFIG_DVB_STV6110x=y

#
# Multistandard (cable + terrestrial) frontends
#
CONFIG_DVB_DRXK=y
CONFIG_DVB_TDA18271C2DD=y

#
# DVB-S (satellite) frontends
#
CONFIG_DVB_CX24110=y
CONFIG_DVB_CX24123=y
CONFIG_DVB_MT312=y
CONFIG_DVB_ZL10036=y
CONFIG_DVB_ZL10039=y
CONFIG_DVB_S5H1420=y
CONFIG_DVB_STV0288=y
CONFIG_DVB_STB6000=y
CONFIG_DVB_STV0299=y
CONFIG_DVB_STV6110=y
CONFIG_DVB_STV0900=y
CONFIG_DVB_TDA8083=y
CONFIG_DVB_TDA10086=y
CONFIG_DVB_TDA8261=y
CONFIG_DVB_VES1X93=y
CONFIG_DVB_TUNER_ITD1000=y
CONFIG_DVB_TUNER_CX24113=y
CONFIG_DVB_TDA826X=y
CONFIG_DVB_TUA6100=y
CONFIG_DVB_CX24116=y
CONFIG_DVB_SI21XX=y
CONFIG_DVB_DS3000=y
CONFIG_DVB_MB86A16=y
CONFIG_DVB_TDA10071=y

#
# DVB-T (terrestrial) frontends
#
CONFIG_DVB_SP8870=y
CONFIG_DVB_SP887X=y
CONFIG_DVB_CX22700=y
CONFIG_DVB_CX22702=y
CONFIG_DVB_DRXD=y
CONFIG_DVB_L64781=y
CONFIG_DVB_TDA1004X=y
CONFIG_DVB_NXT6000=y
CONFIG_DVB_MT352=y
CONFIG_DVB_ZL10353=y
CONFIG_DVB_DIB3000MB=y
CONFIG_DVB_DIB3000MC=y
CONFIG_DVB_DIB7000M=y
CONFIG_DVB_DIB7000P=y
CONFIG_DVB_TDA10048=y
CONFIG_DVB_AF9013=y
CONFIG_DVB_EC100=y
CONFIG_DVB_STV0367=y
CONFIG_DVB_CXD2820R=y

#
# DVB-C (cable) frontends
#
CONFIG_DVB_VES1820=y
CONFIG_DVB_TDA10021=y
CONFIG_DVB_TDA10023=y
CONFIG_DVB_STV0297=y

#
# ATSC (North American/Korean Terrestrial/Cable DTV) frontends
#
CONFIG_DVB_NXT200X=y
CONFIG_DVB_OR51211=y
CONFIG_DVB_OR51132=y
CONFIG_DVB_BCM3510=y
CONFIG_DVB_LGDT330X=y
CONFIG_DVB_LGDT3305=y
CONFIG_DVB_S5H1409=y
CONFIG_DVB_AU8522=y
CONFIG_DVB_AU8522_DTV=y
CONFIG_DVB_AU8522_V4L=y
CONFIG_DVB_S5H1411=y

#
# ISDB-T (terrestrial) frontends
#
CONFIG_DVB_S921=y
CONFIG_DVB_DIB8000=y
CONFIG_DVB_MB86A20S=y

#
# Digital terrestrial only tuners/PLL
#
CONFIG_DVB_PLL=y
CONFIG_DVB_TUNER_DIB0070=y
CONFIG_DVB_TUNER_DIB0090=y

#
# SEC control devices for DVB-S
#
CONFIG_DVB_LNBP21=y
CONFIG_DVB_ISL6405=y
CONFIG_DVB_ISL6421=y
CONFIG_DVB_ISL6423=y
CONFIG_DVB_A8293=y
CONFIG_DVB_LGS8GXX=y
CONFIG_DVB_ATBM8830=y
CONFIG_DVB_TDA665x=y
CONFIG_DVB_IX2505V=y
CONFIG_DVB_IT913X_FE=y
CONFIG_DVB_M88RS2000=y

#
# Tools to develop new frontends
#
# CONFIG_DVB_DUMMY_FE is not set

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
CONFIG_DRM_NOUVEAU=y
CONFIG_DRM_NOUVEAU_BACKLIGHT=y
# CONFIG_DRM_NOUVEAU_DEBUG is not set

#
# I2C encoder or helper chips
#
CONFIG_DRM_I2C_CH7006=y
CONFIG_DRM_I2C_SIL164=y
# CONFIG_DRM_I810 is not set
CONFIG_DRM_I915=y
CONFIG_DRM_I915_KMS=y
CONFIG_DRM_MGA=y
CONFIG_DRM_SIS=y
CONFIG_DRM_VIA=y
CONFIG_DRM_SAVAGE=y
CONFIG_DRM_VMWGFX=y
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
CONFIG_FB_VIA_X_COMPATIBILITY=y
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
# CONFIG_FB_SMSCUFX is not set
CONFIG_FB_UDL=y
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
CONFIG_BACKLIGHT_APPLE=y
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
CONFIG_SND_ALOOP=y
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
CONFIG_SND_TEA575X=y
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
CONFIG_SND_ES1968_RADIO=y
CONFIG_SND_FM801=y
CONFIG_SND_FM801_TEA575X_BOOL=y
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
CONFIG_SND_HDA_POWER_SAVE=y
CONFIG_SND_HDA_POWER_SAVE_DEFAULT=0
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
CONFIG_SND_LOLA=y
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
CONFIG_SND_USB=y
CONFIG_SND_USB_AUDIO=y
CONFIG_SND_USB_UA101=y
CONFIG_SND_USB_USX2Y=y
CONFIG_SND_USB_CAIAQ=y
CONFIG_SND_USB_CAIAQ_INPUT=y
CONFIG_SND_USB_US122L=y
CONFIG_SND_USB_6FIRE=y
CONFIG_SND_FIREWIRE=y
CONFIG_SND_FIREWIRE_LIB=y
CONFIG_SND_FIREWIRE_SPEAKERS=y
CONFIG_SND_ISIGHT=y
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
CONFIG_HID_GENERIC=y

#
# Special HID drivers
#
CONFIG_HID_A4TECH=y
CONFIG_HID_ACRUX=y
# CONFIG_HID_ACRUX_FF is not set
CONFIG_HID_APPLE=y
# CONFIG_HID_AUREAL is not set
CONFIG_HID_BELKIN=y
CONFIG_HID_CHERRY=y
CONFIG_HID_CHICONY=y
CONFIG_HID_PRODIKEYS=y
CONFIG_HID_CYPRESS=y
CONFIG_HID_DRAGONRISE=y
CONFIG_DRAGONRISE_FF=y
CONFIG_HID_EMS_FF=y
CONFIG_HID_EZKEY=y
# CONFIG_HID_HOLTEK is not set
CONFIG_HID_KEYTOUCH=y
CONFIG_HID_KYE=y
CONFIG_HID_UCLOGIC=y
CONFIG_HID_WALTOP=y
CONFIG_HID_GYRATION=y
CONFIG_HID_TWINHAN=y
CONFIG_HID_KENSINGTON=y
CONFIG_HID_LCPOWER=y
CONFIG_HID_LOGITECH=y
CONFIG_HID_LOGITECH_DJ=y
CONFIG_LOGITECH_FF=y
CONFIG_LOGIRUMBLEPAD2_FF=y
CONFIG_LOGIG940_FF=y
CONFIG_LOGIWHEELS_FF=y
CONFIG_HID_MICROSOFT=y
CONFIG_HID_MONTEREY=y
CONFIG_HID_MULTITOUCH=y
CONFIG_HID_NTRIG=y
CONFIG_HID_ORTEK=y
CONFIG_HID_PANTHERLORD=y
CONFIG_PANTHERLORD_FF=y
CONFIG_HID_PETALYNX=y
CONFIG_HID_PICOLCD=y
CONFIG_HID_PICOLCD_FB=y
CONFIG_HID_PICOLCD_BACKLIGHT=y
CONFIG_HID_PICOLCD_LEDS=y
# CONFIG_HID_PRIMAX is not set
CONFIG_HID_ROCCAT=y
# CONFIG_HID_SAITEK is not set
CONFIG_HID_SAMSUNG=y
CONFIG_HID_SONY=y
# CONFIG_HID_SPEEDLINK is not set
CONFIG_HID_SUNPLUS=y
CONFIG_HID_GREENASIA=y
CONFIG_GREENASIA_FF=y
# CONFIG_HID_HYPERV_MOUSE is not set
CONFIG_HID_SMARTJOYPLUS=y
CONFIG_SMARTJOYPLUS_FF=y
# CONFIG_HID_TIVO is not set
CONFIG_HID_TOPSEED=y
CONFIG_HID_THRUSTMASTER=y
CONFIG_THRUSTMASTER_FF=y
CONFIG_HID_ZEROPLUS=y
CONFIG_ZEROPLUS_FF=y
CONFIG_HID_ZYDACRON=y

#
# USB HID support
#
CONFIG_USB_HID=y
CONFIG_HID_PID=y
CONFIG_USB_HIDDEV=y
CONFIG_USB_ARCH_HAS_OHCI=y
CONFIG_USB_ARCH_HAS_EHCI=y
CONFIG_USB_ARCH_HAS_XHCI=y
CONFIG_USB_SUPPORT=y
CONFIG_USB_COMMON=y
CONFIG_USB_ARCH_HAS_HCD=y
CONFIG_USB=y
# CONFIG_USB_DEBUG is not set
CONFIG_USB_ANNOUNCE_NEW_DEVICES=y

#
# Miscellaneous USB options
#
CONFIG_USB_DYNAMIC_MINORS=y
CONFIG_USB_SUSPEND=y
# CONFIG_USB_OTG is not set
# CONFIG_USB_DWC3 is not set
CONFIG_USB_MON=y
CONFIG_USB_WUSB=y
CONFIG_USB_WUSB_CBAF=y
# CONFIG_USB_WUSB_CBAF_DEBUG is not set

#
# USB Host Controller Drivers
#
CONFIG_USB_C67X00_HCD=y
CONFIG_USB_XHCI_HCD=y
# CONFIG_USB_XHCI_HCD_DEBUGGING is not set
CONFIG_USB_EHCI_HCD=y
CONFIG_USB_EHCI_ROOT_HUB_TT=y
CONFIG_USB_EHCI_TT_NEWSCHED=y
# CONFIG_USB_OXU210HP_HCD is not set
CONFIG_USB_ISP116X_HCD=y
# CONFIG_USB_ISP1760_HCD is not set
# CONFIG_USB_ISP1362_HCD is not set
CONFIG_USB_OHCI_HCD=y
# CONFIG_USB_OHCI_HCD_SSB is not set
# CONFIG_USB_OHCI_HCD_PLATFORM is not set
# CONFIG_USB_EHCI_HCD_PLATFORM is not set
# CONFIG_USB_OHCI_BIG_ENDIAN_DESC is not set
# CONFIG_USB_OHCI_BIG_ENDIAN_MMIO is not set
CONFIG_USB_OHCI_LITTLE_ENDIAN=y
CONFIG_USB_UHCI_HCD=y
CONFIG_USB_U132_HCD=y
CONFIG_USB_SL811_HCD=y
# CONFIG_USB_SL811_HCD_ISO is not set
CONFIG_USB_SL811_CS=y
CONFIG_USB_R8A66597_HCD=y
CONFIG_USB_WHCI_HCD=y
CONFIG_USB_HWA_HCD=y
# CONFIG_USB_HCD_BCMA is not set
# CONFIG_USB_HCD_SSB is not set
# CONFIG_USB_MUSB_HDRC is not set
# CONFIG_USB_CHIPIDEA is not set
# CONFIG_USB_RENESAS_USBHS is not set

#
# USB Device Class drivers
#
CONFIG_USB_ACM=y
CONFIG_USB_PRINTER=y
CONFIG_USB_WDM=y
CONFIG_USB_TMC=y

#
# NOTE: USB_STORAGE depends on SCSI but BLK_DEV_SD may
#

#
# also be needed; see USB_STORAGE Help for more info
#
CONFIG_USB_STORAGE=y
# CONFIG_USB_STORAGE_DEBUG is not set
CONFIG_USB_STORAGE_REALTEK=y
CONFIG_REALTEK_AUTOPM=y
CONFIG_USB_STORAGE_DATAFAB=y
CONFIG_USB_STORAGE_FREECOM=y
CONFIG_USB_STORAGE_ISD200=y
CONFIG_USB_STORAGE_USBAT=y
CONFIG_USB_STORAGE_SDDR09=y
CONFIG_USB_STORAGE_SDDR55=y
CONFIG_USB_STORAGE_JUMPSHOT=y
CONFIG_USB_STORAGE_ALAUDA=y
CONFIG_USB_STORAGE_ONETOUCH=y
CONFIG_USB_STORAGE_KARMA=y
CONFIG_USB_STORAGE_CYPRESS_ATACB=y
CONFIG_USB_STORAGE_ENE_UB6250=y
CONFIG_USB_UAS=y
# CONFIG_USB_LIBUSUAL is not set

#
# USB Imaging devices
#
CONFIG_USB_MDC800=y
CONFIG_USB_MICROTEK=y

#
# USB port drivers
#
CONFIG_USB_USS720=y
CONFIG_USB_SERIAL=y
# CONFIG_USB_SERIAL_CONSOLE is not set
CONFIG_USB_EZUSB=y
CONFIG_USB_SERIAL_GENERIC=y
CONFIG_USB_SERIAL_AIRCABLE=y
CONFIG_USB_SERIAL_ARK3116=y
CONFIG_USB_SERIAL_BELKIN=y
CONFIG_USB_SERIAL_CH341=y
CONFIG_USB_SERIAL_WHITEHEAT=y
CONFIG_USB_SERIAL_DIGI_ACCELEPORT=y
CONFIG_USB_SERIAL_CP210X=y
CONFIG_USB_SERIAL_CYPRESS_M8=y
CONFIG_USB_SERIAL_EMPEG=y
CONFIG_USB_SERIAL_FTDI_SIO=y
CONFIG_USB_SERIAL_FUNSOFT=y
CONFIG_USB_SERIAL_VISOR=y
CONFIG_USB_SERIAL_IPAQ=y
CONFIG_USB_SERIAL_IR=y
CONFIG_USB_SERIAL_EDGEPORT=y
CONFIG_USB_SERIAL_EDGEPORT_TI=y
# CONFIG_USB_SERIAL_F81232 is not set
CONFIG_USB_SERIAL_GARMIN=y
CONFIG_USB_SERIAL_IPW=y
CONFIG_USB_SERIAL_IUU=y
CONFIG_USB_SERIAL_KEYSPAN_PDA=y
CONFIG_USB_SERIAL_KEYSPAN=y
CONFIG_USB_SERIAL_KLSI=y
CONFIG_USB_SERIAL_KOBIL_SCT=y
CONFIG_USB_SERIAL_MCT_U232=y
# CONFIG_USB_SERIAL_METRO is not set
CONFIG_USB_SERIAL_MOS7720=y
CONFIG_USB_SERIAL_MOS7715_PARPORT=y
CONFIG_USB_SERIAL_MOS7840=y
CONFIG_USB_SERIAL_MOTOROLA=y
CONFIG_USB_SERIAL_NAVMAN=y
CONFIG_USB_SERIAL_PL2303=y
CONFIG_USB_SERIAL_OTI6858=y
CONFIG_USB_SERIAL_QCAUX=y
CONFIG_USB_SERIAL_QUALCOMM=y
CONFIG_USB_SERIAL_SPCP8X5=y
CONFIG_USB_SERIAL_HP4X=y
CONFIG_USB_SERIAL_SAFE=y
# CONFIG_USB_SERIAL_SAFE_PADDED is not set
CONFIG_USB_SERIAL_SIEMENS_MPI=y
CONFIG_USB_SERIAL_SIERRAWIRELESS=y
CONFIG_USB_SERIAL_SYMBOL=y
CONFIG_USB_SERIAL_TI=y
CONFIG_USB_SERIAL_CYBERJACK=y
CONFIG_USB_SERIAL_XIRCOM=y
CONFIG_USB_SERIAL_WWAN=y
CONFIG_USB_SERIAL_OPTION=y
CONFIG_USB_SERIAL_OMNINET=y
CONFIG_USB_SERIAL_OPTICON=y
CONFIG_USB_SERIAL_VIVOPAY_SERIAL=y
CONFIG_USB_SERIAL_ZIO=y
CONFIG_USB_SERIAL_SSU100=y
# CONFIG_USB_SERIAL_QT2 is not set
CONFIG_USB_SERIAL_DEBUG=y

#
# USB Miscellaneous drivers
#
CONFIG_USB_EMI62=y
CONFIG_USB_EMI26=y
CONFIG_USB_ADUTUX=y
CONFIG_USB_SEVSEG=y
CONFIG_USB_RIO500=y
CONFIG_USB_LEGOTOWER=y
CONFIG_USB_LCD=y
CONFIG_USB_LED=y
CONFIG_USB_CYPRESS_CY7C63=y
CONFIG_USB_CYTHERM=y
CONFIG_USB_IDMOUSE=y
CONFIG_USB_FTDI_ELAN=y
CONFIG_USB_APPLEDISPLAY=y
CONFIG_USB_SISUSBVGA=y
CONFIG_USB_SISUSBVGA_CON=y
CONFIG_USB_LD=y
CONFIG_USB_TRANCEVIBRATOR=y
CONFIG_USB_IOWARRIOR=y
CONFIG_USB_TEST=y
CONFIG_USB_ISIGHTFW=y
CONFIG_USB_YUREX=y

#
# USB Physical Layer drivers
#
# CONFIG_USB_ISP1301 is not set
CONFIG_USB_ATM=y
CONFIG_USB_SPEEDTOUCH=y
CONFIG_USB_CXACRU=y
CONFIG_USB_UEAGLEATM=y
CONFIG_USB_XUSBATM=y
CONFIG_USB_GADGET=y
# CONFIG_USB_GADGET_DEBUG is not set
# CONFIG_USB_GADGET_DEBUG_FILES is not set
# CONFIG_USB_GADGET_DEBUG_FS is not set
CONFIG_USB_GADGET_VBUS_DRAW=2
CONFIG_USB_GADGET_STORAGE_NUM_BUFFERS=2

#
# USB Peripheral Controller
#
# CONFIG_USB_R8A66597 is not set
# CONFIG_USB_MV_UDC is not set
# CONFIG_USB_M66592 is not set
# CONFIG_USB_AMD5536UDC is not set
# CONFIG_USB_NET2272 is not set
# CONFIG_USB_NET2280 is not set
# CONFIG_USB_GOKU is not set
CONFIG_USB_EG20T=m
# CONFIG_USB_DUMMY_HCD is not set
CONFIG_USB_GADGET_DUALSPEED=y
# CONFIG_USB_ZERO is not set
# CONFIG_USB_AUDIO is not set
# CONFIG_USB_ETH is not set
# CONFIG_USB_G_NCM is not set
# CONFIG_USB_GADGETFS is not set
# CONFIG_USB_FUNCTIONFS is not set
# CONFIG_USB_FILE_STORAGE is not set
# CONFIG_USB_MASS_STORAGE is not set
# CONFIG_USB_GADGET_TARGET is not set
# CONFIG_USB_G_SERIAL is not set
# CONFIG_USB_MIDI_GADGET is not set
# CONFIG_USB_G_PRINTER is not set
# CONFIG_USB_CDC_COMPOSITE is not set
# CONFIG_USB_G_NOKIA is not set
# CONFIG_USB_G_ACM_MS is not set
# CONFIG_USB_G_MULTI is not set
# CONFIG_USB_G_HID is not set
# CONFIG_USB_G_DBGP is not set
# CONFIG_USB_G_WEBCAM is not set

#
# OTG and related infrastructure
#
CONFIG_USB_OTG_UTILS=y
# CONFIG_USB_GPIO_VBUS is not set
CONFIG_NOP_USB_XCEIV=y
CONFIG_UWB=y
CONFIG_UWB_HWA=y
CONFIG_UWB_WHCI=y
CONFIG_UWB_I1480U=y
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
CONFIG_MMC_VUB300=y
CONFIG_MMC_USHC=y
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
CONFIG_MEMSTICK_R592=y
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
# CONFIG_LEDS_OT200 is not set
CONFIG_LEDS_TRIGGERS=y

#
# LED Triggers
#
CONFIG_LEDS_TRIGGER_TIMER=y
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
# CONFIG_INFINIBAND_SRPT is not set
CONFIG_INFINIBAND_ISER=y
CONFIG_EDAC=y

#
# Reporting subsystems
#
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
CONFIG_EDAC_I7300=y
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
CONFIG_PCH_DMA=y
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
CONFIG_VIRTIO=y
CONFIG_VIRTIO_RING=y

#
# Virtio drivers
#
CONFIG_VIRTIO_PCI=y
CONFIG_VIRTIO_BALLOON=y
CONFIG_VIRTIO_MMIO=y
# CONFIG_VIRTIO_MMIO_CMDLINE_DEVICES is not set

#
# Microsoft Hyper-V guest support
#
CONFIG_HYPERV=y
CONFIG_HYPERV_UTILS=y

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
CONFIG_XEN_GNTDEV=y
CONFIG_XEN_GRANT_DEV_ALLOC=y
CONFIG_SWIOTLB_XEN=y
CONFIG_XEN_PCIDEV_BACKEND=y
CONFIG_XEN_PRIVCMD=y
CONFIG_XEN_ACPI_PROCESSOR=m
CONFIG_STAGING=y
CONFIG_ET131X=y
# CONFIG_SLICOSS is not set
CONFIG_USBIP_CORE=y
CONFIG_USBIP_VHCI_HCD=y
CONFIG_USBIP_HOST=y
# CONFIG_USBIP_DEBUG is not set
# CONFIG_W35UND is not set
CONFIG_PRISM2_USB=y
# CONFIG_ECHO is not set
CONFIG_COMEDI=m
# CONFIG_COMEDI_DEBUG is not set
CONFIG_COMEDI_DEFAULT_BUF_SIZE_KB=2048
CONFIG_COMEDI_DEFAULT_BUF_MAXSIZE_KB=20480
CONFIG_COMEDI_MISC_DRIVERS=m
CONFIG_COMEDI_KCOMEDILIB=m
CONFIG_COMEDI_BOND=m
CONFIG_COMEDI_TEST=m
CONFIG_COMEDI_PARPORT=m
CONFIG_COMEDI_SERIAL2002=m
# CONFIG_COMEDI_SKEL is not set
CONFIG_COMEDI_PCI_DRIVERS=m
CONFIG_COMEDI_ADDI_APCI_035=m
CONFIG_COMEDI_ADDI_APCI_1032=m
CONFIG_COMEDI_ADDI_APCI_1500=m
CONFIG_COMEDI_ADDI_APCI_1516=m
CONFIG_COMEDI_ADDI_APCI_1564=m
CONFIG_COMEDI_ADDI_APCI_16XX=m
CONFIG_COMEDI_ADDI_APCI_2016=m
CONFIG_COMEDI_ADDI_APCI_2032=m
CONFIG_COMEDI_ADDI_APCI_2200=m
CONFIG_COMEDI_ADDI_APCI_3001=m
CONFIG_COMEDI_ADDI_APCI_3120=m
CONFIG_COMEDI_ADDI_APCI_3501=m
CONFIG_COMEDI_ADDI_APCI_3XXX=m
CONFIG_COMEDI_ADL_PCI6208=m
# CONFIG_COMEDI_ADL_PCI7230 is not set
CONFIG_COMEDI_ADL_PCI7296=m
CONFIG_COMEDI_ADL_PCI7432=m
CONFIG_COMEDI_ADL_PCI8164=m
CONFIG_COMEDI_ADL_PCI9111=m
CONFIG_COMEDI_ADL_PCI9118=m
CONFIG_COMEDI_ADV_PCI1710=m
CONFIG_COMEDI_ADV_PCI1723=m
CONFIG_COMEDI_ADV_PCI_DIO=m
# CONFIG_COMEDI_AMPLC_DIO200_PCI is not set
# CONFIG_COMEDI_AMPLC_PC236_PCI is not set
# CONFIG_COMEDI_AMPLC_PC263_PCI is not set
CONFIG_COMEDI_AMPLC_PCI224=m
CONFIG_COMEDI_AMPLC_PCI230=m
CONFIG_COMEDI_CONTEC_PCI_DIO=m
# CONFIG_COMEDI_DAS08_PCI is not set
CONFIG_COMEDI_DT3000=m
# CONFIG_COMEDI_DYNA_PCI10XX is not set
CONFIG_COMEDI_UNIOXX5=m
CONFIG_COMEDI_GSC_HPDI=m
CONFIG_COMEDI_ICP_MULTI=m
CONFIG_COMEDI_II_PCI20KC=m
CONFIG_COMEDI_DAQBOARD2000=m
CONFIG_COMEDI_JR3_PCI=m
CONFIG_COMEDI_KE_COUNTER=m
CONFIG_COMEDI_CB_PCIDAS64=m
CONFIG_COMEDI_CB_PCIDAS=m
CONFIG_COMEDI_CB_PCIDDA=m
CONFIG_COMEDI_CB_PCIDIO=m
CONFIG_COMEDI_CB_PCIMDAS=m
CONFIG_COMEDI_CB_PCIMDDA=m
CONFIG_COMEDI_ME4000=m
CONFIG_COMEDI_ME_DAQ=m
CONFIG_COMEDI_NI_6527=m
CONFIG_COMEDI_NI_65XX=m
CONFIG_COMEDI_NI_660X=m
CONFIG_COMEDI_NI_670X=m
CONFIG_COMEDI_NI_PCIDIO=m
CONFIG_COMEDI_NI_PCIMIO=m
CONFIG_COMEDI_RTD520=m
CONFIG_COMEDI_S526=m
CONFIG_COMEDI_S626=m
CONFIG_COMEDI_SSV_DNP=m
CONFIG_COMEDI_PCMCIA_DRIVERS=m
CONFIG_COMEDI_CB_DAS16_CS=m
CONFIG_COMEDI_DAS08_CS=m
CONFIG_COMEDI_NI_DAQ_700_CS=m
CONFIG_COMEDI_NI_DAQ_DIO24_CS=m
CONFIG_COMEDI_NI_LABPC_CS=m
CONFIG_COMEDI_NI_MIO_CS=m
CONFIG_COMEDI_QUATECH_DAQP_CS=m
CONFIG_COMEDI_USB_DRIVERS=m
CONFIG_COMEDI_DT9812=m
CONFIG_COMEDI_USBDUX=m
CONFIG_COMEDI_USBDUXFAST=m
# CONFIG_COMEDI_USBDUXSIGMA is not set
CONFIG_COMEDI_VMK80XX=m
CONFIG_COMEDI_NI_COMMON=m
CONFIG_COMEDI_MITE=m
CONFIG_COMEDI_NI_TIO=m
CONFIG_COMEDI_NI_LABPC=m
CONFIG_COMEDI_8255=m
CONFIG_COMEDI_FC=m
CONFIG_COMEDI_DAS08=m
# CONFIG_ASUS_OLED is not set
# CONFIG_PANEL is not set
CONFIG_R8187SE=m
CONFIG_RTL8192U=m
# CONFIG_RTLLIB is not set
CONFIG_R8712U=y
CONFIG_RTS_PSTOR=y
# CONFIG_RTS_PSTOR_DEBUG is not set
# CONFIG_RTS5139 is not set
# CONFIG_TRANZPORT is not set
# CONFIG_IDE_PHISON is not set
# CONFIG_LINE6_USB is not set
# CONFIG_USB_SERIAL_QUATECH2 is not set
# CONFIG_VT6655 is not set
CONFIG_VT6656=m
# CONFIG_DX_SEP is not set
CONFIG_ZRAM=y
# CONFIG_ZRAM_DEBUG is not set
CONFIG_ZSMALLOC=y
# CONFIG_WLAGS49_H2 is not set
# CONFIG_WLAGS49_H25 is not set
# CONFIG_FB_SM7XX is not set
# CONFIG_CRYSTALHD is not set
# CONFIG_CXT1E1 is not set
# CONFIG_FB_XGI is not set
# CONFIG_ACPI_QUICKSTART is not set
# CONFIG_SBE_2T3E3 is not set
# CONFIG_USB_ENESTORAGE is not set
# CONFIG_BCM_WIMAX is not set
# CONFIG_FT1000 is not set

#
# Speakup console speech
#
CONFIG_SPEAKUP=y
CONFIG_SPEAKUP_SYNTH_ACNTSA=y
CONFIG_SPEAKUP_SYNTH_ACNTPC=y
CONFIG_SPEAKUP_SYNTH_APOLLO=y
CONFIG_SPEAKUP_SYNTH_AUDPTR=y
CONFIG_SPEAKUP_SYNTH_BNS=y
CONFIG_SPEAKUP_SYNTH_DECTLK=y
CONFIG_SPEAKUP_SYNTH_DECEXT=y
# CONFIG_SPEAKUP_SYNTH_DECPC is not set
CONFIG_SPEAKUP_SYNTH_DTLK=y
CONFIG_SPEAKUP_SYNTH_KEYPC=y
CONFIG_SPEAKUP_SYNTH_LTLK=y
CONFIG_SPEAKUP_SYNTH_SOFT=y
CONFIG_SPEAKUP_SYNTH_SPKOUT=y
CONFIG_SPEAKUP_SYNTH_TXPRT=y
CONFIG_SPEAKUP_SYNTH_DUMMY=y
# CONFIG_TOUCHSCREEN_CLEARPAD_TM1217 is not set
# CONFIG_TOUCHSCREEN_SYNAPTICS_I2C_RMI4 is not set
CONFIG_STAGING_MEDIA=y
# CONFIG_DVB_AS102 is not set
# CONFIG_DVB_CXD2099 is not set
# CONFIG_VIDEO_DT3155 is not set
CONFIG_EASYCAP=y
# CONFIG_EASYCAP_DEBUG is not set
# CONFIG_VIDEO_GO7007 is not set
# CONFIG_SOLO6X10 is not set
CONFIG_LIRC_STAGING=y
CONFIG_LIRC_BT829=y
CONFIG_LIRC_IGORPLUGUSB=y
CONFIG_LIRC_IMON=y
# CONFIG_LIRC_PARALLEL is not set
CONFIG_LIRC_SASEM=y
CONFIG_LIRC_SERIAL=y
CONFIG_LIRC_SERIAL_TRANSMITTER=y
CONFIG_LIRC_SIR=y
CONFIG_LIRC_TTUSBIR=y
CONFIG_LIRC_ZILOG=y

#
# Android
#
# CONFIG_ANDROID is not set
CONFIG_PHONE=y
CONFIG_PHONE_IXJ=y
CONFIG_PHONE_IXJ_PCMCIA=y
# CONFIG_USB_WPAN_HCD is not set
# CONFIG_USB_G_CCG is not set
# CONFIG_IPACK_BUS is not set
# CONFIG_WIMAX_GDM72XX is not set
CONFIG_X86_PLATFORM_DEVICES=y
CONFIG_ACER_WMI=y
CONFIG_ACERHDF=y
CONFIG_ASUS_LAPTOP=y
CONFIG_DELL_LAPTOP=y
CONFIG_DELL_WMI=y
CONFIG_DELL_WMI_AIO=y
CONFIG_FUJITSU_LAPTOP=y
# CONFIG_FUJITSU_LAPTOP_DEBUG is not set
# CONFIG_FUJITSU_TABLET is not set
# CONFIG_AMILO_RFKILL is not set
CONFIG_HP_ACCEL=y
CONFIG_HP_WMI=y
CONFIG_MSI_LAPTOP=y
CONFIG_PANASONIC_LAPTOP=y
CONFIG_COMPAL_LAPTOP=y
CONFIG_SONY_LAPTOP=y
CONFIG_SONYPI_COMPAT=y
CONFIG_IDEAPAD_LAPTOP=y
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
CONFIG_ASUS_WMI=y
CONFIG_ASUS_NB_WMI=y
CONFIG_EEEPC_WMI=y
CONFIG_ACPI_WMI=y
CONFIG_MSI_WMI=y
CONFIG_TOPSTAR_LAPTOP=y
CONFIG_ACPI_TOSHIBA=y
CONFIG_TOSHIBA_BT_RFKILL=y
CONFIG_ACPI_CMPC=y
CONFIG_INTEL_IPS=y
# CONFIG_IBM_RTL is not set
# CONFIG_XO15_EBOOK is not set
CONFIG_SAMSUNG_LAPTOP=y
CONFIG_MXM_WMI=y
CONFIG_INTEL_OAKTRAIL=y
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
CONFIG_DMAR_TABLE=y
CONFIG_INTEL_IOMMU=y
# CONFIG_INTEL_IOMMU_DEFAULT_ON is not set
CONFIG_INTEL_IOMMU_FLOPPY_WA=y
CONFIG_IRQ_REMAP=y

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
CONFIG_FANOTIFY=y
# CONFIG_FANOTIFY_ACCESS_PERMISSIONS is not set
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
CONFIG_SQUASHFS_XATTR=y
CONFIG_SQUASHFS_ZLIB=y
CONFIG_SQUASHFS_LZO=y
CONFIG_SQUASHFS_XZ=y
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
CONFIG_NFS_V4_1=y
CONFIG_PNFS_FILE_LAYOUT=y
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
CONFIG_CIFS_FSCACHE=y
CONFIG_CIFS_ACL=y
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
CONFIG_9P_FS_POSIX_ACL=y
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
CONFIG_DEBUG_SECTION_MISMATCH=y
CONFIG_DEBUG_KERNEL=y
CONFIG_DEBUG_SHIRQ=y
CONFIG_LOCKUP_DETECTOR=y
CONFIG_HARDLOCKUP_DETECTOR=y
# CONFIG_BOOTPARAM_HARDLOCKUP_PANIC is not set
CONFIG_BOOTPARAM_HARDLOCKUP_PANIC_VALUE=0
# CONFIG_BOOTPARAM_SOFTLOCKUP_PANIC is not set
CONFIG_BOOTPARAM_SOFTLOCKUP_PANIC_VALUE=0
# CONFIG_PANIC_ON_OOPS is not set
CONFIG_PANIC_ON_OOPS_VALUE=0
CONFIG_DETECT_HUNG_TASK=y
CONFIG_DEFAULT_HUNG_TASK_TIMEOUT=300
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
CONFIG_SPARSE_RCU_POINTER=y
CONFIG_LOCKDEP=y
CONFIG_LOCK_STAT=y
# CONFIG_DEBUG_LOCKDEP is not set
CONFIG_TRACE_IRQFLAGS=y
CONFIG_DEBUG_ATOMIC_SLEEP=y
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
CONFIG_TEST_LIST_SORT=y
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
CONFIG_CPU_NOTIFIER_ERROR_INJECT=y
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
CONFIG_DEBUG_SET_MODULE_RONX=y
CONFIG_DEBUG_NX_TEST=m
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
# CONFIG_INTEL_TXT is not set
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
CONFIG_SECURITY_APPARMOR=y
CONFIG_SECURITY_APPARMOR_BOOTPARAM_VALUE=1
# CONFIG_SECURITY_YAMA is not set
# CONFIG_IMA is not set
# CONFIG_EVM is not set
# CONFIG_DEFAULT_SECURITY_SELINUX is not set
# CONFIG_DEFAULT_SECURITY_TOMOYO is not set
# CONFIG_DEFAULT_SECURITY_APPARMOR is not set
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
CONFIG_CRYPTO_FIPS=y
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
CONFIG_CRYPTO_PCRYPT=y
CONFIG_CRYPTO_WORKQUEUE=y
CONFIG_CRYPTO_CRYPTD=y
CONFIG_CRYPTO_AUTHENC=y
CONFIG_CRYPTO_TEST=m

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
CONFIG_CRYPTO_SHA1_SSSE3=y
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
CONFIG_CRYPTO_BLOWFISH_X86_64=y
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
CONFIG_CRYPTO_TEA=y
CONFIG_CRYPTO_TWOFISH=y
CONFIG_CRYPTO_TWOFISH_COMMON=y
CONFIG_CRYPTO_TWOFISH_X86_64=y
CONFIG_CRYPTO_TWOFISH_X86_64_3WAY=y

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
CONFIG_CRYPTO_USER_API=y
CONFIG_CRYPTO_USER_API_HASH=y
CONFIG_CRYPTO_USER_API_SKCIPHER=y
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
CONFIG_CRC8=y
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
CONFIG_LRU_CACHE=y
CONFIG_AVERAGE=y
CONFIG_CORDIC=y
# CONFIG_DDR is not set

--M9NhX3UHpAaciwkO--
