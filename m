From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: [PATCH] Re: skb_segment() questions
Date: Wed, 1 Apr 2009 09:50:50 +0000
Message-ID: <20090401095049.GB5970@ff.dom.local>
References: <20090329020701.GA9983@gondor.apana.org.au> <20090401091801.GA5970@ff.dom.local> <20090401092457.GB19847@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: James Huang <jamesclhuang@gmail.com>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from wf-out-1314.google.com ([209.85.200.168]:34614 "EHLO
	wf-out-1314.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752145AbZDAJvB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 1 Apr 2009 05:51:01 -0400
Received: by wf-out-1314.google.com with SMTP id 29so3703409wff.4
        for <netdev@vger.kernel.org>; Wed, 01 Apr 2009 02:50:58 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20090401092457.GB19847@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Apr 01, 2009 at 05:24:57PM +0800, Herbert Xu wrote:
> On Wed, Apr 01, 2009 at 09:18:01AM +0000, Jarek Poplawski wrote:
> >
> > gso: Fix support for linear packets 2
> > 
> > The previous fix removed a check, which should be useful, only a bit
> > later, by skipping at least two similar checks and three useless
> > assignments in case a header is (still) copied.
> > 
> > Signed-off-by: Jarek Poplawski <jarkao2@gmail.com>
> > ---
> > 
> >  net/core/skbuff.c |    2 ++
> >  1 files changed, 2 insertions(+), 0 deletions(-)
> > 
> > diff --git a/net/core/skbuff.c b/net/core/skbuff.c
> > index ce6356c..2123a92 100644
> > --- a/net/core/skbuff.c
> > +++ b/net/core/skbuff.c
> > @@ -2594,6 +2594,8 @@ struct sk_buff *skb_segment(struct sk_buff *skb, int features)
> >  
> >  		skb_copy_from_linear_data_offset(skb, offset,
> >  						 skb_put(nskb, hsize), hsize);
> > +		if (pos >= offset + len)
> > +			continue;
> >  
> >  		while (pos < offset + len && i < nfrags) {
> >  			*frag = skb_shinfo(skb)->frags[i];
> 
> The common case (non-linear skb) is going to fail that check so 
> I'm no sure if it's warranted.

I guess you mean non-linear skb with a header smaller than mtu? Well,
if it's the most common case now, I agree.

Thanks,
Jarek P.
