From: Glen Turner <gdt@gdt.id.au>
Subject: [PATCHv2] usb/net/asix_devices: Add USBNET HG20F9 ethernet dongle
Date: Thu, 28 Feb 2013 01:02:36 +1030
Message-ID: <1361975556.13093.3.camel@ilion>
References: <1361852232.23197.4.camel@andromache.adelaide.aarnet.edu.au>
	 <20130226.172856.235525833921140241.davem@davemloft.net>
	 <20130226.172955.926853809838377302.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: gregkh@linuxfoundation.org, linux-usb@vger.kernel.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20130226.172955.926853809838377302.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This USB ethernet adapter was purchased in anodyne packaging
from the computer store adjacent to linux.conf.au 2013 in
Canberra (Australia). A web search shows other recent
purchasers in Lancaster (UK) and Seattle (USA). Just like an
emergent virus, our age of e-commerce and airmail allows
underdocumented hardware to spread around the world instantly
using the vector of ridiculously low prices.

Paige Thompson, infected via eBay, discovered that the HG20F9
is a copy of the Asix 88772B; many viruses copy the RNA of
other viruses. See Paige's work at
<https://github.com/paigeadele/HG20F9>.
This patch uses her discovery to update the restructured Asix
driver in the current kernel.

Just as some viruses inhabit seemingly-healthy cells, the
HG20F9 uses the Vendor ID 0x066b assigned to Linksys Inc.
=46or the present there is no clash of Product ID 0x20f9.

Signed-off-by: Glen Turner <gdt@gdt.id.au>
---
David,

My apologies for the patch failing to compile. I worked off Linus' GIT =
tree
from a week ago, which I now realise was ignorant. Today I downloaded
<git://git.kernel.org/pub/scm/linux/kernel/git/davem/net.git>,
modified the patch to suit, compiled with a distributor's .config (ten =
hours
on my EeePC 901), and re-tested against a range of switches and traffic=
=2E

Thanks to Bj=C3=B8rn Mork for the heads-up about comment coding style. =
I had
copied the style used throughout asix_devices.c but one never knows whe=
re
being on the bad side of an automated tool can lead, now that the creat=
or
of the Daleks can no longer protect us from robots with rigid notions
of the acceptable and the exterminatable.

-glen

 drivers/net/usb/asix_devices.c |   31 +++++++++++++++++++++++++++++++
 1 file changed, 31 insertions(+)

diff --git a/drivers/net/usb/asix_devices.c b/drivers/net/usb/asix_devi=
ces.c
index 2205dbc..7097534 100644
--- a/drivers/net/usb/asix_devices.c
+++ b/drivers/net/usb/asix_devices.c
@@ -924,6 +924,29 @@ static const struct driver_info ax88178_info =3D {
 	.tx_fixup =3D asix_tx_fixup,
 };
=20
+/*
+ * USBLINK 20F9 "USB 2.0 LAN" USB ethernet adapter, typically found in
+ * no-name packaging.
+ * USB device strings are:
+ *   1: Manufacturer: USBLINK
+ *   2: Product: HG20F9 USB2.0
+ *   3: Serial: 000003
+ * Appears to be compatible with Asix 88772B.
+ */
+static const struct driver_info hg20f9_info =3D {
+	.description =3D "HG20F9 USB 2.0 Ethernet",
+	.bind =3D ax88772_bind,
+	.unbind =3D ax88772_unbind,
+	.status =3D asix_status,
+	.link_reset =3D ax88772_link_reset,
+	.reset =3D ax88772_reset,
+	.flags =3D FLAG_ETHER | FLAG_FRAMING_AX | FLAG_LINK_INTR |
+	         FLAG_MULTI_PACKET,
+	.rx_fixup =3D asix_rx_fixup_common,
+	.tx_fixup =3D asix_tx_fixup,
+	.data =3D FLAG_EEPROM_MAC,
+};
+
 extern const struct driver_info ax88172a_info;
=20
 static const struct usb_device_id	products [] =3D {
@@ -1063,6 +1086,14 @@ static const struct usb_device_id	products [] =3D=
 {
 	/* ASIX 88172a demo board */
 	USB_DEVICE(0x0b95, 0x172a),
 	.driver_info =3D (unsigned long) &ax88172a_info,
+}, {
+	/*
+	 * USBLINK HG20F9 "USB 2.0 LAN"
+	 * Appears to have gazumped Linksys's manufacturer ID but
+	 * doesn't (yet) conflict with any known Linksys product.
+	 */
+	USB_DEVICE(0x066b, 0x20f9),
+	.driver_info =3D (unsigned long) &hg20f9_info,
 },
 	{ },		// END
 };
--=20
1.7.10.4
