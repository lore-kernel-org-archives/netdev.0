From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] [stable 2.6.27.y] don't take the mdio_lock in
 atl1e_probe
Date: Sat, 11 Oct 2008 11:08:16 -0700 (PDT)
Message-ID: <20081011.110816.15486713.davem@davemloft.net>
References: <20081011100501.7ff818ce@osprey.hogchain.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: stable@kernel.org, willy@linux.intel.com, jgarzik@redhat.com,
	csnook@redhat.com, jie.yang@atheros.com, netdev@vger.kernel.org,
	jcliburn@gmail.com, nm127@freemail.hu, akpm@linux-foundation.org
To: jacliburn@bellsouth.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:41730
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1762151AbYJKSIk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 11 Oct 2008 14:08:40 -0400
In-Reply-To: <20081011100501.7ff818ce@osprey.hogchain.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jay Cliburn <jacliburn@bellsouth.net>
Date: Sat, 11 Oct 2008 10:05:01 -0500

> From: Matthew Wilcox <matthew@wil.cx>
> 
> Upstream commit: f382a0a8e9403c6d7f8b2cfa21e41fefb5d0c9bd
> 
> This fixes bug 11736.
> 
> http://marc.info/?l=linux-netdev&m=122367387219316&w=2
> 
> Lockdep warns about the mdio_lock taken with interrupts enabled then
> later taken from interrupt context.  Initially, I considered changing
> these to spin_lock_irq/spin_unlock_irq, but then I looked at
> atl1e_phy_init() and saw that it calls msleep().  Sleeping while
> holding a spinlock is not allowed either.
> 
> In the probe path, we haven't registered the interrupt handler, so
> it can't poke at this card yet.  It's before we call register_netdev(),
> so I don't think any other threads can reach this card either.  If I'm
> right, we don't need a spinlock at all.
> 
> Signed-off-by: Matthew Wilcox <willy@linux.intel.com>
> Signed-off-by: Jeff Garzik <jgarzik@redhat.com>

Signed-off-by: David S. Miller <davem@davemloft.net>
