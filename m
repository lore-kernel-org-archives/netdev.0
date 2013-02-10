From: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Subject: Re: [PATCH] ipv6: don't let node/interface scoped multicast traffic
 escape on the wire
Date: Mon, 11 Feb 2013 00:31:39 +0900
Message-ID: <5117BD5B.2020900@linux-ipv6.org>
References: <20130210123335.GA18219@order.stressinduktion.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, erik.hugne@ericsson.com,
	YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 94.43.138.210.xn.2iij.net ([210.138.43.94]:35587 "EHLO
	mail.st-paulia.net" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1755138Ab3BJPbl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 10 Feb 2013 10:31:41 -0500
In-Reply-To: <20130210123335.GA18219@order.stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> Reported-by: Erik Hugne <erik.hugne@ericsson.com>
> Cc: Erik Hugne <erik.hugne@ericsson.com>
> Cc: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
> Signed-off-by: Hannes Frederic Sowa <hannes@stressinduktion.org>
> ---
>  net/ipv6/ip6_output.c | 7 +++++++
>  1 file changed, 7 insertions(+)
> 
> diff --git a/net/ipv6/ip6_output.c b/net/ipv6/ip6_output.c
> index c953825..155eccf 100644
> --- a/net/ipv6/ip6_output.c
> +++ b/net/ipv6/ip6_output.c
> @@ -120,6 +120,13 @@ static int ip6_finish_output2(struct sk_buff *skb)
>  
>  		IP6_UPD_PO_STATS(dev_net(dev), idev, IPSTATS_MIB_OUTMCAST,
>  				skb->len);
> +
> +		if (IPV6_ADDR_MC_SCOPE(&ipv6_hdr(skb)->daddr) <=
> +		    IPV6_ADDR_SCOPE_NODELOCAL &&
> +		    !(dev->flags & IFF_LOOPBACK)) {
> +			kfree_skb(skb);
> +			return 0;
> +		}
>  	}
>  
>  	rcu_read_lock_bh();
> 

Acked-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>

--yoshfuji
