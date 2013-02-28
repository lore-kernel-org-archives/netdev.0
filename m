From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [PATCH net] tcp: Don't collapse if resulting skb could overflow
 skb->csum_start
Date: Thu, 28 Feb 2013 16:45:02 +0000
Message-ID: <20130228164502.GD7558@casper.infradead.org>
References: <20130228102603.GA7558@casper.infradead.org>
 <1362068326.15793.33.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, netdev@vger.kernel.org, foraker1@llnl.gov
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from casper.infradead.org ([85.118.1.10]:51072 "EHLO
	casper.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753277Ab3B1QpH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 Feb 2013 11:45:07 -0500
Content-Disposition: inline
In-Reply-To: <1362068326.15793.33.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 02/28/13 at 08:18am, Eric Dumazet wrote:
> but.... what is the value of skb_availroom(to) ?
> 
> The earlier test at line 2302 should already guard this case ?
> 
>                /* Punt if not enough space exists in the first SKB for
>                  * the data in the second
>                  */
>                 if (skb->len > skb_availroom(to))
>                         break;

Only if it is guaranteed that we never see an MSS > 64K.

Assuming that is true forever, then a21d45726 (tcp: avoid order-1
allocations on wifi and tx path) does in fact resolve this
issue at the cost of not being able to use the extra room
kmalloc() might have given us in __alloc_skb() for collapsing.

Was that an intentional side effect of a21d45726?
