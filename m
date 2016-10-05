From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH net-next 2/2] net: phy: Add PHY Auto/Mdi/Mdix set driver
 for Microsemi PHYs.
Date: Wed, 5 Oct 2016 09:18:34 +0200
Message-ID: <20161005071834.GD5575@lunn.ch>
References: <1475064078-22310-1-git-send-email-Raju.Lakkaraju@microsemi.com>
 <1475064078-22310-3-git-send-email-Raju.Lakkaraju@microsemi.com>
 <20160928202451.GC30728@lunn.ch>
 <20161004143122.GC29274@microsemi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, f.fainelli@gmail.com,
        Allan.Nielsen@microsemi.com
To: Raju Lakkaraju <Raju.Lakkaraju@microsemi.com>,
        Florian Fainelli <f.fainelli@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:39127 "EHLO vps0.lunn.ch"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1750940AbcJEHSh (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 5 Oct 2016 03:18:37 -0400
Content-Disposition: inline
In-Reply-To: <20161004143122.GC29274@microsemi.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> > > +     phydev->mdix = ETH_TP_MDI_AUTO;
> > 
> > Humm, interesting. The only other driver supporting mdix is the
> > Marvell one. It does not do this, it leaves it to its default value of
> > ETH_TP_MDI_INVALID. It does however interpret ETH_TP_MDI_INVALID as
> > meaning as ETH_TP_MDI_AUTO.
> > 
> > There needs to be consistency here. You either need to do the same as
> > the Marvell driver, or you need to modify the Marvell driver to also
> > set phydev->mdix to ETH_TP_MDI_AUTO.
> > 
> In Ethtool two variable i.e. eth_tp_mdix_ctrl, eth_tp_mdix use to update
> the status. But, driver header is having one variable i.e. mdix.
> Driver header should also have another variabl like mdix_ctrl.
> Then, Ethtool can get/set the Auto MDIX/MDI.
> In case, mdix is not configure with ETH_TP_MDI_AUTO, Ethtool shows error as
> "setting MDI not supported"
> 
> Please suggest me if you have any better method to fix this issue.

Maybe we should add a new flag for the .flags member of the
phy_driver. If PHY_HAS_MDIX is set, the phy core will set phydev->mdix
to ETH_TP_MDI_AUTO?

Florian, what do you think?

	 Andrew
