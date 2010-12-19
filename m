From: Andreas Mohr <andi@lisas.de>
Subject: [PATCH] net: Add USB PID for new MOSCHIP USB ethernet controller
 MCS7832 variant
Date: Sun, 19 Dec 2010 16:42:57 +0100
Message-ID: <20101219154257.GA29086@rhlx01.hs-esslingen.de>
References: <20101130200737.GA5185@rhlx01.hs-esslingen.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Arnd Bergmann <arnd@arndb.de>, dhollis@davehollis.com,
	Phil Chang <pchang23@sbcglobal.net>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20101130200737.GA5185@rhlx01.hs-esslingen.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Due to active notification of the new MCS7832 version by the manufacturer
(Mr. Milton; thanks!) -- quote: "functionality same as MCS7830",
I'm now submitting this patch (on -rc6), intended for networking.git and -stable.

- add MCS7832 USB PID to be able to support this new device variant, too
- add related descriptions

Signed-off-by: Andreas Mohr <andi@lisas.de>
Cc: stable@kernel.org
---
Patch created, "semi"-tested (via my existing MCS7830 only),
checkpatch.pl'd.
GIT history seems clean, should thus apply easily.

Took longer (it's that time of the year again).

Thanks!

diff --git a/drivers/net/usb/mcs7830.c b/drivers/net/usb/mcs7830.c
index a6281e3..b701f59 100644
--- a/drivers/net/usb/mcs7830.c
+++ b/drivers/net/usb/mcs7830.c
@@ -1,5 +1,5 @@
 /*
- * MOSCHIP MCS7830 based USB 2.0 Ethernet Devices
+ * MOSCHIP MCS7830 based (7730/7830/7832) USB 2.0 Ethernet Devices
  *
  * based on usbnet.c, asix.c and the vendor provided mcs7830 driver
  *
@@ -11,6 +11,9 @@
  *
  * Definitions gathered from MOSCHIP, Data Sheet_7830DA.pdf (thanks!).
  *
+ * 2010-12-19: add 7832 USB PID ("functionality same as MCS7830"),
+ *             per active notification by manufacturer
+ *
  * TODO:
  * - support HIF_REG_CONFIG_SLEEPMODE/HIF_REG_CONFIG_TXENABLE (via autopm?)
  * - implement ethtool_ops get_pauseparam/set_pauseparam
@@ -60,6 +63,7 @@
 #define MCS7830_MAX_MCAST	64
 
 #define MCS7830_VENDOR_ID	0x9710
+#define MCS7832_PRODUCT_ID	0x7832
 #define MCS7830_PRODUCT_ID	0x7830
 #define MCS7730_PRODUCT_ID	0x7730
 
@@ -626,7 +630,7 @@ static int mcs7830_rx_fixup(struct usbnet *dev, struct sk_buff *skb)
 }
 
 static const struct driver_info moschip_info = {
-	.description	= "MOSCHIP 7830/7730 usb-NET adapter",
+	.description	= "MOSCHIP 7830/7832/7730 usb-NET adapter",
 	.bind		= mcs7830_bind,
 	.rx_fixup	= mcs7830_rx_fixup,
 	.flags		= FLAG_ETHER,
@@ -645,6 +649,10 @@ static const struct driver_info sitecom_info = {
 
 static const struct usb_device_id products[] = {
 	{
+		USB_DEVICE(MCS7830_VENDOR_ID, MCS7832_PRODUCT_ID),
+		.driver_info = (unsigned long) &moschip_info,
+	},
+	{
 		USB_DEVICE(MCS7830_VENDOR_ID, MCS7830_PRODUCT_ID),
 		.driver_info = (unsigned long) &moschip_info,
 	},
