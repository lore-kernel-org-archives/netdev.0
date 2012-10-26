From: =?UTF-8?q?Bj=C3=B8rn=20Mork?= <bjorn-yOkvZcmFvRU@public.gmane.org>
Subject: [PATCH net-next] net: cdc_ncm: big endian fix
Date: Fri, 26 Oct 2012 09:44:08 +0200
Message-ID: <1351237449-23643-2-git-send-email-bjorn@mork.no>
References: <1351237449-23643-1-git-send-email-bjorn@mork.no>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Oliver Neukum <oliver-GvhC2dPhHPQdnm+yROfE0A@public.gmane.org>,
	=?UTF-8?q?Bj=C3=B8rn=20Mork?= <bjorn-yOkvZcmFvRU@public.gmane.org>
To: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1351237449-23643-1-git-send-email-bjorn-yOkvZcmFvRU@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Probably doesn't matter much since the value is used as a
boolean anyway, but it removes the sparse warning:

 drivers/net/usb/cdc_ncm.c:1090:32: warning: incorrect type in assignme=
nt (different base types)
 drivers/net/usb/cdc_ncm.c:1090:32:    expected unsigned short [unsigne=
d] [usertype] connected
 drivers/net/usb/cdc_ncm.c:1090:32:    got restricted __le16 [usertype]=
 wValue

Signed-off-by: Bj=C3=B8rn Mork <bjorn-yOkvZcmFvRU@public.gmane.org>
---
 drivers/net/usb/cdc_ncm.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/usb/cdc_ncm.c b/drivers/net/usb/cdc_ncm.c
index 0ed03b1..682b17a 100644
--- a/drivers/net/usb/cdc_ncm.c
+++ b/drivers/net/usb/cdc_ncm.c
@@ -1087,7 +1087,7 @@ static void cdc_ncm_status(struct usbnet *dev, st=
ruct urb *urb)
 		 * USB_CDC_NOTIFY_NETWORK_CONNECTION notification shall be
 		 * sent by device after USB_CDC_NOTIFY_SPEED_CHANGE.
 		 */
-		ctx->connected =3D event->wValue;
+		ctx->connected =3D le16_to_cpu(event->wValue);
=20
 		printk(KERN_INFO KBUILD_MODNAME ": %s: network connection:"
 			" %sconnected\n",
--=20
1.7.10.4

--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
