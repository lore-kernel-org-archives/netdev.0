From: Willy Tarreau <w@1wt.eu>
Subject: Re: [PATCH v2] tcp: splice as many packets as possible at once
Date: Fri, 30 Jan 2009 22:59:20 +0100
Message-ID: <20090130215920.GC31355@1wt.eu>
References: <20090126212130.GA4338@ioremap.net> <20090126.221056.174077798.davem@davemloft.net> <20090127074048.GA4197@ff.dom.local> <20090130.134227.123379239.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: jarkao2@gmail.com, zbr@ioremap.net, herbert@gondor.apana.org.au,
	dada1@cosmosbay.com, ben@zeus.com, mingo@elte.hu,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	jens.axboe@oracle.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 1wt.eu ([62.212.114.60]:1921 "EHLO 1wt.eu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755273AbZA3V76 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 30 Jan 2009 16:59:58 -0500
Content-Disposition: inline
In-Reply-To: <20090130.134227.123379239.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Jan 30, 2009 at 01:42:27PM -0800, David Miller wrote:
> From: Jarek Poplawski <jarkao2@gmail.com>
> Date: Tue, 27 Jan 2009 07:40:48 +0000
> 
> > I think the main problem is to respect put_page() more, and maybe you
> > mean to add this to your allocator too, but using slab pages for this
> > looks a bit complex to me, but I can miss something.
> 
> Hmmm, Jarek's comments here made me realize that we might be
> able to do some hack with cooperation with SLAB.
> 
> Basically the idea is that if the page count of a SLAB page
> is greater than one, SLAB will not use that page for new
> allocations.

I thought it was the standard behaviour. That may explain why I
did not understand much of previous discussion then :-/

> It's cheesy and the SLAB developers will likely barf at the
> idea, but it would certainly work.

Maybe that would be enough as a definitive fix for a stable
release, so that we can go on with deeper changes in newer
versions ?

> Back to real life, I think long term the thing to do is to just do the
> cached page allocator thing we'll be doing after Jarek's socket page
> patch is integrated, and for best performance the driver has to
> receive it's data into pages, only explicitly pulling the ethernet
> header into the linear area, like NIU does.

Are there NICs out there able to do that themselves or does the
driver need to rely on complex hacks in order to achieve this ?

Willy

