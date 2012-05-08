From: pablo@netfilter.org
Subject: [PATCH 07/25] ipvs: DH scheduler does not need GFP_ATOMIC allocation
Date: Tue,  8 May 2012 09:49:37 +0200
Message-ID: <1336463394-3119-9-git-send-email-pablo@netfilter.org>
References: <1336463394-3119-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1336463394-3119-1-git-send-email-pablo@netfilter.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Julian Anastasov <ja@ssi.bg>

	Schedulers are initialized and bound to services only
on commands.

Signed-off-by: Julian Anastasov <ja@ssi.bg>
Signed-off-by: Hans Schillstrom <hans@schillstrom.com>
Signed-off-by: Simon Horman <horms@verge.net.au>
---
 net/netfilter/ipvs/ip_vs_dh.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/netfilter/ipvs/ip_vs_dh.c b/net/netfilter/ipvs/ip_vs_dh.c
index 1a53a7a..8b7dca9 100644
--- a/net/netfilter/ipvs/ip_vs_dh.c
+++ b/net/netfilter/ipvs/ip_vs_dh.c
@@ -149,7 +149,7 @@ static int ip_vs_dh_init_svc(struct ip_vs_service *svc)
 
 	/* allocate the DH table for this service */
 	tbl = kmalloc(sizeof(struct ip_vs_dh_bucket)*IP_VS_DH_TAB_SIZE,
-		      GFP_ATOMIC);
+		      GFP_KERNEL);
 	if (tbl == NULL)
 		return -ENOMEM;
 
-- 
1.7.9.5

