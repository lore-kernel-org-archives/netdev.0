From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] ip: generate unique IP identificator if local
 fragmentation is allowed
Date: Wed, 18 Sep 2013 12:20:18 -0400 (EDT)
Message-ID: <20130918.122018.1088822749792394509.davem@davemloft.net>
References: <1379456700-8033-1-git-send-email-aatteka@nicira.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: aatteka@nicira.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:35479 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752918Ab3IRQUU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Sep 2013 12:20:20 -0400
In-Reply-To: <1379456700-8033-1-git-send-email-aatteka@nicira.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ansis Atteka <aatteka@nicira.com>
Date: Tue, 17 Sep 2013 15:25:00 -0700

> @@ -1317,6 +1317,7 @@ struct sk_buff *__ip_make_skb(struct sock *sk,
>  		ttl = ip_select_ttl(inet, &rt->dst);
>  
>  	iph = (struct iphdr *)skb->data;
> +
>  	iph->version = 4;
>  	iph->ihl = 5;
>  	iph->tos = inet->tos;
> @@ -1324,7 +1325,7 @@ struct sk_buff *__ip_make_skb(struct sock *sk,
>  	iph->ttl = ttl;
>  	iph->protocol = sk->sk_protocol;
>  	ip_copy_addrs(iph, fl4);
> -	ip_select_ident(iph, &rt->dst, sk);
> +	ip_select_ident(skb, &rt->dst, sk);
>  
>  	if (opt) {
>  		iph->ihl += opt->optlen>>2;

This transformation is not equivalent.

ip_select_ident() is going to use ip_hdr() which obtains the header
pointer via skb_network_header().

But here, the code is using skb->data for this, which is different.
