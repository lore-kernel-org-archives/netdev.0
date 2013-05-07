From: Jingoo Han <jg1.han@samsung.com>
Subject: [PATCH 04/36] net: can: ti_hecc: remove unnecessary
 platform_set_drvdata()
Date: Tue, 07 May 2013 13:17:38 +0900
Message-ID: <001401ce4ad9$cf41aeb0$6dc50c10$@samsung.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Jingoo Han <jg1.han@samsung.com>,
	Marc Kleine-Budde <mkl@pengutronix.de>
To: "'David S. Miller'" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailout2.samsung.com ([203.254.224.25]:57954 "EHLO
	mailout2.samsung.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756489Ab3EGERk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 7 May 2013 00:17:40 -0400
Received: from epcpsbgr3.samsung.com
 (u143.gpu120.samsung.co.kr [203.254.230.143])
 by mailout2.samsung.com (Oracle Communications Messaging Server 7u4-24.01
 (7.0.4.24.0) 64bit (built Nov 17 2011))
 with ESMTP id <0MME00EW6ULFZI70@mailout2.samsung.com> for
 netdev@vger.kernel.org; Tue, 07 May 2013 13:17:39 +0900 (KST)
Content-language: ko
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The driver core clears the driver data to NULL after device_release
or on probe failure, since commit 0998d0631001288a5974afc0b2a5f568bcdecb4d
(device-core: Ensure drvdata = NULL when no driver is bound).
Thus, it is not needed to manually clear the device driver data to NULL.

Signed-off-by: Jingoo Han <jg1.han@samsung.com>
---
 drivers/net/can/ti_hecc.c |    1 -
 1 files changed, 0 insertions(+), 1 deletions(-)

diff --git a/drivers/net/can/ti_hecc.c b/drivers/net/can/ti_hecc.c
index f21fc37..3a349a2 100644
--- a/drivers/net/can/ti_hecc.c
+++ b/drivers/net/can/ti_hecc.c
@@ -1001,7 +1001,6 @@ static int ti_hecc_remove(struct platform_device *pdev)
 	iounmap(priv->base);
 	release_mem_region(res->start, resource_size(res));
 	free_candev(ndev);
-	platform_set_drvdata(pdev, NULL);
 
 	return 0;
 }
-- 
1.7.2.5
