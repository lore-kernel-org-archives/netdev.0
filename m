From: Lennert Buytenhek <buytenh@wantstofly.org>
Subject: Re: [PATCH,RFC] Re: r8169 driver problem with RTL8110SB chip (on iop3xx ARM board)
Date: Tue, 5 Sep 2006 00:07:41 +0200
Message-ID: <20060904220741.GE3782@xi.wantstofly.org>
References: <20060728101109.GA25854@xi.wantstofly.org> <20060818212852.GA5379@xi.wantstofly.org> <20060820213558.GA13188@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, tbm@cyrius.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from alephnull.demon.nl ([83.160.184.112]:53897 "EHLO
	xi.wantstofly.org") by vger.kernel.org with ESMTP id S1751489AbWIDWHn
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 4 Sep 2006 18:07:43 -0400
To: Francois Romieu <romieu@fr.zoreil.com>
Content-Disposition: inline
In-Reply-To: <20060820213558.GA13188@electric-eye.fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sun, Aug 20, 2006 at 11:35:58PM +0200, Francois Romieu wrote:

> > 1. Writing zero to the upper part of the TxDescStartAddr register (via
> >    the MMIO region) somehow also clears the lower part, and writing the
> >    upper and lower halves the other way round fixes it.  The RxDescAddr
> >    register doesn't seem to suffer from this problem.
> > 
> >    The Realtek r1000 driver writes the two halves in the same order as
> >    r8169, but it doesn't happen there, which is a bit of a mystery to
> >    me.
> > 
> > [snip]
> 
> 1 - unknown so far. Realtek's driver actually use IO, not MM. I do not see
>     why it would make a difference as long as posteed writes are correctly
>     taken care of.

I suspect it's a chip bug.  I rechecked with I/O space, and that works
okay, so this artifact (bug) only manifests itself when you do the upper
write in MMIO space.

Are there any plans to switch r8169 to the iomap API?  Would you take
a patch if I'd write one?


cheers,
Lennert
