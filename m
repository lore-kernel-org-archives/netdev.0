From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net v2] xen-netback: bookkeep number of active queues
 in our own module
Date: Sun, 22 Jun 2014 17:21:05 -0700 (PDT)
Message-ID: <20140622.172105.1949118384610767695.davem@davemloft.net>
References: <1403443901-5404-1-git-send-email-wei.liu2@citrix.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: xen-devel@lists.xen.org, netdev@vger.kernel.org,
	boris.ostrovsky@oracle.com, ian.campbell@citrix.com
To: wei.liu2@citrix.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:49631 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751007AbaFWAVG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 22 Jun 2014 20:21:06 -0400
In-Reply-To: <1403443901-5404-1-git-send-email-wei.liu2@citrix.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Wei Liu <wei.liu2@citrix.com>
Date: Sun, 22 Jun 2014 14:31:41 +0100

>  
> +	/* Initialisation completed, tell core driver the number of
> +	 * active queues.
> +	 */
> +	rtnl_lock();
> +	netif_set_real_num_tx_queues(be->vif->dev, requested_num_queues);
> +	netif_set_real_num_rx_queues(be->vif->dev, requested_num_queues);
> +	rtnl_unlock();
> +
>  	xenvif_carrier_on(be->vif);

This function _NEVER_ set the number of RX queues beforehand,
therefore why are you adding an RX queue adjustment now?

Regardless of the reason, you must explain such a change, in
detail, in your commit message.

Your previous patch didn't do this, and I really am suspect as to
whether you functionally tested and verified this aspect of your
change at a ll.

Please don't "quietly" make undescribed changes like this. It's very
tiring to think that a patch has been adjusted to my liking and then
during review I find a grenade like this :-/

Thanks.
