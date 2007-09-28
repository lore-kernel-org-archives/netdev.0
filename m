From: Corey Hickey <bugfood-ml@fatooh.org>
Subject: [PATCH 03/10] Move two functions.
Date: Fri, 28 Sep 2007 15:52:50 -0700
Message-ID: <1191019977559-git-send-email-bugfood-ml@fatooh.org>
References: <1191019977201-git-send-email-bugfood-ml@fatooh.org>
Cc: Corey Hickey <bugfood-ml@fatooh.org>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from hot.fatooh.org ([208.78.103.127]:42849 "EHLO hot.fatooh.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754026AbXI1WxG (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 28 Sep 2007 18:53:06 -0400
In-Reply-To: <1191019977201-git-send-email-bugfood-ml@fatooh.org>
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
index 1ba3d1a..ca22cb7 100644
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
@@ -451,17 +462,6 @@ static int sfq_init(struct Qdisc *sch, struct rtattr *opt)
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
1.5.3

