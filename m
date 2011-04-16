From: Neil Horman <nhorman@tuxdriver.com>
Subject: Re: [PATCH 2/3] net: Add net device irq siloing feature
Date: Fri, 15 Apr 2011 21:49:03 -0400
Message-ID: <20110416014547.GA2200@neilslaptop.think-freely.org>
References: <1302898677-3833-1-git-send-email-nhorman@tuxdriver.com>
 <1302898677-3833-3-git-send-email-nhorman@tuxdriver.com>
 <1302907743.2845.23.camel@bwh-desktop>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, davem@davemloft.net,
	Dimitris Michailidis <dm@chelsio.com>,
	Thomas Gleixner <tglx@linutronix.de>,
	David Howells <dhowells@redhat.com>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Tom Herbert <therbert@google.com>
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:50155 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756673Ab1DPBtS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 15 Apr 2011 21:49:18 -0400
Content-Disposition: inline
In-Reply-To: <1302907743.2845.23.camel@bwh-desktop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Apr 15, 2011 at 11:49:03PM +0100, Ben Hutchings wrote:
> On Fri, 2011-04-15 at 16:17 -0400, Neil Horman wrote:
> > Using the irq affinity infrastrucuture, we can now allow net devices to call
> > request_irq using a new wrapper function (request_net_irq), which will attach a
> > common affinty_update handler to each requested irq.  This affinty update
> > mechanism correlates each tracked irq to the flow(s) that said irq processes
> > most frequently.  The highest traffic flow is noted, marked and exported to user
> > space via the affinity_hint proc file for each irq. In this way, utilities like
> > irqbalance are able to determine  which cpu is recieving the most data from each
> > rx queue on a given NIC, and set irq affinity accordingly.
> [...]
> 
> Is irqbalance expected to poll the affinity hints?  How often?
> 
Yes, its done just that for quite some time.  Intel added that ability at the
same time they added the affinity_hint proc file.  Irqbalance polls the
affinity_hint file at the same time it rebalances all irqs (every 10 seconds).
If the affinity_hint is non-zero, irqbalance just copies it to smp_affinity for
the same irq.  Up until now thats been just about dead code because only ixgbe
sets affinity_hint.  Thats why I added the affinity_alg file, so irqbalance
could do something more intellegent than just a blind copy.  With the patch that
I referenced I added code to irqbalance to allow it to preform different
balancing methods based on the output of affinity_alg.
Neil

> Ben.
> 
> -- 
> Ben Hutchings, Senior Software Engineer, Solarflare
> Not speaking for my employer; that's the marketing department's job.
> They asked us to note that Solarflare product names are trademarked.
> 
> 
