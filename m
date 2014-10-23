From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH 06/14] net: dsa: Add support for hardware monitoring
Date: Thu, 23 Oct 2014 21:55:26 +0200
Message-ID: <20141023195526.GH25190@lunn.ch>
References: <1414037002-25528-1-git-send-email-linux@roeck-us.net>
 <1414037002-25528-7-git-send-email-linux@roeck-us.net>
 <CAGVrzcYjPJWai9bxkh+WRrEEAzBKBd-LQm7zDeeouxngr_v9SQ@mail.gmail.com>
 <54488CE1.2000106@roeck-us.net>
 <20141023134706.GB25190@lunn.ch>
 <20141023162754.GA21343@roeck-us.net>
 <20141023165459.GE25190@lunn.ch>
 <20141023173847.GA22988@roeck-us.net>
 <20141023180357.GG25190@lunn.ch>
 <20141023184322.GA24281@roeck-us.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Andrew Lunn <andrew@lunn.ch>,
	Florian Fainelli <f.fainelli@gmail.com>,
	netdev <netdev@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: Guenter Roeck <linux@roeck-us.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20141023184322.GA24281@roeck-us.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Oct 23, 2014 at 11:43:22AM -0700, Guenter Roeck wrote:
> On Thu, Oct 23, 2014 at 08:03:57PM +0200, Andrew Lunn wrote:
> > > No, I am not saying that. The hwmon device's parent device will tell,
> > > which is how it works for all other hwmon devices.
> > 
> > O.K, so parent is important.
> > 
> > > Not really. Again, the parent device provides that information. libsensors,
> > > which is the preferred way of accessing sensors information from user space,
> > > provides the parent device instance as part of the logical sensor device
> > > name. In this case, the names will end up being dsa-isa-0000, dsa-isa-0001,
> > > and so on. With your added tags it would be dsa.0.0-isa-0000, dsa.0.1-isa-0001,
> > > and so on. I don't see how this would add any value.
> > 
> > isa is the name of the ethernet device? Why is it not eth0? Most
> 
> isa is just an internal name made up by libsensors, and pretty much just
> indicates something like "neither i2c nor spi". It is mostly historic,
> but nowadays almost part of the ABI. It is made up by user space,
> based on the parent device type, not by the kernel.

So for DSA, since it is not i2c or spi, the parent is actually
irrelevant, because libsensor ignores it and says "IsSomethingAlien".
So the name alone needs to identify it.

 > You have convinced me that 'dsa' as hwmon attribute name is insufficient,
> so let's see what we have.
> 
> - the parent network device in dst->master_netdev
> - the dsa device in 'parent'
> - the host device in host_dev
> - the switch index in 'index'
> 
> First question is what should be the parent device.

Does it even matter, given the observation above?  I would probably go
for dsa, since as you said, the Ethernet device may have a temperature
sensor of its own. DSA is a virtual device...

> Second is what to choose for the hwmon device 'name' attribute.
> 'dsa' is not sufficient, but what to choose instead ? dsa.X or dsa_X,
> where X is the switch index ? At this point I am open to suggestions.
> Note that we can not use the name returned from the switch probe
> functions as it may contain spaces and other invalid characters.
> Including the ethernet device name (eg as in eth0_dsa_0) may also be
> problematic if it can contain '-', which is illegal for hwmon devices.

Does hwmon offer a function to sanitise a string?

The switch index definitely should be used and i would probably
combine that with a sanitised version of the ethernet device name and
"dsa".

	Andrew
