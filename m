From: Volodymyr Bendiuga <volodymyr.bendiuga@westermo.se>
Subject: Re: [PATCH] net:dsa:mv88e6xxx: delete timer and cancel ppu_work
Date: Wed, 7 Dec 2016 11:38:11 +0100
Message-ID: <5aa87c21-2710-be25-2962-1f37b4c4b916@westermo.se>
References: <1481029062-16668-1-git-send-email-volodymyr.bendiuga@westermo.se>
 <20161206142226.GD26615@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: vivien.didelot@savoirfairelinux.com, f.fainelli@gmail.com,
        netdev@vger.kernel.org, volodymyr.bendiuga@gmail.com,
        Jonas Johansson <jonas.johansson@westermo.se>
To: Andrew Lunn <andrew@lunn.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailgw1.beijerelectronics.com ([195.67.87.156]:62228 "EHLO
        mailgw1.beijerelectronics.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1751895AbcLGKxp (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 7 Dec 2016 05:53:45 -0500
In-Reply-To: <20161206142226.GD26615@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

OK, will check it.

/Volodymyr

On 2016-12-06 15:22, Andrew Lunn wrote:
> On Tue, Dec 06, 2016 at 01:57:42PM +0100, Volodymyr Bendiuga wrote:
>> Signed-off-by: Jonas Johansson <jonas.johansson@westermo.se>
>> Signed-off-by: Volodymyr Bendiuga <volodymyr.bendiuga@westermo.se>
>> ---
>>   drivers/net/dsa/mv88e6xxx/chip.c | 5 ++++-
>>   1 file changed, 4 insertions(+), 1 deletion(-)
>>
>> diff --git a/drivers/net/dsa/mv88e6xxx/chip.c b/drivers/net/dsa/mv88e6xxx/chip.c
>> index ca453f3..4212fb6 100644
>> --- a/drivers/net/dsa/mv88e6xxx/chip.c
>> +++ b/drivers/net/dsa/mv88e6xxx/chip.c
>> @@ -4528,8 +4528,11 @@ static int mv88e6xxx_probe(struct mdio_device *mdiodev)
>>   out_mdio:
>>   	mv88e6xxx_mdio_unregister(chip);
>>   out_g2_irq:
>> -	if (mv88e6xxx_has(chip, MV88E6XXX_FLAG_G2_INT) && chip->irq > 0)
>> +	if (mv88e6xxx_has(chip, MV88E6XXX_FLAG_G2_INT) && chip->irq > 0) {
>>   		mv88e6xxx_g2_irq_free(chip);
>> +		del_timer(&chip->ppu_timer);
>> +		cancel_work_sync(&chip->ppu_work);
>> +	}
> Why do this here, inside this if statement?
>
> Vivien has also just reworked the PPU code. Please take a look at his
> patches and see if they fix the issue.
>
> 	Thanks
> 		Andrew
