From: Jingoo Han <jg1.han@samsung.com>
Subject: [PATCH 20/36] net: ethernet: nuvoton: remove unnecessary
 platform_set_drvdata()
Date: Tue, 07 May 2013 13:42:27 +0900
Message-ID: <002401ce4add$46a61380$d3f23a80$@samsung.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Jingoo Han <jg1.han@samsung.com>,
	Wan ZongShun <mcuos.com@gmail.com>
To: "'David S. Miller'" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailout4.samsung.com ([203.254.224.34]:52563 "EHLO
	mailout4.samsung.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759457Ab3EGEm2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 7 May 2013 00:42:28 -0400
Received: from epcpsbgr3.samsung.com
 (u143.gpu120.samsung.co.kr [203.254.230.143])
 by mailout4.samsung.com (Oracle Communications Messaging Server 7u4-24.01
 (7.0.4.24.0) 64bit (built Nov 17 2011))
 with ESMTP id <0MME00MUIVPYLYC0@mailout4.samsung.com> for
 netdev@vger.kernel.org; Tue, 07 May 2013 13:42:27 +0900 (KST)
Content-language: ko
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The driver core clears the driver data to NULL after device_release
or on probe failure, since commit 0998d0631001288a5974afc0b2a5f568bcdecb4d
(device-core: Ensure drvdata = NULL when no driver is bound).
Thus, it is not needed to manually clear the device driver data to NULL.

Signed-off-by: Jingoo Han <jg1.han@samsung.com>
---
 drivers/net/ethernet/nuvoton/w90p910_ether.c |    2 --
 1 files changed, 0 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/nuvoton/w90p910_ether.c b/drivers/net/ethernet/nuvoton/w90p910_ether.c
index 3df8287..e88bdb1 100644
--- a/drivers/net/ethernet/nuvoton/w90p910_ether.c
+++ b/drivers/net/ethernet/nuvoton/w90p910_ether.c
@@ -1051,7 +1051,6 @@ failed_put_clk:
 	clk_put(ether->clk);
 failed_free_rxirq:
 	free_irq(ether->rxirq, pdev);
-	platform_set_drvdata(pdev, NULL);
 failed_free_txirq:
 	free_irq(ether->txirq, pdev);
 failed_free_io:
@@ -1080,7 +1079,6 @@ static int w90p910_ether_remove(struct platform_device *pdev)
 	free_irq(ether->rxirq, dev);
 
 	del_timer_sync(&ether->check_timer);
-	platform_set_drvdata(pdev, NULL);
 
 	free_netdev(dev);
 	return 0;
-- 
1.7.2.5
