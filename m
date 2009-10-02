From: Marcel Holtmann <marcel@holtmann.org>
Subject: [PATCH 2/4] usbnet: Set device type for wlan and wwan devices
Date: Fri,  2 Oct 2009 17:15:26 +0200
Message-ID: <45ca9f6130993f8f935f98a99b83ebc7ae7c116d.1254495724.git.marcel@holtmann.org>
References: <cover.1254495724.git.marcel@holtmann.org>
 <ff8a6da2784c27455e9666469ec95d84a1e00fd4.1254495724.git.marcel@holtmann.org>
Cc: David Miller <davem@davemloft.net>,
	Johannes Berg <johannes@sipsolutions.net>,
	Greg KH <greg@kroah.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from senator.holtmann.net ([87.106.208.187]:33425 "EHLO
	mail.holtmann.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754989AbZJBPPz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 2 Oct 2009 11:15:55 -0400
In-Reply-To: <ff8a6da2784c27455e9666469ec95d84a1e00fd4.1254495724.git.marcel@holtmann.org>
In-Reply-To: <cover.1254495724.git.marcel@holtmann.org>
References: <cover.1254495724.git.marcel@holtmann.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

For usbnet devices with FLAG_WLAN and FLAG_WWAN set the proper device
type so that uevent contains the correct value. This then allows an easy
identification of the actual underlying technology of the Ethernet device.

Signed-off-by: Marcel Holtmann <marcel@holtmann.org>
---
 drivers/net/usb/usbnet.c |   14 ++++++++++++++
 1 files changed, 14 insertions(+), 0 deletions(-)

diff --git a/drivers/net/usb/usbnet.c b/drivers/net/usb/usbnet.c
index 8124cf1..378da8c 100644
--- a/drivers/net/usb/usbnet.c
+++ b/drivers/net/usb/usbnet.c
@@ -1210,6 +1210,14 @@ static const struct net_device_ops usbnet_netdev_ops = {
 
 // precondition: never called in_interrupt
 
+static struct device_type wlan_type = {
+	.name	= "wlan",
+};
+
+static struct device_type wwan_type = {
+	.name	= "wwan",
+};
+
 int
 usbnet_probe (struct usb_interface *udev, const struct usb_device_id *prod)
 {
@@ -1325,6 +1333,12 @@ usbnet_probe (struct usb_interface *udev, const struct usb_device_id *prod)
 	dev->maxpacket = usb_maxpacket (dev->udev, dev->out, 1);
 
 	SET_NETDEV_DEV(net, &udev->dev);
+
+	if ((dev->driver_info->flags & FLAG_WLAN) != 0)
+		SET_NETDEV_DEVTYPE(net, &wlan_type);
+	if ((dev->driver_info->flags & FLAG_WWAN) != 0)
+		SET_NETDEV_DEVTYPE(net, &wwan_type);
+
 	status = register_netdev (net);
 	if (status)
 		goto out3;
-- 
1.6.2.5

