From: Patrick McHardy <kaber@trash.net>
Subject: Re: v2: [PATCH 2/3] netdevice: Fix promiscuity and allmulti overflow
Date: Tue, 17 Jun 2008 14:59:46 +0200
Message-ID: <4857B542.6030703@trash.net>
References: <48562F45.3040302@cn.fujitsu.com> <48568125.4090500@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	NETDEV <netdev@vger.kernel.org>
To: Wang Chen <wangchen@cn.fujitsu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:63472 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755722AbYFQM7v (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Jun 2008 08:59:51 -0400
In-Reply-To: <48568125.4090500@cn.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Wang Chen wrote:
> +	if (dev->promiscuity == 0) {
> +		/*
> +		 * Avoid overflow.
> +		 * If inc causes overflow, untouch promisc and return error.
> +		 */
> +		if (inc < 0)
> +			dev->flags &= ~IFF_PROMISC;
> +		else {
> +			dev->promiscuity -= inc;
> +			printk(KERN_ERR "%s: promiscuity touches roof, "
> +				"set promiscuity failed, promiscuity feature "
> +				"of device will be broken.\n", dev->name);
> +			return -EOVERFLOW;
> +		}
> +	}

Assuming the caller does proper error handling, that printk is
not true.
