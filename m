From: Bjorge Dijkstra <bjd-a1rhEgazXTw@public.gmane.org>
Subject: [PATCH 8/8] [PATCH] Use wlan device name for RNDIS wireless devices
Date: Sat, 22 Dec 2007 22:51:34 +0100
Message-ID: <11983602952006-git-send-email-bjd@jooz.net>
References: <11983602942818-git-send-email-bjd@jooz.net>
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Jussi Kivilinna <jussi.kivilinna-E01nCVcF24I@public.gmane.org>
To: dbrownell-Rn4VEauK+AKRv+LV9MX5uipxlwaOVQ5f@public.gmane.org
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <11983602942818-git-send-email-bjd-a1rhEgazXTw@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Jussi Kivilinna <jussi.kivilinna-E01nCVcF24I@public.gmane.org>

Use wlan device name for RNDIS wireless devices.

Signed-off-by: Jussi Kivilinna <jussi.kivilinna-E01nCVcF24I@public.gmane.org>
Signed-off-by: Bjorge Dijkstra <bjd-a1rhEgazXTw@public.gmane.org>
---
 drivers/net/usb/rndis_wext.c |    2 +-
 drivers/net/usb/usbnet.c     |    3 +++
 drivers/net/usb/usbnet.h     |    2 ++
 3 files changed, 6 insertions(+), 1 deletions(-)

diff --git a/drivers/net/usb/rndis_wext.c b/drivers/net/usb/rndis_wext.c
index a9ce944..1c28b2a 100644
--- a/drivers/net/usb/rndis_wext.c
+++ b/drivers/net/usb/rndis_wext.c
@@ -2166,7 +2166,7 @@ static int rndis_wext_reset(struct usbnet *dev)
 
 struct driver_info rndis_wext_info = {
 	.description =	"Wireless RNDIS device",
-	.flags =	FLAG_ETHER | FLAG_FRAMING_RN | FLAG_NO_SETINT,
+	.flags =	FLAG_WLAN | FLAG_FRAMING_RN | FLAG_NO_SETINT,
 	.bind =		rndis_wext_bind,
 	.unbind =	rndis_wext_unbind,
 	.status =	rndis_status,
diff --git a/drivers/net/usb/usbnet.c b/drivers/net/usb/usbnet.c
index 8ed1fc5..a2a2d5e 100644
--- a/drivers/net/usb/usbnet.c
+++ b/drivers/net/usb/usbnet.c
@@ -1204,6 +1204,9 @@ usbnet_probe (struct usb_interface *udev, const struct usb_device_id *prod)
 		if ((dev->driver_info->flags & FLAG_ETHER) != 0
 				&& (net->dev_addr [0] & 0x02) == 0)
 			strcpy (net->name, "eth%d");
+		/* WLAN devices should always be named "wlan%d" */
+		if ((dev->driver_info->flags & FLAG_WLAN) != 0)
+			strcpy(net->name, "wlan%d");
 
 		/* maybe the remote can't receive an Ethernet MTU */
 		if (net->mtu > (dev->hard_mtu - net->hard_header_len))
diff --git a/drivers/net/usb/usbnet.h b/drivers/net/usb/usbnet.h
index 83860a0..5c98ddc 100644
--- a/drivers/net/usb/usbnet.h
+++ b/drivers/net/usb/usbnet.h
@@ -88,6 +88,8 @@ struct driver_info {
 #define FLAG_ETHER	0x0020		/* maybe use "eth%d" names */
 
 #define FLAG_FRAMING_AX 0x0040		/* AX88772/178 packets */
+#define FLAG_WLAN	0x0080		/* use "wlan%d" names */
+
 
 	/* init device ... can sleep, or cause probe() failure */
 	int	(*bind)(struct usbnet *, struct usb_interface *);
-- 
1.5.2.5
