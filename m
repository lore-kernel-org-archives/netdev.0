From: "Maciej S. Szmigiero" <mail@maciej.szmigiero.name>
Subject: Re: [PATCH v2] net: phy: leds: Add support for "link" trigger
Date: Wed, 1 Nov 2017 13:21:58 +0100
Message-ID: <b789b023-2e7b-1f5b-59a6-9676db74e850@maciej.szmigiero.name>
References: <52ce25a6-8d6b-039d-ca08-90595eb9ee72@maciej.szmigiero.name>
 <20171101121611.GD12680@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: Florian Fainelli <f.fainelli@gmail.com>, netdev@vger.kernel.org,
        linux-kernel <linux-kernel@vger.kernel.org>
To: Andrew Lunn <andrew@lunn.ch>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20171101121611.GD12680@lunn.ch>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Andrew,

On 01.11.2017 13:16, Andrew Lunn wrote:
>> @@ -123,6 +153,10 @@ int phy_led_triggers_register(struct phy_device *phy)
>>  	while (i--)
>>  		phy_led_trigger_unregister(&phy->phy_led_triggers[i]);
>>  	devm_kfree(&phy->mdio.dev, phy->phy_led_triggers);
>> +out_unreg_link:
>> +	phy_led_trigger_unregister(phy->led_link_trigger);
>> +out_free_link:
>> +	devm_kfree(&phy->mdio.dev, phy->led_link_trigger);
> 
> Hi Maciej
> 
> The point of the devm_ API is that you don't need to worry about
> freeing the memory. The core will do it, when the driver is removed.
> 
> I guess you are just copying the code above, which i would also say is
> unnecessary.

Yes, I did it the same way as the existing code did for phy->phy_led_triggers
for reasons of both consistency and also to be on the safe side because
maybe there is some non-obvious reason why it has to be freed
explicitly (?).

> 	Andrew

Maciej
