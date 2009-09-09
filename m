From: =?utf-8?q?R=C3=A9mi=20Denis-Courmont?= <remi@remlab.net>
Subject: [PATCH 2/2] cdc-phonet: autoconfigure Phonet address
Date: Wed,  9 Sep 2009 13:00:06 +0300
Message-ID: <1252490406-27951-2-git-send-email-remi@remlab.net>
References: <1252490406-27951-1-git-send-email-remi@remlab.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: =?utf-8?q?R=C3=A9mi=20Denis-Courmont?=
	<remi.denis-courmont@nokia.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from yop.chewa.net ([91.121.105.214]:47715 "EHLO yop.chewa.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751622AbZIIKFt (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 9 Sep 2009 06:05:49 -0400
In-Reply-To: <1252490406-27951-1-git-send-email-remi@remlab.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: R=C3=A9mi Denis-Courmont <remi.denis-courmont@nokia.com>

Signed-off-by: R=C3=A9mi Denis-Courmont <remi.denis-courmont@nokia.com>
---
 drivers/net/usb/cdc-phonet.c |   15 +++++++++++++++
 include/linux/phonet.h       |    3 +++
 2 files changed, 18 insertions(+), 0 deletions(-)

diff --git a/drivers/net/usb/cdc-phonet.c b/drivers/net/usb/cdc-phonet.=
c
index 0ca5916..97e54d9 100644
--- a/drivers/net/usb/cdc-phonet.c
+++ b/drivers/net/usb/cdc-phonet.c
@@ -27,6 +27,7 @@
 #include <linux/netdevice.h>
 #include <linux/if_arp.h>
 #include <linux/if_phonet.h>
+#include <linux/phonet.h>
=20
 #define PN_MEDIA_USB	0x1B
=20
@@ -256,6 +257,19 @@ static int usbpn_close(struct net_device *dev)
 	return usb_set_interface(pnd->usb, num, !pnd->active_setting);
 }
=20
+static int usbpn_ioctl(struct net_device *dev, struct ifreq *ifr, int =
cmd)
+{
+	struct if_phonet_req *req =3D (struct if_phonet_req *)ifr;
+
+	switch (cmd) {
+	case SIOCPNGAUTOCONF:
+		req->ifr_phonet_autoconf.device =3D PN_DEV_PC;
+		printk(KERN_CRIT"device is PN_DEV_PC\n");
+		return 0;
+	}
+	return -ENOIOCTLCMD;
+}
+
 static int usbpn_set_mtu(struct net_device *dev, int new_mtu)
 {
 	if ((new_mtu < PHONET_MIN_MTU) || (new_mtu > PHONET_MAX_MTU))
@@ -269,6 +283,7 @@ static const struct net_device_ops usbpn_ops =3D {
 	.ndo_open	=3D usbpn_open,
 	.ndo_stop	=3D usbpn_close,
 	.ndo_start_xmit =3D usbpn_xmit,
+	.ndo_do_ioctl	=3D usbpn_ioctl,
 	.ndo_change_mtu =3D usbpn_set_mtu,
 };
=20
diff --git a/include/linux/phonet.h b/include/linux/phonet.h
index 82b45d1..1ef5a07 100644
--- a/include/linux/phonet.h
+++ b/include/linux/phonet.h
@@ -99,6 +99,9 @@ struct sockaddr_pn {
 	__u8 spn_zero[sizeof(struct sockaddr) - sizeof(sa_family_t) - 3];
 } __attribute__ ((packed));
=20
+/* Well known address */
+#define PN_DEV_PC	0x10
+
 static inline __u16 pn_object(__u8 addr, __u16 port)
 {
 	return (addr << 8) | (port & 0x3ff);
--=20
1.6.0.4

