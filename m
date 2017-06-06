From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next v2 2/6] net: sched: introduce helper to identify gact trap action
Date: Tue,  6 Jun 2017 14:12:03 +0200
Message-ID: <20170606121207.2921-3-jiri@resnulli.us>
References: <20170606121207.2921-1-jiri@resnulli.us>
Cc: davem@davemloft.net, jhs@mojatatu.com, xiyou.wangcong@gmail.com,
        edumazet@google.com, alexander.h.duyck@intel.com,
        stephen@networkplumber.org, daniel@iogearbox.net,
        mlxsw@mellanox.com, andrew@lunn.ch
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wr0-f194.google.com ([209.85.128.194]:35247 "EHLO
        mail-wr0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751426AbdFFMMO (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 6 Jun 2017 08:12:14 -0400
Received: by mail-wr0-f194.google.com with SMTP id g76so10109619wrd.2
        for <netdev@vger.kernel.org>; Tue, 06 Jun 2017 05:12:13 -0700 (PDT)
In-Reply-To: <20170606121207.2921-1-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@mellanox.com>

Introduce a helper called is_tcf_gact_trap which could be used to
tell if the action is gact trap or not.

Signed-off-by: Jiri Pirko <jiri@mellanox.com>
Reviewed-by: Yotam Gigi <yotamg@mellanox.com>
---
 include/net/tc_act/tc_gact.h | 15 +++++++++++++--
 1 file changed, 13 insertions(+), 2 deletions(-)

diff --git a/include/net/tc_act/tc_gact.h b/include/net/tc_act/tc_gact.h
index b6f1739..d576374 100644
--- a/include/net/tc_act/tc_gact.h
+++ b/include/net/tc_act/tc_gact.h
@@ -15,7 +15,7 @@ struct tcf_gact {
 };
 #define to_gact(a) ((struct tcf_gact *)a)
 
-static inline bool is_tcf_gact_shot(const struct tc_action *a)
+static inline bool __is_tcf_gact_act(const struct tc_action *a, int act)
 {
 #ifdef CONFIG_NET_CLS_ACT
 	struct tcf_gact *gact;
@@ -24,10 +24,21 @@ static inline bool is_tcf_gact_shot(const struct tc_action *a)
 		return false;
 
 	gact = to_gact(a);
-	if (gact->tcf_action == TC_ACT_SHOT)
+	if (gact->tcf_action == act)
 		return true;
 
 #endif
 	return false;
 }
+
+static inline bool is_tcf_gact_shot(const struct tc_action *a)
+{
+	return __is_tcf_gact_act(a, TC_ACT_SHOT);
+}
+
+static inline bool is_tcf_gact_trap(const struct tc_action *a)
+{
+	return __is_tcf_gact_act(a, TC_ACT_TRAP);
+}
+
 #endif /* __NET_TC_GACT_H */
-- 
2.9.3
