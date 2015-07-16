From: Reinhard Speyerer <rspmn@arcor.de>
Subject: [PATCH] qmi_wwan: add the second QMI/network interface for Sierra
 Wireless MC7305/MC7355
Date: Thu, 16 Jul 2015 23:28:14 +0200
Message-ID: <20150716212813.GA2904@arcor.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, bjorn@mork.no
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-in-04.arcor-online.net ([151.189.21.44]:56089 "EHLO
	mail-in-04.arcor-online.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755926AbbGPV2a (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 16 Jul 2015 17:28:30 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Sierra Wireless MC7305/MC7355 with USB ID 1199:9041 also provide a
second QMI/network interface like the MC73xx with USB ID 1199:68c0 on
USB interface #10 when used in the appropriate USB configuration.
Add the corresponding QMI_FIXED_INTF entry to the qmi_wwan driver.

Please note that the second QMI/network interface is not working for
early MC73xx firmware versions like 01.08.x as the device does not
respond to QMI messages on the second /dev/cdc-wdm port.

Signed-off-by: Reinhard Speyerer <rspmn@arcor.de>
---
diff -uprN linux-4.2-rc2/drivers/net/usb/qmi_wwan.c linux-4.2-rc2-with-mc73xx-patch/drivers/net/usb/qmi_wwan.c
--- linux-4.2-rc2/drivers/net/usb/qmi_wwan.c	2015-07-13 00:10:30.000000000 +0200
+++ linux-4.2-rc2-with-mc73xx-patch/drivers/net/usb/qmi_wwan.c	2015-07-16 21:35:26.000000000 +0200
@@ -757,6 +757,7 @@ static const struct usb_device_id produc
 	{QMI_FIXED_INTF(0x1199, 0x901c, 8)},    /* Sierra Wireless EM7700 */
 	{QMI_FIXED_INTF(0x1199, 0x901f, 8)},    /* Sierra Wireless EM7355 */
 	{QMI_FIXED_INTF(0x1199, 0x9041, 8)},	/* Sierra Wireless MC7305/MC7355 */
+	{QMI_FIXED_INTF(0x1199, 0x9041, 10)},	/* Sierra Wireless MC7305/MC7355 */
 	{QMI_FIXED_INTF(0x1199, 0x9051, 8)},	/* Netgear AirCard 340U */
 	{QMI_FIXED_INTF(0x1199, 0x9053, 8)},	/* Sierra Wireless Modem */
 	{QMI_FIXED_INTF(0x1199, 0x9054, 8)},	/* Sierra Wireless Modem */
