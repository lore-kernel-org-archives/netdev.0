From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [v1 PATCH 0/7] rhashtable: Introduce inlined interface
Date: Sat, 21 Mar 2015 09:21:06 +1100
Message-ID: <20150320222106.GA24241@gondor.apana.org.au>
References: <20150320105421.GA18148@gondor.apana.org.au>
 <20150320.161743.1329037804732884094.davem@davemloft.net>
 <20150320212844.GC23301@gondor.apana.org.au>
 <20150320.181715.477950273744674777.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: tgraf@suug.ch, eric.dumazet@gmail.com, kaber@trash.net,
	netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ringil.hengli.com.au ([178.18.16.133]:60433 "EHLO
	ringil.hengli.com.au" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751131AbbCTWVN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 Mar 2015 18:21:13 -0400
Content-Disposition: inline
In-Reply-To: <20150320.181715.477950273744674777.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Mar 20, 2015 at 06:17:15PM -0400, David Miller wrote:
> From: Herbert Xu <herbert@gondor.apana.org.au>
> Date: Sat, 21 Mar 2015 08:28:44 +1100
> 
> > On Fri, Mar 20, 2015 at 04:17:43PM -0400, David Miller wrote:
> >>
> >> Why do you need that trailer[] think in the new netlink code?
> >> You only use it in an offsetof() expression and wouldn't sizeof
> >> the structure work just fine for that?  This also makes the
> >> memset() superfluous in the initializer function.
> > 
> > Aha I was wating for someone to ask :) Without the trailer it
> > gets padded to 16 bytes on x86-64.  I found this out because
> > netlink was mysteriously failing due to the extra padding not
> > getting zeroed. Designated initializers do not zero padding bytes,
> > so you'd need an explicit memset.  Besides, hashing another
> > four bytes with jhash that always contained zero seemed wasteful.
> 
> Then "offsetof(struct netlink_compare_arg, portid) + sizeof(u32)"?

But that should be identical to the trailer offset, no? The whole
structure gets padded to 16 bytes, not the trailer (since it's only
a char[]).

Cheers,
-- 
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
