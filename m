From: John Fastabend <john.fastabend@gmail.com>
Subject: [net-next PATCH v3 5/8] net: tc: helper functions to query action
 types
Date: Tue, 16 Feb 2016 21:18:03 -0800
Message-ID: <20160217051803.17139.39151.stgit@john-Precision-Tower-5810>
References: <20160217051418.17139.41052.stgit@john-Precision-Tower-5810>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jeffrey.t.kirsher@intel.com
To: jiri@resnulli.us, amir@vadai.me, john.fastabend@gmail.com,
	jhs@mojatatu.com, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f177.google.com ([209.85.192.177]:36521 "EHLO
	mail-pf0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751030AbcBQFSW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 17 Feb 2016 00:18:22 -0500
Received: by mail-pf0-f177.google.com with SMTP id e127so4768855pfe.3
        for <netdev@vger.kernel.org>; Tue, 16 Feb 2016 21:18:22 -0800 (PST)
In-Reply-To: <20160217051418.17139.41052.stgit@john-Precision-Tower-5810>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a helper function drivers can use to learn if the
action type is a drop action.

Signed-off-by: John Fastabend <john.r.fastabend@intel.com>
---
 include/net/tc_act/tc_gact.h |   16 ++++++++++++++++
 1 file changed, 16 insertions(+)

diff --git a/include/net/tc_act/tc_gact.h b/include/net/tc_act/tc_gact.h
index 592a6bc..04a3183 100644
--- a/include/net/tc_act/tc_gact.h
+++ b/include/net/tc_act/tc_gact.h
@@ -2,6 +2,7 @@
 #define __NET_TC_GACT_H
 
 #include <net/act_api.h>
+#include <linux/tc_act/tc_gact.h>
 
 struct tcf_gact {
 	struct tcf_common	common;
@@ -15,4 +16,19 @@ struct tcf_gact {
 #define to_gact(a) \
 	container_of(a->priv, struct tcf_gact, common)
 
+#ifdef CONFIG_NET_CLS_ACT
+static inline bool is_tcf_gact_shot(const struct tc_action *a)
+{
+	struct tcf_gact *gact;
+
+	if (a->ops && a->ops->type != TCA_ACT_GACT)
+		return false;
+
+	gact = a->priv;
+	if (gact->tcf_action == TC_ACT_SHOT)
+		return true;
+
+	return false;
+}
+#endif
 #endif /* __NET_TC_GACT_H */
