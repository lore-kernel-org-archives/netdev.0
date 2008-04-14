From: Paulius Zaleckas <paulius.zaleckas-Ft0m5Q12RQ9xBelEqimL3w@public.gmane.org>
Subject: Re: [RFC] Patch to option HSO driver to the kernel
Date: Tue, 15 Apr 2008 02:20:51 +0300
Message-ID: <fu0osk$887$1@ger.gmane.org>
References: <20080414213238.GB28833@kroah.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------050900060001080505010704"
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20080414213238.GB28833-U8xfFu+wG4EAvxtiuMwx3w@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------050900060001080505010704
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

Greg KH wrote:
> I'd like to see this go into 2.6.26, so any review comments by anyone
> who wishes to review any portion of this would be greatly apprecited.

In attached patch I have rewrote MAC address generation to simple call
to random_ether_addr instead of some mysterious pointer parsing :)

Paulius

--------------050900060001080505010704
Content-Type: text/x-patch;
 name="hso_random.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="hso_random.patch"

diff --git a/ldp/usb-add-option-hso-driver.patch b/ldp/usb-add-option-hso-driver.patch
index 429f9c9..7360e04 100644
--- a/ldp/usb-add-option-hso-driver.patch
+++ b/ldp/usb-add-option-hso-driver.patch
@@ -56,7 +56,7 @@ Signed-off-by: Greg Kroah-Hartman <gregkh-l3A5Bk7waGM@public.gmane.org>
  obj-$(CONFIG_USB_NET_DM9601)	+= dm9601.o
 --- /dev/null
 +++ b/drivers/net/usb/hso.c
-@@ -0,0 +1,3349 @@
+@@ -0,0 +1,3343 @@
 +/******************************************************************************
 + *
 + * Driver for Option High Speed Mobile Devices.
@@ -1523,7 +1523,7 @@ Signed-off-by: Greg Kroah-Hartman <gregkh-l3A5Bk7waGM@public.gmane.org>
 +	return 0;
 +}
 +
-+/* Toggles radioon or off ( used by ioctl ) */
++/* Toggles radio on or off ( used by ioctl ) */
 +static int hso_set_radio(struct hso_device *hso_dev, int enabled)
 +{
 +	if (!hso_dev)
@@ -2350,7 +2350,7 @@ Signed-off-by: Greg Kroah-Hartman <gregkh-l3A5Bk7waGM@public.gmane.org>
 +	spin_lock_init(&serial->serial_lock);
 +	serial->num_rx_urbs = num_urbs;
 +
-+	/* RX , allocate urb and initialize */
++	/* RX, allocate urb and initialize */
 +
 +	/* prepare our RX buffer */
 +	serial->rx_data_length = rx_size;
@@ -2370,7 +2370,7 @@ Signed-off-by: Greg Kroah-Hartman <gregkh-l3A5Bk7waGM@public.gmane.org>
 +		}
 +	}
 +
-+	/* TX , allocate urb and initialize */
++	/* TX, allocate urb and initialize */
 +	serial->tx_urb = usb_alloc_urb(0, GFP_KERNEL);
 +	if (!serial->tx_urb) {
 +		dev_err(dev, "Could not allocate urb?\n");
@@ -3190,14 +3190,8 @@ Signed-off-by: Greg Kroah-Hartman <gregkh-l3A5Bk7waGM@public.gmane.org>
 +	unsigned char buffer[13];
 +	unsigned char checkserial[7] = "Serial";
 +
-+	/* we can't fail, therefor we use a default macaddress (constructed
-+	 * from the pointer of our struct) */
-+	mac_addr[0] = 0x00;
-+	mac_addr[1] = 0x03;
-+	mac_addr[2] = (unsigned char)(((unsigned long)odev) & 0xFF);
-+	mac_addr[3] = (unsigned char)((((unsigned long)odev) >> 8) & 0xFF);
-+	mac_addr[4] = (unsigned char)((((unsigned long)odev) >> 16) & 0xFF);
-+	mac_addr[5] = (unsigned char)((((unsigned long)odev) >> 24) & 0xFF);
++	/* we can't fail, therefor we use a random macaddress */
++	random_ether_addr(mac_addr);
 +	dummy_mac[0] = 0xFA;
 +	dummy_mac[1] = mac_addr[1];
 +	dummy_mac[2] = mac_addr[2];
@@ -3233,7 +3227,7 @@ Signed-off-by: Greg Kroah-Hartman <gregkh-l3A5Bk7waGM@public.gmane.org>
 +		}
 +	} else {
 +		dev_err(&odev->parent->usb->dev, "Attempting to get MAC "
-+			"address failed: using default\n");
++			"address failed: using random\n");
 +	}
 +
 +	/* Now copy it over to our network device structure */

--------------050900060001080505010704--

--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
