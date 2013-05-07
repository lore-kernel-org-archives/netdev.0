From: Jingoo Han <jg1.han@samsung.com>
Subject: [PATCH 01/36] net: can: at91_can: remove unnecessary
 platform_set_drvdata()
Date: Tue, 07 May 2013 13:11:29 +0900
Message-ID: <000901ce4ad8$f32ac1a0$d98044e0$@samsung.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, 'Jingoo Han' <jg1.han@samsung.com>,
	'Ludovic Desroches' <ludovic.desroches@atmel.com>
To: "'David S. Miller'" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailout2.samsung.com ([203.254.224.25]:56578 "EHLO
	mailout2.samsung.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756380Ab3EGELb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 7 May 2013 00:11:31 -0400
Received: from epcpsbgr3.samsung.com
 (u143.gpu120.samsung.co.kr [203.254.230.143])
 by mailout2.samsung.com (Oracle Communications Messaging Server 7u4-24.01
 (7.0.4.24.0) 64bit (built Nov 17 2011))
 with ESMTP id <0MME00F5BUB5F070@mailout2.samsung.com> for
 netdev@vger.kernel.org; Tue, 07 May 2013 13:11:29 +0900 (KST)
Content-language: ko
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The driver core clears the driver data to NULL after device_release
or on probe failure, since commit 0998d0631001288a5974afc0b2a5f568bcdecb4d
(device-core: Ensure drvdata = NULL when no driver is bound).
Thus, it is not needed to manually clear the device driver data to NULL.

Signed-off-by: Jingoo Han <jg1.han@samsung.com>
---
 drivers/net/can/at91_can.c |    2 --
 1 files changed, 0 insertions(+), 2 deletions(-)

diff --git a/drivers/net/can/at91_can.c b/drivers/net/can/at91_can.c
index db52f441..5566566 100644
--- a/drivers/net/can/at91_can.c
+++ b/drivers/net/can/at91_can.c
@@ -1393,8 +1393,6 @@ static int at91_can_remove(struct platform_device *pdev)
 
 	unregister_netdev(dev);
 
-	platform_set_drvdata(pdev, NULL);
-
 	iounmap(priv->reg_base);
 
 	res = platform_get_resource(pdev, IORESOURCE_MEM, 0);
-- 
1.7.2.5
