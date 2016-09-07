From: Jeremy Linton <jeremy.linton@arm.com>
Subject: Re: [PATCH 2/2 v3] net: smsc911x: request and deassert optional RESET
 GPIO
Date: Wed, 7 Sep 2016 18:11:11 -0500
Message-ID: <4e88c084-1cae-49ac-c2f0-daf8363f7c35@arm.com>
References: <1473256422-14012-1-git-send-email-linus.walleij@linaro.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Guenter Roeck <linux@roeck-us.net>,
        Kamlakant Patel <kamlakant.patel@broadcom.com>,
        Pavel Fedin <p.fedin@samsung.com>
To: Linus Walleij <linus.walleij@linaro.org>, netdev@vger.kernel.org,
        "David S . Miller" <davem@davemloft.net>,
        Steve Glendinning <steve.glendinning@shawell.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from foss.arm.com ([217.140.101.70]:60294 "EHLO foss.arm.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1750976AbcIGXLO (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 7 Sep 2016 19:11:14 -0400
In-Reply-To: <1473256422-14012-1-git-send-email-linus.walleij@linaro.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

On 09/07/2016 08:53 AM, Linus Walleij wrote:
> On some systems (such as the Qualcomm APQ8060 Dragonboard) the
> RESET signal of the SMSC911x is not pulled up by a resistor (or
> the internal pull-up that will pull it up if the pin is not
> even connected) but instead connected to a GPIO line, so that
> the operating system must explicitly deassert RESET before use.
>
> Support this in the SMSC911x driver so this ethernet connector
> can be used on such targets.
>
> Notice that we request the line to go logical low (deassert)
> whilst the line on the actual component is active low. This
> is managed in the respective hardware description when
> specifying the GPIO line with e.g. device tree or ACPI. With
> device tree it looks like this in one case:
>
>   reset-gpios = <&tlmm 30 GPIO_ACTIVE_LOW>;
>
> Which means that logically requesting the RESET line to be
> deasserted will result in the line being driven high, taking
> the device out of reset.
>
> Cc: Jeremy Linton <jeremy.linton@arm.com>
> Signed-off-by: Linus Walleij <linus.walleij@linaro.org>

Thanks for clarifying the GPIO_ACTIVE_LOW state on this pin. I've 
reviewed this patch, and tested that it doesn't have any affect on a 
JunoR2 (ACPI or DT) system. I've got some personal reservations about 
making changes for a single board that might better be handled in 
firmware. But, I don't think those should be an excuse to keep that 
hardware from working. Particularly since this is a fairly trivial change.

So FWIW,

Reviewed-by: Jeremy Linton <jeremy.linton@arm.com>


Thanks,
