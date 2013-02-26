From: Glen Turner <gdt@gdt.id.au>
Subject: [PATCH] usb/net/asix_devices: Add USBNET HG20F9 ethernet dongle
Date: Tue, 26 Feb 2013 14:47:12 +1030
Message-ID: <1361852232.23197.4.camel@andromache.adelaide.aarnet.edu.au>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: linux-usb@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from eth6445.sa.adsl.internode.on.net ([150.101.30.44]:33456 "EHLO
	aix.gdt.id.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1750877Ab3BZFQG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 26 Feb 2013 00:16:06 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This USB ethernet adapter was purchased in anodyne packaging
marked "USB2.0 to LAN" from the computer store adjacent to
linux.conf.au 2013 in Canberra (Australia). A web search
shows other recent purchasers in Lancaster (UK) and Seattle
(USA). Just like an emergent virus, our age of e-commerce and
airmail allows underdocumented hardware to spread around the
world instantly using the vector of ridiculously low prices.

Paige Thompson, infected via eBay, discovered that the HG20F9
is a copy of the Asix 88772B; many viruses copy the RNA of
other viruses. See Paige's work at
<https://github.com/paigeadele/HG20F9>.
This patch uses her discovery to update the restructured Asix
driver in the current kernel.

The spread of viruses is often accompanied by rumours. It is
rumoured that the HG20F9 has extensions to to provide gigabit
ethernet. This patch does not chase that chimera.

Just as some viruses inhabit seemingly-healthy cells, the
HG20F9 uses the Vendor ID 0x066b assigned to Linksys Inc.
For the present there is no clash of Product ID 0x20f9.

Signed-off-by: Glen Turner <gdt@gdt.id.au>
---
 drivers/net/usb/asix_devices.c |   24 ++++++++++++++++++++++++
 1 file changed, 24 insertions(+)

diff --git a/drivers/net/usb/asix_devices.c b/drivers/net/usb/asix_devices.c
index 7a6e758..649025d 100644
--- a/drivers/net/usb/asix_devices.c
+++ b/drivers/net/usb/asix_devices.c
@@ -883,6 +883,24 @@ static const struct driver_info ax88178_info = {
 	.tx_fixup = asix_tx_fixup,
 };
 
+// USBLINK 20F9 "USB 2.0 LAN" USB ethernet adapter, typically found in
+// no-name packaging.
+// USB device strings are:
+//   1: Manufacturer: USBLINK
+//   2: Product: HG20F9 USB2.0
+//   3: Serial: 000003
+// Appears to be compatible with Asix 88772B.
+static const struct driver_info hg20f9_info = {
+	.description = "HG20F9 USB 2.0 Ethernet",
+	.bind = ax88772_bind,
+	.status = asix_status,
+	.link_reset = ax88772_link_reset,
+	.reset = ax88772_reset,
+	.flags = FLAG_ETHER | FLAG_FRAMING_AX | FLAG_LINK_INTR | FLAG_MULTI_PACKET,
+	.rx_fixup = asix_rx_fixup,
+	.tx_fixup = asix_tx_fixup,
+};
+
 extern const struct driver_info ax88172a_info;
 
 static const struct usb_device_id	products [] = {
@@ -1022,6 +1040,12 @@ static const struct usb_device_id	products [] = {
 	/* ASIX 88172a demo board */
 	USB_DEVICE(0x0b95, 0x172a),
 	.driver_info = (unsigned long) &ax88172a_info,
+}, {
+	// USBLINK HG20F9 "USB 2.0 LAN"
+	// Appears to have gazumped Linksys's manufacturer ID but
+	// doesn't (yet) conflict with any known Linksys product.
+	USB_DEVICE(0x066b, 0x20f9),
+	.driver_info = (unsigned long) &hg20f9_info,
 },
 	{ },		// END
 };
-- 
1.7.10.4
