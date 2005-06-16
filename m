From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [PATCH]: Tigon3 new NAPI locking v2
Date: Thu, 16 Jun 2005 13:04:17 -0700 (PDT)
Message-ID: <20050616.130417.78707215.davem@davemloft.net>
References: <20050616113732.GA22367@gondor.apana.org.au>
	<20050616115945.GA23064@gondor.apana.org.au>
	<20050616130453.GA23682@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, mchan@broadcom.com
Return-path: <netdev-bounce@oss.sgi.com>
To: herbert@gondor.apana.org.au
In-Reply-To: <20050616130453.GA23682@gondor.apana.org.au>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH]: Tigon3 new NAPI locking v2
Date: Thu, 16 Jun 2005 23:04:53 +1000

> On Thu, Jun 16, 2005 at 09:59:45PM +1000, herbert wrote:
> > 
> > Actually, why don't we utilise the existing synchronize_irq mechanism?
> > Here is what we could do.
> 
> Oops, I should've left the smp_mb() in tg3_irq_quiesce since
> synchronize_irq isn't a memory barrier.

Wow, that's a very cool idea.  :-)

In fact, I think it will eliminate some (but definitely not all) of
the races that the new locking code has.

When you posted the patch with the atomic bitop added to the interrupt
handler, I was going to tell you that the whole idea was to make it
near zero cost to the interrupt fast path. :)
