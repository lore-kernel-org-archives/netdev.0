From: Eric Dumazet <erdnetdev@gmail.com>
Subject: [PATCH] veth: extend device features
Date: Sat, 29 Dec 2012 18:26:10 -0800
Message-ID: <1356834370.21409.6234.camel@edumazet-glaptop>
References: <20121229092417.GA4038@paralelels.com>
	 <1356789203.21409.3923.camel@edumazet-glaptop>
	 <CAHXqBFL+Ycw4-_LRcOCT0bjhALE3HfVMB7YfcoCruu=zW5PN-g@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Andrew Vagin <avagin@parallels.com>, netdev@vger.kernel.org,
	vvs@parallels.com,
	=?UTF-8?Q?Micha=C5=82_Miros=C5=82aw?= <mirq-linux@rere.qmqm.pl>
To: =?UTF-8?Q?Micha=C5=82_Miros=C5=82aw?= <mirqus@gmail.com>,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-da0-f53.google.com ([209.85.210.53]:50896 "EHLO
	mail-da0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753587Ab2L3C0O (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 29 Dec 2012 21:26:14 -0500
Received: by mail-da0-f53.google.com with SMTP id x6so5299063dac.40
        for <netdev@vger.kernel.org>; Sat, 29 Dec 2012 18:26:13 -0800 (PST)
In-Reply-To: <CAHXqBFL+Ycw4-_LRcOCT0bjhALE3HfVMB7YfcoCruu=zW5PN-g@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Eric Dumazet <edumazet@google.com>

veth is lacking most modern facilities, like SG, checksums, TSO.

It makes sense to extend dev->features to get them, or GRO aggregation
is defeated by a forced segmentation.

Reported-by: Andrew Vagin <avagin@parallels.com>
Signed-off-by: Eric Dumazet <edumazet@google.com>
Cc: Micha=C5=82 Miros=C5=82aw <mirq-linux@rere.qmqm.pl>
---
 drivers/net/veth.c |    7 ++++++-
 1 file changed, 6 insertions(+), 1 deletion(-)

diff --git a/drivers/net/veth.c b/drivers/net/veth.c
index 95814d9..ccf211f 100644
--- a/drivers/net/veth.c
+++ b/drivers/net/veth.c
@@ -259,6 +259,10 @@ static const struct net_device_ops veth_netdev_ops=
 =3D {
 	.ndo_set_mac_address =3D eth_mac_addr,
 };
=20
+#define VETH_FEATURES (NETIF_F_SG | NETIF_F_FRAGLIST | NETIF_F_ALL_TSO=
 |    \
+		       NETIF_F_HW_CSUM | NETIF_F_RXCSUM | NETIF_F_HIGHDMA | \
+		       NETIF_F_HW_VLAN_TX | NETIF_F_HW_VLAN_RX)
+
 static void veth_setup(struct net_device *dev)
 {
 	ether_setup(dev);
@@ -269,9 +273,10 @@ static void veth_setup(struct net_device *dev)
 	dev->netdev_ops =3D &veth_netdev_ops;
 	dev->ethtool_ops =3D &veth_ethtool_ops;
 	dev->features |=3D NETIF_F_LLTX;
+	dev->features |=3D VETH_FEATURES;
 	dev->destructor =3D veth_dev_free;
=20
-	dev->hw_features =3D NETIF_F_HW_CSUM | NETIF_F_SG | NETIF_F_RXCSUM;
+	dev->hw_features =3D VETH_FEATURES;
 }
=20
 /*
