From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH] New driver "sfc" for Solarstorm SFC4000 controller (try #7)
Date: Mon, 3 Mar 2008 21:17:44 +0000
Message-ID: <20080303211743.GG2988@solarflare.com>
References: <20080303185624.GC2988@solarflare.com> <20080303.110206.36977456.davem@davemloft.net> <1204572175.16248.5.camel@localhost.localdomain> <20080303123937.2d72d7e8@extreme>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Dan Williams <dcbw@redhat.com>, David Miller <davem@davemloft.net>,
	netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rutherford.zen.co.uk ([212.23.3.142]:32826 "EHLO
	rutherford.zen.co.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752447AbYCCVRy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 3 Mar 2008 16:17:54 -0500
Content-Disposition: inline
In-Reply-To: <20080303123937.2d72d7e8@extreme>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Stephen Hemminger wrote:
> On Mon, 03 Mar 2008 14:22:55 -0500
> Dan Williams <dcbw@redhat.com> wrote:
> 
> > On Mon, 2008-03-03 at 11:02 -0800, David Miller wrote:
> > > From: Ben Hutchings <bhutchings@solarflare.com>
> > > Date: Mon, 3 Mar 2008 18:56:24 +0000
> > > 
> > > > The patch (against netdev-2.6) is at:
> > > >   https://support.solarflare.com/netdev/7/netdev-2.6-sfc-2.2.0106.patch
> > > 
> > > Nobody can properly review the driver if it's off on some external web
> > > site instead of posted here.
> > 
> > The diff is 707K; I certainly thought that netdev had a message size
> > limit.  What's the proper policy on splitting up _new_ drivers?  There
> > may/may not be a good way of splitting up any given new driver for
> > piecemeal in-line review.  If there's not, what's the alternative?
> 
> Part of the problem is that you put a lot of stuff all in one driver:

It's comparable in size to most other high-performance Ethernet
drivers.  It has to do a little more work talking to the hardware as
there is no firmware.

>   * sensors support

While this sort of protection is unusual, in this case I don't think
it's something that can reasonably be done outside the driver.

>   * large debugfs chunk

debugfs code is separated out, quite straightforward, and can't
really go anywhere but in this driver.

>   * efx driver layer

"efx" is a common prefix used in our driver code to be independent of
product and company names.  It isn't a separate layer.

>   * event queue

We could try writing a driver that just guessed what the NIC was
doing, but I don't think it would work very well. ;-)

> You created a big monolith. No one likes reading big stuff, it requires
> lots of time, as much as going over a whole subsystem. The fact that so
> many callbacks and hooks are needed implies that the design got out of hand
> for a simple device.

It's not a simple device.  There are callbacks into MAC-, PHY- and
board-specific code because this code supports several of each.  I
spent some weeks ruthlessly paring away unnecessary abstraction and
cruft, and I don't believe there is a significant amount left.

> Maybe an alternative would be to make your device better match existing
> infrastructure. The EFX code looks like a separate driver which should
> show up as a bus in the driver model, not a network device.

Are you talking about driverlink?

> Other people who don't just do network device could help as well.

The MTD driver has already benefitted from review on the linux-mtd
list.

Ben.

-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
