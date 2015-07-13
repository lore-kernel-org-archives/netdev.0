From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: [Patch net] fq_codel: fix a use-after-free
Date: Mon, 13 Jul 2015 12:30:07 -0700
Message-ID: <1436815807-25359-1-git-send-email-xiyou.wangcong@gmail.com>
Cc: Cong Wang <xiyou.wangcong@gmail.com>,
	John Fastabend <john.fastabend@gmail.com>,
	Cong Wang <cwang@twopensource.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f48.google.com ([209.85.220.48]:34864 "EHLO
	mail-pa0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752666AbbGMTa0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 13 Jul 2015 15:30:26 -0400
Received: by pactm7 with SMTP id tm7so212130756pac.2
        for <netdev@vger.kernel.org>; Mon, 13 Jul 2015 12:30:23 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Fixes: 25331d6ce42b ("net: sched: implement qstat helper routines")
Cc: John Fastabend <john.fastabend@gmail.com>
Signed-off-by: Cong Wang <xiyou.wangcong@gmail.com>
Signed-off-by: Cong Wang <cwang@twopensource.com>
---
 net/sched/sch_fq_codel.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/sched/sch_fq_codel.c b/net/sched/sch_fq_codel.c
index d75993f..06e7c84 100644
--- a/net/sched/sch_fq_codel.c
+++ b/net/sched/sch_fq_codel.c
@@ -155,10 +155,10 @@ static unsigned int fq_codel_drop(struct Qdisc *sch)
 	skb = dequeue_head(flow);
 	len = qdisc_pkt_len(skb);
 	q->backlogs[idx] -= len;
-	kfree_skb(skb);
 	sch->q.qlen--;
 	qdisc_qstats_drop(sch);
 	qdisc_qstats_backlog_dec(sch, skb);
+	kfree_skb(skb);
 	flow->dropped++;
 	return idx;
 }
-- 
1.8.3.1
