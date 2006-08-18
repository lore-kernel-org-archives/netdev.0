From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 3/7] [I/OAT] Don't offload copies for loopback traffic
Date: Fri, 18 Aug 2006 14:23:39 -0700 (PDT)
Message-ID: <20060818.142339.108741209.davem@davemloft.net>
References: <20060816005337.8634.70033.stgit@gitlost.site>
	<20060816005341.8634.10380.stgit@gitlost.site>
	<200608182017.19248.ak@suse.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: christopher.leech@intel.com, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:48323
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S964940AbWHRVXh (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 18 Aug 2006 17:23:37 -0400
To: ak@suse.de
In-Reply-To: <200608182017.19248.ak@suse.de>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Andi Kleen <ak@suse.de>
Date: Fri, 18 Aug 2006 20:17:18 +0200

> 
> > @@ -1136,7 +1137,8 @@ int tcp_recvmsg(struct kiocb *iocb, stru
> >  	skb = skb_peek_tail(&sk->sk_receive_queue);
> >  	if (skb)
> >  		available = TCP_SKB_CB(skb)->seq + skb->len - (*seq);
> > -	if ((available < target) &&
> > +	dst = __sk_dst_get(sk);
> > +	if ((available < target) && (!dst || (dst->dev != &loopback_dev)) &&
> 
> You just added another potential cache miss to a critical
> path. A bit flag in the socket would be better.
> 
> But is it really worth this ugly special case?

I think it isn't.  It is really gross.
