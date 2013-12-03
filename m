From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: [PATCH 1/5] net_sched: Default action lookup method for actions
Date: Tue,  3 Dec 2013 09:23:15 -0500
Message-ID: <1386080600-4067-2-git-send-email-jhs@mojatatu.com>
References: <1386080600-4067-1-git-send-email-jhs@mojatatu.com>
Cc: netdev@vger.kernel.org, eric.dumazet@gmail.com,
	alexander.h.duyck@intel.com, jhs@mojatatu.com,
	ebiederm@xmission.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f182.google.com ([209.85.223.182]:53887 "EHLO
	mail-ie0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753545Ab3LCOYW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Dec 2013 09:24:22 -0500
Received: by mail-ie0-f182.google.com with SMTP id as1so24119214iec.13
        for <netdev@vger.kernel.org>; Tue, 03 Dec 2013 06:24:22 -0800 (PST)
In-Reply-To: <1386080600-4067-1-git-send-email-jhs@mojatatu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Jamal Hadi Salim <jhs@mojatatu.com>
---
 net/sched/act_api.c |    6 ++++--
 1 file changed, 4 insertions(+), 2 deletions(-)

diff --git a/net/sched/act_api.c b/net/sched/act_api.c
index fd70728..053a115 100644
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
@@ -723,8 +727,6 @@ tcf_action_get_1(struct nlattr *nla, struct nlmsghdr *n, u32 portid)
 	a->ops = tc_lookup_action(tb[TCA_ACT_KIND]);
 	if (a->ops == NULL)
 		goto err_free;
-	if (a->ops->lookup == NULL)
-		goto err_mod;
 	err = -ENOENT;
 	if (a->ops->lookup(a, index) == 0)
 		goto err_mod;
-- 
1.7.10.4
