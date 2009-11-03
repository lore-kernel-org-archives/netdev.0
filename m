From: Torgny Johansson <torgny.johansson@gmail.com>
Subject: [PATCH torvalds-2.6] cdc_ether: additional Ericsson MBM PID's to the whitelist
Date: Tue, 3 Nov 2009 22:28:05 +0100
Message-ID: <200911032228.05527.torgny.johansson@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, saurin.shah@intel.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ew0-f207.google.com ([209.85.219.207]:34459 "EHLO
	mail-ew0-f207.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752176AbZKCV2D (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Nov 2009 16:28:03 -0500
Received: by ewy3 with SMTP id 3so2443180ewy.37
        for <netdev@vger.kernel.org>; Tue, 03 Nov 2009 13:28:07 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi!

This is another attempt to submit this patch that adds more Ericsson Mobile Broadband modules to the cdc_ether whitelist. 
The last patch was rejected since it produced rejects with the Torvalds tree. I've tried it again after adding 
another vid/pid and also rechecked it with the 
checkpatch script. It still applies cleanly for me and checkpatch gives no errors or warnings. 
I suspect Outlook garbles it when I send it.

Trying with another e-mail client to see if that works better. I've sent it to my own gmail first and if I "view original" in gmail 
the patch works and applies cleanly after downloading it so I'm hoping it will work for you guys too.

Devices added to the whitelist:
 - Ericsson Mobile Broadband variants (F3607gw, F3307 and c3607w)
 - Dell F3607gw variants
 - Toshiba F3607gw variants

Thanks!

Regards 
Torgny Johansson

---

Signed-off-by: Torgny Johansson <torgny.johansson@gmail.com>

diff --git a/drivers/net/usb/Kconfig b/drivers/net/usb/Kconfig
index c47237c..32d9356 100644
--- a/drivers/net/usb/Kconfig
+++ b/drivers/net/usb/Kconfig
@@ -174,7 +174,7 @@ config USB_NET_CDCETHER
 	    * Ericsson Mobile Broadband Module (all variants)
  	    * Motorola (DM100 and SB4100)
  	    * Broadcom Cable Modem (reference design)
-	    * Toshiba (PCX1100U and F3507g)
+	    * Toshiba (PCX1100U and F3507g/F3607gw)
 	    * ...
 
 	  This driver creates an interface named "ethX", where X depends on
diff --git a/drivers/net/usb/cdc_ether.c b/drivers/net/usb/cdc_ether.c
index 4a6aff5..21e1ba1 100644
--- a/drivers/net/usb/cdc_ether.c
+++ b/drivers/net/usb/cdc_ether.c
@@ -544,20 +544,60 @@ static const struct usb_device_id	products [] = {
 			USB_CDC_SUBCLASS_MDLM, USB_CDC_PROTO_NONE),
 	.driver_info = (unsigned long) &cdc_info,
 }, {
-	/* Ericsson F3307 */
+	/* Ericsson F3607gw ver 2 */
+	USB_DEVICE_AND_INTERFACE_INFO(0x0bdb, 0x1905, USB_CLASS_COMM,
+			USB_CDC_SUBCLASS_MDLM, USB_CDC_PROTO_NONE),
+	.driver_info = (unsigned long) &cdc_info,
+}, {
+	/* Ericsson F3607gw ver 3 */
 	USB_DEVICE_AND_INTERFACE_INFO(0x0bdb, 0x1906, USB_CLASS_COMM,
 			USB_CDC_SUBCLASS_MDLM, USB_CDC_PROTO_NONE),
 	.driver_info = (unsigned long) &cdc_info,
 }, {
+	/* Ericsson F3307 */
+	USB_DEVICE_AND_INTERFACE_INFO(0x0bdb, 0x190a, USB_CLASS_COMM,
+			USB_CDC_SUBCLASS_MDLM, USB_CDC_PROTO_NONE),
+	.driver_info = (unsigned long) &cdc_info,
+}, {
+	/* Ericsson F3307 ver 2 */
+	USB_DEVICE_AND_INTERFACE_INFO(0x0bdb, 0x1909, USB_CLASS_COMM,
+			USB_CDC_SUBCLASS_MDLM, USB_CDC_PROTO_NONE),
+	.driver_info = (unsigned long) &cdc_info,
+}, {
+	/* Ericsson C3607w */
+	USB_DEVICE_AND_INTERFACE_INFO(0x0bdb, 0x1049, USB_CLASS_COMM,
+			USB_CDC_SUBCLASS_MDLM, USB_CDC_PROTO_NONE),
+	.driver_info = (unsigned long) &cdc_info,
+}, {
 	/* Toshiba F3507g */
 	USB_DEVICE_AND_INTERFACE_INFO(0x0930, 0x130b, USB_CLASS_COMM,
 			USB_CDC_SUBCLASS_MDLM, USB_CDC_PROTO_NONE),
 	.driver_info = (unsigned long) &cdc_info,
 }, {
+	/* Toshiba F3607gw */
+	USB_DEVICE_AND_INTERFACE_INFO(0x0930, 0x130c, USB_CLASS_COMM,
+			USB_CDC_SUBCLASS_MDLM, USB_CDC_PROTO_NONE),
+	.driver_info = (unsigned long) &cdc_info,
+}, {
+	/* Toshiba F3607gw ver 2 */
+	USB_DEVICE_AND_INTERFACE_INFO(0x0930, 0x1311, USB_CLASS_COMM,
+			USB_CDC_SUBCLASS_MDLM, USB_CDC_PROTO_NONE),
+	.driver_info = (unsigned long) &cdc_info,
+}, {
 	/* Dell F3507g */
 	USB_DEVICE_AND_INTERFACE_INFO(0x413c, 0x8147, USB_CLASS_COMM,
 			USB_CDC_SUBCLASS_MDLM, USB_CDC_PROTO_NONE),
 	.driver_info = (unsigned long) &cdc_info,
+}, {
+	/* Dell F3607gw */
+	USB_DEVICE_AND_INTERFACE_INFO(0x413c, 0x8183, USB_CLASS_COMM,
+			USB_CDC_SUBCLASS_MDLM, USB_CDC_PROTO_NONE),
+	.driver_info = (unsigned long) &cdc_info,
+}, {
+	/* Dell F3607gw ver 2 */
+	USB_DEVICE_AND_INTERFACE_INFO(0x413c, 0x8184, USB_CLASS_COMM,
+			USB_CDC_SUBCLASS_MDLM, USB_CDC_PROTO_NONE),
+	.driver_info = (unsigned long) &cdc_info,
 },
 	{ },		// END
 };
