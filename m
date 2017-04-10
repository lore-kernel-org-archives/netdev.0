From: Juergen Borleis <jbe@pengutronix.de>
Subject: Re: [PATCH v2 2/4] net: dsa: add new DSA switch driver for the SMSC-LAN9303
Date: Mon, 10 Apr 2017 09:44:12 +0200
Message-ID: <201704100944.13165.jbe@pengutronix.de>
References: <20170407081502.30172-1-jbe@pengutronix.de> <20170407081502.30172-3-jbe@pengutronix.de> <20170407142943.GC23415@lunn.ch>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 8BIT
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        f.fainelli@gmail.com, kernel@pengutronix.de,
        vivien.didelot@savoirfairelinux.com, davem@davemloft.net
To: Andrew Lunn <andrew@lunn.ch>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170407142943.GC23415@lunn.ch>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Andrew,

On Friday 07 April 2017 16:29:43 Andrew Lunn wrote:
> > +static int lan9303_virt_phy_reg_read(struct lan9303 *chip, int regnum)
> > +{
> > +	int ret;
> > +	u32 val;
> > +
> > +	if (regnum > MII_EXPANSION) {
> > +		if (regnum == MII_LAN911X_SPECIAL_CONTROL_STATUS)
> > +			regnum = 7; /* map to LAN9303_VIRT_SPECIAL_CTRL */
> > +		else
> > +			return -EINVAL;
> > +	}
>
> What PHY ID does the virtual PHY use? The same as the LAN911X? Or 
> something different.

Something different: 0x00000000 (instead of 0x0007c0d1 the real PHYs are
using).
 
> I'm just wondering if this should be in the PHY 
> driver. But that only works if you can differentiate the virtual PHY
> from the real PHYs in the PHY driver.

For the real PHYs the driver states:

SMSC LAN911x Internal PHY dsa-0.0:01: attached PHY driver [SMSC LAN911x Internal PHY] (mii_bus:phy_addr=dsa-0.0:01, irq=-1)
SMSC LAN911x Internal PHY dsa-0.0:02: attached PHY driver [SMSC LAN911x Internal PHY] (mii_bus:phy_addr=dsa-0.0:02, irq=-1)

For the virtual PHY the driver states (MDIO emulation case):

Generic PHY 63fec000.etherne:00: attached PHY driver [Generic PHY] (mii_bus:phy_addr=63fec000.etherne:00, irq=-1)

And for the fixed-link case:

Generic PHY fixed-0:00: attached PHY driver [Generic PHY] (mii_bus:phy_addr=fixed-0:00, irq=-1)

Regards,
Juergen

-- 
Pengutronix e.K.                              | Juergen Borleis             |
Industrial Linux Solutions                    | http://www.pengutronix.de/  |
