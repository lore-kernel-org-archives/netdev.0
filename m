From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Subject: Re: Distributed storage.
Date: Mon, 6 Aug 2007 12:28:12 +0400
Message-ID: <20070806082812.GC21909@2ka.mipt.ru>
References: <20070731171347.GA14267@2ka.mipt.ru> <200708050106.58383.phillips@phunq.net> <20070805150154.GA32132@2ka.mipt.ru> <200708051435.04542.phillips@phunq.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	linux-fsdevel@vger.kernel.org
To: Daniel Phillips <phillips@phunq.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay.2ka.mipt.ru ([194.85.82.65]:51028 "EHLO 2ka.mipt.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755778AbXHFI23 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 6 Aug 2007 04:28:29 -0400
Content-Disposition: inline
In-Reply-To: <200708051435.04542.phillips@phunq.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sun, Aug 05, 2007 at 02:35:04PM -0700, Daniel Phillips (phillips@phunq.net) wrote:
> On Sunday 05 August 2007 08:01, Evgeniy Polyakov wrote:
> > On Sun, Aug 05, 2007 at 01:06:58AM -0700, Daniel Phillips wrote:
> > > > DST original code worked as device mapper plugin too, but its two
> > > > additional allocations (io and clone) per block request ended up
> > > > for me as a show stopper.
> > >
> > > Ah, sorry, I misread.  A show stopper in terms of efficiency, or in
> > > terms of deadlock?
> >
> > At least as in terms of efficiency. Device mapper lives in happy
> > world where memory does not end and allocations are fast.
> 
> Are you saying that things are different for a network block device 
> because it needs to do GFP_ATOMIC allocations?  If so then that is just 
> a misunderstanding.  The global page reserve Peter and I use is 
> available in interrupt context just like GFP_ATOMIC.

No, neither device needs atomic allocations, I just said that device
mapper is too expensive, since it performs alot of additional
allocations in the fast path and is not designed to cases when
allocation fails, since there is no recovery path and (maybe because of
this) mempool allocation waits forever until there is free memory
and can not fail.

-- 
	Evgeniy Polyakov
