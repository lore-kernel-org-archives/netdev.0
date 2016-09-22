From: Saeed Mahameed <saeedm@mellanox.com>
Subject: [PATCH net-next 1/9] net_sched: act_vlan: add helper inlines to access tcf_vlan info
Date: Thu, 22 Sep 2016 20:01:41 +0300
Message-ID: <1474563709-17943-2-git-send-email-saeedm@mellanox.com>
References: <1474563709-17943-1-git-send-email-saeedm@mellanox.com>
Cc: netdev@vger.kernel.org, Or Gerlitz <ogerlitz@mellanox.com>,
        Hadar Hen-Zion <hadarh@mellanox.com>,
        Jiri Pirko <jiri@mellanox.com>,
        Andy Gospodarek <gospo@cumulusnetworks.com>,
        Jesse Brandeburg <jesse.brandeburg@intel.com>,
        John Fastabend <john.r.fastabend@intel.com>,
        Amir Vadai <amirv@mellanox.com>,
        Saeed Mahameed <saeedm@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:48995 "EHLO
        mellanox.co.il" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S964976AbcIVRCQ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 22 Sep 2016 13:02:16 -0400
In-Reply-To: <1474563709-17943-1-git-send-email-saeedm@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Or Gerlitz <ogerlitz@mellanox.com>

Needed e.g for offloading drivers to pick the relevant attributes.

Signed-off-by: Or Gerlitz <ogerlitz@mellanox.com>
Signed-off-by: Saeed Mahameed <saeedm@mellanox.com>
---
 include/net/tc_act/tc_vlan.h | 25 +++++++++++++++++++++++++
 1 file changed, 25 insertions(+)

diff --git a/include/net/tc_act/tc_vlan.h b/include/net/tc_act/tc_vlan.h
index 6b83588..48cca32 100644
--- a/include/net/tc_act/tc_vlan.h
+++ b/include/net/tc_act/tc_vlan.h
@@ -11,6 +11,7 @@
 #define __NET_TC_VLAN_H
 
 #include <net/act_api.h>
+#include <linux/tc_act/tc_vlan.h>
 
 #define VLAN_F_POP		0x1
 #define VLAN_F_PUSH		0x2
@@ -24,4 +25,28 @@ struct tcf_vlan {
 };
 #define to_vlan(a) ((struct tcf_vlan *)a)
 
+static inline bool is_tcf_vlan(const struct tc_action *a)
+{
+#ifdef CONFIG_NET_CLS_ACT
+	if (a->ops && a->ops->type == TCA_ACT_VLAN)
+		return true;
+#endif
+	return false;
+}
+
+static inline u32 tcf_vlan_action(const struct tc_action *a)
+{
+	return to_vlan(a)->tcfv_action;
+}
+
+static inline u16 tcf_vlan_push_vid(const struct tc_action *a)
+{
+	return to_vlan(a)->tcfv_push_vid;
+}
+
+static inline __be16 tcf_vlan_push_proto(const struct tc_action *a)
+{
+	return to_vlan(a)->tcfv_push_proto;
+}
+
 #endif /* __NET_TC_VLAN_H */
-- 
2.7.4
