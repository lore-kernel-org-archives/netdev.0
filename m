From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: [PATCH 15/21] net: tulip/de2104x: use common rx_copybreak handling [strict refill!]
Date: Sun, 10 Jul 2011 00:31:44 +0200
Message-ID: <20110709223144.GA5744@electric-eye.fr.zoreil.com>
References: <cover.1310229312.git.mirq-linux@rere.qmqm.pl> <29374e542d6211f31b9ed0571a60b795f4aed1bb.1310229312.git.mirq-linux@rere.qmqm.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, Grant Grundler <grundler@parisc-linux.org>
To: =?utf-8?B?TWljaGHFgiBNaXJvc8WCYXc=?= <mirq-linux@rere.qmqm.pl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from violet.fr.zoreil.com ([92.243.8.30]:48002 "EHLO
	violet.fr.zoreil.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751447Ab1GIWqJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 9 Jul 2011 18:46:09 -0400
Content-Disposition: inline
In-Reply-To: <29374e542d6211f31b9ed0571a60b795f4aed1bb.1310229312.git.mirq-linux@rere.qmqm.pl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Micha=C5=82 Miros=C5=82aw <mirq-linux@rere.qmqm.pl> :
[...]
> diff --git a/drivers/net/tulip/de2104x.c b/drivers/net/tulip/de2104x.=
c
> index ce90efc..80a34b6 100644
> --- a/drivers/net/tulip/de2104x.c
> +++ b/drivers/net/tulip/de2104x.c
> @@ -432,42 +431,22 @@ static void de_rx (struct de_private *de)
>  			goto rx_next;
>  		}
> =20
> -		copying_skb =3D (len <=3D rx_copybreak);
> -
>  		netif_dbg(de, rx_status, de->dev,
>  			  "rx slot %d status 0x%x len %d copying? %d\n",
> -			  rx_tail, status, len, copying_skb);
> +			  rx_tail, status, len, len <=3D rx_copybreak);
> =20
> -		buflen =3D copying_skb ? (len + RX_OFFSET) : de->rx_buf_sz;
> -		copy_skb =3D dev_alloc_skb (buflen);
> -		if (unlikely(!copy_skb)) {
> +		skb =3D dev_skb_finish_rx_dma_refill(&de->rx_skb[rx_tail].skb,
> +			len, rx_copybreak, 0, RX_OFFSET,
> +			&de->pdev->dev, &mapping, de->rx_buf_sz);
> +		de->rx_skb[rx_tail].mapping =3D mapping;
> +
> +		if (unlikely(!skb)) {

s/skb/de->rx_skb[rx_tail].skb/

--=20
Ueimor
