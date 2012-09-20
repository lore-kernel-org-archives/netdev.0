From: =?UTF-8?q?Bj=C3=B8rn=20Mork?= <bjorn@mork.no>
Subject: [PATCH net-next] net: qmi_wwan: adding Huawei E367, ZTE MF683 and Pantech P4200
Date: Thu, 20 Sep 2012 09:18:05 +0200
Message-ID: <1348125485-3404-1-git-send-email-bjorn@mork.no>
References: <1348085016-30850-1-git-send-email-bjorn@mork.no>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-usb@vger.kernel.org,
	=?UTF-8?q?Bj=C3=B8rn=20Mork?= <bjorn@mork.no>,
	"Fangxiaozhi (Franko)" <fangxiaozhi@huawei.com>,
	=?UTF-8?q?Thomas=20Sch=C3=A4fer?= <tschaefer@t-online.de>,
	Dan Williams <dcbw@redhat.com>,
	"Shawn J. Goff" <shawn7400@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from canardo.mork.no ([148.122.252.1]:59128 "EHLO canardo.mork.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751439Ab2ITHS1 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 20 Sep 2012 03:18:27 -0400
In-Reply-To: <1348085016-30850-1-git-send-email-bjorn@mork.no>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

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

Cc: Fangxiaozhi (Franko) <fangxiaozhi@huawei.com>
Cc: Thomas Sch=C3=A4fer <tschaefer@t-online.de>
Cc: Dan Williams <dcbw@redhat.com>
Cc: Shawn J. Goff <shawn7400@gmail.com>
Signed-off-by: Bj=C3=B8rn Mork <bjorn@mork.no>
---
Hello David,

This is the net-next version of the previously posted patch with the
same title.  I totally forgot that I had messed with the .driver_info
fields, making it impossible to apply the same patch to both net and=20
net-next.

Sorry about that.  Please apply this version to net-next.  The other
one should still be applied to net (if still possible) and stable.


Thanks,
Bj=C3=B8rn

 drivers/net/usb/qmi_wwan.c |   11 ++++++++---
 1 file changed, 8 insertions(+), 3 deletions(-)

diff --git a/drivers/net/usb/qmi_wwan.c b/drivers/net/usb/qmi_wwan.c
index e7b53f0..ca25320 100644
--- a/drivers/net/usb/qmi_wwan.c
+++ b/drivers/net/usb/qmi_wwan.c
@@ -353,16 +353,20 @@ static const struct usb_device_id products[] =3D =
{
 	},
=20
 	/* 2. Combined interface devices matching on class+protocol */
+	{       /* Huawei E367 and possibly others in "Windows mode" */
+		USB_VENDOR_AND_INTERFACE_INFO(HUAWEI_VENDOR_ID, USB_CLASS_VENDOR_SPE=
C, 1, 7),
+		.driver_info        =3D (unsigned long)&qmi_wwan_info,
+	},
 	{	/* Huawei E392, E398 and possibly others in "Windows mode" */
 		USB_VENDOR_AND_INTERFACE_INFO(HUAWEI_VENDOR_ID, USB_CLASS_VENDOR_SPE=
C, 1, 17),
 		.driver_info        =3D (unsigned long)&qmi_wwan_info,
 	},
-	{	/* Pantech UML290 */
-		USB_DEVICE_AND_INTERFACE_INFO(0x106c, 0x3718, USB_CLASS_VENDOR_SPEC,=
 0xf0, 0xff),
+	{       /* Pantech UML290, P4200 and more */
+		USB_VENDOR_AND_INTERFACE_INFO(0x106c, USB_CLASS_VENDOR_SPEC, 0xf0, 0=
xff),
 		.driver_info        =3D (unsigned long)&qmi_wwan_info,
 	},
 	{	/* Pantech UML290 - newer firmware */
-		USB_DEVICE_AND_INTERFACE_INFO(0x106c, 0x3718, USB_CLASS_VENDOR_SPEC,=
 0xf1, 0xff),
+		USB_VENDOR_AND_INTERFACE_INFO(0x106c, USB_CLASS_VENDOR_SPEC, 0xf1, 0=
xff),
 		.driver_info        =3D (unsigned long)&qmi_wwan_info,
 	},
=20
@@ -370,6 +374,7 @@ static const struct usb_device_id products[] =3D {
 	{QMI_FIXED_INTF(0x19d2, 0x0055, 1)},	/* ZTE (Vodafone) K3520-Z */
 	{QMI_FIXED_INTF(0x19d2, 0x0063, 4)},	/* ZTE (Vodafone) K3565-Z */
 	{QMI_FIXED_INTF(0x19d2, 0x0104, 4)},	/* ZTE (Vodafone) K4505-Z */
+	{QMI_FIXED_INTF(0x19d2, 0x0157, 5)},	/* ZTE MF683 */
 	{QMI_FIXED_INTF(0x19d2, 0x0167, 4)},	/* ZTE MF820D */
 	{QMI_FIXED_INTF(0x19d2, 0x0326, 4)},	/* ZTE MF821D */
 	{QMI_FIXED_INTF(0x19d2, 0x1008, 4)},	/* ZTE (Vodafone) K3570-Z */
--=20
1.7.10.4
