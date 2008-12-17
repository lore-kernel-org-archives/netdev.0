From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH] tcp: make urg+gso work for real this time
Date: Thu, 18 Dec 2008 10:31:05 +1100
Message-ID: <20081217233105.GB28582@gondor.apana.org.au>
References: <20081217212907.GA27243@gondor.apana.org.au> <20081217225231.GA28052@gondor.apana.org.au> <20081217231543.GA28459@gondor.apana.org.au> <20081217.152118.103503644.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: kuznet@ms2.inr.ac.ru, ptesarik@suse.cz, ilpo.jarvinen@helsinki.fi,
	netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:32902 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751715AbYLQXbZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 17 Dec 2008 18:31:25 -0500
Content-Disposition: inline
In-Reply-To: <20081217.152118.103503644.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Dec 17, 2008 at 03:21:18PM -0800, David Miller wrote:
> From: Herbert Xu <herbert@gondor.apana.org.au>
> Date: Thu, 18 Dec 2008 10:15:43 +1100
> 
> > +		if (between(tp->snd_up, tcb->seq + 1, tcb->seq + 0xFFFF)) {
> > +			th->urg_ptr = htons(tp->snd_up - tcb->seq);
> > +			th->urg = 1;
> > +		} else if (after(tcb->seq + 0xFFFF, tp->snd_nxt)) {
> > +			th->urg_ptr = 0xFFFF;
> > +			th->urg = 1;
> > +		}
> 
> What does this make happen for a jumbo frame where the urgent pointer
> is within this packet, yet is beyond the 0xffff offset limit?

Just how on earth can we build such a packet when our skb is designed
to carry 64K maximum?

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
