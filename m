From: Jarek Poplawski <jarkao2@o2.pl>
Subject: Re: [PATCH] flush_work_sync vs. flush_scheduled_work Re: [PATCH] PHYLIB: IRQ event workqueue handling fixes
Date: Tue, 23 Oct 2007 08:59:51 +0200
Message-ID: <20071023065951.GA1847@ff.dom.local>
References: <Pine.LNX.4.64N.0710151737250.16262@blysk.ds.pg.gda.pl> <20071016062108.GB1000@ff.dom.local> <Pine.LNX.4.64N.0710161759050.22596@blysk.ds.pg.gda.pl> <20071017085809.GA1658@ff.dom.local> <20071018063157.GA1694@ff.dom.local> <20071018070531.GA2065@ff.dom.local> <20071018154819.GA425@tv-sign.ru> <20071019075014.GA1765@ff.dom.local> <20071022061143.GA973@ff.dom.local> <20071022180259.GA967@tv-sign.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "Maciej W\. Rozycki" <macro@linux-mips.org>,
	Andy Fleming <afleming@freescale.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Jeff Garzik <jgarzik@pobox.com>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Oleg Nesterov <oleg@tv-sign.ru>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx12.go2.pl ([193.17.41.142]:60747 "EHLO poczta.o2.pl"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751968AbXJWG4g (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 23 Oct 2007 02:56:36 -0400
Content-Disposition: inline
In-Reply-To: <20071022180259.GA967@tv-sign.ru>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Oct 22, 2007 at 10:02:59PM +0400, Oleg Nesterov wrote:
> On 10/22, Jarek Poplawski wrote:
...
> > OK, I know I'm dumber and dumber everyday,
> 
> You are not alone. I have the same feeling about myself!

Feeling is not the same, only true knowledge counts!

> 
> > these all flushes are
> > rtnl lockup vulnerable wrt. other work functions, but cancel_work_sync
> > looks perfectly fine
> 
> Yes,
> 
> > Then, if by any chance I'm right, something like flush_work_sync
> > (or changed flush_scheduled_work, if there is no problem with such
> > a change of implementation) could be safely (if it's called without
> > locks used by flushed work only) done cancel_work_sync() way, by
> > running a work function after try_to_grab_pending() returns 1
> 
> If this work doesn't rearm itself - yes. (otherwise, the same ->func
> can run twice _at the same time_)
> 
> But again, in this case wait_on_work() after try_to_grab_pending() == 1
> doesn't block, so we can just do
> 
> 	if (cancel_work_sync(w))
> 		w->func();

Of course, I should have written it much shorter by saying
flush_scheduled_work could be done internally just like you suggested!

My point is to make this all safer and simpler, so we don't have to
remember each time about these differences wrt. locking. Then checking
of such patches could be much easier. Unless this current behavior
of flush_scheduled_work has any real advantages, worth of this
potential unsafety. (Btw. is there any reason to use this with
rearming works, anyway?)

Thanks,
Jarek P.
