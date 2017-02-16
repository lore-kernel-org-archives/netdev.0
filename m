From: Or Gerlitz <ogerlitz@mellanox.com>
Subject: [PATCH net-next V4 3/7] net/sched: Reflect HW offload status
Date: Thu, 16 Feb 2017 10:31:12 +0200
Message-ID: <1487233876-28576-4-git-send-email-ogerlitz@mellanox.com>
References: <1487233876-28576-1-git-send-email-ogerlitz@mellanox.com>
Cc: Jamal Hadi Salim <jhs@mojatatu.com>, Roi Dayan <roid@mellanox.com>,
        netdev@vger.kernel.org, Or Gerlitz <ogerlitz@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:44993 "EHLO
        mellanox.co.il" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S1752859AbdBPIbi (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 16 Feb 2017 03:31:38 -0500
In-Reply-To: <1487233876-28576-1-git-send-email-ogerlitz@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Currently there is no way of querying whether a filter is
offloaded to HW or not when using "both" policy (where none
of skip_sw or skip_hw flags are set by user-space).

Add two new flags, "in hw" and "not in hw" such that user
space can determine if a filter is actually offloaded to
hw or not. The "in hw" UAPI semantics was chosen so it's
similar to the "skip hw" flag logic.

If none of these two flags are set, this signals running
over older kernel.

Signed-off-by: Or Gerlitz <ogerlitz@mellanox.com>
Reviewed-by: Amir Vadai <amir@vadai.me>
Acked-by: Jiri Pirko <jiri@mellanox.com>
---
 include/net/pkt_cls.h        | 5 +++++
 include/uapi/linux/pkt_cls.h | 6 ++++--
 2 files changed, 9 insertions(+), 2 deletions(-)

diff --git a/include/net/pkt_cls.h b/include/net/pkt_cls.h
index 71b266c..15cfe15 100644
--- a/include/net/pkt_cls.h
+++ b/include/net/pkt_cls.h
@@ -475,6 +475,11 @@ static inline bool tc_flags_valid(u32 flags)
 	return true;
 }
 
+static inline bool tc_in_hw(u32 flags)
+{
+	return (flags & TCA_CLS_FLAGS_IN_HW) ? true : false;
+}
+
 enum tc_fl_command {
 	TC_CLSFLOWER_REPLACE,
 	TC_CLSFLOWER_DESTROY,
diff --git a/include/uapi/linux/pkt_cls.h b/include/uapi/linux/pkt_cls.h
index 345551e..7a69f2a 100644
--- a/include/uapi/linux/pkt_cls.h
+++ b/include/uapi/linux/pkt_cls.h
@@ -103,8 +103,10 @@ enum {
 #define TCA_POLICE_MAX (__TCA_POLICE_MAX - 1)
 
 /* tca flags definitions */
-#define TCA_CLS_FLAGS_SKIP_HW	(1 << 0)
-#define TCA_CLS_FLAGS_SKIP_SW	(1 << 1)
+#define TCA_CLS_FLAGS_SKIP_HW	(1 << 0) /* don't offload filter to HW */
+#define TCA_CLS_FLAGS_SKIP_SW	(1 << 1) /* don't use filter in SW */
+#define TCA_CLS_FLAGS_IN_HW	(1 << 2) /* filter is offloaded to HW */
+#define TCA_CLS_FLAGS_NOT_IN_HW (1 << 3) /* filter isn't offloaded to HW */
 
 /* U32 filters */
 
-- 
2.5.5
