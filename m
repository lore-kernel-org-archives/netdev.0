From: roy.qing.li@gmail.com
Subject: [PATCH net-next] ipv6: remove unnecessory call rt6_clean_expires
Date: Thu, 20 Sep 2012 12:57:33 +0800
Message-ID: <1348117053-4113-1-git-send-email-roy.qing.li@gmail.com>
To: netdev@vger.kernel.org, gaofeng@cn.fujitsu.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f46.google.com ([209.85.160.46]:59158 "EHLO
	mail-pb0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751832Ab2ITE5p (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 20 Sep 2012 00:57:45 -0400
Received: by pbbrr13 with SMTP id rr13so4184649pbb.19
        for <netdev@vger.kernel.org>; Wed, 19 Sep 2012 21:57:44 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Li RongQing <roy.qing.li@gmail.com>

ip6_dst_alloc will zero the from and rt6i_flags of dst cache,
so it is unnecessory to call rt6_clean_expires again.

Cc: Gao feng <gaofeng@cn.fujitsu.com>
Signed-off-by: Li RongQing <roy.qing.li@gmail.com>
---
 net/ipv6/route.c |    9 ++-------
 1 files changed, 2 insertions(+), 7 deletions(-)

diff --git a/net/ipv6/route.c b/net/ipv6/route.c
index 0607ee3..fd5dabf 100644
--- a/net/ipv6/route.c
+++ b/net/ipv6/route.c
@@ -996,8 +996,7 @@ struct dst_entry *ip6_blackhole_route(struct net *net, struct dst_entry *dst_ori
 			in6_dev_hold(rt->rt6i_idev);
 
 		rt->rt6i_gateway = ort->rt6i_gateway;
-		rt->rt6i_flags = ort->rt6i_flags;
-		rt6_clean_expires(rt);
+		rt->rt6i_flags = ort->rt6i_flags & ~RTF_EXPIRES;
 		rt->rt6i_metric = 0;
 
 		memcpy(&rt->rt6i_dst, &ort->rt6i_dst, sizeof(struct rt6key));
@@ -1393,8 +1392,6 @@ int ip6_route_add(struct fib6_config *cfg)
 	if (cfg->fc_flags & RTF_EXPIRES)
 		rt6_set_expires(rt, jiffies +
 				clock_t_to_jiffies(cfg->fc_expires));
-	else
-		rt6_clean_expires(rt);
 
 	if (cfg->fc_protocol == RTPROT_UNSPEC)
 		cfg->fc_protocol = RTPROT_BOOT;
@@ -1803,12 +1800,10 @@ static struct rt6_info *ip6_rt_copy(struct rt6_info *ort,
 		rt->dst.lastuse = jiffies;
 
 		rt->rt6i_gateway = ort->rt6i_gateway;
-		rt->rt6i_flags = ort->rt6i_flags;
+		rt->rt6i_flags = ort->rt6i_flags & ~RTF_EXPIRES;
 		if ((ort->rt6i_flags & (RTF_DEFAULT | RTF_ADDRCONF)) ==
 		    (RTF_DEFAULT | RTF_ADDRCONF))
 			rt6_set_from(rt, ort);
-		else
-			rt6_clean_expires(rt);
 		rt->rt6i_metric = 0;
 
 #ifdef CONFIG_IPV6_SUBTREES
-- 
1.7.4.1
