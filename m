From: Benjamin LaHaise <ben.lahaise@neterion.com>
Subject: Re: [0/14] GRO: Lots of microoptimisations
Date: Fri, 12 Jun 2009 12:09:26 -0400
Message-ID: <20090612160926.GA4290@neterion.com>
References: <20090527044539.GA32372@gondor.apana.org.au> <20090527175223.GB7804@neterion.com> <20090527230858.GA24278@gondor.apana.org.au> <20090528152143.GA4501@neterion.com> <20090529092821.GA11725@gondor.apana.org.au> <20090529092930.GA11785@gondor.apana.org.au> <20090529162312.GA5191@neterion.com> <20090610054449.GB16984@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from barracuda.s2io.com ([72.1.205.138]:42572 "EHLO
	barracuda.s2io.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1760137AbZFLQJr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 12 Jun 2009 12:09:47 -0400
Content-Disposition: inline
In-Reply-To: <20090610054449.GB16984@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jun 10, 2009 at 03:44:49PM +1000, Herbert Xu wrote:
> On Fri, May 29, 2009 at 12:23:13PM -0400, Benjamin LaHaise wrote:
> >
> > It's just being turned off by setting a loadable module option.
> 
> Let me see if I can get my hands on a machine with your NIC.

I found at least one reason why: the first skb_shinfo()->frag_list touch 
in dev_gro_receive() was causing a cache miss.  Adding a prefetch in the 
driver helps that a little bit, but there's still > 500Mbps difference.  
I'd like to retest on a system with newer CPUs, but it will probably be a 
few weeks until all the hardware is in the same place.

		-ben
