From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: [RFC Patch net-next 3/6] net_sched: return NULL in tcf_hash_check()
Date: Thu,  1 Sep 2016 22:57:17 -0700
Message-ID: <1472795840-31901-4-git-send-email-xiyou.wangcong@gmail.com>
References: <1472795840-31901-1-git-send-email-xiyou.wangcong@gmail.com>
Cc: jhs@mojatatu.com, Cong Wang <xiyou.wangcong@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f196.google.com ([209.85.192.196]:34944 "EHLO
        mail-pf0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751734AbcIBF5s (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 2 Sep 2016 01:57:48 -0400
Received: by mail-pf0-f196.google.com with SMTP id h186so5342768pfg.2
        for <netdev@vger.kernel.org>; Thu, 01 Sep 2016 22:57:48 -0700 (PDT)
In-Reply-To: <1472795840-31901-1-git-send-email-xiyou.wangcong@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When we don't find an action with a specific index,
we only return false but not touch *a. It is nicer
if we could set *a to NULL here, this would make
callers easier to use these API's.

Cc: Jamal Hadi Salim <jhs@mojatatu.com>
Signed-off-by: Cong Wang <xiyou.wangcong@gmail.com>
---
 net/sched/act_api.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/net/sched/act_api.c b/net/sched/act_api.c
index db907e5..d0a7db2 100644
--- a/net/sched/act_api.c
+++ b/net/sched/act_api.c
@@ -230,6 +230,7 @@ bool tcf_hash_check(struct tc_action_net *tn, u32 index, struct tc_action **a,
 		*a = p;
 		return true;
 	}
+	*a = NULL;
 	return false;
 }
 EXPORT_SYMBOL(tcf_hash_check);
-- 
2.1.0
