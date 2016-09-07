From: Linus Walleij <linus.walleij@linaro.org>
Subject: Re: [PATCH 2/3 v2] net: smsc911x: request and deassert optional RESET GPIO
Date: Wed, 7 Sep 2016 11:59:35 +0200
Message-ID: <CACRpkdbd=qby2AymyNm7Mm7F2HMHGJ_rpbO6uHD8JVr+Up51iA@mail.gmail.com>
References: <1472043582-7653-1-git-send-email-linus.walleij@linaro.org>
 <1472043582-7653-2-git-send-email-linus.walleij@linaro.org> <722bf13c-ebce-2a33-a5b7-c654c515ac3c@arm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "David S . Miller" <davem@davemloft.net>,
        Steve Glendinning <steve.glendinning@smsc.com>,
        Guenter Roeck <linux@roeck-us.net>,
        Kamlakant Patel <kamlakant.patel@broadcom.com>,
        Pavel Fedin <p.fedin@samsung.com>
To: Jeremy Linton <jeremy.linton@arm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f48.google.com ([209.85.218.48]:33009 "EHLO
        mail-oi0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753905AbcIGJ7h (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 7 Sep 2016 05:59:37 -0400
Received: by mail-oi0-f48.google.com with SMTP id y2so18398419oie.0
        for <netdev@vger.kernel.org>; Wed, 07 Sep 2016 02:59:37 -0700 (PDT)
In-Reply-To: <722bf13c-ebce-2a33-a5b7-c654c515ac3c@arm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Aug 31, 2016 at 5:08 PM, Jeremy Linton <jeremy.linton@arm.com> wrote:
> On 08/24/2016 07:59 AM, Linus Walleij wrote:
>>
>> On some systems (such as the Qualcomm APQ8060 Dragonboard) the
>> RESET signal of the SMSC911x is not pulled up by a resistor but
>> connected to a GPIO line, so that the operating system must
>> explicitly deassert RESET before use.
>>
>> Support this in the SMSC911x driver so this ethernet connector
>> can be used on such targets.
>
> Hmm, at least in our hardware case AFAIK (juno/lan9118) the hardware reset
> line on the lan9118 is active low, but the chip itself is documented as
> having internal pullups so that it may be left unconnected.

I guess this is only a comment about the contents of the commit message,
I'll check it up and augment.

This:

+       /* Request optional RESET GPIO */
+       pdata->reset_gpiod = devm_gpiod_get_optional(&pdev->dev,
+                                                    "reset",
+                                                    GPIOD_OUT_LOW);

Is Linux-internal way of saying "deassert the RESET" line, it does
*not* mean "drive it low".

GPIO lines are configured in the device tree for the platform in
question, and what you say about it being active low is true, and
that is why the device tree for the DragonBoard looks like so:

+ reset-gpios = <&tlmm 30 GPIO_ACTIVE_LOW>;

Flagging it active low in the device tree make sure it is driven
high by the statement in the code.

> Beyond that, is it not possible for the firmware to get the reset pin in the
> correct configuration, so that linux doesn't have to mess with it?

That is always possible, and in that case you simply do not specify
the GPIO line for RESET. But this firmware for the APQ8060 DragonBoard
does not do it and Qualcomm is not going to update it, and I need
to deal with it.

Yours,
Linus Walleij
