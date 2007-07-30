From: Corey Hickey <bugfood-ml@fatooh.org>
Subject: [PATCH 3/7] Move two functions.
Date: Sun, 29 Jul 2007 17:21:12 -0700
Message-ID: <11857548782786-git-send-email-bugfood-ml@fatooh.org>
References: <11857548771998-git-send-email-bugfood-ml@fatooh.org>
Cc: Corey Hickey <bugfood-ml@fatooh.org>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from hot.fatooh.org ([208.78.103.127]:37088 "EHLO hot.fatooh.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750751AbXG3AVW (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 29 Jul 2007 20:21:22 -0400
In-Reply-To: <11857548771998-git-send-email-bugfood-ml@fatooh.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Move sfq_q_destroy() to above sfq_q_init() so that it can be used
by an error case in a later patch.

Move sfq_destroy() as well, for clarity.

Signed-off-by: Corey Hickey <bugfood-ml@fatooh.org>
---
 net/sched/sch_sfq.c |   24 ++++++++++++------------
 1 files changed, 12 insertions(+), 12 deletions(-)

diff --git a/net/sched/sch_sfq.c b/net/sched/sch_sfq.c
index 0c46938..583f925 100644
--- a/net/sched/sch_sfq.c
+++ b/net/sched/sch_sfq.c
@@ -380,6 +380,17 @@ static void sfq_perturbation(unsigned long arg)
 	}
 }
 
+static void sfq_q_destroy(struct sfq_sched_data *q)
+{
+	del_timer(&q->perturb_timer);
+}
+
+static void sfq_destroy(struct Qdisc *sch)
+{
+	struct sfq_sched_data *q = qdisc_priv(sch);
+	sfq_q_destroy(q);
+}
+
 static int sfq_q_init(struct sfq_sched_data *q, struct rtattr *opt)
 {
 	struct tc_sfq_qopt *ctl = RTA_DATA(opt);
@@ -420,7 +431,7 @@ static int sfq_init(struct Qdisc *sch, struct rtattr *opt)
 {
 	struct sfq_sched_data *q = qdisc_priv(sch);
 	int err;
-	
+
 	q->quantum = psched_mtu(sch->dev); /* default */
 	if ((err = sfq_q_init(q, opt)))
 		return err;
@@ -436,17 +447,6 @@ static int sfq_init(struct Qdisc *sch, struct rtattr *opt)
 	return 0;
 }
 
-static void sfq_q_destroy(struct sfq_sched_data *q)
-{
-	del_timer(&q->perturb_timer);
-}
-
-static void sfq_destroy(struct Qdisc *sch)
-{
-	struct sfq_sched_data *q = qdisc_priv(sch);
-	sfq_q_destroy(q);
-}
-
 static int sfq_dump(struct Qdisc *sch, struct sk_buff *skb)
 {
 	struct sfq_sched_data *q = qdisc_priv(sch);
-- 
1.5.2.4

