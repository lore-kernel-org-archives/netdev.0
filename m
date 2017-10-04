From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH 2/3 v2] net: phy: DP83822 initial driver submission
Date: Thu, 5 Oct 2017 01:53:07 +0200
Message-ID: <20171004235307.GD16612@lunn.ch>
References: <20171004182031.13794-1-dmurphy@ti.com>
 <20171004182031.13794-2-dmurphy@ti.com>
 <9235D6609DB808459E95D78E17F2E43D40B3F9A9@CHN-SV-EXMX02.mchp-main.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: dmurphy@ti.com, f.fainelli@gmail.com, netdev@vger.kernel.org,
        afd@ti.com
To: Woojung.Huh@microchip.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([185.16.172.187]:39822 "EHLO vps0.lunn.ch"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751197AbdJDXxK (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 4 Oct 2017 19:53:10 -0400
Content-Disposition: inline
In-Reply-To: <9235D6609DB808459E95D78E17F2E43D40B3F9A9@CHN-SV-EXMX02.mchp-main.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Oct 04, 2017 at 10:44:36PM +0000, Woojung.Huh@microchip.com wrote:
> > +static int dp83822_suspend(struct phy_device *phydev)
> > +{
> > +	int value;
> > +
> > +	mutex_lock(&phydev->lock);
> > +	value = phy_read_mmd(phydev, DP83822_DEVADDR,
> > MII_DP83822_WOL_CFG);
> > +	mutex_unlock(&phydev->lock);

> Would we need mutex to access phy_read_mmd()?
> phy_read_mmd() has mdio_lock for indirect access.

Hi Woojung

The mdio lock is not sufficient. It protects against two mdio
accesses. But here we need to protect against two phy operations.
There is a danger something else tries to access the phy during
suspend.

> > +	if (!(value & DP83822_WOL_EN))
> > +		genphy_suspend(phydev);

Releasing the lock before calling genphy_suspend() is not so nice.
Maybe add a version which assumes the lock has already been taken?

      Andrew
