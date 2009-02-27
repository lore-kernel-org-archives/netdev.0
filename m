From: Lennert Buytenhek <buytenh@wantstofly.org>
Subject: Re: Marvell 88E609x switch?
Date: Fri, 27 Feb 2009 15:25:48 +0100
Message-ID: <20090227142548.GA17040@xi.wantstofly.org>
References: <20090225131550.GA24996@xi.wantstofly.org> <49A5B877.8080403@mlbassoc.com> <20090226151107.GN17040@xi.wantstofly.org> <49A6B991.2090703@mlbassoc.com> <20090226155726.GO17040@xi.wantstofly.org> <49A73E00.7050406@mlbassoc.com> <20090227011903.GS17040@xi.wantstofly.org> <49A7DBA2.8060605@mlbassoc.com> <20090227125211.GV17040@xi.wantstofly.org> <49A7E920.2020601@mlbassoc.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, Anton Vorontsov <avorontsov@ru.mvista.com>,
	Li Yang <leoli@freescale.com>
To: Gary Thomas <gary@mlbassoc.com>,
	Kumar Gala <galak@kernel.crashing.org>,
	Andy Fleming <afleming@freescale.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from xi.wantstofly.org ([80.101.37.227]:56264 "EHLO
	xi.wantstofly.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753984AbZB0OZv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 27 Feb 2009 09:25:51 -0500
Content-Disposition: inline
In-Reply-To: <49A7E920.2020601@mlbassoc.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Feb 27, 2009 at 06:22:40AM -0700, Gary Thomas wrote:

> >> However, the network subsystem still can't locate it.  It may be
> >> a complication of the OF stuff and how the [gianfar] network
> >> device knows what PHY to look at.
> >>
> >>   starting network interfaces...
> >>   24520:01 not found
> >>   eth0: Could not attach to PHY
> > 
> > It's correct that eth0 should not associate with a PHY -- since the
> > MAC connects to the switch chip over GMII/RGMII/SGMII, there is no
> > PHY involved.
> 
> Yes, but it's expecting to be able to talk to the PHYLIB layer
> and ask things like speed, duplex, link state, etc.
> 
> > Is the gianfar driver refusing to up the interface without a PHY?
> > It shouldn't do that -- IMHO it's perfectly fine to not have a PHY
> > on your ethernet MAC.
> 
> It seems so, yes.  I tried disabling the PHY connection in the OF
> tree and now eth0 doesn't even try to come up :-(

gianfar authors/maintainers: is there a way of using gianfar purely
as a (R)(G)MII transport, i.e. without it trying to talk to a PHY?
Gary is trying to use it to just pass packets to another
(R)(G)MII-speaking chip that doesn't have a PHY interface, but gianfar
seems to bail out if you don't give it a PHY to talk to.
