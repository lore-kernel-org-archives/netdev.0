From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2] ethernet: call __skb_pull() in eth_type_trans()
Date: Mon, 03 May 2010 12:54:04 -0700 (PDT)
Message-ID: <20100503.125404.134122628.davem@davemloft.net>
References: <1272895972-13799-1-git-send-email-xiaosuo@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, netdev@vger.kernel.org
To: xiaosuo@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:41920
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753462Ab0ECTx6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 3 May 2010 15:53:58 -0400
In-Reply-To: <1272895972-13799-1-git-send-email-xiaosuo@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Changli Gao <xiaosuo@gmail.com>
Date: Mon,  3 May 2010 22:12:52 +0800

> @@ -162,7 +162,10 @@ __be16 eth_type_trans(struct sk_buff *skb, struct net_device *dev)
>  
>  	skb->dev = dev;
>  	skb_reset_mac_header(skb);
> -	skb_pull_inline(skb, ETH_HLEN);
> +	if (unlikely(skb->len < ETH_ZLEN))
> +		dev_warn(&dev->dev, "too small ethernet packet: %u bytes\n",
> +			 skb->len);
> +	__skb_pull(skb, ETH_HLEN);
>  	eth = eth_hdr(skb);

And now it's even more expensive than skb_pull_inline() :-)

Really, things are fine as-is.
