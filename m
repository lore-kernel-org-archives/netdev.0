From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v4 1/1] rps: core implementation
Date: Fri, 20 Nov 2009 16:05:07 -0800 (PST)
Message-ID: <20091120.160507.110482370.davem@davemloft.net>
References: <65634d660911201528k5a07135el471b65fff9dd7c9d@mail.gmail.com>
	<20091120.153913.242783116.davem@davemloft.net>
	<65634d660911201550v34bc463ao17dcd7b16f62264f@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: therbert@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:55523
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753313AbZKUAEu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 Nov 2009 19:04:50 -0500
In-Reply-To: <65634d660911201550v34bc463ao17dcd7b16f62264f@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Tom Herbert <therbert@google.com>
Date: Fri, 20 Nov 2009 15:50:03 -0800

> We only set the bit in remote_softirq_cpus in here.  The actual IPIs
> are sent at the end net_rx_action.  I'm not exactly sure what you're
> thinking on this...

You're scheduling a softirq so you can schedule remote softirqs.

Just do that "for each rps cpu" loop at the end of NAPI ->poll()
processing.  In fact that seems to be what you're doing :-)

I guess my confusion is from the:

				__raise_softirq_irqoff(NET_RX_SOFTIRQ);

you are doing as you set the cpus in rps_remote_softirq_cpus.

Why do you need to schedule the local RX softirq, when we know we're
in a NAPI poll loop and thus that we're in a softirq, and thus that we
will fire off the IPIs at the end of net_rx_action()?

That's what you're doing, the softirq raising just seems superfluous.
