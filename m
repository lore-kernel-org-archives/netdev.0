From: jamal <hadi@cyberus.ca>
Subject: [PATCH 2/2][XFRM]: Sub-policies beautification
Date: Fri, 17 Nov 2006 09:14:15 -0500
Message-ID: <1163772855.5107.41.camel@jzny2>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="=-jQ8l1AbnW3ujbB13QUke"
Cc: Masahide NAKAMURA <nakam@linux-ipv6.org>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx03.cybersurf.com ([209.197.145.106]:10145 "EHLO
	mx03.cybersurf.com") by vger.kernel.org with ESMTP id S932905AbWKQOOR
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 17 Nov 2006 09:14:17 -0500
Received: from mail.cyberus.ca ([209.197.145.21])
	by mx03.cybersurf.com with esmtp (Exim 4.30)
	id 1Gl4U0-0003lV-Ab
	for netdev@vger.kernel.org; Fri, 17 Nov 2006 09:14:20 -0500
To: David Miller <davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--=-jQ8l1AbnW3ujbB13QUke
Content-Type: text/plain
Content-Transfer-Encoding: 7bit

Second one ..

cheers,
jamal

--=-jQ8l1AbnW3ujbB13QUke
Content-Disposition: attachment; filename=ipsec-subp32
Content-Type: text/plain; name=ipsec-subp32; charset=UTF-8
Content-Transfer-Encoding: 7bit

[XFRM]: Make flush notifier prettier when subpolicy used

Might as well make flush notifier prettier when subpolicy used

Signed-off-by: Jamal Hadi Salim <hadi@cyberus.ca>

---
commit eb52e3df145c2f8676da51a21cbe664d7794949c
tree d51daec2222f0feb1119f7c00bf9949b255a9494
parent 5e6a47d1e7baabd38cca9d01f3d78ae1319db535
author Jamal Hadi Salim <hadi@cyberus.ca> Fri, 17 Nov 2006 08:56:34 -0500
committer Jamal Hadi Salim <hadi@jzny2.(none)> Fri, 17 Nov 2006 08:56:34 -0500

 net/xfrm/xfrm_user.c |   12 ++----------
 1 files changed, 2 insertions(+), 10 deletions(-)

diff --git a/net/xfrm/xfrm_user.c b/net/xfrm/xfrm_user.c
index 3c34385..793b241 100644
--- a/net/xfrm/xfrm_user.c
+++ b/net/xfrm/xfrm_user.c
@@ -2117,7 +2117,6 @@ static int xfrm_notify_policy_flush(stru
 	unsigned char *b;
 	int len = 0;
 #ifdef CONFIG_XFRM_SUB_POLICY
-	struct xfrm_userpolicy_type upt;
 	len += RTA_SPACE(sizeof(struct xfrm_userpolicy_type));
 #endif
 	len += NLMSG_LENGTH(0);
@@ -2130,12 +2129,8 @@ #endif
 
 	nlh = NLMSG_PUT(skb, c->pid, c->seq, XFRM_MSG_FLUSHPOLICY, 0);
 	nlh->nlmsg_flags = 0;
-
-#ifdef CONFIG_XFRM_SUB_POLICY
-	memset(&upt, 0, sizeof(upt));
-	upt.type = c->data.type;
-	RTA_PUT(skb, XFRMA_POLICY_TYPE, sizeof(upt), &upt);
-#endif
+	if (copy_to_user_policy_type(c->data.type, skb) < 0)
+		goto nlmsg_failure;
 
 	nlh->nlmsg_len = skb->tail - b;
 
@@ -2143,9 +2138,6 @@ #endif
 	return netlink_broadcast(xfrm_nl, skb, 0, XFRMNLGRP_POLICY, GFP_ATOMIC);
 
 nlmsg_failure:
-#ifdef CONFIG_XFRM_SUB_POLICY
-rtattr_failure:
-#endif
 	kfree_skb(skb);
 	return -1;
 }

--=-jQ8l1AbnW3ujbB13QUke--

