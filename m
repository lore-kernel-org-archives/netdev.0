From: Byungho An <bh74.an@samsung.com>
Subject: RE: [patch 1/3] net: sxgbe: sxgbe_mdio_register() frees the bus
Date: Tue, 01 Apr 2014 23:55:51 -0700
Message-ID: <000301cf4e40$97f14a40$c7d3dec0$@samsung.com>
References: <20140401133844.GA11536@mwanda>
 <20140401.162322.2243641448457002118.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ks.giri@samsung.com, siva.kallam@samsung.com,
	vipul.pandya@samsung.com, netdev@vger.kernel.org,
	kernel-janitors@vger.kernel.org
To: 'David Miller' <davem@davemloft.net>, dan.carpenter@oracle.com
Return-path: <kernel-janitors-owner@vger.kernel.org>
In-reply-to: <20140401.162322.2243641448457002118.davem@davemloft.net>
Content-language: en-us
Sender: kernel-janitors-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

David Miller <davem@davemloft.net> :
> From: Dan Carpenter <dan.carpenter@oracle.com>
> Date: Tue, 1 Apr 2014 16:38:44 +0300
> 
> > @@ -219,13 +219,6 @@ int sxgbe_mdio_register(struct net_device *ndev)
> >  		}
> >  	}
> >
> > -	if (!err) {
> > -		netdev_err(ndev, "PHY not found\n");
> > -		mdiobus_unregister(mdio_bus);
> > -		mdiobus_free(mdio_bus);
> > -		goto mdiobus_err;
> > -	}
> > -
> ...
> > @@ -93,9 +93,9 @@ static void sxgbe_core_set_umac_addr(void __iomem
> > *ioaddr, unsigned char *addr,  {
> >  	u32 high_word, low_word;
> >
> > -	high_word = (addr[5] << 8) || (addr[4]);
> > -	low_word = ((addr[3] << 24) || (addr[2] << 16) ||
> > -		    (addr[1] << 8) || (addr[0]));
> > +	high_word = (addr[5] << 8) | (addr[4]);
> > +	low_word = (addr[3] << 24) | (addr[2] << 16) |
> > +		   (addr[1] << 8) | (addr[0]);
> >  	writel(high_word, ioaddr + SXGBE_CORE_ADD_HIGHOFFSET(reg_n));
> >  	writel(low_word, ioaddr + SXGBE_CORE_ADD_LOWOFFSET(reg_n));  }
> 
> Nothing says "DRIVER NOT TESTED" like these two bugs.
> 
> The MDIO bus is always freed, and the MAC address is corrupted into a
> boolean value before being programmed into the hardware.
> 
> Frankly, this kind of stuff is unacceptable.
> 
> I cannot see how this driver can function successfully with these two
errors, it
> looks simply impossible.
> 
> I'm not going to hide my feelings, this was a truly terrible driver
submission.
> The amount of reviewing resources consumed during all of these iterations
was
> huge, and it still went in with bugs like this.
> 
> It probably should have gone into staging.

Oops, my apologies. mdio err path and logical and bitwise for mac address are
my mistake I didn't tested carefully (maybe tested with previous version)
because I couldn't much time to test it due to facing merge window. sorry
about that...

For logical and bitwise OR for mac address, actually I couldn't catch since
"eth_hw_addr_random" is used.. however it is also mistake.

I apology again.


