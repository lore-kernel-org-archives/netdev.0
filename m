From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH 10/13] ftgmac100: Add a reset task and use it for link
 changes
Date: Sun, 2 Apr 2017 20:42:37 +0200
Message-ID: <20170402184237.GB5189@lunn.ch>
References: <20170402033523.9482-1-benh@kernel.crashing.org>
 <20170402033523.9482-11-benh@kernel.crashing.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:43169 "EHLO vps0.lunn.ch"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1750996AbdDBSmi (ORCPT <rfc822;netdev@vger.kernel.org>);
        Sun, 2 Apr 2017 14:42:38 -0400
Content-Disposition: inline
In-Reply-To: <20170402033523.9482-11-benh@kernel.crashing.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> +static void ftgmac100_reset_task(struct work_struct *work)
> +{
> +	struct ftgmac100 *priv = container_of(work, struct ftgmac100,
> +					      reset_task);
> +	struct net_device *netdev = priv->netdev;
> +	int err;
> +
> +	netdev_dbg(netdev, "Resetting NIC...\n");
> +
> +	/* Block PHY polling */
> +	if (netdev->phydev)
> +		mutex_lock(&netdev->phydev->lock);
> +
> +	rtnl_lock();

Hi Ben

Have you run lockdep tests on this? I think it is normal to take the
rtnl lock first, then the phydev lock. Try some ethtool operations and
see if you get a splat.

Also, do you need to be worried about mdio operations? Do you need to
take that lock as well, since there might be other PHYs, or an
Ethernet switch on the bus?

    Andrew
