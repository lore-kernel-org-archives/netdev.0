From: =?UTF-8?q?Bj=C3=B8rn=20Mork?= <bjorn-yOkvZcmFvRU@public.gmane.org>
Subject: [PATCH net-next 2/2] net: sierra_net: rx_urb_size is constant
Date: Mon,  3 Sep 2012 11:20:33 +0200
Message-ID: <1346664033-30284-3-git-send-email-bjorn@mork.no>
References: <1346664033-30284-1-git-send-email-bjorn@mork.no>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	=?UTF-8?q?Bj=C3=B8rn=20Mork?= <bjorn-yOkvZcmFvRU@public.gmane.org>
To: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1346664033-30284-1-git-send-email-bjorn-yOkvZcmFvRU@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

The rx_urb_size is set to the same value for every device
supported by this driver.  No need to keep a per-device
data structure to do that. Replacing with a macro constant.

This was the last device specific info, and removing it
allows us to delete the sierra_net_info_data struct.

Signed-off-by: Bj=C3=B8rn Mork <bjorn-yOkvZcmFvRU@public.gmane.org>
---
 drivers/net/usb/sierra_net.c |   17 ++++-------------
 1 file changed, 4 insertions(+), 13 deletions(-)

diff --git a/drivers/net/usb/sierra_net.c b/drivers/net/usb/sierra_net.=
c
index 596ddaa..7ae70e9 100644
--- a/drivers/net/usb/sierra_net.c
+++ b/drivers/net/usb/sierra_net.c
@@ -68,9 +68,8 @@ static	atomic_t iface_counter =3D ATOMIC_INIT(0);
  */
 #define SIERRA_NET_USBCTL_BUF_LEN	1024
=20
-struct sierra_net_info_data {
-	u16 rx_urb_size;
-};
+/* Overriding the default usbnet rx_urb_size */
+#define SIERRA_NET_RX_URB_SIZE		(8 * 1024)
=20
 /* Private data structure */
 struct sierra_net_data {
@@ -678,9 +677,6 @@ static int sierra_net_bind(struct usbnet *dev, stru=
ct usb_interface *intf)
 	static const u8 shdwn_tmplate[sizeof(priv->shdwn_msg)] =3D {
 		0x00, 0x00, SIERRA_NET_HIP_SHUTD_ID, 0x00};
=20
-	struct sierra_net_info_data *data =3D
-			(struct sierra_net_info_data *)dev->driver_info->data;
-
 	dev_dbg(&dev->udev->dev, "%s", __func__);
=20
 	ifacenum =3D intf->cur_altsetting->desc.bInterfaceNumber;
@@ -725,9 +721,9 @@ static int sierra_net_bind(struct usbnet *dev, stru=
ct usb_interface *intf)
 	sierra_net_set_ctx_index(priv, 0);
=20
 	/* decrease the rx_urb_size and max_tx_size to 4k on USB 1.1 */
-	dev->rx_urb_size  =3D data->rx_urb_size;
+	dev->rx_urb_size  =3D SIERRA_NET_RX_URB_SIZE;
 	if (dev->udev->speed !=3D USB_SPEED_HIGH)
-		dev->rx_urb_size  =3D min_t(size_t, 4096, data->rx_urb_size);
+		dev->rx_urb_size  =3D min_t(size_t, 4096, SIERRA_NET_RX_URB_SIZE);
=20
 	dev->net->hard_header_len +=3D SIERRA_NET_HIP_EXT_HDR_LEN;
 	dev->hard_mtu =3D dev->net->mtu + dev->net->hard_header_len;
@@ -918,10 +914,6 @@ static struct sk_buff *sierra_net_tx_fixup(struct =
usbnet *dev,
 	return NULL;
 }
=20
-static const struct sierra_net_info_data sierra_net_info_data_direct_i=
p =3D {
-	.rx_urb_size =3D 8 * 1024,
-};
