From: jamal <hadi@cyberus.ca>
Subject: [PATCH 1/2][XFRM]: Sub-policies beautification
Date: Fri, 17 Nov 2006 09:10:16 -0500
Message-ID: <1163772616.5107.40.camel@jzny2>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="=-1KttsjZ5FEHGMStuUHa2"
Cc: Masahide NAKAMURA <nakam@linux-ipv6.org>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx02.cybersurf.com ([209.197.145.105]:1749 "EHLO
	mx02.cybersurf.com") by vger.kernel.org with ESMTP id S932897AbWKQOKS
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 17 Nov 2006 09:10:18 -0500
Received: from mail.cyberus.ca ([209.197.145.21])
	by mx02.cybersurf.com with esmtp (Exim 4.30)
	id 1Gl4Q9-0005iP-4v
	for netdev@vger.kernel.org; Fri, 17 Nov 2006 09:10:21 -0500
To: David Miller <davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--=-1KttsjZ5FEHGMStuUHa2
Content-Type: text/plain
Content-Transfer-Encoding: 7bit

First one

cheers,
jamal

--=-1KttsjZ5FEHGMStuUHa2
Content-Disposition: attachment; filename=ipsec-subp31
Content-Type: text/plain; name=ipsec-subp31; charset=UTF-8
Content-Transfer-Encoding: 7bit

[XFRM]: Make copy_to_user_policy_type take a type
Make copy_to_user_policy_type take a type instead a policy and
fix its users to pass the type

Signed-off-by: Jamal Hadi Salim <hadi@cyberus.ca>

---
commit 5e6a47d1e7baabd38cca9d01f3d78ae1319db535
tree cb4b19b38076cdf545a591ae9d5d6ecd8849c0bc
parent c3d793454ab2a36c2d618d226d7de975ab9b7570
author Jamal Hadi Salim <hadi@cyberus.ca> Fri, 17 Nov 2006 08:52:26 -0500
committer Jamal Hadi Salim <hadi@jzny2.(none)> Fri, 17 Nov 2006 08:52:26 -0500

 net/xfrm/xfrm_user.c |   14 +++++++-------
 1 files changed, 7 insertions(+), 7 deletions(-)

diff --git a/net/xfrm/xfrm_user.c b/net/xfrm/xfrm_user.c
index c4cde57..3c34385 100644
--- a/net/xfrm/xfrm_user.c
+++ b/net/xfrm/xfrm_user.c
@@ -1082,12 +1082,12 @@ static inline int copy_to_user_sec_ctx(s
 }
 
 #ifdef CONFIG_XFRM_SUB_POLICY
-static int copy_to_user_policy_type(struct xfrm_policy *xp, struct sk_buff *skb)
+static int copy_to_user_policy_type(__u8 type, struct sk_buff *skb)
 {
 	struct xfrm_userpolicy_type upt;
 
 	memset(&upt, 0, sizeof(upt));
-	upt.type = xp->type;
+	upt.type = type;
 
 	RTA_PUT(skb, XFRMA_POLICY_TYPE, sizeof(upt), &upt);
 
@@ -1098,7 +1098,7 @@ rtattr_failure:
 }
 
 #else
-static inline int copy_to_user_policy_type(struct xfrm_policy *xp, struct sk_buff *skb)
+static inline int copy_to_user_policy_type(__u8 type, struct sk_buff *skb)
 {
 	return 0;
 }
@@ -1127,7 +1127,7 @@ static int dump_one_policy(struct xfrm_p
 		goto nlmsg_failure;
 	if (copy_to_user_sec_ctx(xp, skb))
 		goto nlmsg_failure;
-	if (copy_to_user_policy_type(xp, skb) < 0)
+	if (copy_to_user_policy_type(xp->type, skb) < 0)
 		goto nlmsg_failure;
 
 	nlh->nlmsg_len = skb->tail - b;
@@ -1907,7 +1907,7 @@ static int build_acquire(struct sk_buff 
 		goto nlmsg_failure;
 	if (copy_to_user_state_sec_ctx(x, skb))
 		goto nlmsg_failure;
-	if (copy_to_user_policy_type(xp, skb) < 0)
+	if (copy_to_user_policy_type(xp->type, skb) < 0)
 		goto nlmsg_failure;
 
 	nlh->nlmsg_len = skb->tail - b;
@@ -2017,7 +2017,7 @@ static int build_polexpire(struct sk_buf
 		goto nlmsg_failure;
 	if (copy_to_user_sec_ctx(xp, skb))
 		goto nlmsg_failure;
-	if (copy_to_user_policy_type(xp, skb) < 0)
+	if (copy_to_user_policy_type(xp->type, skb) < 0)
 		goto nlmsg_failure;
 	upe->hard = !!hard;
 
@@ -2096,7 +2096,7 @@ #endif
 	copy_to_user_policy(xp, p, dir);
 	if (copy_to_user_tmpl(xp, skb) < 0)
 		goto nlmsg_failure;
-	if (copy_to_user_policy_type(xp, skb) < 0)
+	if (copy_to_user_policy_type(xp->type, skb) < 0)
 		goto nlmsg_failure;
 
 	nlh->nlmsg_len = skb->tail - b;

--=-1KttsjZ5FEHGMStuUHa2--

