From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: moxa: fix TX overrun memory leak
Date: Sun, 07 Jun 2015 19:22:02 -0700 (PDT)
Message-ID: <20150607.192202.705812138482774611.davem@davemloft.net>
References: <1433511978-17666-1-git-send-email-jonas.jensen@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-arm-kernel@lists.infradead.org,
	linux-kernel@vger.kernel.org
To: jonas.jensen@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:49320 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750978AbbFHCWG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 7 Jun 2015 22:22:06 -0400
In-Reply-To: <1433511978-17666-1-git-send-email-jonas.jensen@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jonas Jensen <jonas.jensen@gmail.com>
Date: Fri,  5 Jun 2015 15:46:18 +0200

>  	desc = priv->tx_desc_base + (TX_REG_DESC_SIZE * tx_head);
>  
> -	spin_lock_irq(&priv->txlock);
> +	if (CIRC_SPACE(tx_head, tx_tail, TX_DESC_NUM) == 0) {
> +		priv->stats.tx_dropped++;
> +		goto out_unlock;
> +	}

You can't do this.

Whatever code creates this condition _must_ stop the TX queue
so that the core netdevice transmit layer does not call your
transmit method.
