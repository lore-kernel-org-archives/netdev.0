From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2] rfs: Receive Flow Steering
Date: Wed, 07 Apr 2010 21:40:39 -0700 (PDT)
Message-ID: <20100407.214039.67944635.davem@davemloft.net>
References: <alpine.DEB.1.00.1004052248390.29212@pokey.mtv.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.com, netdev@vger.kernel.org, eric.dumazet@gmail.com
To: therbert@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:41466
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750746Ab0DHEkh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 8 Apr 2010 00:40:37 -0400
In-Reply-To: <alpine.DEB.1.00.1004052248390.29212@pokey.mtv.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Tom Herbert <therbert@google.com>
Date: Mon, 5 Apr 2010 22:56:50 -0700 (PDT)

> @@ -2342,6 +2387,10 @@ static int enqueue_to_backlog(struct sk_buff *skb, int cpu)
>  		if (queue->input_pkt_queue.qlen) {
>  enqueue:
>  			__skb_queue_tail(&queue->input_pkt_queue, skb);
> +#ifdef CONFIG_RPS
> +			*qtail = queue->input_queue_head +
> +			    queue->input_pkt_queue.qlen;
> +#endif
>  			rps_unlock(queue);
>  			local_irq_restore(flags);
>  			return NET_RX_SUCCESS;
 ...
> @@ -2801,6 +2864,9 @@ static void flush_backlog(void *arg)
>  		if (skb->dev == dev) {
>  			__skb_unlink(skb, &queue->input_pkt_queue);
>  			kfree_skb(skb);
> +#ifdef CONFIG_RPS
> +			queue->input_queue_head++;
> +#endif
>  		}
>  	rps_unlock(queue);
>  }

Please abstract these behind inline functions that live in
some header file, so we don't need to continually pepper
dev.c with countless ifdefs.

If you fix this and the kernel command line --> sysctl thing
Eric pointed out, I think I can apply this to net-next-2.6

Thanks.

