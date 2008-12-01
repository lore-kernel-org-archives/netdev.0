From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [RFC PATCH 0/5] IPsec parallelization
Date: Mon, 1 Dec 2008 19:15:01 +0800
Message-ID: <20081201111501.GA20650@gondor.apana.org.au>
References: <20081201071614.GP476@secunet.com> <20081201084902.GA19904@gondor.apana.org.au> <20081201.022929.253639406.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: steffen.klassert@secunet.com, netdev@vger.kernel.org,
	klassert@mathematik.tu-chemnitz.de
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:39485 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751334AbYLALPK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 1 Dec 2008 06:15:10 -0500
Content-Disposition: inline
In-Reply-To: <20081201.022929.253639406.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Dec 01, 2008 at 02:29:29AM -0800, David Miller wrote:
>
> Herbert, I'm not completely convinced of this line of thinking :-)

Well you've put some doubts into mind for a second there, but
after thinking some more I'm sticking to my position :)

> Will crypto be faster than a routing cache lookup?  Because flow
> seperation helps routing performance, significantly.

No to the first part, but that's not the point.  I'm saying that
you can do flow separation within the crypto layer, well, for
output anyway.  All you need to do is to provide some key to
the crypto layer that tells it that ordering is only required
within that key.  Alternatively, just allocate plenty of crypto
tfms as these patches do, and feed the flows down to different
tfms.

For input there's nothing we can do apart from processing completed
requests in sequence so no flow information is going to help (and
in fact if it did one could argue that the purpose of IPsec has been
defeated :)

> And the reconstitution of the seperated crypto operations into the
> original properly ordered flow can be done most cleanly (IMHO) in the
> networking layer as far as I have seen so far.

Well once I've finished the GRO stuff I can give this a go.  But
I'm pretty sure we can achieve exactly the same thing with only
minimal changes to xfrm.  Really all it needs to do is allocate
more tfm objects for the output path.

All the serialisation logic can stay in the crypto layer because
AFAICS no network-specific knowledge is being used in this patch
set.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
