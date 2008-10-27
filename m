From: David Miller <davem@davemloft.net>
Subject: Re: tbench wrt. loopback TSO
Date: Mon, 27 Oct 2008 12:37:17 -0700 (PDT)
Message-ID: <20081027.123717.71252945.davem@davemloft.net>
References: <20081027170314.GA25148@ioremap.net>
	<20081027.113904.211811887.davem@davemloft.net>
	<20081027193502.GA2590@ioremap.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ilpo.jarvinen@helsinki.fi, netdev@vger.kernel.org, efault@gmx.de,
	mingo@elte.hu, a.p.zijlstra@chello.nl, herbert@gondor.apana.org.au
To: zbr@ioremap.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:53360
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1750784AbYJ0Thk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 27 Oct 2008 15:37:40 -0400
In-Reply-To: <20081027193502.GA2590@ioremap.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Evgeniy Polyakov <zbr@ioremap.net>
Date: Mon, 27 Oct 2008 22:35:02 +0300

> On Mon, Oct 27, 2008 at 11:39:04AM -0700, David Miller (davem@davemloft.net) wrote:
> > One idea immediately occurs to me.  Since we're effectively limited
> > to a 64K TSO frame, and the MSS is some value smaller than that, we
> > can probably get away with a reciprocol divide.  Even using a 16-bit
> > inverse value would suffice, so we wouldn't need to use u64's like
> > some other pieces of code do.  A u32 would be enough.
> 
> But why do we need to trim that last bytes at the first place at all?
> Is it just enough to 'binary and' with 0xffff? Or is it what you mean? :)

We need to trim because we want to send full sized frames onto the
network, and those trailing bytes will make sub-MSS sized frame
instead of coalescing with the next round of user sendmsg() data.
