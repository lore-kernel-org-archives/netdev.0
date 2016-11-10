From: David Miller <davem@davemloft.net>
Subject: Re: [Regression w/ patch] Restore network resistance to weird ICMP
 messages
Date: Wed, 09 Nov 2016 20:22:10 -0500 (EST)
Message-ID: <20161109.202210.1450575682716819324.davem@davemloft.net>
References: <CAO1wt+Y7JfeCXnrR5BeZ7K6dErmB3nfdA4mRkFQ21S=VPCkLXg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: 8BIT
Cc: kuznet@ms2.inr.ac.ru, jmorris@namei.org, yoshfuji@linux-ipv6.org,
        kaber@trash.net, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: googuy@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:46500 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751420AbcKJBWN (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 9 Nov 2016 20:22:13 -0500
In-Reply-To: <CAO1wt+Y7JfeCXnrR5BeZ7K6dErmB3nfdA4mRkFQ21S=VPCkLXg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Vicente Jiménez <googuy@gmail.com>
Date: Mon, 7 Nov 2016 12:11:59 +0100

> From bfc9a00e6b78d8eb60e46dacd7d761669d29a573 Mon Sep 17 00:00:00 2001
> From: Vicente Jimenez Aguilar <googuy@gmail.com>
> Date: Mon, 31 Oct 2016 13:10:29 +0100
> Subject: [PATCH] ipv4: icmp: Fix pMTU handling for rarest case
> 
> Restore network resistance to weird ICMP fragmentation needed messages
> with next hop MTU equal to (or exceeding) dropped packet size
> 
> Fixes: 46517008e116 ("ipv4: Kill ip_rt_frag_needed().")
> Signed-off-by: Vicente Jimenez Aguilar <googuy@gmail.com>
> ---
>  net/ipv4/icmp.c | 7 +++++++
>  1 file changed, 7 insertions(+)
> 
> diff --git a/net/ipv4/icmp.c b/net/ipv4/icmp.c
> index 38abe70..c0af1d2 100644
> --- a/net/ipv4/icmp.c
> +++ b/net/ipv4/icmp.c
> @@ -776,6 +776,7 @@ static bool icmp_unreach(struct sk_buff *skb)
>  	struct icmphdr *icmph;
>  	struct net *net;
>  	u32 info = 0;
> +	unsigned short old_mtu;
>  
>  	net = dev_net(skb_dst(skb)->dev);
>  

Order local variable declarations from longest to shortest line
please.

> +				if ( info >= old_mtu )

There should be no space after the '(' and before the ')' in this
conditional.
