From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] mv643xx_eth: Fix a possible deadlock upon ifdown
Date: Fri, 04 Jan 2013 15:20:31 -0800 (PST)
Message-ID: <20130104.152031.1827815520394695268.davem@davemloft.net>
References: <1357308422-19639-1-git-send-email-lkundrak@v3.sk>
	<1357309063-20236-1-git-send-email-lkundrak@v3.sk>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: buytenh@wantstofly.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: lkundrak@v3.sk
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:41819 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754749Ab3ADXUc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 4 Jan 2013 18:20:32 -0500
In-Reply-To: <1357309063-20236-1-git-send-email-lkundrak@v3.sk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Lubomir Rintel <lkundrak@v3.sk>
Date: Fri,  4 Jan 2013 15:17:43 +0100

> @@ -943,7 +943,7 @@ static int txq_reclaim(struct tx_queue *txq, int budget, int force)
>  	struct netdev_queue *nq = netdev_get_tx_queue(mp->dev, txq->index);
>  	int reclaimed;
>  
> -	__netif_tx_lock(nq, smp_processor_id());
> +	__netif_tx_lock_bh(nq);

I still don't understand why this change is necessary.

The TX reclaim function is invoked in software interrupt context in
all of the places where this lockdep warning might matter.
