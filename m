From: Ian Campbell <Ian.Campbell@eu.citrix.com>
Subject: Re: [PATCH 1/8] vxge: convert to SKB paged frag API.
Date: Thu, 6 Oct 2011 08:05:56 +0100
Message-ID: <1317884756.24742.13.camel@dagon.hellion.org.uk>
References: <1317810511.21903.204.camel@zakaz.uk.xensource.com>
	 <1317810532-24984-1-git-send-email-ian.campbell@citrix.com>
	 <CAHXqBFKX5eojLMhT1MW1inAUH9cfVne4-rhDQYSLsUh-OTzuPQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Jon Mason <jdmason@kudzu.us>
To: =?UTF-8?Q?Micha=C5=82_Miros=C5=82aw?= <mirqus@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.ctxuk.citrix.com ([62.200.22.115]:8959 "EHLO
	SMTP.EU.CITRIX.COM" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757829Ab1JFHF6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 6 Oct 2011 03:05:58 -0400
In-Reply-To: <CAHXqBFKX5eojLMhT1MW1inAUH9cfVne4-rhDQYSLsUh-OTzuPQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2011-10-05 at 22:03 +0100, Micha=C5=82 Miros=C5=82aw wrote:
> 2011/10/5 Ian Campbell <ian.campbell@citrix.com>:
> [...]
> > --- a/drivers/net/ethernet/neterion/vxge/vxge-main.c
> > +++ b/drivers/net/ethernet/neterion/vxge/vxge-main.c
> > @@ -923,9 +923,9 @@ vxge_xmit(struct sk_buff *skb, struct net_devic=
e *dev)
> >                if (!frag->size)
> >                        continue;
> >
> > -               dma_pointer =3D (u64) pci_map_page(fifo->pdev, frag=
->page,
> > -                               frag->page_offset, frag->size,
> > -                               PCI_DMA_TODEVICE);
> > +               dma_pointer =3D (u64)skb_frag_dma_map(&fifo->pdev->=
dev, frag,
> > +                                                   0, frag->size,
> > +                                                   PCI_DMA_TODEVIC=
E);
>=20
> This should be DMA_TO_DEVICE instead of PCI_DMA_TODEVICE.
>=20
> >
> >                if (unlikely(pci_dma_mapping_error(fifo->pdev, dma_p=
ointer)))
> >                        goto _exit2;
>=20
> I would also change this to dma_mapping_error() in one go.
>=20
> Just a random patch check.

Thanks Micha=C5=82.

I'm sure I must have made the same mistakes in a whole bunch of patches
which have already been applied. I'll knock up a fixup patch.

Cheers,
Ian.

>=20
> Best Regards,
> Micha=C5=82 Miros=C5=82aw
