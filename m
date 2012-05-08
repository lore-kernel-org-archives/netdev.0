From: pablo@netfilter.org
Subject: [PATCH 10/25] ipvs: SH scheduler does not need GFP_ATOMIC allocation
Date: Tue,  8 May 2012 20:38:08 +0200
Message-ID: <1336502303-1722-11-git-send-email-pablo@netfilter.org>
References: <1336502303-1722-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, openbsc@lists.osmocom.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:39093 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756020Ab2EHSjg (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 8 May 2012 14:39:36 -0400
In-Reply-To: <1336502303-1722-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Julian Anastasov <ja@ssi.bg>

        Schedulers are initialized and bound to services only
on commands.

Signed-off-by: Julian Anastasov <ja@ssi.bg>
Signed-off-by: Hans Schillstrom <hans@schillstrom.com>
Signed-off-by: Simon Horman <horms@verge.net.au>
---
 net/netfilter/ipvs/ip_vs_sh.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/netfilter/ipvs/ip_vs_sh.c b/net/netfilter/ipvs/ip_vs_sh.c
index 91e97ee..0512652 100644
--- a/net/netfilter/ipvs/ip_vs_sh.c
+++ b/net/netfilter/ipvs/ip_vs_sh.c
@@ -162,7 +162,7 @@ static int ip_vs_sh_init_svc(struct ip_vs_service *svc)
 
 	/* allocate the SH table for this service */
 	tbl = kmalloc(sizeof(struct ip_vs_sh_bucket)*IP_VS_SH_TAB_SIZE,
-		      GFP_ATOMIC);
+		      GFP_KERNEL);
 	if (tbl == NULL)
 		return -ENOMEM;
 
-- 
1.7.9.5
