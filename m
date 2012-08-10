From: Arnd Bergmann <arnd@arndb.de>
Subject: Re: [PATCH v3 0/7] mv643xx.c: Add basic device tree support.
Date: Fri, 10 Aug 2012 10:49:57 +0000
Message-ID: <201208101049.57586.arnd@arndb.de>
References: <1344350092-24050-1-git-send-email-ian.molton@codethink.co.uk> <201208091143.32972.arnd@arndb.de> <5023D577.8090001@codethink.co.uk>
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
Received: from moutng.kundenserver.de ([212.227.126.171]:62427 "EHLO
	moutng.kundenserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755209Ab2HJKuP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 10 Aug 2012 06:50:15 -0400
In-Reply-To: <5023D577.8090001@codethink.co.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thursday 09 August 2012, Ian Molton wrote:
> >  I think showing one
> > parent device with children at address 0, 1 and 2 is ok.
> Is it acceptable for the child devices to directly access the
> parents register space? because there would be no other
> way for that to work.

Yes, I see no problem with that. As long as all the drivers
agree on who can access what.

> >  The driver
> > already knows all those offsets and they are always the same
> > for all variants of mv643xx, right?
> Yes, but its not clean. And no amount of refactoring is
> really going to make a nice driver that also fits the ancient
> (and badly thought out) OF bindings.

In what way is it badly though out, or not clean? The use of
underscores in the properties, and the way that the sram
is configured is problematic, I agree. But The way that
the three ports are addressed and how the PHY is found
seems quite clever.

> If we have to break things, we can at least go for a nice
> clean design, surely?
> 
> The ports arent really child devices of the MAC. The MAC
> just has 3 ports.

I don't see the difference between those two things.

> Luckily, it looks like the existing users don't actually use
> the device tree to set up the driver at all, preferring to
> translate their D-T bindings to calls to
> platform_device_register() so all we'd need to do to
> support them is completely ignore them.
> 
> We're going to have to maintain a legacy
> platform_device -> DT bindings hack somewhere anyway,
> at least until the remaining other users of the driver
> convert to D-T.

I don't understand why you describe the method used in
powerpc as a hack. It was the normal way to introduce
DT support for platform devices back when it was implemented.
It also had the advantage of not requiring any modifications
to the generic driver, because it was shared between one
architecture using DT (powerpc) and one that didn't (ARM).

	Arnd
