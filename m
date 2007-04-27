From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 00/14] AF_RXRPC socket family and AFS rewrite [net-2.6]
Date: Thu, 26 Apr 2007 20:12:13 -0700 (PDT)
Message-ID: <20070426.201213.85816532.davem@davemloft.net>
References: <20070426195415.24531.78794.stgit@warthog.cambridge.redhat.com>
	<20070426.161522.76328746.davem@davemloft.net>
	<20070426.200809.04441500.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: dhowells@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:44359
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1755207AbXD0DMF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 Apr 2007 23:12:05 -0400
In-Reply-To: <20070426.200809.04441500.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: David Miller <davem@davemloft.net>
Date: Thu, 26 Apr 2007 20:08:09 -0700 (PDT)

> From: David Miller <davem@davemloft.net>
> Date: Thu, 26 Apr 2007 16:15:22 -0700 (PDT)
> 
> > Ok, I applied it all and added a compiler warning fix for 64-bit
> > at the end.
> 
> I just found a problem in your work, you cannot use cmpxchg() in
> generic code, it is not available on all processors:

And even more problems, what the heck are you doing here?

In file included from net/rxrpc/rxkad.c:21:
net/rxrpc/ar-internal.h:803:1: warning: "atomic_dec" redefined
In file included from include/linux/spinlock.h:326,
                 from include/linux/module.h:9,
                 from net/rxrpc/rxkad.c:12:
include/asm/atomic.h:67:1: warning: this is the location of the previous definition

You can't override atomic_dec() like this, in fact I'd suggest you
don't try to do that at all and instead use your own rxrpc_drop_ref()
or whatever to get this functionality and pepper the rxrpc sources
with calls to your local version.

I'm going to ask that you test build any future work on a couple of
platforms besides x86 and x86_64 or else I'm not merging your work
until someone does.

I'm a little bit upset that I waited so many iterations of your
changes, and still there is massive fallout like this on a simple
platform like sparc64.

It's not even run-time fallout, it's build-time detectable stuff,
things you could have prevented without having access to any of these
systems.
