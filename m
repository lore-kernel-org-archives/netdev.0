From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: Re: [RFC PATCH 12/16] dsa: Make mdio bus optional
Date: Fri, 27 May 2016 12:38:47 -0400
Message-ID: <87d1o75uco.fsf@ketchup.mtl.sfl>
References: <1464312050-23023-1-git-send-email-andrew@lunn.ch> <1464312050-23023-13-git-send-email-andrew@lunn.ch> <87inxz5z4e.fsf@ketchup.mtl.sfl> <20160527151851.GD20214@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain
Cc: netdev <netdev@vger.kernel.org>,
	Florian Fainelli <f.fainelli@gmail.com>,
	John Crispin <john@phrozen.org>, Bryan.Whitehead@microchip.com
To: Andrew Lunn <andrew@lunn.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.savoirfairelinux.com ([208.88.110.44]:58350 "EHLO
	mail.savoirfairelinux.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750914AbcE0Qiu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 27 May 2016 12:38:50 -0400
In-Reply-To: <20160527151851.GD20214@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Andrew,

Andrew Lunn <andrew@lunn.ch> writes:

> On Fri, May 27, 2016 at 10:55:45AM -0400, Vivien Didelot wrote:
>> Hi Andrew,
>> 
>> Andrew Lunn <andrew@lunn.ch> writes:
>> 
>> > -	mdiobus_unregister(ds->slave_mii_bus);
>> > +	if (ds->slave_mii_bus && ds->drv->phy_read)
>> > +		mdiobus_unregister(ds->slave_mii_bus);
>> 
>> So if a driver registered the slave MII bus itself, it may have
>> unregistered it itself as well, so checking ds->slave_mii_bus is OK
>> (assuming the driver correctly zero'ed it).
>> 
>> But is it necessary to check ds->drv->phy_read?
>
> It makes the code symmetrical to the register code, which makes the
> same check. My experience is that keeping the code symmetrical results
> in less surprises late on.
>
> One such surprise could be a driver that does not zero
> ds->slave_mii_bus. In fact, mv88e6xxx does not zero it. So we would
> get a double unregister happening. We also don't want the core
> unregistering it, since we have other cleanup work to do, we have an
> of_node_put() to call.

OK good for me, as long as it is intuitive for the driver
implementation.

Thanks,

        Vivien
