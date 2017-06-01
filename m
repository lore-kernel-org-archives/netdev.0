From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH 2/5] net: phy: hook up clause 45 autonegotiation restart
Date: Thu, 1 Jun 2017 15:19:55 +0200
Message-ID: <20170601131955.GH9282@lunn.ch>
References: <20170601102327.GF27796@n2100.armlinux.org.uk>
 <E1dGNJM-00043g-KJ@rmk-PC.armlinux.org.uk>
 <20170601122350.GA9282@lunn.ch>
 <20170601125132.GY22219@n2100.armlinux.org.uk>
 <20170601130527.GG9282@lunn.ch>
 <20170601130900.GA22219@n2100.armlinux.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Florian Fainelli <f.fainelli@gmail.com>, netdev@vger.kernel.org
To: Russell King - ARM Linux <linux@armlinux.org.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:32823 "EHLO vps0.lunn.ch"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1750952AbdFANT4 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 1 Jun 2017 09:19:56 -0400
Content-Disposition: inline
In-Reply-To: <20170601130900.GA22219@n2100.armlinux.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jun 01, 2017 at 02:09:00PM +0100, Russell King - ARM Linux wrote:
> On Thu, Jun 01, 2017 at 03:05:27PM +0200, Andrew Lunn wrote:
> > So you are saying a 10G PHY driver always needs to have a aneg_done
> > callback, even if it just needs to call phygen_c45_aneg_done?
> > 
> > This seems a bit error prone. I can see somebody writing a 10G driver,
> > leaving out aneg_done() and having the c22 version called. Is the read
> > of MII_BMSR likely to return 0xffff, since the register does not
> > exist? If so, genphy_aneg_done() is likely to always return
> > BMSR_ANEGCOMPLETE.
> 
> Don't forget that the read will fail, so phy_read() will return a
> negative number.

By fail, you mean return something like -EIO or -ETIMEOUT? Is this
guaranteed in the code somewhere? This particular Marvell PHY only
does c45. But i could imagine some other PHYs answering a c22 request
with 0xffff.

     Andrew
