From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH 2/5] net: phy: hook up clause 45 autonegotiation restart
Date: Fri, 2 Jun 2017 15:46:32 +0200
Message-ID: <20170602134632.GI12261@lunn.ch>
References: <E1dGNJM-00043g-KJ@rmk-PC.armlinux.org.uk>
 <20170601122350.GA9282@lunn.ch>
 <20170601125132.GY22219@n2100.armlinux.org.uk>
 <20170601130527.GG9282@lunn.ch>
 <20170601130900.GA22219@n2100.armlinux.org.uk>
 <20170601131955.GH9282@lunn.ch>
 <20170601154735.GB22219@n2100.armlinux.org.uk>
 <20170601162417.GA14541@n2100.armlinux.org.uk>
 <23c238e0-2af8-3171-9986-af02e9c19129@gmail.com>
 <20170602124339.GO22219@n2100.armlinux.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Florian Fainelli <f.fainelli@gmail.com>, netdev@vger.kernel.org
To: Russell King - ARM Linux <linux@armlinux.org.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:34101 "EHLO vps0.lunn.ch"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751125AbdFBNqf (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 2 Jun 2017 09:46:35 -0400
Content-Disposition: inline
In-Reply-To: <20170602124339.GO22219@n2100.armlinux.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Jun 02, 2017 at 01:43:39PM +0100, Russell King - ARM Linux wrote:
> On Thu, Jun 01, 2017 at 10:16:17AM -0700, Florian Fainelli wrote:
> > On 06/01/2017 09:24 AM, Russell King - ARM Linux wrote:
> > > Checking 802.3-2015, in "22.2.4 Management functions", the first
> > > sentence requires all PHYs that respond to Clause 22 cycles to
> > > implement BMCR and BMSR.  However, my statement about unimplemented
> > > registers returning zero seems to be a C45 thing, not a C22 thing,
> > > according to the C22 PICS and "45.2 MDIO Interface Registers"
> > > 
> > > However, digging a bit further, "22.2.4.2.10 Auto-Negotiation complete"
> > > states that bit 5 shall be zero if aneg has not completed or if aneg is
> > > unimplemented.
> > > 
> > 
> > So how about we are more defensive than that and if we are presented
> > with a C45 PHY driver that does not have an aneg_done() function pointer
> > set we return an error/warning during driver registration?
> 
> We don't mark drivers as being C22 or C45, we rely on them matching
> the IDs and/or the probe function making that decision, so it's a
> tad difficult to make that decision at driver registration time.
> 
> We could reject an attempt to probe a C45 phy with a driver that
> does not provide an aneg_done() pointer.

Just an idea.

We could make phy_read/phy_write look to see if the is_c45 flag is
set. If so, return -EINVAL if the register being accessed does not
have MII_ADDR_C45.

That should catch all these sort of problems.

     Andrew
