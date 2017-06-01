From: Russell King - ARM Linux <linux@armlinux.org.uk>
Subject: Re: [PATCH 2/5] net: phy: hook up clause 45 autonegotiation restart
Date: Thu, 1 Jun 2017 16:47:35 +0100
Message-ID: <20170601154735.GB22219@n2100.armlinux.org.uk>
References: <20170601102327.GF27796@n2100.armlinux.org.uk>
 <E1dGNJM-00043g-KJ@rmk-PC.armlinux.org.uk>
 <20170601122350.GA9282@lunn.ch>
 <20170601125132.GY22219@n2100.armlinux.org.uk>
 <20170601130527.GG9282@lunn.ch>
 <20170601130900.GA22219@n2100.armlinux.org.uk>
 <20170601131955.GH9282@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Florian Fainelli <f.fainelli@gmail.com>, netdev@vger.kernel.org
To: Andrew Lunn <andrew@lunn.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from pandora.armlinux.org.uk ([78.32.30.218]:56776 "EHLO
        pandora.armlinux.org.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752473AbdFAPrs (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 1 Jun 2017 11:47:48 -0400
Content-Disposition: inline
In-Reply-To: <20170601131955.GH9282@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jun 01, 2017 at 03:19:55PM +0200, Andrew Lunn wrote:
> On Thu, Jun 01, 2017 at 02:09:00PM +0100, Russell King - ARM Linux wrote:
> > On Thu, Jun 01, 2017 at 03:05:27PM +0200, Andrew Lunn wrote:
> > > So you are saying a 10G PHY driver always needs to have a aneg_done
> > > callback, even if it just needs to call phygen_c45_aneg_done?
> > > 
> > > This seems a bit error prone. I can see somebody writing a 10G driver,
> > > leaving out aneg_done() and having the c22 version called. Is the read
> > > of MII_BMSR likely to return 0xffff, since the register does not
> > > exist? If so, genphy_aneg_done() is likely to always return
> > > BMSR_ANEGCOMPLETE.
> > 
> > Don't forget that the read will fail, so phy_read() will return a
> > negative number.
> 
> By fail, you mean return something like -EIO or -ETIMEOUT? Is this
> guaranteed in the code somewhere? This particular Marvell PHY only
> does c45. But i could imagine some other PHYs answering a c22 request
> with 0xffff.

Yes, C45 allows the PHYs to answer C22 as well, but then they have to
implement the C22 register set.  Such a PHY would be out of spec,
especially as what you're suggesting is that it answers C22 cycles
and fails to implement MII_BMSR.  I also think that there's a comment
in the 802.3 specs that says that unimplemented registers are to
return zero, not 0xffff.

So, if there is a non-compliant PHY like that, I think the time to
address it is when such a broken situation appears, rather than
engineering additional complexity before we know we need it.

-- 
RMK's Patch system: http://www.armlinux.org.uk/developer/patches/
FTTC broadband for 0.8mile line: currently at 9.6Mbps down 400kbps up
according to speedtest.net.
