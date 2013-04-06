From: Jingoo Han <jg1.han@samsung.com>
Subject: [PATCH 4/7] net: ethernet: enc28j60: use spi_get_drvdata() and
 spi_set_drvdata()
Date: Sat, 06 Apr 2013 15:36:11 +0900
Message-ID: <000f01ce3291$076ddbd0$16499370$%han@samsung.com>
References: <000c01ce3290$c44c0980$4ce41c80$%han@samsung.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, 'Jingoo Han' <jg1.han@samsung.com>
To: "'David S. Miller'" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailout3.samsung.com ([203.254.224.33]:51210 "EHLO
	mailout3.samsung.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754389Ab3DFGgN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 6 Apr 2013 02:36:13 -0400
Received: from epcpsbgr5.samsung.com
 (u145.gpu120.samsung.co.kr [203.254.230.145])
 by mailout3.samsung.com (Oracle Communications Messaging Server 7u4-24.01
 (7.0.4.24.0) 64bit (built Nov 17 2011))
 with ESMTP id <0MKT002LOMCB78C0@mailout3.samsung.com> for
 netdev@vger.kernel.org; Sat, 06 Apr 2013 15:36:12 +0900 (KST)
In-reply-to: <000c01ce3290$c44c0980$4ce41c80$%han@samsung.com>
Content-language: ko
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Use the wrapper functions for getting and setting the driver data using
spi_device instead of using dev_{get|set}_drvdata with &spi->dev, so we
can directly pass a struct spi_device.

Signed-off-by: Jingoo Han <jg1.han@samsung.com>
---
 drivers/net/ethernet/microchip/enc28j60.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/microchip/enc28j60.c b/drivers/net/ethernet/microchip/enc28j60.c
index 5d98a9f..c7b40aa 100644
--- a/drivers/net/ethernet/microchip/enc28j60.c
+++ b/drivers/net/ethernet/microchip/enc28j60.c
@@ -1566,7 +1566,7 @@ static int enc28j60_probe(struct spi_device *spi)
 	INIT_WORK(&priv->setrx_work, enc28j60_setrx_work_handler);
 	INIT_WORK(&priv->irq_work, enc28j60_irq_work_handler);
 	INIT_WORK(&priv->restart_work, enc28j60_restart_work_handler);
-	dev_set_drvdata(&spi->dev, priv);	/* spi to priv reference */
+	spi_set_drvdata(spi, priv);	/* spi to priv reference */
 	SET_NETDEV_DEV(dev, &spi->dev);
 
 	if (!enc28j60_chipset_init(dev)) {
@@ -1618,7 +1618,7 @@ error_alloc:
 
 static int enc28j60_remove(struct spi_device *spi)
 {
-	struct enc28j60_net *priv = dev_get_drvdata(&spi->dev);
+	struct enc28j60_net *priv = spi_get_drvdata(spi);
 
 	if (netif_msg_drv(priv))
 		printk(KERN_DEBUG DRV_NAME ": remove\n");
-- 
1.7.2.5
