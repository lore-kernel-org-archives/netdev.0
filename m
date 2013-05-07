From: Jingoo Han <jg1.han@samsung.com>
Subject: [PATCH 03/36] net: can: flexcan: remove unnecessary
 platform_set_drvdata()
Date: Tue, 07 May 2013 13:15:49 +0900
Message-ID: <001301ce4ad9$8e7f2920$ab7d7b60$@samsung.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Jingoo Han <jg1.han@samsung.com>,
	'Fabio Baltieri' <fabio.baltieri@gmail.com>,
	Marc Kleine-Budde <mkl@pengutronix.de>
To: "'David S. Miller'" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailout1.samsung.com ([203.254.224.24]:33181 "EHLO
	mailout1.samsung.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759244Ab3EGEPv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 7 May 2013 00:15:51 -0400
Received: from epcpsbgr1.samsung.com
 (u141.gpu120.samsung.co.kr [203.254.230.141])
 by mailout1.samsung.com (Oracle Communications Messaging Server 7u4-24.01
 (7.0.4.24.0) 64bit (built Nov 17 2011))
 with ESMTP id <0MME00J3CUI9G9L0@mailout1.samsung.com> for
 netdev@vger.kernel.org; Tue, 07 May 2013 13:15:50 +0900 (KST)
Content-language: ko
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The driver core clears the driver data to NULL after device_release
or on probe failure, since commit 0998d0631001288a5974afc0b2a5f568bcdecb4d
(device-core: Ensure drvdata = NULL when no driver is bound).
Thus, it is not needed to manually clear the device driver data to NULL.

Signed-off-by: Jingoo Han <jg1.han@samsung.com>
---
 drivers/net/can/flexcan.c |    1 -
 1 files changed, 0 insertions(+), 1 deletions(-)

diff --git a/drivers/net/can/flexcan.c b/drivers/net/can/flexcan.c
index 769d29e..4a40a18 100644
--- a/drivers/net/can/flexcan.c
+++ b/drivers/net/can/flexcan.c
@@ -1127,7 +1127,6 @@ static int flexcan_remove(struct platform_device *pdev)
 	struct resource *mem;
 
 	unregister_flexcandev(dev);
-	platform_set_drvdata(pdev, NULL);
 	iounmap(priv->base);
 
 	mem = platform_get_resource(pdev, IORESOURCE_MEM, 0);
-- 
1.7.2.5
