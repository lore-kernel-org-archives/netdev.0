From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: fix a race in gro_cell_poll()
Date: Tue, 11 Dec 2012 12:50:53 -0500 (EST)
Message-ID: <20121211.125053.1135051054831742185.davem@davemloft.net>
References: <504C9EFCA2D0054393414C9CB605C37F1BFC32A1@SJEXCHMB06.corp.ad.broadcom.com>
	<1355176551.27891.57.camel@edumazet-glaptop>
	<1355178723.27891.85.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: dmitry@broadcom.com, netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:41034 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753735Ab2LKRuz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 11 Dec 2012 12:50:55 -0500
In-Reply-To: <1355178723.27891.85.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Mon, 10 Dec 2012 14:32:03 -0800

> From: Eric Dumazet <edumazet@google.com>
> 
> Dmitry Kravkov reported packet drops for GRE packets since GRO support
> was added.
> 
> There is a race in gro_cell_poll() because we call napi_complete()
> without any synchronization with a concurrent gro_cells_receive()
> 
> Once bug was triggered, we queued packets but did not schedule NAPI
> poll.
> 
> We can fix this issue using the spinlock protected the napi_skbs queue,
> as we have to hold it to perform skb dequeue anyway.
> 
> As we open-code skb_dequeue(), we no longer need to mask IRQS, as both
> producer and consumer run under BH context.
> 
> Bug added in commit c9e6bc644e (net: add gro_cells infrastructure)
> 
> Reported-by: Dmitry Kravkov <dmitry@broadcom.com>
> Signed-off-by: Eric Dumazet <edumazet@google.com>

Applied and queued up for -stable, thanks.
