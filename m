From: Willy Tarreau <w@1wt.eu>
Subject: Re: [PATCH v2] tcp: splice as many packets as possible at once
Date: Fri, 30 Jan 2009 23:13:46 +0100
Message-ID: <20090130221346.GE31355@1wt.eu>
References: <20090127074048.GA4197@ff.dom.local> <20090130.134227.123379239.davem@davemloft.net> <20090130215920.GC31355@1wt.eu> <20090130.140346.159984249.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: jarkao2@gmail.com, zbr@ioremap.net, herbert@gondor.apana.org.au,
	dada1@cosmosbay.com, ben@zeus.com, mingo@elte.hu,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	jens.axboe@oracle.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 1wt.eu ([62.212.114.60]:1932 "EHLO 1wt.eu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753852AbZA3WOQ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 30 Jan 2009 17:14:16 -0500
Content-Disposition: inline
In-Reply-To: <20090130.140346.159984249.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Jan 30, 2009 at 02:03:46PM -0800, David Miller wrote:
> From: Willy Tarreau <w@1wt.eu>
> Date: Fri, 30 Jan 2009 22:59:20 +0100
> 
> > On Fri, Jan 30, 2009 at 01:42:27PM -0800, David Miller wrote:
> > > It's cheesy and the SLAB developers will likely barf at the
> > > idea, but it would certainly work.
> > 
> > Maybe that would be enough as a definitive fix for a stable
> > release, so that we can go on with deeper changes in newer
> > versions ?
> 
> Such a check could have performance ramifications, I wouldn't
> risk it and already I intend to push Jarek's page allocator
> splice fix back to -stable eventually.

OK.

> > > Back to real life, I think long term the thing to do is to just do the
> > > cached page allocator thing we'll be doing after Jarek's socket page
> > > patch is integrated, and for best performance the driver has to
> > > receive it's data into pages, only explicitly pulling the ethernet
> > > header into the linear area, like NIU does.
> > 
> > Are there NICs out there able to do that themselves or does the
> > driver need to rely on complex hacks in order to achieve this ?
> 
> Any NIC, even the dumbest ones, can be made to receive into pages.

OK I thought that it was not always easy to split between headers
and payload. I know that myri10ge can be configured to receive into
either skbs or pages, but I was not sure about the real implications
behind that.

Thanks
Willy

