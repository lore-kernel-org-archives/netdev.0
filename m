From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next-2.6] ifb: add performance flags to dev->features
Date: Mon, 20 Dec 2010 15:25:20 +0100
Message-ID: <1292855120.2800.45.camel@edumazet-laptop>
References: <AANLkTi=R_ZsYgsYd7EkxHRFTKjtLyLQAOYay2nBV=0bK@mail.gmail.com>
	 <1292836885.2800.4.camel@edumazet-laptop>
	 <20101220103226.GB7977@ff.dom.local>
	 <1292841671.2800.11.camel@edumazet-laptop>
	 <20101220111141.GC7977@ff.dom.local> <20101220115855.GD7977@ff.dom.local>
	 <4D0F471D.8030607@itcare.pl> <20101220122256.GA9325@ff.dom.local>
	 <1292849150.2800.25.camel@edumazet-laptop>
	 <1292849687.2800.27.camel@edumazet-laptop>
	 <20101220130247.GB9325@ff.dom.local>
	 <AANLkTi=eqCWpFpHQ86_yO544p5G6J6P2os7rCR9FBtUd@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Jarek Poplawski <jarkao2@gmail.com>,
	=?UTF-8?Q?Pawe=C5=82?= Staszewski <pstaszewski@itcare.pl>,
	Linux Network Development list <netdev@vger.kernel.org>
To: Changli Gao <xiaosuo@gmail.com>, David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:65009 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757865Ab0LTOZ0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 20 Dec 2010 09:25:26 -0500
Received: by wyb28 with SMTP id 28so2897327wyb.19
        for <netdev@vger.kernel.org>; Mon, 20 Dec 2010 06:25:24 -0800 (PST)
In-Reply-To: <AANLkTi=eqCWpFpHQ86_yO544p5G6J6P2os7rCR9FBtUd@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le lundi 20 d=C3=A9cembre 2010 =C3=A0 22:05 +0800, Changli Gao a =C3=A9=
crit :
> 2010/12/20 Jarek Poplawski <jarkao2@gmail.com>:
> >
> > IMHO it should, (probably even more, like loopback) but we should
> > consider mirred can xmit to other than ifb too.
> >
>=20
> I also think so. And when making ifb a multiqueue NIC, I tried to add
> these dev features to ifb. :)
>=20

This has litle to do with your multiqueue work,
its more an effect of GRO being more and more deployed.

I dont see dev->features being changed in one of your previous patches.
I did dummy case in commit 6d81f41c58c6

[PATCH net-next-2.6] ifb: add performance flags to dev->features

IFB can use the full set of features flags (NETIF_F_SG |
NETIF_F_FRAGLIST | NETIF_F_TSO | NETIF_F_NO_CSUM | NETIF_F_HIGHDMA) to
avoid unecessary split of some packets (GRO for example)

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
Cc: Changli Gao <xiaosuo@gmail.com>
Cc: Jarek Poplawski <jarkao2@gmail.com>
Cc: Pawel Staszewski <pstaszewski@itcare.pl>
---
 drivers/net/ifb.c |    3 +++
 1 file changed, 3 insertions(+)

diff --git a/drivers/net/ifb.c b/drivers/net/ifb.c
index 124dac4..c761551 100644
--- a/drivers/net/ifb.c
+++ b/drivers/net/ifb.c
@@ -136,6 +136,9 @@ static void ifb_setup(struct net_device *dev)
 	ether_setup(dev);
 	dev->tx_queue_len =3D TX_Q_LIMIT;
=20
+	dev->features |=3D NETIF_F_NO_CSUM | NETIF_F_SG |
+			 NETIF_F_FRAGLIST | NETIF_F_HIGHDMA |
+			 NETIF_F_TSO;
 	dev->flags |=3D IFF_NOARP;
 	dev->flags &=3D ~IFF_MULTICAST;
 	dev->priv_flags &=3D ~IFF_XMIT_DST_RELEASE;


