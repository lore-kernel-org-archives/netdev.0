From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH 2/2] ipv4: Initialize on-stack cork more efficiently.
Date: Fri, 06 May 2011 15:44:54 -0700
Message-ID: <1304721894.11874.28.camel@Joe-Laptop>
References: <20110506.152623.232747437.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, herbert@gondor.apana.org.au,
	eric.dumazet@gmail.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.perches.com ([173.55.12.10]:1299 "EHLO mail.perches.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751034Ab1EFWoz (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 6 May 2011 18:44:55 -0400
In-Reply-To: <20110506.152623.232747437.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2011-05-06 at 15:26 -0700, David Miller wrote:
> ip_setup_cork() explicitly initializes every member of
> inet_cork except flags, addr, and opt.  So we can simply
> set those three members to zero instead of using a
> memset() via an empty struct assignment.
> Signed-off-by: David S. Miller <davem@davemloft.net>
> diff --git a/net/ipv4/ip_output.c b/net/ipv4/ip_output.c
[]
> @@ -1417,6 +1417,9 @@ struct sk_buff *ip_make_skb(struct sock *sk,
>  
>  	__skb_queue_head_init(&queue);
>  
> +	cork.flags = 0;
> +	cork.addr = 0;
> +	cork.opt = 0;

	cork.opt = NULL;

>  	err = ip_setup_cork(sk, &cork, ipc, rtp);
>  	if (err)
>  		return ERR_PTR(err);

Perhaps it'd be better to move the initialization
of all cork fields to ip_setup_cork.


