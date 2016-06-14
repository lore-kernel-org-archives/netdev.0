From: Jeremy Linton <jeremy.linton@arm.com>
Subject: Re: [PATCH] net: smsc911x: If PHY doesn't have an interrupt then POLL
Date: Tue, 14 Jun 2016 15:13:40 -0500
Message-ID: <57606574.5080700@arm.com>
References: <1465920962-24946-1-git-send-email-jeremy.linton@arm.com>
 <81bb72b5-ccea-ee75-24f9-ffec73853fd9@cogentembedded.com>
 <1881cbee-2d9f-a933-63dd-caf91f3e14a3@cogentembedded.com>
 <0b8c79f9-f938-8357-fb6a-af49ada03fda@cogentembedded.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: steve.glendinning@shawell.net
To: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from foss.arm.com ([217.140.101.70]:33107 "EHLO foss.arm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751392AbcFNUOB (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 14 Jun 2016 16:14:01 -0400
In-Reply-To: <0b8c79f9-f938-8357-fb6a-af49ada03fda@cogentembedded.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 06/14/2016 02:49 PM, Sergei Shtylyov wrote:
> On 06/14/2016 10:27 PM, Sergei Shtylyov wrote:
>
>>>> If the interrupt configuration isn't set and we are using the
>>>> internal phy, then we need to poll the phy to reliably detect
>>>> phy state changes.
>>>>
>>>> Signed-off-by: Jeremy Linton <jeremy.linton@arm.com>
>>>> ---
>>>>  drivers/net/ethernet/smsc/smsc911x.c | 3 +++
>>>>  1 file changed, 3 insertions(+)
>>>>
>>>> diff --git a/drivers/net/ethernet/smsc/smsc911x.c
>>>> b/drivers/net/ethernet/smsc/smsc911x.c
>>>> index 8af2556..369dc7d 100644
>>>> --- a/drivers/net/ethernet/smsc/smsc911x.c
>>>> +++ b/drivers/net/ethernet/smsc/smsc911x.c
>>>> @@ -1020,6 +1020,9 @@ static int smsc911x_mii_probe(struct
>>>> net_device *dev)
>>>>          return -ENODEV;
>>>>      }
>>>>
>>>> +    if ((!phydev->irq) && (!pdata->using_extphy))
>>>
>>>    Inner parens aren't needed at all.
>>
>>    Hm, 'phydev->irq' shouldn't be 0 in the first place. It seems to me we
>> should correctly initialize 'pdata->phy_irq[]' in smsc911x_mii_init()...
>
>     And looking at that array, I doubt it's really useful for
> anything... And the memcpy() there seems buggy as well -- it copies just
> 4 bytes of this array to 'pdata->mii_bus->irq'. I do care about this
> driver, so might be a good idea to clean it up a bit...

	The use of phy_connect_direct() in the driver probe is incorrect, and 
keeps the driver from being unloaded.

	Also, some portion of smsc's can deliver mii state change interrupts 
via the smsc interrupt, but that code is no longer in this driver.

	I suspect a portion of the problem, besides all the strange hardware 
configurations this driver supports are the emulated hardware like QEMU 
that also uses it.
