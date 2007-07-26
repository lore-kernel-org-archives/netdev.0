From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH RFC]: napi_struct V4
Date: Wed, 25 Jul 2007 17:37:31 -0700 (PDT)
Message-ID: <20070725.173731.98526781.davem@davemloft.net>
References: <20070725.013154.34764933.davem@davemloft.net>
	<20070725095654.38a10abc@oldman.hamilton.local>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jgarzik@pobox.com, hadi@cyberus.ca,
	rusty@rustcorp.com.au
To: shemminger@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:58589
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1750962AbXGZAhc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 25 Jul 2007 20:37:32 -0400
In-Reply-To: <20070725095654.38a10abc@oldman.hamilton.local>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Stephen Hemminger <shemminger@linux-foundation.org>
Date: Wed, 25 Jul 2007 09:56:54 +0100

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
> 
> Better would be to change it to:
> 		spin_lock_irqsave(&cp->lock, flags);
> 		cpw16_f(IntrMask, cp_intr_mask);
> 		__netif_rx_complete(dev);
> 		spin_unlock_irqrestore(&cp->lock, flags);
> 
> Which actually is same code on UP.

I've made these fixes to my tree, thanks Stephen.
