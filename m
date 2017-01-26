From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH net-next 2/2] net: phy: Marvell: Add mv88e6390 internal
 PHY
Date: Thu, 26 Jan 2017 15:16:15 +0100
Message-ID: <20170126141615.GA16836@lunn.ch>
References: <1485309314-23942-1-git-send-email-andrew@lunn.ch>
 <1485309314-23942-3-git-send-email-andrew@lunn.ch>
 <87y3xyyqrh.fsf@free-electrons.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>,
        netdev <netdev@vger.kernel.org>,
        Vivien Didelot <vivien.didelot@savoirfairelinux.com>
To: Gregory CLEMENT <gregory.clement@free-electrons.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:46460 "EHLO vps0.lunn.ch"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752571AbdAZOQU (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 26 Jan 2017 09:16:20 -0500
Content-Disposition: inline
In-Reply-To: <87y3xyyqrh.fsf@free-electrons.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jan 26, 2017 at 01:01:06PM +0100, Gregory CLEMENT wrote:
> Hi Andrew,
>  
>  On mer., janv. 25 2017, Andrew Lunn <andrew@lunn.ch> wrote:
> 
> 
> > diff --git a/drivers/net/phy/marvell.c b/drivers/net/phy/marvell.c
> > index b5b73ff4329a..9debe1a4a6f6 100644
> > --- a/drivers/net/phy/marvell.c
> > +++ b/drivers/net/phy/marvell.c
> > @@ -2140,6 +2140,25 @@ static struct phy_driver marvell_drivers[] = {
> >  		.get_strings = marvell_get_strings,
> >  		.get_stats = marvell_get_stats,
> >  	},
> > +	{
> > +		.phy_id = MARVELL_PHY_ID_88E6390,
> > +		.phy_id_mask = MARVELL_PHY_ID_MASK,
> > +		.name = "Marvell 88E6390",
> > +		.features = PHY_GBIT_FEATURES,
> > +		.flags = PHY_HAS_INTERRUPT,
> > +		.probe = marvell_probe,
> 
> In order to get the temperature support I also had to modify the line
> above by using m88e1510_probe instead of the marvell_probe. Indeed the
> hwmon register was not done marvell_probe.

Yes, this is historic.

These patches come from one branch where i have all my mv88e6390
code. I had them in the opposite order to what we have now. I had this
PHY work around first, and then the temperature sensor move patches.

But to get the code into mainline, i pulled the patches apart. The
temperature code has hit mainline first, now follow the PHY ID
workaround. I need to fix this probe call as a result.

Although the temperature sensor does not work yet for the 6390, i'm
going to assume it will at some point work. So i think it is O.K. to
use the same ID, and have the 6390 PHYs return -25000mC until we
figure out what is wrong.

       Andrew
