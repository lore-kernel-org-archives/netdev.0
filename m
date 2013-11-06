From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH net-next 3/3] net: allow to leave the buffer fragmented
 in skb_cow_data()
Date: Wed, 6 Nov 2013 20:48:11 +0800
Message-ID: <20131106124811.GA20404@gondor.apana.org.au>
References: <cover.1381923854.git.mathias.krause@secunet.com>
 <14f30e8f5f8405c1ca73b6d3a554441c1736142d.1381923854.git.mathias.krause@secunet.com>
 <20131106093028.GA18435@gondor.apana.org.au>
 <527A109E.5040000@secunet.com>
 <20131106095217.GA18851@gondor.apana.org.au>
 <527A391B.4050907@secunet.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>,
	Steffen Klassert <steffen.klassert@secunet.com>,
	Dmitry Tarnyagin <dmitry.tarnyagin@lockless.no>,
	netdev@vger.kernel.org
To: Mathias Krause <mathias.krause@secunet.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ringil.hengli.com.au ([178.18.16.133]:38479 "EHLO
	fornost.hengli.com.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1756037Ab3KFMsT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 Nov 2013 07:48:19 -0500
Content-Disposition: inline
In-Reply-To: <527A391B.4050907@secunet.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Nov 06, 2013 at 01:42:03PM +0100, Mathias Krause wrote:
>
> Well, skb_cow_data() will only copy, i.e. call __pskb_pull_tail(), in
> case the skb is either cloned or fragmented. As you already said it
> won't be cloned in your case. Does it contain fragments, i.e. is
> skb_shinfo(skb)->nr_frags != 0? If not, we won't copy with the current
> code either.

Whenever we say page it means nr_frags != 0.  So currently as
long as we have pages in our skb we will copy.  With your patch
we will no longer copy in the case where we have pages but the
skb isn't cloned.  In fact that is the whole point of your patch.

> Can you please explain why this would be needed? I still don't get the
> reasoning behind "pages are considered not writable at the moment even
> if they are anonymous".

As I said you don't know where the page in the skb came from.  It
may point to read-only memory or memory that's shared with another
task that isn't expecting things to change underneath it.

It may well turn out to most if not all cases of pages are safe to
be written to if skb_cloned == 0.  However, we'd need to do a full
audit of every source of page frags to be sure.  For example, you'd
need to look at net drivers and splice.

Cheers,
-- 
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
