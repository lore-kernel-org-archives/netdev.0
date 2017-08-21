From: Willem de Bruijn <willemdebruijn.kernel@gmail.com>
Subject: Re: [PATCH net] udp: on peeking bad csum, drop packets even if not at head
Date: Mon, 21 Aug 2017 18:37:29 -0400
Message-ID: <CAF=yD-Ki-=yr+U6aeTmdqziWpv3WW6kH+ZN7mLB=F_XSWw_Q9Q@mail.gmail.com>
References: <20170821213912.93333-1-willemdebruijn.kernel@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: David Miller <davem@davemloft.net>,
        Paolo Abeni <pabeni@redhat.com>,
        Willem de Bruijn <willemb@google.com>,
        Eric Dumazet <eric.dumazet@gmail.com>
To: Network Development <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f52.google.com ([209.85.218.52]:34076 "EHLO
        mail-oi0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932065AbdHUWiK (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 21 Aug 2017 18:38:10 -0400
Received: by mail-oi0-f52.google.com with SMTP id j144so41394720oib.1
        for <netdev@vger.kernel.org>; Mon, 21 Aug 2017 15:38:10 -0700 (PDT)
In-Reply-To: <20170821213912.93333-1-willemdebruijn.kernel@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Aug 21, 2017 at 5:39 PM, Willem de Bruijn
<willemdebruijn.kernel@gmail.com> wrote:
> From: Willem de Bruijn <willemb@google.com>
>
> When peeking, if a bad csum is discovered, the skb is unlinked from
> the queue with __sk_queue_drop_skb and the peek operation restarted.
>
> __sk_queue_drop_skb only drops packets that match the queue head. With
> sk_peek_off, the skb need not be at head, causing the call to fail and
> the same skb to be found again on restart.
>
> Walk the queue to find the correct skb. Limit the walk to sk_peek_off,
> to bound cycle cost to at most twice the original skb_queue_walk in
> __skb_try_recv_from_queue.
>
> The operation may race with updates to sk_peek_off. As the operation
> is retried, it will eventually succeed.
>
> Signed-off-by: Willem de Bruijn <willemb@google.com>

Eric just suggested an alternative that does not require looping, which
is much nicer.
