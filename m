From: Tony Lindgren <tony@atomide.com>
Subject: Re: [PATCH 3/3 v2] net: smsc911x: add wake-up event interrupt support
Date: Fri, 26 Aug 2016 07:40:21 -0700
Message-ID: <20160826144021.2so6ekrx7r26lt2s@atomide.com>
References: <1472043582-7653-1-git-send-email-linus.walleij@linaro.org>
 <1472043582-7653-3-git-send-email-linus.walleij@linaro.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, "David S . Miller" <davem@davemloft.net>,
        Steve Glendinning <steve.glendinning@smsc.com>,
        Guenter Roeck <linux@roeck-us.net>,
        Jeremy Linton <jeremy.linton@arm.com>,
        Kamlakant Patel <kamlakant.patel@broadcom.com>,
        Pavel Fedin <p.fedin@samsung.com>,
        Sudeep Holla <sudeep.holla@arm.com>,
        Florian Fainelli <f.fainelli@gmail.com>
To: Linus Walleij <linus.walleij@linaro.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from muru.com ([72.249.23.125]:46358 "EHLO muru.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751640AbcHZOkZ (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 26 Aug 2016 10:40:25 -0400
Content-Disposition: inline
In-Reply-To: <1472043582-7653-3-git-send-email-linus.walleij@linaro.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

* Linus Walleij <linus.walleij@linaro.org> [160824 06:00]:
> The SMSC911x have a line out of the chip called "PME",
> Power Management Event. When connected to an asynchronous
> interrupt controller this is able to wake the system up
> from sleep in response to certain network events.
> 
> This is the first attempt to support this in the Linux
> driver: the Qualcomm APQ8060 Dragonboard has this line
> routed to a GPIO line on the primary SoC padring, and as
> such it can be armed as a wakeup interrupt.
> 
> The patch is inspired by the wakeup code in the RTC
> subsystem.
> 
> The code looks for an additional interrupt - apart from the
> ordinary device interrupt - and in case that is present,
> we register an interrupt handler to respons to this,
> and flag the device and this interrupt as a wakeup.
> 
> Cc: Sudeep Holla <sudeep.holla@arm.com>
> Cc: Tony Lindgren <tony@atomide.com>
> Cc: Florian Fainelli <f.fainelli@gmail.com>
> Signed-off-by: Linus Walleij <linus.walleij@linaro.org>
> ---
> ChangeLog v1->v2:
> - Call pm_wakeup_event() in the wakeup IRQ thread to
>   account for the wakeup event.
> - Drop the enable/disable_irq_wake() calls from suspend/resume:
>   this is handled from the irq core when you call
>   dev_pm_set_wake_irq() as we do.

Looks OK to me:

Acked-by: Tony Lindgren <tony@atomide.com>
