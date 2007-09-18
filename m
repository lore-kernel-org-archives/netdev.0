From: David Miller <davem@davemloft.net>
Subject: Re: SFQ qdisc crashes with limit of 2 packets
Date: Tue, 18 Sep 2007 13:09:57 -0700 (PDT)
Message-ID: <20070918.130957.130617077.davem@davemloft.net>
References: <46F00B80.7050901@trash.net>
	<46F0117A.4060807@trash.net>
	<46F023D0.7030307@trash.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: cebbert@redhat.com, netdev@vger.kernel.org, kuznet@ms2.inr.ac.ru
To: kaber@trash.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:59659
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753425AbXIRUKD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 18 Sep 2007 16:10:03 -0400
In-Reply-To: <46F023D0.7030307@trash.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Patrick McHardy <kaber@trash.net>
Date: Tue, 18 Sep 2007 21:15:28 +0200

> OK the off-by-one prevents an out-of-bounds array access, which
> would cause a crash itself. Despite what I said above, sfq does
> try to handle dequeues while empty, but forgets to update q->tail
> when dropping the last packet from the only active queue, probably
> because it wasn't expected that the queue length is too small to
> queue even a single packet (and that really doesn't make much sense).
> 
> So one possibility for fixing this is to update q->tail in sfq_drop
> when dropping the last packet, but that would still leave the qdisc
> non-functional because of the off-by-one. I chose a different way:
> cap the limit at SFQ_DEPTH-1 and remove the off-by-one, which should
> have no effect on the max (still 127), but prevents the crash since
> we can now queue at least a single packet and q->tail is properly
> updated in sfq_dequeue().
> 
> CCed Alexey just to be safe, but I think the patch should be fine.
> 
> Signed-off-by: Patrick McHardy <kaber@trash.net>

I've applied this to net-2.6, thanks Patrick.

I'll hold off merging this to Linus until later today so
that if some issue is found we can address it.

Thanks.
