From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: [Patch net] sch_sfb: keep backlog updated with qlen
Date: Sun, 18 Sep 2016 16:22:48 -0700
Message-ID: <1474240968-15202-2-git-send-email-xiyou.wangcong@gmail.com>
References: <1474240968-15202-1-git-send-email-xiyou.wangcong@gmail.com>
Cc: Cong Wang <xiyou.wangcong@gmail.com>,
        Jamal Hadi Salim <jhs@mojatatu.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f193.google.com ([209.85.192.193]:35965 "EHLO
        mail-pf0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932595AbcIRXW4 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 18 Sep 2016 19:22:56 -0400
Received: by mail-pf0-f193.google.com with SMTP id n24so6319659pfb.3
        for <netdev@vger.kernel.org>; Sun, 18 Sep 2016 16:22:56 -0700 (PDT)
In-Reply-To: <1474240968-15202-1-git-send-email-xiyou.wangcong@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Fixes: 2ccccf5fb43f ("net_sched: update hierarchical backlog too")
Cc: Jamal Hadi Salim <jhs@mojatatu.com>
Signed-off-by: Cong Wang <xiyou.wangcong@gmail.com>
---
 net/sched/sch_sfb.c | 3 +++
 1 file changed, 3 insertions(+)

diff --git a/net/sched/sch_sfb.c b/net/sched/sch_sfb.c
index add3cc7..20a350b 100644
--- a/net/sched/sch_sfb.c
+++ b/net/sched/sch_sfb.c
@@ -400,6 +400,7 @@ static int sfb_enqueue(struct sk_buff *skb, struct Qdisc *sch,
 enqueue:
 	ret = qdisc_enqueue(skb, child, to_free);
 	if (likely(ret == NET_XMIT_SUCCESS)) {
+		qdisc_qstats_backlog_inc(sch, skb);
 		sch->q.qlen++;
 		increment_qlen(skb, q);
 	} else if (net_xmit_drop_count(ret)) {
@@ -428,6 +429,7 @@ static struct sk_buff *sfb_dequeue(struct Qdisc *sch)
 
 	if (skb) {
 		qdisc_bstats_update(sch, skb);
+		qdisc_qstats_backlog_dec(sch, skb);
 		sch->q.qlen--;
 		decrement_qlen(skb, q);
 	}
@@ -450,6 +452,7 @@ static void sfb_reset(struct Qdisc *sch)
 	struct sfb_sched_data *q = qdisc_priv(sch);
 
 	qdisc_reset(q->qdisc);
+	sch->qstats.backlog = 0;
 	sch->q.qlen = 0;
 	q->slot = 0;
 	q->double_buffering = false;
-- 
2.1.0
