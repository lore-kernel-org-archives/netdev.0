From: David Miller <davem@davemloft.net>
Subject: [PATCH] ipv6: Use ERR_CAST in addrconf_dst_alloc.
Date: Thu, 03 Mar 2011 12:11:11 -0800 (PST)
Message-ID: <20110303.121111.246525803.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:52975
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S932248Ab1CCUKe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Mar 2011 15:10:34 -0500
Received: from localhost (localhost [127.0.0.1])
	by sunset.davemloft.net (Postfix) with ESMTP id 7155124C087
	for <netdev@vger.kernel.org>; Thu,  3 Mar 2011 12:11:11 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Signed-off-by: David S. Miller <davem@davemloft.net>
---
 net/ipv6/route.c |    7 +------
 1 files changed, 1 insertions(+), 6 deletions(-)

diff --git a/net/ipv6/route.c b/net/ipv6/route.c
index 053a92e..59f2a58 100644
--- a/net/ipv6/route.c
+++ b/net/ipv6/route.c
@@ -2022,12 +2022,7 @@ struct rt6_info *addrconf_dst_alloc(struct inet6_dev *idev,
 	if (IS_ERR(neigh)) {
 		dst_free(&rt->dst);
 
-		/* We are casting this because that is the return
-		 * value type.  But an errno encoded pointer is the
-		 * same regardless of the underlying pointer type,
-		 * and that's what we are returning.  So this is OK.
-		 */
-		return (struct rt6_info *) neigh;
+		return ERR_CAST(neigh);
 	}
 	rt->rt6i_nexthop = neigh;
 
-- 
1.7.4.1

