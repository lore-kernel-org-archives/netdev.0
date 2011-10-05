From: =?ISO-8859-2?Q?Micha=B3_Miros=B3aw?= <mirqus@gmail.com>
Subject: Re: [PATCH 1/8] vxge: convert to SKB paged frag API.
Date: Wed, 5 Oct 2011 23:03:27 +0200
Message-ID: <CAHXqBFKX5eojLMhT1MW1inAUH9cfVne4-rhDQYSLsUh-OTzuPQ@mail.gmail.com>
References: <1317810511.21903.204.camel@zakaz.uk.xensource.com> <1317810532-24984-1-git-send-email-ian.campbell@citrix.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-2
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, Jon Mason <jdmason@kudzu.us>
To: Ian Campbell <ian.campbell@citrix.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-iy0-f174.google.com ([209.85.210.174]:43402 "EHLO
	mail-iy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757872Ab1JEVDr convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 5 Oct 2011 17:03:47 -0400
Received: by iakk32 with SMTP id k32so2198978iak.19
        for <netdev@vger.kernel.org>; Wed, 05 Oct 2011 14:03:47 -0700 (PDT)
In-Reply-To: <1317810532-24984-1-git-send-email-ian.campbell@citrix.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

2011/10/5 Ian Campbell <ian.campbell@citrix.com>:
[...]
> --- a/drivers/net/ethernet/neterion/vxge/vxge-main.c
> +++ b/drivers/net/ethernet/neterion/vxge/vxge-main.c
> @@ -923,9 +923,9 @@ vxge_xmit(struct sk_buff *skb, struct net_device =
*dev)
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0if (!frag->size)
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0continue;
>
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 dma_pointer =3D (u64) pci_map_page(fifo=
->pdev, frag->page,
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 frag->p=
age_offset, frag->size,
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 PCI_DMA=
_TODEVICE);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 dma_pointer =3D (u64)skb_frag_dma_map(&=
fifo->pdev->dev, frag,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 0, frag->size,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 PCI_DMA_TODEVICE);

This should be DMA_TO_DEVICE instead of PCI_DMA_TODEVICE.

>
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0if (unlikely(pci_dma_mapping_error(fif=
o->pdev, dma_pointer)))
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0goto _exit2;

I would also change this to dma_mapping_error() in one go.

Just a random patch check.

Best Regards,
Micha=B3 Miros=B3aw
