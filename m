From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?=
	<yoshfuji@linux-ipv6.org>
Subject: [GIT PULL net-2.6.26] [NET,IPV6]: Neighbor updates.
Date: Fri, 28 Mar 2008 14:08:46 +0900 (JST)
Message-ID: <20080328.140846.116544440.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: yoshfuji@linux-ipv6.org, netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from yue.linux-ipv6.org ([203.178.140.15]:55400 "EHLO
	yue.st-paulia.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751243AbYC1FHR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 28 Mar 2008 01:07:17 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Dave,

Please consider pulling the following changes on top of net-2.6.26 available at
	git://git.linux-ipv6.org/gitroot/yoshfuji/linux-2.6-dev.git net-2.6.26-inet-2.6.26-20080328b

---
HEADLINES
---------

    [NET] NEIGHBOUR: Make each EXPORT_SYMBOL{,_GPL}() immediately follow its function/variable.
    [NET] NEIGHBOUR: Extract hash/lookup functions for pneigh entries.
    [IPV6] NEIGH: Optimize is_router check.

DIFFSTAT
--------

 net/core/neighbour.c |  114 +++++++++++++++++++++++---------------------------
 net/ipv6/ndisc.c     |   22 +++++-----
 2 files changed, 64 insertions(+), 72 deletions(-)

CHANGESETS
----------

commit 0a204500f913974b4ca9b6f509a43e1544239c6d
Author: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Date:   Mon Mar 24 18:39:10 2008 +0900

    [NET] NEIGHBOUR: Make each EXPORT_SYMBOL{,_GPL}() immediately follow its function/variable.
    
    Signed-off-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>

diff --git a/net/core/neighbour.c b/net/core/neighbour.c
index d8d0ca9..d4fae81 100644
--- a/net/core/neighbour.c
+++ b/net/core/neighbour.c
@@ -123,6 +123,7 @@ unsigned long neigh_rand_reach_time(unsigned long base)
 {
 	return (base ? (net_random() % base) + (base >> 1) : 0);
 }
+EXPORT_SYMBOL(neigh_rand_reach_time);
 
 
 static int neigh_forced_gc(struct neigh_table *tbl)
@@ -241,6 +242,7 @@ void neigh_changeaddr(struct neigh_table *tbl, struct net_device *dev)
 	neigh_flush_dev(tbl, dev);
 	write_unlock_bh(&tbl->lock);
 }
+EXPORT_SYMBOL(neigh_changeaddr);
 
 int neigh_ifdown(struct neigh_table *tbl, struct net_device *dev)
 {
@@ -253,6 +255,7 @@ int neigh_ifdown(struct neigh_table *tbl, struct net_device *dev)
 	pneigh_queue_purge(&tbl->proxy_queue);
 	return 0;
 }
+EXPORT_SYMBOL(neigh_ifdown);
 
 static struct neighbour *neigh_alloc(struct neigh_table *tbl)
 {
@@ -374,6 +377,7 @@ struct neighbour *neigh_lookup(struct neigh_table *tbl, const void *pkey,
 	read_unlock_bh(&tbl->lock);
 	return n;
 }
+EXPORT_SYMBOL(neigh_lookup);
 
 struct neighbour *neigh_lookup_nodev(struct neigh_table *tbl, struct net *net,
 				     const void *pkey)
@@ -397,6 +401,7 @@ struct neighbour *neigh_lookup_nodev(struct neigh_table *tbl, struct net *net,
 	read_unlock_bh(&tbl->lock);
 	return n;
 }
+EXPORT_SYMBOL(neigh_lookup_nodev);
 
 struct neighbour *neigh_create(struct neigh_table *tbl, const void *pkey,
 			       struct net_device *dev)
@@ -465,6 +470,7 @@ out_neigh_release:
 	neigh_release(n);
 	goto out;
 }
