From: Jingoo Han <jg1.han@samsung.com>
Subject: [PATCH 3/7] net: ethernet: ks8851: use spi_get_drvdata() and
 spi_set_drvdata()
Date: Sat, 06 Apr 2013 15:35:43 +0900
Message-ID: <000e01ce3290$f670a560$e351f020$%han@samsung.com>
References: <000c01ce3290$c44c0980$4ce41c80$%han@samsung.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, 'Jingoo Han' <jg1.han@samsung.com>
To: "'David S. Miller'" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailout1.samsung.com ([203.254.224.24]:21804 "EHLO
	mailout1.samsung.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932525Ab3DFGfo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 6 Apr 2013 02:35:44 -0400
Received: from epcpsbgr4.samsung.com
 (u144.gpu120.samsung.co.kr [203.254.230.144])
 by mailout1.samsung.com (Oracle Communications Messaging Server 7u4-24.01
 (7.0.4.24.0) 64bit (built Nov 17 2011))
 with ESMTP id <0MKT009RAMB7ZD90@mailout1.samsung.com> for
 netdev@vger.kernel.org; Sat, 06 Apr 2013 15:35:43 +0900 (KST)
In-reply-to: <000c01ce3290$c44c0980$4ce41c80$%han@samsung.com>
Content-language: ko
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Use the wrapper functions for getting and setting the driver data using
spi_device instead of using dev_{get|set}_drvdata with &spi->dev, so we
can directly pass a struct spi_device.

Signed-off-by: Jingoo Han <jg1.han@samsung.com>
---
 drivers/net/ethernet/micrel/ks8851.c |    8 ++++----
 1 files changed, 4 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/micrel/ks8851.c b/drivers/net/ethernet/micrel/ks8851.c
index 8fb4812..4a3b499 100644
--- a/drivers/net/ethernet/micrel/ks8851.c
+++ b/drivers/net/ethernet/micrel/ks8851.c
@@ -1367,7 +1367,7 @@ static int ks8851_read_selftest(struct ks8851_net *ks)
 #ifdef CONFIG_PM
 static int ks8851_suspend(struct spi_device *spi, pm_message_t state)
 {
-	struct ks8851_net *ks = dev_get_drvdata(&spi->dev);
+	struct ks8851_net *ks = spi_get_drvdata(spi);
 	struct net_device *dev = ks->netdev;
 
 	if (netif_running(dev)) {
@@ -1380,7 +1380,7 @@ static int ks8851_suspend(struct spi_device *spi, pm_message_t state)
 
 static int ks8851_resume(struct spi_device *spi)
 {
-	struct ks8851_net *ks = dev_get_drvdata(&spi->dev);
+	struct ks8851_net *ks = spi_get_drvdata(spi);
 	struct net_device *dev = ks->netdev;
 
 	if (netif_running(dev)) {
@@ -1456,7 +1456,7 @@ static int ks8851_probe(struct spi_device *spi)
 	SET_ETHTOOL_OPS(ndev, &ks8851_ethtool_ops);
 	SET_NETDEV_DEV(ndev, &spi->dev);
 
-	dev_set_drvdata(&spi->dev, ks);
+	spi_set_drvdata(spi, ks);
 
 	ndev->if_port = IF_PORT_100BASET;
 	ndev->netdev_ops = &ks8851_netdev_ops;
@@ -1516,7 +1516,7 @@ err_irq:
 
 static int ks8851_remove(struct spi_device *spi)
 {
-	struct ks8851_net *priv = dev_get_drvdata(&spi->dev);
+	struct ks8851_net *priv = spi_get_drvdata(spi);
 
 	if (netif_msg_drv(priv))
 		dev_info(&spi->dev, "remove\n");
-- 
1.7.2.5
