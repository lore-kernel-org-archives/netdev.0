From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: gso: Attempt to handle mega-GRO packets
Date: Thu, 7 Nov 2013 09:47:24 +0800
Message-ID: <20131107014724.GA28946@gondor.apana.org.au>
References: <20131106040717.GA15711@gondor.apana.org.au>
 <1383711785.4291.156.camel@edumazet-glaptop2.roam.corp.google.com>
 <20131106042858.GA15745@gondor.apana.org.au>
 <1383715222.4291.158.camel@edumazet-glaptop2.roam.corp.google.com>
 <20131106080425.GA17556@gondor.apana.org.au>
 <20131106081638.GA17665@gondor.apana.org.au>
 <20131106131252.GA20680@gondor.apana.org.au>
 <1383750070.4291.163.camel@edumazet-glaptop2.roam.corp.google.com>
 <20131107003658.GA27976@gondor.apana.org.au>
 <1383786208.2878.15.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Ben Hutchings <bhutchings@solarflare.com>,
	David Miller <davem@davemloft.net>,
	christoph.paasch@uclouvain.be, netdev@vger.kernel.org,
	hkchu@google.com, mwdalton@google.com, mst@redhat.com,
	Jason Wang <jasowang@redhat.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ringil.hengli.com.au ([178.18.16.133]:52893 "EHLO
	fornost.hengli.com.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1753652Ab3KGBrf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 Nov 2013 20:47:35 -0500
Content-Disposition: inline
In-Reply-To: <1383786208.2878.15.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Nov 06, 2013 at 05:03:28PM -0800, Eric Dumazet wrote:
>
> > But once the system has been running for a while, I see nothing
> > in the virtio_net code that tries to prevent fragmentation.  Once
> > fragmentation sets in, you'll be back in the terrible situation
> > that we were in prior to the coalesce patch.
> 
> There is no fragmentation, since we allocate 32Kb pages.

Say the system is fragmented sufficiently that you'll end up with
0-order pages.  In that case you'll only ever be able to coalesce
two packets.

Real systems that run for more than a day do end up with seriously
fragmented memory.

Cheers,
-- 
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
