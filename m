From: David Hollis <dhollis@davehollis.com>
Subject: [PATCH] asix - Add support for LyconSys FiberGecko
Date: Thu,  7 Aug 2014 11:53:46 -0400
Message-ID: <1407426826-11335-2-git-send-email-dhollis@davehollis.com>
References: <1407426826-11335-1-git-send-email-dhollis@davehollis.com>
Cc: David Hollis <dhollis@davehollis.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.davehollis.com ([66.77.138.211]:58465 "EHLO
	mail.davehollis.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932082AbaHGQAI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Aug 2014 12:00:08 -0400
In-Reply-To: <1407426826-11335-1-git-send-email-dhollis@davehollis.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Reported-by: Sven Kreiensen <s.kreiensen@lyconsys.com>
Signed-off-by: David Hollis <dhollis@davehollis.com>

---
 drivers/net/usb/asix_devices.c | 25 ++++++++++++++++++++++++-
 1 file changed, 24 insertions(+), 1 deletion(-)

diff --git a/drivers/net/usb/asix_devices.c b/drivers/net/usb/asix_devices.c
index 5d19409..d09f2ea 100644
--- a/drivers/net/usb/asix_devices.c
+++ b/drivers/net/usb/asix_devices.c
@@ -1,6 +1,6 @@
 /*
  * ASIX AX8817X based USB 2.0 Ethernet Devices
- * Copyright (C) 2003-2006 David Hollis <dhollis@davehollis.com>
+ * Copyright (C) 2003-2014 David Hollis <dhollis@davehollis.com>
  * Copyright (C) 2005 Phil Chang <pchang23@sbcglobal.net>
  * Copyright (C) 2006 James Painter <jamie.painter@iname.com>
  * Copyright (c) 2002-2003 TiVo Inc.
@@ -648,6 +648,12 @@ static int ax88178_reset(struct usbnet *dev)
 	asix_sw_reset(dev, 0);
 	msleep(150);
 
+	/* LyconSys FiberGecko: Turn on PHY */
+	if (dev->driver_info->flags == 0x20061201) {
+		/* Power on Phy: set gpio2=high */
+		asix_write_gpio(dev, AX_GPIO_GPO2EN | AX_GPIO_GPO_2, 50);
+	}
+
 	asix_sw_reset(dev, AX_SWRESET_PRL | AX_SWRESET_IPPD);
 	msleep(150);
 
@@ -946,6 +952,19 @@ static const struct driver_info hg20f9_info = {
 	.data = FLAG_EEPROM_MAC,
 };
 
+static const struct driver_info lyconsys_fibergecko100_info = {
+	.description = "LyconSys FiberGecko 100 USB 2.0 to Ethernet Adapter",
+	.bind = ax88178_bind,
+	.status = asix_status,
+	.link_reset = ax88178_link_reset,
+	.reset = ax88178_link_reset,
+	.flags = FLAG_ETHER | FLAG_FRAMING_AX | FLAG_LINK_INTR |
+		 FLAG_MULTI_PACKET,
+	.rx_fixup =	asix_rx_fixup_common,
+	.tx_fixup =	asix_tx_fixup,
+	.data = 0x20061201,
+};
+
 static const struct usb_device_id	products [] = {
 {
 	// Linksys USB200M
@@ -1091,6 +1110,10 @@ static const struct usb_device_id	products [] = {
 	 */
 	USB_DEVICE(0x066b, 0x20f9),
 	.driver_info = (unsigned long) &hg20f9_info,
+}, {
+	/* LyconSys FiberGecko 100 */
+	USB_DEVICE(0x1d2a, 0x0801),
+	.driver_info = (unsigned long) &lyconsys_fibergecko100_info,
 },
 	{ },		// END
 };
-- 
1.8.3.1
