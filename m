From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Subject: RE: [PATCH] mlx4_en: fix transmit of packages when blue frame is
 enabled
Date: Mon, 10 Oct 2011 10:53:36 +0200
Message-ID: <1318236816.29415.415.camel@pasglop>
References: <AE90C24D6B3A694183C094C60CF0A2F6D8AE78@saturn3.aculab.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Eli Cohen <eli@dev.mellanox.co.il>, netdev@vger.kernel.org,
	Eli Cohen <eli@mellanox.co.il>, linuxppc-dev@lists.ozlabs.org,
	Thadeu Lima de Souza Cascardo <cascardo@linux.vnet.ibm.com>,
	Yevgeny Petrilin <yevgenyp@mellanox.co.il>
To: David Laight <David.Laight@ACULAB.COM>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gate.crashing.org ([63.228.1.57]:54443 "EHLO gate.crashing.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752947Ab1JJIx6 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 10 Oct 2011 04:53:58 -0400
In-Reply-To: <AE90C24D6B3A694183C094C60CF0A2F6D8AE78@saturn3.aculab.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2011-10-10 at 09:40 +0100, David Laight wrote:
> > What is this __iowrite64_copy... oh I see
> > 
> > Nice, somebody _AGAIN_ added a bunch of "generic" IO 
> > accessors that are utterly wrong on all archs except
> > x86 (ok, -almost-).
> > There isn't a single bloody memory barrier in there !
> 
> Actually memory barriers shouldn't really be added to
> any of these 'accessor' functions.
> (Or, at least, ones without barriers should be provided.)

As long as they are documented to provide no guarantee of ordering
between the stores... And x86 driver writers have any clue that they
will not be ordered vs. surrounding accesses.

> The driver may want to to a series of writes, then a
> single barrier, before a final write of a command (etc).
> 
> in_le32() from io.h is specially horrid!

The reason for that is that drivers expect fully ordered writel() vs
everything (including DMA).

Unfortunately, this is how Linux defines those semantics. I would much
prefer to require barriers explicitely but the decision was made back
then simply because the vast majority of driver writers do not
understand weakly ordered memory models and "everything should be made
to look like x86".

It would be great to come up with a set of more relaxed accessors along
with the appropriate barrier to use for drivers who "know better" but so
far all attempts at doing so have failed due to the inability to agree
on their precise semantics. Tho that was a while ago, we should probably
give it a new shot.

Cheers,
Ben. 
