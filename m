From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [RFC/T] [NET] give truesize warning when truesize differs
Date: Mon, 5 May 2008 23:04:05 +0800
Message-ID: <20080505150405.GA9626@gondor.apana.org.au>
References: <1209924728.3655.7.camel@johannes.berg> <1209993080.8245.16.camel@johannes.berg>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>
To: Johannes Berg <johannes@sipsolutions.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:42068 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1754764AbYEEPEM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 5 May 2008 11:04:12 -0400
Content-Disposition: inline
In-Reply-To: <1209993080.8245.16.camel@johannes.berg>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, May 05, 2008 at 03:11:20PM +0200, Johannes Berg wrote:
>
> >  static inline void skb_truesize_check(struct sk_buff *skb)
> >  {
> > -	int len = sizeof(struct sk_buff) + skb->len;
> > +#ifdef NET_SKBUFF_DATA_USES_OFFSET
> > +	int len = sizeof(struct sk_buff) + skb->end;
> > +#else
> > +	int len = sizeof(struct sk_buff) + (skb->end - skb->head);
> > +#endif
> 
> Umm, is this even correct? Should it check data_len? I seem to get the
> truesize warning a bit now:

It must check data_len.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
