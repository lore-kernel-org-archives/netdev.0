From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] netpoll: use non-BH variant of RCU
Date: Wed, 11 Aug 2010 23:09:36 -0700 (PDT)
Message-ID: <20100811.230936.183035599.davem@davemloft.net>
References: <20100810211932.GG2379@linux.vnet.ibm.com>
	<20100810.163117.241919476.davem@davemloft.net>
	<20100811220047.GH2516@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: herbert@gondor.apana.org.au, linville@tuxdriver.com,
	netdev@vger.kernel.org
To: paulmck@linux.vnet.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:57435
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752485Ab0HLGJT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 Aug 2010 02:09:19 -0400
In-Reply-To: <20100811220047.GH2516@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Date: Wed, 11 Aug 2010 15:00:47 -0700

> @@ -113,6 +113,12 @@ int rcu_my_thread_group_empty(void)
>  	return thread_group_empty(current);
>  }
>  EXPORT_SYMBOL_GPL(rcu_my_thread_group_empty);
> +
> +void rcu_read_unlock_bh_irqsoff_check(void)
> +{
> +	WARN_ON_ONCE(in_irq() || irqs_disabled());
> +}
> +EXPORT_SYMBOL_GPL(rcu_read_unlock_bh_irqsoff_check);
>  #endif /* #ifdef CONFIG_PROVE_RCU */

Is this WARN_ON_ONCE() test inverted?  It seems to be called where we
"should be" in an IRQ or have IRQs disabled.

