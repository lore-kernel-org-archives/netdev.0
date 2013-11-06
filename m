From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH net-next 3/3] net: allow to leave the buffer fragmented
 in skb_cow_data()
Date: Wed, 6 Nov 2013 17:52:17 +0800
Message-ID: <20131106095217.GA18851@gondor.apana.org.au>
References: <cover.1381923854.git.mathias.krause@secunet.com>
 <14f30e8f5f8405c1ca73b6d3a554441c1736142d.1381923854.git.mathias.krause@secunet.com>
 <20131106093028.GA18435@gondor.apana.org.au>
 <527A109E.5040000@secunet.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>,
	Steffen Klassert <steffen.klassert@secunet.com>,
	Dmitry Tarnyagin <dmitry.tarnyagin@lockless.no>,
	netdev@vger.kernel.org
To: Mathias Krause <mathias.krause@secunet.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ringil.hengli.com.au ([178.18.16.133]:47197 "EHLO
	fornost.hengli.com.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1755142Ab3KFJwW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 Nov 2013 04:52:22 -0500
Content-Disposition: inline
In-Reply-To: <527A109E.5040000@secunet.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Nov 06, 2013 at 10:49:18AM +0100, Mathias Krause wrote:
> On 06.11.2013 10:30, Herbert Xu wrote:
>
> > Hang on, you haven't explained why it is OK to write to pages.
> 
> Why wouldn't it if the skb isn't cloned?

Because if it's owned by an entity outside our stack (e.g., virt
host or app) then the skb itself won't be cloned.

> > What if said page is owned by the virt host or some app?
> 
> How would one detect such a case. I could image not by testing
> skb_shinfo(skb)->nr_frags as it is right now?

You can't.  That's why we always copy.  If you want to do this
properly then we'll need to add at least a bit to indicate whether
the page originated from within the network stack and we have
full ownership.

Cheers,
-- 
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
