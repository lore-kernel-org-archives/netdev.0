From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net] fq_codel: return non zero qlen in class dumps
Date: Mon, 06 Jun 2016 09:12:39 -0700
Message-ID: <1465229559.2968.75.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
	John Fastabend <john.r.fastabend@intel.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f195.google.com ([209.85.192.195]:35118 "EHLO
	mail-pf0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751631AbcFFQMq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 6 Jun 2016 12:12:46 -0400
Received: by mail-pf0-f195.google.com with SMTP id z187so3951187pfz.2
        for <netdev@vger.kernel.org>; Mon, 06 Jun 2016 09:12:46 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

We properly scan the flow list to count number of packets,
but John passed 0 to gnet_stats_copy_queue() so we report
a zero value to user space instead of the result.

Fixes: 640158536632 ("net: sched: restrict use of qstats qlen")
Signed-off-by: Eric Dumazet <edumazet@google.com>
Cc: John Fastabend <john.r.fastabend@intel.com>
---
 net/sched/sch_fq_codel.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/sched/sch_fq_codel.c b/net/sched/sch_fq_codel.c
index 6883a8971562..7a280360aeed 100644
--- a/net/sched/sch_fq_codel.c
+++ b/net/sched/sch_fq_codel.c
@@ -649,7 +649,7 @@ static int fq_codel_dump_class_stats(struct Qdisc *sch, unsigned long cl,
 		qs.backlog = q->backlogs[idx];
 		qs.drops = flow->dropped;
 	}
-	if (gnet_stats_copy_queue(d, NULL, &qs, 0) < 0)
+	if (gnet_stats_copy_queue(d, NULL, &qs, qs.qlen) < 0)
 		return -1;
 	if (idx < q->flows_cnt)
 		return gnet_stats_copy_app(d, &xstats, sizeof(xstats));
