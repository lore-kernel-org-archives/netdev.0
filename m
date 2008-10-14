From: Jarek Poplawski <jarkao2@gmail.com>
Subject: [PATCH 13/14] sch_hfsc: Remove remains of the old requeue code.
Date: Tue, 14 Oct 2008 09:55:31 +0000
Message-ID: <20081014095531.GN10804@ff.dom.local>
References: <fe92ba9380e7da89b674cc58fcb5bc1dae69e0c6.1223973003.git.jarkao2@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ug-out-1314.google.com ([66.249.92.170]:52657 "EHLO
	ug-out-1314.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755148AbYJNJzg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 14 Oct 2008 05:55:36 -0400
Received: by ug-out-1314.google.com with SMTP id k3so850192ugf.37
        for <netdev@vger.kernel.org>; Tue, 14 Oct 2008 02:55:35 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <fe92ba9380e7da89b674cc58fcb5bc1dae69e0c6.1223973003.git.jarkao2@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

sch_hfsc: Remove remains of the old requeue code.

Signed-off-by: Jarek Poplawski <jarkao2@gmail.com>
---
 net/sched/sch_hfsc.c |    7 -------
 1 files changed, 0 insertions(+), 7 deletions(-)

diff --git a/net/sched/sch_hfsc.c b/net/sched/sch_hfsc.c
index 53153ba..6c16741 100644
--- a/net/sched/sch_hfsc.c
+++ b/net/sched/sch_hfsc.c
@@ -184,7 +184,6 @@ struct hfsc_sched
 	struct rb_root eligible;		/* eligible tree */
 	struct list_head droplist;		/* active leaf class list (for
 						   dropping) */
-	struct sk_buff_head requeue;		/* requeued packet */
 	struct qdisc_watchdog watchdog;		/* watchdog timer */
 };
 
@@ -1435,7 +1434,6 @@ hfsc_init_qdisc(struct Qdisc *sch, struct nlattr *opt)
 		return err;
 	q->eligible = RB_ROOT;
 	INIT_LIST_HEAD(&q->droplist);
-	skb_queue_head_init(&q->requeue);
 
 	q->root.cl_common.classid = sch->handle;
 	q->root.refcnt  = 1;
@@ -1520,7 +1518,6 @@ hfsc_reset_qdisc(struct Qdisc *sch)
 		hlist_for_each_entry(cl, n, &q->clhash.hash[i], cl_common.hnode)
 			hfsc_reset_class(cl);
 	}
-	__skb_queue_purge(&q->requeue);
 	q->eligible = RB_ROOT;
 	INIT_LIST_HEAD(&q->droplist);
 	qdisc_watchdog_cancel(&q->watchdog);
@@ -1545,7 +1542,6 @@ hfsc_destroy_qdisc(struct Qdisc *sch)
 			hfsc_destroy_class(sch, cl);
 	}
 	qdisc_class_hash_destroy(&q->clhash);
-	__skb_queue_purge(&q->requeue);
 	qdisc_watchdog_cancel(&q->watchdog);
 }
 
@@ -1612,8 +1608,6 @@ hfsc_dequeue(struct Qdisc *sch)
 
 	if (sch->q.qlen == 0)
 		return NULL;
-	if ((skb = __skb_dequeue(&q->requeue)))
-		goto out;
 
 	cur_time = psched_get_time();
 
@@ -1662,7 +1656,6 @@ hfsc_dequeue(struct Qdisc *sch)
 		set_passive(cl);
 	}
 
- out:
 	sch->flags &= ~TCQ_F_THROTTLED;
 	sch->q.qlen--;
 
-- 
1.5.6.5

