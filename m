From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next] bnx2x: properly update skb when mtu > 1500
Date: Tue, 13 Dec 2011 10:56:17 +0100
Message-ID: <1323770177.2307.2.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
References: <1323769253-8760-1-git-send-email-dmitry@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	Eilon Greenstein <eilong@broadcom.com>
To: Dmitry Kravkov <dmitry@broadcom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vx0-f174.google.com ([209.85.220.174]:34671 "EHLO
	mail-vx0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752826Ab1LMJ4W (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 13 Dec 2011 04:56:22 -0500
Received: by vcbfk14 with SMTP id fk14so4480740vcb.19
        for <netdev@vger.kernel.org>; Tue, 13 Dec 2011 01:56:21 -0800 (PST)
In-Reply-To: <1323769253-8760-1-git-send-email-dmitry@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mardi 13 d=C3=A9cembre 2011 =C3=A0 11:40 +0200, Dmitry Kravkov a =C3=
=A9crit :
> Since commit e52fcb2462ac484e6dd6e68869536609f0216938 newly allocated
> skb for small packets are not updated properly and dropped by stack.
>=20
> Signed-off-by: Dmitry Kravkov <dmitry@broadcom.com>
> Signed-off-by: Eilon Greenstein <eilong@broadcom.com>
>=20
> ---
>  drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c |   22 +++++++++++--=
---------
>  1 files changed, 11 insertions(+), 11 deletions(-)
>=20
> diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c b/driver=
s/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c
> index 477bc97..64f5cf5 100644
> --- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c
> +++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c
> @@ -731,22 +731,22 @@ reuse_rx:
>  				bnx2x_reuse_rx_data(fp, bd_cons, bd_prod);
>  				goto next_rx;
>  			}
> +		}
> =20
> -			skb_put(skb, len);
> -			skb->protocol =3D eth_type_trans(skb, bp->dev);
> +		skb_put(skb, len);
> +		skb->protocol =3D eth_type_trans(skb, bp->dev);
> =20
> -			/* Set Toeplitz hash for a none-LRO skb */
> -			skb->rxhash =3D bnx2x_get_rxhash(bp, cqe_fp);
> +		/* Set Toeplitz hash for a none-LRO skb */
> +		skb->rxhash =3D bnx2x_get_rxhash(bp, cqe_fp);
> =20
> -			skb_checksum_none_assert(skb);
> +		skb_checksum_none_assert(skb);
> =20
> -			if (bp->dev->features & NETIF_F_RXCSUM) {
> +		if (bp->dev->features & NETIF_F_RXCSUM) {
> =20
> -				if (likely(BNX2X_RX_CSUM_OK(cqe)))
> -					skb->ip_summed =3D CHECKSUM_UNNECESSARY;
> -				else
> -					fp->eth_q_stats.hw_csum_err++;
> -			}
> +			if (likely(BNX2X_RX_CSUM_OK(cqe)))
> +				skb->ip_summed =3D CHECKSUM_UNNECESSARY;
> +			else
> +				fp->eth_q_stats.hw_csum_err++;
>  		}
> =20
>  		skb_record_rx_queue(skb, fp->rx_queue);

Ah, sorry for this, thanks for fixing it !

Acked-by: Eric Dumazet <eric.dumazet@gmail.com>
