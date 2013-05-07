From: Jingoo Han <jg1.han@samsung.com>
Subject: [PATCH 16/36] net: ethernet: korina: remove unnecessary
 platform_set_drvdata()
Date: Tue, 07 May 2013 13:35:07 +0900
Message-ID: <002001ce4adc$408f5980$c1ae0c80$@samsung.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Jingoo Han <jg1.han@samsung.com>
To: "'David S. Miller'" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailout1.samsung.com ([203.254.224.24]:36331 "EHLO
	mailout1.samsung.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759536Ab3EGEfJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 7 May 2013 00:35:09 -0400
Received: from epcpsbgr4.samsung.com
 (u144.gpu120.samsung.co.kr [203.254.230.144])
 by mailout1.samsung.com (Oracle Communications Messaging Server 7u4-24.01
 (7.0.4.24.0) 64bit (built Nov 17 2011))
 with ESMTP id <0MME00HVUVDZ98M0@mailout1.samsung.com> for
 netdev@vger.kernel.org; Tue, 07 May 2013 13:35:08 +0900 (KST)
Content-language: ko
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The driver core clears the driver data to NULL after device_release
or on probe failure, since commit 0998d0631001288a5974afc0b2a5f568bcdecb4d
(device-core: Ensure drvdata = NULL when no driver is bound).
Thus, it is not needed to manually clear the device driver data to NULL.

Signed-off-by: Jingoo Han <jg1.han@samsung.com>
---
 drivers/net/ethernet/korina.c |    1 -
 1 files changed, 0 insertions(+), 1 deletions(-)

diff --git a/drivers/net/ethernet/korina.c b/drivers/net/ethernet/korina.c
index 5409fe8..4a9a593 100644
--- a/drivers/net/ethernet/korina.c
+++ b/drivers/net/ethernet/korina.c
@@ -1214,7 +1214,6 @@ static int korina_remove(struct platform_device *pdev)
 	iounmap(lp->rx_dma_regs);
 	iounmap(lp->tx_dma_regs);
 
-	platform_set_drvdata(pdev, NULL);
 	unregister_netdev(bif->dev);
 	free_netdev(bif->dev);
 
-- 
1.7.2.5
