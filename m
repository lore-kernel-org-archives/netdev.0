From: Dan Williams <dcbw@redhat.com>
Subject: [PATCH 1/2 v2] qmi_wwan/cdc_ether: add Dell Wireless 5800 (Novatel
 E362) USB IDs
Date: Mon, 17 Dec 2012 12:17:41 -0600
Message-ID: <1355768261.1424.50.camel@dcbw.foobar.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Aleksander Morgado <aleksander@gnu.org>,
	netdev <netdev@vger.kernel.org>
To: =?ISO-8859-1?Q?Bj=F8rn?= Mork <bjorn@mork.no>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:13685 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752716Ab2LQSQO (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 17 Dec 2012 13:16:14 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Dan Williams <dcbw@redhat.com>
Cc: stable@vger.kernel.org
---
 drivers/net/usb/cdc_ether.c | 15 +++++++++++++++
 drivers/net/usb/qmi_wwan.c  | 14 ++++++++++++++
 2 files changed, 29 insertions(+)

diff --git a/drivers/net/usb/cdc_ether.c b/drivers/net/usb/cdc_ether.c
index d012982..c4c593d 100644
--- a/drivers/net/usb/cdc_ether.c
+++ b/drivers/net/usb/cdc_ether.c
@@ -487,6 +487,7 @@ static const struct driver_info wwan_info = {
 #define HUAWEI_VENDOR_ID	0x12D1
 #define NOVATEL_VENDOR_ID	0x1410
 #define ZTE_VENDOR_ID		0x19D2
+#define DELL_VENDOR_ID		0x413C
 
 static const struct usb_device_id	products [] = {
 /*
@@ -618,6 +619,20 @@ static const struct usb_device_id	products [] = {
 	.driver_info = 0,
 },
 
+/* Dell Wireless 5800 (Novatel E362) - handled by qmi_wwan */
+{
+	USB_DEVICE_AND_INTERFACE_INFO(DELL_VENDOR_ID, 0x8195, USB_CLASS_COMM,
+			USB_CDC_SUBCLASS_ETHERNET, USB_CDC_PROTO_NONE),
+	.driver_info = 0,
+},
+
+/* Dell Wireless 5800 (Novatel E362) - handled by qmi_wwan */
+{
+	USB_DEVICE_AND_INTERFACE_INFO(DELL_VENDOR_ID, 0x8196, USB_CLASS_COMM,
+			USB_CDC_SUBCLASS_ETHERNET, USB_CDC_PROTO_NONE),
+	.driver_info = 0,
+},
+
 /*
  * WHITELIST!!!
  *
diff --git a/drivers/net/usb/qmi_wwan.c b/drivers/net/usb/qmi_wwan.c
index 1ea91f4..9b950f5 100644
--- a/drivers/net/usb/qmi_wwan.c
+++ b/drivers/net/usb/qmi_wwan.c
@@ -383,6 +383,20 @@ static const struct usb_device_id products[] = {
 		                              USB_CDC_PROTO_NONE),
 		.driver_info        = (unsigned long)&qmi_wwan_info,
 	},
+	{	/* Dell Wireless 5800 (Novatel E362) */
+		USB_DEVICE_AND_INTERFACE_INFO(0x413C, 0x8195,
+					      USB_CLASS_COMM,
+					      USB_CDC_SUBCLASS_ETHERNET,
+					      USB_CDC_PROTO_NONE),
+		.driver_info        = (unsigned long)&qmi_wwan_info,
+	},
+	{	/* Dell Wireless 5800 V2 (Novatel E362) */
+		USB_DEVICE_AND_INTERFACE_INFO(0x413C, 0x8196,
+					      USB_CLASS_COMM,
+					      USB_CDC_SUBCLASS_ETHERNET,
+					      USB_CDC_PROTO_NONE),
+		.driver_info        = (unsigned long)&qmi_wwan_info,
+	},
 
 	/* 3. Combined interface devices matching on interface number */
 	{QMI_FIXED_INTF(0x12d1, 0x140c, 1)},	/* Huawei E173 */
-- 
1.7.11.7
