From: jamal <hadi@cyberus.ca>
Subject: [RESEND]	[PATCH][XFRM] SPD info TLV aggregation
Date: Thu, 03 May 2007 19:15:27 -0400
Message-ID: <1178234127.4068.9.camel@localhost>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="=-Ove1OiHX2XGQxwkQVV5S"
Cc: netdev@vger.kernel.org, Patrick McHardy <kaber@trash.net>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from wx-out-0506.google.com ([66.249.82.225]:21374 "EHLO
	wx-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754475AbXECXPc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 May 2007 19:15:32 -0400
Received: by wx-out-0506.google.com with SMTP id h31so591025wxd
        for <netdev@vger.kernel.org>; Thu, 03 May 2007 16:15:31 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--=-Ove1OiHX2XGQxwkQVV5S
Content-Type: text/plain
Content-Transfer-Encoding: 7bit

And heres the SPD version

cheers,
jamal


--=-Ove1OiHX2XGQxwkQVV5S
Content-Disposition: attachment; filename=xfrmk-spd-2622-2
Content-Type: text/plain; name=xfrmk-spd-2622-2; charset=us-ascii
Content-Transfer-Encoding: 7bit

[XFRM] SPD info TLV aggregation
Aggregate the SPD info TLVs.

Signed-off-by: Jamal Hadi Salim <hadi@cyberus.ca>

---
commit bbf6e8386c92047459854427e2f936c58f87d1c1
tree 775125c5526162f9aa1de5105ecc362bdd804817
parent c157d47586129bc4cb8320217df9f80a4dea8b6f
author Jamal Hadi Salim <hadi@cyberus.ca> Thu, 03 May 2007 19:12:47 -0400
committer Jamal Hadi Salim <hadi@cyberus.ca> Thu, 03 May 2007 19:12:47 -0400

 include/linux/xfrm.h   |   41 ++++++++++++++++-----------------------
 include/net/xfrm.h     |   24 +++++++++++------------
 net/xfrm/xfrm_policy.c |    2 +-
 net/xfrm/xfrm_user.c   |   51 +++++++++++++++---------------------------------
 4 files changed, 46 insertions(+), 72 deletions(-)

diff --git a/include/linux/xfrm.h b/include/linux/xfrm.h
index 81c95aa..8a522d5 100644
--- a/include/linux/xfrm.h
+++ b/include/linux/xfrm.h
@@ -288,36 +288,29 @@ struct xfrmu_sadhinfo {
 	__u32 sadhmcnt; /* max allowed hash bkts */
 };
 
-/* SPD Table filter flags  */
-enum xfrm_spd_ftype_t {
-	XFRM_SPD_UNSPEC,
-	XFRM_SPD_HMASK=1,
-	XFRM_SPD_HMAX=2,
-	XFRM_SPD_ICNT=4,
-	XFRM_SPD_OCNT=8,
-	XFRM_SPD_FCNT=16,
-	XFRM_SPD_ISCNT=32,
-	XFRM_SPD_OSCNT=64,
-	XFRM_SPD_FSCNT=128,
-	__XFRM_SPD_MAX
-
-#define XFRM_SPD_MAX (__XFRM_SPD_MAX - 1)
-};
 enum xfrm_spdattr_type_t {
-	XFRMA_SPD_UNSPEC,
-	XFRMA_SPDHMASK,
-	XFRMA_SPDHMAX,
-	XFRMA_SPDICNT,
-	XFRMA_SPDOCNT,
-	XFRMA_SPDFCNT,
-	XFRMA_SPDISCNT,
-	XFRMA_SPDOSCNT,
-	XFRMA_SPDFSCNT,
+	XFRMA_SPDUNSPEC,
+	XFRMA_SPDINFO,
+	XFRMA_SPDHINFO,
 	__XFRMA_SPD_MAX
 
 #define XFRMA_SPD_MAX (__XFRMA_SPD_MAX - 1)
 };
 
+struct xfrmu_spdinfo {
+	__u32 incnt;
+	__u32 outcnt;
+	__u32 fwdcnt;
+	__u32 inscnt;
+	__u32 outscnt;
+	__u32 fwdscnt;
+};
+
+struct xfrmu_spdhinfo {
+	__u32 spdhcnt;
+	__u32 spdhmcnt;
+};
+
 struct xfrm_usersa_info {
 	struct xfrm_selector		sel;
 	struct xfrm_id			id;
diff --git a/include/net/xfrm.h b/include/net/xfrm.h
index d0d7db5..39ef925 100644
--- a/include/net/xfrm.h
+++ b/include/net/xfrm.h
@@ -416,17 +416,6 @@ struct xfrm_audit
 	u32	secid;
 };
 
-struct xfrm_spdinfo
-{
-	u32 incnt;
-	u32 outcnt;
-	u32 fwdcnt;
-	u32 inscnt;
-	u32 outscnt;
-	u32 fwdscnt;
-	u32 spdhcnt;
-	u32 spdhmcnt;
-};
 #ifdef CONFIG_AUDITSYSCALL
 extern void xfrm_audit_log(uid_t auid, u32 secid, int type, int result,
 		    struct xfrm_policy *xp, struct xfrm_state *x);
@@ -963,11 +952,22 @@ struct xfrmk_sadinfo {
 	u32 sadcnt; /* current running count */
 };
 
+struct xfrmk_spdinfo {
+	u32 incnt;
+	u32 outcnt;
+	u32 fwdcnt;
+	u32 inscnt;
+	u32 outscnt;
+	u32 fwdscnt;
+	u32 spdhcnt;
+	u32 spdhmcnt;
+};
+
 extern struct xfrm_state *xfrm_find_acq_byseq(u32 seq);
 extern int xfrm_state_delete(struct xfrm_state *x);
 extern void xfrm_state_flush(u8 proto, struct xfrm_audit *audit_info);
 extern void xfrm_sad_getinfo(struct xfrmk_sadinfo *si);
-extern void xfrm_spd_getinfo(struct xfrm_spdinfo *si);
+extern void xfrm_spd_getinfo(struct xfrmk_spdinfo *si);
 extern int xfrm_replay_check(struct xfrm_state *x, __be32 seq);
 extern void xfrm_replay_advance(struct xfrm_state *x, __be32 seq);
 extern void xfrm_replay_notify(struct xfrm_state *x, int event);
diff --git a/net/xfrm/xfrm_policy.c b/net/xfrm/xfrm_policy.c
index 263e34e..95271e8 100644
--- a/net/xfrm/xfrm_policy.c
+++ b/net/xfrm/xfrm_policy.c
@@ -579,7 +579,7 @@ static inline int xfrm_byidx_should_resize(int total)
 	return 0;
 }
 
