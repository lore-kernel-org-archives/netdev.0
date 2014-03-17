From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 28/38] netfilter: nf_tables: restore notifications for anonymous set destruction
Date: Mon, 17 Mar 2014 13:42:48 +0100
Message-ID: <1395060178-11833-29-git-send-email-pablo@netfilter.org>
References: <1395060178-11833-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:59540 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933183AbaCQMnu (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 17 Mar 2014 08:43:50 -0400
In-Reply-To: <1395060178-11833-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Patrick McHardy <kaber@trash.net>

Since we have the context available again, we can restore notifications
for destruction of anonymous sets.

Signed-off-by: Patrick McHardy <kaber@trash.net>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 net/netfilter/nf_tables_api.c |    3 +--
 net/netfilter/nft_lookup.c    |    2 +-
 2 files changed, 2 insertions(+), 3 deletions(-)

diff --git a/net/netfilter/nf_tables_api.c b/net/netfilter/nf_tables_api.c
index 2c10c3f..33045a5 100644
--- a/net/netfilter/nf_tables_api.c
+++ b/net/netfilter/nf_tables_api.c
@@ -2442,8 +2442,7 @@ err1:
 static void nf_tables_set_destroy(const struct nft_ctx *ctx, struct nft_set *set)
 {
 	list_del(&set->list);
-	if (!(set->flags & NFT_SET_ANONYMOUS))
-		nf_tables_set_notify(ctx, set, NFT_MSG_DELSET);
+	nf_tables_set_notify(ctx, set, NFT_MSG_DELSET);
 
 	set->ops->destroy(set);
 	module_put(set->ops->owner);
diff --git a/net/netfilter/nft_lookup.c b/net/netfilter/nft_lookup.c
index 953978e..7fd2bea 100644
--- a/net/netfilter/nft_lookup.c
+++ b/net/netfilter/nft_lookup.c
@@ -94,7 +94,7 @@ static void nft_lookup_destroy(const struct nft_ctx *ctx,
 {
 	struct nft_lookup *priv = nft_expr_priv(expr);
 
-	nf_tables_unbind_set(NULL, priv->set, &priv->binding);
+	nf_tables_unbind_set(ctx, priv->set, &priv->binding);
 }
 
 static int nft_lookup_dump(struct sk_buff *skb, const struct nft_expr *expr)
-- 
1.7.10.4
