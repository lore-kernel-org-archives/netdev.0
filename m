From: =?UTF-8?q?Micha=C5=82=20Miros=C5=82aw?= <mirq-linux@rere.qmqm.pl>
Subject: [PATCH] net: ibm_newemac: convert to hw_features
Date: Sun, 17 Apr 2011 12:15:47 +0200 (CEST)
Message-ID: <20110417101547.C207E13A6C@rere.qmqm.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rere.qmqm.pl ([89.167.52.164]:48112 "EHLO rere.qmqm.pl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756617Ab1DQKPw (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 17 Apr 2011 06:15:52 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Side effect: allow toggling of TX offloads.

Signed-off-by: Micha=C5=82 Miros=C5=82aw <mirq-linux@rere.qmqm.pl>
---
 drivers/net/ibm_newemac/core.c |   17 ++++-------------
 1 files changed, 4 insertions(+), 13 deletions(-)

diff --git a/drivers/net/ibm_newemac/core.c b/drivers/net/ibm_newemac/c=
ore.c
index 3bb990b..079450f 100644
--- a/drivers/net/ibm_newemac/core.c
+++ b/drivers/net/ibm_newemac/core.c
@@ -2053,13 +2053,6 @@ static void emac_ethtool_get_pauseparam(struct n=
et_device *ndev,
 	mutex_unlock(&dev->link_lock);
 }
=20
-static u32 emac_ethtool_get_rx_csum(struct net_device *ndev)
-{
-	struct emac_instance *dev =3D netdev_priv(ndev);
-
-	return dev->tah_dev !=3D NULL;
-}
-
 static int emac_get_regs_len(struct emac_instance *dev)
 {
 	if (emac_has_feature(dev, EMAC_FTR_EMAC4))
@@ -2203,15 +2196,11 @@ static const struct ethtool_ops emac_ethtool_op=
s =3D {
 	.get_ringparam =3D emac_ethtool_get_ringparam,
 	.get_pauseparam =3D emac_ethtool_get_pauseparam,
=20
-	.get_rx_csum =3D emac_ethtool_get_rx_csum,
-
 	.get_strings =3D emac_ethtool_get_strings,
 	.get_sset_count =3D emac_ethtool_get_sset_count,
 	.get_ethtool_stats =3D emac_ethtool_get_ethtool_stats,
=20
 	.get_link =3D ethtool_op_get_link,
-	.get_tx_csum =3D ethtool_op_get_tx_csum,
-	.get_sg =3D ethtool_op_get_sg,
 };
=20
 static int emac_ioctl(struct net_device *ndev, struct ifreq *rq, int c=
md)
@@ -2859,8 +2848,10 @@ static int __devinit emac_probe(struct platform_=
device *ofdev)
 	if (err !=3D 0)
 		goto err_detach_tah;
=20
-	if (dev->tah_dev)
-		ndev->features |=3D NETIF_F_IP_CSUM | NETIF_F_SG;
+	if (dev->tah_dev) {
+		ndev->hw_features =3D NETIF_F_IP_CSUM | NETIF_F_SG;
+		ndev->features |=3D ndev->hw_features | NETIF_F_RXCSUM;
+	}
 	ndev->watchdog_timeo =3D 5 * HZ;
 	if (emac_phy_supports_gige(dev->phy_mode)) {
 		ndev->netdev_ops =3D &emac_gige_netdev_ops;
--=20
1.7.2.5

