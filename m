From: Bjorn Mork <bjorn-yOkvZcmFvRU@public.gmane.org>
Subject: [PATCH 2/3] cdc_ether: allow vendor specific data interface if control interface is vendor specific
Date: Tue, 13 Dec 2011 05:33:03 +0100
Message-ID: <1323750784-32608-3-git-send-email-bjorn@mork.no>
References: <1323750784-32608-1-git-send-email-bjorn@mork.no>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: =?UTF-8?q?Bj=C3=B8rn=20Mork?= <bjorn-yOkvZcmFvRU@public.gmane.org>
To: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1323750784-32608-1-git-send-email-bjorn-yOkvZcmFvRU@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

=46rom: Bj=C3=B8rn Mork <bjorn-yOkvZcmFvRU@public.gmane.org>

Some vendors, like Huawei, use the vendor specific class code all over =
the
place even for devices which otherwise conform pretty well to the CDC E=
CM
specification.  This allows such devices to be supported merely by
adding them to the device specific whitelist.

Signed-off-by: Bj=C3=B8rn Mork <bjorn-yOkvZcmFvRU@public.gmane.org>
---
 drivers/net/usb/cdc_ether.c |    8 ++++++--
 1 files changed, 6 insertions(+), 2 deletions(-)

diff --git a/drivers/net/usb/cdc_ether.c b/drivers/net/usb/cdc_ether.c
index 99ed6eb..84840dd 100644
--- a/drivers/net/usb/cdc_ether.c
+++ b/drivers/net/usb/cdc_ether.c
@@ -211,8 +211,12 @@ int usbnet_generic_cdc_bind(struct usbnet *dev, st=
ruct usb_interface *intf)
=20
 			/* a data interface altsetting does the real i/o */
 			d =3D &info->data->cur_altsetting->desc;
-			if (d->bInterfaceClass !=3D USB_CLASS_CDC_DATA) {
-				dev_dbg(&intf->dev, "slave class %u\n",
+			if ((d->bInterfaceClass !=3D USB_CLASS_CDC_DATA) &&
+				/* Allow vendor specific data interface iff
+				   control interface is vendor specific */
+				!(info->control->cur_altsetting->desc.bInterfaceClass =3D=3D USB_C=
LASS_VENDOR_SPEC &&
+					d->bInterfaceClass =3D=3D USB_CLASS_VENDOR_SPEC)) {
+				dev_dbg(&intf->dev, "xslave class %u\n",
 					d->bInterfaceClass);
 				goto bad_desc;
 			}
--=20
1.7.7.3

--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
