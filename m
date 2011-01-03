From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: [PATCH v2 net-next-2.6] ifb: add performance flags
Date: Mon, 3 Jan 2011 20:37:03 +0100
Message-ID: <20110103193703.GA1977@del.dom.local>
References: <20101220130247.GB9325@ff.dom.local>
 <AANLkTi=eqCWpFpHQ86_yO544p5G6J6P2os7rCR9FBtUd@mail.gmail.com>
 <1292855120.2800.45.camel@edumazet-laptop>
 <20101228.135013.39173075.davem@davemloft.net>
 <1293575781.20573.391.camel@edumazet-laptop>
 <20101228230709.GA2088@del.dom.local>
 <1293999876.2535.211.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, xiaosuo@gmail.com,
	pstaszewski@itcare.pl, netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f46.google.com ([209.85.214.46]:64844 "EHLO
	mail-bw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754330Ab1ACThN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 3 Jan 2011 14:37:13 -0500
Received: by bwz15 with SMTP id 15so14001410bwz.19
        for <netdev@vger.kernel.org>; Mon, 03 Jan 2011 11:37:09 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <1293999876.2535.211.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Jan 02, 2011 at 09:24:36PM +0100, Eric Dumazet wrote:
> Le mercredi 29 d=E9cembre 2010 ?? 00:07 +0100, Jarek Poplawski a =E9c=
rit :
>=20
> > Ingress is before vlans handler so these features and the
> > NETIF_F_HW_VLAN_TX flag seem useful for ifb considering
> > dev_hard_start_xmit() checks.
>=20
> OK, here is v2 of the patch then, thanks everybody.
>=20
>=20
> [PATCH v2 net-next-2.6] ifb: add performance flags
>=20
> IFB can use the full set of features flags (NETIF_F_SG |
> NETIF_F_FRAGLIST | NETIF_F_TSO | NETIF_F_NO_CSUM | NETIF_F_HIGHDMA) t=
o
> avoid unnecessary split of some packets (GRO for example)
>=20
> Changli suggested to also set vlan_features,

He also suggested more GSO flags of which especially NETIF_F_TSO6
seems interesting (wrt GRO)?

Jarek P.

> Jarek suggested to add NETIF_F_HW_VLAN_TX as well.
>=20
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
> Cc: Changli Gao <xiaosuo@gmail.com>
> Cc: Jarek Poplawski <jarkao2@gmail.com>
> Cc: Pawel Staszewski <pstaszewski@itcare.pl>
> ---
>  drivers/net/ifb.c |    6 ++++++
>  1 file changed, 6 insertions(+)
>=20
> diff --git a/drivers/net/ifb.c b/drivers/net/ifb.c
> index 124dac4..66ca7bf 100644
> --- a/drivers/net/ifb.c
> +++ b/drivers/net/ifb.c
> @@ -126,6 +126,9 @@ static const struct net_device_ops ifb_netdev_ops=
 =3D {
>  	.ndo_validate_addr =3D eth_validate_addr,
>  };
> =20
> +#define IFB_FEATURES (NETIF_F_NO_CSUM | NETIF_F_SG  | NETIF_F_FRAGLI=
ST | \
> +		      NETIF_F_HIGHDMA | NETIF_F_TSO | NETIF_F_HW_VLAN_TX)
> +
>  static void ifb_setup(struct net_device *dev)
>  {
>  	/* Initialize the device structure. */
> @@ -136,6 +139,9 @@ static void ifb_setup(struct net_device *dev)
>  	ether_setup(dev);
>  	dev->tx_queue_len =3D TX_Q_LIMIT;
> =20
> +	dev->features |=3D IFB_FEATURES;
> +	dev->vlan_features |=3D IFB_FEATURES;
> +
>  	dev->flags |=3D IFF_NOARP;
>  	dev->flags &=3D ~IFF_MULTICAST;
>  	dev->priv_flags &=3D ~IFF_XMIT_DST_RELEASE;
>=20
>=20
