From: Bert Vermeulen <bert@biot.com>
Subject: Re: [PATCH] net: mdio-gpio: Allow for unspecified bus id
Date: Fri, 08 May 2015 18:01:22 +0200
Message-ID: <554CDDD2.6050104@biot.com>
References: <1431094729-21775-1-git-send-email-bert@biot.com> <20150508154816.GJ18496@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: f.fainelli@gmail.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Andrew Lunn <andrew@lunn.ch>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20150508154816.GJ18496@lunn.ch>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 05/08/2015 05:48 PM, Andrew Lunn wrote:
> On Fri, May 08, 2015 at 04:18:49PM +0200, Bert Vermeulen wrote:
>> When the bus id was supplied via a struct platform_device, the driver wasn't
>> handling -1 to mean an unspecified id of the only instance of this driver,
>> as the platform spec requires.
>>
>> Signed-off-by: Bert Vermeulen <bert@biot.com>
>> ---
>>  drivers/net/phy/mdio-gpio.c | 5 ++++-
>>  1 file changed, 4 insertions(+), 1 deletion(-)
>>
>> diff --git a/drivers/net/phy/mdio-gpio.c b/drivers/net/phy/mdio-gpio.c
>> index f5cddf5..7bd90db 100644
>> --- a/drivers/net/phy/mdio-gpio.c
>> +++ b/drivers/net/phy/mdio-gpio.c
>> @@ -165,7 +165,10 @@ static struct mii_bus *mdio_gpio_bus_init(struct device *dev,
>>  		if (!new_bus->irq[i])
>>  			new_bus->irq[i] = PHY_POLL;
>>  
>> -	snprintf(new_bus->id, MII_BUS_ID_SIZE, "gpio-%x", bus_id);
>> +	if (bus_id != -1)
>> +		snprintf(new_bus->id, MII_BUS_ID_SIZE, "gpio-%x", bus_id);
>> +	else
>> +		strncpy(new_bus->id, "gpio", MII_BUS_ID_SIZE);
> 
> Hi Bert
> 
> What happens if there are multiple platform_device's with -1?  You
> should probably be using use idr_alloc().

It's an instance id per driver, not globally, and -1 specifically means it's
the only instance. From Documentation/driver-model/platform.txt:

> These are concatenated, so name/id "serial"/0 indicates bus_id "serial.0", and
> "serial/3" indicates bus_id "serial.3"; both would use the platform_driver
> named "serial".  While "my_rtc"/-1 would be bus_id "my_rtc" (no instance id)
> and use the platform_driver called "my_rtc".


-- 
Bert Vermeulen        bert@biot.com          email/xmpp
