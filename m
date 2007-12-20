From: Ben Dooks <ben@fluff.org>
Subject: Re: DM9000_IRQ_FLAGS
Date: Thu, 20 Dec 2007 09:46:26 +0000
Message-ID: <20071220094626.GB9216@fluff.org.uk>
References: <20071211191823.GD15295@buzzloop.caiaq.de> <3efb10970712111231r29f9fba1l3528d805d1009c52@mail.gmail.com> <20071212134153.GA21510@buzzloop.caiaq.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Remy Bohmer <linux@bohmer.net>, netdev@vger.kernel.org
To: Daniel Mack <daniel@caiaq.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 87-194-8-8.bethere.co.uk ([87.194.8.8]:49341 "EHLO
	kira.home.fluff.org" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1754949AbXLTJqk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 20 Dec 2007 04:46:40 -0500
Content-Disposition: inline
In-Reply-To: <20071212134153.GA21510@buzzloop.caiaq.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Dec 12, 2007 at 02:41:53PM +0100, Daniel Mack wrote:
> Hi Remy,
> 
> On Tue, Dec 11, 2007 at 09:31:03PM +0100, Remy Bohmer wrote:
> > This controller is also used on many other boards, like the e.g. Atmel
> > AT91sam9261-ek board. On that board on both the rising _and_ falling
> > edge an interrupt is generated.
> 
> However, request_irq() is called with IRQF_SHARED only, so neither
> IRQT_RISING nor IRQT_FALLING is set and the value defaults to
> IRQT_NOEDGE. How can you get IRQs?
> 
> > I can test tomorrow if this patch leaves this board in tact, but
> > should the board-specific code not add this flag if it is required ?
> > By modifying this driver you will interfere the behavior of other
> > boards, and I do not know if there any level triggered types used.
> 
> Actually, the best way to go is to let the platform resources flags 
> decide about that with something like
> 
> 	resource->flags = IORESOURCE_IRQ | IRQT_RISING;
> 
> but the dm9000 does not care about them at all. Changing that would also
> imply modifications to all board support code.

I did have a go at trying to get people to pass the information this
way, but it seem to be ignored last time I sent it. I can dig out the
code that converts resource->flags to IRQT_ flags.

-- 
Ben (ben@fluff.org, http://www.fluff.org/)

  'a smiley only costs 4 bytes'
