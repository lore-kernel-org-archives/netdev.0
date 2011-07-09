From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: [PATCH 09/21] net: pcnet32: use common rx_copybreak handling [strict refill!]
Date: Sun, 10 Jul 2011 00:28:33 +0200
Message-ID: <20110709222833.GA5710@electric-eye.fr.zoreil.com>
References: <cover.1310229312.git.mirq-linux@rere.qmqm.pl> <0f270b4469acf1db6e18025c7097f6e4e338ad5d.1310229312.git.mirq-linux@rere.qmqm.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, Don Fry <pcnet32@frontier.com>
To: =?utf-8?B?TWljaGHFgiBNaXJvc8WCYXc=?= <mirq-linux@rere.qmqm.pl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from violet.fr.zoreil.com ([92.243.8.30]:47997 "EHLO
	violet.fr.zoreil.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754873Ab1GIWm5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 9 Jul 2011 18:42:57 -0400
Content-Disposition: inline
In-Reply-To: <0f270b4469acf1db6e18025c7097f6e4e338ad5d.1310229312.git.mirq-linux@rere.qmqm.pl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Micha=C5=82 Miros=C5=82aw <mirq-linux@rere.qmqm.pl> :
[...]
> diff --git a/drivers/net/pcnet32.c b/drivers/net/pcnet32.c
> index 8b3090d..baae404 100644
> --- a/drivers/net/pcnet32.c
> +++ b/drivers/net/pcnet32.c
> @@ -1147,51 +1146,18 @@ static void pcnet32_rx_entry(struct net_devic=
e *dev,
>  		return;
>  	}
> =20
> -	if (pkt_len > rx_copybreak) {
> -		struct sk_buff *newskb;
> -
> -		newskb =3D dev_alloc_skb(PKT_BUF_SKB);
> -		if (newskb) {
> -			skb_reserve(newskb, NET_IP_ALIGN);
> -			skb =3D lp->rx_skbuff[entry];
> -			pci_unmap_single(lp->pci_dev,
> -					 lp->rx_dma_addr[entry],
> -					 PKT_BUF_SIZE,
> -					 PCI_DMA_FROMDEVICE);
> -			skb_put(skb, pkt_len);
> -			lp->rx_skbuff[entry] =3D newskb;
> -			lp->rx_dma_addr[entry] =3D
> -					    pci_map_single(lp->pci_dev,
> -							   newskb->data,
> -							   PKT_BUF_SIZE,
> -							   PCI_DMA_FROMDEVICE);
> -			rxp->base =3D cpu_to_le32(lp->rx_dma_addr[entry]);
> -			rx_in_place =3D 1;
> -		} else
> -			skb =3D NULL;
> -	} else
> -		skb =3D dev_alloc_skb(pkt_len + NET_IP_ALIGN);
> +	skb =3D dev_skb_finish_rx_dma_refill(&lp->rx_skbuff[entry],
> +		pkt_len, rx_copybreak, NET_IP_ALIGN, 0,
> +		&lp->pci_dev->dev, &lp->rx_dma_addr[entry],
> +		PKT_BUF_SIZE);
> +	rxp->base =3D cpu_to_le32(lp->rx_dma_addr[entry]);
> =20
>  	if (skb =3D=3D NULL) {

s/skb/lp->rx_skbuff[entry]/

--=20
Ueimor
