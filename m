From: Thomas Graf <tgraf@suug.ch>
Subject: [PATCH 5/6] cls_fw: Whitespace/ifdef fixes
Date: Fri, 29 Oct 2004 02:25:48 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20041029002548.GD12289@postel.suug.ch>
References: <20041029002113.GY12289@postel.suug.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com, hadi@cyberus.ca
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@davemloft.net>
Content-Disposition: inline
In-Reply-To: <20041029002113.GY12289@postel.suug.ch>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Signed-off-by: Thomas Graf <tgraf@suug.ch>

--- linux-2.6.10-rc1-bk7.orig/net/sched/cls_fw.c	2004-10-29 00:37:34.000000000 +0200
+++ linux-2.6.10-rc1-bk7/net/sched/cls_fw.c	2004-10-29 00:38:46.000000000 +0200
@@ -57,15 +57,15 @@
 	u32			id;
 	struct tcf_result	res;
 #ifdef CONFIG_NET_CLS_ACT
-       struct tc_action        *action;
+	struct tc_action        *action;
 #ifdef CONFIG_NET_CLS_IND
-       char			indev[IFNAMSIZ];
-#endif
-#else
+	char			indev[IFNAMSIZ];
+#endif /* CONFIG_NET_CLS_IND */
+#else /* CONFIG_NET_CLS_ACT */
 #ifdef CONFIG_NET_CLS_POLICE
 	struct tcf_police	*police;
-#endif
-#endif
+#endif /* CONFIG_NET_CLS_POLICE */
+#endif /* CONFIG_NET_CLS_ACT */
 };
 
 static __inline__ int fw_hash(u32 handle)
@@ -158,14 +158,14 @@
 			head->ht[h] = f->next;
 			tcf_unbind_filter(tp, &f->res);
 #ifdef CONFIG_NET_CLS_ACT
-       if (f->action) {
-               tcf_action_destroy(f->action,TCA_ACT_UNBIND);
-       }
-#else
+			if (f->action)
+				tcf_action_destroy(f->action, TCA_ACT_UNBIND);
+#else /* CONFIG_NET_CLS_ACT */
 #ifdef CONFIG_NET_CLS_POLICE
-			tcf_police_release(f->police,TCA_ACT_UNBIND);
-#endif
-#endif
+			if (f->police)
+				tcf_police_release(f->police, TCA_ACT_UNBIND);
+#endif /* CONFIG_NET_CLS_POLICE */
+#endif /* CONFIG_NET_CLS_ACT */
 
 			kfree(f);
 		}
@@ -189,14 +189,13 @@
 			tcf_tree_unlock(tp);
 			tcf_unbind_filter(tp, &f->res);
 #ifdef CONFIG_NET_CLS_ACT
-       if (f->action) {
-               tcf_action_destroy(f->action,TCA_ACT_UNBIND);
-       }
-#else
+			if (f->action)
+				tcf_action_destroy(f->action,TCA_ACT_UNBIND);
+#else /* CONFIG_NET_CLS_ACT */
 #ifdef CONFIG_NET_CLS_POLICE
 			tcf_police_release(f->police,TCA_ACT_UNBIND);
-#endif
-#endif
+#endif /* CONFIG_NET_CLS_POLICE */
+#endif /* CONFIG_NET_CLS_ACT */
 			kfree(f);
 			return 0;
 		}
@@ -358,15 +357,15 @@
 
 	t->tcm_handle = f->id;
 
-       if (!f->res.classid
+	if (!f->res.classid
 #ifdef CONFIG_NET_CLS_ACT
-           && !f->action
+		&& !f->action
 #else
 #ifdef CONFIG_NET_CLS_POLICE
-           && !f->police
+		&& !f->police
 #endif
 #endif
-           )
+		)
 		return skb->len;
 
 	rta = (struct rtattr*)b;
@@ -390,19 +389,19 @@
 
 	rta->rta_len = skb->tail - b;
 #ifdef CONFIG_NET_CLS_ACT
-       if (f->action && f->action->type == TCA_OLD_COMPAT) {
-               if (tcf_action_copy_stats(skb,f->action))
-                       goto rtattr_failure;
-       }
-#else
+	if (f->action && f->action->type == TCA_OLD_COMPAT) {
+		if (tcf_action_copy_stats(skb,f->action))
+			goto rtattr_failure;
+	}
+#else /* CONFIG_NET_CLS_ACT */
 #ifdef CONFIG_NET_CLS_POLICE
 	if (f->police) {
 		if (qdisc_copy_stats(skb, &f->police->stats,
-				     f->police->stats_lock))
+			f->police->stats_lock))
 			goto rtattr_failure;
 	}
-#endif
-#endif
+#endif /* CONFIG_NET_CLS_POLICE */
+#endif /* CONFIG_NET_CLS_ACT */
 	return skb->len;
 
 rtattr_failure:
