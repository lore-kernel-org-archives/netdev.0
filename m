From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH] Fix xfrm hash collisions by changing
	__xfrm4_daddr_saddr_hash to hash addresses with addition
Date: Thu, 13 Aug 2009 13:53:10 +1000
Message-ID: <20090813035310.GA19182@gondor.apana.org.au>
References: <alpine.DEB.1.10.0908071032171.3426@sisapiiri.net.net> <20090813020606.GA18205@gondor.apana.org.au> <20090812.204247.183387787.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: joamaki@gmail.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:34109 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752824AbZHMDxO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 12 Aug 2009 23:53:14 -0400
Content-Disposition: inline
In-Reply-To: <20090812.204247.183387787.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Aug 12, 2009 at 08:42:47PM -0700, David Miller wrote:
>
> Isn't it fruitless to talk about exploiting SA IDs when such things
> are setup using an encrypted negotiation sequence and some level of
> trust?
> 
> Just wondering :-)

It's a good question :)

However, IPsec is not always carried out between two parties
that trust each other.  In fact, quite often IPsec is used in
a hub and spoke fashion where a central IPsec gateway serves a
number of IPsec clients that may or may not be trustworthy.

Take corporate VPN servers for instance.  Yes each client is
trusted to the extent that it is being offered connectivity to
the corporate network.  However, it would not be ideal if one
rogue client can take down the entire VPN server, especially
in this case because repeatedly creating identical SAs can often
occur purely by accident.

With IKEv1, it is quite possible for the client to think that
SA negotiation failed while in fact it had been created at the
server's end.  In that case the client depending on configuration
may retry indefinitely, causing a large number of identical SAs
to be created at the server end.  

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
