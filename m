From: Eric Dumazet <edumazet@google.com>
Subject: Re: [PATCH net] sock: correct sk_wmem_queued accounting on efault in
 tcp zerocopy
Date: Thu, 19 Oct 2017 09:45:14 -0700
Message-ID: <CANn89iJjEG1iVHTKEg3xMpaj6Q1jEE7VMxsKhao-TCrJF8+nSQ@mail.gmail.com>
References: <20171019164039.20927-1-willemdebruijn.kernel@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: netdev <netdev@vger.kernel.org>,
        David Miller <davem@davemloft.net>,
        Willem de Bruijn <willemb@google.com>
To: Willem de Bruijn <willemdebruijn.kernel@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yw0-f196.google.com ([209.85.161.196]:43391 "EHLO
        mail-yw0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754587AbdJSQpP (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 19 Oct 2017 12:45:15 -0400
Received: by mail-yw0-f196.google.com with SMTP id y75so4042263ywg.0
        for <netdev@vger.kernel.org>; Thu, 19 Oct 2017 09:45:15 -0700 (PDT)
In-Reply-To: <20171019164039.20927-1-willemdebruijn.kernel@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Oct 19, 2017 at 9:40 AM, Willem de Bruijn
<willemdebruijn.kernel@gmail.com> wrote:
> From: Willem de Bruijn <willemb@google.com>
>
> Syzkaller hits WARN_ON(sk->sk_wmem_queued) in sk_stream_kill_queues
> after triggering an EFAULT in __zerocopy_sg_from_iter.
>
> On this error, skb_zerocopy_stream_iter resets the skb to its state
> before the operation with __pskb_trim. It cannot kfree_skb like
> datagram callers, as the skb may have data from a previous send call.
>
> __pskb_trim calls skb_condense for unowned skbs, which adjusts their
> truesize. These tcp skbuffs are owned and their truesize must add up
> to sk_wmem_queued. But they match because their skb->sk is NULL until
> tcp_transmit_skb.
>
> Temporarily set skb->sk when calling __pskb_trim to signal that the
> skbuffs are owned and avoid the skb_condense path.
>
> Fixes: 52267790ef52 ("sock: add MSG_ZEROCOPY")
> Signed-off-by: Willem de Bruijn <willemb@google.com>

Reviewed-by: Eric Dumazet <edumazet@google.com>

Thanks a lot Willem.
