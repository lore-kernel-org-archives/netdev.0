From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 8/8] netfilter: nft_compat: fix wrong target lookup in nft_target_select_ops()
Date: Mon, 27 Oct 2014 22:38:07 +0100
Message-ID: <1414445887-5108-9-git-send-email-pablo@netfilter.org>
References: <1414445887-5108-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1414445887-5108-1-git-send-email-pablo@netfilter.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Arturo Borrero <arturo.borrero.glez@gmail.com>

The code looks for an already loaded target, and the correct list to search
is nft_target_list, not nft_match_list.

Signed-off-by: Arturo Borrero Gonzalez <arturo.borrero.glez@gmail.com>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 net/netfilter/nft_compat.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/netfilter/nft_compat.c b/net/netfilter/nft_compat.c
index 0480f57..9d6d6f6 100644
--- a/net/netfilter/nft_compat.c
+++ b/net/netfilter/nft_compat.c
@@ -672,7 +672,7 @@ nft_target_select_ops(const struct nft_ctx *ctx,
 	family = ctx->afi->family;
 
 	/* Re-use the existing target if it's already loaded. */
-	list_for_each_entry(nft_target, &nft_match_list, head) {
+	list_for_each_entry(nft_target, &nft_target_list, head) {
 		struct xt_target *target = nft_target->ops.data;
 
 		if (strcmp(target->name, tg_name) == 0 &&
-- 
1.7.10.4

