From: Patrick McHardy <kaber@trash.net>
Subject: [PATCH PKT_SCHED 9/22]: tc actions: whitespace and coding style cleanup
Date: Mon, 10 Jan 2005 20:37:57 +0100
Message-ID: <41E2D995.4000501@trash.net>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------030809080002090402080508"
Cc: Maillist netdev <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: jamal <hadi@cyberus.ca>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------030809080002090402080508
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit



--------------030809080002090402080508
Content-Type: text/x-patch;
 name="09.diff"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="09.diff"

# This is a BitKeeper generated diff -Nru style patch.
#
# ChangeSet
#   2005/01/09 23:35:01+01:00 kaber@coreworks.de 
#   [PKT_SCHED]: tc actions: whitespace and coding style cleanup
#   
#   Signed-off-by: Patrick McHardy <kaber@trash.net>
# 
# net/sched/police.c
#   2005/01/09 23:34:55+01:00 kaber@coreworks.de +49 -48
#   [PKT_SCHED]: tc actions: whitespace and coding style cleanup
#   
#   Signed-off-by: Patrick McHardy <kaber@trash.net>
# 
# net/sched/pedit.c
#   2005/01/09 23:34:55+01:00 kaber@coreworks.de +36 -52
#   [PKT_SCHED]: tc actions: whitespace and coding style cleanup
#   
#   Signed-off-by: Patrick McHardy <kaber@trash.net>
# 
# net/sched/mirred.c
#   2005/01/09 23:34:55+01:00 kaber@coreworks.de +48 -58
#   [PKT_SCHED]: tc actions: whitespace and coding style cleanup
#   
#   Signed-off-by: Patrick McHardy <kaber@trash.net>
# 
# net/sched/ipt.c
#   2005/01/09 23:34:55+01:00 kaber@coreworks.de +28 -41
#   [PKT_SCHED]: tc actions: whitespace and coding style cleanup
#   
#   Signed-off-by: Patrick McHardy <kaber@trash.net>
# 
# net/sched/gact.c
#   2005/01/09 23:34:55+01:00 kaber@coreworks.de +35 -47
#   [PKT_SCHED]: tc actions: whitespace and coding style cleanup
#   
#   Signed-off-by: Patrick McHardy <kaber@trash.net>
# 
diff -Nru a/net/sched/gact.c b/net/sched/gact.c
--- a/net/sched/gact.c	2005-01-10 06:22:20 +01:00
+++ b/net/sched/gact.c	2005-01-10 06:22:20 +01:00
@@ -38,41 +38,41 @@
 /* use generic hash table */
 #define MY_TAB_SIZE	16
 #define MY_TAB_MASK	15
+
 static u32 idx_gen;
 static struct tcf_gact *tcf_gact_ht[MY_TAB_SIZE];
 static rwlock_t gact_lock = RW_LOCK_UNLOCKED;
 
 /* ovewrride the defaults */
-#define tcf_st  tcf_gact
-#define tc_st  tc_gact
-#define tcf_t_lock   gact_lock
-#define tcf_ht tcf_gact_ht
+#define tcf_st		tcf_gact
+#define tc_st		tc_gact
+#define tcf_t_lock	gact_lock
+#define tcf_ht		tcf_gact_ht
 
 #define CONFIG_NET_ACT_INIT 1
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
-static g_rand gact_rand[MAX_RAND]= { NULL,gact_net_rand, gact_determ};
-
+typedef int (*g_rand)(struct tcf_gact *p);
+static g_rand gact_rand[MAX_RAND]= { NULL, gact_net_rand, gact_determ };
 #endif
