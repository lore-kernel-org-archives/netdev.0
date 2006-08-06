From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH] [e1000]: Remove unnecessary tx_lock
Date: Sun, 6 Aug 2006 19:10:20 +1000
Message-ID: <20060806091020.GA29454@gondor.apana.org.au>
References: <20060806080659.GA22168@edgar.underground.se.axis.com> <E1G9dyx-0007Yv-00@gondolin.me.apana.org.au> <20060806090354.GB22168@edgar.underground.se.axis.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, hadi@cyberus.ca, shemminger@osdl.org,
	mchan@broadcom.com, jesse.brandeburg@intel.com,
	auke-jan.h.kok@intel.com, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:15876 "EHLO
	arnor.apana.org.au") by vger.kernel.org with ESMTP id S1750851AbWHFJKt
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 6 Aug 2006 05:10:49 -0400
To: "Edgar E. Iglesias" <edgar.iglesias@axis.com>
Content-Disposition: inline
In-Reply-To: <20060806090354.GB22168@edgar.underground.se.axis.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sun, Aug 06, 2006 at 11:03:54AM +0200, Edgar E. Iglesias wrote:
>
> > For UDP yes but does this really make sense for TCP?
> 
> I don't know :)
> 
> The flow may end up with SNDBUF worth of skbs on the socket
> transmit_queue + cwnd worth of skbs on the qdisc queue + full tx ring. In slow
> start we'll increase cwnd and won't se packet loss until the qdisc is full
> (which might be at 1000 pkts).

For TCP, the packets stay on the transmit queue until they're acked.
So all those packets on the qdisc queue (and tx ring) are still charged
to the socket.  The only difference is that right now we're double-
charging the ones on the qdisc queue..

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
