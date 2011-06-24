From: David Miller <davem@davemloft.net>
Subject: [PATCH 1/2 v2] ipv6: Don't change dst->flags using assignments.
Date: Fri, 24 Jun 2011 16:47:12 -0700 (PDT)
Message-ID: <20110624.164712.931684144821542399.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: sim@hostway.ca
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:32854 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754918Ab1FXXrN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 24 Jun 2011 19:47:13 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


This blows away any flags already set in the entry.

Signed-off-by: David S. Miller <davem@davemloft.net>
---
 net/ipv6/route.c |   12 ++----------
 1 files changed, 2 insertions(+), 10 deletions(-)

diff --git a/net/ipv6/route.c b/net/ipv6/route.c
index de2b1de..c2af4da 100644
--- a/net/ipv6/route.c
+++ b/net/ipv6/route.c
@@ -1062,14 +1062,6 @@ struct dst_entry *icmp6_dst_alloc(struct net_device *dev,
 	dst_metric_set(&rt->dst, RTAX_HOPLIMIT, 255);
 	rt->dst.output  = ip6_output;
 
-#if 0	/* there's no chance to use these for ndisc */
-	rt->dst.flags   = ipv6_addr_type(addr) & IPV6_ADDR_UNICAST
-				? DST_HOST
-				: 0;
-	ipv6_addr_copy(&rt->rt6i_dst.addr, addr);
-	rt->rt6i_dst.plen = 128;
-#endif
-
 	spin_lock_bh(&icmp6_dst_lock);
 	rt->dst.next = icmp6_dst_gc_list;
 	icmp6_dst_gc_list = &rt->dst;
@@ -1244,7 +1236,7 @@ int ip6_route_add(struct fib6_config *cfg)
 	ipv6_addr_prefix(&rt->rt6i_dst.addr, &cfg->fc_dst, cfg->fc_dst_len);
 	rt->rt6i_dst.plen = cfg->fc_dst_len;
 	if (rt->rt6i_dst.plen == 128)
-	       rt->dst.flags = DST_HOST;
+	       rt->dst.flags |= DST_HOST;
 
 #ifdef CONFIG_IPV6_SUBTREES
 	ipv6_addr_prefix(&rt->rt6i_src.addr, &cfg->fc_src, cfg->fc_src_len);
@@ -2025,7 +2017,7 @@ struct rt6_info *addrconf_dst_alloc(struct inet6_dev *idev,
 
 	in6_dev_hold(idev);
 
-	rt->dst.flags = DST_HOST;
+	rt->dst.flags |= DST_HOST;
 	rt->dst.input = ip6_input;
 	rt->dst.output = ip6_output;
 	rt->rt6i_idev = idev;
-- 
1.7.5.4

