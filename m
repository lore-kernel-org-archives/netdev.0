From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: [PATCH 1/4] Provide default lookup function for actions that dont provide one
Date: Sun,  1 Dec 2013 17:30:06 -0500
Message-ID: <1385937009-589-2-git-send-email-jhs@mojatatu.com>
References: <1385937009-589-1-git-send-email-jhs@mojatatu.com>
Cc: netdev@vger.kernel.org, eric.dumazet@gmail.com,
	alexander.h.duyck@intel.com, ebiederm@xmission.com,
	jhs@mojatatu.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f173.google.com ([209.85.223.173]:53640 "EHLO
	mail-ie0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751894Ab3LAWbu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 1 Dec 2013 17:31:50 -0500
Received: by mail-ie0-f173.google.com with SMTP id to1so18926151ieb.4
        for <netdev@vger.kernel.org>; Sun, 01 Dec 2013 14:31:50 -0800 (PST)
In-Reply-To: <1385937009-589-1-git-send-email-jhs@mojatatu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Jamal Hadi Salim <jhs@mojatatu.com>
---
 net/sched/act_api.c |    4 ++++
 1 file changed, 4 insertions(+)

diff --git a/net/sched/act_api.c b/net/sched/act_api.c
index fd70728..3c974a0 100644
--- a/net/sched/act_api.c
+++ b/net/sched/act_api.c
@@ -279,6 +279,10 @@ int tcf_register_action(struct tc_action_ops *act)
 	}
 	act->next = NULL;
 	*ap = act;
+
+	if (!act->lookup)
+		act->lookup = tcf_hash_search;
+
 	write_unlock(&act_mod_lock);
 	return 0;
 }
-- 
1.7.10.4
