From: David Miller <davem@davemloft.net>
Subject: Re: asm volatile
Date: Thu, 08 Mar 2007 14:01:51 -0800 (PST)
Message-ID: <20070308.140151.95057712.davem@davemloft.net>
References: <20070306215349.hquin7d6pfy2n5d2@m.safari.iki.fi>
	<20070306222435.cbpv63ltximq6lrf@m.safari.iki.fi>
	<20070308182357.nnpvhqqj5qqk2vsx@m.safari.iki.fi>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: 7atbggg02@sneakemail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:55173
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1030705AbXCHWBv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 8 Mar 2007 17:01:51 -0500
In-Reply-To: <20070308182357.nnpvhqqj5qqk2vsx@m.safari.iki.fi>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Sami Farin <7atbggg02@sneakemail.com>
Date: Thu, 8 Mar 2007 20:23:57 +0200

> On Wed, Mar 07, 2007 at 00:24:35 +0200, Sami Farin wrote:
> > On Tue, Mar 06, 2007 at 23:53:49 +0200, Sami Farin wrote:
> > ...
> > > And I found bug in gcc-4.1.2, it gave 0 for ncubic results
> > > when doing 1000 loops test... gcc-4.0.3 works.
> > 
> > Found it.
> > 
> > --- cbrt-test.c~	2007-03-07 00:20:54.735248105 +0200
> > +++ cbrt-test.c	2007-03-07 00:21:03.964864343 +0200
> > @@ -209,7 +209,7 @@
> >  
> >  	__asm__("bsrl %1,%0\n\t"
> >  		"cmovzl %2,%0"
> > -		: "=&r" (r) : "rm" (x), "rm" (-1));
> > +		: "=&r" (r) : "rm" (x), "rm" (-1) : "memory");
> >  	return r+1;
> >  }
> >  
> > Now Linux 2.6 does not have "memory" in fls, maybe it causes
> > some gcc funnies some people are seeing.
> 
> It also works without "memory" if I do "__asm__ volatile".
> 
> Why some functions have volatile and some have not in include/asm-*/*.h ?

"volatile" is really only needed if there is some side effect
that cannot be expressed to gcc which makes ordering over
the asm wrt. other pieces of code important.

But in these case it should absolutely not be needed.  It's
simply computing an interger result from some inputs and
some values in memory.  GCC should see perfectly fine what
is memory is read by the asm and therefore what ordering
constraints there are wrt. writes to the same memory location.
