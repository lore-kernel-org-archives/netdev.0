From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: [Patch net v2 2/5] net_sched: remove an unnecessary list_del()
Date: Wed, 10 Aug 2016 13:16:12 -0700
Message-ID: <1470860175-10903-3-git-send-email-xiyou.wangcong@gmail.com>
References: <1470860175-10903-1-git-send-email-xiyou.wangcong@gmail.com>
Cc: Cong Wang <xiyou.wangcong@gmail.com>,
	Jamal Hadi Salim <jhs@mojatatu.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f193.google.com ([209.85.192.193]:35874 "EHLO
	mail-pf0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S934388AbcHJUQe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 10 Aug 2016 16:16:34 -0400
Received: by mail-pf0-f193.google.com with SMTP id y134so3360493pfg.3
        for <netdev@vger.kernel.org>; Wed, 10 Aug 2016 13:16:34 -0700 (PDT)
In-Reply-To: <1470860175-10903-1-git-send-email-xiyou.wangcong@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This list_del() for tc action is not needed actually,
because we only use this list to chain bulk operations,
therefore should not be carried for latter operations.

Fixes: ec0595cc4495 ("net_sched: get rid of struct tcf_common")
Cc: Jamal Hadi Salim <jhs@mojatatu.com>
Signed-off-by: Cong Wang <xiyou.wangcong@gmail.com>
---
 net/sched/act_api.c | 1 -
 1 file changed, 1 deletion(-)

diff --git a/net/sched/act_api.c b/net/sched/act_api.c
index cce6986..b4c7be3 100644
--- a/net/sched/act_api.c
+++ b/net/sched/act_api.c
@@ -64,7 +64,6 @@ int __tcf_hash_release(struct tc_action *p, bool bind, bool strict)
 		if (p->tcfa_bindcnt <= 0 && p->tcfa_refcnt <= 0) {
 			if (p->ops->cleanup)
 				p->ops->cleanup(p, bind);
-			list_del(&p->list);
 			tcf_hash_destroy(p->hinfo, p);
 			ret = ACT_P_DELETED;
 		}
-- 
2.1.0
