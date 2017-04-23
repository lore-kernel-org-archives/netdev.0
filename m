From: Pan Bian <bianpan201603-9Onoh4P/yGk@public.gmane.org>
Subject: [PATCH 1/1] cfg80211: add return value validation
Date: Sun, 23 Apr 2017 21:27:03 +0800
Message-ID: <1492954023-8596-1-git-send-email-bianpan201603@163.com>
Cc: linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Pan Bian <bianpan2016-9Onoh4P/yGk@public.gmane.org>
To: Jussi Kivilinna <jussi.kivilinna-X3B1VOXEql0@public.gmane.org>,
        Kalle Valo <kvalo-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org>,
        linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Pan Bian <bianpan2016-9Onoh4P/yGk@public.gmane.org>

Function create_singlethread_workqueue() will return a NULL pointer if
there is no enough memory, and its return value should be validated
before using. However, in function rndis_wlan_bind(), its return value
is not checked. This may cause NULL dereference bugs. This patch fixes
it.

Signed-off-by: Pan Bian <bianpan2016-9Onoh4P/yGk@public.gmane.org>
---
 drivers/net/wireless/rndis_wlan.c | 4 ++++
 1 file changed, 4 insertions(+)

diff --git a/drivers/net/wireless/rndis_wlan.c b/drivers/net/wireless/rndis_wlan.c
index 785334f..92a1bde 100644
--- a/drivers/net/wireless/rndis_wlan.c
+++ b/drivers/net/wireless/rndis_wlan.c
@@ -3427,6 +3427,10 @@ static int rndis_wlan_bind(struct usbnet *usbdev, struct usb_interface *intf)
 
 	/* because rndis_command() sleeps we need to use workqueue */
 	priv->workqueue = create_singlethread_workqueue("rndis_wlan");
+	if (!priv->workqueue) {
+		wiphy_free(wiphy);
+		return -ENOMEM;
+	}
 	INIT_WORK(&priv->work, rndis_wlan_worker);
 	INIT_DELAYED_WORK(&priv->dev_poller_work, rndis_device_poller);
 	INIT_DELAYED_WORK(&priv->scan_work, rndis_get_scan_results);
-- 
1.9.1
