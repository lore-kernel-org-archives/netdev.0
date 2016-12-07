From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 16/50] netfilter: nf_tables: add conntrack dependencies for nat/masq/redir expressions
Date: Wed,  7 Dec 2016 22:52:22 +0100
Message-ID: <1481147576-5690-17-git-send-email-pablo@netfilter.org>
References: <1481147576-5690-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:60210 "EHLO mail.us.es"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S932423AbcLGVxj (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 7 Dec 2016 16:53:39 -0500
Received: from antivirus1-rhel7.int (unknown [192.168.2.11])
        by mail.us.es (Postfix) with ESMTP id BF936C1062
        for <netdev@vger.kernel.org>; Wed,  7 Dec 2016 22:53:32 +0100 (CET)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
        by antivirus1-rhel7.int (Postfix) with ESMTP id AD8FADA865
        for <netdev@vger.kernel.org>; Wed,  7 Dec 2016 22:53:32 +0100 (CET)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
        by antivirus1-rhel7.int (Postfix) with ESMTP id 75192DA853
        for <netdev@vger.kernel.org>; Wed,  7 Dec 2016 22:53:30 +0100 (CET)
In-Reply-To: <1481147576-5690-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Florian Westphal <fw@strlen.de>

so that conntrack core will add the needed hooks in this namespace.

Signed-off-by: Florian Westphal <fw@strlen.de>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 net/ipv4/netfilter/nft_masq_ipv4.c  |  7 +++++++
 net/ipv4/netfilter/nft_redir_ipv4.c |  7 +++++++
 net/ipv6/netfilter/nft_masq_ipv6.c  |  7 +++++++
 net/ipv6/netfilter/nft_redir_ipv6.c |  7 +++++++
 net/netfilter/nft_masq.c            |  2 +-
 net/netfilter/nft_nat.c             | 11 ++++++++++-
 net/netfilter/nft_redir.c           |  2 +-
 7 files changed, 40 insertions(+), 3 deletions(-)

diff --git a/net/ipv4/netfilter/nft_masq_ipv4.c b/net/ipv4/netfilter/nft_masq_ipv4.c
index 4d69f99b8707..a0ea8aad1bf1 100644
--- a/net/ipv4/netfilter/nft_masq_ipv4.c
+++ b/net/ipv4/netfilter/nft_masq_ipv4.c
@@ -35,12 +35,19 @@ static void nft_masq_ipv4_eval(const struct nft_expr *expr,
 						    &range, nft_out(pkt));
 }
 
+static void
+nft_masq_ipv4_destroy(const struct nft_ctx *ctx, const struct nft_expr *expr)
+{
+	nf_ct_netns_put(ctx->net, NFPROTO_IPV4);
+}
+
 static struct nft_expr_type nft_masq_ipv4_type;
 static const struct nft_expr_ops nft_masq_ipv4_ops = {
 	.type		= &nft_masq_ipv4_type,
 	.size		= NFT_EXPR_SIZE(sizeof(struct nft_masq)),
 	.eval		= nft_masq_ipv4_eval,
 	.init		= nft_masq_init,
+	.destroy	= nft_masq_ipv4_destroy,
 	.dump		= nft_masq_dump,
 	.validate	= nft_masq_validate,
 };
diff --git a/net/ipv4/netfilter/nft_redir_ipv4.c b/net/ipv4/netfilter/nft_redir_ipv4.c
index 62c18e68ac58..1650ed23c15d 100644
--- a/net/ipv4/netfilter/nft_redir_ipv4.c
+++ b/net/ipv4/netfilter/nft_redir_ipv4.c
@@ -38,12 +38,19 @@ static void nft_redir_ipv4_eval(const struct nft_expr *expr,
 	regs->verdict.code = nf_nat_redirect_ipv4(pkt->skb, &mr, nft_hook(pkt));
 }
 
+static void
+nft_redir_ipv4_destroy(const struct nft_ctx *ctx, const struct nft_expr *expr)
+{
+	nf_ct_netns_put(ctx->net, NFPROTO_IPV4);
+}
+
 static struct nft_expr_type nft_redir_ipv4_type;
 static const struct nft_expr_ops nft_redir_ipv4_ops = {
 	.type		= &nft_redir_ipv4_type,
 	.size		= NFT_EXPR_SIZE(sizeof(struct nft_redir)),
 	.eval		= nft_redir_ipv4_eval,
 	.init		= nft_redir_init,
+	.destroy	= nft_redir_ipv4_destroy,
 	.dump		= nft_redir_dump,
 	.validate	= nft_redir_validate,
 };
diff --git a/net/ipv6/netfilter/nft_masq_ipv6.c b/net/ipv6/netfilter/nft_masq_ipv6.c
index 93d758f70334..6c5b5b1830a7 100644
--- a/net/ipv6/netfilter/nft_masq_ipv6.c
+++ b/net/ipv6/netfilter/nft_masq_ipv6.c
@@ -36,12 +36,19 @@ static void nft_masq_ipv6_eval(const struct nft_expr *expr,
 						    nft_out(pkt));
 }
 
