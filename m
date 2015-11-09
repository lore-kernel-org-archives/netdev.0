From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] mvneta: add FIXED_PHY dependency
Date: Mon, 09 Nov 2015 11:36:22 -0500 (EST)
Message-ID: <20151109.113622.1309064405711224118.davem@davemloft.net>
References: <4225885.EYXTHjRPmX@wuerfel>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, stsp@users.sourceforge.net,
	f.fainelli@gmail.com, thomas.petazzoni@free-electrons.com,
	linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org
To: arnd@arndb.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:34847 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752363AbbKIQgZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 9 Nov 2015 11:36:25 -0500
In-Reply-To: <4225885.EYXTHjRPmX@wuerfel>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Arnd Bergmann <arnd@arndb.de>
Date: Mon, 09 Nov 2015 15:08:57 +0100

> The fixed_phy infrastructure is done in a way that is optional,
> by providing 'static inline' helper functions doing nothing in
> include/linux/phy_fixed.h for all its APIs. However, three out
> of the four users (DSA, BCMGENET, and SYSTEMPORT) always
> 'select FIXED_PHY', presumably because they need that.
> MVNETA is the fourth one, and if that is built-in but FIXED_PHY
> is configured as a loadable module, we get a link error:
> 
> drivers/built-in.o: In function `mvneta_fixed_link_update':
> fpga-mgr.c:(.text+0x33ed80): undefined reference to `fixed_phy_update_state'
> 
> Presumably this driver has the same dependency as the others,
> so this patch also uses 'select' to ensure that the fixed-phy
> support is built-in.
> 
> Signed-off-by: Arnd Bergmann <arnd@arndb.de>
> Fixes: 898b2970e2c9 ("mvneta: implement SGMII-based in-band link state signaling")
> ---
> Found using ARM randconfig tests. An alternative here would be
> to use 'depends on FIXED_PHY || FIXED_PHY=n', I picked the 'select'
> approach for consistency.
> 
> Should we perhaps make 'FIXED_PHY' a silent option and remove the
> inline helpers, based on the assumption that a driver that wants these
> will not work without them?

This seems reasonable to fix the problem for the time being, applied.

Thanks Arnd.
