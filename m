From: Christer Weinigel <christer@weinigel.se>
Subject: Re: [PATCH] dnet: Dave DNET ethernet controller driver
Date: Thu, 12 Mar 2009 15:21:47 +0100
Message-ID: <49B91A7B.7050303@weinigel.se>
References: <49B82566.3070909@weinigel.se>	<20090311171354.04c7a63d@nehalam>	<49B8E6D4.2030702@weinigel.se> <20090312.055523.193191701.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: shemminger@vyatta.com, s.hauer@pengutronix.de, yanok@emcraft.com,
	linux-arm-kernel@lists.arm.linux.org.uk, netdev@vger.kernel.org,
	wd@denx.de, dzu@denx.de
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 2-1-3-15a.ens.sth.bostream.se ([82.182.31.214]:51155 "EHLO
	zoo.weinigel.se" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753632AbZCLOVu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 Mar 2009 10:21:50 -0400
In-Reply-To: <20090312.055523.193191701.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller wrote:
> From: Christer Weinigel <christer@weinigel.se>
> Date: Thu, 12 Mar 2009 11:41:24 +0100
> 
>> 1. The bootloader can pass a command line to the kernel and it is saved in non-volatile storage that can be changed from the bootloader
>>
>> 2. I can not modify the bootloader
>>
>> 3. I can modify the Linux kernel
>>
>> 4. The manufacturer has hardcoded a MAC address in the ethernet driver
>>
>> 5. I want to use NFS root to make it easy to develop on the platform
>>
>> 6. We get a second board so the hardcoded MAC addresses collide
> 
> This is getting rediculious.

Yes, ridiculous in the complexity of the workarounds for not having a 
generic way to set the mac address from the command line.  :-/

> If you can modify the kernel, you can have the kernel look in the
> non-volatile storage for the MAC address and export that information
> to the ethernet driver.

Which means that the non-volatile storage must be available through a 
Linux driver before the MAC address is set.  AFAIK there is no guarantee 
that the MTD layer will be ready to use by that time.  And that is 
assuming that there actually is a MTD driver available, usually when I 
work on a Linux port for a reference board, the first thing I do is to 
get a NFS root up and running, then I can put a have a complete Debian 
system with all nice debugging tools available.  When I have that up and 
running I start porting the other drivers, such as the MTD driver.

Also, I don't really want to spend time on reverse engineering some 
random non-volatile storage format, that's quite fragile.

> Or, you can parse the command line in your platform specific code
> and program the MAC address into the chip.

Which is actually what I'm doing, except that it's easier to hack that 
into the ethernet driver each time it is needed.

> In fact there are many reasonable ways to solve the problem in
> your scenerio, and none of them require device driver command
> line option handler.

Yes, that why I'd want that in a generic piece of code instead of having 
to hack it into each device driver.  Would a generic command line 
option, something like "ethaddrs=eth0=00:de:ad:be:ef:01" which assigns 
addresses to network cards be acceptable?

Next time I have to port something to an embedded platform with this 
kind of problem, I might try to do something more generic instead of the 
simple hack I usually do now.

   /Christer

