From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [RFC][PATCH] IP: Make ping sockets optional
Date: Thu, 24 Apr 2014 18:37:12 +0200
Message-ID: <20140424163712.GJ1960@order.stressinduktion.org>
References: <1398266428.7767.140.camel@deadeye.wl.decadent.org.uk> <20140423153018.GA13717@breakpoint.cc> <1398268542.7767.145.camel@deadeye.wl.decadent.org.uk> <20140423162712.GB13717@breakpoint.cc> <20140424151748.GH1960@order.stressinduktion.org> <1398355320.7767.175.camel@deadeye.wl.decadent.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: Florian Westphal <fw@strlen.de>, netdev <netdev@vger.kernel.org>,
	Vasiliy Kulikov <segoon@openwall.com>, lorenzo@google.com
To: Ben Hutchings <ben@decadent.org.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from order.stressinduktion.org ([87.106.68.36]:37326 "EHLO
	order.stressinduktion.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758003AbaDXQhN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 24 Apr 2014 12:37:13 -0400
Content-Disposition: inline
In-Reply-To: <1398355320.7767.175.camel@deadeye.wl.decadent.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Apr 24, 2014 at 05:02:00PM +0100, Ben Hutchings wrote:
> On Thu, 2014-04-24 at 17:17 +0200, Hannes Frederic Sowa wrote:
> > On Wed, Apr 23, 2014 at 06:27:12PM +0200, Florian Westphal wrote:
> > > Ben Hutchings <ben@decadent.org.uk> wrote:
> > > > Userspace can't assume it now because access is controlled by a sysctl.
> > > > 
> > > > I think it is for distributions to choose whether to enable this feature
> > > > in ping and the kernel.
> > > 
> > > I am not (yet) buying this argument.
> > > 
> > > Saying 'you need to change sysctl foo for this to work' in a program manpage
> > > is a lot different than 'you need to recompile the kernel'.
> > 
> > Maybe we can make the Kconfig option depend on CONFIG_EMBEDDED so that we can
> > be sure people don't have man-pages on the device. ;)
> > 
> > Seriously, I think doing authorization check based on gids in a sysctl is
> > wrong.
> 
> It is quite weird but perhaps made sense in the context of some embedded
> systems.

The origins of this interface are in the openwall project. I assume
embedded devices were not that high up on their agenda.

> > Switching over to capabilities seems to make this interface much
> > more useable to me. But we would need to make sure, that we don't suddenly
> > allow people to use those sockets where it was restricted previously.
> 
> Standard ping could already be implemented as setcap (CAP_NET_RAW).  You
> want a capability just for ping?

That came to my mind at first, yes.

Hm, that's quite difficult:

I don't think we can stop respecting ping_group_range. So one possibility
is to just always allow icmp socket access if CAP_NET_RAW is in the
effective set *or* user is in a valid gid. But why should people switch
to icmp sockets and why should we add more code to iputils then if they
also have full CAP_NET_RAW?

We could be nitpicking and add a new capability, but I would be too
lazy to do that for the very little gain to give users only access to
ping/traceroute without giving access to the whole NET_RAW world.

We absolutely cannot abandon the interface as it already is in use by
android, as Lorenzo stated. Will android switch to file based capabilities
in some time? Is that possible?

I think I am in favour of the Kconfig option that it can be disabled or
compiled as a module (maybe only visible with CONFIG_EMBEDDED) and push that
on the deprecated list as file based capabilities made this socket type
unnecessary.

Any thoughts?

Bye,

  Hannes
