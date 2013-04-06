From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 22/51] ipvs: convert nq scheduler to rcu
Date: Sat,  6 Apr 2013 14:17:21 +0200
Message-ID: <1365250670-14993-23-git-send-email-pablo@netfilter.org>
References: <1365250670-14993-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:38946 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1163409Ab3DFMSa (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 6 Apr 2013 08:18:30 -0400
In-Reply-To: <1365250670-14993-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Julian Anastasov <ja@ssi.bg>

The schedule method now needs _rcu list-traversal
primitive for svc->destinations.

Signed-off-by: Julian Anastasov <ja@ssi.bg>
Signed-off-by: Simon Horman <horms@verge.net.au>
---
 net/netfilter/ipvs/ip_vs_nq.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/netfilter/ipvs/ip_vs_nq.c b/net/netfilter/ipvs/ip_vs_nq.c
index 984d9c1..51dc0cf 100644
--- a/net/netfilter/ipvs/ip_vs_nq.c
+++ b/net/netfilter/ipvs/ip_vs_nq.c
@@ -75,7 +75,7 @@ ip_vs_nq_schedule(struct ip_vs_service *svc, const struct sk_buff *skb)
 	 * new connections.
 	 */
 
-	list_for_each_entry(dest, &svc->destinations, n_list) {
+	list_for_each_entry_rcu(dest, &svc->destinations, n_list) {
 
 		if (dest->flags & IP_VS_DEST_F_OVERLOAD ||
 		    !atomic_read(&dest->weight))
-- 
1.7.10.4
