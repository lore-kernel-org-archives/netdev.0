From: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Subject: [PATCH 42/44] [XFRM] POLICY: Support netlink socket interface for sub policy.
Date: Thu, 24 Aug 2006 00:02:43 +0900
Message-ID: <11563453673854-git-send-email-yoshfuji@linux-ipv6.org>
References: <11563453651167-git-send-email-yoshfuji@linux-ipv6.org> <11563453651533-git-send-email-yoshfuji@linux-ipv6.org> <11563453653169-git-send-email-yoshfuji@linux-ipv6.org> <1156345365325-git-send-email-yoshfuji@linux-ipv6.org> <11563453653851-git-send-email-yoshfuji@linux-ipv6.org> <11563453653575-git-send-email-yoshfuji@linux-ipv6.org> <1156345365651-git-send-email-yoshfuji@linux-ipv6.org> <1156345365264-git-send-email-yoshfuji@linux-ipv6.org> <1156345365312-git-send-email-yoshfuji@linux-ipv6.org> <11563453652646-git-send-email-yoshfuji@linux-ipv6.org> <1156345365315-git-send-email-yoshfuji@linux-ipv6.org> <11563453651452-git-send-email-yoshfuji@linux-ipv6.org> <1156345366288-git-send-email-yoshfuji@linux-ipv6.org> <1156345366857-git-send-email-yoshfuji@linux-ipv6.org> <11563453663761-git-send-email-yoshfuji@linux-ipv6.org> <11563453662321-git-send-email-yoshfuji@linux-ipv6.org>
  <11563453661892-git-send-email-yoshfuji@linux-ipv6.org> <11563453661207-git-send-email-yoshfuji@linux-ipv6.org> <11563453663743-git-send-email-yoshfuji@linux-ipv6.org> <1156345366676-git-send-email-yoshfuji@linux-ipv6.org> <11563453662840-git-send-email-yoshfuji@linux-ipv6.org> <11563453662913-git-send-email-yoshfuji@linux-ipv6.org> <11563453663400-git-send-email-yoshfuji@linux-ipv6.org> <1156345366549-git-send-email-yoshfuji@linux-ipv6.org> <11563453662956-git-send-email-yoshfuji@linux-ipv6.org> <11563453661764-git-send-email-yoshfuji@linux-ipv6.org> <11563453663275-git-send-email-yoshfuji@linux-ipv6.org> <11563453671174-git-send-email-yoshfuji@linux-ipv6.org> <11563453674049-git-send-email-yoshfuji@linux-ipv6.org> <11563453673517-git-send-email-yoshfuji@linux-ipv6.org> <11563453674137-git-send-email-yoshfuji@linux-ipv6.org> <11563453671944-git-send-email-yoshfuji@linux-ipv6.org> <11
 563453671187-git-send-email-yoshfuji@linux-ipv6.org> <11563453672959-git-send-email-yoshfuji@linux-ipv6.org> <1156345367208-git-send-email-yoshfuji@linux-ipv6.org> <11563453673786-git-send-email-yoshfuji@linux-ipv6.org> <11563453672531-git-send-email-yoshfuji@linux-ipv6.org> <11563453674194-git-send-email-yoshfuji@linux-ipv6.org> <11563453671463-git-send-email-yoshfuji@linux-ipv6.org> <11563453672872-git-send-email-yoshfuji@linux-ipv6.org> <11563453671273-git-send-email-yoshfuji@linux-ipv6.org> <11563453674024-git-send-email-yoshfuji@linux-ipv6.org>
