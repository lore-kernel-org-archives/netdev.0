From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH] phy: marvell: Fix reg-init bug on 88E1510
Date: Sun, 14 Feb 2016 21:48:22 +0100
Message-ID: <20160214204822.GB4802@lunn.ch>
References: <1455481885-11395-1-git-send-email-clemens.gruber@pqgruber.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, Florian Fainelli <f.fainelli@gmail.com>,
	linux-kernel@vger.kernel.org,
	"David S . Miller" <davem@davemloft.net>
To: Clemens Gruber <clemens.gruber@pqgruber.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1455481885-11395-1-git-send-email-clemens.gruber@pqgruber.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sun, Feb 14, 2016 at 09:31:25PM +0100, Clemens Gruber wrote:
> The function marvell_of_reg_init was called too late, in
> m88e1510_config_aneg. This function was not reached, due to the phy
> state machine being stuck at waiting for interrupts (which were not
> enabled and off by default on the 88E1510)
> It lead to the ethernet link not coming up at boot.
> 
> This commit moves the call of marvell_of_reg_init to config_init.
> Now, a marvell,reg-init option to enable PHY interrupts on pin LED[2] is
> set early on and the phy state machine does not get stuck anymore.
> Tested on i.MX6Q boards with Marvell 88E1510 PHYs.

This looks like a good fix for you board. But maybe we should look at
the bigger picture. How about calling your new 

> +static int m88e1510_config_init(struct phy_device *phydev)
> +{
> +	int err;
> +
> +	err = marvell_of_reg_init(phydev);
> +	if (err < 0)
> +		return err;
> +
> +	return 0;
> +}

marvell_config_init() and adding it to all PHYs which don't have a
specific config_init function.

We then get more consistent behaviour across Marvell PHYs.

   Andrew
