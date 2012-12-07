From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH net-next 1/2] caif_usb: Check driver name before reading
 driver state in netdev notifier
Date: Fri, 7 Dec 2012 16:17:26 +0000
Message-ID: <1354897046.2707.7.camel@bwh-desktop.uk.solarflarecom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>
To: Sjur Braendeland <sjur.brandeland@stericsson.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:8564 "EHLO
	webmail.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1422667Ab2LGQR3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 7 Dec 2012 11:17:29 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In cfusbl_device_notify(), the usbnet and usbdev variables are
initialised before the driver name has been checked.  In case the
device's driver is not cdc_ncm, this may result in reading beyond the
end of the netdev private area.  Move the initialisation below the
driver name check.

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
Compile-tested only.

Ben.

 net/caif/caif_usb.c |    7 +++++--
 1 files changed, 5 insertions(+), 2 deletions(-)

diff --git a/net/caif/caif_usb.c b/net/caif/caif_usb.c
index fd7cbf5..582f80c 100644
--- a/net/caif/caif_usb.c
+++ b/net/caif/caif_usb.c
@@ -126,8 +126,8 @@ static int cfusbl_device_notify(struct notifier_block *me, unsigned long what,
 	struct net_device *dev = arg;
 	struct caif_dev_common common;
 	struct cflayer *layer, *link_support;
-	struct usbnet	*usbnet = netdev_priv(dev);
-	struct usb_device	*usbdev = usbnet->udev;
+	struct usbnet *usbnet;
+	struct usb_device *usbdev;
 	struct ethtool_drvinfo drvinfo;
 
 	/*
@@ -141,6 +141,9 @@ static int cfusbl_device_notify(struct notifier_block *me, unsigned long what,
 	if (strncmp(drvinfo.driver, "cdc_ncm", 7) != 0)
 		return 0;
 
+	usbnet = netdev_priv(dev);
+	usbdev = usbnet->udev;
+
 	pr_debug("USB CDC NCM device VID:0x%4x PID:0x%4x\n",
 		le16_to_cpu(usbdev->descriptor.idVendor),
 		le16_to_cpu(usbdev->descriptor.idProduct));
-- 
1.7.7.6



-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
