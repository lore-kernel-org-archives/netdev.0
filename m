From: David Miller <davem@davemloft.net>
Subject: [PATCH 4/10] ipvs: Use IP_VS_RT_MODE_* instead of magic constants.
Date: Mon, 09 May 2011 22:31:18 -0700 (PDT)
Message-ID: <20110509.223118.260083861.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:53404
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752993Ab1EJFbu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 May 2011 01:31:50 -0400
Received: from localhost (localhost [127.0.0.1])
	by sunset.davemloft.net (Postfix) with ESMTP id 683A224C087
	for <netdev@vger.kernel.org>; Mon,  9 May 2011 22:31:18 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Signed-off-by: David S. Miller <davem@davemloft.net>
---
 net/netfilter/ipvs/ip_vs_xmit.c |   17 ++++++++++++-----
 1 files changed, 12 insertions(+), 5 deletions(-)

diff --git a/net/netfilter/ipvs/ip_vs_xmit.c b/net/netfilter/ipvs/ip_vs_xmit.c
index 6132b21..c4a19f9 100644
--- a/net/netfilter/ipvs/ip_vs_xmit.c
+++ b/net/netfilter/ipvs/ip_vs_xmit.c
@@ -440,7 +440,8 @@ ip_vs_bypass_xmit_v6(struct sk_buff *skb, struct ip_vs_conn *cp,
 
 	EnterFunction(10);
 
-	if (!(rt = __ip_vs_get_out_rt_v6(skb, NULL, &iph->daddr, NULL, 0, 2)))
+	if (!(rt = __ip_vs_get_out_rt_v6(skb, NULL, &iph->daddr, NULL, 0,
+					 IP_VS_RT_MODE_NON_LOCAL)))
 		goto tx_error_icmp;
 
 	/* MTU checking */
@@ -632,7 +633,9 @@ ip_vs_nat_xmit_v6(struct sk_buff *skb, struct ip_vs_conn *cp,
 	}
 
 	if (!(rt = __ip_vs_get_out_rt_v6(skb, cp->dest, &cp->daddr.in6, NULL,
-					 0, 1|2|4)))
+					 0, (IP_VS_RT_MODE_LOCAL |
+					     IP_VS_RT_MODE_NON_LOCAL |
+					     IP_VS_RT_MODE_RDR))))
 		goto tx_error_icmp;
 	local = __ip_vs_is_local_route6(rt);
 	/*
@@ -875,7 +878,8 @@ ip_vs_tunnel_xmit_v6(struct sk_buff *skb, struct ip_vs_conn *cp,
 	EnterFunction(10);
 
 	if (!(rt = __ip_vs_get_out_rt_v6(skb, cp->dest, &cp->daddr.in6,
-					 &saddr, 1, 1|2)))
+					 &saddr, 1, (IP_VS_RT_MODE_LOCAL |
+						     IP_VS_RT_MODE_NON_LOCAL))))
 		goto tx_error_icmp;
 	if (__ip_vs_is_local_route6(rt)) {
 		dst_release(&rt->dst);
@@ -1050,7 +1054,8 @@ ip_vs_dr_xmit_v6(struct sk_buff *skb, struct ip_vs_conn *cp,
 	EnterFunction(10);
 
 	if (!(rt = __ip_vs_get_out_rt_v6(skb, cp->dest, &cp->daddr.in6, NULL,
-					 0, 1|2)))
+					 0, (IP_VS_RT_MODE_LOCAL |
+					     IP_VS_RT_MODE_NON_LOCAL))))
 		goto tx_error_icmp;
 	if (__ip_vs_is_local_route6(rt)) {
 		dst_release(&rt->dst);
@@ -1254,7 +1259,9 @@ ip_vs_icmp_xmit_v6(struct sk_buff *skb, struct ip_vs_conn *cp,
 	 */
 
 	if (!(rt = __ip_vs_get_out_rt_v6(skb, cp->dest, &cp->daddr.in6, NULL,
-					 0, 1|2|4)))
+					 0, (IP_VS_RT_MODE_LOCAL |
+					     IP_VS_RT_MODE_NON_LOCAL |
+					     IP_VS_RT_MODE_RDR))))
 		goto tx_error_icmp;
 
 	local = __ip_vs_is_local_route6(rt);
-- 
1.7.5.1

