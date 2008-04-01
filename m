From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCH 4/6] IPV4: route inline changes
Date: Mon, 31 Mar 2008 17:47:12 -0700
Message-ID: <20080401004724.677182853@vyatta.com>
References: <20080401004708.009204033@vyatta.com>
Cc: netdev@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from suva.vyatta.com ([69.59.150.140]:40014 "EHLO suva.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755436AbYDACbi (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 31 Mar 2008 22:31:38 -0400
Content-Disposition: inline; filename=route-inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Don't mark functions that are large as inline, let compiler decide.
Also, use inline rather than __inline__.

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

--- a/net/ipv4/route.c	2008-03-31 11:10:44.000000000 -0700
+++ b/net/ipv4/route.c	2008-03-31 11:14:50.000000000 -0700
@@ -600,18 +600,18 @@ static inline int ip_rt_proc_init(void)
 }
 #endif /* CONFIG_PROC_FS */
 
-static __inline__ void rt_free(struct rtable *rt)
+static inline void rt_free(struct rtable *rt)
 {
 	call_rcu_bh(&rt->u.dst.rcu_head, dst_rcu_free);
 }
 
-static __inline__ void rt_drop(struct rtable *rt)
+static inline void rt_drop(struct rtable *rt)
 {
 	ip_rt_put(rt);
 	call_rcu_bh(&rt->u.dst.rcu_head, dst_rcu_free);
 }
 
-static __inline__ int rt_fast_clean(struct rtable *rth)
+static inline int rt_fast_clean(struct rtable *rth)
 {
 	/* Kill broadcast/multicast entries very aggresively, if they
 	   collide in hash table with more useful entries */
@@ -619,7 +619,7 @@ static __inline__ int rt_fast_clean(stru
 		rth->fl.iif && rth->u.dst.rt_next;
 }
 
-static __inline__ int rt_valuable(struct rtable *rth)
+static inline int rt_valuable(struct rtable *rth)
 {
 	return (rth->rt_flags & (RTCF_REDIRECTED | RTCF_NOTIFY)) ||
 		rth->u.dst.expires;
@@ -1420,7 +1420,7 @@ out:	kfree_skb(skb);
 static const unsigned short mtu_plateau[] =
 {32000, 17914, 8166, 4352, 2002, 1492, 576, 296, 216, 128 };
 
-static __inline__ unsigned short guess_mtu(unsigned short old_mtu)
+static inline unsigned short guess_mtu(unsigned short old_mtu)
 {
 	int i;
 
@@ -1750,11 +1750,11 @@ static void ip_handle_martian_source(str
 #endif
 }
 
-static inline int __mkroute_input(struct sk_buff *skb,
-				  struct fib_result* res,
-				  struct in_device *in_dev,
-				  __be32 daddr, __be32 saddr, u32 tos,
-				  struct rtable **result)
+static int __mkroute_input(struct sk_buff *skb,
+			   struct fib_result *res,
+			   struct in_device *in_dev,
+			   __be32 daddr, __be32 saddr, u32 tos,
+			   struct rtable **result)
 {
 
 	struct rtable *rth;
@@ -1846,11 +1846,11 @@ static inline int __mkroute_input(struct
 	return err;
 }
 
-static inline int ip_mkroute_input(struct sk_buff *skb,
-				   struct fib_result* res,
-				   const struct flowi *fl,
-				   struct in_device *in_dev,
-				   __be32 daddr, __be32 saddr, u32 tos)
+static int ip_mkroute_input(struct sk_buff *skb,
+			    struct fib_result *res,
+			    const struct flowi *fl,
+			    struct in_device *in_dev,
+			    __be32 daddr, __be32 saddr, u32 tos)
 {
 	struct rtable* rth = NULL;
 	int err;
@@ -2132,12 +2132,12 @@ int ip_route_input(struct sk_buff *skb, 
 	return ip_route_input_slow(skb, daddr, saddr, tos, dev);
 }
 
-static inline int __mkroute_output(struct rtable **result,
-				   struct fib_result* res,
-				   const struct flowi *fl,
-				   const struct flowi *oldflp,
-				   struct net_device *dev_out,
-				   unsigned flags)
+static int __mkroute_output(struct rtable **result,
+			    struct fib_result *res,
+			    const struct flowi *fl,
+			    const struct flowi *oldflp,
+			    struct net_device *dev_out,
+			    unsigned flags)
 {
 	struct rtable *rth;
 	struct in_device *in_dev;
@@ -2252,12 +2252,12 @@ static inline int __mkroute_output(struc
 	return err;
 }
 
-static inline int ip_mkroute_output(struct rtable **rp,
-				    struct fib_result* res,
-				    const struct flowi *fl,
-				    const struct flowi *oldflp,
-				    struct net_device *dev_out,
-				    unsigned flags)
+static int ip_mkroute_output(struct rtable **rp,
+			     struct fib_result *res,
+			     const struct flowi *fl,
+			     const struct flowi *oldflp,
+			     struct net_device *dev_out,
+			     unsigned flags)
 {
 	struct rtable *rth = NULL;
 	int err = __mkroute_output(&rth, res, fl, oldflp, dev_out, flags);

-- 

