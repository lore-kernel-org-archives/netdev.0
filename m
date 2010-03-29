From: Al Viro <viro@ZenIV.linux.org.uk>
Subject: Re: [PATCH] r8169: fix broken register writes
Date: Mon, 29 Mar 2010 03:17:30 +0100
Message-ID: <20100329021730.GI30031@ZenIV.linux.org.uk>
References: <4BAE6C92.2060801@iki.fi>
 <20100327211133.GA3624@electric-eye.fr.zoreil.com>
 <1269732054.8653.155.camel@localhost>
 <20100327.163005.28815553.davem@davemloft.net>
 <20100328003143.GA8501@electric-eye.fr.zoreil.com>
 <1269737245.8653.162.camel@localhost>
 <20100328212858.GA4220@electric-eye.fr.zoreil.com>
 <20100328221924.GG30031@ZenIV.linux.org.uk>
 <20100329010346.GH30031@ZenIV.linux.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Ben Hutchings <ben@decadent.org.uk>,
	David Miller <davem@davemloft.net>, timo.teras@iki.fi,
	ivecera@redhat.com, netdev@vger.kernel.org
To: Fran?ois Romieu <romieu@fr.zoreil.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from zeniv.linux.org.uk ([195.92.253.2]:38405 "EHLO
	ZenIV.linux.org.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753967Ab0C2CSD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 28 Mar 2010 22:18:03 -0400
Content-Disposition: inline
In-Reply-To: <20100329010346.GH30031@ZenIV.linux.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Mar 29, 2010 at 02:03:46AM +0100, Al Viro wrote:
> On Sun, Mar 28, 2010 at 11:19:24PM +0100, Al Viro wrote:
> 
> > > > Thanks Fran?ois.  Which hardware have you tested this on so far ?
> > > 
> > > 10ec:8169 (rev 10) / RTL8169sb/8110sb / XID 10000000
> > > 
> > > Timo's is a 10ec:8167 / RTL8169sc/8110sc / XID 18000000. He only tested
> > > the MAC[04] part.
> > 
> > FWIW, XID18000000 here (J7F4) loses MAC4 on shutdown; hadn't tested the patch
> > yet.  2.6.26 (on that box) and 2.6.31 (on identical mb) work, 2.6.33 doesn't.
> > I suspect that bisect would lead to commit cc098dc70 (i.e. the place where we
> > started to set address on shutdown).  One more data point: ifconfig hw ether
> > done under 2.6.26 did restore the address.  And that's the same function,
> > isn't it?
> 
> As the matter of fact, ifconfig eth0 hw ether .... ends up zeroing upper
> 32 bits on old kernels once in a while.

BTW, patch from upthread doesn't help on that box, and neither does
simple reordering of MAC0 and MAC4 writes.  Adding reads of MAC0 and
MAC4 after corresponding writes seems to work.
