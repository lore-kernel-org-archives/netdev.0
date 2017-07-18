From: Fabio Estevam <festevam@gmail.com>
Subject: Re: [PATCH net-next] mdio_bus: Remove unneeded gpiod NULL check
Date: Tue, 18 Jul 2017 10:09:21 -0300
Message-ID: <CAOMZO5Ce3yAEghVRFW7v0PaCA4Mz6xbGaAuyCTEDhEk=W726LA@mail.gmail.com>
References: <1500325749-8382-1-git-send-email-festevam@gmail.com>
 <6f984a9c-e6d3-fd0a-6719-fa9032d43d1d@cogentembedded.com> <CAOMZO5ABD9iasv67ehcpTzcjU-iD9=8vQ2vM7Gwc4-v9pnUt-Q@mail.gmail.com>
 <f4cdcb4b-feac-5106-8068-e694dbd3b4e6@cogentembedded.com> <CAOMZO5BycGHNocULcScDczRoEvbQqjnRZTDrNAw7=+zpadSOSA@mail.gmail.com>
 <8f6ca18a-b95c-458d-c19b-bf0186ff96e7@cogentembedded.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: "David S. Miller" <davem@davemloft.net>,
        Andrew Lunn <andrew@lunn.ch>,
        Florian Fainelli <f.fainelli@gmail.com>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        Fabio Estevam <fabio.estevam@nxp.com>
To: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ua0-f176.google.com ([209.85.217.176]:34586 "EHLO
        mail-ua0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751439AbdGRNJX (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 18 Jul 2017 09:09:23 -0400
Received: by mail-ua0-f176.google.com with SMTP id z22so22452183uah.1
        for <netdev@vger.kernel.org>; Tue, 18 Jul 2017 06:09:22 -0700 (PDT)
In-Reply-To: <8f6ca18a-b95c-458d-c19b-bf0186ff96e7@cogentembedded.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jul 18, 2017 at 10:02 AM, Sergei Shtylyov
<sergei.shtylyov@cogentembedded.com> wrote:

>    No, it does -- devm_gpiod_get_optinal() will return NULL in that case,
> bus->reset_gpio will remanin NULL, and you're removing the NULL checks
> around the gpiod_set_value_cansleep() calls. Perhaps it's the problem in the
> GPIO support though...

It is perfectly fine to call gpiod_set_value_cansleep() with a NULL
gpio descriptor.

Please take a look at drivers/gpio/gpiolib.c:

gpiod_set_value_cansleep() calls VALIDATE_DESC_VOID

Then if you look at the definition of VALIDATE_DESC_VOID you will see
that it does a NULL check on desc and returns immediately if it is
NULL.

This means we are safe here :-)
