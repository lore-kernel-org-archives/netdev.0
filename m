From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 18/21] netfilter: nf_tables: mark stateful expressions
Date: Mon, 13 Apr 2015 21:29:57 +0200
Message-ID: <1428953401-4838-19-git-send-email-pablo@netfilter.org>
References: <1428953401-4838-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1428953401-4838-1-git-send-email-pablo@netfilter.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Patrick McHardy <kaber@trash.net>

Add a flag to mark stateful expressions.

This is used for dynamic expression instanstiation to limit the usable
expressions. Strictly speaking only the dynset expression can not be
used in order to avoid recursion, but since dynamically instantiating
non-stateful expressions will simply create an identical copy, which
behaves no differently than the original, this limits to expressions
where it actually makes sense to dynamically instantiate them.

Signed-off-by: Patrick McHardy <kaber@trash.net>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 include/net/netfilter/nf_tables.h |    4 ++++
 net/netfilter/nft_counter.c       |    1 +
 net/netfilter/nft_limit.c         |    1 +
 3 files changed, 6 insertions(+)

diff --git a/include/net/netfilter/nf_tables.h b/include/net/netfilter/nf_tables.h
index d45a871..e6bcf55 100644
--- a/include/net/netfilter/nf_tables.h
+++ b/include/net/netfilter/nf_tables.h
@@ -583,6 +583,7 @@ static inline void nft_set_gc_batch_add(struct nft_set_gc_batch *gcb,
  *	@policy: netlink attribute policy
  *	@maxattr: highest netlink attribute number
  *	@family: address family for AF-specific types
+ *	@flags: expression type flags
  */
 struct nft_expr_type {
 	const struct nft_expr_ops	*(*select_ops)(const struct nft_ctx *,
@@ -594,8 +595,11 @@ struct nft_expr_type {
 	const struct nla_policy		*policy;
 	unsigned int			maxattr;
 	u8				family;
+	u8				flags;
 };
 
+#define NFT_EXPR_STATEFUL		0x1
+
 /**
  *	struct nft_expr_ops - nf_tables expression operations
  *
diff --git a/net/netfilter/nft_counter.c b/net/netfilter/nft_counter.c
index 0f6367e..1759123 100644
--- a/net/netfilter/nft_counter.c
+++ b/net/netfilter/nft_counter.c
@@ -92,6 +92,7 @@ static struct nft_expr_type nft_counter_type __read_mostly = {
 	.ops		= &nft_counter_ops,
 	.policy		= nft_counter_policy,
 	.maxattr	= NFTA_COUNTER_MAX,
+	.flags		= NFT_EXPR_STATEFUL,
 	.owner		= THIS_MODULE,
 };
 
diff --git a/net/netfilter/nft_limit.c b/net/netfilter/nft_limit.c
index c862045..435c1cc 100644
--- a/net/netfilter/nft_limit.c
+++ b/net/netfilter/nft_limit.c
@@ -98,6 +98,7 @@ static struct nft_expr_type nft_limit_type __read_mostly = {
 	.ops		= &nft_limit_ops,
 	.policy		= nft_limit_policy,
 	.maxattr	= NFTA_LIMIT_MAX,
+	.flags		= NFT_EXPR_STATEFUL,
 	.owner		= THIS_MODULE,
 };
 
-- 
1.7.10.4

