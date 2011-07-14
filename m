From: =?UTF-8?q?Micha=C5=82=20Miros=C5=82aw?= <mirq-linux@rere.qmqm.pl>
Subject: [PATCH 05/10] net: Disable NOCACHE_COPY by default
Date: Thu, 14 Jul 2011 02:10:29 +0200 (CEST)
Message-ID: <245234f4964a304e6b427b7f1895d2c30d38aabd.1310601401.git.mirq-linux@rere.qmqm.pl>
References: <cover.1310601401.git.mirq-linux@rere.qmqm.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Tom Herbert <therbert@google.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rere.qmqm.pl ([89.167.52.164]:59820 "EHLO rere.qmqm.pl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752758Ab1GNAKc (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 13 Jul 2011 20:10:32 -0400
In-Reply-To: <cover.1310601401.git.mirq-linux@rere.qmqm.pl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Disable NOCACHE_COPY by default as there's no reliable way to tell
in advance what device(s) will take the packet. Also, allow the
setting to be inherited by VLAN devices.

This is the last use of NETIF_F_NO_CSUM.

Signed-off-by: Micha=C5=82 Miros=C5=82aw <mirq-linux@rere.qmqm.pl>
---
 net/core/dev.c |   11 +++++------
 1 files changed, 5 insertions(+), 6 deletions(-)

diff --git a/net/core/dev.c b/net/core/dev.c
index e57be02..7b9e2f4 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -5480,13 +5480,12 @@ int register_netdevice(struct net_device *dev)
 	dev->features |=3D NETIF_F_SOFT_FEATURES;
 	dev->wanted_features =3D dev->features & dev->hw_features;
=20
-	/* Turn on no cache copy if HW is doing checksum */
+	/* Allow changing no-cache copy but disable it by default
+	 * as there's no reliable way to tell what device(s) will take
+	 * the packet. Allow the setting to be inherited to VLANs.
+	 */
 	dev->hw_features |=3D NETIF_F_NOCACHE_COPY;
-	if ((dev->features & NETIF_F_ALL_CSUM) &&
-	    !(dev->features & NETIF_F_NO_CSUM)) {
-		dev->wanted_features |=3D NETIF_F_NOCACHE_COPY;
-		dev->features |=3D NETIF_F_NOCACHE_COPY;
-	}
+	dev->vlan_features |=3D NETIF_F_NOCACHE_COPY;
=20
 	/* Make NETIF_F_HIGHDMA inheritable to VLAN devices.
 	 */
--=20
1.7.5.4

