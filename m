From: Patrick McHardy <kaber@trash.net>
Subject: [PATCH PKT_SCHED 6/17]: Clean up gact action
Date: Thu, 30 Dec 2004 04:39:51 +0100
Message-ID: <41D37887.2010504@trash.net>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------020505020004020905020104"
Cc: Maillist netdev <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: jamal <hadi@cyberus.ca>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------020505020004020905020104
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit

Whitespace cleanup, consistent comparision style.


--------------020505020004020905020104
Content-Type: text/x-patch;
 name="06.diff"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="06.diff"

# This is a BitKeeper generated diff -Nru style patch.
#
# ChangeSet
#   2004/12/30 02:15:50+01:00 kaber@coreworks.de 
#   [PKT_SCHED: Clean up gact action
#   
#   - Whitespace cleanup
#   - Consistent comparision style
#   
#   Signed-off-by: Patrick McHardy <kaber@trash.net>
# 
# net/sched/gact.c
#   2004/12/30 02:15:44+01:00 kaber@coreworks.de +29 -38
#   [PKT_SCHED: Clean up gact action
#   
#   - Whitespace cleanup
#   - Consistent comparision style
#   
#   Signed-off-by: Patrick McHardy <kaber@trash.net>
# 
diff -Nru a/net/sched/gact.c b/net/sched/gact.c
--- a/net/sched/gact.c	2004-12-30 04:01:19 +01:00
+++ b/net/sched/gact.c	2004-12-30 04:01:19 +01:00
@@ -52,27 +52,27 @@
 #include <net/pkt_act.h>
 
 #ifdef CONFIG_GACT_PROB
