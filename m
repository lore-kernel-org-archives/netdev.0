From: Dmitry Torokhov <dtor_core@ameritech.net>
Subject: Re: [PATCH 2/2 (resend)] TBF trailing whitespace fixes
Date: Wed, 24 Mar 2004 23:54:22 -0500
Sender: linux-net-owner@vger.kernel.org
Message-ID: <200403242354.23584.dtor_core@ameritech.net>
References: <200403230108.08384.dtor_core@ameritech.net> <200403230108.58006.dtor_core@ameritech.net> <20040324135939.4dff0560.davem@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: linux-net@vger.kernel.org, netdev@oss.sgi.com
Return-path: <linux-net-owner@vger.kernel.org>
To: "David S. Miller" <davem@redhat.com>
In-Reply-To: <20040324135939.4dff0560.davem@redhat.com>
Content-Disposition: inline
List-Id: netdev.vger.kernel.org

On Wednesday 24 March 2004 04:59 pm, David S. Miller wrote:
> 
> Dmitry, I applied the first patch to both 2.4.x and 2.6.x
> The whitespace patch (the second one) only applies to 2.6.x,
> so a 2.4.x version would be appreciated.
> 
> Thanks.
> 

Here it is, against the today's Marcelo's BK plus the first patch.
It compiles.

--
Dmitry


===================================================================


ChangeSet@1.1321, 2004-03-24 23:50:16-05:00, dtor_core@ameritech.net
  NET: TBF trailing whitespace cleanup


 sch_tbf.c |   68 +++++++++++++++++++++++++++++++-------------------------------
 1 files changed, 34 insertions(+), 34 deletions(-)


===================================================================



diff -Nru a/net/sched/sch_tbf.c b/net/sched/sch_tbf.c
--- a/net/sched/sch_tbf.c	Wed Mar 24 23:50:55 2004
+++ b/net/sched/sch_tbf.c	Wed Mar 24 23:50:55 2004
@@ -62,7 +62,7 @@
 
 	Algorithm.
 	----------
-	
+
 	Let N(t_i) be B/R initially and N(t) grow continuously with time as:
 
 	N(t+delta) = min{B/R, N(t) + delta}
@@ -146,15 +146,15 @@
 		if (sch->reshape_fail == NULL || sch->reshape_fail(skb, sch))
 #endif
 			kfree_skb(skb);
-	
+
 		return NET_XMIT_DROP;
 	}
-	
+
 	if ((ret = q->qdisc->enqueue(skb, q->qdisc)) != 0) {
 		sch->stats.drops++;
 		return ret;
-	}	
-	
+	}
+
 	sch->q.qlen++;
 	sch->stats.bytes += skb->len;
 	sch->stats.packets++;
@@ -165,10 +165,10 @@
 {
 	struct tbf_sched_data *q = (struct tbf_sched_data *)sch->data;
 	int ret;
-	
+
 	if ((ret = q->qdisc->ops->requeue(skb, q->qdisc)) == 0)
-		sch->q.qlen++; 
-	
+		sch->q.qlen++;
+
 	return ret;
 }
 
