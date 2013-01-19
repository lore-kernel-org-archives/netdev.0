From: Wei Shuai <cpuwolf-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: [PATCH 1/2] introduce flag FLAG_NOARP for usb net devices which cannot do ARP
Date: Sat, 19 Jan 2013 19:47:57 +0800
Message-ID: <1358596079-7126-2-git-send-email-cpuwolf@gmail.com>
References: <1358596079-7126-1-git-send-email-cpuwolf@gmail.com>
Cc: linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Wei Shuai <cpuwolf-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
To: dbbw-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org, peter-Y+HMSxxDrH8@public.gmane.org,
	oneukum-l3A5Bk7waGM@public.gmane.org, sshtylyov-Igf4POYTYCDQT0dZR+AlfA@public.gmane.org, gregkh-hQyY1W1yCW8ekmWlsbkhG0B+6BGkLq7r@public.gmane.org,
	alexey.orishko-0IS4wlFg1OjSUeElwK9/Pw@public.gmane.org, bjorn-yOkvZcmFvRU@public.gmane.org
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1358596079-7126-1-git-send-email-cpuwolf-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org


Signed-off-by: Wei Shuai <cpuwolf-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
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

--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
