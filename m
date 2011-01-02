From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH v2 net-next-2.6] ifb: add performance flags
Date: Sun, 02 Jan 2011 21:24:36 +0100
Message-ID: <1293999876.2535.211.camel@edumazet-laptop>
References: <20101220130247.GB9325@ff.dom.local>
	 <AANLkTi=eqCWpFpHQ86_yO544p5G6J6P2os7rCR9FBtUd@mail.gmail.com>
	 <1292855120.2800.45.camel@edumazet-laptop>
	 <20101228.135013.39173075.davem@davemloft.net>
	 <1293575781.20573.391.camel@edumazet-laptop>
	 <20101228230709.GA2088@del.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, xiaosuo@gmail.com,
	pstaszewski@itcare.pl, netdev@vger.kernel.org
To: Jarek Poplawski <jarkao2@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:38932 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753462Ab1ABUYo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 2 Jan 2011 15:24:44 -0500
Received: by wwa36 with SMTP id 36so13656130wwa.1
        for <netdev@vger.kernel.org>; Sun, 02 Jan 2011 12:24:43 -0800 (PST)
In-Reply-To: <20101228230709.GA2088@del.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mercredi 29 d=C3=A9cembre 2010 =C3=A0 00:07 +0100, Jarek Poplawski a=
 =C3=A9crit :

> Ingress is before vlans handler so these features and the
> NETIF_F_HW_VLAN_TX flag seem useful for ifb considering
> dev_hard_start_xmit() checks.

OK, here is v2 of the patch then, thanks everybody.


[PATCH v2 net-next-2.6] ifb: add performance flags

IFB can use the full set of features flags (NETIF_F_SG |
NETIF_F_FRAGLIST | NETIF_F_TSO | NETIF_F_NO_CSUM | NETIF_F_HIGHDMA) to
avoid unnecessary split of some packets (GRO for example)

Changli suggested to also set vlan_features,
Jarek suggested to add NETIF_F_HW_VLAN_TX as well.

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
Cc: Changli Gao <xiaosuo@gmail.com>
Cc: Jarek Poplawski <jarkao2@gmail.com>
Cc: Pawel Staszewski <pstaszewski@itcare.pl>
---
 drivers/net/ifb.c |    6 ++++++
 1 file changed, 6 insertions(+)

diff --git a/drivers/net/ifb.c b/drivers/net/ifb.c
index 124dac4..66ca7bf 100644
--- a/drivers/net/ifb.c
+++ b/drivers/net/ifb.c
@@ -126,6 +126,9 @@ static const struct net_device_ops ifb_netdev_ops =3D=
 {
 	.ndo_validate_addr =3D eth_validate_addr,
 };
=20
+#define IFB_FEATURES (NETIF_F_NO_CSUM | NETIF_F_SG  | NETIF_F_FRAGLIST=
 | \
+		      NETIF_F_HIGHDMA | NETIF_F_TSO | NETIF_F_HW_VLAN_TX)
+
 static void ifb_setup(struct net_device *dev)
 {
 	/* Initialize the device structure. */
@@ -136,6 +139,9 @@ static void ifb_setup(struct net_device *dev)
 	ether_setup(dev);
 	dev->tx_queue_len =3D TX_Q_LIMIT;
=20
+	dev->features |=3D IFB_FEATURES;
+	dev->vlan_features |=3D IFB_FEATURES;
+
 	dev->flags |=3D IFF_NOARP;
 	dev->flags &=3D ~IFF_MULTICAST;
 	dev->priv_flags &=3D ~IFF_XMIT_DST_RELEASE;


