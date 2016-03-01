From: Amir Vadai <amir@vadai.me>
Subject: [PATCH net-next 3/8] net/act_skbedit: Utility functions for mark action
Date: Tue,  1 Mar 2016 16:24:45 +0200
Message-ID: <1456842290-7844-4-git-send-email-amir@vadai.me>
References: <1456842290-7844-1-git-send-email-amir@vadai.me>
Cc: netdev@vger.kernel.org, Or Gerlitz <ogerlitz@mellanox.com>,
	John Fastabend <john.r.fastabend@intel.com>,
	Saeed Mahameed <saeedm@mellanox.com>,
	Hadar Har-Zion <hadarh@mellanox.com>,
	Jiri Pirko <jiri@mellanox.com>, Amir Vadai <amir@vadai.me>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f67.google.com ([74.125.82.67]:34203 "EHLO
	mail-wm0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753745AbcCAOVm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Mar 2016 09:21:42 -0500
Received: by mail-wm0-f67.google.com with SMTP id p65so4362732wmp.1
        for <netdev@vger.kernel.org>; Tue, 01 Mar 2016 06:21:41 -0800 (PST)
In-Reply-To: <1456842290-7844-1-git-send-email-amir@vadai.me>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Enable device drivers to query the action if is a mark action and what
value to use for marking.

Signed-off-by: Amir Vadai <amir@vadai.me>
---
 include/net/tc_act/tc_skbedit.h | 15 +++++++++++++++
 1 file changed, 15 insertions(+)

diff --git a/include/net/tc_act/tc_skbedit.h b/include/net/tc_act/tc_skbedit.h
index 0df9a0d..ad27d69 100644
--- a/include/net/tc_act/tc_skbedit.h
+++ b/include/net/tc_act/tc_skbedit.h
@@ -20,6 +20,7 @@
 #define __NET_TC_SKBEDIT_H
 
 #include <net/act_api.h>
+#include <linux/tc_act/tc_skbedit.h>
 
 struct tcf_skbedit {
 	struct tcf_common	common;
@@ -32,4 +33,18 @@ struct tcf_skbedit {
 #define to_skbedit(a) \
 	container_of(a->priv, struct tcf_skbedit, common)
 
+#ifdef CONFIG_NET_CLS_ACT
+static inline bool is_tcf_skbedit_mark(const struct tc_action *a)
+{
+	if (!a->ops || a->ops->type != TCA_ACT_SKBEDIT)
+		return false;
+
+	return to_skbedit(a)->flags == SKBEDIT_F_MARK;
+}
+
+static inline u32 tcf_skbedit_mark(const struct tc_action *a)
+{
+	return to_skbedit(a)->mark;
+}
+#endif
 #endif /* __NET_TC_SKBEDIT_H */
-- 
2.7.0
