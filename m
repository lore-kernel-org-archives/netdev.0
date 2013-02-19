From: Dan Williams <dcbw@redhat.com>
Subject: [PATCH v2] qmi_wwan, cdc-ether: add ADU960S
Date: Mon, 18 Feb 2013 21:25:09 -0600
Message-ID: <1361244309.29695.12.camel@dcbw.foobar.com>
References: <1360173904.11742.8.camel@dcbw.foobar.com>
	 <874nhp6x1o.fsf@nemi.mork.no> <1360255990.2382.17.camel@dcbw.foobar.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: linux-usb@vger.kernel.org, netdev@vger.kernel.org
To: =?ISO-8859-1?Q?Bj=F8rn?= Mork <bjorn@mork.no>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:38027 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758115Ab3BSDY4 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 18 Feb 2013 22:24:56 -0500
In-Reply-To: <1360255990.2382.17.camel@dcbw.foobar.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

It advertises a standard CDC-ETHER interface, which actually should be
driven by qmi_wwan.

Signed-off-by: Dan Williams <dcbw@redhat.com>
---
index 3f3d12d..57136dc 100644
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
index 19d9035..efb5c7c 100644
--- a/drivers/net/usb/qmi_wwan.c
+++ b/drivers/net/usb/qmi_wwan.c
@@ -409,6 +409,13 @@ static const struct usb_device_id products[] = {
 					      USB_CDC_PROTO_NONE),
 		.driver_info        = (unsigned long)&qmi_wwan_info,
 	},
+	{	/* ADU960S */
+		USB_DEVICE_AND_INTERFACE_INFO(0x16d5, 0x650a,
+					      USB_CLASS_COMM,
+					      USB_CDC_SUBCLASS_ETHERNET,
+					      USB_CDC_PROTO_NONE),
+		.driver_info        = (unsigned long)&qmi_wwan_info,
+	},
 
 	/* 3. Combined interface devices matching on interface number */
 	{QMI_FIXED_INTF(0x0408, 0xea42, 4)},	/* Yota / Megafon M100-1 */
