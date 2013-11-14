From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] connector: improved unaligned access error fix
Date: Thu, 14 Nov 2013 17:20:23 -0500 (EST)
Message-ID: <20131114.172023.1565829138219271745.davem@davemloft.net>
References: <201311141743.rAEHhuEV004998@farm-0012.internal.tilera.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: zbr@ioremap.net, erikj@sgi.com, akpm@osdl.org, matthltc@us.ibm.com,
	zaitcev@redhat.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: cmetcalf@tilera.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <201311141743.rAEHhuEV004998@farm-0012.internal.tilera.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Chris Metcalf <cmetcalf@tilera.com>
Date: Thu, 14 Nov 2013 12:09:21 -0500

> In af3e095a1fb4, Erik Jacobsen fixed one type of unaligned access
> bug for ia64 by converting a 64-bit write to use put_unaligned().
> Unfortunately, since gcc will convert a short memset() to a series
> of appropriately-aligned stores, the problem is now visible again
> on tilegx, where the memset that zeros out proc_event is converted
> to three 64-bit stores, causing an unaligned access panic.
> 
> A better fix for the original problem is to ensure that proc_event
> is aligned to 8 bytes here.  We can do that relatively easily by
> arranging to start the struct cn_msg aligned to 8 bytes and then
> offset by 4 bytes.  Doing so means that the immediately following
> proc_event structure is then correctly aligned to 8 bytes.
> 
> The result is that the memset() stores are now aligned, and as an
> added benefit, we can remove the put_unaligned() calls in the code.
> 
> Signed-off-by: Chris Metcalf <cmetcalf@tilera.com>

This looks fine to me, applied and queued up for -stable, thanks
Chris.
