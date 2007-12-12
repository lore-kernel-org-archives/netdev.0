From: "Remy Bohmer" <linux@bohmer.net>
Subject: Re: DM9000_IRQ_FLAGS
Date: Wed, 12 Dec 2007 15:46:29 +0100
Message-ID: <3efb10970712120646ub8f5047ub333b74658bab44d@mail.gmail.com>
References: <20071211191823.GD15295@buzzloop.caiaq.de>
	 <3efb10970712111231r29f9fba1l3528d805d1009c52@mail.gmail.com>
	 <20071212134153.GA21510@buzzloop.caiaq.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: "Daniel Mack" <daniel@caiaq.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rv-out-0910.google.com ([209.85.198.187]:48438 "EHLO
	rv-out-0910.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754225AbXLLOqm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 12 Dec 2007 09:46:42 -0500
Received: by rv-out-0910.google.com with SMTP id k20so226958rvb.1
        for <netdev@vger.kernel.org>; Wed, 12 Dec 2007 06:46:29 -0800 (PST)
In-Reply-To: <20071212134153.GA21510@buzzloop.caiaq.de>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello Daniel,

> However, request_irq() is called with IRQF_SHARED only, so neither
> IRQT_RISING nor IRQT_FALLING is set and the value defaults to
> IRQT_NOEDGE. How can you get IRQs?

The DM9000 adapter is connected to a GPIO line on the at91sam9261-ek
board, the board-specific code has a generic handler for every GPIO
interrupt. So, the Device driver __does not need to know__ the type of
interrupt, It just installs a handler by request_irq().

So, these flags are dependant on the board where the driver is
installed, and thus everything you want to define fixed in the driver
is not generic and thus wrong.
This is why a NACK your patch.

> Actually, the best way to go is to let the platform resources flags
> decide about that with something like
>
>         resource->flags = IORESOURCE_IRQ | IRQT_RISING;
>
These types of flags are never meant to be compatible, and thus they
shall not be stored in the same flags variable. The same is valid for
the flags IRQF_* and IRQT* flags, so request_irq() is also not the
place to do this.

You should look at the routine set_irq_type() in kernel/irq/chip.c.
This routine is supposed to be used for the IRQT_RISING type of flags
Just do a grep of IRQT_RISING in the arch/arm tree and you will find
enough examples.

Kind Regards,

Remy
