From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: Patch for tbench regression.
Date: Mon, 29 Sep 2008 17:51:26 +0800
Message-ID: <20080929095126.GA25371@gondor.apana.org.au>
References: <20080928211530.GA9341@2ka.mipt.ru> <20080929031244.GA22619@gondor.apana.org.au> <20080929053605.GA21663@2ka.mipt.ru> <20080929054052.GA23600@gondor.apana.org.au> <20080929055203.GA3460@2ka.mipt.ru> <20080929064006.GA23967@gondor.apana.org.au> <20080929064518.GA10653@2ka.mipt.ru> <20080929070213.GA24146@gondor.apana.org.au> <20080929094352.GA25273@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org,
	Christoph Lameter <cl@linux-foundation.org>,
	Mel Gorman <mel@csn.ul.ie>, David Miller <davem@davemloft.net>,
	Lennert Buytenhek <buytenh@marvell.com>
To: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:59436 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751711AbYI2Jvb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 29 Sep 2008 05:51:31 -0400
Content-Disposition: inline
In-Reply-To: <20080929094352.GA25273@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Sep 29, 2008 at 05:43:52PM +0800, Herbert Xu wrote:
> 
> A packet dump on tbench indicates it's sending lots of small
> packets so TSO wouldn't be contributing anything positive at
> all.  Hmm, it seems that even netperf isn't producing anything
> larger than MTU so something seems amiss with the TCP stack.

It seems that netperf is issuing 16384-byte writes and as such
we're sending the packets out immediately so TSO doesn't get a
chance to merge the data.  Running netperf with -m 65536 makes
TSO beat non-TSO by 6293Mb/s to 4761Mb/s.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
