From: "=?ISO-8859-1?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: Re: tbench wrt. loopback TSO
Date: Mon, 27 Oct 2008 09:49:21 +0200 (EET)
Message-ID: <Pine.LNX.4.64.0810270942430.1290@wrl-59.cs.helsinki.fi>
References: <20081015.171408.193701292.davem@davemloft.net>
 <20081026123442.GA31506@ioremap.net> <20081026.185911.193696873.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: Netdev <netdev@vger.kernel.org>, efault@gmx.de, mingo@elte.hu,
	a.p.zijlstra@chello.nl, Herbert Xu <herbert@gondor.apana.org.au>
To: zbr@ioremap.net, David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:53998 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751624AbYJ0HtZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 27 Oct 2008 03:49:25 -0400
In-Reply-To: <20081026.185911.193696873.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 26 Oct 2008, David Miller wrote:

> From: Evgeniy Polyakov <zbr@ioremap.net>
> Date: Sun, 26 Oct 2008 15:34:42 +0300
> 
> > On Wed, Oct 15, 2008 at 05:14:08PM -0700, David Miller (davem@davemloft.net) wrote:
> > > 
> > > I got curious about this aspect of the investigation so I wanted
> > > to see it first-hand :-)
> > > 
> > > To be honest, this reported effect of disabling TSO in the loopback
> > > driver surprised me because:
> > > 
> > > 1) If the benchmark is doing small writes, TSO should have zero
> > >    effect.  The TSO logic won't kick in.
> > 
> > But GSO will try to create a huge packet and that overhead will not be
> > overweighted?
> > 
> > That's what I got with the current tree for 8 threads on a 4-way 32-bit
> > Xeons (2 physical CPUs) and 8gb of ram:
> > gso/tso off: 361.367
> > tso/gso on:  354.635
> > 
> > Disabled/enabled via ethtools: -k tso off/on gso off/on
> 
> Yes, it might do this, in which case tcp_tso_should_defer() simply needs
> some tweaking.

Good point, could you Evgeniy verify first if simple goto send_now; in 
beginning there recovers it all...

-- 
 i.
