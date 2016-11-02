From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH net-next 07/11] net: dsa: mv88e6xxx: add port link setter
Date: Thu, 3 Nov 2016 00:05:17 +0100
Message-ID: <20161102230517.GK384@lunn.ch>
References: <20161101032023.32762-1-vivien.didelot@savoirfairelinux.com>
 <20161101032023.32762-8-vivien.didelot@savoirfairelinux.com>
 <20161101094313.GB2802@lunn.ch>
 <87shra4rlu.fsf@ketchup.i-did-not-set--mail-host-address--so-tickle-me>
 <20161102091629.GA384@lunn.ch>
 <8760o55x9j.fsf@ketchup.i-did-not-set--mail-host-address--so-tickle-me>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        kernel@savoirfairelinux.com,
        "David S. Miller" <davem@davemloft.net>,
        Florian Fainelli <f.fainelli@gmail.com>
To: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <8760o55x9j.fsf@ketchup.i-did-not-set--mail-host-address--so-tickle-me>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> Do you expect to return an error if adjust_link is called with
> phydev->duplex == DUPLEX_UNKNOWN, or, do you expect to fallback to
> unforced duplex when setting such value?

ethtool(1) itself does not allow you to specify "unknown". It only
allows "full" or "half". So passing DUPLEX_UNKNOWN means using the API
directly. The core ethtool code does not sanity check the request, so
will pass on DUPLEX_UNKNOWN to the drivers.

A quick search of the drivers, 99% seem to ignore DUPLEX_UNKNOWN. The
1% is bnx2x, which has:

        /* If received a request for an unknown duplex, assume full*/
        if (cmd->duplex == DUPLEX_UNKNOWN)
                cmd->duplex = DUPLEX_FULL;

I personally would return -EINVAL, since it is unclear what
DUPLEX_UNKNOWN means. It could be argued that falling back to Half is
correct, since failed autoneg generally results in 10/Half. Every
Ethernet can do that, where as a device needs to be 25 years or
younger to support Full :-)

	  Andrew
