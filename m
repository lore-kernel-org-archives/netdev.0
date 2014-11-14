From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 4/8] netfilter: nft_compat: use current net namespace
Date: Fri, 14 Nov 2014 17:58:45 +0100
Message-ID: <1415984329-5569-6-git-send-email-pablo@netfilter.org>
References: <1415984329-5569-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1415984329-5569-1-git-send-email-pablo@netfilter.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Instead of init_net when using xtables over nftables compat.

Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 net/netfilter/nft_compat.c |    4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/netfilter/nft_compat.c b/net/netfilter/nft_compat.c
index 9d6d6f6..b92f129 100644
--- a/net/netfilter/nft_compat.c
+++ b/net/netfilter/nft_compat.c
@@ -117,7 +117,7 @@ nft_target_set_tgchk_param(struct xt_tgchk_param *par,
 			   struct xt_target *target, void *info,
 			   union nft_entry *entry, u8 proto, bool inv)
 {
-	par->net	= &init_net;
+	par->net	= ctx->net;
 	par->table	= ctx->table->name;
 	switch (ctx->afi->family) {
 	case AF_INET:
@@ -324,7 +324,7 @@ nft_match_set_mtchk_param(struct xt_mtchk_param *par, const struct nft_ctx *ctx,
 			  struct xt_match *match, void *info,
 			  union nft_entry *entry, u8 proto, bool inv)
 {
-	par->net	= &init_net;
+	par->net	= ctx->net;
 	par->table	= ctx->table->name;
 	switch (ctx->afi->family) {
 	case AF_INET:
-- 
1.7.10.4

