From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH RFT 1/2] phylib: add device reset GPIO support
Date: Sat, 14 May 2016 00:16:35 +0300
Message-ID: <9c1c7190-f3bb-2e95-7d1f-c61ca8f6ee90@cogentembedded.com>
References: <81129033.NXiOLTg1so@wasted.cogentembedded.com>
 <3641492.klKRrvS8tr@wasted.cogentembedded.com>
 <20160512184233.GJ30822@pengutronix.de>
 <f1fae99f-2464-8a42-deb8-c27cccf8df12@cogentembedded.com>
 <20160513040653.GA24461@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: =?UTF-8?Q?Uwe_Kleine-K=c3=b6nig?= <u.kleine-koenig@pengutronix.de>,
	grant.likely@linaro.org, robh+dt@kernel.org,
	devicetree@vger.kernel.org, f.fainelli@gmail.com,
	netdev@vger.kernel.org, frowand.list@gmail.com, pawel.moll@arm.com,
	mark.rutland@arm.com, ijc+devicetree@hellion.org.uk,
	galak@codeaurora.org, linux-kernel@vger.kernel.org,
	Linus Walleij <linus.walleij@linaro.org>
To: Andrew Lunn <andrew@lunn.ch>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20160513040653.GA24461@lunn.ch>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello.

On 05/13/2016 07:06 AM, Andrew Lunn wrote:

>>>> +	gpiod = fwnode_get_named_gpiod(&child->fwnode, "reset-gpios");
>>>> +	/* Deassert the reset signal */
>>>> +	if (!IS_ERR(gpiod))
>>>> +		gpiod_direction_output(gpiod, 0);
>>>
>>> This is wrong I think. You must only ignore -ENODEV, all other error
>>
>>    At least -ENOSYS should also be ignored (it's returned when
>> gpiolib is not configured), right? When does -ENODEV gets returned
>> (it's not easy to follow)?
>>
>>> codes should be passed to the caller.
>>
>>    The caller doesn't care anyway...
>
> It should do.

    Tell that to Florian. So far, everybody has been happy with 
of_mdiobus_register(). Until I had to touch this code. :-)

> What if fwnode_get_named_gpiod() returns -EPROBE_DEFER
> because the GPIO driver has not been loaded yet?

    Bad luck. :-)
    Seriously, I'll see what I can do but it's not a trivial case.

> 	Andrew

MBR, Sergei
