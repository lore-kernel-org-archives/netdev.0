From: Jean-Christophe PLAGNIOL-VILLARD <plagnioj-sclMFOaUSTBWk0Htik3J/w@public.gmane.org>
Subject: [PATCH 1/1] asix: use ramdom hw addr if the one read is not valid
Date: Wed, 21 Nov 2012 11:22:42 +0100
Message-ID: <1353493362-30418-1-git-send-email-plagnioj@jcrosoft.com>
Cc: Jean-Christophe PLAGNIOL-VILLARD <plagnioj-sclMFOaUSTBWk0Htik3J/w@public.gmane.org>,
	linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Signed-off-by: Jean-Christophe PLAGNIOL-VILLARD <plagnioj-sclMFOaUSTBWk0Htik3J/w@public.gmane.org>
Cc: linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
---
 drivers/net/usb/asix_devices.c |   24 +++++++++++++++++++++---
 1 file changed, 21 insertions(+), 3 deletions(-)

diff --git a/drivers/net/usb/asix_devices.c b/drivers/net/usb/asix_devices.c
index 33ab824..7ebec5b 100644
--- a/drivers/net/usb/asix_devices.c
+++ b/drivers/net/usb/asix_devices.c
@@ -225,7 +225,13 @@ static int ax88172_bind(struct usbnet *dev, struct usb_interface *intf)
 			   ret);
 		goto out;
 	}
-	memcpy(dev->net->dev_addr, buf, ETH_ALEN);
+
+	if (is_valid_ether_addr(buf)) {
+		memcpy(dev->net->dev_addr, buf, ETH_ALEN);
+	} else {
+		netdev_info(dev->net, "invalid hw address, using random\n");
+		eth_hw_addr_random(dev->net);
+	}
 
 	/* Initialize MII structure */
 	dev->mii.dev = dev->net;
@@ -423,7 +429,13 @@ static int ax88772_bind(struct usbnet *dev, struct usb_interface *intf)
 		netdev_dbg(dev->net, "Failed to read MAC address: %d\n", ret);
 		return ret;
 	}
-	memcpy(dev->net->dev_addr, buf, ETH_ALEN);
+
+	if (is_valid_ether_addr(buf)) {
+		memcpy(dev->net->dev_addr, buf, ETH_ALEN);
+	} else {
+		netdev_info(dev->net, "invalid hw address, using random\n");
+		eth_hw_addr_random(dev->net);
+	}
 
 	/* Initialize MII structure */
 	dev->mii.dev = dev->net;
@@ -777,7 +789,13 @@ static int ax88178_bind(struct usbnet *dev, struct usb_interface *intf)
 		netdev_dbg(dev->net, "Failed to read MAC address: %d\n", ret);
 		return ret;
 	}
-	memcpy(dev->net->dev_addr, buf, ETH_ALEN);
+
+	if (is_valid_ether_addr(buf)) {
+		memcpy(dev->net->dev_addr, buf, ETH_ALEN);
+	} else {
+		netdev_info(dev->net, "invalid hw address, using random\n");
+		eth_hw_addr_random(dev->net);
+	}
 
 	/* Initialize MII structure */
 	dev->mii.dev = dev->net;
-- 
1.7.10.4

--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
