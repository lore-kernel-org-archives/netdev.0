From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH v2 2/6] net: phy: broadcom: Add BCM54810 PHY entry
Date: Sat, 29 Oct 2016 10:18:39 +0200
Message-ID: <20161029081839.GA32579@lunn.ch>
References: <1477688219-3871-1-git-send-email-jon.mason@broadcom.com>
 <1477688219-3871-3-git-send-email-jon.mason@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>,
        Rob Herring <robh+dt@kernel.org>,
        Mark Rutland <mark.rutland@arm.com>,
        Florian Fainelli <f.fainelli@gmail.com>,
        devicetree@vger.kernel.org, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org,
        bcm-kernel-feedback-list@broadcom.com, rafal@milecki.pl,
        linux-arm-kernel@lists.infradead.org
To: Jon Mason <jon.mason@broadcom.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1477688219-3871-3-git-send-email-jon.mason@broadcom.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Oct 28, 2016 at 04:56:55PM -0400, Jon Mason wrote:
> The BCM54810 PHY requires some semi-unique configuration, which results
> in some additional configuration in addition to the standard config.
> Also, some users of the BCM54810 require the PHY lanes to be swapped.
> Since there is no way to detect this, add a device tree query to see if
> it is applicable.
> 
> Inspired-by: Vikas Soni <vsoni@broadcom.com>
> Signed-off-by: Jon Mason <jon.mason@broadcom.com>
> ---
>  drivers/net/phy/Kconfig    |  2 +-
>  drivers/net/phy/broadcom.c | 58 +++++++++++++++++++++++++++++++++++++++++++++-
>  include/linux/brcmphy.h    | 10 ++++++++

Hi Jon

The binding documentation is missing.

> +	if (of_property_read_bool(np, "brcm,enet-phy-lane-swap")) {
> +		/* Lane Swap - Undocumented register...magic! */
> +		ret = bcm_phy_write_exp(phydev, MII_BCM54XX_EXP_SEL_ER + 0x9,
> +					0x11B);
> +		if (ret < 0)
> +			return ret;
> +	}
> +

I wounder if this property could be made generic? What exactly are you
swapping? Rx and Tx lanes? Maybe we should add it to phy.txt?

	  Andrew
