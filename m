From: Jingoo Han <jg1.han@samsung.com>
Subject: [PATCH 17/36] net: ethernet: marvell: remove unnecessary
 platform_set_drvdata()
Date: Tue, 07 May 2013 13:37:36 +0900
Message-ID: <002101ce4adc$9992ac30$ccb80490$@samsung.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Jingoo Han <jg1.han@samsung.com>,
	'Lennert Buytenhek' <buytenh@wantstofly.org>,
	'Thomas Petazzoni' <thomas.petazzoni@free-electrons.com>
To: "'David S. Miller'" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailout2.samsung.com ([203.254.224.25]:61461 "EHLO
	mailout2.samsung.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757281Ab3EGEhi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 7 May 2013 00:37:38 -0400
Received: from epcpsbgr3.samsung.com
 (u143.gpu120.samsung.co.kr [203.254.230.143])
 by mailout2.samsung.com (Oracle Communications Messaging Server 7u4-24.01
 (7.0.4.24.0) 64bit (built Nov 17 2011))
 with ESMTP id <0MME00JK0VIPZ850@mailout2.samsung.com> for
 netdev@vger.kernel.org; Tue, 07 May 2013 13:37:37 +0900 (KST)
Content-language: ko
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The driver core clears the driver data to NULL after device_release
or on probe failure, since commit 0998d0631001288a5974afc0b2a5f568bcdecb4d
(device-core: Ensure drvdata = NULL when no driver is bound).
Thus, it is not needed to manually clear the device driver data to NULL.

Signed-off-by: Jingoo Han <jg1.han@samsung.com>
---
 drivers/net/ethernet/marvell/mv643xx_eth.c |    2 --
 drivers/net/ethernet/marvell/mvneta.c      |    2 --
 drivers/net/ethernet/marvell/pxa168_eth.c  |    1 -
 3 files changed, 0 insertions(+), 5 deletions(-)

diff --git a/drivers/net/ethernet/marvell/mv643xx_eth.c b/drivers/net/ethernet/marvell/mv643xx_eth.c
index d0afeea..eaa8c33 100644
--- a/drivers/net/ethernet/marvell/mv643xx_eth.c
+++ b/drivers/net/ethernet/marvell/mv643xx_eth.c
@@ -2813,8 +2813,6 @@ static int mv643xx_eth_remove(struct platform_device *pdev)
 
 	free_netdev(mp->dev);
 
-	platform_set_drvdata(pdev, NULL);
-
 	return 0;
 }
 
diff --git a/drivers/net/ethernet/marvell/mvneta.c b/drivers/net/ethernet/marvell/mvneta.c
index c966785..cd0ea20 100644
--- a/drivers/net/ethernet/marvell/mvneta.c
+++ b/drivers/net/ethernet/marvell/mvneta.c
@@ -2804,8 +2804,6 @@ static int mvneta_remove(struct platform_device *pdev)
 	irq_dispose_mapping(dev->irq);
 	free_netdev(dev);
 
-	platform_set_drvdata(pdev, NULL);
-
 	return 0;
 }
 
diff --git a/drivers/net/ethernet/marvell/pxa168_eth.c b/drivers/net/ethernet/marvell/pxa168_eth.c
index 339bb32..2602cf7 100644
--- a/drivers/net/ethernet/marvell/pxa168_eth.c
+++ b/drivers/net/ethernet/marvell/pxa168_eth.c
@@ -1602,7 +1602,6 @@ static int pxa168_eth_remove(struct platform_device *pdev)
 	unregister_netdev(dev);
 	cancel_work_sync(&pep->tx_timeout_task);
 	free_netdev(dev);
-	platform_set_drvdata(pdev, NULL);
 	return 0;
 }
 
-- 
1.7.2.5