@@ -176,7 +176,7 @@
 {
 	struct tbf_sched_data *q = (struct tbf_sched_data *)sch->data;
 	unsigned int len;
-	
+
 	if ((len = q->qdisc->ops->drop(q->qdisc)) != 0) {
 		sch->q.qlen--;
 		sch->stats.drops++;
@@ -196,7 +196,7 @@
 {
 	struct tbf_sched_data *q = (struct tbf_sched_data *)sch->data;
 	struct sk_buff *skb;
-	
+
 	skb = q->qdisc->dequeue(q->qdisc);
 
 	if (skb) {
@@ -204,7 +204,7 @@
 		long toks;
 		long ptoks = 0;
 		unsigned int len = skb->len;
-		
+
 		PSCHED_GET_TIME(now);
 
 		toks = PSCHED_TDIFF_SAFE(now, q->t_c, q->buffer, 0);
@@ -248,13 +248,13 @@
 		   This is the main idea of all FQ algorithms
 		   (cf. CSZ, HPFQ, HFSC)
 		 */
-		
+
 		if (q->qdisc->ops->requeue(skb, q->qdisc) != NET_XMIT_SUCCESS) {
-			/* When requeue fails skb is dropped */ 
+			/* When requeue fails skb is dropped */
 			sch->q.qlen--;
 			sch->stats.drops++;
-		}	
-		
+		}
+
 		sch->flags |= TCQ_F_THROTTLED;
 		sch->stats.overlimits++;
 	}
@@ -279,24 +279,24 @@
 	struct Qdisc *q = qdisc_create_dflt(dev, &bfifo_qdisc_ops);
         struct rtattr *rta;
 	int ret;
-	
+
 	if (q) {
 		rta = kmalloc(RTA_LENGTH(sizeof(struct tc_fifo_qopt)), GFP_KERNEL);
 		if (rta) {
 			rta->rta_type = RTM_NEWQDISC;
-			rta->rta_len = RTA_LENGTH(sizeof(struct tc_fifo_qopt)); 
+			rta->rta_len = RTA_LENGTH(sizeof(struct tc_fifo_qopt));
 			((struct tc_fifo_qopt *)RTA_DATA(rta))->limit = limit;
-			
+
 			ret = q->ops->change(q, rta);
 			kfree(rta);
-			
+
 			if (ret == 0)
 				return q;
 		}
 		qdisc_destroy(q);
 	}
 
-	return NULL;	
+	return NULL;
 }
 
 static int tbf_change(struct Qdisc* sch, struct rtattr *opt)
@@ -340,7 +340,7 @@
 	}
 	if (max_size < 0)
 		goto done;
-	
+
 	if (q->qdisc == &noop_qdisc) {
 		if ((child = tbf_create_dflt_qdisc(sch->dev, qopt->limit)) == NULL)
 			goto done;
@@ -370,19 +370,19 @@
 {
 	int err;
 	struct tbf_sched_data *q = (struct tbf_sched_data *)sch->data;
-	
+
 	if (opt == NULL)
 		return -EINVAL;
-	
+
 	MOD_INC_USE_COUNT;
-	
+
 	PSCHED_GET_TIME(q->t_c);
 	init_timer(&q->wd_timer);
 	q->wd_timer.function = tbf_watchdog;
 	q->wd_timer.data = (unsigned long)sch;
 
 	q->qdisc = &noop_qdisc;
-	
+
 	if ((err = tbf_change(sch, opt)) != 0) {
 		MOD_DEC_USE_COUNT;
 	}
@@ -399,7 +399,7 @@
 		qdisc_put_rtab(q->P_tab);
 	if (q->R_tab)
 		qdisc_put_rtab(q->R_tab);
-	
+
 	qdisc_destroy(q->qdisc);
 	q->qdisc = &noop_qdisc;
 
@@ -412,10 +412,10 @@
 	unsigned char	 *b = skb->tail;
 	struct rtattr *rta;
 	struct tc_tbf_qopt opt;
-	
+
 	rta = (struct rtattr*)b;
 	RTA_PUT(skb, TCA_OPTIONS, 0, NULL);
-	
+
 	opt.limit = q->limit;
 	opt.rate = q->R_tab->rate;
 	if (q->P_tab)
@@ -439,9 +439,9 @@
 {
 	struct tbf_sched_data *q = (struct tbf_sched_data*)sch->data;
 
-	if (cl != 1) 	/* only one class */ 
+	if (cl != 1) 	/* only one class */
 		return -ENOENT;
-    
+
 	tcm->tcm_handle |= TC_H_MIN(1);
 	tcm->tcm_info = q->qdisc->handle;
 
@@ -456,12 +456,12 @@
 	if (new == NULL)
 		new = &noop_qdisc;
 
-	sch_tree_lock(sch);	
+	sch_tree_lock(sch);
 	*old = xchg(&q->qdisc, new);
 	qdisc_reset(*old);
 	sch->q.qlen = 0;
 	sch_tree_unlock(sch);
-	
+
 	return 0;
 }
 
@@ -480,7 +480,7 @@
 {
 }
 
-static int tbf_change_class(struct Qdisc *sch, u32 classid, u32 parentid, 
+static int tbf_change_class(struct Qdisc *sch, u32 classid, u32 parentid,
 			struct rtattr **tca, unsigned long *arg)
 {
 	return -ENOSYS;
@@ -542,7 +542,7 @@
 	return register_qdisc(&tbf_qdisc_ops);
 }
 
-void cleanup_module(void) 
+void cleanup_module(void)
 {
 	unregister_qdisc(&tbf_qdisc_ops);
 }
