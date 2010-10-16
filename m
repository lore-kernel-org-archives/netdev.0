From: Changli Gao <xiaosuo@gmail.com>
Subject: [PATCH] net_sched: remove the unused parameter of qdisc_create_dflt()
Date: Sun, 17 Oct 2010 07:04:08 +0800
Message-ID: <1287270248-13190-1-git-send-email-xiaosuo@gmail.com>
Cc: Jamal Hadi Salim <hadi@cyberus.ca>,
	Stephen Hemminger <shemminger@linux-foundation.org>,
	netdev@vger.kernel.org, netem@lists.linux-foundation.org,
	Changli Gao <xiaosuo@gmail.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pv0-f174.google.com ([74.125.83.174]:44700 "EHLO
	mail-pv0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755169Ab0JQI2f (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 17 Oct 2010 04:28:35 -0400
Received: by pva18 with SMTP id 18so172774pva.19
        for <netdev@vger.kernel.org>; Sun, 17 Oct 2010 01:28:35 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The first parameter dev isn't in use in qdisc_create_dflt().

Signed-off-by: Changli Gao <xiaosuo@gmail.com>
---
 include/net/sch_generic.h |    3 +--
 net/sched/sch_atm.c       |    5 ++---
 net/sched/sch_cbq.c       |   12 ++++++------
 net/sched/sch_drr.c       |    4 ++--
 net/sched/sch_dsmark.c    |    6 ++----
 net/sched/sch_fifo.c      |    3 +--
 net/sched/sch_generic.c   |   10 ++++------
 net/sched/sch_hfsc.c      |    8 +++-----
 net/sched/sch_htb.c       |    8 +++-----
 net/sched/sch_mq.c        |    2 +-
 net/sched/sch_multiq.c    |    3 +--
 net/sched/sch_netem.c     |    3 +--
 net/sched/sch_prio.c      |    2 +-
 13 files changed, 28 insertions(+), 41 deletions(-)
diff --git a/include/net/sch_generic.h b/include/net/sch_generic.h
index eda8808..ea1f8a8 100644
--- a/include/net/sch_generic.h
+++ b/include/net/sch_generic.h
@@ -328,8 +328,7 @@ extern void qdisc_destroy(struct Qdisc *qdisc);
 extern void qdisc_tree_decrease_qlen(struct Qdisc *qdisc, unsigned int n);
 extern struct Qdisc *qdisc_alloc(struct netdev_queue *dev_queue,
 				 struct Qdisc_ops *ops);
-extern struct Qdisc *qdisc_create_dflt(struct net_device *dev,
-				       struct netdev_queue *dev_queue,
+extern struct Qdisc *qdisc_create_dflt(struct netdev_queue *dev_queue,
 				       struct Qdisc_ops *ops, u32 parentid);
 extern void qdisc_calculate_pkt_len(struct sk_buff *skb,
 				   struct qdisc_size_table *stab);
diff --git a/net/sched/sch_atm.c b/net/sched/sch_atm.c
index 6318e11..2825407 100644
--- a/net/sched/sch_atm.c
+++ b/net/sched/sch_atm.c
@@ -275,8 +275,7 @@ static int atm_tc_change(struct Qdisc *sch, u32 classid, u32 parent,
 		goto err_out;
 	}
 	flow->filter_list = NULL;
-	flow->q = qdisc_create_dflt(qdisc_dev(sch), sch->dev_queue,
-				    &pfifo_qdisc_ops, classid);
+	flow->q = qdisc_create_dflt(sch->dev_queue, &pfifo_qdisc_ops, classid);
 	if (!flow->q)
 		flow->q = &noop_qdisc;
 	pr_debug("atm_tc_change: qdisc %p\n", flow->q);
@@ -543,7 +542,7 @@ static int atm_tc_init(struct Qdisc *sch, struct nlattr *opt)
 	INIT_LIST_HEAD(&p->flows);
 	INIT_LIST_HEAD(&p->link.list);
 	list_add(&p->link.list, &p->flows);
-	p->link.q = qdisc_create_dflt(qdisc_dev(sch), sch->dev_queue,
+	p->link.q = qdisc_create_dflt(sch->dev_queue,
 				      &pfifo_qdisc_ops, sch->handle);
 	if (!p->link.q)
 		p->link.q = &noop_qdisc;
diff --git a/net/sched/sch_cbq.c b/net/sched/sch_cbq.c
index 28c01ef..eb76315 100644
--- a/net/sched/sch_cbq.c
+++ b/net/sched/sch_cbq.c
@@ -1379,9 +1379,9 @@ static int cbq_init(struct Qdisc *sch, struct nlattr *opt)
 	q->link.sibling = &q->link;
 	q->link.common.classid = sch->handle;
 	q->link.qdisc = sch;
-	if (!(q->link.q = qdisc_create_dflt(qdisc_dev(sch), sch->dev_queue,
-					    &pfifo_qdisc_ops,
-					    sch->handle)))
+	q->link.q = qdisc_create_dflt(sch->dev_queue, &pfifo_qdisc_ops,
+				      sch->handle);
+	if (!q->link.q)
 		q->link.q = &noop_qdisc;
 
 	q->link.priority = TC_CBQ_MAXPRIO-1;
@@ -1623,7 +1623,7 @@ static int cbq_graft(struct Qdisc *sch, unsigned long arg, struct Qdisc *new,
 	struct cbq_class *cl = (struct cbq_class*)arg;
 
 	if (new == NULL) {
-		new = qdisc_create_dflt(qdisc_dev(sch), sch->dev_queue,
+		new = qdisc_create_dflt(sch->dev_queue,
 					&pfifo_qdisc_ops, cl->common.classid);
 		if (new == NULL)
 			return -ENOBUFS;
@@ -1874,8 +1874,8 @@ cbq_change_class(struct Qdisc *sch, u32 classid, u32 parentid, struct nlattr **t
 	cl->R_tab = rtab;
 	rtab = NULL;
 	cl->refcnt = 1;
-	if (!(cl->q = qdisc_create_dflt(qdisc_dev(sch), sch->dev_queue,
-					&pfifo_qdisc_ops, classid)))
+	cl->q = qdisc_create_dflt(sch->dev_queue, &pfifo_qdisc_ops, classid);
+	if (!cl->q)
 		cl->q = &noop_qdisc;
 	cl->common.classid = classid;
 	cl->tparent = parent;
diff --git a/net/sched/sch_drr.c b/net/sched/sch_drr.c
index b74046a..aa8b531 100644
--- a/net/sched/sch_drr.c
+++ b/net/sched/sch_drr.c
@@ -110,7 +110,7 @@ static int drr_change_class(struct Qdisc *sch, u32 classid, u32 parentid,
 	cl->refcnt	   = 1;
 	cl->common.classid = classid;
 	cl->quantum	   = quantum;
-	cl->qdisc	   = qdisc_create_dflt(qdisc_dev(sch), sch->dev_queue,
+	cl->qdisc	   = qdisc_create_dflt(sch->dev_queue,
 					       &pfifo_qdisc_ops, classid);
 	if (cl->qdisc == NULL)
 		cl->qdisc = &noop_qdisc;
@@ -218,7 +218,7 @@ static int drr_graft_class(struct Qdisc *sch, unsigned long arg,
 	struct drr_class *cl = (struct drr_class *)arg;
 
 	if (new == NULL) {
-		new = qdisc_create_dflt(qdisc_dev(sch), sch->dev_queue,
+		new = qdisc_create_dflt(sch->dev_queue,
 					&pfifo_qdisc_ops, cl->common.classid);
 		if (new == NULL)
 			new = &noop_qdisc;
diff --git a/net/sched/sch_dsmark.c b/net/sched/sch_dsmark.c
index 63d41f8..1d295d6 100644
--- a/net/sched/sch_dsmark.c
+++ b/net/sched/sch_dsmark.c
@@ -61,8 +61,7 @@ static int dsmark_graft(struct Qdisc *sch, unsigned long arg,
 		sch, p, new, old);
 
 	if (new == NULL) {
-		new = qdisc_create_dflt(qdisc_dev(sch), sch->dev_queue,
-					&pfifo_qdisc_ops,
+		new = qdisc_create_dflt(sch->dev_queue, &pfifo_qdisc_ops,
 					sch->handle);
 		if (new == NULL)
 			new = &noop_qdisc;
@@ -384,8 +383,7 @@ static int dsmark_init(struct Qdisc *sch, struct nlattr *opt)
 	p->default_index = default_index;
 	p->set_tc_index = nla_get_flag(tb[TCA_DSMARK_SET_TC_INDEX]);
 
-	p->q = qdisc_create_dflt(qdisc_dev(sch), sch->dev_queue,
-				 &pfifo_qdisc_ops, sch->handle);
+	p->q = qdisc_create_dflt(sch->dev_queue, &pfifo_qdisc_ops, sch->handle);
 	if (p->q == NULL)
 		p->q = &noop_qdisc;
 
diff --git a/net/sched/sch_fifo.c b/net/sched/sch_fifo.c
index 5948baf..4dfecb0 100644
--- a/net/sched/sch_fifo.c
+++ b/net/sched/sch_fifo.c
@@ -172,8 +172,7 @@ struct Qdisc *fifo_create_dflt(struct Qdisc *sch, struct Qdisc_ops *ops,
 	struct Qdisc *q;
 	int err = -ENOMEM;
 
-	q = qdisc_create_dflt(qdisc_dev(sch), sch->dev_queue,
-			      ops, TC_H_MAKE(sch->handle, 1));
+	q = qdisc_create_dflt(sch->dev_queue, ops, TC_H_MAKE(sch->handle, 1));
 	if (q) {
 		err = fifo_set_limit(q, limit);
 		if (err < 0) {
diff --git a/net/sched/sch_generic.c b/net/sched/sch_generic.c
index 3d57681..2a95272 100644
--- a/net/sched/sch_generic.c
+++ b/net/sched/sch_generic.c
@@ -574,10 +574,8 @@ errout:
 	return ERR_PTR(err);
 }
 
-struct Qdisc * qdisc_create_dflt(struct net_device *dev,
-				 struct netdev_queue *dev_queue,
-				 struct Qdisc_ops *ops,
-				 unsigned int parentid)
+struct Qdisc *qdisc_create_dflt(struct netdev_queue *dev_queue,
+				struct Qdisc_ops *ops, unsigned int parentid)
 {
 	struct Qdisc *sch;
 
@@ -682,7 +680,7 @@ static void attach_one_default_qdisc(struct net_device *dev,
 	struct Qdisc *qdisc;
 
 	if (dev->tx_queue_len) {
-		qdisc = qdisc_create_dflt(dev, dev_queue,
+		qdisc = qdisc_create_dflt(dev_queue,
 					  &pfifo_fast_ops, TC_H_ROOT);
 		if (!qdisc) {
 			printk(KERN_INFO "%s: activation failed\n", dev->name);
@@ -709,7 +707,7 @@ static void attach_default_qdiscs(struct net_device *dev)
 		dev->qdisc = txq->qdisc_sleeping;
 		atomic_inc(&dev->qdisc->refcnt);
 	} else {
-		qdisc = qdisc_create_dflt(dev, txq, &mq_qdisc_ops, TC_H_ROOT);
+		qdisc = qdisc_create_dflt(txq, &mq_qdisc_ops, TC_H_ROOT);
 		if (qdisc) {
 			qdisc->ops->attach(qdisc);
 			dev->qdisc = qdisc;
diff --git a/net/sched/sch_hfsc.c b/net/sched/sch_hfsc.c
index 4749609..069c62b 100644
--- a/net/sched/sch_hfsc.c
+++ b/net/sched/sch_hfsc.c
@@ -1088,7 +1088,7 @@ hfsc_change_class(struct Qdisc *sch, u32 classid, u32 parentid,
 	cl->refcnt    = 1;
 	cl->sched     = q;
 	cl->cl_parent = parent;
-	cl->qdisc = qdisc_create_dflt(qdisc_dev(sch), sch->dev_queue,
+	cl->qdisc = qdisc_create_dflt(sch->dev_queue,
 				      &pfifo_qdisc_ops, classid);
 	if (cl->qdisc == NULL)
 		cl->qdisc = &noop_qdisc;
@@ -1209,8 +1209,7 @@ hfsc_graft_class(struct Qdisc *sch, unsigned long arg, struct Qdisc *new,
 	if (cl->level > 0)
 		return -EINVAL;
 	if (new == NULL) {
-		new = qdisc_create_dflt(qdisc_dev(sch), sch->dev_queue,
-					&pfifo_qdisc_ops,
+		new = qdisc_create_dflt(sch->dev_queue, &pfifo_qdisc_ops,
 					cl->cl_common.classid);
 		if (new == NULL)
 			new = &noop_qdisc;
@@ -1452,8 +1451,7 @@ hfsc_init_qdisc(struct Qdisc *sch, struct nlattr *opt)
 	q->root.cl_common.classid = sch->handle;
 	q->root.refcnt  = 1;
 	q->root.sched   = q;
-	q->root.qdisc = qdisc_create_dflt(qdisc_dev(sch), sch->dev_queue,
-					  &pfifo_qdisc_ops,
+	q->root.qdisc = qdisc_create_dflt(sch->dev_queue, &pfifo_qdisc_ops,
 					  sch->handle);
 	if (q->root.qdisc == NULL)
 		q->root.qdisc = &noop_qdisc;
diff --git a/net/sched/sch_htb.c b/net/sched/sch_htb.c
index 87d9449..01b519d 100644
--- a/net/sched/sch_htb.c
+++ b/net/sched/sch_htb.c
@@ -1121,8 +1121,7 @@ static int htb_graft(struct Qdisc *sch, unsigned long arg, struct Qdisc *new,
 	if (cl->level)
 		return -EINVAL;
 	if (new == NULL &&
-	    (new = qdisc_create_dflt(qdisc_dev(sch), sch->dev_queue,
-				     &pfifo_qdisc_ops,
+	    (new = qdisc_create_dflt(sch->dev_queue, &pfifo_qdisc_ops,
 				     cl->common.classid)) == NULL)
 		return -ENOBUFS;
 
@@ -1247,8 +1246,7 @@ static int htb_delete(struct Qdisc *sch, unsigned long arg)
 		return -EBUSY;
 
 	if (!cl->level && htb_parent_last_child(cl)) {
-		new_q = qdisc_create_dflt(qdisc_dev(sch), sch->dev_queue,
-					  &pfifo_qdisc_ops,
+		new_q = qdisc_create_dflt(sch->dev_queue, &pfifo_qdisc_ops,
 					  cl->parent->common.classid);
 		last_child = 1;
 	}
@@ -1377,7 +1375,7 @@ static int htb_change_class(struct Qdisc *sch, u32 classid,
 		/* create leaf qdisc early because it uses kmalloc(GFP_KERNEL)
 		   so that can't be used inside of sch_tree_lock
 		   -- thanks to Karlis Peisenieks */
-		new_q = qdisc_create_dflt(qdisc_dev(sch), sch->dev_queue,
+		new_q = qdisc_create_dflt(sch->dev_queue,
 					  &pfifo_qdisc_ops, classid);
 		sch_tree_lock(sch);
 		if (parent && !parent->level) {
diff --git a/net/sched/sch_mq.c b/net/sched/sch_mq.c
index fe91e50..ecc302f 100644
--- a/net/sched/sch_mq.c
+++ b/net/sched/sch_mq.c
@@ -56,7 +56,7 @@ static int mq_init(struct Qdisc *sch, struct nlattr *opt)
 
 	for (ntx = 0; ntx < dev->num_tx_queues; ntx++) {
 		dev_queue = netdev_get_tx_queue(dev, ntx);
-		qdisc = qdisc_create_dflt(dev, dev_queue, &pfifo_fast_ops,
+		qdisc = qdisc_create_dflt(dev_queue, &pfifo_fast_ops,
 					  TC_H_MAKE(TC_H_MAJ(sch->handle),
 						    TC_H_MIN(ntx + 1)));
 		if (qdisc == NULL)
diff --git a/net/sched/sch_multiq.c b/net/sched/sch_multiq.c
index 6ae2512..32690de 100644
--- a/net/sched/sch_multiq.c
+++ b/net/sched/sch_multiq.c
@@ -227,8 +227,7 @@ static int multiq_tune(struct Qdisc *sch, struct nlattr *opt)
 	for (i = 0; i < q->bands; i++) {
 		if (q->queues[i] == &noop_qdisc) {
 			struct Qdisc *child, *old;
-			child = qdisc_create_dflt(qdisc_dev(sch),
-						  sch->dev_queue,
+			child = qdisc_create_dflt(sch->dev_queue,
 						  &pfifo_qdisc_ops,
 						  TC_H_MAKE(sch->handle,
 							    i + 1));
diff --git a/net/sched/sch_netem.c b/net/sched/sch_netem.c
index 4714ff1..e5593c0 100644
--- a/net/sched/sch_netem.c
+++ b/net/sched/sch_netem.c
@@ -538,8 +538,7 @@ static int netem_init(struct Qdisc *sch, struct nlattr *opt)
 
 	qdisc_watchdog_init(&q->watchdog, sch);
 
-	q->qdisc = qdisc_create_dflt(qdisc_dev(sch), sch->dev_queue,
-				     &tfifo_qdisc_ops,
+	q->qdisc = qdisc_create_dflt(sch->dev_queue, &tfifo_qdisc_ops,
 				     TC_H_MAKE(sch->handle, 1));
 	if (!q->qdisc) {
 		pr_debug("netem: qdisc create failed\n");
diff --git a/net/sched/sch_prio.c b/net/sched/sch_prio.c
index 0748fb1..b1c95bc 100644
--- a/net/sched/sch_prio.c
+++ b/net/sched/sch_prio.c
@@ -200,7 +200,7 @@ static int prio_tune(struct Qdisc *sch, struct nlattr *opt)
 	for (i=0; i<q->bands; i++) {
 		if (q->queues[i] == &noop_qdisc) {
 			struct Qdisc *child, *old;
-			child = qdisc_create_dflt(qdisc_dev(sch), sch->dev_queue,
+			child = qdisc_create_dflt(sch->dev_queue,
 						  &pfifo_qdisc_ops,
 						  TC_H_MAKE(sch->handle, i + 1));
 			if (child) {
