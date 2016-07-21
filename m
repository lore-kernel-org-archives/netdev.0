From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next v2 8/9] net/sched: act_mirred: Add helper inlines to access tcf_mirred info.
Date: Thu, 21 Jul 2016 12:03:16 +0200
Message-ID: <1469095397-3837-9-git-send-email-jiri@resnulli.us>
References: <1469095397-3837-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, yotamg@mellanox.com, eladr@mellanox.com,
	idosch@mellanox.com, nogahf@mellanox.com, ogerlitz@mellanox.com,
	jhs@mojatatu.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f68.google.com ([74.125.82.68]:33702 "EHLO
	mail-wm0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751882AbcGUKDd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 21 Jul 2016 06:03:33 -0400
Received: by mail-wm0-f68.google.com with SMTP id o80so1964897wme.0
        for <netdev@vger.kernel.org>; Thu, 21 Jul 2016 03:03:32 -0700 (PDT)
In-Reply-To: <1469095397-3837-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Yotam Gigi <yotamg@mellanox.com>

The helper function is_tcf_mirred_mirror helps finding whether an action
struct is of type mirred and is configured to be of type mirror.

Signed-off-by: Yotam Gigi <yotamg@mellanox.com>
Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 include/net/tc_act/tc_mirred.h | 9 +++++++++
 1 file changed, 9 insertions(+)

diff --git a/include/net/tc_act/tc_mirred.h b/include/net/tc_act/tc_mirred.h
index e891835..6a13a7c 100644
--- a/include/net/tc_act/tc_mirred.h
+++ b/include/net/tc_act/tc_mirred.h
@@ -24,6 +24,15 @@ static inline bool is_tcf_mirred_redirect(const struct tc_action *a)
 	return false;
 }
 
+static inline bool is_tcf_mirred_mirror(const struct tc_action *a)
+{
+#ifdef CONFIG_NET_CLS_ACT
+	if (a->ops && a->ops->type == TCA_ACT_MIRRED)
+		return to_mirred(a)->tcfm_eaction == TCA_EGRESS_MIRROR;
+#endif
+	return false;
+}
+
 static inline int tcf_mirred_ifindex(const struct tc_action *a)
 {
 	return to_mirred(a)->tcfm_ifindex;
-- 
2.5.5
