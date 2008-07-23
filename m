From: David Miller <davem@davemloft.net>
Subject: Re: [RFC] napi: adding an administrative state & priority
Date: Wed, 23 Jul 2008 14:11:58 -0700 (PDT)
Message-ID: <20080723.141158.99031196.davem@davemloft.net>
References: <20080723192548.GA14654@hmsreliant.think-freely.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jgarzik@pobox.com
To: nhorman@tuxdriver.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:60249
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1754606AbYGWVL6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Jul 2008 17:11:58 -0400
In-Reply-To: <20080723192548.GA14654@hmsreliant.think-freely.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Neil Horman <nhorman@tuxdriver.com>
Date: Wed, 23 Jul 2008 15:27:13 -0400

> 1) An administrative state for napi, specifically administratively disabled
> state, on a per-interface basis.  When napi was administratively disabled the
> interface would behave as though napi had never been configured on it.  I.E.
> netif_rx_schedule would call directly into dev->poll with a budget of 1, so as
> to behave like a legacy interrupt handler.   setting of this administrative
> state can be handled through sysfs

It's not going to be the same, by a large margin.

The MMIO operations required by NAPI to disable and enable interrupts
on most hardware is extremely expensive.

The only way to mitigate that cost is a combination of software (NAPI)
and hardware interrupt mitigation.

And therefore...

> My reasoning for these features is common in that I've had occasion to observe
> some workloads where incomming data that is highly sensitive to loss and
> latency, gets lost near the hardware.  Most often this happens because the
> latency from the time of interrupt to the time of serving in dev->poll is
> sufficient to overrun a hardware buffer, or the devices ring buffer.  While ring
> buffers can be extended, I'm personally loathe to simply try out run the problem
> by adding ring-buffer space.  It would be nice if we had a way to drain the
> overrunning queue faster, rather than just making it longer.

this feature is not going to help you reach your objective.

In fact, disabling NAPI by decreasing the quota to 1 is going to
result in more, not less, packet loss under high load.
