From: Linus Walleij <linus.walleij@linaro.org>
Subject: Re: [PATCH net-next] mdio_bus: Remove unneeded gpiod NULL check
Date: Thu, 7 Sep 2017 23:33:50 +0200
Message-ID: <CACRpkdbK03cwzmGs=0nVeCp6NnX0-41dhEotxfDT46O4xDzagQ@mail.gmail.com>
References: <1500325749-8382-1-git-send-email-festevam@gmail.com>
 <6f984a9c-e6d3-fd0a-6719-fa9032d43d1d@cogentembedded.com> <CAOMZO5ABD9iasv67ehcpTzcjU-iD9=8vQ2vM7Gwc4-v9pnUt-Q@mail.gmail.com>
 <f4cdcb4b-feac-5106-8068-e694dbd3b4e6@cogentembedded.com> <CAOMZO5BycGHNocULcScDczRoEvbQqjnRZTDrNAw7=+zpadSOSA@mail.gmail.com>
 <20170718133209.GB32757@lunn.ch> <CACRpkdYw5GWv3HRCqnWjDfctLEfzcoFdJ7ib_NVKRgw0+Y9dEg@mail.gmail.com>
 <9235D6609DB808459E95D78E17F2E43D40B1B424@CHN-SV-EXMX02.mchp-main.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: Andrew Lunn <andrew@lunn.ch>, Fabio Estevam <festevam@gmail.com>,
        Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>,
        "David S. Miller" <davem@davemloft.net>,
        Florian Fainelli <f.fainelli@gmail.com>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        Fabio Estevam <fabio.estevam@nxp.com>
To: Woojung.Huh@microchip.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f54.google.com ([209.85.218.54]:36568 "EHLO
        mail-oi0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752708AbdIGVdv (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 7 Sep 2017 17:33:51 -0400
Received: by mail-oi0-f54.google.com with SMTP id x190so5316700oix.3
        for <netdev@vger.kernel.org>; Thu, 07 Sep 2017 14:33:51 -0700 (PDT)
In-Reply-To: <9235D6609DB808459E95D78E17F2E43D40B1B424@CHN-SV-EXMX02.mchp-main.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Sep 7, 2017 at 11:30 PM,  <Woojung.Huh@microchip.com> wrote:
>> If someone is using GPIO descriptors with GPIO disabled, i.e. calling
>> gpiod_get() and friends, this is very likely to be a bug, and what
>> the driver wants to do is:
>>
>>  depends on GPIOLIB
>>
>> or
>>
>>  select GPIOLIB
>>
>> in Kconfig. The whole optional thing is mainly a leftover from when it
>> was possible to have a local implementation of the GPIOLIB API in
>> some custom header file, noone sane should be doing that anymore,
>> and if they do, they can very well face the warnings.
>>
>> If someone is facing a lot of WARN_ON() messages to this, it is a clear
>> indication that they need to fix their Kconfig and in that case it is proper.
> Linus & Andrew,
>
> I knew that it is already in David's pulling request.
> Configuring GPIOLIB is the right solution  even if platform doesn't use it?

I guess?

"Platform doesn't use it" what does that mean?

Does it mean it does not call the
APIs of the GPIOLIB, does it mean it doesn't have a GPIO driver
at probe (but may have one by having it probed from a module)
or does it mean the platform can never have it?

If it calls the APIs, it is using it.

Yours,
Linus Walleij
