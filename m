From: Saeed Mahameed <saeedm@mellanox.com>
Subject: [net 2/8] net/sched: act_csum: Add accessors for offloading drivers
Date: Tue, 23 May 2017 17:16:04 +0300
Message-ID: <20170523141610.27833-3-saeedm@mellanox.com>
References: <20170523141610.27833-1-saeedm@mellanox.com>
Cc: netdev@vger.kernel.org, Or Gerlitz <ogerlitz@mellanox.com>,
        Saeed Mahameed <saeedm@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:44672 "EHLO
        mellanox.co.il" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S935930AbdEWOQb (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 23 May 2017 10:16:31 -0400
In-Reply-To: <20170523141610.27833-1-saeedm@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Or Gerlitz <ogerlitz@mellanox.com>

Add the accessors for realizing if this is a csum action,
and for which fields checksum is needed.

Signed-off-by: Or Gerlitz <ogerlitz@mellanox.com>
Reviewed-by: Paul Blakey <paulb@mellanox.com>
Signed-off-by: Saeed Mahameed <saeedm@mellanox.com>
---
 include/net/tc_act/tc_csum.h | 15 +++++++++++++++
 1 file changed, 15 insertions(+)

diff --git a/include/net/tc_act/tc_csum.h b/include/net/tc_act/tc_csum.h
index f31fb6331a53..3248beaf16b0 100644
--- a/include/net/tc_act/tc_csum.h
+++ b/include/net/tc_act/tc_csum.h
@@ -3,6 +3,7 @@
 
 #include <linux/types.h>
 #include <net/act_api.h>
+#include <linux/tc_act/tc_csum.h>
 
 struct tcf_csum {
 	struct tc_action common;
@@ -11,4 +12,18 @@ struct tcf_csum {
 };
 #define to_tcf_csum(a) ((struct tcf_csum *)a)
 
+static inline bool is_tcf_csum(const struct tc_action *a)
+{
+#ifdef CONFIG_NET_CLS_ACT
+	if (a->ops && a->ops->type == TCA_ACT_CSUM)
+		return true;
+#endif
+	return false;
+}
+
+static inline u32 tcf_csum_update_flags(const struct tc_action *a)
+{
+	return to_tcf_csum(a)->update_flags;
+}
+
 #endif /* __NET_TC_CSUM_H */
-- 
2.11.0
