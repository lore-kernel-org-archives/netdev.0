From: =?UTF-8?q?Bj=C3=B8rn=20Mork?= <bjorn-yOkvZcmFvRU@public.gmane.org>
Subject: [PATCH] net: usbnet: update addr_assign_type if appropriate
Date: Thu, 22 Aug 2013 13:45:46 +0200
Message-ID: <1377171946-19133-1-git-send-email-bjorn@mork.no>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Oliver Neukum <oneukum-l3A5Bk7waGM@public.gmane.org>,
	=?UTF-8?q?Bj=C3=B8rn=20Mork?= <bjorn-yOkvZcmFvRU@public.gmane.org>
To: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

This module generates a common default address on init,
using eth_random_addr. Set addr_assign_type to let
userspace know the address is random unless it was
overridden by the minidriver.

Signed-off-by: Bj=C3=B8rn Mork <bjorn-yOkvZcmFvRU@public.gmane.org>
---
 drivers/net/usb/usbnet.c |    4 ++++
 1 file changed, 4 insertions(+)

diff --git a/drivers/net/usb/usbnet.c b/drivers/net/usb/usbnet.c
index e4811d7..74a8e3c 100644
--- a/drivers/net/usb/usbnet.c
+++ b/drivers/net/usb/usbnet.c
@@ -1629,6 +1629,10 @@ usbnet_probe (struct usb_interface *udev, const =
struct usb_device_id *prod)
 		dev->rx_urb_size =3D dev->hard_mtu;
 	dev->maxpacket =3D usb_maxpacket (dev->udev, dev->out, 1);
=20
+	/* let userspace know we have a random address */
+	if (ether_addr_equal(net->dev_addr, node_id))
+		net->addr_assign_type =3D NET_ADDR_RANDOM;
+
 	if ((dev->driver_info->flags & FLAG_WLAN) !=3D 0)
 		SET_NETDEV_DEVTYPE(net, &wlan_type);
 	if ((dev->driver_info->flags & FLAG_WWAN) !=3D 0)
--=20
1.7.10.4

--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
