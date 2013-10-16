From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: Re: [PATCH RFC 0/2] xfrm: Remove ancient sleeping code
Date: Wed, 16 Oct 2013 11:45:49 +0200
Message-ID: <20131016094549.GZ7660@secunet.com>
References: <20131010063301.GO7660@secunet.com>
 <20131011.150124.527914076255487526.davem@davemloft.net>
 <20131015073020.GV7660@secunet.com>
 <1381881514.2045.82.camel@edumazet-glaptop.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([195.81.216.161]:33264 "EHLO a.mx.secunet.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1760181Ab3JPJpw (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 16 Oct 2013 05:45:52 -0400
Content-Disposition: inline
In-Reply-To: <1381881514.2045.82.camel@edumazet-glaptop.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Oct 15, 2013 at 04:58:34PM -0700, Eric Dumazet wrote:
> On Tue, 2013-10-15 at 09:30 +0200, Steffen Klassert wrote:
> 
> > Right, that's why I've limited the queue to 100 packets. We can
> > queue the SYNs of up to 100 tcp connestions that want to use
> > this IPsec state. It surely can happen that we queue multiple
> > retransmitted SYNs if the IPsec resolution is slow. But the
> > queueing code tries at least to get the packets out before
> > the first tcp retransmit. I think there is still room for
> > optimizations, maybe reducing the queue lenght or the queue
> > timeout to avoid queueing retransmitted SYNs as much as possible.
> 
> Note that its totally possible to avoid retransmitting SYN if original
> SYN is still in a host queue.
> 
> We currently increment a SNMP counter when we detect this, we could
> do something else (like not queuing a copy of the packet)
> 
> http://git.kernel.org/cgit/linux/kernel/git/davem/net-next.git/commit/?id=0e280af026a5662ffd57c4e623b822df1f7f47ff

This is interesting, we could do the same check before we queue
the packet and drop it if the original packet is still in a host
queue.

I'll do a RFC patch.

> 
> Another work in progress is to delay RTO arming at the time TCP
> packet leaves the host queues, instead of at the enqueue time.
> 

That would be even better, are there already patches publicly
available?

Thanks!
