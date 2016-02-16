From: John Fastabend <john.fastabend@gmail.com>
Subject: [net-next PATCH v2 5/8] net: tc: helper functions to query action
 types
Date: Mon, 15 Feb 2016 22:02:16 -0800
Message-ID: <20160216060216.32452.72576.stgit@john-Precision-Tower-5810>
References: <20160216055819.32452.84181.stgit@john-Precision-Tower-5810>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jiri@resnulli.us,
	jeffrey.t.kirsher@intel.com
To: amir@vadai.me, john.fastabend@gmail.com, jhs@mojatatu.com,
	davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f181.google.com ([209.85.192.181]:32839 "EHLO
	mail-pf0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753831AbcBPGCh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 16 Feb 2016 01:02:37 -0500
Received: by mail-pf0-f181.google.com with SMTP id q63so99093086pfb.0
        for <netdev@vger.kernel.org>; Mon, 15 Feb 2016 22:02:37 -0800 (PST)
In-Reply-To: <20160216055819.32452.84181.stgit@john-Precision-Tower-5810>
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
