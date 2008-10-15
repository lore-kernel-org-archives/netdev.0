From: Greg KH <greg@kroah.com>
Subject: Re: [stable] [PATCH] [stable 2.6.27.y] don't take the mdio_lock in
	atl1e_probe
Date: Wed, 15 Oct 2008 15:15:37 -0700
Message-ID: <20081015221537.GA22555@kroah.com>
References: <20081011100501.7ff818ce@osprey.hogchain.net> <20081011.110816.15486713.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: jacliburn@bellsouth.net, jcliburn@gmail.com, nm127@freemail.hu,
	netdev@vger.kernel.org, jie.yang@atheros.com, jgarzik@redhat.com,
	willy@linux.intel.com, akpm@linux-foundation.org,
	csnook@redhat.com, stable@kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from kroah.org ([198.145.64.141]:57284 "EHLO coco.kroah.org"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752195AbYJOWTG (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 15 Oct 2008 18:19:06 -0400
Content-Disposition: inline
In-Reply-To: <20081011.110816.15486713.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Oct 11, 2008 at 11:08:16AM -0700, David Miller wrote:
> From: Jay Cliburn <jacliburn@bellsouth.net>
> Date: Sat, 11 Oct 2008 10:05:01 -0500
> 
> > From: Matthew Wilcox <matthew@wil.cx>
> > 
> > Upstream commit: f382a0a8e9403c6d7f8b2cfa21e41fefb5d0c9bd
> > 
> > This fixes bug 11736.
> > 
> > http://marc.info/?l=linux-netdev&m=122367387219316&w=2
> > 
> > Lockdep warns about the mdio_lock taken with interrupts enabled then
> > later taken from interrupt context.  Initially, I considered changing
> > these to spin_lock_irq/spin_unlock_irq, but then I looked at
> > atl1e_phy_init() and saw that it calls msleep().  Sleeping while
> > holding a spinlock is not allowed either.
> > 
> > In the probe path, we haven't registered the interrupt handler, so
> > it can't poke at this card yet.  It's before we call register_netdev(),
> > so I don't think any other threads can reach this card either.  If I'm
> > right, we don't need a spinlock at all.
> > 
> > Signed-off-by: Matthew Wilcox <willy@linux.intel.com>
> > Signed-off-by: Jeff Garzik <jgarzik@redhat.com>
> 
> Signed-off-by: David S. Miller <davem@davemloft.net>

Does this mean you will forward this to -stable in a bunch of network
patches?  Or should I take it now?

thanks,

greg k-h
