From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [PATCH 1/1] ipv6 addrconf: add IFA_F_NOPREFIXROUTE flag to suppress creation of IP6 routes
Date: Tue, 7 Jan 2014 10:39:42 +0100
Message-ID: <20140107093942.GA24730@order.stressinduktion.org>
References: <20140106160139.GB10204@order.stressinduktion.org> <1389029375-17698-1-git-send-email-thaller@redhat.com> <20140106173837.GA2571@minipsycho.orion>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: Thomas Haller <thaller@redhat.com>, netdev@vger.kernel.org,
	stephen@networkplumber.org, dcbw@redhat.com
To: Jiri Pirko <jiri@resnulli.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from order.stressinduktion.org ([87.106.68.36]:44527 "EHLO
	order.stressinduktion.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750849AbaAGJj5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 7 Jan 2014 04:39:57 -0500
Content-Disposition: inline
In-Reply-To: <20140106173837.GA2571@minipsycho.orion>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jan 06, 2014 at 06:38:37PM +0100, Jiri Pirko wrote:
> Mon, Jan 06, 2014 at 06:29:35PM CET, thaller@redhat.com wrote:
> >When adding/modifying an IPv6 address, the userspace application needs
> >a way to suppress adding a prefix route. This is for example relevant
> >together with IFA_F_MANAGERTEMPADDR, where userspace creates autoconf
> >generated addresses, but depending on on-link, no route should for the
> >prefix should be added.
> >
> >This flag will not be set as ifa_flags of the address, it is only
> >considered as parameter while adding/modifying an address.
> >
> >Signed-off-by: Thomas Haller <thaller@redhat.com>
> >---
> > Hi, how about this?
> >
> > The flag is only a parameter for the netlink command.
> > This might be unexpected, because when adding an address,
> > you won't see the flag in `ip -6 addr`.
> > Still, I think, it is better to do it this way, because having
> > an address with the NOPREFIXROUTE flag, does not mean, that
> > there is no route for this prefix. It only means, that at the
> > moment of setting the address, no route was added.
> >
> > The alternative would be, not to add a prefix route, when
> > IFA_F_MANAGERTEMPADDR is set.

Looks good, maybe you could apply Jiri's feedback.

Otherwise we could skip trying to find a corresponding prefix route in
ipv6_del_addr. You would need to add the IFA_F_NOPREFIXROUTE test just before
the addrconf_get_prefix_route and ip6_del_rt.

Greetings,

  Hannes
