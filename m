From: Clemens Gruber <clemens.gruber@pqgruber.com>
Subject: Re: [PATCH] phy: marvell: remove LED config override
Date: Fri, 10 Jun 2016 22:52:11 +0200
Message-ID: <20160610205211.GA14243@archie.localdomain>
References: <20160610174252.14017-1-clemens.gruber@pqgruber.com>
 <20160610183857.GF2338@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, Florian Fainelli <f.fainelli@gmail.com>,
	linux-kernel@vger.kernel.org,
	"David S . Miller" <davem@davemloft.net>,
	Sergei Poselenov <sposelenov@emcraft.com>
To: Andrew Lunn <andrew@lunn.ch>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20160610183857.GF2338@lunn.ch>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Andrew,

On Fri, Jun 10, 2016 at 08:38:57PM +0200, Andrew Lunn wrote:
> On Fri, Jun 10, 2016 at 07:42:52PM +0200, Clemens Gruber wrote:
> > Configuring the PHY LED registers for the Marvell 88E1510 and others is
> > not possible, because regardless of the values in marvell,reg-init, it
> > is later overridden in m88e1121_config_aneg with a non-standard default.
> > 
> > This became visible after we moved the call of marvell_of_reg_init in
> > commit 79be1a1c9090 ("phy: marvell: Fix and unify reg-init behavior").
> > Moving it to _config_init was necessary due to the PHY state machine
> > getting stuck if the PHY interrupts were not enabled early on.
> > As that default LED configuration is set in _config_aneg, it overrides
> > the marvell,reg-init configuration from the device tree.
> > 
> > This patch removes this override and allows the user to again set the
> > PHY LED configuration through marvell,reg-init or if that does not
> > exist, keep the original defaults as documented in the datasheet.
> 
> That override code exists for a reason. I don't like just removing it
> without understanding why it is there. Sergei Poselenov added it as
> part of the 1121 support. Maybe he knows why it is there?

Maybe because he needed that special LED configuration (LED[0] .. Link,
LED[1] .. Activity) on his board?
On my board it's LED[0] as Activity and LED[1] as Link LED.

We could move that 0x30 LED configuration to .config_init instead of
.config_aneg, so that if nobody configures it with marvell,reg-init, the
behavior does not change. I'd have to create a new .config_init function
for the 1121, 1318 and 1510.

Would you prefer that?

(I thought it would be good to be consistent with the defaults mentioned
in the datasheet, but being backwards-compatible is probably more
important, you are right)

Regards,
Clemens
