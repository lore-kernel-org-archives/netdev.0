From: Jarek Poplawski <jarkao2@o2.pl>
Subject: [PATCH][NET_SCHED] sch_prio: class statistics printing enabled
Date: Wed, 31 Jan 2007 08:53:49 +0100
Message-ID: <20070131075348.GA1857@ff.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from poczta.o2.pl ([193.17.41.142]:52164 "EHLO poczta.o2.pl"
	rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1750937AbXAaHvI (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 31 Jan 2007 02:51:08 -0500
Received: from poczta.o2.pl (mx12 [127.0.0.1])
	by poczta.o2.pl (Postfix) with ESMTP id ED2D562807D
	for <netdev@vger.kernel.org>; Wed, 31 Jan 2007 08:51:06 +0100 (CET)
Received: from ff.dom.local (bv170.internetdsl.tpnet.pl [80.53.205.170])
	by poczta.o2.pl (Postfix) with ESMTP
	for <netdev@vger.kernel.org>; Wed, 31 Jan 2007 08:51:06 +0100 (CET)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello,

This patch adds a dump_stats callback to enable
printing of basic statistics of prio classes.

Signed-off-by: Jarek Poplawski <jarkao2@o2.pl>

---

diff -Nurp linux-2.6.20-rc6-/net/sched/sch_prio.c linux-2.6.20-rc6/net/sched/sch_prio.c
--- linux-2.6.20-rc6-/net/sched/sch_prio.c	2007-01-08 20:23:58.000000000 +0100
+++ linux-2.6.20-rc6/net/sched/sch_prio.c	2007-01-30 20:26:31.000000000 +0100
@@ -372,6 +372,23 @@ static int prio_dump_class(struct Qdisc 
 	return 0;
 }
 
+static int prio_dump_class_stats(struct Qdisc *sch, unsigned long cl,
+							struct gnet_dump *d)
+{
+	struct prio_sched_data *q = qdisc_priv(sch);
+	struct Qdisc *cl_q;
+
+	if (cl - 1 > q->bands)
+		return -ENOENT;
+
+	cl_q = q->queues[cl - 1];
+	if (gnet_stats_copy_basic(d, &cl_q->bstats) < 0 ||
+	    gnet_stats_copy_queue(d, &cl_q->qstats) < 0)
+		return -1;
+
+	return 0;
+}
+
 static void prio_walk(struct Qdisc *sch, struct qdisc_walker *arg)
 {
 	struct prio_sched_data *q = qdisc_priv(sch);
@@ -414,6 +431,7 @@ static struct Qdisc_class_ops prio_class
 	.bind_tcf	=	prio_bind,
 	.unbind_tcf	=	prio_put,
 	.dump		=	prio_dump_class,
+	.dump_stats	=	prio_dump_class_stats,
 };
 
 static struct Qdisc_ops prio_qdisc_ops = {
