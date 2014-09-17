From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next] net: sched: use __skb_queue_head_init() where
 applicable
Date: Wed, 17 Sep 2014 08:05:05 -0700
Message-ID: <1410966305.7106.238.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f42.google.com ([209.85.220.42]:57734 "EHLO
	mail-pa0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755268AbaIQPFH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 17 Sep 2014 11:05:07 -0400
Received: by mail-pa0-f42.google.com with SMTP id lj1so2323611pab.15
        for <netdev@vger.kernel.org>; Wed, 17 Sep 2014 08:05:07 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

pfifo_fast and htb use skb lists, without needing their spinlocks.
(They instead use the standard qdisc lock)

We can use __skb_queue_head_init() instead of skb_queue_head_init()
to be consistent.

Signed-off-by: Eric Dumazet <edumazet@google.com>
---
 net/sched/sch_generic.c |    2 +-
 net/sched/sch_htb.c     |    2 +-
 2 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/sched/sch_generic.c b/net/sched/sch_generic.c
index 346ef85617d3..11b28f651ad1 100644
--- a/net/sched/sch_generic.c
+++ b/net/sched/sch_generic.c
@@ -523,7 +523,7 @@ static int pfifo_fast_init(struct Qdisc *qdisc, struct nlattr *opt)
 	struct pfifo_fast_priv *priv = qdisc_priv(qdisc);
 
 	for (prio = 0; prio < PFIFO_FAST_BANDS; prio++)
-		skb_queue_head_init(band2list(priv, prio));
+		__skb_queue_head_init(band2list(priv, prio));
 
 	/* Can by-pass the queue discipline */
 	qdisc->flags |= TCQ_F_CAN_BYPASS;
diff --git a/net/sched/sch_htb.c b/net/sched/sch_htb.c
index 6d16b9b81c28..14408f262143 100644
--- a/net/sched/sch_htb.c
+++ b/net/sched/sch_htb.c
@@ -1044,7 +1044,7 @@ static int htb_init(struct Qdisc *sch, struct nlattr *opt)
 
 	qdisc_watchdog_init(&q->watchdog, sch);
 	INIT_WORK(&q->work, htb_work_func);
-	skb_queue_head_init(&q->direct_queue);
+	__skb_queue_head_init(&q->direct_queue);
 
 	if (tb[TCA_HTB_DIRECT_QLEN])
 		q->direct_qlen = nla_get_u32(tb[TCA_HTB_DIRECT_QLEN]);
