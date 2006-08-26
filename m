From: Alexey Dobriyan <adobriyan@gmail.com>
Subject: [PATCH] net/*: use SLAB_PANIC
Date: Sun, 27 Aug 2006 03:08:41 +0400
Message-ID: <20060826230841.GA5204@martell.zuzino.mipt.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <netdev-owner@vger.kernel.org>
Received: from nf-out-0910.google.com ([64.233.182.187]:15432 "EHLO
	nf-out-0910.google.com") by vger.kernel.org with ESMTP
	id S1750705AbWHZXIr (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 26 Aug 2006 19:08:47 -0400
Received: by nf-out-0910.google.com with SMTP id o25so1018331nfa
        for <netdev@vger.kernel.org>; Sat, 26 Aug 2006 16:08:45 -0700 (PDT)
To: netdev@vger.kernel.org
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Signed-off-by: Alexey Dobriyan <adobriyan@gmail.com>
---

 Forgive me reformatting, in some cases making it fit in 80 columns was hard.

 net/core/flow.c        |    6 +-----
 net/core/neighbour.c   |   12 ++++--------
 net/core/skbuff.c      |    9 ++-------
 net/decnet/dn_route.c  |   11 +++--------
 net/ipv4/inetpeer.c    |    5 +----
 net/ipv4/ipmr.c        |    5 +----
 net/ipv4/route.c       |   10 +++-------
 net/ipv4/tcp.c         |    4 +---
 net/ipv6/ip6_fib.c     |    4 +---
 net/ipv6/route.c       |   10 +++-------
 net/xfrm/xfrm_input.c  |    4 +---
 net/xfrm/xfrm_policy.c |    5 +----
 12 files changed, 22 insertions(+), 63 deletions(-)

--- a/net/core/flow.c
+++ b/net/core/flow.c
@@ -346,12 +346,8 @@ static int __init flow_cache_init(void)
 
 	flow_cachep = kmem_cache_create("flow_cache",
 					sizeof(struct flow_cache_entry),
-					0, SLAB_HWCACHE_ALIGN,
+					0, SLAB_HWCACHE_ALIGN|SLAB_PANIC,
 					NULL, NULL);
-
-	if (!flow_cachep)
-		panic("NET: failed to allocate flow cache slab\n");
-
 	flow_hash_shift = 10;
 	flow_lwm = 2 * flow_hash_size;
 	flow_hwm = 4 * flow_hash_size;
--- a/net/core/neighbour.c
+++ b/net/core/neighbour.c
@@ -1338,14 +1338,10 @@ void neigh_table_init_no_netlink(struct 
 			  neigh_rand_reach_time(tbl->parms.base_reachable_time);
 
 	if (!tbl->kmem_cachep)
-		tbl->kmem_cachep = kmem_cache_create(tbl->id,
-						     tbl->entry_size,
-						     0, SLAB_HWCACHE_ALIGN,
-						     NULL, NULL);
-
-	if (!tbl->kmem_cachep)
-		panic("cannot create neighbour cache");
-
+		tbl->kmem_cachep =
+			kmem_cache_create(tbl->id, tbl->entry_size, 0,
+					  SLAB_HWCACHE_ALIGN|SLAB_PANIC,
+					  NULL, NULL);
 	tbl->stats = alloc_percpu(struct neigh_statistics);
 	if (!tbl->stats)
 		panic("cannot create neighbour cache statistics");
--- a/net/core/skbuff.c
+++ b/net/core/skbuff.c
@@ -2046,19 +2046,14 @@ void __init skb_init(void)
 	skbuff_head_cache = kmem_cache_create("skbuff_head_cache",
 					      sizeof(struct sk_buff),
 					      0,
-					      SLAB_HWCACHE_ALIGN,
+					      SLAB_HWCACHE_ALIGN|SLAB_PANIC,
 					      NULL, NULL);
-	if (!skbuff_head_cache)
-		panic("cannot create skbuff cache");
-
 	skbuff_fclone_cache = kmem_cache_create("skbuff_fclone_cache",
 						(2*sizeof(struct sk_buff)) +
 						sizeof(atomic_t),
 						0,
-						SLAB_HWCACHE_ALIGN,
+						SLAB_HWCACHE_ALIGN|SLAB_PANIC,
 						NULL, NULL);
-	if (!skbuff_fclone_cache)
-		panic("cannot create skbuff cache");
 }
 
 EXPORT_SYMBOL(___pskb_trim);
--- a/net/decnet/dn_route.c
+++ b/net/decnet/dn_route.c
@@ -1781,14 +1781,9 @@ void __init dn_route_init(void)
 {
 	int i, goal, order;
 
-	dn_dst_ops.kmem_cachep = kmem_cache_create("dn_dst_cache",
-						   sizeof(struct dn_route),
-						   0, SLAB_HWCACHE_ALIGN,
-						   NULL, NULL);
-
-	if (!dn_dst_ops.kmem_cachep)
-		panic("DECnet: Failed to allocate dn_dst_cache\n");
-
+	dn_dst_ops.kmem_cachep =
+		kmem_cache_create("dn_dst_cache", sizeof(struct dn_route), 0,
+				  SLAB_HWCACHE_ALIGN|SLAB_PANIC, NULL, NULL);
 	init_timer(&dn_route_timer);
 	dn_route_timer.function = dn_dst_check_expire;
 	dn_route_timer.expires = jiffies + decnet_dst_gc_interval * HZ;
--- a/net/ipv4/inetpeer.c
+++ b/net/ipv4/inetpeer.c
@@ -126,12 +126,9 @@ void __init inet_initpeers(void)
 
 	peer_cachep = kmem_cache_create("inet_peer_cache",
 			sizeof(struct inet_peer),
-			0, SLAB_HWCACHE_ALIGN,
+			0, SLAB_HWCACHE_ALIGN|SLAB_PANIC,
 			NULL, NULL);
 
-	if (!peer_cachep)
-		panic("cannot create inet_peer_cache");
-
 	/* All the timers, started at system startup tend
 	   to synchronize. Perturb it a bit.
 	 */
