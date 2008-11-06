From: David Miller <davem@davemloft.net>
Subject: Re: UNIX sockets kernel panic
Date: Wed, 05 Nov 2008 17:18:22 -0800 (PST)
Message-ID: <20081105.171822.193705306.davem@davemloft.net>
References: <20081106001445.GA5595@shorty>
	<20081106011319.GA22389@x200.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, a.bittau@cs.ucl.ac.uk
To: adobriyan@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:40923
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753060AbYKFBSX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 5 Nov 2008 20:18:23 -0500
In-Reply-To: <20081106011319.GA22389@x200.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexey Dobriyan <adobriyan@gmail.com>
Date: Thu, 6 Nov 2008 04:13:19 +0300

> On Thu, Nov 06, 2008 at 12:14:46AM +0000, Andrea Bittau wrote:
> > The following code causes a kernel panic on Linux 2.6.26:
> > http://darkircop.org/unix.c
> > 
> > I haven't investigated the bug so I'm not sure what is causing it, and
> > don't know if it's exploitable.  The code passes unix sockets from one
> > process to another using unix sockets.  The bug probably has to do with
> > closing file descriptors.
> 
> Aie, nice localhost DoS (random oopses)

Indeed.  I'm looking at it too and in my case I get random memory
corruption, usually it's skb->destruct being set to garbage and then
we hit the WARN_ON(in_irq()) in net/core/skbuff.c

I think the key is passing a unix socket fd (as opposed to some other
kind of fd) using SCM_RIGHTS and the ordering of the fd closes.