-static int
-tcf_gact_init(struct rtattr *rta, struct rtattr *est, struct tc_action *a,int ovr,int bind)
+
+static int tcf_gact_init(struct rtattr *rta, struct rtattr *est,
+                         struct tc_action *a, int ovr, int bind)
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
@@ -178,14 +170,10 @@
 {
 	unsigned char *b = skb->tail;
 	struct tc_gact opt;
-#ifdef CONFIG_GACT_PROB
-	struct tc_gact_p p_opt;
-#endif
-	struct tcf_gact *p;
+	struct tcf_gact *p = PRIV(a, gact);
 	struct tcf_t t;
 
-	p = PRIV(a,gact);
-	if (NULL == p) {
+	if (p == NULL) {
 		printk("BUG: tcf_gact_dump called with NULL params\n");
 		goto rtattr_failure;
 	}
@@ -194,19 +182,20 @@
 	opt.refcnt = p->refcnt - ref;
 	opt.bindcnt = p->bindcnt - bind;
 	opt.action = p->action;
-	RTA_PUT(skb, TCA_GACT_PARMS, sizeof (opt), &opt);
+	RTA_PUT(skb, TCA_GACT_PARMS, sizeof(opt), &opt);
 #ifdef CONFIG_GACT_PROB
 	if (p->ptype) {
+		struct tc_gact_p p_opt;
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
@@ -215,7 +204,6 @@
 }
 
 static struct tc_action_ops act_gact_ops = {
-	.next		=	NULL,
 	.kind		=	"gact",
 	.type		=	TCA_ACT_GACT,
 	.capab		=	TCA_CAP_NONE,
diff -Nru a/net/sched/ipt.c b/net/sched/ipt.c
--- a/net/sched/ipt.c	2005-01-10 06:22:20 +01:00
+++ b/net/sched/ipt.c	2005-01-10 06:22:20 +01:00
@@ -49,9 +49,9 @@
 static rwlock_t ipt_lock = RW_LOCK_UNLOCKED;
 
 /* ovewrride the defaults */
-#define tcf_st  tcf_ipt
-#define tcf_t_lock   ipt_lock
-#define tcf_ht tcf_ipt_ht
+#define tcf_st		tcf_ipt
+#define tcf_t_lock	ipt_lock
+#define tcf_ht		tcf_ipt_ht
 
 #include <net/pkt_act.h>
 
@@ -73,8 +73,8 @@
 
 	if (t->u.kernel.target->checkentry
 	    && !t->u.kernel.target->checkentry(p->tname, NULL, t->data,
-					       t->u.target_size
-					       - sizeof (*t), p->hook)) {
+					       t->u.target_size - sizeof(*t),
+					       p->hook)) {
 		DPRINTK("ip_tables: check failed for `%s'.\n",
 			t->u.kernel.target->name);
 		module_put(t->u.kernel.target->me);
@@ -85,7 +85,8 @@
 }
 
 static int
-tcf_ipt_init(struct rtattr *rta, struct rtattr *est, struct tc_action *a, int ovr, int bind)
+tcf_ipt_init(struct rtattr *rta, struct rtattr *est, struct tc_action *a,
+             int ovr, int bind)
 {
 	struct ipt_entry_target *t;
 	unsigned h;
@@ -95,12 +96,9 @@
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
@@ -114,22 +112,19 @@
 			p->bindcnt += 1;
 			p->refcnt += 1;
 		}
-		if (ovr) {
+		if (ovr)
 			goto override;
-		}
 		spin_unlock(&p->lock);
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
@@ -184,7 +179,7 @@
 		}
 	}
 
