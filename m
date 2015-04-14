From: =?UTF-8?B?UmFmYcWCIE1pxYJlY2tp?= <zajec5@gmail.com>
Subject: Re: [PATCH v6 4/9] bgmac: simplify/optimize rx DMA error handling
Date: Tue, 14 Apr 2015 11:37:54 +0200
Message-ID: <CACna6rx_6NRnA4s_b8WspTAm3SichxqQAN5VzK9MgcaKfXVD-w@mail.gmail.com>
References: <1428968537-6181-1-git-send-email-nbd@openwrt.org>
	<1428968537-6181-4-git-send-email-nbd@openwrt.org>
	<CACna6ry7yD4jb2ph1EOvOrmdWiqOU8+yFQKvH0OCS=haH4dUqA@mail.gmail.com>
	<552CDA4D.6080702@openwrt.org>
	<CACna6rz-b2TXMPpPdRCiyS45mfZ2pgLRNiCyPpd4XLVDfwfbEA@mail.gmail.com>
	<552CDD58.5030904@openwrt.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Network Development <netdev@vger.kernel.org>,
	Hauke Mehrtens <hauke@hauke-m.de>
To: Felix Fietkau <nbd@openwrt.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f173.google.com ([209.85.213.173]:36827 "EHLO
	mail-ig0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751795AbbDNJhy convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 14 Apr 2015 05:37:54 -0400
Received: by igblo3 with SMTP id lo3so68999085igb.1
        for <netdev@vger.kernel.org>; Tue, 14 Apr 2015 02:37:54 -0700 (PDT)
In-Reply-To: <552CDD58.5030904@openwrt.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 14 April 2015 at 11:26, Felix Fietkau <nbd@openwrt.org> wrote:
> On 2015-04-14 11:19, Rafa=C5=82 Mi=C5=82ecki wrote:
>> On 14 April 2015 at 11:13, Felix Fietkau <nbd@openwrt.org> wrote:
>>> On 2015-04-14 07:55, Rafa=C5=82 Mi=C5=82ecki wrote:
>>>> On 14 April 2015 at 01:42, Felix Fietkau <nbd@openwrt.org> wrote:
>>>>> @@ -528,14 +524,14 @@ static void bgmac_dma_rx_ring_free(struct b=
gmac *bgmac,
>>>>>
>>>>>         for (i =3D 0; i < ring->num_slots; i++) {
>>>>>                 slot =3D &ring->slots[i];
>>>>> -               if (!slot->buf)
>>>>> +               if (!slot->dma_addr)
>>>>>                         continue;
>>>>
>>>> I think it breaks error path of bgmac_dma_alloc. It may happen tha=
t
>>>> during DMA alloc we alloc skb and then we fail to map it. In such =
case
>>>> buf should be freed. Please trace how bgmac_dma_free is used in
>>>> bgmac_dma_alloc.
>>> I don't think so: bgmac_dma_rx_skb_for_slot handles both buffer
>>> allocation and dma mapping. If dma mapping fails, the buffer is fre=
ed
>>> before any part of the slot is overwritten.
>>
>> Oops, I think I just spotted a memory leak then.
>>
>> If bgmac_dma_rx_skb_for_slot fails to do DMA mapping it returns an
>> error without freeing a skb.
> It neither allocates, nor frees an skb - I should probably rename tha=
t
> function in a later patch round.
>
> Allocation does:
>         buf =3D netdev_alloc_frag(BGMAC_RX_ALLOC_SIZE);
>
> When handling a DMA mapping error, it does this:
>         put_page(virt_to_head_page(buf));
>
> Where's the memory leak?

Oooh, sorry. I didn't understand put_page. I just expected direct
kfree here. It's alright then, sorry.

--=20
Rafa=C5=82
