From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [RFC PATCH 1/2] net: Add new network device function to allow
 for MMIO batching
Date: Fri, 13 Jul 2012 09:19:14 +0200
Message-ID: <1342163954.3265.8299.camel@edumazet-glaptop>
References: <20120712002103.27846.73812.stgit@gitlad.jf.intel.com>
	 <20120712002603.27846.23752.stgit@gitlad.jf.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net,
	jeffrey.t.kirsher@intel.com, edumazet@google.com,
	bhutchings@solarflare.com, therbert@google.com,
	alexander.duyck@gmail.com
To: Alexander Duyck <alexander.h.duyck@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bk0-f46.google.com ([209.85.214.46]:43792 "EHLO
	mail-bk0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754378Ab2GMHTU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 13 Jul 2012 03:19:20 -0400
Received: by bkwj10 with SMTP id j10so2873501bkw.19
        for <netdev@vger.kernel.org>; Fri, 13 Jul 2012 00:19:18 -0700 (PDT)
In-Reply-To: <20120712002603.27846.23752.stgit@gitlad.jf.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2012-07-11 at 17:26 -0700, Alexander Duyck wrote:

> +static inline void netdev_complete_xmit(struct netdev_queue *txq)
> +{
> +	struct net_device *dev = txq->dev;
> +	const struct net_device_ops *ops = dev->netdev_ops;
> +
> +	if (txq->dispatch_pending < txq->dispatch_limit) {
> +		if (netif_tx_queue_delayed(txq)) {
> +			txq->dispatch_pending++;
> +			return;
> +		}
> +
> +		/* start of delayed write sequence */
> +		netif_tx_delay_queue(txq);

	I dont understand this part. Isnt a return missing here ?

> +	}
> +
> +	txq->dispatch_pending = 0;
> +
> +	ops->ndo_complete_xmit(dev, txq - &dev->_tx[0]);
> +}
> +
