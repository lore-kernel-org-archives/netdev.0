From: David Miller <davem@davemloft.net>
Subject: [PATCH 1/10] ipv4: Remove now superfluous code in
 ip_route_connect().
Date: Fri, 29 Apr 2011 10:26:54 -0700 (PDT)
Message-ID: <20110429.102654.71099871.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:52398
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1757548Ab1D2R11 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 29 Apr 2011 13:27:27 -0400
Received: from localhost (localhost [127.0.0.1])
	by sunset.davemloft.net (Postfix) with ESMTP id 834AF24C087
	for <netdev@vger.kernel.org>; Fri, 29 Apr 2011 10:26:54 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Now that output route lookups update the flow with
source address et al. selections, the fl4->{saddr,daddr}
assignments here are no longer necessary.

Signed-off-by: David S. Miller <davem@davemloft.net>
---
 include/net/route.h |    2 --
 1 files changed, 0 insertions(+), 2 deletions(-)

diff --git a/include/net/route.h b/include/net/route.h
index 81b6cf2..16eb59c 100644
--- a/include/net/route.h
+++ b/include/net/route.h
@@ -271,8 +271,6 @@ static inline struct rtable *ip_route_connect(struct flowi4 *fl4,
 		rt = __ip_route_output_key(net, fl4);
 		if (IS_ERR(rt))
 			return rt;
-		fl4->daddr = rt->rt_dst;
-		fl4->saddr = rt->rt_src;
 		ip_rt_put(rt);
 	}
 	security_sk_classify_flow(sk, flowi4_to_flowi(fl4));
-- 
1.7.4.5

