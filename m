From: Daniel Mack <daniel@caiaq.de>
Subject: Re: DM9000_IRQ_FLAGS
Date: Wed, 12 Dec 2007 14:41:53 +0100
Message-ID: <20071212134153.GA21510@buzzloop.caiaq.de>
References: <20071211191823.GD15295@buzzloop.caiaq.de> <3efb10970712111231r29f9fba1l3528d805d1009c52@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Remy Bohmer <linux@bohmer.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from buzzloop.caiaq.de ([212.112.241.133]:45090 "EHLO
	buzzloop.caiaq.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751485AbXLLNl6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 12 Dec 2007 08:41:58 -0500
Content-Disposition: inline
In-Reply-To: <3efb10970712111231r29f9fba1l3528d805d1009c52@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Remy,

On Tue, Dec 11, 2007 at 09:31:03PM +0100, Remy Bohmer wrote:
> This controller is also used on many other boards, like the e.g. Atmel
> AT91sam9261-ek board. On that board on both the rising _and_ falling
> edge an interrupt is generated.

However, request_irq() is called with IRQF_SHARED only, so neither
IRQT_RISING nor IRQT_FALLING is set and the value defaults to
IRQT_NOEDGE. How can you get IRQs?

> I can test tomorrow if this patch leaves this board in tact, but
> should the board-specific code not add this flag if it is required ?
> By modifying this driver you will interfere the behavior of other
> boards, and I do not know if there any level triggered types used.

Actually, the best way to go is to let the platform resources flags 
decide about that with something like

	resource->flags = IORESOURCE_IRQ | IRQT_RISING;

but the dm9000 does not care about them at all. Changing that would also
imply modifications to all board support code.

Regards,
Daniel

