From: Patrick McHardy <kaber@trash.net>
Subject: [PATCH PKT_SCHED 10/22]: tc actions: remove checks for impossible
 conditions
Date: Mon, 10 Jan 2005 20:37:59 +0100
Message-ID: <41E2D997.3060401@trash.net>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------030509010300020508090902"
Cc: Maillist netdev <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: jamal <hadi@cyberus.ca>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------030509010300020508090902
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit



--------------030509010300020508090902
Content-Type: text/x-patch;
 name="10.diff"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="10.diff"

# This is a BitKeeper generated diff -Nru style patch.
#
# ChangeSet
#   2005/01/09 23:37:54+01:00 kaber@coreworks.de 
#   [PKT_SCHED]: tc actions: remove checks for impossible conditions
#   
#   Signed-off-by: Patrick McHardy <kaber@trash.net>
# 
# net/sched/police.c
#   2005/01/09 23:37:48+01:00 kaber@coreworks.de +0 -17
#   [PKT_SCHED]: tc actions: remove checks for impossible conditions
#   
#   Signed-off-by: Patrick McHardy <kaber@trash.net>
# 
# net/sched/pedit.c
#   2005/01/09 23:37:48+01:00 kaber@coreworks.de +1 -11
#   [PKT_SCHED]: tc actions: remove checks for impossible conditions
#   
#   Signed-off-by: Patrick McHardy <kaber@trash.net>
# 
# net/sched/mirred.c
#   2005/01/09 23:37:48+01:00 kaber@coreworks.de +3 -20
#   [PKT_SCHED]: tc actions: remove checks for impossible conditions
#   
#   Signed-off-by: Patrick McHardy <kaber@trash.net>
# 
# net/sched/ipt.c
#   2005/01/09 23:37:48+01:00 kaber@coreworks.de +1 -8
#   [PKT_SCHED]: tc actions: remove checks for impossible conditions
#   
#   Signed-off-by: Patrick McHardy <kaber@trash.net>
# 
# net/sched/gact.c
#   2005/01/09 23:37:48+01:00 kaber@coreworks.de +1 -12
#   [PKT_SCHED]: tc actions: remove checks for impossible conditions
#   
#   Signed-off-by: Patrick McHardy <kaber@trash.net>
# 
diff -Nru a/net/sched/gact.c b/net/sched/gact.c
--- a/net/sched/gact.c	2005-01-10 06:22:25 +01:00
+++ b/net/sched/gact.c	2005-01-10 06:22:25 +01:00
@@ -85,7 +85,7 @@
 	if (rtattr_parse(tb, TCA_GACT_MAX, RTA_DATA(rta), RTA_PAYLOAD(rta)) < 0)
 		return -1;
 
