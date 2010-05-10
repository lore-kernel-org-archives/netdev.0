From: kaber@trash.net
Subject: [PATCH 18/84] netfilter: xtables: do without explicit XT_ALIGN
Date: Mon, 10 May 2010 22:17:49 +0200
Message-ID: <1273522735-24672-19-git-send-email-kaber@trash.net>
References: <1273522735-24672-1-git-send-email-kaber@trash.net>
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:54508 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756701Ab0EJUTB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 10 May 2010 16:19:01 -0400
In-Reply-To: <1273522735-24672-1-git-send-email-kaber@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jan Engelhardt <jengelh@medozas.de>

XT_ALIGN is already applied on matchsize/targetsize in x_tables.c,
so it is not strictly needed in the extensions.

Signed-off-by: Jan Engelhardt <jengelh@medozas.de>
---
 net/netfilter/xt_CT.c  |    2 +-
 net/netfilter/xt_LED.c |    2 +-
 2 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/netfilter/xt_CT.c b/net/netfilter/xt_CT.c
index fda603e..6509e03 100644
--- a/net/netfilter/xt_CT.c
+++ b/net/netfilter/xt_CT.c
@@ -137,7 +137,7 @@ static void xt_ct_tg_destroy(const struct xt_tgdtor_param *par)
 static struct xt_target xt_ct_tg __read_mostly = {
 	.name		= "CT",
 	.family		= NFPROTO_UNSPEC,
-	.targetsize	= XT_ALIGN(sizeof(struct xt_ct_target_info)),
+	.targetsize	= sizeof(struct xt_ct_target_info),
 	.checkentry	= xt_ct_tg_check,
 	.destroy	= xt_ct_tg_destroy,
 	.target		= xt_ct_target,
diff --git a/net/netfilter/xt_LED.c b/net/netfilter/xt_LED.c
index 8ff7843..f86dc52 100644
--- a/net/netfilter/xt_LED.c
+++ b/net/netfilter/xt_LED.c
@@ -141,7 +141,7 @@ static struct xt_target led_tg_reg __read_mostly = {
 	.revision	= 0,
 	.family		= NFPROTO_UNSPEC,
 	.target		= led_tg,
-	.targetsize	= XT_ALIGN(sizeof(struct xt_led_info)),
+	.targetsize	= sizeof(struct xt_led_info),
 	.checkentry	= led_tg_check,
 	.destroy	= led_tg_destroy,
 	.me		= THIS_MODULE,
-- 
1.7.0.4

