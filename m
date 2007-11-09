From: Domen Puncer <domen.puncer@telargo.com>
Subject: Re: [PATCH] Fix buglets in mpc5200 FEC code that are corrupting memory.
Date: Fri, 9 Nov 2007 10:12:45 +0100
Message-ID: <20071109091245.GA3148@nd47.coderock.org>
References: <9e4733910711082131v70c4b7bm2b00445b7e62c33f@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: PowerPC dev list <Linuxppc-dev@ozlabs.org>,
	Grant Likely <grant.likely@secretlab.ca>,
	netdev <netdev@vger.kernel.org>
To: Jon Smirl <jonsmirl@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from kukmak.uni-mb.si ([164.8.100.3]:43943 "EHLO kukmak.uni-mb.si"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751438AbXKIJM6 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 9 Nov 2007 04:12:58 -0500
Content-Disposition: inline
In-Reply-To: <9e4733910711082131v70c4b7bm2b00445b7e62c33f@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 09/11/07 00:31 -0500, Jon Smirl wrote:
> This is the reason I couldn't get user space started or connect to my
> nfs server. Patch is against current linus git.
>=20
> mpc5200 fec driver is corrupting memory. This patch fixes two bugs
> where the wrong skb buffer was being referenced.
>=20
> Signed-off-by: Jon Smirl <jonsmirl@gmail.com>

Acked-by: Domen Puncer <domen.puncer@telargo.com>

I can't test it at the moment, but the patch is obviously correct,
mapped buffer should be the _same_ as submitted.

>=20
> ---
>=20
>  drivers/net/fec_mpc52xx.c |    4 ++--
>  1 files changed, 2 insertions(+), 2 deletions(-)
>=20
>=20
> diff --git a/drivers/net/fec_mpc52xx.c b/drivers/net/fec_mpc52xx.c
> index a8a0ee2..ddfcc0b 100644
> --- a/drivers/net/fec_mpc52xx.c
> +++ b/drivers/net/fec_mpc52xx.c
> @@ -422,7 +422,7 @@ static irqreturn_t mpc52xx_fec_rx_interrupt(int
> irq, void *dev_id)
>=20
>  		rskb =3D bcom_retrieve_buffer(priv->rx_dmatsk, &status,
>  				(struct bcom_bd **)&bd);
> -		dma_unmap_single(&dev->dev, bd->skb_pa, skb->len, DMA_FROM_DEVICE)=
;
> +		dma_unmap_single(&dev->dev, bd->skb_pa, rskb->len, DMA_FROM_DEVICE=
);
>=20
>  		/* Test for errors in received frame */
>  		if (status & BCOM_FEC_RX_BD_ERRORS) {
> @@ -467,7 +467,7 @@ static irqreturn_t mpc52xx_fec_rx_interrupt(int
> irq, void *dev_id)
>  			bcom_prepare_next_buffer(priv->rx_dmatsk);
>=20
>  		bd->status =3D FEC_RX_BUFFER_SIZE;
> -		bd->skb_pa =3D dma_map_single(&dev->dev, rskb->data,
> +		bd->skb_pa =3D dma_map_single(&dev->dev, skb->data,
>  				FEC_RX_BUFFER_SIZE, DMA_FROM_DEVICE);
>=20
>  		bcom_submit_next_buffer(priv->rx_dmatsk, skb);
>=20
>=20
> --=20
> Jon Smirl
> jonsmirl@gmail.com

--=20
Domen Puncer | Research & Development
=2E....................................................................=
=2E.......................
Telargo d.o.o. | Zagreb=C5=A1ka cesta 20 | 2000 Maribor | Slovenia
=2E....................................................................=
=2E.......................
www.telargo.com
