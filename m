From: "Denis V. Lunev" <den@openvz.org>
Subject: Re: [PATCH net-next 0/9] selective (per/namespace) flush of
	rt_cache
Date: Mon, 07 Jul 2008 14:39:41 +0400
Message-ID: <1215427181.29879.77.camel@iris.sw.ru>
References: <1215177360.27873.50.camel@iris.sw.ru>
	 <20080705.205548.122498335.davem@davemloft.net>
	 <m1fxqmyol8.fsf@frodo.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, containers@lists.osdl.org,
	netdev@vger.kernel.org
To: "Eric W. Biederman" <ebiederm@xmission.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailhub.sw.ru ([195.214.232.25]:19403 "EHLO relay.sw.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752474AbYGGKjQ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 7 Jul 2008 06:39:16 -0400
In-Reply-To: <m1fxqmyol8.fsf@frodo.ebiederm.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On Mon, 2008-07-07 at 03:29 -0700, Eric W. Biederman wrote:
> David Miller <davem@davemloft.net> writes:
> 
> > From: "Denis V. Lunev" <den@openvz.org>
> > Date: Fri, 04 Jul 2008 17:16:00 +0400
> >
> >> This series of patches implements selective rt cache flushing to make
> >> sure that in one namespace we'll not been able to affect the performance
> >> of other from the user space.
> >
> > Applied and pushed out to net-next-2.6, thanks.
> >
> > Although I wish patch 9 didn't have to be so ugly. :-/ Also, is it
> > really the right thing to do if another namespace's RT cache entries
> > are in fact chewing up all the slots in a hash chain?  I think
> > the replacement garbage collection algorithm should be namespace
> > agnostic.
> 
> My VM experience agrees.  The requested flushes from inside the namespace
> and for namespace exit really should just flush the routes for that namespace.
> However for general route caching and expiry I don't see the point of making
> the code per namespace, and my gut feel is that is likely to reduce average
> case performance at the cost of better isolation between namespaces.
> 
> Denis did I read the patches right and you are making all route cache flushes
> per namespace?  Including the periodic expiry?
yes. The reason for the latter is that we can't pin namespace list in
the timer, so it is better to have a separate timer for each namespace.
The similar approach has been discussed for IPv6 flushing if my memory
does not fail me.

Though, generic rt cache garbage collecting is left untouched and from
my point of view it should be left as it is. At least we use this
approach in OpenVz.

