From: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Subject: Re: [PATCH net-next v4 4/4] ipv6: report sin6_scope_id if sockopt
 RECVORIGDSTADDR is set
Date: Sat, 09 Mar 2013 01:30:42 +0900
Message-ID: <513A1232.7040707@linux-ipv6.org>
References: <20130308120726.GA5174@order.stressinduktion.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org, David Miller <davem@davemloft.net>,
	YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 94.43.138.210.xn.2iij.net ([210.138.43.94]:60596 "EHLO
	mail.st-paulia.net" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S933136Ab3CHQan (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 8 Mar 2013 11:30:43 -0500
In-Reply-To: <20130308120726.GA5174@order.stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hannes Frederic Sowa wrote:
> v4:
> a) unchanged
> 
> Cc: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
> Acked-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
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
