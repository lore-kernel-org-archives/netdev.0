From: Matt Mackall <mpm@selenic.com>
Subject: Re: [PATCH] netpoll: break recursive loop in netpoll rx path
Date: Mon, 12 Jun 2006 10:51:21 -0500
Message-ID: <20060612155120.GO24227@waste.org>
References: <20060612154029.GA3790@hmsreliant.homelinux.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, jmoyer@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from waste.org ([64.81.244.121]:57216 "EHLO waste.org")
	by vger.kernel.org with ESMTP id S1752100AbWFLQBl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 12 Jun 2006 12:01:41 -0400
To: Neil Horman <nhorman@tuxdriver.com>
Content-Disposition: inline
In-Reply-To: <20060612154029.GA3790@hmsreliant.homelinux.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Jun 12, 2006 at 11:40:29AM -0400, Neil Horman wrote:
> Hey there-
> 	the netpoll system currently has a rx to tx path via:
> netpoll_rx
>  __netpoll_rx
>   arp_reply
>    netpoll_send_skb
>     dev->hard_start_tx
> 
> 	This rx->tx loop places network drivers at risk of
> inadvertently causing a deadlock or BUG halt by recursively trying
> to acquire a spinlock that is used in both their rx and tx paths
> (this problem was origionally reported to me in the 3c59x driver,
> which shares a spinlock between the boomerang_interrupt and
> boomerang_start_xmit routines).

Grumble.

> This patch breaks this loop, by queueing arp frames, so that they
> can be responded to after all receive operations have been
> completed. Tested by myself and the reported with successful
> results.

Tested how? kgdb?

> +	if (likely(npi))
> +		while ((skb = skb_dequeue(&npi->arp_tx)) != NULL)
> +			arp_reply(skb);
> +

Assignment inside tests is frowned upon. I'd prefer pulling this out
to its own function too.


Mathematics is the supreme nostalgia of our time.
