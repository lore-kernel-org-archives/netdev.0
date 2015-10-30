From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH net-next] net: dsa: mv88e6xxx: assert SMI lock
Date: Fri, 30 Oct 2015 22:01:46 +0100
Message-ID: <20151030210146.GD10053@lunn.ch>
References: <1446237342-5109-1-git-send-email-vivien.didelot@savoirfairelinux.com>
 <20151030204110.GB10053@lunn.ch>
 <20151030205048.GA6658@ketchup.mtl.sfl>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	kernel@savoirfairelinux.com,
	"David S. Miller" <davem@davemloft.net>,
	Florian Fainelli <f.fainelli@gmail.com>,
	Guenter Roeck <linux@roeck-us.net>,
	Neil Armstrong <narmstrong@baylibre.com>
To: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20151030205048.GA6658@ketchup.mtl.sfl>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> > >  static int _mv88e6xxx_reg_read(struct dsa_switch *ds, int addr, int reg)
> > >  {
> > > -	struct mii_bus *bus = dsa_host_dev_to_mii_bus(ds->master_dev);
> > > +	struct mii_bus *bus;
> > >  	int ret;
> > >  
> > > +	assert_smi_lock(ds);
> > > +
> > > +	bus = dsa_host_dev_to_mii_bus(ds->master_dev);
> > 
> > Is this change of when bus is assigned actually required?
> 
> No, but I found not necessary to issue this "mdio_bus" lookup if the
> lock is not held (see net/dsa/dsa.c:555). Do you prefer not to do that?

You are optimising for an error condition. If this optimisation saves
anything, it means we have a locking bug!

As a separate patch, i would do this lookup once in a setup function
and save it away in ps. We just need to watch out for the probe
register accesses.
 
> Also are you OK with removing all the "Must be called with..." comments,

Yes, it will become a lot more clear when the kernel outputs a stack dump!

     Andrew
