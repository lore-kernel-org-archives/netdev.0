From: Linus Walleij <linus.walleij@linaro.org>
Subject: Re: [PATCH net-next] mdio_bus: Remove unneeded gpiod NULL check
Date: Wed, 2 Aug 2017 13:57:36 +0200
Message-ID: <CACRpkdYw5GWv3HRCqnWjDfctLEfzcoFdJ7ib_NVKRgw0+Y9dEg@mail.gmail.com>
References: <1500325749-8382-1-git-send-email-festevam@gmail.com>
 <6f984a9c-e6d3-fd0a-6719-fa9032d43d1d@cogentembedded.com> <CAOMZO5ABD9iasv67ehcpTzcjU-iD9=8vQ2vM7Gwc4-v9pnUt-Q@mail.gmail.com>
 <f4cdcb4b-feac-5106-8068-e694dbd3b4e6@cogentembedded.com> <CAOMZO5BycGHNocULcScDczRoEvbQqjnRZTDrNAw7=+zpadSOSA@mail.gmail.com>
 <20170718133209.GB32757@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: Fabio Estevam <festevam@gmail.com>,
        Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>,
        "David S. Miller" <davem@davemloft.net>,
        Florian Fainelli <f.fainelli@gmail.com>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        Fabio Estevam <fabio.estevam@nxp.com>
To: Andrew Lunn <andrew@lunn.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f172.google.com ([209.85.223.172]:35371 "EHLO
        mail-io0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753207AbdHBL5i (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 2 Aug 2017 07:57:38 -0400
Received: by mail-io0-f172.google.com with SMTP id m88so19363179iod.2
        for <netdev@vger.kernel.org>; Wed, 02 Aug 2017 04:57:37 -0700 (PDT)
In-Reply-To: <20170718133209.GB32757@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jul 18, 2017 at 3:32 PM, Andrew Lunn <andrew@lunn.ch> wrote:
> On Tue, Jul 18, 2017 at 09:52:51AM -0300, Fabio Estevam wrote:
>> On Tue, Jul 18, 2017 at 9:48 AM, Sergei Shtylyov
>> <sergei.shtylyov@cogentembedded.com> wrote:
>> > On 07/18/2017 03:39 PM, Fabio Estevam wrote:
>> >
>> >>>    Won't this result in kernel WARNING when GPIO is disabled?
>> >
>> >
>> >    GPIO support, I was going to type...
>> >
>> >> Not sure if I understood your point, but gpiod_set_value_cansleep() is
>> >> a no-op when the gpiod is NULL.
>> >
>> >
>> >    Look at the stub in <linux/gpio/consumer.h>, it has WARN_ON(1).
>>
>> This patch does not alter the behavior of the driver with respect to
>> GPIO being disabled, so I still do not understand your concern.
>
> http://elixir.free-electrons.com/linux/latest/source/include/linux/gpio/consumer.h#L345
> static inline void gpiod_set_value_cansleep(struct gpio_desc *desc, int value)
> {
>         /* GPIO can never have been requested */
>         WARN_ON(1);
> }
>
> But i would say this is a gpio problem. If GPIO enabled does not care,
> GPIO disabled should also not care.

If someone is using GPIO descriptors with GPIO disabled, i.e. calling
gpiod_get() and friends, this is very likely to be a bug, and what
the driver wants to do is:

 depends on GPIOLIB

or

 select GPIOLIB

in Kconfig. The whole optional thing is mainly a leftover from when it
was possible to have a local implementation of the GPIOLIB API in
some custom header file, noone sane should be doing that anymore,
and if they do, they can very well face the warnings.

If someone is facing a lot of WARN_ON() messages to this, it is a clear
indication that they need to fix their Kconfig and in that case it is proper.

Yours,
Linus Walleij
