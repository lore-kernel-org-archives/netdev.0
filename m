From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: Re: [PATCH net-next] net: dsa: mv88e6xxx: assert SMI lock
Date: Fri, 30 Oct 2015 17:11:31 -0400
Message-ID: <20151030211130.GA4682@ketchup.mtl.sfl>
References: <1446237342-5109-1-git-send-email-vivien.didelot@savoirfairelinux.com>
 <20151030204110.GB10053@lunn.ch>
 <20151030205048.GA6658@ketchup.mtl.sfl>
 <20151030210146.GD10053@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	kernel@savoirfairelinux.com,
	"David S. Miller" <davem@davemloft.net>,
	Florian Fainelli <f.fainelli@gmail.com>,
	Guenter Roeck <linux@roeck-us.net>,
	Neil Armstrong <narmstrong@baylibre.com>
To: Andrew Lunn <andrew@lunn.ch>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20151030210146.GD10053@lunn.ch>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Oct. Friday 30 (44) 10:01 PM, Andrew Lunn wrote:
> > > >  static int _mv88e6xxx_reg_read(struct dsa_switch *ds, int addr, int reg)
> > > >  {
> > > > -	struct mii_bus *bus = dsa_host_dev_to_mii_bus(ds->master_dev);
> > > > +	struct mii_bus *bus;
> > > >  	int ret;
> > > >  
> > > > +	assert_smi_lock(ds);
> > > > +
> > > > +	bus = dsa_host_dev_to_mii_bus(ds->master_dev);
> > > 
> > > Is this change of when bus is assigned actually required?
> > 
> > No, but I found not necessary to issue this "mdio_bus" lookup if the
> > lock is not held (see net/dsa/dsa.c:555). Do you prefer not to do that?
> 
> You are optimising for an error condition. If this optimisation saves
> anything, it means we have a locking bug!

Very good point, I'll get rid of that then.

> As a separate patch, i would do this lookup once in a setup function
> and save it away in ps. We just need to watch out for the probe
> register accesses.

Yes, I already put that on a todo list ;-)

> > Also are you OK with removing all the "Must be called with..." comments,
> 
> Yes, it will become a lot more clear when the kernel outputs a stack dump!

Good, sending a v2 right away then.

Thanks,
-v
