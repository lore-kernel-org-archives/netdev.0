From: David Miller <davem@davemloft.net>
Subject: Re: how expensive are mallocs?
Date: Wed, 25 Nov 2009 15:18:46 -0800 (PST)
Message-ID: <20091125.151846.106903149.davem@davemloft.net>
References: <c0a09e5c0911240957x45abfb26k1611e53f435e5179@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: andy.grover@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:49494
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S934752AbZKYXS2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 25 Nov 2009 18:18:28 -0500
In-Reply-To: <c0a09e5c0911240957x45abfb26k1611e53f435e5179@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Andrew Grover <andy.grover@gmail.com>
Date: Tue, 24 Nov 2009 09:57:34 -0800

> How much effort generally makes sense to avoid mallocs? For example,
> rds has a function that does a kmalloc for an array of scatterlist
> entries, which is freed at the bottom of the function. We couldn't
> allocate off the stack in all cases (too big), but we could allocate
> an array of say 8 scatterlists, and use it if that's big enough,
> falling back to kmalloc if it's not.
> 
> Is this a good idea?

This is a poor idea, especially if this function executes frequently.

Better to have a per-socket or per-cpu (softirq protected, if
necessary) work area to do such things if you really can't fit it on
the stack.

> Also, RDS has its own per-cpu page remainder allocator (see
> net/rds/page.c) for kernel send buffers. Would cutting this code and
> just using kmalloc be recommended? Doesn't SL?B already do per-cpu
> pools?
> 
> Does this stuff even matter enough to rise above the noise in benchmarks?

We already have a per-socket page allocation scheme for sendmsg handling.

In general adding more and more specialized allocators is heavily
discouraged.  If the generic kernel facilities don't fit the bill,
fix them.

