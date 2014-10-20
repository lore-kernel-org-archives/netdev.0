From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 3/7] netfilter: nft_compat: fix hook validation for non-base chains
Date: Mon, 20 Oct 2014 10:10:35 +0200
Message-ID: <1413792639-3954-4-git-send-email-pablo@netfilter.org>
References: <1413792639-3954-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:40031 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751493AbaJTIJR (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 20 Oct 2014 04:09:17 -0400
In-Reply-To: <1413792639-3954-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Set hook_mask to zero for non-base chains, otherwise people may hit
bogus errors from the xt_check_target() and xt_check_match() when
validating the uninitialized hook_mask.

Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 net/netfilter/nft_compat.c |    4 ++++
 1 file changed, 4 insertions(+)

diff --git a/net/netfilter/nft_compat.c b/net/netfilter/nft_compat.c
index 7e2683c..44ae273 100644
--- a/net/netfilter/nft_compat.c
+++ b/net/netfilter/nft_compat.c
@@ -95,6 +95,8 @@ nft_target_set_tgchk_param(struct xt_tgchk_param *par,
 		const struct nf_hook_ops *ops = &basechain->ops[0];
 
 		par->hook_mask = 1 << ops->hooknum;
+	} else {
+		par->hook_mask = 0;
 	}
 	par->family	= ctx->afi->family;
 }
@@ -293,6 +295,8 @@ nft_match_set_mtchk_param(struct xt_mtchk_param *par, const struct nft_ctx *ctx,
 		const struct nf_hook_ops *ops = &basechain->ops[0];
 
 		par->hook_mask = 1 << ops->hooknum;
+	} else {
+		par->hook_mask = 0;
 	}
 	par->family	= ctx->afi->family;
 }
-- 
1.7.10.4
