From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH] fq_codel: dont reinit flow state
Date: Sat, 01 Sep 2012 06:19:57 -0700
Message-ID: <1346505597.7996.76.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>, Dave Taht <dave.taht@gmail.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pz0-f46.google.com ([209.85.210.46]:40688 "EHLO
	mail-pz0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751849Ab2IANT7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 1 Sep 2012 09:19:59 -0400
Received: by dady13 with SMTP id y13so2602514dad.19
        for <netdev@vger.kernel.org>; Sat, 01 Sep 2012 06:19:59 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When fq_codel builds a new flow, it should not reset codel state.

Codel algo needs to get previous values (lastcount, drop_next) to get
proper behavior.

Signed-off-by: Dave Taht <dave.taht@gmail.com>
Signed-off-by: Eric Dumazet <edumazet@google.com>
---
 net/sched/sch_fq_codel.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/sched/sch_fq_codel.c b/net/sched/sch_fq_codel.c
index 9fc1c62..4e606fc 100644
--- a/net/sched/sch_fq_codel.c
+++ b/net/sched/sch_fq_codel.c
@@ -191,7 +191,6 @@ static int fq_codel_enqueue(struct sk_buff *skb, struct Qdisc *sch)
 
 	if (list_empty(&flow->flowchain)) {
 		list_add_tail(&flow->flowchain, &q->new_flows);
-		codel_vars_init(&flow->cvars);
 		q->new_flow_count++;
 		flow->deficit = q->quantum;
 		flow->dropped = 0;
@@ -418,6 +417,7 @@ static int fq_codel_init(struct Qdisc *sch, struct nlattr *opt)
 			struct fq_codel_flow *flow = q->flows + i;
 
 			INIT_LIST_HEAD(&flow->flowchain);
+			codel_vars_init(&flow->cvars);
 		}
 	}
 	if (sch->limit >= 1)
