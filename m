From: "=?ISO-8859-1?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: [PATCH 3/4] ipv6/ndisc: join error paths
Date: Sat,  7 Feb 2009 02:21:02 +0200
Message-ID: <1233966063-2419-3-git-send-email-ilpo.jarvinen@helsinki.fi>
References: <1233966063-2419-1-git-send-email-ilpo.jarvinen@helsinki.fi>
 <1233966063-2419-2-git-send-email-ilpo.jarvinen@helsinki.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org,
	"=?utf-8?q?Ilpo=20J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:36585 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752256AbZBGAVH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 6 Feb 2009 19:21:07 -0500
In-Reply-To: <1233966063-2419-2-git-send-email-ilpo.jarvinen@helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Ilpo J=E4rvinen <ilpo.jarvinen@helsinki.fi>
---
 net/ipv6/ndisc.c |   16 ++++++++--------
 1 files changed, 8 insertions(+), 8 deletions(-)

diff --git a/net/ipv6/ndisc.c b/net/ipv6/ndisc.c
index 3e29708..3cd83b8 100644
--- a/net/ipv6/ndisc.c
+++ b/net/ipv6/ndisc.c
@@ -1538,13 +1538,10 @@ void ndisc_send_redirect(struct sk_buff *skb, s=
truct neighbour *neigh,
 	if (rt->rt6i_flags & RTF_GATEWAY) {
 		ND_PRINTK2(KERN_WARNING
 			   "ICMPv6 Redirect: destination is not a neighbour.\n");
-		dst_release(dst);
-		return;
-	}
-	if (!xrlim_allow(dst, 1*HZ)) {
-		dst_release(dst);
-		return;
+		goto release;
 	}
+	if (!xrlim_allow(dst, 1*HZ))
+		goto release;
=20
 	if (dev->addr_len) {
 		read_lock_bh(&neigh->lock);
@@ -1570,8 +1567,7 @@ void ndisc_send_redirect(struct sk_buff *skb, str=
uct neighbour *neigh,
 		ND_PRINTK0(KERN_ERR
 			   "ICMPv6 Redirect: %s() failed to allocate an skb.\n",
 			   __func__);
-		dst_release(dst);
-		return;
+		goto release;
 	}
=20
 	skb_reserve(buff, LL_RESERVED_SPACE(dev));
@@ -1631,6 +1627,10 @@ void ndisc_send_redirect(struct sk_buff *skb, st=
ruct neighbour *neigh,
=20
 	if (likely(idev !=3D NULL))
 		in6_dev_put(idev);
+	return;
+
+release:
+	dst_release(dst);
 }
=20
 static void pndisc_redo(struct sk_buff *skb)
--=20
1.5.6.5

