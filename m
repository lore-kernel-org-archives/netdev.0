From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/1] net: fec: fix miss init spinlock
Date: Thu, 21 Feb 2013 13:03:18 -0500 (EST)
Message-ID: <20130221.130318.641947665855008551.davem@davemloft.net>
References: <loom.20130221T175907-606@post.gmane.org>
	<CAOMZO5AJa7fs+VdA8jGE5mDnxp4ZQ6a9CjbSou5J+RA3uXUjxQ@mail.gmail.com>
	<loom.20130221T185110-574@post.gmane.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: jim_baxter@mentor.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:60899 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756199Ab3BUSDU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 21 Feb 2013 13:03:20 -0500
In-Reply-To: <loom.20130221T185110-574@post.gmane.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jim Baxter <jim_baxter@mentor.com>
Date: Thu, 21 Feb 2013 17:59:23 +0000 (UTC)

> Fabio Estevam <festevam <at> gmail.com> writes:
> 
>> 
>> On Thu, Feb 21, 2013 at 2:07 PM, Jim Baxter <jim_baxter <at> mentor.com> wrote:
>> > Is the general issue in this driver that the fec_probe function:
>> > request_irq(irq, fec_enet_interrupt, IRQF_DISABLED, pdev->name, ndev);
>> >
>> > is called before fec_ptp_init() and fec_enet_init() have been called so that
>> > there is a chance the fec_enet_interrupt can occur before the hardware and 
> data
>> > structures are fully setup?
>> 
>> The scenario you described is fixed by the patch that Frank proposed at:
>> http://patchwork.ozlabs.org/patch/222164/
>> 
> 
> That is a good patch that will stop interrupts occurring before request_irq is 
> called.
> 
> What about the problem of fec_enet_interrupt calling fec_ptp_start_cyclecounter 
> before fec_ptp_init has been called?
> 
> Should fec_enet_init and fec_ptp_init be setup before the request_irq is called?

This is a reocurring theme, and there is only one answer.

All software state MUCH be completely, and fully, initialized before
request_irq() is invoked.

There is no other valid way to proceed in this area.
