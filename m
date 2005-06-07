From: Thomas Graf <tgraf@suug.ch>
Subject: [PATCH 7/7] [PKT_SCHED]: noop/noqueue qdisc style cleanups
Date: Tue, 07 Jun 2005 16:08:49 +0200
Message-ID: <20050607140901.632982000@axs>
References: <20050607140842.778143000@axs>
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: davem@davemloft.net
Content-Disposition: inline; filename=sch_generic_cleanups
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Signed-off-by: Thomas Graf <tgraf@suug.ch>

Index: net-2.6.13/net/sched/sch_generic.c
===================================================================
--- net-2.6.13.orig/net/sched/sch_generic.c
+++ net-2.6.13/net/sched/sch_generic.c
@@ -243,31 +243,27 @@ static void dev_watchdog_down(struct net
    cheaper.
  */
 
-static int
-noop_enqueue(struct sk_buff *skb, struct Qdisc * qdisc)
+static int noop_enqueue(struct sk_buff *skb, struct Qdisc * qdisc)
 {
 	kfree_skb(skb);
 	return NET_XMIT_CN;
 }
 
-static struct sk_buff *
-noop_dequeue(struct Qdisc * qdisc)
+static struct sk_buff *noop_dequeue(struct Qdisc * qdisc)
 {
 	return NULL;
 }
 
-static int
-noop_requeue(struct sk_buff *skb, struct Qdisc* qdisc)
+static int noop_requeue(struct sk_buff *skb, struct Qdisc* qdisc)
 {
 	if (net_ratelimit())
-		printk(KERN_DEBUG "%s deferred output. It is buggy.\n", skb->dev->name);
+		printk(KERN_DEBUG "%s deferred output. It is buggy.\n",
+		       skb->dev->name);
 	kfree_skb(skb);
 	return NET_XMIT_CN;
 }
 
 struct Qdisc_ops noop_qdisc_ops = {
-	.next		=	NULL,
-	.cl_ops		=	NULL,
 	.id		=	"noop",
 	.priv_size	=	0,
 	.enqueue	=	noop_enqueue,
@@ -285,8 +281,6 @@ struct Qdisc noop_qdisc = {
 };
 
 static struct Qdisc_ops noqueue_qdisc_ops = {
-	.next		=	NULL,
-	.cl_ops		=	NULL,
 	.id		=	"noqueue",
 	.priv_size	=	0,
 	.enqueue	=	noop_enqueue,
