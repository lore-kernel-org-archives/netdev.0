From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: Minimum MTU Mess
Date: Wed, 7 Sep 2016 22:31:12 +0200
Message-ID: <20160907203112.GA26445@lunn.ch>
References: <20160902170742.GA17677@redhat.com>
 <20160906.165529.496766310703537877.davem@davemloft.net>
 <20160907195356.GX33916@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Jarod Wilson <jarod@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:37996 "EHLO vps0.lunn.ch"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751372AbcIGUbR (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 7 Sep 2016 16:31:17 -0400
Content-Disposition: inline
In-Reply-To: <20160907195356.GX33916@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Jarod

> -	/*	MTU must be positive.	 */
> -	if (new_mtu < 0)
> +	if (new_mtu < dev->min_mtu) {
> +		netdev_err(dev, "Invalid MTU %d requested, hw min %d\n",
> +			   new_mtu, dev->min_mtu);
>  		return -EINVAL;
> +	}
> +
> +	if (new_mtu > dev->max_mtu) {
> +		netdev_err(dev, "Invalid MTU %d requested, hw max %d\n",
> +			   new_mtu, dev->min_mtu);
> +		return -EINVAL;
> +	}

I doubt you can make such a big change like this in one go. Can you
really guarantee all interfaces, of what ever type, will have some
value for dev->min_mtu and dev->max_mtu? What may fly is something
more like:

> +	if (dev->max_mtu && new_mtu > dev->max_mtu) {
> +		netdev_err(dev, "Invalid MTU %d requested, hw max %d\n",
> +			   new_mtu, dev->min_mtu);
> +		return -EINVAL;
> +	}

Maybe in a few cycles you can add a WARN_ON(!dev->max_mtu), and a few
cycles after that go with (new_mtu > dev->max_mtu).

  Andrew
