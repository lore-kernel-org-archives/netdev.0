From: Amnon Aaronsohn <bla@cs.huji.ac.il>
Subject: [PATCH] net: fix PRIO qdisc bands init
Date: Tue, 10 Jan 2006 12:30:15 +0200 (IST)
Message-ID: <Pine.LNX.4.56.0601101217290.1420@duke.cs.huji.ac.il>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1750863AbWAJKaU@vger.kernel.org>
To: netdev@vger.kernel.org
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The PRIO queuing discipline currently initializes only the bands
that appear in the priomap. It should instead initialize all the
configured bands.

Signed-off-by: Amnon Aaronsohn <bla@cs.huji.ac.il>

---

--- linux-2.6.14/net/sched/sch_prio.c	2005-10-28 02:02:08.000000000 +0200
+++ work-2.6.14/net/sched/sch_prio.c	2006-01-10 12:02:20.000000000 +0200
@@ -227,14 +227,13 @@ static int prio_tune(struct Qdisc *sch,
 	}
 	sch_tree_unlock(sch);

-	for (i=0; i<=TC_PRIO_MAX; i++) {
-		int band = q->prio2band[i];
-		if (q->queues[band] == &noop_qdisc) {
+	for (i=0; i<q->bands; i++) {
+		if (q->queues[i] == &noop_qdisc) {
 			struct Qdisc *child;
 			child = qdisc_create_dflt(sch->dev, &pfifo_qdisc_ops);
 			if (child) {
 				sch_tree_lock(sch);
-				child = xchg(&q->queues[band], child);
+				child = xchg(&q->queues[i], child);

 				if (child != &noop_qdisc)
 					qdisc_destroy(child);
