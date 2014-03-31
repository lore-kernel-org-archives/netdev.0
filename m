From: Yegor Yefremov <yegorslists@googlemail.com>
Subject: [PATCH v2] qmi_wwan/cdc_ether: move Novatel E371 (1410:9011) to qmi_wwan
Date: Mon, 31 Mar 2014 18:11:27 +0200
Message-ID: <1396282287-5060-1-git-send-email-yegorslists@googlemail.com>
Cc: bjorn@mork.no, dcbw@redhat.com, davem@davemloft.net,
	Yegor Yefremov <yegorslists@googlemail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bk0-f44.google.com ([209.85.214.44]:34930 "EHLO
	mail-bk0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754049AbaCaQLs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 31 Mar 2014 12:11:48 -0400
Received: by mail-bk0-f44.google.com with SMTP id mz13so1196626bkb.17
        for <netdev@vger.kernel.org>; Mon, 31 Mar 2014 09:11:46 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This device provides QMI and ethernet functionality via a standard CDC
ethernet descriptor.  But when driven by cdc_ether, the QMI
functionality is unavailable because only cdc_ether can claim the USB
interface. Thus blacklist the device in cdc_ether and add its IDs to
qmi_wwan, which enables both QMI and ethernet simultaneously.

Signed-off-by: Yegor Yefremov <yegorslists@googlemail.com>
---
Changes:
	v2: fix indentation

 drivers/net/usb/cdc_ether.c | 7 +++++++
 drivers/net/usb/qmi_wwan.c  | 7 +++++++
 2 files changed, 14 insertions(+)

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
index 313cb6c..c912966 100644
--- a/drivers/net/usb/qmi_wwan.c
+++ b/drivers/net/usb/qmi_wwan.c
@@ -500,6 +500,13 @@ static const struct usb_device_id products[] = {
 		                              USB_CDC_PROTO_NONE),
 		.driver_info        = (unsigned long)&qmi_wwan_info,
 	},
+	{	/* Novatel Expedite E371 */
+		USB_DEVICE_AND_INTERFACE_INFO(0x1410, 0x9011,
+						USB_CLASS_COMM,
+						USB_CDC_SUBCLASS_ETHERNET,
+						USB_CDC_PROTO_NONE),
+		.driver_info        = (unsigned long)&qmi_wwan_info,
+	},
 	{	/* Dell Wireless 5800 (Novatel E362) */
 		USB_DEVICE_AND_INTERFACE_INFO(0x413C, 0x8195,
 					      USB_CLASS_COMM,
-- 
1.8.3.2
