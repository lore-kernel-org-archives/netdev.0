From: Stephen Hemminger <stephen.hemminger@vyatta.com>
Subject: Re: [PATCH 2/3] net: Add net device irq siloing feature
Date: Fri, 15 Apr 2011 21:52:24 -0700 (PDT)
Message-ID: <367764507.40661.1302929544356.JavaMail.root@tahiti.vyatta.com>
References: <20110416014547.GA2200@neilslaptop.think-freely.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net,
	Dimitris Michailidis <dm@chelsio.com>,
	Thomas Gleixner <tglx@linutronix.de>,
	David Howells <dhowells@redhat.com>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Tom Herbert <therbert@google.com>,
	Ben Hutchings <bhutchings@solarflare.com>
To: Neil Horman <nhorman@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:37585 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750788Ab1DPEw3 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 16 Apr 2011 00:52:29 -0400
In-Reply-To: <20110416014547.GA2200@neilslaptop.think-freely.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


> On Fri, Apr 15, 2011 at 11:49:03PM +0100, Ben Hutchings wrote:
> > On Fri, 2011-04-15 at 16:17 -0400, Neil Horman wrote:
> > > Using the irq affinity infrastrucuture, we can now allow net
> > > devices to call
> > > request_irq using a new wrapper function (request_net_irq), which
> > > will attach a
> > > common affinty_update handler to each requested irq. This affinty
> > > update mechanism correlates each tracked irq to the flow(s) that
> > > said irq processes
> > > most frequently. The highest traffic flow is noted, marked and
> > > exported to user
> > > space via the affinity_hint proc file for each irq. In this way,
> > > utilities like
> > > irqbalance are able to determine which cpu is recieving the most
> > > data from each
> > > rx queue on a given NIC, and set irq affinity accordingly.
> > [...]
> >
> > Is irqbalance expected to poll the affinity hints? How often?
> >
> Yes, its done just that for quite some time. Intel added that ability
> at the
> same time they added the affinity_hint proc file. Irqbalance polls the
> affinity_hint file at the same time it rebalances all irqs (every 10
> seconds). If the affinity_hint is non-zero, irqbalance just copies it
> to smp_affinity for
> the same irq. Up until now thats been just about dead code because
> only ixgbe
> sets affinity_hint. Thats why I added the affinity_alg file, so
> irqbalance could do something more intellegent than just a blind copy.
> With the patch that
> I referenced I added code to irqbalance to allow it to preform
> different balancing methods based on the output of affinity_alg.
> Neil

I hate the way more and more interfaces are becoming device driver
specific. It makes it impossible to build sane management infrastructure
and causes lots of customer and service complaints.

