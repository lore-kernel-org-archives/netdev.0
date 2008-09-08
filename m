From: Julius Volz <juliusv@google.com>
Subject: [PATCH] IPVS: Remove incorrect ip_route_me_harder(), fix IPv6
Date: Mon,  8 Sep 2008 14:55:42 +0200
Message-ID: <1220878542-1864-1-git-send-email-juliusv@google.com>
Cc: horms@verge.net.au, siim@p6drad-teel.net, ja@ssi.bg,
	malcolm@loadbalancer.org, vbusam@google.com,
	herbert@gondor.apana.org.au, Julius Volz <juliusv@google.com>
To: netdev@vger.kernel.org, lvs-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out.google.com ([216.239.33.17]:25413 "EHLO
	smtp-out.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751342AbYIHM4N (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 8 Sep 2008 08:56:13 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Remove an incorrect ip_route_me_harder() that was probably a result of
merging my IPv6 patches with the local client patches. With this, IPv6+NAT
are working again.

Signed-off-by: Julius Volz <juliusv@google.com>

 1 files changed, 0 insertions(+), 9 deletions(-)

diff --git a/net/ipv4/ipvs/ip_vs_core.c b/net/ipv4/ipvs/ip_vs_core.c
index f5180ac..bdc92d7 100644
--- a/net/ipv4/ipvs/ip_vs_core.c
+++ b/net/ipv4/ipvs/ip_vs_core.c
@@ -904,15 +904,6 @@ handle_response(int af, struct sk_buff *skb, struct ip_vs_protocol *pp,
 		if (ip_route_me_harder(skb, RTN_LOCAL) != 0)
 			goto drop;
 
-	/* For policy routing, packets originating from this
-	 * machine itself may be routed differently to packets
-	 * passing through.  We want this packet to be routed as
-	 * if it came from this machine itself.  So re-compute
-	 * the routing information.
-	 */
-	if (ip_route_me_harder(skb, RTN_LOCAL) != 0)
-		goto drop;
-
 	IP_VS_DBG_PKT(10, pp, skb, 0, "After SNAT");
 
 	ip_vs_out_stats(cp, skb);
-- 
1.5.4.5

