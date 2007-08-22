From: Thomas Graf <tgraf@suug.ch>
Subject: [PATCH 12/16] [XFRM] netlink: Rename attribyte array from xfrma[] to attrs[]
Date: Wed, 22 Aug 2007 16:55:50 +0200
Message-ID: <20070822145631.500935706@lsx.localdomain>
References: <20070822145538.861270927@lsx.localdomain>
Cc: netdev@vger.kernel.org, Thomas Graf <tgraf@suug.ch>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from postel.suug.ch ([194.88.212.233]:56958 "EHLO postel.suug.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1763165AbXHVP3R (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 22 Aug 2007 11:29:17 -0400
Content-Disposition: inline; filename=xfrma_rename
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Increases readability a lot.

Signed-off-by: Thomas Graf <tgraf@suug.ch>

Index: net-2.6.24/net/xfrm/xfrm_user.c
===================================================================
--- net-2.6.24.orig/net/xfrm/xfrm_user.c	2007-08-21 17:34:10.000000000 +0200
+++ net-2.6.24/net/xfrm/xfrm_user.c	2007-08-21 17:34:29.000000000 +0200
@@ -38,9 +38,9 @@ static inline int alg_len(struct xfrm_al
 	return sizeof(*alg) + ((alg->alg_key_len + 7) / 8);
 }
 
-static int verify_one_alg(struct rtattr **xfrma, enum xfrm_attr_type_t type)
+static int verify_one_alg(struct rtattr **attrs, enum xfrm_attr_type_t type)
 {
-	struct rtattr *rt = xfrma[type];
+	struct rtattr *rt = attrs[type];
 	struct xfrm_algo *algp;
 
 	if (!rt)
@@ -75,18 +75,18 @@ static int verify_one_alg(struct rtattr 
 	return 0;
 }
 
-static void verify_one_addr(struct rtattr **xfrma, enum xfrm_attr_type_t type,
+static void verify_one_addr(struct rtattr **attrs, enum xfrm_attr_type_t type,
 			   xfrm_address_t **addrp)
 {
-	struct rtattr *rt = xfrma[type];
+	struct rtattr *rt = attrs[type];
 
 	if (rt && addrp)
 		*addrp = RTA_DATA(rt);
 }
 
-static inline int verify_sec_ctx_len(struct rtattr **xfrma)
+static inline int verify_sec_ctx_len(struct rtattr **attrs)
 {
-	struct rtattr *rt = xfrma[XFRMA_SEC_CTX];
+	struct rtattr *rt = attrs[XFRMA_SEC_CTX];
 	struct xfrm_user_sec_ctx *uctx;
 
 	if (!rt)
@@ -101,7 +101,7 @@ static inline int verify_sec_ctx_len(str
 
 
 static int verify_newsa_info(struct xfrm_usersa_info *p,
-			     struct rtattr **xfrma)
+			     struct rtattr **attrs)
 {
 	int err;
 
@@ -125,35 +125,35 @@ static int verify_newsa_info(struct xfrm
 	err = -EINVAL;
 	switch (p->id.proto) {
 	case IPPROTO_AH:
-		if (!xfrma[XFRMA_ALG_AUTH]	||
-		    xfrma[XFRMA_ALG_CRYPT]	||
-		    xfrma[XFRMA_ALG_COMP])
+		if (!attrs[XFRMA_ALG_AUTH]	||
+		    attrs[XFRMA_ALG_CRYPT]	||
+		    attrs[XFRMA_ALG_COMP])
 			goto out;
 		break;
 
 	case IPPROTO_ESP:
-		if ((!xfrma[XFRMA_ALG_AUTH] &&
-		     !xfrma[XFRMA_ALG_CRYPT])	||
-		    xfrma[XFRMA_ALG_COMP])
+		if ((!attrs[XFRMA_ALG_AUTH] &&
+		     !attrs[XFRMA_ALG_CRYPT])	||
+		    attrs[XFRMA_ALG_COMP])
 			goto out;
 		break;
 
 	case IPPROTO_COMP:
-		if (!xfrma[XFRMA_ALG_COMP]	||
-		    xfrma[XFRMA_ALG_AUTH]	||
-		    xfrma[XFRMA_ALG_CRYPT])
+		if (!attrs[XFRMA_ALG_COMP]	||
+		    attrs[XFRMA_ALG_AUTH]	||
+		    attrs[XFRMA_ALG_CRYPT])
 			goto out;
 		break;
 
 #if defined(CONFIG_IPV6) || defined(CONFIG_IPV6_MODULE)
 	case IPPROTO_DSTOPTS:
 	case IPPROTO_ROUTING:
-		if (xfrma[XFRMA_ALG_COMP]	||
-		    xfrma[XFRMA_ALG_AUTH]	||
-		    xfrma[XFRMA_ALG_CRYPT]	||
-		    xfrma[XFRMA_ENCAP]		||
-		    xfrma[XFRMA_SEC_CTX]	||
-		    !xfrma[XFRMA_COADDR])
+		if (attrs[XFRMA_ALG_COMP]	||
+		    attrs[XFRMA_ALG_AUTH]	||
+		    attrs[XFRMA_ALG_CRYPT]	||
+		    attrs[XFRMA_ENCAP]		||
+		    attrs[XFRMA_SEC_CTX]	||
+		    !attrs[XFRMA_COADDR])
 			goto out;
 		break;
 #endif
@@ -162,13 +162,13 @@ static int verify_newsa_info(struct xfrm
 		goto out;
 	}
 
-	if ((err = verify_one_alg(xfrma, XFRMA_ALG_AUTH)))
+	if ((err = verify_one_alg(attrs, XFRMA_ALG_AUTH)))
 		goto out;
-	if ((err = verify_one_alg(xfrma, XFRMA_ALG_CRYPT)))
+	if ((err = verify_one_alg(attrs, XFRMA_ALG_CRYPT)))
 		goto out;
-	if ((err = verify_one_alg(xfrma, XFRMA_ALG_COMP)))
+	if ((err = verify_one_alg(attrs, XFRMA_ALG_COMP)))
 		goto out;
-	if ((err = verify_sec_ctx_len(xfrma)))
+	if ((err = verify_sec_ctx_len(attrs)))
 		goto out;
 
 	err = -EINVAL;
@@ -298,12 +298,12 @@ static void copy_from_user_state(struct 
  * somehow made shareable and move it to xfrm_state.c - JHS
  *
 */
-static void xfrm_update_ae_params(struct xfrm_state *x, struct rtattr **xfrma)
+static void xfrm_update_ae_params(struct xfrm_state *x, struct rtattr **attrs)
 {
-	struct rtattr *rp = xfrma[XFRMA_REPLAY_VAL];
-	struct rtattr *lt = xfrma[XFRMA_LTIME_VAL];
-	struct rtattr *et = xfrma[XFRMA_ETIMER_THRESH];
-	struct rtattr *rt = xfrma[XFRMA_REPLAY_THRESH];
+	struct rtattr *rp = attrs[XFRMA_REPLAY_VAL];
+	struct rtattr *lt = attrs[XFRMA_LTIME_VAL];
+	struct rtattr *et = attrs[XFRMA_ETIMER_THRESH];
+	struct rtattr *rt = attrs[XFRMA_REPLAY_THRESH];
 
 	if (rp) {
 		struct xfrm_replay_state *replay;
@@ -329,7 +329,7 @@ static void xfrm_update_ae_params(struct
 }
 
 static struct xfrm_state *xfrm_state_construct(struct xfrm_usersa_info *p,
-					       struct rtattr **xfrma,
+					       struct rtattr **attrs,
 					       int *errp)
 {
 	struct xfrm_state *x = xfrm_state_alloc();
@@ -342,25 +342,25 @@ static struct xfrm_state *xfrm_state_con
 
 	if ((err = attach_one_algo(&x->aalg, &x->props.aalgo,
 				   xfrm_aalg_get_byname,
-				   xfrma[XFRMA_ALG_AUTH])))
+				   attrs[XFRMA_ALG_AUTH])))
 		goto error;
 	if ((err = attach_one_algo(&x->ealg, &x->props.ealgo,
 				   xfrm_ealg_get_byname,
-				   xfrma[XFRMA_ALG_CRYPT])))
+				   attrs[XFRMA_ALG_CRYPT])))
 		goto error;
 	if ((err = attach_one_algo(&x->calg, &x->props.calgo,
 				   xfrm_calg_get_byname,
-				   xfrma[XFRMA_ALG_COMP])))
+				   attrs[XFRMA_ALG_COMP])))
 		goto error;
-	if ((err = attach_encap_tmpl(&x->encap, xfrma[XFRMA_ENCAP])))
+	if ((err = attach_encap_tmpl(&x->encap, attrs[XFRMA_ENCAP])))
 		goto error;
-	if ((err = attach_one_addr(&x->coaddr, xfrma[XFRMA_COADDR])))
+	if ((err = attach_one_addr(&x->coaddr, attrs[XFRMA_COADDR])))
 		goto error;
 	err = xfrm_init_state(x);
 	if (err)
 		goto error;
 
-	if ((err = attach_sec_ctx(x, xfrma[XFRMA_SEC_CTX])))
+	if ((err = attach_sec_ctx(x, attrs[XFRMA_SEC_CTX])))
 		goto error;
 
 	x->km.seq = p->seq;
@@ -373,7 +373,7 @@ static struct xfrm_state *xfrm_state_con
 
 	/* override default values from above */
 
-	xfrm_update_ae_params(x, (struct rtattr **)xfrma);
+	xfrm_update_ae_params(x, (struct rtattr **)attrs);
 
 	return x;
 
@@ -386,18 +386,18 @@ error_no_put:
 }
 
 static int xfrm_add_sa(struct sk_buff *skb, struct nlmsghdr *nlh,
-		struct rtattr **xfrma)
+		struct rtattr **attrs)
 {
 	struct xfrm_usersa_info *p = nlmsg_data(nlh);
 	struct xfrm_state *x;
 	int err;
 	struct km_event c;
 
-	err = verify_newsa_info(p, xfrma);
+	err = verify_newsa_info(p, attrs);
 	if (err)
 		return err;
 
-	x = xfrm_state_construct(p, xfrma, &err);
+	x = xfrm_state_construct(p, attrs, &err);
 	if (!x)
 		return err;
 
@@ -427,7 +427,7 @@ out:
 }
 
 static struct xfrm_state *xfrm_user_state_lookup(struct xfrm_usersa_id *p,
-						 struct rtattr **xfrma,
+						 struct rtattr **attrs,
 						 int *errp)
 {
 	struct xfrm_state *x = NULL;
@@ -439,7 +439,7 @@ static struct xfrm_state *xfrm_user_stat
 	} else {
 		xfrm_address_t *saddr = NULL;
 
-		verify_one_addr(xfrma, XFRMA_SRCADDR, &saddr);
+		verify_one_addr(attrs, XFRMA_SRCADDR, &saddr);
 		if (!saddr) {
 			err = -EINVAL;
 			goto out;
@@ -457,14 +457,14 @@ static struct xfrm_state *xfrm_user_stat
 }
 
 static int xfrm_del_sa(struct sk_buff *skb, struct nlmsghdr *nlh,
-		struct rtattr **xfrma)
+		struct rtattr **attrs)
 {
 	struct xfrm_state *x;
 	int err = -ESRCH;
 	struct km_event c;
 	struct xfrm_usersa_id *p = nlmsg_data(nlh);
 
-	x = xfrm_user_state_lookup(p, xfrma, &err);
+	x = xfrm_user_state_lookup(p, attrs, &err);
 	if (x == NULL)
 		return err;
 
@@ -669,7 +669,7 @@ nla_put_failure:
 }
 
 static int xfrm_get_spdinfo(struct sk_buff *skb, struct nlmsghdr *nlh,
-		struct rtattr **xfrma)
+		struct rtattr **attrs)
 {
 	struct sk_buff *r_skb;
 	u32 *flags = nlmsg_data(nlh);
@@ -722,7 +722,7 @@ nla_put_failure:
 }
 
 static int xfrm_get_sadinfo(struct sk_buff *skb, struct nlmsghdr *nlh,
-		struct rtattr **xfrma)
+		struct rtattr **attrs)
 {
 	struct sk_buff *r_skb;
 	u32 *flags = nlmsg_data(nlh);
@@ -740,14 +740,14 @@ static int xfrm_get_sadinfo(struct sk_bu
 }
 
 static int xfrm_get_sa(struct sk_buff *skb, struct nlmsghdr *nlh,
-		struct rtattr **xfrma)
+		struct rtattr **attrs)
 {
 	struct xfrm_usersa_id *p = nlmsg_data(nlh);
 	struct xfrm_state *x;
 	struct sk_buff *resp_skb;
 	int err = -ESRCH;
 
-	x = xfrm_user_state_lookup(p, xfrma, &err);
+	x = xfrm_user_state_lookup(p, attrs, &err);
 	if (x == NULL)
 		goto out_noput;
 
@@ -786,7 +786,7 @@ static int verify_userspi_info(struct xf
 }
 
 static int xfrm_alloc_userspi(struct sk_buff *skb, struct nlmsghdr *nlh,
-		struct rtattr **xfrma)
+		struct rtattr **attrs)
 {
 	struct xfrm_state *x;
 	struct xfrm_userspi_info *p;
@@ -915,9 +915,9 @@ static int verify_newpolicy_info(struct 
 	return verify_policy_dir(p->dir);
 }
 
-static int copy_from_user_sec_ctx(struct xfrm_policy *pol, struct rtattr **xfrma)
+static int copy_from_user_sec_ctx(struct xfrm_policy *pol, struct rtattr **attrs)
 {
-	struct rtattr *rt = xfrma[XFRMA_SEC_CTX];
+	struct rtattr *rt = attrs[XFRMA_SEC_CTX];
 	struct xfrm_user_sec_ctx *uctx;
 
 	if (!rt)
@@ -983,9 +983,9 @@ static int validate_tmpl(int nr, struct 
 	return 0;
 }
 
-static int copy_from_user_tmpl(struct xfrm_policy *pol, struct rtattr **xfrma)
+static int copy_from_user_tmpl(struct xfrm_policy *pol, struct rtattr **attrs)
 {
-	struct rtattr *rt = xfrma[XFRMA_TMPL];
+	struct rtattr *rt = attrs[XFRMA_TMPL];
 
 	if (!rt) {
 		pol->xfrm_nr = 0;
@@ -1003,9 +1003,9 @@ static int copy_from_user_tmpl(struct xf
 	return 0;
 }
 
-static int copy_from_user_policy_type(u8 *tp, struct rtattr **xfrma)
+static int copy_from_user_policy_type(u8 *tp, struct rtattr **attrs)
 {
-	struct rtattr *rt = xfrma[XFRMA_POLICY_TYPE];
+	struct rtattr *rt = attrs[XFRMA_POLICY_TYPE];
 	struct xfrm_userpolicy_type *upt;
 	u8 type = XFRM_POLICY_TYPE_MAIN;
 	int err;
@@ -1049,7 +1049,7 @@ static void copy_to_user_policy(struct x
 	p->share = XFRM_SHARE_ANY; /* XXX xp->share */
 }
 
-static struct xfrm_policy *xfrm_policy_construct(struct xfrm_userpolicy_info *p, struct rtattr **xfrma, int *errp)
+static struct xfrm_policy *xfrm_policy_construct(struct xfrm_userpolicy_info *p, struct rtattr **attrs, int *errp)
 {
 	struct xfrm_policy *xp = xfrm_policy_alloc(GFP_KERNEL);
 	int err;
@@ -1061,12 +1061,12 @@ static struct xfrm_policy *xfrm_policy_c
 
 	copy_from_user_policy(xp, p);
 
-	err = copy_from_user_policy_type(&xp->type, xfrma);
+	err = copy_from_user_policy_type(&xp->type, attrs);
 	if (err)
 		goto error;
 
-	if (!(err = copy_from_user_tmpl(xp, xfrma)))
-		err = copy_from_user_sec_ctx(xp, xfrma);
+	if (!(err = copy_from_user_tmpl(xp, attrs)))
+		err = copy_from_user_sec_ctx(xp, attrs);
 	if (err)
 		goto error;
 
@@ -1078,7 +1078,7 @@ static struct xfrm_policy *xfrm_policy_c
 }
 
 static int xfrm_add_policy(struct sk_buff *skb, struct nlmsghdr *nlh,
-		struct rtattr **xfrma)
+		struct rtattr **attrs)
 {
 	struct xfrm_userpolicy_info *p = nlmsg_data(nlh);
 	struct xfrm_policy *xp;
@@ -1089,11 +1089,11 @@ static int xfrm_add_policy(struct sk_buf
 	err = verify_newpolicy_info(p);
 	if (err)
 		return err;
-	err = verify_sec_ctx_len(xfrma);
+	err = verify_sec_ctx_len(attrs);
 	if (err)
 		return err;
 
-	xp = xfrm_policy_construct(p, xfrma, &err);
+	xp = xfrm_policy_construct(p, attrs, &err);
 	if (!xp)
 		return err;
 
@@ -1271,7 +1271,7 @@ static struct sk_buff *xfrm_policy_netli
 }
 
 static int xfrm_get_policy(struct sk_buff *skb, struct nlmsghdr *nlh,
-		struct rtattr **xfrma)
+		struct rtattr **attrs)
 {
 	struct xfrm_policy *xp;
 	struct xfrm_userpolicy_id *p;
@@ -1283,7 +1283,7 @@ static int xfrm_get_policy(struct sk_buf
 	p = nlmsg_data(nlh);
 	delete = nlh->nlmsg_type == XFRM_MSG_DELPOLICY;
 
-	err = copy_from_user_policy_type(&type, xfrma);
+	err = copy_from_user_policy_type(&type, attrs);
 	if (err)
 		return err;
 
@@ -1294,10 +1294,10 @@ static int xfrm_get_policy(struct sk_buf
 	if (p->index)
 		xp = xfrm_policy_byid(type, p->dir, p->index, delete, &err);
 	else {
-		struct rtattr *rt = xfrma[XFRMA_SEC_CTX];
+		struct rtattr *rt = attrs[XFRMA_SEC_CTX];
 		struct xfrm_policy tmp;
 
-		err = verify_sec_ctx_len(xfrma);
+		err = verify_sec_ctx_len(attrs);
 		if (err)
 			return err;
 
@@ -1345,7 +1345,7 @@ out:
 }
 
 static int xfrm_flush_sa(struct sk_buff *skb, struct nlmsghdr *nlh,
-		struct rtattr **xfrma)
+		struct rtattr **attrs)
 {
 	struct km_event c;
 	struct xfrm_usersa_flush *p = nlmsg_data(nlh);
@@ -1411,7 +1411,7 @@ nla_put_failure:
 }
 
 static int xfrm_get_ae(struct sk_buff *skb, struct nlmsghdr *nlh,
-		struct rtattr **xfrma)
+		struct rtattr **attrs)
 {
 	struct xfrm_state *x;
 	struct sk_buff *r_skb;
@@ -1449,14 +1449,14 @@ static int xfrm_get_ae(struct sk_buff *s
 }
 
 static int xfrm_new_ae(struct sk_buff *skb, struct nlmsghdr *nlh,
-		struct rtattr **xfrma)
+		struct rtattr **attrs)
 {
 	struct xfrm_state *x;
 	struct km_event c;
 	int err = - EINVAL;
 	struct xfrm_aevent_id *p = nlmsg_data(nlh);
-	struct rtattr *rp = xfrma[XFRMA_REPLAY_VAL];
-	struct rtattr *lt = xfrma[XFRMA_LTIME_VAL];
+	struct rtattr *rp = attrs[XFRMA_REPLAY_VAL];
+	struct rtattr *lt = attrs[XFRMA_LTIME_VAL];
 
 	if (!lt && !rp)
 		return err;
@@ -1473,7 +1473,7 @@ static int xfrm_new_ae(struct sk_buff *s
 		goto out;
 
 	spin_lock_bh(&x->lock);
-	xfrm_update_ae_params(x, xfrma);
+	xfrm_update_ae_params(x, attrs);
 	spin_unlock_bh(&x->lock);
 
 	c.event = nlh->nlmsg_type;
@@ -1488,14 +1488,14 @@ out:
 }
 
 static int xfrm_flush_policy(struct sk_buff *skb, struct nlmsghdr *nlh,
-		struct rtattr **xfrma)
+		struct rtattr **attrs)
 {
 	struct km_event c;
 	u8 type = XFRM_POLICY_TYPE_MAIN;
 	int err;
 	struct xfrm_audit audit_info;
 
-	err = copy_from_user_policy_type(&type, xfrma);
+	err = copy_from_user_policy_type(&type, attrs);
 	if (err)
 		return err;
 
@@ -1513,7 +1513,7 @@ static int xfrm_flush_policy(struct sk_b
 }
 
 static int xfrm_add_pol_expire(struct sk_buff *skb, struct nlmsghdr *nlh,
-		struct rtattr **xfrma)
+		struct rtattr **attrs)
 {
 	struct xfrm_policy *xp;
 	struct xfrm_user_polexpire *up = nlmsg_data(nlh);
@@ -1521,17 +1521,17 @@ static int xfrm_add_pol_expire(struct sk
 	u8 type = XFRM_POLICY_TYPE_MAIN;
 	int err = -ENOENT;
 
-	err = copy_from_user_policy_type(&type, xfrma);
+	err = copy_from_user_policy_type(&type, attrs);
 	if (err)
 		return err;
 
 	if (p->index)
 		xp = xfrm_policy_byid(type, p->dir, p->index, 0, &err);
 	else {
-		struct rtattr *rt = xfrma[XFRMA_SEC_CTX];
+		struct rtattr *rt = attrs[XFRMA_SEC_CTX];
 		struct xfrm_policy tmp;
 
-		err = verify_sec_ctx_len(xfrma);
+		err = verify_sec_ctx_len(attrs);
 		if (err)
 			return err;
 
@@ -1574,7 +1574,7 @@ out:
 }
 
 static int xfrm_add_sa_expire(struct sk_buff *skb, struct nlmsghdr *nlh,
-		struct rtattr **xfrma)
+		struct rtattr **attrs)
 {
 	struct xfrm_state *x;
 	int err;
@@ -1606,12 +1606,12 @@ out:
 }
 
 static int xfrm_add_acquire(struct sk_buff *skb, struct nlmsghdr *nlh,
-		struct rtattr **xfrma)
+		struct rtattr **attrs)
 {
 	struct xfrm_policy *xp;
 	struct xfrm_user_tmpl *ut;
 	int i;
-	struct rtattr *rt = xfrma[XFRMA_TMPL];
+	struct rtattr *rt = attrs[XFRMA_TMPL];
 
 	struct xfrm_user_acquire *ua = nlmsg_data(nlh);
 	struct xfrm_state *x = xfrm_state_alloc();
@@ -1628,7 +1628,7 @@ static int xfrm_add_acquire(struct sk_bu
 	}
 
 	/*   build an XP */
-	xp = xfrm_policy_construct(&ua->policy, (struct rtattr **) xfrma, &err);
+	xp = xfrm_policy_construct(&ua->policy, (struct rtattr **) attrs, &err);
 	if (!xp) {
 		kfree(x);
 		return err;
@@ -1661,9 +1661,9 @@ static int xfrm_add_acquire(struct sk_bu
 
 #ifdef CONFIG_XFRM_MIGRATE
 static int copy_from_user_migrate(struct xfrm_migrate *ma,
-				  struct rtattr **xfrma, int *num)
+				  struct rtattr **attrs, int *num)
 {
-	struct rtattr *rt = xfrma[XFRMA_MIGRATE];
+	struct rtattr *rt = attrs[XFRMA_MIGRATE];
 	struct xfrm_user_migrate *um;
 	int i, num_migrate;
 
@@ -1692,7 +1692,7 @@ static int copy_from_user_migrate(struct
 }
 
 static int xfrm_do_migrate(struct sk_buff *skb, struct nlmsghdr *nlh,
-			   struct rtattr **xfrma)
+			   struct rtattr **attrs)
 {
 	struct xfrm_userpolicy_id *pi = nlmsg_data(nlh);
 	struct xfrm_migrate m[XFRM_MAX_DEPTH];
@@ -1700,15 +1700,15 @@ static int xfrm_do_migrate(struct sk_buf
 	int err;
 	int n = 0;
 
-	if (xfrma[XFRMA_MIGRATE] == NULL)
+	if (attrs[XFRMA_MIGRATE] == NULL)
 		return -EINVAL;
 
-	err = copy_from_user_policy_type(&type, (struct rtattr **)xfrma);
+	err = copy_from_user_policy_type(&type, (struct rtattr **)attrs);
 	if (err)
 		return err;
 
 	err = copy_from_user_migrate((struct xfrm_migrate *)m,
-				     (struct rtattr **)xfrma, &n);
+				     (struct rtattr **)attrs, &n);
 	if (err)
 		return err;
 
@@ -1721,7 +1721,7 @@ static int xfrm_do_migrate(struct sk_buf
 }
 #else
 static int xfrm_do_migrate(struct sk_buff *skb, struct nlmsghdr *nlh,
-			   struct rtattr **xfrma)
+			   struct rtattr **attrs)
 {
 	return -ENOPROTOOPT;
 }
@@ -1882,7 +1882,7 @@ static struct xfrm_link {
 
 static int xfrm_user_rcv_msg(struct sk_buff *skb, struct nlmsghdr *nlh)
 {
-	struct nlattr *xfrma[XFRMA_MAX+1];
+	struct nlattr *attrs[XFRMA_MAX+1];
 	struct xfrm_link *link;
 	int type, err;
 
@@ -1906,7 +1906,7 @@ static int xfrm_user_rcv_msg(struct sk_b
 		return netlink_dump_start(xfrm_nl, skb, nlh, link->dump, NULL);
 	}
 
-	err = nlmsg_parse(nlh, xfrm_msg_min[type], xfrma, XFRMA_MAX,
+	err = nlmsg_parse(nlh, xfrm_msg_min[type], attrs, XFRMA_MAX,
 			  xfrma_policy);
 	if (err < 0)
 		return err;
@@ -1914,7 +1914,7 @@ static int xfrm_user_rcv_msg(struct sk_b
 	if (link->doit == NULL)
 		return -EINVAL;
 
-	return link->doit(skb, nlh, (struct rtattr **) xfrma);
+	return link->doit(skb, nlh, (struct rtattr **) attrs);
 }
 
 static void xfrm_netlink_rcv(struct sock *sk, int len)

-- 

