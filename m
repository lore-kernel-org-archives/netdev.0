From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 6/8] netfilter: nft_compat: use the match->table to validate dependencies
Date: Fri, 14 Nov 2014 17:58:47 +0100
Message-ID: <1415984329-5569-8-git-send-email-pablo@netfilter.org>
References: <1415984329-5569-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1415984329-5569-1-git-send-email-pablo@netfilter.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Instead of the match->name, which is of course not relevant.

Fixes: f3f5dde ("netfilter: nft_compat: validate chain type in match/target")
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 net/netfilter/nft_compat.c |    4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/netfilter/nft_compat.c b/net/netfilter/nft_compat.c
index 70dc965..265e190 100644
--- a/net/netfilter/nft_compat.c
+++ b/net/netfilter/nft_compat.c
@@ -346,7 +346,7 @@ nft_match_init(const struct nft_ctx *ctx, const struct nft_expr *expr,
 	union nft_entry e = {};
 	int ret;
 
-	ret = nft_compat_chain_validate_dependency(match->name, ctx->chain);
+	ret = nft_compat_chain_validate_dependency(match->table, ctx->chain);
 	if (ret < 0)
 		goto err;
 
@@ -420,7 +420,7 @@ static int nft_match_validate(const struct nft_ctx *ctx,
 		if (!(hook_mask & match->hooks))
 			return -EINVAL;
 
-		ret = nft_compat_chain_validate_dependency(match->name,
+		ret = nft_compat_chain_validate_dependency(match->table,
 							   ctx->chain);
 		if (ret < 0)
 			return ret;
-- 
1.7.10.4

