From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 03/12] netfilter: nft_limit: replace pkt_bytes with bytes
Date: Mon,  4 Sep 2017 22:11:05 +0200
Message-ID: <1504555874-4168-4-git-send-email-pablo@netfilter.org>
References: <1504555874-4168-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1504555874-4168-1-git-send-email-pablo@netfilter.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: "Pablo M. Bermudo Garay" <pablombg@gmail.com>

Just a small refactor patch in order to improve the code readability.

Signed-off-by: Pablo M. Bermudo Garay <pablombg@gmail.com>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 net/netfilter/nft_limit.c | 26 +++++++++++++-------------
 1 file changed, 13 insertions(+), 13 deletions(-)

diff --git a/net/netfilter/nft_limit.c b/net/netfilter/nft_limit.c
index 14538b1d4d11..aae2d1ec27f3 100644
--- a/net/netfilter/nft_limit.c
+++ b/net/netfilter/nft_limit.c
@@ -168,9 +168,9 @@ static const struct nft_expr_ops nft_limit_pkts_ops = {
 	.dump		= nft_limit_pkts_dump,
 };
 
-static void nft_limit_pkt_bytes_eval(const struct nft_expr *expr,
-				     struct nft_regs *regs,
-				     const struct nft_pktinfo *pkt)
+static void nft_limit_bytes_eval(const struct nft_expr *expr,
+				 struct nft_regs *regs,
+				 const struct nft_pktinfo *pkt)
 {
 	struct nft_limit *priv = nft_expr_priv(expr);
 	u64 cost = div64_u64(priv->nsecs * pkt->skb->len, priv->rate);
@@ -179,29 +179,29 @@ static void nft_limit_pkt_bytes_eval(const struct nft_expr *expr,
 		regs->verdict.code = NFT_BREAK;
 }
 
-static int nft_limit_pkt_bytes_init(const struct nft_ctx *ctx,
-				    const struct nft_expr *expr,
-				    const struct nlattr * const tb[])
+static int nft_limit_bytes_init(const struct nft_ctx *ctx,
+				const struct nft_expr *expr,
+				const struct nlattr * const tb[])
 {
 	struct nft_limit *priv = nft_expr_priv(expr);
 
 	return nft_limit_init(priv, tb);
 }
 
-static int nft_limit_pkt_bytes_dump(struct sk_buff *skb,
-				    const struct nft_expr *expr)
+static int nft_limit_bytes_dump(struct sk_buff *skb,
+				const struct nft_expr *expr)
 {
 	const struct nft_limit *priv = nft_expr_priv(expr);
 
 	return nft_limit_dump(skb, priv, NFT_LIMIT_PKT_BYTES);
 }
 
-static const struct nft_expr_ops nft_limit_pkt_bytes_ops = {
+static const struct nft_expr_ops nft_limit_bytes_ops = {
 	.type		= &nft_limit_type,
 	.size		= NFT_EXPR_SIZE(sizeof(struct nft_limit)),
-	.eval		= nft_limit_pkt_bytes_eval,
-	.init		= nft_limit_pkt_bytes_init,
-	.dump		= nft_limit_pkt_bytes_dump,
+	.eval		= nft_limit_bytes_eval,
+	.init		= nft_limit_bytes_init,
+	.dump		= nft_limit_bytes_dump,
 };
 
 static const struct nft_expr_ops *
@@ -215,7 +215,7 @@ nft_limit_select_ops(const struct nft_ctx *ctx,
 	case NFT_LIMIT_PKTS:
 		return &nft_limit_pkts_ops;
 	case NFT_LIMIT_PKT_BYTES:
-		return &nft_limit_pkt_bytes_ops;
+		return &nft_limit_bytes_ops;
 	}
 	return ERR_PTR(-EOPNOTSUPP);
 }
-- 
2.1.4

