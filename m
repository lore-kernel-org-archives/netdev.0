From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net] amd/lance.c: dev_alloc_skb to netdev_alloc_skb
Date: Wed, 25 Jan 2012 19:55:06 +0100
Message-ID: <1327517706.2605.7.camel@edumazet-laptop>
References: <1327517188-14088-1-git-send-email-netdev@pradeepdalvi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>,
	linux-kernel@vger.kernel.org
To: "Pradeep A. Dalvi" <netdev@pradeepdalvi.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1327517188-14088-1-git-send-email-netdev@pradeepdalvi.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Le jeudi 26 janvier 2012 =C3=A0 00:16 +0530, Pradeep A. Dalvi a =C3=A9c=
rit :
> Replaced deprecating dev_alloc_skb with netdev_alloc_skb for amd/lanc=
e.c
>   - Removed extra skb->dev =3D dev
>=20
> Signed-off-by: Pradeep A. Dalvi <netdev@pradeepdalvi.com>
> ---
>  drivers/net/ethernet/amd/lance.c |    9 ++++-----
>  1 files changed, 4 insertions(+), 5 deletions(-)
>=20
> diff --git a/drivers/net/ethernet/amd/lance.c b/drivers/net/ethernet/=
amd/lance.c
> index a6e2e84..a8a6b45 100644
> --- a/drivers/net/ethernet/amd/lance.c
> +++ b/drivers/net/ethernet/amd/lance.c
> @@ -871,12 +871,11 @@ lance_init_ring(struct net_device *dev, gfp_t g=
fp)
>  		struct sk_buff *skb;
>  		void *rx_buff;
> =20
> -		skb =3D alloc_skb(PKT_BUF_SZ, GFP_DMA | gfp);
> +		skb =3D __netdev_alloc_skb(dev, PKT_BUF_SZ, GFP_DMA | gfp);

Nack

As I already explained, alloc_skb() and netdev_alloc_skb() are
different.

Why do you repost this ?

nedev_alloc_skb() adds NET_SKB_PAD bytes.

This driver doesnt need this extra space.

(In fact it could use kmalloc(), since the skb themselves are not used
at all : At RX time, we perform a copybreak)
