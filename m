From: =?UTF-8?q?Micha=C5=82=20Miros=C5=82aw?= <mirq-linux@rere.qmqm.pl>
Subject: [PATCH 03/10] net: vlan: remove reduntant check in ndo_fix_features
 callback
Date: Thu, 14 Jul 2011 02:10:29 +0200 (CEST)
Message-ID: <909c4963df5c6dfa289e84f0133dddd5bd95b194.1310601401.git.mirq-linux@rere.qmqm.pl>
References: <cover.1310601401.git.mirq-linux@rere.qmqm.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Patrick McHardy <kaber@trash.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rere.qmqm.pl ([89.167.52.164]:59816 "EHLO rere.qmqm.pl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752617Ab1GNAKb (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 13 Jul 2011 20:10:31 -0400
In-Reply-To: <cover.1310601401.git.mirq-linux@rere.qmqm.pl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Use the fact that ORing with zero is a no-op.

Signed-off-by: Micha=C5=82 Miros=C5=82aw <mirq-linux@rere.qmqm.pl>
---
 net/8021q/vlan_dev.c |    5 ++---
 1 files changed, 2 insertions(+), 3 deletions(-)

diff --git a/net/8021q/vlan_dev.c b/net/8021q/vlan_dev.c
index d8f45ba..7f67f2e 100644
--- a/net/8021q/vlan_dev.c
+++ b/net/8021q/vlan_dev.c
@@ -593,8 +593,7 @@ static u32 vlan_dev_fix_features(struct net_device =
*dev, u32 features)
 	features &=3D real_dev->features;
 	features &=3D real_dev->vlan_features;
=20
-	if (old_features & NETIF_F_SOFT_FEATURES)
-		features |=3D old_features & NETIF_F_SOFT_FEATURES;
+	features |=3D old_features & NETIF_F_SOFT_FEATURES;
=20
 	if (dev_ethtool_get_rx_csum(real_dev))
 		features |=3D NETIF_F_RXCSUM;
--=20
1.7.5.4

