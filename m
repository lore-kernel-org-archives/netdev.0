From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: Re: [PATCH net-next 3/6] net: dsa: mv88e6xxx: add a software reset op
Date: Fri, 02 Dec 2016 12:30:04 -0500
Message-ID: <87fum66xyb.fsf@ketchup.i-did-not-set--mail-host-address--so-tickle-me>
References: <20161130225930.25510-1-vivien.didelot@savoirfairelinux.com> <20161130225930.25510-4-vivien.didelot@savoirfairelinux.com> <20161130232633.GS21645@lunn.ch> <87vav3gz67.fsf@ketchup.i-did-not-set--mail-host-address--so-tickle-me> <20161202154342.GL21887@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        kernel@savoirfairelinux.com,
        "David S. Miller" <davem@davemloft.net>,
        Florian Fainelli <f.fainelli@gmail.com>
To: Andrew Lunn <andrew@lunn.ch>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20161202154342.GL21887@lunn.ch>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Andrew,

Andrew Lunn <andrew@lunn.ch> writes:

> +	/* Switch Software Reset */
> +	int (*g1_reset)(struct mv88e6xxx_chip *chip);
> +
>
> We have a collection of function pointers with port_ prefix, another
> collection with stats_, and a third with ppu_, etc. And then we have
> some which do not fit a specific category. Those i have prefixed with
> g1_ or g2_. I think we should have some prefix, and that is my
> suggestion.

I disagree. There's only one entry point to issue a switch software
reset, so .reset is enough.

I use this opportunity to give a bit of details about mv88e6xxx/ so that
things get written down at least once somewhere:

global1.c implements accessors to "Global 1 Registers" features and are
prefixed with mv88e6xxx_g1_; port.c implements accessors to "Port
Registers" features and are prefixed with mv88e6xxx_port_, and so
on. (where xxx can be a model if there's conflict due to a redefinition
of the same register)

If a feature is not present or if there's more than one way to access
it, these accessors are bundled in the per-chip mv88e6xxx_ops structure
for disambiguation.

chip.c implements support for a single chip by aggregating and nicely
wrapping these operations. It provides a generic API for Marvell
switches, used to implement net/dsa routines.

  Here's a couple of example. Setting a switch MAC can be done in Global
  1, or Global 2 depending on the model. Thus .set_switch_mac can be
  mv88e6xxx_g1_set_switch_mac or mv88e6xxx_g2_set_switch_mac.

  Setting the port's speed is always in the same Port register, but its
  layout varies with the model. Thus .port_set_speed can be
  mv88e6185_port_set_speed or mv88e6352_port_set_speed.

Thanks,

        Vivien
