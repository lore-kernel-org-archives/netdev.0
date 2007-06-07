From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Subject: Re: [PATCH][RFC] network splice receive
Date: Thu, 7 Jun 2007 18:58:18 +0400
Message-ID: <20070607145818.GA26491@2ka.mipt.ru>
References: <20070605080542.GA9909@kernel.dk> <20070605143130.GA31747@2ka.mipt.ru> <20070606071725.GE31415@kernel.dk> <20070607080954.GB11764@2ka.mipt.ru> <20070607105159.GV4735@kernel.dk>
Mime-Version: 1.0
Content-Type: text/plain; charset=koi8-r
Cc: netdev@vger.kernel.org
To: Jens Axboe <jens.axboe@oracle.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay.2ka.mipt.ru ([194.85.82.65]:57234 "EHLO 2ka.mipt.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753506AbXFGO6p (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 7 Jun 2007 10:58:45 -0400
Content-Disposition: inline
In-Reply-To: <20070607105159.GV4735@kernel.dk>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Jun 07, 2007 at 12:51:59PM +0200, Jens Axboe (jens.axboe@oracle.com) wrote:
> > What bout checking if page belongs to kmalloc cache (or any other cache
> > via priviate pointers) and do not perform any kind of reference counting
> > on them? I will play with this a bit later today.
> 
> That might work, but sounds a little dirty... But there's probably no
> way around. Be sure to look at the #splice-net branch if you are playing
> with this, I've updated it a number of times and fixed some bugs in
> there. Notably it now gets the offset right, and handles fragments and
> fraglist as well.

I've pulled splice-net, which indeed fixed some issues, but referencing
slab pages is still is not allowed. There are at least two problems
(although they are related):
1. if we do not increment reference counter for slab pages, they
eventually get refilled and slab exploses after it understood that its
pages are in use (or user dies when page is moved out of his control in
slab).
2. get/put page does not work with slab pages, and simple
increment/decrement of the reference counters is not allowed too.

Both problems have the same root - slab does not allow anyone to 
manipulate page's members. That should be broken/changed to allow splice
to put its hands into network using the fastest way.
I will think about it.

> -- 
> Jens Axboe

-- 
	Evgeniy Polyakov
