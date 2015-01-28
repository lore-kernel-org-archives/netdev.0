From: Kevin Hao <haokexin@gmail.com>
Subject: [PATCH net-next] net: gianfar: remove the unneeded check of disabled device
Date: Wed, 28 Jan 2015 20:06:48 +0800
Message-ID: <1422446808-16460-1-git-send-email-haokexin@gmail.com>
Cc: David Miller <davem@davemloft.net>,
	Claudiu Manoil <claudiu.manoil@freescale.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yk0-f181.google.com ([209.85.160.181]:49681 "EHLO
	mail-yk0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932704AbbA1UmS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 28 Jan 2015 15:42:18 -0500
Received: by mail-yk0-f181.google.com with SMTP id 79so10009892ykr.12
        for <netdev@vger.kernel.org>; Wed, 28 Jan 2015 12:42:18 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Since commit cd1e65044d44 ("of/device: Don't register disabled
devices"), the disabled device will not be registered at all. So we
don't need to do the check again in the platform device driver.

Signed-off-by: Kevin Hao <haokexin@gmail.com>
---
 drivers/net/ethernet/freescale/gianfar.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/freescale/gianfar.c b/drivers/net/ethernet/freescale/gianfar.c
index 93ff846e96f1..43df78882e48 100644
--- a/drivers/net/ethernet/freescale/gianfar.c
+++ b/drivers/net/ethernet/freescale/gianfar.c
@@ -764,7 +764,7 @@ static int gfar_of_init(struct platform_device *ofdev, struct net_device **pdev)
 	u32 *tx_queues, *rx_queues;
 	unsigned short mode, poll_mode;
 
-	if (!np || !of_device_is_available(np))
+	if (!np)
 		return -ENODEV;
 
 	if (of_device_is_compatible(np, "fsl,etsec2")) {
-- 
1.9.3
