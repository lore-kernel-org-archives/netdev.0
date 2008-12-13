From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH 6/8] tcp: Add GRO support
Date: Sat, 13 Dec 2008 14:19:45 +1100
Message-ID: <20081213031945.GA14324@gondor.apana.org.au>
References: <20081212053116.GA2927@gondor.apana.org.au> <E1LB0d1-0000rd-B2@gondolin.me.apana.org.au> <20081212195615.GC27281@ioremap.net> <20081212214627.GC11046@gondor.apana.org.au> <20081213024046.GB807@ioremap.net> <20081213024644.GB14056@gondor.apana.org.au> <20081213031019.GE807@ioremap.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: Evgeniy Polyakov <zbr@ioremap.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:60755 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1753932AbYLMDTv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 12 Dec 2008 22:19:51 -0500
Content-Disposition: inline
In-Reply-To: <20081213031019.GE807@ioremap.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Dec 13, 2008 at 06:10:19AM +0300, Evgeniy Polyakov wrote:
>
> Some stacks use just increased counter since it is allowed by the RFC :)
> Probably 'not sane' is appropriate name, but still... Probably not a

Well one big reason why TSO worked so well is because the rest
of stack (well most of it) simply treated it as a large packet.
As it stands this means keeping below the 64K threshold (e.g.,
the IP header length field is 16 bits long).

In future of course we'd want to increase this, be it through
using IPv6 or some other means.

> serious problem, but what if just check the timestamp option before/after
> like it was in LRO?

As I said I don't think the restriction on the timestamp is such
a big deal.  At the sort of speeds where merging is actually useful
only an insane clock frequency would require us to merge packets
with different time stamps.  Note also that the limited length of
the TCP timestamp option means that insane clock frequencies aren't
practical anyway as it'll wrap too quickly, thus defeating its
purpose.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
