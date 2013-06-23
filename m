From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: [PATCH net-next] ipv6: don't disable interface if last ipv6 address is removed
Date: Mon, 24 Jun 2013 00:22:20 +0200
Message-ID: <20130623222220.GD13836@order.stressinduktion.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: yoshfuji@linux-ipv6.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from order.stressinduktion.org ([87.106.68.36]:33144 "EHLO
	order.stressinduktion.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751606Ab3FWWWV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 23 Jun 2013 18:22:21 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The reason behind this change is that as soon as we delete
the last ipv6 address of an interface we also lose the
/proc/sys/net/ipv6/conf/<interface> directory. This seems to be a
usability problem for me.

I don't see any reason why we should shutdown ipv6 on that interface in
such cases.

Cc: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Signed-off-by: Hannes Frederic Sowa <hannes@stressinduktion.org>
---
 net/ipv6/addrconf.c | 6 ------
 1 file changed, 6 deletions(-)

diff --git a/net/ipv6/addrconf.c b/net/ipv6/addrconf.c
index 8044912..3c1c789 100644
--- a/net/ipv6/addrconf.c
+++ b/net/ipv6/addrconf.c
@@ -2502,12 +2502,6 @@ static int inet6_addr_del(struct net *net, int ifindex, const struct in6_addr *p
 			read_unlock_bh(&idev->lock);
 
 			ipv6_del_addr(ifp);
-
-			/* If the last address is deleted administratively,
-			   disable IPv6 on this interface.
-			 */
-			if (list_empty(&idev->addr_list))
-				addrconf_ifdown(idev->dev, 1);
 			return 0;
 		}
 	}
-- 
1.8.1.4
