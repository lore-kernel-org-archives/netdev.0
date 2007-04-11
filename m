From: David Miller <davem@davemloft.net>
Subject: Re: link error : 2.6.21-rc6-mm1 for s390
Date: Tue, 10 Apr 2007 19:05:28 -0700 (PDT)
Message-ID: <20070410.190528.91443205.davem@davemloft.net>
References: <20070410182937.8169c672.akpm@linux-foundation.org>
	<20070410.183629.57444787.davem@davemloft.net>
	<20070410184738.dc1c5943.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: mathieu.desnoyers@polymtl.ca, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, shemminger@linux-foundation.org,
	heiko.carstens@de.ibm.com
To: akpm@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:52730
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1030752AbXDKCF2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 Apr 2007 22:05:28 -0400
In-Reply-To: <20070410184738.dc1c5943.akpm@linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Andrew Morton <akpm@linux-foundation.org>
Date: Tue, 10 Apr 2007 18:47:38 -0700

> On Tue, 10 Apr 2007 18:36:29 -0700 (PDT)
> David Miller <davem@davemloft.net> wrote:
> 
> > From: Andrew Morton <akpm@linux-foundation.org>
> > Date: Tue, 10 Apr 2007 18:29:37 -0700
> > 
> > > git-net.patch implements generic lib/div64.c, but s390 also has a
> > > private one.  Presumably the appropriate fix is to remove s390's
> > > private implementation within davem's tree.
> > 
> > The s390 version seems to be optimized in assembler for that
> > processor, therefore we should probably instead elide the
> > generic version on s390.
> 
> We're sure that it has the same API?

Yes, I read over it, I'm pretty sure it does.

> attribute(weak) would give a nicer result?

I'm not so sure.

> We'd also need to remove s390's EXPORT_SYMBOL(__div64_32), so s390 ends up
> using lib/div64.c's EXPORT_SYMBOL().

It shouldn't matter if we use s390's or the generic version's....

Oh, I see, s390 uses lib-y for it's div64.o object, that's a bug.
I'll fix that up, thanks Andrew.
