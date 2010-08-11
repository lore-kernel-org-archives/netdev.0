From: Neil Horman <nhorman@tuxdriver.com>
Subject: Re: [PATCH] Fix deadlock between boomerang_interrupt and
 boomerang_start_tx in 3c59x
Date: Wed, 11 Aug 2010 13:51:30 -0400
Message-ID: <20100811175130.GC23317@hmsreliant.think-freely.org>
References: <20100811151257.GB23317@hmsreliant.think-freely.org>
 <20100811120900.3629706c@s6510>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:54776 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758246Ab0HKR4A (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 Aug 2010 13:56:00 -0400
Content-Disposition: inline
In-Reply-To: <20100811120900.3629706c@s6510>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Aug 11, 2010 at 12:09:00PM -0400, Stephen Hemminger wrote:
> On Wed, 11 Aug 2010 11:12:57 -0400
> Neil Horman <nhorman@tuxdriver.com> wrote:
> 
> > If netconsole is in use, there is a possibility for deadlock in 3c59x between
> > boomerang_interrupt and boomerang_start_xmit.  Both routines take the vp->lock,
> > and if netconsole is in use, a pr_* call from the boomerang_interrupt routine
> > will result in the netconsole code attempting to trnasmit an skb, which can try
> > to take the same spin lock, resulting in de
> 
> I thought we agreed that any device supporting netconsole agrees
> to not call printk in the transmit path. Just kill the pr_* call.
> 

3c59x isn't calling pr_* in the transmit path, its calling it in the interrupt
handler, but since the interrupt handler and the transmit path share a spinlock,
you get a deadlock in that case.  We could kill the several pr_debug calls in
the interrupt path, but I don't think thats really needed in this case.

Neil

