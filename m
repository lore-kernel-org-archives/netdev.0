From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next] ipv6: Initialize the neighbour pointer of
 rt6_info on allocation
Date: Thu, 05 Jul 2012 17:16:44 +0200
Message-ID: <1341501404.2583.4267.camel@edumazet-glaptop>
References: <20120705131828.GE1869@secunet.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Steffen Klassert <steffen.klassert@secunet.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ey0-f174.google.com ([209.85.215.174]:45321 "EHLO
	mail-ey0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752718Ab2GEPQt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 Jul 2012 11:16:49 -0400
Received: by eaak11 with SMTP id k11so3295104eaa.19
        for <netdev@vger.kernel.org>; Thu, 05 Jul 2012 08:16:48 -0700 (PDT)
In-Reply-To: <20120705131828.GE1869@secunet.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2012-07-05 at 15:18 +0200, Steffen Klassert wrote:
> git commit 97cac082 (ipv6: Store route neighbour in rt6_info struct)
> added a neighbour pointer to rt6_info. Currently we don't initialize
> this pointer at allocation time. We assume this pointer to be valid
> if it is not a null pointer, so initialize it on allocation.
> 
> Signed-off-by: Steffen Klassert <steffen.klassert@secunet.com>
> ---
>  net/ipv6/route.c |    2 +-
>  1 files changed, 1 insertions(+), 1 deletions(-)
> 
> diff --git a/net/ipv6/route.c b/net/ipv6/route.c
> index ceff71d..6cc6c88 100644
> --- a/net/ipv6/route.c
> +++ b/net/ipv6/route.c
> @@ -273,7 +273,7 @@ static inline struct rt6_info *ip6_dst_alloc(struct net *net,
>  					0, 0, flags);
>  
>  	if (rt) {
> -		memset(&rt->rt6i_table, 0,
> +		memset(&rt->n, 0,
>  		       sizeof(*rt) - sizeof(struct dst_entry));
>  		rt6_init_peer(rt, table ? &table->tb6_peers : net->ipv6.peers);
>  	}

Hmm, could we find a way to avoid this for future changes ?

We know dst_entry is the first field, so maybe :

if (rt) {
	struct dst_entry *dst = (struct dst_entry *)rt;

	memset(dst + 1, 0, sizeof(*rt) - sizeof(*dst));
