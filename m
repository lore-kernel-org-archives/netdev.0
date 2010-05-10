From: kaber@trash.net
Subject: [PATCH 26/84] netfilter: xtables: do not print any messages on ENOMEM
Date: Mon, 10 May 2010 22:17:57 +0200
Message-ID: <1273522735-24672-27-git-send-email-kaber@trash.net>
References: <1273522735-24672-1-git-send-email-kaber@trash.net>
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1273522735-24672-1-git-send-email-kaber@trash.net>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Jan Engelhardt <jengelh@medozas.de>

ENOMEM is a very obvious error code (cf. EINVAL), so I think we do not
really need a warning message. Not to mention that if the allocation
fails, the user is most likely going to get a stack trace from slab
already.

Signed-off-by: Jan Engelhardt <jengelh@medozas.de>
---
 net/bridge/netfilter/ebt_ulog.c |    7 ++-----
 net/netfilter/xt_LED.c          |    4 +---
 net/netfilter/xt_hashlimit.c    |    8 ++------
 net/netfilter/xt_statistic.c    |    4 +---
 4 files changed, 6 insertions(+), 17 deletions(-)

diff --git a/net/bridge/netfilter/ebt_ulog.c b/net/bridge/netfilter/ebt_ulog.c
index c6ac657..84340ab 100644
--- a/net/bridge/netfilter/ebt_ulog.c
+++ b/net/bridge/netfilter/ebt_ulog.c
@@ -305,13 +305,10 @@ static int __init ebt_ulog_init(void)
 	ebtulognl = netlink_kernel_create(&init_net, NETLINK_NFLOG,
 					  EBT_ULOG_MAXNLGROUPS, NULL, NULL,
 					  THIS_MODULE);
-	if (!ebtulognl) {
-		printk(KERN_WARNING KBUILD_MODNAME ": out of memory trying to "
-		       "call netlink_kernel_create\n");
+	if (!ebtulognl)
 		ret = -ENOMEM;
-	} else if ((ret = xt_register_target(&ebt_ulog_tg_reg)) != 0) {
+	else if ((ret = xt_register_target(&ebt_ulog_tg_reg)) != 0)
 		netlink_kernel_release(ebtulognl);
-	}
 
 	if (ret == 0)
 		nf_log_register(NFPROTO_BRIDGE, &ebt_ulog_logger);
diff --git a/net/netfilter/xt_LED.c b/net/netfilter/xt_LED.c
index f86dc52..0d6c288 100644
--- a/net/netfilter/xt_LED.c
+++ b/net/netfilter/xt_LED.c
@@ -92,10 +92,8 @@ static bool led_tg_check(const struct xt_tgchk_param *par)
 	}
 
 	ledinternal = kzalloc(sizeof(struct xt_led_info_internal), GFP_KERNEL);
-	if (!ledinternal) {
-		printk(KERN_CRIT KBUILD_MODNAME ": out of memory\n");
+	if (!ledinternal)
 		return false;
-	}
 
 	ledinternal->netfilter_led_trigger.name = ledinfo->id;
 
diff --git a/net/netfilter/xt_hashlimit.c b/net/netfilter/xt_hashlimit.c
index 1fdb50a..52327c5 100644
--- a/net/netfilter/xt_hashlimit.c
+++ b/net/netfilter/xt_hashlimit.c
@@ -215,10 +215,8 @@ static int htable_create_v0(struct net *net, struct xt_hashlimit_info *minfo, u_
 	/* FIXME: don't use vmalloc() here or anywhere else -HW */
 	hinfo = vmalloc(sizeof(struct xt_hashlimit_htable) +
 			sizeof(struct list_head) * size);
-	if (!hinfo) {
-		printk(KERN_ERR "xt_hashlimit: unable to create hashtable\n");
+	if (!hinfo)
 		return -1;
-	}
 	minfo->hinfo = hinfo;
 
 	/* copy match config into hashtable config */
@@ -288,10 +286,8 @@ static int htable_create(struct net *net, struct xt_hashlimit_mtinfo1 *minfo,
 	/* FIXME: don't use vmalloc() here or anywhere else -HW */
 	hinfo = vmalloc(sizeof(struct xt_hashlimit_htable) +
 	                sizeof(struct list_head) * size);
-	if (hinfo == NULL) {
-		printk(KERN_ERR "xt_hashlimit: unable to create hashtable\n");
+	if (hinfo == NULL)
 		return -1;
-	}
 	minfo->hinfo = hinfo;
 
 	/* copy match config into hashtable config */
diff --git a/net/netfilter/xt_statistic.c b/net/netfilter/xt_statistic.c
index d8c0f8f..51ac1bb 100644
--- a/net/netfilter/xt_statistic.c
+++ b/net/netfilter/xt_statistic.c
@@ -61,10 +61,8 @@ static bool statistic_mt_check(const struct xt_mtchk_param *par)
 		return false;
 
 	info->master = kzalloc(sizeof(*info->master), GFP_KERNEL);
-	if (info->master == NULL) {
-		printk(KERN_ERR KBUILD_MODNAME ": Out of memory\n");
+	if (info->master == NULL)
 		return false;
-	}
 	info->master->count = info->u.nth.count;
 
 	return true;
-- 
1.7.0.4

