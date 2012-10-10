From: Mark Brown <broonie@opensource.wolfsonmicro.com>
Subject: Re: [net:master 6/7] mdio-gpio.c:(.text+0x58): multiple definition
 of `of_mdiobus_register'
Date: Wed, 10 Oct 2012 10:36:10 +0900
Message-ID: <20121010013608.GA17288@opensource.wolfsonmicro.com>
References: <20121009232818.GB9331@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Fengguang Wu <fengguang.wu@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from opensource.wolfsonmicro.com ([80.75.67.52]:57791 "EHLO
	opensource.wolfsonmicro.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755238Ab2JJBg3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 9 Oct 2012 21:36:29 -0400
Content-Disposition: inline
In-Reply-To: <20121009232818.GB9331@localhost>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Oct 10, 2012 at 07:28:18AM +0800, Fengguang Wu wrote:
> Hi Mark,
> 
> FYI, kernel build failed on
> 
> tree:   git://git.kernel.org/pub/scm/linux/kernel/git/davem/net.git master
> head:   5175a5e76bbdf20a614fb47ce7a38f0f39e70226
> commit: 4085a7f0a09c73ef3e9de113c9f04d78c79be645 [6/7] netdev/phy: Prototype of_mdio_find_bus()
> config: i386-allyesconfig
> 
> All error/warnings:
> 
> drivers/net/phy/mdio-gpio.o: In function `of_mdiobus_register':
> mdio-gpio.c:(.text+0x58): multiple definition of `of_mdiobus_register'
> drivers/net/phy/libphy.o:(.text+0x23d7): first defined here
> drivers/net/phy/mdio-gpio.o: In function `of_phy_find_device':

Hrm, I can't see how that would occur due to this patch unless
!CONFIG_OF is selected which I wouldn't expect from allyesconfig, the
!CONFIG_OF stubs in the header are buggy as they aren't static.  There
is a bug there, though - I'll send a patch for that.
