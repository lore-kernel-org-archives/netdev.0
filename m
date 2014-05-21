From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 08/25] netfilter: nf_tables: Stack expression type depending on their family
Date: Wed, 21 May 2014 11:43:06 +0200
Message-ID: <1400665402-5835-9-git-send-email-pablo@netfilter.org>
References: <1400665402-5835-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1400665402-5835-1-git-send-email-pablo@netfilter.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Tomasz Bursztyka <tomasz.bursztyka@linux.intel.com>

To ensure family tight expression gets selected in priority to family
agnostic ones.

Signed-off-by: Tomasz Bursztyka <tomasz.bursztyka@linux.intel.com>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 net/netfilter/nf_tables_api.c |    5 ++++-
 1 file changed, 4 insertions(+), 1 deletion(-)

diff --git a/net/netfilter/nf_tables_api.c b/net/netfilter/nf_tables_api.c
index 1c5e633..1d0c174 100644
--- a/net/netfilter/nf_tables_api.c
+++ b/net/netfilter/nf_tables_api.c
@@ -1093,7 +1093,10 @@ static void nft_ctx_init(struct nft_ctx *ctx,
 int nft_register_expr(struct nft_expr_type *type)
 {
 	nfnl_lock(NFNL_SUBSYS_NFTABLES);
-	list_add_tail(&type->list, &nf_tables_expressions);
+	if (type->family == NFPROTO_UNSPEC)
+		list_add_tail(&type->list, &nf_tables_expressions);
+	else
+		list_add(&type->list, &nf_tables_expressions);
 	nfnl_unlock(NFNL_SUBSYS_NFTABLES);
 	return 0;
 }
-- 
1.7.10.4

