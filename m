From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [IPCOMP]: Fix truesize after decompression
Date: Wed, 12 Jul 2006 09:12:51 +1000
Message-ID: <20060711231251.GA6725@gondor.apana.org.au>
References: <BB1F4EFD574E9F409035BDA71C9612500242B8@exchange.i-bn> <20060711114544.GA11396@gondor.apana.org.au> <20060711.135553.106801039.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Daniel.Beschorner@facton.com, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:55055 "EHLO
	arnor.apana.org.au") by vger.kernel.org with ESMTP id S1751183AbWGKXNg
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 11 Jul 2006 19:13:36 -0400
To: David Miller <davem@davemloft.net>
Content-Disposition: inline
In-Reply-To: <20060711.135553.106801039.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Jul 11, 2006 at 01:55:53PM -0700, David Miller wrote:
> 
> I think it is possible cover a certain class of these situations
> from within pskb_expand_head.  For example, if skb->sk is NULL
> we can prove that updating skb->truesize is safe since no
> socket's buffer accounting can possible depend upon the truesize
> value of this skb.

Yes that's certainly possible.  However, we'll need to audit the few
spots (e.g., ATM) that use truesize without setting skb->sk.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
