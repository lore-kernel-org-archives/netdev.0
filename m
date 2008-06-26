From: Andy Gospodarek <andy@greyhouse.net>
Subject: Re: [PATCH] igb: completely disable interrupts during netpoll
Date: Wed, 25 Jun 2008 22:49:27 -0400
Message-ID: <20080626024927.GC32408@gospo.rdu.redhat.com>
References: <20080625141511.GH22981@gospo.rdu.redhat.com> <20080625.152751.154176346.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: andy@greyhouse.net, jeffrey.t.kirsher@intel.com,
	jesse.brandeburg@intel.com, bruce.w.allan@intel.com,
	john.ronciak@intel.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:52389 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751999AbYFZCtb (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 25 Jun 2008 22:49:31 -0400
Content-Disposition: inline
In-Reply-To: <20080625.152751.154176346.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jun 25, 2008 at 03:27:51PM -0700, David Miller wrote:
> From: Andy Gospodarek <andy@greyhouse.net>
> Date: Wed, 25 Jun 2008 10:15:11 -0400
> 
> > 
> > Globally disable the interrupt during netpoll rather than simply
> > disabling it on the hardware.  This will ensure all pending operations
> > are complete and no more will execute.  I've seen reports of deadlocks
> > with the current driver and this patch resolves them.
> 
> I don't want to see network drivers start getting into the habit
> of doing this.  This operation could be extremely expensive with
> certain IRQ controllers.
> 
> It's better to have a good understanding of why the deadlocks
> happen, and this was decidedly missing from your commit message.
> 

I thought this was a pretty common problem that cannot simply be solved
with a call to synchronize_irq since you might get one that pops on
another CPU and doesn't set the in-progress bit before your
synchronize_irq call completes?

