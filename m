From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: [Patch net] net_sched: copy exts->type in tcf_exts_change()
Date: Mon,  6 Oct 2014 17:21:54 -0700
Message-ID: <1412641314-17335-1-git-send-email-xiyou.wangcong@gmail.com>
Cc: Cong Wang <xiyou.wangcong@gmail.com>,
	Jamal Hadi Salim <jhs@mojatatu.com>,
	John Fastabend <john.fastabend@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f53.google.com ([209.85.220.53]:42677 "EHLO
	mail-pa0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753045AbaJGAWK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 6 Oct 2014 20:22:10 -0400
Received: by mail-pa0-f53.google.com with SMTP id kq14so6177730pab.12
        for <netdev@vger.kernel.org>; Mon, 06 Oct 2014 17:22:10 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

We need to copy exts->type when committing the change, otherwise
it would be always 0. This is a quick fix for -net and -stable,
for net-next tcf_exts will be removed.

Fixes: commit 33be627159913b094bb578e83 ("net_sched: act: use standard struct list_head")
Reported-by: Jamal Hadi Salim <jhs@mojatatu.com>
Cc: Jamal Hadi Salim <jhs@mojatatu.com>
Cc: John Fastabend <john.fastabend@gmail.com>
Signed-off-by: Cong Wang <xiyou.wangcong@gmail.com>
---
 net/sched/cls_api.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/net/sched/cls_api.c b/net/sched/cls_api.c
index c28b0d3..4f4e08b 100644
--- a/net/sched/cls_api.c
+++ b/net/sched/cls_api.c
@@ -549,6 +549,7 @@ void tcf_exts_change(struct tcf_proto *tp, struct tcf_exts *dst,
 	tcf_tree_lock(tp);
 	list_splice_init(&dst->actions, &tmp);
 	list_splice(&src->actions, &dst->actions);
+	dst->type = src->type;
 	tcf_tree_unlock(tp);
 	tcf_action_destroy(&tmp, TCA_ACT_UNBIND);
 #endif
-- 
1.8.3.1
