From: Andrew Morton <akpm@osdl.org>
Subject: Re: [patch 3/6] 2.6.18: sb1250-mac: Phylib IRQ handling fixes
Date: Fri, 20 Oct 2006 15:13:28 -0700
Message-ID: <20061020151328.788bc38e.akpm@osdl.org>
References: <Pine.LNX.4.64N.0610031509380.4642@blysk.ds.pg.gda.pl>
	<E2ACBAE3-B0E1-4D90-BF25-6981543090C4@freescale.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: "Maciej W. Rozycki" <macro@linux-mips.org>,
	Jeff Garzik <jgarzik@pobox.com>,
	Ralf Baechle <ralf@linux-mips.org>, netdev@vger.kernel.org,
	linux-mips@linux-mips.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.4]:27789 "EHLO smtp.osdl.org")
	by vger.kernel.org with ESMTP id S1422748AbWJTWNv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 Oct 2006 18:13:51 -0400
To: Andy Fleming <afleming@freescale.com>
In-Reply-To: <E2ACBAE3-B0E1-4D90-BF25-6981543090C4@freescale.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 20 Oct 2006 16:40:20 -0500
Andy Fleming <afleming@freescale.com> wrote:

> >    The solution is to ignore phy_interrupt() calls if the reported  
> > device
> >    has already been halted and calling flush_scheduled_work() from
> >    phy_stop_interrupts() (but guarded with current_is_keventd() in  
> > case
> >    the function has been called through keventd from the MAC device's
> >    close call to avoid a deadlock on the netlink lock).
> 
> 
> I've been trying to figure out this problem since you posted this,  
> and I'm not sure I understand it fully

Me either, but I basically gave up.

If it is deadlocky for keventd to call flush_scheduled_work() I fail to see
why it is not deadlocky for other processes.

If the caller of flush_scheduled_work() holds rtnl_lock, and if a queued
work callback also takes rtnl_lock then the flush_scheduled_work() caller
will deadlock regardless of whether or not it is keventd.

Because the flush_scheduled_work() caller holds a lock which will prevent
the flush from completing.

