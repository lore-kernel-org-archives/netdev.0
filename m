From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH 6/8] tcp: Add GRO support
Date: Sat, 13 Dec 2008 08:46:27 +1100
Message-ID: <20081212214627.GC11046@gondor.apana.org.au>
References: <20081212053116.GA2927@gondor.apana.org.au> <E1LB0d1-0000rd-B2@gondolin.me.apana.org.au> <20081212195615.GC27281@ioremap.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: Evgeniy Polyakov <zbr@ioremap.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:45169 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752944AbYLLVqc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 12 Dec 2008 16:46:32 -0500
Content-Disposition: inline
In-Reply-To: <20081212195615.GC27281@ioremap.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Dec 12, 2008 at 10:56:15PM +0300, Evgeniy Polyakov wrote:
>
> > +found:
> > +	flush = NAPI_GRO_CB(p)->flush;
> > +	flush |= flags & TCP_FLAG_CWR;
> > +	flush |= (flags ^ tcp_flag_word(th2)) &
> > +		  ~(TCP_FLAG_CWR | TCP_FLAG_FIN | TCP_FLAG_PSH);
> > +	flush |= th->ack_seq != th2->ack_seq || th->window != th2->window;
> > +	flush |= memcmp(th + 1, th2 + 1, thlen - sizeof(*th));
> > +
> > +	total = p->len;
> > +	mss = total;
> > +	if (skb_shinfo(p)->frag_list)
> > +		mss = skb_shinfo(p)->frag_list->len;
> > +
> > +	flush |= skb->len > mss || skb->len <= 0;
> > +	flush |= ntohl(th2->seq) + total != ntohl(th->seq);
> > +
> 
> No timestamp check?

The memcmp does that for us.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
