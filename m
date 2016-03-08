From: Amir Vadai <amir@vadai.me>
Subject: [PATCH net-next V3 04/10] net/act_skbedit: Utility functions for mark action
Date: Tue,  8 Mar 2016 12:42:32 +0200
Message-ID: <1457433758-9193-5-git-send-email-amir@vadai.me>
References: <1457433758-9193-1-git-send-email-amir@vadai.me>
Cc: netdev@vger.kernel.org,
	John Fastabend <john.r.fastabend@intel.com>,
	Jiri Pirko <jiri@mellanox.com>,
	Or Gerlitz <ogerlitz@mellanox.com>,
	Saeed Mahameed <saeedm@mellanox.com>,
	Hadar Har-Zion <hadarh@mellanox.com>,
	Rony Efraim <ronye@mellanox.com>, Amir Vadai <amir@vadai.me>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f67.google.com ([74.125.82.67]:34582 "EHLO
	mail-wm0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933110AbcCHKjS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 8 Mar 2016 05:39:18 -0500
Received: by mail-wm0-f67.google.com with SMTP id p65so3237881wmp.1
        for <netdev@vger.kernel.org>; Tue, 08 Mar 2016 02:39:17 -0800 (PST)
In-Reply-To: <1457433758-9193-1-git-send-email-amir@vadai.me>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Enable device drivers to query the action, if and only if is a mark
action and what value to use for marking.

Acked-by: Jiri Pirko <jiri@mellanox.com>
Signed-off-by: Amir Vadai <amir@vadai.me>
---
 include/net/tc_act/tc_skbedit.h | 16 ++++++++++++++++
 1 file changed, 16 insertions(+)

diff --git a/include/net/tc_act/tc_skbedit.h b/include/net/tc_act/tc_skbedit.h
index 0df9a0d..b496d5a 100644
--- a/include/net/tc_act/tc_skbedit.h
+++ b/include/net/tc_act/tc_skbedit.h
@@ -20,6 +20,7 @@
 #define __NET_TC_SKBEDIT_H
 
 #include <net/act_api.h>
+#include <linux/tc_act/tc_skbedit.h>
 
 struct tcf_skbedit {
 	struct tcf_common	common;
@@ -32,4 +33,19 @@ struct tcf_skbedit {
 #define to_skbedit(a) \
 	container_of(a->priv, struct tcf_skbedit, common)
 
+/* Return true iff action is mark */
+static inline bool is_tcf_skbedit_mark(const struct tc_action *a)
+{
+#ifdef CONFIG_NET_CLS_ACT
+	if (a->ops && a->ops->type == TCA_ACT_SKBEDIT)
+		return to_skbedit(a)->flags == SKBEDIT_F_MARK;
+#endif
+	return false;
+}
+
+static inline u32 tcf_skbedit_mark(const struct tc_action *a)
+{
+	return to_skbedit(a)->mark;
+}
+
 #endif /* __NET_TC_SKBEDIT_H */
-- 
2.7.0
