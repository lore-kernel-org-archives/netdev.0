From: =?UTF-8?q?Bj=C3=B8rn=20Mork?= <bjorn-yOkvZcmFvRU@public.gmane.org>
Subject: [PATCH net] net: qmi_wwan: new devices: UML290 and K5006-Z
Date: Wed, 15 Aug 2012 15:42:57 +0200
Message-ID: <1345038177-29189-1-git-send-email-bjorn@mork.no>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	=?UTF-8?q?Bj=C3=B8rn=20Mork?= <bjorn-yOkvZcmFvRU@public.gmane.org>,
	Dan Williams <dcbw-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>,
	=?UTF-8?q?Thomas=20Sch=C3=A4fer?= <tschaefer-zqRNUXuvxA0b1SvskN2V4Q@public.gmane.org>
To: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Newer firmware versions for the Pantech UML290 use a different
subclass ID.  The Windows driver match on both IDs, so we do
that as well.

The ZTE (Vodafone) K5006-Z is a new device.

Cc: Dan Williams <dcbw-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Cc: Thomas Sch=C3=A4fer <tschaefer-zqRNUXuvxA0b1SvskN2V4Q@public.gmane.org>
Signed-off-by: Bj=C3=B8rn Mork <bjorn-yOkvZcmFvRU@public.gmane.org>
---
I'll prepare a backport for stable-3.4 and -3.5 once this
is in mainline, unless someone beats me to it.  Feel free
to do so :-)


 drivers/net/usb/qmi_wwan.c |    5 +++++
 1 file changed, 5 insertions(+)

diff --git a/drivers/net/usb/qmi_wwan.c b/drivers/net/usb/qmi_wwan.c
index aaa061b..328397c 100644
--- a/drivers/net/usb/qmi_wwan.c
+++ b/drivers/net/usb/qmi_wwan.c
@@ -373,6 +373,10 @@ static const struct usb_device_id products[] =3D {
 		USB_DEVICE_AND_INTERFACE_INFO(0x106c, 0x3718, USB_CLASS_VENDOR_SPEC,=
 0xf0, 0xff),
 		.driver_info        =3D (unsigned long)&qmi_wwan_shared,
 	},
+	{	/* Pantech UML290 - newer firmware */
+		USB_DEVICE_AND_INTERFACE_INFO(0x106c, 0x3718, USB_CLASS_VENDOR_SPEC,=
 0xf1, 0xff),
+		.driver_info        =3D (unsigned long)&qmi_wwan_shared,
+	},
=20
 	/* 3. Combined interface devices matching on interface number */
 	{QMI_FIXED_INTF(0x19d2, 0x0055, 1)},	/* ZTE (Vodafone) K3520-Z */
@@ -382,6 +386,7 @@ static const struct usb_device_id products[] =3D {
 	{QMI_FIXED_INTF(0x19d2, 0x0326, 4)},	/* ZTE MF821D */
 	{QMI_FIXED_INTF(0x19d2, 0x1008, 4)},	/* ZTE (Vodafone) K3570-Z */
 	{QMI_FIXED_INTF(0x19d2, 0x1010, 4)},	/* ZTE (Vodafone) K3571-Z */
+	{QMI_FIXED_INTF(0x19d2, 0x1018, 3)},	/* ZTE (Vodafone) K5006-Z */
 	{QMI_FIXED_INTF(0x19d2, 0x1402, 2)},	/* ZTE MF60 */
 	{QMI_FIXED_INTF(0x19d2, 0x2002, 4)},	/* ZTE (Vodafone) K3765-Z */
 	{QMI_FIXED_INTF(0x0f3d, 0x68a2, 8)},    /* Sierra Wireless MC7700 */
--=20
1.7.10.4

--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
