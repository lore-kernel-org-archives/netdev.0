From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH] Tulip interrupt uses non IRQ safe spinlock
Date: Tue, 3 May 2005 07:31:08 +1000
Message-ID: <20050502213108.GB16177@gondor.apana.org.au>
References: <E1DRFqC-00028H-Qi@tigger> <E1DRGWv-0003aa-00@gondolin.me.apana.org.au> <20050429093521.274adf9a.davem@davemloft.net> <20050429224931.GA18616@gondor.apana.org.au> <427623B8.8050107@wetlettuce.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Mark Broadbent <markb@wetlettuce.com>
Content-Disposition: inline
In-Reply-To: <427623B8.8050107@wetlettuce.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Mon, May 02, 2005 at 01:57:28PM +0100, Mark Broadbent wrote:
>
> > However, I don't see how this can happen.  __do_IRQ ensures
> > that the handlers on a single IRQ aren't reentered by desc->lock
> > and desc->status.  Softirqs are also kept out by irq_enter.  Am
> > I missing something?
> 
> As far as I can see desc->lock is dropped before handle_IRQ_event() is
> called in __do_IRQ() (kernel/irq/handle.c:170) and desc->status does not
> prevent the execution of the IRQ handler.  Same with softirqs,

desc->status is set to IRQ_INPROGRESS (kernel/irq/handle.c:144) which
prevents the same IRQ handlers from being invoked again
(kernel/irq/handle.c:141).

> interrupts are enabled when the handler is called (kernel/softirq.c:89).

Soft IRQs do not run when we're in an IRQ handler (kernel/softirq.c:121).

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
