From: =?UTF-8?q?Bj=C3=B8rn=20Mork?= <bjorn-yOkvZcmFvRU@public.gmane.org>
Subject: [PATCH net-next 5/5] net: cdc_mbim: fixup error return value
Date: Fri,  1 Nov 2013 14:18:56 +0100
Message-ID: <1383311936-20954-6-git-send-email-bjorn@mork.no>
References: <1383311936-20954-1-git-send-email-bjorn@mork.no>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: =?UTF-8?q?Bj=C3=B8rn=20Mork?= <bjorn-yOkvZcmFvRU@public.gmane.org>,
	linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Oliver Neukum <oneukum-l3A5Bk7waGM@public.gmane.org>
To: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1383311936-20954-1-git-send-email-bjorn-yOkvZcmFvRU@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Reported-by: Oliver Neukum <oneukum-l3A5Bk7waGM@public.gmane.org>
Signed-off-by: Bj=C3=B8rn Mork <bjorn-yOkvZcmFvRU@public.gmane.org>
---
 drivers/net/usb/cdc_mbim.c |    6 ++----
 1 file changed, 2 insertions(+), 4 deletions(-)

diff --git a/drivers/net/usb/cdc_mbim.c b/drivers/net/usb/cdc_mbim.c
index 862d137..166e195 100644
--- a/drivers/net/usb/cdc_mbim.c
+++ b/drivers/net/usb/cdc_mbim.c
@@ -311,15 +311,13 @@ error:
=20
 static int cdc_mbim_suspend(struct usb_interface *intf, pm_message_t m=
essage)
 {
-	int ret =3D 0;
+	int ret =3D -ENODEV;
 	struct usbnet *dev =3D usb_get_intfdata(intf);
 	struct cdc_mbim_state *info =3D (void *)&dev->data;
 	struct cdc_ncm_ctx *ctx =3D info->ctx;
=20
-	if (ctx =3D=3D NULL) {
-		ret =3D -1;
+	if (!ctx)
 		goto error;
-	}
=20
 	/*
 	 * Both usbnet_suspend() and subdriver->suspend() MUST return 0
--=20
1.7.10.4

--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
