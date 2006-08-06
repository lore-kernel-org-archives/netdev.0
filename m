From: "Edgar E. Iglesias" <edgar.iglesias@axis.com>
Subject: Re: [PATCH] [e1000]: Remove unnecessary tx_lock
Date: Sun, 6 Aug 2006 11:18:53 +0200
Message-ID: <20060806091853.GC22168@edgar.underground.se.axis.com>
References: <20060806080659.GA22168@edgar.underground.se.axis.com> <E1G9dyx-0007Yv-00@gondolin.me.apana.org.au> <20060806090354.GB22168@edgar.underground.se.axis.com> <20060806091020.GA29454@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "Edgar E. Iglesias" <edgar.iglesias@axis.com>, davem@davemloft.net,
	hadi@cyberus.ca, shemminger@osdl.org, mchan@broadcom.com,
	jesse.brandeburg@intel.com, auke-jan.h.kok@intel.com,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from miranda.se.axis.com ([193.13.178.8]:30890 "EHLO
	miranda.se.axis.com") by vger.kernel.org with ESMTP
	id S1750914AbWHFJS4 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 6 Aug 2006 05:18:56 -0400
Received: from axis.com (edgar.se.axis.com [10.92.151.1])
	by miranda.se.axis.com (8.12.9/8.12.9/Debian-5local0.1) with ESMTP id k769IrP0032237
	for <netdev@vger.kernel.org>; Sun, 6 Aug 2006 11:18:53 +0200
To: Herbert Xu <herbert@gondor.apana.org.au>
Content-Disposition: inline
In-Reply-To: <20060806091020.GA29454@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sun, Aug 06, 2006 at 07:10:20PM +1000, Herbert Xu wrote:
> On Sun, Aug 06, 2006 at 11:03:54AM +0200, Edgar E. Iglesias wrote:
> >
> > > For UDP yes but does this really make sense for TCP?
> > 
> > I don't know :)
> > 
> > The flow may end up with SNDBUF worth of skbs on the socket
> > transmit_queue + cwnd worth of skbs on the qdisc queue + full tx ring. In slow
> > start we'll increase cwnd and won't se packet loss until the qdisc is full
> > (which might be at 1000 pkts).
> 
> For TCP, the packets stay on the transmit queue until they're acked.
> So all those packets on the qdisc queue (and tx ring) are still charged
> to the socket.  The only difference is that right now we're double-
> charging the ones on the qdisc queue..

I see, then I guess this won't be a problem.

Thanks,
-- 
        Programmer
        Edgar E. Iglesias <edgar.iglesias@axis.com> 46.46.272.1946
