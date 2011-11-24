From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 5/5] ipv4: Don't use the cached pmtu informations for
 input routes
Date: Wed, 23 Nov 2011 19:17:58 -0500 (EST)
Message-ID: <20111123.191758.1061988020384521241.davem@davemloft.net>
References: <20111123155245.GA11638@gondor.apana.org.au>
	<20111123.164941.1950228526500366081.davem@davemloft.net>
	<20111124001035.GA14996@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: steffen.klassert@secunet.com, netdev@vger.kernel.org
To: herbert@gondor.hengli.com.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:40360 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753739Ab1KXASM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Nov 2011 19:18:12 -0500
In-Reply-To: <20111124001035.GA14996@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Herbert Xu <herbert@gondor.hengli.com.au>
Date: Thu, 24 Nov 2011 08:10:35 +0800

> Is there a particular scenario where this breaks? I could only think
> of policy routing cases but that's not unique to forwarding as it
> also affects us as a host.

Steffen has a specific situation.

But regardless I think the current behavior is terrible.

It means there is a propagation delay of PMTU increasing which is on the
order of the number of hops between the sender and the PMTU increased link.
So if the PMTU timeout is X, the propagation time is X * N_HOPS.
