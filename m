From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [PATCH]: Tigon3 new NAPI locking v2
Date: Sun, 05 Jun 2005 23:01:31 -0700 (PDT)
Message-ID: <20050605.230131.78711491.davem@davemloft.net>
References: <20050603.122558.88474819.davem@davemloft.net>
	<42A0BC2B.4020409@pobox.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, mchan@broadcom.com
Return-path: <netdev-bounce@oss.sgi.com>
To: jgarzik@pobox.com
In-Reply-To: <42A0BC2B.4020409@pobox.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

From: Jeff Garzik <jgarzik@pobox.com>
Date: Fri, 03 Jun 2005 16:23:07 -0400

> overall, pretty spiffy :)

Thanks.

> As further work, I would like to see how much (alot? all?) of the timer 
> code could be moved into a workqueue, where we could kill the last of 
> the horrible-udelay loops in the driver.  Particularly awful is
> 
>          while (++tick < 195000) {
>                  status = tg3_fiber_aneg_smachine(tp, &aninfo);
>                  if (status == ANEG_DONE || status == ANEG_FAILED)
>                          break;
> 
>                  udelay(1);
>          }

I know :).

> * This loop makes me nervous...  If there's a fault on the PCI bus or 
> the hardware is unplugged, val will equal 0xffffffff.

I agree, if the chip wedges for whatever reason and stops receiving
interrupts, we will totally lock up here.  I'll add a timeout to the
final version.  Remind me if I don't :)

> * A few comments for normal humans like "force an interrupt" and "wait 
> for interrupt handler to complete" might be nice.

Ok.

> * a BUG_ON(if-interrupts-are-disabled) line might be nice

Which interrupts?  Local cpu interrupts?  Tigon3 chip interrupts?

> Rather than an 'irq_sync' arg, my instinct would have been to create 
> tg3_full_lock() and tg3_full_lock_sync().  This makes the action -much- 
> more obvious to the reader, and since its inline doesn't cost anything 
> (compiler's optimizer even does a tiny bit less work my way).

This doesn't sound like a bad idea either.

Thanks for the feedback Jeff.
