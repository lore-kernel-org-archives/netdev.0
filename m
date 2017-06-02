From: Russell King - ARM Linux <linux@armlinux.org.uk>
Subject: Re: [PATCH 2/5] net: phy: hook up clause 45 autonegotiation restart
Date: Fri, 2 Jun 2017 13:43:39 +0100
Message-ID: <20170602124339.GO22219@n2100.armlinux.org.uk>
References: <20170601102327.GF27796@n2100.armlinux.org.uk>
 <E1dGNJM-00043g-KJ@rmk-PC.armlinux.org.uk>
 <20170601122350.GA9282@lunn.ch>
 <20170601125132.GY22219@n2100.armlinux.org.uk>
 <20170601130527.GG9282@lunn.ch>
 <20170601130900.GA22219@n2100.armlinux.org.uk>
 <20170601131955.GH9282@lunn.ch>
 <20170601154735.GB22219@n2100.armlinux.org.uk>
 <20170601162417.GA14541@n2100.armlinux.org.uk>
 <23c238e0-2af8-3171-9986-af02e9c19129@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Andrew Lunn <andrew@lunn.ch>, netdev@vger.kernel.org
To: Florian Fainelli <f.fainelli@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from pandora.armlinux.org.uk ([78.32.30.218]:42998 "EHLO
        pandora.armlinux.org.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751125AbdFBMnr (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 2 Jun 2017 08:43:47 -0400
Content-Disposition: inline
In-Reply-To: <23c238e0-2af8-3171-9986-af02e9c19129@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jun 01, 2017 at 10:16:17AM -0700, Florian Fainelli wrote:
> On 06/01/2017 09:24 AM, Russell King - ARM Linux wrote:
> > Checking 802.3-2015, in "22.2.4 Management functions", the first
> > sentence requires all PHYs that respond to Clause 22 cycles to
> > implement BMCR and BMSR.  However, my statement about unimplemented
> > registers returning zero seems to be a C45 thing, not a C22 thing,
> > according to the C22 PICS and "45.2 MDIO Interface Registers"
> > 
> > However, digging a bit further, "22.2.4.2.10 Auto-Negotiation complete"
> > states that bit 5 shall be zero if aneg has not completed or if aneg is
> > unimplemented.
> > 
> 
> So how about we are more defensive than that and if we are presented
> with a C45 PHY driver that does not have an aneg_done() function pointer
> set we return an error/warning during driver registration?

We don't mark drivers as being C22 or C45, we rely on them matching
the IDs and/or the probe function making that decision, so it's a
tad difficult to make that decision at driver registration time.

We could reject an attempt to probe a C45 phy with a driver that
does not provide an aneg_done() pointer.

-- 
RMK's Patch system: http://www.armlinux.org.uk/developer/patches/
FTTC broadband for 0.8mile line: currently at 9.6Mbps down 400kbps up
according to speedtest.net.
