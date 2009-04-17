From: Haavard Skinnemoen <haavard.skinnemoen@atmel.com>
Subject: Re: [PATCH] macb: Add support of the netpoll API
Date: Fri, 17 Apr 2009 11:07:03 +0200
Message-ID: <20090417110703.781f8a0e@hskinnemoen-d830>
References: <20090415154658.40e3639a@surf>
	<20090416110753.5c75b805@hskinnemoen-d830>
	<20090416112435.0b779859@surf>
	<20090417.013450.02738760.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: thomas.petazzoni@free-electrons.com, netdev@vger.kernel.org,
	michael@free-electrons.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay.atmel.no ([80.232.32.139]:61626 "EHLO relay.atmel.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752752AbZDQJHM (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 17 Apr 2009 05:07:12 -0400
In-Reply-To: <20090417.013450.02738760.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller wrote:
> And in response to this Haavard explained the potential deadlock
> (sorry I deleted that email) and suggested to use local_irq_save()
> 
> But that won't work either, because it doesn't prevent the interrupt
> handler from running on other cpus, it only prevents that on the
> local cpu.

The interrupt handler takes bp->lock. Isn't that sufficient to prevent
it from running on other cpus?

If you do local_irq_save() around the interrupt handler, the end result
will be identical to spin_lock_irqsave(), which is what the other
(non-interrupt) parts of the driver use.

Or am I misunderstanding something?

Haavard
