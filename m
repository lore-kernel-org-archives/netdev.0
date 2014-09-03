From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: [PATCH net 2/2] ipv6: use addrconf_get_prefix_route() to remove peer addr
Date: Wed,  3 Sep 2014 23:59:22 +0200
Message-ID: <1409781562-4191-2-git-send-email-nicolas.dichtel@6wind.com>
References: <1409781562-4191-1-git-send-email-nicolas.dichtel@6wind.com>
Cc: netdev@vger.kernel.org, Nicolas Dichtel <nicolas.dichtel@6wind.com>
To: yoshfuji@linux-ipv6.org, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from 33.106-14-84.ripe.coltfrance.com ([84.14.106.33]:40259 "EHLO
	proxy.6wind.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756732AbaICV7i (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 3 Sep 2014 17:59:38 -0400
In-Reply-To: <1409781562-4191-1-git-send-email-nicolas.dichtel@6wind.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

addrconf_get_prefix_route() ensures to get the right route in the right table.

Signed-off-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>
---
 net/ipv6/addrconf.c | 5 ++---
 1 file changed, 2 insertions(+), 3 deletions(-)

diff --git a/net/ipv6/addrconf.c b/net/ipv6/addrconf.c
index e75ecb1e848b..bb9ca1655cc5 100644
--- a/net/ipv6/addrconf.c
+++ b/net/ipv6/addrconf.c
@@ -4773,10 +4773,9 @@ static void __ipv6_ifa_notify(int event, struct inet6_ifaddr *ifp)
 		addrconf_leave_solict(ifp->idev, &ifp->addr);
 		if (!ipv6_addr_any(&ifp->peer_addr)) {
 			struct rt6_info *rt;
-			struct net_device *dev = ifp->idev->dev;
 
-			rt = rt6_lookup(dev_net(dev), &ifp->peer_addr, NULL,
-					dev->ifindex, 1);
+			rt = addrconf_get_prefix_route(&ifp->peer_addr, 128,
+						       ifp->idev->dev, 0, 0);
 			if (rt && ip6_del_rt(rt))
 				dst_free(&rt->dst);
 		}
-- 
1.9.0
