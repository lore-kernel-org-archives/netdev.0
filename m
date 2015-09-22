From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 08/30] ipvs: Use outer header in ip_vs_bypass_xmit_v6
Date: Tue, 22 Sep 2015 11:13:58 +0200
Message-ID: <1442913260-3925-9-git-send-email-pablo@netfilter.org>
References: <1442913260-3925-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:34942 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757619AbbIVJHq (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 22 Sep 2015 05:07:46 -0400
In-Reply-To: <1442913260-3925-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alex Gartrell <agartrell@fb.com>

The ip_vs_iphdr may refer to an internal header, so use the outer one
instead.

Signed-off-by: Alex Gartrell <agartrell@fb.com>
Acked-by: Julian Anastasov <ja@ssi.bg>
Signed-off-by: Simon Horman <horms@verge.net.au>
---
 net/netfilter/ipvs/ip_vs_xmit.c |    4 +++-
 1 file changed, 3 insertions(+), 1 deletion(-)

diff --git a/net/netfilter/ipvs/ip_vs_xmit.c b/net/netfilter/ipvs/ip_vs_xmit.c
index 9a26f2e..af5e9d3 100644
--- a/net/netfilter/ipvs/ip_vs_xmit.c
+++ b/net/netfilter/ipvs/ip_vs_xmit.c
@@ -656,10 +656,12 @@ int
 ip_vs_bypass_xmit_v6(struct sk_buff *skb, struct ip_vs_conn *cp,
 		     struct ip_vs_protocol *pp, struct ip_vs_iphdr *ipvsh)
 {
+	struct ipv6hdr *iph = ipv6_hdr(skb);
+
 	EnterFunction(10);
 
 	rcu_read_lock();
-	if (__ip_vs_get_out_rt_v6(cp->af, skb, NULL, &ipvsh->daddr.in6, NULL,
+	if (__ip_vs_get_out_rt_v6(cp->af, skb, NULL, &iph->daddr, NULL,
 				  ipvsh, 0, IP_VS_RT_MODE_NON_LOCAL) < 0)
 		goto tx_error;
 
-- 
1.7.10.4
