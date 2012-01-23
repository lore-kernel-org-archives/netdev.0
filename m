From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH/RESEND net 5/5][NON-TRIVIAL] drivers/net/ethernet:
 dev_alloc_skb to netdev_alloc_skb
Date: Mon, 23 Jan 2012 22:04:27 +0100
Message-ID: <1327352667.2587.4.camel@edumazet-laptop>
References: <1327352046-6896-1-git-send-email-netdev@pradeepdalvi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>,
	linux-kernel@vger.kernel.org, Christoph Hellwig <hch@lst.de>
To: "Pradeep A. Dalvi" <netdev@pradeepdalvi.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1327352046-6896-1-git-send-email-netdev@pradeepdalvi.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Le mardi 24 janvier 2012 =C3=A0 02:24 +0530, Pradeep A. Dalvi a =C3=A9c=
rit :
> Replaced deprecating dev_alloc_skb with netdev_alloc_skb in drivers/n=
et/ethernet
>   - Removed extra skb->dev =3D dev after netdev_alloc_skb
>=20


> =20
>  /* Initialize the LANCE Rx and Tx rings. */
>  static void
> -lance_init_ring(struct net_device *dev, gfp_t gfp)
> +lance_init_ring(struct net_device *dev)
>  {
>  	struct lance_private *lp =3D dev->ml_priv;
>  	int i;
> @@ -871,13 +871,12 @@ lance_init_ring(struct net_device *dev, gfp_t g=
fp)
>  		struct sk_buff *skb;
>  		void *rx_buff;
> =20
> -		skb =3D alloc_skb(PKT_BUF_SZ, GFP_DMA | gfp);
> +		skb =3D netdev_alloc_skb(dev, PKT_BUF_SZ);
>  		lp->rx_skbuff[i] =3D skb;
> -		if (skb) {
> -			skb->dev =3D dev;
> +		if (skb)
>  			rx_buff =3D skb->data;
> -		} else
> -			rx_buff =3D kmalloc(PKT_BUF_SZ, GFP_DMA | gfp);
> +		else
> +			rx_buff =3D kmalloc(PKT_BUF_SZ, GFP_DMA | GFP_AUTOMIC);
>  		if (rx_buff =3D=3D NULL)
>  			lp->rx_ring[i].base =3D 0;
>  		else

Thats really crap, please dont send us such patches, not even compiled.

alloc_skb() has nothing to do with dev_alloc_skb(), and there is a
reason GFP_DMA is used in this driver.
