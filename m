From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH net-next] mdio_bus: Remove unneeded gpiod NULL check
Date: Tue, 18 Jul 2017 16:13:29 +0300
Message-ID: <abb7e045-2e8f-235f-1fde-2ea53258b45d@cogentembedded.com>
References: <1500325749-8382-1-git-send-email-festevam@gmail.com>
 <6f984a9c-e6d3-fd0a-6719-fa9032d43d1d@cogentembedded.com>
 <CAOMZO5ABD9iasv67ehcpTzcjU-iD9=8vQ2vM7Gwc4-v9pnUt-Q@mail.gmail.com>
 <f4cdcb4b-feac-5106-8068-e694dbd3b4e6@cogentembedded.com>
 <CAOMZO5BycGHNocULcScDczRoEvbQqjnRZTDrNAw7=+zpadSOSA@mail.gmail.com>
 <8f6ca18a-b95c-458d-c19b-bf0186ff96e7@cogentembedded.com>
 <CAOMZO5Ce3yAEghVRFW7v0PaCA4Mz6xbGaAuyCTEDhEk=W726LA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
        Andrew Lunn <andrew@lunn.ch>,
        Florian Fainelli <f.fainelli@gmail.com>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        Fabio Estevam <fabio.estevam@nxp.com>
To: Fabio Estevam <festevam@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lf0-f43.google.com ([209.85.215.43]:32957 "EHLO
        mail-lf0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751398AbdGRNNc (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 18 Jul 2017 09:13:32 -0400
Received: by mail-lf0-f43.google.com with SMTP id z78so13425296lff.0
        for <netdev@vger.kernel.org>; Tue, 18 Jul 2017 06:13:32 -0700 (PDT)
In-Reply-To: <CAOMZO5Ce3yAEghVRFW7v0PaCA4Mz6xbGaAuyCTEDhEk=W726LA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 07/18/2017 04:09 PM, Fabio Estevam wrote:

>>    No, it does -- devm_gpiod_get_optinal() will return NULL in that case,
>> bus->reset_gpio will remanin NULL, and you're removing the NULL checks
>> around the gpiod_set_value_cansleep() calls. Perhaps it's the problem in the
>> GPIO support though...
>
> It is perfectly fine to call gpiod_set_value_cansleep() with a NULL
> gpio descriptor.

    Depends on whether CONFIG_HPIOLIB is enabled or not.

> Please take a look at drivers/gpio/gpiolib.c:

    If CONF(G_GPIOLIB=n, the stub from <linux/gpio/consumer.h gets used.
and devm_gpiod_get_optional() will return NULL in that case.

> gpiod_set_value_cansleep() calls VALIDATE_DESC_VOID
>
> Then if you look at the definition of VALIDATE_DESC_VOID you will see
> that it does a NULL check on desc and returns immediately if it is
> NULL.

    Sre, I did see that.

> This means we are safe here :-)

    Sigh...

MBR, Sergei
