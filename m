From: Alexey Klimov <klimov.linux-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: [patch review 3/3] net/usb: rtl8150.c - place dev_err instead of
 err()
Date: Sun, 11 Jan 2009 19:17:15 +0300
Message-ID: <1231690635.2050.107.camel@tux.localhost>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Greg KH <greg-U8xfFu+wG4EAvxtiuMwx3w@public.gmane.org>, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: dbrownell-Rn4VEauK+AKRv+LV9MX5uipxlwaOVQ5f@public.gmane.org, davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

---
Remove err-messages and place dev_err there.

Signed-off-by: Alexey Klimov <klimov.linux-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>

--
diff --git a/drivers/net/usb/rtl8150.c b/drivers/net/usb/rtl8150.c
index d8664bf..ae19675 100644
--- a/drivers/net/usb/rtl8150.c
+++ b/drivers/net/usb/rtl8150.c
@@ -247,7 +247,8 @@ static int async_set_registers(rtl8150_t * dev, u16 indx, u16 size)
 	if ((ret = usb_submit_urb(dev->ctrl_urb, GFP_ATOMIC))) {
 		if (ret == -ENODEV)
 			netif_device_detach(dev->netdev);
-		err("control request submission failed: %d", ret);
+		dev_err(&dev->udev->dev,
+			"control request submission failed: %d\n", ret);
 	} else
 		set_bit(RX_REG_SET, &dev->flags);
 
@@ -599,7 +600,8 @@ resubmit:
 	if (res == -ENODEV)
 		netif_device_detach(dev->netdev);
 	else if (res)
-		err ("can't resubmit intr, %s-%s/input0, status %d",
+		dev_err(&dev->udev->dev,
+			"can't resubmit intr, %s-%s/input0, status %d\n",
 				dev->udev->bus->bus_name,
 				dev->udev->devpath, res);
 }
@@ -906,7 +908,7 @@ static int rtl8150_probe(struct usb_interface *intf,
 
 	netdev = alloc_etherdev(sizeof(rtl8150_t));
 	if (!netdev) {
-		err("Out of memory");
+		dev_err(&intf->dev, "Out of memory\n");
 		return -ENOMEM;
 	}
 
@@ -936,11 +938,11 @@ static int rtl8150_probe(struct usb_interface *intf,
 	dev->intr_interval = 100;	/* 100ms */
 
 	if (!alloc_all_urbs(dev)) {
-		err("out of memory");
+		dev_err(&intf->dev, "out of memory\n");
 		goto out;
 	}
 	if (!rtl8150_reset(dev)) {
-		err("couldn't reset the device");
+		dev_err(&intf->dev, "couldn't reset the device\n");
 		goto out1;
 	}
 	fill_skb_pool(dev);
@@ -949,7 +951,7 @@ static int rtl8150_probe(struct usb_interface *intf,
 	usb_set_intfdata(intf, dev);
 	SET_NETDEV_DEV(netdev, &intf->dev);
 	if (register_netdev(netdev) != 0) {
-		err("couldn't register the device");
+		dev_err(&intf->dev, "couldn't register the device\n");
 		goto out2;
 	}
 

-- 
Best regards, Klimov Alexey

--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
