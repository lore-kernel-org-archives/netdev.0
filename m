From: Jingoo Han <jg1.han@samsung.com>
Subject: [PATCH 11/36] net: ethernet: cirrus: remove unnecessary
 platform_set_drvdata()
Date: Tue, 07 May 2013 13:26:57 +0900
Message-ID: <001b01ce4adb$1c5e04e0$551a0ea0$@samsung.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Jingoo Han <jg1.han@samsung.com>,
	'Hartley Sweeten' <hsweeten@visionengravers.com>
To: "'David S. Miller'" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailout4.samsung.com ([203.254.224.34]:49611 "EHLO
	mailout4.samsung.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932128Ab3EGE06 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 7 May 2013 00:26:58 -0400
Received: from epcpsbgr5.samsung.com
 (u145.gpu120.samsung.co.kr [203.254.230.145])
 by mailout4.samsung.com (Oracle Communications Messaging Server 7u4-24.01
 (7.0.4.24.0) 64bit (built Nov 17 2011))
 with ESMTP id <0MME006PFUYG1L70@mailout4.samsung.com> for
 netdev@vger.kernel.org; Tue, 07 May 2013 13:26:57 +0900 (KST)
Content-language: ko
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The driver core clears the driver data to NULL after device_release
or on probe failure, since commit 0998d0631001288a5974afc0b2a5f568bcdecb4d
(device-core: Ensure drvdata = NULL when no driver is bound).
Thus, it is not needed to manually clear the device driver data to NULL.

Signed-off-by: Jingoo Han <jg1.han@samsung.com>
---
 drivers/net/ethernet/cirrus/ep93xx_eth.c |    1 -
 1 files changed, 0 insertions(+), 1 deletions(-)

diff --git a/drivers/net/ethernet/cirrus/ep93xx_eth.c b/drivers/net/ethernet/cirrus/ep93xx_eth.c
index 67b0388..e3d4ec8 100644
--- a/drivers/net/ethernet/cirrus/ep93xx_eth.c
+++ b/drivers/net/ethernet/cirrus/ep93xx_eth.c
@@ -783,7 +783,6 @@ static int ep93xx_eth_remove(struct platform_device *pdev)
 	dev = platform_get_drvdata(pdev);
 	if (dev == NULL)
 		return 0;
-	platform_set_drvdata(pdev, NULL);
 
 	ep = netdev_priv(dev);
 
-- 
1.7.2.5
