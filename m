From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 09/10] Revert "netfilter: nf_tables: add flush field to struct nft_set_iter"
Date: Wed, 15 Mar 2017 18:01:11 +0100
Message-ID: <1489597272-30347-10-git-send-email-pablo@netfilter.org>
References: <1489597272-30347-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1489597272-30347-1-git-send-email-pablo@netfilter.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This reverts commit 1f48ff6c5393aa7fe290faf5d633164f105b0aa7.

This patch is not required anymore now that we keep a dummy list of
set elements in the bitmap set implementation, so revert this before
we forget this code has no clients.

Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 include/net/netfilter/nf_tables.h | 1 -
 net/netfilter/nf_tables_api.c     | 4 ----
 2 files changed, 5 deletions(-)

diff --git a/include/net/netfilter/nf_tables.h b/include/net/netfilter/nf_tables.h
index 70c5ca0c60b1..0136028652bd 100644
--- a/include/net/netfilter/nf_tables.h
+++ b/include/net/netfilter/nf_tables.h
@@ -232,7 +232,6 @@ struct nft_set_elem {
 struct nft_set;
 struct nft_set_iter {
 	u8		genmask;
-	bool		flush;
 	unsigned int	count;
 	unsigned int	skip;
 	int		err;
diff --git a/net/netfilter/nf_tables_api.c b/net/netfilter/nf_tables_api.c
index 5e0ccfd5bb37..434c739dfeca 100644
--- a/net/netfilter/nf_tables_api.c
+++ b/net/netfilter/nf_tables_api.c
@@ -3145,7 +3145,6 @@ int nf_tables_bind_set(const struct nft_ctx *ctx, struct nft_set *set,
 		iter.count	= 0;
 		iter.err	= 0;
 		iter.fn		= nf_tables_bind_check_setelem;
-		iter.flush	= false;
 
 		set->ops->walk(ctx, set, &iter);
 		if (iter.err < 0)
@@ -3399,7 +3398,6 @@ static int nf_tables_dump_set(struct sk_buff *skb, struct netlink_callback *cb)
 	args.iter.count		= 0;
 	args.iter.err		= 0;
 	args.iter.fn		= nf_tables_dump_setelem;
-	args.iter.flush		= false;
 	set->ops->walk(&ctx, set, &args.iter);
 
 	nla_nest_end(skb, nest);
@@ -3963,7 +3961,6 @@ static int nf_tables_delsetelem(struct net *net, struct sock *nlsk,
 		struct nft_set_iter iter = {
 			.genmask	= genmask,
 			.fn		= nft_flush_set,
-			.flush		= true,
 		};
 		set->ops->walk(&ctx, set, &iter);
 
@@ -5114,7 +5111,6 @@ static int nf_tables_check_loops(const struct nft_ctx *ctx,
 			iter.count	= 0;
 			iter.err	= 0;
 			iter.fn		= nf_tables_loop_check_setelem;
-			iter.flush	= false;
 
 			set->ops->walk(ctx, set, &iter);
 			if (iter.err < 0)
-- 
2.1.4

