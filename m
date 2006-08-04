From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [XFRM]: Improve MTU estimation
Date: Fri, 4 Aug 2006 21:54:57 +1000
Message-ID: <20060804115457.GA3995@gondor.apana.org.au>
References: <44D30A48.4050403@trash.net> <44D312EF.8010202@trash.net> <20060804100121.GA17239@gondor.apana.org.au> <44D31CCE.7020301@trash.net> <20060804101345.GA17583@gondor.apana.org.au> <44D32B57.2000304@trash.net> <20060804111604.GA25693@gondor.apana.org.au> <20060804112544.GA28774@gondor.apana.org.au> <44D33477.2060803@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Kernel Netdev Mailing List <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:14099 "EHLO
	arnor.apana.org.au") by vger.kernel.org with ESMTP id S932609AbWHDLy7
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 4 Aug 2006 07:54:59 -0400
To: Patrick McHardy <kaber@trash.net>
Content-Disposition: inline
In-Reply-To: <44D33477.2060803@trash.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Aug 04, 2006 at 01:50:15PM +0200, Patrick McHardy wrote:
> 
> Now I get it, thanks :) I missed that the IP header isn't part of the
> length when it is aligned. So the worst-case increases by block-size
> - 4 (- 8 for IPv6). How does this look?

That should work.

If you want to be fancy you can also take any bits you shaved off outside
the encrypted block into account.  For example, in the 1500 case we have
to shave off 4 bytes to make it a multiple of 8, therefore there is no
extra overhead for transport mode at all.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
