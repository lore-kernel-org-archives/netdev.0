From: Andrea Parri <parri.andrea@gmail.com>
Subject: [PATCH] pkt_sched: sch_qfq: remove redundant -if- control statement
Date: Mon, 15 Jun 2015 14:20:01 +0200
Message-ID: <20150615122001.GA5600@andrea>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: paolo.valente@unimore.it, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: jhs@mojatatu.com, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f173.google.com ([209.85.212.173]:33728 "EHLO
	mail-wi0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753292AbbFOMUK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 15 Jun 2015 08:20:10 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


The control !hlist_unhashed() in qfq_destroy_agg() is unnecessary
because already performed in hlist_del_init(), so remove it.

Signed-off-by: Andrea Parri <parri.andrea@gmail.com>
---
 net/sched/sch_qfq.c | 3 +--
 1 file changed, 1 insertion(+), 2 deletions(-)

diff --git a/net/sched/sch_qfq.c b/net/sched/sch_qfq.c
index 3ec7e88..b8d73bc 100644
--- a/net/sched/sch_qfq.c
+++ b/net/sched/sch_qfq.c
@@ -339,8 +339,7 @@ static struct qfq_aggregate *qfq_choose_next_agg(struct qfq_sched *);
 
 static void qfq_destroy_agg(struct qfq_sched *q, struct qfq_aggregate *agg)
 {
-       if (!hlist_unhashed(&agg->nonfull_next))
-               hlist_del_init(&agg->nonfull_next);
+       hlist_del_init(&agg->nonfull_next);
        q->wsum -= agg->class_weight;
        if (q->wsum != 0)
                q->iwsum = ONE_FP / q->wsum;
