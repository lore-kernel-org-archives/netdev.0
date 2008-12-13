From: "=?ISO-8859-1?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: [PATCH 05/11] xfrm: join error paths
Date: Sat, 13 Dec 2008 21:21:16 +0200
Message-ID: <1229196082-4162-6-git-send-email-ilpo.jarvinen@helsinki.fi>
References: <1229196082-4162-1-git-send-email-ilpo.jarvinen@helsinki.fi>
 <1229196082-4162-2-git-send-email-ilpo.jarvinen@helsinki.fi>
 <1229196082-4162-3-git-send-email-ilpo.jarvinen@helsinki.fi>
 <1229196082-4162-4-git-send-email-ilpo.jarvinen@helsinki.fi>
 <1229196082-4162-5-git-send-email-ilpo.jarvinen@helsinki.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org,
	"=?utf-8?q?Ilpo=20J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:49496 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751771AbYLMTVY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 13 Dec 2008 14:21:24 -0500
In-Reply-To: <1229196082-4162-5-git-send-email-ilpo.jarvinen@helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Ilpo J=E4rvinen <ilpo.jarvinen@helsinki.fi>
---
 net/xfrm/xfrm_user.c |   22 ++++++++++++----------
 1 files changed, 12 insertions(+), 10 deletions(-)

diff --git a/net/xfrm/xfrm_user.c b/net/xfrm/xfrm_user.c
index 38ffaf3..b95a2d6 100644
--- a/net/xfrm/xfrm_user.c
+++ b/net/xfrm/xfrm_user.c
@@ -1688,21 +1688,16 @@ static int xfrm_add_acquire(struct sk_buff *skb=
, struct nlmsghdr *nlh,
 	int err =3D -ENOMEM;
=20
 	if (!x)
-		return err;
+		goto nomem;
=20
 	err =3D verify_newpolicy_info(&ua->policy);
-	if (err) {
-		printk("BAD policy passed\n");
-		kfree(x);
-		return err;
-	}
+	if (err)
+		goto bad_policy;
=20
 	/*   build an XP */
 	xp =3D xfrm_policy_construct(net, &ua->policy, attrs, &err);
-	if (!xp) {
-		kfree(x);
-		return err;
-	}
+	if (!xp)
+		goto free_state;
=20
 	memcpy(&x->id, &ua->id, sizeof(ua->id));
 	memcpy(&x->props.saddr, &ua->saddr, sizeof(ua->saddr));
@@ -1727,6 +1722,13 @@ static int xfrm_add_acquire(struct sk_buff *skb,=
 struct nlmsghdr *nlh,
 	kfree(xp);
=20
 	return 0;
+
+bad_policy:
+	printk("BAD policy passed\n");
+free_state:
+	kfree(x);
+nomem:
+	return err;
 }
=20
 #ifdef CONFIG_XFRM_MIGRATE
--=20
1.5.2.2

