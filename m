From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH]: Preliminary release of Sun Neptune driver
Date: Wed, 19 Sep 2007 15:07:55 -0700 (PDT)
Message-ID: <20070919.150755.38714639.davem@davemloft.net>
References: <20070918.151528.84360712.davem@davemloft.net>
	<20070919145900.759ef19e@freepuppy.rosehill.hemminger.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Ariel.Hendel@sun.com, greg.onufer@sun.com,
	jeff@garzik.org
To: shemminger@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:40397
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1750868AbXISWHz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 19 Sep 2007 18:07:55 -0400
In-Reply-To: <20070919145900.759ef19e@freepuppy.rosehill.hemminger.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Stephen Hemminger <shemminger@linux-foundation.org>
Date: Wed, 19 Sep 2007 14:59:00 -0700

> > +#ifndef PCI_DEVICE_ID_SUN_NEPTUNE
> > +#define PCI_DEVICE_ID_SUN_NEPTUNE	0xabcd
> > +#endif
> 
> Why bother defining the ID, and what good does driver_data do you?

Good point, I'll put this 0xabcd thing directly into the
table.

> > +#define nr64(reg)		readq(np->regs + (reg))
> > +#define nw64(val, reg)		writeq((val), np->regs + (reg))
> 
> Macro's that make assumptions about context (ie variable name np)
> are evil and bad style.

Too bad, it saves developers who write 20,000 line drivers from carpel
tunnel symdrome.

It's so repetitive to state things over and over again, and this macro
scheme is 1) established widely (tg3 amonst many other drivers do it)
and 2) forces the driver to use a consistent naming convention for
primary driver private struct variables.

> Wrapping locking is poor style and makes code review harder.

I disagree, because in this case the macro says exactly what the thing
is doing, locking the parent of the port.  The implementation is
arbitrary and can be reviewed independently of the uses.

> > +static int niu_wait_bits_clear_mac(struct niu *np, unsigned long reg, u64 bits,
> > +				   int limit, int delay)
> > +{
> > +	BUILD_BUG_ON(limit <= 0 || delay < 0);
> 
> There is no way compiler can evaluate limit or delay.

Check the callers, they all pass contant values.

> Why are you using __u32?  That is reserved for values going out
> to user space.

Right, I'll fix those up, thanks.
