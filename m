From: David Miller <davem@davemloft.net>
Subject: Re: [RFT PATCH 1/2] net: dsa: mv88e6xxx: Add EEE support
Date: Mon, 23 Feb 2015 17:19:47 -0500 (EST)
Message-ID: <20150223.171947.1925831716804927748.davem@davemloft.net>
References: <1424708770-3135-1-git-send-email-linux@roeck-us.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, andrew@lunn.ch, f.fainelli@gmail.com,
	linux-kernel@vger.kernel.org
To: linux@roeck-us.net
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1424708770-3135-1-git-send-email-linux@roeck-us.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Guenter Roeck <linux@roeck-us.net>
Date: Mon, 23 Feb 2015 08:26:09 -0800

> +	/* Don't call phy_init_eee for now. It fails if the link is down,
> +	 * but that should not really be a reason to fail configuration.
> +	 */

I think there is some confusion about phy_init_eee().

You invoke it after a link has been established.  Because programming
the MDIO registers that turn on EEE can only be done if the link
is configured in a certain way.

If you look at stmmac, it invokes phy_init_eee() via it's adjust_link
callback passed to phy_connect().  This is basically how I would
expect it to be used, in that any time a link parameter changes we
rerun phy_init_eee() to check the link partner registers, duplex
state, etc.

SXGBE on the other hand seems to not be using phy_init_eee() properly,
it only invokes it once per device open and that makes no sense at all
because then you're stuck with the eee state resulting from the link
state at open time.
