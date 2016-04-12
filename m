From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH RFT 2/2] macb: kill PHY reset code
Date: Tue, 12 Apr 2016 16:54:27 +0300
Message-ID: <570CFE13.3040100@cogentembedded.com>
References: <81129033.NXiOLTg1so@wasted.cogentembedded.com>
 <2811962.eGX2i5RJbZ@wasted.cogentembedded.com>
 <20160411022802.GB4307@lunn.ch> <570CBE42.50309@atmel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Nicolas Ferre <nicolas.ferre@atmel.com>,
	Andrew Lunn <andrew@lunn.ch>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <570CBE42.50309@atmel.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello.

On 4/12/2016 12:22 PM, Nicolas Ferre wrote:

>>> With  the 'phylib' now  being aware of  the "reset-gpios" PHY node property,
>>> there should be no need to frob the PHY reset in this  driver anymore...
>>>
>>> Signed-off-by: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
>>>
>>> ---
>>>   drivers/net/ethernet/cadence/macb.c |   17 -----------------
>>>   drivers/net/ethernet/cadence/macb.h |    1 -
>>>   2 files changed, 18 deletions(-)
>>>
>>> Index: net-next/drivers/net/ethernet/cadence/macb.c
>>> ===================================================================
>>> --- net-next.orig/drivers/net/ethernet/cadence/macb.c
>>> +++ net-next/drivers/net/ethernet/cadence/macb.c
[...]
>>> @@ -2977,18 +2976,6 @@ static int macb_probe(struct platform_de
>>>   	else
>>>   		macb_get_hwaddr(bp);
>>>
>>> -	/* Power up the PHY if there is a GPIO reset */
>>> -	phy_node =  of_get_next_available_child(np, NULL);
>>> -	if (phy_node) {
>>> -		int gpio = of_get_named_gpio(phy_node, "reset-gpios", 0);
>>> -
>>> -		if (gpio_is_valid(gpio)) {
>>> -			bp->reset_gpio = gpio_to_desc(gpio);
>>> -			gpiod_direction_output(bp->reset_gpio, 1);
>>
>> Hi Sergei
>>
>> The code you are deleting would of ignored the flags in the gpio
>
> I don't parse this.

> The code deleted does take the flag into account.

    Not really -- you need to call of_get_named_gpio_flags() (with a valid 
last argument) for that.

> And the DT property
> associated to it seems correct to me (I mean, with proper flag
> specification).

    It apparently is not as it have GPIO_ACTIVE_HIGH and the driver assumes 
active-low reset signal.

[...]
> Bye,

MBR, Sergei
