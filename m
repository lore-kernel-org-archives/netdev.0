From: =?UTF-8?q?Micha=C5=82=20Miros=C5=82aw?= <mirq-linux@rere.qmqm.pl>
Subject: [PATCH] net: ioc3: convert to hw_features
Date: Tue, 12 Apr 2011 21:48:17 +0200 (CEST)
Message-ID: <20110412194817.3420713A65@rere.qmqm.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Ralf Baechle <ralf@linux-mips.org>, linux-mips@linux-mips.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rere.qmqm.pl ([89.167.52.164]:54846 "EHLO rere.qmqm.pl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756803Ab1DLTsS (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 12 Apr 2011 15:48:18 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Micha=C5=82 Miros=C5=82aw <mirq-linux@rere.qmqm.pl>
---
 drivers/net/ioc3-eth.c |   30 ++----------------------------
 1 files changed, 2 insertions(+), 28 deletions(-)

diff --git a/drivers/net/ioc3-eth.c b/drivers/net/ioc3-eth.c
index c8ee8d2..96c9561 100644
--- a/drivers/net/ioc3-eth.c
+++ b/drivers/net/ioc3-eth.c
@@ -90,8 +90,6 @@ struct ioc3_private {
 	u32 emcr, ehar_h, ehar_l;
 	spinlock_t ioc3_lock;
 	struct mii_if_info mii;
-	unsigned long flags;
-#define IOC3_FLAG_RX_CHECKSUMS	1
=20
 	struct pci_dev *pdev;
=20
@@ -609,7 +607,7 @@ static inline void ioc3_rx(struct net_device *dev)
 				goto next;
 			}
=20
-			if (likely(ip->flags & IOC3_FLAG_RX_CHECKSUMS))
+			if (likely(dev->features & NETIF_F_RXCSUM))
 				ioc3_tcpudp_checksum(skb,
 					w0 & ERXBUF_IPCKSUM_MASK, len);
=20
@@ -1328,6 +1326,7 @@ static int __devinit ioc3_probe(struct pci_dev *p=
dev,
 	dev->watchdog_timeo	=3D 5 * HZ;
 	dev->netdev_ops		=3D &ioc3_netdev_ops;
 	dev->ethtool_ops	=3D &ioc3_ethtool_ops;
+	dev->hw_features	=3D NETIF_F_IP_CSUM | NETIF_F_RXCSUM;
 	dev->features		=3D NETIF_F_IP_CSUM;
=20
 	sw_physid1 =3D ioc3_mdio_read(dev, ip->mii.phy_id, MII_PHYSID1);
@@ -1618,37 +1617,12 @@ static u32 ioc3_get_link(struct net_device *dev=
)
 	return rc;
 }
=20
-static u32 ioc3_get_rx_csum(struct net_device *dev)
-{
-	struct ioc3_private *ip =3D netdev_priv(dev);
-
-	return ip->flags & IOC3_FLAG_RX_CHECKSUMS;
-}
-
-static int ioc3_set_rx_csum(struct net_device *dev, u32 data)
-{
-	struct ioc3_private *ip =3D netdev_priv(dev);
-
-	spin_lock_bh(&ip->ioc3_lock);
-	if (data)
-		ip->flags |=3D IOC3_FLAG_RX_CHECKSUMS;
-	else
-		ip->flags &=3D ~IOC3_FLAG_RX_CHECKSUMS;
-	spin_unlock_bh(&ip->ioc3_lock);
-
-	return 0;
-}
-
 static const struct ethtool_ops ioc3_ethtool_ops =3D {
 	.get_drvinfo		=3D ioc3_get_drvinfo,
 	.get_settings		=3D ioc3_get_settings,
 	.set_settings		=3D ioc3_set_settings,
 	.nway_reset		=3D ioc3_nway_reset,
 	.get_link		=3D ioc3_get_link,
-	.get_rx_csum		=3D ioc3_get_rx_csum,
-	.set_rx_csum		=3D ioc3_set_rx_csum,
-	.get_tx_csum		=3D ethtool_op_get_tx_csum,
-	.set_tx_csum		=3D ethtool_op_set_tx_csum
 };
=20
 static int ioc3_ioctl(struct net_device *dev, struct ifreq *rq, int cm=
d)
--=20
1.7.2.5

