From: Jens Axboe <jens.axboe@oracle.com>
Subject: Re: [PATCH][RFC] network splice receive
Date: Sat, 9 Jun 2007 08:36:09 +0200
Message-ID: <20070609063608.GX7341@kernel.dk>
References: <20070607145818.GA26491@2ka.mipt.ru> <20070608074823.GG7341@kernel.dk> <20070608.010629.52902577.davem@davemloft.net> <20070608083853.GH7341@kernel.dk> <20070608085620.GC11488@2ka.mipt.ru> <20070608090439.GK7341@kernel.dk> <20070608135819.GA14302@2ka.mipt.ru> <20070608141452.GR7341@kernel.dk> <20070608145724.GA14561@2ka.mipt.ru> <20070608153011.GA2375@2ka.mipt.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Return-path: <netdev-owner@vger.kernel.org>
Received: from brick.kernel.dk ([80.160.20.94]:7281 "EHLO kernel.dk"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751447AbXFIGhy (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 9 Jun 2007 02:37:54 -0400
Content-Disposition: inline
In-Reply-To: <20070608153011.GA2375@2ka.mipt.ru>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Jun 08 2007, Evgeniy Polyakov wrote:
> On Fri, Jun 08, 2007 at 06:57:25PM +0400, Evgeniy Polyakov (johnpol@2ka.mipt.ru) wrote:
> > I will try some things for the nearest 30-60 minutes, and then will move to
> > canoe trip until thuesday, so will not be able to work on this idea.
> 
> Ok, replacing in fs/splice.c every page_cache_release() with
> static void splice_page_release(struct page *p)
> {
> 	if (!PageSlab(p))
> 		page_cache_release(p);
> }

Ehm, I don't see why that should be necessary. Except in
splice_to_pipe(), I have considered that we need to pass in a release
function if mapping fails at some point. But it's probably best to do
that in the caller, since they have the knowledge of how to release the
pages.

The rest of the PageSlab() tests are bogus.

> and putting cloned skb into private field instead of 
> original on in spd_fill_page() ends up without kernel hung.

Why? Seems pointless to allocate a clone just to hold on to the skb, a
reference should be equally good. I would not be opposed to doing it
this way, I just don't see what a clone buys us as compared to just
holding that reference to the skb.

> I'm not sure it is correct, that page can be released in fs/splice.c
> without calling any callback from network code, when network data is
> being processed.

Please explain!

> Size of the received file is bigger than file sent, file contains repeated
> blocks of data sometimes. Cloned skb usage is likely too big overhead,
> although for receiving fast clone is unused in most cases, so there
> might be some gain.
> 
> Attached your patch with above changes.

Thanks, I'll fiddle with this on monday.

-- 
Jens Axboe

