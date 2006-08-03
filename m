From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: BUG: warning at net/core/dev.c:1171/skb_checksum_help() 2.6.18-rc3
Date: Thu, 3 Aug 2006 19:57:03 +1000
Message-ID: <20060803095703.GA9082@gondor.apana.org.au>
References: <44CD85FF.9010607@trash.net> <20060730.215907.58439803.davem@davemloft.net> <44CD9013.7020401@trash.net> <44CDDDF7.70004@trash.net> <20060731113050.GA25972@gondor.apana.org.au> <44CE4DCA.8000609@trash.net> <20060801122916.GA6177@gondor.apana.org.au> <44D1C205.4010509@trash.net> <20060803093309.GB8808@gondor.apana.org.au> <44D1C471.2050503@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:31238 "EHLO
	arnor.apana.org.au") by vger.kernel.org with ESMTP id S932449AbWHCJ5O
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 3 Aug 2006 05:57:14 -0400
To: Patrick McHardy <kaber@trash.net>
Content-Disposition: inline
In-Reply-To: <44D1C471.2050503@trash.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Aug 03, 2006 at 11:40:01AM +0200, Patrick McHardy wrote:
>
> > Are you sure? If ip_summed is CHECKSUM_COMPLETE then skb->csum is the
> > checksum of the payload *without* the pseudo header.
> 
> The pseudohdr is included indirectly through the tcp/udp checksum.

Yes of course, the payload gets balanced out by the header checksum,
but not the pseudoheader.  Now I get you :)

> Yes, the 32-bit thing is a bug, I meant it works fine without inverting
> the checksum.

Right, I forgot about the checksum invariance under negation.  In that
case we can get rid of the tildes two lines down as well for consistency.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
