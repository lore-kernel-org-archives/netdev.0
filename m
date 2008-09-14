From: Lennert Buytenhek <buytenh@wantstofly.org>
Subject: Re: [PATCH] Re: ep93xx_eth PHY problems
Date: Sun, 14 Sep 2008 14:12:26 +0200
Message-ID: <20080914121226.GB26902@xi.wantstofly.org>
References: <47CD4857.2060406@student.tuwien.ac.at> <20080321202202.129c1239@ors> <48CC72D4.1020001@garzik.org> <20080914141110.18b42a42@ors.home>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jeff Garzik <jeff@garzik.org>, netdev@vger.kernel.org, hvr@gnu.org
To: Oliver Martin <oliver.martin@student.tuwien.ac.at>
Return-path: <netdev-owner@vger.kernel.org>
Received: from xi.wantstofly.org ([83.160.184.112]:46603 "EHLO
	xi.wantstofly.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753628AbYINMM1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 14 Sep 2008 08:12:27 -0400
Content-Disposition: inline
In-Reply-To: <20080914141110.18b42a42@ors.home>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Sep 14, 2008 at 02:11:10PM +0200, Oliver Martin wrote:

> > Oliver Martin wrote:
> > > Am Tue, 04 Mar 2008 14:02:15 +0100
> > > schrieb Oliver Martin <oliver.martin@student.tuwien.ac.at>:
> > >> Now I'm having different problems: When auto-negotiation is
> > >> enabled, it sometimes randomly changes the link state:
> > >>
> > >> PHY: 0:01 - Link is Down
> > >> PHY: 0:01 - Link is Up - 100/Full
> > >>
> > > 
> > > I've found at least one part of the problem. The MDIO clock divisor
> > > wasn't set again after the reset in ep93xx_start_hw. It was left at
> > > the default, resulting in a 12.5 MHz clock, which the PHY (Micrel
> > > KSZ8721BL) didn't like too much. Calling ep93xx_mdio_reset after
> > > the reset fixed it, the link is now perfectly stable in
> > > auto-negotiation mode.
> > > 
> > > There still seems to be another bug with auto-negotiation disabled:
> > > It doesn't switch to 1000 Mbps any more, but most times it doesn't
> > > stay in the intended configuration either. I haven't done any
> > > extensive testing of this yet, though.
> > > 
> > > Signed-off-by: Oliver Martin <oliver.martin@student.tuwien.ac.at>
> > 
> > Testing feedback?  Lennert ack?
> 
> We're currently using a variation of my original patch, which didn't
> handle ifdown correctly (there's a similar reset there). With the
> current setup, everything seems stable, but we still have some rather
> hackish workarounds for the original issue in our startup scripts.
> I don't have the hardware right now, but we'll specifically test
> without them both with and without auto-negotiation next week and
> report the results.

Can you stick this somewhere together with the version of the phylib
patch you are using?
