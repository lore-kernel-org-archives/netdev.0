From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next v3 09/11] act_police: move struct tcf_police to act_police.c
Date: Sat,  9 Feb 2013 17:45:10 +0100
Message-ID: <1360428312-1277-10-git-send-email-jiri@resnulli.us>
References: <1360428312-1277-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, edumazet@google.com, jhs@mojatatu.com,
	kuznet@ms2.inr.ac.ru, j.vimal@gmail.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f51.google.com ([74.125.83.51]:51557 "EHLO
	mail-ee0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932450Ab3BIQpm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 9 Feb 2013 11:45:42 -0500
Received: by mail-ee0-f51.google.com with SMTP id d17so2376631eek.38
        for <netdev@vger.kernel.org>; Sat, 09 Feb 2013 08:45:41 -0800 (PST)
In-Reply-To: <1360428312-1277-1-git-send-email-jiri@resnulli.us>
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
