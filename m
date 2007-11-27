From: Andi Kleen <andi@firstfloor.org>
Subject: Re: [PATCH RFC] [1/9] Core module symbol namespaces code and intro.
Date: Tue, 27 Nov 2007 11:50:16 +0100
Message-ID: <20071127105016.GC24223@one.firstfloor.org>
References: <20071122343.446909000@suse.de> <200711261225.44415.rusty@rustcorp.com.au> <adalk8lsg3z.fsf@cisco.com> <200711271526.53065.rusty@rustcorp.com.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Roland Dreier <rdreier@cisco.com>, Andi Kleen <ak@suse.de>,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	sam@ravnborg.org
To: Rusty Russell <rusty@rustcorp.com.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from one.firstfloor.org ([213.235.205.2]:33274 "EHLO
	one.firstfloor.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751300AbXK0KuV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 Nov 2007 05:50:21 -0500
Content-Disposition: inline
In-Reply-To: <200711271526.53065.rusty@rustcorp.com.au>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Nov 27, 2007 at 03:26:52PM +1100, Rusty Russell wrote:
> On Monday 26 November 2007 16:58:08 Roland Dreier wrote:
> >  > > I agree that we shouldn't make things too hard for out-of-tree
> >  > > modules, but I disagree with your first statement: there clearly is a
> >  > > large class of symbols that are used by multiple modules but which are
> >  > > not generically useful -- they are only useful by a certain small
> >  > > class of modules.
> >  >
> >  > If it is so clear, you should be able to easily provide examples?
> >
> > Sure -- Andi's example of symbols required only by TCP congestion
> > modules;
> 
> Exactly.  Why exactly should someone not write a new TCP congestion module?

Agreed the congestion modules are a corner case. I even mentioned that in the
patch. I would be happy to drop that one if that is the consensus.
It was more done as a example anyways. That is why I made it an separate
namespace from "tcp"

But for many other TCP symbols it makes a lot of sense: all the functions
only used by tcp_ipv6.c. If someone wants to write support for a "IPv7" or
similar they really should do it in tree. So I think the "tcp" and  "inet"
namespaces make a lot of sense.

> Right.  So presumably there will only ever be two drivers using this core 
> code, so no new users will ever be written?  Now we've found one use case, is 

If there are new users they will need to get proper review and should
be in tree.  MODULE_ALLOW() enforces that.

> it worth the complexity of namespaces?  Is it worth the halfway point of 

What complexity? You're always claiming it is complex. It isn't really.

> export-to-module?
> 

> No, we've seen the solution and various people applying it.  I'm still trying 
> to discover the problem it's solving.

Again for rusty @)

Goals are:
- Limit the interfaces available for out of tree modules to reasonably 
stable ones that are already used by a larger set of drivers.

This can also have further downstream advantages.
For example it might be a reasonable future rule to require all unconditionally
EXPORT_SYMBOL()s to have a complete LinuxDoc documentation entry.

- Explicitely declare in source what is clearly internal and not intended to
be a generally usable interface.

e.g. for the LinuxDoc example above such internal functions don't necessarily
need full LinuxDoc documentation.

- Force review from core maintainers for use of such internal interfaces

- Limit size of exported API to make stable ABIs for enterprise
distributions easier
[Yes I know that is not a popular topic on l-k, but it's a day-to-day
problem for these distros and out of tree solutions do not work]

-Andi