-	if (0 > init_targ(p)) {
+	if (init_targ(p) < 0) {
 		if (ovr) {
 			printk("ipt policy messed up 2 \n");
 			spin_unlock(&p->lock);
@@ -217,7 +212,7 @@
 	p->next = tcf_ipt_ht[h];
 	tcf_ipt_ht[h] = p;
 	write_unlock_bh(&ipt_lock);
-	a->priv = (void *) p;
+	a->priv = p;
 	return ret;
 
 }
@@ -225,8 +220,8 @@
 static int
 tcf_ipt_cleanup(struct tc_action *a, int bind)
 {
-	struct tcf_ipt *p;
-	p = PRIV(a,ipt);
+	struct tcf_ipt *p = PRIV(a,ipt);
+
 	if (NULL != p) {
 		struct ipt_entry_target *t = p->t;
 		if (t && t->u.kernel.target)
@@ -240,14 +235,11 @@
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
 
@@ -256,16 +248,15 @@
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
@@ -295,11 +286,9 @@
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
@@ -309,8 +298,7 @@
 	*/
 
 	t = kmalloc(p->t->u.user.target_size, GFP_ATOMIC);
-
-	if (NULL == t)
+	if (t == NULL)
 		goto rtattr_failure;
 
 	c.bindcnt = p->bindcnt - bind;
@@ -320,10 +308,10 @@
 
 	DPRINTK("\ttcf_ipt_dump tablename %s length %d\n", p->tname,
 		strlen(p->tname));
-	DPRINTK
-	    ("\tdump target name %s size %d size user %d data[0] %x data[1] %x\n",
-	     p->t->u.kernel.target->name, p->t->u.target_size, p->t->u.user.target_size,
-	     p->t->data[0], p->t->data[1]);
+	DPRINTK("\tdump target name %s size %d size user %d "
+	        "data[0] %x data[1] %x\n", p->t->u.kernel.target->name,
+	        p->t->u.target_size, p->t->u.user.target_size,
+	        p->t->data[0], p->t->data[1]);
 	RTA_PUT(skb, TCA_IPT_TARG, p->t->u.user.target_size, t);
 	RTA_PUT(skb, TCA_IPT_INDEX, 4, &p->index);
 	RTA_PUT(skb, TCA_IPT_HOOK, 4, &p->hook);
@@ -341,7 +329,6 @@
 }
 
 static struct tc_action_ops act_ipt_ops = {
-	.next		=	NULL,
 	.kind		=	"ipt",
 	.type		=	TCA_ACT_IPT,
 	.capab		=	TCA_CAP_NONE,
diff -Nru a/net/sched/mirred.c b/net/sched/mirred.c
--- a/net/sched/mirred.c	2005-01-10 06:22:20 +01:00
+++ b/net/sched/mirred.c	2005-01-10 06:22:20 +01:00
@@ -49,10 +49,10 @@
 static rwlock_t mirred_lock = RW_LOCK_UNLOCKED;
 
 /* ovewrride the defaults */
-#define tcf_st  tcf_mirred
-#define tc_st  tc_mirred
-#define tcf_t_lock   mirred_lock
-#define tcf_ht tcf_mirred_ht
+#define tcf_st		tcf_mirred
+#define tc_st		tc_mirred
+#define tcf_t_lock	mirred_lock
+#define tcf_ht		tcf_mirred_ht
 
 #define CONFIG_NET_ACT_INIT 1
 #include <net/pkt_act.h>
@@ -61,10 +61,8 @@
 tcf_mirred_release(struct tcf_mirred *p, int bind)
 {
 	if (p) {
-		if (bind) {
+		if (bind)
 			p->bindcnt--;
-		}
-
 		p->refcnt--;
 		if(!p->bindcnt && p->refcnt <= 0) {
 			dev_put(p->dev);
@@ -72,26 +70,27 @@
 			return 1;
 		}
 	}
-
 	return 0;
 }
 
 static int
-tcf_mirred_init(struct rtattr *rta, struct rtattr *est, struct tc_action *a,int ovr, int bind)
+tcf_mirred_init(struct rtattr *rta, struct rtattr *est, struct tc_action *a,
+                int ovr, int bind)
 {
 	struct rtattr *tb[TCA_MIRRED_MAX];
 	struct tc_mirred *parm;
 	struct tcf_mirred *p;
 	struct net_device *dev = NULL;
-	int size = sizeof (*p), new = 0;
+	int size = sizeof(*p), new = 0;
 
-
-	if (rtattr_parse(tb, TCA_MIRRED_MAX, RTA_DATA(rta), RTA_PAYLOAD(rta)) < 0) {
-		DPRINTK("tcf_mirred_init BUG in user space couldnt parse properly\n");
+	if (rtattr_parse(tb, TCA_MIRRED_MAX, RTA_DATA(rta),
+	                 RTA_PAYLOAD(rta)) < 0) {
+		DPRINTK("tcf_mirred_init BUG in user space couldnt parse "
+		        "properly\n");
 		return -1;
 	}
 
-	if (NULL == a || NULL == tb[TCA_MIRRED_PARMS - 1]) {
+	if (a == NULL || tb[TCA_MIRRED_PARMS - 1] == NULL) {
 		DPRINTK("BUG: tcf_mirred_init called with NULL params\n");
 		return -1;
 	}
@@ -99,16 +98,16 @@
 	parm = RTA_DATA(tb[TCA_MIRRED_PARMS - 1]);
 
 	p = tcf_hash_check(parm, a, ovr, bind);
-	if (NULL == p) { /* new */
-		p = tcf_hash_create(parm,est,a,size,ovr,bind);
-		new = 1;
-		if (NULL == p)
+	if (p == NULL) { /* new */
+		p = tcf_hash_create(parm, est, a, size, ovr, bind);
+		if (p == NULL)
 			return -1;
+		new = 1;
 	}
 
 	if (parm->ifindex) {
 		dev = dev_get_by_index(parm->ifindex);
-		if (NULL == dev) {
+		if (dev == NULL) {
 			printk("BUG: tcf_mirred_init called with bad device\n");
 			return -1;
 		}
@@ -145,18 +144,18 @@
 		spin_unlock(&p->lock);
 	}
 
-
-	DPRINTK(" tcf_mirred_init index %d action %d eaction %d device %s ifndex %d\n",parm->index,parm->action,parm->eaction,dev->name,parm->ifindex);
+	DPRINTK("tcf_mirred_init index %d action %d eaction %d device %s "
+	        "ifindex %d\n", parm->index, parm->action, parm->eaction,
+	        dev->name, parm->ifindex);
 	return new;
-
 }
 
 static int
 tcf_mirred_cleanup(struct tc_action *a, int bind)
 {
-	struct tcf_mirred *p;
-	p = PRIV(a,mirred);
-	if (NULL != p)
+	struct tcf_mirred *p = PRIV(a, mirred);
+
+	if (p != NULL)
 		return tcf_mirred_release(p, bind);
 	return 0;
 }
@@ -164,21 +163,19 @@
 static int
 tcf_mirred(struct sk_buff **pskb, struct tc_action *a)
 {
-	struct tcf_mirred *p;
+	struct tcf_mirred *p = PRIV(a, mirred);
 	struct net_device *dev;
 	struct sk_buff *skb2 = NULL;
 	struct sk_buff *skb = *pskb;
-	__u32 at = G_TC_AT(skb->tc_verd);
+	u32 at = G_TC_AT(skb->tc_verd);
 
-	if (NULL == a) {
+	if (a == NULL) {
 		if (net_ratelimit())
 			printk("BUG: tcf_mirred called with NULL action!\n");
 		return -1;
 	}
 
-	p = PRIV(a,mirred);
-
-	if (NULL == p) {
+	if (p == NULL) {
 		if (net_ratelimit())
 			printk("BUG: tcf_mirred called with NULL params\n");
 		return -1;
@@ -186,48 +183,44 @@
 
 	spin_lock(&p->lock);
 
-       	dev = p->dev;
+	dev = p->dev;
 	p->tm.lastuse = jiffies;
 
-	if (NULL == dev || !(dev->flags&IFF_UP) ) {
+	if (dev == NULL || !(dev->flags&IFF_UP) ) {
 		if (net_ratelimit())
 			printk("mirred to Houston: device %s is gone!\n",
-					dev?dev->name:"");
+			       dev ? dev->name : "");
 bad_mirred:
-		if (NULL != skb2)
+		if (skb2 != NULL)
 			kfree_skb(skb2);
 		p->qstats.overlimits++;
 		p->bstats.bytes += skb->len;
 		p->bstats.packets++;
 		spin_unlock(&p->lock);
 		/* should we be asking for packet to be dropped?
-		 * may make sense for redirect case only 
+		 * may make sense for redirect case only
 		*/
 		return TC_ACT_SHOT;
-	} 
+	}
 
 	skb2 = skb_clone(skb, GFP_ATOMIC);
-	if (skb2 == NULL) {
+	if (skb2 == NULL)
 		goto bad_mirred;
-	}
-	if (TCA_EGRESS_MIRROR != p->eaction &&
-		TCA_EGRESS_REDIR != p->eaction) {
+	if (p->eaction != TCA_EGRESS_MIRROR && p->eaction != TCA_EGRESS_REDIR) {
 		if (net_ratelimit())
-			printk("tcf_mirred unknown action %d\n",p->eaction);
+			printk("tcf_mirred unknown action %d\n", p->eaction);
 		goto bad_mirred;
 	}
 
 	p->bstats.bytes += skb2->len;
 	p->bstats.packets++;
-	if ( !(at & AT_EGRESS)) {
-		if (p->ok_push) {
+	if (!(at & AT_EGRESS))
+		if (p->ok_push)
 			skb_push(skb2, skb2->dev->hard_header_len);
-		}
-	}
 
 	/* mirror is always swallowed */
-	if (TCA_EGRESS_MIRROR != p->eaction)
-		skb2->tc_verd = SET_TC_FROM(skb2->tc_verd,at);
+	if (p->eaction != TCA_EGRESS_MIRROR)
+		skb2->tc_verd = SET_TC_FROM(skb2->tc_verd, at);
 
 	skb2->dev = dev;
 	skb2->input_dev = skb->dev;
@@ -237,15 +230,14 @@
 }
 
 static int
-tcf_mirred_dump(struct sk_buff *skb, struct tc_action *a,int bind, int ref)
+tcf_mirred_dump(struct sk_buff *skb, struct tc_action *a, int bind, int ref)
 {
 	unsigned char *b = skb->tail;
 	struct tc_mirred opt;
-	struct tcf_mirred *p;
+	struct tcf_mirred *p = PRIV(a, mirred);
 	struct tcf_t t;
 
-	p = PRIV(a,mirred);
-	if (NULL == p) {
+	if (p == NULL) {
 		printk("BUG: tcf_mirred_dump called with NULL params\n");
 		goto rtattr_failure;
 	}
@@ -256,12 +248,13 @@
 	opt.bindcnt = p->bindcnt - bind;
 	opt.eaction = p->eaction;
 	opt.ifindex = p->ifindex;
-	DPRINTK(" tcf_mirred_dump index %d action %d eaction %d ifndex %d\n",p->index,p->action,p->eaction,p->ifindex);
-	RTA_PUT(skb, TCA_MIRRED_PARMS, sizeof (opt), &opt);
+	DPRINTK("tcf_mirred_dump index %d action %d eaction %d ifindex %d\n",
+	         p->index, p->action, p->eaction, p->ifindex);
+	RTA_PUT(skb, TCA_MIRRED_PARMS, sizeof(opt), &opt);
 	t.install = jiffies_to_clock_t(jiffies - p->tm.install);
 	t.lastuse = jiffies_to_clock_t(jiffies - p->tm.lastuse);
 	t.expires = jiffies_to_clock_t(p->tm.expires);
-	RTA_PUT(skb, TCA_MIRRED_TM, sizeof (t), &t);
+	RTA_PUT(skb, TCA_MIRRED_TM, sizeof(t), &t);
 	return skb->len;
 
       rtattr_failure:
@@ -270,7 +263,6 @@
 }
 
 static struct tc_action_ops act_mirred_ops = {
-	.next		=	NULL,
 	.kind		=	"mirred",
 	.type		=	TCA_ACT_MIRRED,
 	.capab		=	TCA_CAP_NONE,
@@ -287,7 +279,6 @@
 MODULE_DESCRIPTION("Device Mirror/redirect actions");
 MODULE_LICENSE("GPL");
 
-
 static int __init
 mirred_init_module(void)
 {
@@ -303,4 +294,3 @@
 
 module_init(mirred_init_module);
 module_exit(mirred_cleanup_module);
-
diff -Nru a/net/sched/pedit.c b/net/sched/pedit.c
--- a/net/sched/pedit.c	2005-01-10 06:22:20 +01:00
+++ b/net/sched/pedit.c	2005-01-10 06:22:20 +01:00
@@ -44,46 +44,40 @@
 static struct tcf_pedit *tcf_pedit_ht[MY_TAB_SIZE];
 static rwlock_t pedit_lock = RW_LOCK_UNLOCKED;
 
-#define tcf_st  tcf_pedit
-#define tc_st  tc_pedit
-#define tcf_t_lock   pedit_lock
-#define tcf_ht tcf_pedit_ht
+#define tcf_st		tcf_pedit
+#define tc_st		tc_pedit
+#define tcf_t_lock	pedit_lock
+#define tcf_ht		tcf_pedit_ht
 
 #define CONFIG_NET_ACT_INIT 1
 #include <net/pkt_act.h>
 
-
 static int
-tcf_pedit_init(struct rtattr *rta, struct rtattr *est, struct tc_action *a,int ovr, int bind)
+tcf_pedit_init(struct rtattr *rta, struct rtattr *est, struct tc_action *a,
+               int ovr, int bind)
 {
 	struct rtattr *tb[TCA_PEDIT_MAX];
 	struct tc_pedit *parm;
 	int size = 0;
 	int ret = 0;
-	struct tcf_pedit *p = NULL;
+	struct tcf_pedit *p;
 
-	if (rtattr_parse(tb, TCA_PEDIT_MAX, RTA_DATA(rta), RTA_PAYLOAD(rta)) < 0)
+	if (rtattr_parse(tb, TCA_PEDIT_MAX, RTA_DATA(rta),
+	                 RTA_PAYLOAD(rta)) < 0)
 		return -1;
-
-	if (NULL == a || NULL == tb[TCA_PEDIT_PARMS - 1]) {
+	if (a == NULL || tb[TCA_PEDIT_PARMS - 1] == NULL) {
 		printk("BUG: tcf_pedit_init called with NULL params\n");
 		return -1;
 	}
 
 	parm = RTA_DATA(tb[TCA_PEDIT_PARMS - 1]);
-
 	p = tcf_hash_check(parm, a, ovr, bind);
-
-	if (NULL == p) { /* new */
-
+	if (p == NULL) { /* new */
 		if (!parm->nkeys)
 			return -1;
-
-		size = sizeof (*p)+ (parm->nkeys*sizeof(struct tc_pedit_key));
-
-		p = tcf_hash_create(parm,est,a,size,ovr,bind);
-
-		if (NULL == p)
+		size = sizeof(*p) + parm->nkeys * sizeof(struct tc_pedit_key);
+		p = tcf_hash_create(parm, est, a, size, ovr, bind);
+		if (p == NULL)
 			return -1;
 		ret = 1;
 		goto override;
@@ -94,7 +88,8 @@
 		p->flags = parm->flags;
 		p->nkeys = parm->nkeys;
 		p->action = parm->action;
-		memcpy(p->keys,parm->keys,parm->nkeys*(sizeof(struct tc_pedit_key)));
+		memcpy(p->keys, parm->keys,
+		       parm->nkeys * sizeof(struct tc_pedit_key));
 	}
 
 	return ret;
@@ -103,27 +98,22 @@
 static int
 tcf_pedit_cleanup(struct tc_action *a, int bind)
 {
-	struct tcf_pedit *p;
-	p = PRIV(a,pedit);
+	struct tcf_pedit *p = PRIV(a, pedit);
+
 	if (NULL != p)
-		return	tcf_hash_release(p, bind);
+		return tcf_hash_release(p, bind);
 	return 0;
 }
 
-/*
-**
-*/
 static int
 tcf_pedit(struct sk_buff **pskb, struct tc_action *a)
 {
-	struct tcf_pedit *p;
+	struct tcf_pedit *p = PRIV(a, pedit);
 	struct sk_buff *skb = *pskb;
 	int i, munged = 0;
 	u8 *pptr;
 
-	p = PRIV(a,pedit);
-
-	if (NULL == p) {
+	if (p == NULL) {
 		printk("BUG: tcf_pedit called with NULL params\n");
 		return -1; /* change to something symbolic */
 	}
@@ -141,17 +131,18 @@
 
 	p->tm.lastuse = jiffies;
 
-	if (0 < p->nkeys) {
+	if (p->nkeys > 0) {
 		struct tc_pedit_key *tkey = p->keys;
 
 		for (i = p->nkeys; i > 0; i--, tkey++) {
-			u32 *ptr ;
-
+			u32 *ptr;
 			int offset = tkey->off;
+
 			if (tkey->offmask) {
 				if (skb->len > tkey->at) {
-					 char *j = pptr+tkey->at;
-					 offset +=((*j&tkey->offmask)>>tkey->shift);
+					 char *j = pptr + tkey->at;
+					 offset += ((*j & tkey->offmask) >> 
+					           tkey->shift);
 				} else {
 					goto bad;
 				}
@@ -161,14 +152,12 @@
 				printk("offset must be on 32 bit boundaries\n");
 				goto bad;
 			}
-
 			if (skb->len < 0 || (offset > 0 && offset > skb->len)) {
 				printk("offset %d cant exceed pkt length %d\n",
-						offset, skb->len);
+				       offset, skb->len);
 				goto bad;
 			}
 
-
 			ptr = (u32 *)(pptr+offset);
 			/* just do it, baby */
 			*ptr = ((*ptr & tkey->mask) ^ tkey->val);
@@ -196,29 +185,24 @@
 {
 	unsigned char *b = skb->tail;
 	struct tc_pedit *opt;
-	struct tcf_pedit *p;
+	struct tcf_pedit *p = PRIV(a, pedit);
 	struct tcf_t t;
 	int s; 
 		
-
-	p = PRIV(a,pedit);
-
-	if (NULL == p) {
+	if (p == NULL) {
 		printk("BUG: tcf_pedit_dump called with NULL params\n");
 		goto rtattr_failure;
 	}
 
-	s = sizeof (*opt)+(p->nkeys*sizeof(struct tc_pedit_key));
+	s = sizeof(*opt) + p->nkeys * sizeof(struct tc_pedit_key);
 
-	/* netlink spinlocks held above us - must use ATOMIC
-	 * */
+	/* netlink spinlocks held above us - must use ATOMIC */
 	opt = kmalloc(s, GFP_ATOMIC);
 	if (opt == NULL)
 		return -ENOBUFS;
-
 	memset(opt, 0, s);
 
-	memcpy(opt->keys,p->keys,p->nkeys*(sizeof(struct tc_pedit_key)));
+	memcpy(opt->keys, p->keys, p->nkeys * sizeof(struct tc_pedit_key));
 	opt->index = p->index;
 	opt->nkeys = p->nkeys;
 	opt->flags = p->flags;
@@ -239,15 +223,15 @@
 			(unsigned int)key->off,
 			(unsigned int)key->val,
 			(unsigned int)key->mask);
-												}
-											}
+		}
+	}
 #endif
 
 	RTA_PUT(skb, TCA_PEDIT_PARMS, s, opt);
 	t.install = jiffies_to_clock_t(jiffies - p->tm.install);
 	t.lastuse = jiffies_to_clock_t(jiffies - p->tm.lastuse);
 	t.expires = jiffies_to_clock_t(p->tm.expires);
-	RTA_PUT(skb, TCA_PEDIT_TM, sizeof (t), &t);
+	RTA_PUT(skb, TCA_PEDIT_TM, sizeof(t), &t);
 	return skb->len;
 
 rtattr_failure:
diff -Nru a/net/sched/police.c b/net/sched/police.c
--- a/net/sched/police.c	2005-01-10 06:22:20 +01:00
+++ b/net/sched/police.c	2005-01-10 06:22:20 +01:00
@@ -66,11 +66,12 @@
 }
 
 #ifdef CONFIG_NET_CLS_ACT
-static __inline__ int tcf_generic_walker(struct sk_buff *skb, struct netlink_callback *cb, int type, struct tc_action *a)
+static int tcf_generic_walker(struct sk_buff *skb, struct netlink_callback *cb,
+                              int type, struct tc_action *a)
 {
 	struct tcf_police *p;
-	int err =0, index =  -1,i= 0, s_i = 0, n_i = 0;
-	struct rtattr *r ;
+	int err = 0, index = -1, i = 0, s_i = 0, n_i = 0;
+	struct rtattr *r;
 
 	read_lock(&police_lock);
 
@@ -91,7 +92,7 @@
 				err = tcf_action_dump_1(skb, a, 0, 1);
 			else
 				err = tcf_action_dump_1(skb, a, 0, 0);
-			if (0 > err) {
+			if (err < 0) {
 				index--;
 				skb_trim(skb, (u8*)r - skb->data);
 				goto done;
@@ -123,11 +124,9 @@
 		return 0;
 	}
 }
-
-
 #endif
 
-static __inline__ u32 tcf_police_new_index(void)
+static inline u32 tcf_police_new_index(void)
 {
 	do {
 		if (++idx_gen == 0)
@@ -137,7 +136,6 @@
 	return idx_gen;
 }
 
-
 void tcf_police_destroy(struct tcf_police *p)
 {
 	unsigned h = tcf_police_hash(p->index);
@@ -163,7 +161,8 @@
 }
 
 #ifdef CONFIG_NET_CLS_ACT
-static int tcf_act_police_locate(struct rtattr *rta, struct rtattr *est,struct tc_action *a, int ovr, int bind)
+static int tcf_act_police_locate(struct rtattr *rta, struct rtattr *est,
+                                 struct tc_action *a, int ovr, int bind)
 {
 	unsigned h;
 	int ret = 0;
@@ -171,13 +170,15 @@
 	struct tc_police *parm;
 	struct tcf_police *p;
 
-	if (NULL == a) {
+	if (a == NULL) {
 		if (net_ratelimit())
-			printk("BUG: tcf_police_locate called with NULL params\n");
-		return -1;  
+			printk("BUG: tcf_police_locate called with NULL "
+			       "params\n");
+		return -1;
 	}
 
-	if (rtattr_parse(tb, TCA_POLICE_MAX, RTA_DATA(rta), RTA_PAYLOAD(rta)) < 0)
+	if (rtattr_parse(tb, TCA_POLICE_MAX, RTA_DATA(rta),
+	                 RTA_PAYLOAD(rta)) < 0)
 		return -1;
 
 	if (tb[TCA_POLICE_TBF-1] == NULL ||
@@ -185,26 +186,24 @@
 		return -1;
 
 	parm = RTA_DATA(tb[TCA_POLICE_TBF-1]);
-
 	if (parm->index && (p = tcf_police_lookup(parm->index)) != NULL) {
-		a->priv = (void *)p;
+		a->priv = p;
 		spin_lock(&p->lock);
 		if (bind) {
 			p->bindcnt += 1;
 			p->refcnt += 1;
 		}
-		if (ovr) {
+		if (ovr)
 			goto override;
-		}
 		spin_unlock(&p->lock);
-		return ret; 
+		return ret;
 	}
 
 	p = kmalloc(sizeof(*p), GFP_KERNEL);
 	if (p == NULL)
 		return -1;
-
 	memset(p, 0, sizeof(*p));
+
 	ret = 1;
 	p->refcnt = 1;
 	spin_lock_init(&p->lock);
@@ -213,12 +212,14 @@
 		p->bindcnt = 1;
 override:
 	if (parm->rate.rate) {
-		if ((p->R_tab = qdisc_get_rtab(&parm->rate, tb[TCA_POLICE_RATE-1])) == NULL) {
-			goto failure;
-		}
-		if (parm->peakrate.rate &&
-		    (p->P_tab = qdisc_get_rtab(&parm->peakrate, tb[TCA_POLICE_PEAKRATE-1])) == NULL) {
+		p->R_tab = qdisc_get_rtab(&parm->rate, tb[TCA_POLICE_RATE-1]);
+		if (p->R_tab == NULL)
 			goto failure;
+		if (parm->peakrate.rate) {
+			p->P_tab = qdisc_get_rtab(&parm->peakrate,
+					          tb[TCA_POLICE_PEAKRATE-1]);
+			if (p->P_tab == NULL)
+				goto failure;
 		}
 	}
 	if (tb[TCA_POLICE_RESULT-1]) {
@@ -260,8 +261,8 @@
 	tcf_police_ht[h] = p;
 	write_unlock_bh(&police_lock);
 
-	a->priv = (void *)p;
-	return ret;  
+	a->priv = p;
+	return ret;
 
 failure:
 	if (p->R_tab)
@@ -274,11 +275,10 @@
 
 static int tcf_act_police_cleanup(struct tc_action *a, int bind)
 {
-	struct tcf_police *p;
-	p = PRIV(a);
-	if (NULL != p) 
-		return tcf_police_release(p, bind);
+	struct tcf_police *p = PRIV(a);
 
+	if (p != NULL)
+		return tcf_police_release(p, bind);
 	return 0;
 }
 
@@ -286,15 +286,13 @@
 {
 	psched_time_t now;
 	struct sk_buff *skb = *pskb;
-	struct tcf_police *p;
+	struct tcf_police *p = PRIV(a);
 	long toks;
 	long ptoks = 0;
 
-	p = PRIV(a);
-
-	if (NULL == p) {
+	if (p == NULL) {
 		printk("BUG: tcf_police called with NULL params\n");
-		return -1;  
+		return -1;
 	}
 
 	spin_lock(&p->lock);
@@ -345,14 +343,14 @@
 	return p->action;
 }
 
-static int tcf_act_police_dump(struct sk_buff *skb, struct tc_action *a, int bind, int ref)
+static int
+tcf_act_police_dump(struct sk_buff *skb, struct tc_action *a, int bind, int ref)
 {
 	unsigned char	 *b = skb->tail;
 	struct tc_police opt;
-	struct tcf_police *p;
+	struct tcf_police *p = PRIV(a);
 
-	p = PRIV(a);
-	if (NULL == p) {
+	if (p == NULL) {
 		printk("BUG: tcf_police_dump called with NULL params\n");
 		goto rtattr_failure;
 	}
@@ -389,12 +387,10 @@
 MODULE_DESCRIPTION("Policing actions");
 MODULE_LICENSE("GPL");
 
-
 static struct tc_action_ops act_police_ops = {
-	.next		=	NULL,
 	.kind		=	"police",
-	.type		=	TCA_ID_POLICE, 
-	.capab		=	TCA_CAP_NONE, 
+	.type		=	TCA_ID_POLICE,
+	.capab		=	TCA_CAP_NONE,
 	.owner		=	THIS_MODULE,
 	.act		=	tcf_act_police,
 	.dump		=	tcf_act_police_dump,
@@ -428,7 +424,8 @@
 	struct rtattr *tb[TCA_POLICE_MAX];
 	struct tc_police *parm;
 
-	if (rtattr_parse(tb, TCA_POLICE_MAX, RTA_DATA(rta), RTA_PAYLOAD(rta)) < 0)
+	if (rtattr_parse(tb, TCA_POLICE_MAX, RTA_DATA(rta),
+	                 RTA_PAYLOAD(rta)) < 0)
 		return NULL;
 
 	if (tb[TCA_POLICE_TBF-1] == NULL ||
@@ -451,11 +448,15 @@
 	spin_lock_init(&p->lock);
 	p->stats_lock = &p->lock;
 	if (parm->rate.rate) {
-		if ((p->R_tab = qdisc_get_rtab(&parm->rate, tb[TCA_POLICE_RATE-1])) == NULL)
-			goto failure;
-		if (parm->peakrate.rate &&
-		    (p->P_tab = qdisc_get_rtab(&parm->peakrate, tb[TCA_POLICE_PEAKRATE-1])) == NULL)
+		p->R_tab = qdisc_get_rtab(&parm->rate, tb[TCA_POLICE_RATE-1]);
+		if (p->R_tab == NULL)
 			goto failure;
+		if (parm->peakrate.rate) {
+			p->P_tab = qdisc_get_rtab(&parm->peakrate,
+			                          tb[TCA_POLICE_PEAKRATE-1]);
+			if (p->P_tab == NULL)
+				goto failure;
+		}
 	}
 	if (tb[TCA_POLICE_RESULT-1]) {
 		if (RTA_PAYLOAD(tb[TCA_POLICE_RESULT-1]) != sizeof(u32))

--------------030809080002090402080508--
