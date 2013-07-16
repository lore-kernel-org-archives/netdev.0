From: Helmut Schaa <helmut.schaa@googlemail.com>
Subject: Re: [PATCH 2/2] drivers: net: phy: at803x: LED control via led subsystem
Date: Tue, 16 Jul 2013 08:56:51 +0200
Message-ID: <CAGXE3d9Zv572L22swzHctNR0QNiA-tDAPEhTZKSXBA6SZfeLFg@mail.gmail.com>
References: <1373543855-31670-1-git-send-email-helmut.schaa@googlemail.com>
	<1373543855-31670-2-git-send-email-helmut.schaa@googlemail.com>
	<CAGVrzcbxuogp9umQVEFOfzg64Nb6UWZjHs_5M=bdHceRSFRE4g@mail.gmail.com>
	<CAGXE3d8WRU2fmRZ9DAQ4_Y=WZQwNmt9DVbLys=LkJaRPz=7FAw@mail.gmail.com>
	<CAGVrzcZn+dAzWV9ObyfLn5cyE0D7rXgUkmdKOZ8rE0q1r4J3Hg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: netdev <netdev@vger.kernel.org>, David Miller <davem@davemloft.net>
To: Florian Fainelli <florian@openwrt.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f173.google.com ([209.85.223.173]:53133 "EHLO
	mail-ie0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751715Ab3GPG4w (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 16 Jul 2013 02:56:52 -0400
Received: by mail-ie0-f173.google.com with SMTP id k13so828066iea.32
        for <netdev@vger.kernel.org>; Mon, 15 Jul 2013 23:56:51 -0700 (PDT)
In-Reply-To: <CAGVrzcZn+dAzWV9ObyfLn5cyE0D7rXgUkmdKOZ8rE0q1r4J3Hg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Jul 12, 2013 at 9:19 AM, Florian Fainelli <florian@openwrt.org> wrote:
> 2013/7/11 Helmut Schaa <helmut.schaa@googlemail.com>:
>>>
>>> I do like this and I believe that there is nothing specific that would
>>> prevent you from making software controllable LEDs from being used
>>> with other PHYs. How about you create a small LED class helper that
>>> PHY drivers supporting controllable LEDs can hook into and provide
>>> their own callback and LED name for setting the LED state?
>>
>> Hmm, nice idea. However, there is not much complexity in the code. The only
>> thing worth to make generic would be the delayed register access via workqueue.
>> The rest is just registering the led device :)
>>
>> I thought about moving the code into the generic phy code and using a new
>> phy_driver callback for setting the LED state but there might be more then one
>> LED pin on some PHYs (activity, speed, duplexmode etc.).
>
> I think that the same callback for all LEDs and just take actions
> based on which led_classdev pointer we get passed should be enough. I
> agree with you that there is not much complexity, but for sure, if we
> add support for LEDs to another PHY driver there will be similar stuff
> done (registering a LED classdev, etc...) so we might just want to
> specialize the led_brightness_set() callback and the number of LEDs.
> One thing with moving this closer to the PHY state machine would be to
> allow for better integration, like setting the LED brightness to 0
> when the link goes down etc...

Agreed, let me see if I can come up with a more generic approach.
Thanks,
Helmut
