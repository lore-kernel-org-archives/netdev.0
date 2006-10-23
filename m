From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/3] netpoll: use sk_buff_head for txq
Date: Sun, 22 Oct 2006 20:42:20 -0700 (PDT)
Message-ID: <20061022.204220.78710782.davem@davemloft.net>
References: <20061020134826.75dd1cba@freekitty>
	<20061020.140149.125893169.davem@davemloft.net>
	<20061020153027.3bed8c86@dxpl.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:14026
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S1751401AbWJWDmS (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 22 Oct 2006 23:42:18 -0400
To: shemminger@osdl.org
In-Reply-To: <20061020153027.3bed8c86@dxpl.pdx.osdl.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Stephen Hemminger <shemminger@osdl.org>
Date: Fri, 20 Oct 2006 15:30:27 -0700

> +		spin_lock_irqsave(&netpoll_txq.lock, flags);
> +		for (skb = (struct sk_buff *)netpoll_txq.next;
> +		     skb != (struct sk_buff *)&netpoll_txq; skb = next) {
> +			next = skb->next;
> +			if (skb->dev == dev)
> +				skb_unlink(skb, &netpoll_txq);
> +		}
> +		spin_unlock_irqrestore(&netpoll_txq.lock, flags);
>  	}

All SKBs removed here will be leaked, nothing frees them up.

Since #2 and #3 depend upon this patch, I'll hold off on those
until you fix this bug.

Thanks.
