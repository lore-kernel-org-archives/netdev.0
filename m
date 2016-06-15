From: Jeremy Linton <jeremy.linton@arm.com>
Subject: Re: [PATCH] net: smsc911x: If PHY doesn't have an interrupt then POLL
Date: Wed, 15 Jun 2016 10:56:51 -0500
Message-ID: <57617AC3.1@arm.com>
References: <1465920962-24946-1-git-send-email-jeremy.linton@arm.com>
 <46b56679-e92a-a8f9-f290-f67495169bdc@cogentembedded.com>
 <57607742.5080208@arm.com>
 <308d1da5-a869-7664-e5b4-0c838d9d2c60@cogentembedded.com>
 <576079BC.8010802@arm.com>
 <658086be-8ea6-c419-65f5-c627fb2d0654@cogentembedded.com>
 <57607CD6.5040704@arm.com>
 <cf3c6e59-76f9-4b13-2bfb-0755c68acc9c@cogentembedded.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: steve.glendinning@shawell.net
To: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from foss.arm.com ([217.140.101.70]:38656 "EHLO foss.arm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750713AbcFOP4w (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 15 Jun 2016 11:56:52 -0400
In-Reply-To: <cf3c6e59-76f9-4b13-2bfb-0755c68acc9c@cogentembedded.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 06/14/2016 04:56 PM, Sergei Shtylyov wrote:
> On 06/15/2016 12:53 AM, Jeremy Linton wrote:
>
>>>>>>>> If the interrupt configuration isn't set and we are using the
>>>>>>>
>>>>>>>     It's never set, judging by the driver code.
>>>>>>>
>>>>>>>> internal phy, then we need to poll the phy to reliably detect
>>>>>>>> phy state changes.
>>>>>>>
>>>>>>>     What address your internal PHY is at? Mine is at 1, and things
>>>>>>> seem
>>>>>>> to work reliably after probing:
>>>>>>>
>>>>>>> SMSC LAN8700 18000000.etherne:01: attached PHY driver [SMSC LAN8700]
>>>>>>> (mii_bus:phy_addr=18000000.etherne:01, irq=-1)
>>>>>>>
>>>>>>>     I'm using the device tree on my board.
>>>>>>
>>>>>> Ok, I'm back on the machine, this is what mine says without that
>>>>>> patch.
>>>>>>
>>>>>> SMSC LAN911x Internal PHY 18000000.etherne:01: attached PHY driver
>>>>>> [SMSC
>>>>>> LAN911x Internal PHY] (mii_bus:phy_addr=18000000.etherne:01, irq=0)
>>>>>
>>>>>     Hum, that's unexpected... things are probably more complex that I
>>>>> thought. Do you have extra patches to this driver by changce?
>>>>
>>>> No, the initial kernel where the problem was discovered is
>>>> 4.5.2-301.fc24.aarch64, but I built a mainline 4.6, and modprobed the
>>>> driver
>>>> with the same effect.
>>>>
>>>> Although, now that I'm looking closer at phy_irq, I'm curious how it
>>>> works for
>>>> anyone else...
>>>
>>>     Does anything change when you comment out that memcpy()? It
>>> shouldn't probably...
>>
>>     Well that should change the irq to PHY_POLL by default rather than
>> the 0's
>> in the structure, which may be a better patch.
>
>     It shouldn't due to the wrong size. It should only overwrite IRQ and
> index 0, unless I'm mistaken.

	Oh, sizeof(pointer)==8 on arm64, yah in the arm32 case you dodge the 
bullet.
	I think the memcpy removal solves the problem, i'm also going to test 
moving the mii_probe and will post an updated patch.

	Thanks!




	
