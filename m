From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH v3 0/9] Phy, mdiobus, and netdev struct device fixes
Date: Thu, 24 Sep 2015 23:57:31 +0200
Message-ID: <20150924215731.GE20825@lunn.ch>
References: <20150924191754.GC21513@n2100.arm.linux.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Florian Fainelli <f.fainelli@gmail.com>,
	David Miller <davem@davemloft.net>,
	Thomas Petazzoni <thomas.petazzoni@free-electrons.com>,
	devicetree@vger.kernel.org, Sunil Goutham <sgoutham@cavium.com>,
	Robert Richter <rric@kernel.org>,
	Frank Rowand <frowand.list@gmail.com>,
	linuxppc-dev@lists.ozlabs.org, linux-kernel@vger.kernel.org,
	Rob Herring <robh+dt@kernel.org>,
	Michal Simek <michal.simek@xilinx.com>, netdev@vger.kernel.org,
	Soren Brinkmann <soren.brinkmann@xilinx.com>,
	Iyappan Subramanian <isubramanian@apm.com>,
	Grant Likely <grant.likely@linaro.org>,
	Li Yang <leoli@freescale.com>,
	Keyur Chudgar <kchudgar@apm.com>,
	linux-arm-kernel@lists.infradead.org
To: Russell King - ARM Linux <linux@arm.linux.org.uk>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20150924191754.GC21513@n2100.arm.linux.org.uk>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

...

> While looking at the DSA code, I noticed we have a
> of_find_net_device_by_node(), and it looks like users of that are
> similarly buggy - it looks like net/dsa/dsa.c is the only user.  Fix
> that too.

...
 
> The mdiobus code also suffered from the same kind of leak, but thankfully
> this only happened in one place - the mdio-mux code.

Hi Russell

I tested both of these with my board. It is a Freescale Vybrid, using
the FEC ethernet driver, and i have three switches attached, using
mdio-mux to give three mdio busses.

No obvious regressions, my board boots, the switches are all present
and correct. I built the FEC driver as a module, and it won't unload:

 kernel:unregister_netdevice: waiting for eth1 to become free. Usage count = 1
unregister_netdevice: waiting for eth1 to become free. Usage count = 1

i assume because DSA holds a reference. I've not tried a fully module
build, DSA has issues with that.

Tested-by: Andrew Lunn <andrew@lunn.ch>

Thanks
	Andrew
