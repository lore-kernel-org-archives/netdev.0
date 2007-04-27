From: jamal <hadi@cyberus.ca>
Subject: [PATCH][XFRM] export SPD info
Date: Fri, 27 Apr 2007 09:43:41 -0400
Message-ID: <1177681421.4059.2.camel@localhost>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="=-06oelRvcJhn0ATzp/PR+"
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from wx-out-0506.google.com ([66.249.82.225]:29042 "EHLO
	wx-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755839AbXD0Nnt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 27 Apr 2007 09:43:49 -0400
Received: by wx-out-0506.google.com with SMTP id h31so904882wxd
        for <netdev@vger.kernel.org>; Fri, 27 Apr 2007 06:43:48 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--=-06oelRvcJhn0ATzp/PR+
Content-Type: text/plain
Content-Transfer-Encoding: 7bit


Here's the SPD version against net-2.6.

cheers,
jamal

--=-06oelRvcJhn0ATzp/PR+
Content-Disposition: attachment; filename=xfrm_spdinfo
Content-Type: text/plain; name=xfrm_spdinfo; charset=us-ascii
Content-Transfer-Encoding: 7bit

[XFRM] Export SPD info

With this patch you can use iproute2 in user space to efficiently
see how many policies exist in different directions.

Signed-off-by: Jamal Hadi Salim <hadi@cyberus.ca>

---
commit d3db0b0580d7aa519aabc898656bd5ef0345cf49
tree 14b595f1f616403cdcaf30799dea8b13db765fb0
parent 912a41a4ab935ce8c4308428ec13fc7f8b1f18f4
author Jamal Hadi Salim <hadi@cyberus.ca> Fri, 27 Apr 2007 08:05:05 -0400
committer Jamal Hadi Salim <hadi@cyberus.ca> Fri, 27 Apr 2007 08:05:05 -0400

 include/linux/xfrm.h   |   35 ++++++++++++++++++++++
 include/net/xfrm.h     |   13 ++++++++
 net/xfrm/xfrm_policy.c |   16 +++++++++-
 net/xfrm/xfrm_user.c   |   77 ++++++++++++++++++++++++++++++++++++++++++++++++
 4 files changed, 140 insertions(+), 1 deletions(-)

diff --git a/include/linux/xfrm.h b/include/linux/xfrm.h
index 9c656a5..a5d53e0 100644
--- a/include/linux/xfrm.h
+++ b/include/linux/xfrm.h
@@ -185,6 +185,11 @@ enum {
 #define XFRM_MSG_NEWSADINFO XFRM_MSG_NEWSADINFO
 	XFRM_MSG_GETSADINFO,
 #define XFRM_MSG_GETSADINFO XFRM_MSG_GETSADINFO
+
+	XFRM_MSG_NEWSPDINFO,
+#define XFRM_MSG_NEWSPDINFO XFRM_MSG_NEWSPDINFO
+	XFRM_MSG_GETSPDINFO,
+#define XFRM_MSG_GETSPDINFO XFRM_MSG_GETSPDINFO
 	__XFRM_MSG_MAX
 };
 #define XFRM_MSG_MAX (__XFRM_MSG_MAX - 1)
@@ -290,6 +295,36 @@ enum xfrm_sadattr_type_t {
 #define XFRMA_SAD_MAX (__XFRMA_SAD_MAX - 1)
 };
 
+/* SPD Table filter flags  */
+enum xfrm_spd_ftype_t {
+	XFRM_SPD_UNSPEC,
+	XFRM_SPD_HMASK=1,
+	XFRM_SPD_HMAX=2,
+	XFRM_SPD_ICNT=4,
+	XFRM_SPD_OCNT=8,
+	XFRM_SPD_FCNT=16,
+	XFRM_SPD_ISCNT=32,
+	XFRM_SPD_OSCNT=64,
+	XFRM_SPD_FSCNT=128,
+	__XFRM_SPD_MAX
+
+#define XFRM_SPD_MAX (__XFRM_SPD_MAX - 1)
+};
+enum xfrm_spdattr_type_t {
+	XFRMA_SPD_UNSPEC,
+	XFRMA_SPDHMASK,
+	XFRMA_SPDHMAX,
+	XFRMA_SPDICNT,
+	XFRMA_SPDOCNT,
+	XFRMA_SPDFCNT,
+	XFRMA_SPDISCNT,
+	XFRMA_SPDOSCNT,
+	XFRMA_SPDFSCNT,
+	__XFRMA_SPD_MAX
+
+#define XFRMA_SPD_MAX (__XFRMA_SPD_MAX - 1)
+};
+
 struct xfrm_usersa_info {
 	struct xfrm_selector		sel;
 	struct xfrm_id			id;
diff --git a/include/net/xfrm.h b/include/net/xfrm.h
index 8287081..9561bf8 100644
--- a/include/net/xfrm.h
+++ b/include/net/xfrm.h
@@ -423,6 +423,18 @@ struct xfrm_sadinfo
 	u32 sadhmcnt; /* max allowed hash bkts */
 	u32 sadcnt; /* current running count */
 };
+
+struct xfrm_spdinfo
+{
+	u32 incnt;
+	u32 outcnt;
+	u32 fwdcnt;
+	u32 inscnt;
+	u32 outscnt;
+	u32 fwdscnt;
+	u32 spdhcnt;
+	u32 spdhmcnt;
+};
 #ifdef CONFIG_AUDITSYSCALL
 extern void xfrm_audit_log(uid_t auid, u32 secid, int type, int result,
 		    struct xfrm_policy *xp, struct xfrm_state *x);
@@ -946,6 +958,7 @@ extern struct xfrm_state *xfrm_find_acq_byseq(u32 seq);
 extern int xfrm_state_delete(struct xfrm_state *x);
 extern void xfrm_state_flush(u8 proto, struct xfrm_audit *audit_info);
 extern void xfrm_sad_getinfo(struct xfrm_sadinfo *si);
+extern void xfrm_spd_getinfo(struct xfrm_spdinfo *si);
 extern int xfrm_replay_check(struct xfrm_state *x, __be32 seq);
 extern void xfrm_replay_advance(struct xfrm_state *x, __be32 seq);
 extern void xfrm_replay_notify(struct xfrm_state *x, int event);
diff --git a/net/xfrm/xfrm_policy.c b/net/xfrm/xfrm_policy.c
index 7629260..dbf9d96 100644
--- a/net/xfrm/xfrm_policy.c
+++ b/net/xfrm/xfrm_policy.c
@@ -579,8 +579,22 @@ static inline int xfrm_byidx_should_resize(int total)
 	return 0;
 }
 
