From: pablo@netfilter.org
Subject: [PATCH 09/25] ipvs: LBLCR scheduler does not need GFP_ATOMIC allocation on init
Date: Tue,  8 May 2012 02:22:03 +0200
Message-ID: <1336436539-5880-10-git-send-email-pablo@netfilter.org>
References: <1336436539-5880-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:51763 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757999Ab2EHAW5 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 7 May 2012 20:22:57 -0400
In-Reply-To: <1336436539-5880-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Julian Anastasov <ja@ssi.bg>

	Schedulers are initialized and bound to services only
on commands.

Signed-off-by: Julian Anastasov <ja@ssi.bg>
Signed-off-by: Hans Schillstrom <hans@schillstrom.com>
Signed-off-by: Simon Horman <horms@verge.net.au>
---
 net/netfilter/ipvs/ip_vs_lblcr.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/netfilter/ipvs/ip_vs_lblcr.c b/net/netfilter/ipvs/ip_vs_lblcr.c
index 7498756..00906ea 100644
--- a/net/netfilter/ipvs/ip_vs_lblcr.c
+++ b/net/netfilter/ipvs/ip_vs_lblcr.c
@@ -511,7 +511,7 @@ static int ip_vs_lblcr_init_svc(struct ip_vs_service *svc)
 	/*
 	 *    Allocate the ip_vs_lblcr_table for this service
 	 */
-	tbl = kmalloc(sizeof(*tbl), GFP_ATOMIC);
+	tbl = kmalloc(sizeof(*tbl), GFP_KERNEL);
 	if (tbl == NULL)
 		return -ENOMEM;
 
-- 
1.7.9.5
