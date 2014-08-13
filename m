From: Vasily Averin <vvs@parallels.com>
Subject: [PATCH 2/2] cbq: now_rt removal
Date: Wed, 13 Aug 2014 16:38:41 +0400
Message-ID: <53EB5C51.8060403@parallels.com>
References: <cover.1407918877.git.vvs@openvz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>
To: netdev@vger.kernel.org, Jamal Hadi Salim <jhs@mojatatu.com>,
	"David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailhub.sw.ru ([195.214.232.25]:15488 "EHLO relay.sw.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752223AbaHMMkT (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 13 Aug 2014 08:40:19 -0400
In-Reply-To: <cover.1407918877.git.vvs@openvz.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Now q->now_rt is identical to q->now and is not required anymore.

Signed-off-by: Vasily Averin <vvs@openvz.org>
---
 net/sched/sch_cbq.c |   11 +----------
 1 files changed, 1 insertions(+), 10 deletions(-)

diff --git a/net/sched/sch_cbq.c b/net/sched/sch_cbq.c
index 550be95..762a04b 100644
--- a/net/sched/sch_cbq.c
+++ b/net/sched/sch_cbq.c
@@ -159,7 +159,6 @@ struct cbq_sched_data {
 	struct cbq_class	*tx_borrowed;
 	int			tx_len;
 	psched_time_t		now;		/* Cached timestamp */
-	psched_time_t		now_rt;		/* Cached real time */
 	unsigned int		pmask;
 
 	struct hrtimer		delay_timer;
@@ -353,12 +352,7 @@ cbq_mark_toplevel(struct cbq_sched_data *q, struct cbq_class *cl)
 	int toplevel = q->toplevel;
 
 	if (toplevel > cl->level && !(qdisc_is_throttled(cl->q))) {
-		psched_time_t now;
-		psched_tdiff_t incr;
-
-		now = psched_get_time();
-		incr = now - q->now_rt;
-		now = q->now + incr;
+		psched_time_t now = psched_get_time();
 
 		do {
 			if (cl->undertime < now) {
@@ -956,7 +950,6 @@ cbq_dequeue(struct Qdisc *sch)
 		cbq_update(q);
 
 	q->now = now;
-	q->now_rt = now;
 
 	for (;;) {
 		q->wd_expires = 0;
@@ -1212,7 +1205,6 @@ cbq_reset(struct Qdisc *sch)
 	hrtimer_cancel(&q->delay_timer);
 	q->toplevel = TC_CBQ_MAXLEVEL;
 	q->now = psched_get_time();
-	q->now_rt = q->now;
 
 	for (prio = 0; prio <= TC_CBQ_MAXPRIO; prio++)
 		q->active[prio] = NULL;
@@ -1396,7 +1388,6 @@ static int cbq_init(struct Qdisc *sch, struct nlattr *opt)
 	q->delay_timer.function = cbq_undelay;
 	q->toplevel = TC_CBQ_MAXLEVEL;
 	q->now = psched_get_time();
-	q->now_rt = q->now;
 
 	cbq_link_class(&q->link);
 
-- 
1.7.1
