From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH 1/4] net: phy: Add Edge-rate driver for Microsemi PHYs.
Date: Wed, 24 Aug 2016 14:59:34 +0200
Message-ID: <20160824125934.GC13406@lunn.ch>
References: <646450A91FAED74E85C6E9C4D6E936A145336681@avsrvexchmbx1.microsemi.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "f.fainelli@gmail.com" <f.fainelli@gmail.com>,
        Allan Nielsen <Allan.Nielsen@microsemi.com>
To: Raju Lakkaraju <Raju.Lakkaraju@microsemi.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:43272 "EHLO vps0.lunn.ch"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1753210AbcHXM7h (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 24 Aug 2016 08:59:37 -0400
Content-Disposition: inline
In-Reply-To: <646450A91FAED74E85C6E9C4D6E936A145336681@avsrvexchmbx1.microsemi.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Aug 24, 2016 at 12:20:03PM +0000, Raju Lakkaraju wrote:
> From: Nagaraju Lakkaraju <Raju.Lakkaraju@microsemi.com>
> 
> Edge rate control support will be added for VSC 85xx Microsemi PHYs.

> diff --git a/include/linux/phy.h b/include/linux/phy.h
> index 2d24b28..8ec4c09 100644
> --- a/include/linux/phy.h
> +++ b/include/linux/phy.h
> @@ -586,6 +586,8 @@ struct phy_driver {
>         void (*get_strings)(struct phy_device *dev, u8 *data);
>         void (*get_stats)(struct phy_device *dev,
>                           struct ethtool_stats *stats, u64 *data);
> +       int (*phy_features_set)(struct phy_device *dev);
> +       int (*phy_features_get)(struct phy_device *dev);
>  };

Now we need the missing cover note what should be in 0/4.  What is the
big picture? How are these two functions supposed to be used? Is there
going to be a user space API via netlink? Should the MAC driver
somehow call these functions? Are you going to extend the phylib with
code to call these?

Those are all general questions for these two functions.

Now specifically for edge control, why did you decide not to use
device tree? Both the micrel and renesas phy driver uses device tree
for skew control. You need to explain why you need to do something
different to other drivers.

	  Thanks
		Andrew
