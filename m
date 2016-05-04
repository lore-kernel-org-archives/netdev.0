From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 01/14] net_sched: act_mirred: add helper inlines to access tcf_mirred info
Date: Wed,  4 May 2016 09:26:35 -0700
Message-ID: <1462379208-3997-2-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1462379208-3997-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Sridhar Samudrala <sridhar.samudrala@intel.com>,
	netdev@vger.kernel.org, nhorman@redhat.com, sassmann@redhat.com,
	jogreene@redhat.com, Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:37089 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754585AbcEDQ1Y (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 4 May 2016 12:27:24 -0400
In-Reply-To: <1462379208-3997-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sridhar Samudrala <sridhar.samudrala@intel.com>

Signed-off-by: Sridhar Samudrala <sridhar.samudrala@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 include/net/tc_act/tc_mirred.h | 15 +++++++++++++++
 1 file changed, 15 insertions(+)

diff --git a/include/net/tc_act/tc_mirred.h b/include/net/tc_act/tc_mirred.h
index dae96ba..e891835 100644
--- a/include/net/tc_act/tc_mirred.h
+++ b/include/net/tc_act/tc_mirred.h
@@ -2,6 +2,7 @@
 #define __NET_TC_MIR_H
 
 #include <net/act_api.h>
+#include <linux/tc_act/tc_mirred.h>
 
 struct tcf_mirred {
 	struct tcf_common	common;
@@ -14,4 +15,18 @@ struct tcf_mirred {
 #define to_mirred(a) \
 	container_of(a->priv, struct tcf_mirred, common)
 
+static inline bool is_tcf_mirred_redirect(const struct tc_action *a)
+{
+#ifdef CONFIG_NET_CLS_ACT
+	if (a->ops && a->ops->type == TCA_ACT_MIRRED)
+		return to_mirred(a)->tcfm_eaction == TCA_EGRESS_REDIR;
+#endif
+	return false;
+}
+
+static inline int tcf_mirred_ifindex(const struct tc_action *a)
+{
+	return to_mirred(a)->tcfm_ifindex;
+}
+
 #endif /* __NET_TC_MIR_H */
-- 
2.5.5
