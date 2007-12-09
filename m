From: Paul Moore <paul.moore@hp.com>
Subject: Re: IPsec replay sequence number overflow behavior? (RFC4303 section 3.3.3)
Date: Sun, 9 Dec 2007 09:37:56 -0500
Message-ID: <200712090937.56599.paul.moore@hp.com>
References: <E1J1Bfw-0006Kw-00@gondolin.me.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, latten@us.ibm.com
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailhub.hp.com ([192.151.27.10]:50402 "EHLO mailhub.hp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750789AbXLIOiw (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 9 Dec 2007 09:38:52 -0500
In-Reply-To: <E1J1Bfw-0006Kw-00@gondolin.me.apana.org.au>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Saturday 08 December 2007 9:13:48 pm Herbert Xu wrote:
> Paul Moore <paul.moore@hp.com> wrote:
> > If it is a bug, I think the basic fix should be pretty simple, changing
> > the above xfrm_output() code to the following:
> >
> >   if (x->type->flags & XFRM_TYPE_REPLAY_PROT) {
> >           XFRM_SKB_CB(skb)->seq = ++x->replay.oseq;
> > +          if (x->replay.oseq == 0)
> > +                  goto error;
>
> Yes we need this check.
>
> However please add an unlikely around it since it's a 1-in-4
> billion event :)

 :)

Thanks for clearing that up, I'll send a patch this week; complete with an 
unlikely (similar to the RFC quality IPsec audit patch I sent on Friday) and 
a decrement to the sequence counter in case of rollover.

-- 
paul moore
linux security @ hp
