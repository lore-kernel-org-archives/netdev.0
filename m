From: Pavel Emelyanov <xemul@parallels.com>
Subject: Re: udp_diag: Fix socket skipping within chain
Date: Mon, 26 Jan 2015 14:07:15 +0300
Message-ID: <54C61FE3.5030001@parallels.com>
References: <20150123210240.GA1569@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
To: Herbert Xu <herbert@gondor.apana.org.au>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.parallels.com ([199.115.105.18]:45885 "EHLO
	mx2.parallels.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752712AbbAZLH0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 26 Jan 2015 06:07:26 -0500
In-Reply-To: <20150123210240.GA1569@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 01/24/2015 12:02 AM, Herbert Xu wrote:
> While working on rhashtable walking I noticed that the UDP diag
> dumping code is buggy.  In particular, the socket skipping within
> a chain never happens, even though we record the number of sockets
> that should be skipped.
> 
> As this code was supposedly copied from TCP, this patch does what
> TCP does and resets num before we walk a chain.
> 
> Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

Acked-by: Pavel Emelyanov <xemul@parallels.com>

Thanks,
Pavel

> diff --git a/net/ipv4/udp_diag.c b/net/ipv4/udp_diag.c
> index 7927db0..4a000f1 100644
> --- a/net/ipv4/udp_diag.c
> +++ b/net/ipv4/udp_diag.c
> @@ -99,11 +99,13 @@ static void udp_dump(struct udp_table *table, struct sk_buff *skb, struct netlin
>  	s_slot = cb->args[0];
>  	num = s_num = cb->args[1];
>  
> -	for (slot = s_slot; slot <= table->mask; num = s_num = 0, slot++) {
> +	for (slot = s_slot; slot <= table->mask; s_num = 0, slot++) {
>  		struct sock *sk;
>  		struct hlist_nulls_node *node;
>  		struct udp_hslot *hslot = &table->hash[slot];
>  
> +		num = 0;
> +
>  		if (hlist_nulls_empty(&hslot->head))
>  			continue;
>  
> 
