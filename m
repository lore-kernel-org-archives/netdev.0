From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: [PATCH 07/21] net: lib82596: use common rx_copybreak handling [strict refill!]
Date: Sun, 10 Jul 2011 00:25:59 +0200
Message-ID: <20110709222559.GA5675@electric-eye.fr.zoreil.com>
References: <cover.1310229312.git.mirq-linux@rere.qmqm.pl> <041aed2721ea22ee6e7d122c3c21a59b4042f431.1310229312.git.mirq-linux@rere.qmqm.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: =?utf-8?B?TWljaGHFgiBNaXJvc8WCYXc=?= <mirq-linux@rere.qmqm.pl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from violet.fr.zoreil.com ([92.243.8.30]:40550 "EHLO
	violet.fr.zoreil.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754852Ab1GIWkS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 9 Jul 2011 18:40:18 -0400
Content-Disposition: inline
In-Reply-To: <041aed2721ea22ee6e7d122c3c21a59b4042f431.1310229312.git.mirq-linux@rere.qmqm.pl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Micha=C5=82 Miros=C5=82aw <mirq-linux@rere.qmqm.pl> :
[...]
> diff --git a/drivers/net/lib82596.c b/drivers/net/lib82596.c
> index 9e04289..d19e05b 100644
> --- a/drivers/net/lib82596.c
> +++ b/drivers/net/lib82596.c
> @@ -679,67 +679,29 @@ static inline int i596_rx(struct net_device *de=
v)
>  		if (rbd !=3D NULL && (rfd->stat & SWAP16(STAT_OK))) {
>  			/* a good frame */
>  			int pkt_len =3D SWAP16(rbd->count) & 0x3fff;
> -			struct sk_buff *skb =3D rbd->skb;
> -			int rx_in_place =3D 0;
> +			struct sk_buff *skb;
> +			dma_addr_t dma_addr;
> =20
>  			DEB(DEB_RXADDR, print_eth(rbd->v_data, "received"));
>  			frames++;
> =20
> -			/* Check if the packet is long enough to just accept
> -			 * without copying to a properly sized skbuff.
> -			 */
> +			dma_addr =3D SWAP32(rbd->b_data);
> +			skb =3D dev_skb_finish_rx_dma_refill(&rbd->skb,
> +				pkt_len, rx_copybreak, NET_IP_ALIGN, 0,
> +				dev->dev.parent, &dma_addr, PKT_BUF_SZ);
[...]
> +			if (likely(skb)) {

s/skb/rbd->skb/

--=20
Ueimor
