From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: tg3: Fix to use multi queue BQL interfaces
Date: Mon, 05 Mar 2012 21:56:40 -0800
Message-ID: <1331013400.2474.30.camel@edumazet-laptop>
References: <alpine.DEB.2.00.1203052147540.19396@pokey.mtv.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: davem@davemloft.net, netdev@vger.kernel.org, cl@gentwo.org,
	mcarlson@broadcom.com
To: Tom Herbert <therbert@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pz0-f52.google.com ([209.85.210.52]:48528 "EHLO
	mail-pz0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751772Ab2CFF4o (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 6 Mar 2012 00:56:44 -0500
Received: by dadp12 with SMTP id p12so6185105dad.11
        for <netdev@vger.kernel.org>; Mon, 05 Mar 2012 21:56:44 -0800 (PST)
In-Reply-To: <alpine.DEB.2.00.1203052147540.19396@pokey.mtv.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le lundi 05 mars 2012 =C3=A0 21:53 -0800, Tom Herbert a =C3=A9crit :
> Fix tg3 to use BQL multi queue related netdev interfaces since the
> device supports multi queue.
>=20
> Signed-off-by: Tom Herbert <therbert@google.com>
> ---
>  drivers/net/ethernet/broadcom/tg3.c |    6 +++---
>  1 files changed, 3 insertions(+), 3 deletions(-)
>=20
> diff --git a/drivers/net/ethernet/broadcom/tg3.c b/drivers/net/ethern=
et/broadcom/tg3.c
> index bc236b6..b065746 100644
> --- a/drivers/net/ethernet/broadcom/tg3.c
> +++ b/drivers/net/ethernet/broadcom/tg3.c
> @@ -5595,7 +5595,7 @@ static void tg3_tx(struct tg3_napi *tnapi)
>  		}
>  	}
> =20
> -	netdev_completed_queue(tp->dev, pkts_compl, bytes_compl);
> +	netdev_tx_completed_queue(txq, pkts_compl, bytes_compl);
> =20
>  	tnapi->tx_cons =3D sw_idx;
> =20
> @@ -6971,7 +6971,7 @@ static netdev_tx_t tg3_start_xmit(struct sk_buf=
f *skb, struct net_device *dev)
>  	}
> =20
>  	skb_tx_timestamp(skb);
> -	netdev_sent_queue(tp->dev, skb->len);
> +	netdev_tx_sent_queue(txq, skb->len);
> =20
>  	/* Sync BD data before updating mailbox */
>  	wmb();
> @@ -7396,8 +7396,8 @@ static void tg3_free_rings(struct tg3 *tp)
> =20
>  			dev_kfree_skb_any(skb);
>  		}
> +		netdev_tx_reset_queue(netdev_get_tx_queue(tp->dev, j));
>  	}
> -	netdev_reset_queue(tp->dev);
>  }
> =20
>  /* Initialize tx/rx rings for packet processing.

Reported-by: Christoph Lameter <cl@gentwo.org>
Acked-by: Eric Dumazet <eric.dumazet@gmail.com>
