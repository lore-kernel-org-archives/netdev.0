From: "David S. Miller" <davem@redhat.com>
Subject: Re: [TG3] Always load TSO firmware
Date: Mon, 17 Nov 2003 12:38:36 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20031117123836.2f8e70af.davem@redhat.com>
References: <20031117093225.GA12420@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: jgarzik@pobox.com, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Herbert Xu <herbert@gondor.apana.org.au>
In-Reply-To: <20031117093225.GA12420@gondor.apana.org.au>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Mon, 17 Nov 2003 20:32:25 +1100
Herbert Xu <herbert@gondor.apana.org.au> wrote:

> In 2.5 the TSO firmware is always loaded on capable cards.  This
> does not happen in 2.4.  I've received a report from a Broadcom
> 5705M user that unless the firmware is loaded his card does not
> work.
> 
> This patch makes it load the TSO firmware even if the kernel
> does not support it.
> 
> The only catch is that the Broadcom driver doesn't always load
> the firmware either and yet it still works under 2.4 for that user.
> 
> Despite that this should still be safe as 2.5 always loads the
> firmware regardless of whether TSO is going to be used or not.
> It also removes another variable between 2.4/2.5 when chasing
> down tg3 bugs.

I'd like to figure out the problem instead of applying this patch.

In fact, the behavior is the biggest clue as to what the problem
might be.  Espcially since in 2.4.x the TSO firmware is not executed
at all by the chip, and therefore should have no bearing on it's
operation.

Whether we load the TSO firmware or not on 5705 determines how big
an onboard buffer area we give to the chip for packet data.  It may
be the case that we are miscalculating these values or not programming
them into the chip correctly.

This is where you should look for the problem.

FWIW all of my 5782 and 5705 PCI boards work perfectly fine with the
current 2.4.x driver.
