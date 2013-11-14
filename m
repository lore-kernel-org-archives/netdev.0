From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: [PATCH net 3/3] sit/gre6: don't try to add the same route two times
Date: Thu, 14 Nov 2013 13:51:07 +0100
Message-ID: <1384433467-4780-3-git-send-email-nicolas.dichtel@6wind.com>
References: <1384433467-4780-1-git-send-email-nicolas.dichtel@6wind.com>
Cc: netdev@vger.kernel.org, Nicolas Dichtel <nicolas.dichtel@6wind.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from 33.106-14-84.ripe.coltfrance.com ([84.14.106.33]:45297 "EHLO
	proxy.6wind.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752929Ab3KNMva (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 14 Nov 2013 07:51:30 -0500
In-Reply-To: <1384433467-4780-1-git-send-email-nicolas.dichtel@6wind.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

addrconf_add_linklocal() already adds the link local route, so there is no
reason to add it before calling this function.

Signed-off-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>
---
 net/ipv6/addrconf.c | 3 ---
 1 file changed, 3 deletions(-)

diff --git a/net/ipv6/addrconf.c b/net/ipv6/addrconf.c
index 237bceb74c4e..cfc47b364e51 100644
--- a/net/ipv6/addrconf.c
+++ b/net/ipv6/addrconf.c
@@ -2709,7 +2709,6 @@ static void addrconf_sit_config(struct net_device *dev)
 		struct in6_addr addr;
 
 		ipv6_addr_set(&addr,  htonl(0xFE800000), 0, 0, 0);
-		addrconf_prefix_route(&addr, 64, dev, 0, 0);
 		if (!ipv6_generate_eui64(addr.s6_addr + 8, dev))
 			addrconf_add_linklocal(idev, &addr);
 		return;
@@ -2736,8 +2735,6 @@ static void addrconf_gre_config(struct net_device *dev)
 	}
 
 	ipv6_addr_set(&addr,  htonl(0xFE800000), 0, 0, 0);
-	addrconf_prefix_route(&addr, 64, dev, 0, 0);
-
 	if (!ipv6_generate_eui64(addr.s6_addr + 8, dev))
 		addrconf_add_linklocal(idev, &addr);
 }
-- 
1.8.4.1
