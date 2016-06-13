From: Alexander Shiyan <shc_work@mail.ru>
Subject: [PATCH 1/2] net: cx89x0: Add DT support
Date: Mon, 13 Jun 2016 18:51:05 +0300
Message-ID: <1465833065-785-1-git-send-email-shc_work@mail.ru>
Cc: Alexander Shiyan <shc_work@mail.ru>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from fallback8.mail.ru ([94.100.181.110]:53832 "EHLO
	fallback8.mail.ru" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1424127AbcFMQPt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 13 Jun 2016 12:15:49 -0400
Received: from smtp35.i.mail.ru (smtp35.i.mail.ru [94.100.177.95])
	by fallback8.mail.ru (mPOP.Fallback_MX) with ESMTP id 480AD9FD11C6
	for <netdev@vger.kernel.org>; Mon, 13 Jun 2016 18:51:17 +0300 (MSK)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add DT support to the Cirrus Logic CS89x0 driver.

Signed-off-by: Alexander Shiyan <shc_work@mail.ru>
---
 drivers/net/ethernet/cirrus/cs89x0.c | 12 +++++++++++-
 1 file changed, 11 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/cirrus/cs89x0.c b/drivers/net/ethernet/cirrus/cs89x0.c
index 6038304..c363b58 100644
--- a/drivers/net/ethernet/cirrus/cs89x0.c
+++ b/drivers/net/ethernet/cirrus/cs89x0.c
@@ -53,6 +53,8 @@
 #include <linux/errno.h>
 #include <linux/netdevice.h>
 #include <linux/etherdevice.h>
+#include <linux/of.h>
+#include <linux/of_device.h>
 #include <linux/platform_device.h>
 #include <linux/kernel.h>
 #include <linux/types.h>
@@ -1895,9 +1897,17 @@ static int cs89x0_platform_remove(struct platform_device *pdev)
 	return 0;
 }
 
+static const struct __maybe_unused of_device_id cs89x0_match[] = {
+	{ .compatible = "cirrus,cs8900", },
+	{ .compatible = "cirrus,cs8920", },
+	{ },
+};
+MODULE_DEVICE_TABLE(of, cs89x0_match);
+
 static struct platform_driver cs89x0_driver = {
 	.driver	= {
-		.name	= DRV_NAME,
+		.name		= DRV_NAME,
+		.of_match_table	= of_match_ptr(cs89x0_match),
 	},
 	.remove	= cs89x0_platform_remove,
 };
-- 
2.4.9
