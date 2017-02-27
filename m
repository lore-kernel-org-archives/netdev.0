From: Iyappan Subramanian <isubramanian@apm.com>
Subject: Re: [PATCH net-next 5/6] drivers: net: xgene-v2: Add transmit and receive
Date: Sun, 26 Feb 2017 21:11:33 -0800
Message-ID: <CAKh23FnfarredMmtGiL25KmQwWus36aGv0dKoWnbmF-nwgJkKg@mail.gmail.com>
References: <1485889401-13909-1-git-send-email-isubramanian@apm.com>
 <1485889401-13909-6-git-send-email-isubramanian@apm.com> <fb8fcd33-4b5b-5999-7662-4165aeb179e1@gmail.com>
 <063D6719AE5E284EB5DD2968C1650D6DB0277BB0@AcuExch.aculab.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Florian Fainelli <f.fainelli@gmail.com>,
        "davem@davemloft.net" <davem@davemloft.net>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "linux-arm-kernel@lists.infradead.org"
        <linux-arm-kernel@lists.infradead.org>,
        "patches@apm.com" <patches@apm.com>,
        "kchudgar@apm.com" <kchudgar@apm.com>
To: David Laight <David.Laight@aculab.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ua0-f172.google.com ([209.85.217.172]:34848 "EHLO
        mail-ua0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751096AbdB0FLf (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 27 Feb 2017 00:11:35 -0500
Received: by mail-ua0-f172.google.com with SMTP id 40so44874379uau.2
        for <netdev@vger.kernel.org>; Sun, 26 Feb 2017 21:11:34 -0800 (PST)
In-Reply-To: <063D6719AE5E284EB5DD2968C1650D6DB0277BB0@AcuExch.aculab.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Feb 1, 2017 at 3:09 AM, David Laight <David.Laight@aculab.com> wrote:
> From Florian Fainelli
>> Sent: 31 January 2017 20:33
>> On 01/31/2017 11:03 AM, Iyappan Subramanian wrote:
>> > This patch adds,
>> >     - Transmit
>> >     - Transmit completion poll
>> >     - Receive poll
>> >     - NAPI handler
>> >
>> > and enables the driver.
>> >
>> > Signed-off-by: Iyappan Subramanian <isubramanian@apm.com>
>> > Signed-off-by: Keyur Chudgar <kchudgar@apm.com>
>> > ---
>>
>> > +
>> > +   tx_ring = pdata->tx_ring;
>> > +   tail = tx_ring->tail;
>> > +   len = skb_headlen(skb);
>> > +   raw_desc = &tx_ring->raw_desc[tail];
>> > +
>> > +   /* Tx descriptor not available */
>> > +   if (!GET_BITS(E, le64_to_cpu(raw_desc->m0)) ||
>> > +       GET_BITS(PKT_SIZE, le64_to_cpu(raw_desc->m0)))
>> > +           return NETDEV_TX_BUSY;
>
> Aren't you supposed to detect 'ring full' and stop the code
> giving you packets to transmit.

I'll add stop queue and wake queue.

>
>> > +
>> > +   /* Packet buffers should be 64B aligned */
>
> Is that really a requirement of the hardware?
> Almost all ethernet frames are 4n+2 aligned.

Yes, it's a hardware requirement.

>
>> > +   pkt_buf = dma_alloc_coherent(dev, XGENE_ENET_STD_MTU, &dma_addr,
>> > +                                GFP_ATOMIC);
>> > +   if (unlikely(!pkt_buf))
>> > +           goto out;
>>
>> Can't you obtain a DMA-API mapping for skb->data and pass it down to the
>> hardware? This copy here is inefficient.
>>
>> > +
>> > +   memcpy(pkt_buf, skb->data, len);
>
> You really need to verify that the len <= XGENE_ENET_STD_MTU.

This version of the driver, doesn't support jumbo frame.  So, the
check is not required.

>
> Isn't this code only transmitting the 'head' of the packet?
> What about the fragments??

This driver doesn't enable SG yet.

> ...
>         David
>
