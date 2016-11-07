From: Chris Roth <chris.roth@usask.ca>
Subject: [PATCH v4] Net Driver: Add Cypress GX3 VID=04b4 PID=3610.
Date: Mon, 7 Nov 2016 16:44:20 -0600
Message-ID: <CAPZMiRa0kYyPFQ77L5y4NgxxH85iuMAjODV2iCzd-5OjyGfNuw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: Allan Chou <allan@asix.com.tw>,
        Artjom Simon <artjom.simon@gmail.com>
To: <linux-usb@vger.kernel.org>, <netdev@vger.kernel.org>,
        <linux-kernel@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Allan Chou <allan@asix.com.tw>

Add support for Cypress GX3 SuperSpeed to Gigabit Ethernet
Bridge Controller (Vendor=04b4 ProdID=3610).

Patch verified on x64 linux kernel 4.7.4, 4.8.6, 4.9-rc4 systems
with the Kensington SD4600P USB-C Universal Dock with Power,
which uses the Cypress GX3 SuperSpeed to Gigabit Ethernet Bridge
Controller.

A similar patch was signed-off and tested-by Allan Chou
<allan@asix.com.tw> on 2015-12-01.

Allan verified his similar patch on x86 Linux kernel 4.1.6 system
with Cypress GX3 SuperSpeed to Gigabit Ethernet Bridge Controller.

Tested-by: Allan Chou <allan@asix.com.tw>
Tested-by: Chris Roth <chris.roth@usask.ca>
Tested-by: Artjom Simon <artjom.simon@gmail.com>

Signed-off-by: Allan Chou <allan@asix.com.tw>
Signed-off-by: Chris Roth <chris.roth@usask.ca>
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
+    .description = "Cypress GX3 SuperSpeed to Gigabit Ethernet Controller",
+    .bind = ax88179_bind,
+    .unbind = ax88179_unbind,
+    .status = ax88179_status,
+    .link_reset = ax88179_link_reset,
+    .reset = ax88179_reset,
+    .stop = ax88179_stop,
+    .flags = FLAG_ETHER | FLAG_FRAMING_AX,
+    .rx_fixup = ax88179_rx_fixup,
+    .tx_fixup = ax88179_tx_fixup,
+};
+
 static const struct driver_info dlink_dub1312_info = {
     .description = "D-Link DUB-1312 USB 3.0 to Gigabit Ethernet Adapter",
     .bind = ax88179_bind,
@@ -1718,6 +1731,10 @@ static const struct usb_device_id products[] = {
     , USB_DEVICE(0x0b95, 0x178a),
     .driver_info = (unsigned long)&ax88178a_info,
 }, {
+    /* Cypress GX3 SuperSpeed to Gigabit Ethernet Bridge Controller */
+    USB_DEVICE(0x04b4, 0x3610),
+    .driver_info = (unsigned long)&cypress_GX3_info,
+}, {
     /* D-Link DUB-1312 USB 3.0 to Gigabit Ethernet Adapter */
     USB_DEVICE(0x2001, 0x4a00),
     .driver_info = (unsigned long)&dlink_dub1312_info,
-- 
2.7.4
