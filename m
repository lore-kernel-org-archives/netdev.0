From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 6/7] netfilter: nft_nat: NFTA_NAT_REG_ADDR_MAX depends on NFTA_NAT_REG_ADDR_MIN
Date: Mon, 20 Oct 2014 10:10:38 +0200
Message-ID: <1413792639-3954-7-git-send-email-pablo@netfilter.org>
References: <1413792639-3954-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1413792639-3954-1-git-send-email-pablo@netfilter.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Interpret NFTA_NAT_REG_ADDR_MAX if NFTA_NAT_REG_ADDR_MIN is present,
otherwise, skip it. Same thing with NFTA_NAT_REG_PROTO_MAX.

Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 net/netfilter/nft_nat.c |   50 ++++++++++++++++++++++++++---------------------
 1 file changed, 28 insertions(+), 22 deletions(-)

diff --git a/net/netfilter/nft_nat.c b/net/netfilter/nft_nat.c
index 5078f1f..a95e0c1 100644
--- a/net/netfilter/nft_nat.c
+++ b/net/netfilter/nft_nat.c
@@ -126,38 +126,44 @@ static int nft_nat_init(const struct nft_ctx *ctx, const struct nft_expr *expr,
 	priv->family = family;
 
 	if (tb[NFTA_NAT_REG_ADDR_MIN]) {
-		priv->sreg_addr_min = ntohl(nla_get_be32(
-						tb[NFTA_NAT_REG_ADDR_MIN]));
+		priv->sreg_addr_min =
+			ntohl(nla_get_be32(tb[NFTA_NAT_REG_ADDR_MIN]));
+
 		err = nft_validate_input_register(priv->sreg_addr_min);
 		if (err < 0)
 			return err;
-	}
 
-	if (tb[NFTA_NAT_REG_ADDR_MAX]) {
-		priv->sreg_addr_max = ntohl(nla_get_be32(
-						tb[NFTA_NAT_REG_ADDR_MAX]));
-		err = nft_validate_input_register(priv->sreg_addr_max);
-		if (err < 0)
-			return err;
-	} else
-		priv->sreg_addr_max = priv->sreg_addr_min;
+		if (tb[NFTA_NAT_REG_ADDR_MAX]) {
+			priv->sreg_addr_max =
+				ntohl(nla_get_be32(tb[NFTA_NAT_REG_ADDR_MAX]));
+
+			err = nft_validate_input_register(priv->sreg_addr_max);
+			if (err < 0)
+				return err;
+		} else {
+			priv->sreg_addr_max = priv->sreg_addr_min;
+		}
+	}
 
 	if (tb[NFTA_NAT_REG_PROTO_MIN]) {
-		priv->sreg_proto_min = ntohl(nla_get_be32(
-						tb[NFTA_NAT_REG_PROTO_MIN]));
+		priv->sreg_proto_min =
+			ntohl(nla_get_be32(tb[NFTA_NAT_REG_PROTO_MIN]));
+
 		err = nft_validate_input_register(priv->sreg_proto_min);
 		if (err < 0)
 			return err;
-	}
 
-	if (tb[NFTA_NAT_REG_PROTO_MAX]) {
-		priv->sreg_proto_max = ntohl(nla_get_be32(
-						tb[NFTA_NAT_REG_PROTO_MAX]));
-		err = nft_validate_input_register(priv->sreg_proto_max);
-		if (err < 0)
-			return err;
-	} else
-		priv->sreg_proto_max = priv->sreg_proto_min;
+		if (tb[NFTA_NAT_REG_PROTO_MAX]) {
+			priv->sreg_proto_max =
+				ntohl(nla_get_be32(tb[NFTA_NAT_REG_PROTO_MAX]));
+
+			err = nft_validate_input_register(priv->sreg_proto_max);
+			if (err < 0)
+				return err;
+		} else {
+			priv->sreg_proto_max = priv->sreg_proto_min;
+		}
+	}
 
 	if (tb[NFTA_NAT_FLAGS]) {
 		priv->flags = ntohl(nla_get_be32(tb[NFTA_NAT_FLAGS]));
-- 
1.7.10.4

