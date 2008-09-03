From: David Miller <davem@davemloft.net>
Subject: Re: tipc on sparc32
Date: Tue, 02 Sep 2008 23:26:27 -0700 (PDT)
Message-ID: <20080902.232627.209816179.davem@davemloft.net>
References: <20080902224059.70a182ba.akpm@linux-foundation.org>
	<20080902.231201.184658566.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: tipc-discussion@lists.sourceforge.net, netdev@vger.kernel.org
To: akpm@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:53612
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753964AbYICG0e (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 3 Sep 2008 02:26:34 -0400
In-Reply-To: <20080902.231201.184658566.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Miller <davem@davemloft.net>
Date: Tue, 02 Sep 2008 23:12:01 -0700 (PDT)

> From: Andrew Morton <akpm@linux-foundation.org>
> Date: Tue, 2 Sep 2008 22:40:59 -0700
> 
> > sparc32 allmodconfig:
> > 
> > In file included from net/tipc/link.h:43,
> >                  from net/tipc/bcast.c:41:
> > net/tipc/node.h:71: error: redefinition of 'struct node'
> > 
> > sparc32 likes catching code which uses insufficiently cautiously chosen
> > identifiers.  dlm is presently blowing up on sparc32 because it has a
> > to_node() function.
> > 
> > Arguably, sparc32 should be fixed, but I'd suggest that random bits of
> > networking code should not be using identifiers as generic-sounding as "node".
> 
> I'll fix sparc for the time being, thanks.

Actually, the conflict is between the include/linux/node.h which the
generic device layer uses, and TIPC.

This isn't a sparc specific problem.

And the DLM issue is the same thing.

It might be triggering on sparc32 because linux/node.h gets included
in the tangle of arch and non-arch include files that happen during
the build, but that's benign as far as blaming sparc is concerned.

I can take care of TIPC.

Andrew can you take a stab at DLM?

Thanks.
