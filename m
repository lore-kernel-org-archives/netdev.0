From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [RFC PATCH net-next 3/3] net/mlx5e: Expose link down reason to
 ethtool
Date: Wed, 21 Jun 2017 16:03:18 +0200
Message-ID: <20170621140318.GD27585@lunn.ch>
References: <1498050286-17141-1-git-send-email-galp@mellanox.com>
 <1498050286-17141-4-git-send-email-galp@mellanox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>,
        "John W. Linville" <linville@tuxdriver.com>,
        Saeed Mahameed <saeedm@mellanox.com>,
        Vidya Sagar Ravipati <vidya@cumulusnetworks.com>,
        Jiri Pirko <jiri@mellanox.com>,
        David Decotigny <decot@googlers.com>, kernel-team@fb.com
To: Gal Pressman <galp@mellanox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:58673 "EHLO vps0.lunn.ch"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751042AbdFUODV (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 21 Jun 2017 10:03:21 -0400
Content-Disposition: inline
In-Reply-To: <1498050286-17141-4-git-send-email-galp@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> +static int mlx5e_get_link_down_reason(struct net_device *netdev,
> +				      struct ethtool_link_down_reason *ldr)
> +{
> +	struct mlx5e_priv *priv = netdev_priv(netdev);
> +	u16 monitor_opcode;
> +	int err;
> +
> +	if (!netif_running(netdev)) {
> +		ldr->reason = ETHTOOL_LINK_NETDEV_CARRIER_DOWN;
> +		return 0;
> +	}

This is generic, will work for any interface. The same is true for
ADMIN_DOWN. Either it is not required at all, since the information is
available via other means, or it should be in the core.

	  Andrew
