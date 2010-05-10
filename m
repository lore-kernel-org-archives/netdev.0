From: kaber@trash.net
Subject: [PATCH 50/84] netfilter: xtables: remove xt_string revision 0
Date: Mon, 10 May 2010 22:18:21 +0200
Message-ID: <1273522735-24672-51-git-send-email-kaber@trash.net>
References: <1273522735-24672-1-git-send-email-kaber@trash.net>
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1273522735-24672-1-git-send-email-kaber@trash.net>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Jan Engelhardt <jengelh@medozas.de>

Superseded by xt_string revision 1 (linux v2.6.26-rc8-1127-g4ad3f26,
iptables 1.4.2-rc1).

Signed-off-by: Jan Engelhardt <jengelh@medozas.de>
---
 Documentation/Changes     |    2 +-
 net/netfilter/xt_string.c |   53 +++++++++++++++-----------------------------
 2 files changed, 19 insertions(+), 36 deletions(-)

diff --git a/Documentation/Changes b/Documentation/Changes
index f08b313..eca9f6e 100644
--- a/Documentation/Changes
+++ b/Documentation/Changes
@@ -49,7 +49,7 @@ o  oprofile               0.9                     # oprofiled --version
 o  udev                   081                     # udevinfo -V
 o  grub                   0.93                    # grub --version
 o  mcelog		  0.6
-o  iptables               1.4.1                   # iptables -V
+o  iptables               1.4.2                   # iptables -V
 
 
 Kernel compilation
diff --git a/net/netfilter/xt_string.c b/net/netfilter/xt_string.c
index b0f8292..488e368 100644
--- a/net/netfilter/xt_string.c
+++ b/net/netfilter/xt_string.c
@@ -26,12 +26,10 @@ string_mt(const struct sk_buff *skb, const struct xt_match_param *par)
 {
 	const struct xt_string_info *conf = par->matchinfo;
 	struct ts_state state;
-	int invert;
+	bool invert;
 
 	memset(&state, 0, sizeof(struct ts_state));
-
-	invert = (par->match->revision == 0 ? conf->u.v0.invert :
-				    conf->u.v1.flags & XT_STRING_FLAG_INVERT);
+	invert = conf->u.v1.flags & XT_STRING_FLAG_INVERT;
 
 	return (skb_find_text((struct sk_buff *)skb, conf->from_offset,
 			     conf->to_offset, conf->config, &state)
@@ -53,13 +51,11 @@ static int string_mt_check(const struct xt_mtchk_param *par)
 		return -EINVAL;
 	if (conf->patlen > XT_STRING_MAX_PATTERN_SIZE)
 		return -EINVAL;
-	if (par->match->revision == 1) {
-		if (conf->u.v1.flags &
-		    ~(XT_STRING_FLAG_IGNORECASE | XT_STRING_FLAG_INVERT))
-			return -EINVAL;
-		if (conf->u.v1.flags & XT_STRING_FLAG_IGNORECASE)
-			flags |= TS_IGNORECASE;
-	}
+	if (conf->u.v1.flags &
+	    ~(XT_STRING_FLAG_IGNORECASE | XT_STRING_FLAG_INVERT))
+		return -EINVAL;
+	if (conf->u.v1.flags & XT_STRING_FLAG_IGNORECASE)
+		flags |= TS_IGNORECASE;
 	ts_conf = textsearch_prepare(conf->algo, conf->pattern, conf->patlen,
 				     GFP_KERNEL, flags);
 	if (IS_ERR(ts_conf))
@@ -74,38 +70,25 @@ static void string_mt_destroy(const struct xt_mtdtor_param *par)
 	textsearch_destroy(STRING_TEXT_PRIV(par->matchinfo)->config);
 }
 
-static struct xt_match xt_string_mt_reg[] __read_mostly = {
-	{
-		.name 		= "string",
-		.revision	= 0,
-		.family		= NFPROTO_UNSPEC,
-		.checkentry	= string_mt_check,
-		.match 		= string_mt,
-		.destroy 	= string_mt_destroy,
-		.matchsize	= sizeof(struct xt_string_info),
-		.me 		= THIS_MODULE
-	},
-	{
-		.name 		= "string",
-		.revision	= 1,
-		.family		= NFPROTO_UNSPEC,
-		.checkentry	= string_mt_check,
-		.match 		= string_mt,
-		.destroy 	= string_mt_destroy,
-		.matchsize	= sizeof(struct xt_string_info),
-		.me 		= THIS_MODULE
-	},
+static struct xt_match xt_string_mt_reg __read_mostly = {
+	.name       = "string",
+	.revision   = 1,
+	.family     = NFPROTO_UNSPEC,
+	.checkentry = string_mt_check,
+	.match      = string_mt,
+	.destroy    = string_mt_destroy,
+	.matchsize  = sizeof(struct xt_string_info),
+	.me         = THIS_MODULE,
 };
 
 static int __init string_mt_init(void)
 {
-	return xt_register_matches(xt_string_mt_reg,
-				   ARRAY_SIZE(xt_string_mt_reg));
+	return xt_register_match(&xt_string_mt_reg);
 }
 
 static void __exit string_mt_exit(void)
 {
-	xt_unregister_matches(xt_string_mt_reg, ARRAY_SIZE(xt_string_mt_reg));
+	xt_unregister_match(&xt_string_mt_reg);
 }
 
 module_init(string_mt_init);
-- 
1.7.0.4

