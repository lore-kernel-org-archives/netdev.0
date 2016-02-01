From: John Fastabend <john.fastabend@gmail.com>
Subject: [RFC PATCH 5/7] net: tc: helper functions to query action types
Date: Sun, 31 Jan 2016 17:51:51 -0800
Message-ID: <20160201015151.13871.91135.stgit@john-Precision-Tower-5810>
References: <20160201014555.13871.56591.stgit@john-Precision-Tower-5810>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: ast@fb.com, donald.c.skidmore@intel.com, horms@verge.net.au,
	netdev@vger.kernel.org, tgraf@suug.ch, davem@davemloft.net
To: anjali.singhai@intel.com, jesse.brandeburg@intel.com,
	jhs@mojatatu.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f193.google.com ([209.85.192.193]:35925 "EHLO
	mail-pf0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933350AbcBABwa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 31 Jan 2016 20:52:30 -0500
Received: by mail-pf0-f193.google.com with SMTP id n128so6765303pfn.3
        for <netdev@vger.kernel.org>; Sun, 31 Jan 2016 17:52:30 -0800 (PST)
In-Reply-To: <20160201014555.13871.56591.stgit@john-Precision-Tower-5810>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a helper function drivers can use to learn if the
action type is a drop action.

Signed-off-by: John Fastabend <john.r.fastabend@intel.com>
---
 include/net/tc_act/tc_gact.h |   14 ++++++++++++++
 1 file changed, 14 insertions(+)

diff --git a/include/net/tc_act/tc_gact.h b/include/net/tc_act/tc_gact.h
index 592a6bc..3fee3e9 100644
--- a/include/net/tc_act/tc_gact.h
+++ b/include/net/tc_act/tc_gact.h
@@ -2,6 +2,7 @@
 #define __NET_TC_GACT_H
 
 #include <net/act_api.h>
+#include <linux/tc_act/tc_gact.h>
 
 struct tcf_gact {
 	struct tcf_common	common;
@@ -15,4 +16,17 @@ struct tcf_gact {
 #define to_gact(a) \
 	container_of(a->priv, struct tcf_gact, common)
 
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
 #endif /* __NET_TC_GACT_H */
