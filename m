From: Pan Bian <bianpan201603@163.com>
Subject: [PATCH 1/1] rndis_wlan: add return value validation
Date: Mon, 24 Apr 2017 08:40:28 +0800
Message-ID: <1492994428-16090-1-git-send-email-bianpan201603@163.com>
Cc: linux-kernel@vger.kernel.org, Pan Bian <bianpan2016@163.com>
To: Jussi Kivilinna <jussi.kivilinna@iki.fi>,
        Kalle Valo <kvalo@codeaurora.org>,
        linux-wireless@vger.kernel.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from m12-11.163.com ([220.181.12.11]:60973 "EHLO m12-11.163.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1163769AbdDXAko (ORCPT <rfc822;netdev@vger.kernel.org>);
        Sun, 23 Apr 2017 20:40:44 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Pan Bian <bianpan2016@163.com>

Function create_singlethread_workqueue() will return a NULL pointer if
there is no enough memory, and its return value should be validated
before using. However, in function rndis_wlan_bind(), its return value
is not checked. This may cause NULL dereference bugs. This patch fixes
it.

Signed-off-by: Pan Bian <bianpan2016@163.com>
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
