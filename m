From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] [v2] netdev/phy: add MDIO bus multiplexer driven by a
 memory-mapped device
Date: Fri, 24 Aug 2012 15:07:40 -0400 (EDT)
Message-ID: <20120824.150740.9047511945034908.davem@davemloft.net>
References: <5037C815.4020906@wwwdotorg.org>
	<5037C9AF.3060903@freescale.com>
	<5037CE45.4010309@wwwdotorg.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: timur@freescale.com, afleming@freescale.com, ddaney.cavm@gmail.com,
	netdev@vger.kernel.org, devicetree-discuss@lists.ozlabs.org,
	scottwood@freescale.com
To: swarren@wwwdotorg.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:55585 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752223Ab2HXTHm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 24 Aug 2012 15:07:42 -0400
In-Reply-To: <5037CE45.4010309@wwwdotorg.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stephen Warren <swarren@wwwdotorg.org>
Date: Fri, 24 Aug 2012 12:56:05 -0600

> In the I2C case, the address spaces are disjoint, so there's never any
> mapping between them, so there's no need for ranges.
> 
> Any time the child address space is intended to be part of the parent's
> address space, I believe ranges is supposed to be specified, perhaps
> even mandatory, even if the translation is 1:1.

Regardless, you really can't just generically translate ranges
in some universal way and expect it to work in all cases.

You need bus specific drivers to deal with various special
cases.

See the *_map() methods implemented in:

	arch/sparc/kernel/of_device_64.c

for example.
