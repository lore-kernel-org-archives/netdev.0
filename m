From: Willem de Bruijn <willemdebruijn.kernel@gmail.com>
Subject: Re: [PATCH net] udp: on peeking bad csum, drop packets even if not at head
Date: Mon, 21 Aug 2017 21:11:13 -0400
Message-ID: <CAF=yD-K4HKyAY-+-GbUAQE1seQ2-AYU2MVD14+zd9OahfV33VQ@mail.gmail.com>
References: <20170821213912.93333-1-willemdebruijn.kernel@gmail.com>
 <1503355232.2499.15.camel@edumazet-glaptop3.roam.corp.google.com> <CAF=yD-+oht8gPcNdSU1zuj5TrOhq0cuwzzcwiCn676YzKNsn=Q@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: Network Development <netdev@vger.kernel.org>,
        David Miller <davem@davemloft.net>,
        Paolo Abeni <pabeni@redhat.com>,
        Willem de Bruijn <willemb@google.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f52.google.com ([209.85.218.52]:34304 "EHLO
        mail-oi0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754342AbdHVBLy (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 21 Aug 2017 21:11:54 -0400
Received: by mail-oi0-f52.google.com with SMTP id j144so43851963oib.1
        for <netdev@vger.kernel.org>; Mon, 21 Aug 2017 18:11:54 -0700 (PDT)
In-Reply-To: <CAF=yD-+oht8gPcNdSU1zuj5TrOhq0cuwzzcwiCn676YzKNsn=Q@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Aug 21, 2017 at 8:12 PM, Willem de Bruijn
<willemdebruijn.kernel@gmail.com> wrote:
> On Mon, Aug 21, 2017 at 6:40 PM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
>> On Mon, 2017-08-21 at 17:39 -0400, Willem de Bruijn wrote:
>>> From: Willem de Bruijn <willemb@google.com>
>>>
>>> When peeking, if a bad csum is discovered, the skb is unlinked from
>>> the queue with __sk_queue_drop_skb and the peek operation restarted.
>>>
>>> __sk_queue_drop_skb only drops packets that match the queue head. With
>>> sk_peek_off, the skb need not be at head, causing the call to fail and
>>> the same skb to be found again on restart.
>>>
>>> Walk the queue to find the correct skb. Limit the walk to sk_peek_off,
>>> to bound cycle cost to at most twice the original skb_queue_walk in
>>> __skb_try_recv_from_queue.
>>>
>>> The operation may race with updates to sk_peek_off. As the operation
>>> is retried, it will eventually succeed.
>>>
>>> Signed-off-by: Willem de Bruijn <willemb@google.com>
>>
>> You forgot the Fixes: tag, that such a bug fix deserves.
>
> Indeed, sorry. I'm looking into that now. It should be the patch that
> introduced peeking at offset, but need to verify.

It is. Fixes: 627d2d6b5500 ("udp: enable MSG_PEEK at non-zero offset")
