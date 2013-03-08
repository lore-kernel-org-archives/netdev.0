From: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Subject: Re: [PATCH net-next v3 4/4] ipv6: report sin6_scope_id if sockopt
 RECVORIGDSTADDR is set
Date: Fri, 08 Mar 2013 11:09:40 +0900
Message-ID: <51394864.3070009@linux-ipv6.org>
References: <20130307210540.GA23781@order.stressinduktion.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
To: netdev@vger.kernel.org, David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 94.43.138.210.xn.2iij.net ([210.138.43.94]:39898 "EHLO
	mail.st-paulia.net" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752241Ab3CHCJl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Mar 2013 21:09:41 -0500
In-Reply-To: <20130307210540.GA23781@order.stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hannes Frederic Sowa wrote:
> Cc: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
> Signed-off-by: Hannes Frederic Sowa <hannes@stressinduktion.org>
> ---
>  net/ipv6/datagram.c | 4 +++-
>  1 file changed, 3 insertions(+), 1 deletion(-)
> 
> diff --git a/net/ipv6/datagram.c b/net/ipv6/datagram.c
> index b55e70a..4b56cbb 100644
> --- a/net/ipv6/datagram.c
> +++ b/net/ipv6/datagram.c
> @@ -594,7 +594,9 @@ int ip6_datagram_recv_ctl(struct sock *sk, struct msghdr *msg,
>  			sin6.sin6_addr = ipv6_hdr(skb)->daddr;
>  			sin6.sin6_port = ports[1];
>  			sin6.sin6_flowinfo = 0;
> -			sin6.sin6_scope_id = 0;
> +			sin6.sin6_scope_id =
> +				ipv6_iface_scope_id(&ipv6_hdr(skb)->daddr,
> +						    opt->iif);
>  
>  			put_cmsg(msg, SOL_IPV6, IPV6_ORIGDSTADDR, sizeof(sin6), &sin6);
>  		}
> 

Acked-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
