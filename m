From: David Miller <davem@davemloft.net>
Subject: Re: bridge: Fix IGMP3 report parsing
Date: Wed, 07 Apr 2010 20:52:48 -0700 (PDT)
Message-ID: <20100407.205248.113724360.davem@davemloft.net>
References: <20100408012634.GC18649@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, banyeer@yahoo.com
To: herbert@gondor.apana.org.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:53545
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756005Ab0DHDwq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 7 Apr 2010 23:52:46 -0400
In-Reply-To: <20100408012634.GC18649@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Herbert Xu <herbert@gondor.apana.org.au>
Date: Thu, 8 Apr 2010 09:26:34 +0800

> Hi:
> 
> bridge: Fix IGMP3 report parsing
> 
> The IGMP3 report parsing is looking at the wrong address for
> group records.  This patch fixes it.
> 
> Reported-by: Banyeer <banyeer@yahoo.com>
> Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

I think you're adding as many bugs as you are fixing here :-)

> @@ -719,11 +719,11 @@ static int br_multicast_igmp3_report(struct net_bridge *br,
>  	len = sizeof(*ih);
>  
>  	for (i = 0; i < num; i++) {
> +		grec = (void *)(skb->data + len);
>  		len += sizeof(*grec);
>  		if (!pskb_may_pull(skb, len))
>  			return -EINVAL;
>  
> -		grec = (void *)(skb->data + len);
>  		group = grec->grec_mca;
>  		type = grec->grec_type;
>  

If pskb_may_pull() actually does anything non-trivial,
skb->data will change and you'll be referring to freed
up memory.

That's probably why you had the grec assignment where
you originally had it in the first place :-)
