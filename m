From: Patrick McHardy <kaber@trash.net>
Subject: [PATCH PKT_SCHED 3/22]: act_api.c: use consistent comparision style
Date: Mon, 10 Jan 2005 20:37:46 +0100
Message-ID: <41E2D98A.1030801@trash.net>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------090101080101070505020400"
Cc: Maillist netdev <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: jamal <hadi@cyberus.ca>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------090101080101070505020400
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit



--------------090101080101070505020400
Content-Type: text/x-patch;
 name="03.diff"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="03.diff"

# This is a BitKeeper generated diff -Nru style patch.
#
# ChangeSet
#   2005/01/09 20:41:48+01:00 kaber@coreworks.de 
#   [PKT_SCHED]: act_api.c: use consistent comparision style
#   
#   Signed-off-by: Patrick McHardy <kaber@trash.net>
# 
# net/sched/act_api.c
#   2005/01/09 20:41:41+01:00 kaber@coreworks.de +37 -40
#   [PKT_SCHED]: act_api.c: use consistent comparision style
#   
#   Signed-off-by: Patrick McHardy <kaber@trash.net>
# 
diff -Nru a/net/sched/act_api.c b/net/sched/act_api.c
--- a/net/sched/act_api.c	2005-01-10 06:21:51 +01:00
+++ b/net/sched/act_api.c	2005-01-10 06:21:51 +01:00
@@ -196,7 +196,7 @@
 			DPRINTK("tcf_action_destroy destroying %p next %p\n",
 			        a, a->next ? a->next : NULL);
 			act = act->next;
-			if (ACT_P_DELETED == a->ops->cleanup(a, bind))
+			if (a->ops->cleanup(a, bind) == ACT_P_DELETED)
 				module_put(a->ops->owner);
 			
 			a->ops = NULL;
@@ -220,7 +220,7 @@
 {
 	int err = -EINVAL;
 
-	if ((NULL == a) || (NULL == a->ops) || (NULL == a->ops->dump))
+	if ((a == NULL) || (a->ops == NULL) || (a->ops->dump == NULL))
 		return err;
 	return a->ops->dump(skb, a, bind, ref);
 }
@@ -232,8 +232,8 @@
 	unsigned char *b = skb->tail;
 	struct rtattr *r;
 
-	if ((NULL == a) || (NULL == a->ops) || (NULL == a->ops->dump) ||
-	    (NULL == a->ops->kind))
+	if ((a == NULL) || (a->ops == NULL) || (a->ops->dump == NULL) ||
+	    (a->ops->kind == NULL))
 		return err;
 
 	RTA_PUT(skb, TCA_KIND, IFNAMSIZ, a->ops->kind);
@@ -264,7 +264,7 @@
 		act = a->next;
 		RTA_PUT(skb, a->order, 0, NULL);
 		err = tcf_action_dump_1(skb, a, bind, ref);
-		if (0 > err)
+		if (err < 0)
 			goto rtattr_failure;
 		r->rta_len = skb->tail - (u8*)r;
 	}
@@ -287,12 +287,12 @@
 
 	*err = -EINVAL;
 
