From: "=?ISO-8859-1?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: [PATCH 03/11] ipv6/mcast: join error paths using goto
Date: Sat, 13 Dec 2008 21:21:14 +0200
Message-ID: <1229196082-4162-4-git-send-email-ilpo.jarvinen@helsinki.fi>
References: <1229196082-4162-1-git-send-email-ilpo.jarvinen@helsinki.fi>
 <1229196082-4162-2-git-send-email-ilpo.jarvinen@helsinki.fi>
 <1229196082-4162-3-git-send-email-ilpo.jarvinen@helsinki.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org,
	"=?utf-8?q?Ilpo=20J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:48073 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751328AbYLMTVY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 13 Dec 2008 14:21:24 -0500
In-Reply-To: <1229196082-4162-3-git-send-email-ilpo.jarvinen@helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Ilpo J=E4rvinen <ilpo.jarvinen@helsinki.fi>
---
 net/ipv6/mcast.c |   25 ++++++++++++++-----------
 1 files changed, 14 insertions(+), 11 deletions(-)

diff --git a/net/ipv6/mcast.c b/net/ipv6/mcast.c
index 0f38960..a51fb33 100644
--- a/net/ipv6/mcast.c
+++ b/net/ipv6/mcast.c
@@ -303,20 +303,23 @@ static struct inet6_dev *ip6_mc_find_dev(struct n=
et *net,
 		dev =3D dev_get_by_index(net, ifindex);
=20
 	if (!dev)
-		return NULL;
+		goto nodev;
 	idev =3D in6_dev_get(dev);
-	if (!idev) {
-		dev_put(dev);
-		return NULL;
-	}
+	if (!idev)
+		goto release;
 	read_lock_bh(&idev->lock);
-	if (idev->dead) {
-		read_unlock_bh(&idev->lock);
-		in6_dev_put(idev);
-		dev_put(dev);
-		return NULL;
-	}
+	if (idev->dead)
+		goto unlock_release;
+
 	return idev;
+
+unlock_release:
+	read_unlock_bh(&idev->lock);
+	in6_dev_put(idev);
+release:
+	dev_put(dev);
+nodev:
+	return NULL;
 }
=20
 void ipv6_sock_mc_close(struct sock *sk)
--=20
1.5.2.2

