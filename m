From: mathieu.poirier@linaro.org
Subject: [PATCH 2/8] drivers/net: add missing __devexit_p() annotations
Date: Fri, 20 Apr 2012 14:56:10 -0600
Message-ID: <1334955376-17793-3-git-send-email-mathieu.poirier@linaro.org>
References: <1334955376-17793-1-git-send-email-mathieu.poirier@linaro.org>
Cc: arnd@arndb.de, mathieu.poirier@linaro.org
To: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f46.google.com ([209.85.160.46]:34059 "EHLO
	mail-pb0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753167Ab2DTU40 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 Apr 2012 16:56:26 -0400
Received: by mail-pb0-f46.google.com with SMTP id un15so1475811pbc.19
        for <netdev@vger.kernel.org>; Fri, 20 Apr 2012 13:56:26 -0700 (PDT)
In-Reply-To: <1334955376-17793-1-git-send-email-mathieu.poirier@linaro.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Arnd Bergmann <arnd@arndb.de>

Drivers that refer to a __devexit function in an operations
structure need to annotate that pointer with __devexit_p so
replace it with a NULL pointer when the section gets discarded.

Signed-off-by: Arnd Bergmann <arnd@arndb.de>
Signed-off-by: Mathieu Poirier <mathieu.poirier@linaro.org>
---
 drivers/net/ethernet/micrel/ks8842.c |    2 +-
 drivers/net/wireless/b43/sdio.c      |    2 +-
 drivers/net/wireless/p54/p54usb.c    |    2 +-
 3 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/micrel/ks8842.c b/drivers/net/ethernet/micrel/ks8842.c
index f84dd2d..24fb049 100644
--- a/drivers/net/ethernet/micrel/ks8842.c
+++ b/drivers/net/ethernet/micrel/ks8842.c
@@ -1262,7 +1262,7 @@ static struct platform_driver ks8842_platform_driver = {
 		.owner	= THIS_MODULE,
 	},
 	.probe		= ks8842_probe,
-	.remove		= ks8842_remove,
+	.remove		= __devexit_p(ks8842_remove),
 };
 
 module_platform_driver(ks8842_platform_driver);
diff --git a/drivers/net/wireless/b43/sdio.c b/drivers/net/wireless/b43/sdio.c
index 80b0755..a54fb2d 100644
--- a/drivers/net/wireless/b43/sdio.c
+++ b/drivers/net/wireless/b43/sdio.c
@@ -193,7 +193,7 @@ static struct sdio_driver b43_sdio_driver = {
 	.name		= "b43-sdio",
 	.id_table	= b43_sdio_ids,
 	.probe		= b43_sdio_probe,
-	.remove		= b43_sdio_remove,
+	.remove		= __devexit_p(b43_sdio_remove),
 };
 
 int b43_sdio_init(void)
diff --git a/drivers/net/wireless/p54/p54usb.c b/drivers/net/wireless/p54/p54usb.c
index f4d28c3..43b37b2 100644
--- a/drivers/net/wireless/p54/p54usb.c
+++ b/drivers/net/wireless/p54/p54usb.c
@@ -1072,7 +1072,7 @@ static struct usb_driver p54u_driver = {
 	.name	= "p54usb",
 	.id_table = p54u_table,
 	.probe = p54u_probe,
-	.disconnect = p54u_disconnect,
+	.disconnect = __devexit_p(p54u_disconnect),
 	.pre_reset = p54u_pre_reset,
 	.post_reset = p54u_post_reset,
 #ifdef CONFIG_PM
-- 
1.7.5.4