Cc: yoshfuji@linux-ipv6.org, anttit@tcs.hut.fi, vnuorval@tcs.hut.fi,
	netdev@vger.kernel.org, usagi-core@linux-ipv6.org,
	Masahide NAKAMURA <nakam@linux-ipv6.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from pc9.nezu.wide.ad.jp ([203.178.142.216]:11913 "EHLO
	jupiter.linux-ipv6.org") by vger.kernel.org with ESMTP
	id S964959AbWHWPCw (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 23 Aug 2006 11:02:52 -0400
To: davem@davemloft.net
In-Reply-To: <11563453674024-git-send-email-yoshfuji@linux-ipv6.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Masahide NAKAMURA <nakam@linux-ipv6.org>

Sub policy can be used through netlink socket.
PF_KEY uses main only and it is TODO to support sub.

Signed-off-by: Masahide NAKAMURA <nakam@linux-ipv6.org>
Signed-off-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
---
 include/linux/xfrm.h |    7 +++
 include/net/xfrm.h   |    1 
 net/key/af_key.c     |   18 +++++--
 net/xfrm/xfrm_user.c |  134 +++++++++++++++++++++++++++++++++++++++++++++-----
 4 files changed, 142 insertions(+), 18 deletions(-)

diff --git a/include/linux/xfrm.h b/include/linux/xfrm.h
index 492fb98..14ecd19 100644
--- a/include/linux/xfrm.h
+++ b/include/linux/xfrm.h
@@ -230,6 +230,12 @@ enum xfrm_ae_ftype_t {
 #define XFRM_AE_MAX (__XFRM_AE_MAX - 1)
 };
 
+struct xfrm_userpolicy_type {
+	__u8		type;
+	__u16		reserved1;
+	__u8		reserved2;
+};
+
 /* Netlink message attributes.  */
 enum xfrm_attr_type_t {
 	XFRMA_UNSPEC,
@@ -248,6 +254,7 @@ enum xfrm_attr_type_t {
 	XFRMA_SRCADDR,		/* xfrm_address_t */
 	XFRMA_COADDR,		/* xfrm_address_t */
 	XFRMA_LASTUSED,
+	XFRMA_POLICY_TYPE,	/* struct xfrm_userpolicy_type */
 	__XFRMA_MAX
 
 #define XFRMA_MAX (__XFRMA_MAX - 1)
diff --git a/include/net/xfrm.h b/include/net/xfrm.h
index aab31a2..0f1117d 100644
--- a/include/net/xfrm.h
+++ b/include/net/xfrm.h
@@ -204,6 +204,7 @@ struct km_event
 		u32 proto;
 		u32 byid;
 		u32 aevent;
+		u32 type;
 	} data;
 
 	u32	seq;
diff --git a/net/key/af_key.c b/net/key/af_key.c
index 19e047b..83b443d 100644
--- a/net/key/af_key.c
+++ b/net/key/af_key.c
@@ -1731,7 +1731,8 @@ static u32 gen_reqid(void)
 		++reqid;
 		if (reqid == 0)
 			reqid = IPSEC_MANUAL_REQID_MAX+1;
-		if (xfrm_policy_walk(check_reqid, (void*)&reqid) != -EEXIST)
+		if (xfrm_policy_walk(XFRM_POLICY_TYPE_MAIN, check_reqid,
+				     (void*)&reqid) != -EEXIST)
 			return reqid;
 	} while (reqid != start);
 	return 0;
@@ -2268,7 +2269,8 @@ static int pfkey_spddelete(struct sock *
 			return err;
 	}
 
-	xp = xfrm_policy_bysel_ctx(pol->sadb_x_policy_dir-1, &sel, tmp.security, 1);
+	xp = xfrm_policy_bysel_ctx(XFRM_POLICY_TYPE_MAIN, pol->sadb_x_policy_dir-1,
+				   &sel, tmp.security, 1);
 	security_xfrm_policy_free(&tmp);
 	if (xp == NULL)
 		return -ENOENT;
@@ -2330,7 +2332,7 @@ static int pfkey_spdget(struct sock *sk,
 	if (dir >= XFRM_POLICY_MAX)
 		return -EINVAL;
 
-	xp = xfrm_policy_byid(dir, pol->sadb_x_policy_id,
+	xp = xfrm_policy_byid(XFRM_POLICY_TYPE_MAIN, dir, pol->sadb_x_policy_id,
 			      hdr->sadb_msg_type == SADB_X_SPDDELETE2);
 	if (xp == NULL)
 		return -ENOENT;
@@ -2378,7 +2380,7 @@ static int pfkey_spddump(struct sock *sk
 {
 	struct pfkey_dump_data data = { .skb = skb, .hdr = hdr, .sk = sk };
 
-	return xfrm_policy_walk(dump_sp, &data);
+	return xfrm_policy_walk(XFRM_POLICY_TYPE_MAIN, dump_sp, &data);
 }
 
 static int key_notify_policy_flush(struct km_event *c)
@@ -2405,7 +2407,8 @@ static int pfkey_spdflush(struct sock *s
 {
 	struct km_event c;
 
-	xfrm_policy_flush();
+	xfrm_policy_flush(XFRM_POLICY_TYPE_MAIN);
+	c.data.type = XFRM_POLICY_TYPE_MAIN;
 	c.event = XFRM_MSG_FLUSHPOLICY;
 	c.pid = hdr->sadb_msg_pid;
 	c.seq = hdr->sadb_msg_seq;
@@ -2667,6 +2670,9 @@ static int pfkey_send_notify(struct xfrm
 
 static int pfkey_send_policy_notify(struct xfrm_policy *xp, int dir, struct km_event *c)
 {
+	if (xp && xp->type != XFRM_POLICY_TYPE_MAIN)
+		return 0;
+
 	switch (c->event) {
 	case XFRM_MSG_POLEXPIRE:
 		return key_notify_policy_expire(xp, c);
@@ -2675,6 +2681,8 @@ static int pfkey_send_policy_notify(stru
 	case XFRM_MSG_UPDPOLICY:
 		return key_notify_policy(xp, dir, c);
 	case XFRM_MSG_FLUSHPOLICY:
+		if (c->data.type != XFRM_POLICY_TYPE_MAIN)
+			break;
 		return key_notify_policy_flush(c);
 	default:
 		printk("pfkey: Unknown policy event %d\n", c->event);
diff --git a/net/xfrm/xfrm_user.c b/net/xfrm/xfrm_user.c
index a4a4dd6..a096586 100644
--- a/net/xfrm/xfrm_user.c
+++ b/net/xfrm/xfrm_user.c
@@ -784,6 +784,22 @@ static int verify_policy_dir(__u8 dir)
 	return 0;
 }
 
+static int verify_policy_type(__u8 type)
+{
+	switch (type) {
+	case XFRM_POLICY_TYPE_MAIN:
+#ifdef CONFIG_XFRM_SUB_POLICY
+	case XFRM_POLICY_TYPE_SUB:
+#endif
+		break;
+
+	default:
+		return -EINVAL;
+	};
+
+	return 0;
+}
+
 static int verify_newpolicy_info(struct xfrm_userpolicy_info *p)
 {
 	switch (p->share) {
@@ -877,6 +893,29 @@ static int copy_from_user_tmpl(struct xf
 	return 0;
 }
 
+static int copy_from_user_policy_type(u8 *tp, struct rtattr **xfrma)
+{
+	struct rtattr *rt = xfrma[XFRMA_POLICY_TYPE-1];
+	struct xfrm_userpolicy_type *upt;
+	__u8 type = XFRM_POLICY_TYPE_MAIN;
+	int err;
+
+	if (rt) {
+		if (rt->rta_len < sizeof(*upt))
+			return -EINVAL;
+
+		upt = RTA_DATA(rt);
+		type = upt->type;
+	}
+
+	err = verify_policy_type(type);
+	if (err)
+		return err;
+
+	*tp = type;
+	return 0;
+}
+
 static void copy_from_user_policy(struct xfrm_policy *xp, struct xfrm_userpolicy_info *p)
 {
 	xp->priority = p->priority;
@@ -915,16 +954,20 @@ static struct xfrm_policy *xfrm_policy_c
 
 	copy_from_user_policy(xp, p);
 
+	err = copy_from_user_policy_type(&xp->type, xfrma);
+	if (err)
+		goto error;
+
 	if (!(err = copy_from_user_tmpl(xp, xfrma)))
 		err = copy_from_user_sec_ctx(xp, xfrma);
-
-	if (err) {
-		*errp = err;
-		kfree(xp);
-		xp = NULL;
-	}
+	if (err)
+		goto error;
 
 	return xp;
+ error:
+	*errp = err;
+	kfree(xp);
+	return NULL;
 }
 
 static int xfrm_add_policy(struct sk_buff *skb, struct nlmsghdr *nlh, void **xfrma)
@@ -1035,6 +1078,29 @@ static inline int copy_to_user_sec_ctx(s
 	return 0;
 }
 
+#ifdef CONFIG_XFRM_SUB_POLICY
+static int copy_to_user_policy_type(struct xfrm_policy *xp, struct sk_buff *skb)
+{
+	struct xfrm_userpolicy_type upt;
+
+	memset(&upt, 0, sizeof(upt));
+	upt.type = xp->type;
+
+	RTA_PUT(skb, XFRMA_POLICY_TYPE, sizeof(upt), &upt);
+
+	return 0;
+
+rtattr_failure:
+	return -1;
+}
+
+#else
+static inline int copy_to_user_policy_type(struct xfrm_policy *xp, struct sk_buff *skb)
+{
+	return 0;
+}
+#endif
+
 static int dump_one_policy(struct xfrm_policy *xp, int dir, int count, void *ptr)
 {
 	struct xfrm_dump_info *sp = ptr;
@@ -1058,6 +1124,8 @@ static int dump_one_policy(struct xfrm_p
 		goto nlmsg_failure;
 	if (copy_to_user_sec_ctx(xp, skb))
 		goto nlmsg_failure;
+	if (copy_to_user_policy_type(xp, skb) < 0)
+		goto nlmsg_failure;
 
 	nlh->nlmsg_len = skb->tail - b;
 out:
@@ -1079,7 +1147,10 @@ static int xfrm_dump_policy(struct sk_bu
 	info.nlmsg_flags = NLM_F_MULTI;
 	info.this_idx = 0;
 	info.start_idx = cb->args[0];
-	(void) xfrm_policy_walk(dump_one_policy, &info);
+	(void) xfrm_policy_walk(XFRM_POLICY_TYPE_MAIN, dump_one_policy, &info);
+#ifdef CONFIG_XFRM_SUB_POLICY
+	(void) xfrm_policy_walk(XFRM_POLICY_TYPE_SUB, dump_one_policy, &info);
+#endif
 	cb->args[0] = info.this_idx;
 
 	return skb->len;
@@ -1115,6 +1186,7 @@ static int xfrm_get_policy(struct sk_buf
 {
 	struct xfrm_policy *xp;
 	struct xfrm_userpolicy_id *p;
+	__u8 type = XFRM_POLICY_TYPE_MAIN;
 	int err;
 	struct km_event c;
 	int delete;
@@ -1122,12 +1194,16 @@ static int xfrm_get_policy(struct sk_buf
 	p = NLMSG_DATA(nlh);
 	delete = nlh->nlmsg_type == XFRM_MSG_DELPOLICY;
 
+	err = copy_from_user_policy_type(&type, (struct rtattr **)xfrma);
+	if (err)
+		return err;
+
 	err = verify_policy_dir(p->dir);
 	if (err)
 		return err;
 
 	if (p->index)
-		xp = xfrm_policy_byid(p->dir, p->index, delete);
+		xp = xfrm_policy_byid(type, p->dir, p->index, delete);
 	else {
 		struct rtattr **rtattrs = (struct rtattr **)xfrma;
 		struct rtattr *rt = rtattrs[XFRMA_SEC_CTX-1];
@@ -1144,7 +1220,7 @@ static int xfrm_get_policy(struct sk_buf
 			if ((err = security_xfrm_policy_alloc(&tmp, uctx)))
 				return err;
 		}
-		xp = xfrm_policy_bysel_ctx(p->dir, &p->sel, tmp.security, delete);
+		xp = xfrm_policy_bysel_ctx(type, p->dir, &p->sel, tmp.security, delete);
 		security_xfrm_policy_free(&tmp);
 	}
 	if (xp == NULL)
@@ -1327,9 +1403,16 @@ out:
 
 static int xfrm_flush_policy(struct sk_buff *skb, struct nlmsghdr *nlh, void **xfrma)
 {
-struct km_event c;
+	struct km_event c;
+	__u8 type = XFRM_POLICY_TYPE_MAIN;
+	int err;
+
+	err = copy_from_user_policy_type(&type, (struct rtattr **)xfrma);
+	if (err)
+		return err;
 
-	xfrm_policy_flush();
+	xfrm_policy_flush(type);
+	c.data.type = type;
 	c.event = nlh->nlmsg_type;
 	c.seq = nlh->nlmsg_seq;
 	c.pid = nlh->nlmsg_pid;
@@ -1342,10 +1425,15 @@ static int xfrm_add_pol_expire(struct sk
 	struct xfrm_policy *xp;
 	struct xfrm_user_polexpire *up = NLMSG_DATA(nlh);
 	struct xfrm_userpolicy_info *p = &up->pol;
+	__u8 type = XFRM_POLICY_TYPE_MAIN;
 	int err = -ENOENT;
 
+	err = copy_from_user_policy_type(&type, (struct rtattr **)xfrma);
+	if (err)
+		return err;
+
 	if (p->index)
-		xp = xfrm_policy_byid(p->dir, p->index, 0);
+		xp = xfrm_policy_byid(type, p->dir, p->index, 0);
 	else {
 		struct rtattr **rtattrs = (struct rtattr **)xfrma;
 		struct rtattr *rt = rtattrs[XFRMA_SEC_CTX-1];
@@ -1362,7 +1450,7 @@ static int xfrm_add_pol_expire(struct sk
 			if ((err = security_xfrm_policy_alloc(&tmp, uctx)))
 				return err;
 		}
-		xp = xfrm_policy_bysel_ctx(p->dir, &p->sel, tmp.security, 0);
+		xp = xfrm_policy_bysel_ctx(type, p->dir, &p->sel, tmp.security, 0);
 		security_xfrm_policy_free(&tmp);
 	}
 
@@ -1816,6 +1904,8 @@ static int build_acquire(struct sk_buff 
 		goto nlmsg_failure;
 	if (copy_to_user_state_sec_ctx(x, skb))
 		goto nlmsg_failure;
+	if (copy_to_user_policy_type(xp, skb) < 0)
+		goto nlmsg_failure;
 
 	nlh->nlmsg_len = skb->tail - b;
 	return skb->len;
@@ -1896,6 +1986,7 @@ #endif
 	}
 
 	copy_from_user_policy(xp, p);
+	xp->type = XFRM_POLICY_TYPE_MAIN;
 	copy_templates(xp, ut, nr);
 
 	if (!xp->security) {
@@ -1929,6 +2020,8 @@ static int build_polexpire(struct sk_buf
 		goto nlmsg_failure;
 	if (copy_to_user_sec_ctx(xp, skb))
 		goto nlmsg_failure;
+	if (copy_to_user_policy_type(xp, skb) < 0)
+		goto nlmsg_failure;
 	upe->hard = !!hard;
 
 	nlh->nlmsg_len = skb->tail - b;
@@ -2000,6 +2093,8 @@ static int xfrm_notify_policy(struct xfr
 	copy_to_user_policy(xp, p, dir);
 	if (copy_to_user_tmpl(xp, skb) < 0)
 		goto nlmsg_failure;
+	if (copy_to_user_policy_type(xp, skb) < 0)
+		goto nlmsg_failure;
 
 	nlh->nlmsg_len = skb->tail - b;
 
@@ -2017,6 +2112,9 @@ static int xfrm_notify_policy_flush(stru
 	struct nlmsghdr *nlh;
 	struct sk_buff *skb;
 	unsigned char *b;
+#ifdef CONFIG_XFRM_SUB_POLICY
+	struct xfrm_userpolicy_type upt;
+#endif
 	int len = NLMSG_LENGTH(0);
 
 	skb = alloc_skb(len, GFP_ATOMIC);
@@ -2026,6 +2124,13 @@ static int xfrm_notify_policy_flush(stru
 
 
 	nlh = NLMSG_PUT(skb, c->pid, c->seq, XFRM_MSG_FLUSHPOLICY, 0);
+	nlh->nlmsg_flags = 0;
+
+#ifdef CONFIG_XFRM_SUB_POLICY
+	memset(&upt, 0, sizeof(upt));
+	upt.type = c->data.type;
+	RTA_PUT(skb, XFRMA_POLICY_TYPE, sizeof(upt), &upt);
+#endif
 
 	nlh->nlmsg_len = skb->tail - b;
 
@@ -2033,6 +2138,9 @@ static int xfrm_notify_policy_flush(stru
 	return netlink_broadcast(xfrm_nl, skb, 0, XFRMNLGRP_POLICY, GFP_ATOMIC);
 
 nlmsg_failure:
+#ifdef CONFIG_XFRM_SUB_POLICY
+rtattr_failure:
+#endif
 	kfree_skb(skb);
 	return -1;
 }
-- 
1.4.0

