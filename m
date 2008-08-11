From: Ingo Molnar <mingo@elte.hu>
Subject: Re: [PATCH] net, wd.c: fix undefined reference to `NS8390p_init'
Date: Mon, 11 Aug 2008 13:11:17 +0200
Message-ID: <20080811111116.GA6121@elte.hu>
References: <20080806182828.6bfe0a16.sfr@canb.auug.org.au> <20080806172148.7fac5999.randy.dunlap@oracle.com> <Pine.LNX.4.64.0808070918510.17614@anakin> <20080807102931.1bb0607d@lxorguk.ukuu.org.uk> <20080811091105.GA8141@elte.hu> <48A00AB5.1030108@pobox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Alan Cox <alan@lxorguk.ukuu.org.uk>,
	Geert Uytterhoeven <geert@linux-m68k.org>,
	Randy Dunlap <randy.dunlap@oracle.com>,
	Stephen Rothwell <sfr@canb.auug.org.au>,
	linux-next@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>
To: Jeff Garzik <jgarzik@pobox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.mail.elte.hu ([157.181.151.9]:42447 "EHLO mx2.mail.elte.hu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751532AbYHKLMf (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 11 Aug 2008 07:12:35 -0400
Content-Disposition: inline
In-Reply-To: <48A00AB5.1030108@pobox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


* Jeff Garzik <jgarzik@pobox.com> wrote:

> Ingo Molnar wrote:
>> * Alan Cox <alan@lxorguk.ukuu.org.uk> wrote:
>>
>>> On Thu, 7 Aug 2008 09:20:07 +0200 (CEST)
>>> Geert Uytterhoeven <geert@linux-m68k.org> wrote:
>>>
>>>> On Wed, 6 Aug 2008, Randy Dunlap wrote:
>>>>> One randconfig ends with:
>>>>>
>>>>> drivers/built-in.o: In function `wd_probe1':
>>>>> wd.c:(.init.text+0x6179): undefined reference to `NS8390p_init'
>>>>> make[1]: *** [.tmp_vmlinux1] Error 1
>>>> drivers/net/Makefile has:
>>>>
>>>> obj-$(CONFIG_WD80x3) += wd.o 8390.o
>>>>
>>>> So either wd_probe1() should call NS8390_init(), or obj-$(CONFIG_WD80x3)
>>>> should link with 8390p.o. Don't know which is the appropriate change
>>>> here (my gut feeling says the latter).
>>> Safest is the latter. The shared memory interface on the wd is full  
>>> speed 8 or 16bit (depending on card/jumpers) but I'm not clear about  
>>> the NIC. Most of the performance hit is on the packet transfer which  
>>> is private methods on this device so using 8390p won't make a big  
>>> difference on this board anyway.
>>
>> Alan, Jeff, i triggered this too with latest -git, please pick up the  
>> fix below if you dont have it already.
>>
>> 	Ingo
>>
>> ------------------>
>>> From c03cb1727bb4c5433436bfb0fab59fdcc00749c3 Mon Sep 17 00:00:00 2001
>> From: Ingo Molnar <mingo@elte.hu>
>> Date: Mon, 11 Aug 2008 11:11:42 +0200
>> Subject: [PATCH] net, wd.c: fix undefined reference to `NS8390p_init'
>>
>> fix:
>>
>>   drivers/built-in.o: In function `wd_probe1':
>>   wd.c:(.init.text+0xb247): undefined reference to `NS8390p_init'
>>
>> that triggers with:
>>
>>   http://redhat.com/~mingo/misc/config-Mon_Aug_11_10_40_46_CEST_2008.bad
>>
>> Signed-off-by: Ingo Molnar <mingo@elte.hu>
>> ---
>>  drivers/net/Makefile |    2 +-
>>  1 files changed, 1 insertions(+), 1 deletions(-)
>
> DaveM should have it AFAIK, I'll double-check and make sure it got in  
> somewhere.

there's also this build failure:

 wd.c:(.text+0x38804): undefined reference to `ei_close'
 wd.c:(.text+0x38882): undefined reference to `ei_open'
 wd.c:(.init.text+0x4952): undefined reference to `ei_interrupt'
 wd.c:(.init.text+0x4c27): undefined reference to `ei_poll'
 (.init.text+0x4c83): undefined reference to `__alloc_ei_netdev'

which are only defined in 8390.c.

	Ingo
