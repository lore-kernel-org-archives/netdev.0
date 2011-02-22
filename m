From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/2] DM9000B: Fix PHY power for network down/up
Date: Tue, 22 Feb 2011 10:24:10 -0800 (PST)
Message-ID: <20110222.102410.260079835.davem@davemloft.net>
References: <4D618B5D.5040001@henry.nestler.mail.gmail.com>
	<4D62491F.4050602@ru.mvista.com>
	<4D62D323.7010403@henry.nestler.mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: sshtylyov@mvista.com, netdev@vger.kernel.org, tori@unhappy.mine.nu,
	akpm@linux-foundation.org, linux-arm-kernel@lists.infradead.org
To: henry.nestler@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:51767
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755117Ab1BVSXe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 22 Feb 2011 13:23:34 -0500
In-Reply-To: <4D62D323.7010403@henry.nestler.mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Henry Nestler <henry.nestler@gmail.com>
Date: Mon, 21 Feb 2011 22:03:31 +0100

> On 21.02.2011 12:14, Sergei Shtylyov wrote:
>> On 21-02-2011 0:45, Henry Nestler wrote:
>> 
>>> DM9000 revision B needs 1 ms delay after PHY power on (see spec), and PHY
>>> power must on in register
>> 
>>     Couldn't parse that.
> 
> This can read in manual DM900B-12-DS-F02 from September 2 2010, Page 14:
> "If this Register 1FH bit 0 is updated from '1' to '0', the all
> Registers can not be accessed within 1ms."
> 
> The example driver code waits 2 ms.
> 
>>> diff --git a/drivers/net/dm9000.c b/drivers/net/dm9000.c
>>> index 2d4c4fc..5925569 100644
>>> --- a/drivers/net/dm9000.c
>>> +++ b/drivers/net/dm9000.c
>> [...]
>>> @@ -1194,6 +1191,10 @@ dm9000_open(struct net_device *dev)
>>>   	if (request_irq(dev->irq, dm9000_interrupt, irqflags, dev->name, dev))
>>>   		return -EAGAIN;
>>>
>>> +	/* GPIO0 on pre-activate PHY, Reg 1F is not set by reset */
>>> +	iow(db, DM9000_GPR, 0);	/* REG_1F bit0 activate phyxcer */
>>> +	udelay(1000); /* delay needs by DM9000B */
>> 
>>     Why not mdelay(1)?
> 
> Because udelay is the base of mdelay.
> See include/linux/delay.h:31
> 
> #define mdelay(n) ... udelay((n)*1000)

He is telling you to use mdelay(1) because it's clearer.  Please do
so.
