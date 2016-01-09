From: Guenter Roeck <linux@roeck-us.net>
Subject: Re: [PATCH -next 1/2] net: bfin_mac: Fix error handling in probe
 function
Date: Sat, 9 Jan 2016 10:10:41 -0800
Message-ID: <56914D21.9050804@roeck-us.net>
References: <1452357427-30578-1-git-send-email-linux@roeck-us.net>
 <20160109165802.GD28813@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	adi-buildroot-devel@lists.sourceforge.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Andrew Lunn <andrew@lunn.ch>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20160109165802.GD28813@lunn.ch>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Andrew,

On 01/09/2016 08:58 AM, Andrew Lunn wrote:
> Hi Guenter
>
> Same fix was submitted yesterday by Sudip Mukherjee.
>

I missed that one, sorry.

How about drivers/net/ethernet/toshiba/tc35815.c ? It now has an unused
variable due to e7f4dc3536a4, and it fails to build because of 7f854420fbfe.

Which leads to the question which of the other build failures due to
7f854420fbfe have been addressed already. In addition to the toshiba driver,
I see build failures in drivers/net/ethernet/ti/cpmac.c and possibly
drivers/staging/octeon/ethernet-rgmii.c (the error message is different,
so it may be something else).

I don't see patches for those, but I guess I must be blind, so I figure I
better ask before I send out mine.

Thanks,
Guenter

> Thanks
> 	Andrew
>
>
> On Sat, Jan 09, 2016 at 08:37:06AM -0800, Guenter Roeck wrote:
>> Commit e7f4dc3536a4 ("mdio: Move allocation of interrupts into core")
>> removed interrupt allocation code. While doing so, error handling got
>> messed up a bit, resulting in the following build warning and a missed
>> call to mdiobus_free() in the probe function error path.
>>
>> drivers/net/ethernet/adi/bfin_mac.c: In function 'bfin_mii_bus_probe':
>> drivers/net/ethernet/adi/bfin_mac.c:1865:1: warning:
>> 	label 'out_err_irq_alloc' defined but not used
>>
>> Fixes: e7f4dc3536a4 ("mdio: Move allocation of interrupts into core")
>> Cc: Andrew Lunn <andrew@lunn.ch>
>> Signed-off-by: Guenter Roeck <linux@roeck-us.net>
>> ---
>>   drivers/net/ethernet/adi/bfin_mac.c | 4 ++--
>>   1 file changed, 2 insertions(+), 2 deletions(-)
>>
>> diff --git a/drivers/net/ethernet/adi/bfin_mac.c b/drivers/net/ethernet/adi/bfin_mac.c
>> index 62862744c870..8c5132624510 100644
>> --- a/drivers/net/ethernet/adi/bfin_mac.c
>> +++ b/drivers/net/ethernet/adi/bfin_mac.c
>> @@ -1856,13 +1856,13 @@ static int bfin_mii_bus_probe(struct platform_device *pdev)
>>   	rc = mdiobus_register(miibus);
>>   	if (rc) {
>>   		dev_err(&pdev->dev, "Cannot register MDIO bus!\n");
>> -		goto out_err_alloc;
>> +		goto out_err_mdiobus_register;
>>   	}
>>
>>   	platform_set_drvdata(pdev, miibus);
>>   	return 0;
>>
>> -out_err_irq_alloc:
>> +out_err_mdiobus_register:
>>   	mdiobus_free(miibus);
>>   out_err_alloc:
>>   	peripheral_free_list(pin_req);
>> --
>> 2.1.4
>>
>
