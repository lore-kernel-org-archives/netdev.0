From: Saeed Mahameed <saeedm@mellanox.com>
Subject: [net-next 09/12] net/sched: Add accessor functions to pedit keys for offloading drivers
Date: Wed, 29 Mar 2017 02:27:10 +0300
Message-ID: <20170328232713.29894-10-saeedm@mellanox.com>
References: <20170328232713.29894-1-saeedm@mellanox.com>
Cc: netdev@vger.kernel.org, Amir Vadai <amir@vadai.me>,
        Or Gerlitz <ogerlitz@mellanox.com>,
        Saeed Mahameed <saeedm@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:42866 "EHLO
        mellanox.co.il" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S932594AbdC1X2C (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 28 Mar 2017 19:28:02 -0400
In-Reply-To: <20170328232713.29894-1-saeedm@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Or Gerlitz <ogerlitz@mellanox.com>

HW drivers will use the header-type and command fields from the extended
keys, and some fields (e.g mask, val, offset) from the legacy keys.

Signed-off-by: Or Gerlitz <ogerlitz@mellanox.com>
Reviewed-by: Hadar Hen Zion <hadarh@mellanox.com>
Signed-off-by: Saeed Mahameed <saeedm@mellanox.com>
---
 include/net/tc_act/tc_pedit.h | 45 +++++++++++++++++++++++++++++++++++++++++++
 1 file changed, 45 insertions(+)

diff --git a/include/net/tc_act/tc_pedit.h b/include/net/tc_act/tc_pedit.h
index dfbd6ee0bc7c..a46c3f2ace70 100644
--- a/include/net/tc_act/tc_pedit.h
+++ b/include/net/tc_act/tc_pedit.h
@@ -2,6 +2,7 @@
 #define __NET_TC_PED_H
 
 #include <net/act_api.h>
+#include <linux/tc_act/tc_pedit.h>
 
 struct tcf_pedit_key_ex {
 	enum pedit_header_type htype;
@@ -17,4 +18,48 @@ struct tcf_pedit {
 };
 #define to_pedit(a) ((struct tcf_pedit *)a)
 
+static inline bool is_tcf_pedit(const struct tc_action *a)
+{
+#ifdef CONFIG_NET_CLS_ACT
+	if (a->ops && a->ops->type == TCA_ACT_PEDIT)
+		return true;
+#endif
+	return false;
+}
+
+static inline int tcf_pedit_nkeys(const struct tc_action *a)
+{
+	return to_pedit(a)->tcfp_nkeys;
+}
+
+static inline u32 tcf_pedit_htype(const struct tc_action *a, int index)
+{
+	if (to_pedit(a)->tcfp_keys_ex)
+		return to_pedit(a)->tcfp_keys_ex[index].htype;
+
+	return TCA_PEDIT_KEY_EX_HDR_TYPE_NETWORK;
+}
+
+static inline u32 tcf_pedit_cmd(const struct tc_action *a, int index)
+{
+	if (to_pedit(a)->tcfp_keys_ex)
+		return to_pedit(a)->tcfp_keys_ex[index].cmd;
+
+	return __PEDIT_CMD_MAX;
+}
+
+static inline u32 tcf_pedit_mask(const struct tc_action *a, int index)
+{
+	return to_pedit(a)->tcfp_keys[index].mask;
+}
+
+static inline u32 tcf_pedit_val(const struct tc_action *a, int index)
+{
+	return to_pedit(a)->tcfp_keys[index].val;
+}
+
+static inline u32 tcf_pedit_offset(const struct tc_action *a, int index)
+{
+	return to_pedit(a)->tcfp_keys[index].off;
+}
 #endif /* __NET_TC_PED_H */
-- 
2.11.0
