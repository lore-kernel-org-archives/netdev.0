From: Alan Stern <stern@rowland.harvard.edu>
Subject: Re: [linux-pm] [PATCH] 3c59x: Get rid of "Trying to free already-free
 IRQ"
Date: Fri, 25 Sep 2009 00:43:47 -0400 (EDT)
Message-ID: <Pine.LNX.4.44L0.0909250038300.14463-100000@netrider.rowland.org>
References: <20090924183152.GA30254@oksana.dev.rtsoft.ru>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: David Miller <davem@davemloft.net>, <netdev@vger.kernel.org>,
	<linux-pm@lists.linux-foundation.org>
To: Anton Vorontsov <avorontsov@ru.mvista.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from netrider.rowland.org ([192.131.102.5]:57551 "HELO
	netrider.rowland.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with SMTP id S1750879AbZIYEnn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 25 Sep 2009 00:43:43 -0400
In-Reply-To: <20090924183152.GA30254@oksana.dev.rtsoft.ru>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 24 Sep 2009, Anton Vorontsov wrote:

> Though, there are few other issues with suspend/resume in this driver.
> The intention of calling free_irq() in suspend() was to avoid any
> possible spurious interrupts (see commit 5b039e681b8c5f30aac9cc04385
> "3c59x PM fixes"). But,
> 
> - On resume, the driver was requesting IRQ just after pci_set_master(),
>   but before vortex_up() (which actually resets 3c59x chips).

Shouldn't it be possible to reset the chip (or at least prevent it from 
generating spurious IRQs) during the early-resume phase?

> - Issuing free_irq() on a shared IRQ doesn't guarantee that a buggy
>   HW won't trigger spurious interrupts in another driver that
>   requested the same interrupt. So, if we want to protect from
>   unexpected interrupts, then on suspend we should issue disable_irq(),
>   not free_irq().

What if some other device shares the IRQ and still relies on receiving
interrupts when this code runs?  Won't disable_irq() mess up the other
device?

Alan Stern

