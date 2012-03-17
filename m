From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] ipv6: fix incorrent ipv6 ipsec packet fragment
Date: Fri, 16 Mar 2012 21:58:13 -0700 (PDT)
Message-ID: <20120316.215813.1949007994742764009.davem@davemloft.net>
References: <1331888235-10368-1-git-send-email-gaofeng@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: steffen.klassert@secunet.com, eric.dumazet@gmail.com,
	netdev@vger.kernel.org
To: gaofeng@cn.fujitsu.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:39420 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752143Ab2CQE62 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 17 Mar 2012 00:58:28 -0400
In-Reply-To: <1331888235-10368-1-git-send-email-gaofeng@cn.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Gao feng <gaofeng@cn.fujitsu.com>
Date: Fri, 16 Mar 2012 16:57:15 +0800

> Since commit 299b0767(ipv6: Fix IPsec slowpath fragmentation problem)
> In func ip6_append_data,after call skb_put(skb, fraglen + dst_exthdrlen)
> the skb->len contains dst_exthdrlen,and we don't reduce dst_exthdrlen at last
> This will make fraggap>0 in next "while cycle",and cause the size of skb incorrent
> 
> Call skb_pull reduce skb->len before next "while cycle"
> 
> Signed-off-by: Gao feng <gaofeng@cn.fujitsu.com>

Steffen please review this patch.

> ---
>  net/ipv6/ip6_output.c |    3 ++-
>  1 files changed, 2 insertions(+), 1 deletions(-)
> 
> diff --git a/net/ipv6/ip6_output.c b/net/ipv6/ip6_output.c
> index d97e071..f67f840 100644
> --- a/net/ipv6/ip6_output.c
> +++ b/net/ipv6/ip6_output.c
> @@ -1450,7 +1450,8 @@ alloc_new_skb:
>  				kfree_skb(skb);
>  				goto error;
>  			}
> -
> +
> +			skb_pull(skb, dst_exthdrlen);
>  			offset += copy;
>  			length -= datalen - fraggap;
>  			transhdrlen = 0;
> -- 
> 1.7.5.4
