From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH 0/3] Control ethernet PHY LEDs via LED subsystem
Date: Thu, 24 Mar 2016 14:29:35 +0100
Message-ID: <20160324132935.GA15624@lunn.ch>
References: <1458755500-15571-1-git-send-email-vishalthanki@gmail.com>
 <20160323185006.GL5250@lunn.ch>
 <CAC3a_SCD6aMF=triCQDJrW9GQ3HOMMH9q_J9GEw56qrnwgFXKA@mail.gmail.com>
 <20160323211010.GF19953@lunn.ch>
 <CAC3a_SBjvQFT5XP2bH3TO_4wHnjZ3a3+XvfBy8StxQieEsavQQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Florian Fainelli <f.fainelli@gmail.com>,
	Matus Ujhelyi <ujhelyi.m@gmail.com>, netdev@vger.kernel.org
To: Vishal Thanki <vishalthanki@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:56054 "EHLO vps0.lunn.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750749AbcCXN3i (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 24 Mar 2016 09:29:38 -0400
Content-Disposition: inline
In-Reply-To: <CAC3a_SBjvQFT5XP2bH3TO_4wHnjZ3a3+XvfBy8StxQieEsavQQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Mar 23, 2016 at 10:24:45PM +0100, Vishal Thanki wrote:
> On Wed, Mar 23, 2016 at 10:10 PM, Andrew Lunn <andrew@lunn.ch> wrote:
> > On Wed, Mar 23, 2016 at 09:24:00PM +0100, Vishal Thanki wrote:
> >> Hi,
> >>
> >> > My suggestion was that the hardware needs to control the LEDs. You
> >> > have software doing it. You might be able to do this with the PHY
> >> > state machine for link. But activity is never going to be accepted if
> >> > software control.
> >> >
> >> > The LED trigger attached to an LED should be used to configure the
> >> > hardware to drive the LED as wanted.
> >> >
> >>
> >> The eth-phy-activity trigger uses the blink_set which I think uses the
> >> hardware acceleration if available. I am not sure how to handles LEDs
> >> which does not have hardware acceleration for this (eth-phy-activity)
> >> trigger.
> >
> > We want the LED to blink on activity, real packets coming in and
> > out. The PHY can do this, so let the PHY control the LED. In this
> > case, the trigger is just mechanism for the user to say what the LED
> > should be used for. The trigger is not itself controlling the LED, it
> > has no idea about packets coming and going.
> >
> 
> Yes, I understand that. But PHY can only control the LEDs attached to
> it directly. The at803x led driver configures the PHY to blink the
> activity LED based on traffic but I think it is not possible for PHY
> to control other LEDs in system, for example some other LEDs in system
> controlled only via GPIO. In such cases, putting PHY activity trigger
> on the GPIO LEDs would not make sense. Correct me if I am wrong.

Hi Vishal

All correct. Which is why i said in my original email, you need to
extend the LED core to associate triggers to LEDs. You can then
associate the eth-phy-activity trigger to only PHY leds which can
implement that functionality.

drivers/leds/led-triggers.c contains a global list
LIST_HEAD(trigger_list) which triggers get added to using
led_trigger_register(). You could add a second list to the
led_classdev structure, and add an led_trigger_register_to_led()
function which registers a trigger to a specific LED, on its own
trigger list. led_trigger_store() and led_trigger_show() would use
both lists.

     Andrew
