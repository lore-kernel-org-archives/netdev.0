From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: [PATCH] Tulip interrupt uses non IRQ safe spinlock
Date: Fri, 29 Apr 2005 20:44:40 +0200
Message-ID: <20050429184440.GA6121@electric-eye.fr.zoreil.com>
References: <E1DRFqC-00028H-Qi@tigger> <E1DRGWv-0003aa-00@gondolin.me.apana.org.au> <20050429093521.274adf9a.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Herbert Xu <herbert@gondor.apana.org.au>, markb@wetlettuce.com,
        netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@davemloft.net>
Content-Disposition: inline
In-Reply-To: <20050429093521.274adf9a.davem@davemloft.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

kernel/irq/handle.c::__do_IRQ
[...]
        spin_lock(&desc->lock);
        desc->handler->ack(irq);
        /*
         * REPLAY is when Linux resends an IRQ that was dropped earlier
         * WAITING is used by probe to mark irqs that are being tested
         */
        action = NULL;
        if (likely(!(status & (IRQ_DISABLED | IRQ_INPROGRESS)))) {
                action = desc->action;
                status &= ~IRQ_PENDING; /* we commit to handling */
                status |= IRQ_INPROGRESS; /* we are handling it */
        }
        desc->status = status;

handle_IRQ_event(irq, regs, action) is issued a few lines below
if action != NULL

I thought this (strangely locked) code was supposed to disable reentrancy.

--
Ueimor
