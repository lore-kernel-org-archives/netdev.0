From: Steve Glendinning <steve.glendinning@smsc.com>
Subject: [PATCH] usbnet: allow type check of devdbg arguments in non-debug build
Date: Wed, 21 Jan 2009 15:45:07 +0000
Message-ID: <1232552707-4130-1-git-send-email-steve.glendinning@smsc.com>
Cc: David Miller <davem@davemloft.net>,
	David Brownell <david-b@pacbell.net>,
	Steve Glendinning <steve.glendinning@smsc.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from [86.54.240.114] ([86.54.240.114]:48914 "EHLO
	kensington.shawell.net" rhost-flags-FAIL-FAIL-OK-FAIL)
	by vger.kernel.org with ESMTP id S1751808AbZAUPpK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 21 Jan 2009 10:45:10 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Improve usbnet's devdbg to always type-check diagnostic arguments,
like dev_dbg (device.h).  This makes no change to the resulting size of
usbnet modules.

This patch also removes an #ifdef DEBUG directive from rndis_wlan so
it's devdbg statements are always type-checked at compile time.

Signed-off-by: Steve Glendinning <steve.glendinning@smsc.com>
Signed-off-by: David Brownell <dbrownell@users.sourceforge.net>
---
 drivers/net/wireless/rndis_wlan.c |    2 --
 include/linux/usb/usbnet.h        |    4 +++-
 2 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/drivers/net/wireless/rndis_wlan.c b/drivers/net/wireless/rndis_wlan.c
index 607ce9f..ed93ac4 100644
--- a/drivers/net/wireless/rndis_wlan.c
+++ b/drivers/net/wireless/rndis_wlan.c
@@ -1649,9 +1649,7 @@ static char *rndis_translate_scan(struct net_device *dev,
 				  char *end_buf,
 				  struct ndis_80211_bssid_ex *bssid)
 {
-#ifdef DEBUG
 	struct usbnet *usbdev = netdev_priv(dev);
-#endif
 	u8 *ie;
 	char *current_val;
 	int bssid_len, ie_len, i;
diff --git a/include/linux/usb/usbnet.h b/include/linux/usb/usbnet.h
index ba09fe8..7d38222 100644
--- a/include/linux/usb/usbnet.h
+++ b/include/linux/usb/usbnet.h
@@ -197,7 +197,9 @@ extern int usbnet_nway_reset(struct net_device *net);
 #define devdbg(usbnet, fmt, arg...) \
 	printk(KERN_DEBUG "%s: " fmt "\n" , (usbnet)->net->name , ## arg)
 #else
-#define devdbg(usbnet, fmt, arg...) do {} while(0)
+#define devdbg(usbnet, fmt, arg...) \
+	({ if (0) printk(KERN_DEBUG "%s: " fmt "\n" , (usbnet)->net->name , \
+		## arg); 0; })
 #endif
 
 #define deverr(usbnet, fmt, arg...) \
-- 
1.6.0.6

