From: Arnd Bergmann <arnd@arndb.de>
Subject: Re: [PATCH v3 0/7] mv643xx.c: Add basic device tree support.
Date: Fri, 17 Aug 2012 12:13:08 +0000
Message-ID: <201208171213.09160.arnd@arndb.de>
References: <1344350092-24050-1-git-send-email-ian.molton@codethink.co.uk> <201208101049.57586.arnd@arndb.de> <5028D040.60604@codethink.co.uk>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: linux-arm-kernel@lists.infradead.org,
	thomas.petazzoni@free-electrons.com, andrew@lunn.ch,
	netdev@vger.kernel.org, devicetree-discuss@lists.ozlabs.org,
	ben.dooks@codethink.co.uk, dale@farnsworth.org,
	linuxppc-dev@lists.ozlabs.org, David Miller <davem@davemloft.net>
To: Ian Molton <ian.molton@codethink.co.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from moutng.kundenserver.de ([212.227.17.10]:60689 "EHLO
	moutng.kundenserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753905Ab2HQMNU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 17 Aug 2012 08:13:20 -0400
In-Reply-To: <5028D040.60604@codethink.co.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Monday 13 August 2012, Ian Molton wrote:
> On 10/08/12 11:49, Arnd Bergmann wrote:
> > On Thursday 09 August 2012, Ian Molton wrote:
> >>>  The driver
> >>> already knows all those offsets and they are always the same
> >>> for all variants of mv643xx, right?
> >> Yes, but its not clean. And no amount of refactoring is
> >> really going to make a nice driver that also fits the ancient
> >> (and badly thought out) OF bindings.
> > In what way is it badly though out, or not clean? The use of
> > underscores in the properties, and the way that the sram
> > is configured is problematic, I agree. But The way that
> > the three ports are addressed and how the PHY is found
> > seems quite clever.
> 
> It forces one to load the MDIO driver first, because it maps ALL the
> registers for both itself and all the ports, and the MDIO driver has no
> way of knowing how many ethernet blocks are present (I have a device
> here with two, and another with four). Thats anywhere from 1 to 12
> ports, split across 1 to 4 address ranges, and theres a big gap in the
> address range between controllers 0,1 and 2,3. *ALL* the devices on the
> board are sharing ethernet block 0's MDIO bus. By pure luck it happens
> to work, because the blocks 2,3 have an alias of the MDIO registers from
> blocks 0,1.
> 
> Having the MDIO driver map the ethernet drivers memory is a terrible
> solution, IMO. Ethernet drivers should map their own memory, and that
> introduces the n-ports-per-block problem, because their address ranges
> overlap.
> 
> I think the best solution is to make each ethernet block register 3 ports.
> 
> the PPC code can simply generate different fixups so that instead of
> creating 3 devices, it creates one, with three ports.

Ok.

> Can we get some consensus on the right approach here? I'm loathe to code
> this if its going to be rejected.
> 
> I'd prefer the driver to be properly split so we dont have the MDIO
> driver mapping the ethernet drivers address spaces, but if thats not
> going to be merged, I'm not feeling like doing the work for nothing.
> 
> If the driver is to use the overlapping-address mapped-by-the-mdio
> scheme, then so be it, but I could do with knowing.
> 
> Another point against the latter scheme is that the MDIO driver could
> sensibly be used (the block is identical) on the ArmadaXP, which has 4
> ethernet blocks rather than two, yet grouped in two pairs with a
> discontiguous address range.
> 
> I'd like to get this moved along as soon as possible though.

I don't object to any device driver changes, but I do want to make
sure that the bindings are sensible and can coexist with the
ones that have been used for the past 5 years.

Maybe you can move the binding for the ethernet parts out of the
marvell.txt file into the place you want to use for the new
bindings and then extend it to cover both the old and the new style.

	Arnd
