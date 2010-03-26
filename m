From: David Miller <davem@davemloft.net>
Subject: [PATCH] ipv6: Preserve pervious behavior in ipv6_link_dev_addr().
Date: Thu, 25 Mar 2010 21:26:17 -0700 (PDT)
Message-ID: <20100325.212617.170598892.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: shemminger@vyatta.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:45916
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752008Ab0CZEZy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 26 Mar 2010 00:25:54 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


I just committed the following to net-next-2.6

ipv6: Preserve pervious behavior in ipv6_link_dev_addr().

Use list_add_tail() to get the behavior we had before
the list_head conversion for ipv6 address lists.

Signed-off-by: David S. Miller <davem@davemloft.net>
---
 net/ipv6/addrconf.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/net/ipv6/addrconf.c b/net/ipv6/addrconf.c
index 68e5809..9995683 100644
--- a/net/ipv6/addrconf.c
+++ b/net/ipv6/addrconf.c
@@ -578,7 +578,7 @@ ipv6_link_dev_addr(struct inet6_dev *idev, struct inet6_ifaddr *ifp)
 			break;
 	}
 
-	list_add(&ifp->if_list, p);
+	list_add_tail(&ifp->if_list, p);
 }
 
 static u32 ipv6_addr_hash(const struct in6_addr *addr)
-- 
1.7.0.3

