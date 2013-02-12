From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next v5 08/11] act_police: move struct tcf_police to act_police.c
Date: Tue, 12 Feb 2013 11:12:06 +0100
Message-ID: <1360663929-1023-9-git-send-email-jiri@resnulli.us>
References: <1360663929-1023-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, edumazet@google.com, jhs@mojatatu.com,
	kuznet@ms2.inr.ac.ru, j.vimal@gmail.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f52.google.com ([74.125.83.52]:57158 "EHLO
	mail-ee0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932873Ab3BLKMj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 12 Feb 2013 05:12:39 -0500
Received: by mail-ee0-f52.google.com with SMTP id b15so3444799eek.25
        for <netdev@vger.kernel.org>; Tue, 12 Feb 2013 02:12:38 -0800 (PST)
In-Reply-To: <1360663929-1023-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

It's not used anywhere else, so move it.

Signed-off-by: Jiri Pirko <jiri@resnulli.us>
---
 include/net/act_api.h  | 15 ---------------
 net/sched/act_police.c | 15 +++++++++++++++
 2 files changed, 15 insertions(+), 15 deletions(-)

diff --git a/include/net/act_api.h b/include/net/act_api.h
index 112c25c..06ef7e9 100644
--- a/include/net/act_api.h
+++ b/include/net/act_api.h
@@ -35,21 +35,6 @@ struct tcf_common {
 #define tcf_lock	common.tcfc_lock
 #define tcf_rcu		common.tcfc_rcu
 
-struct tcf_police {
-	struct tcf_common	common;
-	int			tcfp_result;
-	u32			tcfp_ewma_rate;
-	u32			tcfp_burst;
-	u32			tcfp_mtu;
-	u32			tcfp_toks;
-	u32			tcfp_ptoks;
-	psched_time_t		tcfp_t_c;
-	struct qdisc_rate_table	*tcfp_R_tab;
-	struct qdisc_rate_table	*tcfp_P_tab;
-};
-#define to_police(pc)	\
-	container_of(pc, struct tcf_police, common)
-
 struct tcf_hashinfo {
 	struct tcf_common	**htab;
 	unsigned int		hmask;
diff --git a/net/sched/act_police.c b/net/sched/act_police.c
index 8dbd695..378a649 100644
--- a/net/sched/act_police.c
+++ b/net/sched/act_police.c
@@ -22,6 +22,21 @@
 #include <net/act_api.h>
 #include <net/netlink.h>
 
+struct tcf_police {
+	struct tcf_common	common;
+	int			tcfp_result;
+	u32			tcfp_ewma_rate;
+	u32			tcfp_burst;
+	u32			tcfp_mtu;
+	u32			tcfp_toks;
+	u32			tcfp_ptoks;
+	psched_time_t		tcfp_t_c;
+	struct qdisc_rate_table	*tcfp_R_tab;
+	struct qdisc_rate_table	*tcfp_P_tab;
+};
+#define to_police(pc)	\
+	container_of(pc, struct tcf_police, common)
+
 #define L2T(p, L)   qdisc_l2t((p)->tcfp_R_tab, L)
 #define L2T_P(p, L) qdisc_l2t((p)->tcfp_P_tab, L)
 
-- 
1.8.1.2
