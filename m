From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH net] net: bcmgenet: fix accounting of packet drops vs
 errors
Date: Wed, 08 Jul 2015 22:02:39 -0700
Message-ID: <559E006F.4010900@gmail.com>
References: <089e0122a88432eb63051a678bba@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: davem@davemloft.net
To: Petri Gynther <pgynther@google.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f47.google.com ([209.85.218.47]:35456 "EHLO
	mail-oi0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753092AbbGIFCl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 9 Jul 2015 01:02:41 -0400
Received: by oihr66 with SMTP id r66so125738951oih.2
        for <netdev@vger.kernel.org>; Wed, 08 Jul 2015 22:02:41 -0700 (PDT)
In-Reply-To: <089e0122a88432eb63051a678bba@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le 07/08/15 18:55, Petri Gynther a =C3=A9crit :
> bcmgenet driver needs to separate packet drops from packet errors.
>=20
> When the driver has to drop a *good* packet, due to lack of buffers o=
r
> replacement skbs, increment only dev->stats.[rx|tx]_dropped.
>=20
> When the driver encounters a bad Rx packet or Tx error, increment onl=
y
> dev->stats.[rx|tx]_errors + relevant detailed error counter.
>=20
> Signed-off-by: Petri Gynther <pgynther@google.com>

Reviewed-by: Florian Fainelli <f.fainelli@gmail.com>

> ---
>  drivers/net/ethernet/broadcom/genet/bcmgenet.c | 4 ----
>  1 file changed, 4 deletions(-)
>=20
> diff --git a/drivers/net/ethernet/broadcom/genet/bcmgenet.c
> b/drivers/net/ethernet/broadcom/genet/bcmgenet.c
> index b43b2cb..64c1e9d 100644
> --- a/drivers/net/ethernet/broadcom/genet/bcmgenet.c
> +++ b/drivers/net/ethernet/broadcom/genet/bcmgenet.c
> @@ -1230,7 +1230,6 @@ static struct sk_buff *bcmgenet_put_tx_csum(str=
uct
> net_device *dev,
>          new_skb =3D skb_realloc_headroom(skb, sizeof(*status));
>          dev_kfree_skb(skb);
>          if (!new_skb) {
> -            dev->stats.tx_errors++;
>              dev->stats.tx_dropped++;
>              return NULL;
>          }
> @@ -1465,7 +1464,6 @@ static unsigned int bcmgenet_desc_rx(struct
> bcmgenet_rx_ring *ring,
>=20
>          if (unlikely(!skb)) {
>              dev->stats.rx_dropped++;
> -            dev->stats.rx_errors++;
>              goto next;
>          }
>=20
> @@ -1493,7 +1491,6 @@ static unsigned int bcmgenet_desc_rx(struct
> bcmgenet_rx_ring *ring,
>          if (unlikely(!(dma_flag & DMA_EOP) || !(dma_flag & DMA_SOP))=
) {
>              netif_err(priv, rx_status, dev,
>                    "dropping fragmented packet!\n");
> -            dev->stats.rx_dropped++;
>              dev->stats.rx_errors++;
>              dev_kfree_skb_any(skb);
>              goto next;
> @@ -1515,7 +1512,6 @@ static unsigned int bcmgenet_desc_rx(struct
> bcmgenet_rx_ring *ring,
>                  dev->stats.rx_frame_errors++;
>              if (dma_flag & DMA_RX_LG)
>                  dev->stats.rx_length_errors++;
> -            dev->stats.rx_dropped++;
>              dev->stats.rx_errors++;
>              dev_kfree_skb_any(skb);
>              goto next;


--=20
=46lorian
