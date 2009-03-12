From: Sascha Hauer <s.hauer@pengutronix.de>
Subject: Re: [PATCH] dnet: Dave DNET ethernet controller driver
Date: Thu, 12 Mar 2009 15:34:07 +0100
Message-ID: <20090312143407.GP425@pengutronix.de>
References: <49B82566.3070909@weinigel.se> <20090311171354.04c7a63d@nehalam> <49B8E6D4.2030702@weinigel.se> <20090312.055523.193191701.davem@davemloft.net> <49B91A7B.7050303@weinigel.se>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, shemminger@vyatta.com,
	yanok@emcraft.com, linux-arm-kernel@lists.arm.linux.org.uk,
	netdev@vger.kernel.org, wd@denx.de, dzu@denx.de
To: Christer Weinigel <christer@weinigel.se>
Return-path: <netdev-owner@vger.kernel.org>
Received: from metis.ext.pengutronix.de ([92.198.50.35]:37661 "EHLO
	metis.ext.pengutronix.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756819AbZCLOeY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 Mar 2009 10:34:24 -0400
Content-Disposition: inline
In-Reply-To: <49B91A7B.7050303@weinigel.se>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Mar 12, 2009 at 03:21:47PM +0100, Christer Weinigel wrote:
> David Miller wrote:
>> From: Christer Weinigel <christer@weinigel.se>
>> Date: Thu, 12 Mar 2009 11:41:24 +0100
>>
>>> 1. The bootloader can pass a command line to the kernel and it is saved in non-volatile storage that can be changed from the bootloader
>>>
>>> 2. I can not modify the bootloader
>>>
>>> 3. I can modify the Linux kernel
>>>
>>> 4. The manufacturer has hardcoded a MAC address in the ethernet driver
>>>
>>> 5. I want to use NFS root to make it easy to develop on the platform
>>>
>>> 6. We get a second board so the hardcoded MAC addresses collide
>>
>> This is getting rediculious.
>
> Yes, ridiculous in the complexity of the workarounds for not having a  
> generic way to set the mac address from the command line.  :-/
>
>> If you can modify the kernel, you can have the kernel look in the
>> non-volatile storage for the MAC address and export that information
>> to the ethernet driver.
>
> Which means that the non-volatile storage must be available through a  
> Linux driver before the MAC address is set.  AFAIK there is no guarantee  
> that the MTD layer will be ready to use by that time.  And that is  
> assuming that there actually is a MTD driver available, usually when I  
> work on a Linux port for a reference board, the first thing I do is to  
> get a NFS root up and running, then I can put a have a complete Debian  
> system with all nice debugging tools available.  When I have that up and  
> running I start porting the other drivers, such as the MTD driver.
>
> Also, I don't really want to spend time on reverse engineering some  
> random non-volatile storage format, that's quite fragile.
>
>> Or, you can parse the command line in your platform specific code
>> and program the MAC address into the chip.
>
> Which is actually what I'm doing, except that it's easier to hack that  
> into the ethernet driver each time it is needed.
>
>> In fact there are many reasonable ways to solve the problem in
>> your scenerio, and none of them require device driver command
>> line option handler.
>
> Yes, that why I'd want that in a generic piece of code instead of having  
> to hack it into each device driver.  Would a generic command line  
> option, something like "ethaddrs=eth0=00:de:ad:be:ef:01" which assigns  
> addresses to network cards be acceptable?

Unfortunately it isn't this simple because network device names are not
stable (i.e. eth0 can become eth1 when you plug another network card)
Someone has already mentioned this and I think this is the real problem
why we still don't have such a mechanism.

Sascha


-- 
Pengutronix e.K.                           |                             |
Industrial Linux Solutions                 | http://www.pengutronix.de/  |
Peiner Str. 6-8, 31137 Hildesheim, Germany | Phone: +49-5121-206917-0    |
Amtsgericht Hildesheim, HRA 2686           | Fax:   +49-5121-206917-5555 |
