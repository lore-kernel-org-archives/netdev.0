From: =?UTF-8?q?Bj=C3=B8rn=20Mork?= <bjorn-yOkvZcmFvRU@public.gmane.org>
Subject: [PATCH net-next 14/24] net: cdc_ncm: remove ethtool ops
Date: Fri,  1 Nov 2013 11:16:51 +0100
Message-ID: <1383301021-16613-15-git-send-email-bjorn@mork.no>
References: <1383301021-16613-1-git-send-email-bjorn@mork.no>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Alexey Orishko <alexey.orishko-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	=?UTF-8?q?Bj=C3=B8rn=20Mork?= <bjorn-yOkvZcmFvRU@public.gmane.org>
To: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1383301021-16613-1-git-send-email-bjorn-yOkvZcmFvRU@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

No need to keep this code duplicated from usbnet.

Cc: Alexey Orishko <alexey.orishko-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Signed-off-by: Bj=C3=B8rn Mork <bjorn-yOkvZcmFvRU@public.gmane.org>
---
 drivers/net/usb/cdc_ncm.c |   26 --------------------------
 1 file changed, 26 deletions(-)

diff --git a/drivers/net/usb/cdc_ncm.c b/drivers/net/usb/cdc_ncm.c
index c90d843..8fc1a06 100644
--- a/drivers/net/usb/cdc_ncm.c
+++ b/drivers/net/usb/cdc_ncm.c
@@ -53,8 +53,6 @@
 #include <linux/usb/cdc.h>
 #include <linux/usb/cdc_ncm.h>
=20
-#define	DRIVER_VERSION				"14-Mar-2012"
-
 #if IS_ENABLED(CONFIG_USB_NET_CDC_MBIM)
 static bool prefer_mbim =3D true;
 #else
@@ -68,18 +66,6 @@ static void cdc_ncm_tx_timeout_start(struct cdc_ncm_=
ctx *ctx);
 static enum hrtimer_restart cdc_ncm_tx_timer_cb(struct hrtimer *hr_tim=
er);
 static struct usb_driver cdc_ncm_driver;
=20
-static void
-cdc_ncm_get_drvinfo(struct net_device *net, struct ethtool_drvinfo *in=
fo)
-{
-	struct usbnet *dev =3D netdev_priv(net);
-
-	strlcpy(info->driver, dev->driver_name, sizeof(info->driver));
-	strlcpy(info->version, DRIVER_VERSION, sizeof(info->version));
-	strlcpy(info->fw_version, dev->driver_info->description,
-		sizeof(info->fw_version));
-	usb_make_path(dev->udev, info->bus_info, sizeof(info->bus_info));
-}
-
 static u8 cdc_ncm_setup(struct usbnet *dev)
 {
 	struct cdc_ncm_ctx *ctx =3D (struct cdc_ncm_ctx *)dev->data[0];
@@ -360,16 +346,6 @@ static void cdc_ncm_free(struct cdc_ncm_ctx *ctx)
 	kfree(ctx);
 }
=20
-static const struct ethtool_ops cdc_ncm_ethtool_ops =3D {
-	.get_drvinfo =3D cdc_ncm_get_drvinfo,
-	.get_link =3D usbnet_get_link,
-	.get_msglevel =3D usbnet_get_msglevel,
-	.set_msglevel =3D usbnet_set_msglevel,
-	.get_settings =3D usbnet_get_settings,
-	.set_settings =3D usbnet_set_settings,
-	.nway_reset =3D usbnet_nway_reset,
-};
-
 int cdc_ncm_bind_common(struct usbnet *dev, struct usb_interface *intf=
, u8 data_altsetting)
 {
 	const struct usb_cdc_union_desc *union_desc =3D NULL;
@@ -499,8 +475,6 @@ advance:
 	if (cdc_ncm_setup(dev))
 		goto error2;
=20
-	dev->net->ethtool_ops =3D &cdc_ncm_ethtool_ops;
