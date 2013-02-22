From: Ming Lei <ming.lei@canonical.com>
Subject: [PATCH 3/3] usbnet: smsc95xx: rename FEATURE_AUTOSUSPEND
Date: Fri, 22 Feb 2013 21:05:05 +0800
Message-ID: <1361538305-28418-4-git-send-email-ming.lei@canonical.com>
References: <1361538305-28418-1-git-send-email-ming.lei@canonical.com>
Cc: Oliver Neukum <oneukum@suse.de>, netdev@vger.kernel.org,
	linux-usb@vger.kernel.org, Ming Lei <ming.lei@canonical.com>,
	Steve Glendinning <steve.glendinning@shawell.net>
To: "David S. Miller" <davem@davemloft.net>,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-da0-f44.google.com ([209.85.210.44]:63549 "EHLO
	mail-da0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756489Ab3BVNGb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 22 Feb 2013 08:06:31 -0500
In-Reply-To: <1361538305-28418-1-git-send-email-ming.lei@canonical.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The name of FEATURE_AUTOSUSPEND is very misleading and the actual
meaning is remote wakeup, but a device incapable of remote wakeup
still can support USB autosuspend under some situations, so rename
it to avoid misunderstanding.

Cc: Steve Glendinning <steve.glendinning@shawell.net>
Signed-off-by: Ming Lei <ming.lei@canonical.com>
---
 drivers/net/usb/smsc95xx.c |   14 +++++++-------
 1 file changed, 7 insertions(+), 7 deletions(-)

diff --git a/drivers/net/usb/smsc95xx.c b/drivers/net/usb/smsc95xx.c
index 7fa9622..e6d2dea 100644
--- a/drivers/net/usb/smsc95xx.c
+++ b/drivers/net/usb/smsc95xx.c
@@ -53,7 +53,7 @@
 
 #define FEATURE_8_WAKEUP_FILTERS	(0x01)
 #define FEATURE_PHY_NLP_CROSSOVER	(0x02)
-#define FEATURE_AUTOSUSPEND		(0x04)
+#define FEATURE_REMOTE_WAKEUP		(0x04)
 
 #define SUSPEND_SUSPEND0		(0x01)
 #define SUSPEND_SUSPEND1		(0x02)
@@ -1146,7 +1146,7 @@ static int smsc95xx_bind(struct usbnet *dev, struct usb_interface *intf)
 	    (val == ID_REV_CHIP_ID_89530_) || (val == ID_REV_CHIP_ID_9730_))
 		pdata->features = (FEATURE_8_WAKEUP_FILTERS |
 			FEATURE_PHY_NLP_CROSSOVER |
-			FEATURE_AUTOSUSPEND);
+			FEATURE_REMOTE_WAKEUP);
 	else if (val == ID_REV_CHIP_ID_9512_)
 		pdata->features = FEATURE_8_WAKEUP_FILTERS;
 
@@ -1378,7 +1378,7 @@ static int smsc95xx_autosuspend(struct usbnet *dev, u32 link_up)
 	if (!link_up) {
 		/* link is down so enter EDPD mode, but only if device can
 		 * reliably resume from it.  This check should be redundant
-		 * as current FEATURE_AUTOSUSPEND parts also support
+		 * as current FEATURE_REMOTE_WAKEUP parts also support
 		 * FEATURE_PHY_NLP_CROSSOVER but it's included for clarity */
 		if (!(pdata->features & FEATURE_PHY_NLP_CROSSOVER)) {
 			netdev_warn(dev->net, "EDPD not supported\n");
@@ -1433,7 +1433,7 @@ static int smsc95xx_suspend(struct usb_interface *intf, pm_message_t message)
 	link_up = smsc95xx_link_ok_nopm(dev);
 
 	if (message.event == PM_EVENT_AUTO_SUSPEND &&
-	    (pdata->features & FEATURE_AUTOSUSPEND)) {
+	    (pdata->features & FEATURE_REMOTE_WAKEUP)) {
 		ret = smsc95xx_autosuspend(dev, link_up);
 		goto done;
 	}
@@ -1870,11 +1870,11 @@ static int smsc95xx_manage_power(struct usbnet *dev, int on)
 
 	dev->intf->needs_remote_wakeup = on;
 
-	if (pdata->features & FEATURE_AUTOSUSPEND)
+	if (pdata->features & FEATURE_REMOTE_WAKEUP)
 		return 0;
 
-	/* this chip revision doesn't support autosuspend */
-	netdev_info(dev->net, "hardware doesn't support USB autosuspend\n");
+	/* this chip revision isn't capable of remote wakeup */
+	netdev_info(dev->net, "hardware isn't capable of remote wakeup\n");
 
 	if (on)
 		usb_autopm_get_interface_no_resume(dev->intf);
-- 
1.7.9.5
