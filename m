From: David Miller <davem@davemloft.net>
Subject: Re: [BUG] eth_type_trans() can access stale data
Date: Wed, 15 Jan 2014 15:48:05 -0800 (PST)
Message-ID: <20140115.154805.1403628531019301276.davem@davemloft.net>
References: <1389743541.31367.279.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:42335 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751248AbaAOXsH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 15 Jan 2014 18:48:07 -0500
In-Reply-To: <1389743541.31367.279.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Tue, 14 Jan 2014 15:52:21 -0800

> @@ -194,7 +194,8 @@ __be16 eth_type_trans(struct sk_buff *skb, struct net_device *dev)
>  	 *      layer. We look for FFFF which isn't a used 802.2 SSAP/DSAP. This
>  	 *      won't work for fault tolerant netware but does for the rest.
>  	 */
> -	if (unlikely(skb->len >= 2 && *(unsigned short *)(skb->data) == 0xFFFF))
> +	if (unlikely(skb_headlen(skb) >= 2 &&
> +		     *(unsigned short *)(skb->data) == 0xFFFF))
>  		return htons(ETH_P_802_3);

I think using skb_header_pointer() will essentially have the same cost,
why not use it instead?

Thanks.