+EXPORT_SYMBOL(neigh_create);
 
 struct pneigh_entry *__pneigh_lookup(struct neigh_table *tbl,
 		struct net *net, const void *pkey, struct net_device *dev)
@@ -487,6 +493,7 @@ struct pneigh_entry *__pneigh_lookup(struct neigh_table *tbl,
 
 	return n;
 }
+EXPORT_SYMBOL_GPL(__pneigh_lookup);
 
 struct pneigh_entry * pneigh_lookup(struct neigh_table *tbl,
 				    struct net *net, const void *pkey,
@@ -546,6 +553,7 @@ struct pneigh_entry * pneigh_lookup(struct neigh_table *tbl,
 out:
 	return n;
 }
+EXPORT_SYMBOL(pneigh_lookup);
 
 
 int pneigh_delete(struct neigh_table *tbl, struct net *net, const void *pkey,
@@ -653,6 +661,7 @@ void neigh_destroy(struct neighbour *neigh)
 	atomic_dec(&neigh->tbl->entries);
 	kmem_cache_free(neigh->tbl->kmem_cachep, neigh);
 }
+EXPORT_SYMBOL(neigh_destroy);
 
 /* Neighbour state is suspicious;
    disable fast path.
@@ -933,6 +942,7 @@ out_unlock_bh:
 	write_unlock_bh(&neigh->lock);
 	return rc;
 }
+EXPORT_SYMBOL(__neigh_event_send);
 
 static void neigh_update_hhs(struct neighbour *neigh)
 {
@@ -1105,6 +1115,7 @@ out:
 
 	return err;
 }
+EXPORT_SYMBOL(neigh_update);
 
 struct neighbour *neigh_event_ns(struct neigh_table *tbl,
 				 u8 *lladdr, void *saddr,
@@ -1117,6 +1128,7 @@ struct neighbour *neigh_event_ns(struct neigh_table *tbl,
 			     NEIGH_UPDATE_F_OVERRIDE);
 	return neigh;
 }
+EXPORT_SYMBOL(neigh_event_ns);
 
 static void neigh_hh_init(struct neighbour *n, struct dst_entry *dst,
 			  __be16 protocol)
@@ -1171,6 +1183,7 @@ int neigh_compat_output(struct sk_buff *skb)
 
 	return dev_queue_xmit(skb);
 }
+EXPORT_SYMBOL(neigh_compat_output);
 
 /* Slow and careful. */
 
@@ -1216,6 +1229,7 @@ out_kfree_skb:
 	kfree_skb(skb);
 	goto out;
 }
+EXPORT_SYMBOL(neigh_resolve_output);
 
 /* As fast as possible without hh cache */
 
@@ -1240,6 +1254,7 @@ int neigh_connected_output(struct sk_buff *skb)
 	}
 	return err;
 }
+EXPORT_SYMBOL(neigh_connected_output);
 
 static void neigh_proxy_process(unsigned long arg)
 {
@@ -1301,6 +1316,7 @@ void pneigh_enqueue(struct neigh_table *tbl, struct neigh_parms *p,
 	mod_timer(&tbl->proxy_timer, sched_next);
 	spin_unlock(&tbl->proxy_queue.lock);
 }
+EXPORT_SYMBOL(pneigh_enqueue);
 
 static inline struct neigh_parms *lookup_neigh_params(struct neigh_table *tbl,
 						      struct net *net, int ifindex)
@@ -1353,6 +1369,7 @@ struct neigh_parms *neigh_parms_alloc(struct net_device *dev,
 	}
 	return p;
 }
+EXPORT_SYMBOL(neigh_parms_alloc);
 
 static void neigh_rcu_free_parms(struct rcu_head *head)
 {
@@ -1383,6 +1400,7 @@ void neigh_parms_release(struct neigh_table *tbl, struct neigh_parms *parms)
 	write_unlock_bh(&tbl->lock);
 	NEIGH_PRINTK1("neigh_parms_release: not found\n");
 }