-	if (a == NULL || tb[TCA_GACT_PARMS - 1] == NULL) {
+	if (tb[TCA_GACT_PARMS - 1] == NULL) {
 		printk("BUG: tcf_gact_init called with NULL params\n");
 		return -1;
 	}
@@ -140,12 +140,6 @@
 	struct sk_buff *skb = *pskb;
 	int action = TC_ACT_SHOT;
 
-	if (p == NULL) {
-		if (net_ratelimit())
-			printk("BUG: tcf_gact called with NULL params\n");
-		return -1;
-	}
-
 	spin_lock(&p->lock);
 #ifdef CONFIG_GACT_PROB
 	if (p->ptype && gact_rand[p->ptype] != NULL)
@@ -172,11 +166,6 @@
 	struct tc_gact opt;
 	struct tcf_gact *p = PRIV(a, gact);
 	struct tcf_t t;
-
-	if (p == NULL) {
-		printk("BUG: tcf_gact_dump called with NULL params\n");
-		goto rtattr_failure;
-	}
 
 	opt.index = p->index;
 	opt.refcnt = p->refcnt - ref;
diff -Nru a/net/sched/ipt.c b/net/sched/ipt.c
--- a/net/sched/ipt.c	2005-01-10 06:22:25 +01:00
+++ b/net/sched/ipt.c	2005-01-10 06:22:25 +01:00
@@ -96,7 +96,7 @@
 	u32 index = 0;
 	u32 hook = 0;
 
-	if (a == NULL || rta == NULL ||
+	if (rta == NULL ||
 	    rtattr_parse(tb, TCA_IPT_MAX, RTA_DATA(rta), RTA_PAYLOAD(rta)) < 0)
 		return -1;
 
@@ -238,9 +238,6 @@
 	struct tcf_ipt *p = PRIV(a, ipt);
 	struct sk_buff *skb = *pskb;
 
-	if (p == NULL || skb == NULL)
-		return -1;
-
 	spin_lock(&p->lock);
 
 	p->tm.lastuse = jiffies;
@@ -288,10 +285,6 @@
 	unsigned char *b = skb->tail;
 	struct tcf_ipt *p = PRIV(a, ipt);
 
-	if (p == NULL) {
-		printk("BUG: tcf_ipt_dump called with NULL params\n");
-		goto rtattr_failure;
-	}
 	/* for simple targets kernel size == user size
 	** user name = target name
 	** for foolproof you need to not assume this
diff -Nru a/net/sched/mirred.c b/net/sched/mirred.c
--- a/net/sched/mirred.c	2005-01-10 06:22:25 +01:00
+++ b/net/sched/mirred.c	2005-01-10 06:22:25 +01:00
@@ -90,7 +90,7 @@
 		return -1;
 	}
 
-	if (a == NULL || tb[TCA_MIRRED_PARMS - 1] == NULL) {
+	if (tb[TCA_MIRRED_PARMS - 1] == NULL) {
 		DPRINTK("BUG: tcf_mirred_init called with NULL params\n");
 		return -1;
 	}
@@ -169,27 +169,15 @@
 	struct sk_buff *skb = *pskb;
 	u32 at = G_TC_AT(skb->tc_verd);
 
-	if (a == NULL) {
-		if (net_ratelimit())
-			printk("BUG: tcf_mirred called with NULL action!\n");
-		return -1;
-	}
-
-	if (p == NULL) {
-		if (net_ratelimit())
-			printk("BUG: tcf_mirred called with NULL params\n");
-		return -1;
-	}
-
 	spin_lock(&p->lock);
 
 	dev = p->dev;
 	p->tm.lastuse = jiffies;
 
-	if (dev == NULL || !(dev->flags&IFF_UP) ) {
+	if (!(dev->flags&IFF_UP) ) {
 		if (net_ratelimit())
 			printk("mirred to Houston: device %s is gone!\n",
-			       dev ? dev->name : "");
+			       dev->name);
 bad_mirred:
 		if (skb2 != NULL)
 			kfree_skb(skb2);
@@ -236,11 +224,6 @@
 	struct tc_mirred opt;
 	struct tcf_mirred *p = PRIV(a, mirred);
 	struct tcf_t t;
-
-	if (p == NULL) {
-		printk("BUG: tcf_mirred_dump called with NULL params\n");
-		goto rtattr_failure;
-	}
 
 	opt.index = p->index;
 	opt.action = p->action;
diff -Nru a/net/sched/pedit.c b/net/sched/pedit.c
--- a/net/sched/pedit.c	2005-01-10 06:22:25 +01:00
+++ b/net/sched/pedit.c	2005-01-10 06:22:25 +01:00
@@ -65,7 +65,7 @@
 	if (rtattr_parse(tb, TCA_PEDIT_MAX, RTA_DATA(rta),
 	                 RTA_PAYLOAD(rta)) < 0)
 		return -1;
-	if (a == NULL || tb[TCA_PEDIT_PARMS - 1] == NULL) {
+	if (tb[TCA_PEDIT_PARMS - 1] == NULL) {
 		printk("BUG: tcf_pedit_init called with NULL params\n");
 		return -1;
 	}
@@ -113,11 +113,6 @@
 	int i, munged = 0;
 	u8 *pptr;
 
-	if (p == NULL) {
-		printk("BUG: tcf_pedit called with NULL params\n");
-		return -1; /* change to something symbolic */
-	}
-
 	if (!(skb->tc_verd & TC_OK2MUNGE)) {
 		/* should we set skb->cloned? */
 		if (pskb_expand_head(skb, 0, 0, GFP_ATOMIC)) {
@@ -189,11 +184,6 @@
 	struct tcf_t t;
 	int s; 
 		
-	if (p == NULL) {
-		printk("BUG: tcf_pedit_dump called with NULL params\n");
-		goto rtattr_failure;
-	}
-
 	s = sizeof(*opt) + p->nkeys * sizeof(struct tc_pedit_key);
 
 	/* netlink spinlocks held above us - must use ATOMIC */
diff -Nru a/net/sched/police.c b/net/sched/police.c
--- a/net/sched/police.c	2005-01-10 06:22:25 +01:00
+++ b/net/sched/police.c	2005-01-10 06:22:25 +01:00
@@ -170,13 +170,6 @@
 	struct tc_police *parm;
 	struct tcf_police *p;
 
-	if (a == NULL) {
-		if (net_ratelimit())
-			printk("BUG: tcf_police_locate called with NULL "
-			       "params\n");
-		return -1;
-	}
-
 	if (rtattr_parse(tb, TCA_POLICE_MAX, RTA_DATA(rta),
 	                 RTA_PAYLOAD(rta)) < 0)
 		return -1;
@@ -290,11 +283,6 @@
 	long toks;
 	long ptoks = 0;
 
-	if (p == NULL) {
-		printk("BUG: tcf_police called with NULL params\n");
-		return -1;
-	}
-
 	spin_lock(&p->lock);
 
 	p->bstats.bytes += skb->len;
@@ -349,11 +337,6 @@
 	unsigned char	 *b = skb->tail;
 	struct tc_police opt;
 	struct tcf_police *p = PRIV(a);
-
-	if (p == NULL) {
-		printk("BUG: tcf_police_dump called with NULL params\n");
-		goto rtattr_failure;
-	}
 
 	opt.index = p->index;
 	opt.action = p->action;

--------------030509010300020508090902--
