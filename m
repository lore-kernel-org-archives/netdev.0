From: freddy@asix.com.tw
Subject: [PATCH 1/1] [PATCH] ax88179_178a: Correct the RX error definition in RX header
Date: Mon, 21 Oct 2013 14:37:40 +0800
Message-ID: <1382337460-2036-1-git-send-email-freddy@asix.com.tw>
Cc: Freddy Xin <freddy@asix.com.tw>
To: davem@davemloft.net, linux-usb@vger.kernel.org,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	louis@asix.com.tw, allan@asix.com.tw
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Freddy Xin <freddy@asix.com.tw>

Correct the definition of AX_RXHDR_CRC_ERR and
AX_RXHDR_DROP_ERR. They are BIT29 and BIT31 in pkt_hdr
seperately.
Add VID:DID for Samsung USB Ethernet Adapter.

Signed-off-by: Freddy Xin <freddy@asix.com.tw>
---
 drivers/net/usb/ax88179_178a.c |   23 ++++++++++++++++++++---
 1 file changed, 20 insertions(+), 3 deletions(-)

diff --git a/drivers/net/usb/ax88179_178a.c b/drivers/net/usb/ax88179_178a.c
index 3569293..846cc19 100644
--- a/drivers/net/usb/ax88179_178a.c
+++ b/drivers/net/usb/ax88179_178a.c
@@ -36,8 +36,8 @@
 #define AX_RXHDR_L4_TYPE_TCP			16
 #define AX_RXHDR_L3CSUM_ERR			2
 #define AX_RXHDR_L4CSUM_ERR			1
-#define AX_RXHDR_CRC_ERR			((u32)BIT(31))
-#define AX_RXHDR_DROP_ERR			((u32)BIT(30))
+#define AX_RXHDR_CRC_ERR			((u32)BIT(29))
+#define AX_RXHDR_DROP_ERR			((u32)BIT(31))
 #define AX_ACCESS_MAC				0x01
 #define AX_ACCESS_PHY				0x02
 #define AX_ACCESS_EEPROM			0x04
@@ -1406,6 +1406,19 @@ static const struct driver_info sitecom_info = {
 	.tx_fixup = ax88179_tx_fixup,
 };
 
+static const struct driver_info samsung_info = {
+	.description = "Samsung USB Ethernet Adapter",
+	.bind = ax88179_bind,
+	.unbind = ax88179_unbind,
+	.status = ax88179_status,
+	.link_reset = ax88179_link_reset,
+	.reset = ax88179_reset,
+	.stop = ax88179_stop,
+	.flags = FLAG_ETHER | FLAG_FRAMING_AX,
+	.rx_fixup = ax88179_rx_fixup,
+	.tx_fixup = ax88179_tx_fixup,
+};
+
 static const struct usb_device_id products[] = {
 {
 	/* ASIX AX88179 10/100/1000 */
@@ -1418,7 +1431,11 @@ static const struct usb_device_id products[] = {
 }, {
 	/* Sitecom USB 3.0 to Gigabit Adapter */
 	USB_DEVICE(0x0df6, 0x0072),
-	.driver_info = (unsigned long) &sitecom_info,
+	.driver_info = (unsigned long)&sitecom_info,
+}, {
+	/* Samsung USB Ethernet Adapter */
+	USB_DEVICE(0x04e8, 0xa100),
+	.driver_info = (unsigned long)&samsung_info,
 },
 	{ },
 };
-- 
1.7.10.4
