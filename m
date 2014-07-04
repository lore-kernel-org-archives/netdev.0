From: Arvid Brodin <arvid.brodin@alten.se>
Subject: [PATCH net-next 08/10] net/hsr: Added SET_NETDEV_DEVTYPE and features
 |= NETIF_F_NETNS_LOCAL to dev_setup.
Date: Fri, 4 Jul 2014 23:39:42 +0200
Message-ID: <53B71F1E.5070808@alten.se>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from spam1.webland.se ([91.207.112.90]:57192 "EHLO spam1.webland.se"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757069AbaGDVjR (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 4 Jul 2014 17:39:17 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Arvid Brodin <arvid.brodin@alten.se>
---
 net/hsr/hsr_device.c | 14 +++++++++++---
 1 file changed, 11 insertions(+), 3 deletions(-)

diff --git a/net/hsr/hsr_device.c b/net/hsr/hsr_device.c
index c489aed..c2ae549 100644
--- a/net/hsr/hsr_device.c
+++ b/net/hsr/hsr_device.c
@@ -501,15 +501,19 @@ static const struct net_device_ops hsr_device_ops=
 =3D {
 	.ndo_fix_features =3D hsr_fix_features,
 };
=20
+static struct device_type hsr_type =3D {
+	.name =3D "hsr",
+};
=20
 void hsr_dev_setup(struct net_device *dev)
 {
 	random_ether_addr(dev->dev_addr);
=20
 	ether_setup(dev);
-	dev->header_ops		 =3D &hsr_header_ops;
-	dev->netdev_ops		 =3D &hsr_device_ops;
-	dev->tx_queue_len	 =3D 0;
+	dev->header_ops =3D &hsr_header_ops;
+	dev->netdev_ops =3D &hsr_device_ops;
+	SET_NETDEV_DEVTYPE(dev, &hsr_type);
+	dev->tx_queue_len =3D 0;
=20
 	dev->destructor =3D hsr_dev_destroy;
=20
@@ -525,6 +529,10 @@ void hsr_dev_setup(struct net_device *dev)
 	 * hsr_header_create() etc.
 	 */
 	dev->features |=3D NETIF_F_VLAN_CHALLENGED;
+	/* Not sure about this. Taken from bridge code. netdev_features.h say=
s
+	 * it means "Does not change network namespaces".
+	 */
+	dev->features |=3D NETIF_F_NETNS_LOCAL;
 }
=20
=20
--=20
1.8.3.2

--=20
Arvid Brodin | Consultant (Linux)
ALTEN | Knarrarn=C3=A4sgatan 7 | SE-164 40 Kista | Sweden
arvid.brodin@alten.se | www.alten.se/en/
