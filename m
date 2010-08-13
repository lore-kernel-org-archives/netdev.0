From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH] netpoll: use non-BH variant of RCU
Date: Fri, 13 Aug 2010 10:39:04 -0400
Message-ID: <20100813143904.GA27261@gondor.apana.org.au>
References: <20100810211932.GG2379@linux.vnet.ibm.com> <20100810.163117.241919476.davem@davemloft.net> <20100811220047.GH2516@linux.vnet.ibm.com> <20100811.230936.183035599.davem@davemloft.net> <20100812154213.GB2524@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, linville@tuxdriver.com,
	netdev@vger.kernel.org
To: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from helcar.apana.org.au ([209.40.204.226]:51549 "EHLO
	fornost.hengli.com.au" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1761689Ab0HMOjN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 13 Aug 2010 10:39:13 -0400
Content-Disposition: inline
In-Reply-To: <20100812154213.GB2524@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Aug 12, 2010 at 08:42:13AM -0700, Paul E. McKenney wrote:
>
> +/**
> + * rcu_read_lock_bh_irqsoff() - mark the beginning of an RCU-bh critical section
> + *
> + * This is equivalent of rcu_read_lock_bh(), but to be used where the
> + * caller either is in an irq handler or has irqs disabled.  Note that
> + * this function assumes that PREEMPT_RT kernels run irq handlers at
> + * higher priority than softirq handlers!
> + */
> +static inline void rcu_read_lock_bh_irqsoff(void)
> +{
> +	rcu_read_unlock_bh_irqsoff_check();
> +	__acquire(RCU_BH);
> +	rcu_read_acquire_bh();
> +}

Thanks for the patch Paul!

But this doesn't really solve the problem for netif_rx.  The reason
is that netif_rx can either be called with IRQs on OR off.  So we
need to take the right precautions in the case where IRQs are
enabled along with BH.

Cheers,
-- 
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
