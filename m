From: =?UTF-8?q?Roman=20Spycha=C5=82a?= <roed@onet.eu>
Subject: [PATCH] usb: plusb: Add support for PL-27A1
Date: Thu, 20 Apr 2017 12:04:10 +0200
Message-ID: <20170420100410.3296-1-roed@onet.eu>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        =?UTF-8?q?Roman=20Spycha=C5=82a?= <roed@onet.eu>
To: linux-usb@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtpo47.poczta.onet.pl ([213.180.142.178]:43455 "EHLO
        smtpo47.poczta.onet.pl" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1031193AbdDTKNj (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 20 Apr 2017 06:13:39 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Roman Spychała <roed@onet.eu>

This patch adds support for the PL-27A1 by adding the appropriate
USB ID's. This chip is used in the goobay Active USB 3.0 Data Link
and Unitek Y-3501 cables.

Signed-off-by: Roman Spychała <roed@onet.eu>
---
 drivers/net/usb/Kconfig |  2 +-
 drivers/net/usb/plusb.c | 15 +++++++++++++--
 2 files changed, 14 insertions(+), 3 deletions(-)

diff --git a/drivers/net/usb/Kconfig b/drivers/net/usb/Kconfig
index 3dd490f53e48..f28bd74ac275 100644
--- a/drivers/net/usb/Kconfig
+++ b/drivers/net/usb/Kconfig
@@ -369,7 +369,7 @@ config USB_NET_NET1080
 	  optionally with LEDs that indicate traffic
 
 config USB_NET_PLUSB
-	tristate "Prolific PL-2301/2302/25A1 based cables"
+	tristate "Prolific PL-2301/2302/25A1/27A1 based cables"
 	# if the handshake/init/reset problems, from original 'plusb',
 	# are ever resolved ... then remove "experimental"
 	depends on USB_USBNET
diff --git a/drivers/net/usb/plusb.c b/drivers/net/usb/plusb.c
index 22e1a9a99a7d..6fe59373cba9 100644
--- a/drivers/net/usb/plusb.c
+++ b/drivers/net/usb/plusb.c
@@ -102,7 +102,7 @@ static int pl_reset(struct usbnet *dev)
 }
 
 static const struct driver_info	prolific_info = {
-	.description =	"Prolific PL-2301/PL-2302/PL-25A1",
+	.description =	"Prolific PL-2301/PL-2302/PL-25A1/PL-27A1",
 	.flags =	FLAG_POINTTOPOINT | FLAG_NO_SETINT,
 		/* some PL-2302 versions seem to fail usb_set_interface() */
 	.reset =	pl_reset,
@@ -139,6 +139,17 @@ static const struct usb_device_id	products [] = {
 					 * Host-to-Host Cable
 					 */
 	.driver_info =  (unsigned long) &prolific_info,
+
+},
+
+/* super speed cables */
+{
+	USB_DEVICE(0x067b, 0x27a1),     /* PL-27A1, no eeprom
+					 * also: goobay Active USB 3.0
+					 * Data Link,
+					 * Unitek Y-3501
+					 */
+	.driver_info =  (unsigned long) &prolific_info,
 },
 
 	{ },		// END
@@ -158,5 +169,5 @@ static struct usb_driver plusb_driver = {
 module_usb_driver(plusb_driver);
 
 MODULE_AUTHOR("David Brownell");
-MODULE_DESCRIPTION("Prolific PL-2301/2302/25A1 USB Host to Host Link Driver");
+MODULE_DESCRIPTION("Prolific PL-2301/2302/25A1/27A1 USB Host to Host Link Driver");
 MODULE_LICENSE("GPL");
-- 
2.12.2
