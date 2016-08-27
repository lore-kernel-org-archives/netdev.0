From: Neal Cardwell <ncardwell@google.com>
Subject: Re: [PATCH net-next] tcp: add tcp_add_backlog()
Date: Sat, 27 Aug 2016 14:24:54 -0400
Message-ID: <CADVnQymHib8x0mhi2St0dZ5WfzxcMCiwxmg-LdAg=33Z+6MMRQ@mail.gmail.com>
References: <1472308674.14381.226.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>,
        netdev <netdev@vger.kernel.org>,
        Yuchung Cheng <ycheng@google.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f41.google.com ([209.85.218.41]:33679 "EHLO
        mail-oi0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754209AbcH0SZZ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 27 Aug 2016 14:25:25 -0400
Received: by mail-oi0-f41.google.com with SMTP id c15so150351893oig.0
        for <netdev@vger.kernel.org>; Sat, 27 Aug 2016 11:25:25 -0700 (PDT)
In-Reply-To: <1472308674.14381.226.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Aug 27, 2016 at 10:37 AM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> From: Eric Dumazet <edumazet@google.com>
>
> When TCP operates in lossy environments (between 1 and 10 % packet
> losses), many SACK blocks can be exchanged, and I noticed we could
> drop them on busy senders, if these SACK blocks have to be queued
> into the socket backlog.
>
> While the main cause is the poor performance of RACK/SACK processing,
> we can try to avoid these drops of valuable information that can lead to
> spurious timeouts and retransmits.
>
> Cause of the drops is the skb->truesize overestimation caused by :
>
> - drivers allocating ~2048 (or more) bytes as a fragment to hold an
>   Ethernet frame.
>
> - various pskb_may_pull() calls bringing the headers into skb->head
>   might have pulled all the frame content, but skb->truesize could
>   not be lowered, as the stack has no idea of each fragment truesize.
>
> The backlog drops are also more visible on bidirectional flows, since
> their sk_rmem_alloc can be quite big.
>
> Let's add some room for the backlog, as only the socket owner
> can selectively take action to lower memory needs, like collapsing
> receive queues or partial ofo pruning.
>
> Signed-off-by: Eric Dumazet <edumazet@google.com>
> Cc: Yuchung Cheng <ycheng@google.com>
> Cc: Neal Cardwell <ncardwell@google.com>
> ---
>  include/net/tcp.h   |    1 +
>  net/ipv4/tcp_ipv4.c |   33 +++++++++++++++++++++++++++++----
>  net/ipv6/tcp_ipv6.c |    5 +----
>  3 files changed, 31 insertions(+), 8 deletions(-)
>
> diff --git a/include/net/tcp.h b/include/net/tcp.h
> index 25d64f6de69e1f639ed1531bf2d2df3f00fd76a2..5f5f09f6e019682ef29c864d2f43a8f247fcdd9a 100644

Thanks for doing this, and thanks for the detailed answers to Yuchung's e-mail!

Acked-by: Neal Cardwell <ncardwell@google.com>

neal
