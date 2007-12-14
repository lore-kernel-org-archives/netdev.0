From: Joe Perches <joe@perches.com>
Subject: [PATCH 11/11] drivers/net/usb/catc.c: Use print_mac
Date: Fri, 14 Dec 2007 14:34:12 -0800
Message-ID: <b41dd7dec52cd03cc97893325bfef6a57639a61a.1197671367.git.joe__22478.6125858829$1197671785$gmane$org@perches.com>
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
Cc: Greg Kroah-Hartman <gregkh@suse.de>,
	Jeff Garzik <jgarzik@pobox.com>, linux-usb@vger.kernel.org,
	netdev@vger.kernel.org
To: linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from DSL022.labridge.com ([206.117.136.22]:4998 "EHLO perches.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1763186AbXLNWeV (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 14 Dec 2007 17:34:21 -0500
In-Reply-To: <1197671652-32492-10-git-send-email-joe@perches.com>
Message-Id: <b41dd7dec52cd03cc97893325bfef6a57639a61a.1197671367.git.joe@perches.com>
In-Reply-To: <9fc484fc034428ab68ecb2711c8456df9e98d56d.1197671367.git.joe@perches.com>
References: <9fc484fc034428ab68ecb2711c8456df9e98d56d.1197671367.git.joe@perches.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Signed-off-by: Joe Perches <joe@perches.com>
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

