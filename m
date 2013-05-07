From: Jingoo Han <jg1.han@samsung.com>
Subject: [PATCH 18/36] net: ethernet: micrel: remove unnecessary
 platform_set_drvdata()
Date: Tue, 07 May 2013 13:40:21 +0900
Message-ID: <002201ce4adc$fb8067c0$f2813740$@samsung.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Jingoo Han <jg1.han@samsung.com>,
	Fabio Estevam <fabio.estevam@freescale.com>,
	Lars-Peter Clausen <lars@metafoo.de>,
	"'David J. Choi'" <david.choi@micrel.com>
To: "'David S. Miller'" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailout1.samsung.com ([203.254.224.24]:37233 "EHLO
	mailout1.samsung.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1760376Ab3EGEkW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 7 May 2013 00:40:22 -0400
Received: from epcpsbgr4.samsung.com
 (u144.gpu120.samsung.co.kr [203.254.230.144])
 by mailout1.samsung.com (Oracle Communications Messaging Server 7u4-24.01
 (7.0.4.24.0) 64bit (built Nov 17 2011))
 with ESMTP id <0MME00H53VN998N0@mailout1.samsung.com> for
 netdev@vger.kernel.org; Tue, 07 May 2013 13:40:21 +0900 (KST)
Content-language: ko
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The driver core clears the driver data to NULL after device_release
or on probe failure, since commit 0998d0631001288a5974afc0b2a5f568bcdecb4d
(device-core: Ensure drvdata = NULL when no driver is bound).
Thus, it is not needed to manually clear the device driver data to NULL.

Signed-off-by: Jingoo Han <jg1.han@samsung.com>
---
 drivers/net/ethernet/micrel/ks8695net.c  |    1 -
 drivers/net/ethernet/micrel/ks8842.c     |    1 -
 drivers/net/ethernet/micrel/ks8851_mll.c |    1 -
 3 files changed, 0 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/micrel/ks8695net.c b/drivers/net/ethernet/micrel/ks8695net.c
index b6c60fd..106eb97 100644
--- a/drivers/net/ethernet/micrel/ks8695net.c
+++ b/drivers/net/ethernet/micrel/ks8695net.c
@@ -1600,7 +1600,6 @@ ks8695_drv_remove(struct platform_device *pdev)
 	struct net_device *ndev = platform_get_drvdata(pdev);
 	struct ks8695_priv *ksp = netdev_priv(ndev);
 
-	platform_set_drvdata(pdev, NULL);
 	netif_napi_del(&ksp->napi);
 
 	unregister_netdev(ndev);
diff --git a/drivers/net/ethernet/micrel/ks8842.c b/drivers/net/ethernet/micrel/ks8842.c
index fbcb9e7..e393d99 100644
--- a/drivers/net/ethernet/micrel/ks8842.c
+++ b/drivers/net/ethernet/micrel/ks8842.c
@@ -1250,7 +1250,6 @@ static int ks8842_remove(struct platform_device *pdev)
 	iounmap(adapter->hw_addr);
 	free_netdev(netdev);
 	release_mem_region(iomem->start, resource_size(iomem));
-	platform_set_drvdata(pdev, NULL);
 	return 0;
 }
 
diff --git a/drivers/net/ethernet/micrel/ks8851_mll.c b/drivers/net/ethernet/micrel/ks8851_mll.c
index ddaf138ce..e9b1a83 100644
--- a/drivers/net/ethernet/micrel/ks8851_mll.c
+++ b/drivers/net/ethernet/micrel/ks8851_mll.c
@@ -1671,7 +1671,6 @@ static int ks8851_remove(struct platform_device *pdev)
 	iounmap(ks->hw_addr);
 	free_netdev(netdev);
 	release_mem_region(iomem->start, resource_size(iomem));
-	platform_set_drvdata(pdev, NULL);
 	return 0;
 
 }
-- 
1.7.2.5
