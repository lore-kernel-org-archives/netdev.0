From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [RESEND][PATCH 2.6.28] myri10ge: fix stop/go mmio ordering
Date: Fri, 31 Oct 2008 00:49:09 -0400
Message-ID: <490A8E45.909@garzik.org>
References: <49096965.20905@myri.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Brice Goglin <brice@myri.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:54198 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753554AbYJaEtN (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 31 Oct 2008 00:49:13 -0400
In-Reply-To: <49096965.20905@myri.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Brice Goglin wrote:
> Use mmiowb() to ensure "stop" and "go" commands are sent in order on ia64.
> 
> Signed-off-by: Brice Goglin <brice@myri.com>
> 
> --- linux-git/drivers/net/myri10ge/myri10ge.c	2008-10-30 08:15:37.000000000 +0100
> +++ linux-tmp/drivers/net/myri10ge/myri10ge.c	2008-10-30 08:17:54.000000000 +0100
> @@ -75,7 +75,7 @@
>  #include "myri10ge_mcp.h"
>  #include "myri10ge_mcp_gen_header.h"
>  
> -#define MYRI10GE_VERSION_STR "1.4.3-1.371"
> +#define MYRI10GE_VERSION_STR "1.4.3-1.375"
>  
>  MODULE_DESCRIPTION("Myricom 10G driver (10GbE)");
>  MODULE_AUTHOR("Maintainer: help@myri.com");
> @@ -1393,6 +1393,7 @@
>  		if (tx->req == tx->done) {
>  			tx->queue_active = 0;
>  			put_be32(htonl(1), tx->send_stop);
> +			mmiowb();
>  		}
>  		__netif_tx_unlock(dev_queue);
>  	}
> @@ -2864,6 +2865,7 @@
>  	if ((mgp->dev->real_num_tx_queues > 1) && tx->queue_active == 0) {
>  		tx->queue_active = 1;
>  		put_be32(htonl(1), tx->send_go);
> +		mmiowb();
>  	}
>  	tx->pkt_start++;
>  	if ((avail - count) < MXGEFW_MAX_SEND_DESC) {
> 

applied


