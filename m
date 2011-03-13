From: Jiri Slaby <jslaby@suse.cz>
Subject: [PATCH 1/2] NET: cdc-phonet, fix stop-queue handling
Date: Sun, 13 Mar 2011 17:54:30 +0100
Message-ID: <1300035271-8138-1-git-send-email-jslaby@suse.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: jirislaby@gmail.com, netdev@vger.kernel.org, gregkh@suse.de,
	linux-usb@vger.kernel.org, linux-kernel@vger.kernel.org,
	Jiri Slaby <jslaby@suse.cz>,
	=?UTF-8?q?R=C3=A9mi=20Denis-Courmont?=
	<remi.denis-courmont@nokia.com>
To: davem@davemloft.net
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Currently there is a warning emitted by the cdc-phonet driver:
WARNING: at include/linux/netdevice.h:1557 usbpn_probe+0x3bb/0x3f0 [cdc=
_phonet]()
Modules linked in: ...
Pid: 5877, comm: insmod Not tainted 2.6.37.3-16-desktop #1
Call Trace:
 [<ffffffff810059b9>] dump_trace+0x79/0x340
 [<ffffffff81520fdc>] dump_stack+0x69/0x6f
 [<ffffffff810580eb>] warn_slowpath_common+0x7b/0xc0
 [<ffffffffa00254fb>] usbpn_probe+0x3bb/0x3f0 [cdc_phonet]
=2E..
---[ end trace f5d3e02908603ab4 ]---
netif_stop_queue() cannot be called before register_netdev()

So remove netif_stop_queue from the probe funtction to avoid that.

Signed-off-by: Jiri Slaby <jslaby@suse.cz>
Cc: R=C3=A9mi Denis-Courmont <remi.denis-courmont@nokia.com>
Cc: David S. Miller <davem@davemloft.net>
---
 drivers/net/usb/cdc-phonet.c |    1 -
 1 files changed, 0 insertions(+), 1 deletions(-)

diff --git a/drivers/net/usb/cdc-phonet.c b/drivers/net/usb/cdc-phonet.=
c
index 109751b..4cf4e36 100644
--- a/drivers/net/usb/cdc-phonet.c
+++ b/drivers/net/usb/cdc-phonet.c
@@ -392,7 +392,6 @@ int usbpn_probe(struct usb_interface *intf, const s=
truct usb_device_id *id)
=20
 	pnd =3D netdev_priv(dev);
 	SET_NETDEV_DEV(dev, &intf->dev);
-	netif_stop_queue(dev);
=20
 	pnd->dev =3D dev;
 	pnd->usb =3D usb_get_dev(usbdev);
--=20
1.7.4.1
