From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH net-next 0/2] Move hwmon support out of switch and into
 PHYs.
Date: Wed, 11 Jan 2017 18:37:41 +0100
Message-ID: <20170111173741.GB13033@lunn.ch>
References: <1484096604-25033-1-git-send-email-andrew@lunn.ch>
 <87vatljzlo.fsf@weeman.i-did-not-set--mail-host-address--so-tickle-me>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>,
        netdev <netdev@vger.kernel.org>,
        Florian Fainelli <f.fainelli@gmail.com>,
        Guenter Roeck <linux@roeck-us.net>
To: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:56450 "EHLO vps0.lunn.ch"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S934128AbdAKRh4 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 11 Jan 2017 12:37:56 -0500
Content-Disposition: inline
In-Reply-To: <87vatljzlo.fsf@weeman.i-did-not-set--mail-host-address--so-tickle-me>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jan 11, 2017 at 12:06:11PM -0500, Vivien Didelot wrote:
> Hi Andrew,
> 
> Andrew Lunn <andrew@lunn.ch> writes:
> 
> > Marvell Ethernet switches contain temperature sensors. They are inside
> > the embedded PHYs. Move the code into the PHY driver, so that discrete
> > PHY drivers also export there temperature sensor.
> 
> This message is not correct. The Marvell Ethernet switches contain only
> one temperature sensor for the entire chip (please adjust the cover
> letter and commit messages when you respin.)

Agreed.

> The temperature and threshold are accessed through the embedded PHY
> registers of any port, as long as the port is not disabled.

This is not correct. Each PHY has its own threshold registers. They
can be different, even if they are applied to one shared sensor.  One
PHY can be in alarm state, while others are not, due to different
thresholds.

> Even unlikely to be used, an interrupt can be generated when the
> temperature exceeds a certain threshold. It should be enabled on only
> one port at a time since there is only one temperature sensor.

Actually, since each PHY can have a different threshold, it would in
theory be possible to have different PHYs generating interrupts at
different thresholds.

However, at the moment, there is no code to enable interrupts for
temperature alarms. I also don't see any need to add such code, since
there is nowhere in HWMON to actively report such an alarm condition.

There is potentially an issue sometime down the road, if we were to
enable the temperature threshold interrupt. It is not clear what
happens if two PHYs have the same threshold conditions and this
threshold is crossed. Do all PHYs trigger an interrupt? Does only one?
Do none? I would prefer investigating and solving such issues if and
when it is decided to enable the interrupt.

> To sum up briefly, the temperature chip is physically inside the switch
> chip, but its access is via the embedded PHYs of the switch.

There is one temperature sensor in the chip, which each embedded PHY
shares for reporting the current temperature. It appears that
everything but the sensor is duplicated in each embedded PHY.

       Andrew
