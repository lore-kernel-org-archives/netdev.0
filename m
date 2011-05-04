From: David Miller <davem@davemloft.net>
Subject: [PATCH 2/8] ipv4: Renamt struct rtable's rt_tos to rt_key_tos.
Date: Wed, 04 May 2011 10:14:44 -0700 (PDT)
Message-ID: <20110504.101444.71119810.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:49222
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754695Ab1EDRPQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 May 2011 13:15:16 -0400
Received: from localhost (localhost [127.0.0.1])
	by sunset.davemloft.net (Postfix) with ESMTP id 96C9724C088
	for <netdev@vger.kernel.org>; Wed,  4 May 2011 10:14:44 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


To more accurately reflect that it is purely a routing
cache lookup key and is used in no other context.

Signed-off-by: David S. Miller <davem@davemloft.net>
---
 include/net/route.h     |    2 +-
 net/ipv4/route.c        |   24 ++++++++++++------------
 net/ipv4/xfrm4_policy.c |    2 +-
 3 files changed, 14 insertions(+), 14 deletions(-)

diff --git a/include/net/route.h b/include/net/route.h
index 16eb59c..f07609e 100644
--- a/include/net/route.h
+++ b/include/net/route.h
@@ -52,7 +52,7 @@ struct rtable {
 	int			rt_genid;
 	unsigned		rt_flags;
 	__u16			rt_type;
-	__u8			rt_tos;
+	__u8			rt_key_tos;
 
 	__be32			rt_dst;	/* Path destination	*/
 	__be32			rt_src;	/* Path source		*/
diff --git a/net/ipv4/route.c b/net/ipv4/route.c
index 64f360d..3bc6854 100644
--- a/net/ipv4/route.c
+++ b/net/ipv4/route.c
@@ -424,7 +424,7 @@ static int rt_cache_seq_show(struct seq_file *seq, void *v)
 			dst_metric(&r->dst, RTAX_WINDOW),
 			(int)((dst_metric(&r->dst, RTAX_RTT) >> 3) +
 			      dst_metric(&r->dst, RTAX_RTTVAR)),
-			r->rt_tos,
+			r->rt_key_tos,
 			r->dst.hh ? atomic_read(&r->dst.hh->hh_refcnt) : -1,
 			r->dst.hh ? (r->dst.hh->hh_output ==
 				       dev_queue_xmit) : 0,
@@ -724,7 +724,7 @@ static inline int compare_keys(struct rtable *rt1, struct rtable *rt2)
 	return (((__force u32)rt1->rt_key_dst ^ (__force u32)rt2->rt_key_dst) |
 		((__force u32)rt1->rt_key_src ^ (__force u32)rt2->rt_key_src) |
 		(rt1->rt_mark ^ rt2->rt_mark) |
-		(rt1->rt_tos ^ rt2->rt_tos) |
+		(rt1->rt_key_tos ^ rt2->rt_key_tos) |
 		(rt1->rt_oif ^ rt2->rt_oif) |
 		(rt1->rt_iif ^ rt2->rt_iif)) == 0;
 }
@@ -1349,7 +1349,7 @@ static struct dst_entry *ipv4_negative_advice(struct dst_entry *dst)
 						rt_genid(dev_net(dst->dev)));
 #if RT_CACHE_DEBUG >= 1
 			printk(KERN_DEBUG "ipv4_negative_advice: redirect to %pI4/%02x dropped\n",
-				&rt->rt_dst, rt->rt_tos);
+				&rt->rt_dst, rt->rt_key_tos);
 #endif
 			rt_del(hash, rt);
 			ret = NULL;
