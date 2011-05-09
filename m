From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH 1/2] ipv4: Pass flow keys down into datagram packet
 building engine.
Date: Sun, 8 May 2011 18:14:46 -0700 (PDT)
Message-ID: <Pine.LNX.4.30.1105081811570.26257-100000@mail.perches.com>
References: <20110508.180753.241908549.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.perches.com ([173.55.12.10]:1349 "EHLO mail.perches.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756285Ab1EIBOx (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 8 May 2011 21:14:53 -0400
In-Reply-To: <20110508.180753.241908549.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 8 May 2011, David Miller wrote:
> +static struct rtable *icmp_route_lookup(struct net *net,
> +					struct flowi4 *fl4,
> +					struct sk_buff *skb_in,
>  					const struct iphdr *iph,
>  					__be32 saddr, u8 tos,
>  					int type, int code,
>  					struct icmp_bxm *param)
>  {
[]
> +	memset(&fl4, 0, sizeof(fl4));

	memset(fl4, 0, sizeof(*fl4));

> +	fl4->daddr = (param->replyopts.opt.opt.srr ?
> +		      param->replyopts.opt.opt.faddr : iph->saddr);

