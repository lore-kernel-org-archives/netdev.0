From: Thomas Graf <tgraf@suug.ch>
Subject: [PATCH 03/16] [XFRM] netlink: Use nlmsg_data() instead of NLMSG_DATA()
Date: Wed, 22 Aug 2007 16:55:41 +0200
Message-ID: <20070822145630.199729600@lsx.localdomain>
References: <20070822145538.861270927@lsx.localdomain>
Cc: netdev@vger.kernel.org, Thomas Graf <tgraf@suug.ch>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from postel.suug.ch ([194.88.212.233]:56971 "EHLO postel.suug.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1763276AbXHVP3S (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 22 Aug 2007 11:29:18 -0400
Content-Disposition: inline; filename=xfrm_nlmsg_data
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Signed-off-by: Thomas Graf <tgraf@suug.ch>

Index: net-2.6.24/net/xfrm/xfrm_user.c
===================================================================
--- net-2.6.24.orig/net/xfrm/xfrm_user.c	2007-08-21 16:12:20.000000000 +0200
+++ net-2.6.24/net/xfrm/xfrm_user.c	2007-08-21 16:13:57.000000000 +0200
@@ -443,7 +443,7 @@ error_no_put:
 static int xfrm_add_sa(struct sk_buff *skb, struct nlmsghdr *nlh,
 		struct rtattr **xfrma)
 {
-	struct xfrm_usersa_info *p = NLMSG_DATA(nlh);
+	struct xfrm_usersa_info *p = nlmsg_data(nlh);
 	struct xfrm_state *x;
 	int err;
 	struct km_event c;
@@ -520,7 +520,7 @@ static int xfrm_del_sa(struct sk_buff *s
 	struct xfrm_state *x;
 	int err = -ESRCH;
 	struct km_event c;
-	struct xfrm_usersa_id *p = NLMSG_DATA(nlh);
+	struct xfrm_usersa_id *p = nlmsg_data(nlh);
 
 	x = xfrm_user_state_lookup(p, xfrma, &err);
 	if (x == NULL)
@@ -592,7 +592,7 @@ static int dump_one_state(struct xfrm_st
 	if (nlh == NULL)
 		return -EMSGSIZE;
 
-	p = NLMSG_DATA(nlh);
+	p = nlmsg_data(nlh);
 	copy_to_user_state(x, p);
 
 	if (x->aalg)
@@ -715,7 +715,7 @@ static int xfrm_get_spdinfo(struct sk_bu
 		struct rtattr **xfrma)
 {
 	struct sk_buff *r_skb;
-	u32 *flags = NLMSG_DATA(nlh);
+	u32 *flags = nlmsg_data(nlh);
 	u32 spid = NETLINK_CB(skb).pid;
 	u32 seq = nlh->nlmsg_seq;
 	int len = NLMSG_LENGTH(sizeof(u32));
@@ -765,7 +765,7 @@ static int xfrm_get_sadinfo(struct sk_bu
 		struct rtattr **xfrma)
 {
 	struct sk_buff *r_skb;
-	u32 *flags = NLMSG_DATA(nlh);
+	u32 *flags = nlmsg_data(nlh);
 	u32 spid = NETLINK_CB(skb).pid;
 	u32 seq = nlh->nlmsg_seq;
 	int len = NLMSG_LENGTH(sizeof(u32));
@@ -787,7 +787,7 @@ static int xfrm_get_sadinfo(struct sk_bu
 static int xfrm_get_sa(struct sk_buff *skb, struct nlmsghdr *nlh,
 		struct rtattr **xfrma)
 {
-	struct xfrm_usersa_id *p = NLMSG_DATA(nlh);
+	struct xfrm_usersa_id *p = nlmsg_data(nlh);
 	struct xfrm_state *x;
 	struct sk_buff *resp_skb;
 	int err = -ESRCH;
@@ -841,7 +841,7 @@ static int xfrm_alloc_userspi(struct sk_
 	int family;
 	int err;
 
-	p = NLMSG_DATA(nlh);
+	p = nlmsg_data(nlh);
 	err = verify_userspi_info(p);
 	if (err)
 		goto out_noput;
@@ -1130,7 +1130,7 @@ static struct xfrm_policy *xfrm_policy_c
 static int xfrm_add_policy(struct sk_buff *skb, struct nlmsghdr *nlh,
 		struct rtattr **xfrma)
 {
-	struct xfrm_userpolicy_info *p = NLMSG_DATA(nlh);
+	struct xfrm_userpolicy_info *p = nlmsg_data(nlh);
 	struct xfrm_policy *xp;
 	struct km_event c;
 	int err;
@@ -1277,8 +1277,8 @@ static int dump_one_policy(struct xfrm_p
 			XFRM_MSG_NEWPOLICY, sizeof(*p), sp->nlmsg_flags);
 	if (nlh == NULL)
 		return -EMSGSIZE;
-	p = NLMSG_DATA(nlh);
 
+	p = nlmsg_data(nlh);
 	copy_to_user_policy(xp, p, dir);
 	if (copy_to_user_tmpl(xp, skb) < 0)
 		goto nlmsg_failure;
@@ -1351,7 +1351,7 @@ static int xfrm_get_policy(struct sk_buf
 	struct km_event c;
 	int delete;
 
-	p = NLMSG_DATA(nlh);
+	p = nlmsg_data(nlh);
 	delete = nlh->nlmsg_type == XFRM_MSG_DELPOLICY;
 
 	err = copy_from_user_policy_type(&type, xfrma);
@@ -1420,7 +1420,7 @@ static int xfrm_flush_sa(struct sk_buff 
 		struct rtattr **xfrma)
 {
 	struct km_event c;
-	struct xfrm_usersa_flush *p = NLMSG_DATA(nlh);
+	struct xfrm_usersa_flush *p = nlmsg_data(nlh);
 	struct xfrm_audit audit_info;
 	int err;
 
@@ -1448,8 +1448,8 @@ static int build_aevent(struct sk_buff *
 	nlh = nlmsg_put(skb, c->pid, c->seq, XFRM_MSG_NEWAE, sizeof(*id), 0);
 	if (nlh == NULL)
 		return -EMSGSIZE;
-	id = NLMSG_DATA(nlh);
 
+	id = nlmsg_data(nlh);
 	memcpy(&id->sa_id.daddr, &x->id.daddr,sizeof(x->id.daddr));
 	id->sa_id.spi = x->id.spi;
 	id->sa_id.family = x->props.family;
@@ -1490,7 +1490,7 @@ static int xfrm_get_ae(struct sk_buff *s
 	struct sk_buff *r_skb;
 	int err;
 	struct km_event c;
-	struct xfrm_aevent_id *p = NLMSG_DATA(nlh);
+	struct xfrm_aevent_id *p = nlmsg_data(nlh);
 	int len = NLMSG_LENGTH(sizeof(struct xfrm_aevent_id));
 	struct xfrm_usersa_id *id = &p->sa_id;
 
@@ -1538,7 +1538,7 @@ static int xfrm_new_ae(struct sk_buff *s
 	struct xfrm_state *x;
 	struct km_event c;
 	int err = - EINVAL;
-	struct xfrm_aevent_id *p = NLMSG_DATA(nlh);
+	struct xfrm_aevent_id *p = nlmsg_data(nlh);
 	struct rtattr *rp = xfrma[XFRMA_REPLAY_VAL-1];
 	struct rtattr *lt = xfrma[XFRMA_LTIME_VAL-1];
 
@@ -1602,7 +1602,7 @@ static int xfrm_add_pol_expire(struct sk
 		struct rtattr **xfrma)
 {
 	struct xfrm_policy *xp;
-	struct xfrm_user_polexpire *up = NLMSG_DATA(nlh);
+	struct xfrm_user_polexpire *up = nlmsg_data(nlh);
 	struct xfrm_userpolicy_info *p = &up->pol;
 	u8 type = XFRM_POLICY_TYPE_MAIN;
 	int err = -ENOENT;
@@ -1664,7 +1664,7 @@ static int xfrm_add_sa_expire(struct sk_
 {
 	struct xfrm_state *x;
 	int err;
-	struct xfrm_user_expire *ue = NLMSG_DATA(nlh);
+	struct xfrm_user_expire *ue = nlmsg_data(nlh);
 	struct xfrm_usersa_info *p = &ue->state;
 
 	x = xfrm_state_lookup(&p->id.daddr, p->id.spi, p->id.proto, p->family);
@@ -1699,7 +1699,7 @@ static int xfrm_add_acquire(struct sk_bu
 	int i;
 	struct rtattr *rt = xfrma[XFRMA_TMPL-1];
 
-	struct xfrm_user_acquire *ua = NLMSG_DATA(nlh);
+	struct xfrm_user_acquire *ua = nlmsg_data(nlh);
 	struct xfrm_state *x = xfrm_state_alloc();
 	int err = -ENOMEM;
 
@@ -1794,7 +1794,7 @@ static int copy_from_user_migrate(struct
 static int xfrm_do_migrate(struct sk_buff *skb, struct nlmsghdr *nlh,
 			   struct rtattr **xfrma)
 {
-	struct xfrm_userpolicy_id *pi = NLMSG_DATA(nlh);
+	struct xfrm_userpolicy_id *pi = nlmsg_data(nlh);
 	struct xfrm_migrate m[XFRM_MAX_DEPTH];
 	u8 type;
 	int err;
@@ -1863,8 +1863,8 @@ static int build_migrate(struct sk_buff 
 	nlh = nlmsg_put(skb, 0, 0, XFRM_MSG_MIGRATE, sizeof(*pol_id), 0);
 	if (nlh == NULL)
 		return -EMSGSIZE;
-	pol_id = NLMSG_DATA(nlh);
 
+	pol_id = nlmsg_data(nlh);
 	/* copy data from selector, dir, and type to the pol_id */
 	memset(pol_id, 0, sizeof(*pol_id));
 	memcpy(&pol_id->sel, sel, sizeof(pol_id->sel));
@@ -2041,8 +2041,8 @@ static int build_expire(struct sk_buff *
 	nlh = nlmsg_put(skb, c->pid, 0, XFRM_MSG_EXPIRE, sizeof(*ue), 0);
 	if (nlh == NULL)
 		return -EMSGSIZE;
-	ue = NLMSG_DATA(nlh);
 
+	ue = nlmsg_data(nlh);
 	copy_to_user_state(x, &ue->state);
 	ue->hard = (c->data.hard != 0) ? 1 : 0;
 
@@ -2100,7 +2100,7 @@ static int xfrm_notify_sa_flush(struct k
 		return -EMSGSIZE;
 	}
 
-	p = NLMSG_DATA(nlh);
+	p = nlmsg_data(nlh);
 	p->proto = c->data.proto;
 
 	nlmsg_end(skb, nlh);
@@ -2148,9 +2148,9 @@ static int xfrm_notify_sa(struct xfrm_st
 	if (nlh == NULL)
 		goto nlmsg_failure;
 
-	p = NLMSG_DATA(nlh);
+	p = nlmsg_data(nlh);
 	if (c->event == XFRM_MSG_DELSA) {
-		id = NLMSG_DATA(nlh);
+		id = nlmsg_data(nlh);
 		memcpy(&id->daddr, &x->id.daddr, sizeof(id->daddr));
 		id->spi = x->id.spi;
 		id->family = x->props.family;
@@ -2218,8 +2218,8 @@ static int build_acquire(struct sk_buff 
 	nlh = nlmsg_put(skb, 0, 0, XFRM_MSG_ACQUIRE, sizeof(*ua), 0);
 	if (nlh == NULL)
 		return -EMSGSIZE;
-	ua = NLMSG_DATA(nlh);
 
+	ua = nlmsg_data(nlh);
 	memcpy(&ua->id, &x->id, sizeof(ua->id));
 	memcpy(&ua->saddr, &x->props.saddr, sizeof(ua->saddr));
 	memcpy(&ua->sel, &x->sel, sizeof(ua->sel));
@@ -2335,8 +2335,8 @@ static int build_polexpire(struct sk_buf
 	nlh = nlmsg_put(skb, c->pid, 0, XFRM_MSG_POLEXPIRE, sizeof(*upe), 0);
 	if (nlh == NULL)
 		return -EMSGSIZE;
-	upe = NLMSG_DATA(nlh);
 
+	upe = nlmsg_data(nlh);
 	copy_to_user_policy(xp, &upe->pol, dir);
 	if (copy_to_user_tmpl(xp, skb) < 0)
 		goto nlmsg_failure;
@@ -2402,9 +2402,9 @@ static int xfrm_notify_policy(struct xfr
 	if (nlh == NULL)
 		goto nlmsg_failure;
 
-	p = NLMSG_DATA(nlh);
+	p = nlmsg_data(nlh);
 	if (c->event == XFRM_MSG_DELPOLICY) {
-		id = NLMSG_DATA(nlh);
+		id = nlmsg_data(nlh);
 		memset(id, 0, sizeof(*id));
 		id->dir = dir;
 		if (c->data.byid)
@@ -2491,8 +2491,8 @@ static int build_report(struct sk_buff *
 	nlh = nlmsg_put(skb, 0, 0, XFRM_MSG_REPORT, sizeof(*ur), 0);
 	if (nlh == NULL)
 		return -EMSGSIZE;
-	ur = NLMSG_DATA(nlh);
 
+	ur = nlmsg_data(nlh);
 	ur->proto = proto;
 	memcpy(&ur->sel, sel, sizeof(ur->sel));
 

-- 

