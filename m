From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2 nf-next] netfilter: conntrack: remove the central
 spinlock
Date: Wed, 22 May 2013 14:29:46 -0700 (PDT)
Message-ID: <20130522.142946.1071765105220112729.davem@davemloft.net>
References: <1369255104.2143.108.camel@joe-AO722>
	<1369255736.3301.358.camel@edumazet-glaptop>
	<1369257171.2143.120.camel@joe-AO722>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, pablo@netfilter.org,
	netfilter-devel@vger.kernel.org, netdev@vger.kernel.org,
	therbert@google.com, kaber@trash.net
To: joe@perches.com
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1369257171.2143.120.camel@joe-AO722>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Joe Perches <joe@perches.com>
Date: Wed, 22 May 2013 14:12:51 -0700

> @@ -528,7 +528,7 @@ struct netdev_queue {
>   * write mostly part
>   */
>  	spinlock_t		_xmit_lock ____cacheline_aligned_in_smp;
> -	int			xmit_lock_owner;
> +	u16			xmit_lock_owner;
>  	/*
>  	 * please use this field instead of dev->trans_start
>  	 */
> @@ -2453,7 +2453,7 @@ static inline void __netif_tx_unlock_bh(struct netdev_queue *txq)
>  
>  static inline void txq_trans_update(struct netdev_queue *txq)
>  {
> -	if (txq->xmit_lock_owner != -1)
> +	if (txq->xmit_lock_owner != (u16)-1)
>  		txq->trans_start = jiffies;
>  }

Then technically this is an s16, don't use casts to pretend that it
isn't.
