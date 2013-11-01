From: =?UTF-8?q?Bj=C3=B8rn=20Mork?= <bjorn@mork.no>
Subject: [PATCH net-next 03/24] net: cdc_ncm: remove redundant "intf" field
Date: Fri,  1 Nov 2013 11:16:40 +0100
Message-ID: <1383301021-16613-4-git-send-email-bjorn@mork.no>
References: <1383301021-16613-1-git-send-email-bjorn@mork.no>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-usb@vger.kernel.org,
	Alexey Orishko <alexey.orishko@gmail.com>,
	=?UTF-8?q?Bj=C3=B8rn=20Mork?= <bjorn@mork.no>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from canardo.mork.no ([148.122.252.1]:49968 "EHLO canardo.mork.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755916Ab3KAKRW (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 1 Nov 2013 06:17:22 -0400
In-Reply-To: <1383301021-16613-1-git-send-email-bjorn@mork.no>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is always a duplicate of the "control" field. It causes
confusion wrt intf_data updates and cleanups.

Cc: Alexey Orishko <alexey.orishko@gmail.com>
Signed-off-by: Bj=C3=B8rn Mork <bjorn@mork.no>
---
 drivers/net/usb/cdc_ncm.c   |    4 +---
 include/linux/usb/cdc_ncm.h |    1 -
 2 files changed, 1 insertion(+), 4 deletions(-)

diff --git a/drivers/net/usb/cdc_ncm.c b/drivers/net/usb/cdc_ncm.c
index 38566bf..bfab879 100644
--- a/drivers/net/usb/cdc_ncm.c
+++ b/drivers/net/usb/cdc_ncm.c
@@ -382,7 +382,6 @@ int cdc_ncm_bind_common(struct usbnet *dev, struct =
usb_interface *intf, u8 data_
 	len =3D intf->cur_altsetting->extralen;
=20
 	ctx->udev =3D dev->udev;
-	ctx->intf =3D intf;
=20
 	/* parse through descriptors associated with control interface */
 	while ((len > 0) && (buf[0] > 2) && (buf[0] <=3D len)) {
@@ -489,7 +488,6 @@ advance:
=20
 	usb_set_intfdata(ctx->data, dev);
 	usb_set_intfdata(ctx->control, dev);
-	usb_set_intfdata(ctx->intf, dev);
=20
 	if (ctx->ether_desc) {
 		temp =3D usbnet_get_ethernet_addr(dev, ctx->ether_desc->iMACAddress)=
;
@@ -562,7 +560,7 @@ void cdc_ncm_unbind(struct usbnet *dev, struct usb_=
interface *intf)
 		ctx->control =3D NULL;
 	}
=20
-	usb_set_intfdata(ctx->intf, NULL);
+	usb_set_intfdata(intf, NULL);
 	cdc_ncm_free(ctx);
 }
 EXPORT_SYMBOL_GPL(cdc_ncm_unbind);
diff --git a/include/linux/usb/cdc_ncm.h b/include/linux/usb/cdc_ncm.h
index 89f0bbc..c14e00f 100644
--- a/include/linux/usb/cdc_ncm.h
+++ b/include/linux/usb/cdc_ncm.h
@@ -103,7 +103,6 @@ struct cdc_ncm_ctx {
 	struct usb_host_endpoint *in_ep;
 	struct usb_host_endpoint *out_ep;
 	struct usb_host_endpoint *status_ep;
-	struct usb_interface *intf;
 	struct usb_interface *control;
 	struct usb_interface *data;
=20
--=20
1.7.10.4
