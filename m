From: Jingoo Han <jg1.han@samsung.com>
Subject: [PATCH 30/36] net: ethernet: wiznet: remove unnecessary
 platform_set_drvdata()
Date: Tue, 07 May 2013 13:56:46 +0900
Message-ID: <002f01ce4adf$46e26e50$d4a74af0$@samsung.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Jingoo Han <jg1.han@samsung.com>,
	Wei Yongjun <yongjun_wei@trendmicro.com.cn>,
	'Mike Sinkovsky' <msink@permonline.ru>
To: "'David S. Miller'" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailout4.samsung.com ([203.254.224.34]:55116 "EHLO
	mailout4.samsung.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758721Ab3EGE4t (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 7 May 2013 00:56:49 -0400
Received: from epcpsbgr1.samsung.com
 (u141.gpu120.samsung.co.kr [203.254.230.141])
 by mailout4.samsung.com (Oracle Communications Messaging Server 7u4-24.01
 (7.0.4.24.0) 64bit (built Nov 17 2011))
 with ESMTP id <0MME00161WDGTHC0@mailout4.samsung.com> for
 netdev@vger.kernel.org; Tue, 07 May 2013 13:56:48 +0900 (KST)
Content-language: ko
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The driver core clears the driver data to NULL after device_release
or on probe failure, since commit 0998d0631001288a5974afc0b2a5f568bcdecb4d
(device-core: Ensure drvdata = NULL when no driver is bound).
Thus, it is not needed to manually clear the device driver data to NULL.

Signed-off-by: Jingoo Han <jg1.han@samsung.com>
---
 drivers/net/ethernet/wiznet/w5100.c |    2 --
 drivers/net/ethernet/wiznet/w5300.c |    2 --
 2 files changed, 0 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/wiznet/w5100.c b/drivers/net/ethernet/wiznet/w5100.c
index a518dca..30fed08 100644
--- a/drivers/net/ethernet/wiznet/w5100.c
+++ b/drivers/net/ethernet/wiznet/w5100.c
@@ -734,7 +734,6 @@ err_hw_probe:
 	unregister_netdev(ndev);
 err_register:
 	free_netdev(ndev);
-	platform_set_drvdata(pdev, NULL);
 	return err;
 }
 
@@ -750,7 +749,6 @@ static int w5100_remove(struct platform_device *pdev)
 
 	unregister_netdev(ndev);
 	free_netdev(ndev);
-	platform_set_drvdata(pdev, NULL);
 	return 0;
 }
 
diff --git a/drivers/net/ethernet/wiznet/w5300.c b/drivers/net/ethernet/wiznet/w5300.c
index 6e00e3f..e928845 100644
--- a/drivers/net/ethernet/wiznet/w5300.c
+++ b/drivers/net/ethernet/wiznet/w5300.c
@@ -646,7 +646,6 @@ err_hw_probe:
 	unregister_netdev(ndev);
 err_register:
 	free_netdev(ndev);
-	platform_set_drvdata(pdev, NULL);
 	return err;
 }
 
@@ -662,7 +661,6 @@ static int w5300_remove(struct platform_device *pdev)
 
 	unregister_netdev(ndev);
 	free_netdev(ndev);
-	platform_set_drvdata(pdev, NULL);
 	return 0;
 }
 
-- 
1.7.2.5
