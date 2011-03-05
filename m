From: David Miller <davem@davemloft.net>
Subject: [PATCH] ipv4: Set rt->rt_iif more sanely on output routes.
Date: Fri, 04 Mar 2011 21:36:25 -0800 (PST)
Message-ID: <20110304.213625.104050222.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:53224
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750752Ab1CEFfr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 5 Mar 2011 00:35:47 -0500
Received: from localhost (localhost [127.0.0.1])
	by sunset.davemloft.net (Postfix) with ESMTP id 543FB24C087
	for <netdev@vger.kernel.org>; Fri,  4 Mar 2011 21:36:25 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


rt->rt_iif is only ever inspected on input routes, for example DCCP
uses this to populate a route lookup flow key when generating replies
to another packet.

Therefore, setting it to anything other than zero on output routes
makes no sense.

Signed-off-by: David S. Miller <davem@davemloft.net>
---
 net/ipv4/route.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/net/ipv4/route.c b/net/ipv4/route.c
index 9794a2c..602473c 100644
--- a/net/ipv4/route.c
+++ b/net/ipv4/route.c
@@ -2381,7 +2381,7 @@ static struct rtable *__mkroute_output(const struct fib_result *res,
 	rth->fl.mark    = oldflp->mark;
 	rth->rt_dst	= fl->fl4_dst;
 	rth->rt_src	= fl->fl4_src;
-	rth->rt_iif	= oldflp->oif ? : dev_out->ifindex;
+	rth->rt_iif	= 0;
 	/* get references to the devices that are to be hold by the routing
 	   cache entry */
 	rth->dst.dev	= dev_out;
-- 
1.7.4.1

