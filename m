From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH RFT 2/2] macb: kill PHY reset code
Date: Mon, 11 Apr 2016 20:41:25 +0300
Message-ID: <570BE1C5.70502@cogentembedded.com>
References: <81129033.NXiOLTg1so@wasted.cogentembedded.com>
 <2811962.eGX2i5RJbZ@wasted.cogentembedded.com>
 <20160411022802.GB4307@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: nicolas.ferre@atmel.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Andrew Lunn <andrew@lunn.ch>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20160411022802.GB4307@lunn.ch>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello.

On 04/11/2016 05:28 AM, Andrew Lunn wrote:

>> With  the 'phylib' now  being aware of  the "reset-gpios" PHY node property,
>> there should be no need to frob the PHY reset in this  driver anymore...
>>
>> Signed-off-by: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
>>
>> ---
>>   drivers/net/ethernet/cadence/macb.c |   17 -----------------
>>   drivers/net/ethernet/cadence/macb.h |    1 -
>>   2 files changed, 18 deletions(-)
>>
>> Index: net-next/drivers/net/ethernet/cadence/macb.c
>> ===================================================================
>> --- net-next.orig/drivers/net/ethernet/cadence/macb.c
>> +++ net-next/drivers/net/ethernet/cadence/macb.c
[...]
>> @@ -2977,18 +2976,6 @@ static int macb_probe(struct platform_de
>>   	else
>>   		macb_get_hwaddr(bp);
>>
>> -	/* Power up the PHY if there is a GPIO reset */
>> -	phy_node =  of_get_next_available_child(np, NULL);
>> -	if (phy_node) {
>> -		int gpio = of_get_named_gpio(phy_node, "reset-gpios", 0);
>> -
>> -		if (gpio_is_valid(gpio)) {
>> -			bp->reset_gpio = gpio_to_desc(gpio);
>> -			gpiod_direction_output(bp->reset_gpio, 1);
>
> Hi Sergei
>
> The code you are deleting would of ignored the flags in the gpio
> property, i.e. active low.

    Hm, you're right -- I forgot about that... :-/

> The new code in the previous patch does
> however take the flags into account. Did you check if there are any
> device trees which have flags, which were never used, but are now
> going to be used and thus break...

    Checked this now and found out arch/arm/boot/dts/ar91-vinco.dts. Looks 
like it needs to be fixed indeed...

>        Andrew

MBR, Sergei
