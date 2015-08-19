From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 05/15] netfilter: nft_limit: rename to nft_limit_pkts
Date: Wed, 19 Aug 2015 21:18:21 +0200
Message-ID: <1440011911-4359-6-git-send-email-pablo@netfilter.org>
References: <1440011911-4359-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:44909 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751821AbbHSTMn (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 19 Aug 2015 15:12:43 -0400
In-Reply-To: <1440011911-4359-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

To prepare introduction of bytes ratelimit support.

Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 net/netfilter/nft_limit.c |   12 ++++++------
 1 file changed, 6 insertions(+), 6 deletions(-)

diff --git a/net/netfilter/nft_limit.c b/net/netfilter/nft_limit.c
index 435c1cc..d0788e1 100644
--- a/net/netfilter/nft_limit.c
+++ b/net/netfilter/nft_limit.c
@@ -26,9 +26,9 @@ struct nft_limit {
 	unsigned long	stamp;
 };
 
-static void nft_limit_eval(const struct nft_expr *expr,
-			   struct nft_regs *regs,
-			   const struct nft_pktinfo *pkt)
+static void nft_limit_pkts_eval(const struct nft_expr *expr,
+				struct nft_regs *regs,
+				const struct nft_pktinfo *pkt)
 {
 	struct nft_limit *priv = nft_expr_priv(expr);
 
@@ -85,17 +85,17 @@ nla_put_failure:
 }
 
 static struct nft_expr_type nft_limit_type;
-static const struct nft_expr_ops nft_limit_ops = {
+static const struct nft_expr_ops nft_limit_pkts_ops = {
 	.type		= &nft_limit_type,
 	.size		= NFT_EXPR_SIZE(sizeof(struct nft_limit)),
-	.eval		= nft_limit_eval,
+	.eval		= nft_limit_pkts_eval,
 	.init		= nft_limit_init,
 	.dump		= nft_limit_dump,
 };
 
 static struct nft_expr_type nft_limit_type __read_mostly = {
 	.name		= "limit",
-	.ops		= &nft_limit_ops,
+	.ops		= &nft_limit_pkts_ops,
 	.policy		= nft_limit_policy,
 	.maxattr	= NFTA_LIMIT_MAX,
 	.flags		= NFT_EXPR_STATEFUL,
-- 
1.7.10.4
