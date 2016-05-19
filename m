From: Guenter Roeck <linux@roeck-us.net>
Subject: Re: [PATCH] Revert "phy: add support for a reset-gpio specification"
Date: Thu, 19 May 2016 06:29:58 -0700
Message-ID: <573DBFD6.2050508@roeck-us.net>
References: <1463587500-12293-1-git-send-email-fabio.estevam@nxp.com>
 <b2763da7-575a-4d73-2997-4236173761bf@cogentembedded.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: u.kleine-koenig@pengutronix.de, f.fainelli@gmail.com,
	netdev@vger.kernel.org
To: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>,
	Fabio Estevam <fabio.estevam@nxp.com>, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from bh-25.webhostbox.net ([208.91.199.152]:40412 "EHLO
	bh-25.webhostbox.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754838AbcESNaL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 May 2016 09:30:11 -0400
In-Reply-To: <b2763da7-575a-4d73-2997-4236173761bf@cogentembedded.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 05/19/2016 06:11 AM, Sergei Shtylyov wrote:
> Hello.
>
> On 5/18/2016 7:05 PM, Fabio Estevam wrote:
>
>> Commit da47b4572056 ("phy: add support for a reset-gpio specification")
>> causes the following xtensa qemu crash according to Guenter Roeck:
>>
>> [    9.366256] libphy: ethoc-mdio: probed
>> [    9.367389]  (null): could not attach to PHY
>> [    9.368555]  (null): failed to probe MDIO bus
>> [    9.371540] Unable to handle kernel paging request at virtual address 0000001c
>> [    9.371540]  pc = d0320926, ra = 903209d1
>> [    9.375358] Oops: sig: 11 [#1]
>
>     Of course, I'd like this patch to be reverted (as it was applied erroneously instead of my patches)... but where's the backtrace? It's not immediately clear how this code can cause kernel oops...
>

See http://www.spinics.net/lists/kernel/msg2258611.html.

Guenter

>> This reverts commit da47b4572056487fd7941c26f73b3e8815ff712a.
>>
>> Reported-by: Guenter Roeck <linux@roeck-us.net>
>> Signed-off-by: Fabio Estevam <fabio.estevam@nxp.com>
> [...]
>> diff --git a/drivers/net/phy/phy_device.c b/drivers/net/phy/phy_device.c
>> index 307f72a..e977ba9 100644
>> --- a/drivers/net/phy/phy_device.c
>> +++ b/drivers/net/phy/phy_device.c
> [...]
>> @@ -1571,16 +1570,9 @@ static int phy_probe(struct device *dev)
>>      struct device_driver *drv = phydev->mdio.dev.driver;
>>      struct phy_driver *phydrv = to_phy_driver(drv);
>>      int err = 0;
>> -    struct gpio_descs *reset_gpios;
>>
>>      phydev->drv = phydrv;
>>
>> -    /* take phy out of reset */
>> -    reset_gpios = devm_gpiod_get_array_optional(dev, "reset",
>> -                            GPIOD_OUT_LOW);
>> -    if (IS_ERR(reset_gpios))
>> -        return PTR_ERR(reset_gpios);
>> -
>>      /* Disable the interrupt if the PHY doesn't support it
>>       * but the interrupt is still a valid one
>>       */
>
> MBR, Sergei
>
>