+EXPORT_SYMBOL(neigh_parms_release);
 
 static void neigh_parms_destroy(struct neigh_parms *parms)
 {
@@ -1445,6 +1463,7 @@ void neigh_table_init_no_netlink(struct neigh_table *tbl)
 	tbl->last_flush = now;
 	tbl->last_rand	= now + tbl->parms.reachable_time * 20;
 }
+EXPORT_SYMBOL(neigh_table_init_no_netlink);
 
 void neigh_table_init(struct neigh_table *tbl)
 {
@@ -1466,6 +1485,7 @@ void neigh_table_init(struct neigh_table *tbl)
 		dump_stack();
 	}
 }
+EXPORT_SYMBOL(neigh_table_init);
 
 int neigh_table_clear(struct neigh_table *tbl)
 {
@@ -1503,6 +1523,7 @@ int neigh_table_clear(struct neigh_table *tbl)
 
 	return 0;
 }
+EXPORT_SYMBOL(neigh_table_clear);
 
 static int neigh_delete(struct sk_buff *skb, struct nlmsghdr *nlh, void *arg)
 {
@@ -2536,6 +2557,7 @@ void neigh_app_ns(struct neighbour *n)
 {
 	__neigh_notify(n, RTM_GETNEIGH, NLM_F_REQUEST);
 }
+EXPORT_SYMBOL(neigh_app_ns);
 #endif /* CONFIG_ARPD */
 
 #ifdef CONFIG_SYSCTL
@@ -2782,6 +2804,7 @@ free:
 err:
 	return -ENOBUFS;
 }
+EXPORT_SYMBOL(neigh_sysctl_register);
 
 void neigh_sysctl_unregister(struct neigh_parms *p)
 {
@@ -2793,6 +2816,7 @@ void neigh_sysctl_unregister(struct neigh_parms *p)
 		kfree(t);
 	}
 }
+EXPORT_SYMBOL(neigh_sysctl_unregister);
 
 #endif	/* CONFIG_SYSCTL */
 
@@ -2810,32 +2834,3 @@ static int __init neigh_init(void)
 
 subsys_initcall(neigh_init);
 
-EXPORT_SYMBOL(__neigh_event_send);
-EXPORT_SYMBOL(neigh_changeaddr);
-EXPORT_SYMBOL(neigh_compat_output);
-EXPORT_SYMBOL(neigh_connected_output);
-EXPORT_SYMBOL(neigh_create);
-EXPORT_SYMBOL(neigh_destroy);
-EXPORT_SYMBOL(neigh_event_ns);
-EXPORT_SYMBOL(neigh_ifdown);
-EXPORT_SYMBOL(neigh_lookup);
-EXPORT_SYMBOL(neigh_lookup_nodev);
-EXPORT_SYMBOL(neigh_parms_alloc);
-EXPORT_SYMBOL(neigh_parms_release);
-EXPORT_SYMBOL(neigh_rand_reach_time);
-EXPORT_SYMBOL(neigh_resolve_output);
-EXPORT_SYMBOL(neigh_table_clear);
-EXPORT_SYMBOL(neigh_table_init);
-EXPORT_SYMBOL(neigh_table_init_no_netlink);
-EXPORT_SYMBOL(neigh_update);
-EXPORT_SYMBOL(pneigh_enqueue);
-EXPORT_SYMBOL(pneigh_lookup);
-EXPORT_SYMBOL_GPL(__pneigh_lookup);
-
-#ifdef CONFIG_ARPD
-EXPORT_SYMBOL(neigh_app_ns);
-#endif
-#ifdef CONFIG_SYSCTL
-EXPORT_SYMBOL(neigh_sysctl_register);
-EXPORT_SYMBOL(neigh_sysctl_unregister);
-#endif

