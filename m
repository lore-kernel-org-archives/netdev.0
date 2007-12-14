From: Joe Perches <joe-6d6DIl74uiNBDgjK7y7TUQ@public.gmane.org>
Subject: [PATCH 11/11] drivers/net/usb/catc.c: Use print_mac
Date: Fri, 14 Dec 2007 14:34:12 -0800
Message-ID: <1197671652-32492-11-git-send-email-joe@perches.com>
References: <1197671652-32492-1-git-send-email-joe@perches.com>
 <1197671652-32492-2-git-send-email-joe@perches.com>
 <1197671652-32492-3-git-send-email-joe@perches.com>
 <1197671652-32492-4-git-send-email-joe@perches.com>
 <1197671652-32492-5-git-send-email-joe@perches.com>
 <1197671652-32492-6-git-send-email-joe@perches.com>
 <1197671652-32492-7-git-send-email-joe@perches.com>
 <1197671652-32492-8-git-send-email-joe@perches.com>
 <1197671652-32492-9-git-send-email-joe@perches.com>
 <1197671652-32492-10-git-send-email-joe@perches.com>
Cc: Greg Kroah-Hartman <gregkh-l3A5Bk7waGM@public.gmane.org>,
	Jeff Garzik <jgarzik-e+AXbWqSrlAAvxtiuMwx3w@public.gmane.org>, linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1197671652-32492-10-git-send-email-joe-6d6DIl74uiNBDgjK7y7TUQ@public.gmane.org>
Message-Id: <b41dd7dec52cd03cc97893325bfef6a57639a61a.1197671367.git.joe-6d6DIl74uiNBDgjK7y7TUQ@public.gmane.org>
In-Reply-To: <9fc484fc034428ab68ecb2711c8456df9e98d56d.1197671367.git.joe-6d6DIl74uiNBDgjK7y7TUQ@public.gmane.org>
References: <9fc484fc034428ab68ecb2711c8456df9e98d56d.1197671367.git.joe-6d6DIl74uiNBDgjK7y7TUQ@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org


Signed-off-by: Joe Perches <joe-6d6DIl74uiNBDgjK7y7TUQ@public.gmane.org>
---
 drivers/net/usb/catc.c |    8 ++++----
 1 files changed, 4 insertions(+), 4 deletions(-)

diff --git a/drivers/net/usb/catc.c b/drivers/net/usb/catc.c
index 76752d8..e20db50 100644
--- a/drivers/net/usb/catc.c
+++ b/drivers/net/usb/catc.c
@@ -757,6 +757,7 @@ static int catc_probe(struct usb_interface *intf, const struct usb_device_id *id
 	struct catc *catc;
 	u8 broadcast[6];
 	int i, pktsz;
+	DECLARE_MAC_BUF(mac);
 
 	if (usb_set_interface(usbdev,
 			intf->altsetting->desc.bInterfaceNumber, 1)) {
@@ -891,11 +892,10 @@ static int catc_probe(struct usb_interface *intf, const struct usb_device_id *id
 		f5u011_rxmode(catc, catc->rxmode);
 	}
 	dbg("Init done.");
-	printk(KERN_INFO "%s: %s USB Ethernet at usb-%s-%s, ",
+	printk(KERN_INFO "%s: %s USB Ethernet at usb-%s-%s, %s\n",
 	       netdev->name, (catc->is_f5u011) ? "Belkin F5U011" : "CATC EL1210A NetMate",
-	       usbdev->bus->bus_name, usbdev->devpath);
-	for (i = 0; i < 5; i++) printk("%2.2x:", netdev->dev_addr[i]);
-	printk("%2.2x.\n", netdev->dev_addr[i]);
+	       usbdev->bus->bus_name, usbdev->devpath,
+	       print_mac(mac, netdev->dev_addr));
 	usb_set_intfdata(intf, catc);
 
 	SET_NETDEV_DEV(netdev, &intf->dev);
-- 
1.5.3.7.949.g2221a6

-
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
