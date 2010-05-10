From: kaber@trash.net
Subject: [PATCH 51/84] netfilter: xtables: merge registration structure to NFPROTO_UNSPEC
Date: Mon, 10 May 2010 22:18:22 +0200
Message-ID: <1273522735-24672-52-git-send-email-kaber@trash.net>
References: <1273522735-24672-1-git-send-email-kaber@trash.net>
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1273522735-24672-1-git-send-email-kaber@trash.net>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Jan Engelhardt <jengelh@medozas.de>

Signed-off-by: Jan Engelhardt <jengelh@medozas.de>
---
 net/netfilter/xt_state.c |   31 ++++++++++---------------------
 1 files changed, 10 insertions(+), 21 deletions(-)

diff --git a/net/netfilter/xt_state.c b/net/netfilter/xt_state.c
index be00d7b..bb12718 100644
--- a/net/netfilter/xt_state.c
+++ b/net/netfilter/xt_state.c
@@ -53,35 +53,24 @@ static void state_mt_destroy(const struct xt_mtdtor_param *par)
 	nf_ct_l3proto_module_put(par->family);
 }
 
-static struct xt_match state_mt_reg[] __read_mostly = {
-	{
-		.name		= "state",
-		.family		= NFPROTO_IPV4,
-		.checkentry	= state_mt_check,
-		.match		= state_mt,
-		.destroy	= state_mt_destroy,
-		.matchsize	= sizeof(struct xt_state_info),
-		.me		= THIS_MODULE,
-	},
-	{
-		.name		= "state",
-		.family		= NFPROTO_IPV6,
-		.checkentry	= state_mt_check,
-		.match		= state_mt,
-		.destroy	= state_mt_destroy,
-		.matchsize	= sizeof(struct xt_state_info),
-		.me		= THIS_MODULE,
-	},
+static struct xt_match state_mt_reg __read_mostly = {
+	.name       = "state",
+	.family     = NFPROTO_UNSPEC,
+	.checkentry = state_mt_check,
+	.match      = state_mt,
+	.destroy    = state_mt_destroy,
+	.matchsize  = sizeof(struct xt_state_info),
+	.me         = THIS_MODULE,
 };
 
 static int __init state_mt_init(void)
 {
-	return xt_register_matches(state_mt_reg, ARRAY_SIZE(state_mt_reg));
+	return xt_register_match(&state_mt_reg);
 }
 
 static void __exit state_mt_exit(void)
 {
-	xt_unregister_matches(state_mt_reg, ARRAY_SIZE(state_mt_reg));
+	xt_unregister_match(&state_mt_reg);
 }
 
 module_init(state_mt_init);
-- 
1.7.0.4

