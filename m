From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] netdev/ethernet: dev_alloc_skb to netdev_alloc_skb
Date: Mon, 23 Jan 2012 10:45:25 +0100
Message-ID: <1327311925.2525.7.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
References: <1327179463-13980-1-git-send-email-netdev@pradeepdalvi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>,
	Christoph Hellwig <hch@lst.de>, linux-kernel@vger.kernel.org
To: "Pradeep A. Dalvi" <netdev@pradeepdalvi.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1327179463-13980-1-git-send-email-netdev@pradeepdalvi.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Le dimanche 22 janvier 2012 =C3=A0 02:27 +0530, Pradeep A. Dalvi a =C3=A9=
crit :
> Replaced deprecating dev_alloc_skb with netdev_alloc_skb in drivers/n=
et/ethernet
>=20

=2E..


> diff --git a/drivers/net/ethernet/3com/3c515.c b/drivers/net/ethernet=
/3com/3c515.c
> index f67a5d3..68fd765 100644
> --- a/drivers/net/ethernet/3com/3c515.c
> +++ b/drivers/net/ethernet/3com/3c515.c
> @@ -826,7 +826,7 @@ static int corkscrew_open(struct net_device *dev)
>  				vp->rx_ring[i].next =3D 0;
>  			vp->rx_ring[i].status =3D 0;	/* Clear complete bit. */
>  			vp->rx_ring[i].length =3D PKT_BUF_SZ | 0x80000000;
> -			skb =3D dev_alloc_skb(PKT_BUF_SZ);
> +			skb =3D netdev_alloc_skb(dev, PKT_BUF_SZ);
>  			vp->rx_skbuff[i] =3D skb;
>  			if (skb =3D=3D NULL)
>  				break;	/* Bad news!  */


One of the difference between netdev_alloc_skb() and dev_alloc_skb() is
the former initializes skb->dev.

So you should remove the extra "skb->dev =3D dev;" lines that sometimes
are after the dev_alloc_skb() calls.

[ They were redundant anyway because eth_type_trans() also sets skb->de=
v
]

=20
