From: Russell King - ARM Linux <linux@arm.linux.org.uk>
Subject: Re: [PATCH v3 0/9] Phy, mdiobus, and netdev struct device fixes
Date: Fri, 25 Sep 2015 00:12:21 +0100
Message-ID: <20150924231221.GI21513@n2100.arm.linux.org.uk>
References: <20150924215731.GE20825@lunn.ch>
 <20150924.151554.619662567057050978.davem@davemloft.net>
 <20150924222654.GG20825@lunn.ch>
 <20150924.155137.1429397912516096627.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: andrew@lunn.ch, f.fainelli@gmail.com,
	thomas.petazzoni@free-electrons.com, devicetree@vger.kernel.org,
	sgoutham@cavium.com, rric@kernel.org, frowand.list@gmail.com,
	linuxppc-dev@lists.ozlabs.org, linux-kernel@vger.kernel.org,
	robh+dt@kernel.org, michal.simek@xilinx.com,
	netdev@vger.kernel.org, soren.brinkmann@xilinx.com,
	isubramanian@apm.com, grant.likely@linaro.org, leoli@freescale.com,
	kchudgar@apm.com, linux-arm-kernel@lists.infradead.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from pandora.arm.linux.org.uk ([78.32.30.218]:45454 "EHLO
	pandora.arm.linux.org.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753445AbbIXXMj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 24 Sep 2015 19:12:39 -0400
Content-Disposition: inline
In-Reply-To: <20150924.155137.1429397912516096627.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Sep 24, 2015 at 03:51:37PM -0700, David Miller wrote:
> From: Andrew Lunn <andrew@lunn.ch>
> Date: Fri, 25 Sep 2015 00:26:54 +0200
> 
> > On Thu, Sep 24, 2015 at 03:15:54PM -0700, David Miller wrote:
> >> From: Andrew Lunn <andrew@lunn.ch>
> >> Date: Thu, 24 Sep 2015 23:57:31 +0200
> >> 
> >> > I built the FEC driver as a module, and it won't unload:
> >> > 
> >> >  kernel:unregister_netdevice: waiting for eth1 to become free. Usage count = 1
> >> > unregister_netdevice: waiting for eth1 to become free. Usage count = 1
> >> > 
> >> > i assume because DSA holds a reference. I've not tried a fully module
> >> > build, DSA has issues with that.
> >> > 
> >> > Tested-by: Andrew Lunn <andrew@lunn.ch>
> >> 
> >> So, is this a regression?
> > 
> > Sorry, worded that badly. Since DSA is still active, it should not be
> > possible to unload the FEC driver. DSA should have a reference to it,
> > and mdio-mux also should have a reference to the mdio bus of the FEC
> > driver.
> > 
> > As Russell requested, i will re-test without his patches, just to make
> > sure.
> 
> Something needs to hold into the underlying device refcount of a DSA
> blob so that an unload can't even be attempted in that state.

Holding a reference on a struct device does _not_ stop the device
being unbound or the module driving it being removed.  It merely
stops the struct device from being freed before all references have
been dropped.

Devices are always free to be unbound from their bound drivers
irrespective of the struct device refcount.  Even taking a reference
on the module (via try_module_get()) does not stop this.

-- 
FTTC broadband for 0.8mile line: currently at 9.6Mbps down 400kbps up
according to speedtest.net.
