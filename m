From: =?ISO-8859-2?Q?Micha=B3_Miros=B3aw?= <mirqus@gmail.com>
Subject: Re: [PATCH v4] net: add Faraday FTMAC100 10/100 Ethernet driver
Date: Mon, 24 Jan 2011 21:22:03 +0100
Message-ID: <AANLkTimWuBfeYPOsOFpTiAGS5uHysevAHiOg0svBQ4zW@mail.gmail.com>
References: <1295537418-2057-1-git-send-email-ratbert.chuang@gmail.com>
	<1295596533-1748-1-git-send-email-ratbert.chuang@gmail.com>
	<AANLkTikpu05V92T+YvuHW+jcTH-Bu2t6=HoQn5OR3ZhX@mail.gmail.com>
	<AANLkTinsWVHj6qdSS-_ztztcNPHAkwZQnimPbjzvcHb2@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-2
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	bhutchings@solarflare.com, eric.dumazet@gmail.com, joe@perches.com,
	dilinger@queued.net, Po-Yu Chuang <ratbert@faraday-tech.com>
To: Po-Yu Chuang <ratbert.chuang@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <AANLkTinsWVHj6qdSS-_ztztcNPHAkwZQnimPbjzvcHb2@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

W dniu 24 stycznia 2011 09:26 u=BFytkownik Po-Yu Chuang
<ratbert.chuang@gmail.com> napisa=B3:
> 2011/1/21 Micha=B3 Miros=B3aw <mirqus@gmail.com>:
>> 2011/1/21 Po-Yu Chuang <ratbert.chuang@gmail.com>:
>>> +static void ftmac100_free_buffers(struct ftmac100 *priv)
>>> +{
>>> + =A0 =A0 =A0 int i;
>>> +
>>> + =A0 =A0 =A0 for (i =3D 0; i < RX_QUEUE_ENTRIES; i +=3D 2) {
>>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 struct ftmac100_rxdes *rxdes =3D &pri=
v->descs->rxdes[i];
>>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 dma_addr_t d =3D ftmac100_rxdes_get_d=
ma_addr(rxdes);
>>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 void *page =3D ftmac100_rxdes_get_va(=
rxdes);
>>> +
>>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (d)
>>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 dma_unmap_single(priv=
->dev, d, PAGE_SIZE,
>>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0DMA_FROM_DEVICE);
>>> +
>>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (page !=3D NULL)
>>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 free_page((unsigned l=
ong)page);
>>> + =A0 =A0 =A0 }
>>> +
>> [...]
>>
>>> +static int ftmac100_alloc_buffers(struct ftmac100 *priv)
>>> +{
>>> + =A0 =A0 =A0 int i;
>>> +
>>> + =A0 =A0 =A0 priv->descs =3D dma_alloc_coherent(priv->dev,
>>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0sizeof(struct ftmac100_descs),
>>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0&priv->descs_dma_addr,
>>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0GFP_KERNEL | GFP_DMA);
>>> + =A0 =A0 =A0 if (priv->descs =3D=3D NULL)
>>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 return -ENOMEM;
>>> +
>>> + =A0 =A0 =A0 memset(priv->descs, 0, sizeof(struct ftmac100_descs))=
;
>>> +
>>> + =A0 =A0 =A0 /* initialize RX ring */
>>> +
>>> + =A0 =A0 =A0 ftmac100_rxdes_set_end_of_ring(&priv->descs->rxdes[RX=
_QUEUE_ENTRIES - 1]);
>>> +
>>> + =A0 =A0 =A0 for (i =3D 0; i < RX_QUEUE_ENTRIES; i +=3D 2) {
>>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 struct ftmac100_rxdes *rxdes =3D &pri=
v->descs->rxdes[i];
>>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 void *page;
>>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 dma_addr_t d;
>>> +
>>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 page =3D (void *)__get_free_page(GFP_=
KERNEL | GFP_DMA);
>>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (page =3D=3D NULL)
>>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 goto err;
>>> +
>>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 d =3D dma_map_single(priv->dev, page,=
 PAGE_SIZE, DMA_FROM_DEVICE);
>>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (unlikely(dma_mapping_error(priv->=
dev, d))) {
>>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 free_page((unsigned l=
ong)page);
>>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 goto err;
>>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 }
>>> +
>>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 /*
>>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* The hardware enforces a sub-2K m=
aximum packet size, so we
>>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* put two buffers on every hardwar=
e page.
>>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0*/
>>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 ftmac100_rxdes_set_va(rxdes, page);
>>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 ftmac100_rxdes_set_va(rxdes + 1, page=
 + PAGE_SIZE / 2);
>>> +
>>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 ftmac100_rxdes_set_dma_addr(rxdes, d)=
;
>>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 ftmac100_rxdes_set_dma_addr(rxdes + 1=
, d + PAGE_SIZE / 2);
>>> +
>>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 ftmac100_rxdes_set_buffer_size(rxdes,=
 RX_BUF_SIZE);
>>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 ftmac100_rxdes_set_buffer_size(rxdes =
+ 1, RX_BUF_SIZE);
>>> +
>>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 ftmac100_rxdes_set_dma_own(rxdes);
>>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 ftmac100_rxdes_set_dma_own(rxdes + 1)=
;
>>> + =A0 =A0 =A0 }
>> [...]
>>
>> Did you test this? This looks like it will result in double free aft=
er
>> packet RX, as you are giving the same page (referenced once) to two
>> distinct RX descriptors, that may be assigned different packets.
>
> Yes, this is tested.
>
>> Since your not implementing any RX offloads, you might just allocate
>> fresh skb's with alloc_skb() and store skb pointer in rxdes3. Since
>
> rxdes3 does not store virtual address of an skb.
> It stores the address of the buffer allocated while open() and freed
> only when stop().
> The data in that buffer will be memcpy()ed to an skb allocated in
> ftmac100_rx_packet().
> No double free happens.

Ah, I blindly assumed that you're just appending the buffers to the
skb (using skb_fill_page_desc() and friends). Since you have to mark
descriptors for the device anyway, it might be faster to allocate new
skbs and map those as rx buffers (changing the descriptor's buffer
address after every RX) instead of keeping static buffer and copying
every time. (For small packets it wastes lot of memory, though - so
the right choice depends on the expected workload.)

Best Regards,
Micha=B3 Miros=B3aw