@@ -1710,7 +1710,7 @@ void ip_rt_get_source(u8 *addr, struct rtable *rt)
 		struct flowi4 fl4 = {
 			.daddr = rt->rt_key_dst,
 			.saddr = rt->rt_key_src,
-			.flowi4_tos = rt->rt_tos,
+			.flowi4_tos = rt->rt_key_tos,
 			.flowi4_oif = rt->rt_oif,
 			.flowi4_iif = rt->rt_iif,
 			.flowi4_mark = rt->rt_mark,
@@ -1886,7 +1886,7 @@ static int ip_route_input_mc(struct sk_buff *skb, __be32 daddr, __be32 saddr,
 	rth->rt_genid	= rt_genid(dev_net(dev));
 	rth->rt_flags	= RTCF_MULTICAST;
 	rth->rt_type	= RTN_MULTICAST;
-	rth->rt_tos	= tos;
+	rth->rt_key_tos	= tos;
 	rth->rt_dst	= daddr;
 	rth->rt_src	= saddr;
 	rth->rt_route_iif = dev->ifindex;
@@ -2023,7 +2023,7 @@ static int __mkroute_input(struct sk_buff *skb,
 	rth->rt_genid = rt_genid(dev_net(rth->dst.dev));
 	rth->rt_flags = flags;
 	rth->rt_type = res->type;
-	rth->rt_tos	= tos;
+	rth->rt_key_tos	= tos;
 	rth->rt_dst	= daddr;
 	rth->rt_src	= saddr;
 	rth->rt_route_iif = in_dev->dev->ifindex;
@@ -2203,7 +2203,7 @@ local_input:
 	rth->rt_genid = rt_genid(net);
 	rth->rt_flags 	= flags|RTCF_LOCAL;
 	rth->rt_type	= res.type;
-	rth->rt_tos	= tos;
+	rth->rt_key_tos	= tos;
 	rth->rt_dst	= daddr;
 	rth->rt_src	= saddr;
 #ifdef CONFIG_IP_ROUTE_CLASSID
@@ -2293,7 +2293,7 @@ int ip_route_input_common(struct sk_buff *skb, __be32 daddr, __be32 saddr,
 		     ((__force u32)rth->rt_key_src ^ (__force u32)saddr) |
 		     (rth->rt_iif ^ iif) |
 		     rth->rt_oif |
-		     (rth->rt_tos ^ tos)) == 0 &&
+		     (rth->rt_key_tos ^ tos)) == 0 &&
 		    rth->rt_mark == skb->mark &&
 		    net_eq(dev_net(rth->dst.dev), net) &&
 		    !rt_is_expired(rth)) {
@@ -2410,7 +2410,7 @@ static struct rtable *__mkroute_output(const struct fib_result *res,
 	rth->rt_genid = rt_genid(dev_net(dev_out));
 	rth->rt_flags	= flags;
 	rth->rt_type	= type;
-	rth->rt_tos	= tos;
+	rth->rt_key_tos	= tos;
 	rth->rt_dst	= fl4->daddr;
 	rth->rt_src	= fl4->saddr;
 	rth->rt_route_iif = 0;
@@ -2668,7 +2668,7 @@ struct rtable *__ip_route_output_key(struct net *net, struct flowi4 *flp4)
 		    rt_is_output_route(rth) &&
 		    rth->rt_oif == flp4->flowi4_oif &&
 		    rth->rt_mark == flp4->flowi4_mark &&
-		    !((rth->rt_tos ^ flp4->flowi4_tos) &
+		    !((rth->rt_key_tos ^ flp4->flowi4_tos) &
 			    (IPTOS_RT_MASK | RTO_ONLINK)) &&
 		    net_eq(dev_net(rth->dst.dev), net) &&
 		    !rt_is_expired(rth)) {
@@ -2740,7 +2740,7 @@ struct dst_entry *ipv4_blackhole_route(struct net *net, struct dst_entry *dst_or
 
 		rt->rt_key_dst = ort->rt_key_dst;
 		rt->rt_key_src = ort->rt_key_src;
-		rt->rt_tos = ort->rt_tos;
+		rt->rt_key_tos = ort->rt_key_tos;
 		rt->rt_route_iif = ort->rt_route_iif;
 		rt->rt_iif = ort->rt_iif;
 		rt->rt_oif = ort->rt_oif;
@@ -2803,7 +2803,7 @@ static int rt_fill_info(struct net *net,
 	r->rtm_family	 = AF_INET;
 	r->rtm_dst_len	= 32;
 	r->rtm_src_len	= 0;
-	r->rtm_tos	= rt->rt_tos;
+	r->rtm_tos	= rt->rt_key_tos;
 	r->rtm_table	= RT_TABLE_MAIN;
 	NLA_PUT_U32(skb, RTA_TABLE, RT_TABLE_MAIN);
 	r->rtm_type	= rt->rt_type;
diff --git a/net/ipv4/xfrm4_policy.c b/net/ipv4/xfrm4_policy.c
index 59b1340..7ff973b 100644
--- a/net/ipv4/xfrm4_policy.c
+++ b/net/ipv4/xfrm4_policy.c
@@ -73,7 +73,7 @@ static int xfrm4_fill_dst(struct xfrm_dst *xdst, struct net_device *dev,
 
 	rt->rt_key_dst = fl4->daddr;
 	rt->rt_key_src = fl4->saddr;
-	rt->rt_tos = fl4->flowi4_tos;
+	rt->rt_key_tos = fl4->flowi4_tos;
 	rt->rt_route_iif = fl4->flowi4_iif;
 	rt->rt_iif = fl4->flowi4_iif;
 	rt->rt_oif = fl4->flowi4_oif;
-- 
1.7.4.5

