From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next V2 1/3] net: Add max rate tx queue attribute
Date: Mon, 16 Mar 2015 15:53:09 -0400 (EDT)
Message-ID: <20150316.155309.890032766051959784.davem@davemloft.net>
References: <1426424596-3911-1-git-send-email-ogerlitz@mellanox.com>
	<1426424596-3911-2-git-send-email-ogerlitz@mellanox.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: john.r.fastabend@intel.com, netdev@vger.kernel.org,
	amirv@mellanox.com, idos@mellanox.com
To: ogerlitz@mellanox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:37270 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932234AbbCPTxM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 Mar 2015 15:53:12 -0400
In-Reply-To: <1426424596-3911-2-git-send-email-ogerlitz@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Or Gerlitz <ogerlitz@mellanox.com>
Date: Sun, 15 Mar 2015 15:03:14 +0200

> From: John Fastabend <john.r.fastabend@intel.com>
> 
> This adds a tx_maxrate attribute to the tx queue sysfs entry allowing
> for max-rate limiting. Along with DCB-ETS and BQL this provides another
> knob to tune queue performance. The limit units are Mbps.
> 
> By default it is disabled. To disable the rate limitation after it
> has been set for a queue, it should be set to zero.
> 
> Signed-off-by: John Fastabend <john.r.fastabend@intel.com>
> Signed-off-by: Or Gerlitz <ogerlitz@mellanox.com>
> ---
>  include/linux/netdevice.h |    9 ++++++
>  net/core/net-sysfs.c      |   67 +++++++++++++++++++++++++++++++++++++--------
>  2 files changed, 64 insertions(+), 12 deletions(-)
> 
> diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
> index ddab1a2..0719307 100644
> --- a/include/linux/netdevice.h
> +++ b/include/linux/netdevice.h
> @@ -587,6 +587,7 @@ struct netdev_queue {
>  #ifdef CONFIG_BQL
>  	struct dql		dql;
>  #endif
> +	unsigned long		tx_maxrate;
>  } ____cacheline_aligned_in_smp;
>  
>  static inline int netdev_queue_numa_node_read(const struct netdev_queue *q)
> @@ -1025,6 +1026,11 @@ struct fib_info;
>   *	the set of features that the stack has calculated and it returns
>   *	those the driver believes to be appropriate.
>   *
> + *	int (*ndo_set_tx_maxrate)(struct net_device *dev,
> +				  int queue_index,
> +				  u32 maxrate);
> + *	Called when a user wants to set a max-rate limitation of specific
> + *	TX queue.

Every comment line you add should start with a "*" just like the rest
of the comment does.

You'll also need to re-spin this against net-next as the swdev_ops changes
that went in recently conflict.

Thanks.
