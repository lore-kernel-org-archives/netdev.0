From: Andrew Morton <akpm@osdl.org>
Subject: Re: [PATCH] netdev: hotplug napi race cleanup
Date: Mon, 24 Apr 2006 18:30:43 -0700
Message-ID: <20060424183043.7650d1cb.akpm@osdl.org>
References: <20060421102503.4e44eb28@localhost.localdomain>
	<E1FX5zQ-000177-00@gondolin.me.apana.org.au>
	<20060424152341.094b72d8@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: herbert@gondor.apana.org.au, patrakov@ums.usu.ru,
	netdev@vger.kernel.org, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.4]:2538 "EHLO smtp.osdl.org")
	by vger.kernel.org with ESMTP id S1751483AbWDYBcw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 24 Apr 2006 21:32:52 -0400
To: Stephen Hemminger <shemminger@osdl.org>
In-Reply-To: <20060424152341.094b72d8@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Stephen Hemminger <shemminger@osdl.org> wrote:
>
> This follows after the earlier two patches.
> 
> Change the initialization of the class device portion of the net device
> to be done earlier, so that any races before registration completes are
> harmless.  Add a mutex to avoid changes to netdevice during the
> class device registration. 
> 

I had to fix up a reject in here.

> @@ -3047,7 +3051,10 @@
>  			 * this is a delayed call after register_netdevice
>  			 * so no way to tell device driver what is wrong.
>  			 */
> +			rtnl_lock();
>  			err = netdev_register_sysfs(dev);
> +			__rtnl_unlock();
> +
>  			if (err) {
>  				printk(KERN_ERR "%s: failed sysfs registration (%d)\n",
>  				       dev->name, err);

bix:/usr/src/25> grep 'this is a delayed call after' net/core/*.c patches/*.patch
bix:/usr/src/25> 

I cannot find that comment anywhere.
