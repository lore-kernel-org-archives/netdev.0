From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 1/2] ipvs: SCTP ports should be writable in ICMP packets
Date: Fri, 21 Jun 2013 02:38:40 +0200
Message-ID: <1371775121-9710-2-git-send-email-pablo@netfilter.org>
References: <1371775121-9710-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:59457 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758204Ab3FUAi7 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 20 Jun 2013 20:38:59 -0400
In-Reply-To: <1371775121-9710-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Julian Anastasov <ja@ssi.bg>

Make sure that SCTP ports are writable when embedded in ICMP
from client, so that ip_vs_nat_icmp can translate them safely.

Signed-off-by: Julian Anastasov <ja@ssi.bg>
Signed-off-by: Simon Horman <horms@verge.net.au>
---
 net/netfilter/ipvs/ip_vs_core.c |    3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/net/netfilter/ipvs/ip_vs_core.c b/net/netfilter/ipvs/ip_vs_core.c
index 05565d2..23b8eb5 100644
--- a/net/netfilter/ipvs/ip_vs_core.c
+++ b/net/netfilter/ipvs/ip_vs_core.c
@@ -1442,7 +1442,8 @@ ignore_ipip:
 
 	/* do the statistics and put it back */
 	ip_vs_in_stats(cp, skb);
-	if (IPPROTO_TCP == cih->protocol || IPPROTO_UDP == cih->protocol)
+	if (IPPROTO_TCP == cih->protocol || IPPROTO_UDP == cih->protocol ||
+	    IPPROTO_SCTP == cih->protocol)
 		offset += 2 * sizeof(__u16);
 	verdict = ip_vs_icmp_xmit(skb, cp, pp, offset, hooknum, &ciph);
 
-- 
1.7.10.4
