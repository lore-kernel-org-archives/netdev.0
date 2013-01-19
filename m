From: Wei Shuai <cpuwolf@gmail.com>
Subject: [PATCH 1/2] introduce flag FLAG_NOARP for usb net devices which cannot do ARP
Date: Sat, 19 Jan 2013 19:53:18 +0800
Message-ID: <1358596401-7209-1-git-send-email-cpuwolf@gmail.com>
Cc: linux-usb@vger.kernel.org, netdev@vger.kernel.org,
	Wei Shuai <cpuwolf@gmail.com>
To: dcbw@redhat.com, davem@davemloft.net, peter@stuge.se,
	oneukum@suse.de, sshtylyov@mvista.com, gregkh@linuxfoundation.org,
	alexey.orishko@stericsson.com, bjorn@mork.no
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f46.google.com ([209.85.220.46]:65452 "EHLO
	mail-pa0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751909Ab3ASLyH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 19 Jan 2013 06:54:07 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

we do have some USB net devices, which cannot do ARP. so we can introduce a new flag 
FLAG_NOARP, then client drivers can easily handle these kind of devices


Signed-off-by: Wei Shuai <cpuwolf@gmail.com>
---
 drivers/net/usb/usbnet.c   |    4 ++++
 include/linux/usb/usbnet.h |    1 +
 2 files changed, 5 insertions(+), 0 deletions(-)

diff --git a/drivers/net/usb/usbnet.c b/drivers/net/usb/usbnet.c
index 3d4bf01..f34b2eb 100644
--- a/drivers/net/usb/usbnet.c
+++ b/drivers/net/usb/usbnet.c
@@ -1448,6 +1448,10 @@ usbnet_probe (struct usb_interface *udev, const struct usb_device_id *prod)
 		if ((dev->driver_info->flags & FLAG_WWAN) != 0)
 			strcpy(net->name, "wwan%d");
 
+		/* devices that cannot do ARP */
+		if ((dev->driver_info->flags & FLAG_NOARP) != 0)
+			net->flags |= IFF_NOARP;
+
 		/* maybe the remote can't receive an Ethernet MTU */
 		if (net->mtu > (dev->hard_mtu - net->hard_header_len))
 			net->mtu = dev->hard_mtu - net->hard_header_len;
diff --git a/include/linux/usb/usbnet.h b/include/linux/usb/usbnet.h
index bd45eb7..5de7a22 100644
--- a/include/linux/usb/usbnet.h
+++ b/include/linux/usb/usbnet.h
@@ -100,6 +100,7 @@ struct driver_info {
 #define FLAG_LINK_INTR	0x0800		/* updates link (carrier) status */
 
 #define FLAG_POINTTOPOINT 0x1000	/* possibly use "usb%d" names */
+#define FLAG_NOARP	0x2000		/* device can't do ARP */
 
 /*
  * Indicates to usbnet, that USB driver accumulates multiple IP packets.
-- 
1.7.6.5
