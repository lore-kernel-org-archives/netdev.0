From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: Re: [PATCH 8/8] xfrm: Fix potential null pointer dereference in
 xdst_queue_output
Date: Thu, 29 Aug 2013 06:27:57 +0200
Message-ID: <20130829042757.GF7660@secunet.com>
References: <1377687895-5780-1-git-send-email-steffen.klassert@secunet.com>
 <1377687895-5780-9-git-send-email-steffen.klassert@secunet.com>
 <1377689787.8828.179.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([195.81.216.161]:45513 "EHLO a.mx.secunet.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752132Ab3H2E17 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 29 Aug 2013 00:27:59 -0400
Content-Disposition: inline
In-Reply-To: <1377689787.8828.179.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Aug 28, 2013 at 04:36:27AM -0700, Eric Dumazet wrote:
> On Wed, 2013-08-28 at 13:04 +0200, Steffen Klassert wrote:
> > ---
> >  net/xfrm/xfrm_policy.c |    9 +--------
> >  1 file changed, 1 insertion(+), 8 deletions(-)
> > 
> > diff --git a/net/xfrm/xfrm_policy.c b/net/xfrm/xfrm_policy.c
> > index e52cab3..f77c371 100644
> > --- a/net/xfrm/xfrm_policy.c
> > +++ b/net/xfrm/xfrm_policy.c
> > @@ -320,10 +320,8 @@ static void xfrm_queue_purge(struct sk_buff_head *list)
> >  {
> >  	struct sk_buff *skb;
> >  
> > -	while ((skb = skb_dequeue(list)) != NULL) {
> > -		dev_put(skb->dev);
> > +	while ((skb = skb_dequeue(list)) != NULL)
> >  		kfree_skb(skb);
> > -	}
> >  }
> >  
> 
> xfrm_queue_purge() now looks a lot like skb_queue_purge() ;)
> 

Oh, indeed. Looks like I was too much focused on fixing this bug
to notice that this function looks familiar now ;)

I'll do a followup patch to remove xfrm_queue_purge() in favor of
skb_queue_purge() or I generate an updated pull request, depending
what David prefers.
