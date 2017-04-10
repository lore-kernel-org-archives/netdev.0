From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH v2 2/4] net: dsa: add new DSA switch driver for the
 SMSC-LAN9303
Date: Mon, 10 Apr 2017 15:25:46 +0200
Message-ID: <20170410132546.GB19820@lunn.ch>
References: <20170407081502.30172-1-jbe@pengutronix.de>
 <20170407081502.30172-3-jbe@pengutronix.de>
 <20170407142943.GC23415@lunn.ch>
 <201704100944.13165.jbe@pengutronix.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        f.fainelli@gmail.com, kernel@pengutronix.de,
        vivien.didelot@savoirfairelinux.com, davem@davemloft.net
To: Juergen Borleis <jbe@pengutronix.de>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <201704100944.13165.jbe@pengutronix.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Apr 10, 2017 at 09:44:12AM +0200, Juergen Borleis wrote:
> Hi Andrew,
> 
> On Friday 07 April 2017 16:29:43 Andrew Lunn wrote:
> > > +static int lan9303_virt_phy_reg_read(struct lan9303 *chip, int regnum)
> > > +{
> > > +	int ret;
> > > +	u32 val;
> > > +
> > > +	if (regnum > MII_EXPANSION) {
> > > +		if (regnum == MII_LAN911X_SPECIAL_CONTROL_STATUS)
> > > +			regnum = 7; /* map to LAN9303_VIRT_SPECIAL_CTRL */
> > > +		else
> > > +			return -EINVAL;
> > > +	}
> >
> > What PHY ID does the virtual PHY use? The same as the LAN911X? Or 
> > something different.
> 
> Something different: 0x00000000 (instead of 0x0007c0d1 the real PHYs are
> using).

Hi Juergen

0x0 does not help us. We cannot bind a specific PHY driver to that.

> For the virtual PHY the driver states (MDIO emulation case):
> 
> Generic PHY 63fec000.etherne:00: attached PHY driver [Generic PHY] (mii_bus:phy_addr=63fec000.etherne:00, irq=-1)

This is what i would expect. But i think that means the redirect of
MII_LAN911X_SPECIAL_CONTROL_STATUS to 7 is pointless. The generic PHY
only uses registers below MII_EXPANSION. So unless there is a use of
MII_LAN911X_SPECIAL_CONTROL_STATUS i don't see, you might as well
remove this.

     Andrew
