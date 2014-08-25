From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] net: Functions to report space available in
 device TX queues
Date: Sun, 24 Aug 2014 22:35:29 -0700 (PDT)
Message-ID: <20140824.223529.704627469513160252.davem@davemloft.net>
References: <alpine.DEB.2.02.1408241312500.30395@tomh.mtv.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: therbert@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:54168 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752462AbaHYFfb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 25 Aug 2014 01:35:31 -0400
In-Reply-To: <alpine.DEB.2.02.1408241312500.30395@tomh.mtv.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Tom Herbert <therbert@google.com>
Date: Sun, 24 Aug 2014 13:19:47 -0700 (PDT)

> +/**
> + *	netdev_avail_queue - report how much space is availble for xmit
> + *	@dev: network device
> + *
> + *	Report the amount of space available in the TX queue in terms of
> + *	number of bytes. This returns the number of bytes avaiable per
> + *	DQL. This function may be called without taking the txlock on
> + *	the device, however in that case the result should be taken as
> + *	a (strong) hint.
> + */
> +static inline int netdev_avail_queue(struct net_device *dev_queue)
> +{
> +	return netdev_tx_avail_queue(netdev_get_tx_queue(dev_queue, 0));
> +}
> +

This doesn't make any sense, you're only providing queue zero's
information.

You're passing in a net_device, calling it a "dev_queue" in the
variable name, the exlicitly using queue zero of that device in the
netdev_get_tx_queue() call.

Pretty confusing if you ask me :)
