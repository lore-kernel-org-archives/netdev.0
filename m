From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [RFC PATCH] net: phy: Don't miss phy_suspend() on PHY_HALTED for
 PHYs with interrupts
Date: Wed, 15 Mar 2017 15:08:11 +0100
Message-ID: <20170315140811.GD21021@lunn.ch>
References: <1489585887-8683-1-git-send-email-rogerq@ti.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: f.fainelli@gmail.com, davem@davemloft.net, kyle.roeschley@ni.com,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Roger Quadros <rogerq@ti.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1489585887-8683-1-git-send-email-rogerq@ti.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Mar 15, 2017 at 03:51:27PM +0200, Roger Quadros wrote:
> Since commit 3c293f4e08b5 ("net: phy: Trigger state machine on state change and not polling.")
> phy_suspend() doesn't get called as part of phy_stop() for PHYs using
> interrupts because the phy state machine is never triggered after a phy_stop().
> 
> Explicitly trigger the PHY state machine so that it can
> see the new PHY state (HALTED) and suspend the PHY.
> 
> Signed-off-by: Roger Quadros <rogerq@ti.com>

Hi Roger

This seems sensible. It mirrors what phy_start() does.

Reviewed-by: Andrew Lunn <andrew@lunn.ch>

It does however lead to a follow up question. Are there other places
phydev->state is changed and it is missing a phy_trigger_machine()?

	      Andrew
