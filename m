From: "H Hartley Sweeten" <hartleys@visionengravers.com>
Subject: [PATCH] drivers/net/usb/catc.c: use %pM to shown MAC address
Date: Mon, 28 Dec 2009 18:22:13 -0500
Message-ID: <BD79186B4FD85F4B8E60E381CAEE19090200F4CB@mi8nycmail19.Mi8.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
Cc: "David Miller" <davem@davemloft.net>
To: <linux-kernel@vger.kernel.org>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exprod6og106.obsmtp.com ([64.18.1.191]:48138 "HELO
	exprod6og106.obsmtp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with SMTP id S1750988AbZL1XWK convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 28 Dec 2009 18:22:10 -0500
Content-class: urn:content-classes:message
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Use the %pM kernel extension to display the MAC address.

Signed-off-by: H Hartley Sweeten <hsweeten@visionengravers.com>
Cc: David S. Miller <davem@davemloft.net>

---

diff --git a/drivers/net/usb/catc.c b/drivers/net/usb/catc.c
index 22b87e6..7d3fa06 100644
--- a/drivers/net/usb/catc.c
+++ b/drivers/net/usb/catc.c
@@ -897,11 +897,9 @@ static int catc_probe(struct usb_interface *intf, const struct usb_device_id *id
 		f5u011_rxmode(catc, catc->rxmode);
 	}
 	dbg("Init done.");
-	printk(KERN_INFO "%s: %s USB Ethernet at usb-%s-%s, ",
+	printk(KERN_INFO "%s: %s USB Ethernet at usb-%s-%s, %pM.\n",
 	       netdev->name, (catc->is_f5u011) ? "Belkin F5U011" : "CATC EL1210A NetMate",
-	       usbdev->bus->bus_name, usbdev->devpath);
-	for (i = 0; i < 5; i++) printk("%2.2x:", netdev->dev_addr[i]);
-	printk("%2.2x.\n", netdev->dev_addr[i]);
+	       usbdev->bus->bus_name, usbdev->devpath, netdev->dev_addr);
 	usb_set_intfdata(intf, catc);
 
 	SET_NETDEV_DEV(netdev, &intf->dev); 
