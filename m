From: Lennert Buytenhek <buytenh@wantstofly.org>
Subject: Re: [PATCH] Re: ep93xx_eth PHY problems
Date: Sun, 14 Sep 2008 13:47:48 +0200
Message-ID: <20080914114748.GA26704@xi.wantstofly.org>
References: <47CD4857.2060406@student.tuwien.ac.at> <20080321202202.129c1239@ors> <48CC72D4.1020001@garzik.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Oliver Martin <oliver.martin@student.tuwien.ac.at>,
	netdev@vger.kernel.org
To: Jeff Garzik <jeff@garzik.org>, Herbert Valerio Riedel <hvr@gnu.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from xi.wantstofly.org ([83.160.184.112]:60619 "EHLO
	xi.wantstofly.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752836AbYINLrw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 14 Sep 2008 07:47:52 -0400
Content-Disposition: inline
In-Reply-To: <48CC72D4.1020001@garzik.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Sep 13, 2008 at 10:11:32PM -0400, Jeff Garzik wrote:

> >Am Tue, 04 Mar 2008 14:02:15 +0100
> >schrieb Oliver Martin <oliver.martin@student.tuwien.ac.at>:
> >>Now I'm having different problems: When auto-negotiation is enabled,
> >>it sometimes randomly changes the link state:
> >>
> >>PHY: 0:01 - Link is Down
> >>PHY: 0:01 - Link is Up - 100/Full
> >
> >I've found at least one part of the problem. The MDIO clock divisor
> >wasn't set again after the reset in ep93xx_start_hw. It was left at the
> >default, resulting in a 12.5 MHz clock, which the PHY (Micrel KSZ8721BL)
> >didn't like too much. Calling ep93xx_mdio_reset after the reset fixed
> >it, the link is now perfectly stable in auto-negotiation mode.
> >
> >There still seems to be another bug with auto-negotiation disabled: It
> >doesn't switch to 1000 Mbps any more, but most times it doesn't stay in
> >the intended configuration either. I haven't done any extensive
> >testing of this yet, though.
> >
> >Signed-off-by: Oliver Martin <oliver.martin@student.tuwien.ac.at>
> 
> Testing feedback?  Lennert ack?

ACKed on March 29.  Since this patch depends on Herbert Valerio
Riedel's ep93xx_eth phylib conversion, I asked Herbert to resend his
latest version of those patches at that time, but I didn't see that
yet.

Herbert, have you made changes to the ep93xx_eth phylib patch since
you last posted it and/or what is the latest version?
