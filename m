From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: Re: [PATCH 5/5] ipv4: Don't use the cached pmtu informations for
 input routes
Date: Thu, 24 Nov 2011 09:49:52 +0100
Message-ID: <20111124084952.GF6348@secunet.com>
References: <20111123155245.GA11638@gondor.apana.org.au>
 <20111123.164941.1950228526500366081.davem@davemloft.net>
 <20111124001035.GA14996@gondor.apana.org.au>
 <20111123.191758.1061988020384521241.davem@davemloft.net>
 <20111124010147.GA15318@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([195.81.216.161]:32924 "EHLO a.mx.secunet.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752896Ab1KXIt7 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 24 Nov 2011 03:49:59 -0500
Content-Disposition: inline
In-Reply-To: <20111124010147.GA15318@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Nov 24, 2011 at 09:01:47AM +0800, Herbert Xu wrote:
> On Wed, Nov 23, 2011 at 07:17:58PM -0500, David Miller wrote:
> >
> > It means there is a propagation delay of PMTU increasing which is on the
> > order of the number of hops between the sender and the PMTU increased link.
> > So if the PMTU timeout is X, the propagation time is X * N_HOPS.
> 
> That assumes that each router in the path would constantly probe
> to refresh its cached value, as otherwise they should all expire
> after X.

Well, it simply got unpredictable how long pmtu propagation takes.
This depends now on the network activity of the routers and on the
individual configuration of the expiration time on each router. With
the original behaviour, we could expect to notice a pmtu increase
if we probe after our timeout X. Now we don't know when this is going
to happen.

Btw. we leak a trigger to check if the learned pmtu information has
expired in our current tree, the learned pmtu informations never
expire. So we are doing good to not propagate our learned pmtu
to other hosts :)
