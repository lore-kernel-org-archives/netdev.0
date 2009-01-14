From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH] tcp: splice as many packets as possible at once
Date: Wed, 14 Jan 2009 22:28:08 +1100
Message-ID: <20090114112808.GA18662@gondor.apana.org.au>
References: <20090113.232710.55011568.davem@davemloft.net> <20090114082630.GB16692@gondor.apana.org.au> <20090114085308.GB4234@ff.dom.local> <20090114.012919.117682429.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: jarkao2@gmail.com, zbr@ioremap.net, dada1@cosmosbay.com, w@1wt.eu,
	ben@zeus.com, mingo@elte.hu, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, jens.axboe@oracle.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:36460 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1755120AbZANL2s (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 14 Jan 2009 06:28:48 -0500
Content-Disposition: inline
In-Reply-To: <20090114.012919.117682429.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jan 14, 2009 at 01:29:19AM -0800, David Miller wrote:
> 
> It's a simple fix, but as Herbert stated it leaves other ->sendpage()
> implementations exposed to data corruption when the from side of the
> pipe buffer is a socket.
> 
> That, to me, is almost worse than a bad fix.

Yep, so far nobody has verified the disk path at all.  So for all
we know, if there is a delay on the way to disk, the exact same
thing can occur.

Besides, the PageSlab thing is going to copy for network to network
anyway.

> So, I've put together a full commit message and Jarek's patch
> below.  One thing I notice is that the silly skb_clone() done
> by SKB splicing is no longer necessary.
> 
> We could get rid of that to offset (some) of the cost we are
> adding with this bug fix.
> 
> Comments?

Yes that's probably a good idea.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
