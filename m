From: Gilles Chanteperdrix <gilles.chanteperdrix@gmail.com>
Subject: Re: [PATCH] i.MX31: Fixing cs89x0 network building to i.MX31ADS
Date: Thu, 02 Apr 2009 11:23:19 +0200
Message-ID: <49D48407.5080100@gmail.com>
References: <37367b3a0903241018h7ff3302fi83cf1fcb21a3114d@mail.gmail.com>	<37367b3a0903300714g40a108d3j59a3b56ee9cda2bf@mail.gmail.com>	<20090330143155.GA20101@pengutronix.de>	<37367b3a0903301315u51787ebcl119ed295e373a1e4@mail.gmail.com>	<20090331075951.GF22913@pengutronix.de>	<37367b3a0903310636x3c8d8eban4310018c3d1b40b@mail.gmail.com>	<155d92380904010454l34c57687j67e6805dafcb92ef@mail.gmail.com> <20090402091000.GI4337@n2100.arm.linux.org.uk>
Reply-To: gilles.chanteperdrix@xenomai.org
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Sajith P V <sajithpv@gmail.com>,
	Alan Carvalho de Assis <acassis@gmail.com>,
	linux-arm-kernel@lists.arm.linux.org.uk, netdev@vger.kernel.org,
	Sascha Hauer <s.hauer@pengutronix.de>
To: Russell King - ARM Linux <linux@arm.linux.org.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 54.242.96-84.rev.gaoland.net ([84.96.242.54]:37152 "EHLO
	xenomai.org" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1757495AbZDBKFB (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 2 Apr 2009 06:05:01 -0400
In-Reply-To: <20090402091000.GI4337@n2100.arm.linux.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Russell King - ARM Linux wrote:
> On Wed, Apr 01, 2009 at 05:24:27PM +0530, Sajith P V wrote:
>> Hi Alan,
>>
>> On Tue, Mar 31, 2009 at 7:06 PM, Alan Carvalho de Assis
>> <acassis@gmail.com> wrote:
>>> This is a fix to get cs89x0 network driver working on i.MX31ADS
>>> diff --git a/drivers/net/cs89x0.c b/drivers/net/cs89x0.c
>>> index ff64976..8ccc8f7 100644
>>> --- a/drivers/net/cs89x0.c
>>> +++ b/drivers/net/cs89x0.c
>>> @@ -190,6 +190,7 @@ static unsigned int cs8900_irq_map[] =
>>> {IRQ_IXDP2X01_CS8900, 0, 0, 0};
>>>  static unsigned int netcard_portlist[] __used __initdata =
>>> {CIRRUS_DEFAULT_BASE, 0};
>>>  static unsigned int cs8900_irq_map[] = {CIRRUS_DEFAULT_IRQ, 0, 0, 0};
>>>  #elif defined(CONFIG_MACH_MX31ADS)
>>> +#include <mach/hardware.h>
>>>  #include <mach/board-mx31ads.h>
>>>  static unsigned int netcard_portlist[] __used __initdata = {
>>>        PBC_BASE_ADDRESS + PBC_CS8900A_IOBASE + 0x300, 0
>>>
>> I tried this change on a different Freescale board but using the same
>> ethernet controller. The probe worked as shown in the console dump
>> below:
> 
> It didn't - you didn't read all the messages.
> 
>> cs89x0:cs89x0_probe(0x0)
>> cs89x0.c: v2.4.3-pre1 Russell Nelson <nelson@crynwr.com>, Andrew
>> Morton <andrewm@uow.edu.au>
>> eth0: cs8900 rev K found at 0xf0000300
>> cs89x0: Extended EEPROM checksum bad and no Cirrus EEPROM, relying on
>> command line
>> cs89x0 media  IRQ 61, programmed I/O, MAC 00:00:00:00:00:00
>> cs89x0_probe1() successful
>> cs89x0:cs89x0_probe(0x0)
>> cs89x0: request_region(0xf0000300, 0x10) failed
> ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
> 
>> cs89x0: no cs8900 or cs8920 detected.  Be sure to disable PnP with SETUP
> ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
> 
> The IO region was not available for whatever reason.  Check what's in
> /proc/ioports and also check your setting for IO_SPACE_LIMIT.

That is the expected behaviour of this driver:
http://lists.arm.linux.org.uk/lurker/message/20080917.154011.4631d62b.en.html

I guess the real issue is the failing eeprom and the missing mac address.

-- 
                                                 Gilles.
