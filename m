From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH 2/5] net: phy: hook up clause 45 autonegotiation restart
Date: Thu, 1 Jun 2017 15:05:27 +0200
Message-ID: <20170601130527.GG9282@lunn.ch>
References: <20170601102327.GF27796@n2100.armlinux.org.uk>
 <E1dGNJM-00043g-KJ@rmk-PC.armlinux.org.uk>
 <20170601122350.GA9282@lunn.ch>
 <20170601125132.GY22219@n2100.armlinux.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Florian Fainelli <f.fainelli@gmail.com>, netdev@vger.kernel.org
To: Russell King - ARM Linux <linux@armlinux.org.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:32806 "EHLO vps0.lunn.ch"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751083AbdFANF3 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 1 Jun 2017 09:05:29 -0400
Content-Disposition: inline
In-Reply-To: <20170601125132.GY22219@n2100.armlinux.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> > > +/**
> > > + * phy_restart_aneg - restart auto-negotiation
> > > + * @phydev: target phy_device struct
> > > + *
> > > + * Restart the autonegotiation on @phydev.  Returns >= 0 on success or
> > > + * negative errno on error.
> > > + */
> > > +int phy_restart_aneg(struct phy_device *phydev)
> > > +{
> > > +	int ret;
> > > +
> > > +	if (phydev->is_c45)
> > > +		ret = genphy_c45_restart_aneg(phydev);
> > > +	else
> > > +		ret = genphy_restart_aneg(phydev);
> > > +
> > > +	return ret;
> > > +}
> > > +EXPORT_SYMBOL_GPL(phy_restart_aneg);
> > 
> > Hi Russell
> > 
> > Isn't the same sort of thing needed in phy_aneg_done()?
> 
> No, because phy_aneg_done() already has hooks in it which PHY drivers
> can use to override the default C22 implementation.
> 
> I did toy with providing a similar conditional in phy_aneg_done(), but
> decided it was better to use the existing hooks where present, rather
> than needlessly adding additional code.

Hi Russell

So you are saying a 10G PHY driver always needs to have a aneg_done
callback, even if it just needs to call phygen_c45_aneg_done?

This seems a bit error prone. I can see somebody writing a 10G driver,
leaving out aneg_done() and having the c22 version called. Is the read
of MII_BMSR likely to return 0xffff, since the register does not
exist? If so, genphy_aneg_done() is likely to always return
BMSR_ANEGCOMPLETE.

Seems like a trap waiting for somebody to fall into it. The additional
code might be worth it to avoid placing this trap.

      Andrew
