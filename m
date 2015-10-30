From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: [Patch net-next v2 4/4] sch_dsmark: update backlog as well
Date: Fri, 30 Oct 2015 11:22:31 -0700
Message-ID: <1446229351-13412-5-git-send-email-xiyou.wangcong@gmail.com>
References: <1446229351-13412-1-git-send-email-xiyou.wangcong@gmail.com>
Cc: Cong Wang <xiyou.wangcong@gmail.com>,
	Jamal Hadi Salim <jhs@mojatatu.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f46.google.com ([209.85.220.46]:32914 "EHLO
	mail-pa0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758627AbbJ3SWs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 30 Oct 2015 14:22:48 -0400
Received: by padhy1 with SMTP id hy1so75198128pad.0
        for <netdev@vger.kernel.org>; Fri, 30 Oct 2015 11:22:47 -0700 (PDT)
In-Reply-To: <1446229351-13412-1-git-send-email-xiyou.wangcong@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Similarly, we need to update backlog too when we update qlen.

Cc: Jamal Hadi Salim <jhs@mojatatu.com>
Signed-off-by: Cong Wang <xiyou.wangcong@gmail.com>
---
 net/sched/sch_dsmark.c | 3 +++
 1 file changed, 3 insertions(+)

diff --git a/net/sched/sch_dsmark.c b/net/sched/sch_dsmark.c
index cfddb1c..d0dff0c 100644
--- a/net/sched/sch_dsmark.c
+++ b/net/sched/sch_dsmark.c
@@ -258,6 +258,7 @@ static int dsmark_enqueue(struct sk_buff *skb, struct Qdisc *sch)
 		return err;
 	}
 
+	qdisc_qstats_backlog_inc(sch, skb);
 	sch->q.qlen++;
 
 	return NET_XMIT_SUCCESS;
@@ -280,6 +281,7 @@ static struct sk_buff *dsmark_dequeue(struct Qdisc *sch)
 		return NULL;
 
 	qdisc_bstats_update(sch, skb);
+	qdisc_qstats_backlog_dec(sch, skb);
 	sch->q.qlen--;
 
 	index = skb->tc_index & (p->indices - 1);
@@ -395,6 +397,7 @@ static void dsmark_reset(struct Qdisc *sch)
 
 	pr_debug("%s(sch %p,[qdisc %p])\n", __func__, sch, p);
 	qdisc_reset(p->q);
+	sch->qstats.backlog = 0;
 	sch->q.qlen = 0;
 }
 
-- 
1.8.3.1
