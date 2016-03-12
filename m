From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH net-next 5/5] phy: fixed: Fix removal of phys.
Date: Sat, 12 Mar 2016 18:24:29 +0100
Message-ID: <20160312172429.GB2186@lunn.ch>
References: <1457737300-23660-1-git-send-email-andrew@lunn.ch>
 <1457737300-23660-6-git-send-email-andrew@lunn.ch>
 <56E35250.6020101@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	Vivien Didelot <vivien.didelot@savoirfairelinux.com>
To: Florian Fainelli <f.fainelli@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:55437 "EHLO vps0.lunn.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751883AbcCLRYc (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 12 Mar 2016 12:24:32 -0500
Content-Disposition: inline
In-Reply-To: <56E35250.6020101@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> > +void fixed_phy_unregister(struct phy_device *phy)
> > +{
> > +	phy_device_remove(phy);
> > +
> > +	fixed_phy_del(phy->mdio.addr);
> 
> fixed_phy_del() should also make sure that there is no dangling
> link_update callback registered, even though this is not fatal, as it
> checks whether the phydev is NULL, we should automatically unregister
> one by doing something like: fixed_phy_set_link_update(phydev, NULL) for
> robustness.

Hi Florian

I don't see how it could happen. The link_update callback is only
called from fixed_mdio_read(). But we have just called
phy_device_remove(). There should not be anything using
fixed_mdio_read() after that. Also, fixed_phy_del() first removes fp
from the list of fmb->phys, meaning it is no longer possible to find
it, and then kfree(fp). So if there is some way we have a dangling
link_update, we are in big trouble, and the locking is badly broken...

    Andrew
