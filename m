From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 5/7] netfilter: nft_nat: insufficient attribute validation
Date: Mon, 20 Oct 2014 10:10:37 +0200
Message-ID: <1413792639-3954-6-git-send-email-pablo@netfilter.org>
References: <1413792639-3954-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1413792639-3954-1-git-send-email-pablo@netfilter.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

We have to validate that we at least get an NFTA_NAT_REG_ADDR_MIN or
NFTA_NFT_REG_PROTO_MIN attribute. Reject the configuration if none
of them are present.

Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 net/netfilter/nft_nat.c |    4 +++-
 1 file changed, 3 insertions(+), 1 deletion(-)

diff --git a/net/netfilter/nft_nat.c b/net/netfilter/nft_nat.c
index 0f0af6e..5078f1f 100644
--- a/net/netfilter/nft_nat.c
+++ b/net/netfilter/nft_nat.c
@@ -99,7 +99,9 @@ static int nft_nat_init(const struct nft_ctx *ctx, const struct nft_expr *expr,
 	if (err < 0)
 		return err;
 
-	if (tb[NFTA_NAT_TYPE] == NULL)
+	if (tb[NFTA_NAT_TYPE] == NULL ||
+	    (tb[NFTA_NAT_REG_ADDR_MIN] == NULL &&
+	     tb[NFTA_NAT_REG_PROTO_MIN] == NULL))
 		return -EINVAL;
 
 	switch (ntohl(nla_get_be32(tb[NFTA_NAT_TYPE]))) {
-- 
1.7.10.4

