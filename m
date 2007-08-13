From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Subject: Re: Block device throttling [Re: Distributed storage.]
Date: Mon, 13 Aug 2007 16:04:17 +0400
Message-ID: <20070813120417.GA5992@2ka.mipt.ru>
References: <20070731171347.GA14267@2ka.mipt.ru> <200708122344.00343.phillips@phunq.net> <20070813081441.GA30089@2ka.mipt.ru> <200708130404.26572.phillips@phunq.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jens Axboe <jens.axboe@oracle.com>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org,
	Peter Zijlstra <peterz@infradead.org>
To: Daniel Phillips <phillips@phunq.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay.2ka.mipt.ru ([194.85.82.65]:45421 "EHLO 2ka.mipt.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S968580AbXHMMFR (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 13 Aug 2007 08:05:17 -0400
Content-Disposition: inline
In-Reply-To: <200708130404.26572.phillips@phunq.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Aug 13, 2007 at 04:04:26AM -0700, Daniel Phillips (phillips@phunq.net) wrote:
> On Monday 13 August 2007 01:14, Evgeniy Polyakov wrote:
> > > Oops, and there is also:
> > >
> > > 3) The bio throttle, which is supposed to prevent deadlock, can
> > > itself deadlock.  Let me see if I can remember how it goes.
> > >
> > >   * generic_make_request puts a bio in flight
> > >   * the bio gets past the throttle and initiates network IO
> > >   * net calls sk_alloc->alloc_pages->shrink_caches
> > >   * shrink_caches submits a bio recursively to our block device
> > >   * this bio blocks on the throttle
> > >   * net may never get the memory it needs, and we are wedged
> >
> > If system is in such condition, it is already broken - throttle limit
> > must be lowered (next time) not to allow such situation.
> 
> Agreed that the system is broken, however lowering the throttle limit 
> gives no improvement in this case.

How is it ever possible? The whole idea of throttling is to remove such
situation, and now you say it can not be solved. If limit is for 1gb of
pending block io, and system has for example 2gbs of ram (or any other
resonable parameters), then there is no way we can deadlock in
allocation, since it will not force page reclaim mechanism.

-- 
	Evgeniy Polyakov