-void xfrm_spd_getinfo(struct xfrm_spdinfo *si)
+void xfrm_spd_getinfo(struct xfrmk_spdinfo *si)
 {
 	read_lock_bh(&xfrm_policy_lock);
 	si->incnt = xfrm_policy_count[XFRM_POLICY_IN];
diff --git a/net/xfrm/xfrm_user.c b/net/xfrm/xfrm_user.c
index 9220d14..3b2e6a8 100644
--- a/net/xfrm/xfrm_user.c
+++ b/net/xfrm/xfrm_user.c
@@ -674,7 +674,9 @@ static struct sk_buff *xfrm_state_netlink(struct sk_buff *in_skb,
 
 static int build_spdinfo(struct sk_buff *skb, u32 pid, u32 seq, u32 flags)
 {
-	struct xfrm_spdinfo si;
+	struct xfrmk_spdinfo si;
+	struct xfrmu_spdinfo spc;
+	struct xfrmu_spdhinfo sph;
 	struct nlmsghdr *nlh;
 	u32 *f;
 
@@ -685,23 +687,17 @@ static int build_spdinfo(struct sk_buff *skb, u32 pid, u32 seq, u32 flags)
 	f = nlmsg_data(nlh);
 	*f = flags;
 	xfrm_spd_getinfo(&si);
-
-	if (flags & XFRM_SPD_HMASK)
-		NLA_PUT_U32(skb, XFRMA_SPDHMASK, si.spdhcnt);
-	if (flags & XFRM_SPD_HMAX)
-		NLA_PUT_U32(skb, XFRMA_SPDHMAX, si.spdhmcnt);
-	if (flags & XFRM_SPD_ICNT)
-		NLA_PUT_U32(skb, XFRMA_SPDICNT, si.incnt);
-	if (flags & XFRM_SPD_OCNT)
-		NLA_PUT_U32(skb, XFRMA_SPDOCNT, si.outcnt);
-	if (flags & XFRM_SPD_FCNT)
-		NLA_PUT_U32(skb, XFRMA_SPDFCNT, si.fwdcnt);
-	if (flags & XFRM_SPD_ISCNT)
-		NLA_PUT_U32(skb, XFRMA_SPDISCNT, si.inscnt);
-	if (flags & XFRM_SPD_OSCNT)
-		NLA_PUT_U32(skb, XFRMA_SPDOSCNT, si.inscnt);
-	if (flags & XFRM_SPD_FSCNT)
-		NLA_PUT_U32(skb, XFRMA_SPDFSCNT, si.inscnt);
+	spc.incnt = si.incnt;
+	spc.outcnt = si.outcnt;
+	spc.fwdcnt = si.fwdcnt;
+	spc.inscnt = si.inscnt;
+	spc.outscnt = si.outscnt;
+	spc.fwdscnt = si.fwdscnt;
+	sph.spdhcnt = si.spdhcnt;
+	sph.spdhmcnt = si.spdhmcnt;
+
+	NLA_PUT(skb, XFRMA_SPDINFO, sizeof(spc), &spc);
+	NLA_PUT(skb, XFRMA_SPDHINFO, sizeof(sph), &sph);
 
 	return nlmsg_end(skb, nlh);
 
@@ -719,23 +715,8 @@ static int xfrm_get_spdinfo(struct sk_buff *skb, struct nlmsghdr *nlh,
 	u32 seq = nlh->nlmsg_seq;
 	int len = NLMSG_LENGTH(sizeof(u32));
 
-
-	if (*flags & XFRM_SPD_HMASK)
-		len += RTA_SPACE(sizeof(u32));
-	if (*flags & XFRM_SPD_HMAX)
-		len += RTA_SPACE(sizeof(u32));
-	if (*flags & XFRM_SPD_ICNT)
-		len += RTA_SPACE(sizeof(u32));
-	if (*flags & XFRM_SPD_OCNT)
-		len += RTA_SPACE(sizeof(u32));
-	if (*flags & XFRM_SPD_FCNT)
-		len += RTA_SPACE(sizeof(u32));
-	if (*flags & XFRM_SPD_ISCNT)
-		len += RTA_SPACE(sizeof(u32));
-	if (*flags & XFRM_SPD_OSCNT)
-		len += RTA_SPACE(sizeof(u32));
-	if (*flags & XFRM_SPD_FSCNT)
-		len += RTA_SPACE(sizeof(u32));
+	len += RTA_SPACE(sizeof(struct xfrmu_spdinfo));
+	len += RTA_SPACE(sizeof(struct xfrmu_spdhinfo));
 
 	r_skb = alloc_skb(len, GFP_ATOMIC);
 	if (r_skb == NULL)

--=-Ove1OiHX2XGQxwkQVV5S--

