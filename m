From: jamal <hadi@cyberus.ca>
Subject: [[PATCH][XFRM]: Sub-policies broke policy events
Date: Fri, 17 Nov 2006 08:34:44 -0500
Message-ID: <1163770484.5107.20.camel@jzny2>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="=-yaQ8bv2PSsiEzFZI9j9R"
Cc: netdev@vger.kernel.org, Masahide NAKAMURA <nakam@linux-ipv6.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx03.cybersurf.com ([209.197.145.106]:31689 "EHLO
	mx03.cybersurf.com") by vger.kernel.org with ESMTP id S1162424AbWKQNer
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 17 Nov 2006 08:34:47 -0500
Received: from mail.cyberus.ca ([209.197.145.21])
	by mx03.cybersurf.com with esmtp (Exim 4.30)
	id 1Gl3rl-0007L2-Vr
	for netdev@vger.kernel.org; Fri, 17 Nov 2006 08:34:49 -0500
To: David Miller <davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--=-yaQ8bv2PSsiEzFZI9j9R
Content-Type: text/plain
Content-Transfer-Encoding: 7bit


Found the cause of my problems. 
Dave, this is against Linus tree because it is bug fix.

Nakamura-san please ACK.

cheers,
jamal



--=-yaQ8bv2PSsiEzFZI9j9R
Content-Disposition: attachment; filename=ipsec-subp
Content-Type: text/plain; name=ipsec-subp; charset=UTF-8
Content-Transfer-Encoding: 7bit

[XFRM]: Sub-policies broke policy events
XFRM policy events are broken when sub-policy feature is turned on.
A simple test to verify this:
run ip xfrm mon on one window and add then delete a policy on another
window ..

Signed-off-by: Jamal Hadi Salim <hadi@cyberus.ca>

---
commit b53ec68c276ac1d879759de130620a72254cb969
tree b91ed5cf9090478bc49bd7414be6dd295352ff2b
parent 1b9bb3c14c60324b54645ffefbe6d270f9fd191c
author Jamal Hadi Salim <hadi@cyberus.ca> Fri, 17 Nov 2006 08:13:16 -0500
committer Jamal Hadi Salim <hadi@jzny2.(none)> Fri, 17 Nov 2006 08:13:16 -0500

 net/xfrm/xfrm_user.c |    3 +++
 1 files changed, 3 insertions(+), 0 deletions(-)

diff --git a/net/xfrm/xfrm_user.c b/net/xfrm/xfrm_user.c
index b43e764..2dae1c1 100644
--- a/net/xfrm/xfrm_user.c
+++ b/net/xfrm/xfrm_user.c
@@ -2060,6 +2060,9 @@ static int xfrm_notify_policy(struct xfr
 		len += RTA_SPACE(headlen);
 		headlen = sizeof(*id);
 	}
+#ifdef CONFIG_XFRM_SUB_POLICY
+	len += RTA_SPACE(sizeof(struct xfrm_userpolicy_type));
+#endif
 	len += NLMSG_SPACE(headlen);
 
 	skb = alloc_skb(len, GFP_ATOMIC);

--=-yaQ8bv2PSsiEzFZI9j9R--

