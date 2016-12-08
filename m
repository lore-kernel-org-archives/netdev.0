From: Geert Uytterhoeven <geert@linux-m68k.org>
Subject: Re: [PATCH] sh_eth: add wake-on-lan support via magic packet
Date: Thu, 8 Dec 2016 16:13:39 +0100
Message-ID: <CAMuHMdUG6QRs7aF=Kdcd8_6cnQO6+UER6XjyNEmqQS7igBeFTw@mail.gmail.com>
References: <20161207162843.4731-1-niklas.soderlund+renesas@ragnatech.se>
 <59a1f246-9062-20e1-3f85-a1c5f6fcfc29@cogentembedded.com> <20161208145635.GH21834@bigcity.dyn.berto.se>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Cc: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>,
        Simon Horman <horms+renesas@verge.net.au>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        Linux-Renesas <linux-renesas-soc@vger.kernel.org>
To: =?UTF-8?Q?Niklas_S=C3=B6derlund?= <niklas.soderlund@ragnatech.se>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f195.google.com ([209.85.223.195]:34919 "EHLO
        mail-io0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753630AbcLHPN4 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 8 Dec 2016 10:13:56 -0500
In-Reply-To: <20161208145635.GH21834@bigcity.dyn.berto.se>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Dec 8, 2016 at 3:56 PM, Niklas S=C3=B6derlund
<niklas.soderlund@ragnatech.se> wrote:
>> > +   /* Increased clock usage so device won't be suspended */
>> > +   clk_enable(mdp->clk);
>>
>>    Hum, intermixiggn runtime PM with clock API doesn't look good...
>
> I agree it looks weird but I need a way to increment the usage count for
> the clock otherwise the PM code will disable the module clock and WoL
> will not work. Note that this call will not enable the clock just
> increase the usage count so it won't be disabled when the PM code
> decrease it after the sh_eth suspend function is run.
>
> If you know of a different way of ensuring that the clock is not turned
> off I be happy to look at it. I did some investigation into this and
> calling clk_enable() directly is for example what happens in the
> enable_irq_wake() call path to ensure the clock for the irq_chip is not
> turned off if it is a wakeup source, se for example
> gpio_rcar_irq_set_wake() in drivers/gpio/gpio-rcar.c.

Ideally we want to prevent the PM code from disabling the clock, and  from
powering down the power area, if present.
The latter may matter on other SoCs. But on r8a7740, Ethernet is part of
power area A4S, which we already prevent from being powered down because
it contains the memory controller.

Gr{oetje,eeting}s,

                        Geert
