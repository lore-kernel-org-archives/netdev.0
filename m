From: =?UTF-8?q?Bj=C3=B8rn=20Mork?= <bjorn@mork.no>
Subject: [PATCH net 2/3] net: qmi_wwan: add Sierra Wireless devices
Date: Sun, 12 Aug 2012 21:16:31 +0200
Message-ID: <1344798992-10176-3-git-send-email-bjorn@mork.no>
References: <1344798992-10176-1-git-send-email-bjorn@mork.no>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-usb@vger.kernel.org,
	=?UTF-8?q?Bj=C3=B8rn=20Mork?= <bjorn@mork.no>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from canardo.mork.no ([148.122.252.1]:41811 "EHLO canardo.mork.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752366Ab2HLTQr (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 12 Aug 2012 15:16:47 -0400
In-Reply-To: <1344798992-10176-1-git-send-email-bjorn@mork.no>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add 6 new devices and one modified device, based on
information from laptop vendor Windows drivers.

Sony provides a driver with two new devices using
a Gobi 2k+ layout (1199:68a5 and 1199:68a9).  The
Sony driver also adds a non-standard QMI/net
interface to the already supported 1199:9011
Gobi device. We do not know whether this is an
alternate interface number or an additional
interface which might be present, but that doesn't
really matter.

Lenovo provides a driver supporting 4 new devices:
 - MC7770 (1199:901b) with standard Gobi 2k+ layout
 - MC7700 (0f3d:68a2) with layout similar to MC7710
 - MC7750 (114f:68a2) with layout similar to MC7710
 - EM7700 (1199:901c) with layout similar to MC7710

Note regaring the three devices similar to MC7710:

The Windows drivers only support interface #8 on these
devices.  The MC7710 can support QMI/net functions on
interface #19 and #20 as well, and this driver is
verified to work on interface #19 (a firmware bug is
suspected to prevent #20 from working).

We do not enable these additional interfaces until they
either show up in a Windows driver or are verified to
work in some other way.  Therefore limiting the new
devices to interface #8 for now.

Signed-off-by: Bj=C3=B8rn Mork <bjorn@mork.no>
---
 drivers/net/usb/qmi_wwan.c |    8 ++++++++
 1 file changed, 8 insertions(+)

diff --git a/drivers/net/usb/qmi_wwan.c b/drivers/net/usb/qmi_wwan.c
index c6a5873..24524b2 100644
--- a/drivers/net/usb/qmi_wwan.c
+++ b/drivers/net/usb/qmi_wwan.c
@@ -401,8 +401,11 @@ static const struct usb_device_id products[] =3D {
 	{QMI_FIXED_INTF(0x19d2, 0x1010, 4)},	/* ZTE (Vodafone) K3571-Z */
 	{QMI_FIXED_INTF(0x19d2, 0x1402, 2)},	/* ZTE MF60 */
 	{QMI_FIXED_INTF(0x19d2, 0x2002, 4)},	/* ZTE (Vodafone) K3765-Z */
+	{QMI_FIXED_INTF(0x0f3d, 0x68a2, 8)},    /* Sierra Wireless MC7700 */
+	{QMI_FIXED_INTF(0x114f, 0x68a2, 8)},    /* Sierra Wireless MC7750 */
 	{QMI_FIXED_INTF(0x1199, 0x68a2, 8)},	/* Sierra Wireless MC7710 in QMI=
 mode */
 	{QMI_FIXED_INTF(0x1199, 0x68a2, 19)},	/* Sierra Wireless MC7710 in QM=
I mode */
+	{QMI_FIXED_INTF(0x1199, 0x901c, 8)},    /* Sierra Wireless EM7700 */
=20
 	/* 4. Gobi 1000 devices */
 	{QMI_GOBI1K_DEVICE(0x05c6, 0x9212)},	/* Acer Gobi Modem Device */
@@ -430,6 +433,8 @@ static const struct usb_device_id products[] =3D {
 	{QMI_GOBI_DEVICE(0x05c6, 0x9265)},	/* Asus Gobi 2000 Modem device (VR=
305) */
 	{QMI_GOBI_DEVICE(0x05c6, 0x9235)},	/* Top Global Gobi 2000 Modem devi=
ce (VR306) */
 	{QMI_GOBI_DEVICE(0x05c6, 0x9275)},	/* iRex Technologies Gobi 2000 Mod=
em device (VR307) */
+	{QMI_GOBI_DEVICE(0x1199, 0x68a5)},	/* Sierra Wireless Modem */
+	{QMI_GOBI_DEVICE(0x1199, 0x68a9)},	/* Sierra Wireless Modem */
 	{QMI_GOBI_DEVICE(0x1199, 0x9001)},	/* Sierra Wireless Gobi 2000 Modem=
 device (VT773) */
 	{QMI_GOBI_DEVICE(0x1199, 0x9002)},	/* Sierra Wireless Gobi 2000 Modem=
 device (VT773) */
 	{QMI_GOBI_DEVICE(0x1199, 0x9003)},	/* Sierra Wireless Gobi 2000 Modem=
 device (VT773) */
@@ -441,11 +446,14 @@ static const struct usb_device_id products[] =3D =
{
 	{QMI_GOBI_DEVICE(0x1199, 0x9009)},	/* Sierra Wireless Gobi 2000 Modem=
 device (VT773) */
 	{QMI_GOBI_DEVICE(0x1199, 0x900a)},	/* Sierra Wireless Gobi 2000 Modem=
 device (VT773) */
 	{QMI_GOBI_DEVICE(0x1199, 0x9011)},	/* Sierra Wireless Gobi 2000 Modem=
 device (MC8305) */
+	{QMI_FIXED_INTF(0x1199, 0x9011, 5)},	/* alternate interface number!? =
*/
 	{QMI_GOBI_DEVICE(0x16d8, 0x8002)},	/* CMDTech Gobi 2000 Modem device =
(VU922) */
 	{QMI_GOBI_DEVICE(0x05c6, 0x9205)},	/* Gobi 2000 Modem device */
 	{QMI_GOBI_DEVICE(0x1199, 0x9013)},	/* Sierra Wireless Gobi 3000 Modem=
 device (MC8355) */
 	{QMI_GOBI_DEVICE(0x1199, 0x9015)},	/* Sierra Wireless Gobi 3000 Modem=
 device */
 	{QMI_GOBI_DEVICE(0x1199, 0x9019)},	/* Sierra Wireless Gobi 3000 Modem=
 device */
+	{QMI_GOBI_DEVICE(0x1199, 0x901b)},	/* Sierra Wireless MC7770 */
+
 	{ }					/* END */
 };
 MODULE_DEVICE_TABLE(usb, products);
--=20
1.7.10.4
