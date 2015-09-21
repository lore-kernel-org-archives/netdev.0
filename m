From: David Miller <davem@redhat.com>
Subject: Re: [PATCH 1/7] phy: fix of_mdio_find_bus() device refcount leak
Date: Mon, 21 Sep 2015 15:08:27 -0700 (PDT)
Message-ID: <20150921.150827.116958889622345434.davem@redhat.com>
References: <E1ZcsNb-0001Bf-U5@rmk-PC.arm.linux.org.uk>
	<20150921.120159.326170798236851436.davem@davemloft.net>
	<20150921193206.GU21084@n2100.arm.linux.org.uk>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: f.fainelli@gmail.com, devicetree@vger.kernel.org,
	frowand.list@gmail.com, grant.likely@linaro.org,
	isubramanian@apm.com, kchudgar@apm.com,
	linux-arm-kernel@lists.infradead.org,
	linuxppc-dev@lists.ozlabs.org, leoli@freescale.com,
	michal.simek@xilinx.com, netdev@vger.kernel.org, rric@kernel.org,
	robh+dt@kernel.org, soren.brinkmann@xilinx.com,
	sgoutham@cavium.com, thomas.petazzoni@free-electrons.com,
	linux-kernel@vger.kernel.org
To: linux@arm.linux.org.uk
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20150921193206.GU21084@n2100.arm.linux.org.uk>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Russell King - ARM Linux <linux@arm.linux.org.uk>
Date: Mon, 21 Sep 2015 20:32:07 +0100

> In the case of the mdio mux code, I'm dropping the reference when
> either (a) we've encountered an error during initialisation and
> we're cleaning up, or (b) when the mdio mux code is being torn down
> after the mdiomux bus has been unregistered and freed.  In both
> cases, we're done with the mdio bus that was returned from
> of_mdio_find_bus().
> 
> In case (a), the devres code will release the kmalloc'd memory when
> mdio_mux_gpio_probe() or mdio_mux_mmioreg_probe() propagates the error
> out of their probe() function.
> 
> I'm not sure why you think anything is wrong here - maybe it's the odd
> code structure to the success path at the bottom of mdio_mux_init()?

Ok I may have misread your change.  I'll restudy it when you respin
the series with the commit message fixed and the DSA change added.

Thanks.
