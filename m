From: Denis Kirjanov <kda@linux-powerpc.org>
Subject: [PATCH v2 net-next] ipv4: ip_forward: perform skb->pkt_type check at the beginning
Date: Thu, 13 Feb 2014 08:58:56 +0400
Message-ID: <1392267536-2453-1-git-send-email-kda@linux-powerpc.org>
Cc: Denis Kirjanov <kda@linux-powerpc.org>
To: netdev@vger.kernel.org, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f181.google.com ([209.85.217.181]:33544 "EHLO
	mail-lb0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753190AbaBMItZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 13 Feb 2014 03:49:25 -0500
Received: by mail-lb0-f181.google.com with SMTP id z11so6902376lbi.40
        for <netdev@vger.kernel.org>; Thu, 13 Feb 2014 00:49:23 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Packets which have L2 address different from ours should be
already filtered before entering into ip_forward().

Perform that check at the beginning to avoid processing such packets.

Signed-off-by: Denis Kirjanov <kda@linux-powerpc.org>
---
v1 -> v2: Fixed identation
---
 net/ipv4/ip_forward.c | 7 ++++---
 1 file changed, 4 insertions(+), 3 deletions(-)

diff --git a/net/ipv4/ip_forward.c b/net/ipv4/ip_forward.c
index e9f1217..d9d9290 100644
--- a/net/ipv4/ip_forward.c
+++ b/net/ipv4/ip_forward.c
@@ -59,6 +59,10 @@ int ip_forward(struct sk_buff *skb)
 	struct rtable *rt;	/* Route we use */
 	struct ip_options *opt	= &(IPCB(skb)->opt);
 
+	/* that should never happen */
+	if (skb->pkt_type != PACKET_HOST)
+		goto drop;
+
 	if (skb_warn_if_lro(skb))
 		goto drop;
 
@@ -68,9 +72,6 @@ int ip_forward(struct sk_buff *skb)
 	if (IPCB(skb)->opt.router_alert && ip_call_ra_chain(skb))
 		return NET_RX_SUCCESS;
 
-	if (skb->pkt_type != PACKET_HOST)
-		goto drop;
-
 	skb_forward_csum(skb);
 
 	/*
-- 
1.8.0.2
