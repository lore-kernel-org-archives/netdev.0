From: Lennert Buytenhek <buytenh@wantstofly.org>
Subject: Re: using software TSO on non-TSO capable netdevices
Date: Thu, 7 Aug 2008 13:50:09 +0200
Message-ID: <20080807115009.GF7716@xi.wantstofly.org>
References: <20080731132735.GA9085@gondor.apana.org.au> <20080803.011945.249059359.davem@davemloft.net> <20080803085553.GA1512@gondor.apana.org.au> <20080806.230741.137564172.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: herbert@gondor.apana.org.au, bhutchings@solarflare.com,
	netdev@vger.kernel.org, akarkare@marvell.com, nico@cam.org,
	dale@farnsworth.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from xi.wantstofly.org ([83.160.184.112]:33066 "EHLO
	xi.wantstofly.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753035AbYHGMYD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Aug 2008 08:24:03 -0400
Content-Disposition: inline
In-Reply-To: <20080806.230741.137564172.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Aug 06, 2008 at 11:07:41PM -0700, David Miller wrote:

> > > I would start hacking on this beast but I haven't yet come up with
> > > a clean way to share a lot of code with the existing sw GSO engine.
> > > That's the key to implementing this properly.
> > 
> > I think it's doable.  We could refactor the software GSO so that
> > it spits out one fragment at a time and the output could either
> > be written to some memory provided by the caller or fed through
> > a callback.
> > 
> > BTW, loner term we should start thinking about breaking the 64K
> > barrier.
> 
> So I had this idea.  My goal is to minimize the number of DMA
> mappings the driver has to make.

FWIW, this wouldn't make much of a difference in my case..


> Another nice aspect of this idea is that we can make the existing GSO
> code just build this funny "TSO plus hidden headers" SKB, and then do
> the by-hand unpacking into new SKB chunks that we will let smart
> drivers do directly into their TX rings.

..but I'm pretty sure that this would.
