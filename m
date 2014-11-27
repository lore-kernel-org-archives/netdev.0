From: Linus Walleij <linus.walleij@linaro.org>
Subject: Re: [PATCH v7 6/8] net: can: c_can: Disable pins when CAN interface
 is down
Date: Thu, 27 Nov 2014 14:26:31 +0100
Message-ID: <CACRpkdbVXPi7fNjGEzChayQ1KQg8h2R6sm0TNRsVOFJmAT=YMQ@mail.gmail.com>
References: <1415371762-29885-1-git-send-email-rogerq@ti.com>
	<1415371762-29885-7-git-send-email-rogerq@ti.com>
	<5464CCFF.5010004@ti.com>
	<5466225D.2070202@ti.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: wg@grandegger.com, Marc Kleine-Budde <mkl@pengutronix.de>,
	Wolfram Sang <wsa@the-dreams.de>,
	Tony Lindgren <tony@atomide.com>,
	Thomas Gleixner <tglx@linutronix.de>,
	Mugunthan V N <mugunthanvnm@ti.com>,
	George Cherian <george.cherian@ti.com>,
	Felipe Balbi <balbi@ti.com>, Sekhar Nori <nsekhar@ti.com>,
	Nishanth Menon <nm@ti.com>,
	Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>,
	Linux-OMAP <linux-omap@vger.kernel.org>,
	linux-can@vger.kernel.org,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Roger Quadros <rogerq@ti.com>
Return-path: <linux-can-owner@vger.kernel.org>
In-Reply-To: <5466225D.2070202@ti.com>
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Nov 14, 2014 at 4:40 PM, Roger Quadros <rogerq@ti.com> wrote:

> DRA7 CAN IP suffers from a problem which causes it to be prevented
> from fully turning OFF (i.e. stuck in transition) if the module was
> disabled while there was traffic on the CAN_RX line.
>
> To work around this issue we select the SLEEP pin state by default
> on probe and use the DEFAULT pin state on CAN up and back to the
> SLEEP pin state on CAN down.
>
> Signed-off-by: Roger Quadros <rogerq@ti.com>

Reviewed-by: Linus Walleij <linus.walleij@linaro.org>

I see you figured it out all by yourselves :D

(Sorry for being absent.)

> +#include <linux/pinctrl/consumer.h>
> +       pinctrl_pm_select_default_state(dev->dev.parent);
> +       pinctrl_pm_select_sleep_state(dev->dev.parent);
> +       pinctrl_pm_select_sleep_state(dev->dev.parent);

NB: in drivers/base/pinctrl.c:

#ifdef CONFIG_PM
        /*
         * If power management is enabled, we also look for the optional
         * sleep and idle pin states, with semantics as defined in
         * <linux/pinctrl/pinctrl-state.h>
         */
        dev->pins->sleep_state = pinctrl_lookup_state(dev->pins->p,
                                        PINCTRL_STATE_SLEEP);

So if these states are necessary for the driver to work, put
depends on PM or select PM in the Kconfig.

Yours,
Linus Walleij
