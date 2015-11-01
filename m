From: =?UTF-8?q?Bj=C3=B8rn=20Mork?= <bjorn-yOkvZcmFvRU@public.gmane.org>
Subject: [PATCH net,stable] qmi_wwan: fix entry for HP lt4112 LTE/HSPA+ Gobi 4G Module
Date: Sun,  1 Nov 2015 01:34:50 +0100
Message-ID: <1446338090-16494-1-git-send-email-bjorn@mork.no>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	=?UTF-8?q?Bj=C3=B8rn=20Mork?= <bjorn-yOkvZcmFvRU@public.gmane.org>
To: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

The lt4112 is a HP branded Huawei me906e modem. Like other Huawei
modems, it does not have a fixed interface to function mapping.
Instead it uses a Huawei specific scheme: functions are mapped by
subclass and protocol.

However, the HP vendor ID is used for modems from many different
manufacturers using different schemes, so we cannot apply a generic
vendor rule like we do for the Huawei vendor ID.

Replace the previous lt4112 entry pointing to an arbitrary interface
number with a device specific subclass + protocol match.

Reported-and-tested-by: Muri Nicanor <muri+libqmi-8Y1gJgr9kN5yDzI6CaY1VQ@public.gmane.org>
Tested-by: Martin Hauke <mardnh-Mmb7MZpHnFY@public.gmane.org>
=46ixes: bb2bdeb83fb1 ("qmi_wwan: Add support for HP lt4112 LTE/HSPA+ G=
obi 4G Modem")
Signed-off-by: Bj=C3=B8rn Mork <bjorn-yOkvZcmFvRU@public.gmane.org>
---
 drivers/net/usb/qmi_wwan.c | 5 ++++-
 1 file changed, 4 insertions(+), 1 deletion(-)

diff --git a/drivers/net/usb/qmi_wwan.c b/drivers/net/usb/qmi_wwan.c
index c2e7222f2556..434f147e67ac 100644
--- a/drivers/net/usb/qmi_wwan.c
+++ b/drivers/net/usb/qmi_wwan.c
@@ -487,6 +487,10 @@ static const struct usb_device_id products[] =3D {
 					      USB_CDC_PROTO_NONE),
 		.driver_info        =3D (unsigned long)&qmi_wwan_info,
 	},
+	{	/* HP lt4112 LTE/HSPA+ Gobi 4G Module (Huawei me906e) */
+		USB_DEVICE_AND_INTERFACE_INFO(0x03f0, 0x581d, USB_CLASS_VENDOR_SPEC,=
 1, 7),
+		.driver_info =3D (unsigned long)&qmi_wwan_info,
+	},
=20
 	/* 3. Combined interface devices matching on interface number */
 	{QMI_FIXED_INTF(0x0408, 0xea42, 4)},	/* Yota / Megafon M100-1 */
@@ -739,7 +743,6 @@ static const struct usb_device_id products[] =3D {
 	{QMI_FIXED_INTF(0x413c, 0x81a9, 8)},	/* Dell Wireless 5808e Gobi(TM) =
4G LTE Mobile Broadband Card */
 	{QMI_FIXED_INTF(0x413c, 0x81b1, 8)},	/* Dell Wireless 5809e Gobi(TM) =
4G LTE Mobile Broadband Card */
 	{QMI_FIXED_INTF(0x03f0, 0x4e1d, 8)},	/* HP lt4111 LTE/EV-DO/HSPA+ Gob=
i 4G Module */
-	{QMI_FIXED_INTF(0x03f0, 0x581d, 4)},	/* HP lt4112 LTE/HSPA+ Gobi 4G M=
odule (Huawei me906e) */
=20
 	/* 4. Gobi 1000 devices */
 	{QMI_GOBI1K_DEVICE(0x05c6, 0x9212)},	/* Acer Gobi Modem Device */
--=20
2.1.4

--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
