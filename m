From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: [Patch net] net_sched: fix a use-after-free in sfq
Date: Tue, 14 Jul 2015 11:21:57 -0700
Message-ID: <1436898118-30804-1-git-send-email-xiyou.wangcong@gmail.com>
Cc: Cong Wang <xiyou.wangcong@gmail.com>,
	John Fastabend <john.fastabend@gmail.com>,
	Cong Wang <cwang@twopensource.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f48.google.com ([209.85.220.48]:34648 "EHLO
	mail-pa0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752125AbbGNSWX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 14 Jul 2015 14:22:23 -0400
Received: by pacan13 with SMTP id an13so9632398pac.1
        for <netdev@vger.kernel.org>; Tue, 14 Jul 2015 11:22:23 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Fixes: 25331d6ce42b ("net: sched: implement qstat helper routines")
Cc: John Fastabend <john.fastabend@gmail.com>
Signed-off-by: Cong Wang <xiyou.wangcong@gmail.com>
Signed-off-by: Cong Wang <cwang@twopensource.com>
---
 net/sched/sch_sfq.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/sched/sch_sfq.c b/net/sched/sch_sfq.c
index 7d14926..52f75a5 100644
--- a/net/sched/sch_sfq.c
+++ b/net/sched/sch_sfq.c
@@ -306,10 +306,10 @@ static unsigned int sfq_drop(struct Qdisc *sch)
 		len = qdisc_pkt_len(skb);
 		slot->backlog -= len;
 		sfq_dec(q, x);
-		kfree_skb(skb);
 		sch->q.qlen--;
 		qdisc_qstats_drop(sch);
 		qdisc_qstats_backlog_dec(sch, skb);
+		kfree_skb(skb);
 		return len;
 	}
 
-- 
1.8.3.1
