From: Jarek Poplawski <jarkao2@o2.pl>
Subject: [PATCH][NET_SCHED] sch_prio: class statistics printing enabled
Date: Wed, 31 Jan 2007 16:22:45 +0100
Message-ID: <20070131152245.GB3811@ff.dom.local>
References: <20070131075348.GA1857@ff.dom.local> <45C09E0B.6020107@trash.net> <20070131143522.GB3521@ff.dom.local> <45C0A9A5.4080607@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx10.go2.pl ([193.17.41.74]:33436 "EHLO poczta.o2.pl"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S965398AbXAaPUE (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 31 Jan 2007 10:20:04 -0500
Content-Disposition: inline
In-Reply-To: <45C0A9A5.4080607@trash.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

(Take 3)

This patch adds a dump_stats callback to enable
printing of basic statistics of prio classes.
(With help of Patrick McHardy).

Signed-off-by: Jarek Poplawski <jarkao2@o2.pl>

---

diff -Nurp linux-2.6.20-rc6-/net/sched/sch_prio.c linux-2.6.20-rc6/net/sched/sch_prio.c
--- linux-2.6.20-rc6-/net/sched/sch_prio.c	2007-01-08 20:23:58.000000000 +0100
+++ linux-2.6.20-rc6/net/sched/sch_prio.c	2007-01-31 16:08:20.000000000 +0100
@@ -372,6 +372,20 @@ static int prio_dump_class(struct Qdisc 
 	return 0;
 }
 
+static int prio_dump_class_stats(struct Qdisc *sch, unsigned long cl,
+				 struct gnet_dump *d)
+{
+	struct prio_sched_data *q = qdisc_priv(sch);
+	struct Qdisc *cl_q;
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
@@ -414,6 +428,7 @@ static struct Qdisc_class_ops prio_class
 	.bind_tcf	=	prio_bind,
 	.unbind_tcf	=	prio_put,
 	.dump		=	prio_dump_class,
+	.dump_stats	=	prio_dump_class_stats,
 };
 
 static struct Qdisc_ops prio_qdisc_ops = {
