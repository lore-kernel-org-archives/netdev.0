From: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>
Subject: Re: [PATCH net-next] tcp: add tcp_add_backlog()
Date: Mon, 29 Aug 2016 16:33:28 -0300
Message-ID: <20160829193328.GD11144@localhost.localdomain>
References: <1472308674.14381.226.camel@edumazet-glaptop3.roam.corp.google.com>
 <20160829185137.GC11144@localhost.localdomain>
 <1472498557.14381.275.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>,
        netdev <netdev@vger.kernel.org>,
        Neal Cardwell <ncardwell@google.com>,
        Yuchung Cheng <ycheng@google.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:42682 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751965AbcH2Tdb (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 29 Aug 2016 15:33:31 -0400
Content-Disposition: inline
In-Reply-To: <1472498557.14381.275.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Aug 29, 2016 at 12:22:37PM -0700, Eric Dumazet wrote:
> On Mon, 2016-08-29 at 15:51 -0300, Marcelo Ricardo Leitner wrote:
> > 	skb->truesize = SKB_TRUESIZE(skb_end_offset(skb));
> > 
> > Shouldn't __pskb_pull_tail() already fix this? As it seems the expected
> > behavior and it would have a more global effect then. For drivers not
> > using copybreak, that's needed here anyway, but maybe this help other
> > protocols/situations too.
> 
> That would be difficult, because some callers do their own truesize
> tacking (skb might be attached/charged to a socket, so changing
> skb->truesize would need to adjust the amount that was charged)
> 
> This is why pskb_expand_head() is not allowed to mess with skb->truesize
> (but in the opposite way, since we probably are increasing
> skb->truesize)
> 

Ok, makes sense.

> Not sure it is worth the pain in fast path, where packets are consumed
> so fast that their skb->truesize being slightly over estimated is not an
> issue.

Good point, thanks.
