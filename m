From: kaber@trash.net
Subject: [PATCH 16/84] netfilter: xt_recent: check for unsupported user space flags
Date: Mon, 10 May 2010 22:17:47 +0200
Message-ID: <1273522735-24672-17-git-send-email-kaber@trash.net>
References: <1273522735-24672-1-git-send-email-kaber@trash.net>
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:54526 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756697Ab0EJUTB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 10 May 2010 16:19:01 -0400
In-Reply-To: <1273522735-24672-1-git-send-email-kaber@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Tim Gardner <tim.gardner@canonical.com>

Signed-off-by: Tim Gardner <tim.gardner@canonical.com>
Signed-off-by: Patrick McHardy <kaber@trash.net>
---
 include/linux/netfilter/xt_recent.h |    3 +++
 net/netfilter/xt_recent.c           |    5 +++++
 2 files changed, 8 insertions(+), 0 deletions(-)

diff --git a/include/linux/netfilter/xt_recent.h b/include/linux/netfilter/xt_recent.h
index bba990e..83318e0 100644
--- a/include/linux/netfilter/xt_recent.h
+++ b/include/linux/netfilter/xt_recent.h
@@ -20,6 +20,9 @@ enum {
 /* Only allowed with --rcheck and --update */
 #define XT_RECENT_MODIFIERS (XT_RECENT_TTL|XT_RECENT_REAP)
 
+#define XT_RECENT_VALID_FLAGS (XT_RECENT_CHECK|XT_RECENT_SET|XT_RECENT_UPDATE|\
+			       XT_RECENT_REMOVE|XT_RECENT_TTL|XT_RECENT_REAP)
+
 struct xt_recent_mtinfo {
 	__u32 seconds;
 	__u32 hit_count;
diff --git a/net/netfilter/xt_recent.c b/net/netfilter/xt_recent.c
index b65eca9..d2e7c80 100644
--- a/net/netfilter/xt_recent.c
+++ b/net/netfilter/xt_recent.c
@@ -319,6 +319,11 @@ static bool recent_mt_check(const struct xt_mtchk_param *par)
 		get_random_bytes(&hash_rnd, sizeof(hash_rnd));
 		hash_rnd_inited = true;
 	}
+	if (info->check_set & ~XT_RECENT_VALID_FLAGS) {
+		pr_info(KBUILD_MODNAME ": Unsupported user space flags "
+			"(%08x)\n", info->check_set);
+		return false;
+	}
 	if (hweight8(info->check_set &
 		     (XT_RECENT_SET | XT_RECENT_REMOVE |
 		      XT_RECENT_CHECK | XT_RECENT_UPDATE)) != 1)
-- 
1.7.0.4

