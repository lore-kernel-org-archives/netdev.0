From: Ian Molton <ian.molton@codethink.co.uk>
Subject: [PATCH v3 2/7] mv643xx.c: Remove magic numbers.
Date: Tue,  7 Aug 2012 15:34:47 +0100
Message-ID: <1344350092-24050-3-git-send-email-ian.molton@codethink.co.uk>
References: <1344350092-24050-1-git-send-email-ian.molton@codethink.co.uk>
Cc: andrew@lunn.ch, thomas.petazzoni@free-electrons.com,
	ben.dooks@codethink.co.uk, arnd@arndb.de, netdev@vger.kernel.org
To: linux-arm-kernel@lists.infradead.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ducie-dc1.codethink.co.uk ([37.128.190.40]:50806 "EHLO
	ducie-dc1.codethink.co.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754767Ab2HGOfH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 7 Aug 2012 10:35:07 -0400
In-Reply-To: <1344350092-24050-1-git-send-email-ian.molton@codethink.co.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

replace magic number with RX_CSUM_WITH_HEADER.

Signed-off-by: Ian Molton <ian.molton@codethink.co.uk>
---
 drivers/net/ethernet/marvell/mv643xx_eth.c |    3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/marvell/mv643xx_eth.c b/drivers/net/ethernet/marvell/mv643xx_eth.c
index 4fbba57..92497eb 100644
--- a/drivers/net/ethernet/marvell/mv643xx_eth.c
+++ b/drivers/net/ethernet/marvell/mv643xx_eth.c
@@ -86,6 +86,7 @@ static char mv643xx_eth_driver_version[] = "1.4";
  * port #0, 0x0800 for port #1, and 0x0c00 for port #2.
  */
 #define PORT_CONFIG			0x0000
+#define  RX_CSUM_WITH_HEADER		0x02000000
 #define  UNICAST_PROMISCUOUS_MODE	0x00000001
 #define PORT_CONFIG_EXT			0x0004
 #define MAC_ADDR_LOW			0x0014
@@ -1607,7 +1608,7 @@ mv643xx_eth_set_features(struct net_device *dev, netdev_features_t features)
 	struct mv643xx_eth_private *mp = netdev_priv(dev);
 	bool rx_csum = features & NETIF_F_RXCSUM;
 
-	wrlp(mp, PORT_CONFIG, rx_csum ? 0x02000000 : 0x00000000);
+	wrlp(mp, PORT_CONFIG, rx_csum ? RX_CSUM_WITH_HEADER : 0x00000000);
 
 	return 0;
 }
-- 
1.7.9.5
