From: John Fastabend <john.fastabend@gmail.com>
Subject: [net-next PATCH 5/7] net: tc: helper functions to query action types
Date: Wed, 03 Feb 2016 01:29:19 -0800
Message-ID: <20160203092919.1356.21655.stgit@john-Precision-Tower-5810>
References: <20160203092708.1356.13733.stgit@john-Precision-Tower-5810>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net
To: amir@vadai.me, ogerlitz@mellanox.com, jiri@resnulli.us,
	jhs@mojatatu.com, jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f180.google.com ([209.85.192.180]:33641 "EHLO
	mail-pf0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751519AbcBCJ3e (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 3 Feb 2016 04:29:34 -0500
Received: by mail-pf0-f180.google.com with SMTP id w123so11019102pfb.0
        for <netdev@vger.kernel.org>; Wed, 03 Feb 2016 01:29:34 -0800 (PST)
In-Reply-To: <20160203092708.1356.13733.stgit@john-Precision-Tower-5810>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a helper function drivers can use to learn if the
action type is a drop action.

Signed-off-by: John Fastabend <john.r.fastabend@intel.com>
---
 include/net/tc_act/tc_gact.h |   16 ++++++++++++++++
 1 file changed, 16 insertions(+)

diff --git a/include/net/tc_act/tc_gact.h b/include/net/tc_act/tc_gact.h
index 592a6bc..3067a10 100644
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
+static inline bool is_tcf_gact_dropped(const struct tc_action *a)
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
