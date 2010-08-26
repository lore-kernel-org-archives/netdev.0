From: David Lamparter <equinox@diac24.net>
Subject: Re: [PATCH RFC] netns: introduce NETREG_NETNS_MOVING reg_state
Date: Thu, 26 Aug 2010 10:21:45 +0200
Message-ID: <20100826082145.GD235835@jupiter.n2.diac24.net>
References: <20100824115056.GA235835@jupiter.n2.diac24.net>
 <4C73FAB8.1090402@free.fr>
 <m1tymjg6w8.fsf@fess.ebiederm.org>
 <20100825115213.GB235835@jupiter.n2.diac24.net>
 <4C751484.8030004@free.fr>
 <20100825135254.GC235835@jupiter.n2.diac24.net>
 <m139u2fv7u.fsf@fess.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Lamparter <equinox@diac24.net>,
	Daniel Lezcano <daniel.lezcano@free.fr>,
	netdev@vger.kernel.org, Patrick McHardy <kaber@trash.net>
To: "Eric W. Biederman" <ebiederm@xmission.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from spaceboyz.net ([87.106.131.203]:47580 "EHLO spaceboyz.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753089Ab0HZIVy (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 26 Aug 2010 04:21:54 -0400
Content-Disposition: inline
In-Reply-To: <m139u2fv7u.fsf@fess.ebiederm.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Aug 25, 2010 at 10:39:01AM -0700, Eric W. Biederman wrote:
> David Lamparter <equinox@diac24.net> writes:
> > No; since NETDEV_UNREGISTER is still sent in all places where it is
> > currently sent, none of the stacks would require changing. However,
> > users of the actual, physical device (independent of its network
> > namespace) would need changing to NETDEV_UNREGISTER_PHYSICAL, which is a
> > new notification that is only sent if the device really disappears.
> >
> > TBH, I'm not quite sure which is the better solution here;
> > NETDEV_UNREGISTER_PHYSICAL or NETREG_NETNS_MOVING...
> > ... or the initial one?
> 
> Before we get too far down any of these paths, what is it that caused
> you to notice that moving the physical device broke the connection to
> the vlan and macvlan devices?
> 
> I just want to understand this case a little better before we walk down
> any of these paths.

I'm doing system configuration software that allows you to manage
interfaces on a virtual routing platform. I can work around the
vlan-disappearings, but they kind of disrupt operation, especially as
they can affect namespaces not even related to what the user is changing
in the config.

If nothing else, I'd try to push my original patch. It is pretty
nonintrusive and should be OK with maybe a few more lines of comments.


David

