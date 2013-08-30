From: Jingoo Han <jg1.han@samsung.com>
Subject: [PATCH 04/31] net: bcm63xx_enet: use dev_get_platdata()
Date: Fri, 30 Aug 2013 13:52:21 +0900
Message-ID: <003401cea53c$b68a97c0$239fc740$%han@samsung.com>
References: <003101cea53b$9fc95b30$df5c1190$%han@samsung.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, 'Jingoo Han' <jg1.han@samsung.com>
To: "'David S. Miller'" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailout4.samsung.com ([203.254.224.34]:38434 "EHLO
	mailout4.samsung.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753752Ab3H3EwW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 30 Aug 2013 00:52:22 -0400
Received: from epcpsbgr1.samsung.com
 (u141.gpu120.samsung.co.kr [203.254.230.141])
 by mailout4.samsung.com (Oracle Communications Messaging Server 7u4-24.01
 (7.0.4.24.0) 64bit (built Nov 17 2011))
 with ESMTP id <0MSB001MNUV3QJN0@mailout4.samsung.com> for
 netdev@vger.kernel.org; Fri, 30 Aug 2013 13:52:21 +0900 (KST)
In-reply-to: <003101cea53b$9fc95b30$df5c1190$%han@samsung.com>
Content-language: ko
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Use the wrapper function for retrieving the platform data instead of
accessing dev->platform_data directly. This is a cosmetic change
to make the code simpler and enhance the readability.

Signed-off-by: Jingoo Han <jg1.han@samsung.com>
---
 drivers/net/ethernet/broadcom/bcm63xx_enet.c |    6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/bcm63xx_enet.c b/drivers/net/ethernet/broadcom/bcm63xx_enet.c
index 190219e..1985ee3 100644
--- a/drivers/net/ethernet/broadcom/bcm63xx_enet.c
+++ b/drivers/net/ethernet/broadcom/bcm63xx_enet.c
@@ -1800,7 +1800,7 @@ static int bcm_enet_probe(struct platform_device *pdev)
 	priv->rx_ring_size = BCMENET_DEF_RX_DESC;
 	priv->tx_ring_size = BCMENET_DEF_TX_DESC;
 
-	pd = pdev->dev.platform_data;
+	pd = dev_get_platdata(&pdev->dev);
 	if (pd) {
 		memcpy(dev->dev_addr, pd->mac_addr, ETH_ALEN);
 		priv->has_phy = pd->has_phy;
@@ -1964,7 +1964,7 @@ static int bcm_enet_remove(struct platform_device *pdev)
 	} else {
 		struct bcm63xx_enet_platform_data *pd;
 
-		pd = pdev->dev.platform_data;
+		pd = dev_get_platdata(&pdev->dev);
 		if (pd && pd->mii_config)
 			pd->mii_config(dev, 0, bcm_enet_mdio_read_mii,
 				       bcm_enet_mdio_write_mii);
@@ -2742,7 +2742,7 @@ static int bcm_enetsw_probe(struct platform_device *pdev)
 	priv->tx_ring_size = BCMENET_DEF_TX_DESC;
 	priv->dma_maxburst = BCMENETSW_DMA_MAXBURST;
 
-	pd = pdev->dev.platform_data;
+	pd = dev_get_platdata(&pdev->dev);
 	if (pd) {
 		memcpy(dev->dev_addr, pd->mac_addr, ETH_ALEN);
 		memcpy(priv->used_ports, pd->used_ports,
-- 
1.7.10.4
