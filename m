From: Patrick McHardy <kaber@trash.net>
Subject: [PATCH 2.6]: Remove unnecessary memset in packet schedulers
Date: Tue, 17 Aug 2004 02:07:32 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <41214C44.5010108@trash.net>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------070406080400090802070305"
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------070406080400090802070305
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit

This patch removes some more unnecessary memsets in packet
schedulers. The qdisc's private data is already set to 0
in qdisc_create/qdisc_create_dflt.



--------------070406080400090802070305
Content-Type: text/x-patch;
 name="2.6-psched-memsets.diff"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="2.6-psched-memsets.diff"

# This is a BitKeeper generated diff -Nru style patch.
#
# ChangeSet
#   2004/08/17 01:30:30+02:00 kaber@coreworks.de 
#   [PKT_SCHED]: remove unnecessary memsets in packet schedulers
#   
#   Signed-off-by: Patrick McHardy <kaber@trash.net>
# 
# net/sched/sch_ingress.c
#   2004/08/17 01:30:10+02:00 kaber@coreworks.de +0 -8
#   [PKT_SCHED]: remove unnecessary memsets in packet schedulers
# 
# net/sched/sch_htb.c
#   2004/08/17 01:30:10+02:00 kaber@coreworks.de +0 -1
#   [PKT_SCHED]: remove unnecessary memsets in packet schedulers
# 
# net/sched/sch_hfsc.c
#   2004/08/17 01:30:10+02:00 kaber@coreworks.de +0 -1
#   [PKT_SCHED]: remove unnecessary memsets in packet schedulers
# 
# net/sched/sch_dsmark.c
#   2004/08/17 01:30:10+02:00 kaber@coreworks.de +0 -2
#   [PKT_SCHED]: remove unnecessary memsets in packet schedulers
# 
# net/sched/sch_atm.c
#   2004/08/17 01:30:10+02:00 kaber@coreworks.de +0 -1
#   [PKT_SCHED]: remove unnecessary memsets in packet schedulers
# 
diff -Nru a/net/sched/sch_atm.c b/net/sched/sch_atm.c
--- a/net/sched/sch_atm.c	2004-08-17 01:35:21 +02:00
+++ b/net/sched/sch_atm.c	2004-08-17 01:35:21 +02:00
@@ -573,7 +573,6 @@
 	struct atm_qdisc_data *p = PRIV(sch);
 
 	DPRINTK("atm_tc_init(sch %p,[qdisc %p],opt %p)\n",sch,p,opt);
-	memset(p,0,sizeof(*p));
 	p->flows = &p->link;
 	if(!(p->link.q = qdisc_create_dflt(sch->dev,&pfifo_qdisc_ops)))
 		p->link.q = &noop_qdisc;
diff -Nru a/net/sched/sch_dsmark.c b/net/sched/sch_dsmark.c
--- a/net/sched/sch_dsmark.c	2004-08-17 01:35:21 +02:00
+++ b/net/sched/sch_dsmark.c	2004-08-17 01:35:21 +02:00
@@ -331,8 +331,6 @@
 	    !tb[TCA_DSMARK_INDICES-1] ||
 	    RTA_PAYLOAD(tb[TCA_DSMARK_INDICES-1]) < sizeof(__u16))
                 return -EINVAL;
-	memset(p,0,sizeof(*p));
-	p->filter_list = NULL;
 	p->indices = *(__u16 *) RTA_DATA(tb[TCA_DSMARK_INDICES-1]);
 	if (!p->indices)
 		return -EINVAL;
diff -Nru a/net/sched/sch_hfsc.c b/net/sched/sch_hfsc.c
--- a/net/sched/sch_hfsc.c	2004-08-17 01:35:21 +02:00
+++ b/net/sched/sch_hfsc.c	2004-08-17 01:35:21 +02:00
@@ -1553,7 +1553,6 @@
 		return -EINVAL;
 	qopt = RTA_DATA(opt);
 
-	memset(q, 0, sizeof(struct hfsc_sched));
 	sch->stats_lock = &sch->dev->queue_lock;
 
 	q->defcls = qopt->defcls;
diff -Nru a/net/sched/sch_htb.c b/net/sched/sch_htb.c
--- a/net/sched/sch_htb.c	2004-08-17 01:35:21 +02:00
+++ b/net/sched/sch_htb.c	2004-08-17 01:35:21 +02:00
@@ -1277,7 +1277,6 @@
 				HTB_VER >> 16,HTB_VER & 0xffff,gopt->version);
 		return -EINVAL;
 	}
-	memset(q,0,sizeof(*q));
 	q->debug = gopt->debug;
 	HTB_DBG(0,1,"htb_init sch=%p handle=%X r2q=%d\n",sch,sch->handle,gopt->rate2quantum);
 
diff -Nru a/net/sched/sch_ingress.c b/net/sched/sch_ingress.c
--- a/net/sched/sch_ingress.c	2004-08-17 01:35:21 +02:00
+++ b/net/sched/sch_ingress.c	2004-08-17 01:35:21 +02:00
@@ -289,9 +289,6 @@
 #endif
 #endif
                                                                                 
-	if (NULL == p)
-		goto error;
-
 #ifndef CONFIG_NET_CLS_ACT
 #ifdef CONFIG_NETFILTER
 	if (!nf_registered) {
@@ -305,8 +302,6 @@
 #endif
 
 	DPRINTK("ingress_init(sch %p,[qdisc %p],opt %p)\n",sch,p,opt);
-	memset(p, 0, sizeof(*p));
-	p->filter_list = NULL;
 	p->q = &noop_qdisc;
 	return 0;
 error:
@@ -346,9 +341,6 @@
 		p->filter_list = tp->next;
 		tcf_destroy(tp);
 	}
-	memset(p, 0, sizeof(*p));
-	p->filter_list = NULL;
-
 #if 0
 /* for future use */
 	qdisc_destroy(p->q);

--------------070406080400090802070305--
