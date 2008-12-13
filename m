From: Evgeniy Polyakov <zbr@ioremap.net>
Subject: Re: [PATCH 6/8] tcp: Add GRO support
Date: Sat, 13 Dec 2008 06:10:19 +0300
Message-ID: <20081213031019.GE807@ioremap.net>
References: <20081212053116.GA2927@gondor.apana.org.au> <E1LB0d1-0000rd-B2@gondolin.me.apana.org.au> <20081212195615.GC27281@ioremap.net> <20081212214627.GC11046@gondor.apana.org.au> <20081213024046.GB807@ioremap.net> <20081213024644.GB14056@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from intermatrixgroup.ru ([195.178.208.66]:54714 "EHLO
	tservice.net.ru" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751880AbYLMDKU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 12 Dec 2008 22:10:20 -0500
Content-Disposition: inline
In-Reply-To: <20081213024644.GB14056@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Dec 13, 2008 at 01:46:45PM +1100, Herbert Xu (herbert@gondor.apana.org.au) wrote:
> On Sat, Dec 13, 2008 at 05:40:46AM +0300, Evgeniy Polyakov wrote:
> >
> > So it will fail if timestamp changed? Or if some new option added?
> 
> Correct, it must remain exactly the same.  Even at 100Mbps any
> sane clock frequency will result in an average of 8 packets per
> clock update.  At the sort speeds (>1Gbps) at which we're targetting
> this'll easily get us to 64K which is our maximum (actually it
> looks like I forgot to add a check to stop this from growing beyond
> 64K :)

Some stacks use just increased counter since it is allowed by the RFC :)
Probably 'not sane' is appropriate name, but still... Probably not a
serious problem, but what if just check the timestamp option before/after
like it was in LRO?

-- 
	Evgeniy Polyakov
