From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: SO_REUSEPORT - can it be done in kernel?
Date: Tue, 1 Mar 2011 20:15:44 +0800
Message-ID: <20110301121544.GA7166@gondor.apana.org.au>
References: <1298910174.2941.585.camel@edumazet-laptop> <20110228163742.GH9763@canuck.infradead.org> <1298912869.2941.687.camel@edumazet-laptop> <20110301101955.GI9763@canuck.infradead.org> <1298975602.3284.13.camel@edumazet-laptop> <20110301110708.GJ9763@canuck.infradead.org> <1298977984.3284.15.camel@edumazet-laptop> <20110301112759.GK9763@canuck.infradead.org> <1298979909.3284.28.camel@edumazet-laptop> <20110301120112.GL9763@canuck.infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: Eric Dumazet <eric.dumazet@gmail.com>,
	David Miller <davem@davemloft.net>, rick.jones2@hp.com,
	therbert@google.com, wsommerfeld@google.com,
	daniel.baluta@gmail.com, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from helcar.apana.org.au ([209.40.204.226]:49833 "EHLO
	fornost.hengli.com.au" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751127Ab1CAMP7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Mar 2011 07:15:59 -0500
Content-Disposition: inline
In-Reply-To: <20110301120112.GL9763@canuck.infradead.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Mar 01, 2011 at 07:01:12AM -0500, Thomas Graf wrote:
> On Tue, Mar 01, 2011 at 12:45:09PM +0100, Eric Dumazet wrote:
> 
> This is how perf top looks like with SO_REUSEPORT

Yeah I think Eric is spot on.  The remaining bottleneck is because
we hash all outbound packets from a single socket to a single TX
queue, despite the fact that they were produced on difference CPUs.

Cheers,
-- 
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
