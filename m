From: Andi Kleen <ak@suse.de>
Subject: Re: [PATCH 3/7] [I/OAT] Don't offload copies for loopback traffic
Date: Fri, 18 Aug 2006 20:17:18 +0200
Message-ID: <200608182017.19248.ak@suse.de>
References: <20060816005337.8634.70033.stgit@gitlost.site> <20060816005341.8634.10380.stgit@gitlost.site>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from cantor2.suse.de ([195.135.220.15]:47489 "EHLO mx2.suse.de")
	by vger.kernel.org with ESMTP id S1161048AbWHRRJM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 18 Aug 2006 13:09:12 -0400
To: Chris Leech <christopher.leech@intel.com>
In-Reply-To: <20060816005341.8634.10380.stgit@gitlost.site>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


> @@ -1136,7 +1137,8 @@ int tcp_recvmsg(struct kiocb *iocb, stru
>  	skb = skb_peek_tail(&sk->sk_receive_queue);
>  	if (skb)
>  		available = TCP_SKB_CB(skb)->seq + skb->len - (*seq);
> -	if ((available < target) &&
> +	dst = __sk_dst_get(sk);
> +	if ((available < target) && (!dst || (dst->dev != &loopback_dev)) &&

You just added another potential cache miss to a critical
path. A bit flag in the socket would be better.

But is it really worth this ugly special case?

-Andi
