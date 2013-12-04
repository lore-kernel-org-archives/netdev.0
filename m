From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: [PATCH 2/5] net_sched: Default action lookup method for actions
Date: Wed,  4 Dec 2013 09:26:53 -0500
Message-ID: <1386167216-30281-3-git-send-email-jhs@mojatatu.com>
References: <1386167216-30281-1-git-send-email-jhs@mojatatu.com>
Cc: netdev@vger.kernel.org, eric.dumazet@gmail.com,
	alexander.h.duyck@intel.com, jhs@mojatatu.com,
	ebiederm@xmission.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f176.google.com ([209.85.223.176]:43284 "EHLO
	mail-ie0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932303Ab3LDO1j (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 Dec 2013 09:27:39 -0500
Received: by mail-ie0-f176.google.com with SMTP id at1so26954918iec.35
        for <netdev@vger.kernel.org>; Wed, 04 Dec 2013 06:27:38 -0800 (PST)
In-Reply-To: <1386167216-30281-1-git-send-email-jhs@mojatatu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Jamal Hadi Salim <jhs@mojatatu.com>
---
 net/sched/act_api.c |    5 +++--
 1 file changed, 3 insertions(+), 2 deletions(-)

diff --git a/net/sched/act_api.c b/net/sched/act_api.c
index 618695e..d1a022e 100644
--- a/net/sched/act_api.c
+++ b/net/sched/act_api.c
@@ -274,6 +274,9 @@ int tcf_register_action(struct tc_action_ops *act)
 	if (!act->act || !act->dump || !act->cleanup || !act->init)
 		return -EINVAL;
 
+	if (!act->lookup)
+		act->lookup = tcf_hash_search;
+
 	write_lock(&act_mod_lock);
 	for (ap = &act_base; (a = *ap) != NULL; ap = &a->next) {
 		if (act->type == a->type || (strcmp(act->kind, a->kind) == 0)) {
@@ -727,8 +730,6 @@ tcf_action_get_1(struct nlattr *nla, struct nlmsghdr *n, u32 portid)
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
