From: linas@austin.ibm.com (Linas Vepstas)
Subject: Re: [PATCH] spidernet : fix memory leak in spider_net_stop
Date: Thu, 1 Feb 2007 11:36:18 -0600
Message-ID: <20070201173618.GI5616@austin.ibm.com>
References: <200702011207.47421.jens@de.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: James K Lewis <jim@jklewis.com>, linuxppc-dev@ozlabs.org,
	netdev@vger.kernel.org, jgarzik@pobox.com, cbe-oss-dev@ozlabs.org,
	Ishizaki Kou <kou.ishizaki@toshiba.co.jp>
To: Jens Osterkamp <jens@de.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e6.ny.us.ibm.com ([32.97.182.146]:53417 "EHLO e6.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1422728AbXBARgZ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 1 Feb 2007 12:36:25 -0500
Received: from d01relay04.pok.ibm.com (d01relay04.pok.ibm.com [9.56.227.236])
	by e6.ny.us.ibm.com (8.13.8/8.13.8) with ESMTP id l11Hb1FV007018
	for <netdev@vger.kernel.org>; Thu, 1 Feb 2007 12:37:01 -0500
Received: from d01av04.pok.ibm.com (d01av04.pok.ibm.com [9.56.224.64])
	by d01relay04.pok.ibm.com (8.13.8/8.13.8/NCO v8.2) with ESMTP id l11HaMDP275580
	for <netdev@vger.kernel.org>; Thu, 1 Feb 2007 12:36:22 -0500
Received: from d01av04.pok.ibm.com (loopback [127.0.0.1])
	by d01av04.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l11HaL8c020061
	for <netdev@vger.kernel.org>; Thu, 1 Feb 2007 12:36:22 -0500
Content-Disposition: inline
In-Reply-To: <200702011207.47421.jens@de.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


A variant of this patch is queued up for 2.6.21,
as a part of the patch
http://www.mail-archive.com/netdev@vger.kernel.org/msg28213.html

I beleive its in the -mm tree, I have not checked.

--linas

On Thu, Feb 01, 2007 at 12:07:47PM +0100, Jens Osterkamp wrote:
> 
> We forget to call spider_net_free_rx_chain_contents which does the
> actual dev_kfree_skb. New skbs are allocated from skbuff_head_cache
> on each "ifconfig up" letting the cache grow infinitely.
> 
> This patch fixes it.
> 
> Signed-off-by: Jens Osterkamp <jens@de.ibm.com>
> 
> Index: linux-2.6.20-rc6/drivers/net/spider_net.c
> ===================================================================
> --- linux-2.6.20-rc6.orig/drivers/net/spider_net.c
> +++ linux-2.6.20-rc6/drivers/net/spider_net.c
> @@ -1925,6 +1925,8 @@ spider_net_stop(struct net_device *netde
>  	/* release chains */
>  	spider_net_release_tx_chain(card, 1);
>  
> +	spider_net_free_rx_chain_contents(card);
> +
>  	spider_net_free_chain(card, &card->tx_chain);
>  	spider_net_free_chain(card, &card->rx_chain);
>  
