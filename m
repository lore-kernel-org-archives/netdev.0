From: Guenter Roeck <linux@roeck-us.net>
Subject: Re: [PATCH 06/14] net: dsa: Add support for hardware monitoring
Date: Fri, 24 Oct 2014 09:19:19 -0700
Message-ID: <20141024161919.GA29600@roeck-us.net>
References: <1414037002-25528-7-git-send-email-linux@roeck-us.net>
 <CAGVrzcYjPJWai9bxkh+WRrEEAzBKBd-LQm7zDeeouxngr_v9SQ@mail.gmail.com>
 <54488CE1.2000106@roeck-us.net>
 <20141023134706.GB25190@lunn.ch>
 <20141023162754.GA21343@roeck-us.net>
 <20141023165459.GE25190@lunn.ch>
 <20141023173847.GA22988@roeck-us.net>
 <20141023180357.GG25190@lunn.ch>
 <20141023184322.GA24281@roeck-us.net>
 <20141023195526.GH25190@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Florian Fainelli <f.fainelli@gmail.com>,
	netdev <netdev@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: Andrew Lunn <andrew@lunn.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from bh-25.webhostbox.net ([208.91.199.152]:48739 "EHLO
	bh-25.webhostbox.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932247AbaJXQTb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 24 Oct 2014 12:19:31 -0400
Received: from mailnull by bh-25.webhostbox.net with sa-checked (Exim 4.82)
	(envelope-from <linux@roeck-us.net>)
	id 1XhhaM-002iRD-Hc
	for netdev@vger.kernel.org; Fri, 24 Oct 2014 16:19:30 +0000
Content-Disposition: inline
In-Reply-To: <20141023195526.GH25190@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Oct 23, 2014 at 09:55:26PM +0200, Andrew Lunn wrote:
> On Thu, Oct 23, 2014 at 11:43:22AM -0700, Guenter Roeck wrote:
> > On Thu, Oct 23, 2014 at 08:03:57PM +0200, Andrew Lunn wrote:
> > > > No, I am not saying that. The hwmon device's parent device will=
 tell,
> > > > which is how it works for all other hwmon devices.
> > >=20
> > > O.K, so parent is important.
> > >=20
> > > > Not really. Again, the parent device provides that information.=
 libsensors,
> > > > which is the preferred way of accessing sensors information fro=
m user space,
> > > > provides the parent device instance as part of the logical sens=
or device
> > > > name. In this case, the names will end up being dsa-isa-0000, d=
sa-isa-0001,
> > > > and so on. With your added tags it would be dsa.0.0-isa-0000, d=
sa.0.1-isa-0001,
> > > > and so on. I don't see how this would add any value.
> > >=20
> > > isa is the name of the ethernet device? Why is it not eth0? Most
> >=20
> > isa is just an internal name made up by libsensors, and pretty much=
 just
> > indicates something like "neither i2c nor spi". It is mostly histor=
ic,
> > but nowadays almost part of the ABI. It is made up by user space,
> > based on the parent device type, not by the kernel.
>=20
> So for DSA, since it is not i2c or spi, the parent is actually
> irrelevant, because libsensor ignores it and says "IsSomethingAlien".
> So the name alone needs to identify it.
>=20
>  > You have convinced me that 'dsa' as hwmon attribute name is insuff=
icient,
> > so let's see what we have.
> >=20
> > - the parent network device in dst->master_netdev
> > - the dsa device in 'parent'
> > - the host device in host_dev
> > - the switch index in 'index'
> >=20
> > First question is what should be the parent device.
>=20
> Does it even matter, given the observation above?  I would probably g=
o
> for dsa, since as you said, the Ethernet device may have a temperatur=
e
> sensor of its own. DSA is a virtual device...
>=20
> > Second is what to choose for the hwmon device 'name' attribute.
> > 'dsa' is not sufficient, but what to choose instead ? dsa.X or dsa_=
X,
> > where X is the switch index ? At this point I am open to suggestion=
s.
> > Note that we can not use the name returned from the switch probe
> > functions as it may contain spaces and other invalid characters.
> > Including the ethernet device name (eg as in eth0_dsa_0) may also b=
e
> > problematic if it can contain '-', which is illegal for hwmon devic=
es.
>=20
> Does hwmon offer a function to sanitise a string?
>=20
> The switch index definitely should be used and i would probably
> combine that with a sanitised version of the ethernet device name and
> "dsa".
>=20
Here is another naming option:

em1dsa0-virtual-0
Adapter: Virtual device
temp1:        +52.0=B0C  (high =3D +100.0=B0C)

I think I'll go with that one. I get it by not specifying
a parent device when registering with the hwmon subsystem.
It is kind of similar to the thermal sensor data reported
through acpi.

acpitz-virtual-0
Adapter: Virtual device
temp1:        +52.0=B0C  (crit =3D +111.0=B0C)
temp2:        +52.0=B0C  (crit =3D +111.0=B0C)

Guenter
