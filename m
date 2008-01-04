From: Nick Piggin <npiggin@suse.de>
Subject: Re: lockless pagecache Cassini regression
Date: Fri, 4 Jan 2008 15:27:33 +0100
Message-ID: <20080104142733.GA31052@wotan.suse.de>
References: <20080103.193245.15134133.davem@davemloft.net> <20080104113351.GA12706@wotan.suse.de> <20080104.035831.52071724.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.suse.de ([195.135.220.2]:47374 "EHLO mx1.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752208AbYADO1f (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 4 Jan 2008 09:27:35 -0500
Content-Disposition: inline
In-Reply-To: <20080104.035831.52071724.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Jan 04, 2008 at 03:58:31AM -0800, David Miller wrote:
> From: Nick Piggin <npiggin@suse.de>
> Date: Fri, 4 Jan 2008 12:33:52 +0100
> 
> > Just for interest, the lockless pagecache actually makes
> > page->_count unstable for all pages that _have ever_ been pagecache
> > pages (since the last quiescent rcu state, anyway). Basically, it
> > looks up and takes a ref on the struct page without ever having a
> > prior pin or reference on that page. It can do this because it knows
> > the struct page won't actually get freed. After taking the ref, it
> > rechecks that it has got the right page...
> 
> Ok, I understand the needs now.
> 
> I think the way the drivers/net/niu.c driver handles things
> would work better.  It only performs get_page(), atomic
> increments on compound_head(page)->_count, and __free_page().
> Is that all legal with the lockless pagecache?

Yes, you can use the regular refcounting and freeing operations. If the
lockless pagecache has got a speculative reference on the page after the
driver drops all "real" references, it will take care of freeing the page.

 
> If so I can likely rework the Cassini page management to
> behave similarly.

If you got the chance, that would be very nice.

Thanks,
Nick
