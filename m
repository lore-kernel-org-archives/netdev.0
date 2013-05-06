From: Dan Williams <dcbw@redhat.com>
Subject: qmi_wwan/cdc_ether: add device IDs for Dell 5804 (Novatel E371)
 WWAN card
Date: Mon, 06 May 2013 16:14:38 -0500
Message-ID: <1367874878.31762.0.camel@dcbw.foobar.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: stable@vger.kernel.org, dagofthedofg@gmail.com,
	=?ISO-8859-1?Q?Bj=F8rn?= Mork <bjorn@mork.no>
To: netdev@vger.kernel.org
Return-path: <stable-owner@vger.kernel.org>
Sender: stable-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

A rebranded Novatel E371 for AT&T's LTE bands.  qmi_wwan should drive this
device, while cdc_ether should ignore it.  Even though the USB descriptors
are plain CDC-ETHER that USB interface is a QMI interface.

Cc: <stable@vger.kernel.org>
Signed-off-by: Dan Williams <dcbw@redhat.com>
---
 drivers/net/usb/cdc_ether.c | 7 +++++++
 drivers/net/usb/qmi_wwan.c  | 7 +++++++
 2 files changed, 14 insertions(+)

diff --git a/drivers/net/usb/cdc_ether.c b/drivers/net/usb/cdc_ether.c
index 24fbec2..078795f 100644
--- a/drivers/net/usb/cdc_ether.c
+++ b/drivers/net/usb/cdc_ether.c
@@ -613,6 +613,13 @@ static const struct usb_device_id	products [] = {
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
index 834e405..cf887c2 100644
--- a/drivers/net/usb/qmi_wwan.c
+++ b/drivers/net/usb/qmi_wwan.c
@@ -501,6 +501,13 @@ static const struct usb_device_id products[] = {
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
-- 
1.8.1.4
