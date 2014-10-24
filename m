From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: [Patch net 1/2] sch_pie: schedule the timer after all init succeed
Date: Fri, 24 Oct 2014 16:55:58 -0700
Message-ID: <1414194959-28006-1-git-send-email-xiyou.wangcong@gmail.com>
Cc: davem@davemloft.net, Cong Wang <xiyou.wangcong@gmail.com>,
	Vijay Subramanian <vijaynsu@cisco.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f43.google.com ([209.85.220.43]:39010 "EHLO
	mail-pa0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754757AbaJXX5I (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 24 Oct 2014 19:57:08 -0400
Received: by mail-pa0-f43.google.com with SMTP id eu11so2001294pac.16
        for <netdev@vger.kernel.org>; Fri, 24 Oct 2014 16:57:08 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Cc: Vijay Subramanian <vijaynsu@cisco.com>
Cc: David S. Miller <davem@davemloft.net>
Signed-off-by: Cong Wang <xiyou.wangcong@gmail.com>
---
 net/sched/sch_pie.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/sched/sch_pie.c b/net/sched/sch_pie.c
index 33d7a98..b783a44 100644
--- a/net/sched/sch_pie.c
+++ b/net/sched/sch_pie.c
@@ -445,7 +445,6 @@ static int pie_init(struct Qdisc *sch, struct nlattr *opt)
 	sch->limit = q->params.limit;
 
 	setup_timer(&q->adapt_timer, pie_timer, (unsigned long)sch);
-	mod_timer(&q->adapt_timer, jiffies + HZ / 2);
 
 	if (opt) {
 		int err = pie_change(sch, opt);
@@ -454,6 +453,7 @@ static int pie_init(struct Qdisc *sch, struct nlattr *opt)
 			return err;
 	}
 
+	mod_timer(&q->adapt_timer, jiffies + HZ / 2);
 	return 0;
 }
 
-- 
1.8.3.1
