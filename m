From: kaber@trash.net
Subject: [PATCH 40/84] netfilter: ipvs: use NFPROTO values for NF_HOOK invocation
Date: Mon, 10 May 2010 22:18:11 +0200
Message-ID: <1273522735-24672-41-git-send-email-kaber@trash.net>
References: <1273522735-24672-1-git-send-email-kaber@trash.net>
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:54510 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756788Ab0EJUTJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 10 May 2010 16:19:09 -0400
In-Reply-To: <1273522735-24672-1-git-send-email-kaber@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jan Engelhardt <jengelh@medozas.de>

Semantic patch:
// <smpl>
@@
@@
 IP_VS_XMIT(
-PF_INET6,
+NFPROTO_IPV6,
 ...)

@@
@@
 IP_VS_XMIT(
-PF_INET,
+NFPROTO_IPV4,
 ...)
// </smpl>

Signed-off-by: Jan Engelhardt <jengelh@medozas.de>
---
 net/netfilter/ipvs/ip_vs_xmit.c |   16 ++++++++--------
 1 files changed, 8 insertions(+), 8 deletions(-)

diff --git a/net/netfilter/ipvs/ip_vs_xmit.c b/net/netfilter/ipvs/ip_vs_xmit.c
index 223b501..d0a7b7b 100644
--- a/net/netfilter/ipvs/ip_vs_xmit.c
+++ b/net/netfilter/ipvs/ip_vs_xmit.c
@@ -269,7 +269,7 @@ ip_vs_bypass_xmit(struct sk_buff *skb, struct ip_vs_conn *cp,
 	/* Another hack: avoid icmp_send in ip_fragment */
 	skb->local_df = 1;
 
-	IP_VS_XMIT(PF_INET, skb, rt);
+	IP_VS_XMIT(NFPROTO_IPV4, skb, rt);
 
 	LeaveFunction(10);
 	return NF_STOLEN;
@@ -333,7 +333,7 @@ ip_vs_bypass_xmit_v6(struct sk_buff *skb, struct ip_vs_conn *cp,
 	/* Another hack: avoid icmp_send in ip_fragment */
 	skb->local_df = 1;
 
-	IP_VS_XMIT(PF_INET6, skb, rt);
+	IP_VS_XMIT(NFPROTO_IPV6, skb, rt);
 
 	LeaveFunction(10);
 	return NF_STOLEN;
@@ -409,7 +409,7 @@ ip_vs_nat_xmit(struct sk_buff *skb, struct ip_vs_conn *cp,
 	/* Another hack: avoid icmp_send in ip_fragment */
 	skb->local_df = 1;
 
-	IP_VS_XMIT(PF_INET, skb, rt);
+	IP_VS_XMIT(NFPROTO_IPV4, skb, rt);
 
 	LeaveFunction(10);
 	return NF_STOLEN;
@@ -485,7 +485,7 @@ ip_vs_nat_xmit_v6(struct sk_buff *skb, struct ip_vs_conn *cp,
 	/* Another hack: avoid icmp_send in ip_fragment */
 	skb->local_df = 1;
 
-	IP_VS_XMIT(PF_INET6, skb, rt);
+	IP_VS_XMIT(NFPROTO_IPV6, skb, rt);
 
 	LeaveFunction(10);
 	return NF_STOLEN;
@@ -784,7 +784,7 @@ ip_vs_dr_xmit(struct sk_buff *skb, struct ip_vs_conn *cp,
 	/* Another hack: avoid icmp_send in ip_fragment */
 	skb->local_df = 1;
 
-	IP_VS_XMIT(PF_INET, skb, rt);
+	IP_VS_XMIT(NFPROTO_IPV4, skb, rt);
 
 	LeaveFunction(10);
 	return NF_STOLEN;
@@ -837,7 +837,7 @@ ip_vs_dr_xmit_v6(struct sk_buff *skb, struct ip_vs_conn *cp,
 	/* Another hack: avoid icmp_send in ip_fragment */
 	skb->local_df = 1;
 
-	IP_VS_XMIT(PF_INET6, skb, rt);
+	IP_VS_XMIT(NFPROTO_IPV6, skb, rt);
 
 	LeaveFunction(10);
 	return NF_STOLEN;
@@ -911,7 +911,7 @@ ip_vs_icmp_xmit(struct sk_buff *skb, struct ip_vs_conn *cp,
 	/* Another hack: avoid icmp_send in ip_fragment */
 	skb->local_df = 1;
 
-	IP_VS_XMIT(PF_INET, skb, rt);
+	IP_VS_XMIT(NFPROTO_IPV4, skb, rt);
 
 	rc = NF_STOLEN;
 	goto out;
@@ -986,7 +986,7 @@ ip_vs_icmp_xmit_v6(struct sk_buff *skb, struct ip_vs_conn *cp,
 	/* Another hack: avoid icmp_send in ip_fragment */
 	skb->local_df = 1;
 
-	IP_VS_XMIT(PF_INET6, skb, rt);
+	IP_VS_XMIT(NFPROTO_IPV6, skb, rt);
 
 	rc = NF_STOLEN;
 	goto out;
-- 
1.7.0.4

