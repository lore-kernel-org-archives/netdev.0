From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] ipv4: fix a bug in ping_err().
Date: Thu, 21 Feb 2013 13:08:09 -0500 (EST)
Message-ID: <20130221.130809.1972679391726935145.davem@davemloft.net>
References: <1361441394-16668-1-git-send-email-lw@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: lw@cn.fujitsu.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:60996 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756240Ab3BUSIK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 21 Feb 2013 13:08:10 -0500
In-Reply-To: <1361441394-16668-1-git-send-email-lw@cn.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Li Wei <lw@cn.fujitsu.com>
Date: Thu, 21 Feb 2013 18:09:54 +0800

> We should get 'type' and 'code' from the outer ICMP header.
> 
> Signed-off-by: Li Wei <lw@cn.fujitsu.com>
> ---
>  net/ipv4/ping.c | 4 ++--
>  1 file changed, 2 insertions(+), 2 deletions(-)
> 
> diff --git a/net/ipv4/ping.c b/net/ipv4/ping.c
> index 55c4ee1..2e91006 100644
> --- a/net/ipv4/ping.c
> +++ b/net/ipv4/ping.c
> @@ -322,8 +322,8 @@ void ping_err(struct sk_buff *skb, u32 info)
>  	struct iphdr *iph = (struct iphdr *)skb->data;
>  	struct icmphdr *icmph = (struct icmphdr *)(skb->data+(iph->ihl<<2));
>  	struct inet_sock *inet_sock;
> -	int type = icmph->type;
> -	int code = icmph->code;
> +	int type = icmp_hdr(skb)->type;
> +	int code = icmp_hdr(skb)->code;

Isn't that the same thing at this point?  skb->data points to the
outer IPv4 header at this point, doesn't it?
