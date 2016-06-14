From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH] net: smsc911x: If PHY doesn't have an interrupt then POLL
Date: Tue, 14 Jun 2016 23:21:41 +0300
Message-ID: <8cb3ce33-1bac-65aa-9c8b-1585ccda0b89@cogentembedded.com>
References: <1465920962-24946-1-git-send-email-jeremy.linton@arm.com>
 <81bb72b5-ccea-ee75-24f9-ffec73853fd9@cogentembedded.com>
 <1881cbee-2d9f-a933-63dd-caf91f3e14a3@cogentembedded.com>
 <0b8c79f9-f938-8357-fb6a-af49ada03fda@cogentembedded.com>
 <20160614201243.GC8518@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Jeremy Linton <jeremy.linton@arm.com>, netdev@vger.kernel.org,
	steve.glendinning@shawell.net
To: Andrew Lunn <andrew@lunn.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lf0-f45.google.com ([209.85.215.45]:34688 "EHLO
	mail-lf0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752793AbcFNUVq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 14 Jun 2016 16:21:46 -0400
Received: by mail-lf0-f45.google.com with SMTP id j7so891701lfg.1
        for <netdev@vger.kernel.org>; Tue, 14 Jun 2016 13:21:45 -0700 (PDT)
In-Reply-To: <20160614201243.GC8518@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 06/14/2016 11:12 PM, Andrew Lunn wrote:
> On Tue, Jun 14, 2016 at 10:49:20PM +0300, Sergei Shtylyov wrote:
>> On 06/14/2016 10:27 PM, Sergei Shtylyov wrote:
>>
>>>>> If the interrupt configuration isn't set and we are using the
>>>>> internal phy, then we need to poll the phy to reliably detect
>>>>> phy state changes.
>>>>>
>>>>> Signed-off-by: Jeremy Linton <jeremy.linton@arm.com>
>>>>> ---
>>>>> drivers/net/ethernet/smsc/smsc911x.c | 3 +++
>>>>> 1 file changed, 3 insertions(+)
>>>>>
>>>>> diff --git a/drivers/net/ethernet/smsc/smsc911x.c
>>>>> b/drivers/net/ethernet/smsc/smsc911x.c
>>>>> index 8af2556..369dc7d 100644
>>>>> --- a/drivers/net/ethernet/smsc/smsc911x.c
>>>>> +++ b/drivers/net/ethernet/smsc/smsc911x.c
>>>>> @@ -1020,6 +1020,9 @@ static int smsc911x_mii_probe(struct net_device *dev)
>>>>>         return -ENODEV;
>>>>>     }
>>>>>
>>>>> +    if ((!phydev->irq) && (!pdata->using_extphy))
>>>>
>>>>   Inner parens aren't needed at all.
>>>
>>>   Hm, 'phydev->irq' shouldn't be 0 in the first place. It seems to me we
>>> should correctly initialize 'pdata->phy_irq[]' in smsc911x_mii_init()...
>
> Hi Sergei
>
> The mdio layer, when it allocates the mdiobus structure, will
> initialise all the phy interrupts to polling.

    And this whole array would get overwritten with zeros by memcpy() iff that 
one was correct (it really overwrites only index 0).

>>    And looking at that array, I doubt it's really useful for
>> anything... And the memcpy() there seems buggy as well -- it copies
>> just 4 bytes of this array to 'pdata->mii_bus->irq'.
>
> 0 is not a valid interrupt.

    Or at least Linus says so... :-)

> So it should probably loop over the array
> and copy any which are not 0 into pdata->mii_bus->irq[].

    I don't see where that array is explicitly initialized in the first place. 
So it seems actively harmful...

>     Andrew

MBR, Sergei
