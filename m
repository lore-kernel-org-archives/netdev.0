From: =?UTF-8?q?Bj=C3=B8rn=20Mork?= <bjorn@mork.no>
Subject: [PATCH net-next 13/24] net: cdc_ncm: remove probe and disconnect wrappers
Date: Fri,  1 Nov 2013 11:16:50 +0100
Message-ID: <1383301021-16613-14-git-send-email-bjorn@mork.no>
References: <1383301021-16613-1-git-send-email-bjorn@mork.no>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-usb@vger.kernel.org,
	Alexey Orishko <alexey.orishko@gmail.com>,
	=?UTF-8?q?Bj=C3=B8rn=20Mork?= <bjorn@mork.no>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from canardo.mork.no ([148.122.252.1]:49987 "EHLO canardo.mork.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755939Ab3KAKRY (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 1 Nov 2013 06:17:24 -0400
In-Reply-To: <1383301021-16613-1-git-send-email-bjorn@mork.no>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

These functions were merely wrappers around the usbnet
variants.  Remove them.

Cc: Alexey Orishko <alexey.orishko@gmail.com>
Signed-off-by: Bj=C3=B8rn Mork <bjorn@mork.no>
---
 drivers/net/usb/cdc_ncm.c |   20 ++------------------
 1 file changed, 2 insertions(+), 18 deletions(-)

diff --git a/drivers/net/usb/cdc_ncm.c b/drivers/net/usb/cdc_ncm.c
index 42c8620..c90d843 100644
--- a/drivers/net/usb/cdc_ncm.c
+++ b/drivers/net/usb/cdc_ncm.c
@@ -1141,22 +1141,6 @@ static int cdc_ncm_check_connect(struct usbnet *=
dev)
 	return !ctx->connected;
 }
=20
-static int
-cdc_ncm_probe(struct usb_interface *udev, const struct usb_device_id *=
prod)
-{
-	return usbnet_probe(udev, prod);
-}
-
-static void cdc_ncm_disconnect(struct usb_interface *intf)
-{
-	struct usbnet *dev =3D usb_get_intfdata(intf);
-
-	if (dev =3D=3D NULL)
-		return;		/* already disconnected */
-
-	usbnet_disconnect(intf);
-}
-
 static const struct driver_info cdc_ncm_info =3D {
 	.description =3D "CDC NCM",
 	.flags =3D FLAG_POINTTOPOINT | FLAG_NO_SETINT | FLAG_MULTI_PACKET,
@@ -1267,8 +1251,8 @@ MODULE_DEVICE_TABLE(usb, cdc_devs);
 static struct usb_driver cdc_ncm_driver =3D {
 	.name =3D "cdc_ncm",
 	.id_table =3D cdc_devs,
-	.probe =3D cdc_ncm_probe,
-	.disconnect =3D cdc_ncm_disconnect,
+	.probe =3D usbnet_probe,
+	.disconnect =3D usbnet_disconnect,
 	.suspend =3D usbnet_suspend,
 	.resume =3D usbnet_resume,
 	.reset_resume =3D	usbnet_resume,
--=20
1.7.10.4
