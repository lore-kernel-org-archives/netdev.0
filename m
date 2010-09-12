From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [PATCH v2] net: af_packet: don't call tpacket_destruct_skb()
 until the skb is sent out
Date: Sun, 12 Sep 2010 14:13:49 +0200
Message-ID: <20100912121349.GD22982@redhat.com>
References: <1284175403-3228-1-git-send-email-xiaosuo@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Oliver Hartkopp <socketcan@hartkopp.net>,
	netdev@vger.kernel.org
To: Changli Gao <xiaosuo@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:15598 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751823Ab0ILMTy (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 12 Sep 2010 08:19:54 -0400
Content-Disposition: inline
In-Reply-To: <1284175403-3228-1-git-send-email-xiaosuo@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Sep 11, 2010 at 11:23:23AM +0800, Changli Gao wrote:
> @@ -799,7 +806,9 @@ int pskb_expand_head(struct sk_buff *skb, int nhead, int ntail,
>  
>  	memcpy((struct skb_shared_info *)(data + size),
>  	       skb_shinfo(skb),
> -	       offsetof(struct skb_shared_info, frags[skb_shinfo(skb)->nr_frags]));
> +	       offsetof(struct skb_shared_info,
> +			frags[skb_shinfo(skb)->nr_frags]));
> +	skb_shinfo(skb)->destructor = NULL;
>  
>  	/* Check if we can avoid taking references on fragments if we own
>  	 * the last reference on skb->head. (see skb_release_data())

So it looks like pskb_expand_head will prevent the shinfo desctructor
from being called, ever? If so, won't this break af_packet?

-- 
MST
