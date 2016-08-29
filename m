From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] tcp: add tcp_add_backlog()
Date: Mon, 29 Aug 2016 00:20:42 -0400 (EDT)
Message-ID: <20160829.002042.876057972687474994.davem@davemloft.net>
References: <1472308674.14381.226.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, ncardwell@google.com, ycheng@google.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:49368 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750949AbcH2EVH (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 29 Aug 2016 00:21:07 -0400
In-Reply-To: <1472308674.14381.226.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Sat, 27 Aug 2016 07:37:54 -0700

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

Really nice change, thanks Eric.
