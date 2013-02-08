From: Lucas Stach <dev@lynxeye.de>
Subject: [PATCH] net: usb: fix regression from 6509141f9c2ba74df6cc72ec35cd1865276ae3a4
Date: Fri,  8 Feb 2013 03:18:39 +0100
Message-ID: <1360289919-20409-1-git-send-email-dev@lynxeye.de>
Cc: Wei Shuai <cpuwolf@gmail.com>,
	"David S. Miller" <davem@davemloft.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ns.km20343-01.keymachine.de ([84.19.182.79]:57051 "EHLO
	km20343-01.keymachine.de" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1757513Ab3BHCSo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Feb 2013 21:18:44 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The newly added flag NOARP was using an already defined value, which
broke drivers using flag MULTI_PACKET.

Signed-off-by: Lucas Stach <dev@lynxeye.de>
---
As the regressing patch went in with v3.8-rc5, this fix should go to
mainline ASAP.
---
 include/linux/usb/usbnet.h | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/include/linux/usb/usbnet.h b/include/linux/usb/usbnet.h
index 5de7a22..2cb5fb6 100644
--- a/include/linux/usb/usbnet.h
+++ b/include/linux/usb/usbnet.h
@@ -100,7 +100,6 @@ struct driver_info {
 #define FLAG_LINK_INTR	0x0800		/* updates link (carrier) status */
 
 #define FLAG_POINTTOPOINT 0x1000	/* possibly use "usb%d" names */
-#define FLAG_NOARP	0x2000		/* device can't do ARP */
 
 /*
  * Indicates to usbnet, that USB driver accumulates multiple IP packets.
@@ -108,6 +107,7 @@ struct driver_info {
  */
 #define FLAG_MULTI_PACKET	0x2000
 #define FLAG_RX_ASSEMBLE	0x4000	/* rx packets may span >1 frames */
+#define FLAG_NOARP		0x8000	/* device can't do ARP */
 
 	/* init device ... can sleep, or cause probe() failure */
 	int	(*bind)(struct usbnet *, struct usb_interface *);
-- 
1.8.1
