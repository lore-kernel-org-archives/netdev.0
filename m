From: Jingoo Han <jg1.han@samsung.com>
Subject: [PATCH 26/36] net: ethernet: smsc: remove unnecessary
 platform_set_drvdata()
Date: Tue, 07 May 2013 13:50:20 +0900
Message-ID: <002b01ce4ade$60b71750$222545f0$@samsung.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Jingoo Han <jg1.han@samsung.com>,
	Nicolas Pitre <nico@fluxnic.net>,
	'Steve Glendinning' <steve.glendinning@shawell.net>
To: "'David S. Miller'" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailout2.samsung.com ([203.254.224.25]:63675 "EHLO
	mailout2.samsung.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757226Ab3EGEuW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 7 May 2013 00:50:22 -0400
Received: from epcpsbgr1.samsung.com
 (u141.gpu120.samsung.co.kr [203.254.230.141])
 by mailout2.samsung.com (Oracle Communications Messaging Server 7u4-24.01
 (7.0.4.24.0) 64bit (built Nov 17 2011))
 with ESMTP id <0MME00FX8W3WF080@mailout2.samsung.com> for
 netdev@vger.kernel.org; Tue, 07 May 2013 13:50:21 +0900 (KST)
Content-language: ko
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The driver core clears the driver data to NULL after device_release
or on probe failure, since commit 0998d0631001288a5974afc0b2a5f568bcdecb4d
(device-core: Ensure drvdata = NULL when no driver is bound).
Thus, it is not needed to manually clear the device driver data to NULL.

Signed-off-by: Jingoo Han <jg1.han@samsung.com>
---
 drivers/net/ethernet/smsc/smc911x.c  |    2 --
 drivers/net/ethernet/smsc/smc91x.c   |    3 ---
 drivers/net/ethernet/smsc/smsc911x.c |    2 --
 3 files changed, 0 insertions(+), 7 deletions(-)

diff --git a/drivers/net/ethernet/smsc/smc911x.c b/drivers/net/ethernet/smsc/smc911x.c
index 9dd842d..345558f 100644
--- a/drivers/net/ethernet/smsc/smc911x.c
+++ b/drivers/net/ethernet/smsc/smc911x.c
@@ -2087,7 +2087,6 @@ static int smc911x_drv_probe(struct platform_device *pdev)
 	ndev->base_addr = res->start;
 	ret = smc911x_probe(ndev);
 	if (ret != 0) {
-		platform_set_drvdata(pdev, NULL);
 		iounmap(addr);
 release_both:
 		free_netdev(ndev);
@@ -2113,7 +2112,6 @@ static int smc911x_drv_remove(struct platform_device *pdev)
 	struct resource *res;
 
 	DBG(SMC_DEBUG_FUNC, "--> %s\n", __func__);
-	platform_set_drvdata(pdev, NULL);
 
 	unregister_netdev(ndev);
 
diff --git a/drivers/net/ethernet/smsc/smc91x.c b/drivers/net/ethernet/smsc/smc91x.c
index dfbf978..cde13be 100644
--- a/drivers/net/ethernet/smsc/smc91x.c
+++ b/drivers/net/ethernet/smsc/smc91x.c
@@ -2299,7 +2299,6 @@ static int smc_drv_probe(struct platform_device *pdev)
 	return 0;
 
  out_iounmap:
-	platform_set_drvdata(pdev, NULL);
 	iounmap(addr);
  out_release_attrib:
 	smc_release_attrib(pdev, ndev);
@@ -2319,8 +2318,6 @@ static int smc_drv_remove(struct platform_device *pdev)
 	struct smc_local *lp = netdev_priv(ndev);
 	struct resource *res;
 
-	platform_set_drvdata(pdev, NULL);
-
 	unregister_netdev(ndev);
 
 	free_irq(ndev->irq, ndev);
diff --git a/drivers/net/ethernet/smsc/smsc911x.c b/drivers/net/ethernet/smsc/smsc911x.c
index 3663b9e..a141921 100644
--- a/drivers/net/ethernet/smsc/smsc911x.c
+++ b/drivers/net/ethernet/smsc/smsc911x.c
@@ -2284,7 +2284,6 @@ static int smsc911x_drv_remove(struct platform_device *pdev)
 	mdiobus_unregister(pdata->mii_bus);
 	mdiobus_free(pdata->mii_bus);
 
-	platform_set_drvdata(pdev, NULL);
 	unregister_netdev(dev);
 	free_irq(dev->irq, dev);
 	res = platform_get_resource_byname(pdev, IORESOURCE_MEM,
@@ -2539,7 +2538,6 @@ out_disable_resources:
 out_enable_resources_fail:
 	smsc911x_free_resources(pdev);
 out_request_resources_fail:
-	platform_set_drvdata(pdev, NULL);
 	iounmap(pdata->ioaddr);
 	free_netdev(dev);
 out_release_io_1:
-- 
1.7.2.5
