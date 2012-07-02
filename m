From: =?UTF-8?q?Bj=C3=B8rn=20Mork?= <bjorn@mork.no>
Subject: [PATCH net] net: qmi_wwan: add ZTE MF60
Date: Mon,  2 Jul 2012 19:53:17 +0200
Message-ID: <1341251597-21124-1-git-send-email-bjorn@mork.no>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: =?UTF-8?q?Bj=C3=B8rn=20Mork?= <bjorn@mork.no>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from canardo.mork.no ([148.122.252.1]:57797 "EHLO canardo.mork.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755899Ab2GBRxW (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 2 Jul 2012 13:53:22 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Adding a device with limited QMI support. It does not support
normal QMI_WDS commands for connection management. Instead,
sending a QMI_CTL SET_INSTANCE_ID command is required to
enable the network interface:

  01 0f 00 00 00 00 00 00  20 00 04 00 01 01 00 00

A number of QMI_DMS and QMI_NAS commands are also supported
for optional device management.

Signed-off-by: Bj=C3=B8rn Mork <bjorn@mork.no>
---
 drivers/net/usb/qmi_wwan.c |   18 ++++++++++++++++++
 1 file changed, 18 insertions(+)

diff --git a/drivers/net/usb/qmi_wwan.c b/drivers/net/usb/qmi_wwan.c
index b01960f..5badafd 100644
--- a/drivers/net/usb/qmi_wwan.c
+++ b/drivers/net/usb/qmi_wwan.c
@@ -346,6 +346,15 @@ static const struct driver_info	qmi_wwan_force_int=
1 =3D {
 	.data		=3D BIT(1), /* interface whitelist bitmap */
 };
=20
+static const struct driver_info	qmi_wwan_force_int2 =3D {
+	.description	=3D "Qualcomm WWAN/QMI device",
+	.flags		=3D FLAG_WWAN,
+	.bind		=3D qmi_wwan_bind_shared,
+	.unbind		=3D qmi_wwan_unbind_shared,
+	.manage_power	=3D qmi_wwan_manage_power,
+	.data		=3D BIT(2), /* interface whitelist bitmap */
+};
+
 static const struct driver_info	qmi_wwan_force_int3 =3D {
 	.description	=3D "Qualcomm WWAN/QMI device",
 	.flags		=3D FLAG_WWAN,
@@ -498,6 +507,15 @@ static const struct usb_device_id products[] =3D {
 		.bInterfaceProtocol =3D 0xff,
 		.driver_info        =3D (unsigned long)&qmi_wwan_force_int4,
 	},
+	{	/* ZTE MF60 */
+		.match_flags	    =3D USB_DEVICE_ID_MATCH_DEVICE | USB_DEVICE_ID_MATC=
H_INT_INFO,
+		.idVendor           =3D 0x19d2,
+		.idProduct          =3D 0x1402,
+		.bInterfaceClass    =3D 0xff,
+		.bInterfaceSubClass =3D 0xff,
+		.bInterfaceProtocol =3D 0xff,
+		.driver_info        =3D (unsigned long)&qmi_wwan_force_int2,
+	},
 	{	/* Sierra Wireless MC77xx in QMI mode */
 		.match_flags	    =3D USB_DEVICE_ID_MATCH_DEVICE | USB_DEVICE_ID_MATC=
H_INT_INFO,
 		.idVendor           =3D 0x1199,
--=20
1.7.10
