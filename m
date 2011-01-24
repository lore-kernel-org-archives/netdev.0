From: Po-Yu Chuang <ratbert.chuang@gmail.com>
Subject: Re: [PATCH v4] net: add Faraday FTMAC100 10/100 Ethernet driver
Date: Mon, 24 Jan 2011 16:26:03 +0800
Message-ID: <AANLkTinsWVHj6qdSS-_ztztcNPHAkwZQnimPbjzvcHb2@mail.gmail.com>
References: <1295537418-2057-1-git-send-email-ratbert.chuang@gmail.com>
 <1295596533-1748-1-git-send-email-ratbert.chuang@gmail.com> <AANLkTikpu05V92T+YvuHW+jcTH-Bu2t6=HoQn5OR3ZhX@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	bhutchings@solarflare.com, eric.dumazet@gmail.com, joe@perches.com,
	dilinger@queued.net, Po-Yu Chuang <ratbert@faraday-tech.com>
To: =?UTF-8?B?TWljaGHFgiBNaXJvc8WCYXc=?= <mirqus@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f46.google.com ([209.85.214.46]:48542 "EHLO
	mail-bw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751871Ab1AXI00 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 24 Jan 2011 03:26:26 -0500
In-Reply-To: <AANLkTikpu05V92T+YvuHW+jcTH-Bu2t6=HoQn5OR3ZhX@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Dear Micha=C5=82,

2011/1/21 Micha=C5=82 Miros=C5=82aw <mirqus@gmail.com>:
> 2011/1/21 Po-Yu Chuang <ratbert.chuang@gmail.com>:
>> From: Po-Yu Chuang <ratbert@faraday-tech.com>
>>
>> FTMAC100 Ethernet Media Access Controller supports 10/100 Mbps and
>> MII. =C2=A0This driver has been working on some ARM/NDS32 SoC's incl=
uding
>> Faraday A320 and Andes AG101.
>>
>> Signed-off-by: Po-Yu Chuang <ratbert@faraday-tech.com>
> [...]
>> +static void ftmac100_txdes_reset(struct ftmac100_txdes *txdes)
>> +{
>> + =C2=A0 =C2=A0 =C2=A0 /* clear all except end of ring bit */
>> + =C2=A0 =C2=A0 =C2=A0 txdes->txdes0 =3D 0;
>> + =C2=A0 =C2=A0 =C2=A0 txdes->txdes1 &=3D FTMAC100_TXDES1_EDOTR;
>> + =C2=A0 =C2=A0 =C2=A0 txdes->txdes2 =3D 0;
>> + =C2=A0 =C2=A0 =C2=A0 txdes->txdes3 =3D 0;
>> +}
>
> This also probably needs cpu_to_le32().

Ah, I missed that. Fixed.

> [...]
>> +static void ftmac100_free_buffers(struct ftmac100 *priv)
>> +{
>> + =C2=A0 =C2=A0 =C2=A0 int i;
>> +
>> + =C2=A0 =C2=A0 =C2=A0 for (i =3D 0; i < RX_QUEUE_ENTRIES; i +=3D 2)=
 {
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 struct ftmac100_r=
xdes *rxdes =3D &priv->descs->rxdes[i];
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 dma_addr_t d =3D =
ftmac100_rxdes_get_dma_addr(rxdes);
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 void *page =3D ft=
mac100_rxdes_get_va(rxdes);
>> +
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 if (d)
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 dma_unmap_single(priv->dev, d, PAGE_SIZE,
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
DMA_FROM_DEVICE);
>> +
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 if (page !=3D NUL=
L)
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 free_page((unsigned long)page);
>> + =C2=A0 =C2=A0 =C2=A0 }
>> +
> [...]
>
>> +static int ftmac100_alloc_buffers(struct ftmac100 *priv)
>> +{
>> + =C2=A0 =C2=A0 =C2=A0 int i;
>> +
>> + =C2=A0 =C2=A0 =C2=A0 priv->descs =3D dma_alloc_coherent(priv->dev,
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
sizeof(struct ftmac100_descs),
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
&priv->descs_dma_addr,
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
GFP_KERNEL | GFP_DMA);
>> + =C2=A0 =C2=A0 =C2=A0 if (priv->descs =3D=3D NULL)
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 return -ENOMEM;
>> +
>> + =C2=A0 =C2=A0 =C2=A0 memset(priv->descs, 0, sizeof(struct ftmac100=
_descs));
>> +
>> + =C2=A0 =C2=A0 =C2=A0 /* initialize RX ring */
>> +
>> + =C2=A0 =C2=A0 =C2=A0 ftmac100_rxdes_set_end_of_ring(&priv->descs->=
rxdes[RX_QUEUE_ENTRIES - 1]);
>> +
>> + =C2=A0 =C2=A0 =C2=A0 for (i =3D 0; i < RX_QUEUE_ENTRIES; i +=3D 2)=
 {
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 struct ftmac100_r=
xdes *rxdes =3D &priv->descs->rxdes[i];
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 void *page;
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 dma_addr_t d;
>> +
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 page =3D (void *)=
__get_free_page(GFP_KERNEL | GFP_DMA);
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 if (page =3D=3D N=
ULL)
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 goto err;
>> +
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 d =3D dma_map_sin=
gle(priv->dev, page, PAGE_SIZE, DMA_FROM_DEVICE);
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 if (unlikely(dma_=
mapping_error(priv->dev, d))) {
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 free_page((unsigned long)page);
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 goto err;
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 }
>> +
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 /*
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0* The hardw=
are enforces a sub-2K maximum packet size, so we
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0* put two b=
uffers on every hardware page.
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0*/
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 ftmac100_rxdes_se=
t_va(rxdes, page);
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 ftmac100_rxdes_se=
t_va(rxdes + 1, page + PAGE_SIZE / 2);
>> +
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 ftmac100_rxdes_se=
t_dma_addr(rxdes, d);
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 ftmac100_rxdes_se=
t_dma_addr(rxdes + 1, d + PAGE_SIZE / 2);
>> +
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 ftmac100_rxdes_se=
t_buffer_size(rxdes, RX_BUF_SIZE);
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 ftmac100_rxdes_se=
t_buffer_size(rxdes + 1, RX_BUF_SIZE);
>> +
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 ftmac100_rxdes_se=
t_dma_own(rxdes);
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 ftmac100_rxdes_se=
t_dma_own(rxdes + 1);
>> + =C2=A0 =C2=A0 =C2=A0 }
> [...]
>
> Did you test this? This looks like it will result in double free afte=
r
> packet RX, as you are giving the same page (referenced once) to two
> distinct RX descriptors, that may be assigned different packets.

Yes, this is tested.

> Since your not implementing any RX offloads, you might just allocate
> fresh skb's with alloc_skb() and store skb pointer in rxdes3. Since

rxdes3 does not store virtual address of an skb.
It stores the address of the buffer allocated while open() and freed
only when stop().
The data in that buffer will be memcpy()ed to an skb allocated in
ftmac100_rx_packet().
No double free happens.

> hardware doesn't touch it, you can skip cpu_to_le32()/le32_to_cpu()
> there (leave a comment, though).

Agree. Thanks.

> Unless this needs to work for ISA devices, you should drop GFP_DMA
> allocation flag.

Ben mentioned about this in the previous mail. I thought that it is OK
to keep GFP_DMA
on ARM platform, but since you point out this flag is for ISA, I will d=
rop it.

best regards,
Po-Yu Chuang
