From: =?UTF-8?q?Micha=C5=82=20Miros=C5=82aw?= <mirq-linux@rere.qmqm.pl>
Subject: [PATCH 04/10] net: cleanup vlan_features setting in register_netdev
Date: Thu, 14 Jul 2011 02:10:29 +0200 (CEST)
Message-ID: <27c1ec41217c615f63183b53bb1d5eccff08b9f8.1310601401.git.mirq-linux@rere.qmqm.pl>
References: <cover.1310601401.git.mirq-linux@rere.qmqm.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Patrick McHardy <kaber@trash.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rere.qmqm.pl ([89.167.52.164]:59815 "EHLO rere.qmqm.pl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752347Ab1GNAKb (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 13 Jul 2011 20:10:31 -0400
In-Reply-To: <cover.1310601401.git.mirq-linux@rere.qmqm.pl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

vlan_features contains features inherited from underlying device.
NETIF_SOFT_FEATURES are not inherited but belong to the vlan device
itself (ensured in vlan_dev_fix_features()).

Signed-off-by: Micha=C5=82 Miros=C5=82aw <mirq-linux@rere.qmqm.pl>
---
 net/core/dev.c |    7 ++-----
 1 files changed, 2 insertions(+), 5 deletions(-)

diff --git a/net/core/dev.c b/net/core/dev.c
index 9ca1514..e57be02 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -5488,12 +5488,9 @@ int register_netdevice(struct net_device *dev)
 		dev->features |=3D NETIF_F_NOCACHE_COPY;
 	}
=20
-	/* Enable GSO, GRO and NETIF_F_HIGHDMA for vlans by default,
-	 * vlan_dev_fix_features() will do the features check,
-	 * so NETIF_F_HIGHDMA feature is enabled only if supported
-	 * by underlying device.
+	/* Make NETIF_F_HIGHDMA inheritable to VLAN devices.
 	 */
-	dev->vlan_features |=3D (NETIF_F_SOFT_FEATURES | NETIF_F_HIGHDMA);
+	dev->vlan_features |=3D NETIF_F_HIGHDMA;
=20
 	ret =3D call_netdevice_notifiers(NETDEV_POST_INIT, dev);
 	ret =3D notifier_to_errno(ret);
--=20
1.7.5.4

