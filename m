From: Patrick McHardy <kaber@trash.net>
Subject: [PATCH PKT_SCHED 2/22]: act_api.c: whitespace and coding style cleanup
Date: Mon, 10 Jan 2005 20:37:44 +0100
Message-ID: <41E2D988.4090503@trash.net>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------090101090401050203030104"
Cc: Maillist netdev <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: jamal <hadi@cyberus.ca>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------090101090401050203030104
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit



--------------090101090401050203030104
Content-Type: text/x-patch;
 name="02.diff"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="02.diff"

# This is a BitKeeper generated diff -Nru style patch.
#
# ChangeSet
#   2005/01/09 20:39:27+01:00 kaber@coreworks.de 
#   [PKT_SCHED]: act_api.c: whitespace and coding style cleanup
#   
#   Signed-off-by: Patrick McHardy <kaber@trash.net>
# 
# net/sched/act_api.c
#   2005/01/09 20:39:18+01:00 kaber@coreworks.de +141 -184
#   [PKT_SCHED]: act_api.c: whitespace and coding style cleanup
#   
#   Signed-off-by: Patrick McHardy <kaber@trash.net>
# 
diff -Nru a/net/sched/act_api.c b/net/sched/act_api.c
--- a/net/sched/act_api.c	2005-01-10 06:21:47 +01:00
+++ b/net/sched/act_api.c	2005-01-10 06:21:47 +01:00
@@ -35,14 +35,14 @@
 #include <net/act_api.h>
 
 #if 1 /* control */
-#define DPRINTK(format,args...) printk(KERN_DEBUG format,##args)
+#define DPRINTK(format, args...) printk(KERN_DEBUG format, ##args)
 #else
-#define DPRINTK(format,args...)
+#define DPRINTK(format, args...)
 #endif
 #if 0 /* data */
-#define D2PRINTK(format,args...) printk(KERN_DEBUG format,##args)
+#define D2PRINTK(format, args...) printk(KERN_DEBUG format, ##args)
 #else
-#define D2PRINTK(format,args...)
+#define D2PRINTK(format, args...)
 #endif
 
 static struct tc_action_ops *act_base = NULL;
@@ -53,18 +53,15 @@
 	struct tc_action_ops *a, **ap;
 
 	write_lock(&act_mod_lock);
-	for (ap = &act_base; (a=*ap)!=NULL; ap = &a->next) {
+	for (ap = &act_base; (a = *ap) != NULL; ap = &a->next) {
 		if (act->type == a->type || (strcmp(act->kind, a->kind) == 0)) {
 			write_unlock(&act_mod_lock);
 			return -EEXIST;
 		}
 	}
-
-        act->next = NULL;
+	act->next = NULL;
 	*ap = act;
-
 	write_unlock(&act_mod_lock);
-
 	return 0;
 }
 
@@ -74,10 +71,9 @@
 	int err = -ENOENT;
 
 	write_lock(&act_mod_lock);
-	for (ap = &act_base; (a=*ap)!=NULL; ap = &a->next) 
-		if(a == act)
+	for (ap = &act_base; (a = *ap) != NULL; ap = &a->next)
+		if (a == act)
 			break;
-
 	if (a) {
 		*ap = a->next;
 		a->next = NULL;
@@ -90,47 +86,42 @@
 /* lookup by name */
 static struct tc_action_ops *tc_lookup_action_n(char *kind)
 {
-
 	struct tc_action_ops *a = NULL;
 
 	if (kind) {
 		read_lock(&act_mod_lock);
 		for (a = act_base; a; a = a->next) {
-			if (strcmp(kind,a->kind) == 0) {
+			if (strcmp(kind, a->kind) == 0) {
 				if (!try_module_get(a->owner)) {
 					read_unlock(&act_mod_lock);
 					return NULL;
-				} 
+				}
 				break;
 			}
 		}
 		read_unlock(&act_mod_lock);
 	}
-
 	return a;
 }
 
 /* lookup by rtattr */
 static struct tc_action_ops *tc_lookup_action(struct rtattr *kind)
 {
-
 	struct tc_action_ops *a = NULL;
 
 	if (kind) {
 		read_lock(&act_mod_lock);
 		for (a = act_base; a; a = a->next) {
-
-			if (strcmp((char*)RTA_DATA(kind),a->kind) == 0){
+			if (strcmp((char*)RTA_DATA(kind), a->kind) == 0) {
 				if (!try_module_get(a->owner)) {
 					read_unlock(&act_mod_lock);
 					return NULL;
-				} 
+				}
 				break;
 			}
 		}
 		read_unlock(&act_mod_lock);
 	}
-
 	return a;
 }
 
@@ -147,55 +138,52 @@
 				if (!try_module_get(a->owner)) {
 					read_unlock(&act_mod_lock);
 					return NULL;
-				} 
+				}
 				break;
 			}
 		}
 		read_unlock(&act_mod_lock);
 	}