-static DEFINE_MUTEX(hash_resize_mutex);
+void xfrm_spd_getinfo(struct xfrm_spdinfo *si)
+{
+	read_lock_bh(&xfrm_policy_lock);
+	si->incnt = xfrm_policy_count[XFRM_POLICY_IN];
+	si->outcnt = xfrm_policy_count[XFRM_POLICY_OUT];
+	si->fwdcnt = xfrm_policy_count[XFRM_POLICY_FWD];
+	si->inscnt = xfrm_policy_count[XFRM_POLICY_IN+XFRM_POLICY_MAX];
+	si->outscnt = xfrm_policy_count[XFRM_POLICY_OUT+XFRM_POLICY_MAX];
+	si->fwdscnt = xfrm_policy_count[XFRM_POLICY_FWD+XFRM_POLICY_MAX];
+	si->spdhcnt = xfrm_idx_hmask;
+	si->spdhmcnt = xfrm_policy_hashmax;
+	read_unlock_bh(&xfrm_policy_lock);
+}
+EXPORT_SYMBOL(xfrm_spd_getinfo);
 
+static DEFINE_MUTEX(hash_resize_mutex);
 static void xfrm_hash_resize(struct work_struct *__unused)
 {
 	int dir, total;
diff --git a/net/xfrm/xfrm_user.c b/net/xfrm/xfrm_user.c
index 69110fe..4210d91 100644
--- a/net/xfrm/xfrm_user.c
+++ b/net/xfrm/xfrm_user.c
@@ -672,6 +672,81 @@ static struct sk_buff *xfrm_state_netlink(struct sk_buff *in_skb,
 	return skb;
 }
 
+static int build_spdinfo(struct sk_buff *skb, u32 pid, u32 seq, u32 flags)
+{
+	struct xfrm_spdinfo si;
+	struct nlmsghdr *nlh;
+	u32 *f;
+
+	nlh = nlmsg_put(skb, pid, seq, XFRM_MSG_NEWSPDINFO, sizeof(u32), 0);
+	if (nlh == NULL) /* shouldnt really happen ... */
+		return -EMSGSIZE;
+
+	f = nlmsg_data(nlh);
+	*f = flags;
+	xfrm_spd_getinfo(&si);
+
+	if (flags & XFRM_SPD_HMASK)
+		NLA_PUT_U32(skb, XFRMA_SPDHMASK, si.spdhcnt);
+	if (flags & XFRM_SPD_HMAX)
+		NLA_PUT_U32(skb, XFRMA_SPDHMAX, si.spdhmcnt);
+	if (flags & XFRM_SPD_ICNT)
+		NLA_PUT_U32(skb, XFRMA_SPDICNT, si.incnt);
+	if (flags & XFRM_SPD_OCNT)
+		NLA_PUT_U32(skb, XFRMA_SPDOCNT, si.outcnt);
+	if (flags & XFRM_SPD_FCNT)
+		NLA_PUT_U32(skb, XFRMA_SPDFCNT, si.fwdcnt);
+	if (flags & XFRM_SPD_ISCNT)
+		NLA_PUT_U32(skb, XFRMA_SPDISCNT, si.inscnt);
+	if (flags & XFRM_SPD_OSCNT)
+		NLA_PUT_U32(skb, XFRMA_SPDOSCNT, si.inscnt);
+	if (flags & XFRM_SPD_FSCNT)
+		NLA_PUT_U32(skb, XFRMA_SPDFSCNT, si.inscnt);
+
+	return nlmsg_end(skb, nlh);
+
+nla_put_failure:
+	nlmsg_cancel(skb, nlh);
+	return -EMSGSIZE;
+}
+
+static int xfrm_get_spdinfo(struct sk_buff *skb, struct nlmsghdr *nlh,
+		struct rtattr **xfrma)
+{
+	struct sk_buff *r_skb;
+	u32 *flags = NLMSG_DATA(nlh);
+	u32 spid = NETLINK_CB(skb).pid;
+	u32 seq = nlh->nlmsg_seq;
+	int len = NLMSG_LENGTH(sizeof(u32));
+
+
+	if (*flags & XFRM_SPD_HMASK)
+		len += RTA_SPACE(sizeof(u32));
+	if (*flags & XFRM_SPD_HMAX)
+		len += RTA_SPACE(sizeof(u32));
+	if (*flags & XFRM_SPD_ICNT)
+		len += RTA_SPACE(sizeof(u32));
+	if (*flags & XFRM_SPD_OCNT)
+		len += RTA_SPACE(sizeof(u32));
+	if (*flags & XFRM_SPD_FCNT)
+		len += RTA_SPACE(sizeof(u32));
+	if (*flags & XFRM_SPD_ISCNT)
+		len += RTA_SPACE(sizeof(u32));
+	if (*flags & XFRM_SPD_OSCNT)
+		len += RTA_SPACE(sizeof(u32));
+	if (*flags & XFRM_SPD_FSCNT)
+		len += RTA_SPACE(sizeof(u32));
+
+	r_skb = alloc_skb(len, GFP_ATOMIC);
+	if (r_skb == NULL)
+		return -ENOMEM;
+
+	if (build_spdinfo(r_skb, spid, seq, *flags) < 0)
+		BUG();
+
+	return nlmsg_unicast(xfrm_nl, r_skb, spid);
+}
+
 static int build_sadinfo(struct sk_buff *skb, u32 pid, u32 seq, u32 flags)
 {
 	struct xfrm_sadinfo si;
@@ -1879,6 +1954,7 @@ static const int xfrm_msg_min[XFRM_NR_MSGTYPES] = {
 	[XFRM_MSG_REPORT      - XFRM_MSG_BASE] = XMSGSIZE(xfrm_user_report),
 	[XFRM_MSG_MIGRATE     - XFRM_MSG_BASE] = XMSGSIZE(xfrm_userpolicy_id),
 	[XFRM_MSG_GETSADINFO  - XFRM_MSG_BASE] = NLMSG_LENGTH(sizeof(u32)),
+	[XFRM_MSG_GETSPDINFO  - XFRM_MSG_BASE] = NLMSG_LENGTH(sizeof(u32)),
 };
 
 #undef XMSGSIZE
@@ -1907,6 +1983,7 @@ static struct xfrm_link {
 	[XFRM_MSG_GETAE       - XFRM_MSG_BASE] = { .doit = xfrm_get_ae  },
 	[XFRM_MSG_MIGRATE     - XFRM_MSG_BASE] = { .doit = xfrm_do_migrate    },
 	[XFRM_MSG_GETSADINFO  - XFRM_MSG_BASE] = { .doit = xfrm_get_sadinfo   },
+	[XFRM_MSG_GETSPDINFO  - XFRM_MSG_BASE] = { .doit = xfrm_get_spdinfo   },
 };
 
 static int xfrm_user_rcv_msg(struct sk_buff *skb, struct nlmsghdr *nlh)

--=-06oelRvcJhn0ATzp/PR+--

