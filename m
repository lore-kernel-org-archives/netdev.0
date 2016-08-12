From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: [Patch net v3 2/5] net_sched: remove an unnecessary list_del()
Date: Thu, 11 Aug 2016 17:41:40 -0700
Message-ID: <1470962503-19682-3-git-send-email-xiyou.wangcong@gmail.com>
References: <1470962503-19682-1-git-send-email-xiyou.wangcong@gmail.com>
Cc: Cong Wang <xiyou.wangcong@gmail.com>,
	Jamal Hadi Salim <jhs@mojatatu.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f68.google.com ([209.85.220.68]:36704 "EHLO
	mail-pa0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751143AbcHLAny (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Aug 2016 20:43:54 -0400
Received: by mail-pa0-f68.google.com with SMTP id ez1so533677pab.3
        for <netdev@vger.kernel.org>; Thu, 11 Aug 2016 17:43:54 -0700 (PDT)
In-Reply-To: <1470962503-19682-1-git-send-email-xiyou.wangcong@gmail.com>
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
1.8.4.5