-	if (NULL == name) {
+	if (name == NULL) {
 		if (rtattr_parse(tb, TCA_ACT_MAX, RTA_DATA(rta),
 		                 RTA_PAYLOAD(rta)) < 0)
 			goto err_out;
 		kind = tb[TCA_ACT_KIND-1];
-		if (NULL != kind) {
+		if (kind != NULL) {
 			sprintf(act_name, "%s", (char*)RTA_DATA(kind));
 			if (RTA_PAYLOAD(kind) >= IFNAMSIZ) {
 				printk("Action %s bad\n",
@@ -310,7 +310,7 @@
 		a_o = tc_lookup_action_n(name);
 	}
 #ifdef CONFIG_KMOD
-	if (NULL == a_o) {
+	if (a_o == NULL) {
 		DPRINTK("tcf_action_init_1: trying to load module %s\n",
 		        act_name);
 		request_module(act_name);
@@ -318,7 +318,7 @@
 	}
 
 #endif
-	if (NULL == a_o) {
+	if (a_o == NULL) {
 		printk("failed to find %s\n", act_name);
 		goto err_out;
 	}
@@ -331,7 +331,7 @@
 	memset(a, 0, sizeof(*a));
 
 	/* backward compatibility for policer */
-	if (NULL == name) {
+	if (name == NULL) {
 		*err = a_o->init(tb[TCA_ACT_OPTIONS-1], est, a, ovr, bind);
 		if (*err < 0) {
 			*err = -EINVAL;
@@ -414,7 +414,7 @@
 	/* place holder */
 #endif
 
-	if (NULL == h)
+	if (h == NULL)
 		goto errout;
 
 	if (a->type == TCA_OLD_COMPAT)
@@ -427,7 +427,7 @@
 	if (err < 0)
 		goto errout;
 
-	if (NULL != a->ops && NULL != a->ops->get_stats)
+	if (a->ops != NULL && a->ops->get_stats != NULL)
 		if (a->ops->get_stats(skb, a) < 0)
 			goto errout;
 
@@ -464,7 +464,7 @@
 	x = (struct rtattr*) skb->tail;
 	RTA_PUT(skb, TCA_ACT_TAB, 0, NULL);
 
-	if (0 > tcf_action_dump(skb, a, bind, ref))
+	if (tcf_action_dump(skb, a, bind, ref) < 0)
 		goto rtattr_failure;
 
 	x->rta_len = skb->tail - (u8*)x;
@@ -510,7 +510,7 @@
 	if (rtattr_parse(tb, TCA_ACT_MAX, RTA_DATA(rta), RTA_PAYLOAD(rta)) < 0)
 		goto err_out;
 	kind = tb[TCA_ACT_KIND-1];
-	if (NULL != kind) {
+	if (kind != NULL) {
 		sprintf(act_name, "%s", (char*)RTA_DATA(kind));
 		if (RTA_PAYLOAD(kind) >= IFNAMSIZ) {
 			printk("tcf_action_get_1: action %s bad\n",
@@ -531,21 +531,21 @@
 
 	a_o = tc_lookup_action(kind);
 #ifdef CONFIG_KMOD
-	if (NULL == a_o) {
+	if (a_o == NULL) {
 		request_module (act_name);
 		a_o = tc_lookup_action_n(act_name);
 	}
 #endif
-	if (NULL == a_o) {
+	if (a_o == NULL) {
 		printk("failed to find %s\n", act_name);
 		goto err_out;
 	}
-	if (NULL == a)
+	if (a == NULL)
 		goto err_mod;
 
 	a->ops = a_o;
 
-	if (NULL == a_o->lookup || 0 == a_o->lookup(a, index)) {
+	if (a_o->lookup == NULL || a_o->lookup(a, index) == 0) {
 		a->ops = NULL;
 		err = -EINVAL;
 		goto err_mod;
@@ -579,7 +579,7 @@
 	char act_name[4 + IFNAMSIZ + 1];
 	struct tc_action_ops *a_o = NULL;
 
-	if (NULL != kind) {
+	if (kind != NULL) {
 		sprintf(act_name, "%s", (char*)RTA_DATA(kind));
 		if (RTA_PAYLOAD(kind) >= IFNAMSIZ) {
 			printk("get_ao: action %s bad\n",
@@ -593,14 +593,13 @@
 
 	a_o = tc_lookup_action(kind);
 #ifdef CONFIG_KMOD
-	if (NULL == a_o) {
+	if (a_o == NULL) {
 		DPRINTK("get_ao: trying to load module %s\n", act_name);
 		request_module(act_name);
 		a_o = tc_lookup_action_n(act_name);
 	}
 #endif
-
-	if (NULL == a_o) {
+	if (a_o == NULL) {
 		printk("get_ao: failed to find %s\n", act_name);
 		return NULL;
 	}
@@ -614,7 +613,7 @@
 	struct tc_action *act = NULL;
 
 	act = kmalloc(sizeof(*act), GFP_KERNEL);
-	if (NULL == act) { /* grrr .. */
+	if (act == NULL) {
 		printk("create_a: failed to alloc!\n");
 		return NULL;
 	}
@@ -636,7 +635,7 @@
 	struct tc_action *a = create_a(0);
 	int err = -EINVAL;
 
-	if (NULL == a) {
+	if (a == NULL) {
 		printk("tca_action_flush: couldnt create tc_action\n");
 		return err;
 	}
@@ -654,7 +653,7 @@
 		goto err_out;
 
 	kind = tb[TCA_ACT_KIND-1];
-	if (NULL == get_ao(kind, a))
+	if (get_ao(kind, a) == NULL)
 		goto err_out;
 
 	nlh = NLMSG_PUT(skb, pid, n->nlmsg_seq, RTM_DELACTION, sizeof(*t));
@@ -665,7 +664,7 @@
 	RTA_PUT(skb, TCA_ACT_TAB, 0, NULL);
 
 	err = a->ops->walk(skb, &dcb, RTM_DELACTION, a);
-	if (0 > err)
+	if (err < 0)
 		goto rtattr_failure;
 
 	x->rta_len = skb->tail - (u8 *) x;
@@ -680,7 +679,6 @@
 
 	return err;
 
-
 rtattr_failure:
 	module_put(a->ops->owner);
 nlmsg_failure:
@@ -709,15 +707,15 @@
 	}
 
 	if (event == RTM_DELACTION && n->nlmsg_flags&NLM_F_ROOT) {
-		if (NULL != tb[0] && NULL == tb[1])
+		if (tb[0] != NULL && tb[1] == NULL)
 			return tca_action_flush(tb[0], n, pid);
 	}
 
 	for (i=0; i < TCA_ACT_MAX_PRIO; i++) {
-		if (NULL == tb[i])
+		if (tb[i] == NULL)
 			break;
 		act = create_a(i+1);
-		if (NULL != a && a != act) {
+		if (a != NULL && a != act) {
 			a->next = act;
 			a = act;
 		} else
@@ -736,7 +734,7 @@
 		}
 	}
 
-	if (RTM_GETACTION == event)
+	if (event == RTM_GETACTION)
 		ret = act_get_notify(pid, n, a_s, event);
 	else { /* delete */
 		struct sk_buff *skb;
@@ -792,7 +790,7 @@
 	x = (struct rtattr*) skb->tail;
 	RTA_PUT(skb, TCA_ACT_TAB, 0, NULL);
 
-	if (0 > tcf_action_dump(skb, a, 0, 0))
+	if (tcf_action_dump(skb, a, 0, 0) < 0)
 		goto rtattr_failure;
 
 	x->rta_len = skb->tail - (u8*)x;
@@ -847,7 +845,7 @@
 	u32 pid = skb ? NETLINK_CB(skb).pid : 0;
 	int ret = 0, ovr = 0;
 
-	if (NULL == tca[TCA_ACT_TAB-1]) {
+	if (tca[TCA_ACT_TAB-1] == NULL) {
 		printk("tc_ctl_action: received NO action attribs\n");
 		return -EINVAL;
 	}
@@ -894,14 +892,13 @@
 	if (rtattr_parse(rta, TCAA_MAX, attr, attrlen) < 0)
 		return NULL;
 	tb1 = rta[TCA_ACT_TAB - 1];
-	if (NULL == tb1) {
+	if (tb1 == NULL)
 		return NULL;
-	}
 
 	if (rtattr_parse(tb, TCA_ACT_MAX_PRIO, RTA_DATA(tb1),
 	                 NLMSG_ALIGN(RTA_PAYLOAD(tb1))) < 0)
 		return NULL;
-	if (NULL == tb[0])
+	if (tb[0] == NULL)
 		return NULL;
 
 	if (rtattr_parse(tb2, TCA_ACT_MAX, RTA_DATA(tb[0]),
@@ -924,13 +921,13 @@
 	struct tcamsg *t = (struct tcamsg *) NLMSG_DATA(cb->nlh);
 	char *kind = find_dump_kind(cb->nlh);
 
-	if (NULL == kind) {
+	if (kind == NULL) {
 		printk("tc_dump_action: action bad kind\n");
 		return 0;
 	}
 
 	a_o = tc_lookup_action_n(kind);
-	if (NULL == a_o) {
+	if (a_o == NULL) {
 		printk("failed to find %s\n", kind);
 		return 0;
 	}
@@ -938,7 +935,7 @@
 	memset(&a, 0, sizeof(struct tc_action));
 	a.ops = a_o;
 
-	if (NULL == a_o->walk) {
+	if (a_o->walk == NULL) {
 		printk("tc_dump_action: %s !capable of dumping table\n", kind);
 		goto rtattr_failure;
 	}
@@ -952,7 +949,7 @@
 	RTA_PUT(skb, TCA_ACT_TAB, 0, NULL);
 
 	ret = a_o->walk(skb, cb, RTM_GETACTION, &a);
-	if (0 > ret)
+	if (ret < 0)
 		goto rtattr_failure;
 
 	if (ret > 0) {

--------------090101080101070505020400--
