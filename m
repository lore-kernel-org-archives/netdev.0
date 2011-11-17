From: =?UTF-8?q?Micha=C5=82=20Miros=C5=82aw?= <mirq-linux@rere.qmqm.pl>
Subject: [PATCH 1/2] net: drivers: use bool type instead of double negation
Date: Thu, 17 Nov 2011 01:05:33 +0100 (CET)
Message-ID: <2ec988cd27c6eb5162ea2e41416edcaae207bb5e.1321488025.git.mirq-linux@rere.qmqm.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "David S. Miller" <davem@davemloft.net>,
	Ben Hutchings <bhutchings@solarflare.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rere.qmqm.pl ([89.167.52.164]:35142 "EHLO rere.qmqm.pl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753962Ab1KQAFg (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 16 Nov 2011 19:05:36 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Save some punctuation by using bool type's property equivalent to
doubled negation operator.

Reported-by: Ben Hutchings <bhutchings@solarflare.com>
Signed-off-by: Micha=C5=82 Miros=C5=82aw <mirq-linux@rere.qmqm.pl>
---
 drivers/net/ethernet/jme.c                 |    4 ++--
 drivers/net/ethernet/marvell/mv643xx_eth.c |    2 +-
 drivers/net/ethernet/marvell/sky2.c        |    2 +-
 drivers/net/xen-netfront.c                 |    4 ++--
 4 files changed, 6 insertions(+), 6 deletions(-)

diff --git a/drivers/net/ethernet/jme.c b/drivers/net/ethernet/jme.c
index df3ab83..5c0b531 100644
--- a/drivers/net/ethernet/jme.c
+++ b/drivers/net/ethernet/jme.c
@@ -1883,7 +1883,7 @@ jme_fill_tx_map(struct pci_dev *pdev,
 		struct page *page,
 		u32 page_offset,
 		u32 len,
-		u8 hidma)
+		bool hidma)
 {
 	dma_addr_t dmaaddr;
=20
@@ -1917,7 +1917,7 @@ jme_map_tx_skb(struct jme_adapter *jme, struct sk=
_buff *skb, int idx)
 	struct jme_ring *txring =3D &(jme->txring[0]);
 	struct txdesc *txdesc =3D txring->desc, *ctxdesc;
 	struct jme_buffer_info *txbi =3D txring->bufinf, *ctxbi;
-	u8 hidma =3D !!(jme->dev->features & NETIF_F_HIGHDMA);
+	bool hidma =3D jme->dev->features & NETIF_F_HIGHDMA;
 	int i, nr_frags =3D skb_shinfo(skb)->nr_frags;
 	int mask =3D jme->tx_ring_mask;
 	const struct skb_frag_struct *frag;
diff --git a/drivers/net/ethernet/marvell/mv643xx_eth.c b/drivers/net/e=
thernet/marvell/mv643xx_eth.c
index 157c5c1..43e3e61 100644
--- a/drivers/net/ethernet/marvell/mv643xx_eth.c
+++ b/drivers/net/ethernet/marvell/mv643xx_eth.c
@@ -1582,7 +1582,7 @@ static int
 mv643xx_eth_set_features(struct net_device *dev, netdev_features_t fea=
tures)
 {
 	struct mv643xx_eth_private *mp =3D netdev_priv(dev);
-	int rx_csum =3D !!(features & NETIF_F_RXCSUM);
+	bool rx_csum =3D features & NETIF_F_RXCSUM;
=20
 	wrlp(mp, PORT_CONFIG, rx_csum ? 0x02000000 : 0x00000000);
=20
diff --git a/drivers/net/ethernet/marvell/sky2.c b/drivers/net/ethernet=
/marvell/sky2.c
index c79dc54..7db6e36 100644
--- a/drivers/net/ethernet/marvell/sky2.c
+++ b/drivers/net/ethernet/marvell/sky2.c
@@ -4313,7 +4313,7 @@ static int sky2_set_features(struct net_device *d=
ev, netdev_features_t features)
 	netdev_features_t changed =3D dev->features ^ features;
=20
 	if (changed & NETIF_F_RXCSUM) {
-		int on =3D !!(features & NETIF_F_RXCSUM);
+		bool on =3D features & NETIF_F_RXCSUM;
 		sky2_write32(sky2->hw, Q_ADDR(rxqaddr[sky2->port], Q_CSR),
 			     on ? BMU_ENA_RX_CHKSUM : BMU_DIS_RX_CHKSUM);
 	}
diff --git a/drivers/net/xen-netfront.c b/drivers/net/xen-netfront.c
index a6e379f..4312db8 100644
--- a/drivers/net/xen-netfront.c
+++ b/drivers/net/xen-netfront.c
@@ -201,9 +201,9 @@ static void xennet_sysfs_delif(struct net_device *n=
etdev);
 #define xennet_sysfs_delif(dev) do { } while (0)
 #endif
=20
-static int xennet_can_sg(struct net_device *dev)
+static bool xennet_can_sg(struct net_device *dev)
 {
-	return !!(dev->features & NETIF_F_SG);
+	return dev->features & NETIF_F_SG;
 }
=20
=20
--=20
1.7.7.1
