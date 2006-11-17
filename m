From: jamal <hadi@cyberus.ca>
Subject: [PATCH][XFRM]: nlmsg length not computed correctly in the presence
	of subpolicies
Date: Fri, 17 Nov 2006 08:48:31 -0500
Message-ID: <1163771311.5107.24.camel@jzny2>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="=-73Ao42onm+pQArdHfk1n"
Cc: Masahide NAKAMURA <nakam@linux-ipv6.org>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx03.cybersurf.com ([209.197.145.106]:59617 "EHLO
	mx03.cybersurf.com") by vger.kernel.org with ESMTP id S1424409AbWKQNsf
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 17 Nov 2006 08:48:35 -0500
Received: from mail.cyberus.ca ([209.197.145.21])
	by mx03.cybersurf.com with esmtp (Exim 4.30)
	id 1Gl457-0003S1-KY
	for netdev@vger.kernel.org; Fri, 17 Nov 2006 08:48:37 -0500
To: David Miller <davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--=-73Ao42onm+pQArdHfk1n
Content-Type: text/plain
Content-Transfer-Encoding: 7bit

Another one in the same spirit as before. Compiles. I dont have
a good test case, but looks right.
Nakamura-san please ACK and Dave (as before this goes in as a bug-fix).

cheers,
jamal

--=-73Ao42onm+pQArdHfk1n
Content-Disposition: attachment; filename=ipsec-subp2
Content-Type: text/plain; name=ipsec-subp2; charset=UTF-8
Content-Transfer-Encoding: 7bit

[XFRM]: nlmsg length not computed correctly in the presence of subpolicies

I actually dont have a test case for these; i just found them by
inspection. Refer to patch "[XFRM]: Sub-policies broke policy events"
for more info

Signed-off-by: Jamal Hadi Salim <hadi@cyberus.ca>

---
commit c3d793454ab2a36c2d618d226d7de975ab9b7570
tree 26198ba84d85317b4f1b54c0e10c220dbe0d97da
parent b53ec68c276ac1d879759de130620a72254cb969
author Jamal Hadi Salim <hadi@cyberus.ca> Fri, 17 Nov 2006 08:39:52 -0500
committer Jamal Hadi Salim <hadi@jzny2.(none)> Fri, 17 Nov 2006 08:39:52 -0500

 net/xfrm/xfrm_user.c |   10 +++++++++-
 1 files changed, 9 insertions(+), 1 deletions(-)

diff --git a/net/xfrm/xfrm_user.c b/net/xfrm/xfrm_user.c
index 2dae1c1..c4cde57 100644
--- a/net/xfrm/xfrm_user.c
+++ b/net/xfrm/xfrm_user.c
@@ -1927,6 +1927,9 @@ static int xfrm_send_acquire(struct xfrm
 	len = RTA_SPACE(sizeof(struct xfrm_user_tmpl) * xp->xfrm_nr);
 	len += NLMSG_SPACE(sizeof(struct xfrm_user_acquire));
 	len += RTA_SPACE(xfrm_user_sec_ctx_size(xp));
+#ifdef CONFIG_XFRM_SUB_POLICY
+	len += RTA_SPACE(sizeof(struct xfrm_userpolicy_type));
+#endif
 	skb = alloc_skb(len, GFP_ATOMIC);
 	if (skb == NULL)
 		return -ENOMEM;
@@ -2034,6 +2037,9 @@ static int xfrm_exp_policy_notify(struct
 	len = RTA_SPACE(sizeof(struct xfrm_user_tmpl) * xp->xfrm_nr);
 	len += NLMSG_SPACE(sizeof(struct xfrm_user_polexpire));
 	len += RTA_SPACE(xfrm_user_sec_ctx_size(xp));
+#ifdef CONFIG_XFRM_SUB_POLICY
+	len += RTA_SPACE(sizeof(struct xfrm_userpolicy_type));
+#endif
 	skb = alloc_skb(len, GFP_ATOMIC);
 	if (skb == NULL)
 		return -ENOMEM;
@@ -2109,10 +2115,12 @@ static int xfrm_notify_policy_flush(stru
 	struct nlmsghdr *nlh;
 	struct sk_buff *skb;
 	unsigned char *b;
+	int len = 0;
 #ifdef CONFIG_XFRM_SUB_POLICY
 	struct xfrm_userpolicy_type upt;
+	len += RTA_SPACE(sizeof(struct xfrm_userpolicy_type));
 #endif
-	int len = NLMSG_LENGTH(0);
+	len += NLMSG_LENGTH(0);
 
 	skb = alloc_skb(len, GFP_ATOMIC);
 	if (skb == NULL)

--=-73Ao42onm+pQArdHfk1n--

