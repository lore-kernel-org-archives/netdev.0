From: Toby Gray <toby.gray@realvnc.com>
Subject: [PATCH 4/5] usb: usbnet: Add validation of dev->maxpacket to usbnet
Date: Wed, 15 Feb 2012 14:47:40 +0000
Message-ID: <1329317261-3406-5-git-send-email-toby.gray@realvnc.com>
References: <1329317261-3406-1-git-send-email-toby.gray@realvnc.com>
Cc: netdev@vger.kernel.org, alexey.orishko@gmail.com,
	Toby Gray <toby.gray@realvnc.com>
To: Toby Gray <tg@realvnc.com>, Oliver Neukum <oliver@neukum.name>,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	linux-usb@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from realvnc.com ([146.101.152.142]:53058 "EHLO realvnc.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1759419Ab2BOOsJ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 15 Feb 2012 09:48:09 -0500
In-Reply-To: <1329317261-3406-1-git-send-email-toby.gray@realvnc.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Several parts of usbnet rely on dev->maxpacket not being set to 0 to
prevent division by zero errors.

This adds validation of the dev->maxpacket value being non-zero before
treating the device probe as successful.

Signed-off-by: Toby Gray <toby.gray@realvnc.com>
---
 drivers/net/usb/usbnet.c |    4 ++++
 1 files changed, 4 insertions(+), 0 deletions(-)

diff --git a/drivers/net/usb/usbnet.c b/drivers/net/usb/usbnet.c
index 4ccd316..1491c90 100644
--- a/drivers/net/usb/usbnet.c
+++ b/drivers/net/usb/usbnet.c
@@ -1427,6 +1427,10 @@ usbnet_probe (struct usb_interface *udev, const struct usb_device_id *prod)
 		dev->rx_urb_size = dev->hard_mtu;
 	if (!dev->maxpacket)
 		dev->maxpacket = usb_maxpacket(dev->udev, dev->out, 1);
+	if (!dev->maxpacket) {
+		status = -ENODEV;
+		goto out3;
+	}
 
 	if ((dev->driver_info->flags & FLAG_WLAN) != 0)
 		SET_NETDEV_DEVTYPE(net, &wlan_type);
-- 
1.7.0.4
