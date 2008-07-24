From: Neil Horman <nhorman@tuxdriver.com>
Subject: Re: [RFC] napi: adding an administrative state & priority
Date: Wed, 23 Jul 2008 21:21:15 -0400
Message-ID: <20080724012115.GA17150@hmsreliant.think-freely.org>
References: <20080723192548.GA14654@hmsreliant.think-freely.org> <20080723.141158.99031196.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, jgarzik@pobox.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ra.tuxdriver.com ([70.61.120.52]:3225 "EHLO ra.tuxdriver.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750836AbYGXBVw (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 23 Jul 2008 21:21:52 -0400
Content-Disposition: inline
In-Reply-To: <20080723.141158.99031196.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jul 23, 2008 at 02:11:58PM -0700, David Miller wrote:
> From: Neil Horman <nhorman@tuxdriver.com>
> Date: Wed, 23 Jul 2008 15:27:13 -0400
> 
> > 1) An administrative state for napi, specifically administratively disabled
> > state, on a per-interface basis.  When napi was administratively disabled the
> > interface would behave as though napi had never been configured on it.  I.E.
> > netif_rx_schedule would call directly into dev->poll with a budget of 1, so as
> > to behave like a legacy interrupt handler.   setting of this administrative
> > state can be handled through sysfs
> 
> It's not going to be the same, by a large margin.
> 
> The MMIO operations required by NAPI to disable and enable interrupts
> on most hardware is extremely expensive.
> 
> The only way to mitigate that cost is a combination of software (NAPI)
> and hardware interrupt mitigation.
> 
> And therefore...
> 
> > My reasoning for these features is common in that I've had occasion to observe
> > some workloads where incomming data that is highly sensitive to loss and
> > latency, gets lost near the hardware.  Most often this happens because the
> > latency from the time of interrupt to the time of serving in dev->poll is
> > sufficient to overrun a hardware buffer, or the devices ring buffer.  While ring
> > buffers can be extended, I'm personally loathe to simply try out run the problem
> > by adding ring-buffer space.  It would be nice if we had a way to drain the
> > overrunning queue faster, rather than just making it longer.
> 
> this feature is not going to help you reach your objective.
> 
> In fact, disabling NAPI by decreasing the quota to 1 is going to
> result in more, not less, packet loss under high load.

I'd like to find some time to observe this for myself, but I'll certainly take
my word for it now.  This begs the question however, how does one mitigate drops
near the hardware, when tuning interrupt coalescing for minimum latency isn't
enough.  Are ring buffer size and napi weight our only choices?  Or is there an
alternate approach to drain the ring buffer more quickly?

And what are your thoughts regarding the creation of a napi instance priority
scheme?  I understand your arguments for not disabling napi entirely, but it
doesn't speak to prioritization.  I can still see a benefit to instructing the
kernel to serve a interface first handling high priority traffic.

thanks for your input!

Best
Neil

-- 
/****************************************************
 * Neil Horman <nhorman@tuxdriver.com>
 * Software Engineer, Red Hat
 ****************************************************/
