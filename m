From: Grant Grundler <iod00d@hp.com>
Subject: Re: [PATCH] tg3_msi() and weakly ordered memory
Date: Tue, 21 Jun 2005 22:20:12 -0700
Message-ID: <20050622052012.GA17224@esmail.cup.hp.com>
References: <20050614154625.GB24371@esmail.cup.hp.com> <1118771563.7059.30.camel@rh4> <20050614211530.GB25516@esmail.cup.hp.com> <20050621.165634.07642938.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: iod00d@hp.com, mchan@broadcom.com, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@davemloft.net>
Content-Disposition: inline
In-Reply-To: <20050621.165634.07642938.davem@davemloft.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Tue, Jun 21, 2005 at 04:56:34PM -0700, David S. Miller wrote:
> 
> Ok, here is the patch I came up with as a result of this thread.

looks good to me.

> Michael stated he would investigate using a pure tag comparison in
> place of tg3_has_work() when the chip is using tagged interrupts.

The more I think about it, the more I like the idea of each ISR calling
into a different tg3_poll routine. The specific _poll() routine could
do the "is there more work" checking instead the TX/RX ring
cleanup code. The main reason is the "more work" checks can
be better optimized for MSI (use tags) vs IRQ Line interrupt (use ring
indices) handlers. I also hope to reduce cacheline movement by touching
the status block fewer times.

This isn't a trivial patch and I'm short on time (preparing stuff
for OLS and HP World before my vacation). If there is still interest,
I can prototype a patch in late August or Sept (about 8 weeks from now).


> Thanks.

Welcome and thanks too.

BTW, I greatly appreciate Michael clarifying tg3 behavior.

thanks,
grant
