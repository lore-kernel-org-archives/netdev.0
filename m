From: Randy Dunlap <rdunlap@infradead.org>
Subject: Re: randconfig build error with next-20141001, in drivers/i2c/algos/i2c-algo-bit.c
Date: Mon, 06 Oct 2014 11:09:44 -0700
Message-ID: <5432DAE8.5030509@infradead.org>
References: <CA+r1ZhiL1y9aeLeJjpd_1DtzOG_oyoPg7XsTPJ9G-XY5G2DfCQ@mail.gmail.com> <542C8D93.8090008@infradead.org> <54324D68.6070309@hartkopp.net> <5432C8C6.7060506@infradead.org> <5432D3E6.9020805@hartkopp.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: linux-next <linux-next@vger.kernel.org>,
	Stephane Grosjean <s.grosjean@peak-system.com>,
	linux-i2c@vger.kernel.org,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	linux-can@vger.kernel.org
To: Oliver Hartkopp <socketcan@hartkopp.net>,
	Jim Davis <jim.epost@gmail.com>,
	Stephen Rothwell <sfr@canb.auug.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from bombadil.infradead.org ([198.137.202.9]:44229 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752080AbaJFSJp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 6 Oct 2014 14:09:45 -0400
In-Reply-To: <5432D3E6.9020805@hartkopp.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 10/06/14 10:39, Oliver Hartkopp wrote:
> 
> 
> On 10/06/2014 06:52 PM, Randy Dunlap wrote:
>> On 10/06/14 01:06, Oliver Hartkopp wrote:
>>> Hello all,
>>>
>>> just to get it right:
>>>
>>> So far it looks like this in linux/drivers/net/can/sja1000/Kconfig
>>>
>>> config CAN_PEAK_PCIEC
>>>         bool "PEAK PCAN-ExpressCard Cards"
>>>         depends on CAN_PEAK_PCI
>>>         select I2C
>>>         select I2C_ALGOBIT
>>>
>>> If one would change the
>>>
>>>         select I2C
>>>
>>> into
>>>
>>>         depends on I2C
>>>
>>> IMHO the CAN_PEAK_PCIEC hardware would *only* be visible and selectable when
>>> I2C was selected before (from anyone else?).
>>
>> That is correct.
>>
>>> So what it wrong on the current Kconfig entry?
>>> Is 'select' deprecated?
>>
>> No, it's not deprecated.  It's just dangerous.  and driver configs should not
>> enable entire subsystems via 'select'.
>>
>>> Or did randconfig generate a configuration that would not be possible by
>>> properly generating the config file with 'make menuconfig' ??
>>
>> randconfig generated a config for another driver which causes a build error,
>> not for a CAN driver.  The CAN driver does not have a build error AFAIK.
>> Its Kconfig is just doing something with a very big & ugly stick.
> 
> But when it is not done like this, we might have an invisible config option in
> the corner case that I2C is not enabled by anyone else.
> 
> So what would you propose then?
> 
> AFAICS there is 'just' a style problem as 'configs should not enable entire
> subsystems'. But it finally is a correct and valid Kconfig, right?

Yes, right.

> When I2C is already enabled - fine. If (unlikely) I2C is not enabled, we need
> to pull the ugly stick. So what is dangerous on this? Was there any misuse of
> select statements before?

No syntactic misuse, more of a style thing, like you say.

The danger is in select being a big stick that does not check for symbol
dependencies.

In the unlikely case that I2C is not enabled, the user should have to enable
it instead of a solitary driver enabling it.  IOW, if a subsystem is disabled,
the user probably wanted it that way and a single driver should not override
that setting.


-- 
~Randy
