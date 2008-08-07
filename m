From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: qdisc_enqueue, NET_XMIT_SUCCESS and kfree_skb
Date: Thu, 7 Aug 2008 11:39:30 +0000
Message-ID: <20080807113930.GB12654@ff.dom.local>
References: <20080807100910.GA12391@ff.dom.local> <20080807.031058.193703340.davem@davemloft.net> <20080807103130.GA12654@ff.dom.local> <20080807.034545.202633862.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: jussi.kivilinna@mbnet.fi, kaber@trash.net, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ug-out-1314.google.com ([66.249.92.171]:65225 "EHLO
	ug-out-1314.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753376AbYHGMcc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Aug 2008 08:32:32 -0400
Received: by ug-out-1314.google.com with SMTP id h2so328394ugf.16
        for <netdev@vger.kernel.org>; Thu, 07 Aug 2008 05:32:30 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20080807.034545.202633862.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Aug 07, 2008 at 03:45:45AM -0700, David Miller wrote:
...
> 
> BTW, speaking of ->requeue(), I think we could easily eliminate
> that thing.  It only exists because we allow drivers to kick things
> back to us via ->hard_start_xmit() return values.
> 
> There are two cases:
> 
> 1) NETDEV_TX_LOCKED... thanks to the bogon named LLTX
> 
> 2) NETDEV_TX_BUSY, which is pretty much a bug
> 
>    %99.999 of the cases that return NETDEV_TX_BUSY are error
>    conditions in the driver which log a message and we could
>    just as validly drop the packet for this case
> 
> But anyways, LLTX isn't dying tomorrow as much as we'd like it go
> away.
> 
> But we could cache the SKB instead of requeueing it, just like how
> we handle the ->gso_skb right now.
> 
> In fact it seems we can just reuse the ->gso_skb Qdisc member for
> this purpose.
> 
> Then all of the ->requeue() code and resulting complexity can just
> go away.

In most cases it looks like the right thing, but it seems there are
cases (RT or OOB) which could need more control on this, so they would
sometimes prefer to change the order of next xmitted packet if
previous had failed, I guess.

Jarek P.
