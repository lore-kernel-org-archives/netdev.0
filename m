From: Greg KH <gregkh@suse.de>
Subject: Re: [RFC PATCH] platform: Faciliatate the creation of
 pseduo-platform busses
Date: Tue, 3 Aug 2010 17:09:45 -0700
Message-ID: <20100804000945.GA19729@suse.de>
References: <4C58A7AA.8020007@codeaurora.org>
 <20100803235631.GA17759@suse.de>
 <4C58AE15.6090900@codeaurora.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org, linux-arm-msm@vger.kernel.org,
	linux-omap@vger.kernel.org, damm@opensource.se,
	lethal@linux-sh.org, rjw@sisk.pl, dtor@mail.ru,
	eric.y.miao@gmail.com, netdev@vger.kernel.org
To: Patrick Pannuto <ppannuto@codeaurora.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cantor.suse.de ([195.135.220.2]:55055 "EHLO mx1.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757554Ab0HDAKD (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 3 Aug 2010 20:10:03 -0400
Content-Disposition: inline
In-Reply-To: <4C58AE15.6090900@codeaurora.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Aug 03, 2010 at 05:02:29PM -0700, Patrick Pannuto wrote:
> On 08/03/2010 04:56 PM, Greg KH wrote:
> > On Tue, Aug 03, 2010 at 04:35:06PM -0700, Patrick Pannuto wrote:
> >> Inspiration for this comes from:
> >> http://www.mail-archive.com/linux-omap@vger.kernel.org/msg31161.html
> >>
> >> INTRO
> >>
> >> As SOCs become more popular, the desire to quickly define a simple,
> >> but functional, bus type with only a few unique properties becomes
> >> desirable. As they become more complicated, the ability to nest these
> >> simple busses and otherwise orchestrate them to match the actual
> >> topology also becomes desirable.
> >>
> >> EXAMPLE USAGE
> >>
> >> /arch/ARCH/MY_ARCH/my_bus.c:
> >>
> >> 	#include <linux/device.h>
> >> 	#include <linux/platform_device.h>
> >>
> >> 	struct bus_type my_bus_type = {
> >> 		.name	= "mybus",
> >> 	};
> >> 	EXPORT_SYMBOL_GPL(my_bus_type);

For your question below, this could be in write-only memory.  Well, I
guess it never is as we modify things in the bus structure, so nevermind
about that, false alarm.

> >>
> >> 	struct platform_device sub_bus1 = {
> >> 		.name		= "sub_bus1",
> >> 		.id		= -1,
> >> 		.dev.bus	= &my_bus_type,
> >> 	}
> >> 	EXPORT_SYMBOL_GPL(sub_bus1);
> > 
> > You really want a bus hanging off of a bus?  Normally you need a device
> > to do that, which is what I think you have here, but the naming is a bit
> > odd to me.
> > 
> > What would you do with this "sub bus"?  It's just a device, but you are
> > wanting it to be around for something.
> > 
> 
> It's for power management stuff, basically, there are actual physical buses
> involved that can be completely powered off IFF all of their devices are
> not in use. Plus it actually matches bus topology this way.

Then create a real bus hanging off of a device, not another device that
"acts" like a bus here, right?  Or am I missing the point?

> >> +void platform_bus_type_init(struct bus_type *bus)
> >> +{
> >> +	if (!bus->dev_attrs)
> >> +		bus->dev_attrs = platform_bus_type.dev_attrs;
> >> +	if (!bus->match)
> >> +		bus->match = platform_bus_type.match;
> >> +	if (!bus->uevent)
> >> +		bus->uevent = platform_bus_type.uevent;
> >> +	if (!bus->pm)
> >> +		bus->pm = platform_bus_type.pm;
> > 
> > Watch out for things in "write only" memory here.  That could cause
> > problems.
> 
> Pardon my ignorance (I'm quite new to kernel work), what do you mean
> here? What memory could be "write only"?

See above.  I was thinking that struct bus would be a constant or
something.  Sorry.

greg k-h
