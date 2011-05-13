From: Felipe Balbi <balbi-l0cyMroinI0@public.gmane.org>
Subject: [RFC/PATCH 10/13] net: wl12xx: main: add platform device
Date: Sat, 14 May 2011 00:26:27 +0300
Message-ID: <1305321990-22041-11-git-send-email-balbi@ti.com>
References: <1305321990-22041-1-git-send-email-balbi@ti.com>
Cc: linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Felipe Balbi <balbi-l0cyMroinI0@public.gmane.org>
To: Luciano Coelho <coelho-l0cyMroinI0@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1305321990-22041-1-git-send-email-balbi-l0cyMroinI0@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

now that we have a platform_driver on both
glue layers, add a platform_device to the
core driver.

It's currently an empty platform_driver but
more functionality will be added on later
patches.

Signed-off-by: Felipe Balbi <balbi-l0cyMroinI0@public.gmane.org>
---
 drivers/net/wireless/wl12xx/main.c |   35 +++++++++++++++++++++++++++++++++++
 1 files changed, 35 insertions(+), 0 deletions(-)

diff --git a/drivers/net/wireless/wl12xx/main.c b/drivers/net/wireless/wl12xx/main.c
index 8b3c8d1..d377e1f 100644
--- a/drivers/net/wireless/wl12xx/main.c
+++ b/drivers/net/wireless/wl12xx/main.c
@@ -3547,6 +3547,41 @@ int wl1271_free_hw(struct wl1271 *wl)
 }
 EXPORT_SYMBOL_GPL(wl1271_free_hw);
 
+static int __devinit wl12xx_probe(struct platform_device *pdev)
+{
+	return 0;
+}
+
+static int __devexit wl12xx_remove(struct platform_device *pdev)
+{
+	return 0;
+}
+
+static const struct platform_device_id wl12xx_id_table[] __devinitconst = {
+	{ "wl12xx-sdio", 0 },
+	{ "wl12xx-spi", 0 },
+	{  }	/* Terminating Entry */
+};
+MODULE_DEVICE_TABLE(platform, wl12xx_id_table);
+
+static struct platform_driver wl12xx_driver = {
+	.probe		= wl12xx_probe,
+	.remove		= __devexit_p(wl12xx_remove),
+	.id_table	= wl12xx_id_table,
+};
+
+static int __init wl12xx_init(void)
+{
+	return platform_driver_register(&wl12xx_driver);
+}
+module_init(wl12xx_init);
+
+static void __exit wl12xx_exit(void)
+{
+	platform_driver_unregister(&wl12xx_driver);
+}
+module_exit(wl12xx_exit);
+
 u32 wl12xx_debug_level = DEBUG_NONE;
 EXPORT_SYMBOL_GPL(wl12xx_debug_level);
 module_param_named(debug_level, wl12xx_debug_level, uint, S_IRUSR | S_IWUSR);
-- 
1.7.4.1.343.ga91df

--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
