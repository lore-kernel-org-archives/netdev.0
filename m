From: saeed bishara <saeed.bishara@gmail.com>
Subject: Re: [PATCH v2] net: add calxeda xgmac ethernet driver
Date: Mon, 31 Oct 2011 09:58:05 +0200
Message-ID: <CAMAG_ecUe3UNYE4pUYA3_NNcK5znotBDvMPfb_BgHmx4ZmgcWQ@mail.gmail.com>
References: <1320010217-17322-1-git-send-email-robherring2@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: joe@perches.com
To: Rob Herring <robherring2@gmail.com>, netdev@vger.kernel.org,
	devicetree-discuss@lists.ozlabs.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vw0-f46.google.com ([209.85.212.46]:36394 "EHLO
	mail-vw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750790Ab1JaH61 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 31 Oct 2011 03:58:27 -0400
Received: by vws1 with SMTP id 1so4631574vws.19
        for <netdev@vger.kernel.org>; Mon, 31 Oct 2011 00:58:26 -0700 (PDT)
In-Reply-To: <1320010217-17322-1-git-send-email-robherring2@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Oct 30, 2011 at 11:30 PM, Rob Herring <robherring2@gmail.com> w=
rote:
> From: Rob Herring <rob.herring@calxeda.com>
Hi Rob, one more comment
>


> +static void xgmac_tx_complete(struct xgmac_priv *priv)
> +{
> + =C2=A0 =C2=A0 =C2=A0 void __iomem *ioaddr =3D priv->base;
> +
> +
> + =C2=A0 =C2=A0 =C2=A0 writel(DMA_STATUS_TU | DMA_STATUS_NIS, ioaddr =
+ XGMAC_DMA_STATUS);
> +
> + =C2=A0 =C2=A0 =C2=A0 while (dma_ring_cnt(priv->tx_head, priv->tx_ta=
il, DMA_TX_RING_SZ)) {
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 unsigned int entry=
 =3D priv->tx_tail;
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 struct sk_buff *sk=
b =3D priv->tx_skbuff[entry];
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 struct xgmac_dma_d=
esc *p =3D priv->dma_tx + entry;
> +
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 /* Check if the de=
scriptor is owned by the DMA. */
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 if (desc_get_owner=
(p))
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 break;
> +
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 /* Verify tx error=
 by looking at the last segment */
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 if (desc_get_tx_ls=
(p))
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 desc_get_tx_status(priv, p);
> +
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 netdev_dbg(priv->d=
ev, "tx ring: curr %d, dirty %d\n",
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 priv->tx_head, priv->tx_tail);
> +
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 dma_unmap_single(p=
riv->device, desc_get_buf_addr(p),
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0desc_get_buf_len(p), DMA_TO_D=
EVICE);
I think you missed to do dma_unmap_page for the skp frags page.
saeed
