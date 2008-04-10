From: Max Krasnyanskiy <maxk@qualcomm.com>
Subject: Re: [PATCH 2/2] net: check for underlength tap writes
Date: Thu, 10 Apr 2008 11:19:38 -0700
Message-ID: <47FE5A3A.9050109@qualcomm.com>
References: <200804052153.55676.rusty@rustcorp.com.au> <200804052154.33636.rusty@rustcorp.com.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Rusty Russell <rusty@rustcorp.com.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from wolverine02.qualcomm.com ([199.106.114.251]:33222 "EHLO
	wolverine02.qualcomm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757163AbYDJSTj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 10 Apr 2008 14:19:39 -0400
In-Reply-To: <200804052154.33636.rusty@rustcorp.com.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Ack. I've been meaning to fix this as well.
Dave, can please merge it.

Thanx
Max


Rusty Russell wrote:
> If the user gives a packet under 14 bytes, we'll end up reading off the end
> of the skb (not oopsing, just reading off the end).
> 
> Signed-off-by: Rusty Russell <rusty@rustcorp.com.au>
> 
> diff -r 99132ad16999 drivers/net/tun.c
> --- a/drivers/net/tun.c	Sat Apr 05 21:20:32 2008 +1100
> +++ b/drivers/net/tun.c	Sat Apr 05 22:47:20 2008 +1100
> @@ -286,8 +286,11 @@ static __inline__ ssize_t tun_get_user(s
>  			return -EFAULT;
>  	}
>  
> -	if ((tun->flags & TUN_TYPE_MASK) == TUN_TAP_DEV)
> +	if ((tun->flags & TUN_TYPE_MASK) == TUN_TAP_DEV) {
>  		align = NET_IP_ALIGN;
> +		if (unlikely(len < ETH_HLEN))
> +			return -EINVAL;
> +	}
>  
>  	if (!(skb = alloc_skb(len + align, GFP_KERNEL))) {
>  		tun->dev->stats.rx_dropped++;
> 

