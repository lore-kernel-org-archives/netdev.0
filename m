From: Dan Williams <dcbw-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Subject: [PATCH] usb: add device IDs for Dell 5804 (Novatel E371) WWAN card
Date: Wed, 01 May 2013 13:01:45 -0500
Message-ID: <1367431305.12353.8.camel@dcbw.foobar.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: =?ISO-8859-1?Q?Bj=F8rn?= Mork <bjorn-yOkvZcmFvRU@public.gmane.org>,
	Network Development <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Greg KH <gregkh-hQyY1W1yCW8ekmWlsbkhG0B+6BGkLq7r@public.gmane.org>, stable-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Matthias Urlichs <smurf-ci3XGGwdvIcvfNposrsB4g@public.gmane.org>, dagofthedofg-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org
To: linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

A rebranded Novatel E371 for AT&T's LTE bands.

Cc: <stable-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Signed-off-by: Dan Williams <dcbw-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
---
See https://bugzilla.redhat.com/show_bug.cgi?id=955426

diff --git a/drivers/net/usb/cdc_ether.c b/drivers/net/usb/cdc_ether.c
index 57136dc..299c53b 100644
--- a/drivers/net/usb/cdc_ether.c
+++ b/drivers/net/usb/cdc_ether.c
@@ -615,6 +615,13 @@ static const struct usb_device_id	products [] = {
 	.driver_info = 0,
 },
 
+/* Dell Wireless 5804 (Novatel E371) - handled by qmi_wwan */
+{
+	USB_DEVICE_AND_INTERFACE_INFO(DELL_VENDOR_ID, 0x819b, USB_CLASS_COMM,
+			USB_CDC_SUBCLASS_ETHERNET, USB_CDC_PROTO_NONE),
+	.driver_info = 0,
+},
+
 /* AnyDATA ADU960S - handled by qmi_wwan */
 {
 	USB_DEVICE_AND_INTERFACE_INFO(0x16d5, 0x650a, USB_CLASS_COMM,
diff --git a/drivers/net/usb/qmi_wwan.c b/drivers/net/usb/qmi_wwan.c
index 968d5d5..38734fd 100644
--- a/drivers/net/usb/qmi_wwan.c
+++ b/drivers/net/usb/qmi_wwan.c
@@ -392,6 +392,13 @@ static const struct usb_device_id products[] = {
 					      USB_CDC_PROTO_NONE),
 		.driver_info        = (unsigned long)&qmi_wwan_info,
 	},
+	{	/* Dell Wireless 5804 (Novatel E371) */
+		USB_DEVICE_AND_INTERFACE_INFO(0x413C, 0x819b,
+					      USB_CLASS_COMM,
+					      USB_CDC_SUBCLASS_ETHERNET,
+					      USB_CDC_PROTO_NONE),
+		.driver_info        = (unsigned long)&qmi_wwan_info,
+	},
 	{	/* ADU960S */
 		USB_DEVICE_AND_INTERFACE_INFO(0x16d5, 0x650a,
 					      USB_CLASS_COMM,
diff --git a/drivers/usb/serial/option.c b/drivers/usb/serial/option.c
index 558adfc..569caf6 100644
--- a/drivers/usb/serial/option.c
+++ b/drivers/usb/serial/option.c
@@ -196,6 +196,7 @@ static void option_instat_callback(struct urb *urb);
 
 #define DELL_PRODUCT_5800_MINICARD_VZW		0x8195  /* Novatel E362 */
 #define DELL_PRODUCT_5800_V2_MINICARD_VZW	0x8196  /* Novatel E362 */
+#define DELL_PRODUCT_5804_MINICARD_ATT		0x819b  /* Novatel E371 */
 
 #define KYOCERA_VENDOR_ID			0x0c88
 #define KYOCERA_PRODUCT_KPC650			0x17da
@@ -770,6 +771,7 @@ static const struct usb_device_id option_ids[] = {
 	{ USB_DEVICE(DELL_VENDOR_ID, DELL_PRODUCT_5730_MINICARD_VZW) }, 	/* Dell Wireless 5730 Mobile Broadband EVDO/HSPA Mini-Card */
 	{ USB_DEVICE_AND_INTERFACE_INFO(DELL_VENDOR_ID, DELL_PRODUCT_5800_MINICARD_VZW, 0xff, 0xff, 0xff) },
 	{ USB_DEVICE_AND_INTERFACE_INFO(DELL_VENDOR_ID, DELL_PRODUCT_5800_V2_MINICARD_VZW, 0xff, 0xff, 0xff) },
+	{ USB_DEVICE_AND_INTERFACE_INFO(DELL_VENDOR_ID, DELL_PRODUCT_5804_MINICARD_ATT, 0xff, 0xff, 0xff) },
 	{ USB_DEVICE(ANYDATA_VENDOR_ID, ANYDATA_PRODUCT_ADU_E100A) },	/* ADU-E100, ADU-310 */
 	{ USB_DEVICE(ANYDATA_VENDOR_ID, ANYDATA_PRODUCT_ADU_500A) },
 	{ USB_DEVICE(ANYDATA_VENDOR_ID, ANYDATA_PRODUCT_ADU_620UW) },


--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
