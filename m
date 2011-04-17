From: =?UTF-8?q?Micha=C5=82=20Miros=C5=82aw?= <mirq-linux@rere.qmqm.pl>
Subject: [PATCH] net: macvlan: convert to hw_features
Date: Sun, 17 Apr 2011 12:15:46 +0200 (CEST)
Message-ID: <20110417101546.8337A13A64@rere.qmqm.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Patrick McHardy <kaber@trash.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rere.qmqm.pl ([89.167.52.164]:48097 "EHLO rere.qmqm.pl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752395Ab1DQKPr (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 17 Apr 2011 06:15:47 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Not much of a conversion anyway - macvlan has no way to change the offl=
oad
settings independently to its base device.

Signed-off-by: Micha=C5=82 Miros=C5=82aw <mirq-linux@rere.qmqm.pl>
---
 drivers/net/macvlan.c |   16 +---------------
 1 files changed, 1 insertions(+), 15 deletions(-)

diff --git a/drivers/net/macvlan.c b/drivers/net/macvlan.c
index 78e34e9..3ad5425 100644
--- a/drivers/net/macvlan.c
+++ b/drivers/net/macvlan.c
@@ -415,7 +415,7 @@ static struct lock_class_key macvlan_netdev_addr_lo=
ck_key;
 #define MACVLAN_FEATURES \
 	(NETIF_F_SG | NETIF_F_ALL_CSUM | NETIF_F_HIGHDMA | NETIF_F_FRAGLIST |=
 \
 	 NETIF_F_GSO | NETIF_F_TSO | NETIF_F_UFO | NETIF_F_GSO_ROBUST | \
-	 NETIF_F_TSO_ECN | NETIF_F_TSO6 | NETIF_F_GRO)
+	 NETIF_F_TSO_ECN | NETIF_F_TSO6 | NETIF_F_GRO | NETIF_F_RXCSUM)
=20
 #define MACVLAN_STATE_MASK \
 	((1<<__LINK_STATE_NOCARRIER) | (1<<__LINK_STATE_DORMANT))
@@ -517,12 +517,6 @@ static void macvlan_ethtool_get_drvinfo(struct net=
_device *dev,
 	snprintf(drvinfo->version, 32, "0.1");
 }
=20
-static u32 macvlan_ethtool_get_rx_csum(struct net_device *dev)
-{
-	const struct macvlan_dev *vlan =3D netdev_priv(dev);
-	return dev_ethtool_get_rx_csum(vlan->lowerdev);
-}
-
 static int macvlan_ethtool_get_settings(struct net_device *dev,
 					struct ethtool_cmd *cmd)
 {
@@ -530,18 +524,10 @@ static int macvlan_ethtool_get_settings(struct ne=
t_device *dev,
 	return dev_ethtool_get_settings(vlan->lowerdev, cmd);
 }
=20
-static u32 macvlan_ethtool_get_flags(struct net_device *dev)
-{
-	const struct macvlan_dev *vlan =3D netdev_priv(dev);
-	return dev_ethtool_get_flags(vlan->lowerdev);
-}
-
 static const struct ethtool_ops macvlan_ethtool_ops =3D {
 	.get_link		=3D ethtool_op_get_link,
 	.get_settings		=3D macvlan_ethtool_get_settings,
-	.get_rx_csum		=3D macvlan_ethtool_get_rx_csum,
 	.get_drvinfo		=3D macvlan_ethtool_get_drvinfo,
-	.get_flags		=3D macvlan_ethtool_get_flags,
 };
=20
 static const struct net_device_ops macvlan_netdev_ops =3D {
--=20
1.7.2.5

