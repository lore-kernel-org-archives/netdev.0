From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [RFC PATCH net-next 2/2] phy: fixed-phy: Allow DT description of
 an MDIO bus and PHYs.
Date: Sat, 12 Mar 2016 18:32:44 +0100
Message-ID: <20160312173244.GC2186@lunn.ch>
References: <1457737726-23907-1-git-send-email-andrew@lunn.ch>
 <1457737726-23907-3-git-send-email-andrew@lunn.ch>
 <56E35530.6000009@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev <netdev@vger.kernel.org>
To: Florian Fainelli <f.fainelli@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:55440 "EHLO vps0.lunn.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751682AbcCLRcq (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 12 Mar 2016 12:32:46 -0500
Content-Disposition: inline
In-Reply-To: <56E35530.6000009@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> One too many " here.
> 
> > +- #address-cells = <1>;
> > +- #size-cells = <0>;
> > +
> > +Child nodes represent PHYs on this mdio bus. Standard properties for
> > +fixed links, 'speed', 'full-duplex', 'pause', 'asym-pause',
> > +'link-gpios', as defined above are used. Additionally a 'reg' property
> > +is required for the address of the PHY on the bus. This should be of
> > +value 0 to 31.
> 
> This is a virtual bus, the only limitation is because we re-use to the
> maximum permission extent the real MDIO bus code, and this is putting a
> SW constraint on something that does not have one here.

Hi Florian

I now took a look at the core code. PHY_MAX_ADDR is used in quite a
few places, e.g. phy_find_first(), of_mdiobus_link_phydev(),
__mdiobus_register(). In order to be able to use this virtual MDIO bus
just like any other MDIO bus, we need to enforce PHY_MAX_ADDR.
Otherwise it is not going to work.

	  Andrew
