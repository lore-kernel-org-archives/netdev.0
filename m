From: Julian Anastasov <ja@ssi.bg>
Subject: Re: suggestion for routing code improvement
Date: Wed, 10 Apr 2002 21:37:46 +0000 (GMT)
Sender: owner-netdev@oss.sgi.com
Message-ID: <Pine.LNX.4.44.0204102126320.1082-100000@u.domain.uli>
References: <3CB47B90.B4CF1FAD@nortelnetworks.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@oss.sgi.com
Return-path: <owner-netdev@oss.sgi.com>
To: Chris Friesen <cfriesen@nortelnetworks.com>
In-Reply-To: <3CB47B90.B4CF1FAD@nortelnetworks.com>
List-Id: netdev.vger.kernel.org


	Hello,

On Wed, 10 Apr 2002, Chris Friesen wrote:

> However, when you then up the interface, the routes do not come back up
> automatically.  This is the part that I don't agree with.
>
> Addresses, automatic routes, and custom rules either stay in effect or are
> brought back up by the system when an interface is downed and then upped.  The
> only exception to this is custom routes.

	Check this implementation of static routes (new version
is coming soon...):

http://www.linuxvirtualserver.org/~julian/#routes

The exact patches for static routes:
http://www.linuxvirtualserver.org/~julian/00_static_routes-2.4.16-6.diff
http://www.linuxvirtualserver.org/~julian/00_static_routes-2.2.20-6.diff

> So, what do you guys think?  Is this a reasonable thing to do?  I think that it
> makes the system nicely symmetrical, as opposed to the asymmetrical handling of
> current kernels.

	The patches are not perfect but I hope they can help you:

ip route add XXX proto static

	Such routes survive only device state changes. They are
removed when the last IP address is deleted or the device is
unregistered. Of course, it is recommended that the multipath
routes are recreated when a device used in nexthop is unregistered
or all its addresses are deleted. So, it needs some scripting and
help from user space.

> Thanks,
>
>
> Chris

Regards

--
Julian Anastasov <ja@ssi.bg>
