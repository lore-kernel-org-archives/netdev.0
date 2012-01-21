From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH 1/1] netdev/ethernet: dev_alloc_skb to netdev_alloc_skb
Date: Sat, 21 Jan 2012 16:53:58 +0100
Message-ID: <1327161238.2574.3.camel@edumazet-laptop>
References: <1327156996-12505-1-git-send-email-netdev@pradeepdalvi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>,
	Christoph Hellwig <hch@lst.de>, linux-kernel@vger.kernel.org
To: "Pradeep A. Dalvi" <netdev@pradeepdalvi.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1327156996-12505-1-git-send-email-netdev@pradeepdalvi.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Le samedi 21 janvier 2012 =C3=A0 20:13 +0530, Pradeep A. Dalvi a =C3=A9=
crit :
> Replaced deprecating dev_alloc_skb with netdev_alloc_skb in drivers/n=
et/ethernet
>=20
> Signed-off-by: Pradeep A. Dalvi <netdev@pradeepdalvi.com>
> ---

=2E..

>  114 files changed, 257 insertions(+), 203 deletions(-)
>=20
> diff --git a/drivers/net/ethernet/3com/3c501.c b/drivers/net/ethernet=
/3com/3c501.c
> index 68da81d..9ebc739 100644
> --- a/drivers/net/ethernet/3com/3c501.c
> +++ b/drivers/net/ethernet/3com/3c501.c
> @@ -702,7 +702,7 @@ static void el_receive(struct net_device *dev)
>  	 */
> =20
>  	outb(AX_SYS, AX_CMD);
> -	skb =3D dev_alloc_skb(pkt_len+2);
> +	skb =3D netdev_alloc_skb(dev, pkt_len + NET_IP_ALIGN);
> =20
>  	/*
>  	 *	Start of frame
> diff --git a/drivers/net/ethernet/3com/3c509.c b/drivers/net/ethernet=
/3com/3c509.c


So the very first chunk of this huge patch is wrong, since it adds a
true bug.  (You dont change the skb_reserve(skb, 2); later)

I stopped my review at this first chunk.

Please dont add NET_IP_ALIGN on drivers if you cant test the change
yourself.
=20
Some hardware really need the hardcoded 2 value.
