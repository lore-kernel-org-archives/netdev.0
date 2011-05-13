From: Felipe Balbi <balbi-l0cyMroinI0@public.gmane.org>
Subject: [RFC/PATCH 12/13] net: wireless: wl12xx: mark some symbols static
Date: Sat, 14 May 2011 00:26:29 +0300
Message-ID: <1305321990-22041-13-git-send-email-balbi@ti.com>
References: <1305321990-22041-1-git-send-email-balbi@ti.com>
Cc: linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Felipe Balbi <balbi-l0cyMroinI0@public.gmane.org>
To: Luciano Coelho <coelho-l0cyMroinI0@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1305321990-22041-1-git-send-email-balbi-l0cyMroinI0@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

after re-factoring a bunch of symbols are only
used inside main.c which allows us to mark
them as static.

Signed-off-by: Felipe Balbi <balbi-l0cyMroinI0@public.gmane.org>
---
 drivers/net/wireless/wl12xx/io.h   |    7 -------
 drivers/net/wireless/wl12xx/main.c |   18 ++++++------------
 2 files changed, 6 insertions(+), 19 deletions(-)

diff --git a/drivers/net/wireless/wl12xx/io.h b/drivers/net/wireless/wl12xx/io.h
index 2bb2295..34ead79 100644
--- a/drivers/net/wireless/wl12xx/io.h
+++ b/drivers/net/wireless/wl12xx/io.h
@@ -157,11 +157,4 @@ int wl1271_set_partition(struct wl1271 *wl,
 
 /* Functions from wl1271_main.c */
 
-int wl1271_register_hw(struct wl1271 *wl);
-void wl1271_unregister_hw(struct wl1271 *wl);
-int wl1271_init_ieee80211(struct wl1271 *wl);
-struct ieee80211_hw *wl1271_alloc_hw(void);
-int wl1271_free_hw(struct wl1271 *wl);
-irqreturn_t wl1271_irq(int irq, void *data);
-
 #endif
diff --git a/drivers/net/wireless/wl12xx/main.c b/drivers/net/wireless/wl12xx/main.c
index 628f7a3..d3c056d 100644
--- a/drivers/net/wireless/wl12xx/main.c
+++ b/drivers/net/wireless/wl12xx/main.c
@@ -661,7 +661,7 @@ static void wl1271_netstack_work(struct work_struct *work)
 
 #define WL1271_IRQ_MAX_LOOPS 256
 
-irqreturn_t wl1271_irq(int irq, void *cookie)
+static irqreturn_t wl1271_irq(int irq, void *cookie)
 {
 	int ret;
 	u32 intr;
@@ -776,7 +776,6 @@ out:
 
 	return IRQ_HANDLED;
 }
-EXPORT_SYMBOL_GPL(wl1271_irq);
 
 static int wl1271_fetch_firmware(struct wl1271 *wl)
 {
@@ -3265,7 +3264,7 @@ static ssize_t wl1271_sysfs_show_hw_pg_ver(struct device *dev,
 static DEVICE_ATTR(hw_pg_ver, S_IRUGO | S_IWUSR,
 		   wl1271_sysfs_show_hw_pg_ver, NULL);
 
-int wl1271_register_hw(struct wl1271 *wl)
+static int wl1271_register_hw(struct wl1271 *wl)
 {
 	int ret;
 
@@ -3302,9 +3301,8 @@ int wl1271_register_hw(struct wl1271 *wl)
 
 	return 0;
 }
-EXPORT_SYMBOL_GPL(wl1271_register_hw);
 
-void wl1271_unregister_hw(struct wl1271 *wl)
+static void wl1271_unregister_hw(struct wl1271 *wl)
 {
 	if (wl->state == WL1271_STATE_PLT)
 		__wl1271_plt_stop(wl);
@@ -3314,9 +3312,8 @@ void wl1271_unregister_hw(struct wl1271 *wl)
 	wl->mac80211_registered = false;
 
 }
-EXPORT_SYMBOL_GPL(wl1271_unregister_hw);
 
-int wl1271_init_ieee80211(struct wl1271 *wl)
+static int wl1271_init_ieee80211(struct wl1271 *wl)
 {
 	static const u32 cipher_suites[] = {
 		WLAN_CIPHER_SUITE_WEP40,
@@ -3386,11 +3383,10 @@ int wl1271_init_ieee80211(struct wl1271 *wl)
 
 	return 0;
 }
-EXPORT_SYMBOL_GPL(wl1271_init_ieee80211);
 
 #define WL1271_DEFAULT_CHANNEL 0
 
-struct ieee80211_hw *wl1271_alloc_hw(void)
+static struct ieee80211_hw *wl1271_alloc_hw(void)
 {
 	struct ieee80211_hw *hw;
 	struct platform_device *plat_dev = NULL;
@@ -3523,9 +3519,8 @@ err_hw_alloc:
 
 	return ERR_PTR(ret);
 }
-EXPORT_SYMBOL_GPL(wl1271_alloc_hw);
 
-int wl1271_free_hw(struct wl1271 *wl)
+static int wl1271_free_hw(struct wl1271 *wl)
 {
 	platform_device_unregister(wl->plat_dev);
 	free_pages((unsigned long)wl->aggr_buf,
@@ -3546,7 +3541,6 @@ int wl1271_free_hw(struct wl1271 *wl)
 
 	return 0;
 }
-EXPORT_SYMBOL_GPL(wl1271_free_hw);
 
 static irqreturn_t wl12xx_hardirq(int irq, void *_wl)
 {
-- 
1.7.4.1.343.ga91df

--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
