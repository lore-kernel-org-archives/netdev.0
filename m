From: =?UTF-8?q?Bj=C3=B8rn=20Mork?= <bjorn@mork.no>
Subject: [PATCH RESEND net-next] net: usbnet: update addr_assign_type if appropriate
Date: Wed,  4 Sep 2013 09:42:32 +0200
Message-ID: <1378280552-12632-1-git-send-email-bjorn@mork.no>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-usb@vger.kernel.org,
	=?UTF-8?q?Bj=C3=B8rn=20Mork?= <bjorn@mork.no>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from canardo.mork.no ([148.122.252.1]:33937 "EHLO canardo.mork.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756333Ab3IDHnM (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 4 Sep 2013 03:43:12 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This module generates a common default address on init,
using eth_random_addr. Set addr_assign_type to let
userspace know the address is random unless it was
overridden by the minidriver.

Signed-off-by: Bj=C3=B8rn Mork <bjorn@mork.no>
Acked-by: Oliver Neukum <oliver@neukum.org>
---
Sorry this patch missed the "addr_assign_type series" where it should
have been.

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
