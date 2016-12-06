From: Volodymyr Bendiuga <volodymyr.bendiuga@westermo.se>
Subject: Re: [PATCH] net:mv88e6xxx: dispose irq mapping
Date: Tue, 6 Dec 2016 16:00:27 +0100
Message-ID: <7717215e-dddd-14af-196f-e638b5c60649@westermo.se>
References: <1481018743-27208-1-git-send-email-volodymyr.bendiuga@westermo.se>
 <20161206141923.GB26615@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: vivien.didelot@savoirfairelinux.com, f.fainelli@gmail.com,
        netdev@vger.kernel.org
To: Andrew Lunn <andrew@lunn.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailgw1.beijerelectronics.com ([195.67.87.156]:55947 "EHLO
        mailgw1.beijerelectronics.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1751443AbcLFPRL (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 6 Dec 2016 10:17:11 -0500
In-Reply-To: <20161206141923.GB26615@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Andrew,

thanks for you comments and time taken to review. I will make a new

version which will indicate net-next tree.

About mv88e6xxx_remove(), this function will not be called

if switch has not been registered completely, therefore dispose will not 
be called.

irq_dispose_mapping() is also called in mv88e6xxx_g2_irq_free(), so I 
put it in a similar

way in mv88e6xxx_g1_irq_free(). What do you think? If you have any other 
idea

of how this could be implemented then let me know and I will fix it.

/Volodymyr

On 2016-12-06 15:19, Andrew Lunn wrote:
> On Tue, Dec 06, 2016 at 11:05:43AM +0100, Volodymyr Bendiuga wrote:
>> If this is not done, then it is not possible to map
>> irq next time, after EPROBE_DEFER.
>>
>> Signed-off-by: Volodymyr Bendiuga <volodymyr.bendiuga@westermo.se>
> Hi Volodymyr
>
> Thanks for your patches.
>
> Please could you include in the subject line which tree it is for. See
>
> Documentation/networking/netdev-FAQ.txt
>
>
>> ---
>>   drivers/net/dsa/mv88e6xxx/chip.c | 1 +
>>   1 file changed, 1 insertion(+)
>>
>> diff --git a/drivers/net/dsa/mv88e6xxx/chip.c b/drivers/net/dsa/mv88e6xxx/chip.c
>> index 05942e3..12e7d38 100644
>> --- a/drivers/net/dsa/mv88e6xxx/chip.c
>> +++ b/drivers/net/dsa/mv88e6xxx/chip.c
>> @@ -420,6 +420,7 @@ static void mv88e6xxx_g1_irq_free(struct mv88e6xxx_chip *chip)
>>   	mv88e6xxx_g1_write(chip, GLOBAL_CONTROL, mask);
>>   
>>   	free_irq(chip->irq, chip);
>> +	irq_dispose_mapping(chip->irq);
> This seems like the wrong place to do this.
>
> The mapping is created by chip->irq = of_irq_get(np, 0); in
> mv88e6xxx_probe(). So the correct place to dispose of this mapping would be in
> mv88e6xxx_remove() and the error path of mv88e6xxx_probe().
>
> Thanks
> 	Andrew
