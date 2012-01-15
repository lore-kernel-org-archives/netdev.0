From: =?UTF-8?q?Bj=C3=B8rn=20Mork?= <bjorn-yOkvZcmFvRU@public.gmane.org>
Subject: [PATCH v2 1/3] cdc_ether: allow vendor specific data interface if control interface is vendor specific
Date: Sun, 15 Jan 2012 07:40:35 +0100
Message-ID: <19b71374642ee38bd389048488e855e814a09914.1326607234.git.bjorn@mork.no>
References: <cover.1326607234.git.bjorn@mork.no>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: =?UTF-8?q?Bj=C3=B8rn=20Mork?= <bjorn-yOkvZcmFvRU@public.gmane.org>,
	Dan Williams <dcbw-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>,
	=?UTF-8?q?Thomas=20Sch=C3=A4fer?= <tschaefer-zqRNUXuvxA0b1SvskN2V4Q@public.gmane.org>,
	Joe Perches <joe-6d6DIl74uiNBDgjK7y7TUQ@public.gmane.org>
To: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <cover.1326607234.git.bjorn-yOkvZcmFvRU@public.gmane.org>
In-Reply-To: <cover.1326607234.git.bjorn-yOkvZcmFvRU@public.gmane.org>
References: <cover.1326607234.git.bjorn-yOkvZcmFvRU@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Some vendors, like Huawei, use the vendor specific class code all over =
the
place even for devices which otherwise conform pretty well to the CDC E=
CM
specification.  This allows such devices to be supported merely by
adding them to the device specific whitelist.

Signed-off-by: Bj=C3=B8rn Mork <bjorn-yOkvZcmFvRU@public.gmane.org>
---
Changes from v1: Removed an unintentional debug message change.  Thanks=
 to
Joe Perches for pointing that out


 drivers/net/usb/cdc_ether.c |    6 +++++-
 1 files changed, 5 insertions(+), 1 deletions(-)

diff --git a/drivers/net/usb/cdc_ether.c b/drivers/net/usb/cdc_ether.c
index 41a61ef..a14a4a3 100644
--- a/drivers/net/usb/cdc_ether.c
+++ b/drivers/net/usb/cdc_ether.c
@@ -211,7 +211,11 @@ int usbnet_generic_cdc_bind(struct usbnet *dev, st=
ruct usb_interface *intf)
=20
 			/* a data interface altsetting does the real i/o */
 			d =3D &info->data->cur_altsetting->desc;
-			if (d->bInterfaceClass !=3D USB_CLASS_CDC_DATA) {
+			if ((d->bInterfaceClass !=3D USB_CLASS_CDC_DATA) &&
+				/* Allow vendor specific data interface iff
+				   control interface is vendor specific */
+				!(info->control->cur_altsetting->desc.bInterfaceClass =3D=3D USB_C=
LASS_VENDOR_SPEC &&
+					d->bInterfaceClass =3D=3D USB_CLASS_VENDOR_SPEC)) {
 				dev_dbg(&intf->dev, "slave class %u\n",
 					d->bInterfaceClass);
 				goto bad_desc;
--=20
1.7.7.3

--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
