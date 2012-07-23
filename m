From: David Miller <davem@davemloft.net>
Subject: [PATCH] decnet: Don't set RTCF_DIRECTSRC.
Date: Mon, 23 Jul 2012 13:17:39 -0700 (PDT)
Message-ID: <20120723.131739.2064070169913079873.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:49066 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753828Ab2GWURl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 Jul 2012 16:17:41 -0400
Received: from localhost (74-93-104-98-Washington.hfc.comcastbusiness.net [74.93.104.98])
	by shards.monkeyblade.net (Postfix) with ESMTPSA id 3095F584258
	for <netdev@vger.kernel.org>; Mon, 23 Jul 2012 13:17:42 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


It's an ipv4 defined route flag, and only ipv4 uses it.

Signed-off-by: David S. Miller <davem@davemloft.net>
---
 net/decnet/dn_route.c |    2 --
 1 file changed, 2 deletions(-)

diff --git a/net/decnet/dn_route.c b/net/decnet/dn_route.c
index 23cc11d..85a3604 100644
--- a/net/decnet/dn_route.c
+++ b/net/decnet/dn_route.c
@@ -1424,7 +1424,6 @@ static int dn_route_input_slow(struct sk_buff *skb)
 		/* Packet was intra-ethernet, so we know its on-link */
 		if (cb->rt_flags & DN_RT_F_IE) {
 			gateway = cb->src;
-			flags |= RTCF_DIRECTSRC;
 			goto make_route;
 		}
 
@@ -1437,7 +1436,6 @@ static int dn_route_input_slow(struct sk_buff *skb)
 
 		/* Close eyes and pray */
 		gateway = cb->src;
-		flags |= RTCF_DIRECTSRC;
 		goto make_route;
 	default:
 		goto e_inval;
-- 
1.7.10.4
