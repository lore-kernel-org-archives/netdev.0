From: David Miller <davem@davemloft.net>
Subject: Re: [1/2] [NET] link_watch: Move link watch list into net_device
Date: Tue, 08 May 2007 18:35:26 -0700 (PDT)
Message-ID: <20070508.183526.108739707.davem@davemloft.net>
References: <20070505102305.GA12771@gondor.apana.org.au>
	<463F95C3.60407@goop.org>
	<20070508121322.GA21647@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jeremy@goop.org, hch@infradead.org, ak@suse.de,
	akpm@linux-foundation.org, virtualization@lists.osdl.org,
	linux-kernel@vger.kernel.org, chrisw@sous-sol.org,
	ian.pratt@xensource.com, Christian.Limpach@cl.cam.ac.uk,
	netdev@vger.kernel.org, jeff@garzik.org,
	shemminge@linux-foundation.org, rusty@rustcorp.com.au,
	Keir.Fraser@cl.cam.ac.uk
To: herbert@gondor.apana.org.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:49153
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1755573AbXEIBf0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 8 May 2007 21:35:26 -0400
In-Reply-To: <20070508121322.GA21647@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Herbert Xu <herbert@gondor.apana.org.au>
Date: Tue, 8 May 2007 22:13:22 +1000

> [NET] link_watch: Move link watch list into net_device
> 
> These days the link watch mechanism is an integral part of the
> network subsystem as it manages the carrier status.  So it now
> makes sense to allocate some memory for it in net_device rather
> than allocating it on demand.
> 
> In fact, this is necessary because we can't tolerate a memory
> allocation failure since that means we'd have to potentially
> throw a link up event away.
> 
> It also simplifies the code greatly.
> 
> In doing so I discovered a subtle race condition in the use
> of singleevent.  This race condition still exists (and is
> somewhat magnified) without singleevent but it's now plugged
> thanks to an smp_mb__before_clear_bit.
> 
> Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

Applied, thanks Herbert.
