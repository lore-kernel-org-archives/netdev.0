From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: Re: xfrm4_garbage_collect reaching limit
Date: Wed, 30 Sep 2015 11:54:19 +0200
Message-ID: <20150930095419.GH7701@secunet.com>
References: <CAOZ2QJPt=3YmLG=S2Zf70yNPwLf-dbWtiyWJNbfYMRrQ5C6EZg@mail.gmail.com>
 <20150911094808.GI25499@secunet.com>
 <CAOZ2QJPAb4PfoBybPuhMokh9jhRFY0XSNMajf75Mgx=3=KXfUg@mail.gmail.com>
 <20150916084541.GB7701@secunet.com>
 <CALZtONDZXmTPJgRH6OzF+cX9Ac5Tt+Q6wkX2sUbXzN8zdj1DyQ@mail.gmail.com>
 <CAOZ2QJMFNRza8cLnB4Wu0TZCi4pQE0UL7Ch=+D7igMvjNjpONQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Dan Streetman <ddstreet@ieee.org>,
	Jay Vosburgh <jay.vosburgh@canonical.com>,
	<netdev@vger.kernel.org>
To: Dan Streetman <dan.streetman@canonical.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([195.81.216.161]:45728 "EHLO a.mx.secunet.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932880AbbI3JyX (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 30 Sep 2015 05:54:23 -0400
Content-Disposition: inline
In-Reply-To: <CAOZ2QJMFNRza8cLnB4Wu0TZCi4pQE0UL7Ch=+D7igMvjNjpONQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Sep 21, 2015 at 10:51:11AM -0400, Dan Streetman wrote:
> On Fri, Sep 18, 2015 at 1:00 AM, Dan Streetman <ddstreet@ieee.org> wrote:
> > On Wed, Sep 16, 2015 at 4:45 AM, Steffen Klassert
> > <steffen.klassert@secunet.com> wrote:
> >>
> >> What about the patch below? With this we are independent of the number
> >> of cpus. It should cover most, if not all usecases.
> >
> > yep that works, thanks!  I'll give it a test also, but I don't see how
> > it would fail.
> 
> Yep, on a test setup that previously failed within several hours, it
> ran over the weekend successfully.  Thanks!
> 
> Tested-by: Dan Streetman <dan.streetman@canonical.com>
> 
> >
> >>
> >> While we are at it, we could think about increasing the flowcache
> >> percpu limit. This value was choosen back in 2003, so maybe we could
> >> have more than 4k cache entries per cpu these days.
> >>
> >>
> >> Subject: [PATCH RFC] xfrm: Let the flowcache handle its size by default.
> >>
> >> The xfrm flowcache size is limited by the flowcache limit
> >> (4096 * number of online cpus) and the xfrm garbage collector
> >> threshold (2 * 32768), whatever is reached first. This means
> >> that we can hit the garbage collector limit only on systems
> >> with more than 16 cpus. On such systems we simply refuse
> >> new allocations if we reach the limit, so new flows are dropped.
> >> On syslems with 16 or less cpus, we hit the flowcache limit.
> >> In this case, we shrink the flow cache instead of refusing new
> >> flows.
> >>
> >> We increase the xfrm garbage collector threshold to INT_MAX
> >> to get the same behaviour, independent of the number of cpus.
> >>
> >> The xfrm garbage collector threshold can still be set below
> >> the flowcache limit to reduce the memory usage of the flowcache.
> >>
> >> Signed-off-by: Steffen Klassert <steffen.klassert@secunet.com>

I've applied this to ipsec-next now. It can be considered as a fix too,
but we still can tweak the value via the sysctl in the meantime. So
it is better to test it a bit longer before it hits the mainline.

Thanks a lot for your work Dan!
