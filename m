From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/2 v2] xfrm: fix a potential use after free in
 xfrm4_policy.c
Date: Wed, 22 Oct 2014 15:35:46 -0400 (EDT)
Message-ID: <20141022.153546.1208352838031672211.davem@davemloft.net>
References: <1413968993-13528-1-git-send-email-roy.qing.li@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: roy.qing.li@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:60815 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932493AbaJVTfr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 22 Oct 2014 15:35:47 -0400
In-Reply-To: <1413968993-13528-1-git-send-email-roy.qing.li@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: roy.qing.li@gmail.com
Date: Wed, 22 Oct 2014 17:09:52 +0800

> From: Li RongQing <roy.qing.li@gmail.com>
> 
> pskb_may_pull() maybe change skb->data and make xprth pointer oboslete,
> so recompute the xprth
> 
> Signed-off-by: Li RongQing <roy.qing.li@gmail.com>
> ---
> Diff with v1: NEXT_HEAD add a length parameter, which hide on v1
> 
>  net/ipv4/xfrm4_policy.c |   21 +++++++++++++--------
>  1 file changed, 13 insertions(+), 8 deletions(-)
> 
> diff --git a/net/ipv4/xfrm4_policy.c b/net/ipv4/xfrm4_policy.c
> index 6156f68..d7b33c5 100644
> --- a/net/ipv4/xfrm4_policy.c
> +++ b/net/ipv4/xfrm4_policy.c
> @@ -98,11 +98,14 @@ static int xfrm4_fill_dst(struct xfrm_dst *xdst, struct net_device *dev,
>  	return 0;
>  }
>  
> +#define NEXT_HEAD(skb, length) (skb_network_header(skb) + length)
> +

If you're going to properly have arguments, use an inline function
rather a macro so you get type checking.

THanks.