+static void
+nft_masq_ipv6_destroy(const struct nft_ctx *ctx, const struct nft_expr *expr)
+{
+	nf_ct_netns_put(ctx->net, NFPROTO_IPV6);
+}
+
 static struct nft_expr_type nft_masq_ipv6_type;
 static const struct nft_expr_ops nft_masq_ipv6_ops = {
 	.type		= &nft_masq_ipv6_type,
 	.size		= NFT_EXPR_SIZE(sizeof(struct nft_masq)),
 	.eval		= nft_masq_ipv6_eval,
 	.init		= nft_masq_init,
+	.destroy	= nft_masq_ipv6_destroy,
 	.dump		= nft_masq_dump,
 	.validate	= nft_masq_validate,
 };
diff --git a/net/ipv6/netfilter/nft_redir_ipv6.c b/net/ipv6/netfilter/nft_redir_ipv6.c
index 2850fcd8583f..f5ac080fc084 100644
--- a/net/ipv6/netfilter/nft_redir_ipv6.c
+++ b/net/ipv6/netfilter/nft_redir_ipv6.c
@@ -39,12 +39,19 @@ static void nft_redir_ipv6_eval(const struct nft_expr *expr,
 		nf_nat_redirect_ipv6(pkt->skb, &range, nft_hook(pkt));
 }
 
+static void
+nft_redir_ipv6_destroy(const struct nft_ctx *ctx, const struct nft_expr *expr)
+{
+	nf_ct_netns_put(ctx->net, NFPROTO_IPV6);
+}
+
 static struct nft_expr_type nft_redir_ipv6_type;
 static const struct nft_expr_ops nft_redir_ipv6_ops = {
 	.type		= &nft_redir_ipv6_type,
 	.size		= NFT_EXPR_SIZE(sizeof(struct nft_redir)),
 	.eval		= nft_redir_ipv6_eval,
 	.init		= nft_redir_init,
+	.destroy	= nft_redir_ipv6_destroy,
 	.dump		= nft_redir_dump,
 	.validate	= nft_redir_validate,
 };
diff --git a/net/netfilter/nft_masq.c b/net/netfilter/nft_masq.c
index bf92de01410f..11ce016cd479 100644
--- a/net/netfilter/nft_masq.c
+++ b/net/netfilter/nft_masq.c
@@ -77,7 +77,7 @@ int nft_masq_init(const struct nft_ctx *ctx,
 		}
 	}
 
-	return 0;
+	return nf_ct_netns_get(ctx->net, ctx->afi->family);
 }
 EXPORT_SYMBOL_GPL(nft_masq_init);
 
diff --git a/net/netfilter/nft_nat.c b/net/netfilter/nft_nat.c
index ee2d71753746..19a7bf3236f9 100644
--- a/net/netfilter/nft_nat.c
+++ b/net/netfilter/nft_nat.c
@@ -209,7 +209,7 @@ static int nft_nat_init(const struct nft_ctx *ctx, const struct nft_expr *expr,
 			return -EINVAL;
 	}
 
-	return 0;
+	return nf_ct_netns_get(ctx->net, family);
 }
 
 static int nft_nat_dump(struct sk_buff *skb, const struct nft_expr *expr)
@@ -257,12 +257,21 @@ static int nft_nat_dump(struct sk_buff *skb, const struct nft_expr *expr)
 	return -1;
 }
 
+static void
+nft_nat_destroy(const struct nft_ctx *ctx, const struct nft_expr *expr)
+{
+	const struct nft_nat *priv = nft_expr_priv(expr);
+
+	nf_ct_netns_put(ctx->net, priv->family);
+}
+
 static struct nft_expr_type nft_nat_type;
 static const struct nft_expr_ops nft_nat_ops = {
 	.type           = &nft_nat_type,
 	.size           = NFT_EXPR_SIZE(sizeof(struct nft_nat)),
 	.eval           = nft_nat_eval,
 	.init           = nft_nat_init,
+	.destroy        = nft_nat_destroy,
 	.dump           = nft_nat_dump,
 	.validate	= nft_nat_validate,
 };
diff --git a/net/netfilter/nft_redir.c b/net/netfilter/nft_redir.c
index 967e09b099b2..40dcd05146d5 100644
--- a/net/netfilter/nft_redir.c
+++ b/net/netfilter/nft_redir.c
@@ -79,7 +79,7 @@ int nft_redir_init(const struct nft_ctx *ctx,
 			return -EINVAL;
 	}
 
-	return 0;
+	return nf_ct_netns_get(ctx->net, ctx->afi->family);
 }
 EXPORT_SYMBOL_GPL(nft_redir_init);
 
-- 
2.1.4
