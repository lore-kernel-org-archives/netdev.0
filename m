From: David Miller <davem@davemloft.net>
Subject: [PATCH] ipv4: Get peer more cheaply in rt_init_metrics().
Date: Fri, 04 Mar 2011 21:26:36 -0800 (PST)
Message-ID: <20110304.212636.226786422.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:49020
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751638Ab1CEFZ7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 5 Mar 2011 00:25:59 -0500
Received: from localhost (localhost [127.0.0.1])
	by sunset.davemloft.net (Postfix) with ESMTP id 08CC924C087
	for <netdev@vger.kernel.org>; Fri,  4 Mar 2011 21:26:37 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


We know this is a new route object, so doing atomics and
stuff makes no sense at all.

Signed-off-by: David S. Miller <davem@davemloft.net>
---
 net/ipv4/route.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/ipv4/route.c b/net/ipv4/route.c
index 6c87403..9794a2c 100644
--- a/net/ipv4/route.c
+++ b/net/ipv4/route.c
@@ -1759,9 +1759,9 @@ static void rt_init_metrics(struct rtable *rt, struct fib_info *fi)
 	if (rt->fl.flags & FLOWI_FLAG_PRECOW_METRICS)
 		create = 1;
 
-	rt_bind_peer(rt, create);
-	peer = rt->peer;
+	rt->peer = peer = inet_getpeer_v4(rt->rt_dst, create);
 	if (peer) {
+		rt->rt_peer_genid = rt_peer_genid();
 		if (inet_metrics_new(peer))
 			memcpy(peer->metrics, fi->fib_metrics,
 			       sizeof(u32) * RTAX_MAX);
-- 
1.7.4.1

