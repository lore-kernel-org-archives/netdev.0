From: =?UTF-8?q?Bj=C3=B8rn=20Mork?= <bjorn@mork.no>
Subject: [PATCH net 3/3] net: qmi_wwan: compress device_id list using macros
Date: Sun, 12 Aug 2012 21:16:32 +0200
Message-ID: <1344798992-10176-4-git-send-email-bjorn@mork.no>
References: <1344798992-10176-1-git-send-email-bjorn@mork.no>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-usb@vger.kernel.org,
	=?UTF-8?q?Bj=C3=B8rn=20Mork?= <bjorn@mork.no>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from canardo.mork.no ([148.122.252.1]:41812 "EHLO canardo.mork.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752309Ab2HLTQs (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 12 Aug 2012 15:16:48 -0400
In-Reply-To: <1344798992-10176-1-git-send-email-bjorn@mork.no>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Take advantage of the matching macros to make the device id
list easier to read and maintain.

Signed-off-by: Bj=C3=B8rn Mork <bjorn@mork.no>
---
 drivers/net/usb/qmi_wwan.c |   25 ++++---------------------
 1 file changed, 4 insertions(+), 21 deletions(-)

diff --git a/drivers/net/usb/qmi_wwan.c b/drivers/net/usb/qmi_wwan.c
index 24524b2..aaa061b 100644
--- a/drivers/net/usb/qmi_wwan.c
+++ b/drivers/net/usb/qmi_wwan.c
@@ -356,38 +356,21 @@ static const struct driver_info	qmi_wwan_shared =3D=
 {
 static const struct usb_device_id products[] =3D {
 	/* 1. CDC ECM like devices match on the control interface */
 	{	/* Huawei E392, E398 and possibly others sharing both device id and=
 more... */
-		.match_flags        =3D USB_DEVICE_ID_MATCH_VENDOR | USB_DEVICE_ID_M=
ATCH_INT_INFO,
-		.idVendor           =3D HUAWEI_VENDOR_ID,
-		.bInterfaceClass    =3D USB_CLASS_VENDOR_SPEC,
-		.bInterfaceSubClass =3D 1,
-		.bInterfaceProtocol =3D 9, /* CDC Ethernet *control* interface */
+		USB_VENDOR_AND_INTERFACE_INFO(HUAWEI_VENDOR_ID, USB_CLASS_VENDOR_SPE=
C, 1, 9),
 		.driver_info        =3D (unsigned long)&qmi_wwan_info,
 	},
 	{	/* Vodafone/Huawei K5005 (12d1:14c8) and similar modems */
-		.match_flags        =3D USB_DEVICE_ID_MATCH_VENDOR | USB_DEVICE_ID_M=
ATCH_INT_INFO,
-		.idVendor           =3D HUAWEI_VENDOR_ID,
-		.bInterfaceClass    =3D USB_CLASS_VENDOR_SPEC,
-		.bInterfaceSubClass =3D 1,
-		.bInterfaceProtocol =3D 57, /* CDC Ethernet *control* interface */
+		USB_VENDOR_AND_INTERFACE_INFO(HUAWEI_VENDOR_ID, USB_CLASS_VENDOR_SPE=
C, 1, 57),
 		.driver_info        =3D (unsigned long)&qmi_wwan_info,
 	},
=20
 	/* 2. Combined interface devices matching on class+protocol */
 	{	/* Huawei E392, E398 and possibly others in "Windows mode" */
-		.match_flags        =3D USB_DEVICE_ID_MATCH_VENDOR | USB_DEVICE_ID_M=
ATCH_INT_INFO,
-		.idVendor           =3D HUAWEI_VENDOR_ID,
-		.bInterfaceClass    =3D USB_CLASS_VENDOR_SPEC,
-		.bInterfaceSubClass =3D 1,
-		.bInterfaceProtocol =3D 17,
+		USB_VENDOR_AND_INTERFACE_INFO(HUAWEI_VENDOR_ID, USB_CLASS_VENDOR_SPE=
C, 1, 17),
 		.driver_info        =3D (unsigned long)&qmi_wwan_shared,
 	},
 	{	/* Pantech UML290 */
-		.match_flags	    =3D USB_DEVICE_ID_MATCH_DEVICE | USB_DEVICE_ID_MATC=
H_INT_INFO,
-		.idVendor           =3D 0x106c,
-		.idProduct          =3D 0x3718,
-		.bInterfaceClass    =3D 0xff,
-		.bInterfaceSubClass =3D 0xf0,
-		.bInterfaceProtocol =3D 0xff,
+		USB_DEVICE_AND_INTERFACE_INFO(0x106c, 0x3718, USB_CLASS_VENDOR_SPEC,=
 0xf0, 0xff),
 		.driver_info        =3D (unsigned long)&qmi_wwan_shared,
 	},
=20
--=20
1.7.10.4
