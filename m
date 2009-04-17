From: Haavard Skinnemoen <haavard.skinnemoen@atmel.com>
Subject: Re: [PATCH] macb: Add support of the netpoll API
Date: Fri, 17 Apr 2009 11:50:11 +0200
Message-ID: <20090417115011.5c3d17e1@hskinnemoen-d830>
References: <20090417110703.781f8a0e@hskinnemoen-d830>
	<20090417.020841.21679845.davem@davemloft.net>
	<20090417112553.21e1f2e5@hskinnemoen-d830>
	<20090417.023357.121366056.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: thomas.petazzoni@free-electrons.com, netdev@vger.kernel.org,
	michael@free-electrons.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay.atmel.no ([80.232.32.139]:55632 "EHLO relay.atmel.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756247AbZDQJuR (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 17 Apr 2009 05:50:17 -0400
In-Reply-To: <20090417.023357.121366056.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller wrote:
> From: Haavard Skinnemoen <haavard.skinnemoen@atmel.com>
> Date: Fri, 17 Apr 2009 11:25:53 +0200
> 
> > I guess you're right -- we just have to be careful about calling
> > printk() from within the driver. But it seems a lot easier to just drop
> > the lock before dumping an error message than it is to work around that
> > disable_irq() deadlock. And if you're running with verbose debugging
> > enabled, you probably shouldn't be using netconsole anyway.  
> 
> Therefore, do you agree to add Thomas's patch as-is?

No, therefore, I'd prefer local_irq_save() :-)

When using disable_irq(), there's no way we can call printk() from the
interrupt handler ever. When using local_irq_save() we can call
printk() from the interrupt handler provided that we drop the lock
first.

And since poll_controller() ends up taking the lock in both cases, we
need to be careful about calling printk() while holding the lock
anyway. So local_irq_save() means one less thing that might kill the
driver.

Haavard