-
 	return a;
 }
 #endif
 
-int tcf_action_exec(struct sk_buff *skb,struct tc_action *act, struct tcf_result *res)
+int tcf_action_exec(struct sk_buff *skb, struct tc_action *act,
+                    struct tcf_result *res)
 {
-
 	struct tc_action *a;
-	int ret = -1; 
+	int ret = -1;
 
 	if (skb->tc_verd & TC_NCLS) {
 		skb->tc_verd = CLR_TC_NCLS(skb->tc_verd);
-		D2PRINTK("(%p)tcf_action_exec: cleared TC_NCLS in %s out %s\n",skb,skb->input_dev?skb->input_dev->name:"xxx",skb->dev->name);
+		D2PRINTK("(%p)tcf_action_exec: cleared TC_NCLS in %s out %s\n",
+		         skb, skb->input_dev ? skb->input_dev->name : "xxx",
+		         skb->dev->name);
 		ret = TC_ACT_OK;
 		goto exec_done;
 	}
 	while ((a = act) != NULL) {
 repeat:
 		if (a->ops && a->ops->act) {
-			ret = a->ops->act(&skb,a);
-				if (TC_MUNGED & skb->tc_verd) {
-					/* copied already, allow trampling */
-					skb->tc_verd = SET_TC_OK2MUNGE(skb->tc_verd);
-					skb->tc_verd = CLR_TC_MUNGED(skb->tc_verd);
-				}
-
+			ret = a->ops->act(&skb, a);
+			if (TC_MUNGED & skb->tc_verd) {
+				/* copied already, allow trampling */
+				skb->tc_verd = SET_TC_OK2MUNGE(skb->tc_verd);
+				skb->tc_verd = CLR_TC_MUNGED(skb->tc_verd);
+			}
 			if (ret != TC_ACT_PIPE)
 				goto exec_done;
 			if (ret == TC_ACT_REPEAT)
 				goto repeat;	/* we need a ttl - JHS */
-
 		}
 		act = a->next;
 	}
-
 exec_done:
 	if (skb->tc_classid > 0) {
 		res->classid = skb->tc_classid;
 		res->class = 0;
 		skb->tc_classid = 0;
 	}
-
 	return ret;
 }
 
@@ -205,54 +193,51 @@
 
 	for (a = act; act; a = act) {
 		if (a && a->ops && a->ops->cleanup) {
-			DPRINTK("tcf_action_destroy destroying %p next %p\n", a,a->next?a->next:NULL);
+			DPRINTK("tcf_action_destroy destroying %p next %p\n",
+			        a, a->next ? a->next : NULL);
 			act = act->next;
-			if (ACT_P_DELETED == a->ops->cleanup(a, bind)) {
+			if (ACT_P_DELETED == a->ops->cleanup(a, bind))
 				module_put(a->ops->owner);
-			}
 			
-			a->ops = NULL;  
+			a->ops = NULL;
 			kfree(a);
 		} else { /*FIXME: Remove later - catch insertion bugs*/
-			printk("tcf_action_destroy: BUG? destroying NULL ops \n");
+			printk("tcf_action_destroy: BUG? destroying NULL ops\n");
 			if (a) {
 				act = act->next;
 				kfree(a);
 			} else {
-				printk("tcf_action_destroy: BUG? destroying NULL action! \n");
+				printk("tcf_action_destroy: BUG? destroying "
+				       "NULL action!\n");
 				break;
 			}
 		}
 	}
 }
 
-int tcf_action_dump_old(struct sk_buff *skb, struct tc_action *a, int bind, int ref)
+int
+tcf_action_dump_old(struct sk_buff *skb, struct tc_action *a, int bind, int ref)
 {
 	int err = -EINVAL;
 
-
-	if ( (NULL == a) || (NULL == a->ops)
-	   || (NULL == a->ops->dump) )
+	if ((NULL == a) || (NULL == a->ops) || (NULL == a->ops->dump))
 		return err;
 	return a->ops->dump(skb, a, bind, ref);
-
 }
 
