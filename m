From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH] phy: micrel: add of configuration for LED mode
Date: Wed, 19 Mar 2014 02:15:14 +0300
Message-ID: <5328D382.2020902@cogentembedded.com>
References: <1393415280-10227-1-git-send-email-ben.dooks@codethink.co.uk> <5328AF1A.3090008@cogentembedded.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: f.fainelli@gmail.com, linux-sh@vger.kernel.org
To: Ben Dooks <ben.dooks@codethink.co.uk>,
	linux-kernel@lists.codethink.co.uk, devicetree@vger.kernel.org,
	netdev@vger.kernel.org
Return-path: <linux-sh-owner@vger.kernel.org>
In-Reply-To: <5328AF1A.3090008@cogentembedded.com>
Sender: linux-sh-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 03/18/2014 11:39 PM, Sergei Shtylyov wrote:

>> Add support for the led-mode property for the following PHYs
>> which have a single LED mode configuration value.

>> KSZ8001 and KSZ8041 which both use register 0x1e bits 15,14 and
>> KSZ8021, KSZ8031 and KSZ8051 which use register 0x1f bits 5,4
>> to control the LED configuration.

>> Signed-off-by: Ben Dooks <ben.dooks@codethink.co.uk>
> [...]

>     Missed this patch, unfortunately and now it has been merged already... doh.

    Great work, BTW -- looks like you had to browse a lot of datasheets to do 
this patch.

>> diff --git a/drivers/net/phy/micrel.c b/drivers/net/phy/micrel.c
>> index 5a8993b..0c9e434 100644
>> --- a/drivers/net/phy/micrel.c
>> +++ b/drivers/net/phy/micrel.c
>> @@ -148,15 +148,52 @@ static int ks8737_config_intr(struct phy_device *phydev)
>>       return rc < 0 ? rc : 0;
>>   }
>>
>> +static int kszphy_setup_led(struct phy_device *phydev,
>> +                unsigned int reg, unsigned int shift)
>> +{
>> +
>> +    struct device *dev = &phydev->dev;
>> +    struct device_node *of_node = dev->of_node;
>> +    int rc, temp;
>> +    u32 val;
>> +
>> +    if (!of_node && dev->parent->of_node)
>> +        of_node = dev->parent->of_node;
>> +
>> +    if (of_property_read_u32(of_node, "micrel,led-mode", &val))
>> +        return 0;
>> +
>> +    temp = phy_read(phydev, reg);
>> +    if (temp < 0)
>> +        return temp;
>> +
>> +    temp &= 3 << shift;

>     Hm, I guess you meant ~(3 << shift), else it wouldn't work as expected if
> the LED field is currently non-zero. Also, I think you didn't want to mask off
> unrelated bits. I'm surprised nobody has noticed this before...

    OK, I'll go fix this myself.

WBR, Sergei

