From: Hangbin Liu <liuhangbin@gmail.com>
Subject: Re: [PATCH net] ipv6: make sure dev is not NULL before call
 ip6_frag_reasm
Date: Tue, 9 May 2017 21:40:34 +0800
Message-ID: <20170509134033.GB4649@leo.usersys.redhat.com>
References: <1494212964-17861-1-git-send-email-liuhangbin@gmail.com>
 <1494255030.7796.56.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f193.google.com ([209.85.192.193]:36345 "EHLO
        mail-pf0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753098AbdEINkp (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 9 May 2017 09:40:45 -0400
Received: by mail-pf0-f193.google.com with SMTP id v14so77058pfd.3
        for <netdev@vger.kernel.org>; Tue, 09 May 2017 06:40:44 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <1494255030.7796.56.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, May 08, 2017 at 07:50:30AM -0700, Eric Dumazet wrote:
> On Mon, 2017-05-08 at 11:09 +0800, Hangbin Liu wrote:
> > Since ip6_frag_reasm() will call __in6_dev_get(dev), which will access
> > dev->ip6_ptr. We need to make sure dev is not NULL.
> > 
> > Signed-off-by: Hangbin Liu <liuhangbin@gmail.com>
> > ---
> >  net/ipv6/reassembly.c | 2 +-
> >  1 file changed, 1 insertion(+), 1 deletion(-)
> > 
> > diff --git a/net/ipv6/reassembly.c b/net/ipv6/reassembly.c
> > index e1da5b8..e3ebd62 100644
> > --- a/net/ipv6/reassembly.c
> > +++ b/net/ipv6/reassembly.c
> > @@ -348,7 +348,7 @@ static int ip6_frag_queue(struct frag_queue *fq, struct sk_buff *skb,
> >  		fq->q.flags |= INET_FRAG_FIRST_IN;
> >  	}
> >  
> > -	if (fq->q.flags == (INET_FRAG_FIRST_IN | INET_FRAG_LAST_IN) &&
> > +	if (dev && fq->q.flags == (INET_FRAG_FIRST_IN | INET_FRAG_LAST_IN) &&
> >  	    fq->q.meat == fq->q.len) {
> >  		int res;
> >  		unsigned long orefdst = skb->_skb_refdst;
> 
> 
> How dev could be possibly NULL here ?

I saw we checked the dev in this function

	dev = skb->dev;
	if (dev) {
		fq->iif = dev->ifindex;
		skb->dev = NULL;
        }

and upper caller ipv6_frag_rcv()

	fq = fq_find(net, fhdr->identification, &hdr->saddr, &hdr->daddr,
		     skb->dev ? skb->dev->ifindex : 0, ip6_frag_ecn(hdr));


Apologise that I did not do enough research to make sure whether skb->dev
could be NULL or not. I will do the check recently and reply when got a
confirmation.

Regards
Hangbin
