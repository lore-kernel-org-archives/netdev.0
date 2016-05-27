From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: Re: [RFC PATCH 12/16] dsa: Make mdio bus optional
Date: Fri, 27 May 2016 10:55:45 -0400
Message-ID: <87inxz5z4e.fsf@ketchup.mtl.sfl>
References: <1464312050-23023-1-git-send-email-andrew@lunn.ch> <1464312050-23023-13-git-send-email-andrew@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Florian Fainelli <f.fainelli@gmail.com>,
	John Crispin <john@phrozen.org>, Bryan.Whitehead@microchip.com,
	Andrew Lunn <andrew@lunn.ch>
To: Andrew Lunn <andrew@lunn.ch>, netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.savoirfairelinux.com ([208.88.110.44]:54907 "EHLO
	mail.savoirfairelinux.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752454AbcE0Ozs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 27 May 2016 10:55:48 -0400
In-Reply-To: <1464312050-23023-13-git-send-email-andrew@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Andrew,

Andrew Lunn <andrew@lunn.ch> writes:

> -	mdiobus_unregister(ds->slave_mii_bus);
> +	if (ds->slave_mii_bus && ds->drv->phy_read)
> +		mdiobus_unregister(ds->slave_mii_bus);

So if a driver registered the slave MII bus itself, it may have
unregistered it itself as well, so checking ds->slave_mii_bus is OK
(assuming the driver correctly zero'ed it).

But is it necessary to check ds->drv->phy_read?

Thanks,

        Vivien
