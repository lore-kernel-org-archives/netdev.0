From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH net] ipvs: avoid netns exit crash on ip_vs_conn_drop_conntrack
Date: Mon, 21 Jul 2014 14:15:08 +0200
Message-ID: <1405944908-4487-2-git-send-email-pablo@netfilter.org>
References: <1405944908-4487-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:54250 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754414AbaGUMPO (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 21 Jul 2014 08:15:14 -0400
In-Reply-To: <1405944908-4487-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Julian Anastasov <ja@ssi.bg>

commit 8f4e0a18682d91 ("IPVS netns exit causes crash in conntrack")
added second ip_vs_conn_drop_conntrack call instead of just adding
the needed check. As result, the first call still can cause
crash on netns exit. Remove it.

Signed-off-by: Julian Anastasov <ja@ssi.bg>
Signed-off-by: Hans Schillstrom <hans@schillstrom.com>
Signed-off-by: Simon Horman <horms@verge.net.au>
---
 net/netfilter/ipvs/ip_vs_conn.c |    1 -
 1 file changed, 1 deletion(-)

diff --git a/net/netfilter/ipvs/ip_vs_conn.c b/net/netfilter/ipvs/ip_vs_conn.c
index a8eb0a8..610e19c 100644
--- a/net/netfilter/ipvs/ip_vs_conn.c
+++ b/net/netfilter/ipvs/ip_vs_conn.c
@@ -797,7 +797,6 @@ static void ip_vs_conn_expire(unsigned long data)
 			ip_vs_control_del(cp);
 
 		if (cp->flags & IP_VS_CONN_F_NFCT) {
-			ip_vs_conn_drop_conntrack(cp);
 			/* Do not access conntracks during subsys cleanup
 			 * because nf_conntrack_find_get can not be used after
 			 * conntrack cleanup for the net.
-- 
1.7.10.4
