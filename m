From: Dan Williams <dcbw@redhat.com>
Subject: [PATCH] qmi_wwan, cdc-ether: add ADU960S
Date: Wed, 06 Feb 2013 12:05:04 -0600
Message-ID: <1360173904.11742.8.camel@dcbw.foobar.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: linux-usb@vger.kernel.org, netdev@vger.kernel.org
To: =?ISO-8859-1?Q?Bj=F8rn?= Mork <bjorn@mork.no>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:30457 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755389Ab3BFSEu (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 6 Feb 2013 13:04:50 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

It advertises a standard CDC-ETHER interface, which actually should be
driven by qmi_wwan.

Signed-off-by: Dan Williams <dcbw@redhat.com>
---
diff --git a/drivers/net/usb/cdc_ether.c b/drivers/net/usb/cdc_ether.c
index 3f3d12d..cc6d0c1 100644
--- a/drivers/net/usb/cdc_ether.c
+++ b/drivers/net/usb/cdc_ether.c
@@ -615,6 +615,13 @@ static const struct usb_device_id	products [] = {
 	.driver_info = 0,
 },
 
+/* AnyDATA ADU960S - handled by qmi_wwan */
+{
+	USB_DEVICE_AND_INTERFACE_INFO(0x16d5, 0x650a, USB_CLASS_COMM,
+			USB_CDC_SUBCLASS_ETHERNET, USB_CDC_PROTO_NONE),
+	.driver_info = 0,
+},
+
 /*
  * WHITELIST!!!
  *
diff --git a/drivers/net/usb/qmi_wwan.c b/drivers/net/usb/qmi_wwan.c
index 6a1ca50..2b5ea32 100644
--- a/drivers/net/usb/qmi_wwan.c
+++ b/drivers/net/usb/qmi_wwan.c
@@ -459,6 +459,7 @@ static const struct usb_device_id products[] = {
 	{QMI_FIXED_INTF(0x1199, 0x68a2, 19)},	/* Sierra Wireless MC7710 in QMI mode */
 	{QMI_FIXED_INTF(0x1199, 0x901c, 8)},    /* Sierra Wireless EM7700 */
 	{QMI_FIXED_INTF(0x1bbb, 0x011e, 4)},	/* Telekom Speedstick LTE II (Alcatel One Touch L100V LTE) */
+	{QMI_FIXED_INTF(0x16d5, 0x650a, 8)},	/* AnyDATA ADU960S */
 
 	/* 4. Gobi 1000 devices */
 	{QMI_GOBI1K_DEVICE(0x05c6, 0x9212)},	/* Acer Gobi Modem Device */
