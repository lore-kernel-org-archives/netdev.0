From: "Andrew F. Davis" <afd-l0cyMroinI0@public.gmane.org>
Subject: [PATCH] net: usb: asix88179_178a: Add support for the Belkin B2B128
Date: Mon, 26 Jun 2017 12:41:20 -0500
Message-ID: <20170626174120.1293-1-afd@ti.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        "Andrew F . Davis" <afd-l0cyMroinI0@public.gmane.org>
To: "David S . Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
        Allan Chou <allan-knRN6Y/kmf1NUHwG+Fw1Kw@public.gmane.org>,
        Geoffrey Tran <geoffrey.tran-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

The Belkin B2B128 is a USB 3.0 Hub + Gigabit Ethernet Adapter, the
Ethernet adapter uses the ASIX AX88179 USB 3.0 to Gigabit Ethernet
chip supported by this driver, add the USB ID for the same.

This patch is based on work by Geoffrey Tran <geoffrey.tran-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
who has indicated they would like this upstreamed by someone more
familiar with the upstreaming process.

Signed-off-by: Andrew F. Davis <afd-l0cyMroinI0@public.gmane.org>
---
 drivers/net/usb/ax88179_178a.c | 16 ++++++++++++++++
 1 file changed, 16 insertions(+)

diff --git a/drivers/net/usb/ax88179_178a.c b/drivers/net/usb/ax88179_178a.c
index 51cf60092a18..4037ab27734a 100644
--- a/drivers/net/usb/ax88179_178a.c
+++ b/drivers/net/usb/ax88179_178a.c
@@ -1722,6 +1722,18 @@ static const struct driver_info lenovo_info = {
 	.tx_fixup = ax88179_tx_fixup,
 };
 
+static const struct driver_info belkin_info = {
+	.description = "Belkin USB Ethernet Adapter",
+	.bind	= ax88179_bind,
+	.unbind = ax88179_unbind,
+	.status = ax88179_status,
+	.link_reset = ax88179_link_reset,
+	.reset	= ax88179_reset,
+	.flags	= FLAG_ETHER | FLAG_FRAMING_AX,
+	.rx_fixup = ax88179_rx_fixup,
+	.tx_fixup = ax88179_tx_fixup,
+};
+
 static const struct usb_device_id products[] = {
 {
 	/* ASIX AX88179 10/100/1000 */
@@ -1751,6 +1763,10 @@ static const struct usb_device_id products[] = {
 	/* Lenovo OneLinkDock Gigabit LAN */
 	USB_DEVICE(0x17ef, 0x304b),
 	.driver_info = (unsigned long)&lenovo_info,
+}, {
+	/* Belkin B2B128 USB 3.0 Hub + Gigabit Ethernet Adapter */
+	USB_DEVICE(0x050d, 0x0128),
+	.driver_info = (unsigned long)&belkin_info,
 },
 	{ },
 };
-- 
2.13.0

--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
