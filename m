From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: [PATCH] ipv6: remove unneeded check to pskb_may_pull in ipip6_rcv
Date: Fri, 18 Jan 2013 20:18:17 +0100
Message-ID: <20130118191816.GA4795@order.stressinduktion.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from order.stressinduktion.org ([87.106.68.36]:36682 "EHLO
	order.stressinduktion.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751574Ab3ARTSS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 18 Jan 2013 14:18:18 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is already checked by the caller (tunnel64_rcv) and brings ipip6_rcv
in line with ipip_rcv.

Signed-off-by: Hannes Frederic Sowa <hannes@stressinduktion.org>
---
 net/ipv6/sit.c | 7 +------
 1 file changed, 1 insertion(+), 6 deletions(-)

diff --git a/net/ipv6/sit.c b/net/ipv6/sit.c
index cfba99b..98fe536 100644
--- a/net/ipv6/sit.c
+++ b/net/ipv6/sit.c
@@ -592,15 +592,10 @@ out:
 
 static int ipip6_rcv(struct sk_buff *skb)
 {
-	const struct iphdr *iph;
+	const struct iphdr *iph = ip_hdr(skb);
 	struct ip_tunnel *tunnel;
 	int err;
 
-	if (!pskb_may_pull(skb, sizeof(struct ipv6hdr)))
-		goto out;
-
-	iph = ip_hdr(skb);
-
 	tunnel = ipip6_tunnel_lookup(dev_net(skb->dev), skb->dev,
 				     iph->saddr, iph->daddr);
 	if (tunnel != NULL) {
-- 
1.7.11.7
