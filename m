From: =?UTF-8?q?Bj=C3=B8rn=20Mork?= <bjorn-yOkvZcmFvRU@public.gmane.org>
Subject: [PATCH] net: qmi_wwan: adding Huawei E367, ZTE MF683 and Pantech P4200
Date: Wed, 19 Sep 2012 22:03:36 +0200
Message-ID: <1348085016-30850-1-git-send-email-bjorn@mork.no>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	=?UTF-8?q?Bj=C3=B8rn=20Mork?= <bjorn-yOkvZcmFvRU@public.gmane.org>,
	"Fangxiaozhi (Franko)" <fangxiaozhi-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>,
	=?UTF-8?q?Thomas=20Sch=C3=A4fer?= <tschaefer-zqRNUXuvxA0b1SvskN2V4Q@public.gmane.org>,
	Dan Williams <dcbw-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>,
	"Shawn J. Goff" <shawn7400-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
To: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

One of the modes of Huawei E367 has this QMI/wwan interface:

 I:* If#=3D 1 Alt=3D 0 #EPs=3D 3 Cls=3Dff(vend.) Sub=3D01 Prot=3D07 Dri=
ver=3D(none)
 E:  Ad=3D83(I) Atr=3D03(Int.) MxPS=3D  64 Ivl=3D2ms
 E:  Ad=3D84(I) Atr=3D02(Bulk) MxPS=3D 512 Ivl=3D0ms
 E:  Ad=3D02(O) Atr=3D02(Bulk) MxPS=3D 512 Ivl=3D4ms

Huawei use subclass and protocol to identify vendor specific
functions, so adding a new vendor rule for this combination.

The Pantech devices UML290 (106c:3718) and P4200 (106c:3721) use
the same subclass to identify the QMI/wwan function.  Replace the
existing device specific UML290 entries with generic vendor matching,
adding support for the Pantech P4200.

The ZTE MF683 has 6 vendor specific interfaces, all using
ff/ff/ff for cls/sub/prot.  Adding a match on interface #5 which
is a QMI/wwan interface.

Cc: Fangxiaozhi (Franko) <fangxiaozhi-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>
Cc: Thomas Sch=C3=A4fer <tschaefer-zqRNUXuvxA0b1SvskN2V4Q@public.gmane.org>
Cc: Dan Williams <dcbw-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Cc: Shawn J. Goff <shawn7400-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Signed-off-by: Bj=C3=B8rn Mork <bjorn-yOkvZcmFvRU@public.gmane.org>
---
 drivers/net/usb/qmi_wwan.c |   11 ++++++++---
 1 file changed, 8 insertions(+), 3 deletions(-)

diff --git a/drivers/net/usb/qmi_wwan.c b/drivers/net/usb/qmi_wwan.c
index b1ba68f..3543c9e 100644
--- a/drivers/net/usb/qmi_wwan.c
+++ b/drivers/net/usb/qmi_wwan.c
@@ -366,16 +366,20 @@ static const struct usb_device_id products[] =3D =
{
 	},
=20
 	/* 2. Combined interface devices matching on class+protocol */
+	{	/* Huawei E367 and possibly others in "Windows mode" */
+		USB_VENDOR_AND_INTERFACE_INFO(HUAWEI_VENDOR_ID, USB_CLASS_VENDOR_SPE=
C, 1, 7),
+		.driver_info        =3D (unsigned long)&qmi_wwan_info,
+	},
 	{	/* Huawei E392, E398 and possibly others in "Windows mode" */
 		USB_VENDOR_AND_INTERFACE_INFO(HUAWEI_VENDOR_ID, USB_CLASS_VENDOR_SPE=
C, 1, 17),
 		.driver_info        =3D (unsigned long)&qmi_wwan_shared,
 	},
-	{	/* Pantech UML290 */
-		USB_DEVICE_AND_INTERFACE_INFO(0x106c, 0x3718, USB_CLASS_VENDOR_SPEC,=
 0xf0, 0xff),
+	{	/* Pantech UML290, P4200 and more */
+		USB_VENDOR_AND_INTERFACE_INFO(0x106c, USB_CLASS_VENDOR_SPEC, 0xf0, 0=
xff),
 		.driver_info        =3D (unsigned long)&qmi_wwan_shared,
 	},
 	{	/* Pantech UML290 - newer firmware */
-		USB_DEVICE_AND_INTERFACE_INFO(0x106c, 0x3718, USB_CLASS_VENDOR_SPEC,=
 0xf1, 0xff),
+		USB_VENDOR_AND_INTERFACE_INFO(0x106c, USB_CLASS_VENDOR_SPEC, 0xf1, 0=
xff),
 		.driver_info        =3D (unsigned long)&qmi_wwan_shared,
 	},
=20
@@ -383,6 +387,7 @@ static const struct usb_device_id products[] =3D {
 	{QMI_FIXED_INTF(0x19d2, 0x0055, 1)},	/* ZTE (Vodafone) K3520-Z */
 	{QMI_FIXED_INTF(0x19d2, 0x0063, 4)},	/* ZTE (Vodafone) K3565-Z */
 	{QMI_FIXED_INTF(0x19d2, 0x0104, 4)},	/* ZTE (Vodafone) K4505-Z */
+	{QMI_FIXED_INTF(0x19d2, 0x0157, 5)},	/* ZTE MF683 */
 	{QMI_FIXED_INTF(0x19d2, 0x0167, 4)},	/* ZTE MF820D */
 	{QMI_FIXED_INTF(0x19d2, 0x0326, 4)},	/* ZTE MF821D */
 	{QMI_FIXED_INTF(0x19d2, 0x1008, 4)},	/* ZTE (Vodafone) K3570-Z */
--=20
1.7.10.4

--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
