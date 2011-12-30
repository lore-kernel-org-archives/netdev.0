From: Andy Fleming <afleming@freescale.com>
Subject: Re: Allocation of MDIO bus numbers when fixed MDIO bus is enabled?
Date: Thu, 29 Dec 2011 21:52:26 -0600
Message-ID: <A4772B50-0705-49EE-AE6D-BCF546C426A7@freescale.com>
References: <4EFC90C8.1060802@openwrt.org> <20111229191011.GA19220@oksana.dev.rtsoft.ru>
Mime-Version: 1.0 (Apple Message framework v1251.1)
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: Florian Fainelli <florian@openwrt.org>, <netdev@vger.kernel.org>
To: Anton Vorontsov <anton.vorontsov@linaro.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from db3ehsobe003.messaging.microsoft.com ([213.199.154.141]:24683
	"EHLO DB3EHSOBE003.bigfish.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754995Ab1L3DyD convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 29 Dec 2011 22:54:03 -0500
In-Reply-To: <20111229191011.GA19220@oksana.dev.rtsoft.ru>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On Dec 29, 2011, at 1:10 PM, Anton Vorontsov wrote:

> Hello,
> 
> On Thu, Dec 29, 2011 at 05:09:44PM +0100, Florian Fainelli wrote:
>> An user of the r6040 driver has enabled support for the Fixed MDIO
>> bus, so when the r6040 registers with its first instance, it will
>> also try to register a MDIO bus with id 0, and this fails.
>> 
>> What's the proper solution to fixing this kind of issue? The same
>> user proposed to use the pci slot and function as an id for
>> registering the MDIO bus, which will work for PCI devices, but not
>> for platform_devices for instance.
> 
> AFAIR, MDIO bus id doesn't have to be numeric, so you can change it
> to parent's dev_name(). I.e. something like
> 
> snprintf(fmb->mii_bus->id, MII_BUS_ID_SIZE, "%s-mdio", dev_name(dev));
> 
> So, the resulting PHYs would have IDs something like "dev-mdio:1".


Yeah, there's a long-standing issue from when the "fixed" bus was created. I wasn't really involved in the architecture, and the arbitrary "0" bus stuck around. I think renaming it is not as trivial as it sounds, in that the bus id is hard-coded in a number of places. However, I would eagerly endorse any solution that was less hard-coded. You would have to change all of the fixed-phy clients. At the very least, it should be called "fixed-0", or something.

However, the issue is that the r6040's bus registration is being just as bad a citizen as the fixed bus registration. Please change it to have a sensible bus name. You can craft whatever name you like. Make it something that follows a convention that shouldn't ever conflict with anything else, while also being trivially deducible from available information (so the ethernet driver can find the right bus for the right instance). The names are global for the whole system.

Andy
