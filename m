From: yegorslists@googlemail.com
Subject: [PATCH] qmi_wwan/cdc_ether: move Novatel E371 (1410:9011) to qmi_wwan
Date: Fri, 28 Mar 2014 12:07:18 +0100
Message-ID: <1396004838-23877-1-git-send-email-yegorslists@googlemail.com>
Cc: bjorn@mork.no, dcbw@redhat.com,
	Yegor Yefremov <yegorslists@googlemail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ns.visionsystems.de ([62.145.30.242]:44934 "EHLO
	mail.visionsystems.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751185AbaC1LgT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 28 Mar 2014 07:36:19 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Yegor Yefremov <yegorslists@googlemail.com>

This device provides QMI and ethernet functionality via a standard CDC
ethernet descriptor.  But when driven by cdc_ether, the QMI
functionality is unavailable because only cdc_ether can claim the USB
interface. Thus blacklist the device in cdc_ether and add its IDs to
qmi_wwan, which enables both QMI and ethernet simultaneously.

Signed-off-by: Yegor Yefremov <yegorslists@googlemail.com>
---
 drivers/net/usb/cdc_ether.c |    7 +++++++
 drivers/net/usb/qmi_wwan.c  |    7 +++++++
 2 files changed, 14 insertions(+), 0 deletions(-)

diff --git a/drivers/net/usb/cdc_ether.c b/drivers/net/usb/cdc_ether.c
index bd363b2..9ea4bfe 100644
--- a/drivers/net/usb/cdc_ether.c
+++ b/drivers/net/usb/cdc_ether.c
@@ -625,6 +625,13 @@ static const struct usb_device_id	products[] = {
 	.driver_info = 0,
 },
 
+/* Novatel Expedite E371 - handled by qmi_wwan */
+{
+	USB_DEVICE_AND_INTERFACE_INFO(NOVATEL_VENDOR_ID, 0x9011, USB_CLASS_COMM,
+			USB_CDC_SUBCLASS_ETHERNET, USB_CDC_PROTO_NONE),
+	.driver_info = 0,
+},
+
 /* AnyDATA ADU960S - handled by qmi_wwan */
 {
 	USB_DEVICE_AND_INTERFACE_INFO(0x16d5, 0x650a, USB_CLASS_COMM,
diff --git a/drivers/net/usb/qmi_wwan.c b/drivers/net/usb/qmi_wwan.c
index 313cb6c..e3458e3 100644
--- a/drivers/net/usb/qmi_wwan.c
+++ b/drivers/net/usb/qmi_wwan.c
@@ -500,6 +500,13 @@ static const struct usb_device_id products[] = {
 		                              USB_CDC_PROTO_NONE),
 		.driver_info        = (unsigned long)&qmi_wwan_info,
 	},
+	{	/* Novatel Expedite E371 */
+		USB_DEVICE_AND_INTERFACE_INFO(0x1410, 0x9011,
+		                              USB_CLASS_COMM,
+		                              USB_CDC_SUBCLASS_ETHERNET,
+		                              USB_CDC_PROTO_NONE),
+		.driver_info        = (unsigned long)&qmi_wwan_info,
+	},
 	{	/* Dell Wireless 5800 (Novatel E362) */
 		USB_DEVICE_AND_INTERFACE_INFO(0x413C, 0x8195,
 					      USB_CLASS_COMM,
-- 
1.7.7
