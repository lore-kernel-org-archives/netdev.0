From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/4] net: Dynamically allocate the per cpu counters for
 the loopback device.
Date: Wed, 26 Sep 2007 22:09:01 -0700 (PDT)
Message-ID: <20070926.220901.51682476.davem@davemloft.net>
References: <m1ps05rnjv.fsf@ebiederm.dsl.xmission.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, containers@lists.osdl.org
To: ebiederm@xmission.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:51144
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751924AbXI0FJB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 27 Sep 2007 01:09:01 -0400
In-Reply-To: <m1ps05rnjv.fsf@ebiederm.dsl.xmission.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: ebiederm@xmission.com (Eric W. Biederman)
Date: Wed, 26 Sep 2007 17:53:40 -0600

> 
> This patch add support for dynamically allocating the statistics counters
> for the loopback device and adds appropriate device methods for allocating
> and freeing the loopback device.
> 
> This completes support for creating multiple instances of the loopback
> device,  in preparation for creating per network namespace instances.
> 
> Signed-off-by: Eric W. Biederman <ebiederm@xmission.com>

Applied to net-2.6.24, thanks.

> @@ -155,7 +154,8 @@ static int loopback_xmit(struct sk_buff *skb, struct net_device *dev)
>  	dev->last_rx = jiffies;
>  
>  	/* it's OK to use __get_cpu_var() because BHs are off */
> -	lb_stats = &__get_cpu_var(pcpu_lstats);
> +	pcpu_lstats = netdev_priv(dev);
> +	lb_stats = per_cpu_ptr(pcpu_lstats, smp_processor_id());
>  	lb_stats->bytes += skb->len;
>  	lb_stats->packets++;
>  

I'm going to add a followon change that gets rid of that
comment about __get_cpu_var() since it is no longer
relevant.
