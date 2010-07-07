From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH 2.6.35-rc1] net: vmxnet3 fixes [1/5] Spare skb to avoid
 starvation
Date: Wed, 7 Jul 2010 10:46:39 -0700
Message-ID: <20100707104639.28f69b57@s6510>
References: <alpine.LRH.2.00.1007070214400.6105@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, pv-drivers@vmware.com
To: Shreyas Bhatewara <sbhatewara@vmware.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:50400 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754680Ab0GGRql (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 7 Jul 2010 13:46:41 -0400
In-Reply-To: <alpine.LRH.2.00.1007070214400.6105@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 7 Jul 2010 02:21:55 -0700 (PDT)
Shreyas Bhatewara <sbhatewara@vmware.com> wrote:

> 
> 
> From: Shreyas Bhatewara <sbhatewara@vmware.com>
> 
> skb_alloc() failure can cause the recv ring to loose all packet reception.
> Avoid this by introducing a spare buffer.
> 
> Signed-off-by: Michael Stolarchuk <stolarchuk@vmware.com>
> Signed-off-by: Shreyas Bhatewara <sbhatewara@vmware.com>
> 

I don't see how this fixes the problem, what happens when
the spare buffer is used up? Better to design a flow control algorithm
that holds off sender if allocation fails, and retry allocation later
(for example with a work queue).

> diff --git a/drivers/net/vmxnet3/vmxnet3_drv.c b/drivers/net/vmxnet3/vmxnet3_drv.c
> index 989b742..5a50d10 100644
...

>  /*
> @@ -149,6 +149,13 @@ vmxnet3_cmd_ring_desc_avail(struct vmxnet3_cmd_ring *ring)
>  		ring->next2comp - ring->next2fill - 1;
>  }
>  
> +static inline bool
> +vmxnet3_cmd_ring_desc_empty(struct vmxnet3_cmd_ring *ring)
> +{
> +	return (ring->next2comp == ring->next2fill);
> +}

const is good practice on functions like this.

