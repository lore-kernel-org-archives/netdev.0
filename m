From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] Fix b44 RX FIFO overflow recovery.
Date: Wed, 30 Jun 2010 13:25:53 -0700 (PDT)
Message-ID: <20100630.132553.163237479.davem@davemloft.net>
References: <AANLkTik2BadzkkVcmlhgWh6rcLDm1kEu0RDqWuILnwVZ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: james.dutton@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:46733
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754796Ab0F3UZj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 Jun 2010 16:25:39 -0400
In-Reply-To: <AANLkTik2BadzkkVcmlhgWh6rcLDm1kEu0RDqWuILnwVZ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: James Courtier-Dutton <james.dutton@gmail.com>
Date: Wed, 30 Jun 2010 21:11:18 +0100

> diff --git a/drivers/net/b44.c b/drivers/net/b44.c
> index 69d9f3d..72537c1 100644
> --- a/drivers/net/b44.c
> +++ b/drivers/net/b44.c
> @@ -852,12 +852,46 @@ static int b44_poll(struct napi_struct *napi, int budget)
>  		/* spin_unlock(&bp->tx_lock); */
>  	}
>  	spin_unlock_irqrestore(&bp->lock, flags);
> +	if (bp->istat & ISTAT_DSCE)
> +	{
> +		printk(KERN_INFO "b44_poll: ISTAT_DSCE\n");
> +	}

Using braces here is overkill, and even if it was appropriate it's formatted
incorrectly, it should be:

	if (x)
		y;

for single-line code blocks, and:

	if (x) {
		y;
		z;
	}

For multi-line code blocks.
