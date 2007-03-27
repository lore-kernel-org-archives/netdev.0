From: Andy Gospodarek <andy@greyhouse.net>
Subject: Re: [patch 5/7] bonding: replace system timer with work queue
Date: Tue, 27 Mar 2007 08:31:15 -0400
Message-ID: <20070327123114.GA25218@gospo.rdu.redhat.com>
References: <200703270550.l2R5o16M008387@shell0.pdx.osdl.net> <20070326215648.58cb392b.akpm@linux-foundation.org> <25159.1174976707@death>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Andrew Morton <akpm@linux-foundation.org>, davem@davemloft.net,
	netdev@vger.kernel.org, perex@suse.cz, oleg@tv-sign.ru,
	shemminger@linux-foundation.org,
	Andy Gospodarek <andy@greyhouse.net>
To: Jay Vosburgh <fubar@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:45372 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753806AbXC0McG (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 27 Mar 2007 08:32:06 -0400
Content-Disposition: inline
In-Reply-To: <25159.1174976707@death>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Mar 26, 2007 at 11:25:07PM -0700, Jay Vosburgh wrote:
> Andrew Morton <akpm@linux-foundation.org> wrote:
> 
> >On Mon, 26 Mar 2007 21:50:01 -0800 akpm@linux-foundation.org wrote:
> >
> >> Replace system timer with work queue in monitor functions.  The reason for
> >> this change is that bonding handlers calls various sleeping functions from
> >> the timer handler which is not allowed.  Because we cannot share the main
> >> workqueue threads (rtnl_lock is used also in linkwatch_event) - new bond
> >> workqueue thread is created.
> >
> >I have a note here that this patch needs additional work.
> >
> >I forget what it was, there has since been no followup and hence I shall now
> >drop this patch.
> 
> 	Andy Gospodarek <andy@greyhouse.net> and I have been working off
> list to come up with a comprehensive scheme to resolve the various
> locking problems in bonding all at once, rather than piecemeal.
> Currently, we believe we've identified all of the problem areas, have
> worked up a set of locking rules, and are now hashing out an
> implementation that (hopefully) doesn't suck.
> 
> 	The patch referenced above is more or less a functional subset
> of the work we're doing, in that we'll also be moving the timers to
> workqueues.
> 
> 	Andy, anything to add?
> 
> 	-J
> 

Jay has summed up our work perfectly and Andrew is correct to drop the
patch.  This patch does the conversion correctly, but it will cause a
deadlock in the transmit path.

Jay and I both hope to have something ready to post pretty soon.

-andy

