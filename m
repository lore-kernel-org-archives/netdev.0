From: Patrick McHardy <kaber@trash.net>
Subject: [PATCH PKT_SCHED 10/17]: Clean up ipt action
Date: Thu, 30 Dec 2004 04:40:21 +0100
Message-ID: <41D378A5.9090702@trash.net>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------060706090705090305050802"
Cc: Maillist netdev <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: jamal <hadi@cyberus.ca>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------060706090705090305050802
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit

Whitespace cleanup, consistent comparision style,
break lines at 80 characters.


--------------060706090705090305050802
Content-Type: text/x-patch;
 name="10.diff"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="10.diff"

# This is a BitKeeper generated diff -Nru style patch.
#
# ChangeSet
#   2004/12/30 02:45:21+01:00 kaber@coreworks.de 
#   [PKT_SCHED]: Clean up ipt action
#   
#   - Whitespace cleanup
#   - Consistent comparision style
#   - Break lines at 80 characters
#   
#   Signed-off-by: Patrick McHardy <kaber@trash.net>
# 
# net/sched/ipt.c
#   2004/12/30 02:45:15+01:00 kaber@coreworks.de +18 -28
#   [PKT_SCHED]: Clean up ipt action
#   
#   - Whitespace cleanup
#   - Consistent comparision style
#   - Break lines at 80 characters
#   
#   Signed-off-by: Patrick McHardy <kaber@trash.net>
# 
diff -Nru a/net/sched/ipt.c b/net/sched/ipt.c
--- a/net/sched/ipt.c	2004-12-30 04:01:37 +01:00
+++ b/net/sched/ipt.c	2004-12-30 04:01:37 +01:00
@@ -93,7 +93,8 @@
 }
 
 static int
-tcf_ipt_init(struct rtattr *rta, struct rtattr *est, struct tc_action *a, int ovr, int bind)
+tcf_ipt_init(struct rtattr *rta, struct rtattr *est, struct tc_action *a,
+             int ovr, int bind)
 {
 	struct ipt_entry_target *t;
 	unsigned h;
@@ -103,12 +104,9 @@
 	u32 index = 0;
 	u32 hook = 0;
 
-	if (NULL == a || NULL == rta ||
-	    (rtattr_parse(tb, TCA_IPT_MAX, RTA_DATA(rta), RTA_PAYLOAD(rta)) <
-	     0)) {
+	if (a == NULL || rta == NULL ||
+	    rtattr_parse(tb, TCA_IPT_MAX, RTA_DATA(rta), RTA_PAYLOAD(rta)) < 0)
 		return -1;
-	}
-
 
 	if (tb[TCA_IPT_INDEX - 1]) {
 		index = *(u32 *) RTA_DATA(tb[TCA_IPT_INDEX - 1]);
@@ -129,15 +127,13 @@
 		return ret;
 	}
 
-	if (NULL == tb[TCA_IPT_TARG - 1] || NULL == tb[TCA_IPT_HOOK - 1]) {
+	if (tb[TCA_IPT_TARG - 1] == NULL || tb[TCA_IPT_HOOK - 1] == NULL)
 		return -1;
-	}
 
-	p = kmalloc(sizeof (*p), GFP_KERNEL);
+	p = kmalloc(sizeof(*p), GFP_KERNEL);
 	if (p == NULL)
 		return -1;
-
-	memset(p, 0, sizeof (*p));
+	memset(p, 0, sizeof(*p));
 	p->refcnt = 1;
 	ret = 1;
 	spin_lock_init(&p->lock);
@@ -192,7 +188,7 @@
 		}
 	}
 
-	if (0 > init_targ(p)) {
+	if (init_targ(p) < 0) {
 		if (ovr) {
 			printk("ipt policy messed up 2 \n");
 			spin_unlock(&p->lock);
@@ -225,7 +221,7 @@
 	p->next = tcf_ipt_ht[h];
 	tcf_ipt_ht[h] = p;
 	write_unlock_bh(&ipt_lock);
-	a->priv = (void *) p;
+	a->priv = p;
 	return ret;
 
 }
@@ -233,8 +229,8 @@
 static int
 tcf_ipt_cleanup(struct tc_action *a, int bind)
 {
-	struct tcf_ipt *p;
-	p = PRIV(a,ipt);
+	struct tcf_ipt *p = PRIV(a, ipt);
+
 	if (NULL != p)
 		return tcf_hash_release(p, bind);
 	return 0;
@@ -244,14 +240,11 @@
 tcf_ipt(struct sk_buff **pskb, struct tc_action *a)
 {
 	int ret = 0, result = 0;
-	struct tcf_ipt *p;
+	struct tcf_ipt *p = PRIV(a, ipt);
 	struct sk_buff *skb = *pskb;
 
-	p = PRIV(a,ipt);
-
-	if (NULL == p || NULL == skb) {
+	if (p == NULL || skb == NULL)
 		return -1;
-	}
 
 	spin_lock(&p->lock);
 
@@ -260,16 +253,15 @@
 	p->bstats.packets++;
 
 	if (skb_cloned(skb) ) {
-		if (pskb_expand_head(skb, 0, 0, GFP_ATOMIC)) {
+		if (pskb_expand_head(skb, 0, 0, GFP_ATOMIC))
 			return -1;
-		}
 	}
 	/* yes, we have to worry about both in and out dev
 	 worry later - danger - this API seems to have changed
 	 from earlier kernels */
 
 	ret = p->t->u.kernel.target->target(&skb, skb->dev, NULL,
-					    p->hook, p->t->data, (void *)NULL);
+					    p->hook, p->t->data, NULL);
 	switch (ret) {
 	case NF_ACCEPT:
 		result = TC_ACT_OK;
@@ -299,11 +291,9 @@
 	struct tcf_t tm;
 	struct tc_cnt c;
 	unsigned char *b = skb->tail;
+	struct tcf_ipt *p = PRIV(a, ipt);
 
-	struct tcf_ipt *p;
-
-	p = PRIV(a,ipt);
-	if (NULL == p) {
+	if (p == NULL) {
 		printk("BUG: tcf_ipt_dump called with NULL params\n");
 		goto rtattr_failure;
 	}
@@ -314,7 +304,7 @@
 
 	t = kmalloc(p->t->u.user.target_size, GFP_ATOMIC);
 
-	if (NULL == t)
+	if (t == NULL)
 		goto rtattr_failure;
 
 	c.bindcnt = p->bindcnt - bind;

--------------060706090705090305050802--
