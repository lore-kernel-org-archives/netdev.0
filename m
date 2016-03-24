From: Vishal Thanki <vishalthanki@gmail.com>
Subject: Re: [PATCH 0/3] Control ethernet PHY LEDs via LED subsystem
Date: Thu, 24 Mar 2016 18:35:44 +0100
Message-ID: <CAC3a_SDK8aoz1KKXa9FYBj8a1q8EPMLtVe94mGemeh7Wf=BL4g@mail.gmail.com>
References: <1458755500-15571-1-git-send-email-vishalthanki@gmail.com>
 <20160323185006.GL5250@lunn.ch> <CAC3a_SCD6aMF=triCQDJrW9GQ3HOMMH9q_J9GEw56qrnwgFXKA@mail.gmail.com>
 <20160323211010.GF19953@lunn.ch> <CAC3a_SBjvQFT5XP2bH3TO_4wHnjZ3a3+XvfBy8StxQieEsavQQ@mail.gmail.com>
 <20160324132935.GA15624@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Florian Fainelli <f.fainelli@gmail.com>,
	Matus Ujhelyi <ujhelyi.m@gmail.com>, netdev@vger.kernel.org
To: Andrew Lunn <andrew@lunn.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lf0-f67.google.com ([209.85.215.67]:36507 "EHLO
	mail-lf0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750798AbcCXRgG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 24 Mar 2016 13:36:06 -0400
Received: by mail-lf0-f67.google.com with SMTP id r8so4409058lfe.3
        for <netdev@vger.kernel.org>; Thu, 24 Mar 2016 10:36:05 -0700 (PDT)
In-Reply-To: <20160324132935.GA15624@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>> >> The eth-phy-activity trigger uses the blink_set which I think uses the
>> >> hardware acceleration if available. I am not sure how to handles LEDs
>> >> which does not have hardware acceleration for this (eth-phy-activity)
>> >> trigger.
>> >
>> > We want the LED to blink on activity, real packets coming in and
>> > out. The PHY can do this, so let the PHY control the LED. In this
>> > case, the trigger is just mechanism for the user to say what the LED
>> > should be used for. The trigger is not itself controlling the LED, it
>> > has no idea about packets coming and going.
>> >
>>
>> Yes, I understand that. But PHY can only control the LEDs attached to
>> it directly. The at803x led driver configures the PHY to blink the
>> activity LED based on traffic but I think it is not possible for PHY
>> to control other LEDs in system, for example some other LEDs in system
>> controlled only via GPIO. In such cases, putting PHY activity trigger
>> on the GPIO LEDs would not make sense. Correct me if I am wrong.
>
> Hi Vishal
>
> All correct. Which is why i said in my original email, you need to
> extend the LED core to associate triggers to LEDs. You can then
> associate the eth-phy-activity trigger to only PHY leds which can
> implement that functionality.
>
> drivers/leds/led-triggers.c contains a global list
> LIST_HEAD(trigger_list) which triggers get added to using
> led_trigger_register(). You could add a second list to the
> led_classdev structure, and add an led_trigger_register_to_led()

Hi Andrew,

I still have some questions. Will the phylib call this
led_trigger_register_to_led() function for registering the trigger
instead of calling led_trigger_register()?

> function which registers a trigger to a specific LED, on its own
> trigger list. led_trigger_store() and led_trigger_show() would use
> both lists.

In case of led_trigger_store(), how to stop the non-PHY LEDs to
register themselves from eth-phy-activity trigger. Should there be a
LED class field which distinguishes different LEDs types (GPIO, PHY
etc..) ? And only PHY LEDs have the privilege to register to
eth-phy-activity trigger?

Thanks you very much for your guidance and patience with me.

Regards,
Vishal

>
>      Andrew