---
commit be01d655d9b07c1350b19bf3d80eae0059254b4b
Author: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Date:   Fri Mar 28 12:46:53 2008 +0900

    [NET] NEIGHBOUR: Extract hash/lookup functions for pneigh entries.
    
    Extract hash function for pneigh entries from pneigh_lookup(),
    __pneigh_lookup() and pneigh_delete() as pneigh_hash().
    Extract core of pneigh_lookup() and __pneigh_lookup() as
    __pneigh_lookup_1().
    
    Signed-off-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>

diff --git a/net/core/neighbour.c b/net/core/neighbour.c
index d4fae81..75075c3 100644
--- a/net/core/neighbour.c
+++ b/net/core/neighbour.c
@@ -472,26 +472,40 @@ out_neigh_release:
 }
 EXPORT_SYMBOL(neigh_create);
 
-struct pneigh_entry *__pneigh_lookup(struct neigh_table *tbl,
-		struct net *net, const void *pkey, struct net_device *dev)
+static u32 pneigh_hash(const void *pkey, int key_len)
 {
-	struct pneigh_entry *n;
-	int key_len = tbl->key_len;
 	u32 hash_val = *(u32 *)(pkey + key_len - 4);
-
 	hash_val ^= (hash_val >> 16);
 	hash_val ^= hash_val >> 8;
 	hash_val ^= hash_val >> 4;
 	hash_val &= PNEIGH_HASHMASK;
+	return hash_val;
+}
 
