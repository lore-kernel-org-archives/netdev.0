From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 2/5] netfilter: nft_compat: check extension hook mask only if set
Date: Thu, 24 Aug 2017 16:43:28 +0200
Message-ID: <1503585811-13447-3-git-send-email-pablo@netfilter.org>
References: <1503585811-13447-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1503585811-13447-1-git-send-email-pablo@netfilter.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

If the x_tables extension comes with no hook mask, skip this validation.

Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 net/netfilter/nft_compat.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/netfilter/nft_compat.c b/net/netfilter/nft_compat.c
index f5a7cb68694e..b89f4f65b2a0 100644
--- a/net/netfilter/nft_compat.c
+++ b/net/netfilter/nft_compat.c
@@ -305,7 +305,7 @@ static int nft_target_validate(const struct nft_ctx *ctx,
 		const struct nf_hook_ops *ops = &basechain->ops[0];
 
 		hook_mask = 1 << ops->hooknum;
-		if (!(hook_mask & target->hooks))
+		if (target->hooks && !(hook_mask & target->hooks))
 			return -EINVAL;
 
 		ret = nft_compat_chain_validate_dependency(target->table,
@@ -484,7 +484,7 @@ static int nft_match_validate(const struct nft_ctx *ctx,
 		const struct nf_hook_ops *ops = &basechain->ops[0];
 
 		hook_mask = 1 << ops->hooknum;
-		if (!(hook_mask & match->hooks))
+		if (match->hooks && !(hook_mask & match->hooks))
 			return -EINVAL;
 
 		ret = nft_compat_chain_validate_dependency(match->table,
-- 
2.1.4


