From: =?ISO-8859-2?Q?Micha=B3_Miros=B3aw?= <mirqus@gmail.com>
Subject: Re: [PATCH 1/8] vxge: convert to SKB paged frag API.
Date: Thu, 6 Oct 2011 22:45:57 +0200
Message-ID: <CAHXqBFJsGcAdH0zFS_Gd34oR3Ov6ssbXRMzK-KrnSxq8c3=WNg@mail.gmail.com>
References: <1317810511.21903.204.camel@zakaz.uk.xensource.com>
 <1317810532-24984-1-git-send-email-ian.campbell@citrix.com>
 <CAHXqBFKX5eojLMhT1MW1inAUH9cfVne4-rhDQYSLsUh-OTzuPQ@mail.gmail.com>
 <1317884756.24742.13.camel@dagon.hellion.org.uk> <1317916822.21903.252.camel@zakaz.uk.xensource.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-2
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Jon Mason <jdmason@kudzu.us>
To: Ian Campbell <Ian.Campbell@citrix.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-iy0-f174.google.com ([209.85.210.174]:45073 "EHLO
	mail-iy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754560Ab1JFUqR convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 6 Oct 2011 16:46:17 -0400
Received: by iakk32 with SMTP id k32so3369168iak.19
        for <netdev@vger.kernel.org>; Thu, 06 Oct 2011 13:46:17 -0700 (PDT)
In-Reply-To: <1317916822.21903.252.camel@zakaz.uk.xensource.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

W dniu 6 pa=BCdziernika 2011 18:00 u=BFytkownik Ian Campbell
<Ian.Campbell@citrix.com> napisa=B3:
> On Thu, 2011-10-06 at 08:05 +0100, Ian Campbell wrote:
>> On Wed, 2011-10-05 at 22:03 +0100, Micha=B3 Miros=B3aw wrote:
>> > 2011/10/5 Ian Campbell <ian.campbell@citrix.com>:
>> > [...]
>> > > --- a/drivers/net/ethernet/neterion/vxge/vxge-main.c
>> > > +++ b/drivers/net/ethernet/neterion/vxge/vxge-main.c
>> > > @@ -923,9 +923,9 @@ vxge_xmit(struct sk_buff *skb, struct net_de=
vice *dev)
>> > > =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0if (!frag->size)
>> > > =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0continue;
>> > >
>> > > - =A0 =A0 =A0 =A0 =A0 =A0 =A0 dma_pointer =3D (u64) pci_map_page=
(fifo->pdev, frag->page,
>> > > - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 fr=
ag->page_offset, frag->size,
>> > > - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 PC=
I_DMA_TODEVICE);
>> > > + =A0 =A0 =A0 =A0 =A0 =A0 =A0 dma_pointer =3D (u64)skb_frag_dma_=
map(&fifo->pdev->dev, frag,
>> > > + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 0, frag->size,
>> > > + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 PCI_DMA_TODEVICE);
>> >
>> > This should be DMA_TO_DEVICE instead of PCI_DMA_TODEVICE.
>> > > =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0if (unlikely(pci_dma_mapping_erro=
r(fifo->pdev, dma_pointer)))
>> > > =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0goto _exit2;
>> > I would also change this to dma_mapping_error() in one go.
>> > Just a random patch check.
>> Thanks Micha=B3.
>> I'm sure I must have made the same mistakes in a whole bunch of patc=
hes
>> which have already been applied. I'll knock up a fixup patch.
> Here it is. David, if you want N separate patches (or a git pull
> request?) let me know.

There's a catch there, though:

[...]
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0mapping =3D skb_frag_d=
ma_map(&tp->pdev->dev, frag, 0,
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0len, PCI_DMA_TODEVICE);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0len, DMA_TO_DEVICE);
>
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0tnapi->tx_buffers[entr=
y].skb =3D NULL;
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0dma_unmap_addr_set(&tn=
api->tx_buffers[entry], mapping,
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 mapping);
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (pci_dma_mapping_err=
or(tp->pdev, mapping))
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (dma_mapping_error(t=
p->pdev, mapping))

dma_mapping_error() takes struct device *, so those changes should be:

dma_mapping_error(&tp->pdev->dev, mapping)

(Like skb_frag_dma_map()'s first argument).

Best Regards,
Micha=B3 Miros=B3aw
