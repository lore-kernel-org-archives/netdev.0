From: "Dale Farnsworth" <dale@farnsworth.org>
Subject: Re: [PATCH] Merge GT/MV642xx Support into MV643xx Driver [7/8]
Date: Thu, 19 Jul 2007 20:40:43 -0700
Message-ID: <20070720034043.GA28756@xyzzy.farnsworth.org>
References: <469EEF13.2000607@realitydiluted.com> <20070719142159.GF12892@xyzzy.farnsworth.org> <46A01992.1060907@realitydiluted.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: "Steven J. Hill" <sjhill@realitydiluted.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from xyzzy.farnsworth.org ([65.39.95.219]:3171 "HELO farnsworth.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with SMTP
	id S1754546AbXGTDkq (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 19 Jul 2007 23:40:46 -0400
Content-Disposition: inline
In-Reply-To: <46A01992.1060907@realitydiluted.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Jul 19, 2007 at 09:10:26PM -0500, Steven J. Hill wrote:
> Dale Farnsworth wrote:
> > 
> > You have replaced the use of the global PHY spinlock with a per-port spinlock.
> > However, the SMI register is shared by all ports.  The global lock is
> > needed to prevent simultaneous updates of the register by drivers for
> > multiple ports.
> > 
> > NAK
> >
> Are you sure? Notice that a majority of the spinlocks were changed to disable
> IRQs. Secondly, the lowest level mv_read/mv_write functions have to acquire
> the big mv64x60_lock before they can read or write registers. I see the PHY
> spinlock as being an additional and unnecessary lock to contend with. Am I
> make an improper assumption?

I'm sure.  (Of course, I could be wrong.)  On an SMP (or fully
preemptive) system, disabling IRQs doesn't provide sufficient
protection.  Nor does a per-port spinlock, since multiple ports
share the single register.  It seems to me that a driver-scope
lock is required.

-Dale
