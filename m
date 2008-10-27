From: David Miller <davem@davemloft.net>
Subject: Re: tbench wrt. loopback TSO
Date: Sun, 26 Oct 2008 18:59:11 -0700 (PDT)
Message-ID: <20081026.185911.193696873.davem@davemloft.net>
References: <20081015.171408.193701292.davem@davemloft.net>
	<20081026123442.GA31506@ioremap.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, efault@gmx.de, mingo@elte.hu,
	a.p.zijlstra@chello.nl, herbert@gondor.apana.org.au
To: zbr@ioremap.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:33786
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751724AbYJ0CGX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 26 Oct 2008 22:06:23 -0400
In-Reply-To: <20081026123442.GA31506@ioremap.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Evgeniy Polyakov <zbr@ioremap.net>
Date: Sun, 26 Oct 2008 15:34:42 +0300

> On Wed, Oct 15, 2008 at 05:14:08PM -0700, David Miller (davem@davemloft.net) wrote:
> > 
> > I got curious about this aspect of the investigation so I wanted
> > to see it first-hand :-)
> > 
> > To be honest, this reported effect of disabling TSO in the loopback
> > driver surprised me because:
> > 
> > 1) If the benchmark is doing small writes, TSO should have zero
> >    effect.  The TSO logic won't kick in.
> 
> But GSO will try to create a huge packet and that overhead will not be
> overweighted?
> 
> That's what I got with the current tree for 8 threads on a 4-way 32-bit
> Xeons (2 physical CPUs) and 8gb of ram:
> gso/tso off: 361.367
> tso/gso on:  354.635
> 
> Disabled/enabled via ethtools: -k tso off/on gso off/on

Yes, it might do this, in which case tcp_tso_should_defer() simply needs
some tweaking.
