From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next] tcp: add tcp_add_backlog()
Date: Mon, 29 Aug 2016 12:22:37 -0700
Message-ID: <1472498557.14381.275.camel@edumazet-glaptop3.roam.corp.google.com>
References: <1472308674.14381.226.camel@edumazet-glaptop3.roam.corp.google.com>
         <20160829185137.GC11144@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
        netdev <netdev@vger.kernel.org>,
        Neal Cardwell <ncardwell@google.com>,
        Yuchung Cheng <ycheng@google.com>
To: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f41.google.com ([209.85.220.41]:34275 "EHLO
        mail-pa0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751378AbcH2TWk (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 29 Aug 2016 15:22:40 -0400
Received: by mail-pa0-f41.google.com with SMTP id fi15so52293713pac.1
        for <netdev@vger.kernel.org>; Mon, 29 Aug 2016 12:22:39 -0700 (PDT)
In-Reply-To: <20160829185137.GC11144@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2016-08-29 at 15:51 -0300, Marcelo Ricardo Leitner wrote:
> 	skb->truesize = SKB_TRUESIZE(skb_end_offset(skb));
> 
> Shouldn't __pskb_pull_tail() already fix this? As it seems the expected
> behavior and it would have a more global effect then. For drivers not
> using copybreak, that's needed here anyway, but maybe this help other
> protocols/situations too.

That would be difficult, because some callers do their own truesize
tacking (skb might be attached/charged to a socket, so changing
skb->truesize would need to adjust the amount that was charged)

This is why pskb_expand_head() is not allowed to mess with skb->truesize
(but in the opposite way, since we probably are increasing
skb->truesize)

Not sure it is worth the pain in fast path, where packets are consumed
so fast that their skb->truesize being slightly over estimated is not an
issue.
