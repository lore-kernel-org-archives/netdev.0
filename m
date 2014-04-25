From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: [Patch net-next] sched, act: allow to clear all actions as well
Date: Fri, 25 Apr 2014 13:55:30 -0700
Message-ID: <1398459330-15598-1-git-send-email-xiyou.wangcong@gmail.com>
Cc: Cong Wang <xiyou.wangcong@gmail.com>,
	Jamal Hadi Salim <jhs@mojatatu.com>,
	"David S. Miller" <davem@davemloft.net>,
	Cong Wang <cwang@twopensource.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f41.google.com ([209.85.160.41]:44193 "EHLO
	mail-pb0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754981AbaDYUzo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 25 Apr 2014 16:55:44 -0400
Received: by mail-pb0-f41.google.com with SMTP id rr13so3608578pbb.14
        for <netdev@vger.kernel.org>; Fri, 25 Apr 2014 13:55:44 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Cong Wang <cwang@twopensource.com>

When we change the list of action on a given filter, currently we don't
change it to empty. This is a bug, we should allow to change to whatever
users given.

Cc: Jamal Hadi Salim <jhs@mojatatu.com>
Cc: David S. Miller <davem@davemloft.net>
Signed-off-by: Cong Wang <xiyou.wangcong@gmail.com>
Signed-off-by: Cong Wang <cwang@twopensource.com>
---
 net/sched/cls_api.c | 14 ++++++--------
 1 file changed, 6 insertions(+), 8 deletions(-)

diff --git a/net/sched/cls_api.c b/net/sched/cls_api.c
index 6786130..a481bbe 100644
--- a/net/sched/cls_api.c
+++ b/net/sched/cls_api.c
@@ -544,14 +544,12 @@ void tcf_exts_change(struct tcf_proto *tp, struct tcf_exts *dst,
 		     struct tcf_exts *src)
 {
 #ifdef CONFIG_NET_CLS_ACT
-	if (!list_empty(&src->actions)) {
-		LIST_HEAD(tmp);
-		tcf_tree_lock(tp);
-		list_splice_init(&dst->actions, &tmp);
-		list_splice(&src->actions, &dst->actions);
-		tcf_tree_unlock(tp);
-		tcf_action_destroy(&tmp, TCA_ACT_UNBIND);
-	}
+	LIST_HEAD(tmp);
+	tcf_tree_lock(tp);
+	list_splice_init(&dst->actions, &tmp);
+	list_splice(&src->actions, &dst->actions);
+	tcf_tree_unlock(tp);
+	tcf_action_destroy(&tmp, TCA_ACT_UNBIND);
 #endif
 }
 EXPORT_SYMBOL(tcf_exts_change);
-- 
1.8.3.1
