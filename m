From: Jingoo Han <jg1.han@samsung.com>
Subject: [PATCH 09/36] net: ethernet: cadence: remove unnecessary
 platform_set_drvdata()
Date: Tue, 07 May 2013 13:23:54 +0900
Message-ID: <001901ce4ada$af3f99f0$0dbecdd0$@samsung.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Jingoo Han <jg1.han@samsung.com>,
	Nicolas Ferre <nicolas.ferre@atmel.com>
To: "'David S. Miller'" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailout1.samsung.com ([203.254.224.24]:34445 "EHLO
	mailout1.samsung.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750862Ab3EGEXz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 7 May 2013 00:23:55 -0400
Received: from epcpsbgr1.samsung.com
 (u141.gpu120.samsung.co.kr [203.254.230.141])
 by mailout1.samsung.com (Oracle Communications Messaging Server 7u4-24.01
 (7.0.4.24.0) 64bit (built Nov 17 2011))
 with ESMTP id <0MME00JECUV4G9L0@mailout1.samsung.com> for
 netdev@vger.kernel.org; Tue, 07 May 2013 13:23:54 +0900 (KST)
Content-language: ko
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The driver core clears the driver data to NULL after device_release
or on probe failure, since commit 0998d0631001288a5974afc0b2a5f568bcdecb4d
(device-core: Ensure drvdata = NULL when no driver is bound).
Thus, it is not needed to manually clear the device driver data to NULL.

Signed-off-by: Jingoo Han <jg1.han@samsung.com>
---
 drivers/net/ethernet/cadence/at91_ether.c |    1 -
 drivers/net/ethernet/cadence/macb.c       |    2 --
 2 files changed, 0 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/cadence/at91_ether.c b/drivers/net/ethernet/cadence/at91_ether.c
index cc9a185..3f19571 100644
--- a/drivers/net/ethernet/cadence/at91_ether.c
+++ b/drivers/net/ethernet/cadence/at91_ether.c
@@ -435,7 +435,6 @@ static int at91ether_remove(struct platform_device *pdev)
 	unregister_netdev(dev);
 	clk_disable(lp->pclk);
 	free_netdev(dev);
-	platform_set_drvdata(pdev, NULL);
 
 	return 0;
 }
diff --git a/drivers/net/ethernet/cadence/macb.c b/drivers/net/ethernet/cadence/macb.c
index 6be513d..6a7bf7d 100644
--- a/drivers/net/ethernet/cadence/macb.c
+++ b/drivers/net/ethernet/cadence/macb.c
@@ -1635,7 +1635,6 @@ err_out_put_pclk:
 err_out_free_dev:
 	free_netdev(dev);
 err_out:
-	platform_set_drvdata(pdev, NULL);
 	return err;
 }
 
@@ -1661,7 +1660,6 @@ static int __exit macb_remove(struct platform_device *pdev)
 		clk_disable_unprepare(bp->pclk);
 		clk_put(bp->pclk);
 		free_netdev(dev);
-		platform_set_drvdata(pdev, NULL);
 	}
 
 	return 0;
-- 
1.7.2.5
