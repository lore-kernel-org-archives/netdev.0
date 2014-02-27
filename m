From: Ben Dooks <ben.dooks@codethink.co.uk>
Subject: Re: [PATCH] phy: micrel: add of configuration for LED mode
Date: Thu, 27 Feb 2014 10:22:22 +0000
Message-ID: <530F11DE.2000309@codethink.co.uk>
References: <1393415280-10227-1-git-send-email-ben.dooks@codethink.co.uk> <CAGVrzcbUShzdYgEgHJiG8gL11+1DANiJpAk3PL5=jKASqXAyGg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linux-kernel <linux-kernel@lists.codethink.co.uk>,
	"devicetree@vger.kernel.org" <devicetree@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>
To: Florian Fainelli <f.fainelli@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ducie-dc1.codethink.co.uk ([185.25.241.215]:52504 "EHLO
	ducie-dc1.codethink.co.uk" rhost-flags-OK-FAIL-OK-FAIL)
	by vger.kernel.org with ESMTP id S1751026AbaB0KW0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 27 Feb 2014 05:22:26 -0500
In-Reply-To: <CAGVrzcbUShzdYgEgHJiG8gL11+1DANiJpAk3PL5=jKASqXAyGg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 26/02/14 22:20, Florian Fainelli wrote:
> Hi,
>
> 2014-02-26 3:48 GMT-08:00 Ben Dooks <ben.dooks@codethink.co.uk>:
>
> [snip]
>
>> diff --git a/drivers/net/phy/micrel.c b/drivers/net/phy/micrel.c
>> index 5a8993b..0c9e434 100644
>> --- a/drivers/net/phy/micrel.c
>> +++ b/drivers/net/phy/micrel.c
>> @@ -148,15 +148,52 @@ static int ks8737_config_intr(struct phy_device *phydev)
>>          return rc < 0 ? rc : 0;
>>   }
>>
>> +static int kszphy_setup_led(struct phy_device *phydev,
>> +                           unsigned int reg, unsigned int shift)
>> +{
>> +
>> +       struct device *dev = &phydev->dev;
>> +       struct device_node *of_node = dev->of_node;
>> +       int rc, temp;
>> +       u32 val;
>> +
>> +       if (!of_node && dev->parent->of_node)
>> +               of_node = dev->parent->of_node;
>> +
>> +       if (of_property_read_u32(of_node, "micrel,led-mode", &val))
>> +               return 0;
>
> This breaks non-OF configuration because of_read_property_read_u32()
> will return -ENOSYS, so you skip the LED register configuration
> entirely, is that intended?

Yes, it is only here for OF case. I should however check if
of_node is available for the !OF case.

>> +
>> +       temp = phy_read(phydev, reg);
>> +       if (temp < 0)
>> +               return temp;
>> +
>> +       temp &= 3 << shift;
>
> The compiler cannot verify that we are not overflowing, you might want
> to make sure that shift <= 14 (just in case)

Ok, should I add a WARN_ON(shift > 14) ?

>> +       temp |= val << shift;
>> +       rc = phy_write(phydev, reg, temp);
>> +
>> +       return rc < 0 ? rc : 0;
>
> You could have;
>
>               return phy_write(phydev, reg, temp);

Thanks, will change to doing that.

-- 
Ben Dooks				http://www.codethink.co.uk/
Senior Engineer				Codethink - Providing Genius
