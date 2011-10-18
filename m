From: "Yan, Zheng" <zheng.z.yan@intel.com>
Subject: [PATCH] fib_rules: fix unresolved_rules counting
Date: Tue, 18 Oct 2011 09:20:28 +0800
Message-ID: <4E9CD45C.9050608@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
To: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"davem@davemloft.net" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:42793 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752150Ab1JRBUa (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 17 Oct 2011 21:20:30 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

we should decrease ops->unresolved_rules when deleting a unresolved rule.

Signed-off-by: Zheng Yan <zheng.z.yan@intel.com>
---
diff --git a/net/core/fib_rules.c b/net/core/fib_rules.c
index 3231b46..27071ee 100644
--- a/net/core/fib_rules.c
+++ b/net/core/fib_rules.c
@@ -475,8 +475,11 @@ static int fib_nl_delrule(struct sk_buff *skb, struct nlmsghdr* nlh, void *arg)
 
 		list_del_rcu(&rule->list);
 
-		if (rule->action == FR_ACT_GOTO)
+		if (rule->action == FR_ACT_GOTO) {
 			ops->nr_goto_rules--;
+			if (rtnl_dereference(rule->ctarget) == NULL)
+				ops->unresolved_rules--;
+		}
 
 		/*
 		 * Check if this rule is a target to any of them. If so,
