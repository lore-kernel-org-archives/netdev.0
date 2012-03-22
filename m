From: Oliver Neukum <oliver-GvhC2dPhHPQdnm+yROfE0A@public.gmane.org>
Subject: [PATCH] usbnet: consider device busy at each recieved packet
Date: Thu, 22 Mar 2012 21:35:07 +0100
Message-ID: <201203222135.07331.oliver@neukum.org>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org,
	Tony Hill <tony.hill-3WKxDLwmzFNWk0Htik3J/w@public.gmane.org>
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

>From dd427382b6d3326acd6886041e8bbb432dfd4263 Mon Sep 17 00:00:00 2001
From: Oliver Neukum <oliver-GvhC2dPhHPQdnm+yROfE0A@public.gmane.org>
Date: Sat, 3 Mar 2012 18:45:07 +0100
Subject: [PATCH] usbnet: consider device busy at each recieved packet

usbnet should centrally handle busy reporting in the rx path
so subdrivers need not worry. This hurts use cases which do
rx only or predominantly.

Signed-off-by: Oliver Neukum <oneukum-l3A5Bk7waGM@public.gmane.org>
---
 drivers/net/usb/usbnet.c |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/drivers/net/usb/usbnet.c b/drivers/net/usb/usbnet.c
index fae0fbd..a51ab46 100644
--- a/drivers/net/usb/usbnet.c
+++ b/drivers/net/usb/usbnet.c
@@ -493,6 +493,7 @@ block:
 		if (netif_running (dev->net) &&
 		    !test_bit (EVENT_RX_HALT, &dev->flags)) {
 			rx_submit (dev, urb, GFP_ATOMIC);
+			usb_mark_last_busy(dev->udev);
 			return;
 		}
 		usb_free_urb (urb);
-- 
1.7.1

--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
