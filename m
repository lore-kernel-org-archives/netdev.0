From: Thomas Graf <tgraf@suug.ch>
Subject: [PATCH 2.6] PKT_SCHED: Rename TCQ_F_INGRES to TCQ_F_INGRESS
Date: Sat, 23 Oct 2004 01:06:30 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20041022230630.GK21977@postel.suug.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@davemloft.net>
Content-Disposition: inline
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

This typo annoyned me several times by not showing up in greps.

Signed-off-by: Thomas Graf <tgraf@suug.ch>

--- linux-2.6.9-bk6.orig/include/net/pkt_sched.h	2004-10-21 17:28:57.000000000 +0200
+++ linux-2.6.9-bk6/include/net/pkt_sched.h	2004-10-23 00:45:48.000000000 +0200
@@ -79,7 +79,7 @@
 	unsigned		flags;
 #define TCQ_F_BUILTIN	1
 #define TCQ_F_THROTTLED	2
-#define TCQ_F_INGRES	4
+#define TCQ_F_INGRESS	4
 	int			padded;
 	struct Qdisc_ops	*ops;
 	u32			handle;
--- linux-2.6.9-bk6.orig/net/sched/sch_api.c	2004-10-21 17:29:02.000000000 +0200
+++ linux-2.6.9-bk6/net/sched/sch_api.c	2004-10-23 00:42:06.000000000 +0200
@@ -308,7 +308,7 @@
 		dev_deactivate(dev);
 
 	qdisc_lock_tree(dev);
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
@@ -430,7 +430,7 @@
 	skb_queue_head_init(&sch->q);
 
 	if (handle == TC_H_INGRESS)
-		sch->flags |= TCQ_F_INGRES;
+		sch->flags |= TCQ_F_INGRESS;
 
 	sch->ops = ops;
 	sch->enqueue = ops->enqueue;
