From: Russell King - ARM Linux <linux@arm.linux.org.uk>
Subject: Re: [PATCH v4] lpc32xx: Added ethernet driver: smp_wmb()
Date: Tue, 6 Mar 2012 14:17:45 +0000
Message-ID: <20120306141745.GA15201@n2100.arm.linux.org.uk>
References: <1330983641-32622-1-git-send-email-stigge@antcom.de> <1330987524.2538.61.camel@bwh-desktop> <4F55EA6D.3070602@antcom.de> <1331042608.2347.1.camel@bwh-desktop>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Roland Stigge <stigge@antcom.de>, alexander.h.duyck@intel.com,
	baruch@tkos.co.il, ian.campbell@citrix.com, arnd@arndb.de,
	netdev@vger.kernel.org, eilong@broadcom.com, kevin.wells@nxp.com,
	w.sang@pengutronix.de, jeffrey.t.kirsher@intel.com,
	joe@perches.com, davem@davemloft.net, linux-kernel@vger.kernel.org,
	linux-arm-kernel@lists.infradead.org
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from caramon.arm.linux.org.uk ([78.32.30.218]:34064 "EHLO
	caramon.arm.linux.org.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S965183Ab2CFOSX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 6 Mar 2012 09:18:23 -0500
Content-Disposition: inline
In-Reply-To: <1331042608.2347.1.camel@bwh-desktop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Mar 06, 2012 at 02:03:28PM +0000, Ben Hutchings wrote:
> On Tue, 2012-03-06 at 11:43 +0100, Roland Stigge wrote:
> > On 03/05/2012 11:45 PM, Ben Hutchings wrote:
> > >> +	/* Clear and enable interrupts */
> > >> +	writel(0xFFFF, LPC_ENET_INTCLEAR(pldat->net_base));
> > >> +	lpc_eth_enable_int(pldat->net_base);
> > >> +
> > >> +	/* Get the next TX buffer output index */
> > >> +	pldat->num_used_tx_buffs = 0;
> > >> +	pldat->last_tx_idx =
> > >> +		readl(LPC_ENET_TXCONSUMEINDEX(pldat->net_base));
> > > 
> > > Doesn't this need to be done *before* enabling interrupts?  Also, I
> > > think you need an smp_wmb() so that the interrupt handler is guaranteed
> > > to see all these writes.
> > 
> > Do you mean _one_ smp_wmb() directly after lpc_eth_enable_int() (which
> > I'm moving behind the above code?
> 
> The sequence should be
> 
> 	pldat->state = values...;
> 	smp_wmb();
> 	enable_interrupts();

Is this correct?

"SMP BARRIER PAIRING" and "EXAMPLES OF MEMORY BARRIER SEQUENCES" in
Documentation/memory-barriers.txt suggest that there should be some kind
of pairing with smp_wmb() to ensure correctness.
