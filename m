From: Linus Walleij <linus.walleij@linaro.org>
Subject: Re: [PATCH net] Revert "mdio_bus: Remove unneeded gpiod NULL check"
Date: Sat, 9 Sep 2017 01:24:17 +0200
Message-ID: <CACRpkdbFUaO=kwLVf8kmCR7ULFPs9MVQJVOrjM6mJ_6JWGet9A@mail.gmail.com>
References: <20170908223807.6015-1-f.fainelli@gmail.com> <CACRpkdZD-nRXXusX36Gaypf5A601CMEO3vVgaOV5tKufvy1M3Q@mail.gmail.com>
 <fe6846be-afc3-1025-d78a-96674e1b2a35@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "David S. Miller" <davem@davemloft.net>,
        Andrew Lunn <andrew@lunn.ch>,
        Fabio Estevam <festevam@gmail.com>,
        Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>,
        Fabio Estevam <fabio.estevam@nxp.com>,
        Bryan.Whitehead@microchip.com
To: Florian Fainelli <f.fainelli@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f43.google.com ([209.85.218.43]:35905 "EHLO
        mail-oi0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1757286AbdIHXYS (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 8 Sep 2017 19:24:18 -0400
Received: by mail-oi0-f43.google.com with SMTP id x190so22460773oix.3
        for <netdev@vger.kernel.org>; Fri, 08 Sep 2017 16:24:18 -0700 (PDT)
In-Reply-To: <fe6846be-afc3-1025-d78a-96674e1b2a35@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Sep 9, 2017 at 1:18 AM, Florian Fainelli <f.fainelli@gmail.com> wrote:
> On 09/08/2017 04:13 PM, Linus Walleij wrote:
>> On Sat, Sep 9, 2017 at 12:38 AM, Florian Fainelli <f.fainelli@gmail.com> wrote:
>>
>>> This reverts commit 95b80bf3db03c2bf572a357cf74b9a6aefef0a4a ("mdio_bus:
>>> Remove unneeded gpiod NULL check"), this commit assumed that GPIOLIB
>>> checks for NULL descriptors, so it's safe to drop them, but it is not
>>> when CONFIG_GPIOLIB is disabled in the kernel. If we do call
>>> gpiod_set_value_cansleep() on a GPIO descriptor we will issue warnings
>>> coming from the inline stubs declared in include/linux/gpio/consumer.h.
>>>
>>> Fixes: 95b80bf3db03 ("mdio_bus: Remove unneeded gpiod NULL check")
>>> Reported-by: Woojung Huh <Woojung.Huh@microchip.com>
>>> Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
>>
>> Yeah I guess you don't wanna have these messages spewing
>> in the console. :/
>>
>> But what about simply doing this:
>
> That would create another dependency which really does not need to be
> there as it really prevents you from testing more configurations,
> including but not limited to having CONFIG_GPIOLIB=n w/
> CONFIG_MDIO_DEVICE=[ym].
>
> The GPIOLIB=n inline stubs have a "contract" with the code calling them
> that is fairly clear, which is what this revert is leveraging.

Ayeah the contract is something like "you can call us if compiled out,
but then you get warnings".

Yeah NULL checks does the trick as well as #ifdef:in in that sense.
It's no big deal so if you prefer this:
Acked-by: Linus Walleij <linus.walleij@linaro.org>

Yours,
Linus Walleij
