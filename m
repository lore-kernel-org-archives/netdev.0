From: Sachin Kamat <sachin.kamat@linaro.org>
Subject: [PATCH 1/2] net: wireless: p54spi: Use module_spi_driver macro
Date: Wed, 29 May 2013 15:31:40 +0530
Message-ID: <1369821701-4867-1-git-send-email-sachin.kamat@linaro.org>
Cc: netdev@vger.kernel.org, chunkeey@googlemail.com,
	linville@tuxdriver.com, davem@davemloft.net,
	sachin.kamat@linaro.org
To: linux-wireless@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f54.google.com ([209.85.220.54]:42225 "EHLO
	mail-pa0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S965275Ab3E2KPl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 29 May 2013 06:15:41 -0400
Received: by mail-pa0-f54.google.com with SMTP id kx1so9055718pab.41
        for <netdev@vger.kernel.org>; Wed, 29 May 2013 03:15:41 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

module_spi_driver() eliminates some boiler plate and makes code
simpler.

Signed-off-by: Sachin Kamat <sachin.kamat@linaro.org>
---
 drivers/net/wireless/p54/p54spi.c |   22 +---------------------
 1 file changed, 1 insertion(+), 21 deletions(-)

diff --git a/drivers/net/wireless/p54/p54spi.c b/drivers/net/wireless/p54/p54spi.c
index 978e7eb..146e653 100644
--- a/drivers/net/wireless/p54/p54spi.c
+++ b/drivers/net/wireless/p54/p54spi.c
@@ -713,27 +713,7 @@ static struct spi_driver p54spi_driver = {
 	.remove		= p54spi_remove,
 };
 
-static int __init p54spi_init(void)
-{
-	int ret;
-
-	ret = spi_register_driver(&p54spi_driver);
-	if (ret < 0) {
-		printk(KERN_ERR "failed to register SPI driver: %d", ret);
-		goto out;
-	}
-
-out:
-	return ret;
-}
-
-static void __exit p54spi_exit(void)
-{
-	spi_unregister_driver(&p54spi_driver);
-}
-
-module_init(p54spi_init);
-module_exit(p54spi_exit);
+module_spi_driver(p54spi_driver);
 
 MODULE_LICENSE("GPL");
 MODULE_AUTHOR("Christian Lamparter <chunkeey@web.de>");
-- 
1.7.9.5
