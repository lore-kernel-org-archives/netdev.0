From: Patrick McHardy <kaber@trash.net>
Subject: [PATCH 2.6 5/5]: remove noop_qdisc assignments in destroy functions
Date: Tue, 03 Aug 2004 17:25:54 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <410FAE82.7070604@trash.net>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------060803040006040108040500"
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------060803040006040108040500
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit

This patch removes useless noop_qdisc assignments in multiple qdiscs destroy
functions, the memory where the pointer is stored is freed directly 
after the
destroy function.


--------------060803040006040108040500
Content-Type: text/x-patch;
 name="05-destroy-noop-qdisc.diff"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="05-destroy-noop-qdisc.diff"

# This is a BitKeeper generated diff -Nru style patch.
#
# ChangeSet
#   2004/08/03 03:02:03+02:00 kaber@coreworks.de 
#   [PKT_SCHED]: Remove useless noop_qdisc assignments in destroy functions
#   
#   Signed-off-by: Patrick McHardy <kaber@trash.net>
# 
# net/sched/sch_tbf.c
#   2004/08/03 03:01:39+02:00 kaber@coreworks.de +0 -1
#   [PKT_SCHED]: Remove useless noop_qdisc assignments in destroy functions
# 
# net/sched/sch_red.c
#   2004/08/03 03:01:39+02:00 kaber@coreworks.de +0 -5
#   [PKT_SCHED]: Remove useless noop_qdisc assignments in destroy functions
# 
# net/sched/sch_prio.c
#   2004/08/03 03:01:39+02:00 kaber@coreworks.de +1 -3
#   [PKT_SCHED]: Remove useless noop_qdisc assignments in destroy functions
# 
# net/sched/sch_netem.c
#   2004/08/03 03:01:39+02:00 kaber@coreworks.de +0 -2
#   [PKT_SCHED]: Remove useless noop_qdisc assignments in destroy functions
# 
# net/sched/sch_dsmark.c
#   2004/08/03 03:01:39+02:00 kaber@coreworks.de +0 -1
#   [PKT_SCHED]: Remove useless noop_qdisc assignments in destroy functions
# 
diff -Nru a/net/sched/sch_dsmark.c b/net/sched/sch_dsmark.c
--- a/net/sched/sch_dsmark.c	2004-08-03 03:03:09 +02:00
+++ b/net/sched/sch_dsmark.c	2004-08-03 03:03:09 +02:00
@@ -383,7 +383,6 @@
 		tcf_destroy(tp);
 	}
 	qdisc_destroy(p->q);
-	p->q = &noop_qdisc;
 	kfree(p->mask);
 }
 
diff -Nru a/net/sched/sch_netem.c b/net/sched/sch_netem.c
--- a/net/sched/sch_netem.c	2004-08-03 03:03:09 +02:00
+++ b/net/sched/sch_netem.c	2004-08-03 03:03:09 +02:00
@@ -812,9 +812,7 @@
 	struct netem_sched_data *q = (struct netem_sched_data *)sch->data;
 
 	del_timer_sync(&q->timer);
-
 	qdisc_destroy(q->qdisc);
-	q->qdisc = &noop_qdisc;
 }
 
 static int netem_dump(struct Qdisc *sch, struct sk_buff *skb)
diff -Nru a/net/sched/sch_prio.c b/net/sched/sch_prio.c
--- a/net/sched/sch_prio.c	2004-08-03 03:03:09 +02:00
+++ b/net/sched/sch_prio.c	2004-08-03 03:03:09 +02:00
@@ -208,10 +208,8 @@
 		tcf_destroy(tp);
 	}
 
-	for (prio=0; prio<q->bands; prio++) {
+	for (prio=0; prio<q->bands; prio++)
 		qdisc_destroy(q->queues[prio]);
-		q->queues[prio] = &noop_qdisc;
-	}
 }
 
 static int prio_tune(struct Qdisc *sch, struct rtattr *opt)
diff -Nru a/net/sched/sch_red.c b/net/sched/sch_red.c
--- a/net/sched/sch_red.c	2004-08-03 03:03:09 +02:00
+++ b/net/sched/sch_red.c	2004-08-03 03:03:09 +02:00
@@ -434,10 +434,6 @@
 	return -1;
 }
 
-static void red_destroy(struct Qdisc *sch)
-{
-}
-
 static struct Qdisc_ops red_qdisc_ops = {
 	.next		=	NULL,
 	.cl_ops		=	NULL,
@@ -449,7 +445,6 @@
 	.drop		=	red_drop,
 	.init		=	red_init,
 	.reset		=	red_reset,
-	.destroy	=	red_destroy,
 	.change		=	red_change,
 	.dump		=	red_dump,
 	.owner		=	THIS_MODULE,
diff -Nru a/net/sched/sch_tbf.c b/net/sched/sch_tbf.c
--- a/net/sched/sch_tbf.c	2004-08-03 03:03:09 +02:00
+++ b/net/sched/sch_tbf.c	2004-08-03 03:03:09 +02:00
@@ -393,7 +393,6 @@
 		qdisc_put_rtab(q->R_tab);
 
 	qdisc_destroy(q->qdisc);
-	q->qdisc = &noop_qdisc;
 }
 
 static int tbf_dump(struct Qdisc *sch, struct sk_buff *skb)

--------------060803040006040108040500--
