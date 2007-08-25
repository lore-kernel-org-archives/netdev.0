From: Corey Hickey <bugfood-ml@fatooh.org>
Subject: [PATCH 03/10] Move two functions.
Date: Sat, 25 Aug 2007 15:26:57 -0700
Message-ID: <11880808261329-git-send-email-bugfood-ml@fatooh.org>
References: <11880808243166-git-send-email-bugfood-ml@fatooh.org>
Cc: Corey Hickey <bugfood-ml@fatooh.org>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from hot.fatooh.org ([208.78.103.127]:35059 "EHLO hot.fatooh.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757950AbXHYW1H (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 25 Aug 2007 18:27:07 -0400
In-Reply-To: <11880808243166-git-send-email-bugfood-ml@fatooh.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Move sfq_q_destroy() to above sfq_q_init() so that it can be used
by an error case in a later patch.

Move sfq_destroy() as well, for clarity.

Signed-off-by: Corey Hickey <bugfood-ml@fatooh.org>
---
 net/sched/sch_sfq.c |   22 +++++++++++-----------
 1 files changed, 11 insertions(+), 11 deletions(-)

diff --git a/net/sched/sch_sfq.c b/net/sched/sch_sfq.c
index f95a0dc..676195d 100644
--- a/net/sched/sch_sfq.c
+++ b/net/sched/sch_sfq.c
@@ -382,6 +382,17 @@ static void sfq_perturbation(unsigned long arg)
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
 static void
 sfq_default_parameters(struct Qdisc *sch)
 {
@@ -452,17 +463,6 @@ static int sfq_init(struct Qdisc *sch, struct rtattr *opt)
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

