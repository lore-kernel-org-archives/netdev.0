From: Phil Sutter <phil.sutter@viprinet.com>
Subject: [PATCH] usbnet: sanitise overlong driver information strings
Date: Thu, 14 Jun 2012 13:18:42 +0200
Message-ID: <1339672722-22793-1-git-send-email-phil.sutter@viprinet.com>
Cc: davem@davemloft.net
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from zimbra.vipri.net ([89.207.250.15]:41381 "EHLO zimbra.vipri.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752826Ab2FNL1b (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 14 Jun 2012 07:27:31 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

As seen on smsc75xx, driver_info->description being longer than 32
characters messes up 'ethtool -i' output.

Signed-off-by: Phil Sutter <phil.sutter@viprinet.com>
---
 drivers/net/usb/usbnet.c |    6 +++---
 1 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/drivers/net/usb/usbnet.c b/drivers/net/usb/usbnet.c
index 9f58330..d4f7256 100644
--- a/drivers/net/usb/usbnet.c
+++ b/drivers/net/usb/usbnet.c
@@ -876,9 +876,9 @@ void usbnet_get_drvinfo (struct net_device *net, struct ethtool_drvinfo *info)
 {
 	struct usbnet *dev = netdev_priv(net);
 
-	strncpy (info->driver, dev->driver_name, sizeof info->driver);
-	strncpy (info->version, DRIVER_VERSION, sizeof info->version);
-	strncpy (info->fw_version, dev->driver_info->description,
+	strlcpy (info->driver, dev->driver_name, sizeof info->driver);
+	strlcpy (info->version, DRIVER_VERSION, sizeof info->version);
+	strlcpy (info->fw_version, dev->driver_info->description,
 		sizeof info->fw_version);
 	usb_make_path (dev->udev, info->bus_info, sizeof info->bus_info);
 }
-- 
1.7.3.4
