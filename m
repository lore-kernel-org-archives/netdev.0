From: Wolfgang Grandegger <wg@grandegger.com>
Subject: Re: [net-next-2.6 PATCH v2] can: SJA1000: generic OF platform bus
 driver
Date: Sat, 30 May 2009 19:59:08 +0200
Message-ID: <4A2173EC.9040107@grandegger.com>
References: <200905242327.15139.arnd@arndb.de>	<4A1A418D.3040207@grandegger.com>	<200905261010.31364.arnd@arndb.de>	<20090526.022508.238274281.davem@davemloft.net> <4A1BFB73.4020305@grandegger.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: linuxppc-dev@ozlabs.org, devicetree-discuss@ozlabs.org,
	arnd@arndb.de, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-out.m-online.net ([212.18.0.9]:33789 "EHLO
	mail-out.m-online.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752783AbZE3R7I (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 30 May 2009 13:59:08 -0400
In-Reply-To: <4A1BFB73.4020305@grandegger.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Wolfgang Grandegger wrote:
> David Miller wrote:
>> From: Arnd Bergmann <arnd@arndb.de>
>> Date: Tue, 26 May 2009 10:10:30 +0100
>>
>>> On Monday 25 May 2009, Wolfgang Grandegger wrote:
>>>>> Right, that makes sense. However, most drivers use the field to store the
>>>>> physical address, not the iomap token. Maybe there should be a new field
>>>>> in struct sja1000_priv for the virtual address, but that would be a change
>>>>> to the base driver, not just to the OF portion.
>>>> Is that common practice? If yes, I will add a member to store the
>>>> virtual address to struct sja1000_priv.
>>> I grepped through the network driver for usage of ->base_addr, and
>>> it's somewhat inconsistent. The majority of the users use it for
>>> a physical address, but there are also a few that use it for the
>>> __iomem token.
>>>
>>> Casts between unsigned long and qualified (__iomem, __user, const, ...)
>>> pointers do not cause a warning, but can easily lead to bugs when
>>> another user casts to an unqualified pointer.
>> It's such a baroque thing, there is no reason to set it at all if you
>> ask me.  It's only use is to allow ISA and similar primitive bus
>> devices to have their I/O ports changed via ifconfig.
> 
> OK, I see, there are good reasons not to (mis-)use dev->base_addr. I
> will prepare a patch for the SJA1000 CAN drivers.

I have just sent out a patch series fixing this issue and providing
a revised patch for the SJA1000 OF platform driver:

[net-next-2.6 PATCH 0/3] can: sja1000: misused netdev->base_addr and OF platform driver

Wolfgang.
