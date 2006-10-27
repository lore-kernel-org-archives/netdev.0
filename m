From: Stephen Hemminger <shemminger@osdl.org>
Subject: Re: [PATCH] tcp: don't allow unfair congestion control to be built
 without warning
Date: Fri, 27 Oct 2006 15:21:49 -0700
Message-ID: <20061027152149.42bcb539@dxpl.pdx.osdl.net>
References: <20061027142402.07a47f3f@freekitty>
	<20061027.143701.85411558.davem@davemloft.net>
	<20061027145913.04dc0e5f@dxpl.pdx.osdl.net>
	<20061027.151238.59655130.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: hagen@jauu.net, jheffner@psc.edu, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.4]:4063 "EHLO smtp.osdl.org")
	by vger.kernel.org with ESMTP id S1750776AbWJ0WWY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 27 Oct 2006 18:22:24 -0400
To: David Miller <davem@davemloft.net>
In-Reply-To: <20061027.151238.59655130.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 27 Oct 2006 15:12:38 -0700 (PDT)
David Miller <davem@davemloft.net> wrote:

> From: Stephen Hemminger <shemminger@osdl.org>
> Date: Fri, 27 Oct 2006 14:59:13 -0700
> 
> > On Fri, 27 Oct 2006 14:37:01 -0700 (PDT)
> > David Miller <davem@davemloft.net> wrote:
> > 
> > > From: Stephen Hemminger <shemminger@osdl.org>
> > > Date: Fri, 27 Oct 2006 14:24:02 -0700
> > > 
> > > > Only some (very few) have any bad consequences. So the typical
> > > > distribution should be able to switch with most available for everyone,
> > > > and only a few needing special privileges.
> > > 
> > > I would strongly disagree as we've had several OOPS'er class bugs in
> > > the less frequently used algorithms.
> > > 
> > 
> > Then tag those as restricted.  Why should we keep app's away from
> > the simple ones.
> 
> You can't predict bugs, but what you can do is know that the lesser
> used algorithms are by definition less tested and therefore more
> likely to have bugs.  Everything except the default and Reno are
> lesser used.

If they aren't usable they should be marked BROKEN or something
like that. The stability argument doesn't really work, we don't
like to let root kill the system either.
 
> Safe by default, there is no other choice.  You fail to respond to
> THAT part of my email.  That's the important point.  Let me
> reiterate:
> 
> > It's bad enough that people are all over us for the default algorithm
> > we have choosen, so it'd be extremely irresponsible and even worse if
> > we allowed users to select any of the other "research" algorithms for
> > their TCP connections by default just because those modules happened
> > to be configured into the kernel.

Make it hard for them to configure then.  I don't want your
distro to ship with the risky ones turned on.  But we should allow
use of reno, bic, cubic, lp, htcp, and westwood (maybe) by regular
users if admin allows.

> > This userspace convenience argument holds zero water.
> >
> > Provide a way for the administrator to control the situation fully,
> > and choose a sane default which errs on the side of caution for the
> > sake of internet stability.
> 
> Please reread this and consider why it's important.

The current situation is fine. You have to ask for them in the configuration,
and root has to either load the module or set it as default.

The restricted flag patch which you have ignored, would be a way to
allow them to be configured but tag the "bad apples" for only
root usage.




