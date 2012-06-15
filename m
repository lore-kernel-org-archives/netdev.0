From: Joe Perches <joe@perches.com>
Subject: [PATCH wireless-next 03/20] at76c50x-usb: Use pr_<level>
Date: Thu, 14 Jun 2012 22:53:43 -0700
Message-ID: <4146d28583e1c579daf612f9c0e338403f7a39a4.1339739416.git.joe@perches.com>
References: <cover.1339739415.git.joe@perches.com>
Cc: linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: "John W. Linville" <linville@tuxdriver.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <cover.1339739415.git.joe@perches.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Use a more current logging style.

Convert printks to pr_<level>.
Coalesce formats, align arguments.

Signed-off-by: Joe Perches <joe@perches.com>
---
 drivers/net/wireless/at76c50x-usb.c |   15 +++++++--------
 1 files changed, 7 insertions(+), 8 deletions(-)

diff --git a/drivers/net/wireless/at76c50x-usb.c b/drivers/net/wireless/at76c50x-usb.c
index efc162e..817fd7b 100644
--- a/drivers/net/wireless/at76c50x-usb.c
+++ b/drivers/net/wireless/at76c50x-usb.c
@@ -25,6 +25,8 @@
  *
  */
 
+#define pr_fmt(fmt) KBUILD_MODNAME ": " fmt
+
 #include <linux/init.h>
 #include <linux/kernel.h>
 #include <linux/sched.h>
@@ -2120,8 +2122,7 @@ static struct at76_priv *at76_alloc_new_device(struct usb_device *udev)
 
 	hw = ieee80211_alloc_hw(sizeof(struct at76_priv), &at76_ops);
 	if (!hw) {
-		printk(KERN_ERR DRIVER_NAME ": could not register"
-		       " ieee80211_hw\n");
+		pr_err("could not register ieee80211_hw\n");
 		return NULL;
 	}
 
@@ -2301,8 +2302,7 @@ static int at76_init_new_device(struct at76_priv *priv,
 
 	ret = ieee80211_register_hw(priv->hw);
 	if (ret) {
-		printk(KERN_ERR "cannot register mac80211 hw (status %d)!\n",
-		       ret);
+		pr_err("cannot register mac80211 hw (status %d)!\n", ret);
 		goto exit;
 	}
 
@@ -2493,15 +2493,14 @@ static int __init at76_mod_init(void)
 {
 	int result;
 
-	printk(KERN_INFO DRIVER_DESC " " DRIVER_VERSION " loading\n");
+	pr_info(DRIVER_DESC " " DRIVER_VERSION " loading\n");
 
 	mutex_init(&fw_mutex);
 
 	/* register this driver with the USB subsystem */
 	result = usb_register(&at76_driver);
 	if (result < 0)
-		printk(KERN_ERR DRIVER_NAME
-		       ": usb_register failed (status %d)\n", result);
+		pr_err("usb_register failed (status %d)\n", result);
 
 	led_trigger_register_simple("at76_usb-tx", &ledtrig_tx);
 	return result;
@@ -2511,7 +2510,7 @@ static void __exit at76_mod_exit(void)
 {
 	int i;
 
-	printk(KERN_INFO DRIVER_DESC " " DRIVER_VERSION " unloading\n");
+	pr_info(DRIVER_DESC " " DRIVER_VERSION " unloading\n");
 	usb_deregister(&at76_driver);
 	for (i = 0; i < ARRAY_SIZE(firmwares); i++)
 		release_firmware(firmwares[i].fw);
-- 
1.7.8.111.gad25c.dirty
