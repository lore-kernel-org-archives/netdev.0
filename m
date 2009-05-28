From: Benjamin LaHaise <ben.lahaise@neterion.com>
Subject: Re: [0/14] GRO: Lots of microoptimisations
Date: Thu, 28 May 2009 11:21:43 -0400
Message-ID: <20090528152143.GA4501@neterion.com>
References: <20090527044539.GA32372@gondor.apana.org.au> <20090527175223.GB7804@neterion.com> <20090527230858.GA24278@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from barracuda.s2io.com ([72.1.205.138]:45970 "EHLO
	barracuda.s2io.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756839AbZE1PeI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 May 2009 11:34:08 -0400
Content-Disposition: inline
In-Reply-To: <20090527230858.GA24278@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, May 28, 2009 at 09:08:58AM +1000, Herbert Xu wrote:
> On Wed, May 27, 2009 at 01:52:23PM -0400, Benjamin LaHaise wrote:
> > 
> > A few questions for you: I've been looking a bit into potential GRO 
> > optimisations that are possible with the vxge driver.  At least from my 
> > existing testing on a P4 Xeon, it seems that doing packet rx via 
> > napi_gro_receive() was a bit slower.  I'll retest with these changes 
> 
> Slower compared to LRO or GRO off?

With GRO off I'm getting ~4.7-5Gbps to the receiver which is CPU bound with 
netperf.  With GRO on, that drops to ~3.9-4.3Gbps.  The only real difference 
is the entry point into the net code being napi_gro_receive() vs 
netif_receive_skb().

> > of yours.  What platform have your tests been run on?  Also, do you have 
> > any notes/ideas on how best to make use of the GRO functionality within 
> > the kernel?  I'm hoping it's possible to make use of a few of the hardware 
> > hints to improve fast path performance.
> 
> What sort of hints do you have?

We have a few bits in the hardware descriptor which indicate if the packet 
is TCP or UDP, IPv4 or IPv6, as well as whether TCP packets are fast path 
eligible.  The hardware can also split up the headers to place the ethernet 
MAC, IP and payload in separate buffers.  I plan to run a few tests to see 
if dispatching directly from the driver into the TCP fast path makes much 
difference.

		-ben
