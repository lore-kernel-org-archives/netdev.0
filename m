From: lsorense@csclub.uwaterloo.ca (Lennart Sorensen)
Subject: Re: Why linux keeps connected routes when link goes down
Date: Tue, 24 Feb 2009 13:52:22 -0500
Message-ID: <20090224185222.GO23244@csclub.uwaterloo.ca>
References: <20090220171912.GA7315@csclub.uwaterloo.ca> <20090220.121508.252047266.davem@davemloft.net> <20090223143830.GA23244@csclub.uwaterloo.ca> <20090223.153353.237733933.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: homecreate@list.ru, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from caffeine.csclub.uwaterloo.ca ([129.97.134.17]:52385 "EHLO
	caffeine.csclub.uwaterloo.ca" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751807AbZBXSwZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 Feb 2009 13:52:25 -0500
Content-Disposition: inline
In-Reply-To: <20090223.153353.237733933.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Feb 23, 2009 at 03:33:53PM -0800, David Miller wrote:
> From: lsorense@csclub.uwaterloo.ca (Lennart Sorensen)
> Date: Mon, 23 Feb 2009 09:38:30 -0500
> 
> > On Fri, Feb 20, 2009 at 12:15:08PM -0800, David Miller wrote:
> > > The route is tied to the IP address, and the route is therefore
> > > created and destroyed alongside the IP address.
> > 
> > That's how it works now.  It wasn't how it worked in linux a long
> > time ago.  Long ago you had to create the route yourself in userspace
> > (which was actually to some extent better than the current setup).
> > The current method is simpler to understand for your typical user though.
> 
> I don't remember Linux ever not creating a subnet route when an IP
> address was added to an interface.  And I also don't remember Linux
> ever deleting an IP address on interface down.

Not IP address.  And no it never deleted the route either.

> Maybe it happened back in 0.99pl5 times, but we're talking at least
> 10 years ago.

I did run 0.99something on my first linux system, so I remember the
transition happening at some point.  I remember distribution's network
scripts creating routes after assigning the IP to an interface.  I don't
remember how long ago that was though.

Now it had nothing to do with link state, it was simply a matter that
setting an ip and netmask on an interface did not create a route the
way newer kernels have done (where newer probably covers most years of
linux kernels).  All route management was userspace's job back then.
In the case of running quagga and trying to do link detect and route
management based on link state, having the one route the kernel auto
creates there is a pain in the ass and it would be nice if it wasn't
there based on some sysctl option.  I haven't found one though.  I would
be happy to have zebra be responsible for the network route for all
interfaces for consistency.  That way all route management without
exception would be a userspace problem.  This would of course not be the
default, since for most normal users this is not the desired behaviour,
but for an advanced router it very much is desired behaviour.

-- 
Len Sorensen
