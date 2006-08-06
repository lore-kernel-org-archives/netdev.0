From: "Edgar E. Iglesias" <edgar.iglesias@axis.com>
Subject: Re: [PATCH] [e1000]: Remove unnecessary tx_lock
Date: Sun, 6 Aug 2006 11:03:54 +0200
Message-ID: <20060806090354.GB22168@edgar.underground.se.axis.com>
References: <20060806080659.GA22168@edgar.underground.se.axis.com> <E1G9dyx-0007Yv-00@gondolin.me.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "Edgar E. Iglesias" <edgar.iglesias@axis.com>, davem@davemloft.net,
	hadi@cyberus.ca, shemminger@osdl.org, mchan@broadcom.com,
	jesse.brandeburg@intel.com, auke-jan.h.kok@intel.com,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from miranda.se.axis.com ([193.13.178.8]:41639 "EHLO
	miranda.se.axis.com") by vger.kernel.org with ESMTP
	id S1750805AbWHFJD5 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 6 Aug 2006 05:03:57 -0400
Received: from axis.com (edgar.se.axis.com [10.92.151.1])
	by miranda.se.axis.com (8.12.9/8.12.9/Debian-5local0.1) with ESMTP id k7693sP0031114
	for <netdev@vger.kernel.org>; Sun, 6 Aug 2006 11:03:54 +0200
To: Herbert Xu <herbert@gondor.apana.org.au>
Content-Disposition: inline
In-Reply-To: <E1G9dyx-0007Yv-00@gondolin.me.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sun, Aug 06, 2006 at 06:27:35PM +1000, Herbert Xu wrote:
> Edgar E. Iglesias <edgar.iglesias@axis.com> wrote:
> > 
> > It makes sense, but I see a problem with this. It will remove some of the
> > control applications have on how much of their data gets queued on local
> > queues. Small SNDBUF's are sometimes used to somewhat avoid/control latency.
> 
> For UDP yes but does this really make sense for TCP?
> 

I don't know :)

The flow may end up with SNDBUF worth of skbs on the socket
transmit_queue + cwnd worth of skbs on the qdisc queue + full tx ring. In slow
start we'll increase cwnd and won't se packet loss until the qdisc is full
(which might be at 1000 pkts).

If the flow is locally limited, won't we end up with a very latent flow? where
moste packets will be on the qdisc.

I agree that in general this is an effect of users having to large qdisc 
queues, but today maybe it is beeing somewhat avoided by apps setting small 
SNDBUF's. So I kind of agree with what you suggest but there might be risks.

Best regards
-- 
        Programmer
        Edgar E. Iglesias <edgar.iglesias@axis.com> 46.46.272.1946