--- a/net/ipv4/ipmr.c
+++ b/net/ipv4/ipmr.c
@@ -1899,11 +1899,8 @@ void __init ip_mr_init(void)
 {
 	mrt_cachep = kmem_cache_create("ip_mrt_cache",
 				       sizeof(struct mfc_cache),
-				       0, SLAB_HWCACHE_ALIGN,
+				       0, SLAB_HWCACHE_ALIGN|SLAB_PANIC,
 				       NULL, NULL);
-	if (!mrt_cachep)
-		panic("cannot allocate ip_mrt_cache");
-
 	init_timer(&ipmr_expire_timer);
 	ipmr_expire_timer.function=ipmr_expire_process;
 	register_netdevice_notifier(&ip_mr_notifier);
--- a/net/ipv4/route.c
+++ b/net/ipv4/route.c
@@ -3143,13 +3143,9 @@ #ifdef CONFIG_NET_CLS_ROUTE
 	}
 #endif
 
-	ipv4_dst_ops.kmem_cachep = kmem_cache_create("ip_dst_cache",
-						     sizeof(struct rtable),
-						     0, SLAB_HWCACHE_ALIGN,
-						     NULL, NULL);
-
-	if (!ipv4_dst_ops.kmem_cachep)
-		panic("IP: failed to allocate ip_dst_cache\n");
+	ipv4_dst_ops.kmem_cachep =
+		kmem_cache_create("ip_dst_cache", sizeof(struct rtable), 0,
+				  SLAB_HWCACHE_ALIGN|SLAB_PANIC, NULL, NULL);
 
 	rt_hash_table = (struct rt_hash_bucket *)
 		alloc_large_system_hash("IP route cache",
--- a/net/ipv4/tcp.c
+++ b/net/ipv4/tcp.c
@@ -2254,9 +2254,7 @@ void __init tcp_init(void)
 	tcp_hashinfo.bind_bucket_cachep =
 		kmem_cache_create("tcp_bind_bucket",
 				  sizeof(struct inet_bind_bucket), 0,
-				  SLAB_HWCACHE_ALIGN, NULL, NULL);
-	if (!tcp_hashinfo.bind_bucket_cachep)
-		panic("tcp_init: Cannot alloc tcp_bind_bucket cache.");
+				  SLAB_HWCACHE_ALIGN|SLAB_PANIC, NULL, NULL);
 
 	/* Size and allocate the main established and bind bucket
 	 * hash tables.
--- a/net/ipv6/ip6_fib.c
+++ b/net/ipv6/ip6_fib.c
@@ -1161,10 +1161,8 @@ void __init fib6_init(void)
 {
 	fib6_node_kmem = kmem_cache_create("fib6_nodes",
 					   sizeof(struct fib6_node),
-					   0, SLAB_HWCACHE_ALIGN,
+					   0, SLAB_HWCACHE_ALIGN|SLAB_PANIC,
 					   NULL, NULL);
-	if (!fib6_node_kmem)
-		panic("cannot create fib6_nodes cache");
 }
 
 void fib6_gc_cleanup(void)
--- a/net/ipv6/route.c
+++ b/net/ipv6/route.c
@@ -2256,13 +2256,9 @@ void __init ip6_route_init(void)
 {
 	struct proc_dir_entry *p;
 
-	ip6_dst_ops.kmem_cachep = kmem_cache_create("ip6_dst_cache",
-						     sizeof(struct rt6_info),
-						     0, SLAB_HWCACHE_ALIGN,
-						     NULL, NULL);
-	if (!ip6_dst_ops.kmem_cachep)
-		panic("cannot create ip6_dst_cache");
-
+	ip6_dst_ops.kmem_cachep =
+		kmem_cache_create("ip6_dst_cache", sizeof(struct rt6_info), 0,
+				  SLAB_HWCACHE_ALIGN|SLAB_PANIC, NULL, NULL);
 	fib6_init();
 #ifdef 	CONFIG_PROC_FS
 	p = proc_net_create("ipv6_route", 0, rt6_proc_info);
--- a/net/xfrm/xfrm_input.c
+++ b/net/xfrm/xfrm_input.c
@@ -82,8 +82,6 @@ void __init xfrm_input_init(void)
 {
 	secpath_cachep = kmem_cache_create("secpath_cache",
 					   sizeof(struct sec_path),
-					   0, SLAB_HWCACHE_ALIGN,
+					   0, SLAB_HWCACHE_ALIGN|SLAB_PANIC,
 					   NULL, NULL);
-	if (!secpath_cachep)
-		panic("XFRM: failed to allocate secpath_cache\n");
 }
--- a/net/xfrm/xfrm_policy.c
+++ b/net/xfrm/xfrm_policy.c
@@ -1450,11 +1450,8 @@ static void __init xfrm_policy_init(void
 {
 	xfrm_dst_cache = kmem_cache_create("xfrm_dst_cache",
 					   sizeof(struct xfrm_dst),
-					   0, SLAB_HWCACHE_ALIGN,
+					   0, SLAB_HWCACHE_ALIGN|SLAB_PANIC,
 					   NULL, NULL);
-	if (!xfrm_dst_cache)
-		panic("XFRM: failed to allocate xfrm_dst_cache\n");
-
 	INIT_WORK(&xfrm_policy_gc_work, xfrm_policy_gc_task, NULL);
 	register_netdevice_notifier(&xfrm_dev_notifier);
 }

