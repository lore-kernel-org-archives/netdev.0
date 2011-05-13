From: Felipe Balbi <balbi@ti.com>
Subject: [RFC/PATCH 05/13] net: wl12xx: remove the nops
Date: Sat, 14 May 2011 00:26:22 +0300
Message-ID: <1305321990-22041-6-git-send-email-balbi@ti.com>
References: <1305321990-22041-1-git-send-email-balbi@ti.com>
Cc: linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, Felipe Balbi <balbi@ti.com>
To: Luciano Coelho <coelho@ti.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1305321990-22041-1-git-send-email-balbi@ti.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Nops aren't needed. When we actually need
those calls, then we add them with meat
and barbecue sauce.

Signed-off-by: Felipe Balbi <balbi@ti.com>
---
 drivers/net/wireless/wl12xx/sdio.c |   30 ------------------------------
 1 files changed, 0 insertions(+), 30 deletions(-)

diff --git a/drivers/net/wireless/wl12xx/sdio.c b/drivers/net/wireless/wl12xx/sdio.c
index 0832b80..bb7569c 100644
--- a/drivers/net/wireless/wl12xx/sdio.c
+++ b/drivers/net/wireless/wl12xx/sdio.c
@@ -95,14 +95,6 @@ static void wl1271_sdio_enable_interrupts(struct wl1271 *wl)
 	enable_irq(wl->irq);
 }
 
-static void wl1271_sdio_reset(struct wl1271 *wl)
-{
-}
-
-static void wl1271_sdio_init(struct wl1271 *wl)
-{
-}
-
 static void wl1271_sdio_raw_read(struct wl1271 *wl, int addr, void *buf,
 				 size_t len, bool fixed)
 {
@@ -207,8 +199,6 @@ static int wl1271_sdio_set_power(struct wl1271 *wl, bool enable)
 static struct wl1271_if_operations sdio_ops = {
 	.read		= wl1271_sdio_raw_read,
 	.write		= wl1271_sdio_raw_write,
-	.reset		= wl1271_sdio_reset,
-	.init		= wl1271_sdio_init,
 	.power		= wl1271_sdio_set_power,
 	.dev		= wl1271_sdio_wl_to_dev,
 	.enable_irq	= wl1271_sdio_enable_interrupts,
@@ -316,31 +306,11 @@ static void __devexit wl1271_remove(struct sdio_func *func)
 	kfree(glue);
 }
 
-static int wl1271_suspend(struct device *dev)
-{
-	/* Tell MMC/SDIO core it's OK to power down the card
-	 * (if it isn't already), but not to remove it completely */
-	return 0;
-}
-
-static int wl1271_resume(struct device *dev)
-{
-	return 0;
-}
-
-static const struct dev_pm_ops wl1271_sdio_pm_ops = {
-	.suspend	= wl1271_suspend,
-	.resume		= wl1271_resume,
-};
-
 static struct sdio_driver wl1271_sdio_driver = {
 	.name		= "wl1271_sdio",
 	.id_table	= wl1271_devices,
 	.probe		= wl1271_probe,
 	.remove		= __devexit_p(wl1271_remove),
-	.drv = {
-		.pm = &wl1271_sdio_pm_ops,
-	},
 };
 
 static int __init wl1271_init(void)
-- 
1.7.4.1.343.ga91df
