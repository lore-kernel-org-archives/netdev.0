From: Thomas Graf <tgraf@suug.ch>
Subject: [PATCH 07/16] [XFRM] netlink: Clear up some of the CONFIG_XFRM_SUB_POLICY ifdef mess
Date: Wed, 22 Aug 2007 16:55:45 +0200
Message-ID: <20070822145630.772409495@lsx.localdomain>
References: <20070822145538.861270927@lsx.localdomain>
Cc: netdev@vger.kernel.org, Thomas Graf <tgraf@suug.ch>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from postel.suug.ch ([194.88.212.233]:56976 "EHLO postel.suug.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758571AbXHVP3T (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 22 Aug 2007 11:29:19 -0400
Content-Disposition: inline; filename=xfrm_userpolicy_type_size
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Moves all of the SUB_POLICY ifdefs related to the attribute size
calculation into a function.

Signed-off-by: Thomas Graf <tgraf@suug.ch>

Index: net-2.6.24/net/xfrm/xfrm_user.c
===================================================================
--- net-2.6.24.orig/net/xfrm/xfrm_user.c	2007-08-21 17:03:43.000000000 +0200
+++ net-2.6.24/net/xfrm/xfrm_user.c	2007-08-21 17:04:46.000000000 +0200
@@ -1224,6 +1224,14 @@ static inline int copy_to_user_sec_ctx(s
 	}
 	return 0;
 }
+static inline size_t userpolicy_type_attrsize(void)
+{
+#ifdef CONFIG_XFRM_SUB_POLICY
+	return nla_total_size(sizeof(struct xfrm_userpolicy_type));
+#else
+	return 0;
+#endif
+}
 
 #ifdef CONFIG_XFRM_SUB_POLICY
 static int copy_to_user_policy_type(u8 type, struct sk_buff *skb)
@@ -1857,9 +1865,7 @@ static int xfrm_send_migrate(struct xfrm
 
 	len = RTA_SPACE(sizeof(struct xfrm_user_migrate) * num_migrate);
 	len += NLMSG_SPACE(sizeof(struct xfrm_userpolicy_id));
-#ifdef CONFIG_XFRM_SUB_POLICY
-	len += RTA_SPACE(sizeof(struct xfrm_userpolicy_type));
-#endif
+	len += userpolicy_type_attrsize();
 	skb = alloc_skb(len, GFP_ATOMIC);
 	if (skb == NULL)
 		return -ENOMEM;
@@ -2214,9 +2220,7 @@ static int xfrm_send_acquire(struct xfrm
 	len = RTA_SPACE(sizeof(struct xfrm_user_tmpl) * xp->xfrm_nr);
 	len += NLMSG_SPACE(sizeof(struct xfrm_user_acquire));
 	len += RTA_SPACE(xfrm_user_sec_ctx_size(x->security));
-#ifdef CONFIG_XFRM_SUB_POLICY
-	len += RTA_SPACE(sizeof(struct xfrm_userpolicy_type));
-#endif
+	len += userpolicy_type_attrsize();
 	skb = alloc_skb(len, GFP_ATOMIC);
 	if (skb == NULL)
 		return -ENOMEM;
@@ -2322,9 +2326,7 @@ static int xfrm_exp_policy_notify(struct
 	len = RTA_SPACE(sizeof(struct xfrm_user_tmpl) * xp->xfrm_nr);
 	len += NLMSG_SPACE(sizeof(struct xfrm_user_polexpire));
 	len += RTA_SPACE(xfrm_user_sec_ctx_size(xp->security));
-#ifdef CONFIG_XFRM_SUB_POLICY
-	len += RTA_SPACE(sizeof(struct xfrm_userpolicy_type));
-#endif
+	len += userpolicy_type_attrsize();
 	skb = alloc_skb(len, GFP_ATOMIC);
 	if (skb == NULL)
 		return -ENOMEM;
@@ -2349,9 +2351,7 @@ static int xfrm_notify_policy(struct xfr
 		len += RTA_SPACE(headlen);
 		headlen = sizeof(*id);
 	}
-#ifdef CONFIG_XFRM_SUB_POLICY
-	len += RTA_SPACE(sizeof(struct xfrm_userpolicy_type));
-#endif
+	len += userpolicy_type_attrsize();
 	len += NLMSG_SPACE(headlen);
 
 	skb = alloc_skb(len, GFP_ATOMIC);
@@ -2401,9 +2401,7 @@ static int xfrm_notify_policy_flush(stru
 	struct nlmsghdr *nlh;
 	struct sk_buff *skb;
 	int len = 0;
-#ifdef CONFIG_XFRM_SUB_POLICY
-	len += RTA_SPACE(sizeof(struct xfrm_userpolicy_type));
-#endif
+	len += userpolicy_type_attrsize();
 	len += NLMSG_LENGTH(0);
 
 	skb = alloc_skb(len, GFP_ATOMIC);

-- 

