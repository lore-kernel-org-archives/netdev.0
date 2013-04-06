From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 24/51] ipvs: convert sed scheduler to rcu
Date: Sat,  6 Apr 2013 14:17:23 +0200
Message-ID: <1365250670-14993-25-git-send-email-pablo@netfilter.org>
References: <1365250670-14993-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:38960 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1163417Ab3DFMSd (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 6 Apr 2013 08:18:33 -0400
In-Reply-To: <1365250670-14993-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Julian Anastasov <ja@ssi.bg>

The schedule method now needs _rcu list-traversal
primitive for svc->destinations.

Signed-off-by: Julian Anastasov <ja@ssi.bg>
Signed-off-by: Simon Horman <horms@verge.net.au>
---
 net/netfilter/ipvs/ip_vs_sed.c |    4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/netfilter/ipvs/ip_vs_sed.c b/net/netfilter/ipvs/ip_vs_sed.c
index 89ead246..d011870 100644
--- a/net/netfilter/ipvs/ip_vs_sed.c
+++ b/net/netfilter/ipvs/ip_vs_sed.c
@@ -79,7 +79,7 @@ ip_vs_sed_schedule(struct ip_vs_service *svc, const struct sk_buff *skb)
 	 * new connections.
 	 */
 
-	list_for_each_entry(dest, &svc->destinations, n_list) {
+	list_for_each_entry_rcu(dest, &svc->destinations, n_list) {
 		if (!(dest->flags & IP_VS_DEST_F_OVERLOAD) &&
 		    atomic_read(&dest->weight) > 0) {
 			least = dest;
@@ -94,7 +94,7 @@ ip_vs_sed_schedule(struct ip_vs_service *svc, const struct sk_buff *skb)
 	 *    Find the destination with the least load.
 	 */
   nextstage:
-	list_for_each_entry_continue(dest, &svc->destinations, n_list) {
+	list_for_each_entry_continue_rcu(dest, &svc->destinations, n_list) {
 		if (dest->flags & IP_VS_DEST_F_OVERLOAD)
 			continue;
 		doh = ip_vs_sed_dest_overhead(dest);
-- 
1.7.10.4
