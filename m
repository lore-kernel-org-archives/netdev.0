From: Brian Haley <brian.haley@hp.com>
Subject: Re: [PATCH net-next-2.6] net: optimize INET input path further
Date: Wed, 01 Dec 2010 12:37:55 -0500
Message-ID: <4CF687F3.7030107@hp.com>
References: <1291179847.2856.452.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g6t0187.atlanta.hp.com ([15.193.32.64]:14958 "EHLO
	g6t0187.atlanta.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751327Ab0LARs4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 1 Dec 2010 12:48:56 -0500
In-Reply-To: <1291179847.2856.452.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 12/01/2010 12:04 AM, Eric Dumazet wrote:
>  struct sock_common {
> -	/*
> -	 * first fields are not copied in sock_copy()
> +	/* skc_daddr and skc_rcv_saddr must be grouped :
> +	 * cf INET_MATCH() and INET_TW_MATCH()
>  	 */
> -	union {
> -		struct hlist_node	skc_node;
> -		struct hlist_nulls_node skc_nulls_node;
> -	};
> -	atomic_t		skc_refcnt;
> -	int			skc_tx_queue_mapping;
> +	__be32			skc_daddr;
> +	__be32			skc_rcv_saddr;
>  
>  	union  {
>  		unsigned int	skc_hash;

Putting IPv4 addresses in sock_common doesn't make it so common anymore :)

Is it possible to make this a union so other address families like IPv6
can benefit from this as well, or will that blow the whole cache line
effect you were trying to achieve?

-Brian