-	for (n = tbl->phash_buckets[hash_val]; n; n = n->next) {
+static struct pneigh_entry *__pneigh_lookup_1(struct pneigh_entry *n,
+					      struct net *net,
+					      const void *pkey,
+					      int key_len,
+					      struct net_device *dev)
+{
+	while (n) {
 		if (!memcmp(n->key, pkey, key_len) &&
-		    (pneigh_net(n) == net) &&
+		    net_eq(pneigh_net(n), net) &&
 		    (n->dev == dev || !n->dev))
-			break;
+			return n;
+		n = n->next;
 	}
+	return NULL;
+}
 
-	return n;
+struct pneigh_entry *__pneigh_lookup(struct neigh_table *tbl,
+		struct net *net, const void *pkey, struct net_device *dev)
+{
+	int key_len = tbl->key_len;
+	u32 hash_val = pneigh_hash(pkey, key_len);
+
+	return __pneigh_lookup_1(tbl->phash_buckets[hash_val],
+				 net, pkey, key_len, dev);
 }
 EXPORT_SYMBOL_GPL(__pneigh_lookup);
 
@@ -501,26 +515,14 @@ struct pneigh_entry * pneigh_lookup(struct neigh_table *tbl,
 {
 	struct pneigh_entry *n;
 	int key_len = tbl->key_len;
-	u32 hash_val = *(u32 *)(pkey + key_len - 4);
-
-	hash_val ^= (hash_val >> 16);
-	hash_val ^= hash_val >> 8;
-	hash_val ^= hash_val >> 4;
-	hash_val &= PNEIGH_HASHMASK;
+	u32 hash_val = pneigh_hash(pkey, key_len);
 
 	read_lock_bh(&tbl->lock);
-
-	for (n = tbl->phash_buckets[hash_val]; n; n = n->next) {
-		if (!memcmp(n->key, pkey, key_len) &&
-		    net_eq(pneigh_net(n), net) &&
-		    (n->dev == dev || !n->dev)) {
-			read_unlock_bh(&tbl->lock);
-			goto out;
-		}
-	}
+	n = __pneigh_lookup_1(tbl->phash_buckets[hash_val],
+			      net, pkey, key_len, dev);
 	read_unlock_bh(&tbl->lock);
-	n = NULL;
-	if (!creat)
+
+	if (n || !creat)
 		goto out;
 
 	ASSERT_RTNL();
@@ -561,12 +563,7 @@ int pneigh_delete(struct neigh_table *tbl, struct net *net, const void *pkey,
 {
 	struct pneigh_entry *n, **np;
 	int key_len = tbl->key_len;
-	u32 hash_val = *(u32 *)(pkey + key_len - 4);
-
-	hash_val ^= (hash_val >> 16);
-	hash_val ^= hash_val >> 8;
-	hash_val ^= hash_val >> 4;
-	hash_val &= PNEIGH_HASHMASK;
+	u32 hash_val = pneigh_hash(pkey, key_len);
 
 	write_lock_bh(&tbl->lock);
 	for (np = &tbl->phash_buckets[hash_val]; (n = *np) != NULL;

---
commit 0736ffc04eec239cce9fd3c6ae5dce54e14c25c7
Author: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Date:   Fri Mar 28 13:37:58 2008 +0900

    [IPV6] NEIGH: Optimize is_router check.
    
    Our interest is not the whole entry of proxy neighbor but the
    NTF_ROUTER flag.  Let's test it explicitly.
    
    Signed-off-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>

diff --git a/net/ipv6/ndisc.c b/net/ipv6/ndisc.c
index e77b74e..510aa74 100644
--- a/net/ipv6/ndisc.c
+++ b/net/ipv6/ndisc.c
@@ -661,18 +661,19 @@ static void ndisc_solicit(struct neighbour *neigh, struct sk_buff *skb)
 	}
 }
 
-static struct pneigh_entry *pndisc_check_router(struct net_device *dev,
-		struct in6_addr *addr, int *is_router)
+static int pndisc_is_router(const void *pkey,
+			    struct net_device *dev)
 {
 	struct pneigh_entry *n;
+	int ret = -1;
 
 	read_lock_bh(&nd_tbl.lock);
-	n = __pneigh_lookup(&nd_tbl, dev_net(dev), addr, dev);
-	if (n != NULL)
-		*is_router = (n->flags & NTF_ROUTER);
+	n = __pneigh_lookup(&nd_tbl, dev_net(dev), pkey, dev);
+	if (n)
+		ret = !!(n->flags & NTF_ROUTER);
 	read_unlock_bh(&nd_tbl.lock);
 
-	return n;
+	return ret;
 }
 
 static void ndisc_recv_ns(struct sk_buff *skb)
@@ -688,10 +689,9 @@ static void ndisc_recv_ns(struct sk_buff *skb)
 	struct inet6_ifaddr *ifp;
 	struct inet6_dev *idev = NULL;
 	struct neighbour *neigh;
-	struct pneigh_entry *pneigh = NULL;
 	int dad = ipv6_addr_any(saddr);
 	int inc;
-	int is_router = 0;
+	int is_router = -1;
 
 	if (ipv6_addr_is_multicast(&msg->target)) {
 		ND_PRINTK2(KERN_WARNING
@@ -790,8 +790,7 @@ static void ndisc_recv_ns(struct sk_buff *skb)
 		if (ipv6_chk_acast_addr(dev_net(dev), dev, &msg->target) ||
 		    (idev->cnf.forwarding &&
 		     (ipv6_devconf.proxy_ndp || idev->cnf.proxy_ndp) &&
-		     (pneigh = pndisc_check_router(dev, &msg->target,
-						  &is_router)) != NULL)) {
+		     (is_router = pndisc_is_router(&msg->target, dev)) >= 0)) {
 			if (!(NEIGH_CB(skb)->flags & LOCALLY_ENQUEUED) &&
 			    skb->pkt_type != PACKET_HOST &&
 			    inc != 0 &&
@@ -812,7 +811,8 @@ static void ndisc_recv_ns(struct sk_buff *skb)
 			goto out;
 	}
 
-	is_router = !!(pneigh ? is_router : idev->cnf.forwarding);
+	if (is_router < 0)
+		is_router = !!idev->cnf.forwarding;
 
 	if (dad) {
 		struct in6_addr maddr;

---
