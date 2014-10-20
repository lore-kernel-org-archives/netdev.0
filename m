From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 7/7] netfilter: nft_nat: dump attributes if they are set
Date: Mon, 20 Oct 2014 10:10:39 +0200
Message-ID: <1413792639-3954-8-git-send-email-pablo@netfilter.org>
References: <1413792639-3954-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1413792639-3954-1-git-send-email-pablo@netfilter.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Dump NFTA_NAT_REG_ADDR_MIN if this is non-zero. Same thing with
NFTA_NAT_REG_PROTO_MIN.

Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 net/netfilter/nft_nat.c |   20 +++++++++++---------
 1 file changed, 11 insertions(+), 9 deletions(-)

diff --git a/net/netfilter/nft_nat.c b/net/netfilter/nft_nat.c
index a95e0c1..afe2b0b 100644
--- a/net/netfilter/nft_nat.c
+++ b/net/netfilter/nft_nat.c
@@ -191,17 +191,19 @@ static int nft_nat_dump(struct sk_buff *skb, const struct nft_expr *expr)
 
 	if (nla_put_be32(skb, NFTA_NAT_FAMILY, htonl(priv->family)))
 		goto nla_put_failure;
-	if (nla_put_be32(skb,
-			 NFTA_NAT_REG_ADDR_MIN, htonl(priv->sreg_addr_min)))
-		goto nla_put_failure;
-	if (nla_put_be32(skb,
-			 NFTA_NAT_REG_ADDR_MAX, htonl(priv->sreg_addr_max)))
-		goto nla_put_failure;
+
+	if (priv->sreg_addr_min) {
+		if (nla_put_be32(skb, NFTA_NAT_REG_ADDR_MIN,
+				 htonl(priv->sreg_addr_min)) ||
+		    nla_put_be32(skb, NFTA_NAT_REG_ADDR_MAX,
+				 htonl(priv->sreg_addr_max)))
+			goto nla_put_failure;
+	}
+
 	if (priv->sreg_proto_min) {
 		if (nla_put_be32(skb, NFTA_NAT_REG_PROTO_MIN,
-				 htonl(priv->sreg_proto_min)))
-			goto nla_put_failure;
-		if (nla_put_be32(skb, NFTA_NAT_REG_PROTO_MAX,
+				 htonl(priv->sreg_proto_min)) ||
+		    nla_put_be32(skb, NFTA_NAT_REG_PROTO_MAX,
 				 htonl(priv->sreg_proto_max)))
 			goto nla_put_failure;
 	}
-- 
1.7.10.4

