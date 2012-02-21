From: Scott Talbert <talbert@techie.net>
Subject: [PATCH v2] cdc_ether/zaurus: Move Harmony 900 from cdc_ether to
 zaurus
Date: Mon, 20 Feb 2012 21:29:29 -0500 (EST)
Message-ID: <alpine.LRH.2.02.1202202114180.382@bear.techie.net>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; format=flowed; charset=US-ASCII
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from bear.techie.net ([205.134.185.202]:34908 "EHLO bear.techie.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751472Ab2BUC3a (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 20 Feb 2012 21:29:30 -0500
Received: from bear.techie.net (localhost.localdomain [127.0.0.1])
	by bear.techie.net (8.13.8/8.13.8) with ESMTP id q1L2TTCr000537
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=NO)
	for <netdev@vger.kernel.org>; Mon, 20 Feb 2012 21:29:29 -0500
Received: from localhost (talbert@localhost)
	by bear.techie.net (8.13.8/8.13.8/Submit) with ESMTP id q1L2TTrR000534
	for <netdev@vger.kernel.org>; Mon, 20 Feb 2012 21:29:29 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In the current kernel implementation, the Logitech Harmony 900 remote 
control is matched to the cdc_ether driver through the generic 
USB_CDC_SUBCLASS_MDLM entry.  However, this device appears to be of the 
pseudo-MDLM (Belcarra) type, rather than the standard one.  This 
patch blacklists the Harmony 900 from the cdc_ether driver and whitelists 
it for the pseudo-MDLM driver in zaurus.

Signed-off-by: Scott Talbert <talbert@techie.net>
---
  drivers/net/usb/cdc_ether.c |    7 +++++++
  drivers/net/usb/zaurus.c    |    7 +++++++
  2 files changed, 14 insertions(+), 0 deletions(-)

diff --git a/drivers/net/usb/cdc_ether.c b/drivers/net/usb/cdc_ether.c
index c924ea2..13919dd 100644
--- a/drivers/net/usb/cdc_ether.c
+++ b/drivers/net/usb/cdc_ether.c
@@ -570,6 +570,13 @@ static const struct usb_device_id	products [] = {
  	.driver_info = (unsigned long)&wwan_info,
  },

+/* Logitech Harmony 900 - uses the pseudo-MDLM (BLAN) driver */
+{
+	USB_DEVICE_AND_INTERFACE_INFO(0x046d, 0xc11f, USB_CLASS_COMM,
+			USB_CDC_SUBCLASS_MDLM, USB_CDC_PROTO_NONE),
+	.driver_info		= 0,
+},
+
  /*
   * WHITELIST!!!
   *
diff --git a/drivers/net/usb/zaurus.c b/drivers/net/usb/zaurus.c
index 1a2234c..246b3bb 100644
--- a/drivers/net/usb/zaurus.c
+++ b/drivers/net/usb/zaurus.c
@@ -349,6 +349,13 @@ static const struct usb_device_id	products [] = {
  	ZAURUS_MASTER_INTERFACE,
  	.driver_info = OLYMPUS_MXL_INFO,
  },
+
+/* Logitech Harmony 900 - uses the pseudo-MDLM (BLAN) driver */
+{
+	USB_DEVICE_AND_INTERFACE_INFO(0x046d, 0xc11f, USB_CLASS_COMM,
+			USB_CDC_SUBCLASS_MDLM, USB_CDC_PROTO_NONE),
+	.driver_info = (unsigned long) &bogus_mdlm_info,
+},
  	{ },		// END
  };
  MODULE_DEVICE_TABLE(usb, products);
-- 
1.7.5.4
