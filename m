From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: txq_trans_update() helper
Date: Mon, 25 May 2009 22:38:27 -0700 (PDT)
Message-ID: <20090525.223827.256643479.davem@davemloft.net>
References: <4A110C7B.4020407@cosmosbay.com>
	<20090518.151152.76033192.davem@davemloft.net>
	<4A1B8007.1000703@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:45967
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751414AbZEZFi2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 26 May 2009 01:38:28 -0400
In-Reply-To: <4A1B8007.1000703@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Tue, 26 May 2009 07:37:11 +0200

> @@ -302,8 +302,11 @@ static void netpoll_send_skb(struct netpoll *np, struct sk_buff *skb)
>  		for (tries = jiffies_to_usecs(1)/USEC_PER_POLL;
>  		     tries > 0; --tries) {
>  			if (__netif_tx_trylock(txq)) {
> -				if (!netif_tx_queue_stopped(txq))
> +				if (!netif_tx_queue_stopped(txq)) {
>  					status = ops->ndo_start_xmit(skb, dev);
> +					if (status == NETDEV_TX_OK)
> +						txq_trans_update(txq);
> +					}

Closing brace here has strange indentation, which doesn't match
the statement of the openning brace.

Please fix this, thanks.
