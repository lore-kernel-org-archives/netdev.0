From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH v4 net-next 04/10] net/ncsi: Ethtool operation to get
 NCSI topology
Date: Thu, 4 May 2017 02:49:33 +0200
Message-ID: <20170504004933.GP8029@lunn.ch>
References: <1493786681-27468-1-git-send-email-gwshan@linux.vnet.ibm.com>
 <1493786681-27468-5-git-send-email-gwshan@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, joe@perches.com, kubakici@wp.pl,
        f.fainelli@gmail.com, davem@davemloft.net
To: Gavin Shan <gwshan@linux.vnet.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:50021 "EHLO vps0.lunn.ch"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752242AbdEDAth (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 3 May 2017 20:49:37 -0400
Content-Disposition: inline
In-Reply-To: <1493786681-27468-5-git-send-email-gwshan@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> +void ncsi_ethtool_register_dev(struct net_device *dev)
> +{
> +	struct ethtool_ops *ops;
> +
> +	ops = (struct ethtool_ops *)(dev->ethtool_ops);

Why do you need the cast here?

Ah, is it because net_device has:

          const struct ethtool_ops *ethtool_ops;

i.e. you are casting off the const.

> +	if (!ops)
> +		return;
> +
> +	ops->get_ncsi_channels = ncsi_get_channels;

and here you modify it. Which is going to blow up, because it will be
in a read only segment and should throw an opps when you write to it?

You need to export ncsi_get_channels, and let the underlying driver
add it to its own ethtool_ops.

   Andrew
