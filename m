From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH] net: mdio-gpio: Allow for unspecified bus id
Date: Fri, 8 May 2015 18:46:47 +0200
Message-ID: <20150508164647.GK18496@lunn.ch>
References: <1431094729-21775-1-git-send-email-bert@biot.com>
 <20150508154816.GJ18496@lunn.ch>
 <554CDDD2.6050104@biot.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: f.fainelli@gmail.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Bert Vermeulen <bert@biot.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <554CDDD2.6050104@biot.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> >> -	snprintf(new_bus->id, MII_BUS_ID_SIZE, "gpio-%x", bus_id);
> >> +	if (bus_id != -1)
> >> +		snprintf(new_bus->id, MII_BUS_ID_SIZE, "gpio-%x", bus_id);
> >> +	else
> >> +		strncpy(new_bus->id, "gpio", MII_BUS_ID_SIZE);
> > 
> > Hi Bert
> > 
> > What happens if there are multiple platform_device's with -1?  You
> > should probably be using use idr_alloc().
> 
> It's an instance id per driver, not globally, and -1 specifically means it's
> the only instance. From Documentation/driver-model/platform.txt:

Ah, did not know there can only be one with -1. I've used i2c where
this does not apply when registering adaptors. It will allocate a
unique id to each added with id = -1.

       Andrew
