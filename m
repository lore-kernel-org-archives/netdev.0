From: Alan Carvalho de Assis <acassis@gmail.com>
Subject: Re: [PATCH] i.MX31: Fixing cs89x0 network building to i.MX31ADS
Date: Wed, 1 Apr 2009 11:04:19 -0300
Message-ID: <37367b3a0904010704o34aa5532p4bc8b3c9a8c16f7f@mail.gmail.com>
References: <37367b3a0903241018h7ff3302fi83cf1fcb21a3114d@mail.gmail.com>
	 <37367b3a0903300714g40a108d3j59a3b56ee9cda2bf@mail.gmail.com>
	 <20090330143155.GA20101@pengutronix.de>
	 <37367b3a0903301315u51787ebcl119ed295e373a1e4@mail.gmail.com>
	 <20090331075951.GF22913@pengutronix.de>
	 <37367b3a0903310636x3c8d8eban4310018c3d1b40b@mail.gmail.com>
	 <155d92380904010454l34c57687j67e6805dafcb92ef@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: linux-arm-kernel@lists.arm.linux.org.uk, netdev@vger.kernel.org,
	Sascha Hauer <s.hauer@pengutronix.de>
To: Sajith P V <sajithpv@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from yw-out-2324.google.com ([74.125.46.31]:43554 "EHLO
	yw-out-2324.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1764043AbZDAOEV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 1 Apr 2009 10:04:21 -0400
Received: by yw-out-2324.google.com with SMTP id 5so49304ywb.1
        for <netdev@vger.kernel.org>; Wed, 01 Apr 2009 07:04:19 -0700 (PDT)
In-Reply-To: <155d92380904010454l34c57687j67e6805dafcb92ef@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Sajith,

On 4/1/09, Sajith P V <sajithpv@gmail.com> wrote:
> Hi Alan,
>
> On Tue, Mar 31, 2009 at 7:06 PM, Alan Carvalho de Assis
> <acassis@gmail.com> wrote:
>> This is a fix to get cs89x0 network driver working on i.MX31ADS
>> diff --git a/drivers/net/cs89x0.c b/drivers/net/cs89x0.c
>> index ff64976..8ccc8f7 100644
>> --- a/drivers/net/cs89x0.c
>> +++ b/drivers/net/cs89x0.c
>> @@ -190,6 +190,7 @@ static unsigned int cs8900_irq_map[] =
>> {IRQ_IXDP2X01_CS8900, 0, 0, 0};
>>  static unsigned int netcard_portlist[] __used __initdata =
>> {CIRRUS_DEFAULT_BASE, 0};
>>  static unsigned int cs8900_irq_map[] = {CIRRUS_DEFAULT_IRQ, 0, 0, 0};
>>  #elif defined(CONFIG_MACH_MX31ADS)
>> +#include <mach/hardware.h>
>>  #include <mach/board-mx31ads.h>
>>  static unsigned int netcard_portlist[] __used __initdata = {
>>        PBC_BASE_ADDRESS + PBC_CS8900A_IOBASE + 0x300, 0
>>
>
> I tried this change on a different Freescale board but using the same
> ethernet controller. The probe worked as shown in the console dump
> below:
>
> cs89x0:cs89x0_probe(0x0)
> cs89x0.c: v2.4.3-pre1 Russell Nelson <nelson@crynwr.com>, Andrew
> Morton <andrewm@uow.edu.au>
> eth0: cs8900 rev K found at 0xf0000300
> cs89x0: Extended EEPROM checksum bad and no Cirrus EEPROM, relying on
> command line
> cs89x0 media  IRQ 61, programmed I/O, MAC 00:00:00:00:00:00
> cs89x0_probe1() successful
> cs89x0:cs89x0_probe(0x0)
> cs89x0: request_region(0xf0000300, 0x10) failed
> cs89x0: no cs8900 or cs8920 detected.  Be sure to disable PnP with SETUP
>
> But going further the network device configuration failed:
> IP-Config: Failed to open eth0
> IP-Config: No network devices available.
>

It is strange, here I got a similar message:
cs89x0:cs89x0_probe(0x0)
cs89x0.c: v2.4.3-pre1 Russell Nelson <nelson@crynwr.com>, Andrew Morton
eth0: cs8900 rev K found at 0xf4020300 [Cirrus EEPROM]
cs89x0 media RJ-45, IRQ 168, programmed I/O, MAC 00:04:9f:00:41:87
cs89x0_probe1() successful
cs89x0:cs89x0_probe(0x0)
cs89x0: request_region(0xf4020300, 0x10) failed
cs89x0: no cs8900 or cs8920 detected.  Be sure to disable PnP with SETUP

But network works fine:
$ ping 10.29.240.182
PING 10.29.240.182 (10.29.240.182): 56 data bytes
64 bytes from 10.29.240.182: seq=0 ttl=63 time=0.6 ms
64 bytes from 10.29.240.182: seq=1 ttl=63 time=0.6 ms

> Should we not also enable interrupts for the ethernet controller to
> make it work?
>

On iMX31ADS there is a CPLD which receive interruptions network controller.

> Regards,
> Saijth
>

Regards,

Alan
