From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: [PATCH] ipv6: fix ecmp lookup on forwarding path
Date: Thu, 13 Jun 2013 16:04:55 +0200
Message-ID: <1371132295-5620-1-git-send-email-nicolas.dichtel@6wind.com>
Cc: netdev@vger.kernel.org, dingzhi <zhi.ding@6wind.com>,
	Nicolas Dichtel <nicolas.dichtel@6wind.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from 33.106-14-84.ripe.coltfrance.com ([84.14.106.33]:40183 "EHLO
	proxy.6wind.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752678Ab3FMOGA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 13 Jun 2013 10:06:00 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: dingzhi <zhi.ding@6wind.com>

There is no reason to skip ECMP lookup when oif is specified. For example, when
a packet is forwarded, the input interface is specified.

Signed-off-by: dingzhi <zhi.ding@6wind.com>
Signed-off-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>
---
 net/ipv6/route.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/ipv6/route.c b/net/ipv6/route.c
index ad0aa6b..9a6d637 100644
--- a/net/ipv6/route.c
+++ b/net/ipv6/route.c
@@ -742,7 +742,7 @@ static struct rt6_info *ip6_pol_route_lookup(struct net *net,
 restart:
 	rt = fn->leaf;
 	rt = rt6_device_match(net, rt, &fl6->saddr, fl6->flowi6_oif, flags);
-	if (rt->rt6i_nsiblings && fl6->flowi6_oif == 0)
+	if (rt->rt6i_nsiblings)
 		rt = rt6_multipath_select(rt, fl6);
 	BACKTRACK(net, &fl6->saddr);
 out:
@@ -875,7 +875,7 @@ restart_2:
 
 restart:
 	rt = rt6_select(fn, oif, strict | reachable);
-	if (rt->rt6i_nsiblings && oif == 0)
+	if (rt->rt6i_nsiblings)
 		rt = rt6_multipath_select(rt, fl6);
 	BACKTRACK(net, &fl6->saddr);
 	if (rt == net->ipv6.ip6_null_entry ||
-- 
1.8.2.1
