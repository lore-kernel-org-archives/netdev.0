From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: Need help with mdiobus_register and phy
Date: Sat, 15 Oct 2016 20:02:19 +0200
Message-ID: <20161015180219.GB6918@lunn.ch>
References: <5800D214.70808@codeaurora.org>
 <20161014124928.GJ5822@lunn.ch>
 <5800D474.1030303@codeaurora.org>
 <20161014125736.GK5822@lunn.ch>
 <5800D796.1030602@codeaurora.org>
 <20161014131852.GM5822@lunn.ch>
 <58010E79.2030607@codeaurora.org>
 <20161014172514.GA23455@lunn.ch>
 <535FE9FE-0D69-4874-BBF0-F0662C2157DB@gmail.com>
 <58023F90.5070302@codeaurora.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Florian Fainelli <f.fainelli@gmail.com>, netdev@vger.kernel.org
To: Timur Tabi <timur@codeaurora.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:45984 "EHLO vps0.lunn.ch"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751986AbcJOSDz (ORCPT <rfc822;netdev@vger.kernel.org>);
        Sat, 15 Oct 2016 14:03:55 -0400
Content-Disposition: inline
In-Reply-To: <58023F90.5070302@codeaurora.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Oct 15, 2016 at 09:39:12AM -0500, Timur Tabi wrote:
> Florian Fainelli wrote:
> >After reading the spec again, it does not appear to me that a PHY
> >with PDOWN set is guaranteed or even required to respond to other
> >register reads such as MII_PHYID1/2, in which case we may have to
> >implement a MDIO bus reset routine which clears PDOWN for all PHYs
> >that we detect(ed), or as Andrew suggested, utilize the matching by
> >compatible string with the PHY OUI in it.
> 
> The 8031 does respond normally when PDOWN is set.  However, the ID
> registers are not available when the SerDes bus is also powered
> down. I'll call this PDOWN+.  This is a special power-down sequence
> that the at803x driver does on suspend.  See my other email for
> details.

So we appear to have two ways to go:

1) Take the SerDes power down out of the suspend code for the at803x.

2) Assume MII_PHYID1/2 registers are not guaranteed to be available
when the PHY is powered down. So get_phy_id should first read
MII_BMCR. If it gets 0xffff, assume there is no PHY there. If the
PDOWN bit is set, power up the PHY. Then reading the ID registers.

      Andrew
