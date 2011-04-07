From: Simon Wood <simon@mungewell.org>
Subject: [PatchV3 2/3] usb: plusb: Add support for PL-25A1
Date: Thu,  7 Apr 2011 00:40:14 -0700
Message-ID: <1302162015-22504-2-git-send-email-simon@mungewell.org>
References: <1301456667-1648-1-git-send-email-simon@mungewell.org>
 <1302162015-22504-1-git-send-email-simon@mungewell.org>
Cc: Sergei Shtylyov <sshtylyov@mvista.com>, davem@davemloft.net,
	linux-usb@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, Simon Wood <simon@mungewell.org>
To: Greg Kroah-Hartman <gregkh@suse.de>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1302162015-22504-1-git-send-email-simon@mungewell.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: simon <simon@ubuntu.(none)>

This patch adds support for the PL-25A1 by adding the appropriate
USB ID's. This chip is used in the Belkin 'Windows Easy Transfer'
Cables.

Signed-off-by: Simon Wood <simon@mungewell.org>
---
 drivers/net/usb/Kconfig |    2 +-
 drivers/net/usb/plusb.c |   22 ++++++++++++++++++++--
 2 files changed, 21 insertions(+), 3 deletions(-)

diff --git a/drivers/net/usb/Kconfig b/drivers/net/usb/Kconfig
index 3ec22c3..9d4f911 100644
--- a/drivers/net/usb/Kconfig
+++ b/drivers/net/usb/Kconfig
@@ -258,7 +258,7 @@ config USB_NET_NET1080
 	  optionally with LEDs that indicate traffic
 
 config USB_NET_PLUSB
-	tristate "Prolific PL-2301/2302 based cables"
+	tristate "Prolific PL-2301/2302/25A1 based cables"
 	# if the handshake/init/reset problems, from original 'plusb',
 	# are ever resolved ... then remove "experimental"
 	depends on USB_USBNET && EXPERIMENTAL
diff --git a/drivers/net/usb/plusb.c b/drivers/net/usb/plusb.c
index 2fe1bb5..f46aa07 100644
--- a/drivers/net/usb/plusb.c
+++ b/drivers/net/usb/plusb.c
@@ -45,6 +45,14 @@
  * seems to get wedged under load.  Prolific docs are weak, and
  * don't identify differences between PL2301 and PL2302, much less
  * anything to explain the different PL2302 versions observed.
+ *
+ * NOTE:  pl2501 has several modes, including pl2301 and pl2302
+ * compatibility.   Some docs suggest the difference between 2301
+ * and 2302 is only to make MS-Windows use a different driver...
+ *
+ * pl25a1 glue based on patch from Tony Gibbs.  Prolific "docs" on
+ * this chip are as usual incomplete about what control messages
+ * are supported.
  */
 
 /*
@@ -95,7 +103,7 @@ static int pl_reset(struct usbnet *dev)
 }
 
 static const struct driver_info	prolific_info = {
-	.description =	"Prolific PL-2301/PL-2302",
+	.description =	"Prolific PL-2301/PL-2302/PL-25A1",
 	.flags =	FLAG_POINTTOPOINT | FLAG_NO_SETINT,
 		/* some PL-2302 versions seem to fail usb_set_interface() */
 	.reset =	pl_reset,
@@ -111,6 +119,7 @@ static const struct driver_info	prolific_info = {
 
 static const struct usb_device_id	products [] = {
 
+/* full speed cables */
 {
 	USB_DEVICE(0x067b, 0x0000),	// PL-2301
 	.driver_info =	(unsigned long) &prolific_info,
@@ -119,6 +128,15 @@ static const struct usb_device_id	products [] = {
 	.driver_info =	(unsigned long) &prolific_info,
 },
 
+/* high speed cables */
+{
+	USB_DEVICE(0x067b, 0x25a1),     /* PL-25A1, no eeprom */
+	.driver_info =  (unsigned long) &prolific_info,
+}, {
+	USB_DEVICE(0x050d, 0x258a),     /* Belkin F5U258/F5U279 (PL-25A1) */
+	.driver_info =  (unsigned long) &prolific_info,
+},
+
 	{ },		// END
 };
 MODULE_DEVICE_TABLE(usb, products);
@@ -145,5 +163,5 @@ static void __exit plusb_exit(void)
 module_exit(plusb_exit);
 
 MODULE_AUTHOR("David Brownell");
-MODULE_DESCRIPTION("Prolific PL-2301/2302 USB Host to Host Link Driver");
+MODULE_DESCRIPTION("Prolific PL-2301/2302/25A1 USB Host to Host Link Driver");
 MODULE_LICENSE("GPL");
-- 
1.7.4.1
