From: Simon Horman <horms@verge.net.au>
Subject: Re: [PATCH] GRE: Use IS_ERR_OR_NULL in gre_gso_segment
Date: Mon, 22 Apr 2013 10:35:57 +0900
Message-ID: <20130422013557.GF15680@verge.net.au>
References: <1366354120-11230-1-git-send-email-horms@verge.net.au>
 <1366367073.3205.105.camel@edumazet-glaptop>
 <20130419.142852.1914290650706288260.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: eric.dumazet@gmail.com, netdev@vger.kernel.org, xeb@mail.ru
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from kirsty.vergenet.net ([202.4.237.240]:49745 "EHLO
	kirsty.vergenet.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752946Ab3DVBgE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 21 Apr 2013 21:36:04 -0400
Content-Disposition: inline
In-Reply-To: <20130419.142852.1914290650706288260.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Apr 19, 2013 at 02:28:52PM -0400, David Miller wrote:
> From: Eric Dumazet <eric.dumazet@gmail.com>
> Date: Fri, 19 Apr 2013 03:24:33 -0700
> 
> > On Fri, 2013-04-19 at 15:48 +0900, Simon Horman wrote:
> >> Signed-off-by: Simon Horman <horms@verge.net.au>
> >> ---
> >>  net/ipv4/gre.c |    2 +-
> >>  1 file changed, 1 insertion(+), 1 deletion(-)
> >> 
> >> diff --git a/net/ipv4/gre.c b/net/ipv4/gre.c
> >> index d2d5a99..0ae998b 100644
> >> --- a/net/ipv4/gre.c
> >> +++ b/net/ipv4/gre.c
> >> @@ -168,7 +168,7 @@ static struct sk_buff *gre_gso_segment(struct sk_buff *skb,
> >>  	/* segment inner packet. */
> >>  	enc_features = skb->dev->hw_enc_features & netif_skb_features(skb);
> >>  	segs = skb_mac_gso_segment(skb, enc_features);
> >> -	if (!segs || IS_ERR(segs))
> >> +	if (IS_ERR_OR_NULL(segs))
> >>  		goto out;
> >>  
> >>  	skb = segs;
> > 
> > Hi Simon
> > 
> > AFAIK I would change things so that NULL is not a possible value.
> > 
> > I don't really like IS_ERR_OR_NULL() because it hides some lazyness of
> > ours, and is more expensive (2 tests)
> > 
> > If we return NULL for an error, why not instead return -Esomething,
> > since caller is OK to get -ENOMEM,-Exxxxx,... ?
> 
> Sometimes IS_ERR_OR_NULL is appropriate, but not here, since the caller
> can more easily just provide good error codes all the time instead of
> sometimes returning nULL.

I am confused.

I'm not sure that my change actually alters the logic at all.
Is the suggestion that the logic should be changed somehow?
