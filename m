From: =?UTF-8?B?UmFmYcWCIE1pxYJlY2tp?= <zajec5@gmail.com>
Subject: Re: [PATCH v6 4/9] bgmac: simplify/optimize rx DMA error handling
Date: Tue, 14 Apr 2015 11:19:10 +0200
Message-ID: <CACna6rz-b2TXMPpPdRCiyS45mfZ2pgLRNiCyPpd4XLVDfwfbEA@mail.gmail.com>
References: <1428968537-6181-1-git-send-email-nbd@openwrt.org>
	<1428968537-6181-4-git-send-email-nbd@openwrt.org>
	<CACna6ry7yD4jb2ph1EOvOrmdWiqOU8+yFQKvH0OCS=haH4dUqA@mail.gmail.com>
	<552CDA4D.6080702@openwrt.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Network Development <netdev@vger.kernel.org>,
	Hauke Mehrtens <hauke@hauke-m.de>
To: Felix Fietkau <nbd@openwrt.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f170.google.com ([209.85.213.170]:33042 "EHLO
	mail-ig0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752500AbbDNJTK convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 14 Apr 2015 05:19:10 -0400
Received: by igbpi8 with SMTP id pi8so43443490igb.0
        for <netdev@vger.kernel.org>; Tue, 14 Apr 2015 02:19:10 -0700 (PDT)
In-Reply-To: <552CDA4D.6080702@openwrt.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 14 April 2015 at 11:13, Felix Fietkau <nbd@openwrt.org> wrote:
> On 2015-04-14 07:55, Rafa=C5=82 Mi=C5=82ecki wrote:
>> On 14 April 2015 at 01:42, Felix Fietkau <nbd@openwrt.org> wrote:
>>> @@ -528,14 +524,14 @@ static void bgmac_dma_rx_ring_free(struct bgm=
ac *bgmac,
>>>
>>>         for (i =3D 0; i < ring->num_slots; i++) {
>>>                 slot =3D &ring->slots[i];
>>> -               if (!slot->buf)
>>> +               if (!slot->dma_addr)
>>>                         continue;
>>
>> I think it breaks error path of bgmac_dma_alloc. It may happen that
>> during DMA alloc we alloc skb and then we fail to map it. In such ca=
se
>> buf should be freed. Please trace how bgmac_dma_free is used in
>> bgmac_dma_alloc.
> I don't think so: bgmac_dma_rx_skb_for_slot handles both buffer
> allocation and dma mapping. If dma mapping fails, the buffer is freed
> before any part of the slot is overwritten.

Oops, I think I just spotted a memory leak then.

If bgmac_dma_rx_skb_for_slot fails to do DMA mapping it returns an
error without freeing a skb.

--=20
Rafa=C5=82
