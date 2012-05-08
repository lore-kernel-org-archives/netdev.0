From: pablo@netfilter.org
Subject: [PATCH 13/25] ipvs: remove check for IP_VS_CONN_F_SYNC from ip_vs_bind_dest
Date: Tue,  8 May 2012 20:38:11 +0200
Message-ID: <1336502303-1722-14-git-send-email-pablo@netfilter.org>
References: <1336502303-1722-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, openbsc@lists.osmocom.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:38974 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755594Ab2EHSjR (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 8 May 2012 14:39:17 -0400
In-Reply-To: <1336502303-1722-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Julian Anastasov <ja@ssi.bg>

	As the IP_VS_CONN_F_INACTIVE bit is properly set
in cp->flags for all kind of connections we do not need to
add special checks for synced connections when updating
the activeconns/inactconns counters for first time. Now
logic will look just like in ip_vs_unbind_dest.

Signed-off-by: Julian Anastasov <ja@ssi.bg>
Signed-off-by: Simon Horman <horms@verge.net.au>
---
 net/netfilter/ipvs/ip_vs_conn.c |   10 +++++-----
 1 file changed, 5 insertions(+), 5 deletions(-)

diff --git a/net/netfilter/ipvs/ip_vs_conn.c b/net/netfilter/ipvs/ip_vs_conn.c
index f562e63..1c1bb30 100644
--- a/net/netfilter/ipvs/ip_vs_conn.c
+++ b/net/netfilter/ipvs/ip_vs_conn.c
@@ -585,11 +585,11 @@ ip_vs_bind_dest(struct ip_vs_conn *cp, struct ip_vs_dest *dest)
 
 	/* Update the connection counters */
 	if (!(cp->flags & IP_VS_CONN_F_TEMPLATE)) {
-		/* It is a normal connection, so increase the inactive
-		   connection counter because it is in TCP SYNRECV
-		   state (inactive) or other protocol inacive state */
-		if ((cp->flags & IP_VS_CONN_F_SYNC) &&
-		    (!(cp->flags & IP_VS_CONN_F_INACTIVE)))
+		/* It is a normal connection, so modify the counters
+		 * according to the flags, later the protocol can
+		 * update them on state change
+		 */
+		if (!(cp->flags & IP_VS_CONN_F_INACTIVE))
 			atomic_inc(&dest->activeconns);
 		else
 			atomic_inc(&dest->inactconns);
-- 
1.7.9.5
