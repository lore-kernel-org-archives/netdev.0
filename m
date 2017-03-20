From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 02/22] netfilter: nft_hash: rename nft_hash to nft_jhash
Date: Mon, 20 Mar 2017 11:08:30 +0100
Message-ID: <1490004530-9128-3-git-send-email-pablo@netfilter.org>
References: <1490004530-9128-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1490004530-9128-1-git-send-email-pablo@netfilter.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Laura Garcia Liebana <nevola@gmail.com>

This patch renames the local nft_hash structure and functions
to nft_jhash in order to prepare the nft_hash module code to
add new hash functions.

Signed-off-by: Laura Garcia Liebana <laura.garcia@zevenet.com>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 net/netfilter/nft_hash.c | 36 ++++++++++++++++++------------------
 1 file changed, 18 insertions(+), 18 deletions(-)

diff --git a/net/netfilter/nft_hash.c b/net/netfilter/nft_hash.c
index eb2721af898d..ccb834ef049b 100644
--- a/net/netfilter/nft_hash.c
+++ b/net/netfilter/nft_hash.c
@@ -17,7 +17,7 @@
 #include <net/netfilter/nf_tables_core.h>
 #include <linux/jhash.h>
 
-struct nft_hash {
+struct nft_jhash {
 	enum nft_registers      sreg:8;
 	enum nft_registers      dreg:8;
 	u8			len;
@@ -26,11 +26,11 @@ struct nft_hash {
 	u32			offset;
 };
 
-static void nft_hash_eval(const struct nft_expr *expr,
-			  struct nft_regs *regs,
-			  const struct nft_pktinfo *pkt)
+static void nft_jhash_eval(const struct nft_expr *expr,
+			   struct nft_regs *regs,
+			   const struct nft_pktinfo *pkt)
 {
-	struct nft_hash *priv = nft_expr_priv(expr);
+	struct nft_jhash *priv = nft_expr_priv(expr);
 	const void *data = &regs->data[priv->sreg];
 	u32 h;
 
@@ -47,11 +47,11 @@ static const struct nla_policy nft_hash_policy[NFTA_HASH_MAX + 1] = {
 	[NFTA_HASH_OFFSET]	= { .type = NLA_U32 },
 };
 
-static int nft_hash_init(const struct nft_ctx *ctx,
-			 const struct nft_expr *expr,
-			 const struct nlattr * const tb[])
+static int nft_jhash_init(const struct nft_ctx *ctx,
+			  const struct nft_expr *expr,
+			  const struct nlattr * const tb[])
 {
-	struct nft_hash *priv = nft_expr_priv(expr);
+	struct nft_jhash *priv = nft_expr_priv(expr);
 	u32 len;
 	int err;
 
@@ -92,10 +92,10 @@ static int nft_hash_init(const struct nft_ctx *ctx,
 					   NFT_DATA_VALUE, sizeof(u32));
 }
 
-static int nft_hash_dump(struct sk_buff *skb,
-			 const struct nft_expr *expr)
+static int nft_jhash_dump(struct sk_buff *skb,
+			  const struct nft_expr *expr)
 {
-	const struct nft_hash *priv = nft_expr_priv(expr);
+	const struct nft_jhash *priv = nft_expr_priv(expr);
 
 	if (nft_dump_register(skb, NFTA_HASH_SREG, priv->sreg))
 		goto nla_put_failure;
@@ -117,17 +117,17 @@ static int nft_hash_dump(struct sk_buff *skb,
 }
 
 static struct nft_expr_type nft_hash_type;
-static const struct nft_expr_ops nft_hash_ops = {
+static const struct nft_expr_ops nft_jhash_ops = {
 	.type		= &nft_hash_type,
-	.size		= NFT_EXPR_SIZE(sizeof(struct nft_hash)),
-	.eval		= nft_hash_eval,
-	.init		= nft_hash_init,
-	.dump		= nft_hash_dump,
+	.size		= NFT_EXPR_SIZE(sizeof(struct nft_jhash)),
+	.eval		= nft_jhash_eval,
+	.init		= nft_jhash_init,
+	.dump		= nft_jhash_dump,
 };
 
 static struct nft_expr_type nft_hash_type __read_mostly = {
 	.name		= "hash",
-	.ops		= &nft_hash_ops,
+	.ops		= &nft_jhash_ops,
 	.policy		= nft_hash_policy,
 	.maxattr	= NFTA_HASH_MAX,
 	.owner		= THIS_MODULE,
-- 
2.1.4

