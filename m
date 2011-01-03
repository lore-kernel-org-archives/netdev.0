From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH v2 net-next-2.6] ifb: add performance flags
Date: Mon, 03 Jan 2011 21:35:22 +0100
Message-ID: <1294086922.2711.18.camel@edumazet-laptop>
References: <20101228230709.GA2088@del.dom.local>
	 <1293999876.2535.211.camel@edumazet-laptop>
	 <20110103193703.GA1977@del.dom.local>
	 <20110103.114033.28807428.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: jarkao2@gmail.com, xiaosuo@gmail.com, pstaszewski@itcare.pl,
	netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f194.google.com ([74.125.82.194]:55355 "EHLO
	mail-wy0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751242Ab1ACUf1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 3 Jan 2011 15:35:27 -0500
Received: by wyf23 with SMTP id 23so4786512wyf.1
        for <netdev@vger.kernel.org>; Mon, 03 Jan 2011 12:35:25 -0800 (PST)
In-Reply-To: <20110103.114033.28807428.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le lundi 03 janvier 2011 =C3=A0 11:40 -0800, David Miller a =C3=A9crit =
:
> From: Jarek Poplawski <jarkao2@gmail.com>
> Date: Mon, 3 Jan 2011 20:37:03 +0100
>=20
> > On Sun, Jan 02, 2011 at 09:24:36PM +0100, Eric Dumazet wrote:
> >> Le mercredi 29 d=C3=A9cembre 2010 ?? 00:07 +0100, Jarek Poplawski =
a =C3=A9crit :
> >>=20
> >> > Ingress is before vlans handler so these features and the
> >> > NETIF_F_HW_VLAN_TX flag seem useful for ifb considering
> >> > dev_hard_start_xmit() checks.
> >>=20
> >> OK, here is v2 of the patch then, thanks everybody.
> >>=20
> >>=20
> >> [PATCH v2 net-next-2.6] ifb: add performance flags
> >>=20
> >> IFB can use the full set of features flags (NETIF_F_SG |
> >> NETIF_F_FRAGLIST | NETIF_F_TSO | NETIF_F_NO_CSUM | NETIF_F_HIGHDMA=
) to
> >> avoid unnecessary split of some packets (GRO for example)
> >>=20
> >> Changli suggested to also set vlan_features,
> >=20
> > He also suggested more GSO flags of which especially NETIF_F_TSO6
> > seems interesting (wrt GRO)?
>=20
> I think at least TSO6 would very much be appropriate here.

Yes, why not, I am only wondering why loopback / dummy (and others ?)
only set NETIF_F_TSO :)

Since I want to play with ECN, I might also add NETIF_F_TSO_ECN ;)

=46or other flags, I really doubt it can matter on ifb ?

[PATCH v3 net-next-2.6] ifb: add performance flags

IFB can use the full set of features flags (NETIF_F_SG |
NETIF_F_FRAGLIST | NETIF_F_TSO | NETIF_F_NO_CSUM | NETIF_F_HIGHDMA) to
avoid unnecessary split of some packets (GRO for example)

Changli suggested to also set vlan_features, NETIF_F_TSO6,
NETIF_F_TSO_ECN.

Jarek suggested to add NETIF_F_HW_VLAN_TX as well.

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
Cc: Changli Gao <xiaosuo@gmail.com>
Cc: Jarek Poplawski <jarkao2@gmail.com>
Cc: Pawel Staszewski <pstaszewski@itcare.pl>
---
 drivers/net/ifb.c |    7 +++++++
 1 file changed, 7 insertions(+)

diff --git a/drivers/net/ifb.c b/drivers/net/ifb.c
index 124dac4..e07d487 100644
--- a/drivers/net/ifb.c
+++ b/drivers/net/ifb.c
@@ -126,6 +126,10 @@ static const struct net_device_ops ifb_netdev_ops =
=3D {
 	.ndo_validate_addr =3D eth_validate_addr,
 };
=20
+#define IFB_FEATURES (NETIF_F_NO_CSUM | NETIF_F_SG  | NETIF_F_FRAGLIST=
	| \
+		      NETIF_F_TSO_ECN | NETIF_F_TSO | NETIF_F_TSO6	| \
+		      NETIF_F_HIGHDMA | NETIF_F_HW_VLAN_TX)
+
 static void ifb_setup(struct net_device *dev)
 {
 	/* Initialize the device structure. */
@@ -136,6 +140,9 @@ static void ifb_setup(struct net_device *dev)
 	ether_setup(dev);
 	dev->tx_queue_len =3D TX_Q_LIMIT;
=20
+	dev->features |=3D IFB_FEATURES;
+	dev->vlan_features |=3D IFB_FEATURES;
+
 	dev->flags |=3D IFF_NOARP;
 	dev->flags &=3D ~IFF_MULTICAST;
 	dev->priv_flags &=3D ~IFF_XMIT_DST_RELEASE;


