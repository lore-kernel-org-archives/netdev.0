From: Cong Wang <amwang@redhat.com>
Subject: [Resend PATCH 2/2] netfilter: remove rev 0 of xt_connlimit
Date: Sat, 19 May 2012 22:39:01 +0800
Message-ID: <1337438341-29732-2-git-send-email-amwang@redhat.com>
References: <1337438341-29732-1-git-send-email-amwang@redhat.com>
Cc: netdev@vger.kernel.org, Cong Wang <xiyou.wangcong@gmail.com>,
	Jan Engelhardt <jengelh@medozas.de>
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:60513 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1760319Ab2ESOjU (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 19 May 2012 10:39:20 -0400
In-Reply-To: <1337438341-29732-1-git-send-email-amwang@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Cong Wang <xiyou.wangcong@gmail.com>

It was scheduled to be removed.

Cc: Jan Engelhardt <jengelh@medozas.de>
Signed-off-by: Cong Wang <xiyou.wangcong@gmail.com>
---
 Documentation/feature-removal-schedule.txt |    7 -----
 include/linux/netfilter/xt_connlimit.h     |    9 +-----
 net/netfilter/xt_connlimit.c               |   35 ++++++++-------------------
 3 files changed, 13 insertions(+), 38 deletions(-)

diff --git a/Documentation/feature-removal-schedule.txt b/Documentation/feature-removal-schedule.txt
index 366d158..edf7901 100644
--- a/Documentation/feature-removal-schedule.txt
+++ b/Documentation/feature-removal-schedule.txt
@@ -407,13 +407,6 @@ Who:	Jean Delvare <khali@linux-fr.org>
 
 ----------------------------
 
-What:	xt_connlimit rev 0
-When:	2012
-Who:	Jan Engelhardt <jengelh@medozas.de>
-Files:	net/netfilter/xt_connlimit.c
-
-----------------------------
-
 What:	i2c_driver.attach_adapter
 	i2c_driver.detach_adapter
 When:	September 2011
diff --git a/include/linux/netfilter/xt_connlimit.h b/include/linux/netfilter/xt_connlimit.h
index d1366f0..f165609 100644
--- a/include/linux/netfilter/xt_connlimit.h
+++ b/include/linux/netfilter/xt_connlimit.h
@@ -22,13 +22,8 @@ struct xt_connlimit_info {
 #endif
 	};
 	unsigned int limit;
-	union {
-		/* revision 0 */
-		unsigned int inverse;
-
-		/* revision 1 */
-		__u32 flags;
-	};
+	/* revision 1 */
+	__u32 flags;
 
 	/* Used internally by the kernel */
 	struct xt_connlimit_data *data __attribute__((aligned(8)));
diff --git a/net/netfilter/xt_connlimit.c b/net/netfilter/xt_connlimit.c
index c6d5a83..70b5591 100644
--- a/net/netfilter/xt_connlimit.c
+++ b/net/netfilter/xt_connlimit.c
@@ -274,38 +274,25 @@ static void connlimit_mt_destroy(const struct xt_mtdtor_param *par)
 	kfree(info->data);
 }
 
-static struct xt_match connlimit_mt_reg[] __read_mostly = {
-	{
-		.name       = "connlimit",
-		.revision   = 0,
-		.family     = NFPROTO_UNSPEC,
-		.checkentry = connlimit_mt_check,
-		.match      = connlimit_mt,
-		.matchsize  = sizeof(struct xt_connlimit_info),
-		.destroy    = connlimit_mt_destroy,
-		.me         = THIS_MODULE,
-	},
-	{
-		.name       = "connlimit",
-		.revision   = 1,
-		.family     = NFPROTO_UNSPEC,
-		.checkentry = connlimit_mt_check,
-		.match      = connlimit_mt,
-		.matchsize  = sizeof(struct xt_connlimit_info),
-		.destroy    = connlimit_mt_destroy,
-		.me         = THIS_MODULE,
-	},
+static struct xt_match connlimit_mt_reg __read_mostly = {
+	.name       = "connlimit",
+	.revision   = 1,
+	.family     = NFPROTO_UNSPEC,
+	.checkentry = connlimit_mt_check,
+	.match      = connlimit_mt,
+	.matchsize  = sizeof(struct xt_connlimit_info),
+	.destroy    = connlimit_mt_destroy,
+	.me         = THIS_MODULE,
 };
 
 static int __init connlimit_mt_init(void)
 {
-	return xt_register_matches(connlimit_mt_reg,
-	       ARRAY_SIZE(connlimit_mt_reg));
+	return xt_register_match(&connlimit_mt_reg);
 }
 
 static void __exit connlimit_mt_exit(void)
 {
-	xt_unregister_matches(connlimit_mt_reg, ARRAY_SIZE(connlimit_mt_reg));
+	xt_unregister_match(&connlimit_mt_reg);
 }
 
 module_init(connlimit_mt_init);
-- 
1.7.7.6