-typedef int (*g_rand)(struct tcf_gact *p);
-static int
-gact_net_rand(struct tcf_gact *p) {
+static int gact_net_rand(struct tcf_gact *p)
+{
 	if (net_random()%p->pval)
 		return p->action;
 	return p->paction;
 }
 
-static int
-gact_determ(struct tcf_gact *p) {
+static int gact_determ(struct tcf_gact *p)
+{
 	if (p->bstats.packets%p->pval)
 		return p->action;
 	return p->paction;
 }
 
-
-g_rand gact_rand[MAX_RAND]= { NULL,gact_net_rand, gact_determ};
-
+typedef int (*g_rand)(struct tcf_gact *p);
+static g_rand gact_rand[MAX_RAND] = { NULL, gact_net_rand, gact_determ };
 #endif
+
 static int
-tcf_gact_init(struct rtattr *rta, struct rtattr *est, struct tc_action *a,int ovr,int bind)
+tcf_gact_init(struct rtattr *rta, struct rtattr *est, struct tc_action *a,
+              int ovr, int bind)
 {
 	struct rtattr *tb[TCA_GACT_MAX];
 	struct tc_gact *parm = NULL;
@@ -81,31 +81,26 @@
 #endif
 	struct tcf_gact *p = NULL;
 	int ret = 0;
-	int size = sizeof (*p);
 
 	if (rtattr_parse(tb, TCA_GACT_MAX, RTA_DATA(rta), RTA_PAYLOAD(rta)) < 0)
 		return -1;
 
-	if (NULL == a || NULL == tb[TCA_GACT_PARMS - 1]) {
+	if (a == NULL || tb[TCA_GACT_PARMS - 1] == NULL) {
 		printk("BUG: tcf_gact_init called with NULL params\n");
 		return -1;
 	}
 
 	parm = RTA_DATA(tb[TCA_GACT_PARMS - 1]);
 #ifdef CONFIG_GACT_PROB
-	if (NULL != tb[TCA_GACT_PROB - 1]) {
+	if (tb[TCA_GACT_PROB - 1] != NULL)
 		p_parm = RTA_DATA(tb[TCA_GACT_PROB - 1]);
-	}
 #endif
-
 	p = tcf_hash_check(parm, a, ovr, bind);
-
-	if (NULL == p) {
-		p = tcf_hash_create(parm,est,a,size,ovr, bind);
-
-		if (NULL == p) {
+	if (p == NULL) {
+		p = tcf_hash_create(parm, est, a, sizeof(*p), ovr, bind);
+		if (p == NULL)
 			return -1;
-		} else {
+		else {
 			p->refcnt = 1;
 			ret = 1;
 			goto override;
@@ -116,7 +111,7 @@
 override:
 		p->action = parm->action;
 #ifdef CONFIG_GACT_PROB
-		if (NULL != p_parm) {
+		if (p_parm != NULL) {
 			p->paction = p_parm->paction;
 			p->pval = p_parm->pval;
 			p->ptype = p_parm->ptype;
@@ -125,16 +120,15 @@
 		}
 #endif
 	}
-
 	return ret;
 }
 
 static int
 tcf_gact_cleanup(struct tc_action *a, int bind)
 {
-	struct tcf_gact *p;
-	p = PRIV(a,gact);
-	if (NULL != p)
+	struct tcf_gact *p = PRIV(a, gact);
+
+	if (p != NULL)
 		return tcf_hash_release(p, bind);
 	return 0;
 }
@@ -142,13 +136,11 @@
 static int
 tcf_gact(struct sk_buff **pskb, struct tc_action *a)
 {
-	struct tcf_gact *p;
+	struct tcf_gact *p = PRIV(a, gact);
 	struct sk_buff *skb = *pskb;
 	int action = TC_ACT_SHOT;
 
-	p = PRIV(a,gact);
-
-	if (NULL == p) {
+	if (p == NULL) {
 		if (net_ratelimit())
 			printk("BUG: tcf_gact called with NULL params\n");
 		return -1;
@@ -156,7 +148,7 @@
 
 	spin_lock(&p->lock);
 #ifdef CONFIG_GACT_PROB
-	if (p->ptype && NULL != gact_rand[p->ptype])
+	if (p->ptype && gact_rand[p->ptype] != NULL)
 		action = gact_rand[p->ptype](p);
 	else
 		action = p->action;
@@ -165,7 +157,7 @@
 #endif
 	p->bstats.bytes += skb->len;
 	p->bstats.packets++;
-	if (TC_ACT_SHOT == action)
+	if (action == TC_ACT_SHOT)
 		p->qstats.drops++;
 	p->tm.lastuse = jiffies;
 	spin_unlock(&p->lock);
@@ -181,11 +173,10 @@
 #ifdef CONFIG_GACT_PROB
 	struct tc_gact_p p_opt;
 #endif
-	struct tcf_gact *p;
+	struct tcf_gact *p = PRIV(a, gact);
 	struct tcf_t t;
 
-	p = PRIV(a,gact);
-	if (NULL == p) {
+	if (p == NULL) {
 		printk("BUG: tcf_gact_dump called with NULL params\n");
 		goto rtattr_failure;
 	}
@@ -194,19 +185,19 @@
 	opt.refcnt = p->refcnt - ref;
 	opt.bindcnt = p->bindcnt - bind;
 	opt.action = p->action;
-	RTA_PUT(skb, TCA_GACT_PARMS, sizeof (opt), &opt);
+	RTA_PUT(skb, TCA_GACT_PARMS, sizeof(opt), &opt);
 #ifdef CONFIG_GACT_PROB
 	if (p->ptype) {
 		p_opt.paction = p->paction;
 		p_opt.pval = p->pval;
 		p_opt.ptype = p->ptype;
-		RTA_PUT(skb, TCA_GACT_PROB, sizeof (p_opt), &p_opt);
-	} 
+		RTA_PUT(skb, TCA_GACT_PROB, sizeof(p_opt), &p_opt);
+	}
 #endif
 	t.install = jiffies_to_clock_t(jiffies - p->tm.install);
 	t.lastuse = jiffies_to_clock_t(jiffies - p->tm.lastuse);
 	t.expires = jiffies_to_clock_t(p->tm.expires);
-	RTA_PUT(skb, TCA_GACT_TM, sizeof (t), &t);
+	RTA_PUT(skb, TCA_GACT_TM, sizeof(t), &t);
 	return skb->len;
 
       rtattr_failure:

--------------020505020004020905020104--
