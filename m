From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next RESEND] net: Do not call ndo_dflt_fdb_dump if
 ndo_fdb_dump is defined.
Date: Wed, 10 Dec 2014 23:32:39 -0500 (EST)
Message-ID: <20141210.233239.472984361665334371.davem@davemloft.net>
References: <c6756bd161048ac4b4407e308045fe73.squirrel@poczta.wsisiz.edu.pl>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jhs@mojatatu.com
To: h.sokolowski@wit.edu.pl
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:50240 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751774AbaLKEcm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 10 Dec 2014 23:32:42 -0500
In-Reply-To: <c6756bd161048ac4b4407e308045fe73.squirrel@poczta.wsisiz.edu.pl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Hubert Sokolowski" <h.sokolowski@wit.edu.pl>
Date: Wed, 10 Dec 2014 19:37:01 -0000

> This change restores the semantic that was present
> before 5e6d243587990a588143b9da3974833649595587
> "bridge: netlink dump interface at par with brctl"
> on how ndo_dflt_fdb_dump is called.
> This semantic is still used for add and del operations
> so let's keep it consistent.
> Driver can still call ndo_dflt_fdb_dump from inside
> its own fdb_dump routine when needed.
> 
> Signed-off-by: Hubert Sokolowski <h.sokolowski@wit.edu.pl>

Jamal, please review.

> ---
>  net/core/rtnetlink.c | 3 ++-
>  1 file changed, 2 insertions(+), 1 deletion(-)
> 
> diff --git a/net/core/rtnetlink.c b/net/core/rtnetlink.c
> index eaa057f..a9e5c37 100644
> --- a/net/core/rtnetlink.c
> +++ b/net/core/rtnetlink.c
> @@ -2692,10 +2692,11 @@ static int rtnl_fdb_dump(struct sk_buff *skb, struct netlink_callback *cb)
>  							 idx);
>  		}
> 
> -		idx = ndo_dflt_fdb_dump(skb, cb, dev, NULL, idx);
>  		if (dev->netdev_ops->ndo_fdb_dump)
>  			idx = dev->netdev_ops->ndo_fdb_dump(skb, cb, bdev, dev,
>  							    idx);
> +		else
> +			idx = ndo_dflt_fdb_dump(skb, cb, dev, NULL, idx);
> 
>  		cops = NULL;
>  	}
> -- 
> 1.9.3
> 
> 
> 
> 
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