-
-int tcf_action_dump_1(struct sk_buff *skb, struct tc_action *a, int bind, int ref)
+int
+tcf_action_dump_1(struct sk_buff *skb, struct tc_action *a, int bind, int ref)
 {
 	int err = -EINVAL;
-	unsigned char    *b = skb->tail;
+	unsigned char *b = skb->tail;
 	struct rtattr *r;
 
-
-	if ( (NULL == a) || (NULL == a->ops)
-	   || (NULL == a->ops->dump) || (NULL == a->ops->kind))
+	if ((NULL == a) || (NULL == a->ops) || (NULL == a->ops->dump) ||
+	    (NULL == a->ops->kind))
 		return err;
 
-
 	RTA_PUT(skb, TCA_KIND, IFNAMSIZ, a->ops->kind);
-	if (tcf_action_copy_stats(skb,a))
+	if (tcf_action_copy_stats(skb, a))
 		goto rtattr_failure;
 	r = (struct rtattr*) skb->tail;
 	RTA_PUT(skb, TCA_OPTIONS, 0, NULL);
@@ -261,18 +246,17 @@
 		return err;
 	}
 
-
 rtattr_failure:
 	skb_trim(skb, b - skb->data);
 	return -1;
-
 }
 
-int tcf_action_dump(struct sk_buff *skb, struct tc_action *act, int bind, int ref)
+int
+tcf_action_dump(struct sk_buff *skb, struct tc_action *act, int bind, int ref)
 {
 	struct tc_action *a;
 	int err = -EINVAL;
-	unsigned char    *b = skb->tail;
+	unsigned char *b = skb->tail;
 	struct rtattr *r ;
 
 	while ((a = act) != NULL) {
@@ -280,9 +264,8 @@
 		act = a->next;
 		RTA_PUT(skb, a->order, 0, NULL);
 		err = tcf_action_dump_1(skb, a, bind, ref);
-		if (0 > err) 
+		if (0 > err)
 			goto rtattr_failure;
-
 		r->rta_len = skb->tail - (u8*)r;
 	}
 
@@ -291,7 +274,6 @@
 rtattr_failure:
 	skb_trim(skb, b - skb->data);
 	return -err;
-	
 }
 
 struct tc_action *tcf_action_init_1(struct rtattr *rta, struct rtattr *est,
@@ -306,16 +288,17 @@
 	*err = -EINVAL;
 
 	if (NULL == name) {
-		if (rtattr_parse(tb, TCA_ACT_MAX, RTA_DATA(rta), RTA_PAYLOAD(rta))<0)
+		if (rtattr_parse(tb, TCA_ACT_MAX, RTA_DATA(rta),
+		                 RTA_PAYLOAD(rta)) < 0)
 			goto err_out;
 		kind = tb[TCA_ACT_KIND-1];
 		if (NULL != kind) {
 			sprintf(act_name, "%s", (char*)RTA_DATA(kind));
 			if (RTA_PAYLOAD(kind) >= IFNAMSIZ) {
-				printk(" Action %s bad\n", (char*)RTA_DATA(kind));
+				printk("Action %s bad\n",
+				        (char*)RTA_DATA(kind));
 				goto err_out;
 			}
-
 		} else {
 			printk("Action bad kind\n");
 			goto err_out;
@@ -323,19 +306,20 @@
 		a_o = tc_lookup_action(kind);
 	} else {
 		sprintf(act_name, "%s", name);
-		DPRINTK("tcf_action_init_1: finding  %s\n",act_name);
+		DPRINTK("tcf_action_init_1: finding %s\n", act_name);
 		a_o = tc_lookup_action_n(name);
 	}
 #ifdef CONFIG_KMOD
 	if (NULL == a_o) {
-		DPRINTK("tcf_action_init_1: trying to load module %s\n",act_name);
-		request_module (act_name);
+		DPRINTK("tcf_action_init_1: trying to load module %s\n",
+		        act_name);
+		request_module(act_name);
 		a_o = tc_lookup_action_n(act_name);
 	}
 
 #endif
 	if (NULL == a_o) {
-		printk("failed to find %s\n",act_name);
+		printk("failed to find %s\n", act_name);
 		goto err_out;
 	}
 
@@ -363,12 +347,12 @@
 
 	/* module count goes up only when brand new policy is created
 	   if it exists and is only bound to in a_o->init() then
-           ACT_P_CREATED is not returned (a zero is).
-        */
+	   ACT_P_CREATED is not returned (a zero is).
+	*/
 	if (*err != ACT_P_CREATED)
 		module_put(a_o->owner);
 	a->ops = a_o;
-	DPRINTK("tcf_action_init_1: successfull %s \n",act_name);
+	DPRINTK("tcf_action_init_1: successfull %s\n", act_name);
 
 	*err = 0;
 	return a;
@@ -396,7 +380,8 @@
 
 	for (i=0; i < TCA_ACT_MAX_PRIO; i++) {
 		if (tb[i]) {
-			act = tcf_action_init_1(tb[i], est, name, ovr, bind, err);
+			act = tcf_action_init_1(tb[i], est, name, ovr, bind,
+			                        err);
 			if (act == NULL) {
 				printk("Error processing action order %d\n", i);
 				goto bad_ret;
@@ -419,7 +404,7 @@
 	return NULL;
 }
 
-int tcf_action_copy_stats (struct sk_buff *skb,struct tc_action *a)
+int tcf_action_copy_stats(struct sk_buff *skb, struct tc_action *a)
 {
 	int err;
 	struct gnet_dump d;
@@ -462,14 +447,13 @@
 	return -1;
 }
 
-
 static int
-tca_get_fill(struct sk_buff *skb,  struct tc_action *a,
-	      u32 pid, u32 seq, unsigned flags, int event, int bind, int ref)
+tca_get_fill(struct sk_buff *skb, struct tc_action *a, u32 pid, u32 seq,
+             unsigned flags, int event, int bind, int ref)
 {
 	struct tcamsg *t;
-	struct nlmsghdr  *nlh;
-	unsigned char	 *b = skb->tail;
+	struct nlmsghdr *nlh;
+	unsigned char *b = skb->tail;
 	struct rtattr *x;
 
 	nlh = NLMSG_PUT(skb, pid, seq, event, sizeof(*t));
@@ -480,9 +464,8 @@
 	x = (struct rtattr*) skb->tail;
 	RTA_PUT(skb, TCA_ACT_TAB, 0, NULL);
 
-	if (0 > tcf_action_dump(skb, a, bind, ref)) {
+	if (0 > tcf_action_dump(skb, a, bind, ref))
 		goto rtattr_failure;
-	}
 
 	x->rta_len = skb->tail - (u8*)x;
 	
@@ -495,58 +478,53 @@
 	return -1;
 }
 
-static int act_get_notify(u32 pid, struct nlmsghdr *n,
-			   struct tc_action *a, int event)
+static int
+act_get_notify(u32 pid, struct nlmsghdr *n, struct tc_action *a, int event)
 {
 	struct sk_buff *skb;
-
 	int err = 0;
 
 	skb = alloc_skb(NLMSG_GOODSIZE, GFP_KERNEL);
 	if (!skb)
 		return -ENOBUFS;
-
-	if (tca_get_fill(skb, a,  pid, n->nlmsg_seq, 0, event, 0, 0) <= 0) {
+	if (tca_get_fill(skb, a, pid, n->nlmsg_seq, 0, event, 0, 0) <= 0) {
 		kfree_skb(skb);
 		return -EINVAL;
 	}
-
-	err =  netlink_unicast(rtnl,skb, pid, MSG_DONTWAIT);
+	err = netlink_unicast(rtnl, skb, pid, MSG_DONTWAIT);
 	if (err > 0)
 		err = 0;
 	return err;
 }
 
-static int tcf_action_get_1(struct rtattr *rta, struct tc_action *a, struct nlmsghdr *n, u32 pid)
+static int tcf_action_get_1(struct rtattr *rta, struct tc_action *a,
+                            struct nlmsghdr *n, u32 pid)
 {
 	struct tc_action_ops *a_o;
 	char act_name[4 + IFNAMSIZ + 1];
 	struct rtattr *tb[TCA_ACT_MAX+1];
 	struct rtattr *kind = NULL;
 	int index;
-
 	int err = -EINVAL;
 
-	if (rtattr_parse(tb, TCA_ACT_MAX, RTA_DATA(rta), RTA_PAYLOAD(rta))<0)
+	if (rtattr_parse(tb, TCA_ACT_MAX, RTA_DATA(rta), RTA_PAYLOAD(rta)) < 0)
 		goto err_out;
-
-
 	kind = tb[TCA_ACT_KIND-1];
 	if (NULL != kind) {
 		sprintf(act_name, "%s", (char*)RTA_DATA(kind));
 		if (RTA_PAYLOAD(kind) >= IFNAMSIZ) {
-			printk("tcf_action_get_1: action %s bad\n", (char*)RTA_DATA(kind));
+			printk("tcf_action_get_1: action %s bad\n",
+			       (char*)RTA_DATA(kind));
 			goto err_out;
 		}
-
 	} else {
 		printk("tcf_action_get_1: action bad kind\n");
 		goto err_out;
 	}
 
-	if (tb[TCA_ACT_INDEX - 1]) {
+	if (tb[TCA_ACT_INDEX - 1])
 		index = *(int *)RTA_DATA(tb[TCA_ACT_INDEX - 1]);
-	} else {
+	else {
 		printk("tcf_action_get_1: index not received\n");
 		goto err_out;
 	}
@@ -557,16 +535,13 @@
 		request_module (act_name);
 		a_o = tc_lookup_action_n(act_name);
 	}
-
 #endif
 	if (NULL == a_o) {
-		printk("failed to find %s\n",act_name);
+		printk("failed to find %s\n", act_name);
 		goto err_out;
 	}
-
-	if (NULL == a) {
+	if (NULL == a)
 		goto err_mod;
-	}
 
 	a->ops = a_o;
 
@@ -584,7 +559,7 @@
 	return err;
 }
 
-static void cleanup_a (struct tc_action *act) 
+static void cleanup_a(struct tc_action *act)
 {
 	struct tc_action *a;
 
@@ -594,9 +569,8 @@
 			a->ops = NULL;
 			a->priv = NULL;
 			kfree(a);
-		} else {
+		} else
 			printk("cleanup_a: BUG? empty action\n");
-		}
 	}
 }
 
@@ -608,10 +582,10 @@
 	if (NULL != kind) {
 		sprintf(act_name, "%s", (char*)RTA_DATA(kind));
 		if (RTA_PAYLOAD(kind) >= IFNAMSIZ) {
-			printk("get_ao: action %s bad\n", (char*)RTA_DATA(kind));
+			printk("get_ao: action %s bad\n",
+			       (char*)RTA_DATA(kind));
 			return NULL;
 		}
-
 	} else {
 		printk("get_ao: action bad kind\n");
 		return NULL;
@@ -620,14 +594,14 @@
 	a_o = tc_lookup_action(kind);
 #ifdef CONFIG_KMOD
 	if (NULL == a_o) {
-		DPRINTK("get_ao: trying to load module %s\n",act_name);
-		request_module (act_name);
+		DPRINTK("get_ao: trying to load module %s\n", act_name);
+		request_module(act_name);
 		a_o = tc_lookup_action_n(act_name);
 	}
 #endif
 
 	if (NULL == a_o) {
-		printk("get_ao: failed to find %s\n",act_name);
+		printk("get_ao: failed to find %s\n", act_name);
 		return NULL;
 	}
 
@@ -639,16 +613,13 @@
 {
 	struct tc_action *act = NULL;
 
-	act = kmalloc(sizeof(*act),GFP_KERNEL);
+	act = kmalloc(sizeof(*act), GFP_KERNEL);
 	if (NULL == act) { /* grrr .. */
-		printk("create_a: failed to alloc! \n");
+		printk("create_a: failed to alloc!\n");
 		return NULL;
 	}
-
-	memset(act, 0,sizeof(*act));
-
+	memset(act, 0, sizeof(*act));
 	act->order = i;
-
 	return act;
 }
 
@@ -679,16 +650,14 @@
 
 	b = (unsigned char *)skb->tail;
 
-	if (rtattr_parse(tb, TCA_ACT_MAX, RTA_DATA(rta), RTA_PAYLOAD(rta))<0) {
+	if (rtattr_parse(tb, TCA_ACT_MAX, RTA_DATA(rta), RTA_PAYLOAD(rta)) < 0)
 		goto err_out;
-	}
 
 	kind = tb[TCA_ACT_KIND-1];
-	if (NULL == get_ao(kind, a)) {
+	if (NULL == get_ao(kind, a))
 		goto err_out;
-	}
 
-	nlh = NLMSG_PUT(skb, pid,  n->nlmsg_seq, RTM_DELACTION, sizeof (*t));
+	nlh = NLMSG_PUT(skb, pid, n->nlmsg_seq, RTM_DELACTION, sizeof(*t));
 	t = NLMSG_DATA(nlh);
 	t->tca_family = AF_UNSPEC;
 
@@ -696,9 +665,8 @@
 	RTA_PUT(skb, TCA_ACT_TAB, 0, NULL);
 
 	err = a->ops->walk(skb, &dcb, RTM_DELACTION, a);
-	if (0 > err ) {
+	if (0 > err)
 		goto rtattr_failure;
-	}
 
 	x->rta_len = skb->tail - (u8 *) x;
 
@@ -722,61 +690,55 @@
 	return err;
 }
 
-static int tca_action_gd(struct rtattr *rta, struct nlmsghdr *n, u32 pid, int event )
+static int
+tca_action_gd(struct rtattr *rta, struct nlmsghdr *n, u32 pid, int event)
 {
-
 	int s = 0;
 	int i, ret = 0;
 	struct tc_action *act = NULL;
 	struct rtattr *tb[TCA_ACT_MAX_PRIO+1];
 	struct tc_action *a = NULL, *a_s = NULL;
 
-	if (event != RTM_GETACTION  && event != RTM_DELACTION)
+	if (event != RTM_GETACTION && event != RTM_DELACTION)
 		ret = -EINVAL;
 
-	if (rtattr_parse(tb, TCA_ACT_MAX_PRIO, RTA_DATA(rta), RTA_PAYLOAD(rta))<0) {
+	if (rtattr_parse(tb, TCA_ACT_MAX_PRIO, RTA_DATA(rta),
+	                 RTA_PAYLOAD(rta)) < 0) {
 		ret = -EINVAL;
 		goto nlmsg_failure;
 	}
 
 	if (event == RTM_DELACTION && n->nlmsg_flags&NLM_F_ROOT) {
-		if (NULL != tb[0]  && NULL == tb[1]) {
-			return tca_action_flush(tb[0],n,pid);
-		}
+		if (NULL != tb[0] && NULL == tb[1])
+			return tca_action_flush(tb[0], n, pid);
 	}
 
-	for (i=0; i < TCA_ACT_MAX_PRIO ; i++) {
-
+	for (i=0; i < TCA_ACT_MAX_PRIO; i++) {
 		if (NULL == tb[i])
 			break;
-
 		act = create_a(i+1);
 		if (NULL != a && a != act) {
 			a->next = act;
 			a = act;
-		} else {
+		} else
 			a = act;
-		}
 
 		if (!s) {
 			s = 1;
 			a_s = a;
 		}
 
-		ret = tcf_action_get_1(tb[i],act,n,pid);
+		ret = tcf_action_get_1(tb[i], act, n, pid);
 		if (ret < 0) {
-			printk("tcf_action_get: failed to get! \n");
+			printk("tcf_action_get: failed to get!\n");
 			ret = -EINVAL;
 			goto rtattr_failure;
 		}
-
 	}
 
-
-	if (RTM_GETACTION == event) {
+	if (RTM_GETACTION == event)
 		ret = act_get_notify(pid, n, a_s, event);
-	} else { /* delete */
-
+	else { /* delete */
 		struct sk_buff *skb;
 
 		skb = alloc_skb(NLMSG_GOODSIZE, GFP_KERNEL);
@@ -785,7 +747,8 @@
 			goto nlmsg_failure;
 		}
 
-		if (tca_get_fill(skb, a_s,  pid, n->nlmsg_seq, 0, event, 0 , 1) <= 0) {
+		if (tca_get_fill(skb, a_s, pid, n->nlmsg_seq, 0, event,
+		                 0, 1) <= 0) {
 			kfree_skb(skb);
 			ret = -EINVAL;
 			goto nlmsg_failure;
@@ -793,8 +756,8 @@
 
 		/* now do the delete */
 		tcf_action_destroy(a_s, 0);
-
-		ret = rtnetlink_send(skb, pid, RTMGRP_TC, n->nlmsg_flags&NLM_F_ECHO);
+		ret = rtnetlink_send(skb, pid, RTMGRP_TC,
+		                     n->nlmsg_flags&NLM_F_ECHO);
 		if (ret > 0)
 			return 0;
 		return ret;
@@ -805,16 +768,14 @@
 	return ret;
 }
 
-
-static int tcf_add_notify(struct tc_action *a, u32 pid, u32 seq, int event, unsigned flags) 
+static int tcf_add_notify(struct tc_action *a, u32 pid, u32 seq, int event,
+                          unsigned flags)
 {
 	struct tcamsg *t;
-	struct nlmsghdr  *nlh;
+	struct nlmsghdr *nlh;
 	struct sk_buff *skb;
 	struct rtattr *x;
 	unsigned char *b;
-
-
 	int err = 0;
 
 	skb = alloc_skb(NLMSG_GOODSIZE, GFP_KERNEL);
@@ -831,9 +792,8 @@
 	x = (struct rtattr*) skb->tail;
 	RTA_PUT(skb, TCA_ACT_TAB, 0, NULL);
 
-	if (0 > tcf_action_dump(skb, a, 0, 0)) {
+	if (0 > tcf_action_dump(skb, a, 0, 0))
 		goto rtattr_failure;
-	}
 
 	x->rta_len = skb->tail - (u8*)x;
 	
@@ -843,7 +803,6 @@
 	err = rtnetlink_send(skb, pid, RTMGRP_TC, flags&NLM_F_ECHO);
 	if (err > 0)
 		err = 0;
-
 	return err;
 
 rtattr_failure:
@@ -853,7 +812,8 @@
 }
 
 	
-static int tcf_action_add(struct rtattr *rta, struct nlmsghdr *n, u32 pid, int ovr ) 
+static int
+tcf_action_add(struct rtattr *rta, struct nlmsghdr *n, u32 pid, int ovr)
 {
 	int ret = 0;
 	struct tc_action *act = NULL;
@@ -867,16 +827,15 @@
 	/* dump then free all the actions after update; inserted policy
 	 * stays intact
 	 * */
-	ret = tcf_add_notify(act, pid, seq, RTM_NEWACTION, n->nlmsg_flags); 
+	ret = tcf_add_notify(act, pid, seq, RTM_NEWACTION, n->nlmsg_flags);
 	for (a = act; act; a = act) {
 		if (a) {
 			act = act->next;
 			a->ops = NULL;
 			a->priv = NULL;
 			kfree(a);
-		} else {
+		} else
 			printk("tcf_action_add: BUG? empty action\n");
-		}
 	}
 done:
 	return ret;
@@ -886,37 +845,35 @@
 {
 	struct rtattr **tca = arg;
 	u32 pid = skb ? NETLINK_CB(skb).pid : 0;
-
 	int ret = 0, ovr = 0;
 
 	if (NULL == tca[TCA_ACT_TAB-1]) {
-			printk("tc_ctl_action: received NO action attribs\n");
-			return -EINVAL;
+		printk("tc_ctl_action: received NO action attribs\n");
+		return -EINVAL;
 	}
 
 	/* n->nlmsg_flags&NLM_F_CREATE
 	 * */
 	switch (n->nlmsg_type) {
-	case RTM_NEWACTION:    
+	case RTM_NEWACTION:
 		/* we are going to assume all other flags
 		 * imply create only if it doesnt exist
 		 * Note that CREATE | EXCL implies that
 		 * but since we want avoid ambiguity (eg when flags
 		 * is zero) then just set this
 		 */
-		if (n->nlmsg_flags&NLM_F_REPLACE) {
+		if (n->nlmsg_flags&NLM_F_REPLACE)
 			ovr = 1;
-		}
-		ret =  tcf_action_add(tca[TCA_ACT_TAB-1], n, pid, ovr);
+		ret = tcf_action_add(tca[TCA_ACT_TAB-1], n, pid, ovr);
 		break;
 	case RTM_DELACTION:
-		ret = tca_action_gd(tca[TCA_ACT_TAB-1], n, pid,RTM_DELACTION);
+		ret = tca_action_gd(tca[TCA_ACT_TAB-1], n, pid, RTM_DELACTION);
 		break;
 	case RTM_GETACTION:
-		ret = tca_action_gd(tca[TCA_ACT_TAB-1], n, pid,RTM_GETACTION);
+		ret = tca_action_gd(tca[TCA_ACT_TAB-1], n, pid, RTM_GETACTION);
 		break;
 	default:
-		printk(" Unknown cmd was detected\n");
+		printk("Unknown cmd was detected\n");
 		break;
 	}
 
@@ -930,8 +887,7 @@
 	struct rtattr *tb[TCA_ACT_MAX_PRIO + 1];
 	struct rtattr *rta[TCAA_MAX + 1];
 	struct rtattr *kind = NULL;
-	int min_len = NLMSG_LENGTH(sizeof (struct tcamsg));
-
+	int min_len = NLMSG_LENGTH(sizeof(struct tcamsg));
 	int attrlen = n->nlmsg_len - NLMSG_ALIGN(min_len);
 	struct rtattr *attr = (void *) n + NLMSG_ALIGN(min_len);
 
@@ -942,12 +898,14 @@
 		return NULL;
 	}
 
-	if (rtattr_parse(tb, TCA_ACT_MAX_PRIO, RTA_DATA(tb1), NLMSG_ALIGN(RTA_PAYLOAD(tb1))) < 0)
+	if (rtattr_parse(tb, TCA_ACT_MAX_PRIO, RTA_DATA(tb1),
+	                 NLMSG_ALIGN(RTA_PAYLOAD(tb1))) < 0)
 		return NULL;
-	if (NULL == tb[0]) 
+	if (NULL == tb[0])
 		return NULL;
 
-	if (rtattr_parse(tb2, TCA_ACT_MAX, RTA_DATA(tb[0]), RTA_PAYLOAD(tb[0]))<0)
+	if (rtattr_parse(tb2, TCA_ACT_MAX, RTA_DATA(tb[0]),
+	                 RTA_PAYLOAD(tb[0])) < 0)
 		return NULL;
 	kind = tb2[TCA_ACT_KIND-1];
 
@@ -963,30 +921,30 @@
 	struct tc_action_ops *a_o;
 	struct tc_action a;
 	int ret = 0;
-
 	struct tcamsg *t = (struct tcamsg *) NLMSG_DATA(cb->nlh);
 	char *kind = find_dump_kind(cb->nlh);
+
 	if (NULL == kind) {
 		printk("tc_dump_action: action bad kind\n");
 		return 0;
 	}
 
 	a_o = tc_lookup_action_n(kind);
-
 	if (NULL == a_o) {
 		printk("failed to find %s\n", kind);
 		return 0;
 	}
 
-	memset(&a,0,sizeof(struct tc_action));
+	memset(&a, 0, sizeof(struct tc_action));
 	a.ops = a_o;
 
 	if (NULL == a_o->walk) {
-		printk("tc_dump_action: %s !capable of dumping table\n",kind);
+		printk("tc_dump_action: %s !capable of dumping table\n", kind);
 		goto rtattr_failure;
 	}
 
-	nlh = NLMSG_PUT(skb, NETLINK_CB(cb->skb).pid,  cb->nlh->nlmsg_seq, cb->nlh->nlmsg_type, sizeof (*t));
+	nlh = NLMSG_PUT(skb, NETLINK_CB(cb->skb).pid, cb->nlh->nlmsg_seq,
+	                cb->nlh->nlmsg_type, sizeof(*t));
 	t = NLMSG_DATA(nlh);
 	t->tca_family = AF_UNSPEC;
 
@@ -994,19 +952,17 @@
 	RTA_PUT(skb, TCA_ACT_TAB, 0, NULL);
 
 	ret = a_o->walk(skb, cb, RTM_GETACTION, &a);
-	if (0 > ret ) {
+	if (0 > ret)
 		goto rtattr_failure;
-	}
 
 	if (ret > 0) {
 		x->rta_len = skb->tail - (u8 *) x;
 		ret = skb->len;
-	} else {
+	} else
 		skb_trim(skb, (u8*)x - skb->data);
-	}
 
 	nlh->nlmsg_len = skb->tail - b;
-	if (NETLINK_CB(cb->skb).pid && ret) 
+	if (NETLINK_CB(cb->skb).pid && ret)
 		nlh->nlmsg_flags |= NLM_F_MULTI;
 	module_put(a_o->owner);
 	return skb->len;
@@ -1029,7 +985,8 @@
 		link_p[RTM_GETACTION-RTM_BASE].dumpit = tc_dump_action;
 	}
 
-	printk("TC classifier action (bugs to netdev@oss.sgi.com cc hadi@cyberus.ca)\n");
+	printk("TC classifier action (bugs to netdev@oss.sgi.com cc "
+	       "hadi@cyberus.ca)\n");
 	return 0;
 }
 

--------------090101090401050203030104--
