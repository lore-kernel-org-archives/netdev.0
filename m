From: =?UTF-8?q?Bj=C3=B8rn=20Mork?= <bjorn-yOkvZcmFvRU@public.gmane.org>
Subject: [PATCH net-next 2/5] net: qmi_wwan: manage_power should always set needs_remote_wakeup
Date: Fri,  1 Nov 2013 14:18:53 +0100
Message-ID: <1383311936-20954-3-git-send-email-bjorn@mork.no>
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
 drivers/net/usb/qmi_wwan.c |   10 ++++------
 1 file changed, 4 insertions(+), 6 deletions(-)

diff --git a/drivers/net/usb/qmi_wwan.c b/drivers/net/usb/qmi_wwan.c
index e0a4a2b..5dd0d85 100644
--- a/drivers/net/usb/qmi_wwan.c
+++ b/drivers/net/usb/qmi_wwan.c
@@ -149,7 +149,7 @@ static const struct net_device_ops qmi_wwan_netdev_=
ops =3D {
 static int qmi_wwan_manage_power(struct usbnet *dev, int on)
 {
 	struct qmi_wwan_state *info =3D (void *)&dev->data;
-	int rv =3D 0;
+	int rv;
=20
 	dev_dbg(&dev->intf->dev, "%s() pmcount=3D%d, on=3D%d\n", __func__,
 		atomic_read(&info->pmcount), on);
@@ -160,13 +160,11 @@ static int qmi_wwan_manage_power(struct usbnet *d=
ev, int on)
 		 * the new value
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
 static int qmi_wwan_cdc_wdm_manage_power(struct usb_interface *intf, i=
nt on)
--=20
1.7.10.4

--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
