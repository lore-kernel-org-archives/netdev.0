From: Lennert Buytenhek <buytenh@wantstofly.org>
Subject: Re: Marvell 88E609x switch?
Date: Thu, 26 Feb 2009 16:57:26 +0100
Message-ID: <20090226155726.GO17040@xi.wantstofly.org>
References: <49A49C06.90908@mlbassoc.com> <20090225131550.GA24996@xi.wantstofly.org> <49A5B877.8080403@mlbassoc.com> <20090226151107.GN17040@xi.wantstofly.org> <49A6B991.2090703@mlbassoc.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Gary Thomas <gary@mlbassoc.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from xi.wantstofly.org ([80.101.37.227]:54900 "EHLO
	xi.wantstofly.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753382AbZBZP53 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 Feb 2009 10:57:29 -0500
Content-Disposition: inline
In-Reply-To: <49A6B991.2090703@mlbassoc.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Feb 26, 2009 at 08:47:29AM -0700, Gary Thomas wrote:

> >>>> Is there support for this device anywhere?  In particular,
> >>>> the M88E6095 switch.
> >>> Not at the moment, but it should be easy enough to add.  If your
> >>> board already runs on 2.6.28+, I can whip up some patches for you
> >>> to try from the docs I have for that part.
> >> That would be much appreciated, thanks.
> > 
> > I noticed that the 6095/6095F are quite similar to the 6131 as far
> > as the register set goes.  So something along these lines (hacky
> > patch, breaks 6131, not for mainline) might just work to detect
> > single 6095s (cascading DSA chips is something that needs more work,
> > let's get the single-chip case working first).
> > 
> > The other thing you'll need to do is create dsa platform devices
> > for your switch chips, a la how it's done in arch/arm/mach-orion5x/
> > or arch/arm/mach-kirkwood/ for example -- you need to pass in a struct
> > device * for your network device, a struct device * for your mii bus,
> > the switch MII address on the MII bus, and names of the individual
> > ports (where you'll specify "cpu" for the port on the switch chip that
> > the CPU is connected to).
> > 
> > Let me know if this works.
> 
> Thanks, I'll give it a try.  It will take a little effort
> to get setup as I have to work within the open firmware
> structure (that's how all the various components are
> specified).

Right, we don't have OF bindings yet.  I guess this would make sense
to do generically at some point, since there are quite a few PPC
platforms with DSA switch chips.
