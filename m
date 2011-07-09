From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: [PATCH 20/21] net: via-velocity: use common rx_copybreak handling
Date: Sun, 10 Jul 2011 00:19:16 +0200
Message-ID: <20110709221916.GA5609@electric-eye.fr.zoreil.com>
References: <cover.1310229312.git.mirq-linux@rere.qmqm.pl> <fde4e58b4575124aaa9878ea2329dcb3445c50f0.1310229312.git.mirq-linux@rere.qmqm.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: =?utf-8?B?TWljaGHFgiBNaXJvc8WCYXc=?= <mirq-linux@rere.qmqm.pl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from violet.fr.zoreil.com ([92.243.8.30]:56158 "EHLO
	violet.fr.zoreil.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754875Ab1GIWdh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 9 Jul 2011 18:33:37 -0400
Content-Disposition: inline
In-Reply-To: <fde4e58b4575124aaa9878ea2329dcb3445c50f0.1310229312.git.mirq-linux@rere.qmqm.pl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Micha=C5=82 Miros=C5=82aw <mirq-linux@rere.qmqm.pl> :
[...]
> diff --git a/drivers/net/via-velocity.c b/drivers/net/via-velocity.c
> index f929242..cdc51de 100644
> --- a/drivers/net/via-velocity.c
> +++ b/drivers/net/via-velocity.c
[...]
> @@ -2027,10 +1996,10 @@ static int velocity_rx_copy(struct sk_buff **=
rx_skb, int pkt_size,
>   *	configured by the user.
>   */
>  static inline void velocity_iph_realign(struct velocity_info *vptr,
> -					struct sk_buff *skb, int pkt_size)
> +					struct sk_buff *skb)
>  {
>  	if (vptr->flags & VELOCITY_FLAGS_IP_ALIGN) {
> -		memmove(skb->data + 2, skb->data, pkt_size);
> +		memmove(skb->data + 2, skb->data, skb->len);
>  		skb_reserve(skb, 2);
>  	}
>  }
[...]
> @@ -2078,30 +2044,25 @@ static int velocity_receive_frame(struct velo=
city_info *vptr, int idx)
>  		}
>  	}
> =20
> -	pci_action =3D pci_dma_sync_single_for_device;
> +	skb =3D dev_skb_finish_rx_dma(&rd_info->skb,
> +		pkt_len - ETH_FCS_LEN, rx_copybreak,
> +		&vptr->pdev->dev, rd_info->skb_dma, vptr->rx.buf_sz);
> +	if (!skb)
> +		/* not copied */
> +		velocity_iph_realign(vptr, skb);

s/if (!skb)/if (!rd_info->skb)/ ?

--=20
Ueimor
