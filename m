From: linas@austin.ibm.com (Linas Vepstas)
Subject: Re: NAPI wait before enabling irq's [was Re: [Cbe-oss-dev] Spider DMA wrongness]
Date: Thu, 14 Dec 2006 16:49:52 -0600
Message-ID: <20061214224952.GB4329@austin.ibm.com>
References: <OFBF8BBD4B.0E5AEA34-ON8725721F.005D5313-8625721F.005EAC5D@us.ibm.com> <1162931892.28571.497.camel@localhost.localdomain> <20061214205432.GA4329@austin.ibm.com> <Pine.LNX.4.61.0612141244160.30447@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Benjamin Herrenschmidt <benh@kernel.crashing.org>,
	James K Lewis <jklewis@us.ibm.com>,
	Arnd Bergmann <arnd@arndb.de>,
	"cbe-oss-dev@ozlabs.org" <cbe-oss-dev@ozlabs.org>,
	cbe-oss-dev-bounces+jklewis=us.ibm.com@ozlabs.org,
	Christoph Hellwig <hch@lst.de>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from e1.ny.us.ibm.com ([32.97.182.141]:44706 "EHLO e1.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S964995AbWLNWt5 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 14 Dec 2006 17:49:57 -0500
Received: from d01relay02.pok.ibm.com (d01relay02.pok.ibm.com [9.56.227.234])
	by e1.ny.us.ibm.com (8.13.8/8.12.11) with ESMTP id kBEMnsNp008659
	for <netdev@vger.kernel.org>; Thu, 14 Dec 2006 17:49:54 -0500
Received: from d01av02.pok.ibm.com (d01av02.pok.ibm.com [9.56.224.216])
	by d01relay02.pok.ibm.com (8.13.6/8.13.6/NCO v8.1.1) with ESMTP id kBEMnsdG276338
	for <netdev@vger.kernel.org>; Thu, 14 Dec 2006 17:49:54 -0500
Received: from d01av02.pok.ibm.com (loopback [127.0.0.1])
	by d01av02.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id kBEMnrSE027747
	for <netdev@vger.kernel.org>; Thu, 14 Dec 2006 17:49:54 -0500
To: akepner@sgi.com, Ishizaki Kou <kou.ishizaki@toshiba.co.jp>
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.61.0612141244160.30447@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Dec 14, 2006 at 12:51:14PM -0800, akepner@sgi.com wrote:
> On Thu, 14 Dec 2006, Linas Vepstas wrote:
> 
> >On Wed, Nov 08, 2006 at 07:38:12AM +1100, Benjamin Herrenschmidt wrote:
> >>
> >>What about Linas patches to do interrupt mitigation with NAPI polling ?
> >>That didn't end up working ?
> >
> >It seems to be "working as designed", which is different than "working
> >as naively expected".
> >
> >For large packets:
> >-- a packet comes in
> >-- rx interrupt generated
> >-- rx interrupts turned off
> >-- tcp poll function runs, receives packet
> >-- completes all work before next packet has arrived,
> >  so interupts are turned back on.
> >-- go to start
> >
> >This results in a high number of interrupts, and a high cpu usage.
> >We were able to prove that napi works by stalling in the poll function
> >just long enough to allow the next packet to arrive.  In this case,
> >napi works great, and number of irqs is vastly reduced.
> >....
> 
> This sounds awfully familiar. We went through the same
> with the tg3 driver on Altix. In that case we succeeded
> getting interrupt coalescence added to the driver, which
> ended up working pretty well for us. See the thread
> beginning with:
> 
> http://oss.sgi.com/archives/netdev/2005-05/msg00497.html
> 
> if you're interested.

I'm interested. The tg3 seems to have "hardware coalescing",
which, from what I can tell, is a way of delaying an RX
interrupt for some number of microseconds?  I assume there's 
nothing more to it than that?

The spider has some suggestively named registers and functions,
hinting that it can similarly delay an RX interupt, but the 
docs are opaque and mysteriously worded, so I cannot really tell.

Perhaps Ishizaki Kou can clue us in? 

> As for the "stalling NAPI" idea, Jamal did a bit of work
> with that idea and wrote it up in:
> 
> www.kernel.org/pub/linux/kernel/people/hadi/docs/UKUUG2005.pdf

Reading now ... 

--linas
