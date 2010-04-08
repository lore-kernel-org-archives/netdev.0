From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH] tcp: Set CHECKSUM_UNNECESSARY in tcp_init_nondata_skb
Date: Thu, 8 Apr 2010 23:39:06 +0800
Message-ID: <20100408153906.GA26376@gondor.apana.org.au>
References: <20100408.012617.98660541.davem@davemloft.net> <20100408135715.GA24890@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ringil.hengli.com.au ([216.59.3.182]:55957 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1758823Ab0DHPjJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 8 Apr 2010 11:39:09 -0400
Content-Disposition: inline
In-Reply-To: <20100408135715.GA24890@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Apr 08, 2010 at 09:57:15PM +0800, Herbert Xu wrote:
> 
> The problem here is that for non-data packets CHECKSUM_PARTIAL
> can actually end up being worse if we wind up going out through
> an interface that doesn't support checksums.

I don't know what I was thinking but the above is totally wrong.
CHECKSUM_PARTIAL should be just fine on non-checksuming interfaces
as we'll checksum everything once just as the CHECKSUM_NONE case
would.

So with that in mind, we don't need my CHECKSUM_UNNECESSARY patch
at all and your CHECKSUM_PARTIAL path is the right solution after
all :)

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
