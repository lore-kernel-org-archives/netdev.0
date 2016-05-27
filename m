From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [RFC PATCH 12/16] dsa: Make mdio bus optional
Date: Fri, 27 May 2016 17:18:51 +0200
Message-ID: <20160527151851.GD20214@lunn.ch>
References: <1464312050-23023-1-git-send-email-andrew@lunn.ch>
 <1464312050-23023-13-git-send-email-andrew@lunn.ch>
 <87inxz5z4e.fsf@ketchup.mtl.sfl>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev <netdev@vger.kernel.org>,
	Florian Fainelli <f.fainelli@gmail.com>,
	John Crispin <john@phrozen.org>, Bryan.Whitehead@microchip.com
To: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:52884 "EHLO vps0.lunn.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754154AbcE0PSx (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 27 May 2016 11:18:53 -0400
Content-Disposition: inline
In-Reply-To: <87inxz5z4e.fsf@ketchup.mtl.sfl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, May 27, 2016 at 10:55:45AM -0400, Vivien Didelot wrote:
> Hi Andrew,
> 
> Andrew Lunn <andrew@lunn.ch> writes:
> 
> > -	mdiobus_unregister(ds->slave_mii_bus);
> > +	if (ds->slave_mii_bus && ds->drv->phy_read)
> > +		mdiobus_unregister(ds->slave_mii_bus);
> 
> So if a driver registered the slave MII bus itself, it may have
> unregistered it itself as well, so checking ds->slave_mii_bus is OK
> (assuming the driver correctly zero'ed it).
> 
> But is it necessary to check ds->drv->phy_read?

It makes the code symmetrical to the register code, which makes the
same check. My experience is that keeping the code symmetrical results
in less surprises late on.

One such surprise could be a driver that does not zero
ds->slave_mii_bus. In fact, mv88e6xxx does not zero it. So we would
get a double unregister happening. We also don't want the core
unregistering it, since we have other cleanup work to do, we have an
of_node_put() to call.

	Andrew
