From: David Miller <davem@davemloft.net>
Subject: Re: multiqueue interrupts...
Date: Fri, 19 Sep 2008 13:14:02 -0700 (PDT)
Message-ID: <20080919.131402.157398113.davem@davemloft.net>
References: <20080918.193815.175549834.davem@davemloft.net>
	<41b516cb0809191050t6c9783dele8926f697854bb1@mail.gmail.com>
	<20080919181840.GE30956@parisc-linux.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, arjan@infradead.org
To: matthew@wil.cx
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:43102
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752719AbYISUOO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 19 Sep 2008 16:14:14 -0400
In-Reply-To: <20080919181840.GE30956@parisc-linux.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Matthew Wilcox <matthew@wil.cx>
Date: Fri, 19 Sep 2008 12:18:41 -0600

> On Thu, Sep 18, 2008 at 7:38 PM, David Miller wrote:
> > During kernel summit I was speaking with Arjan van de Ven
> > about irqbalanced and networking card multiqueue interrupts.
> > 
> > In order for irqbalanaced to make smart decisions, what needs to
> > happen in drivers is that the individual interrupts need to be
> > named in such a way that he can tell by looking at /proc/interrupts
> > output that these interrupts are related.
> > 
> > So on a multiqueue card with 2 RX queues and 2 TX queues we'd
> > have names like:
> > 
> >        eth0-rx-0
> >        eth0-rx-1
> >        eth0-tx-0
> >        eth0-tx-1
> > 
> > So let's make an effort to get this done right in 2.6.28 and meanwhile
> > Arjan can add the irqbalanced code.
> 
> Instead of having magic names, how about we put something in
> /proc/irq/nnn/ that lets us tell which interrupts are connected to which
> queues?

More code for irqbalanced to write, to look for the files and
directories under there, etc.  Harder to make work with simple
individual driver backports, which you know dists are going to
want to do.

That's why.

No, this new subdirectory thing isn't a good idea.
