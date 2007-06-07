From: Jens Axboe <jens.axboe@oracle.com>
Subject: Re: [PATCH][RFC] network splice receive
Date: Thu, 7 Jun 2007 12:51:59 +0200
Message-ID: <20070607105159.GV4735@kernel.dk>
References: <20070605080542.GA9909@kernel.dk> <20070605143130.GA31747@2ka.mipt.ru> <20070606071725.GE31415@kernel.dk> <20070607080954.GB11764@2ka.mipt.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Return-path: <netdev-owner@vger.kernel.org>
Received: from brick.kernel.dk ([80.160.20.94]:15472 "EHLO kernel.dk"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750930AbXFGKx0 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 7 Jun 2007 06:53:26 -0400
Content-Disposition: inline
In-Reply-To: <20070607080954.GB11764@2ka.mipt.ru>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Jun 07 2007, Evgeniy Polyakov wrote:
> On Wed, Jun 06, 2007 at 09:17:25AM +0200, Jens Axboe (jens.axboe@oracle.com) wrote:
> > > Some pages have zero reference counter here.
> > 
> > But it's somewhat annoying to get pages with zero reference counts
> > there, I wonder how that happens. I guess if the skb->data originated
> > from kmalloc() then we don't really know. The main intent there was just
> > to ensure the page wasn't going away, but clearly it's not good enough
> > to ensure that reuse isn't taking place.
> 
> What bout checking if page belongs to kmalloc cache (or any other cache
> via priviate pointers) and do not perform any kind of reference counting
> on them? I will play with this a bit later today.

That might work, but sounds a little dirty... But there's probably no
way around. Be sure to look at the #splice-net branch if you are playing
with this, I've updated it a number of times and fixed some bugs in
there. Notably it now gets the offset right, and handles fragments and
fraglist as well.

-- 
Jens Axboe

