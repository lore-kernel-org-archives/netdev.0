From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH ipsec 2/3] ipv6: xfrm: dereference inner ipv6 header if
 encapsulated
Date: Sat, 17 Aug 2013 12:03:54 -0700
Message-ID: <1376766234.21329.11.camel@edumazet-glaptop>
References: <20130817175130.GA7039@order.stressinduktion.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, steffen.klassert@secunet.com
To: Hannes Frederic Sowa <hannes@stressinduktion.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f182.google.com ([209.85.192.182]:38169 "EHLO
	mail-pd0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754125Ab3HQTD4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 17 Aug 2013 15:03:56 -0400
Received: by mail-pd0-f182.google.com with SMTP id r10so2443436pdi.27
        for <netdev@vger.kernel.org>; Sat, 17 Aug 2013 12:03:55 -0700 (PDT)
In-Reply-To: <20130817175130.GA7039@order.stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 2013-08-17 at 19:51 +0200, Hannes Frederic Sowa wrote:
> In xfrm6_local_error use inner_header if the packet was encapsulated.
> 
> Cc: Steffen Klassert <steffen.klassert@secunet.com>
> Signed-off-by: Hannes Frederic Sowa <hannes@stressinduktion.org>
> ---
> 
> This patch is based on Steffen Klassert's ipsec tree. 
> 
>  net/ipv6/xfrm6_output.c | 4 +++-
>  1 file changed, 3 insertions(+), 1 deletion(-)
> 
> diff --git a/net/ipv6/xfrm6_output.c b/net/ipv6/xfrm6_output.c
> index 3ac5ab2..45effcc 100644
> --- a/net/ipv6/xfrm6_output.c
> +++ b/net/ipv6/xfrm6_output.c
> @@ -59,10 +59,12 @@ static void xfrm6_local_rxpmtu(struct sk_buff *skb, u32 mtu)
>  void xfrm6_local_error(struct sk_buff *skb, u32 mtu)
>  {
>  	struct flowi6 fl6;
> +	struct ipv6hdr *hdr;
>  	struct sock *sk = skb->sk;
>  
> +	hdr = skb->encapsulation ? inner_ipv6_hdr(skb) : ipv6_hdr(skb);
>  	fl6.fl6_dport = inet_sk(sk)->inet_dport;
> -	fl6.daddr = ipv6_hdr(skb)->daddr;
> +	fl6.daddr = hdr->daddr;
>  
>  	ipv6_local_error(sk, EMSGSIZE, &fl6, mtu);
>  }

You could have use "const struct ipv6hdr *hdr;", but otherwise :

Acked-by: Eric Dumazet <edumazet@google.com>
