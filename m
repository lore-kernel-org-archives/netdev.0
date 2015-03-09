From: Russell King - ARM Linux <linux@arm.linux.org.uk>
Subject: Re: [PATCH] net: smc91x: improve neponset hack
Date: Mon, 9 Mar 2015 12:20:12 +0000
Message-ID: <20150309122012.GJ8656@n2100.arm.linux.org.uk>
References: <5763365.j5Nvv4LgM3@wuerfel>
 <20150219003549.GY8656@n2100.arm.linux.org.uk>
 <5754481.gFE9BvLjh0@wuerfel>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-arm-kernel@lists.infradead.org,
	Dmitry Eremin-Solenikov <dbaryshkov@gmail.com>,
	netdev@vger.kernel.org, Linus Walleij <linus.walleij@linaro.org>,
	linux-kernel@vger.kernel.org, davem@davemloft.net
To: Arnd Bergmann <arnd@arndb.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from pandora.arm.linux.org.uk ([78.32.30.218]:60658 "EHLO
	pandora.arm.linux.org.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751231AbbCIMU1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 9 Mar 2015 08:20:27 -0400
Content-Disposition: inline
In-Reply-To: <5754481.gFE9BvLjh0@wuerfel>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Feb 20, 2015 at 04:47:06PM +0100, Arnd Bergmann wrote:
> On Thursday 19 February 2015 00:35:49 Russell King - ARM Linux wrote:
> > On Wed, Feb 18, 2015 at 08:47:30PM +0100, Arnd Bergmann wrote:
> > > The smc91x driver tries to support multiple platforms at compile
> > > time, but they are mutually exclusive at runtime, and not clearly
> > > defined.
> > 
> > I'd prefer to rework this to fix that properly.  From what I remember,
> > the whole SA11x0 stuff in this driver was a mess.
> 
> I guess that's reasonable. I've looked through the driver and it seems we
> did most of the multiplatform work but left a few things alone that should
> have been converted a long time ago.
> 
> Can you check if the approach below makes sense to you?

I don't know who's carrying what patches, but this is still broken.

arch/arm/mach-sa1100/neponset.c: In function 'neponset_probe':
arch/arm/mach-sa1100/neponset.c:271:12: error: 'smc91c_platdata' undeclared (first use in this function)
drivers/net/ethernet/smsc/smc91x.c: In function 'smc_drv_probe':
drivers/net/ethernet/smsc/smc91x.c:2363:2: error: implicit declaration of function 'machine_has_neponset' [-Werror=implicit-function-declaration]

This is from building Linus' tree as of Saturday plus arm-soc.

Let's revert all this crap and start again, this time testing it better?

-- 
FTTC broadband for 0.8mile line: currently at 10.5Mbps down 400kbps up
according to speedtest.net.
