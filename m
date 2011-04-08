From: =?UTF-8?q?Micha=C5=82=20Miros=C5=82aw?= <mirq-linux@rere.qmqm.pl>
Subject: [PATCH] net: benet: convert to hw_features - fixup
Date: Fri,  8 Apr 2011 14:38:47 +0200 (CEST)
Message-ID: <20110408123847.76855138DD@rere.qmqm.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Sathya Perla <sathya.perla@emulex.com>,
	Subbu Seetharaman <subbu.seetharaman@emulex.com>,
	Ajit Khaparde <ajit.khaparde@emulex.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rere.qmqm.pl ([89.167.52.164]:40595 "EHLO rere.qmqm.pl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754858Ab1DHMis (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 8 Apr 2011 08:38:48 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46ix up after merge with NETIF_F_RXHASH implementation.

This allows to toggle NETIF_F_RXHASH and NETIF_F_HW_VLAN_TX.

Signed-off-by: Micha=C5=82 Miros=C5=82aw <mirq-linux@rere.qmqm.pl>
---
 drivers/net/benet/be_main.c |   15 +++++++--------
 1 files changed, 7 insertions(+), 8 deletions(-)

diff --git a/drivers/net/benet/be_main.c b/drivers/net/benet/be_main.c
index 58a652f..5497336 100644
--- a/drivers/net/benet/be_main.c
+++ b/drivers/net/benet/be_main.c
@@ -2629,14 +2629,13 @@ static void be_netdev_init(struct net_device *n=
etdev)
 	int i;
=20
 	netdev->hw_features |=3D NETIF_F_SG | NETIF_F_TSO | NETIF_F_TSO6 |
-		NETIF_F_IP_CSUM | NETIF_F_IPV6_CSUM | NETIF_F_RXCSUM;
-
-	netdev->features |=3D netdev->hw_features |
-		NETIF_F_HW_VLAN_RX | NETIF_F_HW_VLAN_TX |
-		NETIF_F_HW_VLAN_FILTER;
-
+		NETIF_F_IP_CSUM | NETIF_F_IPV6_CSUM | NETIF_F_RXCSUM |
+		NETIF_F_HW_VLAN_TX;
 	if (be_multi_rxq(adapter))
-		netdev->features |=3D NETIF_F_RXHASH;
+		netdev->hw_features |=3D NETIF_F_RXHASH;
+
+	netdev->features |=3D netdev->hw_features |
+		NETIF_F_HW_VLAN_RX | NETIF_F_HW_VLAN_FILTER;
=20
 	netdev->vlan_features |=3D NETIF_F_SG | NETIF_F_TSO |
 		NETIF_F_IP_CSUM | NETIF_F_IPV6_CSUM;
--=20
1.7.2.5

