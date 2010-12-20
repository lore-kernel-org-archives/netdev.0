From: Changli Gao <xiaosuo@gmail.com>
Subject: Re: [PATCH net-next-2.6] ifb: add performance flags to dev->features
Date: Mon, 20 Dec 2010 22:43:46 +0800
Message-ID: <AANLkTikNF8Fr-n7j8EcwAp8zfn0U6EqBjORjn-sEJps8@mail.gmail.com>
References: <AANLkTi=R_ZsYgsYd7EkxHRFTKjtLyLQAOYay2nBV=0bK@mail.gmail.com>
 <1292836885.2800.4.camel@edumazet-laptop> <20101220103226.GB7977@ff.dom.local>
 <1292841671.2800.11.camel@edumazet-laptop> <20101220111141.GC7977@ff.dom.local>
 <20101220115855.GD7977@ff.dom.local> <4D0F471D.8030607@itcare.pl>
 <20101220122256.GA9325@ff.dom.local> <1292849150.2800.25.camel@edumazet-laptop>
 <1292849687.2800.27.camel@edumazet-laptop> <20101220130247.GB9325@ff.dom.local>
 <AANLkTi=eqCWpFpHQ86_yO544p5G6J6P2os7rCR9FBtUd@mail.gmail.com> <1292855120.2800.45.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>,
	Jarek Poplawski <jarkao2@gmail.com>,
	=?ISO-8859-2?Q?Pawe=B3_Staszewski?= <pstaszewski@itcare.pl>,
	Linux Network Development list <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>,
	Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f43.google.com ([209.85.161.43]:65039 "EHLO
	mail-fx0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932512Ab0LTQoY convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 20 Dec 2010 11:44:24 -0500
Received: by fxm18 with SMTP id 18so3243834fxm.2
        for <netdev@vger.kernel.org>; Mon, 20 Dec 2010 08:44:22 -0800 (PST)
In-Reply-To: <1292855120.2800.45.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Dec 20, 2010 at 10:25 PM, Eric Dumazet <eric.dumazet@gmail.com>=
 wrote:
> =A0drivers/net/ifb.c | =A0 =A03 +++
> =A01 file changed, 3 insertions(+)
>
> diff --git a/drivers/net/ifb.c b/drivers/net/ifb.c
> index 124dac4..c761551 100644
> --- a/drivers/net/ifb.c
> +++ b/drivers/net/ifb.c
> @@ -136,6 +136,9 @@ static void ifb_setup(struct net_device *dev)
> =A0 =A0 =A0 =A0ether_setup(dev);
> =A0 =A0 =A0 =A0dev->tx_queue_len =3D TX_Q_LIMIT;
>
> + =A0 =A0 =A0 dev->features |=3D NETIF_F_NO_CSUM | NETIF_F_SG |
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0NETIF_F_FRAGLIST | N=
ETIF_F_HIGHDMA |
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0NETIF_F_TSO;
> =A0 =A0 =A0 =A0dev->flags |=3D IFF_NOARP;
> =A0 =A0 =A0 =A0dev->flags &=3D ~IFF_MULTICAST;
> =A0 =A0 =A0 =A0dev->priv_flags &=3D ~IFF_XMIT_DST_RELEASE;
>
>
>

I think we can assign these features to vlan_features.

dev->vlan_features |=3D dev->features.

Although I don't know all the features related to GSO,  I just added
all of them. For pseudo NIC, I think it is safe to do so.

+       dev->features |=3D NETIF_F_SG | NETIF_F_NO_CSUM | NETIF_F_TSO |
+                        NETIF_F_UFO | NETIF_F_GSO_ROBUST | NETIF_F_TSO=
_ECN |
+                        NETIF_F_TSO6 | NETIF_F_FSO;

--=20
Regards,
Changli Gao(xiaosuo@gmail.com)
