From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/7] phy: fix of_mdio_find_bus() device refcount leak
Date: Mon, 21 Sep 2015 12:01:59 -0700 (PDT)
Message-ID: <20150921.120159.326170798236851436.davem@davemloft.net>
References: <20150918094625.GB21084@n2100.arm.linux.org.uk>
	<E1ZcsNb-0001Bf-U5@rmk-PC.arm.linux.org.uk>
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
To: rmk+kernel@arm.linux.org.uk
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:54472 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932164AbbIUTCB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 Sep 2015 15:02:01 -0400
In-Reply-To: <E1ZcsNb-0001Bf-U5@rmk-PC.arm.linux.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Russell King <rmk+kernel@arm.linux.org.uk>
Date: Fri, 18 Sep 2015 10:54:55 +0100

> Update the comment, and arrange for the only user of this function
> to drop this refcount when disposing of a reference to it.

mdio_mux is not the only user of of_mdio_find_bus(), DSA uses it as
well.

So if anything this commit message is inaccurate.

I also wonder about this refcounting scheme.

If you are going to drop the inner device reference, then we take the
mdio bus returned from of_mdio_find_bus() what holds onto it and keeps
it from disappearing on us?

Don't we have to hold onto some reference count of some kind here?
