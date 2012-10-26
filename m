From: =?UTF-8?q?Bj=C3=B8rn=20Mork?= <bjorn-yOkvZcmFvRU@public.gmane.org>
Subject: [PATCH net-next] net: sierra: shut up sparse restricted type warnings
Date: Fri, 26 Oct 2012 09:44:07 +0200
Message-ID: <1351237449-23643-1-git-send-email-bjorn@mork.no>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Oliver Neukum <oliver-GvhC2dPhHPQdnm+yROfE0A@public.gmane.org>,
	=?UTF-8?q?Bj=C3=B8rn=20Mork?= <bjorn-yOkvZcmFvRU@public.gmane.org>
To: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Removes the warnings

 drivers/net/usb/sierra_net.c:343:45: warning: incorrect type in assign=
ment (different base types)
 drivers/net/usb/sierra_net.c:343:45:    expected unsigned short [unsig=
ned] [short] [usertype] <noident>
 drivers/net/usb/sierra_net.c:343:45:    got restricted __be16 [usertyp=
e] <noident>

and

 drivers/net/usb/sierra_net.c:658:18: warning: cast to restricted __le1=
6

Signed-off-by: Bj=C3=B8rn Mork <bjorn-yOkvZcmFvRU@public.gmane.org>
---
 drivers/net/usb/sierra_net.c |    4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/usb/sierra_net.c b/drivers/net/usb/sierra_net.=
c
index c27d277..2c3b82e 100644
--- a/drivers/net/usb/sierra_net.c
+++ b/drivers/net/usb/sierra_net.c
@@ -340,7 +340,7 @@ static void sierra_net_set_ctx_index(struct sierra_=
net_data *priv, u8 ctx_ix)
 	dev_dbg(&(priv->usbnet->udev->dev), "%s %d", __func__, ctx_ix);
 	priv->tx_hdr_template[0] =3D 0x3F;
 	priv->tx_hdr_template[1] =3D ctx_ix;
-	*((u16 *)&priv->tx_hdr_template[2]) =3D
+	*((__be16 *)&priv->tx_hdr_template[2]) =3D
 		cpu_to_be16(SIERRA_NET_HIP_EXT_IP_OUT_ID);
 }
=20
@@ -632,7 +632,7 @@ static int sierra_net_change_mtu(struct net_device =
*net, int new_mtu)
 static int sierra_net_get_fw_attr(struct usbnet *dev, u16 *datap)
 {
 	int result =3D 0;
-	u16 *attrdata;
+	__le16 *attrdata;
=20
 	attrdata =3D kmalloc(sizeof(*attrdata), GFP_KERNEL);
 	if (!attrdata)
--=20
1.7.10.4

--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
