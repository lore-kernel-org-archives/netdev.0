From: Allan Chou <allan-knRN6Y/kmf1NUHwG+Fw1Kw@public.gmane.org>
Subject: [PATCH v2] Net Driver: Add Cypress GX3 VID=04b4 PID=3610.
Date: Mon, 26 Sep 2016 15:48:03 -0600
Message-ID: <271e26e7350f418bad08761cab439005@Mail06.usask.ca>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Allan Chou <allan-knRN6Y/kmf1NUHwG+Fw1Kw@public.gmane.org>, Chris Roth <chris.roth-/KKvz3x1pcI@public.gmane.org>
To: <linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Chris Roth <chris.roth-/KKvz3x1pcI@public.gmane.org>

Add support for Cypress GX3 SuperSpeed to Gigabit Ethernet
Bridge Controller (Vendor=04b4 ProdID=3610).

Patch verified on x64 linux kernel 4.7.4 system with the
Kensington SD4600P USB-C Universal Dock with Power, which uses the
Cypress GX3 SuperSpeed to Gigabit Ethernet Bridge Controller.

A similar patch was signed-off and tested-by Allan Chou
<allan-knRN6Y/kmf1NUHwG+Fw1Kw@public.gmane.org> on 2015-12-01.

Allan verified his similar patch on x86 Linux kernel 4.1.6 system
with Cypress GX3 SuperSpeed to Gigabit Ethernet Bridge Controller.

Tested-by: Allan Chou <allan-knRN6Y/kmf1NUHwG+Fw1Kw@public.gmane.org>
Tested-by: Chris Roth <chris.roth-/KKvz3x1pcI@public.gmane.org>

Signed-off-by: Allan Chou <allan-knRN6Y/kmf1NUHwG+Fw1Kw@public.gmane.org>
Signed-off-by: Chris Roth <chris.roth-/KKvz3x1pcI@public.gmane.org>
---
 drivers/net/usb/ax88179_178a.c | 17 +++++++++++++++++
 1 file changed, 17 insertions(+)

diff --git a/drivers/net/usb/ax88179_178a.c b/drivers/net/usb/ax88179_178a.c
index e6338c1..8a6675d 100644
--- a/drivers/net/usb/ax88179_178a.c
+++ b/drivers/net/usb/ax88179_178a.c
@@ -1656,6 +1656,19 @@ static const struct driver_info ax88178a_info = {
 	.tx_fixup = ax88179_tx_fixup,
 };
 
+static const struct driver_info cypress_GX3_info = {
+	.description = "Cypress GX3 SuperSpeed to Gigabit Ethernet Controller",
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
 static const struct driver_info dlink_dub1312_info = {
 	.description = "D-Link DUB-1312 USB 3.0 to Gigabit Ethernet Adapter",
 	.bind = ax88179_bind,
@@ -1718,6 +1731,10 @@ static const struct usb_device_id products[] = {
 	USB_DEVICE(0x0b95, 0x178a),
 	.driver_info = (unsigned long)&ax88178a_info,
 }, {
+	/* Cypress GX3 SuperSpeed to Gigabit Ethernet Bridge Controller */
+	USB_DEVICE(0x04b4, 0x3610),
+	.driver_info = (unsigned long)&cypress_GX3_info,
+}, {
 	/* D-Link DUB-1312 USB 3.0 to Gigabit Ethernet Adapter */
 	USB_DEVICE(0x2001, 0x4a00),
 	.driver_info = (unsigned long)&dlink_dub1312_info,
-- 
2.7.4

--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
