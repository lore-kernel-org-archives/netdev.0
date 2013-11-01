From: =?UTF-8?q?Bj=C3=B8rn=20Mork?= <bjorn-yOkvZcmFvRU@public.gmane.org>
Subject: [PATCH net-next 1/5] net: cdc_mbim: manage_power should always set needs_remote_wakeup
Date: Fri,  1 Nov 2013 14:18:52 +0100
Message-ID: <1383311936-20954-2-git-send-email-bjorn@mork.no>
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
 drivers/net/usb/cdc_mbim.c |    8 +++-----
 1 file changed, 3 insertions(+), 5 deletions(-)

diff --git a/drivers/net/usb/cdc_mbim.c b/drivers/net/usb/cdc_mbim.c
index 25ba7ec..172059e 100644
--- a/drivers/net/usb/cdc_mbim.c
+++ b/drivers/net/usb/cdc_mbim.c
@@ -42,13 +42,11 @@ static int cdc_mbim_manage_power(struct usbnet *dev=
, int on)
 	if ((on && atomic_add_return(1, &info->pmcount) =3D=3D 1) || (!on && =
atomic_dec_and_test(&info->pmcount))) {
 		/* need autopm_get/put here to ensure the usbcore sees the new value=
 */
 		rv =3D usb_autopm_get_interface(dev->intf);
-		if (rv < 0)
-			goto err;
 		dev->intf->needs_remote_wakeup =3D on;
-		usb_autopm_put_interface(dev->intf);
+		if (!rv)
+			usb_autopm_put_interface(dev->intf);
 	}
-err:
-	return rv;
+	return 0;
 }
=20
 static int cdc_mbim_wdm_manage_power(struct usb_interface *intf, int s=
tatus)
--=20
1.7.10.4

--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
