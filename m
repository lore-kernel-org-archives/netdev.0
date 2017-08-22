From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH net-next 3/3 v7] drivers: net: ethernet: qualcomm: rmnet:
 Initial implementation
Date: Tue, 22 Aug 2017 03:17:48 +0200
Message-ID: <20170822011748.GB24555@lunn.ch>
References: <1503355019-12236-1-git-send-email-subashab@codeaurora.org>
 <1503355019-12236-4-git-send-email-subashab@codeaurora.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, davem@davemloft.net,
        fengguang.wu@intel.com, dcbw@redhat.com, jiri@resnulli.us,
        stephen@networkplumber.org, David.Laight@ACULAB.COM,
        marcel@holtmann.org
To: Subash Abhinov Kasiviswanathan <subashab@codeaurora.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:38576 "EHLO vps0.lunn.ch"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1754342AbdHVBRx (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 21 Aug 2017 21:17:53 -0400
Content-Disposition: inline
In-Reply-To: <1503355019-12236-4-git-send-email-subashab@codeaurora.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> +static int rmnet_unregister_real_device(struct net_device *real_dev)
> +{
> +	struct rmnet_real_dev_info *rdinfo;
> +	struct list_head *iter;
> +
> +	ASSERT_RTNL();
> +
> +	if (!rmnet_is_real_dev_registered(real_dev) ||
> +	    netdev_lower_get_next(real_dev, &iter))
> +		return -EINVAL;
> +
> +	rdinfo = __rmnet_get_real_dev_info(real_dev);
> +	kfree(rdinfo);
> +
> +	netdev_rx_handler_unregister(real_dev);
> +
> +	/* release reference on real_dev */
> +	dev_put(real_dev);
> +
> +	netdev_info(real_dev, "Removed from rmnet\n");

I would probably turn all your netdev_info()s into netdev_dbg()s.  You
seem to be spamming the kernel log quite a bit.

  Andrew
