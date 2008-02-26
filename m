From: Peter Zijlstra <a.p.zijlstra@chello.nl>
Subject: Re: [PATCH 00/28] Swap over NFS -v16
Date: Tue, 26 Feb 2008 13:00:37 +0100
Message-ID: <1204027238.6242.302.camel@lappy>
References: <20080220144610.548202000@chello.nl>
	 <20080223000620.7fee8ff8.akpm@linux-foundation.org>
	 <18371.43950.150842.429997@notabene.brown>
	 <1204023042.6242.271.camel@lappy>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Andrew Morton <akpm@linux-foundation.org>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	linux-kernel@vger.kernel.org, linux-mm@kvack.org,
	netdev@vger.kernel.org, trond.myklebust@fys.uio.no
To: Neil Brown <neilb@suse.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from bombadil.infradead.org ([18.85.46.34]:35201 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751577AbYBZMA6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 26 Feb 2008 07:00:58 -0500
In-Reply-To: <1204023042.6242.271.camel@lappy>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On Tue, 2008-02-26 at 11:50 +0100, Peter Zijlstra wrote:

> > mm-reserve.patch
> > 
> >    I'm confused by __mem_reserve_add.
> > 
> > +	reserve = mem_reserve_root.pages;
> > +	__calc_reserve(res, pages, 0);
> > +	reserve = mem_reserve_root.pages - reserve;
> > 
> >    __calc_reserve will always add 'pages' to mem_reserve_root.pages.
> >    So this is a complex way of doing
> >         reserve = pages;
> >         __calc_reserve(res, pages, 0);
> > 
> >     And as you can calculate reserve before calling __calc_reserve
> >     (which seems odd when stated that way), the whole function looks
> >     like it could become:
> > 
> >            ret = adjust_memalloc_reserve(pages);
> > 	   if (!ret)
> > 		__calc_reserve(res, pages, limit);
> > 	   return ret;
> > 
> >     What am I missing?
> 
> Probably the horrible twist my brain has. Looking at it makes me doubt
> my own sanity. I think you're right - it would also clean up
> __calc_reserve() a little.
> 
> This is what review for :-)

Ah, you confused me. Well, I confused me - this does deserve a comment
its tricksy.

Its correct. The trick is, the mem_reserve in question (res) need not be
connected to mem_reserve_root.

In that case, mem_reserve_root.pages will not change, but we do
propagate the change as far up as possible, so that
mem_reserve_connect() can just observe the parent and child without
being bothered by the rest of the hierarchy.



