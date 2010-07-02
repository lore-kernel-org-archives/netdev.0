From: Ben Hutchings <ben@decadent.org.uk>
Subject: [PATCH net-2.6 2/2] usbnet: Set parent device early for
 netdev_printk()
Date: Fri, 02 Jul 2010 23:40:50 +0100
Message-ID: <1278110450.4878.75.camel@localhost>
References: <1278110361.4878.73.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev <netdev@vger.kernel.org>,
	=?ISO-8859-1?Q?Lu=EDs?= Picciochi Oliveira <pitxyoki@gmail.com>,
	Joe Perches <joe@perches.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from shadbolt.e.decadent.org.uk ([88.96.1.126]:58236 "EHLO
	shadbolt.e.decadent.org.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753241Ab0GBWky convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 2 Jul 2010 18:40:54 -0400
In-Reply-To: <1278110361.4878.73.camel@localhost>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

netdev_printk() follows the net_device's parent device pointer, so
we must set that earlier than we previously did.

Reported-by: Lu=C3=ADs Picciochi Oliveira <pitxyoki@gmail.com>
Signed-off-by: Ben Hutchings <ben@decadent.org.uk>
---
 drivers/net/usb/usbnet.c |    5 +++--
 1 files changed, 3 insertions(+), 2 deletions(-)

diff --git a/drivers/net/usb/usbnet.c b/drivers/net/usb/usbnet.c
index a95c73d..81c76ad 100644
--- a/drivers/net/usb/usbnet.c
+++ b/drivers/net/usb/usbnet.c
@@ -1293,6 +1293,9 @@ usbnet_probe (struct usb_interface *udev, const s=
truct usb_device_id *prod)
 		goto out;
 	}
=20
+	/* netdev_printk() needs this so do it as early as possible */
+	SET_NETDEV_DEV(net, &udev->dev);
+
 	dev =3D netdev_priv(net);
 	dev->udev =3D xdev;
 	dev->intf =3D udev;
@@ -1377,8 +1380,6 @@ usbnet_probe (struct usb_interface *udev, const s=
truct usb_device_id *prod)
 		dev->rx_urb_size =3D dev->hard_mtu;
 	dev->maxpacket =3D usb_maxpacket (dev->udev, dev->out, 1);
=20
-	SET_NETDEV_DEV(net, &udev->dev);
-
 	if ((dev->driver_info->flags & FLAG_WLAN) !=3D 0)
 		SET_NETDEV_DEVTYPE(net, &wlan_type);
 	if ((dev->driver_info->flags & FLAG_WWAN) !=3D 0)
--=20
1.7.1


