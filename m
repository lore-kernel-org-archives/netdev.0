From: David Miller <davem@davemloft.net>
Subject: Re: [patch] net: sxgbe: fix error handling in init_rx_ring()
Date: Fri, 06 Feb 2015 12:50:27 -0800 (PST)
Message-ID: <20150206.125027.797640169824978113.davem@davemloft.net>
References: <20150116071229.GH5520@mwanda>
	<20150205080042.GC27855@mwanda>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: bh74.an@samsung.com, kgene@kernel.org, ks.giri@samsung.com,
	vipul.pandya@samsung.com, netdev@vger.kernel.org,
	kernel-janitors@vger.kernel.org
To: dan.carpenter@oracle.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:57154 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752833AbbBFUua (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 6 Feb 2015 15:50:30 -0500
In-Reply-To: <20150205080042.GC27855@mwanda>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Dan Carpenter <dan.carpenter@oracle.com>
Date: Thu, 5 Feb 2015 11:00:42 +0300

> There are a couple bugs with the error handling in this function.
> 
> 1) If we can't allocate "rx_ring->rx_skbuff" then we should call
>    dma_free_coherent() but we don't.
> 2) free_rx_ring() frees "rx_ring->rx_skbuff_dma" and "rx_ring->rx_skbuff"
>    so calling it in a loop causes a double free.
> 
> Also it was a bit confusing how we sometimes freed things before doing
> the goto.  I've cleaned it up so it does error handling in normal kernel
> style.
> 
> Signed-off-by: Dan Carpenter <dan.carpenter@oracle.com>

Looks good, applied, thanks Dan.
