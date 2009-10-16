From: "Divy Le Ray" <divy@chelsio.com>
Subject: Re: [PATCH] cxgb3: No need to wake queue in xmit handler
Date: Thu, 15 Oct 2009 22:09:22 -0700
Message-ID: <op.u1vm9wbjduofyu@cayman.asicdesigners.com>
References: <20091015055419.30109.16062.sendpatchset@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII;
	format=flowed	delsp=yes
Content-Transfer-Encoding: 7BIT
Cc: netdev@vger.kernel.org
To: "Krishna Kumar" <krkumar2@in.ibm.com>, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([67.207.112.58]:21829 "EHLO
	stargate.chelsio.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751559AbZJPFeS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 16 Oct 2009 01:34:18 -0400
In-Reply-To: <20091015055419.30109.16062.sendpatchset@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 14 Oct 2009 22:54:19 -0700, Krishna Kumar <krkumar2@in.ibm.com>  
wrote:

> The xmit handler doesn't need to wake the queue after stopping
> it temporarily (some other drivers are doing the same).
>
> Patch on net-next-2.6, multiple netperf sessions tested.
>
> Signed-off-by: Krishna Kumar <krkumar2@in.ibm.com>
Acked-by: Divy Le Ray <divy@chelsio.com>
> ---
>
>  drivers/net/cxgb3/sge.c |    2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
>
> diff -ruNp org/drivers/net/cxgb3/sge.c new/drivers/net/cxgb3/sge.c
> --- org/drivers/net/cxgb3/sge.c	2009-09-07 10:09:03.000000000 +0530
> +++ new/drivers/net/cxgb3/sge.c	2009-09-07 10:11:11.000000000 +0530
> @@ -1260,7 +1260,7 @@ netdev_tx_t t3_eth_xmit(struct sk_buff *
>  		if (should_restart_tx(q) &&
>  		    test_and_clear_bit(TXQ_ETH, &qs->txq_stopped)) {
>  			q->restarts++;
> -			netif_tx_wake_queue(txq);
> +			netif_tx_start_queue(txq);
>  		}
>  	}
>


