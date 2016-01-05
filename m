From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [RFC PATCH net-next 03/24] phy: Use phy_read() instead of
 mdiobus_read()
Date: Tue, 5 Jan 2016 14:40:33 +0100
Message-ID: <20160105134033.GE20108@lunn.ch>
References: <1451929022-5580-1-git-send-email-andrew@lunn.ch>
 <1451929022-5580-4-git-send-email-andrew@lunn.ch>
 <568AD10F.7070005@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev <netdev@vger.kernel.org>
To: Florian Fainelli <f.fainelli@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:36196 "EHLO vps0.lunn.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752388AbcAENkf (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 5 Jan 2016 08:40:35 -0500
Content-Disposition: inline
In-Reply-To: <568AD10F.7070005@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jan 04, 2016 at 12:07:43PM -0800, Florian Fainelli wrote:
> On 04/01/16 09:36, Andrew Lunn wrote:
> > Since we have a phydev, make use of it and the phy_read() function.
> > This will help with later refactoring.
> > 
> > Signed-off-by: Andrew Lunn <andrew@lunn.ch>
> > ---
> 
> [snip]
> 
> 
> > diff --git a/drivers/net/phy/phy.c b/drivers/net/phy/phy.c
> > index 47cd306dbb3c..67a77956ae6f 100644
> > --- a/drivers/net/phy/phy.c
> > +++ b/drivers/net/phy/phy.c
> > @@ -407,8 +407,7 @@ int phy_mii_ioctl(struct phy_device *phydev, struct ifreq *ifr, int cmd)
> >  		/* fall through */
> >  
> >  	case SIOCGMIIREG:
> > -		mii_data->val_out = mdiobus_read(phydev->bus, mii_data->phy_id,
> > -						 mii_data->reg_num);
> > +		mii_data->val_out = phy_read(phydev, mii_data->reg_num);
> >  		return 0;
> 
> Do we have any guarantee that users of this interface do a prior
> SIOCGMIIPHY ioctl() to select the PHY address? If not, then this change
> forces it. Arguably, you are current allowed to issue MII reads/writes
> using a PHY device that can be different from the intent, that does not
> sound like a robust interface...

This and the following hunk are wrong, and i will drop them. You are
supposed to be able to read/write any address on the bus, and i
removed this ability.

Thanks for pointing this out.

       Andrew
