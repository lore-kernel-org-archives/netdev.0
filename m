From: Julian Anastasov <ja@ssi.bg>
Subject: [PATCH net-next 10/19] ipvs: convert sed scheduler to rcu
Date: Fri, 22 Mar 2013 11:46:45 +0200
Message-ID: <1363945614-11752-11-git-send-email-ja@ssi.bg>
References: <1363945614-11752-1-git-send-email-ja@ssi.bg>
Cc: lvs-devel@vger.kernel.org, netdev@vger.kernel.org
To: Simon Horman <horms@verge.net.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ja.ssi.bg ([178.16.129.10]:43383 "EHLO ja.ssi.bg"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754971Ab3CVJpZ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 22 Mar 2013 05:45:25 -0400
In-Reply-To: <1363945614-11752-1-git-send-email-ja@ssi.bg>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

	The schedule method now needs _rcu list-traversal
primitive for svc->destinations.

Signed-off-by: Julian Anastasov <ja@ssi.bg>
---
 net/netfilter/ipvs/ip_vs_sed.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

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
1.7.3.4
