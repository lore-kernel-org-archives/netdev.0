From: Simon Horman <horms@verge.net.au>
Subject: [PATCH 02/18] ipvs: LBLC scheduler does not need GFP_ATOMIC allocation on init
Date: Wed,  2 May 2012 15:22:26 +0900
Message-ID: <1335939762-1912-3-git-send-email-horms@verge.net.au>
References: <1335939762-1912-1-git-send-email-horms@verge.net.au>
Cc: lvs-devel@vger.kernel.org, netdev@vger.kernel.org,
	netfilter-devel@vger.kernel.org,
	Wensong Zhang <wensong@linux-vs.org>,
	Julian Anastasov <ja@ssi.bg>,
	Hans Schillstrom <hans.schillstrom@ericsson.com>,
	Jesper Dangaard Brouer <brouer@redhat.com>,
	Hans Schillstrom <hans@schillstrom.com>,
	Simon Horman <horms@verge.net.au>
To: Pablo Neira Ayuso <pablo@netfilter.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from kirsty.vergenet.net ([202.4.237.240]:44669 "EHLO
	kirsty.vergenet.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754073Ab2EBGWs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 May 2012 02:22:48 -0400
In-Reply-To: <1335939762-1912-1-git-send-email-horms@verge.net.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Julian Anastasov <ja@ssi.bg>

	Schedulers are initialized and bound to services only
on commands.

Signed-off-by: Julian Anastasov <ja@ssi.bg>
Signed-off-by: Hans Schillstrom <hans@schillstrom.com>
Signed-off-by: Simon Horman <horms@verge.net.au>
---
 net/netfilter/ipvs/ip_vs_lblc.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/netfilter/ipvs/ip_vs_lblc.c b/net/netfilter/ipvs/ip_vs_lblc.c
index 27c24f1..7ba1672 100644
--- a/net/netfilter/ipvs/ip_vs_lblc.c
+++ b/net/netfilter/ipvs/ip_vs_lblc.c
@@ -342,7 +342,7 @@ static int ip_vs_lblc_init_svc(struct ip_vs_service *svc)
 	/*
 	 *    Allocate the ip_vs_lblc_table for this service
 	 */
-	tbl = kmalloc(sizeof(*tbl), GFP_ATOMIC);
+	tbl = kmalloc(sizeof(*tbl), GFP_KERNEL);
 	if (tbl == NULL)
 		return -ENOMEM;
 
-- 
1.7.10
