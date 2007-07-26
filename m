From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [PATCH RFC]: napi_struct V4
Date: Wed, 25 Jul 2007 21:55:08 -0400
Message-ID: <46A7FEFC.4040005@pobox.com>
References: <20070725.013154.34764933.davem@davemloft.net> <20070725095654.38a10abc@oldman.hamilton.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	hadi@cyberus.ca, rusty@rustcorp.com.au
To: Stephen Hemminger <shemminger@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:43230 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756675AbXGZBzO (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 25 Jul 2007 21:55:14 -0400
In-Reply-To: <20070725095654.38a10abc@oldman.hamilton.local>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Stephen Hemminger wrote:
> The usage of NAPI on 8139cp and 8139too seems dodgy;
> these drivers expect this to work:
> 
> 		local_irq_save(flags);
> 		cpw16_f(IntrMask, cp_intr_mask);
> 		__netif_rx_complete(dev);
> 		local_irq_restore(flags);
> 
> It works on SMP only because if poll races with IRQ, 
> the IRQ is not masked or cleared so the IRQ will get restarted.

Expect?  This _does_ work on both UP and SMP.


> Better would be to change it to:
> 		spin_lock_irqsave(&cp->lock, flags);
> 		cpw16_f(IntrMask, cp_intr_mask);
> 		__netif_rx_complete(dev);
> 		spin_unlock_irqrestore(&cp->lock, flags);
> 
> Which actually is same code on UP.

I'm missing your point?

You claim local_irq_save() works only on SMP, then suggest a solution 
that you agree produces the same result?

I don't see any logic to your request, only added overhead for no reason.

	Jeff


