From: Paulius Zaleckas <paulius.zaleckas-Ft0m5Q12RQ9xBelEqimL3w@public.gmane.org>
Subject: Re: [RFC] Patch to option HSO driver to the kernel
Date: Tue, 15 Apr 2008 11:58:50 +0300
Message-ID: <48046E4A.3060901@teltonika.lt>
References: <20080414213238.GB28833@kroah.com> <fu0osk$887$1@ger.gmane.org> <200804151010.33688.oliver@neukum.org>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------060502040702030200040100"
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <200804151010.33688.oliver-GvhC2dPhHPQdnm+yROfE0A@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------060502040702030200040100
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit

Oliver Neukum wrote:
> Could you please generate a kernel patch, not a patch against a patch?
> I have difficulties dealing with that.

OK. Here it goes.

Paulius


--------------060502040702030200040100
Content-Type: text/x-patch;
 name="kernel_hso_random.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="kernel_hso_random.patch"

--- linux-2.6-hso/drivers/net/usb/hso.c	2008-04-15 11:26:05.000000000 +0300
+++ linux-2.6-hso-my/drivers/net/usb/hso.c	2008-04-15 11:52:25.000000000 +0300
@@ -1464,7 +1464,7 @@ static int hso_set_suspend(struct hso_de
 	return 0;
 }
 
-/* Toggles radioon or off ( used by ioctl ) */
+/* Toggles radio on or off ( used by ioctl ) */
 static int hso_set_radio(struct hso_device *hso_dev, int enabled)
 {
 	if (!hso_dev)
@@ -2291,7 +2291,7 @@ static int hso_serial_common_create(stru
 	spin_lock_init(&serial->serial_lock);
 	serial->num_rx_urbs = num_urbs;
 
-	/* RX , allocate urb and initialize */
+	/* RX, allocate urb and initialize */
 
 	/* prepare our RX buffer */
 	serial->rx_data_length = rx_size;
@@ -2311,7 +2311,7 @@ static int hso_serial_common_create(stru
 		}
 	}
 
-	/* TX , allocate urb and initialize */
+	/* TX, allocate urb and initialize */
 	serial->tx_urb = usb_alloc_urb(0, GFP_KERNEL);
 	if (!serial->tx_urb) {
 		dev_err(dev, "Could not allocate urb?\n");
@@ -3131,14 +3131,8 @@ static void set_ethernet_addr(struct hso
 	unsigned char buffer[13];
 	unsigned char checkserial[7] = "Serial";
 
-	/* we can't fail, therefor we use a default macaddress (constructed
-	 * from the pointer of our struct) */
-	mac_addr[0] = 0x00;
-	mac_addr[1] = 0x03;
-	mac_addr[2] = (unsigned char)(((unsigned long)odev) & 0xFF);
-	mac_addr[3] = (unsigned char)((((unsigned long)odev) >> 8) & 0xFF);
-	mac_addr[4] = (unsigned char)((((unsigned long)odev) >> 16) & 0xFF);
-	mac_addr[5] = (unsigned char)((((unsigned long)odev) >> 24) & 0xFF);
+	/* we can't fail, therefor we use a random macaddress */
+	random_ether_addr(mac_addr);
 	dummy_mac[0] = 0xFA;
 	dummy_mac[1] = mac_addr[1];
 	dummy_mac[2] = mac_addr[2];
@@ -3174,7 +3168,7 @@ static void set_ethernet_addr(struct hso
 		}
 	} else {
 		dev_err(&odev->parent->usb->dev, "Attempting to get MAC "
-			"address failed: using default\n");
+			"address failed: using random\n");
 	}
 
 	/* Now copy it over to our network device structure */

--------------060502040702030200040100--

--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
