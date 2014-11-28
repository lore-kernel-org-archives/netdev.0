From: Roger Quadros <rogerq@ti.com>
Subject: Re: [PATCH v7 6/8] net: can: c_can: Disable pins when CAN interface
 is down
Date: Fri, 28 Nov 2014 11:22:12 +0200
Message-ID: <54783EC4.5000909@ti.com>
References: <1415371762-29885-1-git-send-email-rogerq@ti.com>	<1415371762-29885-7-git-send-email-rogerq@ti.com>	<5464CCFF.5010004@ti.com>	<5466225D.2070202@ti.com> <CACRpkdbVXPi7fNjGEzChayQ1KQg8h2R6sm0TNRsVOFJmAT=YMQ@mail.gmail.com> <54779564.7010309@pengutronix.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: <wg@grandegger.com>, Wolfram Sang <wsa@the-dreams.de>,
	Tony Lindgren <tony@atomide.com>,
	Thomas Gleixner <tglx@linutronix.de>,
	Mugunthan V N <mugunthanvnm@ti.com>,
	George Cherian <george.cherian@ti.com>,
	Felipe Balbi <balbi@ti.com>, Sekhar Nori <nsekhar@ti.com>,
	Nishanth Menon <nm@ti.com>,
	Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>,
	Linux-OMAP <linux-omap@vger.kernel.org>,
	<linux-can@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Marc Kleine-Budde <mkl@pengutronix.de>,
	Linus Walleij <linus.walleij@linaro.org>
Return-path: <linux-omap-owner@vger.kernel.org>
In-Reply-To: <54779564.7010309@pengutronix.de>
Sender: linux-omap-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 27/11/14 23:19, Marc Kleine-Budde wrote:
> On 11/27/2014 02:26 PM, Linus Walleij wrote:
>> On Fri, Nov 14, 2014 at 4:40 PM, Roger Quadros <rogerq@ti.com> wrote:
>>
>>> DRA7 CAN IP suffers from a problem which causes it to be prevented
>>> from fully turning OFF (i.e. stuck in transition) if the module was
>>> disabled while there was traffic on the CAN_RX line.
>>>
>>> To work around this issue we select the SLEEP pin state by default
>>> on probe and use the DEFAULT pin state on CAN up and back to the
>>> SLEEP pin state on CAN down.
>>>
>>> Signed-off-by: Roger Quadros <rogerq@ti.com>
>>
>> Reviewed-by: Linus Walleij <linus.walleij@linaro.org>
> 
> Thanks, however the patch is already upstream.
> 
>>
>> I see you figured it out all by yourselves :D
>>
>> (Sorry for being absent.)
>>
>>> +#include <linux/pinctrl/consumer.h>
>>> +       pinctrl_pm_select_default_state(dev->dev.parent);
>>> +       pinctrl_pm_select_sleep_state(dev->dev.parent);
>>> +       pinctrl_pm_select_sleep_state(dev->dev.parent);
>>
>> NB: in drivers/base/pinctrl.c:
>>
>> #ifdef CONFIG_PM
>>         /*
>>          * If power management is enabled, we also look for the optional
>>          * sleep and idle pin states, with semantics as defined in
>>          * <linux/pinctrl/pinctrl-state.h>
>>          */
>>         dev->pins->sleep_state = pinctrl_lookup_state(dev->pins->p,
>>                                         PINCTRL_STATE_SLEEP);
>>
>> So if these states are necessary for the driver to work, put
>> depends on PM or select PM in the Kconfig.
> 
> Roger, you can prepare a patch, if needed.

As pinctrl sleep is an optional driver feature we don't need to do any changes.
For the DRA7 specific case, the platform configs ensure that PM is enabled.

cheers,
-roger
