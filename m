From: Thomas Graf <tgraf@suug.ch>
Subject: [PATCH 2.4] PKT_SCHED: Rename TCQ_F_INGRES to TCQ_F_INGRESS
Date: Sat, 23 Oct 2004 01:07:31 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20041022230731.GL21977@postel.suug.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@davemloft.net>
Content-Disposition: inline
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Signed-off-by: Thomas Graf <tgraf@suug.ch>

--- linux-2.4.28-pre4-bk6.orig/include/net/pkt_sched.h	2004-10-22 10:58:23.000000000 +0200
+++ linux-2.4.28-pre4-bk6/include/net/pkt_sched.h	2004-10-23 00:48:08.000000000 +0200
@@ -78,7 +78,7 @@
 	unsigned		flags;
 #define TCQ_F_BUILTIN	1
 #define TCQ_F_THROTTLED	2
-#define TCQ_F_INGRES	4
+#define TCQ_F_INGRESS	4
 	struct Qdisc_ops	*ops;
 	u32			handle;
 	u32			parent;
--- linux-2.4.28-pre4-bk6.orig/net/sched/sch_api.c	2004-10-22 10:58:23.000000000 +0200
+++ linux-2.4.28-pre4-bk6/net/sched/sch_api.c	2004-10-23 00:48:08.000000000 +0200
@@ -307,7 +307,7 @@
 
 	write_lock(&qdisc_tree_lock);
 	spin_lock_bh(&dev->queue_lock);
-	if (qdisc && qdisc->flags&TCQ_F_INGRES) {
+	if (qdisc && qdisc->flags&TCQ_F_INGRESS) {
 		oqdisc = dev->qdisc_ingress;
 		/* Prune old scheduler */
 		if (oqdisc && atomic_read(&oqdisc->refcnt) <= 1) {
@@ -357,7 +357,7 @@
 
 
 	if (parent == NULL) { 
-		if (q && q->flags&TCQ_F_INGRES) {
+		if (q && q->flags&TCQ_F_INGRESS) {
 			*old = dev_graft_qdisc(dev, q);
 		} else {
 			*old = dev_graft_qdisc(dev, new);
@@ -431,7 +431,7 @@
 	skb_queue_head_init(&sch->q);
 
 	if (handle == TC_H_INGRESS)
-		sch->flags |= TCQ_F_INGRES;
+		sch->flags |= TCQ_F_INGRESS;
 
 	sch->ops = ops;
 	sch->enqueue = ops->enqueue;
